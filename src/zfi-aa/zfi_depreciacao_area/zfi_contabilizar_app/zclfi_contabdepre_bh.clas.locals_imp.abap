CLASS lcl_depre DEFINITION INHERITING FROM cl_abap_behavior_handler.

  PUBLIC SECTION.

    METHODS setup_messages IMPORTING p_task TYPE clike.
    METHODS setup_messages2 IMPORTING p_task TYPE clike.

  PRIVATE SECTION.

    METHODS contabilizar FOR MODIFY
      IMPORTING keys FOR ACTION _depre~contab.

    METHODS reav FOR MODIFY
      IMPORTING keys FOR ACTION _depre~reav.

    METHODS get_features FOR FEATURES
      IMPORTING keys REQUEST requested_features FOR _depre RESULT result.

    DATA gt_messages       TYPE STANDARD TABLE OF bapiret2.
    DATA gv_wait_async     TYPE abap_bool.

ENDCLASS.


CLASS lcl_depre IMPLEMENTATION.

  METHOD contabilizar.

    DATA lt_linhas TYPE TABLE OF zsfi_contab_depre.

*    READ ENTITIES OF zi_fi_contabilizar IN LOCAL MODE
*        ENTITY _depre
*          ALL FIELDS WITH CORRESPONDING #( keys )
*        RESULT DATA(lt_depre)
*        FAILED failed.

    SELECT bukrs,
           anln1,
           anln2,
           anlkl,
           gsber,
           kostl,
           gjahr,
           peraf,
           nafag01,
           nafag10,
           nafag11,
           nafag80,
           nafag82,
           nafag84,
           ajus80_01,
           ajus82_10,
           ajus84_11,
           total,
           contadepfiscal_01,
           contadespfiscal_01,
           contadepfiscal_10,
           contadespfiscal_10,
           contadepfiscal_11,
           contadespfiscal_11,
           contadepfiscal_80,
           contadespfiscal_80,
           contadepfiscal_82,
           contadespfiscal_82,
           contadepfiscal_84,
           contadespfiscal_84
      FROM zi_fi_contabilizar
       FOR ALL ENTRIES IN @keys
     WHERE bukrs = @keys-bukrs
       AND anln1 = @keys-anln1
       AND anln2 = @keys-anln2
       AND anlkl = @keys-anlkl
       AND gsber = @keys-gsber
       AND kostl = @keys-kostl
       AND gjahr = @keys-gjahr
       AND peraf = @keys-peraf
      INTO TABLE @DATA(lt_depre).

    LOOP AT lt_depre ASSIGNING FIELD-SYMBOL(<fs_depre>).

      DATA(ls_linha) = VALUE zsfi_contab_depre(
      bukrs             = <fs_depre>-bukrs
      anln1             = <fs_depre>-anln1
      anln2             = <fs_depre>-anln2
      anlkl             = <fs_depre>-anlkl
      gsber             = <fs_depre>-gsber
      kostl             = <fs_depre>-kostl
      gjahr             = <fs_depre>-gjahr
      peraf             = <fs_depre>-peraf
      moeda             = <fs_depre>-bukrs
      nafag01           = <fs_depre>-nafag01
      nafag10           = <fs_depre>-nafag10
      nafag11           = <fs_depre>-nafag11
      nafag80           = <fs_depre>-nafag80
      nafag82           = <fs_depre>-nafag82
      nafag84           = <fs_depre>-nafag84
      ajust80_01        = <fs_depre>-ajus80_01
      ajust82_10        = <fs_depre>-ajus82_10
      ajust84_11        = <fs_depre>-ajus84_11
      total             = <fs_depre>-total
      deprec_fiscal01   = <fs_depre>-contadepfiscal_01
      despesa_fiscal01  = <fs_depre>-contadespfiscal_01
      deprec_fiscal10   = <fs_depre>-contadepfiscal_10
      despesa_fiscal10  = <fs_depre>-contadespfiscal_10
      deprec_fiscal11   = <fs_depre>-contadepfiscal_11
      despesa_fiscal11  = <fs_depre>-contadespfiscal_11
      deprec_societ80   = <fs_depre>-contadepfiscal_80
      despesa_societ80  = <fs_depre>-contadespfiscal_80
      deprec_societ82   = <fs_depre>-contadepfiscal_82
      despesa_societ82  = <fs_depre>-contadespfiscal_82
      deprec_societ84   = <fs_depre>-contadepfiscal_84
      despesa_societ84  = <fs_depre>-contadespfiscal_84
       ).

      APPEND ls_linha TO lt_linhas.
    ENDLOOP.

    CALL FUNCTION 'ZFMFI_CONTAB_DEPRE'
      STARTING NEW TASK 'PRODENC'
      CALLING setup_messages ON END OF TASK
      EXPORTING
        it_linhas = lt_linhas.

    WAIT UNTIL gv_wait_async = abap_true.

    LOOP AT lt_depre ASSIGNING FIELD-SYMBOL(<fs_depre2>).
*    READ TABLE lt_depre ASSIGNING FIELD-SYMBOL(<fs_depre2>) INDEX 1.

      IF sy-tabix = 1.
        IF line_exists( gt_messages[ type = 'E' ] ).     "#EC CI_STDSEQ
*          APPEND VALUE #(  %tky = <fs_depre2>-%tky ) TO failed-_depre.
          APPEND VALUE #( bukrs  = <fs_depre2>-bukrs
                          anln1  = <fs_depre2>-anln1
                          anln2  = <fs_depre2>-anln2
                          anlkl  = <fs_depre2>-anlkl
                          gsber  = <fs_depre2>-gsber
                          kostl  = <fs_depre2>-kostl
                          gjahr  = <fs_depre2>-gjahr
                          peraf  = <fs_depre2>-peraf ) TO failed-_depre.
        ENDIF.

        LOOP AT gt_messages INTO DATA(ls_message).       "#EC CI_NESTED

*          APPEND VALUE #( %tky        = <fs_depre2>-%tky
          APPEND VALUE #( bukrs  = <fs_depre2>-bukrs
                         anln1  = <fs_depre2>-anln1
                         anln2  = <fs_depre2>-anln2
                         anlkl  = <fs_depre2>-anlkl
                         gsber  = <fs_depre2>-gsber
                         kostl  = <fs_depre2>-kostl
                         gjahr  = <fs_depre2>-gjahr
                         peraf  = <fs_depre2>-peraf
                         %msg   = new_message( id       = ls_message-id
                                               number   = ls_message-number
                                               v1       = ls_message-message_v1
                                               v2       = ls_message-message_v2
                                               v3       = ls_message-message_v3
                                               v4       = ls_message-message_v4
                                               severity = SWITCH  #( ls_message-type WHEN 'W' OR 'E'
                                                                                       THEN CONV #( 'I' )
                                                                                     ELSE CONV #( ls_message-type )  )
                          ) )
           TO reported-_depre.

        ENDLOOP.
*
*      ELSE.
*
*        APPEND VALUE #( %tky        = <fs_depre2>-%tky )
*        TO reported-_depre.

      ENDIF.

    ENDLOOP.


  ENDMETHOD.

  METHOD get_features.

    READ ENTITIES OF zi_fi_contabilizar IN LOCAL MODE
      ENTITY _depre
        FIELDS ( bukrs ) WITH CORRESPONDING #( keys )
      RESULT DATA(lt_header)
      FAILED failed.

    result =
         VALUE #(
         FOR ls_header IN lt_header
             ( %tky              = ls_header-%tky
              ) ).


  ENDMETHOD.

  METHOD reav.

    DATA lt_linhas TYPE TABLE OF zsfi_contab_depre.

    READ ENTITIES OF zi_fi_contabilizar IN LOCAL MODE
        ENTITY _depre
          ALL FIELDS WITH CORRESPONDING #( keys )
        RESULT DATA(lt_depre)
        FAILED failed.

    LOOP AT lt_depre ASSIGNING FIELD-SYMBOL(<fs_depre>).

      DATA(ls_linha) = VALUE zsfi_contab_depre(
      bukrs = <fs_depre>-bukrs
      anln1 = <fs_depre>-anln1
      anln2 = <fs_depre>-anln2
      anlkl = <fs_depre>-anlkl
      gsber = <fs_depre>-gsber
      kostl = <fs_depre>-kostl
      gjahr = <fs_depre>-gjahr
      peraf = <fs_depre>-peraf
      moeda = <fs_depre>-bukrs
      nafag01    = <fs_depre>-nafag01
      nafag10    = <fs_depre>-nafag10
      nafag11    = <fs_depre>-nafag11
      nafag80    = <fs_depre>-nafag80
      nafag82    = <fs_depre>-nafag82
      nafag84    = <fs_depre>-nafag84
      ajust80_01 = <fs_depre>-ajus80_01
      ajust82_10 = <fs_depre>-ajus82_10
      ajust84_11 = <fs_depre>-ajus84_11
      total = <fs_depre>-total
      deprec_fiscal01   = <fs_depre>-contadepfiscal_01
      despesa_fiscal01  = <fs_depre>-contadespfiscal_01
      deprec_fiscal10   = <fs_depre>-contadepfiscal_10
      despesa_fiscal10  = <fs_depre>-contadespfiscal_10
      deprec_fiscal11   = <fs_depre>-contadepfiscal_11
      despesa_fiscal11  = <fs_depre>-contadespfiscal_11
      deprec_societ80   = <fs_depre>-contadepfiscal_80
      despesa_societ80  = <fs_depre>-contadespfiscal_80
      deprec_societ82   = <fs_depre>-contadepfiscal_82
      despesa_societ82  = <fs_depre>-contadespfiscal_82
      deprec_societ84   = <fs_depre>-contadepfiscal_84
      despesa_societ84  = <fs_depre>-contadespfiscal_84
       ).

      APPEND ls_linha TO lt_linhas.
    ENDLOOP.

    CALL FUNCTION 'ZFMFI_CONTAB_REAV'
      STARTING NEW TASK 'REAV'
      CALLING setup_messages2 ON END OF TASK
      EXPORTING
        it_linhas = lt_linhas.

    WAIT UNTIL gv_wait_async = abap_true.

    READ TABLE lt_depre ASSIGNING FIELD-SYMBOL(<fs_depre2>) INDEX 1.

    IF line_exists( gt_messages[ type = 'E' ] ).         "#EC CI_STDSEQ
      APPEND VALUE #(  %tky = <fs_depre2>-%tky ) TO failed-_depre.
    ENDIF.

    LOOP AT gt_messages INTO DATA(ls_message).           "#EC CI_NESTED

      APPEND VALUE #( %tky        = <fs_depre2>-%tky
                      %msg        = new_message( id       = ls_message-id
                                                 number   = ls_message-number
                                                 v1       = ls_message-message_v1
                                                 v2       = ls_message-message_v2
                                                 v3       = ls_message-message_v3
                                                 v4       = ls_message-message_v4
                                                 severity = SWITCH  #( ls_message-type
                                                                                WHEN 'W' THEN CONV #( 'I' )
                                                                                ELSE CONV #( ls_message-type )  )
                       ) )
        TO reported-_depre.

    ENDLOOP.


  ENDMETHOD.

  METHOD setup_messages.

    RECEIVE RESULTS FROM FUNCTION 'ZFMFI_CONTAB_DEPRE'
        IMPORTING
          et_return = gt_messages.

    gv_wait_async = abap_true.

  ENDMETHOD.

  METHOD setup_messages2.

    RECEIVE RESULTS FROM FUNCTION 'ZFMFI_CONTAB_REAV'
    IMPORTING
      et_return = gt_messages.

    gv_wait_async = abap_true.

  ENDMETHOD.

ENDCLASS.

*"* use this source file for the definition and implementation of
*"* local helper classes, interface definitions and type
*"* declarations
