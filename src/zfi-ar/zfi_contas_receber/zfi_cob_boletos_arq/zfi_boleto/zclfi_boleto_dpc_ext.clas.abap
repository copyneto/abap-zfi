CLASS zclfi_boleto_dpc_ext DEFINITION
  PUBLIC
  INHERITING FROM zclfi_boleto_dpc
  CREATE PUBLIC .

  PUBLIC SECTION.

    METHODS /iwbep/if_mgw_appl_srv_runtime~get_stream
        REDEFINITION .
  PROTECTED SECTION.

    METHODS emailset_get_entity
        REDEFINITION .
    METHODS emailset_get_entityset
        REDEFINITION .
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCLFI_BOLETO_DPC_EXT IMPLEMENTATION.


  METHOD /iwbep/if_mgw_appl_srv_runtime~get_stream.
    DATA: lo_fp       TYPE REF TO if_fp,
          lo_pdfobj   TYPE REF TO if_fp_pdf_object,
          lt_return   TYPE bapiret2_t,
          ls_stream   TYPE ty_s_media_resource,
          ls_lheader  TYPE ihttpnvp,
          ls_meta     TYPE sfpmetadata,
          lv_pdf_file TYPE xstring.

    CONSTANTS: lc_key   TYPE char3      VALUE 'KEY',
               lc_ads   TYPE rfcdest    VALUE 'ADS',
               lc_arq   TYPE char7      VALUE 'Arquivo' ##NO_TEXT,
               lc_name  TYPE ihttpnam   VALUE 'Content-Disposition' ##NO_TEXT,
               lc_value TYPE ihttpval   VALUE 'inline; filename="Boleto.pdf";' ##NO_TEXT,
               lc_mime  TYPE char15     VALUE 'application/pdf' ##NO_TEXT.

    TRY.
        DATA(lt_keys) = io_tech_request_context->get_keys( ).

*        DATA(lt_key) = VALUE zctgfi_post_key( ( CONV ze_post_key( lt_keys[ name = 'KEY' ]-value  ) ) ).


      CATCH cx_root.
    ENDTRY.

    DATA ls_process  TYPE zsfi_boleto_process.

    ls_process-app = abap_true.

    DATA(lo_boleto) = NEW zclfi_gerar_boleto( is_process = ls_process ).



    DATA(lv_bukrs) = CONV bukrs( VALUE #( lt_keys[ name = 'EMPRESA' ]-value OPTIONAL ) ).
    DATA(lv_belnr) = CONV belnr_d( VALUE #( lt_keys[ name = 'DOCUMENTO' ]-value OPTIONAL ) ).
    DATA(lv_gjahr) = CONV gjahr( VALUE #( lt_keys[ name = 'ANO' ]-value OPTIONAL ) ).
    DATA(lv_buzei) = CONV buzei( VALUE #( lt_keys[ name = 'ITEM' ]-value OPTIONAL ) ).

    lo_boleto->process(
      EXPORTING
*       it_key      = lt_key
        iv_bukrs    = lv_bukrs
        iv_belnr    = lv_belnr
        iv_gjahr    = lv_gjahr
        iv_buzei    = lv_buzei
      IMPORTING
        ev_pdf_file = lv_pdf_file
        et_return   = lt_return      " Parâmetro de retorno
    ).

    "@@ PDF
    TRY.

        lo_fp = cl_fp=>get_reference( ).
        lo_pdfobj = lo_fp->create_pdf_object( connection = lc_ads ).
        lo_pdfobj->set_document( pdfdata = lv_pdf_file ).

        ls_meta-title = lc_arq.
        lo_pdfobj->set_metadata( metadata = ls_meta ).
        lo_pdfobj->execute( ).

        lo_pdfobj->get_document( IMPORTING pdfdata = lv_pdf_file ).

      CATCH cx_root.
    ENDTRY.
    lv_belnr = |{ lv_belnr ALPHA = IN }|.
    SELECT SINGLE xblnr FROM bkpf
    INTO @DATA(lv_xblnr)
    WHERE bukrs = @lv_bukrs
     AND belnr = @lv_belnr
     AND gjahr = @lv_gjahr.

    SELECT SINGLE kunnr FROM bseg
    INTO @DATA(lv_kunnr)
    WHERE bukrs = @lv_bukrs
     AND belnr = @lv_belnr
     AND gjahr = @lv_gjahr
     AND buzei = @lv_buzei.

    ls_lheader-name  = lc_name. "'Content-Disposition'.
*    ls_lheader-value = lc_value ."'inline; filename="File.pdf";'.
    ls_lheader-value = |{ TEXT-001 }_{ lv_kunnr }_{ lv_xblnr(16) }.pdf";|.

    set_header( is_header = ls_lheader ).

    ls_stream-mime_type = lc_mime. "'application/pdf'.
    ls_stream-value     = lv_pdf_file.

    copy_data_to_ref( EXPORTING is_data = ls_stream
                      CHANGING  cr_data = er_stream ).


    FREE lo_boleto.

  ENDMETHOD.


  METHOD emailset_get_entity.

    DATA: lo_message   TYPE REF TO /iwbep/if_message_container,
          lo_exception TYPE REF TO /iwbep/cx_mgw_busi_exception.

    DATA: lo_fp       TYPE REF TO if_fp,
          lo_pdfobj   TYPE REF TO if_fp_pdf_object,
*          lt_Return   TYPE bapiret2_t,
          ls_stream   TYPE ty_s_media_resource,
          ls_lheader  TYPE ihttpnvp,
          ls_meta     TYPE sfpmetadata,
          lv_pdf_file TYPE xstring.

    CONSTANTS: lc_email TYPE char5 VALUE 'EMAIL',
               lc_key   TYPE char3 VALUE 'KEY'.


    TRY.
        DATA(lt_keys) = io_tech_request_context->get_keys( ).

        DATA(lt_key) = VALUE zctgfi_post_key( ( CONV ze_post_key( lt_keys[ name = lc_key ]-value  ) ) ).

        DATA(lv_email) = lt_keys[ name = lc_email ]-value.

      CATCH cx_root.
    ENDTRY.

    DATA ls_process  TYPE zsfi_boleto_process.

    ls_process-email = abap_true.

    DATA(lo_boleto) = NEW zclfi_gerar_boleto( is_process = ls_process ).

    lo_boleto->process(
      EXPORTING
        iv_app    = abap_true
        it_key    = lt_key
        iv_email  = CONV ad_smtpadr( lv_email )
      IMPORTING
*       ev_pdf_file = gv_pdf_file
        et_return = DATA(lt_return)
    ).


    TRY.
        er_entity-mensagem = lt_return[ type = 'S' ]-message.
        CLEAR er_entity-mensagem.
        er_entity-mensagem = TEXT-002.
      CATCH cx_root.
    ENDTRY.

    FREE lo_boleto.


    IF line_exists( lt_return[ type = 'E' ] ).
      lo_message = mo_context->get_message_container( ).
      lo_message->add_messages_from_bapi( it_bapi_messages = lt_return ).
      CREATE OBJECT lo_exception EXPORTING message_container = lo_message.
      RAISE EXCEPTION lo_exception.
    ENDIF.

  ENDMETHOD.


  METHOD emailset_get_entityset.
    RETURN.
**TRY.
*CALL METHOD SUPER->EMAILSET_GET_ENTITYSET
*  EXPORTING
*    IV_ENTITY_NAME           =
*    IV_ENTITY_SET_NAME       =
*    IV_SOURCE_NAME           =
*    IT_FILTER_SELECT_OPTIONS =
*    IS_PAGING                =
*    IT_KEY_TAB               =
*    IT_NAVIGATION_PATH       =
*    IT_ORDER                 =
*    IV_FILTER_STRING         =
*    IV_SEARCH_STRING         =
**    io_tech_request_context  =
**  IMPORTING
**    et_entityset             =
**    es_response_context      =
*    .
**  CATCH /iwbep/cx_mgw_busi_exception.
**  CATCH /iwbep/cx_mgw_tech_exception.
**ENDTRY.
  ENDMETHOD.
ENDCLASS.
