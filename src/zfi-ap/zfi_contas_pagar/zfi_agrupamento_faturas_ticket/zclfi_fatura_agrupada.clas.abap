"!<p><h2>Fatura agrupada</h2></p> <br/>
"! Esta classe atualiza as tabelas de agrupamento após a conclusão do processo<br/> <br/>
"!<p><strong>Autor:</strong> Anderson Miazato</p>
"!<p><strong>Data:</strong> 22 de dez de 2021</p>
CLASS zclfi_fatura_agrupada DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    CONSTANTS:
      "! Classe de mensagem
      gc_msgid TYPE sy-msgid VALUE 'ZFI_AGRUPA_FATURAS',

      "! Moeda: R$
      gc_reais TYPE waers VALUE 'BRL',

      "! Status de processamento do Arquivo
      BEGIN OF gc_status_arq,
        pendente        TYPE ztfi_agrupfatura-status_proc VALUE '0',
        nao_processavel TYPE ztfi_agrupfatura-status_proc VALUE '1',
        disponivel      TYPE ztfi_agrupfatura-status_proc VALUE '2',
        agrupado        TYPE ztfi_agrupfatura-status_proc VALUE '3',
        erro_agrupar    TYPE ztfi_agrupfatura-status_proc VALUE '4',
      END OF gc_status_arq,

      "! Status de processamento do Item
      BEGIN OF gc_status_proc,
        pendente TYPE ztfi_agruplinhas-status_proc VALUE '0',
        erro     TYPE ztfi_agruplinhas-status_proc VALUE '1',
        aviso    TYPE ztfi_agruplinhas-status_proc VALUE '2',
        ok       TYPE ztfi_agruplinhas-status_proc VALUE '3',
      END OF gc_status_proc.

    TYPES:
      "! Categ. tabela para arquivo de faturas
      ty_arquivo_t   TYPE STANDARD TABLE OF ztfi_agrupfatura WITH DEFAULT KEY,
      "! Categ. tabela para linhas do arquivo de faturas
      ty_arqlinhas_t TYPE STANDARD TABLE OF ztfi_agruplinhas WITH DEFAULT KEY.

    METHODS:
      "! Inicializa a instância
      "! @parameter is_campos_popup      | Campos do popup de agrupamento
      "! @parameter iv_idarquivo         | Id do arquivo a ser atualizado
      "! @parameter iv_faturaagrupada    | Fatura agrupada
      "! @parameter iv_exercicioagrupado | Exercício da fatura agrupada
      constructor
        IMPORTING
          is_campos_popup      TYPE zi_fi_agrupa_faturas_popup
          iv_idarquivo         TYPE ztfi_agrupfatura-id_arquivo
          iv_faturaagrupada    TYPE ztfi_agruplinhas-fatura_agrupada
          iv_exercicioagrupado TYPE ztfi_agruplinhas-exercicio_agrupado,

      "! Atualiza dados após agrupamento
      "! @parameter it_msg | Mensagens da bapi
      atualiza
        IMPORTING
          it_msg TYPE bapiret2_tab.

  PROTECTED SECTION.
  PRIVATE SECTION.

    TYPES:
      "! Dados para atualização
      BEGIN OF ty_atualizacao,
        fornagrupador     TYPE ztfi_agruplinhas-forn_agrupador,
        faturaagrupada    TYPE ztfi_agruplinhas-fatura_agrupada,
        refagrupada       TYPE ztfi_agruplinhas-ref_agrupada,
        exercicioagrupado TYPE ztfi_agruplinhas-exercicio_agrupado,
        vencimento        TYPE ztfi_agrupfatura-vencimento,
        desconto          TYPE ztfi_agrupfatura-desconto,
        currency          TYPE ztfi_agrupfatura-waers,
      END OF ty_atualizacao.

    DATA:
      "! Arquivo de faturas
      gt_arquivo     TYPE ty_arquivo_t,
      "! Linhas do arquivo de faturas
      gt_arqlinhas   TYPE ty_arqlinhas_t,
      "! Dados para atualização
      gs_atualizacao TYPE ty_atualizacao.

    METHODS:

      "! Busca mensagem para exiibção na linha do arquivo
      "! @parameter it_msg    | Mensagens da bapi de agrupamento
      "! @parameter rv_result | Mensagem de processamento
      busca_msg
        IMPORTING
                  it_msg           TYPE bapiret2_tab
        RETURNING VALUE(rv_result) TYPE ztfi_agruplinhas-msg,

      "! Seleciona dados do arquivo de faturas
      "! @parameter iv_idarquivo | Id do arquivo de faturas
      "! @parameter rt_result | Dados do arquivo de faturas
      seleciona_arquivo
        IMPORTING
                  iv_idarquivo     TYPE ztfi_agrupfatura-id_arquivo
        RETURNING VALUE(rt_result) TYPE ty_arquivo_t,

      "! Seleciona linhas do arquivo de faturas
      "! @parameter iv_idarquivo | Id do arquivo de faturas
      "! @parameter rt_result | Linhas do arquivo de faturas
      seleciona_arquivo_linhas
        IMPORTING
                  iv_idarquivo     TYPE ztfi_agrupfatura-id_arquivo
        RETURNING VALUE(rt_result) TYPE ty_arqlinhas_t.

ENDCLASS.



CLASS zclfi_fatura_agrupada IMPLEMENTATION.

  METHOD constructor.

    me->seleciona_arquivo( iv_idarquivo ).

    me->seleciona_arquivo_linhas( iv_idarquivo ).

    me->gs_atualizacao = VALUE #(
        fornagrupador = is_campos_popup-selfornagrupa
        faturaagrupada = iv_faturaagrupada
        refagrupada    = is_campos_popup-selreference
        exercicioagrupado = iv_exercicioagrupado
        vencimento = is_campos_popup-selduedate
        desconto = is_campos_popup-seldesconto
        currency = COND #( WHEN is_campos_popup-selcurrency IS NOT INITIAL
                                THEN is_campos_popup-selcurrency
                           ELSE gc_reais )
    ).

  ENDMETHOD.

  METHOD seleciona_arquivo.

    SELECT
        id_arquivo,
        arquivo,
        data,
        status_proc,
        created_by,
        created_at,
        last_changed_by,
        last_changed_at,
        local_last_changed_at
    FROM ztfi_agrupfatura
    WHERE id_arquivo EQ @iv_idarquivo
    INTO CORRESPONDING FIELDS OF TABLE @me->gt_arquivo.

  ENDMETHOD.

  METHOD seleciona_arquivo_linhas.

    SELECT
        id_arquivo,
        id,
        bukrs,
        lifnr,
        xblnr1,
        arq_data,
        tipo_nf,
        chave_acesso,
        cnpj,
        zfbdt,
        status_proc,
        arq_dmbtr,
        doc_dmbtr,
        waers,
        belnr,
        gjahr,
        buzei,
        arq_bldat,
        doc_bldat,
        bupla,
        zuonr,
        sgtxt,
        prctr,
        msg,
        forn_agrupador,
        fatura_agrupada,
        ref_agrupada,
        created_by,
        created_at,
        last_changed_by,
        last_changed_at,
        local_last_changed_at
    FROM ztfi_agruplinhas
    WHERE id_arquivo EQ @iv_idarquivo
    INTO CORRESPONDING FIELDS OF TABLE @me->gt_arqlinhas.

  ENDMETHOD.

  METHOD atualiza.

    DATA(lt_msg) = it_msg.
    SORT lt_msg BY type.

    READ TABLE me->gt_arquivo ASSIGNING FIELD-SYMBOL(<fs_arquivo>) INDEX 1.

    IF sy-subrc EQ 0.

      <fs_arquivo>-status_proc = COND #( WHEN me->gs_atualizacao-faturaagrupada IS INITIAL
                                            THEN gc_status_arq-erro_agrupar
                                            ELSE gc_status_arq-agrupado ).

      <fs_arquivo>-forn_agrupador = me->gs_Atualizacao-fornagrupador.
      <fs_arquivo>-ref_agrupada = me->gs_atualizacao-refagrupada.
      <fs_arquivo>-vencimento = me->gs_atualizacao-vencimento.
      <fs_arquivo>-desconto = me->gs_atualizacao-desconto.
      <fs_arquivo>-waers = me->gs_atualizacao-currency.

    ENDIF.

    LOOP AT me->gt_arqlinhas ASSIGNING FIELD-SYMBOL(<fs_arqlinhas>).

      <fs_arqlinhas>-fatura_agrupada    = me->gs_atualizacao-faturaagrupada.
      <fs_arqlinhas>-forn_agrupador     = me->gs_Atualizacao-fornagrupador.
      <fs_arqlinhas>-ref_agrupada       = me->gs_atualizacao-refagrupada.
      <fs_arqlinhas>-exercicio_agrupado = me->gs_atualizacao-exercicioagrupado.

      <fs_arqlinhas>-status_proc = COND #( WHEN me->gs_atualizacao-faturaagrupada IS INITIAL
                                            THEN gc_status_proc-erro
                                            ELSE gc_status_proc-ok ).

      <fs_arqlinhas>-msg = me->busca_msg( lt_msg ).

    ENDLOOP.

    IF me->gt_arquivo IS NOT INITIAL.
      MODIFY ztfi_agrupfatura FROM TABLE me->gt_arquivo.
    ENDIF.

    IF me->gt_arqlinhas IS NOT INITIAL.
      MODIFY ztfi_agruplinhas FROM TABLE me->gt_arqlinhas.
    ENDIF.

  ENDMETHOD.

  METHOD busca_msg.

    " Busca mensagem de erro
    READ TABLE it_msg ASSIGNING FIELD-SYMBOL(<Fs_msg>)
        WITH KEY type = if_xo_const_message=>error
        BINARY SEARCH.
    IF sy-subrc EQ 0.

      IF <fs_msg>-message IS INITIAL.

        MESSAGE ID <fs_msg>-id TYPE if_xo_const_message=>error NUMBER <fs_msg>-number
            WITH <fs_msg>-message_v1 <fs_msg>-message_v2 <fs_msg>-message_v3 <fs_msg>-message_v4
            INTO rv_result.

      ELSE.

        rv_result = <fs_msg>-message.

      ENDIF.

      RETURN.

    ENDIF.

    IF me->gs_atualizacao-faturaagrupada IS INITIAL.
      " Se não houver mensagem de erro, mas o campo fatura agrupada está em branco, envia mensagem de erro no agrupamento
      MESSAGE ID gc_msgid TYPE if_xo_const_message=>success NUMBER 017
          INTO rv_result.

    ELSE.

      " Se não houve erro, envia mensagem para agrupamento concluído com sucesso
      MESSAGE ID gc_msgid TYPE if_xo_const_message=>success NUMBER 015
          INTO rv_result.
    ENDIF.
  ENDMETHOD.

ENDCLASS.
