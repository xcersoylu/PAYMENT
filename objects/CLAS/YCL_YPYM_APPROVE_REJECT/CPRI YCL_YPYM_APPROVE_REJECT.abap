  PRIVATE SECTION.
    DATA: ms_request  TYPE ypym_s_approve_reject_req,
          ms_response TYPE ypym_s_approve_reject_res.
    CONSTANTS: mc_header_content TYPE string VALUE 'content-type',
               mc_content_type   TYPE string VALUE 'text/json',
               mc_inprocess      TYPE ypym_e_approvementstatus VALUE 'INPROCESS',
               mc_waiting        TYPE ypym_e_approvementstatus VALUE 'WAITING'.