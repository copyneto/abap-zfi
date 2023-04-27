FUNCTION zfmfi_estorno.
*"----------------------------------------------------------------------
*"*"Interface local:
*"  IMPORTING
*"     VALUE(IS_APP) TYPE  ZI_FI_PROVISAO_CLI OPTIONAL
*"  CHANGING
*"     VALUE(CT_RETURN) TYPE  BAPIRET2_TAB OPTIONAL
*"----------------------------------------------------------------------

  FIELD-SYMBOLS: <fs_ret> LIKE LINE OF ct_return.

  CALL FUNCTION 'TB_FI_DOCUMENT_REVERSE'
    EXPORTING
      companycode         = is_app-empresa
      document            = is_app-docliq
      year                = is_app-exercliq
      reason_for_reversal = '01'
    EXCEPTIONS
      error               = 1
      OTHERS              = 2.

  IF sy-subrc = 0.

    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        wait = abap_true.

    SELECT SINGLE stblg
    FROM bkpf
    INTO @DATA(lv_doc_est)
    WHERE bukrs = @is_app-empresa
      AND belnr = @is_app-docliq
      AND gjahr = @is_app-exercliq.

    UPDATE ztfi_cont_cont
        SET doc_estorno   = lv_doc_est
        exerc_estorno = is_app-exercliq
        mont_estorno  = is_app-montante
        WHERE contrato = is_app-numcontrato
        AND aditivo  = is_app-numaditivo.

    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        wait = abap_true.

    APPEND INITIAL LINE TO ct_return ASSIGNING <fs_ret>.
    <fs_ret>-id         = 'ZFI_CONTRATO_CLIENTE'.
    <fs_ret>-type       = 'I'.
    <fs_ret>-number     = '013'.

    "DocLiq &1 estornado &2 realizado com sucesso!
    APPEND INITIAL LINE TO ct_return ASSIGNING <fs_ret>.
    <fs_ret>-id         = 'ZFI_CONTRATO_CLIENTE'.
    <fs_ret>-type       = 'S'.
    <fs_ret>-number     = '011'.
    <fs_ret>-message_v1 = is_app-docliq.
    <fs_ret>-message_v2 = is_app-docestorno.

  ELSE.

    APPEND INITIAL LINE TO ct_return ASSIGNING <fs_ret>.
    <fs_ret>-id         = 'ZFI_CONTRATO_CLIENTE'.
    <fs_ret>-type       = 'E'.
    <fs_ret>-number     = '012'.

  ENDIF.

ENDFUNCTION.
