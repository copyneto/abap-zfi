CLASS lcl_SelTipoAtualizacao DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    CONSTANTS:

      BEGIN OF gc_campos_obrig,
        id     TYPE symsgid VALUE 'ZFI_AUTO_TXT_CONTAB',
        number TYPE symsgno VALUE '011',
      END OF gc_campos_obrig,

      BEGIN OF gc_high_desconsiderado,
        id     TYPE symsgid VALUE 'ZFI_AUTO_TXT_CONTAB',
        number TYPE symsgno VALUE '017',
      END OF gc_high_desconsiderado,

      BEGIN OF gc_high_menor_low,
        id     TYPE symsgid VALUE 'ZFI_AUTO_TXT_CONTAB',
        number TYPE symsgno VALUE '018',
      END OF gc_high_menor_low,

      BEGIN OF gc_high_vazio,
        id     TYPE symsgid VALUE 'ZFI_AUTO_TXT_CONTAB',
        number TYPE symsgno VALUE '019',
      END OF gc_high_vazio.

    TYPES:
      ty_regras_gravadas_t TYPE TABLE OF REF TO zclfi_autotxt_selecao_regras.

    DATA:
      gt_regras_gravadas     TYPE ty_regras_gravadas_t,
      gt_range_empresa       TYPE zclfi_autotxt_esboco_regras=>ty_range_empresa_t,
      gt_range_tipo_doc      TYPE zclfi_autotxt_esboco_regras=>ty_range_tipo_documento_t,
      gt_range_conta         TYPE zclfi_autotxt_esboco_regras=>ty_range_conta_t,
      gt_range_chave_lancto  TYPE zclfi_autotxt_esboco_regras=>ty_range_chave_lancto_t,
      gt_range_tipo_atualiza TYPE zclfi_autotxt_esboco_regras=>ty_range_tipo_atualiza_t,
      gt_range_tipo_prod     TYPE zclfi_autotxt_esboco_regras=>ty_range_tipo_produto_t.

    METHODS preencheIdSelecao FOR DETERMINE ON MODIFY
      IMPORTING keys FOR SelTipoAtualizacao~preencheIdSelecao.
    METHODS validaPreenchimento FOR VALIDATE ON SAVE
      IMPORTING keys FOR SelTipoAtualizacao~validaPreenchimento.
    METHODS buscaRegraConflitante FOR VALIDATE ON SAVE
      IMPORTING keys FOR SelTipoAtualizacao~buscaRegraConflitante.

    METHODS busca_proximo_IdSelecao
      IMPORTING iv_idregra       TYPE ztfi_sel_flowtp-id_regra
      RETURNING VALUE(rv_result) TYPE ztfi_sel_flowtp-cod_criterio.


ENDCLASS.

CLASS lcl_SelTipoAtualizacao IMPLEMENTATION.

  METHOD preencheIdSelecao.

    READ ENTITIES OF zi_fi_cfg_auto_textos_regras IN LOCAL MODE
      ENTITY SelTipoAtualizacao
      FIELDS ( IdRegra
               CritSelTreasuryUpdateType  )
      WITH CORRESPONDING #( keys )
    RESULT DATA(lt_screen_info).

    SORT lt_screen_info BY CritSelTreasuryUpdateType.
    READ TABLE lt_screen_info TRANSPORTING NO FIELDS
        WITH KEY CritSelTreasuryUpdateType = ''
        BINARY SEARCH.

    IF sy-subrc NE 0.
      RETURN.
    ENDIF.

    LOOP AT lt_screen_info ASSIGNING FIELD-SYMBOL(<fs_screen_info>).
      IF <fs_screen_info>-CritSelTreasuryUpdateType IS NOT INITIAL.
        DELETE lt_screen_info INDEX sy-tabix.
      ENDIF.
    ENDLOOP.


    MODIFY ENTITIES OF zi_fi_cfg_auto_textos_regras IN LOCAL MODE
      ENTITY SelTipoAtualizacao
        UPDATE FIELDS ( CritSelTreasuryUpdateType )
        WITH VALUE #( FOR ls_screen_info IN lt_screen_info (
                            %key    = ls_screen_info-%key
                            CritSelTreasuryUpdateType = me->busca_proximo_idselecao( ls_screen_info-IdRegra )
                           ) )
    REPORTED DATA(lt_reported).

  ENDMETHOD.

  METHOD busca_proximo_idselecao.

    SELECT MAX( cod_criterio )
    FROM ztfi_sel_flowtp
    WHERE id_regra EQ @iv_idregra
      AND cod_criterio NE ''
    INTO @DATA(lv_ultimo_criterio).

    IF sy-subrc EQ 0.
      rv_result = lv_ultimo_criterio + 1.
    ENDIF.

  ENDMETHOD.

  METHOD validaPreenchimento.

    READ ENTITIES OF zi_fi_cfg_auto_textos_regras IN LOCAL MODE
     ENTITY SelTipoAtualizacao
       FIELDS ( SignTreasuryUpdateType
                OptTreasuryUpdateType
                LowTreasuryUpdateType
                HighTreasuryUpdateType ) WITH CORRESPONDING #( keys )
   RESULT DATA(lt_campos) FAILED DATA(ls_erros).

    IF lt_campos IS INITIAL.
      RETURN.
    ENDIF.

    LOOP AT lt_campos ASSIGNING FIELD-SYMBOL(<fs_campos>).

      IF <fs_campos>-SignTreasuryUpdateType IS INITIAL.

        APPEND VALUE #( %tky = <fs_campos>-%tky ) TO failed-campos.

        APPEND VALUE #(
          %tky        = <fs_campos>-%tky
          %state_area = 'VALIDAR_CRIT'
          %msg        =  new_message(
            id       = gc_campos_obrig-id
            number   = gc_campos_obrig-number
            severity = if_abap_behv_message=>severity-error
          )
          %element-SignTreasuryUpdateType = if_abap_behv=>mk-on
        ) TO reported-seltipoatualizacao.

      ENDIF.

      IF <fs_campos>-OptTreasuryUpdateType IS INITIAL.

        APPEND VALUE #( %tky = <fs_campos>-%tky ) TO failed-campos.

        APPEND VALUE #(
          %tky        = <fs_campos>-%tky
          %state_area = 'VALIDAR_CRIT'
          %msg        =  new_message(
            id       = gc_campos_obrig-id
            number   = gc_campos_obrig-number
            severity = if_abap_behv_message=>severity-error
          )
          %element-OptTreasuryUpdateType = if_abap_behv=>mk-on
        ) TO reported-seltipoatualizacao.

      ENDIF.

      IF <fs_campos>-LowTreasuryUpdateType IS INITIAL.

        APPEND VALUE #( %tky = <fs_campos>-%tky ) TO failed-campos.

        APPEND VALUE #(
          %tky        = <fs_campos>-%tky
          %state_area = 'VALIDAR_CRIT'
          %msg        =  new_message(
            id       = gc_campos_obrig-id
            number   = gc_campos_obrig-number
            severity = if_abap_behv_message=>severity-error
          )
          %element-lowTreasuryUpdateType = if_abap_behv=>mk-on
        ) TO reported-seltipoatualizacao.

      ENDIF.

      CASE <fs_campos>-OptTreasuryUpdateType.

        WHEN rsmds_c_option-equal.

          IF <fs_campos>-HighTreasuryUpdateType IS NOT INITIAL.

            APPEND VALUE #( %tky = <fs_campos>-%tky ) TO failed-campos.

            APPEND VALUE #(
              %tky        = <fs_campos>-%tky
              %state_area = 'VALIDAR_CRIT'
              %msg        =  new_message(
                id       = gc_high_desconsiderado-id
                number   = gc_high_desconsiderado-number
                severity = if_abap_behv_message=>severity-warning
                v1 = <fs_campos>-OptTreasuryUpdateType
              )
              %element-highTreasuryUpdateType = if_abap_behv=>mk-on
            ) TO reported-seltipoatualizacao.

          ENDIF.

        WHEN rsmds_c_option-between.

          IF <fs_campos>-HighTreasuryUpdateType IS INITIAL.

            APPEND VALUE #( %tky = <fs_campos>-%tky ) TO failed-campos.

            APPEND VALUE #(
              %tky        = <fs_campos>-%tky
              %state_area = 'VALIDAR_CRIT'
              %msg        =  new_message(
                id       = gc_high_vazio-id
                number   = gc_high_vazio-number
                severity = if_abap_behv_message=>severity-error
                v1 = <fs_campos>-OptTreasuryUpdateType
              )
              %element-highTreasuryUpdateType = if_abap_behv=>mk-on
            ) TO reported-seltipoatualizacao.


          ENDIF.

          IF <fs_campos>-HighTreasuryUpdateType LT <fs_campos>-LowTreasuryUpdateType.

            APPEND VALUE #( %tky = <fs_campos>-%tky ) TO failed-campos.

            APPEND VALUE #(
              %tky        = <fs_campos>-%tky
              %state_area = 'VALIDAR_CRIT'
              %msg        =  new_message(
                id       = gc_high_menor_low-id
                number   = gc_high_menor_low-number
                severity = if_abap_behv_message=>severity-error
              )
              %element-highTreasuryUpdateType = if_abap_behv=>mk-on
            ) TO reported-seltipoatualizacao.



          ENDIF.

      ENDCASE.

    ENDLOOP.

  ENDMETHOD.

  METHOD buscaRegraConflitante.

    SELECT
        IdRegra,
        Regra,
        Descricao,
        TextoFixo
    FROM zi_fi_cfg_auto_textos_regras
    WHERE Regra NE ''
    INTO TABLE @DATA(lt_regra_existente).

    IF sy-subrc EQ 0.

      gt_regras_gravadas = VALUE #( FOR <fs_regra_existente> IN lt_regra_existente
                                   ( NEW zclfi_autotxt_selecao_regras( is_regra = <fs_regra_existente> ) )
                           ).

    ELSE.
      RETURN.
    ENDIF.

    " Para verificar se há alguma regra já gravada que atenda os mesmos critérios,
    " é necessário buscar todos os critérios da regra processada e das regras gravadas,
    " para validar todas as combinações de critério que cada regra permite

    READ ENTITIES OF zi_fi_cfg_auto_textos_regras IN LOCAL MODE
      ENTITY SelTipoAtualizacao
        FIELDS ( IdRegra
                 CritSelTreasuryUpdateType
                 SignTreasuryUpdateType
                 OptTreasuryUpdateType
                 LowTreasuryUpdateType
                 HighTreasuryUpdateType )  WITH CORRESPONDING #( keys )
    RESULT DATA(lt_criterio_draft) FAILED DATA(ls_erros_tipo_atualiza).

    IF lt_criterio_draft IS NOT INITIAL.

      gt_range_tipo_atualiza = VALUE #( FOR ls_sel_tipo_atualiza IN lt_criterio_draft
                                          ( sign = ls_sel_tipo_atualiza-SignTreasuryUpdateType
                                            option = ls_sel_tipo_atualiza-OptTreasuryUpdateType
                                            low = ls_sel_tipo_atualiza-LowTreasuryUpdateType
                                            high = ls_sel_tipo_atualiza-hightreasuryupdatetype )
                              ).


      SELECT
          CritSelCompany,
          SignCompany,
          OptCompany,
          LowCompany,
          HighCompany
      FROM zi_fi_cfg_autotxt_crit_empresa
      FOR ALL ENTRIES IN @lt_criterio_draft
      WHERE IdRegra EQ @lt_criterio_draft-IdRegra
          INTO TABLE @DATA(lt_sel_empresa).

      IF sy-subrc EQ 0.

        gt_range_empresa = VALUE #( FOR ls_sel_empresa IN lt_sel_empresa
                                            ( sign = ls_sel_empresa-signcompany
                                              option = ls_sel_empresa-optcompany
                                              low = ls_sel_empresa-lowcompany
                                              high = ls_sel_empresa-highcompany )
                                ).

      ENDIF.

      SELECT
          CritSelDocType,
          SignDocType,
          OptDocType,
          LowDocType,
          HighDocType
      FROM zi_fi_cfg_autotxt_crit_tipodoc
      FOR ALL ENTRIES IN @lt_criterio_draft
      WHERE IdRegra EQ @lt_criterio_draft-IdRegra
         INTO TABLE @DATA(lt_sel_tipodoc).

      IF sy-subrc EQ 0.

        gt_range_tipo_doc = VALUE #( FOR ls_sel_tipo_doc IN lt_sel_tipodoc
                                            ( sign = ls_sel_tipo_doc-SignDocType
                                              option = ls_sel_tipo_doc-OptDocType
                                              low = ls_sel_tipo_doc-LowDocType
                                              high = ls_sel_tipo_doc-highdoctype )
                                ).


      ENDIF.

      SELECT
          CritSelAccount,
          SignAccount,
          OptAccount,
          LowAccount,
          HighAccount
      FROM zi_fi_cfg_autotxt_crit_conta
      FOR ALL ENTRIES IN @lt_criterio_draft
      WHERE IdRegra EQ @lt_criterio_draft-IdRegra
          INTO TABLE @DATA(lt_sel_conta).

      IF sy-subrc EQ 0.

        gt_range_conta = VALUE #( FOR ls_sel_conta IN lt_sel_conta
                                            ( sign = ls_sel_conta-SignAccount
                                              option = ls_sel_conta-OptAccount
                                              low = ls_sel_conta-lowaccount
                                              high = ls_sel_conta-highaccount )
                                ).

      ENDIF.

      SELECT
          CritSelPostingKey,
          SignPostingKey,
          OptPostingKey,
          LowPostingKey,
          HighPostingKey
      FROM zi_fi_cfg_autotxt_crit_chave
      FOR ALL ENTRIES IN @lt_criterio_draft
      WHERE IdRegra EQ @lt_criterio_draft-IdRegra
        INTO TABLE @DATA(lt_sel_chave).

      IF sy-subrc EQ 0.

        gt_range_chave_lancto = VALUE #( FOR ls_sel_chave IN lt_sel_chave
                                            ( sign = ls_sel_chave-signpostingkey
                                              option = ls_sel_chave-OptPostingKey
                                              low = ls_sel_Chave-LowPostingKey
                                              high = ls_sel_chave-highpostingkey )
                                ).

      ENDIF.

      SELECT
          CritSelFIProdType,
          SignFIProdType,
          OptFIProdType,
          LowFIProdType,
          HighFIProdType
      FROM zi_fi_cfg_autotxt_crit_prodtp
      FOR ALL ENTRIES IN @lt_criterio_draft
      WHERE IdRegra EQ @lt_criterio_draft-IdRegra
         INTO TABLE @DATA(lt_sel_tipo_prod).

      IF sy-subrc EQ 0.

        gt_range_tipo_prod = VALUE #( FOR ls_sel_tipo_prod IN lt_sel_tipo_prod
                                            ( sign = ls_sel_tipo_prod-signfiprodtype
                                              option = ls_sel_tipo_prod-optfiprodtype
                                              low = ls_sel_tipo_prod-lowfiprodtype
                                              high = ls_sel_tipo_prod-highfiprodtype )
                                ).

      ENDIF.
    ENDIF.

    DATA(lo_regra_esboco) = NEW zclfi_autotxt_esboco_regras(
      it_sel_empresa       = gt_range_empresa
      it_sel_tipodoc       = gt_range_tipo_doc
      it_sel_conta         = gt_range_conta
      it_sel_chave         = gt_range_chave_lancto
      it_sel_tipo_atualiza = gt_range_tipo_atualiza
      it_sel_tipo_prod     = gt_range_tipo_prod
    ).


    READ TABLE lt_criterio_draft ASSIGNING FIELD-SYMBOL(<fs_screen_info>) INDEX 1.

    IF sy-subrc EQ 0.

      reported-seltipoatualizacao = VALUE #( FOR <fs_regra_gravada> IN gt_regras_gravadas
                                      FOR ls_msg IN lo_regra_esboco->verifica_conflito_de_regra( <fs_regra_gravada> )
                                          ( %tky = <fs_screen_info>-%tky
                                            %state_area = 'VALIDAR_REGRA'
                                            %msg        =  new_message(
                                                id          = ls_msg-id
                                                number      = ls_msg-number
                                                severity    = if_abap_behv_message=>severity-error
                                                v1          = ls_msg-message_v1
                                                v2          = ls_msg-message_v2
                                                v3          = ls_msg-message_v3
                                                v4          = ls_msg-message_v4 )
                                            %element-signtreasuryupdatetype  = if_abap_behv=>mk-on
                                            %element-opttreasuryupdatetype   = if_abap_behv=>mk-on
                                            %element-lowtreasuryupdatetype   = if_abap_behv=>mk-on
                                            %element-hightreasuryupdatetype  = if_abap_behv=>mk-on )
                            ).

      failed-seltipoatualizacao = VALUE #( FOR <fs_reported> IN reported-seltipoatualizacao
                                    ( %tky = <fs_reported>-%tky )
                          ).

    ENDIF.

  ENDMETHOD.


ENDCLASS.
