class ZCLFI_GET_VENC_ORIG definition
  public
  final
  create public .

public section.

  interfaces IF_SADL_EXIT .
  interfaces IF_SADL_EXIT_CALC_ELEMENT_READ .
protected section.
private section.
ENDCLASS.



CLASS ZCLFI_GET_VENC_ORIG IMPLEMENTATION.


  METHOD if_sadl_exit_calc_element_read~calculate.

    DATA: lt_original_data TYPE STANDARD TABLE OF zi_fi_venc_cli WITH DEFAULT KEY.

    DATA: ls_bseg TYPE bseg_key.

    DATA: lv_venc TYPE datum.

    lt_original_data = CORRESPONDING #( it_original_data ).


    LOOP AT lt_original_data ASSIGNING FIELD-SYMBOL(<fs_data>).

      ls_bseg-belnr = <fs_data>-nodocumento.
      ls_bseg-bukrs = <fs_data>-empresa.
      ls_bseg-gjahr = <fs_data>-exercicio.
      ls_bseg-buzei = <fs_data>-item.

      lv_venc = NEW zclfi_venc_orig( )->ext_venc_orig( iv_key   = ls_bseg
                                                       iv_netdt = <fs_data>-vencimentoem ).

      <fs_data>-vencorigem = lv_venc.

      <fs_data>-diasprorrog = <fs_data>-vencimentoem - <fs_data>-vencorigem.

    ENDLOOP.

    ct_calculated_data = CORRESPONDING #( lt_original_data ).

  ENDMETHOD.


  METHOD if_sadl_exit_calc_element_read~get_calculation_info.
    RETURN.
  ENDMETHOD.
ENDCLASS.
