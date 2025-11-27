  METHOD file_0010.
    TYPES: BEGIN OF ty_header,
             kayit_tipi(1),
             kurum_kodu(5),
             kurum_alt_kodu(3),
             bodro_no(10),
             bodro_tarihi(8),
             bodro_aciklama(50),
           END OF ty_header.

    TYPES: BEGIN OF ty_detail,
             kayit_tipi(1),
             kayit_numarasi(7),
             islem_turu(3),
             odeme_amac(2),
             odeme_tarihi(8),
             alacak_banka_kodu(4),
             alacak_sube_kodu(5),
             alacak_hesap_no(26),
             alacak_kredi_kart_no(16),
             tutar(16),
             musteri_adı(30),
             musteri_soyadi(30),
             baba_adi(30),
             tckn_vkn(11),
             aciklama(100),
           END OF ty_detail.

    TYPES: BEGIN OF ty_footer,
             kayit_tipi(1),
             toplam_adet(7),
             toplam_tutar(16),
           END OF ty_footer.

    DATA: ls_line(1000)        TYPE c,
          lv_sira(7)           TYPE c VALUE '1',
          ls_header            TYPE ty_header,
          ls_detail            TYPE ty_detail,
          ls_footer            TYPE ty_footer,
          lv_paymentamount(18).
    DATA(lv_system_date) = cl_abap_context_info=>get_system_date(  ).
    DATA(lv_system_time) = cl_abap_context_info=>get_system_time(  ).
    CLEAR: ls_header.
    ls_header = VALUE #( kayit_tipi = |H|
                        kurum_kodu = ms_urfcode-firm_code(5)
                        kurum_alt_kodu = ms_urfcode-firm_code+5(3)
                        bodro_no = |{ lv_system_date+2(2) }{ lv_system_date+4(2) }{ lv_system_date+6(2) }{ lv_system_time }|
                        bodro_tarihi = lv_system_date
                        bodro_aciklama = |TOS-Havale| ).

    CLEAR: ls_line.
    REPLACE SECTION OFFSET 0  LENGTH 1  OF ls_line WITH ls_header-kayit_tipi."*-&Kayıt Tipi
    REPLACE SECTION OFFSET 1  LENGTH 5  OF ls_line WITH ls_header-kurum_kodu."*-&Kurum Kodu
    REPLACE SECTION OFFSET 6  LENGTH 3  OF ls_line WITH ls_header-kurum_alt_kodu."*-&Kurum Alt Kodu
    REPLACE SECTION OFFSET 9  LENGTH 10 OF ls_line WITH ls_header-bodro_no."*-&Bordro No
    REPLACE SECTION OFFSET 19 LENGTH 8  OF ls_line WITH ls_header-bodro_tarihi."*-&Bordro Tarihi
    REPLACE SECTION OFFSET 27 LENGTH 50 OF ls_line WITH ls_header-bodro_aciklama."*-&Bordro Açıklama
    APPEND INITIAL LINE TO rt_bank_file ASSIGNING FIELD-SYMBOL(<ls_bank_file>).
    <ls_bank_file> = ls_line.

    LOOP AT mt_bank_file INTO DATA(ls_bank_file).
      lv_paymentamount = ls_bank_file-paymentamount. TRANSLATE lv_paymentamount  USING '.,'. SHIFT lv_paymentamount RIGHT DELETING TRAILING space. TRANSLATE lv_paymentamount USING ' 0'.
      ls_detail = VALUE #(  kayit_tipi = |D|
                            kayit_numarasi = |{ lv_sira ALPHA = IN }|
                            islem_turu = |M01|
                            odeme_amac = |99|
                            odeme_tarihi = lv_system_date
                            alacak_banka_kodu = ls_bank_file-banknumber(4)
                            alacak_sube_kodu = ls_bank_file-banknumber+5(5)
                            alacak_hesap_no = COND #( WHEN ls_bank_file-iban <> space THEN ls_bank_file-iban ELSE ls_bank_file-bankaccount )
                            alacak_kredi_kart_no = space
                            tutar = lv_paymentamount
*                           musteri_adı = ls_bank_file-name1. "FIX_IT
*                           musteri_soyadi = ls_bank_file-name2. "FIX_IT
                             baba_adi = space
                             tckn_vkn = COND #( WHEN ls_bank_file-bptaxnumber <> space THEN ls_bank_file-bptaxnumber ELSE ls_bank_file-tckn )
                            aciklama =  COND #( WHEN ls_bank_file-accountingdocument IS NOT INITIAL
                                                    THEN |{ ls_bank_file-companycode }{ ls_bank_file-accountingdocument }{ ls_bank_file-accountingdocumetitem }{ ls_bank_file-fiscalyear }|
                                                    WHEN ls_bank_file-purchaseorder IS NOT INITIAL THEN |{ ls_bank_file-companycode }{ ls_bank_file-purchaseorder }{ ls_bank_file-purchaseorderitem } |
                                                             ELSE |{ ls_bank_file-companycode }{ ls_bank_file-paymentnumber }{ ls_bank_file-paymentamount }{ ls_bank_file-purchaseorderitem } | )

      ).

      CLEAR: ls_line.
      REPLACE SECTION OFFSET 0   LENGTH 1   OF ls_line WITH ls_detail-kayit_tipi."*-&Kayıt Tipi
      REPLACE SECTION OFFSET 1   LENGTH 7   OF ls_line WITH ls_detail-kayit_numarasi."*-&Kayıt Numarası
      REPLACE SECTION OFFSET 8   LENGTH 3   OF ls_line WITH ls_detail-islem_turu."*-&İşlme Türü
      REPLACE SECTION OFFSET 11  LENGTH 2   OF ls_line WITH ls_detail-odeme_amac."*-&Ödeme Amaç
      REPLACE SECTION OFFSET 13  LENGTH 8   OF ls_line WITH ls_detail-odeme_tarihi."*-&Ödeme Tarihi
      IF ls_bank_file-iban IS NOT INITIAL.
        ls_detail-alacak_banka_kodu = '0000'.
        ls_detail-alacak_sube_kodu  = '00000'.
      ENDIF.
      REPLACE SECTION OFFSET 21  LENGTH 4   OF ls_line WITH ls_detail-alacak_banka_kodu."*-&Alacak Banka Kodu
      REPLACE SECTION OFFSET 25  LENGTH 5   OF ls_line WITH ls_detail-alacak_sube_kodu."*-&Alacak Şube Kodu
      REPLACE SECTION OFFSET 30  LENGTH 26  OF ls_line WITH ls_detail-alacak_hesap_no."*-&Alacak Hesap No
      REPLACE SECTION OFFSET 56  LENGTH 16  OF ls_line WITH ls_detail-alacak_kredi_kart_no."*-&Alacak Kredi Kart No
      REPLACE SECTION OFFSET 72  LENGTH 16  OF ls_line WITH ls_detail-tutar."*-&Tutar
      REPLACE SECTION OFFSET 88  LENGTH 30  OF ls_line WITH ls_detail-musteri_adı."*-&Müşteri Adı
      REPLACE SECTION OFFSET 118 LENGTH 30  OF ls_line WITH ls_detail-musteri_soyadi."*-&Müşteri Soyadı
      REPLACE SECTION OFFSET 148 LENGTH 30  OF ls_line WITH ls_detail-baba_adi."*-&Baba Adı
      REPLACE SECTION OFFSET 178 LENGTH 11  OF ls_line WITH ls_detail-tckn_vkn."*-&TCKN/VKN
      REPLACE SECTION OFFSET 189 LENGTH 51  OF ls_line WITH ls_bank_file-receiptexplanation.
      REPLACE SECTION OFFSET 240 LENGTH 49  OF ls_line WITH ls_detail-aciklama."*-&Açıklama
      APPEND INITIAL LINE TO rt_bank_file ASSIGNING <ls_bank_file>.
      <ls_bank_file> = ls_line.

      lv_sira += 1.
    ENDLOOP.
**********************************************************************
*footer
    CLEAR: ls_footer.
    ls_footer = VALUE #( kayit_tipi = |T|
                         toplam_adet = CONV char7( |{ |{ lines( mt_bank_file ) }| ALPHA = IN }| ) ).
    DATA(v_total) = REDUCE ypym_e_wrbtr( INIT val TYPE ypym_e_wrbtr FOR wa IN  mt_bank_file NEXT val = val + wa-paymentamount ).
    ls_footer-toplam_tutar = v_total. TRANSLATE ls_footer-toplam_tutar  USING '.,'. SHIFT ls_footer-toplam_tutar RIGHT DELETING TRAILING space. TRANSLATE ls_footer-toplam_tutar USING ' 0'.

    CLEAR: ls_line.
    REPLACE SECTION OFFSET 0 LENGTH 1  OF ls_line WITH ls_footer-kayit_tipi."*-&Kayıt Tipi
    REPLACE SECTION OFFSET 1 LENGTH 7  OF ls_line WITH ls_footer-toplam_adet."*-&Toplam Adet
    REPLACE SECTION OFFSET 8 LENGTH 16 OF ls_line WITH ls_footer-toplam_tutar."*-&Toplam Tutar
    APPEND INITIAL LINE TO rt_bank_file ASSIGNING <ls_bank_file>.
    <ls_bank_file> = ls_line.

  ENDMETHOD.