*"* use this source file for the definition and implementation of
*"* local helper classes, interface definitions and type
*"* declarations
CLASS lcl_Regras DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    CONSTANTS:
      BEGIN OF gc_existe_regra,
        id     TYPE symsgid VALUE 'ZFI_AUTO_TXT_CONTAB',
        number TYPE symsgno VALUE '001',
      END OF gc_existe_regra.

    CONSTANTS gc_table TYPE tabname_auth VALUE 'ZTFI_AUTOTEXT'.

    METHODS preencheRegra FOR DETERMINE ON MODIFY
      IMPORTING keys FOR Regras~preencheRegra.

    METHODS busca_proxima_Regra
      RETURNING VALUE(rv_result) TYPE ztfi_autotext-regra.

    METHODS get_authorizations FOR AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR Regras RESULT result.

    METHODS authorityCreate FOR VALIDATE ON SAVE
      IMPORTING keys FOR Regras~authorityCreate.

ENDCLASS.

CLASS lcl_regras IMPLEMENTATION.

  METHOD preencheregra.

    READ ENTITIES OF zi_fi_cfg_auto_textos_regras IN LOCAL MODE
      ENTITY Regras
      FIELDS ( Regra )
      WITH CORRESPONDING #( keys )
    RESULT DATA(lt_regras).

    SORT lt_regras BY Regra.
    READ TABLE lt_regras TRANSPORTING NO FIELDS
        WITH KEY Regra = ''
        BINARY SEARCH.

    IF sy-subrc NE 0.
      RETURN.
    ENDIF.

    LOOP AT lt_regras ASSIGNING FIELD-SYMBOL(<Fs_regras>).
      IF <fs_regras>-regra IS NOT INITIAL.
        DELETE lt_regras INDEX sy-tabix.
      ENDIF.
    ENDLOOP.

    MODIFY ENTITIES OF zi_fi_cfg_auto_textos_regras IN LOCAL MODE
      ENTITY Regras
        UPDATE FIELDS ( Regra )
        WITH VALUE #( FOR ls_regra IN lt_regras (
                            %key    = ls_regra-%key
                            Regra   = me->busca_proxima_regra( )
                           ) )
    REPORTED DATA(lt_reported).


  ENDMETHOD.

  METHOD busca_proxima_regra.

    SELECT MAX( regra )
    FROM ztfi_autotext
    WHERE regra NE ''
    INTO @DATA(lv_ultima_regra).

    IF sy-subrc EQ 0.
      rv_result = lv_ultima_regra + 1.
    ENDIF.

  ENDMETHOD.

  METHOD get_authorizations.

    READ ENTITIES OF zi_fi_cfg_auto_textos_regras IN LOCAL MODE
        ENTITY Regras
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
                      %delete = lv_delete
                      %assoc-_Campos          = lv_update
                      %assoc-_ChaveLancto     = lv_update
                      %assoc-_ContaContabil   = lv_update
                      %assoc-_Empresa         = lv_update
                      %assoc-_TipoAtualizacao = lv_update
                      %assoc-_TipoDocumento   = lv_update
                      %assoc-_TipoProduto     = lv_update )
             TO result.

    ENDLOOP.

  ENDMETHOD.

    METHOD authorityCreate.

    CONSTANTS lc_area TYPE string VALUE 'VALIDATE_CREATE'.

    READ ENTITIES OF zi_fi_cfg_auto_textos_regras IN LOCAL MODE
        ENTITY Regras
        ALL FIELDS WITH CORRESPONDING #( keys )
        RESULT DATA(lt_data).

    LOOP AT lt_data ASSIGNING FIELD-SYMBOL(<fs_data>).

      IF zclfi_auth_zfimtable=>create( gc_table ) EQ abap_false.

        APPEND VALUE #( %tky        = <fs_data>-%tky
                        %state_area = lc_area )
        TO reported-regras.

        APPEND VALUE #( %tky = <fs_data>-%tky ) TO failed-regras.

        APPEND VALUE #( %tky        = <fs_data>-%tky
                        %state_area = lc_area
                        %msg        = NEW zcxca_authority_check(
                                          severity = if_abap_behv_message=>severity-error
                                          textid   = zcxca_authority_check=>gc_create ) )
          TO reported-regras.

      ENDIF.

    ENDLOOP.

  ENDMETHOD.

ENDCLASS.
