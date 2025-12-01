  METHOD if_http_service_extension~handle_request.
    DATA lt_txt_file TYPE string_table.
    DATA ls_txt_file TYPE string.
    DATA lt_bank_file TYPE ypym_tt_bank_file_data.
    DATA lv_methodname TYPE string VALUE 'file_'.
    DATA(lv_request_body) = request->get_text( ).
    DATA(lv_get_method) = request->get_method( ).
    /ui2/cl_json=>deserialize( EXPORTING json = lv_request_body CHANGING data = ms_request ).

    LOOP AT ms_request-header INTO DATA(ls_header) GROUP BY ( companybankcode = ls_header-companybankcode
                                                              companyaccountcode = ls_header-companyaccountcode ).
      LOOP AT ms_request-items INTO DATA(ls_item) WHERE paymentnumber = ls_header-paymentnumber
                                                    AND companybankcode = ls_header-companybankcode
                                                    AND companyaccountcode = ls_header-companyaccountcode
                                                    AND transactioncurrency = ls_header-currency.
        APPEND VALUE #( paymentnumber         = ls_item-paymentnumber
                        paymentdate           = ls_item-paymentdate
                        customer              = ls_item-customer
                        customername          = ls_item-customername
                        companycode           = ls_item-companycode
                        accountingdocument    = ls_item-accountingdocument
                        fiscalyear            = ls_item-fiscalyear
                        accountingdocumetitem = ls_item-accountingdocumentitem
                        paymentamount         = ls_item-paymentamount
                        transactioncurrency   = ls_item-transactioncurrency
                        bankcountrykey        = ls_item-customerbankcountrykey
                        banknumber            = ls_item-customerbanknumber
                        bankaccount           = ls_item-customerbankaccount
                        iban                  = ls_item-customeriban
                        swiftcode             = ls_item-customerswiftcode
                        bankname              = ls_item-customerbankname
                        bankbranch            = ls_item-customerbankbranch
                        paymentexplanation    = ls_item-paymentexplanation
                        receiptexplanation    = ls_item-receiptexplanation
                        companybankcode       = ls_item-companybankcode
                        companyaccountcode    = ls_item-companyaccountcode
                        companyiban           = ls_item-companyiban
                        companybankinternalid = ls_item-companybankinternalid
                        companybankaccount    = ls_item-companybankaccount
                        bptaxnumber           = ls_item-bptaxnumber
                        tckn                  = ls_item-tckn
                        documentreferenceid   = ls_item-documentreferenceid ) TO lt_bank_file.
      ENDLOOP.
      DATA(lo_bank) = NEW ycl_pym_create_bank_file( iv_companycode = ls_header-companycode
                                                    iv_bankshortid = ls_header-companybankcode
                                                    iv_accountshortid = ls_header-companyaccountcode
                                                    it_bank_file = lt_bank_file ).
      IF lo_bank IS BOUND.
*        lv_methodname = lv_methodname && ls_header-companybankinternalid(4).
*        CONDENSE lv_methodname.
        CASE ls_header-companybankinternalid(4).
          WHEN '0046'."Akbank
            lt_txt_file = lo_bank->file_0046( ).
          WHEN '0134'."Denizbank
            lt_txt_file = lo_bank->file_0134(  ).
          WHEN '0064'."İşbankası
            lt_txt_file = lo_bank->file_0064(  ).
          WHEN '0062'."Garanti
            lt_txt_file = lo_bank->file_0062(  ).
          WHEN '0015'."Vakıfbank
            lt_txt_file = lo_bank->file_0015(  ).
          WHEN '0111'."QNB
            lt_txt_file = lo_bank->file_0111(  ).
          WHEN '0010'."Ziraat Bankası
            lt_txt_file = lo_bank->file_0010(  ).
          WHEN '0012'."Halkbank
            lt_txt_file = lo_bank->file_0012(  ).
          WHEN '0067'."Yapıkredi
            lt_txt_file = lo_bank->file_0067(  ).
          WHEN '0032'."TEB
            lt_txt_file = lo_bank->file_0032(  ).
        ENDCASE.
        ls_txt_file = concat_lines_of( table = lt_txt_file sep = cl_abap_char_utilities=>newline ).
      ENDIF.
      IF lt_txt_file IS NOT INITIAL.
        IF ms_request-download IS INITIAL. "dosya gönder
          send_sftp(
            EXPORTING
              iv_companycode    = ls_header-companycode
              iv_bankshortid    = ls_header-companybankcode
              iv_accountshortid = ls_header-companyaccountcode
              iv_direction      = 'S'
              iv_filename       = lo_bank->generate_filename( iv_transfer_type = ls_item-transfer_type
                                                      iv_lc_fc         = COND #( WHEN ls_item-transactioncurrency = 'TRY' THEN 'LC' ELSE 'FC' ) )
              iv_bank_file      = ls_txt_file
            IMPORTING
              es_http_status    = DATA(ls_http_status)
              et_messages       = DATA(lt_messages)
          ).

          IF ls_http_status-code = mc_success.
            LOOP AT lt_bank_file INTO DATA(ls_bank_file) GROUP BY ( paymentnumber = ls_bank_file-paymentnumber ).
              APPEND VALUE #( paymentnumber = ls_bank_file-paymentnumber success = abap_true  ) TO ms_response-status.
            ENDLOOP.
          ELSE.
            IF lt_messages IS NOT INITIAL.
              APPEND LINES OF lt_messages TO ms_response-messages.
              CLEAR lt_messages.
            ENDIF.
          ENDIF.
        ELSE. "txt indir
          DATA(lv_xstring) = cl_abap_conv_codepage=>create_out( )->convert( EXPORTING source = ls_txt_file ).
          ms_response-txt_base64 = cl_web_http_utility=>encode_x_base64( lv_xstring ).
          ms_response-filename = lo_bank->generate_filename( iv_transfer_type = ls_item-transfer_type
                                                             iv_lc_fc         = COND #( WHEN ls_item-transactioncurrency = 'TRY'
                                                                                        THEN 'LC' ELSE 'FC' ) ).
        ENDIF.
      ENDIF.
      CLEAR : ls_http_status , lt_messages , lt_txt_file , lt_bank_file , lv_methodname , ls_txt_file.
    ENDLOOP.
    DATA(lv_response_body) = /ui2/cl_json=>serialize( EXPORTING data = ms_response ).
    response->set_text( lv_response_body ).
    response->set_header_field( i_name = mc_header_content i_value = mc_content_type ).
  ENDMETHOD.