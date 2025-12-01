  METHOD file_0015.
    TYPES: BEGIN OF ty_header,
             kayit_tipi(1),
             dosya_tarihi(8),
             banka(4),
             kurum_kodu(5),
             kurum_hesap_no(26),
             sube_kodu(5),
           END OF ty_header.

    TYPES: BEGIN OF ty_detail,
             kayit_tipi(1),
             odeme_tarihi(8),
             alacakli_banka(4),
             alacakli_sube(5),
             alacakli_hesap(26),
             miktar(21),
             doviz_cinsi(3),
             aciklama(100),
             alacakli_ad_soyad(40),
             alacakli_adresi(50),
             alacakli_tel(20),
             alacakli_vkn_tckn(11),
             alacakli_vergi_dairesi(15),
             alacakli_musteri_no(10),
             alacakli_baba_adi(20),
             alacakli_email(50),
             referans(16),
             parametre(40),
             islem_kodu(2),
             revize_alan1(34),
             revize_alan2(11),
             durum_kodu(2),
             eft_sorgu_no(30),
           END OF ty_detail.

    TYPES: BEGIN OF ty_footer,
             kayit_tipi(1),
             banka_kodu(4),
             adet_toplam(6),
             tutar_toplam(21),
           END OF ty_footer.

    DATA: ls_line(1000)        TYPE c,
          ls_header            TYPE ty_header,
          ls_detail            TYPE ty_detail,
          ls_footer            TYPE ty_footer,
          lv_paymentamount(18),
          lv_space_length      TYPE i.
    DATA(lv_system_date) = cl_abap_context_info=>get_system_date(  ).
    DATA(lv_space) = get_space_character(  ).
**********************************************************************
*başlık
    ls_header = VALUE #(  kayit_tipi = |H|
                          dosya_tarihi = lv_system_date
                          banka = |0015|
                          kurum_kodu = ms_urfcode-firm_code
                          kurum_hesap_no = VALUE #( mt_bank_file[ 1 ]-companybankaccount OPTIONAL )
                          sube_kodu = VALUE #( mt_bank_file[ 1 ]-companybankinternalid+5(5) OPTIONAL ) ).

    CLEAR: ls_line.
    REPLACE SECTION OFFSET 0  LENGTH 1  OF ls_line WITH ls_header-kayit_tipi."*-&Kayıt Tipi
    REPLACE SECTION OFFSET 1  LENGTH 8  OF ls_line WITH ls_header-dosya_tarihi."*-&Dosya Hazırlanma Tarihi
    REPLACE SECTION OFFSET 9  LENGTH 4  OF ls_line WITH ls_header-banka."*-&Banka EFT Kodu
    REPLACE SECTION OFFSET 13 LENGTH 5  OF ls_line WITH ls_header-kurum_kodu."*-&Kurumun Bankadaki Kodu
    REPLACE SECTION OFFSET 18 LENGTH 26 OF ls_line WITH ls_header-kurum_hesap_no."*-&Kurum Bankomat Hesap Numarasi
    REPLACE SECTION OFFSET 44 LENGTH 5  OF ls_line WITH ls_header-sube_kodu."*-&Sorumlu Sube Kodu
    APPEND INITIAL LINE TO rt_bank_file ASSIGNING FIELD-SYMBOL(<ls_bank_file>).
    <ls_bank_file> = ls_line.
**********************************************************************
*kalem
    LOOP AT mt_bank_file INTO DATA(ls_bank_file).
      lv_paymentamount = ls_bank_file-paymentamount. TRANSLATE lv_paymentamount  USING '.,'. SHIFT lv_paymentamount RIGHT DELETING TRAILING space. TRANSLATE lv_paymentamount USING ' 0'.
      CLEAR ls_detail.
      ls_detail = VALUE #( kayit_tipi = |D|
                           odeme_tarihi = lv_system_date
                           alacakli_banka = ls_bank_file-banknumber(4)
                           alacakli_sube = ls_bank_file-banknumber+5(5)
                           alacakli_hesap = COND #( WHEN ls_bank_file-iban IS NOT INITIAL THEN ls_bank_file-iban ELSE ls_bank_file-bankaccount )
                           miktar = lv_paymentamount
                           doviz_cinsi = COND #( WHEN ls_bank_file-transactioncurrency EQ 'TRY' THEN 'TL' ELSE ls_bank_file-transactioncurrency )
                           aciklama = COND #( WHEN ls_bank_file-receiptexplanation IS NOT INITIAL THEN ls_bank_file-receiptexplanation ELSE |TOS-Havale| )
                           alacakli_ad_soyad = COND #( WHEN ls_bank_file-suppliername IS INITIAL THEN ls_bank_file-customername ELSE ls_bank_file-suppliername )
                           alacakli_adresi = space
                           alacakli_tel = space
                           alacakli_vkn_tckn = COND #( WHEN ls_bank_file-bptaxnumber <> space THEN ls_bank_file-bptaxnumber ELSE ls_bank_file-tckn )
                           alacakli_vergi_dairesi = space
                           alacakli_musteri_no = COND #( WHEN ls_bank_file-supplier IS INITIAL THEN ls_bank_file-customer ELSE ls_bank_file-supplier )
                           alacakli_baba_adi = space
                           alacakli_email = space
                           referans = ls_bank_file-documentreferenceid
                           parametre =  COND #( WHEN ls_bank_file-accountingdocument IS NOT INITIAL
                                                    THEN |{ ls_bank_file-companycode }{ ls_bank_file-accountingdocument }{ ls_bank_file-accountingdocumetitem }{ ls_bank_file-fiscalyear }|
                                                    WHEN ls_bank_file-purchaseorder IS NOT INITIAL THEN |{ ls_bank_file-companycode }{ ls_bank_file-purchaseorder }{ ls_bank_file-purchaseorderitem } |
                                                             ELSE |{ ls_bank_file-companycode }{ ls_bank_file-paymentnumber }{ ls_bank_file-paymentamount }{ ls_bank_file-purchaseorderitem } | )
                           islem_kodu = |00|
                           revize_alan1 = space
                           revize_alan2 = space
                           durum_kodu = space
                           eft_sorgu_no = space
      ).

      CLEAR: ls_line.
      REPLACE SECTION OFFSET 0   LENGTH 1   OF ls_line WITH ls_detail-kayit_tipi."*-&Kayıt Tipi
      REPLACE SECTION OFFSET 1   LENGTH 8   OF ls_line WITH ls_detail-odeme_tarihi."-&Odemenin Yapilacagi Tarih
      REPLACE SECTION OFFSET 9   LENGTH 4   OF ls_line WITH ls_detail-alacakli_banka."-&Alacakli Banka Kodu
      REPLACE SECTION OFFSET 13  LENGTH 5   OF ls_line WITH ls_detail-alacakli_sube."-&Alacakli Sube Kodu
      REPLACE SECTION OFFSET 18  LENGTH 26  OF ls_line WITH ls_detail-alacakli_hesap."-&Alacakli Hesap Numarasi
      REPLACE SECTION OFFSET 44  LENGTH 21  OF ls_line WITH ls_detail-miktar."-&Ödeme Miktari
      REPLACE SECTION OFFSET 65  LENGTH 3   OF ls_line WITH ls_detail-doviz_cinsi."-&Para Birimi
      REPLACE SECTION OFFSET 68  LENGTH 100 OF ls_line WITH ls_detail-aciklama."-&Karşı Tarafa Gidecek Açıklama
      REPLACE SECTION OFFSET 168 LENGTH 40  OF ls_line WITH ls_detail-alacakli_ad_soyad."-&Alacakli Adi Soyadi
      REPLACE SECTION OFFSET 208 LENGTH 50  OF ls_line WITH ls_detail-alacakli_adresi."-&Alacakli Adresi
      REPLACE SECTION OFFSET 258 LENGTH 20  OF ls_line WITH ls_detail-alacakli_tel."-&Alacakli Telefon Numarasi
      REPLACE SECTION OFFSET 278 LENGTH 11  OF ls_line WITH ls_detail-alacakli_vkn_tckn."-&Alacakli Vergi ya da TC Kimlik No
      REPLACE SECTION OFFSET 289 LENGTH 15  OF ls_line WITH ls_detail-alacakli_vergi_dairesi."-&Alacakli Vergi Dairesi
      REPLACE SECTION OFFSET 304 LENGTH 10  OF ls_line WITH ls_detail-alacakli_musteri_no."-&Firma Sistemindeki Satıcı/Müşteri No
      REPLACE SECTION OFFSET 314 LENGTH 20  OF ls_line WITH ls_detail-alacakli_baba_adi."-&Alacakli Baba Adi
      REPLACE SECTION OFFSET 334 LENGTH 50  OF ls_line WITH ls_detail-alacakli_email."-&Alacakli E-mail Adresi
      REPLACE SECTION OFFSET 384 LENGTH 16  OF ls_line WITH ls_detail-referans."-&Referans
      REPLACE SECTION OFFSET 400 LENGTH 40  OF ls_line WITH ls_detail-parametre."-&Parametre
      REPLACE SECTION OFFSET 440 LENGTH 2   OF ls_line WITH ls_detail-islem_kodu."-&İşlem Kodu
      REPLACE SECTION OFFSET 442 LENGTH 34  OF ls_line WITH ls_detail-revize_alan1."-&Revize Alan-1
      REPLACE SECTION OFFSET 476 LENGTH 11  OF ls_line WITH ls_detail-revize_alan2."-&Revize Alan-2
      REPLACE SECTION OFFSET 487 LENGTH 2   OF ls_line WITH ls_detail-durum_kodu."-&Durum Kodu
      REPLACE SECTION OFFSET 489 LENGTH 30  OF ls_line WITH ls_detail-eft_sorgu_no."-&Eft/Havale İçin Sorgu Numarasi

*      DATA lv_spaces TYPE i.
*      DATA: g_space TYPE string.
*      CONSTANTS: c_space TYPE syhex02 VALUE '00a0'.
*
*      g_space = cl_abap_conv_in_ce=>uccp( c_space ).
*      lv_spaces = 519 - strlen( ls_line ).
*
*      DO lv_spaces TIMES.
*        CONCATENATE ls_line g_space INTO ls_line.
*      ENDDO.

      lv_space_length = 519 - strlen( ls_line ).
      IF lv_space_length > 0.
        DO lv_space_length TIMES.
          CONCATENATE ls_line lv_space INTO ls_line.
        ENDDO.
      ENDIF.

      APPEND INITIAL LINE TO rt_bank_file ASSIGNING <ls_bank_file>.
      <ls_bank_file> = ls_line.
    ENDLOOP.

    CLEAR: ls_footer.
    ls_footer-kayit_tipi = |F|.
    ls_footer-banka_kodu = |0015|.
*    ls_footer-adet_toplam = CONV numc06( |{ |{ lines( mt_bank_file ) }| ALPHA = IN }| ).
    DATA(v_total) = REDUCE ypym_e_wrbtr( INIT val TYPE ypym_e_wrbtr FOR wa IN mt_bank_file NEXT val = val + wa-paymentamount ).
    ls_footer-tutar_toplam = v_total. SHIFT ls_footer-tutar_toplam RIGHT DELETING TRAILING space. TRANSLATE ls_footer-tutar_toplam USING ' 0'.

    CLEAR: ls_line.
    REPLACE SECTION OFFSET 0  LENGTH 1  OF ls_line WITH ls_footer-kayit_tipi."*-&Kayıt Tipi
    REPLACE SECTION OFFSET 1  LENGTH 4  OF ls_line WITH ls_footer-banka_kodu."*-&Banka Kodu
    REPLACE SECTION OFFSET 5  LENGTH 6  OF ls_line WITH ls_footer-adet_toplam."*-&Toplam İslem Adedi
    REPLACE SECTION OFFSET 11 LENGTH 21 OF ls_line WITH ls_footer-tutar_toplam."*-&Toplam İslem Tutari
    APPEND INITIAL LINE TO rt_bank_file ASSIGNING <ls_bank_file>.
    <ls_bank_file> = ls_line.

  ENDMETHOD.