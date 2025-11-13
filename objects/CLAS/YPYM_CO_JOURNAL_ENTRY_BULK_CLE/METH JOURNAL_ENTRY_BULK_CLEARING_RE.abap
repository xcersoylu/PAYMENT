  method JOURNAL_ENTRY_BULK_CLEARING_RE.

  data(lt_parmbind) = value abap_parmbind_tab(
    ( name = 'INPUT' kind = '0' value = ref #( INPUT ) )
  ).
  if_proxy_client~execute(
    exporting
      method_name = 'JOURNAL_ENTRY_BULK_CLEARING_RE'
    changing
      parmbind_tab = lt_parmbind
  ).

  endmethod.