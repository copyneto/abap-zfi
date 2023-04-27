FUNCTION zfmfi_controle_anexo.
*"----------------------------------------------------------------------
*"*"Interface local:
*"  IMPORTING
*"     VALUE(IV_UUID) TYPE  SYSUUID_X16 OPTIONAL
*"     VALUE(IV_ANEXO) TYPE  ZE_TIPO_ANEXO OPTIONAL
*"  EXPORTING
*"     VALUE(ET_RETURN) TYPE  BAPIRET2_T
*"----------------------------------------------------------------------

  DATA(lo_anexo) = NEW zclfi_atualiza_contrato_anexo( ).
  TRY .

      IF iv_uuid IS NOT INITIAL.
        lo_anexo->atualiza_campo(
        EXPORTING
          iv_uuid = iv_uuid
          iv_anexo = iv_anexo
        IMPORTING
          et_return = et_return
        ).
      ENDIF.

    CATCH cx_mdg_missing_input_parameter INTO DATA(lo_catch). " Missing Input parameter in a method

      CALL FUNCTION 'RS_EXCEPTION_TO_BAPIRET2' "Convert Expection into Message
        EXPORTING
          i_r_exception = lo_catch             " cx_root       Abstract Superclass for All Global Exceptions
        CHANGING
          c_t_bapiret2  = et_return.           " bapirettab    BW: Table with Messages (Application Log)

  ENDTRY.

ENDFUNCTION.
