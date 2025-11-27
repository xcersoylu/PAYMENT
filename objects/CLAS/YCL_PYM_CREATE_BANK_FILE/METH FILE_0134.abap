  METHOD file_0134.
    TYPES: BEGIN OF ty_header,
             kayit_tipi(1),
             firma_kodu(15),
             dosya_tarihi(8),
           END OF ty_header.

    TYPES: BEGIN OF ty_detail,
             kayit_tipi(1),
             banka_kodu(4),
             sube_kodu(5),
             hesap_no(18),
             on_akibet_kodu(5),
             eft_sorgu_no(7),
             vergi_no(11),
             karsi_banka_kodu(4),
             karsi_sube_kodu(5),
             karsi_hesap_no(18),
             sat_mus_no(10),
             alici_adi(40),
             adres(40),
             telefon(20),
             alici_vergi_dairesi(15),
             islem_dekont_no(6),
             baba_adi(9),
             aciklama(40),
             referans(16),
             parametre(40),
             tutar(18),
             para_birimi(5),
             islem_tarihi(8),
             islem_kodu(2),
             durum_kodu(2),
             transfer_tipi(2),
           END OF ty_detail.

    TYPES: BEGIN OF ty_footer,
             kayit_tipi(1),
             tpl_kayıt(5),
           END OF ty_footer.

    DATA: ls_line(1000)        TYPE c,
          ls_header            TYPE ty_header,
          ls_detail            TYPE ty_detail,
          ls_footer            TYPE ty_footer,
          lv_paymentamount(18).

    CONSTANTS: lc_cr_lf   TYPE c length 2 VALUE cl_abap_char_utilities=>cr_lf,
               lc_newline TYPE c VALUE cl_abap_char_utilities=>newline.

    DATA(lv_system_date) = cl_abap_context_info=>get_system_date(  ).
**********************************************************************
*Başlık
    ls_header = VALUE #( kayit_tipi = 'B'
                         firma_kodu = ms_urfcode-firm_code
                         dosya_tarihi = |{ lv_system_date+6(2) }{ lv_system_date+4(2) }{ lv_system_date+0(4) }| ).

    CLEAR: ls_line.
    REPLACE SECTION OFFSET 0  LENGTH 1  OF ls_line WITH ls_header-kayit_tipi."*-&Kayıt Tipi
    REPLACE SECTION OFFSET 1  LENGTH 15 OF ls_line WITH ls_header-firma_kodu."*-&Ürün Referans Kodu
    REPLACE SECTION OFFSET 16 LENGTH 8  OF ls_line WITH ls_header-dosya_tarihi."*-&Dosya Tarihi
    APPEND INITIAL LINE TO rt_bank_file ASSIGNING FIELD-SYMBOL(<ls_bank_file>).
    <ls_bank_file> = ls_line.
**********************************************************************
*kalemler
    LOOP AT mt_bank_file INTO DATA(ls_bank_file).
      lv_paymentamount = ls_bank_file-paymentamount. TRANSLATE lv_paymentamount  USING '.,'. SHIFT lv_paymentamount RIGHT DELETING TRAILING space. TRANSLATE lv_paymentamount USING ' 0'.
      clear ls_Detail.
      ls_detail = VALUE #( kayit_tipi = |D|
                          banka_kodu = ls_bank_file-companybankinternalid(4)
                          sube_kodu = ls_bank_file-companybankinternalid+5(5)
                          hesap_no = ls_bank_file-companybankaccount
                          on_akibet_kodu = |00000|
                          eft_sorgu_no = space
                          vergi_no = ls_bank_file-bptaxnumber
                          karsi_banka_kodu = ls_bank_file-iban(4)
                          karsi_sube_kodu = ls_bank_file-iban+4(5)
                          karsi_hesap_no = ls_bank_file-iban+9(17)
                          sat_mus_no = COND #( WHEN ls_bank_file-supplier IS INITIAL THEN ls_bank_file-customer ELSE ls_bank_file-supplier )
                          alici_adi = COND #( WHEN ls_bank_file-suppliername IS INITIAL THEN ls_bank_file-customername ELSE ls_bank_file-suppliername )
                          adres = space
                          telefon = space
                          alici_vergi_dairesi = space
                          islem_dekont_no = space
                          baba_adi = space
                          aciklama = COND #( WHEN ls_bank_file-receiptexplanation IS NOT INITIAL THEN ls_bank_file-receiptexplanation ELSE |TOS-Havale| )
                          referans = ls_bank_file-documentreferenceid
           parametre =  COND #( WHEN ls_bank_file-accountingdocument IS NOT INITIAL
                                THEN |{ ls_bank_file-companycode }{ ls_bank_file-accountingdocument }{ ls_bank_file-accountingdocumetitem }{ ls_bank_file-fiscalyear }|
                                WHEN ls_bank_file-purchaseorder IS NOT INITIAL THEN |{ ls_bank_file-companycode }{ ls_bank_file-purchaseorder }{ ls_bank_file-purchaseorderitem } |
                                         ELSE |{ ls_bank_file-companycode }{ ls_bank_file-paymentnumber }{ ls_bank_file-paymentamount }{ ls_bank_file-purchaseorderitem } | )
           tutar = lv_paymentamount
           para_birimi = ls_bank_file-transactioncurrency
           islem_tarihi = |{ lv_system_date+6(2) }{ lv_system_date+4(2) }{ lv_system_date+0(4) }|
           islem_kodu = |00|
           durum_kodu = |00|
           transfer_tipi = |99| ).

      CLEAR: ls_line.
      REPLACE SECTION OFFSET 0   LENGTH 1   OF ls_line WITH ls_detail-kayit_tipi."*-&Kayıt Tipi
      REPLACE SECTION OFFSET 1   LENGTH 4   OF ls_line WITH ls_detail-banka_kodu."*-&banka_kodu
      REPLACE SECTION OFFSET 5   LENGTH 5   OF ls_line WITH ls_detail-sube_kodu."*-&sube_kodu
      REPLACE SECTION OFFSET 10  LENGTH 18  OF ls_line WITH ls_detail-hesap_no."*-&hesap_no
      REPLACE SECTION OFFSET 28  LENGTH 5   OF ls_line WITH ls_detail-on_akibet_kodu."*-&ÖnAkibetKodu
      REPLACE SECTION OFFSET 33  LENGTH 7   OF ls_line WITH ls_detail-eft_sorgu_no."*-&eft_sorgu_no
      REPLACE SECTION OFFSET 40  LENGTH 11  OF ls_line WITH ls_detail-vergi_no."*-&vergi_no
      REPLACE SECTION OFFSET 51  LENGTH 4   OF ls_line WITH ls_detail-karsi_banka_kodu."*-&karsi_banka_kodu
      REPLACE SECTION OFFSET 55  LENGTH 5   OF ls_line WITH ls_detail-karsi_sube_kodu."*-&karsi_sube_kodu
      REPLACE SECTION OFFSET 60  LENGTH 18  OF ls_line WITH ls_detail-karsi_hesap_no."*-&karsi_hesap_no
      REPLACE SECTION OFFSET 78  LENGTH 10  OF ls_line WITH ls_detail-sat_mus_no."*-&sat_mus_no
      REPLACE SECTION OFFSET 88  LENGTH 40  OF ls_line WITH ls_detail-alici_adi."*-&alici_adi
      REPLACE SECTION OFFSET 128 LENGTH 40  OF ls_line WITH ls_detail-adres."*-&adres
      REPLACE SECTION OFFSET 168 LENGTH 20  OF ls_line WITH ls_detail-telefon."*-&telefon
      REPLACE SECTION OFFSET 188 LENGTH 15  OF ls_line WITH ls_detail-alici_vergi_dairesi."*-&alici_vergi_dairesi
      REPLACE SECTION OFFSET 203 LENGTH 6   OF ls_line WITH ls_detail-islem_dekont_no."*-&islem_dekont_no
      REPLACE SECTION OFFSET 209 LENGTH 9   OF ls_line WITH ls_detail-baba_adi."*-&baba_adi
      REPLACE SECTION OFFSET 218 LENGTH 40  OF ls_line WITH ls_detail-aciklama."*-&aciklama
      REPLACE SECTION OFFSET 258 LENGTH 16  OF ls_line WITH ls_detail-referans."*-&referans
      REPLACE SECTION OFFSET 274 LENGTH 40  OF ls_line WITH ls_detail-parametre."*-&parametre
      REPLACE SECTION OFFSET 314 LENGTH 18  OF ls_line WITH ls_detail-tutar."*-&tutar
      REPLACE SECTION OFFSET 332 LENGTH 5   OF ls_line WITH ls_detail-para_birimi."*-&para_birimi
      REPLACE SECTION OFFSET 337 LENGTH 8   OF ls_line WITH ls_detail-islem_tarihi."*-&islem_tarihi
      REPLACE SECTION OFFSET 345 LENGTH 2   OF ls_line WITH ls_detail-islem_kodu."*-&islem_kodu
      REPLACE SECTION OFFSET 347 LENGTH 2   OF ls_line WITH ls_detail-durum_kodu."*-&durum_kodu
      REPLACE SECTION OFFSET 349 LENGTH 2   OF ls_line WITH ls_detail-transfer_tipi."*-&islem_kodu

      APPEND INITIAL LINE TO rt_bank_file ASSIGNING <ls_bank_file>.
      <ls_bank_file> = ls_line.
    ENDLOOP.
**********************************************************************
*Foooter
    clear ls_Footer.
    ls_footer = VALUE #( kayit_tipi = |T|
                         tpl_kayit = CONV numc5( |{ |{ lines( mt_bank_file ) }| ALPHA = IN }| ) ).
    clear ls_line.
    REPLACE SECTION OFFSET 0 LENGTH 1 OF ls_line WITH ls_footer-kayit_tipi."*-&Kayıt Tipi
    REPLACE SECTION OFFSET 1 LENGTH 5 OF ls_line WITH ls_footer-tpl_kayit."*-&Toplam Kayıt Sayısı
    APPEND INITIAL LINE TO rt_bank_file ASSIGNING <ls_bank_file>.
    <ls_bank_file> = ls_line.
  ENDMETHOD.