  PRIVATE SECTION.
    DATA: ms_request        TYPE ypym_s_downpay_save_doc_req,
          ms_response       TYPE ypym_s_downpay_save_doc_res,
          mc_header_content TYPE string VALUE 'content-type',
          mc_content_type   TYPE string VALUE 'text/json',
          mc_completed      TYPE ypym_e_approvementstatus VALUE 'COMPLETED'.