*&---------------------------------------------------------------------*
*& Include LZFGFI_SOL_CORRECAOI01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_9001  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_9001 INPUT.

  DATA: lt_itens TYPE zctgfi_itens_correcao.

  CASE sy-ucomm.

    WHEN 'ZSOL'.

      lt_itens =  VALUE #(
        FOR ls_item IN gt_itens WHERE ( mark = abap_true )
        ( bukrs          = ls_item-include-bukrs
          kunnr          = ls_item-include-kunnr
          name1          = ls_item-include-name1
          blart          = ls_item-include-blart
          bschl          = ls_item-include-bschl
          belnr          = ls_item-include-belnr
          buzei          = ls_item-include-buzei
          gjahr          = ls_item-include-gjahr
          xblnr          = ls_item-include-xblnr
          zuonr          = ls_item-include-zuonr
          hbkid          = ls_item-include-hbkid
          zlsch          = ls_item-include-zlsch
          zterm          = ls_item-include-zterm
          gsber          = ls_item-include-gsber
          netdt          = ls_item-include-netdt
          wrbtr          = ls_item-include-wrbtr
          novovencimento = ls_item-include-novovencimento
          motivo_pro     = ls_item-include-motivo_pro
      ) ).                                               "#EC CI_STDSEQ

      IF lines( lt_itens ) < 1.
        MESSAGE s000(zfi_cont_rcb) WITH TEXT-002 DISPLAY LIKE 'E'.
        EXIT.
      ENDIF.

      SORT lt_itens BY bukrs belnr gjahr.
      SELECT bukrs, belnr, gjahr, budat FROM bkpf
      FOR ALL ENTRIES IN @lt_itens
        WHERE bukrs = @lt_itens-bukrs
          AND belnr = @lt_itens-belnr
          AND gjahr = @lt_itens-gjahr
      INTO TABLE @DATA(lt_bkpf).
      DATA(gv_sucesso_data) = abap_true.
      LOOP AT lt_itens ASSIGNING FIELD-SYMBOL(<fs_itens>).
        READ TABLE lt_bkpf ASSIGNING FIELD-SYMBOL(<fs_bkpf>)
        WITH KEY bukrs = <fs_itens>-bukrs
                 belnr = <fs_itens>-belnr
                 gjahr = <fs_itens>-gjahr BINARY SEARCH.
        IF sy-subrc = 0 AND <fs_itens>-novovencimento < <fs_bkpf>-budat.
         MESSAGE s010(zfi_cont_rcb) DISPLAY LIKE 'E'.
         gv_sucesso_data = abap_false.
         EXIT.
        ENDIF.
      ENDLOOP.
      IF gv_sucesso_data = abap_false.
        EXIT.
      ENDIF.

      DATA(gv_sucesso) = go_process->process_sol( it_itens = lt_itens ).
      IF gv_sucesso = abap_true.
        MESSAGE s000(zfi_cont_rcb) WITH TEXT-001.
      ELSE.
        MESSAGE s000(zfi_cont_rcb) WITH TEXT-003 DISPLAY LIKE 'E'.
      ENDIF.
      SET SCREEN 0.
      LEAVE TO SCREEN 0.
    WHEN 'ZREP'.
      LOOP AT gt_itens ASSIGNING FIELD-SYMBOL(<fs_item_atual>).
        IF <fs_item_atual>-include-novovencimento IS NOT INITIAL OR
            <fs_item_atual>-include-motivo_pro IS NOT INITIAL.
          DATA(gv_preenchido) = abap_true.
          EXIT.
        ENDIF.
      ENDLOOP.
      IF gv_preenchido = abap_true.
        LOOP AT gt_itens ASSIGNING FIELD-SYMBOL(<fs_item>).
          <fs_item>-include-novovencimento = COND #(
            WHEN <fs_item>-include-novovencimento IS INITIAL
            THEN <fs_item_atual>-include-novovencimento
            ELSE <fs_item>-include-novovencimento
          ).
          <fs_item>-include-motivo_pro = COND #(
            WHEN <fs_item>-include-motivo_pro IS INITIAL
            THEN <fs_item_atual>-include-motivo_pro
            ELSE <fs_item>-include-motivo_pro
          ).
        ENDLOOP.
      ENDIF.

    WHEN '&ALL'.
      LOOP AT gt_itens ASSIGNING <fs_item>.
        <fs_item>-mark = abap_true.
      ENDLOOP.
    WHEN '&SAL'.
      LOOP AT gt_itens ASSIGNING <fs_item>.
        <fs_item>-mark = abap_false.
      ENDLOOP.
    WHEN 'BACK' OR 'EXIT' OR 'CANCEL' OR '&F12'.
      SET SCREEN 0.
      LEAVE TO SCREEN 0.
  ENDCASE.

ENDMODULE.

MODULE check_table INPUT.
  MODIFY gt_itens FROM gs_item INDEX tbc_sol_correc-current_line.
ENDMODULE.

MODULE transp_itab OUTPUT.
  READ TABLE gt_itens INDEX tbc_sol_correc-current_line INTO gs_item.
ENDMODULE.
