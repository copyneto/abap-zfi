CLASS lcl_cgc DEFINITION INHERITING FROM cl_abap_behavior_handler.

  PRIVATE SECTION.

    METHODS authoritycreate FOR VALIDATE ON SAVE
      IMPORTING keys FOR cgc~authoritycreate.
    METHODS mandatoryfields FOR VALIDATE ON SAVE
      IMPORTING keys FOR cgc~mandatoryfields.

ENDCLASS.

CLASS lcl_cgc IMPLEMENTATION.

  METHOD authoritycreate.
    CONSTANTS lc_area TYPE string VALUE 'VALIDATE_CREATE'.

    READ ENTITIES OF zi_fi_cgc_coligadas_empres IN LOCAL MODE
        ENTITY cgc
        ALL FIELDS WITH CORRESPONDING #( keys )
        RESULT DATA(lt_data).

    LOOP AT lt_data ASSIGNING FIELD-SYMBOL(<fs_data>).

      IF zclfscm_auth_zfscmbukrs=>bukrs_create( <fs_data>-bukrs ) = abap_false.

        APPEND VALUE #( %tky        = <fs_data>-%tky
                        %state_area = lc_area )
        TO reported-cgc.

        APPEND VALUE #( %tky = <fs_data>-%tky ) TO failed-cgc.

        APPEND VALUE #( %tky        = <fs_data>-%tky
                        %state_area = lc_area
                        %msg        = NEW zcxca_authority_check(
                                          severity = if_abap_behv_message=>severity-error
                                          textid   = zcxca_authority_check=>gc_create ) )
          TO reported-cgc.
      ENDIF.

    ENDLOOP.
  ENDMETHOD.

  METHOD mandatoryfields.

    READ ENTITIES OF zi_fi_cgc_coligadas_empres IN LOCAL MODE
        ENTITY cgc
        ALL FIELDS WITH CORRESPONDING #( keys )
        RESULT DATA(lt_data).

    IF lt_data[] IS NOT INITIAL.

      READ TABLE lt_data ASSIGNING FIELD-SYMBOL(<fs_data>) INDEX 1.

      IF <fs_data>-bukrs IS INITIAL
      OR <fs_data>-bupla IS INITIAL
      OR <fs_data>-cgc   IS INITIAL.

        reported-cgc = VALUE #( BASE reported-cgc ( %element-bukrs = COND #( WHEN <fs_data>-bukrs IS INITIAL
                                                                               THEN if_abap_behv=>mk-on
                                                                               ELSE if_abap_behv=>mk-off )
                                                    %element-bupla = COND #( WHEN <fs_data>-bupla IS INITIAL
                                                                               THEN if_abap_behv=>mk-on
                                                                               ELSE if_abap_behv=>mk-off )
                                                    %element-cgc   = COND #( WHEN <fs_data>-cgc IS INITIAL
                                                                               THEN if_abap_behv=>mk-on
                                                                               ELSE if_abap_behv=>mk-off )
                                                    %msg           = new_message( id       = '00'
                                                                                  number   = '055'
                                                                                  severity = CONV #( 'E' ) ) ) ).

      ENDIF.
    ENDIF.

  ENDMETHOD.

ENDCLASS.

*"* use this source file for the definition and implementation of
*"* local helper classes, interface definitions and type
*"* declarations
