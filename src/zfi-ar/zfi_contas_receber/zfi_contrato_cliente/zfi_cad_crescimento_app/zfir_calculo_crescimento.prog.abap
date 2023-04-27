*&---------------------------------------------------------------------*
*& Report ZFIR_REVERSAO
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zfir_calculo_crescimento.

DATA: gv_contrato TYPE ze_num_contrato.
DATA: gv_aditivo  TYPE ze_num_aditivo.

DATA: gt_msg TYPE bapiret2_tab.

CONSTANTS: gc_tcode TYPE sy-tcode VALUE 'ZFI_CALCRESC',
           gc_sub   TYPE balsubobj VALUE 'LOG_JOB'.

SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-b01.

  SELECT-OPTIONS: s_cont     FOR gv_contrato,
                  s_adit     FOR gv_aditivo.

SELECTION-SCREEN END OF BLOCK b1.

START-OF-SELECTION.

  SELECT a~contrato,
         a~aditivo,
         b~bukrs
    FROM ztfi_cad_cresci AS a
    INNER JOIN ztfi_contrato AS b
    ON  b~doc_uuid_h = a~doc_uuid_h
    AND b~contrato   = a~contrato
    AND b~aditivo    = a~aditivo
    INTO TABLE @DATA(gt_cresc).



end-of-selection.

  DATA(go_cresc) = NEW zclfi_contrato_calc_cresciment( ).

  DATA(go_log) = NEW zclca_save_log( gc_tcode ).

  go_log->create_log( gc_sub ).

  IF gt_cresc IS NOT INITIAL.



    LOOP AT gt_cresc ASSIGNING FIELD-SYMBOL(<fs_cresc>).

*      DATA(ls_import) = VALUE zsfi_key_crescimnt( contrato = <fs_cresc>-contrato
*                                                  aditivo  = <fs_cresc>-aditivo
*                                                  bukrs    = <fs_cresc>-bukrs ).

*      gt_msg = go_cresc->execute( EXPORTING is_import = ls_import ).

      go_log->add_msgs( gt_msg ).

      REFRESH gt_msg.

    ENDLOOP.

  ELSE.

    APPEND INITIAL LINE TO gt_msg ASSIGNING FIELD-SYMBOL(<fs_msg>).
    <fs_msg>-id         = 'ZFI_CONTRATO_CLIENTE'.
    <fs_msg>-number     = '036'.
    <fs_msg>-type       = 'E'.

    go_log->add_msgs( gt_msg ).

  ENDIF.



  go_log->save( ).
