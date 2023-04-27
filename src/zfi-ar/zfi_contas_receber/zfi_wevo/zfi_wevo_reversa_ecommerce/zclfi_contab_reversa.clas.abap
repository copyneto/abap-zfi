class ZCLFI_CONTAB_REVERSA definition
  public
  final
  create public .

public section.

  methods CONTABILIZA_REVERSA
    importing
      !IT_CONTAB type ZCTGFI_WEVO_CONTAB
    exporting
      !ET_RETORNO type ZCTGFI_RETRN_CTREVERSA .
  methods VALIDA_REVERSA
    exporting
      !ET_RETORNO type ZCTGFI_RETRN_CTREVERSA
    changing
      !CT_CONTAB type ZCTGFI_WEVO_CONTAB optional .
  methods MAIN
    importing
      !IT_CONTAB type ZCTGFI_WEVO_CONTAB
    exporting
      !ET_RETORNO type ZCTGFI_RETRN_CTREVERSA .
protected section.
private section.
ENDCLASS.



CLASS ZCLFI_CONTAB_REVERSA IMPLEMENTATION.


  METHOD contabiliza_reversa.

    DATA: lt_contab  TYPE STANDARD TABLE OF ztfi_wevo_contab,
          lt_retorno TYPE STANDARD TABLE OF zsfi_retrn_ctreversa.

    DATA: ls_retorno TYPE zsfi_retrn_ctreversa.

    DATA: lv_msg TYPE bapi_msg.

    LOOP AT it_contab ASSIGNING FIELD-SYMBOL(<fs_contab>).

      CALL FUNCTION 'ZFMFI_CONTAB_REVERSA'
        EXPORTING
          iv_cenario       = <fs_contab>-cod_cenario
          iv_bukrs         = <fs_contab>-bukrs
          iv_bstkd         = <fs_contab>-bstkd
          iv_bupla         = <fs_contab>-bupla
          iv_zlsch         = <fs_contab>-zlsch
          iv_tipo_cenario  = <fs_contab>-tipo_cenario
          iv_ordem         = <fs_contab>-ordem
          iv_pagamento     = <fs_contab>-pagamento
          iv_ressarcimento = <fs_contab>-cod_ressarcimento
          iv_mercadoria    = <fs_contab>-mercadoria
          iv_ordem_venda   = <fs_contab>-vbeln
          iv_lifnr         = <fs_contab>-lifnr
          iv_voucher       = <fs_contab>-voucher
          iv_zvou          = <fs_contab>-zvou
          iv_vlr_restituir = <fs_contab>-vlr_restituir
          iv_id_pedido     = <fs_contab>-id_pedido
          iv_dias          = <fs_contab>-dias
          iv_adm           = <fs_contab>-adm
          iv_nsu           = <fs_contab>-nsu
          iv_dt_venda      = <fs_contab>-dt_venda
*         iv_encerrar      = ' '
*         iv_lcto_pendente = 'X'
*         iv_tx_perc       =
*         iv_id_sales_force =
*         IV_RESERVADO_1   =
*         IV_RESERVADO_2   =
*         IV_RESERVADO_3   =
*         IV_RESERVADO_4   =
*         IV_RESERVADO_5   =
*         IV_RESERVADO_6   =
*         IV_RESERVADO_7   =
*         IV_RESERVADO_8   =
*         IV_RESERVADO_9   =
*         IV_RESERVADO_10  =
        IMPORTING
          ev_subrc         = ls_retorno-subrc
          ev_msg           = lv_msg
          ev_belnr         = ls_retorno-belnr
          ev_gjahr         = ls_retorno-gjahr
          ev_bukrs         = ls_retorno-bukrs
          ev_belnr_f       = ls_retorno-belnr_f
          ev_gjahr_f       = ls_retorno-gjahr_f
          ev_bukrs_f       = ls_retorno-bukrs_f.

      IF ls_retorno-subrc IS INITIAL.
        ls_retorno-msg = |{ TEXT-t01 } { <fs_contab>-bstkd } { TEXT-t02 } { <fs_contab>-vbeln } { TEXT-t03 } { ls_retorno-belnr }|.
      ELSE.
        ls_retorno-msg = |{ TEXT-t01 } { <fs_contab>-bstkd } { TEXT-t02 } { <fs_contab>-vbeln } { TEXT-t04 } { lv_msg }|.
      ENDIF.

      APPEND ls_retorno TO et_retorno.
      CLEAR: ls_retorno.

    ENDLOOP.

  ENDMETHOD.


  METHOD valida_reversa.

    DATA: ls_retorno TYPE zsfi_retrn_ctreversa.

    DATA: lv_tabix TYPE sy-tabix.

    CHECK ct_contab[] IS NOT INITIAL.

    SELECT bstkd,
           belnr
      FROM ztfi_cont_revers
       FOR ALL ENTRIES IN @ct_contab
     WHERE bstkd = @ct_contab-bstkd
      INTO TABLE @DATA(lt_revers).

    IF sy-subrc IS INITIAL.

      SORT lt_revers BY bstkd.

      LOOP AT ct_contab ASSIGNING FIELD-SYMBOL(<fs_contab>).
        lv_tabix = sy-tabix.

        READ TABLE lt_revers ASSIGNING FIELD-SYMBOL(<fs_revers>)
                                           WITH KEY bstkd = <fs_contab>-bstkd
                                           BINARY SEARCH.
        IF sy-subrc IS INITIAL.
          ls_retorno-subrc = 4.
          ls_retorno-bstkd = <fs_contab>-bstkd.
          ls_retorno-vbeln = <fs_contab>-vbeln.
          ls_retorno-belnr = <fs_revers>-belnr.
          ls_retorno-msg   = |{ TEXT-t05 } { TEXT-t01 } { <fs_contab>-bstkd } { TEXT-t02 } { <fs_contab>-vbeln } { TEXT-t03 } { <fs_revers>-belnr } |.
          APPEND ls_retorno TO et_retorno.
          DELETE ct_contab INDEX lv_tabix.
        ENDIF.
      ENDLOOP.
    ENDIF.

  ENDMETHOD.


  METHOD main.

    DATA: lt_processados TYPE STANDARD TABLE OF ztfi_wevo_contab,
          lt_retorno     TYPE STANDARD TABLE OF zsfi_retrn_ctreversa,
          lt_retorno_aux TYPE STANDARD TABLE OF zsfi_retrn_ctreversa,
          lt_contab      TYPE STANDARD TABLE OF ztfi_wevo_contab.

    DATA: ls_processados TYPE ztfi_wevo_contab.

    DATA: lv_subrc   TYPE  sy-subrc,
          lv_msg     TYPE  bapi_msg,
          lv_belnr   TYPE  bseg-belnr,
          lv_gjahr   TYPE  bseg-gjahr,
          lv_bukrs   TYPE  bseg-bukrs,
          lv_belnr_f TYPE  bseg-belnr,
          lv_gjahr_f TYPE  bseg-gjahr,
          lv_bukrs_f TYPE  bseg-bukrs.

    CHECK it_contab[] IS NOT INITIAL.

    lt_contab[] = it_contab[].

    DATA(lo_contab) = NEW zclfi_contab_reversa( ).

    FREE: lt_retorno_aux[].
    lo_contab->valida_reversa( IMPORTING et_retorno = lt_retorno_aux[]
                                CHANGING ct_contab  = lt_contab[] ).

    IF lt_retorno_aux[] IS NOT INITIAL.
      APPEND LINES OF lt_retorno_aux TO lt_retorno.

      LOOP AT lt_retorno_aux ASSIGNING FIELD-SYMBOL(<fs_retorno>).
        IF <fs_retorno>-bstkd IS NOT INITIAL.
          ls_processados-bstkd = <fs_retorno>-bstkd.
          APPEND ls_processados TO lt_processados.
          CLEAR ls_processados.
        ENDIF.
      ENDLOOP.
    ENDIF.

    IF lt_contab[] IS NOT INITIAL.

      FREE: lt_retorno_aux[].
      lo_contab->contabiliza_reversa( EXPORTING it_contab  = lt_contab[]
                                      IMPORTING et_retorno = lt_retorno_aux[] ).
      IF lt_retorno_aux[] IS NOT INITIAL.
        APPEND LINES OF lt_retorno_aux TO lt_retorno.

        LOOP AT lt_retorno_aux ASSIGNING <fs_retorno>.
          IF <fs_retorno>-subrc = 0
         AND <fs_retorno>-bstkd IS NOT INITIAL
         AND <fs_retorno>-belnr IS NOT INITIAL.
            ls_processados-bstkd = <fs_retorno>-bstkd.
            APPEND ls_processados TO lt_processados.
            CLEAR ls_processados.
          ENDIF.
        ENDLOOP.

        IF lt_processados[] IS NOT INITIAL.
          DELETE ztfi_wevo_contab FROM TABLE lt_processados.
          IF sy-subrc IS INITIAL.
            COMMIT WORK AND WAIT.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.

    et_retorno[] = lt_retorno[].

  ENDMETHOD.
ENDCLASS.
