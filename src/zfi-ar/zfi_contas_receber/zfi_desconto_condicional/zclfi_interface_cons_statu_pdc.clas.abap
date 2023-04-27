"!<p>Classe processar Interface Consulta Status Parcelas PDC</p>
"!<p><strong>Autor:</strong>Marcos Rubik</p>
"!<p><strong>Data:</strong> 04 de Março de 2022</p>
class ZCLFI_INTERFACE_CONS_STATU_PDC definition
  public
  final
  create public .

public section.

    "! Método realizar consulta status parcelas
    "! @parameter is_input  | Dados entrada interface
  methods CONSULTA_STATUS_PARCELAS
    importing
      !IS_INPUT type ZCLFI_MT_CONSULTA_STATUS_PARC1
    exporting
      !ES_OUTPUT type ZCLFI_MT_CONSULTA_STATUS_PARCE
    raising
      ZCXCA_ERRO_INTERFACE .
  PROTECTED SECTION.
  PRIVATE SECTION.
    CONSTANTS: BEGIN OF gc_erros,
                 interface TYPE string VALUE 'SI_RECEBER_CONSULTA_STATUS_PAR',
                 metodo    TYPE string VALUE 'consulta_status_parcelas'   ##NO_TEXT,
                 classe    TYPE string VALUE 'ZCLFI_INTERFACE_CONS_STATU_PDC'        ##NO_TEXT,
               END OF gc_erros.

    METHODS:
      "! Return error raising
      error_raise
        IMPORTING
          is_ret TYPE scx_t100key
        RAISING
          zcxca_erro_interface.

ENDCLASS.



CLASS ZCLFI_INTERFACE_CONS_STATU_PDC IMPLEMENTATION.


  METHOD consulta_status_parcelas.

    DATA: lt_return  TYPE bapiret2_t,
          lt_respost TYPE zclfi_dt_consulta_status_p_tab.

    DATA: lv_bukrs    TYPE  bukrs,
          lv_tipo_doc TYPE  char1,
          lv_xblnr    TYPE  xblnr.

    lv_bukrs    = is_input-mt_consulta_status_parcelas-bukrs.
    lv_tipo_doc = is_input-mt_consulta_status_parcelas-zed_tipo_doc.
    lv_xblnr    = is_input-mt_consulta_status_parcelas-xblnr.

*    NEW zclfi_consultar_status_pdc( )->consultar( EXPORTING iv_bukrs    = lv_bukrs
*                                                            iv_tipo_doc = lv_tipo_doc
*                                                            iv_xblnr    = lv_xblnr
*                                                  IMPORTING ev_belnr   = DATA(lv_e_belnr)
*                                                            ev_gjahr   = DATA(lv_e_gjahr)
*                                                            ev_status  = DATA(lv_e_status)
*                                                            ev_augdt   = DATA(lv_e_augdt)
*                                                            ev_xblnr   = DATA(lv_e_xblnr) ).

    NEW zclfi_consultar_status_pdc( )->consultar( EXPORTING iv_bukrs    = lv_bukrs
                                                            iv_tipo_doc = lv_tipo_doc
                                                            iv_xblnr    = lv_xblnr
                                                  IMPORTING et_parcelas = DATA(lt_parcelas) ).

*    IF lt_parcelas IS INITIAL.
    IF lt_parcelas[] IS INITIAL.
      me->error_raise( is_ret = VALUE scx_t100key( attr1 = gc_erros-interface
                                                   attr2 = gc_erros-classe
                                                   attr3 = gc_erros-metodo ) ).
    ENDIF.

    LOOP AT lt_parcelas ASSIGNING FIELD-SYMBOL(<fs_parcelas>).
      lt_respost = VALUE #( BASE lt_respost ( augdt        = <fs_parcelas>-augdt
                                              zed_status   = <fs_parcelas>-status
                                              gjhar        = <fs_parcelas>-gjahr
                                              belnr_d      = <fs_parcelas>-belnr
                                              xblnr        = <fs_parcelas>-xblnr
                                              zed_tipo_doc = is_input-mt_consulta_status_parcelas-zed_tipo_doc
                                              bukrs        = is_input-mt_consulta_status_parcelas-bukrs ) ).
    ENDLOOP.

    es_output-mt_consulta_status_parcelas_re-retorno_status_parcelas_sap[] = CORRESPONDING #( lt_respost[] ).

*    es_output-mt_consulta_status_parcelas_re-belnr_d    = lv_e_belnr.
*    es_output-mt_consulta_status_parcelas_re-gjhar      = lv_e_gjahr.
*    es_output-mt_consulta_status_parcelas_re-zed_status = lv_e_status.
*    es_output-mt_consulta_status_parcelas_re-augdt      = lv_e_augdt.
*    es_output-mt_consulta_status_parcelas_re-xblnr      = lv_e_xblnr.

  ENDMETHOD.


  METHOD error_raise.
    RAISE EXCEPTION TYPE zcxca_erro_interface
      EXPORTING
        textid = VALUE #(
                          attr1 = is_ret-attr1
                          attr2 = is_ret-attr2
                          attr3 = is_ret-attr3
                          msgid = is_ret-msgid
                          msgno = is_ret-msgno
                          ).
  ENDMETHOD.
ENDCLASS.
