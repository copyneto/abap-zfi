*&---------------------------------------------------------------------*
*& Report ZFIR_REVERSAO
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zfir_reversao.

TYPES: BEGIN OF ty_log,
         documento TYPE belnr_d,
         empresa   TYPE bukrs,
         exercicio TYPE gjahr,
         mensagem  TYPE bapiret2-message,
       END OF ty_log.

DATA: gv_belnr TYPE bsid_view-belnr.
DATA: gs_mot TYPE zi_fi_reversao_popup.

DATA: gt_log TYPE TABLE OF ty_log.
DATA: gs_log TYPE ty_log.

DATA: gt_msg TYPE bapiret2_tab.

CONSTANTS: gc_tcode TYPE sy-tcode VALUE 'ZFIREVERSAO',
           gc_sub   TYPE balsubobj VALUE 'LOG_JOB'.

SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-b01.

  SELECT-OPTIONS: s_belnr FOR gv_belnr.

  PARAMETERS: p_bukrs TYPE bsid_view-bukrs OBLIGATORY,
              p_gjahr TYPE bsid_view-gjahr OBLIGATORY.

SELECTION-SCREEN END OF BLOCK b1.

START-OF-SELECTION.

  SELECT *
    FROM zi_fi_reversao
    INTO TABLE @DATA(gt_rev)
    WHERE belnr NE @space.

END-OF-SELECTION.

  DATA(go_rev) = NEW zclfi_exec_reversao( ).

  DATA(go_log) = NEW zclca_save_log( gc_tcode ).

  go_log->create_log( gc_sub ).

  IF gt_rev IS NOT INITIAL.

    LOOP AT gt_rev ASSIGNING FIELD-SYMBOL(<fs_rev>).

      gt_msg = go_rev->execute( EXPORTING iv_doc   = <fs_rev>-augbl
                                          iv_emp   = <fs_rev>-bukrs
                                          iv_year  = <fs_rev>-gjahr
                                          iv_tpsub = <fs_rev>-rebzt
                                          is_rev   = <fs_rev>
                                          is_mot   = gs_mot
                                          iv_app   = abap_false ).

      go_log->add_msgs( gt_msg ).

      REFRESH gt_msg.

    ENDLOOP.

  ELSE.

    APPEND INITIAL LINE TO gt_msg ASSIGNING FIELD-SYMBOL(<fs_msg>).
    <fs_msg>-id         = 'ZFI_REVERSAO'.
    <fs_msg>-number     = '007'.
    <fs_msg>-type       = 'E'.

    go_log->add_msgs( gt_msg ).

  ENDIF.



  go_log->save( ).
