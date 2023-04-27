FUNCTION zfmfi_autbanc_grava_arqremessa.
*"----------------------------------------------------------------------
*"*"Interface local:
*"  IMPORTING
*"     REFERENCE(IS_REGUT) TYPE  REGUT
*"  EXPORTING
*"     REFERENCE(EV_ARQ) TYPE  STRING
*"----------------------------------------------------------------------
  CONSTANTS:
    lc_unicode_utf8 TYPE tcp00-cpcodepage VALUE '4110'.

  TYPES: BEGIN OF ty_fbhandle,
           handle       TYPE rststype-handle,
           curpart      TYPE i,
           filler(4),
           client       TYPE rststype-client,
           name         TYPE rststype-name,
           part         TYPE tst01-dpart,
           apppart(1),
           nxtpart(1),
           binary(1),
           alline(1),
           type         TYPE rststype-type,
           rectyp       TYPE rststype-rectyp,
           charco       TYPE rststype-charco,
           queue(1),
           life         TYPE i,
           lang(1),
           stotyp(1),
           path(77),
           compr(1),
           prom         TYPE rststype-prom,
           norollb(1),
           synccom(1),
           authority(4),
           openkind(3),
           halfrec(1),
         END OF ty_fbhandle.

  DATA: lt_xfile        TYPE STANDARD TABLE OF xstring,
        ls_regut        TYPE regut,
        ls_fbhandle     TYPE ty_fbhandle,
        lv_temse_laenge TYPE p,
        lv_result       TYPE p,
        lv_rsts_rc      TYPE c LENGTH 5,
        lv_rsts_msg     TYPE c LENGTH 100,
        ls_x            TYPE xstring,
        lv_arquivo      TYPE string.


  ls_regut = is_regut.
  CHECK NOT ls_regut IS INITIAL.
  "Busca o arquivo já salvo na transação FDTA.
  PERFORM read_data IN PROGRAM saplfpaym05 TABLES lt_xfile
                                            USING ls_regut-fsnam
                                                  ls_regut-tsnam
                                                  ls_regut
                                         CHANGING lv_result
                                                  lv_rsts_rc
                                                  lv_rsts_msg
                                                  ls_fbhandle
                                                  lv_temse_laenge.

  LOOP AT lt_xfile ASSIGNING FIELD-SYMBOL(<fs_xfile>).
    FREE lv_arquivo.
    CALL FUNCTION 'LXE_COMMON_XSTRING_TO_STRING'
      EXPORTING
        in_xstring  = <fs_xfile>
        ex_codepage = lc_unicode_utf8
      IMPORTING
        ex_string   = lv_arquivo
      EXCEPTIONS
        error       = 1
        OTHERS      = 2.

    IF sy-subrc IS INITIAL.
      CONCATENATE ev_arq
                  lv_arquivo
             INTO ev_arq.
    ELSE.
      EXIT.
    ENDIF.
  ENDLOOP.


ENDFUNCTION.
