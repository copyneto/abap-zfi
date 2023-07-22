"!<p><h2>Gravação dos dados de Retorno de Pagamento segmento Z</h2></p>
"!<p><strong>Autor:</strong> Anderson Miazato</p>
"!<p><strong>Data:</strong> 10 de set de 2021</p>
CLASS zclfi_retorno_pagto_segz DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    TYPES:
        "! Categ. Tabela Segmento Z extraído do arquivo de retorno de pagamento
      tt_segmento_z    TYPE STANDARD TABLE OF j_1bdmexz WITH KEY z01 z02 z04 .
    TYPES:
        "! Categ. Tabela Registro do segmento Z com dados complementares
      tt_retpagto_segz TYPE STANDARD TABLE OF ztfi_retpag_segz WITH DEFAULT KEY .

    CONSTANTS:
      "! Códigos dos bancos
      BEGIN OF gc_multibanco,
        banco_brasil TYPE ze_banco VALUE '001', "Banco do Brasil
        bradesco     TYPE ze_banco VALUE '237', "Banco do Bradesco
        itau         TYPE ze_banco VALUE '341', "Banco do itaú
        safra        TYPE ze_banco VALUE '422', "Banco do Safra
        santander    TYPE ze_banco VALUE '033', "Banco do Santander
        citibank     TYPE ze_banco VALUE '745', "Banco do Citibank
        modulo       TYPE ztca_param_par-modulo VALUE 'FI-AP',
        chave1       TYPE ztca_param_par-chave1 VALUE 'COMPROVANTE',
        chave2       TYPE ztca_param_par-chave2 VALUE 'BANCO',
      END OF gc_multibanco .

    "! Inicializa dados do objeto referenciado
    "! @parameter it_dados_arquivo | Dados do Retorno de pagamento
    METHODS constructor
      IMPORTING
        !it_dados_arquivo TYPE zctgfi_retpagto_segz_dados .
    "! Armazena dados relacionados para gravação do Segmento Z
    "! @parameter is_segmento_a    | Segmento A
    "! @parameter is_segmento_j    | Segmento J
    "! @parameter is_febko         | Cabeçalho extrato conta eletrônico
    "! @parameter is_febep         | Itens extrato conta eletrônico
    METHODS set_data
      IMPORTING
        !is_segmento_a  TYPE j_1bdmexa
        !is_segmento_j  TYPE j_1bdmexj
        !is_segmento_oz TYPE zsfi_items_p_oz
        !is_febko       TYPE febko
        !is_febep       TYPE febep .
    "! Grava dados relacionados ao Segmento Z no banco de dados
    METHODS save_data .
  PROTECTED SECTION.

private section.

  "! Segmento Z extraído do arquivo de retorno de pagamento
  data GT_SEGMENTO_Z type TT_SEGMENTO_Z .
  data:
      "! Registro do segmento Z com dados complementares
    gt_retpagto_segz TYPE STANDARD TABLE OF ztfi_retpag_segz .
  data:
    gr_bank_aut_banc TYPE RANGE OF ze_banco_favorecido .


  "! Recupera Segmento Z
  "! @parameter rt_result | Segmento Z
  methods GET_SEGMENTO_Z
    returning
      value(RT_RESULT) type TT_SEGMENTO_Z .
  "! Importa dados do arquivo Retorno de pagamento para obter segmento Z
  "! @parameter it_dados_arquivo | Arquivo Retorno de pagamento
  methods SET_SEGMENTO_Z
    importing
      !IT_DADOS_ARQUIVO type ZCTGFI_RETPAGTO_SEGZ_DADOS .
  "! Recupera os dados completos do retorno de pagamento Segmento Z
  "! @parameter rt_result | Retorno de pagamento Segmento Z (completo)
  methods GET_RETPAGTO_SEGZ
    returning
      value(RT_RESULT) type TT_RETPAGTO_SEGZ .
  "! Armazena os dados completos do retorno de pagamento Segmento Z
  "! @parameter is_retpagto_segz | Retorno de pagamento Segmento Z (completo)
  methods APPEND_RETPAGTO_SEGZ
    importing
      !IS_RETPAGTO_SEGZ type ZTFI_RETPAG_SEGZ .
  methods GET_BANK_AUT_BANK .
ENDCLASS.



CLASS ZCLFI_RETORNO_PAGTO_SEGZ IMPLEMENTATION.


  METHOD save_data.

    DATA(lt_retpagto_segz) = me->get_retpagto_segz(  ).
    IF lt_retpagto_segz[] IS NOT INITIAL.
      MODIFY ztfi_retpag_segz FROM TABLE lt_retpagto_segz.
    ENDIF.

  ENDMETHOD.


  METHOD set_data.

    CONSTANTS: lc_lancto_pagto    TYPE bsak_view-blart VALUE 'ZP',
               lc_separador_conta TYPE c VALUE '-'.

    DATA: lt_retpagto_segz TYPE STANDARD TABLE OF ztfi_retpag_segz.

    DATA: lr_bancos_validos TYPE RANGE OF ze_banco.

    DATA: lv_now  TYPE timestampl,
          lv_ctr  TYPE string,
          lv_ctr1 TYPE string.

    IF is_segmento_a IS INITIAL AND
       is_segmento_j IS INITIAL AND
       is_segmento_oz IS INITIAL.

      RETURN.

    ENDIF.

    DATA(lt_segmento_z) = me->get_segmento_z( ).
    SORT lt_segmento_z BY z01 z04 z02.

    " Bancos válidos para o desenvolvimento
    lr_bancos_validos = VALUE #(
                            sign = 'I'
                            option = 'EQ'
                            ( low = gc_multibanco-banco_brasil )
                            ( low = gc_multibanco-bradesco )
                            ( low = gc_multibanco-citibank )
                            ( low = gc_multibanco-itau )
                            ( low = gc_multibanco-safra )
                            ( low = gc_multibanco-santander )
                         ).

    DATA(lo_dados_complementares) = NEW zclfi_segmentoz_complemento(
      is_febko = is_febko
      is_febep = is_febep
    ).

    DATA(lt_partidas_compensadas) = lo_dados_complementares->get_partidas_compensadas( ).

    DATA(ls_dados_fornecedor) = lo_dados_complementares->get_dados_fornecedor( ).

    " Dados bancários do segmento Z
    DATA(lo_dados_bancarios) = NEW zclfi_segmentoz_bancarios(
      is_febko = is_febko
      is_febep = is_febep
    ).

    " Dados do banco e agência
    DATA(ls_dados_bancarios) = lo_dados_bancarios->get_dados_bancarios( ).

    " Conta bancária
    DATA(ls_conta_bancaria) = lo_dados_bancarios->get_conta_principal( ).


    "Segmento A.
    IF is_segmento_a IS NOT INITIAL.

      IF    is_segmento_a-a05 = 'A'
        AND is_segmento_a-a01 IN lr_bancos_validos
        AND is_segmento_a-a28(2) = '00'.

        IF is_segmento_a-a01 = gc_multibanco-itau.

          READ TABLE lt_segmento_z  WITH KEY z01 = is_segmento_a-a01
                                         z04 = is_segmento_a-a04
                                         z02 = is_segmento_a-a02
                                         ASSIGNING FIELD-SYMBOL(<fs_segmento_z>) BINARY SEARCH.
        ELSE." (outros bancos):

          READ TABLE lt_segmento_z  WITH KEY z01 = is_segmento_a-a01
                                         z04 = is_segmento_a-a04 + 1
                                         z02 = is_segmento_a-a02
                                         ASSIGNING <fs_segmento_z> BINARY SEARCH.
          IF sy-subrc <> 0.

            READ TABLE lt_segmento_z  WITH KEY z01 = is_segmento_a-a01
                                           z04 = is_segmento_a-a04 + 2
                                           z02 = is_segmento_a-a02
                                           ASSIGNING <fs_segmento_z> BINARY SEARCH. "(caso venha com o segmento B ou J-52)
          ENDIF.
        ENDIF.

        IF sy-subrc = 0.

          LOOP AT lt_partidas_compensadas ASSIGNING FIELD-SYMBOL(<fs_part>).

            APPEND INITIAL LINE TO lt_retpagto_segz ASSIGNING FIELD-SYMBOL(<fs_retpagto_segmento_z>).

            <fs_retpagto_segmento_z>-bukrs        = is_febko-bukrs.
            <fs_retpagto_segmento_z>-hbkid        = is_febko-hbkid.
            <fs_retpagto_segmento_z>-nbbln_eb     = is_febep-belnr.
*          <fs_retpagto_segmento_z>-nbbln_eb     = is_febep-nbbln.
            <fs_retpagto_segmento_z>-zgjahr       = <fs_part>-augdt(4).
            <fs_retpagto_segmento_z>-lifnr        = <fs_part>-lifnr.
            <fs_retpagto_segmento_z>-zlsch        = <fs_part>-zlsch.
            <fs_retpagto_segmento_z>-belnr        = <fs_part>-belnr.
            <fs_retpagto_segmento_z>-buzei        = <fs_part>-buzei.
            <fs_retpagto_segmento_z>-gjahr        = <fs_part>-gjahr.
            <fs_retpagto_segmento_z>-augdt        = <fs_part>-augdt.
*            <fs_retpagto_segmento_z>-dmbtr        = <fs_part>-dmbtr.
            <fs_retpagto_segmento_z>-dmbtr        = is_febep-kwbtr.
            <fs_retpagto_segmento_z>-zbanco       = COND #( WHEN ls_dados_bancarios-bankl IS NOT INITIAL THEN ls_dados_bancarios-bankl(3) ).
            <fs_retpagto_segmento_z>-zagencia     = COND #( WHEN ls_dados_bancarios-bankl IS NOT INITIAL THEN substring( val = ls_dados_bancarios-bankl
                                                                                                                   off = strlen( ls_dados_bancarios-bankl ) - 4
                                                                                                                   len = 4 ) ).

            <fs_retpagto_segmento_z>-zcontacor = condense( val  = |{ ls_conta_bancaria-bankn }|
                                                                  && lc_separador_conta
                                                                  && |{ ls_conta_bancaria-bkont }|
                                                           from = ` `
                                                           to   = `` ).

            <fs_retpagto_segmento_z>-zbancofav = COND #( WHEN ls_dados_fornecedor-bank IS NOT INITIAL THEN ls_dados_fornecedor-bank(3) ).

            <fs_retpagto_segmento_z>-zagenciafav = COND #( WHEN ls_dados_fornecedor-bank IS NOT INITIAL THEN substring( val = ls_dados_fornecedor-bank
                                                                                                                     off = strlen( ls_dados_fornecedor-bank ) - 4
                                                                                                                     len = 4 ) ).
            <fs_retpagto_segmento_z>-zcontafav = ls_dados_fornecedor-bankaccount.

            <fs_retpagto_segmento_z>-kukey_eb        = is_febko-kukey.

            IF ls_dados_bancarios-bankl(3) IN gr_bank_aut_banc.

              <fs_retpagto_segmento_z>-zautenticaban = condense( val  = |{ <fs_segmento_z>-z12 }|
                                                                        && |{ <fs_segmento_z>-z13 }|
                                                                 from = ` `
                                                                 to   = `` ).

            ELSE.
              <fs_retpagto_segmento_z>-zautenticaban = condense( val  = |{ <fs_segmento_z>-z06 }|
                                                                        && |{ <fs_segmento_z>-z07 }|
                                                                        && |{ <fs_segmento_z>-z08 }|
                                                                        && |{ <fs_segmento_z>-z09 }|
                                                                        && |{ <fs_segmento_z>-z10 }|
                                                                        && |{ <fs_segmento_z>-z11 }|
                                                                        && |{ <fs_segmento_z>-z12(1) }|
                                                                 from = ` `
                                                                 to   = `` ).
            ENDIF.


            <fs_retpagto_segmento_z>-zcontroleban = condense( <fs_segmento_z>-z13 ).

            " Campos de controle
            GET TIME STAMP FIELD lv_now.

            <fs_retpagto_segmento_z>-created_by = sy-uname.
            <fs_retpagto_segmento_z>-created_at = lv_now.
            <fs_retpagto_segmento_z>-last_changed_by = sy-uname.
            <fs_retpagto_segmento_z>-last_changed_at = lv_now.
            CONVERT DATE sy-datum TIME sy-uzeit
              INTO TIME STAMP <fs_retpagto_segmento_z>-local_last_changed_at TIME ZONE sy-zonlo.

          ENDLOOP.

        ENDIF.

      ENDIF.
      "Segmento J, N e O
    ELSEIF is_segmento_j IS NOT INITIAL.

      IF      is_segmento_j-j05 = 'J'
          AND is_segmento_j-j01 IN lr_bancos_validos
          AND is_segmento_j-j23(2) = '00'.

        IF is_segmento_j-j01 = gc_multibanco-itau.

          READ TABLE lt_segmento_z  WITH KEY z01 = is_segmento_j-j01
                                         z04 = is_segmento_j-j04
                                         z02 = is_segmento_j-j02
                                         ASSIGNING <fs_segmento_z> BINARY SEARCH.
        ELSE." (outros bancos):
          READ TABLE lt_segmento_z  WITH KEY z01 = is_segmento_j-j01
                                         z04 = is_segmento_j-j04 + 1
                                         z02 = is_segmento_j-j02
                                         ASSIGNING <fs_segmento_z> BINARY SEARCH.
          IF sy-subrc <> 0.

            READ TABLE lt_segmento_z  WITH KEY z01 = is_segmento_j-j01
                                           z04 = is_segmento_j-j04 + 2
                                           z02 = is_segmento_j-j02
                                         ASSIGNING <fs_segmento_z> BINARY SEARCH. "(caso venha com o segmento B ou J-52)
          ENDIF.

        ENDIF.

        IF sy-subrc = 0.

          LOOP AT lt_partidas_compensadas ASSIGNING FIELD-SYMBOL(<fs_part2>).

            APPEND INITIAL LINE TO lt_retpagto_segz ASSIGNING <fs_retpagto_segmento_z>.

            <fs_retpagto_segmento_z>-bukrs    = is_febko-bukrs.
            <fs_retpagto_segmento_z>-hbkid    = is_febko-hbkid.
            <fs_retpagto_segmento_z>-kukey_eb = is_febko-kukey.
            <fs_retpagto_segmento_z>-nbbln_eb = is_febep-belnr.
*          <fs_retpagto_segmento_z>-nbbln_eb = is_febep-nbbln.
            <fs_retpagto_segmento_z>-zgjahr   = <fs_part2>-augdt(4).
            <fs_retpagto_segmento_z>-lifnr    = <fs_part2>-lifnr.
            <fs_retpagto_segmento_z>-zlsch    = <fs_part2>-zlsch.
            <fs_retpagto_segmento_z>-belnr    = <fs_part2>-belnr.
            <fs_retpagto_segmento_z>-buzei    = <fs_part2>-buzei.
            <fs_retpagto_segmento_z>-gjahr    = <fs_part2>-gjahr.

            <fs_retpagto_segmento_z>-augdt    = <fs_part2>-augdt.
*            <fs_retpagto_segmento_z>-dmbtr    = <fs_part2>-dmbtr.
            <fs_retpagto_segmento_z>-dmbtr    = is_febep-kwbtr.
            <fs_retpagto_segmento_z>-zbanco   = COND #( WHEN ls_dados_bancarios-bankl IS NOT INITIAL THEN ls_dados_bancarios-bankl(3) ).

            <fs_retpagto_segmento_z>-zagencia = COND #( WHEN ls_dados_bancarios-bankl IS NOT INITIAL THEN substring( val = ls_dados_bancarios-bankl
                                                                                                                   off = strlen( ls_dados_bancarios-bankl ) - 4
                                                                                                                   len = 4 ) ).

            <fs_retpagto_segmento_z>-zcontacor = condense( val  = |{ ls_conta_bancaria-bankn }|
                                                                  && lc_separador_conta
                                                                  && |{ ls_conta_bancaria-bkont }|
                                                           from = ` `
                                                           to   = `` ).

            <fs_retpagto_segmento_z>-zbancofav = COND #( WHEN ls_dados_fornecedor-bank IS NOT INITIAL THEN ls_dados_fornecedor-bank(3) ).
            <fs_retpagto_segmento_z>-zagenciafav = COND #( WHEN ls_dados_fornecedor-bank IS NOT INITIAL THEN substring( val = ls_dados_fornecedor-bank
                                                                                                                        off = strlen( ls_dados_fornecedor-bank ) - 4
                                                                                                                        len = 4 ) ).
            <fs_retpagto_segmento_z>-zcontafav = ls_dados_fornecedor-bankaccount.

            IF ls_dados_bancarios-bankl(3) IN gr_bank_aut_banc.

              <fs_retpagto_segmento_z>-zautenticaban = condense( val  = |{ <fs_segmento_z>-z12 }|
                                                                        && |{ <fs_segmento_z>-z13 }|
                                                                 from = ` `
                                                                 to   = `` ).

            ELSE.
              <fs_retpagto_segmento_z>-zautenticaban = condense( val  = |{ <fs_segmento_z>-z06 }|
                                                                        && |{ <fs_segmento_z>-z07 }|
                                                                        && |{ <fs_segmento_z>-z08 }|
                                                                        && |{ <fs_segmento_z>-z09 }|
                                                                        && |{ <fs_segmento_z>-z10 }|
                                                                        && |{ <fs_segmento_z>-z11 }|
                                                                        && |{ <fs_segmento_z>-z12(1) }|
                                                                 from = ` `
                                                                 to   = `` ).
            ENDIF.

            <fs_retpagto_segmento_z>-zcontroleban = condense( <fs_segmento_z>-z13 ).

            " Campos de controle
            GET TIME STAMP FIELD lv_now.

            <fs_retpagto_segmento_z>-created_by = sy-uname.
            <fs_retpagto_segmento_z>-created_at = lv_now.
            <fs_retpagto_segmento_z>-last_changed_by = sy-uname.
            <fs_retpagto_segmento_z>-last_changed_at = lv_now.
            CONVERT DATE sy-datum TIME sy-uzeit
              INTO TIME STAMP <fs_retpagto_segmento_z>-local_last_changed_at TIME ZONE sy-zonlo.

          ENDLOOP.

        ENDIF.

      ENDIF.

      "Segmento OZ
    ELSEIF is_segmento_oz IS NOT INITIAL.

      IF  is_segmento_oz-o05 = 'O'
       AND is_segmento_oz-o01 IN lr_bancos_validos.
        "AND is_segmento_j-j23(2) = '00'.

        IF is_segmento_oz-o01 = gc_multibanco-itau.

          READ TABLE lt_segmento_z  WITH KEY z01 = is_segmento_oz-o01
                                         z04 = is_segmento_oz-o04
                                         z02 = is_segmento_oz-o02
                                         ASSIGNING <fs_segmento_z> BINARY SEARCH.
        ELSE." (outros bancos):
          READ TABLE lt_segmento_z  WITH KEY z01 = is_segmento_oz-o01
                                         z04 = is_segmento_oz-o04 + 1
                                         z02 = is_segmento_oz-o02
                                         ASSIGNING <fs_segmento_z> BINARY SEARCH.
          IF sy-subrc <> 0.

            READ TABLE lt_segmento_z  WITH KEY z01 = is_segmento_oz-o01
                                           z04 = is_segmento_oz-o04 + 2
                                           z02 = is_segmento_oz-o02
                                         ASSIGNING <fs_segmento_z> BINARY SEARCH. "(caso venha com o segmento B ou J-52)
          ENDIF.

        ENDIF.

        IF sy-subrc = 0.

          LOOP AT lt_partidas_compensadas ASSIGNING FIELD-SYMBOL(<fs_part3>).

            APPEND INITIAL LINE TO lt_retpagto_segz ASSIGNING <fs_retpagto_segmento_z>.

            <fs_retpagto_segmento_z>-bukrs    = is_febko-bukrs.
            <fs_retpagto_segmento_z>-hbkid    = is_febko-hbkid.
            <fs_retpagto_segmento_z>-kukey_eb = is_febko-kukey.
            <fs_retpagto_segmento_z>-nbbln_eb = is_febep-belnr.
*          <fs_retpagto_segmento_z>-nbbln_eb = is_febep-nbbln.
            <fs_retpagto_segmento_z>-zgjahr   = <fs_part3>-augdt(4).
            <fs_retpagto_segmento_z>-lifnr    = <fs_part3>-lifnr.
            <fs_retpagto_segmento_z>-zlsch    = <fs_part3>-zlsch.
            <fs_retpagto_segmento_z>-belnr    = <fs_part3>-belnr.
            <fs_retpagto_segmento_z>-buzei    = <fs_part3>-buzei.
            <fs_retpagto_segmento_z>-gjahr    = <fs_part3>-gjahr.

            <fs_retpagto_segmento_z>-augdt    = <fs_part3>-augdt.
*            <fs_retpagto_segmento_z>-dmbtr    = <fs_part3>-dmbtr.
            <fs_retpagto_segmento_z>-dmbtr    = is_febep-kwbtr.
            <fs_retpagto_segmento_z>-zbanco   = COND #( WHEN ls_dados_bancarios-bankl IS NOT INITIAL THEN ls_dados_bancarios-bankl(3) ).

            <fs_retpagto_segmento_z>-zagencia = COND #( WHEN ls_dados_bancarios-bankl IS NOT INITIAL THEN substring( val = ls_dados_bancarios-bankl
                                                                                                                   off = strlen( ls_dados_bancarios-bankl ) - 4
                                                                                                                   len = 4 ) ).

            <fs_retpagto_segmento_z>-zcontacor = condense( val  = |{ ls_conta_bancaria-bankn }|
                                                                  && lc_separador_conta
                                                                  && |{ ls_conta_bancaria-bkont }|
                                                           from = ` `
                                                           to   = `` ).

            <fs_retpagto_segmento_z>-zbancofav = COND #( WHEN ls_dados_fornecedor-bank IS NOT INITIAL THEN ls_dados_fornecedor-bank(3) ).
            <fs_retpagto_segmento_z>-zagenciafav = COND #( WHEN ls_dados_fornecedor-bank IS NOT INITIAL THEN substring( val = ls_dados_fornecedor-bank
                                                                                                                        off = strlen( ls_dados_fornecedor-bank ) - 4
                                                                                                                        len = 4 ) ).
            <fs_retpagto_segmento_z>-zcontafav = ls_dados_fornecedor-bankaccount.

            IF ls_dados_bancarios-bankl(3) IN gr_bank_aut_banc.

              <fs_retpagto_segmento_z>-zautenticaban = condense( val  = |{ <fs_segmento_z>-z12 }|
                                                                        && |{ <fs_segmento_z>-z13 }|
                                                                 from = ` `
                                                                 to   = `` ).

            ELSE.
              <fs_retpagto_segmento_z>-zautenticaban = condense( val  = |{ <fs_segmento_z>-z06 }|
                                                                        && |{ <fs_segmento_z>-z07 }|
                                                                        && |{ <fs_segmento_z>-z08 }|
                                                                        && |{ <fs_segmento_z>-z09 }|
                                                                        && |{ <fs_segmento_z>-z10 }|
                                                                        && |{ <fs_segmento_z>-z11 }|
                                                                        && |{ <fs_segmento_z>-z12(1) }|
                                                                 from = ` `
                                                                 to   = `` ).
            ENDIF.

            <fs_retpagto_segmento_z>-zcontroleban = condense( <fs_segmento_z>-z13 ).

            " Campos de controle
            GET TIME STAMP FIELD lv_now.

            <fs_retpagto_segmento_z>-created_by = sy-uname.
            <fs_retpagto_segmento_z>-created_at = lv_now.
            <fs_retpagto_segmento_z>-last_changed_by = sy-uname.
            <fs_retpagto_segmento_z>-last_changed_at = lv_now.
            CONVERT DATE sy-datum TIME sy-uzeit
              INTO TIME STAMP <fs_retpagto_segmento_z>-local_last_changed_at TIME ZONE sy-zonlo.

          ENDLOOP.

        ENDIF.

      ENDIF.

    ENDIF.

    TRY.
        LOOP AT lt_retpagto_segz ASSIGNING FIELD-SYMBOL(<fs_segz>).
          me->append_retpagto_segz( <fs_segz> ).
        ENDLOOP.

      CATCH cx_sy_itab_line_not_found.
        RETURN.
    ENDTRY.

  ENDMETHOD.


  METHOD constructor.

    me->set_segmento_z( it_dados_arquivo ).

    me->get_bank_aut_bank( ).

  ENDMETHOD.


  METHOD get_segmento_z.
    rt_result = me->gt_segmento_z.
  ENDMETHOD.


  METHOD set_segmento_z.

    LOOP AT it_dados_arquivo ASSIGNING FIELD-SYMBOL(<fs_dados_arquivo>).

      IF    <fs_dados_arquivo>-rec+7(1) EQ '3'   "Items
        AND <fs_dados_arquivo>-rec+13(1) EQ 'Z'. "Segmento Z

        APPEND INITIAL LINE TO me->gt_segmento_z ASSIGNING FIELD-SYMBOL(<fs_segmento_z>).
        <fs_segmento_z> = <fs_dados_arquivo>.
      ENDIF.

    ENDLOOP.

  ENDMETHOD.


  METHOD get_retpagto_segz.
    rt_result = me->gt_retpagto_segz.
  ENDMETHOD.


  METHOD append_retpagto_segz.
    APPEND is_retpagto_segz TO me->gt_retpagto_segz.
  ENDMETHOD.


  METHOD get_bank_aut_bank.

    CLEAR: gr_bank_aut_banc.

    DATA(lo_param) = zclca_tabela_parametros=>get_instance( ). " CHANGE - LSCHEPP - 20.07.2023

    TRY.
        lo_param->m_get_range( EXPORTING iv_modulo = gc_multibanco-modulo
                                         iv_chave1 = gc_multibanco-chave1
                                         iv_chave2 = gc_multibanco-chave2
                               IMPORTING et_range  = gr_bank_aut_banc ).

      CATCH zcxca_tabela_parametros INTO DATA(lo_cx).
        WRITE lo_cx->get_text( ).
    ENDTRY.

  ENDMETHOD.
ENDCLASS.
