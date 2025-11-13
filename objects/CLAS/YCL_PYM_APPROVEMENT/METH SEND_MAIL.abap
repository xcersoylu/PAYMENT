  METHOD send_mail.
    TRY.
        DATA(lo_mail) = cl_bcs_mail_message=>create_instance( ).
        lo_mail->set_sender( iv_address = CONV #( iv_sender ) ).
        LOOP AT it_recipient INTO DATA(ls_recipient).
          lo_mail->add_recipient( iv_address = CONV #( ls_recipient-email ) ).
          IF ls_recipient-proxyapprovers IS NOT INITIAL.
            LOOP AT ls_recipient-proxyapprovers INTO DATA(ls_proxyapprover).
              lo_mail->add_recipient( iv_address = CONV #( ls_recipient-email ) iv_copy = CONV #( 'C' ) ).
            ENDLOOP.
          ENDIF.
        ENDLOOP.
        lo_mail->set_subject( CONV #( iv_subject ) ).
        lo_mail->set_main( cl_bcs_mail_textpart=>create_instance( iv_content      = iv_content
                                                                  iv_content_type = 'text/html' ) ).
        lo_mail->send( IMPORTING et_status = DATA(lt_status) ).
        COMMIT WORK.
      CATCH cx_bcs_mail INTO DATA(lo_err).
        DATA(lv_error) = lo_err->get_longtext( ) .
    ENDTRY.
  ENDMETHOD.