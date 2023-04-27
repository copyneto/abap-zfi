"!<p><h2>Tratamento do arquivo de agrupamento de faturas</h2></p> <br/>
"! Esta classe é utilizada para carga do arquivo de agrupamento de faturas <br/> <br/>
"!<p><strong>Autor:</strong> Anderson Miazato</p>
"!<p><strong>Data:</strong> 13 de dez de 2021</p>
CLASS zclfi_agrupa_faturas_arquivo DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    CONSTANTS:
       "! Classe de mensagem
       gc_msg_id TYPE sy-msgid VALUE 'ZFI_AGRUPA_FATURAS'.

    CONSTANTS:
      "! Status de processamento do Arquivo
      BEGIN OF gc_status_arquivo,
        pendente        TYPE ztfi_agrupfatura-status_proc VALUE '0',
        nao_processavel TYPE ztfi_agrupfatura-status_proc VALUE '1',
        disponivel      TYPE ztfi_agrupfatura-status_proc VALUE '2',
        agrupado        TYPE ztfi_agrupfatura-status_proc VALUE '3',
        erro_agrupar    TYPE ztfi_agrupfatura-status_proc VALUE '4',
      END OF gc_status_arquivo,

      "! Status de processamento do Item
      BEGIN OF gc_status_proc,
        pendente TYPE ztfi_agrupfatura-status_proc VALUE '0',
        erro     TYPE ztfi_agrupfatura-status_proc VALUE '1',
        aviso    TYPE ztfi_agrupfatura-status_proc VALUE '2',
        ok       TYPE ztfi_agrupfatura-status_proc VALUE '3',
      END OF gc_status_proc.


    CONSTANTS:
      "! Tipo de NF
      BEGIN OF gc_tipo_nf,
        "! MDO
        mdo TYPE zi_fi_agrupalinhas-TipoNF VALUE 'MDO',
        "! PEC
        pec TYPE zi_fi_agrupalinhas-TipoNF VALUE 'PEC',
      END OF gc_tipo_nf.

    TYPES:
      "! Categ. tabela com dados do arquivo de agrupamento
      ty_arquivo_t           TYPE STANDARD TABLE OF zsfi_agrupa_fatura_arquivo.

    METHODS:
      "! Converte xstring para tabela interna
      "! @parameter iv_xstring  | Arquivo Xstring
      "! @parameter iv_nome_arq | Nome do arquivo
      "! @parameter ct_tabela   | Tabela tipificada
      converte_xstring_para_it
        IMPORTING
          !iv_xstring  TYPE xstring
          !iv_nome_arq TYPE rsfilenm
        CHANGING
          !ct_tabela   TYPE STANDARD TABLE,

      "! Preenche tabela dos componentes
      "! @parameter is_line   | Linha da tabela
      "! @parameter ct_tabela | Tabela tipificada
      preenche_tabela_componentes
        IMPORTING
          !is_line   TYPE any
        CHANGING
          !ct_tabela TYPE STANDARD TABLE,

      "! Grava dados do arquivo para processamento posterior
      "! @parameter iv_nome_arquivo | Nome do arquivo
      "! @parameter it_arquivo      | Dados do arquivo
      "! @parameter et_return       | Retorno do processamento
      grava_dados_arquivo
        IMPORTING
          iv_nome_arquivo TYPE rsfilenm
          it_arquivo      TYPE ty_arquivo_t
        EXPORTING
          et_return       TYPE bapiret2_t,

      "! Validações do arquivo
      "! @parameter iv_nome_arquivo | Nome do arquivo
      "! @parameter it_arquivo      | Dados do arquivo
      "! @parameter rt_msg          | Mensagens de validação
      valida_arquivo
        IMPORTING
                  iv_nome_arquivo TYPE rsfilenm
                  it_arquivo      TYPE ty_arquivo_t
        RETURNING VALUE(rt_msg)   TYPE bapiret2_t.

  PROTECTED SECTION.
  PRIVATE SECTION.

    METHODS:
      "! Recupera data do campo data/hora
      "! @parameter iv_data_hora | Data/hora
      "! @parameter rv_result | Data
      recupera_data
        IMPORTING
                  iv_data_hora     TYPE zsfi_agrupa_fatura_arquivo-datahora
        RETURNING VALUE(rv_result) TYPE dats,

      "! Converte data para formato AAAAMMDD
      "! @parameter iv_data   | Data em formato DD/MM/AAAA
      "! @parameter rv_result | Data em formato AAAAMMDD
      conv_data
        IMPORTING
                  iv_data          TYPE zsfi_agrupa_fatura_arquivo-data_emissao_nf_mdo
        RETURNING VALUE(rv_result) TYPE dats,

      "! Busca NF com dígito - PEC
      "! @parameter is_linha_arquivo | Linha do arquivo
      "! @parameter rv_result | NF PEC
      busca_nf_pec
        IMPORTING
                  is_linha_Arquivo TYPE zsfi_agrupa_fatura_arquivo
        RETURNING VALUE(rv_result) TYPE xblnr,
      "! Valida formato de data
      "! @parameter iv_data   | Data formato char10
      "! @parameter rs_result | Mensagem de validação
      valida_data
        IMPORTING
          iv_data          TYPE char10
        RETURNING
          VALUE(rs_result) TYPE bapiret2.

ENDCLASS.



CLASS ZCLFI_AGRUPA_FATURAS_ARQUIVO IMPLEMENTATION.


  METHOD converte_xstring_para_it.

    DATA:
      lo_ref_descr TYPE REF TO cl_abap_structdescr,
      lo_excel_ref TYPE REF TO cl_fdt_xl_spreadsheet.

    DATA:
          lt_detail TYPE abap_compdescr_tab.

    FIELD-SYMBOLS : <fs_data>      TYPE STANDARD TABLE.

    TRY.

        lo_excel_ref = NEW cl_fdt_xl_spreadsheet(
          document_name = CONV #( iv_nome_arq )
          xdocument     = iv_xstring ).

      CATCH cx_fdt_excel_core.
        RETURN.
    ENDTRY .


    lo_excel_ref->if_fdt_doc_spreadsheet~get_worksheet_names(
      IMPORTING
        worksheet_names = DATA(lt_worksheets) ).

    IF NOT lt_worksheets IS INITIAL.

      READ TABLE lt_worksheets INTO DATA(lv_woksheetname) INDEX 1.

      DATA(lo_data_ref) = lo_excel_ref->if_fdt_doc_spreadsheet~get_itab_from_worksheet(
                                               lv_woksheetname ).

      ASSIGN lo_data_ref->* TO <fs_data>.

      LOOP AT <fs_data> ASSIGNING FIELD-SYMBOL(<fs_line>) FROM 2. "Ignorar linha do cabeçalho
        me->preenche_tabela_componentes( EXPORTING is_line = <fs_line> CHANGING ct_tabela = ct_tabela ).
      ENDLOOP.

    ENDIF.

  ENDMETHOD.


  METHOD preenche_tabela_componentes.

    DATA:
          lo_ref_descr TYPE REF TO cl_abap_structdescr.

    DATA:
          lt_detail TYPE abap_compdescr_tab.

    DATA:
      lv_value TYPE bapi_current_sales_price,
      lv_qty   TYPE char13,
      lv_data  TYPE char10,
      lv_guid  TYPE char16.

    ASSIGN is_line TO FIELD-SYMBOL(<fs_line>).

    APPEND INITIAL LINE TO ct_tabela ASSIGNING FIELD-SYMBOL(<fs_return>).

    lo_ref_descr ?= cl_abap_typedescr=>describe_by_data( <fs_return> ).
    lt_detail[] = lo_ref_descr->components.

    LOOP AT lt_detail ASSIGNING FIELD-SYMBOL(<fs_detail>).

      ASSIGN COMPONENT <fs_detail>-name OF STRUCTURE <fs_return> TO FIELD-SYMBOL(<fs_ref>).
      ASSIGN COMPONENT sy-tabix         OF STRUCTURE <fs_line>   TO FIELD-SYMBOL(<fs_line_value>).

      IF <fs_ref> IS ASSIGNED AND <fs_line_value> IS ASSIGNED.

        CASE <fs_detail>-type_kind.

          WHEN 'D'.
            IF <fs_line_value> IS NOT INITIAL.
              lv_data = <fs_line_value>.
              TRANSLATE lv_data USING '/ . '.
              CONDENSE lv_data NO-GAPS.
              lv_data = |{ lv_data+4(4) }{ lv_data+2(2) }{ lv_data(2) }|.
              ASSIGN lv_data TO <fs_line_value>.
            ENDIF.

          WHEN 'P'.
            lv_qty = <fs_line_value>.
            CONDENSE lv_qty NO-GAPS.

            FIND ALL OCCURRENCES OF REGEX '[,.]' IN lv_qty RESULTS DATA(lt_result).

            IF sy-subrc EQ 0.
              " Recupera último registro
              DATA(ls_result) = lt_result[ lines( lt_result ) ].

              CASE lv_qty+ls_result-offset(ls_result-length).
                WHEN ','.
                  TRANSLATE lv_qty USING '. '.
                  TRANSLATE lv_qty USING ',.'.
                  CONDENSE  lv_qty NO-GAPS.
                WHEN '.'.
                  TRANSLATE lv_qty USING ', '.
                  CONDENSE  lv_qty NO-GAPS.
              ENDCASE.
            ENDIF.

            ASSIGN lv_qty TO <fs_line_value>.

          WHEN abap_true.

            lv_guid = <fs_line_value>.
            lv_guid = to_upper( lv_guid ).
            TRANSLATE lv_guid USING '- '.
            CONDENSE lv_guid NO-GAPS .
            ASSIGN lv_guid TO <fs_line_value>.

        ENDCASE.

        TRY .
            <fs_ref> = <fs_line_value>.

          CATCH cx_root.
            RETURN.
        ENDTRY.

      ENDIF.
    ENDLOOP.


  ENDMETHOD.


  METHOD grava_dados_arquivo.

    CONSTANTS:
      lc_currency_Reais TYPE waers VALUE 'BRL',
      lc_virgula        TYPE c VALUE `,`,
      lc_ponto          TYPE c VALUE `.`.

    TYPES:
      BEGIN OF ty_taxnum,
        taxnumber1 TYPE i_supplier-TaxNumber1,
      END OF ty_taxnum.

    DATA:
      lt_taxnum    TYPE STANDARD TABLE OF ty_taxnum,
      lt_grava_arq TYPE STANDARD TABLE OF ztfi_agruplinhas.

    DATA:
      ls_novo_arquivo TYPE ztfi_agrupfatura.

    DATA:
      lv_now TYPE zsca_campos_controle-last_changed_at.

    " Gera ID único para o arquivo
    TRY.
        DATA(lv_id_arquivo) = cl_system_uuid=>create_uuid_x16_static( ).
      CATCH cx_uuid_error.
        CLEAR lv_id_arquivo.
    ENDTRY.

    GET TIME STAMP FIELD lv_now.

    ls_novo_arquivo = VALUE #( id_arquivo = lv_id_arquivo
                               arquivo = iv_nome_arquivo
                               data = sy-datum
                               hora = sy-uzeit
                               status_proc = gc_status_arquivo-pendente
                               created_by  = sy-uname
                               created_at  = lv_now
                               last_changed_by = sy-uname
                               last_changed_at = lv_now
                               local_last_changed_at = lv_now
                      ).

    DATA(lt_dados_arquivo) = it_arquivo.

    LOOP AT lt_dados_arquivo ASSIGNING FIELD-SYMBOL(<fs_dados_arquivo>).

      IF <fs_dados_arquivo>-nfnum_mdo IS NOT INITIAL.

        APPEND INITIAL LINE TO lt_grava_arq ASSIGNING FIELD-SYMBOL(<fs_grava_arq>).

        TRY.
            DATA(lv_id_linha) = cl_system_uuid=>create_uuid_x16_static( ).
          CATCH cx_uuid_error.
            CONTINUE.
        ENDTRY.

        DATA(lv_valor_Conv) = CONV dmbtr( translate( val = <fs_dados_arquivo>-valor_nf_mdo
                                                     from = lc_virgula to = lc_ponto )
                              ).

        <fs_grava_arq> = VALUE #(   id          = lv_id_linha
                                    id_arquivo  = lv_id_arquivo
                                    status_proc = gc_status_proc-pendente
                                    arq_data    = me->CONV_data( <fs_dados_arquivo>-data_emissao_nf_mdo )
                                    xblnr1      = <fs_dados_arquivo>-nfnum_mdo
                                    tipo_nf     = Gc_tipo_nf-mdo
                                    chave_acesso = <fs_dados_arquivo>-chave_acesso
                                    cnpj        = <fs_dados_arquivo>-cnpj_emissor_nf
                                    arq_dmbtr   = lv_valor_conv
                                    waers       = lc_currency_reais
                                    arq_bldat   = me->recupera_data( <fs_dados_arquivo>-datahora )
                                    created_by  = sy-uname
                                    created_at  = lv_now
                                    last_changed_by = sy-uname
                                    last_changed_at = lv_now
                                    local_last_changed_at = lv_now
                            ).

      ENDIF.


      IF <fs_dados_arquivo>-nfnum_peca IS NOT INITIAL.
*
        APPEND INITIAL LINE TO lt_grava_arq ASSIGNING <fs_grava_arq>.
*
        TRY.
            lv_id_linha = cl_system_uuid=>create_uuid_x16_static( ).
          CATCH cx_uuid_error.
            CONTINUE.
        ENDTRY.

        CLEAR lv_valor_conv.
        lv_valor_Conv = translate( val  = <fs_dados_arquivo>-valor_nf_peca
                                   from = lc_virgula
                                   to   = lc_ponto ).

        <fs_grava_arq> = VALUE #(   id          = lv_id_linha
                                    id_arquivo  = lv_id_arquivo
                                    status_proc = gc_status_proc-pendente
                                    arq_data    = me->CONV_data(  <fs_dados_arquivo>-data_emissao_nf_peca  )
                                    xblnr1      = me->busca_nf_pec( <fs_dados_arquivo> )
                                    tipo_nf     = Gc_tipo_nf-mdo
                                    chave_acesso = <fs_dados_arquivo>-chave_acesso
                                    cnpj        = <fs_dados_arquivo>-cnpj_emissor_nf
                                    arq_dmbtr   = lv_valor_conv
                                    waers       = lc_currency_reais
                                    arq_bldat   = me->recupera_data( <fs_dados_arquivo>-datahora )
                                    created_by  = sy-uname
                                    created_at  = lv_now
                                    last_changed_by = sy-uname
                                    last_changed_at = lv_now
                                    local_last_changed_at = lv_now
                            ).

      ENDIF.

    ENDLOOP.

    IF lt_grava_arq IS NOT INITIAL.

      MODIFY ztfi_agrupfatura FROM ls_novo_arquivo.
      MODIFY ztfi_agruplinhas FROM TABLE lt_grava_arq.

    ENDIF.

  ENDMETHOD.


  METHOD recupera_data.

    DATA:
      lv_data_original(10) TYPE c.

    lv_data_original = substring( val = iv_data_hora len = 10 ).

    rv_result = lv_data_original(4) && lv_data_original+5(2) && lv_data_original+8(2).
*    rv_result = lv_data_original+6(4) && lv_data_original+3(2) && lv_data_original(2).

  ENDMETHOD.


  METHOD conv_data.

    CONSTANTS:
       lc_numeros(10) TYPE c VALUE '0123456789'.

    IF iv_data IS INITIAL.
      RETURN.
    ENDIF.

    " Data em formato caractere AAAA-MM-DD
    IF iv_data(4) CO lc_numeros.
      rv_result = iv_data(4) && iv_data+5(2) && iv_data+8(2).
      RETURN.
    ENDIF.

    " Data em formato data DD/MM/YYYY
    IF iv_data+6(4) CO lc_numeros.
      rv_result = iv_data+6(4) && iv_data+3(2) && iv_data(2).
      RETURN.
    ENDIF.


  ENDMETHOD.


  METHOD valida_arquivo.

    SELECT COUNT(*)
    FROM ztfi_agrupfatura
    WHERE Arquivo EQ @iv_nome_arquivo.

    IF sy-subrc EQ 0.

      rt_msg = VALUE #( BASE rt_msg
                          ( id = gc_msg_id
                            number = 001
                            type = if_xo_const_message=>error
                            message_v1 = iv_nome_arquivo )
      ).

      RETURN.

    ENDIF.

    LOOP AT it_arquivo ASSIGNING FIELD-SYMBOL(<Fs_arquivo>).

      DATA(lv_data_mdo) = CONV char10( COND #( WHEN <Fs_arquivo>-data_emissao_nf_mdo IS NOT INITIAL
                                                   THEN <Fs_arquivo>-data_emissao_nf_mdo ) ).

      DATA(ls_msg) = me->valida_data( lv_data_mdo ).
      IF ls_msg IS NOT INITIAL.
        APPEND ls_msg TO rt_msg.
        RETURN.
      ENDIF.


      DATA(lv_data_peca) = CONV char10( COND #( WHEN <Fs_arquivo>-data_emissao_nf_peca IS NOT INITIAL
                                                   THEN <Fs_arquivo>-data_emissao_nf_peca ) ).


      ls_msg = me->valida_data( lv_data_peca ).
      IF ls_msg IS NOT INITIAL.
        APPEND ls_msg TO rt_msg.
        RETURN.
      ENDIF.

    ENDLOOP.

  ENDMETHOD.


  METHOD busca_nf_pec.

*    IF is_linha_arquivo-chave_acesso IS NOT INITIAL
*        AND strlen( is_linha_arquivo-chave_acesso ) > 34.
*
*      rv_Result  = |{ is_linha_arquivo-chave_acesso+25(9) }-{ is_linha_arquivo-chave_acesso+22(3) }|.
*
*    ELSE.
    rv_Result = is_linha_arquivo-nfnum_peca.
*    ENDIF.

  ENDMETHOD.


  METHOD valida_data.

    CONSTANTS:
      lc_data_vazia TYPE dats VALUE '00000000'.

    IF iv_data IS INITIAL
        OR iv_data EQ lc_data_vazia.

      RETURN.

    ENDIF.

    DATA(lv_data_formatada) = me->conv_data( iv_data ).

    CALL FUNCTION 'DATE_CHECK_PLAUSIBILITY'
      EXPORTING
        date                      = lv_data_formatada
      EXCEPTIONS
        plausibility_check_failed = 1
        OTHERS                    = 2.

    IF sy-subrc <> 0.

      rs_result = VALUE #( id = gc_msg_id
                           type = if_xo_const_message=>error
                           number = 018
                           message_v1 = iv_data
                  ).


    ENDIF.

  ENDMETHOD.
ENDCLASS.
