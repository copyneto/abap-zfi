CLASS lcl__prov DEFINITION INHERITING FROM cl_abap_behavior_handler.

  PRIVATE SECTION.

    METHODS numcontrato FOR DETERMINE ON SAVE
      IMPORTING keys FOR _prov~numcontrato.

    METHODS validacampos FOR VALIDATE ON SAVE
      IMPORTING keys FOR _prov~validacampos.

ENDCLASS.

CLASS lcl__prov IMPLEMENTATION.

  METHOD numcontrato.

    READ ENTITIES OF zi_fi_contrato IN LOCAL MODE
         ENTITY _contrato
         ALL FIELDS
         WITH CORRESPONDING #( keys )
         RESULT DATA(lt_contrato).

    READ ENTITIES OF zi_fi_contrato IN LOCAL MODE
         ENTITY _prov
         ALL FIELDS
         WITH CORRESPONDING #( keys )
         RESULT DATA(lt_prov).

    READ TABLE lt_contrato ASSIGNING FIELD-SYMBOL(<fs_contrato>) INDEX 1.

    IF sy-subrc = 0.

      MODIFY ENTITIES OF zi_fi_contrato IN LOCAL MODE
             ENTITY _prov
             UPDATE SET FIELDS WITH VALUE #( FOR ls_prov IN lt_prov (
                                                 %key = ls_prov-%key
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
    READ ENTITIES OF zi_fi_contrato IN LOCAL MODE ENTITY _prov
         ALL FIELDS
         WITH CORRESPONDING #( keys )
         RESULT DATA(lt_prov).


    DATA(lo_contrato) = NEW zclfi_contrato_cliente_util( ).

* ---------------------------------------------------------------------------
* Valida campos
* ---------------------------------------------------------------------------
    LOOP AT lt_prov REFERENCE INTO DATA(ls_prov).

      lo_contrato->valida_prov( EXPORTING is_prov   = CORRESPONDING #( ls_prov->* )
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
