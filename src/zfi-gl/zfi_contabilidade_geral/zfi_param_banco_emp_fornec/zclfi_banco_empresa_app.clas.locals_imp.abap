CLASS lcl_bncemp DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS authoritycreate FOR VALIDATE ON SAVE
      IMPORTING keys FOR bncemp~authoritycreate.

    METHODS mandatoryfields FOR VALIDATE ON SAVE
      IMPORTING keys FOR bncemp~mandatoryfields.

ENDCLASS.

CLASS lcl_bncemp IMPLEMENTATION.

  METHOD authoritycreate.
    CONSTANTS lc_area TYPE string VALUE 'VALIDATE_CREATE'.

    READ ENTITIES OF zi_fi_banco_empresa_app IN LOCAL MODE
        ENTITY bncemp
        ALL FIELDS WITH CORRESPONDING #( keys )
        RESULT DATA(lt_data).

    LOOP AT lt_data ASSIGNING FIELD-SYMBOL(<fs_data>).

      IF zclfi_auth_zfibukrs=>bukrs_create( <fs_data>-bukrs ) = abap_false.

        APPEND VALUE #( %tky        = <fs_data>-%tky
                        %state_area = lc_area )
        TO reported-bncemp.

        APPEND VALUE #( %tky = <fs_data>-%tky ) TO failed-bncemp.

        APPEND VALUE #( %tky        = <fs_data>-%tky
                        %state_area = lc_area
                        %msg        = NEW zcxca_authority_check(
                                          severity = if_abap_behv_message=>severity-error
                                          textid   = zcxca_authority_check=>gc_create ) )
          TO reported-bncemp.
      ENDIF.

    ENDLOOP.
  ENDMETHOD.

  METHOD mandatoryfields.

    READ ENTITIES OF zi_fi_banco_empresa_app IN LOCAL MODE
      ENTITY bncemp
      ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(lt_data).

    IF lt_data[] IS NOT INITIAL.

      READ TABLE lt_data ASSIGNING FIELD-SYMBOL(<fs_data>) INDEX 1.

      IF <fs_data>-bukrs IS INITIAL.
*      OR <fs_data>-banco IS INITIAL.

        reported-bncemp = VALUE #( BASE reported-bncemp ( %element-bukrs = COND #( WHEN <fs_data>-bukrs IS INITIAL
                                                                               THEN if_abap_behv=>mk-on
                                                                               ELSE if_abap_behv=>mk-off )
*                                                          %element-banco = COND #( WHEN <fs_data>-banco IS INITIAL
*                                                                               THEN if_abap_behv=>mk-on
*                                                                               ELSE if_abap_behv=>mk-off )
                                                           %msg           = new_message( id       = '00'
                                                                                         number   = '055'
                                                                                         severity = CONV #( 'E' ) ) ) ).

      ENDIF.
    ENDIF.
  ENDMETHOD.

ENDCLASS.
