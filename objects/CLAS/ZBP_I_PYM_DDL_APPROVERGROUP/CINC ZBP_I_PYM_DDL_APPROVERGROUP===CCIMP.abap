CLASS lhc_yi_pym_ddl_approvergroup DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR yi_pym_ddl_approvergroup RESULT result.

ENDCLASS.

CLASS lhc_yi_pym_ddl_approvergroup IMPLEMENTATION.

  METHOD get_instance_authorizations.
  ENDMETHOD.

ENDCLASS.