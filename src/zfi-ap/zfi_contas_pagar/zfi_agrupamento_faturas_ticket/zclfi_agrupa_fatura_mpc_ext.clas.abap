"!<p><h2>MPC Extension p/ upload do Arquivo de faturas ticket </h2></p> <br/>
"! Model Provider Class extension para serviço do upload de arquivo de faturas <br/> <br/>
"!<p><strong>Autor:</strong> Anderson Miazato</p>
"!<p><strong>Data:</strong> 22 de dez de 2021</p>
CLASS zclfi_agrupa_fatura_mpc_ext DEFINITION
  PUBLIC
  INHERITING FROM zclfi_agrupa_fatura_mpc
  CREATE PUBLIC .

  PUBLIC SECTION.

    METHODS define
        REDEFINITION .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zclfi_agrupa_fatura_mpc_ext IMPLEMENTATION.


  METHOD define.

    DATA:
      lo_entity   TYPE REF TO /iwbep/if_mgw_odata_entity_typ,
      lo_property TYPE REF TO /iwbep/if_mgw_odata_property.

    DATA:
      lv_entity_name   TYPE /iwbep/if_mgw_med_odata_types=>ty_e_med_entity_name,
      lv_property_name TYPE /iwbep/if_mgw_med_odata_types=>ty_e_med_entity_name.

    super->define( ).

    lv_entity_name = 'Excel'(001).

    lo_entity = model->get_entity_type( iv_entity_name = lv_entity_name ).

    IF lo_entity IS BOUND.

      lv_property_name = 'FileName'(002).

      lo_property = lo_entity->get_property( iv_property_name = lv_property_name ).
      lo_property->set_as_content_type( ).

    ENDIF.

  ENDMETHOD.
ENDCLASS.
