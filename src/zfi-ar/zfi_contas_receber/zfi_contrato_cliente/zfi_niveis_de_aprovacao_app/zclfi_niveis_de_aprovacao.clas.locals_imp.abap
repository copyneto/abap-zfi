CLASS lcl__niveis DEFINITION INHERITING FROM cl_abap_behavior_handler .

  PRIVATE SECTION.

    CONSTANTS gc_table TYPE tabname_auth VALUE 'ZTFI_CAD_NIVEL'.

    METHODS authorityCreate FOR VALIDATE ON SAVE
      IMPORTING keys FOR _niveis~authorityCreate.

    METHODS get_authorizations FOR AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR _niveis RESULT result.

    METHODS validateemptyfield FOR VALIDATE ON SAVE
      IMPORTING keys FOR _niveis~validateemptyfield.

ENDCLASS.

CLASS lcl__niveis IMPLEMENTATION.

  METHOD validateemptyfield.

    READ ENTITIES OF zi_fi_niveis_de_aprovacao
       IN LOCAL MODE ENTITY _niveis
       ALL FIELDS WITH CORRESPONDING #( keys )
       RESULT DATA(lt_niveis) .

    DATA(ls_niveis) = lt_niveis[ 1 ].

    IF ls_niveis-Nivel IS INITIAL OR
       ls_niveis-descnivel IS INITIAL.

      APPEND VALUE #(  %tky        = ls_niveis-%tky
                       %msg        = new_message_with_text(
                                           severity = if_abap_behv_message=>severity-error
                                           text     = TEXT-001 "Campos Mandatórios: Devem estar preenchido.
                    ) ) TO reported-_niveis.

    ENDIF.

  ENDMETHOD.

  METHOD authorityCreate.

    CONSTANTS: lc_area TYPE string VALUE 'VALIDATE_CREATE'.

    READ ENTITIES OF zi_fi_niveis_de_aprovacao IN LOCAL MODE
        ENTITY  _Niveis
        ALL FIELDS WITH CORRESPONDING #( keys )
        RESULT DATA(lt_data).

    LOOP AT lt_data ASSIGNING FIELD-SYMBOL(<fs_data>).

      IF zclfi_auth_zfimtable=>create( gc_table ) EQ abap_false.

        APPEND VALUE #( %tky        = <fs_data>-%tky
                        %state_area = lc_area )
        TO reported-_Niveis.

        APPEND VALUE #( %tky = <fs_data>-%tky ) TO failed-_Niveis.

        APPEND VALUE #( %tky        = <fs_data>-%tky
                        %state_area = lc_area
                        %msg        = NEW zcxca_authority_check(
                                          severity = if_abap_behv_message=>severity-error
                                          textid   = zcxca_authority_check=>gc_create ) )
          TO reported-_Niveis.
      ENDIF.

    ENDLOOP.

  ENDMETHOD.

  METHOD get_authorizations.

    READ ENTITIES OF zi_fi_niveis_de_aprovacao IN LOCAL MODE
         ENTITY _Niveis
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

*"* use this source file for the definition and implementation of
*"* local helper classes, interface definitions and type
*"* declarations
