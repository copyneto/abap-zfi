CLASS lcl_crescimento DEFINITION INHERITING FROM cl_abap_behavior_handler.

  PRIVATE SECTION.

    METHODS get_authorizations FOR AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR _Crescimento RESULT result.
    METHODS get_features FOR FEATURES
      IMPORTING keys REQUEST requested_features FOR _Crescimento RESULT result.

ENDCLASS.

CLASS lcl_crescimento IMPLEMENTATION.

  METHOD get_authorizations.
    READ ENTITIES OF zi_fi_contrato_cresc IN LOCAL MODE
         ENTITY _Crescimento
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

      APPEND VALUE #( %tky = <fs_data>-%tky
                      %update              = lv_update
                      %assoc-_cadcresci    = lv_update
                      %assoc-_compcresci   = lv_update
                      %assoc-_faixacresc   = lv_update
                      %assoc-_familiacresc = lv_update
                    )
             TO result.
    ENDLOOP.
  ENDMETHOD.

  METHOD get_features.
    READ ENTITIES OF zi_fi_contrato_cresc IN LOCAL MODE
         ENTITY _Crescimento
         ALL FIELDS
         WITH CORRESPONDING #( keys )
         RESULT DATA(lt_entities).

    result = VALUE #( FOR ls_entity IN lt_entities
                        ( %tky    = ls_entity-%tky
                          %features-%update = if_abap_behv=>fc-o-disabled
                        )
                    ).
  ENDMETHOD.

ENDCLASS.
