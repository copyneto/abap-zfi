CLASS zclfi_carga_contr_01_dpc_ext DEFINITION
  PUBLIC
  INHERITING FROM zclfi_carga_contr_01_dpc
  CREATE PUBLIC .

  PUBLIC SECTION.

    METHODS /iwbep/if_mgw_appl_srv_runtime~create_stream
        REDEFINITION .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCLFI_CARGA_CONTR_01_DPC_EXT IMPLEMENTATION.


  METHOD /iwbep/if_mgw_appl_srv_runtime~create_stream.


*    DATA  lv_filetype  TYPE ze_carga_contratos.
    DATA  lv_filetype  TYPE c LENGTH 63.
    DATA  lv_nome_arq  TYPE rsfilenm.
    DATA  lv_guid      TYPE guid_16.
    DATA  lo_message   TYPE REF TO /iwbep/if_message_container.
    DATA  lo_exception TYPE REF TO /iwbep/cx_mgw_busi_exception.
    DATA  ls_arquivo   TYPE zclfi_carga_contr_01_mpc=>ts_upload.
*    DATA  ls_arquivo   TYPE zclfi_carga_contr_01_mpc=>ty_upload.
    DATA  lv_mime_type TYPE char100 VALUE 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'.
    DATA  lt_return    TYPE bapiret2_t.

    DATA(lo_carga) = NEW zclfi_carga_contrat_excel( ).

    CONSTANTS lc_contrato(29)      TYPE c VALUE '1 - Contratos / ZTFI_CONTRATO'.
    CONSTANTS lc_client_cnpj(60)   TYPE c VALUE '3 - Clientes da Raiz CNPJ Principal / ZTFI_CNPJ_CLIENT'.
    CONSTANTS lc_raiz_cnpj(60)     TYPE c VALUE '2 - CNPJ Principal dos Contratos / ZTFI_RAIZ_CNPJ'.
    CONSTANTS lc_cond_desc(60)     TYPE c VALUE '4 - Condições de Desconto / ZTFI_CAD_COND'.
    CONSTANTS lc_cont_cond(60)     TYPE c VALUE '5 - Condição de Contratos / ZTFI_CONT_COND'.
    CONSTANTS lc_cad_prov(60)      TYPE c VALUE '6 - Cadastro de Provisões / ZTFI_CAD_PROVI'.
    CONSTANTS lc_par_venc(60)      TYPE c VALUE '8 - Cadastro Janela Contratos / ZTFI_CONT_JANELA'.
    CONSTANTS lc_famiprov(60)      TYPE c VALUE '7 - Cadastro Campo Familia Provisões / ZTFI_PROV_FAM'.
    CONSTANTS lc_niveis_aprov(60)  TYPE c VALUE '9 - Níveis de Aprovação / ZTFI_CAD_NIVEL'.
    CONSTANTS lc_aprov_usuar(60)   TYPE c VALUE '10 - Aprovadores de Contrato Níveis / ZTFI_CAD_APROVAD'.
    CONSTANTS lc_aprovacao(60)     TYPE c VALUE '11 - Aprovações do Contrato / ZTFI_CONT_APROV'.
    CONSTANTS lc_cent_custo(60)    TYPE c VALUE '12 - Centro de Custos / ZTFI_CAD_CC'.
    CONSTANTS lc_cont_cont(60)     TYPE c VALUE '13 - Contratos Contabilizados / ZTFI_CONT_CONT'.
    CONSTANTS lc_crescimento(60)   TYPE c VALUE '14 - Cadastro Crescimento / ZTFI_CAD_CRESCI'.
    CONSTANTS lc_cresc_bonus(60)   TYPE c VALUE '15 - Cadastro Faixa Bônus Crescimento / ZTFI_FAIXA_CRESC'.
    CONSTANTS lc_base_cres(63)     TYPE c VALUE '16 - Cadastro Base de Comparação Crescimento / ZTFI_COMP_CRESCI'.
    CONSTANTS lc_fam_cres(53)     TYPE c VALUE  '17 - Cadastro Familia Crescimento / ZTFI_CRESC_FAMIL'.

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
    CASE lv_filetype.
      WHEN lc_contrato.

        lo_carga->upload_contrato( EXPORTING iv_filename   = iv_slug
                                             is_media      = is_media_resource
                                   IMPORTING
                                             et_return     = lt_return ).

      WHEN lc_cad_prov.

        lo_carga->upload_cadprovi( EXPORTING iv_filename   = iv_slug
                                             is_media      = is_media_resource
                                   IMPORTING
                                             et_return     = lt_return ).

      WHEN lc_cont_cont.

        lo_carga->upload_contcont( EXPORTING iv_filename   = iv_slug
                                             is_media      = is_media_resource
                                   IMPORTING
                                             et_return     = lt_return ).
      WHEN lc_cont_cond.


        lo_carga->upload_contcond( EXPORTING iv_filename   = iv_slug
                                              is_media      = is_media_resource
                                   IMPORTING
                                              et_return     = lt_return ).
      WHEN lc_cent_custo.

        lo_carga->upload_cadcc( EXPORTING iv_filename   = iv_slug
                                          is_media      = is_media_resource
                                IMPORTING
                                          et_return     = lt_return ).
      WHEN lc_niveis_aprov.

        lo_carga->upload_cadnivel( EXPORTING iv_filename   = iv_slug
                                             is_media      = is_media_resource
                                   IMPORTING
                                             et_return     = lt_return ).

      WHEN lc_aprov_usuar.

        lo_carga->upload_cadaprovad( EXPORTING iv_filename   = iv_slug
                                               is_media      = is_media_resource
                                     IMPORTING
                                               et_return     = lt_return ).

      WHEN lc_crescimento.

        lo_carga->upload_cadcresci( EXPORTING iv_filename   = iv_slug
                                              is_media      = is_media_resource
                                    IMPORTING
                                              et_return     = lt_return ).

      WHEN lc_cond_desc.

        lo_carga->upload_cadcond( EXPORTING iv_filename   = iv_slug
                                            is_media      = is_media_resource
                                  IMPORTING
                                            et_return     = lt_return ).

      WHEN lc_cresc_bonus.
        lo_carga->upload_faixacresc( EXPORTING iv_filename   = iv_slug
                                               is_media      = is_media_resource
                                     IMPORTING
                                               et_return     = lt_return ).

      WHEN lc_aprovacao.
        lo_carga->upload_contaprov( EXPORTING iv_filename   = iv_slug
                                              is_media      = is_media_resource
                                    IMPORTING
                                              et_return     = lt_return ).
      WHEN lc_base_cres.

        lo_carga->upload_basecompar( EXPORTING iv_filename   = iv_slug
                                               is_media      = is_media_resource
                                    IMPORTING
                                              et_return     = lt_return ).
      WHEN lc_par_venc.

        lo_carga->upload_contjanela( EXPORTING iv_filename   = iv_slug
                                               is_media      = is_media_resource
                                     IMPORTING
                                               et_return     = lt_return ).

      WHEN lc_raiz_cnpj.

        lo_carga->upload_raizcnpj( EXPORTING iv_filename   = iv_slug
                                             is_media      = is_media_resource
                                   IMPORTING
                                             et_return     = lt_return ).
      WHEN lc_client_cnpj.

        lo_carga->upload_cnpjclient( EXPORTING iv_filename   = iv_slug
                                               is_media      = is_media_resource
                                     IMPORTING
                                               et_return     = lt_return ).
      WHEN lc_famiprov.

        lo_carga->upload_famiprov( EXPORTING iv_filename   = iv_slug
                                               is_media      = is_media_resource
                                     IMPORTING
                                               et_return     = lt_return ).

      WHEN lc_fam_cres.

        lo_carga->upload_famicresc( EXPORTING iv_filename   = iv_slug
                                              is_media      = is_media_resource
                                    IMPORTING
                                              et_return     = lt_return ).


      WHEN OTHERS.
        " Falha ao salvar dados de carga.
        lt_return = VALUE #( BASE lt_return ( type = 'E' id = 'ZFI_CARGA_EXCEL' number = '002' ) ).
        RETURN.

    ENDCASE.

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

  ENDMETHOD.
ENDCLASS.
