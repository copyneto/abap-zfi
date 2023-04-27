CLASS lcl_zi_fi_clientes_sem_contrat DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PUBLIC SECTION.

    CONSTANTS gc_msgid TYPE msgid VALUE 'ZFI_SEM_CONTRATO'.
    CONSTANTS gc_e TYPE char1 VALUE 'E'.



  PRIVATE SECTION.

    METHODS verificacontrato FOR VALIDATE ON SAVE
      IMPORTING keys FOR zi_fi_clientes_sem_contrato~verificacontrato.

    METHODS get_authorizations FOR AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR zi_fi_clientes_sem_contrato RESULT result.

    METHODS authoritycreate FOR VALIDATE ON SAVE
      IMPORTING keys FOR zi_fi_clientes_sem_contrato~authoritycreate.
    METHODS verificadia FOR VALIDATE ON SAVE
      IMPORTING keys FOR zi_fi_clientes_sem_contrato~verificadia.


ENDCLASS.

CLASS lcl_zi_fi_clientes_sem_contrat IMPLEMENTATION.

  METHOD verificacontrato.

    READ ENTITIES OF zi_fi_clientes_sem_contrato IN LOCAL MODE
    ENTITY zi_fi_clientes_sem_contrato
    FIELDS ( kunnr ) WITH CORRESPONDING #( keys )
    RESULT DATA(lt_kunnr)
    FAILED DATA(lv_failed).


    READ TABLE lt_kunnr ASSIGNING FIELD-SYMBOL(<fs_kunnr>) INDEX 1.
    IF   sy-subrc = 0.

      SELECT kunnr, katr10
      FROM kna1
      INTO @DATA(ls_katr10)
      WHERE kunnr = @<fs_kunnr>-kunnr.
      ENDSELECT.

      IF  ls_katr10-katr10 IS NOT INITIAL.

        APPEND VALUE #( %tky        = <fs_kunnr>-%tky
                        %msg        = new_message( id       = gc_msgid
                                                   number   = '000'
                                                   severity = CONV #( gc_e )
                                                   v1       = <fs_kunnr>-kunnr )
                         )
          TO reported-zi_fi_clientes_sem_contrato.

      ENDIF.
    ENDIF.
  ENDMETHOD.

  METHOD authoritycreate.
    CONSTANTS lc_area TYPE string VALUE 'VALIDATE_CREATE'.

    READ ENTITIES OF zi_fi_clientes_sem_contrato IN LOCAL MODE
    ENTITY zi_fi_clientes_sem_contrato
    ALL FIELDS WITH CORRESPONDING #( keys )
    RESULT DATA(lt_data).

    LOOP AT lt_data ASSIGNING FIELD-SYMBOL(<fs_data>).

      IF zclfi_auth_zfibukrs=>bukrs_create( <fs_data>-bukrs ) EQ abap_false.

        APPEND VALUE #( %tky        = <fs_data>-%tky
                        %state_area = lc_area )
        TO reported-zi_fi_clientes_sem_contrato.

        APPEND VALUE #( %tky = <fs_data>-%tky ) TO failed-zi_fi_clientes_sem_contrato.

        APPEND VALUE #( %tky        = <fs_data>-%tky
                        %state_area = lc_area
                        %msg        = NEW zcxca_authority_check(
                                          severity = if_abap_behv_message=>severity-error
                                          textid   = zcxca_authority_check=>gc_create )
                        %element-bukrs = if_abap_behv=>mk-on )
          TO reported-zi_fi_clientes_sem_contrato.

      ENDIF.

    ENDLOOP.
  ENDMETHOD.

  METHOD get_authorizations.

    READ ENTITIES OF zi_fi_clientes_sem_contrato IN LOCAL MODE
    ENTITY zi_fi_clientes_sem_contrato
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

  METHOD verificadia.

    READ ENTITIES OF zi_fi_clientes_sem_contrato IN LOCAL MODE
      ENTITY zi_fi_clientes_sem_contrato
      ALL FIELDS WITH  CORRESPONDING #( keys )
      RESULT DATA(lt_kunnr)
      FAILED DATA(lv_failed).


    READ TABLE lt_kunnr ASSIGNING FIELD-SYMBOL(<fs_kunnr>) INDEX 1.
    IF sy-subrc = 0.

      IF <fs_kunnr>-diafixo IS NOT INITIAL AND
         <fs_kunnr>-diasemana IS NOT INITIAL.

        "Informar somente um valor: dia fixo mês ou dia da semana
        APPEND VALUE #( %tky        = <fs_kunnr>-%tky
                %msg        = new_message( id       = gc_msgid
                                           number   = '001'
                                           severity = CONV #( gc_e )
                                           v1       = <fs_kunnr>-kunnr )
                 )
          TO reported-zi_fi_clientes_sem_contrato.

      ENDIF.

    ENDIF.

  ENDMETHOD.

ENDCLASS.
