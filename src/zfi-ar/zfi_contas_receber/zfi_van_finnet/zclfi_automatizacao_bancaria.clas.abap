"!<p><h2>Automat. Bancária - Leitura de diretórios na rede e Importação arquivos Van FINNET</h2></p>
"! Esta classe é utilizada para leitura e gravação de <em>arquivos de remessa</em> nos seguintes pontos: <br/>
"! <ul>
"! <li>Report RFFOBR_U, include RFFORI99, form DATEI_SCHLIESSEN; </li>
"! <li>Report RFFOBR_D, include RFFORI99, form DATEI_SCHLIESSEN; </li>
"! <li>Report RFFOBR_A, include RFFORI99, form DATEI_SCHLIESSEN; </li>
"! </ul>
"! <br/><br/>
"!<p><strong>Autor:</strong> Anderson Miazato - Meta</p>
"!<p><strong>Data:</strong> 21 de out de 2021</p>
CLASS zclfi_automatizacao_bancaria DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    TYPES:
      "! Linha do arquivo DDA
      BEGIN OF ty_line_dda,
        campo(255) TYPE c,
      END OF ty_line_dda,

      "! Categ. tabela para arquivo DDA
      tt_line_dda TYPE STANDARD TABLE OF ty_line_dda.

    CONSTANTS:
      "! Atividade autorizada: exibir
      gc_activ_display TYPE	activ_auth VALUE '03'.

    CONSTANTS:
      "! Formas de pagamento para cada tipo de arquivo
      BEGIN OF gc_forma_pagto,
        fornecedor  TYPE string VALUE 'TUBG',
        tributos    TYPE string VALUE 'OQ',
        cobranca    TYPE string VALUE 'DZ',
        riscosacado TYPE string VALUE 'RCNVPX',
      END OF gc_forma_pagto.

    CLASS-DATA:
      "! Diretório de arquivos de saída
      gv_diretorio_saida   TYPE   ze_autobanc_diretorio.

    CLASS-METHODS:

      "! Verifica se o arquivo já foi processado
      "! @parameter IS_REGUH  | Cabeçalho de proposta de pagamento
      "! @parameter RV_STATUS | Status do arquivo (X = processado)
      check_processado
        IMPORTING
          !is_reguh        TYPE reguh
        RETURNING
          VALUE(rv_status) TYPE flag,

      "! Busca o diretório para importação dos arquivos
      "! @parameter IV_BUKRS | Cód. Empresa
      "! @parameter IV_TIPO  | Tipo de importação
      "! @parameter RV_DIR   | Nome do diretório
      get_diretorio
        IMPORTING
          !iv_bukrs     TYPE bukrs
          !iv_tipo      TYPE ze_autobanc_tp_proc
        RETURNING
          VALUE(rv_dir) TYPE ze_autobanc_diretorio,


      "! Recupera instância ativa desta classe
      "! @parameter IV_BUKRS    | Cód. Empresa
      "! @parameter IT_BUKRS    | Range de Empresas
      "! @parameter RO_INSTANCE | Instância
      get_instance
        IMPORTING
          !iv_bukrs          TYPE bukrs OPTIONAL
          !it_bukrs          TYPE fagl_range_t_bukrs OPTIONAL
        RETURNING
          VALUE(ro_instance) TYPE REF TO zclfi_automatizacao_bancaria,

      "! Busca sequencial para o banco
      "! @parameter IV_BANCO | Banco
      "! @parameter RV_SEQ   | Sequencial
      get_sequencial_banco
        IMPORTING
          !iv_banco     TYPE numc3
        RETURNING
          VALUE(rv_seq) TYPE numc3,

      "! Grava arquivo de remessa na pasta de saída para a VAN
      "! @parameter IS_REGUH | Cabeçalho de proposta de pagamento
      "! @parameter IV_TIPO  | Tipo de processamento
      gravar_saida
        IMPORTING
          !is_reguh TYPE reguh
          !iv_tipo  TYPE ze_autobanc_tp_proc OPTIONAL,

      "! Busca arquivos de determinado diretório
      "! @parameter iv_path  | Caminho do diretório
      "! @parameter rt_files | Arquivos
      get_files
        IMPORTING
          !iv_path        TYPE any
        RETURNING
          VALUE(rt_files) TYPE eps2filis,

      "! Lê arquivo DDA
      "! @parameter IV_ARQ      | Caminho do Arquivo
      "! @parameter ET_OUT_DATA | Arquivo
      get_dda
        IMPORTING
          !iv_arq     TYPE any
        EXPORTING
          et_out_data TYPE tt_line_dda,

      "! Grava arquivo FINNET no report RFFOBR_U
      "! @parameter is_reguh | Cabeçalho de proposta de pagamento
      exec_proposal
        IMPORTING
          !is_reguh TYPE reguh.

    METHODS:

      "! Inicia o objeto
      "! @parameter iv_bukrs            | Cód. Empresa
      "! @parameter it_bukrs            | Range de empresas
      "! @raising zcxfi_autobanc_import | Exceções
      constructor
        IMPORTING
          !iv_bukrs TYPE bukrs OPTIONAL
          !it_bukrs TYPE fagl_range_t_bukrs OPTIONAL
        RAISING
          zcxfi_autobanc_import.
  PROTECTED SECTION.
  PRIVATE SECTION.
    CLASS-DATA:
      "! Instância ativa da classe
      go_instance TYPE REF TO zclfi_automatizacao_bancaria.

    CLASS-METHODS:

      "! Recupera arquivo de remessa
      "! @parameter is_regut | Dados do arquivo de pagamento
      "! @parameter rv_file  | Arquivo em formato string
      get_arq_remessa
        IMPORTING
          !is_regut      TYPE regut
        RETURNING
          VALUE(rv_file) TYPE string,

      "! Atualiza número sequencial do banco
      "! @parameter iv_banco  | Cód. Banco
      "! @parameter iv_action | Ação
      "! @parameter iv_data   | Data
      "! @parameter iv_seq    | Sequencial atualizado
      "! @parameter rv_status | Status da atualização
      set_sequencial_banco
        IMPORTING
          !iv_banco        TYPE numc3
          !iv_action       TYPE flag
          !iv_data         TYPE datum
          !iv_seq          TYPE numc3
        RETURNING
          VALUE(rv_status) TYPE flag,

      "! Atualiza log de processamento do arquivo
      "! @parameter is_reguh  | Cabeçalho da proposta de pagamento
      "! @parameter iv_dir    | Diretório
      "! @parameter iv_msgty  | Tipo de mensagem
      "! @parameter iv_msg    | Mensagem
      "! @parameter rv_status | Status de atualização
      set_log_proc
        IMPORTING
          !is_reguh        TYPE reguh
          !iv_dir          TYPE any
          !iv_msgty        TYPE msgty
          !iv_msg          TYPE ze_autobanc_msg_proc
        RETURNING
          VALUE(rv_status) TYPE flag,

      "! Recupera dígito da conta bancária
      "! @parameter iv_ubknt | Nosso número Conta do banco
      "! @parameter iv_ubkon | Código do banco
      "! @parameter rv_digit | Dígito
      get_digit_account
        IMPORTING
          !iv_ubknt       TYPE reguh-ubknt
          !iv_ubkon       TYPE reguh-ubkon
        RETURNING
          VALUE(rv_digit) TYPE reguh-ubkon.

    METHODS:
      "! Verifica autorização para visualizar dados da empresa
      "! @parameter iv_bukrs            | Cód. Empresa
      "! @parameter it_bukrs            | Range de empresas
      "! @raising zcxfi_autobanc_import | Erro de autorização
      check_authority_empresa
        IMPORTING
          !iv_bukrs TYPE bukrs OPTIONAL
          !it_bukrs TYPE fagl_range_t_bukrs OPTIONAL
        RAISING
          zcxfi_autobanc_import.


ENDCLASS.



CLASS ZCLFI_AUTOMATIZACAO_BANCARIA IMPLEMENTATION.


  METHOD check_processado.

    CONSTANTS:
      BEGIN OF lc_forma_pagto,
        antecipacao TYPE reguh-rzawe VALUE '6',
      END OF lc_forma_pagto.

    CONSTANTS:
      lc_Date_empty TYPE dats VALUE '00000000'.

    CLEAR: rv_status.
    IF is_reguh-rzawe = lc_forma_pagto-antecipacao.

      SELECT COUNT(*)
      FROM zi_fi_autobanc_procfile
      WHERE PaymentRunDate = @is_reguh-laufd
        AND PaymentRunID = @is_reguh-laufi
        AND type = @if_xo_const_message=>success.


    ELSE.

      SELECT COUNT(*)
        FROM zi_fi_autobanc_procfile
       WHERE PaymentRunDate       = @is_reguh-laufd
         AND PaymentRunID         = @is_reguh-laufi
         AND PaymentRunIsProposal = @is_reguh-xvorl
         AND PayingCompanyCode    = @is_reguh-zbukr
         AND Supplier             = @is_reguh-lifnr
         AND Customer             = @is_reguh-kunnr
         AND PaymentRecipient     = @is_reguh-empfg
         AND PaymentDocument      = @is_reguh-vblnr
         AND Type            = @if_xo_const_message=>success.

    ENDIF.

    IF sy-subrc EQ 0.
      rv_status = abap_true.
    ENDIF.

    IF rv_status IS INITIAL.

      IF is_reguh-rzawe = lc_forma_pagto-antecipacao.

        SELECT COUNT(*)
          FROM I_PaytMedia
          WHERE PaymentRunDate = @is_reguh-laufd
            AND PaymentRunID = @is_reguh-laufi
            AND ( DownloadFileName NE @space      OR
                  DownloadDate NE @lc_date_empty  OR
                  DownloadByUser NE @space ).

        IF sy-subrc EQ 0.
          rv_status = abap_true.
        ENDIF.
      ENDIF.
    ENDIF.


  ENDMETHOD.


  METHOD constructor.

    "Checa a autorização para a empresa informada.
    me->check_authority_empresa( EXPORTING iv_bukrs = iv_bukrs    " Empresa
                                           it_bukrs = it_bukrs ). " Tabela range para empresas

  ENDMETHOD.


  METHOD get_dda.

    DATA: ls_file LIKE LINE OF et_out_data.

    "Efetua a leitura do arquivo.
    OPEN DATASET iv_arq FOR INPUT IN TEXT MODE ENCODING DEFAULT.

    IF sy-subrc EQ 0.

      DO.
        READ DATASET iv_arq INTO ls_file.
        IF sy-subrc EQ 0.
          APPEND ls_file TO et_out_data.
        ELSE.
          EXIT.
        ENDIF.
      ENDDO.
    ENDIF.

  ENDMETHOD.


  METHOD get_diretorio.

    "Busca o diretório para automatização bancária.
    SELECT SINGLE diretorio
      FROM zi_fi_autobanc_diretorios
     WHERE CompanyCode EQ @iv_bukrs
       AND tipo  EQ @iv_tipo
       INTO @rv_dir.

    IF sy-subrc NE 0.
      CLEAR: rv_dir.
    ENDIF.

  ENDMETHOD.


  METHOD get_files.

    CONSTANTS:
      lc_file_mask TYPE epsf-epsfilnam VALUE '*.*'.

    DATA:
      lv_dir TYPE eps2filnam.

    lv_dir = iv_path.

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
      FREE rt_files.
    ENDIF.


  ENDMETHOD.


  METHOD get_instance.

    TRY.
        "Verifica se existe alguma instância ativa para a sessão.
        IF go_instance IS INITIAL.
          "Cria/Instancia o objeto da classe
          go_instance = NEW zclfi_automatizacao_bancaria(
            iv_bukrs = iv_bukrs
            it_bukrs = it_bukrs ).
        ENDIF.
        "Retorna a instância.
        ro_instance = go_instance.
      CATCH zcxfi_autobanc_import.
    ENDTRY.

  ENDMETHOD.


  METHOD get_sequencial_banco.

    CONSTANTS:
      BEGIN OF lc_action,
        insert(1) TYPE c VALUE '1',
        update(1) TYPE c VALUE '2',
      END OF lc_action.

    GET TIME.

    CLEAR: rv_seq.

    "Busca o último sequencial para o banco.
    SELECT SINGLE seq
      FROM zi_fi_autobanc_sequencial
     WHERE banco EQ @iv_banco
       AND data  EQ @sy-datum
       INTO @rv_seq.

    IF sy-subrc EQ 0.

      ADD 1 TO rv_seq.
      IF set_sequencial_banco( iv_action = lc_action-update
                               iv_banco  = iv_banco
                               iv_data   = sy-datum
                               iv_seq    = rv_seq ) IS INITIAL.
        "Erro, abortar o processo.
        CLEAR: rv_seq.
      ENDIF.
    ELSE.
      rv_seq = 001.
      set_sequencial_banco( iv_action = lc_action-insert
                            iv_banco  = iv_banco
                            iv_data   = sy-datum
                            iv_seq    = rv_seq ).
    ENDIF.

  ENDMETHOD.


  METHOD gravar_saida.

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
        lv_gap_ativo = abap_false.
    ENDTRY.

    IF lv_gap_ativo EQ abap_false.
      RETURN.
    ENDIF.


    CONSTANTS:
      lc_dot             TYPE c VALUE '.',
      lc_zero            TYPE c VALUE '0',
      lc_msg_variable    TYPE c VALUE '&',
      lc_separador_dir   TYPE c VALUE '/',
      lc_first_seq       TYPE lfdnr VALUE '001',
      lc_extensao_rem(4) TYPE c VALUE '.REM',
      lc_pagto_forn(3)   TYPE c VALUE 'PGF',
      lc_cobranca(3)     TYPE c VALUE 'COB',
      lc_pagto(3)        TYPE c VALUE 'PGF'.

    DATA:
      lt_regut TYPE STANDARD TABLE OF regut.

    DATA:
      ls_regut TYPE regut,
      ls_reguh TYPE reguh.

    DATA:
      lv_pos  TYPE i,
      lv_nome TYPE ze_autobanc_diretorio,
      lv_cc   TYPE c LENGTH 20,
      lv_bank TYPE n LENGTH 3,
      lv_msg  TYPE ze_autobanc_msg_proc,
      lv_tipo TYPE ze_autobanc_tp_proc.

    "Informa qual o tipo de diretório será utilizado.
    lv_tipo = iv_tipo.
    IF lv_tipo IS INITIAL OR lv_tipo = 9.
      lv_tipo = 1. "Contas a Pagar.
    ENDIF.
    "Move a estrutura informada pra uma local, podendo tratar melhor o registro.
    ls_reguh = is_reguh.
    "Verifica se a linha do cabeçalho do programa de pagamento está completa.

    IF ls_reguh-ubnks IS INITIAL OR
       ls_reguh-ubnkl IS INITIAL OR
       ls_reguh-ubkon IS INITIAL OR
       ls_reguh-ubknt IS INITIAL.

      IF lv_tipo = 9.
        SELECT laufd, laufi, xvorl, zbukr, lifnr, kunnr, empfg,
               vblnr, ubnks, ubnkl, ubkon, ubknt, hbkid, rzawe
          FROM zi_fi_paymt_proposal_header
          WHERE laufd EQ @ls_reguh-laufd
            AND laufi EQ @ls_reguh-laufi
            AND xvorl EQ @ls_reguh-xvorl
            AND zbukr EQ @ls_reguh-zbukr
            AND kunnr EQ @ls_reguh-kunnr
            AND empfg EQ @ls_reguh-empfg
            AND ubnkl <> @space
            INTO CORRESPONDING FIELDS OF @ls_reguh UP TO 1 ROWS.
        ENDSELECT.
      ELSE.
        SELECT laufd, laufi, xvorl, zbukr, lifnr, kunnr, empfg,
               vblnr, ubnks, ubnkl, ubkon, ubknt, hbkid, rzawe
          FROM zi_fi_paymt_proposal_header
          WHERE laufd EQ @ls_reguh-laufd
            AND laufi EQ @ls_reguh-laufi
            AND xvorl EQ @ls_reguh-xvorl
            AND zbukr EQ @ls_reguh-zbukr
            AND lifnr EQ @ls_reguh-lifnr
            AND kunnr EQ @ls_reguh-kunnr
            AND empfg EQ @ls_reguh-empfg
            AND vblnr EQ @ls_reguh-vblnr
            INTO CORRESPONDING FIELDS OF @ls_reguh UP TO 1 ROWS.
        ENDSELECT.
      ENDIF.
      IF sy-subrc NE 0.
        RETURN.
      ENDIF.
    ENDIF.

    SELECT zlsch FROM regup
      WHERE laufd = @ls_reguh-laufd
        AND laufi = @ls_reguh-laufi
        AND xvorl = @ls_reguh-xvorl
        AND zbukr = @ls_reguh-zbukr
        AND lifnr = @ls_reguh-lifnr
        AND kunnr = @ls_reguh-kunnr
        AND empfg = @ls_reguh-empfg
        AND vblnr = @ls_reguh-vblnr
        INTO @DATA(lv_zlsch) UP TO 1 ROWS.
    ENDSELECT.
    IF sy-subrc = 0.
      ls_reguh-rzawe = lv_zlsch.
    ENDIF.

    SELECT zbukr, banks, dtkey FROM regut
      WHERE laufd = @ls_reguh-laufd
        AND laufi = @ls_reguh-laufi
        AND xvorl = @ls_reguh-xvorl
        AND zbukr = @ls_reguh-zbukr
      INTO @DATA(ls_regut_dtkey) UP TO 1 ROWS.
    ENDSELECT.
    IF sy-subrc = 0.
      ls_reguh-hbkid = ls_regut_dtkey-dtkey.
      ls_reguh-ubnks = ls_regut_dtkey-banks.

      SELECT SINGLE bankl FROM t012
        WHERE bukrs = @ls_regut_dtkey-zbukr
          AND hbkid = @ls_regut_dtkey-dtkey
        INTO @DATA(lv_bankl_t012).

      SELECT SINGLE bankn, bkont FROM t012k
        WHERE bukrs = @ls_regut_dtkey-zbukr
          AND hbkid = @ls_regut_dtkey-dtkey
        INTO @DATA(ls_bankl_t012k).
    ENDIF.

    "Verifica se NÃO é proposta.
    CHECK ls_reguh-xvorl IS INITIAL.
    "Verifica se o arquivo já foi gerado em algum momento na pasta da VAN.
    CHECK check_processado( is_reguh = ls_reguh ) IS INITIAL.
    "Busca o diretório a ser utilizado para a gravação do arquivo de remessa.
    DATA(lv_dir) = get_diretorio( iv_bukrs = ls_reguh-zbukr
                                  iv_tipo  = lv_tipo ).
    IF NOT lv_dir IS INITIAL.
      GET TIME.
      "Gera a data no formato DDMMAAAA.
      WRITE sy-datum TO lv_nome.
      REPLACE ALL OCCURRENCES OF lc_dot IN lv_nome WITH space.
      lv_bank = lv_bankl_t012(3). "ls_reguh-ubnkl(3).
      lv_cc = ls_bankl_t012k-bankn && ls_bankl_t012k-bkont.
*      lv_cc = ls_reguh-ubknt && get_digit_account( iv_ubknt = ls_reguh-ubknt
*                                                   iv_ubkon = ls_reguh-ubkon ).
      CONDENSE lv_cc.
      SHIFT lv_cc LEFT DELETING LEADING lc_zero.
      CONDENSE lv_cc.
      "Verifica se existe número de banco.
      IF lv_bank IS INITIAL.
        "Aborta o método e retorna sem fazer nada.
        RETURN.
      ENDIF.

      "Concatena Banco, Conta, Data e Sequencial
*      lv_nome = |{ lv_bank }{ lv_cc }{ lv_nome }{ get_sequencial_banco( iv_banco = lv_bank ) }.REM|.
      lv_nome = |{ lv_bank }{ lv_cc }{ lv_nome }{ get_sequencial_banco( iv_banco = lv_bank ) }{ lc_extensao_rem }|.

      IF ls_reguh-rzawe CA gc_forma_pagto-fornecedor. "Arquivos de "Pagamento a Fornecedor".
*        lv_nome = |PGF{ lv_nome }|.
        lv_nome = |{ lc_pagto_forn }{ lv_nome }|.
      ELSEIF ls_reguh-rzawe CA gc_forma_pagto-tributos. "Arquivos de "Pagamento de Tributos e concessionaria".
*        lv_nome = |PGF{ lv_nome }|.
        lv_nome = |{ lc_pagto_forn }{ lv_nome }|.
      ELSEIF ls_reguh-rzawe CA gc_forma_pagto-cobranca.
*        lv_nome = |COB{ lv_nome }|.
        lv_nome = |{ lc_cobranca }{ lv_nome }|.
      ELSEIF ls_reguh-rzawe CA gc_forma_pagto-riscosacado.
        lv_nome = |{ lc_pagto }{ lv_nome }|.
      ELSE.
        lv_msg = TEXT-e02.
        REPLACE lc_msg_variable IN lv_msg WITH ls_reguh-rzawe.
        set_log_proc( is_reguh = ls_reguh " Dados de pagamento do programa de pagamento
                      iv_dir   = lv_dir "Diretório salvo
                      iv_msgty = if_xo_const_message=>error " Tipo de mensagem
                      iv_msg   = lv_msg ). " Mensagem de processamento
        RETURN.
      ENDIF.
      "Verifica se a ultima posição do diretório é uma '\'.
      lv_pos = strlen( lv_dir ) - 1.
      IF lv_dir+lv_pos CA lc_separador_dir.
        lv_dir = |{ lv_dir }{ lv_nome }|.
      ELSE.
*        lv_dir = |{ lv_dir }//{ lv_nome }|.
        lv_dir = |{ lv_dir }{ lc_separador_dir }{ lv_nome }|.
      ENDIF.
      "Busca a linha que identifica o arquivo para o registro processado.
      SELECT
        zbukr,
        banks,
        laufd,
        laufi,
        xvorl,
        dtkey,
        lfdnr,
        waers,
        rbetr,
        renum,
        dtfor,
        tsnam,
        tsdat,
        tstim,
        tsusr,
        dwnam,
        dwdat,
        dwtim,
        dwusr,
        kadat,
        katim,
        kausr,
        report,
        fsnam,
        usrex,
        edinum,
        grpno,
        dttyp,
        guid,
        saprl,
        codepage,
        status
        FROM zi_fi_admin_temse
       WHERE zbukr EQ @ls_reguh-zbukr
         AND banks EQ @ls_reguh-ubnks
         AND laufd EQ @ls_reguh-laufd
         AND laufi EQ @ls_reguh-laufi
         AND dtkey EQ @ls_reguh-hbkid
         AND lfdnr EQ @lc_first_seq
        INTO CORRESPONDING FIELDS OF TABLE @lt_regut.

      IF sy-subrc EQ 0.
        READ TABLE lt_regut INTO ls_regut INDEX 1.
      ELSE.
        set_log_proc( is_reguh = ls_reguh " Dados de pagamento do programa de pagamento
                      iv_dir   = lv_dir "Diretório salvo
                      iv_msgty = if_xo_const_message=>error " Tipo de mensagem
                      iv_msg   = TEXT-e05 ). " Registro não encontrado na REGUT.
        RETURN.
      ENDIF.

      "Recede o conteúdo do arquivo
      DATA(lv_file) = get_arq_remessa( is_regut = ls_regut ).

      "Grava o arquivo na pasta de destino.
*      OPEN DATASET lv_dir FOR OUTPUT IN BINARY MODE.
      OPEN DATASET lv_dir FOR OUTPUT IN TEXT MODE ENCODING UTF-8.

      IF sy-subrc EQ 0.
        "Tranfere os dados do arquivo gerado no SAP para a pasta da VAN.
        TRANSFER lv_file TO lv_dir NO END OF LINE.
        CLOSE DATASET lv_dir.
        "Verifica se o arquivo foi gravado com sucesso.
        IF sy-subrc EQ 0.
          set_log_proc( is_reguh = ls_reguh " Dados de pagamento do programa de pagamento
                        iv_dir   = lv_dir "Diretório salvo
                        iv_msgty = if_xo_const_message=>success " Tipo de mensagem
                        iv_msg   = TEXT-s01 ). " Arquivo gravado com sucesso.

          UPDATE regut SET status = '010'
          WHERE zbukr = @ls_regut-zbukr
            AND laufd = @ls_regut-laufd
            AND laufi = @ls_regut-laufi.
        ELSE.
          set_log_proc( is_reguh = ls_reguh " Dados de pagamento do programa de pagamento
                        iv_dir   = lv_dir "Diretório salvo
                        iv_msgty = if_xo_const_message=>error " Tipo de mensagem
                        iv_msg   = TEXT-e03 ). " Falha ao gravar o arquivo (Transfer OpenDataset).
        ENDIF.
      ELSE.
        set_log_proc( is_reguh = ls_reguh " Dados de pagamento do programa de pagamento
                      iv_dir   = lv_dir "Diretório salvo
                      iv_msgty = if_xo_const_message=>error " Tipo de mensagem
                      iv_msg   = TEXT-e01 ). " Falha ao gravar o arquivo (abertura file).
      ENDIF.
    ELSE.
      set_log_proc( is_reguh = ls_reguh " Dados de pagamento do programa de pagamento
                    iv_dir   = lv_dir "Diretório salvo
                    iv_msgty = if_xo_const_message=>error " Tipo de mensagem
                    iv_msg   = TEXT-e04 ). " Falta configuração de diretório para empresa e tipo de arquivo.
    ENDIF.


  ENDMETHOD.


  METHOD check_authority_empresa.


    CONSTANTS:
      BEGIN OF lc_auth_check,
        object(10) TYPE c VALUE 'F_BKPF_BUK',
        bukrs(5)   TYPE c VALUE 'BUKRS',
        actvt(5)   TYPE c VALUE 'ACTVT',
      END OF lc_auth_check.

    DATA: lt_range TYPE fagl_range_t_bukrs, "Range para empresas
          lt_bukrs TYPE TABLE OF bukrs. "Lista com todas as empresas

    IF NOT iv_bukrs IS INITIAL.
      APPEND VALUE #( sign = rsmds_c_sign-including option = rsmds_c_option-equal low = iv_bukrs ) TO lt_range.
    ELSEIF NOT it_bukrs IS INITIAL.
      lt_range = it_bukrs.
    ENDIF.
    "Buscam as empresas informadas.
    SELECT bukrs INTO TABLE lt_bukrs FROM t001 WHERE bukrs IN lt_range.
    "Percorrem todas as empresas retornadas para verificação de perfil.
    LOOP AT lt_bukrs ASSIGNING FIELD-SYMBOL(<fs_bukrs>).
      "Verifica se o usuário tem autorização para exibir dados da empresa
      AUTHORITY-CHECK OBJECT lc_auth_check-object
        ID lc_auth_check-bukrs FIELD <fs_bukrs>
        ID lc_auth_check-actvt FIELD me->gc_activ_display.

      IF sy-subrc IS NOT INITIAL.

        RAISE EXCEPTION TYPE zcxfi_autobanc_import
          EXPORTING
            iv_textid = zcxfi_autobanc_import=>gc_auth_check_empresa.

      ENDIF.
    ENDLOOP.



  ENDMETHOD.


  METHOD get_arq_remessa.

    CLEAR: rv_file.

    CALL FUNCTION 'ZFMFI_AUTBANC_GRAVA_ARQREMESSA'
      EXPORTING
        is_regut = is_regut
      IMPORTING
        ev_arq   = rv_file.

  ENDMETHOD.


  METHOD get_digit_account.

    DATA: lv_bankn  TYPE t012k-bankn,
          lv_bkont  TYPE t012k-bkont,
          lv_digit  TYPE t164a-art,
          lv_digit2 TYPE t164a-art.

    CLEAR: rv_digit, lv_bankn, lv_bkont, lv_digit.

    IF NOT iv_ubkon IS INITIAL.

      lv_bankn = iv_ubknt.
      lv_bkont = iv_ubkon.

      CALL FUNCTION 'READ_ACCOUNT_DATA'
        EXPORTING
          i_bankn = lv_bankn
          i_bkont = lv_bkont
        IMPORTING
          e_cntr2 = lv_digit
          e_cntr3 = lv_digit2.

      IF NOT lv_digit IS INITIAL.
        rv_digit = lv_digit.
      ELSE.
        rv_digit = lv_digit2.
      ENDIF.

    ENDIF.


  ENDMETHOD.


  METHOD set_log_proc.

    DATA: ls_proc TYPE ztfi_autbanc_prc.

    "Atualiza a data e hora do sistema.
    GET TIME STAMP FIELD DATA(lv_now).

    "Transfere os dados para a estrutura de processamento.
    MOVE-CORRESPONDING is_reguh TO ls_proc.
    "Informa o diretório gravado.
    ls_proc-diretorio = iv_dir.
    ls_proc-type = iv_msgty.
    ls_proc-message = iv_msg.
    "Informa dados administrativos do sistema.
    ls_proc-created_at = lv_now.
    ls_proc-created_by = sy-uname.
    ls_proc-last_changed_by = sy-uname.
    ls_proc-last_changed_at = lv_now.
    ls_proc-local_last_changed_at = lv_now.

    "Efetua a inclusão do registro na tabela de processamento.
    INSERT ztfi_autbanc_prc FROM ls_proc.
    IF sy-subrc EQ 0.
      rv_status = abap_true.
    ENDIF.

  ENDMETHOD.


  METHOD set_sequencial_banco.

    DATA: ls_seq TYPE ztfi_autbanc_seq.
    CLEAR: rv_status.

    "Atribui o novo sequencial na estrutura.
    ls_seq-banco = iv_banco.
    ls_seq-data  = iv_data.
    ls_seq-seq   = iv_seq.

    CASE iv_action.
      WHEN 1.
        "Insere um novo sequencial na tabela.
        INSERT ztfi_autbanc_seq FROM ls_seq.
      WHEN 2.
        "Verifica se o registros realmente existe na tabela, antes de efetuar uma modificação.
        SELECT COUNT(*) FROM ztfi_autbanc_seq WHERE banco = iv_banco AND data = iv_data.
        IF sy-subrc EQ 0.
          "Mofifica o sequencial existente na tabela.
          MODIFY ztfi_autbanc_seq FROM ls_seq.
        ENDIF.
    ENDCASE.

    IF sy-subrc EQ 0.
      rv_status = abap_true.
    ENDIF.

  ENDMETHOD.


  METHOD exec_proposal.

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


    WRITE:/ 'Forma de pagamento:'(003), 20 is_reguh-rzawe, 22 'Apenas execução de proposta:'(004), 51 is_reguh-xvorl.

    "Verifica se os tipos de pagamento NÃO exigem aprovação.
    IF is_reguh-rzawe CA '68' AND is_reguh-xvorl IS INITIAL.

      WRITE:/ 'Entrou para execução da classe de gravar arquivo automático FINNET'(005).
      WRITE:/ is_reguh-laufd, '|', is_reguh-laufi, '|', is_reguh-xvorl, '|', is_reguh-zbukr, '|', is_reguh-lifnr, '|', is_reguh-kunnr, '|', is_reguh-empfg, '|', is_reguh-vblnr.

      "Efetua a gravação do arquivo de remessa na pasta de saída para a VAN (FINNET).
      gravar_saida( is_reguh ).

    ENDIF.

  ENDMETHOD.
ENDCLASS.
