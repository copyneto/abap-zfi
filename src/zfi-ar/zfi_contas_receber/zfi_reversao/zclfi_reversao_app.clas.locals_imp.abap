"! <p class="shorttext synchronized">Classe para eventos de reversão </p>
"! Autor: Anderson Macedo
"! Data: 11/10/2021
CLASS lhc__estorno DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    "! Método de execução para leitura das chaves
    "! @parameter keys | Chaves
    METHODS read FOR READ
      IMPORTING keys FOR READ _estorno RESULT result.
    "! Ação do botão reversão
    "! @parameter keys | Chaves
    METHODS motivoestorno FOR MODIFY
      IMPORTING keys FOR ACTION _estorno~motivoestorno.

ENDCLASS.

CLASS lhc__estorno IMPLEMENTATION.

  METHOD read.

    SELECT *                                  "#EC CI_FAE_LINES_ENSURED
      FROM zi_fi_reversao_app
      FOR ALL ENTRIES IN @keys
      WHERE empresa       = @keys-empresa
        AND documento     = @keys-documento
        AND exercicio     = @keys-exercicio
        AND item          = @keys-item
        AND tpdocsub      = @keys-tpdocsub
        INTO TABLE @DATA(lt_estorno).

    result = CORRESPONDING #( lt_estorno ).

  ENDMETHOD.

  METHOD motivoestorno.

    DATA lt_rev TYPE TABLE OF zi_fi_reversao_app WITH DEFAULT KEY.

    READ ENTITIES OF zi_fi_reversao_app IN LOCAL MODE
        ENTITY _estorno
        ALL FIELDS WITH CORRESPONDING #( keys )
        RESULT DATA(lt_estorno).

    MOVE-CORRESPONDING lt_estorno TO lt_rev.

    DATA(lo_estorno) = NEW zclfi_exec_reversao( it_reversao = lt_rev ).

    reported-_estorno = VALUE #( FOR ls_key IN keys
                                 FOR ls_mensagem IN lo_estorno->execute( iv_doc    = ls_key-documento
                                                                         iv_emp    = ls_key-empresa
                                                                         iv_year   = ls_key-exercicio
                                                                         iv_tpsub  = ls_key-tpdocsub
                                                                         is_mot    = ls_key-%param
                                                                         iv_app    = abap_true )
                                 ( %tky = VALUE #( documento = ls_key-documento
                                                   empresa   = ls_key-empresa
                                                   exercicio = ls_key-exercicio
                                                   item      = ls_key-item     )
                                   %msg = new_message(
                                                       id       = ls_mensagem-id
                                                       number   = ls_mensagem-number
                                                       severity = CONV #( ls_mensagem-type )
                                                       v1       = ls_mensagem-message_v1
                                                       v2       = ls_mensagem-message_v2
                                                       v3       = ls_mensagem-message_v3
                                                       v4       = ls_mensagem-message_v4  ) ) ).

  ENDMETHOD.

ENDCLASS.

CLASS lsc_zi_fi_reversao_app DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.

    METHODS check_before_save REDEFINITION.

    METHODS finalize          REDEFINITION.

    METHODS save              REDEFINITION.

ENDCLASS.

CLASS lsc_zi_fi_reversao_app IMPLEMENTATION.

  METHOD check_before_save.
    RETURN.
  ENDMETHOD.

  METHOD finalize.
    RETURN.
  ENDMETHOD.

  METHOD save.
    RETURN.
  ENDMETHOD.

ENDCLASS.
