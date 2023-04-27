CLASS lhc_zc_fi_venc_dde_busca DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS read FOR READ
      IMPORTING keys FOR READ zc_fi_venc_dde_busca RESULT result.

    METHODS atualiza FOR MODIFY
      IMPORTING keys FOR ACTION zc_fi_venc_dde_busca~atualiza.

ENDCLASS.

CLASS lhc_zc_fi_venc_dde_busca IMPLEMENTATION.

  METHOD read.

    "Cria instancia
    DATA(lo_venc_dde) = zclfi_venc_dde_data=>get_instance( ).

    DATA(lt_result) = lo_venc_dde->build(  ).

    DATA(ls_keys) = VALUE #( keys[ 1 ] OPTIONAL ).

    SELECT *
    FROM @lt_result AS dados
    WHERE kunnr = @ls_keys-kunnr
      AND belnr = @ls_keys-belnr
      AND bukrs = @ls_keys-bukrs
      AND gjahr = @ls_keys-gjahr
      AND vbeln = @ls_keys-vbeln
      AND vgbel = @ls_keys-vgbel
      INTO CORRESPONDING FIELDS OF TABLE @lt_result            .

    result = CORRESPONDING #( lt_result ).

  ENDMETHOD.

  METHOD atualiza.

    DATA lt_vencimento TYPE TABLE OF zc_fi_venc_dde_busca WITH DEFAULT KEY.

    READ ENTITIES OF zc_fi_venc_dde_busca IN LOCAL MODE
        ENTITY zc_fi_venc_dde_busca
        ALL FIELDS WITH CORRESPONDING #( keys )
        RESULT DATA(lt_venc).

    lt_vencimento = CORRESPONDING #( lt_venc ).

    DATA(lo_exec) = NEW zclfi_venc_dde( lt_vencimento ).

    reported-zc_fi_venc_dde_busca = VALUE #( FOR ls_key IN keys
                                    FOR ls_mensagem IN lo_exec->process_by_app( iv_cliente   = ls_key-kunnr
                                                                                iv_documento = ls_key-belnr
                                                                                iv_empresa   = ls_key-bukrs
                                                                                iv_exercicio = ls_key-gjahr
                                                                                iv_fatura    = ls_key-vbeln
                                                                                iv_remessa   = ls_key-vgbel )
                                 ( %tky = VALUE #( kunnr = ls_key-kunnr
                                                   belnr = ls_key-belnr
                                                   bukrs = ls_key-bukrs
                                                   gjahr = ls_key-gjahr
                                                   vbeln = ls_key-vbeln
                                                   vgbel = ls_key-vgbel )
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

CLASS lsc_zc_fi_venc_dde_busca DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.

    METHODS check_before_save REDEFINITION.

    METHODS finalize          REDEFINITION.

    METHODS save              REDEFINITION.

ENDCLASS.

CLASS lsc_zc_fi_venc_dde_busca IMPLEMENTATION.

  METHOD check_before_save.
    return.
  ENDMETHOD.

  METHOD finalize.
  return.
  ENDMETHOD.

  METHOD save.
  return.
  ENDMETHOD.

ENDCLASS.
