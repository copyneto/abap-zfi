CLASS lhc__cadcrescrimento DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS calcdocno FOR DETERMINE ON SAVE
      IMPORTING keys FOR _cadcrescrimento~calcdocno.
    METHODS authoritycreate FOR VALIDATE ON SAVE
      IMPORTING keys FOR _cadcrescrimento~authoritycreate.

ENDCLASS.

CLASS lhc__cadcrescrimento IMPLEMENTATION.

  METHOD calcdocno.

    READ ENTITIES OF zi_fi_contrato_cresc IN LOCAL MODE
    ENTITY _crescimento
    FIELDS ( contrato )
    WITH CORRESPONDING #( keys )
    RESULT DATA(lt_header).

    READ ENTITIES OF zi_fi_contrato_cresc IN LOCAL MODE
    ENTITY _crescimento BY \_cadcresci
    FIELDS ( contrato )
    WITH CORRESPONDING #( keys )
    RESULT DATA(lt_linha).

    READ TABLE lt_header ASSIGNING FIELD-SYMBOL(<fs_header>) INDEX 1.
    IF sy-subrc = 0.

      SELECT SINGLE contrato, aditivo
      FROM ztfi_contrato
      INTO @DATA(ls_contrato)
      WHERE doc_uuid_h = @<fs_header>-docuuidh.

      SELECT SINGLE contrato, aditivo
      FROM ztfi_cad_cresci
      INTO @DATA(ls_cresce)
      WHERE doc_uuid_h = @<fs_header>-docuuidh.

      IF sy-subrc IS NOT INITIAL.

        MODIFY ENTITIES OF zi_fi_contrato_cresc IN LOCAL MODE
        ENTITY _cadcrescrimento
        UPDATE FIELDS ( contrato aditivo )
        WITH VALUE #( FOR ls_linha IN lt_linha (         "#EC CI_STDSEQ
                           %key      =  ls_linha-%key
                            contrato = ls_contrato-contrato
                            aditivo = ls_contrato-aditivo
                           ) )
        REPORTED DATA(lt_reported).

      ELSE.

        APPEND VALUE #( %msg =  new_message( id       = 'ZFI_CONTRATO_CLIENTE'
                   number   = CONV #( '037' )
                   severity = CONV #( 'E' ) ) ) TO reported-_cadcrescrimento.

        RETURN.
      ENDIF.

    ENDIF.

  ENDMETHOD.

  METHOD authoritycreate.
    CONSTANTS lc_area TYPE string VALUE 'VALIDATE_CREATE'.

    READ ENTITIES OF zi_fi_contrato_cresc IN LOCAL MODE
        ENTITY _crescimento
        ALL FIELDS WITH CORRESPONDING #( keys )
        RESULT DATA(lt_data).

    TRY.
        DATA(ls_root_data) = lt_data[ 1 ].

        LOOP AT keys ASSIGNING FIELD-SYMBOL(<fs_key>).
          IF zclfi_auth_zfibukrs=>bukrs_create( ls_root_data-bukrs ) EQ abap_false.

            APPEND VALUE #( %tky        = <fs_key>-%tky
                            %state_area = lc_area )
            TO reported-_cadcrescrimento.

            APPEND VALUE #( %tky = <fs_key>-%tky ) TO failed-_cadcrescrimento.

            APPEND VALUE #( %tky        = <fs_key>-%tky
                            %state_area = lc_area
                            %msg        = NEW zcxca_authority_check(
                                              severity = if_abap_behv_message=>severity-error
                                              textid   = zcxca_authority_check=>gc_create )
                            %element-familiacl = if_abap_behv=>mk-on )
              TO reported-_cadcrescrimento.
          ENDIF.
        ENDLOOP.
      CATCH cx_sy_itab_line_not_found.
    ENDTRY.
  ENDMETHOD.

ENDCLASS.
