CLASS lcl_Reversao DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS lock FOR LOCK
      IMPORTING keys FOR LOCK Reversao.

    METHODS read FOR READ
      IMPORTING keys FOR READ Reversao RESULT result.

    METHODS reverter FOR MODIFY
      IMPORTING keys FOR ACTION Reversao~reverter.

    METHODS get_features FOR FEATURES
      IMPORTING keys REQUEST requested_features FOR Reversao RESULT result.

ENDCLASS.

CLASS lcl_Reversao IMPLEMENTATION.

  METHOD lock.
    RETURN.
  ENDMETHOD.

  METHOD read.

* ---------------------------------------------------------------------------
* Recupera os dados
* ---------------------------------------------------------------------------
    IF keys[] IS NOT INITIAL.

      SELECT *
        FROM zi_fi_reversao_provisao_pdc
        FOR ALL ENTRIES IN @keys
        WHERE CompanyCode            = @keys-CompanyCode
          AND AccountingDocument     = @keys-AccountingDocument
          AND FiscalYear             = @keys-FiscalYear
          AND AccountingDocumentItem = @keys-AccountingDocumentItem
        INTO CORRESPONDING FIELDS OF TABLE @result.     "#EC CI_SEL_DEL

      IF sy-subrc NE 0.
        FREE result.
      ENDIF.
    ENDIF.

  ENDMETHOD.

  METHOD reverter.

* ---------------------------------------------------------------------------
* Recupera dados das linhas selecionadas
* ---------------------------------------------------------------------------
    READ ENTITIES OF zi_fi_reversao_provisao_pdc IN LOCAL MODE ENTITY Reversao
      ALL FIELDS
      WITH CORRESPONDING #( keys )
      RESULT DATA(lt_reversao)
      FAILED failed.

* ---------------------------------------------------------------------------
* Recupera dados informados via Abstract
* ---------------------------------------------------------------------------
    TRY.
        DATA(ls_keys) = keys[ 1 ].
        DATA(ls_reversao) = lt_reversao[ 1 ].
      CATCH cx_root.
        CLEAR ls_keys.
    ENDTRY.

* ---------------------------------------------------------------------------
* Aplica reversão
* ---------------------------------------------------------------------------
    DATA(lo_events) = NEW zclfi_reversao_provisao_events(  ).

    lo_events->revert( EXPORTING is_reversao       = CORRESPONDING #( ls_reversao )
                                 is_reversao_popup = ls_keys-%param
                       IMPORTING et_return         = DATA(lt_return) ).

* ---------------------------------------------------------------------------
* Retorna mensagens
* ---------------------------------------------------------------------------
    reported-reversao = VALUE #( FOR ls_return IN lt_return (
                        %tky = ls_keys-%tky
                        %msg = new_message( id       = ls_return-id
                                            number   = ls_return-number
                                            v1       = ls_return-message_v1
                                            v2       = ls_return-message_v2
                                            v3       = ls_return-message_v3
                                            v4       = ls_return-message_v4
                                            severity = CONV #( ls_return-type ) ) ) ).

  ENDMETHOD.

  METHOD get_features.

* ---------------------------------------------------------------------------
* Recupera dados das linhas selecionadas
* ---------------------------------------------------------------------------
    READ ENTITIES OF zi_fi_reversao_provisao_pdc IN LOCAL MODE ENTITY Reversao
      ALL FIELDS
      WITH CORRESPONDING #( keys )
      RESULT DATA(lt_reversao)
      FAILED failed.

* ---------------------------------------------------------------------------
* Atualiza permissões de cada linha
* ---------------------------------------------------------------------------

    result = VALUE #( FOR ls_reversao IN lt_reversao
                    ( %tky                              = ls_reversao-%tky
                      %action-reverter                  = COND #( WHEN ls_reversao-AccountingDocumentTypeOk   EQ abap_true
*                                                                   AND ls_reversao-Reference1InDocumentHeader NE zclfi_reversao_provisao_events=>gc_revertido
                                                          THEN if_abap_behv=>fc-o-enabled
                                                          ELSE if_abap_behv=>fc-o-disabled ) ) ).

  ENDMETHOD.

ENDCLASS.

CLASS lcl_ZI_FI_REVERSAO_PROVISAO_PD DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.

    METHODS check_before_save REDEFINITION.

    METHODS finalize          REDEFINITION.

    METHODS save              REDEFINITION.

ENDCLASS.

CLASS lcl_ZI_FI_REVERSAO_PROVISAO_PD IMPLEMENTATION.

  METHOD check_before_save.
    RETURN.
  ENDMETHOD.

  METHOD finalize.
    RETURN.
  ENDMETHOD.

  METHOD save.
    RETURN.
  ENDMETHOD.

ENDCLASS.
