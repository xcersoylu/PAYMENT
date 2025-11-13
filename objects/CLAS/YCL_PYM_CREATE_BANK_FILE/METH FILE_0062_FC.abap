  METHOD file_0062_fc.
    TYPES: BEGIN OF ty_header,
             kayit_tipi(1),
             firma_kodu(6),
             dosya_tarihi(8),
           END OF ty_header.

    TYPES: BEGIN OF ty_detail,
             banka_bic(11),
             tutar(16),
             referans(16),
             talimat_tarihi(8),
             islem_tarihi(8),
             valor(8),
             borclu_hesap(12),
             alici_banka_bic(11),
             alici_banka_adi(35),
             alici_sube(35),
             alici_adres(70),
             lehdar_iban(34),
             lehdar_isim(35),
             doviz_kodu(3),
             aciklama(40),
             islem_turu(1),
             islem_detay(2),
             masraf_yeri(3),
             islem_kodu(2),
             iban_kodu(34),
             masraf_hesap(12),
           END OF ty_detail.

    TYPES: BEGIN OF ty_footer,
             kayit_tipi(1),
             tpl_kayıt(7),
           END OF ty_footer.

    DATA: ls_line(2000)        TYPE c,
          ls_header            TYPE ty_header,
          ls_detail            TYPE ty_detail,
          ls_footer            TYPE ty_footer,
          lv_paymentamount(18).
    DATA(lv_system_date) = cl_abap_context_info=>get_system_date(  ).
    CLEAR: ls_header.
    ls_header-kayit_tipi = |H|.
    ls_header-firma_kodu = ms_urfcode-firm_code.
    ls_header-dosya_tarihi = sy-datum.

    REPLACE SECTION OFFSET 0  LENGTH 1  OF ls_line WITH ls_header-kayit_tipi.  "*-&Kayıt Tipi
    REPLACE SECTION OFFSET 1  LENGTH 6  OF ls_line WITH ls_header-firma_kodu.  "*-&Ürün Referans Kodu
    REPLACE SECTION OFFSET 7  LENGTH 8  OF ls_line WITH ls_header-dosya_tarihi."*-&Dosya Tarihi
    APPEND INITIAL LINE TO rt_bank_file ASSIGNING FIELD-SYMBOL(<ls_bank_file>).
    <ls_bank_file> = ls_line.

*--------------------------------------------------------------------*
*-&STEP -2: Detay Verilerinin Doldurulması->
*--------------------------------------------------------------------*
    "TODO : stras
    LOOP AT mt_bank_file INTO DATA(ls_bank_file).
      lv_paymentamount = ls_bank_file-paymentamount.
      TRANSLATE lv_paymentamount  USING '.,'. SHIFT lv_paymentamount RIGHT DELETING TRAILING space. TRANSLATE lv_paymentamount USING ' 0'.
      CLEAR: ls_detail.
      ls_detail-banka_bic       = ls_bank_file-companyswiftcode.
      ls_detail-tutar           = lv_paymentamount.
      IF ls_bank_file-documentreferenceid IS NOT INITIAL.
        ls_detail-referans        = ls_bank_file-documentreferenceid.
      ELSE.
        ls_detail-referans        = ls_bank_file-paymentnumber.
      ENDIF.
      ls_detail-talimat_tarihi  = lv_system_date.
      ls_detail-islem_tarihi    = lv_system_date.
      ls_detail-valor           = lv_system_date.
      ls_detail-borclu_hesap    = ls_bank_file-companybankaccount.
      ls_detail-alici_banka_bic = ls_bank_file-swiftcode.
      ls_detail-alici_banka_adi = ls_bank_file-bankname.
      ls_detail-alici_sube      = ls_bank_file-bankbranch.
*      ls_detail-alici_adres     = ls_bank_file-bank_stras.
      ls_detail-lehdar_iban     = ls_bank_file-iban.
      ls_detail-lehdar_isim     = COND #( WHEN ls_bank_file-suppliername IS INITIAL THEN ls_bank_file-customername ELSE ls_bank_file-suppliername ).
      ls_detail-doviz_kodu      = ls_bank_file-transactioncurrency.
      ls_detail-aciklama        = COND #( WHEN ls_bank_file-accountingdocument IS NOT INITIAL
                                THEN |{ ls_bank_file-companycode }{ ls_bank_file-accountingdocument }{ ls_bank_file-accountingdocumetitem }{ ls_bank_file-fiscalyear }|
                                WHEN ls_bank_file-purchaseorder IS NOT INITIAL THEN |{ ls_bank_file-companycode }{ ls_bank_file-purchaseorder }{ ls_bank_file-purchaseorderitem } |
                                         ELSE |{ ls_bank_file-companycode }{ ls_bank_file-paymentnumber }{ ls_bank_file-paymentamount }{ ls_bank_file-purchaseorderitem } | ).
      ls_detail-islem_turu      = |D|.
      ls_detail-islem_detay     = |60|.
      ls_detail-masraf_yeri     = |OUR|.
      ls_detail-islem_kodu      = |00|.
      ls_detail-iban_kodu       = ls_bank_file-iban.
      ls_detail-masraf_hesap    = ls_bank_file-companybankaccount.

      CLEAR: ls_line.
      REPLACE SECTION OFFSET 0    LENGTH 11  OF ls_line WITH ls_detail-banka_bic.
      REPLACE SECTION OFFSET 11   LENGTH 16  OF ls_line WITH ls_detail-tutar.
      REPLACE SECTION OFFSET 27   LENGTH 16  OF ls_line WITH ls_detail-referans.
      REPLACE SECTION OFFSET 59   LENGTH 8   OF ls_line WITH ls_detail-talimat_tarihi.
      REPLACE SECTION OFFSET 67   LENGTH 8   OF ls_line WITH ls_detail-islem_tarihi.
      REPLACE SECTION OFFSET 75   LENGTH 8   OF ls_line WITH ls_detail-valor.
      REPLACE SECTION OFFSET 83   LENGTH 12  OF ls_line WITH ls_detail-borclu_hesap.
      REPLACE SECTION OFFSET 83   LENGTH 11  OF ls_line WITH ls_detail-alici_banka_bic.
      REPLACE SECTION OFFSET 94   LENGTH 35  OF ls_line WITH ls_detail-alici_banka_adi.
      REPLACE SECTION OFFSET 129  LENGTH 35  OF ls_line WITH ls_detail-alici_sube.
      REPLACE SECTION OFFSET 164  LENGTH 70  OF ls_line WITH ls_detail-alici_adres.
      REPLACE SECTION OFFSET 234  LENGTH 34  OF ls_line WITH ls_detail-lehdar_iban.
      REPLACE SECTION OFFSET 268  LENGTH 35  OF ls_line WITH ls_detail-lehdar_isim.
      REPLACE SECTION OFFSET 408  LENGTH 3   OF ls_line WITH ls_detail-doviz_kodu.
      REPLACE SECTION OFFSET 411  LENGTH 40  OF ls_line WITH ls_detail-aciklama.
      REPLACE SECTION OFFSET 661  LENGTH 1   OF ls_line WITH ls_detail-islem_turu.
      REPLACE SECTION OFFSET 662  LENGTH 2   OF ls_line WITH ls_detail-islem_detay.
      REPLACE SECTION OFFSET 664  LENGTH 3   OF ls_line WITH ls_detail-masraf_yeri.
      REPLACE SECTION OFFSET 667  LENGTH 2   OF ls_line WITH ls_detail-islem_kodu.
      REPLACE SECTION OFFSET 669  LENGTH 34  OF ls_line WITH ls_detail-iban_kodu.
      REPLACE SECTION OFFSET 1101 LENGTH 12  OF ls_line WITH ls_detail-masraf_hesap.

      APPEND INITIAL LINE TO rt_bank_file ASSIGNING <ls_bank_file>.
      <ls_bank_file> = ls_line.
    ENDLOOP.

*--------------------------------------------------------------------*
*-&STEP -3: Sayfa Sonu Verilerinin Doldurulması->
*--------------------------------------------------------------------*
    CLEAR: ls_footer.
    ls_footer-kayit_tipi = |T|.
    ls_footer-tpl_kayit = CONV char7( |{ |{ lines( mt_bank_file ) }| ALPHA = IN }| ).

    CLEAR: ls_line.
    REPLACE SECTION OFFSET 0 LENGTH 1 OF ls_line WITH ls_footer-kayit_tipi."*-&Kayıt Tipi
    REPLACE SECTION OFFSET 1 LENGTH 7 OF ls_line WITH ls_footer-tpl_kayit."*-&Toplam Kayıt Sayısı
    APPEND INITIAL LINE TO rt_bank_file ASSIGNING <ls_bank_file>.
    <ls_bank_file> = ls_line.

  ENDMETHOD.