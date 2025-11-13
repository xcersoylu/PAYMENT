managed implementation in class zbp_i_pym_ddl_approvergroup unique;
strict ( 2 );

define behavior for YI_PYM_DDL_APPROVERGROUP //alias <alias_name>
persistent table ypym_t_appgroup
lock master
authorization master ( instance )
//etag master <field_name>
{
  create;
  update;
  delete;
  field ( readonly : update ) Companycode, Approvergroup;
  association _Sequence { create; }
  association _User { create; }
  association _Text { create; }
  mapping for ypym_t_appgroup
    {
      Companycode   = companycode;
      Approvergroup = approvergroup;
    }
}

define behavior for YI_PYM_DDL_APPROVERGROUPSEQ //alias <alias_name>
persistent table ypym_t_appgrsequ
lock dependent by _ApproverGroup
authorization dependent by _ApproverGroup
//etag master <field_name>
{
  update;
  delete;
  field ( readonly : update ) Companycode, Approvergroup, Approvergroupsequence;
  association _ApproverGroup;

  mapping for ypym_t_appgrsequ
    {
      Companycode           = companycode;
      Approvergroup         = approvergroup;
      Approver              = approver;
      Approvergroupsequence = approvergroupsequence;
    }
}

define behavior for YI_PYM_DDL_APPROVERUSER //alias <alias_name>
persistent table ypym_t_appgruser
lock dependent by _ApproverGroup
authorization dependent by _ApproverGroup
//etag master <field_name>
{
  update;
  delete;
  field ( readonly : update ) Companycode, Approvergroup, Approver;
  association _ApproverGroup;
  mapping for ypym_t_appgruser
    {
      Companycode   = companycode;
      Approvergroup = approvergroup;
      Approver      = approver;
    }
}

define behavior for YI_PYM_DDL_APPROVERGROUP_TEXT //alias <alias_name>
persistent table ypym_t_xappgroup
lock dependent by _ApproverGroup
authorization dependent by _ApproverGroup
//etag master <field_name>
{
  update;
  delete;
  field ( readonly : update ) Language,Companycode, Approvergroup;
  association _ApproverGroup;
  mapping for ypym_t_xappgroup
    {
      Language      = language;
      Companycode   = companycode;
      Approvergroup = approvergroup;
      Approvergrouptext = approvergrouptext;
    }
}