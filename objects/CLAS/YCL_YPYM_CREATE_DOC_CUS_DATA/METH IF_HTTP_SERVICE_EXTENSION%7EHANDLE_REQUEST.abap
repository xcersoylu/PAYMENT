  METHOD if_http_service_extension~handle_request.
    DATA(lv_request_body) = request->get_text( ).
    DATA(lv_get_method) = request->get_method( ).
    DATA lr_bankfilestatus TYPE RANGE OF ypym_e_bankfilestatus.
    /ui2/cl_json=>deserialize( EXPORTING json = lv_request_body CHANGING data = ms_request ).
    IF ms_request-bankfilestatus IS NOT INITIAL.
      APPEND VALUE #( sign = 'I' option = 'EQ' low = ms_request-bankfilestatus ) TO lr_bankfilestatus.
    ENDIF.
    SELECT payment~paymentnumber,
          payment~paymentdate,
          bsid~customer,
          i_customer~customername,
          payment~companycode,
          payment~accountingdocument,
          payment~fiscalyear,
          payment~accountingdocumentitem,
          bsid~absoluteamountincocodecrcy,
          bsid~companycodecurrency,
          bsid~absoluteamountintransaccrcy,
          bsid~transactioncurrency,
          payment~paymentamount,
          payment~currency,
          bsid~absltamtinadditionalcurrency1,
          bsid~additionalcurrency1,
          bsid~absltamtinadditionalcurrency2,
          bsid~additionalcurrency2,
          bsid~postingdate,
          bsid~documentdate,
          bpbank~bankcountrykey AS customerbankcountrykey,
          bpbank~banknumber AS customerbanknumber,
          bpbank~bankaccount AS customerbankaccount,
          payment~customeriban,
          bpbank~swiftcode AS customerswiftcode,
          bpbank~bankname AS customerbankname,
          bank~bankbranch AS customerbankbranch,
          payment~paymentexplanation,
          payment~receiptexplanation,
          payment~companybankcode,
          payment~companyaccountcode,
          payment~companyiban,
          payment~companybankinternalid,
          payment~companybankaccount,
          payment~glaccount,
          payment~paymentrequestdate,
          payment~bankfilestatus,
          payment~paymentstatus,
          paymenttext~text AS paymentstatustext,
          taxnum~bptaxnumber,
          tckn~bptaxnumber AS tckn,
          bsid~documentreferenceid,
          t012~swiftcode AS companyswiftcode,
          CASE WHEN substring( payment~companybankinternalid,1,4 ) = '0062'
                    THEN CASE WHEN bsid~transactioncurrency = 'TRY'
                              THEN 'HAVALE/EFT'
                              ELSE CASE WHEN substring( bpbank~banknumber,1,4 ) = substring( payment~companybankinternalid,1,4 )
                                        THEN 'HAVALE'
                                        ELSE 'EFT'
                                    END
                           END
                    ELSE 'HAVALE/EFT' END AS transfer_type
    FROM ypym_t_pay_cus AS payment INNER JOIN yi_pym_ddl_bsid AS bsid ON bsid~accountingdocument = payment~accountingdocument
                                                                     AND bsid~accountingdocumentitem = payment~accountingdocumentitem
                                                                     AND bsid~fiscalyear = payment~fiscalyear
    LEFT OUTER JOIN i_customer ON i_customer~customer = bsid~customer
    LEFT OUTER JOIN i_businesspartnerbank AS bpbank ON bpbank~businesspartner = bsid~customer
                                              AND bpbank~iban = payment~customeriban
    LEFT OUTER JOIN i_bank_2 AS bank ON bank~bankcountry = bpbank~bankcountrykey
                                      AND bank~bankinternalid = bpbank~banknumber
    LEFT OUTER JOIN   i_housebankaccountlinkage AS t012 ON t012~companycode = payment~companycode
                                                   AND t012~housebank        = payment~companybankcode "inner
                                                   AND t012~housebankaccount = payment~companyaccountcode
        LEFT OUTER JOIN i_businesspartnertaxnumber AS taxnum ON taxnum~businesspartner = bsid~customer
                                                            AND taxnum~bptaxtype = 'TR2'
        LEFT OUTER JOIN i_businesspartnertaxnumber AS tckn ON tckn~businesspartner = bsid~customer
                                                            AND tckn~bptaxtype = 'TR3'
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
        COLLECT VALUE ypym_s_save_doc_cus_header( paymentnumber      = ls_item-paymentnumber
                                                  paymentdate        = ls_item-paymentdate
                                                  companycode        = ls_item-companycode
                                                  paymentamount      = ls_item-paymentamount
                                                  currency           = ls_item-currency
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