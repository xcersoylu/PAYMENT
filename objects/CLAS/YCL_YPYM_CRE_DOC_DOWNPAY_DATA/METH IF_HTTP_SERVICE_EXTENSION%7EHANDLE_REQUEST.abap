  METHOD if_http_service_extension~handle_request.
    DATA(lv_request_body) = request->get_text( ).
    DATA(lv_get_method) = request->get_method( ).
    DATA lr_bankfilestatus TYPE RANGE OF ypym_e_bankfilestatus.
    /ui2/cl_json=>deserialize( EXPORTING json = lv_request_body CHANGING data = ms_request ).
    IF ms_request-bankfilestatus IS NOT INITIAL.
      APPEND VALUE #( sign = 'I' option = 'EQ' low = ms_request-bankfilestatus ) TO lr_bankfilestatus.
    ENDIF.
    SELECT payment~paymentnumber,
           payment~purchaseorder,
           payment~purchaseorderitem,
          payment~paymentdate,
          ekko~supplier,
          i_supplier~suppliername,
          ekko~companycode,
          payment~paymentamount,
          payment~currency,
          bpbank~bankcountrykey AS supplierbankcountrykey,
          bpbank~banknumber AS supplierbanknumber,
          bpbank~bankaccount AS supplierbankaccount,
          payment~supplieriban,
          bpbank~swiftcode AS supplierswiftcode,
          bpbank~bankname AS supplierbankname,
          bank~bankbranch AS supplierbankbranch,
          payment~paymentexplanation,
          payment~receiptexplanation,
          payment~companybankcode,
          payment~companyaccountcode,
          payment~companyiban,
          payment~companybankinternalid,
          payment~companybankaccount,
          payment~paymentrequestdate,
          payment~bankfilestatus,
          payment~paymentstatus,
          paymenttext~text AS paymentstatustext,
          CASE WHEN substring( payment~companybankinternalid,1,4 ) = '0062'
                    THEN CASE WHEN ekko~documentcurrency = 'TRY'
                              THEN 'HAVALE/EFT'
                              ELSE CASE WHEN substring( bpbank~banknumber,1,4 ) = substring( payment~companybankinternalid,1,4 )
                                        THEN 'HAVALE'
                                        ELSE 'EFT'
                                    END
                           END
                    ELSE 'HAVALE/EFT' END AS transfer_type,
          payment~paymentdocument,
          payment~paymentdocumentyear,
          payment~clearingdocument,
          payment~clearingdocumentyear
    FROM ypym_t_downpay AS payment INNER JOIN i_purchaseorderapi01 AS ekko ON ekko~purchaseorder = payment~purchaseorder
    LEFT OUTER JOIN i_supplier ON i_supplier~supplier = ekko~supplier
    LEFT OUTER JOIN i_businesspartnerbank AS bpbank ON bpbank~businesspartner = ekko~supplier
                                              AND bpbank~iban = payment~supplieriban
      LEFT OUTER JOIN i_bank_2 AS bank ON bank~bankcountry = bpbank~bankcountrykey
                                      AND bank~bankinternalid = bpbank~banknumber
        LEFT OUTER JOIN ddcds_customer_domain_value_t( p_domain_name = 'YPYM_D_PAYMENTSTATUS' ) AS paymenttext
            ON paymenttext~value_low = payment~paymentstatus
            AND paymenttext~language = @sy-langu
    WHERE approvementstatus = @mc_completed
      AND payment~companycode = @ms_request-companycode
      AND payment~paymentnumber IN @ms_request-paymentnumber
      AND payment~bankfilestatus IN @lr_bankfilestatus
      AND payment~paymentrequestdate IN @ms_request-paymentrequestdate
    INTO CORRESPONDING FIELDS OF TABLE @ms_response-items.
    IF sy-subrc = 0.
      LOOP AT ms_response-items INTO DATA(ls_item) GROUP BY ( paymentnumber = ls_item-paymentnumber
                                                              companybankcode = ls_item-companybankcode ).
        LOOP AT GROUP ls_item INTO DATA(ls_member).
          COLLECT VALUE ypym_s_downpay_save_doc_header( paymentnumber         = ls_member-paymentnumber
                                                        paymentdate           = ls_member-paymentdate
                                                        companycode           = ls_member-companycode
                                                        paymentamount         = ls_member-paymentamount
                                                        currency              = ls_member-currency
                                                        companybankcode       = ls_member-companybankcode
                                                        companyaccountcode    = ls_member-companyaccountcode
                                                        bankfilestatus        = ls_member-bankfilestatus
                                                        companybankinternalid = ls_member-companybankinternalid
                                                        paymentrequestdate    = ls_member-paymentrequestdate ) INTO ms_response-header.
        ENDLOOP.
      ENDLOOP.
    ENDIF.

    DATA(lv_response_body) = /ui2/cl_json=>serialize( EXPORTING data = ms_response ).
    response->set_text( lv_response_body ).
    response->set_header_field( i_name = mc_header_content i_value = mc_content_type ).
  ENDMETHOD.