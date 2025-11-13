managed implementation in class zbp_i_pym_ddl_sftp unique;
strict ( 2 );

define behavior for YI_PYM_DDL_SFTP //alias <alias_name>
persistent table ypym_t_sftp
lock master
authorization master ( instance )
//etag master <field_name>
{
  create;
  update;
  delete;
  field ( readonly :update ) Companycode, Bankshortid, Accountshortid ,Direction;
  mapping for ypym_t_sftp
    {
      Companycode    = companycode;
      Bankshortid    = bankshortid;
      Accountshortid = accountshortid;
      Direction      = direction;
      HostName       = host_name;
      SshKey         = ssh_key;
      Username       = username;
      Password       = password;
      SftpPath       = sftp_path;
      FileExt        = file_ext;
      SftpTarget     = sftp_target;
      CpiUser        = cpi_user;
      CpiPassword    = cpi_password;
      CpiUrl         = cpi_url;
    }
}