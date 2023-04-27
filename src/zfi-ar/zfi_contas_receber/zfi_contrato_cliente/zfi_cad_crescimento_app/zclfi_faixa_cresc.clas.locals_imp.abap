CLASS lhc__faixacrescimento DEFINITION INHERITING FROM cl_abap_behavior_handler.

  PRIVATE SECTION.

    METHODS valid_codfaixa FOR VALIDATE ON SAVE
      IMPORTING keys FOR _faixacrescimento~valid_codfaixa.
    METHODS updatecurrency FOR DETERMINE ON MODIFY
      IMPORTING keys FOR _faixacrescimento~updatecurrency.
    METHODS authoritycreate FOR VALIDATE ON SAVE
      IMPORTING keys FOR _faixacrescimento~authoritycreate.
    METHODS calcdocno FOR DETERMINE ON SAVE
      IMPORTING keys FOR _faixacrescimento~calcdocno.

ENDCLASS.

CLASS lhc__faixacrescimento IMPLEMENTATION.

  METHOD valid_codfaixa.

    READ ENTITIES OF zi_fi_contrato_cresc IN LOCAL MODE
    ENTITY _faixacrescimento
    ALL FIELDS
    WITH CORRESPONDING #( keys )
    RESULT DATA(lt_faixa).

    DATA(ls_faixa) = lt_faixa[ 1 ].



**********************************************************************
*                  % e Valor                                       *
**********************************************************************
    IF ( ls_faixa-vlrfaixaini IS NOT INITIAL OR
       ls_faixa-vlrfaixafim IS NOT INITIAL ) AND
       ( ls_faixa-vlrmontini IS NOT INITIAL OR
         ls_faixa-vlrmontini IS NOT INITIAL ) .

      "Informar % ou Valor de faixa
      APPEND VALUE #( %msg     = new_message_with_text(
                       severity = if_abap_behv_message=>severity-error
                       text     = TEXT-013

                     ) ) TO reported-_faixacrescimento.
    ELSE.

      IF ( ls_faixa-codfaixa IS NOT INITIAL ) AND
     ( ls_faixa-codmontante IS NOT INITIAL ) .

        "Informar % ou Valor de faixa
        APPEND VALUE #( %msg     = new_message_with_text(
                         severity = if_abap_behv_message=>severity-error
                         text     = TEXT-013

                       ) ) TO reported-_faixacrescimento.
      ELSE.


**********************************************************************
*                  % Faixa de Crescimento                            *
**********************************************************************
        IF ls_faixa-vlrfaixaini IS NOT INITIAL OR ls_faixa-vlrfaixafim IS NOT INITIAL.
          IF ls_faixa-codfaixa IS INITIAL.

            APPEND VALUE #( %msg     = new_message_with_text(
                      severity = if_abap_behv_message=>severity-error
                      text     = TEXT-000

                    ) ) TO reported-_faixacrescimento.

          ELSEIF ls_faixa-codfaixa EQ '1'.
            IF ls_faixa-vlrfaixaini IS INITIAL OR ls_faixa-vlrfaixafim IS INITIAL.

              APPEND VALUE #( %msg     = new_message_with_text(
                    severity = if_abap_behv_message=>severity-error
                    text     = TEXT-001
                  ) ) TO reported-_faixacrescimento.

            ENDIF.
          ELSEIF ls_faixa-codfaixa NE '1'.
            IF ls_faixa-vlrfaixafim IS NOT INITIAL.

              APPEND VALUE #( %msg     = new_message_with_text(
                  severity = if_abap_behv_message=>severity-error
                  text     = TEXT-008
                ) ) TO reported-_faixacrescimento.

            ENDIF.
          ENDIF.
        ENDIF.

**********************************************************************
*                  Montante Faixa de Crescimento                     *
**********************************************************************
        IF ls_faixa-vlrmontini IS NOT INITIAL OR ls_faixa-vlrmontfim IS NOT INITIAL.
          IF ls_faixa-codmontante IS INITIAL.

            APPEND VALUE #( %msg     = new_message_with_text(
                      severity = if_abap_behv_message=>severity-error
                      text     = TEXT-002

                    ) ) TO reported-_faixacrescimento.

          ELSEIF ls_faixa-codmontante EQ '1'.
            IF ls_faixa-vlrmontini IS INITIAL OR ls_faixa-vlrmontfim IS INITIAL.

              APPEND VALUE #( %msg     = new_message_with_text(
                    severity = if_abap_behv_message=>severity-error
                    text     = TEXT-003
                  ) ) TO reported-_faixacrescimento.

            ENDIF.
          ELSEIF ls_faixa-codmontante NE '1'.
            IF ls_faixa-vlrmontfim IS NOT INITIAL.

              APPEND VALUE #( %msg     = new_message_with_text(
                  severity = if_abap_behv_message=>severity-error
                  text     = TEXT-009
                ) ) TO reported-_faixacrescimento.

            ENDIF.

          ENDIF.
        ENDIF.

      ENDIF.
    ENDIF.
**********************************************************************
*      % Bonus de Crescimento   e Montante Bônus de Crescimento      *
**********************************************************************
    IF ls_faixa-vlrbonusini IS NOT INITIAL AND ls_faixa-vlrmontbonusini IS NOT INITIAL.
      APPEND VALUE #( %msg     = new_message_with_text(
            severity = if_abap_behv_message=>severity-error
            text     = TEXT-004
          ) ) TO reported-_faixacrescimento.
    ELSEIF ls_faixa-vlrbonusini IS INITIAL AND ls_faixa-vlrmontbonusini IS INITIAL.
      APPEND VALUE #( %msg     = new_message_with_text(
          severity = if_abap_behv_message=>severity-error
          text     = TEXT-004
        ) ) TO reported-_faixacrescimento.
    ENDIF.

  ENDMETHOD.

  METHOD updatecurrency.

    READ ENTITIES OF zi_fi_contrato_cresc IN LOCAL MODE
    ENTITY _faixacrescimento
    ALL FIELDS
    WITH CORRESPONDING #( keys )
    RESULT DATA(lt_faixa).

    MODIFY ENTITIES OF zi_fi_contrato_cresc IN LOCAL MODE
    ENTITY _faixacrescimento
    UPDATE SET FIELDS WITH VALUE #( FOR ls_faixa IN lt_faixa (
                                        %key = ls_faixa-%key
                                        moeda = 'BRL'
                                        %control = VALUE #( moeda = if_abap_behv=>mk-on )
                                    ) ) REPORTED DATA(lt_reported).

    reported = CORRESPONDING #( DEEP lt_reported ).


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
            TO reported-_faixacrescimento.

            APPEND VALUE #( %tky = <fs_key>-%tky ) TO failed-_faixacrescimento.

            APPEND VALUE #( %tky        = <fs_key>-%tky
                            %state_area = lc_area
                            %msg        = NEW zcxca_authority_check(
                                              severity = if_abap_behv_message=>severity-error
                                              textid   = zcxca_authority_check=>gc_create )
                            %element-codfaixa = if_abap_behv=>mk-on )
              TO reported-_faixacrescimento.
          ENDIF.
        ENDLOOP.
      CATCH cx_sy_itab_line_not_found.
    ENDTRY.
  ENDMETHOD.

  METHOD calcdocno.


    READ ENTITIES OF zi_fi_contrato_cresc IN LOCAL MODE
  ENTITY _crescimento
  FIELDS ( contrato )
  WITH CORRESPONDING #( keys )
  RESULT DATA(lt_header).

    READ ENTITIES OF zi_fi_contrato_cresc IN LOCAL MODE
    ENTITY _crescimento BY \_faixacresc
    FIELDS ( contrato )
    WITH CORRESPONDING #( keys )
    RESULT DATA(lt_linha).

    READ TABLE lt_header ASSIGNING FIELD-SYMBOL(<fs_header>) INDEX 1.
    IF sy-subrc = 0.

      SELECT SINGLE contrato, aditivo
      FROM ztfi_contrato
      INTO @DATA(ls_contrato)
      WHERE doc_uuid_h = @<fs_header>-docuuidh.

      MODIFY ENTITIES OF zi_fi_contrato_cresc IN LOCAL MODE
      ENTITY _faixacrescimento
      UPDATE FIELDS ( contrato aditivo )
      WITH VALUE #( FOR ls_linha IN lt_linha (           "#EC CI_STDSEQ
                         %key      =  ls_linha-%key
                          contrato = ls_contrato-contrato
                          aditivo = ls_contrato-aditivo
                         ) )
      REPORTED DATA(lt_reported).

    ENDIF.

  ENDMETHOD.

ENDCLASS.

*"* use this source file for the definition and implementation of
*"* local helper classes, interface definitions and type
*"* declarations
