  METHOD get_space_character.
    CONSTANTS lv_xspace_hex TYPE x LENGTH 2 VALUE '00a0'.
    DATA lv_xspace TYPE xstring.
    lv_xspace = lv_xspace_hex.
    TRY.
        cl_abap_conv_codepage=>create_in(
          EXPORTING
            codepage         = `UTF-16`
*        replacement_char =
          RECEIVING
            instance         = DATA(lo_instance)
        ).
        lo_instance->convert(
          EXPORTING
            source = lv_xspace
          RECEIVING
            result = rv_space
        ).
      CATCH cx_sy_conversion_codepage INTO DATA(lo_error).
      CATCH cx_parameter_invalid_range INTO DATA(lo_error2).
    ENDTRY.
  ENDMETHOD.