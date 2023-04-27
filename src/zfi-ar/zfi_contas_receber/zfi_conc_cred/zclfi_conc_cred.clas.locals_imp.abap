CLASS lhc_credito DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS updatecurrency FOR DETERMINE ON MODIFY
      IMPORTING keys FOR credito~updatecurrency.

    METHODS validateid FOR VALIDATE ON SAVE
      IMPORTING keys FOR credito~validateid.

    METHODS obligfields FOR VALIDATE ON SAVE
      IMPORTING keys FOR credito~obligfields.

    METHODS authorityCreate FOR VALIDATE ON SAVE
      IMPORTING keys FOR credito~authorityCreate.

    METHODS get_authorizations FOR AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR credito RESULT result.

ENDCLASS.

CLASS lhc_credito IMPLEMENTATION.

  METHOD updatecurrency.

    READ ENTITIES OF zi_fi_conc_cred IN LOCAL MODE
    ENTITY credito
    ALL FIELDS
    WITH CORRESPONDING #( keys )
    RESULT DATA(lt_cred).

    MODIFY ENTITIES OF zi_fi_conc_cred IN LOCAL MODE
    ENTITY credito
    UPDATE SET FIELDS WITH VALUE #( FOR ls_header IN lt_cred (
                                        %key = ls_header-%key
                                        moeda = 'BRL'
                                        %control = VALUE #( moeda = if_abap_behv=>mk-on )
                                    ) ) REPORTED DATA(lt_reported).

    reported = CORRESPONDING #( DEEP lt_reported ).


  ENDMETHOD.

  METHOD validateid.

    CONSTANTS: lc_id     TYPE sy-msgid VALUE '00',
               lc_number TYPE sy-msgno VALUE '398',
               lc_erro   TYPE sy-msgty VALUE 'E'.

    READ ENTITIES OF zi_fi_conc_cred IN LOCAL MODE
        ENTITY credito
        ALL FIELDS WITH CORRESPONDING #( keys )
        RESULT DATA(lt_cred).

    LOOP AT lt_cred ASSIGNING FIELD-SYMBOL(<fs_cred>).

      IF <fs_cred>-identificacao = '2'.

        IF <fs_cred>-diasmin IS NOT INITIAL.

          APPEND VALUE #( %tky = <fs_cred>-%tky ) TO failed-credito.

          APPEND VALUE #( %tky        = <fs_cred>-%tky
                          %state_area = 'DIASMIN'
                          %msg        = new_message( id       = lc_id
                                                     number   = lc_number
                                                     v1       = TEXT-e01
                                                     severity = CONV #( lc_erro ) )
                          %element-diasmin = if_abap_behv=>mk-on )  TO reported-credito.

        ENDIF.

        IF <fs_cred>-residualmin IS NOT INITIAL.

          IF failed-credito IS INITIAL.
            APPEND VALUE #( %tky = <fs_cred>-%tky ) TO failed-credito.
          ENDIF.

          APPEND VALUE #( %tky        = <fs_cred>-%tky
                          %state_area = 'RESIDUALMIN'
                          %msg        = new_message( id       = lc_id
                                                     number   = lc_number
                                                     v1       = TEXT-e01
                                                     severity = CONV #( lc_erro ) )
                          %element-residualmin = if_abap_behv=>mk-on )  TO reported-credito.

        ENDIF.

        IF <fs_cred>-origem IS INITIAL.

          IF failed-credito IS INITIAL.
            APPEND VALUE #( %tky = <fs_cred>-%tky ) TO failed-credito.
          ENDIF.

          APPEND VALUE #( %tky        = <fs_cred>-%tky
                          %state_area = 'ORIGEM'
                          %msg        = new_message( id       = lc_id
                                                     number   = lc_number
                                                     v1       = TEXT-e02
                                                     severity = CONV #( lc_erro ) )
                          %element-origem = if_abap_behv=>mk-on )  TO reported-credito.

        ENDIF.

      ELSE.

        IF <fs_cred>-origem IS NOT INITIAL.

          IF failed-credito IS INITIAL.
            APPEND VALUE #( %tky = <fs_cred>-%tky ) TO failed-credito.
          ENDIF.

          APPEND VALUE #( %tky        = <fs_cred>-%tky
                          %state_area = 'ORIGEM'
                          %msg        = new_message( id       = lc_id
                                                     number   = lc_number
                                                     v1       = TEXT-e03
                                                     severity = CONV #( lc_erro ) )
                          %element-origem = if_abap_behv=>mk-on )  TO reported-credito.

        ENDIF.


      ENDIF.

    ENDLOOP.

  ENDMETHOD.

  METHOD obligfields.

    CONSTANTS: lc_id     TYPE sy-msgid VALUE '00',
               lc_number TYPE sy-msgno VALUE '398',
               lc_erro   TYPE sy-msgty VALUE 'E'.

    READ ENTITIES OF zi_fi_conc_cred IN LOCAL MODE
        ENTITY credito
        ALL FIELDS WITH CORRESPONDING #( keys )
        RESULT DATA(lt_cred).

    LOOP AT lt_cred ASSIGNING FIELD-SYMBOL(<fs_cred>).

      IF <fs_cred>-empresa IS INITIAL.

        IF failed-credito IS INITIAL.
          APPEND VALUE #( %tky = <fs_cred>-%tky ) TO failed-credito.
        ENDIF.

        APPEND VALUE #( %tky        = <fs_cred>-%tky
                        %state_area = 'EMPRESA'
                        %msg        = new_message( id       = lc_id
                                                   number   = lc_number
                                                   v1       = TEXT-e04
                                                   severity = CONV #( lc_erro ) )
                        %element-empresa = if_abap_behv=>mk-on )  TO reported-credito.

      ENDIF.

      IF <fs_cred>-chavelanc IS INITIAL.

        IF failed-credito IS INITIAL.
          APPEND VALUE #( %tky = <fs_cred>-%tky ) TO failed-credito.
        ENDIF.

        APPEND VALUE #( %tky        = <fs_cred>-%tky
                        %state_area = 'CHAVELANC'
                        %msg        = new_message( id       = lc_id
                                                   number   = lc_number
                                                   v1       = TEXT-e04
                                                   severity = CONV #( lc_erro ) )
                        %element-chavelanc = if_abap_behv=>mk-on )  TO reported-credito.

      ENDIF.

      IF <fs_cred>-tipodoc IS INITIAL.

        IF failed-credito IS INITIAL.
          APPEND VALUE #( %tky = <fs_cred>-%tky ) TO failed-credito.
        ENDIF.

        APPEND VALUE #( %tky        = <fs_cred>-%tky
                        %state_area = 'TIPODOC'
                        %msg        = new_message( id       = lc_id
                                                   number   = lc_number
                                                   v1       = TEXT-e04
                                                   severity = CONV #( lc_erro ) )
                        %element-tipodoc = if_abap_behv=>mk-on )  TO reported-credito.

      ENDIF.

      IF <fs_cred>-identificacao IS INITIAL.

        IF failed-credito IS INITIAL.
          APPEND VALUE #( %tky = <fs_cred>-%tky ) TO failed-credito.
        ENDIF.

        APPEND VALUE #( %tky        = <fs_cred>-%tky
                        %state_area = 'IDENTIFICACAO'
                        %msg        = new_message( id       = lc_id
                                                   number   = lc_number
                                                   v1       = TEXT-e04
                                                   severity = CONV #( lc_erro ) )
                        %element-identificacao = if_abap_behv=>mk-on )  TO reported-credito.

      ENDIF.

    ENDLOOP.

  ENDMETHOD.

  METHOD authorityCreate.

    CONSTANTS: lc_area TYPE string VALUE 'VALIDATE_CREATE'.

    READ ENTITIES OF zi_fi_conc_cred IN LOCAL MODE
        ENTITY  Credito
        ALL FIELDS WITH CORRESPONDING #( keys )
        RESULT DATA(lt_data).

    LOOP AT lt_data ASSIGNING FIELD-SYMBOL(<fs_data>).

      IF zclfi_auth_zfibukrs=>bukrs_create( <fs_data>-Empresa ) EQ abap_false.

        APPEND VALUE #( %tky        = <fs_data>-%tky
                        %state_area = lc_area )
        TO reported-Credito.

        APPEND VALUE #( %tky = <fs_data>-%tky ) TO failed-Credito.

        APPEND VALUE #( %tky        = <fs_data>-%tky
                        %state_area = lc_area
                        %msg        = NEW zcxca_authority_check(
                                          severity = if_abap_behv_message=>severity-error
                                          textid   = zcxca_authority_check=>gc_create ) )
          TO reported-Credito.
      ENDIF.

    ENDLOOP.

  ENDMETHOD.

  METHOD get_authorizations.

    READ ENTITIES OF zi_fi_conc_cred IN LOCAL MODE
         ENTITY Credito
         ALL FIELDS WITH CORRESPONDING #( keys )
         RESULT DATA(lt_data)
         FAILED failed.

    CHECK lt_data IS NOT INITIAL.

    DATA: lv_update TYPE if_abap_behv=>t_xflag,
          lv_delete TYPE if_abap_behv=>t_xflag.

    LOOP AT lt_data ASSIGNING FIELD-SYMBOL(<fs_data>).

      IF requested_authorizations-%update EQ if_abap_behv=>mk-on.

        IF zclfi_auth_zfibukrs=>bukrs_update( <fs_data>-Empresa ).
          lv_update = if_abap_behv=>auth-allowed.
        ELSE.
          lv_update = if_abap_behv=>auth-unauthorized.
        ENDIF.

      ENDIF.

      IF requested_authorizations-%delete EQ if_abap_behv=>mk-on.

        IF zclfi_auth_zfibukrs=>bukrs_delete( <fs_data>-Empresa ).
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
