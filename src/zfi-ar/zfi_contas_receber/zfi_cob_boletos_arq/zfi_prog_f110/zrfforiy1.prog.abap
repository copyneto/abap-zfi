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
* 3.0A                                                                 *
* WGYS11K127228 25051995 Verbesserungen für HR-Überweisungen           *
*                                                                      *
* Includebaustein ZRFFORIY1 zu den Formulardruckprogrammen              *
*                  RFFOBR_A und RFFOBR_D                               *
* mit Unterprogrammen für den Datenträgeraustausch Brasilien           *
*                                                                      *
* Unterprogramm               gerufen von FORM  /  von REPORT          *
* -------------------------------------------------------------------- *
* DME_BRAZIL_DU                          RFFOBR_A und RFFOBR_D         +
*                                                                      *
************************************************************************

DATA:
  total_file   TYPE p DECIMALS 2,           "total per file, gross
  agency       LIKE reguh-ubnkl,
  hlp_zinso    LIKE t056p-zsoll,
  hlp_interest LIKE regud-dmbtr,          "for interest calculation
  clstr(18)    TYPE c.

DATA : lv_rebate LIKE bsid-dmbtr,
       hlp_vblnr LIKE reguh-vblnr.

DATA: l_xblnr1  TYPE char16,    "note 1087535
      l_xblnr2  TYPE char16,
      val_xblnr LIKE regup-xblnr,
      par_xblnr TYPE c.

DATA: gv_p07(1) TYPE c.                                     "N1897495

DATA:

  dta_cr(1)   TYPE c,  "Carriage Return
  dta_lf(1)   TYPE c,  "Line Feed
  dta_crlf(2) TYPE c.    "carriage return + line feed

*----------------------------------------------------------------------*
* FORM DME_BRAZIL_DU                                                   *
*----------------------------------------------------------------------*
* Ausgabe der Datenträgeraustausch-Information in Band- oder           *
* Diskettenformat für Brasilien                                        *
* gerufen von END-OF-SELECTION (RFFOBR_D)                              *
*----------------------------------------------------------------------*
* keine USING-Parameter                                                *
*----------------------------------------------------------------------*
FORM dme_brazil_du.


  TABLES:
    j_1bdmeyh,                         "DME Brazil, header Itau
    j_1bdmeya,                         "DME Brazil, details Itau
    j_1bdmeyt,                         "DME Brazil, trailer Itau

    j_1bdmezh,                         "DME Brazil, header Bradesco
    j_1bdmeza,                         "DME Brazil, details Bradesco
*                                       Trailer Bradesco = Itau

    j_1bdmexh1,                        "DME Brazil, header Febraban
    j_1bdmexh3,                        "DME Brazil, lot header Febraban
    j_1bdmexp,                         "DME Brazil, segment P Febraban
    j_1bdmexq,                         "DME Brazil, segment Q Febraban
    j_1bdmext3,                        "DME Brazil, lot trailer Febraban
    j_1bdmext1,                        "DME Brazil, trailer Febraban

    knb1, knbk,                        "Various data
    t012a.                             "Bank transaction = Carteira


  DATA:
    dta_record(400) TYPE c.           "Teil des EP-Satzes bei DTA Disk.

  CALL FUNCTION 'FI_DME_CHARACTERS'
    IMPORTING
      e_cr   = dta_cr
      e_lf   = dta_lf
      e_crlf = dta_crlf.

*----------------------------------------------------------------------*
* Vorbereitung zum Datenträgeraustausch                                *
*----------------------------------------------------------------------*

* Sortieren des Datenbestandes unter Beachtung von Gut/Lastschrift
  SORT BY
    reguh-zbukr                        "Zahlender Buchungskreis
    reguh-ubnks                        "Bankland unserer Bank
    reguh-ubnky                        "Bankkey zur Übersortierung
    regud-xeinz                         "X - Lastschrift
    reguh-ubnkl                        "Bankleitzahl unserer Bank
    reguh-ubknt                        "Kontonummer bei unserer Bank
    reguh-zbnks                        "Bankland Zahlungsempfänger
    reguh-zbnky                        "Bankkey zur Übersortierung
    reguh-zbnkl                        "Bankleitzahl Zahlungsempfänger
    reguh-zbnkn                        "Bank-Ktonummer Zahlungsempfänger
    reguh-lifnr                        "Kreditorennummer
    reguh-kunnr                        "Debitorennummer
    reguh-empfg                        "Zahlungsempfänger CPD
    reguh-vblnr                        "Zahlungsbelegnummer
    regup-belnr.                       "Internal document number

*----------------------------------------------------------------------*
* Abarbeiten der extrahierten Daten                                    *
*----------------------------------------------------------------------*
  LOOP.

    AT FIRST.                                               "n2993717

      IF hlp_temse NA par_dtyp.        "File System (No TemSe) "n2993717

        IF par_unix EQ space.          "Unspecified filename   "n2993717
          par_unix      = 'CB'.                             "n2993717
          CONCATENATE sy-datum+6(2) sy-datum+4(2) sy-datum+0(4) "n2993717
            INTO par_unix+2(8).                             "n2993717
          WRITE sy-uzeit TO par_unix+10(6).                 "n2993717
          par_unix+16    = 'X.REM'.                         "n2993717
        ENDIF.                                              "n2993717

        IF sy-cprog = 'RFFOBR_A'.                           "n2993717
          CASE reguh-ubnkl(3).   "Bank                         "n2993717
            WHEN '341'.                                     "n2993717
              hlp_dtfor = 'ITAU'.                           "n2993717
            WHEN '237'.                                     "n2993717
              hlp_dtfor = 'BRADESCO'.                       "n2993717
            WHEN OTHERS.                                    "n2993717
              hlp_dtfor = 'FEBRABAN'.                       "n2993717
          ENDCASE.                                          "n2993717
        ELSEIF sy-cprog = 'RFFOBR_D'.                       "n2993717
          hlp_dtfor = 'BOLETO'.                             "n2993717
        ENDIF.                                              "n2993717

      ELSE.                                                 "n2993717
        hlp_dtfor   = 'CB'.                                 "n2993717
        WRITE sy-datum TO hlp_dtfor+2(4) DDMMYY.            "n2993717
        hlp_dtfor+6 = 'X'.                                  "n2993717
      ENDIF.                                                "n2993717

      cnt_filenr = 0.                "# erstellter Dateien     "n2993717

    ENDAT.                                                  "n2993717

*-- Neuer zahlender Buchungskreis --------------------------------------
    AT NEW reguh-zbukr.

      PERFORM buchungskreis_daten_lesen.
      PERFORM read_branch_data.

*     Überschrift modifizieren
*     modify title of payment method
      t042z-text1 = text_004.

*     Spoolparameter zur Ausgabe von Begleitzettel und Formularabschluß
*     specify spool parameters for print of sheet and summary
      itcpo-tdpageslct  = space.       "all pages
      itcpo-tdnewid     = 'X'.         "create new spool dataset
      itcpo-tdcopies    = 1.           "one copy
      itcpo-tddest      = par_priw.    "name of printer
      itcpo-tdpreview   = space.       "no preview
      itcpo-tdcover     = space.       "Kein Titelblatt
      itcpo-tddataset   = 'LIST7S'.    "dataset name
      IF zw_xvorl EQ space.
        itcpo-tdsuffix1 = par_priw.    "name of printer
      ELSE.
        itcpo-tdsuffix1 = 'TEST'.      "test run
      ENDIF.
      itcpo-tdsuffix2   = par_vari.    "name of report variant
      itcpo-tdimmed     = par_sofw.    "immediately?
      itcpo-tddelete    = space.       "do not delete after print
      itcpo-tdtitle     = t042z-text1. "short description
      itcpo-tdcovtitle  = t042z-text1. "Cover

      IF par_priw EQ space.
        flg_dialog = 'X'.
      ELSE.
        flg_dialog = space.
      ENDIF.




*     Formular mit Begleitzettel öffnen
*     open form with sheet


      CALL FUNCTION 'OPEN_FORM'
        EXPORTING
          form     = t042e-wforn
          device   = 'PRINTER'
          language = t001-spras
          options  = itcpo
          dialog   = flg_dialog
        EXCEPTIONS
          form     = 1.
      IF sy-subrc EQ 1.                "abend:
        IF sy-batch EQ space.          "form is not active
          MESSAGE a069 WITH t042e-wforn.
        ELSE.
          MESSAGE s069 WITH t042e-wforn.
          MESSAGE s094.
          STOP.
        ENDIF.
      ENDIF.

    ENDAT.


*-- Neue Hausbank ------------------------------------------------------
    AT NEW reguh-ubnkl.

      PERFORM hausbank_daten_lesen.

      PERFORM zahlweg_daten_lesen.
      hlp_rzawe = reguh-rzawe.
    ENDAT.

*-- Neue Kontonummer bei der Hausbank ----------------------------------
*-- new account number with house bank ---------------------------------
    AT NEW reguh-ubknt.

*     Kontonummer ohne Aufbereitungszeichen speichern
*     store numerical account number for code line

      regud-obknt = reguh-ubknt.


*       Neue Diskette/ neues Band bei Wechsel
*         a) des Buchungskreises
*         b) der Hausbank
*         c) des Kontos bei der Hausbank
*
*       create new disk/new tape if
*         a) company code
*         b) bank number of house bank
*         c) bank account
*       changes.

*     Neue Diskette/Band anlegen
*     create new disk/tape
      PERFORM zusatzfeld_fuellen USING *regut-dtkey 'BRA'.
      PERFORM datei_oeffnen.
      sum_regut     = 0.


*     Felder für Formularabschluß initialisieren
      cnt_formulare = 0.
      total_file    = 0.
      cnt_hinweise  = 0.
      sum_abschluss = 0.
      cnt_records   = 0.

*----HEADER-------------------------------------------------------------
      CASE reguh-ubnkl(3).                         "Bank

        WHEN '341'.                             "Itau
          PERFORM fill_header_itau.
          PERFORM store_on_file USING j_1bdmeyh.
          PERFORM cr_lf.

        WHEN '237'.                             "Bradesco
          IF par_brla EQ '240'.                             "N2263671
            PERFORM fill_header_bradesco_240.
            PERFORM store_on_file USING j_1bdmexh1.
            PERFORM cr_lf.
            PERFORM store_on_file USING j_1bdmexh3.
            PERFORM cr_lf.
          ELSE.
            PERFORM fill_header_bradesco.
            PERFORM store_on_file USING j_1bdmezh.
            PERFORM cr_lf.
          ENDIF.                                            "N2263671

        WHEN OTHERS.
          PERFORM fill_header_febraban.
          PERFORM store_on_file USING j_1bdmexh1.
          PERFORM cr_lf.
          PERFORM store_on_file USING j_1bdmexh3.
          PERFORM cr_lf.
          cnt_posten  = 0.

      ENDCASE.

*- END HEADER----------------------------------------------------------
    ENDAT.


*-- Neue Empfängerbank -------------------------------------------------
    AT NEW reguh-zbnkl.
      PERFORM empfbank_daten_lesen.
    ENDAT.

    PERFORM read_customer.

*-- Neue Zahlungsbelegnummer -------------------------------------------
    AT NEW reguh-vblnr.

      CLEAR hlp_vblnr.
      PERFORM read_carteira.
      carteira = carttab-carteira.

*     Zahlweg-Daten nachlesen, falls notwendig
      IF reguh-rzawe NE hlp_rzawe.
        PERFORM zahlweg_daten_lesen.
        hlp_rzawe = reguh-rzawe.
        t042z-text1 = text_004.
      ENDIF.

      PERFORM weisungsschluessel_lesen.
      PERFORM zahlungs_daten_lesen.
      PERFORM summenfelder_initialisieren.
      PERFORM belegdaten_schreiben.

      ADD reguh-rbetr TO sum_regut.
    ENDAT.

*--LINE ITEMS-----------------------------------------------------------
    AT daten.

      PERFORM einzelpostenfelder_fuellen.
      PERFORM summenfelder_fuellen.
      total_file  = total_file + regud-dmbtr.

*   REGUP-XREBZ is only <> space when paid together with referenced
*   item, e.g. for credit memo or down payment.
      IF regup-xrebz = space OR regup-shkzg = 'S'.
        IF regup-qsskz NE space AND hlp_vblnr EQ space
        OR regup-qsskz EQ space.

          CASE reguh-ubnkl(3).                       "Bank

            WHEN '341'.                              "Itau
              PERFORM fill_details_itau.
              PERFORM store_on_file USING j_1bdmeya.
              PERFORM cr_lf.

            WHEN '237'.                             "Bradesco
              IF par_brla EQ '240'.                         "N2263671
                PERFORM fill_details_febraban.
                PERFORM store_on_file USING j_1bdmexp.
                PERFORM cr_lf.
                PERFORM store_on_file USING j_1bdmexq.
                PERFORM cr_lf.
              ELSE.
                PERFORM fill_details_bradesco.
                PERFORM store_on_file USING j_1bdmeza.
                PERFORM cr_lf.
              ENDIF.                                        "N2263671

            WHEN OTHERS.
              PERFORM fill_details_febraban.        "Febraban
              PERFORM store_on_file USING j_1bdmexp.
              PERFORM cr_lf.
              PERFORM store_on_file USING j_1bdmexq.
              PERFORM cr_lf.

          ENDCASE.
        ENDIF.
      ENDIF.

      WRITE:
        cnt_hinweise   TO regud-avish,
        cnt_formulare  TO regud-zahlt,
        sum_abschluss  TO regud-summe CURRENCY t001-waers.
      TRANSLATE:
        regud-avish USING ' *',
        regud-zahlt USING ' *',
        regud-summe USING ' *'.

    ENDAT.
*---END LINE ITEMS------------------------------------------------------

    AT END OF reguh-vblnr.
*     Summenfelder hochzählen und aufbereiten
      ADD 1            TO cnt_formulare.
      ADD reguh-rbetr  TO sum_abschluss.
    ENDAT.

*-- end of account of house bank----------------------------------------
    AT END OF reguh-ubknt.

*---fill file trailer--------------------------------------------------

      CASE reguh-ubnkl(3).                         "Bank

        WHEN '341'.                             "Itau
          PERFORM fill_trailer_itau.
          PERFORM store_on_file USING j_1bdmeyt.
          PERFORM cr_lf.

        WHEN '237'.
          IF par_brla EQ '240'.                             "N2263671
            PERFORM fill_trailer_bradesco240.
            PERFORM store_on_file USING j_1bdmext3.
            PERFORM cr_lf.
            PERFORM store_on_file USING j_1bdmext1.
            PERFORM cr_lf.
          ELSE.
            PERFORM fill_trailer_itau.
            PERFORM store_on_file USING j_1bdmeyt.
            PERFORM cr_lf.
          ENDIF.                                            "N2263671

        WHEN OTHERS.                             "Febraban
          PERFORM fill_trailer_febraban.
          PERFORM store_on_file USING j_1bdmext3.
          PERFORM cr_lf.
          PERFORM store_on_file USING j_1bdmext1.
          PERFORM cr_lf.

      ENDCASE.

*---end file trailer----------------------------------------------------

*     find out name of element of sheet
      IF NOT regud-xeinz EQ space.
        hlp_element = '535'.                    "Duplicata
        hlp_eletext = TEXT-535.
      ELSE.
        hlp_element = '538'.               "Credit note to customer
        hlp_eletext = TEXT-535.
      ENDIF.

      PERFORM begleitzettel_schreiben USING cnt_records total_file.
      PERFORM formularabschluss_schreiben.

*     Alte Diskette/altes Band schließen
*     close disk/ tape
      sum_regut = sum_abschluss.       "identisch
      PERFORM datei_schliessen.

    ENDAT.

*-- Ende des zahlenden Buchungskreises ---------------------------------
*-- end of paying company code -----------------------------------------
    AT END OF reguh-zbukr.

      CALL FUNCTION 'CLOSE_FORM'
        IMPORTING
          result = itcpp.

      CLEAR tab_ausgabe.
      tab_ausgabe-name    = itcpp-tdtitle.
      tab_ausgabe-dataset = itcpp-tddataset.
      tab_ausgabe-spoolnr = itcpp-tdspoolid.
      COLLECT tab_ausgabe.

    ENDAT.

  ENDLOOP.

ENDFORM.                               "DME Brazil

*&---------------------------------------------------------------------*
*&      Form  FILL_HEADER_BRADESCO_240
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM fill_header_bradesco_240 .

  CLEAR: j_1bdmexh1, j_1bdmexh3.  "Data set: Header, lot header
  cnt_records = cnt_records + 1.

  j_1bdmexh1-h101      = reguh-ubnkl(3).
  j_1bdmexh1-h102      = 0.                         " count lot
  j_1bdmexh1-h103      = '0'.
  j_1bdmexh1-h104      = space.                     " 9 blanks
  j_1bdmexh1-h105      = '2'.                       " CGC and not CPF
  j_1bdmexh1-h106      = j_1bwfield-cgc_number.

*     Company ID at bank
  CLEAR t045t.
  SELECT SINGLE dtaid FROM t045t INTO j_1bdmexh1-h107
                            WHERE bukrs = reguh-zbukr
                            AND   zlsch = reguh-rzawe
                            AND   hbkid = reguh-hbkid
                            AND   hktid = reguh-hktid.
  IF sy-subrc NE 0.
    SELECT SINGLE dtaid FROM t045t INTO j_1bdmexh1-h107
                          WHERE bukrs = reguh-zbukr
                          AND   zlsch = space  "no payment method maint.
                          AND   hbkid = reguh-hbkid
                          AND   hktid = reguh-hktid.
  ENDIF.

  CALL FUNCTION 'J_1B_CONVERT_BANK'
    EXPORTING
      i_bank = reguh-ubnkl
    IMPORTING
      e_bank = agency
    EXCEPTIONS
      OTHERS = 1.

  j_1bdmexh1-h108   = agency.

  CALL FUNCTION 'READ_ACCOUNT_DATA'
    EXPORTING
      i_bankn = reguh-ubknt
      i_bkont = reguh-ubkon
    IMPORTING
      e_bankn = regud-obknt
      e_cntr1 = j_1bdmexh1-h109
      e_cntr2 = j_1bdmexh1-h111
      e_cntr3 = j_1bdmexh1-h112
    EXCEPTIONS
      OTHERS  = 1.

  j_1bdmexh1-h110   = regud-obknt.
  j_1bdmexh1-h113   = hlp_sadr-name1.
  PERFORM dta_text_aufbereiten USING j_1bdmexh1-h113.
  j_1bdmexh1-h114   = regud-ubnka.
  PERFORM dta_text_aufbereiten USING j_1bdmexh1-h114.
  j_1bdmexh1-h115   = space.                                " 15 blanks
  j_1bdmexh1-h116   = '1'.

  j_1bdmexh1-h117(2)    = sy-datum+6(2).  "dd
  j_1bdmexh1-h117+2(2)  = sy-datum+4(2).  "mm
  j_1bdmexh1-h117+4(4)  = sy-datum(4).    "yyyy

  j_1bdmexh1-h118   = sy-uzeit.
  j_1bdmexh1-h119(6)   = hlp_resultat+2(6).        "File number
*  j_1bdmexh1-h119+6(3) = '087'.                   "File Version 240
  j_1bdmexh1-h119+6(3) = '089'.  "Note no 2555959 "File Version 240

*  End of Registry header

*--Lot Header: start of filling-----------------------------------------
  cnt_records          = cnt_records + 1.

  j_1bdmexh3-h301      = reguh-ubnkl(3).   "Código do Banco
  j_1bdmexh3-h302      =  1.               "Número do Lote
  j_1bdmexh3-h303      = '1'.              "Tipo de Registro
  j_1bdmexh3-h304      = 'R'.              "Tipo de Operação (D/C)
  j_1bdmexh3-h305      =  1.               "Tipo de Serviço
  j_1bdmexh3-h306      =  0.               "Forma de Lançamento

  SHIFT j_1bdmexh3-h306 LEFT DELETING LEADING '0'.
  j_1bdmexh3-h307  = '045'.               "Lot version Feb 8.7

  j_1bdmexh3-h309      =  '2'.
  j_1bdmexh3-h310      = j_1bwfield-cgc_number.
  j_1bdmexh3-h311      = j_1bdmexh1-h107.
  j_1bdmexh3-h312      = j_1bdmexh1-h108.
  j_1bdmexh3-h313      = j_1bdmexh1-h109.
  j_1bdmexh3-h314      = j_1bdmexh1-h110.
  j_1bdmexh3-h315      = j_1bdmexh1-h111.
  j_1bdmexh3-h316      = j_1bdmexh1-h112.
  j_1bdmexh3-h317      = j_1bdmexh1-h113.
  j_1bdmexh3-h321      = j_1bdmexh1-h117.
*--Lot Header: end of filling------------------------------------------

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  FILL_TRAILER_BRADESCO240
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM fill_trailer_bradesco240 .

  CLEAR: j_1bdmext1, j_1bdmext3.  "Data set: trailer, lot trailer

*   Lot trailer
  cnt_records             = cnt_records + 1.

  j_1bdmext3-t301         = reguh-ubnkl(3).
  j_1bdmext3-t302         = 1.
  j_1bdmext3-t303         = '5'.
  j_1bdmext3-t305         = cnt_posten + 2.

*   Trailer
  cnt_records             = cnt_records + 1.

  j_1bdmext1-t101         = reguh-ubnkl(3).
  j_1bdmext1-t102         = '9999'.
  j_1bdmext1-t103         = '9'.
  j_1bdmext1-t105         = space.
  j_1bdmext1-t106         = cnt_records.
  j_1bdmext1-t107(6)      = '000000'.
ENDFORM.
*----------------------------------------------------------------------*
* FORM BEGLEITZETTEL_SCHREIBEN                                         *
*----------------------------------------------------------------------*
* Schreiben eines Begleitzettels pro logische Datei                    *
* write accompanying sheet for each logical file                       *
*----------------------------------------------------------------------*
FORM begleitzettel_schreiben USING cnt_records total_file.

  WRITE cnt_records TO regud-text1(20).           "Total of records
  WRITE total_file TO regud-text2(20).              "Total amount

  DO par_anzb TIMES.

    CALL FUNCTION 'START_FORM'
      EXPORTING
        startpage = 'DTA'.

*   Ausgabe des Begleitzettels
*   write sheet
    CALL FUNCTION 'WRITE_FORM'
      EXPORTING
        window  = 'INLAND'
        element = hlp_element
      EXCEPTIONS
        window  = 1
        element = 2.

    IF sy-subrc EQ 2.
      err_element-fname = t042e-wforn.
      err_element-fenst = 'INLAND'.
      err_element-elemt = hlp_element.
      err_element-text  = hlp_eletext.
      COLLECT err_element.
    ENDIF.

    CALL FUNCTION 'END_FORM'.

  ENDDO.

ENDFORM.                               "BEGLEITZETTEL_SCHREIBEN



*----------------------------------------------------------------------*
* FORM FORMULARABSCHLUSS_SCHREIBEN                                     *
*----------------------------------------------------------------------*
* Schreiben eines Abschlußformulars                                    *
* write summary form                                                   *
*----------------------------------------------------------------------*
FORM formularabschluss_schreiben.


* Übergabe der benützten Zahlwege in die REGUD-Struktur
* copy array of payment methods used into REGUD-field
  CONDENSE hlp_dta_zwels.
  regud-zwels = hlp_dta_zwels.

  CALL FUNCTION 'START_FORM'
    EXPORTING
      startpage = 'LAST'
      language  = t001-spras.

*     Ausgabe des Formularabschlusses für DTA
*     write summary for DME
  CALL FUNCTION 'WRITE_FORM'
    EXPORTING
      window  = 'SUMMARY'
      element = '520'
    EXCEPTIONS
      window  = 1
      element = 2.

  IF sy-subrc EQ 2.
    err_element-fname = t042e-wforn.
    err_element-fenst = 'SUMMARY'.
    err_element-elemt = '520'.
    err_element-text  = TEXT-520.
    COLLECT err_element.
  ENDIF.

  CALL FUNCTION 'END_FORM'.

ENDFORM.                               "FORMULARABSCHLUSS_SCHREIBEN

*-----------------------------------------------------------------------
*---     FORM FILL_HEADER_ITAU                                 ---------
*-----------------------------------------------------------------------

FORM fill_header_itau.

*     DATA  UP_CRLF(2) TYPE X VALUE '0D0A'."carriage return + line feed
*     Fill data set H
  CLEAR: j_1bdmeyh.   "Data set: Header
  cnt_records           = cnt_records + 1.

*     J_1BDMEYH-J_1BCRLF    = UP_CRLF.

  j_1bdmeyh-h01         = '0'.
  j_1bdmeyh-h02         = '1'.
  j_1bdmeyh-h03         = 'REMESSA'.
  j_1bdmeyh-h04         = '01'.
  j_1bdmeyh-h05         = 'COBRANCA'.
  CALL FUNCTION 'J_1B_CONVERT_BANK'
    EXPORTING
      i_bank = reguh-ubnkl
    IMPORTING
      e_bank = agency
    EXCEPTIONS
      OTHERS = 1.

  j_1bdmeyh-h06(4)      =  agency.
  j_1bdmeyh-h06+4(2)    =  '00'.
  j_1bdmeyh-h06+6(5)    =  reguh-ubknt.

*     Convert the control digit REGUH-UBKON(char2) to numc1.
  CONDENSE reguh-ubkon NO-GAPS.
  j_1bdmeyh-h06+11(1)    =  reguh-ubkon.

  j_1bdmeyh-h08   = hlp_sadr-name1.
  PERFORM dta_text_aufbereiten USING j_1bdmeyh-h08.
  j_1bdmeyh-h09   = reguh-ubnkl(3).
  j_1bdmeyh-h10   = 'BANCO ITAU SA'.        "Note 1611532.
  PERFORM datum_in_ddmmyy USING sy-datum j_1bdmeyh-h11.
*     REGUT-TSDAT in case payment run date instead of file creation date

  j_1bdmeyh-h13   =  '000001'.

*--File Header: end of filling------------------------------------------

ENDFORM.                    "FILL_HEADER_ITAU

*-----------------------------------------------------------------------
*---     FORM FILL_HEADER_BRADESCO                             ---------
*-----------------------------------------------------------------------
FORM fill_header_bradesco.

*     DATA  UP_CRLF(2) TYPE X VALUE '0D0A'."carriage return + line feed
*     Fill data set H
  CLEAR: j_1bdmezh.   "Data set: Header
  cnt_records = cnt_records + 1.
*
*     J_1BDMEZH-J_1BCRLF   = UP_CRLF.

  j_1bdmezh-h01   = '0'.
  j_1bdmezh-h02   = '1'.
  j_1bdmezh-h03   = 'REMESSA'.
  j_1bdmezh-h04   = '01'.
  j_1bdmezh-h05   = 'COBRANCA'.
  SELECT * FROM t045t                 "Company ID at bank
    WHERE bukrs = reguh-zbukr
    AND   zlsch = reguh-rzawe
    AND   hbkid = reguh-hbkid
    AND   hktid = reguh-hktid.
    IF sy-subrc EQ 0.
      EXIT.
    ENDIF.
  ENDSELECT.
  IF sy-subrc <> 0.                     "found none
    SELECT * FROM t045t                 "second chance
      WHERE bukrs = reguh-zbukr
      AND   zlsch = space               "no payment method maint.
      AND   hbkid = reguh-hbkid
      AND   hktid = reguh-hktid.
      IF sy-subrc EQ 0.
        EXIT.
      ENDIF.
    ENDSELECT.
    IF sy-subrc <> 0.
      MESSAGE ID '8B' TYPE 'E' NUMBER '787'.
    ENDIF.
  ENDIF.
  j_1bdmezh-h06   = t045t-dtaid.             "Company ID at bank
  j_1bdmezh-h07   = hlp_sadr-name1.
  PERFORM dta_text_aufbereiten USING j_1bdmezh-h07.
  j_1bdmezh-h08   = reguh-ubnkl(3).
  j_1bdmezh-h09   = 'BRADESCO'.
  PERFORM datum_in_ddmmyy USING sy-datum j_1bdmezh-h10.
*     REGUT-TSDAT in case payment run date instead of file creation

  j_1bdmezh-h12   = 'MX'.
  j_1bdmezh-h13   =  hlp_resultat+1(7).
  j_1bdmezh-h15   = '000001'.

*--File Header: end of filling------------------------------------------
ENDFORM.                    "FILL_HEADER_BRADESCO


*-----------------------------------------------------------------------
*---     FORM FILL_DETAILS_ITAU                                ---------
*-----------------------------------------------------------------------
FORM fill_details_itau.


*     DATA  UP_CRLF(2) TYPE X VALUE '0D0A'."carriage return + line feed
  DATA dummy TYPE c.
  DATA : l_cnt TYPE n.           "Note 1005924 Changes
  DATA: ls_kna1 TYPE kna1.
  cnt_records         = cnt_records + 1.
* -----Details----------------------------------------------------------
  CLEAR j_1bdmeya.

*     J_1BDMEYA-J_1BCRLF  = UP_CRLF.

  j_1bdmeya-a01       = '1'.
  j_1bdmeya-a02       = '02'.
  j_1bdmeya-a03       = j_1bwfield-cgc_number.
  j_1bdmeya-a04       = j_1bdmeyh-h06.            "Bank nr and acc.
  j_1bdmeya-a05+4(4)  = '0000'.                   "Note 1636989
  j_1bdmeya-a06       = regup-kunnr.
  PERFORM dta_text_aufbereiten USING j_1bdmeya-a06.
  j_1bdmeya-a06+10    = regup-belnr.
  j_1bdmeya-a06+20(4) = regup-gjahr.

* Downpayments : Note 859618
* Uso da Empresa must be filled with the special G/L indicator. This is
* needed later to clear the d/p request when the incoming file is loaded
  IF regup-umskz NE space.
    j_1bdmeya-a06+24(1)    = regup-umskz.
  ENDIF.


  IF regup-xref3 EQ space.
*       Highest boleto number for given VBLNR (reprints !)
    SELECT * FROM payr
      WHERE zbukr = reguh-zbukr
        AND vblnr = reguh-vblnr
        AND gjahr = regud-gjahr
        AND voidr = 0.
    ENDSELECT.
    IF sy-subrc = 0.
      j_1bdmeya-a07     =    payr-chect.
    ELSE.
      j_1bdmeya-a07     =    '00000000'.        "see layout
    ENDIF.
  ELSE.
*    J_1BDMEYA-A07     = REGUP-XREF3. " note 1095025
    j_1bdmeya-a07     = regup-xref3(8).
  ENDIF.
  IF NOT regup-waers EQ t001-waers.
    j_1bdmeya-a08    = regup-wrbtr.
    PERFORM for_curr_check USING regup-waers t001-waers
                    CHANGING j_1bdmeya-a08.

  ELSE.
    CLEAR j_1bdmeya-a08.
  ENDIF.

*     Split Cateira Code X and Carteira number YYY from XYYY,if present
  DATA: str_length TYPE i.
  str_length = strlen( carteira ).
  IF str_length LE 3.
    j_1bdmeya-a11     = space.
    j_1bdmeya-a09     = carteira.
  ELSE.
    j_1bdmeya-a11     = carteira(1).
    j_1bdmeya-a09     = carteira+1(3).
  ENDIF.
  PERFORM dta_text_aufbereiten USING j_1bdmeya-a09.
  PERFORM dta_text_aufbereiten USING j_1bdmeya-a11.

  PERFORM weisungsschluessel_umsetzen USING
                            'BR' '1' t015w-dtws1         "export
                             j_1bdmeya-a12 dummy.        "import

  CONDENSE regup-xblnr NO-GAPS.             "prevent handling errors
  PERFORM fill_notafiscal CHANGING j_1bdmeya-a13. "note 1087535
*  j_1bdmeya-a13(6)    = regup-xblnr(6)."Nota Fiscal Nr
*  j_1bdmeya-a13+6(3)  = regup-buzei.   "Duplicata number
  PERFORM dta_text_aufbereiten USING j_1bdmeya-a13.

  CALL FUNCTION 'J_1B_FI_NETDUE'
    EXPORTING
      zfbdt   = regup-zfbdt
      zbd1t   = regup-zbd1t
      zbd2t   = regup-zbd2t
      zbd3t   = regup-zbd3t
    IMPORTING
      duedate = hlp_duedate
    EXCEPTIONS
      OTHERS  = 1.

  PERFORM datum_in_ddmmyy USING hlp_duedate j_1bdmeya-a14.
  PERFORM amount_check CHANGING j_1bdmeya-a15.
*     Where the customer pays.
  j_1bdmeya-a16      = '341'.             "Bank group number
  j_1bdmeya-a17      = regup-xref2.       "Agency or other info,

*     not aktive, as no specified requirements yet (15.07.97)
*     IF REGUP-SHKZG  EQ  'S'.
  j_1bdmeya-a18     = '01'.                    "Duplicata
*     ELSE.
*       J_1BDMEYA-A18     = '13'.                    "Credit note
*     ENDIF.

  j_1bdmeya-a19       = 'N'.
  PERFORM datum_in_ddmmyy USING regup-bldat j_1bdmeya-a20.

  PERFORM weisungsschluessel_umsetzen USING
                            'BR' '2' t015w-dtws2         "export
                             j_1bdmeya-a21 dummy.        "import

  PERFORM weisungsschluessel_umsetzen USING
                            'BR' '3' t015w-dtws3         "export
                             j_1bdmeya-a22 dummy.        "import

  IF regup-zinkz EQ space.
    CALL FUNCTION 'J_1B_GET_INTEREST_RATE_PER_DAY'
      EXPORTING
        duedate = hlp_duedate
        vzskz   = knb1-vzskz
        waers   = reguh-waers
      IMPORTING
        zinso   = hlp_zinso
      EXCEPTIONS
        OTHERS  = 1.

    hlp_interest      = ( reguh-rwbtr + reguh-rwskt )
                                * hlp_zinso / 100 / 10000000.
    j_1bdmeya-a23     = hlp_interest.
    PERFORM for_curr_check USING regup-waers t001-waers
                     CHANGING j_1bdmeya-a23.

  ENDIF.

*     Date until discount is given
  hlp_date = regup-zfbdt + regup-zbd1t.
*     Limit date only filled if there is discount value
  IF NOT reguh-rwskt IS INITIAL.
    PERFORM datum_in_ddmmyy USING hlp_date j_1bdmeya-a24.
    j_1bdmeya-a25       = reguh-rwskt. "Total Discount 1
  ELSE.
    j_1bdmeya-a24       = '000000'.
  ENDIF.
  PERFORM for_curr_check USING regup-waers t001-waers
                     CHANGING j_1bdmeya-a25.

  j_1bdmeya-a26       = 0.
*     Rebate
* Note 928822 change Starts
  IF NOT reguh-rwskt IS INITIAL.
    j_1bdmeya-a27 = regup-wrbtr - ( reguh-rwbtr + reguh-rwskt ).
  ELSE.
*Note 1005924 Changes starts
*    j_1bdmeya-a27 = 0.
    SELECT COUNT(*) FROM regup INTO l_cnt
              WHERE laufd = regup-laufd
                AND laufi = regup-laufi
                AND vblnr = regup-vblnr    "Note 2204744
                AND rebzg = regup-belnr
                AND rebzj = regup-gjahr
                AND rebzt = 'G'.

    IF NOT l_cnt IS INITIAL.
      j_1bdmeya-a27 = regup-wrbtr - reguh-rwbtr.
    ELSE. "   Note 1498280
      j_1bdmeya-a27 = 0.   "Note 1498280
    ENDIF.
*--Start of Note 1498280
*    IF NOT ( regup-qbshb is initial or regup-qbshh is initial ).
*      j_1bdmeya-a27 = regup-wrbtr - reguh-rwbtr.
*    ELSE.
*      j_1bdmeya-a27 = 0.
*    ENDIF.
*--End of Note 1498280
*Note 1005924 Changes ends
  ENDIF.
* Note 928822 change Ends
  PERFORM for_curr_check USING regup-waers t001-waers
                     CHANGING j_1bdmeya-a27.

  j_1bdmeya-a28       = hlp_stkzn.              " sole proprietor ?
  j_1bdmeya-a29       = hlp_taxcode.            " CPF or CGC
*     j_1bdmeya-a30       = reguh-znme1.
*     j_1bdmeya-a30       = reguh-koinh.
  j_1bdmeya-a30       = kna1-name1.             "dev request
  PERFORM dta_text_aufbereiten USING j_1bdmeya-a30.
*  IF kna1-knrza is INITIAL.                     "Note 1767203 Alternative payee?
  j_1bdmeya-a32       = kna1-stras.
  PERFORM dta_text_aufbereiten USING j_1bdmeya-a32.
  j_1bdmeya-a33       = kna1-ort02.
  PERFORM dta_text_aufbereiten USING j_1bdmeya-a33.
  j_1bdmeya-a34(5)    = kna1-pstlz(5).
  j_1bdmeya-a34+5(3)  = kna1-pstlz+6(3).
  PERFORM dta_text_aufbereiten USING j_1bdmeya-a34.
  j_1bdmeya-a35       = kna1-ort01.
  PERFORM dta_text_aufbereiten USING j_1bdmeya-a35.
*  ENDIF.
  j_1bdmeya-a36       = kna1-regio.            "Note 1931476
  PERFORM dta_text_aufbereiten USING j_1bdmeya-a36.

*     Second discount rule
*     Not available for the time being. Problem: Discount has to be
*     recalculated as a total over all regup entries. Is in principle
*     possible, but as not occuring for some layouts nayway (bradesco),
*     not impleneted here.
*      J_1BDMEYA-A37(2)    = SPACE.
*     ---> Only good for credit notes, not for down payment
*      HLP_WSKTO            = ( REGUD-DMBTR - REBATE )
*                                         * REGUP-ZBD2P / 100000.
*      J_1BDMEYA-A37+8(13)  = HLP_WSKTO.
*      J_1BDMEYA-A37+21     = SPACE.

  PERFORM datum_in_ddmmyy USING hlp_duedate j_1bdmeya-a39.
*  set days of protest in field a40 if instruction code is 09
*  (protest code)
  IF j_1bdmeya-a12 = '09' OR j_1bdmeya-a12 = '36'.
    j_1bdmeya-a40 = j_1bdmeya-a21.
    CLEAR: j_1bdmeya-a21,  j_1bdmeya-a22.
  ELSEIF j_1bdmeya-a12 = '01' AND
     ( j_1bdmeya-a21 = '09' OR j_1bdmeya-a21 = '36' OR
       j_1bdmeya-a21 = '81' OR j_1bdmeya-a21 = '82' OR j_1bdmeya-a21 = '35' OR
       j_1bdmeya-a21 = '91' OR j_1bdmeya-a21 = '92' ).
    j_1bdmeya-a40 = j_1bdmeya-a22.
    CLEAR j_1bdmeya-a22.
  ENDIF.
*
  j_1bdmeya-a42        = cnt_records.

*---END SINGLE ITEMS---------------------------------------------------
ENDFORM.                    "FILL_DETAILS_ITAU


*-----------------------------------------------------------------------
*---     FORM FILL_DETAILS_BRADESCO                            ---------
*-----------------------------------------------------------------------
FORM fill_details_bradesco.

  DATA:
*         UP_CRLF(2) TYPE X VALUE '0D0A', "carriage return + line feed
    str_length  TYPE i,                     "For string processing
*         Help fields for right alligned moves
    hlp_num3(3) TYPE n, hlp_num5(5) TYPE n, hlp_num7(7) TYPE n,
    dummy       TYPE c,
    hlp_chect   LIKE regud-chect.
  DATA : l_cnt TYPE n.           "Note 871348 Changes
* Note 774764 Changes Starts
  DATA:
    hlp_num8     LIKE regud-obknt,
    hlp_num9(1)  TYPE c,
    hlp_num10(1) TYPE c.
* Note 774764 Changes Ends
  DATA: ls_kna1 TYPE kna1.
  DATA: ls_regup TYPE regup.
  cnt_records = cnt_records + 1.
* ----Details----------------------------------------------------------
  CLEAR j_1bdmeza.
  CLEAR : hlp_num7, hlp_num8, hlp_num9, hlp_num10. "Note 774764 Changes

*     J_1BDMEZA-J_1BCRLF   = UP_CRLF.

  j_1bdmeza-a01        = '1'.

*     Automatic collection
  IF knbk-xezer <> space.
    j_1bdmeza-a09        = knbk-bankl(3).
    CALL FUNCTION 'J_1B_CONVERT_BANK'
      EXPORTING
        i_bank = knbk-bankl
      IMPORTING
        e_bank = agency
      EXCEPTIONS
        OTHERS = 1.
    j_1bdmeza-a02        = agency.            "Agency
* Note 774764 Changes Starts
    j_1bdmeza-a04        = space.                "Razao ??

    CALL FUNCTION 'READ_ACCOUNT_DATA'
      EXPORTING
        i_bankn = knbk-bankn
        i_bkont = knbk-bkont
      IMPORTING
        e_bankn = hlp_num8
        e_cntr1 = hlp_num9
        e_cntr2 = hlp_num10.

    hlp_num7 = hlp_num8.
    j_1bdmeza-a05 = hlp_num7.
    j_1bdmeza-a03 = hlp_num9.
    j_1bdmeza-a06 = hlp_num10.

  ENDIF.

  CLEAR : hlp_num7, hlp_num8, hlp_num9, hlp_num10.
* Note 774764 Changes Ends
  j_1bdmeza-a07(1)       = '0'.
*     Split Cateira Code X and Carteira number YYY from XYYY,if present
  str_length = strlen( carteira ).
  IF str_length LE 3.
    hlp_num3 = carteira.
  ELSE.
    hlp_num3 = carteira+1(3).
  ENDIF.
  j_1bdmeza-a07+1(3)     = hlp_num3.
  CALL FUNCTION 'J_1B_CONVERT_BANK'
    EXPORTING
      i_bank = reguh-ubnkl
    IMPORTING
      e_bank = agency
    EXCEPTIONS
      OTHERS = 1.
  hlp_num5               = agency.
  j_1bdmeza-a07+4(5)     = hlp_num5.
* Note 774764 Changes Starts
  CALL FUNCTION 'READ_ACCOUNT_DATA'
    EXPORTING
      i_bankn = reguh-ubknt
      i_bkont = reguh-ubkon
    IMPORTING
      e_bankn = hlp_num8
      e_cntr2 = hlp_num10.

  hlp_num7 = hlp_num8.
  hlp_num9 = hlp_num10. "Note 942971 Changes
  j_1bdmeza-a07+9(7)     = hlp_num7.
  j_1bdmeza-a07+16(1)    = hlp_num9.
* Note 774764 Changes Ends
  PERFORM dta_text_aufbereiten USING j_1bdmeza-a07.

* Field is used in return file for finding open item
  j_1bdmeza-a08          = regup-kunnr.
  j_1bdmeza-a08+10(10)   = regup-belnr.
  j_1bdmeza-a08+20(4)    = regup-gjahr.

* Downpayments : Note 859618
* Uso da Empresa must be filled with the special G/L indicator. This is
* needed later to clear the d/p request when the incoming file is loaded
  IF regup-umskz NE space.
    j_1bdmeza-a08+24(1)    = regup-umskz.
  ENDIF.

  PERFORM dta_text_aufbereiten USING j_1bdmeza-a08.
*  j_1bdmeza-a10          = 0000.

  " A10 - Percentual de Multa por Atraso
  PERFORM f_multa_atraso CHANGING j_1bdmeza-a10.

*     Is duplicata already entered ?
  IF regup-xref3 EQ space.
    SELECT * FROM payr
      WHERE zbukr = reguh-zbukr
        AND vblnr = reguh-vblnr
        AND gjahr = regud-gjahr
        AND voidr = 0.
    ENDSELECT.
*       Has a boleto been printed by us.
    IF sy-subrc = 0.
* Note 606664 : Make year identical to REGUT-TSDAT, RFFORI99
      hlp_chect = payr-chect.
      SHIFT hlp_chect RIGHT DELETING TRAILING ' '.
      TRANSLATE hlp_chect USING ' 0'.
      j_1bdmeza-a11(2)   =    '00'.                         "N2213805
      j_1bdmeza-a11+2(9) =    hlp_chect+4.
      hlp_chect = j_1bdmeza-a11.  "Note 846299 Change

      CALL FUNCTION 'CALCULATE_CHECK_DIGIT_BOLETO'
        EXPORTING
          bankkey    = reguh-ubnkl
          conta_corr = reguh-ubknt
          carteira   = j_1bdmeza-a07+1(3)
          nos_numero = hlp_chect
          docdate    = regup-bldat
        IMPORTING
          nos_check  = j_1bdmeza-a11+11(1)
        EXCEPTIONS
          OTHERS     = 1.
*     new layout: boleto is printed by us
      j_1bdmeza-a13(1)    = '2'.
    ELSE.
      j_1bdmeza-a11      = '000000000000'.           "see layout
*     printed by bank
      j_1bdmeza-a13(1)    = '1'.
    ENDIF.
  ELSE.
    j_1bdmeza-a11        = regup-xref3.
    SELECT * FROM payr
      WHERE zbukr = reguh-zbukr
        AND vblnr = reguh-vblnr
        AND gjahr = regud-gjahr
        AND voidr = 0.
    ENDSELECT.
*       Has a boleto been printed by us.
    IF sy-subrc = 0.
*     new layout:
      j_1bdmeza-a13(1)    = '2'.
    ELSE.
      j_1bdmeza-a13(1)    = '1'.
    ENDIF.

    j_1bdmeza-a13(1) = COND #(
      WHEN reguh-ubnkl(3) = '237'
      THEN '2'
      ELSE j_1bdmeza-a13(1)
    ).
  ENDIF.

  " A11 - Nosso Número
  PERFORM f_nosso_numero USING reguh
                               regup
                      CHANGING j_1bdmeza.

  PERFORM weisungsschluessel_umsetzen USING
                            'BR' '1' t015w-dtws1         "export
                             j_1bdmeza-a15 dummy.        "import

  " A15 - Identificações de Ocorrência
  PERFORM f_ocorrencia USING reguh
                    CHANGING j_1bdmeza-a15.

  CONDENSE regup-xblnr NO-GAPS.                 "prevent handl. err.
  PERFORM fill_notafiscal CHANGING j_1bdmeza-a16.  "note 1087535
*  j_1bdmeza-a16(6)    = regup-xblnr.   "Nota Fiscal nr
*  j_1bdmeza-a16+6(3)  = regup-buzei.   "Duplicata number
  PERFORM dta_text_aufbereiten USING j_1bdmeza-a16.

  CLEAR hlp_duedate.
  CALL FUNCTION 'J_1B_FI_NETDUE'
    EXPORTING
      zfbdt   = regup-zfbdt
      zbd1t   = regup-zbd1t
      zbd2t   = regup-zbd2t
      zbd3t   = regup-zbd3t
    IMPORTING
      duedate = hlp_duedate
    EXCEPTIONS
      OTHERS  = 1.

  PERFORM datum_in_ddmmyy USING hlp_duedate j_1bdmeza-a17.
  PERFORM amount_check CHANGING j_1bdmeza-a18.
  PERFORM for_curr_check USING regup-waers t001-waers
                      CHANGING j_1bdmeza-a18.

*    Where the customer pays, see layout !
  j_1bdmeza-a19        = 0.          "Bank group number
  j_1bdmeza-a20        = regup-xref2.    "Agency, or other info

  j_1bdmeza-a21        = '01'.                              "Always 01
  j_1bdmeza-a22        = 'N'.                  "Always N

  PERFORM datum_in_ddmmyy USING regup-bldat j_1bdmeza-a23.

*    Instruction codes 2,3

  PERFORM weisungsschluessel_umsetzen USING
                            'BR' '2' t015w-dtws2         "export
                             j_1bdmeza-a24 dummy.        "import

  PERFORM weisungsschluessel_umsetzen USING
                            'BR' '3' t015w-dtws3         "export
                             j_1bdmeza-a25 dummy.        "import

  IF regup-zinkz EQ space.                        "No exempt
    CALL FUNCTION 'J_1B_GET_INTEREST_RATE_PER_DAY'
      EXPORTING
        duedate = hlp_duedate
        vzskz   = knb1-vzskz
        waers   = reguh-waers
      IMPORTING
        zinso   = hlp_zinso
      EXCEPTIONS
        OTHERS  = 1.

    hlp_interest      = ( reguh-rwbtr + reguh-rwskt )
                                 * hlp_zinso / 100 / 10000000.
    j_1bdmeza-a26     = hlp_interest.

    " A26 - Valor a ser Cobrado por dia de atraso (mora dia)
    PERFORM f_moradia USING reguh
                   CHANGING j_1bdmeza-a26.

    PERFORM for_curr_check USING regup-waers t001-waers
                     CHANGING j_1bdmeza-a26.


  ENDIF.
*     Date until discount is given
  hlp_date = regup-zfbdt + regup-zbd1t.
*     limit date only filled if there is discount value
  IF NOT reguh-rwskt IS INITIAL.
    PERFORM datum_in_ddmmyy USING hlp_date j_1bdmeza-a27.
    j_1bdmeza-a28       = reguh-rwskt. "Total Discount 1
  ELSE.
    j_1bdmeza-a27       = '000000'.
  ENDIF.

  PERFORM for_curr_check USING regup-waers t001-waers
                     CHANGING j_1bdmeza-a28.

  j_1bdmeza-a29       = 0.
*     Rebate
  IF NOT reguh-rwskt IS INITIAL.
    j_1bdmeza-a30       = regup-wrbtr - ( reguh-rwbtr + reguh-rwskt ).
  ELSE.
*Note 871348 Changes starts
*   J_1BDMEZA-A30       = 0.
*Note 2014449 for rebate changes when more than 1 credit memos are present in the payment. The rebate value should be the sum of the
*credit memos
    TYPES : BEGIN OF ty_rebate ,
              wrbtr TYPE wrbtr,
            END OF ty_rebate.
    DATA : itab       TYPE TABLE OF ty_rebate,
           wa_itab    LIKE LINE OF itab,
           sum_amount TYPE wrbtr.

    SELECT * FROM regup INTO CORRESPONDING FIELDS OF TABLE itab
              WHERE laufd = regup-laufd
                AND laufi = regup-laufi
                AND vblnr = regup-vblnr
                AND rebzg = regup-belnr
                AND rebzj = regup-gjahr
                AND rebzt = 'G'.
    IF sy-subrc EQ 0.
      LOOP AT itab INTO wa_itab.
        sum_amount = sum_amount + wa_itab-wrbtr.
      ENDLOOP.
      j_1bdmeza-a30 = sum_amount.
    ELSE.
      j_1bdmeza-a30 = 0.
    ENDIF.
    CLEAR : wa_itab,itab,sum_amount.
    REFRESH : itab.
*     ENDIF.
*Note 871348 Changes ends
  ENDIF.

  " A30 - Valor do Abatimento a ser Concedido
  PERFORM f_valor_abatimento USING regup
                          CHANGING j_1bdmeza-a30.

  PERFORM for_curr_check USING regup-waers t001-waers
                     CHANGING j_1bdmeza-a30.

  j_1bdmeza-a31       = hlp_stkzn.              " sole proprietor
  j_1bdmeza-a32       = hlp_taxcode.            " CPF or CGC number
*     j_1bdmeza-a33       = reguh-znme1.
*     j_1bdmeza-a33       = reguh-koinh.
  j_1bdmeza-a33       = kna1-name1.             "devrequest
  PERFORM dta_text_aufbereiten USING j_1bdmeza-a33.
*  IF kna1-knrza IS INITIAL.                     "Note 1767203
  j_1bdmeza-a34       = kna1-stras.
*  j_1bdmeza-a34       = reguh-zstra.          " Note 119424: street
  " only
*      str_length          = strlen( reguh-zort1 ). Note 119424
*      str_length          = str_length + 1.
*      move reguh-zstra to j_1bdmeza-a34+str_length.    "city and street
  PERFORM dta_text_aufbereiten USING j_1bdmeza-a34.
  j_1bdmeza-boletotext = t015w-dtzus.
  PERFORM dta_text_aufbereiten USING j_1bdmeza-boletotext.
  j_1bdmeza-a36       = kna1-pstlz(5).
  PERFORM dta_text_aufbereiten USING j_1bdmeza-a36.
  j_1bdmeza-a37       = kna1-pstlz+6(3).
  PERFORM dta_text_aufbereiten USING j_1bdmeza-a37.
*  ENDIF.
  j_1bdmeza-a38       = regup-sgtxt.
  PERFORM dta_text_aufbereiten USING j_1bdmeza-a38.
  j_1bdmeza-a39       = cnt_records.

*---END SINGLE ITEMS----------------------------------------------------
ENDFORM.                    "FILL_DETAILS_BRADESCO


*-----------------------------------------------------------------------
*---     FORM FILL_TRAILER_ITAU (also Bradesco)                ---------
*-----------------------------------------------------------------------
FORM fill_trailer_itau.

*     DATA  UP_CRLF(2) TYPE X VALUE '0D0A'."carriage return + line feed

  cnt_records = cnt_records + 1.
*     Datensatz file trailer füllen
  CLEAR j_1bdmeyt.
*     J_1BDMEYT-J_1BCRLF   = UP_CRLF.

  j_1bdmeyt-t01        = '9'.
  j_1bdmeyt-t02        = space.
  j_1bdmeyt-t03        = cnt_records.

ENDFORM.                    "FILL_TRAILER_ITAU



*----------------------------------------------------------------------*
* FORM READ_CUSTOMER                                                   *
*----------------------------------------------------------------------*

FORM read_customer.
  DATA: lv_kunnr TYPE kunnr.
  DATA: obj_rffobr_cust TYPE REF TO badi_rffobr. "Note 2169582

  GET BADI obj_rffobr_cust. "Note 2169582

  IF regup-empfg IS NOT INITIAL. "Note 1996121
    lv_kunnr = regup-empfg+1(10).
    SELECT SINGLE * FROM kna1
   WHERE kunnr EQ lv_kunnr.
  ELSE.
    SELECT SINGLE * FROM kna1
       WHERE kunnr EQ reguh-kunnr.
  ENDIF.

  CALL BADI obj_rffobr_cust->read_customer_data "Note 2169582
    EXPORTING
      is_reguh = reguh
      is_regup = regup
    CHANGING
      cs_kna1  = kna1.

*     Store STKZN(sole proprietor) and STCD1/2 (tax code 1/2) from kna1
  CASE kna1-stkzn.                 " sole proprietor

    WHEN space.                                         "CGC
      hlp_stkzn = '2'.
      hlp_taxcode = kna1-stcd1.

    WHEN OTHERS.
      hlp_stkzn = '1'.
      hlp_taxcode = kna1-stcd2.

  ENDCASE.

*     Customer bank details
  SELECT SINGLE * FROM knbk
    WHERE kunnr = reguh-kunnr
      AND banks = reguh-zbnks
      AND bankl = reguh-zbnkl
      AND bankn = reguh-zbnkn.
  IF sy-subrc <> 0.
*        do nothing, is just not there
  ENDIF.

*     Interest indicator
  SELECT SINGLE * FROM knb1
    WHERE bukrs EQ reguh-zbukr
      AND kunnr EQ reguh-kunnr.
ENDFORM.                    "READ_CUSTOMER
*&---------------------------------------------------------------------*
*&      Form  FILL_HEADER_FEBRABAN
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM fill_header_febraban.

*     DATA  UP_CRLF(2) TYPE X VALUE '0D0A'."carriage return + line feed
  CLEAR: j_1bdmexh1, j_1bdmexh3.  "Data set: Header, lot header
  cnt_records = cnt_records + 1.

*     J_1BDMEXH1-J_1BCRLF  = UP_CRLF.
  j_1bdmexh1-h101      = reguh-ubnkl(3).            " '341' for ITAU
  j_1bdmexh1-h102      = 0.                         " count lot
  j_1bdmexh1-h103      = '0'.
  j_1bdmexh1-h104      = space.                             " 9 blanks
  j_1bdmexh1-h105      = '2'.         " CGC and not CPF
  j_1bdmexh1-h106      = j_1bwfield-cgc_number.

*     Company ID at bank
  CLEAR t045t.
  SELECT * FROM t045t
    WHERE bukrs = reguh-zbukr
    AND   zlsch = reguh-rzawe
    AND   hbkid = reguh-hbkid
    AND   hktid = reguh-hktid.
    IF sy-subrc EQ 0.
      EXIT.
    ENDIF.
  ENDSELECT.
  IF sy-subrc <> 0.                     "found none
    SELECT * FROM t045t                 "second chance
      WHERE bukrs = reguh-zbukr
      AND   zlsch = space              "no payment method maint.
      AND   hbkid = reguh-hbkid
      AND   hktid = reguh-hktid.
      IF sy-subrc EQ 0.
        EXIT.
      ENDIF.
    ENDSELECT.
  ENDIF.
*     Fill if available. If not maintained, not required. No message
  j_1bdmexh1-h107     = t045t-dtaid.

  CALL FUNCTION 'J_1B_CONVERT_BANK'
    EXPORTING
      i_bank = reguh-ubnkl
    IMPORTING
      e_bank = agency
    EXCEPTIONS
      OTHERS = 1.

  j_1bdmexh1-h108   = agency.

  CALL FUNCTION 'READ_ACCOUNT_DATA'
    EXPORTING
      i_bankn = reguh-ubknt
      i_bkont = reguh-ubkon
    IMPORTING
      e_bankn = regud-obknt
      e_cntr1 = j_1bdmexh1-h109
      e_cntr2 = j_1bdmexh1-h111
      e_cntr3 = j_1bdmexh1-h112
    EXCEPTIONS
      OTHERS  = 1.

  j_1bdmexh1-h110   = regud-obknt.
  j_1bdmexh1-h113   = hlp_sadr-name1.
  PERFORM dta_text_aufbereiten USING j_1bdmexh1-h113.
  j_1bdmexh1-h114   = regud-ubnka.
  PERFORM dta_text_aufbereiten USING j_1bdmexh1-h114.
  j_1bdmexh1-h115   = space.                                " 15 blanks
  j_1bdmexh1-h116   = '1'.
*     BREAK HERE FOR TEST: BANK ACCOUNT STATEMENT
*     J_1BDMEXH1-H116   =  2  for test of bank account statement

  j_1bdmexh1-h117(2)    = sy-datum+6(2).  "dd
  j_1bdmexh1-h117+2(2)  = sy-datum+4(2).  "mm
  j_1bdmexh1-h117+4(4)  = sy-datum(4).    "yyyy

  j_1bdmexh1-h118   = sy-uzeit.
*     REGUT-TSDAT and REGUT-TSTIM, respectively, in case payment run
*     date run date and time are required instead of
*     file creation program run date.

  j_1bdmexh1-h119(6)   = hlp_resultat+2(6).        "File number
********BEGIN OF CHANGES : BRAZIL DDA************************************
*  IF par_fbla = ' '.
*    j_1bdmexh1-h119+6(3) = '030'.                 "File version 3.0
*  ELSE.
*    j_1bdmexh1-h119+6(3) = '040'.                 "File version 4.0
*  ENDIF.
  j_1bdmexh1-h119+6(3) = '084'.

*  if par_fbla = '087'.
*    j_1bdmexh1-h119+6(3) = '087'.                  "File Version 8.7
*  endif.

  IF par_fbla = '089'.                             "SNote no 2555959
    j_1bdmexh1-h119+6(3) = '089'.                 "SNote no 2555959 "File Version 8.7
  ENDIF.

********END OF CHANGES : BRAZIL DDA**************************************
*--File Header: end of filling------------------------------------------

*--Lot Header: start of filling-----------------------------------------
  cnt_records          = cnt_records + 1.
*     J_1BDMEXH3-UP_CRLF   = UP_CRLF.

  j_1bdmexh3-h301      = reguh-ubnkl(3).   "Código do Banco
  j_1bdmexh3-h302      =  1.               "Número do Lote
  j_1bdmexh3-h303      = '1'.              "Tipo de Registro
  j_1bdmexh3-h304      = 'R'.              "Tipo de Operação (D/C)
  j_1bdmexh3-h305      =  1.               "Tipo de Serviço
  j_1bdmexh3-h306      =  0.               "Forma de Lançamento

* BEGIN OF NOTE: 1746618
  SHIFT j_1bdmexh3-h306 LEFT DELETING LEADING '0'.
* END OF NOTE: 1746618

********BEGIN OF CHANGES : BRAZIL DDA************************************
*  IF par_fbla = ' '.
*    j_1bdmexh3-h307     =  '020'.           "Lot version Feb 3.0
*  ELSE.
*    j_1bdmexh3-h307     =  '030'.           "Lot version Feb 4.0
*  ENDIF.
  j_1bdmexh3-h307  = '043'.

*   if par_fbla = '087'.
  IF par_fbla = '089'.             "Snote no 2555959
    j_1bdmexh3-h307  = '045'.               "Lot version Feb 8.7
  ENDIF.
********END OF CHANGES : BRAZIL DDA**************************************
  j_1bdmexh3-h309      =  '2'.             "CGC and not CPF
  j_1bdmexh3-h310      = j_1bwfield-cgc_number.
  j_1bdmexh3-h311      = j_1bdmexh1-h107.
  j_1bdmexh3-h312      = j_1bdmexh1-h108.
  j_1bdmexh3-h313      = j_1bdmexh1-h109.
  j_1bdmexh3-h314      = j_1bdmexh1-h110.
  j_1bdmexh3-h315      = j_1bdmexh1-h111.
  j_1bdmexh3-h316      = j_1bdmexh1-h112.
  j_1bdmexh3-h317      = j_1bdmexh1-h113.
  j_1bdmexh3-h321      = j_1bdmexh1-h117.
*--Lot Header: end of filling------------------------------------------

ENDFORM.                    " FILL_HEADER_FEBRABAN

*&---------------------------------------------------------------------*
*&      Form  FILL_DETAILS_FEBRABAN
*&---------------------------------------------------------------------*
*       text                                                           *
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM fill_details_febraban.

  CLEAR: j_1bdmexp, j_1bdmexq, lv_rebate.
* DATA  UP_CRLF(2) TYPE X VALUE '0D0A'."carriage return + line feed

  DATA  dummy TYPE c.
  DATA: ls_kna1 TYPE kna1.

  DATA: obj_rffobr TYPE REF TO badi_rffobr.   "Note 2169582

  GET BADI obj_rffobr. "Note 2169582

* -----Details segment P -----------------------------------------------
  cnt_posten           = cnt_posten + 1.
  cnt_records          = cnt_records + 1.

* J_1BDMEXP-UP_CRLF    = UP_CRLF.
  j_1bdmexp-p01        = reguh-ubnkl(3).   "Código do Banco
  j_1bdmexp-p02        =  1.               "Número do Lote
  j_1bdmexp-p03        = '3'.              "Tipo de Registro
  j_1bdmexp-p04        = cnt_posten.  "record number
  j_1bdmexp-p05        = 'P'.              "segment type
  PERFORM weisungsschluessel_umsetzen USING
                             'BR' '1' t015w-dtws1         "export
                              j_1bdmexp-p07 dummy.        "import
  j_1bdmexp-p08      = j_1bdmexh1-h108.
  j_1bdmexp-p09      = j_1bdmexh1-h109.
  j_1bdmexp-p10      = j_1bdmexh1-h110.
  j_1bdmexp-p11      = j_1bdmexh1-h111.
  j_1bdmexp-p12      = j_1bdmexh1-h112.
  IF regup-xref3 EQ space.
*   Highest boleto number for given VBLNR (reprints !)
    SELECT * FROM payr
      WHERE zbukr = reguh-zbukr
        AND vblnr = reguh-vblnr
        AND gjahr = regud-gjahr
        AND voidr = 0.
    ENDSELECT.
    IF sy-subrc = 0.
* Note 141714
      regud-chect = payr-chect.
      CLEAR regud-text4(2).
      CALL FUNCTION 'BOLETO_DATA'
        EXPORTING
          line_reguh = reguh
        TABLES
          itab_regup = tab_regup
        CHANGING
          line_regud = regud.
      CONCATENATE payr-chect regud-text4(2) INTO  j_1bdmexp-p13.
    ELSE.
      CLEAR j_1bdmexp-p13.
* NOTE 606071 : G069
      IF j_1bdmexp-p07 = '01'.            "Código de Movimento Remessa
        j_1bdmexp-p13 = '00000000000000000000'.         "Nosso Número
      ENDIF.
    ENDIF.
  ELSE.
    j_1bdmexp-p13      = regup-xref3.
  ENDIF.
* Tipo de Documento: 1=Tradicional e 2=Escritural
  j_1bdmexp-p16      = '2'.
  j_1bdmexp-p14      = carteira(1).                   "carteira number
  j_1bdmexp-p15      = carteira+1(1).                 "cadastramento
  j_1bdmexp-p17      = carteira+2(1).                 "emmission
  j_1bdmexp-p18      = carteira+3(1).                 "distribution

  PERFORM fill_notafiscal CHANGING j_1bdmexp-p19.  "note 1087535
*  j_1bdmexp-p19(6)   = regup-xblnr(6).
*  j_1bdmexp-p19+6(3) = regup-buzei.

  CALL FUNCTION 'J_1B_FI_NETDUE'
    EXPORTING
      zfbdt   = regup-zfbdt
      zbd1t   = regup-zbd1t
      zbd2t   = regup-zbd2t
      zbd3t   = regup-zbd3t
    IMPORTING
      duedate = hlp_duedate
    EXCEPTIONS
      OTHERS  = 1.
  CONCATENATE hlp_duedate+6(2) hlp_duedate+4(2) hlp_duedate(4) INTO
              j_1bdmexp-p20.

  PERFORM amount_check CHANGING j_1bdmexp-p21.

  PERFORM for_curr_check USING regup-waers t001-waers
                           CHANGING j_1bdmexp-p21.

  j_1bdmexp-p22      = regup-xref2.             "agencia cobradora
  j_1bdmexp-p23      = regup-xref2+5(1).        "agencia cobr., control
  j_1bdmexp-p24      = '02'.
  j_1bdmexp-p25      = 'N'.
  CONCATENATE regup-bldat+6(2) regup-bldat+4(2) regup-bldat(4) INTO
              j_1bdmexp-p26.

* -----Interests ------------------------------------------
  IF regup-zinkz NE space OR knb1-vzskz IS INITIAL.
    j_1bdmexp-p27   = '3'.                     "no interest
    j_1bdmexp-p28 = '00000000'.
  ELSE.

*   Note 840288: The interest calculation indicator must be considered
*   from the customer master record and not always assigned to "1"
*    if knb1-vzskz is not initial.
*      j_1bdmexp-p27  = knb1-vzskz.  "interest from customer master
*    else.
*      j_1bdmexp-p27  = '1'.    "interest
*    endif.

* Note 975006 Begins - REVERSAL of Note 840288
* P27 actually corresponds to the following field of segment P :
*"Código do Juros de Mora". It refers to -Password used by FEBRABAN -
*(BRAZILIAN FEDERATION OF BANKS ASSOCIATIONS)
* to identify the Type of Payment of default interests and can have ONLY
*the following fixed values :
*'1'  =  Value per Diem
*'2'  =  Month Rate --> Not yet supported as the FM
*                       J_1B_GET_INTEREST_RATE_PER_DAY can only return
*                        daily rates and NOT monthly rates
*'3'  =  Free

    j_1bdmexp-p27  = '1'.    "interest
* Note 975006 End

    IF NOT hlp_duedate IS INITIAL.                          "hw0432966
      CONCATENATE hlp_duedate+6(2) hlp_duedate+4(2) hlp_duedate(4)
               INTO j_1bdmexp-p28.             "Date for interests
    ELSE.
      j_1bdmexp-p28 = '00000000'.
    ENDIF.                                                  "hw0432966
    CALL FUNCTION 'J_1B_GET_INTEREST_RATE_PER_DAY'
      EXPORTING
        duedate = hlp_duedate
        vzskz   = knb1-vzskz
        waers   = reguh-waers
      IMPORTING
        zinso   = hlp_zinso
      EXCEPTIONS
        OTHERS  = 1.

    hlp_interest      = ( reguh-rwbtr + reguh-rwskt )
                                   * hlp_zinso / 100 / 10000000.
    j_1bdmexp-p29     = hlp_interest.
    PERFORM for_curr_check USING reguh-waers t001-waers
                          CHANGING j_1bdmexp-p29.

  ENDIF.
* ----end interests -------------------------------------------

* ----discount ------------------------------------------------
  IF reguh-rskon EQ 0.
    j_1bdmexp-p30      = 0.                   "Código Desconto
    j_1bdmexp-p31      = '00000000'.          "Data Desconto
    j_1bdmexp-p32      = 0.                   "Vlr Perc.Concedid
  ELSE.
    j_1bdmexp-p30      = 1.                   "Código Desconto

    hlp_date = regup-zfbdt + regup-zbd1t.
    CONCATENATE hlp_date+6(2) hlp_date+4(2) hlp_date(4)
                INTO j_1bdmexp-p31.           "Data Descont
    j_1bdmexp-p32 = reguh-rwskt.             "Vlr Perc.Concedid
    PERFORM for_curr_check USING regup-waers t001-waers
                        CHANGING j_1bdmexp-p32.

  ENDIF.


* ---end discount ---------------------------------------------------

* rebate
*  J_1BDMEXP-P34        = REGUP-wrbtr - ( REGUH-Rwbtr + REGUH-Rwskt ).
  PERFORM check_rebate CHANGING lv_rebate.
  j_1bdmexp-p34        = lv_rebate.
  PERFORM for_curr_check USING regup-waers t001-waers
                         CHANGING j_1bdmexp-p34.

* uso da empresa
  j_1bdmexp-p35        = regup-kunnr.
  PERFORM dta_text_aufbereiten USING j_1bdmexp-p35.
  j_1bdmexp-p35+10     = regup-belnr.
  j_1bdmexp-p35+20(4)  = regup-gjahr.
* Downpayments : Note 859618
* Uso da Empresa must be filled with the special G/L indicator. This is
* needed later to clear the d/p request when the incoming file is loaded
  IF regup-umskz NE space.
    j_1bdmexp-p35+24(1)    = regup-umskz.
  ENDIF.


* protest code
  IF j_1bdmexp-p07 EQ '09' OR  j_1bdmexp-p07 EQ '01'.
    PERFORM weisungsschluessel_umsetzen USING
                              'BR' '2' t015w-dtws2         "export
                               j_1bdmexp-p36 dummy.        "import
    PERFORM weisungsschluessel_umsetzen USING
                              'BR' '3' t015w-dtws3         "export
                               j_1bdmexp-p37 dummy.        "import
  ELSE.
    j_1bdmexp-p36      = '3'.            " no protest
    j_1bdmexp-p37      = 0.
  ENDIF.

* clearing code
  IF j_1bdmexp-p07 NE '02'.                       "instruction 1
    PERFORM weisungsschluessel_umsetzen USING
                              'BR' '4' t015w-dtws4          "export "n2993717
                              j_1bdmexp-p38 dummy.          "import
    CLEAR j_1bdmexp-p39.
  ELSE.
    PERFORM weisungsschluessel_umsetzen USING
                              'BR' '4' t015w-dtws4         "export  "n2993717
                               j_1bdmexp-p38 dummy.        "import
    PERFORM weisungsschluessel_umsetzen USING
                              'BR' '3' t015w-dtws3         "export
                               j_1bdmexp-p39 dummy.        "import
  ENDIF.


* currency code
  READ TABLE currtab WITH KEY bukrs = reguh-zbukr
                              hbkid = reguh-hbkid
                              waers = reguh-waers.
  IF sy-subrc NE 0.
    MESSAGE e124(icc_cl) WITH 'CURRTAB'.
  ENDIF.

  j_1bdmexp-p40        = currtab-dmecurr.

  CALL BADI obj_rffobr->change_febraban_seg_p24   "Note 2169582
    EXPORTING
      is_reguh = reguh
      is_regup = regup
    CHANGING
      cv_p24   = j_1bdmexp-p24.

* -----Details segment Q -----------------------------------------------
  cnt_posten           = cnt_posten + 1.
  cnt_records          = cnt_records + 1.

* J_1BDMEXQ-UP_CRLF    = UP_CRLF.

  j_1bdmexq-q01        = reguh-ubnkl(3).   "Código do Banco
  j_1bdmexq-q02        =  1.               "Número do Lote
  j_1bdmexq-q03        = '3'.              "Tipo de Registro
  j_1bdmexq-q04        = cnt_posten.       "record number
  j_1bdmexq-q05        = 'Q'.              "segment type
  j_1bdmexq-q07        = j_1bdmexp-p07.    "instruction
  j_1bdmexq-q08        = hlp_stkzn.
  j_1bdmexq-q09        = hlp_taxcode.
  j_1bdmexq-q10        = kna1-name1.
  PERFORM dta_text_aufbereiten USING j_1bdmexq-q10.

*  IF KNA1-KNRZA IS INITIAL.                "Note 1767203
  j_1bdmexq-q11        = kna1-stras.
  PERFORM dta_text_aufbereiten USING j_1bdmexq-q11.
  j_1bdmexq-q12        = kna1-ort02.
  PERFORM dta_text_aufbereiten USING j_1bdmexq-q12.
  j_1bdmexq-q13        = kna1-pstlz(5).
  j_1bdmexq-q14        = kna1-pstlz+6(3).
  j_1bdmexq-q15        = kna1-ort01.
  PERFORM dta_text_aufbereiten USING j_1bdmexq-q15.
*  ENDIF.

  j_1bdmexq-q16       = reguh-zregi.


  PERFORM dta_text_aufbereiten USING j_1bdmexq-q16.
* Nosso Numero in Segment P / Nosso numero in Segment Q
  j_1bdmexq-q21        = ' '.

ENDFORM.                    " FILL_DEATILS_FEBRABAN
*&---------------------------------------------------------------------*
*&      Form  FILL_TRAILER_FEBRABAN
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM fill_trailer_febraban.

*   DATA  UP_CRLF(2) TYPE X VALUE '0D0A'."carriage return + line feed
  CLEAR: j_1bdmext1, j_1bdmext3.  "Data set: trailer, lot trailer

*   Lot trailer
  cnt_records             = cnt_records + 1.
*   J_1BDMEXT3-UP_CRLF      = UP_CRLF.
  j_1bdmext3-t301         = reguh-ubnkl(3).
  j_1bdmext3-t302         = 1.
  j_1bdmext3-t303         = '5'.
  j_1bdmext3-t305         = cnt_posten + 2.

*   Trailer
  cnt_records             = cnt_records + 1.
*   J_1BDMEXT1-J_1BCRLF     = UP_CRLF.

  j_1bdmext1-t101         = reguh-ubnkl(3).
  j_1bdmext1-t102         = '9999'.
  j_1bdmext1-t103         = '9'.
  j_1bdmext1-t105         = 1.
  j_1bdmext1-t106         = cnt_records.
  j_1bdmext1-t107(6)      = '000000'.

ENDFORM.                    " FILL_TRAILER_FEBRABAN
*&---------------------------------------------------------------------*
*&      Form  check_rebate
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_LV_REBATE  text
*----------------------------------------------------------------------*
FORM check_rebate  CHANGING lv_rebate.

  DATA: BEGIN OF lt_bsid.
          INCLUDE STRUCTURE bsid.
  DATA: END   OF lt_bsid.

  SELECT * FROM bsid INTO lt_bsid
                     WHERE bukrs EQ regup-bukrs
                       AND kunnr EQ regup-kunnr
                       AND rebzg EQ regup-belnr
                       AND rebzj EQ regup-gjahr
                       AND rebzz EQ regup-buzei.

    IF sy-subrc = 0 AND lt_bsid-shkzg = 'H'.
* Get all lines for rebate
      lv_rebate = lv_rebate + lt_bsid-dmbtr.
    ENDIF.
  ENDSELECT.


ENDFORM.                    " check_rebate
*&---------------------------------------------------------------------*
*&      Form  amount_check
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_J_1BDMEXP_P21  text
*----------------------------------------------------------------------*
FORM amount_check  CHANGING amount.

* Check if there is more than 1 line item
* REGUH-RBETR and REGUP-DMBTR will not be equal in case there are more
* than 1 line items or when there is a rebate

  CASE reguh-ubnkl(3).

    WHEN '341'. " Itau

      IF reguh-rbetr <> regup-dmbtr.

        IF regup-qsskz NE space.
* Amount should always be identical to the amount printed in the boleto.
* Check Function module BOLETO_DATA
*Note 1396267
*         amount     = regup-dmbtr + reguh-rskon.
          IF NOT ( regup-qbshb IS INITIAL OR regup-qbshh IS INITIAL ).

            amount     = regup-dmbtr - regup-qbshh.
          ELSE.

            amount     = regup-dmbtr.
          ENDIF.
*Note 1396267

          hlp_vblnr           = reguh-vblnr.

        ELSE.

          amount     = regup-dmbtr.

        ENDIF.
      ELSE.

        amount = reguh-rbetr + reguh-rskon.

      ENDIF.

    WHEN OTHERS. " Boleto and Febraban

      IF reguh-rwbtr <> regup-wrbtr.

        IF regup-qsskz NE space.

* Amount should always be identical to the amount printed in the boleto.
* Check Function module BOLETO_DATA
* Note 944856 changes starts
          IF NOT ( regup-qbshb IS INITIAL OR regup-qbshh IS INITIAL ).

            amount     = regup-wrbtr - regup-qbshb.
          ELSE.

            amount     = regup-wrbtr ."note 1384242
          ENDIF.
* Note 944856 changes ends
          hlp_vblnr           = reguh-vblnr.

        ELSE.

          amount     = regup-wrbtr.

        ENDIF.

      ELSE.

        amount = reguh-rwbtr + reguh-rwskt.

      ENDIF.

  ENDCASE.

ENDFORM.                    " amount_check



***********Start of PDF conversion ,Date: 15/03/2005 ,C5056173


*&---------------------------------------------------------------------*
*&      Form  open_form_pdf
*&---------------------------------------------------------------------*
*       Open PDF form
*----------------------------------------------------------------------*
FORM open_form_pdf.

  IF t042e-pdffo IS INITIAL.
    MOVE t042e-zforn TO gv_formname .
  ELSE.
    MOVE t042e-pdffo TO gv_formname .
  ENDIF.

  TRY.
* Get the function module names for the form
      CALL FUNCTION 'FP_FUNCTION_MODULE_NAME'
        EXPORTING
          i_name           = gv_formname
        IMPORTING
          e_funcname       = gv_fm_name
          e_interface_type = gv_interface_type.

    CATCH cx_fp_api_repository INTO gv_cx_fp_api_repository.
      MESSAGE gv_cx_fp_api_repository TYPE 'E'.
    CATCH cx_fp_api_internal INTO gv_cx_fp_api_internal.
      MESSAGE gv_cx_fp_api_internal TYPE 'E'.
    CATCH cx_fp_api_usage INTO gv_cx_fp_api_usage.
      MESSAGE gv_cx_fp_api_usage TYPE 'E'.
    CATCH cx_root INTO gv_w_cx_root.                     "#EC CATCH_ALL
      MESSAGE gv_w_cx_root TYPE 'E'.

  ENDTRY.

* to be uncommented if output parameters are to be specified
** Fill print parameters for the form
  PERFORM fill_outputparams_pdf
                            CHANGING gv_fp_outputparams.

  TRY.
*  To start the pdf
      CALL FUNCTION 'FP_JOB_OPEN'
        CHANGING
          ie_outputparams = gv_fp_outputparams
        EXCEPTIONS
          cancel          = 1
          usage_error     = 2
          system_error    = 3
          internal_error  = 4
          OTHERS          = 5.
      IF sy-subrc <> 0.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      ENDIF.

    CATCH cx_root.

  ENDTRY.

ENDFORM.                    " open_form_pdf


*&---------------------------------------------------------------------*
*&      Form  output_pdf
*&---------------------------------------------------------------------*
*       Display output in ADOBE PDF Format
*----------------------------------------------------------------------*
FORM output_pdf .

  CALL FUNCTION gv_fm_name
    EXPORTING
      total              = gs_total
      data               = gt_data
    IMPORTING
      /1bcdwb/formoutput = gv_fpformoutput
    EXCEPTIONS
      usage_error        = 1
      system_error       = 2
      internal_error     = 3
      OTHERS             = 4.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

ENDFORM.                    " output_pdf


*&---------------------------------------------------------------------*
*&      Form  close_form_pdf
*&---------------------------------------------------------------------*
*       Close PDF form
*----------------------------------------------------------------------*
FORM close_form_pdf .

  DATA : ls_sfpjoboutput TYPE sfpjoboutput.
* Close PDF form.
  CALL FUNCTION 'FP_JOB_CLOSE'
    IMPORTING
      e_result       = ls_sfpjoboutput
    EXCEPTIONS
      usage_error    = 1
      system_error   = 2
      internal_error = 3
      OTHERS         = 4.
  IF sy-subrc = 0.
    CLEAR tab_ausgabe.
    tab_ausgabe-name    = gv_fp_outputparams-covtitle.
    tab_ausgabe-dataset = gv_fp_outputparams-dataset.
    READ TABLE ls_sfpjoboutput-spoolids INTO
                 tab_ausgabe-spoolnr INDEX 1.
    COLLECT tab_ausgabe.
  ELSE.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
          WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

ENDFORM.                    " close_form_pdf



************************************************************************
* Form: SEUNUM:  write seu numero which is
*                nota fiscal number + posting line of cust. inv
*                for vendor operation write line number of vend op
*                doc + year + sl ind. (note line is always '001'.=
*
*
************************************************************************
FORM seunum_pdf CHANGING seunum.

  CLEAR: seunum.
* If its a vendor operation document
  IF regup-umskz = gc_splind.
    CONCATENATE reguh-pyord regup-umskz INTO seunum.
  ELSE.
    CONCATENATE regup-xblnr(6) '-' regup-buzei INTO seunum.
  ENDIF.

ENDFORM.                    "seunum_pdf


************************************************************************
* Form VALOR: Write amounts and currency symbols
*
* usage in SAP-Script:
* PERFORM CURR IN PROGRAM RFIDBR_BOLETO
* USING &REGUH-WAERS&
* CHANGING &BETR&
* ENDPERFORM
************************************************************************
FORM valor_pdf CHANGING esp quan val .
  " TABLES INPUT_FIELDS  STRUCTURE ITCSY
  " OUTPUT_FIELDS STRUCTURE ITCSY.


  DATA: hwaer    LIKE t001-waers,
        twaer    LIKE reguh-waers,
        zbukr    LIKE reguh-zbukr,
        hbkid    LIKE reguh-hbkid,
        tiso     LIKE reguh-waers,
        tamo(18) TYPE c,
        hamo(18) TYPE c,
        test(1)  TYPE c.

  CLEAR: esp, quan, val.

  hwaer = t001-waers.

  zbukr = reguh-zbukr.

  hbkid = reguh-hbkid.

  IF reguh-waers(2) = 'XX'.
    test = 'X'.
  ENDIF.

  IF test IS INITIAL.
    twaer = reguh-waers.

* fill currency information
    PERFORM curr_fill(rffobr_d) TABLES currtab
                      USING zbukr hbkid
                            twaer.

  ENDIF.

*READ TABLE INPUT_FIELDS INDEX 5.
  IF test IS INITIAL.
    tamo = regud-wrbtr.
    SHIFT tamo LEFT DELETING LEADING space.
  ENDIF.

*READ TABLE INPUT_FIELDS INDEX 6.
  IF test IS INITIAL.
    hamo = regud-dmbtr.
    SHIFT hamo LEFT DELETING LEADING space.
  ENDIF.

  IF test IS INITIAL.
    READ TABLE currtab WITH KEY bukrs = zbukr
                                hbkid = hbkid
                                waers = twaer.
    IF sy-subrc NE 0.
      MESSAGE e124(icc_cl) WITH 'CURRTAB'.
    ENDIF.

    esp = currtab-bolcurr.

* foreign currency involved
    IF hwaer NE twaer.
      CLEAR val.
      quan = tamo.
    ELSE.
      CLEAR: quan.
      val = hamo.
    ENDIF.
  ELSE.
    esp = 'XXX'.
    val = 'XXXXXXXXXXXXXXX'.
    quan = 'XXXXXXXXXXXXXXX'.
  ENDIF.

ENDFORM.                    "VALOR_PDF


************End  of PDF conversion ,Date: 15/03/2005 ,C5056173

******************************************************************
***********Start of PDF conversion ,Date: 19/03/2005 ,C5056173

*----------------------------------------------------------------------*
* FORM SCHECK_PDF                                                      *
*----------------------------------------------------------------------*
* Druck des Avises mit Allongeteil                                     *
* (Beispiel Scheck)                                                    *
* Gerufen von END-OF-SELECTION (RFFOxxxz)                              *
*----------------------------------------------------------------------*
* prints a remittance advice with a check                              *
* called by END-OF-SELECTION (RFFOxxxz)                                *
*----------------------------------------------------------------------*
* keine USING-Parameter                                                *
* no USING-parameters                                                  *
*----------------------------------------------------------------------*
FORM scheck_pdf.


* Tabellen für den Angabeteil von Auslandsschecks in Österreich
* Austria only
  DATA:
    BEGIN OF up_oenb_angaben OCCURS 5, "Angaben zur OeNB-Meldung
      diekz    LIKE regup-diekz,       "Anmerkung: die betragshöchste
      lzbkz    LIKE regup-lzbkz,       "Angabe wird auf den Angabenteil
      summe(7) TYPE p,                 "übernommen
    END OF up_oenb_angaben,
    BEGIN OF up_oenb_kontowae OCCURS 5,"Kontowährung der Hausbankkonten
      ubhkt LIKE reguh-ubhkt,       "für die OeNB-Meldung
      uwaer LIKE t012k-waers,
    END OF up_oenb_kontowae.


***********Start of PDF conversion ,Date: 19/03/2005 ,C5056173
* Data declaration for pdf
  DATA: seunum(15) TYPE c.

  DATA: esp(5)      TYPE c,
        quan(18)    TYPE c,
        val(18)     TYPE c,
        lv_temp(20) TYPE c.

  IF NOT t042e-zforn IS INITIAL.
    gv_script = gc_x.
  ELSE.
    gv_script = ' '.
  ENDIF.

************End  of PDF conversion ,Date: 19/03/2005 ,C5056173


*----------------------------------------------------------------------*
* Abarbeiten der extrahierten Daten                                    *
* loop at extracted data                                               *
*----------------------------------------------------------------------*
  IF flg_sort NE 2.
    SORT BY avis.
    flg_sort = 2.
  ENDIF.

  hlp_ep_element = '525'.

  LOOP.


*-- Neuer zahlender Buchungskreis --------------------------------------
*-- new paying company code --------------------------------------------
    AT NEW reguh-zbukr.

      PERFORM buchungskreis_daten_lesen.
*Moving the cnpj of company to the local variable to display in Boleto form.
      PERFORM read_branch_data.
      WRITE j_1bwfield-cgc_number USING EDIT MASK 'RR__.___.___/____-__' TO company_cnpj.

    ENDAT.


*-- Neuer Zahlweg ------------------------------------------------------
*-- new payment method -------------------------------------------------
    AT NEW reguh-rzawe.

      flg_probedruck = 0.              "für diesen Zahlweg wurde noch
      "kein Probedruck durchgeführt
      "test print for this payment
      "method not yet done
      PERFORM zahlweg_daten_lesen.

*     Spoolparameter zur Ausgabe des Schecks angeben
*     specify spool parameters for check print
      PERFORM fill_itcpo USING par_priz
                               t042z-zlstn
                               space   "par_sofz via tab_ausgabe!
                               hlp_auth.

      IF flg_schecknum NE 0.
        itcpo-tddelete  = 'X'.         "delete after print
      ENDIF.
      EXPORT itcpo TO MEMORY ID 'RFFORI01_ITCPO'.



      CALL FUNCTION 'OPEN_FORM'
        EXPORTING
          archive_index  = toa_dara
          archive_params = arc_params
          form           = t042e-zforn
          device         = 'PRINTER'
          language       = t001-spras
          options        = itcpo
          dialog         = flg_dialog
        IMPORTING
          result         = itcpp
        EXCEPTIONS
          form           = 1.
      IF sy-subrc EQ 1.              "abend:
        IF sy-batch EQ space.        "form is not active
          MESSAGE a069 WITH t042e-zforn.
        ELSE.
          MESSAGE s069 WITH t042e-zforn.
          MESSAGE s094.
          STOP.
        ENDIF.
      ENDIF.




*     Formular auf Segmenttext (Global &REGUP-SGTXT) untersuchen
*     examine whether segment text is to be printed
      IF t042e-xavis NE space AND t042e-anzpo NE 99.
        flg_sgtxt = 0.
        CALL FUNCTION 'READ_FORM_LINES'
          EXPORTING
            element = hlp_ep_element
          TABLES
            lines   = tab_element
          EXCEPTIONS
            element = 1.
        IF sy-subrc EQ 0.
          LOOP AT tab_element.
            IF    tab_element-tdline   CS 'REGUP-SGTXT'
              AND tab_element-tdformat NE '/*'.
              flg_sgtxt = 1.           "Global für Segmenttext existiert
              EXIT.                    "global for segment text exists
            ENDIF.
          ENDLOOP.
        ENDIF.
      ENDIF.

*     Scheck auf Währungsschlüssel (Global &REGUD-WAERS&) und Maximal-
*     betrag für die Umsetzung der Ziffern in Worten untersuchen
*     currency code &REGUD-WAERS& has to exist in window CHECK for
*     foreign currency checks, compute maximal amount 'in words'
      flg_fw_scheck = 0.
      IF t042z-xeinz EQ space.
        hlp_element = '545'.
      ELSE.
        hlp_element = '546'.
      ENDIF.
      CALL FUNCTION 'READ_FORM_LINES'
        EXPORTING
          window  = 'CHECK'
          element = hlp_element
        TABLES
          lines   = tab_element
        EXCEPTIONS
          element = 2.
      CALL FUNCTION 'READ_FORM_LINES'
        EXPORTING
          window  = 'CHECKSPL'
          element = hlp_element
        TABLES
          lines   = tab_element2
        EXCEPTIONS
          element = 2.
      APPEND LINES OF tab_element2 TO tab_element.

      hlp_maxstellen = 0.              "der Maximalbetrag wird nur
      hlp_maxbetrag  = 10000000000000. "berechnet, wenn die Globals
      "SPELL-DIGnn verwendet wurden
      IF sy-tabix NE 0.                "max. amount only computed if
        LOOP AT tab_element.           "globals SPELL-DIGnn are used
          IF tab_element-tdformat NE '/*'.
*           Währungsschlüssel
*           currency code
            IF tab_element-tdline CP '*REGU+-WAERS*'.
              flg_fw_scheck = 1.
            ENDIF.
*           Maximal umsetzbare Stellen ermitteln
*           find out maximal number of places which can be transformed
            WHILE tab_element-tdline CS '&SPELL-DIG'.
              SHIFT tab_element-tdline BY sy-fdpos PLACES.
              SHIFT tab_element-tdline BY 10 PLACES.
              IF tab_element-tdline(2) CO '0123456789'.
                IF hlp_maxstellen LT tab_element-tdline(2). "#EC PORTABLE
                  hlp_maxstellen = tab_element-tdline(2).
                ENDIF.
              ENDIF.
            ENDWHILE.
          ENDIF.
        ENDLOOP.
*       Maximalbetrag ermitteln
*       compute maximal amount for transformation 'in words'
        IF hlp_maxstellen NE 0.
          hlp_maxbetrag = 1.
          DO hlp_maxstellen TIMES.
            hlp_maxbetrag = hlp_maxbetrag * 10.
          ENDDO.
        ENDIF.
      ENDIF.
      CALL FUNCTION 'CLOSE_FORM'.

    ENDAT.


*-- Neue Hausbank ------------------------------------------------------
*-- new house bank -----------------------------------------------------
    AT NEW reguh-ubnkl.

      PERFORM hausbank_daten_lesen.

*     Felder für Formularabschluß initialisieren
*     initialize fields for summary
      cnt_formulare = 0.
      cnt_hinweise  = 0.
      sum_abschluss = 0.

      flg_druckmodus = 0.
*     Vornumerierte Schecks: erste Schecknummer ermitteln
*     prenumbered checks: find out first check number
      IF flg_schecknum NE 0.
        PERFORM schecknummer_ermitteln USING 1.
      ENDIF.

    ENDAT.


*-- Neue Kontonummer bei der Hausbank ----------------------------------
*-- new account number with house bank ---------------------------------
    AT NEW reguh-ubknt.

*     Kontonummer ohne Aufbereitungszeichen für OCRA-Zeile speichern
*     store numerical account number for code line
      regud-obknt = reguh-ubknt.

    ENDAT.


*-- Neue Empfängerbank -------------------------------------------------
*-- new bank of payee --------------------------------------------------
    AT NEW reguh-zbnkl.

      PERFORM empfbank_daten_lesen.

    ENDAT.


*-- Neue Zahlungsbelegnummer -------------------------------------------
*-- new payment document number ----------------------------------------
    AT NEW reguh-vblnr.

*     Angabentabelle und Kontowährung für die OeNB-Meldung (Österreich)
*     Austria only
      IF t042e-xausl EQ 'X' AND        "nur Auslandsscheck
        hlp_laufk NE 'P'.              "kein HR
        REFRESH up_oenb_angaben.
        CLEAR up_oenb_kontowae.
        READ TABLE up_oenb_kontowae WITH KEY reguh-ubhkt.
        IF sy-subrc NE 0.
          PERFORM hausbank_konto_lesen.
          up_oenb_kontowae-ubhkt = reguh-ubhkt.
          PERFORM isocode_umsetzen
            USING t012k-waers up_oenb_kontowae-uwaer.
          APPEND up_oenb_kontowae.
        ENDIF.
      ENDIF.

*     Lesen der Referenzangaben (Schweiz)
*     Switzerland only
      PERFORM hausbank_konto_lesen.

*     Kein Druck falls Fremdwährung, aber kein Fremdwährungsscheck
*     no print if foreign currency, but global &REGUD-WAERS& is missing
      flg_kein_druck = 0.
      IF reguh-waers NE t001-waers AND flg_fw_scheck EQ 0.
        err_fw_scheck-fname = t042e-zforn.
        MOVE-CORRESPONDING reguh TO err_fw_scheck.
        COLLECT err_fw_scheck.
        flg_kein_druck = 1.            "kein Druck möglich
      ENDIF.                           "no print

      IF flg_kein_druck EQ 0.

        PERFORM zahlungs_daten_lesen.

*       Tag der Zahlung in Worten (Spanien)
*       day of payment in words (Spain)
        CLEAR t015z.
        SELECT SINGLE * FROM t015z
          WHERE spras EQ hlp_sprache
            AND einh  EQ reguh-zaldt+6(1)
            AND ziff  EQ reguh-zaldt+7(1).
        IF sy-subrc EQ 0.
          regud-text2 = t015z-wort.
          TRANSLATE regud-text2 TO LOWER CASE.           "#EC TRANSLANG
          TRANSLATE regud-text2 USING '; '.
        ELSE.
          CLEAR err_t015z.
          err_t015z-spras = hlp_sprache.
          err_t015z-einh  = reguh-zaldt+6(1).
          err_t015z-ziff  = reguh-zaldt+7(1).
          COLLECT err_t015z.
        ENDIF.

*       Elementname für die Einzelposteninformation ermitteln
*       determine element name for item list
        IF hlp_laufk EQ 'P' OR
           hrxblnr-txtsl EQ 'HR' AND hrxblnr-txerg EQ 'GRN'.
          hlp_ep_element = '525-HR'.
        ELSE.
          hlp_ep_element = '525'.
        ENDIF.

*       Name des Fensters mit dem Anschreiben zusammensetzen
*       specify name of the window with the check text
        hlp_element   = '510-'.
        hlp_element+4 = reguh-rzawe.
        hlp_eletext   = text_510.
        REPLACE '&ZAHLWEG' WITH reguh-rzawe INTO hlp_eletext.

*       Druckvorgaben modifizieren lassen
*       modification of print parameters
        IMPORT itcpo FROM MEMORY ID 'RFFORI01_ITCPO'.
        PERFORM modify_itcpo.

*       open form only at first time or when optical archiving is active
        IF flg_druckmodus NE 1 OR itcpo-tdarmod NE '1'.
*         Scheckformular öffnen
*         open check form
          IF cnt_formulare EQ 0.
            itcpo-tdnewid = 'X'.
          ELSE.
            itcpo-tdnewid = space.
          ENDIF.
          IF par_priz EQ space.
            flg_dialog = 'X'.
          ELSE.
            flg_dialog = space.
          ENDIF.

*         close last form
          IF flg_druckmodus NE 0.
            CALL FUNCTION 'CLOSE_FORM'
              IMPORTING
                result = itcpp.

            IF itcpp-tdspoolid NE 0.
              CLEAR tab_ausgabe.
              tab_ausgabe-name    = t042z-text1.
              tab_ausgabe-dataset = itcpp-tddataset.
              tab_ausgabe-spoolnr = itcpp-tdspoolid.
              tab_ausgabe-immed   = par_sofz.
              COLLECT tab_ausgabe.
            ENDIF.
          ENDIF.

          flg_druckmodus = itcpo-tdarmod.


          CALL FUNCTION 'OPEN_FORM'
            EXPORTING
              archive_index  = toa_dara
              archive_params = arc_params
              form           = t042e-zforn
              device         = 'PRINTER'
              language       = t001-spras
              options        = itcpo
              dialog         = flg_dialog
            IMPORTING
              result         = itcpp
            EXCEPTIONS
              form           = 1.
          IF sy-subrc EQ 1.              "abend:
            IF sy-batch EQ space.        "form is not active
              MESSAGE a069 WITH t042e-zforn.
            ELSE.
              MESSAGE s069 WITH t042e-zforn.
              MESSAGE s094.
              STOP.
            ENDIF.
          ENDIF.

***********Start of PDF conversion ,Date: 21/03/2005 ,C5056173
          IF gv_script IS INITIAL.
* Open PDF form.
            PERFORM open_form_pdf .
          ENDIF.
************End  of PDF conversion ,Date: 21/03/2005 ,C5056173

          par_priz = itcpp-tddest.
          PERFORM fill_itcpo_from_itcpp.
          EXPORT itcpo TO MEMORY ID 'RFFORI01_ITCPO'.
        ENDIF. "flg_druckmodus NE 1 OR itcpo-tdarmod NE '1'

*       Probedruck
*       test print
        IF flg_probedruck EQ 0.        "Probedruck noch nicht erledigt
          PERFORM daten_sichern.       "test print not yet done
          IF flg_schecknum EQ 2.
            regud-chect = xxx_regud-chect.
            regud-checf = xxx_regud-checf.
          ENDIF.
          cnt_seiten = 0.
          DO par_anzp TIMES.
*           Vornumerierte Schecks: Schecknummer hochzählen ab 2.Seite
*           prenumbered checks: add 1 to check number
            IF flg_schecknum EQ 1 AND sy-index GT 1.
              hlp_page = sy-index.
              PERFORM schecknummer_addieren.
            ENDIF.
*           Probedruck-Formular starten
*           start test print form
            CALL FUNCTION 'START_FORM'
              EXPORTING
                language = hlp_sprache.
*           Fenster mit Probedruck schreiben
*           write windows with test print
            CALL FUNCTION 'WRITE_FORM'
              EXPORTING
                window   = 'INFO'
                element  = '505'
                function = 'APPEND'
              EXCEPTIONS
                window   = 1
                element  = 2.
            CALL FUNCTION 'WRITE_FORM'
              EXPORTING
                window  = 'CHECK'
                element = '540'
              EXCEPTIONS
                window  = 1
                element = 2.
            CALL FUNCTION 'WRITE_FORM'
              EXPORTING
                element = hlp_element
              EXCEPTIONS
                window  = 1
                element = 2.
            IF sy-subrc NE 0.
              CALL FUNCTION 'WRITE_FORM'
                EXPORTING
                  element = '510'
                EXCEPTIONS
                  window  = 1
                  element = 2.
            ENDIF.
            CALL FUNCTION 'WRITE_FORM'
              EXPORTING
                element = '514'
              EXCEPTIONS
                window  = 1
                element = 2.
            CALL FUNCTION 'WRITE_FORM'
              EXPORTING
                element = '515'
              EXCEPTIONS
                window  = 1
                element = 2.
            CALL FUNCTION 'WRITE_FORM'
              EXPORTING
                element  = hlp_ep_element
                function = 'APPEND'
              EXCEPTIONS
                window   = 1
                element  = 2.
            CALL FUNCTION 'WRITE_FORM'
              EXPORTING
                element  = '530'
                function = 'APPEND'
              EXCEPTIONS
                window   = 1
                element  = 2.
            CALL FUNCTION 'WRITE_FORM'
              EXPORTING
                window  = 'TOTAL'
                element = '530'
              EXCEPTIONS
                window  = 1
                element = 2.
            CALL FUNCTION 'WRITE_FORM'
              EXPORTING
                window   = 'INFO'
                element  = '505'
                function = 'DELETE'
              EXCEPTIONS
                window   = 1
                element  = 2.
*           Probedruck-Formular beenden
*           End test print
            CALL FUNCTION 'END_FORM'
              IMPORTING
                result = itcpp.
            IF itcpp-tdpages EQ 0.     "Print via RDI
              itcpp-tdpages = 1.
            ENDIF.
            ADD itcpp-tdpages TO cnt_seiten.
          ENDDO.
          IF flg_schecknum EQ 1 AND cnt_seiten GT 0.
            PERFORM scheckinfo_speichern USING 1.
          ENDIF.
          PERFORM daten_zurueck.
          flg_probedruck = 1.          "Probedruck erledigt
        ENDIF.                         "Test print done

***********Start of PDF conversion ,Date: 21/03/2005 ,C5056173
        IF gv_script IS INITIAL.

        ENDIF.
************End  of PDF conversion ,Date: 21/03/2005 ,C5056173


        PERFORM summenfelder_initialisieren.

*       Prüfe, ob HR-Formular zu verwenden ist
*       Check if HR-form is to be used
        IF ( hlp_laufk EQ 'P' OR
             hrxblnr-txtsl EQ 'HR' AND hrxblnr-txerg EQ 'GRN' )
         AND hrxblnr-xhrfo NE space.
          hlp_xhrfo = 'X'.
        ELSE.
          hlp_xhrfo = space.
        ENDIF.


***********Start of PDF conversion ,Date: 21/03/2005 ,C5056173
        IF NOT gv_script IS INITIAL.
************End  of PDF conversion ,Date: 21/03/2005 ,C5056173

*       Formular starten
*       start check form
          CALL FUNCTION 'START_FORM'
            EXPORTING
              archive_index = toa_dara
              language      = hlp_sprache.
***********Start of PDF conversion ,Date: 21/03/2005 ,C5056173
        ENDIF.
************End  of PDF conversion ,Date: 21/03/2005 ,C5056173


*       Vornumerierte Schecks: nächste Schecknummer ermitteln
*       prenumbered checks: compute next check number
        IF flg_schecknum NE 0.
          PERFORM schecknummer_ermitteln USING 2.
        ENDIF.

***********Start of PDF conversion ,Date: 21/03/2005 ,C5056173
        IF NOT gv_script IS INITIAL.
************End  of PDF conversion ,Date: 21/03/2005 ,C5056173

*       Fenster Check, Element Entwerteter Scheck
*       window check, element voided check
          CALL FUNCTION 'WRITE_FORM'
            EXPORTING
              window  = 'CHECK'
              element = '540'
            EXCEPTIONS
              window  = 1
              element = 2.
          IF sy-subrc EQ 2.
            err_element-fname = t042e-zforn.
            err_element-fenst = 'CHECK'.
            err_element-elemt = '540'.
            err_element-text  = text_540.
            COLLECT err_element.
          ENDIF.

***********Start of PDF conversion ,Date: 21/03/2005 ,C5056173
        ENDIF.
************End  of PDF conversion ,Date: 21/03/2005 ,C5056173

        IF hlp_xhrfo EQ space.

***********Start of PDF conversion ,Date: 21/03/2005 ,C5056173
          IF NOT gv_script IS INITIAL.
************End  of PDF conversion ,Date: 21/03/2005 ,C5056173

*         Fenster Info, Element Unsere Nummer (falls diese gefüllt ist)
*         window info, element our number (if filled)
            IF reguh-eikto NE space.
              CALL FUNCTION 'WRITE_FORM'
                EXPORTING
                  window   = 'INFO'
                  element  = '505'
                  function = 'APPEND'
                EXCEPTIONS
                  window   = 1
                  element  = 2.
              IF sy-subrc EQ 2.
                err_element-fname = t042e-zforn.
                err_element-fenst = 'INFO'.
                err_element-elemt = '505'.
                err_element-text  = text_505.
                COLLECT err_element.
              ENDIF.
            ENDIF.

*         Fenster Carry Forward, Element Übertrag (außer letzte Seite)
*         window carryfwd, element carry forward below (not last page)
            CALL FUNCTION 'WRITE_FORM'
              EXPORTING
                window  = 'CARRYFWD'
                element = '535'
              EXCEPTIONS
                window  = 1
                element = 2.
            IF sy-subrc EQ 2.
              err_element-fname = t042e-zforn.
              err_element-fenst = 'CARRYFWD'.
              err_element-elemt = '535'.
              err_element-text  = text_535.
              COLLECT err_element.
            ENDIF.

*         Hauptfenster, Element Anschreiben (nur auf der ersten Seite)
*         main window, element check text (only on first page)
            CALL FUNCTION 'WRITE_FORM'
              EXPORTING
                element = hlp_element
              EXCEPTIONS
                window  = 1
                element = 2.
            IF sy-subrc EQ 2.
              CALL FUNCTION 'WRITE_FORM'
                EXPORTING
                  element = '510'
                EXCEPTIONS
                  window  = 1
                  element = 2.
              err_element-fname = t042e-zforn.
              err_element-fenst = 'MAIN'.
              err_element-elemt = hlp_element.
              err_element-text  = hlp_eletext.
              COLLECT err_element.
            ENDIF.

*         Hauptfenster, Element Zahlung erfolgt im Auftrag von
*         main window, element payment by order of
            IF reguh-absbu NE reguh-zbukr.
              CALL FUNCTION 'WRITE_FORM'
                EXPORTING
                  element = '513'
                EXCEPTIONS
                  window  = 1
                  element = 2.
              IF sy-subrc EQ 2.
                err_element-fname = t042e-zforn.
                err_element-fenst = 'MAIN'.
                err_element-elemt = '513'.
                err_element-text  = text_513.
                COLLECT err_element.
              ENDIF.
            ENDIF.

*         Hauptfenster, Element Abweichender Zahlungsemfänger
*         main window, element different payee
            IF regud-xabwz EQ 'X'.
              CALL FUNCTION 'WRITE_FORM'
                EXPORTING
                  element = '512'
                EXCEPTIONS
                  window  = 1
                  element = 2.
              IF sy-subrc EQ 2.
                err_element-fname = t042e-zforn.
                err_element-fenst = 'MAIN'.
                err_element-elemt = '512'.
                err_element-text  = text_512.
                COLLECT err_element.
              ENDIF.
            ENDIF.

*         Hauptfenster, Element Gruß und Unterschrift
*         main window, element regards and signature
            CALL FUNCTION 'WRITE_FORM'
              EXPORTING
                element = '514'
              EXCEPTIONS
                window  = 1
                element = 2.

*         Hauptfenster, Element Überschrift (nur auf der ersten Seite)
*         main window, element title (only on first page)
            CALL FUNCTION 'WRITE_FORM'
              EXPORTING
                element = '515'
              EXCEPTIONS
                window  = 1
                element = 2.
            IF sy-subrc EQ 2.
              err_element-fname = t042e-zforn.
              err_element-fenst = 'MAIN'.
              err_element-elemt = '515'.
              err_element-text  = text_515.
              COLLECT err_element.
            ENDIF.

*         Hauptfenster, Element Überschrift (ab der zweiten Seite oben)
*         main window, element title (2nd and following pages)
            CALL FUNCTION 'WRITE_FORM'
              EXPORTING
                element = '515'
                type    = 'TOP'
              EXCEPTIONS
                window  = 1        "Fehler bereits oben gemerkt
                element = 2.       "error already noted

*         Hauptfenster, Element Übertrag (ab der zweiten Seite oben)
*         main window, element carry forward above (2nd and following p)
            CALL FUNCTION 'WRITE_FORM'
              EXPORTING
                element  = '520'
                type     = 'TOP'
                function = 'APPEND'
              EXCEPTIONS
                window   = 1
                element  = 2.
            IF sy-subrc EQ 2.
              err_element-fname = t042e-zforn.
              err_element-fenst = 'MAIN'.
              err_element-elemt = '520'.
              err_element-text  = text_520.
              COLLECT err_element.
            ENDIF.

***********Start of PDF conversion ,Date: 21/03/2005 ,C5056173
          ENDIF.
************End  of PDF conversion ,Date: 21/03/2005 ,C5056173

        ELSE.

          PERFORM hr_formular_lesen.

        ENDIF.

*       Prüfung, ob Avishinweis erforderlich
*       check if advice note is necessary
        cnt_zeilen = 0.
        IF t042e-xavis NE space AND t042e-anzpo NE 99.
          IF hlp_xhrfo EQ space.
            IF flg_sgtxt = 1.
              cnt_zeilen = reguh-rpost + reguh-rtext.
            ELSE.
              cnt_zeilen = reguh-rpost.
            ENDIF.
          ELSE.
            DESCRIBE TABLE pform LINES cnt_zeilen.
          ENDIF.
          IF cnt_zeilen GT t042e-anzpo.
            IF hlp_xhrfo EQ space.
***********Start of PDF conversion ,Date: 21/03/2005 ,C5056173
              IF NOT gv_script IS INITIAL.
************End  of PDF conversion ,Date: 21/03/2005 ,C5056173

                CALL FUNCTION 'WRITE_FORM'
                  EXPORTING
                    element  = '526'
                    function = 'APPEND'
                  EXCEPTIONS
                    window   = 1
                    element  = 2.
                IF sy-subrc EQ 2.
                  err_element-fname = t042e-zforn.
                  err_element-fenst = 'MAIN'.
                  err_element-elemt = '526'.
                  err_element-text  = text_526.
                  COLLECT err_element.
                ENDIF.
***********Start of PDF conversion ,Date: 21/03/2005 ,C5056173
              ENDIF.
************End  of PDF conversion ,Date: 21/03/2005 ,C5056173

            ENDIF.
            ADD 1 TO cnt_hinweise.
          ENDIF.
        ENDIF.

*       HR-Formular ausgeben
*       write HR form
        IF hlp_xhrfo NE space.
          LOOP AT pform.
            IF cnt_zeilen GT t042e-anzpo AND sy-tabix GT t042e-anzpo.
              EXIT.
            ENDIF.
            regud-txthr = pform-linda.
            PERFORM scheckavis_zeile.
          ENDLOOP.
        ENDIF.
        flg_diff_bukrs = 0.

      ENDIF.

    ENDAT.

*-- Neuer Rechnungsbuchungskreis ---------------------------------------
*-- New invoice company code -------------------------------------------
    AT NEW regup-bukrs.

      IF cnt_zeilen LE t042e-anzpo AND hlp_xhrfo EQ space.
        IF ( regup-bukrs NE reguh-zbukr OR flg_diff_bukrs EQ 1 ) AND
           ( reguh-absbu EQ space OR reguh-absbu EQ reguh-zbukr ).
          flg_diff_bukrs = 1.
          SELECT SINGLE * FROM t001 INTO *t001
            WHERE bukrs EQ regup-bukrs.
          regud-abstx = *t001-butxt.
          regud-absor = *t001-ort01.

***********Start of PDF conversion ,Date: 21/03/2005 ,C5056173
          IF NOT gv_script IS INITIAL.
************End  of PDF conversion ,Date: 21/03/2005 ,C5056173
            CALL FUNCTION 'WRITE_FORM'
              EXPORTING
                element = '513'
              EXCEPTIONS
                window  = 1
                element = 2.
            IF sy-subrc EQ 2.
              err_element-fname = t042e-zforn.
              err_element-fenst = 'MAIN'.
              err_element-elemt = '513'.
              err_element-text  = text_513.
              COLLECT err_element.
            ENDIF.
***********Start of PDF conversion ,Date: 21/03/2005 ,C5056173
          ENDIF.
************End  of PDF conversion ,Date: 21/03/2005 ,C5056173

        ENDIF.
      ENDIF.

    ENDAT.


*-- Verarbeitung der Einzelposten-Informationen ------------------------
*-- single item information --------------------------------------------
    AT daten.

      IF flg_kein_druck EQ 0.

        PERFORM einzelpostenfelder_fuellen.

*       Ausgabe der Einzelposten, falls kein Avishinweis erforderl. war
*       single item information if no advice note
        IF cnt_zeilen LE t042e-anzpo AND hlp_xhrfo EQ space.
          regud-txthr = regup-sgtxt.
          PERFORM scheckavis_zeile.
        ENDIF.

        PERFORM summenfelder_fuellen.

        IF cnt_zeilen LE t042e-anzpo AND hlp_xhrfo EQ space.

***********Start of PDF conversion ,Date: 21/03/2005 ,C5056173
          IF NOT gv_script IS INITIAL.
************End  of PDF conversion ,Date: 21/03/2005 ,C5056173
            CALL FUNCTION 'WRITE_FORM'
              EXPORTING
                element  = '525-TX'
                function = 'APPEND'
              EXCEPTIONS
                window   = 1
                element  = 2.
***********Start of PDF conversion ,Date: 21/03/2005 ,C5056173
          ENDIF.
************End  of PDF conversion ,Date: 21/03/2005 ,C5056173

        ENDIF.
      ENDIF.


*     Angabentabelle für die OeNB-Meldung (Österreich)
      IF t042e-xausl = 'X'.            "nur Auslandsscheck
        CLEAR up_oenb_angaben.
        up_oenb_angaben-diekz = regup-diekz.
        up_oenb_angaben-lzbkz = regup-lzbkz.
        up_oenb_angaben-summe = regud-netto.
        COLLECT up_oenb_angaben.
      ENDIF.

    ENDAT.


*-- Ende der Zahlungsbelegnummer ---------------------------------------
*-- end of payment document number -------------------------------------
    AT END OF reguh-vblnr.

      IF flg_kein_druck EQ 0.

*       Zahlbetrag ohne Aufbereitungszeichen für Codierzeile speichern
*       store numerical payment amount for code line
        IF reguh-waers EQ t001-waers.
          regud-socra = regud-swnes.
        ELSE.
          regud-socra = 0.
          PERFORM laender_lesen USING t001-land1.
          IF t005-intca EQ 'DE'.
            PERFORM isocode_umsetzen USING reguh-waers hlp_waers.
            IF hlp_waers EQ 'DEM' OR hlp_waers EQ 'EUR'.
              regud-socra = regud-swnes.
            ENDIF.
          ENDIF.
          IF t005-intca EQ 'AT'.
            PERFORM isocode_umsetzen USING reguh-waers hlp_waers.
            IF hlp_waers EQ 'ATS' OR hlp_waers EQ 'EUR'.
              regud-socra = regud-swnes.
            ENDIF.
          ENDIF.
        ENDIF.
        IF reguh-waers EQ t012k-waers.
          regud-socrb = regud-swnes.
        ELSE.
          regud-socrb = 0.
        ENDIF.

        PERFORM ziffern_in_worten.

*       Summenfelder hochzählen und aufbereiten
*       add up total amount fields
        ADD 1            TO cnt_formulare.
        ADD reguh-rbetr  TO sum_abschluss.
        WRITE:
          cnt_hinweise   TO regud-avish,
          cnt_formulare  TO regud-zahlt,
          sum_abschluss  TO regud-summe CURRENCY t001-waers.
        TRANSLATE:
          regud-avish USING ' *',
          regud-zahlt USING ' *',
          regud-summe USING ' *'.

        IF hlp_xhrfo EQ space.

* Nur für Brasilien (Check auf Land liegt in Funktionsbaustein)
* Only Brazil (Check on country within the function module)

          CALL FUNCTION 'BOLETO_DATA'
            EXPORTING
              line_reguh = reguh
            TABLES
              itab_regup = tab_regup
            CHANGING
              line_regud = regud.

          CALL FUNCTION 'KOREA_DATA'
            EXPORTING
              line_reguh = reguh
            TABLES
              itab_regup = tab_regup
            CHANGING
              line_regud = regud.


***********Start of PDF conversion ,Date: 21/03/2005 ,C5056173
          IF NOT gv_script IS INITIAL.
************End  of PDF conversion ,Date: 21/03/2005 ,C5056173

*         Hauptfenster, Element Gesamtsumme (nur auf der letzten Seite)
*         main window, element total (only last page)
            CALL FUNCTION 'WRITE_FORM'
              EXPORTING
                element  = '530'
                function = 'APPEND'
              EXCEPTIONS
                window   = 1
                element  = 2.
            IF sy-subrc EQ 2.
              err_element-fname = t042e-zforn.
              err_element-fenst = 'MAIN'.
              err_element-elemt = '530'.
              err_element-text  = text_530.
              COLLECT err_element.
            ENDIF.



*         Vornumerierte Schecks: Schecknummer hochzählen ab 2.Seite
*         prenumbered checks: add 1 to check number
            IF flg_schecknum EQ 1.
              CALL FUNCTION 'GET_TEXTSYMBOL'
                EXPORTING
                  line         = '&PAGE&'
                  start_offset = 0
                IMPORTING
                  value        = hlp_page.

            ENDIF.

            IF hlp_page NE hlp_seite.
              hlp_seite = hlp_page.
              PERFORM schecknummer_addieren.
            ENDIF.

***********Start of PDF conversion ,Date: 21/03/2005 ,C5056173
          ELSE.
            hlp_page = gv_pageno.
            hlp_seite = gv_pageno.    " hlp_page.
            PERFORM schecknummer_addieren.
          ENDIF.
************End  of PDF conversion ,Date: 21/03/2005 ,C5056173


***********Start of PDF conversion ,Date: 21/03/2005 ,C5056173
          IF NOT gv_script IS INITIAL.
************End  of PDF conversion ,Date: 21/03/2005 ,C5056173

*         Alternativ: Fenster Total, Element Gesamtsumme
*         alternatively: window total, element total
            CALL FUNCTION 'WRITE_FORM'
              EXPORTING
                window  = 'TOTAL'
                element = '530'
              EXCEPTIONS
                window  = 1
                element = 2.
            IF sy-subrc EQ 2 AND
              (  err_element-fname NE t042e-zforn
              OR err_element-fenst NE 'MAIN'
              OR err_element-elemt NE '530' ).
              err_element-fname = t042e-zforn.
              err_element-fenst = 'TOTAL'.
              err_element-elemt = '530'.
              err_element-text  = text_530.
              COLLECT err_element.
            ENDIF.

*         Fenster Carry Forward, Element Übertrag löschen
*         window carryfwd, delete element carry forward below
            CALL FUNCTION 'WRITE_FORM'
              EXPORTING
                window   = 'CARRYFWD'
                element  = '535'
                function = 'DELETE'
              EXCEPTIONS
                window   = 1       "Fehler bereits oben gemerkt
                element  = 2.      "error already noted

*         Hauptfenster, Element Überschrift löschen
*         main window, delete element title
            CALL FUNCTION 'WRITE_FORM'
              EXPORTING
                element  = '515'
                type     = 'TOP'
                function = 'DELETE'
              EXCEPTIONS
                window   = 1       "Fehler bereits oben gemerkt
                element  = 2.      "error already noted

*         Hauptfenster, Element Übertrag löschen
*         main window, delete element carry forward above
            CALL FUNCTION 'WRITE_FORM'
              EXPORTING
                element  = '520'
                type     = 'TOP'
                function = 'DELETE'
              EXCEPTIONS
                window   = 1       "Fehler bereits oben gemerkt
                element  = 2.      "error already noted

***********Start of PDF conversion ,Date: 21/03/2005 ,C5056173
          ENDIF.
************End  of PDF conversion ,Date: 21/03/2005 ,C5056173
        ENDIF.

***********Start of PDF conversion ,Date: 21/03/2005 ,C5056173
        IF NOT gv_script IS INITIAL.
************End  of PDF conversion ,Date: 21/03/2005 ,C5056173

*       Fenster Check, Element Entwerteter Scheck löschen
*       window check, delete element voided check
          IF reguh-rwbtr NE 0.           "zero net check has to be voided
            CALL FUNCTION 'WRITE_FORM'
              EXPORTING
                window   = 'CHECK'
                element  = '540'
                function = 'DELETE'
              EXCEPTIONS
                window   = 1       "Fehler bereits oben gemerkt
                element  = 2.      "error already noted

*         Fenster Check, Element Echter Scheck (nur auf letzte Seite)
*         window check, element genuine check (only last page)
            IF t042z-xeinz EQ space.
              CALL FUNCTION 'WRITE_FORM'
                EXPORTING
                  window  = 'CHECKSPL'
                  element = '545'
                EXCEPTIONS
                  window  = 1
                  element = 2.
              CALL FUNCTION 'WRITE_FORM'
                EXPORTING
                  window  = 'CHECK'
                  element = '545'
                EXCEPTIONS
                  window  = 1
                  element = 2.
              IF sy-subrc EQ 2.
                err_element-fname = t042e-zforn.
                err_element-fenst = 'CHECK'.
                err_element-elemt = '545'.
                err_element-text  = text_545.
                COLLECT err_element.
              ENDIF.
            ELSE.                        "debitorische Wechsel Frankreich
              CALL FUNCTION 'WRITE_FORM' "bills of exchange to debitors
                EXPORTING             "(France)
                  window  = 'CHECKSPL'
                  element = '546'
                EXCEPTIONS
                  window  = 1
                  element = 2.
              CALL FUNCTION 'WRITE_FORM'
                EXPORTING
                  window  = 'CHECK'
                  element = '546'
                EXCEPTIONS
                  window  = 1
                  element = 2.
              IF sy-subrc EQ 2.
                err_element-fname = t042e-zforn.
                err_element-fenst = 'CHECK'.
                err_element-elemt = '546'.
                err_element-text  = text_546.
                COLLECT err_element.
              ENDIF.
            ENDIF.
          ENDIF.

***********Start of PDF conversion ,Date: 21/03/2005 ,C5056173
        ENDIF.
************End  of PDF conversion ,Date: 21/03/2005 ,C5056173


*       Angabenteil für die OeNB-Meldung (Österreich)
*       Austria only
        IF t042e-xausl NE space        "Auslandsscheck, nicht Pfändung
        AND NOT ( hrxblnr-txtsl EQ 'HR' AND hrxblnr-txerg EQ 'GRN' ).
          CLEAR:
            regud-x08, regud-x10, regud-x11, regud-x12, regud-x13,
            regud-text1, regud-zwck1, regud-zwck2.
          IF up_oenb_kontowae-uwaer EQ 'ATS'.
            regud-x08   = 'X'.
          ELSE.
            regud-text1 = up_oenb_kontowae-uwaer.
          ENDIF.
          SORT up_oenb_angaben BY summe DESCENDING.
          READ TABLE up_oenb_angaben INDEX 1.
          CASE up_oenb_angaben-diekz.
            WHEN space.
              regud-x10 = 'X'.
            WHEN 'I'.
              regud-x10 = 'X'.
            WHEN 'R'.
              regud-x11 = 'X'.
            WHEN 'K'.
              regud-x12 = 'X'.
            WHEN OTHERS.
              regud-x13 = 'X'.
              PERFORM read_scb_indicator USING up_oenb_angaben-lzbkz.
              regud-zwck1 = t015l-zwck1.
              regud-zwck2 = t015l-zwck2.
          ENDCASE.

***********Start of PDF conversion ,Date: 21/03/2005 ,C5056173
          IF NOT gv_script IS INITIAL.
************End  of PDF conversion ,Date: 21/03/2005 ,C5056173

            CALL FUNCTION 'WRITE_FORM'
              EXPORTING
                window  = 'ORDERS'
                element = '550'
              EXCEPTIONS
                window  = 1
                element = 2.
          ENDIF.

***********Start of PDF conversion ,Date: 21/03/2005 ,C5056173
        ENDIF.
************End  of PDF conversion ,Date: 21/03/2005 ,C5056173


***********Start of PDF conversion ,Date: 21/03/2005 ,C5056173
        IF NOT gv_script IS INITIAL.
************End  of PDF conversion ,Date: 21/03/2005 ,C5056173
*       Formular beenden
*       End check form
          CALL FUNCTION 'END_FORM'
            IMPORTING
              result = itcpp.
          IF itcpp-tdpages EQ 0.         "Print via RDI
            itcpp-tdpages = 1.
          ENDIF.


***********Start of PDF conversion ,Date: 21/03/2005 ,C5056173
        ELSE.
          IF flg_probedruck NE 0.
            PERFORM seunum_pdf CHANGING seunum.

            PERFORM valor_pdf CHANGING esp quan val .

            MOVE: reguh-vblnr         TO gs_data-vblnr,
                  reguh-ubnkl         TO gs_data-ubnkl,
                  reguh-laufd         TO gs_data-laufd,
                  t001-butxt          TO gs_data-t001_butxt,
                  t001-ort01          TO gs_data-t001_ort01,
                  regud-ausft         TO gs_data-ausft,
                  regud-text3(3)      TO gs_data-text3,
                  seunum              TO gs_data-hlp_seunum,
                  regud-text9(10)     TO gs_data-text9,
                  quan                TO gs_data-hlp_quan,
                  val                 TO gs_data-hlp_val,
                  esp                 TO gs_data-hlp_esp,
                  esp                 TO gs_data-esp,
                  regud-text5(10)     TO gs_data-text5,
                  regud-text6(30)     TO gs_data-text6,
                  regud-text6+40(30)  TO gs_data-text6_40 ,
                  regud-text6+80(30)  TO gs_data-text6_80,
                  regud-text7(60)     TO gs_data-text7,
                  reguh-zpstl         TO gs_data-zpstl,
                  reguh-zort1         TO gs_data-zort1,
                  reguh-zstra         TO gs_data-zstra,
                  reguh-znme1         TO gs_data-znme1,
                  regud-text3+40(18)  TO gs_data-inscr_text3.


            IF NOT t001-ort01 IS INITIAL.
              CONCATENATE gs_data-t001_butxt gc_comma
                          INTO gs_data-t001_butxt
                          SEPARATED BY ' '.
            ENDIF.

            CONCATENATE reguh-ubnkl(3) reguh-ubnkl+3(1)
                        INTO gs_data-ubnkl
                        SEPARATED BY gc_hyphen .

            CONCATENATE reguh-ubnkl+4(4) reguh-ubkon "note 1297249
                        INTO gs_data-ubknt
                        SEPARATED BY gc_hyphen .
            CONCATENATE gs_data-ubknt  gc_hyphen
                        INTO gs_data-ubknt
                        SEPARATED BY ' '.
            CONCATENATE gs_data-ubknt reguh-ubknt
                        INTO gs_data-ubknt.


            CONCATENATE regud-text3(3) regud-chect regud-text4(1)
                        INTO gs_data-text4
                        SEPARATED BY gc_hyphen .

            IF regud-text3+10(1) = ' '.

              CONCATENATE reguh-stcd1(2) reguh-stcd1+2(3)
                          reguh-stcd1+5(3) reguh-stcd1+8(4)
                          INTO gs_data-cpf_text3
                          SEPARATED BY gc_dot .
              CONCATENATE gs_data-cpf_text3 reguh-stcd1+12(2)
                          INTO gs_data-cpf_text3
                          SEPARATED BY gc_hyphen .
              CONCATENATE 'CNPJ/CPF ' gs_data-cpf_text3
                          INTO gs_data-cpf_text3
                          SEPARATED BY ' ' .
              gs_data-cpf_text3+30(18) = company_cnpj.


            ELSE.
              CONCATENATE regud-text3+20(3) regud-text3+23(3)
                          regud-text3+26(3)
                          INTO gs_data-cpf_text3
                          SEPARATED BY gc_dot.
              CONCATENATE gs_data-cpf_text3 regud-text3+29(2)
                          INTO gs_data-cpf_text3
                          SEPARATED BY gc_hyphen .
              CONCATENATE 'CPF: ' gs_data-cpf_text3
                          INTO gs_data-cpf_text3
                          SEPARATED BY ' ' .
            ENDIF.

            MOVE TEXT-921 TO gs_data-chk_type.
            APPEND gs_data TO gt_data.

            MOVE TEXT-922 TO gs_data-chk_type.
            APPEND gs_data TO gt_data.

            CLEAR: gs_data-chk_type.
            MOVE: gs_data-text4 TO gs_data-chec_no,
                  TEXT-920 TO gs_data-text10.
            APPEND gs_data TO gt_data.


*     Dispaly PDF output
            PERFORM output_pdf .

            CLEAR: gs_data.
            REFRESH: gt_data.

            gv_pageno = gv_pageno + 1.
          ENDIF.

        ENDIF.
************End  of PDF conversion ,Date: 21/03/2005 ,C5056173



        IF flg_schecknum EQ 1.
          cnt_seiten = itcpp-tdpages.  "Für vornumerierte Schecks
        ELSE.                          "For prenumbered checks
          cnt_seiten = 1.
        ENDIF.
        IF flg_schecknum NE 0 AND cnt_seiten GT 0.
          PERFORM scheckinfo_speichern USING 2.
        ENDIF.
***********Start of PDF conversion ,Date: 21/03/2005 ,C5056173
*            gv_pageno = gv_pageno + 1.
************End  of PDF conversion ,Date: 21/03/2005 ,C5056173
      ENDIF.

    ENDAT.


*-- Ende der Hausbank --------------------------------------------------
*-- end of house bank --------------------------------------------------
    AT END OF reguh-ubnkl.

      IF cnt_formulare NE 0.           "Formularabschluß erforderlich
        "summary necessary

***********Start of PDF conversion ,Date: 21/03/2005 ,C5056173
        IF NOT gv_script IS INITIAL.
************End  of PDF conversion ,Date: 21/03/2005 ,C5056173

*       close last check
          CALL FUNCTION 'CLOSE_FORM'
            IMPORTING
              result = itcpp.

          IF itcpp-tdspoolid NE 0.
            CLEAR tab_ausgabe.
            tab_ausgabe-name    = t042z-text1.
            tab_ausgabe-dataset = itcpp-tddataset.
            tab_ausgabe-spoolnr = itcpp-tdspoolid.
            tab_ausgabe-immed   = par_sofz.
            COLLECT tab_ausgabe.
          ENDIF.

***********Start of PDF conversion ,Date: 21/03/2005 ,C5056173
        ENDIF.
************End  of PDF conversion ,Date: 21/03/2005 ,C5056173

        CLEAR flg_druckmodus.

        IF hlp_laufk NE '*'            "kein Onlinedruck
                                       "no online check print
          AND par_nosu EQ space.       "Formularabschluß gewünscht
          "summary requested

***********Start of PDF conversion ,Date: 21/03/2005 ,C5056173
          IF NOT gv_script IS INITIAL.
************End  of PDF conversion ,Date: 21/03/2005 ,C5056173

*         Formular für den Abschluß starten
*         start form for summary
            SET COUNTRY space.
            IMPORT itcpo FROM MEMORY ID 'RFFORI01_ITCPO'.
            itcpo-tdnewid = space.


            CALL FUNCTION 'OPEN_FORM'
              EXPORTING
                form     = t042e-zforn
                device   = 'PRINTER'
                language = t001-spras
                options  = itcpo
                dialog   = space.
            CALL FUNCTION 'START_FORM'
              EXPORTING
                startpage = 'LAST'
                language  = t001-spras.

***********Start of PDF conversion ,Date: 21/03/2005 ,C5056173
          ENDIF.
************End  of PDF conversion ,Date: 21/03/2005 ,C5056173

*         Vornumerierte Schecks: letzte Schecknummer ermitteln
*         prenumbered checks: compute last check number
          IF flg_schecknum EQ 1.
            PERFORM schecknummer_ermitteln USING 3.
          ENDIF.

***********Start of PDF conversion ,Date: 21/03/2005 ,C5056173
          IF NOT gv_script IS INITIAL.
************End  of PDF conversion ,Date: 21/03/2005 ,C5056173

*         Ausgabe des Formularabschlusses
*         print summary
            CALL FUNCTION 'WRITE_FORM'
              EXPORTING
                window = 'SUMMARY'
              EXCEPTIONS
                window = 1.
            IF sy-subrc EQ 1.
              err_element-fname = t042e-zforn.
              err_element-fenst = 'SUMMARY'.
              err_element-elemt = space.
              err_element-text  = space.
              COLLECT err_element.
            ENDIF.

*         Fenster Scheck, Element Entwertet
*         window check, element voided check

            CALL FUNCTION 'WRITE_FORM'
              EXPORTING
                window  = 'CHECK'
                element = '540'
              EXCEPTIONS
                window  = 1        "Fehler bereits oben gemerkt
                element = 2.       "error already noted

*         Formular für den Abschluß beenden
*         end form for summary
            CALL FUNCTION 'END_FORM'
              IMPORTING
                result = itcpp.
            IF itcpp-tdpages EQ 0.       "Print via RDI
              itcpp-tdpages = 1.
            ENDIF.

***********Start of PDF conversion ,Date: 21/03/2005 ,C5056173
          ENDIF.
************End  of PDF conversion ,Date: 21/03/2005 ,C5056173

          cnt_seiten = itcpp-tdpages.  "Für vornumerierte Schecks
          "For prenumbered checks
          IF flg_schecknum EQ 1 AND cnt_seiten GT 0.
            PERFORM scheckinfo_speichern USING 3.
          ENDIF.

***********Start of PDF conversion ,Date: 21/03/2005 ,C5056173
          IF NOT gv_script IS INITIAL.
************End  of PDF conversion ,Date: 21/03/2005 ,C5056173

*         Abschluß des Formulars
*         close form
            CALL FUNCTION 'CLOSE_FORM'
              IMPORTING
                result = itcpp.

            IF itcpp-tdspoolid NE 0.
              CLEAR tab_ausgabe.
              tab_ausgabe-name    = t042z-text1.
              tab_ausgabe-dataset = itcpp-tddataset.
              tab_ausgabe-spoolnr = itcpp-tdspoolid.
              tab_ausgabe-immed   = par_sofz.
              COLLECT tab_ausgabe.
            ENDIF.

***********Start of PDF conversion ,Date: 21/03/2005 ,C5056173
          ELSE.

* This suroutine is used to increment the check number

            hlp_page = gv_pageno.
            hlp_seite = gv_pageno.    " hlp_page.
            PERFORM schecknummer_addieren.


            PERFORM seunum_pdf CHANGING seunum.

            PERFORM valor_pdf CHANGING esp quan val .

            MOVE: reguh-vblnr         TO gs_data-vblnr,
                  reguh-ubnkl         TO gs_data-ubnkl,
                  reguh-laufd         TO gs_data-laufd,
                  t001-butxt          TO gs_data-t001_butxt,
                  t001-ort01          TO gs_data-t001_ort01,
                  regud-ausft         TO gs_data-ausft,
                  regud-text3(3)      TO gs_data-text3,
                  seunum              TO gs_data-hlp_seunum,
                  regud-text9(10)     TO gs_data-text9,
                  quan                TO gs_data-hlp_quan,
                  val                 TO gs_data-hlp_val,
                  esp                 TO gs_data-hlp_esp,
                  esp                 TO gs_data-esp,
                  regud-text5(10)     TO gs_data-text5,
                  regud-text6(30)     TO gs_data-text6,
                  regud-text6+40(30)  TO gs_data-text6_40 ,
                  regud-text6+80(30)  TO gs_data-text6_80,
                  regud-text7(60)     TO gs_data-text7,
                  reguh-zpstl         TO gs_data-zpstl,
                  reguh-zort1         TO gs_data-zort1,
                  reguh-zstra         TO gs_data-zstra,
                  reguh-znme1         TO gs_data-znme1,
                  regud-text3+40(18)  TO gs_data-inscr_text3.


            MOVE regud-text8+50(44)  TO gs_total-text8.


            IF NOT t001-ort01 IS INITIAL.
              CONCATENATE gs_data-t001_butxt gc_comma
                          INTO gs_data-t001_butxt
                          SEPARATED BY ' '.
            ENDIF.

            CONCATENATE reguh-ubnkl(3) reguh-ubnkl+3(1)
                        INTO gs_data-ubnkl
                        SEPARATED BY gc_hyphen.

            CONCATENATE reguh-ubnkl+4(4) reguh-ubkon "note 1297249
                        INTO gs_data-ubknt
                        SEPARATED BY gc_hyphen .
            CONCATENATE gs_data-ubknt  gc_hyphen
                        INTO gs_data-ubknt
                        SEPARATED BY ' '.
            CONCATENATE gs_data-ubknt reguh-ubknt
                        INTO gs_data-ubknt.

            CONCATENATE regud-text3(3) regud-chect regud-text4(1)
                        INTO gs_data-text4
                        SEPARATED BY gc_hyphen.

            IF regud-text3+10(1) = ' '.

              CONCATENATE reguh-stcd1(2) reguh-stcd1+2(3)
                          reguh-stcd1+5(3) reguh-stcd1+8(4)
                          INTO gs_data-cpf_text3
                          SEPARATED BY gc_dot .
              CONCATENATE gs_data-cpf_text3 reguh-stcd1+12(2)
                          INTO gs_data-cpf_text3
                          SEPARATED BY gc_hyphen .
              CONCATENATE 'CGC: ' gs_data-cpf_text3
                          INTO gs_data-cpf_text3
                          SEPARATED BY ' ' .


            ELSE.
              CONCATENATE regud-text3+20(3) regud-text3+23(3)
                          regud-text3+26(3)
                          INTO gs_data-cpf_text3
                          SEPARATED BY gc_dot.
              CONCATENATE gs_data-cpf_text3 regud-text3+29(2)
                          INTO gs_data-cpf_text3
                          SEPARATED BY gc_hyphen .
              CONCATENATE 'CPF: ' gs_data-cpf_text3
                          INTO gs_data-cpf_text3
                          SEPARATED BY ' ' .
            ENDIF.

            MOVE: TEXT-921 TO gs_data-chk_type.
            APPEND gs_data TO gt_data.

            MOVE: TEXT-922 TO gs_data-chk_type.
            APPEND gs_data TO gt_data.

            CLEAR: gs_data-chk_type.
            MOVE: gs_data-text4 TO gs_data-chec_no,
                  TEXT-920 TO gs_data-text10.
            APPEND gs_data TO gt_data.

*     Dispaly PDF output
            PERFORM output_pdf .

            CLEAR: gs_data.
            REFRESH: gt_data.

          ENDIF.
************End  of PDF conversion ,Date: 21/03/2005 ,C5056173

        ENDIF.

***********Start of PDF conversion ,Date: 21/03/2005 ,C5056173
        IF NOT gv_script IS INITIAL.
************End  of PDF conversion ,Date: 21/03/2005 ,C5056173

          IF NOT itcpp-tdspoolid IS INITIAL.
            CALL FUNCTION 'RSPO_FINAL_SPOOLJOB'
              EXPORTING
                rqident = itcpp-tdspoolid
                set     = 'X'
                force   = 'X'
              EXCEPTIONS
                OTHERS  = 4.
            IF sy-subrc NE 0.
              MOVE-CORRESPONDING syst TO fimsg.
              PERFORM message USING fimsg-msgno.
            ENDIF.
          ENDIF.

***********Start of PDF conversion ,Date: 21/03/2005 ,C5056173
        ENDIF.
************End  of PDF conversion ,Date: 21/03/2005 ,C5056173

      ENDIF.

    ENDAT.

  ENDLOOP.

***********Start of PDF conversion ,Date: 21/03/2005 ,C5056173
  IF gv_script IS INITIAL.

* Close PDF form
    PERFORM close_form_pdf.

  ENDIF.
************End  of PDF conversion ,Date: 21/03/2005 ,C5056173

  hlp_ep_element = '525'.

ENDFORM.                               "Scheck_pdf



*&---------------------------------------------------------------------*
*&      Form  fill_outputparams_pdf
*&---------------------------------------------------------------------*
*       Fill Print parameters
*----------------------------------------------------------------------*
*      <--XS_FP_OUTPUTPARAMS  text
*----------------------------------------------------------------------*
FORM fill_outputparams_pdf
                          CHANGING xs_outputparams TYPE sfpoutputparams.



  xs_outputparams-device     = itcpo-tdprinter.
  xs_outputparams-nodialog   = 'X'.
  xs_outputparams-preview    = itcpo-tdpreview.
  xs_outputparams-dest       = itcpo-tddest.
  xs_outputparams-reqnew     = itcpo-tdnewid.
  xs_outputparams-reqimm     = itcpo-tdimmed.
  xs_outputparams-reqdel     = itcpo-tddelete.
  xs_outputparams-copies     = itcpo-tdcopies.
  xs_outputparams-lifetime   = itcpo-tdlifetime.
  xs_outputparams-title      = itcpo-tdtitle.
  xs_outputparams-nopreview  = itcpo-tdnoprev.
  xs_outputparams-noprint    = itcpo-tdnoprint.
  xs_outputparams-suffix1    = itcpo-tdsuffix1 .
  xs_outputparams-suffix2    = itcpo-tdsuffix2.
  xs_outputparams-covtitle   = itcpo-tdcovtitle.
  xs_outputparams-authority  = itcpo-tdautority.
  xs_outputparams-receiver   = itcpo-tdreceiver.
  xs_outputparams-division   = itcpo-tddivision.
  xs_outputparams-reqimm     = itcpo-tdimmed .
  xs_outputparams-cover      = itcpo-tdcover.



ENDFORM.                    " fill_outputparams_pdf


************End  of PDF conversion ,Date: 19/03/2005 ,C5056173
*&---------------------------------------------------------------------*
*&      Form  FILL_NOTAFISCAl
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM fill_notafiscal CHANGING par_xblnr.

  DATA: hlp_len TYPE n.

  val_xblnr = regup-xblnr.
  PERFORM convert_xblnr.

  CALL FUNCTION 'STRING_LENGTH'
    EXPORTING
      string = l_xblnr1
    IMPORTING
      length = hlp_len.


  CASE reguh-ubnkl(3).
    WHEN '341'.                               "Itau
      IF hlp_len GE 8.
        SHIFT regup-xblnr BY 1 PLACES.
        par_xblnr(8)    = regup-xblnr(8).       "Nota Fiscal Nr
        SHIFT regup-buzei BY 1 PLACES.
        par_xblnr+8(2)  = regup-buzei.          "Duplicata number
        CONCATENATE par_xblnr(8) par_xblnr+8(2) INTO par_xblnr.
      ELSE.
        par_xblnr(6)    = regup-xblnr(6).
        par_xblnr+6(3)  = regup-buzei.
        CONCATENATE par_xblnr(6) par_xblnr+6(3) INTO par_xblnr.
      ENDIF.

    WHEN '237'.                               "bradesco
      IF hlp_len GE 8.
        SHIFT regup-xblnr BY 1 PLACES.
        par_xblnr(8)  = regup-xblnr(8).        "Nota Fiscal Nr
        SHIFT regup-buzei BY 1 PLACES.
        par_xblnr+8(2)  = regup-buzei.         "Duplicata number
        CONCATENATE par_xblnr(8) par_xblnr+8(2) INTO par_xblnr.
      ELSE.
        par_xblnr(6)    = regup-xblnr(6).
        par_xblnr+6(3)  = regup-buzei.
        CONCATENATE par_xblnr(6) par_xblnr+6(3) INTO par_xblnr.
      ENDIF.

    WHEN OTHERS.
      IF hlp_len GE 8.                         "FEBRABAN
        par_xblnr(9)    = regup-xblnr(9).        "Nota Fiscal Nr
*      Write par_xblnr(9) RIGHT-JUSTIFIED To par_xblnr(9).         "Note 1271711 Starts
*      UNPACK par_xblnr(9) TO par_xblnr(9).

        DATA: len    TYPE n.
        len = strlen( par_xblnr(9) ).
        len = len - 9.

        DO len TIMES.
          REPLACE SECTION LENGTH 0 OF par_xblnr(9) WITH '0'.
        ENDDO.                                                      "Note 1271711 Ends

*     shift REGUP-BUZEI by 1 places.
        par_xblnr+9(3)  = regup-buzei.           "Duplicata number
        CONCATENATE par_xblnr(9) par_xblnr+9(3) INTO par_xblnr.
      ELSE.
        par_xblnr(6)    = regup-xblnr(6).
        par_xblnr+6(3)  = regup-buzei.
        CONCATENATE par_xblnr(6) par_xblnr+6(3) INTO par_xblnr.
      ENDIF.

  ENDCASE.
ENDFORM.                    " FILL_NOTAFISCAl
*&---------------------------------------------------------------------
*
*&      Form  convert_xblnr
*&---------------------------------------------------------------------
*
*       text
*----------------------------------------------------------------------
*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------
*
FORM convert_xblnr.

*     Initialize
  l_xblnr1 = space.
  l_xblnr2 = space.

  CHECK val_xblnr <> space.
  SPLIT val_xblnr AT '-' INTO l_xblnr1 l_xblnr2.

ENDFORM.                    " convert_xblnr
*&---------------------------------------------------------------------*
*&      Form  CR_LF
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM cr_lf .

  IF par_crlf EQ 1.
    PERFORM store_on_file USING dta_cr.
  ENDIF.
  IF par_crlf EQ 2.
    PERFORM store_on_file USING dta_lf.
  ENDIF.
  IF par_crlf EQ 3.
    PERFORM store_on_file USING dta_crlf.
  ENDIF.

ENDFORM.                    " CR_LF
*&---------------------------------------------------------------------*
*&      Form  F_MULTA_ATRASO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM f_multa_atraso CHANGING cv_a10 TYPE j_1bza10.

  DATA: lv_multa TYPE ztca_param_val-low.

  SELECT low
    FROM ztca_param_val
    UP TO 1 ROWS
    INTO lv_multa
    WHERE modulo = gc_modulo
      AND chave1 = gc_chave1
      AND chave2 = gc_chv_pc
      AND chave3 = gc_chv_mt.
  ENDSELECT.

  IF sy-subrc IS INITIAL
 AND lv_multa IS NOT INITIAL.

    TRANSLATE lv_multa USING '% '.
    TRANSLATE lv_multa USING ',.'.
    CONDENSE lv_multa NO-GAPS.

    cv_a10+1(4) = lv_multa * 100.

    IF cv_a10 IS NOT INITIAL.
      cv_a10(1) = 2.
    ENDIF.

  ELSE.

    cv_a10 = gc_a10_df.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form f_nosso_numero
*&---------------------------------------------------------------------*
FORM f_nosso_numero USING us_reguh     TYPE reguh
                          us_regup     TYPE regup
                 CHANGING cv_j_1bdmeza TYPE j_1bdmeza.

  DATA: lv_digito TYPE char1.
  DATA: lv_hlp_chect TYPE regud-chect.

  CLEAR cv_j_1bdmeza-a11.
* pferraz - Ajustes Nosso numero - 25.07.23 - inicio
**  cv_j_1bdmeza-a11(8)   = us_regup-belnr+2(8).
**  cv_j_1bdmeza-a11+8(1) = us_regup-buzei+2(1).
**  cv_j_1bdmeza-a11+9(2) = us_regup-gjahr+2(2).

  cv_j_1bdmeza-a11(11)   = us_regup-xref3(11).
* pferraz - Ajustes Nosso numero - 25.07.23 - Fim

  lv_hlp_chect = cv_j_1bdmeza-a11.

  CALL FUNCTION 'CALCULATE_CHECK_DIGIT_BOLETO'
    EXPORTING
      bankkey    = us_reguh-ubnkl
      conta_corr = us_reguh-ubknt
      carteira   = cv_j_1bdmeza-a07+1(3)
      nos_numero = lv_hlp_chect
      docdate    = us_regup-bldat
    IMPORTING
      nos_check  = lv_digito.

  IF lv_digito = 'P'.
    cv_j_1bdmeza-a11+11(1) = 0.
  ELSE.
    cv_j_1bdmeza-a11+11(1) = lv_digito.
  ENDIF.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form f_ocorrencia
*&---------------------------------------------------------------------*
FORM f_ocorrencia USING us_reguh TYPE reguh
               CHANGING cv_a15   TYPE j_1bya12.

  TYPES: BEGIN OF ty_reguh,
           dtws1 TYPE reguh-dtws1,
         END OF ty_reguh.

  DATA: lt_dtws1 TYPE STANDARD TABLE OF ty_reguh.

  SELECT dtws1
    FROM reguh
    INTO TABLE lt_dtws1
   WHERE laufd = us_reguh-laufd
     AND laufi = us_reguh-laufi
     AND zbukr = us_reguh-zbukr
* pferraz - Ajustes busca ocorrencia - 26.07.23 - inicio
*     AND xvorl = abap_true.
     AND xvorl = abap_false
     AND vblnr = us_reguh-vblnr.
* pferraz - Ajustes busca ocorrencia - 26.07.23 - fim

  IF sy-subrc IS INITIAL.

    DELETE lt_dtws1 WHERE dtws1 IS INITIAL.

    IF lt_dtws1[] IS NOT INITIAL.

      DATA(ls_dtws1) = lt_dtws1[ 1 ].

      cv_a15 = ls_dtws1-dtws1.

    ENDIF.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form F_MORADIA
*&---------------------------------------------------------------------*
FORM f_moradia USING us_reguh TYPE reguh
            CHANGING cv_a26   TYPE j_1bya23.

  DATA: lv_multa      TYPE ztca_param_val-low,
        lv_taxa_juros TYPE p LENGTH 12 DECIMALS 2,
        lv_interest   TYPE regud-dmbtr.

  CLEAR cv_a26.

  SELECT low
    FROM ztca_param_val
    UP TO 1 ROWS
    INTO lv_multa
    WHERE modulo = gc_modulo
      AND chave1 = gc_chave1
      AND chave2 = gc_chv_md
      AND chave3 = gc_chv_ac.
  ENDSELECT.

  IF sy-subrc IS INITIAL.

    TRANSLATE lv_multa USING '% '.
    TRANSLATE lv_multa USING ',.'.
    CONDENSE lv_multa NO-GAPS.
    lv_taxa_juros = lv_multa.
    lv_interest   = us_reguh-rwbtr * lv_taxa_juros.
    DIVIDE lv_interest BY 30.
    DIVIDE lv_interest BY 100.
    cv_a26        = lv_interest.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form f_valor_abatimento
*&---------------------------------------------------------------------*
FORM f_valor_abatimento USING uv_regup TYPE regup
                     CHANGING cv_a30   TYPE j_1bya27.

  TYPES: BEGIN OF ty_regup,
           laufd TYPE regup-laufd,
           laufi TYPE regup-laufi,
           xvorl TYPE regup-xvorl,
           vblnr TYPE regup-vblnr,
           belnr TYPE regup-belnr,
           rebzg TYPE regup-rebzg,
           rebzz TYPE regup-rebzz,
           wrbtr TYPE regup-wrbtr,
         END OF ty_regup,

         BEGIN OF ty_reguh,
           laufd TYPE reguh-laufd,
           laufi TYPE reguh-laufi,
           xvorl TYPE reguh-xvorl,
           vblnr TYPE reguh-vblnr,
           rwbtr TYPE reguh-rwbtr,
           rwskt TYPE reguh-rwskt,
         END OF ty_reguh.

  DATA: lt_regup1 TYPE STANDARD TABLE OF ty_regup,
        lt_regup2 TYPE STANDARD TABLE OF ty_regup,
        lt_reguh  TYPE STANDARD TABLE OF ty_reguh,
        lt_reguh2 TYPE STANDARD TABLE OF ty_reguh.

  DATA: lv_wrbtr TYPE regup-wrbtr,
        lv_rwbtr TYPE reguh-rwbtr,
        lv_rwskt TYPE reguh-rwskt.

  CLEAR cv_a30.

  SELECT laufd
         laufi
         xvorl
         vblnr
         belnr
         rebzg
         rebzz
         wrbtr
    FROM regup
    INTO TABLE lt_regup1
   WHERE laufd = uv_regup-laufd
     AND laufi = uv_regup-laufi
     AND vblnr = uv_regup-vblnr
     AND xvorl NE abap_true
     AND rebzg NE space.

  IF sy-subrc IS INITIAL.

    SORT lt_regup1 BY rebzg.
    DELETE ADJACENT DUPLICATES FROM lt_regup1 COMPARING rebzg.

    IF lt_regup1[] IS NOT INITIAL.

      SELECT laufd
         laufi
         xvorl
         vblnr
         belnr
         rebzg
         rebzz
         wrbtr
        FROM regup
        INTO TABLE lt_regup2
        FOR ALL ENTRIES IN lt_regup1
       WHERE laufd = lt_regup1-laufd
         AND laufi = lt_regup1-laufi
         AND xvorl NE abap_true
         AND belnr = lt_regup1-rebzg
         AND buzei = lt_regup1-rebzz.

      IF sy-subrc IS INITIAL.

        LOOP AT lt_regup2 ASSIGNING FIELD-SYMBOL(<fs_regup2>).

          lv_wrbtr = lv_wrbtr = <fs_regup2>-wrbtr.

        ENDLOOP.

        SELECT laufd
               laufi
               xvorl
               vblnr
               rwbtr
               rwskt
          FROM reguh
          INTO TABLE lt_reguh
           FOR ALL ENTRIES IN lt_regup2
         WHERE laufd = lt_regup2-laufd
           AND laufi = lt_regup2-laufi
           AND xvorl NE abap_true
           AND vblnr = lt_regup2-vblnr.

        IF sy-subrc IS INITIAL.

          LOOP AT lt_reguh ASSIGNING FIELD-SYMBOL(<fs_reguh>).
            lv_rwbtr = lv_rwbtr + <fs_reguh>-rwbtr.
          ENDLOOP.

        ENDIF.

        SELECT laufd
               laufi
               xvorl
               vblnr
               rwbtr
               rwskt
          FROM reguh
          INTO TABLE lt_reguh2
           FOR ALL ENTRIES IN lt_regup2
          WHERE laufd = lt_regup2-laufd
            AND laufi = lt_regup2-laufi
            AND xvorl NE abap_true.

        IF sy-subrc IS INITIAL.
          LOOP AT lt_reguh2 ASSIGNING FIELD-SYMBOL(<fs_reguh2>).
            lv_rwskt = lv_rwskt + <fs_reguh2>-rwskt.
          ENDLOOP.
        ENDIF.

        cv_a30 = lv_wrbtr - ( lv_rwbtr + lv_rwskt ).

      ENDIF.
    ENDIF.
  ENDIF.

ENDFORM.
