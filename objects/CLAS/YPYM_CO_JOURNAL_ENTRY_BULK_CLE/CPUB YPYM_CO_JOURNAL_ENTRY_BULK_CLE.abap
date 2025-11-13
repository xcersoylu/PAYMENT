class YPYM_CO_JOURNAL_ENTRY_BULK_CLE definition
  public
  inheriting from CL_PROXY_CLIENT
  create public .

public section.

  methods CONSTRUCTOR
    importing
      !DESTINATION type ref to IF_PROXY_DESTINATION optional
      !LOGICAL_PORT_NAME type PRX_LOGICAL_PORT_NAME optional
    preferred parameter LOGICAL_PORT_NAME
    raising
      CX_AI_SYSTEM_FAULT .
  methods JOURNAL_ENTRY_BULK_CLEARING_RE
    importing
      !INPUT type YPYM_JOURNAL_ENTRY_BULK_CLEARI
    raising
      CX_AI_SYSTEM_FAULT .