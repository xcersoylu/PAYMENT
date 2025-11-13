managed implementation in class zbp_i_pym_ddl_bank unique;
strict ( 2 );

define behavior for YI_PYM_DDL_BANK //alias <alias_name>
persistent table ypym_t_bank
lock master
authorization master ( instance )
//etag master <field_name>
{
  create;
  update;
  delete;
  field ( readonly : update ) Bankcountry, Bankinternalid, Currency, Bankshortid, Accountshortid;
  mapping for ypym_t_bank
    {
      Bankcountry    = bankcountry;
      Bankinternalid = bankinternalid;
      Currency       = currency;
      Bankshortid    = bankshortid;
      Accountshortid = accountshortid;
      Bankname       = bankname;
    }
}