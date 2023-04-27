CLASS zclfi_carga_contrat_excel DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.


*___________________________Constantes________________________*

    "! Tipo para erro
    CONSTANTS gc_e TYPE c  VALUE 'E'.
    CONSTANTS gc_s TYPE c  VALUE 'S'.
    "! Tipo de arquivo
    CONSTANTS gc_xlsx TYPE c LENGTH 4 VALUE 'XLSX'.
    "! ID mensagem
    CONSTANTS gc_msg TYPE c LENGTH 15 VALUE 'ZFI_CARGA_EXCEL'.
    "! Numero das mensagens
    CONSTANTS gc_num1 TYPE bapiret2-number VALUE '001'.
    CONSTANTS gc_num2 TYPE bapiret2-number VALUE '002'.
    CONSTANTS gc_num6 TYPE bapiret2-number VALUE '006'.
    CONSTANTS gc_num7 TYPE bapiret2-number VALUE '007'.


*_____________________Tabela ZTFI_CAD_APROVAD ________________*

    "! Realiza carga de arquivo
    "! @parameter iv_filename | Nome do arquivo
    "! @parameter is_media | Arquivo enviado
    "! @parameter et_return | Mensagens de retorno
    METHODS upload_cadaprovad
      IMPORTING
        !iv_filename TYPE string
        !is_media    TYPE /iwbep/if_mgw_appl_srv_runtime=>ty_s_media_resource
      EXPORTING
        !et_return   TYPE bapiret2_t .


*_____________________Tabela ZTFI_CAD_CC __________________*

    "! Realiza carga de arquivo
    "! @parameter iv_filename | Nome do arquivo
    "! @parameter is_media | Arquivo enviado
    "! @parameter et_return | Mensagens de retorno
    METHODS upload_cadcc
      IMPORTING
        !iv_filename TYPE string
        !is_media    TYPE /iwbep/if_mgw_appl_srv_runtime=>ty_s_media_resource
      EXPORTING
        !et_return   TYPE bapiret2_t .

*_____________________Tabela ZTFI_CAD_COND __________________*

    "! Realiza carga de arquivo
    "! @parameter iv_filename | Nome do arquivo
    "! @parameter is_media | Arquivo enviado
    "! @parameter et_return | Mensagens de retorno
    METHODS upload_cadcond
      IMPORTING
        !iv_filename TYPE string
        !is_media    TYPE /iwbep/if_mgw_appl_srv_runtime=>ty_s_media_resource
      EXPORTING
        !et_return   TYPE bapiret2_t .

*_____________________Tabela ZTFI_CAD_NIVEL __________________*

    "! Realiza carga de arquivo
    "! @parameter iv_filename | Nome do arquivo
    "! @parameter is_media | Arquivo enviado
    "! @parameter et_return | Mensagens de retorno
    METHODS upload_cadnivel
      IMPORTING
        !iv_filename TYPE string
        !is_media    TYPE /iwbep/if_mgw_appl_srv_runtime=>ty_s_media_resource
      EXPORTING
        !et_return   TYPE bapiret2_t .

*_____________________Tabela ZTFI_CAD_SEMCONT __________________*

    "! Realiza carga de arquivo
    "! @parameter iv_filename | Nome do arquivo
    "! @parameter is_media | Arquivo enviado
    "! @parameter et_return | Mensagens de retorno
    METHODS upload_cadsemcont
      IMPORTING
        !iv_filename TYPE string
        !is_media    TYPE /iwbep/if_mgw_appl_srv_runtime=>ty_s_media_resource
      EXPORTING
        !et_return   TYPE bapiret2_t .


*_____________________Tabela ZTFI_CNPJ_CLIENT __________________*

    "! Realiza carga de arquivo
    "! @parameter iv_filename | Nome do arquivo
    "! @parameter is_media | Arquivo enviado
    "! @parameter et_return | Mensagens de retorno
    METHODS upload_cnpjclient
      IMPORTING
        !iv_filename TYPE string
        !is_media    TYPE /iwbep/if_mgw_appl_srv_runtime=>ty_s_media_resource
      EXPORTING
        !et_return   TYPE bapiret2_t .

*_____________________Tabela ZTFI_CONTRATO __________________*

    "! Realiza carga de arquivo
    "! @parameter iv_filename | Nome do arquivo
    "! @parameter is_media | Arquivo enviado
    "! @parameter et_return | Mensagens de retorno
    METHODS upload_contrato
      IMPORTING
        !iv_filename TYPE string
        !is_media    TYPE /iwbep/if_mgw_appl_srv_runtime=>ty_s_media_resource
      EXPORTING
        !et_return   TYPE bapiret2_t .


*_____________________Tabela ZTFI_CONT_COND __________________*

    "! Realiza carga de arquivo
    "! @parameter iv_filename | Nome do arquivo
    "! @parameter is_media | Arquivo enviado
    "! @parameter et_return | Mensagens de retorno
    METHODS upload_contcond
      IMPORTING
        !iv_filename TYPE string
        !is_media    TYPE /iwbep/if_mgw_appl_srv_runtime=>ty_s_media_resource
      EXPORTING
        !et_return   TYPE bapiret2_t .


*_____________________Tabela ZTFI_RAIZ_CNPJ __________________*

    "! Realiza carga de arquivo
    "! @parameter iv_filename | Nome do arquivo
    "! @parameter is_media | Arquivo enviado
    "! @parameter et_return | Mensagens de retorno
    METHODS upload_raizcnpj
      IMPORTING
        !iv_filename TYPE string
        !is_media    TYPE /iwbep/if_mgw_appl_srv_runtime=>ty_s_media_resource
      EXPORTING
        !et_return   TYPE bapiret2_t .


*_____________________Tabela ZTFI_CONT_CONT __________________*

    "! Realiza carga de arquivo
    "! @parameter iv_filename | Nome do arquivo
    "! @parameter is_media | Arquivo enviado
    "! @parameter et_return | Mensagens de retorno
    METHODS upload_contcont
      IMPORTING
        !iv_filename TYPE string
        !is_media    TYPE /iwbep/if_mgw_appl_srv_runtime=>ty_s_media_resource
      EXPORTING
        !et_return   TYPE bapiret2_t .


*_____________________Tabela ZTFI_CAD_PROVI __________________*

    "! Realiza carga de arquivo
    "! @parameter iv_filename | Nome do arquivo
    "! @parameter is_media | Arquivo enviado
    "! @parameter et_return | Mensagens de retorno
    METHODS upload_cadprovi
      IMPORTING
        !iv_filename TYPE string
        !is_media    TYPE /iwbep/if_mgw_appl_srv_runtime=>ty_s_media_resource
      EXPORTING
        !et_return   TYPE bapiret2_t .

*_____________________Tabela ZTFI_CONT_JANELA __________________*

    "! Realiza carga de arquivo
    "! @parameter iv_filename | Nome do arquivo
    "! @parameter is_media | Arquivo enviado
    "! @parameter et_return | Mensagens de retorno
    METHODS upload_contjanela
      IMPORTING
        !iv_filename TYPE string
        !is_media    TYPE /iwbep/if_mgw_appl_srv_runtime=>ty_s_media_resource
      EXPORTING
        !et_return   TYPE bapiret2_t .

*_____________________Tabela ZTFI_CAD_CRESCI __________________*

    "! Realiza carga de arquivo
    "! @parameter iv_filename | Nome do arquivo
    "! @parameter is_media | Arquivo enviado
    "! @parameter et_return | Mensagens de retorno
    METHODS upload_cadcresci
      IMPORTING
        !iv_filename TYPE string
        !is_media    TYPE /iwbep/if_mgw_appl_srv_runtime=>ty_s_media_resource
      EXPORTING
        !et_return   TYPE bapiret2_t .

*_____________________Tabela ZTFI_FAIXA_CRESC __________________*

    "! Realiza carga de arquivo
    "! @parameter iv_filename | Nome do arquivo
    "! @parameter is_media | Arquivo enviado
    "! @parameter et_return | Mensagens de retorno
    METHODS upload_faixacresc
      IMPORTING
        !iv_filename TYPE string
        !is_media    TYPE /iwbep/if_mgw_appl_srv_runtime=>ty_s_media_resource
      EXPORTING
        !et_return   TYPE bapiret2_t .


*_____________________Tabela ZTFI_CONT_APROV __________________*

    "! Realiza carga de arquivo
    "! @parameter iv_filename | Nome do arquivo
    "! @parameter is_media | Arquivo enviado
    "! @parameter et_return | Mensagens de retorno
    METHODS upload_contaprov
      IMPORTING
        !iv_filename TYPE string
        !is_media    TYPE /iwbep/if_mgw_appl_srv_runtime=>ty_s_media_resource
      EXPORTING
        !et_return   TYPE bapiret2_t .

*_____________________Tabela ZTFI_BASE_COMPAR __________________*

    "! Realiza carga de arquivo
    "! @parameter iv_filename | Nome do arquivo
    "! @parameter is_media | Arquivo enviado
    "! @parameter et_return | Mensagens de retorno
    METHODS upload_basecompar
      IMPORTING
        iv_filename TYPE string
        is_media    TYPE /iwbep/if_mgw_appl_srv_runtime=>ty_s_media_resource
      EXPORTING
        et_return   TYPE bapiret2_t .
    METHODS upload_famiprov
      IMPORTING
        iv_filename TYPE string
        is_media    TYPE /iwbep/if_mgw_appl_types=>ty_s_media_resource
      EXPORTING
        et_return   TYPE bapiret2_t.

    METHODS upload_famicresc
      IMPORTING
        iv_filename TYPE string
        is_media    TYPE /iwbep/if_mgw_appl_types=>ty_s_media_resource
      EXPORTING
        et_return   TYPE bapiret2_t.


  PROTECTED SECTION.



  PRIVATE SECTION.

    METHODS get_next_guid
      EXPORTING
        !ev_guid       TYPE sysuuid_x16
        !et_return     TYPE bapiret2_t
      RETURNING
        VALUE(rv_guid) TYPE sysuuid_x16 .
    METHODS get_next_documentno
      EXPORTING
        !et_return          TYPE bapiret2_t
      RETURNING
        VALUE(rv_docnumber) TYPE ztfi_carga_conth-documentno .
    METHODS upload_header
      IMPORTING
        !iv_filetype TYPE char60
      EXPORTING
        !et_return   TYPE bapiret2_t .
*_____________________Tabela ZTFI_CAD_APROVAD ________________*
    "! Processar arquivo e separar em tabelas
    "! @parameter it_file | Tabela do arquivo
    "! @parameter et_doc | Tabela de documentos
    "! @parameter et_return | Tabela de retorno
    METHODS upload_fill_data_cadaprovad
      IMPORTING
        !it_file   TYPE zctgfi_cad_aprovad
      EXPORTING
        !et_doc    TYPE zctgfi_cad_aprov
        !et_return TYPE bapiret2_t .
    "! Salvar dados carregados na tabela
    "! @parameter it_doc | Tabela de documentos
    "! @parameter et_return | Tabela de mensagens
    METHODS upload_save_cadaprovad
      IMPORTING
        !it_doc    TYPE zctgfi_cad_aprov OPTIONAL
      EXPORTING
        !et_return TYPE bapiret2_t .
*_____________________Tabela ZTFI_CAD_CC __________________*
    "! Processar arquivo e separar em tabelas
    "! @parameter it_file | Tabela do arquivo
    "! @parameter et_doc | Tabela de documentos
    "! @parameter et_return | Tabela de retorno
    METHODS upload_fill_data_cadcc
      IMPORTING
        !it_file   TYPE zctgfi_cad_cc
      EXPORTING
        !et_doc    TYPE zctgfi_cadcc
        !et_return TYPE bapiret2_t .
    "! Salvar dados carregados na tabela
    "! @parameter it_doc | Tabela de documentos
    "! @parameter et_return | Tabela de mensagens
    METHODS upload_save_cadcc
      IMPORTING
        !it_doc    TYPE zctgfi_cadcc OPTIONAL
      EXPORTING
        !et_return TYPE bapiret2_t .
*_____________________Tabela ZTFI_CAD_COND __________________*
    "! Processar arquivo e separar em tabelas
    "! @parameter it_file | Tabela do arquivo
    "! @parameter et_doc | Tabela de documentos
    "! @parameter et_return | Tabela de retorno
    METHODS upload_fill_data_cadcond
      IMPORTING
        !it_file   TYPE zctgfi_cad_cond
      EXPORTING
        !et_doc    TYPE zctgfi_cadcond
        !et_return TYPE bapiret2_t .
    "! Salvar dados carregados na tabela
    "! @parameter it_doc | Tabela de documentos
    "! @parameter et_return | Tabela de mensagens
    METHODS upload_save_cadcond
      IMPORTING
        !it_doc    TYPE zctgfi_cadcond OPTIONAL
      EXPORTING
        !et_return TYPE bapiret2_t .
*_____________________Tabela ZTFI_CAD_NIVEL __________________*
    "! Processar arquivo e separar em tabelas
    "! @parameter it_file | Tabela do arquivo
    "! @parameter et_doc | Tabela de documentos
    "! @parameter et_return | Tabela de retorno
    METHODS upload_fill_data_cadnivel
      IMPORTING
        !it_file   TYPE zctgfi_cad_nivel
      EXPORTING
        !et_doc    TYPE zctgfi_cadnivel
        !et_return TYPE bapiret2_t .
    "! Salvar dados carregados na tabela
    "! @parameter it_doc | Tabela de documentos
    "! @parameter et_return | Tabela de mensagens
    METHODS upload_save_cadnivel
      IMPORTING
        !it_doc    TYPE zctgfi_cadnivel OPTIONAL
      EXPORTING
        !et_return TYPE bapiret2_t .
*_____________________Tabela ZTFI_CAD_SEMCONT __________________*
    "! Processar arquivo e separar em tabelas
    "! @parameter it_file | Tabela do arquivo
    "! @parameter et_doc | Tabela de documentos
    "! @parameter et_return | Tabela de retorno
    METHODS upload_fill_data_cadsemcont
      IMPORTING
        !it_file   TYPE zctgfi_cad_semcont
      EXPORTING
        !et_doc    TYPE zctgfi_cadsemcont
        !et_return TYPE bapiret2_t .
    "! Salvar dados carregados na tabela
    "! @parameter it_doc | Tabela de documentos
    "! @parameter et_return | Tabela de mensagens
    METHODS upload_save_cadsemcont
      IMPORTING
        !it_doc    TYPE zctgfi_cadsemcont OPTIONAL
      EXPORTING
        !et_return TYPE bapiret2_t .
*_____________________Tabela ZTFI_CNPJ_CLIENT __________________*
    "! Processar arquivo e separar em tabelas
    "! @parameter it_file | Tabela do arquivo
    "! @parameter et_doc | Tabela de documentos
    "! @parameter et_return | Tabela de retorno
    METHODS upload_fill_data_cnpjclient
      IMPORTING
        !it_file   TYPE zctgfi_cnpj_client
      EXPORTING
        !et_doc    TYPE zctgfi_cnpjclient
        !et_return TYPE bapiret2_t .
    "! Salvar dados carregados na tabela
    "! @parameter it_doc | Tabela de documentos
    "! @parameter et_return | Tabela de mensagens
    METHODS upload_save_cnpjclient
      IMPORTING
        !it_doc    TYPE zctgfi_cnpjclient OPTIONAL
      EXPORTING
        !et_return TYPE bapiret2_t .
*_____________________Tabela ZTFI_CONTRATO __________________*
    "! Processar arquivo e separar em tabelas
    "! @parameter it_file | Tabela do arquivo
    "! @parameter et_doc | Tabela de documentos
    "! @parameter et_return | Tabela de retorno
    METHODS upload_fill_data_contrato
      IMPORTING
        !it_file   TYPE zctgfi_contrato_excel
      EXPORTING
        !et_doc    TYPE zctgfi_contrato_tb
        !et_return TYPE bapiret2_t .
    "! Salvar dados carregados na tabela
    "! @parameter it_doc | Tabela de documentos
    "! @parameter et_return | Tabela de mensagens
    METHODS upload_save_contrato
      IMPORTING
        !it_doc    TYPE zctgfi_contrato_tb OPTIONAL
      EXPORTING
        !et_return TYPE bapiret2_t .
*_____________________Tabela ZTFI_CONT_COND __________________*
    "! Processar arquivo e separar em tabelas
    "! @parameter it_file | Tabela do arquivo
    "! @parameter et_doc | Tabela de documentos
    "! @parameter et_return | Tabela de retorno
    METHODS upload_fill_data_contcond
      IMPORTING
        !it_file   TYPE zctgfi_cont_cond
      EXPORTING
        !et_doc    TYPE zctgfi_contcond
        !et_return TYPE bapiret2_t .
    "! Salvar dados carregados na tabela
    "! @parameter it_doc | Tabela de documentos
    "! @parameter et_return | Tabela de mensagens
    METHODS upload_save_contcond
      IMPORTING
        !it_doc    TYPE zctgfi_contcond OPTIONAL
      EXPORTING
        !et_return TYPE bapiret2_t .
*_____________________Tabela ZTFI_RAIZ_CNPJ __________________*
    "! Processar arquivo e separar em tabelas
    "! @parameter it_file | Tabela do arquivo
    "! @parameter et_doc | Tabela de documentos
    "! @parameter et_return | Tabela de retorno
    METHODS upload_fill_data_raizcnpj
      IMPORTING
        !it_file   TYPE zctgfi_raiz_cnpj
      EXPORTING
        !et_doc    TYPE zctgfi_raizcnpj
        !et_return TYPE bapiret2_t .
    "! Salvar dados carregados na tabela
    "! @parameter it_doc | Tabela de documentos
    "! @parameter et_return | Tabela de mensagens
    METHODS upload_save_raizcnpj
      IMPORTING
        !it_doc    TYPE zctgfi_raizcnpj OPTIONAL
      EXPORTING
        !et_return TYPE bapiret2_t .
*_____________________Tabela ZTFI_CONT_CONT __________________*
    "! Processar arquivo e separar em tabelas
    "! @parameter it_file | Tabela do arquivo
    "! @parameter et_doc | Tabela de documentos
    "! @parameter et_return | Tabela de retorno
    METHODS upload_fill_data_contcont
      IMPORTING
        !it_file   TYPE zctgfi_contcont
      EXPORTING
        !et_doc    TYPE zctgfi_cont_cont
        !et_return TYPE bapiret2_t .
    "! Salvar dados carregados na tabela
    "! @parameter it_doc | Tabela de documentos
    "! @parameter et_return | Tabela de mensagens
    METHODS upload_save_contcont
      IMPORTING
        !it_doc    TYPE zctgfi_cont_cont OPTIONAL
      EXPORTING
        !et_return TYPE bapiret2_t .
*_____________________Tabela ZTFI_CAD_PROVI __________________*
    "! Processar arquivo e separar em tabelas
    "! @parameter it_file | Tabela do arquivo
    "! @parameter et_doc | Tabela de documentos
    "! @parameter et_return | Tabela de retorno
    METHODS upload_fill_data_cadprovi
      IMPORTING
        !it_file   TYPE zctgfi_cad_provi
      EXPORTING
        !et_doc    TYPE zctgfi_cadprovi
        !et_return TYPE bapiret2_t .
    "! Salvar dados carregados na tabela
    "! @parameter it_doc | Tabela de documentos
    "! @parameter et_return | Tabela de mensagens
    METHODS upload_save_cadprovi
      IMPORTING
        !it_doc    TYPE zctgfi_cadprovi OPTIONAL
      EXPORTING
        !et_return TYPE bapiret2_t .
*_____________________Tabela ZTFI_CONT_JANELA __________________*
    "! Processar arquivo e separar em tabelas
    "! @parameter it_file | Tabela do arquivo
    "! @parameter et_doc | Tabela de documentos
    "! @parameter et_return | Tabela de retorno
    METHODS upload_fill_data_contjanela
      IMPORTING
        !it_file   TYPE zctgfi_cont_janel
      EXPORTING
        !et_doc    TYPE zctgfi_contjanel
        !et_return TYPE bapiret2_t .
    "! Salvar dados carregados na tabela
    "! @parameter it_doc | Tabela de documentos
    "! @parameter et_return | Tabela de mensagens
    METHODS upload_save_contjanela
      IMPORTING
        !it_doc    TYPE zctgfi_contjanel OPTIONAL
      EXPORTING
        !et_return TYPE bapiret2_t .
*_____________________Tabela ZTFI_CAD_CRESCI __________________*
    "! Processar arquivo e separar em tabelas
    "! @parameter it_file | Tabela do arquivo
    "! @parameter et_doc | Tabela de documentos
    "! @parameter et_return | Tabela de retorno
    METHODS upload_fill_data_cadcresci
      IMPORTING
        !it_file   TYPE zctgfi_cad_cresci
      EXPORTING
        !et_doc    TYPE zctgfi_cadcresci
        !et_return TYPE bapiret2_t .
    "! Salvar dados carregados na tabela
    "! @parameter it_doc | Tabela de documentos
    "! @parameter et_return | Tabela de mensagens
    METHODS upload_save_cadcresci
      IMPORTING
        !it_doc    TYPE zctgfi_cadcresci OPTIONAL
      EXPORTING
        !et_return TYPE bapiret2_t .
*_____________________Tabela ZTFI_FAIXA_CRESC __________________*
    "! Processar arquivo e separar em tabelas
    "! @parameter it_file | Tabela do arquivo
    "! @parameter et_doc | Tabela de documentos
    "! @parameter et_return | Tabela de retorno
    METHODS upload_fill_data_faixacresc
      IMPORTING
        !it_file   TYPE zctgfi_faixa_cres
      EXPORTING
        !et_doc    TYPE zctgfi_faixacres
        !et_return TYPE bapiret2_t .
    "! Salvar dados carregados na tabela
    "! @parameter it_doc | Tabela de documentos
    "! @parameter et_return | Tabela de mensagens
    METHODS upload_save_faixacresc
      IMPORTING
        !it_doc    TYPE zctgfi_faixacres OPTIONAL
      EXPORTING
        !et_return TYPE bapiret2_t .
*_____________________Tabela ZTFI_CONT_APROV __________________*
    "! Processar arquivo e separar em tabelas
    "! @parameter it_file | Tabela do arquivo
    "! @parameter et_doc | Tabela de documentos
    "! @parameter et_return | Tabela de retorno
    METHODS upload_fill_data_contaprov
      IMPORTING
        !it_file   TYPE zctgfi_cont_aprov
      EXPORTING
        !et_doc    TYPE zctgfi_contaprov
        !et_return TYPE bapiret2_t .
    "! Salvar dados carregados na tabela
    "! @parameter it_doc | Tabela de documentos
    "! @parameter et_return | Tabela de mensagens
    METHODS upload_save_contaprov
      IMPORTING
        !it_doc    TYPE zctgfi_contaprov OPTIONAL
      EXPORTING
        !et_return TYPE bapiret2_t .
*_____________________Tabela ZTFI_BASE_COMPAR __________________*
    "! Processar arquivo e separar em tabelas
    "! @parameter it_file | Tabela do arquivo
    "! @parameter et_doc | Tabela de documentos
    "! @parameter et_return | Tabela de retorno
    METHODS upload_fill_data_basecompar
      IMPORTING
        !it_file   TYPE zctgfi_base_compar
      EXPORTING
        !et_doc    TYPE zctgfi_basecompar
        !et_return TYPE bapiret2_t .
    "! Salvar dados carregados na tabela
    "! @parameter it_doc | Tabela de documentos
    "! @parameter et_return | Tabela de mensagens
    METHODS upload_save_basecompar
      IMPORTING
        it_doc    TYPE zctgfi_basecompar OPTIONAL
      EXPORTING
        et_return TYPE bapiret2_t .
    METHODS upload_fill_data_famiprovi
      IMPORTING
        it_file   TYPE zctgfi_fami_provi
      EXPORTING
        et_doc    TYPE zctgfi_fami_provi_tab
        et_return TYPE bapiret2_t.
    METHODS upload_fill_data_famicresc
      IMPORTING
        it_file   TYPE zctgfi_fami_provi
      EXPORTING
        et_doc    TYPE zctgfi_fami_cresc_tab
        et_return TYPE bapiret2_t.
    METHODS upload_save_famiprovi
      IMPORTING
        it_doc    TYPE zctgfi_fami_provi_tab
      EXPORTING
        et_return TYPE bapiret2_t.
    METHODS upload_save_famicresc
      IMPORTING
        it_doc    TYPE zctgfi_fami_cresc_tab
      EXPORTING
        et_return TYPE bapiret2_t.

ENDCLASS.



CLASS ZCLFI_CARGA_CONTRAT_EXCEL IMPLEMENTATION.


  METHOD upload_cadaprovad.

    DATA: lt_file TYPE zctgfi_cad_aprovad.
    DATA: lt_doc  TYPE TABLE OF ztfi_cad_aprovad.
    DATA: lv_mimetype TYPE w3conttype.
*    DATA  lv_filetype  TYPE ze_carga_contratos.
    DATA  lv_filetype  TYPE c LENGTH 60.

    CONSTANTS lc_aprov_usuar(60)   TYPE c VALUE '10 - Aprovadores de Contrato Níveis / ZTFI_CAD_APROVAD'.

    lv_filetype = lc_aprov_usuar.

* ---------------------------------------------------------------------------
* Valida tipo de arquivo
* ---------------------------------------------------------------------------
    CALL FUNCTION 'SDOK_MIMETYPE_GET'
      EXPORTING
        extension = gc_xlsx
      IMPORTING
        mimetype  = lv_mimetype.

    IF is_media-mime_type NE lv_mimetype.
      " Formato de arquivo não suportado. Realizar nova carga com formato "xlsx".
      et_return[] = VALUE #( BASE et_return ( type = gc_e id = gc_msg number = gc_num1 ) ).
    ENDIF.

    CHECK NOT line_exists( et_return[ type = gc_e ] ).

* ---------------------------------------------------------------------------
* Converte arquivo excel para tabela
* ---------------------------------------------------------------------------
    DATA(lo_excel) = NEW zclca_excel( iv_filename = iv_filename
                                      iv_file     = is_media-value ).

    lo_excel->get_sheet( IMPORTING et_return = DATA(lt_return)
                         CHANGING  ct_table  = lt_file[] ).

    et_return[] = VALUE #( BASE et_return FOR ls_return IN lt_return ( ls_return ) ).

    CHECK NOT line_exists( et_return[ type = gc_e ] ).

* ---------------------------------------------------------------------------
* Preenche tabelas interna
* ---------------------------------------------------------------------------
    me->upload_fill_data_cadaprovad( EXPORTING
                            it_file     = lt_file[]
                          IMPORTING
                            et_doc      = lt_doc[]
                            et_return   = lt_return[] ).

    et_return[] = VALUE #( BASE et_return FOR ls_return IN lt_return ( ls_return ) ).
    CHECK NOT line_exists( et_return[ type = gc_e ] ).

* ---------------------------------------------------------------------------
* Salva registros
* ---------------------------------------------------------------------------
    me->upload_save_cadaprovad(
            EXPORTING
            it_doc = lt_doc[]
            IMPORTING
            et_return = lt_return[] ).

    APPEND LINES OF lt_return TO et_return.
    CLEAR: lt_return.

* ---------------------------------------------------------------------------
* Salva registros no Header
* ---------------------------------------------------------------------------
    me->upload_header( EXPORTING
                   iv_filetype   = lv_filetype
          IMPORTING
                   et_return     = lt_return ).

    APPEND LINES OF lt_return TO et_return.
    CLEAR: lt_return.

  ENDMETHOD.


  METHOD upload_fill_data_cadaprovad.

    DATA: lt_carga  TYPE zctgfi_cad_aprovad.

    FREE et_doc.

    lt_carga[] = it_file[].

    LOOP AT lt_carga ASSIGNING FIELD-SYMBOL(<fs_carga>).

      "Empresa, Local de Neg., Nível e Usuário são Obrigatórios
      IF <fs_carga>-bukrs IS INITIAL OR
         <fs_carga>-branch IS INITIAL OR
         <fs_carga>-nivel IS INITIAL OR
         <fs_carga>-bname IS INITIAL.

        APPEND INITIAL LINE TO et_return ASSIGNING FIELD-SYMBOL(<fs_erro>).
        <fs_erro>-id = gc_msg.
        <fs_erro>-type = gc_e.
        <fs_erro>-number = 009.

        CONTINUE.

      ENDIF.

      APPEND INITIAL LINE TO et_doc ASSIGNING FIELD-SYMBOL(<fs_doc>).
      <fs_doc>-bukrs    =  <fs_carga>-bukrs.
      <fs_doc>-branch   =  <fs_carga>-branch.
      <fs_doc>-nivel    =  <fs_carga>-nivel.
      <fs_doc>-bname    =  <fs_carga>-bname.
      <fs_doc>-email    =  <fs_carga>-email.
      <fs_doc>-created_by  = sy-uname.
      GET TIME STAMP FIELD <fs_doc>-created_at.
      <fs_doc>-local_last_changed_at = <fs_doc>-created_at.
    ENDLOOP.
  ENDMETHOD.


  METHOD upload_save_cadaprovad.

    IF it_doc[] IS NOT INITIAL.

      MODIFY ztfi_cad_aprovad FROM TABLE it_doc.

      IF sy-subrc NE 0.
        " Falha ao salvar dados de carga.
        et_return[] = VALUE #( BASE et_return ( type = gc_e id = gc_msg number = gc_num2 ) ).
        RETURN.
      ELSE.
        "Carga realizada com sucesso
        et_return[] = VALUE #( BASE et_return ( type = gc_s id = gc_msg number = gc_num6 ) ).
        "Processo finalizado
        et_return[] = VALUE #( BASE et_return ( type = gc_s id = gc_msg number = gc_num7 ) ).
      ENDIF.
    ENDIF.

  ENDMETHOD.


  METHOD upload_cadcc.

    DATA: lt_file TYPE zctgfi_cad_cc.
    DATA: lt_doc  TYPE TABLE OF ztfi_cad_cc.
    DATA: lv_mimetype TYPE w3conttype.
*    DATA  lv_filetype  TYPE ze_carga_contratos.
    DATA  lv_filetype  TYPE c LENGTH 60.

    CONSTANTS lc_cent_custo(35)    TYPE c VALUE '12 - Centro de Custos / ZTFI_CAD_CC'.

    lv_filetype = lc_cent_custo.

* ---------------------------------------------------------------------------
* Valida tipo de arquivo
* ---------------------------------------------------------------------------
    CALL FUNCTION 'SDOK_MIMETYPE_GET'
      EXPORTING
        extension = gc_xlsx
      IMPORTING
        mimetype  = lv_mimetype.

    IF is_media-mime_type NE lv_mimetype.
      " Formato de arquivo não suportado. Realizar nova carga com formato "xlsx".
      et_return[] = VALUE #( BASE et_return ( type = gc_e id = gc_msg number = gc_num1 ) ).
    ENDIF.

    CHECK NOT line_exists( et_return[ type = gc_e ] ).

* ---------------------------------------------------------------------------
* Converte arquivo excel para tabela
* ---------------------------------------------------------------------------
    DATA(lo_excel) = NEW zclca_excel( iv_filename = iv_filename
                                      iv_file     = is_media-value ).

    lo_excel->get_sheet( IMPORTING et_return = DATA(lt_return)
                         CHANGING  ct_table  = lt_file[] ).

    et_return[] = VALUE #( BASE et_return FOR ls_return IN lt_return ( ls_return ) ).

    CHECK NOT line_exists( et_return[ type = gc_e ] ).

* ---------------------------------------------------------------------------
* Preenche tabelas interna
* ---------------------------------------------------------------------------
    me->upload_fill_data_cadcc( EXPORTING
                                it_file     = lt_file[]
                                IMPORTING
                                et_doc      = lt_doc[]
                                et_return   = lt_return[] ).

    et_return[] = VALUE #( BASE et_return FOR ls_return IN lt_return ( ls_return ) ).
    CHECK NOT line_exists( et_return[ type = gc_e ] ).

* ---------------------------------------------------------------------------
* Salva registros
* ---------------------------------------------------------------------------
    me->upload_save_cadcc(
            EXPORTING
            it_doc = lt_doc[]
            IMPORTING
            et_return = lt_return[] ).

    APPEND LINES OF lt_return TO et_return.
    CLEAR: lt_return.

* ---------------------------------------------------------------------------
* Salva registros no Header
* ---------------------------------------------------------------------------
    me->upload_header( EXPORTING
                   iv_filetype   = lv_filetype
          IMPORTING
                   et_return     = lt_return ).

    APPEND LINES OF lt_return TO et_return.
    CLEAR: lt_return.

  ENDMETHOD.


  METHOD upload_fill_data_cadcc.

    DATA: lt_carga  TYPE zctgfi_cad_cc .

    FREE et_doc.

    lt_carga[] = it_file[].

    LOOP AT lt_carga ASSIGNING FIELD-SYMBOL(<fs_carga>).

      APPEND INITIAL LINE TO et_doc ASSIGNING FIELD-SYMBOL(<fs_doc>).
      <fs_doc>-region   =  <fs_carga>-region.
*      <fs_doc>-canal    =  <fs_carga>-canal.
*      <fs_doc>-setor    =  <fs_carga>-setor.
      <fs_doc>-kostl    =  <fs_carga>-kostl.
      <fs_doc>-created_by = sy-uname.
      GET TIME STAMP FIELD <fs_doc>-created_at.
      <fs_doc>-local_last_changed_at = <fs_doc>-created_at.
    ENDLOOP.

  ENDMETHOD.


  METHOD upload_save_cadcc.

    IF it_doc[] IS NOT INITIAL.

      MODIFY ztfi_cad_cc FROM TABLE it_doc.

      IF sy-subrc NE 0.
        " Falha ao salvar dados de carga.
        et_return[] = VALUE #( BASE et_return ( type = gc_e id = gc_msg number = gc_num2 ) ).
        RETURN.
      ELSE.
        "Carga realizada com sucesso
        et_return[] = VALUE #( BASE et_return ( type = gc_s id = gc_msg number = gc_num6 ) ).
        "Processo finalizado
        et_return[] = VALUE #( BASE et_return ( type = gc_s id = gc_msg number = gc_num7 ) ).
      ENDIF.
    ENDIF.

  ENDMETHOD.


  METHOD upload_cadcond.

    DATA: lt_file TYPE zctgfi_cad_cond.
    DATA: lt_doc  TYPE TABLE OF ztfi_cad_cond.
    DATA: lv_mimetype TYPE w3conttype.
*    DATA  lv_filetype  TYPE ze_carga_contratos.
    DATA  lv_filetype  TYPE c LENGTH 60.

    CONSTANTS lc_cond_desc(41)   TYPE c VALUE '4 - Condições de Desconto / ZTFI_CAD_COND'.

    lv_filetype = lc_cond_desc.

* ---------------------------------------------------------------------------
* Valida tipo de arquivo
* ---------------------------------------------------------------------------
    CALL FUNCTION 'SDOK_MIMETYPE_GET'
      EXPORTING
        extension = gc_xlsx
      IMPORTING
        mimetype  = lv_mimetype.

    IF is_media-mime_type NE lv_mimetype.
      " Formato de arquivo não suportado. Realizar nova carga com formato "xlsx".
      et_return[] = VALUE #( BASE et_return ( type = gc_e id = gc_msg number = gc_num1 ) ).
    ENDIF.

    CHECK NOT line_exists( et_return[ type = gc_e ] ).

* ---------------------------------------------------------------------------
* Converte arquivo excel para tabela
* ---------------------------------------------------------------------------
    DATA(lo_excel) = NEW zclca_excel( iv_filename = iv_filename
                                      iv_file     = is_media-value ).

    lo_excel->get_sheet( IMPORTING et_return = DATA(lt_return)
                         CHANGING  ct_table  = lt_file[] ).

    et_return[] = VALUE #( BASE et_return FOR ls_return IN lt_return ( ls_return ) ).

    CHECK NOT line_exists( et_return[ type = gc_e ] ).

* ---------------------------------------------------------------------------
* Preenche tabelas interna
* ---------------------------------------------------------------------------
    me->upload_fill_data_cadcond( EXPORTING
                            it_file     = lt_file[]
                          IMPORTING
                            et_doc      = lt_doc[]
                            et_return   = lt_return[] ).

    et_return[] = VALUE #( BASE et_return FOR ls_return IN lt_return ( ls_return ) ).
    CHECK NOT line_exists( et_return[ type = gc_e ] ).

* ---------------------------------------------------------------------------
* Salva registros
* ---------------------------------------------------------------------------
    me->upload_save_cadcond(
            EXPORTING
            it_doc = lt_doc[]
            IMPORTING
            et_return = lt_return[] ).

    APPEND LINES OF lt_return TO et_return.
    CLEAR: lt_return.
* ---------------------------------------------------------------------------
* Salva registros no Header
* ---------------------------------------------------------------------------
    me->upload_header( EXPORTING
                                iv_filetype   = lv_filetype
                       IMPORTING
                                et_return     = lt_return ).

    APPEND LINES OF lt_return TO et_return.
    CLEAR: lt_return.

  ENDMETHOD.


  METHOD upload_fill_data_cadcond.

    DATA: lt_carga  TYPE zctgfi_cad_cond .

    FREE et_doc.

    lt_carga[] = it_file[].

    LOOP AT lt_carga ASSIGNING FIELD-SYMBOL(<fs_carga>).

      APPEND INITIAL LINE TO et_doc ASSIGNING FIELD-SYMBOL(<fs_doc>).

      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
        EXPORTING
          input  = <fs_carga>-tipo_cond
        IMPORTING
          output = <fs_doc>-tipo_cond.

      <fs_doc>-text_tipo_cond =  <fs_carga>-text_tipo_cond.
      <fs_doc>-created_by = sy-uname.
      GET TIME STAMP FIELD <fs_doc>-created_at.
      <fs_doc>-local_last_changed_at = <fs_doc>-created_at.

    ENDLOOP.

  ENDMETHOD.


  METHOD upload_save_cadcond.

    IF it_doc[] IS NOT INITIAL.

      MODIFY ztfi_cad_cond FROM TABLE it_doc.

      IF sy-subrc NE 0.
        " Falha ao salvar dados de carga.
        et_return[] = VALUE #( BASE et_return ( type = gc_e id = gc_msg number = gc_num2 ) ).
        RETURN.

      ELSE.
        "Carga realizada com sucesso
        et_return[] = VALUE #( BASE et_return ( type = gc_s id = gc_msg number = gc_num6 ) ).
        "Processo finalizado
        et_return[] = VALUE #( BASE et_return ( type = gc_s id = gc_msg number = gc_num7 ) ).

      ENDIF.
    ENDIF.

  ENDMETHOD.


  METHOD upload_cadnivel.

    DATA: lt_file TYPE zctgfi_cad_nivel.
    DATA: lt_doc  TYPE TABLE OF ztfi_cad_nivel.
    DATA: lv_mimetype TYPE w3conttype.
*    DATA  lv_filetype  TYPE ze_carga_contratos.
    DATA  lv_filetype  TYPE c LENGTH 60.

    CONSTANTS lc_niveis_aprov(40)  TYPE c VALUE '9 - Níveis de Aprovação / ZTFI_CAD_NIVEL'.

    lv_filetype = lc_niveis_aprov.

* ---------------------------------------------------------------------------
* Valida tipo de arquivo
* ---------------------------------------------------------------------------
    CALL FUNCTION 'SDOK_MIMETYPE_GET'
      EXPORTING
        extension = gc_xlsx
      IMPORTING
        mimetype  = lv_mimetype.

    IF is_media-mime_type NE lv_mimetype.
      " Formato de arquivo não suportado. Realizar nova carga com formato "xlsx".
      et_return[] = VALUE #( BASE et_return ( type = gc_e id = gc_msg number = gc_num1 ) ).
    ENDIF.

    CHECK NOT line_exists( et_return[ type = gc_e ] ).

* ---------------------------------------------------------------------------
* Converte arquivo excel para tabela
* ---------------------------------------------------------------------------
    DATA(lo_excel) = NEW zclca_excel( iv_filename = iv_filename
                                      iv_file     = is_media-value ).

    lo_excel->get_sheet( IMPORTING et_return = DATA(lt_return)
                         CHANGING  ct_table  = lt_file[] ).

    et_return[] = VALUE #( BASE et_return FOR ls_return IN lt_return ( ls_return ) ).

    CHECK NOT line_exists( et_return[ type = gc_e ] ).

* ---------------------------------------------------------------------------
* Preenche tabelas interna
* ---------------------------------------------------------------------------
    me->upload_fill_data_cadnivel( EXPORTING
                            it_file     = lt_file[]
                          IMPORTING
                            et_doc      = lt_doc[]
                            et_return   = lt_return[] ).

    et_return[] = VALUE #( BASE et_return FOR ls_return IN lt_return ( ls_return ) ).
    CHECK NOT line_exists( et_return[ type = gc_e ] ).

* ---------------------------------------------------------------------------
* Salva registros
* ---------------------------------------------------------------------------
    me->upload_save_cadnivel(
            EXPORTING
            it_doc = lt_doc[]
            IMPORTING
            et_return = lt_return[] ).

    APPEND LINES OF lt_return TO et_return.
    CLEAR: lt_return.

* ---------------------------------------------------------------------------
* Salva registros no Header
* ---------------------------------------------------------------------------
    me->upload_header( EXPORTING
                   iv_filetype   = lv_filetype
          IMPORTING
                   et_return     = lt_return ).

    APPEND LINES OF lt_return TO et_return.
    CLEAR: lt_return.

  ENDMETHOD.


  METHOD upload_fill_data_cadnivel.

    DATA: lt_carga  TYPE zctgfi_cad_nivel.

    FREE et_doc.

    lt_carga[] = it_file[].

    LOOP AT lt_carga ASSIGNING FIELD-SYMBOL(<fs_carga>).

      APPEND INITIAL LINE TO et_doc ASSIGNING FIELD-SYMBOL(<fs_doc>).
      <fs_doc>-nivel      =  <fs_carga>-nivel.
      <fs_doc>-desc_nivel =  <fs_carga>-desc_nivel.
      <fs_doc>-created_by = sy-uname.
      GET TIME STAMP FIELD <fs_doc>-created_at.
      <fs_doc>-local_last_changed_at = <fs_doc>-created_at.

    ENDLOOP.

  ENDMETHOD.


  METHOD upload_save_cadnivel.

    IF it_doc[] IS NOT INITIAL.

      MODIFY ztfi_cad_nivel FROM TABLE it_doc.

      IF sy-subrc NE 0.
        " Falha ao salvar dados de carga.
        et_return[] = VALUE #( BASE et_return ( type = gc_e id = gc_msg number = gc_num2 ) ).
        RETURN.
      ELSE.
        "Carga realizada com sucesso
        et_return[] = VALUE #( BASE et_return ( type = gc_s id = gc_msg number = gc_num6 ) ).
        "Processo finalizado
        et_return[] = VALUE #( BASE et_return ( type = gc_s id = gc_msg number = gc_num7 ) ).
      ENDIF.
    ENDIF.

  ENDMETHOD.


  METHOD upload_cadsemcont.

    DATA: lt_file TYPE zctgfi_cad_semcont.
    DATA: lt_doc  TYPE TABLE OF ztfi_cad_semcont.
    DATA: lv_mimetype TYPE w3conttype.

* ---------------------------------------------------------------------------
* Valida tipo de arquivo
* ---------------------------------------------------------------------------
    CALL FUNCTION 'SDOK_MIMETYPE_GET'
      EXPORTING
        extension = gc_xlsx
      IMPORTING
        mimetype  = lv_mimetype.

    IF is_media-mime_type NE lv_mimetype.
      " Formato de arquivo não suportado. Realizar nova carga com formato "xlsx".
      et_return[] = VALUE #( BASE et_return ( type = gc_e id = gc_msg number = gc_num1 ) ).
    ENDIF.

    CHECK NOT line_exists( et_return[ type = gc_e ] ).

* ---------------------------------------------------------------------------
* Converte arquivo excel para tabela
* ---------------------------------------------------------------------------
    DATA(lo_excel) = NEW zclca_excel( iv_filename = iv_filename
                                      iv_file     = is_media-value ).

    lo_excel->get_sheet( IMPORTING et_return = DATA(lt_return)
                         CHANGING  ct_table  = lt_file[] ).

    et_return[] = VALUE #( BASE et_return FOR ls_return IN lt_return ( ls_return ) ).

    CHECK NOT line_exists( et_return[ type = gc_e ] ).

* ---------------------------------------------------------------------------
* Preenche tabelas interna
* ---------------------------------------------------------------------------
    me->upload_fill_data_cadsemcont( EXPORTING
                            it_file     = lt_file[]
                          IMPORTING
                            et_doc      = lt_doc[]
                            et_return   = lt_return[] ).

    et_return[] = VALUE #( BASE et_return FOR ls_return IN lt_return ( ls_return ) ).
    CHECK NOT line_exists( et_return[ type = gc_e ] ).

* ---------------------------------------------------------------------------
* Salva registros
* ---------------------------------------------------------------------------
    me->upload_save_cadsemcont(
            EXPORTING
            it_doc = lt_doc[]
            IMPORTING
            et_return = lt_return[] ).

  ENDMETHOD.


  METHOD upload_fill_data_cadsemcont.

    DATA: lt_carga  TYPE zctgfi_cad_semcont.

    FREE et_doc.

    lt_carga[] = it_file[].

    LOOP AT lt_carga ASSIGNING FIELD-SYMBOL(<fs_carga>).

      APPEND INITIAL LINE TO et_doc ASSIGNING FIELD-SYMBOL(<fs_doc>).
      <fs_doc>-bukrs      =  <fs_carga>-bukrs.
      <fs_doc>-kunnr      =  <fs_carga>-kunnr.
      <fs_doc>-grupo_cond =  <fs_carga>-grupo_cond.
      <fs_doc>-dia_fixo   =  <fs_carga>-dia_fixo.
      <fs_doc>-dia_semana =  <fs_carga>-dia_semana.
      <fs_doc>-created_by = sy-uname.
      GET TIME STAMP FIELD <fs_doc>-created_at.
      <fs_doc>-local_last_changed_at = <fs_doc>-created_at.

    ENDLOOP.

  ENDMETHOD.


  METHOD upload_save_cadsemcont.

    IF it_doc[] IS NOT INITIAL.

      MODIFY ztfi_cad_semcont FROM TABLE it_doc.

      IF sy-subrc NE 0.
        " Falha ao salvar dados de carga.
        et_return[] = VALUE #( BASE et_return ( type = gc_e id = gc_msg number = gc_num2 ) ).
        RETURN.
      ENDIF.
    ENDIF.

  ENDMETHOD.


  METHOD upload_cnpjclient.

    DATA: lt_file TYPE zctgfi_cnpj_client.
    DATA: lt_doc  TYPE TABLE OF ztfi_cnpj_client.
    DATA: lv_mimetype TYPE w3conttype.
*    DATA  lv_filetype  TYPE ze_carga_contratos.
    DATA  lv_filetype  TYPE c LENGTH 60.

    CONSTANTS lc_client_cnpj(60)   TYPE c VALUE '3 - Clientes da Raiz CNPJ Principal / ZTFI_CNPJ_CLIENT'.

    lv_filetype = lc_client_cnpj.

* ---------------------------------------------------------------------------
* Valida tipo de arquivo
* ---------------------------------------------------------------------------
    CALL FUNCTION 'SDOK_MIMETYPE_GET'
      EXPORTING
        extension = gc_xlsx
      IMPORTING
        mimetype  = lv_mimetype.

    IF is_media-mime_type NE lv_mimetype.
      " Formato de arquivo não suportado. Realizar nova carga com formato "xlsx".
      et_return[] = VALUE #( BASE et_return ( type = gc_e id = gc_msg number = gc_num1 ) ).
    ENDIF.

    CHECK NOT line_exists( et_return[ type = gc_e ] ).

* ---------------------------------------------------------------------------
* Converte arquivo excel para tabela
* ---------------------------------------------------------------------------
    DATA(lo_excel) = NEW zclca_excel( iv_filename = iv_filename
                                      iv_file     = is_media-value ).

    lo_excel->get_sheet( IMPORTING et_return = DATA(lt_return)
                         CHANGING  ct_table  = lt_file[] ).

    et_return[] = VALUE #( BASE et_return FOR ls_return IN lt_return ( ls_return ) ).

    CHECK NOT line_exists( et_return[ type = gc_e ] ).

* ---------------------------------------------------------------------------
* Preenche tabelas interna
* ---------------------------------------------------------------------------
    me->upload_fill_data_cnpjclient( EXPORTING
                            it_file     = lt_file[]
                          IMPORTING
                            et_doc      = lt_doc[]
                            et_return   = lt_return[] ).

    et_return[] = VALUE #( BASE et_return FOR ls_return IN lt_return ( ls_return ) ).
    CHECK NOT line_exists( et_return[ type = gc_e ] ).

* ---------------------------------------------------------------------------
* Salva registros
* ---------------------------------------------------------------------------
    me->upload_save_cnpjclient(
            EXPORTING
            it_doc = lt_doc[]
            IMPORTING
            et_return = lt_return[] ).

    APPEND LINES OF lt_return TO et_return.
    CLEAR: lt_return.

* ---------------------------------------------------------------------------
* Salva registros no Header
* ---------------------------------------------------------------------------
    me->upload_header( EXPORTING
                   iv_filetype   = lv_filetype
          IMPORTING
                   et_return     = lt_return ).

    APPEND LINES OF lt_return TO et_return.
    CLEAR: lt_return.

  ENDMETHOD.


  METHOD upload_fill_data_cnpjclient.

    DATA: lt_carga  TYPE zctgfi_cnpj_client.
    DATA: lv_index TYPE sy-tabix.

    FREE et_doc.

    lt_carga[] = it_file[].

    LOOP AT lt_carga ASSIGNING FIELD-SYMBOL(<fs_carga_aux>).

      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
        EXPORTING
          input  = <fs_carga_aux>-contrato
        IMPORTING
          output = <fs_carga_aux>-contrato.

    ENDLOOP.
    DATA(lt_carga_aux) = lt_carga[].
    SORT lt_carga_aux BY contrato aditivo.
    DELETE ADJACENT DUPLICATES FROM lt_carga_aux COMPARING contrato aditivo.



    IF lt_carga_aux[] IS NOT INITIAL.
      SELECT doc_uuid_h, contrato, aditivo
        FROM ztfi_contrato
        INTO TABLE @DATA(lt_contrato)
        FOR ALL ENTRIES IN @lt_carga_aux
        WHERE contrato = @lt_carga_aux-contrato
          AND aditivo = @lt_carga_aux-aditivo.
      IF sy-subrc IS INITIAL.
        SORT lt_contrato BY contrato aditivo.

        DATA(lt_contrato_aux) = lt_contrato[].
        SORT lt_contrato_aux BY doc_uuid_h contrato aditivo.
        DELETE ADJACENT DUPLICATES FROM lt_contrato_aux COMPARING doc_uuid_h contrato aditivo.
        IF lt_contrato_aux[] IS NOT INITIAL.
          SELECT doc_uuid_h, doc_uuid_raiz, contrato, aditivo
          FROM ztfi_raiz_cnpj
          INTO TABLE @DATA(lt_raiz)
          FOR ALL ENTRIES IN @lt_contrato_aux
          WHERE doc_uuid_h = @lt_contrato_aux-doc_uuid_h
            AND contrato   = @lt_contrato_aux-contrato
            AND aditivo    = @lt_contrato_aux-aditivo.
          IF sy-subrc IS INITIAL.

            SORT lt_raiz BY doc_uuid_h contrato aditivo.

          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.

    LOOP AT lt_carga ASSIGNING FIELD-SYMBOL(<fs_carga>).
      lv_index = sy-tabix.

      APPEND INITIAL LINE TO et_doc ASSIGNING FIELD-SYMBOL(<fs_doc>).
      READ TABLE lt_contrato ASSIGNING FIELD-SYMBOL(<fs_contrato>) WITH KEY contrato = <fs_carga>-contrato
                                                                            aditivo = <fs_carga>-aditivo
                                                                      BINARY SEARCH.
      IF sy-subrc IS INITIAL.
        <fs_doc>-doc_uuid_h      =   <fs_contrato>-doc_uuid_h.

        READ TABLE lt_raiz ASSIGNING FIELD-SYMBOL(<fs_raiz>) WITH KEY doc_uuid_h = <fs_contrato>-doc_uuid_h
                                                                      contrato   = <fs_carga>-contrato
                                                                       aditivo = <fs_carga>-aditivo
                                                                      BINARY SEARCH.
        IF sy-subrc IS INITIAL.
          "Registro já existente na tabela: &1 linha &2
          APPEND INITIAL LINE TO et_return ASSIGNING FIELD-SYMBOL(<fs_erro>).
          <fs_erro>-number = 008.

*          <fs_doc>-doc_uuid_raiz     =   <fs_raiz>-doc_uuid_raiz.

        ENDIF.
      ENDIF.
      <fs_doc>-contrato      =  <fs_carga>-contrato.
      <fs_doc>-aditivo       =  <fs_carga>-aditivo.
      <fs_doc>-cnpj_raiz     =  <fs_carga>-cnpj_raiz.
      <fs_doc>-cliente       =  <fs_carga>-cliente.
      <fs_doc>-cnpj          =  <fs_carga>-cnpj.
      <fs_doc>-nome1         =  <fs_carga>-nome1.
      <fs_doc>-classif_cnpj  =  <fs_carga>-classif_cnpj.
      <fs_doc>-created_by    = sy-uname.
      GET TIME STAMP FIELD <fs_doc>-created_at.
      <fs_doc>-local_last_changed_at = <fs_doc>-created_at.

    ENDLOOP.

  ENDMETHOD.


  METHOD upload_save_cnpjclient.


    IF it_doc[] IS NOT INITIAL.

      MODIFY ztfi_cnpj_client FROM TABLE it_doc.

      IF sy-subrc NE 0.
        " Falha ao salvar dados de carga.
        et_return[] = VALUE #( BASE et_return ( type = gc_e id = gc_msg number = gc_num2 ) ).
        RETURN.
      ELSE.
        "Carga realizada com sucesso
        et_return[] = VALUE #( BASE et_return ( type = gc_s id = gc_msg number = gc_num6 ) ).
        "Processo finalizado
        et_return[] = VALUE #( BASE et_return ( type = gc_s id = gc_msg number = gc_num7 ) ).
      ENDIF.
    ENDIF.

  ENDMETHOD.


  METHOD upload_contrato.

    DATA: lt_file TYPE zctgfi_contrato_excel.
    DATA: lt_doc  TYPE TABLE OF ztfi_contrato.
    DATA: lv_mimetype TYPE w3conttype.
*    DATA  lv_filetype  TYPE ze_carga_contratos.
    DATA  lv_filetype  TYPE c LENGTH 60.

    CONSTANTS lc_contrato(29)       TYPE c VALUE '1 - Contratos / ZTFI_CONTRATO'.

    lv_filetype = lc_contrato.

* ---------------------------------------------------------------------------
* Valida tipo de arquivo
* ---------------------------------------------------------------------------
    CALL FUNCTION 'SDOK_MIMETYPE_GET'
      EXPORTING
        extension = gc_xlsx
      IMPORTING
        mimetype  = lv_mimetype.

    IF is_media-mime_type NE lv_mimetype.
      " Formato de arquivo não suportado. Realizar nova carga com formato "xlsx".
      et_return[] = VALUE #( BASE et_return ( type = gc_e id = gc_msg number = gc_num1 ) ).
    ENDIF.

    CHECK NOT line_exists( et_return[ type = gc_e ] ).

* ---------------------------------------------------------------------------
* Converte arquivo excel para tabela
* ---------------------------------------------------------------------------
    DATA(lo_excel) = NEW zclca_excel( iv_filename = iv_filename
                                      iv_file     = is_media-value ).

    lo_excel->get_sheet( IMPORTING et_return = DATA(lt_return)
                         CHANGING  ct_table  = lt_file[] ).

    et_return[] = VALUE #( BASE et_return FOR ls_return IN lt_return ( ls_return ) ).

    CHECK NOT line_exists( et_return[ type = gc_e ] ).

* ---------------------------------------------------------------------------
* Preenche tabelas interna
* ---------------------------------------------------------------------------
    me->upload_fill_data_contrato( EXPORTING
                            it_file     = lt_file[]
                          IMPORTING
                            et_doc      = lt_doc[]
                            et_return   = lt_return[] ).

    et_return[] = VALUE #( BASE et_return FOR ls_return IN lt_return ( ls_return ) ).
    CHECK NOT line_exists( et_return[ type = gc_e ] ).

* ---------------------------------------------------------------------------
* Salva registros
* ---------------------------------------------------------------------------
    me->upload_save_contrato(
            EXPORTING
            it_doc = lt_doc[]
            IMPORTING
            et_return = lt_return[] ).

    APPEND LINES OF lt_return TO et_return.
    CLEAR: lt_return.
* ---------------------------------------------------------------------------
* Salva registros no Header
* ---------------------------------------------------------------------------
    me->upload_header( EXPORTING
                   iv_filetype   = lv_filetype
          IMPORTING
                   et_return     = lt_return ).

    APPEND LINES OF lt_return TO et_return.
    CLEAR: lt_return.

  ENDMETHOD.


  METHOD upload_fill_data_contrato.

    DATA: lt_carga  TYPE zctgfi_contrato.
    DATA: lv_number TYPE ze_num_contrato.
    DATA: lv_index TYPE sy-tabix.
    DATA: lv_qtd_aditivo TYPE ze_num_aditivo .


    FREE et_doc.
    CLEAR lv_number.

*    lt_carga[] = it_file[].

    LOOP AT it_file ASSIGNING FIELD-SYMBOL(<fs_carga>).

      lv_index = sy-tabix.


      APPEND INITIAL LINE TO et_doc ASSIGNING FIELD-SYMBOL(<fs_doc>).

      IF <fs_carga>-aditivo IS NOT INITIAL AND
         <fs_carga>-contrato IS INITIAL.
        "Erro linha: &1 N° Contrato em branco
        et_return[] = VALUE #( BASE et_return ( type = gc_e id = gc_msg number = '003'
                                                message_v1 = lv_index  ) ).
      ENDIF.

      IF <fs_carga>-aditivo IS NOT INITIAL AND
         <fs_carga>-contrato IS NOT INITIAL.

        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
          EXPORTING
            input  = <fs_carga>-contrato
          IMPORTING
            output = lv_number.

        SELECT COUNT(*)
               FROM ztfi_contrato
               WHERE contrato = lv_number.

        IF sy-subrc = 0.

          lv_qtd_aditivo = lv_number && '-' && sy-dbcnt.
          CONDENSE lv_qtd_aditivo NO-GAPS.
          <fs_doc>-contrato           = lv_number.
          <fs_doc>-aditivo           = lv_qtd_aditivo.

          UPDATE ztfi_contrato
            SET status = '7'
            WHERE contrato = lv_number
              AND aditivo = space.
          IF sy-subrc = 0.
            COMMIT WORK AND WAIT.
          ENDIF.


        ELSE.

          "Erro linha: &1 Contrato não localizado
          et_return[] = VALUE #( BASE et_return ( type = gc_e id = gc_msg number = '004'
                                                  message_v1 = lv_index  ) ).
        ENDIF.

      ENDIF.


      <fs_doc>-mandt = sy-mandt.
      <fs_doc>-doc_uuid_h        =  me->get_next_guid( ).


      IF <fs_doc>-contrato IS INITIAL.
        CALL FUNCTION 'NUMBER_GET_NEXT'
          EXPORTING
            nr_range_nr             = '01'
            object                  = 'ZFICONTRAT'
          IMPORTING
            number                  = lv_number
          EXCEPTIONS
            interval_not_found      = 1
            number_range_not_intern = 2
            object_not_found        = 3
            quantity_is_0           = 4
            quantity_is_not_1       = 5
            interval_overflow       = 6
            buffer_overflow         = 7
            OTHERS                  = 8.
        IF sy-subrc = 0.
          <fs_doc>-contrato          =  lv_number.
        ENDIF.

      ENDIF.

      <fs_doc>-contrato_proprio  =  <fs_carga>-contrato_proprio.
      <fs_doc>-contrato_jurid    =  <fs_carga>-contrato_jurid.
      <fs_doc>-data_ini_valid    =  <fs_carga>-data_ini_valid .
      <fs_doc>-data_fim_valid    =  <fs_carga>-data_fim_valid.
      <fs_doc>-bukrs             =  <fs_carga>-bukrs.
      <fs_doc>-branch            =  <fs_carga>-branch.
      <fs_doc>-grp_contratos     =  <fs_carga>-grp_contratos .
      <fs_doc>-grp_cond          =  <fs_carga>-grp_cond.
      <fs_doc>-chamado           =  <fs_carga>-chamado.
      <fs_doc>-cnpj_principal    =  <fs_carga>-cnpj_principal.
      <fs_doc>-razao_social      =  <fs_carga>-razao_social.
      <fs_doc>-nome_fantasia     =  <fs_carga>-nome_fantasia.
      <fs_doc>-prazo_pagto       =  <fs_carga>-prazo_pagto.
      <fs_doc>-forma_pagto       =  <fs_carga>-forma_pagto.
      <fs_doc>-resp_legal        =  <fs_carga>-resp_legal.
      <fs_doc>-resp_legal_gtcor  =  <fs_carga>-resp_legal_gtcor.
      <fs_doc>-prod_contemplado  =  <fs_carga>-prod_contemplado.
      <fs_doc>-observacao        =  <fs_carga>-observacao.
      <fs_doc>-status            =  <fs_carga>-status.
      <fs_doc>-status_anexo      =  <fs_carga>-status_anexo.
      <fs_doc>-desativado        =  <fs_carga>-desativado.
      <fs_doc>-canal             =  <fs_carga>-canal.
      <fs_doc>-grp_economico     =  <fs_carga>-grp_economico.
      <fs_doc>-abrangencia       =  <fs_carga>-abrangencia.
      <fs_doc>-estrutura         =  <fs_carga>-estrutura.
      <fs_doc>-canalpdv          =  <fs_carga>-canalpdv.
      <fs_doc>-tipo_entrega      =  <fs_carga>-tipo_entrega.
      <fs_doc>-data_entrega      =  <fs_carga>-data_entrega.
      <fs_doc>-data_fatura       =  <fs_carga>-data_fatura.
      <fs_doc>-crescimento       =  <fs_carga>-crescimento.
      <fs_doc>-ajuste_anual      =  <fs_carga>-ajuste_anual.
      <fs_doc>-data_assinatura   =  <fs_carga>-data_assinatura.
      <fs_doc>-multas            =  <fs_carga>-multas.
      <fs_doc>-renov_aut         =  <fs_carga>-renov_aut.
      <fs_doc>-alerta_vig        =  <fs_carga>-alerta_vig.
      <fs_doc>-alerta_enviado    =  <fs_carga>-alerta_enviado.
      <fs_doc>-alerta_data_envio =  <fs_carga>-alerta_data_envio.
      <fs_doc>-created_by        = sy-uname.
      GET TIME STAMP FIELD <fs_doc>-created_at.
      <fs_doc>-local_last_changed_at = <fs_doc>-created_at.
      <fs_doc>-aprov1           =  <fs_carga>-aprov1.
      <fs_doc>-dataaprov1       =  <fs_carga>-dataaprov1.
      <fs_doc>-hora_aprov1      =  <fs_carga>-hora_aprov1.
      <fs_doc>-aprov2           =  <fs_carga>-aprov2.
      <fs_doc>-dataaprov2       =  <fs_carga>-dataaprov2.
      <fs_doc>-hora_aprov2      =  <fs_carga>-hora_aprov2.
      <fs_doc>-aprov3           =  <fs_carga>-aprov3.
      <fs_doc>-dataaprov3       =  <fs_carga>-dataaprov3.
      <fs_doc>-hora_aprov3      =  <fs_carga>-hora_aprov3.
      <fs_doc>-aprov4           =  <fs_carga>-hora_aprov3.
      <fs_doc>-dataaprov4       =  <fs_carga>-dataaprov4.
      <fs_doc>-hora_aprov4      =  <fs_carga>-hora_aprov4.
      <fs_doc>-aprov5           =  <fs_carga>-aprov5.
      <fs_doc>-dataaprov5       =  <fs_carga>-dataaprov5.
      <fs_doc>-hora_aprov5      =  <fs_carga>-hora_aprov5.
      <fs_doc>-aprov6           =  <fs_carga>-aprov6.
      <fs_doc>-dataaprov6       =  <fs_carga>-dataaprov6.
      <fs_doc>-hora_aprov6      =  <fs_carga>-hora_aprov6.
      <fs_doc>-aprov7           =  <fs_carga>-aprov7.
      <fs_doc>-dataaprov7       =  <fs_carga>-dataaprov7.
      <fs_doc>-hora_aprov7      =  <fs_carga>-hora_aprov7.
      <fs_doc>-aprov8           =  <fs_carga>-aprov8.
      <fs_doc>-dataaprov8       =  <fs_carga>-dataaprov8.
      <fs_doc>-hora_aprov8      =  <fs_carga>-hora_aprov8.
      <fs_doc>-aprov9           =  <fs_carga>-aprov9.
      <fs_doc>-dataaprov9       =  <fs_carga>-dataaprov9.
      <fs_doc>-hora_aprov9      =  <fs_carga>-hora_aprov9.
      <fs_doc>-aprov10          =  <fs_carga>-aprov10.
      <fs_doc>-dataaprov10      =  <fs_carga>-dataaprov10.
      <fs_doc>-hora_aprov10     =  <fs_carga>-hora_aprov10.


    ENDLOOP.

  ENDMETHOD.


  METHOD upload_save_contrato.

    IF it_doc[] IS NOT INITIAL.

      MODIFY ztfi_contrato FROM TABLE it_doc.

      IF sy-subrc NE 0.
        " Falha ao salvar dados de carga.
        et_return[] = VALUE #( BASE et_return ( type = gc_e id = gc_msg number = gc_num2 ) ).
        RETURN.
      ELSE.
        "Carga realizada com sucesso
        et_return[] = VALUE #( BASE et_return ( type = gc_s id = gc_msg number = gc_num6 ) ).
        "Processo finalizado
        et_return[] = VALUE #( BASE et_return ( type = gc_s id = gc_msg number = gc_num7 ) ).
      ENDIF.
    ENDIF.

  ENDMETHOD.


  METHOD upload_contcond.

    DATA: lt_file TYPE zctgfi_cont_cond.
    DATA: lt_doc  TYPE TABLE OF ztfi_cont_cond.
    DATA: lv_mimetype TYPE w3conttype.
*    DATA  lv_filetype  TYPE ze_carga_contratos.
    DATA  lv_filetype  TYPE c LENGTH 60.

    CONSTANTS lc_cont_cont(42)     TYPE c VALUE '5 - Condição de Contratos / ZTFI_CONT_COND'.

    lv_filetype = lc_cont_cont.

* ---------------------------------------------------------------------------
* Valida tipo de arquivo
* ---------------------------------------------------------------------------
    CALL FUNCTION 'SDOK_MIMETYPE_GET'
      EXPORTING
        extension = gc_xlsx
      IMPORTING
        mimetype  = lv_mimetype.

    IF is_media-mime_type NE lv_mimetype.
      " Formato de arquivo não suportado. Realizar nova carga com formato "xlsx".
      et_return[] = VALUE #( BASE et_return ( type = gc_e id = gc_msg number = gc_num1 ) ).
    ENDIF.

    CHECK NOT line_exists( et_return[ type = gc_e ] ).

* ---------------------------------------------------------------------------
* Converte arquivo excel para tabela
* ---------------------------------------------------------------------------
    DATA(lo_excel) = NEW zclca_excel( iv_filename = iv_filename
                                      iv_file     = is_media-value ).

    lo_excel->get_sheet( IMPORTING et_return = DATA(lt_return)
                         CHANGING  ct_table  = lt_file[] ).

    et_return[] = VALUE #( BASE et_return FOR ls_return IN lt_return ( ls_return ) ).

    CHECK NOT line_exists( et_return[ type = gc_e ] ).

* ---------------------------------------------------------------------------
* Preenche tabelas interna
* ---------------------------------------------------------------------------
    me->upload_fill_data_contcond( EXPORTING
                            it_file     = lt_file[]
                          IMPORTING
                            et_doc      = lt_doc[]
                            et_return   = lt_return[] ).

    et_return[] = VALUE #( BASE et_return FOR ls_return IN lt_return ( ls_return ) ).
    CHECK NOT line_exists( et_return[ type = gc_e ] ).

* ---------------------------------------------------------------------------
* Salva registros
* ---------------------------------------------------------------------------
    me->upload_save_contcond(
            EXPORTING
            it_doc = lt_doc[]
            IMPORTING
            et_return = lt_return[] ).

    APPEND LINES OF lt_return TO et_return.
    CLEAR: lt_return.

* ---------------------------------------------------------------------------
* Salva registros no Header
* ---------------------------------------------------------------------------
    me->upload_header( EXPORTING
                   iv_filetype   = lv_filetype
          IMPORTING
                   et_return     = lt_return[] ).

    APPEND LINES OF lt_return TO et_return.
    CLEAR: lt_return.

  ENDMETHOD.


  METHOD upload_fill_data_contcond.

    DATA: lt_carga  TYPE zctgfi_cont_cond.

    FREE et_doc.



    lt_carga[] = it_file[].

    LOOP AT lt_carga ASSIGNING FIELD-SYMBOL(<fs_carga_aux>).

      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
        EXPORTING
          input  = <fs_carga_aux>-contrato
        IMPORTING
          output = <fs_carga_aux>-contrato.

    ENDLOOP.
    DATA(lt_carga_aux) = lt_carga[].
    SORT lt_carga_aux BY contrato aditivo.
    DELETE ADJACENT DUPLICATES FROM lt_carga_aux COMPARING contrato aditivo.

    IF lt_carga_aux[] IS NOT INITIAL.
      SELECT doc_uuid_h, contrato, aditivo
        FROM ztfi_contrato
        INTO TABLE @DATA(lt_contrato)
        FOR ALL ENTRIES IN @lt_carga_aux
        WHERE contrato = @lt_carga_aux-contrato
           AND aditivo = @lt_carga_aux-aditivo.
      IF sy-subrc IS INITIAL.
        SORT lt_contrato BY contrato aditivo.
      ENDIF.
    ENDIF.

    LOOP AT lt_carga ASSIGNING FIELD-SYMBOL(<fs_carga>).

      APPEND INITIAL LINE TO et_doc ASSIGNING FIELD-SYMBOL(<fs_doc>).
      READ TABLE lt_contrato ASSIGNING FIELD-SYMBOL(<fs_contrato>) WITH KEY contrato = <fs_carga>-contrato
                                                                            aditivo = <fs_carga>-aditivo
                                                                            BINARY SEARCH.
      IF sy-subrc IS INITIAL.
        <fs_doc>-doc_uuid_h    =  <fs_contrato>-doc_uuid_h.
      ENDIF.
      <fs_doc>-doc_uuid_cond     =  me->get_next_guid( ).
      <fs_doc>-contrato          =  <fs_carga>-contrato.
      <fs_doc>-aditivo           =  <fs_carga>-aditivo.

      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
        EXPORTING
          input  = <fs_carga>-tipo_cond
        IMPORTING
          output = <fs_doc>-tipo_cond.

      <fs_doc>-percentual        =  <fs_carga>-percentual.
      <fs_doc>-montante          =  <fs_carga>-montante.
      <fs_doc>-koei1             =  <fs_carga>-koei1.
      <fs_doc>-aplicacao         =  <fs_carga>-aplicacao.
      <fs_doc>-per_vigencia      =  <fs_carga>-per_vigencia.
      <fs_doc>-recorrencia_anual =  <fs_carga>-recorrencia_anual.
      <fs_doc>-created_by        = sy-uname.
      GET TIME STAMP FIELD <fs_doc>-created_at.
      <fs_doc>-local_last_changed_at = <fs_doc>-created_at.

    ENDLOOP.

  ENDMETHOD.


  METHOD upload_save_contcond.

    IF it_doc[] IS NOT INITIAL.

      MODIFY ztfi_cont_cond FROM TABLE it_doc.

      IF sy-subrc NE 0.
        " Falha ao salvar dados de carga.
        et_return[] = VALUE #( BASE et_return ( type = gc_e id = gc_msg number = gc_num2 ) ).
        "Processo finalizado
        et_return[] = VALUE #( BASE et_return ( type = gc_s id = gc_msg number = gc_num7 ) ).
        RETURN.
      ELSE.
        "Carga realizada com sucesso
        et_return[] = VALUE #( BASE et_return ( type = gc_s id = gc_msg number = gc_num6 ) ).
        "Processo finalizado
        et_return[] = VALUE #( BASE et_return ( type = gc_s id = gc_msg number = gc_num7 ) ).
      ENDIF.
    ENDIF.


  ENDMETHOD.


  METHOD upload_fill_data_raizcnpj.

    DATA: lt_carga  TYPE zctgfi_raiz_cnpj.

    FREE et_doc.



    lt_carga[] = it_file[].
    LOOP AT lt_carga ASSIGNING FIELD-SYMBOL(<fs_carga_aux>).

      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
        EXPORTING
          input  = <fs_carga_aux>-contrato
        IMPORTING
          output = <fs_carga_aux>-contrato.

    ENDLOOP.
    DATA(lt_carga_aux) = lt_carga[].
    SORT lt_carga_aux BY contrato aditivo.
    DELETE ADJACENT DUPLICATES FROM lt_carga_aux COMPARING contrato aditivo.

    IF lt_carga_aux[] IS NOT INITIAL.
      SELECT doc_uuid_h, contrato, aditivo
        FROM ztfi_contrato
        INTO TABLE @DATA(lt_contrato)
        FOR ALL ENTRIES IN @lt_carga_aux
        WHERE contrato = @lt_carga_aux-contrato
          AND aditivo = @lt_carga_aux-aditivo.
      IF sy-subrc IS INITIAL.
        SORT lt_contrato BY contrato aditivo.

        SELECT doc_uuid_h , cnpj_raiz
          FROM ztfi_raiz_cnpj
          INTO TABLE @DATA(lt_raiz)
          FOR ALL ENTRIES IN @lt_contrato
              WHERE doc_uuid_h = @lt_contrato-doc_uuid_h.
        IF sy-subrc = 0.
          SORT: lt_raiz BY doc_uuid_h cnpj_raiz.
        ENDIF.

      ENDIF.
    ENDIF.

    LOOP AT lt_carga ASSIGNING FIELD-SYMBOL(<fs_carga>).

      APPEND INITIAL LINE TO et_doc ASSIGNING FIELD-SYMBOL(<fs_doc>).
      READ TABLE lt_contrato ASSIGNING FIELD-SYMBOL(<fs_contrato>) WITH KEY contrato = <fs_carga>-contrato
                                                                            aditivo = <fs_carga>-aditivo
                                                                            BINARY SEARCH.
      IF sy-subrc IS INITIAL.

        READ TABLE lt_raiz TRANSPORTING NO FIELDS WITH KEY doc_uuid_h = <fs_contrato>-doc_uuid_h
                                                           cnpj_raiz = <fs_carga>-cnpj_raiz
                                                           BINARY SEARCH.
        IF sy-subrc = 0.

          APPEND INITIAL LINE TO et_return ASSIGNING FIELD-SYMBOL(<fs_erro>).
          <fs_erro>-id = gc_msg.
          <fs_erro>-type = gc_e.
          <fs_erro>-number = 008.
          <fs_erro>-message_v1 = <fs_carga>-contrato.
          <fs_erro>-message_v2 = <fs_carga>-aditivo.
          <fs_erro>-message_v3 = <fs_carga>-cnpj_raiz.
          CONTINUE.
        ENDIF.


        <fs_doc>-doc_uuid_h      =   <fs_contrato>-doc_uuid_h.
      ENDIF.
      <fs_doc>-doc_uuid_raiz     =  me->get_next_guid( ).
      <fs_doc>-contrato          =  <fs_carga>-contrato.
      <fs_doc>-aditivo           =  <fs_carga>-aditivo.
      <fs_doc>-cnpj_raiz         =  <fs_carga>-cnpj_raiz.
      <fs_doc>-razao_soci        =  <fs_carga>-razao_soci.
      <fs_doc>-nome_fanta        =  <fs_carga>-nome_fanta.
      <fs_doc>-created_by        = sy-uname.
      GET TIME STAMP FIELD <fs_doc>-created_at.
      <fs_doc>-local_last_changed_at = <fs_doc>-created_at.

    ENDLOOP.

  ENDMETHOD.


  METHOD upload_raizcnpj.

    DATA: lt_file TYPE zctgfi_raiz_cnpj.
    DATA: lt_doc  TYPE TABLE OF ztfi_raiz_cnpj.
    DATA: lv_mimetype TYPE w3conttype.
*    DATA  lv_filetype  TYPE ze_carga_contratos.
    DATA  lv_filetype  TYPE c LENGTH 60.


    CONSTANTS lc_raiz_cnpj(60)     TYPE c VALUE '2 - CNPJ Principal dos Contratos / ZTFI_RAIZ_CNPJ'.

    lv_filetype = lc_raiz_cnpj.

* ---------------------------------------------------------------------------
* Valida tipo de arquivo
* ---------------------------------------------------------------------------
    CALL FUNCTION 'SDOK_MIMETYPE_GET'
      EXPORTING
        extension = gc_xlsx
      IMPORTING
        mimetype  = lv_mimetype.

    IF is_media-mime_type NE lv_mimetype.
      " Formato de arquivo não suportado. Realizar nova carga com formato "xlsx".
      et_return[] = VALUE #( BASE et_return ( type = gc_e id = gc_msg number = gc_num1 ) ).
    ENDIF.

    CHECK NOT line_exists( et_return[ type = gc_e ] ).

* ---------------------------------------------------------------------------
* Converte arquivo excel para tabela
* ---------------------------------------------------------------------------
    DATA(lo_excel) = NEW zclca_excel( iv_filename = iv_filename
                                      iv_file     = is_media-value ).

    lo_excel->get_sheet( IMPORTING et_return = DATA(lt_return)
                         CHANGING  ct_table  = lt_file[] ).

    et_return[] = VALUE #( BASE et_return FOR ls_return IN lt_return ( ls_return ) ).

    CHECK NOT line_exists( et_return[ type = gc_e ] ).

* ---------------------------------------------------------------------------
* Preenche tabelas interna
* ---------------------------------------------------------------------------
    me->upload_fill_data_raizcnpj( EXPORTING
                            it_file     = lt_file[]
                          IMPORTING
                            et_doc      = lt_doc[]
                            et_return   = lt_return[] ).

    et_return[] = VALUE #( BASE et_return FOR ls_return IN lt_return ( ls_return ) ).
    CHECK NOT line_exists( et_return[ type = gc_e ] ).

* ---------------------------------------------------------------------------
* Salva registros
* ---------------------------------------------------------------------------
    me->upload_save_raizcnpj(
            EXPORTING
            it_doc = lt_doc[]
            IMPORTING
            et_return = lt_return[] ).

    APPEND LINES OF lt_return TO et_return.
    CLEAR: lt_return.

* ---------------------------------------------------------------------------
* Salva registros no Header
* ---------------------------------------------------------------------------
    me->upload_header( EXPORTING
                   iv_filetype   = lv_filetype
          IMPORTING
                   et_return     = lt_return ).

    APPEND LINES OF lt_return TO et_return.
    CLEAR: lt_return.

  ENDMETHOD.


  METHOD upload_save_raizcnpj.

    IF it_doc[] IS NOT INITIAL.

      MODIFY ztfi_raiz_cnpj FROM TABLE it_doc.

      IF sy-subrc NE 0.
        " Falha ao salvar dados de carga.
        et_return[] = VALUE #( BASE et_return ( type = gc_e id = gc_msg number = gc_num2 ) ).
        RETURN.
      ELSE.
        "Carga realizada com sucesso
        et_return[] = VALUE #( BASE et_return ( type = gc_s id = gc_msg number = gc_num6 ) ).
        "Processo finalizado
        et_return[] = VALUE #( BASE et_return ( type = gc_s id = gc_msg number = gc_num7 ) ).

      ENDIF.
    ENDIF.

  ENDMETHOD.


  METHOD upload_contcont.

    DATA: lt_file TYPE zctgfi_contcont.
    DATA: lt_doc  TYPE TABLE OF ztfi_cont_cont.
    DATA: lv_mimetype TYPE w3conttype.
*    DATA  lv_filetype  TYPE ze_carga_contratos.
    DATA  lv_filetype  TYPE c LENGTH 60.

    CONSTANTS lc_cont_cont(46)     TYPE c VALUE '13 - Contratos Contabilizados / ZTFI_CONT_CONT'.

    lv_filetype = lc_cont_cont.

* ---------------------------------------------------------------------------
* Valida tipo de arquivo
* ---------------------------------------------------------------------------
    CALL FUNCTION 'SDOK_MIMETYPE_GET'
      EXPORTING
        extension = gc_xlsx
      IMPORTING
        mimetype  = lv_mimetype.

    IF is_media-mime_type NE lv_mimetype.
      " Formato de arquivo não suportado. Realizar nova carga com formato "xlsx".
      et_return[] = VALUE #( BASE et_return ( type = gc_e id = gc_msg number = gc_num1 ) ).
    ENDIF.

    CHECK NOT line_exists( et_return[ type = gc_e ] ).

* ---------------------------------------------------------------------------
* Converte arquivo excel para tabela
* ---------------------------------------------------------------------------
    DATA(lo_excel) = NEW zclca_excel( iv_filename = iv_filename
                                      iv_file     = is_media-value ).

    lo_excel->get_sheet( IMPORTING et_return = DATA(lt_return)
                         CHANGING  ct_table  = lt_file[] ).

    et_return[] = VALUE #( BASE et_return FOR ls_return IN lt_return ( ls_return ) ).

    CHECK NOT line_exists( et_return[ type = gc_e ] ).

* ---------------------------------------------------------------------------
* Preenche tabelas interna
* ---------------------------------------------------------------------------
    me->upload_fill_data_contcont( EXPORTING
                            it_file     = lt_file[]
                          IMPORTING
                            et_doc      = lt_doc[]
                            et_return   = lt_return[] ).

    et_return[] = VALUE #( BASE et_return FOR ls_return IN lt_return ( ls_return ) ).
    CHECK NOT line_exists( et_return[ type = gc_e ] ).

* ---------------------------------------------------------------------------
* Salva registros
* ---------------------------------------------------------------------------
    me->upload_save_contcont(
            EXPORTING
            it_doc = lt_doc[]
            IMPORTING
            et_return = lt_return[] ).

    APPEND LINES OF lt_return TO et_return.
    CLEAR: lt_return.
* ---------------------------------------------------------------------------
* Salva registros no Header
* ---------------------------------------------------------------------------
    me->upload_header( EXPORTING
                   iv_filetype   = lv_filetype
          IMPORTING
                   et_return     = lt_return ).

    APPEND LINES OF lt_return TO et_return.
    CLEAR: lt_return.

  ENDMETHOD.


  METHOD upload_fill_data_contcont.

    DATA: lt_carga  TYPE zctgfi_contcont.

    FREE et_doc.

    lt_carga[] = it_file[].

    LOOP AT lt_carga ASSIGNING FIELD-SYMBOL(<fs_carga>).

      APPEND INITIAL LINE TO et_doc ASSIGNING FIELD-SYMBOL(<fs_doc>).


      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
        EXPORTING
          input  = <fs_carga>-contrato
        IMPORTING
          output = <fs_doc>-contrato.

      <fs_doc>-doc_cont_id       =  me->get_next_guid( ).
      <fs_doc>-aditivo           =  <fs_carga>-aditivo.
      <fs_doc>-bukrs             =  <fs_carga>-bukrs.
      <fs_doc>-kunnr             =  <fs_carga>-kunnr.

      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
        EXPORTING
          input  = <fs_carga>-belnr
        IMPORTING
          output = <fs_doc>-belnr.

      <fs_doc>-gjahr             =  <fs_carga>-gjahr.
      <fs_doc>-numero_item       =  <fs_carga>-numero_item.
      <fs_doc>-budat             =  <fs_carga>-budat.
      <fs_doc>-wrbtr             =  <fs_carga>-wrbtr.
      <fs_doc>-waers             =  <fs_carga>-waers.
      <fs_doc>-bzirk             =  <fs_carga>-bzirk.

      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
        EXPORTING
          input  = <fs_carga>-canal
        IMPORTING
          output = <fs_doc>-canal.

      <fs_doc>-setor             =  <fs_carga>-setor.
      <fs_doc>-vkorg             =  <fs_carga>-vkorg.
      <fs_doc>-tipo_desc         =  <fs_carga>-tipo_desc.
      <fs_doc>-doc_provisao      =  <fs_carga>-doc_provisao.
      <fs_doc>-exerc_provisao    =  <fs_carga>-exerc_provisao.
      <fs_doc>-mont_provisao     =  <fs_carga>-mont_provisao.
      <fs_doc>-doc_liquidacao    =  <fs_carga>-doc_liquidacao.
      <fs_doc>-exerc_liquidacao  =  <fs_carga>-exerc_liquidacao.
      <fs_doc>-mont_liquidacao   =  <fs_carga>-mont_liquidacao.
      <fs_doc>-doc_estorno       =  <fs_carga>-doc_estorno.
      <fs_doc>-exerc_estorno     =  <fs_carga>-exerc_estorno.
      <fs_doc>-mont_estorno      =  <fs_carga>-mont_estorno.
      <fs_doc>-status_provisao   =  <fs_carga>-status_provisao.
      <fs_doc>-tipo_dado         =  <fs_carga>-tipo_dado.
      <fs_doc>-created_by        = sy-uname.
      GET TIME STAMP FIELD <fs_doc>-created_at.
      <fs_doc>-local_last_changed_at = <fs_doc>-created_at.

    ENDLOOP.

  ENDMETHOD.


  METHOD upload_save_contcont.

    IF it_doc[] IS NOT INITIAL.

      MODIFY ztfi_cont_cont FROM TABLE it_doc.

      IF sy-subrc NE 0.
        " Falha ao salvar dados de carga.
        et_return[] = VALUE #( BASE et_return ( type = gc_e id = gc_msg number = gc_num2 ) ).
        RETURN.
      ELSE.
        "Carga realizada com sucesso
        et_return[] = VALUE #( BASE et_return ( type = gc_s id = gc_msg number = gc_num6 ) ).
        "Processo finalizado
        et_return[] = VALUE #( BASE et_return ( type = gc_s id = gc_msg number = gc_num7 ) ).
      ENDIF.
    ENDIF.

  ENDMETHOD.


  METHOD upload_cadprovi.

    DATA: lt_file TYPE zctgfi_cad_provi.
    DATA: lt_doc  TYPE TABLE OF ztfi_cad_provi.
    DATA: lv_mimetype TYPE w3conttype.
*    DATA  lv_filetype  TYPE ze_carga_contratos.
    DATA  lv_filetype  TYPE c LENGTH 60.

    CONSTANTS lc_cad_prov(43)      TYPE c VALUE '6 - Cadastro de provisões / ZTFI_CAD_PROVI'.

    lv_filetype = lc_cad_prov.

* ---------------------------------------------------------------------------
* Valida tipo de arquivo
* ---------------------------------------------------------------------------
    CALL FUNCTION 'SDOK_MIMETYPE_GET'
      EXPORTING
        extension = gc_xlsx
      IMPORTING
        mimetype  = lv_mimetype.

    IF is_media-mime_type NE lv_mimetype.
      " Formato de arquivo não suportado. Realizar nova carga com formato "xlsx".
      et_return[] = VALUE #( BASE et_return ( type = gc_e id = gc_msg number = gc_num1 ) ).
    ENDIF.

    CHECK NOT line_exists( et_return[ type = gc_e ] ).

* ---------------------------------------------------------------------------
* Converte arquivo excel para tabela
* ---------------------------------------------------------------------------
    DATA(lo_excel) = NEW zclca_excel( iv_filename = iv_filename
                                      iv_file     = is_media-value ).

    lo_excel->get_sheet( IMPORTING et_return = DATA(lt_return)
                         CHANGING  ct_table  = lt_file[] ).

    et_return[] = VALUE #( BASE et_return FOR ls_return IN lt_return ( ls_return ) ).

    CHECK NOT line_exists( et_return[ type = gc_e ] ).

* ---------------------------------------------------------------------------
* Preenche tabelas interna
* ---------------------------------------------------------------------------
    me->upload_fill_data_cadprovi( EXPORTING
                            it_file     = lt_file[]
                          IMPORTING
                            et_doc      = lt_doc[]
                            et_return   = lt_return[] ).

    et_return[] = VALUE #( BASE et_return FOR ls_return IN lt_return ( ls_return ) ).
    CHECK NOT line_exists( et_return[ type = gc_e ] ).

* ---------------------------------------------------------------------------
* Salva registros
* ---------------------------------------------------------------------------
    me->upload_save_cadprovi(
            EXPORTING
            it_doc = lt_doc[]
            IMPORTING
            et_return = lt_return[] ).

    APPEND LINES OF lt_return TO et_return.
    CLEAR: lt_return.
* ---------------------------------------------------------------------------
* Salva registros no Header
* ---------------------------------------------------------------------------
    me->upload_header( EXPORTING
                   iv_filetype   = lv_filetype
          IMPORTING
                   et_return     = lt_return ).

    APPEND LINES OF lt_return TO et_return.
    CLEAR: lt_return.

  ENDMETHOD.


  METHOD upload_fill_data_cadprovi.

    DATA: lt_carga  TYPE zctgfi_cad_provi.

    FREE et_doc.

    lt_carga[] = it_file[].
    LOOP AT lt_carga ASSIGNING FIELD-SYMBOL(<fs_carga_aux>).

      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
        EXPORTING
          input  = <fs_carga_aux>-contrato
        IMPORTING
          output = <fs_carga_aux>-contrato.

    ENDLOOP.
    DATA(lt_carga_aux) = lt_carga[].
    SORT lt_carga_aux BY contrato aditivo.
    DELETE ADJACENT DUPLICATES FROM lt_carga_aux COMPARING contrato aditivo.

    IF lt_carga_aux[] IS NOT INITIAL.
      SELECT doc_uuid_h, contrato, aditivo
        FROM ztfi_contrato
        INTO TABLE @DATA(lt_contrato)
        FOR ALL ENTRIES IN @lt_carga_aux
        WHERE contrato = @lt_carga_aux-contrato
          AND aditivo = @lt_carga_aux-aditivo.
      IF sy-subrc IS INITIAL.
        SORT lt_contrato BY contrato aditivo.
      ENDIF.
    ENDIF.
    LOOP AT lt_carga ASSIGNING FIELD-SYMBOL(<fs_carga>).

      APPEND INITIAL LINE TO et_doc ASSIGNING FIELD-SYMBOL(<fs_doc>).

      READ TABLE lt_contrato ASSIGNING FIELD-SYMBOL(<fs_contrato>) WITH KEY contrato = <fs_carga>-contrato
                                                                            aditivo = <fs_carga>-aditivo
                                                                            BINARY SEARCH.
      IF sy-subrc IS INITIAL.
        <fs_doc>-doc_uuid_h    =  <fs_contrato>-doc_uuid_h.
      ENDIF.
      <fs_doc>-doc_uuid_prov   =  me->get_next_guid( ).
      <fs_doc>-contrato        =  <fs_carga>-contrato.
      <fs_doc>-aditivo         =  <fs_carga>-aditivo.
      <fs_doc>-empresa         =  <fs_carga>-empresa.
      <fs_doc>-grup_contrato   =  <fs_carga>-grup_contrato.
      <fs_doc>-tipo_desconto   =  <fs_carga>-tipo_desconto.
      <fs_doc>-aplica_desconto =  <fs_carga>-aplica_desconto.

      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
        EXPORTING
          input  = <fs_carga>-cond_desconto
        IMPORTING
          output = <fs_doc>-cond_desconto.

      <fs_doc>-classific_cnpj  =  <fs_carga>-classific_cnpj.
      <fs_doc>-familia_cl      =  <fs_carga>-familia_cl.
      <fs_doc>-tipo_ap_imposto =  <fs_carga>-tipo_ap_imposto.
      <fs_doc>-tipo_imposto    =  <fs_carga>-tipo_imposto.
      <fs_doc>-perc_cond_desc  =  <fs_carga>-perc_cond_desc.
      <fs_doc>-mes_vigencia    =  <fs_carga>-mes_vigencia.
      <fs_doc>-reco_anual_desc =  <fs_carga>-reco_anual_desc.
      <fs_doc>-tipo_apuracao   =  <fs_carga>-tipo_apuracao.
      <fs_doc>-created_by      = sy-uname.
      GET TIME STAMP FIELD <fs_doc>-created_at.
      <fs_doc>-local_last_changed_at = <fs_doc>-created_at.

    ENDLOOP.

  ENDMETHOD.


  METHOD upload_save_cadprovi.

    IF it_doc[] IS NOT INITIAL.

      MODIFY ztfi_cad_provi FROM TABLE it_doc.

      IF sy-subrc NE 0.
        " Falha ao salvar dados de carga.
        et_return[] = VALUE #( BASE et_return ( type = gc_e id = gc_msg number = gc_num2 ) ).
        RETURN.
      ELSE.
        "Carga realizada com sucesso
        et_return[] = VALUE #( BASE et_return ( type = gc_s id = gc_msg number = gc_num6 ) ).
        "Processo finalizado
        et_return[] = VALUE #( BASE et_return ( type = gc_s id = gc_msg number = gc_num7 ) ).

      ENDIF.
    ENDIF.

  ENDMETHOD.


  METHOD upload_contjanela.

    DATA: lt_file TYPE zctgfi_cont_janel.
    DATA: lt_doc  TYPE TABLE OF ztfi_cont_janela.
    DATA: lv_mimetype TYPE w3conttype.
*    DATA  lv_filetype  TYPE ze_carga_contratos.
    DATA  lv_filetype  TYPE c LENGTH 60.

    CONSTANTS lc_par_venc(48)      TYPE c VALUE '8 - Cadastro Janela Contratos / ZTFI_CONT_JANELA'.

    lv_filetype = lc_par_venc.

* ---------------------------------------------------------------------------
* Valida tipo de arquivo
* ---------------------------------------------------------------------------
    CALL FUNCTION 'SDOK_MIMETYPE_GET'
      EXPORTING
        extension = gc_xlsx
      IMPORTING
        mimetype  = lv_mimetype.

    IF is_media-mime_type NE lv_mimetype.
      " Formato de arquivo não suportado. Realizar nova carga com formato "xlsx".
      et_return[] = VALUE #( BASE et_return ( type = gc_e id = gc_msg number = gc_num1 ) ).
    ENDIF.

    CHECK NOT line_exists( et_return[ type = gc_e ] ).

* ---------------------------------------------------------------------------
* Converte arquivo excel para tabela
* ---------------------------------------------------------------------------
    DATA(lo_excel) = NEW zclca_excel( iv_filename = iv_filename
                                      iv_file     = is_media-value ).

    lo_excel->get_sheet( IMPORTING et_return = DATA(lt_return)
                         CHANGING  ct_table  = lt_file[] ).

    et_return[] = VALUE #( BASE et_return FOR ls_return IN lt_return ( ls_return ) ).

    CHECK NOT line_exists( et_return[ type = gc_e ] ).

* ---------------------------------------------------------------------------
* Preenche tabelas interna
* ---------------------------------------------------------------------------
    me->upload_fill_data_contjanela( EXPORTING
                            it_file     = lt_file[]
                          IMPORTING
                            et_doc      = lt_doc[]
                            et_return   = lt_return[] ).

    et_return[] = VALUE #( BASE et_return FOR ls_return IN lt_return ( ls_return ) ).
    CHECK NOT line_exists( et_return[ type = gc_e ] ).

* ---------------------------------------------------------------------------
* Salva registros
* ---------------------------------------------------------------------------
    me->upload_save_contjanela(
            EXPORTING
            it_doc = lt_doc[]
            IMPORTING
            et_return = lt_return[] ).

    APPEND LINES OF lt_return TO et_return.
    CLEAR: lt_return.

* ---------------------------------------------------------------------------
* Salva registros no Header
* ---------------------------------------------------------------------------
    me->upload_header( EXPORTING
                   iv_filetype   = lv_filetype
          IMPORTING
                   et_return     = lt_return ).

    APPEND LINES OF lt_return TO et_return.
    CLEAR: lt_return.

  ENDMETHOD.


  METHOD upload_fill_data_contjanela.

    DATA: lt_carga  TYPE zctgfi_cont_janel.

    FREE et_doc.

    lt_carga[] = it_file[].
    LOOP AT lt_carga ASSIGNING FIELD-SYMBOL(<fs_carga_aux>).

      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
        EXPORTING
          input  = <fs_carga_aux>-contrato
        IMPORTING
          output = <fs_carga_aux>-contrato.

    ENDLOOP.
    DATA(lt_carga_aux) = lt_carga[].
    SORT lt_carga_aux BY contrato aditivo.
    DELETE ADJACENT DUPLICATES FROM lt_carga_aux COMPARING contrato aditivo.

    IF lt_carga_aux[] IS NOT INITIAL.
      SELECT doc_uuid_h, contrato, aditivo
        FROM ztfi_contrato
        INTO TABLE @DATA(lt_contrato)
        FOR ALL ENTRIES IN @lt_carga_aux
        WHERE contrato = @lt_carga_aux-contrato
         AND aditivo = @lt_carga_aux-aditivo.
      IF sy-subrc IS INITIAL.
        SORT lt_contrato BY contrato aditivo.
      ENDIF.
    ENDIF.

    LOOP AT lt_carga ASSIGNING FIELD-SYMBOL(<fs_carga>).

      IF <fs_carga>-prazo CO '0123456789'.
      ELSE.
        et_return[] = VALUE #( BASE et_return ( type = gc_e id = gc_msg number = 005 message_v1 = 'Campo prazo não é numérico' message_v2 = <fs_carga>-prazo ) ).
        CONTINUE.
      ENDIF.

      IF <fs_carga>-dia_mes_fixo IS NOT INITIAL AND
         <fs_carga>-dia_semana IS NOT INITIAL.
        et_return[] = VALUE #( BASE et_return ( type = gc_e id = gc_msg number = 005 message_v1 = 'Somente é possivel grava dia da Semana ou Mês fixo' ) ).
        CONTINUE.
      ENDIF.

      APPEND INITIAL LINE TO et_doc ASSIGNING FIELD-SYMBOL(<fs_doc>).
      READ TABLE lt_contrato ASSIGNING FIELD-SYMBOL(<fs_contrato>) WITH KEY contrato = <fs_carga>-contrato
                                                                            aditivo = <fs_carga>-aditivo
                                                                            BINARY SEARCH.
      IF sy-subrc IS INITIAL.
        <fs_doc>-doc_uuid_h    =  <fs_contrato>-doc_uuid_h.
      ENDIF.
      <fs_doc>-doc_uuid_janela =  me->get_next_guid( ).
      <fs_doc>-contrato        =  <fs_carga>-contrato.
      <fs_doc>-aditivo         =  <fs_carga>-aditivo.


      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
        EXPORTING
          input  = <fs_carga>-grp_cond
        IMPORTING
          output = <fs_doc>-grp_cond.


      <fs_doc>-atributo_2      =  <fs_carga>-atributo_2.
      <fs_doc>-familia_cl      =  <fs_carga>-familia_cl.
      <fs_doc>-prazo           =  <fs_carga>-prazo.
      <fs_doc>-percentual      =  <fs_carga>-percentual.
      <fs_doc>-dia_mes_fixo    =  <fs_carga>-dia_mes_fixo.
      <fs_doc>-dia_semana      =  <fs_carga>-dia_semana.
      <fs_doc>-created_by      = sy-uname.
      GET TIME STAMP FIELD <fs_doc>-created_at.
      <fs_doc>-local_last_changed_at = <fs_doc>-created_at.

    ENDLOOP.

  ENDMETHOD.


  METHOD upload_save_contjanela.

    IF it_doc[] IS NOT INITIAL.

      MODIFY ztfi_cont_janela FROM TABLE it_doc.

      IF sy-subrc NE 0.
        " Falha ao salvar dados de carga.
        et_return[] = VALUE #( BASE et_return ( type = gc_e id = gc_msg number = gc_num2 ) ).
        RETURN.
      ELSE.
        "Carga realizada com sucesso
        et_return[] = VALUE #( BASE et_return ( type = gc_s id = gc_msg number = gc_num6 ) ).
        "Processo finalizado
        et_return[] = VALUE #( BASE et_return ( type = gc_s id = gc_msg number = gc_num7 ) ).

      ENDIF.
    ENDIF.


  ENDMETHOD.


  METHOD upload_cadcresci.

    DATA: lt_file TYPE zctgfi_cad_cresci.
    DATA: lt_doc  TYPE TABLE OF ztfi_cad_cresci.
    DATA: lv_mimetype TYPE w3conttype.
*    DATA  lv_filetype  TYPE ze_carga_contratos.
    DATA  lv_filetype  TYPE c LENGTH 60.

    CONSTANTS lc_crescimento(60)   TYPE c VALUE '14 - Cadastro Crescimento / ZTFI_CAD_CRESCI'.

    lv_filetype = lc_crescimento.

* ---------------------------------------------------------------------------
* Valida tipo de arquivo
* ---------------------------------------------------------------------------
    CALL FUNCTION 'SDOK_MIMETYPE_GET'
      EXPORTING
        extension = gc_xlsx
      IMPORTING
        mimetype  = lv_mimetype.

    IF is_media-mime_type NE lv_mimetype.
      " Formato de arquivo não suportado. Realizar nova carga com formato "xlsx".
      et_return[] = VALUE #( BASE et_return ( type = gc_e id = gc_msg number = gc_num1 ) ).
    ENDIF.

    CHECK NOT line_exists( et_return[ type = gc_e ] ).

* ---------------------------------------------------------------------------
* Converte arquivo excel para tabela
* ---------------------------------------------------------------------------
    DATA(lo_excel) = NEW zclca_excel( iv_filename = iv_filename
                                      iv_file     = is_media-value ).

    lo_excel->get_sheet( IMPORTING et_return = DATA(lt_return)
                         CHANGING  ct_table  = lt_file[] ).

    et_return[] = VALUE #( BASE et_return FOR ls_return IN lt_return ( ls_return ) ).

    CHECK NOT line_exists( et_return[ type = gc_e ] ).

* ---------------------------------------------------------------------------
* Preenche tabelas interna
* ---------------------------------------------------------------------------
    me->upload_fill_data_cadcresci( EXPORTING
                            it_file     = lt_file[]
                          IMPORTING
                            et_doc      = lt_doc[]
                            et_return   = lt_return[] ).

    et_return[] = VALUE #( BASE et_return FOR ls_return IN lt_return ( ls_return ) ).
    CHECK NOT line_exists( et_return[ type = gc_e ] ).

* ---------------------------------------------------------------------------
* Salva registros
* ---------------------------------------------------------------------------
    me->upload_save_cadcresci(
            EXPORTING
            it_doc = lt_doc[]
            IMPORTING
            et_return = lt_return[] ).

    APPEND LINES OF lt_return TO et_return.
    CLEAR: lt_return.

* ---------------------------------------------------------------------------
* Salva registros no Header
* ---------------------------------------------------------------------------
    me->upload_header( EXPORTING
                   iv_filetype   = lv_filetype
          IMPORTING
                   et_return     = lt_return ).

    APPEND LINES OF lt_return TO et_return.
    CLEAR: lt_return.


  ENDMETHOD.


  METHOD upload_fill_data_cadcresci.

    DATA: lt_carga  TYPE zctgfi_cad_cresci.

    FREE et_doc.

    lt_carga[] = it_file[].
    LOOP AT lt_carga ASSIGNING FIELD-SYMBOL(<fs_carga_aux>).

      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
        EXPORTING
          input  = <fs_carga_aux>-contrato
        IMPORTING
          output = <fs_carga_aux>-contrato.

    ENDLOOP.
    DATA(lt_carga_aux) = lt_carga[].
    SORT lt_carga_aux BY contrato aditivo .
    DELETE ADJACENT DUPLICATES FROM lt_carga_aux COMPARING contrato aditivo.

    IF lt_carga_aux[] IS NOT INITIAL.
      SELECT doc_uuid_h, contrato, aditivo
        FROM ztfi_contrato
        INTO TABLE @DATA(lt_contrato)
        FOR ALL ENTRIES IN @lt_carga_aux
        WHERE contrato = @lt_carga_aux-contrato
          AND aditivo = @lt_carga_aux-aditivo.
      IF sy-subrc IS INITIAL.
        SORT lt_contrato BY contrato aditivo.
      ENDIF.
    ENDIF.

    LOOP AT lt_carga ASSIGNING FIELD-SYMBOL(<fs_carga>).

      APPEND INITIAL LINE TO et_doc ASSIGNING FIELD-SYMBOL(<fs_doc>).
      READ TABLE lt_contrato ASSIGNING FIELD-SYMBOL(<fs_contrato>) WITH KEY contrato = <fs_carga>-contrato
                                                                            aditivo = <fs_carga>-aditivo
                                                                   BINARY SEARCH.
      IF sy-subrc IS INITIAL.
        <fs_doc>-doc_uuid_h      =   <fs_contrato>-doc_uuid_h.
      ENDIF.
      <fs_doc>-doc_uuid_cresc   = me->get_next_guid( ).
      <fs_doc>-contrato         = <fs_carga>-contrato.
      <fs_doc>-aditivo          = <fs_carga>-aditivo.
      <fs_doc>-familia_cl       = <fs_carga>-familia_cl .
*      <fs_doc>-flag_td_famili   = <fs_carga>-flag_td_famili.
      <fs_doc>-tipo_ap_devoluc  = <fs_carga>-tipo_ap_devoluc.
      <fs_doc>-tipo_ap_imposto  = <fs_carga>-tipo_ap_imposto.
      <fs_doc>-tipo_imposto     = <fs_carga>-tipo_imposto.
      <fs_doc>-forma_descont    = <fs_carga>-forma_descont.
      <fs_doc>-ajuste_anual     = <fs_carga>-ajuste_anual.
      <fs_doc>-periodicidade    = <fs_carga>-periodicidade.
      <fs_doc>-inicio_periodic  = <fs_carga>-inicio_periodic.
      <fs_doc>-classific_cnpj   = <fs_carga>-classific_cnpj.
      <fs_doc>-flag_td_atribut  = <fs_carga>-flag_td_atribut.
      <fs_doc>-tipo_comparacao  = <fs_carga>-tipo_comparacao.
      <fs_doc>-created_by       = sy-uname.
      GET TIME STAMP FIELD <fs_doc>-created_at.
      <fs_doc>-local_last_changed_at = <fs_doc>-created_at.

    ENDLOOP.

  ENDMETHOD.


  METHOD upload_save_cadcresci.

    IF it_doc[] IS NOT INITIAL.

      MODIFY ztfi_cad_cresci FROM TABLE it_doc.

      IF sy-subrc NE 0.
        " Falha ao salvar dados de carga.
        et_return[] = VALUE #( BASE et_return ( type = gc_e id = gc_msg number = gc_num2 ) ).
        RETURN.

      ELSE.
        "Carga realizada com sucesso
        et_return[] = VALUE #( BASE et_return ( type = gc_s id = gc_msg number = gc_num6 ) ).
        "Processo finalizado
        et_return[] = VALUE #( BASE et_return ( type = gc_s id = gc_msg number = gc_num7 ) ).

      ENDIF.
    ENDIF.

  ENDMETHOD.


  METHOD get_next_documentno.

    DATA: ls_return TYPE bapiret2,
          lv_object TYPE nrobj VALUE 'ZFICARGATA',
          lv_range  TYPE nrnr  VALUE '01'.

    FREE: et_return, rv_docnumber.

* ---------------------------------------------------------------------------
* Travar objeto de numeração
* ---------------------------------------------------------------------------
    CALL FUNCTION 'NUMBER_RANGE_ENQUEUE'
      EXPORTING
        object           = lv_object
      EXCEPTIONS
        foreign_lock     = 1
        object_not_found = 2
        system_failure   = 3
        OTHERS           = 4.

    IF sy-subrc NE 0.
      et_return[] =  VALUE #( BASE et_return ( type = sy-msgty id = sy-msgid number = sy-msgno
                                               message_v1 = sy-msgv1
                                               message_v2 = sy-msgv2
                                               message_v3 = sy-msgv3
                                               message_v4 = sy-msgv4 ) ).
      RETURN.
    ENDIF.

* ---------------------------------------------------------------------------
* Recuperar novo número da requisição
* ---------------------------------------------------------------------------
    CALL FUNCTION 'NUMBER_GET_NEXT'
      EXPORTING
        nr_range_nr             = lv_range
        object                  = lv_object
      IMPORTING
        number                  = rv_docnumber
      EXCEPTIONS
        interval_not_found      = 1
        number_range_not_intern = 2
        object_not_found        = 3
        quantity_is_0           = 4
        quantity_is_not_1       = 5
        interval_overflow       = 6
        buffer_overflow         = 7
        OTHERS                  = 8.

    IF sy-subrc NE 0.
      et_return[] =  VALUE #( BASE et_return ( type = sy-msgty id = sy-msgid number = sy-msgno
                                               message_v1 = sy-msgv1
                                               message_v2 = sy-msgv2
                                               message_v3 = sy-msgv3
                                               message_v4 = sy-msgv4 ) ).
    ENDIF.

* ---------------------------------------------------------------------------
* Destravar objeto de numeração
* ---------------------------------------------------------------------------
    CALL FUNCTION 'NUMBER_RANGE_DEQUEUE'
      EXPORTING
        object           = lv_object
      EXCEPTIONS
        object_not_found = 1
        OTHERS           = 2.

    IF sy-subrc NE 0.
      et_return[] =  VALUE #( BASE et_return ( type = sy-msgty id = sy-msgid number = sy-msgno
                                               message_v1 = sy-msgv1
                                               message_v2 = sy-msgv2
                                               message_v3 = sy-msgv3
                                               message_v4 = sy-msgv4 ) ).
    ENDIF.

  ENDMETHOD.


  METHOD get_next_guid.

    FREE: ev_guid.

    TRY.
        rv_guid = ev_guid = cl_system_uuid=>create_uuid_x16_static( ).

      CATCH cx_root INTO DATA(lo_root).
        DATA(lv_message) = CONV bapi_msg( lo_root->get_longtext( ) ).
        et_return[] = VALUE #( BASE et_return ( type = 'E' id = 'ZCA_EXCEL' number = '000'
                                                message_v1 = lv_message+0(50)
                                                message_v2 = lv_message+50(50)
                                                message_v3 = lv_message+100(50)
                                                message_v4 = lv_message+150(50) ) ).
        RETURN.
    ENDTRY.

  ENDMETHOD.


  METHOD upload_header.

    DATA: ls_header TYPE ztfi_carga_conth.


    ls_header-doc_uuid_h             = me->get_next_guid( ).
*    ls_header-documentno             = me->get_next_documentno( IMPORTING et_return = et_return ).
    ls_header-data_carga             = sy-datum.
    ls_header-tipo_carga             = iv_filetype.
    ls_header-created_by             = sy-uname.
    GET TIME STAMP FIELD ls_header-created_at.
    ls_header-local_last_changed_at  = ls_header-created_at.


    IF ls_header IS NOT INITIAL.

      MODIFY ztfi_carga_conth FROM ls_header.

      IF sy-subrc NE 0.
        " Falha ao salvar dados de carga.
        et_return[] = VALUE #( BASE et_return ( type = 'E' id = 'ZFI_CARGA_EXCEL' number = '014' ) ).
        RETURN.
      ENDIF.
    ENDIF.

  ENDMETHOD.


  METHOD upload_faixacresc.

    DATA: lt_file TYPE zctgfi_faixa_cres.
    DATA: lt_doc  TYPE TABLE OF ztfi_faixa_cresc.
    DATA: lv_mimetype TYPE w3conttype.
*    DATA  lv_filetype  TYPE ze_carga_contratos.
    DATA  lv_filetype  TYPE c LENGTH 60.

    CONSTANTS lc_crescimento(60)   TYPE c VALUE '15 - Cadastro Faixa Bônus Crescimento / ZTFI_FAIXA_CRESC'.

    lv_filetype = lc_crescimento.

* ---------------------------------------------------------------------------
* Valida tipo de arquivo
* ---------------------------------------------------------------------------
    CALL FUNCTION 'SDOK_MIMETYPE_GET'
      EXPORTING
        extension = gc_xlsx
      IMPORTING
        mimetype  = lv_mimetype.

    IF is_media-mime_type NE lv_mimetype.
      " Formato de arquivo não suportado. Realizar nova carga com formato "xlsx".
      et_return[] = VALUE #( BASE et_return ( type = gc_e id = gc_msg number = gc_num1 ) ).
    ENDIF.

    CHECK NOT line_exists( et_return[ type = gc_e ] ).

* ---------------------------------------------------------------------------
* Converte arquivo excel para tabela
* ---------------------------------------------------------------------------
    DATA(lo_excel) = NEW zclca_excel( iv_filename = iv_filename
                                      iv_file     = is_media-value ).

    lo_excel->get_sheet( IMPORTING et_return = DATA(lt_return)
                         CHANGING  ct_table  = lt_file[] ).

    et_return[] = VALUE #( BASE et_return FOR ls_return IN lt_return ( ls_return ) ).

    CHECK NOT line_exists( et_return[ type = gc_e ] ).

* ---------------------------------------------------------------------------
* Preenche tabelas interna
* ---------------------------------------------------------------------------
    me->upload_fill_data_faixacresc( EXPORTING
                            it_file     = lt_file[]
                          IMPORTING
                            et_doc      = lt_doc[]
                            et_return   = lt_return[] ).

    et_return[] = VALUE #( BASE et_return FOR ls_return IN lt_return ( ls_return ) ).
    CHECK NOT line_exists( et_return[ type = gc_e ] ).

* ---------------------------------------------------------------------------
* Salva registros
* ---------------------------------------------------------------------------
    me->upload_save_faixacresc(
            EXPORTING
            it_doc = lt_doc[]
            IMPORTING
            et_return = lt_return[] ).

    APPEND LINES OF lt_return TO et_return.
    CLEAR: lt_return.

* ---------------------------------------------------------------------------
* Salva registros no Header
* ---------------------------------------------------------------------------
    me->upload_header( EXPORTING
                   iv_filetype   = lv_filetype
          IMPORTING
                   et_return     = lt_return ).

    APPEND LINES OF lt_return TO et_return.
    CLEAR: lt_return.


  ENDMETHOD.


  METHOD upload_fill_data_faixacresc.

    DATA: lt_carga  TYPE zctgfi_faixa_cres.
    DATA: lv_contrato TYPE char25.

    FREE et_doc.

    lt_carga[] = it_file[].
    LOOP AT lt_carga ASSIGNING FIELD-SYMBOL(<fs_carga_aux>).

      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
        EXPORTING
          input  = <fs_carga_aux>-contrato
        IMPORTING
          output = <fs_carga_aux>-contrato.

    ENDLOOP.
    DATA(lt_carga_aux) = lt_carga[].
    SORT lt_carga_aux BY contrato aditivo.
    DELETE ADJACENT DUPLICATES FROM lt_carga_aux COMPARING contrato aditivo.


    IF lt_carga_aux[] IS NOT INITIAL.
      SELECT doc_uuid_h, contrato, aditivo
        FROM ztfi_contrato
        INTO TABLE @DATA(lt_contrato)
        FOR ALL ENTRIES IN @lt_carga_aux
        WHERE contrato = @lt_carga_aux-contrato
          AND aditivo = @lt_carga_aux-aditivo.
      IF sy-subrc IS INITIAL.
        SORT lt_contrato BY contrato aditivo.
      ENDIF.
    ENDIF.

    LOOP AT lt_carga ASSIGNING FIELD-SYMBOL(<fs_carga>).

      IF <fs_carga>-aditivo IS NOT INITIAL.
        CONCATENATE <fs_carga>-contrato '/' <fs_carga>-aditivo INTO lv_contrato.
      ELSE.
        lv_contrato = <fs_carga>-contrato.
      ENDIF.

      IF <fs_carga>-cod_faixa IS NOT INITIAL AND
         <fs_carga>-cod_montante IS NOT INITIAL.
        "Informar % ou Valor de faixa
        APPEND INITIAL LINE TO et_return ASSIGNING FIELD-SYMBOL(<fs_erro1>).
        <fs_erro1>-id = gc_msg.
        <fs_erro1>-type = gc_e.
        <fs_erro1>-number = '010'.
        <fs_erro1>-message_v1 = lv_contrato.
        CONTINUE.
      ENDIF.

      IF <fs_carga>-vlr_bonus_ini IS NOT INITIAL AND
         <fs_carga>-vlr_montbonus_ini IS NOT INITIAL.
        "Preencher % Bonus OU Mont Bonus
        APPEND INITIAL LINE TO et_return ASSIGNING <fs_erro1>.
        <fs_erro1>-id = gc_msg.
        <fs_erro1>-type = gc_e.
        <fs_erro1>-number = '011'.
        <fs_erro1>-message_v1 = lv_contrato.
        CONTINUE.
      ENDIF.


      APPEND INITIAL LINE TO et_doc ASSIGNING FIELD-SYMBOL(<fs_doc>).
      READ TABLE lt_contrato ASSIGNING FIELD-SYMBOL(<fs_contrato>) WITH KEY contrato = <fs_carga>-contrato
                                                                            aditivo = <fs_carga>-aditivo
                                                                   BINARY SEARCH.
      IF sy-subrc IS INITIAL.
        <fs_doc>-doc_uuid_h      =   <fs_contrato>-doc_uuid_h.
      ENDIF.
      <fs_doc>-doc_uuid_faixa    = me->get_next_guid( ).
      <fs_doc>-contrato          = <fs_carga>-contrato.
      <fs_doc>-aditivo           = <fs_carga>-aditivo.
      <fs_doc>-moeda             = <fs_carga>-moeda .
      <fs_doc>-cod_faixa         = <fs_carga>-cod_faixa.
      <fs_doc>-vlr_faixa_ini     = <fs_carga>-vlr_faixa_ini.
      <fs_doc>-vlr_faixa_fim     = <fs_carga>-vlr_faixa_fim.
      <fs_doc>-cod_montante      = <fs_carga>-cod_montante.
      <fs_doc>-vlr_mont_ini      = <fs_carga>-vlr_mont_ini.
      <fs_doc>-vlr_mont_fim      = <fs_carga>-vlr_mont_fim.
*      <fs_doc>-cod_bonus         = <fs_carga>-cod_bonus.
      <fs_doc>-vlr_bonus_ini     = <fs_carga>-vlr_bonus_ini.
*      <fs_doc>-vlr_bonus_fim     = <fs_carga>-vlr_bonus_fim.
*      <fs_doc>-cod_mbonus        = <fs_carga>-cod_mbonus.
      <fs_doc>-vlr_montbonus_ini = <fs_carga>-vlr_montbonus_ini.
*      <fs_doc>-vlr_montbonus_fim = <fs_carga>-vlr_montbonus_fim.

      <fs_doc>-created_by = sy-uname.
      GET TIME STAMP FIELD <fs_doc>-created_at.


    ENDLOOP.



  ENDMETHOD.


  METHOD upload_save_faixacresc.

    IF it_doc[] IS NOT INITIAL.

      MODIFY ztfi_faixa_cresc FROM TABLE it_doc.

      IF sy-subrc NE 0.
        " Falha ao salvar dados de carga.
        et_return[] = VALUE #( BASE et_return ( type = gc_e id = gc_msg number = gc_num2 ) ).
        RETURN.
      ELSE.
        "Carga realizada com sucesso
        et_return[] = VALUE #( BASE et_return ( type = gc_s id = gc_msg number = gc_num6 ) ).
        "Processo finalizado
        et_return[] = VALUE #( BASE et_return ( type = gc_s id = gc_msg number = gc_num7 ) ).
      ENDIF.
    ENDIF.

  ENDMETHOD.


  METHOD upload_contaprov.

    DATA: lt_file TYPE zctgfi_cont_aprov.
    DATA: lt_doc  TYPE TABLE OF ztfi_cont_aprov.
    DATA: lv_mimetype TYPE w3conttype.
*    DATA  lv_filetype  TYPE ze_carga_contratos.
    DATA  lv_filetype  TYPE c LENGTH 60.

    CONSTANTS lc_aprov(60)   TYPE c VALUE '11 - Aprovações do Contrato / ZTFI_CONT_APROV'.

    lv_filetype = lc_aprov.

* ---------------------------------------------------------------------------
* Valida tipo de arquivo
* ---------------------------------------------------------------------------
    CALL FUNCTION 'SDOK_MIMETYPE_GET'
      EXPORTING
        extension = gc_xlsx
      IMPORTING
        mimetype  = lv_mimetype.

    IF is_media-mime_type NE lv_mimetype.
      " Formato de arquivo não suportado. Realizar nova carga com formato "xlsx".
      et_return[] = VALUE #( BASE et_return ( type = gc_e id = gc_msg number = gc_num1 ) ).
    ENDIF.

    CHECK NOT line_exists( et_return[ type = gc_e ] ).

* ---------------------------------------------------------------------------
* Converte arquivo excel para tabela
* ---------------------------------------------------------------------------
    DATA(lo_excel) = NEW zclca_excel( iv_filename = iv_filename
                                      iv_file     = is_media-value ).

    lo_excel->get_sheet( IMPORTING et_return = DATA(lt_return)
                         CHANGING  ct_table  = lt_file[] ).

    et_return[] = VALUE #( BASE et_return FOR ls_return IN lt_return ( ls_return ) ).

    CHECK NOT line_exists( et_return[ type = gc_e ] ).

* ---------------------------------------------------------------------------
* Preenche tabelas interna
* ---------------------------------------------------------------------------
    me->upload_fill_data_contaprov( EXPORTING
                            it_file     = lt_file[]
                          IMPORTING
                            et_doc      = lt_doc[]
                            et_return   = lt_return[] ).

    et_return[] = VALUE #( BASE et_return FOR ls_return IN lt_return ( ls_return ) ).
    CHECK NOT line_exists( et_return[ type = gc_e ] ).

* ---------------------------------------------------------------------------
* Salva registros
* ---------------------------------------------------------------------------
    me->upload_save_contaprov(
            EXPORTING
            it_doc = lt_doc[]
            IMPORTING
            et_return = lt_return[] ).

    APPEND LINES OF lt_return TO et_return.
    CLEAR: lt_return.

* ---------------------------------------------------------------------------
* Salva registros no Header
* ---------------------------------------------------------------------------
    me->upload_header( EXPORTING
                   iv_filetype   = lv_filetype
          IMPORTING
                   et_return     = lt_return ).

    APPEND LINES OF lt_return TO et_return.
    CLEAR: lt_return.

  ENDMETHOD.


  METHOD upload_fill_data_contaprov.

    DATA: lt_carga  TYPE zctgfi_cont_aprov.

    FREE et_doc.

    lt_carga[] = it_file[].
    LOOP AT lt_carga ASSIGNING FIELD-SYMBOL(<fs_carga_aux>).

      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
        EXPORTING
          input  = <fs_carga_aux>-contrato
        IMPORTING
          output = <fs_carga_aux>-contrato.

    ENDLOOP.
    DATA(lt_carga_aux) = lt_carga[].
    SORT lt_carga_aux BY contrato aditivo.
    DELETE ADJACENT DUPLICATES FROM lt_carga_aux COMPARING contrato aditivo.

    IF lt_carga_aux[] IS NOT INITIAL.
      SELECT doc_uuid_h, contrato, aditivo
        FROM ztfi_contrato
        INTO TABLE @DATA(lt_contrato)
        FOR ALL ENTRIES IN @lt_carga_aux
        WHERE contrato = @lt_carga_aux-contrato
          AND aditivo = @lt_carga_aux-aditivo.
      IF sy-subrc IS INITIAL.
        SORT lt_contrato BY contrato aditivo.
      ENDIF.
    ENDIF.

    LOOP AT lt_carga ASSIGNING FIELD-SYMBOL(<fs_carga>).

      APPEND INITIAL LINE TO et_doc ASSIGNING FIELD-SYMBOL(<fs_doc>).
      READ TABLE lt_contrato ASSIGNING FIELD-SYMBOL(<fs_contrato>) WITH KEY contrato = <fs_carga>-contrato
                                                                            aditivo = <fs_carga>-aditivo
                                                                   BINARY SEARCH.
      IF sy-subrc IS INITIAL.
        <fs_doc>-doc_uuid_h      =   <fs_contrato>-doc_uuid_h.
      ENDIF.
      <fs_doc>-doc_uuid_aprov    = me->get_next_guid( ).
      <fs_doc>-contrato          = <fs_carga>-contrato.
      <fs_doc>-aditivo           = <fs_carga>-aditivo.
      <fs_doc>-nivel             = <fs_carga>-nivel.
      <fs_doc>-aprovador         = <fs_carga>-aprovador.
      <fs_doc>-data_aprov        = <fs_carga>-data_aprov.
      <fs_doc>-hora_aprov        = <fs_carga>-hora_aprov.
      <fs_doc>-nivel_atual       = <fs_carga>-nivel_atual.
      <fs_doc>-observacao        = <fs_carga>-observacao.
      <fs_doc>-created_by       = sy-uname.
      GET TIME STAMP FIELD <fs_doc>-created_at.
      <fs_doc>-local_last_changed_at = <fs_doc>-created_at.


    ENDLOOP.


  ENDMETHOD.


  METHOD upload_save_contaprov.

    IF it_doc[] IS NOT INITIAL.

      MODIFY ztfi_cont_aprov FROM TABLE it_doc.

      IF sy-subrc NE 0.
        " Falha ao salvar dados de carga.
        et_return[] = VALUE #( BASE et_return ( type = gc_e id = gc_msg number = gc_num2 ) ).
        RETURN.
      ELSE.
        "Carga realizada com sucesso
        et_return[] = VALUE #( BASE et_return ( type = gc_s id = gc_msg number = gc_num6 ) ).
        "Processo finalizado
        et_return[] = VALUE #( BASE et_return ( type = gc_s id = gc_msg number = gc_num7 ) ).

      ENDIF.
    ENDIF.

  ENDMETHOD.


  METHOD upload_basecompar.

    DATA: lt_file TYPE zctgfi_base_compar.
    DATA: lt_doc  TYPE TABLE OF ztfi_comp_cresci.
    DATA: lv_mimetype TYPE w3conttype.
*    DATA  lv_filetype  TYPE ze_carga_contratos.
    DATA  lv_filetype  TYPE c LENGTH 60.

    CONSTANTS lc_base(63)   TYPE c VALUE '16 - Cadastro Base de Comparação Crescimento / ZTFI_COMP_CRESCI'.

    lv_filetype = lc_base.

* ---------------------------------------------------------------------------
* Valida tipo de arquivo
* ---------------------------------------------------------------------------
    CALL FUNCTION 'SDOK_MIMETYPE_GET'
      EXPORTING
        extension = gc_xlsx
      IMPORTING
        mimetype  = lv_mimetype.

    IF is_media-mime_type NE lv_mimetype.
      " Formato de arquivo não suportado. Realizar nova carga com formato "xlsx".
      et_return[] = VALUE #( BASE et_return ( type = gc_e id = gc_msg number = gc_num1 ) ).
    ENDIF.

    CHECK NOT line_exists( et_return[ type = gc_e ] ).

* ---------------------------------------------------------------------------
* Converte arquivo excel para tabela
* ---------------------------------------------------------------------------
    DATA(lo_excel) = NEW zclca_excel( iv_filename = iv_filename
                                      iv_file     = is_media-value ).

    lo_excel->get_sheet( IMPORTING et_return = DATA(lt_return)
                         CHANGING  ct_table  = lt_file[] ).

    et_return[] = VALUE #( BASE et_return FOR ls_return IN lt_return ( ls_return ) ).

    CHECK NOT line_exists( et_return[ type = gc_e ] ).

* ---------------------------------------------------------------------------
* Preenche tabelas interna
* ---------------------------------------------------------------------------
    me->upload_fill_data_basecompar( EXPORTING
                            it_file     = lt_file[]
                          IMPORTING
                            et_doc      = lt_doc[]
                            et_return   = lt_return[] ).

    et_return[] = VALUE #( BASE et_return FOR ls_return IN lt_return ( ls_return ) ).
    CHECK NOT line_exists( et_return[ type = gc_e ] ).

* ---------------------------------------------------------------------------
* Salva registros
* ---------------------------------------------------------------------------
    me->upload_save_basecompar(
            EXPORTING
            it_doc = lt_doc[]
            IMPORTING
            et_return = lt_return[] ).

    APPEND LINES OF lt_return TO et_return.
    CLEAR: lt_return.

* ---------------------------------------------------------------------------
* Salva registros no Header
* ---------------------------------------------------------------------------
    me->upload_header( EXPORTING
                   iv_filetype   = lv_filetype
          IMPORTING
                   et_return     = lt_return ).

    APPEND LINES OF lt_return TO et_return.
    CLEAR: lt_return.

  ENDMETHOD.


  METHOD upload_fill_data_basecompar.

    DATA: lt_carga  TYPE zctgfi_base_compar.

    lt_carga[] = it_file[].

    FREE et_doc.

    LOOP AT lt_carga ASSIGNING FIELD-SYMBOL(<fs_carga_aux>).

      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
        EXPORTING
          input  = <fs_carga_aux>-contrato
        IMPORTING
          output = <fs_carga_aux>-contrato.

    ENDLOOP.

    DATA(lt_carga_aux) = lt_carga[].
    SORT lt_carga_aux BY contrato aditivo.
    DELETE ADJACENT DUPLICATES FROM lt_carga_aux COMPARING contrato aditivo.


    IF lt_carga_aux[] IS NOT INITIAL.
      SELECT doc_uuid_h, contrato, aditivo
        FROM ztfi_contrato
        INTO TABLE @DATA(lt_contrato)
        FOR ALL ENTRIES IN @lt_carga_aux
        WHERE contrato = @lt_carga_aux-contrato
           AND aditivo = @lt_carga_aux-aditivo.
      IF sy-subrc IS INITIAL.
        SORT lt_contrato BY contrato aditivo.
      ENDIF.
    ENDIF.

    LOOP AT lt_carga ASSIGNING FIELD-SYMBOL(<fs_carga>).

      APPEND INITIAL LINE TO et_doc ASSIGNING FIELD-SYMBOL(<fs_doc>).
      READ TABLE lt_contrato ASSIGNING FIELD-SYMBOL(<fs_contrato>) WITH KEY contrato = <fs_carga>-contrato
                                                                            aditivo = <fs_carga>-aditivo
                                                                   BINARY SEARCH.
      IF sy-subrc IS INITIAL.
        <fs_doc>-doc_uuid_h      =   <fs_contrato>-doc_uuid_h.
      ENDIF.

      <fs_doc>-doc_uuid_ciclo =  me->get_next_guid( ).
      <fs_doc>-contrato          = <fs_carga>-contrato.
      <fs_doc>-aditivo           = <fs_carga>-aditivo.
      <fs_doc>-ciclos             = <fs_carga>-ciclo.
      <fs_doc>-waers             = <fs_carga>-moeda.
      <fs_doc>-waers             = <fs_carga>-moeda.
      <fs_doc>-mont_comp     = <fs_carga>-montante_comp.
      <fs_doc>-created_by        = sy-uname.
      GET TIME STAMP FIELD <fs_doc>-created_at.
      <fs_doc>-local_last_changed_at = <fs_doc>-created_at.

    ENDLOOP.


  ENDMETHOD.


  METHOD upload_save_basecompar.

    IF it_doc[] IS NOT INITIAL.

      MODIFY ztfi_comp_cresci FROM TABLE it_doc.

      IF sy-subrc NE 0.
        " Falha ao salvar dados de carga.
        et_return[] = VALUE #( BASE et_return ( type = gc_e id = gc_msg number = gc_num2 ) ).
        RETURN.
      ELSE.
        "Carga realizada com sucesso
        et_return[] = VALUE #( BASE et_return ( type = gc_s id = gc_msg number = gc_num6 ) ).
        "Processo finalizado
        et_return[] = VALUE #( BASE et_return ( type = gc_s id = gc_msg number = gc_num7 ) ).

      ENDIF.
    ENDIF.

  ENDMETHOD.


  METHOD upload_famiprov.

    DATA: lt_file TYPE zctgfi_fami_provi.
    DATA: lt_doc  TYPE TABLE OF ztfi_prov_fam.
    DATA: lv_mimetype TYPE w3conttype.
    DATA  lv_filetype  TYPE c LENGTH 60.

    CONSTANTS lc_cad_prov(60)      TYPE c VALUE '7 - Cadastro Campo Familia Provisões / ZTFI_PROV_FAM'.

    lv_filetype = lc_cad_prov.

* ---------------------------------------------------------------------------
* Valida tipo de arquivo
* ---------------------------------------------------------------------------
    CALL FUNCTION 'SDOK_MIMETYPE_GET'
      EXPORTING
        extension = gc_xlsx
      IMPORTING
        mimetype  = lv_mimetype.

    IF is_media-mime_type NE lv_mimetype.
      " Formato de arquivo não suportado. Realizar nova carga com formato "xlsx".
      et_return[] = VALUE #( BASE et_return ( type = gc_e id = gc_msg number = gc_num1 ) ).
    ENDIF.

    CHECK NOT line_exists( et_return[ type = gc_e ] ).

* ---------------------------------------------------------------------------
* Converte arquivo excel para tabela
* ---------------------------------------------------------------------------
    DATA(lo_excel) = NEW zclca_excel( iv_filename = iv_filename
                                      iv_file     = is_media-value ).

    lo_excel->get_sheet( IMPORTING et_return = DATA(lt_return)
                         CHANGING  ct_table  = lt_file[] ).

    et_return[] = VALUE #( BASE et_return FOR ls_return IN lt_return ( ls_return ) ).

    CHECK NOT line_exists( et_return[ type = gc_e ] ).

* ---------------------------------------------------------------------------
* Preenche tabelas interna
* ---------------------------------------------------------------------------
    me->upload_fill_data_famiprovi( EXPORTING
                            it_file     = lt_file[]
                          IMPORTING
                            et_doc      = lt_doc[]
                            et_return   = lt_return[] ).

    et_return[] = VALUE #( BASE et_return FOR ls_return IN lt_return ( ls_return ) ).
    CHECK NOT line_exists( et_return[ type = gc_e ] ).

* ---------------------------------------------------------------------------
* Salva registros
* ---------------------------------------------------------------------------
    me->upload_save_famiprovi(
            EXPORTING
            it_doc = lt_doc[]
            IMPORTING
            et_return = lt_return[] ).

    APPEND LINES OF lt_return TO et_return.
    CLEAR: lt_return.
* ---------------------------------------------------------------------------
* Salva registros no Header
* ---------------------------------------------------------------------------
    me->upload_header( EXPORTING
                   iv_filetype   = lv_filetype
          IMPORTING
                   et_return     = lt_return ).

    APPEND LINES OF lt_return TO et_return.
    CLEAR: lt_return.


  ENDMETHOD.


  METHOD upload_fill_data_famiprovi.

    DATA: lt_carga  TYPE zctgfi_fami_provi.
    DATA: lv_tabix TYPE sy-tabix.

    FREE et_doc.

    lt_carga[] = it_file[].
    LOOP AT lt_carga ASSIGNING FIELD-SYMBOL(<fs_carga_aux>).

      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
        EXPORTING
          input  = <fs_carga_aux>-contrato
        IMPORTING
          output = <fs_carga_aux>-contrato.

*      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
*        EXPORTING
*          input  = <fs_carga_aux>-cond_desconto
*        IMPORTING
*          output = <fs_carga_aux>-cond_desconto.

    ENDLOOP.

    DATA(lt_carga_aux) = lt_carga[].
    SORT lt_carga_aux BY contrato aditivo. " cond_desconto.
    DELETE ADJACENT DUPLICATES FROM lt_carga_aux COMPARING contrato aditivo. " cond_desconto.

    IF lt_carga_aux[] IS NOT INITIAL.
      SELECT doc_uuid_h, doc_uuid_prov, contrato, aditivo , cond_desconto
        FROM ztfi_cad_provi
        INTO TABLE @DATA(lt_contrato)
        FOR ALL ENTRIES IN @lt_carga_aux
        WHERE contrato = @lt_carga_aux-contrato
          AND aditivo = @lt_carga_aux-aditivo.
      "AND cond_desconto = @lt_carga_aux-cond_desconto.
      IF sy-subrc IS INITIAL.
        SORT lt_contrato BY contrato aditivo." cond_desconto.
      ELSE.
        "Erro linha: &1 Contrato não localizado
        et_return[] = VALUE #( BASE et_return ( type = gc_e id = gc_msg number = '004' message_v1 = lv_tabix  ) ).
      ENDIF.
    ENDIF.

    "Condições do contrato
    LOOP AT lt_contrato ASSIGNING FIELD-SYMBOL(<fs_contrato>).

      LOOP AT lt_carga ASSIGNING FIELD-SYMBOL(<fs_carga>) WHERE contrato = <fs_contrato>-contrato
                                                                AND aditivo = <fs_contrato>-aditivo.

        lv_tabix = sy-tabix.

        APPEND INITIAL LINE TO et_doc ASSIGNING FIELD-SYMBOL(<fs_doc>).

        <fs_doc>-doc_uuid_h    =  <fs_contrato>-doc_uuid_h.
        <fs_doc>-doc_uuid_prov   = <fs_contrato>-doc_uuid_prov.
        <fs_doc>-contrato    =  <fs_carga>-contrato.
        <fs_doc>-aditivo     =  <fs_carga>-aditivo.
        <fs_doc>-familia     =  <fs_carga>-familia_cl.
        <fs_doc>-created_by  = sy-uname.
        GET TIME STAMP FIELD <fs_doc>-created_at.
        <fs_doc>-local_last_changed_at = <fs_doc>-created_at.

      ENDLOOP.
    ENDLOOP.


  ENDMETHOD.


  METHOD upload_save_famiprovi.

    IF it_doc[] IS NOT INITIAL.

      MODIFY ztfi_prov_fam FROM TABLE it_doc.

      IF sy-subrc NE 0.
        " Falha ao salvar dados de carga.
        et_return[] = VALUE #( BASE et_return ( type = gc_e id = gc_msg number = gc_num2 ) ).
        RETURN.
      ELSE.
        "Carga realizada com sucesso
        et_return[] = VALUE #( BASE et_return ( type = gc_s id = gc_msg number = gc_num6 ) ).
        "Processo finalizado
        et_return[] = VALUE #( BASE et_return ( type = gc_s id = gc_msg number = gc_num7 ) ).

      ENDIF.
    ENDIF.

  ENDMETHOD.


  METHOD upload_famicresc.

    DATA: lt_file TYPE zctgfi_fami_provi.
    DATA: lt_doc  TYPE TABLE OF ztfi_prov_fam.
    DATA: lv_mimetype TYPE w3conttype.
    DATA  lv_filetype  TYPE c LENGTH 60.

    CONSTANTS lc_cad_prov(60)      TYPE c VALUE '17 - Cadastro Familia Crescimento / ZTFI_CRESC_FAMIL'.

    lv_filetype = lc_cad_prov.

* ---------------------------------------------------------------------------
* Valida tipo de arquivo
* ---------------------------------------------------------------------------
    CALL FUNCTION 'SDOK_MIMETYPE_GET'
      EXPORTING
        extension = gc_xlsx
      IMPORTING
        mimetype  = lv_mimetype.

    IF is_media-mime_type NE lv_mimetype.
      " Formato de arquivo não suportado. Realizar nova carga com formato "xlsx".
      et_return[] = VALUE #( BASE et_return ( type = gc_e id = gc_msg number = gc_num1 ) ).
    ENDIF.

    CHECK NOT line_exists( et_return[ type = gc_e ] ).

* ---------------------------------------------------------------------------
* Converte arquivo excel para tabela
* ---------------------------------------------------------------------------
    DATA(lo_excel) = NEW zclca_excel( iv_filename = iv_filename
                                      iv_file     = is_media-value ).

    lo_excel->get_sheet( IMPORTING et_return = DATA(lt_return)
                         CHANGING  ct_table  = lt_file[] ).

    et_return[] = VALUE #( BASE et_return FOR ls_return IN lt_return ( ls_return ) ).

    CHECK NOT line_exists( et_return[ type = gc_e ] ).

* ---------------------------------------------------------------------------
* Preenche tabelas interna
* ---------------------------------------------------------------------------
    me->upload_fill_data_famicresc( EXPORTING
                            it_file     = lt_file[]
                          IMPORTING
                            et_doc      = lt_doc[]
                            et_return   = lt_return[] ).

    et_return[] = VALUE #( BASE et_return FOR ls_return IN lt_return ( ls_return ) ).
    CHECK NOT line_exists( et_return[ type = gc_e ] ).

* ---------------------------------------------------------------------------
* Salva registros
* ---------------------------------------------------------------------------
    me->upload_save_famicresc(
            EXPORTING
            it_doc = lt_doc[]
            IMPORTING
            et_return = lt_return[] ).

    APPEND LINES OF lt_return TO et_return.
    CLEAR: lt_return.
* ---------------------------------------------------------------------------
* Salva registros no Header
* ---------------------------------------------------------------------------
    me->upload_header( EXPORTING
                   iv_filetype   = lv_filetype
          IMPORTING
                   et_return     = lt_return ).

    APPEND LINES OF lt_return TO et_return.
    CLEAR: lt_return.


  ENDMETHOD.


  METHOD upload_fill_data_famicresc.

    DATA: lt_carga  TYPE zctgfi_fami_provi.
    DATA: lv_tabix TYPE sy-tabix.

    FREE et_doc.

    lt_carga[] = it_file[].
    LOOP AT lt_carga ASSIGNING FIELD-SYMBOL(<fs_carga_aux>).

      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
        EXPORTING
          input  = <fs_carga_aux>-contrato
        IMPORTING
          output = <fs_carga_aux>-contrato.

    ENDLOOP.

    DATA(lt_carga_aux) = lt_carga[].
    SORT lt_carga_aux BY contrato aditivo.
    DELETE ADJACENT DUPLICATES FROM lt_carga_aux COMPARING contrato aditivo.

    IF lt_carga_aux[] IS NOT INITIAL.
      SELECT doc_uuid_h, doc_uuid_cresc, contrato, aditivo
        FROM ztfi_cad_cresci
        INTO TABLE @DATA(lt_contrato)
        FOR ALL ENTRIES IN @lt_carga_aux
        WHERE contrato = @lt_carga_aux-contrato
          AND aditivo = @lt_carga_aux-aditivo.

      IF sy-subrc IS INITIAL.
        SORT lt_contrato BY contrato aditivo.
      ELSE.
        "Erro linha: &1 Contrato não localizado
        et_return[] = VALUE #( BASE et_return ( type = gc_e id = gc_msg number = '004' message_v1 = lv_tabix  ) ).
      ENDIF.
    ENDIF.

    "Condições do contrato
    LOOP AT lt_contrato ASSIGNING FIELD-SYMBOL(<fs_contrato>).

      LOOP AT lt_carga ASSIGNING FIELD-SYMBOL(<fs_carga>) WHERE contrato = <fs_contrato>-contrato AND
                                                                aditivo = <fs_contrato>-aditivo.

        APPEND INITIAL LINE TO et_doc ASSIGNING FIELD-SYMBOL(<fs_doc>).

        <fs_doc>-doc_uuid_h    =  <fs_contrato>-doc_uuid_h.
*        <fs_doc>-doc_uuid_h    =  <fs_contrato>-doc_uuid_cresc.
        <fs_doc>-doc_uuid_familia = me->get_next_guid( ).
        <fs_doc>-contrato         =  <fs_carga>-contrato.
        <fs_doc>-aditivo          =  <fs_carga>-aditivo.
        <fs_doc>-familia_cl       =  <fs_carga>-familia_cl.
        <fs_doc>-created_by  = sy-uname.
        GET TIME STAMP FIELD <fs_doc>-created_at.
        <fs_doc>-local_last_changed_at = <fs_doc>-created_at.

      ENDLOOP.
    ENDLOOP.


  ENDMETHOD.


  METHOD upload_save_famicresc.

    IF it_doc[] IS NOT INITIAL.

      MODIFY ztfi_cresc_famil FROM TABLE it_doc.

      IF sy-subrc NE 0.
        " Falha ao salvar dados de carga.
        et_return[] = VALUE #( BASE et_return ( type = gc_e id = gc_msg number = gc_num2 ) ).
        RETURN.
      ELSE.
        "Carga realizada com sucesso
        et_return[] = VALUE #( BASE et_return ( type = gc_s id = gc_msg number = gc_num6 ) ).
        "Processo finalizado
        et_return[] = VALUE #( BASE et_return ( type = gc_s id = gc_msg number = gc_num7 ) ).

      ENDIF.
    ENDIF.

  ENDMETHOD.
ENDCLASS.
