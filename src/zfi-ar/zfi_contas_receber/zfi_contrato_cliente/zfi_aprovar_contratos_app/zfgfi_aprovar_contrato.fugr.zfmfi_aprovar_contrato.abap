FUNCTION zfmfi_aprovar_contrato.
*"----------------------------------------------------------------------
*"*"Interface local:
*"  IMPORTING
*"     VALUE(IV_OBSERVACAO) TYPE  ZE_OBS_APROV
*"     VALUE(IV_DOC_UUID_H) TYPE  SYSUUID_X16
*"     VALUE(IV_CONTRATO) TYPE  ZE_NUM_CONTRATO
*"     VALUE(IV_ADITIVO) TYPE  ZE_NUM_ADITIVO
*"  EXPORTING
*"     VALUE(ET_RETURN) TYPE  BAPIRET2_T
*"----------------------------------------------------------------------


  TRY .

      DATA(lo_aprovar) = NEW zclfi_aprovar_contratos(
        iv_doc_uuid_h = iv_doc_uuid_h
        iv_contrato   = iv_contrato
        iv_aditivo    = iv_aditivo
      ).
      lo_aprovar->aprovar( EXPORTING iv_observacao = iv_observacao
                           IMPORTING et_return     = et_return     ).

    CATCH cx_root INTO DATA(lo_catch).

      CALL FUNCTION 'RS_EXCEPTION_TO_BAPIRET2' "Convert Expection into Message
        EXPORTING
          i_r_exception = lo_catch             " cx_root       Abstract Superclass for All Global Exceptions
        CHANGING
          c_t_bapiret2  = et_return.           " bapirettab    BW: Table with Messages (Application Log)

        ROLLBACK WORK.
  ENDTRY.



ENDFUNCTION.
