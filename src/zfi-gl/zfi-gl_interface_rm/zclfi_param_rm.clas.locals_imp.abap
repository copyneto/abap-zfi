CLASS lhc__ParamRM DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS authorityCreate FOR VALIDATE ON SAVE
      IMPORTING keys FOR _ParamRM~authorityCreate.

    METHODS get_authorizations FOR AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR _ParamRM RESULT result.

    METHODS verificarMatriz FOR VALIDATE ON SAVE
      IMPORTING keys FOR _ParamRM~verificarMatriz.

ENDCLASS.

CLASS lhc__ParamRM IMPLEMENTATION.

  METHOD verificarmatriz.

    TYPES: BEGIN OF ty_keys,
             bukrs TYPE bukrs,
             gsber TYPE gsber,
             bupla TYPE bupla,
           END OF ty_keys.

    DATA: lt_keys    TYPE TABLE OF ty_keys.

    LOOP AT keys INTO DATA(ls_keys).

      APPEND INITIAL LINE TO lt_keys ASSIGNING FIELD-SYMBOL(<fs_keys>).

      <fs_keys>-bukrs = ls_keys-Bukrs.
      <fs_keys>-gsber = ls_keys-Gsber.
      <fs_keys>-bupla = ls_keys-Bupla.

    ENDLOOP.

    READ ENTITIES OF zi_fi_param_rm IN LOCAL MODE
        ENTITY _ParamRM
        ALL FIELDS WITH CORRESPONDING #( lt_keys )
        RESULT DATA(lt_paramrm).

    DATA(ls_param) = lt_paramrm[ 1 ].

    IF sy-subrc IS INITIAL.

      IF ls_param-Zmatriz IS NOT INITIAL.

        SELECT COUNT( * )
         INTO @DATA(lv_count)
         FROM ztfi_param_rm
         WHERE Bukrs = @<fs_keys>-bukrs
         AND Gsber = @<fs_keys>-gsber.

        IF lv_count IS NOT INITIAL.

          APPEND VALUE #(  %msg     = new_message(
                           id       = 'ZFI_PARAM_RM'
                           number   = '001'
                           severity = CONV #( 'E' ) ) ) TO reported-_paramrm.

        ENDIF.

      ENDIF.

    ENDIF.
  ENDMETHOD.

  METHOD authoritycreate.

    CONSTANTS lc_area TYPE string VALUE 'VALIDATE_CREATE'.

    READ ENTITIES OF zi_fi_param_rm IN LOCAL MODE
    ENTITY _ParamRM
    ALL FIELDS WITH CORRESPONDING #( keys )
    RESULT DATA(lt_data).

    LOOP AT lt_data ASSIGNING FIELD-SYMBOL(<fs_data>).

      IF zclfi_auth_zfibukrs=>bukrs_create( <fs_data>-Bukrs ) EQ abap_false.

        APPEND VALUE #( %tky        = <fs_data>-%tky
                        %state_area = lc_area )
        TO reported-_paramrm.

        APPEND VALUE #( %tky = <fs_data>-%tky ) TO failed-_paramrm.

        APPEND VALUE #( %tky        = <fs_data>-%tky
                        %state_area = lc_area
                        %msg        = NEW zcxca_authority_check(
                                          severity = if_abap_behv_message=>severity-error
                                          textid   = zcxca_authority_check=>gc_create )
                        %element-Bukrs = if_abap_behv=>mk-on )
          TO reported-_paramrm.
      ENDIF.

    ENDLOOP.

  ENDMETHOD.

  METHOD get_authorizations.

    READ ENTITIES OF zi_fi_param_rm IN LOCAL MODE
    ENTITY _ParamRM
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
