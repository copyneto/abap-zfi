CLASS lcl_Param DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    CONSTANTS gc_table TYPE tabname_auth VALUE 'ZTFI_IMOB_PARAM'.

    METHODS get_authorizations FOR AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR Param RESULT result.

    METHODS authorityCreate FOR VALIDATE ON SAVE
      IMPORTING keys FOR Param~authorityCreate.

    METHODS Zclas FOR VALIDATE ON SAVE IMPORTING key FOR Param~Zclas.
    METHODS Zaqui FOR VALIDATE ON SAVE IMPORTING key FOR Param~Zaqui.
    METHODS Zdepr FOR VALIDATE ON SAVE IMPORTING key FOR Param~Zdepr.

ENDCLASS.

CLASS lcl_Param IMPLEMENTATION.

  METHOD get_authorizations.
    READ ENTITIES OF zi_fi_param_imob IN LOCAL MODE
         ENTITY param
         ALL FIELDS WITH CORRESPONDING #( keys )
         RESULT DATA(lt_data)
         FAILED failed.

    CHECK lt_data IS NOT INITIAL.

    DATA: lv_update TYPE if_abap_behv=>t_xflag,
          lv_delete TYPE if_abap_behv=>t_xflag.

    LOOP AT lt_data ASSIGNING FIELD-SYMBOL(<fs_data>).

      IF requested_authorizations-%update EQ if_abap_behv=>mk-on.

        IF zclfi_auth_zfimtable=>update( gc_table ).
          lv_update = if_abap_behv=>auth-allowed.
        ELSE.
          lv_update = if_abap_behv=>auth-unauthorized.
        ENDIF.

      ENDIF.

      IF requested_authorizations-%delete EQ if_abap_behv=>mk-on.

        IF zclfi_auth_zfimtable=>delete( gc_table ).
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

  METHOD authoritycreate.

    CONSTANTS lc_area TYPE string VALUE 'VALIDATE_CREATE'.

    READ ENTITIES OF zi_fi_param_imob IN LOCAL MODE
        ENTITY Param
        ALL FIELDS WITH CORRESPONDING #( keys )
        RESULT DATA(lt_data).

    LOOP AT lt_data ASSIGNING FIELD-SYMBOL(<fs_data>).

      IF zclfi_auth_zfimtable=>create( gc_table ) EQ abap_false.

        APPEND VALUE #( %tky        = <fs_data>-%tky
                        %state_area = lc_area )
        TO reported-param.

        APPEND VALUE #( %tky = <fs_data>-%tky ) TO failed-param.

        APPEND VALUE #( %tky        = <fs_data>-%tky
                        %state_area = lc_area
                        %msg        = NEW zcxca_authority_check(
                                          severity = if_abap_behv_message=>severity-error
                                          textid   = zcxca_authority_check=>gc_create ) )
          TO reported-param.

      ENDIF.

    ENDLOOP.

  ENDMETHOD.

  METHOD zclas.

    CONSTANTS: lc_id     TYPE symsgid  VALUE 'ZMM_IMOBILIZADO',
               lc_number TYPE  symsgno VALUE 001,
               lc_p      TYPE spras VALUE 'P'.


    SELECT anlkl FROM Zi_ca_vh_anla
    WHERE spras = @lc_p
    INTO TABLE @DATA(lt_anlkl).

    IF sy-subrc EQ 0.

      READ ENTITY zi_fi_param_imob\\Param FROM VALUE #(
        FOR <fs_root_key> IN key ( %key-Zclas  = <fs_root_key>-%key
                                   %control    = VALUE #( Zclas = if_abap_behv=>mk-on ) ) )

        RESULT DATA(lt_resul).

      IF lt_resul IS NOT INITIAL AND
       NOT line_exists( lt_anlkl[ anlkl = lt_resul[ 1 ]-Zclas ] ).

        APPEND VALUE #( %key = lt_resul[ 1 ]-%key
                        %msg = new_message( id       = lc_id
                                            number   = lc_number
                                            v1 = lt_resul[ 1 ]-Zclas
                                            severity = if_abap_behv_message=>severity-error )
                        %element-Zclas = if_abap_behv=>mk-on ) TO reported-param.

      ENDIF.

    ENDIF.

  ENDMETHOD.

  METHOD zaqui.

    CONSTANTS: lc_id     TYPE symsgid  VALUE 'ZMM_IMOBILIZADO',
               lc_number TYPE symsgno VALUE 001,
               lc_ktopl  TYPE ktopl VALUE 'PC3C'.


    SELECT Saknr FROM Zi_ca_vh_skat
      WHERE ktopl = @lc_ktopl
    INTO TABLE @DATA(lt_saknr).

    IF sy-subrc EQ 0.

      READ ENTITY zi_fi_param_imob\\Param FROM VALUE #(
        FOR <fs_root_key> IN key ( %key-Zclas  = <fs_root_key>-%key ) )
        RESULT DATA(lt_resul).

      IF lt_resul IS NOT INITIAL AND
       NOT line_exists( lt_saknr[ saknr = lt_resul[ 1 ]-Zaqui ] ).

        APPEND VALUE #( %key = lt_resul[ 1 ]-%key
                        %msg = new_message( id       = lc_id
                                            number   = lc_number
                                            v1 = lt_resul[ 1 ]-Zaqui
                                            severity = if_abap_behv_message=>severity-error )
                        %element-Zaqui = if_abap_behv=>mk-on ) TO reported-param.

      ENDIF.

    ENDIF.

  ENDMETHOD.

  METHOD zdepr.

    CONSTANTS: lc_id     TYPE symsgid  VALUE 'ZMM_IMOBILIZADO',
               lc_number TYPE  symsgno VALUE 001,
               lc_ktopl  TYPE ktopl    VALUE 'PC3C'.


    SELECT Saknr FROM Zi_ca_vh_skat
     WHERE ktopl = @lc_ktopl
    INTO TABLE @DATA(lt_saknr).

    IF sy-subrc EQ 0.

      READ ENTITY zi_fi_param_imob\\Param FROM VALUE #(
        FOR <fs_root_key> IN key ( %key-Zclas = <fs_root_key>-%key ) )
        RESULT DATA(lt_resul).

      IF lt_resul IS NOT INITIAL AND
       NOT line_exists( lt_saknr[ saknr = lt_resul[ 1 ]-Zdepr ] ).

        APPEND VALUE #( %key = lt_resul[ 1 ]-%key
                        %msg = new_message( id       = lc_id
                                            number   = lc_number
                                            v1 = lt_resul[ 1 ]-Zdepr
                                            severity = if_abap_behv_message=>severity-error )
                        %element-Zdepr = if_abap_behv=>mk-on ) TO reported-param.

      ENDIF.

    ENDIF.

  ENDMETHOD.



ENDCLASS.
