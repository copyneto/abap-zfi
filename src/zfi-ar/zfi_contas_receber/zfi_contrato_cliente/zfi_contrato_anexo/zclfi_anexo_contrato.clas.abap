CLASS zclfi_anexo_contrato DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    TYPES:
      BEGIN OF ty_info_arquivos,
        doc_uuid_ht  TYPE sysuuid_x16,
        contrato     TYPE  ze_num_contrato,
        aditivo      TYPE  ze_num_aditivo,
        doc_uuid_doc TYPE  sysuuid_x16,
        tipo_doc     TYPE  ze_tipo_anexo,
        filename     TYPE char100,
        mimetype     TYPE  w3conttype,
      END OF ty_info_arquivos .
    TYPES ty_arquivo TYPE ztfi_cont_anexo .
    TYPES:
      tt_arquivo TYPE TABLE OF ty_info_arquivos .
    TYPES:
      tt_info_arquivos TYPE TABLE OF ty_info_arquivos .

    DATA gv_novo LIKE abap_false VALUE abap_false ##NO_TEXT.
    DATA gv_doc_uuid_h TYPE ty_info_arquivos-doc_uuid_ht .
    DATA gv_contrato TYPE ty_info_arquivos-contrato .
    DATA gv_aditivo TYPE ty_info_arquivos-aditivo .
    CLASS-DATA gv_tipo_anexo_contrato_ass TYPE ze_tipo_anexo READ-ONLY VALUE 1 ##NO_TEXT.
    CLASS-DATA gv_tipo_anexo_minuta TYPE ze_tipo_anexo READ-ONLY VALUE 2 ##NO_TEXT.
    CLASS-DATA gv_tipo_anexo_outros TYPE ze_tipo_anexo READ-ONLY VALUE 3 ##NO_TEXT.
    CLASS-DATA gv_tipo_anexo_parecer TYPE ze_tipo_anexo READ-ONLY VALUE 4 ##NO_TEXT.

    METHODS constructor
      IMPORTING
        !iv_doc_uuid_h TYPE sysuuid_x16
        !iv_contrato   TYPE ze_num_contrato
        !iv_aditivo    TYPE ze_num_aditivo
      RAISING
        cx_cnv_00001_entry_not_found .
    METHODS anexar
      IMPORTING
        !iv_tipo_doc  TYPE ze_tipo_anexo
        !iv_filename  TYPE string
        !is_media     TYPE /iwbep/if_mgw_appl_srv_runtime=>ty_s_media_resource
      EXPORTING
        !ev_new_docid TYPE sysuuid_x16
        !et_return    TYPE bapiret2_t .
    METHODS recuperar_arquivo
      IMPORTING
        !iv_docid   TYPE sysuuid_x16
      EXPORTING
        !es_arquivo TYPE ty_arquivo .
    METHODS listar_arquivos .
  PROTECTED SECTION.
  PRIVATE SECTION.

    DATA gt_todos_arquivos TYPE tt_info_arquivos .

    METHODS salvar
      IMPORTING
        is_arquivo TYPE ty_arquivo
      EXPORTING
        et_return  TYPE bapiret2_t .
    METHODS status_anexo
      IMPORTING
        is_arquivo TYPE ztfi_cont_anexo.
ENDCLASS.



CLASS zclfi_anexo_contrato IMPLEMENTATION.


  METHOD anexar.

    DATA ls_anexo TYPE me->ty_arquivo.

* ---------------------------------------------------------------------------
* Checa o Tipo de Arquivo
* ---------------------------------------------------------------------------
    IF   iv_tipo_doc <> gv_tipo_anexo_contrato_ass   AND
         iv_tipo_doc <> gv_tipo_anexo_minuta         AND
         iv_tipo_doc <> gv_tipo_anexo_outros         AND
         iv_tipo_doc <> gv_tipo_anexo_parecer.

      "Tipo de Documento Incorreto. Realizar Nova Carga.".
      et_return[] = VALUE #( BASE et_return ( type = 'E' id = 'ZFI_CARGA_CONTRATO' number = '000' ) ).

      CHECK NOT line_exists( et_return[ type = 'E' ] ).  "#EC CI_STDSEQ

    ENDIF.
* ---------------------------------------------------------------------------
* Preenche tabelas interna
* ---------------------------------------------------------------------------

    "Geral
    ls_anexo-mandt      = sy-mandt.
    ls_anexo-doc_uuid_h = me->gv_doc_uuid_h.
    ls_anexo-contrato   = me->gv_contrato.
    ls_anexo-aditivo    = me->gv_aditivo.
    ls_anexo-filename = iv_filename.
    ls_anexo-mimetype = is_media-mime_type.
    ls_anexo-value = is_media-value.
    ls_anexo-created_by = sy-uname.
    ls_anexo-last_changed_by  = sy-uname.

    ""TimeStamp Gang.
    GET TIME STAMP FIELD DATA(lv_ts) .
    ls_anexo-created_at = lv_ts.
    ls_anexo-last_changed_at = lv_ts.
    ls_anexo-local_last_changed_at = lv_ts.

    "GUUID
    DATA(lo_guuid) = NEW cl_system_uuid( ).
    TRY.
        ls_anexo-doc_uuid_doc = lo_guuid->if_system_uuid~create_uuid_x16( ).
      CATCH cx_root.
    ENDTRY.

    "Tipo de Arquivo
    ls_anexo-tipo_doc     = iv_tipo_doc.

* ---------------------------------------------------------------------------
* Salva registros
* ---------------------------------------------------------------------------
    me->salvar(
            EXPORTING
            is_arquivo = ls_anexo
            IMPORTING
            et_return = et_return[] ).


    me->status_anexo(
           EXPORTING
               is_arquivo = ls_anexo ).



    ""Retorna o UUID do arquivo criado.
    ev_new_docid = ls_anexo-doc_uuid_doc.


  ENDMETHOD.


  METHOD constructor.

    me->gv_doc_uuid_h = iv_doc_uuid_h.
    me->gv_contrato = iv_contrato.
    me->gv_aditivo = iv_aditivo.

    SELECT doc_uuid_h,
           contrato,
           aditivo,
           doc_uuid_doc,
           tipo_doc,
           filename,
           mimetype
    FROM ztfi_cont_anexo
    INTO TABLE @me->gt_todos_arquivos
    WHERE doc_uuid_h = @iv_doc_uuid_h.
*       and
*          contrato   = @iv_contrato   AND
*          aditivo    = @iv_aditivo.

    IF sy-subrc IS NOT INITIAL.

      me->gv_novo = abap_true.

    ENDIF.


    SELECT SINGLE contrato,
           aditivo
      FROM ztfi_contrato
      INTO ( @gv_contrato , @gv_aditivo )
      WHERE doc_uuid_h = @iv_doc_uuid_h.


  ENDMETHOD.


  METHOD listar_arquivos.

    RETURN.


  ENDMETHOD.


  METHOD recuperar_arquivo.

    SELECT SINGLE *
      FROM ztfi_cont_anexo
      INTO @es_arquivo
      WHERE doc_uuid_h    = @me->gv_doc_uuid_h AND
            contrato      = @me->gv_contrato   AND
            aditivo       = @me->gv_aditivo    AND
            doc_uuid_doc  = @iv_docid.

  ENDMETHOD.


  METHOD salvar.

    MODIFY ztfi_cont_anexo FROM is_arquivo.

    IF sy-subrc NE 0.
      " Falha ao salvar dados de carga.
      et_return[] = VALUE #( BASE et_return ( type = 'E' id = 'ZFI_CARGA_CONTRATO' number = '001' ) ).
      RETURN.
    ENDIF.

  ENDMETHOD.


  METHOD status_anexo.

    DATA: lv_status_new TYPE char17.
    DATA: lv_status_anexo TYPE ztfi_contrato-status_anexo.

    SELECT SINGLE status_anexo
        FROM ztfi_contrato
        INTO ( lv_status_anexo )
        WHERE doc_uuid_h = is_arquivo-doc_uuid_h.

    IF sy-subrc = 0.

      CASE is_arquivo-tipo_doc.
        WHEN '1'.
          lv_status_new = TEXT-001.
        WHEN '2'.
          lv_status_new = TEXT-002.
        WHEN '3'.
          lv_status_new = TEXT-003.
        WHEN '4'.
          lv_status_new = TEXT-004.
      ENDCASE.

      GET TIME STAMP FIELD DATA(lv_ts).

      IF lv_status_anexo IS INITIAL.
        lv_status_anexo = lv_status_new.



        UPDATE ztfi_contrato SET status_anexo          = lv_status_anexo
                                last_changed_by        = sy-uname
                                local_last_changed_at  = lv_ts
                          WHERE doc_uuid_h             = is_arquivo-doc_uuid_h.

        COMMIT WORK.

      ELSEIF NOT lv_status_anexo CS lv_status_new.
        lv_status_anexo = lv_status_anexo && '-' && lv_status_new.

        UPDATE ztfi_contrato SET status_anexo          = lv_status_anexo
                                last_changed_by        = sy-uname
                                local_last_changed_at  = lv_ts
                          WHERE doc_uuid_h             = is_arquivo-doc_uuid_h.

        COMMIT WORK.

      ENDIF.

    ENDIF.

  ENDMETHOD.
ENDCLASS.
