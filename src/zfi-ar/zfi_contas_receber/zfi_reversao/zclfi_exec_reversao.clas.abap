"! <p class="shorttext synchronized">Classe para eventos de reversão</p>
"! Autor: Anderson Macedo
"! Data: 11/10/2021
CLASS zclfi_exec_reversao DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    TYPES:
      ty_t_reversao TYPE TABLE OF zi_fi_reversao_app WITH DEFAULT KEY .

    DATA gt_return TYPE bapiret2_tab .
    DATA gv_app TYPE abap_bool .

    METHODS constructor
      IMPORTING
        !it_reversao TYPE ty_t_reversao OPTIONAL .
    "! Chama o processo principal
    "! @parameter iv_doc         | Documento
    "! @parameter iv_emp         | Empresa
    "! @parameter iv_year        | Ano
    "! @parameter iv_tpsub       | Tipo Doc Subsequente
    "! @parameter is_mot         | Motivo
    "! @parameter rt_mensagens   | Tabela de Mensagens
    METHODS execute
      IMPORTING
        !iv_doc             TYPE belnr_d
        !iv_emp             TYPE bukrs
        !iv_year            TYPE gjahr
        !iv_tpsub           TYPE rebzt
        !is_mot             TYPE zi_fi_reversao_popup
        !is_rev             TYPE zi_fi_reversao OPTIONAL
        !iv_app             TYPE abap_bool
      RETURNING
        VALUE(rt_mensagens) TYPE bapiret2_tab .
    METHODS task_finish
      IMPORTING
        !p_task TYPE clike .
  PROTECTED SECTION.
  PRIVATE SECTION.

    DATA gt_reversao TYPE ty_t_reversao .

    "! Valida Tipo Doc Subsequente
    "! @parameter iv_doc         | Documento
    "! @parameter iv_emp         | Empresa
    "! @parameter iv_year        | Ano
    "! @parameter iv_tpsub       | Tipo Doc Subsequente
    "! @parameter ct_mensagens   | Tabela de Mensagens
    "! @parameter rv_result      | Retorno de Validação
    METHODS tpdocsub_is_not_valid
      IMPORTING
        !iv_doc          TYPE belnr_d
        !iv_emp          TYPE bukrs
        !iv_year         TYPE gjahr
        !iv_tpsub        TYPE rebzt
      CHANGING
        !ct_mensagens    TYPE bapiret2_tab
      RETURNING
        VALUE(rv_result) TYPE abap_bool .
    "! Valida documento
    "! @parameter is_mot         | Motivo
    "! @parameter ct_mensagens   | Tabela de Mensagens
    "! @parameter rv_result       | Retorno de Validação
    METHODS reverse_param_is_not_valid
      IMPORTING
        !is_mot          TYPE zi_fi_reversao_popup
      CHANGING
        !ct_mensagens    TYPE bapiret2_tab
      RETURNING
        VALUE(rv_result) TYPE abap_bool .
    "! Gera o documento
    "! @parameter iv_doc         | Documento
    "! @parameter iv_emp         | Empresa
    "! @parameter iv_year        | Ano
    "! @parameter iv_tpsub       | Tipo Doc Subsequente
    "! @parameter is_mot         | Motivo
    "! @parameter ct_mensagens   | Tabela Mensagens
    METHODS process_reverse
      IMPORTING
        iv_doc       TYPE belnr_d
        iv_emp       TYPE bukrs
        iv_year      TYPE gjahr
        iv_tpsub     TYPE rebzt
        iv_orig      TYPE belnr_d
        is_mot       TYPE zi_fi_reversao_popup
      CHANGING
        ct_mensagens TYPE bapiret2_tab .
    METHODS validate_reason
      IMPORTING
        is_mot TYPE zi_fi_reversao_popup
        is_rev TYPE zi_fi_reversao_app
      CHANGING
        cs_mot TYPE zi_fi_reversao_popup.
    METHODS process_by_app
      IMPORTING
        is_mot              TYPE zi_fi_reversao_popup
        iv_doc              TYPE belnr_d
        iv_emp              TYPE bukrs
        iv_year             TYPE gjahr
        iv_tpsub            TYPE rebzt
      RETURNING
        VALUE(rt_mensagens) TYPE bapiret2_tab.
    METHODS process_by_job
      IMPORTING
        is_rev       TYPE zi_fi_reversao
        is_mot       TYPE zi_fi_reversao_popup
        iv_tpsub     TYPE rebzt
        iv_year      TYPE gjahr
        iv_emp       TYPE bukrs
      CHANGING
        ct_mensagens TYPE bapiret2_tab.

ENDCLASS.



CLASS zclfi_exec_reversao IMPLEMENTATION.


  METHOD execute.

    gv_app = iv_app.

    IF gt_reversao IS NOT INITIAL.

      rt_mensagens = process_by_app( is_mot   = is_mot
                                     iv_doc   = iv_doc
                                     iv_emp   = iv_emp
                                     iv_year  = iv_year
                                     iv_tpsub = iv_tpsub ).

    ELSE.

      process_by_job( EXPORTING
                        is_rev   = is_rev
                        is_mot   = is_mot
                        iv_tpsub = iv_tpsub
                        iv_year  = iv_year
                        iv_emp   = iv_emp
                      CHANGING
                        ct_mensagens = rt_mensagens ).

    ENDIF.

  ENDMETHOD.


  METHOD process_by_job.

    DATA ls_mot TYPE zi_fi_reversao_popup.
    DATA ls_rev TYPE zi_fi_reversao_app.

    ls_rev-datacomp = is_rev-augdt.

    validate_reason( EXPORTING
                       is_mot = is_mot
                       is_rev = ls_rev
                     CHANGING
                       cs_mot = ls_mot ).

    process_reverse( EXPORTING iv_doc       = is_rev-augbl
                               iv_emp       = iv_emp
                               iv_year      = iv_year
                               iv_tpsub     = iv_tpsub
                               iv_orig      = is_rev-belnr
                               is_mot       = ls_mot
                     CHANGING  ct_mensagens = ct_mensagens ).

  ENDMETHOD.


  METHOD process_by_app.

    DATA ls_mot TYPE zi_fi_reversao_popup.

    ls_mot = is_mot.

    READ TABLE gt_reversao INTO DATA(ls_rev) WITH KEY documento  = iv_doc
                                                      empresa    = iv_emp
                                                      exercicio  = iv_year
                                                      tpdocsub   = iv_tpsub
                                             BINARY SEARCH.

    IF sy-subrc = 0.


      validate_reason( EXPORTING
                         is_mot = is_mot
                         is_rev = ls_rev
                       CHANGING
                         cs_mot = ls_mot ).

      process_reverse( EXPORTING iv_doc       = ls_rev-doccomp
                                 iv_emp       = iv_emp
                                 iv_year      = iv_year
                                 iv_tpsub     = iv_tpsub
                                 iv_orig      = ls_rev-Documento
                                 is_mot       = ls_mot
                       CHANGING  ct_mensagens = rt_mensagens ).

    ENDIF.

  ENDMETHOD.


  METHOD validate_reason.

    IF is_mot-motestorno IS INITIAL.

      IF is_rev-datacomp+4(2) EQ sy-datum+4(2).
        cs_mot-motestorno = '01'.
      ELSE.
        cs_mot-motestorno = '02'.
      ENDIF.

      cs_mot-datalancest = is_rev-datacomp.

    ENDIF.

    IF is_mot-motestorno EQ '01'.

      cs_mot-datalancest = is_rev-datacomp.

    ENDIF.

  ENDMETHOD.


  METHOD tpdocsub_is_not_valid.

    IF iv_tpsub NE 'G'.

      APPEND INITIAL LINE TO ct_mensagens ASSIGNING FIELD-SYMBOL(<fs_msg>).
      <fs_msg>-id     = 'ZFI_REVERSAO'.
      <fs_msg>-number = '001'.
      <fs_msg>-type   = 'E'.
      <fs_msg>-message_v1 = iv_doc.
      <fs_msg>-message_v2 = iv_emp.
      <fs_msg>-message_v3 = iv_year.

      rv_result = abap_true.

    ENDIF.

  ENDMETHOD.


  METHOD reverse_param_is_not_valid.

    IF is_mot-motestorno EQ '01' AND is_mot-datalancest+4(2) NE sy-datum+4(2).

      APPEND INITIAL LINE TO ct_mensagens ASSIGNING FIELD-SYMBOL(<fs_msg>).
      <fs_msg>-id     = 'ZFI_REVERSAO'.
      <fs_msg>-number = '002'.
      <fs_msg>-type   = 'E'.

      rv_result = abap_true.

    ENDIF.

  ENDMETHOD.


  METHOD process_reverse.

    CLEAR gt_return.

    IF gv_app IS NOT INITIAL.

      CALL FUNCTION 'ZFMFI_REVERSE_CLEARING'
        STARTING NEW TASK 'BACKGROUND' CALLING task_finish ON END OF TASK
        EXPORTING
          iv_emp      = iv_emp
          iv_doc      = iv_doc
          iv_year     = iv_year
          iv_orig     = iv_orig
          is_mot      = is_mot
        TABLES
          t_mensagens = gt_return.

      WAIT FOR ASYNCHRONOUS TASKS UNTIL gt_return IS NOT INITIAL.

    ELSE.

      CALL FUNCTION 'ZFMFI_REVERSE_CLEARING'
        EXPORTING
          iv_emp      = iv_emp
          iv_doc      = iv_doc
          iv_year     = iv_year
          iv_orig     = iv_orig
          is_mot      = is_mot
        TABLES
          t_mensagens = gt_return.

    ENDIF.

    APPEND LINES OF gt_return TO ct_mensagens.

  ENDMETHOD.


  METHOD constructor.

    gt_reversao = it_reversao.

  ENDMETHOD.


  METHOD task_finish.

    RECEIVE RESULTS FROM FUNCTION 'ZFMFI_REVERSE_CLEARING'
      TABLES
        t_mensagens = gt_return.

    RETURN.

  ENDMETHOD.
ENDCLASS.
