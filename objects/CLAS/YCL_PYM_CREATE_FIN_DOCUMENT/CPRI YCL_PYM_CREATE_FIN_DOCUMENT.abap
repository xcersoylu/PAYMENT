  PRIVATE SECTION.
    CONSTANTS mc_error          TYPE messagetyp VALUE 'E'.
    DATA: ms_request        TYPE ypym_s_create_fin_document_req,
          ms_response       TYPE ypym_s_create_fin_document_res,
          mc_header_content TYPE string VALUE 'content-type',
          mc_content_type   TYPE string VALUE 'text/json'.
    METHODS create_clearing_document IMPORTING is_item               TYPE ypym_s_payment_save_doc_item
                                     EXPORTING ev_accountingdocument TYPE belnr_d
                                               ev_fiscalyear         TYPE gjahr.