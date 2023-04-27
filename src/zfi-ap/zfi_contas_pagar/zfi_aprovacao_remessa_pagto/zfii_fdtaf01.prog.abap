*&---------------------------------------------------------------------*
*& Include          ZFII_FDTAF01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form zcall_fdta
*&---------------------------------------------------------------------*
FORM zcall_fdta  CHANGING pt_regut TYPE epic_t_regut.

  DATA: up_stop  TYPE p,
        up_subrc TYPE p.

  LOOP AT pt_regut ASSIGNING FIELD-SYMBOL(<fs_regut>).
    APPEND CORRESPONDING #( <fs_regut> ) TO tab_regut
      ASSIGNING FIELD-SYMBOL(<fs_tab_regut>).
    <fs_tab_regut>-selected = abap_true.
  ENDLOOP.

  PERFORM fill_tab_selected.

  LOOP AT tab_selected.
    PERFORM zdownload_file
       USING tab_selected-index
             up_subrc
             up_stop.
  ENDLOOP.

ENDFORM.

*----------------------------------------------------------------------*
* FORM ZGET_DOWNLOAD_NAME
*----------------------------------------------------------------------*
FORM zget_download_name USING ps_regut TYPE regut
                              p_filename.

  CONSTANTS:
    "! Formas de pagamento para cada tipo de arquivo
    BEGIN OF lc_forma_pagto,
      fornecedor  TYPE string VALUE 'TUBG6X',
      tributos    TYPE string VALUE '38',
      cobranca    TYPE string VALUE '1DAZ',
      riscosacado TYPE string VALUE 'R',
    END OF lc_forma_pagto.

  CONSTANTS: lc_saida_ctas_pagar TYPE ze_autobanc_tp_proc VALUE '01',
             lc_pagto_forn(3)    TYPE c VALUE 'PGF',
             lc_cobranca(3)      TYPE c VALUE 'COB',
             lc_replace(2)       TYPE c VALUE '&1'.

  DATA: lv_diretorio TYPE ztfi_autbanc_dir-diretorio,
        lv_rzawe     TYPE reguh-rzawe.


  SELECT SINGLE diretorio
    FROM ztfi_autbanc_dir
    INTO lv_diretorio
    WHERE bukrs EQ ps_regut-zbukr
      AND tipo  EQ lc_saida_ctas_pagar.
  IF sy-subrc NE 0.
    RETURN.
  ENDIF.

  p_filename = |{ lv_diretorio }/{ lc_replace }{ ps_regut-laufd }_{ ps_regut-zbukr }_{ ps_regut-banks }_{ ps_regut-laufi }.txt|.

*** Incluído por Diego Lima - 25/05/22 -> Funcional FI - Raphael Rocha

  SELECT SINGLE rzawe
    FROM reguh
    INTO lv_rzawe
   WHERE laufd EQ ps_regut-laufd
     AND laufi EQ ps_regut-laufi
     AND xvorl EQ ps_regut-xvorl
     AND zbukr EQ ps_regut-zbukr.
  IF sy-subrc NE 0.
    RETURN.
  ENDIF.

  IF lv_rzawe CA lc_forma_pagto-fornecedor. "Arquivos de "Pagamento a Fornecedor".
    REPLACE lc_replace IN p_filename WITH lc_pagto_forn.
  ELSEIF lv_rzawe CA lc_forma_pagto-tributos. "Arquivos de "Pagamento de Tributos".
    REPLACE lc_replace IN p_filename WITH lc_pagto_forn.
  ELSEIF lv_rzawe CA lc_forma_pagto-cobranca.
    REPLACE lc_replace IN p_filename WITH lc_cobranca.
  ELSE.
    RETURN.
  ENDIF.

*** Incluído por Diego Lima - 25/05/22 -> Funcional fi - Raphael Rocha

ENDFORM.

*----------------------------------------------------------------------*
* FORM ZDOWNLOAD_FILE
*----------------------------------------------------------------------*
FORM zdownload_file USING
            hlp_curs
            result
            abbruch.
  tab_regut = tab_regut[ hlp_curs ].

  DATA:
    up_kombi   LIKE hlp_kombi_zusatz,
    up_komment LIKE hlp_kommentar,
    up_label   LIKE regud-label.


*- (1) Daten einlesen -------------------------------------------------*
  REFRESH tab_xfile.
  CLEAR   hlp_tab_temse_laenge.

  PERFORM read_data(saplfpaym05)
                    TABLES   tab_xfile
                    USING    tab_regut-fsnam
                             tab_regut-tsnam
                             tab_regut
                    CHANGING result
                             hlp_rsts_rc
                             hlp_rsts_msg
                             hlp_fbhandle
                             hlp_tab_temse_laenge.

  IF result NE 0.                      "Fehler beim Lesen
    EXIT.
  ENDIF.

* Reset Codepage if we have both TemSe and File           "nte1423701
  IF tab_regut-tsnam <> space AND tab_regut-fsnam <> space. "nte1423701
    CLEAR tab_regut-codepage.                               "nte1423701
  ENDIF.

* Unicode-changes
  IF tab_regut-codepage IS INITIAL.
    PERFORM get_codepage(saplfpaym05) USING tab_regut-tsnam
                         CHANGING tab_regut-codepage.
  ENDIF.

  IF tab_regut-saprl IS INITIAL.
    PERFORM replace_old_characters(saplfpaym05) TABLES tab_xfile
                                   USING  tab_regut-codepage.
  ENDIF.



*-(2) Ausgabe: Laufdatum/Lauf-ID   Eingabe: Dateiname -----------------*
  PERFORM get_kombi_zusatz USING tab_regut up_kombi.

  up_label = tab_regut-renum.          "Kopie

  CLEAR up_komment.                    "Reset Kommentarzeile im Dynpro
  IF NOT tab_regut-dwdat IS INITIAL.   "Download wurde schonmal gemacht
    up_komment = TEXT-052.
  ENDIF.
  IF tab_regut-xvorl NE space.         "Vorschlagslauf
    up_komment = TEXT-053.
  ENDIF.

  regut = tab_regut.                   "Felder für Dynpro kopieren
  rlgrap-filename = regut-dwnam.       "Alten Wert kopieren

*** Início Jefferson Fujii
*
*  IF rlgrap-filename IS INITIAL.       "Kein Zielfile-Name angegeben
*    rlgrap-filename+0 = 'A:\'.         "Muster-Namen vorbelegen
*    rlgrap-filename+3 = tab_regut-dtfor.
*  ENDIF.
*
**- (3) Name von Ausgabefile bestimmen ---------------------------------*
*  PERFORM get_download_name
*       USING up_kombi
*             rlgrap-filename
*             up_label
*             up_komment
*             abbruch
*             result.
*  IF result NE 0 OR abbruch NE 0.      "Fehler oder Abbruch
*    EXIT.
*  ENDIF.

  DATA ls_reguh TYPE reguh.

  SELECT SINGLE *
    INTO ls_reguh
    FROM reguh
   WHERE laufd = regut-laufd
     AND laufi = regut-laufi
     AND xvorl = regut-xvorl
     AND zbukr = regut-zbukr.

  "Efetua a gravação do arquivo de remessa na pasta de saída para a VAN (FINNET).
  zclfi_automatizacao_bancaria=>gravar_saida( is_reguh = ls_reguh iv_tipo = 1 ).

*  PERFORM zget_download_name USING regut rlgrap-filename.
*
*** Fim Jefferson Fujii


* begin 2010603
* we need no validation for download to frontend
*  DATA ld_filename(255) TYPE C.
*  ld_filename = rlgrap-filename.
*  CALL FUNCTION 'FILE_VALIDATE_NAME' " note 1511617
*  EXPORTING
*    logical_filename  = 'FI_DME_DOWNLOAD_FILE'
*    parameter_1       = sy-cprog
*  CHANGING
*    physical_filename = ld_filename
*  EXCEPTIONS
*    validation_failed          = 1
*    logical_filename_not_found = 2
*    OTHERS                     = 3.
*  IF sy-subrc <> 0.
*    MESSAGE ID sy-msgid TYPE 'I' NUMBER sy-msgno
*    WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
*    result = 100.
*    EXIT.
*  ENDIF.
* end 2010603

*- (4) Download der gelesenen Daten -----------------------------------*
*  PERFORM ws_download_to_pc USING rlgrap-filename
*  PERFORM zdownload_to_server USING rlgrap-filename
*                                    tab_regut-codepage
*                                    tab_regut-dtfor
*                                    tab_regut-dttyp
*                                    tab_regut-laufi
*                                    result.
*  IF result NE 0.                      "Nichts geschrieben !
*    EXIT.
*  ELSE.
*    regut-dwnam = rlgrap-filename.
*  ENDIF.
*
**- (5) Bei Disketten ggfs Volume-Label schreiben ----------------------*
*  IF fdta-label_sel EQ 'X'.            "Label ist selektiert
*    PERFORM set_label USING regut-dwnam up_label.
*  ENDIF.
*
**- (6) Verwaltungsdaten aktualisieren ---------------------------------*
*  tab_regut-dwnam = regut-dwnam.
*  tab_regut-dwdat = sy-datlo.
*  tab_regut-dwtim = sy-timlo.
*  tab_regut-dwusr = sy-uname.
*  MODIFY tab_regut INDEX hlp_curs.
*
*  regut = tab_regut.                   "Änderungen auf DB schreiben
*  UPDATE regut.
*  IF sy-subrc NE 0.
*    result = 20.
*  ENDIF.
*
**- (7) User-Exit aufrufen ---------------------------------------------*
*  REFRESH tab_regut_exit.
*  tab_regut_exit = regut.
*  APPEND tab_regut_exit.
*  PERFORM userexit_001.

ENDFORM.                               "ZDOWNLOAD_FILE


*----------------------------------------------------------------------*
* FORM ZDOWNLOAD_TO_SERVER
*----------------------------------------------------------------------*
FORM zdownload_to_server
     USING VALUE(filename) LIKE rlgrap-filename
           in_codepage LIKE regut-codepage
           dtfor TYPE regut-dtfor
           dttyp TYPE regut-dttyp
           laufi TYPE regut-laufi
           result.

  CONSTANTS x_linesize TYPE i VALUE 128.

  TYPES x_linetype TYPE x LENGTH x_linesize.

  DATA:
    user_codepage(4)      TYPE c,
    out_codepage          LIKE regut-codepage,
    tab_x                 TYPE STANDARD TABLE OF x_linetype,
    wa_x                  TYPE xstring,
    wa_xfile              LIKE LINE OF tab_xfile,
    filename_string       TYPE string,
    linesize              TYPE i,
    lines                 TYPE i,
    length                TYPE i,
    fill_length           TYPE i,
    last_length           TYPE i,
    filesize              TYPE i,
    after_download_length TYPE i,
    l_format_cp           TYPE cpcodepage.

* Convert data to codepage defined in format, if not defined than to
* codepage in user parameter dcp, if not there then default with 1100

  CLEAR l_format_cp.
  IF laufi+5(1) = 'M'.
    DATA g_function TYPE rs38l_fnam.
    g_function = 'FKK_DME_FDTA_CODEPAGE_GET'.
    CALL FUNCTION 'FUNCTION_EXISTS'
      EXPORTING
        funcname           = g_function
      EXCEPTIONS
        function_not_exist = 1.
    IF sy-subrc = 0.
      CALL FUNCTION g_function
        EXPORTING
          i_formi    = dtfor
        IMPORTING
          e_codepage = l_format_cp
        EXCEPTIONS
          OTHERS     = 1.
    ENDIF.

* begin 2832354
  ELSEIF dttyp = '90'.  " Multi bank connectivity

    DATA : lx_string          TYPE xstring,
           ls_encoding_string TYPE string.

    READ TABLE tab_xfile INDEX 1 INTO lx_string.
*   search for string encoding = ... in file
    PERFORM check_encoding_of_xml_file USING lx_string in_codepage
                                       CHANGING ls_encoding_string.
    IF ls_encoding_string = 'utf-8' OR ls_encoding_string = 'UTF-8'.
      l_format_cp = '4110'.
    ELSEIF ls_encoding_string = 'utf-16' OR ls_encoding_string = 'UTF-16'.
*     keep in utf-16, no conversion, file stored in Temse
      l_format_cp = in_codepage.
    ELSE.
      CALL FUNCTION 'FI_PAYM_FORMAT_READ_CODEPAGE'
        EXPORTING
          i_formi    = dtfor
        IMPORTING
          e_codepage = l_format_cp
        EXCEPTIONS
          not_found  = 1
          OTHERS     = 2.
    ENDIF.
*  end 2832354

  ELSEIF dttyp = '01' OR dttyp = '04' OR dttyp = '06'.
    CALL FUNCTION 'FI_PAYM_FORMAT_READ_CODEPAGE'
      EXPORTING
        i_formi    = dtfor
      IMPORTING
        e_codepage = l_format_cp
      EXCEPTIONS
        not_found  = 1
        OTHERS     = 2.
    IF l_format_cp IS INITIAL AND cl_abap_char_utilities=>charsize > 1 AND
        dttyp = '04'.  " XML
      l_format_cp = '4110'.
    ENDIF.
  ENDIF.
  IF NOT l_format_cp IS INITIAL.
    IF in_codepage = l_format_cp.
* file aready converted to codepage assigned in the format configuration
      out_codepage = in_codepage.
    ELSE.
* old file that was not converted yet: convert it now
      out_codepage = l_format_cp.
    ENDIF.
  ELSE.
*   no codepage in customizing specified
    GET PARAMETER ID 'DCP' FIELD user_codepage.

* begin 2199778
*   if user_codepage is initial.
*      out_codepage = '1100'.
*    elseif user_codepage = 'NONE'.
*      out_codepage = in_codepage.
*    else.
*      out_codepage = user_codepage.
*    endif.
    IF cl_abap_char_utilities=>charsize > 1.
*     unicode system
      IF ( in_codepage = '4102' OR in_codepage = '4103' ).
*     unicode / system codepage
        IF user_codepage IS INITIAL.
          out_codepage = '1100'.
        ELSEIF user_codepage = 'NONE'.
          out_codepage = in_codepage.
        ELSE.
          out_codepage = user_codepage.
        ENDIF.
      ELSE.
*       ignore DCP parameter, file is already in specific codepage (regut-codepage)
        out_codepage = in_codepage.
      ENDIF.
    ELSE.
*     non unicode system
      IF user_codepage IS INITIAL.
        out_codepage = '1100'.
      ELSEIF user_codepage = 'NONE'.
        out_codepage = in_codepage.
      ELSE.
        out_codepage = user_codepage.
      ENDIF.
    ENDIF.
  ENDIF.
* end 2199778

  IF in_codepage <> out_codepage.
    PERFORM convert_data TABLES tab_xfile
                         USING  in_codepage
                                out_codepage.
  ENDIF.

*-Write data into tab_x (standard table of x_linetype)

  DATA rest TYPE i.
  rest = 0. filesize = 0.
  DATA ld_rest LIKE wa_xfile.
  LOOP AT tab_xfile INTO wa_xfile.
    IF rest <> 0.
      CONCATENATE ld_rest(rest) wa_xfile
             INTO wa_xfile IN BYTE MODE.
    ENDIF.
* concatenate
    rest = xstrlen( wa_xfile ).
    WHILE rest >= x_linesize.    " 128
      wa_x = wa_xfile(x_linesize).
      APPEND wa_x TO tab_x.
      filesize = filesize + x_linesize.
      SHIFT wa_xfile BY x_linesize PLACES IN BYTE MODE.
      rest = rest - x_linesize.
    ENDWHILE.
    ld_rest = wa_xfile.
*  this condition is now always true:
*    rest_ = 0 or rest < x_linesize  and
*    contents in ld_rest(rest).
  ENDLOOP.
  IF rest > 0.
    wa_x = wa_xfile(rest).
    filesize = filesize + rest.
    APPEND wa_x TO tab_x.
  ENDIF.

* gui_download of tab_x

*** Início Jefferson Fujii
*
*  filename_string = filename.
*
*  CALL METHOD cl_gui_frontend_services=>gui_download
*    EXPORTING
*      bin_filesize         = filesize
*      filename             = filename_string
*      filetype             = 'BIN'
*      no_auth_check        = 'X'
*    IMPORTING
*      filelength           = after_download_length
*    CHANGING
*      data_tab             = tab_x
*    EXCEPTIONS
*      file_not_found       = 91
*      file_write_error     = 92
*      filesize_not_allowed = 93
*      invalid_type         = 95
*      no_batch             = 96
*      OTHERS               = 97.
*  hlp_file_exit = filename.
*  IF sy-subrc NE 0.                              "download error
*    result = sy-subrc.
*  ELSEIF after_download_length EQ 0.             "nothing written
*    result = 97.
*  ENDIF.

  hlp_file_exit = filename.

  OPEN DATASET filename FOR OUTPUT IN BINARY MODE.
  result = sy-subrc.
  CHECK result IS INITIAL.

  LOOP AT tab_x ASSIGNING FIELD-SYMBOL(<fs_line>).
    TRANSFER <fs_line> TO filename.
  ENDLOOP.

  CLOSE DATASET filename.
  result = sy-subrc.
  CHECK result IS INITIAL.

*** Fim Jefferson Fujii
ENDFORM.                               "ZDOWNLOAD_TO_SERVER
