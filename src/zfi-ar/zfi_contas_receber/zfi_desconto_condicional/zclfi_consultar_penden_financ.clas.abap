"!<p>Classe Consultar Pendência Financeira</p>
"!<p><strong>Autor:</strong>Marcos Rubik</p>
"!<p><strong>Data:</strong> 08 de Março de 2022</p>
class ZCLFI_CONSULTAR_PENDEN_FINANC definition
  public
  create public .

public section.

  constants:
    BEGIN OF gc_param,
                 modulo TYPE ztca_param_par-modulo VALUE 'FI-AR',
                 chave1 TYPE ztca_param_par-chave1 VALUE 'PDC',
                 chave2 TYPE ztca_param_par-chave2 VALUE 'CONTARAZAO',
               END OF gc_param .
  constants GC_RP type CHAR2 value 'RP' ##NO_TEXT.
  constants GC_BR type CHAR2 value 'BR' ##NO_TEXT.
  constants GC_0 type CHAR1 value '0' ##NO_TEXT.

  methods CONSTRUCTOR .
    "! Realizar consulta da pendência financeira
    "! @parameter iv_dtven_ini | Data Vencimento Inicial
    "! @parameter iv_dtven_fim | Data Vencimento Final
    "! @parameter iv_dtbase    | Data Base
    "! @parameter iv_kunnr     | Cliente
    "! @parameter it_vkorg     | Organização de Vendas
    "! @parameter rt_pend_fin  | Tabela retorno pendências financeiras
  methods CONSULTAR
    importing
      !IV_DTVEN_INI type DATS
      !IV_DTVEN_FIM type DATS
      !IV_DTBASE type DATS
      !IV_KUNNR type KUNNR
      !IT_VKORG type TDT_VKORG
    returning
      value(RT_PEND_FIN) type ZCTGFI_PEND_FIN .
  PROTECTED SECTION.
  PRIVATE SECTION.
    DATA: gr_hkont TYPE RANGE OF hkont,
          gr_parvw TYPE RANGE OF parvw.

    METHODS get_nr_days IMPORTING iv_dtde        TYPE dats
                                  iv_dtate       TYPE dats
                        RETURNING VALUE(rv_days) TYPE i.
ENDCLASS.



CLASS ZCLFI_CONSULTAR_PENDEN_FINANC IMPLEMENTATION.


  METHOD constructor.
    DATA(lo_param) = NEW zclca_tabela_parametros( ).

    TRY.
        lo_param->m_get_range( EXPORTING iv_modulo = gc_param-modulo
                                         iv_chave1 = gc_param-chave1
                                         iv_chave2 = gc_param-chave2
                               IMPORTING et_range  = gr_hkont ).

      CATCH zcxca_tabela_parametros INTO DATA(lo_cx).
        WRITE lo_cx->get_text( ).
    ENDTRY.

    gr_parvw =  VALUE #( ( sign   = 'I' option = 'EQ' low    = 'ZI' )
                         ( sign   = 'I' option = 'EQ' low    = 'ZE' )
                         ( sign   = 'I' option = 'EQ' low    = 'ZY' ) ).

  ENDMETHOD.


  METHOD consultar.
    DATA: ls_pend_fin TYPE zsfi_pend_fin.

    DATA: lv_parvw TYPE tpaum-parvw.

    DATA: lr_vkorg TYPE RANGE OF knvv-vkorg,
          lr_kunnr TYPE RANGE OF bsid_view-kunnr,
          lr_budat TYPE RANGE OF bsid_view-budat.

    lr_vkorg = VALUE #( FOR <fs_vkorg> IN it_vkorg
                          ( sign   = 'I'
                            option = 'EQ'
                            low    = <fs_vkorg> ) ).

    IF iv_kunnr IS NOT INITIAL.
      lr_kunnr = VALUE #( BASE lr_kunnr ( sign   = 'I'
                                          option = 'EQ'
                                          low    = iv_kunnr ) ).
    ENDIF.

    SELECT bukrs,
           kunnr,
           augdt,
           augbl,
           zuonr,
           gjahr,
           belnr,
           buzei,
           bldat,
           waers,
           shkzg,
           dmbtr,
           sgtxt,
           hkont,
           zlsch,
           anfbn,
           manst,
           bupla
      FROM bsid_view
     WHERE kunnr IN @lr_kunnr
       AND hkont IN @gr_hkont
       AND bldat <= @iv_dtbase
       AND mansp IN ('P', 'T')
      INTO TABLE @DATA(lt_bsid).

    SELECT bukrs,
           kunnr,
           augdt,
           augbl,
           zuonr,
           gjahr,
           belnr,
           buzei,
           bldat,
           waers,
           shkzg,
           dmbtr,
           sgtxt,
           hkont,
           zlsch,
           anfbn,
           manst,
           bupla
      FROM bsad_view
     WHERE kunnr IN @lr_kunnr
       AND augdt >  @iv_dtbase
       AND bldat >= @iv_dtbase
       AND hkont IN @gr_hkont
      INTO TABLE @DATA(lt_bsad).

    IF sy-subrc IS INITIAL.
      SORT lt_bsad BY kunnr.

      DATA: ls_bsid  LIKE LINE OF lt_bsid.

      LOOP AT lt_bsad ASSIGNING FIELD-SYMBOL(<fs_bsad>).
        MOVE-CORRESPONDING <fs_bsad> TO ls_bsid.
        APPEND ls_bsid TO lt_bsid.
      ENDLOOP.

      SORT lt_bsid BY kunnr belnr gjahr buzei.
    ENDIF.

    CHECK lt_bsid[] IS NOT INITIAL.

    SELECT  bukrs,
            belnr,
            gjahr,
            buzei,
            vbeln,
            netdt
    FROM bseg
    INTO TABLE @DATA(lt_bseg)
    FOR ALL ENTRIES IN @lt_bsid
    WHERE bukrs = @lt_bsid-bukrs
      AND belnr = @lt_bsid-belnr
      AND gjahr = @lt_bsid-gjahr
      AND buzei = @lt_bsid-buzei.
    IF sy-subrc EQ 0.
      SORT lt_bseg BY bukrs belnr gjahr buzei.
    ENDIF.

    SELECT kunnr,
           vkorg,
           vkbur,
           vkgrp
 FROM knvv
      INTO TABLE @DATA(lt_knvv)
        FOR ALL ENTRIES IN @lt_bsid
          WHERE kunnr EQ @lt_bsid-kunnr
            AND vkorg IN @lr_vkorg.
    IF sy-subrc EQ 0.
      SORT lt_knvv BY kunnr.
    ENDIF.

    CLEAR lv_parvw.
    CALL FUNCTION 'CONVERSION_EXIT_PARVW_INPUT'
      EXPORTING
        input  = gc_rp
      IMPORTING
        output = lv_parvw.


    SELECT  vbeln,
            posnr,
            parvw,
            lifnr
      FROM vbpa
      INTO TABLE @DATA(lt_vbpa)
      FOR ALL ENTRIES IN @lt_bseg
     WHERE vbeln EQ @lt_bseg-vbeln
       AND parvw IN @gr_parvw.
    IF sy-subrc EQ 0.
      SORT lt_vbpa BY vbeln.

      SELECT a~lifnr,
             b~bukrs,
             a~name1,
             b~mindk
        FROM lfa1 AS a
        INNER JOIN lfb1 AS b
        ON a~lifnr = b~lifnr
       INTO TABLE @DATA(lt_lfa1)
       FOR ALL ENTRIES IN @lt_vbpa
        WHERE a~lifnr EQ @lt_vbpa-lifnr.
      IF sy-subrc EQ 0.
        SORT lt_lfa1 BY lifnr bukrs.

        SELECT vkgrp,
               bezei
          FROM tvgrt
          INTO TABLE @DATA(lt_tvgrt)
          FOR ALL ENTRIES IN @lt_lfa1
            WHERE spras EQ @sy-langu
              AND vkgrp EQ @lt_lfa1-mindk.
        IF sy-subrc EQ 0.
          SORT lt_tvgrt BY vkgrp.
        ENDIF.
      ENDIF.
    ENDIF.

    SELECT kunnr,
           name1,
           regio
      FROM kna1
      INTO TABLE @DATA(lt_kna1)
        FOR ALL ENTRIES IN @lt_bsid
          WHERE kunnr EQ @lt_bsid-kunnr.
    IF sy-subrc EQ 0.
      SORT lt_kna1 BY kunnr.
    ENDIF.

    lr_budat =  VALUE #( ( sign   = 'I'
                           option = 'BT'
                           low    = iv_dtven_ini
                           high   = iv_dtven_fim ) ).

    LOOP AT lt_bsid ASSIGNING FIELD-SYMBOL(<fs_bsid>).
      CLEAR: ls_pend_fin.

      READ TABLE lt_bseg
            INTO DATA(ls_bseg)
        WITH KEY  bukrs = <fs_bsid>-bukrs
                  belnr = <fs_bsid>-belnr
                  gjahr = <fs_bsid>-gjahr
                  buzei = <fs_bsid>-buzei
        BINARY SEARCH.
      IF sy-subrc EQ 0 AND
         ls_bseg-netdt NOT IN lr_budat.
        CONTINUE.
      ENDIF.

      MOVE-CORRESPONDING <fs_bsid> TO ls_pend_fin.

      ls_pend_fin-dtven = ls_bseg-netdt.

      READ TABLE lt_kna1
            INTO DATA(ls_kna1)
        WITH KEY kunnr = <fs_bsid>-kunnr BINARY SEARCH.
      IF sy-subrc EQ 0.
        ls_pend_fin-name1 = ls_kna1-name1.
        ls_pend_fin-regio = ls_kna1-regio.
      ENDIF.

      READ TABLE lt_knvv
            INTO DATA(ls_knvv)
        WITH KEY kunnr = <fs_bsid>-kunnr
        BINARY SEARCH.
      IF sy-subrc EQ 0.
        ls_pend_fin-vkorg = ls_knvv-vkorg.
        ls_pend_fin-vkbur = ls_knvv-vkbur.
        ls_pend_fin-vkgrp = ls_knvv-vkgrp.
        READ TABLE lt_vbpa
              INTO DATA(ls_vbpa)
          WITH KEY vbeln = ls_bseg-vbeln
          BINARY SEARCH.
        IF sy-subrc EQ 0.
          READ TABLE lt_lfa1
                INTO DATA(ls_lfa1)
            WITH KEY lifnr = ls_vbpa-lifnr
                     bukrs = <fs_bsid>-bukrs
            BINARY SEARCH.
          IF sy-subrc EQ 0.
            ls_pend_fin-lifnr     = ls_lfa1-lifnr.
            ls_pend_fin-name_vend = ls_lfa1-name1.
            ls_pend_fin-mindk     = ls_lfa1-mindk.
            READ TABLE lt_tvgrt
                  INTO DATA(ls_tvgrt)
              WITH KEY vkgrp = ls_lfa1-mindk
              BINARY SEARCH.
            IF sy-subrc EQ 0.
              ls_pend_fin-name_sup = ls_tvgrt-bezei.
            ENDIF.
          ENDIF.
        ENDIF.
      ENDIF.

      ls_pend_fin-bldat = <fs_bsid>-bldat.

      IF iv_dtbase < ls_pend_fin-dtven.

        ls_pend_fin-atraso = me->get_nr_days( iv_dtde  = iv_dtven_ini
                                              iv_dtate = iv_dtven_fim ).
        ls_pend_fin-atraso = (  ls_pend_fin-atraso - 1 ) * -1.

      ELSEIF iv_dtbase > ls_pend_fin-dtven.

        ls_pend_fin-atraso = me->get_nr_days( iv_dtde  = ls_pend_fin-dtven
                                              iv_dtate = iv_dtbase ).
        ls_pend_fin-atraso = ls_pend_fin-atraso - 1.

      ELSEIF iv_dtbase < <fs_bsid>-augdt.

        IF <fs_bsid>-augdt > ls_pend_fin-dtven.

          ls_pend_fin-atraso = me->get_nr_days( iv_dtde  = iv_dtbase
                                                iv_dtate = <fs_bsid>-augdt ).
          ls_pend_fin-atraso = ls_pend_fin-atraso - 1.

        ELSE.

          ls_pend_fin-atraso = me->get_nr_days( iv_dtde  = iv_dtbase
                                                iv_dtate = <fs_bsid>-augdt ).
          ls_pend_fin-atraso = (  ls_pend_fin-atraso - 1 ) * -1.

        ENDIF.
      ENDIF.

      SHIFT ls_pend_fin-atraso LEFT DELETING LEADING gc_0.

      IF ls_pend_fin-atraso IS INITIAL.
        ls_pend_fin-atraso = gc_0.
      ENDIF.

      IF <fs_bsid>-shkzg = 'H'.
        <fs_bsid>-dmbtr = <fs_bsid>-dmbtr * -1.
      ENDIF.

*     Valor faturamento
      IF ls_pend_fin-atraso <= 5.
        ls_pend_fin-tax05 = <fs_bsid>-dmbtr.
      ELSEIF ls_pend_fin-atraso > 5  AND ls_pend_fin-atraso <= 30.
        ls_pend_fin-tax30 = <fs_bsid>-dmbtr.
      ELSEIF ls_pend_fin-atraso > 30 AND ls_pend_fin-atraso <= 60.
        ls_pend_fin-tax60 = <fs_bsid>-dmbtr.
      ELSEIF ls_pend_fin-atraso > 60 AND ls_pend_fin-atraso <= 120.
        ls_pend_fin-tax120 = <fs_bsid>-dmbtr.
      ELSEIF ls_pend_fin-atraso > 120.
        ls_pend_fin-taxmax = <fs_bsid>-dmbtr.
      ENDIF.

*     Total de cada registro
      ls_pend_fin-total = ls_pend_fin-tax05  + ls_pend_fin-tax30  + ls_pend_fin-tax60 +
                          ls_pend_fin-tax120 + ls_pend_fin-taxmax.

      IF ls_pend_fin-total < 0.
        CLEAR ls_pend_fin.
        CONTINUE.
      ENDIF.

      APPEND ls_pend_fin TO rt_pend_fin.
    ENDLOOP.

  ENDMETHOD.


  METHOD get_nr_days.
    DATA: lt_mes     TYPE STANDARD TABLE OF casdayattr.

    CALL FUNCTION 'DAY_ATTRIBUTES_GET'
      EXPORTING
        factory_calendar = gc_br
        holiday_calendar = gc_br
        date_from        = iv_dtde
        date_to          = iv_dtate
        language         = sy-langu
      TABLES
        day_attributes   = lt_mes.

    DESCRIBE TABLE lt_mes LINES rv_days.

  ENDMETHOD.
ENDCLASS.
