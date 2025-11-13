  METHOD file_0062.
    TYPES: BEGIN OF ty_header,
             kayit_tipi(1),
             firma_kodu(9),
             vergi_no(10),
             dosya_tarihi(8),
           END OF ty_header.

    TYPES: BEGIN OF ty_detail,
             kayit_tipi(1),
             banka_kodu(4),
             sube_kodu(5),
             hesap_no(18),
             dolgu(23),
             k_banka_kodu(4),
             k_sube_kodu(5),
             k_hesap_no(18),
             sat_mus_no(10),
             alıcı_adı(40),
             adres(40),
             telefon(20),
             baba_adı(30),
             acıklama(40),
             referans(16),
             parametre(40),
             tutar(18),
             para_birimi(5),
             islem_tarihi(8),
             islem_kodu(2),
             durum_kodu(2),
             vergi_no(10),
             tck_no(11),
             email(50),
             iban(26),
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

    CONSTANTS: lc_cr_lf   TYPE c VALUE cl_abap_char_utilities=>cr_lf,
               lc_newline TYPE c VALUE cl_abap_char_utilities=>newline.
    DATA(lv_system_date) = cl_abap_context_info=>get_system_date(  ).
**********************************************************************
*Başlık
    ls_header = VALUE #( kayit_tipi = 'B'
                         firma_kodu = ms_urfcode-firm_code
                         dosya_tarihi = |{ lv_system_date+6(2) }{ lv_system_date+4(2) }{ lv_system_date+0(4) }| ).

    CLEAR: ls_line.
    REPLACE SECTION OFFSET 0  LENGTH 1  OF ls_line WITH ls_header-kayit_tipi."*-&Kayıt Tipi
    REPLACE SECTION OFFSET 1  LENGTH 9  OF ls_line WITH ls_header-firma_kodu."*-&Ürün Referans Kodu
    REPLACE SECTION OFFSET 10 LENGTH 10 OF ls_line WITH ls_header-vergi_no."*-&Ürün Referans Kodu
    REPLACE SECTION OFFSET 20 LENGTH 8  OF ls_line WITH ls_header-dosya_tarihi."*-&Dosya Tarihi
    APPEND INITIAL LINE TO rt_bank_file ASSIGNING FIELD-SYMBOL(<ls_bank_file>).
    <ls_bank_file> = ls_line.
**********************************************************************
    LOOP AT mt_bank_file INTO DATA(ls_bank_file).
      lv_paymentamount = ls_bank_file-paymentamount. TRANSLATE lv_paymentamount  USING '.,'. SHIFT lv_paymentamount RIGHT DELETING TRAILING space. TRANSLATE lv_paymentamount USING ' 0'.
      ls_detail = VALUE #(  kayit_tipi = |D|
                            banka_kodu = ls_bank_file-companybankinternalid(4)
                            sube_kodu = ls_bank_file-companybankinternalid+5(5)
                            hesap_no = ls_bank_file-companybankaccount
                            dolgu = space
                            k_banka_kodu = COND #( WHEN ls_bank_file-iban <> space THEN ls_bank_file-iban(4) ELSE ls_bank_file-banknumber(4) )
                            k_sube_kodu = COND #( WHEN ls_bank_file-iban <> space THEN ls_bank_file-iban+4(5) ELSE ls_bank_file-banknumber+4(5) )
                            k_hesap_no =  COND #( WHEN ls_bank_file-iban <> space THEN ls_bank_file-iban+9(17) ELSE ls_bank_file-bankaccount )
                            sat_mus_no =  COND #( WHEN ls_bank_file-supplier IS INITIAL THEN ls_bank_file-customer ELSE ls_bank_file-supplier )
                            alıcı_adı = COND #( WHEN ls_bank_file-suppliername IS INITIAL THEN ls_bank_file-customername ELSE ls_bank_file-suppliername )
                            adres = space
                            telefon = space
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
           islem_kodu = |00|
           durum_kodu = |00|
      vergi_no = ls_bank_file-bptaxnumber
      tck_no = ls_bank_file-tckn
      iban = ls_bank_file-iban ).
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