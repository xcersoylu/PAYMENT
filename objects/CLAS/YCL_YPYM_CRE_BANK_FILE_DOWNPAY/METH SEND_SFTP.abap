  METHOD send_sftp.
    SELECT SINGLE *
           FROM ypym_t_sftp
           WHERE companycode = @iv_companycode
             AND bankshortid = @iv_bankshortid
             AND accountshortid = @iv_accountshortid
             AND direction = @iv_direction
           INTO @DATA(ls_sftp_info).
    IF sy-subrc = 0.
      TRY.
          DATA(lo_http_destination) = cl_http_destination_provider=>create_by_url( CONV #( ls_sftp_info-cpi_url ) ).
          DATA(lo_web_http_client) = cl_web_http_client_manager=>create_by_http_destination( lo_http_destination ) .
          DATA(lo_web_http_request) = lo_web_http_client->get_http_request( ).
          lo_web_http_request->set_authorization_basic(
            EXPORTING
              i_username = CONV #( ls_sftp_info-cpi_user )
              i_password = CONV #( ls_sftp_info-cpi_password )
          ).

          lo_web_http_request->set_header_fields( VALUE #( (  name = 'HouseBank'    value = ls_sftp_info-bankshortid )
                                                           (  name = 'AccountID'    value = ls_sftp_info-accountshortid )
                                                           (  name = 'FileName'     value = '' )
                                                           (  name = 'SftpHostPort' value = ls_sftp_info-host_name )
                                                           (  name = 'SftpUserPsw'  value = |{ ls_sftp_info-username }/{ ls_sftp_info-password }| )
                                                           (  name = 'SftpPath'     value = ls_sftp_info-sftp_path )
                                                           (  name = 'SSHKey'       value = ls_sftp_info-ssh_key )
                                                           (  name = 'SftpTarget'   value = ls_sftp_info-sftp_target )
                                                           (  name = 'Content-Type' value = 'text/plain' ) ) ).
          lo_web_http_request->set_text(
            EXPORTING
              i_text   = iv_bank_file
          ).

          DATA(lo_web_http_response) = lo_web_http_client->execute( if_web_http_client=>post ).
          DATA(lv_response) = lo_web_http_response->get_text( ).
          lo_web_http_response->get_status(
            RECEIVING
              r_value = DATA(ls_status)
          ).
          es_http_status = CORRESPONDING #( ls_status ).
        CATCH cx_http_dest_provider_error cx_web_http_client_error cx_web_message_error.
      ENDTRY.
    ELSE.
      MESSAGE ID 'YPYM_MESSAGES'
              TYPE 'E'
              NUMBER 005
              INTO DATA(lv_message).
      APPEND VALUE #( messagetype = 'E' message = lv_message  ) TO et_messages.
    ENDIF.
  ENDMETHOD.