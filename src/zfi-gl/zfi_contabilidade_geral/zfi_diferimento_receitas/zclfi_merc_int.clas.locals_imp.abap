CLASS lcl_header DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS read FOR READ
      IMPORTING keys FOR READ header RESULT result.

    METHODS rba_mercintitem FOR READ
      IMPORTING keys_rba FOR READ header\_mercintitem FULL result_requested RESULT result LINK association_links.

    METHODS contabilizar FOR MODIFY
      IMPORTING keys FOR ACTION header~contabilizar.

    METHODS simular FOR MODIFY
      IMPORTING keys FOR ACTION header~simular.

    METHODS diferir FOR MODIFY
      IMPORTING keys FOR ACTION header~diferir.

ENDCLASS.

CLASS lcl_header IMPLEMENTATION.

  METHOD read.
* ---------------------------------------------------------------------------
* Recupera os dados do Header
* ---------------------------------------------------------------------------
    IF keys[] IS NOT INITIAL.

      SELECT *
        FROM zi_fi_merc_int_h
        FOR ALL ENTRIES IN @keys
        WHERE empresa = @keys-empresa
          AND numdoc  = @keys-numdoc
          AND ano     = @keys-ano
        INTO CORRESPONDING FIELDS OF TABLE @result.     "#EC CI_SEL_DEL

      IF sy-subrc NE 0.
        FREE result.
      ENDIF.
    ENDIF.
  ENDMETHOD.

  METHOD rba_mercintitem.
    RETURN.
  ENDMETHOD.

  METHOD contabilizar.

    DATA: lt_header_aux TYPE TABLE OF zsfi_mercado_header WITH EMPTY KEY,
          lt_item_aux   TYPE TABLE OF zsfi_mercado_item,
          lv_data(8)    TYPE c.

    DATA: ls_header_aux LIKE LINE OF lt_header_aux,
          ls_item_aux   LIKE LINE OF lt_item_aux.

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

    READ ENTITIES OF zi_fi_merc_int_h IN LOCAL MODE
        ENTITY header
        ALL FIELDS WITH CORRESPONDING #( keys )
        RESULT DATA(lt_header).

    IF lt_header IS NOT INITIAL.

      DATA(lv_skip) = abap_false.

      LOOP AT lt_header ASSIGNING FIELD-SYMBOL(<fs_header>).
        CHECK <fs_header>-aptodiferimento <> 'Sim'.

        reported-header = VALUE #( ( %tky = <fs_header>-%tky
                                     %msg = new_message_with_text( severity = if_abap_behv_message=>severity-error
                                                                   text     = TEXT-003 )
                                   ) ).
        lv_skip = abap_true.
      ENDLOOP.

      CHECK lv_skip = abap_false.

      READ ENTITIES OF zi_fi_merc_int_h IN LOCAL MODE
          ENTITY item
          ALL FIELDS WITH CORRESPONDING #( keys )
          RESULT DATA(lt_item).

      MOVE-CORRESPONDING lt_header TO lt_header_aux.
      MOVE-CORRESPONDING lt_item   TO lt_item_aux.

      DATA(lo_contab) = zclfi_contabilizacao=>get_instance( ).

      lo_contab->set_ref_data( iv_app       = abap_true
                               it_header    = lt_header_aux
                               it_item      = lt_item_aux
                               iv_dtlanc    = ls_param-datalanc
                               iv_dtestorno = ls_param-dataestorno ).

      DATA(lt_menagens) = lo_contab->build( iv_merc_int = abap_true ).

      reported-header = VALUE #( FOR ls_mensagem IN lt_menagens
                                 ( %tky = keys[ sy-index ]-%tky
                                   %msg = new_message( id       = ls_mensagem-id
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

    DATA: ls_header_aux LIKE LINE OF lt_header_aux,
          ls_item_aux   LIKE LINE OF lt_item_aux.

    TRY .
        DATA(ls_param) = keys[ 1 ]-%param.
      CATCH cx_sy_itab_line_not_found.
    ENDTRY.

    IF ls_param-datalanc IS INITIAL.

      reported-header = VALUE #(  ( %tky = ls_param-datalanc
                                    %msg = new_message_with_text( severity = if_abap_behv_message=>severity-information
                                                                  text     = TEXT-001 )
                                  ) ).
      RETURN.
    ENDIF.

    READ ENTITIES OF zi_fi_merc_int_h IN LOCAL MODE
        ENTITY header
        ALL FIELDS WITH CORRESPONDING #( keys )
        RESULT DATA(lt_header).

    DATA(lv_skip) = abap_false.

    LOOP AT lt_header ASSIGNING FIELD-SYMBOL(<fs_header>).
      CHECK <fs_header>-aptodiferimento <> 'Sim'.

      reported-header = VALUE #(  ( %tky = <fs_header>-%tky
                                    %msg = new_message_with_text( severity = if_abap_behv_message=>severity-error
                                                                  text     = TEXT-003
                                          ) ) ).
      lv_skip = abap_true.
    ENDLOOP.

    CHECK lv_skip = abap_false.

    IF lt_header IS NOT INITIAL.

      READ ENTITIES OF zi_fi_merc_int_h IN LOCAL MODE
          ENTITY item
          ALL FIELDS WITH CORRESPONDING #( keys )
          RESULT DATA(lt_item).

      MOVE-CORRESPONDING lt_header TO lt_header_aux.
      MOVE-CORRESPONDING lt_item   TO lt_item_aux.

      IF lt_item_aux[] IS NOT INITIAL.

        DATA(lo_contab) = zclfi_contabilizacao=>get_instance(  ).

        lo_contab->set_ref_data( iv_app    = abap_true
                                 it_header = lt_header_aux
                                 it_item   = lt_item_aux
                                 iv_dtlanc = ls_param-datalanc ).

        DATA(lt_menagens) = lo_contab->build( iv_merc_int = abap_true
                                              iv_simular  = abap_true ).

        reported-header = VALUE #( FOR ls_mensagem IN lt_menagens
                                   ( %tky = keys[ sy-index ]-%tky
                                     %msg = new_message( id       = ls_mensagem-id
                                                         number   = ls_mensagem-number
*                                                         severity = CONV #( ls_mensagem-type )
                                                         severity = COND #( WHEN ls_mensagem-type = 'E'
                                                                              THEN CONV #( 'I' )
                                                                            ELSE CONV #( ls_mensagem-type ) )
                                                         v1       = ls_mensagem-message_v1
                                                         v2       = ls_mensagem-message_v2
                                                         v3       = ls_mensagem-message_v3
                                                         v4       = ls_mensagem-message_v4  ) ) ).
      ENDIF.
    ENDIF.

  ENDMETHOD.

  METHOD diferir.

    DATA: lt_header_aux TYPE TABLE OF zsfi_mercado_header WITH EMPTY KEY,
          lt_item_aux   TYPE TABLE OF zsfi_mercado_item.

    READ ENTITIES OF zi_fi_merc_int_h IN LOCAL MODE
        ENTITY header
        ALL FIELDS WITH CORRESPONDING #( keys )
        RESULT DATA(lt_header).

    LOOP AT lt_header ASSIGNING FIELD-SYMBOL(<fs_header>).
      CHECK <fs_header>-aptodiferimento IS NOT INITIAL.

      reported-header = VALUE #(  ( %tky = <fs_header>-%tky
                                    %msg = new_message_with_text(
                                                                    severity = if_abap_behv_message=>severity-error
                                                                    text     = TEXT-003
                                          ) ) ).
      DATA(lv_skip) = abap_true.
    ENDLOOP.

    CHECK lv_skip = abap_false.

    IF lt_header IS NOT INITIAL.

      READ ENTITIES OF zi_fi_merc_int_h IN LOCAL MODE
          ENTITY item
          ALL FIELDS WITH CORRESPONDING #( keys )
          RESULT DATA(lt_item).

      MOVE-CORRESPONDING lt_header TO lt_header_aux.
      MOVE-CORRESPONDING lt_item   TO lt_item_aux.

      DATA(lo_contab) = zclfi_contabilizacao=>get_instance(  ).

      lo_contab->set_ref_data( iv_app       = abap_true
                               it_header    = lt_header_aux
                               it_item      = lt_item_aux
                               iv_dtlanc    = sy-datum
                               iv_dtestorno = sy-datum ).

      lo_contab->diferimento( ).
*      DATA(lt_menagens) = lo_contab->diferimento( ).


*      reported-header = VALUE #( FOR ls_mensagem IN lt_menagens
*                                 ( %tky = keys[ sy-index ]-%tky
*
*                                   %msg = new_message(
*                                                       id       = ls_mensagem-id
*                                                       number   = ls_mensagem-number
*                                                       severity = CONV #( ls_mensagem-type )
*                                                       v1       = ls_mensagem-message_v1
*                                                       v2       = ls_mensagem-message_v2
*                                                       v3       = ls_mensagem-message_v3
*                                                       v4       = ls_mensagem-message_v4  ) ) ).

    ENDIF.

  ENDMETHOD.

ENDCLASS.

CLASS lcl_item DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS read FOR READ
      IMPORTING keys FOR READ item RESULT result.

    METHODS rba_mercintheader FOR READ
      IMPORTING keys_rba FOR READ item\_mercintheader FULL result_requested RESULT result LINK association_links.

ENDCLASS.

CLASS lcl_item IMPLEMENTATION.

  METHOD read.
* ---------------------------------------------------------------------------
* Recupera os dados do Item
* ---------------------------------------------------------------------------
    IF keys[] IS NOT INITIAL.

*      SELECT *
*      SELECT empresa,
*             numdoc,
*             ano,
*             item,
*             cliente,
*             conta,
*             divisao,
*             atribuicao,
*             textitem,
*             creddeb,
*             localnegocio,
*             centrolucro,
*             centrocusto,
*             segmento,
*             moeda,
*             valor,
*             valorcriticality
*        FROM zi_fi_merc_int_i
*         FOR ALL ENTRIES IN @keys
*       WHERE empresa = @keys-empresa
*         AND numdoc  = @keys-numdoc
*         AND ano     = @keys-ano
**        INTO CORRESPONDING FIELDS OF TABLE @result.     "#EC CI_SEL_DEL
*        INTO TABLE @DATA(lt_merc_i).

      SELECT a~bukrs AS empresa,
             a~belnr AS numdoc,
             a~gjahr AS ano,
             a~buzei AS item,
             a~kunnr AS cliente,
             a~hkont AS conta,
             a~gsber AS divisao,
             a~zuonr AS atribuicao,
             a~sgtxt AS textitem,
             a~shkzg AS creddeb,
             a~bupla AS localnegocio,
             a~prctr AS centrolucro,
             a~kostl AS centrocusto,
             a~segment AS segmento,
             b~waers AS moeda,
             a~dmbtr AS valor
        FROM bseg AS a
       INNER JOIN p_bkpf_com AS b ON b~bukrs = a~bukrs
                                 AND b~belnr = a~belnr
                                 AND b~gjahr = a~gjahr
         FOR ALL ENTRIES IN @keys
       WHERE a~bukrs = @keys-empresa
         AND a~belnr = @keys-numdoc
         AND a~gjahr = @keys-ano
*        INTO CORRESPONDING FIELDS OF TABLE @result.     "#EC CI_SEL_DEL
        INTO TABLE @DATA(lt_merc_i).

      IF sy-subrc IS INITIAL.

        result = CORRESPONDING #( lt_merc_i ).

      ENDIF.
    ENDIF.
  ENDMETHOD.

  METHOD rba_mercintheader.
    RETURN.
  ENDMETHOD.

ENDCLASS.

CLASS lcl_zi_fi_merc_int_h DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.

    METHODS check_before_save REDEFINITION.

    METHODS finalize          REDEFINITION.

    METHODS save              REDEFINITION.

ENDCLASS.

CLASS lcl_zi_fi_merc_int_h IMPLEMENTATION.

  METHOD check_before_save.
    RETURN.
  ENDMETHOD.

  METHOD finalize.
    RETURN.
  ENDMETHOD.

  METHOD save.
*    DATA(lo_contab) = zclfi_contabilizacao=>get_instance(  ).
*    lo_contab->save(  ).
    RETURN.
  ENDMETHOD.

ENDCLASS.
