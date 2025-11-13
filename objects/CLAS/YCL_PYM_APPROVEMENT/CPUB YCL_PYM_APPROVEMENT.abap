CLASS ycl_pym_approvement DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    CLASS-METHODS get_all_approvers IMPORTING iv_companycode      TYPE bukrs
                                              iv_approvergroup    TYPE ypym_e_approvergroup
                                    RETURNING VALUE(rt_approvers) TYPE ypym_tt_approver_sequence.
    CLASS-METHODS send_mail IMPORTING iv_sender    TYPE string
                                      it_recipient TYPE ypym_tt_recipient
                                      iv_subject   TYPE string
                                      iv_content   TYPE string.
    METHODS update_approve_status IMPORTING is_approve_status TYPE ypym_s_update_approve_status RETURNING VALUE(rt_messages) TYPE ypym_tt_approve_reject_message.
    METHODS get_next_approvers  IMPORTING iv_paymentnumber         TYPE ypym_e_paymentnumber
                                          iv_approvergroupsequence TYPE ypym_e_approvergroupseq
                                RETURNING VALUE(rt_approvers)      TYPE ypym_tt_approver_sequence .
    CLASS-METHODS get_email IMPORTING iv_username TYPE syuname RETURNING VALUE(rv_email) TYPE ypym_e_email.
