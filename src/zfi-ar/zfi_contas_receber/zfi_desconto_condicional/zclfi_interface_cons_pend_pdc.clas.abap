"!<p>Classe processar Interface Consulta Pendencia Financeira PDC</p>
"!<p><strong>Autor:</strong>Marcos Rubik</p>
"!<p><strong>Data:</strong> 08 de Março de 2022</p>
class ZCLFI_INTERFACE_CONS_PEND_PDC definition
  public
  final
  create public .

public section.

    "! Método realizar consulta pendência financeira
    "! @parameter is_input  | Dados entrada interface
  methods CONSULTA_PENDENCIA_FINANCEIRA
    importing
      !IS_INPUT type ZCLFI_MT_CONSULTA_PENDENCIA_FI
    exporting
      !ES_OUTPUT type ZCLFI_MT_RETORNA_PENDENCIA_FIN
    raising
      ZCXCA_ERRO_INTERFACE .
  PROTECTED SECTION.
  PRIVATE SECTION.
    CONSTANTS: BEGIN OF gc_erros,
                 interface TYPE string VALUE 'SI_RECEBER_CONSULTA_STATUS_PAR',
                 metodo    TYPE string VALUE 'consulta_pendencia_financeira'        ##NO_TEXT,
                 classe    TYPE string VALUE 'ZCLFI_INTERFACE_CONS_PEND_PDC'        ##NO_TEXT,
               END OF gc_erros.

    METHODS:
      "! Return error raising
      error_raise
        IMPORTING
          is_ret TYPE scx_t100key
        RAISING
          zcxca_erro_interface.

ENDCLASS.



CLASS ZCLFI_INTERFACE_CONS_PEND_PDC IMPLEMENTATION.


  METHOD consulta_pendencia_financeira.
    DATA: lt_return   TYPE bapiret2_t,
          lt_vkorg    TYPE tdt_vkorg,
          lt_pend_fin TYPE zctgfi_pend_fin.

    DATA: ls_vkorg     LIKE LINE OF lt_vkorg,
          ls_tab_saida TYPE zclfi_dt_retorna_pendencia_fi1.

    DATA: lv_bukrs    TYPE  bukrs,
          lv_tipo_doc TYPE  char1,
          lv_xblnr    TYPE  xblnr.

    DATA: lv_dtven_ini TYPE dats,
          lv_dtven_fim TYPE dats,
          lv_dtbase    TYPE dats,
          lv_kunnr     TYPE kunnr.

    lv_dtven_ini = is_input-mt_consulta_pendencia_financei-data_vencimento_inicial.
    lv_dtven_fim = is_input-mt_consulta_pendencia_financei-data_vencimento_final.
    lv_dtbase    = is_input-mt_consulta_pendencia_financei-data_base.
    lv_kunnr     = is_input-mt_consulta_pendencia_financei-cliente.

    LOOP AT is_input-mt_consulta_pendencia_financei-lista_organizacoes
      ASSIGNING FIELD-SYMBOL(<fs_listaorg>).
      ls_vkorg = <fs_listaorg>.
      APPEND ls_vkorg TO lt_vkorg.
    ENDLOOP.

    NEW zclfi_consultar_penden_financ(  )->consultar(
      EXPORTING
        iv_dtven_ini = lv_dtven_ini
        iv_dtven_fim = lv_dtven_fim
        iv_dtbase    = lv_dtbase
        iv_kunnr     = lv_kunnr
        it_vkorg     = lt_vkorg
      RECEIVING
        rt_pend_fin  = lt_pend_fin ).

    IF lt_pend_fin[] IS INITIAL.
      RETURN.
*      me->error_raise( is_ret = VALUE scx_t100key( attr1 = gc_erros-interface
*                                                   attr2 = gc_erros-classe
*                                                   attr3 = gc_erros-metodo ) ).
    ENDIF.

    LOOP AT lt_pend_fin ASSIGNING FIELD-SYMBOL(<fs_pend_fin>).
      MOVE-CORRESPONDING <fs_pend_fin> TO ls_tab_saida.
      ls_tab_saida-netdt = <fs_pend_fin>-dtven.
      CONDENSE ls_tab_saida-cont    NO-GAPS.
      CONDENSE ls_tab_saida-atraso  NO-GAPS.
      CONDENSE ls_tab_saida-tax05   NO-GAPS.
      CONDENSE ls_tab_saida-tax30   NO-GAPS.
      CONDENSE ls_tab_saida-tax60   NO-GAPS.
      CONDENSE ls_tab_saida-tax120  NO-GAPS.
      CONDENSE ls_tab_saida-taxmax  NO-GAPS.
      CONDENSE ls_tab_saida-total   NO-GAPS.
      APPEND ls_tab_saida TO es_output-mt_retorna_pendencia_financeir-tab_saida.
    ENDLOOP.

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
