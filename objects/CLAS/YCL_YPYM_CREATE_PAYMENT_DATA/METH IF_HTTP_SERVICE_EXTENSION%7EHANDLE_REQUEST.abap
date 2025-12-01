  METHOD if_http_service_extension~handle_request.
    DATA(lv_request_body) = request->get_text( ).
    DATA(lv_get_method) = request->get_method( ).
    /ui2/cl_json=>deserialize( EXPORTING json = lv_request_body CHANGING data = ms_request ).
    LOOP AT ms_request-supplier ASSIGNING FIELD-SYMBOL(<ls_supplier>).
      IF <ls_supplier>-low IS NOT INITIAL.
        <ls_supplier>-low = |{ <ls_supplier>-low ALPHA = IN }|.
      ENDIF.
      IF <ls_supplier>-high IS NOT INITIAL.
        <ls_supplier>-high = |{ <ls_supplier>-high ALPHA = IN }|.
      ENDIF.
    ENDLOOP.
    SELECT bsik~companycode,
           bsik~supplier,
           i_supplier~suppliername,
           bsik~specialgltransactiontype,
           bsik~specialglcode,
           bsik~clearingdate,
           bsik~clearingjournalentry,
           bsik~assignmentreference,
           bsik~fiscalyear,
           bsik~accountingdocument,
           bsik~accountingdocumentitem,
           bsik~duecalculationbasedate,
           bsik~cashdiscount1days,
           dats_add_days( bsik~duecalculationbasedate , CAST( CAST( bsik~cashdiscount1days AS CHAR( 5 ) ) AS INT4 ) ) AS invoiceduedate,
           bsik~postingdate,
           bsik~documentdate,
           bsik~debitcreditcode,
           bsik~accountingdocumenttype,
           bsik~accountingdoccreatedbyuser,
           bsik~absoluteamountintransaccrcy,
           bsik~transactioncurrency,
           bsik~absoluteamountincocodecrcy,
           bsik~companycodecurrency,
           bsik~absltamtinadditionalcurrency1,
           bsik~additionalcurrency1,
           bsik~absltamtinadditionalcurrency2,
           bsik~additionalcurrency2,
           bsik~absoluteamountintransaccrcy AS paymentamount,
           bsik~documentitemtext,
           bsik~paymentmethod,
           bsik~purchasingdocument,
           bsik~paymentblockingreason,
           bsik~paymentterms,
           bsik~businessarea,
           bsik~absoluteexchangerate,
           bsik~originalreferencedocument,
           bsik~parkedbyuser,
           taxnum~bptaxnumber,
           tckn~bptaxnumber AS tckn,
           bsik~documentreferenceid
      FROM yi_pym_ddl_bsik AS bsik
      INNER JOIN ypym_t_doctype AS doctype ON doctype~documenttype = bsik~accountingdocumenttype
      INNER JOIN i_supplier ON  i_supplier~supplier = bsik~supplier
        LEFT OUTER JOIN i_companycode AS t001 ON t001~companycode = bsik~companycode
        LEFT OUTER JOIN i_supplier AS supplier ON supplier~supplier = bsik~supplier
        LEFT OUTER JOIN i_businesspartnertaxnumber AS taxnum ON taxnum~businesspartner = bsik~supplier
                                                            AND taxnum~bptaxtype = 'TR2'
        LEFT OUTER JOIN i_businesspartnertaxnumber AS tckn ON tckn~businesspartner = bsik~supplier
                                                            AND tckn~bptaxtype = 'TR3'
        WHERE NOT EXISTS ( SELECT * FROM ypym_t_payment WHERE accountingdocument = bsik~accountingdocument
                                                          AND fiscalyear = bsik~fiscalyear
                                                          AND accountingdocumentitem = bsik~accountingdocumentitem
                                                          AND approvementstatus NE 'REJECTED' )
          AND bsik~companycode = @ms_request-companycode
          AND bsik~accountingdocument IN @ms_request-accountingdocument
          AND bsik~fiscalyear IN @ms_request-fiscalyear
          AND bsik~supplier IN @ms_request-supplier
          AND bsik~paymentblockingreason IN @ms_request-paymentblockingreason
          AND bsik~transactioncurrency IN @ms_request-currency
          AND bsik~specialglcode IN @ms_request-specialglcode
          AND dats_add_days( bsik~duecalculationbasedate , CAST( CAST( bsik~cashdiscount1days AS CHAR( 5 ) ) AS INT4 ) ) IN @ms_request-invoiceduedate
          AND bsik~accountingdocumenttype IN @ms_request-documenttype
          AND bsik~postingdate IN @ms_request-postingdate
          AND bsik~isreversal = ''
          AND bsik~isreversed = ''
        INTO CORRESPONDING FIELDS OF TABLE @ms_response-data.


    DATA(lt_supplier) = ms_response-data.
    SORT lt_supplier BY supplier.
    DELETE ADJACENT DUPLICATES FROM lt_supplier.
    IF lt_supplier IS NOT INITIAL.
      SELECT bsik~supplier,
             bpbank~bankcountrykey AS supplierbankcountrykey,
             bpbank~banknumber     AS supplierbanknumber,
             bpbank~bankaccount    AS supplierbankaccount,
             bpbank~iban           AS supplieriban,
             bpbank~swiftcode      AS supplierswiftcode,
             bpbank~bankname       AS supplierbankname,
             bank~bankbranch       AS supplierbankbranch
      FROM @lt_supplier AS bsik
      INNER JOIN i_businesspartnerbank AS bpbank ON bpbank~businesspartner = bsik~supplier
      INNER JOIN i_bank_2 AS bank ON bank~bankcountry = bpbank~bankcountrykey
                                      AND bank~bankinternalid = bpbank~banknumber
      ORDER BY bsik~supplier
      INTO TABLE @DATA(lt_supplier_bank).
      IF sy-subrc = 0.
        LOOP AT ms_response-data ASSIGNING FIELD-SYMBOL(<ls_data>).
          READ TABLE lt_supplier_bank INTO DATA(ls_supplier_bank) WITH KEY supplier = <ls_data>-supplier BINARY SEARCH.
          IF sy-subrc = 0.
            <ls_data>-supplierbankcountrykey = ls_supplier_bank-supplierbankcountrykey.
            <ls_data>-supplierbanknumber     = ls_supplier_bank-supplierbanknumber.
            <ls_data>-supplierbankaccount    = ls_supplier_bank-supplierbankaccount.
            <ls_data>-supplieriban           = ls_supplier_bank-supplieriban.
            <ls_data>-supplierswiftcode      = ls_supplier_bank-supplierswiftcode.
            <ls_data>-supplierbankname       = ls_supplier_bank-supplierbankname.
            <ls_data>-supplierbankbranch     = ls_supplier_bank-supplierbankbranch.
          ENDIF.
        ENDLOOP.
      ENDIF.
    ENDIF.
    DATA(lv_response_body) = /ui2/cl_json=>serialize( EXPORTING data = ms_response ).
    response->set_text( lv_response_body ).
    response->set_header_field( i_name = mc_header_content i_value = mc_content_type ).
  ENDMETHOD.