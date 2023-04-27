CLASS lhc__alertacont DEFINITION INHERITING FROM cl_abap_behavior_handler.

  PUBLIC SECTION.

    METHODS setup_messages IMPORTING p_task TYPE clike.

  PRIVATE SECTION.

    METHODS enviar_email FOR MODIFY
      IMPORTING keys FOR ACTION _alertacont~enviar_email RESULT result.

    DATA gv_wait_async     TYPE abap_bool.
    DATA gt_messages       TYPE STANDARD TABLE OF bapiret2.

    METHODS get_authorizations FOR AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR _alertacont RESULT result.

ENDCLASS.

CLASS lhc__alertacont IMPLEMENTATION.

  METHOD enviar_email.
    TYPES: BEGIN OF  ty_envio,
             doc_uuid_h        TYPE ztfi_contrato-doc_uuid_h,
             contrato          TYPE ztfi_contrato-contrato,
             aditivo           TYPE ztfi_contrato-aditivo,
             data_fim_valid    TYPE ztfi_contrato-data_fim_valid,
             bukrs             TYPE ztfi_contrato-bukrs,
             branch            TYPE ztfi_contrato-branch,
             prazo_pagto       TYPE ztfi_contrato-prazo_pagto,
             renov_aut         TYPE ztfi_contrato-renov_aut,
             alerta_enviado    TYPE ztfi_contrato-alerta_enviado,
             alerta_data_envio TYPE ztfi_contrato-alerta_data_envio,
             email             TYPE ztfi_contratos13-email.
    TYPES: END OF ty_envio .

    DATA: lt_env   TYPE zctgfi_rfc_envioemail.
    DATA: ls_cont  TYPE  ztfi_contratos13.
    DATA: lt_envio TYPE zctgfi_rfc_envioemail.
    DATA: lv_status_retorno TYPE char1.

* ---------------------------------------------------------------------------
* Recupera informações do cabeçalho
* ---------------------------------------------------------------------------

    READ ENTITIES OF zi_fi_alerta_vigencia_contrato IN LOCAL MODE
     ENTITY _alertacont ALL FIELDS
     WITH CORRESPONDING #( keys )
     RESULT DATA(lt_contrato).

*      READ ENTITIES OF zi_fi_alerta_vigencia_contrato IN LOCAL MODE
*      ENTITY _AlertaCont
*        FIELDS ( Contrato Aditivo ) WITH CORRESPONDING #( keys )
*      RESULT DATA(lt_contrato)
*      FAILED failed.

* ---------------------------------------------------------------------------
* Seleciona endereço de e-mail
* ---------------------------------------------------------------------------
*    SELECT empresa, local_negocio, email      "#EC CI_FAE_LINES_ENSURED
*    FROM ztfi_contratos13
*    INTO TABLE @DATA(lt_contrat)
*    FOR ALL ENTRIES IN @lt_contrato
*    WHERE empresa EQ @lt_contrato-Empresa
*    AND local_negocio EQ @lt_contrato-Local_negocio.


    LOOP AT lt_contrato ASSIGNING FIELD-SYMBOL(<fs_envio>).

*      LOOP AT lt_contrat ASSIGNING FIELD-SYMBOL(<fs_cont>) WHERE empresa      = <fs_envio>-empresa "#EC CI_STDSEQ
*                                                           AND  local_negocio = <fs_envio>-local_negocio.
      APPEND INITIAL LINE TO lt_env ASSIGNING FIELD-SYMBOL(<fs_envio_email>).

*        IF sy-subrc EQ 0.
      <fs_envio_email>-doc_uuid_h        = <fs_envio>-docuuidh.
      <fs_envio_email>-contrato          = <fs_envio>-contrato.
      <fs_envio_email>-aditivo           = <fs_envio>-aditivo.
      <fs_envio_email>-data_fim_valid    = <fs_envio>-datafimvalid.
      <fs_envio_email>-bukrs             = <fs_envio>-empresa.
      <fs_envio_email>-branch            = <fs_envio>-local_negocio.
      <fs_envio_email>-prazo_pagto       = <fs_envio>-prazopagto.
      <fs_envio_email>-renov_aut         = <fs_envio>-renovaut.
      <fs_envio_email>-razao_social      = <fs_envio>-razao_social.
      <fs_envio_email>-cnpj_principal    = <fs_envio>-cnpj_principal.
      <fs_envio_email>-alerta_enviado    = <fs_envio>-alertaenviado.
      <fs_envio_email>-alerta_data_envio = <fs_envio>-alertadataenvio.
*        ENDIF.
*      ENDLOOP.
    ENDLOOP.

    lt_envio =  lt_env[].

    CLEAR: gv_wait_async, gt_messages.
* ---------------------------------------------------------------------------
* FM de envio de email
* ---------------------------------------------------------------------------
    CALL FUNCTION 'ZFMFI_ENVIO_EMAILAPP'
      STARTING NEW TASK 'ENVIO_EMAIL'
      CALLING setup_messages ON END OF TASK
      EXPORTING
        it_envio = lt_envio.

    WAIT UNTIL gv_wait_async = abap_true.

    READ TABLE lt_contrato ASSIGNING FIELD-SYMBOL(<fs_envio1>) INDEX 1.

    IF line_exists( gt_messages[ type = 'E' ] ).         "#EC CI_STDSEQ
      APPEND VALUE #(  %tky = <fs_envio1>-%tky ) TO failed-_alertacont.
    ENDIF.

    LOOP AT gt_messages INTO DATA(ls_message).           "#EC CI_NESTED

      APPEND VALUE #( %tky        = <fs_envio1>-%tky
                      %msg        = new_message( id       = ls_message-id
                                                 number   = ls_message-number
                                                 v1       = ls_message-message_v1
                                                 v2       = ls_message-message_v2
                                                 v3       = ls_message-message_v3
                                                 v4       = ls_message-message_v4
                                                 severity = CONV #( ls_message-type ) )
                       )
        TO reported-_alertacont.

    ENDLOOP.

    READ ENTITIES OF zi_fi_alerta_vigencia_contrato IN LOCAL MODE
      ENTITY _alertacont
      ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(lt_result)
      FAILED failed.

    result = VALUE #( FOR ls_int IN lt_result
                       ( %tky   = ls_int-%tky
                         %param = ls_int ) ).


  ENDMETHOD.



  METHOD setup_messages.

    RECEIVE RESULTS FROM FUNCTION 'ZFMFI_ENVIO_EMAILAPP'
           IMPORTING
             et_return = gt_messages.

    gv_wait_async = abap_true.

  ENDMETHOD.

  METHOD get_authorizations.

    READ ENTITIES OF zi_fi_alerta_vigencia_contrato IN LOCAL MODE
    ENTITY _alertacont
    ALL FIELDS WITH CORRESPONDING #( keys )
    RESULT DATA(lt_data)
    FAILED failed.

    CHECK lt_data IS NOT INITIAL.

    DATA: lv_update TYPE if_abap_behv=>t_xflag,
          lv_delete TYPE if_abap_behv=>t_xflag.

    LOOP AT lt_data ASSIGNING FIELD-SYMBOL(<fs_data>).

      IF requested_authorizations-%update EQ if_abap_behv=>mk-on.

        IF zclfi_auth_zfibukrs=>bukrs_update( <fs_data>-empresa ).
          lv_update = if_abap_behv=>auth-allowed.
        ELSE.
          lv_update = if_abap_behv=>auth-unauthorized.
        ENDIF.

      ENDIF.


      APPEND VALUE #( %tky = <fs_data>-%tky
                      %update = lv_update )
             TO result.

    ENDLOOP.


  ENDMETHOD.

ENDCLASS.
