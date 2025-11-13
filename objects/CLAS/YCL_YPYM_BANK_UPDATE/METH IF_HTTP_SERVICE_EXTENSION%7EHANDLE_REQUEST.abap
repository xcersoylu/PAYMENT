  METHOD if_http_service_extension~handle_request.
    DATA(lv_request_body) = request->get_text( ).
    DATA(lv_get_method) = request->get_method( ).
    /ui2/cl_json=>deserialize( EXPORTING json = lv_request_body CHANGING data = ms_request ).

    IF ms_request-paymentnumbers IS INITIAL.
      MESSAGE ID 'YPYM_MESSAGES'
             TYPE 'E'
             NUMBER 003
             INTO DATA(lv_message).
      APPEND VALUE #( messagetype = 'E' message = lv_message ) TO ms_response-messages.
    ELSE.
      SELECT * FROM @ms_request-paymentnumbers AS paymentnumbers
               INNER JOIN ypym_t_payment AS db ON db~paymentnumber = paymentnumbers~paymentnumber
               WHERE db~bankfilestatus = '01'
               INTO TABLE @DATA(lt_check).
      IF sy-subrc = 0.
        MESSAGE ID 'YPYM_MESSAGES'
               TYPE 'E'
               NUMBER 004
               INTO lv_message.
        APPEND VALUE #( messagetype = 'E' message = lv_message ) TO ms_response-messages.
      ELSE.
        SELECT SINGLE * FROM i_housebankaccountlinkage WHERE housebank = @ms_request-companybankcode
                                                         AND housebankaccount = @ms_request-companyaccountcode
        INTO @DATA(ls_housebankaccountlinkage).
        LOOP AT ms_request-paymentnumbers INTO DATA(ls_paymentnumber).
          UPDATE ypym_t_payment
             SET   companybankcode = @ms_request-companybankcode,
                   companyaccountcode = @ms_request-companyaccountcode,
                   companyiban = @ls_housebankaccountlinkage-iban,
                   companybankinternalid = @ls_housebankaccountlinkage-bankinternalid,
                   companybankaccount = @ls_housebankaccountlinkage-bankaccount,
                   glaccount = @ls_housebankaccountlinkage-glaccount
             WHERE paymentnumber = @ls_paymentnumber-paymentnumber.
          IF sy-subrc = 0.
            COMMIT WORK AND WAIT.
          ELSE.
            UPDATE ypym_t_pay_cus
               SET   companybankcode = @ms_request-companybankcode,
                     companyaccountcode = @ms_request-companyaccountcode,
                     companyiban = @ls_housebankaccountlinkage-iban,
                     companybankinternalid = @ls_housebankaccountlinkage-bankinternalid,
                     companybankaccount = @ls_housebankaccountlinkage-bankaccount,
                     glaccount = @ls_housebankaccountlinkage-glaccount
               WHERE paymentnumber = @ls_paymentnumber-paymentnumber.
            IF sy-subrc = 0.
              COMMIT WORK AND WAIT.
            ELSE.
            UPDATE ypym_t_downpay
               SET   companybankcode = @ms_request-companybankcode,
                     companyaccountcode = @ms_request-companyaccountcode,
                     companyiban = @ls_housebankaccountlinkage-iban,
                     companybankinternalid = @ls_housebankaccountlinkage-bankinternalid,
                     companybankaccount = @ls_housebankaccountlinkage-bankaccount,
                     glaccount = @ls_housebankaccountlinkage-glaccount
               WHERE paymentnumber = @ls_paymentnumber-paymentnumber.
            IF sy-subrc = 0.
              COMMIT WORK AND WAIT.
            ELSE.
            ENDIF.
            ENDIF.
          ENDIF.
        ENDLOOP.
      ENDIF.
    ENDIF.
    DATA(lv_response_body) = /ui2/cl_json=>serialize( EXPORTING data = ms_response ).
    response->set_text( lv_response_body ).
    response->set_header_field( i_name = mc_header_content i_value = mc_content_type ).
  ENDMETHOD.