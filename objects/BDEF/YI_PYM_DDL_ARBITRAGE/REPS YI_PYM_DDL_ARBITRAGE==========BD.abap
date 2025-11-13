managed implementation in class zbp_i_pym_ddl_arbitrage unique;
strict ( 2 );

define behavior for YI_PYM_DDL_ARBITRAGE //alias <alias_name>
persistent table ypym_t_arbitrage
lock master
authorization master ( instance )
//etag master <field_name>
{
  create;
  update;
  delete;
  field ( readonly : update ) Companycode, Arbitrageaccount, Paymenttype;
  mapping for ypym_t_arbitrage
    {
      companycode            = companycode;
      arbitrageaccount       = arbitrageaccount;
      paymenttype            = paymenttype;
      accountingdocumenttype = accountingdocumenttype;
    }
}