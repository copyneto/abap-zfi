CLASS zclfi_partidas_compensadas DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    TYPES: BEGIN OF ty_bsak,
             lifnr TYPE lifnr,
             xblnr TYPE xblnr1,
             belnr TYPE belnr_d,
             buzei TYPE buzei,
             gjahr TYPE gjahr,
             augdt TYPE augdt,
             augbl TYPE augbl,
             budat TYPE budat,
             zterm TYPE dzterm,
             blart TYPE blart,
             zlsch TYPE dzlsch,
             skfbt TYPE skfbt,
             wrbtr TYPE wrbtr,
             sgtxt TYPE sgtxt,
             ebeln TYPE ebeln,
             ebelp TYPE ebelp,
             bukrs TYPE bukrs,
             bupla TYPE bupla,
             shkzg TYPE shkzg,
           END   OF ty_bsak,

           BEGIN OF ty_bseg,
             bukrs TYPE bukrs,
             belnr TYPE belnr_d,
             buzei TYPE buzei,
             gjahr TYPE gjahr,
             netdt TYPE netdt,
             augbl TYPE augbl,
             wrbtr TYPE wrbtr,
             hkont TYPE hkont,
           END OF ty_bseg.

    TYPES: tt_bukrs TYPE RANGE OF t001-bukrs,
           tt_ebeln TYPE RANGE OF bseg-ebeln,
           tt_belnr TYPE RANGE OF bseg-belnr,
           tt_gjahr TYPE RANGE OF bseg-gjahr,
           tt_bsak  TYPE STANDARD TABLE OF ty_bsak WITH EMPTY KEY,
           tt_bseg  TYPE STANDARD TABLE OF ty_bseg WITH EMPTY KEY.

    METHODS:
      constructor
        IMPORTING
          ir_bukrs TYPE tt_bukrs
          ir_ebeln TYPE tt_ebeln
          ir_belnr TYPE tt_belnr
          ir_gjahr TYPE tt_gjahr,

      send_me
        RETURNING VALUE(rv_mess) TYPE string.

  PROTECTED SECTION.
  PRIVATE SECTION.

    CONSTANTS: BEGIN OF gc_values,
                 m1         TYPE string VALUE 'Dados não encontrados.',
                 m2         TYPE string VALUE 'Processamento executado com sucesso.',
                 k          TYPE koart VALUE 'K',
                 s          TYPE koart VALUE 'S',
                 n          TYPE koart VALUE 'N',
                 h          TYPE char1 VALUE 'H',
                 brl        TYPE string VALUE 'BRL',
                 fiap       TYPE ze_param_modulo VALUE 'FI-AP',
                 deducoes   TYPE ze_param_chave  VALUE 'DEDUCOES',
                 contarazao TYPE ze_param_chave VALUE 'CONTARAZAO',
                 pago       TYPE string VALUE 'Pago',
                 centro     TYPE string VALUE 'CENTRO',
                 empresa    TYPE string VALUE 'EMPRESA',
               END OF gc_values.


    DATA: gs_output    TYPE zclfi_mt_contas_pagas,
          gt_pedido_me TYPE STANDARD TABLE OF ztmm_pedido_me,
          gt_bsak      TYPE tt_bsak.

    DATA: gr_bukrs TYPE tt_bukrs,
          gr_ebeln TYPE tt_ebeln,
          gr_belnr TYPE tt_belnr,
          gr_gjahr TYPE tt_gjahr.

    METHODS:
      process_data,
      get_item
        IMPORTING
          is_bsak          TYPE ty_bsak
          iv_ctrazao       TYPE char10
          it_bsak          TYPE tt_bsak
          it_bseg          TYPE tt_bseg
        EXPORTING
          ev_pago          TYPE char1
        RETURNING
          VALUE(rv_result) TYPE wrbtr,

      get_wrbtr
        IMPORTING
          is_bsak          TYPE ty_bsak
        EXPORTING
          ev_pago          TYPE char1
        RETURNING
          VALUE(rv_result) TYPE wrbtr.

ENDCLASS.



CLASS ZCLFI_PARTIDAS_COMPENSADAS IMPLEMENTATION.


  METHOD constructor.

    gr_bukrs = ir_bukrs.
    gr_ebeln = ir_ebeln.
    gr_belnr = ir_belnr.
    gr_gjahr = ir_gjahr.

    me->process_data( ).
  ENDMETHOD.


  METHOD process_data.

    DATA: lr_ebeln                 TYPE RANGE OF bstnr,
          lr_ebelp                 TYPE RANGE OF ebelp,
          lt_contas_pagas_cont_tab TYPE zclfi_dt_contas_pagas_cont_tab,
          ls_contas_pagas_borg_tab TYPE zclfi_dt_contas_pagas_borg_tab,
          ls_contas_pagas_borgs    TYPE zclfi_dt_contas_pagas_borgs,
          lr_awkey                 TYPE RANGE OF awkey,
          lv_ctrazao               TYPE char10,
          lv_return                TYPE char1.

    SELECT * FROM ztmm_pedido_me
      WHERE ebeln IN @gr_ebeln
        AND pago  IS INITIAL
    INTO TABLE @gt_pedido_me.

    IF sy-subrc EQ 0.

      SELECT     ebeln,
                 ebelp,
                 belnr,
                 gjahr,
                 werks FROM ekbe
                 FOR ALL ENTRIES IN @gt_pedido_me
                 WHERE ebeln = @gt_pedido_me-ebeln
                 AND   ebelp = @gt_pedido_me-ebelp
                 INTO TABLE @DATA(lt_ekbe).

      IF sy-subrc EQ 0.

        LOOP AT lt_ekbe ASSIGNING FIELD-SYMBOL(<fs_ekbe>).

          lr_awkey = VALUE #( BASE lr_awkey ( sign   = 'I'
                                              option = 'EQ'
                                              low    = <fs_ekbe>-belnr && <fs_ekbe>-gjahr ) ).

        ENDLOOP.

        SELECT     bukrs,
                   belnr,
                   gjahr,
                   awkey FROM bkpf
            WHERE bukrs IN @gr_bukrs
              AND belnr IN @gr_belnr
              AND gjahr IN @gr_gjahr
              AND awkey IN @lr_awkey
            INTO TABLE @DATA(lt_bkpf).

        IF sy-subrc EQ 0.

          SELECT     bukrs,
                     belnr,
                     buzei,
                     gjahr,
                     netdt,
                     augbl,
                     wrbtr,
                     hkont FROM bseg
              FOR ALL ENTRIES IN @lt_bkpf
              WHERE bukrs = @lt_bkpf-bukrs
              AND   belnr = @lt_bkpf-belnr
              AND   gjahr = @lt_bkpf-gjahr
              AND   koart = @gc_values-k
              INTO TABLE @DATA(lt_bseg).

          SELECT     lifnr,
                     xblnr,
                     belnr,
                     buzei,
                     gjahr,
                     augdt,
                     augbl,
                     bldat,
                     budat,
                     zterm,
                     blart,
                     zlsch,
                     skfbt,
                     wrbtr,
                     sgtxt,
                     ebeln,
                     ebelp,
                     bukrs,
                     bupla,
                     shkzg FROM bsak_view
              FOR ALL ENTRIES IN @lt_bkpf
              WHERE bukrs = @lt_bkpf-bukrs
              AND   belnr = @lt_bkpf-belnr
              AND   gjahr = @lt_bkpf-gjahr
              INTO TABLE @DATA(lt_bsak).

          IF sy-subrc EQ 0.

            TRY.
                NEW zclca_tabela_parametros( )->m_get_single(
                            EXPORTING
                              iv_modulo = gc_values-fiap
                              iv_chave1 = gc_values-deducoes
                              iv_chave2 = gc_values-contarazao
                            IMPORTING
                              ev_param  = lv_ctrazao ).
              CATCH zcxca_tabela_parametros.
            ENDTRY.

            LOOP AT lt_bsak ASSIGNING FIELD-SYMBOL(<fs_bsak>).

              DATA(lv_deducao) = me->get_item(
                              EXPORTING
                                  is_bsak    = CORRESPONDING #( <fs_bsak> )
                                  it_bsak    = CORRESPONDING #( lt_bsak )
                                  it_bseg    = lt_bseg
                                  iv_ctrazao = lv_ctrazao
                              IMPORTING
                                  ev_pago    = lv_return ).

              IF lv_return NE abap_true.

                IF <fs_bsak>-shkzg = 'S'.
                  EXIT.
                ELSE.

                  <fs_bsak>-wrbtr = me->get_wrbtr(
                                  EXPORTING
                                      is_bsak    = CORRESPONDING #( <fs_bsak> )
                                  IMPORTING
                                      ev_pago    = lv_return ).

                  IF lv_return IS INITIAL.
                    EXIT.
                  ENDIF.

                ENDIF.
              ENDIF.

              DATA(lv_awkey) = VALUE #( lt_bkpf[ bukrs = <fs_bsak>-bukrs
                                                 belnr = <fs_bsak>-belnr
                                                 gjahr = <fs_bsak>-gjahr ]-awkey OPTIONAL ).

              IF lv_awkey IS NOT INITIAL.

                DATA(ls_ekbe) = VALUE #( lt_ekbe[ belnr = lv_awkey(10)
                                                  gjahr = lv_awkey+10(4) ] OPTIONAL ).

              ENDIF.

              SORT lt_bseg BY bukrs.

              DATA(ls_bseg) = VALUE #( lt_bseg[ bukrs = <fs_bsak>-bukrs
                                                belnr = <fs_bsak>-belnr
                                                buzei = <fs_bsak>-buzei
                                                gjahr = <fs_bsak>-gjahr ] OPTIONAL ).


              IF ls_bseg IS NOT INITIAL.

                DATA(lv_with_item) = <fs_bsak>-bukrs && <fs_bsak>-belnr && <fs_bsak>-gjahr.

                APPEND VALUE #(
                    is_loaded    = abap_true
                    xblnr        = <fs_bsak>-xblnr
                    belnr        = <fs_bsak>-belnr
                    lifnr        = <fs_bsak>-lifnr
                    fdtag        = ls_bseg-netdt
                    augdt        = <fs_bsak>-augdt
                    skfbt        = <fs_bsak>-skfbt
                    bldat        = <fs_bsak>-bldat
                    zterm        = <fs_bsak>-zterm
                    blart        = <fs_bsak>-blart
                    sgtxt        = <fs_bsak>-sgtxt
                    ebeln        = ls_ekbe-ebeln
                    budat        = <fs_bsak>-budat
                    deducao      = lv_deducao
                    status       = gc_values-pago
                    zlsch        = <fs_bsak>-zlsch
                    excluir      = gc_values-n
                    conta_rec    = space
                    moeda        = gc_values-brl
                    wrbtr        = ( <fs_bsak>-wrbtr - lv_deducao )
                    borgs        = VALUE zclfi_dt_contas_pagas_borgs( borg_empresa = VALUE #( ( codigo_borg = <fs_bsak>-bukrs  codigo_vent = gc_values-empresa ) )
                                                                      borg_centro  = VALUE #( ( codigo_borg = ls_ekbe-werks    codigo_vent = gc_values-centro  ) ) )
*                                                                        borg_centro  = VALUE #( ( codigo_borg = <fs_bsak>-bupla  codigo_vent = 'CENTRO' ) ) )
                ) TO lt_contas_pagas_cont_tab.

              ENDIF.

              gt_pedido_me[ ebeln =  ls_ekbe-ebeln ebelp =  ls_ekbe-ebelp ]-pago = abap_true.

              CLEAR: ls_ekbe, lv_with_item, lv_return, lv_deducao, lv_return.

            ENDLOOP.

            gs_output-mt_contas_pagas-msg_contas_pagas_list-itens-conta_paga = lt_contas_pagas_cont_tab[].

          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.

  ENDMETHOD.


  METHOD send_me.

    IF gs_output IS NOT INITIAL.

      TRY.

          NEW zclfi_co_si_enviar_contas_paga( )->si_enviar_contas_pagas_out( EXPORTING output = gs_output ).

          IF sy-subrc EQ 0.

            UPDATE ztmm_pedido_me FROM TABLE gt_pedido_me.

            COMMIT WORK.

            rv_mess = gc_values-m2.

          ENDIF.

        CATCH cx_ai_system_fault INTO DATA(lo_erro).

          DATA(ls_erro) = VALUE zclmm_exchange_fault_data1( fault_text = lo_erro->get_text( ) ).

          IF ls_erro IS NOT INITIAL.
            rv_mess = ls_erro-fault_text.
          ENDIF.

      ENDTRY.

    ELSE.
      rv_mess = gc_values-m1.
    ENDIF.

  ENDMETHOD.


  METHOD get_item.

    DATA: lv_sum TYPE wrbtr.

    CLEAR: lv_sum, ev_pago.

    DATA(lt_bsak_group)  = VALUE tt_bsak( FOR ls_bsak IN it_bsak
                                  WHERE ( augbl = is_bsak-augbl )
                                        ( CORRESPONDING #( ls_bsak ) ) ) .

    IF lines( lt_bsak_group ) GT 1.

      DELETE lt_bsak_group WHERE shkzg NE gc_values-h.

      IF lt_bsak_group IS NOT INITIAL.

        SELECT * FROM bsak_view
        FOR ALL ENTRIES IN @lt_bsak_group
           WHERE  bukrs = @lt_bsak_group-bukrs
            AND   belnr = @lt_bsak_group-augbl
            AND   gjahr = @lt_bsak_group-gjahr
            AND   shkzg = @gc_values-h
            INTO TABLE @DATA(lt_resul_augbl).

        IF lt_resul_augbl IS NOT INITIAL.

          SELECT     bukrs,
                     belnr,
                     buzei,
                     gjahr,
                     netdt,
                     augbl,
                     wrbtr,
                     hkont FROM bseg
              FOR ALL ENTRIES IN @lt_resul_augbl
              WHERE bukrs = @lt_resul_augbl-bukrs
              AND   belnr = @lt_resul_augbl-augbl
              AND   gjahr = @lt_resul_augbl-gjahr
              AND   koart = @gc_values-s
              AND   hkont = @iv_ctrazao
              INTO TABLE @DATA(lt_bseg_augbl).

          IF lt_bseg_augbl IS NOT INITIAL.

            ev_pago = NEW zclfi_verificar_pag_efetuado( )->verifica(
                             EXPORTING
                               iv_bukrs = VALUE #( lt_bsak_group[ 1 ]-bukrs OPTIONAL )
                               iv_belnr = VALUE #( lt_bsak_group[ 1 ]-belnr OPTIONAL )
                               iv_gjahr = VALUE #( lt_bsak_group[ 1 ]-gjahr OPTIONAL ) ).

            IF ev_pago IS INITIAL.
              RETURN.
            ENDIF.

            LOOP AT lt_bseg_augbl ASSIGNING FIELD-SYMBOL(<fs_bseg>).
              lv_sum = lv_sum + <fs_bseg>-wrbtr.
            ENDLOOP.


          ENDIF.

        ENDIF.
      ENDIF.

    ELSE.

      SELECT     bukrs,
                 belnr,
                 buzei,
                 gjahr,
                 netdt,
                 augbl,
                 wrbtr,
                 hkont FROM bseg
          FOR ALL ENTRIES IN @it_bsak
          WHERE bukrs = @it_bsak-bukrs
          AND   belnr = @it_bsak-augbl
          AND   gjahr = @it_bsak-gjahr
          AND   hkont = @iv_ctrazao
          INTO TABLE @lt_bseg_augbl.

      ev_pago = NEW zclfi_verificar_pag_efetuado( )->verifica(
                       EXPORTING
                         iv_bukrs = is_bsak-bukrs
                         iv_belnr = is_bsak-belnr
                         iv_gjahr = is_bsak-gjahr ).

      IF ev_pago IS INITIAL.
        RETURN.
      ENDIF.

      LOOP AT lt_bseg_augbl ASSIGNING <fs_bseg>
      GROUP BY ( bukrs = <fs_bseg>-bukrs
                 belnr = <fs_bseg>-belnr
                 gjahr = <fs_bseg>-gjahr
                ) ASSIGNING FIELD-SYMBOL(<fs_group>).
        CLEAR lv_sum.

        LOOP AT GROUP <fs_group> INTO DATA(ls_bseg) WHERE hkont = iv_ctrazao.
          lv_sum = lv_sum + ls_bseg-wrbtr.
        ENDLOOP.
      ENDLOOP.

    ENDIF.

    rv_result = lv_sum.

  ENDMETHOD.


  METHOD get_wrbtr.

    ev_pago = NEW zclfi_verificar_pag_efetuado( )->verifica(
       EXPORTING
         iv_bukrs = is_bsak-bukrs
         iv_belnr = is_bsak-belnr
         iv_gjahr = is_bsak-gjahr ).

    IF ev_pago IS NOT INITIAL.

      DATA(lv_hkont) = '111023%'.

      SELECT SINGLE wrbtr FROM bseg
                   WHERE bukrs = @is_bsak-bukrs
                   AND   belnr = @is_bsak-augbl
                   AND   gjahr = @is_bsak-gjahr
                   AND   hkont LIKE @lv_hkont
                   INTO @rv_result.

    ENDIF.

  ENDMETHOD.
ENDCLASS.
