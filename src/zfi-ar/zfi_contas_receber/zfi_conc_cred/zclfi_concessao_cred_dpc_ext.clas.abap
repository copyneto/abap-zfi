class ZCLFI_CONCESSAO_CRED_DPC_EXT definition
  public
  inheriting from ZCLFI_CONCESSAO_CRED_DPC
  create public .

public section.

  methods /IWBEP/IF_MGW_APPL_SRV_RUNTIME~CREATE_STREAM
    redefinition .
protected section.
private section.
ENDCLASS.



CLASS ZCLFI_CONCESSAO_CRED_DPC_EXT IMPLEMENTATION.


  METHOD /iwbep/if_mgw_appl_srv_runtime~create_stream.

    SPLIT iv_slug AT ';' INTO DATA(lv_nome_arq) DATA(lv_filetype).

    DATA lv_nome_arquivo TYPE rsfilenm.
    lv_nome_arquivo = CONV #( lv_nome_arq ).

    CONSTANTS:
      lc_mime_type_xlsx TYPE char100 VALUE 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
      lc_mime_type_xls  TYPE char100 VALUE 'application/vnd.ms-excel'.
    DATA:
      ls_entity TYPE zsfi_gateway_upload.

    IF is_media_resource-mime_type = lc_mime_type_xlsx OR
       is_media_resource-mime_type = lc_mime_type_xls.
      NEW zclfi_conc_cred_upload( )->carga( iv_media_resource_value = is_media_resource-value
                                            iv_nome_arq = lv_nome_arquivo ).
    ENDIF.

    ls_entity-filename     = lv_nome_arq.
    ls_entity-mimetype     = is_media_resource-mime_type.
    ls_entity-type_message = 'S'.

    copy_data_to_ref( EXPORTING is_data = ls_entity
                      CHANGING  cr_data = er_entity ).

  ENDMETHOD.
ENDCLASS.
