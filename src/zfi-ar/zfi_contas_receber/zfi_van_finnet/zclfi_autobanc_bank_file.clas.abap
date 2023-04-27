"!<p><h2>Automat. Bancária - Importa Arquivos pela FF.5</h2></p>
"!<p><strong>Autor:</strong> Anderson Miazato</p>
"!<p><strong>Data:</strong> 18 de out de 2021</p>
CLASS zclfi_autobanc_bank_file DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    CLASS-METHODS:
      "! Gera instância desta classe
      "! @parameter io_log    | Log na SLG1
      "! @parameter ro_result | Instância gerada
      create_instance
        IMPORTING
          io_log           TYPE REF TO zclfi_autobanc_import_log
        RETURNING
          VALUE(ro_result) TYPE REF TO zclfi_autobanc_bank_file,

      "! Seleciona dados de log de importação
      select_data_log.

    METHODS:
      "! Inicializa o objeto
      "! @parameter io_log    | Log na SLG1
      constructor
        IMPORTING
          io_log TYPE REF TO zclfi_autobanc_import_log,

      "! Processa arquivo pela transação FF.5
      "! @parameter is_directory        | Estrutura do Diretório
      "! @parameter iv_file_name        | Nome do arquivo
      "! @parameter rv_chave            | Chave do arquivo
      "! @raising zcxfi_autobanc_import | Erro ao processar arquivo na FF.5
      process
        IMPORTING
          is_directory    TYPE zi_fi_autobanc_diretorios
          iv_file_name    TYPE eps2filnam
        RETURNING
          VALUE(rv_chave) TYPE kukey_eb
        RAISING
          zcxfi_autobanc_import,

      "! Valida arquivo para importação pela FF.5
      "! @parameter iv_file_name        | Nome do arquivo
      "! @raising zcxfi_autobanc_import | Erros do arquivo
      check_file
        IMPORTING
          iv_file_name TYPE eps2filnam
        RAISING
          zcxfi_autobanc_import.

    METHODS:
      "! Executa Batch input do arquivo pela FF.5
      execute_batch.

  PROTECTED SECTION.
  PRIVATE SECTION.

    DATA:
      go_log TYPE REF TO zclfi_autobanc_import_log.

    DATA:
      "! Batch input
      gt_bdcdata TYPE TABLE OF bdcdata.

    CLASS-DATA:
      "! Log de importação de arquivos
      gt_log_import TYPE SORTED TABLE OF zi_fi_autobanc_log WITH NON-UNIQUE KEY Nome.

    METHODS:

      "! Armazena nova mensagem
      "! @parameter is_message          | Mensagem
      "! @parameter is_log_context      | Contexto do log
      add_log_msg
        IMPORTING
          is_message     TYPE bapiret2
          is_log_context TYPE zsfi_log_van_finnet OPTIONAL,

      "! Batch input por tela da FF.5
      "! @parameter iv_program | Programa
      "! @parameter iv_dynpro  | Nº Tela
      bdc_dynpro
        IMPORTING
          iv_program TYPE bdcdata-program
          iv_dynpro  TYPE bdcdata-dynpro,

      "! Batch input por campo da FF.5
      "! @parameter iv_fnam | Nome do campo
      "! @parameter iv_fval | Valor do campo
      bdc_field
        IMPORTING
          iv_fnam TYPE bdcdata-fnam
          iv_fval TYPE bdcdata-fval.

ENDCLASS.



CLASS ZCLFI_AUTOBANC_BANK_FILE IMPLEMENTATION.


  METHOD bdc_dynpro.

    APPEND INITIAL LINE TO gt_bdcdata ASSIGNING FIELD-SYMBOL(<fs_dynpro>).
    <fs_dynpro>-program  = iv_program.
    <fs_dynpro>-dynpro   = iv_dynpro.
    <fs_dynpro>-dynbegin = abap_True.

  ENDMETHOD.


  METHOD bdc_field.

    APPEND INITIAL LINE TO gt_bdcdata ASSIGNING FIELD-SYMBOL(<fs_field>).
    <fs_field>-fnam = iv_fnam.
    <fs_field>-fval = iv_fval.

  ENDMETHOD.


  METHOD check_file.

    IF line_exists( gt_log_import[ nome = iv_file_name ] ).

      CONVERT TIME STAMP gt_log_import[ nome = iv_file_name ]-CreatedAt
        TIME ZONE sy-zonlo
        INTO DATE DATA(lv_procdate).

      lv_procdate = gt_log_import[ nome = iv_file_name ]-CreatedAt.

      "Erro ao importar o arquivo & na FF.5
      RAISE EXCEPTION TYPE zcxfi_autobanc_import
        EXPORTING
          iv_textid = zcxfi_autobanc_import=>gc_file_exist
          iv_type   = if_xo_const_message=>error
          iv_msgv1  = CONV #( iv_file_name )
          iv_msgv2  = CONV #( lv_procdate ).
    ENDIF.

  ENDMETHOD.


  METHOD create_instance.

    ro_result = NEW zclfi_autobanc_bank_file( io_log ).

  ENDMETHOD.


  METHOD execute_batch.

    CONSTANTS:
      lc_progid     TYPE apqi-progid VALUE 'RFEBBU00',
      lc_modus_n(1) TYPE c VALUE 'N'.

    DATA:
      lv_jobcount TYPE tbtcjob-jobcount,
      lv_jobname  TYPE tbtcjob-jobname.

    " Selecionar nome da pasta - SM35
    DATA(lv_datai) = sy-datum - 1.
    DATA(lv_dataf) = sy-datum.

    SELECT
        destsys,
        destapp,
        datatyp,
        mandant,
        groupid,
        progid,
        formid,
        qattrib,
        qid
      FROM apqi
      INTO TABLE @DATA(lt_apqi)
      WHERE mandant = @sy-mandt
        AND progid  = @lc_progid
        AND qstate  = @abap_false
        AND userid  = @sy-uname
        AND credate BETWEEN @lv_datai AND @lv_dataf.

    " Processar pasta automaticamente - SM35
    IF sy-subrc IS INITIAL.

      LOOP AT lt_apqi ASSIGNING FIELD-SYMBOL(<fs_apqi>).

        lv_jobname = <fs_apqi>-groupid.

        CALL FUNCTION 'JOB_OPEN'
          EXPORTING
            jobname          = lv_jobname
          IMPORTING
            jobcount         = lv_jobcount
          EXCEPTIONS
            cant_create_job  = 1
            invalid_job_data = 2
            jobname_missing  = 3
            OTHERS           = 99.
*
        IF sy-subrc EQ 0.              "Job_open OK
*
          SUBMIT rsbdcbtc_sub WITH queue_id  EQ <fs_apqi>-qid
                              WITH modus     EQ lc_modus_n
                              WITH logall    EQ abap_false
                              VIA JOB lv_jobname NUMBER lv_jobcount AND RETURN.
*
          IF sy-subrc EQ 0.            "submit OK

            CALL FUNCTION 'JOB_CLOSE'
              EXPORTING
                jobcount             = lv_jobcount
                jobname              = lv_jobname
                strtimmed            = abap_true
              EXCEPTIONS
                cant_start_immediate = 1
                invalid_startdate    = 2
                jobname_missing      = 3
                job_close_failed     = 4
                job_nosteps          = 5
                job_notex            = 6
                lock_failed          = 7
                invalid_target       = 8
                OTHERS               = 99.

            IF sy-subrc NE 0.
              RETURN.
            ENDIF.

          ENDIF.

        ENDIF.

      ENDLOOP.

    ENDIF.

  ENDMETHOD.


  METHOD process.

    CONSTANTS:
      lc_numeric_string   TYPE string VALUE '0123456789',
      lc_import(6)        TYPE c VALUE 'IMPORT',
      lc_separador(1)     TYPE c VALUE '_',
      lc_first(1)         TYPE c VALUE '1',
      lc_modus_n(1)       TYPE c VALUE 'N',
      lc_update(1)        TYPE c VALUE 'S',
      lc_msgid_fb         TYPE sy-msgid VALUE 'FB',
      lc_msgno_773        TYPE sy-msgno VALUE '773',
      lc_separador_dir(1) TYPE c VALUE '/'.

    CONSTANTS:
      BEGIN OF lc_format_bancos,
        bradesco(1) TYPE c VALUE '1',
        outros(1)   TYPE c VALUE 'B',
      END OF lc_format_bancos,

      BEGIN OF lc_tipo_arquivo,
        cobranca(3) TYPE c VALUE 'COB',
      END OF lc_tipo_arquivo,

      BEGIN OF lc_finish,
        finalizado TYPE c VALUE 'F',
        final_erro TYPE c VALUE 'A',
      END OF lc_finish.

    TYPES: BEGIN OF ty_text,
             data TYPE c LENGTH 2000,
           END OF ty_text.

    DATA: lt_text  TYPE STANDARD TABLE OF ty_text,
          lt_mem   TYPE STANDARD TABLE OF abaplist,
          lr_xref3 TYPE RANGE OF xref3,
          lv_spool TYPE btclistid,
          lv_mode.


    DATA: lv_msg(500),
          lv_path(128)    TYPE c,
          lv_jobcount     TYPE tbtcjob-jobcount,
          lv_jobname      TYPE tbtcjob-jobname,
          lv_cont         TYPE numc4,
          lv_finish       TYPE tbtcjob-status,
          lv_tempo_max(4) TYPE n,
          lv_tam          TYPE i,
          lv_dummy        TYPE c,
          lv_banco        TYPE c LENGTH 3.

    DATA: lt_job_log TYPE STANDARD TABLE OF tbtc5,
          ls_job_log TYPE tbtc5.

    DATA: lv_einlesen TYPE rfpdo1-febeinles VALUE 'X',  " Importar dados
          lv_format   TYPE rfpdo1-febformat,            " Formato
          lv_x_format TYPE febformat_long,              " XML ou formato específ.banco
          lv_auszfile TYPE rfpdo1-febauszf,             " File Dump
          lv_xcall    TYPE febpdo-xcall     VALUE 'X',  " Lançar imediatamente
          lv_binpt    TYPE febpdo-xbinpt    VALUE 'X',  " Criar pastas batch-input
          lv_pcupload TYPE rfpdo1-febpcupld VALUE '',  " Estação de trabalho-upload
          lv_batch    TYPE rfpdo2-febbatch  VALUE 'X',  " Execução em batch-job
          lv_p_koausz TYPE rfpdo1-febpausz  VALUE 'X',  " Imprimir extrato de conta
          lv_p_bupro  TYPE rfpdo2-febbupro  VALUE 'X',  " Imprimir log de lançamento
          lv_p_statik TYPE rfpdo2-febstat   VALUE 'X',  " Imprimir estatística
          lv_pa_lsepa TYPE febpdo-lsepa     VALUE 'X'.  " Separação de lista

    "Busca o número do banco no nome do arquivo.
    CLEAR: lv_banco.

    IF iv_file_name+3(1) CO lc_numeric_string AND iv_file_name+3(3) CO lc_numeric_string.
      lv_banco = iv_file_name+3(3).
    ELSE.

      IF iv_file_name+4(1) CO lc_numeric_string AND iv_file_name+4(3) CO lc_numeric_string.
        lv_banco = iv_file_name+4(3).
      ELSE.

        DATA(ls_msg) = VALUE bapiret2(
              id          = zcxfi_autobanc_import=>gc_erro_name_file-msgid
              type        = if_xo_const_message=>error
              number      = zcxfi_autobanc_import=>gc_erro_name_file-msgno
              message_v1  = CONV #( iv_file_name )
          ).

        me->add_log_msg(
          EXPORTING
            is_message = ls_msg
        ).

        "Erro ao iniciar o JOB de processamento do arquivo &
        RAISE EXCEPTION TYPE zcxfi_autobanc_import
          EXPORTING
            iv_textid = zcxfi_autobanc_import=>gc_erro_name_file
            iv_msgv1  = CONV #( iv_file_name ).
      ENDIF.

    ENDIF.

    "Verifica o tipo de arquivo para gerar ou não pasta Batch-Input
    CASE iv_file_name(3).

      WHEN lc_tipo_arquivo-cobranca.

        "Verifica o tipo de formato do arquivo.
        CASE iv_file_name+3(3).

          WHEN 237.
            lv_format = lc_format_bancos-bradesco.

          WHEN OTHERS.
            lv_format = lc_format_bancos-outros.

        ENDCASE.

        CLEAR: lv_xcall.

      WHEN OTHERS.

        lv_format = lc_format_bancos-outros.
        CLEAR: lv_binpt.

    ENDCASE.

    "Determinando caminho do arquivo para executar a FF.5
    lv_auszfile = |{ is_directory-diretorio }{ lc_separador_dir }{ iv_file_name }|.

    "Definindo nome do JOB
    CONCATENATE lc_import iv_file_name INTO lv_jobname SEPARATED BY lc_separador.

    "Iniciando JOB de execução
    CALL FUNCTION 'JOB_OPEN'
      EXPORTING
        jobname          = lv_jobname
      IMPORTING
        jobcount         = lv_jobcount
      EXCEPTIONS
        cant_create_job  = 1
        invalid_job_data = 2
        jobname_missing  = 3
        OTHERS           = 4.

    IF sy-subrc IS NOT INITIAL.

      FREE ls_msg.
      ls_msg = VALUE bapiret2(
            id          = zcxfi_autobanc_import=>gc_job_start_erro-msgid
            type        = if_xo_const_message=>error
            number      = zcxfi_autobanc_import=>gc_job_start_erro-msgno
            message_v1  = CONV #( iv_file_name )
        ).

      me->add_log_msg(
        EXPORTING
          is_message = ls_msg
      ).

      "Erro ao iniciar o JOB de processamento do arquivo &
      RAISE EXCEPTION TYPE zcxfi_autobanc_import
        EXPORTING
          iv_textid = zcxfi_autobanc_import=>gc_job_start_erro
          iv_msgv1  = CONV #( iv_file_name ).
    ENDIF.

    "Executando a FF.5
    SUBMIT rfebka00 WITH  einlesen = lv_einlesen
                    WITH  format   = lv_format
                    WITH  x_format = lv_x_format
                    WITH  auszfile = lv_auszfile
                    WITH  pa_xcall = lv_xcall
                    WITH  pa_xbdc  = lv_binpt
                    WITH  pcupload = lv_pcupload
                    WITH  batch    = lv_batch
                    WITH  p_koausz = lv_p_koausz
                    WITH  p_bupro  = lv_p_bupro
                    WITH  p_statik = lv_p_statik
                    WITH  pa_lsepa = lv_pa_lsepa
                    VIA JOB lv_jobname NUMBER lv_jobcount AND RETURN. "#EC CI_SUBMIT

    CALL FUNCTION 'JOB_CLOSE'
      EXPORTING
        jobcount             = lv_jobcount
        jobname              = lv_jobname
        strtimmed            = abap_true
      EXCEPTIONS
        cant_start_immediate = 1
        invalid_startdate    = 2
        jobname_missing      = 3
        job_close_failed     = 4
        job_nosteps          = 5
        job_notex            = 6
        lock_failed          = 7
        invalid_target       = 8
        OTHERS               = 9.

    IF sy-subrc IS NOT INITIAL.

      FREE ls_msg.
      ls_msg = VALUE bapiret2(
            id          = zcxfi_autobanc_import=>gc_job_start_erro-msgid
            type        = if_xo_const_message=>error
            number      = zcxfi_autobanc_import=>gc_job_start_erro-msgno
            message_v1  = CONV #( iv_file_name )
        ).

      me->add_log_msg(
        EXPORTING
          is_message = ls_msg
      ).

      "Erro ao iniciar o JOB de processamento do arquivo &
      RAISE EXCEPTION TYPE zcxfi_autobanc_import
        EXPORTING
          iv_textid = zcxfi_autobanc_import=>gc_job_start_erro
          iv_type   = if_xo_const_message=>error
          iv_msgv1  = CONV #( iv_file_name ).
    ENDIF.



    "Verifica a execução até que o mesmo seja concluído com sucesso ou erro
    WHILE lv_finish <> lc_finish-finalizado AND "Diferente de Finalizado
          lv_finish <> lc_finish-final_erro.    "Diferente de Finalizado com erro

      WAIT UP TO 1 SECONDS.

      CLEAR lv_finish.

      CALL FUNCTION 'BP_JOB_STATUS_GET'
        EXPORTING
          jobcount                   = lv_jobcount
          jobname                    = lv_jobname
        IMPORTING
          status                     = lv_finish
        EXCEPTIONS
          job_doesnt_exist           = 1
          unknown_error              = 2
          parent_child_inconsistency = 3
          OTHERS                     = 4.

      IF sy-subrc <> 0.
        lv_dummy = abap_true.
      ENDIF.

    ENDWHILE.

    "Aguarda um segundo para atualizar as mensagens dos jobs.
    WAIT UP TO 1 SECONDS.

    "Verificando se deu sucesso
    CALL FUNCTION 'BP_JOBLOG_READ'
      EXPORTING
        jobcount              = lv_jobcount
        jobname               = lv_jobname
      TABLES
        joblogtbl             = lt_job_log
      EXCEPTIONS
        cant_read_joblog      = 1
        jobcount_missing      = 2
        joblog_does_not_exist = 3
        joblog_is_empty       = 4
        joblog_name_missing   = 5
        jobname_missing       = 6
        job_does_not_exist    = 7
        OTHERS                = 8.

    IF sy-subrc IS NOT INITIAL.

      FREE ls_msg.
      ls_msg = VALUE bapiret2(
            id          = sy-msgid
            type        = if_xo_const_message=>error
            number      = sy-msgno
            message_v1  = sy-msgv1
            message_v2  = sy-msgv2
            message_v3  = sy-msgv3
            message_v4  = sy-msgv4
        ).

      me->add_log_msg(
        EXPORTING
          is_message = ls_msg
      ).

      FREE ls_msg.
      ls_msg = VALUE bapiret2(
            id          = zcxfi_autobanc_import=>gc_ff5_import_erro-msgid
            type        = if_xo_const_message=>error
            number      = zcxfi_autobanc_import=>gc_ff5_import_erro-msgno
            message_v1  = CONV #( iv_file_name )
        ).

      me->add_log_msg(
        EXPORTING
          is_message = ls_msg
      ).

      "Erro ao importar o arquivo & na FF.5
      RAISE EXCEPTION TYPE zcxfi_autobanc_import
        EXPORTING
          iv_textid = zcxfi_autobanc_import=>gc_ff5_import_erro
          iv_type   = if_xo_const_message=>error
          iv_msgv1  = CONV #( iv_file_name ).
    ENDIF.

    DESCRIBE TABLE lt_job_log LINES lv_tam.

    WHILE lv_tam < 3.

      CLEAR: lt_job_log, lv_tam.

      WAIT UP TO 1 SECONDS.

      "Verificando se deu sucesso
      CALL FUNCTION 'BP_JOBLOG_READ'
        EXPORTING
          jobcount              = lv_jobcount
          jobname               = lv_jobname
        TABLES
          joblogtbl             = lt_job_log
        EXCEPTIONS
          cant_read_joblog      = 1
          jobcount_missing      = 2
          joblog_does_not_exist = 3
          joblog_is_empty       = 4
          joblog_name_missing   = 5
          jobname_missing       = 6
          job_does_not_exist    = 7
          OTHERS                = 8.

      IF sy-subrc NE 0.
        lv_dummy = abap_true.
      ENDIF.

      DESCRIBE TABLE lt_job_log LINES lv_tam.

    ENDWHILE.

    IF iv_file_name(3) EQ lc_tipo_arquivo-cobranca.

      FREE: lv_spool, lt_mem, lt_text.

      SELECT SINGLE listident
        FROM tbtcp
        INTO lv_spool
        WHERE jobname  = lv_jobname
          AND jobcount = lv_jobcount.

      IF lv_spool IS NOT INITIAL.

        SUBMIT rspolst2 EXPORTING LIST TO MEMORY AND RETURN
          WITH rqident = lv_spool
          WITH first = lc_first.

        CALL FUNCTION 'LIST_FROM_MEMORY'
          TABLES
            listobject = lt_mem.

        IF lt_mem[] IS NOT INITIAL.

          CALL FUNCTION 'LIST_TO_ASCI'
            EXPORTING
              list_index = -1
            TABLES
              listasci   = lt_text
              listobject = lt_mem.

          LOOP AT lt_text ASSIGNING FIELD-SYMBOL(<fs_text>).

            FIND 'Chave breve:'(001) IN <fs_text> MATCH OFFSET DATA(lv_offset).

            IF sy-subrc EQ 0.

              ADD 12 TO lv_offset.
              rv_chave = <fs_text>+lv_offset.
              CONDENSE rv_chave.
              EXIT.

            ENDIF.

          ENDLOOP.

          IF rv_chave IS NOT INITIAL.

            SELECT
              StatementShortID,
              StatementItem,
              FiscalYear,
              PaymentExternalTransacType,
              DocumentReferenceID,
              DaybookEntry,
              ItemProcessingType,
              PaymentReference,
              AcctItem,
              Application,
              BankStatementId,
              PayeeKeys,
              CompanyCode,
              \_PartidasAbertoCliente-bukrs,
              \_PartidasAbertoCliente-kunnr,
              \_PartidasAbertoCliente-augdt,
              \_PartidasAbertoCliente-gjahr,
              \_PartidasAbertoCliente-belnr,
              \_PartidasAbertoCliente-buzei,
              \_PartidasAbertoCliente-waers,
              \_PartidasAbertoCliente-zterm,
              \_PartidasAbertoCliente-zlsch,
              \_PartidasAbertoCliente-zlspr,
              \_PartidasAbertoCliente-anfbn,
              \_PartidasAbertoCliente-anfbj,
              \_PartidasAbertoCliente-anfbu,
              \_PartidasAbertoCliente-manst,
              \_PartidasAbertoCliente-dtws1,
              \_PartidasAbertoCliente-dtws2,
              \_PartidasAbertoCliente-dtws3
              FROM zc_fi_autobanc_bankfile
                  WHERE StatementShortID EQ @rv_chave
              INTO TABLE @DATA(lt_partidas).

            DATA(lv_data) = sy-datum+6(2) && sy-datum+4(2) && sy-datum(4).

*            LOOP AT lt_bsid ASSIGNING FIELD-SYMBOL(<fs_bsid>).
            LOOP AT lt_partidas ASSIGNING FIELD-SYMBOL(<fs_partidas>).

              "Inicio do preenchimento do SHDB para a Transação FB1D
              FREE gt_bdcdata.
              bdc_dynpro( iv_program = 'SAPMF05A' iv_dynpro  = '0131' ).
              bdc_field( iv_fnam = 'BDC_CURSOR'      iv_fval = 'RF05A-XPOS1(04)' ).
              bdc_field( iv_fnam = 'BDC_OKCODE'      iv_fval = '/00' ).
              bdc_field( iv_fnam = 'RF05A-AGKON'     iv_fval = CONV #( <fs_partidas>-kunnr ) ).
              bdc_field( iv_fnam = 'BKPF-BUDAT'      iv_fval = CONV #( lv_data ) ).
              bdc_field( iv_fnam = 'BKPF-MONAT'      iv_fval = CONV #( lv_data+2(2) ) ).
              bdc_field( iv_fnam = 'BKPF-BUKRS'      iv_fval = CONV #( <fs_partidas>-anfbu ) ).
              bdc_field( iv_fnam = 'BKPF-WAERS'      iv_fval = CONV #( <fs_partidas>-waers ) ).
              bdc_field( iv_fnam = 'RF05A-AGUMS'     iv_fval = 'R' ).
              bdc_field( iv_fnam = 'RF05A-XNOPS'     iv_fval = ' ' ).
              bdc_field( iv_fnam = 'RF05A-XPOS1(01)' iv_fval = ' ' ).
              bdc_field( iv_fnam = 'RF05A-XPOS1(04)' iv_fval = 'X' ).

              bdc_dynpro( iv_program = 'SAPMF05A' iv_dynpro  = '0731' ).
              bdc_field( iv_fnam = 'BDC_CURSOR'      iv_fval = 'RF05A-SEL01(01)' ).
              bdc_field( iv_fnam = 'BDC_OKCODE'      iv_fval = '=PA' ).
              bdc_field( iv_fnam = 'RF05A-SEL01(01)' iv_fval = CONV #( <fs_partidas>-anfbn ) ).

              bdc_dynpro( iv_program = 'SAPDF05X' iv_dynpro  = '3100' ).
              bdc_field( iv_fnam = 'BDC_OKCODE'  iv_fval = '=BU' ).
              bdc_field( iv_fnam = 'BDC_SUBSCR'  iv_fval = 'SAPDF05X' ).
              bdc_field( iv_fnam = 'BDC_CURSOR'  iv_fval = 'RF05A-ABPOS' ).
              bdc_field( iv_fnam = 'RF05A-ABPOS' iv_fval = '1' ).
              "Fim do preenchimento do SHDB para a Transação FB1D

              "Chamada da Função FB1D
              lv_mode = lc_modus_n.
              CALL TRANSACTION 'FB1D' USING  gt_bdcdata
                                      MODE   lv_mode
                                      UPDATE lc_update.
              FREE gt_bdcdata.

              "Inicio do preenchimento do SHDB para a Transação FB09
              bdc_dynpro( iv_program = 'SAPMF05L' iv_dynpro  = '0102' ).
              bdc_field( iv_fnam = 'BDC_CURSOR' iv_fval = 'RF05L-BELNR' ).
              bdc_field( iv_fnam = 'BDC_OKCODE' iv_fval = '/00' ).
              bdc_field( iv_fnam = 'RF05L-BELNR' iv_fval = CONV #( <fs_partidas>-belnr ) ).
              bdc_field( iv_fnam = 'RF05L-BUKRS' iv_fval = CONV #( <fs_partidas>-bukrs ) ).
              bdc_field( iv_fnam = 'RF05L-GJAHR' iv_fval = CONV #( <fs_partidas>-gjahr ) ).
              bdc_field( iv_fnam = 'RF05L-BUZEI' iv_fval = CONV #( <fs_partidas>-buzei ) ).

              bdc_dynpro( iv_program = 'SAPMF05L' iv_dynpro  = '0301' ).
              bdc_field( iv_fnam = 'BDC_CURSOR' iv_fval = 'BSEG-ZTERM' ).
              bdc_field( iv_fnam = 'BDC_OKCODE' iv_fval = '=ZK' ).

              bdc_dynpro( iv_program = 'SAPMF05L' iv_dynpro  = '1301' ).
              bdc_field( iv_fnam = 'BDC_CURSOR' iv_fval = 'BSEG-DTWS3' ).
              bdc_field( iv_fnam = 'BDC_OKCODE' iv_fval = '=ENTR' ).
              bdc_field( iv_fnam = 'BSEG-ZLSCH' iv_fval = CONV #( <fs_partidas>-zlsch ) ).
              bdc_field( iv_fnam = 'BSEG-DTWS1' iv_fval = CONV #( <fs_partidas>-dtws1 ) ).
              bdc_field( iv_fnam = 'BSEG-DTWS2' iv_fval = CONV #( <fs_partidas>-dtws2 ) ).
              bdc_field( iv_fnam = 'BSEG-DTWS3' iv_fval = CONV #( <fs_partidas>-dtws3 ) ).
              bdc_field( iv_fnam = 'BSEG-DTWS4' iv_fval = '0' ).

              bdc_dynpro( iv_program = 'SAPMF05L' iv_dynpro  = '0301' ).
              bdc_field( iv_fnam = 'BDC_CURSOR' iv_fval = 'BSEG-ZTERM' ).
              bdc_field( iv_fnam = 'BSEG-ZLSPR' iv_fval = '9' ).
              bdc_field( iv_fnam = 'BDC_OKCODE' iv_fval = '=AE' ).
              "Fim do preenchimento do SHDB para a Transação FB09

              "Chamada da Função FB09
              lv_mode = lc_modus_n.
              CALL TRANSACTION 'FB09' USING  gt_bdcdata
                                      MODE   lv_mode
                                      UPDATE lc_update.
              FREE gt_bdcdata.

            ENDLOOP.

          ENDIF.

        ENDIF.

      ENDIF.

    ENDIF.

    "Verificando se a importação realmente aconteceu.
    SORT lt_job_log BY msgid msgno.

    READ TABLE lt_job_log INTO ls_job_log
        WITH KEY msgid = lc_msgid_fb
                 msgno = 773
        BINARY SEARCH.
    IF sy-subrc = 0.

      FREE ls_msg.
      ls_msg = VALUE bapiret2(
            id          = ls_job_log-msgid
            type        = if_xo_const_message=>error
            number      = ls_job_log-msgno
        ).

      me->add_log_msg(
        EXPORTING
          is_message = ls_msg
      ).

      "Erro ao importar o arquivo & na FF.5
      RAISE EXCEPTION TYPE zcxfi_autobanc_import
        EXPORTING
          iv_textid = zcxfi_autobanc_import=>gc_ff5_import_erro
          iv_type   = if_xo_const_message=>error
          iv_msgv1  = CONV #( iv_file_name ).

    ENDIF.

    " Atualiza log com mensagens do processamento
    SORT lt_job_log BY msgtype.

    LOOP AT lt_job_log INTO ls_job_log.

      FREE ls_msg.
      ls_msg = VALUE bapiret2(
            id          = ls_job_log-msgid
            type        = ls_job_log-msgtype
            number      = ls_job_log-msgno
            message_v1  = ls_job_log-msgv1
            message_v2  = ls_job_log-msgv2
            message_v3  = ls_job_log-msgv3
            message_v4  = ls_job_log-msgv4
        ).

      me->add_log_msg(
        EXPORTING
          is_message = ls_msg
      ).

    ENDLOOP.

    " Exceção em caso de mensagem de erro
    READ TABLE lt_job_log INTO ls_job_log
        WITH KEY msgtype = if_xo_const_message=>error
        BINARY SEARCH.
    IF sy-subrc EQ 0.

      RAISE EXCEPTION TYPE zcxfi_autobanc_import
        EXPORTING
          iv_textid = VALUE #( msgid = ls_job_log-msgid
                               msgno = ls_job_log-msgno
                               attr1 = ls_job_log-msgv1
                               attr2 = ls_job_log-msgv2
                               attr3 = ls_job_log-msgv3
                               attr4 = ls_job_log-msgv4 )
          iv_type   = if_xo_const_message=>error.

    ENDIF.

    " Exceção em caso de abort
    READ TABLE lt_job_log INTO ls_job_log
      WITH KEY msgtype = if_xo_const_message=>abort
      BINARY SEARCH.
    IF sy-subrc EQ 0.

      RAISE EXCEPTION TYPE zcxfi_autobanc_import
        EXPORTING
          iv_textid = VALUE #( msgid = ls_job_log-msgid
                               msgno = ls_job_log-msgno
                               attr1 = ls_job_log-msgv1
                               attr2 = ls_job_log-msgv2
                               attr3 = ls_job_log-msgv3
                               attr4 = ls_job_log-msgv4 )
          iv_type   = if_xo_const_message=>error.

    ENDIF.

  ENDMETHOD.


  METHOD select_data_log.

    SELECT  Codigo,
            Nome,
            Tipo,
            ChaveBreve,
            Msgtype,
            Diretorio,
            Message,
            CreatedBy,
            CreatedAt,
            LastChangedBy,
            LastChangedAt,
            LocalLastChangedAt
      FROM zi_fi_autobanc_log
     WHERE msgtype EQ @if_xo_const_message=>success
       INTO TABLE @gt_log_import.

  ENDMETHOD.


  METHOD constructor.
    me->go_log = io_log.
  ENDMETHOD.


  METHOD add_log_msg.

    IF me->go_log IS NOT BOUND.
      RETURN.
    ENDIF.

    me->go_log->insert_log(
      EXPORTING
        is_message     = is_message
        is_log_context = is_log_context
    ).

    me->go_log->save_log( ).

  ENDMETHOD.
ENDCLASS.
