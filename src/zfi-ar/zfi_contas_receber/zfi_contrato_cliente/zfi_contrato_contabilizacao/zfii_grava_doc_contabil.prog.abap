*&---------------------------------------------------------------------*
*& Include ZFII_GRAVA_DOC_CONTABIL
*&---------------------------------------------------------------------*

FIELD-SYMBOLS <fs_vbrk> TYPE vbrk.

DATA lt_doc TYPE TABLE OF ztfi_cont_cont.

ASSIGN ('(SAPLV60B)VBRK') TO <fs_vbrk>.
IF <fs_vbrk> IS ASSIGNED.
  IF NOT xvbrk-belnr IS INITIAL.
    "Tabela importada da user-exit EXIT_SAPLV60B_008, include ZXVVFU08, include ZFII_CONTRATOS_CONTAB,
    "final do método EXECUTAR da classe ZCLFI_CONTRATOS_CONTAB para a gravação do documento contábil gerado (BSID)
    IMPORT lt_doc TO lt_doc FROM MEMORY ID 'ZTFI_CONT_CONT'.
    IF NOT lt_doc IS INITIAL.
      DO 10 TIMES.
        SELECT belnr, buzei, wrbtr, gjahr
          FROM bsid_view
          INTO TABLE @DATA(lt_bsid)
          FOR ALL ENTRIES IN @lt_doc
          WHERE bukrs = @lt_doc-bukrs
            AND gjahr = @lt_doc-gjahr
            AND vbeln = @<fs_vbrk>-vbeln.
        IF sy-subrc EQ 0.
          EXIT.
        ELSE.
          WAIT UP TO 1 SECONDS.
        ENDIF.
      ENDDO.
      DESCRIBE TABLE lt_bsid LINES DATA(lv_lines).
      LOOP AT lt_bsid ASSIGNING FIELD-SYMBOL(<fs_bsid>).
        READ TABLE lt_doc ASSIGNING FIELD-SYMBOL(<fs_doc>) INDEX sy-tabix.
        IF sy-subrc EQ 0.
          DATA(ls_doc) = <fs_doc>.
          <fs_doc>-belnr          = <fs_bsid>-belnr.
          <fs_doc>-numero_item    = <fs_bsid>-buzei.
          <fs_doc>-wrbtr          = <fs_bsid>-wrbtr.
          <fs_doc>-gjahr          = <fs_bsid>-gjahr.
          <fs_doc>-doc_provisao   = <fs_bsid>-belnr.
          <fs_doc>-exerc_provisao = <fs_bsid>-gjahr.
          <fs_doc>-mont_provisao  = <fs_doc>-mont_provisao / lv_lines.
        ELSE.
          ls_doc-belnr          = <fs_bsid>-belnr.
          ls_doc-numero_item    = <fs_bsid>-buzei.
          ls_doc-wrbtr          = <fs_bsid>-wrbtr.
          ls_doc-gjahr          = <fs_bsid>-gjahr.
          ls_doc-doc_provisao   = <fs_bsid>-belnr.
          ls_doc-exerc_provisao = <fs_bsid>-gjahr.
          ls_doc-mont_provisao  = ls_doc-mont_provisao / lv_lines.
          APPEND ls_doc TO lt_doc.
        ENDIF.
      ENDLOOP.
      MODIFY ztfi_cont_cont FROM TABLE lt_doc[].
      FREE MEMORY ID 'ZTFI_CONT_CONT'.
    ENDIF.
  ENDIF.
ENDIF.
