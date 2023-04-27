CLASS lcl__aprovadores DEFINITION INHERITING FROM cl_abap_behavior_handler.

  PUBLIC SECTION.

    METHODS setup_messages IMPORTING p_task TYPE clike.

  PRIVATE SECTION.

    METHODS validecampos FOR VALIDATE ON SAVE
      IMPORTING keys FOR _aprovadores~validecampos.

    METHODS authoritycreate FOR VALIDATE ON SAVE
      IMPORTING keys FOR _aprovadores~authoritycreate.

    METHODS get_authorizations FOR AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR _aprovadores RESULT result.
    METHODS replicar FOR MODIFY
      IMPORTING keys FOR ACTION _aprovadores~replicar.

    DATA gv_wait_async     TYPE abap_bool.
    DATA gt_messages       TYPE STANDARD TABLE OF bapiret2.

ENDCLASS.

CLASS lcl__aprovadores IMPLEMENTATION.

  METHOD validecampos.

    READ ENTITIES OF zi_fi_cadastro_de_aprovadores
       IN LOCAL MODE ENTITY _aprovadores
       ALL FIELDS WITH CORRESPONDING #( keys )
       RESULT DATA(lt_aprov) .

    DATA(ls_niveis) = lt_aprov[ 1 ].

    IF ls_niveis-nivel  IS INITIAL OR
       ls_niveis-bukrs  IS INITIAL OR
       ls_niveis-branch IS INITIAL OR
       ls_niveis-bname  IS INITIAL OR
       ls_niveis-email  IS INITIAL.

      APPEND VALUE #(  %tky        = ls_niveis-%tky
                       %msg        = new_message_with_text(
                                           severity = if_abap_behv_message=>severity-error
                                           text     = TEXT-001 "Campos Mandatórios: Devem estar preenchido.
                    ) ) TO reported-_aprovadores.

    ENDIF.
  ENDMETHOD.

  METHOD authoritycreate.

    CONSTANTS lc_area TYPE string VALUE 'VALIDATE_CREATE'.

    READ ENTITIES OF zi_fi_cadastro_de_aprovadores IN LOCAL MODE
        ENTITY _aprovadores
        ALL FIELDS WITH CORRESPONDING #( keys )
        RESULT DATA(lt_data).

    LOOP AT lt_data ASSIGNING FIELD-SYMBOL(<fs_data>).

      IF zclfi_auth_zfibukrs=>bukrs_create( <fs_data>-bukrs ) EQ abap_false.

        APPEND VALUE #( %tky        = <fs_data>-%tky
                        %state_area = lc_area )
        TO reported-_aprovadores.

        APPEND VALUE #( %tky = <fs_data>-%tky ) TO failed-_aprovadores.

        APPEND VALUE #( %tky        = <fs_data>-%tky
                        %state_area = lc_area
                        %msg        = NEW zcxca_authority_check(
                                          severity = if_abap_behv_message=>severity-error
                                          textid   = zcxca_authority_check=>gc_create )
                        %element-bukrs = if_abap_behv=>mk-on )
          TO reported-_aprovadores.
      ENDIF.

    ENDLOOP.

  ENDMETHOD.

  METHOD get_authorizations.

    READ ENTITIES OF zi_fi_cadastro_de_aprovadores IN LOCAL MODE
        ENTITY _aprovadores
        ALL FIELDS WITH CORRESPONDING #( keys )
        RESULT DATA(lt_data)
        FAILED failed.

    CHECK lt_data IS NOT INITIAL.

    DATA: lv_update TYPE if_abap_behv=>t_xflag,
          lv_delete TYPE if_abap_behv=>t_xflag.

    LOOP AT lt_data ASSIGNING FIELD-SYMBOL(<fs_data>).

      IF requested_authorizations-%update EQ if_abap_behv=>mk-on.

        IF zclfi_auth_zfibukrs=>bukrs_update( <fs_data>-bukrs ).
          lv_update = if_abap_behv=>auth-allowed.
        ELSE.
          lv_update = if_abap_behv=>auth-unauthorized.
        ENDIF.

      ENDIF.

      IF requested_authorizations-%delete EQ if_abap_behv=>mk-on.

        IF zclfi_auth_zfibukrs=>bukrs_delete( <fs_data>-bukrs ).
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

  METHOD replicar.

    DATA: ls_aprov TYPE ztfi_cad_aprovad.

    gv_wait_async = abap_false.

    DATA(lv_empresa) = keys[ 1 ]-%param-empresa .

    READ ENTITIES OF zi_fi_cadastro_de_aprovadores IN LOCAL MODE
        ENTITY _aprovadores
        ALL FIELDS WITH CORRESPONDING #( keys )
        RESULT DATA(lt_aprov)
        FAILED failed.

    READ TABLE lt_aprov ASSIGNING FIELD-SYMBOL(<fs_aprov>) INDEX 1.
    IF sy-subrc = 0.

      MOVE-CORRESPONDING <fs_aprov> TO ls_aprov.

      CALL FUNCTION 'ZFMFI_REPLICAR_APROV'
        STARTING NEW TASK 'REPLAPROV'
*        CALLING messages ON END OF TASK
        EXPORTING
          is_aprov = ls_aprov
          iv_bukrs = lv_empresa.

      WAIT UNTIL gv_wait_async = abap_true.
      IF line_exists( gt_messages[ type = 'E' ] ).       "#EC CI_STDSEQ

        LOOP AT gt_messages INTO DATA(ls_message).       "#EC CI_NESTED

          APPEND VALUE #( %msg        = new_message( id       = ls_message-id
                                                     number   = ls_message-number
                                                     v1       = ls_message-message_v1
                                                     v2       = ls_message-message_v2
                                                     v3       = ls_message-message_v3
                                                     v4       = ls_message-message_v4
                                                     severity = CONV #( ls_message-type ) )
                           )
            TO reported-_aprovadores.

        ENDLOOP.

      ELSE.

        APPEND VALUE #( %msg =  new_message( id       = 'ZFI_CONTRATO_CLIENTE'
                         number   = CONV #( '046' )
                         severity = CONV #( 'S' ) ) ) TO reported-_aprovadores.

        APPEND VALUE #( %msg =  new_message( id       = 'ZFI_CONTRATO_CLIENTE'
                         number   = CONV #( '007' )
                         severity = CONV #( 'S' ) ) ) TO reported-_aprovadores.

      ENDIF.
    ENDIF.


  ENDMETHOD.


  METHOD setup_messages.

    RECEIVE RESULTS FROM FUNCTION 'ZFMFI_APROVAR_CONTRATO'
        IMPORTING
          et_return = gt_messages.

    gv_wait_async = abap_true.

  ENDMETHOD.

ENDCLASS.

*"* use this source file for the definition and implementation of
*"* local helper classes, interface definitions and type
*"* declarations
