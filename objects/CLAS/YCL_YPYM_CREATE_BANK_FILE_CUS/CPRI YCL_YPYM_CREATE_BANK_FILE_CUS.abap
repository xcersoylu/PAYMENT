  PRIVATE SECTION.
    TYPES:
      BEGIN OF http_status,
        code   TYPE i,
        reason TYPE string,
      END OF http_status .
    DATA: ms_request  TYPE ypym_s_cre_bank_file_cus_req,
          ms_response TYPE ypym_s_cre_bank_file_cus_res.
    CONSTANTS:mc_header_content TYPE string VALUE 'content-type',
              mc_content_type   TYPE string VALUE 'text/json',
              mc_success        TYPE i VALUE '200'.
    METHODS send_sftp IMPORTING iv_companycode    TYPE bukrs
                                iv_bankshortid    TYPE hbkid
                                iv_accountshortid TYPE hktid
                                iv_direction      TYPE ypym_e_direction
                                iv_filename       TYPE ypym_e_filename
                                iv_bank_file      TYPE string
                      EXPORTING es_http_status    TYPE http_status
                                et_messages       TYPE ypym_tt_message.