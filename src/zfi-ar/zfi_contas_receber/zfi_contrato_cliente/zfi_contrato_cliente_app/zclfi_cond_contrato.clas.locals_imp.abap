CLASS lhc_ordem DEFINITION INHERITING FROM cl_abap_behavior_handler.

  PUBLIC SECTION.

  PRIVATE SECTION.

    METHODS updatecurrency FOR DETERMINE ON MODIFY
      IMPORTING keys FOR _cond~updatecurrency.
    METHODS numcontrato FOR DETERMINE ON SAVE
      IMPORTING keys FOR _cond~numcontrato.
    METHODS validacampos FOR VALIDATE ON SAVE
      IMPORTING keys FOR _cond~validacampos.
ENDCLASS.

CLASS lhc_ordem IMPLEMENTATION.

  METHOD updatecurrency.

    READ ENTITIES OF zi_fi_contrato IN LOCAL MODE
    ENTITY _cond
    ALL FIELDS
    WITH CORRESPONDING #( keys )
    RESULT DATA(lt_cond).

    MODIFY ENTITIES OF zi_fi_contrato IN LOCAL MODE
    ENTITY _cond
    UPDATE SET FIELDS WITH VALUE #( FOR ls_cond IN lt_cond (
                                        %key = ls_cond-%key
                                        moeda = 'BRL'
                                        %control = VALUE #( moeda = if_abap_behv=>mk-on )
                                    ) ) REPORTED DATA(lt_reported).

    reported = CORRESPONDING #( DEEP lt_reported ).


  ENDMETHOD.

  METHOD numcontrato.

    READ ENTITIES OF zi_fi_contrato IN LOCAL MODE
    ENTITY _contrato
    ALL FIELDS
    WITH CORRESPONDING #( keys )
    RESULT DATA(lt_contrato).

    READ ENTITIES OF zi_fi_contrato IN LOCAL MODE
    ENTITY _cond
    ALL FIELDS
    WITH CORRESPONDING #( keys )
    RESULT DATA(lt_cond).

    READ TABLE lt_contrato ASSIGNING FIELD-SYMBOL(<fs_contrato>) INDEX 1.
    IF sy-subrc = 0.

      MODIFY ENTITIES OF zi_fi_contrato IN LOCAL MODE
      ENTITY _cond
      UPDATE SET FIELDS WITH VALUE #( FOR ls_cond IN lt_cond (
                                          %key = ls_cond-%key
                                          contrato = <fs_contrato>-contrato
                                          aditivo = <fs_contrato>-aditivo
                                      ) ) REPORTED DATA(lt_reported).

      reported = CORRESPONDING #( DEEP lt_reported ).

    ENDIF.

  ENDMETHOD.


  METHOD validaCampos.

    DATA: lt_return_all TYPE bapiret2_t.

* ---------------------------------------------------------------------------
* Recupera linhas selecionadas
* ---------------------------------------------------------------------------
    READ ENTITIES OF zi_fi_contrato IN LOCAL MODE ENTITY _Cond
        ALL FIELDS
        WITH CORRESPONDING #( keys )
        RESULT DATA(lt_cond).

    DATA(lo_contrato) = NEW zclfi_contrato_cliente_util( ).

* ---------------------------------------------------------------------------
* Valida campos
* ---------------------------------------------------------------------------
    LOOP AT lt_cond REFERENCE INTO DATA(ls_cond).

      lo_contrato->valida_cond( EXPORTING is_cond   = CORRESPONDING #( ls_cond->* )
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

ENDCLASS.

*"* use this source file for the definition and implementation of
*"* local helper classes, interface definitions and type
*"* declarations
