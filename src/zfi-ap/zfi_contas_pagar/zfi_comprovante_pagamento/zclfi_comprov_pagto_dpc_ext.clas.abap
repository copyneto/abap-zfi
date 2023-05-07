"!<p><h2>Data provider p/ serviço de geração de PDF do comprovante de Pagto</h2></p>
"!<p><strong>Autor:</strong> Anderson Miazato</p>
"!<p><strong>Data:</strong> 06 de setembro de 2021</p>
CLASS zclfi_comprov_pagto_dpc_ext DEFINITION
  PUBLIC
  INHERITING FROM zclfi_comprov_pagto_dpc
  CREATE PUBLIC .

  PUBLIC SECTION.

    METHODS /iwbep/if_mgw_appl_srv_runtime~get_stream
        REDEFINITION .
  PROTECTED SECTION.

    METHODS pdfbrowserset_get_entity
        REDEFINITION .
    METHODS pdffileset_get_entity
        REDEFINITION .
private section.

  constants GC_FI type ZTCA_PARAM_VAL-MODULO value 'FI' ##NO_TEXT.
  constants GC_WF type ZTCA_PARAM_VAL-CHAVE1 value 'WF' ##NO_TEXT.
  constants GC_URL type ZTCA_PARAM_VAL-CHAVE2 value 'URL' ##NO_TEXT.

    "! Prepara o arquivo PDF do comprovante de pagto para visualização/download
    "! @parameter iv_pdf_file       | PDF em formato XSTRING
    "! @parameter is_campos_chave   | Campos chave da tabela ZTFI_RETPAG_SEGZ
    "! @parameter co_stream         | Arquivo PDF a ser exportado pelo serviço
  methods BUILD_PDF
    importing
      !IV_PDF_FILE type XSTRING
      !IS_CAMPOS_CHAVE type ZSFI_COMPROV_PAGTO_CHAVE
    changing
      !CO_STREAM type ref to DATA .
ENDCLASS.



CLASS ZCLFI_COMPROV_PAGTO_DPC_EXT IMPLEMENTATION.


  METHOD pdfbrowserset_get_entity.

    DATA: lt_sorted_keys TYPE SORTED TABLE OF /iwbep/s_mgw_tech_pair  WITH UNIQUE KEY name,
          lt_return      TYPE bapiret2_t.

    DATA: ls_campos_chave TYPE zsfi_comprov_pagto_chave.

    TRY.
        DATA(lt_keys) = io_tech_request_context->get_keys( ).
        lt_sorted_keys = lt_keys.
      CATCH cx_root.
    ENDTRY.

    ls_campos_chave = VALUE zsfi_comprov_pagto_chave(
                               empresa              =  lt_sorted_keys[ name = 'EMPRESA' ]-value
                               fornecedor           =  |{ lt_sorted_keys[ name = 'FORNECEDOR' ]-value ALPHA = IN WIDTH = 10 }|
                               fatura               =  lt_sorted_keys[ name = 'FATURA' ]-value
                               doccontabauxiliar    =  lt_sorted_keys[ name = 'DOCCONTABAUXILIAR' ]-value
                               bancoempresa         =  lt_sorted_keys[ name = 'BANCOEMPRESA' ]-value
                               formapagto           =  lt_sorted_keys[ name = 'FORMAPAGTO' ]-value
                               exerciciocompensacao =  lt_sorted_keys[ name = 'EXERCICIOCOMPENSACAO' ]-value
                               ).

    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
      EXPORTING
        input  = ls_campos_chave-doccontabauxiliar
      IMPORTING
        output = ls_campos_chave-doccontabauxiliar.

    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
      EXPORTING
        input  = ls_campos_chave-fatura
      IMPORTING
        output = ls_campos_chave-fatura.


    NEW zclfi_comprovante_pagamento( )->gerar_comprovante(
      EXPORTING
        is_campos_chave = ls_campos_chave
      IMPORTING
        ev_comprovante  = DATA(lv_comprovante)
    ).

    IF lv_comprovante IS INITIAL.
      RETURN.
    ENDIF.

    er_entity-url = NEW zclca_pdf_url( lv_comprovante )->gerar_url( ).


  ENDMETHOD.


  METHOD /iwbep/if_mgw_appl_srv_runtime~get_stream.


    DATA: lt_sorted_keys TYPE SORTED TABLE OF /iwbep/s_mgw_tech_pair  WITH UNIQUE KEY name,
          lt_return      TYPE bapiret2_t.

    DATA: ls_stream       TYPE ty_s_media_resource,
          ls_lheader      TYPE ihttpnvp,
          ls_meta         TYPE sfpmetadata,
          ls_campos_chave TYPE zsfi_comprov_pagto_chave.

    DATA: lv_pdf_file TYPE xstring.

    DATA: lo_fp     TYPE REF TO if_fp,
          lo_pdfobj TYPE REF TO if_fp_pdf_object.

    TRY.
        DATA(lt_keys) = io_tech_request_context->get_keys( ).
        lt_sorted_keys = lt_keys.
      CATCH cx_root.
    ENDTRY.

    ls_campos_chave = VALUE zsfi_comprov_pagto_chave(
                               empresa              =  lt_sorted_keys[ name = 'EMPRESA' ]-value
                               fornecedor           =  |{ lt_sorted_keys[ name = 'FORNECEDOR' ]-value ALPHA = IN WIDTH = 10 }|
                               fatura               =  lt_sorted_keys[ name = 'FATURA' ]-value
                               doccontabauxiliar    =  lt_sorted_keys[ name = 'DOCCONTABAUXILIAR' ]-value
                               bancoempresa         =  lt_sorted_keys[ name = 'BANCOEMPRESA' ]-value
                               formapagto           =  lt_sorted_keys[ name = 'FORMAPAGTO' ]-value
                               exerciciocompensacao =  lt_sorted_keys[ name = 'EXERCICIOCOMPENSACAO' ]-value
                               ).

    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
      EXPORTING
        input  = ls_campos_chave-doccontabauxiliar
      IMPORTING
        output = ls_campos_chave-doccontabauxiliar.

    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
      EXPORTING
        input  = ls_campos_chave-fatura
      IMPORTING
        output = ls_campos_chave-fatura.


    " Gera o comprovante
    NEW zclfi_comprovante_pagamento( )->gerar_comprovante(
      EXPORTING
        is_campos_chave = ls_campos_chave
      IMPORTING
        ev_comprovante  = DATA(lv_comprovante)
    ).

    IF lv_comprovante IS INITIAL.
      RETURN.
    ENDIF.

    " Monta o arquivo PDF
    me->build_pdf(
      EXPORTING
        iv_pdf_file     = lv_comprovante
        is_campos_chave = ls_campos_chave
      CHANGING
        co_stream       = er_stream
    ).

  ENDMETHOD.


  METHOD pdffileset_get_entity.
    IF sy-subrc EQ 0.
    ENDIF.
  ENDMETHOD.


  METHOD build_pdf.

    CONSTANTS: lc_separador       TYPE c VALUE '_',
               lc_pdf_header_name TYPE string VALUE 'content-disposition'.

    DATA: ls_stream  TYPE ty_s_media_resource,
          ls_lheader TYPE ihttpnvp,
          ls_meta    TYPE sfpmetadata.

    DATA: lv_pdf_file TYPE xstring.

    DATA: lo_fp     TYPE REF TO if_fp,
          lo_pdfobj TYPE REF TO if_fp_pdf_object.

    IF iv_pdf_file IS INITIAL.
      RETURN.
    ENDIF.

    lv_pdf_file = iv_pdf_file.

    "Ler dados do segmento 'Z'
    SELECT SINGLE empresa, fornecedor, montante, datacompensacao
       FROM zi_fi_retpagto_segmentoz
       WHERE empresa              = @is_campos_chave-empresa              AND
             fornecedor           = @is_campos_chave-fornecedor           AND
             fatura               = @is_campos_chave-fatura               AND
             doccontabauxiliar    = @is_campos_chave-doccontabauxiliar    AND
             exerciciocompensacao = @is_campos_chave-exerciciocompensacao AND
             bancoempresa         = @is_campos_chave-bancoempresa         AND
             formapagto           = @is_campos_chave-formapagto
       INTO @DATA(ls_segmentoz).

    IF sy-subrc EQ 0.

      " Monta nome do arquivo
      DATA(lv_data_comp) =  ls_segmentoz-DataCompensacao+6(2) && ls_segmentoz-DataCompensacao+4(2)  && ls_segmentoz-DataCompensacao(4) .

      DATA(lv_valor_montante) = CONV string( ls_segmentoz-Montante ).
      lv_valor_montante = replace( val   = lv_valor_montante
                                   regex = '[^\d]'
                                   with  = ' '
                                   occ   = 0 ).

      DATA(lv_nome_arquivo)  = |{ ls_segmentoz-empresa }|         && lc_separador &&
                               |{ ls_segmentoz-fornecedor }|      && lc_separador &&
                               |{ lv_data_comp }| && lc_separador &&
                               |{ lv_valor_montante }|.

    ENDIF.


    " Atualiza Metadata do arquivo PDF
    TRY.
        "Cria o objeto PDF.
        lo_fp = cl_fp=>get_reference( ).
        lo_pdfobj = lo_fp->create_pdf_object( connection = 'ADS' ).
        lo_pdfobj->set_document( pdfdata = lv_pdf_file ).

        "Determina o título do arquivo
        ls_meta-title = lv_nome_arquivo.

        lo_pdfobj->set_metadata( metadata = ls_meta ).
        lo_pdfobj->execute( ).

        "Get the PDF content back with title
        lo_pdfobj->get_document( IMPORTING pdfdata = lv_pdf_file ).

      CATCH cx_root.
    ENDTRY.

    " Muda nome do arquivo
    " Tipo comportamento:
    " - inline: Não fará download automático
    " - outline: Download automático
    ls_lheader-name  = lc_pdf_header_name.
    ls_lheader-value = 'outline; filename="' && |{ lv_nome_arquivo }| && '.pdf";'.

    set_header( is_header = ls_lheader ).

    " Retorna binário do PDF
    ls_stream-mime_type = 'application/pdf'.
    ls_stream-value     = lv_pdf_file.

    copy_data_to_ref( EXPORTING is_data = ls_stream
                      CHANGING  cr_data = co_stream ).

  ENDMETHOD.
ENDCLASS.
