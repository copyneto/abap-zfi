"!<p><strong>Autor:</strong>Thiago da Graça</p>
"!<p><strong>Data:</strong>30 de dezembro 2021</p>
"!<p><strong>Descrição:</strong>Classe para manipular os dados de contabilização</p>
CLASS zclfi_exec_contabilizacao DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    TYPES:
      ty_t_header TYPE TABLE OF zi_fi_contab_cab  WITH DEFAULT KEY,
      ty_t_item   TYPE TABLE OF zi_fi_contab_item WITH DEFAULT KEY,
      ty_ext      TYPE STANDARD TABLE OF bapiparex WITH DEFAULT KEY,
      ty_t_log    TYPE STANDARD TABLE OF ztfi_log_contab WITH DEFAULT KEY.

    DATA: gt_return     TYPE bapiret2_tab,
          gt_extension2 TYPE ty_ext.

    "! Metodo construtor para inicializar a classe
    "! @parameter it_header | Tabela com os dados de cabeçalho
    "! @parameter it_item   | Tabela com os dados de itens
    METHODS constructor
      IMPORTING
        it_header TYPE ty_t_header OPTIONAL
        it_item   TYPE ty_t_item   OPTIONAL.

    "! Preenche estrutura da BAPI
    "! @parameter iv_simular       | Simular?
    METHODS execute_bapi
      IMPORTING
        iv_simular TYPE abap_bool OPTIONAL.
*      RETURNING
*        VALUE(gt_mensagens) TYPE bapiret2_tab.


    "! Salva dados processados na tabela de log
    "! @parameter iv_delete | Eliminar?
    METHODS save_log
      IMPORTING
        is_header           TYPE zi_fi_contab_cab OPTIONAL
        iv_delete           TYPE abap_bool OPTIONAL
        iv_erro             TYPE abap_bool OPTIONAL
      EXPORTING
        et_return           TYPE bapiret2_tab
      RETURNING
        VALUE(rt_mensagens) TYPE bapiret2_tab.

    METHODS update_status_to_process
      IMPORTING
        iv_simular TYPE abap_bool OPTIONAL.

    METHODS delete_contab_data
      IMPORTING
        is_header TYPE zi_fi_contab_cab.

    METHODS:
      "! Adiciona mensagens
      "! @parameter io_context |Objeto com o conteudo
      "! @parameter it_return  |Tabela com as mensagens
      "! @parameter ro_message_container | Retorna objeto preecnhido
      add_message_to_container
        IMPORTING
          io_context                  TYPE REF TO /iwbep/if_mgw_context
          it_return                   TYPE bapiret2_t OPTIONAL
        RETURNING
          VALUE(ro_message_container) TYPE REF TO /iwbep/if_message_container .

    METHODS:
      "! Preenche mensagens
      "! @parameter rv_message |Retorna mensagens
      fill_message
        RETURNING
          VALUE(rv_message) TYPE bapi_msg .

    METHODS: task_finish
      IMPORTING
        !p_task TYPE clike.

  PROTECTED SECTION.
  PRIVATE SECTION.

    DATA gt_header         TYPE ty_t_header .
    DATA gt_item           TYPE ty_t_item.
    DATA gs_documentheader TYPE bapiache09.
    DATA gt_accountgl      TYPE bapiacgl09_tab.
    DATA gt_currencyamount TYPE bapiaccr09_tab.
    DATA gt_mensagens      TYPE bapiret2_tab.
    "! Verifica se BAPI esta com erros
    METHODS check_bapi.
*      CHANGING
*        ct_mensagens TYPE bapiret2_tab.


    "! Executa BAPI_ACC_DOCUMENT_POST
    METHODS process_bapi.

    "! Preencher tabela da Extension
    METHODS data_fill_ext
      IMPORTING
        is_cab           TYPE zi_fi_contab_cab
        is_item          TYPE zi_fi_contab_item
      RETURNING
        VALUE(rt_result) TYPE ty_ext.


    METHODS:
      get_div_centro_lucro
        IMPORTING
          iv_centro_custo TYPE kostl
        EXPORTING
          ev_divisao      TYPE gsber
          ev_centro_lucro TYPE prctr
          ev_segmento     TYPE fb_segment.
ENDCLASS.



CLASS zclfi_exec_contabilizacao IMPLEMENTATION.


  METHOD constructor.
    gt_header = it_header.
    gt_item   = it_item.
  ENDMETHOD.


  METHOD execute_bapi.

    DATA: ls_accountgl      TYPE bapiacgl09,
          ls_currencyamount TYPE bapiaccr09.

    LOOP AT gt_header ASSIGNING FIELD-SYMBOL(<fs_header>).

*      DATA(ls_header) = VALUE #( gt_header[ id = iv_id Identificacao = iv_identificacao ] OPTIONAL ).

      gs_documentheader-username   = sy-uname.
      gs_documentheader-comp_code  = <fs_header>-Empresa.
      gs_documentheader-doc_date   = <fs_header>-DataDocumento.
      gs_documentheader-pstng_date = <fs_header>-DataLancamento.
      gs_documentheader-doc_type   = <fs_header>-TipoDocumento.
      gs_documentheader-ref_doc_no = <fs_header>-Referencia.
      gs_documentheader-header_txt = <fs_header>-TextCab.

      IF sy-subrc = 0.

        REFRESH: gt_accountgl, gt_currencyamount, gt_extension2.", gt_mensagens.

        LOOP AT gt_item ASSIGNING FIELD-SYMBOL(<fs_item>) WHERE id            = <fs_header>-id
                                                          AND   identificacao = <fs_header>-Identificacao. "#EC CI_STDSEQ
          TRANSLATE <fs_item>-DebCred TO UPPER CASE.

          ls_accountgl-itemno_acc = <fs_item>-Item.
*        ls_accountgl-stat_con   = <fs_item>-DebCred.
          ls_accountgl-alloc_nmbr = <fs_item>-Atribuicao.
          ls_accountgl-gl_account = <fs_item>-Conta.

*          IF <fs_item>-Conta(1) NE 1 AND
*             <fs_item>-Conta(1) NE 2.
          IF <fs_item>-Conta(1) NE 4 and <fs_item>-Conta(1) NE 3.

            me->get_div_centro_lucro( EXPORTING iv_centro_custo = <fs_item>-CentroCusto
                                      IMPORTING ev_centro_lucro = ls_accountgl-profit_ctr
                                                ev_divisao      = ls_accountgl-bus_area
                                                ev_segmento     = ls_accountgl-segment ).

            CLEAR <fs_item>-CentroCusto.

          ELSE.
            ls_accountgl-costcenter = <fs_item>-CentroCusto.
            ls_accountgl-profit_ctr = <fs_item>-CentroLucro.
            ls_accountgl-bus_area   = <fs_item>-Divisao.
            ls_accountgl-segment    = <fs_item>-Segmento.
          ENDIF.

          ls_accountgl-item_text  = <fs_item>-TextoItem.

          APPEND ls_accountgl TO gt_accountgl.

          CLEAR ls_accountgl.

          ls_currencyamount-itemno_acc = <fs_item>-Item.

          IF <fs_item>-DebCred = 'H'.
            ls_currencyamount-amt_doccur = |-{ <fs_item>-Valor }|.
          ELSE.
            ls_currencyamount-amt_doccur = <fs_item>-Valor.
          ENDIF.
*        ls_currencyamount-amt_doccur = <fs_item>-Valor.
          ls_currencyamount-currency   = <fs_item>-Moeda.

          APPEND ls_currencyamount TO gt_currencyamount.

          IF gt_extension2 IS INITIAL.

            gt_extension2 = me->data_fill_ext( EXPORTING is_cab  = <fs_header>
                                                         is_item = <fs_item> ).

          ENDIF.

        ENDLOOP.

        IF iv_simular IS SUPPLIED AND iv_simular IS NOT INITIAL.

*          me->check_bapi( CHANGING ct_mensagens = gt_mensagens ).
          me->check_bapi( ).

          IF line_exists( gt_return[ type = gc_erro ] ). "#EC CI_STDSEQ

            me->save_log( is_header = <fs_header>
                          iv_erro   = abap_true ).
          ELSE.

            DELETE FROM ztfi_log_contab WHERE id            = <fs_header>-id
                                        AND   identificacao = <fs_header>-identificacao. "#EC CI_IMUD_NESTED

          ENDIF.

        ELSE.

          me->process_bapi( ).

          IF NOT line_exists( me->gt_return[ type = gc_erro ] ). "#EC CI_STDSEQ

            me->save_log( is_header = <fs_header> ).

            me->delete_contab_data( <fs_header> ).

          ENDIF.

          APPEND LINES OF me->gt_return TO gt_mensagens.

        ENDIF.

      ENDIF.

      REFRESH: gt_return.

    ENDLOOP.

  ENDMETHOD.


  METHOD check_bapi.

    CLEAR me->gt_return.

    CALL FUNCTION 'BAPI_ACC_DOCUMENT_CHECK'
      EXPORTING
        documentheader = me->gs_documentheader
      TABLES
        accountgl      = me->gt_accountgl
        currencyamount = me->gt_currencyamount
        extension2     = me->gt_extension2
        return         = me->gt_return.

*    APPEND LINES OF me->gt_return TO ct_mensagens.
  ENDMETHOD.


  METHOD task_finish.

    RECEIVE RESULTS FROM FUNCTION 'ZFMFI_CONTABILIZACAO'
      TABLES
        t_mensagens = me->gt_return.

    RETURN.
  ENDMETHOD.


  METHOD process_bapi.

    CLEAR me->gt_return.

    DATA ls_return TYPE bapiret2.

    CALL FUNCTION 'BAPI_ACC_DOCUMENT_POST'
      EXPORTING
        documentheader = gs_documentheader
      TABLES
        accountgl      = gt_accountgl
        currencyamount = gt_currencyamount
*       accountreceivable = gt_accountreceivable
        extension2     = gt_extension2
        return         = gt_return.

    IF NOT line_exists( gt_return[ type = 'E' ] ).       "#EC CI_STDSEQ

      CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
        EXPORTING
          wait = abap_true.

    ELSE.
*      APPEND gt_return TO ct_mensagens.
    ENDIF.


*    CALL FUNCTION 'ZFMFI_CONTABILIZACAO'
*      STARTING NEW TASK 'BACKGROUND' CALLING task_finish ON END OF TASK
*      EXPORTING
*        is_documentheader = me->gs_documentheader
*        it_accountgl      = me->gt_accountgl
*        it_currencyamount = me->gt_currencyamount
*        it_extension2     = me->gt_extension2
*      TABLES
*        t_mensagens       = me->gt_return.
*
*    WAIT FOR ASYNCHRONOUS TASKS UNTIL me->gt_return IS NOT INITIAL.

*    APPEND LINES OF me->gt_return TO ct_mensagens.
  ENDMETHOD.


  METHOD save_log.

    CONSTANTS lc_conta TYPE char5 VALUE 'Conta' ##NO_TEXT.

    DATA: ls_log TYPE ztfi_log_contab.

    IF iv_delete IS SUPPLIED AND iv_delete IS NOT INITIAL.

      ls_log-status_log    = gc_delete.

    ELSEIF iv_erro IS SUPPLIED AND iv_erro IS NOT INITIAL.

      ls_log-status_log  = gc_erro.

      DELETE gt_return WHERE message_v2 NA gc_number.    "#EC CI_STDSEQ

      DATA(ls_return) = VALUE #( me->gt_return[ type = gc_erro ] OPTIONAL ). "#EC CI_STDSEQ

      TRY.
          DATA(lv_linha) = me->gt_return[ type = gc_erro ]-message_v1. "#EC CI_STDSEQ
        CATCH cx_root.
      ENDTRY.

      TRY.
          SELECT SINGLE conta
          FROM zi_fi_contab_item
          WHERE Identificacao = @is_header-Identificacao
          AND id              = @is_header-Id
          AND Item            = @lv_linha
          INTO @DATA(lv_conta). "#EC CI_SEL_NESTED
        CATCH cx_root.
      ENDTRY.

      IF ls_return IS NOT INITIAL.

        REFRESH: gt_return.

*        ls_return-type = gc_type_i.
        IF lv_conta IS NOT INITIAL.
          ls_log-text = |{ lc_conta } { lv_conta }: { ls_return-message }|.
        ELSE.
          ls_log-text    = ls_return-message.
        ENDIF.


        APPEND ls_return TO et_return.

      ENDIF.

*      et_return    =  gt_return.

    ELSE.

      ls_log-status_log  = gc_contab.
      ls_log-text        = VALUE #( me->gt_return[ type = gc_type_s ]-message OPTIONAL ). "#EC CI_STDSEQ

    ENDIF.

    ls_log-id            = is_header-id.
    ls_log-identificacao = is_header-Identificacao.
    ls_log-usuario       = sy-uname.
    ls_log-dt_exec       = sy-datum.
    ls_log-hr_exec       = sy-uzeit.

    MODIFY ztfi_log_contab FROM ls_log. "#EC CI_IMUD_NESTED

  ENDMETHOD.

  METHOD data_fill_ext.

*    IF is_item-Conta(1) = 4
*    OR is_item-Conta(1) = 3.
    DATA(lv_kostl) = is_item-CentroCusto.
    DATA(lv_item)  = is_item-Item.
*      EXIT.
*    ENDIF.

    IF lv_kostl IS NOT INITIAL.

      SELECT SINGLE bupla FROM csks AS a
      INNER JOIN zi_fi_param_rm AS b
      ON a~gsber = b~gsber
      WHERE a~kostl   = @lv_kostl
        AND b~Zmatriz = @abap_true
      INTO @DATA(lv_bupla).                            "#EC CI_BUFFJOIN

      IF lv_bupla IS NOT INITIAL.

        rt_result = VALUE #( BASE rt_result (
            structure  = gc_bupla
            valuepart1 = lv_item
            valuepart2 = lv_bupla
         ) ).

      ENDIF.

    ENDIF.

  ENDMETHOD.

  METHOD add_message_to_container.
    ro_message_container = io_context->get_message_container( ).

    IF it_return IS SUPPLIED AND it_return IS NOT INITIAL.

      LOOP AT it_return INTO DATA(ls_return).

        IF ls_return-id     IS NOT INITIAL AND
           ls_return-type   IS NOT INITIAL.

          MESSAGE ID ls_return-id
             TYPE ls_return-type
           NUMBER ls_return-number
            WITH ls_return-message_v1
                 ls_return-message_v2
                 ls_return-message_v3
                 ls_return-message_v4
            INTO DATA(lv_dummy).

          ro_message_container->add_message_text_only(
                  EXPORTING iv_msg_type               = ls_return-type
                            iv_msg_text               = CONV #( fill_message( ) )
                            iv_add_to_response_header = abap_false ).

        ELSE.
          ro_message_container->add_message_text_only(
                  EXPORTING iv_msg_type               = ls_return-type
                            iv_msg_text               =  ls_return-message
                            iv_add_to_response_header = abap_false ).
        ENDIF.

      ENDLOOP.

    ELSE.
      ro_message_container->add_message_text_only(
              EXPORTING iv_msg_type               = sy-msgty
                        iv_msg_text               = CONV #( fill_message( ) )
                        iv_add_to_response_header = abap_true ).
    ENDIF.
  ENDMETHOD.

  METHOD fill_message.
    MESSAGE ID sy-msgid
      TYPE sy-msgty
    NUMBER sy-msgno
      INTO rv_message
      WITH sy-msgv1
           sy-msgv2
           sy-msgv3
           sy-msgv4.
  ENDMETHOD.

  METHOD update_status_to_process.

    DATA: lt_log TYPE TABLE OF ztfi_log_contab.
    DATA: ls_log TYPE ztfi_log_contab.

    IF iv_simular IS NOT INITIAL.
      DATA(lv_status) = gc_simular_process.
    ELSE.
      lv_status = gc_contab_process.
    ENDIF.

    LOOP AT gt_header ASSIGNING FIELD-SYMBOL(<fs_header>).
      ls_log-status_log    = lv_status.
      ls_log-id            = <fs_header>-id.
      ls_log-identificacao = <fs_header>-Identificacao.
      ls_log-usuario       = sy-uname.
      ls_log-dt_exec       = sy-datum.
      ls_log-hr_exec       = sy-uzeit.


      APPEND ls_log TO lt_log.

    ENDLOOP.

    MODIFY ztfi_log_contab FROM TABLE lt_log.

  ENDMETHOD.

  METHOD delete_contab_data.
    DELETE FROM ztfi_contab_item WHERE id = is_header-id AND identificacao = is_header-identificacao. "#EC CI_IMUD_NESTED
    DELETE FROM ztfi_contab_cab  WHERE id = is_header-id AND identificacao = is_header-identificacao. "#EC CI_IMUD_NESTED
  ENDMETHOD.

  METHOD get_div_centro_lucro.
    SELECT SINGLE gsber, prctr
    FROM csks
    INTO @DATA(ls_return)
    WHERE kostl = @iv_centro_custo
    AND   kokrs = 'AC3C'.

    IF sy-subrc = 0.

      SELECT SINGLE segment
      FROM cepc
      WHERE prctr  = @ls_return-prctr
      AND   datbi >= @sy-datum
      AND   kokrs  = 'AC3C'
      INTO @ev_segmento.

      ev_centro_lucro = ls_return-prctr.
      ev_divisao      = ls_return-gsber.
    ENDIF.
  ENDMETHOD.


ENDCLASS.
