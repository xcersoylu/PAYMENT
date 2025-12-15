  METHOD if_http_service_extension~handle_request.
    DATA lv_subject TYPE string.
    DATA lv_content TYPE string.
    DATA lt_approve TYPE TABLE OF ypym_t_approve.
    DATA lt_payment TYPE TABLE OF ypym_t_pay_cus.
    DATA(lv_request_body) = request->get_text( ).
    DATA(lv_get_method) = request->get_method( ).
    /ui2/cl_json=>deserialize( EXPORTING json = lv_request_body CHANGING data = ms_request ).

    lt_payment = CORRESPONDING #(  ms_request-paymentlist ).
    LOOP AT ms_request-paymentlist INTO DATA(ls_paymentlist) WHERE customeriban IS INITIAL.
      EXIT.
    ENDLOOP.
    IF sy-subrc = 0.
      MESSAGE ID 'YPYM_MESSAGES' TYPE 'E' NUMBER 016 INTO DATA(lv_message).
      ms_response-messages = VALUE #( (  messagetype = 'E' message = lv_message ) ).
    ENDIF.
    DATA(lt_approvers) = ycl_pym_approvement=>get_all_approvers( EXPORTING
                                                              iv_companycode   = ms_request-companycode
                                                              iv_approvergroup = ms_request-approvergroup ).
    IF lt_approvers IS INITIAL.
      MESSAGE ID 'YPYM_MESSAGES' TYPE 'E' NUMBER 006 INTO lv_message.
      ms_response-messages = VALUE #( (  messagetype = 'E' message = lv_message ) ).
    ENDIF.
    IF ms_response-messages IS INITIAL.
      TRY.
          cl_numberrange_runtime=>number_get(
            EXPORTING
              nr_range_nr       = '01'
              object            = 'YPAYNUMBER'
            IMPORTING
              number            = DATA(lv_paymentnumber)
              returncode        = DATA(lv_returncode)
              returned_quantity = DATA(lv_returned_quantity)
          ).
          LOOP AT lt_payment ASSIGNING FIELD-SYMBOL(<ls_payment>).
            <ls_payment>-companycode = ms_request-companycode.
            <ls_payment>-paymentrequestdate = ms_request-paymentrequestdate.
            <ls_payment>-paymentnumber = lv_paymentnumber.
            <ls_payment>-approvementstatus = mc_inprocess.
            <ls_payment>-bankfilestatus = mc_not_processed.
            <ls_payment>-createduser = cl_abap_context_info=>get_user_technical_name(  ).
            <ls_payment>-createdate = cl_abap_context_info=>get_system_date(  ).
            <ls_payment>-createtime = cl_abap_context_info=>get_system_time(  ).
          ENDLOOP.
          INSERT ypym_t_pay_cus FROM TABLE @lt_payment.
          IF sy-subrc = 0.

            lt_approve = VALUE #( FOR ls_approver IN lt_approvers ( paymentnumber = lv_paymentnumber
                                                                    approvergroupsequence = ls_approver-approvergroupsequence
                                                                    approver = ls_approver-approver
                                                                    paymenttype = '03'
                                                                    approvementstatus = COND #( WHEN ls_approver-approvergroupsequence = '01' THEN mc_inprocess ELSE mc_waiting ) ) ) .
            INSERT ypym_t_approve FROM TABLE @lt_approve.
            lv_paymentnumber = |{ lv_paymentnumber ALPHA = OUT }|. CONDENSE lv_paymentnumber NO-GAPS.
            lv_subject = |{ lv_paymentnumber } nolu ödeme onayınızı bekliyor.|.
            lv_content = |{ lv_paymentnumber } nolu ödeme onayınızı bekliyor.|.
            ycl_pym_approvement=>send_mail(
              iv_sender    = ycl_pym_approvement=>get_email( CONV #( cl_abap_context_info=>get_user_technical_name(  ) ) )
              it_recipient = VALUE #( FOR ls_recipient IN lt_approvers WHERE ( approvergroupsequence = '01' ) ( CORRESPONDING #( ls_recipient ) ) )
              iv_subject   = lv_subject
              iv_content   = lv_content
            ).
            ms_response-paymentnumber = lv_paymentnumber.
            MESSAGE ID 'YPYM_MESSAGES' TYPE 'I' NUMBER 002 WITH |{ lv_paymentnumber ALPHA = OUT }| INTO lv_message.
            ms_response-messages = VALUE #( (  messagetype = 'S' message = lv_message ) ).
          ENDIF.
        CATCH cx_nr_object_not_found.
        CATCH cx_number_ranges.
      ENDTRY.
    ENDIF.
    DATA(lv_response_body) = /ui2/cl_json=>serialize( EXPORTING data = ms_response ).
    response->set_text( lv_response_body ).
    response->set_header_field( i_name = mc_header_content i_value = mc_content_type ).
  ENDMETHOD.