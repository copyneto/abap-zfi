CLASS lcl__provfamilia DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS validacampos FOR VALIDATE ON SAVE
      IMPORTING keys FOR _provfamilia~validacampos.
    METHODS numcontrato FOR DETERMINE ON SAVE
      IMPORTING keys FOR _provfamilia~numcontrato.

ENDCLASS.

CLASS lcl__provfamilia IMPLEMENTATION.

  METHOD validacampos.

    DATA: lt_return_all TYPE bapiret2_t.

* ---------------------------------------------------------------------------
* Recupera linhas selecionadas
* ---------------------------------------------------------------------------
    READ ENTITIES OF zi_fi_contrato IN LOCAL MODE
     ENTITY _provfamilia
     ALL FIELDS WITH CORRESPONDING #( keys )
     RESULT DATA(lt_familia).

    DATA(lo_contrato) = NEW zclfi_contrato_cliente_util( ).

* ---------------------------------------------------------------------------
* Valida campos
* ---------------------------------------------------------------------------
    LOOP AT lt_familia REFERENCE INTO DATA(ls_familia).

      lo_contrato->valida_prov_familia( EXPORTING is_familia = CORRESPONDING #( ls_familia->* )
                                        IMPORTING et_return  = DATA(lt_return) ).

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
         ENTITY _provfamilia
         ALL FIELDS
         WITH CORRESPONDING #( keys )
         RESULT DATA(lt_prov).

    READ TABLE lt_contrato ASSIGNING FIELD-SYMBOL(<fs_contrato>) INDEX 1.

    IF sy-subrc = 0.

      MODIFY ENTITIES OF zi_fi_contrato IN LOCAL MODE
             ENTITY _provfamilia
             UPDATE SET FIELDS WITH VALUE #( FOR ls_prov IN lt_prov (
                                                 %key = ls_prov-%key
                                                 contrato = <fs_contrato>-contrato
                                                 aditivo = <fs_contrato>-aditivo
                                             ) ) REPORTED DATA(lt_reported).

      reported = CORRESPONDING #( DEEP lt_reported ).

    ENDIF.


  ENDMETHOD.

ENDCLASS.
