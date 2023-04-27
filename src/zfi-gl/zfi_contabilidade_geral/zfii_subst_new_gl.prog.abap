*&---------------------------------------------------------------------*
*& Include          ZFII_SUBST_NEW_GL
*&---------------------------------------------------------------------*

"Field symbols
FIELD-SYMBOLS: <fs_t_ACCIT_FI> TYPE accit_fi_tab,
               <fs_s_accit_fi> TYPE accit_fi,
               <fs_s_regup>    TYPE regup,
               <fs_v_ebeln>    TYPE ekko-ebeln.

"Range
DATA: lr_blart_trm            TYPE RANGE OF bkpf-blart,
      lr_bank_account         TYPE RANGE OF bseg-hkont,
      lr_document_type        TYPE RANGE OF bkpf-blart,
      lr_special_gl_indicator TYPE RANGE OF bseg-umskz.

"Variáveis
DATA: lv_ebeln TYPE ekko-ebeln.


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Selecionando os tipos de documentos do processo de TRM para       "
" validação posterior.                                              "
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

SELECT low
  FROM ztca_param_val
  INTO TABLE @DATA(lt_tp_doc)
  WHERE modulo = 'FI-GL'
    AND chave1 = 'NEW_GL'
    AND chave2 = 'TRM'
    AND chave3 = 'TIPODOCS'.

lr_blart_trm = VALUE #( FOR ls_tp_doc IN lt_tp_doc ( low    = ls_tp_doc-low
                                                     sign   = 'I'
                                                     option = 'EQ' ) ).


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Selecionando o range de contas de banco para validação posterior  "
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

SELECT low, high
  FROM ztca_param_val
  INTO TABLE @DATA(lt_bank_accounts)
  WHERE modulo = 'FI-GL'
    AND chave1 = 'NEW_GL'
    AND chave2 = 'BANCOS'
    AND chave3 = 'CONTAS'.

lr_bank_account = VALUE #( FOR ls_bank_accounts IN lt_bank_accounts ( low    = ls_bank_accounts-low
                                                                      high   = ls_bank_accounts-high
                                                                      sign   = 'I'
                                                                      option = 'BT' ) ).

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Selecionando o range de tipos de documento que podem ficar com a  "
" divisão                                                           "
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

SELECT low, high
  FROM ztca_param_val
  INTO TABLE @DATA(lt_document_type)
  WHERE modulo = 'FI-GL'
    AND chave1 = 'NEW_GL'
    AND chave2 = 'DIVISAO'
    AND chave3 = 'TIPODOCS'.

lr_document_type = VALUE #( FOR ls_document_type IN lt_document_type ( low    = ls_document_type-low
                                                                       sign   = 'I'
                                                                       option = 'EQ' ) ).

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Selecionando o range de código de razão especial que podem ficar  "
" com o campo de divisão preenchido.                                "
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

SELECT low, high
  FROM ztca_param_val
  INTO TABLE @DATA(lt_special_gl_indicator)
  WHERE modulo = 'FI-GL'
    AND chave1 = 'NEW_GL'
    AND chave2 = 'DIVISAO'
    AND chave3 = 'CODRZESP'.

lr_special_gl_indicator = VALUE #( FOR ls_special_gl_indicator IN lt_special_gl_indicator
                                    ( low    = ls_special_gl_indicator-low
                                      sign   = 'I'
                                      option = 'EQ' ) ).

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Checando se o tipo de conta é de Fornecedor ou Cliente. Caso sim, "
" as lógicas de preenchimento do campo Divisão não serão feitas.    "
"                                                                   "
" No caso de ser uma conta diferente de Fornecedor ou cliente,      "
" a EXIT deverá fazer todas as regras de preenchimento automático   "
" para os campos Divisão, Local de Negócio, Centro de Lucro e Seg-  "
" mento. Este último, somente para cenários de TRM.                 "
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

IF bseg-koart = 'D' OR bseg-koart = 'K'.
  "Limpando campo Divisão
  IF bseg-umskz NOT IN lr_special_gl_indicator AND lr_special_gl_indicator IS NOT INITIAL and
     bkpf-blart NOT IN lr_document_type AND lr_document_type IS NOT INITIAL.
    CLEAR bseg-gsber.
  ENDIF.

  "Veririficando se processo é de TRM
  IF lr_blart_trm IS NOT INITIAL AND bkpf-blart IN lr_blart_trm.

    "Preenchendo campo Filial em caso do mesmo estar vazio
    IF bseg-bupla IS INITIAL.
      SELECT SINGLE bupla
        FROM vtbfha
        INTO bseg-bupla
        WHERE bukrs = bkpf-bukrs
          AND rfha  = bseg-vertn.
    ENDIF.

    "Preenchendo campo Centro de Lucro em caso do mesmo estar vazio
    IF bseg-prctr IS INITIAL.
      "Obtendo referência classificação contábil
      SELECT SINGLE aa_ref
        FROM tracv_poscontext
        INTO @DATA(lv_aa_ref)
        WHERE deal_number = @bseg-vertn.

      IF sy-subrc IS INITIAL.
        SELECT SINGLE kostl
          FROM tracc_addaccdata
          INTO @DATA(lv_kostl)
          WHERE company_code = @bkpf-bukrs
            AND aa_ref       = @lv_aa_ref.

        IF sy-subrc IS INITIAL.
          SELECT SINGLE prctr
            FROM csks
            INTO @bseg-prctr
            WHERE kokrs = 'AC3C'
              AND kostl = @lv_kostl
              AND datbi = '99991231'.
        ENDIF.
      ENDIF.
    ENDIF.

    "Preenchendo campo Segmento em caso do mesmo estar vazio
    IF bseg-segment IS INITIAL.
      SELECT SINGLE segment
        FROM cepc
        INTO @bseg-segment
        WHERE kokrs = 'AC3C'
          AND prctr = @bseg-prctr
          AND datbi = '99991231'.
    ENDIF.
  ELSE.
    "Obtendo os dados do processo (F110)
    ASSIGN ('(SAPF110S)REGUP') TO <fs_s_regup>.

    IF <fs_s_regup> IS ASSIGNED.
      bseg-bupla = <fs_s_regup>-bupla.
    ENDIF.
  ENDIF.

ELSE.

  "Veririficando se processo é de TRM
  IF lr_blart_trm IS NOT INITIAL AND bkpf-blart IN lr_blart_trm.
    IF bseg-gsber IS INITIAL.
      IF bseg-vertn IS NOT INITIAL.
        SELECT SINGLE bupla
          FROM vtbfha
          INTO @DATA(lv_bupla)
          WHERE bukrs = @bkpf-bukrs
          AND   rfha  = @bseg-vertn.

        IF sy-subrc IS INITIAL.
          SELECT SINGLE gsber
            FROM ztfi_param_rm
            INTO @bseg-gsber
            WHERE bukrs   EQ @bkpf-bukrs
              AND bupla   EQ @lv_bupla
              AND zmatriz EQ @abap_true.

          "Preenchendo bupla em caso do campo estar em branco
          IF bseg-bupla IS INITIAL.
            bseg-bupla = lv_bupla.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.

    IF bseg-prctr IS INITIAL.
      "Obtendo referência classificação contábil
      SELECT SINGLE aa_ref
        FROM tracv_poscontext
        INTO lv_aa_ref
        WHERE deal_number = bseg-vertn.

      IF sy-subrc IS INITIAL.
        SELECT SINGLE kostl
          FROM tracc_addaccdata
          INTO lv_kostl
          WHERE company_code = bkpf-bukrs
            AND aa_ref       = lv_aa_ref.

        IF sy-subrc IS INITIAL.
          SELECT SINGLE prctr
            FROM csks
            INTO @bseg-prctr
            WHERE kokrs = 'AC3C'
              AND kostl = @lv_kostl
              AND datbi = '99991231'.
        ENDIF.
      ENDIF.
    ENDIF.

    IF bseg-segment IS INITIAL.
      SELECT SINGLE segment
        FROM cepc
        INTO @bseg-segment
        WHERE kokrs = 'AC3C'
          AND prctr = @bseg-prctr
          AND datbi = '99991231'.
    ENDIF.
  ELSEIF bseg-gsber IS INITIAL. " AND bseg-bupla IS INITIAL.
    "Obtendo os dados do processo
    ASSIGN ('(SAPLFACI)ACCIT_FI') TO <fs_s_accit_fi>.
    ASSIGN ('(SAPLFACI)ACCIT_FI[]') TO <fs_t_accit_fi>.

    "Verificando centro na pilha de processamento
    IF <fs_s_accit_fi> IS ASSIGNED.
      "Preenchimento campo BSEG-GSBER
      IF <fs_s_accit_fi>-werks IS NOT INITIAL.
        SELECT SINGLE gsber
          FROM t134g
          INTO @bseg-gsber
          WHERE werks = @<fs_s_accit_fi>-werks.
      ELSEIF <fs_t_accit_fi> IS ASSIGNED.
        "Procurando na pilha o primeiro registro com o GSBER preenchido
        LOOP AT <fs_t_accit_fi> INTO DATA(ls_accit_fi) WHERE gsber IS NOT INITIAL.
          EXIT.
        ENDLOOP.

        "Caso encontrar, será definido este GSBER no item
        IF sy-subrc IS INITIAL.
          bseg-gsber = ls_accit_fi-gsber.
        ELSE.
          SELECT SINGLE gsber
            FROM ztfi_param_rm
            INTO @bseg-gsber
            WHERE bukrs   EQ @bkpf-bukrs
              AND zmatriz EQ @abap_true.
        ENDIF.
      ELSE.
        SELECT SINGLE gsber
          FROM ztfi_param_rm
          INTO @bseg-gsber
          WHERE bukrs   EQ @bkpf-bukrs
            AND zmatriz EQ @abap_true.
      ENDIF.
    ELSE.
      "Obtendo os dados do processo (F110)
      ASSIGN ('(SAPF110S)REGUP') TO <fs_s_regup>.

      IF <fs_s_regup> IS ASSIGNED.
        bseg-bupla = <fs_s_regup>-bupla.
        bseg-gsber = <fs_s_regup>-gsber.
      ENDIF.

      IF NOT bseg-gsber IS INITIAL AND
         bseg-bupla IS INITIAL.
        SELECT SINGLE bupla
          FROM ztfi_param_rm
          INTO @bseg-bupla
          WHERE bukrs EQ @bkpf-bukrs
            AND gsber EQ @bseg-gsber.
      ELSEIF NOT bseg-bupla IS INITIAL AND
                 bseg-gsber IS INITIAL.
        SELECT SINGLE gsber
          FROM ztfi_param_rm
          INTO @bseg-gsber
          WHERE bukrs   EQ @bkpf-bukrs
            AND bupla   EQ @bseg-bupla
            AND zmatriz EQ @abap_true.
        IF sy-subrc NE 0.
          SELECT SINGLE gsber
            FROM ztfi_param_rm
            INTO @bseg-gsber
            WHERE bukrs   EQ @bkpf-bukrs
              AND bupla   EQ @bseg-bupla
              AND zmatriz EQ @abap_false.
        ENDIF.
      ENDIF.

      "Tratamento para contas de banco caso o BSEG-GSBER não esteja preenchido
      IF bseg-gsber IS INITIAL AND bseg-hkont IN lr_bank_account.
        SELECT SINGLE gsber
          FROM ztfi_param_rm
          INTO @bseg-gsber
          WHERE bukrs   EQ @bkpf-bukrs
            AND zmatriz EQ @abap_true.
      ENDIF.
    ENDIF.
  ENDIF.
ENDIF.

"Preenchimento campo BSEG-BUPLA
IF bseg-gsber IS NOT INITIAL AND bseg-bupla IS INITIAL.
  SELECT SINGLE bupla
    FROM ztfi_param_rm
    INTO @bseg-bupla
    WHERE bukrs = @bkpf-bukrs
      AND gsber = @bseg-gsber.
ENDIF.

"Preenchimento campo BSEG-PRCTR
IF bseg-prctr IS INITIAL.
  SELECT SINGLE centro_lucro
    FROM ztfi_clucro
    INTO @bseg-prctr
    WHERE empresa        = @bkpf-bukrs
      AND conta_contabil = @bseg-hkont
      AND divisao        = @bseg-gsber.
ENDIF.
