CLASS zclfi_imp_action_fagl DEFINITION PUBLIC FINAL CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES:
      if_badi_interface,
      if_fagl_lib .

    CONSTANTS:
      gc_solc      TYPE char5 VALUE 'ZSOLC' ##NO_TEXT,
      gc_solc_text TYPE char25 VALUE 'Solicitação de Correção' ##NO_TEXT,
      gc_imp       TYPE char5 VALUE 'ZIMP' ##NO_TEXT.

  PRIVATE SECTION.
    METHODS:
      processa_imp
        IMPORTING
          it_outtab_selected_rows TYPE lvc_t_roid
          it_outtab               TYPE STANDARD TABLE,

      processa_solic_corr
        IMPORTING
          it_outtab_selected_rows TYPE lvc_t_roid
          it_outtab               TYPE STANDARD TABLE .

    CONSTANTS:
      gc_imp_text TYPE char25 VALUE 'Reimpressão' ##NO_TEXT,
      gc_shkzg_h  TYPE bsid_view-shkzg VALUE 'H',
      gc_zlsch_d  TYPE bsid_view-zlsch VALUE 'D',
      gc_zlsch_z  TYPE bsid_view-zlsch VALUE 'Z',
      gc_erro     TYPE char1           VALUE 'E'.
ENDCLASS.



CLASS ZCLFI_IMP_ACTION_FAGL IMPLEMENTATION.


  METHOD if_fagl_lib~main_toolbar_handle.

    CASE iv_ucomm.
      WHEN gc_solc.

        "Solicitação de correção
        processa_solic_corr(
          EXPORTING
            it_outtab_selected_rows = it_outtab_selected_rows
            it_outtab               = it_outtab ).

      WHEN gc_imp.

        "imprimir
        processa_imp(
          EXPORTING
            it_outtab_selected_rows = it_outtab_selected_rows
            it_outtab               = it_outtab ).



    ENDCASE.

  ENDMETHOD.


  METHOD if_fagl_lib~main_toolbar_handle_menu.
    RETURN.
  ENDMETHOD.


  METHOD if_fagl_lib~main_toolbar_set.

    IF sy-tcode = 'FBL5H'.
      "Solicitar Correção
      APPEND INITIAL LINE TO ct_toolbar ASSIGNING FIELD-SYMBOL(<fs_solc>).
      <fs_solc>-function = gc_solc.
      <fs_solc>-icon = '@0Q@'.
      <fs_solc>-quickinfo = gc_solc_text.
      <fs_solc>-text = gc_solc_text.


      "Imprimir
      APPEND INITIAL LINE TO ct_toolbar ASSIGNING FIELD-SYMBOL(<fs_imp>).
      <fs_imp>-function = gc_imp.
      <fs_imp>-icon = '@2P@'.
      <fs_imp>-quickinfo = gc_imp_text.
      <fs_imp>-text = gc_imp_text.

    ENDIF.

  ENDMETHOD.


  METHOD if_fagl_lib~sidebar_actions_handle.
    RETURN.
  ENDMETHOD.


  METHOD if_fagl_lib~sidebar_actions_set.
    RETURN.
  ENDMETHOD.


  METHOD if_fagl_lib~add_fields.
    RETURN.
  ENDMETHOD.


  METHOD if_fagl_lib~add_secondary_fields.
    RETURN.
  ENDMETHOD.


  METHOD if_fagl_lib~column_visibility_change.
    RETURN.
  ENDMETHOD.


  METHOD if_fagl_lib~create_default_restrictions.
    RETURN.
  ENDMETHOD.


  METHOD if_fagl_lib~modify_rri_restrictions.
    RETURN.
  ENDMETHOD.


  METHOD if_fagl_lib~select_data.
    RETURN.
  ENDMETHOD.


  METHOD processa_solic_corr.

    DATA lt_itens_proc TYPE zctgfi_itens_correcao.

    FIELD-SYMBOLS: <fs_field> TYPE any.

    IF it_outtab_selected_rows IS INITIAL.
      "Necessário selecionar linhas para processamento
      MESSAGE s000(zfi_cont_rcb) WITH TEXT-001 DISPLAY LIKE 'E'.
      RETURN.
    ENDIF.

    LOOP AT it_outtab_selected_rows ASSIGNING FIELD-SYMBOL(<fs_row>).
      READ TABLE it_outtab ASSIGNING FIELD-SYMBOL(<fs_line>) INDEX <fs_row>-row_id.
      IF sy-subrc = 0.
        APPEND INITIAL LINE TO lt_itens_proc ASSIGNING FIELD-SYMBOL(<fs_proc>).

        ASSIGN COMPONENT 'BUKRS' OF STRUCTURE <fs_line> TO <fs_field>.
        IF sy-subrc = 0.
          <fs_proc>-bukrs = <fs_field>.
        ENDIF.

        ASSIGN COMPONENT 'KUNNR' OF STRUCTURE <fs_line> TO <fs_field>.
        IF sy-subrc = 0.
          <fs_proc>-kunnr = <fs_field>.
        ENDIF.

        ASSIGN COMPONENT 'KNA1_NAME1' OF STRUCTURE <fs_line> TO <fs_field>.
        IF sy-subrc = 0.
          <fs_proc>-name1 = <fs_field>.
        ENDIF.

        ASSIGN COMPONENT 'BLART' OF STRUCTURE <fs_line> TO <fs_field>.
        IF sy-subrc = 0.
          <fs_proc>-blart = <fs_field>.
        ENDIF.

        ASSIGN COMPONENT 'BSCHL' OF STRUCTURE <fs_line> TO <fs_field>.
        IF sy-subrc = 0.
          <fs_proc>-bschl = <fs_field>.
        ENDIF.

        ASSIGN COMPONENT 'BELNR' OF STRUCTURE <fs_line> TO <fs_field>.
        IF sy-subrc = 0.
          <fs_proc>-belnr = <fs_field>.
        ENDIF.

        ASSIGN COMPONENT 'BUZEI' OF STRUCTURE <fs_line> TO <fs_field>.
        IF sy-subrc = 0.
          <fs_proc>-buzei = <fs_field>.
        ENDIF.

        ASSIGN COMPONENT 'GJAHR' OF STRUCTURE <fs_line> TO <fs_field>.
        IF sy-subrc = 0.
          <fs_proc>-gjahr = <fs_field>.
        ENDIF.

        ASSIGN COMPONENT 'XBLNR' OF STRUCTURE <fs_line> TO <fs_field>.
        IF sy-subrc = 0.
          <fs_proc>-xblnr = <fs_field>.
        ENDIF.

        ASSIGN COMPONENT 'ZUONR' OF STRUCTURE <fs_line> TO <fs_field>.
        IF sy-subrc = 0.
          <fs_proc>-zuonr = <fs_field>.
        ENDIF.

        ASSIGN COMPONENT 'HBKID' OF STRUCTURE <fs_line> TO <fs_field>.
        IF sy-subrc = 0.
          <fs_proc>-hbkid = <fs_field>.
        ENDIF.

        ASSIGN COMPONENT 'ZLSCH' OF STRUCTURE <fs_line> TO <fs_field>.
        IF sy-subrc = 0.
          <fs_proc>-zlsch = <fs_field>.
        ENDIF.

        ASSIGN COMPONENT 'ZTERM' OF STRUCTURE <fs_line> TO <fs_field>.
        IF sy-subrc = 0.
          <fs_proc>-zterm = <fs_field>.
        ENDIF.

        ASSIGN COMPONENT 'GSBER' OF STRUCTURE <fs_line> TO <fs_field>.
        IF sy-subrc = 0.
          <fs_proc>-gsber = <fs_field>.
        ENDIF.

        ASSIGN COMPONENT 'NETDT' OF STRUCTURE <fs_line> TO <fs_field>.
        IF sy-subrc = 0.
          <fs_proc>-netdt = <fs_field>.
        ENDIF.

        ASSIGN COMPONENT 'CURRVAL_10' OF STRUCTURE <fs_line> TO <fs_field>.
        IF sy-subrc = 0.
          <fs_proc>-wrbtr = <fs_field>.
        ENDIF.

      ENDIF.

    ENDLOOP.

    IF lt_itens_proc IS NOT INITIAL.

      CALL FUNCTION 'ZFMFI_SOL_CORRECAO'
        TABLES
          it_itens = lt_itens_proc.
    ENDIF.

  ENDMETHOD.


  METHOD processa_imp.

*    DATA: lt_key TYPE zctgfi_post_key.
    DATA: lt_keys TYPE zctgfi_boleto_documento.
    FIELD-SYMBOLS: <fs_field> TYPE any.

    DATA: lv_bukrs TYPE bseg-bukrs,
          lv_belnr TYPE bseg-belnr.

    IF it_outtab_selected_rows IS INITIAL.
      "Necessário selecionar linhas para processamento
      MESSAGE s000(zfi_cont_rcb) WITH TEXT-003 DISPLAY LIKE 'E'.
      RETURN.
    ELSEIF lines( it_outtab_selected_rows ) > 1.
*      "Selecione somente uma linha para impressão
*      MESSAGE s000(zfi_cont_rcb) WITH TEXT-002 DISPLAY LIKE 'E'..
*      RETURN.
    ENDIF.


    LOOP AT it_outtab_selected_rows ASSIGNING FIELD-SYMBOL(<fs_row>).

      READ TABLE it_outtab ASSIGNING FIELD-SYMBOL(<fs_line>) INDEX <fs_row>-row_id.
      IF sy-subrc = 0.

        APPEND INITIAL LINE TO lt_keys ASSIGNING FIELD-SYMBOL(<fs_key>).

        ASSIGN COMPONENT 'BUKRS' OF STRUCTURE <fs_line> TO <fs_field>.
        IF sy-subrc = 0.
          <fs_key>-bukrs = <fs_field>.
        ENDIF.
        ASSIGN COMPONENT 'BELNR' OF STRUCTURE <fs_line> TO <fs_field>.
        IF sy-subrc = 0.
          <fs_key>-belnr = <fs_field>.
        ENDIF.
        ASSIGN COMPONENT 'BUZEI' OF STRUCTURE <fs_line> TO <fs_field>.
        IF sy-subrc = 0.
          <fs_key>-buzei = <fs_field>.
        ENDIF.
        ASSIGN COMPONENT 'GJAHR' OF STRUCTURE <fs_line> TO <fs_field>.
        IF sy-subrc = 0.
          <fs_key>-gjahr = <fs_field>.
        ENDIF.
      ENDIF.
    ENDLOOP.

    IF lt_keys IS NOT INITIAL.

      SELECT belnr, shkzg, zlsch, hbkid  FROM bsid_view
      FOR ALL ENTRIES IN @lt_keys
      WHERE bukrs = @lt_keys-bukrs
        AND belnr = @lt_keys-belnr
        AND buzei = @lt_keys-buzei
        AND gjahr = @lt_keys-gjahr
      INTO TABLE @DATA(lt_documentos_validar).

      LOOP AT lt_documentos_validar ASSIGNING FIELD-SYMBOL(<fs_documento_validar>).
        IF <fs_documento_validar>-shkzg = gc_shkzg_h.
          MESSAGE s007(zfi_cont_rcb) WITH <fs_documento_validar>-belnr DISPLAY LIKE gc_erro.
          RETURN.
        ENDIF.
        IF NOT ( <fs_documento_validar>-zlsch = gc_zlsch_d OR <fs_documento_validar>-zlsch = gc_zlsch_z ).
          MESSAGE s008(zfi_cont_rcb) WITH <fs_documento_validar>-belnr DISPLAY LIKE gc_erro.
          RETURN.
        ENDIF.
        IF <fs_documento_validar>-hbkid IS INITIAL.
          MESSAGE s009(zfi_cont_rcb) WITH <fs_documento_validar>-belnr DISPLAY LIKE gc_erro.
          RETURN.
        ENDIF.
      ENDLOOP.

      CALL FUNCTION 'ZFMFI_BOLETO_FBL5H'
        EXPORTING
          is_key = lt_keys.

    ENDIF.

  ENDMETHOD.
ENDCLASS.
