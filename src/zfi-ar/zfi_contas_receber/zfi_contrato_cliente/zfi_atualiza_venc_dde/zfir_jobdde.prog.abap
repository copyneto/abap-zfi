*&---------------------------------------------------------------------*
*& Report ZFIR_JOBDDE
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zfir_jobdde.

TABLES: bseg.

CONSTANTS: gc_tcode TYPE sy-tcode  VALUE 'ZFIDDE',
           gc_sub   TYPE balsubobj VALUE 'LOG_JOB'.

DATA gt_msg TYPE bapiret2_tab.

DATA gt_vencimento TYPE TABLE OF zc_fi_venc_dde_busca WITH DEFAULT KEY.

SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-b01.
  SELECT-OPTIONS: s_bukrs FOR bseg-bukrs,
                  s_belnr FOR bseg-belnr,
                  s_gjahr FOR bseg-gjahr.
SELECTION-SCREEN END OF BLOCK b1.

START-OF-SELECTION.

  DATA(go_log) = NEW zclca_save_log( gc_tcode ).

  go_log->create_log( gc_sub ).

  DATA(go_dde_data) = zclfi_venc_dde_data=>get_instance( ).

  GET REFERENCE OF s_bukrs[] INTO go_dde_data->gr_bukrs.
  GET REFERENCE OF s_belnr[] INTO go_dde_data->gr_belnr.
  GET REFERENCE OF s_gjahr[] INTO go_dde_data->gr_gjahr.

  go_dde_data->set_ref_data( ).

  DATA(gt_cockpit) = go_dde_data->build( ).

END-OF-SELECTION.

  gt_vencimento = CORRESPONDING #( gt_cockpit ).

  DATA(go_exec) = NEW zclfi_venc_dde( gt_vencimento ).

  IF gt_vencimento IS NOT INITIAL.

    LOOP AT gt_vencimento ASSIGNING FIELD-SYMBOL(<fs_venc>).

      gt_msg = go_exec->process_by_job( iv_cliente   = <fs_venc>-kunnr
                                        iv_documento = <fs_venc>-belnr
                                        iv_empresa   = <fs_venc>-bukrs
                                        iv_exercicio = <fs_venc>-gjahr
                                        iv_fatura    = <fs_venc>-vbeln
                                        iv_remessa   = <fs_venc>-vgbel
                                        iv_item      = <fs_venc>-buzei ).

      go_log->add_msgs( gt_msg ).

      REFRESH gt_msg.

    ENDLOOP.

  ELSE.

    APPEND INITIAL LINE TO gt_msg ASSIGNING FIELD-SYMBOL(<fs_msg>).
    <fs_msg>-id         = 'ZFI_DDE'.
    <fs_msg>-number     = '001'.
    <fs_msg>-type       = 'E'.

    go_log->add_msgs( gt_msg ).

  ENDIF.

  go_log->save( ).

  MESSAGE s002(zfi_dde).
