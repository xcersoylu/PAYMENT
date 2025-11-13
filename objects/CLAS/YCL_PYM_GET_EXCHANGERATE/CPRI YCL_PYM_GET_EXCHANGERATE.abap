private section.
    DATA: ms_request        TYPE ypym_s_imp_exchangerate_req,
          ms_response       TYPE ypym_s_imp_exchangerate_res,
          mc_header_content TYPE string VALUE 'content-type',
          mc_content_type   TYPE string VALUE 'text/json'.