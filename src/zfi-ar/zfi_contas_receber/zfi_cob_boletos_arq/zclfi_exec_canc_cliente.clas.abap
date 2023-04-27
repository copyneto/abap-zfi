CLASS zclfi_exec_canc_cliente DEFINITION PUBLIC FINAL CREATE PUBLIC .

  PUBLIC SECTION.

    TYPES: ty_bapiret TYPE STANDARD TABLE OF zsfi_bapiret2 WITH DEFAULT KEY.

    TYPES:
      ty_bukrs    TYPE RANGE OF bukrs,
      ty_kunnr    TYPE RANGE OF kunnr,
      ty_canc_cli TYPE STANDARD TABLE OF zi_fi_canc_cli.

    METHODS:
      executar
        IMPORTING
          it_can_cli TYPE ty_canc_cli OPTIONAL
          iv_bukrs   TYPE ty_bukrs    OPTIONAL
          iv_kunnr   TYPE ty_kunnr    OPTIONAL
          iv_verzn   TYPE verzn       OPTIONAL
        EXPORTING
          et_msg     TYPE ty_bapiret, "bapiret2_tab,

      task_finish
        IMPORTING
          p_task TYPE clike.

  PRIVATE SECTION.
    TYPES:
      BEGIN OF  ty_bsid,
        verzn TYPE verzn.
        INCLUDE TYPE zi_fi_canc_cli.
    TYPES:
      END OF ty_bsid.
    TYPES:
      tt_bsid TYPE STANDARD TABLE OF ty_bsid WITH DEFAULT KEY.

    CONSTANTS: BEGIN OF gc_values,
                 subobject_modelo_2 TYPE balsubobj VALUE 'MODELO_2',
                 erro               TYPE bdc_mart  VALUE 'E',
                 number             TYPE bdc_mnr   VALUE '312',
                 motivo             TYPE ze_mot_prorrog  VALUE 'CM',
                 tipo               TYPE ze_tipo_sol     VALUE  'CANCELAMENTO',
                 type               TYPE bapi_mtype VALUE 'I',
                 id                 TYPE symsgid    VALUE 'ZFI_CONT_RCB',
                 number2            TYPE symsgno    VALUE '017',
               END OF gc_values.

    DATA:
      gt_msg    TYPE STANDARD TABLE OF zsfi_bapiret2, "bapiret2_tab,
      gt_return TYPE bapiret2_tab,
      gv_bukrs  TYPE ty_bukrs,
      gv_kunnr  TYPE ty_kunnr,
      gv_verzn  TYPE verzn.

    METHODS:
      selecionar_dados_canc_cliente
        RETURNING
          VALUE(rt_retorno) TYPE tt_bsid,

      determinar_dados_fora_validade
        IMPORTING
          it_dados_canc_cliente TYPE tt_bsid
        RETURNING
          VALUE(rt_retorno)     TYPE tt_bsid,

      verifica_data_validade
        IMPORTING
          is_dados_canc_cliente TYPE ty_bsid
        RETURNING
          VALUE(rs_retorno)     TYPE ty_bsid,

      alterar_doc_fi_instrucao1
        IMPORTING
          it_dados_fora_validade TYPE tt_bsid
        RETURNING
          VALUE(rt_retorno)      TYPE tt_bsid,

      executa_batch_compensar
        IMPORTING
          it_dados_fora_validade TYPE tt_bsid
        RETURNING
          VALUE(rt_retorno)      TYPE tt_bsid,

      processar_batch_compensar
        IMPORTING
          is_dados_fora_validade TYPE ty_bsid
        RETURNING
          VALUE(rs_retorno)      TYPE ty_bsid,

      salvar_log_solic_correcao
        IMPORTING
          is_dados_fora_validade TYPE ty_bsid
          iv_belnrestorno        TYPE belnr_d,

      valid_delay IMPORTING iv_verzn TYPE verzn,

      create_log.

ENDCLASS.



CLASS zclfi_exec_canc_cliente IMPLEMENTATION.

  METHOD executar.

    gv_bukrs = iv_bukrs.
    gv_kunnr = iv_kunnr.
    gv_verzn = iv_verzn.

    IF it_can_cli IS INITIAL.
      DATA(lt_dados_canc_cliente) = selecionar_dados_canc_cliente( ).
      DATA(lt_dados_fora_validade) = determinar_dados_fora_validade( lt_dados_canc_cliente ).
      DATA(lt_dados_alterados_instrucao1) = alterar_doc_fi_instrucao1( lt_dados_fora_validade ).
    ELSE.
      lt_dados_canc_cliente = CORRESPONDING #( it_can_cli ).
      lt_dados_alterados_instrucao1 = alterar_doc_fi_instrucao1( lt_dados_canc_cliente ).
    ENDIF.


    DATA(lt_dados_shdb) = executa_batch_compensar( lt_dados_alterados_instrucao1 ).

    create_log( ).

    et_msg = gt_msg.

  ENDMETHOD.

  METHOD selecionar_dados_canc_cliente.
    SELECT * FROM zi_fi_canc_cli
      WHERE bukrs IN @gv_bukrs
        AND kunnr IN @gv_kunnr
    INTO CORRESPONDING FIELDS OF TABLE @rt_retorno.
    IF sy-subrc NE 0.

      MESSAGE ID  'ZFI_CONT_RCB' TYPE 'E' NUMBER '001' INTO DATA(lv_msg).


      gt_msg = VALUE #( BASE gt_msg (
              bapiret2 = VALUE #( (
                type       = sy-msgty
                id         = sy-msgid
                number     = sy-msgno
                message_v1 = sy-msgv1
                message_v2 = sy-msgv2
                message_v3 = sy-msgv3
                message_v4 = sy-msgv4 ) )
       ) ).

    ENDIF.
  ENDMETHOD.

  METHOD determinar_dados_fora_validade.
    rt_retorno = VALUE #(
         FOR ls_dados_canc_cliente IN it_dados_canc_cliente
         LET ls_dados_fora_validade = verifica_data_validade( ls_dados_canc_cliente ) IN
         ( LINES OF COND #(
               WHEN ls_dados_fora_validade IS NOT INITIAL
               THEN VALUE #( ( ls_dados_fora_validade ) )
    ) ) ).
  ENDMETHOD.

  METHOD verifica_data_validade.
    DATA(ls_item) = VALUE rfposxext( BASE CORRESPONDING #( is_dados_canc_cliente
      MAPPING
        konto = kunnr
        dmshb = dmbtr
        wrshb = wrbtr
      )
      koart = 'D' ).

    DATA(ls_t001) = VALUE t001( bukrs = is_dados_canc_cliente-bukrs ).

    CALL FUNCTION 'ITEM_DERIVE_FIELDS'
      EXPORTING
        s_t001    = ls_t001
        key_date  = sy-datum
        xopvw     = abap_true
      CHANGING
        s_item    = ls_item
      EXCEPTIONS
        bad_input = 1
        OTHERS    = 2.

    IF sy-subrc NE 0.

      MESSAGE ID 'ZFI_CONT_RCB' TYPE 'E' NUMBER '006' INTO DATA(ls_msg)
       WITH is_dados_canc_cliente-belnr is_dados_canc_cliente-bukrs is_dados_canc_cliente-buzei.

      gt_msg = VALUE #( BASE gt_msg (
       bapiret2 = VALUE #( (
         type       = sy-msgty
         id         = sy-msgid
         number     = sy-msgno
         message_v1 = sy-msgv1
         message_v2 = sy-msgv2
         message_v3 = sy-msgv3
         message_v4 = sy-msgv4 ) )
            ) ).

    ELSE.

      rs_retorno = COND #(
        WHEN ls_item-verz1 >= gv_verzn
        THEN VALUE #( BASE is_dados_canc_cliente verzn = ls_item-verz1 )
        ELSE VALUE #( )
      ).


      IF rs_retorno IS INITIAL.

        gt_msg = VALUE #( BASE gt_msg (
           belnr    = is_dados_canc_cliente-belnr
           buzei    = is_dados_canc_cliente-buzei
           bapiret2 = VALUE #( (
             type       = gc_values-type
             id         = gc_values-id
             number     = gc_values-number2
             message_v1 = is_dados_canc_cliente-belnr
             message_v2 = is_dados_canc_cliente-buzei ) )
        ) ).

      ENDIF.
    ENDIF.

  ENDMETHOD.

  METHOD alterar_doc_fi_instrucao1.

    DATA: lt_validar TYPE STANDARD TABLE OF zclfi_modifica_doc=>ty_bsid.

    lt_validar = CORRESPONDING #( it_dados_fora_validade ).

    NEW zclfi_modifica_doc( )->change_doc(
      IMPORTING
        et_msg  = DATA(lt_mensagens)
      CHANGING
        ct_bsid = lt_validar
    ).

    rt_retorno = CORRESPONDING #( lt_validar ).

    IF lt_mensagens IS NOT INITIAL.
      APPEND  lt_mensagens TO gt_msg.
    ENDIF.


  ENDMETHOD.

  METHOD executa_batch_compensar.
    rt_retorno = VALUE #( FOR ls_dados_fora_validade IN it_dados_fora_validade
      LET ls_dados_compensar_sem_erro = processar_batch_compensar( ls_dados_fora_validade ) IN
      ( LINES OF COND #(
        WHEN ls_dados_compensar_sem_erro IS NOT INITIAL
        THEN VALUE #( ( ls_dados_compensar_sem_erro ) )
    ) ) ).
  ENDMETHOD.

  METHOD processar_batch_compensar.

    CLEAR: gt_return[].

    CALL FUNCTION 'ZFMFI_BATCH_COMPENSAR_REM'
      STARTING NEW TASK 'BACKGROUND' CALLING task_finish ON END OF TASK
      EXPORTING
        iv_kunnr = is_dados_fora_validade-kunnr
        iv_waers = is_dados_fora_validade-waers
        iv_budat = is_dados_fora_validade-bldat
        iv_bukrs = is_dados_fora_validade-bukrs
        iv_anfbn = is_dados_fora_validade-anfbn
      CHANGING
        ct_msg   = gt_return.

    WAIT FOR ASYNCHRONOUS TASKS UNTIL me->gt_return IS NOT INITIAL.

    IF gt_return IS NOT INITIAL.

      DATA(lt_msg) = VALUE ty_bapiret( (
                  belnr    = is_dados_fora_validade-belnr
                  buzei    = is_dados_fora_validade-buzei
                  bapiret2 = VALUE #( FOR ls_ret IN gt_return (
                                                type       = ls_ret-type
                                                id         = ls_ret-id
                                                number     = ls_ret-number
                                                message_v1 = ls_ret-message_v1
                                                message_v2 = ls_ret-message_v2
                                                message_v3 = ls_ret-message_v3
                                                message_v4 = ls_ret-message_v4
                                      ) ) )
             ).


      APPEND LINES OF lt_msg TO gt_msg.

    ENDIF.


    IF NOT line_exists( gt_return[ type = gc_values-erro ] ).

      salvar_log_solic_correcao(
       EXPORTING
         is_dados_fora_validade = is_dados_fora_validade
         iv_belnrestorno        = VALUE #( gt_return[ number = gc_values-number ]-message_v1 OPTIONAL ) ).

      rs_retorno = is_dados_fora_validade.

    ENDIF.

  ENDMETHOD.

  METHOD salvar_log_solic_correcao.

    DATA lv_timestampl TYPE timestampl.
    GET TIME STAMP FIELD lv_timestampl.

    DATA(ls_solcorrecao) = VALUE ztfi_solcorrecao(
      bukrs  = is_dados_fora_validade-bukrs
      kunnr  = is_dados_fora_validade-kunnr
      belnr  = is_dados_fora_validade-belnr
      buzei  = is_dados_fora_validade-buzei
      gjhar  = is_dados_fora_validade-gjahr
      datac  = sy-datum
      horac  = sy-uzeit
      wrbtr  = is_dados_fora_validade-wrbtr
      netdt  = is_dados_fora_validade-bldat
      motivo = gc_values-motivo
      tipo   = gc_values-tipo
      belnrestorno  = iv_belnrestorno
      buzeiestorno  = is_dados_fora_validade-buzei
      gjharestorno  = is_dados_fora_validade-gjahr
      verzn         = is_dados_fora_validade-verzn
      created_by    = sy-uname
      created_at    = lv_timestampl
      local_last_changed_at = lv_timestampl
    ).
    MODIFY ztfi_solcorrecao FROM ls_solcorrecao.
  ENDMETHOD.

  METHOD valid_delay.

    RETURN.
*    DATA(lt_bsid) = gt_bsid.
*
*    REFRESH: gt_bsid.
*
*    LOOP AT lt_bsid ASSIGNING FIELD-SYMBOL(<fs_bsid>) .
*
*      DATA(ls_item) = VALUE rfposxext(
*      koart = 'D'
*      belnr = <fs_bsid>-belnr
*      bldat = <fs_bsid>-bldat
*      zfbdt = <fs_bsid>-zfbdt
*      bukrs = <fs_bsid>-bukrs
*      buzei = <fs_bsid>-buzei
*      konto = <fs_bsid>-kunnr
*      dmshb = <fs_bsid>-dmbtr
*      wrshb = <fs_bsid>-wrbtr ).
*
*      DATA(ls_t001) = VALUE t001( bukrs = <fs_bsid>-bukrs ).
*
*      CALL FUNCTION 'ITEM_DERIVE_FIELDS'
*        EXPORTING
*          s_t001    = ls_t001
*          key_date  = sy-datum
*          xopvw     = abap_true
*        CHANGING
*          s_item    = ls_item
*        EXCEPTIONS
*          bad_input = 1
*          OTHERS    = 2.
*
*      IF sy-subrc NE 0.
*
*        MESSAGE ID  'ZFI_CONT_RCB' TYPE 'E' NUMBER '006'
*         INTO DATA(ls_msg)
*         WITH <fs_bsid>-belnr <fs_bsid>-bukrs <fs_bsid>-buzei.
*
*        APPEND: VALUE #(  type  = 'E' message  = ls_msg ) TO gt_msg.
*
*      ELSE.
*
*        IF ls_item-verz1 >= iv_verzn.
*
*          <fs_bsid>-verzn = iv_verzn.
*
*          APPEND <fs_bsid> TO gt_bsid.
*
*        ENDIF.
*
*      ENDIF.
*
*      CLEAR: ls_item, ls_t001.
*
*    ENDLOOP.
*
*    IF gt_bsid IS NOT INITIAL.
*      me->bapi_change(  ).
*    ENDIF.

  ENDMETHOD.

  METHOD create_log.

    IF lines( gt_msg ) GT 120.

      DATA(lt_msg) = VALUE bapiret2_tab( FOR ls_ret IN gt_msg
                                         FOR ls_itens IN ls_ret-bapiret2
                                         ( CORRESPONDING #(  ls_itens ) ) ).

      NEW zclfi_save_msg( )->save_ballog(
        iv_subobject = gc_values-subobject_modelo_2
        it_msg       = lt_msg
      ).

    ENDIF.

  ENDMETHOD.

  METHOD task_finish.

    RECEIVE RESULTS FROM FUNCTION 'ZFMFI_BATCH_COMPENSAR_REM'
    CHANGING
        ct_msg     = me->gt_return.

    RETURN.

  ENDMETHOD.

ENDCLASS.
