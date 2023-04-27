*----------------------------------------------------------------------*
***INCLUDE LZFGFI_BOLETO_FBL5HI01.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_9001  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_9001 INPUT.

  DATA lo_gerar_boleto TYPE REF TO zclfi_gerar_boleto.
  DATA ls_param  TYPE ssfctrlop.

  CASE sy-ucomm.
    WHEN 'ZEXE'.

      IF gv_imp = abap_true.
        IF lines( gt_key ) > 1.
          MESSAGE s000(zfi_cont_rcb) WITH TEXT-001 DISPLAY LIKE 'E'.
          SET SCREEN 0.
          LEAVE TO SCREEN 0.
        ENDIF.

        ls_param-no_dialog = abap_true.
        ls_param-preview = abap_true.

      ELSE.

        IF lines( gt_key ) > 1.
*          MESSAGE s000(zfi_cont_rcb) WITH TEXT-002 DISPLAY LIKE 'E'.
*          SET SCREEN 0.
*          LEAVE TO SCREEN 0.
        ENDIF.

        ls_param-no_dialog = abap_true.
        ls_param-preview   = abap_false.
        ls_param-getotf    = abap_true.
        ls_param-device    = 'LOCL'.
      ENDIF.

      lo_gerar_boleto = NEW zclfi_gerar_boleto( is_param = ls_param ).
      lo_gerar_boleto->process( EXPORTING it_keys = gt_key ).

      SET SCREEN 0.
      LEAVE TO SCREEN 0.

    WHEN 'BACK'
      OR 'EXIT'
      OR 'CANCEL'
      OR '&F12'.
      SET SCREEN 0.
      LEAVE TO SCREEN 0.

  ENDCASE.

ENDMODULE.
