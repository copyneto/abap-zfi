*"* use this source file for the definition and implementation of
*"* local helper classes, interface definitions and type
*"* declarations
CLASS lcl_TIPO_MOVI DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    CONSTANTS gc_table TYPE tabname_auth VALUE 'ZTFI_TIPO_MOVI'.

    METHODS authorityCreate FOR VALIDATE ON SAVE
      IMPORTING keys FOR _TipoMov~authorityCreate.

    METHODS get_authorizations FOR AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR _TipoMov RESULT result.

ENDCLASS.

CLASS lcl_TIPO_MOVI IMPLEMENTATION.

  METHOD authorityCreate.

    CONSTANTS lc_area TYPE string VALUE 'VALIDATE_CREATE'.

    READ ENTITIES OF zi_fi_tipo_movi IN LOCAL MODE
        ENTITY  _TipoMov
        ALL FIELDS WITH CORRESPONDING #( keys )
        RESULT DATA(lt_data).

    LOOP AT lt_data ASSIGNING FIELD-SYMBOL(<fs_data>).

      IF zclfi_auth_zfimtable=>create( gc_table ) EQ abap_false.

        APPEND VALUE #( %tky        = <fs_data>-%tky
                        %state_area = lc_area )
        TO reported-_tipomov.

        APPEND VALUE #( %tky = <fs_data>-%tky ) TO failed-_tipomov.

        APPEND VALUE #( %tky        = <fs_data>-%tky
                        %state_area = lc_area
                        %msg        = NEW zcxca_authority_check(
                                          severity = if_abap_behv_message=>severity-error
                                          textid   = zcxca_authority_check=>gc_create ) )
          TO reported-_tipomov.
      ENDIF.

    ENDLOOP.

  ENDMETHOD.

  METHOD get_authorizations.

    READ ENTITIES OF zi_fi_tipo_movi IN LOCAL MODE
         ENTITY _TipoMov
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

ENDCLASS.
