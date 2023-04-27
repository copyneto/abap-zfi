CLASS lcl_contrato DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PUBLIC SECTION.
    METHODS setup_messages IMPORTING p_task TYPE clike.

  PRIVATE SECTION.

    METHODS renovarcontrato FOR MODIFY
      IMPORTING keys FOR ACTION contrato~renovarcontrato.

    DATA gt_messages       TYPE STANDARD TABLE OF bapiret2.
    DATA gv_wait_async     TYPE abap_bool.

ENDCLASS.

CLASS lcl_contrato IMPLEMENTATION.

  METHOD renovarcontrato.

    DATA(lv_new_data_fim) = keys[ 1 ]-%param-absdatafimvalid.
*    DATA(lv_new_data_ini) = keys[ 1 ]-%param-absdatainivalid.


    READ ENTITIES OF zi_fi_renovacao_contrato IN LOCAL MODE
  ENTITY contrato FIELDS ( docuuidh aditivo contrato ) WITH CORRESPONDING #( keys )
  RESULT DATA(lt_contrato)
  FAILED failed.

    IF lt_contrato IS NOT INITIAL.

      DATA(ls_contrato) = lt_contrato[ 1 ].

      CALL FUNCTION 'ZFMFI_RENOVACAO_DE_CONTRATO'
        STARTING NEW TASK 'RENOVACONTRATO'
        CALLING setup_messages ON END OF TASK
        EXPORTING
*         iv_data_inicio = lv_new_data_ini
          iv_data_fim   = lv_new_data_fim
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
                        %msg =  new_message( id       = 'ZCLM_RENOVAR_CONTRAT'
                                             v1 = lv_msg
                                             number   = CONV #( '001' )
                                             severity = CONV #( 'E' ) ) ) TO reported-contrato.

      ELSE.

        APPEND VALUE #( %tky = VALUE #( contrato = ls_contrato-%key-contrato )
                        %msg =  new_message( id       = 'ZCLM_RENOVAR_CONTRAT'
                                             v1 = lv_msg
                                             number   = CONV #( '002' )
                                             severity = CONV #( 'S' ) ) ) TO reported-contrato.

        APPEND VALUE #( %tky = VALUE #( contrato = ls_contrato-%key-contrato )
                        %msg =  new_message( id       = 'ZCLM_RENOVAR_CONTRAT'
                                             v1 = lv_msg
                                             number   = CONV #( '000' )
                                             severity = CONV #( 'S' ) ) ) TO reported-contrato.
      ENDIF.
    ENDIF.


  ENDMETHOD.

  METHOD setup_messages.

*    RECEIVE RESULTS FROM FUNCTION 'ZFMFI_CONTROLE_RAIZ_CNPJ'
    RECEIVE RESULTS FROM FUNCTION 'ZFMFI_RENOVACAO_DE_CONTRATO'
         IMPORTING
           et_return = gt_messages.

    gv_wait_async = abap_true.

  ENDMETHOD.

ENDCLASS.
