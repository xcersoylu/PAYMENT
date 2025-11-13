  method IF_HTTP_SERVICE_EXTENSION~HANDLE_REQUEST.
    DATA lv_date TYPE datum.
    DATA(lv_request_body) = request->get_text( ).
    DATA(lv_get_method) = request->get_method( ).

    /ui2/cl_json=>deserialize( EXPORTING json = lv_request_body CHANGING data = ms_request ).
    SELECT SINGLE exchangerate
      FROM i_exchangeraterawdata
      WHERE exchangeratetype  EQ @ms_request-exchangeratetype
        AND sourcecurrency    EQ @ms_request-sourcecurrency
        AND targetcurrency    EQ @ms_request-targetcurrency
        AND validitystartdate LE @ms_request-exchangeratedate
      INTO @ms_response-exchangerate.

    DATA(lv_response_body) = /ui2/cl_json=>serialize( EXPORTING data = ms_response ).
    response->set_text( lv_response_body ).
    response->set_header_field( i_name = mc_header_content i_value = mc_content_type ).
  endmethod.