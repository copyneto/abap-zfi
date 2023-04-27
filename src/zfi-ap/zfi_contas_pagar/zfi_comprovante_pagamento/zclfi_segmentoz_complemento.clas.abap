"!<p><h2>Seleção de dados complementares ao segmento Z</h2></p>
"!<p><strong>Autor:</strong> Anderson Miazato</p>
"!<p><strong>Data:</strong> 14 de set de 2021</p>
CLASS zclfi_segmentoz_complemento DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    TYPES:
      "! Partidas compensadas
      BEGIN OF ty_partidas_compensadas,
        bukrs TYPE bsak_view-bukrs,
        lifnr TYPE bsak_view-lifnr,
        augdt TYPE bsak_view-augdt,
        augbl TYPE bsak_view-augbl,
        gjahr TYPE bsak_view-gjahr,
        belnr TYPE bsak_view-belnr,
        buzei TYPE bsak_view-buzei,
        budat TYPE bsak_view-budat,
        bldat TYPE bsak_view-bldat,
        hbkid TYPE bsak_view-hbkid,
        zlsch TYPE bsak_view-zlsch,
        bvtyp TYPE bsak_view-bvtyp,
        dmbtr TYPE bsak_view-dmbtr,
      END OF ty_partidas_compensadas .
    TYPES:
      "! Dados bancários do fornecedor favorecido
      BEGIN OF ty_dados_fornecedor,
        supplier    TYPE i_supplierbankdetails-supplier,
        bank        TYPE i_supplierbankdetails-bank,
        bankaccount TYPE i_supplierbankdetails-bankaccount,
      END OF ty_dados_fornecedor .
    TYPES:
      ty_t_partidas_compensadas TYPE TABLE OF ty_partidas_compensadas WITH DEFAULT KEY .

    DATA:
      gt_partidas_compensadas TYPE TABLE OF ty_partidas_compensadas .
    CONSTANTS gc_0001 TYPE bvtyp VALUE '0001' ##NO_TEXT.

    "! Inicializa dados do objeto referenciado
    "! @parameter is_febko | Cabeçalho extrato conta eletrônico
    "! @parameter is_febep | Itens extrato conta eletrônico
    METHODS constructor
      IMPORTING
        !is_febko TYPE febko
        !is_febep TYPE febep .
    "! Seleciona partidas compensadas
    METHODS set_partidas_compensadas .
    "! Recupera de partidas compensadas
    "! @parameter rt_result | Partidas compensadas
    METHODS get_partidas_compensadas
      RETURNING
        VALUE(rt_result) TYPE ty_t_partidas_compensadas .
    "! Seleciona dados bancários do fornecedor favorecido
    METHODS set_dados_fornecedor .
    "! Recupera dados bancários do fornecedor favorecido
    "! @parameter rs_result | Dados do fornecedor
    METHODS get_dados_fornecedor
      RETURNING
        VALUE(rs_result) TYPE ty_dados_fornecedor .
  PROTECTED SECTION.
  PRIVATE SECTION.
    DATA:
      "! Cabeçalho do extrato eletrônico da conta
      gs_febko                TYPE febko,
      "! Item do extrato eletrônico da conta
      gs_febep                TYPE febep,
      "! Partida compensada
      gs_partidas_compensadas TYPE ty_partidas_compensadas,
      "! Dados bancários do fornecedor favorecido
      gs_dados_fornecedor     TYPE ty_dados_fornecedor.

    METHODS:
      "! Recupera dados do cabeçalho de extrato da conta
      "! @parameter rs_result | Cabeçalho extrato conta eletrônico
      get_febko RETURNING VALUE(rs_result) TYPE febko,

      "! Armazena cabeçalho extrato da conta
      "! @parameter is_febko | Cabeçalho extrato conta eletrônico
      set_febko IMPORTING is_febko TYPE febko,
      "! Recupera dados do item de extrato da conta
      "! @parameter rs_result | Item extrato conta eletrônico
      get_febep RETURNING VALUE(rs_result) TYPE febep,

      "! Armazena dados do item de extrato da conta
      "! @parameter is_febep | Item extrato conta eletrônico
      set_febep IMPORTING is_febep TYPE febep.

ENDCLASS.



CLASS zclfi_segmentoz_complemento IMPLEMENTATION.


  METHOD get_febko.
    rs_result = me->gs_febko.
  ENDMETHOD.


  METHOD set_febko.
    me->gs_febko = is_febko.
  ENDMETHOD.


  METHOD get_febep.
    rs_result = me->gs_febep.
  ENDMETHOD.


  METHOD set_febep.
    me->gs_febep = is_febep.
  ENDMETHOD.


  METHOD constructor.

    me->set_febko( is_febko ).

    me->set_febep( is_febep ).

    me->set_partidas_compensadas( ).

    me->set_dados_fornecedor( ).

  ENDMETHOD.


  METHOD set_partidas_compensadas.

    CONSTANTS: lc_lancto_pagto    TYPE bsak_view-blart VALUE 'ZP',
               lc_separador_conta TYPE c VALUE '_'.

    DATA(ls_febko) = me->get_febko( ).

    DATA(ls_febep) = me->get_febep( ).

    " Dados da fatura
    SELECT
        bukrs,
        lifnr,
        augdt,
        augbl,
        gjahr,
        belnr,
        buzei,
        budat,
        bldat,
        hbkid,
        zlsch,
        bvtyp,
        dmbtr
    FROM bsak_view
        WHERE bukrs EQ @ls_febko-bukrs
          AND augbl EQ @ls_febep-belnr
*          AND augbl EQ @ls_febep-nbbln
*          AND dmbtr EQ @ls_febep-kwbtr
          AND blart NE @lc_lancto_pagto
        INTO TABLE @me->gt_partidas_compensadas.
*        INTO @me->gs_partidas_compensadas UP TO 1 ROWS.
*    ENDSELECT.

    IF sy-subrc <> 0 .

      " Dados da fatura
      SELECT
          bukrs,
          lifnr,
          augdt,
          augbl,
          gjahr,
          belnr,
          buzei,
          budat,
          bldat,
          hbkid,
          zlsch,
          bvtyp,
          dmbtr
      FROM bsak_view
          WHERE bukrs EQ @ls_febko-bukrs
            AND xblnr EQ @ls_febep-belnr
*          AND augbl EQ @ls_febep-nbbln
*            AND dmbtr EQ @ls_febep-kwbtr
            AND blart NE @lc_lancto_pagto
        INTO TABLE @me->gt_partidas_compensadas.
*            INTO @me->gs_partidas_compensadas UP TO 1 ROWS.
*        ENDSELECT.

    ENDIF.

  ENDMETHOD.


  METHOD get_partidas_compensadas.
    rt_result = me->gt_partidas_compensadas.
  ENDMETHOD.


  METHOD set_dados_fornecedor.

    READ TABLE gt_partidas_compensadas INTO gs_partidas_compensadas INDEX 1.

**    DATA(ls_partidas_compensadas) = me->get_partidas_compensadas(  ).
    IF me->gs_partidas_compensadas IS INITIAL.
      RETURN.
    ENDIF.

    " Dados do favorecido
    SELECT SINGLE
        supplier,
        bank,
        bankaccount
    FROM i_supplierbankdetails
        WHERE supplier EQ @me->gs_partidas_compensadas-lifnr
          AND bpbankaccountinternalid EQ @me->gs_partidas_compensadas-bvtyp
    INTO @me->gs_dados_fornecedor.

    IF sy-subrc <> 0.

      " Dados do favorecido
      SELECT SINGLE
          supplier,
          bank,
          bankaccount
      FROM i_supplierbankdetails
          WHERE supplier EQ @me->gs_partidas_compensadas-lifnr
            AND bpbankaccountinternalid EQ @gc_0001
      INTO @me->gs_dados_fornecedor.

    ENDIF.

  ENDMETHOD.


  METHOD get_dados_fornecedor.
    rs_result = me->gs_dados_fornecedor.
  ENDMETHOD.
ENDCLASS.
