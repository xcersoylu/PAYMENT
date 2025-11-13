  METHOD file_0012.
    TYPES: BEGIN OF ty_header,
             musteri_no(8),
             borclu_sube_kodu(4),
             borclu_hesap(26),
             dosya_aciklama(300),
             e_posta(100),
           END OF ty_header.

    TYPES: BEGIN OF ty_detail,
             odeme_tarihi(8),
             alici_banka_kodu(5),
             alici_sube_kodu(5),
             alici_hesap(16),
             alici_iban(26),
             alici_unvan(50),
             tutar(18),
             odeme_turu(2),
             aciklama(750),
           END OF ty_detail.

    DATA: ls_line(1000) TYPE c,
          ls_header     TYPE ty_header,
          ls_detail     TYPE ty_detail.

    CONSTANTS: lc_newline TYPE c VALUE cl_abap_char_utilities=>newline.

    DATA(lv_system_date) = cl_abap_context_info=>get_system_date(  ).
    ls_header-musteri_no = ms_urfcode-mbb.
    SHIFT ls_header-musteri_no RIGHT DELETING TRAILING space. TRANSLATE ls_header-musteri_no USING ' 0'.
    ls_header-borclu_sube_kodu =  VALUE #( mt_bank_file[ 1 ]-companybankinternalid+5(5) OPTIONAL ).
    SHIFT ls_header-borclu_sube_kodu RIGHT DELETING TRAILING space. TRANSLATE ls_header-borclu_sube_kodu USING ' 0'.
    ls_header-borclu_hesap     =  COND #( WHEN VALUE #( mt_bank_file[ 1 ]-companyiban OPTIONAL ) IS NOT INITIAL
                                    THEN VALUE #( mt_bank_file[ 1 ]-companyiban OPTIONAL )
                                    ELSE VALUE #( mt_bank_file[ 1 ]-companybankaccount OPTIONAL ) ).
    SHIFT ls_header-borclu_hesap RIGHT DELETING TRAILING space. TRANSLATE ls_header-borclu_hesap USING ' 0'.
    ls_header-dosya_aciklama   = |TOS-Havale|.

    CLEAR: ls_line.
    REPLACE SECTION OFFSET 0  LENGTH 8   OF ls_line WITH ls_header-musteri_no.
    IF mt_bank_file[ 1 ]-companyiban IS NOT INITIAL.
      REPLACE SECTION OFFSET 8 LENGTH 26  OF ls_line WITH ls_header-borclu_hesap.
    ELSE.
      REPLACE SECTION OFFSET 8  LENGTH 4   OF ls_line WITH ls_header-borclu_sube_kodu.
      REPLACE SECTION OFFSET 12 LENGTH 22  OF ls_line WITH ls_header-borclu_hesap+4(*).
    ENDIF.
    REPLACE SECTION OFFSET 34 LENGTH 300 OF ls_line WITH ls_header-dosya_aciklama.
    REPLACE SECTION OFFSET 334 LENGTH 100 OF ls_line WITH ls_header-e_posta.
    REPLACE SECTION OFFSET 434 LENGTH 1 OF ls_line WITH lc_newline.

    APPEND INITIAL LINE TO rt_bank_file ASSIGNING FIELD-SYMBOL(<ls_bank_file>).
    <ls_bank_file> = ls_line.


    LOOP AT mt_bank_file INTO DATA(ls_bank_file).
      CLEAR: ls_detail.
      ls_detail-odeme_tarihi     = lv_system_date.
      ls_detail-alici_banka_kodu = ls_bank_file-banknumber(4).
*      UNPACK ls_bank_file-banknumber TO ls_detail-alici_banka_kodu. "FIX_IT
      ls_detail-alici_sube_kodu  = ls_bank_file-banknumber+5(5).
      ls_detail-alici_hesap      =  ls_bank_file-bankaccount.
      SHIFT ls_detail-alici_hesap RIGHT DELETING TRAILING space. TRANSLATE ls_detail-alici_hesap USING ' 0'.
      ls_detail-alici_unvan      = COND #( WHEN ls_bank_file-customername IS NOT INITIAL THEN ls_bank_file-customername ELSE ls_bank_file-suppliername ).
      ls_detail-tutar            = ls_bank_file-paymentamount.
      TRANSLATE ls_detail-tutar  USING '.,'.SHIFT ls_detail-tutar RIGHT DELETING TRAILING space. TRANSLATE ls_detail-tutar USING ' 0'.
      ls_detail-odeme_turu       = |99|.
      ls_detail-aciklama =  COND #( WHEN ls_bank_file-accountingdocument IS NOT INITIAL
                                     THEN |{ ls_bank_file-companycode }{ ls_bank_file-accountingdocument }{ ls_bank_file-accountingdocumetitem }{ ls_bank_file-fiscalyear }|
                                     WHEN ls_bank_file-purchaseorder IS NOT INITIAL THEN |{ ls_bank_file-companycode }{ ls_bank_file-purchaseorder }{ ls_bank_file-purchaseorderitem } |
                                              ELSE |{ ls_bank_file-companycode }{ ls_bank_file-paymentnumber }{ ls_bank_file-paymentamount }{ ls_bank_file-purchaseorderitem } | ).

      ls_detail-alici_iban     =  ls_bank_file-iban.
      CONDENSE ls_detail-aciklama.
      CLEAR: ls_line.
      REPLACE SECTION OFFSET 0   LENGTH 8   OF ls_line WITH ls_detail-odeme_tarihi.
      IF ls_detail-alici_iban IS NOT INITIAL.
        REPLACE SECTION OFFSET 8 LENGTH 26  OF ls_line WITH ls_detail-alici_iban.
      ELSE.
        REPLACE SECTION OFFSET 8   LENGTH 5   OF ls_line WITH ls_detail-alici_banka_kodu.
        REPLACE SECTION OFFSET 13  LENGTH 5   OF ls_line WITH ls_detail-alici_sube_kodu.
        REPLACE SECTION OFFSET 18  LENGTH 16  OF ls_line WITH ls_detail-alici_hesap.
      ENDIF.
      REPLACE SECTION OFFSET 34  LENGTH 50  OF ls_line WITH ls_detail-alici_unvan.
      REPLACE SECTION OFFSET 84  LENGTH 18  OF ls_line WITH ls_detail-tutar.
      REPLACE SECTION OFFSET 102 LENGTH 2   OF ls_line WITH ls_detail-odeme_turu.
      REPLACE SECTION OFFSET 104 LENGTH 51 OF ls_line WITH ls_bank_file-receiptexplanation.
      REPLACE SECTION OFFSET 155 LENGTH 699 OF ls_line WITH ls_detail-aciklama.
      REPLACE SECTION OFFSET 854 LENGTH 1  OF ls_line  WITH lc_newline.

      APPEND INITIAL LINE TO rt_bank_file ASSIGNING <ls_bank_file>.
      <ls_bank_file> = ls_line.
    ENDLOOP.

  ENDMETHOD.