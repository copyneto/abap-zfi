CLASS zclfi_retira_bloqueios DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    TYPES:
      ty_r_bukrs TYPE RANGE OF bsid_view-bukrs .
    TYPES:
      ty_r_kunnr TYPE RANGE OF bsid_view-kunnr .
    TYPES:
      BEGIN OF ty_screen,
        bukrs TYPE bsid_view-bukrs,
        kunnr TYPE bsid_view-kunnr,
        belnr TYPE bsid_view-belnr,
        buzei TYPE bsid_view-buzei,
        gjahr TYPE bsid_view-gjahr,
        xblnr TYPE bsid_view-xblnr,
        zuonr TYPE bsid_view-zuonr,
        hbkid TYPE bsid_view-hbkid,
        zlsch TYPE bsid_view-zlsch,
      END OF  ty_screen .
    TYPES:
      ty_r_belnr TYPE RANGE OF bsid_view-belnr .
    TYPES:
      ty_r_buzei TYPE RANGE OF bsid_view-buzei .
    TYPES:
      ty_r_gjahr TYPE RANGE OF bsid_view-gjahr .
    TYPES:
      ty_r_xblnr TYPE RANGE OF bsid_view-xblnr .
    TYPES:
      ty_r_zuonr TYPE RANGE OF bsid_view-zuonr .
    TYPES:
      ty_r_hbkid TYPE RANGE OF bsid_view-hbkid .
    TYPES:
      ty_r_zlsch TYPE RANGE OF bsid_view-zlsch .

    DATA gs_screen TYPE ty_screen .


    METHODS constructor
      IMPORTING
        !ir_bukrs TYPE ty_r_bukrs
        !ir_kunnr TYPE ty_r_kunnr
        !ir_belnr TYPE ty_r_belnr
        !ir_buzei TYPE ty_r_buzei
        !ir_gjahr TYPE ty_r_gjahr
        !ir_xblnr TYPE ty_r_xblnr
        !ir_zuonr TYPE ty_r_zuonr
        !ir_hbkid TYPE ty_r_hbkid
        !ir_zlsch TYPE ty_r_zlsch .
    METHODS get_report_data
      RETURNING
        VALUE(rt_data) TYPE zctgfi_retira_bloq .
    METHODS exec_unlock
      IMPORTING
        !it_data TYPE zctgfi_retira_bloq .
    METHODS process_unlock .
protected section.
private section.

  data GR_BUKRS type TY_R_BUKRS .
  data GR_KUNNR type TY_R_KUNNR .
  data GR_BELNR type TY_R_BELNR .
  data GR_BUZEI type TY_R_BUZEI .
  data GR_GJAHR type TY_R_GJAHR .
  data GR_XBLNR type TY_R_XBLNR .
  data GR_ZUONR type TY_R_ZUONR .
  data GR_HBKID type TY_R_HBKID .
  data GR_ZLSCH type TY_R_ZLSCH .

  "! <p class="shorttext synchronized" lang="pt">Módulo</p>
  constants GC_MODULO type ZE_PARAM_MODULO value 'FI' ##NO_TEXT.
  "! <p class="shorttext synchronized" lang="pt">Chave do Parâmetro 1</p>
  constants GC_CHAVE1 type ZE_PARAM_CHAVE value 'EMP2000' ##NO_TEXT.
  "! <p class="shorttext synchronized" lang="pt">Chave do Parâmetro 2</p>
  constants GC_CHAVE2 type ZE_PARAM_CHAVE value 'RET_BLOQ_FAT' ##NO_TEXT.
  "! <p class="shorttext synchronized" lang="pt">Chave do Parâmetro</p>
  constants GC_BLOQUEIO type ZE_PARAM_CHAVE_3 value 'BLOQUEIO' ##NO_TEXT.
  "! <p class="shorttext synchronized" lang="pt">Chave do Parâmetro</p>
  constants GC_HORAS type ZE_PARAM_CHAVE_3 value 'HORAS' ##NO_TEXT.
  "! <p class="shorttext synchronized" lang="pt">Chave do Parâmetro</p>
  constants GC_TIPODOC type ZE_PARAM_CHAVE_3 value 'TIPODOC' ##NO_TEXT.
  "! <p class="shorttext synchronized" lang="pt">Basis Class for Simple Tables</p>
  data GO_TABLE type ref to CL_SALV_TABLE .

 "! Metodo para seleção dos dados
  methods GET_DATA
    returning
      value(RT_RETURN) type ZCTGFI_RETIRA_BLOQ .

 "! Metodo para verificar a diferença em horas entre
 "! cpudt/cputm contra data e hora atual
  methods CHECK_HOURS_DIFF
    importing
      !IT_DATA type ZCTGFI_RETIRA_BLOQ
    returning
      value(RT_DATA) type ZCTGFI_RETIRA_BLOQ .

"! Metodo para preencher estrutura BSEG para ser utilizada na BAPI
  methods FILL_BSEG_BAPI
    importing
      !IS_DATA type ZSFI_RETIRA_BLOQ
    returning
      value(RS_BSEG) type BSEG .

"! Metodo para preencher BUZTAB
  methods FILL_BUZTAB
    importing
      !IS_DATA type ZSFI_RETIRA_BLOQ
    returning
      value(RT_RETURN) type TPIT_T_BUZTAB .

"! Metodo para preencher quais campos serão alterado pela BAPI
  methods FILL_FIELDS
    changing
      !CT_FIELDS type TPIT_T_FNAME .

"! Metodo para exibição do LOG quando o processamento for em BACKGROUND
  methods DISPLAY_LOG
    changing
      !CT_LOG type ZCTGFI_RETIRA_BLOQ .
ENDCLASS.



CLASS ZCLFI_RETIRA_BLOQUEIOS IMPLEMENTATION.


  METHOD constructor.


    gr_bukrs = ir_bukrs.
    gr_KUNNR = ir_kunnr.
    gr_BELNR = ir_belnr.
    gr_BUZEI = ir_buzei.
    gr_GJAHR = ir_gjahr.
    gr_XBLNR = ir_xblnr.
    gr_ZUONR = ir_zuonr.
    gr_HBKID = ir_hbkid.
    gr_ZLSCH = ir_zlsch.

  ENDMETHOD.


  METHOD get_data.



    DATA: lr_ZLSPR TYPE RANGE OF dzlspr,
          lr_BLART TYPE RANGE OF blart.


    DATA(lo_param) = zclca_tabela_parametros=>get_instance( ). " CHANGE - LSCHEPP - 20.07.2023

    TRY.
        lo_param->m_get_range( EXPORTING iv_modulo = me->gc_modulo
                                         iv_chave1 = me->gc_chave1
                                         iv_chave2 = me->gc_chave2
                                         iv_chave3 = me->gc_BLOQUEIO
                               IMPORTING et_range  = lr_ZLSPR ).

      CATCH zcxca_tabela_parametros.
    ENDTRY.

    TRY.
        lo_param->m_get_range( EXPORTING iv_modulo = me->gc_modulo
                                         iv_chave1 = me->gc_chave1
                                         iv_chave2 = me->gc_chave2
                                         iv_chave3 = me->gc_tipodoc
                               IMPORTING et_range  = lr_BLART ).

      CATCH zcxca_tabela_parametros.
    ENDTRY.


    SELECT a~bukrs,
           a~kunnr,
           a~belnr,
           a~buzei,
           a~gjahr,
           a~xblnr,
           a~zuonr,
           a~hbkid,
           a~zlsch,
           a~BLART,
           a~ZLSPR,
           a~BSCHL,
           a~ZTERM,
           c~NETDT,
           a~SGTXT,
           a~ZUMSK,
           a~UMSKZ,
           a~GSBER,
           a~DMBTR,
           b~BKTXT,
           b~cpudt,
           b~cputm,
           c~koart
      FROM bsid_view AS a
      INNER JOIN p_bkpf_com AS b
      ON b~bukrs EQ a~bukrs
     AND b~belnr EQ a~belnr
     AND b~gjahr EQ a~gjahr
      INNER JOIN p_bseg_com as c
      on c~bukrs EQ a~bukrs
     and c~belnr eq a~belnr
     and c~gjahr eq a~gjahr
     and c~buzei eq a~buzei

      INTO TABLE @rt_return
     WHERE a~bukrs IN @gr_bukrs
      AND a~kunnr IN @gr_KUNNR
      AND a~belnr IN @gr_BELNR
      AND a~buzei IN @gr_BUZEI
      AND a~gjahr IN @gr_GJAHR
      AND a~xblnr IN @gr_XBLNR
      AND a~zuonr IN @gr_ZUONR
      AND a~hbkid IN @gr_HBKID
      AND a~zlsch IN @gr_ZLSCH
      and a~BLART in @lr_BLART
      and a~ZLSPR in @lr_ZLSPR.


  ENDMETHOD.


  METHOD check_hours_diff.

    DATA lv_dif TYPE fahztd.

    DATA(lo_param) = zclca_tabela_parametros=>get_instance( ). " CHANGE - LSCHEPP - 20.07.2023

    DATA lr_horas TYPE RANGE OF fahztd.

    TRY.
        lo_param->m_get_range( EXPORTING iv_modulo = me->gc_modulo
                                         iv_chave1 = me->gc_chave1
                                         iv_chave2 = me->gc_chave2
                                         iv_chave3 = me->gc_horas
                               IMPORTING et_range  = lr_horas ).

      CATCH zcxca_tabela_parametros.
    ENDTRY.


    IF lr_horas IS NOT INITIAL.

      LOOP AT it_data ASSIGNING FIELD-SYMBOL(<fs_data>).

        CLEAR lv_dif.

        CALL FUNCTION 'SD_CALC_DURATION_FROM_DATETIME'
          EXPORTING
            i_date1          = <fs_data>-cpudt
            i_time1          = <fs_data>-cputm
            i_date2          = sy-datum
            i_time2          = sy-uzeit
          IMPORTING
            e_tdiff          = lv_dif
          EXCEPTIONS
            invalid_datetime = 1
            OTHERS           = 2.

        DATA(lv_cad_time_string) = |{ lr_horas[ 1 ]-low }0000|.
        DATA(lv_cad_time) = CONV fahztd( lv_cad_time_string ).
        IF sy-subrc IS INITIAL.
          IF lv_dif GT lv_cad_time.
            APPEND <fs_data> TO rt_data .
          ENDIF.
        ENDIF.

      ENDLOOP.

    ENDIF.



  ENDMETHOD.


  METHOD exec_unlock.

    DATA lt_buztab TYPE tpit_t_buztab.
    DATA lt_fldtab TYPE tpit_t_fname.
    DATA lt_errtab TYPE tpit_t_errdoc.
    DATA lt_log    TYPE TABLE OF zsfi_retira_bloq.

    IF it_data IS INITIAL
      AND sy-batch IS NOT INITIAL.
      WRITE: TEXT-001.
    ENDIF.

    LOOP AT it_data ASSIGNING FIELD-SYMBOL(<fs_data>).

      DATA(ls_bseg) = fill_bseg_bapi( <fs_data> ) .

      lt_buztab = fill_buztab(  <fs_data> ).

      fill_fields( CHANGING ct_fields = lt_fldtab ).

      DO 40 TIMES. " Equivalente a 4 segundos no máximo
        CALL FUNCTION 'ENQUEUE_EFBKPF'
          EXPORTING
            bukrs          = ls_bseg-bukrs
            belnr          = ls_bseg-belnr
            gjahr          = ls_bseg-gjahr
          EXCEPTIONS
            foreign_lock   = 1
            system_failure = 2
            OTHERS         = 3.

        IF sy-subrc IS INITIAL.

          CALL FUNCTION 'DEQUEUE_EFBKPF'
            EXPORTING
              bukrs = ls_bseg-bukrs
              belnr = ls_bseg-belnr
              gjahr = ls_bseg-gjahr.

          EXIT.
        ELSE.
          WAIT UP TO '0.1' SECONDS.
        ENDIF.
      ENDDO.

      CALL FUNCTION 'FI_ITEMS_MASS_CHANGE'
      "#EC CI_IMUD_NESTED
      "#EC CI_SEL_NESTED
        EXPORTING
          s_bseg     = ls_bseg
        IMPORTING
          errtab     = lt_errtab
        TABLES
          it_buztab  = lt_buztab
          it_fldtab  = lt_fldtab
        EXCEPTIONS
          bdc_errors = 1
          OTHERS     = 2.

      IF sy-subrc IS INITIAL
        AND sy-batch IS NOT INITIAL.

        APPEND <fs_data> TO lt_log.

      ENDIF.

      CLEAR:  lt_fldtab,  lt_buztab, ls_bseg, lt_errtab.


    ENDLOOP.

    IF lt_log IS NOT INITIAL.
      me->display_log( CHANGING ct_log = lt_log ).
    ENDIF.

  ENDMETHOD.


  METHOD get_report_data.

    DATA(lt_data) = me->get_data( ).
    rt_data = me->check_hours_diff( lt_data ).

  ENDMETHOD.


  method FILL_BSEG_BAPI.

    rs_bseg  = VALUE bseg(
        bukrs = is_data-bukrs
        belnr = is_data-belnr
        gjahr = is_data-gjahr
        buzei = is_data-buzei
        bschl = is_data-bschl
        koart = is_data-koart
        zlspr = space ).

  endmethod.


  method FILL_BUZTAB.

    APPEND INITIAL LINE TO rt_return ASSIGNING FIELD-SYMBOL(<fs_buztab>).
    <fs_buztab>-bukrs = is_data-bukrs.
    <fs_buztab>-belnr = is_data-belnr.
    <fs_buztab>-gjahr = is_data-gjahr.
    <fs_buztab>-buzei = is_data-buzei.
    <fs_buztab>-bschl = is_data-bschl.
    <fs_buztab>-koart = is_data-koart.

  endmethod.


  method FILL_FIELDS.

    FIELD-SYMBOLS <fs_field> LIKE LINE OF ct_fields.

    CLEAR ct_fields.

    APPEND INITIAL LINE TO ct_fields ASSIGNING <fs_field>.
    <fs_field>-fname = 'ZLSPR'.
    <fs_field>-aenkz = abap_true.

  endmethod.


  METHOD PROCESS_UNLOCK.

    me->exec_unlock( me->check_hours_diff( me->get_data( ) ) ).

  ENDMETHOD.


  METHOD display_log.

    DATA: lo_salv  TYPE REF TO cl_salv_table.

    TRY.

        cl_salv_table=>factory(
        EXPORTING
          list_display = abap_true
        IMPORTING
          r_salv_table = lo_salv
        CHANGING
          t_table = CT_LOG ).

        lo_salv->display( ).

      CATCH cx_salv_msg.                                "#EC NO_HANDLER
    ENDTRY.

  ENDMETHOD.
ENDCLASS.
