managed implementation in class zbp_i_pym_ddl_parameter unique;
strict ( 2 );

define behavior for YI_PYM_DDL_PARAMETER //alias <alias_name>
persistent table ypym_t_parameter
lock master
authorization master ( instance )
//etag master <field_name>
{
  create ( authorization : global );
  update;
  delete;
  field ( readonly : update ) Parametername, Parameterkey;
  mapping for ypym_t_parameter
    {
      Parameterkey  = parameterkey;
      Parametername = parametername;
      Value         = value;
      Description   = description;
    }
}