CLASS lhc__contrato DEFINITION INHERITING FROM cl_abap_behavior_handler.

  PUBLIC SECTION.
    METHODS setup_messages IMPORTING p_task TYPE clike.

  PRIVATE SECTION.

    METHODS aprovar FOR MODIFY
      IMPORTING keys FOR ACTION _contrato~aprovar.

    DATA gt_messages       TYPE STANDARD TABLE OF bapiret2.
    DATA gv_wait_async     TYPE abap_bool.


ENDCLASS.

CLASS lhc__contrato IMPLEMENTATION.

  METHOD aprovar.

    DATA(lv_observacao) = keys[ 1 ]-%param-observacao.


    READ ENTITIES OF zi_fi_cont_aprovacao IN LOCAL MODE
  ENTITY _contrato FIELDS ( docuuidh aditivo contrato ) WITH CORRESPONDING #( keys )
  RESULT DATA(lt_contrato)
  FAILED failed.

    IF lt_contrato IS NOT INITIAL.

      DATA(ls_contrato) = lt_contrato[ 1 ].

      CALL FUNCTION 'ZFMFI_APROVAR_CONTRATO'
        STARTING NEW TASK 'APROVARCONTRATO'
        CALLING setup_messages ON END OF TASK
        EXPORTING
          iv_observacao = lv_observacao
          iv_doc_uuid_h = ls_contrato-%key-docuuidh
          iv_contrato   = ls_contrato-%key-contrato
          iv_aditivo    = ls_contrato-%key-aditivo.

      WAIT UNTIL gv_wait_async = abap_true.



      IF ls_contrato-%key-aditivo IS INITIAL.
        DATA(lv_msg) = ls_contrato-%key-contrato.
      ELSE.
        lv_msg = ls_contrato-%key-aditivo.
      ENDIF.

      IF line_exists( gt_messages[ type = 'E' ] ).       "#EC CI_STDSEQ
        APPEND VALUE #( %tky = VALUE #( contrato = ls_contrato-%key-contrato )
                        %msg =  new_message( id       = 'ZFI_APROVAR_CONT'
                                             v1 = lv_msg
                                             number   = CONV #( '015' )
                                             severity = CONV #( 'E' ) ) ) TO reported-_contrato.

      ELSE.

        APPEND VALUE #( %tky = VALUE #( contrato = ls_contrato-%key-contrato )
                        %msg =  new_message( id       = 'ZFI_APROVAR_CONT'
                                             v1 = lv_msg
                                             number   = CONV #( '016' )
                                             severity = CONV #( 'S' ) ) ) TO reported-_contrato.

        APPEND VALUE #( %tky = VALUE #( contrato = ls_contrato-%key-contrato )
                        %msg =  new_message( id       = 'ZFI_APROVAR_CONT'
                                             v1 = lv_msg
                                             number   = CONV #( '017' )
                                             severity = CONV #( 'S' ) ) ) TO reported-_contrato.
      ENDIF.


*      IF line_exists( gt_messages[ type = 'E' ] ).       "#EC CI_STDSEQ
*        APPEND VALUE #(  %tky = ls_contrato-%tky ) TO failed-_contrato.
*      ENDIF.
*
*
*      LOOP AT gt_messages INTO DATA(ls_message).         "#EC CI_NESTED
*
*        APPEND VALUE #( %tky        = ls_contrato-%tky
*                        %msg        = new_message( id       = ls_message-id
*                                                   number   = ls_message-number
*                                                   v1       = ls_message-message_v1
*                                                   v2       = ls_message-message_v2
*                                                   v3       = ls_message-message_v3
*                                                   v4       = ls_message-message_v4
*                                                   severity = CONV #( ls_message-type ) )
*                         )
*          TO reported-_contrato.
*
*      ENDLOOP.

    ENDIF.

  ENDMETHOD.

  METHOD setup_messages.

    RECEIVE RESULTS FROM FUNCTION 'ZFMFI_APROVAR_CONTRATO'
          IMPORTING
            et_return = gt_messages.

    gv_wait_async = abap_true.

  ENDMETHOD.
ENDCLASS.
