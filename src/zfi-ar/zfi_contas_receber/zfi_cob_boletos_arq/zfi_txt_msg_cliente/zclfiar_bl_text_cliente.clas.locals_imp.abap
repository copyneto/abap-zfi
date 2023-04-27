CLASS lcl_TextoCli DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS validateText FOR VALIDATE ON SAVE
      IMPORTING keys FOR TextoCli~validateText.

    METHODS authorityCreate FOR VALIDATE ON SAVE
      IMPORTING keys FOR TextoCli~authorityCreate.

    METHODS get_authorizations FOR AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR TextoCli RESULT result.

ENDCLASS.

CLASS lcl_TextoCli IMPLEMENTATION.

  METHOD validateText.

    DATA: lv_lf      TYPE c,
          lv_tabix   TYPE sy-tabix,
          lv_string  TYPE string,
          lv_xstring TYPE xstring.

    " Read the travel status of the existing travels
    READ ENTITIES OF zi_fi_bl_text_cliente IN LOCAL MODE
      ENTITY TextoCli
        FIELDS ( Text ) WITH CORRESPONDING #( keys )
      RESULT DATA(lt_texto).

    IF sy-subrc IS INITIAL.

      DATA(ls_texto) = lt_texto[ 1 ].

      lv_string = ls_texto-Text.

      lv_lf = cl_abap_char_utilities=>cr_lf+1(1).

      REPLACE ALL OCCURRENCES OF lv_lf IN lv_string WITH '#'.

      SPLIT lv_string AT '#' INTO TABLE DATA(lt_text).

      IF sy-subrc IS INITIAL.

        IF lines( lt_text ) > 8.

          APPEND VALUE #( %tky = ls_texto-%tky ) TO failed-textocli.

          APPEND VALUE #( %tky = ls_texto-%tky
                          %msg = new_message( id     = 'ZFI_CONT_RCB'
                                              number = '002'
                                      severity =  CONV #('E') )
                          %element-text = if_abap_behv=>mk-on ) TO reported-textocli.

        ELSE.

          LOOP AT lt_text ASSIGNING FIELD-SYMBOL(<fs_text>).

            lv_tabix = sy-tabix.

            IF strlen( <fs_text> ) > 72.

              APPEND VALUE #( %tky = ls_texto-%tky ) TO failed-textocli.

              APPEND VALUE #( %tky = ls_texto-%tky
                              %msg = new_message( id     = 'ZFI_CONT_RCB'
                                                  number = '003'
                                                      v1 = lv_tabix
                                          severity =  CONV #('E') )
                              %element-text = if_abap_behv=>mk-on ) TO reported-textocli.

            ENDIF.
          ENDLOOP.
        ENDIF.
      ENDIF.
    ENDIF.

  ENDMETHOD.

  METHOD authorityCreate.

    CONSTANTS: lc_area TYPE string VALUE 'VALIDATE_CREATE'.

    READ ENTITIES OF zi_fi_bl_text_cliente IN LOCAL MODE
        ENTITY  TextoCli
        ALL FIELDS WITH CORRESPONDING #( keys )
        RESULT DATA(lt_data).

    LOOP AT lt_data ASSIGNING FIELD-SYMBOL(<fs_data>).

      IF zclfi_auth_zfibukrs=>bukrs_create( <fs_data>-Bukrs ) EQ abap_false.

        APPEND VALUE #( %tky        = <fs_data>-%tky
                        %state_area = lc_area )
        TO reported-TextoCli.

        APPEND VALUE #( %tky = <fs_data>-%tky ) TO failed-TextoCli.

        APPEND VALUE #( %tky        = <fs_data>-%tky
                        %state_area = lc_area
                        %msg        = NEW zcxca_authority_check(
                                          severity = if_abap_behv_message=>severity-error
                                          textid   = zcxca_authority_check=>gc_create ) )
          TO reported-TextoCli.
      ENDIF.

    ENDLOOP.

  ENDMETHOD.

  METHOD get_authorizations.

    READ ENTITIES OF zi_fi_bl_text_cliente IN LOCAL MODE
         ENTITY TextoCli
         ALL FIELDS WITH CORRESPONDING #( keys )
         RESULT DATA(lt_data)
         FAILED failed.

    CHECK lt_data IS NOT INITIAL.

    DATA: lv_update TYPE if_abap_behv=>t_xflag,
          lv_delete TYPE if_abap_behv=>t_xflag.

    LOOP AT lt_data ASSIGNING FIELD-SYMBOL(<fs_data>).

      IF requested_authorizations-%update EQ if_abap_behv=>mk-on.

        IF zclfi_auth_zfibukrs=>bukrs_update( <fs_data>-Bukrs ).
          lv_update = if_abap_behv=>auth-allowed.
        ELSE.
          lv_update = if_abap_behv=>auth-unauthorized.
        ENDIF.

      ENDIF.

      IF requested_authorizations-%delete EQ if_abap_behv=>mk-on.

        IF zclfi_auth_zfibukrs=>bukrs_delete( <fs_data>-Bukrs ).
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
