CLASS lcl_ZI_FI_FORN_AGRUPADOR DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    CONSTANTS:
      BEGIN OF gc_existe_agrupador,
        id     TYPE symsgid VALUE 'ZFI_AGRUPA_FATURAS',
        number TYPE symsgno VALUE '006',
      END OF gc_existe_agrupador.

    METHODS validaAgrupador FOR VALIDATE ON SAVE
      IMPORTING keys FOR Agrupador~validaAgrupador.

    METHODS get_authorizations FOR AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR Agrupador RESULT result.

    METHODS authorityCreate FOR VALIDATE ON SAVE
      IMPORTING keys FOR Agrupador~authorityCreate.

ENDCLASS.

CLASS lcl_ZI_FI_FORN_AGRUPADOR IMPLEMENTATION.

  METHOD validaAgrupador.

    READ ENTITIES OF zi_fi_forn_agrupador IN LOCAL MODE
      ENTITY Agrupador
        FIELDS ( IdFornAgrupador
                 FornAgrupador
                 CompanyCode
                 AccountNumber
                 DocumentType  ) WITH CORRESPONDING #( keys )
    RESULT DATA(lt_agrupador) FAILED DATA(ls_erros).


    IF lt_agrupador IS INITIAL.
      RETURN.
    ENDIF.

    SELECT  id,
            forn_agrupador,
            bukrs,
            hkont,
            blart
     FROM ztfi_forn_Grp
      FOR ALL ENTRIES IN @lt_agrupador
      WHERE forn_agrupador = @lt_agrupador-FornAgrupador
        AND bukrs = @lt_agrupador-CompanyCode
        INTO TABLE @DATA(lt_agrupador_existe).

    IF sy-subrc EQ 0.
      SORT lt_agrupador_existe BY forn_agrupador bukrs.
    ENDIF.

    LOOP AT lt_agrupador ASSIGNING FIELD-SYMBOL(<fs_agrupador>).

      APPEND VALUE #(
        %tky        = <fs_agrupador>-%tky
        %state_area = 'VALIDAR_AGRUPADOR' )
      TO reported-agrupador.


      READ TABLE lt_agrupador_existe ASSIGNING FIELD-SYMBOL(<fs_agrupador_existe>)
          WITH KEY forn_agrupador = <fs_agrupador>-FornAgrupador
                   bukrs = <fs_agrupador>-CompanyCode
           BINARY SEARCH.

      IF sy-subrc EQ 0.

        APPEND VALUE #( %tky = <fs_agrupador>-%tky ) TO failed-agrupador.

        APPEND VALUE #(
          %tky        = <fs_agrupador>-%tky
          %state_area = 'VALIDAR_AGRUPADOR'
          %msg        =  new_message(
            id       = gc_existe_agrupador-id
            number   = gc_existe_agrupador-number
            severity = if_abap_behv_message=>severity-error
            v1       = |{ <fs_agrupador_existe>-forn_agrupador ALPHA = OUT }|
          )
          %element-fornagrupador = if_abap_behv=>mk-on
        ) TO reported-agrupador.
      ENDIF.

    ENDLOOP.


  ENDMETHOD.

  METHOD authoritycreate.

    CONSTANTS lc_area TYPE string VALUE 'VALIDATE_CREATE'.

    READ ENTITIES OF zi_fi_forn_agrupador IN LOCAL MODE
    ENTITY Agrupador
    ALL FIELDS WITH CORRESPONDING #( keys )
    RESULT DATA(lt_data).

    LOOP AT lt_data ASSIGNING FIELD-SYMBOL(<fs_data>).

      IF zclfi_auth_zfibukrs=>bukrs_create( <fs_data>-CompanyCode ) EQ abap_false.

        APPEND VALUE #( %tky        = <fs_data>-%tky
                        %state_area = lc_area )
        TO reported-agrupador.

        APPEND VALUE #( %tky = <fs_data>-%tky ) TO failed-agrupador.

        APPEND VALUE #( %tky        = <fs_data>-%tky
                        %state_area = lc_area
                        %msg        = NEW zcxca_authority_check(
                                          severity = if_abap_behv_message=>severity-error
                                          textid   = zcxca_authority_check=>gc_create )
                        %element-CompanyCode = if_abap_behv=>mk-on )
          TO reported-agrupador.

      ENDIF.

    ENDLOOP.

  ENDMETHOD.

  METHOD get_authorizations.

    READ ENTITIES OF zi_fi_forn_agrupador IN LOCAL MODE
    ENTITY Agrupador
    ALL FIELDS WITH CORRESPONDING #( keys )
    RESULT DATA(lt_data)
    FAILED failed.

    CHECK lt_data IS NOT INITIAL.

    DATA: lv_update TYPE if_abap_behv=>t_xflag,
          lv_delete TYPE if_abap_behv=>t_xflag.

    LOOP AT lt_data ASSIGNING FIELD-SYMBOL(<fs_data>).

      IF requested_authorizations-%update EQ if_abap_behv=>mk-on.

        IF zclfi_auth_zfibukrs=>bukrs_update( <fs_data>-CompanyCode ).
          lv_update = if_abap_behv=>auth-allowed.
        ELSE.
          lv_update = if_abap_behv=>auth-unauthorized.
        ENDIF.

      ENDIF.

      IF requested_authorizations-%delete EQ if_abap_behv=>mk-on.

        IF zclfi_auth_zfibukrs=>bukrs_delete( <fs_data>-CompanyCode ).
          lv_delete = if_abap_behv=>auth-allowed.
        ELSE.
          lv_delete = if_abap_behv=>auth-unauthorized.
        ENDIF.

      ENDIF.

      APPEND VALUE #( %tky = <fs_data>-%tky
                      %update = lv_update
                      %delete = lv_delete )
             TO result.

    ENDLOOP.

  ENDMETHOD.

ENDCLASS.
