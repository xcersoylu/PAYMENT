  METHOD file_0046_fc.
    TYPES: BEGIN OF ty_header,
             kayit_tipi(1),
             urun_ref_kodu(7),
             dosya_tarihi(8),
             dosya_saati(6),
           END OF ty_header.

    TYPES: BEGIN OF ty_detail,
             urun_ref_kodu(7),
             kayit_tipi(1),
             odeme_turu(2),
             referans(16),
             tutar(17),
             talimat_tarihi(8),
             islem_tarihi(8),
             valor_tarihi(8),
             borclu_iban(26),
             swift(11),
             banka_adi(35),
             banka_adres(105),
             lehdar_iban(34),
             lehdar_isim(35),
             para_birimi(3),
             ekstre_aciklama(80),
             genel_aciklama(210),
             muhabir_masrafı(3),
             mbb_no(10),
             masraf_komisyon_hesap(26),
             ozel_alan(100),
             durum_kodu(2),
           END OF ty_detail.

    TYPES: BEGIN OF ty_footer,
             urun_ref_kodu(7),
             kayit_tipi(1),
             tpl_kayıt(5),
           END OF ty_footer.

    DATA: ls_line(3000)        TYPE c,
          ls_header            TYPE ty_header,
          ls_detail            TYPE ty_detail,
          ls_footer            TYPE ty_footer,
          lv_paymentamount(18).
    DATA(lv_system_date) = cl_abap_context_info=>get_system_date(  ).
    DATA(lv_system_time) = cl_abap_context_info=>get_system_time(  ).
    CLEAR: ls_header.
    ls_header-kayit_tipi = |H|.
    ls_header-urun_ref_kodu = ms_urfcode-firm_code.
    ls_header-dosya_tarihi = lv_system_date.
    ls_header-dosya_saati  = lv_system_time.

    CLEAR: ls_line.
    REPLACE SECTION OFFSET 0  LENGTH 7 OF ls_line WITH ls_header-urun_ref_kodu.
    REPLACE SECTION OFFSET 7  LENGTH 1 OF ls_line WITH ls_header-kayit_tipi.
    REPLACE SECTION OFFSET 8  LENGTH 8 OF ls_line WITH ls_header-dosya_tarihi.
    REPLACE SECTION OFFSET 16 LENGTH 6 OF ls_line WITH ls_header-dosya_saati.
    APPEND INITIAL LINE TO rt_bank_file ASSIGNING FIELD-SYMBOL(<ls_bank_file>).
    <ls_bank_file> = ls_line.

    LOOP AT mt_bank_file INTO DATA(ls_bank_file).
      lv_paymentamount = ls_bank_file-paymentamount.
      REPLACE '.' IN ls_detail-tutar WITH space.
      CONDENSE ls_detail-tutar.
      SHIFT ls_detail-tutar RIGHT DELETING TRAILING space.
      TRANSLATE ls_detail-tutar USING ' 0'.
      CLEAR: ls_detail.
      ls_detail-urun_ref_kodu = ms_urfcode-firm_code.
      ls_detail-kayit_tipi = |D|.
      ls_detail-odeme_turu = |DT|.
      ls_detail-referans = ls_bank_file-documentreferenceid.
      ls_detail-tutar = lv_paymentamount.
      ls_detail-talimat_tarihi = lv_system_date.
      ls_detail-islem_tarihi = lv_system_date.
      ls_detail-valor_tarihi = lv_system_date.
      ls_detail-borclu_iban = ls_bank_file-companyiban.
      ls_detail-swift = ls_bank_file-companyswiftcode.
*      ls_detail-banka_adi = COND #( WHEN ls_detail-swift IS INITIAL THEN ls_bank_file-banka ELSE space ).
*      ls_detail-banka_adres = COND #( WHEN ls_detail-swift IS INITIAL THEN ls_bank_file-bank_stras ELSE space ).
      ls_detail-lehdar_iban = ls_bank_file-iban.
      ls_detail-lehdar_isim = COND #( WHEN ls_bank_file-suppliername IS INITIAL THEN ls_bank_file-customername ELSE ls_bank_file-suppliername ).
      ls_detail-para_birimi = ls_bank_file-transactioncurrency.
      ls_detail-ekstre_acıklama = COND #( WHEN ls_bank_file-receiptexplanation IS NOT INITIAL THEN ls_bank_file-receiptexplanation ELSE |TOS-Havale| ).
      ls_detail-genel_acıklama = COND #( WHEN ls_bank_file-receiptexplanation IS NOT INITIAL THEN ls_bank_file-receiptexplanation ELSE |TOS-Havale| ).
      ls_detail-muhabir_masrafi  = |OUR|.
      ls_detail-mbb_no  = ms_urfcode-mbb.
      ls_detail-masraf_komisyon_hesap  = ls_bank_file-companyiban.
      ls_detail-ozel_alan  = COND #( WHEN ls_bank_file-accountingdocument IS NOT INITIAL
                                THEN |{ ls_bank_file-companycode }{ ls_bank_file-accountingdocument }{ ls_bank_file-accountingdocumetitem }{ ls_bank_file-fiscalyear }|
                                WHEN ls_bank_file-purchaseorder IS NOT INITIAL THEN |{ ls_bank_file-companycode }{ ls_bank_file-purchaseorder }{ ls_bank_file-purchaseorderitem } |
                                         ELSE |{ ls_bank_file-companycode }{ ls_bank_file-paymentnumber }{ ls_bank_file-paymentamount }{ ls_bank_file-purchaseorderitem } | ).
      ls_detail-durum_kodu = |00|.

      CLEAR: ls_line.
      REPLACE SECTION OFFSET 0    LENGTH 7   OF ls_line WITH ls_detail-urun_ref_kodu.
      REPLACE SECTION OFFSET 7    LENGTH 1   OF ls_line WITH ls_detail-kayit_tipi.
      REPLACE SECTION OFFSET 8    LENGTH 2   OF ls_line WITH ls_detail-odeme_turu.
      REPLACE SECTION OFFSET 10   LENGTH 16  OF ls_line WITH ls_detail-referans.
      REPLACE SECTION OFFSET 42   LENGTH 17  OF ls_line WITH ls_detail-tutar.
      REPLACE SECTION OFFSET 59   LENGTH 8   OF ls_line WITH ls_detail-talimat_tarihi.
      REPLACE SECTION OFFSET 67   LENGTH 8   OF ls_line WITH ls_detail-islem_tarihi.
      REPLACE SECTION OFFSET 75   LENGTH 8   OF ls_line WITH ls_detail-valor_tarihi.
      REPLACE SECTION OFFSET 83   LENGTH 26  OF ls_line WITH ls_detail-borclu_iban.
      REPLACE SECTION OFFSET 109  LENGTH 11  OF ls_line WITH ls_detail-swift.
      REPLACE SECTION OFFSET 120  LENGTH 35  OF ls_line WITH ls_detail-banka_adi.
      REPLACE SECTION OFFSET 155  LENGTH 105 OF ls_line WITH ls_detail-banka_adres.
      REPLACE SECTION OFFSET 260  LENGTH 34  OF ls_line WITH ls_detail-lehdar_iban.
      REPLACE SECTION OFFSET 294  LENGTH 35  OF ls_line WITH ls_detail-lehdar_isim.
      REPLACE SECTION OFFSET 434  LENGTH 3   OF ls_line WITH ls_detail-para_birimi.
      REPLACE SECTION OFFSET 437  LENGTH 80  OF ls_line WITH ls_detail-ekstre_aciklama.
      REPLACE SECTION OFFSET 517  LENGTH 210 OF ls_line WITH ls_detail-genel_aciklama.
      REPLACE SECTION OFFSET 727  LENGTH 3   OF ls_line WITH ls_detail-muhabir_masrafi.
      REPLACE SECTION OFFSET 2416 LENGTH 10  OF ls_line WITH ls_detail-mbb_no."2396
      REPLACE SECTION OFFSET 2480 LENGTH 26  OF ls_line WITH ls_detail-masraf_komisyon_hesap.
      REPLACE SECTION OFFSET 2533 LENGTH 100 OF ls_line WITH ls_detail-ozel_alan.
      REPLACE SECTION OFFSET 2633 LENGTH 2   OF ls_line WITH ls_detail-durum_kodu.
      REPLACE SECTION OFFSET 2635 LENGTH 306 OF ls_line WITH ''.

      APPEND INITIAL LINE TO rt_bank_file ASSIGNING <ls_bank_file>.
      <ls_bank_file> = ls_line.
    ENDLOOP.

*--------------------------------------------------------------------*
*-&STEP -3: Sayfa Sonu Verilerinin Doldurulması->
*--------------------------------------------------------------------*
    CLEAR: ls_footer.
    ls_footer-urun_ref_kodu = ms_urfcode-firm_code.
    ls_footer-kayit_tipi = |F|.
    ls_footer-tpl_kayit = CONV numc5( |{ |{ lines( mt_bank_file ) }| ALPHA = IN }| ).


    CLEAR: ls_line.
    REPLACE SECTION OFFSET 0 LENGTH 7 OF ls_line WITH ls_footer-urun_ref_kodu.
    REPLACE SECTION OFFSET 7 LENGTH 1 OF ls_line WITH ls_footer-kayit_tipi.
    REPLACE SECTION OFFSET 8 LENGTH 5 OF ls_line WITH ls_footer-tpl_kayit.
*    REPLACE SECTION OFFSET 13 LENGTH 2 OF l_line WITH lc_cr_lf.
    APPEND INITIAL LINE TO rt_bank_file ASSIGNING <ls_bank_file>.
    <ls_bank_file> = ls_line.

  ENDMETHOD.