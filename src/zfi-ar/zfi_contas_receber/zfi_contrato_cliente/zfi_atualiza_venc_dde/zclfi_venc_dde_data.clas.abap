CLASS zclfi_venc_dde_data DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES:
      if_amdp_marker_hdb.

    TYPES: BEGIN OF ty_param,
             bukrs       TYPE if_rap_query_filter=>tt_range_option,
             belnr       TYPE if_rap_query_filter=>tt_range_option,
             gjahr       TYPE if_rap_query_filter=>tt_range_option,
             kunnr       TYPE if_rap_query_filter=>tt_range_option,
             vbeln       TYPE if_rap_query_filter=>tt_range_option,
             vgbel       TYPE if_rap_query_filter=>tt_range_option,
             dataentrega TYPE if_rap_query_filter=>tt_range_option,
           END OF ty_param,

           ty_table TYPE STANDARD TABLE OF zc_fi_venc_dde_busca WITH EMPTY KEY.

    CLASS-DATA go_instance TYPE REF TO zclfi_venc_dde_data.

*    DATA gs_param TYPE ty_param.
    DATA gs_param TYPE zsfi_filtros_dde.

    DATA gr_bukrs        TYPE REF TO data .
    DATA gr_belnr        TYPE REF TO data .
    DATA gr_gjahr        TYPE REF TO data .
    DATA gr_kunnr        TYPE REF TO data .
    DATA gr_vbeln        TYPE REF TO data .
    DATA gr_vgbel        TYPE REF TO data .
    DATA gr_dataentrega  TYPE REF TO data .
    DATA gr_bschl        TYPE REF TO data .

    DATA: gr_diastraz TYPE RANGE OF int8,
          gr_blart    TYPE RANGE OF blart,
          gr_zlsch    TYPE RANGE OF schzw_bseg,
          gr_budat    TYPE RANGE OF bkpf-budat.

    CLASS-METHODS:
      "! Cria instancia
      get_instance
        RETURNING
          VALUE(ro_instance) TYPE REF TO zclfi_venc_dde_data .

    METHODS set_ref_data.

    METHODS:
      build
        RETURNING VALUE(rt_cockpit) TYPE ty_table .

  PROTECTED SECTION.
  PRIVATE SECTION.
    METHODS get_parametros.

ENDCLASS.



CLASS zclfi_venc_dde_data IMPLEMENTATION.
  METHOD get_instance.

    IF ( go_instance IS INITIAL ).
      go_instance = NEW zclfi_venc_dde_data( ).
    ENDIF.

    ro_instance = go_instance.

  ENDMETHOD.

  METHOD set_ref_data.

    ASSIGN gr_bukrs->*          TO FIELD-SYMBOL(<fs_bukrs>).
    ASSIGN gr_belnr->*          TO FIELD-SYMBOL(<fs_belnr>).
    ASSIGN gr_gjahr->*          TO FIELD-SYMBOL(<fs_gjahr>).
    ASSIGN gr_kunnr->*          TO FIELD-SYMBOL(<fs_kunnr>).
    ASSIGN gr_vbeln->*          TO FIELD-SYMBOL(<fs_vbeln>).
    ASSIGN gr_vgbel->*          TO FIELD-SYMBOL(<fs_vgbel>).
    ASSIGN gr_dataentrega->*    TO FIELD-SYMBOL(<fs_dataentrega>).
    ASSIGN gr_bschl->*          TO FIELD-SYMBOL(<fs_bschl>).

    IF <fs_bukrs> IS ASSIGNED.
      MOVE-CORRESPONDING <fs_bukrs> TO gs_param-bukrs[].
    ENDIF.

    IF <fs_belnr> IS ASSIGNED.
      MOVE-CORRESPONDING <fs_belnr> TO gs_param-belnr[].
    ENDIF.

    IF <fs_gjahr> IS ASSIGNED.
      MOVE-CORRESPONDING <fs_gjahr> TO gs_param-gjahr[].
    ENDIF.

    IF <fs_kunnr> IS ASSIGNED.
      MOVE-CORRESPONDING <fs_kunnr> TO gs_param-kunnr[].
    ENDIF.

    IF <fs_vbeln> IS ASSIGNED.
      MOVE-CORRESPONDING <fs_vbeln> TO gs_param-vbeln[].
    ENDIF.

    IF <fs_vgbel> IS ASSIGNED.
      MOVE-CORRESPONDING <fs_vgbel> TO gs_param-vgbel[].
    ENDIF.

    IF <fs_dataentrega> IS ASSIGNED.
      MOVE-CORRESPONDING <fs_dataentrega> TO gs_param-dataentrega[].
    ENDIF.

    IF <fs_bschl> IS ASSIGNED.
      MOVE-CORRESPONDING <fs_bschl> TO gs_param-bschl[].
    ENDIF.


    UNASSIGN <fs_bukrs>.
    UNASSIGN <fs_belnr>.
    UNASSIGN <fs_gjahr>.
    UNASSIGN <fs_kunnr>.
    UNASSIGN <fs_vbeln>.
    UNASSIGN <fs_vgbel>.
    UNASSIGN <fs_dataentrega>.
    UNASSIGN <fs_bschl>.

  ENDMETHOD.

  METHOD build.

    get_parametros(  ).

    SELECT
        bukrs, belnr, gjahr, buzei,
        kunnr, vbeln, vgbel,
        dataentrega, rootcnpj,
        companycodename, name1,
        familia, classificacao, budat,
        zuonr, gsber, xblnr, sgtxt,
        zlspr, zterm, mansp, zfbdt,
        zbd1t, zbd2t, zbd3t, dtws1,
        hbkid, xref3, stcd1, stcd2,
        bktxt, xref1_hd, xref2_hd,
        bldat, zlsch, bschl, postingkeyname
        FROM zi_fi_dde_data
        INTO TABLE @rt_cockpit
        WHERE bukrs IN @gs_param-bukrs
          AND belnr IN @gs_param-belnr
          AND gjahr IN @gs_param-gjahr
          AND kunnr IN @gs_param-kunnr
          AND vbeln IN @gs_param-vbeln
          AND vgbel IN @gs_param-vgbel
          AND bschl IN @gs_param-bschl
          AND budat IN @gr_budat
          AND zlsch IN @gr_zlsch.

  ENDMETHOD.


  METHOD get_parametros.

    CONSTANTS: lc_fi       TYPE ztca_param_par-modulo VALUE 'FI-AR',
               lc_chave1   TYPE ztca_param_par-chave1 VALUE 'ATUALIZARDDE',
               lc_chave2_a TYPE ztca_param_par-chave2 VALUE 'DIASPARATRAZ',
               lc_chave2_b TYPE ztca_param_par-chave2 VALUE 'TIPODOC',
               lc_chave2_c TYPE ztca_param_par-chave2 VALUE 'FORMADEPGTO'.

    DATA: lv_dias     TYPE i,
          lv_data_ini TYPE datum.

    DATA(lo_param) = NEW zclca_tabela_parametros( ).

    TRY.

        lo_param->m_get_single(
          EXPORTING
            iv_modulo = lc_fi
                                         iv_chave1 = lc_chave1
                                         iv_chave2 = lc_chave2_a

          IMPORTING
            ev_param  = lv_dias
        ).

        lv_dias = lv_dias * -1.

        CALL FUNCTION 'BKK_ADD_WORKINGDAY'
          EXPORTING
            i_date = sy-datum
            i_days = lv_dias
          IMPORTING
            e_date = lv_data_ini.

        gr_budat = VALUE #( ( sign = 'I'
                              option = 'EQ'
                              low = lv_data_ini
                              high = sy-datum ) ).

      CATCH zcxca_tabela_parametros.
    ENDTRY.

    TRY.
        lo_param->m_get_range( EXPORTING iv_modulo = lc_fi
                                         iv_chave1 = lc_chave1
                                         iv_chave2 = lc_chave2_b
                               IMPORTING et_range = gr_blart ).
      CATCH zcxca_tabela_parametros.
    ENDTRY.

    TRY.
        lo_param->m_get_range( EXPORTING iv_modulo = lc_fi
                                          iv_chave1 = lc_chave1
                                          iv_chave2 = lc_chave2_c
                                IMPORTING et_range = gr_zlsch ).
      CATCH zcxca_tabela_parametros.
    ENDTRY.


  ENDMETHOD.

ENDCLASS.
