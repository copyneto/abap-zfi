"! Classe principal para logica de carga de contabilização FIGL
CLASS zclfi_carga_contabilizacao DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.


    CONSTANTS: BEGIN OF gc_status,
                 pendente   TYPE ztfi_carga_h-status VALUE '0',
                 erro       TYPE ztfi_carga_h-status VALUE '1',
                 processado TYPE ztfi_carga_h-status VALUE '2',
                 cancelado  TYPE ztfi_carga_h-status VALUE '3',
               END OF gc_status.

    CONSTANTS: BEGIN OF gc_status_doc,
                 pendente   TYPE ztfi_carga_h-status VALUE '0',
                 processado TYPE ztfi_carga_h-status VALUE '1',
                 erro       TYPE ztfi_carga_h-status VALUE '2',
               END OF gc_status_doc.

    "! Moeda padrão
    CONSTANTS gc_brl TYPE c LENGTH 3 VALUE 'BRL'.
    "! Tipo para erro
    CONSTANTS gc_e TYPE c  VALUE 'E'.

    "! Realiza carga de arquivo
    "! @parameter iv_filename | Nome do arquivo
    "! @parameter is_media | Arquivo enviado
    "! @parameter es_header | Dados de cabeçalho
    "! @parameter et_return | Mensagens de retorno
    METHODS upload
      IMPORTING iv_filename TYPE string
                is_media    TYPE /iwbep/if_mgw_appl_srv_runtime=>ty_s_media_resource
      EXPORTING es_header   TYPE ztfi_carga_h
                et_return   TYPE bapiret2_t.

    "! Realizar lançamento de documento financeiro
    "! @parameter iv_doc | id do documento carregado
    "! @parameter et_return | tabela de mensagens
    METHODS lancar
      IMPORTING iv_doc    TYPE ztfi_carga_h-doc_uuid_h
      EXPORTING et_return TYPE bapiret2_t.

    "! Salvar mensagens de processamento
    "! @parameter iv_doc | id do documento carregado
    "! @parameter it_return | tabela de mensagens
    METHODS salvar_log
      IMPORTING iv_doc    TYPE ztfi_carga_h-doc_uuid_h
                it_return TYPE bapiret2_t.

  PROTECTED SECTION.
  PRIVATE SECTION.
    CONSTANTS:
      gc_object       TYPE xuobject VALUE 'ZFICARGACC',
      gc_actvt_import TYPE char2    VALUE '60'.

    "! Processar arquivo e separar em tabelas
    "! @parameter it_file | Tabela do arquivo
    "! @parameter es_header | Estrutura de header
    "! @parameter et_item | Tabela de itens
    "! @parameter et_doc | Tabela de documentos
    "! @parameter et_return | Tabela de retorno
    METHODS upload_fill_data
      IMPORTING
        it_file   TYPE zctgfi_carga_arquivo
      EXPORTING
        es_header TYPE ztfi_carga_h
        et_item   TYPE zctgfi_carga_arquivo_item
        et_doc    TYPE zctgfi_carga_arquivo_doc
        et_return TYPE bapiret2_t.
    "! Separar dados de header e preencher
    "! @parameter et_return | Tabela de mensagens
    "! @parameter rs_header | Retorno do header preenchido
    METHODS fill_header
      EXPORTING et_return        TYPE bapiret2_t
      RETURNING
                VALUE(rs_header) TYPE ztfi_carga_h.
    "! Buscar proximo guid disponivel
    "! @parameter ev_guid | Retornar guid gerado
    "! @parameter et_return | Tabela de mensagens
    "! @parameter rv_guid | Retornar guid gerado
    METHODS get_next_guid
      EXPORTING ev_guid        TYPE sysuuid_x16
                et_return      TYPE bapiret2_t
      RETURNING
                VALUE(rv_guid) TYPE sysuuid_x16.
    "! Buscar proximo id de documento
    "! @parameter et_return | tabela de mensagens
    "! @parameter rv_docnumber | retornar id gerado
    METHODS get_next_documentno
      EXPORTING et_return           TYPE bapiret2_t
      RETURNING
                VALUE(rv_docnumber) TYPE ztfi_carga_h-documentno.
    "! Salvar dados carregados nas tabelas
    "! @parameter is_header | estrutura de header
    "! @parameter it_item | tabela de itens
    "! @parameter it_doc | Tabela de documentos
    "! @parameter et_return | Tabela de mensagens
    METHODS upload_save
      IMPORTING
        is_header TYPE ztfi_carga_h
        it_item   TYPE zctgfi_carga_arquivo_item
        it_doc    TYPE zctgfi_carga_arquivo_doc
      EXPORTING
        et_return TYPE bapiret2_t.
    "! Limpar variaveis de lancamento
    METHODS clear_all.
    "! Preenhcer header de lancamento
    METHODS fill_bapi_header.
    "! Preencher tabela de itens para lancamento
    "! @parameter is_item | item do arquivo
    METHODS fill_bapi_item
      IMPORTING
        is_item TYPE ztfi_carga_item.
    "! validar dados de lancamento
    "! @parameter et_return | tabela de mensagens
    METHODS bapi_check
      EXPORTING
        et_return TYPE bapiret2_t.
    "! Lançar documento financeiro
    "! @parameter ev_documento | Id do documento criado
    "! @parameter et_return | Tabela de mensagens
    METHODS bapi_post
      EXPORTING
        ev_documento TYPE bseg-belnr
        et_return    TYPE bapiret2_t.
    "! Atualizar status do header
    "! @parameter iv_status | status para atribuir
    METHODS atualizar_status_doc
      IMPORTING
        iv_status TYPE ztfi_carga_doc-status
        iv_doc    TYPE bseg-belnr OPTIONAL.
    "! Atualiza status do header conforme retorno
    METHODS atualiza_status_header.

    "! Verificar autorização para upload de arquivo
    "! @parameter rv_check | 'X' autorizado / ' ' não autorizado
    METHODS check_auth_for_upload
      RETURNING
        VALUE(rv_check) TYPE abap_boolean.


    DATA gs_header TYPE bapiache09 .
    DATA gt_acc_gl TYPE bapiacgl09_tab .
    DATA gt_acc_rec TYPE bapiacar09_tab .
    DATA gt_currency TYPE bapiaccr09_tab .
    DATA gt_extension2 TYPE TABLE OF bapiparex .
    DATA gv_dummy TYPE string .
    DATA gv_error TYPE boolean .
    DATA gv_ocorreu_erro TYPE boolean .
    DATA gt_return TYPE bapiret2_t .
    DATA gv_item_no   TYPE bapiacgl09-itemno_acc.
    DATA gs_doc TYPE ztfi_carga_doc.

ENDCLASS.



CLASS ZCLFI_CARGA_CONTABILIZACAO IMPLEMENTATION.


  METHOD upload.

    DATA: lt_file TYPE zctgfi_carga_arquivo,
          lt_doc  TYPE TABLE OF ztfi_carga_doc,
          lt_item TYPE TABLE OF ztfi_carga_item.
    DATA: ls_header   TYPE ztfi_carga_h.
    DATA: lv_mimetype TYPE w3conttype.

* ---------------------------------------------------------------------------
* Verificar autorização para upload de arquivo
* ---------------------------------------------------------------------------
    IF me->check_auth_for_upload( ) = abap_false.
      et_return[] = VALUE #( ( type = 'E' id = 'ZFI_CARGA_CONTAB' message_v1 = sy-uname number = '019' ) ).
      RETURN.
    ENDIF.

* ---------------------------------------------------------------------------
* Valida tipo de arquivo
* ---------------------------------------------------------------------------
    CALL FUNCTION 'SDOK_MIMETYPE_GET'
      EXPORTING
        extension = 'XLSX'
      IMPORTING
        mimetype  = lv_mimetype.

    IF is_media-mime_type NE lv_mimetype.
      " Formato de arquivo não suportado. Realizar nova carga com formato "xlsx".
      et_return[] = VALUE #( BASE et_return ( type = 'E' id = 'ZFI_CARGA_CONTAB' number = '008' ) ).
    ENDIF.

    CHECK NOT line_exists( et_return[ type = 'E' ] ).    "#EC CI_STDSEQ

* ---------------------------------------------------------------------------
* Converte arquivo excel para tabela
* ---------------------------------------------------------------------------
    DATA(lo_excel) = NEW zclca_excel( iv_filename = iv_filename
                                      iv_file     = is_media-value ).

    lo_excel->get_sheet( IMPORTING et_return = DATA(lt_return)
                         CHANGING  ct_table  = lt_file[] ).

    et_return[] = VALUE #( BASE et_return FOR ls_return IN lt_return ( ls_return ) ).

    CHECK NOT line_exists( et_return[ type = 'E' ] ).    "#EC CI_STDSEQ

* ---------------------------------------------------------------------------
* Preenche tabelas interna
* ---------------------------------------------------------------------------
    me->upload_fill_data( EXPORTING
                            it_file     = lt_file[]
                          IMPORTING
                            es_header   = ls_header
                            et_item     = lt_item[]
                            et_doc      = lt_doc[]
                            et_return   = lt_return[] ).

    et_return[] = VALUE #( BASE et_return FOR ls_return IN lt_return ( ls_return ) ).
    CHECK NOT line_exists( et_return[ type = 'E' ] ).    "#EC CI_STDSEQ

* ---------------------------------------------------------------------------
* Salva registros
* ---------------------------------------------------------------------------
    me->upload_save(
            EXPORTING
            is_header = ls_header
            it_item = lt_item[]
            it_doc = lt_doc[]
            IMPORTING
            et_return = lt_return[] ).

  ENDMETHOD.


  METHOD upload_fill_data.

    DATA: lt_header  TYPE zctgfi_carga_arquivo,
          lt_arquivo TYPE zctgfi_carga_arquivo.

    DATA: lv_nro_doc TYPE i.

* ----------------------------------------------------------------------
* Preenche dados cabeçalho
* ----------------------------------------------------------------------
    es_header = me->fill_header( IMPORTING et_return = et_return  ).

    lt_header[] = it_file[].
    SORT: lt_header BY numero_doc.

    CLEAR lv_nro_doc.

    LOOP AT lt_header ASSIGNING FIELD-SYMBOL(<fs_header>).

      ADD 1 TO lv_nro_doc.

      APPEND INITIAL LINE TO et_doc ASSIGNING FIELD-SYMBOL(<fs_doc>).

* ----------------------------------------------------------------------
* Preenche dados documentos
* ----------------------------------------------------------------------
      <fs_doc>-doc_uuid_h            = es_header-doc_uuid_h.
      <fs_doc>-doc_uuid_doc          = get_next_guid( ).
      <fs_doc>-numero_doc            = lv_nro_doc.
      <fs_doc>-bukrs                 = <fs_header>-bukrs.
      <fs_doc>-blart                 = <fs_header>-blart.
      <fs_doc>-bldat                 = <fs_header>-bldat.
      <fs_doc>-budat                 = <fs_header>-budat.
      <fs_doc>-monat                 = <fs_header>-monat.
      <fs_doc>-gjahr                 = <fs_header>-gjahr.
      <fs_doc>-xblnr                 = <fs_header>-xblnr.
      <fs_doc>-bktxt                 = <fs_header>-bktxt.
      <fs_doc>-created_by            = es_header-created_by.
      <fs_doc>-created_at            = es_header-created_at.
      <fs_doc>-local_last_changed_at = es_header-created_at.

* ----------------------------------------------------------------------
* Preenche dados itens
* ----------------------------------------------------------------------

      APPEND INITIAL LINE TO et_item ASSIGNING FIELD-SYMBOL(<fs_item>).

      "@@ Linha de debito
      <fs_item>-doc_uuid_h            = es_header-doc_uuid_h.
      <fs_item>-doc_uuid_doc          = <fs_doc>-doc_uuid_doc.
      <fs_item>-numero_doc            = lv_nro_doc.
      <fs_item>-doc_uuid_item         = get_next_guid(  ).
      <fs_item>-numero_item           = '1'.
      <fs_item>-shkzg                 = <fs_header>-deb_shkzg.
      <fs_item>-zuonr                 = <fs_header>-deb_zuonr.
      <fs_item>-hkont                 = <fs_header>-deb_hkont.
      <fs_item>-dmbtr                 = <fs_header>-deb_dmbtr.
      <fs_item>-waers                 = 'BRL'.
      <fs_item>-bupla                 = <fs_header>-deb_bupla.
      <fs_item>-gsber                 = <fs_header>-deb_gsber.
      <fs_item>-kostl                 = <fs_header>-deb_kostl.
      <fs_item>-prctr                 = <fs_header>-deb_prctr.
      <fs_item>-segment               = <fs_header>-deb_segment.
      <fs_item>-sgtxt                 = <fs_header>-deb_sgtxt.
      <fs_item>-created_by            = es_header-created_by.
      <fs_item>-created_at            = es_header-created_at.
      <fs_item>-local_last_changed_at = es_header-created_at.

      APPEND INITIAL LINE TO et_item ASSIGNING FIELD-SYMBOL(<fs_item2>).

      "@@ Linha de credito
      <fs_item2>-doc_uuid_h            = es_header-doc_uuid_h.
      <fs_item2>-doc_uuid_doc          = <fs_doc>-doc_uuid_doc.
      <fs_item2>-numero_doc            = lv_nro_doc.
      <fs_item2>-doc_uuid_item         = get_next_guid(  ).
      <fs_item2>-numero_item           = '2'.
      <fs_item2>-shkzg                 = <fs_header>-cre_shkzg.
      <fs_item2>-zuonr                 = <fs_header>-cre_zuonr.
      <fs_item2>-hkont                 = <fs_header>-cre_hkont.
      <fs_item2>-dmbtr                 = <fs_header>-cre_dmbtr.
      <fs_item2>-waers                 = 'BRL'.
      <fs_item2>-bupla                 = <fs_header>-cre_bupla.
      <fs_item2>-gsber                 = <fs_header>-cre_gsber.
      <fs_item2>-kostl                 = <fs_header>-cre_kostl.
      <fs_item2>-prctr                 = <fs_header>-cre_prctr.
      <fs_item2>-segment               = <fs_header>-cre_segment.
      <fs_item2>-sgtxt                 = <fs_header>-cre_sgtxt.
      <fs_item2>-created_by            = es_header-created_by.
      <fs_item2>-created_at            = es_header-created_at.
      <fs_item2>-local_last_changed_at = es_header-created_at.

    ENDLOOP.

  ENDMETHOD.


  METHOD fill_header.

    rs_header-doc_uuid_h             = me->get_next_guid( ).
    rs_header-documentno             = me->get_next_documentno( IMPORTING et_return = et_return ).
    rs_header-data_carga             = sy-datum.
    rs_header-status                 = gc_status-pendente.
    rs_header-created_by             = sy-uname.
    GET TIME STAMP FIELD rs_header-created_at.
    rs_header-local_last_changed_at  = rs_header-created_at.

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


  METHOD get_next_documentno.

    DATA: ls_return TYPE bapiret2,
          lv_object TYPE nrobj VALUE 'ZFICARGACO',
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


  METHOD upload_save.

    FREE: et_return.

    IF is_header IS NOT INITIAL.

      MODIFY ztfi_carga_h FROM is_header.

      IF sy-subrc NE 0.
        " Falha ao salvar dados de carga.
        et_return[] = VALUE #( BASE et_return ( type = 'E' id = 'ZFI_CARGA_CONTAB' number = '014' ) ).
        RETURN.
      ENDIF.
    ENDIF.

    IF it_doc IS NOT INITIAL.

      MODIFY ztfi_carga_doc FROM TABLE it_doc.

      IF sy-subrc NE 0.
        " Falha ao salvar dados de carga.
        et_return[] = VALUE #( BASE et_return ( type = 'E' id = 'ZFI_CARGA_CONTAB' number = '014' ) ).
        RETURN.
      ENDIF.
    ENDIF.

    IF it_item IS NOT INITIAL.

      MODIFY ztfi_carga_item FROM TABLE it_item.

      IF sy-subrc NE 0.
        " Falha ao salvar dados de carga.
        et_return[] = VALUE #( BASE et_return ( type = 'E' id = 'ZFI_CARGA_CONTAB' number = '014' ) ).
        RETURN.
      ENDIF.
    ENDIF.

  ENDMETHOD.


  METHOD lancar.

    DATA: lv_belnr TYPE bseg-belnr.
    DATA: lt_return TYPE bapiret2_tab.

    SELECT *
        FROM ztfi_carga_doc
        INTO TABLE @DATA(lt_doc)
        WHERE doc_uuid_h = @iv_doc.
    IF sy-subrc = 0.

      SELECT *
          FROM ztfi_carga_item
          INTO TABLE @DATA(lt_item)
          WHERE doc_uuid_h = @iv_doc.

    ENDIF.

    SORT: lt_doc BY numero_doc,
          lt_item BY numero_doc numero_item.

    LOOP AT lt_doc INTO me->gs_doc.                  "#EC CI_SEL_NESTED

      CLEAR: lt_return.

      me->clear_all(  ).

      me->fill_bapi_header( ).

      READ TABLE lt_item TRANSPORTING NO FIELDS WITH KEY numero_doc = me->gs_doc-numero_doc
                                                BINARY SEARCH.
      IF sy-subrc = 0.

        LOOP AT lt_item ASSIGNING FIELD-SYMBOL(<fs_item>) FROM sy-tabix.

          IF <fs_item>-numero_doc <> me->gs_doc-numero_doc.
            EXIT.
          ENDIF.

          me->fill_bapi_item( is_item = <fs_item> ).

        ENDLOOP.

      ENDIF.

      me->bapi_check(
        IMPORTING
          et_return = lt_return      ).

      IF gv_error = abap_false.

        bapi_post(
          IMPORTING
            ev_documento = lv_belnr
          et_return = lt_return ).

      ENDIF.

      APPEND LINES OF lt_return TO et_return.

    ENDLOOP.

    me->atualiza_status_header(  ).


  ENDMETHOD.


  METHOD clear_all.

    CLEAR: gs_header,
       gv_dummy,
       gv_error,
       gt_acc_gl,
       gt_acc_rec,
       gt_currency,
       gt_return,
       gt_extension2.

  ENDMETHOD.


  METHOD fill_bapi_header.

    CLEAR: gs_header.

    me->gs_header-pstng_date  = me->gs_doc-budat.
    me->gs_header-doc_date    = me->gs_doc-bldat.
    me->gs_header-fisc_year   = me->gs_doc-gjahr.
    me->gs_header-fis_period  = me->gs_doc-monat.
    me->gs_header-username    = sy-uname.
    me->gs_header-ref_doc_no  = me->gs_doc-xblnr.
    me->gs_header-header_txt  = me->gs_doc-bktxt.
    me->gs_header-comp_code   = me->gs_doc-bukrs.
    me->gs_header-doc_type    = me->gs_doc-blart.

  ENDMETHOD.


  METHOD fill_bapi_item.

    IF gv_item_no IS INITIAL.
      gv_item_no = 1.
    ELSE.
      ADD 1 TO gv_item_no.
    ENDIF.

    APPEND INITIAL LINE TO me->gt_acc_gl ASSIGNING FIELD-SYMBOL(<fs_gl>).
    <fs_gl>-itemno_acc = gv_item_no.
    <fs_gl>-comp_code = me->gs_doc-bukrs.
    <fs_gl>-fisc_year = me->gs_doc-gjahr.
    <fs_gl>-pstng_date = me->gs_doc-budat.
    <fs_gl>-alloc_nmbr = is_item-zuonr.
    <fs_gl>-gl_account = is_item-hkont.
    <fs_gl>-bus_area = is_item-gsber.
    <fs_gl>-costcenter = is_item-kostl.
    <fs_gl>-profit_ctr = is_item-prctr.
    <fs_gl>-segment = is_item-segment.
    <fs_gl>-item_text = is_item-sgtxt.

    APPEND INITIAL LINE TO me->gt_currency ASSIGNING FIELD-SYMBOL(<fs_curr>).
    <fs_curr>-itemno_acc = gv_item_no.
    <fs_curr>-currency_iso = gc_brl.
    IF is_item-shkzg = 'S'.
      <fs_curr>-amt_doccur = ( is_item-dmbtr ).
    ELSEIF is_item-shkzg = 'H'.
      <fs_curr>-amt_doccur = ( is_item-dmbtr ) * -1.
    ENDIF.


    APPEND VALUE #(
     structure = 'BUPLA'
     valuepart1 = gv_item_no
     valuepart2 = is_item-bupla ) TO gt_extension2.

  ENDMETHOD.


  METHOD bapi_check.

    CALL FUNCTION 'BAPI_ACC_DOCUMENT_CHECK'
      EXPORTING
        documentheader = me->gs_header
      TABLES
        accountgl      = me->gt_acc_gl
        currencyamount = me->gt_currency
        extension2     = me->gt_extension2
        return         = me->gt_return.

    IF line_exists( me->gt_return[ type = gc_e ] ).      "#EC CI_STDSEQ

      me->atualizar_status_doc(
        EXPORTING
          iv_status = gc_status_doc-erro    ).

      DELETE me->gt_return WHERE number = '609'
                             AND id = 'RW'.              "#EC CI_STDSEQ

      gv_error = abap_true.
      gv_ocorreu_erro = abap_true.

      et_return[] = VALUE #( BASE et_return ( type = 'E'
                                              id   = 'ZFI_CARGA_CONTAB'
                                              number = '016'
                                              message_v1 = me->gs_doc-numero_doc ) ).

      LOOP AT gt_return ASSIGNING FIELD-SYMBOL(<fs_msg>) WHERE type = gc_e. "#EC CI_LOOP_INTO_WA

        et_return[] = VALUE #( BASE et_return ( type = <fs_msg>-type
                                                id   = <fs_msg>-id
                                                number = <fs_msg>-number
                                                message_v1 = <fs_msg>-message_v1
                                                message_v2 = <fs_msg>-message_v2
                                                message_v3 = <fs_msg>-message_v3
                                                message_v4 = <fs_msg>-message_v4 ) ).

      ENDLOOP.

    ENDIF.



  ENDMETHOD.


  METHOD bapi_post.

    DATA: lv_obj_key TYPE bapiache09-obj_key.

    CALL FUNCTION 'BAPI_ACC_DOCUMENT_POST'
      EXPORTING
        documentheader = me->gs_header
      IMPORTING
        obj_key        = lv_obj_key
      TABLES
        accountgl      = me->gt_acc_gl
        currencyamount = me->gt_currency
        extension2     = me->gt_extension2
        return         = me->gt_return.

    "Erro no lançamento
    IF line_exists( me->gt_return[ type = gc_e ] ).      "#EC CI_STDSEQ
      gv_error = abap_true.
      gv_ocorreu_erro = abap_true.
      me->atualizar_status_doc(
        EXPORTING
          iv_status = gc_status_doc-erro ).

      LOOP AT gt_return ASSIGNING FIELD-SYMBOL(<fs_msg>) WHERE type = gc_e. "#EC CI_LOOP_INTO_WA

        et_return[] = VALUE #( BASE et_return ( type = <fs_msg>-type
                                                id   = <fs_msg>-id
                                                number = <fs_msg>-number
                                                message_v1 = <fs_msg>-message_v1
                                                message_v2 = <fs_msg>-message_v2
                                                message_v3 = <fs_msg>-message_v3
                                                message_v4 = <fs_msg>-message_v4 ) ).

      ENDLOOP.

    ELSE.

      READ TABLE me->gt_return ASSIGNING FIELD-SYMBOL(<fs_return>) WITH KEY type = 'S'
                                                                            id = 'RW'
                                                                            number = '605'.
      IF sy-subrc = 0.
        ev_documento =  lv_obj_key(10).
        APPEND <fs_return> TO et_return.
      ENDIF.

      CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
        EXPORTING
          wait = abap_true.

      me->atualizar_status_doc(
        EXPORTING
          iv_status = gc_status_doc-processado
          iv_doc    = ev_documento
      ).

    ENDIF.

  ENDMETHOD.


  METHOD atualizar_status_doc.

    IF iv_doc IS SUPPLIED.
      UPDATE ztfi_carga_doc
         SET status = iv_status
             belnr = iv_doc
         WHERE doc_uuid_h = me->gs_doc-doc_uuid_h
           AND doc_uuid_doc = me->gs_doc-doc_uuid_doc.
      IF sy-subrc = 0.
        CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
          EXPORTING
            wait = abap_true.
      ENDIF.
    ELSE.

      UPDATE ztfi_carga_doc
             SET status = iv_status
             WHERE doc_uuid_h = me->gs_doc-doc_uuid_h
               AND doc_uuid_doc = me->gs_doc-doc_uuid_doc.
      IF sy-subrc = 0.
        CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
          EXPORTING
            wait = abap_true.
      ENDIF.

    ENDIF.



  ENDMETHOD.


  METHOD atualiza_status_header.

    IF gv_ocorreu_erro = abap_true.

      UPDATE ztfi_carga_h
         SET status = gc_status-erro
         WHERE doc_uuid_h = me->gs_doc-doc_uuid_h.
      IF sy-subrc = 0.
        CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
          EXPORTING
            wait = abap_true.
      ENDIF.

    ELSE.

      UPDATE ztfi_carga_h
         SET status = gc_status-processado
         WHERE doc_uuid_h = me->gs_doc-doc_uuid_h.
      IF sy-subrc = 0.
        CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
          EXPORTING
            wait = abap_true.
      ENDIF.

    ENDIF.

  ENDMETHOD.


  METHOD salvar_log.

    DATA: lt_log TYPE STANDARD TABLE OF ztfi_carga_log.

* ---------------------------------------------------------------------------
* Recupera última mensagem criada
* ---------------------------------------------------------------------------
    SELECT MAX( seqnr )
      FROM ztfi_carga_log
      INTO @DATA(lv_seqnr)
     WHERE documentid = @iv_doc.

    IF sy-subrc NE 0.
      lv_seqnr = 1.
    ENDIF.

* prepara mensagens
* ---------------------------------------------------------------------------
    LOOP AT it_return INTO DATA(ls_return).

      lt_log[] = VALUE #( BASE lt_log ( documentid = iv_doc
                                        seqnr      = sy-tabix + lv_seqnr
                                        msgty      = ls_return-type
                                        msgid      = ls_return-id
                                        msgno      = ls_return-number
                                        msgv1      = ls_return-message_v1
                                        msgv2      = ls_return-message_v2
                                        msgv3      = ls_return-message_v3
                                        msgv4      = ls_return-message_v4
                                        message    = ls_return-message
                                        created_by = sy-uname
                                        created_at = sy-datum ) ).
    ENDLOOP.

* ---------------------------------------------------------------------------
* Salva mensagens
* ---------------------------------------------------------------------------
    IF lt_log[] IS NOT INITIAL.

      MODIFY ztfi_carga_log FROM TABLE lt_log[].
      IF sy-subrc = 0.
        COMMIT WORK AND WAIT.
      ENDIF.

    ENDIF.

  ENDMETHOD.


  METHOD check_auth_for_upload.
    AUTHORITY-CHECK OBJECT gc_object
    ID zclfi_auth_zfimtable=>gc_id-actvt FIELD gc_actvt_import.

    IF sy-subrc IS INITIAL.
      rv_check = abap_true.
    ELSE.
      rv_check = abap_false.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
