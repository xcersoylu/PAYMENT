  PRIVATE SECTION.
    CONSTANTS mc_error          TYPE messagetyp VALUE 'E'.
    DATA: ms_request        TYPE ypym_s_create_fin_doc_dpay_req,
          ms_response       TYPE ypym_s_create_fin_doc_dpay_res,
          mc_header_content TYPE string VALUE 'content-type',
          mc_content_type   TYPE string VALUE 'text/json'.
