CLASS lcl_Conciliacao DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS lock FOR LOCK
      IMPORTING keys FOR LOCK Conciliacao.

    METHODS read FOR READ
      IMPORTING keys FOR READ Conciliacao RESULT result.

    METHODS conciliaManual FOR MODIFY
      IMPORTING keys FOR ACTION Conciliacao~conciliaManual.
    METHODS get_features FOR FEATURES
      IMPORTING keys REQUEST requested_features FOR Conciliacao RESULT result.

ENDCLASS.

CLASS lcl_Conciliacao IMPLEMENTATION.

  METHOD read.

    IF keys IS INITIAL.
      RETURN.
    ENDIF.

    SELECT *
    FROM zi_fi_conciliacao_manual_dda
    FOR ALL ENTRIES IN @keys
    WHERE CompanyCode EQ @keys-CompanyCode
      AND Supplier    EQ @keys-Supplier
      AND FiscalYear  EQ @keys-FiscalYear
      AND DocNumber   EQ @keys-DocNumber
      AND ReferenceNo EQ @keys-ReferenceNo
*      AND NotaFiscal  EQ @keys-NotaFiscal
      INTO CORRESPONDING FIELDS OF TABLE @result.

  ENDMETHOD.

  METHOD conciliaManual.

    DATA:
      ls_exec_conciliacao_dda TYPE zi_fi_conciliacao_manual_dda,
      lt_ref                  TYPE /iwbep/t_mgw_name_value_pair.

    READ ENTITIES OF zi_fi_conciliacao_manual_dda IN LOCAL MODE
      ENTITY Conciliacao
        FIELDS ( Supplier
                 CompanyCode
                 ReferenceNo
                 DocNumber
                 FiscalYear
                 DueDate
                 bktxt
                 PaymentMethod
                 BlockPay )
        WITH CORRESPONDING #( keys )
      RESULT DATA(lt_conciliacao)
      FAILED failed.

    IMPORT tab TO lt_ref
        FROM  DATABASE indx(xy)
        CLIENT sy-mandt
        ID 'ZFI_REF'.

    IF lt_ref IS NOT INITIAL
    AND lines( lt_conciliacao ) GT 1.


      APPEND VALUE #( %tky = VALUE #( Supplier    = ls_exec_conciliacao_dda-supplier
                                      companycode = ls_exec_conciliacao_dda-companycode
                                      referenceno = ls_exec_conciliacao_dda-referenceno
                                      fiscalyear  = ls_exec_conciliacao_dda-fiscalyear
                                      docnumber   = ls_exec_conciliacao_dda-DocNumber )
                               %msg = new_message(
                                 id       = 'ZFI_SOLUCAO_DDA'
                                 number   = 008
                                 severity = if_abap_behv_message=>severity-warning ) )
                            TO reported-conciliacao.

      EXIT.

    ELSE.

      DATA(lv_referenceno) = VALUE #( lt_ref[ name = 'ReferenceNo' ]-value OPTIONAL ).
      DATA(lv_fiscalyear) = VALUE #( lt_ref[ name = 'FiscalYear' ]-value OPTIONAL ).
      DATA(lv_docnumber) = VALUE #( lt_ref[ name = 'DocNumber' ]-value OPTIONAL ).

    ENDIF.

    LOOP AT lt_conciliacao ASSIGNING FIELD-SYMBOL(<fs_conciliacao>).

      IF <fs_conciliacao>-BlockPay IS NOT INITIAL.

        APPEND VALUE #( %tky = VALUE #( Supplier    = ls_exec_conciliacao_dda-supplier
                                        companycode = ls_exec_conciliacao_dda-companycode
                                        referenceno = ls_exec_conciliacao_dda-referenceno
                                        fiscalyear  = ls_exec_conciliacao_dda-fiscalyear
                                         docnumber   = ls_exec_conciliacao_dda-DocNumber )
                                %msg = new_message(
                                  id       = 'ZFI_SOLUCAO_DDA'
                                  number   = 007
                                  severity = if_abap_behv_message=>severity-error ) )
                             TO reported-conciliacao.

        CONTINUE.

      ENDIF.

      <fs_conciliacao>-PaymentMethod = 'B'.

      ls_exec_conciliacao_dda = CORRESPONDING #( <fs_conciliacao> ).

      DATA(lo_conciliacao) = NEW zclfi_concilia_manual_dda( ).

      reported-conciliacao = VALUE #(  FOR ls_mensagem IN
                                          lo_conciliacao->executar(
                                              is_conciliacao = ls_exec_conciliacao_dda
                                              iv_xblnr       = CONV xblnr( lv_referenceno )
                                              iv_fiscalyear  = conv gjahr_c( lv_fiscalyear )
                                              iv_docnumber   = conv belnr_d( lv_docnumber ) )

                                          ( %tky = VALUE #( Supplier    = ls_exec_conciliacao_dda-supplier
                                                            companycode = ls_exec_conciliacao_dda-companycode
                                                            referenceno = ls_exec_conciliacao_dda-referenceno
                                                            fiscalyear  = ls_exec_conciliacao_dda-fiscalyear
                                                            docnumber   = ls_exec_conciliacao_dda-DocNumber )

                                            %msg = new_message( id       = ls_mensagem-id
                                                                number   = ls_mensagem-number
                                                                severity = CONV #( ls_mensagem-type )
                                                                v1       = ls_mensagem-message_v1
                                                                v2       = ls_mensagem-message_v2
                                                                v3       = ls_mensagem-message_v3
                                                                v4       = ls_mensagem-message_v4 )
                                          )
                            ).

    ENDLOOP.

  ENDMETHOD.

  METHOD lock.
    IF sy-subrc EQ 0.
    ENDIF.
  ENDMETHOD.

  METHOD get_features.

    READ ENTITIES OF zi_fi_conciliacao_manual_dda IN LOCAL MODE
         ENTITY Conciliacao
           FIELDS ( Supplier
                    CompanyCode
                    ReferenceNo
                    DocNumber
                    FiscalYear
                    DueDate )
           WITH CORRESPONDING #( keys )
         RESULT DATA(lt_conciliacao)
         FAILED failed.

    result = VALUE #( FOR ls_conciliacao IN lt_conciliacao
                          ( %tky-CompanyCode    = ls_conciliacao-companycode
                            %tky-Supplier       = ls_conciliacao-supplier
                            %tky-FiscalYear     = ls_conciliacao-fiscalyear
                            %tky-DocNumber      = ls_conciliacao-DocNumber
                            %tky-ReferenceNo    = ls_conciliacao-ReferenceNo
                            %tky-AccountingItem = ls_conciliacao-AccountingItem
                            %tky-NotaFiscal     = ls_conciliacao-NotaFiscal
                            %tky-DueDate        = ls_conciliacao-DueDate
                            %features-%action-conciliaManual = if_abap_behv=>fc-o-enabled

                            ) ).

  ENDMETHOD.

ENDCLASS.

CLASS lcl_ZI_FI_CONCILIACAO_MANUAL_D DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.

    METHODS check_before_save REDEFINITION.

    METHODS finalize          REDEFINITION.

    METHODS save              REDEFINITION.

ENDCLASS.

CLASS lcl_ZI_FI_CONCILIACAO_MANUAL_D IMPLEMENTATION.

  METHOD check_before_save.
    IF sy-subrc EQ 0.
    ENDIF.
  ENDMETHOD.

  METHOD finalize.
    IF sy-subrc EQ 0.
    ENDIF.
  ENDMETHOD.

  METHOD save.
    IF sy-subrc EQ 0.
    ENDIF.
  ENDMETHOD.

ENDCLASS.
