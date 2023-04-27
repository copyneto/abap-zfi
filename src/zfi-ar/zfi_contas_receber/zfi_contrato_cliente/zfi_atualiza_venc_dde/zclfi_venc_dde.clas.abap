class ZCLFI_VENC_DDE definition
  public
  final
  create public .

public section.

  types:
    BEGIN OF ty_bseg,
        buzei TYPE bseg-buzei,
        bukrs TYPE bseg-bukrs,
        belnr TYPE bseg-belnr,
        gjahr TYPE bseg-gjahr,
      END OF ty_bseg .
  types:
    ty_t_venc TYPE TABLE OF zc_fi_venc_dde_busca WITH DEFAULT KEY .
  types:
    ty_t_ctr TYPE TABLE OF zi_fi_dde_contrato WITH DEFAULT KEY .

  methods CONSTRUCTOR
    importing
      !IT_VENCIMENTO type TY_T_VENC .
  methods PROCESS_BY_APP
    importing
      !IV_CLIENTE type ZI_FI_VENC_DDE_APP-CLIENTE
      !IV_DOCUMENTO type ZI_FI_VENC_DDE_APP-DOCUMENTO
      !IV_EMPRESA type ZI_FI_VENC_DDE_APP-EMPRESA
      !IV_EXERCICIO type ZI_FI_VENC_DDE_APP-EXERCICIO
      !IV_FATURA type ZI_FI_VENC_DDE_APP-FATURA
      !IV_REMESSA type ZI_FI_VENC_DDE_APP-REMESSA
    returning
      value(RT_RETURN) type BAPIRET2_TAB .
  methods PROCESS_BY_JOB
    importing
      !IV_CLIENTE type ZI_FI_VENC_DDE_APP-CLIENTE
      !IV_DOCUMENTO type ZI_FI_VENC_DDE_APP-DOCUMENTO
      !IV_EMPRESA type ZI_FI_VENC_DDE_APP-EMPRESA
      !IV_EXERCICIO type ZI_FI_VENC_DDE_APP-EXERCICIO
      !IV_FATURA type ZI_FI_VENC_DDE_APP-FATURA
      !IV_REMESSA type ZI_FI_VENC_DDE_APP-REMESSA
      !IV_ITEM type BUZEI optional
    returning
      value(RT_RETURN) type BAPIRET2_TAB .
  methods TASK_FINISH
    importing
      !P_TASK type CLIKE .
  PROTECTED SECTION.
private section.

  data GT_VENC type TY_T_VENC .
  data GT_RETURN type BAPIRET2_TAB .
  data GT_CTR type TY_T_CTR .

  methods GET_CONTRATO
    returning
      value(RT_CTR) type TY_T_CTR .
ENDCLASS.



CLASS ZCLFI_VENC_DDE IMPLEMENTATION.


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
