CLASS lhc_yi_pym_ddl_arbitrage DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR yi_pym_ddl_arbitrage RESULT result.

ENDCLASS.

CLASS lhc_yi_pym_ddl_arbitrage IMPLEMENTATION.

  METHOD get_instance_authorizations.
  ENDMETHOD.

ENDCLASS.