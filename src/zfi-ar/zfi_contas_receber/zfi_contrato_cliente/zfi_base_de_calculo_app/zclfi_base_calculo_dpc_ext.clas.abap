class ZCLFI_BASE_CALCULO_DPC_EXT definition
  public
  inheriting from ZCLFI_BASE_CALCULO_DPC
  create public .

public section.

  methods /IWBEP/IF_MGW_APPL_SRV_RUNTIME~CREATE_STREAM
    redefinition .
protected section.
private section.
ENDCLASS.



CLASS ZCLFI_BASE_CALCULO_DPC_EXT IMPLEMENTATION.


  method /IWBEP/IF_MGW_APPL_SRV_RUNTIME~CREATE_STREAM.

    DATA  lv_filetype  TYPE ze_base_calculo.
    DATA  lv_nome_arq  TYPE rsfilenm.
    DATA  lv_guid      TYPE guid_16.
    DATA  lo_message   TYPE REF TO /iwbep/if_message_container.
    DATA  lo_exception TYPE REF TO /iwbep/cx_mgw_busi_exception.
    DATA  ls_arquivo   TYPE zclfi_base_calculo_mpc=>ts_upload.
    DATA  lv_mime_type TYPE char100 VALUE 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'.
    DATA  lt_return    TYPE bapiret2_t.

    DATA(lo_carga) = NEW zclfi_basecalculo( ).

    CONSTANTS lc_msg TYPE c LENGTH 16 VALUE 'ZFI_BASE_CALCULO'.
    "! Numero das mensagens
    CONSTANTS lc_num TYPE bapiret2-number VALUE '002'.
    "! Tipo para erro
    CONSTANTS lc_e TYPE c  VALUE 'E'.

* ----------------------------------------------------------------------
* Lógica para identificar qual o Radion Button selecionado
* ----------------------------------------------------------------------
    IF is_media_resource-mime_type = lv_mime_type.

      SPLIT iv_slug AT ';' INTO lv_nome_arq lv_filetype.

      TRY.
          lv_guid = cl_system_uuid=>create_uuid_x16_static( ).
        CATCH cx_uuid_error.
      ENDTRY.

    ENDIF.


* ----------------------------------------------------------------------
* Realiza carga do arquivo
* ----------------------------------------------------------------------

     lo_carga->upload_calccresci( EXPORTING iv_filename   = iv_slug
                                               is_media      = is_media_resource
                                  IMPORTING
                                              et_return     = lt_return ).

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

  endmethod.
ENDCLASS.
