CLASS lcl_ordem DEFINITION INHERITING FROM cl_abap_behavior_handler.

  PUBLIC SECTION.

  PRIVATE SECTION.

    METHODS validacampos FOR VALIDATE ON SAVE
      IMPORTING keys FOR _janela~validacampos.

    METHODS numcontrato FOR DETERMINE ON SAVE
      IMPORTING keys FOR _janela~numcontrato.


ENDCLASS.

CLASS lcl_ordem IMPLEMENTATION.


  METHOD validacampos.

    DATA: lt_return_all TYPE bapiret2_t.

* ---------------------------------------------------------------------------
* Recupera linhas selecionadas
* ---------------------------------------------------------------------------
    READ ENTITIES OF zi_fi_contrato IN LOCAL MODE
        ENTITY _janela
        ALL FIELDS
        WITH CORRESPONDING #( keys )
        RESULT DATA(lt_janela).

    DATA(lo_contrato) = NEW zclfi_contrato_cliente_util( ).

* ---------------------------------------------------------------------------
* Valida campos
* ---------------------------------------------------------------------------
    LOOP AT lt_janela REFERENCE INTO DATA(ls_janela).

      lo_contrato->valida_janela( EXPORTING is_janela = CORRESPONDING #( ls_janela->* )
                                  IMPORTING et_return = DATA(lt_return) ).

      INSERT LINES OF lt_return[] INTO TABLE lt_return_all[].
    ENDLOOP.
* ---------------------------------------------------------------------------
* Monta mensagens de retorno
* ---------------------------------------------------------------------------
    lo_contrato->reported( EXPORTING it_return   = lt_return_all
                           IMPORTING es_reported = DATA(lt_reported) ).

    reported = CORRESPONDING #( DEEP lt_reported ).

  ENDMETHOD.

  METHOD numcontrato.

    READ ENTITIES OF zi_fi_contrato IN LOCAL MODE
        ENTITY _contrato
        ALL FIELDS
        WITH CORRESPONDING #( keys )
        RESULT DATA(lt_contrato).

    READ ENTITIES OF zi_fi_contrato IN LOCAL MODE
        ENTITY _janela
        ALL FIELDS
        WITH CORRESPONDING #( keys )
        RESULT DATA(lt_janela).

    READ TABLE lt_contrato ASSIGNING FIELD-SYMBOL(<fs_contrato>) INDEX 1.

    IF sy-subrc = 0.

      MODIFY ENTITIES OF zi_fi_contrato IN LOCAL MODE
      ENTITY _janela
      UPDATE SET FIELDS WITH VALUE #( FOR ls_janela IN lt_janela (
                                          %key = ls_janela-%key
                                          contrato = <fs_contrato>-contrato
                                          aditivo = <fs_contrato>-aditivo
                                      ) ) REPORTED DATA(lt_reported).

      reported = CORRESPONDING #( DEEP lt_reported ).

    ENDIF.

  ENDMETHOD.

ENDCLASS.

*"* use this source file for the definition and implementation of
*"* local helper classes, interface definitions and type
*"* declarations
