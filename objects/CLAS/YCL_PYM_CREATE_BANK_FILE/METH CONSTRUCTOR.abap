  METHOD constructor.
    SELECT SINGLE * FROM ypym_t_urfcode WHERE companycode = @iv_companycode
                                          AND bankshortid = @iv_bankshortid
                                          AND accountshortid = @iv_accountshortid
    INTO CORRESPONDING FIELDS OF @ms_urfcode.
    mt_bank_file[] = it_bank_file[].
  ENDMETHOD.