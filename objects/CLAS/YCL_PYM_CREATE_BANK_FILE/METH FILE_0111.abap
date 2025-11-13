  METHOD file_0111.
    TYPES: BEGIN OF ty_detail,
             kb_kodu(4),
             kb_sube_kodu(5),
             kb_hesap_no(26),
             islem_tarihi_gun(2),
             islem_tarihi_ay(2),
             islem_tarihi_yil(4),
             tutar(15),
             unvan(30),
             aciklama(100),
             odeme_turu(2),
             cikis_hesap(10),
             doviz_kodu(3),
             hata_kodu(2),
             sorgu_no(7),
             mail(50),
           END OF ty_detail.

    DATA: ls_line(1000)        TYPE c,
          ls_detail            TYPE ty_detail,
          lv_paymentamount(18),
          lv_space_length      TYPE i.
    DATA(lv_system_date) = cl_abap_context_info=>get_system_date(  ).
    DATA(lv_space) = get_space_character(  ).
    LOOP AT mt_bank_file INTO DATA(ls_bank_file).
      lv_paymentamount = ls_bank_file-paymentamount.
      SHIFT lv_paymentamount RIGHT DELETING TRAILING space. TRANSLATE ls_detail-tutar USING ' 0'.
      ls_detail = VALUE #( kb_kodu        = ls_bank_file-banknumber
                         kb_sube_kodu     = ls_bank_file-bankbranch
                         kb_hesap_no      = ls_bank_file-bankaccount
                         islem_tarihi_gun = lv_system_date+6(2)
                         islem_tarihi_ay  = lv_system_date+4(2)
                         islem_tarihi_yil = lv_system_date+0(4)
                         tutar            = lv_paymentamount
                         unvan            = COND #( WHEN ls_bank_file-suppliername IS INITIAL THEN ls_bank_file-customername ELSE ls_bank_file-suppliername )
              aciklama =  COND #( WHEN ls_bank_file-accountingdocument IS NOT INITIAL
                                   THEN |{ ls_bank_file-companycode }{ ls_bank_file-accountingdocument }{ ls_bank_file-accountingdocumetitem }{ ls_bank_file-fiscalyear }|
                                   WHEN ls_bank_file-purchaseorder IS NOT INITIAL THEN |{ ls_bank_file-companycode }{ ls_bank_file-purchaseorder }{ ls_bank_file-purchaseorderitem } |
                                            ELSE |{ ls_bank_file-companycode }{ ls_bank_file-paymentnumber }{ ls_bank_file-paymentamount }{ ls_bank_file-purchaseorderitem } | )
                         odeme_turu       = |99|
                         cikis_hesap      = ls_bank_file-companybankaccount
                         doviz_kodu       = ls_bank_file-transactioncurrency
                         hata_kodu        = |00|
                         sorgu_no         = |0000000|
                         mail             = space
      ).
      CONDENSE ls_detail-aciklama.
      CLEAR: ls_line.
      IF ls_bank_file-iban IS  INITIAL .
        REPLACE SECTION OFFSET 21  LENGTH 4   OF ls_line WITH ls_detail-kb_kodu.
        REPLACE SECTION OFFSET 26  LENGTH 5   OF ls_line WITH ls_detail-kb_sube_kodu.
        REPLACE SECTION OFFSET 31  LENGTH 26  OF ls_line WITH ls_detail-kb_hesap_no.
      ELSE.
        REPLACE SECTION OFFSET 31  LENGTH 26 OF ls_line WITH ls_bank_file-iban.
      ENDIF.
      REPLACE SECTION OFFSET 57  LENGTH 2   OF ls_line WITH ls_detail-islem_tarihi_gun.
      REPLACE SECTION OFFSET 60  LENGTH 2   OF ls_line WITH ls_detail-islem_tarihi_ay.
      REPLACE SECTION OFFSET 63  LENGTH 4   OF ls_line WITH ls_detail-islem_tarihi_yil.
      REPLACE SECTION OFFSET 67  LENGTH 15  OF ls_line WITH ls_detail-tutar.
      REPLACE SECTION OFFSET 82  LENGTH 30  OF ls_line WITH ls_detail-unvan.
      REPLACE SECTION OFFSET 112 LENGTH 51  OF ls_line WITH ls_bank_file-receiptexplanation.
      REPLACE SECTION OFFSET 163 LENGTH 49  OF ls_line WITH ls_detail-aciklama.
      REPLACE SECTION OFFSET 212 LENGTH 2   OF ls_line WITH ls_detail-odeme_turu.
      REPLACE SECTION OFFSET 245 LENGTH 10  OF ls_line WITH ls_detail-cikis_hesap.
      REPLACE SECTION OFFSET 255 LENGTH 3   OF ls_line WITH ls_detail-doviz_kodu.
      REPLACE SECTION OFFSET 258 LENGTH 2   OF ls_line WITH ls_detail-hata_kodu.
      REPLACE SECTION OFFSET 260 LENGTH 7   OF ls_line WITH ls_detail-sorgu_no.
      REPLACE SECTION OFFSET 267 LENGTH 50  OF ls_line WITH ls_detail-mail.

*      DATA lv_spaces TYPE i.
*      DATA: g_space TYPE string.
*      CONSTANTS: c_space TYPE syhex02 VALUE '00a0'.
*
*      g_space = cl_abap_conv_in_ce=>uccp( c_space ).
*      lv_spaces = 317 - strlen( l_line ).
*
*      DO lv_spaces TIMES.
*        CONCATENATE l_line g_space INTO l_line.
*      ENDDO.
      lv_space_length = 317 - strlen( ls_line ).
      IF lv_space_length > 0.
        DO lv_space_length TIMES.
          CONCATENATE ls_line lv_space INTO ls_line.
        ENDDO.
      ENDIF.

      APPEND INITIAL LINE TO rt_bank_file ASSIGNING FIELD-SYMBOL(<ls_bank_file>).
      <ls_bank_file> = ls_line.

    ENDLOOP.

  ENDMETHOD.