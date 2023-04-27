CLASS zclfi_carga_pendencias DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    METHODS upload
      IMPORTING
        !iv_filename TYPE string
        !is_media    TYPE /iwbep/if_mgw_appl_srv_runtime=>ty_s_media_resource
      EXPORTING
        !et_return   TYPE bapiret2_t .
  PROTECTED SECTION.
  PRIVATE SECTION.

    METHODS upload_fill_data
      IMPORTING
        !it_file   TYPE zctgfi_carga_pend
      EXPORTING
        !et_doc    TYPE zctgfi_cont_cont
        !et_return TYPE bapiret2_t .
    METHODS upload_save
      IMPORTING
        !it_doc    TYPE zctgfi_cont_cont OPTIONAL
      EXPORTING
        !et_return TYPE bapiret2_t .
ENDCLASS.



CLASS ZCLFI_CARGA_PENDENCIAS IMPLEMENTATION.


  METHOD upload.

    DATA: lt_file TYPE zctgfi_carga_pend.
    DATA: lt_doc  TYPE TABLE OF ztfi_cont_cont.
    DATA: lv_mimetype TYPE w3conttype.

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
      et_return[] = VALUE #( BASE et_return ( type = 'E' id = 'ZFI_CARGA_PEND' number = '001' ) ).
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
                            et_doc      = lt_doc[]
                            et_return   = lt_return[] ).

    et_return[] = VALUE #( BASE et_return FOR ls_return IN lt_return ( ls_return ) ).
    CHECK NOT line_exists( et_return[ type = 'E' ] ).    "#EC CI_STDSEQ



* ---------------------------------------------------------------------------
* Salva registros
* ---------------------------------------------------------------------------
    me->upload_save(
            EXPORTING
            it_doc = lt_doc[]
            IMPORTING
            et_return = lt_return[] ).

    et_return[] = lt_return[].

  ENDMETHOD.


  METHOD upload_fill_data.

    DATA: lt_carga    TYPE zctgfi_carga_pend.
    DATA: lv_contrato TYPE char10,
          lv_aditivo  TYPE char14,
          lv_index    TYPE sy-tabix.

    FREE et_doc.

    lt_carga[] = it_file[].

**    SELECT contrato,
**           aditivo
**      FROM ztfi_contrato
**      INTO TABLE @DATA(lt_contrato)
**      FOR ALL ENTRIES IN @lt_carga
**      WHERE contrato = @lt_carga-contrato
**        AND aditivo = @lt_carga-aditivo.
**    IF sy-subrc IS INITIAL.
**      SORT lt_contrato BY contrato aditivo .
**    ENDIF.

    SELECT bukrs, kunnr, belnr, gjahr, numero_item
    FROM ztfi_cont_cont
    INTO TABLE @DATA(lt_cont_cont)
    FOR ALL ENTRIES IN @lt_carga
    WHERE bukrs = @lt_carga-bukrs
    AND kunnr = @lt_carga-kunnr
    AND belnr = @lt_carga-belnr
    AND gjahr = @lt_carga-gjahr
    AND numero_item = @lt_carga-numero_item.
    IF sy-subrc IS INITIAL.
      SORT lt_cont_cont BY bukrs kunnr belnr gjahr numero_item .
    ENDIF.

    SELECT bukrs,
           belnr,
           gjahr
      FROM finsv_sif_bkpf
      INTO TABLE @DATA(lt_doc_princ)
      FOR ALL ENTRIES IN @lt_carga
      WHERE bukrs = @lt_carga-bukrs
        AND belnr = @lt_carga-belnr
        AND gjahr = @lt_carga-gjahr.
    IF sy-subrc IS INITIAL.
      SORT lt_doc_princ BY bukrs belnr gjahr.
    ENDIF.

    SELECT bukrs,
           belnr,
           gjahr
      FROM finsv_sif_bkpf
      INTO TABLE @DATA(lt_doc_prov)
      FOR ALL ENTRIES IN @lt_carga
      WHERE bukrs = @lt_carga-bukrs
        AND belnr = @lt_carga-doc_provisao
        AND gjahr = @lt_carga-exerc_provisao.
    IF sy-subrc IS INITIAL.
      SORT lt_doc_prov BY bukrs belnr gjahr.
    ENDIF.

    SELECT bukrs,
       belnr,
       gjahr
      FROM finsv_sif_bkpf
      INTO TABLE @DATA(lt_doc_liquid)
      FOR ALL ENTRIES IN @lt_carga
      WHERE bukrs = @lt_carga-bukrs
        AND belnr = @lt_carga-doc_liquidacao
        AND gjahr = @lt_carga-exerc_liquidacao.
    IF sy-subrc IS INITIAL.
      SORT lt_doc_liquid BY bukrs belnr gjahr.
    ENDIF.

    SELECT bukrs,
       belnr,
       gjahr
      FROM finsv_sif_bkpf
      INTO TABLE @DATA(lt_doc_est)
      FOR ALL ENTRIES IN @lt_carga
      WHERE bukrs = @lt_carga-bukrs
        AND belnr = @lt_carga-doc_estorno
        AND gjahr = @lt_carga-exerc_estorno.
    IF sy-subrc IS INITIAL.
      SORT lt_doc_liquid BY bukrs belnr gjahr.
    ENDIF.

    LOOP AT lt_carga ASSIGNING FIELD-SYMBOL(<fs_carga>).

      lv_index = sy-tabix.


      "@@ Documento já carregado
      READ TABLE lt_cont_cont WITH KEY bukrs = <fs_carga>-bukrs
                                      kunnr = <fs_carga>-kunnr
                                      belnr = <fs_carga>-belnr
                                      gjahr = <fs_carga>-gjahr
                                      numero_item = <fs_carga>-numero_item
                                       BINARY SEARCH
                                       TRANSPORTING NO FIELDS.
      IF sy-subrc = 0.

        "Documento &1 &2 &3 já carregado.
        et_return[] = VALUE #( BASE et_return ( type = 'E'
                                                id = 'ZFI_CARGA_PEND'
                                                number = '007'
                                                message_v1 = <fs_carga>-belnr
                                                message_v2 = <fs_carga>-gjahr
                                                message_v3 = <fs_carga>-bukrs  ) ).
        CONTINUE.
      ENDIF.

**      "@@ Contrato Aditivo
**      READ TABLE lt_contrato WITH KEY contrato = <fs_carga>-contrato
**                                      aditivo = <fs_carga>-aditivo BINARY SEARCH
**                                       TRANSPORTING NO FIELDS.
**      IF sy-subrc <> 0.
**
**        "Erro na linha: &1 Contrato &1 Aditivo &2
**        et_return[] = VALUE #( BASE et_return ( type = 'E'
**                                                id = 'ZFI_CARGA_PEND'
**                                                number = '006'
**                                                message_v1 = lv_index
**                                                message_v2 = <fs_carga>-contrato
**                                                message_v3 = <fs_carga>-aditivo  ) ).
**        CONTINUE.
**      ENDIF.



      "@@ Doc de lançamento
      READ TABLE lt_doc_princ WITH KEY bukrs = <fs_carga>-bukrs
                                       belnr = <fs_carga>-belnr
                                       gjahr = <fs_carga>-gjahr BINARY SEARCH
                                       TRANSPORTING NO FIELDS.
      IF sy-subrc <> 0.
        "Erro na linha: &1 Documento não encontrado: &2
        et_return[] = VALUE #( BASE et_return ( type = 'E'
                                                id = 'ZFI_CARGA_PEND'
                                                number = '005'
                                                message_v1 = lv_index
                                                message_v2 = <fs_carga>-belnr  ) ).
        CONTINUE.
      ENDIF.

      "@@ Doc de provisão
      IF <fs_carga>-doc_provisao IS NOT INITIAL.
        READ TABLE lt_doc_prov WITH KEY bukrs = <fs_carga>-bukrs
                                        belnr = <fs_carga>-doc_provisao
                                        gjahr = <fs_carga>-exerc_provisao BINARY SEARCH
                                        TRANSPORTING NO FIELDS.
        IF sy-subrc <> 0.
          "Erro na linha: &1 Documento não encontrado: &2
          et_return[] = VALUE #( BASE et_return ( type = 'E'
                                                  id = 'ZFI_CARGA_PEND'
                                                  number = '005'
                                                  message_v1 = lv_index
                                                  message_v2 = <fs_carga>-doc_provisao  ) ).
          CONTINUE.
        ENDIF.
      ENDIF.

      "@@ Doc de liquidação
      IF <fs_carga>-doc_liquidacao IS NOT INITIAL.
        READ TABLE lt_doc_liquid WITH KEY bukrs = <fs_carga>-bukrs
                                        belnr = <fs_carga>-doc_liquidacao
                                        gjahr = <fs_carga>-exerc_liquidacao BINARY SEARCH
                                        TRANSPORTING NO FIELDS.
        IF sy-subrc <> 0.
          "Erro na linha: &1 Documento não encontrado: &2
          et_return[] = VALUE #( BASE et_return ( type = 'E'
                                                  id = 'ZFI_CARGA_PEND'
                                                  number = '005'
                                                  message_v1 = lv_index
                                                  message_v2 = <fs_carga>-doc_liquidacao  ) ).
          CONTINUE.
        ENDIF.
      ENDIF.

      "@@ Doc de Estorno
      IF <fs_carga>-doc_estorno IS NOT INITIAL.
        READ TABLE lt_doc_est WITH KEY bukrs = <fs_carga>-bukrs
                                        belnr = <fs_carga>-doc_estorno
                                        gjahr = <fs_carga>-exerc_estorno BINARY SEARCH
                                        TRANSPORTING NO FIELDS.
        IF sy-subrc <> 0.
          "Erro na linha: &1 Documento não encontrado: &2
          et_return[] = VALUE #( BASE et_return ( type = 'E'
                                                  id = 'ZFI_CARGA_PEND'
                                                  number = '005'
                                                  message_v1 = lv_index
                                                  message_v2 = <fs_carga>-doc_estorno  ) ).
          CONTINUE.
        ENDIF.
      ENDIF.



      APPEND INITIAL LINE TO et_doc ASSIGNING FIELD-SYMBOL(<fs_doc>).

      TRY.
          <fs_doc>-doc_cont_id           =   NEW cl_system_uuid( )->if_system_uuid~create_uuid_x16( )..
        CATCH cx_uuid_error.
          "handle exception
      ENDTRY..

**      <fs_doc>-contrato              =  <fs_carga>-contrato.
**      <fs_doc>-aditivo               =  <fs_carga>-aditivo.

      <fs_doc>-bukrs                 =  <fs_carga>-bukrs.
      <fs_doc>-kunnr                 =  <fs_carga>-kunnr.
      <fs_doc>-belnr                 =  <fs_carga>-belnr.
      <fs_doc>-gjahr                 =  <fs_carga>-gjahr.
      <fs_doc>-numero_item           =  <fs_carga>-numero_item.
      <fs_doc>-budat                 =  <fs_carga>-budat.
      <fs_doc>-wrbtr                 =  <fs_carga>-wrbtr.
      <fs_doc>-waers                 =  <fs_carga>-waers.
      <fs_doc>-bzirk                 =  <fs_carga>-bzirk.
      <fs_doc>-canal                 =   <fs_carga>-canal.
      <fs_doc>-setor                 =  <fs_carga>-setor.
      <fs_doc>-vkorg                 =  <fs_carga>-vkorg.
      <fs_doc>-tipo_desc             =  'M'.
      <fs_doc>-doc_provisao          =  <fs_carga>-doc_provisao.
      <fs_doc>-exerc_provisao        =  <fs_carga>-exerc_provisao.
      <fs_doc>-mont_provisao         =  <fs_carga>-mont_provisao.
      <fs_doc>-doc_liquidacao        =  <fs_carga>-doc_liquidacao.
      <fs_doc>-exerc_liquidacao      =  <fs_carga>-exerc_liquidacao.
      <fs_doc>-mont_liquidacao       =  <fs_carga>-mont_liquidacao.
      <fs_doc>-doc_estorno           =  <fs_carga>-doc_estorno.
      <fs_doc>-exerc_estorno         =  <fs_carga>-exerc_estorno.
      <fs_doc>-mont_estorno          =  <fs_carga>-mont_estorno.
      <fs_doc>-status_provisao       =  '5'.
      <fs_doc>-tipo_dado             =  'C'.
      <fs_doc>-created_by            = sy-uname.
      GET TIME STAMP FIELD <fs_doc>-created_at.
      <fs_doc>-local_last_changed_at = <fs_doc>-created_at.

    ENDLOOP.


  ENDMETHOD.


  METHOD upload_save.

    IF it_doc[] IS NOT INITIAL.

      MODIFY ztfi_cont_cont FROM TABLE it_doc.

      IF sy-subrc NE 0.
        " Falha ao salvar dados de carga.
        et_return[] = VALUE #( BASE et_return ( type = 'E' id = 'ZFI_CARGA_PEND' number = '002' ) ).
        RETURN.
      ELSE.
        "Carga realizada com sucesso
        et_return[] = VALUE #( BASE et_return ( type = 'S' id = 'ZFI_CARGA_PEND' number = '003' ) ).

        "Processamento finalizado com sucesso
        et_return[] = VALUE #( BASE et_return ( type = 'S' id = 'ZFI_CARGA_PEND' number = '004' ) ).
        RETURN.
      ENDIF.
    ENDIF.


  ENDMETHOD.
ENDCLASS.
