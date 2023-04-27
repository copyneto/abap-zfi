*&---------------------------------------------------------------------*
*& Include ZFII_ICMS_ST
*&---------------------------------------------------------------------*
  DATA: ls_vbrk  TYPE vbrk,
        ls_vbrp  TYPE vbrpvb,
        lv_regio TYPE regio,
        lv_wkreg TYPE wkreg.

  DATA: lv_newsetid TYPE sethier-setid,
        lt_setval   TYPE TABLE OF rgsb4.

  FIELD-SYMBOLS: <fs_vbrk>      TYPE vbrk,
                 <fs_tvko_sadr> TYPE sadr,
                 <fs_kuwev>     TYPE kuwev,
                 <fs_xvbrp>     TYPE vbrpvb.


  IF bkpf-awtyp = 'VBRK' AND
     bkpf-glvor = 'SD00'.

    ASSIGN ('(SAPLV60B)VBRK') TO <fs_vbrk>.
    IF <fs_vbrk> IS ASSIGNED.
      MOVE <fs_vbrk> TO ls_vbrk.
      MOVE ls_vbrk-regio TO lv_regio.
      "Faturamento via VF02
      SELECT wkreg UP TO 1 ROWS
        INTO lv_wkreg
        FROM vbrp
        WHERE vbeln EQ ls_vbrk-vbeln.
      ENDSELECT.

      IF sy-subrc EQ 0.
        MOVE ls_vbrk-regio TO lv_regio.
      ELSE.
        "Faturamento via VF04 (Coletivo)
        ASSIGN ('(SAPLV60B)XVBRP') TO <fs_xvbrp>.
        IF <fs_xvbrp> IS ASSIGNED.
          MOVE <fs_xvbrp> TO ls_vbrp.
          MOVE ls_vbrk-regio TO lv_regio.
          MOVE ls_vbrp-wkreg TO lv_wkreg.
        ENDIF.
      ENDIF.
    ENDIF.

    "Ajuste Contabilização ICMS ST para o processo STO - Transferência entre centros
  ELSEIF bkpf-awtyp = 'MKPF' AND bkpf-glvor = 'RMWL'.

    ASSIGN ('(SAPFV50W)TVKO_SADR') TO <fs_tvko_sadr>.
    ASSIGN ('(SAPFV50W)KUWEV') TO <fs_kuwev>.
    "Atribuir a região do emitente
    IF <fs_tvko_sadr> IS ASSIGNED.
      lv_wkreg = <fs_tvko_sadr>-regio.
    ENDIF.
    "Atribuir região do destinatário
    IF <fs_kuwev> IS ASSIGNED.
      lv_regio = <fs_kuwev>-regio.
    ENDIF.

  ENDIF.

  IF lv_regio <> lv_wkreg.

    "Verificar SET
    CALL FUNCTION 'G_SET_GET_ID_FROM_NAME'
      EXPORTING
        shortname = 'ZCONTA_ICMS_ST'
      IMPORTING
        new_setid = lv_newsetid.

    "Valores
    CALL FUNCTION 'G_SET_GET_ALL_VALUES'
      EXPORTING
        setnr      = lv_newsetid
      TABLES
        set_values = lt_setval.

    "Verificando se existe no SET, se sim, preencher BSEG-HKONT
    READ TABLE lt_setval INDEX 1 INTO DATA(ls_setval).
    IF sy-subrc EQ 0.
      bseg-hkont = ls_setval-from.
    ENDIF.

  ENDIF.
