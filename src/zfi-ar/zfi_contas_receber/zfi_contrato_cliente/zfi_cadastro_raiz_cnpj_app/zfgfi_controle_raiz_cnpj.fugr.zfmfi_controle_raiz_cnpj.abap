FUNCTION zfmfi_controle_raiz_cnpj.
*"----------------------------------------------------------------------
*"*"Interface local:
*"  IMPORTING
*"     VALUE(IV_CNPJ_RAIZ) TYPE  ZE_CPNJ_PRINCI OPTIONAL
*"     VALUE(IV_UUID) TYPE  SYSUUID_X16 OPTIONAL
*"  EXPORTING
*"     VALUE(ET_RETURN) TYPE  BAPIRET2_T
*"----------------------------------------------------------------------

  DATA(lo_cliente) = NEW zclfi_clientes_raiz_cnpj( ).
  TRY .

      IF iv_cnpj_raiz IS NOT INITIAL.
        lo_cliente->atualizar_por_raiz_cnpj(
        EXPORTING
          iv_cnpj_raiz = iv_cnpj_raiz
        ).
      ENDIF.

      IF iv_uuid IS NOT INITIAL.
        lo_cliente->atualizar_por_uuid(
        EXPORTING
          iv_raiz_uuid = iv_uuid
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
