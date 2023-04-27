CLASS lcl_Header DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS read FOR READ
      IMPORTING keys FOR READ Header RESULT result.

    METHODS rba_MercExtItem FOR READ
      IMPORTING keys_rba FOR READ Header\_MercExtItem FULL result_requested RESULT result LINK association_links.

    METHODS contabilizar FOR MODIFY
      IMPORTING keys FOR ACTION Header~contabilizar.

    METHODS simular FOR MODIFY
      IMPORTING keys FOR ACTION Header~simular.

ENDCLASS.

CLASS lcl_Header IMPLEMENTATION.

  METHOD read.
* ---------------------------------------------------------------------------
* Recupera os dados do Header
* ---------------------------------------------------------------------------
    IF keys[] IS NOT INITIAL.

      SELECT *
        FROM zi_fi_merc_ext_h
        FOR ALL ENTRIES IN @keys
        WHERE Empresa = @keys-Empresa
          AND NumDoc  = @keys-NumDoc
          AND Ano     = @keys-Ano
        INTO CORRESPONDING FIELDS OF TABLE @result.     "#EC CI_SEL_DEL

      IF sy-subrc NE 0.
        FREE result.
      ENDIF.
    ENDIF.
  ENDMETHOD.

  METHOD rba_MercExtItem.
    RETURN.
  ENDMETHOD.

  METHOD contabilizar.

    DATA: lt_header_aux TYPE TABLE OF zsfi_mercado_header WITH EMPTY KEY,
          lt_item_aux   TYPE TABLE OF zsfi_mercado_item.

    DATA ls_reported TYPE zi_fi_merc_ext_h .


    TRY .
        DATA(ls_param) = keys[ 1 ]-%param.
      CATCH cx_sy_itab_line_not_found.
    ENDTRY.

    IF ls_param-datalanc IS INITIAL.

      reported-header = VALUE #(  ( %tky = ls_param-datalanc
                                    %msg = new_message_with_text(
                                                                    severity = if_abap_behv_message=>severity-information
                                                                    text     = TEXT-001
                                          ) ) ).
      RETURN.
    ENDIF.

    IF ls_param-dataestorno IS INITIAL.

      reported-header = VALUE #(  ( %tky = ls_param-dataestorno
                                    %msg = new_message_with_text(
                                                                    severity = if_abap_behv_message=>severity-information
                                                                    text     = TEXT-002
                                          ) ) ).
      RETURN.
    ENDIF.

    READ ENTITIES OF zi_fi_merc_ext_h IN LOCAL MODE
        ENTITY Header
        ALL FIELDS WITH CORRESPONDING #( keys )
        RESULT DATA(lt_header).

    IF lt_header IS NOT INITIAL.

      READ ENTITIES OF zi_fi_merc_ext_h IN LOCAL MODE
          ENTITY Item
          ALL FIELDS WITH CORRESPONDING #( keys )
          RESULT DATA(lt_item).

      MOVE-CORRESPONDING lt_header TO lt_header_aux.
      MOVE-CORRESPONDING lt_item   TO lt_item_aux.

      DATA(lo_contab) = zclfi_contabilizacao=>get_instance(  ).

      lo_contab->set_ref_data( iv_app       = abap_true
                               it_header    = lt_header_aux
                               it_item      = lt_item_aux
                               iv_dtlanc    = ls_param-datalanc
                               iv_dtestorno = ls_param-dataestorno ).

      DATA(lt_menagens) = lo_contab->build(   ).

      reported-header = VALUE #( FOR ls_mensagem IN lt_menagens
                                 ( %tky = keys[ sy-index ]-%tky

                                   %msg = new_message(
                                                       id       = ls_mensagem-id
                                                       number   = ls_mensagem-number
                                                       severity = CONV #( ls_mensagem-type )
                                                       v1       = ls_mensagem-message_v1
                                                       v2       = ls_mensagem-message_v2
                                                       v3       = ls_mensagem-message_v3
                                                       v4       = ls_mensagem-message_v4  ) ) ).
    ENDIF.


  ENDMETHOD.

  METHOD simular.

    DATA: lt_header_aux TYPE TABLE OF zsfi_mercado_header WITH EMPTY KEY,
          lt_item_aux   TYPE TABLE OF zsfi_mercado_item.

    DATA ls_reported TYPE zi_fi_merc_ext_h .


    TRY .
        DATA(ls_param) = keys[ 1 ]-%param.
      CATCH cx_sy_itab_line_not_found.
    ENDTRY.

    IF ls_param-datalanc IS INITIAL.

      reported-header = VALUE #(  ( %tky = ls_param-datalanc
                                    %msg = new_message_with_text(
                                                                    severity = if_abap_behv_message=>severity-information
                                                                    text     = TEXT-001
                                          ) ) ).
      RETURN.
    ENDIF.

    READ ENTITIES OF zi_fi_merc_ext_h IN LOCAL MODE
        ENTITY Header
        ALL FIELDS WITH CORRESPONDING #( keys )
        RESULT DATA(lt_header).

    IF lt_header IS NOT INITIAL.

      READ ENTITIES OF zi_fi_merc_ext_h IN LOCAL MODE
          ENTITY Item
          ALL FIELDS WITH CORRESPONDING #( keys )
          RESULT DATA(lt_item).

      MOVE-CORRESPONDING lt_header TO lt_header_aux.
      MOVE-CORRESPONDING lt_item   TO lt_item_aux.

      DATA(lo_contab) = zclfi_contabilizacao=>get_instance(  ).

      lo_contab->set_ref_data( iv_app       = abap_true
                               it_header    = lt_header_aux
                               it_item      = lt_item_aux
                               iv_dtlanc    = ls_param-datalanc ).

      DATA(lt_menagens) = lo_contab->build( iv_simular  = abap_true ).

      reported-header = VALUE #( FOR ls_mensagem IN lt_menagens
                                 ( %tky = keys[ sy-index ]-%tky

                                   %msg = new_message(
                                                       id       = ls_mensagem-id
                                                       number   = ls_mensagem-number
                                                       severity = CONV #( ls_mensagem-type )
                                                       v1       = ls_mensagem-message_v1
                                                       v2       = ls_mensagem-message_v2
                                                       v3       = ls_mensagem-message_v3
                                                       v4       = ls_mensagem-message_v4  ) ) ).
    ENDIF.


  ENDMETHOD.

ENDCLASS.

CLASS lcl_Item DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS read FOR READ
      IMPORTING keys FOR READ Item RESULT result.

    METHODS rba_MercExtHeader FOR READ
      IMPORTING keys_rba FOR READ Item\_MercExtHeader FULL result_requested RESULT result LINK association_links.

ENDCLASS.

CLASS lcl_Item IMPLEMENTATION.

  METHOD read.
* ---------------------------------------------------------------------------
* Recupera os dados do Item
* ---------------------------------------------------------------------------
    IF keys[] IS NOT INITIAL.

      SELECT *
        FROM zi_fi_merc_ext_i
        FOR ALL ENTRIES IN @keys
        WHERE Empresa = @keys-Empresa
          AND NumDoc  = @keys-NumDoc
          AND Ano     = @keys-Ano
        INTO CORRESPONDING FIELDS OF TABLE @result.     "#EC CI_SEL_DEL

      IF sy-subrc NE 0.
        FREE result.
      ENDIF.
    ENDIF.
  ENDMETHOD.

  METHOD rba_MercExtHeader.
    RETURN.
  ENDMETHOD.

ENDCLASS.

CLASS lcl_ZI_FI_MERC_EXT_H DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.

    METHODS check_before_save REDEFINITION.

    METHODS finalize          REDEFINITION.

    METHODS save              REDEFINITION.

ENDCLASS.

CLASS lcl_ZI_FI_MERC_EXT_H IMPLEMENTATION.

  METHOD check_before_save.
    RETURN.
  ENDMETHOD.

  METHOD finalize.
    RETURN.
  ENDMETHOD.

  METHOD save.
    RETURN.
  ENDMETHOD.

ENDCLASS.
