CLASS lhc_contas DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    CONSTANTS gc_table TYPE tabname_auth VALUE 'ZTFI_CONT_DEPRE'.

    METHODS areafiscal FOR VALIDATE ON SAVE
      IMPORTING keys FOR contas~areafiscal.

    METHODS areaonsave FOR VALIDATE ON SAVE
      IMPORTING keys FOR contas~areaonsave.

    METHODS areasocietaria FOR VALIDATE ON SAVE
      IMPORTING keys FOR contas~areasocietaria.

    METHODS authoritycreate FOR VALIDATE ON SAVE
      IMPORTING keys FOR contas~authoritycreate.

    METHODS get_authorizations FOR AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR contas RESULT result.

ENDCLASS.

CLASS lhc_contas IMPLEMENTATION.

  METHOD areafiscal.
    "Para a área fiscal somente deverá cosiderar no campo AFABER as áreas 10 e 11.
    READ ENTITIES OF zi_fi_man_contas IN LOCAL MODE
    ENTITY contas
    ALL FIELDS
    WITH CORRESPONDING #( keys )
    RESULT DATA(lt_contas)
    FAILED DATA(ls_erros).

    DATA lr_afaber TYPE RANGE OF anlc-afabe.

    lr_afaber = VALUE #( ( sign = 'I'
                          option = 'EQ'
                           low = '01' )
                         ( sign = 'I'
                          option = 'EQ'
                           low = '10' )
                          ( sign = 'I'
                          option = 'EQ'
                           low = '11' ) ).


    LOOP AT lt_contas ASSIGNING FIELD-SYMBOL(<fs_contas>).

      IF <fs_contas>-afaber IN lr_afaber
        AND <fs_contas>-deprecfiscal IS NOT INITIAL
        AND <fs_contas>-despesafiscal IS INITIAL.

        APPEND VALUE #( %tky = <fs_contas>-%tky ) TO failed-contas.

        APPEND VALUE #( %tky        = <fs_contas>-%tky
                        %state_area = 'DESPESAFISCAL'
                        %msg        = new_message( id       = 'ZFI_DEPRECIACAO_AREA'
                                                   number   = '005'
                                                   severity = if_abap_behv_message=>severity-error )
                        %element-deprecfiscal = if_abap_behv=>mk-on ) TO reported-contas.

      ENDIF.

      IF <fs_contas>-afaber IN lr_afaber
        AND <fs_contas>-deprecfiscal IS INITIAL
        AND <fs_contas>-despesafiscal IS NOT INITIAL.

        APPEND VALUE #( %tky = <fs_contas>-%tky ) TO failed-contas.

        APPEND VALUE #( %tky        = <fs_contas>-%tky
                        %state_area = 'DEPRECFISCAL'
                        %msg        = new_message( id       = 'ZFI_DEPRECIACAO_AREA'
                                                   number   = '005'
                                                   severity = if_abap_behv_message=>severity-error )
                        %element-deprecfiscal = if_abap_behv=>mk-on ) TO reported-contas.

      ELSE.

        IF <fs_contas>-afaber NOT IN lr_afaber
          AND <fs_contas>-deprecfiscal IS NOT INITIAL
        AND <fs_contas>-despesafiscal IS NOT INITIAL..

          APPEND VALUE #( %tky = <fs_contas>-%tky ) TO failed-contas.

          "Área de avalição não permitido informar
          APPEND VALUE #( %tky        = <fs_contas>-%tky
                          %state_area = 'DEPRECFISCAL'
                          %msg        = new_message( id       = 'ZFI_DEPRECIACAO_AREA'
                                                     number   = '006'
                                                     severity = if_abap_behv_message=>severity-error )
                          %element-deprecfiscal = if_abap_behv=>mk-on ) TO reported-contas.

        ENDIF.

      ENDIF.

    ENDLOOP.

  ENDMETHOD.

  METHOD areaonsave.

    DATA lr_fiscal TYPE RANGE OF zi_fi_man_contas-afaber.
    DATA lr_soci   TYPE RANGE OF zi_fi_man_contas-afaber.

    lr_fiscal = VALUE #( sign = 'I' option = 'EQ' ( low = '01' ) ( low = '1' )
                                                  ( low = '10' )
                                                  ( low = '11' ) ).

    lr_soci = VALUE #( sign = 'I' option = 'EQ' ( low = '80' )
                                                  ( low = '82' )
                                                  ( low = '84' ) ).

    READ ENTITIES OF zi_fi_man_contas IN LOCAL MODE
    ENTITY contas
    FIELDS ( deprecsocietaria despesasocietaria deprecfiscal despesafiscal )
    WITH CORRESPONDING #( keys )
    RESULT DATA(lt_contas)
    FAILED DATA(ls_erros).

    LOOP AT lt_contas ASSIGNING FIELD-SYMBOL(<fs_contas>).

      IF <fs_contas>-deprecsocietaria  IS NOT INITIAL AND <fs_contas>-deprecfiscal  IS NOT INITIAL OR
         <fs_contas>-despesasocietaria IS NOT INITIAL AND <fs_contas>-despesafiscal IS NOT INITIAL.
        APPEND VALUE #( %tky = <fs_contas>-%tky ) TO failed-contas.

        APPEND VALUE #( %tky        = <fs_contas>-%tky
                        %state_area = 'DEPRECSOCIETARIA'
                        %msg        = new_message( id       = 'ZFI_DEPRECIACAO_AREA'
                                                   number   = '001'
                                                   severity = if_abap_behv_message=>severity-error )
                           ) TO reported-contas.
      ENDIF.

      IF <fs_contas>-afaber IN lr_fiscal AND <fs_contas>-deprecsocietaria IS NOT INITIAL.
        APPEND VALUE #( %tky = <fs_contas>-%tky ) TO failed-contas.

        APPEND VALUE #( %tky        = <fs_contas>-%tky
                        %state_area = 'DEPRECSOCIETARIA'
                        %msg        = new_message( id       = 'ZFI_DEPRECIACAO_AREA'
                                                   number   = '004'
                                                   severity = if_abap_behv_message=>severity-error )
                        %element-deprecsocietaria = if_abap_behv=>mk-on ) TO reported-contas.
      ENDIF.

      IF <fs_contas>-afaber IN lr_fiscal AND <fs_contas>-despesasocietaria IS NOT INITIAL.
        APPEND VALUE #( %tky = <fs_contas>-%tky ) TO failed-contas.

        APPEND VALUE #( %tky        = <fs_contas>-%tky
                        %state_area = 'DESPESASOCIETARIA'
                        %msg        = new_message( id       = 'ZFI_DEPRECIACAO_AREA'
                                                   number   = '004'
                                                   severity = if_abap_behv_message=>severity-error )
                        %element-despesasocietaria = if_abap_behv=>mk-on ) TO reported-contas.
      ENDIF.

      IF <fs_contas>-afaber IN lr_soci AND <fs_contas>-deprecfiscal IS NOT INITIAL.
        APPEND VALUE #( %tky = <fs_contas>-%tky ) TO failed-contas.

        APPEND VALUE #( %tky        = <fs_contas>-%tky
                        %state_area = 'DEPRECFISCAL'
                        %msg        = new_message( id       = 'ZFI_DEPRECIACAO_AREA'
                                                   number   = '004'
                                                   severity = if_abap_behv_message=>severity-error )
                       %element-deprecfiscal = if_abap_behv=>mk-on ) TO reported-contas.
      ENDIF.

      IF <fs_contas>-afaber IN lr_soci AND <fs_contas>-despesafiscal IS NOT INITIAL.
        APPEND VALUE #( %tky = <fs_contas>-%tky ) TO failed-contas.

        APPEND VALUE #( %tky        = <fs_contas>-%tky
                        %state_area = 'DESPESAFISCAL'
                        %msg        = new_message( id       = 'ZFI_DEPRECIACAO_AREA'
                                                   number   = '004'
                                                   severity = if_abap_behv_message=>severity-error )
                       %element-despesafiscal = if_abap_behv=>mk-on ) TO reported-contas.
      ENDIF.

    ENDLOOP.

  ENDMETHOD.

  METHOD areasocietaria.
    "Para a área societária somente deverá cosiderar no campo AFABER as áreas 80, 82 e 84.
    READ ENTITIES OF zi_fi_man_contas IN LOCAL MODE
    ENTITY contas
    ALL FIELDS
    WITH CORRESPONDING #( keys )
    RESULT DATA(lt_contas)
    FAILED DATA(ls_erros).

    DATA lr_afaber TYPE RANGE OF anlc-afabe.

    lr_afaber = VALUE #( ( sign = 'I'
                          option = 'EQ'
                           low = '80' )
                           ( sign = 'I'
                          option = 'EQ'
                           low = '82' )
                          ( sign = 'I'
                          option = 'EQ'
                           low = '84' ) ).


    LOOP AT lt_contas ASSIGNING FIELD-SYMBOL(<fs_contas>).

      IF ( <fs_contas>-deprecsocietaria  IS NOT INITIAL AND <fs_contas>-despesasocietaria IS NOT INITIAL ) AND
         ( <fs_contas>-afaber NOT IN lr_afaber ).
        APPEND VALUE #( %tky = <fs_contas>-%tky ) TO failed-contas.

        APPEND VALUE #( %tky        = <fs_contas>-%tky
                        %state_area = 'AFABER'
                        %msg        = new_message( id       = 'ZFI_DEPRECIACAO_AREA'
                                                   number   = '002'
                                                   severity = if_abap_behv_message=>severity-error )
                        %element-deprecsocietaria = if_abap_behv=>mk-on ) TO reported-contas.
      ENDIF.

      IF <fs_contas>-afaber IN lr_afaber
        AND <fs_contas>-deprecsocietaria IS NOT INITIAL
        AND <fs_contas>-despesasocietaria IS INITIAL.

        APPEND VALUE #( %tky = <fs_contas>-%tky ) TO failed-contas.

        APPEND VALUE #( %tky        = <fs_contas>-%tky
                        %state_area = 'DESPESASOCIETARIA'
                        %msg        = new_message( id       = 'ZFI_DEPRECIACAO_AREA'
                                                   number   = '005'
                                                   severity = if_abap_behv_message=>severity-error )
                        %element-deprecsocietaria = if_abap_behv=>mk-on ) TO reported-contas.

      ENDIF.

      IF <fs_contas>-afaber IN lr_afaber
        AND <fs_contas>-deprecsocietaria IS INITIAL
        AND <fs_contas>-despesasocietaria IS NOT INITIAL.

        APPEND VALUE #( %tky = <fs_contas>-%tky ) TO failed-contas.

        APPEND VALUE #( %tky        = <fs_contas>-%tky
                        %state_area = 'DEPRECSOCIETARIA'
                        %msg        = new_message( id       = 'ZFI_DEPRECIACAO_AREA'
                                                   number   = '005'
                                                   severity = if_abap_behv_message=>severity-error )
                        %element-deprecsocietaria = if_abap_behv=>mk-on ) TO reported-contas.

      ENDIF.

    ENDLOOP.
  ENDMETHOD.

  METHOD authoritycreate.

    CONSTANTS: lc_area TYPE string VALUE 'VALIDATE_CREATE'.

    READ ENTITIES OF zi_fi_man_contas IN LOCAL MODE
        ENTITY contas
        ALL FIELDS WITH CORRESPONDING #( keys )
        RESULT DATA(lt_data).

    LOOP AT lt_data ASSIGNING FIELD-SYMBOL(<fs_data>).

      IF zclfi_auth_zfimtable=>create( gc_table ) EQ abap_false.

        APPEND VALUE #( %tky        = <fs_data>-%tky
                        %state_area = lc_area )
        TO reported-contas.

        APPEND VALUE #( %tky = <fs_data>-%tky ) TO failed-contas.

        APPEND VALUE #( %tky        = <fs_data>-%tky
                        %state_area = lc_area
                        %msg        = NEW zcxca_authority_check(
                                          severity = if_abap_behv_message=>severity-error
                                          textid   = zcxca_authority_check=>gc_create ) )
          TO reported-contas.
      ENDIF.

    ENDLOOP.

  ENDMETHOD.

  METHOD get_authorizations.

    READ ENTITIES OF zi_fi_man_contas IN LOCAL MODE
         ENTITY contas
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
