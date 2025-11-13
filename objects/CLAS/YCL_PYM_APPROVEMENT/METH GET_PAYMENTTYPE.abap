  METHOD get_paymenttype.
    SELECT @abap_true
            FROM ypym_t_payment
            WHERE paymentnumber = @iv_paymentnumber
            INTO @DATA(lv_exists)
            UP TO 1 ROWS.
    ENDSELECT.
    IF sy-subrc = 0.
      rv_paymenttype = '01'.
    ELSE.
      SELECT @abap_true
              FROM ypym_t_pay_cus
              WHERE paymentnumber = @iv_paymentnumber
              INTO @lv_exists
              UP TO 1 ROWS.
      ENDSELECT.
      IF sy-subrc = 0.
        rv_paymenttype = '03'.
      ELSE.
        SELECT @abap_true
                FROM ypym_t_downpay
                WHERE paymentnumber = @iv_paymentnumber
                INTO @lv_exists
                UP TO 1 ROWS.
        ENDSELECT.
        IF sy-subrc = 0.
          rv_paymenttype = '02'.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDMETHOD.