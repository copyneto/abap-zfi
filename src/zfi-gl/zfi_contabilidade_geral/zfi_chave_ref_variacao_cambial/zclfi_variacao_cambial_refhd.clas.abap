"!<p><h2>Referência na variação cambial</h2></p> <br/>
"! Esta classe preenche a referência no cabeçalho da variação cambial <br/> <br/>
"!<p><strong>Autor:</strong> Anderson Miazato</p>
"!<p><strong>Data:</strong> 27 de dez de 2021</p>
CLASS zclfi_variacao_cambial_refhd DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    CONSTANTS:
      "! Parâmetro: Contas razão válidas para o preenchimento da referência
      BEGIN OF gc_range_contas_razao_validas,
        modulo TYPE ztca_param_par-modulo VALUE 'FI-GL',
        chave1 TYPE ztca_param_par-chave1 VALUE 'FAGL_FCV',
        chave2 TYPE ztca_param_par-chave2 VALUE 'CONTAS_RAZAO',
      END OF gc_range_contas_razao_validas.

    "! Dados do documento em avaliação
    TYPES BEGIN OF ty_post_task.
    TYPES   taskname            TYPE progname.
    TYPES   str_ccode_method    TYPE fagl_fc_s_method.
    TYPES   tab_oi_upd          TYPE fagl_fc_t_oi_upd.
    TYPES   tab_lgoi_upd        TYPE fagl_fc_t_oi_upd.
    TYPES   tab_bal_upd         TYPE fagl_fc_t_bal_upd.
    TYPES END OF ty_post_task.

    "! Categ. tabela Documento em avaliação
    TYPES ty_post_task_t TYPE SORTED TABLE OF ty_post_task
                       WITH NON-UNIQUE KEY taskname.

    METHODS:
      "! Inicializa o objeto
      "! @parameter is_post_db    | Novo documento - Info gerais
      constructor
        IMPORTING
          is_post_db TYPE fagl_fc_post,

      "! Preenche chave referência no cabeçalho do doc. variação cambial
      "! @parameter cs_post_batch | Novo documento - BI Estrutura
      "! @parameter ct_doc_header | Novo documento - BKPF
      "! @parameter ct_post_batch | Novo documento - BI BKPF
      execute
        CHANGING
          cs_post_batch TYPE ftpost
          ct_doc_header TYPE bkpf_t
          ct_post_batch TYPE fagl_t_ftpost.

  PROTECTED SECTION.
  PRIVATE SECTION.
    CONSTANTS:
      "! Referência. 2 do cabeçalho do doc. de variação cambial
      gc_campo_chave_ref2hd TYPE string VALUE 'BKPF-XREF2_HD'.

    DATA:
      "! Documento em avaliação
      gt_post_task TYPE ty_post_task_t.

    DATA:
      "! Dados do documento destino
      gs_post_db    TYPE fagl_fc_post,
      "! Dados do documento origem
      gs_doc_origem TYPE fagl_fc_s_oi_upd.


    METHODS:

      "! Preenche chave na avaliação por clientes
      "! @parameter cs_post_batch | Novo documento - BI Estrutura
      "! @parameter ct_doc_header | Novo documento - BKPF
      "! @parameter ct_post_batch | Novo documento - BI BKPF
      tratar_aval_cliente
        CHANGING
          cs_post_batch TYPE ftpost
          ct_doc_header TYPE bkpf_t
          ct_post_batch TYPE fagl_t_ftpost,

      "! Preenche chave na avaliação por contas razão
      "! @parameter cs_post_batch | Novo documento - BI Estrutura
      "! @parameter ct_doc_header | Novo documento - BKPF
      "! @parameter ct_post_batch | Novo documento - BI BKPF
      tratar_conta_razao
        CHANGING
          cs_post_batch TYPE ftpost
          ct_doc_header TYPE bkpf_t
          ct_post_batch TYPE fagl_t_ftpost.


ENDCLASS.



CLASS ZCLFI_VARIACAO_CAMBIAL_REFHD IMPLEMENTATION.


  METHOD execute.

    FIELD-SYMBOLS:
      <fs_flag_conta_razao>  TYPE xfeld,
      <fs_flag_aval_cliente> TYPE xfeld.

    DATA:
      lt_tab_oi_upd TYPE fagl_fc_t_oi_upd.

    CONSTANTS:
      lc_flag_cliente     TYPE string VALUE '(FAGL_FCV)P_AROI',
      lc_flag_conta_Razao TYPE string VALUE '(FAGL_FCV)P_GLOI'.

    IF me->gs_doc_origem IS INITIAL.
      RETURN.
    ENDIF.

    IF NOT line_exists( ct_doc_header[ 1 ] ).
      RETURN.
    ENDIF.

    ASSIGN (lc_flag_cliente) TO <fs_flag_aval_cliente>.
    IF <fs_flag_aval_cliente> IS ASSIGNED
      AND <fs_flag_aval_cliente> EQ abap_true.

      me->tratar_aval_cliente( CHANGING cs_post_batch = cs_post_batch
                                        ct_doc_header = ct_doc_header
                                        ct_post_batch = ct_post_batch
                                       ).
      RETURN.

    ENDIF.

    ASSIGN (lc_flag_conta_razao) TO <fs_flag_conta_razao>.
    IF <fs_flag_conta_razao> IS ASSIGNED
        AND <fs_flag_conta_razao> EQ abap_true.

      me->tratar_conta_razao( CHANGING cs_post_batch = cs_post_batch
                                       ct_doc_header = ct_doc_header
                                       ct_post_batch = ct_post_batch
                                      ).
      RETURN.
    ENDIF.

  ENDMETHOD.


  METHOD tratar_aval_cliente.

    SELECT SINGLE
        bukrs,
        belnr,
        gjahr,
        xref2_hd
    FROM p_bkpf_com
    WHERE bukrs     EQ @me->gs_doc_origem-ccode
        AND belnr   EQ @me->gs_doc_origem-doc_number
        AND gjahr   EQ @me->gs_doc_origem-fiscal_year
    INTO @DATA(ls_bkpf).

    IF sy-subrc NE 0 OR ls_bkpf-xref2_hd IS INITIAL.
      RETURN.
    ENDIF.

    ASSIGN ct_doc_header[ 1 ] TO FIELD-SYMBOL(<fs_doc_header>).
    IF <fs_doc_header> IS ASSIGNED.
      <fs_doc_header>-xref2_hd = ls_bkpf-xref2_hd.
    ENDIF.

    cs_post_batch-fnam = gc_campo_chave_ref2hd.
    cs_post_batch-fval = ls_bkpf-xref2_hd.
    APPEND cs_post_batch TO ct_post_batch.


  ENDMETHOD.


  METHOD tratar_conta_razao.

    DATA:
      lr_contas_validas TYPE RANGE OF bseg-hkont.

    DATA(lo_param) = zclca_tabela_parametros=>get_instance( ). " CHANGE - LSCHEPP - 20.07.2023

    TRY.
        lo_param->m_get_range(
          EXPORTING
            iv_modulo = gc_range_contas_razao_validas-modulo
            iv_chave1 = gc_range_contas_razao_validas-chave1
            iv_chave2 = gc_range_contas_razao_validas-chave2
          IMPORTING
            et_range  = lr_contas_validas
        ).

      CATCH zcxca_tabela_parametros.
        RETURN.
    ENDTRY.

    IF me->gs_post_db-gl_account NOT IN lr_contas_validas.
      RETURN.
    ENDIF.

    SELECT SINGLE
        bukrs,
        belnr,
        gjahr,
        buzei,
        zuonr
    FROM p_bseg_com1
    WHERE bukrs EQ @me->gs_doc_origem-ccode
    AND belnr EQ @me->gs_doc_origem-doc_number
    AND gjahr  EQ @me->gs_doc_origem-fiscal_year
    AND buzei EQ  @me->gs_doc_origem-doc_line
    INTO @DATA(ls_bseg).

    IF sy-subrc NE 0 OR ls_bseg-zuonr IS INITIAL.
      RETURN.
    ENDIF.

    ASSIGN ct_doc_header[ 1 ] TO FIELD-SYMBOL(<fs_doc_header>).
    IF <fs_doc_header> IS ASSIGNED.
      <fs_doc_header>-xref2_hd = ls_bseg-zuonr.
    ENDIF.

    cs_post_batch-fnam = gc_campo_chave_ref2hd.
    cs_post_batch-fval = ls_bseg-zuonr.
    APPEND cs_post_batch TO ct_post_batch.

  ENDMETHOD.


  METHOD constructor.

    CONSTANTS:
       lc_post_task       TYPE string VALUE '(FAGL_FCV)GT_POST_TASK[]'.

    FIELD-SYMBOLS:
          <fs_post_task>        TYPE ANY TABLE.

    me->gs_post_db = is_post_db.

    ASSIGN (lc_post_task) TO <fs_post_task>.
    IF <fs_post_task> IS ASSIGNED.

      me->gt_post_task = <fs_post_task>.

      DATA(ls_post_task) = me->gt_post_task[ 1 ].

      IF line_exists( ls_post_task-tab_oi_upd[ 1 ] ).
        me->gs_doc_origem = ls_post_task-tab_oi_upd[ 1 ].
      ENDIF.

    ENDIF.

  ENDMETHOD.
ENDCLASS.
