  METHOD if_http_service_extension~handle_request.
    DATA(lv_request_body) = request->get_text( ).
    DATA(lv_get_method) = request->get_method( ).
    /ui2/cl_json=>deserialize( EXPORTING json = lv_request_body CHANGING data = ms_request ).
    LOOP AT ms_request-customer ASSIGNING FIELD-SYMBOL(<ls_customer>).
      IF <ls_customer>-low IS NOT INITIAL.
        <ls_customer>-low = |{ <ls_customer>-low ALPHA = IN }|.
      ENDIF.
      IF <ls_customer>-high IS NOT INITIAL.
        <ls_customer>-high = |{ <ls_customer>-high ALPHA = IN }|.
      ENDIF.
    ENDLOOP.
    SELECT bsid~companycode,
           bsid~customer,
           i_customer~customername,
           bsid~specialgltransactiontype,
           bsid~specialglcode,
           bsid~clearingdate,
           bsid~clearingjournalentry,
           bsid~assignmentreference,
           bsid~fiscalyear,
           bsid~accountingdocument,
           bsid~accountingdocumentitem,
           bsid~duecalculationbasedate,
           bsid~cashdiscount1days,
           dats_add_days( bsid~duecalculationbasedate , CAST( CAST( bsid~cashdiscount1days AS CHAR( 5 ) ) AS INT4 ) ) AS invoiceduedate,
           bsid~postingdate,
           bsid~documentdate,
           bsid~debitcreditcode,
           bsid~accountingdocumenttype,
           bsid~accountingdoccreatedbyuser,
           bsid~absoluteamountintransaccrcy,
           bsid~transactioncurrency,
           bsid~absoluteamountincocodecrcy,
           bsid~companycodecurrency,
           bsid~absltamtinadditionalcurrency1,
           bsid~additionalcurrency1,
           bsid~absltamtinadditionalcurrency2,
           bsid~additionalcurrency2,
           bsid~absoluteamountintransaccrcy AS paymentamount,
           bsid~transactioncurrency AS currency,
           bsid~documentitemtext,
           bsid~paymentmethod,
           bsid~purchasingdocument,
           bsid~paymentblockingreason,
           bsid~paymentterms,
           bsid~businessarea,
           bsid~absoluteexchangerate,
           bsid~originalreferencedocument,
           bsid~parkedbyuser,
           bsid~documentreferenceid
      FROM yi_pym_ddl_bsid AS bsid
      INNER JOIN ypym_t_doctype AS doctype ON doctype~documenttype = bsid~accountingdocumenttype
      INNER JOIN i_customer ON i_customer~customer = bsid~customer
        LEFT OUTER JOIN i_companycode AS t001 ON t001~companycode = bsid~companycode
        WHERE NOT EXISTS ( SELECT * FROM ypym_t_pay_cus WHERE accountingdocument = bsid~accountingdocument
                                                          AND fiscalyear = bsid~fiscalyear
                                                          AND accountingdocumentitem = bsid~accountingdocumentitem
                                                          AND approvementstatus NE 'REJECTED' )
          AND bsid~companycode = @ms_request-companycode
          AND bsid~accountingdocument IN @ms_request-accountingdocument
          AND bsid~fiscalyear IN @ms_request-fiscalyear
          AND bsid~customer IN @ms_request-customer
          AND bsid~paymentblockingreason IN @ms_request-paymentblockingreason
          AND bsid~transactioncurrency IN @ms_request-currency
          AND bsid~specialglcode IN @ms_request-specialglcode
          AND dats_add_days( bsid~duecalculationbasedate , CAST( CAST( bsid~cashdiscount1days AS CHAR( 5 ) ) AS INT4 ) ) IN @ms_request-invoiceduedate
          AND bsid~accountingdocumenttype IN @ms_request-documenttype
          AND bsid~postingdate IN @ms_request-postingdate
          AND bsid~isreversal = ''
          AND bsid~isreversed = ''
          AND bsid~debitcreditcode = 'H'
        INTO CORRESPONDING FIELDS OF TABLE @ms_response-data.


    DATA(lt_customer) = ms_response-data.
    SORT lt_customer BY customer.
    DELETE ADJACENT DUPLICATES FROM lt_customer.
    IF lt_customer IS NOT INITIAL.
      SELECT bsid~customer,
             bpbank~bankcountrykey AS supplierbankcountrykey,
             bpbank~banknumber     AS supplierbanknumber,
             bpbank~bankaccount    AS supplierbankaccount,
             bpbank~iban           AS supplieriban,
             bpbank~swiftcode      AS supplierswiftcode,
             bpbank~bankname       AS supplierbankname,
             bank~bankbranch       AS supplierbankbrunch
      FROM @lt_customer AS bsid
      INNER JOIN i_businesspartnerbank AS bpbank ON bpbank~businesspartner = bsid~customer
      INNER JOIN i_bank_2 AS bank ON bank~bankcountry = bpbank~bankcountrykey
                                      AND bank~bankinternalid = bpbank~banknumber
      ORDER BY bsid~customer
      INTO TABLE @DATA(lt_customer_bank).
      IF sy-subrc = 0.
        LOOP AT ms_response-data ASSIGNING FIELD-SYMBOL(<ls_data>).
          READ TABLE lt_customer_bank INTO DATA(ls_customer_bank) WITH KEY customer = <ls_data>-customer BINARY SEARCH.
          IF sy-subrc = 0.
            <ls_data>-customerbankcountrykey = ls_customer_bank-supplierbankcountrykey.
            <ls_data>-customerbanknumber     = ls_customer_bank-supplierbanknumber.
            <ls_data>-customerbankaccount    = ls_customer_bank-supplierbankaccount.
            <ls_data>-customeriban           = ls_customer_bank-supplieriban.
            <ls_data>-customerswiftcode      = ls_customer_bank-supplierswiftcode.
            <ls_data>-customerbankname       = ls_customer_bank-supplierbankname.
            <ls_data>-customerbankbrunch     = ls_customer_bank-supplierbankbrunch.
          ENDIF.
        ENDLOOP.
      ENDIF.
    ENDIF.
    DATA(lv_response_body) = /ui2/cl_json=>serialize( EXPORTING data = ms_response ).
    response->set_text( lv_response_body ).
    response->set_header_field( i_name = mc_header_content i_value = mc_content_type ).
  ENDMETHOD.