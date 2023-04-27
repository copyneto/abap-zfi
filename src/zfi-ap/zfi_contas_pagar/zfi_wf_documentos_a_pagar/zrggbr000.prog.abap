***********************************************************************
***                      © 3corações                                ***
***********************************************************************
***                                                                   *
*** DESCRIÇÃO: FI - Exit validações                                   *
*** AUTOR : Anderson Miazato - META                                   *
*** FUNCIONAL: Fernando Siqueira/Raphael Rocha - META                 *
*** DATA : 25.11.2021                                                 *
***********************************************************************
*** HISTÓRICO DAS MODIFICAÇÕES                                        *
***-------------------------------------------------------------------*
*** DATA       | AUTOR              | DESCRIÇÃO                       *
***-------------------------------------------------------------------*
*** 25.11.2021 | Anderson Miazato   | Desenvolvimento inicial         *
***********************************************************************

*&---------------------------------------------------------------------*
*& Modulpool ZRGGBR000
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
PROGRAM zrggbr000.

INCLUDE fgbbgd00.

*!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!*
*    PLEASE INCLUDE THE FOLLOWING "TYPE-POOL"  AND "TABLES" COMMANDS  *
*        IF THE ACCOUNTING MODULE IS INSTALLED IN YOUR SYSTEM         *
*!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!*
TYPE-POOLS: gb002.

TABLES: bkpf,
        bseg,
        cobl,
        bpja,
        glu1,
        rbkp.

*----------------------------------------------------------------------*
*       FORM GET_EXIT_TITLES                                           *
*----------------------------------------------------------------------*
*       returns name and title of all available standard-exits         *
*       every exit in this formpool has to be added to this form.      *
*       You have to specify a parameter type in order to enable the    *
*       code generation program to determine correctly how to          *
*       generate the user exit call, i.e. how many and what kind of    *
*       parameter(s) are used in the user exit.                        *
*       The following parameter types exist:                           *
*                                                                      *
*       TYPE                Description              Usage             *
*    ------------------------------------------------------------      *
*       C_EXIT_PARAM_NONE   Use no parameter         Subst. and Valid. *
*                           except B_RESULT                            *
*       C_EXIT_PARAM_CLASS  Use a type as parameter  Subst. and Valid  *
*----------------------------------------------------------------------*
*  -->  EXIT_TAB  table with exit-name and exit-titles                 *
*                 structure: NAME(5), PARAM(1), TITLE(60)
*----------------------------------------------------------------------*
FORM get_exit_titles TABLES etab.

  TYPES: BEGIN OF ty_exits,
           name(5)   TYPE c,
           param     LIKE c_exit_param_none,
           title(60) TYPE c,
         END OF ty_exits.

  DATA: lt_exits TYPE STANDARD TABLE OF ty_exits.

  " Form de exemplo para validação
  APPEND VALUE ty_exits( name = 'U100'
                         param = c_exit_param_none
                         title = TEXT-002 ) TO etab[].

  " Validação Tipo de Documento x Departamento
  APPEND VALUE ty_exits( name = 'U101'
                         param = c_exit_param_none
                         title = TEXT-001 ) TO etab[].

  " Validar retirada de bloqueio doc. em aprovação
  APPEND VALUE ty_exits( name = 'U102'
                         param = c_exit_param_none
                         title = TEXT-002 ) TO etab[].

  " Validar retirada de bloqueio grão verde
  APPEND VALUE ty_exits( name = 'U103'
                         param = c_exit_param_none
                         title = TEXT-007 ) TO etab[].

  " Bloquear fatura com adiantamento
  APPEND VALUE ty_exits( name = 'ZBFA'
                         param = c_exit_param_none
                         title = TEXT-003 ) TO etab[].

  " Validar num nota fiscal
  APPEND VALUE ty_exits( name = 'MTRA'
                         param = c_exit_param_none
                         title = TEXT-004 ) TO etab[].

  " Validar New GL
  APPEND VALUE ty_exits( name = 'ZNGL'
                         param = c_exit_param_none
                         title = TEXT-006 ) TO etab[].

ENDFORM.

*----------------------------------------------------------------------*
*       FORM U100                                                      *
*----------------------------------------------------------------------*
*       Example of an exit for a boolean rule                          *
*       This exit can be used in FI for callup points 1,2 or 3.        *
*----------------------------------------------------------------------*
*  <--  B_RESULT    T = True  F = False                                *
*----------------------------------------------------------------------*
FORM u100  USING b_result.

*!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
* PLEASE DELETE THE FIRST '*' FORM THE BEGINING OF THE FOLLOWING LINES *
*        IF THE ACCOUNTING MODULE IS INSTALLED IN YOUR SYSTEM:         *
*
*   IF SY-DATUM = BKPF-BUDAT.
*     B_RESULT  = B_TRUE.
*  ELSE.
*    B_RESULT  = B_FALSE.
*  ENDIF.
  RETURN.

ENDFORM.                                                    "U100

*----------------------------------------------------------------------*
*       FORM U101
*----------------------------------------------------------------------*
*       Validação de texto de Cabeçalho (BKTXT) permitido por tipo
*       de documento (BLART)
*----------------------------------------------------------------------
*       Attention: for any FORM one has to make an entry in the
*       form GET_EXIT_TITLES at the beginning of this include
*----------------------------------------------------------------------*
*  <--  B_RESULT    T = True  F = False                                *
*----------------------------------------------------------------------*
FORM u101  USING b_result.

  NEW zclfi_valida_docpagar( )->valida_u101(
    EXPORTING
      iv_doctype = bkpf-blart
      iv_text    = bkpf-bktxt
    CHANGING
      cv_result  = b_result
  ).

ENDFORM.

*----------------------------------------------------------------------*
*       FORM U102
*----------------------------------------------------------------------*
*       Validar retirada de bloqueio doc. em aprovação
*----------------------------------------------------------------------
*       Attention: for any FORM one has to make an entry in the
*       form GET_EXIT_TITLES at the beginning of this include
*----------------------------------------------------------------------*
*  <--  B_RESULT    T = True  F = False                                *
*----------------------------------------------------------------------*
FORM u102  USING b_result.

  NEW zclfi_valida_docpagar( )->valida_u102(
    EXPORTING
      iv_bkpf    = bkpf
      iv_bseg    = bseg
    CHANGING
      cv_result  = b_result
  ).

ENDFORM.

FORM u103  USING b_result.

  INCLUDE zfii_verif_ret_bloqueio IF FOUND.

ENDFORM.

*---------------------------------------------------------------------*
*       FORM ZBFA                                                     *
*---------------------------------------------------------------------*
*  Checar se há algum adiantamento em aberto em qualquer empresa      *
*  do grupo.                                                          *
*---------------------------------------------------------------------*
FORM zbfa USING b_result.

  INCLUDE zfii_verif_adiantam IF FOUND.

ENDFORM.

*---------------------------------------------------------------------*
*       FORM MTRA                                                     *
*---------------------------------------------------------------------*
*  Validação num nota fiscal em MB0A se incorreto                     *
*---------------------------------------------------------------------*
FORM mtra USING b_result.

  INCLUDE zfii_valid_num_nota_fiscal IF FOUND.

ENDFORM.

*---------------------------------------------------------------------*
*       FORM ZNGL                                                     *
*---------------------------------------------------------------------*
*  Validação new GL                                                   *
*---------------------------------------------------------------------*
FORM zngl USING b_result.
  INCLUDE zfii_valid_new_gl IF FOUND.

ENDFORM.
