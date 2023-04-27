CLASS lhc_associacao DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS limpaselecao FOR MODIFY
      IMPORTING keys FOR ACTION associ~limpaselecao.

    METHODS get_features FOR FEATURES
      IMPORTING keys REQUEST requested_features FOR associ RESULT result.

    METHODS get_authorizations FOR AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR associ RESULT result.

ENDCLASS.

CLASS lhc_associacao IMPLEMENTATION.
  METHOD get_features.
* ---------------------------------------------------------------------------
* Recupera dados das linhas selecionadas
* ---------------------------------------------------------------------------
    READ ENTITIES OF zi_fi_cockpit_associacao_cre IN LOCAL MODE ENTITY associ
        FIELDS ( empresa cliente raizid raizsn  )
        WITH CORRESPONDING #( keys )
        RESULT DATA(lt_associ)
        FAILED failed.

* ---------------------------------------------------------------------------
* Atualiza permissões de cada linha
* ---------------------------------------------------------------------------
    result = VALUE #( FOR ls_associ IN lt_associ
                    ( %tky     = ls_associ-%tky ) ).

  ENDMETHOD.

  METHOD limpaselecao.
*     ---------------------------------------------------------------------------
*     Recupera dados das linhas selecionadas
*     ---------------------------------------------------------------------------
    READ ENTITIES OF zi_fi_cockpit_associacao_cre IN LOCAL MODE
    ENTITY associ
    ALL FIELDS WITH CORRESPONDING #( keys )
    RESULT DATA(lt_associacao)
    FAILED failed.

    READ TABLE lt_associacao ASSIGNING FIELD-SYMBOL(<fs_associacao>) INDEX 1.
    IF <fs_associacao> IS NOT ASSIGNED.
      RETURN.
    ENDIF.

    DELETE FROM ztfi_creditoscli WHERE empresa       = <fs_associacao>-empresa
                                   AND cliente       = <fs_associacao>-cliente
                                   AND raizid        = <fs_associacao>-raizid
                                   AND raizsn        = <fs_associacao>-raizsn.

    DELETE FROM ztfi_faturacli WHERE empresa       = <fs_associacao>-empresa
                                   AND cliente       = <fs_associacao>-cliente
                                   AND raizid        = <fs_associacao>-raizid
                                   AND raizsn        = <fs_associacao>-raizsn.

*    MODIFY ENTITIES OF zi_fi_cockpit_associacao_cre IN LOCAL MODE ENTITY associ
*         UPDATE FIELDS ( totalizadordetalhe1 totalizadordetalhe4 )
*         WITH VALUE #( ( %tky          = <fs_associacao>-%tky
*                         empresa       = <fs_associacao>-empresa
*                         cliente       = <fs_associacao>-cliente
*                         raizid        = <fs_associacao>-raizid
*                         raizsn        = <fs_associacao>-raizsn
*                         totalizadordetalhe1 = 0
*                         totalizadordetalhe4 = 0
*                         totalizadordetalhe3  = 0
*                         totalizadordetalhe2   = 0 ) )
*         FAILED DATA(lt_failed_asso).

  ENDMETHOD.

  METHOD get_authorizations.

    READ ENTITIES OF zi_fi_cockpit_associacao_cre IN LOCAL MODE
        ENTITY associ
        ALL FIELDS WITH CORRESPONDING #( keys )
        RESULT DATA(lt_data)
        FAILED failed.

    CHECK lt_data IS NOT INITIAL.

    DATA: lv_update TYPE if_abap_behv=>t_xflag,
          lv_delete TYPE if_abap_behv=>t_xflag.

    LOOP AT lt_data ASSIGNING FIELD-SYMBOL(<fs_data>).

      IF requested_authorizations-%update EQ if_abap_behv=>mk-on.

        IF zclfi_auth_zfibukrs=>bukrs_update( <fs_data>-empresa ) = abap_true.
          lv_update = if_abap_behv=>auth-allowed.
        ELSE.
          lv_update = if_abap_behv=>auth-unauthorized.
        ENDIF.

      ENDIF.

      APPEND VALUE #( %tky          = <fs_data>-%tky
                      %update       = lv_update )
             TO result.
    ENDLOOP.

  ENDMETHOD.

ENDCLASS.

CLASS lhc_creditos DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    CONSTANTS:
      BEGIN OF gc_cds,
        credito TYPE string VALUE 'CREDITO',                       " Crédito
        fatura  TYPE string VALUE 'FATURA',                        " Fatura
      END OF gc_cds,
      BEGIN OF gc_proc,
        associacao_credito TYPE string VALUE 'ASSOCIACAO_CREDITO', " Associação Crédito
        pagar_fornecedor   TYPE string VALUE 'PAGAR_FORNECEDOR',   " Pagar Fornecedor
      END OF gc_proc.

    METHODS limpaselecaocre FOR MODIFY
      IMPORTING keys FOR ACTION creditos~limpaselecaocre.

    METHODS calcularsoma FOR MODIFY
      IMPORTING keys FOR ACTION creditos~calcularsoma.

    METHODS execassociacao FOR MODIFY
      IMPORTING keys FOR ACTION creditos~execassociacao.

    METHODS pagarfornecedor FOR MODIFY
      IMPORTING keys FOR ACTION creditos~pagarfornecedor.

    METHODS get_features FOR FEATURES
      IMPORTING keys REQUEST requested_features FOR creditos RESULT result.

    METHODS modifycreditocliente FOR DETERMINE ON SAVE
      IMPORTING keys FOR creditos~modifycreditocliente.

    METHODS get_instance_authorizations FOR AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR creditos RESULT result.

ENDCLASS.

CLASS lhc_creditos IMPLEMENTATION.

  METHOD limpaselecaocre.
*     ---------------------------------------------------------------------------
*     Recupera dados das linhas selecionadas
*     ---------------------------------------------------------------------------
    READ ENTITIES OF zi_fi_cockpit_associacao_cre IN LOCAL MODE
    ENTITY associ
    ALL FIELDS WITH CORRESPONDING #( keys )
    RESULT DATA(lt_associacao)
    FAILED failed.

    READ TABLE lt_associacao ASSIGNING FIELD-SYMBOL(<fs_associacao>) INDEX 1.
    IF <fs_associacao> IS NOT ASSIGNED.
      RETURN.
    ENDIF.

    DELETE FROM ztfi_creditoscli WHERE empresa       = <fs_associacao>-empresa
                                   AND cliente       = <fs_associacao>-cliente
                                   AND raizid        = <fs_associacao>-raizid
                                   AND raizsn        = <fs_associacao>-raizsn.
*    MODIFY ENTITIES OF zi_fi_cockpit_associacao_cre IN LOCAL MODE ENTITY associ
*         UPDATE FIELDS ( totalizadordetalhe1 totalizadordetalhe4 )
*         WITH VALUE #( ( %tky          = <fs_associacao>-%tky
*                         empresa       = <fs_associacao>-empresa
*                         cliente       = <fs_associacao>-cliente
*                         raizid        = <fs_associacao>-raizid
*                         raizsn        = <fs_associacao>-raizsn
*                         totalizadordetalhe1 = 0
*                         totalizadordetalhe4 = 0
*                         totalizadordetalhe3  = 0 ) )
*         FAILED DATA(lt_failed_asso).

  ENDMETHOD.

  METHOD calcularsoma.
    DATA: ls_creditoscli TYPE ztfi_creditoscli.

    DATA: lv_totcre    TYPE ze_totcre,
          lv_totres    TYPE ze_totres,
          lv_timestamp TYPE timestampl.

    GET TIME STAMP FIELD lv_timestamp.

*     ---------------------------------------------------------------------------
*     Recupera dados das linhas selecionadas
*     ---------------------------------------------------------------------------
    READ ENTITIES OF zi_fi_cockpit_associacao_cre IN LOCAL MODE
    ENTITY associ
    ALL FIELDS WITH CORRESPONDING #( keys )
    RESULT DATA(lt_associacao)
    FAILED failed.

    READ TABLE lt_associacao ASSIGNING FIELD-SYMBOL(<fs_associacao>) INDEX 1.
    IF <fs_associacao> IS NOT ASSIGNED.
      RETURN.
    ENDIF.

    " Lê os itens associados
    READ ENTITIES OF zi_fi_cockpit_associacao_cre
    ENTITY creditos
    ALL FIELDS WITH CORRESPONDING #( keys )
    RESULT DATA(lt_creditos)
    FAILED failed.

    SORT lt_creditos BY empresa cliente raizid raizsn documento ano linha.

    READ ENTITIES OF zi_fi_cockpit_associacao_cre
    ENTITY associ BY \_creditos
    ALL FIELDS WITH CORRESPONDING #( keys )
    RESULT DATA(lt_creditos_all)
    FAILED failed.

* ---------------------------------------------------------------------------
* Update field
* ---------------------------------------------------------------------------
    LOOP AT lt_creditos_all ASSIGNING FIELD-SYMBOL(<fs_creditos_all>).
      DATA(lv_marcado) = space.

      READ TABLE lt_creditos
        ASSIGNING FIELD-SYMBOL(<fs_creditos>)
        WITH KEY empresa       = <fs_creditos_all>-empresa
                 cliente       = <fs_creditos_all>-cliente
                 raizid        = <fs_creditos_all>-raizid
                 raizsn        = <fs_creditos_all>-raizsn
                 documento     = <fs_creditos_all>-documento
                 ano           = <fs_creditos_all>-ano
                 linha         = <fs_creditos_all>-linha
        BINARY SEARCH.

      IF sy-subrc EQ 0.
        lv_totcre = lv_totcre + <fs_creditos>-montante.
        lv_totres = lv_totres + <fs_creditos>-residual.

        MOVE-CORRESPONDING <fs_creditos> TO ls_creditoscli.

        ls_creditoscli-created_at      = lv_timestamp.
        ls_creditoscli-created_by      = sy-uname.
        ls_creditoscli-last_changed_at = lv_timestamp.
        ls_creditoscli-last_changed_by = sy-uname.
        ls_creditoscli-local_last_changed_at = lv_timestamp.

        DELETE FROM ztfi_creditoscli WHERE empresa   = <fs_creditos_all>-empresa
                                       AND documento = <fs_creditos_all>-documento
                                       AND ano       = <fs_creditos_all>-ano
                                       AND linha     = <fs_creditos_all>-linha. "#EC CI_IMUD_NESTED

        MODIFY ztfi_creditoscli FROM ls_creditoscli. "#EC CI_IMUD_NESTED

*        MODIFY ENTITIES OF zi_fi_cockpit_associacao_cre IN LOCAL MODE ENTITY creditos
*             UPDATE FIELDS ( residual )
*             WITH VALUE #( ( %tky          = <fs_creditos_all>-%tky
*                             empresa       = <fs_creditos_all>-empresa
*                             cliente       = <fs_creditos_all>-cliente
*                             raizid        = <fs_creditos_all>-raizid
*                             raizsn        = <fs_creditos_all>-raizsn
*                             documento     = <fs_creditos_all>-documento
*                             ano           = <fs_creditos_all>-ano
*                             linha         = <fs_creditos_all>-linha
*                             residual      = <fs_creditos>-residual
*                              ) )
*             FAILED DATA(lt_failed).

      ELSE.
        DELETE FROM ztfi_creditoscli WHERE empresa   = <fs_creditos_all>-empresa
                                       AND cliente   = <fs_creditos_all>-cliente
                                       AND raizid    = <fs_creditos_all>-raizid
                                       AND raizsn    = <fs_creditos_all>-raizsn
                                       AND documento = <fs_creditos_all>-documento
                                       AND ano       = <fs_creditos_all>-ano
                                       AND linha     = <fs_creditos_all>-linha. "#EC CI_IMUD_NESTED
      ENDIF.


    ENDLOOP.

*    MODIFY ENTITIES OF zi_fi_cockpit_associacao_cre IN LOCAL MODE ENTITY associ
*         UPDATE FIELDS ( totalizadordetalhe1 totalizadordetalhe4 )
*         WITH VALUE #( ( %tky          = <fs_associacao>-%tky
*                         empresa       = <fs_associacao>-empresa
*                         cliente       = <fs_associacao>-cliente
*                         raizid        = <fs_associacao>-raizid
*                         raizsn        = <fs_associacao>-raizsn
*                         totalizadordetalhe1 = lv_totcre
*                         totalizadordetalhe4 = lv_totres ) )
*         FAILED DATA(lt_failed_asso).

  ENDMETHOD.

  METHOD execassociacao.
    DATA: lt_return     TYPE bapiret2_t,
          lt_return_all TYPE bapiret2_t,
          lv_statuscode TYPE /xnfe/statuscode.

    DATA: ls_keys_imp TYPE zclfi_proc_assoc_cred=>ty_keys.

    DATA(lo_proc_pgfornecedor) = NEW zclfi_proc_assoc_cred(  ).

* ---------------------------------------------------------------------------
*   Verifica dados linhas
* ---------------------------------------------------------------------------
    LOOP AT keys INTO DATA(ls_keys).               "#EC CI_LOOP_INTO_WA

      ls_keys_imp = ls_keys-%tky.

      lo_proc_pgfornecedor->validacao(
        EXPORTING
          iv_parameter = gc_cds-credito
          iv_processo  = gc_proc-associacao_credito
          iv_bukrs     = ls_keys-%tky-empresa
          iv_belnr     = ls_keys-%tky-documento
          iv_gjahr     = ls_keys-%tky-ano
          iv_buzei     = ls_keys-%tky-linha
          is_keys      = ls_keys_imp
        IMPORTING
          et_return    = lt_return ).

      IF lt_return[] IS NOT INITIAL.
        lt_return_all[] = VALUE #( BASE lt_return_all ( parameter = gc_cds-credito
                                                        field = 'BELNR'
                                                        type = 'I'
                                                        id = 'ZFI_ASSOCI_CRE'
                                                        number = '017' ) ).
      ENDIF.

      APPEND LINES OF lt_return TO lt_return_all.

    ENDLOOP.

    IF NOT line_exists( lt_return_all[ type = 'E ' ] ).  "#EC CI_STDSEQ
*     ---------------------------------------------------------------------------
*     Recupera dados das linhas selecionadas
*     ---------------------------------------------------------------------------
      READ ENTITIES OF zi_fi_cockpit_associacao_cre IN LOCAL MODE ENTITY creditos
          ALL FIELDS
          WITH CORRESPONDING #( keys )
          RESULT DATA(lt_creditos)
          FAILED failed.

*       ---------------------------------------------------------------------------
*       Executa lançamento
*       ---------------------------------------------------------------------------
      lo_proc_pgfornecedor->executa_lanc_associ_cred(
        EXPORTING
          it_creditos  = CORRESPONDING #( lt_creditos )
        IMPORTING
          et_return    = lt_return ).

      IF line_exists( lt_return[ type = 'E ' ] ).        "#EC CI_STDSEQ
        lt_return_all[] = VALUE #( BASE lt_return_all ( parameter = gc_cds-credito
                                                        field = 'BELNR'
                                                        type = 'I'
                                                        id = 'ZFI_ASSOCI_CRE'
                                                        number = '017' ) ).
      ENDIF.

      APPEND LINES OF lt_return TO lt_return_all.

    ENDIF.

* ---------------------------------------------------------------------------
*     Retornar mensagens
* ---------------------------------------------------------------------------
    LOOP AT lt_return_all ASSIGNING FIELD-SYMBOL(<fs_return_all>).
      IF <fs_return_all>-type = 'E'.
        <fs_return_all>-type = 'I'.
      ENDIF.
    ENDLOOP.

    "Associação
    lt_return_all[] = VALUE #( BASE lt_return_all ( parameter = gc_cds-credito
                                                    field = 'BELNR'
                                                    type = 'I'
                                                    id = 'ZFI_ASSOCI_CRE'
                                                    number = '020' ) ).

    lo_proc_pgfornecedor->build_reported( EXPORTING it_return   = lt_return_all
                               IMPORTING es_reported = DATA(lt_reported) ).

    reported = CORRESPONDING #( DEEP lt_reported ).

  ENDMETHOD.

  METHOD pagarfornecedor.
    DATA: lt_return     TYPE bapiret2_t,
          lt_return_all TYPE bapiret2_t,
          lv_statuscode TYPE /xnfe/statuscode.

    DATA(lo_proc_pgfornecedor) = NEW zclfi_proc_assoc_cred(  ).

* ---------------------------------------------------------------------------
*   Verifica dados linhas
* ---------------------------------------------------------------------------
    LOOP AT keys INTO DATA(ls_keys).               "#EC CI_LOOP_INTO_WA

      lo_proc_pgfornecedor->validacao(
        EXPORTING
          iv_parameter = gc_cds-credito
          iv_processo  = gc_proc-pagar_fornecedor
          iv_bukrs     = ls_keys-%tky-empresa
          iv_belnr     = ls_keys-%tky-documento
          iv_gjahr     = ls_keys-%tky-ano
          iv_buzei     = ls_keys-%tky-linha
        IMPORTING
          et_return    = lt_return

      ).

      IF lt_return[] IS NOT INITIAL.
        lt_return_all[] = VALUE #( BASE lt_return_all ( parameter = gc_cds-credito
                                                        field = 'BELNR'
                                                        type = 'I'
                                                        id = 'ZFI_ASSOCI_CRE'
                                                        number = '018' ) ).
      ENDIF.

      APPEND LINES OF lt_return TO lt_return_all.

    ENDLOOP.

    IF NOT line_exists( lt_return_all[ type = 'E ' ] ).  "#EC CI_STDSEQ
*     ---------------------------------------------------------------------------
*     Recupera dados das linhas selecionadas
*     ---------------------------------------------------------------------------
      READ ENTITIES OF zi_fi_cockpit_associacao_cre IN LOCAL MODE ENTITY creditos
          ALL FIELDS
          WITH CORRESPONDING #( keys )
          RESULT DATA(lt_creditos)
          FAILED failed.

      LOOP AT lt_creditos ASSIGNING FIELD-SYMBOL(<fs_creditos>).

        IF <fs_creditos>-formapagamento NE 'T'.
          CONTINUE.
        ENDIF.

        lo_proc_pgfornecedor->valida_dados_bancarios(
          EXPORTING
            iv_bukrs     = <fs_creditos>-empresa
            iv_belnr     = <fs_creditos>-documento
            iv_gjahr     = <fs_creditos>-ano
            iv_buzei     = <fs_creditos>-linha
            iv_kunnr     = <fs_creditos>-cliente
          IMPORTING
            et_return    = lt_return ).

        IF line_exists( lt_return[ type = 'E ' ] ).      "#EC CI_STDSEQ
          lt_return_all[] = VALUE #( BASE lt_return_all ( parameter = gc_cds-credito
                                                          field = 'BELNR'
                                                          type = 'I'
                                                          id = 'ZFI_ASSOCI_CRE'
                                                          number = '018' ) ).
        ENDIF.

        APPEND LINES OF lt_return TO lt_return_all.

      ENDLOOP.
      IF NOT line_exists( lt_return_all[ type = 'E ' ] ). "#EC CI_STDSEQ
*       ---------------------------------------------------------------------------
*       Executa lançamento
*       ---------------------------------------------------------------------------
        lo_proc_pgfornecedor->executa_lanc_pagamento_forn(
          EXPORTING
            it_creditos  = CORRESPONDING #( lt_creditos )
          IMPORTING
            et_return    = lt_return
        ).
        APPEND LINES OF lt_return TO lt_return_all.

      ENDIF.

    ENDIF.

* ---------------------------------------------------------------------------
*     Retornar mensagens
* ---------------------------------------------------------------------------
    LOOP AT lt_return_all ASSIGNING FIELD-SYMBOL(<fs_return_all>).
      IF <fs_return_all>-type = 'E'.
        <fs_return_all>-type = 'I'.
      ENDIF.
    ENDLOOP.

    "Pagar Fornecedor
    lt_return_all[] = VALUE #( BASE lt_return_all ( parameter = gc_cds-credito
                                                    field = 'BELNR'
                                                    type = 'I'
                                                    id = 'ZFI_ASSOCI_CRE'
                                                    number = '019' ) ).

    lo_proc_pgfornecedor->build_reported( EXPORTING it_return   = lt_return_all
                               IMPORTING es_reported = DATA(lt_reported) ).

    reported = CORRESPONDING #( DEEP lt_reported ).

  ENDMETHOD.

  METHOD get_features.
* ---------------------------------------------------------------------------
* Recupera dados das linhas selecionadas
* ---------------------------------------------------------------------------
    READ ENTITIES OF zi_fi_cockpit_associacao_cre IN LOCAL MODE ENTITY creditos
        FIELDS ( empresa cliente raizid raizsn documento ano linha residual )
        WITH CORRESPONDING #( keys )
        RESULT DATA(lt_creditos)
        FAILED failed.

* ---------------------------------------------------------------------------
* Atualiza permissões de cada linha
* ---------------------------------------------------------------------------
    result = VALUE #( FOR ls_creditos IN lt_creditos
                    ( %tky     = ls_creditos-%tky
                      %update  = if_abap_behv=>fc-o-enabled
                      %field-residual = if_abap_behv=>fc-o-enabled ) ).

  ENDMETHOD.

  METHOD modifycreditocliente.
    DATA: lv_timestamp TYPE timestampl.

    GET TIME STAMP FIELD lv_timestamp.
*     ---------------------------------------------------------------------------
*     Recupera dados das linhas selecionadas
*     ---------------------------------------------------------------------------
    READ ENTITIES OF zi_fi_cockpit_associacao_cre IN LOCAL MODE
          ENTITY creditos
          FIELDS ( empresa cliente raizid raizsn documento ano linha residual tipodocumento
                 chavelancamento codigorze atribuicao referencia datalancamento
                 formapagamento moeda montante desconto )
          WITH CORRESPONDING #( keys )
          RESULT DATA(lt_creditos).

    IF lt_creditos[] IS NOT INITIAL.

      SORT lt_creditos BY empresa cliente raizid raizsn documento ano linha.

      SELECT    mandt,
                empresa,
                cliente,
                raizid,
                raizsn,
                documento,
                ano,
                linha,
                codcliente,
                residual,
                tipodocumento,
                chavelancamento,
                codigorze,
                atribuicao,
                referencia,
                datalancamento,
                formapagamento,
                moeda,
                montante,
                fatura,
                desconto,
                created_by,
                created_at,
                last_changed_by,
                last_changed_at,
                local_last_changed_at
         FROM ztfi_creditoscli
         INTO TABLE @DATA(lt_creditoscli)
         FOR ALL ENTRIES IN @lt_creditos
         WHERE empresa   = @lt_creditos-empresa
           AND documento = @lt_creditos-documento
           AND ano       = @lt_creditos-ano
           AND linha     = @lt_creditos-linha.
      IF sy-subrc = 0.
        LOOP AT lt_creditoscli ASSIGNING FIELD-SYMBOL(<fs_creditoscli>).
          READ TABLE lt_creditos
             ASSIGNING FIELD-SYMBOL(<fs_creditos>)
            WITH KEY empresa   = <fs_creditoscli>-empresa
                     cliente   = <fs_creditoscli>-cliente
                     raizid    = <fs_creditoscli>-raizid
                     raizsn    = <fs_creditoscli>-raizsn
                     documento = <fs_creditoscli>-documento
                     ano       = <fs_creditoscli>-ano
                     linha     = <fs_creditoscli>-linha
            BINARY SEARCH.
          IF sy-subrc = 0.
            <fs_creditoscli>-residual = <fs_creditos>-residual.
            <fs_creditoscli>-last_changed_at = lv_timestamp.
            <fs_creditoscli>-last_changed_by = sy-uname.
            <fs_creditoscli>-local_last_changed_at = lv_timestamp.
          ENDIF.
        ENDLOOP.

      ELSE.
        lt_creditoscli = VALUE #( FOR <fs_creditos_loop> IN lt_creditos
                         ( empresa         = <fs_creditos_loop>-empresa
                           cliente         = <fs_creditos_loop>-cliente
                           raizid          = <fs_creditos_loop>-raizid
                           raizsn          = <fs_creditos_loop>-raizsn
                           documento       = <fs_creditos_loop>-documento
                           ano             = <fs_creditos_loop>-ano
                           linha           = <fs_creditos_loop>-linha
                           codcliente      = <fs_creditos_loop>-codcliente
                           residual        = <fs_creditos_loop>-residual
                           tipodocumento   = <fs_creditos_loop>-tipodocumento
                           chavelancamento = <fs_creditos_loop>-chavelancamento
                           codigorze       = <fs_creditos_loop>-codigorze
                           atribuicao      = <fs_creditos_loop>-atribuicao
                           referencia      = <fs_creditos_loop>-referencia
                           datalancamento  = <fs_creditos_loop>-datalancamento
                           formapagamento  = <fs_creditos_loop>-formapagamento
                           moeda           = <fs_creditos_loop>-moeda
                           montante        = <fs_creditos_loop>-montante
                           desconto        = <fs_creditos_loop>-desconto
                           created_at      = lv_timestamp
                           created_by      = sy-uname
                           local_last_changed_at = lv_timestamp ) ).

      ENDIF.

      MODIFY ztfi_creditoscli FROM TABLE lt_creditoscli.

    ENDIF.

  ENDMETHOD.

  METHOD get_instance_authorizations.
    RETURN.
  ENDMETHOD.

ENDCLASS.

CLASS lhc_fatura DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    CONSTANTS:
      BEGIN OF gc_cds,
        credito TYPE string VALUE 'CREDITO',                       " Crédito
        fatura  TYPE string VALUE 'FATURA',                        " Fatura
      END OF gc_cds,
      BEGIN OF gc_proc,
        associacao_credito TYPE string VALUE 'ASSOCIACAO_CREDITO', " Associação Crédito
        pagar_fornecedor   TYPE string VALUE 'PAGAR_FORNECEDOR',   " Pagar Fornecedor
      END OF gc_proc.

    METHODS limpaselecaofat FOR MODIFY
      IMPORTING keys FOR ACTION fatura~limpaselecaofat.

    METHODS gravaselecao FOR MODIFY
      IMPORTING keys FOR ACTION fatura~gravaselecao.

    METHODS get_features FOR FEATURES
      IMPORTING keys REQUEST requested_features FOR fatura RESULT result.

    METHODS get_instance_authorizations FOR AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR fatura RESULT result.

ENDCLASS.

CLASS lhc_fatura IMPLEMENTATION.
  METHOD limpaselecaofat.
*     ---------------------------------------------------------------------------
*     Recupera dados das linhas selecionadas
*     ---------------------------------------------------------------------------
    READ ENTITIES OF zi_fi_cockpit_associacao_cre IN LOCAL MODE
    ENTITY associ
    ALL FIELDS WITH CORRESPONDING #( keys )
    RESULT DATA(lt_associacao)
    FAILED failed.

    READ TABLE lt_associacao ASSIGNING FIELD-SYMBOL(<fs_associacao>) INDEX 1.
    IF <fs_associacao> IS NOT ASSIGNED.
      RETURN.
    ENDIF.

    DELETE FROM ztfi_faturacli WHERE empresa       = <fs_associacao>-empresa
                                   AND cliente       = <fs_associacao>-cliente
                                   AND raizid        = <fs_associacao>-raizid
                                   AND raizsn        = <fs_associacao>-raizsn.

    MODIFY ENTITIES OF zi_fi_cockpit_associacao_cre IN LOCAL MODE ENTITY associ
         UPDATE FIELDS ( totalizadordetalhe1 totalizadordetalhe4 )
         WITH VALUE #( ( %tky          = <fs_associacao>-%tky
                         empresa       = <fs_associacao>-empresa
                         cliente       = <fs_associacao>-cliente
                         raizid        = <fs_associacao>-raizid
                         raizsn        = <fs_associacao>-raizsn
                         totalizadordetalhe3  = 0
                         totalizadordetalhe2  = 0 ) )
         FAILED DATA(lt_failed_asso).
  ENDMETHOD.

  METHOD gravaselecao.
    DATA: ls_faturacli TYPE ztfi_faturacli.

    DATA: lv_totfat    TYPE ze_totfat,
          lv_timestamp TYPE timestampl.

    GET TIME STAMP FIELD lv_timestamp.

*     ---------------------------------------------------------------------------
*     Recupera dados das linhas selecionadas
*     ---------------------------------------------------------------------------
    READ ENTITIES OF zi_fi_cockpit_associacao_cre IN LOCAL MODE
    ENTITY associ
    ALL FIELDS WITH CORRESPONDING #( keys )
    RESULT DATA(lt_associacao)
    FAILED failed.

    READ TABLE lt_associacao ASSIGNING FIELD-SYMBOL(<fs_associacao>) INDEX 1.
    IF <fs_associacao> IS NOT ASSIGNED.
      RETURN.
    ENDIF.

    " Lê os itens associados
    READ ENTITIES OF zi_fi_cockpit_associacao_cre
    ENTITY fatura
    ALL FIELDS WITH CORRESPONDING #( keys )
    RESULT DATA(lt_fatura)
    FAILED failed.

    SORT lt_fatura BY empresa cliente raizid raizsn documento ano linha.

    READ ENTITIES OF zi_fi_cockpit_associacao_cre
    ENTITY associ BY \_fatura
    ALL FIELDS WITH CORRESPONDING #( keys )
    RESULT DATA(lt_fatura_all)
    FAILED failed.

* ---------------------------------------------------------------------------
* Update field
* ---------------------------------------------------------------------------
    LOOP AT lt_fatura_all ASSIGNING FIELD-SYMBOL(<fs_fatura_all>).
      DATA(lv_marcado) = space.

      READ TABLE lt_fatura
        ASSIGNING FIELD-SYMBOL(<fs_fatura>)
        WITH KEY empresa       = <fs_fatura_all>-empresa
                 cliente       = <fs_fatura_all>-cliente
                 raizid        = <fs_fatura_all>-raizid
                 raizsn        = <fs_fatura_all>-raizsn
                 documento     = <fs_fatura_all>-documento
                 ano           = <fs_fatura_all>-ano
                 linha         = <fs_fatura_all>-linha
        BINARY SEARCH.
      IF sy-subrc EQ 0.
        lv_marcado = abap_true.
        lv_totfat = lv_totfat + <fs_fatura>-montante.

        MOVE-CORRESPONDING <fs_fatura> TO ls_faturacli.

        ls_faturacli-created_at      = lv_timestamp.
        ls_faturacli-created_by      = sy-uname.
        ls_faturacli-last_changed_at = lv_timestamp.
        ls_faturacli-last_changed_by = sy-uname.
        ls_faturacli-local_last_changed_at = lv_timestamp.

*        SELECT SINGLE documento
*          FROM ztfi_faturacli
*          INTO @DATA(lv_documento)
*         WHERE empresa       = @<fs_fatura_all>-empresa
*           AND cliente       = @<fs_fatura_all>-cliente
*           AND raizid        = @<fs_fatura_all>-raizid
*           AND raizsn        = @<fs_fatura_all>-raizsn
*           AND documento     = @<fs_fatura_all>-documento
*           AND ano           = @<fs_fatura_all>-ano
*           AND linha         = @<fs_fatura_all>-linha.
*        IF sy-subrc NE 0.
        MODIFY ztfi_faturacli FROM ls_faturacli.    "#EC CI_IMUD_NESTED
*        ELSE.
        MODIFY ENTITIES OF zi_fi_cockpit_associacao_cre IN LOCAL MODE ENTITY fatura
             UPDATE FIELDS ( marcado )
             WITH VALUE #( ( %tky          = <fs_fatura_all>-%tky
                             empresa       = <fs_fatura_all>-empresa
                             cliente       = <fs_fatura_all>-cliente
                             raizid        = <fs_fatura_all>-raizid
                             raizsn        = <fs_fatura_all>-raizsn
                             documento     = <fs_fatura_all>-documento
                             ano           = <fs_fatura_all>-ano
                             linha         = <fs_fatura_all>-linha
                             marcado       = lv_marcado
                              ) )
             FAILED DATA(lt_failed).
*        ENDIF.
      ELSE.
        DELETE FROM ztfi_faturacli WHERE empresa   = <fs_fatura_all>-empresa
                                     AND cliente   = <fs_fatura_all>-cliente
                                     AND raizid    = <fs_fatura_all>-raizid
                                     AND raizsn    = <fs_fatura_all>-raizsn
                                     AND documento = <fs_fatura_all>-documento
                                     AND ano       = <fs_fatura_all>-ano
                                     AND linha     = <fs_fatura_all>-linha. "#EC CI_IMUD_NESTED
      ENDIF.

    ENDLOOP.


    MODIFY ENTITIES OF zi_fi_cockpit_associacao_cre IN LOCAL MODE ENTITY associ
         UPDATE FIELDS ( totalizadordetalhe2 )
         WITH VALUE #( ( %tky          = <fs_associacao>-%tky
                         empresa       = <fs_associacao>-empresa
                         cliente       = <fs_associacao>-cliente
                         raizid        = <fs_associacao>-raizid
                         raizsn        = <fs_associacao>-raizsn
                         totalizadordetalhe2   = lv_totfat ) )
         FAILED DATA(lt_failed_asso).

  ENDMETHOD.

  METHOD get_features.
*     ---------------------------------------------------------------------------
*     Recupera dados das linhas selecionadas
*     ---------------------------------------------------------------------------
    READ ENTITIES OF zi_fi_cockpit_associacao_cre IN LOCAL MODE
    ENTITY associ
    ALL FIELDS WITH CORRESPONDING #( keys )
    RESULT DATA(lt_associacao)
    FAILED failed.

    READ TABLE lt_associacao ASSIGNING FIELD-SYMBOL(<fs_associacao>) INDEX 1.
    IF <fs_associacao> IS NOT ASSIGNED.
      RETURN.
    ENDIF.

    " Lê os itens associados
    READ ENTITIES OF zi_fi_cockpit_associacao_cre
    ENTITY fatura
    ALL FIELDS WITH CORRESPONDING #( keys )
    RESULT DATA(lt_fatura)
    FAILED failed.

* ---------------------------------------------------------------------------
* Atualiza permissões de cada linha
* ---------------------------------------------------------------------------
    result = VALUE #( FOR ls_fatura IN lt_fatura
                    ( %tky     = ls_fatura-%tky ) ).

  ENDMETHOD.

  METHOD get_instance_authorizations.
    RETURN.
  ENDMETHOD.

ENDCLASS.
