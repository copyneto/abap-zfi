FUNCTION zfmfi_renovacao_de_contrato.
*"----------------------------------------------------------------------
*"*"Interface local:
*"  IMPORTING
*"     VALUE(IV_DATA_FIM) TYPE  ZE_FIM_VALIDADE
*"     VALUE(IV_DOC_UUID_H) TYPE  SYSUUID_X16
*"     VALUE(IV_CONTRATO) TYPE  ZE_NUM_CONTRATO
*"     VALUE(IV_ADITIVO) TYPE  ZE_NUM_ADITIVO
*"  EXPORTING
*"     VALUE(ET_RETURN) TYPE  BAPIRET2_T
*"----------------------------------------------------------------------

  TRY .

      DATA(lo_recontrato) = NEW zclfi_renovar_contratos(
        iv_doc_uuid_h = iv_doc_uuid_h
        iv_contrato   = iv_contrato
        iv_aditivo    = iv_aditivo
      ).

      lo_recontrato->renovar_contrato(
        EXPORTING
          iv_data_fim    = iv_data_fim    " Data fim validade
      ).

    CATCH cx_root INTO DATA(lo_catch). " Missing Input parameter in a method

      CALL FUNCTION 'RS_EXCEPTION_TO_BAPIRET2' "Convert Expection into Message
        EXPORTING
          i_r_exception = lo_catch             " cx_root       Abstract Superclass for All Global Exceptions
        CHANGING
          c_t_bapiret2  = et_return.           " bapirettab    BW: Table with Messages (Application Log)

  ENDTRY.



ENDFUNCTION.
