"!<p>Classe DPC extension para <strong>Impressão de boleto DDA</strong>. <br/>
"! Esta classe é utilizada no serviço OData<em>ZFI_BOLETO_DDA</em> <br/> <br/>
"!<p><strong>Autor:</strong> Anderson Miazato - Meta</p>
"!<p><strong>Data:</strong> 13/out/2021</p>
class ZCLFI_BOLETO_DDA_DPC_EXT definition
  public
  inheriting from ZCLFI_BOLETO_DDA_DPC
  create public .

public section.

  methods /IWBEP/IF_MGW_APPL_SRV_RUNTIME~GET_STREAM
    redefinition .
protected section.

  methods DOWNLOADCHECKSET_GET_ENTITY
    redefinition .
  methods MEMORYSET_GET_ENTITYSET
    redefinition .
  PRIVATE SECTION.

    "! Monta o arquivo PDF para permitir visualização e download
    "! @parameter iv_pdf_file   | PDF em formato XSTRING
    "! @parameter co_stream     | Arquivo media em formato PDF
    METHODS build_pdf
      IMPORTING
        !iv_pdf_file TYPE xstring
      CHANGING
        !co_stream   TYPE REF TO data .
ENDCLASS.



CLASS ZCLFI_BOLETO_DDA_DPC_EXT IMPLEMENTATION.


  METHOD /iwbep/if_mgw_appl_srv_runtime~get_stream.

    CONSTANTS:
      lc_indefinido TYPE string VALUE 'undefined',
      lc_msg_id     TYPE sy-msgid VALUE 'ZFI_SOLUCAO_DDA'.

    CONSTANTS:
      BEGIN OF lc_chave,
        lifnr    TYPE /iwbep/s_mgw_tech_pair-name VALUE 'LIFNR',
        bukrs    TYPE /iwbep/s_mgw_tech_pair-name VALUE 'BUKRS',
        belnr    TYPE /iwbep/s_mgw_tech_pair-name VALUE 'BELNR',
        gjahr    TYPE /iwbep/s_mgw_tech_pair-name VALUE 'GJAHR',
        barcode  TYPE /iwbep/s_mgw_tech_pair-name VALUE 'BARCODE',
        data_arq TYPE /iwbep/s_mgw_tech_pair-name VALUE 'DATA_ARQ',
        NUM_DOC TYPE /iwbep/s_mgw_tech_pair-name VALUE 'NUM_DOC',
      END OF lc_chave.

    DATA: lt_sorted_keys TYPE SORTED TABLE OF /iwbep/s_mgw_tech_pair  WITH UNIQUE KEY name,
          lt_return      TYPE bapiret2_t.

    DATA: ls_stream       TYPE ty_s_media_resource,
          ls_lheader      TYPE ihttpnvp,
          ls_meta         TYPE sfpmetadata,
          ls_campos_Chave TYPE zsfi_arquivo_dda.

    DATA: lv_pdf_file TYPE xstring.

    DATA: lo_fp        TYPE REF TO if_fp,
          lo_pdfobj    TYPE REF TO if_fp_pdf_object,
          lo_message   TYPE REF TO /iwbep/if_message_container,
          lo_exception TYPE REF TO /iwbep/cx_mgw_busi_exception.

    TRY.
        DATA(lt_keys) = io_tech_request_context->get_keys( ).
        lt_sorted_keys = lt_keys.
      CATCH cx_root.
    ENDTRY.

    ls_campos_chave = VALUE zsfi_arquivo_dda(
        lifnr   = |{ lt_sorted_keys[ name = lc_chave-lifnr ]-value ALPHA = IN WIDTH = 10 }|
        bukrs   = lt_sorted_keys[ name = lc_chave-bukrs ]-value
        belnr   = |{ lt_sorted_keys[ name = lc_chave-belnr ]-value ALPHA = IN WIDTH = 10 }|
        gjahr   = lt_sorted_keys[ name = lc_chave-gjahr ]-value
        barcode = lt_sorted_keys[ name = lc_chave-barcode ]-value
        data_arq = lt_sorted_keys[ name = lc_chave-data_arq ]-value
        num_doc = lt_sorted_keys[ name = lc_chave-num_doc ]-value
    ).

    IF lt_sorted_keys[ name = lc_chave-barcode ]-value EQ lc_indefinido.

      SELECT SINGLE Barcode
       FROM zi_fi_error_dda
       WHERE  DocNumber   EQ @ls_campos_chave-belnr
          AND CompanyCode EQ @ls_campos_chave-bukrs
          AND FiscalYear  EQ @ls_campos_chave-gjahr
          INTO @ls_campos_chave-barcode.

    ENDIF.

    REPLACE 'Z' WITH '/' INTO ls_campos_chave-num_doc .

    " Gera o boleto DDA
    NEW zclfi_impressao_dda( )->gerar_boleto(
      EXPORTING
        is_chave_dda = ls_campos_chave
      IMPORTING
        ev_pdf       = lv_pdf_file
        ev_erro      = DATA(lv_erro_boleto)
    ).

    IF lv_pdf_file IS INITIAL.

      lt_return = VALUE #( ( type = if_xo_const_message=>error
                             id = lc_msg_id
                             number = 005 ) ).

    ELSE.

      " Monta o arquivo PDF
      me->build_pdf(
        EXPORTING
          iv_pdf_file = lv_pdf_file
        CHANGING
          co_stream   = er_stream
      ).

    ENDIF.

** ----------------------------------------------------------------------
** Ativa exceção em casos de erro
** ----------------------------------------------------------------------
    SORT lt_return BY type.

    READ TABLE lt_return TRANSPORTING NO FIELDS
        WITH KEY type = if_xo_const_message=>error BINARY SEARCH.
    IF sy-subrc EQ 0.

      lo_message = mo_context->get_message_container( ).
      lo_message->add_messages_from_bapi( it_bapi_messages = lt_return ).
      CREATE OBJECT lo_exception EXPORTING message_container = lo_message.
      RAISE EXCEPTION lo_exception.

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

    " Monta nome do arquivo
    DATA(lv_nome_arquivo) = CONV string( TEXT-001 ).

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
    ls_lheader-value = 'inline; filename="' && |{ lv_nome_arquivo }| && '.pdf";'.

    set_header( is_header = ls_lheader ).

    " Retorna binário do PDF
    ls_stream-mime_type = 'application/pdf'.
    ls_stream-value     = lv_pdf_file.

    copy_data_to_ref( EXPORTING is_data = ls_stream
                      CHANGING  cr_data = co_stream ).

  ENDMETHOD.


  METHOD downloadcheckset_get_entity.

    CONSTANTS:
      lc_indefinido TYPE string VALUE 'undefined',
      lc_msg_id     TYPE sy-msgid VALUE 'ZFI_SOLUCAO_DDA',
      lc_mime_pdf   TYPE string VALUE 'application/pdf'.

    CONSTANTS:
      BEGIN OF lc_chave,
        lifnr    TYPE /iwbep/s_mgw_tech_pair-name VALUE 'LIFNR',
        bukrs    TYPE /iwbep/s_mgw_tech_pair-name VALUE 'BUKRS',
        belnr    TYPE /iwbep/s_mgw_tech_pair-name VALUE 'BELNR',
        gjahr    TYPE /iwbep/s_mgw_tech_pair-name VALUE 'GJAHR',
        barcode  TYPE /iwbep/s_mgw_tech_pair-name VALUE 'BARCODE',
        data_arq TYPE /iwbep/s_mgw_tech_pair-name VALUE 'DATA_ARQ',
        num_doc  TYPE /iwbep/s_mgw_tech_pair-name VALUE 'NUM_DOC',
      END OF lc_chave.

    DATA: lt_sorted_keys TYPE SORTED TABLE OF /iwbep/s_mgw_tech_pair  WITH UNIQUE KEY name,
          lt_return      TYPE bapiret2_t.

    DATA: ls_campos_chave TYPE zsfi_arquivo_dda.

    DATA: lv_pdf_file TYPE xstring.

    DATA: lo_message   TYPE REF TO /iwbep/if_message_container,
          lo_exception TYPE REF TO /iwbep/cx_mgw_busi_exception.

    IF iv_entity_name NE gc_entity-downloadcheck.
      RETURN.
    ENDIF.

    TRY.

        DATA(lt_keys) = io_tech_request_context->get_keys( ).
        lt_sorted_keys = lt_keys.

      CATCH cx_root.

    ENDTRY.

    ls_campos_chave = VALUE zsfi_arquivo_dda(
        lifnr   = |{ lt_sorted_keys[ name = lc_chave-lifnr ]-value ALPHA = IN WIDTH = 10 }|
        bukrs   = lt_sorted_keys[ name = lc_chave-bukrs ]-value
        belnr   = |{ lt_sorted_keys[ name = lc_chave-belnr ]-value ALPHA = IN WIDTH = 10 }|
        gjahr   = lt_sorted_keys[ name = lc_chave-gjahr ]-value
        barcode = lt_sorted_keys[ name = lc_chave-barcode ]-value
        data_arq = lt_sorted_keys[ name = lc_chave-data_arq ]-value
        num_doc = lt_sorted_keys[ name = lc_chave-num_doc ]-value
    ).

    REPLACE 'Z' WITH '/' INTO ls_campos_chave-num_doc .

    IF lt_sorted_keys[ name = lc_chave-barcode ]-value EQ lc_indefinido.

      SELECT SINGLE barcode
       FROM zi_fi_error_dda
       WHERE  docnumber   EQ @ls_campos_chave-belnr
          AND companycode EQ @ls_campos_chave-bukrs
          AND fiscalyear  EQ @ls_campos_chave-gjahr
          INTO @ls_campos_chave-barcode.

    ENDIF.

    " Gera o boleto DDA
    NEW zclfi_impressao_dda( )->gerar_boleto(
      EXPORTING
        is_chave_dda = ls_campos_chave
      IMPORTING
        ev_pdf     = lv_pdf_file
        ev_erro    = DATA(lv_erro_boleto)
    ).

    IF lv_pdf_file IS INITIAL.

      lt_return = VALUE #( ( type = if_xo_const_message=>error
                             id = lc_msg_id
                             number = 005 ) ).

    ENDIF.

    er_entity-lifnr   = ls_campos_chave-lifnr.
    er_entity-bukrs   = ls_campos_chave-bukrs.
    er_entity-belnr   = ls_campos_chave-belnr.
    er_entity-gjahr   = ls_campos_chave-gjahr.
    er_entity-barcode = ls_campos_chave-barcode.
    er_entity-mimetype = lc_mime_pdf.
    er_entity-value    = lv_pdf_file.

* ----------------------------------------------------------------------
* Ativa exceção em casos de erro
* ----------------------------------------------------------------------
    SORT lt_return BY type.

    READ TABLE lt_return TRANSPORTING NO FIELDS
        WITH KEY type = if_xo_const_message=>error BINARY SEARCH.

    IF sy-subrc EQ 0.

      lo_message = mo_context->get_message_container( ).
      lo_message->add_messages_from_bapi( it_bapi_messages = lt_return ).
      CREATE OBJECT lo_exception EXPORTING message_container = lo_message.
      RAISE EXCEPTION lo_exception.

    ENDIF.

  ENDMETHOD.


  METHOD memoryset_get_entityset.
    RETURN.
  ENDMETHOD.
ENDCLASS.
