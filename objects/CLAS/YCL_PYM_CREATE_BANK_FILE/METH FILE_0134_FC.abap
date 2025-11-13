  METHOD file_0134_fc.
    TYPES: BEGIN OF ty_header,
             kayit_tipi(1),
             dosya_referans(5),
             dosya_tarihi(8),
             dosya_no(6),
             dosya_akibet_tar(8),
             dosya_durum_kodu(2),
           END OF ty_header.

    TYPES: BEGIN OF ty_detail,
             kayit_tipi(1),
             musteri_ref(20),
             islem_turu(2),
             tutar(17),
             doviz_cinsi(3),
             borclu_sube(5),
             borclu_hesap(10),
             ek_no(3),
             valor_tarihi(8),
             masraf_turu(3),
             lehdar_hesap(34),
             lehdar_iban(35),
             lehdar_isim(60),
             swift_kodu(13),
             swift_aciklama(210),
             lehdar_ulke(2),
             on_akibet(2),
             odeme_akibet(2),
             borclu_iban(35),
             ozel_alan(45),
             odm_mahiyeti(5),
             aciklama(143),
           END OF ty_detail.

    TYPES: BEGIN OF ty_footer,
             kayit_tipi(1),
             tpl_kayıt(7),
           END OF ty_footer.

    DATA: ls_line(3000)        TYPE c,
          ls_header            TYPE ty_header,
          ls_detail            TYPE ty_detail,
          ls_footer            TYPE ty_footer,
          lv_paymentamount(18),
          lv_space_length      TYPE i.
    DATA(lv_system_date) = cl_abap_context_info=>get_system_date(  ).
    ls_header = VALUE #(  kayit_tipi       = |H|
                          dosya_referans   = |00000|
                          dosya_tarihi     = |{ lv_system_date+6(2) }{ lv_system_date+4(2) }{ lv_system_date+0(4) }|
                          dosya_no         = |000001|
                          dosya_akibet_tar = |{ lv_system_date+6(2) }{ lv_system_date+4(2) }{ lv_system_date+0(4) }|
                          dosya_durum_kodu = |00| ).

    CLEAR: ls_line.
    REPLACE SECTION OFFSET 0  LENGTH 1 OF ls_line WITH ls_header-kayit_tipi.
    REPLACE SECTION OFFSET 1  LENGTH 5 OF ls_line WITH ls_header-dosya_referans.
    REPLACE SECTION OFFSET 6  LENGTH 8 OF ls_line WITH ls_header-dosya_tarihi.
    REPLACE SECTION OFFSET 14 LENGTH 6 OF ls_line WITH ls_header-dosya_no.
    REPLACE SECTION OFFSET 20 LENGTH 8 OF ls_line WITH ls_header-dosya_akibet_tar.
    REPLACE SECTION OFFSET 28 LENGTH 2 OF ls_line WITH ls_header-dosya_durum_kodu.

    APPEND INITIAL LINE TO rt_bank_file ASSIGNING FIELD-SYMBOL(<ls_bank_file>).
    <ls_bank_file> = ls_line.
    DATA(lv_space) = get_space_character(  ).
    LOOP AT mt_bank_file INTO DATA(ls_bank_file).
      CLEAR: ls_detail.
      lv_paymentamount = ls_bank_file-paymentamount.
      TRANSLATE lv_paymentamount  USING '.,'.
      SHIFT lv_paymentamount RIGHT DELETING TRAILING space. TRANSLATE lv_paymentamount USING ' 0'.
      ls_detail-kayit_tipi   = |D|.
      ls_detail-musteri_ref  = space.
      IF ls_bank_file-banknumber(4) EQ '0134'.
        ls_detail-islem_turu   = |09|.
      ELSE.
        ls_detail-islem_turu   = |05|.
      ENDIF.
      ls_detail-tutar        = lv_paymentamount.
      ls_detail-doviz_cinsi  = ls_bank_file-transactioncurrency.
      ls_detail-borclu_sube  = space.
      ls_detail-borclu_hesap = space.
      ls_detail-ek_no        = space.
      ls_detail-valor_tarihi = |{ lv_system_date+6(2) }{ lv_system_date+4(2) }{ lv_system_date+0(4) }|.
      ls_detail-masraf_turu  = |OUR|.
      ls_detail-lehdar_hesap = COND #( WHEN ls_bank_file-iban IS NOT INITIAL THEN |{ space }|
                                       ELSE |{ ls_bank_file-bankaccount }| ).
      ls_detail-lehdar_iban    = ls_bank_file-iban.
      ls_detail-lehdar_isim    = COND #( WHEN ls_bank_file-suppliername IS INITIAL THEN ls_bank_file-customername ELSE ls_bank_file-suppliername ).
      IF ls_detail-lehdar_iban IS INITIAL .
        ls_detail-swift_kodu     = |{ ls_bank_file-swiftcode(4) }| & |-| & |{ ls_bank_file-swiftcode+4(2) }| & |-| & |{ ls_bank_file-swiftcode+6(5) }|.
      ENDIF.
      ls_detail-swift_aciklama =  ls_bank_file-receiptexplanation.
      ls_detail-lehdar_ulke    = ls_bank_file-bankcountrykey.
      ls_detail-on_akibet      = |00|.
      ls_detail-odeme_akibet   = |00|.
      ls_detail-borclu_iban    = ls_bank_file-companyiban.
      IF ls_detail-islem_turu  = '05'.
        ls_detail-odm_mahiyeti   = |00099|.
      ENDIF.
      IF ls_detail-islem_turu  = '05'.
        ls_detail-aciklama      = COND #( WHEN ls_bank_file-receiptexplanation IS NOT INITIAL THEN ls_bank_file-receiptexplanation
                                         ELSE COND #( WHEN ls_bank_file-suppliername IS INITIAL THEN ls_bank_file-customername ELSE ls_bank_file-suppliername ) ).
      ENDIF.
      ls_detail-ozel_alan     = COND #( WHEN ls_bank_file-accountingdocument IS NOT INITIAL
                               THEN |{ ls_bank_file-companycode }{ ls_bank_file-accountingdocument }{ ls_bank_file-accountingdocumetitem }{ ls_bank_file-fiscalyear }|
                               WHEN ls_bank_file-purchaseorder IS NOT INITIAL THEN |{ ls_bank_file-companycode }{ ls_bank_file-purchaseorder }{ ls_bank_file-purchaseorderitem } |
                                        ELSE |{ ls_bank_file-companycode }{ ls_bank_file-paymentnumber }{ ls_bank_file-paymentamount }{ ls_bank_file-purchaseorderitem } | ).


      CLEAR: ls_line.
      REPLACE SECTION OFFSET 0    LENGTH 1   OF ls_line WITH ls_detail-kayit_tipi.
      REPLACE SECTION OFFSET 1    LENGTH 20  OF ls_line WITH ls_detail-musteri_ref.
      REPLACE SECTION OFFSET 21   LENGTH 2   OF ls_line WITH ls_detail-islem_turu.
      REPLACE SECTION OFFSET 26   LENGTH 17  OF ls_line WITH ls_detail-tutar.
      REPLACE SECTION OFFSET 77   LENGTH 3   OF ls_line WITH ls_detail-doviz_cinsi.
      REPLACE SECTION OFFSET 80   LENGTH 5   OF ls_line WITH ls_detail-borclu_sube.
      REPLACE SECTION OFFSET 85   LENGTH 10  OF ls_line WITH ls_detail-borclu_hesap.
      REPLACE SECTION OFFSET 95   LENGTH 3   OF ls_line WITH ls_detail-ek_no.
      REPLACE SECTION OFFSET 98   LENGTH 8   OF ls_line WITH ls_detail-valor_tarihi.
      REPLACE SECTION OFFSET 106  LENGTH 3   OF ls_line WITH ls_detail-masraf_turu.
      REPLACE SECTION OFFSET 109  LENGTH 34  OF ls_line WITH ls_detail-lehdar_hesap.
      REPLACE SECTION OFFSET 143  LENGTH 35  OF ls_line WITH ls_detail-lehdar_iban.
      REPLACE SECTION OFFSET 178  LENGTH 60  OF ls_line WITH ls_detail-lehdar_isim.
      REPLACE SECTION OFFSET 238  LENGTH 13  OF ls_line WITH ls_detail-swift_kodu.
      REPLACE SECTION OFFSET 251  LENGTH 210 OF ls_line WITH ls_detail-swift_aciklama.
      REPLACE SECTION OFFSET 461  LENGTH 2   OF ls_line WITH ls_detail-lehdar_ulke.
      REPLACE SECTION OFFSET 1178 LENGTH 2   OF ls_line WITH ls_detail-on_akibet.
      REPLACE SECTION OFFSET 1180 LENGTH 2   OF ls_line WITH ls_detail-odeme_akibet.
      REPLACE SECTION OFFSET 1232 LENGTH 35  OF ls_line WITH ls_detail-borclu_iban.
      REPLACE SECTION OFFSET 1267 LENGTH 45  OF ls_line WITH ls_detail-ozel_alan.
      REPLACE SECTION OFFSET 1912 LENGTH 5   OF ls_line WITH ls_detail-odm_mahiyeti.
      REPLACE SECTION OFFSET 1925 LENGTH 143 OF ls_line WITH ls_detail-aciklama.
**----------------------------------------->>>>>
*      DATA lv_spaces TYPE i.
*      DATA: g_space TYPE string.
*      CONSTANTS: c_space TYPE syhex02 VALUE '00a0'.
*
*      g_space = cl_abap_conv_in_ce=>uccp( c_space ).
*      lv_spaces = 2068 - strlen( ls_line ).
*
*      DO lv_spaces TIMES.
*        CONCATENATE l_line g_space INTO ls_line.
*      ENDDO.
**-----------------

      lv_space_length = 2068 - strlen( ls_line ).
      IF lv_space_length > 0.
        DO lv_space_length TIMES.
          CONCATENATE ls_line lv_space INTO ls_line.
        ENDDO.
      ENDIF.

      APPEND INITIAL LINE TO rt_bank_file ASSIGNING <ls_bank_file>.
      <ls_bank_file> = ls_line.
    ENDLOOP.

    CLEAR: ls_footer.
    ls_footer-kayit_tipi = |T|.
    ls_footer-tpl_kayit = CONV char7( |{ |{ lines( mt_bank_file ) }| ALPHA = IN }| ).

    CLEAR: ls_line.
    REPLACE SECTION OFFSET 0 LENGTH 1 OF ls_line WITH ls_footer-kayit_tipi.
    REPLACE SECTION OFFSET 1 LENGTH 7 OF ls_line WITH ls_footer-tpl_kayit.
    APPEND INITIAL LINE TO rt_bank_file ASSIGNING <ls_bank_file>.
    <ls_bank_file> = ls_line.

  ENDMETHOD.