***********************************************************************
***                      © 3corações                                ***
***********************************************************************
***                                                                   *
*** DESCRIÇÃO: Agrupamento de faturas GKO                             *
*** AUTOR    : Guido Olivan – META                                    *
*** FUNCIONAL: Raphael – META                                         *
*** DATA     : 02.03.2022                                             *
***********************************************************************
*** HISTÓRICO DAS MODIFICAÇÕES                                        *
***-------------------------------------------------------------------*
*** DATA      | AUTOR                 | DESCRIÇÃO                     *
***-------------------------------------------------------------------*
*** 02.03.22  | Guido Olivan          | Criação do programa           *
***********************************************************************
REPORT zfir_gko_agrup_fatura MESSAGE-ID ztm_if_gko.

TABLES: zttm_gkot001.

* Tipos Locais
*-----------------------------------------------------------------------
TYPES: BEGIN OF ty_s_gko_header,
         acckey     TYPE zttm_gkot001-acckey,
         codstatus  TYPE zttm_gkot001-codstatus,
         num_fatura TYPE zttm_gkot001-num_fatura,
       END OF ty_s_gko_header.

* Variáveis
*-----------------------------------------------------------------------
DATA: gv_eventid                 TYPE tbtcm-eventid,
      gv_eventparm               TYPE tbtcm-eventparm,
      gv_external_program_active TYPE tbtcm-xpgactive,
      gv_jobcount                TYPE tbtcm-jobcount,
      gv_jobname                 TYPE tbtcm-jobname,
      gv_stepcount               TYPE tbtcm-stepcount,
      gv_dummy                   TYPE string,
      ls_invoice                 TYPE xblnr.

* Tabelas Internas e Work Area
*-----------------------------------------------------------------------
DATA: gt_gko_header   TYPE TABLE OF ty_s_gko_header,
      gt_msgs         TYPE bapiret2_tab,
      gt_msgs_invoice TYPE bapiret2_tab,
      lt_return       TYPE bapiret2_tab.

DATA: gs_gko_header      LIKE LINE OF gt_gko_header.

FIELD-SYMBOLS: <fs_msg> TYPE bapiret2.

* Parâmetros de seleção
*-----------------------------------------------------------------------
SELECT-OPTIONS: s_invnum FOR zttm_gkot001-num_fatura.

START-OF-SELECTION.

  CLEAR: gt_msgs.

  IF sy-batch IS INITIAL.
    "Só é possível a execução em background.
    MESSAGE s080 DISPLAY LIKE 'E'.
    RETURN.
  ENDIF.

  "Obtêm os dados do Job
  CALL FUNCTION 'GET_JOB_RUNTIME_INFO'
    IMPORTING
      eventid                 = gv_eventid
      eventparm               = gv_eventparm
      external_program_active = gv_external_program_active
      jobcount                = gv_jobcount
      jobname                 = gv_jobname
      stepcount               = gv_stepcount
    EXCEPTIONS
      no_runtime_info         = 1
      OTHERS                  = 2.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
               WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    RETURN.
  ENDIF.


  "Recupera o nome do programa sendo executado no job
  SELECT SINGLE
         tbtco~jobname,
         tbtco~jobcount,
         tbtcp~stepcount,
         tbtcp~progname
    FROM tbtco
    INNER JOIN tbtcp
      ON  tbtcp~jobname  = tbtco~jobname
      AND tbtcp~jobcount = tbtco~jobcount
    INTO @DATA(ls_job)
    WHERE tbtco~jobname   = @gv_jobname
      AND tbtco~jobcount  = @gv_jobcount
      AND tbtcp~stepcount = @gv_stepcount.

  IF sy-subrc NE 0.
    CLEAR ls_job.
  ENDIF.

  "Verifica se possui outro Job em execução
  SELECT COUNT(*)
    FROM tbtco
    INNER JOIN tbtcp
      ON  tbtcp~jobname  = tbtco~jobname
      AND tbtcp~jobcount = tbtco~jobcount
    WHERE tbtco~jobcount <> gv_jobcount
      AND tbtco~status   = 'R'
      AND tbtcp~progname = ls_job-progname.

  IF sy-subrc IS INITIAL.

    "Já existe um Job em execução.
    MESSAGE e081 INTO gv_dummy.
    APPEND INITIAL LINE TO gt_msgs ASSIGNING <fs_msg>.
    <fs_msg>-id = sy-msgid.
    <fs_msg>-number = sy-msgno.
    <fs_msg>-type = sy-msgty.

  ELSE.

    DATA(lo_agrupamento) = zcltm_agrupar_fatura=>get_instance( ).

    lo_agrupamento->efetivar_agrupamento( EXPORTING ir_xblnr  = s_invnum[]
                                          IMPORTING et_return = lt_return ).

    lo_agrupamento->show_log( it_return = lt_return ).

  ENDIF.
*
*    SELECT
*        t001~acckey
*        t001~codstatus
*        t001~num_fatura
*      FROM zttm_gkot009 AS t009
*      INNER JOIN zttm_gkot001 AS t001
*      ON ( t009~xblnr EQ t001~num_fatura )
*      INTO TABLE gt_gko_header
*      WHERE num_fatura IN s_invnum
*        AND codstatus  = zclfi_gko_incoming_invoice=>gc_codstatus-aguardando_reagrupamento.
*
*
*    IF gt_gko_header IS INITIAL.
*      "-- Nenhum registro válido foi encontrado
*      MESSAGE e000(ztm_gko) WITH TEXT-005 INTO gv_dummy.
*      APPEND INITIAL LINE TO gt_msgs ASSIGNING <fs_msg>.
*      <fs_msg>-id = sy-msgid.
*      <fs_msg>-number = sy-msgno.
*      <fs_msg>-type = sy-msgty.
*      <fs_msg>-message_v1 = sy-msgv1.
*
*    ELSE.
*
*      DATA: lt_faturas TYPE zctgtm_gko009.
*
*      DELETE ADJACENT DUPLICATES FROM gt_gko_header COMPARING num_fatura. "#EC CI_SEL_DEL
*
*      LOOP AT gt_gko_header ASSIGNING FIELD-SYMBOL(<fs_s_header>).
*
*        FREE gt_msgs.
*
*        ls_invoice = <fs_s_header>-num_fatura.
*        DATA(lt_errors) = NEW zclfi_gko_incoming_invoice( )->set_invoice( iv_invoice_number = ls_invoice )->start(  )->get_errors( IMPORTING et_return = lt_return ).
*
*        gt_msgs_invoice =  NEW zcxtm_gko_incoming_invoice( gt_errors = lt_errors )->get_bapi_return( ).
*        gt_msgs = CORRESPONDING #( BASE ( gt_msgs ) gt_msgs_invoice ).
*        gt_msgs = CORRESPONDING #( BASE ( gt_msgs ) lt_return ).
*
**        APPEND <fs_s_header>-num_fatura TO lt_faturas.
**      ENDLOOP.
*
**      DATA(go_gko_incoming_invoice) = NEW zclfi_gko_incoming_invoice( ).
*
**      go_gko_incoming_invoice->set_invoice_multi( it_invoices_number = lt_faturas ).
**      DATA(lo_instace) = go_gko_incoming_invoice->start_multi(  ).
**
**      DATA(go_erros) = go_gko_incoming_invoice->get_errors( ).
*
**      LOOP AT lt_erros ASSIGNING FIELD-SYMBOL(<fs_erro>).
**
***        APPEND INITIAL LINE TO gt_msgs ASSIGNING <fs_msg>.
***        <fs_msg>-id = <fs_erro>- .
***        <fs_msg>-number = sy-msgno.
***        <fs_msg>-type = sy-msgty.
***        <fs_msg>-message_v1 = sy-msgv1.
*
*      ENDLOOP.
*
*      DELETE ADJACENT DUPLICATES FROM gt_msgs COMPARING ALL FIELDS.
*
*    ENDIF.
*
*  ENDIF.
*
**  IF gt_msgs IS NOT INITIAL.
**
**    DATA(go_log) = NEW zclca_save_log( iv_object = 'ZTM' ).
**    go_log->create_log( iv_subobject = 'ZGKO' ).
**    go_log->add_msgs( it_msg = gt_msgs ).
**    go_log->save( ).
**    COMMIT WORK AND WAIT.
**
**  ENDIF.
