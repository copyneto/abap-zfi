CLASS zclfi_carga_contr_01_mpc_ext DEFINITION
  PUBLIC
  INHERITING FROM zclfi_carga_contr_01_mpc
  CREATE PUBLIC .

  PUBLIC SECTION.

    METHODS define
        REDEFINITION .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zclfi_carga_contr_01_mpc_ext IMPLEMENTATION.


  METHOD define.
    super->define( ).

    DATA: lo_entity   TYPE REF TO /iwbep/if_mgw_odata_entity_typ,

          lo_property TYPE REF TO /iwbep/if_mgw_odata_property.

    lo_entity = model->get_entity_type( iv_entity_name = 'upload' ).

    IF lo_entity IS BOUND.

      lo_property = lo_entity->get_property( iv_property_name = 'FileName').

      lo_property->set_as_content_type( ).

    ENDIF.
  ENDMETHOD.
ENDCLASS.
