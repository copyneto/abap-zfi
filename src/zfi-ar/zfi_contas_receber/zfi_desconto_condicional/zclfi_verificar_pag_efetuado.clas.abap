"!<p>Classe Verifica Pagamento Efetuado</p>
"!<p><strong>Autor:</strong>Marcos Rubik</p>
"!<p><strong>Data:</strong> 10 de Março de 2022</p>
CLASS zclfi_verificar_pag_efetuado DEFINITION
  PUBLIC
  CREATE PUBLIC .

  PUBLIC SECTION.

    TYPES:
      BEGIN OF ty_bseg_ret,
        bukrs TYPE bseg-bukrs,
        belnr TYPE bseg-belnr,
        gjahr TYPE bseg-gjahr,
        buzei TYPE bseg-buzei,
        augbl TYPE bseg-augbl,
        augdt TYPE bseg-augdt,
        hkont TYPE bseg-hkont,
      END OF ty_bseg_ret .
    TYPES:
      tt_bseg_ret TYPE TABLE OF ty_bseg_ret .

    "! Realizar verificação se pagamento foi efetuado
    "! @parameter iv_BUKRS    | Empresa
    "! @parameter iv_belnr    | Nº documento de um documento contábil
    "! @parameter iv_GJAHR    | Exercício
    "! @parameter rv_return   | Retorno da verificação
    METHODS verifica
      IMPORTING
                !iv_bukrs        TYPE bukrs
                !iv_belnr        TYPE belnr_d
                !iv_gjahr        TYPE gjahr
      RETURNING VALUE(rv_return) TYPE flag.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.

CLASS zclfi_verificar_pag_efetuado IMPLEMENTATION.
  METHOD verifica.
    DATA: lt_bseg TYPE tt_bseg_ret.

    DATA: ls_bseg TYPE ty_bseg_ret.

    DATA: lv_status TYPE char1.

    DATA: lr_hkont TYPE RANGE OF bseg-hkont,
          lr_blart TYPE RANGE OF bkpf-blart.

    CLEAR: ls_bseg,
           lt_bseg[].
    SELECT bukrs
           belnr
           gjahr
           buzei
           augbl
           augdt
           hkont
      FROM bseg
    INTO TABLE lt_bseg
      WHERE bukrs = iv_bukrs
        AND belnr = iv_belnr
        AND gjahr = iv_gjahr
        AND koart = 'K'
        AND bschl = '31'.
    READ TABLE lt_bseg INTO ls_bseg INDEX 1.

    IF ls_bseg-augbl IS NOT INITIAL AND
       ls_bseg-augdt IS NOT INITIAL.
      "Selecionar contas bancarias
      SELECT
          bukrs,
          hkont
        FROM t012k
        INTO TABLE @DATA(lt_t012k)
        WHERE bukrs EQ @ls_bseg-bukrs.
      SORT lt_t012k BY bukrs hkont.
      DELETE ADJACENT DUPLICATES FROM lt_t012k COMPARING bukrs hkont.

      LOOP AT lt_t012k ASSIGNING FIELD-SYMBOL(<fs_t012k>).

        "BR - Entrada
        DATA(ls_ikofi_in) = VALUE ikofi(
            anwnd = '0001'
            eigr1 = 'B00D'
            eigr2 = '1'
            komo1 = '+'
            komo2 = 'BRL'
            ktopl = 'PC01'
            sakin =  <fs_t012k>-hkont
        ).

        CALL FUNCTION 'ACCOUNT_DETERMINATION'
          EXPORTING
            i_anwnd  = ls_ikofi_in-anwnd
            i_eigr1  = ls_ikofi_in-eigr1
            i_eigr2  = ls_ikofi_in-eigr2
            i_eigr3  = ls_ikofi_in-eigr3
            i_eigr4  = ls_ikofi_in-eigr4
            i_komo1  = ls_ikofi_in-komo1
            i_komo1b = ls_ikofi_in-komo1b
            i_komo2  = ls_ikofi_in-komo2
            i_komo2b = ls_ikofi_in-komo2b
            i_ktopl  = ls_ikofi_in-ktopl
            i_sakin  = ls_ikofi_in-sakin
            i_sakinb = ls_ikofi_in-sakin
          IMPORTING
            e_ikofi  = ls_ikofi_in
          EXCEPTIONS
            OTHERS   = 1.
        IF  sy-subrc IS INITIAL AND ls_ikofi_in-sakn1 IS NOT INITIAL.
          APPEND INITIAL LINE TO lr_hkont ASSIGNING FIELD-SYMBOL(<fs_r_hkont>).
          <fs_r_hkont>-option = 'EQ'.
          <fs_r_hkont>-sign   = 'I'.
          <fs_r_hkont>-low    = ls_ikofi_in-sakn1.
        ENDIF.

        "BR - Saida
        DATA(ls_ikofi_out) =  VALUE ikofi(
            anwnd = '0001'
            eigr1 = 'B00C'
            eigr2 = '1'
            komo1 = '+'
            komo2 = 'BRL'
            ktopl = 'PC01'
            sakin =  <fs_t012k>-hkont
        ).

        CALL FUNCTION 'ACCOUNT_DETERMINATION'
          EXPORTING
            i_anwnd  = ls_ikofi_out-anwnd
            i_eigr1  = ls_ikofi_out-eigr1
            i_eigr2  = ls_ikofi_out-eigr2
            i_eigr3  = ls_ikofi_out-eigr3
            i_eigr4  = ls_ikofi_out-eigr4
            i_komo1  = ls_ikofi_out-komo1
            i_komo1b = ls_ikofi_out-komo1b
            i_komo2  = ls_ikofi_out-komo2
            i_komo2b = ls_ikofi_out-komo2b
            i_ktopl  = ls_ikofi_out-ktopl
            i_sakin  = ls_ikofi_out-sakin
            i_sakinb = ls_ikofi_out-sakin
          IMPORTING
            e_ikofi  = ls_ikofi_out
          EXCEPTIONS
            OTHERS   = 1.
        IF  sy-subrc IS INITIAL AND ls_ikofi_out-sakn1 IS NOT INITIAL.
          UNASSIGN <fs_r_hkont>.
          APPEND INITIAL LINE TO lr_hkont ASSIGNING <fs_r_hkont>.
          <fs_r_hkont>-option = 'EQ'.
          <fs_r_hkont>-sign   = 'I'.
          <fs_r_hkont>-low    = ls_ikofi_out-sakn1.
        ENDIF.
      ENDLOOP.

      "Verificar contas de bancos na compensação
      DELETE lt_bseg WHERE hkont NOT IN lr_hkont.

      IF NOT lt_bseg[] IS INITIAL.
        " Status compensada e paga.
        rv_return = abap_true.
      ENDIF.

    ENDIF.

  ENDMETHOD.
ENDCLASS.
