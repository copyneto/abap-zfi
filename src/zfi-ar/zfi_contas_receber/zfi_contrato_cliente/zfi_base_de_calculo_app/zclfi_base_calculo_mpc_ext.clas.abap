class ZCLFI_BASE_CALCULO_MPC_EXT definition
  public
  inheriting from ZCLFI_BASE_CALCULO_MPC
  create public .

public section.

  methods DEFINE
    redefinition .
protected section.
private section.
ENDCLASS.



CLASS ZCLFI_BASE_CALCULO_MPC_EXT IMPLEMENTATION.


  method DEFINE.

    super->define( ).

    DATA: lo_entity   TYPE REF TO /iwbep/if_mgw_odata_entity_typ,

          lo_property TYPE REF TO /iwbep/if_mgw_odata_property.

    lo_entity = model->get_entity_type( iv_entity_name = 'Upload' ).

    IF lo_entity IS BOUND.

      lo_property = lo_entity->get_property( iv_property_name = 'Value').

      lo_property->set_as_content_type( ).

    ENDIF.

  endmethod.
ENDCLASS.
