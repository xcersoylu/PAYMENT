  METHOD get_all_approvers.
    SELECT approver~approvergroup , approver~approvergroupsequence , approver~approver , userinfo~defaultemailaddress AS email ,  userinfo~personfullname AS fullname
       FROM ypym_t_appgrsequ AS approver INNER JOIN i_businessuservh AS userinfo ON userinfo~userid = approver~approver
       WHERE approver~companycode = @iv_companycode
         AND approver~approvergroup = @iv_approvergroup
         INTO CORRESPONDING FIELDS OF TABLE @rt_approvers.
    IF sy-subrc = 0.
      SELECT proxyapprover~approver , proxyapprover~proxyapprover , userinfo~defaultemailaddress AS email
          FROM @rt_approvers AS approvers INNER JOIN ypym_t_proxyapp AS proxyapprover ON proxyapprover~approver = approvers~approver
          INNER JOIN i_businessuservh AS userinfo ON userinfo~userid = proxyapprover~proxyapprover
          WHERE proxyapprover~begindate <= @sy-datum
            AND proxyapprover~enddate >= @sy-datum
       INTO TABLE @DATA(lt_proxyapprovers).
      LOOP AT rt_approvers ASSIGNING FIELD-SYMBOL(<ls_approver>).
        <ls_approver>-proxyapprovers = VALUE #( FOR wa_proxyapprover
                                                 IN lt_proxyapprovers
                                              WHERE ( approver = <ls_approver>-approver )
                                                 ( proxyapprover = wa_proxyapprover-proxyapprover email = wa_proxyapprover-email ) ).
      ENDLOOP.
    ENDIF.
  ENDMETHOD.