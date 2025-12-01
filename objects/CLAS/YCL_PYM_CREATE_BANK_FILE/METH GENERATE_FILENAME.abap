  METHOD generate_filename.
    DATA(lv_datum) = cl_abap_context_info=>get_system_date( ).
    DATA(lv_time) = cl_abap_context_info=>get_system_time( ).
    CASE iv_transfer_type.
      WHEN 'HAVALE/EFT'.
        CASE iv_lc_fc.
          WHEN 'LC'.
            SELECT SINGLE concat( concat(  @ms_urfcode-pay_namespace,
                                  concat( substring( bankinternalid,1,4 ),
                                  @ms_urfcode-firm_code ) ),
                                  concat( @lv_datum, @lv_time ) ) AS filename
              FROM i_housebank
                WHERE companycode = @ms_urfcode-companycode AND housebank = @ms_urfcode-bankshortid
                  INTO @rv_filename.
          WHEN 'FC'.
            rv_filename = |{ ms_urfcode-pay_namespace }{ ms_urfcode-firm_code }_{ cl_abap_context_info=>get_system_date(  ) }_{ cl_abap_context_info=>get_system_time(  ) }|.
        ENDCASE.
      WHEN 'EFT'.
        rv_filename = |{ ms_urfcode-pay_namespace }{ ms_urfcode-firm_code }_{ cl_abap_context_info=>get_system_date(  ) }_{ cl_abap_context_info=>get_system_time(  ) }|.
      WHEN 'HAVALE'.
        SELECT SINGLE concat( concat(  @ms_urfcode-pay_namespace,
                              concat( substring( bankinternalid,1,4 ),
                              @ms_urfcode-firm_code ) ),
                              concat( @lv_datum, @lv_time ) ) AS filename
          FROM i_housebank
            WHERE companycode = @ms_urfcode-companycode AND housebank = @ms_urfcode-bankshortid
              INTO @rv_filename.
    ENDCASE.
    IF rv_filename IS INITIAL.
      rv_filename = |{ lv_datum }{ lv_time }|.
    ELSEIF rv_filename(4) = '0010'.
      rv_filename = |{ lv_datum }{ lv_time }_{ ms_urfcode-firm_code }|.
    ENDIF.
  ENDMETHOD.