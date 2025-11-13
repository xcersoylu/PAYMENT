projection;
strict ( 2 );

define behavior for YC_PYM_DDL_APPROVERGROUP //alias <alias_name>
{
  use create;
  use update;
  use delete;

  use association _Sequence { create; }
  use association _User { create; }
  use association _Text { create; }
}

define behavior for YC_PYM_DDL_APPROVERGROUPSEQ //alias <alias_name>
{
  use update;
  use delete;

  use association _ApproverGroup;
}

define behavior for YC_PYM_DDL_APPROVERUSER //alias <alias_name>
{
  use update;
  use delete;

  use association _ApproverGroup;
}

define behavior for YC_PYM_DDL_APPROVERGROUP_TEXT //alias <alias_name>
{
  use update;
  use delete;

  use association _ApproverGroup;
}