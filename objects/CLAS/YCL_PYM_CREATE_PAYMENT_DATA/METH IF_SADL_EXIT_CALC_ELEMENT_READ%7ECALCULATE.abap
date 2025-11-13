  METHOD if_sadl_exit_calc_element_read~calculate.
    DATA lt_data TYPE STANDARD TABLE OF yi_pym_ddl_create_payment_list.
    lt_data = CORRESPONDING #( it_original_data ).
    CHECK lt_data IS NOT INITIAL.
    DATA(lt_supplier) = lt_data.
    SORT lt_supplier BY supplier.
    DELETE ADJACENT DUPLICATES FROM lt_supplier.
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


    SELECT bsik~accountingdocument,
           bsik~fiscalyear,
           bsik~accountingdocumentitem,
           payment~paymentnumber
    FROM @lt_data AS bsik
     INNER JOIN ypym_t_payment  AS payment ON payment~accountingdocument     = bsik~accountingdocument
                                              AND payment~fiscalyear             = bsik~fiscalyear
                                              AND payment~accountingdocumentitem = bsik~accountingdocumentitem
    ORDER BY bsik~accountingdocument,
               bsik~fiscalyear,
           bsik~accountingdocumentitem
    INTO TABLE @DATA(lt_payment).

    LOOP AT lt_data ASSIGNING FIELD-SYMBOL(<ls_data>).
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
      READ TABLE lt_payment INTO DATA(ls_payment) WITH KEY accountingdocument = <ls_data>-accountingdocument
                                                           fiscalyear = <ls_data>-fiscalyear
                                                           accountingdocumentitem = <ls_data>-accountingdocumentitem.
      IF sy-subrc = 0.
        <ls_data>-paymentnumber = ls_payment-paymentnumber.
      ENDIF.
    ENDLOOP.

    ct_calculated_data = CORRESPONDING #( lt_data ).
  ENDMETHOD.