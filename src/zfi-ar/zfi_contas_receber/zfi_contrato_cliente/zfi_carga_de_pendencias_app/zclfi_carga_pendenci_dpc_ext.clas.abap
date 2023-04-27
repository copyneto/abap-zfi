class ZCLFI_CARGA_PENDENCI_DPC_EXT definition
  public
  inheriting from ZCLFI_CARGA_PENDENCI_DPC
  create public .

public section.

  methods /IWBEP/IF_MGW_APPL_SRV_RUNTIME~CREATE_STREAM
    redefinition .
protected section.

  methods UPLOADSET_GET_ENTITY
    redefinition .
private section.
ENDCLASS.



CLASS ZCLFI_CARGA_PENDENCI_DPC_EXT IMPLEMENTATION.


  METHOD /iwbep/if_mgw_appl_srv_runtime~create_stream.
**TRY.
    DATA: lo_message   TYPE REF TO /iwbep/if_message_container,
          lo_exception TYPE REF TO /iwbep/cx_mgw_busi_exception.
    DATA: ls_arquivo   TYPE zclfi_carga_pendenci_mpc=>ts_upload.

* ----------------------------------------------------------------------
* Realiza carga do arquivo
* ----------------------------------------------------------------------
    DATA(lo_carga) = NEW zclfi_carga_pendencias( ).

    lo_carga->upload( EXPORTING iv_filename   = iv_slug
                                     is_media      = is_media_resource
                           IMPORTING
                                     et_return     = DATA(lt_return) ).


    ls_arquivo-filename = iv_slug.

    copy_data_to_ref( EXPORTING is_data = ls_arquivo
                      CHANGING  cr_data = er_entity ).

* ----------------------------------------------------------------------
* Ativa exceção em casos de erro
* ----------------------------------------------------------------------
    IF lt_return[] IS NOT INITIAL.
      lo_message = mo_context->get_message_container( ).
      lo_message->add_messages_from_bapi( it_bapi_messages = lt_return ).
      CREATE OBJECT lo_exception EXPORTING message_container = lo_message.
      RAISE EXCEPTION lo_exception.
    ENDIF.
**ENDTRY.
  ENDMETHOD.


  method UPLOADSET_GET_ENTITY.
**TRY.
*CALL METHOD SUPER->UPLOADSET_GET_ENTITY
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
  endmethod.
ENDCLASS.
