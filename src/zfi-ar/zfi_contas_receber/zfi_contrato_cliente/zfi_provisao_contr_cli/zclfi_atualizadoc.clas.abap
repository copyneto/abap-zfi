"! <p class="shorttext synchronized">Classe Atualização de documentos com Bloqueio de Advertência</p>
"! Autor: Anderson Macedo
"! Data: 02/02/2022
class ZCLFI_ATUALIZADOC definition
  public
  final
  create public .

public section.

  types:
    BEGIN OF ty_param,
             bukrs TYPE RANGE OF bseg-bukrs,
             gjahr TYPE bseg-gjahr,
             mansp TYPE bseg-mansp,
           END OF ty_param .

  methods CONSTRUCTOR
    importing
      !IS_BUKRS type TY_PARAM-BUKRS
      !IV_GJAHR type TY_PARAM-GJAHR
      !IV_MANSP type TY_PARAM-MANSP .
  "! Chama o processo principal
  methods PROCESS .
protected section.
private section.

  data GS_PARAM type TY_PARAM .
  data GS_RETURN type BAPIRET2 .
  data GT_RETURN type BAPIRET2_T .
  data GV_JOB type BTCJOB .
  data GV_LOG_HANDLE type BALLOGHNDL .

  methods INITIALIZE_LOG .
  methods SELECT .
  methods MESSAGE_SAVE
    importing
      !IS_MSG type BAPIRET2 .
ENDCLASS.



CLASS ZCLFI_ATUALIZADOC IMPLEMENTATION.


  method CONSTRUCTOR.

   gs_param-bukrs = is_bukrs.
   gs_param-gjahr = iv_gjahr.
   gs_param-mansp = iv_mansp.

  endmethod.


  METHOD process.
    initialize_log( ).
    select( ).

  ENDMETHOD.


  METHOD initialize_log.

    DATA: ls_log        TYPE bal_s_log.
    CONSTANTS: BEGIN OF lc_log,
                 obj TYPE bal_s_log-object VALUE 'ZFI_ATUALIZADOC',
                 sub TYPE bal_s_log-subobject VALUE 'AUTOMATICA',
               END OF lc_log.

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


  METHOD select.

    DATA: ls_cont_cont TYPE ztfi_cont_cont.
    DATA: lv_dummy TYPE string.
    DATA: lr_gjahr TYPE RANGE OF gjahr.

    lr_gjahr = VALUE #( ( sign = 'I'
                          option = 'EQ'
                          low = gs_param-gjahr )
                         ( sign = 'I'
                          option = 'EQ'
                          low = gs_param-gjahr - 1 ) ).


    SELECT bukrs, belnr, gjahr, buzei, kunnr, vbeln, dmbtr
     INTO TABLE @DATA(lt_view)
     FROM bseg
     WHERE bukrs  IN @gs_param-bukrs
      AND  gjahr  IN @lr_gjahr
      AND  mansp  EQ @gs_param-mansp
      AND koart = 'D'
       AND augbl = ''
       AND ( h_bstat <> 'D'
        AND h_bstat <> 'M' ).

    IF sy-subrc EQ 0.

      SELECT vbeln, bukrs, belnr, gjahr, bzirk, vtweg, spart, vkorg
        FROM vbrk
        INTO TABLE @DATA(lt_vbrk)
        FOR ALL ENTRIES IN @lt_view
        WHERE vbeln = @lt_view-vbeln
          AND bukrs = @lt_view-bukrs
          AND belnr = @lt_view-belnr
          AND gjahr = @lt_view-gjahr.
      IF sy-subrc = 0.
        SORT: lt_vbrk BY vbeln bukrs belnr gjahr.
      ENDIF.

      SELECT *
       FROM ztfi_cont_cont
         FOR ALL ENTRIES IN @lt_view
       WHERE bukrs        EQ @lt_view-bukrs
        AND  gjahr        EQ @lt_view-gjahr
        AND  belnr        EQ @lt_view-belnr
        AND  numero_item  EQ @lt_view-buzei
        INTO TABLE @DATA(lt_cont).

      LOOP AT lt_cont ASSIGNING FIELD-SYMBOL(<fs_cont>).
        DELETE lt_view WHERE belnr = <fs_cont>-belnr
                          AND gjahr = <fs_cont>-gjahr
                          AND belnr = <fs_cont>-belnr
                          AND buzei = <fs_cont>-numero_item.
      ENDLOOP.

      IF lt_view IS NOT INITIAL.

**        SELECT *
**         FROM ztfi_cnpj_client
**         FOR ALL ENTRIES IN @lt_view
**         WHERE cliente  EQ @lt_view-kunnr
**         INTO TABLE @DATA(lt_client).

**        IF sy-subrc EQ 0.

**          SORT lt_client BY cliente.

        LOOP AT lt_view ASSIGNING FIELD-SYMBOL(<fs_view>).

          CLEAR: ls_cont_cont.

          ls_cont_cont-kunnr = <fs_view>-kunnr.

**            READ TABLE lt_client ASSIGNING FIELD-SYMBOL(<fs_client>) WITH KEY cliente = <fs_view>-kunnr BINARY SEARCH.
**            IF sy-subrc = 0.
**              ls_cont_cont-contrato = <fs_client>-contrato.
**              ls_cont_cont-aditivo  = <fs_client>-aditivo.
**              ls_cont_cont-kunnr = <fs_client>-cliente.
**            ELSE.
**              CLEAR: ls_cont_cont-contrato, ls_cont_cont-aditivo.
**              ls_cont_cont-kunnr = <fs_view>-kunnr.
**            ENDIF.

          TRY.
              ls_cont_cont-doc_cont_id           =   NEW cl_system_uuid( )->if_system_uuid~create_uuid_x16( ).
            CATCH cx_uuid_error.
              "handle exception
          ENDTRY.


          ls_cont_cont-bukrs           = <fs_view>-bukrs.
          ls_cont_cont-status_provisao = '5'.
          ls_cont_cont-tipo_dado       = 'J'.
          ls_cont_cont-numero_item     = <fs_view>-buzei.
          ls_cont_cont-belnr           = <fs_view>-belnr.
          ls_cont_cont-gjahr           = <fs_view>-gjahr.
          ls_cont_cont-wrbtr           = <fs_view>-dmbtr.

          READ TABLE lt_vbrk ASSIGNING FIELD-SYMBOL(<fs_vbrk>) WITH KEY vbeln = <fs_view>-vbeln
                                                                        bukrs = <fs_view>-bukrs
                                                                        belnr = <fs_view>-belnr
                                                                        gjahr = <fs_view>-gjahr BINARY SEARCH.
          IF sy-subrc = 0.
            ls_cont_cont-canal = <fs_vbrk>-vkorg.
            ls_cont_cont-bzirk = <fs_vbrk>-bzirk.
            ls_cont_cont-setor = <fs_vbrk>-spart.
            ls_cont_cont-vkorg = <fs_vbrk>-vkorg.
*              ELSE.
*                CLEAR: ls_cont_cont.
*                CONTINUE.
          ENDIF.

          MODIFY ztfi_cont_cont FROM ls_cont_cont.
          IF sy-subrc = 0.

            COMMIT WORK AND WAIT.
            CLEAR gs_return.
            "Documento &1/&2/&3 :Cont/Adit &4 gravado.
            MESSAGE s003 INTO lv_dummy WITH <fs_view>-belnr
                                                   <fs_view>-gjahr
                                                   <fs_view>-bukrs.
*                                                   <fs_client>-contrato.
            gs_return-type       = sy-msgty.
            gs_return-id         = sy-msgid.
            gs_return-number     = sy-msgno.
            gs_return-message_v1 = sy-msgv1.
            gs_return-message_v2 = sy-msgv2.
            gs_return-message_v3 = sy-msgv3.
            gs_return-message_v4 = sy-msgv4.
            APPEND gs_return TO gt_return.

            message_save( is_msg = gs_return ).

          ELSE.

            CLEAR gs_return.
            MESSAGE e000 INTO lv_dummy.
            gs_return-type       = sy-msgty.
            gs_return-id         = sy-msgid.
            gs_return-number     = sy-msgno.
            gs_return-message_v1 = sy-msgv1.
            gs_return-message_v2 = sy-msgv2.
            gs_return-message_v3 = sy-msgv3.
            gs_return-message_v4 = sy-msgv4.
            APPEND gs_return TO gt_return.

            message_save( is_msg = gs_return ).

          ENDIF.


        ENDLOOP.

*        ELSE.
*
*          "Cadastro cliente não localizado no contrato
*          CLEAR gs_return.
*          MESSAGE e004 INTO lv_dummy.
*          gs_return-type       = sy-msgty.
*          gs_return-id         = sy-msgid.
*          gs_return-number     = sy-msgno.
*          gs_return-message_v1 = sy-msgv1.
*          gs_return-message_v2 = sy-msgv2.
*          gs_return-message_v3 = sy-msgv3.
*          gs_return-message_v4 = sy-msgv4.
*          APPEND gs_return TO gt_return.
*          message_save( is_msg = gs_return ).
*
*        ENDIF.

      ELSE.

        CLEAR gs_return.
        MESSAGE e000 INTO lv_dummy.
        gs_return-type       = sy-msgty.
        gs_return-id         = sy-msgid.
        gs_return-number     = sy-msgno.
        gs_return-message_v1 = sy-msgv1.
        gs_return-message_v2 = sy-msgv2.
        gs_return-message_v3 = sy-msgv3.
        gs_return-message_v4 = sy-msgv4.
        APPEND gs_return TO gt_return.

        message_save( is_msg = gs_return ).

      ENDIF.

    ENDIF.

    CLEAR gs_return.
    "Processo finalizado.
    MESSAGE s001 INTO lv_dummy.
    gs_return-type       = sy-msgty.
    gs_return-id         = sy-msgid.
    gs_return-number     = sy-msgno.
    gs_return-message_v1 = sy-msgv1.
    gs_return-message_v2 = sy-msgv2.
    gs_return-message_v3 = sy-msgv3.
    gs_return-message_v4 = sy-msgv4.
    APPEND gs_return TO gt_return.

    message_save( is_msg = gs_return ).

  ENDMETHOD.
ENDCLASS.
