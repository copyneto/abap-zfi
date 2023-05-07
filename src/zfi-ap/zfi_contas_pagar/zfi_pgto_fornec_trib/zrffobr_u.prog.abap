************************************************************************
*                                                                      *
*  Sammelüberweisungsauftrag-Druckprogramm J_1BPPTR
*                                                                      *
************************************************************************


*----------------------------------------------------------------------*
* Das Programm includiert:                                             *
*                                                                      *
* RFFORI0M  Makrodefinition für den Selektionsbildaufbau               *
* RFFORI00  Deklarationsteil der Zahlungsträger-Druckprogramme
* RFFORIB0  Additional declarations for Brazil                         *
* RFFORIY2  DME A/P Brazil, Bancos Itau and Bradesco                   *
* RFFORI06  Avis                                                       *
* RFFORI07  Zahlungsbegleitliste                                       *
* RFFORI08 Sammelüberweisungsauftrag                                   *
* RFFORI99  Allgemeine Unterroutinen der Zahlungsträger-Druckprogramme *
* RFFORIY9  Additional subroutines for Brazil                          *
*----------------------------------------------------------------------*



*----------------------------------------------------------------------*
* Report-Header                                                        *
*----------------------------------------------------------------------*
REPORT rffobr_u MESSAGE-ID f0

  LINE-SIZE 132
  NO STANDARD PAGE HEADING.



*----------------------------------------------------------------------*
*  Segmente                                                            *
*----------------------------------------------------------------------*
TABLES:
  reguh,
  regup.



*----------------------------------------------------------------------*
*  Makrodefinitionen                                                   *
*----------------------------------------------------------------------*
INCLUDE rffori0m.

*---------------------------------------------------------------------*
*   PDF Form Data Declaration By C5056155 on 22-Mar-2005
*---------------------------------------------------------------------*
INCLUDE rfforip1.


INITIALIZATION.

*----------------------------------------------------------------------*
*  Parameter und Select-Options                                        *
*----------------------------------------------------------------------*
  block 1.
  SELECT-OPTIONS:
    sel_zawe FOR  reguh-rzawe,         "Payment methods
    sel_uzaw FOR  reguh-uzawe,         "Zahlwegzusatz
    sel_hbki FOR  reguh-hbkid,         "Hausbank (Kurzschlüssel)
    sel_hkti FOR  reguh-hktid,         "Kontenverbindung (Kurzschlüssel)
    sel_waer FOR  reguh-waers,         "Währungsschlüssel
    sel_vbln FOR  reguh-vblnr.         "Zahlungsbelegnummer
  SELECTION-SCREEN END OF BLOCK 1.

  block 2.
  auswahl: zdru z, xdta w, avis a, begl b.
  spool_authority.                         "Spoolberechtigung
  SELECTION-SCREEN END OF BLOCK 2.

  block 3.
  PARAMETERS:
    par_unix LIKE fpm_selpar-pfile,     "RFPDO2-FORDNAMD,     "Filename (bei DTA)
    par_dtyp LIKE rfpdo-forddtyp,      "Ausgabemedium
    par_crlf LIKE rfpdo1-fordcrlf,     "Auswahl des Zeilenvorschubs
    par_anzp LIKE rfpdo-fordanzp,      "Anzahl Probedrucke
    par_anzb LIKE rfpdo2-fordanzb,     "Anzahl Probedrucke
    par_maxp LIKE rfpdo-fordmaxp,      "max. Postenzahl in Begleitliste
    par_epos LIKE rfpdo-fordepos,      "Einzelposten auf Zahlungsträger
    par_belp LIKE rfpdo-fordbelp,      "Zahlungsbeleg-Verprobung
    par_espr LIKE rfpdo-fordespr,      "Texte in Empfängersprache
    par_isoc LIKE rfpdo-fordisoc.      "Währung in ISO-Code
  SELECTION-SCREEN END OF BLOCK 3.

  block 4.
  PARAMETERS:
    par_baav LIKE j_1bdmexa-a27,         "Avis from bank to vendor
* Version selection for ITAU 010, 020, 050
    par_ver  TYPE fiapbr_version DEFAULT '010',   " Version number
* Version selection for Febraban 030, 040, 050
*  PAR_FBLA(3) type n default '050'.
*  PAR_FBLA TYPE FIAPBR_VERSION DEFAULT '087'.
    par_fbla TYPE fiapbr_version DEFAULT '089'.  "SNOTE no 2555959

  PARAMETERS: par_j52 TYPE j_1bj52 DEFAULT 'X'.          "Checkbox for the segment J-52

  PARAMETERS: par_amt LIKE reguh-rwbtr DEFAULT '250000.00'.     "J-52 Threshold Value

* BANK ACCOUNT RAZÃO NUMBER : Bradesco_HR
* To be filled differently by different companies depending on
* whether they are public, private or mixed enterprises
  PARAMETERS:
  par_razo(5) TYPE n.

  PARAMETERS par_brla TYPE fiapbr_brad_version VALUE CHECK.

  SELECTION-SCREEN END OF BLOCK 4.

  PARAMETERS:
    par_vari(12) TYPE c          NO-DISPLAY,
    par_sofo(1)  TYPE c          NO-DISPLAY.

  CONSTANTS:
    format_name(6) TYPE c VALUE 'SISPAG'.

  DATA:gs_zwels TYPE dzwels, "Note 2033785
       gs_land1 TYPE land1.

*----------------------------------------------------------------------*
*  Vorbelegung der Parameter und Select-Options                        *
*----------------------------------------------------------------------*
  PERFORM init.
  textzdru = TEXT-101.
  sel_zawe-low    = 'U'.
  sel_zawe-option = 'EQ'.
  sel_zawe-sign   = 'I'.
  APPEND sel_zawe.

  par_belp = space.
  par_zdru = 'X'.
  par_epos = 'X'.
  par_xdta = space.
  par_dtyp = '0'.
  par_avis = space.
  par_begl = 'X'.
  par_crlf = 2.
  par_anzp = 2.
  par_anzb = 2.
  par_espr = space.
  par_isoc = space.
  par_maxp = 9999.



*----------------------------------------------------------------------*
*  Tabellen / Felder / Field-Groups / At Selection-Screen              *
*----------------------------------------------------------------------*
  INCLUDE rffori00.

*- Prüfungen bei DTA ---------------------------------------------------
  IF par_xdta NE space.
    IF par_dtyp EQ space.
      par_dtyp = '0'.                    "Diskette in TemSe
    ENDIF.
    IF par_dtyp NA '012'.
      SET CURSOR FIELD 'PAR_DTYP'.
      MESSAGE e068.
    ENDIF.
  ENDIF.

AT SELECTION-SCREEN ON par_epos.
  IF par_epos NE space.
    par_epos = 'X'.
  ENDIF.



*----------------------------------------------------------------------*
*  Kopfzeilen (nur bei der Zahlungsbegleitliste)                       *
*----------------------------------------------------------------------*
TOP-OF-PAGE.

  IF flg_begleitl EQ 1.
    PERFORM kopf_zeilen.                                    "RFFORI07
  ENDIF.



*----------------------------------------------------------------------*
*  Felder vorbelegen                                                   *
*----------------------------------------------------------------------*
START-OF-SELECTION.

*- TemSe-Parameter setzen ----------------------------------------------
  hlp_temse = '0---------'.            "Reportspezif. TemSe-Parameter
  hlp_auth  = par_auth.                "spool authority

  PERFORM vorbereitung.

  INCLUDE rfforib0 .                             "Additional declarations
  INCLUDE rfforib2.

*----------------------------------------------------------------------*
*  Daten prüfen und extrahieren                                        *
*----------------------------------------------------------------------*
GET reguh.

  CHECK sel_zawe.
  CHECK sel_uzaw.
  CHECK sel_hbki.
  CHECK sel_hkti.
  CHECK sel_waer.
  CHECK sel_vbln.

  PERFORM check_reguh_afle_compatible.       " AFLE compatible mode only)

  PERFORM pruefung.
  PERFORM extract_vorbereitung.

  PERFORM sortbank.
* check ITAU layout version number
  IF reguh-ubnkl(3) EQ '341'.
    IF par_ver NE '010' AND par_ver NE '020' AND
    par_ver NE '050' AND par_ver NE '080' AND par_fbla EQ ' '. "N1897495
      MESSAGE e420(fb) WITH TEXT-121.
    ENDIF.
  ENDIF.

* check Febraban layout version number
  IF reguh-ubnkl(3) NE '237' AND reguh-ubnkl(3) NE '341'.
    IF par_fbla NE '030' AND par_fbla NE '040' AND
*   PAR_FBLA ne '050' and PAR_FBLA ne '087' and par_ver eq ' '."N1897495
      par_fbla NE '050' AND par_fbla NE '089' AND par_ver EQ ' '. "SNOTE no 2555959
      MESSAGE e420(fb) WITH TEXT-122.
    ENDIF.
  ENDIF.

GET regup.
  PERFORM sortboleto.
  PERFORM extract.


*----------------------------------------------------------------------*
*  Bearbeitung der extrahierten Daten                                  *
*----------------------------------------------------------------------*
END-OF-SELECTION.

  IF flg_selektiert NE 0.

    IF par_xdta EQ 'X'.
      PERFORM dme_brazil.                                   "RFFORIY2
    ENDIF.

    IF par_zdru EQ 'X'.
      PERFORM sammelueberweisung.                           "RFFORI08
    ENDIF.

    IF par_avis EQ 'X'.
      PERFORM avis.                                        "RFFORI06
    ENDIF.

    IF par_begl EQ 'X' AND par_maxp GT 0.
      flg_bankinfo = 2.
      PERFORM begleitliste.                                 "RFFORI07
    ENDIF.

  ENDIF.

  PERFORM fehlermeldungen.

*  PERFORM INFORMATION.
  PERFORM information_2.



*----------------------------------------------------------------------*
*  Unterprogramm Sammelüberweisungsauftrag                             *
*----------------------------------------------------------------------*
  INCLUDE rffori08.


*----------------------------------------------------------------------
*  Subroutine DME for Brazil
*----------------------------------------------------------------------
*  INCLUDE RFFORIY2.
  INCLUDE zrfforiy2.



*----------------------------------------------------------------------*
*  Unterprogramm Avis ohne Allongeteil                                 *
*----------------------------------------------------------------------*
  INCLUDE rffori06.



*----------------------------------------------------------------------*
*  Unterprogramm Begleitliste                                          *
*----------------------------------------------------------------------*
  INCLUDE rffori07.



*----------------------------------------------------------------------*
*  Allgemeine Unterroutinen                                            *
*----------------------------------------------------------------------*
  INCLUDE rffori99.
  INCLUDE rfforiy9.                                  "Subroutines Brazil

*&---------------------------------------------------------------------*
*& Form f_trata_city_a16
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- J_1BDMEXA_A16
*&---------------------------------------------------------------------*
FORM f_trata_city_a16  CHANGING cg_a16.

  DATA: lv_number(15) TYPE n,
        lv_spaces(5)  TYPE c.

  IF regup-xblnr CS '-'.

    SPLIT regup-xblnr AT '-' INTO DATA(lv_part1) DATA(lv_part2).
    lv_number = lv_part1.
  ELSE.
    lv_number = regup-xblnr.
  ENDIF.

  CONCATENATE lv_number lv_spaces INTO cg_a16.

ENDFORM.
