  METHOD file_0046.
    TYPES: BEGIN OF ty_header,
             kayit_tipi(1),
             urun_ref_kodu(15),
             dosya_tarihi(8),
           END OF ty_header.

    TYPES: BEGIN OF ty_detail,
             kayit_tipi(1),
             banka_kodu(4),
             sube_kodu(5),
             hesap_no(7),
             ozel_alan(11),
             fark_sube_kodu(5),
             fark_hesap_no(7),
             alıcı_verigi_no(10),
             bosluk(1),
             k_banka_kodu(4),
             k_sube_kodu(5),
             k_hesap_no(18),
             sat_mus_no(10),
             alıcı_adı(40),
             adres(40),
             telefon(20),
             alıcı_vrg_dairesi(15),
             baba_adı(15),
             acıklama(100),
             referans(16),
             parametre(40),
             tutar(18),
             para_birimi(5),
             islem_tarihi(8),
             islem_kodu(2),
             durum_kodu(2),
             alacakli_iban(26),
           END OF ty_detail.

    TYPES: BEGIN OF ty_footer,
             kayit_tipi(1),
             tpl_kayıt(5),
           END OF ty_footer.

    DATA: ls_line(1000)        TYPE c,
          ls_header            TYPE ty_header,
          ls_detail            TYPE ty_detail,
          ls_footer            TYPE ty_footer,
          lv_paymentamount(18) TYPE c.

    CONSTANTS: lc_cr_lf   TYPE c LENGTH 2 VALUE cl_abap_char_utilities=>cr_lf,
               lc_newline TYPE c VALUE cl_abap_char_utilities=>newline.
    DATA(lv_system_date) = cl_abap_context_info=>get_system_date(  ).
**********************************************************************
*Başlık
    ls_header = VALUE #( kayit_tipi = 'B'
                         urun_ref_kodu = ms_urfcode-firm_code
                         dosya_tarihi = |{ lv_system_date+6(2) }{ lv_system_date+4(2) }{ lv_system_date+0(4) }| ).

    CLEAR: ls_line.
    REPLACE SECTION OFFSET 0  LENGTH 1  OF ls_line WITH ls_header-kayit_tipi."*-&Kayıt Tipi
    REPLACE SECTION OFFSET 1  LENGTH 15 OF ls_line WITH ls_header-urun_ref_kodu."*-&Ürün Referans Kodu
    REPLACE SECTION OFFSET 16 LENGTH 8  OF ls_line WITH ls_header-dosya_tarihi."*-&Dosya Tarihi
    APPEND INITIAL LINE TO rt_bank_file ASSIGNING FIELD-SYMBOL(<ls_bank_file>).
    <ls_bank_file> = ls_line.
**********************************************************************
*Kalemler
    LOOP AT mt_bank_file INTO DATA(ls_bank_file).
      lv_paymentamount = ls_bank_file-paymentamount. TRANSLATE lv_paymentamount  USING '.,'. SHIFT lv_paymentamount RIGHT DELETING TRAILING space. TRANSLATE lv_paymentamount USING ' 0'.
      CLEAR ls_detail.
      ls_detail = VALUE #(  kayit_tipi = |D|
                            banka_kodu = ls_bank_file-companybankinternalid(4)
                            sube_kodu = ls_bank_file-companybankinternalid+5(5)
                            hesap_no = ls_bank_file-companybankaccount
                            ozel_alan = COND #( WHEN ls_bank_file-companybankaccount <> space THEN space ELSE |{ ls_bank_file-companyiban+16(10) WIDTH = 11 ALIGN = RIGHT }| )
                            fark_sube_kodu = space
                            fark_hesap_no = space
                            alıcı_verigi_no = COND #( WHEN strlen( ls_bank_file-bptaxnumber ) EQ 10
                                                      THEN ls_bank_file-bptaxnumber
                                                      WHEN strlen( ls_bank_file-bptaxnumber ) EQ 11
                                                      THEN ls_bank_file-bptaxnumber+0(10) ELSE space )
                            bosluk = COND #( WHEN strlen( ls_bank_file-bptaxnumber ) EQ 11 THEN ls_bank_file-bptaxnumber+10(1) ELSE space )
                            k_banka_kodu = COND #( WHEN ls_bank_file-iban <> space THEN ls_bank_file-iban(4) ELSE ls_bank_file-banknumber(4) )
                            k_sube_kodu = COND #( WHEN ls_bank_file-iban <> space THEN ls_bank_file-iban+4(5) ELSE ls_bank_file-banknumber+4(5) )
                            k_hesap_no =  COND #( WHEN ls_bank_file-iban <> space THEN ls_bank_file-iban+9(17) ELSE ls_bank_file-bankaccount )
                            sat_mus_no =  COND #( WHEN ls_bank_file-supplier IS INITIAL THEN ls_bank_file-customer ELSE ls_bank_file-supplier )
                            alıcı_adı = COND #( WHEN ls_bank_file-suppliername IS INITIAL THEN ls_bank_file-customername ELSE ls_bank_file-suppliername )
                            adres = space
                            telefon = space
                            alıcı_vrg_dairesi = space
                            baba_adı = space
                            acıklama = COND #( WHEN ls_bank_file-receiptexplanation IS NOT INITIAL THEN ls_bank_file-receiptexplanation ELSE |TOS-Havale| )
                            referans = ls_bank_file-documentreferenceid
           parametre =  COND #( WHEN ls_bank_file-accountingdocument IS NOT INITIAL
                                THEN |{ ls_bank_file-companycode }{ ls_bank_file-accountingdocument }{ ls_bank_file-accountingdocumetitem }{ ls_bank_file-fiscalyear }|
                                WHEN ls_bank_file-purchaseorder IS NOT INITIAL THEN |{ ls_bank_file-companycode }{ ls_bank_file-purchaseorder }{ ls_bank_file-purchaseorderitem } |
                                         ELSE |{ ls_bank_file-companycode }{ ls_bank_file-paymentnumber }{ ls_bank_file-paymentamount }{ ls_bank_file-purchaseorderitem } | )
           tutar = lv_paymentamount
           para_birimi = ls_bank_file-transactioncurrency
           islem_tarihi = |{ lv_system_date+6(2) }{ lv_system_date+4(2) }{ lv_system_date+0(4) }|
           islem_kodu = COND #( WHEN ls_bank_file-paymentamount GT 10000000 THEN |06| ELSE |99| )
           durum_kodu = |00|
           alacakli_iban = ls_bank_file-iban ).

      CLEAR: ls_line.
      REPLACE SECTION OFFSET 0   LENGTH 1   OF ls_line WITH ls_detail-kayit_tipi."*-&Kayıt Tipi
      REPLACE SECTION OFFSET 1   LENGTH 4   OF ls_line WITH ls_detail-banka_kodu."*-&Banka Kodu
      REPLACE SECTION OFFSET 5   LENGTH 5   OF ls_line WITH ls_detail-sube_kodu."*-&Şube Kodu
      REPLACE SECTION OFFSET 10  LENGTH 7   OF ls_line WITH ls_detail-hesap_no."*-&Hesap No
      REPLACE SECTION OFFSET 17  LENGTH 11  OF ls_line WITH ls_detail-ozel_alan."*-&Özel alan
      REPLACE SECTION OFFSET 28  LENGTH 5   OF ls_line WITH ls_detail-fark_sube_kodu."*-&Fark Şube Kodu
      REPLACE SECTION OFFSET 33  LENGTH 7   OF ls_line WITH ls_detail-fark_hesap_no."*-&Fark Hesap No
      REPLACE SECTION OFFSET 40  LENGTH 10  OF ls_line WITH ls_detail-alıcı_verigi_no."*-&Alıcı Vergi No
      REPLACE SECTION OFFSET 50  LENGTH 1   OF ls_line WITH ls_detail-bosluk."*-&Boşluk
      REPLACE SECTION OFFSET 51  LENGTH 4   OF ls_line WITH ls_detail-k_banka_kodu."*-&Karşı Banka Kodu
      REPLACE SECTION OFFSET 55  LENGTH 5   OF ls_line WITH ls_detail-k_sube_kodu."*-&Karşı Şube Kodu
      REPLACE SECTION OFFSET 60  LENGTH 18  OF ls_line WITH ls_detail-k_hesap_no."*-&Karşı Hesap No
      REPLACE SECTION OFFSET 78  LENGTH 10  OF ls_line WITH ls_detail-sat_mus_no."*-&Satıcı/Müşteri No
      REPLACE SECTION OFFSET 88  LENGTH 40  OF ls_line WITH ls_detail-alıcı_adı."*-&Alıcı Adı
      REPLACE SECTION OFFSET 128 LENGTH 40  OF ls_line WITH ls_detail-adres."*-&Adres
      REPLACE SECTION OFFSET 168 LENGTH 20  OF ls_line WITH ls_detail-telefon."*-&Telefon
      REPLACE SECTION OFFSET 188 LENGTH 15  OF ls_line WITH ls_detail-alıcı_vrg_dairesi."*-&Alıcı Vergi Dairesi
      REPLACE SECTION OFFSET 203 LENGTH 15  OF ls_line WITH ls_detail-baba_adı."*-&Baba Adı
      REPLACE SECTION OFFSET 218 LENGTH 100 OF ls_line WITH ls_detail-acıklama."*-&Açıklama
      REPLACE SECTION OFFSET 318 LENGTH 16  OF ls_line WITH ls_detail-referans."*-&Referans
      REPLACE SECTION OFFSET 334 LENGTH 40  OF ls_line WITH ls_detail-parametre."*-&Parametre
      REPLACE SECTION OFFSET 374 LENGTH 18  OF ls_line WITH ls_detail-tutar."*-&Tutar
      REPLACE SECTION OFFSET 392 LENGTH 5   OF ls_line WITH ls_detail-para_birimi."*-&Para Birimi
      REPLACE SECTION OFFSET 397 LENGTH 8   OF ls_line WITH ls_detail-islem_tarihi."*-&İşlem Tarihi
      REPLACE SECTION OFFSET 405 LENGTH 2   OF ls_line WITH ls_detail-islem_kodu."*-&İşlem Kodu
      REPLACE SECTION OFFSET 407 LENGTH 2   OF ls_line WITH ls_detail-durum_kodu."*-&Durum Kodu
      APPEND INITIAL LINE TO rt_bank_file ASSIGNING <ls_bank_file>.
      <ls_bank_file> = ls_line.

    ENDLOOP.
**********************************************************************
*Foooter
    CLEAR ls_footer.
    ls_footer = VALUE #( kayit_tipi = |T|
                         tpl_kayit = CONV numc5( |{ |{ lines( mt_bank_file ) }| ALPHA = IN }| ) ).
    CLEAR ls_line.
    REPLACE SECTION OFFSET 0 LENGTH 1 OF ls_line WITH ls_footer-kayit_tipi."*-&Kayıt Tipi
    REPLACE SECTION OFFSET 1 LENGTH 5 OF ls_line WITH ls_footer-tpl_kayit."*-&Toplam Kayıt Sayısı
    APPEND INITIAL LINE TO rt_bank_file ASSIGNING <ls_bank_file>.
    <ls_bank_file> = ls_line.
  ENDMETHOD.