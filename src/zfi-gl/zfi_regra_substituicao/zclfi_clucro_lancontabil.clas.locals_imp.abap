class lcl_fi_CentroLucro definition inheriting from cl_abap_behavior_handler.
  private section.

    methods authorityCreate for validate on save
      importing keys for CentroLucro~authorityCreate.

    methods get_authorizations for authorization
      importing keys request requested_authorizations for CentroLucro result result.

endclass.

class lcl_fi_CentroLucro implementation.

  method authorityCreate.
  "#EC NEEDED
  endmethod.

  method get_authorizations.
  "#EC NEEDED
  endmethod.

endclass.
