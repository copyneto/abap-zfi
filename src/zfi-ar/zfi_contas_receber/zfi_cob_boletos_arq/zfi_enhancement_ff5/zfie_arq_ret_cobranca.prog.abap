***********************************************************************
***                      © 3corações                                ***
***********************************************************************
***                                                                   *
*** DESCRIÇÃO: Arquivo de retorno de cobrança - FF_5                  *
*** AUTOR    : Alysson Anjos – META                                   *
*** FUNCIONAL: Raphael Rocha – META                                   *
*** DATA     : 15/09/2021                                             *
***********************************************************************
*** HISTÓRICO DAS MODIFICAÇÕES                                        *
***-------------------------------------------------------------------*
*** DATA      | AUTOR        | DESCRIÇÃO                              *
***-------------------------------------------------------------------*
***           |              |                                        *
***********************************************************************
*&---------------------------------------------------------------------*
*& Include          ZFIE_ARQ_RET_COBRANCA
*&---------------------------------------------------------------------*
* Tabelas Internas e Work Area
*----------------------------------------------------------------------

CONSTANTS: lc_pesq_br TYPE febep-intag VALUE '030',
           lc_liquid  TYPE febep-vgext VALUE '06',
           lc_banco   TYPE char3       VALUE '237'.


IF i_febep-intag     EQ lc_pesq_br  " 030 Pesquisa brasileira via BELNR, GJAHR e BUZEI
AND i_febep-vgext    EQ lc_liquid  " Liquidação
AND i_febko-absnd(3) EQ lc_banco.  " Bradesco

*  Com este ajuste, serão permitidos as liquidações pelo montante bruto ou líquido.
  READ TABLE t_febcl INTO DATA(ls_febcl) WITH KEY kukey = i_febep-kukey
                                                  esnum = i_febep-esnum
                                                  csnum = 1
                                                  koart = i_febep-avkoa
                                                  agkon = i_febep-avkon . "#EC CI_STDSEQ
  IF sy-subrc IS INITIAL.

    SELECT bukrs,
           kunnr,
           belnr,
           gjahr,
           buzei,
           dmbtr
      FROM bsid_view
      INTO TABLE @DATA(lt_bsid)
     WHERE bukrs = @i_febko-bukrs
       AND kunnr = @i_febep-avkon
       AND belnr = @ls_febcl-selvon+0(10)
       AND gjahr = @ls_febcl-selvon+10(4)
       AND buzei = @ls_febcl-selvon+14(3)
       ORDER BY PRIMARY KEY.

    IF sy-subrc IS INITIAL.

      LOOP AT lt_bsid ASSIGNING FIELD-SYMBOL(<fs_bsid>).

        IF <fs_bsid>-dmbtr EQ i_febep-kwbtr.

          DELETE t_febcl WHERE kukey = i_febep-kukey
                           AND esnum = i_febep-esnum.    "#EC CI_STDSEQ

          t_febcl = ls_febcl.
          APPEND t_febcl.
          EXIT.

        ENDIF.
      ENDLOOP.

    ELSE.

      SELECT bukrs,
             kunnr,
             belnr,
             gjahr,
             buzei,
             dmbtr
        FROM bsid_view
        INTO TABLE @DATA(lt_bsid2)
       WHERE bukrs = @i_febko-bukrs
         AND xref3 = @i_febep-chect(11)
         ORDER BY PRIMARY KEY.

      IF sy-subrc IS INITIAL.

        LOOP AT lt_bsid2 ASSIGNING FIELD-SYMBOL(<fs_bsid2>).

          DELETE t_febcl WHERE kukey = i_febep-kukey
                           AND esnum = i_febep-esnum.    "#EC CI_STDSEQ

          ls_febcl-agkon        = <fs_bsid2>-kunnr.
          ls_febcl-selvon+0(10) = <fs_bsid2>-belnr.
          ls_febcl-selvon+10(4) = <fs_bsid2>-gjahr.
          ls_febcl-selvon+14(3) = <fs_bsid2>-buzei.

          t_febcl = ls_febcl.
          APPEND t_febcl.
          EXIT.

        ENDLOOP.

      ENDIF.

    ENDIF.

  ENDIF.

ENDIF.
