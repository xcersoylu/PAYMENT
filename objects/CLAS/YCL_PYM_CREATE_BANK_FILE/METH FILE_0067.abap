  METHOD file_0067.
    TYPES: BEGIN OF ty_header,
             baslik_satiri(1),
             gonderim_tarihi(15),
           END OF ty_header.

    TYPES: BEGIN OF ty_detail,
             detay_satir(1),
             islem_tarihi(8),
             firma_cikis_hesap(8),
             doviz_cinsi(3),
             alici_ismi(50),
             alici_iban(26),
             tutar(18),
             aciklama(50),
             referans(16),
             vkn_tckn(11),
             odeme_turu(2),
             islem_kodu(3),
           END OF ty_detail.

    TYPES: BEGIN OF ty_footer,
             son_satir(1),
             adet(5),
           END OF ty_footer.
    DATA: ls_line(1000)        TYPE c,
          ls_header            TYPE ty_header,
          ls_detail            TYPE ty_detail,
          ls_footer            TYPE ty_footer,
          lv_paymentamount(18).
    DATA(lv_system_date) = cl_abap_context_info=>get_system_date(  ).
**********************************************************************
*başlık
    CLEAR: ls_header.
    ls_header-baslik_satiri = |H|.
    ls_header-gonderim_tarihi = |{ lv_system_date+6(2) }{ lv_system_date+4(2) }{ lv_system_date+0(4) }|.

    CLEAR: ls_line.
    REPLACE SECTION OFFSET 0  LENGTH 1  OF ls_line WITH ls_header-baslik_satiri.
    REPLACE SECTION OFFSET 16 LENGTH 15  OF ls_line WITH ls_header-gonderim_tarihi.
    APPEND INITIAL LINE TO rt_bank_file ASSIGNING FIELD-SYMBOL(<ls_bank_file>).
    <ls_bank_file> = ls_line.
**********************************************************************
*kalemler
    LOOP AT mt_bank_file INTO DATA(ls_bank_file).
      lv_paymentamount = ls_bank_file-paymentamount.
      TRANSLATE lv_paymentamount  USING '.,'. SHIFT lv_paymentamount RIGHT DELETING TRAILING space. TRANSLATE lv_paymentamount USING ' 0'.
      CLEAR: ls_detail.
      ls_detail = VALUE #(  detay_satir = |D|
                            islem_tarihi = |{ lv_system_date+6(2) }{ lv_system_date+4(2) }{ lv_system_date+0(4) }|
                            firma_cikis_hesap = COND #( WHEN ls_bank_file-companybankaccount <> space
                                                        THEN ls_bank_file-companybankaccount
                                                        ELSE |{ ls_bank_file-iban+16(10) WIDTH = 11 ALIGN = RIGHT }| )
                            doviz_cinsi = ls_bank_file-transactioncurrency
                            alici_ismi = COND #( WHEN ls_bank_file-suppliername IS INITIAL THEN ls_bank_file-customername ELSE ls_bank_file-suppliername )
                            alici_iban = ls_bank_file-iban
                            tutar = lv_paymentamount
      aciklama =  COND #( WHEN ls_bank_file-accountingdocument IS NOT INITIAL
                                     THEN |{ ls_bank_file-companycode }{ ls_bank_file-accountingdocument }{ ls_bank_file-accountingdocumetitem }{ ls_bank_file-fiscalyear }|
                                     WHEN ls_bank_file-purchaseorder IS NOT INITIAL THEN |{ ls_bank_file-companycode }{ ls_bank_file-purchaseorder }{ ls_bank_file-purchaseorderitem } |
                                              ELSE |{ ls_bank_file-companycode }{ ls_bank_file-paymentnumber }{ ls_bank_file-paymentamount }{ ls_bank_file-purchaseorderitem } | )
      referans = ls_bank_file-documentreferenceid
      vkn_tckn = COND #( WHEN ls_bank_file-bptaxnumber <> space THEN ls_bank_file-bptaxnumber ELSE ls_bank_file-tckn )
      odeme_turu = |99|
      islem_kodu = |000|
      ).


      CLEAR: ls_line.
      REPLACE SECTION OFFSET 0   LENGTH 1   OF ls_line WITH ls_detail-detay_satir.
      REPLACE SECTION OFFSET 1   LENGTH 8   OF ls_line WITH ls_detail-islem_tarihi.
      REPLACE SECTION OFFSET 9   LENGTH 8   OF ls_line WITH ls_detail-firma_cikis_hesap.
      REPLACE SECTION OFFSET 17  LENGTH 3   OF ls_line WITH ls_detail-doviz_cinsi.
      REPLACE SECTION OFFSET 20  LENGTH 50  OF ls_line WITH ls_detail-alici_ismi.
      REPLACE SECTION OFFSET 70  LENGTH 26  OF ls_line WITH ls_detail-alici_iban.
      REPLACE SECTION OFFSET 96  LENGTH 18  OF ls_line WITH ls_detail-tutar.
      REPLACE SECTION OFFSET 114 LENGTH 50  OF ls_line WITH ls_detail-aciklama.
      REPLACE SECTION OFFSET 164 LENGTH 16  OF ls_line WITH ls_detail-referans.
      REPLACE SECTION OFFSET 180 LENGTH 11  OF ls_line WITH ls_detail-vkn_tckn.
      REPLACE SECTION OFFSET 191 LENGTH 2   OF ls_line WITH ls_detail-odeme_turu.
      REPLACE SECTION OFFSET 193 LENGTH 3   OF ls_line WITH ls_detail-islem_kodu.
      APPEND INITIAL LINE TO rt_bank_file ASSIGNING <ls_bank_file>.
      <ls_bank_file> = ls_line.
    ENDLOOP.
**********************************************************************
*footer
    CLEAR: ls_footer.
    ls_footer-son_satir = |T|.
    ls_footer-adet = CONV numc5( |{ |{ lines( mt_bank_file ) }| ALPHA = IN }| ).
    CLEAR: ls_line.
    REPLACE SECTION OFFSET 0 LENGTH 1 OF ls_line WITH ls_footer-son_satir.
    REPLACE SECTION OFFSET 1 LENGTH 5 OF ls_line WITH ls_footer-adet.
    APPEND INITIAL LINE TO rt_bank_file ASSIGNING <ls_bank_file>.
    <ls_bank_file> = ls_line.

  ENDMETHOD.