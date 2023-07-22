class ZCLFI_JOB_RENOVAR_CONTRATO definition
  public
  final
  create public .

public section.

  types:
    ty_empresa    TYPE RANGE OF ztfi_contrato-bukrs .
  types:
    ty_locnegocio TYPE RANGE OF ztfi_contrato-branch .
  types:
    ty_contrato   TYPE RANGE OF ztfi_contrato-contrato .

  methods EXECUTE .
  methods EXECUTE_JOB
    importing
      !IV_EMPRESA type TY_EMPRESA optional
      !IV_LOCNEGOCIO type TY_LOCNEGOCIO optional
      !IV_CONTRATO type TY_CONTRATO optional .
  PROTECTED SECTION.
private section.

  types:
    tt_fi_contrato_vencidos TYPE TABLE OF ztfi_contrato .

  data GS_RETURN type BAPIRET2 .
  data GT_RETURN type BAPIRET2_T .
  data GV_MESES type INT1 .
  data GT_CONTRATOS type TT_FI_CONTRATO_VENCIDOS .
  data GV_JOB type BTCJOB .
  data GV_LOG_HANDLE type BALLOGHNDL .

  methods GET_PARAMETERS .
  methods MESSAGE_SAVE
    importing
      !IS_MSG type BAPIRET2 .
  methods GET_DADOS .
  methods PROCESS_DATA .
  methods SAVE_DATA .
  methods INITIALIZE_LOG .
  methods SELECT_CONTRATO
    importing
      !IV_EMPRESA type TY_EMPRESA optional
      !IV_LOCNEGOCIO type TY_LOCNEGOCIO optional
      !IV_CONTRATO type TY_CONTRATO optional .
ENDCLASS.



CLASS ZCLFI_JOB_RENOVAR_CONTRATO IMPLEMENTATION.


  METHOD execute.

    initialize_log( ).
    get_parameters( ).
    get_dados( ).
    process_data( ).
    save_data( ).

  ENDMETHOD.


  METHOD get_dados.

    SELECT *
      INTO TABLE @gt_contratos
      FROM ztfi_contrato
      WHERE doc_uuid_h NE '00000000000000000000000000000000'
        AND renov_aut = @abap_true.

    IF sy-subrc IS NOT INITIAL.

      MESSAGE e002 INTO DATA(lv_dummy1).

      gs_return-type       = sy-msgty.
      gs_return-id         = sy-msgid.
      gs_return-number     = sy-msgno.
      gs_return-message_v1 = sy-msgv1.
      gs_return-message_v2 = sy-msgv2.
      gs_return-message_v3 = sy-msgv3.
      gs_return-message_v4 = sy-msgv4.
      APPEND gs_return TO gt_return.

      IF sy-batch EQ abap_true.

        message_save( is_msg = gs_return ).
        MESSAGE e001 WITH 'ZTFI_CONTRATO'.

      ENDIF.

    ENDIF.

  ENDMETHOD.


  METHOD get_parameters.

    DATA(lo_param) = zclca_tabela_parametros=>get_instance( ). " CHANGE - LSCHEPP - 20.07.2023

    TRY.

        lo_param->m_get_single(
      EXPORTING
        iv_modulo = 'FI-AR'
        iv_chave1 = 'RENOVACAO_AUTOMATICA'
        iv_chave2 = 'MESES'
*        iv_chave3 =
      IMPORTING
        ev_param  = gv_meses
    ).

      CATCH cx_root INTO DATA(lo_root).

        CLEAR gs_return.
        MESSAGE s006 INTO DATA(lv_dummy2).
        gs_return-type       = sy-msgty.
        gs_return-id         = sy-msgid.
        gs_return-number     = sy-msgno.
        gs_return-message_v1 = sy-msgv1.
        gs_return-message_v2 = sy-msgv2.
        gs_return-message_v3 = sy-msgv3.
        gs_return-message_v4 = sy-msgv4.
        APPEND gs_return TO gt_return.

        IF sy-batch EQ abap_true.

          message_save( is_msg = gs_return ).
          MESSAGE s006.

        ENDIF.

    ENDTRY.


  ENDMETHOD.


  METHOD initialize_log.

    CONSTANTS: BEGIN OF lc_log,
                 obj TYPE bal_s_log-object VALUE 'ZFI_RENOV_CONTRATO',
                 sub TYPE bal_s_log-subobject VALUE 'AUTOMATICA',
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


  METHOD process_data.

    LOOP AT gt_contratos ASSIGNING FIELD-SYMBOL(<fs_contratos>).

      CALL FUNCTION 'OIUPR_DATE_ADD_MONTH'
        EXPORTING
          months  = gv_meses
          olddate = <fs_contratos>-data_fim_valid
*         LAST_DAY       =
        IMPORTING
          newdate = <fs_contratos>-data_fim_valid.

**      <fs_contratos>-renov_aut = abap_false.
      <fs_contratos>-last_changed_by = sy-uname.

      ""TimeStamp Gang.
      GET TIME STAMP FIELD DATA(lv_ts) .
      <fs_contratos>-last_changed_at = lv_ts.
      <fs_contratos>-local_last_changed_at = lv_ts.

    ENDLOOP.

  ENDMETHOD.


  METHOD save_data.

    IF gt_contratos[] IS  INITIAL.

      CLEAR gs_return.
      MESSAGE s005 INTO DATA(lv_dummy2).
      gs_return-type       = sy-msgty.
      gs_return-id         = sy-msgid.
      gs_return-number     = sy-msgno.
      gs_return-message_v1 = sy-msgv1.
      gs_return-message_v2 = sy-msgv2.
      gs_return-message_v3 = sy-msgv3.
      gs_return-message_v4 = sy-msgv4.
      APPEND gs_return TO gt_return.

      IF sy-batch EQ abap_true.

        message_save( is_msg = gs_return ).
        MESSAGE s005.

      ENDIF.

    ELSE.

      LOOP AT gt_contratos ASSIGNING FIELD-SYMBOL(<fs_contart>).

        <fs_contart>-status = '8'.
        <fs_contart>-desativado = space.
        <fs_contart>-last_changed_by = sy-uname.
        GET TIME STAMP FIELD DATA(lv_ts) .
        <fs_contart>-last_changed_at = lv_ts.

      ENDLOOP.

      UPDATE ztfi_contrato FROM TABLE gt_contratos.

      IF sy-subrc IS INITIAL.

        COMMIT WORK AND WAIT.

        CLEAR gs_return.
        MESSAGE s003 INTO lv_dummy2 WITH <fs_contart>-contrato <fs_contart>-aditivo.
        gs_return-type       = sy-msgty.
        gs_return-id         = sy-msgid.
        gs_return-number     = sy-msgno.
        gs_return-message_v1 = sy-msgv1.
        gs_return-message_v2 = sy-msgv2.
        gs_return-message_v3 = sy-msgv3.
        gs_return-message_v4 = sy-msgv4.
        APPEND gs_return TO gt_return.

*
        message_save( is_msg = gs_return ).

      ELSE.

        CLEAR gs_return.
        MESSAGE e004 INTO DATA(lv_dummy3) WITH <fs_contart>-contrato <fs_contart>-aditivo.
        gs_return-type       = sy-msgty.
        gs_return-id         = sy-msgid.
        gs_return-number     = sy-msgno.
        gs_return-message_v1 = sy-msgv1.
        gs_return-message_v2 = sy-msgv2.
        gs_return-message_v3 = sy-msgv3.
        gs_return-message_v4 = sy-msgv4.
        APPEND gs_return TO gt_return.

*Erro ao executar o Job Renovação de Contrato.

        message_save( is_msg = gs_return ).

      ENDIF.
    ENDIF.
  ENDMETHOD.


  METHOD execute_job.

    initialize_log( ).
    get_parameters( ).
    select_contrato( iv_empresa    = iv_empresa
                     iv_locnegocio = iv_locnegocio
                     iv_contrato   = iv_contrato ).
    IF gt_contratos IS NOT INITIAL.
      process_data( ).
      save_data( ).
    ENDIF.


  ENDMETHOD.


  METHOD select_contrato.

    SELECT *
     INTO TABLE @gt_contratos
     FROM ztfi_contrato
     WHERE doc_uuid_h IS NOT NULL
      AND  contrato   IN @iv_contrato
      AND  bukrs      IN @iv_empresa
      AND  branch     IN @iv_locnegocio
      AND data_fim_valid < @sy-datum
      AND  renov_aut  EQ @abap_true .                   "#EC CI_NOFIELD

    IF sy-subrc IS NOT INITIAL.

      MESSAGE e002 INTO DATA(lv_dummy1).

      gs_return-type       = sy-msgty.
      gs_return-id         = sy-msgid.
      gs_return-number     = sy-msgno.
      gs_return-message_v1 = sy-msgv1.
      gs_return-message_v2 = sy-msgv2.
      gs_return-message_v3 = sy-msgv3.
      gs_return-message_v4 = sy-msgv4.
      APPEND gs_return TO gt_return.

*      IF sy-batch EQ abap_true.

      message_save( is_msg = gs_return ).
      RETURN.
*      MESSAGE e002.

*      ENDIF.

    ENDIF.
  ENDMETHOD.
ENDCLASS.
