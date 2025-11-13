  METHOD file_0067_fc.
    TYPES: BEGIN OF ty_header,
             kayit_tipi(1),
             mbbno(8),
             dosya_tarihi(8),
           END OF ty_header.

    TYPES: BEGIN OF ty_detail,
             kayit_tipi(1),
             islem_turu(1),
             firma_referansi(16),
             islem_tarihi(8),
             borclu_hesap(8),
             tutar(15),
             doviz_kodu(3),
             valor(1),
             alacakli_swift(11),
             alacakli_banka_adi(35),
             alacakli_banka_adres(105),
             lehdar_hesap(34),
             alici_isim(70),
             dekont_aciklama(40),
             y_masraf_yeri(3),
             islem_kodu(2),
           END OF ty_detail.

    TYPES: BEGIN OF ty_footer,
             kayit_tipi(1),
             kayit_sayisi(7),
           END OF ty_footer.

    DATA: ls_line(3000)        TYPE c,
          ls_header            TYPE ty_header,
          ls_detail            TYPE ty_detail,
          ls_footer            TYPE ty_footer,
          lv_paymentamount(18).
    DATA(lv_system_date) = cl_abap_context_info=>get_system_date( ).
    ls_header-kayit_tipi = |H|.
    ls_header-mbbno = ms_urfcode-mbb.
    ls_header-dosya_tarihi = |{ lv_system_date+6(2) }{ lv_system_date+4(2) }{ lv_system_date(4) }|.

    CLEAR: ls_line.
    REPLACE SECTION OFFSET 0  LENGTH 1  OF ls_line WITH ls_header-kayit_tipi.
    REPLACE SECTION OFFSET 1  LENGTH 8  OF ls_line WITH ls_header-mbbno.
    REPLACE SECTION OFFSET 9  LENGTH 8  OF ls_line WITH ls_header-dosya_tarihi.
    REPLACE SECTION OFFSET 17 LENGTH 6  OF ls_line WITH space.
    APPEND INITIAL LINE TO rt_bank_file ASSIGNING FIELD-SYMBOL(<ls_bank_file>).
    <ls_bank_file> = ls_line.

*--------------------------------------------------------------------*
*-&STEP -2: Detay Verilerinin Doldurulması->
*--------------------------------------------------------------------*
    "TODO stras
    LOOP AT mt_bank_file INTO DATA(ls_bank_file).
      lv_paymentamount = ls_bank_file-paymentamount.
      TRANSLATE lv_paymentamount  USING '.,'. SHIFT lv_paymentamount RIGHT DELETING TRAILING space. TRANSLATE lv_paymentamount USING ' 0'.
      CLEAR: ls_detail.
      ls_detail-kayit_tipi = |D|.
      ls_detail-islem_turu = |D|.
      ls_detail-firma_referansi = ls_bank_file-documentreferenceid.
      ls_detail-islem_tarihi = |{ lv_system_date+6(2) }{ lv_system_date+4(2) }{ lv_system_date+0(4) }|.
      ls_detail-borclu_hesap = COND #( WHEN ls_bank_file-companyaccountcode <> space THEN ls_bank_file-companyaccountcode ELSE |{ ls_bank_file-companyiban+18(8) WIDTH = 8 ALIGN = RIGHT }| ).
      ls_detail-tutar = lv_paymentamount.
      ls_detail-doviz_kodu = ls_bank_file-transactioncurrency.
      ls_detail-valor = |0|.
      ls_detail-alacakli_swift = |{ ls_bank_file-swiftcode }|.
      ls_detail-alacakli_banka_adi = COND #( WHEN ls_detail-alacakli_swift IS INITIAL THEN ls_bank_file-bankname ELSE space ).
*      ls_detail-alacakli_banka_adres = COND #( WHEN ls_detail-alacakli_swift IS INITIAL THEN ls_bank_file-bank_stras ELSE space ).
      ls_detail-lehdar_hesap = COND #( WHEN ls_bank_file-bankaccount <> space THEN ls_bank_file-bankaccount ELSE |{ ls_bank_file-iban+16(10) WIDTH = 34 ALIGN = RIGHT }| ).
      ls_detail-alici_isim = COND #( WHEN ls_bank_file-suppliername IS INITIAL THEN ls_bank_file-customername ELSE ls_bank_file-suppliername ).
      ls_detail-dekont_aciklama = COND #( WHEN ls_bank_file-accountingdocument IS NOT INITIAL
                                THEN |{ ls_bank_file-companycode }{ ls_bank_file-accountingdocument }{ ls_bank_file-accountingdocumetitem }{ ls_bank_file-fiscalyear }|
                                WHEN ls_bank_file-purchaseorder IS NOT INITIAL THEN |{ ls_bank_file-companycode }{ ls_bank_file-purchaseorder }{ ls_bank_file-purchaseorderitem } |
                                         ELSE |{ ls_bank_file-companycode }{ ls_bank_file-paymentnumber }{ ls_bank_file-paymentamount }{ ls_bank_file-purchaseorderitem } | ).
      ls_detail-y_masraf_yeri = |OUR|.
      ls_detail-islem_kodu = |00|.

      CLEAR: ls_line.
      REPLACE SECTION OFFSET 0    LENGTH 1    OF ls_line WITH ls_detail-kayit_tipi.
      REPLACE SECTION OFFSET 1    LENGTH 1    OF ls_line WITH ls_detail-islem_turu.
      REPLACE SECTION OFFSET 2    LENGTH 16   OF ls_line WITH ls_detail-firma_referansi.
      REPLACE SECTION OFFSET 30   LENGTH 8    OF ls_line WITH ls_detail-islem_tarihi.
      REPLACE SECTION OFFSET 38   LENGTH 8    OF ls_line WITH ls_detail-borclu_hesap.
      REPLACE SECTION OFFSET 46   LENGTH 15   OF ls_line WITH ls_detail-tutar.
      REPLACE SECTION OFFSET 61   LENGTH 3    OF ls_line WITH ls_detail-doviz_kodu.
      REPLACE SECTION OFFSET 64   LENGTH 1    OF ls_line WITH ls_detail-valor.
      REPLACE SECTION OFFSET 76   LENGTH 1    OF ls_line WITH ls_detail-alacakli_swift.
      REPLACE SECTION OFFSET 77   LENGTH 35   OF ls_line WITH ls_detail-alacakli_banka_adi.
      REPLACE SECTION OFFSET 112  LENGTH 105  OF ls_line WITH ls_detail-alacakli_banka_adres.
      REPLACE SECTION OFFSET 217  LENGTH 34   OF ls_line WITH ls_detail-lehdar_hesap.
      REPLACE SECTION OFFSET 252  LENGTH 70   OF ls_line WITH ls_detail-alici_isim.
      REPLACE SECTION OFFSET 392  LENGTH 40   OF ls_line WITH ls_detail-dekont_aciklama.
      REPLACE SECTION OFFSET 552  LENGTH 3    OF ls_line WITH ls_detail-y_masraf_yeri.
      REPLACE SECTION OFFSET 788  LENGTH 2    OF ls_line WITH ls_detail-islem_kodu.
      REPLACE SECTION OFFSET 789  LENGTH 1479 OF ls_line WITH space.

      APPEND INITIAL LINE TO rt_bank_file ASSIGNING <ls_bank_file>.
      <ls_bank_file> = ls_line.
    ENDLOOP.

*--------------------------------------------------------------------*
*-&STEP -3: Sayfa Sonu Verilerinin Doldurulması->
*--------------------------------------------------------------------*
    CLEAR: ls_footer.
    ls_footer-kayit_tipi = |T|.
    ls_footer-kayit_sayisi = CONV numc5( |{ |{ lines( mt_bank_file ) }| ALPHA = IN }| ).


    CLEAR: ls_line.
    REPLACE SECTION OFFSET 0 LENGTH 1 OF ls_line WITH ls_footer-kayit_tipi.
    REPLACE SECTION OFFSET 1 LENGTH 7 OF ls_line WITH ls_footer-kayit_sayisi.

    APPEND INITIAL LINE TO rt_bank_file ASSIGNING <ls_bank_file>.
    <ls_bank_file> = ls_line.

  ENDMETHOD.