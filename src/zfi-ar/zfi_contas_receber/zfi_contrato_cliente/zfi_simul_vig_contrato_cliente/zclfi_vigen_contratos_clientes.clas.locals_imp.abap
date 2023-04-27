CLASS lcl_zi_fi_vigen_contratos_clie DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS lock FOR LOCK
      IMPORTING keys FOR LOCK zi_fi_vigen_contratos_clientes.

    METHODS read FOR READ
      IMPORTING keys FOR READ zi_fi_vigen_contratos_clientes RESULT result.

    METHODS simularm FOR MODIFY
      IMPORTING keys FOR ACTION zi_fi_vigen_contratos_clientes~simularm RESULT result.
    METHODS defaultforcreate FOR READ
      IMPORTING keys FOR FUNCTION zi_fi_vigen_contratos_clientes~defaultforcreate RESULT result.

ENDCLASS.

CLASS lcl_zi_fi_vigen_contratos_clie IMPLEMENTATION.

  METHOD lock.
    RETURN.
  ENDMETHOD.

  METHOD read.
    RETURN.
  ENDMETHOD.

*  METHOD simularm.
*    DATA(lo_alterar_motivo_recusa) = NEW zclsd_alterar_motivo_recusa( ).
*    reported-zi_fi_vigen_contratos_clientes = VALUE #( FOR ls_key IN keys
*      FOR ls_mensagem IN lo_alterar_motivo_recusa->executar(
*         iv_salesorder     = ls_key-salesorder
*         iv_salesorderitem = ls_key-salesorderitem
*         is_parametros     = ls_key-%param
*      )
*      ( %tky = VALUE #( salesorder = ls_key-salesorder salesorderitem = ls_key-salesorderitem )
*        %msg        =
*          new_message(
*            id       = ls_mensagem-id
*            number   = ls_mensagem-number
*            severity = CONV #( ls_mensagem-type )
*            v1       = ls_mensagem-message_v1
*            v2       = ls_mensagem-message_v2
*            v3       = ls_mensagem-message_v3
*            v4       = ls_mensagem-message_v4 )
*    ) ).
*  ENDMETHOD.



  METHOD simularm.
    DATA(lo_simular_contrato_cliente) = NEW zclfi_simular_contrato_cliente( ).
    reported-zi_fi_vigen_contratos_clientes = VALUE #( FOR ls_key IN keys
      FOR ls_mensagem IN lo_simular_contrato_cliente->executar(
        is_contrato_key = VALUE #(
          docuuidh   = ls_key-docuuidh
          contrato   = ls_key-contrato
          aditivo    = ls_key-aditivo
          parametros = ls_key-%param
        )
      )
      ( "%tky = VALUE #( salesorder = ls_key-salesorder salesorderitem = ls_key-salesorderitem )
       docuuidh = ls_key-docuuidh
       contrato = ls_key-contrato
       aditivo  = ls_key-aditivo
        %msg        =
          new_message(
            id       = ls_mensagem-id
            number   = ls_mensagem-number
            severity = CONV #( ls_mensagem-type )
            v1       = ls_mensagem-message_v1
            v2       = ls_mensagem-message_v2
            v3       = ls_mensagem-message_v3
            v4       = ls_mensagem-message_v4 )
    ) ).
  ENDMETHOD.

  METHOD defaultforcreate.
    RETURN.
  ENDMETHOD.

ENDCLASS.

CLASS lcl_zi_fi_vigen_contratos_cli DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.

    METHODS check_before_save REDEFINITION.

    METHODS finalize          REDEFINITION.

    METHODS save              REDEFINITION.

ENDCLASS.

CLASS lcl_zi_fi_vigen_contratos_cli IMPLEMENTATION.

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
