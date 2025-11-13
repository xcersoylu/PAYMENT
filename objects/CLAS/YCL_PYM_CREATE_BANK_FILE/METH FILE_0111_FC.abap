  METHOD file_0111_fc.
    TYPES: BEGIN OF ty_detail,
             banka_swift(11),
             tutar(15),
             firma_referans(16),
             talimat_tarihi(8),
             islem_tarihi(8),
             valor(8),
             borclu_sube(5),
             borclu_hesap(10),
             borclu_iban(26),
             ab_swift(11),
             ab_adi(35),
             ab_adres(105),
             alacakli_hesap(34),
             alacakli_isim(35),
             alacakli_adres(105),
             doviz_kodu(3),
             ekstre_aciklama(70),
             islem_turu(1),
             islem_detayi(2),
             masraf(3),
             islem_kodu(2),
             iban_kodu(34),
             masraf_sube(5),
             masraf_hesap(10),
             masraf_iban(26),
             lehdar_ulke(2),
             akibet_kodu(10),
           END OF ty_detail.

    DATA: ls_line(2000)        TYPE c,
          ls_detail            TYPE ty_detail,
          lv_paymentamount(18).
    DATA(lv_space) = get_space_character(  ).
    DATA(lv_system_date) = cl_abap_context_info=>get_system_date(  ).
    "TODO : stras
    LOOP AT mt_bank_file INTO DATA(ls_bank_file).
      lv_paymentamount = ls_bank_file-paymentamount.
      TRANSLATE lv_paymentamount  USING '. '.CONDENSE lv_paymentamount NO-GAPS.
      SHIFT lv_paymentamount RIGHT DELETING TRAILING space. TRANSLATE lv_paymentamount USING ' 0'.
      CLEAR: ls_detail.
      ls_detail-tutar           = lv_paymentamount.
      ls_detail-firma_referans  = ls_bank_file-documentreferenceid.
      ls_detail-talimat_tarihi  = lv_system_date.
      ls_detail-islem_tarihi    = lv_system_date.
      ls_detail-valor           = lv_system_date.
      ls_detail-borclu_sube     = ls_bank_file-companybankinternalid+5(5).
      ls_detail-borclu_hesap    = ls_bank_file-companybankaccount.
      ls_detail-borclu_iban     = ls_bank_file-companyiban.
      ls_detail-ab_swift        = ls_bank_file-swiftcode.
      ls_detail-ab_adi          = ls_bank_file-bankname.
*      ls_detail-ab_adres        = ls_bank_file-bank_stras.
      ls_detail-alacakli_hesap  = ls_bank_file-bankaccount.
      ls_detail-alacakli_isim   = COND #( WHEN ls_bank_file-suppliername IS INITIAL THEN ls_bank_file-customername ELSE ls_bank_file-suppliername ).
*      ls_detail-alacakli_adres  = ls_bank_file-stras.
      ls_detail-doviz_kodu      = ls_bank_file-transactioncurrency.
      ls_detail-ekstre_aciklama = COND #( WHEN ls_bank_file-accountingdocument IS NOT INITIAL
                                THEN |{ ls_bank_file-companycode }{ ls_bank_file-accountingdocument }{ ls_bank_file-accountingdocumetitem }{ ls_bank_file-fiscalyear }|
                                WHEN ls_bank_file-purchaseorder IS NOT INITIAL THEN |{ ls_bank_file-companycode }{ ls_bank_file-purchaseorder }{ ls_bank_file-purchaseorderitem } |
                                         ELSE |{ ls_bank_file-companycode }{ ls_bank_file-paymentnumber }{ ls_bank_file-paymentamount }{ ls_bank_file-purchaseorderitem } | ).
      ls_detail-islem_turu      = |D|.
      ls_detail-islem_detayi    = |60|.
      ls_detail-masraf          = |OUR|.
      ls_detail-islem_kodu      = |00|.
      ls_detail-iban_kodu       = ls_bank_file-companyiban.

      CLEAR: ls_line.
      REPLACE SECTION OFFSET 0    LENGTH 11  OF ls_line WITH ls_detail-banka_swift.
      REPLACE SECTION OFFSET 11   LENGTH 15  OF ls_line WITH ls_detail-tutar.
      REPLACE SECTION OFFSET 26   LENGTH 16  OF ls_line WITH ls_detail-firma_referans.
      REPLACE SECTION OFFSET 58   LENGTH 8   OF ls_line WITH ls_detail-talimat_tarihi.
      REPLACE SECTION OFFSET 66   LENGTH 8   OF ls_line WITH ls_detail-islem_tarihi.
      REPLACE SECTION OFFSET 74   LENGTH 8   OF ls_line WITH ls_detail-valor.
      REPLACE SECTION OFFSET 82   LENGTH 5   OF ls_line WITH ls_detail-borclu_sube.
      REPLACE SECTION OFFSET 87   LENGTH 10  OF ls_line WITH ls_detail-borclu_hesap.
      REPLACE SECTION OFFSET 97   LENGTH 26  OF ls_line WITH ls_detail-borclu_iban.
      REPLACE SECTION OFFSET 123  LENGTH 11  OF ls_line WITH ls_detail-ab_swift.
      REPLACE SECTION OFFSET 134  LENGTH 35  OF ls_line WITH ls_detail-ab_adi.
      REPLACE SECTION OFFSET 169  LENGTH 105 OF ls_line WITH ls_detail-ab_adres.
      REPLACE SECTION OFFSET 274  LENGTH 34  OF ls_line WITH ls_detail-alacakli_hesap.
      REPLACE SECTION OFFSET 308  LENGTH 35  OF ls_line WITH ls_detail-alacakli_isim.
      REPLACE SECTION OFFSET 343  LENGTH 105 OF ls_line WITH ls_detail-alacakli_adres.
      REPLACE SECTION OFFSET 448  LENGTH 3   OF ls_line WITH ls_detail-doviz_kodu.
      REPLACE SECTION OFFSET 451  LENGTH 31  OF ls_line WITH ls_bank_file-receiptexplanation.
      REPLACE SECTION OFFSET 482  LENGTH 39  OF ls_line WITH ls_detail-ekstre_aciklama.
      REPLACE SECTION OFFSET 731  LENGTH 1   OF ls_line WITH ls_detail-islem_turu.
      REPLACE SECTION OFFSET 732  LENGTH 2   OF ls_line WITH ls_detail-islem_detayi.
      REPLACE SECTION OFFSET 734  LENGTH 3   OF ls_line WITH ls_detail-masraf.
      REPLACE SECTION OFFSET 737  LENGTH 2   OF ls_line WITH ls_detail-islem_kodu.
      REPLACE SECTION OFFSET 739  LENGTH 34  OF ls_line WITH ls_detail-iban_kodu.
      REPLACE SECTION OFFSET 1039 LENGTH 5   OF ls_line WITH ls_detail-masraf_sube.
      REPLACE SECTION OFFSET 1044 LENGTH 10  OF ls_line WITH ls_detail-masraf_hesap.
      REPLACE SECTION OFFSET 1054 LENGTH 26  OF ls_line WITH ls_detail-masraf_iban.
      REPLACE SECTION OFFSET 1080 LENGTH 2   OF ls_line WITH ls_detail-lehdar_ulke.
      REPLACE SECTION OFFSET 1082 LENGTH 10  OF ls_line WITH ls_detail-akibet_kodu.

      DATA(lv_spaces_length) = 1092 - strlen( ls_line ).

      DO lv_spaces_length TIMES.
        CONCATENATE ls_line lv_space INTO ls_line.
      ENDDO.

      APPEND INITIAL LINE TO rt_bank_file ASSIGNING FIELD-SYMBOL(<ls_bank_file>).
      <ls_bank_file> = ls_line.
    ENDLOOP.

  ENDMETHOD.