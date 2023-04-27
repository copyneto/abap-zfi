CLASS zclfi_contabilizacao_dpc_ext DEFINITION
  PUBLIC
  INHERITING FROM zclfi_contabilizacao_dpc
  CREATE PUBLIC .

  PUBLIC SECTION.
  PROTECTED SECTION.

    METHODS contabilizacaose_get_entityset
        REDEFINITION .
    METHODS eliminarset_get_entityset
        REDEFINITION .
    METHODS simularset_get_entityset
        REDEFINITION .
  PRIVATE SECTION.
ENDCLASS.



CLASS zclfi_contabilizacao_dpc_ext IMPLEMENTATION.


  METHOD contabilizacaose_get_entityset.
    DATA: lt_header_aux TYPE TABLE OF zi_fi_contab_cab  WITH DEFAULT KEY,
          lt_item_aux   TYPE TABLE OF zi_fi_contab_item WITH DEFAULT KEY.

    "Cria instancia
    DATA(lo_message) = mo_context->get_message_container( ).

    SELECT COUNT( * )
    FROM zi_fi_contab_cab
    WHERE StatusCode = 'E'.

    IF sy-dbcnt = 0.

      SELECT *
      FROM zi_fi_contab_cab
      WHERE StatusCode = 'S'
      INTO TABLE @DATA(lt_header).

*      SELECT COUNT( * )
*      FROM ztfi_log_contab
*      FOR ALL ENTRIES IN @lt_header
*      WHERE status_log    = 'E'
*      AND   identificacao = @lt_header-identificacao
*      AND   id            = @lt_header-id.

      SELECT COUNT( * )
      FROM ztfi_log_contab AS log
      INNER JOIN zi_fi_contab_cab AS cab ON cab~identificacao = log~identificacao
                                        AND cab~id            = log~id
      WHERE log~status_log    = 'E'
      AND   cab~StatusCode    = 'S'.

      IF sy-dbcnt = 0.

        IF lt_header[] IS NOT INITIAL.
          SELECT *
          FROM zi_fi_contab_item
          FOR ALL ENTRIES IN @lt_header
          WHERE id          = @lt_header-Id
          AND identificacao = @lt_header-Identificacao
          INTO TABLE @DATA(lt_item).               "#EC CI_NO_TRANSFORM

          IF lt_item[] IS NOT INITIAL.

            MOVE-CORRESPONDING lt_header TO lt_header_aux.
            MOVE-CORRESPONDING lt_item   TO lt_item_aux.

            DATA(lo_contab) = NEW zclfi_exec_contabilizacao( it_header = lt_header_aux
                                                             it_item   = lt_item_aux ).

            lo_contab->update_status_to_process( iv_simular = abap_false ).

            EXPORT  lt_header_aux = lt_header_aux
                    lt_item_aux   = lt_item_aux  TO DATABASE indx(zw) ID gc_value-memory.

            CALL FUNCTION 'ZFMFI_CONTABILIZACAO_MASSA'
              STARTING NEW TASK 'BACKGROUND_MASS'.

          ENDIF.


        ENDIF.
      ELSE.
* ----------------------------------------------------------------------
* Ativa exceção em casos de erro
* ----------------------------------------------------------------------
        RAISE EXCEPTION TYPE /iwbep/cx_mgw_tech_exception
          EXPORTING
            message_container = lo_contab->add_message_to_container( io_context = mo_context ).
      ENDIF.
* ----------------------------------------------------------------------
* Retorna mensagem de sucesso
* ----------------------------------------------------------------------
      MESSAGE s002(zfi_contab_fp) INTO DATA(lv_msg).

      lo_message->add_message_text_only(
        EXPORTING
          iv_msg_type               = CONV #( if_abap_behv_message=>severity-success )
          iv_msg_text               = CONV bapi_msg( lv_msg )
          iv_add_to_response_header = abap_true ).
    ELSE.
* ----------------------------------------------------------------------
* Ativa exceção em casos de erro
* ----------------------------------------------------------------------
      RAISE EXCEPTION TYPE /iwbep/cx_mgw_tech_exception
        EXPORTING
          message_container = lo_contab->add_message_to_container( io_context = mo_context ).
    ENDIF.
  ENDMETHOD.


  METHOD eliminarset_get_entityset.
    DATA: lt_header TYPE TABLE OF zi_fi_contab_cab  WITH DEFAULT KEY.

    "Preenche os ranges com os filtros da tela
    TRY .
        DATA(lr_identificacao) = it_filter_select_options[ property = gc_filtros-Identificacao ]-select_options. "#EC CI_STDSEQ
      CATCH cx_root.
    ENDTRY.

    TRY .
        DATA(lr_Id) = it_filter_select_options[ property = gc_filtros-Id ]-select_options. "#EC CI_STDSEQ

      CATCH cx_root.
    ENDTRY.

    TRY .
        DATA(lr_StatusCode) = it_filter_select_options[ property = gc_filtros-StatusCode ]-select_options. "#EC CI_STDSEQ
      CATCH cx_root.
    ENDTRY.

    TRY .
        DATA(lr_Empresa) = it_filter_select_options[ property = gc_filtros-Empresa ]-select_options. "#EC CI_STDSEQ
      CATCH cx_root.
    ENDTRY.

    TRY .
        DATA(lr_DataDocumento) =  it_filter_select_options[ property = gc_filtros-DataDocumento ]-select_options. "#EC CI_STDSEQ
      CATCH cx_root.
    ENDTRY.

    TRY .
        DATA(lr_DataLancamento) = it_filter_select_options[ property = gc_filtros-DataLancamento ]-select_options. "#EC CI_STDSEQ
      CATCH cx_root.
    ENDTRY.

    TRY .
        DATA(lr_TipoDocumento) = it_filter_select_options[ property = gc_filtros-TipoDocumento ]-select_options. "#EC CI_STDSEQ
      CATCH cx_root.
    ENDTRY.

    TRY .
        DATA(lr_Referencia) = it_filter_select_options[ property = gc_filtros-Referencia ]-select_options. "#EC CI_STDSEQ
      CATCH cx_root.
    ENDTRY.

    TRY .
        DATA(lr_TextCab) = it_filter_select_options[ property = gc_filtros-TextCab ]-select_options. "#EC CI_STDSEQ
      CATCH cx_root.
    ENDTRY.

    TRY .
        DATA(lr_TextStatus) = it_filter_select_options[ property = gc_filtros-TextStatus ]-select_options. "#EC CI_STDSEQ
      CATCH cx_root.
    ENDTRY.

    SELECT Id, Identificacao, StatusText, StatusCode, StatusCriticality,
           Empresa, DataDocumento, DataLancamento, TipoDocumento, Referencia,
           TextCab, TextStatus
    FROM zi_fi_contab_cab
    WHERE Identificacao  IN @lr_Identificacao
      AND Id             IN @lr_Id
      AND StatusCode     IN @lr_StatusCode
      AND Empresa        IN @lr_Empresa
      AND DataDocumento  IN @lr_DataDocumento
      AND DataLancamento IN @lr_DataLancamento
      AND TipoDocumento  IN @lr_TipoDocumento
      AND Referencia     IN @lr_Referencia
      AND TextCab        IN @lr_TextCab
      AND TextStatus     IN @lr_TextStatus
     INTO TABLE @lt_header.

    "Cria instancia
    DATA(lo_message) = mo_context->get_message_container( ).
    DATA(lo_contab) = NEW zclfi_exec_contabilizacao( it_header = lt_header ).

*      DELETE FROM ztfi_log_contab WHERE status_log IS NOT INITIAL.

    LOOP AT lt_header ASSIGNING FIELD-SYMBOL(<fs_header>).

      lo_contab->save_log( is_header = <fs_header>
                           iv_delete = abap_true ).

      lo_contab->delete_contab_data( <fs_header> ).

    ENDLOOP.

* ----------------------------------------------------------------------
* Retorna mensagem de sucesso
* ----------------------------------------------------------------------
    MESSAGE s002(zfi_contab_fp) INTO DATA(lv_msg).

    lo_message->add_message_text_only(
      EXPORTING
        iv_msg_type               = CONV #( if_abap_behv_message=>severity-success )
        iv_msg_text               = CONV bapi_msg( lv_msg )
        iv_add_to_response_header = abap_true ).
  ENDMETHOD.


  METHOD simularset_get_entityset.
    DATA: lt_header_aux TYPE TABLE OF zi_fi_contab_cab  WITH DEFAULT KEY,
          lt_item_aux   TYPE TABLE OF zi_fi_contab_item WITH DEFAULT KEY.

    "Cria instancia
    DATA(lo_message) = mo_context->get_message_container( ).

    SELECT COUNT( * )
    FROM zi_fi_contab_cab
    WHERE StatusCode = 'E'.

    IF sy-dbcnt = 0.

      SELECT *
      FROM zi_fi_contab_cab
      WHERE StatusCode = 'S'
*      AND   identificacao = '220925'
*      AND   identificacao = '220926'
      INTO TABLE @DATA(lt_header).

      IF lt_header[] IS NOT INITIAL.
        SELECT *
        FROM zi_fi_contab_item
        FOR ALL ENTRIES IN @lt_header
        WHERE id          = @lt_header-Id
        AND identificacao = @lt_header-Identificacao
        INTO TABLE @DATA(lt_item).                 "#EC CI_NO_TRANSFORM

        IF lt_item[] IS NOT INITIAL.

          MOVE-CORRESPONDING lt_header TO lt_header_aux.
          MOVE-CORRESPONDING lt_item   TO lt_item_aux.

          DATA(lo_contab) = NEW zclfi_exec_contabilizacao( it_header = lt_header_aux
                                                           it_item   = lt_item_aux ).

          lo_contab->update_status_to_process( iv_simular = abap_true ).

          DELETE FROM DATABASE indx(zw) ID gc_value-memory.

          EXPORT  lt_header_aux = lt_header_aux
                  lt_item_aux   = lt_item_aux  TO DATABASE indx(zw) ID gc_value-memory.

          CALL FUNCTION 'ZFMFI_CONTABILIZACAO_MASSA'
            STARTING NEW TASK 'BACKGROUND_MASS'
            EXPORTING
              iv_simular = abap_true.
        ENDIF.
      ENDIF.
* ----------------------------------------------------------------------
* Retorna mensagem de sucesso
* ----------------------------------------------------------------------
      MESSAGE s002(zfi_contab_fp) INTO DATA(lv_msg).

      lo_message->add_message_text_only(
        EXPORTING
          iv_msg_type               = CONV #( if_abap_behv_message=>severity-success )
          iv_msg_text               = CONV bapi_msg( lv_msg )
          iv_add_to_response_header = abap_true ).
    ELSE.
* ----------------------------------------------------------------------
* Ativa exceção em casos de erro
* ----------------------------------------------------------------------
      RAISE EXCEPTION TYPE /iwbep/cx_mgw_tech_exception
        EXPORTING
          message_container = lo_contab->add_message_to_container( io_context = mo_context ).
    ENDIF.
  ENDMETHOD.
ENDCLASS.
