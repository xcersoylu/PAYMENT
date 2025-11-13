  METHOD get_email.
    SELECT SINGLE defaultemailaddress
       FROM i_businessuservh WHERE userid = @iv_username
       INTO @rv_email.
  ENDMETHOD.