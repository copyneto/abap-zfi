"!<p><h2>Automat. Bancária - Importação arquivos Van FINNET</h2></p>
"!<p><strong>Autor:</strong> Anderson Miazato - Meta</p>
"!<p><strong>Data:</strong> 18 de out de 2021</p>
CLASS zclfi_autobanc_import DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    CONSTANTS:
      "! Tipos de arquivo
      BEGIN OF gc_tipo_arq,
        cobranca(3)  TYPE c VALUE 'COB',
        ext(3)       TYPE c VALUE 'EXT',
        pagamento(3) TYPE c VALUE 'PAG',
        pagfinal(3)  TYPE c VALUE 'PGF',
      END OF gc_tipo_arq.

    CONSTANTS:
      "! Diretórios por tipo de processamento
      BEGIN OF gc_tipo_diretorio,
        Cobranca_nao_proc       TYPE ztfi_autbanc_dir-tipo VALUE '00',
        Contas_pagar_saida      TYPE ztfi_autbanc_dir-tipo VALUE '01',
        Cobranca_saida          TYPE ztfi_autbanc_dir-tipo VALUE '02',
        Contas_pagar_retorno    TYPE ztfi_autbanc_dir-tipo VALUE '03',
        Cobranca_retorno        TYPE ztfi_autbanc_dir-tipo VALUE '04',
        Contas_pagar_proc       TYPE ztfi_autbanc_dir-tipo VALUE '05',
        Cobranca_proc           TYPE ztfi_autbanc_dir-tipo VALUE '06',
        Contas_pagar_DDA        TYPE ztfi_autbanc_dir-tipo VALUE '07',
        DDA_proc                TYPE ztfi_autbanc_dir-tipo VALUE '08',
        Contas_pagar_nao_proc   TYPE ztfi_autbanc_dir-tipo VALUE '09',
        Extrato_Eletro          TYPE ztfi_autbanc_dir-tipo VALUE '10',
        Extrato_Eletro_proc     TYPE ztfi_autbanc_dir-tipo VALUE '11',
        Extrato_Eletro_nao_proc TYPE ztfi_autbanc_dir-tipo VALUE '12',
      END OF gc_tipo_diretorio.

    DATA:
      "! Diretórios para importação
      gt_directory_to_import TYPE TABLE OF zi_fi_autobanc_diretorios.

    CLASS-METHODS:

      "! Gera instância desta classe
      "! @parameter ro_result | Instância gerada
      create_instance
        RETURNING
          VALUE(ro_result) TYPE REF TO zclfi_autobanc_import,

      "! Controlador de erro
      "! @parameter iv_popup | Erro em pop-up = 'X', Erro em formato mensagem = '')
      "! @parameter io_cx    | Exceções
      handle_error
        IMPORTING
          iv_popup TYPE flag OPTIONAL
          io_cx    TYPE REF TO zcxfi_autobanc_import.

    METHODS:
      "! Verifica se há algum job em execução neste momento
      check_job,
      "! Importa arquivo dos diretórios disponíveis
      main.
  PROTECTED SECTION.
  PRIVATE SECTION.

    "! Constante para Popup Modo Ativo
    CONSTANTS gc_popup_active TYPE c VALUE 'A'.

    TYPES:
      "! Dados de diretório e arquivo para importação
      BEGIN OF ty_import_files.
        INCLUDE TYPE zi_fi_autobanc_diretorios.
        INCLUDE TYPE eps2fili.
    TYPES: END OF ty_import_files.

    TYPES:
      "! Categ. tabela dos arquivos que serão importados
      tt_import_files TYPE STANDARD TABLE OF ty_import_files           WITH DEFAULT KEY,
      "! Categ. tabela dos Diretórios
      tt_directory    TYPE STANDARD TABLE OF zi_fi_autobanc_diretorios WITH DEFAULT KEY.

    DATA:
      go_log TYPE REF TO zclfi_autobanc_import_log.

    DATA:
      "! Arquivos que serão importados
      gt_import_files TYPE tt_import_files,
      "! Tipos de processamento
      gt_tipos_proc   TYPE SORTED TABLE OF dd07v WITH NON-UNIQUE KEY domvalue_l.

    METHODS:

      "! Busca descrições dos tipos de processamento
      "! @parameter iv_tipo_proc | Tipo de processo
      "! @parameter rv_result    | Descrição tipo de processo
      busca_tipos_proc
        IMPORTING iv_tipo_proc     TYPE zi_fi_autobanc_diretorios-Tipo OPTIONAL
        RETURNING VALUE(rv_result) TYPE val_text,

      "! Inicia o log
      init_log,

      "! Armazena nova mensagem
      "! @parameter is_message          | Mensagem
      "! @parameter is_log_context      | Contexto do log
      add_log_msg
        IMPORTING
          is_message     TYPE bapiret2
          is_log_context TYPE zsfi_log_van_finnet OPTIONAL,

      "! Recupera diretórios para importação
      "! @parameter rt_directory        | Diretórios
      "! @raising zcxfi_autobanc_import | Erro ao buscar diretórios
      get_directory_to_import
        RETURNING
          VALUE(rt_directory) TYPE tt_directory
        RAISING
          zcxfi_autobanc_import,

      "! Recupera diretórios para mover arquivos após processamento
      "! @parameter rt_directory        | Diretórios para pós processamento
      get_dir_post_process
        RETURNING
          VALUE(rt_directory) TYPE tt_directory,

      "! Recupera arquivos do diretório
      "! @parameter is_dir              | Diretório
      "! @parameter rt_files            | Arquivos do diretório
      "! @raising zcxfi_autobanc_import | Erro ao buscar arquivos
      get_files
        IMPORTING
          is_dir          TYPE zi_fi_autobanc_diretorios
        RETURNING
          VALUE(rt_files) TYPE eps2filis
        RAISING
          zcxfi_autobanc_import,

      "! Importa arquivos
      "! @parameter it_directory | Diretório a ser importado
      "! @parameter rt_result    | Arquivos importados
      get_import_files
        IMPORTING
          it_directory     TYPE zclfi_autobanc_import=>tt_directory
        RETURNING
          VALUE(rt_result) TYPE tt_import_files,

      "! Move arquivo para pasta de arq. processados
      "! @parameter is_import_file | Arquivo importado
      "! @parameter it_dir_types   | Tipo de processamento
      move_file_to_processed_folder
        IMPORTING
          is_import_file TYPE ty_import_files
          it_dir_types   TYPE zclfi_autobanc_import=>tt_directory,

      "! Move arquivo para pasta de arquivos com erro
      "! @parameter is_import_file | Arquivo com erro na importação
      "! @parameter it_dir_types   | Tipos de processamento
      move_file_to_error_folder
        IMPORTING
          is_import_file TYPE ty_import_files
          it_dir_types   TYPE zclfi_autobanc_import=>tt_directory,

      "! Lê o arquivo no caminho informado
      read_dataset.

ENDCLASS.



CLASS ZCLFI_AUTOBANC_IMPORT IMPLEMENTATION.


  METHOD get_directory_to_import.

    DATA:
      lr_tipos_validos TYPE RANGE OF zi_fi_autobanc_diretorios-Tipo.

    lr_tipos_validos = VALUE #( sign   = rsmds_c_sign-including
                                option = rsmds_c_option-equal
                                ( low = gc_tipo_diretorio-contas_pagar_retorno )
                                ( low = gc_tipo_diretorio-cobranca_retorno )
                                ( low = gc_tipo_diretorio-extrato_eletro )
                       ).

    "Seleciona os diretórios para importação
    SELECT  CompanyCode,
            Tipo,
            Diretorio,
            CreatedBy,
            CreatedAt,
            LastChangedBy,
            LastChangedAt,
            LocalLastChangedAt
      FROM zi_fi_autobanc_diretorios
      WHERE Tipo IN @lr_tipos_validos
         INTO TABLE @rt_directory.

    IF sy-subrc IS NOT INITIAL.

      DATA(ls_msg) = VALUE bapiret2(
            id          = zcxfi_autobanc_import=>gc_import_directory_not_found-msgid
            type        = if_xo_const_message=>error
            number      = zcxfi_autobanc_import=>gc_import_directory_not_found-msgno
            message_v1  = 'ZFIAUTBANC_DIRETORIO'(001)
        ).

      me->add_log_msg(
        EXPORTING
          is_message = ls_msg
      ).

      "Nenhum diretório para importação configurado na transação ZFIAUTBANC_DIRETORIO
      RAISE EXCEPTION TYPE zcxfi_autobanc_import
        EXPORTING
          iv_textid = zcxfi_autobanc_import=>gc_import_directory_not_found
          iv_msgv1  = 'ZFIAUTBANC_DIRETORIO'(001).

    ELSE.

      SORT rt_directory ASCENDING BY diretorio.

    ENDIF.

  ENDMETHOD.


  METHOD get_files.

    CONSTANTS:
      lc_file_mask TYPE epsf-epsfilnam VALUE '*.*'.

    DATA:
      lv_dir   TYPE eps2filnam,
      lv_msgv1 TYPE sy-msgv1,
      lv_msgv2 TYPE sy-msgv2,
      lv_msgv3 TYPE sy-msgv3.

    lv_dir = is_dir-Diretorio.

    FREE: rt_files.

    CALL FUNCTION 'EPS2_GET_DIRECTORY_LISTING'
      EXPORTING
        iv_dir_name            = lv_dir
        file_mask              = lc_file_mask
      TABLES
        dir_list               = rt_files
      EXCEPTIONS
        invalid_eps_subdir     = 1
        sapgparam_failed       = 2
        build_directory_failed = 3
        no_authorization       = 4
        read_directory_failed  = 5
        too_many_read_errors   = 6
        empty_directory_list   = 7
        OTHERS                 = 8.

    IF sy-subrc NE 0.

      DATA(lv_dir_subrc) = sy-subrc.

      CALL FUNCTION 'IQAPI_WORD_WRAP'
        EXPORTING
          textline            = lv_dir
          outputlen           = 50
        IMPORTING
          out_line1           = lv_msgv1
          out_line2           = lv_msgv2
          out_line3           = lv_msgv3
        EXCEPTIONS
          outputlen_too_large = 1
          OTHERS              = 2.
      IF sy-subrc NE 0.
        CLEAR: lv_msgv1, lv_msgv2, lv_msgv3.
      ENDIF.

      DATA(lv_tipo_proc_desc) = me->busca_tipos_proc( is_dir-Tipo ).

      CASE lv_dir_subrc.

        WHEN 7. "Diretório Vazio

          DATA(ls_msg) = VALUE bapiret2(
                id          = zcxfi_autobanc_import=>gc_directory_empty-msgid
                type        = if_xo_const_message=>error
                number      = zcxfi_autobanc_import=>gc_directory_empty-msgno
                message_v1  = lv_msgv1
                message_v2  = lv_msgv2
                message_v3  = CONV #( lv_tipo_proc_desc )
            ).

          me->add_log_msg(
            EXPORTING
              is_message = ls_msg
          ).

          RAISE EXCEPTION TYPE zcxfi_autobanc_import
            EXPORTING
              iv_textid = zcxfi_autobanc_import=>gc_directory_empty
              iv_msgv1  = lv_msgv1
              iv_msgv2  = lv_msgv2
              iv_type   = if_xo_const_message=>warning.

        WHEN OTHERS. "Outras exceções

          FREE ls_msg.
          ls_msg = VALUE bapiret2(
                id          = zcxfi_autobanc_import=>gc_read_directory_failed-msgid
                type        = if_xo_const_message=>error
                number      = zcxfi_autobanc_import=>gc_read_directory_failed-msgno
                message_v1  = lv_msgv1
                message_v2  = lv_msgv2
                message_v3  = CONV #( lv_tipo_proc_desc )
            ).

          me->add_log_msg(
            EXPORTING
              is_message = ls_msg
          ).

          "Erro ao tentar ler o diretório
          RAISE EXCEPTION TYPE zcxfi_autobanc_import
            EXPORTING
              iv_textid = zcxfi_autobanc_import=>gc_read_directory_failed
              iv_msgv1  = lv_msgv1
              iv_msgv2  = lv_msgv2
              iv_type   = if_xo_const_message=>warning.
      ENDCASE.

    ENDIF.

  ENDMETHOD.


  METHOD check_job.

    CONSTANTS:
      lc_status TYPE tbtcp-status VALUE 'R'.

    DATA: lv_jobname  TYPE tbtcp-jobname,
          lv_jobcount TYPE tbtcp-jobcount,
          lv_status   TYPE tbtcp-status.

    SELECT COUNT(*)
    FROM tbtcp INTO @DATA(lv_qtd)
     WHERE progname EQ @sy-cprog
       AND status EQ @lc_status.

    IF lv_qtd > 1.

      MESSAGE ID zclfi_autobanc_import_log=>gc_msgid TYPE if_xo_const_message=>success NUMBER 012 DISPLAY LIKE if_xo_const_message=>error.

      DATA(ls_msg) = VALUE bapiret2(
            id          = zclfi_autobanc_import_log=>gc_msgid
            type        = if_xo_const_message=>error
            number      = 012
        ).

      me->add_log_msg(
        EXPORTING
          is_message = ls_msg
      ).

      LEAVE TO LIST-PROCESSING.

      LEAVE LIST-PROCESSING.

    ENDIF.

  ENDMETHOD.


  METHOD create_instance.
    CREATE OBJECT ro_result.
  ENDMETHOD.


  METHOD handle_error.

    DATA: lt_return TYPE bapiret2_t.

    lt_return = io_cx->get_bapin_return( ).

    READ TABLE lt_return INTO DATA(ls_return) INDEX 1.
    IF sy-subrc NE 0.
      RETURN.
    ENDIF.

    "Mensagem footer
    IF iv_popup EQ gc_popup_active.
      RETURN.
    ELSEIF iv_popup EQ abap_false.

      MESSAGE ID     ls_return-id
              TYPE   if_xo_const_message=>success
              NUMBER ls_return-number WITH ls_return-message_v1
                                           ls_return-message_v2
                                           ls_return-message_v3
                                           ls_return-message_v4 DISPLAY LIKE if_xo_const_message=>error.

    ELSE.

      "Mensagem em pop-up
      CALL FUNCTION 'FB_MESSAGES_DISPLAY_POPUP'
        EXPORTING
          it_return       = lt_return
        EXCEPTIONS
          no_messages     = 1
          popup_cancelled = 2
          OTHERS          = 3.

      IF sy-subrc NE 0.
        DATA(lv_dummy) = abap_true.
      ENDIF.

    ENDIF.

  ENDMETHOD.


  METHOD main.


    DATA(lo_param) = NEW zclca_tabela_parametros( ).

    DATA(lv_gap_ativo) = VALUE abap_bool(  ).

    TRY.
        lo_param->m_get_single(
          EXPORTING
            iv_modulo = 'FI-AR'
            iv_chave1 = 'VAN_FINNET'
          IMPORTING
            ev_param  = lv_gap_ativo
        ).
      CATCH zcxca_tabela_parametros.
        lv_gap_ativo = abap_False.
    ENDTRY.

    IF lv_gap_ativo EQ abap_False.
      RETURN.
    ENDIF.


    DATA:
      lv_msg_erro TYPE   bapi_msg.

    me->init_log( ).

    "Verifica se existe algum JOB rodando em background.
    me->check_job( ).

    "Obtém diretórios para importação
    TRY.

        DATA(lt_directory) = me->get_directory_to_import( ).

      CATCH zcxfi_autobanc_import INTO DATA(lo_cx_dir).

        zclfi_autobanc_import=>handle_error( io_cx    = lo_cx_dir
                                             iv_popup = gc_popup_active ).


    ENDTRY.

    " Busca descrições dos tipos de processo
    me->busca_tipos_proc(  ).

    DATA(lt_dir_post_process) = me->get_dir_post_process( ).
    SORT lt_dir_post_process BY CompanyCode Tipo.

    "Obtém arquivos para importação
    DATA(lt_import_files) = me->get_import_files( EXPORTING it_directory = lt_directory ).

    "Processando os arquivos
    LOOP AT lt_import_files ASSIGNING FIELD-SYMBOL(<fs_s_file>).

      TRY.
          "Verifica o tipo de arquivo a ser processado.
          IF <fs_s_file>-name(3) NE gc_tipo_arq-ext AND
             <fs_s_file>-name(3) NE gc_tipo_arq-cobranca AND
             <fs_s_file>-name(3) NE gc_tipo_arq-pagamento AND
             <fs_s_file>-name(3) NE gc_tipo_arq-pagfinal.

            DATA(ls_msg) = VALUE bapiret2(
                  id          = zclfi_autobanc_import_log=>gc_msgid
                  type        = if_xo_const_message=>error
                  number      = 010
                  message_v1  = <fs_s_file>-name
              ).

            DATA(ls_log_context) = VALUE zsfi_log_van_finnet(
                                        diretorio    = <fs_s_file>-diretorio
                                        nome_arq     = CONV char50( <fs_s_file>-name )
                                        tipo_proc    = <fs_s_file>-tipo ).

            me->add_log_msg(
              EXPORTING
                is_message     = ls_msg
                is_log_context = ls_log_context
            ).

            CONTINUE.
          ENDIF.

          DATA(lo_bank_file) = zclfi_autobanc_bank_file=>create_instance( me->go_log ).

          DATA(ls_directory) = CORRESPONDING zi_fi_autobanc_diretorios( <fs_s_file> ).

          DATA(lv_chave) = lo_bank_file->process( is_directory = ls_directory
                                                  iv_file_name = <fs_s_file>-name ).
          "Arquivo importado com sucesso
          MESSAGE s007 INTO DATA(lv_msg) WITH <fs_s_file>-name.

          ls_msg = VALUE bapiret2(
                id          = zclfi_autobanc_import_log=>gc_msgid
                type        = if_xo_const_message=>success
                number      = 007
                message_v1  = <fs_s_file>-name
            ).

          ls_log_context = VALUE zsfi_log_van_finnet(
                                      diretorio    = <fs_s_file>-diretorio
                                      nome_arq     = CONV char50( <fs_s_file>-name )
                                      tipo_proc    = <fs_s_file>-tipo
                                      kukey_eb     = lv_chave ).

          me->add_log_msg(
            EXPORTING
              is_message     = ls_msg
              is_log_context = ls_log_context
          ).

          "Move o arquivo processado com sucesso para a pasta de processado.
          me->move_file_to_processed_folder(
            EXPORTING
              is_import_file = <fs_s_file>
              it_dir_types   = lt_dir_post_process
          ).

          DATA(lv_processa_bi) = abap_True.

        CATCH zcxfi_autobanc_import INTO DATA(lo_cx_erro).


          "Tranferindo arquivo com erro para pasta de não processados
          me->move_file_to_error_folder(
            EXPORTING
              is_import_file = <fs_s_file>
              it_dir_types   = lt_dir_post_process
          ).

          lv_msg_erro = lo_cx_erro->get_text( ).

          CONCATENATE TEXT-e01 lv_msg_erro INTO lv_msg_erro SEPARATED BY space.

          FREE ls_msg.
          ls_msg = VALUE bapiret2(
                        id          = zclfi_autobanc_import_log=>gc_msgid
                        type        = if_xo_const_message=>error
                        number      = 008
                        message_v1  = <fs_s_file>-name
            ).

          FREE ls_log_context.
          ls_log_context = VALUE zsfi_log_van_finnet(
                                  diretorio    = <fs_s_file>-diretorio
                                  nome_arq     = CONV char50( <fs_s_file>-name )
                                  tipo_proc    = <fs_s_file>-tipo
                                  kukey_eb     = lv_chave ).

          me->add_log_msg(
            EXPORTING
              is_message     = ls_msg
              is_log_context = ls_log_context
          ).


      ENDTRY.
    ENDLOOP.

    IF lv_processa_bi EQ abap_True.

      IF lo_bank_file IS INITIAL.
        lo_bank_file = zclfi_autobanc_bank_file=>create_instance( me->go_log ).
      ENDIF.

      lo_bank_file->execute_batch( ).

    ENDIF.

    IF sy-batch EQ abap_False.

      MESSAGE ID zclfi_autobanc_import_log=>gc_msgid
        TYPE if_xo_const_message=>success
        NUMBER 014
        WITH zclfi_autobanc_import_log=>gc_object
             zclfi_autobanc_import_log=>gc_subobject-importa_arquivo.
    ENDIF.

  ENDMETHOD.


  METHOD get_import_files.

    DATA(lt_directory) = it_directory.

    LOOP AT lt_directory ASSIGNING FIELD-SYMBOL(<fs_s_directory>).

      TRY.

          "Recupera os arquivos de cada diretório
          DATA(lt_files) = me->get_files( <fs_s_directory> ).

          rt_result = VALUE #( BASE rt_result
                                    FOR ls_files IN lt_files
                                      ( CompanyCode         = <fs_s_directory>-companycode
                                        Tipo                = <fs_s_directory>-Tipo
                                        Diretorio           = <fs_s_directory>-Diretorio
                                        CreatedBy           = <fs_s_directory>-CREATEDby
                                        CreatedAt           = <fs_s_directory>-createdat
                                        LastChangedBy       = <fs_s_directory>-lastchangedby
                                        LastChangedAt       = <fs_s_directory>-lastchangedat
                                        LocalLastChangedAt  = <fs_s_directory>-locallastchangedat
                                        name                = ls_files-name
                                        size                = ls_files-size
                                        mtim                = ls_files-mtim
                                        owner               = ls_files-owner
                                        rc                  = ls_files-rc
                                       )

                      ).


        CATCH zcxfi_autobanc_import INTO DATA(lo_cx_erro).
          zclfi_autobanc_import=>handle_error( io_cx    = lo_cx_erro
                                               iv_popup = gc_popup_active ).
      ENDTRY.

      FREE: lt_files.

    ENDLOOP.

  ENDMETHOD.


  METHOD read_dataset.

    DATA: lv_fileread TYPE string,
          lv_fileproc TYPE string,
          lv_file     TYPE string,
          lv_tipo     TYPE zi_fi_autobanc_diretorios-Tipo.


    DATA: lt_file     TYPE STANDARD TABLE OF x.

    DATA: ls_file     LIKE LINE OF lt_file.


    DO 10 TIMES.
      IF sy-subrc EQ 0.
      ENDIF.
    ENDDO.

    LOOP AT lt_file ASSIGNING FIELD-SYMBOL(<fs_file>).
      TRANSFER <fs_file> TO lv_fileproc.
    ENDLOOP.


  ENDMETHOD.


  METHOD move_file_to_processed_folder.

    CONSTANTS:
      lc_separador_dir(1) TYPE c VALUE '/'.

    CONSTANTS:
      BEGIN OF lc_tipo_dir,
        cobranca TYPE ztfi_autbanc_dir-tipo VALUE '06',
        extrato  TYPE ztfi_autbanc_dir-tipo VALUE '11',
        outros   TYPE ztfi_autbanc_dir-tipo VALUE '05',
      END OF lc_tipo_dir.

    DATA: lt_file     TYPE STANDARD TABLE OF x.

    DATA: ls_file     LIKE LINE OF lt_file.

    DATA: lv_fileread TYPE string,
          lv_fileproc TYPE string,
          lv_file     TYPE string,
          lv_tipo     TYPE zi_fi_autobanc_diretorios-Tipo.

    DATA(lv_tam) = strlen( is_import_file-diretorio ) - 1.

    IF is_import_file-diretorio+lv_tam CS lc_separador_dir.
      lv_fileread = |{ is_import_file-diretorio }{ is_import_file-name }|.
    ELSE.
      lv_fileread = |{ is_import_file-diretorio }{ lc_separador_dir }{ is_import_file-name }|.
    ENDIF.

    me->read_dataset(  ).


    "Efetuando a leitura do arquivo.
    OPEN DATASET lv_fileread FOR INPUT IN BINARY MODE.
    IF sy-subrc EQ 0.

      DO.

        READ DATASET lv_fileread INTO ls_file.
        IF sy-subrc EQ 0.
          APPEND ls_file TO lt_file.
        ELSE.
          EXIT.
        ENDIF.

      ENDDO.

    ENDIF.

    IF NOT lt_file IS INITIAL.

      lv_tipo = SWITCH #( is_import_file-name(3)
                          WHEN gc_tipo_arq-cobranca THEN lc_tipo_dir-cobranca
                          WHEN gc_tipo_arq-ext THEN lc_tipo_dir-extrato
                          ELSE lc_tipo_dir-outros ) .

      READ TABLE it_dir_types ASSIGNING FIELD-SYMBOL(<fs_dir_type>)
        WITH KEY CompanyCode = is_import_file-CompanyCode
                 tipo = lv_tipo
        BINARY SEARCH.

      IF sy-subrc EQ 0.

        lv_fileproc = <fs_dir_type>-Diretorio.

        IF is_import_file-diretorio+lv_tam CS lc_separador_dir.
          lv_fileproc = |{ lv_fileproc }{ is_import_file-name }|.
        ELSE.
          lv_fileproc = |{ lv_fileproc }{ lc_separador_dir }{ is_import_file-name }|.
        ENDIF.
        "Efetuando a gravação do arquivo processado.
        OPEN DATASET lv_fileproc FOR OUTPUT IN BINARY MODE.
        IF sy-subrc EQ 0.
          LOOP AT lt_file ASSIGNING FIELD-SYMBOL(<fs_file>).
            TRANSFER <fs_file> TO lv_fileproc.
          ENDLOOP.
          IF sy-subrc EQ 0.
            CLOSE DATASET lv_fileproc.
            DELETE DATASET lv_fileread .
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.


  ENDMETHOD.


  METHOD move_file_to_error_folder.

    CONSTANTS:
      lc_separador_dir(1) TYPE c VALUE '/'.

    CONSTANTS:
      BEGIN OF lc_tipo_dir,
        cobranca TYPE ZTFI_AUTBANC_DIR-tipo VALUE '00',
        extrato  TYPE ZTFI_AUTBANC_DIR-tipo VALUE '12',
        outros   TYPE ZTFI_AUTBANC_DIR-tipo VALUE '09',
      END OF lc_tipo_dir.


    DATA: lt_file     TYPE STANDARD TABLE OF x.

    DATA: ls_file     LIKE LINE OF lt_file.

    DATA: lv_fileread TYPE string,
          lv_fileproc TYPE string,
          lv_file     TYPE string,
          lv_tipo     TYPE zi_fi_autobanc_diretorios-Tipo.

    DATA(lv_tam_aux) = strlen( is_import_file-diretorio ) - 1.
    IF is_import_file-diretorio+lv_tam_aux CS lc_separador_dir.
      lv_fileread = |{ is_import_file-diretorio }{ is_import_file-name }|.
    ELSE.
      lv_fileread = |{ is_import_file-diretorio }{ lc_separador_dir }{ is_import_file-name }|.
    ENDIF.

    "Efetuando a leitura do arquivo.
    OPEN DATASET lv_fileread FOR INPUT IN BINARY MODE.
    IF sy-subrc EQ 0.
      DO.
        READ DATASET lv_fileread INTO ls_file.
        IF sy-subrc EQ 0.
          APPEND ls_file TO lt_file.
        ELSE.
          EXIT.
        ENDIF.
      ENDDO.
    ENDIF.

    IF NOT lt_file IS INITIAL.

      lv_tipo = SWITCH #( is_import_file-name(3)
                          WHEN gc_tipo_arq-cobranca THEN lc_tipo_dir-cobranca
                          WHEN gc_tipo_arq-ext THEN lc_tipo_dir-extrato
                          ELSE lc_tipo_dir-outros ) .

      READ TABLE it_dir_types ASSIGNING FIELD-SYMBOL(<fs_dir_type>)
        WITH KEY CompanyCode = is_import_file-CompanyCode
                 tipo = lv_tipo
        BINARY SEARCH.
      IF sy-subrc EQ 0.

        lv_fileproc = <fs_dir_type>-Diretorio.

        IF is_import_file-diretorio+lv_tam_aux CS lc_separador_dir.
          lv_fileproc = |{ lv_fileproc }{ is_import_file-name }|.
        ELSE.
          lv_fileproc = |{ lv_fileproc }{ lc_separador_dir }{ is_import_file-name }|.
        ENDIF.

        "Efetuando a gravação do arquivo processado.
        OPEN DATASET lv_fileproc FOR OUTPUT IN BINARY MODE.
        IF sy-subrc EQ 0.
          LOOP AT lt_file ASSIGNING FIELD-SYMBOL(<fs_file>).
            TRANSFER <fs_file> TO lv_fileproc.
          ENDLOOP.
          IF sy-subrc EQ 0.
            CLOSE DATASET lv_fileproc.
            DELETE DATASET lv_fileread .
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.

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


  METHOD init_log.

    FREE me->go_log.

    me->go_log = zclfi_autobanc_import_log=>create_instance(
      iv_subobject = zclfi_autobanc_import_log=>gc_subobject-importa_arquivo ).

  ENDMETHOD.


  METHOD busca_tipos_proc.

    CONSTANTS:
      lc_domain_tipo_proc TYPE dd07l-domname VALUE 'ZD_AUTOBANC_TP_PROC'.

    DATA:
      lt_domain_values TYPE STANDARD TABLE OF dd07v.

    IF me->gt_tipos_proc IS NOT INITIAL
        AND iv_tipo_proc IS NOT INITIAL.

      TRY.
          rv_result = me->gt_tipos_proc[ domvalue_l = iv_tipo_proc ]-ddtext.
        CATCH cx_sy_itab_line_not_found.
          RETURN.
      ENDTRY.

      RETURN.

    ENDIF.

    CALL FUNCTION 'GET_DOMAIN_VALUES'
      EXPORTING
        domname         = lc_domain_tipo_proc
      TABLES
        values_tab      = lt_domain_values
      EXCEPTIONS
        no_values_found = 1
        OTHERS          = 2.

    IF sy-subrc NE 0.
      FREE me->gt_tipos_proc.
      RETURN.
    ENDIF.

    me->gt_tipos_proc = lt_domain_values.

    IF iv_tipo_proc IS NOT INITIAL.

      TRY.
          rv_result = me->gt_tipos_proc[ domvalue_l = iv_tipo_proc ]-ddtext.
        CATCH cx_sy_itab_line_not_found.
          RETURN.
      ENDTRY.

    ENDIF.

  ENDMETHOD.


  METHOD get_dir_post_process.

    DATA:
      lr_tipos_validos TYPE RANGE OF zi_fi_autobanc_diretorios-tipo.

    lr_tipos_validos = VALUE #( sign   = rsmds_c_sign-including
                                option = rsmds_c_option-equal
                                ( low = gc_tipo_diretorio-cobranca_proc )
                                ( low = gc_tipo_diretorio-contas_pagar_proc )
                                ( low = gc_tipo_diretorio-dda_proc )
                                ( low = gc_tipo_diretorio-extrato_eletro_proc )

                                ( low = gc_tipo_diretorio-cobranca_nao_proc )
                                ( low = gc_tipo_diretorio-contas_pagar_nao_proc )
                                ( low = gc_tipo_diretorio-extrato_eletro_nao_proc )
                       ).

    "Seleciona os diretórios para mover arquivos processados/não processados
    SELECT  companycode,
            tipo,
            diretorio,
            createdby,
            createdat,
            lastchangedby,
            lastchangedat,
            locallastchangedat
      FROM zi_fi_autobanc_diretorios
      WHERE tipo IN @lr_tipos_validos
         INTO TABLE @rt_directory.

    IF sy-subrc IS INITIAL.

      SORT rt_directory ASCENDING BY diretorio.
      "pferraz - 12.05.23 - inicio
      "Ajustes van finnet- campo empresa esta multiplicando a quantidade de jobs
      DELETE ADJACENT DUPLICATES FROM rt_directory COMPARING diretorio.
      "pferraz - 12.05.23 - Fim

    ENDIF.

  ENDMETHOD.
ENDCLASS.
