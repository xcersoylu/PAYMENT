  METHOD if_http_service_extension~handle_request.
    DATA(lv_request_body) = request->get_text( ).
    DATA(lv_get_method) = request->get_method( ).
    DATA lr_bankfilestatus type rANGE OF ypym_e_bankfilestatus.
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
          paymenttext~text AS paymentstatustext
    FROM ypym_t_downpay AS payment INNER JOIN I_PurchaseOrderAPI01 AS ekko ON ekko~purchaseorder = payment~purchaseorder
    left outer JOIN i_supplier ON i_supplier~supplier = ekko~supplier
    left outer JOIN i_businesspartnerbank AS bpbank ON bpbank~businesspartner = ekko~supplier
                                              AND bpbank~iban = payment~supplieriban
      left outer JOIN i_bank_2 AS bank ON bank~bankcountry = bpbank~bankcountrykey
                                      AND bank~bankinternalid = bpbank~banknumber
        left oUTER join ddcds_customer_domain_value_t( p_domain_name = 'YPYM_D_PAYMENTSTATUS' ) as paymenttext
            on paymenttext~value_low = payment~paymentstatus
            and paymenttext~language = @sy-langu
    WHERE approvementstatus = @mc_completed
      AND payment~companycode = @ms_request-companycode
      AND payment~paymentnumber IN @ms_request-paymentnumber
      AND payment~bankfilestatus in @lr_bankfilestatus
      AND payment~paymentrequestdate in @ms_request-paymentrequestdate
    INTO CORRESPONDING FIELDS OF TABLE @ms_response-items.
    IF sy-subrc = 0.
      LOOP AT ms_response-items INTO DATA(ls_item) GROUP BY ( paymentnumber = ls_item-paymentnumber
                                                              companybankcode = ls_item-companybankcode ).
        COLLECT VALUE ypym_s_downpay_save_doc_header( paymentnumber      = ls_item-paymentnumber
                                                      paymentdate        = ls_item-paymentdate
                                                      companycode        = ls_item-companycode
                                                      paymentamount      = ls_item-paymentamount
                                                      currency           = ls_item-transactioncurrency
                                                      companybankcode    = ls_item-companybankcode
                                                      companyaccountcode = ls_item-companyaccountcode
                                                      bankfilestatus     = ls_item-bankfilestatus
                                                      companybankinternalid = ls_item-companybankinternalid
                                                      paymentrequestdate = ls_item-paymentrequestdate ) INTO ms_response-header.
      ENDLOOP.
    ENDIF.

    DATA(lv_response_body) = /ui2/cl_json=>serialize( EXPORTING data = ms_response ).
    response->set_text( lv_response_body ).
    response->set_header_field( i_name = mc_header_content i_value = mc_content_type ).
  ENDMETHOD.