managed implementation in class zbp_i_pym_ddl_doctype unique;
strict ( 2 );

define behavior for YI_PYM_DDL_DOCTYPE //alias <alias_name>
persistent table ypym_t_doctype
lock master
authorization master ( instance )
//etag master <field_name>
{
  create;
  update;
  delete;
  field ( readonly : update ) Documenttype;
}