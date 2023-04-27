"!<p><h2>DPC Extension p/ upload do Arquivo de faturas ticket </h2></p> <br/>
"! Data Provider Class extension para serviço do upload de arquivo de faturas <br/> <br/>
"!<p><strong>Autor:</strong> Anderson Miazato</p>
"!<p><strong>Data:</strong> 22 de dez de 2021</p>
CLASS zclfi_agrupa_fatura_dpc_ext DEFINITION
  PUBLIC
  INHERITING FROM zclfi_agrupa_fatura_dpc
  CREATE PUBLIC .

  PUBLIC SECTION.

    METHODS /iwbep/if_mgw_appl_srv_runtime~create_stream
        REDEFINITION .
    METHODS /iwbep/if_mgw_appl_srv_runtime~get_stream
        REDEFINITION .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zclfi_agrupa_fatura_dpc_ext IMPLEMENTATION.


  METHOD /iwbep/if_mgw_appl_srv_runtime~create_stream.

    CONSTANTS:
      BEGIN OF lc_mime,
        excel TYPE char100 VALUE 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
        text  TYPE char100 VALUE 'text/plain',
      END OF lc_mime.

    TYPES:
      BEGIN OF ty_upload,
        filename     TYPE string,
        value        TYPE xstring,
        mimetype     TYPE char100,
        type_message TYPE char1,
      END OF ty_upload.


    DATA:
      lo_message   TYPE REF TO /iwbep/if_message_container,
      lo_exception TYPE REF TO /iwbep/cx_mgw_busi_exception.

    DATA:
      lt_arquivo TYPE TABLE OF zsfi_agrupa_fatura_arquivo.

    DATA:
      ls_entity TYPE ty_upload.

    DATA:
      lv_nome_arq TYPE rsfilenm.


    DATA(lo_preenche_tabelas) = NEW zclfi_agrupa_faturas_arquivo( ).

    IF is_media_resource-mime_type EQ lc_mime-excel.

      lv_nome_arq = iv_slug.

      lo_preenche_tabelas->converte_xstring_para_it(
        EXPORTING
          iv_xstring  = is_media_resource-value
          iv_nome_arq = lv_nome_arq
        CHANGING
          ct_tabela   = lt_arquivo
      ).

      IF lt_arquivo IS NOT INITIAL.

        DATA(lt_return) = lo_preenche_tabelas->valida_arquivo(
          EXPORTING
            iv_nome_arquivo = lv_nome_arq
            it_arquivo      = lt_arquivo
        ).

        IF lt_return IS INITIAL.

          lo_preenche_tabelas->grava_dados_arquivo(
            EXPORTING
              iv_nome_arquivo = lv_nome_arq
              it_arquivo      = lt_arquivo
            IMPORTING
              et_return       = lt_return
          ).

        ENDIF.
      ENDIF.

      ls_entity-filename     = lv_nome_arq.
      ls_entity-mimetype     = is_media_resource-mime_type.
      ls_entity-type_message = if_xo_const_message=>success.

    ELSE.

      ls_entity-filename     = lv_nome_arq.
      ls_entity-mimetype     = is_media_resource-mime_type.
      ls_entity-type_message = if_xo_const_message=>error.

    ENDIF.

    copy_data_to_ref( EXPORTING is_data = ls_entity
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


  METHOD /iwbep/if_mgw_appl_srv_runtime~get_stream.

    IF sy-subrc EQ 0.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
