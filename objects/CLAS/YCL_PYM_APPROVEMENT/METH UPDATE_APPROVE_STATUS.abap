  METHOD update_approve_status.
    DATA lv_approvergroupsequence TYPE ypym_e_approvergroupseq.
    DATA lt_recipient TYPE ypym_tt_recipient.
    DATA(lv_user) = cl_abap_context_info=>get_user_technical_name( ).
    DATA(lv_date) = cl_abap_context_info=>get_system_date(  ).
    DATA(lv_time) = cl_abap_context_info=>get_system_time(  ).
    DATA(lv_paymenttype) = get_paymenttype( is_approve_status-paymentnumber ).
    UPDATE ypym_t_approve
       SET lastchangeduser = @lv_user,
           lastchangeddate = @lv_date,
           lastchangedtime = @lv_time,
           approvementstatus = @is_approve_status-approvementstatus
       WHERE paymentnumber = @is_approve_status-paymentnumber
        AND approvergroupsequence = @is_approve_status-approvergroupsequence.
    IF sy-subrc = 0.
      CASE is_approve_status-approvementstatus.
        WHEN mc_approved.
          lv_approvergroupsequence = is_approve_status-approvergroupsequence + 1 .
          DATA(lt_approvers) = get_next_approvers( EXPORTING
                                                        iv_paymentnumber         = is_approve_status-paymentnumber
                                                        iv_approvergroupsequence = lv_approvergroupsequence ).
          IF lt_approvers IS NOT INITIAL.
            send_mail(
              iv_sender    = get_email( CONV #( cl_abap_context_info=>get_user_technical_name(  ) ) )
              it_recipient = VALUE #( FOR ls_recipient IN lt_approvers ( CORRESPONDING #( ls_recipient ) ) )
              iv_subject   = |{ is_approve_status-paymentnumber ALPHA = OUT } nolu ödeme onayınızı bekliyor|
              iv_content   = |{ is_approve_status-paymentnumber ALPHA = OUT } nolu ödeme onayınızı bekliyor|
            ).
            APPEND VALUE #( paymentnumber = is_approve_status-paymentnumber
                            messagetype = 'S'
                            message = |{ is_approve_status-paymentnumber } nolu ödeme onaylanmıştır.| ) TO rt_messages.
          ELSE.
            "completed
            CASE lv_paymenttype.
              WHEN '01'. "satıcı
                UPDATE ypym_t_payment
                   SET approvementstatus = @mc_completed
                 WHERE paymentnumber = @is_approve_status-paymentnumber.
                SELECT SINGLE createduser
                        FROM ypym_t_payment
                        WHERE paymentnumber = @is_approve_status-paymentnumber
                        INTO @DATA(lv_createduser).
              when '02'. "peşinat
                UPDATE ypym_t_downpay
                   SET approvementstatus = @mc_completed
                 WHERE paymentnumber = @is_approve_status-paymentnumber.
                SELECT SINGLE createduser
                        FROM ypym_t_downpay
                        WHERE paymentnumber = @is_approve_status-paymentnumber
                        INTO @lv_createduser.
              WHEN '03'. "müşteri
                UPDATE ypym_t_pay_cus
                   SET approvementstatus = @mc_completed
                 WHERE paymentnumber = @is_approve_status-paymentnumber.
                SELECT SINGLE createduser
                        FROM ypym_t_pay_cus
                        WHERE paymentnumber = @is_approve_status-paymentnumber
                        INTO @lv_createduser.
            ENDCASE.
            APPEND VALUE #(  email = get_email( iv_username = lv_createduser ) ) TO lt_recipient.
            send_mail(
              iv_sender    = get_email( CONV #( cl_abap_context_info=>get_user_technical_name(  ) ) )
              it_recipient = lt_recipient
              iv_subject   = |{ is_approve_status-paymentnumber ALPHA = OUT } nolu ödeme onayı tamamlanmıştır|
              iv_content   = |{ is_approve_status-paymentnumber ALPHA = OUT } nolu ödeme onayı tamamlanmıştır|
            ).
            APPEND VALUE #( paymentnumber = is_approve_status-paymentnumber
                            messagetype = 'S'
                            message = |{ is_approve_status-paymentnumber ALPHA = OUT } nolu ödemenin onayları tamamlanmıştır.| ) TO rt_messages.
          ENDIF.
        WHEN mc_rejected.
          CASE lv_paymenttype.
            WHEN '01'. "satıcı
              UPDATE ypym_t_payment
                 SET approvementstatus = @mc_rejected
               WHERE paymentnumber = @is_approve_status-paymentnumber.
              SELECT SINGLE createduser
                      FROM ypym_t_payment
                      WHERE paymentnumber = @is_approve_status-paymentnumber
                      INTO @lv_createduser.
            when '02'. "peşinat
              UPDATE ypym_t_downpay
                 SET approvementstatus = @mc_rejected
               WHERE paymentnumber = @is_approve_status-paymentnumber.
              SELECT SINGLE createduser
                      FROM ypym_t_downpay
                      WHERE paymentnumber = @is_approve_status-paymentnumber
                      INTO @lv_createduser.
            WHEN '03'. "müşteri
              UPDATE ypym_t_pay_cus
                 SET approvementstatus = @mc_rejected
               WHERE paymentnumber = @is_approve_status-paymentnumber.
              SELECT SINGLE createduser
                      FROM ypym_t_payment
                      WHERE paymentnumber = @is_approve_status-paymentnumber
                      INTO @lv_createduser.
          ENDCASE.
          APPEND VALUE #(  email = get_email( iv_username = lv_createduser ) ) TO lt_recipient.
          send_mail(
            iv_sender    = get_email( CONV #( cl_abap_context_info=>get_user_technical_name(  ) ) )
            it_recipient = lt_recipient
            iv_subject   = |{ is_approve_status-paymentnumber ALPHA = OUT } nolu ödeme reddedilmiştir|
            iv_content   = |{ is_approve_status-paymentnumber ALPHA = OUT } nolu ödeme reddedilmiştir|
          ).
          APPEND VALUE #( paymentnumber = is_approve_status-paymentnumber
                          messagetype = 'S'
                          message = |{ is_approve_status-paymentnumber ALPHA = OUT } nolu ödeme reddedildi.| ) TO rt_messages.
      ENDCASE.
    ENDIF.
  ENDMETHOD.