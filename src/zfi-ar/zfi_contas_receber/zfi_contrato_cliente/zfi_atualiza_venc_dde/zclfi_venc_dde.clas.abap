CLASS zclfi_venc_dde DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    TYPES:
      BEGIN OF ty_bseg,
        buzei TYPE bseg-buzei,
        bukrs TYPE bseg-bukrs,
        belnr TYPE bseg-belnr,
        gjahr TYPE bseg-gjahr,
      END OF ty_bseg .

    TYPES:
      ty_t_venc TYPE TABLE OF zc_fi_venc_dde_busca WITH DEFAULT KEY .
    TYPES:
      ty_t_ctr TYPE TABLE OF zi_fi_dde_contrato WITH DEFAULT KEY .


    METHODS constructor
      IMPORTING
        !it_vencimento TYPE ty_t_venc .
    METHODS process_by_app
      IMPORTING
        !iv_cliente      TYPE zi_fi_venc_dde_app-cliente
        !iv_documento    TYPE zi_fi_venc_dde_app-documento
        !iv_empresa      TYPE zi_fi_venc_dde_app-empresa
        !iv_exercicio    TYPE zi_fi_venc_dde_app-exercicio
        !iv_fatura       TYPE zi_fi_venc_dde_app-fatura
        !iv_remessa      TYPE zi_fi_venc_dde_app-remessa
      RETURNING
        VALUE(rt_return) TYPE bapiret2_tab .
    METHODS process_by_job
      IMPORTING
        !iv_cliente      TYPE zi_fi_venc_dde_app-cliente
        !iv_documento    TYPE zi_fi_venc_dde_app-documento
        !iv_empresa      TYPE zi_fi_venc_dde_app-empresa
        !iv_exercicio    TYPE zi_fi_venc_dde_app-exercicio
        !iv_fatura       TYPE zi_fi_venc_dde_app-fatura
        !iv_remessa      TYPE zi_fi_venc_dde_app-remessa
        !iv_item         TYPE buzei OPTIONAL
      RETURNING
        VALUE(rt_return) TYPE bapiret2_tab .
    METHODS task_finish
      IMPORTING
        !p_task TYPE clike .
  PROTECTED SECTION.
  PRIVATE SECTION.

    DATA gt_venc TYPE ty_t_venc .
    DATA gt_return TYPE bapiret2_tab .
    DATA gt_ctr TYPE ty_t_ctr .

    METHODS get_contrato
      RETURNING
        VALUE(rt_ctr) TYPE ty_t_ctr .

ENDCLASS.



CLASS zclfi_venc_dde IMPLEMENTATION.


  METHOD process_by_app.

*    DATA lv_prazo TYPE ze_prazo.

    READ TABLE gt_venc ASSIGNING FIELD-SYMBOL(<fs_venc>) WITH KEY kunnr = iv_cliente
                                                                  belnr = iv_documento
                                                                  bukrs = iv_empresa
                                                                  gjahr = iv_exercicio
                                                                  vbeln = iv_fatura
                                                                  vgbel = iv_remessa
                                                         BINARY SEARCH.

    IF sy-subrc = 0.

*      READ TABLE gt_ctr ASSIGNING FIELD-SYMBOL(<fs_ctr>) WITH KEY cnpjroot = <fs_venc>-cnpjroot
*                                                         BINARY SEARCH.
*
*      IF sy-subrc = 0.
*        lv_prazo = <fs_ctr>-prazo.
*      ENDIF.

      CALL FUNCTION 'ZFMFI_VENCIMENTODDE'
        STARTING NEW TASK 'BACKGROUND' CALLING task_finish ON END OF TASK
        EXPORTING
          is_cds    = <fs_venc>
        CHANGING
          ct_return = gt_return.

      WAIT FOR ASYNCHRONOUS TASKS UNTIL gt_return IS NOT INITIAL.

      APPEND LINES OF gt_return TO rt_return.

    ENDIF.

  ENDMETHOD.


  METHOD process_by_job.

    READ TABLE gt_venc ASSIGNING FIELD-SYMBOL(<fs_venc>) WITH KEY kunnr = iv_cliente
                                                                  belnr = iv_documento
                                                                  bukrs = iv_empresa
                                                                  gjahr = iv_exercicio
                                                                  vbeln = iv_fatura
                                                                  vgbel = iv_remessa
                                                                  buzei = iv_item
                                                         BINARY SEARCH.

    IF sy-subrc = 0.

      CALL FUNCTION 'ZFMFI_VENCIMENTODDE'
        EXPORTING
          is_cds    = <fs_venc>
        CHANGING
          ct_return = gt_return.

      rt_return = gt_return.

    ENDIF.

  ENDMETHOD.


  METHOD constructor.

    gt_venc = it_vencimento.

    gt_ctr = get_contrato( ).

    SORT gt_venc BY kunnr belnr bukrs gjahr vbeln vgbel buzei.

  ENDMETHOD.


  METHOD task_finish.

    RECEIVE RESULTS FROM FUNCTION 'ZFMFI_VENCIMENTODDE'
      TABLES
        ct_return = gt_return.

    RETURN.

  ENDMETHOD.


  METHOD get_contrato.

    SELECT *
      FROM zi_fi_dde_contrato
      INTO TABLE @rt_ctr
      FOR ALL ENTRIES IN @gt_venc
      WHERE cnpjroot = @gt_venc-cnpjroot.

  ENDMETHOD.


ENDCLASS.
