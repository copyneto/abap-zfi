CLASS lcl_base DEFINITION INHERITING FROM cl_abap_behavior_handler.

  PRIVATE SECTION.

    METHODS update FOR MODIFY
      IMPORTING entities FOR UPDATE base.

    METHODS read FOR READ
      IMPORTING keys FOR READ base RESULT result.

    METHODS rba_contrato FOR READ
      IMPORTING keys_rba FOR READ base\_contrato FULL result_requested RESULT result LINK association_links.


    METHODS apagabase FOR MODIFY
      IMPORTING keys FOR ACTION base~apagabase.

    METHODS lock FOR LOCK
      IMPORTING keys FOR LOCK contrato.


    DATA gt_messages       TYPE STANDARD TABLE OF bapiret2.

ENDCLASS.

CLASS lcl_base IMPLEMENTATION.

  METHOD update.
    DATA ls_values TYPE ztfi_calc_cresci.

    DATA(lo_base) = NEW zclfi_base_de_calculo_app( ).

    LOOP AT entities ASSIGNING FIELD-SYMBOL(<fs_entities>).

      DATA(lv_contrato)         = <fs_entities>-contrato.
      DATA(lv_aditivo)          = <fs_entities>-aditivo.
      DATA(lv_bukrs)            = <fs_entities>-newbukrs.
      DATA(lv_belnr)            = <fs_entities>-newbelnr.
      DATA(lv_gjahr)            = <fs_entities>-newgjahr.
      DATA(lv_buzei)            = <fs_entities>-newbuzei.
      DATA(lv_ajuste_anual)     = <fs_entities>-newajusteanual.
      DATA(lv_gsber)            = <fs_entities>-newgsber.
      DATA(lv_familia_cl)       = <fs_entities>-newfamiliacl.
      DATA(lv_chave_manual)     = <fs_entities>-chavemanual.

      ls_values-aditivo          =  <fs_entities>-aditivo .
      ls_values-ajuste_anual     =  <fs_entities>-ajusteanual  .
      ls_values-augbl            =  <fs_entities>-augbl  .
      ls_values-augdt            =  <fs_entities>-augdt   .
      ls_values-belnr            =  <fs_entities>-belnr  .
      ls_values-blart            =  <fs_entities>-blart .
      ls_values-bldat            =  <fs_entities>-bldat .
      ls_values-bonus_calculado  =  <fs_entities>-bonuscalculado.
      ls_values-bschl            =  <fs_entities>-bschl  .
      ls_values-budat            =  <fs_entities>-budat      .
      ls_values-bukrs            =  <fs_entities>-bukrs  .
      ls_values-buzei            =  <fs_entities>-buzei .
      ls_values-bzirk            =  <fs_entities>-bzirk      .
      ls_values-cond_desconto    =  <fs_entities>-conddesconto .
      ls_values-contrato         =  <fs_entities>-contrato  .
      ls_values-familia_cl       =  <fs_entities>-familiacl   .
      ls_values-gjahr            =  <fs_entities>-gjahr      .
      ls_values-gsber            =  <fs_entities>-gsber .
      ls_values-impost_desconsid =  <fs_entities>-impostdesconsid .
      ls_values-katr2            =  <fs_entities>-katr2   .
      ls_values-kostl            =  <fs_entities>-kostl .
      ls_values-kunnr            =  <fs_entities>-kunnr  .
      ls_values-mont_bonus       =  <fs_entities>-montbonus  .
      ls_values-mont_liq_tax     =  <fs_entities>-montliqtax .
      ls_values-mont_valido      =  <fs_entities>-montvalido  .
      ls_values-netdt            =  <fs_entities>-netdt   .
      ls_values-obs_ajuste       =  <fs_entities>-obsajuste  .
      ls_values-posnr            =  <fs_entities>-posnr      .
      ls_values-prctr            =  <fs_entities>-prctr    .
      ls_values-sgtxt            =  <fs_entities>-sgtxt   .
      ls_values-spart            =  <fs_entities>-spart      .
      ls_values-status_dde       =  <fs_entities>-statusdde  .
      ls_values-tipo_apuracao    =  <fs_entities>-tipoapuracao .
      ls_values-tipo_ap_imposto  =  <fs_entities>-tipoapimposto .
      ls_values-tipo_desconto    =  <fs_entities>-tipodesconto  .
      ls_values-tipo_entrega     =  <fs_entities>-tipoentrega   .
      ls_values-tipo_imposto     =  <fs_entities>-tipoimposto  .
      ls_values-vbeln            =  <fs_entities>-vbeln  .
      ls_values-vgbel            =  <fs_entities>-vgbel .
      ls_values-vtweg            =  <fs_entities>-vtweg  .
      ls_values-wrbtr            =  <fs_entities>-wrbtr   .
      ls_values-wwmt1            =  <fs_entities>-wwmt1  .
      ls_values-xblnr            =  <fs_entities>-xblnr     .
      ls_values-xref1_hd         =  <fs_entities>-xref1hd  .
      ls_values-zlsch            =  <fs_entities>-zlsch      .
      ls_values-zuonr            =  <fs_entities>-zuonr  .

      FREE gt_messages.
      lo_base->update_calc_cresci( EXPORTING is_values       = ls_values
                                             iv_contrato     = lv_contrato
                                             iv_aditivo      = lv_aditivo
                                             iv_bukrs        = lv_bukrs
                                             iv_belnr        = lv_belnr
                                             iv_gjahr        = lv_gjahr
                                             iv_buzei        = lv_buzei
                                             iv_ajuste_anual = lv_ajuste_anual
                                             iv_gsber        = lv_gsber
                                             iv_familia_cl   = lv_familia_cl
                                             iv_chave_manual = lv_chave_manual


                                   IMPORTING et_return = gt_messages  ).

      IF line_exists( gt_messages[ type = 'E' ] ).       "#EC CI_STDSEQ
        APPEND VALUE #(  %tky = <fs_entities>-%tky ) TO failed-base.
      ENDIF.

      LOOP AT gt_messages INTO DATA(ls_message).         "#EC CI_NESTED

        APPEND VALUE #( %tky        = <fs_entities>-%tky
                        %msg        = new_message( id       = ls_message-id
                                                   number   = ls_message-number
                                                   v1       = ls_message-message_v1
                                                   v2       = ls_message-message_v2
                                                   v3       = ls_message-message_v3
                                                   v4       = ls_message-message_v4
                                                   severity = CONV #( ls_message-type ) )
                         )
          TO reported-base.

      ENDLOOP.
    ENDLOOP.
  ENDMETHOD.

  METHOD read.
    IF sy-subrc IS INITIAL.
    ENDIF.
  ENDMETHOD.

  METHOD rba_contrato.
    IF keys_rba IS NOT INITIAL.


      LOOP AT keys_rba ASSIGNING FIELD-SYMBOL(<FS_rba>).
        APPEND INITIAL LINE TO association_links ASSIGNING FIELD-SYMBOL(<fs_links>).

        <fs_links>-source = <FS_rba>.

      ENDLOOP.
    ENDIF.
  ENDMETHOD.

  METHOD apagabase.

    DATA(lv_obs_ajuste) = keys[ 1 ]-%param-obs_ajuste.

    DATA(lo_base) = NEW zclfi_base_de_calculo_app( ).

    READ ENTITIES OF zi_fi_contrato_base IN LOCAL MODE
    ENTITY base BY \_contrato FIELDS ( contrato aditivo ) WITH CORRESPONDING #( keys )
    RESULT DATA(lt_contrato)
    LINK DATA(lt_link)
    FAILED failed.

    LOOP AT lt_link ASSIGNING FIELD-SYMBOL(<FS_source>).
      FREE gt_messages.
      lo_base->apaga_base(
        EXPORTING
          iv_contrato     = <FS_source>-source-contrato
          iv_aditivo      = <FS_source>-source-aditivo
          iv_bukrs        = <FS_source>-source-bukrs
          iv_belnr        = <FS_source>-source-belnr
          iv_gjahr        = <FS_source>-source-gjahr
          iv_buzei        = <FS_source>-source-buzei
          iv_ajuste_anual = <FS_source>-source-ajusteanual
          iv_gsber        = <FS_source>-source-gsber
          iv_familia_cl   = <FS_source>-source-familiacl
          iv_chave_manual = <FS_source>-source-chavemanual
          iv_obs_ajuste   = lv_obs_ajuste
        IMPORTING
          et_return       = gt_messages ).


      IF line_exists( gt_messages[ type = 'E' ] ).       "#EC CI_STDSEQ
        APPEND VALUE #(  %tky = <FS_source>-source-%tky ) TO failed-base.
      ENDIF.

      LOOP AT gt_messages INTO DATA(ls_message).         "#EC CI_NESTED

        APPEND VALUE #( %tky        = <FS_source>-source-%tky
                        %msg        = new_message( id       = ls_message-id
                                                   number   = ls_message-number
                                                   v1       = ls_message-message_v1
                                                   v2       = ls_message-message_v2
                                                   v3       = ls_message-message_v3
                                                   v4       = ls_message-message_v4
                                                   severity = CONV #( ls_message-type ) )
                         )
          TO reported-base.

      ENDLOOP.




    ENDLOOP.

  ENDMETHOD.

  METHOD lock.
    IF sy-subrc IS INITIAL.
    ENDIF.
  ENDMETHOD.

ENDCLASS.
