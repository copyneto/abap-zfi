CLASS lcl__FamiliaCrescimento DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS authorityCreate FOR VALIDATE ON SAVE
      IMPORTING keys FOR _FamiliaCrescimento~authorityCreate.


ENDCLASS.

CLASS lcl__FamiliaCrescimento IMPLEMENTATION.


  METHOD authorityCreate.

      CONSTANTS lc_area TYPE string VALUE 'VALIDATE_CREATE'.

    READ ENTITIES OF zi_fi_contrato_cresc IN LOCAL MODE
        ENTITY _crescimento
        ALL FIELDS WITH CORRESPONDING #( keys )
        RESULT DATA(lt_data).

    TRY.
        DATA(ls_root_data) = lt_data[ 1 ].

        LOOP AT keys ASSIGNING FIELD-SYMBOL(<fs_key>).
          IF zclfi_auth_zfibukrs=>bukrs_create( ls_root_data-bukrs ) EQ abap_false.

            APPEND VALUE #( %tky        = <fs_key>-%tky
                            %state_area = lc_area )
            TO reported-_FamiliaCrescimento.

            APPEND VALUE #( %tky = <fs_key>-%tky ) TO failed-_FamiliaCrescimento.

            APPEND VALUE #( %tky        = <fs_key>-%tky
                            %state_area = lc_area
                            %msg        = NEW zcxca_authority_check(
                                              severity = if_abap_behv_message=>severity-error
                                              textid   = zcxca_authority_check=>gc_create )
                            %element-FamiliaCl = if_abap_behv=>mk-on )
              TO reported-_FamiliaCrescimento.
          ENDIF.
        ENDLOOP.
      CATCH cx_sy_itab_line_not_found.
    ENDTRY.

  ENDMETHOD.

ENDCLASS.
