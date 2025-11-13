managed implementation in class zbp_i_pym_ddl_urfcode unique;
strict ( 2 );

define behavior for YI_PYM_DDL_URFCODE //alias <alias_name>
persistent table ypym_t_urfcode
lock master
authorization master ( instance )
//etag master <field_name>
{
  create;
  update;
  delete;
  field ( readonly:update ) Companycode, Bankshortid, Accountshortid;
  mapping for ypym_t_urfcode
    {
      companycode    = companycode;
      bankshortid    = bankshortid;
      accountshortid = accountshortid;
      firmcode       = firm_code;
      paynamespace   = pay_namespace;
      consnamespace  = cons_namespace;
      mbb            = mbb;
    }
}