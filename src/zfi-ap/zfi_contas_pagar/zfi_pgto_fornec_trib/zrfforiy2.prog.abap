************************************************************************
* 3.0A
** WGYS11K127228 25051995 Verbesserungen für HR-Überweisungen
* Includebaustein RFFORIY2 zu den Formulardruckprogramm RFFOBR_U       *
* mit Unterprogrammen für den Datenträgeraustausch Brasilien           *
*                                                                      *
* Unterprogramm               gerufen von FORM  /  von REPORT
** --------------------------------------------------------------------
*
* DME_BRAZIL                                         RFFOBR_U          *
*                                                                      *
************************************************************************
TYPES:
  BEGIN OF ty_s_datum,
    begda TYPE datum,
    endda TYPE datum,
  END OF ty_s_datum.


CONSTANTS:
  lc_table_pa0006 TYPE tabname VALUE 'PA0006',
  lc_table_t549a  TYPE tabname VALUE 'T549A',
  lc_table_t549q  TYPE tabname VALUE 'T549Q',
  lc_func_rgdir   TYPE tabname VALUE 'CU_READ_RGDIR'.

DATA:
  cnt_lot        TYPE i,                  "Lot counter
  cnt_rec_perlot TYPE i,           "Record counter per lot
  cnt_rec_detail TYPE i,           "special counter of details
  partner_agency LIKE t012-bankl,
  agency         LIKE t012-bankl,
  total_perlot   TYPE p DECIMALS 2.  "Total per lot
DATA: val_xblnr LIKE regup-xblnr,
      par_xblnr TYPE c,
      l_xblnr1  TYPE char16,
      l_xblnr2  TYPE char16.

DATA:

  dta_cr(1)   TYPE c,  "Carriage Return
  dta_lf(1)   TYPE c,  "Line Feed
  dta_crlf(2) TYPE c.    "carriage return + line feed
"note 1378829
TYPES:
  BEGIN OF t_adrs,
    numbr(10)      TYPE c,
    street(60)     TYPE c,
    house_num1(10) TYPE c,
    house_num2(10) TYPE c,
    ort02(15)      TYPE c,
    state(2)       TYPE c,
  END OF t_adrs.
DATA: it_adrs TYPE t_adrs.
TABLES: adrc.
" note 1378829

INCLUDE: rfforib3.
*----------------------------------------------------------------------*
* FORM DME_BRAZIL                                                      *
*----------------------------------------------------------------------*
* Ausgabe der Datenträgeraustausch-Information in                      *
* Diskettenformat für Brasilien                                        *
* gerufen von END-OF-SELECTION (J_1BPPTR)                              *
*----------------------------------------------------------------------*
* keine USING-Parameter                                                *
*----------------------------------------------------------------------*
FORM dme_brazil.

  TABLES:
    bsec,
    t012a,
*   DME structures for Itau and Febraban
    j_1bdmexh1,                        "file header
    j_1bdmexh2,                        "lot header
    j_1bdmexa,                         "details, segment A
    j_1bdmexb,                         "details, segment B
    zsfi_j_1bdmex5, "Segment 5
    j_1bdmexj,                         "details, segment J
    j_1bdmexo,                         "details, segment O
    zsfi_segmento_o,                   "details, segment O
    j_1bdmexj52,                       "details, segment J52 ITAU
    j_1bdfebj52,                       "details, segment J52 FEBR
    j_1bdmext2,                        "lot trailer
    j_1bdmext1,                        "file trailer

*   DME Structures for Bradesco
    j_1bdmeah,                    "DME Brazil, Bradesco, file header
    j_1bdmeaa,                         "DME Brazil, Bradesco, details
    j_1bdmeat.                    "DME Brazil, Bradesco, file trailer

  DATA:
    dta_record(480) TYPE c,            "Teil des EP-Satzes bei DTA Disk.
    nlstr(18)       TYPE n.
*   UP_CRLF(2) TYPE X VALUE '0D0A'.    "carriage return + line feed
*    cr_lf(2)   type c value cl_abap_char_utilities=>cr_lf.

  DATA: obj_badi_rffobr_u TYPE REF TO fiapbr_rffobr_u.   "BAdI object
  DATA: ls_reguh       TYPE reguh,
        ls_regud       TYPE regud,
        ls_file_header TYPE j_1bdmexh1.

  GET BADI obj_badi_rffobr_u.

  CALL FUNCTION 'FI_DME_CHARACTERS'
    IMPORTING
      e_cr   = dta_cr
      e_lf   = dta_lf
      e_crlf = dta_crlf.

*----------------------------------------------------------------------*
* Vorbereitung zum Datenträgeraustausch                                *
* Preparations for DME                                                 *
*----------------------------------------------------------------------*

* Sortieren des Datenbestandes
* Data sort
  SORT BY
    reguh-zbukr                        "Zahlender Buchungskreis
    reguh-ubnks                        "Bankland unserer Bank
    reguh-ubnky                        "Bankkey zur Übersortierung
    reguh-ubnkl                        "Bankleitzahl unserer Bank
    reguh-ubknt                        "Kontonummer bei unserer Bank
    payment_form                       " Brazil: CC, DOC or OP  Note 1635483
    regud-xeinz                        "X - Lastschrift
    reguh-zbnks                        "Bankland Zahlungsempfänger
    reguh-zbnky                        "Bankkey zur Übersortierung
    reguh-zbnkl                        "Bankleitzahl Zahlungsempfänger
    reguh-zbnkn                        "Bank-Ktonummer Zahlungsempfänger
    reguh-lifnr                        "Kreditorennummer
    reguh-kunnr                        "Debitorennummer
    reguh-empfg                        "Zahlungsempfänger CPD
    reguh-vblnr                        "Zahlungsbelegnummer
    regup-belnr.                       "Internal document number


  cnt_filenr = 0.                      "# erstellter Dateien

*----------------------------------------------------------------------*
* Abarbeiten der extrahierten Daten                                    *
*----------------------------------------------------------------------*
  LOOP.

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
      sum_regut = 0.


*     Felder für Formularabschluß initialisieren
      cnt_formulare = 0.
      cnt_hinweise  = 0.
      sum_abschluss = 0.

*     Initialize counters
      cnt_lot       = 0.               "nr of records per lot
      cnt_records = 0.                 "nr of records per file

      CASE reguh-ubnkl(3).
        WHEN '237'.                    "Bradesco
          IF par_brla EQ '240'.                             "N2263671
            PERFORM fill_header_bradesco_240.
            PERFORM store_on_file USING j_1bdmexh1.
            PERFORM cr_lf.
          ELSE.
            IF hlp_laufk EQ 'P'.
              PERFORM fill_header_bradesco_hr.
              PERFORM store_on_file USING j_1bdmeahrh.
              PERFORM cr_lf.
            ELSE.
              PERFORM fill_header_bradesco.
              PERFORM store_on_file USING j_1bdmeah.
              PERFORM cr_lf.
            ENDIF.
          ENDIF.                                            "N2263671

        WHEN OTHERS.                   "Itau and Febraban
          PERFORM fill_header_itau.
          "Santander
          IF reguh-ubnkl(3) = '033'.

            IF reguh-rzawe = 'T' OR
               reguh-rzawe = 'B' OR
               reguh-rzawe = 'O'.
              CLEAR: j_1bdmexh1-h109.
            ENDIF.

          ENDIF.
          PERFORM store_on_file USING j_1bdmexh1.
          PERFORM cr_lf.
      ENDCASE.

    ENDAT.

*---Begin of Lot header-------------------------------------------------
*   Payment form: CC, DOC, OP, Titulo Itau or Titulo outro banco-----
*   If payment or credit note
    AT NEW regud-xeinz.
      CASE reguh-ubnkl(3).
        WHEN '237'.
          IF par_brla EQ '240'.
            PERFORM lot_header_bradesco240.

          ENDIF.

        WHEN OTHERS.                   "Itau, Febraban
          cnt_lot           = cnt_lot + 1. " Lots are counted
*         Datensätze Lot header + Trailer  initialisieren
          CLEAR: j_1bdmexh2, j_1bdmext2.
*         J_1BDMEXH2-J_1BCRLF = UP_CRLF.
*          j_1bdmexh2-j_1bcrlf = cr_lf.
          j_1bdmexh2-h201   = reguh-ubnkl(3).           " '341' for ITAU
          j_1bdmexh2-h202   = cnt_lot.
          j_1bdmexh2-h203   = '1'.

          CASE reguh-ubnkl(3).
            WHEN '341'.                "Itau
              j_1bdmexh2-h204   = 'C'.
              IF hlp_laufk NE 'P'.     "not HR
                IF regud-xeinz = space."Regular payment
                  j_1bdmexh2-h205 = '20'.
                ELSE.                  "credit note
                  j_1bdmexh2-h205 = '15'.
                ENDIF.
              ELSE.                                         "HR
                j_1bdmexh2-h205 = '30'.
              ENDIF.

            WHEN OTHERS.               "Febraban
              IF hlp_laufk NE 'P'.     "not HR
                IF regud-xeinz = space.  "Regular payment
                  j_1bdmexh2-h204 = 'C'.
                  j_1bdmexh2-h205 = '20'.
                ELSE.                    "credit note
                  j_1bdmexh2-h204 = 'D'.
                  j_1bdmexh2-h205 = '05'.
                ENDIF.
              ELSE.                                         "HR
                j_1bdmexh2-h204 = 'C'.
                j_1bdmexh2-h205 = '30'.
              ENDIF.
          ENDCASE.
*          "Meta - FIAP ID 10 - pagto fornecedor - Inicio
*          IF reguh-rzawe = 'T' AND
*             reguh-ubnkl(3) = '341'.
*            j_1bdmexh2-h206    = '41'.
*          ELSE.
          j_1bdmexh2-h206    = payment_form.
*          ENDIF.
          "Meta - FIAP ID 10 - pagto fornecedor - Fim
** J_1BDMEXH2-H207 : ITAU & Febraban layout do Lote
* Febraban

          IF NOT reguh-ubnkl(3) EQ '237' AND
             NOT reguh-ubnkl(3) EQ '341'.
            CASE par_fbla.
              WHEN '030'.
                j_1bdmexh2-h207   =  '020'.      "Lot version Feb 3.0
              WHEN '040'.
                j_1bdmexh2-h207   =  '030'.      "Lot version Feb 4.0
              WHEN '050'.

* Version '050' : When segment 'J' is created '030' instead of '031'
                j_1bdmexh2-h207   =  '031'.      "Lot version Feb 5.0
                IF regup-shkzg = 'H'.
                  IF payment_form = 30 OR payment_form = 31.
                    j_1bdmexh2-h207     =  '030'."Lot version Feb 4.0
                  ENDIF.
                ELSE.
                  AT daten.
                    IF regup-xrebz = space.
                      IF payment_form = 30 OR payment_form = 31.
                        j_1bdmexh2-h207   =  '030'."Lot version Feb 4.0
                      ENDIF.
                    ENDIF.
                  ENDAT.
                ENDIF.
*              WHEN '087'.
              WHEN '089'.  " Snote 2555959
* Version '087' : When segment 'J' is created '040' instead of '045'
                j_1bdmexh2-h207   =  '045'.      "Lot version Feb 8.7

                IF regup-shkzg = 'H'.
                  IF payment_form = 30 OR payment_form = 31.
                    j_1bdmexh2-h207     =  '040'."Lot version Feb 8.7
                  ENDIF.
                ELSE.
                  AT daten.
                    IF regup-xrebz = space.
                      IF payment_form = 30 OR payment_form = 31.
                        j_1bdmexh2-h207   =  '040'."Lot version Feb 8.7
                      ENDIF.
                    ENDIF.
                  ENDAT.
                ENDIF.
            ENDCASE.



          ENDIF.
* ITAU
          IF reguh-ubnkl(3) EQ '341'.
            CASE par_ver.
              WHEN '050'.
                j_1bdmexh2-h207(3)  =  '031'. "Lot version ITAU 5
                IF regup-shkzg = 'H'.
                  IF payment_form = 30 OR payment_form = 31.
                    j_1bdmexh2-h207     =  '030'."Lot version Feb 4.0
                  ENDIF.
                ELSE.
                  AT daten.
                    IF regup-xrebz = space.
                      IF payment_form = 30 OR payment_form = 31.
                        j_1bdmexh2-h207     =  '030'."Lot version Feb 4.0
                      ENDIF.
                    ENDIF.
                  ENDAT.
                ENDIF.
              WHEN '080'.
*                J_1BDMEXH2-H207(3)  =  '031'. "Lot version ITAU 5 "2359292
                j_1bdmexh2-h207(3)  =  '040'. "Lot version ITAU 5 " 2359292
                IF regup-shkzg = 'H'.
                  IF payment_form = 30 OR payment_form = 31.
                    j_1bdmexh2-h207     =  '030'."Lot version Itau 8.0    "N1897495
                  ENDIF.
                ELSE.
                  AT daten.
                    IF regup-xrebz = space.
                      IF payment_form = 30 OR payment_form = 31.
                        j_1bdmexh2-h207     =  '030'."Lot version Itau 8.0 "N1897495
                      ENDIF.
                    ENDIF.
                  ENDAT.
                ENDIF.
            ENDCASE.
          ENDIF.

          j_1bdmexh2-h208    = '2'.    " CGC and not CPF
          j_1bdmexh2-h209    = j_1bdmexh1-h106.
          j_1bdmexh2-h210    = j_1bdmexh1-h107.   " Company ID at bank
          IF par_ver EQ '080' AND reguh-ubnkl(3) EQ '341'.
            CLEAR j_1bdmexh2-h210.
          ENDIF.
          j_1bdmexh2-h211    = j_1bdmexh1-h108.           " house bank
          j_1bdmexh2-h212    = j_1bdmexh1-h109.
          j_1bdmexh2-h213    = j_1bdmexh1-h110.          "house bank acc
          j_1bdmexh2-h214    = j_1bdmexh1-h111.
          j_1bdmexh2-h215    = j_1bdmexh1-h112.          " control digit
          j_1bdmexh2-h216    = j_1bdmexh1-h113.               " our name
          CLEAR: j_1bdmexh2-h217,
                 j_1bdmexh2-h218.

          j_1bdmexh2-h219    = j1_addr1val-street.             " our street
          PERFORM dta_text_aufbereiten USING j_1bdmexh2-h219.
          j_1bdmexh2-h220    = j1_addr1val-house_num1.         "house number
          PERFORM dta_text_aufbereiten USING j_1bdmexh2-h220.
          j_1bdmexh2-h221    = j1_addr1val-house_num2.                 "complement
          PERFORM dta_text_aufbereiten USING j_1bdmexh2-h221.
          j_1bdmexh2-h222    = j1_addr1val-city1.              "City
          PERFORM dta_text_aufbereiten USING j_1bdmexh2-h222.
          j_1bdmexh2-h223    = j1_addr1val-post_code1(5).      "Zip-code
          PERFORM dta_text_aufbereiten USING j_1bdmexh2-h223.
          j_1bdmexh2-h224    = j1_addr1val-post_code1+6(3).    "compl.
          PERFORM dta_text_aufbereiten USING j_1bdmexh2-h224.
          j_1bdmexh2-h225    = j1_addr1val-region.             "Region
          PERFORM dta_text_aufbereiten USING j_1bdmexh2-h225.
          CLEAR:
            j_1bdmexh2-h226,
            j_1bdmexh2-h227,
            j_1bdmexh2-h228.

*          if par_fbla = '087'.
          IF par_fbla = '089'. "Snote  2555959
*   Implement the BAdI method change_lot_header in order to fill
*   the field:
*   Indicative of Payment (j_1bdmexh2-h226), Febraban Version 8.7
            CLEAR: ls_reguh, ls_regud, ls_file_header.

            ls_reguh = reguh.
            ls_regud = regud.
            ls_file_header = j_1bdmexh1.
            TRY.
                CALL BADI obj_badi_rffobr_u->change_lot_header
                  EXPORTING
                    is_j_1bdmexh1  = ls_file_header
                    is_reguh       = ls_reguh
                    is_regud       = ls_regud
                    iv_feb_version = par_fbla
*                   iv_itau_ver    =
                  CHANGING
                    cs_j_1bdmexh2  = j_1bdmexh2.
              CATCH cx_sy_dyn_call_illegal_method.
            ENDTRY.

          ENDIF.

          DATA: lv_barcode1 TYPE bseg-glo_ref1.
          "@@ Busca codigo de barra digitado
          SELECT SINGLE glo_ref1
            FROM bseg
            INTO ( lv_barcode1 )
            WHERE belnr = regup-belnr
              AND bukrs = regup-bukrs
              AND gjahr = regup-gjahr
              AND buzei = regup-buzei.

          IF reguh-rzawe = 'O'
            OR reguh-rzawe = 'Q'
            OR reguh-rzawe = 'G'
            OR ( ( reguh-rzawe = 'B') AND ( reguh-ubnkl(3) = '341') )
            OR ( ( reguh-rzawe = 'B') AND ( reguh-ubnkl(3) = '001') )
            OR ( ( reguh-rzawe = 'U') AND ( reguh-ubnkl(3) = '341') ).

            "BB
            IF reguh-ubnkl(3) = '001'.
              j_1bdmexh2-h205 = '98'.
              j_1bdmexh2-h206 = '11'.
            ELSEIF reguh-ubnkl(3) = '341' AND
                reguh-rzawe = 'B' AND
                lv_barcode1(3) = '341'.
              j_1bdmexh2-h206 = '30'.
            ELSEIF reguh-ubnkl(3) = '341' AND
                reguh-rzawe = 'U'.
              j_1bdmexh2-h206 = '01'.
            ELSE.
              "Outros bancos
              IF reguh-rzawe = 'O' OR reguh-rzawe = 'G' .
                j_1bdmexh2-h205 = '22'.
                j_1bdmexh2-h206 = '91'.
              ELSEIF reguh-rzawe = 'Q'.
                j_1bdmexh2-h205 = '20'.
                j_1bdmexh2-h206 = '13'.
              ENDIF.
            ENDIF.


          ENDIF.


          "Itau
          IF reguh-ubnkl(3) = '341'.

            IF reguh-rzawe = 'R' AND reguh-zbnkl(3) EQ '341'.
              j_1bdmexh2-h206 = '01'.
              j_1bdmexh2-h207 = '040'.
            ELSEIF reguh-rzawe = 'R' AND reguh-zbnkl(3) NE '341'.
              j_1bdmexh2-h206 = '41'.
              j_1bdmexh2-h207 = '040'.
            ENDIF.

          ENDIF.

          "BB
          IF reguh-ubnkl(3) = '001'.


            IF reguh-rzawe = 'U'.
              j_1bdmexh2-h206 = '01'.
              j_1bdmexh2-h207 = '045'.

            ELSEIF reguh-rzawe = 'T'.
              j_1bdmexh2-h207 = '045'.
              IF reguh-zbnkl(3) = '001'.
                j_1bdmexh2-h206 = '03'.
              ELSEIF reguh-zbnkl(3) <> '001'.
                j_1bdmexh2-h206 = '41'.
              ENDIF.

            ELSEIF reguh-rzawe = 'R'.
              j_1bdmexh2-h207 = '045'.
              IF reguh-zbnkl(3) <> '001'.
                j_1bdmexh2-h206 = '03'.
              ELSE.
                j_1bdmexh2-h206 = '01'.
              ENDIF.

            ELSEIF reguh-rzawe = 'B'.

              IF lv_barcode1(3) = '001'.
                j_1bdmexh2-h206 = '30'.
              ELSE.
                j_1bdmexh2-h206 = '31'.
              ENDIF.

            ENDIF.

          ENDIF.

          "Santander
          IF reguh-ubnkl(3) = '033'.

            IF reguh-rzawe = 'T'.
              j_1bdmexh2-h206 = '3'.
              CLEAR: j_1bdmexh2-h212 .

            ELSEIF reguh-rzawe = 'R'.

              IF reguh-zbnkl(3) <> '033'.
                j_1bdmexh2-h206 = '03'.
              ELSEIF reguh-zbnkl(3) = '033'.
                j_1bdmexh2-h206 = '01'.
              ENDIF.

            ENDIF.

            IF reguh-rzawe = 'B' OR
               reguh-rzawe = 'O'.
              CLEAR: j_1bdmexh2-h212 .
            ENDIF.

          ENDIF.

          "Safra
          IF reguh-ubnkl(3) = '422'.
            IF reguh-rzawe = 'T'.
              j_1bdmexh2-h206 = '03'.
            ELSEIF reguh-rzawe = 'R'.
              j_1bdmexh2-h206 = '01'.
            ELSEIF reguh-rzawe = 'U'.
              j_1bdmexh2-h206 = '01'.
              j_1bdmexh2-h207 = '046'.
            ENDIF.
          ENDIF.


          "Citybank
          IF reguh-ubnkl(3) = '745'. .

            IF reguh-rzawe = 'G' OR
               reguh-rzawe = 'Q' .

              j_1bdmexh2-h207 = '031'.
              j_1bdmexh2-h206 = '11'.
              CLEAR: j_1bdmexh2-h218.

            ELSEIF reguh-rzawe = 'R' OR
                   reguh-rzawe = 'T' .
              j_1bdmexh2-h206 = '41'.
              j_1bdmexh2-h207 = '031'.

            ELSEIF reguh-rzawe = 'B'.
              j_1bdmexh2-h206 = '31'.

            ELSEIF reguh-rzawe = 'O'.
              j_1bdmexh2-h207 = '012'.
              j_1bdmexh2-h206 = '11'.
              CLEAR: j_1bdmexh2-h218.
            ENDIF.

          ENDIF.


*-Lot header filled-----------------------------------------------------

          PERFORM store_on_file USING j_1bdmexh2.
          PERFORM cr_lf.

*         Initialize record counter per lot
          cnt_rec_perlot = 0.

*         Initialize special detail counter
          cnt_rec_detail = 0.

*         Initialize total per lot
          CLEAR total_perlot.
*---------End of Lot header---------------------------------------------

      ENDCASE.
    ENDAT.

*-- Neue Empfängerbank -------------------------------------------------
    AT NEW reguh-zbnkl.
      PERFORM empfbank_daten_lesen.
      CALL FUNCTION 'J_1B_CONVERT_BANK'
        EXPORTING
          i_bank = reguh-zbnkl
        IMPORTING
          e_bank = partner_agency
        EXCEPTIONS
          OTHERS = 1.

    ENDAT.

***---New Payment Receiver---------------------------------------------
*    AT NEW REGUH-LIFNR.
*
*      PERFORM FIND_VENDOR_CNPJ.
*
*    ENDAT.
*
*    AT NEW REGUH-EMPFG.
*
*      PERFORM FIND_VENDOR_CNPJ.
*
*    ENDAT.
*---End of Payment Receiver--------------------------------------------

*-- Neue Zahlungsbelegnummer -------------------------------------------
    AT NEW reguh-vblnr.


*     Zahlweg-Daten nachlesen, falls notwendig
      IF reguh-rzawe NE hlp_rzawe.
        PERFORM zahlweg_daten_lesen.
        hlp_rzawe = reguh-rzawe.
        t042z-text1 = text_004.
      ENDIF.

      PERFORM zahlungs_daten_lesen.
      PERFORM summenfelder_initialisieren.
      PERFORM belegdaten_schreiben.

*     Summenfelder hochzählen und aufbereiten
      ADD 1            TO cnt_formulare.

      IF regud-xeinz = 'X'.            "incoming paym.
        sum_abschluss = sum_abschluss - reguh-rbetr.
      ELSE.
        sum_abschluss = sum_abschluss + reguh-rbetr.
      ENDIF.

*     Calculate Total per lot
      total_perlot = total_perlot + reguh-rbetr.
*     Payment form equals 1=CC, 2=Cheque P, 3=DOC, 10=OP
*      IF PAYMENT_FORM LE '10'.
*     get data for one time vendor
      IF hlp_xcpdk IS INITIAL.
        REFRESH: taxtab.
      ELSE.                          " one time vendor
        REFRESH: itemtab.
        SELECT bukrs belnr gjahr buzei
               FROM regup INTO CORRESPONDING FIELDS OF TABLE itemtab
               WHERE laufd = reguh-laufd AND
                     laufi = reguh-laufi AND
                     xvorl = reguh-xvorl AND
                     zbukr = reguh-zbukr AND
                     lifnr = reguh-lifnr AND
                     kunnr = reguh-kunnr AND
                     empfg = reguh-empfg AND
                     vblnr = reguh-vblnr.
* get the tax numbers
        REFRESH:taxtab.
        LOOP AT itemtab.
          SELECT SINGLE stkzn stcd1 stcd2 FROM bsec INTO
                 CORRESPONDING FIELDS OF taxtab
                 WHERE bukrs = itemtab-bukrs AND
                  belnr = itemtab-belnr AND
                  gjahr = itemtab-gjahr AND
                  buzei = itemtab-buzei.
          COLLECT taxtab.
        ENDLOOP.
      ENDIF.

*
      CASE reguh-ubnkl(3).
        WHEN '237'.                  "Bradesco
*          if payment_form le '10'.
          IF par_brla EQ '240'.                             "N2263671
            PERFORM get_barcode.
            IF ls_barcode-esrnr EQ space AND ls_barcode-esrre EQ space.
              PERFORM fill_bradesco240_segment_a.
              "Meta - FIAP ID 10 - pagto fornecedor - Inicio

              IF reguh-rzawe = 'T' OR reguh-rzawe = 'U'.
                j_1bdmexa-a07 = '09'.
              ENDIF.


              IF reguh-rzawe = 'T'.

                j_1bdmexa-a08 = '018'.
                j_1bdmexa-a26+6(5) = '00010'.
                IF reguh-bkref IS INITIAL.
                  j_1bdmexa-a26+11(2) = 'CC'.
                ELSEIF reguh-bkref = 'P'.
                  j_1bdmexa-a26+11(2) = 'PP'.
                ENDIF.

              ELSEIF reguh-rzawe = 'R'.

                IF reguh-zbnkn IS NOT INITIAL.
                  j_1bdmexa-a08 = '018'.
                  IF reguh-zbnkn(3) EQ '237'.
                    CLEAR: j_1bdmexa-a26+6(5), j_1bdmexa-a26+11(2).
                  ELSE.
                    j_1bdmexa-a26+6(5) = '00010'.
                    j_1bdmexa-a26+11(2) = 'CC'.
                  ENDIF.

                ELSE.
                  j_1bdmexa-a08 = '000'.
                ENDIF.

              ELSEIF reguh-rzawe = 'U'.
                j_1bdmexa-a08 = '000'.
              ENDIF.


              "Meta - FIAP ID 10 - pagto fornecedor - Fim

              PERFORM store_on_file USING j_1bdmexa.
              PERFORM cr_lf.
              IF ( NOT par_baav EQ space AND reguh-ubnkl(3) EQ '237' ) OR
                       reguh-ubnkl(3) EQ '237'.
                PERFORM fill_bradesco240_segment_b USING reguh.
                PERFORM store_on_file USING j_1bdmexb.
                PERFORM cr_lf.

                "Risco sacado
                IF reguh-rzawe = 'R'.

                  PERFORM fill_bradesco_5 USING j_1bdmexb.
                  PERFORM store_on_file USING zsfi_j_1bdmex5.
                  PERFORM cr_lf.

                ENDIF.


              ENDIF.
            ENDIF.
          ELSE.
            IF payment_form LE '10'.                        "N2263671
              IF hlp_laufk EQ 'P'.
                PERFORM details_bradesco_hr.
                PERFORM store_on_file USING j_1bdmeahra.
                PERFORM cr_lf.
              ELSE.
                PERFORM details_bradesco.
                PERFORM store_on_file USING j_1bdmeaa.
                PERFORM cr_lf.
              ENDIF.
            ENDIF.
          ENDIF.                                            "N2263671

*          endif. "payform le 10if
        WHEN OTHERS.                 "Itau and Febraban
* only process if not Boleto
          PERFORM get_barcode.
          IF ls_barcode-esrnr EQ space AND ls_barcode-esrre EQ space.
            PERFORM fill_itau_segment_a.
            "Meta - ID 10 - pagto fornecedor - Inicio
            IF reguh-ubnkl(3) = '001'.
              j_1bdmexa-a07 = '00'.
              IF reguh-rzawe = 'U'.
                j_1bdmexa-a08 = '000'.
              ENDIF.
            ELSEIF reguh-ubnkl(3) = '745'.
              j_1bdmexa-a07 = '09'.
              IF reguh-rzawe = 'R'.
                j_1bdmexa-a08 = '018'.
                PERFORM f_trata_city_a16 CHANGING j_1bdmexa-a16.
              ELSEIF reguh-rzawe = 'T'.
                CLEAR: j_1bdmexa-a11,j_1bdmexa-a13.
                j_1bdmexa-a08 = '018'.
              ENDIF.
            ELSEIF reguh-ubnkl(3) = '033' ."Santander
              j_1bdmexa-a07 = '00'.
              IF reguh-rzawe = 'T'.
                j_1bdmexa-a08 = '018'.
              ELSEIF reguh-rzawe = 'R'.
                IF reguh-zbnkl(3) <> '033'.
                  j_1bdmexa-a08 = '018'.
                ELSEIF reguh-zbnkl(3) = '033'.
                  j_1bdmexa-a08 = '000'.
                ENDIF.
              ENDIF.
            ELSEIF reguh-ubnkl(3) = '422'. "Safra
              j_1bdmexa-a07 = '00'.
              IF reguh-rzawe = 'R'.
                j_1bdmexa-a08 = '000'.
                j_1bdmexa-a09 = '422'.
              ELSEIF reguh-rzawe = 'U'.
                j_1bdmexa-a08 = '000'.
                j_1bdmexa-a09 = '422'.
              ENDIF.
            ELSE.
              j_1bdmexa-a07 = '03'.
            ENDIF.

            "Meta - ID 10 - pagto fornecedor - Fim
            PERFORM store_on_file USING j_1bdmexa.
            PERFORM cr_lf.
            IF ( NOT par_baav EQ space
            AND reguh-ubnkl(3) EQ '341' ) OR
            reguh-ubnkl(3) NE '341'.
              PERFORM fill_itau_segment_b USING reguh.      "Note 1931476
              PERFORM store_on_file USING j_1bdmexb.
              PERFORM cr_lf.
            ENDIF.
          ENDIF.
      ENDCASE.
*      ENDIF.
    ENDAT.

*---SINGLE ITEMS -------------------------------------------------------
    AT daten.
      PERFORM einzelpostenfelder_fuellen.
      PERFORM summenfelder_fuellen.

*     REGUP-XREBZ is only <> space when paid together with
*     referenced item, e.g. for credit memo or down payment.
      IF regup-xrebz = space OR regup-shkzg = 'H'.
        IF payment_form = 30 OR payment_form = 31.
          PERFORM get_barcode.
          CASE reguh-ubnkl(3).
            WHEN '237'.                "Bradesco
              IF par_brla EQ '240'.                         "N2263671
                "Meta - FIAP ID 10 - pagto fornecedor - Inicio
                IF reguh-rzawe = 'O' OR reguh-rzawe = 'Q' OR reguh-rzawe = 'G'.
                  PERFORM fill_segment_o.

                  IF reguh-rzawe = 'O' OR reguh-rzawe = 'Q' .
                    j_1bdmexo-o07 = '09'.
                  ELSEIF reguh-rzawe = 'G'.
                    j_1bdmexo-o07 = '00'.
                  ENDIF.

                  PERFORM store_on_file USING j_1bdmexo.
                  PERFORM cr_lf.
                  "Meta - FIAP ID 10 - pagto fornecedor - Fim
                ELSEIF reguh-rzawe <> 'R' .
                  PERFORM fill_itau_segment_j.
                  PERFORM store_on_file USING j_1bdmexj.
                  PERFORM cr_lf.

                  IF par_j52 EQ 'X' AND ( payment_form = 31 OR payment_form = 30 ) AND ( reguh-rwbtr GE par_amt ).
                    PERFORM fill_itau_segment_j52.

                    IF reguh-rzawe = 'B'.
                      j_1bdmexj52-j06_2 = '09'.
                    ENDIF.

                    PERFORM store_on_file USING j_1bdmexj52.
                    PERFORM cr_lf.
                  ENDIF.
                ENDIF.
              ELSE.

                "Meta - FIAP ID 10 - pagto fornecedor - Inicio
                IF reguh-rzawe = 'O' OR reguh-rzawe = 'Q' OR reguh-rzawe = 'G'.
                  PERFORM fill_segment_o.

                  IF reguh-rzawe = 'O' OR reguh-rzawe = 'Q' .
                    j_1bdmexo-o07 = '09'.
                  ELSEIF reguh-rzawe = 'G'.
                    j_1bdmexo-o07 = '00'.
                  ENDIF.

                  PERFORM store_on_file USING j_1bdmexo.
                  PERFORM cr_lf.
                  "Meta - FIAP ID 10 - pagto fornecedor - Fim
                ELSEIF reguh-rzawe <> 'R'.
                  PERFORM details_bradesco.
                  PERFORM store_on_file USING j_1bdmeaa.
                  PERFORM cr_lf.
                ENDIF.
              ENDIF.                                        "N2263671
            WHEN OTHERS.               "Itau, Febr.

              "Meta - FIAP ID 10 - pagto fornecedor - Inicio
              IF reguh-rzawe = 'O' OR reguh-rzawe = 'Q' OR reguh-rzawe = 'G'.

                IF reguh-ubnkl(3) EQ '341'.
                  PERFORM fill_itau_segment_o.
                  PERFORM store_on_file USING zsfi_segmento_o.
                ELSE.
                  PERFORM fill_segment_o.
                  PERFORM store_on_file USING j_1bdmexo.
                ENDIF.
                PERFORM cr_lf.
                "Meta - FIAP ID 10 - pagto fornecedor - Fim
              ELSE.

                DATA: lr_rzame_j TYPE RANGE OF reguh-rzawe.

                lr_rzame_j = VALUE #( ( sign = 'I' option = 'EQ' low = 'R')
                                    ( sign = 'I' option = 'EQ' low = 'U') ).

                IF reguh-rzawe NOT IN lr_rzame_j .

                  PERFORM fill_itau_segment_j.

                  PERFORM store_on_file USING j_1bdmexj.
                  PERFORM cr_lf.

*Legal changes for brazil J52 Segment
                  IF par_j52 EQ 'X' AND ( payment_form = 31 OR payment_form = 30 ).
                    IF par_ver EQ '080' AND reguh-rwbtr GE par_amt AND j_1bdmexh1-h101 EQ '341'.

                      PERFORM fill_itau_segment_j52.
                      PERFORM store_on_file USING j_1bdmexj52.
                      PERFORM cr_lf.
*                ElSEIF par_fbla EQ '087' AND reguh-rwbtr GE par_amt.
                    ELSEIF par_fbla EQ '089' AND reguh-rwbtr GE par_amt.  "Snote  2555959

                      IF reguh-rzawe NOT IN lr_rzame_j .

                        PERFORM fill_febr_segment_j52.
                        IF reguh-ubnkl(3) = '001'.
                          j_1bdfebj52-j14 = j_1bdfebj52-j11.
                          j_1bdfebj52-j15 = j_1bdfebj52-j12.
                        ENDIF.

                        PERFORM store_on_file USING j_1bdfebj52.
                        PERFORM cr_lf.
                      ENDIF.
                    ENDIF.
                  ENDIF.
                ENDIF.
              ENDIF.
*Legal changes for brazil J52 Segment
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
*---END SINGLE ITEMS----------------------------------------------------

    AT END OF regud-xeinz.

      CASE reguh-ubnkl(3).
        WHEN '237'.
          IF par_brla EQ '240'.
            PERFORM fill_lot_trailer_bradesco240.
          ENDIF.
        WHEN OTHERS.                   "Itau, Febraban
*---Fill lot trailer----------------------------------------------------

*         J_1BDMEXT2-J_1BCRLF = UP_CRLF.
*          j_1bdmext2-j_1bcrlf = cr_lf.
          j_1bdmext2-t201   = reguh-ubnkl(3).          " '341' for ITAU
          j_1bdmext2-t202   = cnt_lot.
          j_1bdmext2-t203   = '5'.
          j_1bdmext2-t204   = space.

*         Count record number per lot plus lot header and trailer
          j_1bdmext2-t205   = cnt_rec_perlot + 2.

*         Total per lot
          j_1bdmext2-t206   = total_perlot.              "t206 is num18
          CLEAR: nlstr.
          j_1bdmext2-t207   = nlstr.

          IF reguh-ubnkl(3) NE '341'. "AND PAR_FBLA = '030'. note 2729322
            j_1bdmext2-t208(6) = '000000'.            "note 0391260
          ENDIF.                                      "note 0391260

          CLEAR:
          "j_1bdmext2-t208, note 2729322
          j_1bdmext2-t209.

          PERFORM store_on_file USING j_1bdmext2.
          PERFORM cr_lf.
*  ---End lot trailer--------------------------------------------------
      ENDCASE.
    ENDAT.

*-- end of account of house bank----------------------------------------
    AT END OF reguh-ubknt.
      CASE reguh-ubnkl(3).
        WHEN '237'.                    "Bradesco
          IF par_brla EQ '240' .
            PERFORM fill_trailer_itau.
            PERFORM store_on_file USING j_1bdmext1.
            PERFORM cr_lf.
            regud-text1(20) = j_1bdmext1-t106.         "Total of records
            regud-text2(20) = j_1bdmext1-t105.         "Total of lots
          ELSE.
            IF hlp_laufk EQ 'P'.
              PERFORM fill_trailer_bradesco_hr.
              PERFORM store_on_file USING j_1bdmeahrt.
              PERFORM cr_lf.
            ELSE.
              PERFORM fill_trailer_bradesco.
              PERFORM store_on_file USING j_1bdmeat.
              PERFORM cr_lf.
              regud-text1(20) = j_1bdmeat-t02.           "Total of records
            ENDIF.
          ENDIF.

        WHEN OTHERS.                   "Itau, Febraban
          PERFORM fill_trailer_itau.
          PERFORM store_on_file USING j_1bdmext1.
          PERFORM cr_lf.
          regud-text1(20) = j_1bdmext1-t106.         "Total of records
          regud-text2(20) = j_1bdmext1-t105.         "Total of lots

      ENDCASE.

*     find out name of element of sheet
      IF par_dtyp EQ '1'.
        hlp_element = '526'.           "Transfer
        hlp_eletext = TEXT-525.
      ELSE.
        hlp_element = '536'.           "Transfer
        hlp_eletext = TEXT-535.
      ENDIF.


      PERFORM begleitzettel_schreiben.

      PERFORM formularabschluss_schreiben.

*     Alte Diskette/altes Band schließen
*     close disk/ tape
      sum_regut = sum_abschluss.       "identisch

*     Dateiname --------------------------------------------------------
      CASE reguh-ubnkl(3).
        WHEN '341'.
          hlp_dtfor   = 'SISPAG'.
        WHEN '237'.
          hlp_dtfor   = 'PFEB__'.
        WHEN OTHERS.
          CASE par_fbla.
            WHEN '030'.
              hlp_dtfor   = 'CNAB030'.   "File version 3.0
            WHEN '040'.
              hlp_dtfor   = 'CNAB040'.   "File version 4.0
            WHEN '050'.
              hlp_dtfor   = 'CNAB050'.   "File version 5.0
*            WHEN '087'.
            WHEN '089'.   "snote 2555959
              hlp_dtfor   = 'CNAB087'.   "File version 8.7
          ENDCASE.
      ENDCASE.
*     Name der sequentiellen Files vorbelegen: Datum.Uhrzeit.lfdNr
      IF hlp_temse NA par_dtyp AND     "Keine TemSe / No TemSe
        par_unix EQ space.             "kein Name   / unspecified name
        par_unix =  hlp_dtfor .
        par_unix+6 = '.'.
        WRITE sy-datum TO par_unix+7(6) DDMMYY.
        par_unix+13 = '.'.
        par_unix+14 = sy-uzeit.
        par_unix+20 = '.'.
      ENDIF.
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



*----------------------------------------------------------------------*
* FORM BEGLEITZETTEL_SCHREIBEN                                         *
*----------------------------------------------------------------------*
* Schreiben eines Begleitzettels pro logische Datei                    *
* write accompanying sheet for each logical file                       *
*----------------------------------------------------------------------*
FORM begleitzettel_schreiben.

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

ENDFORM.                    "FORMULARABSCHLUSS_SCHREIBEN

*-----------------------------------------------------------------------
* FORM FILL_ITAU_SEGMENT_A
* segment A of ITAU layout is filled
*-----------------------------------------------------------------------
FORM fill_itau_segment_a.

* DATA  UP_CRLF(2) TYPE X VALUE '0D0A'."carriage return + line feed
*  data cr_lf(2)   type c value cl_abap_char_utilities=>cr_lf.
  DATA: str_length     TYPE i, hlp_char12(12) TYPE c,
        hlp_control(5) TYPE c.

  DATA: obj_badi_rffobr_u TYPE REF TO fiapbr_rffobr_u.   "BAdI object
  DATA: ls_reguh       TYPE reguh,
        ls_regud       TYPE regud,
        ls_file_header TYPE j_1bdmexh1,
        ls_lot_header  TYPE j_1bdmexh2.

  GET BADI obj_badi_rffobr_u.
* -----Segment A -------------------------------------------------------
  CLEAR j_1bdmexa.

* J_1BDMEXA-J_1BCRLF = UP_CRLF.
*  j_1bdmexa-j_1bcrlf = cr_lf.
  cnt_rec_perlot = cnt_rec_perlot + 1.
  cnt_records  = cnt_records  + 1.
  cnt_rec_detail = cnt_rec_detail + 1.

  j_1bdmexa-a01   = j_1bdmexh1-h101.   "'341' for ITAU
  j_1bdmexa-a02   = cnt_lot.
  j_1bdmexa-a03   = '3'.
  j_1bdmexa-a04   = cnt_rec_detail.
  j_1bdmexa-a05   = 'A'.
  j_1bdmexa-a06   = '0'.
*      new layout version for ITAU '020', '050', '080'
  IF ( par_ver EQ '020' OR par_ver EQ '050'
  OR par_ver EQ '080' )
  AND reguh-ubnkl(3) EQ '341'.
* 655287
    CONCATENATE '0' hlp_stkzn INTO j_1bdmexa-a07.
  ELSE.
*      old version 010 /Febraban
    j_1bdmexa-a07   =  00.
  ENDIF.
* Changes for SPB
  IF reguh-ubnkl(3) = '341'.
    j_1bdmexa-a08 = '000'.
  ELSE.
    PERFORM spb_chamber USING payment_form hlp_cnpj_check
                   CHANGING j_1bdmexa-a08.
  ENDIF.
  j_1bdmexa-a09   = reguh-zbnkl(3).    "bank group,e.g.Itau=341
  j_1bdmexa-a10   = partner_agency.    " Partner's agency

  CALL FUNCTION 'READ_ACCOUNT_DATA'
    EXPORTING
      i_bankn = reguh-zbnkn
      i_bkont = reguh-zbkon
    IMPORTING
      e_bankn = regud-obknt
      e_cntr1 = j_1bdmexa-a11
      e_cntr2 = j_1bdmexa-a13
      e_cntr3 = j_1bdmexa-a14
    EXCEPTIONS
      OTHERS  = 1.
*   adjust to correct layout format
*   OUR bank is Itau: write check digit of account to A14
*   and clear the rest
  IF reguh-ubnkl(3) = '341'.
* house bank Itau: no agency check digit exists
* (a11 always empty). If only one check digit
* write on a14. If two check digits write on a13 and a14
    IF  j_1bdmexa-a13 NE space
    AND j_1bdmexa-a14 EQ space.
      j_1bdmexa-a14 = j_1bdmexa-a13.
      CLEAR j_1bdmexa-a13.
    ENDIF.
    CLEAR j_1bdmexa-a11.
  ELSE.
* partner bank is ITAU: check digit might be on a14 or a13
* if on a14 write to a13.
    IF reguh-zbnkl(3) = '341'
    AND j_1bdmexa-a14 NE space.
      j_1bdmexa-a13 = j_1bdmexa-a14.
      CLEAR j_1bdmexa-a14.
    ENDIF.
* no agency check digit with two bank account check digits
* or check digit of agency in 'old way'
    IF  j_1bdmexa-a11 EQ space
    AND j_1bdmexa-a13 EQ space
    AND j_1bdmexa-a14 NE space.
      j_1bdmexa-a11 = j_1bdmexa-a14.
      CLEAR j_1bdmexa-a14.
    ENDIF.
  ENDIF.
*
  j_1bdmexa-a12     = regud-obknt.
*     j_1bdmexa-a15     = reguh-znme1. "Vendor name
  j_1bdmexa-a15     = reguh-koinh.
  PERFORM dta_text_aufbereiten USING j_1bdmexa-a15.
  j_1bdmexa-a16     = reguh-vblnr.     "Seu numero
  PERFORM dta_text_aufbereiten USING j_1bdmexa-a16.

*     Pay date, ddmmyy
  j_1bdmexa-a17(2)    = reguh-valut+6(2).
  j_1bdmexa-a17+2(2)  = reguh-valut+4(2).
  j_1bdmexa-a17+4(4)  = reguh-valut(4).
  CASE reguh-ubnkl(3).
    WHEN '341'.                        "Itau
      j_1bdmexa-a18       = '009'.
    WHEN OTHERS.
      j_1bdmexa-a18       = 'BRL'.     "Febraban
  ENDCASE.
  j_1bdmexa-a20       = reguh-rbetr.   "paid amount per item
*
  j_1bdmexa-a22 = '00000000'.
  j_1bdmexa-a23 = '000000000000000'.
  IF reguh-ubnkl(3) EQ '341'.  " Note 1423537
    IF j_1bdmexh2-h206 = '01'.
      PERFORM fill_nota_fiscal CHANGING j_1bdmexa-a24.
    ENDIF.
    j_1bdmexa-a25+0(6) = '000000'.    "Note 1650735
    j_1bdmexa-a25+6(10) = hlp_taxcode(10).
    j_1bdmexa-a26(4)   =  hlp_taxcode+10(4).
  ENDIF.
*
********** Febraban Version 8.7 and Itau 080 *******************
*  if par_fbla = '087' or ( par_ver = '080'
*     and reguh-ubnkl(3) eq '341' ).
  IF par_fbla = '089' OR ( par_ver = '080'
 AND reguh-ubnkl(3) EQ '341' ).   "snote  2555959

    IF reguh-ubnkl(3) NE '341'.
      CLEAR: j_1bdmexa-a24, j_1bdmexa-a25, j_1bdmexa-a26.
    ENDIF.

*   Implement the BAdI Method "change_segment_a" to fill the
*   fields according  to your requirement

*   The following fields for Febraban version 8.7,
*
*   1. DOC Purpose Code: 	 field  j_1bdmexa-a26+4(2)
*   2. TED Purpose code:   field  j_1bdmexa-a26+6(5)
*   3. Complement of purpose code: field  j_1bdmexa-a26+11(2)
*   j_1bdmexa-a26+6(5)
*   j_1bdmexa-a26+11(2)

*   The following fields for Itau version 080
*   1. DOC Purpose and Employee status:  field  j_1bdmexa-a26+4(2)
*   2. TED Purpose code               :  field  j_1bdmexa-a26+6(5)

    CLEAR: ls_reguh, ls_regud, ls_file_header, ls_lot_header.
    ls_reguh = reguh.
    ls_regud = regud.
    ls_file_header = j_1bdmexh1.
    ls_lot_header = j_1bdmexh2.
    TRY.
        CALL BADI obj_badi_rffobr_u->change_segment_a
          EXPORTING
            is_j_1bdmexh1  = ls_file_header
            is_reguh       = ls_reguh
            is_regud       = ls_regud
            iv_feb_version = par_fbla
            iv_itau_ver    = par_ver
            is_j_1bdmexh2  = ls_lot_header
          CHANGING
            cs_j_1bdmexa   = j_1bdmexa.
      CATCH cx_sy_dyn_call_illegal_method.
    ENDTRY.
  ENDIF.
********** Febraban Version 8.7 **************************
  IF NOT par_baav EQ space.            " with advice
    j_1bdmexa-a27     =  '5'.
  ELSE.                                " w/o advice
    j_1bdmexa-a27     =  '0'.
  ENDIF.
  j_1bdmexa-a28       = space.

*--- End of Segment A --------------------------------------------------
ENDFORM.                    "FILL_ITAU_SEGMENT_A

*-----------------------------------------------------------------------
* FORM FILL_ITAU_SEGMENT_B
* segment B of ITAU layout is filled
*-----------------------------------------------------------------------
FORM
  fill_itau_segment_b  USING i_reguh LIKE reguh.           "Note 1931476

* DATA  UP_CRLF(2) TYPE X VALUE '0D0A'."carriage return + line feed
*  data cr_lf(2)   type c value cl_abap_char_utilities=>cr_lf.
  DATA: hlp_str(113) TYPE c.           " Help string for last entry
  DATA: date LIKE sy-datum.
  DATA: value(15) TYPE c.
  DATA: ls_ispb_code TYPE fiapbrd_ispb.
  DATA: lv_email_addr TYPE ad_smtpadr.

  "Start of Note 1931476
  DATA: et_rgdir TYPE hrpy_tt_rgdir,
        wa_rgdir TYPE pc261,
        lv_molga TYPE molga,
        lv_abkrs TYPE abkrs,
        lv_fpper TYPE faper,
        lv_permo TYPE permo,
        lv_begda TYPE begda,
        lv_endda TYPE endda,
        lv_fpbeg TYPE fpbeg.
  "end of Note 1931476
  "Begin of Note:2658786
  DATA: lv_house_num1 TYPE c LENGTH 5.
  "End of Note 2658786

  DATA:
    lv_tname             TYPE dd02l-tabname,
    lv_hcm_pa0006        TYPE abap_bool,
    lv_hcm_t549a         TYPE abap_bool,
    lv_hcm_t549q         TYPE abap_bool,
    lv_hcm_cu_read_rgdir TYPE abap_bool,
    ls_datum             TYPE ty_s_datum.

*--- Segment B ---------------------------------------------------------
  CLEAR j_1bdmexb.

* HCM Decoupling: Check HCM table availability
  IF cl_cos_utilities=>is_cloud( ) EQ abap_true.
*   Cloud-Edition
    lv_hcm_pa0006 = lv_hcm_t549a = lv_hcm_t549q = lv_hcm_cu_read_rgdir = abap_false.
  ELSE.
    SELECT SINGLE tabname FROM dd02l INTO lv_tname
      WHERE
        tabname  EQ lc_table_pa0006 AND
        as4local EQ 'A' ##WARN_OK.
    IF sy-subrc EQ 0.
      lv_hcm_pa0006 = abap_true.
    ENDIF.
    SELECT SINGLE tabname FROM dd02l INTO lv_tname
      WHERE
        tabname  EQ lc_table_t549a AND
        as4local EQ 'A' ##WARN_OK.
    IF sy-subrc EQ 0.
      lv_hcm_t549a = abap_true.
    ENDIF.
    SELECT SINGLE tabname FROM dd02l INTO lv_tname
      WHERE
        tabname  EQ lc_table_t549q AND
        as4local EQ 'A' ##WARN_OK.
    IF sy-subrc EQ 0.
      lv_hcm_t549q = abap_true.
    ENDIF.
    CALL FUNCTION 'FUNCTION_EXISTS'
      EXPORTING
        funcname           = lc_func_rgdir
      EXCEPTIONS
        function_not_exist = 1
        OTHERS             = 2.
    IF sy-subrc EQ 0.
      lv_hcm_cu_read_rgdir = abap_true.
    ENDIF.
  ENDIF.

* J_1BDMEXB-J_1BCRLF = UP_CRLF.
*  j_1bdmexb-j_1bcrlf = cr_lf.
  cnt_rec_perlot = cnt_rec_perlot + 1.
  cnt_records  = cnt_records  + 1.
  IF NOT j_1bdmexh1-h101 = '341'.
    cnt_rec_detail = cnt_rec_detail + 1.
  ENDIF.
  j_1bdmexb-b01   = j_1bdmexh1-h101.   " '341' for ITAU
  j_1bdmexb-b02   = cnt_lot.
  j_1bdmexb-b03   = '3'.
  j_1bdmexb-b04   = cnt_rec_detail.
  j_1bdmexb-b05   = 'B'.
  IF hlp_xcpdk IS INITIAL.
    j_1bdmexb-b07   = hlp_stkzn.       "CPF(1) or CGC(2)
    j_1bdmexb-b08   = hlp_taxcode.
  ELSE.
    DESCRIBE TABLE taxtab LINES lin.
    IF lin EQ 1.
* unique entry found: write the tax numbers to target arrays
      READ TABLE taxtab INDEX 1.
      IF hlp_laufk NE 'P'.             "No HR
* CGC/CPF distinction
        IF taxtab-stkzn IS INITIAL.
          j_1bdmexb-b07   = '2'.                            "CGC
          j_1bdmexb-b08   = taxtab-stcd1.
        ELSE.
          j_1bdmexb-b07   = '1'.                            "CPF
          j_1bdmexb-b08   = taxtab-stcd2.
        ENDIF.
      ELSE.                                                 "HR
        j_1bdmexb-b07   = '1'.
        j_1bdmexb-b08   = taxtab-stcd1.
      ENDIF.
* error case
    ELSE.
      READ TABLE itemtab INDEX 1.
      fimsg-msgid = '5K'.
      fimsg-msgv1 = reguh-lifnr.
      fimsg-msgv2 = itemtab-belnr.
      fimsg-msgv3 = TEXT-222.
      PERFORM message USING '010'.
    ENDIF.                             "Only one line
  ENDIF.                               "One time vendor done
  "note 1378829
*  j_1bdmexb-b09   = reguh-zstra.       "street + number
*  j_1bdmexb-b10   = '00000'.
*  perform dta_text_aufbereiten using j_1bdmexb-b09.
  IF hlp_laufk NE 'P'.
    SELECT SINGLE addrnumber street house_num1 house_num2
               FROM adrc INTO it_adrs
               WHERE addrnumber = reguh-zadnr.

    j_1bdmexb-b09   = it_adrs-street. "reguh-zstra.       "street + number
    PERFORM dta_text_aufbereiten USING j_1bdmexb-b09.

    "Begin of Note 2754668
    TRY.
        UNPACK it_adrs-house_num1 TO lv_house_num1.
      CATCH cx_sy_conversion_no_number.
        lv_house_num1 = '00000'.
    ENDTRY.

    it_adrs-house_num1 = lv_house_num1.
    "End of Note 2754668

    j_1bdmexb-b10   = it_adrs-house_num1.                   "'00000'.
    j_1bdmexb-b11   = it_adrs-house_num2.
    j_1bdmexb-b16   = reguh-zregi.       "Region
    PERFORM dta_text_aufbereiten USING j_1bdmexb-b16.
  ELSE.

    "Start of Note 1931476.
    CLEAR: lv_molga,et_rgdir,wa_rgdir,lv_abkrs,lv_fpper,lv_permo.

*   HCM Decoupling: Call HCM method or raise error
    IF lv_hcm_cu_read_rgdir EQ abap_true.
      CALL FUNCTION lc_func_rgdir
        EXPORTING
          persnr          = i_reguh-pernr
        IMPORTING
          molga           = lv_molga
        TABLES
          in_rgdir        = et_rgdir
        EXCEPTIONS
          no_record_found = 1
          OTHERS          = 2.
    ELSE.
      MESSAGE e002(idfi_br_paym_appl) WITH lc_func_rgdir.
    ENDIF.
    SORT et_rgdir BY seqnr DESCENDING.
    READ TABLE et_rgdir INTO wa_rgdir WITH KEY seqnr = i_reguh-seqnr.
    IF wa_rgdir-fpper EQ '000000' AND wa_rgdir-inper EQ '000000'. "OFFCYCLE...

*     HCM Decoupling: Select from HCM table or raise message
      IF lv_hcm_pa0006 EQ abap_true.
        SELECT SINGLE pernr stras hsnmr posta ort02 state FROM (lc_table_pa0006) INTO it_adrs
          WHERE
            pernr EQ i_reguh-pernr AND "SELECTING FROM 0006 FOR OFFCYCLE PERIOD
            begda LE wa_rgdir-fpbeg AND
            endda GE wa_rgdir-fpbeg.
      ELSE.
        MESSAGE e001(idfi_br_paym_appl) WITH lc_table_pa0006.
      ENDIF.

    ELSE. "ACTIVE PERIOD
      lv_abkrs = wa_rgdir-abkrs."PAYROLL AREA
      lv_fpper = wa_rgdir-fpper."PAYROLL YEAR + PAYROLL PERIOD

*     HCM Decoupling: Select from HCM table or raise message
      IF lv_hcm_t549a EQ abap_true.
        SELECT SINGLE permo FROM (lc_table_t549a) INTO lv_permo
          WHERE abkrs EQ lv_abkrs.
      ELSE.
        MESSAGE e001(idfi_br_paym_appl) WITH lc_table_t549a.
      ENDIF.
      IF sy-subrc EQ 0.
*GETTING THE BEGGINING AND END DATE OF THE EMPLOYEE
*       HCM Decoupling: Select from HCM table or raise message
        IF lv_hcm_t549q EQ abap_true.
          SELECT SINGLE begda endda FROM (lc_table_t549q) INTO ls_datum
            WHERE
              permo EQ lv_permo AND     "PERIOD PARAMETER
              pabrj EQ lv_fpper(4) AND  "PAYROLL YEAR
              pabrp EQ lv_fpper+4(2).   "PAYROLL PERIOD.
        ELSE.
          MESSAGE e001(idfi_br_paym_appl) WITH lc_table_t549q.
        ENDIF.
        IF sy-subrc EQ 0.
*         HCM Decoupling: Select from HCM table or raise message
          IF lv_hcm_pa0006 EQ abap_true.
            SELECT SINGLE pernr stras hsnmr posta ort02 state FROM (lc_table_pa0006) INTO it_adrs
              WHERE
                pernr EQ i_reguh-pernr AND "SELECTING FROM 0006 FOR ACTIVE PERIOD
                begda LE ls_datum-endda AND
                endda GE ls_datum-begda.
          ELSE.
            MESSAGE e001(idfi_br_paym_appl) WITH lc_table_pa0006.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.

    "End of Note 1931476.

    j_1bdmexb-b09 = it_adrs-street.
    PERFORM dta_text_aufbereiten USING j_1bdmexb-b09.
    j_1bdmexb-b10 = it_adrs-house_num1.
    j_1bdmexb-b11 = it_adrs-house_num2.
    j_1bdmexb-b12 = it_adrs-ort02.
    j_1bdmexb-b16 = it_adrs-state.
    PERFORM dta_text_aufbereiten USING j_1bdmexb-b16.
  ENDIF.
  CLEAR it_adrs.
  " note 1378829

  IF j_1bdmexh2-h205 NE '30'.                               "HR
    CLEAR j_1bdmexb-b12.
    j_1bdmexb-b12 = hlp_ort02.      "District
  ENDIF.
  PERFORM dta_text_aufbereiten USING j_1bdmexb-b12.
  j_1bdmexb-b13   = reguh-zort1.       "City
  PERFORM dta_text_aufbereiten USING j_1bdmexb-b13.
  j_1bdmexb-b14   = reguh-zpstl(5).    "Zip code
  PERFORM dta_text_aufbereiten USING j_1bdmexb-b14.
  j_1bdmexb-b15   = reguh-zpstl+6.     "complement
  PERFORM dta_text_aufbereiten USING j_1bdmexb-b15.
*  j_1bdmexb-b16   = reguh-zregi.       "Region " note 1378829
*  perform dta_text_aufbereiten using j_1bdmexb-b16.
*       set spaces/zeros corrrectly for febraban format
  IF j_1bdmexb-b01  NE '341'.
    TRANSLATE hlp_str USING ' 0'.
    CALL FUNCTION 'J_1B_FI_NETDUE'
      EXPORTING
        zfbdt   = regup-zfbdt
        zbd1t   = regup-zbd1t
        zbd2t   = regup-zbd2t
        zbd3t   = regup-zbd3t
      IMPORTING
        duedate = date
      EXCEPTIONS
        OTHERS  = 1.

    IF date < reguh-ausfd.                                  "n2888287
      MOVE reguh-ausfd TO date.                             "n2888287
    ENDIF.                                                  "n2888287

    hlp_str(8) = date+6(2).
    hlp_str+2(8) = date+4(2).
    hlp_str+4(8) = date(4).
    value = reguh-rbetr.
    REPLACE '.' WITH ' ' INTO value.
    CONDENSE value NO-GAPS.
    SHIFT value RIGHT DELETING TRAILING space.
    TRANSLATE value USING ' 0'.
    hlp_str+8(15) = value.
    hlp_str+83(30) = space.
*********** Febraban version 8.7 ************************
*    if par_fbla = '087'.
    IF par_fbla = '089'. "snote  2555959
      hlp_str+83(15) = space.
      IF NOT par_baav EQ space.            " with advice
        hlp_str+98(1)     =  '5'.
      ELSE.                                " w/o advice
        hlp_str+98(1)     =  '0'.
      ENDIF.
      hlp_str+99(6) = '000000'.
*      fill with ISPB code from the customizing table fiapbrd_ispb
*      based on the first 3 digits of the bank key
      SELECT SINGLE * FROM fiapbrd_ispb INTO ls_ispb_code
        WHERE bukrs = reguh-zbukr AND bank_key = reguh-zbnky(3).

      IF sy-subrc = 0.
        hlp_str+105(8) = ls_ispb_code-ispb_code.
      ENDIF.

    ENDIF.
***********Febraban version 8.7 ************************
    j_1bdmexb-b17  = hlp_str.

  ELSE.
    IF par_ver = '080'.
      CLEAR: j_1bdmexb-b17, lv_email_addr.
      SELECT smtp_addr FROM adr6 INTO lv_email_addr UP TO 1 ROWS WHERE addrnumber = reguh-zadnr ORDER BY PRIMARY KEY.
        j_1bdmexb-b17(100) = lv_email_addr.
      ENDSELECT.
    ENDIF.
  ENDIF.

  IF reguh-ubnkl(3) = '745'.
    j_1bdmexb-b17+99 = '000000'.
  ENDIF.
*----End of Segment B---------------------------------------------------
ENDFORM.                    "FILL_ITAU_SEGMENT_B


*-----------------------------------------------------------------------
* FORM FILL_WITH_BOLETO
* segement J of ITAU layout are filled
*-----------------------------------------------------------------------

FORM fill_itau_segment_j.

* DATA  UP_CRLF(2) TYPE X VALUE '0D0A'."carriage return + line feed
*  data cr_lf(2)   type c value cl_abap_char_utilities=>cr_lf.
  DATA: date LIKE sy-datum.
*begin of note 2469549
  DATA: obj_badi_rffobr_u TYPE REF TO fiapbr_rffobr_u.   "BAdI object
  DATA: ls_reguh       TYPE reguh,
        ls_regud       TYPE regud,
        ls_regup       TYPE regup,
        ls_file_header TYPE j_1bdmexh1,
        ls_lot_header  TYPE j_1bdmexh2.

  GET BADI obj_badi_rffobr_u.
*end of note 2469549
*---- Fill Segment J----------------------------------------------------
  CLEAR j_1bdmexj.

* J_1BDMEXJ-J_1BCRLF = UP_CRLF.
*  j_1bdmexj-j_1bcrlf = cr_lf.
  cnt_rec_perlot  = cnt_rec_perlot + 1.
  cnt_records     = cnt_records  + 1.
  cnt_rec_detail  = cnt_rec_detail + 1."counts details, no records

  j_1bdmexj-j01   = j_1bdmexh1-h101.   " '341' for ITAU
  j_1bdmexj-j02   = cnt_lot.
  j_1bdmexj-j03   = '3'.
  j_1bdmexj-j04   = cnt_rec_detail.
  j_1bdmexj-j05   = 'J'.
  j_1bdmexj-j06   = 000.
  j_1bdmexj-j07   = ls_barcode-esrnr(3).    "b,e.g.Itau=341
  IF ls_barcode-esrnr+3(1) IS INITIAL.
    j_1bdmexj-j08   = '9'.
  ELSE.
    j_1bdmexj-j08   = ls_barcode-esrnr+3(1).  "should be 9
  ENDIF.
  j_1bdmexj-j09   = ls_barcode-esrre+22(1). "Barcode ctrl digit
  CALL FUNCTION 'J_1B_FI_NETDUE'
    EXPORTING
      zfbdt   = regup-zfbdt
      zbd1t   = regup-zbd1t
      zbd2t   = regup-zbd2t
      zbd3t   = regup-zbd3t
    IMPORTING
      duedate = date
    EXCEPTIONS
      OTHERS  = 1.
  j_1bdmexj-j13(2)      = date+6(2).
  j_1bdmexj-j13+2(2)    = date+4(2).
  j_1bdmexj-j13+4(4)    = date(4).
* Old procedure without due date factor
  IF ls_barcode-esrre+23(1) CA ' 0xXnN' AND
  NOT ls_barcode-esrre+23(4) = '0000'.
    IF ls_barcode-esrre+23     = space OR
*     old data from 30F
      ( ls_barcode-esrre+23(3)   = 'x' OR
        ls_barcode-esrre+23(3)   = 'X' ).
      j_1bdmexj-j10       = ls_barcode-amount.               "Amount

    ELSE.
      j_1bdmexj-j10       = '000'.
    ENDIF.

* New procedure with due date factor
  ELSE.
    j_1bdmexj-j10(4)      = ls_barcode-esrre+23(4).
    IF ls_barcode-esrnr+10(1)  = space.
      j_1bdmexj-j10+4     = ls_barcode-amount.                "Amount
    ELSE.
      j_1bdmexj-j10+4     = '0000000000'.
    ENDIF.
*   Overwrite
    IF ls_barcode-esrre+23(4) NE '0000'.
      date                = '20000703'.
      date                = date + ls_barcode-esrre+23(4) - 1000.
      j_1bdmexj-j13(2)      = date+6(2).
      j_1bdmexj-j13+2(2)    = date+4(2).
      j_1bdmexj-j13+4(4)    = date(4).
    ENDIF.

  ENDIF.

  j_1bdmexj-j11(5)      = ls_barcode-esrnr+4(5).      "Campo Livre
  j_1bdmexj-j11+5(10)   = ls_barcode-esrre(10).
  j_1bdmexj-j11+15(10)  = ls_barcode-esrre+11(10).
* j_1bdmexj-j12         = reguh-znme1.            " vendor name
  j_1bdmexj-j12         = reguh-koinh.            " vendor name
  PERFORM dta_text_aufbereiten USING j_1bdmexj-j12.
  j_1bdmexj-j14         = regup-dmbtr.           "Nominal value
* Note 881128
*     Reductions (discount + rebate = credit note)
* In case of Itau and Feberaban format the discount amount is always
* filled with discount + withholding tax amount regardless of the
* boleto amount
*note 1044108
  IF ls_barcode-amount EQ '' OR ls_barcode-amount EQ 0 OR ls_barcode-amount EQ reguh-rwbtr.
    j_1bdmexj-j15         = regup-wrbtr - reguh-rwbtr.
  ELSE.
    IF NOT ( regup-qbshb IS INITIAL OR regup-qbshh IS INITIAL ).
      j_1bdmexj-j15 = regup-wrbtr - reguh-rwbtr.
    ELSE.
*            j_1bdmexj-j15         = ls_barcode-amount - reguh-rwbtr.
      "            j_1bdmexj-j15         = reguh-rskon. "Note 1769249
      j_1bdmexj-j15         = ls_barcode-amount - reguh-rwbtr. "2394906
    ENDIF.
  ENDIF.
  j_1bdmexj-j16         = 0.           "interest
  j_1bdmexj-j17(2)      = reguh-valut+6(2).
  j_1bdmexj-j17+2(2)    = reguh-valut+4(2).
  j_1bdmexj-j17+4(4)    = reguh-valut(4).
  j_1bdmexj-j18         = reguh-rbetr. "paid amount
  j_1bdmexj-j19         = 0.           " Filler
*     Febraban
  IF reguh-ubnkl(3) NE '341'.
    IF reguh-waers NE t001-waers.
*      foreign amount/febraban
      j_1bdmexj-j19         = reguh-rwbtr.
      PERFORM for_curr_check USING reguh-waers t001-waers
             CHANGING j_1bdmexj-j19.


    ENDIF.
  ENDIF.
*
  j_1bdmexj-j20         = reguh-vblnr. "Seu Numero
  j_1bdmexj-j21         = space.       "Filler
*     Carteira and Bank duplicata number(XX..X-D) in REGUP-J_DUPLNR,
*     separated by '/', '-' or '.'.
  REPLACE '/' WITH '.' INTO regup-xref3.
  REPLACE '-' WITH '.' INTO regup-xref3.
  CASE reguh-ubnkl(3).
    WHEN '341'.
      j_1bdmexj-j21         = space.   "Filler
      SPLIT regup-xref3 AT '.' INTO carteira j_1bdmexj-j22.
*         Only number w/o carteira entered.
      IF j_1bdmexj-j22 = space.
        j_1bdmexj-j22 = carteira.
      ENDIF.
      PERFORM dta_text_aufbereiten USING j_1bdmexj-j22.
    WHEN OTHERS.
      j_1bdmexj-j22         = space.   "Filler
      j_1bdmexj-j22+7(2)      = '09'.                       "09 - REAL
      SPLIT regup-xref3 AT '.' INTO carteira j_1bdmexj-j21.
*         Only number w/o carteira entered.
      IF j_1bdmexj-j21 = space.
        j_1bdmexj-j21 = carteira.
      ENDIF.
      PERFORM dta_text_aufbereiten USING j_1bdmexj-j21.
  ENDCASE.
  j_1bdmexj-j23         = space.    "blank, sending
*begin of note 2469549
  CLEAR: ls_reguh, ls_regud, ls_regup, ls_file_header, ls_lot_header.
  ls_reguh = reguh.
  ls_regud = regud.
  ls_regup = regup.
  ls_file_header = j_1bdmexh1.
  ls_lot_header = j_1bdmexh2.
  TRY.
      CALL BADI obj_badi_rffobr_u->change_segment_j
        EXPORTING
          is_j_1bdmexh1  = ls_file_header
          is_reguh       = ls_reguh
          is_regud       = ls_regud
          is_regup       = ls_regup
          iv_feb_version = par_fbla
          iv_itau_ver    = par_ver
          iv_brad_ver    = par_brla
          is_j_1bdmexh2  = ls_lot_header
        CHANGING
          cs_j_1bdmexj   = j_1bdmexj.
    CATCH cx_sy_dyn_call_illegal_method.
  ENDTRY.
*End of note 2469549
*-----End of Segment J--------------------------------------------------

ENDFORM.                    "FILL_ITAU_SEGMENT_J

*&---------------------------------------------------------------------*
*& Form fill_itau_segment_o
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM fill_itau_segment_o .

  DATA: lv_linha_o TYPE c LENGTH 240.
  DATA: lv_digito TYPE c LENGTH 1.
  DATA: lv_barcode TYPE fac_glo_ref1.
  DATA lv_netdt TYPE bseg-netdt.

  CLEAR: zsfi_segmento_o.


  DATA: lv_name1 TYPE lfa1-name1.
  SELECT SINGLE name1
    FROM lfa1
    INTO lv_name1
    WHERE lifnr = regup-lifnr.

  cnt_rec_perlot  = cnt_rec_perlot + 1.
  cnt_records     = cnt_records  + 1.
  cnt_rec_detail  = cnt_rec_detail + 1."counts details, no records

  "@@ Busca codigo de barra digitado
  SELECT SINGLE netdt glo_ref1
    FROM bseg
    INTO ( lv_netdt , lv_barcode )
    WHERE belnr = regup-belnr
      AND bukrs = regup-bukrs
      AND gjahr = regup-gjahr
      AND buzei = regup-buzei.

**  CALL FUNCTION 'CALCULATE_CHECK_DIGIT_MOD10'
**    EXPORTING
**      number_part = lv_barcode
**    IMPORTING
**      check_digit = lv_digito.
**
**  CONCATENATE lv_barcode lv_digito INTO lv_barcode.

  zsfi_segmento_o-codigo_banco = j_1bdmexh1-h101.
  zsfi_segmento_o-codigo_lote = cnt_lot.
  zsfi_segmento_o-tipo_registro = '3'.
  zsfi_segmento_o-numero_reg = cnt_rec_detail.
  zsfi_segmento_o-segmento = 'O'.
  zsfi_segmento_o-tipo_movimento = '000'.
  zsfi_segmento_o-codigo_barras = lv_barcode.
  zsfi_segmento_o-nome = lv_name1.

  zsfi_segmento_o-data_vencto = lv_netdt+6(2) && lv_netdt+4(2) && lv_netdt(4).
  zsfi_segmento_o-moeda = 'REA'.

  zsfi_segmento_o-valor_apagar = reguh-rwbtr.
  zsfi_segmento_o-data_pagto = reguh-ausfd+6(2) && reguh-ausfd+4(2) && reguh-ausfd(4).
  zsfi_segmento_o-nota_fiscal = regup-xblnr.
  zsfi_segmento_o-seu_numero = regup-vblnr && regup-budat(4) && regup-buzei .



ENDFORM.

*&---------------------------------------------------------------------*
*& Form fill_itau_segment_o
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM fill_segment_o .

  DATA: lv_barcode TYPE fac_glo_ref1.
  DATA: lv_digito TYPE c.

  CLEAR: j_1bdmexo.

  cnt_rec_perlot  = cnt_rec_perlot + 1.
  cnt_records     = cnt_records  + 1.
  cnt_rec_detail  = cnt_rec_detail + 1."counts details, no records

  j_1bdmexo-o01   = j_1bdmexh1-h101.
  j_1bdmexo-o02   = cnt_lot.
  j_1bdmexo-o03   = '3'.
  j_1bdmexo-o04   = cnt_rec_detail .
  j_1bdmexo-o05   = 'O'.
  j_1bdmexo-o06   = 0.
  j_1bdmexo-o07   = 000.

  "@@ Busca codigo de barra digitado
  SELECT SINGLE glo_ref1
    FROM bseg
    INTO lv_barcode
    WHERE belnr = regup-belnr
      AND bukrs = regup-bukrs
      AND gjahr = regup-gjahr
      AND buzei = regup-buzei.


  j_1bdmexo-o08   = lv_barcode(11) && lv_barcode+12(11) && lv_barcode+24(11)  && lv_barcode+36(11).
  CONDENSE j_1bdmexo-o08.

  DATA: lv_name1 TYPE lfa1-name1.
  SELECT SINGLE name1
    FROM lfa1
    INTO lv_name1
    WHERE lifnr = regup-lifnr.

  IF strlen( lv_name1 ) > 30.
    j_1bdmexo-o09 = lv_name1(30).
  ELSE.
    j_1bdmexo-o09 = lv_name1.
  ENDIF.

  DATA lv_netdt TYPE bseg-netdt.
  SELECT SINGLE netdt
    FROM bseg
    INTO lv_netdt
    WHERE bukrs = regup-bukrs
       AND belnr = regup-belnr
       AND gjahr = regup-gjahr
       AND buzei = regup-buzei.

  j_1bdmexo-o10 = lv_netdt+6(2) && lv_netdt+4(2) && lv_netdt(4).
  CONDENSE j_1bdmexo-o10.

*  j_1bdmexo-o11 = regup-budat+6(2) && regup-budat+4(2) && regup-budat(4).
  j_1bdmexo-o11 = reguh-augdt+6(2) && reguh-augdt+4(2) && reguh-augdt(4).
  CONDENSE j_1bdmexo-o11.

  j_1bdmexo-o12 = reguh-rwbtr.

  "DATA(lv_posi) = strlen( reguh-zaldt ) - 4.
  " Anderson Macedo - 21/08/22
  IF reguh-ubnkl(3) EQ '745'.
    j_1bdmexo-o13 = reguh-vblnr && reguh-zaldt(4).
    j_1bdmexo-o13+14(1) = '0'.
  ELSE.
    j_1bdmexo-o13 = reguh-vblnr && reguh-zaldt(4) && '001' .
  ENDIF.

ENDFORM.

*-----------------------------------------------------------------------
FORM fill_header_itau.

* DATA  UP_CRLF(2) TYPE X VALUE '0D0A'."carriage return + line feed
*  data cr_lf(2)   type c value cl_abap_char_utilities=>cr_lf.

*     Fill data set H1
  CLEAR: j_1bdmexh1, j_1bdmext1.       "Data set: Header,Trailer

* J_1BDMEXH1-J_1BCRLF = UP_CRLF.
*  j_1bdmexh1-j_1bcrlf = cr_lf.
  j_1bdmexh1-h101   = reguh-ubnkl(3).  " '341' for ITAU
  j_1bdmexh1-h102   = cnt_lot.         " here '0000'
  j_1bdmexh1-h103   = '0'.
  j_1bdmexh1-h104(6)   = space.                             " 6 blanks
  CASE reguh-ubnkl(3).
    WHEN '341'.                        "Itau
      IF par_ver EQ '050'.
        j_1bdmexh1-h104+6(3) = '050'.
      ELSEIF par_ver EQ '080'.
        j_1bdmexh1-h104+6(3) = '080'.
      ELSE.
        j_1bdmexh1-h104+6(3) = '020'.
      ENDIF.

    WHEN OTHERS.
      j_1bdmexh1-h104+6(3) = space.    "Febraban
  ENDCASE.
  j_1bdmexh1-h105   = '2'.
  j_1bdmexh1-h106   = j_1bwfield-cgc_number.
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
  IF sy-subrc <> 0.                    "found none
    SELECT * FROM t045t                "second chance
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

  j_1bdmexh1-h117(2)    = sy-datum+6(2).                    "dd
  j_1bdmexh1-h117+2(2)  = sy-datum+4(2).                    "mm
  j_1bdmexh1-h117+4(4)  = sy-datum(4). "yyyy
  j_1bdmexh1-h118       = sy-uzeit.
*     REGUT-TSDAT and REGUT-TSTIM, respectively, in case payment run
*     date run date and time are required instead of
*     file creation program run date.

  IF reguh-ubnkl(3) NE '341'.          "Febraban
    IF hlp_resultat+2(6) EQ 0.
      PERFORM get_next_number USING    hlp_renum
                                       hlp_resultat.
    ENDIF.
    j_1bdmexh1-h119(6)   = hlp_resultat+2(6).        "File number
    CASE par_fbla.
      WHEN '030'.
        j_1bdmexh1-h119+6(3) = '030'.    "File version 3.0
      WHEN '040'.
        j_1bdmexh1-h119+6(3) = '040'.    "File version 4.0
      WHEN '050'.
        j_1bdmexh1-h119+6(3) = '050'.    "File version 5.0
*      WHEN '087'.
*        J_1BDMEXH1-H119+6(3) = '087'.    "File version 8.7
      WHEN '089'.                       " snote 2555959
        j_1bdmexh1-h119+6(3) = '089'.    " snote 2555959 "File version 8.7
    ENDCASE.

  ENDIF.
*--File Header: end of filling------------------------------------------

  IF reguh-ubnkl(3) <> '745'.
    j_1bdmexh1-h121+20   = hlp_resultat.
  ENDIF.


ENDFORM.                    "FILL_HEADER_ITAU
*&---------------------------------------------------------------------*
*&      Form  FILL_HEADER_BRADESCO
*&---------------------------------------------------------------------*
*       text                                                           *
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM fill_header_bradesco.


* DATA UP_CRLF(2) TYPE X VALUE '0D0A'. "carriage return + line feed
*  data cr_lf(2)   type c value cl_abap_char_utilities=>cr_lf.
  CLEAR: j_1bdmeah, j_1bdmeat.         "Data set: Header,Trailer

* J_1BDMEAH-J_1BCRLF = UP_CRLF.
*  j_1bdmeah-j_1bcrlf = cr_lf.

  j_1bdmeah-h01     = '0'.
  SELECT * FROM t045t                  "Company ID at bank
    WHERE bukrs = reguh-zbukr
    AND   zlsch = reguh-rzawe
    AND   hbkid = reguh-hbkid
    AND   hktid = reguh-hktid.
    IF sy-subrc EQ 0.
      EXIT.
    ENDIF.
  ENDSELECT.
  IF sy-subrc <> 0.                    "found none
    SELECT * FROM t045t                "second chance
      WHERE bukrs = reguh-zbukr
      AND   zlsch = space              "no payment method maint.
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

*  J_1BDMEAH-H02     = T045T-DTAID.     "Company ID at bank
  j_1bdmeah-h02     = t045t-dtaid(9).     "Company ID at bank
  j_1bdmeah-h03     = '2'.             " CGC and not CPF
  j_1bdmeah-h04     = j_1bwfield-cgc_number.
  j_1bdmeah-h05     = hlp_sadr-name1.
  PERFORM dta_text_aufbereiten USING j_1bdmeah-h05.
  j_1bdmeah-h06     = '20'.
  j_1bdmeah-h07     = '1'.
  IF hlp_resultat+3(5) EQ 0.
    PERFORM get_next_number USING    hlp_renum
                                     hlp_resultat.
  ENDIF.
  j_1bdmeah-h08(5)  = hlp_resultat+3(5).       "reference number
  j_1bdmeah-h10     = sy-datum.
  j_1bdmeah-h11     = sy-uzeit.
*     REGUT-TSDAT and REGUT-TSTIM, respectively, in case payment run
*     date run date and time are required instead of
*     file creation program run date.
  j_1bdmeah-h16     = hlp_resultat.
  j_1bdmeah-h19     = '0000001'.       "first record

  SHIFT j_1bdmeah-h12 LEFT DELETING LEADING '0'.            "N1804255

ENDFORM.                               " FILL_HEADER_BRADESCO

*&---------------------------------------------------------------------*
*&      Form  FILL_HEADER_BRADESCO_HR
*&---------------------------------------------------------------------*
*       text                                                           *
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM fill_header_bradesco_hr.

* DATA UP_CRLF(2) TYPE X VALUE '0D0A'. "carriage return + line feed
*  data cr_lf(2)   type c value cl_abap_char_utilities=>cr_lf.

  CLEAR: j_1bdmeahrh, j_1bdmeahrt.

* J_1bdmeahrh-J_1BCRLF = UP_CRLF. "Campo c/retorno e avanço de linha
*  j_1bdmeahrh-j_1bcrlf = cr_lf. "Campo c/retorno e avanço de linha

  j_1bdmeahrh-h01 = '0'.               "Identificação Registro Header
  j_1bdmeahrh-h02 = '1'.            "Identificação Fita Remessa/Retorno
  j_1bdmeahrh-h03 = 'REMESSA'.      "Identificação p/ext.Remessa/Retorno
  j_1bdmeahrh-h04 = '03'.              "Identificação do Tipo Serviço
  j_1bdmeahrh-h05 = 'CREDITO C/C'.  "Identificação p/ext. o Tipo de Se
  j_1bdmeahrh-h06 = reguh-ubnkl+4(5).  "Código da Ag.Empresa tem C/C

* Note 839332
* j_1bdmeahrh-h07 should be filled differently depending on
* whether the company is a public, private or mixed enterprise
  IF par_razo NE '00000'.
    j_1bdmeahrh-h07 = par_razo.           "Número do Razão da C/C.
  ELSE.
    j_1bdmeahrh-h07 = '07050'.           "Número do Razão da C/C.
  ENDIF.

* Note 586193 HR only requires bank account check digit(1)

  CALL FUNCTION 'READ_ACCOUNT_DATA'
    EXPORTING
      i_bankn = reguh-ubknt
      i_bkont = reguh-ubkon
    IMPORTING
      e_bankn = regud-obknt
      e_cntr2 = j_1bdmeahrh-h09.

  j_1bdmeahrh-h08 = regud-obknt. "Número da Conta Corrente

  j_1bdmeahrh-h10 = space.             "Identificação da Empresa no CREC
  j_1bdmeahrh-h11 = space.             "1 Espaço em Branco

  SELECT * FROM t045t                  "Company ID at bank
    WHERE bukrs = reguh-zbukr
    AND   zlsch = reguh-rzawe
    AND   hbkid = reguh-hbkid
    AND   hktid = reguh-hktid.
    IF sy-subrc EQ 0.
      EXIT.
    ENDIF.
  ENDSELECT.
  IF sy-subrc <> 0.
    "found none
    SELECT * FROM t045t                "second chance
      WHERE bukrs = reguh-zbukr
      AND   zlsch = space              "no payment method maint.
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

  j_1bdmeahrh-h12 = t045t-dtaid(5).    "Código Fornecido Pelo Banco
  j_1bdmeahrh-h13 = t001-butxt.        "Nome da Empresa
  j_1bdmeahrh-h14 = reguh-ubnkl(3).    "Nº do Banco na Camara de Comp.

  SELECT SINGLE * FROM bnka
    WHERE banks = reguh-zbnks AND
          bankl = reguh-zbnky.

  j_1bdmeahrh-h15 = bnka-banka.        "Nome por Extenso do Banco
  CONCATENATE sy-datum+6(2)
              sy-datum+4(2)
              sy-datum(4)
              INTO j_1bdmeahrh-h16.    "Data da Gravação do Arquivo
  j_1bdmeahrh-h17 = '01600'.           "Densidade da Gravação
  j_1bdmeahrh-h18 = 'BPI'.             "Unidade de Densidade de Gravação
*begin of note 2359292
*  concatenate reguh-valut+6(2)
*              reguh-valut+4(2)
*              reguh-valut(4)
*              into j_1bdmeahrh-h19.    "Data do Débito na Conta Empresa
  CONCATENATE reguh-ausfd+6(2)
              reguh-ausfd+4(2)
              reguh-ausfd(4)
              INTO j_1bdmeahrh-h19.    "Data do Débito na Conta Empresa
*end of note 2359292
  j_1bdmeahrh-h20 = space.             "Identificação da Moeda
  j_1bdmeahrh-h21 = 'N'.               "Identificação do Século
  j_1bdmeahrh-h22 = space.             "74 Espaços em Branco
  j_1bdmeahrh-h23 = '000001'.          "Nº Sequencial do Registro



ENDFORM.                               " FILL_HEADER_BRADESCO_HR





*&---------------------------------------------------------------------*
*&      Form  DETAILS_BRADESCO
*&---------------------------------------------------------------------*
*       text                                                           *
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM details_bradesco.


  DATA: hlp_code(14) TYPE n.
  DATA: lin TYPE i.


* DATA: UP_CRLF(2) TYPE X VALUE '0D0A'."carriage return + line feed
*  data cr_lf(2)   type c value cl_abap_char_utilities=>cr_lf.
  DATA: ktonum(7) TYPE n.


  cnt_records          = cnt_records  + 1.
  CLEAR j_1bdmeaa.

* J_1BDMEAA-J_1BCRLF   = UP_CRLF.
*  j_1bdmeaa-j_1bcrlf   = cr_lf.

*     Data not pending on payment_form ---------------------------------
  j_1bdmeaa-a01        = '1'.
*  tax number: no one-time-vendor.
*  if hlp_xcpdk is initial.
  j_1bdmeaa-a02        = hlp_stkzn.

  IF hlp_stkzn = 1.                                       "CPF
    j_1bdmeaa-a03(9)    = hlp_taxcode+3(9).
    j_1bdmeaa-a03+9(4)  = '0000'.
    j_1bdmeaa-a03+13(2) = hlp_taxcode+12(2).
  ELSE.                                                   "CGC
    j_1bdmeaa-a03        = hlp_taxcode.
  ENDIF.
  j_1bdmeaa-a04        = reguh-koinh.
  PERFORM dta_text_aufbereiten USING j_1bdmeaa-a04.
  j_1bdmeaa-a05        = reguh-zstra.
  PERFORM dta_text_aufbereiten USING j_1bdmeaa-a05.
  j_1bdmeaa-a06        = reguh-zpstl(5). "Zip code
  PERFORM dta_text_aufbereiten USING j_1bdmeaa-a06.
  j_1bdmeaa-a07        = reguh-zpstl+6."complement
  PERFORM dta_text_aufbereiten USING j_1bdmeaa-a07.

  j_1bdmeaa-a13        = reguh-vblnr.
  j_1bdmeaa-a17        = reguh-vblnr.

*     Gross, but excluding credit memo
  j_1bdmeaa-a21        = reguh-rbetr + reguh-rskon.

* In the layout, the field length is 10. So, we cannot have amount greater that 10 positions
* if the amount it greater than 100 mil (10 positions), then clear it.
  IF j_1bdmeaa-a21 >= 10000000000.                    " 2736861 n2953844
    CLEAR j_1bdmeaa-a21.
  ENDIF.

  j_1bdmeaa-a22        = reguh-rbetr.

  j_1bdmeaa-a25 = '04'.
  j_1bdmeaa-a28        = payment_form.
  j_1bdmeaa-a29        = reguh-valut.
  j_1bdmeaa-a33        = 0.
  j_1bdmeaa-a34        = 00.
  PERFORM determine_a39.

*   Fill Conta complementar
  j_1bdmeaa-a41+64(7) = '0000000'.

  IF payment_form = 01 OR
     payment_form = 05.
    j_1bdmeaa-a41+63(1)  = '1'.                             " hw0438628
  ENDIF.


  j_1bdmeaa-a42        = cnt_records + 1.
*     End data not pending on payment form -----------------------------

  IF payment_form = 30 OR payment_form = 31.
    PERFORM get_barcode.
    PERFORM boleto_data.               "REGUP
  ELSE.
    PERFORM further_payment_data.      "only REGUH
  ENDIF.

  IF NOT j_1bdmeaa-a23 IS INITIAL.     "Discount, Rebate
    j_1bdmeaa-a20 = reguh-ausfd.
  ENDIF.

ENDFORM.                               " DETAILS_BRADESCO


*&---------------------------------------------------------------------*
*&      Form  DETAILS_BRADESCO_HR
*&---------------------------------------------------------------------*
*       text                                                           *
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM details_bradesco_hr.

* DATA: UP_CRLF(2) TYPE X VALUE '0D0A'."carriage return + line feed
*  data cr_lf(2)   type c value cl_abap_char_utilities=>cr_lf.
  DATA: hlp_acc(7) TYPE c.
  DATA: hlp_char7(7) TYPE c.     "Note 1549382

  cnt_records          = cnt_records  + 1.
  CLEAR j_1bdmeahra.

* J_1bdmeahra-J_1BCRLF   = UP_CRLF.
*  j_1bdmeahra-j_1bcrlf   = cr_lf.

*     Data not pending on payment_form ---------------------------------
  j_1bdmeahra-a01 = '1'.               "Identificação Registro Transação
  j_1bdmeahra-a02 = space.             "61 Espaços em Branco

  j_1bdmeahra-a03 = partner_agency.   "Código da Ag. Funcionário tem C/C
  j_1bdmeahra-a04 = '07050'.           "Número do Razão da C/C
  SPLIT reguh-zbnkn AT '-'
    INTO hlp_char7           "Número da C/C do Funcionário note 1549382
         j_1bdmeahra-a06.              "Digito da Conta Corrente

  j_1bdmeahra-a05 = hlp_char7.         "Note 1549382
  j_1bdmeahra-a07 = space.             "2 Espaços em Branco
  j_1bdmeahra-a08 = reguh-znme1.       "Nome do Funcionário Creditado
  j_1bdmeahra-a09 = reguh-pernr.       "Código ou Chapa do Funcionário
  UNPACK reguh-rbetr TO j_1bdmeahra-a10.
  "Valor a Creditar p/ o Funcionário
  j_1bdmeahra-a11 = '298'.             "Identificação do Tipo de Serviço
  j_1bdmeahra-a12 = space.             "8 Espaços em Branco
  j_1bdmeahra-a13 = space.             "44 espaços em branco
  j_1bdmeahra-a14 = cnt_records + 1.   "Número seq. do registro do arqu

ENDFORM.                    "DETAILS_BRADESCO_HR

*&---------------------------------------------------------------------*
*&      Form  DETERMINE_A39
*&---------------------------------------------------------------------*
*       text                                                           *
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM determine_a39.
  CASE payment_form.
    WHEN '01'.                                              "CC
*     do nothing
    WHEN '02'.
      j_1bdmeaa-a39        =       regup-sgtxt.     "Instrucao
      PERFORM dta_text_aufbereiten USING j_1bdmeaa-a39.
    WHEN '03' OR '07' OR '08'. "DOC, CIP, STR
*     Need further explanations, current knowledge is mail kazuo 060896
*     J_1BDMEAA-A39(1)     =      'C'. "See mail Kazuo
*     J_1BDMEAA-A39+1(6)   =      '000000'.
*     J_1BDMEAA-A39+7(2)   =      '07'."See mail Kazou, Au06
*     J_1BDMEAA-A39+9(1)   =      SPACE.
************************************************************************
* 26.04.2001 - According to a Mail from Bradesco, for DOCs between
* companies with the same CGC number, the field Tipo do Doc is filled
* with 'D', and Código de Finalidade de Doc with '01'.
* For further details please look into Note 399292
************************************************************************

      PERFORM compare_cnpj USING j_1bdmeah-h04
                                 j_1bdmeaa-a03
                           CHANGING hlp_cnpj_check.

*    Comparison and selection of type of DOC
      IF hlp_cnpj_check = 'X'.
        j_1bdmeaa-a39(1)     =      'D'.           "note 399292
        j_1bdmeaa-a39+1(6)   =      '000000'.      "doc w/o CPMF
        j_1bdmeaa-a39+7(2)   =      '01'.
        j_1bdmeaa-a39+9(2)   =      '01'.
      ELSE.                                        "note 399292
        j_1bdmeaa-a39(1)     =      'C'.           "doc w/ CPMF
        j_1bdmeaa-a39+1(6)   =      '000000'.
        j_1bdmeaa-a39+7(2)   =      '07'.
        j_1bdmeaa-a39+9(2)   =      '01'.
      ENDIF.
    WHEN '30'.                         "Tit. nosso banc
*      do nothing
    WHEN '31'.                         "Tit outro banco
*     Campo livre
      PERFORM get_barcode.
      j_1bdmeaa-a39(5)      = ls_barcode-esrnr+4(5).
      j_1bdmeaa-a39+5(10)   = ls_barcode-esrre(10).
      j_1bdmeaa-a39+15(10)  = ls_barcode-esrre+11(10).
*     Control digit
      j_1bdmeaa-a39+25(1)   = ls_barcode-esrre+22(1).
      j_1bdmeaa-a39+26(1)   = ls_barcode-esrnr+3(1).        "usually 9

  ENDCASE.
ENDFORM.                               " DETERMINE_A39
*&---------------------------------------------------------------------*
*&      Form  FILL_TRAILER_ITAU
*&---------------------------------------------------------------------*
*       text                                                           *
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM fill_trailer_itau.

*  Datensatz file trailer füllen

* DATA UP_CRLF(2) TYPE X VALUE '0D0A'. "carriage return + line feed
*  data cr_lf(2)   type c value cl_abap_char_utilities=>cr_lf.
* J_1BDMEXT1-J_1BCRLF = UP_CRLF.
*  j_1bdmext1-j_1bcrlf = cr_lf.
  j_1bdmext1-t101    = reguh-ubnkl(3). " '341' for ITAU
  j_1bdmext1-t102   = '9999'.
  j_1bdmext1-t103   = '9'.
  j_1bdmext1-t104   = space.
  j_1bdmext1-t105   = cnt_lot.

*  COUNT ALL RECORDS, I.E. ALL ITEMS, LOT HEADERS AND TRAILERS, FILE
*  HEADER AND TRAILER.
  j_1bdmext1-t106   = cnt_records + 2 * cnt_lot + 2.

  CLEAR:
  j_1bdmext1-t107.
  IF reguh-ubnkl(3) NE '341'.      "note 1580422
    j_1bdmext1-t107(6) = '000000'.
  ENDIF.
ENDFORM.                    "FILL_TRAILER_ITAU
*&---------------------------------------------------------------------*
*&      Form  FILL_TRAILER_BRADESCO
*&---------------------------------------------------------------------*
*       text                                                           *
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM fill_trailer_bradesco.


* DATA UP_CRLF(2) TYPE X VALUE '0D0A'. "carriage return + line feed
*  data cr_lf(2)   type c value cl_abap_char_utilities=>cr_lf.
* J_1BDMEAT-J_1BCRLF = UP_CRLF.
*  j_1bdmeat-j_1bcrlf = cr_lf.
  j_1bdmeat-t01       =  '9'.
  j_1bdmeat-t02       =  cnt_records + 2.               "plus H+T
  j_1bdmeat-t03       =  sum_abschluss.

  j_1bdmeat-t05       =  cnt_records + 2.

ENDFORM.                               " FILL_TRAILER_BRADESCO


*&---------------------------------------------------------------------*
*&      Form  FILL_TRAILER_BRADESCO_HR
*&---------------------------------------------------------------------*
*       text                                                           *
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM fill_trailer_bradesco_hr.

* DATA UP_CRLF(2) TYPE X VALUE '0D0A'. "carriage return + line feed
*  data cr_lf(2)   type c value cl_abap_char_utilities=>cr_lf.
* J_1bdmeahrt-J_1BCRLF = UP_CRLF.
*  j_1bdmeahrt-j_1bcrlf = cr_lf.

  j_1bdmeahrt-t01 = '9'.             "Indentificação do Registro Traille
  j_1bdmeahrt-t02 = sum_abschluss.     "Valor Total
  j_1bdmeahrt-t03 = space.             "Filler
  j_1bdmeahrt-t04 = cnt_records + 2.   "Número Sequencial

ENDFORM.                               " FILL_TRAILER_BRADESCO_HR



*&---------------------------------------------------------------------*
*&      Form  Sortbank
*&---------------------------------------------------------------------*
*       text                                                           *
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*

FORM sortbank.

* For payment forms (sort parameter in DME include)
* SPB Changes
* Prepare some data
** Identify Vendor (payer) Tax ID
  PERFORM find_vendor_cnpj.
** Compare Tax IDs between Vendor and Company
*** Get Company Tax ID
  PERFORM read_branch_data.
*** Do comparison
*** When equal HLP_CNPJ_CHECK = 'X'
  IF hlp_stkzn = '2'.
    PERFORM compare_cnpj  USING j_1bwfield-cgc_number
                                  hlp_taxcode
                         CHANGING hlp_cnpj_check.
  ELSE.
    hlp_cnpj_check = ' '.
  ENDIF.
  PERFORM weisungsschluessel_lesen.
** IDENTIFY WHERE IS PAYMENT FORM
** CASE 1: ALREADY SPECIFIED
  IF t042z-txtsl = '01'
  OR t042z-txtsl = '02'
  OR t042z-txtsl = '05'                 "Only Bradesco
  OR t042z-txtsl = '10'.
    payment_form = t042z-txtsl.
* LOOK FOR PAYMENT FORM IN OTHER PLACES
* CASE 2: IN PAYMENT INSTRUCTION
** GET PAYMENT FORM FROM INSTRUCTION KEY
  ELSEIF reguh-dtws4 NE space.
    DATA pf(2) TYPE n.
    PERFORM get_pf_from_ik CHANGING pf.
    payment_form = pf.
* Case 3: Only in Payment Method
  ELSEIF reguh-rzawe NE space.
    PERFORM get_pf_from_pm
    USING hlp_cnpj_check CHANGING pf.
    payment_form = pf.
* Case 4: Not specified at all or wrong customizing
  ELSE.
    IF reguh-ubnkl(3) = reguh-zbnkl(3).
      payment_form = '01'.                                  "CC
    ELSE.
      payment_form = '03'.                                  "DOC
    ENDIF.
  ENDIF.
ENDFORM.                    "SORTBANK

************************************************************************
************************************************************************
************************************************************************

FORM sortboleto.

  CLEAR ls_barcode.
*    Only relevant for boleto payments
  IF NOT regup-esrnr IS INITIAL.       "Boleto/Barcode
    CALL FUNCTION 'J_1B_BARCODE_REVERT'
      EXPORTING
        iv_esrre            = regup-esrre
        iv_esrnr            = regup-esrnr
        iv_esrpz            = regup-esrpz
        iv_dmbtr            = regup-dmbtr
      IMPORTING
        ev_reverted_barcode = ls_barcode-barcode.

    IF NOT ls_barcode-barcode IS INITIAL.
      PERFORM convert_barcode USING    ls_barcode-barcode
                              CHANGING ls_barcode-esrre
                                       ls_barcode-esrnr.
    ELSE.
      ls_barcode-esrnr = regup-esrnr.
      ls_barcode-esrre = regup-esrre.
      ls_barcode-esrpz = regup-esrpz.
    ENDIF.
* All cases of credit note, with reference or not,
* Regular item and Residual item should be considered.
*      If here, overwrites payment_form even if previously filled.
*    case reguh-ubnkl(3).
*      when '237'.
*        payment_form = '31'.
*      when others.                   "Itau
*            Bank on Boleto barcode equal to house bank ?
*Begin of note 2394906
    IF par_brla = '240' OR par_fbla IS NOT INITIAL OR par_ver IS NOT INITIAL. "2536140
      IF ls_barcode-esrnr(3) = reguh-ubnkl(3).
        payment_form = '30'.
      ELSE.
        payment_form = '31'.
      ENDIF.
    ELSE.
      IF reguh-ubnkl(3) = '237'.
        payment_form = '31'.
      ENDIF.
    ENDIF.
*end of note 2394906
*    endcase.
  ENDIF.
ENDFORM.                    "SORTBOLETO
*&---------------------------------------------------------------------*
*&      Form  FURTHER_PAYMENT_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM further_payment_data.

  DATA: str_length     TYPE i, hlp_char13(13) TYPE c, hlp_control(5) TYPE c.

  j_1bdmeaa-a08           = reguh-zbnkl(3).
  j_1bdmeaa-a09           = partner_agency.

* Assign check digits
  SPLIT reguh-zbnkn AT '-' INTO hlp_char13 hlp_control.

  j_1bdmeaa-a11           = hlp_char13.

  str_length              = strlen( hlp_control ).
  IF str_length GE 2.                  "type other, 2 digits
    j_1bdmeaa-a10         = reguh-zbkon(1).   "Agency cd
    j_1bdmeaa-a12         = hlp_control.
  ELSEIF str_length = 1.               "type other, 1 digit
    j_1bdmeaa-a10         = reguh-zbkon(1).   "Agency cd
    j_1bdmeaa-a12         = hlp_control.
  ELSEIF str_length = 0.               "normal, Itau or Brad
    CLEAR str_length.
    str_length = strlen( reguh-zbkon ).
    IF str_length = 2.                 "Bradesco type
      j_1bdmeaa-a10       = reguh-zbkon(1).   "Agency cd,
      j_1bdmeaa-a12       = reguh-zbkon+1(1).
    ELSE.                              " 1 (or 0), Itau type
      CLEAR j_1bdmeaa-a10.
      j_1bdmeaa-a12       = reguh-zbkon(1).
    ENDIF.
  ENDIF.

  j_1bdmeaa-a18           = reguh-valut.
  j_1bdmeaa-a19           = reguh-valut.
  j_1bdmeaa-a23           = reguh-rskon.
  j_1bdmeaa-a26           = reguh-vblnr.

ENDFORM.                               " FURTHER_PAYMENT_DATA

*&---------------------------------------------------------------------*
*&      Form  BOLETO_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM boleto_data.

  j_1bdmeaa-a08          = ls_barcode-esrnr(3).

  CALL FUNCTION 'J_1B_FI_NETDUE'
    EXPORTING
      zfbdt   = regup-zfbdt
      zbd1t   = regup-zbd1t
      zbd2t   = regup-zbd2t
      zbd3t   = regup-zbd3t
    IMPORTING
      duedate = j_1bdmeaa-a18
    EXCEPTIONS
      OTHERS  = 1.

  j_1bdmeaa-a19          = regup-bldat.

* Old procedure without due date factor
  IF ls_barcode-esrre+23(1) CA ' 0xXnN'
  AND NOT ls_barcode-esrre+23(4) = '0000'.
    IF ls_barcode-esrre+23(3)  = space OR
*   old data from 30F
    ( ls_barcode+23(3)   = 'x' OR ls_barcode+23(3)   = 'X' ).
      j_1bdmeaa-a21        = ls_barcode-amount.
      IF ls_barcode-amount EQ '' OR ls_barcode-amount EQ 0.
        j_1bdmeaa-a23        = '000000000000000'.
      ELSE.
        j_1bdmeaa-a23        = ls_barcode-amount - reguh-rbetr.
      ENDIF.
    ENDIF.
*    else.
*      clear j_1bdmeaa-a21.
*      clear j_1bdmeaa-a23.
*    endif.

* New procedure with due date factor
  ELSE.
    j_1bdmeaa-a21(1)     = '0'.
    j_1bdmeaa-a21+1(4)   = ls_barcode-esrre+23(4).
    IF ls_barcode-esrnr+10(1)   = space.
      j_1bdmeaa-a21+5      = ls_barcode-amount.
      IF ls_barcode-amount EQ '' OR ls_barcode-amount EQ 0.
        j_1bdmeaa-a23        = '000000000000000'..
      ELSE.
        j_1bdmeaa-a23        = ls_barcode-amount - reguh-rbetr.
      ENDIF.
    ELSE.
      j_1bdmeaa-a21+5      = '0000000000'.
      CLEAR j_1bdmeaa-a23.
    ENDIF.
*   Overwrite due date via due date factor
    IF regup-esrre+23(4) NE '0000'.
      j_1bdmeaa-a18          = '20000703'.
      j_1bdmeaa-a18          = j_1bdmeaa-a18 +
                               ls_barcode-esrre+23(4) - 1000.
    ENDIF.
  ENDIF.

  "note 1087535
  PERFORM fill_notafiscal(rffobr_a) CHANGING j_1bdmeaa-a26.
*  j_1bdmeaa-a26+1(6)     = regup-xblnr(6).
*  j_1bdmeaa-a26+7(3)     = regup-buzei.
  PERFORM dta_text_aufbereiten USING j_1bdmeaa-a26.

  IF payment_form = 31 AND ls_barcode-esrnr(3) = '237'.
    j_1bdmeaa-a09        = ls_barcode-esrnr+4(4).         "agency
    PERFORM control_agency_brad USING  j_1bdmeaa-a09 j_1bdmeaa-a10.
    j_1bdmeaa-a11        = ls_barcode-esrre+13(7).        "account
    PERFORM control_account_brad USING ls_barcode-esrre+13(7)
                                       j_1bdmeaa-a12.
    j_1bdmeaa-a14(1)     = '0'.        "carteira
    j_1bdmeaa-a14+1(1)   = ls_barcode-esrnr+8(1).         "carteira
    j_1bdmeaa-a14+2(1)   = ls_barcode-esrre(1).           "carteira
    j_1bdmeaa-a15        = ls_barcode-esrre+1(3).         "year     "N2276736
    j_1bdmeaa-a16(7)     = ls_barcode-esrre+4(7).         "nosso numer
    j_1bdmeaa-a16+7(2)   = ls_barcode-esrre+11(2).        "nosso numer
  ENDIF.

ENDFORM.                               " BOLETO_DATA

*&---------------------------------------------------------------------*
*&      Form  find_vendor_cnpj
*&---------------------------------------------------------------------*
FORM find_vendor_cnpj .

  TYPES: BEGIN OF st_lfa1,                                  "note401117
           lifnr TYPE lifnr,
           stcd2 TYPE stcd2,
           xcpdk TYPE xcpdk,
           ort02 TYPE ort02_gp,
         END OF st_lfa1.

  TYPES: BEGIN OF st_kna1,                                  "note2073194
           kunnr TYPE kunnr,
           stcd2 TYPE stcd2,
           xcpdk TYPE xcpdk,
           ort02 TYPE ort02_gp,
         END OF st_kna1.

  TYPES: BEGIN OF st_bsec,
           bukrs TYPE bukrs,
           gjahr TYPE gjahr,
           stcd2 TYPE stcd2,
           empfg TYPE empfg,
           xcpdk TYPE xcpdk,
           ort02 TYPE ort02_gp,
         END OF st_bsec.

  STATICS: gt_lfa1 TYPE TABLE OF st_lfa1      "FOR PERFORMANCE PURPOSE
           WITH HEADER LINE.
  STATICS: gt_kna1 TYPE TABLE OF st_kna1      "FOR PERFORMANCE PURPOSE
           WITH HEADER LINE.

  STATICS: gt_bsec TYPE TABLE OF st_bsec
           WITH HEADER LINE.

  DATA: wa_lfa1    LIKE lfa1,
        wa_kna1    LIKE kna1,
        wa_bsec    LIKE bsec,
        wa_gt_bsec LIKE gt_bsec.

  DATA: gjahr(4) TYPE c.

  gjahr = reguh-laufd.
  CLEAR hlp_taxcode.    " CNPJ
  CLEAR hlp_xcpdk.      " one time vendor flag
  CLEAR hlp_ort02.      " district
  CLEAR hlp_stkzn.
  CLEAR: gt_lfa1, wa_lfa1, gt_bsec, wa_bsec, wa_gt_bsec.
  IF hlp_laufk NE 'P'.             "not HR
*       Company CNPJ
    IF NOT reguh-zstc1 IS INITIAL.
      hlp_stkzn = '2'.
      hlp_taxcode = reguh-zstc1.
      SELECT SINGLE * FROM lfa1
      WHERE lifnr = reguh-lifnr.
      hlp_ort02 = lfa1-ort02.
    ELSE.
*       Natural Person CPF
*       Check of alternative payee
*       Not Alternative Payee
      IF reguh-empfg EQ space.
        READ TABLE gt_lfa1
        WITH KEY lifnr = reguh-lifnr.
        IF sy-subrc = 0.
          hlp_stkzn = '1'.
          hlp_taxcode = gt_lfa1-stcd2.
          hlp_xcpdk = gt_lfa1-xcpdk.
          hlp_ort02 = gt_lfa1-ort02.      "District
        ELSE.
          SELECT SINGLE * FROM lfa1 INTO wa_lfa1
          WHERE lifnr = reguh-lifnr.
          IF sy-subrc = 0.
            MOVE-CORRESPONDING wa_lfa1 TO gt_lfa1.
            APPEND gt_lfa1 TO gt_lfa1.
            hlp_stkzn = '1'.
            hlp_taxcode = gt_lfa1-stcd2.
            hlp_xcpdk = gt_lfa1-xcpdk.
            hlp_ort02 = gt_lfa1-ort02.      "District
          ELSE.
            SELECT SINGLE * FROM kna1 INTO wa_kna1
            WHERE kunnr = reguh-kunnr.
            IF sy-subrc = 0.
              MOVE-CORRESPONDING wa_kna1 TO gt_kna1.
              APPEND gt_kna1 TO gt_kna1.
              hlp_stkzn = '1'. "CPF
              hlp_taxcode = gt_kna1-stcd2."Tax number of customer
              hlp_xcpdk = gt_kna1-xcpdk.
              hlp_ort02 = gt_kna1-ort02.      "District
            ELSE.
              CLEAR hlp_taxcode.    " CNPJ
              CLEAR hlp_xcpdk.      " one time vendor flag
              CLEAR hlp_ort02.      " district
              CLEAR hlp_stkzn.
            ENDIF.
          ENDIF.
        ENDIF.
      ELSE.
*         Alternative Payee w/ Master Data (not One Time)
*         REGUH-EMPFG NE SPACE.
        READ TABLE gt_lfa1 WITH KEY
        lifnr = reguh-empfg+1(10).
        IF sy-subrc = 0.
          hlp_stkzn = '1'.
          hlp_taxcode = gt_lfa1-stcd2.
          hlp_xcpdk = gt_lfa1-xcpdk.
          hlp_ort02 = gt_lfa1-ort02.      "District
        ELSE.
          SELECT SINGLE * FROM lfa1 INTO wa_lfa1
          WHERE lifnr = reguh-empfg+1(10).
*              Alternative Payee w/o Master Data (One Time)
          IF sy-subrc <> 0.
            READ TABLE gt_bsec INTO wa_gt_bsec
            WITH KEY bukrs = reguh-zbukr
            gjahr = gjahr
            empfg = reguh-empfg.
            IF sy-subrc <> 0.
              SELECT SINGLE * FROM regup
              WHERE laufd = reguh-laufd
              AND   laufi = reguh-laufi
              AND   xvorl = reguh-xvorl
              AND   zbukr = reguh-zbukr
              AND   lifnr = reguh-lifnr
              AND   empfg = reguh-empfg
              AND   vblnr = reguh-vblnr.
*              endselect.
              IF sy-subrc = 0.
                SELECT SINGLE * FROM bsec INTO wa_bsec
                WHERE bukrs = regup-zbukr
                AND   belnr = regup-belnr
                AND   gjahr = regup-gjahr
                AND   buzei = regup-buzei.
*                endselect.
                IF sy-subrc = 0.
                  MOVE-CORRESPONDING wa_bsec
                  TO wa_gt_bsec.
                  APPEND wa_gt_bsec TO gt_bsec.
                ENDIF.
              ENDIF.
            ENDIF.
            IF sy-subrc = 0.
              hlp_stkzn = '1'.
              hlp_taxcode = wa_gt_bsec-stcd2.
              hlp_xcpdk = wa_gt_bsec-xcpdk.
              hlp_ort02 = wa_gt_bsec-ort02.      "District
            ENDIF.
          ELSE.
*         Alternative Payee w/ Master Data (not One Time)
*         The ones not in the static table
            MOVE-CORRESPONDING wa_lfa1 TO gt_lfa1.
            APPEND gt_lfa1.
            hlp_stkzn = '1'.
            hlp_taxcode = wa_lfa1-stcd2.
            hlp_xcpdk = wa_lfa1-xcpdk.
            hlp_ort02 = wa_lfa1-ort02.      "District
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.
  ELSE.                                               "HR
    hlp_stkzn = '1'.
    hlp_taxcode = reguh-zstc1.                              "note401117
    hlp_ort02 = lfa1-ort02.      "District
  ENDIF.

ENDFORM.                    " find_vendor_cnpj
*&---------------------------------------------------------------------*
*&      Form  COMPARE_CNPJ
*&---------------------------------------------------------------------*

FORM compare_cnpj  USING    p_cnpj_company
                            p_cnpj_vendor
                   CHANGING p_hlp_cnpj_check.

  DATA:
    cgc_company_i LIKE j_1bwfield-cgc_number,
    cgc_company_c LIKE j_1bwfield-cgc_compan,
    cgc_vendor_i  LIKE j_1bwfield-cgc_number,
    cgc_vendor_c  LIKE j_1bwfield-cgc_compan.

*   Selection of CGC/CNPJ and preparation of data for comparison
  cgc_company_i = p_cnpj_company.
  CALL FUNCTION 'J_1BSPLIT_CGC_FROM_BRANCH'
    EXPORTING
      cgc_i = cgc_company_i
    IMPORTING
      cgc_c = cgc_company_c.

  cgc_vendor_i = p_cnpj_vendor.

  CALL FUNCTION 'J_1BSPLIT_CGC_FROM_BRANCH'
    EXPORTING
      cgc_i = cgc_vendor_i
    IMPORTING
      cgc_c = cgc_vendor_c.

*    Comparison and selection of type of DOC
  IF cgc_company_c = cgc_vendor_c.
    p_hlp_cnpj_check = 'X'.
  ELSE.
    p_hlp_cnpj_check = ' '.
  ENDIF.

ENDFORM.                    " COMPARE_CNPJ
*&---------------------------------------------------------------------*
*&      Form  FIND_INSTRUCTION
*&---------------------------------------------------------------------*
FORM find_instruction  USING    p_dtws4
                       CHANGING p_pf.
  DATA: code(2)   TYPE c,
        wa_t015w1 LIKE t015w1.
  CLEAR p_pf.
  SELECT SINGLE * FROM t015w1 INTO wa_t015w1
  WHERE dtwsc = 'BR'
  AND   dtwsf = '4'
  AND   dtwsx = p_dtws4.
  IF sy-subrc = 0.
    p_pf = wa_t015w1-code.
  ENDIF.


ENDFORM.                    " FIND_INSTRUCTION

*&---------------------------------------------------------------------*
*&      Form  get_pf_from_ik
*&---------------------------------------------------------------------*
FORM get_pf_from_ik CHANGING p_pf.

  CLEAR p_pf.
* Changes for SPB
  PERFORM find_instruction USING reguh-dtws4
                           CHANGING p_pf.
  IF p_pf NE 0..
* Check if it is an allowed value
    PERFORM validate_pf USING p_pf
                   CHANGING p_pf.
  ENDIF.


ENDFORM.                    " get_pf_from_ik
*
*&---------------------------------------------------------------------*
*&      Form  GET_PF_FROM_PM
*&---------------------------------------------------------------------*
FORM get_pf_from_pm
USING p_hlp_cnpj_check CHANGING p_pf.

  DATA: it_t015w  LIKE t015w OCCURS 100 WITH HEADER LINE,
        it_t015w1 LIKE t015w1 OCCURS 100 WITH HEADER LINE,
        wa_t012d  LIKE t012d,
        wa_t015w  LIKE t015w,
        wa_t015w1 LIKE t015w1,
        n         TYPE i.

***New logic to get the instruction code based on payment method check...Note 2033785
  DATA:
    l_rzawe  TYPE rzawe,
    ls_t042e TYPE t042e,
    ls_t042z TYPE t042z,
    ls_zwels TYPE dzwels,
    ls_land1 TYPE land1,
    ls_cprog TYPE sycprog,
    BEGIN OF ls_f110id,
      progr(4) TYPE c VALUE 'F110',
      laufd    TYPE laufd,
      laufi    TYPE laufi,
      objkt(4) TYPE c VALUE 'PARM',
    END OF ls_f110id.
  DATA: BEGIN OF buktab OCCURS 100,
          bukrs    LIKE t001-bukrs,    " Buchungskreis
          bugrp(2) TYPE n,             " Gruppe
          land1    LIKE t001-land1,    " Laenderschluessel
          zbukr    LIKE t001-bukrs,    " zahlender Buchungskr.
          xkwes(1) TYPE c,             " Debitoren-Wechsel
          xdwes(1) TYPE c,             " Kreditoren-Wechsel
        END OF buktab.
  DATA: BEGIN OF fkttab OCCURS 10,
          bugrp(2)  TYPE n,             " Gruppe
          zwels(10) TYPE c,             " Zahlwege
          nedat     TYPE d,             " naechster Lauf
          wdate     TYPE d,             " Wechsel-Ausstellung
          wfael     TYPE d,             " Wechsel-Faelligkeit
          bukls(50) TYPE c,             " Buchungskreise
          xwanf(1)  TYPE c,             " Wechselanforderg.
          xswec(1)  TYPE c,             " Scheck-Wechsel
          xweca(1)  TYPE c,             " Wechsel-Ausgang
          xwece(1)  TYPE c,             " Wechsel-Eingang
          xwesa(1)  TYPE c,             " Wechsel-Ausgang sof.
          xwese(1)  TYPE c,             " Wechsel-Eingang sof.
          xwfai(1)  TYPE c,             " Wechsel-Fael.-int.
          xwfaf(1)  TYPE c,             " Wechsel bei Faellig
          xpruf(1)  TYPE c,             " Pruefkennzeichen
          xpruw(1)  TYPE c,             " Pruefkennzeichen
        END OF fkttab.
  CLEAR:ls_zwels,ls_t042e,ls_t042z,wa_t012d,ls_cprog.
  ls_cprog = sy-cprog.
*Select from t012d
  SELECT SINGLE * FROM t012d INTO wa_t012d
  WHERE bukrs = reguh-zbukr
  AND   hbkid = reguh-hbkid.
  IF sy-subrc = 0.
*Selecting from T042E to get the amount limit maintained for payment method..
    l_rzawe = reguh-rzawe.
    SELECT SINGLE * FROM t042e INTO ls_t042e
      WHERE zbukr EQ reguh-zbukr
      AND zlsch EQ reguh-rzawe.
*Check the payment amount, if it lies between the amount limit of the payment method...
    IF NOT reguh-rbetr BETWEEN ls_t042e-vonbt AND ls_t042e-bisbt.
* the below query should be done only once and in next iteration take the details from the global fields gs_land1 and gs_zwels.
      ON CHANGE OF reguh-zbukr.
        ls_f110id-laufd = reguh-laufd.
        ls_f110id-laufi = reguh-laufi.
        IMPORT buktab fkttab FROM DATABASE rfdt(fb) ID ls_f110id.
        LOOP AT  buktab WHERE bukrs = reguh-zbukr.
          gs_land1 = buktab-land1.
          EXIT.
        ENDLOOP.
        LOOP AT fkttab WHERE bugrp = buktab-bugrp.
          gs_zwels = fkttab-zwels.
          EXIT.
        ENDLOOP.
      ENDON.
      ls_zwels = gs_zwels.
      ls_land1 = gs_land1.
      WHILE ls_zwels NE space.
        SELECT SINGLE * FROM t042z INTO ls_t042z
                                       WHERE land1 = ls_land1
                                       AND zlsch = ls_zwels(1)
                                       AND progn = ls_cprog.
        IF sy-subrc EQ 0.
          CLEAR:ls_t042e.
          SELECT SINGLE * FROM t042e INTO ls_t042e
                                    WHERE zbukr EQ reguh-zbukr
                                     AND zlsch EQ ls_zwels.
          IF reguh-rbetr BETWEEN ls_t042e-vonbt AND ls_t042e-bisbt.
            l_rzawe = ls_t042e-zlsch.
            EXIT.
          ENDIF.
        ENDIF.
        SHIFT ls_zwels.                                     "N2340223
      ENDWHILE.
    ENDIF."check for payment method..
    SELECT SINGLE * FROM t015w INTO wa_t015w
                                WHERE banks = 'BR'
                                AND   zlsch = l_rzawe
                                AND   dtaws = wa_t012d-dtaws.
***New logic end......Note 2033785
    IF sy-subrc = 0.
      SELECT SINGLE * FROM t015w1 INTO wa_t015w1
          WHERE dtwsc = 'BR'
          AND   dtwsf = '4'
          AND   dtwsx = wa_t015w-dtws4.
      IF sy-subrc = 0.
        PERFORM validate_pf USING wa_t015w1-code
                       CHANGING p_pf.
* Missing customizing in t015w1
      ELSE.
      ENDIF.
* Missing customizing in t015w
    ELSE.
    ENDIF.
* Missing customizing in t012d
  ELSE.
  ENDIF.

ENDFORM.                    " GET_PF_FROM_PM
*&---------------------------------------------------------------------*
*&      Form  spb_chamber
*&---------------------------------------------------------------------*
FORM spb_chamber USING payment_form hlp_cnpj_check
                 CHANGING chamber.
  CASE payment_form.
    WHEN '03'.
      chamber = '700'.
    WHEN '41' OR '43'.
      chamber = '018'.
    WHEN OTHERS.
      chamber = '000'.
  ENDCASE.
ENDFORM.                    " spb_chamber
*&---------------------------------------------------------------------*
*&      Form  validate_PF
*&---------------------------------------------------------------------*
FORM validate_pf  USING    p_wa_t015w1-code
                  CHANGING p_pf.

  "Meta - 08.02.22 - inicio
  p_pf = p_wa_t015w1-code.

**  CASE reguh-ubnkl(3).
**    WHEN '237'.
**      p_pf = p_wa_t015w1-code.
**      SHIFT p_pf LEFT DELETING LEADING space.
**      IF   p_pf = '01'                              "CC
**        OR p_pf = '02'                              "Cheque
**        OR p_pf = '03'                              "DOC
**        OR p_pf = '05'                              "OP
**        OR p_pf = '07'                              "TED CIP
**        OR p_pf = '08'                             "TED STR
**        OR p_pf = '41'.                            "TED
**      ELSE.
**        p_pf = '03'.
**      ENDIF.
**    WHEN OTHERS.
**      p_pf = p_wa_t015w1-code.
**      SHIFT p_pf LEFT DELETING LEADING space.
**      IF   ( p_pf = '01' )             "CC
**        OR ( p_pf = '02' )             "Cheque
**        OR ( ( p_pf = '03' )           "DOC C ITAU
**           AND ( reguh-ubnkl(3) = '341' )
**           AND ( hlp_cnpj_check = ' ' ) )
**        OR ( ( p_pf = '07' )           "DOC D ITAU
**           AND ( reguh-ubnkl(3) = '341' )
**           AND ( hlp_cnpj_check = 'X' ) )
**        OR ( ( p_pf = '03' )           "DOC BRAD/FEBR
**        AND ( reguh-ubnkl(3) <> '341' ) )
**        OR ( p_pf = '10' )             "OP
**        OR ( ( p_pf = '41' )           "TED ne CNPJ
**           AND ( hlp_cnpj_check = ' ' ) )
**        OR ( ( p_pf = '43' )           "TED eq CNPJ
**           AND ( hlp_cnpj_check = 'X' ) ).
**      ELSEIF
**           ( ( ( p_pf = '03' )
**           AND ( reguh-ubnkl(3) = '341' )
**           AND ( hlp_cnpj_check = 'X' ) )
**        OR ( ( p_pf = '07' )
**           AND ( reguh-ubnkl(3) = '341' )
**           AND ( hlp_cnpj_check = ' ' ) )
**        OR ( ( p_pf = '41' )
**           AND ( hlp_cnpj_check = 'X' ) ) "TED ne CNPJ
**        OR ( ( p_pf = '43' )
**           AND ( hlp_cnpj_check = ' ' ) ) ) . "TED eq CNPJ
**        CASE p_pf.
**          WHEN '03'.
**            IF reguh-ubnkl(3) = '341'.
**              p_pf = '07'.
**            ENDIF.
**          WHEN '07'.
**            IF reguh-ubnkl(3) = '341'.
**              p_pf = '03'.
**            ENDIF.
**          WHEN '41'.
**            p_pf = '43'.
**          WHEN '43'.
**            p_pf = '41'.
**        ENDCASE.
**      ELSE.
**        p_pf = '03'.
**      ENDIF.
**  ENDCASE.
**  IF reguh-ubnkl(3) = reguh-zbnkl(3).
**    IF p_pf = '03'
**    OR p_pf = '41'
**    OR p_pf = '43'
**    OR p_pf = '07'
**    OR p_pf = '08'.
**      p_pf = '01'.
**    ENDIF.
**  ELSE.
**    IF p_pf = '01'
**    OR p_pf = '05'.
**      p_pf = '03'.
**    ENDIF.
**  ENDIF.

  "Meta - 08.02.22 - Fim
ENDFORM.                    " validate_PF
*&---------------------------------------------------------------------*
*&      Form  get_next_number
*&---------------------------------------------------------------------*
FORM get_next_number  USING    hlp_renum
                               hlp_resultat.

  PERFORM naechster_index USING hlp_renum.
  PERFORM temse_name USING hlp_renum
                           hlp_temsename.

  CALL FUNCTION 'COMPUTE_CONTROL_NUMBER'
    EXPORTING
      i_refno  = hlp_renum
    IMPORTING
      e_result = hlp_resultat.

  regud-label = hlp_dta_id-refnr = hlp_resultat.

ENDFORM.                    " get_next_number
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
*&      Form  FILL_NOTAFISCAL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->PAR_XBLNR  text
*----------------------------------------------------------------------*
FORM fill_nota_fiscal CHANGING par_xblnr.
  DATA: hlp_len TYPE n.
  DATA: len    TYPE i. "Note 1342616

  val_xblnr = regup-xblnr.
  PERFORM convert_xblnr.

  CALL FUNCTION 'STRING_LENGTH'
    EXPORTING
      string = l_xblnr1
    IMPORTING
      length = hlp_len.

*---Note 1342616
  par_xblnr+8(10) = l_xblnr1.
*    UNPACK par_xblnr+8(10) TO par_xblnr+8(10).
  len = strlen( par_xblnr+8(10) ).
  len = 10 - len.

  DO len TIMES.
    REPLACE SECTION LENGTH 0 OF par_xblnr+8(10) WITH '0'.
  ENDDO.
*---Note 1342616
ENDFORM.                    " FILL_NOTA_FISCAL
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
*&      Form  FILL_ITAU_SEGMENT_J52
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM fill_itau_segment_j52 .

  DATA: obj_badi_rffobr_u TYPE REF TO fiapbr_rffobr_u.   "BAdI object
  DATA: ls_reguh       TYPE reguh,
        ls_regud       TYPE regud,
        ls_file_header TYPE j_1bdmexh1,
        ls_lot_header  TYPE j_1bdmexh2.

  GET BADI obj_badi_rffobr_u.

  CLEAR: j_1bdmexj52.   "Dataset for J-52

  cnt_rec_perlot  = cnt_rec_perlot + 1.
  cnt_records     = cnt_records  + 1.
  IF reguh-ubnkl(3) = '237'.                                "n2878213
    cnt_rec_detail  = cnt_rec_detail + 1."counts details, no records "2394906
  ENDIF.
  j_1bdmexj52-j01 = j_1bdmexh1-h101.
  j_1bdmexj52-j02 = cnt_lot.
  j_1bdmexj52-j03 = '3'.
  j_1bdmexj52-j04 = cnt_rec_detail.                         "n2878213
  j_1bdmexj52-j05 = 'J'.
* Begin of note 2529571
  IF reguh-ubnkl(3) = '237'.
    j_1bdmexj52-j06_1 = space.
  ELSE.
    j_1bdmexj52-j06_1 = '0'.
  ENDIF.
* End of note 2529571
  j_1bdmexj52-j06_2 = '00'.                                 "n2878213
  j_1bdmexj52-j07 = '52'.
  j_1bdmexj52-j08 = '2'.

  "cnpj details
  j_1bdmexj52-j09 = j_1bwfield-cgc_number.
  j_1bdmexj52-j10 = j_1bdmexh1-h113.

  j_1bdmexj52-j11 = hlp_stkzn.
  j_1bdmexj52-j12 = hlp_taxcode.
  j_1bdmexj52-j13 = reguh-znme1.
  j_1bdmexj52-j17 = space.
  j_1bdmexj52-j18 = space.

*  Implement the BAdI Method "change_segment_j52" to fill the
*  following fields according to your requirement for Itau
*  version 080:
*  1. J_1BDMEXJ52-J14 - Drawee/Payee Inscription Type
*  2. J_1BDMEXJ52-J15 - Draweer/Payee Insc. Numb
*  3. J_1BDMEXJ52-J16 - Drawee/Payee Name

  CLEAR: ls_reguh, ls_regud, ls_file_header, ls_lot_header.
  ls_reguh = reguh.
  ls_regud = regud.
  ls_file_header = j_1bdmexh1.
  ls_lot_header = j_1bdmexh2.

  CALL BADI obj_badi_rffobr_u->change_segment_j52
    EXPORTING
      is_j_1bdmexh1  = ls_file_header
      is_reguh       = ls_reguh
      is_regud       = ls_regud
      iv_itau_ver    = par_ver
      is_j_1bdmexh2  = ls_lot_header
      is_j_1bdmexa   = j_1bdmexa
      is_j_1bdmexj   = j_1bdmexj
    CHANGING
      cs_j_1bdmexj52 = j_1bdmexj52.


ENDFORM.                    " FILL_ITAU_SEGMENT_J52
*&---------------------------------------------------------------------*
*&      Form  FILL_HEADER_BRADESCO_240
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM fill_header_bradesco_240 .
  CLEAR: j_1bdmexh1. ", j_1bdmexh3.  "Data set: Header, lot header

  j_1bdmexh1-h101      = reguh-ubnkl(3).
  j_1bdmexh1-h102      = 0.                         "count lot
  j_1bdmexh1-h103      = '0'.
  j_1bdmexh1-h104      = space.                     "9 blanks
  j_1bdmexh1-h105      = '2'.                       "CGC and not CPF
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
*  j_1bdmexh1-h119+6(3) = '087'.                  "File Version 240
  j_1bdmexh1-h119+6(3) = '089'.            "snote 2555959      "File Version 240
*begin of note 2394906
*     IF hlp_laufk eq 'P'.
*       j_1bdmexh1-h120 = '01600'.
*     ELSE.
*       j_1bdmexh1-h120 = space.
*     ENDIF.
  j_1bdmexh1-h120 = '01600'.
*end of note 2394906
  j_1bdmexh1-h121 = space.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  LOT_HEADER_BRADESCO240
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM lot_header_bradesco240 .

  cnt_lot = cnt_lot + 1. " Lots are counted

  CLEAR: j_1bdmexh2, j_1bdmext2.
  j_1bdmexh2-h201   = reguh-ubnkl(3).           "
  j_1bdmexh2-h202   = cnt_lot.
  j_1bdmexh2-h203   = '1'.

  IF hlp_laufk NE 'P'.     "not HR
    IF regud-xeinz = space.  "Regular payment
      j_1bdmexh2-h204 = 'C'.
      j_1bdmexh2-h205 = '20'.
    ELSE.                    "credit note
      j_1bdmexh2-h204 = 'D'.
      j_1bdmexh2-h205 = '05'.
    ENDIF.
  ELSE.                                         "HR
    j_1bdmexh2-h204 = 'C'.
    j_1bdmexh2-h205 = '30'.
  ENDIF.

  j_1bdmexh2-h206    = payment_form.

  j_1bdmexh2-h207   =  '045'.      "Lot version Feb 8.7

  IF regup-shkzg = 'H'.
    IF payment_form = 30 OR payment_form = 31.
      j_1bdmexh2-h207     =  '040'."Lot version Feb 8.7
    ENDIF.
  ELSE.
    IF regup-xrebz = space.
      IF payment_form = 30 OR payment_form = 31.
        j_1bdmexh2-h207   =  '040'."Lot version Feb 8.7
      ENDIF.
    ENDIF.
  ENDIF.

  j_1bdmexh2-h208    = '2'.    " CGC and not CPF
  j_1bdmexh2-h209    = j_1bdmexh1-h106.

  CLEAR t045t.
  SELECT SINGLE dtaid FROM t045t INTO j_1bdmexh2-h210
                       WHERE bukrs = reguh-zbukr
                       AND   zlsch = reguh-rzawe
                       AND   hbkid = reguh-hbkid
                       AND   hktid = reguh-hktid.
  IF sy-subrc NE 0.
    SELECT SINGLE dtaid FROM t045t INTO j_1bdmexh2-h210
                         WHERE bukrs = reguh-zbukr
                         AND   zlsch = space  "no payment method maint.
                         AND   hbkid = reguh-hbkid
                         AND   hktid = reguh-hktid.
  ENDIF.

  j_1bdmexh2-h211    = j_1bdmexh1-h108.           " house bank
  j_1bdmexh2-h212    = j_1bdmexh1-h109.
  j_1bdmexh2-h213    = j_1bdmexh1-h110.          "house bank acc
  j_1bdmexh2-h214    = j_1bdmexh1-h111.
  j_1bdmexh2-h215    = j_1bdmexh1-h112.          " control digit
  j_1bdmexh2-h216    = j_1bdmexh1-h113.               " our name
  CLEAR: j_1bdmexh2-h217,
         j_1bdmexh2-h218.

  j_1bdmexh2-h219    = j1_addr1val-street.             " our street
  PERFORM dta_text_aufbereiten USING j_1bdmexh2-h219.
  j_1bdmexh2-h220    = j1_addr1val-house_num1.         "house number
  PERFORM dta_text_aufbereiten USING j_1bdmexh2-h220.
  j_1bdmexh2-h221    = j1_addr1val-house_num2.                 "complement
  PERFORM dta_text_aufbereiten USING j_1bdmexh2-h221.
  j_1bdmexh2-h222    = j1_addr1val-city1.              "City
  PERFORM dta_text_aufbereiten USING j_1bdmexh2-h222.
  j_1bdmexh2-h223    = j1_addr1val-post_code1(5).      "Zip-code
  PERFORM dta_text_aufbereiten USING j_1bdmexh2-h223.
  j_1bdmexh2-h224    = j1_addr1val-post_code1+6(3).    "compl.
  PERFORM dta_text_aufbereiten USING j_1bdmexh2-h224.
  j_1bdmexh2-h225    = j1_addr1val-region.             "Region
  PERFORM dta_text_aufbereiten USING j_1bdmexh2-h225.
*          if PAR_FBLA eq '087' and j_1bdmexh2-h207 eq '045'.  "2394906
  IF ( par_fbla EQ '089' AND j_1bdmexh2-h207 EQ '045' ) OR ( par_ver IS NOT INITIAL AND j_1bdmexh2-h207 EQ '045' ).  "SNOTE  2555959
    j_1bdmexh2-h226 = '01'.                                 "2394906
  ENDIF.                                                    "2394906
  CLEAR:
    "j_1bdmexh2-h226, "2394906
    j_1bdmexh2-h227,
    j_1bdmexh2-h228.

*-Lot header filled-----------------------------------------------------


*          "Meta - FIAP ID 10 - pagto fornecedor - Inicio
  j_1bdmexh2-h205 = '22'.
  j_1bdmexh2-h206 = '11'.
  j_1bdmexh2-h207 = '012'.
  j_1bdmexh2-h226 = '01'.
*          "Meta - FIAP ID 10 - pagto fornecedor - Fim

  IF reguh-rzawe = 'O' OR reguh-rzawe = 'G' OR reguh-rzawe = 'Q' .
    j_1bdmexh2-h206 = '11'.

  ELSEIF reguh-rzawe = 'B'.

    DATA: lv_ref1 TYPE bseg-glo_ref1.

    SELECT SINGLE glo_ref1
      FROM bseg
      INTO lv_ref1
      WHERE belnr = regup-belnr
       AND gjahr = regup-gjahr
       AND bukrs = regup-bukrs
       AND buzei = regup-buzei.

    IF lv_ref1(3) = '237'.
      j_1bdmexh2-h206 = '030'.
    ELSE.
      j_1bdmexh2-h206 = '031'.
    ENDIF.

    IF reguh-ubnkl(3) = '237'.
      j_1bdmexh2-h207 = '040'.
      CLEAR: j_1bdmexh2-h227.
    ENDIF.


  ELSEIF reguh-rzawe = 'U'.
    j_1bdmexh2-h206 = '01'.
    j_1bdmexh2-h227 = '01'.

    IF reguh-ubnkl(3) = '237'.
      j_1bdmexh2-h207 = '045'.
    ENDIF.

  ELSEIF reguh-rzawe = 'R' .

    IF reguh-zbnkl(3) = '237'.
      j_1bdmexh2-h206 = '01'.
    ELSE.
      j_1bdmexh2-h206 = '41'.
    ENDIF.

    IF reguh-ubnkl(3) = '237'.
      IF reguh-zbnkn IS INITIAL.
        j_1bdmexh2-h207 = '040'.
      ELSE.
        j_1bdmexh2-h207 = '045'.
      ENDIF.
    ENDIF.

    IF reguh-zbnkn IS INITIAL.
      j_1bdmexh2-h227 = '01'.
    ELSE.
      CLEAR: j_1bdmexh2-h227.
    ENDIF.


  ELSEIF reguh-rzawe = 'T'.
    j_1bdmexh2-h206 = '41'.
    j_1bdmexh2-h227 = '01'.

    IF reguh-ubnkl(3) = '237'.
      j_1bdmexh2-h207 = '045'.
    ENDIF.

  ENDIF.


  "Bradesco
  IF reguh-rzawe = 'T' OR
     reguh-rzawe = 'B' OR
     reguh-rzawe = 'R' OR
     reguh-rzawe = 'U' .
    j_1bdmexh2-h205 = '20'.
  ENDIF.

  IF reguh-rzawe = 'O' OR
     reguh-rzawe = 'G' OR
     reguh-rzawe = 'Q'.
    j_1bdmexh2-h205 = '22'.
  ENDIF.


  IF reguh-ubnkl(3) = '237'.
    IF reguh-rzawe = 'B' OR reguh-rzawe = 'T' OR reguh-rzawe = 'U'  .
      j_1bdmexh1-h119 = '080'.
    ENDIF.
  ENDIF.

  CLEAR: j_1bdmexh2-h228, j_1bdmexh2-h227.


*          "Meta - FIAP ID 10 - pagto fornecedor - Fim

  PERFORM store_on_file USING j_1bdmexh2.
  PERFORM cr_lf.

*         Initialize record counter per lot
  cnt_rec_perlot = 0.

*         Initialize special detail counter
  cnt_rec_detail = 0.

*         Initialize total per lot
  CLEAR total_perlot.
*---------End of Lot header---



ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  FILL_BRADESCO240_SEGMENT_A
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM fill_bradesco240_segment_a .

* -----Segment A -------------------------------------------------------
  DATA: date LIKE sy-datum.
  CLEAR j_1bdmexa.

  DATA: obj_badi_rffobr_u TYPE REF TO fiapbr_rffobr_u.   "BAdI object
  DATA: ls_reguh       TYPE reguh,
        ls_regud       TYPE regud,
        ls_file_header TYPE j_1bdmexh1,
        ls_lot_header  TYPE j_1bdmexh2.

  GET BADI obj_badi_rffobr_u.

  cnt_rec_perlot = cnt_rec_perlot + 1.
  cnt_records    = cnt_records    + 1.
  cnt_rec_detail = cnt_rec_detail + 1.

  j_1bdmexa-a01   = j_1bdmexh1-h101.
  j_1bdmexa-a02   = cnt_lot.
  j_1bdmexa-a03   = '3'.
  j_1bdmexa-a04   = cnt_rec_detail.
  j_1bdmexa-a05   = 'A'.
  j_1bdmexa-a06   = '0'.
  j_1bdmexa-a07   =  00.

* Changes for SPB
  PERFORM spb_chamber USING payment_form hlp_cnpj_check
                 CHANGING j_1bdmexa-a08.
  j_1bdmexa-a09   = reguh-zbnkl(3).    "bank group,e.g.Itau=341
  j_1bdmexa-a10   = partner_agency.    " Partner's agency

  CALL FUNCTION 'READ_ACCOUNT_DATA'
    EXPORTING
      i_bankn = reguh-zbnkn
      i_bkont = reguh-zbkon
    IMPORTING
      e_bankn = regud-obknt
      e_cntr1 = j_1bdmexa-a11
      e_cntr2 = j_1bdmexa-a13
      e_cntr3 = j_1bdmexa-a14
    EXCEPTIONS
      OTHERS  = 1.

  j_1bdmexa-a12     = regud-obknt.
  j_1bdmexa-a15     = reguh-koinh.
  PERFORM dta_text_aufbereiten USING j_1bdmexa-a15.
  j_1bdmexa-a16     = reguh-vblnr.     "Seu numero
  PERFORM dta_text_aufbereiten USING j_1bdmexa-a16.

  IF hlp_laufk EQ 'P'. "HR Payments

*      j_1bdmexa-a17(2)    = reguh-valut+6(2). "2359292
*      j_1bdmexa-a17+2(2)  = reguh-valut+4(2). "2359292
*      j_1bdmexa-a17+4(4)  = reguh-valut(4).   "2359292
    j_1bdmexa-a17(2)    = reguh-ausfd+6(2).                 "2359292
    j_1bdmexa-a17+2(2)  = reguh-ausfd+4(2).                 "2359292
    j_1bdmexa-a17+4(4)  = reguh-ausfd(4).                   "2359292


  ELSE.
*     Pay date, ddmmyy
    CALL FUNCTION 'J_1B_FI_NETDUE'
      EXPORTING
        zfbdt   = regup-zfbdt
        zbd1t   = regup-zbd1t
        zbd2t   = regup-zbd2t
        zbd3t   = regup-zbd3t
      IMPORTING
        duedate = date
      EXCEPTIONS
        OTHERS  = 1.

    IF date < reguh-ausfd.                                  "n2888287
      MOVE reguh-ausfd TO date.                             "n2888287
    ENDIF.                                                  "n2888287

    j_1bdmexa-a17(2)   = date+6(2).
    j_1bdmexa-a17+2(2) = date+4(2).
    j_1bdmexa-a17+4(4) = date(4).

  ENDIF.

  j_1bdmexa-a18 = 'BRL'.     "Febraban
  j_1bdmexa-a20 = reguh-rbetr.   "paid amount per item
  j_1bdmexa-a22 = '00000000'.
  j_1bdmexa-a23 = '000000000000000'.
  j_1bdmexa-a24 = space.
  j_1bdmexa-a25+0(6) = space.
  j_1bdmexa-a26(4)   =  space.

*   Implement the BAdI Method "change_segment_a" to fill the
*   fields according  to your requirement

*   The following fields for Febraban version 8.7,
*
*   1. DOC Purpose Code: 	 field  j_1bdmexa-a26+4(2)
*   2. TED Purpose code:   field  j_1bdmexa-a26+6(5)
*   3. Complement of purpose code: field  j_1bdmexa-a26+11(2)
*   j_1bdmexa-a26+6(5)
*   j_1bdmexa-a26+11(2)

*   The following fields for Itau version 080
*   1. DOC Purpose and Employee status:  field  j_1bdmexa-a26+4(2)
*   2. TED Purpose code               :  field  j_1bdmexa-a26+6(5)

  CLEAR: ls_reguh, ls_regud, ls_file_header, ls_lot_header.
  ls_reguh = reguh.
  ls_regud = regud.
  ls_file_header = j_1bdmexh1.
  ls_lot_header  = j_1bdmexh2.
  TRY.
      CALL BADI obj_badi_rffobr_u->change_segment_a
        EXPORTING
          is_j_1bdmexh1  = ls_file_header
          is_reguh       = ls_reguh
          is_regud       = ls_regud
          iv_feb_version = par_fbla
          iv_itau_ver    = par_ver
          is_j_1bdmexh2  = ls_lot_header
        CHANGING
          cs_j_1bdmexa   = j_1bdmexa.
    CATCH cx_sy_dyn_call_illegal_method.
  ENDTRY.

********** Febraban Version 8.7 **************************
  IF NOT par_baav EQ space.            " with advice
    j_1bdmexa-a27     =  '5'.
  ELSE.                                " w/o advice
    j_1bdmexa-a27     =  '0'.
  ENDIF.
  j_1bdmexa-a28       = space.

*--- End of Segment A --------------------------------------------------
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  FILL_BRADESCO240_SEGMENT_B
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_REGUH  text
*----------------------------------------------------------------------*
FORM fill_bradesco240_segment_b  USING i_reguh LIKE reguh.

  DATA: hlp_str(113) TYPE c.
  DATA: date LIKE sy-datum.
  DATA: value(15) TYPE c.
  DATA: ls_ispb_code TYPE fiapbrd_ispb.
  DATA: lv_email_addr TYPE ad_smtpadr.
  "Begin of Note:2658786
  DATA: lv_house_num1 TYPE c LENGTH 5.
  "End of Note 2658786

  DATA: et_rgdir TYPE hrpy_tt_rgdir,
        wa_rgdir TYPE pc261,
        lv_molga TYPE molga,
        lv_abkrs TYPE abkrs,
        lv_fpper TYPE faper,
        lv_permo TYPE permo,
        lv_begda TYPE begda,
        lv_endda TYPE endda,
        lv_fpbeg TYPE fpbeg.

  DATA:
    lv_tname             TYPE dd02l-tabname,
    lv_hcm_pa0006        TYPE abap_bool,
    lv_hcm_t549a         TYPE abap_bool,
    lv_hcm_t549q         TYPE abap_bool,
    lv_hcm_cu_read_rgdir TYPE abap_bool,
    ls_datum             TYPE ty_s_datum.

*--- Segment B ---------------------------------------------------------
  CLEAR j_1bdmexb.

* HCM Decoupling: Check HCM table availability
  IF cl_cos_utilities=>is_cloud( ) EQ abap_true.
*   Cloud-Edition
    lv_hcm_pa0006 = lv_hcm_t549a = lv_hcm_t549q = abap_false.
  ELSE.
    SELECT SINGLE tabname FROM dd02l INTO lv_tname
      WHERE
        tabname  EQ lc_table_pa0006 AND
        as4local EQ 'A' ##WARN_OK.
    IF sy-subrc EQ 0.
      lv_hcm_pa0006 = abap_true.
    ENDIF.
    SELECT SINGLE tabname FROM dd02l INTO lv_tname
      WHERE
        tabname  EQ lc_table_t549a AND
        as4local EQ 'A' ##WARN_OK.
    IF sy-subrc EQ 0.
      lv_hcm_t549a = abap_true.
    ENDIF.
    SELECT SINGLE tabname FROM dd02l INTO lv_tname
      WHERE
        tabname  EQ lc_table_t549q AND
        as4local EQ 'A' ##WARN_OK.
    IF sy-subrc EQ 0.
      lv_hcm_t549q = abap_true.
    ENDIF.
    CALL FUNCTION 'FUNCTION_EXISTS'
      EXPORTING
        funcname           = lc_func_rgdir
      EXCEPTIONS
        function_not_exist = 1
        OTHERS             = 2.
    IF sy-subrc EQ 0.
      lv_hcm_cu_read_rgdir = abap_true.
    ENDIF.
  ENDIF.

  cnt_rec_perlot = cnt_rec_perlot + 1.
  cnt_records    = cnt_records    + 1.
  cnt_rec_detail = cnt_rec_detail + 1.
  j_1bdmexb-b01   = j_1bdmexh1-h101.
  j_1bdmexb-b02   = cnt_lot.
  j_1bdmexb-b03   = '3'.
  j_1bdmexb-b04   = cnt_rec_detail.
  j_1bdmexb-b05   = 'B'.
  IF hlp_xcpdk IS INITIAL.
    j_1bdmexb-b07   = hlp_stkzn.       "CPF(1) or CGC(2)
    j_1bdmexb-b08   = hlp_taxcode.
  ELSE.
    DESCRIBE TABLE taxtab LINES lin.
    IF lin EQ 1.
* unique entry found: write the tax numbers to target arrays
      READ TABLE taxtab INDEX 1.
      IF hlp_laufk NE 'P'.             "No HR
* CGC/CPF distinction
        IF taxtab-stkzn IS INITIAL.
          j_1bdmexb-b07   = '2'.                            "CGC
          j_1bdmexb-b08   = taxtab-stcd1.
        ELSE.
          j_1bdmexb-b07   = '1'.                            "CPF
          j_1bdmexb-b08   = taxtab-stcd2.
        ENDIF.
      ELSE.                                                 "HR
        j_1bdmexb-b07   = '1'.
        j_1bdmexb-b08   = taxtab-stcd1.
      ENDIF.
* error case
    ELSE.
      READ TABLE itemtab INDEX 1.
      fimsg-msgid = '5K'.
      fimsg-msgv1 = reguh-lifnr.
      fimsg-msgv2 = itemtab-belnr.
      fimsg-msgv3 = TEXT-222.
      PERFORM message USING '010'.
    ENDIF.                             "Only one line
  ENDIF.                               "One time vendor done

  IF hlp_laufk NE 'P'.
    SELECT SINGLE addrnumber street house_num1 house_num2
               FROM adrc INTO it_adrs
               WHERE addrnumber = reguh-zadnr.

    j_1bdmexb-b09   = it_adrs-street. "reguh-zstra.       "street + number
    PERFORM dta_text_aufbereiten USING j_1bdmexb-b09.

    "Begin of Note 2754668
    TRY.
        UNPACK it_adrs-house_num1 TO lv_house_num1.
      CATCH cx_sy_conversion_no_number.
        lv_house_num1 = '00000'.
    ENDTRY.

    it_adrs-house_num1 = lv_house_num1.
    "End of Note 2754668

    j_1bdmexb-b10   = it_adrs-house_num1.                   "'00000'.
    j_1bdmexb-b11   = it_adrs-house_num2.
    j_1bdmexb-b16   = reguh-zregi.       "Region
    PERFORM dta_text_aufbereiten USING j_1bdmexb-b16.
  ELSE.

    CLEAR: lv_molga,et_rgdir,wa_rgdir,lv_abkrs,lv_fpper,lv_permo.

*   HCM Decoupling: Call HCM method or raise error
    IF lv_hcm_cu_read_rgdir EQ abap_true.
      CALL FUNCTION lc_func_rgdir
        EXPORTING
          persnr          = i_reguh-pernr
        IMPORTING
          molga           = lv_molga
        TABLES
          in_rgdir        = et_rgdir
        EXCEPTIONS
          no_record_found = 1
          OTHERS          = 2.
    ELSE.
      MESSAGE e002(idfi_br_paym_appl) WITH lc_func_rgdir.
    ENDIF.
    SORT et_rgdir BY seqnr DESCENDING.
    READ TABLE et_rgdir INTO wa_rgdir WITH KEY seqnr = i_reguh-seqnr.
    IF wa_rgdir-fpper EQ '000000' AND wa_rgdir-inper EQ '000000'. "OFFCYCLE...
*     HCM Decoupling: Select from HCM table or raise message
      IF lv_hcm_pa0006 EQ abap_true.
        SELECT SINGLE pernr stras hsnmr posta ort02 state FROM (lc_table_pa0006) INTO it_adrs
          WHERE
            pernr EQ i_reguh-pernr AND "SELECTING FROM 0006 FOR OFFCYCLE PERIOD
            begda LE wa_rgdir-fpbeg AND
            endda GE wa_rgdir-fpbeg.
      ELSE.
        MESSAGE e001(idfi_br_paym_appl) WITH lc_table_pa0006.
      ENDIF.
    ELSE. "ACTIVE PERIOD
      lv_abkrs = wa_rgdir-abkrs."PAYROLL AREA
      lv_fpper = wa_rgdir-fpper."PAYROLL YEAR + PAYROLL PERIOD

*     HCM Decoupling: Select from HCM table or raise message
      IF lv_hcm_t549a EQ abap_true.
        SELECT SINGLE permo FROM (lc_table_t549a) INTO lv_permo
          WHERE abkrs EQ lv_abkrs.
      ELSE.
        MESSAGE e001(idfi_br_paym_appl) WITH lc_table_t549a.
      ENDIF.
      IF sy-subrc EQ 0.
*GETTING THE BEGGINING AND END DATE OF THE EMPLOYEE
*       HCM Decoupling: Select from HCM table or raise message
        IF lv_hcm_t549q EQ abap_true.
          SELECT SINGLE begda endda FROM (lc_table_t549q) INTO ls_datum
            WHERE
              permo = lv_permo AND"PERIOD PARAMETER
              pabrj = lv_fpper(4) AND "PAYROLL YEAR
              pabrp = lv_fpper+4(2)."PAYROLL PERIOD.
        ELSE.
          MESSAGE e001(idfi_br_paym_appl) WITH lc_table_t549q.
        ENDIF.
        IF sy-subrc EQ 0.
*         HCM Decoupling: Select from HCM table or raise message
          IF lv_hcm_pa0006 EQ abap_true.
            SELECT SINGLE pernr stras hsnmr posta ort02 state FROM (lc_table_pa0006) INTO it_adrs
              WHERE
                pernr EQ i_reguh-pernr AND "SELECTING FROM 0006 FOR ACTIVE PERIOD
                begda LE ls_datum-endda AND
                endda GE ls_datum-begda.
          ELSE.
            MESSAGE e001(idfi_br_paym_appl) WITH lc_table_pa0006.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.

    "End of Note 1931476.

    j_1bdmexb-b09 = it_adrs-street.
    PERFORM dta_text_aufbereiten USING j_1bdmexb-b09.
    j_1bdmexb-b10 = it_adrs-house_num1.
    j_1bdmexb-b11 = it_adrs-house_num2.
    j_1bdmexb-b12 = it_adrs-ort02.
    j_1bdmexb-b16 = it_adrs-state.
    PERFORM dta_text_aufbereiten USING j_1bdmexb-b16.
  ENDIF.
  CLEAR it_adrs.
  " note 1378829

  IF j_1bdmexh2-h205 NE '30'.                               "HR
    CLEAR j_1bdmexb-b12.
    j_1bdmexb-b12 = hlp_ort02.      "District
  ENDIF.
  PERFORM dta_text_aufbereiten USING j_1bdmexb-b12.
  j_1bdmexb-b13   = reguh-zort1.       "City
  PERFORM dta_text_aufbereiten USING j_1bdmexb-b13.
  j_1bdmexb-b14   = reguh-zpstl(5).    "Zip code
  PERFORM dta_text_aufbereiten USING j_1bdmexb-b14.
  j_1bdmexb-b15   = reguh-zpstl+6.     "complement
  PERFORM dta_text_aufbereiten USING j_1bdmexb-b15.

  IF j_1bdmexb-b01  EQ '237'.
    TRANSLATE hlp_str USING ' 0'.
    CALL FUNCTION 'J_1B_FI_NETDUE'
      EXPORTING
        zfbdt   = regup-zfbdt
        zbd1t   = regup-zbd1t
        zbd2t   = regup-zbd2t
        zbd3t   = regup-zbd3t
      IMPORTING
        duedate = date
      EXCEPTIONS
        OTHERS  = 1.
    hlp_str(8) = date+6(2).
    hlp_str+2(8) = date+4(2).
    hlp_str+4(8) = date(4).
    value = reguh-rbetr.
    REPLACE '.' WITH ' ' INTO value.
    CONDENSE value NO-GAPS.
    SHIFT value RIGHT DELETING TRAILING space.
    TRANSLATE value USING ' 0'.
    hlp_str+8(15) = value.
    hlp_str+83(30) = space.
*********** Febraban version 8.7 ************************
    IF par_fbla = '089'.
      hlp_str+83(15) = space.
      IF NOT par_baav EQ space.            " with advice
        hlp_str+98(1)     =  '5'.
      ELSE.                                " w/o advice
        hlp_str+98(1)     =  '0'.
      ENDIF.
      hlp_str+99(6) = '000000'.
*      fill with ISPB code from the customizing table fiapbrd_ispb
*      based on the first 3 digits of the bank key
      SELECT SINGLE * FROM fiapbrd_ispb INTO ls_ispb_code
        WHERE bukrs = reguh-zbukr AND bank_key = reguh-zbnky(3).

      IF sy-subrc = 0.
        hlp_str+105(8) = ls_ispb_code-ispb_code.
      ENDIF.

    ENDIF.
***********Febraban version 8.7 ************************
    j_1bdmexb-b17  = hlp_str.

  ELSE.
    IF par_brla = '240'.
      CLEAR: j_1bdmexb-b17, lv_email_addr.
      SELECT smtp_addr FROM adr6 INTO lv_email_addr UP TO 1 ROWS WHERE addrnumber = reguh-zadnr ORDER BY PRIMARY KEY.
        j_1bdmexb-b17(100) = lv_email_addr.
      ENDSELECT.
    ENDIF.
  ENDIF.
*----End of Segment B---------------------------------------------------

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  FILL_LOT_TRAILER_BRADESCO240
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM fill_lot_trailer_bradesco240 .
*---Fill lot trailer----------------------------------------------------

  j_1bdmext2-t201   = reguh-ubnkl(3).
  j_1bdmext2-t202   = cnt_lot.
  j_1bdmext2-t203   = '5'.
  j_1bdmext2-t204   = space.

*         Count record number per lot plus lot header and trailer
  j_1bdmext2-t205   = cnt_rec_perlot + 2.

*         Total per lot
  j_1bdmext2-t206   = total_perlot.
  j_1bdmext2-t207 = '000000000000000000'.

  CLEAR:
  j_1bdmext2-t208,
  j_1bdmext2-t209.
  j_1bdmext2-t208 = '000000'.                               "2394906
  PERFORM store_on_file USING j_1bdmext2.
  PERFORM cr_lf.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  FILL_FEBR_SEGMENT_J52
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM fill_febr_segment_j52 .

  DATA: obj_badi_rffobr_u TYPE REF TO fiapbr_rffobr_u.   "BAdI object
  DATA: ls_reguh       TYPE reguh,
        ls_regud       TYPE regud,
        ls_file_header TYPE j_1bdmexh1,
        ls_lot_header  TYPE j_1bdmexh2.

  GET BADI obj_badi_rffobr_u.

  CLEAR: j_1bdfebj52.   "dataset for j-52

  cnt_rec_perlot  = cnt_rec_perlot + 1.
  cnt_records     = cnt_records  + 1.
  cnt_rec_detail  = cnt_rec_detail + 1."counts details, no records N 2180552

  j_1bdfebj52-j01 = j_1bdmexh1-h101.
  j_1bdfebj52-j02 = cnt_lot.
  j_1bdfebj52-j03 = '3'.
  j_1bdfebj52-j04 = cnt_rec_detail.  "Note 2180552
  j_1bdfebj52-j05 = 'J'.
  j_1bdfebj52-j06_1 = space.
  j_1bdfebj52-j06_2 = 00.
  j_1bdfebj52-j07 = '52'.
  j_1bdfebj52-j08 = '2'.

  "cnpj details
  j_1bdfebj52-j09 = j_1bwfield-cgc_number.
  j_1bdfebj52-j10 = j_1bdmexh1-h113.

  j_1bdfebj52-j11 = hlp_stkzn.
  j_1bdfebj52-j12 = hlp_taxcode.
  j_1bdfebj52-j13 = reguh-znme1.
  j_1bdfebj52-j17 = space.
  j_1bdfebj52-j18 = space.

  IF reguh-ubnkl(3) = '745'.
    IF reguh-zstc1 IS NOT INITIAL.
      j_1bdfebj52-j14 = '2'.
    ELSE.
      j_1bdfebj52-j14 = '1'.
    ENDIF.
  ENDIF.


  IF reguh-ubnkl(3) = '745' AND reguh-rzawe = 'B'.
    j_1bdfebj52-j15 = j_1bdfebj52-j09.
*    j_1bdfebj52-j15 = j_1bwfield-cgc_number.
  ENDIF.

*  Implement the BAdI Method "change_segment_j52" to fill the
*  following fields according to your requirement for Febraban
*  version 8.7:
*  1. j_1bdfebj52-J14 - Drawee/Payee Inscription Type
*  2. j_1bdfebj52-J15 - Draweer/Payee Insc. Numb
*  3. j_1bdfebj52-J16 - Drawee/Payee Name

  " Anderson Macedo
  IF reguh-ubnkl(3) = '745' AND reguh-rzawe = 'R'.
    j_1bdfebj52-j15 = '000000000000000'.
  ENDIF.


  CLEAR: ls_reguh, ls_regud, ls_file_header, ls_lot_header.
  ls_reguh = reguh.
  ls_regud = regud.
  ls_file_header = j_1bdmexh1.
  ls_lot_header = j_1bdmexh2.

  CALL BADI obj_badi_rffobr_u->change_segment_j52
    EXPORTING
      is_j_1bdmexh1  = ls_file_header
      is_reguh       = ls_reguh
      is_regud       = ls_regud
      iv_feb_version = par_fbla
      is_j_1bdmexh2  = ls_lot_header
      is_j_1bdmexa   = j_1bdmexa
      is_j_1bdmexj   = j_1bdmexj
    CHANGING
      cs_j_1bdfebj52 = j_1bdfebj52.

ENDFORM.                    " FILL_FEBR_SEGMENT_J52

*&---------------------------------------------------------------------*
*& Form fill_bradesco_5
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> J_1BDMEXB
*&---------------------------------------------------------------------*
FORM fill_bradesco_5  USING p_1bdmexb TYPE j_1bdmexb.

  CLEAR: zsfi_j_1bdmex5.

  zsfi_j_1bdmex5-501 = p_1bdmexb-b01.
  zsfi_j_1bdmex5-502 = p_1bdmexb-b02.
  zsfi_j_1bdmex5-503 = p_1bdmexb-b03 + 1.
  zsfi_j_1bdmex5-504 = '5'.
  zsfi_j_1bdmex5-509 = '001'.
  PERFORM f_trata_city_a16 CHANGING zsfi_j_1bdmex5-510.

  zsfi_j_1bdmex5-513 = regup-bldat+6(2) &&  regup-bldat+4(2) &&  regup-bldat(4).

ENDFORM.
