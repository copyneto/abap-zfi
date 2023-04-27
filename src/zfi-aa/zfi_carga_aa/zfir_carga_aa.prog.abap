***********************************************************************
***                      © 3corações                                ***
***********************************************************************
***                                                                   *
*** DESCRIÇÃO: Programa de Cargas AA                                  *
*** AUTOR    : Flavia Nunes – Meta                                    *
*** FUNCIONAL: Luiz Eduardo Quintanilha - Meta                        *
*** DATA     : 16/03/2022                                             *
***********************************************************************
*** HISTÓRICO DAS MODIFICAÇÕES                                        *
***-------------------------------------------------------------------*
*** DATA       | AUTOR               | DESCRIÇÃO                      *
***-------------------------------------------------------------------*
*** 20.04.2022 | Luís Gustavo Schepp | Ajustes finais                 *
***********************************************************************
*&--------------------------------------------------------------------*
*& Report ZFIR_CARGA_AA
*&--------------------------------------------------------------------*
*&
*&--------------------------------------------------------------------*
REPORT zfir_carga_aa.

*-Types---------------------------------------------------------------*
TYPES:BEGIN OF ty_data,
        "Início
        anln1        TYPE anla-anln1,    " Nº Imobilizado
        anln2        TYPE anla-anln2,    " Subnúmero Imobilizado
        anlkl(8)     TYPE c,             " Classe imobilizado
        bukrs(4)     TYPE c,             " Empresa
        txt50_1(50)  TYPE c,             " Denominação do imobilizado
        txt50_2(50)  TYPE c,             " Denominação do imobilizado (continuação)
        sernr(8)     TYPE c,             " Nr série
        invnr(25)    TYPE c,             " Nr Inventário
*        anlhtxt      TYPE anlh-anlhtxt,
        xhist        TYPE ra02s-xhist,   " Adm Historicamente
        aktiv(18)    TYPE c,             " Data de incorporação do imobilizado
        deakt        TYPE anla-deakt,
        gsber        TYPE anlz-gsber,    " Divisão
        kostl        TYPE anlz-kostl,    " Centro de Custo
        kostlv       TYPE anlz-kostl,    " Centro de Custo responsavel
        werks        TYPE anlz-werks,    " Centro
        xneu_am      TYPE ra02s-xneu_am, " Imob.comprado novo
        afabe_01(10) TYPE c,             " Área de avaliação efetiva (Valor Área 1)
        afasl_01(4)  TYPE c,             " Chave depreciação (1)
        ndjar_01(5)  TYPE c,             " Vida Útil em anos (1)
        ndper_01(3)  TYPE c,             " Período Vida Útil
        afabg_01(10) TYPE c,             " Data de início do cálculo da depreciação (1)
        kansw_01(15) TYPE c,             " Custos de aquisição e de produção acumulados (Valor Área 1)
        knafa_01(15) TYPE c,             " Depreciação normal acumulada (Depreciação Área 1)
        gjahr_01     TYPE gjahr,

*        gjahr_01(15) TYPE c,             " Ano Fiscal (1)
*        afabe_20(10) TYPE c,             " Área de avaliação efetiva (Valor Área 20)
*        afasl_20(4)  TYPE c,             " Chave depreciação (1)
*        ndjar_20(5)  TYPE c,             " Vida Útil em anos (1)
*        afabg_20(10) TYPE c,             " Data de início do cálculo da depreciação (1)
*        kansw_20(15) TYPE c,             " Custos de aquisição e de produção acumulados (Valor Área 20)
*        knafa_20(15) TYPE c,             " Depreciação normal acumulada (Depreciação Área 20)
*        gjahr_20(15) TYPE c,             " Ano Fiscal (20)
        "Fim
        menge(13)    TYPE c,              " Quantidade,
        meins(3)     TYPE c,              " Unidade medida,
        invzu        TYPE anla-invzu,     " Nota Inventário
        ivdat        TYPE anla-ivdat,
        inken        TYPE anla-inken,
        zugdt        TYPE anla-zugdt,
        zujhr        TYPE anla-zujhr,
        zuper        TYPE anla-zuper,
        iaufn        TYPE anlz-iaufn,
        raumn        TYPE anlz-raumn,
        kfzkz        TYPE anlz-kfzkz,
        stort        TYPE anlz-stort,
        prctr        TYPE anlz-prctr,
        segment      TYPE anlz-segment,
        xstil        TYPE anlz-xstil,
        ord41        TYPE anla-ord41,
        ord42        TYPE anla-ord42,
        ord43        TYPE anla-ord43,
        ord44        TYPE anla-ord44,
        gdlgrp       TYPE anla-gdlgrp,
        anlue        TYPE anla-anlue,
        posnr        TYPE char25,
        stadt        TYPE anla-stadt,
        gruvo        TYPE anla-gruvo,
        grein        TYPE anla-grein,
        grbnd        TYPE anla-grbnd,
        grblt        TYPE anla-grblt,
        grlfd        TYPE anla-grlfd,
        equi_sync    TYPE ra02s-equi_sync_aa,
        lifnr        TYPE anla-lifnr,
        aibn1        TYPE anla-aibn1,
        aibn2        TYPE anla-aibn2,
        herst        TYPE anla-herst,
        xgbr_am      TYPE ra02s-xgbr_am,
        vbund        TYPE anla-vbund,
        land1        TYPE anla-land1,
        typbz        TYPE anla-typbz,
*        aibn1        TYPE anla-aibn1,
*        aibn2        TYPE anla-aibn2,
        aibdt        TYPE anla-aibdt,
        urjhr(4)     TYPE c,
        urwrt(50)    TYPE c,
        leafi        TYPE anla-leafi,
        lvtnr        TYPE anla-lvtnr,
        lvdat        TYPE anla-lvdat,
        lkdat        TYPE anla-lkdat,
        leabg        TYPE anla-leabg,
        lejar        TYPE anla-lejar,
        leper        TYPE anla-leper,
        leart        TYPE anla-leart,
        lbasw(50)    TYPE c,
        lkauf(50)    TYPE c,
        letxt        TYPE anla-letxt,
        leanz(5)     TYPE c,
        lryth        TYPE anla-lryth,
        lvors        TYPE anla-lvors,
        legeb(50)    TYPE c,
        lzins(50)    TYPE c,
        lbarw(50)    TYPE c,
*        afasl_01(4)  TYPE c,            " Chave depreciação
*        ndjar_01(5)  TYPE c,            " Vida Útil em anos

*        afabg_01(10) TYPE c,            " Data de início do cálculo da depreciação
        ndabj_01(5)  TYPE c,             " Vida Útil Expirada em anos
        ndabp_01(5)  TYPE c,             " Período Vida Útil Expirada
        nafag_01(15) TYPE c,             " Valor Depreciação Normal Lançada
        afabe_10(10) TYPE c,             "
        afasl_10(4)  TYPE c,             "
        gjahr_10     TYPE gjahr,
        ndjar_10(5)  TYPE c,             " Vida Útil em anos
        ndper_10(3)  TYPE c,             " Período Vida Útil
        afabg_10(10) TYPE c,             "
        ndabj_10(5)  TYPE c,             " Vida Útil Expirada em anos
        ndabp_10(5)  TYPE c,             " Período Vida Útil Expirada
        kansw_10(15) TYPE c,             " Custos de aquisição e de produção acumulados
        knafa_10(15) TYPE c,             " Depreciação normal acumulada
        nafag_10(15) TYPE c,             " Valor Depreciação Normal Lançada
*        afasl_20(4)  TYPE c,            "
*        ndjar_20(5)  TYPE c,            " Vida Útil em anos
        ndper_20(3)  TYPE c,             " Período Vida Útil
*        afabg_20(10) TYPE c,            "
        ndabj_20(5)  TYPE c,             " Vida Útil Expirada em anos
        ndabp_20(5)  TYPE c,             " Período Vida Útil Expirada
        nafag_20(15) TYPE c,             " Valor Depreciação Normal Lançada
        afabe_30(10) TYPE c,             "
        afasl_30(4)  TYPE c,             "
        ndjar_30(5)  TYPE c,             " Vida Útil em anos
        ndper_30(3)  TYPE c,             " Período Vida Útil
        afabg_30(10) TYPE c,             "
        ndabj_30(5)  TYPE c,             " Vida Útil Expirada em anos
        ndabp_30(5)  TYPE c,             " Período Vida Útil Expirada
        kansw_30(15) TYPE c,             " Custos de aquisição e de produção acumulados
        knafa_30(15) TYPE c,             " Depreciação normal acumulada
        nafag_30(15) TYPE c,             " Valor Depreciação Normal Lançada

        afabe_11(10) TYPE c,             " Área de avaliação efetiva (Valor Área 1)
        afasl_11(4)  TYPE c,             " Chave depreciação (1)
        ndjar_11(5)  TYPE c,             " Vida Útil em anos (1)
        ndper_11(3)  TYPE c,             " Período Vida Útil
        afabg_11(10) TYPE c,             " Data de início do cálculo da depreciação (1)
        ndabj_11(3)  TYPE c,             " Vida útil expirada
        ndabp_11(3)  TYPE c,             " Período
        kansw_11(15) TYPE c,             " Custos de aquisição e de produção acumulados (Valor Área 1)
        knafa_11(15) TYPE c,             " Depreciação normal acumulada (Depreciação Área 1)
        gjahr_11     TYPE gjahr,

        afabe_31(10) TYPE c,             " Área de avaliação efetiva (Valor Área 1)
        afasl_31(4)  TYPE c,             " Chave depreciação (1)
        ndjar_31(5)  TYPE c,             " Vida Útil em anos (1)
        ndper_31(3)  TYPE c,             " Período Vida Útil
        afabg_31(10) TYPE c,             " Data de início do cálculo da depreciação (1)
        ndabj_31(3)  TYPE c,             " Vida útil expirada
        ndabp_31(3)  TYPE c,             " Período
        kansw_31(15) TYPE c,             " Custos de aquisição e de produção acumulados (Valor Área 1)
        knafa_31(15) TYPE c,             " Depreciação normal acumulada (Depreciação Área 1)
        gjahr_31     TYPE gjahr,

        afabe_34(10) TYPE c,             " Área de avaliação efetiva (Valor Área 1)
        afasl_34(4)  TYPE c,             " Chave depreciação (1)
        ndjar_34(5)  TYPE c,             " Vida Útil em anos (1)
        ndper_34(3)  TYPE c,             " Período Vida Útil
        afabg_34(10) TYPE c,             " Data de início do cálculo da depreciação (1)
        ndabj_34(3)  TYPE c,             " Vida útil expirada
        ndabp_34(3)  TYPE c,             " Período
        kansw_34(15) TYPE c,             " Custos de aquisição e de produção acumulados (Valor Área 1)
        knafa_34(15) TYPE c,             " Depreciação normal acumulada (Depreciação Área 1)
        gjahr_34     TYPE gjahr,

        afabe_80(10) TYPE c,             " Área de avaliação efetiva (Valor Área 1)
        afasl_80(4)  TYPE c,             " Chave depreciação (1)
        ndjar_80(5)  TYPE c,             " Vida Útil em anos (1)
        ndper_80(3)  TYPE c,             " Período Vida Útil
        afabg_80(10) TYPE c,             " Data de início do cálculo da depreciação (1)
        ndabj_80(3)  TYPE c,             " Vida útil expirada
        ndabp_80(3)  TYPE c,             " Período
        kansw_80(15) TYPE c,             " Custos de aquisição e de produção acumulados (Valor Área 1)
        knafa_80(15) TYPE c,             " Depreciação normal acumulada (Depreciação Área 1)
        gjahr_80     TYPE gjahr,

        afabe_82(10) TYPE c,             " Área de avaliação efetiva (Valor Área 1)
        afasl_82(4)  TYPE c,             " Chave depreciação (1)
        ndjar_82(5)  TYPE c,             " Vida Útil em anos (1)
        ndper_82(3)  TYPE c,             " Período Vida Útil
        afabg_82(10) TYPE c,             " Data de início do cálculo da depreciação (1)
        ndabj_82(3)  TYPE c,             " Vida útil expirada
        ndabp_82(3)  TYPE c,             " Período
        kansw_82(15) TYPE c,             " Custos de aquisição e de produção acumulados (Valor Área 1)
        knafa_82(15) TYPE c,             " Depreciação normal acumulada (Depreciação Área 1)
        gjahr_82     TYPE gjahr,

        afabe_84(10) TYPE c,             " Área de avaliação efetiva (Valor Área 1)
        afasl_84(4)  TYPE c,             " Chave depreciação (1)
        ndjar_84(5)  TYPE c,             " Vida Útil em anos (1)
        ndper_84(3)  TYPE c,             " Período Vida Útil
        afabg_84(10) TYPE c,             " Data de início do cálculo da depreciação (1)
        ndabj_84(3)  TYPE c,             " Vida útil expirada
        ndabp_84(3)  TYPE c,             " Período
        kansw_84(15) TYPE c,             " Custos de aquisição e de produção acumulados (Valor Área 1)
        knafa_84(15) TYPE c,             " Depreciação normal acumulada (Depreciação Área 1)
        gjahr_84     TYPE gjahr,
        linha(10)    TYPE c,

      END OF ty_data.

*-Internal tables------------------------------------------------------*
DATA: gt_split              TYPE TABLE OF string,
      gt_data               TYPE TABLE OF ty_data,
      gt_depreciationareas  TYPE TABLE OF bapi1022_dep_areas,
      gt_depreciationareasx TYPE TABLE OF bapi1022_dep_areasx,
      gt_cumulatedvalues    TYPE TABLE OF bapi1022_cumval,
      gt_return_dis         TYPE TABLE OF ZSFI_ALV_CARGA_AA,
      gt_return             TYPE TABLE OF bapiret2.

*-Work areas------------------------------------------------------*
DATA: gs_data                TYPE ty_data,
      gs_depreciationareas   TYPE bapi1022_dep_areas,
      gs_depreciationareasx  TYPE bapi1022_dep_areasx,
      gs_cumulatedvalues     TYPE bapi1022_cumval,
      gs_return_dis          TYPE ZSFI_ALV_CARGA_AA,
      gs_return              TYPE bapiret2,
      gs_key                 TYPE bapi1022_key,
      gs_reference           TYPE bapi1022_reference,
      gs_createsubnumber     TYPE bapi1022_misc-xsubno,
      gs_creategroupasset    TYPE bapi1022_misc-xanlgr,
      gs_testrun             TYPE bapi1022_misc-testrun,
      gs_generaldata         TYPE bapi1022_feglg001,
      gs_generaldatax        TYPE bapi1022_feglg001x,
      gs_inventory           TYPE bapi1022_feglg011,
      gs_inventoryx          TYPE bapi1022_feglg011x,
      gs_postinginformation  TYPE bapi1022_feglg002,
      gs_postinginformationx TYPE bapi1022_feglg002x,
      gs_timedependentdata   TYPE bapi1022_feglg003,
      gs_timedependentdatax  TYPE bapi1022_feglg003x,
      gs_allocations         TYPE bapi1022_feglg004,
      gs_allocationsx        TYPE bapi1022_feglg004x,
      gs_origin              TYPE bapi1022_feglg009,
      gs_originx             TYPE bapi1022_feglg009x,
      gs_classcont           TYPE bapi1022_feglg010,
      gs_classcontx          TYPE bapi1022_feglg010x,
      gs_leasing             TYPE bapi1022_feglg005,
      gs_leasingx            TYPE bapi1022_feglg005x,
      gs_terreno             TYPE bapi1022_feglg007,
      gs_terrenox            TYPE bapi1022_feglg007x,
      gs_line                TYPE string.

*-Global variables-----------------------------------------------------*
DATA: gv_companycode  TYPE  bapi1022_1-comp_code,
      gv_asset        TYPE  bapi1022_1-assetmaino,
      gv_subnumber    TYPE  bapi1022_1-assetsubno,
      gv_assetcreated TYPE  bapi1022_reference.

*-Screen parameters----------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-001.
  PARAMETERS: p_servi RADIOBUTTON GROUP g1 USER-COMMAND zuc_rbgrp1 DEFAULT 'X',
              p_local RADIOBUTTON GROUP g1,
              p_file   TYPE string OBLIGATORY LOWER CASE.
  SELECTION-SCREEN BEGIN OF BLOCK b2 WITH FRAME TITLE TEXT-003.
    PARAMETERS p_teste TYPE char01 AS CHECKBOX.
  SELECTION-SCREEN END OF BLOCK b2.

SELECTION-SCREEN END OF BLOCK b1.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_file.

  DATA: lv_directory  TYPE text10,
        lv_serverfile TYPE string.


  IF p_local = abap_true.
    DATA: lt_file_table TYPE filetable,
          lv_filter     TYPE string,
          lv_rc         TYPE i.

    lv_filter = TEXT-001. "Arquivos CSV (*.csv, *.CSV)|*.CSV|

    cl_gui_frontend_services=>file_open_dialog(
      EXPORTING
        file_filter             = lv_filter
      CHANGING
        file_table              = lt_file_table
        rc                      = lv_rc
      EXCEPTIONS
        file_open_dialog_failed = 1
        cntl_error              = 2
        error_no_gui            = 3
        not_supported_by_gui    = 4
        OTHERS                  = 5 ).
    IF sy-subrc EQ 0.
      IF lt_file_table IS NOT INITIAL.
        p_file = lt_file_table[ 1 ]-filename.
      ENDIF.
    ENDIF.
  ELSE.

      CALL FUNCTION '/SAPDMC/LSM_F4_SERVER_FILE'
        EXPORTING
          directory        = lv_directory
        IMPORTING
          serverfile       = lv_serverfile
        EXCEPTIONS
          canceled_by_user = 1
          error_message    = 4
          OTHERS           = 2.
      IF sy-subrc <> 0.
        MESSAGE ID sy-msgid TYPE 'I' NUMBER sy-msgno
                WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
        STOP.
      ELSE.
        IF sy-opsys = 'Windows NT'(002).
          CONCATENATE lv_serverfile '\' INTO p_file.
        ELSE.
          CONCATENATE lv_serverfile '/' INTO p_file.
        ENDIF.
      ENDIF.
  ENDIF.

*=================*
START-OF-SELECTION.
*=================*

  IF p_local = abap_true.
    cl_gui_frontend_services=>gui_upload(
      EXPORTING
        filename                = p_file
        filetype                = 'ASC'
      CHANGING
        data_tab                = gt_split
      EXCEPTIONS
        file_open_error         = 1
        file_read_error         = 2
        no_batch                = 3
        gui_refuse_filetransfer = 4
        invalid_type            = 5
        no_authority            = 6
        unknown_error           = 7
        bad_data_format         = 8
        header_not_allowed      = 9
        separator_not_allowed   = 10
        header_too_long         = 11
        unknown_dp_error        = 12
        access_denied           = 13
        dp_out_of_memory        = 14
        disk_full               = 15
        dp_timeout              = 16
        not_supported_by_gui    = 17
        error_no_gui            = 18
        OTHERS                  = 19 ).
    IF sy-subrc EQ 0.
      PERFORM f_split_data.
    ELSE.
      MESSAGE ID sy-msgid
      TYPE 'S' NUMBER sy-msgno
      WITH sy-msgv1 sy-msgv2
           sy-msgv3 sy-msgv4
      DISPLAY LIKE 'E'.
      LEAVE LIST-PROCESSING.
    ENDIF.
  ELSE.

    data(gv_tam) = strlen( p_file ).
    gv_tam = gv_tam - 1.
    if p_file+gv_tam(1) = '/'.
      p_file = p_file+0(gv_tam).
    endif.

    OPEN DATASET p_file FOR INPUT IN TEXT MODE ENCODING NON-UNICODE IGNORING CONVERSION ERRORS.
    DO.
      READ DATASET p_file INTO gs_line.
      IF NOT sy-subrc IS INITIAL.
        CLOSE DATASET p_file.
        EXIT.
      ELSE.
        APPEND gs_line TO gt_split.
      ENDIF.
    ENDDO.

    PERFORM f_split_data.

  ENDIF.

  PERFORM f_pass_data .
  PERFORM f_display_log.

*&---------------------------------------------------------------------*
*& Form F_SPLIT_DATA
*&---------------------------------------------------------------------*
FORM f_split_data .

  LOOP AT gt_split ASSIGNING FIELD-SYMBOL(<fs_split>).
    data(lv_tabix) = sy-tabix.
    CLEAR gs_data.

    IF sy-tabix GT 1.

      SPLIT <fs_split> AT ';' INTO gs_data-anln1
                                 gs_data-anln2
                                 gs_data-anlkl
                                 gs_data-bukrs
                                 gs_data-txt50_1
                                 gs_data-txt50_2
                                 gs_data-sernr
                                 gs_data-invnr
                                 gs_data-menge
                                 gs_data-meins
                                 gs_data-invzu
                                 gs_data-aktiv
                                 gs_data-deakt
                                 gs_data-gsber
                                 gs_data-kostl
                                 gs_data-kostlv
                                 gs_data-werks
                                 gs_data-stort
                                 gs_data-kfzkz
                                 gs_data-raumn
                                 gs_data-prctr
                                 gs_data-segment

                                 gs_data-ord41
                                 gs_data-ord42
                                 gs_data-ord43
                                 gs_data-ord44
                                 gs_data-gdlgrp
                                 gs_data-lifnr
                                 gs_data-aibn1
                                 gs_data-aibn2
                                 gs_data-xneu_am
                                 gs_data-posnr
                                 gs_data-stadt
                                 gs_data-gruvo
                                 gs_data-grein
                                 gs_data-grbnd
                                 gs_data-grblt
                                 gs_data-grlfd
                                 gs_data-leafi
                                 gs_data-lvtnr
                                 gs_data-lvdat
                                 gs_data-lkdat
                                 gs_data-leabg
                                 gs_data-lejar
                                 gs_data-leper

                                 gs_data-afabe_01
                                 gs_data-afasl_01
                                 gs_data-ndjar_01
                                 gs_data-ndper_01
                                 gs_data-afabg_01
                                 gs_data-ndabj_01
                                 gs_data-ndabp_01
                                 gs_data-kansw_01
                                 gs_data-knafa_01
                                 gs_data-gjahr_01

                                 gs_data-afabe_10
                                 gs_data-afasl_10
                                 gs_data-ndjar_10
                                 gs_data-ndper_10
                                 gs_data-afabg_10
                                 gs_data-ndabj_10
                                 gs_data-ndabp_10
                                 gs_data-kansw_10
                                 gs_data-knafa_10
                                 gs_data-gjahr_10

                                 gs_data-afabe_11
                                 gs_data-afasl_11
                                 gs_data-ndjar_11
                                 gs_data-ndper_11
                                 gs_data-afabg_11
                                 gs_data-ndabj_11
                                 gs_data-ndabp_11
                                 gs_data-kansw_11
                                 gs_data-knafa_11
                                 gs_data-gjahr_11

                                 gs_data-afabe_31
                                 gs_data-afasl_31
                                 gs_data-ndjar_31
                                 gs_data-ndper_31
                                 gs_data-afabg_31
                                 gs_data-ndabj_31
                                 gs_data-ndabp_31
                                 gs_data-kansw_31
                                 gs_data-knafa_31
                                 gs_data-gjahr_31

                                 gs_data-afabe_34
                                 gs_data-afasl_34
                                 gs_data-ndjar_34
                                 gs_data-ndper_34
                                 gs_data-afabg_34
                                 gs_data-ndabj_34
                                 gs_data-ndabp_34
                                 gs_data-kansw_34
                                 gs_data-knafa_34
                                 gs_data-gjahr_34

                                 gs_data-afabe_80
                                 gs_data-afasl_80
                                 gs_data-ndjar_80
                                 gs_data-ndper_80
                                 gs_data-afabg_80
                                 gs_data-ndabj_80
                                 gs_data-ndabp_80
                                 gs_data-kansw_80
                                 gs_data-knafa_80
                                 gs_data-gjahr_80

                                 gs_data-afabe_82
                                 gs_data-afasl_82
                                 gs_data-ndjar_82
                                 gs_data-ndper_82
                                 gs_data-afabg_82
                                 gs_data-ndabj_82
                                 gs_data-ndabp_82
                                 gs_data-kansw_82
                                 gs_data-knafa_82
                                 gs_data-gjahr_82

                                 gs_data-afabe_84
                                 gs_data-afasl_84
                                 gs_data-ndjar_84
                                 gs_data-ndper_84
                                 gs_data-afabg_84
                                 gs_data-ndabj_84
                                 gs_data-ndabp_84
                                 gs_data-kansw_84
                                 gs_data-knafa_84
                                 gs_data-gjahr_84.

*                                 gs_data-xhist
*                                 gs_data-afabe_01
*                                 gs_data-afasl_01
*                                 gs_data-ndjar_01
*                                 gs_data-afabg_01
*                                 gs_data-kansw_01
*                                 gs_data-knafa_01
*                                 gs_data-gjahr_01
*                                 gs_data-afabe_20
*                                 gs_data-afasl_20
*                                 gs_data-ndjar_20
*                                 gs_data-afabg_20
*                                 gs_data-kansw_20
*                                 gs_data-knafa_20
*                                 gs_data-gjahr_20.

*
*                                 gs_data-ivdat
*                                 gs_data-invzu
*                                 gs_data-inken
*                                 gs_data-zugdt
*                                 gs_data-zujhr
*                                 gs_data-zuper
*                                 gs_data-iaufn

*                                 gs_data-xstil

*                                 gs_data-prctr
*                                 gs_data-segment
*                                 gs_data-xstil
*                                 gs_data-ord41
*                                 gs_data-ord42
*                                 gs_data-ord43
*                                 gs_data-anlue
*                                 gs_data-equi_sync

*                                 gs_data-herst
*                                 gs_data-xgbr_am
*                                 gs_data-vbund
*                                 gs_data-land1
*                                 gs_data-typbz
*                                 gs_data-aibn1
*                                 gs_data-aibn2
*                                 gs_data-aibdt
*                                 gs_data-urjhr
*                                 gs_data-urwrt
*
*                                 gs_data-leart
*                                 gs_data-lbasw
*                                 gs_data-lkauf
*                                 gs_data-letxt
*                                 gs_data-leanz
*                                 gs_data-lryth
*                                 gs_data-lvors
*                                 gs_data-legeb
*                                 gs_data-lzins
*                                 gs_data-lbarw
*                                 gs_data-afasl_01
*                                 gs_data-ndjar_01
*                                 gs_data-ndper_01
*                                 gs_data-ndabj_01
*                                 gs_data-ndabp_01
*                                 gs_data-nafag_01
*                                 gs_data-afabe_10
*                                 gs_data-afasl_10
*                                 gs_data-ndjar_10
*                                 gs_data-ndper_10
*                                 gs_data-afabg_10
*                                 gs_data-ndabj_10
*                                 gs_data-ndabp_10
*                                 gs_data-kansw_10
*                                 gs_data-knafa_10
*                                 gs_data-nafag_10
*                                 gs_data-afabe_20
*                                 gs_data-afasl_20
*                                 gs_data-ndjar_20
*                                 gs_data-ndper_20
*                                 gs_data-afabg_20
*                                 gs_data-ndabj_20
*                                 gs_data-ndabp_20
*                                 gs_data-nafag_20
*                                 gs_data-afabe_30
*                                 gs_data-afasl_30
*                                 gs_data-ndjar_30
*                                 gs_data-ndper_30
*                                 gs_data-afabg_30
*                                 gs_data-ndabj_30
*                                 gs_data-ndabp_30
*                                 gs_data-kansw_30
*                                 gs_data-knafa_30
*                                 gs_data-nafag_30.

      gs_data-linha = lv_tabix.
      APPEND gs_data TO gt_data.

    ENDIF.

  ENDLOOP.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_PASS_DATA
*&---------------------------------------------------------------------*
FORM f_pass_data .

  LOOP AT gt_data INTO gs_data.

    CLEAR: gs_generaldata,
           gs_generaldatax,
           gs_depreciationareas ,
           gs_depreciationareasx,
           gs_cumulatedvalues,
           gs_reference,
           gs_createsubnumber.

    REFRESH: gt_return,
             gt_cumulatedvalues,
             gt_depreciationareasx,
             gt_depreciationareas.

    gs_key-companycode = gs_data-bukrs.
    gs_key-asset       = |{ gs_data-anln1 ALPHA = IN }|.
    gs_key-subnumber   = |{ gs_data-anln2 ALPHA = IN }|.

    IF gs_key-asset IS NOT INITIAL AND gs_key-subnumber IS NOT INITIAL.

      gs_reference-companycode = gs_key-companycode.
      gs_reference-asset = gs_key-asset.
      gs_reference-subnumber = gs_key-subnumber.

      gs_createsubnumber = abap_true.

    ENDIF.

    gs_data-anlkl = |{ gs_data-anlkl ALPHA = IN }|.

    IF gs_data-anlkl IS NOT INITIAL.
      gs_generaldata-assetclass    = gs_data-anlkl.
    ENDIF.

    gs_generaldata-descript      = gs_data-txt50_1.
    gs_generaldata-descript2     = gs_data-txt50_2.
    gs_generaldata-serial_no     = gs_data-sernr.
    gs_generaldata-quantity      = gs_data-menge.
    gs_generaldata-invent_no     = gs_data-invnr.

*    gs_generaldata-main_descript = gs_data-anlhtxt.
*    gs_generaldata-history       = gs_data-xhist.

    CALL FUNCTION 'CONVERSION_EXIT_CUNIT_INPUT'
      EXPORTING
        input          = gs_data-meins
        language       = sy-langu
      IMPORTING
        output         = gs_data-meins
      EXCEPTIONS
        unit_not_found = 1
        OTHERS         = 2.
    IF sy-subrc NE 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 INTO DATA(lv_message).
    ENDIF.

    gs_generaldata-base_uom = gs_data-meins.

    IF gs_data-anlkl IS NOT INITIAL.
      gs_generaldatax-assetclass    =  'X'.
    ENDIF.

    gs_generaldatax-descript      =  'X'.
    gs_generaldatax-descript2     =  'X'.
    gs_generaldatax-serial_no     =  'X'.
    gs_generaldatax-quantity      =  'X'.
    gs_generaldatax-base_uom      =  'X'.

*    gs_generaldatax-serial_no     =  'X'.
    gs_generaldatax-invent_no     =  'X'.
*    gs_generaldatax-quantity      =  'X'.
*    gs_generaldatax-base_uom      =  'X'.
*    gs_generaldatax-main_descript =  'X'.
*    IF NOT gs_generaldata-history IS INITIAL.
*      gs_generaldatax-history     =  'X'.
*    ENDIF.

    REPLACE ALL OCCURRENCES OF '-' IN gs_data-aktiv WITH ''.
    REPLACE ALL OCCURRENCES OF '.' IN gs_data-aktiv WITH ''.
    CONDENSE gs_data-aktiv NO-GAPS.
    IF gs_data-aktiv EQ ''.
      gs_data-aktiv = '00000000'.
    ENDIF.

    CALL FUNCTION 'CONVERT_DATE_TO_INTERNAL'
      EXPORTING
        date_external            = gs_data-aktiv
      IMPORTING
        date_internal            = gs_data-aktiv
      EXCEPTIONS
        date_external_is_invalid = 1
        OTHERS                   = 2.
    IF sy-subrc NE 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 INTO lv_message.
    ENDIF.

    REPLACE ALL OCCURRENCES OF '-' IN gs_data-deakt WITH ''.
    REPLACE ALL OCCURRENCES OF '.' IN gs_data-deakt WITH ''.
    CONDENSE gs_data-deakt NO-GAPS.
    IF gs_data-deakt EQ ''.
      gs_data-deakt = '00000000'.
    ENDIF.

    CALL FUNCTION 'CONVERT_DATE_TO_INTERNAL'
      EXPORTING
        date_external            = gs_data-deakt
      IMPORTING
        date_internal            = gs_data-deakt
      EXCEPTIONS
        date_external_is_invalid = 1
        OTHERS                   = 2.
    IF sy-subrc NE 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 INTO lv_message.
    ENDIF.

*    gs_inventory-date            = gs_data-ivdat.
    gs_inventory-note            = gs_data-invzu.
*    gs_inventory-include_in_list = gs_data-inken.
*
*    gs_inventoryx-date            = 'X'.
    gs_inventoryx-note           = 'X'.
*    gs_inventoryx-include_in_list = 'X'.

    gs_postinginformation-cap_date        = gs_data-aktiv.
    IF gs_data-deakt IS NOT INITIAL.
      gs_postinginformation-deact_date        = gs_data-deakt.
    ENDIF.
*    gs_postinginformation-initial_acq     = gs_data-zugdt.
*    gs_postinginformation-initial_acq_yr  = gs_data-zujhr.
*    gs_postinginformation-initial_acq_prd = gs_data-zuper.

    gs_postinginformationx-cap_date        = 'X'.
    IF gs_data-deakt IS NOT INITIAL.
      gs_postinginformationx-deact_date        = 'X'.
    ENDIF.
*    gs_postinginformationx-initial_acq     = 'X'.
*    gs_postinginformationx-initial_acq_yr  = 'X'.
*    gs_postinginformationx-initial_acq_prd = 'X'.

    gs_timedependentdata-costcenter = gs_data-kostl.
    gs_timedependentdata-resp_cctr = gs_data-kostlv.
    gs_timedependentdata-bus_area   = gs_data-gsber.
*    gs_timedependentdata-maint_ord  = gs_data-iaufn.
    gs_timedependentdata-plant      = gs_data-werks.
    gs_timedependentdata-location   = gs_data-stort.
    gs_timedependentdata-room       = gs_data-raumn.
    gs_timedependentdata-plate_no   = gs_data-kfzkz.
    gs_timedependentdata-segment    = gs_data-segment.
    gs_timedependentdata-profit_ctr = gs_data-prctr.

    gs_timedependentdatax-costcenter       = 'X'.
    gs_timedependentdatax-resp_cctr       = 'X'.
    gs_timedependentdatax-bus_area         = 'X'.
*    gs_timedependentdatax-maint_ord        = 'X'.
    gs_timedependentdatax-plant            = 'X'.
    gs_timedependentdatax-location         = 'X'.
    gs_timedependentdatax-room             = 'X'.
    gs_timedependentdatax-license_plate_no = 'X'.

    CONDENSE gs_timedependentdata-segment NO-GAPS.
    IF gs_timedependentdata-segment IS NOT INITIAL.
      gs_timedependentdatax-segment          = 'X'.
    ENDIF.

    CONDENSE gs_timedependentdata-profit_ctr NO-GAPS.
    IF gs_timedependentdata-profit_ctr IS NOT INITIAL.
      gs_timedependentdatax-profit_ctr       = 'X'.
    ENDIF.

    gs_allocations-evalgroup1  = gs_data-ord41.
    gs_allocations-evalgroup2  = gs_data-ord42.
    gs_allocations-evalgroup3  = gs_data-ord43.
    gs_allocations-evalgroup4  = gs_data-ord44.
    gs_allocations-evalgroup5  = gs_data-gdlgrp.
*    gs_allocations-assetsupno  = gs_data-anlue.
    gs_allocationsx-evalgroup1 = 'X'.
    gs_allocationsx-evalgroup2 = 'X'.
    gs_allocationsx-evalgroup3 = 'X'.
    gs_allocationsx-evalgroup4 = 'X'.
    gs_allocationsx-evalgroup5 = 'X'.
*    gs_allocationsx-assetsupno = 'X'.


    gs_origin-vendor_no        = gs_data-lifnr.
*    gs_origin-manufacturer     = gs_data-herst.
    gs_origin-purch_new        = gs_data-xneu_am.
*    gs_origin-country          = gs_data-land1.
*    gs_origin-type_name        = gs_data-typbz.
    gs_origin-orig_asset       = gs_data-aibn1.
    gs_origin-orig_asset_subno = gs_data-aibn2.
*    gs_origin-orig_acq_date    = gs_data-aibdt.
*    gs_origin-orig_acq_yr      = gs_data-urjhr.
*    gs_origin-orig_value       = gs_data-urwrt.
*    gs_origin-trade_id         = gs_data-vbund.

    gs_originx-vendor_no        = 'X'.
*    gs_originx-manufacturer     = 'X'.
    gs_originx-purch_new        = 'X'.
*    gs_originx-country          = 'X'.
*    gs_originx-type_name        = 'X'.
    gs_originx-orig_asset       = 'X'.
    gs_originx-orig_asset_subno = 'X'.
*    gs_originx-orig_acq_date    = 'X'.
*    gs_originx-orig_acq_year    = 'X'.
*    gs_originx-orig_value       = 'X'.
*    gs_originx-trade_id         = 'X'.



    gs_classcont-wbs_element = gs_data-posnr.
    gs_classcontx-wbs_element = 'X'.

    REPLACE ALL OCCURRENCES OF '-' IN gs_data-gruvo WITH ''.
    REPLACE ALL OCCURRENCES OF '.' IN gs_data-gruvo WITH ''.
    CONDENSE gs_data-gruvo NO-GAPS.
    IF gs_data-gruvo EQ ''.
      gs_data-gruvo = '00000000'.
    ENDIF.

    CALL FUNCTION 'CONVERT_DATE_TO_INTERNAL'
      EXPORTING
        date_external            = gs_data-gruvo
      IMPORTING
        date_internal            = gs_data-gruvo
      EXCEPTIONS
        date_external_is_invalid = 1
        OTHERS                   = 2.
    IF sy-subrc NE 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 INTO lv_message.
    ENDIF.

    REPLACE ALL OCCURRENCES OF '-' IN gs_data-grein WITH ''.
    REPLACE ALL OCCURRENCES OF '.' IN gs_data-grein WITH ''.
    CONDENSE gs_data-grein NO-GAPS.
    IF gs_data-grein EQ ''.
      gs_data-grein = '00000000'.
    ENDIF.

    CALL FUNCTION 'CONVERT_DATE_TO_INTERNAL'
      EXPORTING
        date_external            = gs_data-grein
      IMPORTING
        date_internal            = gs_data-grein
      EXCEPTIONS
        date_external_is_invalid = 1
        OTHERS                   = 2.
    IF sy-subrc NE 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 INTO lv_message.
    ENDIF.

    gs_terreno-municipality = gs_data-stadt.
    gs_terreno-lndreg_date = gs_data-gruvo.
    gs_terreno-lndreg_entry_date = gs_data-grein.
    gs_terreno-lndreg_vol = gs_data-grbnd.
    gs_terreno-lndreg_pg = gs_data-grblt.
    gs_terreno-lndreg_no = gs_data-grlfd.

    gs_terrenox-municipality = 'X'.
    gs_terrenox-lndreg_date = 'X'.
    gs_terrenox-lndreg_entry_date = 'X'.
    gs_terrenox-lndreg_vol = 'X'.
    gs_terrenox-lndreg_pg = 'X'.
    gs_terrenox-lndreg_no = 'X'.


    REPLACE ALL OCCURRENCES OF '-' IN gs_data-lvdat WITH ''.
    REPLACE ALL OCCURRENCES OF '.' IN gs_data-lvdat WITH ''.
    CONDENSE gs_data-lvdat NO-GAPS.
    IF gs_data-lvdat EQ ''.
      gs_data-lvdat = '00000000'.
    ENDIF.

    CALL FUNCTION 'CONVERT_DATE_TO_INTERNAL'
      EXPORTING
        date_external            = gs_data-lvdat
      IMPORTING
        date_internal            = gs_data-lvdat
      EXCEPTIONS
        date_external_is_invalid = 1
        OTHERS                   = 2.
    IF sy-subrc NE 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 INTO lv_message.
    ENDIF.

    REPLACE ALL OCCURRENCES OF '-' IN gs_data-lkdat WITH ''.
    REPLACE ALL OCCURRENCES OF '.' IN gs_data-lkdat WITH ''.
    CONDENSE gs_data-lkdat NO-GAPS.
    IF gs_data-lkdat EQ ''.
      gs_data-lkdat = '00000000'.
    ENDIF.

    CALL FUNCTION 'CONVERT_DATE_TO_INTERNAL'
      EXPORTING
        date_external            = gs_data-lkdat
      IMPORTING
        date_internal            = gs_data-lkdat
      EXCEPTIONS
        date_external_is_invalid = 1
        OTHERS                   = 2.
    IF sy-subrc NE 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 INTO lv_message.
    ENDIF.

    REPLACE ALL OCCURRENCES OF '-' IN gs_data-lkdat WITH ''.
    REPLACE ALL OCCURRENCES OF '.' IN gs_data-lkdat WITH ''.
    CONDENSE gs_data-lkdat NO-GAPS.
    IF gs_data-lkdat EQ ''.
      gs_data-lkdat = '00000000'.
    ENDIF.

    CALL FUNCTION 'CONVERT_DATE_TO_INTERNAL'
      EXPORTING
        date_external            = gs_data-lkdat
      IMPORTING
        date_internal            = gs_data-lkdat
      EXCEPTIONS
        date_external_is_invalid = 1
        OTHERS                   = 2.
    IF sy-subrc NE 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 INTO lv_message.
    ENDIF.

    REPLACE ALL OCCURRENCES OF '-' IN gs_data-leabg WITH ''.
    REPLACE ALL OCCURRENCES OF '.' IN gs_data-leabg WITH ''.
    CONDENSE gs_data-leabg NO-GAPS.
    IF gs_data-leabg EQ ''.
      gs_data-leabg = '00000000'.
    ENDIF.

    CALL FUNCTION 'CONVERT_DATE_TO_INTERNAL'
      EXPORTING
        date_external            = gs_data-leabg
      IMPORTING
        date_internal            = gs_data-leabg
      EXCEPTIONS
        date_external_is_invalid = 1
        OTHERS                   = 2.
    IF sy-subrc NE 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 INTO lv_message.
    ENDIF.

    gs_leasing-company    = gs_data-leafi.
    gs_leasing-agrmnt_no  = gs_data-lvtnr.
    gs_leasing-agrmntdate = gs_data-lvdat.
    gs_leasing-noticedate = gs_data-lkdat.
    gs_leasing-start_date = gs_data-leabg.
    gs_leasing-lngth_yrs  = gs_data-lejar.
    gs_leasing-lngth_prds = gs_data-leper.


*    gs_leasing-type       = gs_data-leart.
*    gs_leasing-base_value = gs_data-lbasw.
*    gs_leasing-purchprice = gs_data-lkauf.
*    gs_leasing-text       = gs_data-letxt.
*    gs_leasing-no_paymnts = gs_data-leanz.
*    gs_leasing-cycle      = gs_data-lryth.
*    gs_leasing-in_advance = gs_data-lvors.
*    gs_leasing-payment    = gs_data-legeb.
*    gs_leasing-interest   = gs_data-lzins.
*    gs_leasing-value      = gs_data-lbarw.

    gs_leasingx-company    = 'X'.
    gs_leasingx-agrmnt_no  = 'X'.
    gs_leasingx-agrmntdate = 'X'.
    gs_leasingx-noticedate = 'X'.
    gs_leasingx-start_date = 'X'.
    IF gs_leasing-lngth_yrs NE space.
      gs_leasingx-lngth_yrs  = 'X'.
    ENDIF.
    IF gs_leasing-lngth_prds NE space.
      gs_leasingx-lngth_prds = 'X'.
    ENDIF.

*    gs_leasingx-type       = 'X'.
*    gs_leasingx-base_value = 'X'.
*    gs_leasingx-purchprice = 'X'.
*    gs_leasingx-text       = 'X'.
*    gs_leasingx-no_paymnts = 'X'.
*    gs_leasingx-cycle      = 'X'.
*    gs_leasingx-in_advance = 'X'.
*    gs_leasingx-payment    = 'X'.
*    gs_leasingx-interest   = 'X'.
*    gs_leasingx-value      = 'X'.

    REPLACE ALL OCCURRENCES OF '-' IN gs_data-afabg_01 WITH ''.
    REPLACE ALL OCCURRENCES OF '.' IN gs_data-afabg_01 WITH ''.
    CONDENSE gs_data-afabg_01 NO-GAPS.
    IF gs_data-afabg_01 EQ ''.
      gs_data-afabg_01 = '00000000'.
    ENDIF.

    CALL FUNCTION 'CONVERT_DATE_TO_INTERNAL'
      EXPORTING
        date_external            = gs_data-afabg_01
      IMPORTING
        date_internal            = gs_data-afabg_01
      EXCEPTIONS
        date_external_is_invalid = 1
        OTHERS                   = 2.
    IF sy-subrc NE 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 INTO lv_message.
    ENDIF.



    UNPACK gs_data-afabe_01 TO gs_data-afabe_01.

    CLEAR gs_depreciationareas.
    gs_depreciationareas-area            = gs_data-afabe_01.
    gs_depreciationareas-dep_key         = gs_data-afasl_01.
    gs_depreciationareas-ulife_yrs       = gs_data-ndjar_01.
    gs_depreciationareas-ulife_prds      = gs_data-ndper_01.
    gs_depreciationareas-exp_ulife_yrs   = gs_data-ndabj_01.
    gs_depreciationareas-exp_ulife_prds  = gs_data-ndabp_01.
    gs_depreciationareas-odep_start_date = gs_data-afabg_01.
    APPEND gs_depreciationareas TO gt_depreciationareas.

    REPLACE ALL OCCURRENCES OF '-' IN gs_data-afabg_10 WITH ''.
    REPLACE ALL OCCURRENCES OF '.' IN gs_data-afabg_10 WITH ''.
    CONDENSE gs_data-afabg_10 NO-GAPS.
    IF gs_data-afabg_10 EQ ''.
      gs_data-afabg_10 = '00000000'.
    ENDIF.

    CALL FUNCTION 'CONVERT_DATE_TO_INTERNAL'
      EXPORTING
        date_external            = gs_data-afabg_10
      IMPORTING
        date_internal            = gs_data-afabg_10
      EXCEPTIONS
        date_external_is_invalid = 1
        OTHERS                   = 2.
    IF sy-subrc NE 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 INTO lv_message.
    ENDIF.

    IF gs_data-afabe_10 IS NOT INITIAL.
      UNPACK gs_data-afabe_10 TO gs_data-afabe_10.
      gs_depreciationareas-area            = gs_data-afabe_10.
      gs_depreciationareas-dep_key         = gs_data-afasl_10.
      gs_depreciationareas-ulife_yrs       = gs_data-ndjar_10.
      gs_depreciationareas-ulife_prds      = gs_data-ndper_10.
      gs_depreciationareas-exp_ulife_yrs   = gs_data-ndabj_10.
      gs_depreciationareas-exp_ulife_prds  = gs_data-ndabp_10.
      gs_depreciationareas-odep_start_date = gs_data-afabg_10.
      APPEND gs_depreciationareas TO gt_depreciationareas.
    ENDIF.


    REPLACE ALL OCCURRENCES OF '-' IN gs_data-afabg_11 WITH ''.
    REPLACE ALL OCCURRENCES OF '.' IN gs_data-afabg_11 WITH ''.
    CONDENSE gs_data-afabg_11 NO-GAPS.
    IF gs_data-afabg_11 EQ ''.
      gs_data-afabg_11 = '00000000'.
    ENDIF.
    CALL FUNCTION 'CONVERT_DATE_TO_INTERNAL'
      EXPORTING
        date_external            = gs_data-afabg_11
      IMPORTING
        date_internal            = gs_data-afabg_11
      EXCEPTIONS
        date_external_is_invalid = 1
        OTHERS                   = 2.
    IF sy-subrc NE 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 INTO lv_message.
    ENDIF.

    IF gs_data-afabe_11 IS NOT INITIAL.
      UNPACK gs_data-afabe_11 TO gs_data-afabe_11.
      gs_depreciationareas-area            = gs_data-afabe_11.
      gs_depreciationareas-dep_key         = gs_data-afasl_11.
      gs_depreciationareas-ulife_yrs       = gs_data-ndjar_11.
      gs_depreciationareas-ulife_prds      = gs_data-ndper_11.
      gs_depreciationareas-exp_ulife_yrs   = gs_data-ndabj_11.
      gs_depreciationareas-exp_ulife_prds  = gs_data-ndabp_11.
      gs_depreciationareas-odep_start_date = gs_data-afabg_11.
      APPEND gs_depreciationareas TO gt_depreciationareas.
    ENDIF.

    REPLACE ALL OCCURRENCES OF '-' IN gs_data-afabg_31 WITH ''.
    REPLACE ALL OCCURRENCES OF '.' IN gs_data-afabg_31 WITH ''.
    CONDENSE gs_data-afabg_31 NO-GAPS.
    IF gs_data-afabg_31 EQ ''.
      gs_data-afabg_31 = '00000000'.
    ENDIF.
    CALL FUNCTION 'CONVERT_DATE_TO_INTERNAL'
      EXPORTING
        date_external            = gs_data-afabg_31
      IMPORTING
        date_internal            = gs_data-afabg_31
      EXCEPTIONS
        date_external_is_invalid = 1
        OTHERS                   = 2.
    IF sy-subrc NE 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 INTO lv_message.
    ENDIF.

    IF gs_data-afabe_31 IS NOT INITIAL.
      UNPACK gs_data-afabe_31 TO gs_data-afabe_31.
      gs_depreciationareas-area            = gs_data-afabe_31.
      gs_depreciationareas-dep_key         = gs_data-afasl_31.
      gs_depreciationareas-ulife_yrs       = gs_data-ndjar_31.
      gs_depreciationareas-ulife_prds      = gs_data-ndper_31.
      gs_depreciationareas-exp_ulife_yrs   = gs_data-ndabj_31.
      gs_depreciationareas-exp_ulife_prds  = gs_data-ndabp_31.
      gs_depreciationareas-odep_start_date = gs_data-afabg_31.
      APPEND gs_depreciationareas TO gt_depreciationareas.
    ENDIF.

    REPLACE ALL OCCURRENCES OF '-' IN gs_data-afabg_34 WITH ''.
    REPLACE ALL OCCURRENCES OF '.' IN gs_data-afabg_34 WITH ''.
    CONDENSE gs_data-afabg_34 NO-GAPS.
    IF gs_data-afabg_34 EQ ''.
      gs_data-afabg_34 = '00000000'.
    ENDIF.
    CALL FUNCTION 'CONVERT_DATE_TO_INTERNAL'
      EXPORTING
        date_external            = gs_data-afabg_34
      IMPORTING
        date_internal            = gs_data-afabg_34
      EXCEPTIONS
        date_external_is_invalid = 1
        OTHERS                   = 2.
    IF sy-subrc NE 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 INTO lv_message.
    ENDIF.

    IF gs_data-afabe_34 IS NOT INITIAL.
      UNPACK gs_data-afabe_34 TO gs_data-afabe_34.
      gs_depreciationareas-area            = gs_data-afabe_34.
      gs_depreciationareas-dep_key         = gs_data-afasl_34.
      gs_depreciationareas-ulife_yrs       = gs_data-ndjar_34.
      gs_depreciationareas-ulife_prds      = gs_data-ndper_34.
      gs_depreciationareas-exp_ulife_yrs   = gs_data-ndabj_34.
      gs_depreciationareas-exp_ulife_prds  = gs_data-ndabp_34.
      gs_depreciationareas-odep_start_date = gs_data-afabg_34.
      APPEND gs_depreciationareas TO gt_depreciationareas.
    ENDIF.

    REPLACE ALL OCCURRENCES OF '-' IN gs_data-afabg_80 WITH ''.
    REPLACE ALL OCCURRENCES OF '.' IN gs_data-afabg_80 WITH ''.
    CONDENSE gs_data-afabg_80 NO-GAPS.
    IF gs_data-afabg_80 EQ ''.
      gs_data-afabg_80 = '00000000'.
    ENDIF.
    CALL FUNCTION 'CONVERT_DATE_TO_INTERNAL'
      EXPORTING
        date_external            = gs_data-afabg_80
      IMPORTING
        date_internal            = gs_data-afabg_80
      EXCEPTIONS
        date_external_is_invalid = 1
        OTHERS                   = 2.
    IF sy-subrc NE 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 INTO lv_message.
    ENDIF.

    IF gs_data-afabe_80 IS NOT INITIAL.
      UNPACK gs_data-afabe_80 TO gs_data-afabe_80.
      gs_depreciationareas-area            = gs_data-afabe_80.
      gs_depreciationareas-dep_key         = gs_data-afasl_80.
      gs_depreciationareas-ulife_yrs       = gs_data-ndjar_80.
      gs_depreciationareas-ulife_prds      = gs_data-ndper_80.
      gs_depreciationareas-exp_ulife_yrs   = gs_data-ndabj_80.
      gs_depreciationareas-exp_ulife_prds  = gs_data-ndabp_80.
      gs_depreciationareas-odep_start_date = gs_data-afabg_80.
      APPEND gs_depreciationareas TO gt_depreciationareas.
    ENDIF.

    REPLACE ALL OCCURRENCES OF '-' IN gs_data-afabg_82 WITH ''.
    REPLACE ALL OCCURRENCES OF '.' IN gs_data-afabg_82 WITH ''.
    CONDENSE gs_data-afabg_82 NO-GAPS.
    IF gs_data-afabg_82 EQ ''.
      gs_data-afabg_82 = '00000000'.
    ENDIF.
    CALL FUNCTION 'CONVERT_DATE_TO_INTERNAL'
      EXPORTING
        date_external            = gs_data-afabg_82
      IMPORTING
        date_internal            = gs_data-afabg_82
      EXCEPTIONS
        date_external_is_invalid = 1
        OTHERS                   = 2.
    IF sy-subrc NE 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 INTO lv_message.
    ENDIF.

    IF gs_data-afabe_82 IS NOT INITIAL.
      UNPACK gs_data-afabe_82 TO gs_data-afabe_82.
      gs_depreciationareas-area            = gs_data-afabe_82.
      gs_depreciationareas-dep_key         = gs_data-afasl_82.
      gs_depreciationareas-ulife_yrs       = gs_data-ndjar_82.
      gs_depreciationareas-ulife_prds      = gs_data-ndper_82.
      gs_depreciationareas-exp_ulife_yrs   = gs_data-ndabj_82.
      gs_depreciationareas-exp_ulife_prds  = gs_data-ndabp_82.
      gs_depreciationareas-odep_start_date = gs_data-afabg_82.
      APPEND gs_depreciationareas TO gt_depreciationareas.
    ENDIF.

    REPLACE ALL OCCURRENCES OF '-' IN gs_data-afabg_84 WITH ''.
    REPLACE ALL OCCURRENCES OF '.' IN gs_data-afabg_84 WITH ''.
    CONDENSE gs_data-afabg_84 NO-GAPS.
    IF gs_data-afabg_84 EQ ''.
      gs_data-afabg_84 = '00000000'.
    ENDIF.
    CALL FUNCTION 'CONVERT_DATE_TO_INTERNAL'
      EXPORTING
        date_external            = gs_data-afabg_84
      IMPORTING
        date_internal            = gs_data-afabg_84
      EXCEPTIONS
        date_external_is_invalid = 1
        OTHERS                   = 2.
    IF sy-subrc NE 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 INTO lv_message.
    ENDIF.

    IF gs_data-afabe_84 IS NOT INITIAL.
      UNPACK gs_data-afabe_84 TO gs_data-afabe_84.
      gs_depreciationareas-area            = gs_data-afabe_84.
      gs_depreciationareas-dep_key         = gs_data-afasl_84.
      gs_depreciationareas-ulife_yrs       = gs_data-ndjar_84.
      gs_depreciationareas-ulife_prds      = gs_data-ndper_84.
      gs_depreciationareas-exp_ulife_yrs   = gs_data-ndabj_84.
      gs_depreciationareas-exp_ulife_prds  = gs_data-ndabp_84.
      gs_depreciationareas-odep_start_date = gs_data-afabg_84.
      APPEND gs_depreciationareas TO gt_depreciationareas.
    ENDIF.

    CLEAR gs_depreciationareasx.
    gs_depreciationareasx-area            = gs_data-afabe_01.
    gs_depreciationareasx-dep_key         =  'X'.
    gs_depreciationareasx-ulife_yrs       =  'X'.
    gs_depreciationareasx-ulife_prds      =  'X'.
    gs_depreciationareasx-exp_ulife_yrs   =  'X'.
    gs_depreciationareasx-exp_ulife_prds  =  'X'.
    gs_depreciationareasx-odep_start_date =  'X'.
    APPEND gs_depreciationareasx TO gt_depreciationareasx.

    IF gs_data-afabe_10 IS NOT INITIAL.
      gs_depreciationareasx-area            = gs_data-afabe_10.
      gs_depreciationareasx-dep_key         =  'X'.
      gs_depreciationareasx-ulife_yrs       =  'X'.
      gs_depreciationareasx-ulife_prds      =  'X'.
      gs_depreciationareasx-exp_ulife_yrs   =  'X'.
      gs_depreciationareasx-exp_ulife_prds  =  'X'.
      gs_depreciationareasx-odep_start_date =  'X'.
      APPEND gs_depreciationareasx TO gt_depreciationareasx.
    ENDIF.

    IF gs_data-afabe_11 IS NOT INITIAL.
      gs_depreciationareasx-area            = gs_data-afabe_11.
      gs_depreciationareasx-dep_key         =  'X'.
      gs_depreciationareasx-ulife_yrs       =  'X'.
      gs_depreciationareasx-ulife_prds      =  'X'.
      gs_depreciationareasx-exp_ulife_yrs   =  'X'.
      gs_depreciationareasx-exp_ulife_prds  =  'X'.
      gs_depreciationareasx-odep_start_date =  'X'.
      APPEND gs_depreciationareasx TO gt_depreciationareasx.
    ENDIF.

    IF gs_data-afabe_31 IS NOT INITIAL.
      gs_depreciationareasx-area            = gs_data-afabe_31.
      gs_depreciationareasx-dep_key         =  'X'.
      gs_depreciationareasx-ulife_yrs       =  'X'.
      gs_depreciationareasx-ulife_prds      =  'X'.
      gs_depreciationareasx-exp_ulife_yrs   =  'X'.
      gs_depreciationareasx-exp_ulife_prds  =  'X'.
      gs_depreciationareasx-odep_start_date =  'X'.
      APPEND gs_depreciationareasx TO gt_depreciationareasx.
    ENDIF.

    IF gs_data-afabe_34 IS NOT INITIAL.
      gs_depreciationareasx-area            = gs_data-afabe_34.
      gs_depreciationareasx-dep_key         =  'X'.
      gs_depreciationareasx-ulife_yrs       =  'X'.
      gs_depreciationareasx-ulife_prds      =  'X'.
      gs_depreciationareasx-exp_ulife_yrs   =  'X'.
      gs_depreciationareasx-exp_ulife_prds  =  'X'.
      gs_depreciationareasx-odep_start_date =  'X'.
      APPEND gs_depreciationareasx TO gt_depreciationareasx.
    ENDIF.

    IF gs_data-afabe_80 IS NOT INITIAL.
      gs_depreciationareasx-area            = gs_data-afabe_80.
      gs_depreciationareasx-dep_key         =  'X'.
      gs_depreciationareasx-ulife_yrs       =  'X'.
      gs_depreciationareasx-ulife_prds      =  'X'.
      gs_depreciationareasx-exp_ulife_yrs   =  'X'.
      gs_depreciationareasx-exp_ulife_prds  =  'X'.
      gs_depreciationareasx-odep_start_date =  'X'.
      APPEND gs_depreciationareasx TO gt_depreciationareasx.
    ENDIF.

    IF gs_data-afabe_82 IS NOT INITIAL.
      gs_depreciationareasx-area            = gs_data-afabe_82.
      gs_depreciationareasx-dep_key         =  'X'.
      gs_depreciationareasx-ulife_yrs       =  'X'.
      gs_depreciationareasx-ulife_prds      =  'X'.
      gs_depreciationareasx-exp_ulife_yrs   =  'X'.
      gs_depreciationareasx-exp_ulife_prds  =  'X'.
      gs_depreciationareasx-odep_start_date =  'X'.
      APPEND gs_depreciationareasx TO gt_depreciationareasx.
    ENDIF.

    IF gs_data-afabe_84 IS NOT INITIAL.
      gs_depreciationareasx-area            = gs_data-afabe_84.
      gs_depreciationareasx-dep_key         =  'X'.
      gs_depreciationareasx-ulife_yrs       =  'X'.
      gs_depreciationareasx-ulife_prds      =  'X'.
      gs_depreciationareasx-exp_ulife_yrs   =  'X'.
      gs_depreciationareasx-exp_ulife_prds  =  'X'.
      gs_depreciationareasx-odep_start_date =  'X'.
      APPEND gs_depreciationareasx TO gt_depreciationareasx.
    ENDIF.


*    CALL FUNCTION 'CONVERT_DATE_TO_INTERNAL'
*      EXPORTING
*        date_external            = gs_data-afabg_20
*      IMPORTING
*        date_internal            = gs_data-afabg_20
*      EXCEPTIONS
*        date_external_is_invalid = 1
*        OTHERS                   = 2.
*
*    CLEAR gs_depreciationareas.
*    gs_depreciationareas-area            = gs_data-afabe_20.
*    gs_depreciationareas-dep_key         = gs_data-afasl_20.
*    gs_depreciationareas-ulife_yrs       = gs_data-ndjar_20.
*    gs_depreciationareas-odep_start_date = gs_data-afabg_20.
*    APPEND gs_depreciationareas TO gt_depreciationareas.
*
*    IF gs_data-afabe_20 IS NOT INITIAL.
*      CLEAR gs_depreciationareasx.
*      gs_depreciationareasx-area            = gs_data-afabe_20.
*      gs_depreciationareasx-dep_key         =  'X'.
*      gs_depreciationareasx-ulife_yrs       =  'X'.
*      gs_depreciationareasx-odep_start_date =  'X'.
*      APPEND gs_depreciationareasx TO gt_depreciationareasx.
*    ENDIF.

    CLEAR gs_cumulatedvalues.
    gs_cumulatedvalues-area      = gs_data-afabe_01.
    REPLACE ALL OCCURRENCES OF '.' IN gs_data-kansw_01 WITH space.
    REPLACE ALL OCCURRENCES OF ',' IN gs_data-kansw_01 WITH '.'.
    CONDENSE gs_data-kansw_01 NO-GAPS.
    REPLACE ALL OCCURRENCES OF '.' IN gs_data-knafa_01 WITH space.
    REPLACE ALL OCCURRENCES OF ',' IN gs_data-knafa_01 WITH '.'.
    CONDENSE gs_data-knafa_01 NO-GAPS.
    gs_cumulatedvalues-fisc_year = gs_data-gjahr_01.
    gs_cumulatedvalues-acq_value = gs_data-kansw_01.
    gs_cumulatedvalues-ord_dep = gs_data-knafa_01.
*    Card 4308 - Ajuste depreciação positiva
*    IF gs_data-knafa_01 GE 0.
*      gs_data-knafa_01 = gs_data-knafa_01 * -1.
*
*    ELSE.
*      gs_cumulatedvalues-ord_dep = gs_data-knafa_01.
*    ENDIF.
    gs_cumulatedvalues-currency = 'BRL'.

    APPEND gs_cumulatedvalues TO gt_cumulatedvalues.

*    IF gs_data-afabe_10 IS NOT INITIAL.
*
*      gs_cumulatedvalues-area      =  gs_data-afabe_10.
*      gs_cumulatedvalues-acq_value =  gs_data-kansw_10.
*
*      IF gs_data-knafa_10 GE 0.
*        gs_data-knafa_10 = gs_data-knafa_10 * -1.
*        gs_cumulatedvalues-ord_dep = gs_data-knafa_10.
*      ELSE.
*        gs_cumulatedvalues-ord_dep = gs_data-knafa_10.
*      ENDIF.
*      APPEND gs_cumulatedvalues TO gt_cumulatedvalues.
*    ENDIF.

*    REPLACE ALL OCCURRENCES OF '.' IN gs_data-kansw_20 WITH space.
*    REPLACE ALL OCCURRENCES OF ',' IN gs_data-kansw_20 WITH '.'.
*    CONDENSE gs_data-kansw_20 NO-GAPS.
*    REPLACE ALL OCCURRENCES OF '.' IN gs_data-knafa_20 WITH space.
*    REPLACE ALL OCCURRENCES OF ',' IN gs_data-knafa_20 WITH '.'.
*    CONDENSE gs_data-knafa_20 NO-GAPS.
*    CLEAR gs_cumulatedvalues.
*    gs_cumulatedvalues-fisc_year = gs_data-gjahr_20.
*    gs_cumulatedvalues-area      = gs_data-afabe_20.
*    gs_cumulatedvalues-acq_value = gs_data-kansw_20.
*    IF gs_data-knafa_20 GE 0.
*      gs_data-knafa_20 = gs_data-knafa_20 * -1.
*      gs_cumulatedvalues-ord_dep = gs_data-knafa_20.
*    ELSE.
*      gs_cumulatedvalues-ord_dep = gs_data-knafa_20.
*    ENDIF.
*    gs_cumulatedvalues-currency = 'BRL'.
*    APPEND gs_cumulatedvalues TO gt_cumulatedvalues.

    IF gs_data-afabe_10 IS NOT INITIAL.
      REPLACE ALL OCCURRENCES OF '.' IN gs_data-kansw_10 WITH space.
      REPLACE ALL OCCURRENCES OF ',' IN gs_data-kansw_10 WITH '.'.
      CONDENSE gs_data-kansw_10 NO-GAPS.
      REPLACE ALL OCCURRENCES OF '.' IN gs_data-knafa_10 WITH space.
      REPLACE ALL OCCURRENCES OF ',' IN gs_data-knafa_10 WITH '.'.
      CONDENSE gs_data-knafa_10 NO-GAPS.
      CLEAR gs_cumulatedvalues.
      gs_cumulatedvalues-fisc_year = gs_data-gjahr_10.
      gs_cumulatedvalues-area      = gs_data-afabe_10.
      gs_cumulatedvalues-acq_value = gs_data-kansw_10.
*      IF gs_data-knafa_10 GE 0.
*        gs_data-knafa_10 = gs_data-knafa_10 * -1.
*        gs_cumulatedvalues-ord_dep = gs_data-knafa_10.
*      ELSE.
*        gs_cumulatedvalues-ord_dep = gs_data-knafa_10.
*      ENDIF.
      gs_cumulatedvalues-ord_dep = gs_data-knafa_10.
      gs_cumulatedvalues-currency = 'BRL'.
      APPEND gs_cumulatedvalues TO gt_cumulatedvalues.
    ENDIF.

    IF gs_data-afabe_11 IS NOT INITIAL.
      REPLACE ALL OCCURRENCES OF '.' IN gs_data-kansw_11 WITH space.
      REPLACE ALL OCCURRENCES OF ',' IN gs_data-kansw_11 WITH '.'.
      CONDENSE gs_data-kansw_11 NO-GAPS.
      REPLACE ALL OCCURRENCES OF '.' IN gs_data-knafa_11 WITH space.
      REPLACE ALL OCCURRENCES OF ',' IN gs_data-knafa_11 WITH '.'.
      CONDENSE gs_data-knafa_11 NO-GAPS.
      CLEAR gs_cumulatedvalues.
      gs_cumulatedvalues-fisc_year = gs_data-gjahr_11.
      gs_cumulatedvalues-area      = gs_data-afabe_11.
      gs_cumulatedvalues-acq_value = gs_data-kansw_11.
      gs_cumulatedvalues-ord_dep = gs_data-knafa_11.
*      IF gs_data-knafa_11 GE 0.
*        gs_data-knafa_11 = gs_data-knafa_11 * -1.
*        gs_cumulatedvalues-ord_dep = gs_data-knafa_11.
*      ELSE.
*        gs_cumulatedvalues-ord_dep = gs_data-knafa_11.
*      ENDIF.
      gs_cumulatedvalues-currency = 'BRL'.
      APPEND gs_cumulatedvalues TO gt_cumulatedvalues.
    ENDIF.

    IF gs_data-afabe_31 IS NOT INITIAL.
      REPLACE ALL OCCURRENCES OF '.' IN gs_data-kansw_31 WITH space.
      REPLACE ALL OCCURRENCES OF ',' IN gs_data-kansw_31 WITH '.'.
      CONDENSE gs_data-kansw_31 NO-GAPS.
      REPLACE ALL OCCURRENCES OF '.' IN gs_data-knafa_31 WITH space.
      REPLACE ALL OCCURRENCES OF ',' IN gs_data-knafa_31 WITH '.'.
      CONDENSE gs_data-knafa_31 NO-GAPS.
      CLEAR gs_cumulatedvalues.
      gs_cumulatedvalues-fisc_year = gs_data-gjahr_31.
      gs_cumulatedvalues-area      = gs_data-afabe_31.
      gs_cumulatedvalues-acq_value = gs_data-kansw_31.
      gs_cumulatedvalues-ord_dep = gs_data-knafa_31.
*      IF gs_data-knafa_31 GE 0.
*        gs_data-knafa_31 = gs_data-knafa_31 * -1.
*        gs_cumulatedvalues-ord_dep = gs_data-knafa_31.
*      ELSE.
*        gs_cumulatedvalues-ord_dep = gs_data-knafa_31.
*      ENDIF.
      gs_cumulatedvalues-currency = 'BRL'.
      APPEND gs_cumulatedvalues TO gt_cumulatedvalues.
    ENDIF.

    IF gs_data-afabe_34 IS NOT INITIAL.
      REPLACE ALL OCCURRENCES OF '.' IN gs_data-kansw_34 WITH space.
      REPLACE ALL OCCURRENCES OF ',' IN gs_data-kansw_34 WITH '.'.
      CONDENSE gs_data-kansw_34 NO-GAPS.
      REPLACE ALL OCCURRENCES OF '.' IN gs_data-knafa_34 WITH space.
      REPLACE ALL OCCURRENCES OF ',' IN gs_data-knafa_34 WITH '.'.
      CONDENSE gs_data-knafa_34 NO-GAPS.
      CLEAR gs_cumulatedvalues.
      gs_cumulatedvalues-fisc_year = gs_data-gjahr_34.
      gs_cumulatedvalues-area      = gs_data-afabe_34.
      gs_cumulatedvalues-acq_value = gs_data-kansw_34.
      gs_cumulatedvalues-ord_dep = gs_data-knafa_34.
*      IF gs_data-knafa_34 GE 0.
*        gs_data-knafa_34 = gs_data-knafa_34 * -1.
*        gs_cumulatedvalues-ord_dep = gs_data-knafa_34.
*      ELSE.
*        gs_cumulatedvalues-ord_dep = gs_data-knafa_34.
*      ENDIF.
      gs_cumulatedvalues-currency = 'BRL'.
      APPEND gs_cumulatedvalues TO gt_cumulatedvalues.
    ENDIF.

    IF gs_data-afabe_80 IS NOT INITIAL.
      REPLACE ALL OCCURRENCES OF '.' IN gs_data-kansw_80 WITH space.
      REPLACE ALL OCCURRENCES OF ',' IN gs_data-kansw_80 WITH '.'.
      CONDENSE gs_data-kansw_80 NO-GAPS.
      REPLACE ALL OCCURRENCES OF '.' IN gs_data-knafa_80 WITH space.
      REPLACE ALL OCCURRENCES OF ',' IN gs_data-knafa_80 WITH '.'.
      CONDENSE gs_data-knafa_80 NO-GAPS.
      CLEAR gs_cumulatedvalues.
      gs_cumulatedvalues-fisc_year = gs_data-gjahr_80.
      gs_cumulatedvalues-area      = gs_data-afabe_80.
      gs_cumulatedvalues-acq_value = gs_data-kansw_80.
      gs_cumulatedvalues-ord_dep = gs_data-knafa_80.
*      IF gs_data-knafa_80 GE 0.
*        gs_data-knafa_80 = gs_data-knafa_80 * -1.
*        gs_cumulatedvalues-ord_dep = gs_data-knafa_80.
*      ELSE.
*        gs_cumulatedvalues-ord_dep = gs_data-knafa_80.
*      ENDIF.
      gs_cumulatedvalues-currency = 'BRL'.
      APPEND gs_cumulatedvalues TO gt_cumulatedvalues.
    ENDIF.

    IF gs_data-afabe_82 IS NOT INITIAL.
      REPLACE ALL OCCURRENCES OF '.' IN gs_data-kansw_82 WITH space.
      REPLACE ALL OCCURRENCES OF ',' IN gs_data-kansw_82 WITH '.'.
      CONDENSE gs_data-kansw_82 NO-GAPS.
      REPLACE ALL OCCURRENCES OF '.' IN gs_data-knafa_82 WITH space.
      REPLACE ALL OCCURRENCES OF ',' IN gs_data-knafa_82 WITH '.'.
      CONDENSE gs_data-knafa_82 NO-GAPS.
      CLEAR gs_cumulatedvalues.
      gs_cumulatedvalues-fisc_year = gs_data-gjahr_82.
      gs_cumulatedvalues-area      = gs_data-afabe_82.
      gs_cumulatedvalues-acq_value = gs_data-kansw_82.
      gs_cumulatedvalues-ord_dep = gs_data-knafa_82.
*      IF gs_data-knafa_82 GE 0.
*        gs_data-knafa_82 = gs_data-knafa_82 * -1.
*        gs_cumulatedvalues-ord_dep = gs_data-knafa_82.
*      ELSE.
*        gs_cumulatedvalues-ord_dep = gs_data-knafa_82.
*      ENDIF.
      gs_cumulatedvalues-currency = 'BRL'.
      APPEND gs_cumulatedvalues TO gt_cumulatedvalues.
    ENDIF.

    IF gs_data-afabe_84 IS NOT INITIAL.
      REPLACE ALL OCCURRENCES OF '.' IN gs_data-kansw_84 WITH space.
      REPLACE ALL OCCURRENCES OF ',' IN gs_data-kansw_84 WITH '.'.
      CONDENSE gs_data-kansw_84 NO-GAPS.
      REPLACE ALL OCCURRENCES OF '.' IN gs_data-knafa_84 WITH space.
      REPLACE ALL OCCURRENCES OF ',' IN gs_data-knafa_84 WITH '.'.
      CONDENSE gs_data-knafa_84 NO-GAPS.
      CLEAR gs_cumulatedvalues.
      gs_cumulatedvalues-fisc_year = gs_data-gjahr_84.
      gs_cumulatedvalues-area      = gs_data-afabe_84.
      gs_cumulatedvalues-acq_value = gs_data-kansw_84.
      gs_cumulatedvalues-ord_dep = gs_data-knafa_84.
*      IF gs_data-knafa_84 GE 0.
*        gs_data-knafa_84 = gs_data-knafa_84 * -1.
*        gs_cumulatedvalues-ord_dep = gs_data-knafa_84.
*      ELSE.
*        gs_cumulatedvalues-ord_dep = gs_data-knafa_84.
*      ENDIF.
      gs_cumulatedvalues-currency = 'BRL'.
      APPEND gs_cumulatedvalues TO gt_cumulatedvalues.
    ENDIF.

    PERFORM f_post_bapi.

  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form F_POST_BAPI
*&---------------------------------------------------------------------*
FORM f_post_bapi .

  CALL FUNCTION 'BAPI_FIXEDASSET_OVRTAKE_CREATE'
    EXPORTING
      key                  = gs_key
      reference            = gs_reference
      createsubnumber      = gs_createsubnumber
      generaldata          = gs_generaldata
      generaldatax         = gs_generaldatax
      inventory            = gs_inventory
      inventoryx           = gs_inventoryx
      postinginformation   = gs_postinginformation
      postinginformationx  = gs_postinginformationx
      timedependentdata    = gs_timedependentdata
      timedependentdatax   = gs_timedependentdatax
      allocations          = gs_allocations
      allocationsx         = gs_allocationsx
      origin               = gs_origin
      originx              = gs_originx
      leasing              = gs_leasing
      leasingx             = gs_leasingx
      investacctassignmnt  = gs_classcont
      investacctassignmntx = gs_classcontx
      realestate           = gs_terreno
      realestatex          = gs_terrenox
      TESTRUN              = p_teste
    IMPORTING
      companycode          = gv_companycode
      asset                = gv_asset
      subnumber            = gv_subnumber
      assetcreated         = gv_assetcreated
    TABLES
      depreciationareas    = gt_depreciationareas
      depreciationareasx   = gt_depreciationareasx
      cumulatedvalues      = gt_cumulatedvalues
      return               = gt_return.

  LOOP AT gt_return INTO gs_return.

    IF gs_return-type EQ 'E'.

      gs_return_dis = CORRESPONDING #( gs_return ).
      gs_return_dis-anln1 = gs_data-anln1.
      gs_return_dis-anln2 = gs_data-anln2.
      gs_return_dis-linha = gs_data-linha.

      APPEND gs_return_dis TO gt_return_dis.
      CLEAR gs_return_dis.

    ELSEIF gs_return-type EQ 'S'.

      gs_return_dis = CORRESPONDING #( gs_return ).
      gs_return_dis-anln1 = gs_data-anln1.
      gs_return_dis-anln2 = gs_data-anln2.
      gs_return_dis-linha = gs_data-linha.
      APPEND gs_return_dis TO gt_return_dis.
      CLEAR gs_return_dis.

      CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
        EXPORTING
          wait = abap_true.

    ENDIF.

  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form F_DISPLAY_LOG
*&---------------------------------------------------------------------*
FORM f_display_log .

  CALL FUNCTION 'REUSE_ALV_LIST_DISPLAY'
    EXPORTING
      i_callback_program = sy-repid
      i_structure_name   = 'ZSFI_ALV_CARGA_AA'
      i_default          = 'X'
    TABLES
      t_outtab           = gt_return_dis.

ENDFORM.
