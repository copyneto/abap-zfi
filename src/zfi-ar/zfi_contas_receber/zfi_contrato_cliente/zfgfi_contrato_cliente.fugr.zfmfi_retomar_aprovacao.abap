FUNCTION zfmfi_retomar_aprovacao.
*"----------------------------------------------------------------------
*"*"Interface local:
*"  IMPORTING
*"     VALUE(IV_OBSERVACAO) TYPE  ZE_OBS_APROV
*"     VALUE(IV_CONTRATO) TYPE  ZE_NUM_CONTRATO
*"     VALUE(IV_ADITIVO) TYPE  ZE_NUM_ADITIVO
*"  EXPORTING
*"     VALUE(ET_RETURN) TYPE  BAPIRET2_T
*"----------------------------------------------------------------------
  TRY .

      DATA(lo_objeto) = NEW zclfi_retomar_aprovacao(
        iv_observacao = iv_observacao
        iv_contrato   = iv_contrato
        iv_aditivo    = iv_aditivo
      ).
      lo_objeto->resetar_nivel_atual( ).

    CATCH cx_root INTO DATA(lo_catch).

      CALL FUNCTION 'RS_EXCEPTION_TO_BAPIRET2' "Convert Expection into Message
        EXPORTING
          i_r_exception = lo_catch             " cx_root       Abstract Superclass for All Global Exceptions
        CHANGING
          c_t_bapiret2  = et_return.           " bapirettab    BW: Table with Messages (Application Log)

      ROLLBACK WORK.
  ENDTRY.

ENDFUNCTION.
