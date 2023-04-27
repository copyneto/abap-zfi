CLASS zclfi_basecalculo DEFINITION
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
    CONSTANTS gc_msg TYPE c LENGTH 16 VALUE 'ZFI_BASE_CALCULO'.
    "! Numero das mensagens
    CONSTANTS gc_num1 TYPE bapiret2-number VALUE '001'.
    CONSTANTS gc_num2 TYPE bapiret2-number VALUE '002'.


*_____________________Tabela ZTFI_CALC_CRESCI ________________*

    "! Realiza carga de arquivo
    "! @parameter iv_filename | Nome do arquivo
    "! @parameter is_media | Arquivo enviado
    "! @parameter et_return | Mensagens de retorno
    METHODS upload_calccresci
      IMPORTING
        !iv_filename TYPE string
        !is_media    TYPE /iwbep/if_mgw_appl_srv_runtime=>ty_s_media_resource
      EXPORTING
        !et_return   TYPE bapiret2_t .

  PROTECTED SECTION.
  PRIVATE SECTION.

*_____________________Tabela ZTFI_CALC_CRESCI ________________*

    "! Processar arquivo e separar em tabelas
    "! @parameter it_file | Tabela do arquivo
    "! @parameter et_doc | Tabela de documentos
    "! @parameter et_return | Tabela de retorno
    METHODS upload_fill_data_calccresci
      IMPORTING
        !it_file   TYPE zctgfi_calc_cresci
      EXPORTING
        !et_doc    TYPE zctgfi_calccresci
        !et_return TYPE bapiret2_t .
    "! Salvar dados carregados na tabela
    "! @parameter it_doc | Tabela de documentos
    "! @parameter et_return | Tabela de mensagens
    METHODS upload_save_calccresci
      IMPORTING
        !it_doc    TYPE zctgfi_calccresci OPTIONAL
      EXPORTING
        !et_return TYPE bapiret2_t .


ENDCLASS.



CLASS zclfi_basecalculo IMPLEMENTATION.


  METHOD upload_calccresci.

    DATA: lt_file TYPE zctgfi_calc_cresci.
    DATA: lt_doc  TYPE TABLE OF ztfi_calc_cresci.
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
    me->upload_fill_data_calccresci( EXPORTING
                            it_file     = lt_file[]
                          IMPORTING
                            et_doc      = lt_doc[]
                            et_return   = lt_return[] ).

    et_return[] = VALUE #( BASE et_return FOR ls_return IN lt_return ( ls_return ) ).
    CHECK NOT line_exists( et_return[ type = gc_e ] ).

* ---------------------------------------------------------------------------
* Salva registros
* ---------------------------------------------------------------------------
    me->upload_save_calccresci(
            EXPORTING
            it_doc = lt_doc[]
            IMPORTING
            et_return = lt_return[] ).

    APPEND LINES OF lt_return TO et_return.

  ENDMETHOD.


  METHOD upload_fill_data_calccresci.

    DATA: lt_carga  TYPE zctgfi_calc_cresci.

    FREE et_doc.

    lt_carga[] = it_file[].

    LOOP AT lt_carga ASSIGNING FIELD-SYMBOL(<fs_carga>).

      APPEND INITIAL LINE TO et_doc ASSIGNING FIELD-SYMBOL(<fs_doc>).

      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
        EXPORTING
          input  = <fs_carga>-contrato
        IMPORTING
          output = <fs_doc>-contrato.

      <fs_doc>-aditivo          =  <fs_carga>-aditivo.
      <fs_doc>-bukrs            =  <fs_carga>-bukrs.
      <fs_doc>-belnr            =  <fs_carga>-belnr.
      <fs_doc>-gjahr            =  <fs_carga>-gjahr.

      <fs_doc>-buzei            =  <fs_carga>-buzei.
      <fs_doc>-ajuste_anual     =  <fs_carga>-ajuste_anual.
      <fs_doc>-gsber            =  <fs_carga>-gsber.
      <fs_doc>-familia_cl       =  <fs_carga>-familia_cl.
      <fs_doc>-chave_manual     =  <fs_carga>-chave_manual.
      <fs_doc>-wrbtr            =  <fs_carga>-wrbtr.
      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
        EXPORTING
          input  = <fs_carga>-bschl
        IMPORTING
          output = <fs_doc>-bschl.

      <fs_doc>-blart            =  <fs_carga>-blart.
      <fs_doc>-zuonr            =  <fs_carga>-zuonr.
      <fs_doc>-kunnr            =  <fs_carga>-kunnr.
      <fs_doc>-zlsch            =  <fs_carga>-zlsch.
      <fs_doc>-sgtxt            =  <fs_carga>-sgtxt.
      <fs_doc>-netdt            =  <fs_carga>-netdt.
      <fs_doc>-xblnr            =  <fs_carga>-xblnr.
      <fs_doc>-budat            =  <fs_carga>-budat.
      <fs_doc>-bldat            =  <fs_carga>-bldat.
      <fs_doc>-augbl            =  <fs_carga>-augbl.
      <fs_doc>-augdt            =  <fs_carga>-augdt.
      <fs_doc>-vbeln            =  <fs_carga>-vbeln.
      <fs_doc>-posnr            =  <fs_carga>-posnr.
      <fs_doc>-vgbel            =  <fs_carga>-vgbel.
      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
        EXPORTING
          input  = <fs_carga>-vtweg
        IMPORTING
          output = <fs_doc>-vtweg.

      <fs_doc>-spart            =  <fs_carga>-spart.
      <fs_doc>-bzirk            =  <fs_carga>-bzirk.
      <fs_doc>-katr2            =  <fs_carga>-katr2.
      <fs_doc>-wwmt1            =  <fs_carga>-wwmt1.
      <fs_doc>-prctr            =  <fs_carga>-prctr.
      <fs_doc>-tipo_entrega     =  <fs_carga>-tipo_entrega.
      <fs_doc>-xref1_hd         =  <fs_carga>-xref1_hd.
      <fs_doc>-status_dde       =  <fs_carga>-status_dde.
      <fs_doc>-tipo_apuracao    =  <fs_carga>-tipo_apuracao.
      <fs_doc>-tipo_ap_imposto  =  <fs_carga>-tipo_ap_imposto.
      <fs_doc>-tipo_imposto     =  <fs_carga>-tipo_imposto.
      <fs_doc>-impost_desconsid =  <fs_carga>-impost_desconsid.
      <fs_doc>-mont_liq_tax     =  <fs_carga>-mont_liq_tax.
      <fs_doc>-mont_valido      =  <fs_carga>-mont_valido.
      <fs_doc>-tipo_desconto    =  <fs_carga>-tipo_desconto.

      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
        EXPORTING
          input  = <fs_carga>-cond_desconto
        IMPORTING
          output = <fs_doc>-cond_desconto.

      <fs_doc>-kostl            =  <fs_carga>-kostl.
      <fs_doc>-mont_bonus       =  <fs_carga>-mont_bonus.
      <fs_doc>-bonus_calculado  =  <fs_carga>-bonus_calculado.
      <fs_doc>-obs_ajuste       =  <fs_carga>-obs_ajuste.

    ENDLOOP.

  ENDMETHOD.


  METHOD upload_save_calccresci.

    IF it_doc[] IS NOT INITIAL.

      MODIFY ztfi_calc_cresci FROM TABLE it_doc.

      IF sy-subrc NE 0.
        " Falha ao salvar dados de carga.
        et_return[] = VALUE #( BASE et_return ( type = gc_e id = gc_msg number = gc_num2 ) ).
        RETURN.
      ELSE.

        " Dados Gravados com Sucesso!
        et_return[] = VALUE #( BASE et_return ( type = gc_s id = gc_msg number = 006 )
                                              ( type = gc_s id = gc_msg number = 039 )  ).
      ENDIF.
    ENDIF.

  ENDMETHOD.
ENDCLASS.
