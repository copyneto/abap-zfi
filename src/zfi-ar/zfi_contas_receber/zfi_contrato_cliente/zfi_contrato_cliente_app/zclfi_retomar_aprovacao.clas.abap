CLASS zclfi_retomar_aprovacao DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    METHODS constructor
      IMPORTING
        !iv_observacao TYPE ze_obs_aprov
        !iv_contrato   TYPE ze_num_contrato
        !iv_aditivo    TYPE ze_num_aditivo .

    METHODS resetar_nivel_atual .
  PROTECTED SECTION.
  PRIVATE SECTION.

    DATA gv_contrato TYPE ze_num_contrato .
    DATA gv_obs TYPE ze_obs_aprov .
    DATA gv_aditivo TYPE ze_num_aditivo .
    DATA gs_aprovacao TYPE ztfi_cont_aprov .

    METHODS checar_autorizacao .
    METHODS restaurar_backup .
    METHODS check_status_contrato
      IMPORTING
        iv_index TYPE i.
ENDCLASS.



CLASS ZCLFI_RETOMAR_APROVACAO IMPLEMENTATION.


  METHOD checar_autorizacao.
**    ""Checar o AuthCheck e se O user é Autorizador do Nivel Atual.
*    AUTHORITY-CHECK OBJECT 'ZAPROVCONT' ID 'CRIAR' DUMMY.
*
*    CASE sy-subrc.
*      WHEN 0. "Autorizado!
*
*      WHEN 4. "Não Autorizado.
*        RAISE EXCEPTION TYPE zcxfi_erro_aprovacao MESSAGE e005(ZFI_CONTRATO_CLIENTE). "Você Não Possui Autorização Para Retornar Aprovação.
*
*      WHEN OTHERS.
*        RAISE EXCEPTION TYPE zcxfi_erro_aprovacao MESSAGE e006(ZFI_CONTRATO_CLIENTE). "Objeto de Autorização Não Encontrado.
*
*    ENDCASE.
    RETURN.

  ENDMETHOD.


  METHOD constructor.

    me->gv_contrato = iv_contrato.
    me->gv_aditivo = iv_aditivo.
    me->gv_obs = iv_observacao.

    SELECT SINGLE * FROM ztfi_cont_aprov
            WHERE contrato = @me->gv_contrato
              AND aditivo  = @me->gv_aditivo
              AND nivel_atual = 'X'
             INTO @gs_aprovacao .

    IF sy-subrc IS NOT INITIAL.
      RAISE EXCEPTION TYPE zcxfi_erro_aprovacao MESSAGE e002(zfi_contrato_cliente).
    ELSE.
      me->checar_autorizacao( ).
    ENDIF.
  ENDMETHOD.


  METHOD resetar_nivel_atual.

    DATA: ls_ret_aprov TYPE ztfi_ret_aprov.

* Busca todos os níveis de aprovação

    SELECT *
      FROM ztfi_cont_aprov
      INTO TABLE @DATA(lt_aprov)
        WHERE contrato   = @me->gv_contrato
          AND aditivo    = @me->gv_aditivo.
    IF sy-subrc IS INITIAL.

      SORT lt_aprov BY nivel ASCENDING.

      DATA(lv_index) = line_index( lt_aprov[ nivel_atual = 'X' ] ).

      DATA(ls_aprov) = lt_aprov[ lv_index ].

      ls_aprov-nivel_atual = space.
      MODIFY ztfi_cont_aprov FROM ls_aprov.
      COMMIT WORK AND WAIT.

      MOVE-CORRESPONDING ls_aprov TO ls_ret_aprov.
      TRY.
          ls_ret_aprov-doc_uuid_ret = cl_system_uuid=>create_uuid_x16_static( ).
        CATCH cx_root INTO DATA(lo_root).
          RETURN.
      ENDTRY.
      ls_ret_aprov-observacao = gv_obs.
      ls_ret_aprov-retornador = sy-uname.
      ls_ret_aprov-data_ret = sy-datum.
      ls_ret_aprov-hora_ret = sy-uzeit.
      ls_ret_aprov-created_by = sy-uname.
      GET TIME STAMP FIELD ls_ret_aprov-created_at.
      MODIFY ztfi_ret_aprov FROM ls_ret_aprov.
      COMMIT WORK AND WAIT.


      IF sy-subrc IS INITIAL.

        lv_index = lv_index - 1.
        IF lv_index > 0.
          DATA(ls_aprov_ant) = lt_aprov[ lv_index ].

          ls_aprov_ant-nivel_atual = abap_true.

          MODIFY ztfi_cont_aprov FROM ls_aprov_ant.
          COMMIT WORK AND WAIT.
          IF sy-subrc IS NOT INITIAL.

            ROLLBACK WORK.
            me->restaurar_backup( ).

          ELSE.

            "Retorna Status do contrato
            me->check_status_contrato( lv_index ).
          ENDIF.
        ENDIF.
      ELSE.

        ROLLBACK WORK.
        me->restaurar_backup( ).

      ENDIF.
    ENDIF.

  ENDMETHOD.


  METHOD restaurar_backup.

    MODIFY ztfi_cont_aprov FROM me->gs_aprovacao.
    COMMIT WORK AND WAIT.
    RAISE EXCEPTION TYPE zcxfi_erro_aprovacao MESSAGE e005(zfi_aprovar_cont)." Não foi possivel atualizar a tabela.

  ENDMETHOD.


  METHOD check_status_contrato.

    DATA lv_nivel TYPE ze_nivel_aprov_cc.
    DATA(lo_param) = zclca_tabela_parametros=>get_instance( ). " CHANGE - LSCHEPP - 20.07.2023
    TRY.
        lo_param->m_get_single(
          EXPORTING
            iv_modulo = 'FI-AR'
            iv_chave1 = 'CONTRATO'
            iv_chave2 = 'NIVELDEAPROVACAO'
          IMPORTING
            ev_param  = lv_nivel
        ).
      CATCH zcxca_tabela_parametros.
    ENDTRY.

    IF lv_nivel > iv_index.

      UPDATE ztfi_contrato SET status = '3'
                  WHERE doc_uuid_h = gs_aprovacao-doc_uuid_h
                    AND contrato = me->gv_contrato
                    AND aditivo = me->gv_aditivo.

      IF sy-subrc = 0.
        COMMIT WORK AND WAIT.
      ENDIF.

    ENDIF.

  ENDMETHOD.
ENDCLASS.
