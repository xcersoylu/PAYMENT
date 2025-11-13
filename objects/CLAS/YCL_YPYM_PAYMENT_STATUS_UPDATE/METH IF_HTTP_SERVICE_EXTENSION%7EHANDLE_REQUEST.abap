  METHOD if_http_service_extension~handle_request.
    DATA(lv_request_body) = request->get_text( ).
    DATA(lv_get_method) = request->get_method( ).
    /ui2/cl_json=>deserialize( EXPORTING json = lv_request_body CHANGING data = ms_request ).
    DATA(lv_datum) = cl_abap_context_info=>get_system_date( ).
    DATA(lv_uzeit) = cl_abap_context_info=>get_system_time( ).
    DATA(lv_uname) = cl_abap_context_info=>get_user_alias( ).
    CASE ms_request-programtype.
      WHEN 'S'. "supplier - satıcı
        IF ms_request-items IS NOT INITIAL.
          SELECT payment~paymentnumber,
                payment~accountingdocument,
                payment~fiscalyear,
                payment~accountingdocumentitem
          FROM @ms_request-items AS items
                   INNER JOIN ypym_t_payment AS payment ON payment~paymentnumber = items~paymentnumber
                                                       AND payment~accountingdocument = items~accountingdocument
                                                       AND payment~fiscalyear = items~fiscalyear
                                                       AND payment~accountingdocumentitem = items~accountingdocumentitem
           WHERE payment~paymentstatus IN ( '01','99' )
           INTO TABLE @DATA(lt_payment_exists).
          IF sy-subrc = 0.
            LOOP AT lt_payment_exists INTO DATA(ls_exist).
              MESSAGE ID 'YPYM_MESSAGES' TYPE 'E' NUMBER 008 WITH ls_exist-accountingdocument
                                                                  ls_exist-fiscalyear
                                                                  ls_exist-accountingdocumentitem
                                                             INTO DATA(lv_message).
              APPEND VALUE #( messagetype = 'E' message = lv_message ) TO ms_response-messages.
              CLEAR lv_message.
            ENDLOOP.
          ENDIF.
        ENDIF.
        IF ms_response-messages IS INITIAL.
          LOOP AT ms_request-items INTO DATA(ls_item).
            UPDATE ypym_t_payment
                SET paymentstatus = @ms_request-paymentstatus ,
                    manualpaymentstatususer = @lv_uname ,
                    manualpaymentstatusdate = @lv_datum,
                    manualpaymentstatustime = @lv_uzeit
                WHERE paymentnumber = @ls_item-paymentnumber
                  AND accountingdocument = @ls_item-accountingdocument
                  AND fiscalyear = @ls_item-fiscalyear
                  AND accountingdocumentitem = @ls_item-accountingdocumentitem.
            IF sy-subrc = 0.
              MESSAGE ID 'YPYM_MESSAGES' TYPE 'S' NUMBER 007 WITH ls_item-accountingdocument
                                                                  ls_item-fiscalyear
                                                                  ls_item-accountingdocumentitem
                                                             INTO lv_message.
              APPEND VALUE #( messagetype = 'S' message = lv_message ) TO ms_response-messages.
              CLEAR lv_message.
            ENDIF.
          ENDLOOP.
        ENDIF.
      WHEN 'C'. "customer - müşteri
        IF ms_request-items IS NOT INITIAL.
          SELECT payment~paymentnumber,
                payment~accountingdocument,
                payment~fiscalyear,
                payment~accountingdocumentitem
          FROM @ms_request-items AS items
                   INNER JOIN ypym_t_pay_cus AS payment ON payment~paymentnumber = items~paymentnumber
                                                       AND payment~accountingdocument = items~accountingdocument
                                                       AND payment~fiscalyear = items~fiscalyear
                                                       AND payment~accountingdocumentitem = items~accountingdocumentitem
           WHERE payment~paymentstatus IN ( '01','99' )
           INTO TABLE @lt_payment_exists.
          IF sy-subrc = 0.
            LOOP AT lt_payment_exists INTO ls_exist.
              MESSAGE ID 'YPYM_MESSAGES' TYPE 'E' NUMBER 008 WITH ls_exist-accountingdocument
                                                                  ls_exist-fiscalyear
                                                                  ls_exist-accountingdocumentitem
                                                             INTO lv_message.
              APPEND VALUE #( messagetype = 'E' message = lv_message ) TO ms_response-messages.
              CLEAR lv_message.
            ENDLOOP.
          ENDIF.
        ENDIF.
        IF ms_response-messages IS INITIAL.
          LOOP AT ms_request-items INTO ls_item.
            UPDATE ypym_t_pay_cus
                SET paymentstatus = @ms_request-paymentstatus ,
                    manualpaymentstatususer = @lv_uname ,
                    manualpaymentstatusdate = @lv_datum,
                    manualpaymentstatustime = @lv_uzeit
                WHERE paymentnumber = @ls_item-paymentnumber
                  AND accountingdocument = @ls_item-accountingdocument
                  AND fiscalyear = @ls_item-fiscalyear
                  AND accountingdocumentitem = @ls_item-accountingdocumentitem.
            IF sy-subrc = 0.
              MESSAGE ID 'YPYM_MESSAGES' TYPE 'S' NUMBER 007 WITH ls_item-accountingdocument
                                                                  ls_item-fiscalyear
                                                                  ls_item-accountingdocumentitem
                                                             INTO lv_message.
              APPEND VALUE #( messagetype = 'S' message = lv_message ) TO ms_response-messages.
              CLEAR lv_message.
            ENDIF.
          ENDLOOP.
        ENDIF.
      WHEN 'D'. "downpay - peşinat

        IF ms_request-items IS NOT INITIAL.
          SELECT downpay~paymentnumber,
                 downpay~purchaseorder,
                 downpay~purchaseorderitem
          FROM @ms_request-items AS items
                   INNER JOIN ypym_t_downpay AS downpay ON downpay~paymentnumber = items~paymentnumber
                                                       AND downpay~purchaseorder = items~purchaseorder
                                                       AND downpay~purchaseorderitem = items~purchaseorderitem
           WHERE downpay~paymentstatus IN ( '01','99' )
           INTO TABLE @DATA(lt_downpay_exists).
          IF sy-subrc = 0.
            LOOP AT lt_downpay_exists INTO DATA(ls_downpay_exist).
              MESSAGE ID 'YPYM_MESSAGES' TYPE 'E' NUMBER 008 WITH ls_downpay_exist-purchaseorder
                                                                  ls_downpay_exist-purchaseorderitem
                                                             INTO lv_message.
              APPEND VALUE #( messagetype = 'E' message = lv_message ) TO ms_response-messages.
              CLEAR lv_message.
            ENDLOOP.
          ENDIF.
        ENDIF.
        IF ms_response-messages IS INITIAL.
          LOOP AT ms_request-items INTO ls_item.
            UPDATE ypym_t_downpay
                SET paymentstatus = @ms_request-paymentstatus ,
                    manualpaymentstatususer = @lv_uname ,
                    manualpaymentstatusdate = @lv_datum,
                    manualpaymentstatustime = @lv_uzeit
                WHERE paymentnumber = @ls_item-paymentnumber
                  AND purchaseorder = @ls_item-purchaseorder
                  AND purchaseorderitem = @ls_item-purchaseorderitem.
            IF sy-subrc = 0.
              MESSAGE ID 'YPYM_MESSAGES' TYPE 'S' NUMBER 007 WITH ls_item-purchaseorder
                                                                  ls_item-purchaseorderitem
                                                             INTO lv_message.
              APPEND VALUE #( messagetype = 'S' message = lv_message ) TO ms_response-messages.
              CLEAR lv_message.
            ENDIF.
          ENDLOOP.
        ENDIF.
    ENDCASE.

    DATA(lv_response_body) = /ui2/cl_json=>serialize( EXPORTING data = ms_response ).
    response->set_text( lv_response_body ).
    response->set_header_field( i_name = mc_header_content i_value = mc_content_type ).
  ENDMETHOD.