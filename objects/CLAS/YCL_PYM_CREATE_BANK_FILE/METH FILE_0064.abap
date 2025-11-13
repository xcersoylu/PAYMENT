  METHOD file_0064.
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
             fark_sube_kodu(5),
             fark_hesap_no(18),
             karsi_banka_kodu(4),
             karsi_sube_kodu(5),
             karsi_hesap_no(18),
             satici_no(10),
             alici_adi(40),
             adres(40),
             telefon(20),
             baba_adi(30),
             aciklama(40),
             referans(16),
             parametre(40),
             tutar(18),
             para_birimi(5),
             islem_tarihi(8),
             islem_kodu(2),
             durum_kodu(2),
             gonderen_iban(26),
             alici_iban(26),
             islem_tipi(1),
           END OF ty_detail.

    TYPES: BEGIN OF ty_footer,
             kayit_tipi(1),
             tpl_kayit(5),
           END OF ty_footer.

    DATA: ls_line(1000)        TYPE c,
          ls_header            TYPE ty_header,
          ls_detail            TYPE ty_detail,
          ls_footer            TYPE ty_footer,
          lv_paymentamount(18) TYPE c.
    DATA(lv_system_date) = cl_abap_context_info=>get_system_date(  ).
**********************************************************************
*Başlık
    ls_header = VALUE #( kayit_tipi = 'B'
                         firma_kodu = space
                         dosya_tarihi = |{ lv_system_date+6(2) }{ lv_system_date+4(2) }{ lv_system_date+0(4) }| ).

    CLEAR: ls_line.
    REPLACE SECTION OFFSET 0  LENGTH 1  OF ls_line WITH ls_header-kayit_tipi."*-&Kayıt Tipi
    REPLACE SECTION OFFSET 1  LENGTH 15 OF ls_line WITH ls_header-firma_kodu."*-&Ürün Referans Kodu
    REPLACE SECTION OFFSET 16 LENGTH 8  OF ls_line WITH ls_header-dosya_tarihi."*-&Dosya Tarihi
    APPEND INITIAL LINE TO rt_bank_file ASSIGNING FIELD-SYMBOL(<ls_bank_file>).
    <ls_bank_file> = ls_line.
**********************************************************************
*Kalemler
    LOOP AT mt_bank_file INTO DATA(ls_bank_file).
      lv_paymentamount = ls_bank_file-paymentamount. TRANSLATE lv_paymentamount  USING '.,'. SHIFT lv_paymentamount RIGHT DELETING TRAILING space. TRANSLATE lv_paymentamount USING ' 0'.
      ls_detail = VALUE #(
      kayit_tipi = 'D'
      banka_kodu = ls_bank_file-companybankinternalid(4)
      sube_kodu = ls_bank_file-companybankinternalid+5(5)
      hesap_no = ls_bank_file-companybankaccount
      fark_sube_kodu = space
      fark_hesap_no = space
      karsi_banka_kodu = ls_bank_file-iban(4)
      karsi_sube_kodu = ls_bank_file-iban+4(5)
      karsi_hesap_no = ls_bank_file-iban+10(16)
      satici_no = COND #( WHEN ls_bank_file-supplier IS INITIAL THEN ls_bank_file-customer ELSE ls_bank_file-supplier )
      alici_adi = COND #( WHEN ls_bank_file-suppliername IS INITIAL THEN ls_bank_file-customername ELSE ls_bank_file-suppliername )
      adres = space
      telefon = space
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
      gonderen_iban = ls_bank_file-companyiban
      alici_iban = ls_bank_file-iban
      islem_tipi = |D|  ).

      CLEAR: ls_line.
      REPLACE SECTION OFFSET 0   LENGTH 1  OF ls_line WITH ls_detail-kayit_tipi."Kayıt Tipi *
      REPLACE SECTION OFFSET 1   LENGTH 4  OF ls_line WITH ls_detail-banka_kodu."Banka Kodu *
      REPLACE SECTION OFFSET 5   LENGTH 5  OF ls_line WITH ls_detail-sube_kodu."Şube Kodu *
      REPLACE SECTION OFFSET 10  LENGTH 18 OF ls_line WITH ls_detail-hesap_no."Hesap No *
      REPLACE SECTION OFFSET 28  LENGTH 5  OF ls_line WITH ls_detail-fark_sube_kodu."Fark Şube Kodu
      REPLACE SECTION OFFSET 33  LENGTH 18 OF ls_line WITH ls_detail-fark_hesap_no."Fark Hesap No
      REPLACE SECTION OFFSET 51  LENGTH 4  OF ls_line WITH ls_detail-karsi_banka_kodu."Karşı Banka Kodu
      REPLACE SECTION OFFSET 55  LENGTH 5  OF ls_line WITH ls_detail-karsi_sube_kodu."Karşı Şube Kodu *
      REPLACE SECTION OFFSET 60  LENGTH 18 OF ls_line WITH ls_detail-karsi_hesap_no."Karşı Hesap No *
      REPLACE SECTION OFFSET 78  LENGTH 10 OF ls_line WITH ls_detail-satici_no."Satıcı/Müşteri No
      REPLACE SECTION OFFSET 88  LENGTH 40 OF ls_line WITH ls_detail-alici_adi."Alıcı Adı *
      REPLACE SECTION OFFSET 128 LENGTH 40 OF ls_line WITH ls_detail-adres."Adres
      REPLACE SECTION OFFSET 168 LENGTH 20 OF ls_line WITH ls_detail-telefon."Telefon
      REPLACE SECTION OFFSET 188 LENGTH 30 OF ls_line WITH ls_detail-baba_adi."Baba Adı
      REPLACE SECTION OFFSET 218 LENGTH 40 OF ls_line WITH ls_detail-aciklama."Açıklama *
      REPLACE SECTION OFFSET 258 LENGTH 16 OF ls_line WITH ls_detail-referans."Referans
      REPLACE SECTION OFFSET 274 LENGTH 40 OF ls_line WITH ls_detail-parametre."Parametre
      REPLACE SECTION OFFSET 314 LENGTH 18 OF ls_line WITH ls_detail-tutar."Tutar *
      REPLACE SECTION OFFSET 332 LENGTH 5  OF ls_line WITH ls_detail-para_birimi."Para Birimi *
      REPLACE SECTION OFFSET 337 LENGTH 8  OF ls_line WITH ls_detail-islem_tarihi."İşlem Tarihi *
      REPLACE SECTION OFFSET 345 LENGTH 2  OF ls_line WITH ls_detail-islem_kodu."İşlem Kodu
      REPLACE SECTION OFFSET 347 LENGTH 2  OF ls_line WITH ls_detail-durum_kodu."Durum Kodu
      REPLACE SECTION OFFSET 349 LENGTH 26 OF ls_line WITH ls_detail-gonderen_iban."Gönderen  IBAN
      REPLACE SECTION OFFSET 375 LENGTH 26 OF ls_line WITH ls_detail-alici_iban."Gönderen  IBAN
      REPLACE SECTION OFFSET 401 LENGTH 1  OF ls_line WITH ls_detail-islem_tipi."İşlem Tipi *

      APPEND INITIAL LINE TO rt_bank_file ASSIGNING <ls_bank_file>.
      <ls_bank_file> = ls_line.

    ENDLOOP.
**********************************************************************
*Foooter
    ls_footer = VALUE #( kayit_tipi = |T|
                         tpl_kayit = CONV numc5( |{ |{ lines( mt_bank_file ) }| ALPHA = IN }| ) ).

    REPLACE SECTION OFFSET 0 LENGTH 1 OF ls_line WITH ls_footer-kayit_tipi."*-&Kayıt Tipi
    REPLACE SECTION OFFSET 1 LENGTH 5 OF ls_line WITH ls_footer-tpl_kayit."*-&Toplam Kayıt Sayısı
    APPEND INITIAL LINE TO rt_bank_file ASSIGNING <ls_bank_file>.
    <ls_bank_file> = ls_line.
  ENDMETHOD.