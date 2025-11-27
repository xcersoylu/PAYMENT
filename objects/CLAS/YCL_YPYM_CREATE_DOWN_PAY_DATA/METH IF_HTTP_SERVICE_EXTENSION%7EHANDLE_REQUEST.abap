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
    SELECT ekko~companycode,
            ekko~supplier,
            supplier~suppliername,
            ekko~purchaseorder,
            ekpo~purchaseorderitem,
            ekko~purchasingorganization,
            ekko~purchasinggroup,
            ekpo~plant,
            ekpo~storagelocation,
            purchaseorderdate,
            ekko~creationdate,
            ekko~createdbyuser,
            ekko~paymentterms,
            ekko~exchangerate,
            ekpo~purchaseorderitemtext,
            ekpo~material,
            ekpo~materialgroup,
            ekpo~purchaseorderquantityunit,
            ekpo~orderquantity,
            ekpo~netpriceamount,
            ekpo~netamount,
            ekpo~grossamount,
            ekpo~netpricequantity,
            ekpo~partnerreportedbusinessarea,
            ekpo~taxcode,
            ekpo~netpriceamount AS paymentamount,
            ekko~documentcurrency
    FROM i_purchaseorderapi01 AS ekko INNER JOIN i_purchaseorderitemapi01 AS ekpo ON ekpo~purchaseorder = ekko~purchaseorder
    INNER JOIN i_supplier AS supplier ON supplier~supplier = ekko~supplier
    WHERE ekko~companycode = @ms_request-companycode
      AND ekko~purchasingorganization IN @ms_request-purchasingorganization
      AND ekko~purchasinggroup IN @ms_request-purchasinggroup
      AND ekko~purchaseorder IN @ms_request-purchaseorder
      AND ekko~supplier IN @ms_request-supplier
      AND ekko~purchaseorderdate IN @ms_request-purchaseorderdate
      AND ekko~documentcurrency IN @ms_request-currency
      AND NOT EXISTS ( SELECT * FROM ypym_t_downpay WHERE purchaseorder = ekpo~purchaseorder
                                                      AND purchaseorderitem = ekpo~purchaseorderitem
                                                      AND approvementstatus NE 'REJECTED' )
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
             bank~bankbranch       AS supplierbankbrunch
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
            <ls_data>-supplierbankbrunch     = ls_supplier_bank-supplierbankbrunch.
          ENDIF.
        ENDLOOP.
      ENDIF.
    ENDIF.

    DATA(lv_response_body) = /ui2/cl_json=>serialize( EXPORTING data = ms_response ).
    response->set_text( lv_response_body ).
    response->set_header_field( i_name = mc_header_content i_value = mc_content_type ).

  ENDMETHOD.