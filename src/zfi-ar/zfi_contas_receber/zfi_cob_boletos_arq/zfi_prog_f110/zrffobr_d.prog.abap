***********************************************************************
***                      © 3corações                                ***
***********************************************************************
***                                                                   *
*** DESCRIÇÃO: F110 geração de arquivo remessa envio                  *
*** AUTOR    : Alysson Anjos – META                                   *
*** FUNCIONAL: Raphael Rocha – META                                   *
*** DATA     : 09/09/2021                                             *
***********************************************************************
*** HISTÓRICO DAS MODIFICAÇÕES                                        *
***-------------------------------------------------------------------*
*** DATA      | AUTOR        | DESCRIÇÃO                              *
***-------------------------------------------------------------------*
***           |              |                                        *
***********************************************************************
************************************************************************
*                                                                      *
*  Boleto print program RFFOBR_D - exclusively used in Brazil          *
*  creates DME file with duplicata data and printout of boletos, a     *
*  brazilian remittance form, reflecting the DME file (duplicata) data *
************************************************************************


*----------------------------------------------------------------------*
* Program includes:                                                    *
*                                                                      *
* RFFORI0M  Definition of macros                                       *
* RFFORI00  international data definitions                             *
* RFFORI01  check and boleto creation                                  *
* RFFORI06  remittance advice                                          *
* RFFORI07  payment summary list                                       *
* RFFORI99  international subroutines                                  *
* RFFORIB0  Additional declarations for Brazil                         *
* ZRFFORIY1 Payment Medium Include (BRAZIL): DME in A/R                *
* RFFORIY9  International Payment Medium Include: General Subroutines  *
*           in Brazil                                                  *
*----------------------------------------------------------------------*

*--------------------------------------------------------------------*
* Change history of  Form Development
* Program description:
*   - Author: Geeta L. Agashe (C5056173)
*     Date : 07/03/2005
*     Short description of the program:
*     - International Payment Media - Boleto (Brazil)
*  	- The output is displayed in PDF format.
*        - Interface : J_1B_DUPLICATA
*        - PDF Form  : J_1B_BOLETO_ITAU
*--------------------------------------------------------------------*

*----------------------------------------------------------------------*
* report header                                                        *
*----------------------------------------------------------------------*

REPORT zrffobr_d
  LINE-SIZE 132
  MESSAGE-ID f0
  NO STANDARD PAGE HEADING.

*----------------------------------------------------------------------*
*  segments and tables for prenumbered checks                          *
*----------------------------------------------------------------------*

TABLES:
  reguh,
  regup.




*----------------------------------------------------------------------*
*  macro definitions                                                   *
*----------------------------------------------------------------------*

INCLUDE rffori0m.

***********Start of PDF conversion ,Date: 17/03/2005 ,C5056173
INCLUDE rfforip1.
************End  of PDF conversion ,Date: 17/03/2005 ,C5056173

CONSTANTS: gc_modulo TYPE ztca_param_val-modulo  VALUE 'FI-AR',
           gc_chave1 TYPE ztca_param_val-chave1  VALUE 'EMP2000',
           gc_chv_md TYPE ztca_param_val-chave2  VALUE 'MORA_DIA',
           gc_chv_ac TYPE ztca_param_val-chave3  VALUE 'ATRA_CLI',
           gc_chv_pc TYPE ztca_param_val-chave2  VALUE 'PERCENT',
           gc_chv_mt TYPE ztca_param_val-chave3  VALUE 'MULTACLI',
           gc_a10_df TYPE j_1bza10               VALUE '0000'.

INITIALIZATION.

*----------------------------------------------------------------------*
*  parameters and select-options                                       *
*----------------------------------------------------------------------*

  block 1.
  SELECT-OPTIONS:
    sel_zawe FOR  reguh-rzawe,              "payment method
    sel_uzaw FOR  reguh-uzawe,              "payment method supplement
    sel_gsbr FOR  reguh-srtgb,              "business area
    sel_hbki FOR  reguh-hbkid NO-EXTENSION NO INTERVALS, "house bank id
    sel_hkti FOR  reguh-hktid NO-EXTENSION NO INTERVALS. "account id
  SELECTION-SCREEN:
  BEGIN OF LINE,
  COMMENT 01(30) TEXT-106 FOR FIELD par_stap,
  POSITION POS_LOW.
  PARAMETERS:
    par_stap LIKE rfpdo-fordstap.           "check lot number
  SELECTION-SCREEN:
  COMMENT 40(30) textinfo FOR FIELD par_stap,
  END OF LINE.
  PARAMETERS:
    par_rchk LIKE rfpdo-fordrchk.           "Restart from
  SELECT-OPTIONS:
    sel_waer FOR  reguh-waers,              "currency
    sel_vbln FOR  reguh-vblnr.              "payment document number
  SELECTION-SCREEN END OF BLOCK 1.

  block 2.
  auswahl: zdru z, xdta w, avis a, begl b.
  auswahl_alv_list.
  spool_authority.                         "Spoolberechtigung
  SELECTION-SCREEN:
  BEGIN OF LINE.
  PARAMETERS:
    par_dupl AS CHECKBOX.
  SELECTION-SCREEN:
  COMMENT 03(28) TEXT-200 FOR FIELD par_dupl,
  COMMENT pos_low(10) TEXT-201 FOR FIELD par_prdu.
  PARAMETERS:
    par_prdu LIKE rfpdo-fordpriw VISIBLE LENGTH 11.
  SELECTION-SCREEN:
  POSITION POS_HIGH.
  PARAMETERS:
    par_sodu LIKE rfpdo1-fordsofw.
  SELECTION-SCREEN:
  COMMENT 60(18) TEXT-202 FOR FIELD par_sodu,
  END OF LINE.
  SELECTION-SCREEN END OF BLOCK 2.

  block 3.
  PARAMETERS:
    par_unix LIKE rfpdo2-fordnamd,          "Filename (DME case)
    par_dtyp LIKE rfpdo-forddtyp,           "Output medium
    par_crlf LIKE rfpdo1-fordcrlf,          "Auswahl des Zeilenvorschubs
    par_zfor LIKE rfpdo1-fordzfor,          "different form
    par_fill LIKE rfpdo2-fordfill,          "filler for spell_amount
    par_anzb LIKE rfpdo2-fordanzb,          "no. of accompanying sheets
    par_anzp LIKE rfpdo-fordanzp,           "number of test prints
    par_maxp LIKE rfpdo-fordmaxp,           "no of items in summary list
    par_belp LIKE rfpdo-fordbelp,           "payment doc. validation
    par_epos LIKE rfpdo-fordepos,           "display line items
    "in payment carrier
    par_espr LIKE rfpdo-fordespr,           "texts in reciepient's lang.
    par_isoc LIKE rfpdo-fordisoc,           "currency in ISO code
    par_nosu LIKE rfpdo2-fordnosu.          "no summary page


  SELECTION-SCREEN END OF BLOCK 3.

  PARAMETERS:
    par_vari(12) TYPE c           NO-DISPLAY,
    par_sofo(1)  TYPE c           NO-DISPLAY.
  SELECTION-SCREEN BEGIN OF BLOCK 4 WITH FRAME TITLE TEXT-250.
  PARAMETERS:
*    par_fbla AS CHECKBOX.              "Option for Febraban 4.0
*    par_fbla TYPE FIAPBR_VERSION DEFAULT '087'.
      par_fbla TYPE fiapbr_version DEFAULT '089'. "sNote 2555959
  PARAMETERS par_brla TYPE fiapbr_brad_version VALUE CHECK.
  SELECTION-SCREEN END OF BLOCK 4.


* temporary help variable to store par_xdta
  DATA: hlp_xdta(1)  TYPE c.

  CONSTANTS format_name(7) TYPE c VALUE 'CBnnnnX'.
  DATA:company_cnpj(18) TYPE c.

*----------------------------------------------------------------------*
*  Default values for parameters and select-options                    *
*----------------------------------------------------------------------*

  PERFORM init.
  textzdru = TEXT-203.

  sel_zawe-low    = 'D'.                                   "D <=> Boleto
  sel_zawe-option = 'EQ'.
  sel_zawe-sign   = 'I'.
  APPEND sel_zawe.

  par_zfor = 'J_1B_BOLETO_ITAU'.
  par_belp = space.
  par_epos = 'X'.
  par_zdru = 'X'.
  par_xdta = space.
  par_dtyp = '0'.
  par_avis = space.
  par_begl = 'X'.
  par_crlf = 2.
  par_fill = space.
  par_anzp = 2.
  par_espr = space.
  par_isoc = space.
  par_maxp = 9999.

*----------------------------------------------------------------------*
*  tables / fields / field-groups / at selection-screen                *
*----------------------------------------------------------------------*

  INCLUDE rffori00.



  PERFORM scheckdaten_eingabe USING par_rchk
                                    par_stap
                                    textinfo.

* temporary solution: to enable Boleto print and DME file creation at
* the same time, reset xdta-variable before calling rffori00 check to
* prevent errormessage e067 (this takes place in RFFORI00 at event
* at selection-screen)
  IF par_zdru NE space. " Note 1451083
    par_xdta = hlp_xdta.                                    "temp. sol.
  ENDIF.                " Note 1451083


AT SELECTION-SCREEN ON par_xdta.                        "temp. sol.
  IF par_xdta NE space AND par_zdru NE space.             "temp. sol.
    hlp_xdta = par_xdta.                                 "temp. sol.
    CLEAR par_xdta.                                      "temp. sol.
  ENDIF.                                                  "temp. sol.

AT SELECTION-SCREEN OUTPUT.
  LOOP AT SCREEN.
    IF screen-group1 EQ 1.
      screen-input = 0.
      MODIFY SCREEN.
    ENDIF.
    IF screen-name EQ 'ZW_ZBUKR-HIGH' OR
       screen-name EQ '%_ZW_ZBUKR_%_APP_%-VALU_PUSH'.
      screen-active = 0.
      MODIFY SCREEN.
    ENDIF.
  ENDLOOP.

  auswahl_alv_list_f4_and_check.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR par_stap.
  CALL FUNCTION 'F4_CHECK_LOT'
    EXPORTING
      i_xdynp      = 'X'
      i_dynp_progn = 'ZRFFOBR_D'
      i_dynp_dynnr = '1000'
      i_dynp_zbukr = 'ZW_ZBUKR-LOW'
      i_dynp_hbkid = 'SEL_HBKI-LOW'
      i_dynp_hktid = 'SEL_HKTI-LOW'
    IMPORTING
      e_stapl      = par_stap
    EXCEPTIONS
      OTHERS       = 0.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR par_zfor.
  PERFORM f4_formular USING par_zfor.

AT SELECTION-SCREEN ON par_zfor.
  IF par_zfor NE space.
    SET CURSOR FIELD 'PAR_ZFOR'.
    CALL FUNCTION 'FORM_CHECK'
      EXPORTING
        i_pzfor = par_zfor.
  ENDIF.

*----------------------------------------------------------------------*
*  Checks for DTA
*----------------------------------------------------------------------*

  IF par_xdta NE space.
    IF par_dtyp EQ space.
      par_dtyp = '0'.                    "Disk in TemSe
    ENDIF.
    IF par_dtyp NA '012'.
      SET CURSOR FIELD 'PAR_DTYP'.
      MESSAGE e068.
    ENDIF.
  ENDIF.


*----------------------------------------------------------------------*
*  batch heading (for the payment summary list)                        *
*----------------------------------------------------------------------*

TOP-OF-PAGE.

  IF flg_begleitl EQ 1.
    PERFORM kopf_zeilen.                                    "RFFORI07
  ENDIF.



*----------------------------------------------------------------------*
*  preparations                                                        *
*----------------------------------------------------------------------*

START-OF-SELECTION.


  hlp_temse  = '0---------'.           "Keine TemSe-Verwendung
  hlp_filler = par_fill.
  hlp_auth   = par_auth.               "spool authority
  PERFORM vorbereitung.
  PERFORM scheckdaten_pruefen USING par_rchk
                                    par_stap.

*----------------------------------------------------------------------*
* Additional declarations for Brazil
*----------------------------------------------------------------------*

  INCLUDE rfforib0.
  INCLUDE rfforib2.

*----------------------------------------------------------------------*
*  check and extract data                                              *
*----------------------------------------------------------------------*
GET reguh.

  CHECK sel_zawe.
  CHECK sel_uzaw.
  CHECK sel_gsbr.
  CHECK sel_hbki.
  CHECK sel_hkti.
  CHECK sel_waer.
  CHECK sel_vbln.
  PERFORM check_reguh_afle_compatible.       " AFLE compatible mode only)
  PERFORM pruefung.
  PERFORM scheckinfo_pruefen.                               "RFFORI01
  PERFORM extract_vorbereitung.

* fill currency information
  PERFORM curr_fill TABLES currtab
                    USING reguh-zbukr reguh-hbkid
                          reguh-waers.

GET regup.

  PERFORM extract.
  IF reguh-zbukr NE regup-bukrs.
    tab_uebergreifend-zbukr = reguh-zbukr.
    tab_uebergreifend-vblnr = reguh-vblnr.
    COLLECT tab_uebergreifend.
  ENDIF.

*----------------------------------------------------------------------*
*  print checks, remittance advices and lists                          *
*----------------------------------------------------------------------*
END-OF-SELECTION.


  IF flg_selektiert NE 0.

    IF par_zdru EQ 'X'.
      hlp_zforn = par_zfor.
      hlp_checf_restart = par_rchk.
      PERFORM schecknummern_sperren.                        "RFFORI01

***********Start of Commenting ,Date: 15/03/2005 ,C5056173
*      PERFORM SCHECK.                    "RFFORI01
*************End of Commenting ,Date: 15/03/2005 ,C5056173

***********Start of PDF conversion ,Date: 15/03/2005 ,C5056173
      PERFORM scheck_pdf.                                   "ZRFFORIY1
************End  of PDF conversion ,Date: 15/03/2005 ,C5056173

      PERFORM schecknummern_entsperren.                     "RFFORI01
    ENDIF.

    IF par_xdta EQ 'X'.
      PERFORM dme_brazil_du.                                "ZRFFORIY1
    ENDIF.

    IF par_dupl EQ 'X'.
      par_sofz = par_sodu.
      par_priz = par_prdu.
      PERFORM sammelueberweisung.                           "RFFORI08
    ENDIF.

    IF par_avis EQ 'X'.
      PERFORM avis.                                         "RFFORI06
    ENDIF.

    IF par_begl EQ 'X' AND par_maxp GT 0.
      flg_bankinfo = 1.
      PERFORM begleitliste.                                 "RFFORI07
    ENDIF.

  ENDIF.

  PERFORM fehlermeldungen.

  PERFORM information.

*----------------------------------------------------------------------*
*  subroutines for check print and prenumbered checks                  *
*----------------------------------------------------------------------*
  INCLUDE rffori01.



*----------------------------------------------------------------------*
*  subroutines for remittance advices                                  *
*----------------------------------------------------------------------*
  INCLUDE rffori06.



*----------------------------------------------------------------------*
*  subroutines for the payment summary list                            *
*----------------------------------------------------------------------*
  INCLUDE rffori07.



*----------------------------------------------------------------------*
*  subroutines for collective order                                    *
*----------------------------------------------------------------------*
  INCLUDE rffori08.



*----------------------------------------------------------------------*
*  international subroutines                                           *
*----------------------------------------------------------------------*
  INCLUDE rffori99.



*----------------------------------------------------------------------*
*  subroutine DME for Brazil                                           *
*----------------------------------------------------------------------*
  INCLUDE zrfforiy1.



*----------------------------------------------------------------------*
*  general subroutines for Brazil                                      *
*----------------------------------------------------------------------*
  INCLUDE rfforiy9.

  INCLUDE rffobr_d_open_sapscriptf01.
