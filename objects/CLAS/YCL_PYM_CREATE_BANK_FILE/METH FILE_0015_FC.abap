  METHOD file_0015_fc.
    TYPES: BEGIN OF ty_header,
             kayit_tipi(1),
             musteri_no(12),
             dosya_tarihi(8),
           END OF ty_header.

    TYPES: BEGIN OF ty_detail,
             kayit_tipi(1),
             tutar(15),
             referans(16),
             odeme_tarihi(8),
             islem_tarihi(8),
             valor(1),
             borclu_sube(6),
             borclu_hesap(20),
             ab_swift(11),
             ab_adi(70),
             ab_adres(105),
             alacakli_hesap(34),
             alacakli_isim(70),
             alacakli_adres(70),
             doviz_cinsi(3),
             islem_kodu(2),
             masraf(3),
             iban_kodu(34),
             gumruk_tarih(500),
             gumruk_no(500),
           END OF ty_detail.

    TYPES: BEGIN OF ty_footer,
             kayit_tipi(1),
             adet_toplam(5),
           END OF ty_footer.

    DATA: ls_line(1000)        TYPE c,
          ls_header            TYPE ty_header,
          ls_detail            TYPE ty_detail,
          ls_footer            TYPE ty_footer,
          lv_space_length      TYPE i,
          lv_paymentamount(18).
    DATA(lv_system_date) = cl_abap_context_info=>get_system_date(  ).
    DATA(lv_space) = get_space_character(  ).
    ls_header = VALUE #( kayit_tipi = |H|
                         dosya_tarihi = |{ lv_system_date+6(2) }{ lv_system_date+4(2) }{ lv_system_date+0(4) }|
                         musteri_no   = ms_urfcode-mbb ).

    CLEAR: ls_line.
    REPLACE SECTION OFFSET 0  LENGTH 1   OF ls_line WITH ls_header-kayit_tipi."*-&Kayıt Tipi
    REPLACE SECTION OFFSET 1  LENGTH 12  OF ls_line WITH ls_header-musteri_no."*-&Müşteri No
    REPLACE SECTION OFFSET 13 LENGTH 8   OF ls_line WITH ls_header-dosya_tarihi ."*-&Dosya Tarihi
    APPEND INITIAL LINE TO rt_bank_file ASSIGNING FIELD-SYMBOL(<ls_bank_file>).
    <ls_bank_file> = ls_line.
    "TODO : tamamlanacak
    LOOP AT mt_bank_file INTO DATA(ls_bank_file).
      CLEAR: ls_detail.
      lv_paymentamount = ls_bank_file-paymentamount.
      TRANSLATE lv_paymentamount  USING '.,'. SHIFT lv_paymentamount RIGHT DELETING TRAILING space. TRANSLATE lv_paymentamount USING ' 0'.
      ls_detail-kayit_tipi      = |D|.
      ls_detail-tutar           = lv_paymentamount.
      ls_detail-odeme_tarihi    = |{ lv_system_date+6(2) }{ lv_system_date+4(2) }{ lv_system_date+0(4) }|.
      ls_detail-islem_tarihi    = |{ lv_system_date+6(2) }{ lv_system_date+4(2) }{ lv_system_date+0(4) }|.
      ls_detail-referans        = ls_bank_file-documentreferenceid.
      ls_detail-valor           = |0|.
      ls_detail-borclu_sube     = CONV char6( |{ ls_bank_file-companybankinternalid+5(5) ALPHA = IN }| ) .
      ls_detail-borclu_hesap    = COND #( WHEN ls_bank_file-companyiban IS NOT INITIAL THEN ls_bank_file-companyiban ELSE ls_bank_file-companybankaccount ).
      ls_detail-ab_swift        = ls_bank_file-companybankcode.
      ls_detail-ab_adi          = COND #( WHEN ls_bank_file-companyswiftcode IS INITIAL THEN ls_bank_file-companybankcode ELSE space ).
*      ls_detail-ab_adres        = ls_bank_file-bank_stras.
*      ls_detail-alacakli_hesap  = ls_bank_file-bankl_pay.
      ls_detail-alacakli_isim   = COND #( WHEN ls_bank_file-suppliername IS INITIAL THEN ls_bank_file-customername ELSE ls_bank_file-suppliername ).
*      ls_detail-alacakli_adres  = ls_bank_file-stras.
      ls_detail-doviz_cinsi     = ls_bank_file-transactioncurrency.
      ls_detail-islem_kodu      = |40|.
      ls_detail-masraf          = |OUR|.
      ls_detail-iban_kodu       = ls_bank_file-iban.

      CLEAR: ls_line.
      REPLACE SECTION OFFSET 0   LENGTH 1   OF ls_line WITH ls_detail-kayit_tipi."*-&Kayıt Tipi
      REPLACE SECTION OFFSET 1   LENGTH 15  OF ls_line WITH ls_detail-tutar."-&tutar
      REPLACE SECTION OFFSET 16  LENGTH 16  OF ls_line WITH ls_detail-referans."-&referans
      REPLACE SECTION OFFSET 32  LENGTH 8   OF ls_line WITH ls_detail-odeme_tarihi."-&odeme_tarihi
      REPLACE SECTION OFFSET 40  LENGTH 8   OF ls_line WITH ls_detail-islem_tarihi."-&islem_tarihi
      REPLACE SECTION OFFSET 48  LENGTH 1   OF ls_line WITH ls_detail-valor."-&valor
      REPLACE SECTION OFFSET 49  LENGTH 6   OF ls_line WITH ls_detail-borclu_sube."-&borclu_sube
      REPLACE SECTION OFFSET 55  LENGTH 20  OF ls_line WITH ls_detail-borclu_hesap."-&borclu_hesap
      REPLACE SECTION OFFSET 75  LENGTH 11  OF ls_line WITH ls_detail-ab_swift."-&ab_swift
      REPLACE SECTION OFFSET 86  LENGTH 70  OF ls_line WITH ls_detail-ab_adi."-&ab_adi
      REPLACE SECTION OFFSET 156 LENGTH 105 OF ls_line WITH ls_detail-ab_adres."-&ab_adres
      REPLACE SECTION OFFSET 261 LENGTH 34  OF ls_line WITH ls_detail-alacakli_hesap."-&alacakli_hesap
      REPLACE SECTION OFFSET 295 LENGTH 70  OF ls_line WITH ls_detail-alacakli_isim."-&alacakli_isim
      REPLACE SECTION OFFSET 365 LENGTH 70  OF ls_line WITH ls_detail-alacakli_adres."-&alacakli_adres
      REPLACE SECTION OFFSET 435 LENGTH 3   OF ls_line WITH ls_detail-doviz_cinsi."-&doviz_cinsi
      REPLACE SECTION OFFSET 438 LENGTH 2   OF ls_line WITH ls_detail-islem_kodu."-&islem_kodu
      REPLACE SECTION OFFSET 440 LENGTH 3   OF ls_line WITH ls_detail-masraf."-&masraf
      REPLACE SECTION OFFSET 443 LENGTH 34  OF ls_line WITH ls_detail-iban_kodu."-&iban_kodu

      lv_space_length = 519 - strlen( ls_line ).

      DO lv_space_length TIMES.
        CONCATENATE ls_line lv_space INTO ls_line.
      ENDDO.

      APPEND INITIAL LINE TO rt_bank_file ASSIGNING <ls_bank_file>.
      <ls_bank_file> = ls_line.
    ENDLOOP.

    ls_footer-kayit_tipi = |T|.
    ls_footer-adet_toplam = CONV char5( |{ |{ lines( mt_bank_file ) }| ALPHA = IN }| ).
    CLEAR: ls_line.
    REPLACE SECTION OFFSET 0  LENGTH 1  OF ls_line WITH ls_footer-kayit_tipi."*-&Kayıt Tipi
    REPLACE SECTION OFFSET 1  LENGTH 5  OF ls_line WITH ls_footer-adet_toplam."*-&Toplam İslem Adedi
    APPEND INITIAL LINE TO rt_bank_file ASSIGNING <ls_bank_file>.
    <ls_bank_file> = ls_line.

  ENDMETHOD.