CLASS ycl_pym_create_bank_file DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    DATA mt_bank_file TYPE ypym_tt_bank_file_data.
    DATA ms_urfcode TYPE ypym_t_urfcode.
    METHODS constructor IMPORTING iv_companycode    TYPE bukrs
                                  iv_bankshortid    TYPE hbkid
                                  iv_accountshortid TYPE hktid
                                  it_bank_file      TYPE ypym_tt_bank_file_data.
    METHODS get_space_character RETURNING VALUE(rv_space) TYPE string.
    METHODS file_0046 RETURNING VALUE(rt_bank_file) TYPE string_table."Akbank
    METHODS file_0134 RETURNING VALUE(rt_bank_file) TYPE string_table."Denizbank
    METHODS file_0064 RETURNING VALUE(rt_bank_file) TYPE string_table."İşbankası
    METHODS file_0062 RETURNING VALUE(rt_bank_file) TYPE string_table."Garanti
    METHODS file_0015 RETURNING VALUE(rt_bank_file) TYPE string_table."Vakıfbank
    METHODS file_0111 RETURNING VALUE(rt_bank_file) TYPE string_table."QNB
    METHODS file_0010 RETURNING VALUE(rt_bank_file) TYPE string_table."Ziraat
    METHODS file_0012 RETURNING VALUE(rt_bank_file) TYPE string_table."HalkBank
    METHODS file_0067 RETURNING VALUE(rt_bank_file) TYPE string_table."YapıKredi
    METHODS file_0032 RETURNING VALUE(rt_bank_file) TYPE string_table."Teb
    METHODS file_0134_fc RETURNING VALUE(rt_bank_file) TYPE string_table."Denizbank
    METHODS file_0015_fc RETURNING VALUE(rt_bank_file) TYPE string_table."Vakıfbank
    METHODS file_0046_fc RETURNING VALUE(rt_bank_file) TYPE string_table."Akbank
    METHODS file_0064_fc RETURNING VALUE(rt_bank_file) TYPE string_table."İşbankası
    METHODS file_0010_fc RETURNING VALUE(rt_bank_file) TYPE string_table."Ziraat
    METHODS file_0062_fc RETURNING VALUE(rt_bank_file) TYPE string_table."Garanti
    METHODS file_0111_fc RETURNING VALUE(rt_bank_file) TYPE string_table."QNB
    METHODS file_0067_fc RETURNING VALUE(rt_bank_file) TYPE string_table."Yapıkredi
    METHODS generate_filename IMPORTING iv_transfer_type   TYPE ypym_e_transfer_type
                                        iv_lc_fc           TYPE ypym_e_lc_fc
                              RETURNING VALUE(rv_filename) TYPE ypym_e_filename.