CLASS zclfi_dde_function DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    METHODS constructor
      IMPORTING
        !is_venc TYPE zc_fi_venc_dde_busca .
    METHODS execute
      RETURNING
        VALUE(rt_return) TYPE bapiret2_tab .
  PROTECTED SECTION.
  PRIVATE SECTION.

    TYPES:
      BEGIN OF ty_semctr,
        bukrs      TYPE ztfi_cad_semcont-bukrs,
        kunnr      TYPE ztfi_cad_semcont-kunnr,
        dia_fixo   TYPE ztfi_cad_semcont-dia_fixo,
        dia_semana TYPE ztfi_cad_semcont-dia_semana,
      END OF ty_semctr .
    TYPES:
      ty_t_ctr TYPE TABLE OF zi_fi_dde_contrato WITH DEFAULT KEY .

    TYPES:
        ty_t_doc_lc TYPE TABLE OF zi_fi_dde_doc_lc WITH DEFAULT KEY .

    DATA gt_ctr TYPE ty_t_ctr .
    DATA gt_doc_lc TYPE ty_t_doc_lc .
    DATA gs_venc TYPE zc_fi_venc_dde_busca .
    DATA gs_semctr TYPE ty_semctr .
    CONSTANTS gc_contrato TYPE char1 VALUE '1' ##NO_TEXT.
    CONSTANTS gc_tab_semctr TYPE char1 VALUE '2' ##NO_TEXT.
    CONSTANTS gc_sem_ctr TYPE char1 VALUE '3' ##NO_TEXT.
    DATA gv_status TYPE char1 .
    DATA gt_return TYPE bapiret2_tab .
    DATA gv_entrega TYPE datum .
    DATA gv_venc TYPE datum .
    DATA gs_ctr TYPE zi_fi_dde_contrato .
    DATA gv_valida_dia TYPE abap_bool .

    METHODS calcula_novo_venc
      RETURNING
        VALUE(rv_date) TYPE scdatum .
    METHODS dia_fixo
      IMPORTING
        !iv_dia_fixo TYPE ze_dia_mes_fixo .
    METHODS dia_semana
      IMPORTING
        !iv_dia_semana TYPE ze_dia_semana_range .
    METHODS get_dia_util
      CHANGING
        !cv_date TYPE datum .
    METHODS get_output_date
      IMPORTING
        !iv_date       TYPE datum
      RETURNING
        VALUE(rv_date) TYPE char10 .
    METHODS main_process .
    METHODS tab_contrato .
    METHODS tab_sem_contrato .
    METHODS update_doc_cont
      IMPORTING
        !iv_date TYPE datum .
    METHODS tem_contrato
      RETURNING
        VALUE(rv_return) TYPE abap_bool .
    METHODS tem_tab_sem_contrato
      RETURNING
        VALUE(rv_return) TYPE abap_bool .
    METHODS get_contrato .
    METHODS get_sem_contrato .
    METHODS baixa_lc.
ENDCLASS.



CLASS zclfi_dde_function IMPLEMENTATION.


  METHOD calcula_novo_venc.

    DATA: lv_prazo TYPE bseg-zbd1t.

    SELECT SINGLE
      bukrs, belnr, gjahr,
      buzei, zfbdt, zbd1t,
      zbd2t, zbd3t
      FROM bseg
      INTO @DATA(ls_bseg)
      WHERE bukrs = @gs_venc-bukrs
        AND belnr = @gs_venc-belnr
        AND gjahr = @gs_venc-gjahr
        AND buzei = @gs_venc-buzei.

    lv_prazo = ls_bseg-zbd1t.

    IF tem_contrato( ) AND gs_ctr-prazo IS NOT INITIAL.

      lv_prazo = gs_ctr-prazo.

    ENDIF.

    CALL FUNCTION 'J_1B_FI_NETDUE'
      EXPORTING
        zfbdt   = gs_venc-dataentrega
        zbd1t   = lv_prazo
        zbd2t   = ls_bseg-zbd2t
        zbd3t   = ls_bseg-zbd3t
      IMPORTING
        duedate = rv_date.

  ENDMETHOD.


  METHOD constructor.

    gs_venc = is_venc.

    CLEAR: gt_doc_lc.
    SELECT *
    FROM zi_fi_dde_doc_lc
    INTO TABLE @gt_doc_lc
    WHERE belnr = @gs_venc-belnr
      AND gjahr = @gs_venc-gjahr
      AND bukrs = @gs_venc-bukrs.

  ENDMETHOD.


  METHOD dia_fixo.

    DATA: lv_mes TYPE numc2,
          lv_dia TYPE numc2.

    DATA: lt_data TYPE TABLE OF sy-datum.

    lv_mes  = gv_venc+4(2).

*    SPLIT gs_semctr-dia_fixo AT '-' INTO TABLE DATA(lt_dia_fixo).
    SPLIT iv_dia_fixo AT '-' INTO TABLE DATA(lt_dia_fixo).

    LOOP AT lt_dia_fixo ASSIGNING FIELD-SYMBOL(<fs_dia>).

      lv_mes = gv_venc+4(2).

      APPEND INITIAL LINE TO lt_data ASSIGNING FIELD-SYMBOL(<fs_data>).

      IF <fs_dia> < gv_venc+6(2).
        ADD 1 TO lv_mes.
      ENDIF.

      lv_dia = <fs_dia>.

      <fs_data> = gv_venc(4) && lv_mes && lv_dia.

      CALL FUNCTION 'DATE_CHECK_PLAUSIBILITY'
        EXPORTING
          date                      = <fs_data>
        EXCEPTIONS
          plausibility_check_failed = 1.

      IF sy-subrc <> 0.
        ADD 1 TO lv_mes.

        <fs_data> = gv_venc(4) && lv_mes && lv_dia.

      ENDIF.

    ENDLOOP.

    SORT lt_data.

    gv_venc = VALUE #( lt_data[ 1 ] OPTIONAL ).

    gv_valida_dia = abap_true.

  ENDMETHOD.


  METHOD dia_semana.

    DATA: lv_day  TYPE cind,
          lv_diff TYPE numc1.

    SPLIT iv_dia_semana AT '-' INTO TABLE DATA(lt_semana).

    CALL FUNCTION 'DATE_COMPUTE_DAY'
      EXPORTING
        date = gv_venc
      IMPORTING
        day  = lv_day.

    SORT lt_semana.

    LOOP AT lt_semana ASSIGNING FIELD-SYMBOL(<fs_semana>).

      IF <fs_semana> > lv_day.
        lv_diff = <fs_semana> - lv_day.
        ADD lv_diff TO gv_venc.
        EXIT.
      ENDIF.

    ENDLOOP.

    IF lv_diff IS INITIAL.

      lv_diff = VALUE #( lt_semana[ 1 ] OPTIONAL ).
      lv_diff = 7 - lv_day + lv_diff.
      ADD lv_diff TO gv_venc.

    ENDIF.

    gv_valida_dia = abap_true.

  ENDMETHOD.


  METHOD execute.

    get_contrato( ).

    gv_venc = calcula_novo_venc( ).

    IF tem_contrato( ).
      tab_contrato( ).
    ELSEIF tem_tab_sem_contrato( ).
      tab_sem_contrato( ).
    ELSE.

    ENDIF.

    main_process( ).

    rt_return = gt_return.

  ENDMETHOD.


  METHOD get_contrato.

    SELECT *
      FROM zi_fi_dde_contrato
      INTO TABLE @gt_ctr
      WHERE cnpjroot = @gs_venc-cnpjroot
        AND bukrs    = @gs_venc-bukrs.


    IF sy-subrc = 0.
      SORT gt_ctr BY familia classificacao.

      READ TABLE gt_ctr INTO gs_ctr WITH KEY familia       = gs_venc-familia
                                             classificacao = gs_venc-classificacao
                                             BINARY SEARCH.

      IF sy-subrc = 0.
        RETURN.
      ELSE.

        READ TABLE gt_ctr INTO gs_ctr WITH KEY familia       = space
                                               classificacao = gs_venc-classificacao
                                               BINARY SEARCH.

        IF sy-subrc = 0.
          RETURN.
        ELSE.

          READ TABLE gt_ctr INTO gs_ctr WITH KEY familia       = space
                                                 classificacao = space
                                                 BINARY SEARCH.

          IF sy-subrc = 0.
            RETURN.
          ELSE.

            CLEAR gs_ctr.
            RETURN.

          ENDIF.

        ENDIF.

      ENDIF.

    ENDIF.

  ENDMETHOD.


  METHOD get_dia_util.

    DATA lv_day TYPE cind.

    DO 7 TIMES.

      CALL FUNCTION 'DATE_CONVERT_TO_FACTORYDATE'
        EXPORTING
          date                         = cv_date
          factory_calendar_id          = 'BR'
        IMPORTING
          date                         = cv_date
        EXCEPTIONS
          calendar_buffer_not_loadable = 1
          correct_option_invalid       = 2
          date_after_range             = 3
          date_before_range            = 4
          date_invalid                 = 5
          factory_calendar_not_found   = 6
          OTHERS                       = 7.

      IF sy-subrc <> 0.
        CLEAR cv_date.
        EXIT.
      ELSE.
        CALL FUNCTION 'DATE_COMPUTE_DAY'
          EXPORTING
            date = cv_date
          IMPORTING
            day  = lv_day.
      ENDIF.

      IF lv_day EQ '6' OR lv_day EQ '7'.
        ADD 1 TO cv_date.
      ELSE.
        EXIT.
      ENDIF.

    ENDDO.

  ENDMETHOD.


  METHOD get_output_date.

    CALL FUNCTION 'CONVERSION_EXIT_PDATE_OUTPUT'
      EXPORTING
        input  = iv_date
      IMPORTING
        output = rv_date.

  ENDMETHOD.


  METHOD get_sem_contrato.

    SELECT SINGLE
      bukrs, kunnr,
      dia_fixo,
      dia_semana
      FROM ztfi_cad_semcont
      INTO @gs_semctr
      WHERE bukrs = @gs_venc-bukrs
        AND kunnr = @gs_venc-kunnr.

  ENDMETHOD.


  METHOD main_process.

    get_dia_util( CHANGING cv_date = gv_venc ).

    update_doc_cont( gv_venc ).

    baixa_lc(  ).

  ENDMETHOD.


  METHOD tab_contrato.

    IF gs_ctr-dia_mes_fixo IS NOT INITIAL.

      dia_fixo( gs_ctr-dia_mes_fixo ).

    ELSEIF gs_ctr-dia_semana IS NOT INITIAL.

      dia_semana( gs_ctr-dia_semana ).

    ENDIF.

  ENDMETHOD.


  METHOD tab_sem_contrato.

    IF gs_semctr-dia_fixo IS NOT INITIAL.

      dia_fixo( gs_semctr-dia_fixo ).

    ELSEIF gs_semctr-dia_semana IS NOT INITIAL.

      dia_semana( gs_semctr-dia_semana ).

    ENDIF.

  ENDMETHOD.


  METHOD tem_contrato.

    IF gs_ctr IS NOT INITIAL.
      rv_return = abap_true.
    ENDIF.

  ENDMETHOD.


  METHOD tem_tab_sem_contrato.

    get_sem_contrato( ).

    IF gs_semctr IS NOT INITIAL.
      rv_return = abap_true.
    ENDIF.

  ENDMETHOD.


  METHOD update_doc_cont.

    DATA lt_change TYPE fdm_t_accchg.

    DATA(lv_date_out) = get_output_date( gs_venc-dataentrega ).

    SELECT SINGLE
      anfbn
      FROM bseg
      INTO @DATA(lv_anfbn)
      WHERE bukrs = @gs_venc-bukrs
        AND belnr = @gs_venc-belnr
        AND gjahr = @gs_venc-gjahr
        AND buzei = @gs_venc-buzei.

    APPEND INITIAL LINE TO lt_change ASSIGNING FIELD-SYMBOL(<fs_chg>).
    <fs_chg>-fdname = 'MANSP'.

    IF gs_venc-dataentrega < gs_venc-budat.
      <fs_chg>-newval = '1'.
    ELSEIF gv_valida_dia IS NOT INITIAL.
      <fs_chg>-newval = '3'.

      APPEND INITIAL LINE TO lt_change ASSIGNING <fs_chg>.
      <fs_chg>-fdname = 'ZFBDT'.
      <fs_chg>-newval = iv_date.

      APPEND INITIAL LINE TO lt_change ASSIGNING <fs_chg>.
      <fs_chg>-fdname = 'ZBD1T'.
      <fs_chg>-newval = space.

      APPEND INITIAL LINE TO lt_change ASSIGNING <fs_chg>.
      <fs_chg>-fdname = 'ZBD2T'.
      <fs_chg>-newval = space.

      APPEND INITIAL LINE TO lt_change ASSIGNING <fs_chg>.
      <fs_chg>-fdname = 'ZBD3T'.
      <fs_chg>-newval = space.

      IF lv_anfbn IS NOT INITIAL.

        APPEND INITIAL LINE TO lt_change ASSIGNING <fs_chg>.
        <fs_chg>-fdname = 'DTWS1'.
        <fs_chg>-newval = '06'.

      ENDIF.

      APPEND INITIAL LINE TO lt_change ASSIGNING <fs_chg>.
      <fs_chg>-fdname = 'XREF1_HD'.
      <fs_chg>-newval = 'DDE-' && lv_date_out.

    ELSE.
      <fs_chg>-newval = '*'.

      APPEND INITIAL LINE TO lt_change ASSIGNING <fs_chg>.
      <fs_chg>-fdname = 'ZFBDT'.
      <fs_chg>-newval = iv_date.

      APPEND INITIAL LINE TO lt_change ASSIGNING <fs_chg>.
      <fs_chg>-fdname = 'ZBD1T'.
      <fs_chg>-newval = space.

      APPEND INITIAL LINE TO lt_change ASSIGNING <fs_chg>.
      <fs_chg>-fdname = 'ZBD2T'.
      <fs_chg>-newval = space.

      APPEND INITIAL LINE TO lt_change ASSIGNING <fs_chg>.
      <fs_chg>-fdname = 'ZBD3T'.
      <fs_chg>-newval = space.

      IF lv_anfbn IS NOT INITIAL.

        APPEND INITIAL LINE TO lt_change ASSIGNING <fs_chg>.
        <fs_chg>-fdname = 'DTWS1'.
        <fs_chg>-newval = '06'.

      ENDIF.

      APPEND INITIAL LINE TO lt_change ASSIGNING <fs_chg>.
      <fs_chg>-fdname = 'XREF1_HD'.
      <fs_chg>-newval = 'DDE-' && lv_date_out.

    ENDIF.



    CALL FUNCTION 'FI_DOCUMENT_CHANGE'
      EXPORTING
        i_buzei              = gs_venc-buzei
        i_bukrs              = gs_venc-bukrs
        i_belnr              = gs_venc-belnr
        i_gjahr              = gs_venc-gjahr
      TABLES
        t_accchg             = lt_change
      EXCEPTIONS
        no_reference         = 1
        no_document          = 2
        many_documents       = 3
        wrong_input          = 4
        overwrite_creditcard = 5
        OTHERS               = 6.

    IF sy-subrc <> 0.
      RETURN.
    ELSE.

      CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
        EXPORTING
          wait = 'X'.

      IF gt_return IS INITIAL.
        APPEND INITIAL LINE TO gt_return ASSIGNING FIELD-SYMBOL(<fs_return1>).
        <fs_return1>-id         = 'ZFI_DDE'.
        <fs_return1>-type       = 'I'.
        <fs_return1>-number     = '004'.

      ENDIF.

      APPEND INITIAL LINE TO gt_return ASSIGNING FIELD-SYMBOL(<fs_return>).
      <fs_return>-id         = 'ZFI_DDE'.
      <fs_return>-type       = 'S'.
      <fs_return>-number     = '003'.
      <fs_return>-message_v1 = gs_venc-bukrs.
      <fs_return>-message_v2 = gs_venc-belnr.
      <fs_return>-message_v3 = gs_venc-gjahr.
    ENDIF.

  ENDMETHOD.

  METHOD baixa_lc.

    DATA: lt_msg TYPE bapiret2_tab.

    LOOP AT gt_doc_lc ASSIGNING FIELD-SYMBOL(<fs_doc_lc>).

      CALL FUNCTION 'ZFMFI_BATCH_COMPENSAR'
        EXPORTING
          iv_kunnr = gs_venc-kunnr
          iv_waers = 'BRL'
          iv_budat = <fs_doc_lc>-budat
          iv_bukrs = <fs_doc_lc>-bukrs
          iv_anfbn = <fs_doc_lc>-anfbn
*        IMPORTING
*         ev_erro  =
*         ev_doc_est  =
*         ev_item_est =
*         ev_ano_est  =
        CHANGING
          ct_msg   = lt_msg.

      IF NOT line_exists( lt_msg[ type = 'E' ] ).
        APPEND INITIAL LINE TO gt_return ASSIGNING FIELD-SYMBOL(<fs_return>).
        <fs_return>-id         = 'ZFI_DDE'.
        <fs_return>-type       = 'S'.
        <fs_return>-number     = '005'.
        <fs_return>-message_v1 = <fs_doc_lc>-anfbn.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.

ENDCLASS.
