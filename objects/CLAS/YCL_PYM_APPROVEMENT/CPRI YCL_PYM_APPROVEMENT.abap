  PRIVATE SECTION.
    METHODS get_paymenttype IMPORTING iv_paymentnumber TYPE ypym_e_paymentnumber RETURNING VALUE(rv_paymenttype) TYPE ypym_e_paymenttype.
    CONSTANTS mc_approved TYPE ypym_e_approvementstatus VALUE 'APPROVED'.
    CONSTANTS mc_rejected TYPE ypym_e_approvementstatus VALUE 'REJECTED'.
    CONSTANTS mc_inprogress TYPE ypym_e_approvementstatus VALUE 'INPROGRESS'.
    CONSTANTS mc_completed TYPE ypym_e_approvementstatus VALUE 'COMPLETED'.