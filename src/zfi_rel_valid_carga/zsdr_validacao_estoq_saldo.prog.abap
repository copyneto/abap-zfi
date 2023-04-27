*&---------------------------------------------------------------------*
*& Report ZSDR_VALIDACAO_ESTOQ_SALDO
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zsdr_validacao_estoq_saldo.

TABLES: mseg.

TYPES: BEGIN OF ty_result,
         empresa               TYPE mseg-bukrs,
         material              TYPE mseg-matnr,
         tipomovimento         TYPE mseg-bwart,
         docmaterial           TYPE mseg-mblnr,
         ano                   TYPE mseg-mjahr,
         usuario               TYPE mseg-usnam_mkpf,
         itemdocmat            TYPE mseg-zeile,
         centro                TYPE mseg-werks,
         deposito              TYPE mseg-lgort,
         lote                  TYPE mseg-charg,
         quantidade            TYPE mseg-menge,
         unidmedida            TYPE mseg-meins,
         divisao               TYPE mseg-gsber,
         centrolucro           TYPE mseg-prctr,
         datalancamento        TYPE mseg-budat_mkpf,
         tipooperacao          TYPE mseg-vgart_mkpf,
         qntumregistro         TYPE mseg-erfmg,
         tipoavaliacao         TYPE mseg-bwtar,

         "MARA/MAKT
         materialecc           TYPE mara-bismt,
         descmaterialecc       TYPE makt-maktx,

         "ACDOCA
         ledger                TYPE acdoca-rldnr,
         docreferencia         TYPE acdoca-awref,
         itemdocreferencia     TYPE acdoca-awitem,
         numdocumento          TYPE acdoca-belnr,

         precopadrao           TYPE acdoca-hstprs,

         moedamaterial         TYPE acdoca-rwcur,
         contamaterial         TYPE acdoca-racct,
         montantematerial      TYPE acdoca-wsl,

         contacontrapartida    TYPE acdoca-racct,
         montantecontrapartida TYPE acdoca-wsl,

         contadiferenca        TYPE acdoca-racct,
         montantediferenca     TYPE acdoca-wsl,

       END OF ty_result,

       BEGIN OF ty_material,
         matnr TYPE mara-matnr,
         bismt TYPE mara-bismt,
         maktx TYPE makt-maktx,
       END OF ty_material,

       BEGIN OF ty_acdoca,
         docln  TYPE acdoca-docln,
         rldnr  TYPE acdoca-rldnr,
         awref  TYPE acdoca-awref,
         awitem TYPE acdoca-awitem,
         belnr  TYPE acdoca-belnr,
         hstprs TYPE acdoca-hstprs,
         rwcur  TYPE acdoca-rwcur,
         racct  TYPE acdoca-racct,
         wsl    TYPE acdoca-wsl,
       END OF ty_acdoca.

TYPES: ty_t_result TYPE STANDARD TABLE OF ty_result WITH DEFAULT KEY,
       ty_t_acdoca TYPE STANDARD TABLE OF ty_acdoca WITH DEFAULT KEY.

DATA: gt_result   TYPE TABLE OF ty_result,
      gt_material TYPE TABLE OF ty_material,
      gt_mseg     TYPE STANDARD TABLE OF mseg,
      gt_acdoca   TYPE STANDARD TABLE OF ty_acdoca.

DATA: gv_result TYPE ty_result.

DATA: go_table TYPE REF TO cl_salv_table,
      go_cols  TYPE REF TO cl_salv_columns,
      go_funct TYPE REF TO cl_salv_functions.

SELECTION-SCREEN: BEGIN OF BLOCK b1 WITH FRAME TITLE teste.

  SELECT-OPTIONS:
    s_emp     FOR mseg-bukrs NO INTERVALS,      "*Empresa (MSEG-BUKRS)
    s_mat     FOR mseg-matnr NO INTERVALS,      "*Material (MSEG-MATNR)
    s_tpmov   FOR mseg-bwart NO INTERVALS,      "*Tipo de Movimento (MSEG-BWART)
    s_docmat  FOR mseg-mblnr NO INTERVALS,      "*Documento de Material (MSEG-MBLNR)
    s_anodoc  FOR mseg-mjahr,                   "*Ano Doc. Material (MSEG-MJAHR)
    s_usu     FOR mseg-usnam_mkpf NO INTERVALS. "*Usuário (MSEG-USNAM_MKPF)

SELECTION-SCREEN: END OF BLOCK b1.

START-OF-SELECTION.

  PERFORM f_obter_dados.

  PERFORM f_exibir_alv USING gt_result.

FORM f_obter_dados.

  SELECT
    bukrs,
    mseg~matnr,
    bwart,
    mblnr,
    mjahr,
    zeile,
    usnam_mkpf,
    mseg~werks,
    lgort,
    charg,
    menge,
    mseg~meins,
    gsber,
    mseg~prctr,
    mseg~erfmg,
    mseg~bwtar,
    budat_mkpf,
    vgart_mkpf
    FROM mseg
    WHERE bukrs      IN @s_emp
      AND mseg~matnr IN @s_mat
      AND bwart      IN @s_tpmov
      AND mblnr      IN @s_docmat
      AND mjahr      IN @s_anodoc
      AND usnam_mkpf IN @s_usu
    INTO CORRESPONDING FIELDS OF TABLE @gt_mseg.

  IF sy-subrc IS INITIAL.

    SORT gt_mseg BY mblnr mjahr zeile.

    SELECT
      docln,
      rldnr,
      awref,
      awitem,
      belnr,
      rwcur,
      racct ,
      wsl ,
      hstprs
      FROM acdoca
      FOR ALL ENTRIES IN @gt_mseg
      WHERE awref = @gt_mseg-mblnr
        AND gjahr = @gt_mseg-mjahr
        AND rldnr = '0L'
     INTO CORRESPONDING FIELDS OF TABLE @gt_acdoca.

    IF sy-subrc IS INITIAL.

      SORT gt_acdoca BY docln.

    ENDIF.

    SELECT
      mara~matnr,
      bismt,
      maktx
      FROM mara
      INNER JOIN makt ON makt~matnr = mara~matnr
      FOR ALL ENTRIES IN @gt_mseg
      WHERE mara~matnr = @gt_mseg-matnr
        AND makt~spras = @sy-langu
      INTO TABLE @gt_material.

    IF sy-subrc IS INITIAL.

      SORT gt_material BY matnr.

    ENDIF.

  ENDIF.

  LOOP AT gt_mseg ASSIGNING FIELD-SYMBOL(<fs_mseg>).

    CLEAR gv_result.

    gv_result-empresa        = <fs_mseg>-bukrs.
    gv_result-material       = <fs_mseg>-matnr.
    gv_result-tipomovimento  = <fs_mseg>-bwart.
    gv_result-docmaterial    = <fs_mseg>-mblnr.
    gv_result-ano            = <fs_mseg>-mjahr.
    gv_result-usuario        = <fs_mseg>-usnam_mkpf.
    gv_result-docmaterial    = <fs_mseg>-mblnr.
    gv_result-itemdocmat     = <fs_mseg>-zeile.
    gv_result-centro         = <fs_mseg>-werks.
    gv_result-deposito       = <fs_mseg>-lgort.
    gv_result-lote           = <fs_mseg>-charg.
    gv_result-quantidade     = <fs_mseg>-menge.
    gv_result-unidmedida     = <fs_mseg>-meins.
    gv_result-divisao        = <fs_mseg>-gsber.
    gv_result-centrolucro    = <fs_mseg>-prctr.
    gv_result-datalancamento = <fs_mseg>-budat_mkpf.
    gv_result-tipooperacao   = <fs_mseg>-vgart_mkpf.
    gv_result-qntumregistro  = <fs_mseg>-erfmg.
    gv_result-tipoavaliacao  = <fs_mseg>-bwtar.

    "Material ECC (MARA)
    READ TABLE gt_material WITH KEY matnr = <fs_mseg>-matnr INTO DATA(ls_mara) BINARY SEARCH.
    IF sy-subrc = 0.
      gv_result-materialecc = ls_mara-bismt.
      gv_result-descmaterialecc = ls_mara-maktx.
    ENDIF.

    DATA(lt_filtered) = VALUE ty_t_acdoca(
                          FOR lv_doca IN gt_acdoca WHERE ( awref = <fs_mseg>-mblnr AND awitem = <fs_mseg>-zeile ) "#EC CI_STDSEQ
                          (
                              rldnr  = lv_doca-rldnr
                              awref  = lv_doca-awref
                              awitem = lv_doca-awitem
                              belnr  = lv_doca-belnr
                              hstprs = lv_doca-hstprs
                              rwcur  = lv_doca-rwcur
                              racct  = lv_doca-racct
                              wsl    = lv_doca-wsl
                          ) ).

    SORT lt_filtered BY awref awitem.                  "#EC CI_SORTLOOP

    READ TABLE lt_filtered INDEX 1 INTO DATA(ls_index1).
    IF sy-subrc IS INITIAL.
      gv_result-ledger            = ls_index1-rldnr.
      gv_result-docreferencia     = ls_index1-awref.
      gv_result-itemdocreferencia = ls_index1-awitem.
      gv_result-numdocumento      = ls_index1-belnr.
      gv_result-precopadrao       = ls_index1-hstprs.

      gv_result-moedamaterial     = ls_index1-rwcur.
      gv_result-contamaterial     = ls_index1-racct.
      gv_result-montantematerial  = ls_index1-wsl.
    ENDIF.

    READ TABLE lt_filtered INDEX 2 INTO DATA(ls_index2).
    IF sy-subrc IS INITIAL.
      gv_result-contacontrapartida    = ls_index2-racct.
      gv_result-montantecontrapartida = ls_index2-wsl.
    ENDIF.

    READ TABLE lt_filtered INDEX 3 INTO DATA(ls_index3).
    IF sy-subrc IS INITIAL.
      gv_result-contadiferenca    = ls_index3-racct.
      gv_result-montantediferenca = ls_index3-wsl.
    ENDIF.

    APPEND gv_result TO gt_result.

  ENDLOOP.



ENDFORM.

CLASS lcl_event_receiver DEFINITION.
  PUBLIC SECTION.
    CLASS-METHODS:
      on_double_click FOR EVENT double_click OF cl_salv_events_table
        IMPORTING
          row column.
ENDCLASS.

CLASS lcl_event_receiver IMPLEMENTATION.
  METHOD on_double_click.

    DATA: lo_selections TYPE REF TO cl_salv_selections.
    DATA: lt_rows TYPE salv_t_row.
    DATA: lv_belnr TYPE bkpf-belnr.

    CLEAR gv_result.

    lo_selections = go_table->get_selections( ).

    lt_rows = lo_selections->get_selected_rows( ).

    DATA(lt_column) = lo_selections->get_selected_cells( ).

    IF lt_rows IS NOT INITIAL .

      LOOP AT lt_rows ASSIGNING FIELD-SYMBOL(<fs_row>).
        READ TABLE gt_result INTO gv_result INDEX <fs_row>.
      ENDLOOP.

      IF gv_result-numdocumento IS NOT INITIAL.

        " Open transaction FB03 with the clicked document number
        SET PARAMETER ID 'BLN' FIELD gv_result-numdocumento.
        SET PARAMETER ID 'BUK' FIELD gv_result-empresa.
        SET PARAMETER ID 'GJR' FIELD gv_result-ano.

        CALL TRANSACTION 'FB03' AND SKIP FIRST SCREEN.


      ENDIF.


    ENDIF.


  ENDMETHOD.

ENDCLASS.

FORM f_exibir_alv USING ut_table TYPE ty_t_result.

  DATA: lo_event TYPE REF TO lcl_event_receiver.
  DATA: lt_fieldcat TYPE lvc_t_fcat.

  DATA: lt_coluna TYPE salv_t_column_ref.

  DATA: lo_column TYPE REF TO cl_salv_column_list.
  DATA: lv_texto TYPE scrtext_l.

  DATA: ls_color TYPE lvc_s_colo.

  TRY.
      cl_salv_table=>factory( IMPORTING r_salv_table = go_table
                              CHANGING  t_table      = ut_table[] ).

      SET HANDLER lcl_event_receiver=>on_double_click FOR go_table->get_event( ).

    CATCH cx_salv_msg.                                  "#EC NO_HANDLER
  ENDTRY.

* Mudar descricao das colunas para o nome do campo
  go_cols = go_table->get_columns( ).
  lt_coluna = go_cols->get( ).

  LOOP AT lt_coluna ASSIGNING FIELD-SYMBOL(<fs_coluna>).
    TRY.
        lo_column ?= go_cols->get_column( <fs_coluna>-columnname ).
        lv_texto = <fs_coluna>-columnname.
        lo_column->set_long_text( lv_texto ).

      CATCH cx_salv_not_found.                          "#EC NO_HANDLER
        MESSAGE TEXT-001 TYPE 'I'. "Erro ao processar linha.
    ENDTRY.

  ENDLOOP.

* Habilitar funções para o AVL
  go_funct = go_table->get_functions( ).
  go_funct->set_all( abap_true ).

* Otimizar largura das colunas
  go_cols->set_optimize( 'X' ).

* Exibir ALV
  go_table->display( ).

ENDFORM.                    "exibir_alv
