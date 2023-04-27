"!<p><strong>Essa classe é utilizada para atualizar o campo customizado Vencimento Original</strong>
"!<p><strong>Autor:</strong> Anderson Macedo - Meta</p>
"!<p><strong>Data:</strong> 18/08/2021</p>
CLASS zclfi_venc_orig DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_badi_interface .
    INTERFACES if_fagl_lib .

    METHODS ext_venc_orig
      IMPORTING
        !iv_key             TYPE bseg_key
        !iv_netdt           TYPE bseg-netdt
      RETURNING
        VALUE(rv_venc_orig) TYPE datum .
  PROTECTED SECTION.
  PRIVATE SECTION.

    TYPES:
      BEGIN OF ty_func,
        zfbdt TYPE dzfbdt,
        zbd1t TYPE dzbd1t,
        zbd2t TYPE dzbd2t,
        zbd3t TYPE dzbd3t,
      END OF ty_func .
    TYPES:
      BEGIN OF ty_bseg,
        belnr TYPE bseg-belnr,
        bukrs TYPE bseg-bukrs,
        gjahr TYPE bseg-gjahr,
        buzei TYPE bseg-buzei,
        netdt TYPE bseg-netdt,
        objid TYPE char90,
        tbkey TYPE char70,
      END OF ty_bseg .
    TYPES:
      BEGIN OF ty_venc,
        bukrs TYPE bseg-bukrs,
        belnr TYPE bseg-belnr,
        gjahr TYPE bseg-gjahr,
        buzei TYPE bseg-buzei,
        zfbdt TYPE dzfbdt,
        zbd1t TYPE dzbd1t,
        zbd2t TYPE dzbd2t,
        zbd3t TYPE dzbd3t,
      END OF ty_venc .
    TYPES:
      BEGIN OF ty_funcx,
        zfbdt TYPE abap_bool,
        zbd1t TYPE abap_bool,
        zbd2t TYPE abap_bool,
        zbd3t TYPE abap_bool,
      END OF ty_funcx .

    TYPES:
      BEGIN OF ty_bseg_venc,
        belnr     TYPE bseg-belnr,
        bukrs     TYPE bseg-bukrs,
        gjahr     TYPE bseg-gjahr,
        buzei     TYPE bseg-buzei,
        netdt     TYPE bseg-netdt,
        venc_orig TYPE sy-datum,
      END OF ty_bseg_venc.

    DATA gs_func TYPE ty_func .
    DATA gs_funcx TYPE ty_funcx .
    DATA:
      gt_venc TYPE TABLE OF ty_venc .
    DATA:
      gt_bseg TYPE TABLE OF ty_bseg WITH DEFAULT KEY .
    DATA:
      gt_log TYPE TABLE OF zi_fi_log_doc .

    METHODS tcode_is_valid
      RETURNING
        VALUE(rv_return) TYPE abap_bool .
    "! Rotina de atualização do campo na tabela principal
    "! @parameter ct_data      | Tabela com os dados principais do relatório
    METHODS update_venc_orig
      CHANGING
        !ct_data            TYPE STANDARD TABLE
      RETURNING
        VALUE(rv_venc_orig) TYPE datum .
    "! Busca os dados das tabelas de log do documento
    METHODS get_doc_history .
    "! Leitura dos dados de log e calculo do campo
    "! @parameter is_bseg      | Linha da tabela BSEG
    "! @parameter rv_venc      | Vencimento Original
    METHODS get_venc_orig
      IMPORTING
        !is_bseg       TYPE ty_bseg
      RETURNING
        VALUE(rv_venc) TYPE datum .
    "! Preparação dos dados para o processamento
    "! @parameter ct_data      | Tabela com os dados principais do relatório
    METHODS prepare_data
      CHANGING
        !ct_data TYPE STANDARD TABLE .
    "! Montagem da tabela BSEG para otimizar buscas
    "! @parameter ct_detail_it | Campos da tabela BSEG
    "! @parameter cs_data      | Linha da tabela principal
    METHODS fill_bseg
      CHANGING
        !ct_detail_it TYPE abap_compdescr_tab
        !cs_data      TYPE any .
ENDCLASS.



CLASS ZCLFI_VENC_ORIG IMPLEMENTATION.


  METHOD if_fagl_lib~select_data.

    IF tcode_is_valid( ).

      prepare_data( CHANGING ct_data = ct_data ).

      get_doc_history( ).

      update_venc_orig( CHANGING  ct_data = ct_data ).

    ENDIF.

  ENDMETHOD.


  METHOD if_fagl_lib~add_fields.
    RETURN.
  ENDMETHOD.


  METHOD if_fagl_lib~add_secondary_fields.
    RETURN.
  ENDMETHOD.


  METHOD if_fagl_lib~column_visibility_change.
    RETURN.
  ENDMETHOD.


  METHOD if_fagl_lib~create_default_restrictions.
    RETURN.
  ENDMETHOD.


  METHOD if_fagl_lib~main_toolbar_handle.
    RETURN.
  ENDMETHOD.


  METHOD if_fagl_lib~main_toolbar_handle_menu.
    RETURN.
  ENDMETHOD.


  METHOD if_fagl_lib~main_toolbar_set.
    RETURN.
  ENDMETHOD.


  METHOD if_fagl_lib~modify_rri_restrictions.
    RETURN.
  ENDMETHOD.


  METHOD if_fagl_lib~sidebar_actions_handle.
    RETURN.
  ENDMETHOD.


  METHOD if_fagl_lib~sidebar_actions_set.
    RETURN.
  ENDMETHOD.


  METHOD get_venc_orig.

    CLEAR: gs_func, gs_funcx.

    READ TABLE gt_log ASSIGNING FIELD-SYMBOL(<fs_log1>) WITH KEY objectid = is_bseg-objid
                                                                 tabkey   = is_bseg-tbkey
                                                                 fname    = 'ZFBDT'
                                                        BINARY SEARCH.
    IF sy-subrc = 0.
      gs_func-zfbdt = <fs_log1>-value_old.
      gs_funcx-zfbdt = abap_true.
    ENDIF.
    UNASSIGN <fs_log1>.

    READ TABLE gt_log ASSIGNING FIELD-SYMBOL(<fs_log2>) WITH KEY objectid = is_bseg-objid
                                                                 tabkey   = is_bseg-tbkey
                                                                 fname    = 'ZBD1T'
                                                        BINARY SEARCH.
    IF sy-subrc = 0.
      gs_func-zbd1t = <fs_log2>-value_old.
      gs_funcx-zbd1t = abap_true.
    ENDIF.
    UNASSIGN <fs_log2>.

    READ TABLE gt_log ASSIGNING FIELD-SYMBOL(<fs_log3>) WITH KEY objectid = is_bseg-objid
                                                                 tabkey   = is_bseg-tbkey
                                                                 fname    = 'ZBD2T'
                                                        BINARY SEARCH.
    IF sy-subrc = 0.
      gs_func-zbd2t = <fs_log3>-value_old.
      gs_funcx-zbd2t = abap_true.
    ENDIF.
    UNASSIGN <fs_log3>.

    READ TABLE gt_log ASSIGNING FIELD-SYMBOL(<fs_log4>) WITH KEY objectid = is_bseg-objid
                                                                 tabkey   = is_bseg-tbkey
                                                                 fname    = 'ZBD3T'
                                                        BINARY SEARCH.
    IF sy-subrc = 0.
      gs_func-zbd3t = <fs_log4>-value_old.
      gs_funcx-zbd3t = abap_true.
    ENDIF.
    UNASSIGN <fs_log4>.

    IF gs_func IS NOT INITIAL OR gs_funcx IS NOT INITIAL.

      READ TABLE gt_venc INTO DATA(ls_venc) WITH KEY bukrs = is_bseg-tbkey+3(4) "#EC CI_STDSEQ
                                                     belnr = is_bseg-tbkey+7(10)
                                                     gjahr = is_bseg-tbkey+17(4)
                                                     buzei = is_bseg-tbkey+21(3).

      IF sy-subrc = 0.

        IF gs_func-zfbdt EQ if_hrbas_constants=>initial_date AND gs_funcx-zfbdt IS INITIAL.
          gs_func-zfbdt = ls_venc-zfbdt.
        ENDIF.

        IF gs_func-zbd1t IS INITIAL AND gs_funcx-zbd1t IS INITIAL.
          gs_func-zbd1t = ls_venc-zbd1t.
        ENDIF.

        IF gs_func-zbd2t IS INITIAL AND gs_funcx-zbd2t IS INITIAL.
          gs_func-zbd2t = ls_venc-zbd2t.
        ENDIF.

        IF gs_func-zbd3t IS INITIAL AND gs_funcx-zbd3t IS INITIAL.
          gs_func-zbd3t = ls_venc-zbd3t.
        ENDIF.

        CALL FUNCTION 'J_1B_FI_NETDUE'
          EXPORTING
            zfbdt   = gs_func-zfbdt
            zbd1t   = gs_func-zbd1t
            zbd2t   = gs_func-zbd2t
            zbd3t   = gs_func-zbd3t
          IMPORTING
            duedate = rv_venc.

      ENDIF.

    ELSE.

      rv_venc = is_bseg-netdt.

    ENDIF.

  ENDMETHOD.


  METHOD prepare_data.

    DATA: lo_ref_descr   TYPE REF TO cl_abap_structdescr.
    DATA: lt_detail_it   TYPE abap_compdescr_tab.

    DATA ls_bseg TYPE ty_bseg.

    lo_ref_descr ?= cl_abap_typedescr=>describe_by_data( ls_bseg ).
    lt_detail_it  = lo_ref_descr->components.

    LOOP AT ct_data ASSIGNING FIELD-SYMBOL(<fs_data>).

      fill_bseg( CHANGING ct_detail_it = lt_detail_it
                          cs_data = <fs_data> ).

    ENDLOOP.

    IF gt_bseg IS NOT INITIAL.

      SELECT
        bukrs, belnr, gjahr, buzei,
        zfbdt, zbd1t, zbd2t, zbd3t
        FROM bseg
        INTO TABLE @gt_venc
        FOR ALL ENTRIES IN @gt_bseg
        WHERE bukrs = @gt_bseg-bukrs
          AND belnr = @gt_bseg-belnr
          AND gjahr = @gt_bseg-gjahr
          AND buzei = @gt_bseg-buzei.

    ENDIF.

    SORT gt_bseg BY belnr bukrs gjahr.

  ENDMETHOD.


  METHOD fill_bseg.

    FIELD-SYMBOLS <fs_ref> TYPE any.
    DATA ls_bseg TYPE ty_bseg.

    LOOP AT ct_detail_it ASSIGNING FIELD-SYMBOL(<fs_det_it>).

      ASSIGN COMPONENT <fs_det_it>-name OF STRUCTURE cs_data TO <fs_ref>.
      ASSIGN COMPONENT <fs_det_it>-name OF STRUCTURE ls_bseg   TO FIELD-SYMBOL(<fs_ref_bseg>).

      IF <fs_ref_bseg> IS ASSIGNED AND <fs_ref> IS ASSIGNED.
        <fs_ref_bseg> = <fs_ref>.
      ENDIF.

    ENDLOOP.

    ls_bseg-objid = sy-mandt && ls_bseg-bukrs && ls_bseg-belnr && ls_bseg-gjahr.
    ls_bseg-tbkey = sy-mandt && ls_bseg-bukrs && ls_bseg-belnr && ls_bseg-gjahr && ls_bseg-buzei.

    APPEND ls_bseg TO gt_bseg.
    CLEAR ls_bseg.

  ENDMETHOD.


  METHOD get_doc_history.

    IF gt_bseg IS NOT INITIAL.

      SELECT * FROM zi_fi_log_doc
       INTO TABLE @gt_log
       FOR ALL ENTRIES IN @gt_bseg
       WHERE objectid = @gt_bseg-objid
         AND tabkey   = @gt_bseg-tbkey.

    ENDIF.

  ENDMETHOD.


  METHOD update_venc_orig.

    SORT gt_log BY objectid tabkey fname.

    LOOP AT ct_data ASSIGNING FIELD-SYMBOL(<fs_data>).

      ASSIGN COMPONENT 'BUKRS' OF STRUCTURE <fs_data> TO FIELD-SYMBOL(<fs_bukrs>).
      IF <fs_bukrs> IS NOT ASSIGNED.
        CONTINUE.
      ENDIF.

      ASSIGN COMPONENT 'BELNR' OF STRUCTURE <fs_data> TO FIELD-SYMBOL(<fs_belnr>).
      IF <fs_belnr> IS NOT ASSIGNED.
        CONTINUE.
      ENDIF.

      ASSIGN COMPONENT 'GJAHR' OF STRUCTURE <fs_data> TO FIELD-SYMBOL(<fs_gjahr>).
      IF <fs_gjahr> IS NOT ASSIGNED.
        CONTINUE.
      ENDIF.

      ASSIGN COMPONENT 'BUZEI' OF STRUCTURE <fs_data> TO FIELD-SYMBOL(<fs_buzei>).
      IF <fs_buzei> IS NOT ASSIGNED.
        CONTINUE.
      ENDIF.

      READ TABLE gt_bseg ASSIGNING FIELD-SYMBOL(<fs_bseg>) WITH KEY belnr = <fs_belnr>
                                                                    bukrs = <fs_bukrs>
                                                                    gjahr = <fs_gjahr>
                                                           BINARY SEARCH.

      IF sy-subrc = 0.

        ASSIGN COMPONENT 'VENC_ORIG' OF STRUCTURE <fs_data> TO FIELD-SYMBOL(<fs_venc>).
        IF <fs_venc> IS NOT ASSIGNED.
          CONTINUE.
        ENDIF.

        <fs_venc> = get_venc_orig( is_bseg = <fs_bseg> ).
        rv_venc_orig = <fs_venc>.

      ENDIF.

    ENDLOOP.

  ENDMETHOD.


  METHOD tcode_is_valid.

    CONSTANTS: lc_fi    TYPE ztca_param_par-modulo VALUE 'FI',
               lc_chave TYPE ztca_param_par-chave1 VALUE 'CAMPO NOVO'.

    DATA: lr_tcode TYPE RANGE OF sy-tcode.

    DATA(lo_param) = NEW zclca_tabela_parametros( ).

    TRY.

        lo_param->m_get_range( EXPORTING iv_modulo = lc_fi
                                         iv_chave1 = lc_chave
                               IMPORTING et_range = lr_tcode ).

        IF sy-tcode IN lr_tcode.
          rv_return = abap_true.
        ENDIF.

      CATCH zcxca_tabela_parametros.

        RETURN.

    ENDTRY.

  ENDMETHOD.


  METHOD ext_venc_orig.

    DATA: lt_data TYPE TABLE OF ty_bseg_venc.

    APPEND INITIAL LINE TO lt_data ASSIGNING FIELD-SYMBOL(<fs_data>).

    <fs_data>-belnr = iv_key-belnr.
    <fs_data>-bukrs = iv_key-bukrs.
    <fs_data>-gjahr = iv_key-gjahr.
    <fs_data>-buzei = iv_key-buzei.
    <fs_data>-netdt = iv_netdt.

    prepare_data( CHANGING ct_data = lt_data ).

    get_doc_history( ).

    rv_venc_orig = update_venc_orig( CHANGING  ct_data = lt_data ).


  ENDMETHOD.
ENDCLASS.
