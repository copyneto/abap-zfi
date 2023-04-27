CLASS lhc__anexos DEFINITION INHERITING FROM cl_abap_behavior_handler.

  PUBLIC SECTION.
    METHODS setup_messages IMPORTING p_task TYPE clike.

  PRIVATE SECTION.

    METHODS eliminar FOR MODIFY
      IMPORTING keys FOR ACTION _anexos~eliminar.

    METHODS get_features FOR FEATURES
      IMPORTING keys REQUEST requested_features FOR _anexos RESULT result.
    METHODS numcontrato FOR DETERMINE ON SAVE
      IMPORTING keys FOR _anexos~numcontrato.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR _Anexos RESULT result.

    DATA gt_messages       TYPE STANDARD TABLE OF bapiret2.
    DATA gv_wait_async     TYPE abap_bool.

ENDCLASS.

CLASS lhc__anexos IMPLEMENTATION.

  METHOD eliminar.

    DATA(ls_key) = keys[ 1 ].

    SELECT *
    FROM ztfi_cont_anexo
    INTO TABLE @DATA(lt_anexo)
    WHERE doc_uuid_doc = @ls_key-docuuiddoc
      AND doc_uuid_h   = @ls_key-docuuidh.

    IF sy-subrc IS INITIAL.

      DELETE ztfi_cont_anexo FROM TABLE lt_anexo.

      DATA(ls_anexo) = lt_anexo[ 1 ].

    ENDIF.

    IF ls_anexo IS NOT INITIAL.

      CALL FUNCTION 'ZFMFI_CONTROLE_ANEXO'
        STARTING NEW TASK 'CONTROLEANEXO'
        CALLING setup_messages ON END OF TASK
        EXPORTING
          iv_uuid  = ls_key-docuuidh
          iv_anexo = ls_anexo-tipo_doc.

      WAIT UNTIL gv_wait_async = abap_true.
      IF line_exists( gt_messages[ type = 'E' ] ).       "#EC CI_STDSEQ

        LOOP AT gt_messages INTO DATA(ls_message).       "#EC CI_NESTED

          APPEND VALUE #( %msg        = new_message( id       = ls_message-id
                                                     number   = ls_message-number
                                                     v1       = ls_message-message_v1
                                                     v2       = ls_message-message_v2
                                                     v3       = ls_message-message_v3
                                                     v4       = ls_message-message_v4
                                                     severity = CONV #( ls_message-type ) )
                           )
            TO reported-_contrato.

        ENDLOOP.

      ELSE.

        APPEND VALUE #( %msg =  new_message( id       = 'ZFI_CONTRATO_CLIENTE'
                         number   = CONV #( '009' )
                         severity = CONV #( 'S' ) ) ) TO reported-_contrato.

*        APPEND VALUE #( %msg =  new_message( id       = 'ZFI_CONTRATO_CLIENTE'
*                 number   = CONV #( '008' )
*                 severity = CONV #( 'S' ) ) ) TO reported-_contrato.


      ENDIF.
    ENDIF.


  ENDMETHOD.

  METHOD get_features.

    READ ENTITIES OF zi_fi_contrato IN LOCAL MODE
   ENTITY _anexos
   ALL FIELDS WITH CORRESPONDING #( keys )
   RESULT DATA(lt_anexo)
   FAILED failed.

    result =
        VALUE #(
        FOR ls_header IN lt_anexo
          ( %tky              = ls_header-%tky
           ) ).

  ENDMETHOD.

  METHOD setup_messages.
    gv_wait_async = abap_true.
  ENDMETHOD.

  METHOD numcontrato.

    READ ENTITIES OF zi_fi_contrato IN LOCAL MODE
    ENTITY _contrato
    ALL FIELDS
    WITH CORRESPONDING #( keys )
    RESULT DATA(lt_contrato).

    READ ENTITIES OF zi_fi_contrato IN LOCAL MODE
   ENTITY _anexos
   ALL FIELDS WITH CORRESPONDING #( keys )
   RESULT DATA(lt_anexo).

    READ TABLE lt_contrato ASSIGNING FIELD-SYMBOL(<fs_contrato>) INDEX 1.
    IF sy-subrc = 0.

      MODIFY ENTITIES OF zi_fi_contrato IN LOCAL MODE
      ENTITY _anexos
      UPDATE SET FIELDS WITH VALUE #( FOR ls_anexo IN lt_anexo (
                                          %key = ls_anexo-%key
                                          contrato = <fs_contrato>-contrato
                                          aditivo = <fs_contrato>-aditivo
                                      ) ) REPORTED DATA(lt_reported).

      reported = CORRESPONDING #( DEEP lt_reported ).

    ENDIF.

  ENDMETHOD.

  METHOD get_instance_authorizations.
    RETURN.
  ENDMETHOD.

ENDCLASS.
