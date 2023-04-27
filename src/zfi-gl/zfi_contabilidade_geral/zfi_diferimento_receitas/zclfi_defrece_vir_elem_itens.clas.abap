CLASS zclfi_defrece_vir_elem_itens DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_sadl_exit .
    INTERFACES if_sadl_exit_calc_element_read .
  PROTECTED SECTION.
private section.

  constants GC_DISPLAYCONTRAPARTIDA type CHAR30 value 'displayContraPartida' ##NO_TEXT.
  constants GC_TPCNT type CHAR05 value 'Tpcnt' ##NO_TEXT.
ENDCLASS.



CLASS ZCLFI_DEFRECE_VIR_ELEM_ITENS IMPLEMENTATION.


  METHOD if_sadl_exit_calc_element_read~calculate.

  FIELD-SYMBOLS: <fs_data>     TYPE any.
    LOOP AT it_original_data ASSIGNING <fs_data>.
      DATA(lv_index) = sy-tabix.

      ASSIGN COMPONENT to_upper( gc_tpcnt )  OF STRUCTURE <fs_data> TO FIELD-SYMBOL(<fs_Tpcnt>).

      ASSIGN COMPONENT to_upper( gc_displaycontrapartida )  OF STRUCTURE ct_calculated_data[ lv_index ] TO FIELD-SYMBOL(<fs_displayContraPartida>).
      IF <fs_displayContraPartida> IS ASSIGNED .
          if <fs_Tpcnt> = 'I'.
          <fs_displayContraPartida> = abap_false.
          else.
          <fs_displayContraPartida> = abap_true.
          endif.
      ENDIF.

    ENDLOOP.

  ENDMETHOD.


  METHOD if_sadl_exit_calc_element_read~get_calculation_info.

    exit.

  ENDMETHOD.
ENDCLASS.
