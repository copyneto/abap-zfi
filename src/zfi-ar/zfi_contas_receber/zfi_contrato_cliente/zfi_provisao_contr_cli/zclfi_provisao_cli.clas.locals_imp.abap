CLASS lcl_zi_fi_provisao_cli DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS read FOR READ
      IMPORTING keys FOR READ zi_fi_provisao_cli RESULT result.

    METHODS provisao FOR MODIFY
      IMPORTING keys FOR ACTION zi_fi_provisao_cli~provisao.

    METHODS liquidacao FOR MODIFY
      IMPORTING keys FOR ACTION zi_fi_provisao_cli~liquidacao.

    METHODS estornar FOR MODIFY
      IMPORTING keys FOR ACTION zi_fi_provisao_cli~estornar RESULT result.

    METHODS get_features FOR FEATURES
      IMPORTING keys REQUEST requested_features FOR zi_fi_provisao_cli RESULT result.

ENDCLASS.

CLASS lcl_zi_fi_provisao_cli IMPLEMENTATION.

  METHOD read.

    SELECT * FROM zi_fi_provisao_cli
    FOR ALL ENTRIES IN @keys
    WHERE numcontrato = @keys-numcontrato
    AND numaditivo = @keys-numaditivo
    INTO TABLE @DATA(lt_prov).

    result = CORRESPONDING #( lt_prov ).


  ENDMETHOD.

  METHOD provisao.

    DATA lt_provisao TYPE TABLE OF zi_fi_provisao_cli WITH DEFAULT KEY.

    READ ENTITIES OF zi_fi_provisao_cli IN LOCAL MODE
        ENTITY zi_fi_provisao_cli
        ALL FIELDS WITH CORRESPONDING #( keys )
        RESULT DATA(lt_prov).

    lt_provisao = CORRESPONDING #( lt_prov ).

    DATA(lo_exec) = NEW zclfi_prov_exec( lt_provisao ).

    reported-zi_fi_provisao_cli = VALUE #( FOR ls_key IN keys
                                           FOR ls_mensagem IN lo_exec->execute( iv_contrato  = ls_key-numcontrato
                                                                                iv_aditivo   = ls_key-numaditivo
                                                                                iv_cliente   = ls_key-cliente
                                                                                iv_empresa   = ls_key-empresa
                                                                                iv_exercicio = ls_key-exercicio
                                                                                iv_item      = ls_key-item
                                                                                iv_numdoc    = ls_key-numdoc
                                                                                iv_lanc      = ls_key-%param-venc_prov )
                                  ( %tky = VALUE #( numcontrato = ls_key-numcontrato
                                                    numaditivo  = ls_key-numaditivo
                                                    cliente     = ls_key-cliente
                                                    empresa     = ls_key-empresa
                                                    exercicio   = ls_key-exercicio
                                                    item        = ls_key-item
                                                    numdoc      = ls_key-numdoc )
                                     %msg = new_message(
                                                       id       = ls_mensagem-id
                                                       number   = ls_mensagem-number
                                                       severity = CONV #( ls_mensagem-type )
                                                       v1       = ls_mensagem-message_v1
                                                       v2       = ls_mensagem-message_v2
                                                       v3       = ls_mensagem-message_v3
                                                       v4       = ls_mensagem-message_v4  ) ) ).

  ENDMETHOD.

  METHOD liquidacao.

    DATA lt_liquidacao TYPE TABLE OF zi_fi_provisao_cli WITH DEFAULT KEY.

    READ ENTITIES OF zi_fi_provisao_cli IN LOCAL MODE
      ENTITY zi_fi_provisao_cli
      ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(lt_prov).

    lt_liquidacao = CORRESPONDING #( lt_prov ).

    DATA(lo_exec) = NEW zclfi_liquid_exec( lt_liquidacao ).

    reported-zi_fi_provisao_cli = VALUE #( FOR ls_key IN keys
                                           FOR ls_mensagem IN lo_exec->execute( iv_contrato  = ls_key-numcontrato
                                                                                iv_aditivo   = ls_key-numaditivo
                                                                                iv_cliente   = ls_key-cliente
                                                                                iv_empresa   = ls_key-empresa
                                                                                iv_exercicio = ls_key-exercicio
                                                                                iv_item      = ls_key-item
                                                                                iv_numdoc    = ls_key-numdoc
                                                                                iv_lanc      = ls_key-%param-venc_liqui )
                                  ( %tky = VALUE #( numcontrato = ls_key-numcontrato
                                                    numaditivo  = ls_key-numaditivo
                                                    cliente     = ls_key-cliente
                                                    empresa     = ls_key-empresa
                                                    exercicio   = ls_key-exercicio
                                                    item        = ls_key-item
                                                    numdoc      = ls_key-numdoc )
                                   %msg = new_message(
                                                     id       = ls_mensagem-id
                                                     number   = ls_mensagem-number
                                                     severity = CONV #( ls_mensagem-type )
                                                     v1       = ls_mensagem-message_v1
                                                     v2       = ls_mensagem-message_v2
                                                     v3       = ls_mensagem-message_v3
                                                     v4       = ls_mensagem-message_v4  ) ) ).

  ENDMETHOD.

  METHOD estornar.

    DATA lt_estornar TYPE TABLE OF zi_fi_provisao_cli WITH DEFAULT KEY.

    READ ENTITIES OF zi_fi_provisao_cli IN LOCAL MODE
        ENTITY zi_fi_provisao_cli
        ALL FIELDS WITH CORRESPONDING #( keys )
        RESULT DATA(lt_prov).

    lt_estornar = CORRESPONDING #( lt_prov ).

    DATA(lo_exec) = NEW zclfi_estorno_exec( lt_estornar ).

    reported-zi_fi_provisao_cli = VALUE #( FOR ls_key IN keys
                                           FOR ls_mensagem IN lo_exec->execute( iv_contrato  = ls_key-numcontrato
                                                                                iv_aditivo   = ls_key-numaditivo
                                                                                iv_cliente   = ls_key-cliente
                                                                                iv_empresa   = ls_key-empresa
                                                                                iv_exercicio = ls_key-exercicio
                                                                                iv_item      = ls_key-item
                                                                                iv_numdoc    = ls_key-numdoc )
                                  ( %tky = VALUE #( numcontrato = ls_key-numcontrato
                                                    numaditivo  = ls_key-numaditivo
                                                    cliente     = ls_key-cliente
                                                    empresa     = ls_key-empresa
                                                    exercicio   = ls_key-exercicio
                                                    item        = ls_key-item
                                                    numdoc      = ls_key-numdoc )
                                     %msg = new_message(
                                                       id       = ls_mensagem-id
                                                       number   = ls_mensagem-number
                                                       severity = CONV #( ls_mensagem-type )
                                                       v1       = ls_mensagem-message_v1
                                                       v2       = ls_mensagem-message_v2
                                                       v3       = ls_mensagem-message_v3
                                                       v4       = ls_mensagem-message_v4  ) ) ).

  ENDMETHOD.

  METHOD get_features.
  ENDMETHOD.

ENDCLASS.

CLASS lcl_zi_fi_provisao_cli2 DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.

    METHODS check_before_save REDEFINITION.

    METHODS finalize          REDEFINITION.

    METHODS save              REDEFINITION.

ENDCLASS.

CLASS lcl_zi_fi_provisao_cli2 IMPLEMENTATION.

  METHOD check_before_save.
  ENDMETHOD.

  METHOD finalize.
  ENDMETHOD.

  METHOD save.
  ENDMETHOD.

ENDCLASS.
