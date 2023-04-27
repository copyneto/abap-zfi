CLASS zclfi_carga_contab_dpc_ext DEFINITION
  PUBLIC
  INHERITING FROM zclfi_carga_contab_dpc
  CREATE PUBLIC .

  PUBLIC SECTION.
    METHODS /iwbep/if_mgw_appl_srv_runtime~create_stream
        REDEFINITION .

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zclfi_carga_contab_dpc_ext IMPLEMENTATION.

  METHOD /iwbep/if_mgw_appl_srv_runtime~create_stream.

    DATA: lo_message   TYPE REF TO /iwbep/if_message_container,
          lo_exception TYPE REF TO /iwbep/cx_mgw_busi_exception.

* ----------------------------------------------------------------------
* Realiza carga do arquivo
* ----------------------------------------------------------------------
    DATA(lo_carga) = NEW zclfi_carga_contabilizacao( ).

    lo_carga->upload( EXPORTING iv_filename   = iv_slug
                                     is_media      = is_media_resource
                           IMPORTING es_header     = DATA(ls_header)
                                     et_return     = DATA(lt_return) ).

    copy_data_to_ref( EXPORTING is_data = ls_header
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

  ENDMETHOD.
ENDCLASS.
