CLASS zclfi_exec_canc_bancario DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    TYPES:
      ty_data TYPE RANGE OF budat .
    TYPES:
      ty_bukrs TYPE RANGE OF bukrs .
    TYPES:
      BEGIN OF  ty_bsid,
        verzn TYPE verzn.
        INCLUDE TYPE zi_fi_doc_canc_banc.
    TYPES: END OF ty_bsid .
    TYPES:
      ty_bapiret TYPE STANDARD TABLE OF zsfi_bapiret2 WITH DEFAULT KEY .

    CONSTANTS:
      BEGIN OF gc_values,
        subobject_modelo_2 TYPE balsubobj VALUE 'MODELO_2',
        erro               TYPE bdc_mart  VALUE 'E',
        number             TYPE bdc_mnr   VALUE '312',
        motivo             TYPE ze_mot_prorrog  VALUE 'CM',
        tipo               TYPE ze_tipo_sol     VALUE  'CANCELAMENTO',
        type               TYPE bapi_mtype VALUE 'I',
        id                 TYPE symsgid    VALUE 'ZFI_CONT_RCB',
        id2                TYPE symsgid    VALUE 'F5',
        number2            TYPE symsgno    VALUE '017',
        number3            TYPE symsgno    VALUE '312',
        number4            TYPE symsgno    VALUE '018',
      END OF gc_values .
    DATA:
      gt_bsid TYPE TABLE OF ty_bsid .

    DATA gv_report TYPE boolean.

    METHODS calc_date
      CHANGING
        !cr_budat TYPE ty_data .
    METHODS get_data
      IMPORTING
        !iv_bukrs TYPE ty_bukrs
        !iv_budat TYPE ty_data
        iv_report TYPE boolean.
    METHODS execute_app   "IMPORTING iv_verzn TYPE verzn
      EXPORTING
        !et_msg TYPE ty_bapiret .
    METHODS task_finish
      IMPORTING
        !p_task TYPE clike .
  PROTECTED SECTION.

  PRIVATE SECTION.

    DATA go_alv TYPE REF TO cl_salv_table .
    DATA gt_msg    TYPE STANDARD TABLE OF zsfi_bapiret2 .
    DATA gt_return TYPE bapiret2_tab .

    " DATA: gv_verzn  TYPE verzn.

    METHODS bapi_change .
    METHODS exec_shdb .
    METHODS save_log
      IMPORTING
        !iv_doc_est TYPE belnr_d
        !is_bsid    TYPE ty_bsid .
    METHODS create_log .
    METHODS busca_dias_atraso
      IMPORTING
        !is_bsid          TYPE ty_bsid
      RETURNING
        VALUE(rv_retorno) TYPE verzn .
    METHODS executa_batch_compensar
      IMPORTING
        !is_bsid TYPE zclfi_exec_canc_bancario=>ty_bsid .
ENDCLASS.



CLASS zclfi_exec_canc_bancario IMPLEMENTATION.


  METHOD get_data.

    REFRESH: gt_bsid.

    CLEAR: gv_report.
    gv_report = iv_report.

    SELECT bukrs, rebzg, rebzj, rebzz FROM bsid_view
    WHERE bukrs IN @iv_bukrs
      AND budat IN @iv_budat
      AND bschl = '11'
      AND shkzg = 'H'
    INTO TABLE @DATA(lt_bsid).

    IF sy-subrc = 0.

      SORT lt_bsid BY bukrs rebzg rebzj rebzz.

      SELECT * FROM bsid_view
      FOR ALL ENTRIES IN @lt_bsid
      WHERE bukrs = @lt_bsid-bukrs
        AND belnr = @lt_bsid-rebzg
        AND gjahr = @lt_bsid-rebzj
        AND buzei = @lt_bsid-rebzz
*        AND anfbn <> ''
      INTO CORRESPONDING FIELDS OF TABLE @gt_bsid.

    ENDIF.

    IF gt_bsid IS INITIAL.

      MESSAGE ID  'ZFI_CONT_RCB' TYPE 'E' NUMBER '001' INTO DATA(ls_msg).

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

      me->bapi_change( ).

    ENDIF.

    me->create_log( ).

  ENDMETHOD.


  METHOD bapi_change.


    DATA(lo_change) = NEW zclfi_modifica_doc(  ).

    lo_change->change_doc_banc(
     EXPORTING
        iv_report = gv_report
      IMPORTING
        et_msg  = DATA(lt_mensagens)
      CHANGING
        ct_bsid = gt_bsid ).

    IF lt_mensagens IS NOT INITIAL.
      APPEND lt_mensagens TO gt_msg.
    ENDIF.

    IF gt_bsid IS NOT INITIAL.
      CALL METHOD me->exec_shdb( ).
    ENDIF.

  ENDMETHOD.


  METHOD exec_shdb.

    DATA: lv_erro     TYPE c,
          lv_doc_est  TYPE belnr_d,
          lv_item_est TYPE buzei,
          lv_ano_est  TYPE mjahr.

    DATA(lt_bsid) = gt_bsid.

    REFRESH: gt_bsid.

    LOOP AT lt_bsid ASSIGNING FIELD-SYMBOL(<fs_bsid>) .

      IF <fs_bsid>-anfbn IS NOT INITIAL.

        executa_batch_compensar( <fs_bsid> ).

      ENDIF.

    ENDLOOP.

  ENDMETHOD.


  METHOD save_log.

    DATA lv_timestampl TYPE timestampl.

    GET TIME STAMP FIELD lv_timestampl.

    DATA(ls_sol) = VALUE ztfi_solcorrecao(
        bukrs = is_bsid-bukrs
        kunnr = is_bsid-kunnr
        belnr = is_bsid-belnr
        buzei = is_bsid-buzei
        gjhar = is_bsid-gjahr
        datac = sy-datum
        horac = sy-uzeit
        wrbtr = is_bsid-wrbtr
        netdt = is_bsid-bldat
        motivo = gc_values-motivo
        tipo  =  gc_values-tipo
        belnrestorno = iv_doc_est
        buzeiestorno = is_bsid-buzei
        gjharestorno = is_bsid-gjahr
        verzn = busca_dias_atraso( is_bsid )
        created_by   = sy-uname
        created_at   = lv_timestampl
        local_last_changed_at = lv_timestampl ).

    MODIFY ztfi_solcorrecao FROM ls_sol.

  ENDMETHOD.


  METHOD calc_date.

    APPEND VALUE #( sign = 'I' option = 'BT' low = ( sy-datum - 15 ) high =  sy-datum ) TO cr_budat.

  ENDMETHOD.


  METHOD create_log.

    IF lines( gt_msg ) GT 120 OR sy-cprog = 'ZFIR_CAN_BANC_DEV'.

      DATA(lt_msg) = VALUE bapiret2_tab( FOR ls_ret IN gt_msg
                                         FOR ls_itens IN ls_ret-bapiret2
                                         ( CORRESPONDING #(  ls_itens ) ) ).

      NEW zclfi_save_msg( )->save_ballog(
        iv_subobject = gc_values-subobject_modelo_2
        it_msg       = lt_msg
      ).

    ENDIF.

  ENDMETHOD.


  METHOD busca_dias_atraso.
    DATA(ls_item) = VALUE rfposxext( BASE CORRESPONDING #( is_bsid
      MAPPING
        konto = kunnr
        dmshb = dmbtr
        wrshb = wrbtr
      )
      koart = 'D' ).

    DATA(ls_t001) = VALUE t001( bukrs = is_bsid-bukrs ).

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
       WITH is_bsid-belnr is_bsid-bukrs is_bsid-buzei.

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

      rv_retorno = COND #(
        WHEN ls_item-verz1 > 1
        THEN ls_item-verz1
        ELSE '00000000'
      ).

      IF rv_retorno IS INITIAL.

        gt_msg = VALUE #( BASE gt_msg (
           belnr    = is_bsid-belnr
           buzei    = is_bsid-buzei
           bapiret2 = VALUE #( (
             type       = gc_values-type
             id         = gc_values-id
             number     = gc_values-number2
             message_v1 = is_bsid-belnr
             message_v2 = is_bsid-buzei ) )
        ) ).

      ENDIF.

    ENDIF.
  ENDMETHOD.


  METHOD execute_app.

    "gv_verzn = iv_verzn.

    me->bapi_change( ).

    et_msg = me->gt_msg.

    me->create_log( ).

  ENDMETHOD.


  METHOD task_finish.

    RECEIVE RESULTS FROM FUNCTION 'ZFMFI_BATCH_COMPENSAR_REM'
    CHANGING
      ct_msg     = me->gt_return.

    RETURN.

  ENDMETHOD.


  METHOD executa_batch_compensar.

    DATA: ls_return TYPE zsfi_bapiret2.

    CLEAR: gt_return[].

    CALL FUNCTION 'ZFMFI_BATCH_COMPENSAR'
      STARTING NEW TASK 'BACKGROUND' CALLING task_finish ON END OF TASK
      EXPORTING
        iv_kunnr = is_bsid-kunnr
        iv_waers = is_bsid-waers
        iv_budat = is_bsid-bldat
        iv_bukrs = is_bsid-bukrs
        iv_anfbn = is_bsid-anfbn
*       IV_CTU   = 'X'
*       IV_MODE  = 'N'
*       IV_UPDATE         = 'L'
*       IV_GROUP =
*       IV_USER  =
*       IV_KEEP  =
*       IV_HOLDDATE       =
*       IV_NODATA         = ''
*     IMPORTING
*       EV_ERRO  =
*       EV_DOC_EST        =
*       EV_ITEM_EST       =
*       EV_ANO_EST        =
      CHANGING
        ct_msg   = gt_return.

**    CALL FUNCTION 'ZFMFI_BATCH_COMPENSAR_REM'
**      STARTING NEW TASK 'BACKGROUND' CALLING task_finish ON END OF TASK
**      EXPORTING
**        iv_kunnr = is_bsid-kunnr
**        iv_waers = is_bsid-waers
**        iv_budat = is_bsid-bldat
**        iv_bukrs = is_bsid-bukrs
**        iv_anfbn = is_bsid-anfbn
**      CHANGING
**        ct_msg   = gt_return.

    WAIT FOR ASYNCHRONOUS TASKS UNTIL me->gt_return IS NOT INITIAL.

    IF gt_return IS NOT INITIAL.

      ls_return-belnr = is_bsid-belnr.
      ls_return-buzei = is_bsid-buzei.

      READ TABLE gt_return ASSIGNING FIELD-SYMBOL(<fs_return>) WITH KEY id = gc_values-id2
                                                                        number = gc_values-number3.

      IF sy-subrc IS INITIAL.

        APPEND VALUE #( type       = <fs_return>-type
                        id         = gc_values-id
                        number     = gc_values-number4
                        message_v1 = <fs_return>-message_v1
                        message_v2 = <fs_return>-message_v2
                        message_v3 = <fs_return>-message_v3
                        message_v4 = <fs_return>-message_v4 ) TO ls_return-bapiret2.

        APPEND ls_return TO gt_msg.

      ELSE.

        LOOP AT gt_return ASSIGNING <fs_return>.

          APPEND <fs_return> TO ls_return-bapiret2.
          APPEND ls_return TO gt_msg.

        ENDLOOP.

      ENDIF.

*      DATA(lt_msg) = VALUE ty_bapiret( (
*                  belnr    = is_bsid-belnr
*                  buzei    = is_bsid-buzei
*                  bapiret2 = VALUE #( FOR ls_ret IN gt_return (
*                                                type       = ls_ret-type
*                                                id         = ls_ret-id
*                                                number     = ls_ret-number
*                                                message_v1 = ls_ret-message_v1
*                                                message_v2 = ls_ret-message_v2
*                                                message_v3 = ls_ret-message_v3
*                                                message_v4 = ls_ret-message_v4
*                                      ) ) )
*             ).
*
*
*      APPEND LINES OF lt_msg TO gt_msg.

    ENDIF.

    IF NOT line_exists( gt_return[ type = gc_values-erro ] ).

      me->save_log( iv_doc_est = VALUE #( gt_return[ number = gc_values-number ]-message_v1 OPTIONAL )
                    is_bsid    = is_bsid ).
    ENDIF.

  ENDMETHOD.
ENDCLASS.
