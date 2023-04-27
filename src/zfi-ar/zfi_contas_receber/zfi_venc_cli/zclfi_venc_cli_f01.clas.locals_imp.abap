CLASS lhc_zi_fi_venc_cli_f01 DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS read FOR READ
      IMPORTING keys FOR READ zi_fi_venc_cli_f01 RESULT result.

    METHODS modvencimento FOR MODIFY
      IMPORTING keys FOR ACTION zi_fi_venc_cli_f01~modvencimento.

ENDCLASS.

CLASS lhc_zi_fi_venc_cli_f01 IMPLEMENTATION.

  METHOD read.

    SELECT *
          FROM zi_fi_venc_cli_f01
          FOR ALL ENTRIES IN @keys
          WHERE empresa       = @keys-empresa
            AND nodocumento   = @keys-nodocumento
            AND exercicio     = @keys-exercicio
            AND item          = @keys-item
            AND cliente       = @keys-cliente
            INTO TABLE @DATA(lt_venc).

    result = CORRESPONDING #( lt_venc ).

  ENDMETHOD.

  METHOD modvencimento.

    DATA lt_vencimento TYPE TABLE OF zi_fi_venc_cli_f01 WITH DEFAULT KEY.

    READ ENTITIES OF zi_fi_venc_cli_f01 IN LOCAL MODE
        ENTITY zi_fi_venc_cli_f01
        ALL FIELDS WITH CORRESPONDING #( keys )
        RESULT DATA(lt_venc).

    lt_vencimento = CORRESPONDING #( lt_venc ).

    data(lo_exec) = new ZCLFI_VENC_EXEC( lt_vencimento ).

    reported-zi_fi_venc_cli_f01 = VALUE #( FOR ls_key IN keys
                                           FOR ls_mensagem IN lo_exec->execute( iv_doc     = ls_key-NoDocumento
                                                                                iv_emp     = ls_key-empresa
                                                                                iv_year    = ls_key-exercicio
                                                                                iv_item    = ls_key-item
                                                                                iv_cliente = ls_key-Cliente
                                                                                is_param   = ls_key-%param )
                                 ( %tky = VALUE #( nodocumento = ls_key-nodocumento
                                                   empresa     = ls_key-empresa
                                                   exercicio   = ls_key-exercicio
                                                   item        = ls_key-item
                                                   Cliente     = ls_key-cliente     )
                                   %msg = new_message(
                                                       id       = ls_mensagem-id
                                                       number   = ls_mensagem-number
                                                       severity = CONV #( ls_mensagem-type )
                                                       v1       = ls_mensagem-message_v1
                                                       v2       = ls_mensagem-message_v2
                                                       v3       = ls_mensagem-message_v3
                                                       v4       = ls_mensagem-message_v4  ) ) ).



  ENDMETHOD.

ENDCLASS.

CLASS lsc_zi_fi_venc_cli_f01 DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.

    METHODS check_before_save REDEFINITION.

    METHODS finalize          REDEFINITION.

    METHODS save              REDEFINITION.

ENDCLASS.

CLASS lsc_zi_fi_venc_cli_f01 IMPLEMENTATION.

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
