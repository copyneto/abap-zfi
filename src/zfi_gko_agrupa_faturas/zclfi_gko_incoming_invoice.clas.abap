CLASS zclfi_gko_incoming_invoice DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    TYPES:
      BEGIN OF ty_s_vendor,
        stcd1 TYPE lfa1-stcd1,
        name1 TYPE lfa1-name1,
      END OF ty_s_vendor .
    TYPES:
      ty_t_ZTTM_GKOT009 TYPE STANDARD TABLE OF zttm_gkot009 WITH DEFAULT KEY .
    TYPES:
      ty_t_ZTTM_GKOT010 TYPE STANDARD TABLE OF zttm_gkot010 WITH DEFAULT KEY .
    TYPES:
      ty_t_ZTTM_GKOT011 TYPE STANDARD TABLE OF zttm_gkot011 WITH DEFAULT KEY .
    TYPES:
      BEGIN OF ty_s_documents,
        docnum        TYPE j_1bnfdoc-docnum,
        nfnum         TYPE j_1bnfdoc-nfnum,
        nfenum        TYPE j_1bnfdoc-nfenum,
        series        TYPE zstm_gko_004-series,
        bukrs         TYPE j_1bnfdoc-bukrs,
        bupla         TYPE j_1bnfdoc-branch,
        belnr         TYPE bsik_view-belnr,
        gjahr         TYPE bsik_view-gjahr,
        buzei         TYPE bsik_view-buzei,
        parid         TYPE j_1bnfdoc-parid,
        docref        TYPE j_1bnfdoc-docref,
        wrbtr         TYPE bsis_view-wrbtr,
        zfbdt         TYPE bsis_view-zfbdt,
        zbd1t         TYPE bsik_view-zbd1t,
        zbd2t         TYPE bsik_view-zbd2t,
        zbd3t         TYPE bsik_view-zbd3t,
        shkzg         TYPE bsik_view-shkzg,
        rebzg         TYPE bsik_view-rebzg,
        objpr         TYPE REF TO zcltm_gko_process,
        acckey        TYPE zttm_gkot001-acckey,
        codstatus     TYPE zttm_gkot001-codstatus,
        num_fatura    TYPE zttm_gkot001-num_fatura,
        emit_cnpj_cpf TYPE zttm_gkot001-emit_cnpj_cpf,
        re_belnr      TYPE bkpf-belnr,
        re_gjahr      TYPE bkpf-gjahr,
        clear_belnr   TYPE bsak_view-belnr,
        clear_gjahr   TYPE bsak_view-gjahr,
        clear_buzei   TYPE bsak_view-buzei,
      END OF ty_s_documents .
    TYPES:
      BEGIN OF ty_s_doc_ref,
        docnum TYPE j_1bnfdoc-docnum,
        docref TYPE j_1bnfdoc-docref,
      END OF ty_s_doc_ref .
    TYPES:
      BEGIN OF ty_s_active,
        regio   TYPE j_1bnfe_active-regio,
        nfyear  TYPE j_1bnfe_active-nfyear,
        nfmonth TYPE j_1bnfe_active-nfmonth,
        stcd1   TYPE j_1bnfe_active-stcd1,
        model   TYPE j_1bnfe_active-model,
        serie   TYPE j_1bnfe_active-serie,
        nfnum9  TYPE j_1bnfe_active-nfnum9,
        docnum9 TYPE j_1bnfe_active-docnum9,
        cdv     TYPE j_1bnfe_active-cdv,
        docnum  TYPE j_1bnfe_active-docnum,
        branch  TYPE j_1bnfe_active-branch,
      END OF ty_s_active .
    TYPES:
      BEGIN OF ty_s_cte,
        acckey(44),
      END OF ty_s_cte .
    TYPES:
      BEGIN OF ty_s_nfnum,
        nfnum  TYPE j_1bnfdoc-nfnum,
        series TYPE j_1bnfdoc-series,
      END OF ty_s_nfnum .
    TYPES:
      BEGIN OF ty_s_nfenum,
        nfenum TYPE j_1bnfdoc-nfenum,
        series TYPE j_1bnfdoc-series,
      END OF ty_s_nfenum .
    TYPES:
      BEGIN OF ty_s_bsis,
        bukrs TYPE bsis_view-bukrs,
        belnr TYPE bsis_view-belnr,
        gjahr TYPE bsis_view-gjahr,
        buzei TYPE bsis_view-buzei,
        gsber TYPE bsis_view-gsber,
        kostl TYPE bsis_view-kostl,
        prctr TYPE bsis_view-prctr,
      END OF ty_s_bsis .
    TYPES:
      BEGIN OF ty_s_with_item,
        bukrs    TYPE with_item-bukrs,
        belnr    TYPE with_item-belnr,
        gjahr    TYPE with_item-gjahr,
        buzei    TYPE with_item-buzei,
        witht    TYPE with_item-witht,
        wt_qsshb TYPE with_item-wt_qsshb,
      END OF ty_s_with_item .
    TYPES:
      ty_t_with_item TYPE TABLE OF ty_s_with_item WITH DEFAULT KEY .
    TYPES:
      ty_t_documents TYPE STANDARD TABLE OF ty_s_documents WITH DEFAULT KEY .
    TYPES:
      ty_t_active TYPE STANDARD TABLE OF ty_s_active WITH DEFAULT KEY .
    TYPES:
      ty_t_doc_ref TYPE STANDARD TABLE OF ty_s_doc_ref WITH DEFAULT KEY .
    TYPES:
      ty_t_cte TYPE STANDARD TABLE OF ty_s_cte WITH DEFAULT KEY .
    TYPES:
      ty_t_nfnum TYPE STANDARD TABLE OF ty_s_nfnum WITH DEFAULT KEY .
    TYPES:
      ty_t_nfenum TYPE STANDARD TABLE OF ty_s_nfenum WITH DEFAULT KEY .
    TYPES:
      ty_t_bsis TYPE STANDARD TABLE OF ty_s_bsis WITH DEFAULT KEY .
    TYPES:
      ty_t_vendor TYPE STANDARD TABLE OF ty_s_vendor WITH DEFAULT KEY .

    CONSTANTS:
      BEGIN OF gc_codstatus,
        documento_integrado            TYPE ze_gko_codstatus VALUE '100',
        aguardando_dados_adicionais    TYPE ze_gko_codstatus VALUE '101',
        cenario_identificado           TYPE ze_gko_codstatus VALUE '200',
        pedido_compra_criado           TYPE ze_gko_codstatus VALUE '300',
        pedido_compra_aprovado         TYPE ze_gko_codstatus VALUE '301',
        miro_memorizada                TYPE ze_gko_codstatus VALUE '400',
        miro_confirmada                TYPE ze_gko_codstatus VALUE '401',
        agrupamento_efetuado           TYPE ze_gko_codstatus VALUE '500',
        aguardando_reagrupamento       TYPE ze_gko_codstatus VALUE '501',
        pagamento_efetuado             TYPE ze_gko_codstatus VALUE '600',
        evt_rejeicao_aguard_sefaz      TYPE ze_gko_codstatus VALUE '700',
        evt_rejeicao_confirmado_sefaz  TYPE ze_gko_codstatus VALUE '701',
        estorno_total_realizado        TYPE ze_gko_codstatus VALUE '800',
        estorno_realizado              TYPE ze_gko_codstatus VALUE '801',
        estorno_miro_deb_p_realizado   TYPE ze_gko_codstatus VALUE '802',
        estorno_agrupamento_realizado  TYPE ze_gko_codstatus VALUE '803',
        estorno_miro_realizado_n       TYPE ze_gko_codstatus VALUE '804',
        estorno_miro_deb_p_realizado_n TYPE ze_gko_codstatus VALUE '805',
        pedido_eliminado               TYPE ze_gko_codstatus VALUE '806',
        documento_cancelado            TYPE ze_gko_codstatus VALUE '900',
        documento_cancelado_reversao_r TYPE ze_gko_codstatus VALUE '901',
        aguardando_estorno_agrupamento TYPE ze_gko_codstatus VALUE '902',
        cenario_nao_identificado       TYPE ze_gko_codstatus VALUE 'E01',
        cod_transp_nao_encontrado      TYPE ze_gko_codstatus VALUE 'E02',
        cod_tomador_nao_encontrado     TYPE ze_gko_codstatus VALUE 'E03',
        cod_remetente_nao_encontrado   TYPE ze_gko_codstatus VALUE 'E04',
        cod_dest_nao_encontrado        TYPE ze_gko_codstatus VALUE 'E05',
        empresa_filial_nao_encontrado  TYPE ze_gko_codstatus VALUE 'E06',
        cenario_nao_configurado        TYPE ze_gko_codstatus VALUE 'E07',
        erro_ao_criar_pedido_compras   TYPE ze_gko_codstatus VALUE 'E08',
        erro_ao_criar_miro             TYPE ze_gko_codstatus VALUE 'E09',
        erro_ao_realizar_estorno_total TYPE ze_gko_codstatus VALUE 'E10',
        erro_ao_realizar_estorno       TYPE ze_gko_codstatus VALUE 'E11',
        erro_ao_criar_miro_deb_post    TYPE ze_gko_codstatus VALUE 'E12',
        sem_anexo_atribuido            TYPE ze_gko_codstatus VALUE 'E13',
        sem_anexo_atribuido_miro_deb_p TYPE ze_gko_codstatus VALUE 'E14',
        erro_estorno_agrupamento       TYPE ze_gko_codstatus VALUE 'E15',
        erro_estorno_miro_deb_post     TYPE ze_gko_codstatus VALUE 'E16',
        erro_estorno_miro              TYPE ze_gko_codstatus VALUE 'E17',
        erro_ao_eliminar_pedido        TYPE ze_gko_codstatus VALUE 'E18',
        erro_ao_realizar_estorno_canc  TYPE ze_gko_codstatus VALUE 'E19',
        erro_ao_confirmar_evt_rejeicao TYPE ze_gko_codstatus VALUE 'E20',
        erro_agrupamento_manual        TYPE ze_gko_codstatus VALUE 'E40',
        erro_agrupamento               TYPE ze_gko_codstatus VALUE 'E41',
      END OF gc_codstatus .

    METHODS set_invoice
      IMPORTING
        !is_invoice        TYPE zstm_gko_002 OPTIONAL
        !iv_invoice_number TYPE xblnr OPTIONAL
        !iv_cnpj_issue     TYPE stcd1 OPTIONAL
        iv_tpprocess       TYPE ze_gko_tpprocess DEFAULT zcltm_gko_process=>gc_tpprocess-manual
      RETURNING
        VALUE(ro_instance) TYPE REF TO zclfi_gko_incoming_invoice .
    METHODS set_invoice_multi
      IMPORTING
        !it_invoices        TYPE zctgtm_gko008 OPTIONAL
        !it_invoices_number TYPE zctgtm_gko009v2 OPTIONAL
        iv_tpprocess        TYPE ze_gko_tpprocess DEFAULT zcltm_gko_process=>gc_tpprocess-manual
      RETURNING
        VALUE(ro_instance)  TYPE REF TO zclfi_gko_incoming_invoice
      RAISING
        zcxtm_gko_incoming_invoice .
    METHODS recover_data_reprocess
      RAISING
        zcxtm_gko_incoming_invoice .
    METHODS recover_data_reprocess_multi
      RAISING
        zcxtm_gko_incoming_invoice .
    METHODS start_multi
      RETURNING
        VALUE(ro_instance) TYPE REF TO zclfi_gko_incoming_invoice
      RAISING
        zcxtm_gko_incoming_invoice .
    METHODS start
      RETURNING
        VALUE(ro_instance) TYPE REF TO zclfi_gko_incoming_invoice .
    METHODS find_documents_invoice
      RAISING
        zcxtm_gko_incoming_invoice .
    METHODS find_documents_invoice_multi
      RAISING
        zcxtm_gko_incoming_invoice .
    METHODS find_documents_by_nfs
      RETURNING
        VALUE(rt_documents) TYPE ty_t_documents
      RAISING
        zcxtm_gko_incoming_invoice .
    METHODS find_documents_by_nfs_multi
      RETURNING
        VALUE(rt_documents) TYPE ty_t_documents .
    CLASS-METHODS get_status_description
      IMPORTING
        !iv_status            TYPE zttm_gkot001-codstatus
      RETURNING
        VALUE(rv_description) TYPE val_text .
    METHODS remove
      RETURNING
        VALUE(ro_instance) TYPE REF TO zclfi_gko_incoming_invoice .
    METHODS get_errors
      EXPORTING
        !et_return       TYPE bapiret2_tab
      RETURNING
        VALUE(rt_errors) TYPE zcxtm_gko=>ty_t_errors .
    CLASS-METHODS setup_messages
      IMPORTING
        !p_task TYPE clike .
    METHODS process_fat_to_agrup
      RAISING
        zcxtm_gko_incoming_invoice .

    METHODS check_status
      EXPORTING et_return TYPE bapiret2_t.
  PROTECTED SECTION.
  PRIVATE SECTION.

    DATA gv_lifnr TYPE lifnr .
    DATA gv_blart TYPE bkpf-blart .
    DATA gv_waers TYPE bkpf-waers VALUE 'BRL' ##NO_TEXT.
    DATA gv_key_clearing TYPE bseg-bschl VALUE '31' ##NO_TEXT.
    DATA gv_key_discount TYPE bseg-bschl VALUE '50' ##NO_TEXT.
    DATA gv_account_discount TYPE bseg-hkont .
    DATA gv_payment_condition TYPE bseg-zterm .
    DATA gv_txt_doc TYPE bkpf-bktxt .
    DATA gv_tpprocess TYPE ze_gko_tpprocess.
    DATA gv_txt_itm TYPE bseg-sgtxt .
    DATA gv_txt_itm_dsc TYPE bseg-sgtxt .
    DATA gs_invoice TYPE zstm_gko_002 .
    CONSTANTS gc_partyp TYPE j_1bnfdoc-partyp VALUE 'V' ##NO_TEXT.
    CONSTANTS gc_direct TYPE j_1bnfdoc-direct VALUE 1 ##NO_TEXT.
    CONSTANTS gc_replace_xblnr TYPE string VALUE '&REF&' ##NO_TEXT.
    CONSTANTS gc_replace_nomef TYPE string VALUE '&NOME_FOR&' ##NO_TEXT.
    DATA gt_bsis TYPE ty_t_bsis .
    DATA gt_documents TYPE ty_t_documents .
    DATA gt_with_item TYPE ty_t_with_item .
    DATA gt_invoices TYPE zctgtm_gko008 .
    DATA gt_invoices_number TYPE zctgtm_gko009v2 .
    DATA gt_vendor TYPE ty_t_vendor .
    DATA gt_zttm_gkot009_save TYPE ty_t_zttm_gkot009 .
    DATA gt_zttm_gkot010_save TYPE ty_t_zttm_gkot010 .
    DATA gt_zttm_gkot011_save TYPE ty_t_zttm_gkot011 .
    DATA gt_errors TYPE zcxtm_gko=>ty_t_errors .
    CLASS-DATA gv_wait_async TYPE abap_bool .
    CLASS-DATA gv_subrc TYPE sy-subrc .
    CLASS-DATA gs_return TYPE bapiret2 .
    CLASS-DATA gt_return TYPE bapiret2_tab .

    METHODS check
      RAISING
        zcxtm_gko_incoming_invoice .

    METHODS check_params
      RAISING
        zcxtm_gko_incoming_invoice .
    METHODS check_inputs
      RAISING
        zcxtm_gko_incoming_invoice .
    METHODS find_documents_by_cte
      RETURNING
        VALUE(rt_documents) TYPE ty_t_documents
      RAISING
        zcxtm_gko_incoming_invoice .
    METHODS find_documents_by_cte_multi
      RETURNING
        VALUE(rt_documents) TYPE ty_t_documents .
    METHODS validate_value
      RAISING
        zcxtm_gko_incoming_invoice .
    METHODS invoice_update
      RAISING
        zcxtm_gko_incoming_invoice .
    METHODS set_lock_documents
      IMPORTING
        !iv_block TYPE newdata .
    METHODS invoice_grouping
      RAISING
        zcxtm_gko_incoming_invoice .
    METHODS invoice_grouping_multi
      RAISING
        zcxtm_gko_incoming_invoice .
    METHODS get_account_discount .
    METHODS get_document_type .
    METHODS get_vendor_name
      IMPORTING
        !iv_cnpj_issue  TYPE stcd1
      RETURNING
        VALUE(rv_name1) TYPE lfa1-name1 .
    METHODS select_vendor
      RETURNING
        VALUE(rt_vendor) TYPE ty_t_vendor .
    METHODS get_due_date
      RETURNING
        VALUE(rv_due_date) TYPE sy-datum .
    METHODS save_document
      IMPORTING
        !it_blntab TYPE re_t_ex_blntab .
    METHODS save_document_multi
      IMPORTING
        !is_blntab TYPE blntab .
    METHODS save_data_db .
    METHODS save_data_reprocess .
    METHODS save_data_reprocess_multi .
    METHODS remove_data_reprocess
      RAISING
        zcxtm_gko_incoming_invoice .
ENDCLASS.



CLASS ZCLFI_GKO_INCOMING_INVOICE IMPLEMENTATION.


  METHOD validate_value.

    DATA lv_sum_invoices TYPE wrbtr.

    SELECT bukrs
         , belnr
         , gjahr
         , buzei
         , witht
         , wt_qsshb
      FROM with_item
      INTO TABLE @gt_with_item
      FOR ALL ENTRIES IN @gt_documents
      WHERE bukrs = @gt_documents-bukrs
        AND belnr = @gt_documents-belnr
        AND gjahr = @gt_documents-gjahr
        AND buzei = @gt_documents-buzei.

    LOOP AT gt_documents ASSIGNING FIELD-SYMBOL(<fs_s_documents>).

      lv_sum_invoices = lv_sum_invoices + <fs_s_documents>-wrbtr.

      LOOP AT gt_with_item ASSIGNING FIELD-SYMBOL(<fs_s_with_item>) WHERE bukrs = <fs_s_documents>-bukrs
                                                                      AND belnr = <fs_s_documents>-belnr
                                                                      AND gjahr = <fs_s_documents>-gjahr
                                                                      AND buzei = <fs_s_documents>-buzei.
        lv_sum_invoices = lv_sum_invoices + abs( <fs_s_with_item>-wt_qsshb ).
      ENDLOOP.

* BEGIN OF JWSILVA - 01.03.2023
      " Fatura &1 já foi compensada. Não é possível continuar com agrupamento.
      IF <fs_s_documents>-clear_belnr IS NOT INITIAL.
        RAISE EXCEPTION TYPE zcxtm_gko_incoming_invoice
          EXPORTING
            textid   = zcxtm_gko_incoming_invoice=>gc_invoice_already_cleared
            gv_msgv1 = CONV msgv1( <fs_s_documents>-re_belnr ).
      ENDIF.
* END OF JWSILVA - 01.03.2023

    ENDLOOP.

    IF gs_invoice-invoice_value NE lv_sum_invoices.
      RAISE EXCEPTION TYPE zcxtm_gko_incoming_invoice
        EXPORTING
          textid   = zcxtm_gko_incoming_invoice=>gc_value_not_coincident
          gv_msgv1 = CONV msgv1( gs_invoice-invoice_number )
          gv_msgv2 = CONV msgv2( zclfi_gko_clearing=>conv_amount( gs_invoice-invoice_value ) )
          gv_msgv3 = CONV msgv3( zclfi_gko_clearing=>conv_amount( lv_sum_invoices ) ).
    ENDIF.

  ENDMETHOD.


  METHOD start_multi.

    ro_instance = me.

    TRY.

        " Busca CTe's e NFS's no SAP
        find_documents_invoice_multi(  ).

        " Agrupamento de Faturas
        invoice_grouping_multi( ).

      CATCH zcxtm_gko_incoming_invoice INTO DATA(lo_cx_incoming_invoice).

        LOOP AT gt_documents ASSIGNING FIELD-SYMBOL(<fs_s_documents>).
          IF <fs_s_documents>-objpr IS BOUND.
            <fs_s_documents>-objpr->free(  ).
          ENDIF.
        ENDLOOP.

        TRY.
            " Bloqueia os documentos
            set_lock_documents( iv_block = 'G' ).

            " Atulizas as faturas existentes no monitor
            invoice_update( ).
          CATCH zcxtm_gko_incoming_invoice INTO DATA(lo_cx_incoming_invoice_s).
            APPEND lo_cx_incoming_invoice TO gt_errors.
        ENDTRY.

        APPEND lo_cx_incoming_invoice TO gt_errors.
    ENDTRY.

  ENDMETHOD.


  METHOD start.

    ro_instance = me.
    TRY.
        " Verifica os parâmetros de importação
        check( ).

        " Busca CTe's e NFS's no SAP
        find_documents_invoice(  ).

        " Agrupamento de Faturas
        invoice_grouping( ).

      CATCH zcxtm_gko_incoming_invoice INTO DATA(lo_cx_incoming_invoice).

        LOOP AT gt_documents ASSIGNING FIELD-SYMBOL(<fs_s_documents>).
          IF <fs_s_documents>-objpr IS BOUND.
            <fs_s_documents>-objpr->free(  ).
          ENDIF.
        ENDLOOP.

        TRY.
            " Bloqueia os documentos
            set_lock_documents( iv_block = 'G' ).

            " Atulizas as faturas existentes no monitor
            invoice_update( ).
          CATCH zcxtm_gko_incoming_invoice INTO DATA(lo_cx_incoming_invoice_s).
            APPEND lo_cx_incoming_invoice TO gt_errors.
        ENDTRY.

        APPEND lo_cx_incoming_invoice TO gt_errors.
    ENDTRY.

  ENDMETHOD.


  METHOD set_lock_documents.

    LOOP AT gt_documents ASSIGNING FIELD-SYMBOL(<fs_s_documents>).

      TRY.

          DATA(lt_accchg) = VALUE fdm_t_accchg( ( fdname = 'ZLSPR'
                                                  newval = iv_block ) ).

*          CALL FUNCTION 'FI_DOCUMENT_CHANGE'
*            EXPORTING
*              i_bukrs              = <fs_s_documents>-bukrs
*              i_belnr              = <fs_s_documents>-belnr
*              i_gjahr              = <fs_s_documents>-gjahr
*              i_buzei              = <fs_s_documents>-buzei
*            TABLES
*              t_accchg             = lt_accchg
*            EXCEPTIONS
*              no_reference         = 1
*              no_document          = 2
*              many_documents       = 3
*              wrong_input          = 4
*              overwrite_creditcard = 5
*              OTHERS               = 6.

          TRY.
              CALL FUNCTION 'ZFMTM_GKO_DOCUMENT_CHANGE'
                STARTING NEW TASK 'TM_DOCUMENT_CHANGE'
                CALLING setup_messages ON END OF TASK
                EXPORTING
                  iv_buzei  = <fs_s_documents>-buzei
                  iv_bukrs  = <fs_s_documents>-bukrs
                  iv_belnr  = <fs_s_documents>-belnr
                  iv_gjahr  = <fs_s_documents>-gjahr
                  it_accchg = lt_accchg.
            CATCH cx_root INTO DATA(lo_root).

              DATA(lv_message_error) = CONV char200( lo_root->get_longtext( ) ).

*              RAISE EXCEPTION TYPE zcxtm_gko_incoming_invoice
*                EXPORTING
*                  textid   = zcxtm_gko_incoming_invoice=>gc_abort_processing
*                  gv_msgv1 = lv_message_error+0(50)
*                  gv_msgv2 = lv_message_error+50(50)
*                  gv_msgv3 = lv_message_error+100(50)
*                  gv_msgv4 = lv_message_error+150(50).

          ENDTRY.

          WAIT UNTIL gv_wait_async = abap_true.
          CLEAR gv_wait_async.

          IF gv_subrc <> 0 AND gs_return IS NOT INITIAL.
            MESSAGE ID gs_return-id TYPE gs_return-type NUMBER gs_return-number WITH gs_return-message_v1
                                                                                     gs_return-message_v2
                                                                                     gs_return-message_v3
                                                                                     gs_return-message_v4
                                                                                INTO lv_message_error.

*              RAISE EXCEPTION TYPE zcxtm_gko_incoming_invoice
*                EXPORTING
*                  textid   = zcxtm_gko_incoming_invoice=>gc_abort_processing
*                  gv_msgv1 = lv_message_error+0(50)
*                  gv_msgv2 = lv_message_error+50(50)
*                  gv_msgv3 = lv_message_error+100(50)
*                  gv_msgv4 = lv_message_error+150(50).
          ENDIF.

        CATCH zcxtm_gko_incoming_invoice INTO DATA(lo_cx_incoming_invoice).
          APPEND lo_cx_incoming_invoice TO gt_errors.
      ENDTRY.
    ENDLOOP.

  ENDMETHOD.


  METHOD set_invoice_multi.

    gv_tpprocess = iv_tpprocess.

    ro_instance = me.

    "Processamento pela interface de fatura
    IF it_invoices IS NOT INITIAL.
      gt_invoices = it_invoices.                        "#EC CI_CONV_OK
      "Processamento pelos dados guardados nas tabelas do GKO
    ELSE.
      gt_invoices_number = it_invoices_number.
      recover_data_reprocess_multi(  ).
    ENDIF.

  ENDMETHOD.


  METHOD set_invoice.

    gv_tpprocess = iv_tpprocess.

    ro_instance = me.

    " Processamento pela interface de fatura
    IF is_invoice IS NOT INITIAL.
      gs_invoice = is_invoice.
      " Processamento pelos dados guardados nas tabelas do GKO
    ELSE.
      TRY.
          gs_invoice-invoice_number = iv_invoice_number.
          gs_invoice-cnpj_issue     = iv_cnpj_issue.
          recover_data_reprocess(  ).
        CATCH zcxtm_gko_incoming_invoice INTO DATA(lo_cx_incoming_invoice).
          APPEND lo_cx_incoming_invoice TO gt_errors.
      ENDTRY.
    ENDIF.

  ENDMETHOD.


  METHOD select_vendor.

    SELECT
      stcd1,
      name1
        FROM lfa1
        INTO TABLE @rt_vendor
      FOR ALL ENTRIES IN @gt_invoices
        WHERE stcd1 EQ @gt_invoices-cnpj_issue.

  ENDMETHOD.


  METHOD save_document_multi.

    DATA lv_subrc TYPE sy-subrc.
    DATA lv_number TYPE sy-tabix.

    DATA lt_enq TYPE STANDARD TABLE OF seqg3.

    DATA(ls_blntab) = is_blntab.

    "Verificar se o documento está com bloqueio
    DO 3 TIMES.

      DATA(lv_garg) = CONV seqg3-garg( |{ sy-mandt }{ ls_blntab-bukrs }{ ls_blntab-belnr }{ ls_blntab-gjahr }| ).
      CALL FUNCTION 'ENQUEUE_READ'
        EXPORTING
          gclient               = sy-mandt
          gname                 = 'BKPF'
          garg                  = lv_garg
        IMPORTING
          number                = lv_number
          subrc                 = lv_subrc
        TABLES
          enq                   = lt_enq
        EXCEPTIONS
          communication_failure = 1
          system_failure        = 2
          OTHERS                = 3.
      IF sy-subrc IS NOT INITIAL.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 INTO DATA(lv_message_error).
      ENDIF.

      IF lv_subrc IS INITIAL AND lv_number EQ 0.
        EXIT.
      ELSE.
        WAIT UP TO 1 SECONDS.
      ENDIF.

    ENDDO.

    "Atualizar informação no cabeçalho do documento
    DATA(lt_accchg) = VALUE fdm_t_accchg( ( fdname = 'XREF1_HD' newval = to_upper( gv_txt_doc ) ) ).
*    CALL FUNCTION 'FI_DOCUMENT_CHANGE'
*      EXPORTING
*        i_bukrs              = ls_blntab-bukrs
*        i_belnr              = ls_blntab-belnr
*        i_gjahr              = ls_blntab-gjahr
*        i_buzei              = 001
*      TABLES
*        t_accchg             = lt_accchg
*      EXCEPTIONS
*        no_reference         = 1
*        no_document          = 2
*        many_documents       = 3
*        wrong_input          = 4
*        overwrite_creditcard = 5
*        error_message        = 99
*        OTHERS               = 6.

    TRY.
        CALL FUNCTION 'ZFMTM_GKO_DOCUMENT_CHANGE'
          STARTING NEW TASK 'TM_DOCUMENT_CHANGE'
          CALLING setup_messages ON END OF TASK
          EXPORTING
            iv_buzei  = 001
            iv_bukrs  = ls_blntab-bukrs
            iv_belnr  = ls_blntab-belnr
            iv_gjahr  = ls_blntab-gjahr
            it_accchg = lt_accchg.
      CATCH cx_root INTO DATA(lo_root).

        lv_message_error = CONV char200( lo_root->get_longtext( ) ).

*              RAISE EXCEPTION TYPE zcxtm_gko_incoming_invoice
*                EXPORTING
*                  textid   = zcxtm_gko_incoming_invoice=>gc_abort_processing
*                  gv_msgv1 = lv_message_error+0(50)
*                  gv_msgv2 = lv_message_error+50(50)
*                  gv_msgv3 = lv_message_error+100(50)
*                  gv_msgv4 = lv_message_error+150(50).

    ENDTRY.


    WAIT UNTIL gv_wait_async = abap_true.
    CLEAR gv_wait_async.

    IF sy-subrc IS NOT INITIAL.
      MESSAGE ID gs_return-id TYPE gs_return-type NUMBER gs_return-number WITH gs_return-message_v1
                                                                               gs_return-message_v2
                                                                               gs_return-message_v3
                                                                               gs_return-message_v4
                                                                          INTO lv_message_error.
    ENDIF.

  ENDMETHOD.


  METHOD save_document.

    DATA lv_subrc TYPE sy-subrc.
    DATA lv_number TYPE sy-tabix.

    DATA lv_vlr_total_desc TYPE wrbtr.
    DATA lv_vlr_desc       TYPE wrbtr.

    DATA lt_enq TYPE STANDARD TABLE OF seqg3.

    TRY.
        DATA(ls_blntab) = it_blntab[ 1 ].
      CATCH cx_root.
    ENDTRY.

    CLEAR: lv_vlr_total_desc.

    " Salvar as informações no Monitor GKO
    LOOP AT gt_documents ASSIGNING FIELD-SYMBOL(<fs_s_documents>).

      " Calculo Proporcional de Desconto
      IF gs_invoice-invoice_discount_value IS NOT INITIAL AND
         gs_invoice-invoice_value          IS NOT INITIAL.

        lv_vlr_desc = ( gs_invoice-invoice_discount_value / gs_invoice-invoice_value ) * <fs_s_documents>-wrbtr.
        lv_vlr_total_desc = lv_vlr_total_desc + lv_vlr_desc.

        AT LAST.
          lv_vlr_total_desc = gs_invoice-invoice_discount_value - lv_vlr_total_desc.
          lv_vlr_desc = lv_vlr_desc + lv_vlr_total_desc.
        ENDAT.

      ENDIF.

      TRY.
          <fs_s_documents>-objpr->set_invoice_grouping( EXPORTING iv_num_fatura = gs_invoice-invoice_number
                                                                  iv_vct_gko    = gs_invoice-invoice_due_date
                                                                  iv_usr_lib    = gs_invoice-user_approval
                                                                  iv_bukrs      = ls_blntab-bukrs
                                                                  iv_belnr      = ls_blntab-belnr
                                                                  iv_gjahr      = ls_blntab-gjahr
                                                                  iv_desconto   = lv_vlr_desc ).
          <fs_s_documents>-objpr->persist(  ).
          <fs_s_documents>-objpr->free(  ).
        CATCH zcxtm_gko_process INTO DATA(lo_cx_process).
          APPEND lo_cx_process TO gt_errors.
      ENDTRY.
    ENDLOOP.

    " Salvar informações para reprocessamento
    save_data_reprocess(  ).

    IF ls_blntab IS NOT INITIAL.
      APPEND INITIAL LINE TO gt_return ASSIGNING FIELD-SYMBOL(<fs_msg>).
      <fs_msg>-id         = 'ZFI_GKO_AGRUP'.
      <fs_msg>-number     = '001'.
      <fs_msg>-type       = 'S'.
      <fs_msg>-message_v1 = ls_blntab-bukrs.
      <fs_msg>-message_v2 = ls_blntab-belnr.
      <fs_msg>-message_v3 = ls_blntab-gjahr.
    ENDIF.

    " Verificar se o documento está com bloqueio
    DO 3 TIMES.

      DATA(lv_garg) = CONV seqg3-garg( |{ sy-mandt }{ ls_blntab-bukrs }{ ls_blntab-belnr }{ ls_blntab-gjahr }| ).
      CALL FUNCTION 'ENQUEUE_READ'
        EXPORTING
          gclient               = sy-mandt
          gname                 = 'BKPF'
          garg                  = lv_garg
        IMPORTING
          number                = lv_number
          subrc                 = lv_subrc
        TABLES
          enq                   = lt_enq
        EXCEPTIONS
          communication_failure = 1
          system_failure        = 2
          OTHERS                = 3.
      IF sy-subrc IS NOT INITIAL.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 INTO DATA(lv_message_error).
      ENDIF.

      IF lv_subrc IS INITIAL AND lv_number EQ 0.
        EXIT.
      ELSE.
        WAIT UP TO 1 SECONDS.
      ENDIF.

    ENDDO.

    " Atualizar informação no cabeçalho do documento
    DATA(lt_accchg) = VALUE fdm_t_accchg( ( fdname = 'XREF1_HD' newval = to_upper( gv_txt_doc ) ) ).
*    CALL FUNCTION 'FI_DOCUMENT_CHANGE'
*      EXPORTING
*        i_bukrs              = ls_blntab-bukrs
*        i_belnr              = ls_blntab-belnr
*        i_gjahr              = ls_blntab-gjahr
*        i_buzei              = 001
*      TABLES
*        t_accchg             = lt_accchg
*      EXCEPTIONS
*        no_reference         = 1
*        no_document          = 2
*        many_documents       = 3
*        wrong_input          = 4
*        overwrite_creditcard = 5
*        error_message        = 99
*        OTHERS               = 6.

    CALL FUNCTION 'ZFMTM_GKO_DOCUMENT_CHANGE'
      STARTING NEW TASK 'TM_DOCUMENT_CHANGE'
      CALLING setup_messages ON END OF TASK
      EXPORTING
        iv_buzei  = 001
        iv_bukrs  = ls_blntab-bukrs
        iv_belnr  = ls_blntab-belnr
        iv_gjahr  = ls_blntab-gjahr
        it_accchg = lt_accchg.

    WAIT UNTIL gv_wait_async = abap_true.
    CLEAR gv_wait_async.

    IF sy-subrc IS NOT INITIAL.
      MESSAGE ID gs_return-id TYPE gs_return-type NUMBER gs_return-number WITH gs_return-message_v1
                                                                               gs_return-message_v2
                                                                               gs_return-message_v3
                                                                               gs_return-message_v4
                                                                          INTO lv_message_error.
    ENDIF.

  ENDMETHOD.


  METHOD save_data_reprocess_multi.

    DATA lt_zttm_gkot010 TYPE ty_t_zttm_gkot010.
    DATA lt_zttm_gkot011 TYPE ty_t_zttm_gkot011.

    "preenche os dados da fatura
    DATA(ls_zttm_gkot009) = VALUE zttm_gkot009( xblnr       = gs_invoice-invoice_number
                                                bldat       = gs_invoice-invoice_issue_date
                                                zfbdt       = gs_invoice-invoice_due_date
                                                stcd1       = gs_invoice-cnpj_issue
                                                newtr       = gs_invoice-invoice_value
                                                newdis      = gs_invoice-invoice_discount_value
                                                user_approv = gs_invoice-user_approval ).

    "cte's usadas no agrupamento
    LOOP AT gs_invoice-cte ASSIGNING FIELD-SYMBOL(<fs_s_cte>).
      APPEND INITIAL LINE TO lt_zttm_gkot010 ASSIGNING FIELD-SYMBOL(<fs_s_zttm_gkot010>).
      <fs_s_zttm_gkot010>-xblnr  = gs_invoice-invoice_number.
      <fs_s_zttm_gkot010>-stcd1  = gs_invoice-cnpj_issue.
      <fs_s_zttm_gkot010>-bldat  = gs_invoice-invoice_issue_date.
      <fs_s_zttm_gkot010>-seqcte = sy-tabix.
      <fs_s_zttm_gkot010>-acckey = CONV #( <fs_s_cte> ).
    ENDLOOP.

    "nf's usadas no agrupamento
    LOOP AT gs_invoice-nfs ASSIGNING FIELD-SYMBOL(<fs_s_nfs>).
      APPEND INITIAL LINE TO lt_zttm_gkot011 ASSIGNING FIELD-SYMBOL(<fs_s_zttm_gkot011>).
      <fs_s_zttm_gkot011>-xblnr        = gs_invoice-invoice_number.
      <fs_s_zttm_gkot011>-stcd1        = gs_invoice-cnpj_issue.
      <fs_s_zttm_gkot011>-bldat        = gs_invoice-invoice_issue_date.
      <fs_s_zttm_gkot011>-seqnfs       = sy-tabix.
      <fs_s_zttm_gkot011>-docdat       = <fs_s_nfs>-issue_date.
      <fs_s_zttm_gkot011>-prefno       = <fs_s_nfs>-prefno.
      <fs_s_zttm_gkot011>-nfnum        = <fs_s_nfs>-nfnum.
      <fs_s_zttm_gkot011>-nfenum       = <fs_s_nfs>-nfenum.
      <fs_s_zttm_gkot011>-series       = <fs_s_nfs>-series.
      <fs_s_zttm_gkot011>-stcd1_transp = <fs_s_nfs>-stcd1_transp.
    ENDLOOP.

    "gravar os dados
    APPEND ls_zttm_gkot009 TO gt_zttm_gkot009_save.

    "existe cte's?
    IF lt_zttm_gkot010 IS NOT INITIAL.
      APPEND LINES OF lt_zttm_gkot010 TO gt_zttm_gkot010_save.
    ENDIF.

    "existe nf's?
    IF lt_zttm_gkot011 IS NOT INITIAL.
      APPEND LINES OF lt_zttm_gkot011 TO gt_zttm_gkot011_save.
    ENDIF.

  ENDMETHOD.


  METHOD save_data_reprocess.

    DATA lt_zttm_gkot010 TYPE ty_t_zttm_gkot010.
    DATA lt_zttm_gkot011 TYPE ty_t_zttm_gkot011.

    " Preenche os dados da fatura
    DATA(ls_zttm_gkot009) = VALUE zttm_gkot009( xblnr       = gs_invoice-invoice_number
                                                bldat       = gs_invoice-invoice_issue_date
                                                zfbdt       = gs_invoice-invoice_due_date
                                                stcd1       = gs_invoice-cnpj_issue
                                                newtr       = gs_invoice-invoice_value
                                                newdis      = gs_invoice-invoice_discount_value
                                                user_approv = gs_invoice-user_approval ).

    " Cte's usadas no agrupamento
    LOOP AT gs_invoice-cte ASSIGNING FIELD-SYMBOL(<fs_s_cte>).
      APPEND INITIAL LINE TO lt_zttm_gkot010 ASSIGNING FIELD-SYMBOL(<fs_s_zttm_gkot010>).
      <fs_s_zttm_gkot010>-xblnr  = gs_invoice-invoice_number.
      <fs_s_zttm_gkot010>-stcd1  = gs_invoice-cnpj_issue.
      <fs_s_zttm_gkot010>-bldat  = gs_invoice-invoice_issue_date.
      <fs_s_zttm_gkot010>-seqcte = sy-tabix.
      <fs_s_zttm_gkot010>-acckey = CONV #( <fs_s_cte> ).
    ENDLOOP.

    " NF's usadas no agrupamento
    LOOP AT gs_invoice-nfs ASSIGNING FIELD-SYMBOL(<fs_s_nfs>).
      APPEND INITIAL LINE TO lt_zttm_gkot011 ASSIGNING FIELD-SYMBOL(<fs_s_zttm_gkot011>).
      <fs_s_zttm_gkot011>-xblnr        = gs_invoice-invoice_number.
      <fs_s_zttm_gkot011>-stcd1        = gs_invoice-cnpj_issue.
      <fs_s_zttm_gkot011>-bldat        = gs_invoice-invoice_issue_date.
      <fs_s_zttm_gkot011>-seqnfs       = sy-tabix.
      <fs_s_zttm_gkot011>-docdat       = <fs_s_nfs>-issue_date.
      <fs_s_zttm_gkot011>-prefno       = <fs_s_nfs>-prefno.
      <fs_s_zttm_gkot011>-nfnum        = <fs_s_nfs>-nfnum.
      <fs_s_zttm_gkot011>-nfenum       = <fs_s_nfs>-nfenum.
      <fs_s_zttm_gkot011>-series       = <fs_s_nfs>-series.
      <fs_s_zttm_gkot011>-stcd1_transp = <fs_s_nfs>-stcd1_transp.
    ENDLOOP.

    " Gravar os dados
    MODIFY zttm_gkot009 FROM ls_zttm_gkot009.

    " Existe cte's?
    IF lt_zttm_gkot010 IS NOT INITIAL.
      MODIFY zttm_gkot010 FROM TABLE lt_zttm_gkot010.
    ENDIF.

    " Existe nf's?
    IF lt_zttm_gkot011 IS NOT INITIAL.
      MODIFY zttm_gkot011 FROM TABLE  lt_zttm_gkot011.
    ENDIF.

  ENDMETHOD.


  METHOD save_data_db.

    "gravar os dados
    IF gt_zttm_gkot009_save IS NOT INITIAL.
      MODIFY zttm_gkot009 FROM TABLE gt_zttm_gkot009_save.
    ENDIF.

    "existe cte's?
    IF gt_zttm_gkot010_save IS NOT INITIAL.
      MODIFY zttm_gkot010 FROM TABLE gt_zttm_gkot010_save.
    ENDIF.

    "existe nf's?
    IF gt_zttm_gkot011_save IS NOT INITIAL.
      MODIFY zttm_gkot011 FROM TABLE  gt_zttm_gkot011_save.
    ENDIF.

  ENDMETHOD.


  METHOD remove_data_reprocess.

    " Dados da fatura existe?
    SELECT COUNT( * )
      FROM zttm_gkot009
     WHERE xblnr EQ gs_invoice-invoice_number.

    IF sy-subrc IS NOT INITIAL.
      RAISE EXCEPTION TYPE zcxtm_gko_incoming_invoice
        EXPORTING
          textid   = zcxtm_gko_incoming_invoice=>gc_data_not_found_parameter
          gv_msgv1 = TEXT-t01.
    ENDIF.

    " Remover os dados de acordo com número da fatura, cnpj do emissor e data de emissão
    DELETE FROM zttm_gkot009 " Cabeçalho
          WHERE xblnr EQ gs_invoice-invoice_number
            AND stcd1 EQ gs_invoice-cnpj_issue
            AND bldat EQ gs_invoice-invoice_issue_date.

    DELETE FROM zttm_gkot010 " CTe's
          WHERE xblnr EQ gs_invoice-invoice_number
            AND stcd1 EQ gs_invoice-cnpj_issue
            AND bldat EQ gs_invoice-invoice_issue_date.

    DELETE FROM zttm_gkot011 " NFS's
          WHERE xblnr EQ gs_invoice-invoice_number
            AND stcd1 EQ gs_invoice-cnpj_issue
            AND bldat EQ gs_invoice-invoice_issue_date.

  ENDMETHOD.


  METHOD remove.

    ro_instance = me.
    TRY.
        " Remove as faturas para reprocessamento
        remove_data_reprocess( ).

      CATCH zcxtm_gko_incoming_invoice INTO DATA(lo_cx_incoming_invoice).
        LOOP AT gt_documents ASSIGNING FIELD-SYMBOL(<fs_s_documents>).
          IF <fs_s_documents>-objpr IS BOUND.
            <fs_s_documents>-objpr->free(  ).
          ENDIF.
        ENDLOOP.
        APPEND lo_cx_incoming_invoice TO gt_errors.
    ENDTRY.

  ENDMETHOD.


  METHOD recover_data_reprocess_multi.

    DATA lt_zttm_gkot009 TYPE ty_t_zttm_gkot009.
    DATA lt_zttm_gkot010 TYPE ty_t_zttm_gkot010.
    DATA lt_zttm_gkot011 TYPE ty_t_zttm_gkot011.

    " Dados da fatura
    SELECT *
      FROM zttm_gkot009
      INTO TABLE lt_zttm_gkot009
      FOR ALL ENTRIES IN gt_invoices_number
      WHERE xblnr EQ gt_invoices_number-xblnr
        AND stcd1 EQ gt_invoices_number-stcd1.

    IF sy-subrc IS NOT INITIAL.
      RAISE EXCEPTION TYPE zcxtm_gko_incoming_invoice
        EXPORTING
          textid   = zcxtm_gko_incoming_invoice=>gc_data_not_found_parameter
          gv_msgv1 = 'faturas'.
    ENDIF.

    " Cte's da fatura
    SELECT *
      FROM zttm_gkot010
      INTO CORRESPONDING FIELDS OF TABLE lt_zttm_gkot010
      FOR ALL ENTRIES IN gt_invoices_number
      WHERE xblnr EQ gt_invoices_number-xblnr
        AND stcd1 EQ gt_invoices_number-stcd1.

    " Nf's da fatura
    SELECT *
      FROM zttm_gkot011
      INTO CORRESPONDING FIELDS OF TABLE lt_zttm_gkot011
      FOR ALL ENTRIES IN gt_invoices_number
      WHERE xblnr EQ gt_invoices_number-xblnr
        AND stcd1 EQ gt_invoices_number-stcd1.


    LOOP AT lt_zttm_gkot009 ASSIGNING FIELD-SYMBOL(<fs_zttm_gkot009>).

      " Ddados do cabeçalho
      gs_invoice-invoice_number          = <fs_zttm_gkot009>-xblnr.
      gs_invoice-invoice_issue_date      = <fs_zttm_gkot009>-bldat.
      gs_invoice-invoice_due_date        = <fs_zttm_gkot009>-zfbdt.
      gs_invoice-cnpj_issue              = <fs_zttm_gkot009>-stcd1.
      gs_invoice-invoice_value           = <fs_zttm_gkot009>-newtr.
      gs_invoice-invoice_discount_value  = <fs_zttm_gkot009>-newdis.
      gs_invoice-user_approval           = <fs_zttm_gkot009>-user_approv.

      DATA(lt_gkot010_aux) = lt_zttm_gkot010.

      DELETE lt_gkot010_aux WHERE xblnr <> <fs_zttm_gkot009>-xblnr
                               OR stcd1 <> <fs_zttm_gkot009>-stcd1.

      IF lt_gkot010_aux IS NOT INITIAL.
        " Percorrendo tabela de cte's
        gs_invoice-cte = VALUE #( FOR ls_cte IN lt_gkot010_aux ( CONV zstm_gko_003( ls_cte-acckey ) ) ).
      ENDIF.

      DATA(lt_gkot011_aux) = lt_zttm_gkot011.

      DELETE lt_gkot011_aux WHERE xblnr <> <fs_zttm_gkot009>-xblnr
                               OR stcd1 <> <fs_zttm_gkot009>-stcd1.

      IF lt_zttm_gkot011 IS NOT INITIAL.
        " Monta a tabela de nfs's
        gs_invoice-nfs = CORRESPONDING #( lt_zttm_gkot011 MAPPING issue_date = docdat ).
      ENDIF.

      APPEND gs_invoice TO gt_invoices.

    ENDLOOP.

  ENDMETHOD.


  METHOD recover_data_reprocess.

    DATA ls_zttm_gkot009 TYPE zttm_gkot009.
    DATA lt_zttm_gkot010 TYPE ty_t_zttm_gkot010.
    DATA lt_zttm_gkot011 TYPE ty_t_zttm_gkot011.

    " Dados da fatura
    SELECT SINGLE *
      FROM zttm_gkot009
      INTO ls_zttm_gkot009
      WHERE xblnr EQ gs_invoice-invoice_number
        AND stcd1 EQ gs_invoice-cnpj_issue.

    IF sy-subrc IS NOT INITIAL.
      RAISE EXCEPTION TYPE zcxtm_gko_incoming_invoice
        EXPORTING
          textid   = zcxtm_gko_incoming_invoice=>gc_data_not_found_parameter
          gv_msgv1 = 'faturas'.
    ENDIF.

    " Dados do cabeçalho
    gs_invoice-invoice_number          = ls_zttm_gkot009-xblnr.
    gs_invoice-invoice_issue_date      = ls_zttm_gkot009-bldat.
    gs_invoice-invoice_due_date        = ls_zttm_gkot009-zfbdt.
    gs_invoice-cnpj_issue              = ls_zttm_gkot009-stcd1.
    gs_invoice-invoice_value           = ls_zttm_gkot009-newtr.
    gs_invoice-invoice_discount_value  = ls_zttm_gkot009-newdis.
    gs_invoice-user_approval           = ls_zttm_gkot009-user_approv.

    " Cte's da fatura
    SELECT *
      FROM zttm_gkot010
      INTO CORRESPONDING FIELDS OF TABLE lt_zttm_gkot010
      WHERE xblnr EQ gs_invoice-invoice_number
        AND stcd1 EQ gs_invoice-cnpj_issue.   "#EC CI_ALL_FIELDS_NEEDED

    IF sy-subrc IS INITIAL.

      " Percorrendo tabela de cte's
      gs_invoice-cte = VALUE #( FOR ls_cte IN lt_zttm_gkot010 ( CONV zstm_gko_003( ls_cte-acckey ) ) ).
    ENDIF.

    " Nf's da fatura
    SELECT *
      FROM zttm_gkot011
      INTO CORRESPONDING FIELDS OF TABLE lt_zttm_gkot011
      WHERE xblnr EQ gs_invoice-invoice_number
        AND stcd1 EQ gs_invoice-cnpj_issue.   "#EC CI_ALL_FIELDS_NEEDED

    IF sy-subrc IS INITIAL.
      " Monta a tabela de nfs's
      gs_invoice-nfs = CORRESPONDING #( lt_zttm_gkot011 MAPPING issue_date = docdat ).

      LOOP AT gs_invoice-nfs ASSIGNING FIELD-SYMBOL(<fs_invoice>).
        <fs_invoice>-series = |{ <fs_invoice>-series ALPHA = OUT }|.
      ENDLOOP.
    ENDIF.

  ENDMETHOD.


  METHOD invoice_update.

    DATA: lr_acckeys TYPE RANGE OF zttm_gkot001-acckey.

    DATA: lv_error           TYPE abap_bool,
          lv_last_num_fatura TYPE zttm_gkot001-num_fatura.

    " Busca as CTe's pela chave de acesso
    IF gs_invoice-cte IS NOT INITIAL.
      DATA(lt_acckeys) = CONV ty_t_cte( gs_invoice-cte ).

      lr_acckeys = VALUE #( FOR ls_acckey IN lt_acckeys ( option = 'EQ' sign = 'I' low = ls_acckey-acckey ) ).
    ENDIF.

    " Busca as NFS's pela chave de acesso
    IF gs_invoice-nfs IS NOT INITIAL.
      lr_acckeys = VALUE #( BASE lr_acckeys FOR ls_nfs IN gs_invoice-nfs ( option = 'CP'
                                                                           sign   = 'I'
                                                                           low    = |NFS{ ls_nfs-issue_date(4) }{ ls_nfs-issue_date+4(2) }{ ls_nfs-issue_date+6(2) }*{ ls_nfs-prefno }{ gs_invoice-cnpj_issue }*| ) ).
    ENDIF.

    CHECK lr_acckeys IS NOT INITIAL.

    SELECT acckey,
           num_fatura,
           codstatus
      FROM zttm_gkot001
      INTO TABLE @DATA(lt_gko_header)
      WHERE acckey IN @lr_acckeys.                   "#EC CI_SEL_NESTED

    CHECK sy-subrc IS INITIAL.
    SORT lt_gko_header BY num_fatura.

    DATA(lt_gko_header_aux) = lt_gko_header.
    DELETE lt_gko_header_aux WHERE num_fatura IS INITIAL.

    IF lt_gko_header_aux IS NOT INITIAL.
      SELECT acckey,
             num_fatura,
             emit_cnpj_cpf,
             codstatus
        FROM zttm_gkot001
        INTO TABLE @DATA(lt_faturas)
         FOR ALL ENTRIES IN @lt_gko_header_aux
       WHERE num_fatura    EQ @lt_gko_header_aux-num_fatura
         AND emit_cnpj_cpf EQ @gs_invoice-cnpj_issue.

      IF sy-subrc IS INITIAL.
        SORT lt_faturas BY num_fatura.
      ENDIF.

    ENDIF.

    LOOP AT lt_gko_header ASSIGNING FIELD-SYMBOL(<fs_s_gko_header>).

      " Possui fatura atribuida?
      IF <fs_s_gko_header>-num_fatura IS NOT INITIAL.

        LOOP AT lt_faturas ASSIGNING FIELD-SYMBOL(<fs_s_fatura>) WHERE num_fatura    EQ <fs_s_gko_header>-num_fatura
                                                                   AND emit_cnpj_cpf EQ gs_invoice-cnpj_issue.
          CLEAR lv_error.
          TRY.
              CASE <fs_s_fatura>-codstatus.
                WHEN zcltm_gko_process=>gc_codstatus-agrupamento_efetuado
                  OR zcltm_gko_process=>gc_codstatus-pagamento_efetuado.

                  RAISE EXCEPTION TYPE zcxtm_gko_incoming_invoice
                    EXPORTING
                      textid   = zcxtm_gko_incoming_invoice=>gc_invoice_not_to_update
                      gv_msgv1 = CONV msgv1( <fs_s_fatura>-num_fatura )
                      gv_msgv2 = COND msgv2( WHEN <fs_s_fatura>-codstatus EQ zcltm_gko_process=>gc_codstatus-agrupamento_efetuado THEN 'agrupamento efetuado'
                                             WHEN <fs_s_fatura>-codstatus EQ zcltm_gko_process=>gc_codstatus-pagamento_efetuado   THEN 'pagamento efetuado' ).

                WHEN OTHERS.

                  " Limpar dados da fatura no monitor
                  TRY.
                      DATA(lo_cl_gko_process) = NEW zcltm_gko_process( iv_acckey = <fs_s_fatura>-acckey ).

                      lo_cl_gko_process->set_invoice_data( EXPORTING iv_num_fatura = space
                                                                     iv_usr_lib    = space
                                                                     iv_vct_gko    = CONV #( space ) ).

                      lo_cl_gko_process->persist(  ).
                      lo_cl_gko_process->free(  ).
                    CATCH zcxtm_gko_process INTO DATA(lo_cx_gko_process).
                      APPEND lo_cx_gko_process TO gt_errors.
                      CONTINUE.
                  ENDTRY.

              ENDCASE.

            CATCH zcxtm_gko_incoming_invoice INTO DATA(lo_cx_incoming_invoice).

              IF lv_last_num_fatura NE <fs_s_fatura>-num_fatura.
                APPEND lo_cx_incoming_invoice TO gt_errors.
              ENDIF.

              lv_last_num_fatura = <fs_s_fatura>-num_fatura.
              lv_error = abap_true.
              CONTINUE.
          ENDTRY.

        ENDLOOP.

        " Remove da lista para não ser lido novamente
        DELETE lt_faturas WHERE num_fatura EQ <fs_s_gko_header>-num_fatura.
        CLEAR lv_last_num_fatura.
      ENDIF.

      CHECK lv_error IS INITIAL.
      WAIT UP TO 1 SECONDS.

      " Atualizar dados da fatura no monitor
      TRY.
          FREE: lo_cl_gko_process,
                lo_cx_gko_process.

          lo_cl_gko_process = NEW zcltm_gko_process( iv_acckey = <fs_s_gko_header>-acckey ).

          lo_cl_gko_process->set_invoice_data( EXPORTING iv_num_fatura = gs_invoice-invoice_number
                                                         iv_usr_lib    = gs_invoice-user_approval
                                                         iv_vct_gko    = gs_invoice-invoice_due_date ).

          lo_cl_gko_process->persist(  ).
          lo_cl_gko_process->free(  ).

        CATCH zcxtm_gko_process INTO lo_cx_gko_process.
          APPEND lo_cx_gko_process TO gt_errors.
          CONTINUE.
      ENDTRY.

    ENDLOOP.

*    " Confirma as modificações
*    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
*      EXPORTING
*        wait = abap_true.

  ENDMETHOD.


  METHOD invoice_grouping_multi.

    SORT gt_invoices BY invoice_number cnpj_issue.

    LOOP AT gt_documents ASSIGNING FIELD-SYMBOL(<fs_document>).

      READ TABLE gt_invoices TRANSPORTING NO FIELDS WITH KEY invoice_number = <fs_document>-num_fatura
                                                             cnpj_issue     = <fs_document>-emit_cnpj_cpf
                                                             BINARY SEARCH.

      CHECK sy-subrc IS INITIAL.

      LOOP AT gt_invoices ASSIGNING FIELD-SYMBOL(<fs_invoice>) FROM sy-tabix.

        IF <fs_invoice>-invoice_number <> <fs_document>-num_fatura.
          EXIT.
        ENDIF.

        WRITE: / | { TEXT-002 } { <fs_document>-num_fatura }|. "-- Iniciando o processamento da fatura

        IF line_exists( gt_bsis[ bukrs = <fs_document>-bukrs belnr = <fs_document>-belnr gjahr = <fs_document>-gjahr ] ).
          DATA(ls_bsis) = gt_bsis[ bukrs = <fs_document>-bukrs belnr = <fs_document>-belnr gjahr = <fs_document>-gjahr ].
        ENDIF.

        DATA(lv_name_vendor) = get_vendor_name( <fs_invoice>-cnpj_issue ).

        "Montando o cabeçalho do documento
        DATA(ls_header) = VALUE zclfi_gko_clearing=>ty_s_header_data( bukrs = <fs_document>-bukrs
                                                                     waers = gv_waers
                                                                     bldat = sy-datum
                                                                     budat = sy-datum
                                                                     blart = gv_blart
                                                                     bktxt = gv_txt_doc
                                                                     monat = sy-datum+4(2) "<fs_invoice>-invoice_issue_date+4(2)
                                                                     xblnr = <fs_invoice>-invoice_number ).
        DATA(lv_due_date) = get_due_date( ).
        IF <fs_invoice>-invoice_due_date > lv_due_date.
          lv_due_date = <fs_invoice>-invoice_due_date.
        ENDIF.

        "Montanto texto para o item
        gv_txt_itm = replace( val = gv_txt_itm sub = gc_replace_xblnr with = ls_header-xblnr ).
        gv_txt_itm = replace( val = gv_txt_itm sub = gc_replace_nomef with = lv_name_vendor ).

        "Montanto o texto para o item de desconto
        gv_txt_itm_dsc = replace( val = gv_txt_itm_dsc sub = gc_replace_xblnr with = ls_header-xblnr ).
        gv_txt_itm_dsc = replace( val = gv_txt_itm_dsc sub = gc_replace_nomef with = lv_name_vendor ).

        DATA(lv_tot_irrf) = REDUCE with_item-wt_qsshb( INIT lv_result = CONV with_item-wt_qsshb( '0' )
                                                       FOR <fs_s_with_item_red> IN gt_with_item
                                                       NEXT lv_result = lv_result + abs( <fs_s_with_item_red>-wt_qsshb ) ).

        "Monta o item do documento
        DATA(lt_item) = VALUE zclfi_gko_clearing=>ty_t_item_data( ( buzei = 001
                                                                     bschl = gv_key_clearing
                                                                     bupla = <fs_document>-bupla
                                                                     zlsch = space
                                                                     zlspr = space
                                                                     zterm = gv_payment_condition
                                                                     zfbdt = lv_due_date
                                                                     hkont = gv_lifnr
                                                                     wrbtr = <fs_invoice>-invoice_value - <fs_invoice>-invoice_discount_value - lv_tot_irrf
                                                                     sgtxt = gv_txt_itm
                                                                     ) ).
        "Há desconto para fatura?
        IF <fs_invoice>-invoice_discount_value IS NOT INITIAL.

          APPEND INITIAL LINE TO lt_item ASSIGNING FIELD-SYMBOL(<fs_s_item>).
          <fs_s_item>-buzei = 002.
          <fs_s_item>-bupla = <fs_document>-bupla.
          <fs_s_item>-bschl = gv_key_discount.
          <fs_s_item>-hkont = gv_account_discount.
          <fs_s_item>-wrbtr = <fs_invoice>-invoice_discount_value.
          <fs_s_item>-sgtxt = gv_txt_itm_dsc.

          <fs_s_item>-gsber = ls_bsis-gsber.
          <fs_s_item>-kostl = ls_bsis-kostl.
          <fs_s_item>-prctr = ls_bsis-prctr.

        ENDIF.

        "Documentos a serem compensados
        DATA(lt_documents) = VALUE zclfi_gko_clearing=>ty_t_documents( FOR ls_documents IN gt_documents (
                                                                            bukrs = <fs_document>-bukrs
                                                                            koart = 'K'
                                                                            belnr = ls_documents-belnr
                                                                            gjahr = ls_documents-gjahr
                                                                            buzei = ls_documents-buzei  ) ).
        "Transferência c/compensação
        DATA(lo_gko_clearing) = NEW zclfi_gko_clearing( 'UMBUCHNG' ).

        "Passando as informações para processamento
        lo_gko_clearing->set_header_data( ls_header ).
        lo_gko_clearing->set_item_data( lt_item ).
        lo_gko_clearing->set_documents( lt_documents ).

        WRITE: / |{ TEXT-003 }|. " --- Fatura processada

        DATA(lt_blntab) = lo_gko_clearing->clear_documents(  ).

        TRY.
            "Executar o processo de FB05
            save_document_multi( lt_blntab[ 1 ] ).
          CATCH cx_sy_itab_line_not_found.

        ENDTRY.

        "Salvar informações para reprocessamento
        save_data_reprocess_multi(  ).

      ENDLOOP.

    ENDLOOP.

    save_data_db(  ).

  ENDMETHOD.


  METHOD invoice_grouping.

    DATA: lt_return TYPE bapiret2_t,
          ls_textid TYPE scx_t100key.

    DATA(ls_document) = gt_documents[ 1 ].

    TRY.
        IF line_exists( gt_bsis[ bukrs = ls_document-bukrs belnr = ls_document-belnr gjahr = ls_document-gjahr ] ).
          DATA(ls_bsis) = gt_bsis[ bukrs = ls_document-bukrs belnr = ls_document-belnr gjahr = ls_document-gjahr ].
        ELSE.
          ls_bsis = gt_bsis[ 1 ].
        ENDIF.
      CATCH cx_root.
    ENDTRY.

    DATA(lv_name_vendor) = get_vendor_name( gs_invoice-cnpj_issue ).

    " Montando o cabeçalho do documento
    DATA(ls_header) = VALUE zclfi_gko_clearing=>ty_s_header_data( bukrs = ls_document-bukrs
                                                                 waers = gv_waers
                                                                 bldat = gs_invoice-invoice_issue_date
                                                                 budat = sy-datum "GS_invoice-invoice_issue_date
                                                                 blart = gv_blart
                                                                 bktxt = gv_txt_doc
                                                                 monat = sy-datum+4(2) "GS_invoice-invoice_issue_date+4(2)
                                                                 xblnr = gs_invoice-invoice_number ).
    DATA(lv_due_date) = get_due_date( ).
    IF gs_invoice-invoice_due_date > lv_due_date.
      lv_due_date = gs_invoice-invoice_due_date.
    ENDIF.

    "Montanto texto para o item
    gv_txt_itm = replace( val = gv_txt_itm sub = gc_replace_xblnr with = ls_header-xblnr ).
    gv_txt_itm = replace( val = gv_txt_itm sub = gc_replace_nomef with = lv_name_vendor ).

    "Montanto o texto para o item de desconto
    gv_txt_itm_dsc = replace( val = gv_txt_itm_dsc sub = gc_replace_xblnr with = ls_header-xblnr ).
    gv_txt_itm_dsc = replace( val = gv_txt_itm_dsc sub = gc_replace_nomef with = lv_name_vendor ).

    DATA(lv_tot_irrf) = REDUCE with_item-wt_qsshb( INIT lv_result = CONV with_item-wt_qsshb( '0' )
                                                   FOR <fs_s_with_item_red> IN gt_with_item
                                                   NEXT lv_result = lv_result + abs( <fs_s_with_item_red>-wt_qsshb ) ).

    "Monta o item do documento
    DATA(lt_item) = VALUE zclfi_gko_clearing=>ty_t_item_data( ( buzei = 001
                                                                 bschl = gv_key_clearing
                                                                 bupla = ls_document-bupla
                                                                 zlsch = space
                                                                 zlspr = space
                                                                 zterm = gv_payment_condition
                                                                 zfbdt = lv_due_date
                                                                 hkont = gv_lifnr
                                                                 wrbtr = gs_invoice-invoice_value - gs_invoice-invoice_discount_value - lv_tot_irrf
                                                                 sgtxt = gv_txt_itm ) ).

    "Há desconto para fatura?
    IF gs_invoice-invoice_discount_value IS NOT INITIAL.

      APPEND INITIAL LINE TO lt_item ASSIGNING FIELD-SYMBOL(<fs_s_item>).
      <fs_s_item>-buzei = 002.
      <fs_s_item>-bupla = ls_document-bupla.
      <fs_s_item>-bschl = gv_key_discount.
      <fs_s_item>-hkont = gv_account_discount.
      <fs_s_item>-wrbtr = gs_invoice-invoice_discount_value.
      <fs_s_item>-sgtxt = gv_txt_itm_dsc.

      LOOP AT gt_bsis ASSIGNING FIELD-SYMBOL(<fs_s_bsis>) WHERE prctr IS NOT INITIAL
                                                            AND kostl IS NOT INITIAL.
        EXIT.
      ENDLOOP.

      IF sy-subrc IS INITIAL.

        <fs_s_item>-gsber = <fs_s_bsis>-gsber.
        <fs_s_item>-kostl = <fs_s_bsis>-kostl.
        <fs_s_item>-prctr = <fs_s_bsis>-prctr.

      ENDIF.

    ENDIF.

    "Documentos a serem compensados
    DATA(lt_documents) = VALUE zclfi_gko_clearing=>ty_t_documents( FOR ls_documents IN gt_documents (
                                                                        bukrs = ls_document-bukrs
                                                                        koart = 'K'
                                                                        belnr = ls_documents-belnr
                                                                        gjahr = ls_documents-gjahr
                                                                        buzei = ls_documents-buzei  ) ).
    TRY.
        " Transferência c/compensação
        DATA(lo_gko_clearing) = NEW zclfi_gko_clearing( 'UMBUCHNG' ).

        " Passando as informações para processamento
        lo_gko_clearing->set_header_data( ls_header ).
        lo_gko_clearing->set_item_data( lt_item ).
        lo_gko_clearing->set_documents( lt_documents ).

        " Executar o processo de FB05
*        save_document( lo_gko_clearing->clear_documents(  ) ).
        DATA(lt_blntab) = lo_gko_clearing->clear_documents( IMPORTING et_return = lt_return ).
        IF line_exists( lt_return[ type = if_xo_const_message=>error ] ).

          CLEAR: ls_textid.

          DATA(ls_return) = lt_return[ type = if_xo_const_message=>error ].
          ls_textid-msgid = ls_return-id.
          ls_textid-msgno = ls_return-number.
          ls_textid-attr1 = ls_return-message_v1.
          ls_textid-attr2 = ls_return-message_v2.
          ls_textid-attr3 = ls_return-message_v3.
          ls_textid-attr4 = ls_return-message_v4.

          RAISE EXCEPTION TYPE zcxtm_gko_incoming_invoice
            EXPORTING
              textid = ls_textid.
        ELSE.
          save_document( it_blntab = lt_blntab ).
        ENDIF.

      CATCH zcxtm_gko_clearing INTO DATA(lo_cx_clearing).
        RAISE EXCEPTION TYPE zcxtm_gko_incoming_invoice
          EXPORTING
            gt_bapi_return = lo_cx_clearing->get_bapi_return( ).
    ENDTRY.

  ENDMETHOD.


  METHOD get_vendor_name.

*    TRY.
*        rv_name1 = gt_vendor[ stcd1 = iv_cnpj_issue ]-name1.
*
*      CATCH cx_sy_itab_line_not_found.
*
*    ENDTRY.

    SELECT SINGLE name1
      FROM lfa1
      INTO rv_name1
     WHERE stcd1 EQ iv_cnpj_issue.

  ENDMETHOD.


  METHOD get_status_description.

    DATA: lv_val_text TYPE val_text.

    CALL FUNCTION 'DOMAIN_VALUE_GET'
      EXPORTING
        i_domname  = 'ZE_GKO_CODSTATUS'
        i_domvalue = CONV domvalue_l( iv_status )
      IMPORTING
        e_ddtext   = lv_val_text
      EXCEPTIONS
        not_exist  = 1
        OTHERS     = 2.

    IF sy-subrc IS INITIAL.
      rv_description = lv_val_text.
    ENDIF.

  ENDMETHOD.


  METHOD get_errors.

    rt_errors = gt_errors.
    et_return = gt_return.

  ENDMETHOD.


  METHOD get_due_date.

    DATA lv_feadt TYPE rfpos-faedt.

    DATA lt_feadt TYPE TABLE OF rfpos-faedt.

    LOOP AT gt_documents ASSIGNING FIELD-SYMBOL(<fs_s_documents>).
      CALL FUNCTION 'NET_DUE_DATE_GET'
        EXPORTING
          i_zfbdt = <fs_s_documents>-zfbdt
          i_zbd1t = <fs_s_documents>-zbd1t
          i_zbd2t = <fs_s_documents>-zbd2t
          i_zbd3t = <fs_s_documents>-zbd3t
          i_shkzg = <fs_s_documents>-shkzg
          i_rebzg = <fs_s_documents>-rebzg
          i_koart = 'K'
        IMPORTING
          e_faedt = lv_feadt.

      APPEND INITIAL LINE TO lt_feadt ASSIGNING FIELD-SYMBOL(<fs_s_faedt>).
      <fs_s_faedt> = lv_feadt.
    ENDLOOP.

    SORT lt_feadt DESCENDING.
    rv_due_date = lt_feadt[ 1 ].

  ENDMETHOD.


  METHOD get_document_type.

    DATA(lo_param) = NEW zclca_tabela_parametros( ).

    TRY.
        lo_param->m_get_single( EXPORTING iv_modulo = 'FI-AP'
                                          iv_chave1 = 'AGRUPAMENTO'
                                          iv_chave2 = 'TIPODOC'
                                IMPORTING ev_param  = gv_blart ).

      CATCH zcxca_tabela_parametros.
    ENDTRY.


  ENDMETHOD.


  METHOD get_account_discount.

    DATA(lo_param) = NEW zclca_tabela_parametros( ).

    TRY.
        lo_param->m_get_single( EXPORTING iv_modulo = 'FI-AP'
                                          iv_chave1 = 'AGRUPAMENTO'
                                          iv_chave2 = 'CONTARAZAO'
                                IMPORTING ev_param  = gv_account_discount ).

      CATCH zcxca_tabela_parametros.
    ENDTRY.

  ENDMETHOD.


  METHOD find_documents_invoice_multi.

    APPEND LINES OF find_documents_by_nfs_multi( ) TO gt_documents.
    APPEND LINES OF find_documents_by_cte_multi( ) TO gt_documents.

    " Verifica se há registro duplicado
    DELETE ADJACENT DUPLICATES FROM gt_documents COMPARING docnum.

    " Está preenchida?
    IF gt_documents IS NOT INITIAL.

      select_vendor( ).

      get_account_discount( ).

      get_document_type( ).

      " Validando os valores
      validate_value( ).

      " Desbloqueia os documentos
      set_lock_documents( iv_block = space ).

      " Vazio?
    ELSE.

      RAISE EXCEPTION TYPE zcxtm_gko_incoming_invoice
        EXPORTING
          textid   = zcxtm_gko_incoming_invoice=>gc_data_not_found_parameter
          gv_msgv1 = 'CTe/NFe'.

    ENDIF.

  ENDMETHOD.


  METHOD find_documents_invoice.
    TRY.
        APPEND LINES OF find_documents_by_nfs( ) TO gt_documents.
      CATCH zcxtm_gko_incoming_invoice INTO DATA(lo_cx_incoming_invoice).
        APPEND lo_cx_incoming_invoice TO gt_errors.
    ENDTRY.
    TRY.
        APPEND LINES OF find_documents_by_cte( ) TO gt_documents.
      CATCH zcxtm_gko_incoming_invoice INTO lo_cx_incoming_invoice.
        APPEND lo_cx_incoming_invoice TO gt_errors.
    ENDTRY.

    " Verifica se há registro duplicado
    DELETE ADJACENT DUPLICATES FROM gt_documents COMPARING docnum.

    " Está preenchida?
    IF gt_documents IS NOT INITIAL.

      " Validando os valores
      validate_value( ).

      " Desbloqueia os documentos
      set_lock_documents( iv_block = space ).

      " Vazio?
    ELSE.
      RAISE EXCEPTION TYPE zcxtm_gko_incoming_invoice
        EXPORTING
          textid   = zcxtm_gko_incoming_invoice=>gc_data_not_found_parameter
          gv_msgv1 = 'CTe/NFe'.
    ENDIF.

  ENDMETHOD.


  METHOD find_documents_by_nfs_multi.

    TYPES: ty_numc9 TYPE n LENGTH 9,
           ty_numc3 TYPE n LENGTH 3.

    DATA: lt_documents TYPE ty_t_documents,
          lt_docs_ref  TYPE ty_t_doc_ref,
          lt_nfs       TYPE zctgtm_gko002.

    DATA lr_docref TYPE RANGE OF j_1bnfdoc-docref.

    LOOP AT gt_invoices ASSIGNING FIELD-SYMBOL(<fs_invoice>).

      " Monta o range para NFNUM
      CHECK <fs_invoice>-nfs IS NOT INITIAL.

      LOOP AT <fs_invoice>-nfs ASSIGNING FIELD-SYMBOL(<fs_s_nfs>).
        CASE strlen( <fs_s_nfs>-prefno ).
          WHEN 06.
            <fs_s_nfs>-nfnum = <fs_s_nfs>-prefno.
          WHEN OTHERS.
            <fs_s_nfs>-nfenum = CONV ty_numc9( <fs_s_nfs>-prefno ).

            IF NOT <fs_s_nfs>-series IS INITIAL.
              <fs_s_nfs>-series = CONV ty_numc3( <fs_s_nfs>-series ).
            ENDIF.
        ENDCASE.

        <fs_s_nfs>-prefno        = CONV zttm_gkot001-prefno( <fs_s_nfs>-prefno ).
        <fs_s_nfs>-emit_cnpj_cpf = CONV zttm_gkot001-emit_cnpj_cpf( <fs_s_nfs>-stcd1_transp ).

      ENDLOOP.

      APPEND LINES OF <fs_invoice>-nfs TO lt_nfs.

    ENDLOOP.

    " Busca os documentos atráves do NFNUM e SERIES
    IF lt_nfs IS NOT INITIAL.
      SELECT nf~docnum,
             nf~nfnum,
             nf~nfenum,
             nf~series,
             nf~bukrs,
             nf~branch AS bupla,
             nf~belnr,
             nf~gjahr,
             bsik~buzei,
             nf~parid,
             nf~docref,
             bsik~wrbtr,
             bsik~zfbdt,
             bsik~zbd1t,
             bsik~zbd2t,
             bsik~zbd3t,
             bsik~shkzg,
             bsik~rebzg,
             t001~acckey,
             t001~codstatus,
             t001~num_fatura,
             t001~emit_cnpj_cpf
        FROM j_1bnfdoc AS nf
       INNER JOIN lfa1 ON ( lfa1~lifnr = nf~parid )
       INNER JOIN bsik_view AS bsik ON ( nf~bukrs = bsik~bukrs
                                   AND nf~belnr = bsik~belnr
                                   AND nf~gjahr = bsik~gjahr )
       INNER JOIN zttm_gkot001 AS t001 ON ( nf~belnr = t001~re_belnr
                                      AND nf~gjahr = t001~re_gjahr )
         FOR ALL ENTRIES IN @lt_nfs
       WHERE nf~partyp  = @gc_partyp
         AND nf~nfnum   = @lt_nfs-nfnum
         AND nf~nfnum  <> 0
         AND nf~direct  = @gc_direct
         AND nf~cancel  = @space
         AND nf~subseq  = @space
         AND nf~nfesrv  = @abap_true
         AND lfa1~stcd1 = @lt_nfs-stcd1_transp
        INTO CORRESPONDING FIELDS OF TABLE @lt_documents.
    ENDIF.

    " Busca os documentos atráves do NFENUM e SERIES
    IF lt_nfs IS NOT INITIAL.
      SELECT nf~docnum,
             nf~nfnum,
             nf~nfenum,
             nf~series,
             nf~bukrs,
             nf~branch AS bupla,
             nf~belnr,
             nf~gjahr,
             bsik~buzei,
             nf~parid,
             nf~docref,
             bsik~wrbtr,
             bsik~zfbdt,
             bsik~zbd1t,
             bsik~zbd2t,
             bsik~zbd3t,
             bsik~shkzg,
             bsik~rebzg,
             t001~acckey,
             t001~codstatus,
             t001~num_fatura,
             t001~emit_cnpj_cpf
        FROM j_1bnfdoc AS nf
       INNER JOIN lfa1 ON ( lfa1~lifnr = nf~parid )
       INNER JOIN bsik_view AS bsik ON ( nf~bukrs = bsik~bukrs
                                   AND nf~belnr = bsik~belnr
                                   AND nf~gjahr = bsik~gjahr )
       INNER JOIN zttm_gkot001 AS t001 ON ( nf~belnr = t001~re_belnr
                                      AND nf~gjahr = t001~re_gjahr )
         FOR ALL ENTRIES IN @lt_nfs
       WHERE nf~partyp  = @gc_partyp
         AND nf~nfenum  = @lt_nfs-nfenum
         AND nf~nfenum <> @space
         AND nf~series  = @lt_nfs-series
         AND nf~direct  = @gc_direct
         AND nf~cancel  = @space
         AND nf~subseq  = @space
         AND nf~nfesrv  = @abap_true
         AND lfa1~stcd1 = @lt_nfs-stcd1_transp
         APPENDING CORRESPONDING FIELDS OF TABLE @lt_documents.
    ENDIF.

    " Busca a informação do cabeçalho GKO
    SELECT prefno,
           emit_cnpj_cpf,
           codstatus
      FROM zttm_gkot001
      INTO TABLE @DATA(lt_gko_header)
       FOR ALL ENTRIES IN @lt_nfs
     WHERE prefno        = @lt_nfs-prefno
       AND emit_cnpj_cpf = @lt_nfs-emit_cnpj_cpf.

    " Não encontrou documentos?
    IF lt_documents IS INITIAL.
      RETURN.
    ENDIF.

    IF lt_documents IS NOT INITIAL.

      " Seleciona os dados de custos dos documentos
      SELECT DISTINCT bukrs,
                      belnr,
                      gjahr,
                      buzei,
                      gsber,
                      kostl,
                      prctr
        FROM bsis_view
         FOR ALL ENTRIES IN @lt_documents
       WHERE bukrs EQ @lt_documents-bukrs
         AND belnr EQ @lt_documents-belnr
         AND gjahr EQ @lt_documents-gjahr
         AND prctr NE @space
        INTO TABLE @gt_bsis.

      IF sy-subrc IS INITIAL.
        SORT gt_bsis BY buzei ASCENDING.
      ENDIF.
    ENDIF.

    " Verifica se o documento tem alguma referência de cancelamento
    lr_docref = VALUE #( FOR ls_documents IN lt_documents FROM line_index( lt_documents[ docnum = ls_documents-docnum ] )
                                                          WHERE ( docref NE space ) ( sign = 'I' option = 'EQ' low = ls_documents-docref ) ).
    IF lr_docref IS NOT INITIAL.
      SELECT docnum
             docref
       FROM j_1bnfdoc
       INTO TABLE lt_docs_ref
      WHERE docref IN lr_docref.
    ENDIF.

    SORT lt_documents BY nfnum nfenum series.

    LOOP AT gt_invoices ASSIGNING <fs_invoice>.

      LOOP AT <fs_invoice>-nfs ASSIGNING <fs_s_nfs>.

        READ TABLE lt_documents TRANSPORTING NO FIELDS WITH KEY nfnum  = <fs_s_nfs>-nfnum
                                                                nfenum = <fs_s_nfs>-nfenum
                                                                series = <fs_s_nfs>-series BINARY SEARCH.

        CHECK sy-subrc IS INITIAL.

        LOOP AT lt_documents ASSIGNING FIELD-SYMBOL(<fs_s_document>) FROM sy-tabix.

          IF <fs_s_document>-nfnum  <> <fs_s_nfs>-nfnum   AND
             <fs_s_document>-nfenum <> <fs_s_nfs>-nfenum  AND
             <fs_s_document>-series <> <fs_s_nfs>-series.
            EXIT.
          ENDIF.

          " Verifica se existe nota de referencia de cancelamento
          IF lt_docs_ref IS NOT INITIAL.
            READ TABLE lt_docs_ref TRANSPORTING NO FIELDS WITH KEY docref = <fs_s_document>-docnum. "#EC CI_STDSEQ
            IF sy-subrc IS INITIAL.
              CONTINUE.
            ENDIF.
          ENDIF.

          APPEND INITIAL LINE TO rt_documents ASSIGNING FIELD-SYMBOL(<fs_s_documents>).
          MOVE-CORRESPONDING <fs_s_document> TO <fs_s_documents>.
        ENDLOOP.

        " Sucesso ao encontrar as notas?
        IF sy-subrc IS NOT INITIAL.

          READ TABLE lt_gko_header ASSIGNING FIELD-SYMBOL(<fs_s_gko_header>) WITH KEY prefno = <fs_s_nfs>-prefno. "#EC CI_STDSEQ
          IF sy-subrc IS INITIAL.
            DATA(lv_status) = to_lower( zclfi_gko_incoming_invoice=>get_status_description( <fs_s_gko_header>-codstatus ) ).
          ELSE.
            lv_status = TEXT-t02.
          ENDIF.

        ENDIF.
      ENDLOOP.
    ENDLOOP.

  ENDMETHOD.


  METHOD find_documents_by_nfs.

    TYPES: ty_numc9 TYPE n LENGTH 9,
           ty_numc3 TYPE n LENGTH 3.

    DATA: lt_documents TYPE ty_t_documents,
          lt_docs_ref  TYPE ty_t_doc_ref.

    DATA: lr_nfnum  TYPE RANGE OF j_1bnfdoc-nfnum,
          lr_nfenum TYPE RANGE OF j_1bnfdoc-nfenum,
          lr_series TYPE RANGE OF j_1bnfdoc-series,
          lr_docref TYPE RANGE OF j_1bnfdoc-docref.

    " Monta o range para NFNUM
    CHECK gs_invoice-nfs IS NOT INITIAL.

    LOOP AT gs_invoice-nfs ASSIGNING FIELD-SYMBOL(<fs_s_nfs>).

      " Para garantir que a busca será feita para os dois campos
      <fs_s_nfs>-nfnum         = <fs_s_nfs>-prefno.
      <fs_s_nfs>-nfenum        = CONV ty_numc9( <fs_s_nfs>-prefno ).
      <fs_s_nfs>-series        = COND #( WHEN <fs_s_nfs>-series IS INITIAL OR strlen( <fs_s_nfs>-series ) EQ 0
                                         THEN '000'
                                         ELSE <fs_s_nfs>-series ).

      <fs_s_nfs>-prefno        = CONV zttm_gkot001-prefno( <fs_s_nfs>-prefno ).
      <fs_s_nfs>-emit_cnpj_cpf = CONV zttm_gkot001-emit_cnpj_cpf( <fs_s_nfs>-stcd1_transp ).

    ENDLOOP.

    DATA(lt_nfnum)  = gs_invoice-nfs.
    DATA(lt_nfenum) = gs_invoice-nfs.
    DELETE lt_nfnum WHERE nfnum IS INITIAL.
    DELETE lt_nfenum WHERE nfenum IS INITIAL.

    " Busca os documentos atráves do NFNUM e SERIES
    IF lt_nfnum IS NOT INITIAL.
      SELECT docnum,
             nfnum,
             nfenum,
             series,
             bukrs,
             bupla,
             belnr,
             gjahr,
             buzei,
             parid,
             docref,
             wrbtr,
             zfbdt,
             zbd1t,
             zbd2t,
             zbd3t,
             shkzg,
             rebzg,
             acckey,
             codstatus,
             num_fatura,
             stcd1,
             re_belnr,
             re_gjahr,
             clear_belnr,
             clear_gjahr,
             clear_buzei
      FROM zi_tm_gko_doc_nfs
      FOR ALL ENTRIES IN @lt_nfnum
      WHERE partyp        = @gc_partyp
        AND nfnum         = @lt_nfnum-nfnum
        AND direct        = @gc_direct
        AND cancel        = @space
        AND subseq        = @space
        AND nfesrv        = @abap_true
        AND stcd1         = @lt_nfnum-stcd1_transp
      INTO CORRESPONDING FIELDS OF TABLE @lt_documents.
    ENDIF.

    " Busca os documentos atráves do NFENUM e SERIES
    IF lt_nfenum IS NOT INITIAL.

      SELECT docnum,
             nfnum,
             nfenum,
             series,
             bukrs,
             bupla,
             belnr,
             gjahr,
             buzei,
             parid,
             docref,
             wrbtr,
             zfbdt,
             zbd1t,
             zbd2t,
             zbd3t,
             shkzg,
             rebzg,
             acckey,
             codstatus,
             stcd1,
             re_belnr,
             re_gjahr,
             clear_belnr,
             clear_gjahr,
             clear_buzei
        FROM zi_tm_gko_doc_nfs
        FOR ALL ENTRIES IN @lt_nfenum
        WHERE ( partyp        = @gc_partyp              AND
                nfenum        = @lt_nfenum-nfenum       AND
                stcd1         = @lt_nfenum-stcd1_transp AND
                series        = @lt_nfenum-series       AND
                cancel        = @space                  AND
                subseq        = @space                  AND
                nfesrv        = @abap_true )
        APPENDING CORRESPONDING FIELDS OF TABLE @lt_documents.

    ENDIF.

    " Busca a informação do cabeçalho GKO
    SELECT acckey,
           num_fatura,
           nfnum9,
           prefno,
           emit_cnpj_cpf,
           codstatus
      FROM zttm_gkot001
      WHERE num_fatura    = @gs_invoice-invoice_number
        AND emit_cnpj_cpf = @gs_invoice-cnpj_issue
      INTO TABLE @DATA(lt_gko_header).

    " Não encontrou documentos?
    IF lt_documents IS INITIAL.

      " Processa as NFS's e lança o erro de acordo com o status
      LOOP AT gs_invoice-nfs ASSIGNING <fs_s_nfs>.
        TRY.

            READ TABLE lt_gko_header ASSIGNING FIELD-SYMBOL(<fs_s_gko_header>) WITH KEY nfnum9 = <fs_s_nfs>-prefno. "#EC CI_STDSEQ

            IF sy-subrc EQ 0.
              RAISE EXCEPTION TYPE zcxtm_gko_incoming_invoice
                EXPORTING
                  textid   = zcxtm_gko_incoming_invoice=>gc_nfs_invoice_not_found
                  gv_msgv1 = CONV msgv1( |{ <fs_s_nfs>-prefno }-{ <fs_s_nfs>-series }| )
                  gv_msgv2 = CONV msgv2( zcltm_gko_process=>get_status_description( <fs_s_gko_header>-codstatus ) ).
            ENDIF.

            READ TABLE lt_gko_header ASSIGNING <fs_s_gko_header> WITH KEY prefno = <fs_s_nfs>-prefno. "#EC CI_STDSEQ

            IF sy-subrc EQ 0.
              RAISE EXCEPTION TYPE zcxtm_gko_incoming_invoice
                EXPORTING
                  textid   = zcxtm_gko_incoming_invoice=>gc_nfs_invoice_not_found
                  gv_msgv1 = CONV msgv1( |{ <fs_s_nfs>-prefno }-{ <fs_s_nfs>-series }| )
                  gv_msgv2 = CONV msgv2( zcltm_gko_process=>get_status_description( <fs_s_gko_header>-codstatus ) ).
            ENDIF.

          CATCH zcxtm_gko INTO DATA(lo_cx_incoming_invoice).
            APPEND lo_cx_incoming_invoice TO gt_errors.
        ENDTRY.
      ENDLOOP.

      RETURN.

    ENDIF.

    IF lt_documents IS NOT INITIAL.

      " Seleciona os dados de custos dos documentos
      SELECT DISTINCT bukrs,
                      belnr,
                      gjahr,
                      buzei,
                      gsber,
                      kostl,
                      prctr
        FROM bsis_view
         FOR ALL ENTRIES IN @lt_documents
       WHERE bukrs EQ @lt_documents-bukrs
         AND belnr EQ @lt_documents-belnr
         AND gjahr EQ @lt_documents-gjahr
         AND prctr NE @space
        INTO TABLE @gt_bsis.

      IF sy-subrc IS INITIAL.
        SORT gt_bsis BY buzei ASCENDING.
      ENDIF.
    ENDIF.

    " Verifica se o documento tem alguma referência de cancelamento
    lr_docref = VALUE #( FOR ls_documents IN lt_documents FROM line_index( lt_documents[ docnum = ls_documents-docnum ] )
                                                          WHERE ( docref NE space ) ( sign = 'I' option = 'EQ' low = ls_documents-docref ) ).
    IF lr_docref IS NOT INITIAL.
      SELECT docnum
             docref
       FROM j_1bnfdoc
       INTO TABLE lt_docs_ref
      WHERE docref IN lr_docref.
    ENDIF.

    LOOP AT gs_invoice-nfs ASSIGNING <fs_s_nfs>.

      TRY.
*          IF <fs_s_nfs>-nfnum IS NOT INITIAL.
          lr_nfnum = VALUE #( ( option = 'EQ' sign = 'I' low = <fs_s_nfs>-nfnum ) ).
*          ELSE.
          lr_nfenum = VALUE #( ( option = 'EQ' sign = 'I' low = <fs_s_nfs>-nfenum ) ).
          lr_series = VALUE #( ( option = 'EQ' sign = 'I' low = <fs_s_nfs>-series ) ).
*          ENDIF.

          LOOP AT lt_documents ASSIGNING FIELD-SYMBOL(<fs_s_document>) WHERE ( nfnum  IN lr_nfnum OR nfenum IN lr_nfenum )
                                                                         AND series IN lr_series.

            " Verifica se existe nota de referencia de cancelamento
            IF lt_docs_ref IS NOT INITIAL.
              READ TABLE lt_docs_ref TRANSPORTING NO FIELDS WITH KEY docref = <fs_s_document>-docnum. "#EC CI_STDSEQ
              IF sy-subrc IS INITIAL.
                CONTINUE.
              ENDIF.
            ENDIF.

            TRY.
                DATA(lo_gko_process) = NEW zcltm_gko_process( iv_acckey = <fs_s_document>-acckey ).
                APPEND INITIAL LINE TO rt_documents ASSIGNING FIELD-SYMBOL(<fs_s_documents>).
                MOVE-CORRESPONDING <fs_s_document> TO <fs_s_documents>.
                <fs_s_documents>-objpr = lo_gko_process.
              CATCH zcxtm_gko_process INTO DATA(lo_cx_process).
                APPEND lo_cx_process TO gt_errors.
                CONTINUE.
            ENDTRY.
          ENDLOOP.

          " Sucesso ao encontrar as notas?
          IF sy-subrc IS NOT INITIAL.

            READ TABLE lt_gko_header ASSIGNING <fs_s_gko_header> WITH KEY prefno = <fs_s_nfs>-prefno. "#EC CI_STDSEQ
            IF sy-subrc IS INITIAL.
              DATA(lv_status) = to_lower( zclfi_gko_incoming_invoice=>get_status_description( <fs_s_gko_header>-codstatus ) ).
            ELSE.
              lv_status = TEXT-t02. "|não registrado no monitor|.
            ENDIF.

            RAISE EXCEPTION TYPE zcxtm_gko_incoming_invoice
              EXPORTING
                textid   = zcxtm_gko_incoming_invoice=>gc_nfs_invoice_not_found
                gv_msgv1 = CONV msgv1( |{ <fs_s_nfs>-nfnum }-{ <fs_s_nfs>-series }| )
                gv_msgv2 = CONV msgv2( lv_status ).

          ENDIF.

        CATCH zcxtm_gko_incoming_invoice INTO lo_cx_incoming_invoice.
          APPEND lo_cx_incoming_invoice TO gt_errors.
          CONTINUE.
      ENDTRY.

      IF NOT <fs_s_nfs>-series IS INITIAL AND
         NOT <fs_s_nfs>-nfenum IS INITIAL.
        <fs_s_nfs>-series = CONV ty_numc3( <fs_s_nfs>-series ).
      ENDIF.

    ENDLOOP.

  ENDMETHOD.


  METHOD find_documents_by_cte_multi.

    DATA lt_documents TYPE ty_t_documents.
    DATA lt_active TYPE ty_t_active.
    DATA lt_acckeys TYPE ty_t_cte.

    DATA lt_ctes TYPE zctgtm_gko001.

    " Busca as informações de documento com base nas CTE's
    LOOP AT gt_invoices  ASSIGNING FIELD-SYMBOL(<fs_invoice>).

      CHECK <fs_invoice>-cte IS NOT INITIAL.

      APPEND LINES OF <fs_invoice>-cte TO lt_ctes.

    ENDLOOP.

    SELECT cte~docnum,
           cte~nfnum,
           cte~bukrs,
           cte~branch AS bupla,
           cte~belnr,
           cte~gjahr,
           bsik~buzei,
           cte~parid,
           bsik~wrbtr,
           bsik~zfbdt,
           bsik~zbd1t,
           bsik~zbd2t,
           bsik~zbd3t,
           bsik~shkzg,
           bsik~rebzg,
           t001~acckey,
           t001~codstatus,
           t001~num_fatura
      FROM j_1bnfe_active AS active
     INNER JOIN j_1bnfdoc AS cte ON ( cte~docnum EQ active~docnum )
     INNER JOIN bsik_view AS bsik ON ( cte~bukrs EQ bsik~bukrs
                                 AND cte~belnr EQ bsik~belnr
                                 AND cte~gjahr EQ bsik~gjahr )
     INNER JOIN zttm_gkot001 AS t001 ON ( cte~belnr EQ t001~re_belnr
                                    AND cte~gjahr EQ t001~re_gjahr )
       FOR ALL ENTRIES IN @lt_ctes
     WHERE active~regio   EQ @lt_ctes-regio
       AND active~nfyear  EQ @lt_ctes-nfyear
       AND active~nfmonth EQ @lt_ctes-nfmonth
       AND active~stcd1   EQ @lt_ctes-stcd1
       AND active~model   EQ @lt_ctes-model
       AND active~serie   EQ @lt_ctes-serie
       AND active~nfnum9  EQ @lt_ctes-nfnum9
       AND active~docnum9 EQ @lt_ctes-docnum9
       AND active~cdv     EQ @lt_ctes-cdv
       AND active~cancel  EQ @space
      INTO CORRESPONDING FIELDS OF TABLE @lt_documents.

    " Busca a informação do cabeçalho GKO
    lt_acckeys = lt_ctes.

    SELECT acckey,
           codstatus
     FROM zttm_gkot001
     INTO TABLE @DATA(lt_gko_header)
      FOR ALL ENTRIES IN @lt_acckeys
    WHERE acckey EQ @lt_acckeys-acckey.

    IF lt_documents IS INITIAL.

      " Processa as CTe's e lança o erro de acordo com o status
      LOOP AT gs_invoice-cte ASSIGNING FIELD-SYMBOL(<fs_s_cte>).
        ASSIGN lt_gko_header[ acckey = <fs_s_cte> ] TO FIELD-SYMBOL(<fs_s_gko_header>).
        CHECK sy-subrc IS INITIAL.

      ENDLOOP.
    ENDIF.

    IF lt_documents IS NOT INITIAL.

      " Seleciona os dados de custos dos documentos
      SELECT DISTINCT bukrs,
                      belnr,
                      gjahr,
                      buzei,
                      gsber,
                      kostl,
                      prctr
       FROM bsis_view
        FOR ALL ENTRIES IN @lt_documents
      WHERE bukrs EQ @lt_documents-bukrs
        AND belnr EQ @lt_documents-belnr
        AND gjahr EQ @lt_documents-gjahr
        AND prctr NE @space
        APPENDING TABLE @gt_bsis.

    ENDIF.

    SORT gt_bsis BY buzei ASCENDING.

    LOOP AT gt_invoices ASSIGNING <fs_invoice>.

      LOOP AT <fs_invoice>-cte ASSIGNING <fs_s_cte>.

        ASSIGN lt_documents[ acckey = <fs_s_cte> ] TO FIELD-SYMBOL(<fs_s_document>).

        IF sy-subrc IS NOT INITIAL.

          ASSIGN lt_gko_header[ acckey = <fs_s_cte> ] TO <fs_s_gko_header>.
          IF sy-subrc IS INITIAL.
            DATA(lv_status) = to_lower( zclfi_gko_incoming_invoice=>get_status_description( <fs_s_gko_header>-codstatus ) ).
          ELSE.
            lv_status = TEXT-t02.
          ENDIF.

        ENDIF.

        APPEND INITIAL LINE TO rt_documents ASSIGNING FIELD-SYMBOL(<fs_s_documents>).
        MOVE-CORRESPONDING <fs_s_document> TO <fs_s_documents>.

      ENDLOOP.

    ENDLOOP.

  ENDMETHOD.


  METHOD find_documents_by_cte.

    DATA lt_documents TYPE ty_t_documents.
    DATA lt_active TYPE ty_t_active.
    DATA lt_acckeys TYPE ty_t_cte.

    "Busca as informações de documento com base nas CTE's
    CHECK gs_invoice-cte IS NOT INITIAL.

*    SELECT cte~docnum,
*           cte~nfnum,
*           cte~bukrs,
*           cte~branch AS bupla,
*           cte~belnr,
*           cte~gjahr,
*           bsik~buzei,
*           cte~parid,
*           bsik~wrbtr,
*           bsik~zfbdt,
*           bsik~zbd1t,
*           bsik~zbd2t,
*           bsik~zbd3t,
*           bsik~shkzg,
*           bsik~rebzg,
*           t001~acckey,
*           t001~codstatus,
*           t001~num_fatura
*      FROM j_1bnfe_active AS active
*      INNER JOIN j_1bnfdoc AS cte ON ( cte~docnum EQ active~docnum )
*      LEFT OUTER JOIN bsik_view AS bsik ON ( cte~bukrs EQ bsik~bukrs
*                                        AND  cte~belnr EQ bsik~belnr
*                                        AND  cte~gjahr EQ bsik~gjahr )
*      INNER JOIN zttm_gkot001 AS t001 ON ( cte~belnr EQ t001~re_belnr
*                                     AND  cte~gjahr EQ t001~re_gjahr )
*        FOR ALL ENTRIES IN @gs_invoice-cte
*      WHERE active~regio   EQ @gs_invoice-cte-regio
*        AND active~nfyear  EQ @gs_invoice-cte-nfyear
*        AND active~nfmonth EQ @gs_invoice-cte-nfmonth
*        AND active~stcd1   EQ @gs_invoice-cte-stcd1
*        AND active~model   EQ @gs_invoice-cte-model
*        AND active~serie   EQ @gs_invoice-cte-serie
*        AND active~nfnum9  EQ @gs_invoice-cte-nfnum9
*        AND active~docnum9 EQ @gs_invoice-cte-docnum9
*        AND active~cdv     EQ @gs_invoice-cte-cdv
*        AND active~cancel  EQ @space
*       INTO CORRESPONDING FIELDS OF TABLE @lt_documents.

    DATA(lt_acckey) = VALUE zctgtm_acckey( FOR ls_cte IN gs_invoice-cte ( CONV #( ls_cte ) ) ).

    IF lt_acckey IS NOT INITIAL.

      SELECT *
          FROM zi_tm_gko_doc_cte
          FOR ALL ENTRIES IN @lt_acckey
          WHERE acckey  EQ @lt_acckey-table_line
            AND cancel  EQ @space
          INTO CORRESPONDING FIELDS OF TABLE @lt_documents.
    ENDIF.

    " Busca a informação do cabeçalho GKO
    lt_acckeys = gs_invoice-cte.
    SELECT acckey,
           codstatus
     FROM zttm_gkot001
     INTO TABLE @DATA(lt_gko_header)
      FOR ALL ENTRIES IN @lt_acckeys
    WHERE acckey EQ @lt_acckeys-acckey.

    IF lt_documents IS INITIAL.

      " Processa as CTe's e lança o erro de acordo com o status
      LOOP AT gs_invoice-cte ASSIGNING FIELD-SYMBOL(<fs_s_cte>).

        TRY.

            ASSIGN lt_gko_header[ acckey = <fs_s_cte> ] TO FIELD-SYMBOL(<fs_s_gko_header>).
            CHECK sy-subrc IS INITIAL.

            RAISE EXCEPTION TYPE zcxtm_gko_incoming_invoice
              EXPORTING
                textid   = zcxtm_gko_incoming_invoice=>gc_cte_invoice_not_found
                gv_msgv1 = CONV msgv1( <fs_s_gko_header>-acckey )
                gv_msgv2 = CONV msgv2( zcltm_gko_process=>get_status_description( <fs_s_gko_header>-codstatus ) ).

          CATCH zcxtm_gko INTO DATA(lo_cx_incoming_invoice).
            APPEND lo_cx_incoming_invoice TO gt_errors.
        ENDTRY.
      ENDLOOP.

    ENDIF.

    IF lt_documents IS NOT INITIAL.

      " Seleciona os dados de custos dos documentos
      SELECT DISTINCT bukrs,
                      belnr,
                      gjahr,
                      buzei,
                      gsber,
                      kostl,
                      prctr
        FROM bsis_view
         FOR ALL ENTRIES IN @lt_documents
       WHERE bukrs EQ @lt_documents-bukrs
         AND belnr EQ @lt_documents-belnr
         AND gjahr EQ @lt_documents-gjahr
         AND prctr NE @space
         APPENDING TABLE @gt_bsis.

      IF sy-subrc IS INITIAL.
        SORT gt_bsis BY buzei ASCENDING.
      ENDIF.
    ENDIF.

    LOOP AT gs_invoice-cte ASSIGNING <fs_s_cte>.
      TRY.
          ASSIGN lt_documents[ acckey = <fs_s_cte> ] TO FIELD-SYMBOL(<fs_s_document>).
          IF sy-subrc IS NOT INITIAL.

            ASSIGN lt_gko_header[ acckey = <fs_s_cte> ] TO <fs_s_gko_header>.
            IF sy-subrc IS INITIAL.
              DATA(lv_status) = to_lower( zclfi_gko_incoming_invoice=>get_status_description( <fs_s_gko_header>-codstatus ) ).
            ELSE.
              lv_status = TEXT-t02.
            ENDIF.

            RAISE EXCEPTION TYPE zcxtm_gko_incoming_invoice
              EXPORTING
                textid   = zcxtm_gko_incoming_invoice=>gc_cte_invoice_not_found
                gv_msgv1 = CONV msgv1( <fs_s_cte> )
                gv_msgv2 = CONV msgv2( lv_status ).
          ENDIF.

          DATA(lo_gko_process) = NEW zcltm_gko_process( iv_acckey = <fs_s_document>-acckey ).
          APPEND INITIAL LINE TO rt_documents ASSIGNING FIELD-SYMBOL(<fs_s_documents>).
          MOVE-CORRESPONDING <fs_s_document> TO <fs_s_documents>.
          <fs_s_documents>-objpr = lo_gko_process.

        CATCH zcxtm_gko INTO lo_cx_incoming_invoice.
          APPEND lo_cx_incoming_invoice TO gt_errors.
      ENDTRY.
    ENDLOOP.

  ENDMETHOD.


  METHOD check_params.

    " Moeda está configurada?
    SELECT SINGLE parametro
      FROM zttm_pcockpit001
      INTO gv_waers
     WHERE id EQ zcltm_gko_process=>gc_params-moeda.

    IF sy-subrc IS NOT INITIAL.
      RAISE EXCEPTION TYPE zcxtm_gko_incoming_invoice
        EXPORTING
          textid   = zcxtm_gko_incoming_invoice=>gc_parameter_not_registered
          gv_msgv1 = CONV msgv1( 'Moeda' ).
    ENDIF.

    " Tipo do documento de fatura configurado?
    SELECT SINGLE parametro
      FROM zttm_pcockpit001
      INTO gv_blart
     WHERE id EQ zcltm_gko_process=>gc_params-tipo_documento_fatura.

    IF sy-subrc IS NOT INITIAL.
      RAISE EXCEPTION TYPE zcxtm_gko_incoming_invoice
        EXPORTING
          textid   = zcxtm_gko_incoming_invoice=>gc_parameter_not_registered
          gv_msgv1 = CONV msgv1( 'Tipo do documento da fatura' ).
    ENDIF.

    " Texto de cabeçalho de documento da fatura configurado?
    IF gv_tpprocess = zcltm_gko_process=>gc_tpprocess-manual.

      SELECT SINGLE parametro
        FROM zttm_pcockpit001
        INTO gv_txt_doc
        WHERE id EQ zcltm_gko_process=>gc_params-texto_cab_document_fatura_m.

    ELSE.

      SELECT SINGLE parametro
        FROM zttm_pcockpit001
        INTO gv_txt_doc
        WHERE id EQ zcltm_gko_process=>gc_params-texto_cab_document_fatura.

    ENDIF.

    IF sy-subrc IS NOT INITIAL.
      RAISE EXCEPTION TYPE zcxtm_gko_incoming_invoice
        EXPORTING
          textid   = zcxtm_gko_incoming_invoice=>gc_parameter_not_registered
          gv_msgv1 = CONV msgv1( 'Texto de cabeçalho de documento da fatura' ).
    ENDIF.

    " Condição de pagamento da fatura configurado?
    SELECT SINGLE parametro
      FROM zttm_pcockpit001
      INTO gv_payment_condition
     WHERE id EQ zcltm_gko_process=>gc_params-condicao_pagamento_fatura.

    IF sy-subrc IS NOT INITIAL.
      RAISE EXCEPTION TYPE zcxtm_gko_incoming_invoice
        EXPORTING
          textid   = zcxtm_gko_incoming_invoice=>gc_parameter_not_registered
          gv_msgv1 = CONV msgv1( 'Condição de pagamento da fatura' ).
    ENDIF.

    " Texto do item da fatura configurado?
    SELECT SINGLE parametro
      FROM zttm_pcockpit001
      INTO gv_txt_itm
     WHERE id EQ zcltm_gko_process=>gc_params-texto_item_fatura.

    IF sy-subrc IS NOT INITIAL.
      RAISE EXCEPTION TYPE zcxtm_gko_incoming_invoice
        EXPORTING
          textid   = zcxtm_gko_incoming_invoice=>gc_parameter_not_registered
          gv_msgv1 = CONV msgv1( 'Texto do item da fatura' ).
    ENDIF.

    " Chave de lançamento da compensação configurado?
    SELECT SINGLE parametro
      FROM zttm_pcockpit001
      INTO gv_key_clearing
     WHERE id EQ zcltm_gko_process=>gc_params-chave_lancamento.

    IF sy-subrc IS NOT INITIAL.
      RAISE EXCEPTION TYPE zcxtm_gko_incoming_invoice
        EXPORTING
          textid   = zcxtm_gko_incoming_invoice=>gc_parameter_not_registered
          gv_msgv1 = CONV msgv1( 'Chave de lançamento da compensação' ).
    ENDIF.

    " Texto do item de desconto da fatura configurado?
    SELECT SINGLE parametro
      FROM zttm_pcockpit001
      INTO gv_txt_itm_dsc
     WHERE id EQ zcltm_gko_process=>gc_params-texto_item_desconto_fatura.

    IF sy-subrc IS NOT INITIAL.
      RAISE EXCEPTION TYPE zcxtm_gko_incoming_invoice
        EXPORTING
          textid   = zcxtm_gko_incoming_invoice=>gc_parameter_not_registered
          gv_msgv1 = CONV msgv1( 'Texto do item de desconto da fatura' ).
    ENDIF.

    " Chave de lançamento do desconto configurado?
    SELECT SINGLE parametro
      FROM zttm_pcockpit001
      INTO gv_key_discount
     WHERE id EQ zcltm_gko_process=>gc_params-chave_desconto.

    IF sy-subrc IS NOT INITIAL.
      RAISE EXCEPTION TYPE zcxtm_gko_incoming_invoice
        EXPORTING
          textid   = zcxtm_gko_incoming_invoice=>gc_parameter_not_registered
          gv_msgv1 = CONV msgv1( 'Chave de lançamento do desconto' ).
    ENDIF.

    " Conta de desconto da fatura configurado?
    SELECT SINGLE parametro
      FROM zttm_pcockpit001
      INTO gv_account_discount
     WHERE id EQ zcltm_gko_process=>gc_params-conta_desconto_fatura.

    IF sy-subrc IS NOT INITIAL.
      RAISE EXCEPTION TYPE zcxtm_gko_incoming_invoice
        EXPORTING
          textid   = zcxtm_gko_incoming_invoice=>gc_parameter_not_registered
          gv_msgv1 = CONV msgv1( 'Conta de desconto da fatura' ).
    ENDIF.

  ENDMETHOD.


  METHOD check_inputs.

    " Verifica se o CNPJ existe na base
    SELECT SINGLE lifnr
      FROM lfa1
      INTO gv_lifnr
     WHERE stcd1 EQ gs_invoice-cnpj_issue.

    IF sy-subrc IS NOT INITIAL.
      RAISE EXCEPTION TYPE zcxtm_gko_incoming_invoice
        EXPORTING
          textid   = zcxtm_gko_incoming_invoice=>gc_vendor_not_found
          gv_msgv1 = CONV msgv1( gs_invoice-cnpj_issue ).
    ENDIF.

  ENDMETHOD.


  METHOD check.

    " Verifica os campos da interface
    check_inputs(  ).

    " Verifica as parametrizações
    check_params(  ).

  ENDMETHOD.


  METHOD check_status.

    FREE: et_return.

    " Busca a informação do cabeçalho GKO
    SELECT acckey,
           num_fatura,
           nfnum9,
           prefno,
           emit_cnpj_cpf,
           codstatus,
           belnr
      FROM zttm_gkot001
      WHERE num_fatura    = @gs_invoice-invoice_number
        AND emit_cnpj_cpf = @gs_invoice-cnpj_issue
      INTO TABLE @DATA(lt_header).

    IF sy-subrc NE 0.
      RETURN.
    ENDIF.

    IF line_exists( lt_header[ codstatus = zcltm_gko_process=>gc_codstatus-agrupamento_efetuado ] )
    OR line_exists( lt_header[ codstatus = zcltm_gko_process=>gc_codstatus-aguardando_reagrupamento ] )
    OR line_exists( lt_header[ codstatus = zcltm_gko_process=>gc_codstatus-aguardando_aprovacao_wf ] ).

      " Valida se número de documento financeiro já foi criado
      LOOP AT lt_header REFERENCE INTO DATA(ls_header).

        IF ls_header->belnr IS NOT INITIAL.
          " Numero de Fatura &1 já possui agrupamento.
          et_return = VALUE #( BASE et_return ( type = 'E' id = 'ZTM_GKO' number = '143' message_v1 = gs_invoice-invoice_number ) ).
          RETURN.
        ENDIF.

      ENDLOOP.

    ELSE.

      LOOP AT lt_header REFERENCE INTO ls_header.
        IF  ls_header->codstatus NE zcltm_gko_process=>gc_codstatus-miro_confirmada
        AND ls_header->codstatus NE zcltm_gko_process=>gc_codstatus-erro_agrupamento_manual     " INSERT - JWSILVA - 04.04.2023
        AND ls_header->codstatus NE zcltm_gko_process=>gc_codstatus-erro_agrupamento.           " INSERT - JWSILVA - 04.04.2023
          " Chave de acesso &1 não possui o status correto para agrupamento.
          et_return = VALUE #( BASE et_return ( type = 'E' id = 'ZTM_GKO' number = '146' message_v1 = ls_header->acckey ) ).
        ENDIF.
      ENDLOOP.

    ENDIF.

  ENDMETHOD.


  METHOD process_fat_to_agrup.

    DATA: lt_faturas TYPE zctgtm_gko009v2.

    SELECT
      t001~acckey,
      t001~codstatus,
      t001~num_fatura,
      t001~emit_cnpj_cpf
    FROM zttm_gkot009 AS t009
    INNER JOIN zttm_gkot001 AS t001
    ON t009~xblnr EQ t001~num_fatura
    INTO TABLE @DATA(lt_gko_header)
    WHERE codstatus  = @zclfi_gko_incoming_invoice=>gc_codstatus-aguardando_reagrupamento.

    IF sy-subrc = 0.
      lt_faturas = VALUE #( FOR ls_header IN lt_gko_header ( xblnr = ls_header-num_fatura
                                                             stcd1 = ls_header-emit_cnpj_cpf ) ).

      set_invoice_multi( it_invoices_number = lt_faturas ).
      start_multi( ).
    ENDIF.

  ENDMETHOD.


  METHOD setup_messages.

    CASE p_task.
      WHEN 'TM_DOCUMENT_CHANGE'.
        RECEIVE RESULTS FROM FUNCTION 'ZFMTM_GKO_DOCUMENT_CHANGE'
         IMPORTING
           ev_subrc  = gv_subrc
           es_return = gs_return.

        gv_wait_async = abap_true.

      WHEN OTHERS.
    ENDCASE.

  ENDMETHOD.
ENDCLASS.
