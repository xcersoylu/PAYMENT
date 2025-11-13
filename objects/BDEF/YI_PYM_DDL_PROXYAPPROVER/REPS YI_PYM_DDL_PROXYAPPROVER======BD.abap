managed implementation in class zbp_i_pym_ddl_proxyapprover unique;
strict ( 2 );

define behavior for YI_PYM_DDL_PROXYAPPROVER //alias <alias_name>
persistent table ypym_t_proxyapp
lock master
authorization master ( instance )
//etag master <field_name>
{
  create;
  update;
  delete;
  field ( readonly : update ) Approver, Proxyapprover;
  mapping for ypym_t_proxyapp
    {
      Approver      = approver;
      Proxyapprover = proxyapprover;
      Begindate     = begindate;
      Enddate       = enddate;
    }
}