class ZCL_ZFI_CARGA_CONTRATO_DPC_EXT definition
  public
  inheriting from ZCL_ZFI_CARGA_CONTRATO_DPC
  create public .

public section.

  methods /IWBEP/IF_MGW_APPL_SRV_RUNTIME~CREATE_STREAM
    redefinition .
  methods /IWBEP/IF_MGW_APPL_SRV_RUNTIME~GET_STREAM
    redefinition .
protected section.

  methods ANEXO_GET_ENTITY
    redefinition .
  methods ARQUIVOS_GET_ENTITY
    redefinition .
  methods DOWNLOAD_GET_ENTITY
    redefinition .
private section.
ENDCLASS.



CLASS ZCL_ZFI_CARGA_CONTRATO_DPC_EXT IMPLEMENTATION.


  METHOD /iwbep/if_mgw_appl_srv_runtime~create_stream.

    DATA: lo_message   TYPE REF TO /iwbep/if_message_container,
          lo_exception TYPE REF TO /iwbep/cx_mgw_busi_exception.

    DATA ls_anexo TYPE zcl_zfi_carga_contrato_mpc=>ts_anexo.

    io_tech_request_context->get_converted_source_keys(
      IMPORTING
        es_key_values = ls_anexo
    ).

* ----------------------------------------------------------------------
* Realiza carga do arquivo
* ----------------------------------------------------------------------
   TRY.
    DATA(lo_carga) = NEW zclfi_anexo_contrato(
      iv_doc_uuid_h = ls_anexo-doc_uuid_h
      iv_contrato   = ls_anexo-contrato
      iv_aditivo    = ls_anexo-aditivo
    ).
   CATCH CX_CNV_00001_ENTRY_NOT_FOUND INTO DATA(lo_message2).
     RETURN.
   ENDTRY.



    lo_carga->anexar( EXPORTING iv_tipo_doc   = ls_anexo-tipo_doc
                                iv_filename   = iv_slug
                                is_media      = is_media_resource
                      IMPORTING
                                et_return     = DATA(lt_return)
                                ev_new_docid  = ls_anexo-doc_uuid_doc ).


    copy_data_to_ref( EXPORTING is_data = ls_anexo
                      CHANGING  cr_data = er_entity ).

*----------------------------------------------------------------------
*Ativa exceção em casos de erro
*----------------------------------------------------------------------

    IF lt_return[] IS NOT INITIAL.
      lo_message = mo_context->get_message_container( ).
      lo_message->add_messages_from_bapi( it_bapi_messages = lt_return ).
      CREATE OBJECT lo_exception EXPORTING message_container = lo_message.
      RAISE EXCEPTION lo_exception.
    ENDIF.

  ENDMETHOD.


  METHOD /iwbep/if_mgw_appl_srv_runtime~get_stream.

    DATA: ls_stream  TYPE ty_s_media_resource,
          ls_lheader TYPE ihttpnvp.

    DATA ls_anexo TYPE zcl_zfi_carga_contrato_mpc=>ts_download.

    io_tech_request_context->get_converted_keys(
      IMPORTING
        es_key_values =  ls_anexo
    ).

* ----------------------------------------------------------------------
* Realiza carga do arquivo
* ----------------------------------------------------------------------


   TRY.
    DATA(lo_carga) = NEW zclfi_anexo_contrato(
      iv_doc_uuid_h = ls_anexo-doc_uuid_h
      iv_contrato   = ls_anexo-contrato
      iv_aditivo    = ls_anexo-aditivo
    ).
   CATCH CX_CNV_00001_ENTRY_NOT_FOUND INTO DATA(lo_message2).
     RETURN.
   ENDTRY.


    lo_carga->recuperar_arquivo(
      EXPORTING
        iv_docid   = ls_anexo-doc_uuid_doc
      IMPORTING
        es_arquivo = ls_anexo
    ).

    ls_lheader-name  = text-001.
    ls_lheader-value = |outlane; filename="{ ls_anexo-filename }";|.

    set_header( is_header = ls_lheader ).

    ls_stream-value     = ls_anexo-value.
    ls_stream-mime_type = ls_anexo-mimetype.

    copy_data_to_ref( EXPORTING is_data = ls_stream
                      CHANGING  cr_data = er_stream ).


  ENDMETHOD.


  method ANEXO_GET_ENTITY.
**TRY.
*CALL METHOD SUPER->ANEXO_GET_ENTITY
*  EXPORTING
*    IV_ENTITY_NAME          =
*    IV_ENTITY_SET_NAME      =
*    IV_SOURCE_NAME          =
*    IT_KEY_TAB              =
**    io_request_object       =
**    io_tech_request_context =
*    IT_NAVIGATION_PATH      =
**  IMPORTING
**    er_entity               =
**    es_response_context     =
*    .
**  CATCH /iwbep/cx_mgw_busi_exception.
**  CATCH /iwbep/cx_mgw_tech_exception.
**ENDTRY.
    RETURN.
  endmethod.


  METHOD arquivos_get_entity.

    io_tech_request_context->get_converted_keys(
      IMPORTING
        es_key_values = er_entity
    ).

    SELECT  SINGLE *
      FROM  ztfi_cont_anexo
      INTO  @DATA(ls_anexo)
      WHERE doc_uuid_h   = @er_entity-doc_uuid_h AND
            contrato     = @er_entity-contrato AND
            aditivo      = @er_entity-aditivo .
    IF sy-subrc IS INITIAL.

      er_entity-doc_uuid_h = ls_anexo-doc_uuid_h.
      er_entity-contrato  = ls_anexo-contrato.
      er_entity-aditivo = ls_anexo-aditivo.
      er_entity-tipo_doc = ls_anexo-TIPO_DOc.
      er_entity-filename = ls_anexo-filename.
      er_entity-mimetype = ls_anexo-mimetype.
      er_entity-created_by = ls_anexo-created_by.
      er_entity-created_at = ls_anexo-created_at.
      er_entity-last_changed_by = ls_anexo-last_changed_by.
      er_entity-last_changed_at = ls_anexo-last_changed_at.
      er_entity-local_last_changed_at = ls_anexo-local_last_changed_at.

    ENDIF.


  ENDMETHOD.


  METHOD download_get_entity.

    io_tech_request_context->get_converted_keys(
      IMPORTING
        es_key_values =  er_entity
    ).
* ----------------------------------------------------------------------
* Exemplo Utilizando o Get Entity.
* ----------------------------------------------------------------------
   TRY.
    DATA(lo_carga) = NEW zclfi_anexo_contrato(
      iv_doc_uuid_h = er_entity-doc_uuid_h
      iv_contrato   = er_entity-contrato
      iv_aditivo    = er_entity-aditivo
    ).
   CATCH CX_CNV_00001_ENTRY_NOT_FOUND INTO DATA(lo_message2).
     RETURN.
   ENDTRY.

    lo_carga->recuperar_arquivo(
      EXPORTING
        iv_docid   = er_entity-doc_uuid_doc
      IMPORTING
        es_arquivo = er_entity
    ).


  ENDMETHOD.
ENDCLASS.
