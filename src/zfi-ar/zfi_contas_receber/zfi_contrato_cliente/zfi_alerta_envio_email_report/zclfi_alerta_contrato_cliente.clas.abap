class ZCLFI_ALERTA_CONTRATO_CLIENTE definition
  public
  final
  create public .

public section.

  types:
    ty_aditivo TYPE RANGE OF ztfi_contrato-aditivo .
  types:
    BEGIN OF  ty_contrato,
        doc_uuid_h        TYPE ztfi_contrato-doc_uuid_h,
        contrato          TYPE ztfi_contrato-contrato,
        aditivo           TYPE ztfi_contrato-aditivo,
        data_fim_valid    TYPE ztfi_contrato-data_fim_valid,
        bukrs             TYPE ztfi_contrato-bukrs,
        branch            TYPE ztfi_contrato-branch,
        prazo_pagto       TYPE ztfi_contrato-prazo_pagto,
        renov_aut         TYPE ztfi_contrato-renov_aut,
        alerta_enviado    TYPE ztfi_contrato-alerta_enviado,
        alerta_data_envio TYPE ztfi_contrato-alerta_data_envio.
    TYPES: END OF ty_contrato .
  types:
    BEGIN OF  ty_envio,
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
  types:
    ty_ncontrato TYPE RANGE OF ztfi_contrato-contrato .

  data:
    gt_contrato TYPE STANDARD TABLE OF ty_contrato .
  data:
    gt_contrato_fim TYPE STANDARD TABLE OF ty_contrato .
*  data:
*    gt_envio_email TYPE SORTED TABLE OF ty_envio WITH NON-UNIQUE KEY contrato .
  data GT_ENVIO_EMAIL type ZCTGFI_RFC_ENVIOEMAIL .

    "!
    "! @parameter IV_CONTRATO | Parametro da tela de seleção do report
    "! @parameter IV_ADITIVO | Parametro da tela de seleção do report
    "! @parameter ET_ENVIO | Tabela de retornno do metodo com a validações
  methods EXECUTE
    importing
      !IV_CONTRATO type TY_NCONTRATO optional
      !IV_ADITIVO type TY_ADITIVO optional
    exporting
      value(ET_ENVIO) type TY_ENVIO .
protected section.
private section.

  data GS_RETURN type BAPIRET2 .
  data GT_RETURN type BAPIRET2_T .
  data GV_JOB type BTCJOB .
  data GV_LOG_HANDLE type BALLOGHNDL .

  methods MESSAGE_SAVE
    importing
      !IS_MSG type BAPIRET2 .
  methods INITIALIZE_LOG .
  "!
  "! @parameter IV_CONTRATO | Parametro da tela de seleção do report
  "! @parameter IV_ADITIVO |Parametro da tela de seleção do report
  methods SELECT_CONTRATO
    importing
      !IV_CONTRATO type TY_NCONTRATO optional
      !IV_ADITIVO type TY_ADITIVO optional .
  methods CONTAGEM_FIM_CONTRATO .
  methods VERIFICA_ALERTA_ENVIADO .
  methods OBTER_EMAIL .
ENDCLASS.



CLASS ZCLFI_ALERTA_CONTRATO_CLIENTE IMPLEMENTATION.


  METHOD contagem_fim_contrato.

    CONSTANTS: BEGIN OF lc_param,
                 modulo TYPE zi_ca_param_mod-modulo VALUE 'FI-AR',
                 "! Chave
                 chave1 TYPE zi_ca_param_par-chave1 VALUE 'VIGENCIA',
                 "! Chave
                 chave2 TYPE zi_ca_param_par-chave2 VALUE 'QUANTIDADE_DIAS',
               END OF lc_param.

    DATA(lo_param) = NEW zclca_tabela_parametros( ).
    DATA(lv_dias) = VALUE char10(  ).
    DATA: lt_cont TYPE STANDARD TABLE OF ty_contrato .

    DATA: lv_data_dias TYPE p.
    DATA(lv_data) = VALUE sy-datum( ).


    TRY.
        lo_param->m_get_single(
          EXPORTING
            iv_modulo = lc_param-modulo
            iv_chave1 = lc_param-chave1
            iv_chave2 = lc_param-chave2
          IMPORTING
            ev_param  = lv_dias
        ).
      CATCH zcxca_tabela_parametros.

    ENDTRY.

    CLEAR: gt_contrato_fim.

    LOOP AT gt_contrato  ASSIGNING FIELD-SYMBOL(<fs_contrato>).

      APPEND INITIAL LINE TO lt_cont ASSIGNING FIELD-SYMBOL(<fs_contrato_fim>).

      lv_data = <fs_contrato>-data_fim_valid.

      CALL FUNCTION 'SD_DATETIME_DIFFERENCE' ##COMPATIBLE
        EXPORTING
          date1            = sy-datum
          time1            = sy-uzeit
          date2            = lv_data
          time2            = sy-uzeit
        IMPORTING
          datediff         = lv_data_dias
        EXCEPTIONS
          invalid_datetime = 1
          OTHERS           = 2.

      IF sy-subrc EQ 0.
        IF lv_data_dias LE lv_dias.
          <fs_contrato_fim>-doc_uuid_h        = <fs_contrato>-doc_uuid_h.
          <fs_contrato_fim>-contrato          = <fs_contrato>-contrato.
          <fs_contrato_fim>-aditivo           = <fs_contrato>-aditivo.
          <fs_contrato_fim>-data_fim_valid    = <fs_contrato>-data_fim_valid.
          <fs_contrato_fim>-bukrs             = <fs_contrato>-bukrs.
          <fs_contrato_fim>-branch            = <fs_contrato>-branch.
          <fs_contrato_fim>-prazo_pagto       = <fs_contrato>-prazo_pagto.
          <fs_contrato_fim>-renov_aut         = <fs_contrato>-renov_aut.
          <fs_contrato_fim>-alerta_enviado    = <fs_contrato>-alerta_enviado.
          <fs_contrato_fim>-alerta_data_envio = <fs_contrato>-alerta_data_envio.

        ENDIF.
      ENDIF.


  ENDLOOP.

  gt_contrato_fim = lt_cont[].

ENDMETHOD.


  METHOD execute.
    DATA: lv_status_retorno TYPE char1.
    DATA lo_cl_envio TYPE REF TO zclfi_envio_email_alerta.
    CREATE OBJECT lo_cl_envio.

    initialize_log( ).
    select_contrato( iv_contrato = iv_contrato
                     iv_aditivo =  iv_aditivo ).
    contagem_fim_contrato( ).
    verifica_alerta_enviado( ).
    obter_email( ).
    lo_cl_envio->envio_emailapp( EXPORTING   it_emailapp        = gt_envio_email
                                  IMPORTING  ev_status_retorno = lv_status_retorno ).

  ENDMETHOD.                                             "#EC CI_VALPAR


  METHOD obter_email.
    DATA: ls_cont TYPE ztfi_contratos13.
    DATA: lt_cont TYPE STANDARD TABLE OF ty_envio.    "ZCTGFI_RFC_ENVIOEMAIL
    CLEAR: gt_envio_email.

    SELECT empresa, local_negocio, email      "#EC CI_FAE_LINES_ENSURED
    FROM ztfi_contratos13
    INTO TABLE @DATA(lt_env)
    FOR ALL ENTRIES IN @gt_contrato
    WHERE empresa EQ @gt_contrato-bukrs
    AND local_negocio EQ @gt_contrato-branch.


    LOOP AT gt_contrato ASSIGNING FIELD-SYMBOL(<fs_envio>). "#EC CI_STDSEQ

      LOOP AT lt_env ASSIGNING FIELD-SYMBOL(<fs_env>) WHERE empresa = <fs_envio>-bukrs "#EC CI_STDSEQ
                                                      AND   local_negocio = <fs_envio>-branch.
        APPEND INITIAL LINE TO lt_cont ASSIGNING FIELD-SYMBOL(<fs_envio_email>).

        IF sy-subrc EQ 0.

          <fs_envio_email>-doc_uuid_h        = <fs_envio>-doc_uuid_h.
          <fs_envio_email>-contrato          = <fs_envio>-contrato.
          <fs_envio_email>-aditivo           = <fs_envio>-aditivo.
          <fs_envio_email>-data_fim_valid    = <fs_envio>-data_fim_valid.
          <fs_envio_email>-bukrs             = <fs_envio>-bukrs.
          <fs_envio_email>-branch            = <fs_envio>-branch.
          <fs_envio_email>-prazo_pagto       = <fs_envio>-prazo_pagto.
          <fs_envio_email>-renov_aut         = <fs_envio>-renov_aut.
          <fs_envio_email>-alerta_enviado    = <fs_envio>-alerta_enviado.
          <fs_envio_email>-alerta_data_envio = <fs_envio>-alerta_data_envio.
          <fs_envio_email>-email             = <fs_env>-email.

        ENDIF.
      ENDLOOP.

    ENDLOOP.

    gt_envio_email = lt_cont[].


  ENDMETHOD.


  METHOD select_contrato.

    CONSTANTS: BEGIN OF lc_param,
                 modulo TYPE zi_ca_param_mod-modulo VALUE 'FI-AR',
                 "! Chave
                 chave1 TYPE zi_ca_param_par-chave1 VALUE 'VIGENCIA',
                 "! Chave
                 chave2 TYPE zi_ca_param_par-chave2 VALUE 'ALERTA',
               END OF lc_param.

    DATA(lo_param) = NEW zclca_tabela_parametros( ).
    DATA(lv_automatico) = VALUE abap_bool(  ).

    TRY.
        lo_param->m_get_single(
          EXPORTING
            iv_modulo = lc_param-modulo
            iv_chave1 = lc_param-chave1
            iv_chave2 = lc_param-chave2
          IMPORTING
            ev_param  = lv_automatico
        ).
      CATCH zcxca_tabela_parametros.

    ENDTRY.

    IF lv_automatico IS NOT INITIAL.

      SELECT doc_uuid_h, contrato, aditivo, data_fim_valid, bukrs, branch,"#EC CI_NOFIELD
      prazo_pagto,renov_aut, alerta_enviado, alerta_data_envio
      FROM  ztfi_contrato
      WHERE contrato   IN @iv_contrato
        AND aditivo    IN @iv_aditivo
        AND alerta_vig EQ @abap_true
        AND renov_aut  EQ @space
      INTO TABLE @gt_contrato.

      IF sy-subrc IS NOT INITIAL.

        MESSAGE e001 INTO DATA(lv_dummy1).

        gs_return-type       = sy-msgty.
        gs_return-id         = sy-msgid.
        gs_return-number     = sy-msgno.
        gs_return-message_v1 = sy-msgv1.
        gs_return-message_v2 = sy-msgv2.
        gs_return-message_v3 = sy-msgv3.
        gs_return-message_v4 = sy-msgv4.
        APPEND gs_return TO gt_return.


          message_save( is_msg = gs_return ).
          MESSAGE e001.

      ENDIF.

    ELSE.

      SELECT doc_uuid_h, contrato, aditivo, data_fim_valid, bukrs, branch,"#EC CI_NOFIELD
      prazo_pagto, renov_aut, alerta_enviado, alerta_data_envio
      FROM  ztfi_contrato
      WHERE contrato IN @iv_contrato
      AND aditivo    IN @iv_aditivo
      AND alerta_vig EQ @abap_true
      AND renov_aut  EQ @abap_true
      INTO TABLE @gt_contrato.

      IF sy-subrc IS NOT INITIAL.

        MESSAGE e000 INTO DATA(lv_dummy2).

        gs_return-type       = sy-msgty.
        gs_return-id         = sy-msgid.
        gs_return-number     = sy-msgno.
        gs_return-message_v1 = sy-msgv1.
        gs_return-message_v2 = sy-msgv2.
        gs_return-message_v3 = sy-msgv3.
        gs_return-message_v4 = sy-msgv4.
        APPEND gs_return TO gt_return.

          message_save( is_msg = gs_return ).
          MESSAGE e000.

      ENDIF.

    ENDIF.



  ENDMETHOD.


  METHOD verifica_alerta_enviado.
    CONSTANTS: BEGIN OF lc_param,
                 modulo TYPE zi_ca_param_mod-modulo VALUE 'FI-AR',
                 "! Chave
                 chave1 TYPE zi_ca_param_par-chave1 VALUE 'VIGENCIA',
                 "! Chave
                 chave2 TYPE zi_ca_param_par-chave2 VALUE 'RECORRENCIA',
               END OF lc_param.

    DATA: lv_data_dias TYPE p.
    DATA(lv_data) = VALUE sy-datum( ).

    CLEAR:gt_contrato.

    DATA(lo_param) = NEW zclca_tabela_parametros( ).
    DATA(lv_recorrencia) = VALUE char10(  ).

    TRY.
        lo_param->m_get_single(
          EXPORTING
            iv_modulo = lc_param-modulo
            iv_chave1 = lc_param-chave1
            iv_chave2 = lc_param-chave2
          IMPORTING
            ev_param  = lv_recorrencia
        ).
      CATCH zcxca_tabela_parametros.

    ENDTRY.




    LOOP AT gt_contrato_fim  ASSIGNING FIELD-SYMBOL(<fs_contrato_fim>).
      APPEND INITIAL LINE TO gt_contrato ASSIGNING FIELD-SYMBOL(<fs_contrato_envio>).


      IF <fs_contrato_fim>-alerta_enviado EQ abap_false.
        <fs_contrato_envio>-doc_uuid_h        = <fs_contrato_fim>-doc_uuid_h.
        <fs_contrato_envio>-contrato          = <fs_contrato_fim>-contrato.
        <fs_contrato_envio>-aditivo           = <fs_contrato_fim>-aditivo.
        <fs_contrato_envio>-data_fim_valid    = <fs_contrato_fim>-data_fim_valid.
        <fs_contrato_envio>-bukrs             = <fs_contrato_fim>-bukrs.
        <fs_contrato_envio>-branch            = <fs_contrato_fim>-branch.
        <fs_contrato_envio>-prazo_pagto       = <fs_contrato_fim>-prazo_pagto.
        <fs_contrato_envio>-renov_aut         = <fs_contrato_fim>-renov_aut.
        <fs_contrato_envio>-alerta_enviado    = <fs_contrato_fim>-alerta_enviado.
        <fs_contrato_envio>-alerta_data_envio = <fs_contrato_fim>-alerta_data_envio.


      ELSEIF <fs_contrato_fim>-alerta_enviado EQ abap_true.
        lv_data = <fs_contrato_fim>-alerta_data_envio.

        CALL FUNCTION 'SD_DATETIME_DIFFERENCE'
          EXPORTING
            date1            = sy-datum
            time1            = sy-uzeit
            date2            = lv_data
            time2            = sy-uzeit
          IMPORTING
            datediff         = lv_data_dias
          EXCEPTIONS
            invalid_datetime = 1
            OTHERS           = 2.

        IF sy-subrc EQ 0.
          IF lv_data_dias GE lv_recorrencia.
            <fs_contrato_envio>-doc_uuid_h        = <fs_contrato_fim>-doc_uuid_h.
            <fs_contrato_envio>-contrato          = <fs_contrato_fim>-contrato.
            <fs_contrato_envio>-aditivo           = <fs_contrato_fim>-aditivo.
            <fs_contrato_envio>-data_fim_valid    = <fs_contrato_fim>-data_fim_valid.
            <fs_contrato_envio>-bukrs             = <fs_contrato_fim>-bukrs.
            <fs_contrato_envio>-branch            = <fs_contrato_fim>-branch.
            <fs_contrato_envio>-prazo_pagto       = <fs_contrato_fim>-prazo_pagto.
            <fs_contrato_envio>-renov_aut         = <fs_contrato_fim>-renov_aut.
            <fs_contrato_envio>-alerta_enviado    = <fs_contrato_fim>-alerta_enviado.
            <fs_contrato_envio>-alerta_data_envio = <fs_contrato_fim>-alerta_data_envio.

          ENDIF.
        ENDIF.
      ENDIF.
    ENDLOOP.

    DELETE gt_contrato WHERE contrato = space
                       and   aditivo  = space.
  ENDMETHOD.


  METHOD initialize_log.


    CONSTANTS: BEGIN OF lc_log,
               obj TYPE bal_s_log-object    VALUE 'ZFI_ALERTA_CONTRATO',
               sub TYPE bal_s_log-subobject VALUE 'EMAIL',
               END OF lc_log.


    DATA: ls_log        TYPE bal_s_log.

    ls_log-extnumber = gv_job.
    ls_log-aluser    = sy-uname.
    ls_log-alprog    = sy-repid.
    ls_log-object    = lc_log-obj.
    ls_log-subobject = lc_log-sub.

    CALL FUNCTION 'BAL_LOG_CREATE'
      EXPORTING
        i_s_log      = ls_log
      IMPORTING
        e_log_handle = gv_log_handle
      EXCEPTIONS
        OTHERS       = 1.

    IF sy-subrc IS NOT INITIAL.
      DATA(lv_erro) = abap_true.
    ENDIF.

    IF NOT sy-batch IS INITIAL.

      CALL FUNCTION 'BP_ADD_APPL_LOG_HANDLE'
        EXPORTING
          loghandle = gv_log_handle
        EXCEPTIONS
          OTHERS    = 4.

    IF sy-subrc IS NOT INITIAL.
      lv_erro = abap_true.
    ENDIF.

    ENDIF.

  ENDMETHOD.


  METHOD message_save.
    DATA: ls_msg        TYPE bal_s_msg,
          lt_log_handle TYPE bal_t_logh.

    APPEND gv_log_handle TO lt_log_handle.

    ls_msg-msgty     = is_msg-type.
    ls_msg-msgid     = is_msg-id.
    ls_msg-msgno     = is_msg-number.
    ls_msg-msgv1     = is_msg-message_v1.
    ls_msg-msgv2     = is_msg-message_v2.
    ls_msg-msgv3     = is_msg-message_v3.
    ls_msg-msgv4     = is_msg-message_v4.
    ls_msg-probclass = '1'.


    CALL FUNCTION 'BAL_LOG_MSG_ADD'
      EXPORTING
        i_log_handle     = gv_log_handle
        i_s_msg          = ls_msg
      EXCEPTIONS
        log_not_found    = 1
        msg_inconsistent = 2
        log_is_full      = 3
        OTHERS           = 4.

    IF sy-subrc IS NOT INITIAL.
      DATA(lv_erro) = abap_true.
    ENDIF.

    CALL FUNCTION 'BAL_DB_SAVE'
      EXPORTING
*       i_save_all     = 'X' "can cause dumps
        i_t_log_handle = lt_log_handle
      EXCEPTIONS
        OTHERS         = 4.

    IF sy-subrc IS NOT INITIAL.
      lv_erro = abap_true.
    ENDIF.

  ENDMETHOD.
ENDCLASS.
