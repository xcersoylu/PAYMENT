  PRIVATE SECTION.
    DATA: ms_request  TYPE ypym_s_create_pay_cus_data_req,
          ms_response TYPE ypym_s_create_pay_cus_data_res.
    CONSTANTS: mc_header_content TYPE string VALUE 'content-type',
               mc_content_type   TYPE string VALUE 'text/json'.