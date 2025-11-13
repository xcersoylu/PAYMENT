  METHOD file_0032.
    TYPES: BEGIN OF ty_header,
             kayit_tipi(2),
             dosya_tarihi(8),
             banka(4),
             kurum_kodu(5),
             customer_code(8),
             account_numb(16),
             payment_date(8),
             payment_time(4),
             detail(16),
           END OF ty_header.

    TYPES: BEGIN OF ty_detail,
             kayit_tipi(1),
             alacakli_banka(4),
             alacakli_sube(5),
             alacakli_hesap(19),
             currency(3),
             tutar(20),
             aciklama(60),
             referans(20),
             unvan(50),
             adres(50),
             telefon(10),
             vergi_kimlik_no(10),
             vergi_dairesi(30),
             mail(150),
             iban(26),
             tck_no(16),
           END OF ty_detail.

    TYPES: BEGIN OF ty_footer,
             kayit_tipi(1),
             adet_toplam(12),
             tutar_toplam(20),
           END OF ty_footer.
    DATA: ls_line(1000)        TYPE c,
          ls_header            TYPE ty_header,
          ls_detail            TYPE ty_detail,
          ls_footer            TYPE ty_footer,
          lv_paymentamount(18) TYPE c.
    DATA(lv_system_date) = cl_abap_context_info=>get_system_date(  ).
    DATA(lv_system_time) = cl_abap_context_info=>get_system_time(  ).
**********************************************************************
*başlık
    ls_header = VALUE #( kayit_tipi    = |H6|
                         dosya_tarihi  = lv_system_date
                         banka         = |0032|
                         kurum_kodu    = VALUE #( mt_bank_file[ 1 ]-banknumber+5(5) )
                         customer_code = ms_urfcode-firm_code
                         account_numb  = VALUE #( mt_bank_file[ 1 ]-companybankaccount OPTIONAL ) "VALUE #( mv_design-_paydat[ 1 ]-bankn OPTIONAL ).
                         payment_date  = lv_system_date
                         payment_time  = lv_system_time
                         detail        = |0000000000000000| ).
    ls_header-kurum_kodu = |{ ls_header-kurum_kodu ALPHA = IN }|.
    ls_header-customer_code = |{ ls_header-customer_code ALPHA = IN }|.
    ls_header-account_numb = |{ ls_header-account_numb ALPHA = IN }|.

    CLEAR: ls_line.
    REPLACE SECTION OFFSET 0  LENGTH 2  OF ls_line WITH ls_header-kayit_tipi."*-&Kayıt Tipi
    REPLACE SECTION OFFSET 2  LENGTH 8  OF ls_line WITH ls_header-dosya_tarihi."*-&Dosya Hazırlanma Tarihi
    REPLACE SECTION OFFSET 10 LENGTH 4  OF ls_line WITH ls_header-banka."*-&Banka EFT Kodu
    REPLACE SECTION OFFSET 14 LENGTH 5  OF ls_line WITH ls_header-kurum_kodu."*-&Kurumun Bankadaki Kodu
    REPLACE SECTION OFFSET 19 LENGTH 8  OF ls_line WITH ls_header-customer_code."*-&customer_code
    REPLACE SECTION OFFSET 27 LENGTH 16 OF ls_line WITH ls_header-account_numb."*-&account_numb
    REPLACE SECTION OFFSET 43 LENGTH 8  OF ls_line WITH ls_header-payment_date."*-&payment_date
    REPLACE SECTION OFFSET 51 LENGTH 4  OF ls_line WITH ls_header-payment_time."*-&payment_time
    REPLACE SECTION OFFSET 55 LENGTH 16  OF ls_line WITH ls_header-detail."*-&detail
    APPEND INITIAL LINE TO rt_bank_file ASSIGNING FIELD-SYMBOL(<ls_bank_file>).
    <ls_bank_file> = ls_line.

    LOOP AT mt_bank_file INTO DATA(ls_bank_file).

      CLEAR: ls_detail.
      ls_detail-kayit_tipi     = |D|.
      ls_detail-alacakli_banka = COND #( WHEN ls_bank_file-iban IS NOT INITIAL THEN '0000'  ELSE ls_bank_file-banknumber(4) ).
      ls_detail-alacakli_sube  = COND #( WHEN ls_bank_file-iban IS NOT INITIAL THEN '00000' ELSE ls_bank_file-banknumber+5(5) ).
      ls_detail-alacakli_hesap = COND #( WHEN ls_bank_file-iban IS NOT INITIAL THEN space   ELSE ls_bank_file-bankaccount ).
      ls_detail-currency       = ls_bank_file-transactioncurrency.
      ls_detail-tutar          = ls_bank_file-paymentamount.
      SHIFT ls_detail-tutar RIGHT DELETING TRAILING space.
      TRANSLATE ls_detail-tutar USING ' 0'.
      ls_detail-aciklama = COND #( WHEN ls_bank_file-accountingdocument IS NOT INITIAL
                                THEN |{ ls_bank_file-companycode }{ ls_bank_file-accountingdocument }{ ls_bank_file-accountingdocumetitem }{ ls_bank_file-fiscalyear }|
                                WHEN ls_bank_file-purchaseorder IS NOT INITIAL THEN |{ ls_bank_file-companycode }{ ls_bank_file-purchaseorder }{ ls_bank_file-purchaseorderitem } |
                                         ELSE |{ ls_bank_file-companycode }{ ls_bank_file-paymentnumber }{ ls_bank_file-paymentamount }{ ls_bank_file-purchaseorderitem } | ).
      ls_detail-referans       = ls_bank_file-documentreferenceid.
      ls_detail-unvan          = COND #( WHEN ls_bank_file-suppliername IS INITIAL THEN ls_bank_file-customername ELSE ls_bank_file-suppliername ).
      ls_detail-adres          = space.
      ls_detail-telefon         = space.
      ls_detail-vergi_kimlik_no = space.
      ls_detail-vergi_dairesi   = space.
      ls_detail-mail            = space.
      ls_detail-iban            = ls_bank_file-iban.
      ls_detail-tck_no          = space.


      CLEAR: ls_line.
      REPLACE SECTION OFFSET 0   LENGTH 1   OF ls_line WITH ls_detail-kayit_tipi."*-&Kayıt Tipi
      REPLACE SECTION OFFSET 1   LENGTH 4   OF ls_line WITH ls_detail-alacakli_banka.
      REPLACE SECTION OFFSET 5   LENGTH 5   OF ls_line WITH ls_detail-alacakli_sube.
      REPLACE SECTION OFFSET 10  LENGTH 19  OF ls_line WITH ls_detail-alacakli_hesap.
      REPLACE SECTION OFFSET 29  LENGTH 3   OF ls_line WITH ls_detail-currency.
      REPLACE SECTION OFFSET 32  LENGTH 20  OF ls_line WITH ls_detail-tutar.
      REPLACE SECTION OFFSET 52  LENGTH 60  OF ls_line WITH ls_detail-aciklama.
      REPLACE SECTION OFFSET 112 LENGTH 20  OF ls_line WITH ls_detail-referans.
      REPLACE SECTION OFFSET 132 LENGTH 50  OF ls_line WITH ls_detail-unvan.
      REPLACE SECTION OFFSET 182 LENGTH 50  OF ls_line WITH ls_detail-adres.
      REPLACE SECTION OFFSET 232 LENGTH 10  OF ls_line WITH ls_detail-telefon.
      REPLACE SECTION OFFSET 242 LENGTH 10  OF ls_line WITH ls_detail-vergi_kimlik_no.
      REPLACE SECTION OFFSET 252 LENGTH 30  OF ls_line WITH ls_detail-vergi_dairesi.
      REPLACE SECTION OFFSET 282 LENGTH 150 OF ls_line WITH ls_detail-mail.
      REPLACE SECTION OFFSET 432 LENGTH 26  OF ls_line WITH ls_detail-iban.
      REPLACE SECTION OFFSET 458 LENGTH 16  OF ls_line WITH ls_detail-tck_no.
      APPEND INITIAL LINE TO rt_bank_file ASSIGNING <ls_bank_file>.
      <ls_bank_file> = ls_line.
    ENDLOOP.

**********************************************************************
*footer

    CLEAR: ls_footer.
    ls_footer-kayit_tipi = |T|.
    ls_footer-adet_toplam = CONV char6( |{ |{ lines( mt_bank_file ) }| ALPHA = IN }| ).
    DATA(v_total) = REDUCE ypym_e_wrbtr( INIT val TYPE ypym_e_wrbtr FOR wa IN mt_bank_file NEXT val = val + wa-paymentamount ).
    ls_footer-tutar_toplam = v_total. SHIFT ls_footer-tutar_toplam RIGHT DELETING TRAILING space. TRANSLATE ls_footer-tutar_toplam USING ' 0'.
    ls_footer-adet_toplam = |{ ls_footer-adet_toplam ALPHA = IN }|.

    CLEAR: ls_line.
    REPLACE SECTION OFFSET 0  LENGTH 1  OF ls_line WITH ls_footer-kayit_tipi."*-&Kayıt Tipi
    REPLACE SECTION OFFSET 1  LENGTH 12  OF ls_line WITH ls_footer-adet_toplam."*-&Adedi
    REPLACE SECTION OFFSET 13 LENGTH 20  OF ls_line WITH ls_footer-tutar_toplam."*-&Toplam İslem Tutari
    APPEND INITIAL LINE TO rt_bank_file ASSIGNING <ls_bank_file>.
    <ls_bank_file> = ls_line.

  ENDMETHOD.