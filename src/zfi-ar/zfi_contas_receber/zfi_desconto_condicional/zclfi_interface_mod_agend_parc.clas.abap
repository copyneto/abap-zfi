"!<p>Classe processar Interface Modificação Data Agendamento da Parcela PDC</p>
"!<p><strong>Autor:</strong>Marcos Rubik</p>
"!<p><strong>Data:</strong> 11 de Março de 2022</p>
CLASS zclfi_interface_mod_agend_parc DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    METHODS processar
      IMPORTING
        !is_input  TYPE zclfi_mt_parcela_agendamento
      EXPORTING
        !es_output TYPE zclfi_mt_parcela_agendamento_r
      RAISING
        zcxca_erro_interface .
  PROTECTED SECTION.
  PRIVATE SECTION.

    CONSTANTS:
      BEGIN OF gc_erros,
        interface TYPE string VALUE 'SI_MODIFICAR_PARCELA_AGENDAMEN',
        metodo    TYPE string VALUE 'processar'                             ##NO_TEXT,
        classe    TYPE string VALUE 'ZCLFI_INTERFACE_MOD_AGEND_PARC'        ##NO_TEXT,
      END OF gc_erros .

    "! Return error raising
    METHODS error_raise
      IMPORTING
        !is_ret TYPE scx_t100key
      RAISING
        zcxca_erro_interface .
ENDCLASS.

CLASS zclfi_interface_mod_agend_parc IMPLEMENTATION.
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

  METHOD processar.
    DATA: lt_accchg   TYPE fdm_t_accchg.

    lt_accchg = VALUE #( ( fdname  = 'ZFBDT'
                           oldval  = CONV olddata( is_input-mt_parcela_agendamento-fdname )
                           newval  = CONV newdata( is_input-mt_parcela_agendamento-newval ) ) ).

    NEW zclfi_modificar_agend_parcela(  )->modificar(
      EXPORTING
        iv_bukrs  = CONV bukrs( is_input-mt_parcela_agendamento-bukrs )
        iv_belnr  = CONV belnr_d( is_input-mt_parcela_agendamento-belnr )
        iv_gjahr  = CONV gjahr( is_input-mt_parcela_agendamento-gjhar )
        iv_buzei  = CONV buzei( is_input-mt_parcela_agendamento-buzei )
        it_accchg = lt_accchg
      IMPORTING
        ev_msg    = DATA(lv_msg)
      RECEIVING
        rv_subrc  = DATA(lv_subrc) ).
    IF lv_subrc <> 0.
      es_output-mt_parcela_agendamento_resp-detalhe_falha = lv_msg.
    ELSE.
      es_output-mt_parcela_agendamento_resp-sucesso = abap_true.
    ENDIF.

  ENDMETHOD.
ENDCLASS.
