CLASS lhc__Contrato13 DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS ValidaCampos FOR VALIDATE ON SAVE
      IMPORTING keys FOR _Contrato13~ValidaCampos.

    METHODS get_authorizations FOR AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR _Contrato13 RESULT result.

    METHODS authorityCreate FOR VALIDATE ON SAVE
      IMPORTING keys FOR _Contrato13~authorityCreate.


ENDCLASS.

CLASS lhc__Contrato13 IMPLEMENTATION.

  METHOD ValidaCampos.
* *------------------------------------------------------------------
* *Recupera informações e verifica os campos não preenchidos
* *------------------------------------------------------------------
    READ ENTITIES OF zi_fi_contratos13 IN LOCAL MODE
    ENTITY _Contrato13 ALL FIELDS
    WITH CORRESPONDING #( keys )
    RESULT DATA(lt_contratos).

    LOOP AT lt_contratos INTO DATA(ls_contratos).  "#EC CI_LOOP_INTO_WA
      IF ls_contratos-Empresa IS INITIAL.
        APPEND VALUE #(  %key = ls_contratos-%key ) TO failed-_contrato13.
        APPEND VALUE #(  %key = ls_contratos-%key
                         %msg      = new_message( id       = 'ZFI_CONTRATO_CLIENTE'
                                                  number   = '000'
                                                  severity = if_abap_behv_message=>severity-error )
                          %element-Empresa  = if_abap_behv=>mk-on ) TO reported-_contrato13.
      ENDIF.

      IF ls_contratos-LocalNegocio IS INITIAL.
        APPEND VALUE #(  %key = ls_contratos-%key ) TO failed-_contrato13.
        APPEND VALUE #(  %key = ls_contratos-%key
                         %msg      = new_message( id       = 'ZFI_CONTRATO_CLIENTE'
                                                  number   = '000'
                                                  severity = if_abap_behv_message=>severity-error )
                          %element-LocalNegocio  = if_abap_behv=>mk-on ) TO reported-_contrato13.
      ENDIF.

      IF ls_contratos-Email IS INITIAL.
        APPEND VALUE #(  %key = ls_contratos-%key ) TO failed-_contrato13.
        APPEND VALUE #(  %key = ls_contratos-%key
                         %msg      = new_message( id       = 'ZFI_CONTRATO_CLIENTE'
                                                  number   = '000'
                                                  severity = if_abap_behv_message=>severity-error )
                          %element-Email  = if_abap_behv=>mk-on ) TO reported-_contrato13.
      ENDIF.

    ENDLOOP.


  ENDMETHOD.

  METHOD authorityCreate.

    CONSTANTS lc_area TYPE string VALUE 'VALIDATE_CREATE'.

    READ ENTITIES OF zi_fi_contratos13 IN LOCAL MODE
        ENTITY _Contrato13
        ALL FIELDS WITH CORRESPONDING #( keys )
        RESULT DATA(lt_data).

    LOOP AT lt_data ASSIGNING FIELD-SYMBOL(<fs_data>).

      IF zclfi_auth_zfibukrs=>bukrs_create( <fs_data>-Empresa ) EQ abap_false.

        APPEND VALUE #( %tky        = <fs_data>-%tky
                        %state_area = lc_area )
        TO reported-_contrato13.

        APPEND VALUE #( %tky = <fs_data>-%tky ) TO failed-_contrato13.

        APPEND VALUE #( %tky        = <fs_data>-%tky
                        %state_area = lc_area
                        %msg        = NEW zcxca_authority_check(
                                          severity = if_abap_behv_message=>severity-error
                                          textid   = zcxca_authority_check=>gc_create )
                        %element-empresa = if_abap_behv=>mk-on )
          TO reported-_contrato13.
      ENDIF.

    ENDLOOP.

  ENDMETHOD.

  METHOD get_authorizations.

    READ ENTITIES OF zi_fi_contratos13 IN LOCAL MODE
        ENTITY _Contrato13
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
