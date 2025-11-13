  METHOD file_0010_fc.
    TYPES: BEGIN OF ty_header,
             kayit_tipi(1),
             musteri_no(8),
             dosya_tarihi(8),
             dosya_sira(6),
           END OF ty_header.

    TYPES: BEGIN OF ty_detail,
             kayit_tipi(1),
             islem_turu(1),
             islem_tipi(2),
             islem_ref(16),
             havale_ekno(4),
             tutar(15),
             doviz_kodu(3),
             valor(8),
             swift(11),
             alacak_banka_adi(35),
             alacak_banka_adres(105),
             lehdar_iban(35),
             alici_isim(70),
             alici_adres(70),
             aciklama(40),
             yurtdisi_masraf(3),
             masraf_ekno(4),
             ulke_kodu(2),
           END OF ty_detail.

    TYPES: BEGIN OF ty_footer,
             kayit_tipi(1),
             toplam_kayit(8),
           END OF ty_footer.

    DATA: ls_line(1000)        TYPE c,
          ls_header            TYPE ty_header,
          ls_detail            TYPE ty_detail,
          ls_footer            TYPE ty_footer,
          lv_paymentamount(18).
    DATA(lv_system_date) = cl_abap_context_info=>get_system_date(  ).
    CLEAR: ls_header.
    ls_header-kayit_tipi   = |H|.
    ls_header-musteri_no   = ms_urfcode-mbb.
    ls_header-dosya_tarihi = |{ lv_system_date+6(2) }{ lv_system_date+4(2) }{ lv_system_date+0(4) }|.
    ls_header-dosya_sira   = VALUE #( mt_bank_file[ 1 ]-paymentnumber OPTIONAL ).

    REPLACE SECTION OFFSET 0  LENGTH 1  OF ls_line WITH ls_header-kayit_tipi.  "*-&Kayıt Tipi
    REPLACE SECTION OFFSET 1  LENGTH 8  OF ls_line WITH ls_header-musteri_no.  "*-&Müşteri No
    REPLACE SECTION OFFSET 9  LENGTH 8  OF ls_line WITH ls_header-dosya_tarihi."*-&Dosya Tarihi
    REPLACE SECTION OFFSET 17 LENGTH 6  OF ls_line WITH ls_header-dosya_tarihi."*-&Dosya Sıra No
    APPEND INITIAL LINE TO rt_bank_file ASSIGNING FIELD-SYMBOL(<ls_bank_file>).
    <ls_bank_file> = ls_line.

*--------------------------------------------------------------------*
*-&STEP -2: Detay Verilerinin Doldurulması->
*--------------------------------------------------------------------*
    "TODO : stras
    LOOP AT mt_bank_file INTO DATA(ls_bank_file).
      lv_paymentamount = ls_bank_file-paymentamount.
      TRANSLATE ls_detail-tutar  USING '.,'.
      SHIFT ls_detail-tutar RIGHT DELETING TRAILING space. TRANSLATE ls_detail-tutar USING ' 0'.
      CLEAR: ls_detail.
      ls_detail-kayit_tipi         = |D|.
      ls_detail-islem_turu         = |G|.
      ls_detail-islem_tipi         = |60|.
      ls_detail-islem_ref          = ls_bank_file-documentreferenceid.
      ls_detail-havale_ekno        = ls_bank_file-companybankaccount+14(4).
      ls_detail-tutar              = lv_paymentamount.
      ls_detail-doviz_kodu         = ls_bank_file-transactioncurrency.
      ls_detail-valor              = lv_system_date.
      ls_detail-swift              = ls_bank_file-companyswiftcode.
      ls_detail-alacak_banka_adi   = ls_bank_file-bankname.
*      ls_detail-alacak_banka_adres = ls_bank_file-stras.
      ls_detail-lehdar_iban        = ls_bank_file-iban.
      ls_detail-alici_isim         = COND #( WHEN ls_bank_file-suppliername IS INITIAL THEN ls_bank_file-customername ELSE ls_bank_file-suppliername ).
*      ls_detail-alici_adres        = ls_bank_file-bank_stras.
      ls_detail-aciklama           = COND #( WHEN ls_bank_file-accountingdocument IS NOT INITIAL
                                THEN |{ ls_bank_file-companycode }{ ls_bank_file-accountingdocument }{ ls_bank_file-accountingdocumetitem }{ ls_bank_file-fiscalyear }|
                                WHEN ls_bank_file-purchaseorder IS NOT INITIAL THEN |{ ls_bank_file-companycode }{ ls_bank_file-purchaseorder }{ ls_bank_file-purchaseorderitem } |
                                         ELSE |{ ls_bank_file-companycode }{ ls_bank_file-paymentnumber }{ ls_bank_file-paymentamount }{ ls_bank_file-purchaseorderitem } | ).
      ls_detail-yurtdisi_masraf    = |OUR|.
      ls_detail-masraf_ekno        = ls_bank_file-bankaccount.
      ls_detail-ulke_kodu          = ls_bank_file-bankcountrykey.

      CLEAR: ls_line.
      REPLACE SECTION OFFSET 0   LENGTH 1   OF ls_line WITH ls_detail-kayit_tipi.         "*-&Kayıt Tipi
      REPLACE SECTION OFFSET 1   LENGTH 1   OF ls_line WITH ls_detail-islem_turu.         "*-&İşlem Türü
      REPLACE SECTION OFFSET 2   LENGTH 2   OF ls_line WITH ls_detail-islem_tipi.         "*-&İşlem Tipi
      REPLACE SECTION OFFSET 4   LENGTH 16  OF ls_line WITH ls_detail-islem_ref.          "*-&İşlem Referansı
      REPLACE SECTION OFFSET 20  LENGTH 4   OF ls_line WITH ls_detail-havale_ekno.        "*-&Havale Hesap Ek No
      REPLACE SECTION OFFSET 69  LENGTH 16  OF ls_line WITH ls_detail-tutar.              "*-&Tutar
      REPLACE SECTION OFFSET 85  LENGTH 3   OF ls_line WITH ls_detail-doviz_kodu.         "*-&Döviz Kodu
      REPLACE SECTION OFFSET 88  LENGTH 8   OF ls_line WITH ls_detail-valor.              "*-&Valor Tarihi
      REPLACE SECTION OFFSET 107 LENGTH 11  OF ls_line WITH ls_detail-swift.              "*-&Swift Kodu
      REPLACE SECTION OFFSET 119 LENGTH 35  OF ls_line WITH ls_detail-alacak_banka_adi.   "*-&Alacak Banka Adı
      REPLACE SECTION OFFSET 153 LENGTH 105 OF ls_line WITH ls_detail-alacak_banka_adres. "*-&Alacak Banka Adres
      REPLACE SECTION OFFSET 293 LENGTH 35  OF ls_line WITH ls_detail-lehdar_iban.        "*-&Lehdar IBAN No
      REPLACE SECTION OFFSET 328 LENGTH 70  OF ls_line WITH ls_detail-alici_isim.         "*-&Alıcı İsmi
      REPLACE SECTION OFFSET 398 LENGTH 70  OF ls_line WITH ls_detail-alici_adres.        "*-&Alıcı Adresi
      REPLACE SECTION OFFSET 468 LENGTH 40  OF ls_line WITH ls_detail-aciklama.           "*-&Alıcı Adresi
      REPLACE SECTION OFFSET 648 LENGTH 3   OF ls_line WITH ls_detail-yurtdisi_masraf.    "*-&Yurtdışı Masraf Yeri
      REPLACE SECTION OFFSET 651 LENGTH 4   OF ls_line WITH ls_detail-masraf_ekno.        "*-&Masraf Hesap Ek No
      REPLACE SECTION OFFSET 807 LENGTH 2   OF ls_line WITH ls_detail-ulke_kodu.          "*-&Ülke Kodu
      APPEND INITIAL LINE TO rt_bank_file ASSIGNING <ls_bank_file>.
      <ls_bank_file> = ls_line.

    ENDLOOP.

*--------------------------------------------------------------------*
*-&STEP -3: Sayfa Sonu Verilerinin Doldurulması->
*--------------------------------------------------------------------*
    CLEAR: ls_footer.
    ls_footer-kayit_tipi = |F|.
    ls_footer-toplam_kayit = CONV numc5( |{ |{ lines( mt_bank_file ) }| ALPHA = IN }| ).

    CLEAR: ls_line.
    REPLACE SECTION OFFSET 0 LENGTH 1  OF ls_line WITH ls_footer-kayit_tipi.  "*-&Kayıt Tipi
    REPLACE SECTION OFFSET 1 LENGTH 8  OF ls_line WITH ls_footer-toplam_kayit."*-&Toplam Kayıt Sayısı
    APPEND INITIAL LINE TO rt_bank_file ASSIGNING <ls_bank_file>.
    <ls_bank_file> = ls_line.

  ENDMETHOD.