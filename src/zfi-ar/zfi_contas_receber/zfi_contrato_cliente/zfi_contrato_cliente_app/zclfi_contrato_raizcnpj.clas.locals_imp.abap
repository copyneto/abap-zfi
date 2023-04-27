CLASS lcl__raiz DEFINITION INHERITING FROM cl_abap_behavior_handler.

  PUBLIC SECTION.
    METHODS setup_messages IMPORTING p_task TYPE clike.


  PRIVATE SECTION.

    METHODS buscacliente FOR MODIFY
      IMPORTING keys FOR ACTION _raiz~buscacliente.

    METHODS get_features FOR FEATURES
      IMPORTING keys REQUEST requested_features FOR _raiz RESULT result.

    METHODS numcontrato FOR DETERMINE ON SAVE
      IMPORTING keys FOR _raiz~numcontrato.

    METHODS validacampos FOR VALIDATE ON SAVE
      IMPORTING keys FOR _raiz~validacampos.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR _Raiz RESULT result.

    DATA gt_messages       TYPE STANDARD TABLE OF bapiret2.
    DATA gv_wait_async     TYPE abap_bool.

ENDCLASS.

CLASS lcl__raiz IMPLEMENTATION.


  METHOD setup_messages.
    gv_wait_async = abap_true.
  ENDMETHOD.

  METHOD buscacliente.

*    READ ENTITIES OF zi_fi_contrato IN LOCAL MODE
*     ENTITY _contrato BY \_raiz FIELDS ( docuuidraiz )
*     WITH CORRESPONDING #( keys )
*     RESULT DATA(lt_cnpj_raiz).
*
*    IF lt_cnpj_raiz IS NOT INITIAL.
*
*      DATA(ls_key) = keys[ 1 ].
*
*      LOOP AT lt_cnpj_raiz ASSIGNING FIELD-SYMBOL(<Fs_cnpj_raiz>) WHERE cnpjraiz = ls_key-cnpjraiz ."#EC CI_STDSEQ

       LOOP AT keys REFERENCE INTO DATA(ls_keys).

        CALL FUNCTION 'ZFMFI_CONTROLE_RAIZ_CNPJ'
          STARTING NEW TASK 'CONTROLERAIZ'
          CALLING setup_messages ON END OF TASK
          EXPORTING
            iv_uuid = ls_keys->%key-docuuidraiz.

        WAIT UNTIL gv_wait_async = abap_true.

      ENDLOOP.

*    ENDIF.


*    READ ENTITIES OF zi_fi_contrato IN LOCAL MODE
*     ENTITY _contrato BY \_raiz ALL FIELDS
*     WITH CORRESPONDING #( keys )
*     RESULT DATA(lt_return)
*     FAILED failed.
*
*    result = VALUE #( FOR ls_return IN lt_return
*                       ( %tky   = ls_return-%tky ) ).


  ENDMETHOD.

  METHOD get_features.

    READ ENTITIES OF zi_fi_contrato IN LOCAL MODE
         ENTITY _raiz
         ALL FIELDS WITH CORRESPONDING #( keys )
         RESULT DATA(lt_raiz)
         FAILED failed.

    result = VALUE #( FOR ls_header IN lt_raiz
                    ( %tky = ls_header-%tky ) ).

  ENDMETHOD.

  METHOD numcontrato.

    READ ENTITIES OF zi_fi_contrato IN LOCAL MODE
         ENTITY _contrato
         ALL FIELDS
         WITH CORRESPONDING #( keys )
         RESULT DATA(lt_contrato).

    READ ENTITIES OF zi_fi_contrato IN LOCAL MODE
         ENTITY _raiz
         ALL FIELDS WITH CORRESPONDING #( keys )
         RESULT DATA(lt_raiz).

    READ TABLE lt_contrato ASSIGNING FIELD-SYMBOL(<fs_contrato>) INDEX 1.
    IF sy-subrc = 0.

      MODIFY ENTITIES OF zi_fi_contrato IN LOCAL MODE
      ENTITY _raiz
      UPDATE SET FIELDS WITH VALUE #( FOR ls_raiz IN lt_raiz (
                                          %key = ls_raiz-%key
                                          contrato = <fs_contrato>-contrato
                                          aditivo = <fs_contrato>-aditivo
                                      ) ) REPORTED DATA(lt_reported).

      reported = CORRESPONDING #( DEEP lt_reported ).
    ENDIF.

  ENDMETHOD.

  METHOD get_instance_authorizations.
    RETURN.
  ENDMETHOD.

  METHOD validaCampos.

    DATA: lt_return_all TYPE bapiret2_t.

* ---------------------------------------------------------------------------
* Recupera linhas selecionadas
* ---------------------------------------------------------------------------
    READ ENTITIES OF zi_fi_contrato IN LOCAL MODE
     ENTITY _raiz
     ALL FIELDS WITH CORRESPONDING #( keys )
     RESULT DATA(lt_raiz).

    DATA(lo_contrato) = NEW zclfi_contrato_cliente_util( ).

* ---------------------------------------------------------------------------
* Valida campos
* ---------------------------------------------------------------------------
    LOOP AT lt_raiz REFERENCE INTO DATA(ls_raiz).

      lo_contrato->valida_raiz( EXPORTING is_raiz   = CORRESPONDING #( ls_raiz->* )
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
