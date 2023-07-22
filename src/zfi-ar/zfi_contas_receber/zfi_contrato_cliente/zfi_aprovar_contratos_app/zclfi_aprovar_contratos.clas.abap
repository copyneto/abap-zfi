class ZCLFI_APROVAR_CONTRATOS definition
  public
  final
  create public .

public section.

  methods CONSTRUCTOR
    importing
      !IV_DOC_UUID_H type SYSUUID_X16
      !IV_CONTRATO type ZE_NUM_CONTRATO
      !IV_ADITIVO type ZE_NUM_ADITIVO
    raising
      ZCXFI_ERRO_APROVACAO .
  class-methods ENVIAR_EMAIL_PROXIMO_NIVEL
    importing
      !IV_NIVEL type ZE_NIVEL_APROV_CC
      !IV_DOC_UUID_H type SYSUUID_X16
      !IV_CONTRATO type ZE_NUM_CONTRATO
      !IV_ADITIVO type ZE_NUM_ADITIVO
    raising
      ZCXFI_ERRO_APROVACAO .
  methods APROVAR
    importing
      !IV_OBSERVACAO type ZE_OBS_APROV
    exporting
      !ET_RETURN type BAPIRET2_TAB
    raising
      ZCXFI_ERRO_APROVACAO .
  class-methods PROXIMO_NIVEL
    importing
      !IV_DOC_UUID_H type SYSUUID_X16
      !IV_CONTRATO type ZE_NUM_CONTRATO
      !IV_ADITIVO type ZE_NUM_ADITIVO
    returning
      value(RV_RETURN) type ZE_NIVEL_APROV_CC
    raising
      ZCXFI_ERRO_APROVACAO .
  PROTECTED SECTION.
private section.

  data GV_DOC_UUID_H type SYSUUID_X16 .
  data GV_CONTRATO type ZE_NUM_CONTRATO .
  data GV_ADITIVO type ZE_NUM_ADITIVO .
  data GS_PROXIMA_APROVACAO type ZI_FI_CONT_PROX_NIVEL .
  data GS_BACKUP_APROVACAO type ZTFI_CONT_APROV .

  methods CHECAR_AUTORIZACAO .
  methods RESETAR_NIVEL_AUTAL .
  methods CRIAR_BACKUP_NIVEL_ATUAL .
  methods ATUALIZAR_CLIENTES .
  methods RESTAURAR_BACKUP .
  methods ATUALIZA_APROVADOR .
ENDCLASS.



CLASS ZCLFI_APROVAR_CONTRATOS IMPLEMENTATION.


  METHOD constructor.
    "" Verifica se Existe Contrato Para Aprovação com as Chaves e User.
    me->gv_doc_uuid_h = iv_doc_uuid_h.
    me->gv_contrato = iv_contrato.
    me->gv_aditivo = iv_aditivo.

    SELECT SINGLE * FROM zi_fi_cont_prox_nivel
            WHERE docuuidh = @me->gv_doc_uuid_h
              AND contrato = @me->gv_contrato
              AND aditivo  = @me->gv_aditivo
             INTO @gs_proxima_aprovacao .

    IF sy-subrc IS NOT INITIAL.
      RAISE EXCEPTION TYPE zcxfi_erro_aprovacao MESSAGE e001(zfi_aprovar_cont). "Contrato já aprovado no Nível ou Inexistente.
    ELSE.
      me->checar_autorizacao( ).
    ENDIF.
  ENDMETHOD.


  METHOD aprovar.
    DATA: ls_return TYPE bapiret2.
    "Recuperar o Prox. nivel.
    DATA(lv_prox_nivel) = me->proximo_nivel(
      EXPORTING
        iv_doc_uuid_h = me->gv_doc_uuid_h
        iv_contrato   = me->gv_contrato
        iv_aditivo    = me->gv_aditivo
    ).

    IF lv_prox_nivel IS INITIAL.
      RAISE EXCEPTION TYPE zcxfi_erro_aprovacao MESSAGE e010(zfi_aprovar_cont). "Não existe um nível superior, Abortado.
    ENDIF.

    me->criar_backup_nivel_atual( ).
    me->resetar_nivel_autal( ).

    DATA ls_aprovacao TYPE ztfi_cont_aprov.

    ls_aprovacao-mandt = sy-mandt.
    ls_aprovacao-doc_uuid_h = me->gv_doc_uuid_h.
    ls_aprovacao-contrato = me->gv_contrato.
    ls_aprovacao-aditivo = me->gv_aditivo.
    ls_aprovacao-nivel = me->gs_proxima_aprovacao-nivel.
    ls_aprovacao-aprovador = sy-uname.
    ls_aprovacao-data_aprov = sy-datum.
    ls_aprovacao-hora_aprov = sy-uzeit.
    ls_aprovacao-nivel_atual = abap_true.

    ""TimeStamp Gang.
    GET TIME STAMP FIELD DATA(lv_ts) .

    ls_aprovacao-observacao = iv_observacao.
    ls_aprovacao-created_by = sy-uname.
    ls_aprovacao-created_at = lv_ts.
    ls_aprovacao-last_changed_by = sy-uname.
    ls_aprovacao-last_changed_at = lv_ts.
    ls_aprovacao-local_last_changed_at = lv_ts.

    "GUUID
    SELECT SINGLE doc_uuid_aprov
      FROM ztfi_cont_aprov
      INTO @DATA(lv_guid)
      WHERE doc_uuid_h = @ls_aprovacao-doc_uuid_h
         AND nivel = @ls_aprovacao-nivel.
    IF sy-subrc = 0.
      ls_aprovacao-doc_uuid_aprov = lv_guid.
    ELSE.
      DATA(lo_guuid) = NEW cl_system_uuid( ).
      ls_aprovacao-doc_uuid_aprov = lo_guuid->if_system_uuid~create_uuid_x16( ).
    ENDIF.

    MODIFY ztfi_cont_aprov FROM ls_aprovacao.
    COMMIT WORK AND WAIT.

    IF sy-subrc IS NOT INITIAL.

      ROLLBACK WORK.
      me->restaurar_backup( ).

    ELSE.


      ""Verificar se é Preciso Atualizar a Raiz CNPJ.
      me->atualizar_clientes( ).

      IF lv_prox_nivel <> me->gs_proxima_aprovacao-nivel.
        "" Enviar o E-MAIL.
        me->enviar_email_proximo_nivel(
          EXPORTING
            iv_nivel      = lv_prox_nivel     " Nivel de aprovação - Contrato Cliente
            iv_doc_uuid_h = me->gv_doc_uuid_h " 16 Byte UUID in 16 Bytes (Raw Format)
            iv_contrato   = me->gv_contrato   " N° Contrato
            iv_aditivo    = me->gv_aditivo    " Aditivo Contrato Cliente
        ).


        IF me->gv_aditivo IS INITIAL.
* contrato
          MESSAGE i012 INTO DATA(lv_dummy) WITH me->gv_contrato.
          ls_return-type       = sy-msgty.
          ls_return-id         = sy-msgid.
          ls_return-number     = sy-msgno.
          ls_return-message_v1 = sy-msgv1.
          ls_return-message_v2 = sy-msgv2.
          ls_return-message_v3 = sy-msgv3.
          ls_return-message_v4 = sy-msgv4.
          APPEND ls_return TO et_return.
        ELSE.
*Aditivo
          MESSAGE i013 INTO DATA(lv_dummy1) WITH me->gv_aditivo.
          ls_return-type       = sy-msgty.
          ls_return-id         = sy-msgid.
          ls_return-number     = sy-msgno.
          ls_return-message_v1 = sy-msgv1.
          ls_return-message_v2 = sy-msgv2.
          ls_return-message_v3 = sy-msgv3.
          ls_return-message_v4 = sy-msgv4.
          APPEND ls_return TO et_return.
        ENDIF.

      ENDIF.
    ENDIF.


  ENDMETHOD.


  METHOD atualizar_clientes.

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

    IF lv_nivel IS INITIAL OR
       lv_nivel <= me->gs_proxima_aprovacao-nivel.

      DATA(lo_raiz) = NEW zclfi_clientes_raiz_cnpj( ).

      SELECT SINGLE cnpj_raiz
               FROM ztfi_raiz_cnpj
               INTO @DATA(lv_cnpj_raiz)
              WHERE doc_uuid_h = @me->gv_doc_uuid_h
                AND contrato   = @me->gv_contrato
                AND aditivo    = @me->gv_aditivo.
      IF sy-subrc IS INITIAL.
        lo_raiz->atualizar_por_raiz_cnpj(
          EXPORTING
            iv_cnpj_raiz = lv_cnpj_raiz

        ).
      ELSE.
        lo_raiz->atualizar_todos_clientes( ).
      ENDIF.

      IF  lv_nivel EQ me->gs_proxima_aprovacao-nivel.

        UPDATE ztfi_contrato SET status      = '4' "Aprovado
                                 aprov2      = sy-uname
                                 dataaprov2  = sy-datum
                                 hora_aprov2 = sy-uzeit
                             WHERE doc_uuid_h = me->gv_doc_uuid_h.

        COMMIT WORK AND WAIT.

      ENDIF.

    ELSE.

      me->atualiza_aprovador( ).

*      UPDATE ztfi_contrato SET status = '3' "Em Aprovação
*                 WHERE doc_uuid_h = me->gv_doc_uuid_h.
*
*      COMMIT WORK AND WAIT.

    ENDIF.

  ENDMETHOD.


  METHOD checar_autorizacao.

*    ""Checar o AuthCheck e se O user é Autorizador do Nivel Atual.
*    AUTHORITY-CHECK OBJECT 'ZAPROVCONT' ID 'CRIAR' DUMMY.
*
*    CASE sy-subrc.
*      WHEN 0. "Autorizado!
*        DATA(lv_nivel_aprovacao) = me->gs_proxima_aprovacao-nivel.
*
*        SELECT SINGLE mandt
*                 FROM ztfi_cad_aprovad
*                 INTO @sy-mandt
*                WHERE bname EQ @sy-uname
*                  AND nivel EQ @lv_nivel_aprovacao.
*
*        IF sy-subrc IS NOT INITIAL.
*          RAISE EXCEPTION TYPE zcxfi_erro_aprovacao MESSAGE e004(zfi_aprovar_cont). "Você Não Possui Autorização Para Aprovar Neste Nivel.
*        ENDIF.
*
*      WHEN 4. "Não Autorizado.
*        RAISE EXCEPTION TYPE zcxfi_erro_aprovacao MESSAGE e003(zfi_aprovar_cont). "Você Não Possui Autorização Para Aprovar Contratos.
*
*      WHEN OTHERS.
*        RAISE EXCEPTION TYPE zcxfi_erro_aprovacao MESSAGE e002(zfi_aprovar_cont). "Objeto de Autorização Não Encontrado.
*
*    ENDCASE.
  RETURN.
  ENDMETHOD.


  METHOD criar_backup_nivel_atual.

    SELECT SINGLE *
             FROM ztfi_cont_aprov
             INTO @me->gs_backup_aprovacao
            WHERE doc_uuid_h     = @me->gv_doc_uuid_h
              AND contrato       = @me->gv_contrato
              AND aditivo        = @me->gv_aditivo
              AND nivel_atual    = @abap_true.

  ENDMETHOD.


  METHOD enviar_email_proximo_nivel.

    CONSTANTS: lc_type TYPE so_obj_tp VALUE 'RAW'.
    DATA: lv_assunto   TYPE string.
    DATA: lt_data      TYPE bcsy_text.
    DATA: lv_output TYPE char10.

    SELECT a~nivel,
           c~branch,
           c~bukrs,
           c~companycodename,
           c~prazopagto,
           a~observacao
           FROM ztfi_cont_aprov AS a
           INNER JOIN zi_fi_cont_aprovacao AS c ON c~docuuidh    = a~doc_uuid_h
                                               AND c~contrato   = a~contrato
                                               AND c~aditivo    = a~aditivo
           WHERE a~doc_uuid_h  = @iv_doc_uuid_h
             AND a~contrato    = @iv_contrato
             AND a~aditivo     = @iv_aditivo
             AND a~nivel_atual = @abap_true
           INTO TABLE @DATA(lt_aprov).

    IF sy-subrc IS INITIAL.

      DATA(ls_aprov) = lt_aprov[ 1 ].



      SELECT *
        FROM zi_fi_niveis_e_aprovadores
       WHERE bukrs  = @ls_aprov-bukrs
         AND branch = @ls_aprov-branch
         AND nivel  = @iv_nivel
       INTO TABLE @DATA(lt_naprov).


      SELECT SINGLE *
               FROM ztfi_cont_aprov
             WHERE  doc_uuid_h  = @iv_doc_uuid_h
               AND  contrato    = @iv_contrato
               AND  aditivo     = @iv_aditivo
               AND  nivel_atual = @abap_true
             INTO @DATA(ls_ultima_aprovacao).

    ENDIF.

    lv_assunto = |{ TEXT-004 } { iv_contrato }, { TEXT-002 } { iv_aditivo },  { TEXT-003 }.|.       "contrato Nº & Aditivo Nº & pendente de aprovação.

    APPEND |{ TEXT-001 } { iv_contrato }, { TEXT-002 } { iv_aditivo },  { TEXT-003 }.| TO lt_data.  "Segue contrato Nº & Aditivo Nº & pendente de aprovação.
    APPEND space TO lt_data.
    APPEND |{ TEXT-005 }: { iv_nivel } | TO lt_data.                                                "Observações do contrato referente o nível &:
    APPEND |{ TEXT-006 }: { ls_aprov-companycodename } | TO lt_data.                                "Razão Social: &
    APPEND |{ TEXT-007 }: { ls_aprov-prazopagto } | TO lt_data.                                     "Prazo de Pagamento: &
    APPEND |{ TEXT-008 }: { ls_aprov-bukrs } | TO lt_data.                                          "Empresa: &
    APPEND |{ TEXT-009 }: { ls_aprov-branch } | TO lt_data.                                         "Local de negócios: &
    APPEND space TO lt_data.
    APPEND |{ TEXT-010 }: { ls_aprov-observacao } | TO lt_data.                                     "Observações: &

    TRY.
        DATA(lo_send_request) = cl_bcs=>create_persistent( ).
      CATCH cx_send_req_bcs.

    ENDTRY.

    TRY.
        DATA(lo_document) = cl_document_bcs=>create_document(
          i_type      = lc_type
          i_text      = lt_data
          i_subject   = CONV #( lv_assunto )
          i_language  = sy-langu ).

      CATCH cx_document_bcs.
        "handle exception
    ENDTRY.

    TRY.
        lo_send_request->set_document( lo_document ).
      CATCH cx_send_req_bcs.
        "handle exception
    ENDTRY.

    DATA:lo_recipient TYPE REF TO if_recipient_bcs VALUE IS INITIAL.

    LOOP AT lt_naprov ASSIGNING FIELD-SYMBOL(<fs_naprov>).
      TRY.
          lo_recipient = cl_cam_address_bcs=>create_internet_address( <fs_naprov>-email ).
        CATCH cx_address_bcs.
          "handle exception
      ENDTRY.

      TRY.
          lo_send_request->add_recipient(
            EXPORTING
              i_recipient = lo_recipient
              i_express   = abap_true ).
        CATCH cx_send_req_bcs.
          "handle exception
      ENDTRY.
      FREE lo_recipient.
    ENDLOOP.

    TRY.
        DATA: lv_result TYPE abap_bool.

        lo_send_request->send(
          EXPORTING
            i_with_error_screen = abap_true
          RECEIVING
            result              = lv_result ).

        IF lv_result IS INITIAL.
          ROLLBACK WORK.

          RAISE EXCEPTION TYPE zcxfi_erro_aprovacao MESSAGE e009(zfi_aprovar_cont). "Não Foi Possivel Enviar o E-mail.
        ELSE.
          COMMIT WORK.
        ENDIF.

      CATCH cx_send_req_bcs.
        RAISE EXCEPTION TYPE zcxfi_erro_aprovacao MESSAGE e011(zfi_aprovar_cont). "Verificar os E-mails Cadastrados..
    ENDTRY.

  ENDMETHOD.


  METHOD resetar_nivel_autal.

    ""TimeStamp Gang.
    GET TIME STAMP FIELD DATA(lv_ts) .

    UPDATE ztfi_cont_aprov SET nivel_atual = abap_false
                               local_last_changed_at = lv_ts
                               last_changed_by = sy-uname
                               last_changed_at = lv_ts
                          WHERE doc_uuid_h = me->gv_doc_uuid_h
                            AND contrato   = me->gv_contrato
                            AND aditivo    = me->gv_aditivo.

  ENDMETHOD.


  METHOD restaurar_backup.

    MODIFY ztfi_cont_aprov FROM me->gs_backup_aprovacao.
    COMMIT WORK AND WAIT.
    RAISE EXCEPTION TYPE zcxfi_erro_aprovacao MESSAGE e005(zfi_aprovar_cont)." Não foi possivel atualizar a tabela.

  ENDMETHOD.


  METHOD proximo_nivel.

    SELECT  a~nivel, c~branch, c~bukrs
             FROM zi_fi_proximo_niv_aprov AS a
            INNER JOIN ztfi_contrato AS c ON c~doc_uuid_h = a~docuuidh
                                         AND c~contrato   = a~contrato
                                         AND c~aditivo    = a~aditivo
            WHERE a~docuuidh    = @iv_doc_uuid_h
              AND a~contrato    = @iv_contrato
              AND a~aditivo     = @iv_aditivo
             INTO TABLE @DATA(lt_aprov).

    IF sy-subrc IS INITIAL.

      DATA(ls_aprov) = lt_aprov[ 1 ].

      SELECT *
          FROM zi_fi_niveis_e_aprovadores
         WHERE bukrs  = @ls_aprov-bukrs
           AND branch = @ls_aprov-branch
         INTO TABLE @DATA(lt_naprov).

      IF sy-subrc IS INITIAL.
        DATA(lt_naprov_aux) = lt_naprov.

        SORT lt_naprov_aux BY nivel ASCENDING.
        DELETE ADJACENT DUPLICATES FROM lt_naprov_aux COMPARING nivel.

        READ TABLE lt_naprov_aux TRANSPORTING NO FIELDS WITH KEY nivel = ls_aprov-nivel BINARY SEARCH.

        DATA(lv_index) = sy-tabix.

        IF lv_index < lines( lt_naprov_aux ).
          ADD 1 TO lv_index.
        ENDIF.


        READ TABLE lt_naprov_aux INDEX lv_index INTO DATA(ls_naprov_aux).
        rv_return = ls_naprov_aux-nivel.

        IF sy-subrc IS NOT INITIAL.
          CLEAR rv_return.
        ENDIF.

      ELSE.

        RAISE EXCEPTION TYPE zcxfi_erro_aprovacao MESSAGE e008(zfi_aprovar_cont)." Não foi possivel Recuperar os aprovadores.

      ENDIF.

    ELSE.
      RAISE EXCEPTION TYPE zcxfi_erro_aprovacao MESSAGE e007(zfi_aprovar_cont)." Não foi possivel Recuperar o Proximo Nível.
    ENDIF.

  ENDMETHOD.


  METHOD atualiza_aprovador.
    DATA lv_nivel TYPE ze_nivel_aprov_cc.
    CONSTANTS: lc_nivel01(2) TYPE c VALUE '01',
               lc_nivel03(2) TYPE c VALUE '03',
               lc_nivel04(2) TYPE c VALUE '04',
               lc_nivel05(2) TYPE c VALUE '05',
               lc_nivel06(2) TYPE c VALUE '06',
               lc_nivel07(2) TYPE c VALUE '07',
               lc_nivel08(2) TYPE c VALUE '08',
               lc_nivel09(2) TYPE c VALUE '09',
               lc_nivel10(2) TYPE c VALUE '10'.

    lv_nivel = me->gs_proxima_aprovacao-nivel.

    CASE lv_nivel.
      WHEN lc_nivel01.

        UPDATE ztfi_contrato SET status      = '3' "Em Aprovação
                                 aprov1      = sy-uname
                                 dataaprov1  = sy-datum
                                 hora_aprov1 = sy-uzeit
                            WHERE doc_uuid_h = me->gv_doc_uuid_h.

        COMMIT WORK AND WAIT.

      WHEN lc_nivel03.

        UPDATE ztfi_contrato SET status      = '3' "Em Aprovação
                                 aprov3      = sy-uname
                                 dataaprov3  = sy-datum
                                 hora_aprov3 = sy-uzeit
                            WHERE doc_uuid_h = me->gv_doc_uuid_h.

        COMMIT WORK AND WAIT.

      WHEN lc_nivel04.

        UPDATE ztfi_contrato SET status      = '3' "Em Aprovação
                                 aprov4      = sy-uname
                                 dataaprov4  = sy-datum
                                 hora_aprov4 = sy-uzeit
                            WHERE doc_uuid_h = me->gv_doc_uuid_h.

        COMMIT WORK AND WAIT.

      WHEN lc_nivel05.

        UPDATE ztfi_contrato SET status      = '3' "Em Aprovação
                                 aprov5      = sy-uname
                                 dataaprov5  = sy-datum
                                 hora_aprov5 = sy-uzeit
                            WHERE doc_uuid_h = me->gv_doc_uuid_h.

        COMMIT WORK AND WAIT.

      WHEN lc_nivel06.

        UPDATE ztfi_contrato SET status      = '3' "Em Aprovação
                                 aprov6      = sy-uname
                                 dataaprov6  = sy-datum
                                 hora_aprov6 = sy-uzeit
                            WHERE doc_uuid_h = me->gv_doc_uuid_h.

        COMMIT WORK AND WAIT.

      WHEN lc_nivel07.

        UPDATE ztfi_contrato SET status      = '3' "Em Aprovação
                                 aprov7      = sy-uname
                                 dataaprov7  = sy-datum
                                 hora_aprov7 = sy-uzeit
                            WHERE doc_uuid_h = me->gv_doc_uuid_h.

        COMMIT WORK AND WAIT.

      WHEN lc_nivel08.

        UPDATE ztfi_contrato SET status      = '3' "Em Aprovação
                                 aprov8      = sy-uname
                                 dataaprov8  = sy-datum
                                 hora_aprov8 = sy-uzeit
                            WHERE doc_uuid_h = me->gv_doc_uuid_h.

        COMMIT WORK AND WAIT.

      WHEN lc_nivel09.
        UPDATE ztfi_contrato SET status      = '3' "Em Aprovação
                                 aprov9      = sy-uname
                                 dataaprov9  = sy-datum
                                 hora_aprov9 = sy-uzeit
                            WHERE doc_uuid_h = me->gv_doc_uuid_h.

        COMMIT WORK AND WAIT.

      WHEN lc_nivel10.

        UPDATE ztfi_contrato SET status       = '3' "Em Aprovação
                                 aprov10      = sy-uname
                                 dataaprov10  = sy-datum
                                 hora_aprov10 = sy-uzeit
                             WHERE doc_uuid_h = me->gv_doc_uuid_h.

        COMMIT WORK AND WAIT.

      WHEN OTHERS.

    ENDCASE.

  ENDMETHOD.
ENDCLASS.
