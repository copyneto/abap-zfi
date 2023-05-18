CLASS zclfi_reversao_provisao_events DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    TYPES ty_reversao TYPE zi_fi_reversao_provisao_pdc .
    TYPES ty_reversao_popup TYPE zi_fi_reversao_provisao_popup .
    TYPES:
      BEGIN OF ty_parameter,
        saknr_50_fi       TYPE saknr,     " Conta razão - Reversão FI
        saknr_50_fi_co_pa TYPE saknr,     " Conta razão - Reversão FI + CO-PA
        tipo_doc_reversao TYPE blart,     " Tipo de Documento - Reversão FI
      END OF ty_parameter .

    CONSTANTS gc_revertido TYPE bkpf-xref1_hd VALUE 'APPR' ##NO_TEXT.

    "! Reversão da Provisão PDC
    "! @parameter is_reversao | Dados da Reversão
    "! @parameter is_reversao_popup | Dados da Reversão (Popup)
    "! @parameter et_return | Mensagens de retorno
    METHODS revert
      IMPORTING
        !is_reversao       TYPE ty_reversao
        !is_reversao_popup TYPE ty_reversao_popup
      EXPORTING
        !et_return         TYPE bapiret2_t .
    "! Chama processo de reversão
    "! @parameter is_reversao | Dados da Reversão
    "! @parameter is_reversao_popup | Dados da Reversão (Popup)
    "! @parameter et_return | Mensagens de retorno
    METHODS revert_documents
      IMPORTING
        !is_reversao       TYPE ty_reversao
        !is_reversao_popup TYPE ty_reversao_popup
      EXPORTING
        !et_return         TYPE bapiret2_t .
    "! Ler as mensagens geradas pelo processamento
    "! @parameter p_task |Noma da task executada
    CLASS-METHODS setup_messages
      IMPORTING
        !p_task TYPE clike .
    "! Chama processo de reversão
    "! @parameter is_reversao | Dados da Reversão
    "! @parameter is_reversao_popup | Dados da Reversão (Popup)
    "! @parameter et_return | Mensagens de retorno
    METHODS bapi_revert_documents
      IMPORTING
        !is_reversao       TYPE ty_reversao
        !is_reversao_popup TYPE ty_reversao_popup
      EXPORTING
        !et_return         TYPE bapiret2_t .
    "! Chama BAPI de lançamento contábil
    "! @parameter is_reversao | Dados da Reversão
    "! @parameter is_reversao_popup | Dados da Reversão (Popup)
    "! @parameter ev_obj_type |  Operação de referência
    "! @parameter ev_obj_key | Chave referência
    "! @parameter ev_obj_sys | Sistema lógico do documento de origem
    "! @parameter et_return | Mensagens de retorno
    METHODS create_document_post
      IMPORTING
        !is_reversao       TYPE ty_reversao
        !is_reversao_popup TYPE ty_reversao_popup
      EXPORTING
        !ev_obj_type       TYPE awtyp
        !ev_obj_key        TYPE awkey
        !ev_obj_sys        TYPE awsys
        !et_return         TYPE bapiret2_t .
    "! Chama BAPI de lançamento contábil
    "! @parameter is_reversao | Dados da Reversão
    "! @parameter is_reversao_popup | Dados da Reversão (Popup)
    "! @parameter et_return | Mensagens de retorno
    METHODS create_copa_post_cost
      IMPORTING
        !is_reversao       TYPE ty_reversao
        !is_reversao_popup TYPE ty_reversao_popup
        !iv_testrun        TYPE testrun DEFAULT abap_false
      EXPORTING
        !et_return         TYPE bapiret2_t .
    "! Chama BAPI para atualizar os documentos Prov.Desconto Client
    "! @parameter is_reversao | Dados da Reversão
    "! @parameter is_reversao_popup | Dados da Reversão (Popup)
    "! @parameter et_return | Mensagens de retorno
    METHODS change_document
      IMPORTING
        !is_reversao       TYPE ty_reversao
        !is_reversao_popup TYPE ty_reversao_popup
      EXPORTING
        !et_return         TYPE bapiret2_t .
    "! Formata as mensages de retorno
    "! @parameter iv_change_error_type | Muda o Tipo de mensagem 'E' para 'I'.
    "! @parameter iv_change_warning_type | Muda o Tipo de mensagem 'W' para 'I'.
    "! @parameter ct_return | Mensagens de retorno
    METHODS format_return
      IMPORTING
        !iv_change_error_type   TYPE flag OPTIONAL
        !iv_change_warning_type TYPE flag OPTIONAL
      CHANGING
        !ct_return              TYPE bapiret2_t .
    "! Recupera configurações cadastradas
    "! @parameter es_parameter | Parâmetros de configuração
    "! @parameter et_return | Mensagens de retorno
    METHODS get_configuration
      EXPORTING
        !es_parameter TYPE ty_parameter
        !et_return    TYPE bapiret2_t .
    "! Recupera parâmetro
    "! @parameter is_param | Parâmetro cadastrado
    "! @parameter et_value | Valor cadastrado
    METHODS get_parameter
      IMPORTING
        !is_param TYPE ztca_param_val
      EXPORTING
        !ev_value TYPE any
        !et_value TYPE any .
    METHODS create_copa_post_cost_list
      IMPORTING
        !is_reversao       TYPE ty_reversao
        !is_reversao_popup TYPE ty_reversao_popup
        !is_contratopar    TYPE zsfi_contratopar
        !iv_testrun        TYPE testrun DEFAULT abap_false
      EXPORTING
        !et_return         TYPE bapiret2_t .
  PROTECTED SECTION.
  PRIVATE SECTION.

    CLASS-DATA:
      "!Armazenamento das mensagens de processamento
      gt_return     TYPE STANDARD TABLE OF bapiret2,

      "!Parâmetros de configuração
      gs_parameter  TYPE ty_parameter,

      "!Flag para sincronizar o processamento da função de criação de ordens de produção
      gv_wait_async TYPE abap_bool.


ENDCLASS.



CLASS ZCLFI_REVERSAO_PROVISAO_EVENTS IMPLEMENTATION.


  METHOD revert.

    FREE: et_return.

    IF is_reversao_popup-reverttype IS INITIAL.
      " Campo 'Tipo de Reversão' em branco. Favor preencher.
      et_return = VALUE #( BASE et_return ( type = 'E' id = 'ZFI_DESCONTO_COND' number = '001' ) ).
    ENDIF.

    IF is_reversao_popup-documentdate IS INITIAL.
      " Campo 'Data do documento' em branco. Favor preencher.
      et_return = VALUE #( BASE et_return ( type = 'E' id = 'ZFI_DESCONTO_COND' number = '002' ) ).
    ENDIF.

    IF is_reversao_popup-postingdate IS INITIAL.
      " Campo 'Data de lançamento' em branco. Favor preencher.
      et_return = VALUE #( BASE et_return ( type = 'E' id = 'ZFI_DESCONTO_COND' number = '003' ) ).
    ENDIF.

* ---------------------------------------------------------------------------
* Recupera configurações
* ---------------------------------------------------------------------------
    me->get_configuration( IMPORTING es_parameter = me->gs_parameter
                                     et_return    = DATA(lt_return) ).

    INSERT LINES OF lt_return INTO TABLE et_return.

    IF et_return IS NOT INITIAL.
      me->format_return( CHANGING ct_return = et_return ).
      RETURN.
    ENDIF.

* ---------------------------------------------------------------------------
* Chama processo de reversão dos documentos
* ---------------------------------------------------------------------------
    me->revert_documents( EXPORTING is_reversao       = is_reversao
                                    is_reversao_popup = is_reversao_popup
                          IMPORTING et_return         = et_return ).

    me->format_return( CHANGING  ct_return = et_return ).

  ENDMETHOD.


  METHOD revert_documents.

* ---------------------------------------------------------------------------
* Chama evento para reversão de documentos
* ---------------------------------------------------------------------------
    gv_wait_async = abap_false.

    CALL FUNCTION 'ZFMFI_REVERSAO_PROVISAO_PDC'
      STARTING NEW TASK 'REVERSAO_PROVISAO_PDC'
      CALLING setup_messages ON END OF TASK
      EXPORTING
        is_reversao       = is_reversao
        is_reversao_popup = is_reversao_popup.

    WAIT UNTIL gv_wait_async = abap_true.
    et_return = gt_return.

  ENDMETHOD.


  METHOD setup_messages.

    CASE p_task.
      WHEN 'REVERSAO_PROVISAO_PDC'.
        RECEIVE RESULTS FROM FUNCTION 'ZFMFI_REVERSAO_PROVISAO_PDC'
            IMPORTING
                et_return = gt_return.
    ENDCASE.

    gv_wait_async = abap_true.

  ENDMETHOD.


  METHOD bapi_revert_documents.

    FREE: et_return.

* ---------------------------------------------------------------------------
* Recupera configurações
* ---------------------------------------------------------------------------
    me->get_configuration( IMPORTING es_parameter = me->gs_parameter
                                     et_return    = DATA(lt_return) ).

    INSERT LINES OF lt_return INTO TABLE et_return.
    CHECK NOT line_exists( et_return[ type = 'E' ] ).

* ---------------------------------------------------------------------------
* Processamento adicional para CO-PA (test run)
* ---------------------------------------------------------------------------
*    IF is_reversao-RevertType = gc_tipo_reversao-reverter_fi_co_pa.
    IF is_reversao_popup-reverttype = gc_tipo_reversao-reverter_fi_co_pa.

      me->create_copa_post_cost( EXPORTING is_reversao       = is_reversao
                                           is_reversao_popup = is_reversao_popup
                                           iv_testrun        = abap_true
                                 IMPORTING et_return         = lt_return ).

      INSERT LINES OF lt_return INTO TABLE et_return.
      CHECK NOT line_exists( et_return[ type = 'E' ] ).
    ENDIF.

* ---------------------------------------------------------------------------
* Cria lançamento contábil
* ---------------------------------------------------------------------------
    me->create_document_post( EXPORTING is_reversao       = is_reversao
                                        is_reversao_popup = is_reversao_popup
                              IMPORTING et_return         = lt_return ).

    INSERT LINES OF lt_return INTO TABLE et_return.
    CHECK NOT line_exists( et_return[ type = 'E' ] ).

* ---------------------------------------------------------------------------
* Processamento adicional para CO-PA
* ---------------------------------------------------------------------------
*    IF is_reversao-reverttype = gc_tipo_reversao-reverter_fi_co_pa.
    IF is_reversao_popup-reverttype = gc_tipo_reversao-reverter_fi_co_pa.

      me->create_copa_post_cost( EXPORTING is_reversao       = is_reversao
                                           is_reversao_popup = is_reversao_popup
                                 IMPORTING et_return         = lt_return ).

      INSERT LINES OF lt_return INTO TABLE et_return.
      CHECK NOT line_exists( et_return[ type = 'E' ] ).
    ENDIF.

* ---------------------------------------------------------------------------
* Atualiza documentos Prov.Desconto Client sinalizando que o documento foi revertido
* ---------------------------------------------------------------------------
    me->change_document( EXPORTING is_reversao       = is_reversao
                                   is_reversao_popup = is_reversao_popup
                         IMPORTING et_return         = lt_return ).

    INSERT LINES OF lt_return INTO TABLE et_return.

    CHECK NOT line_exists( et_return[ type = 'E' ] ).

    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        wait = abap_true.

  ENDMETHOD.


  METHOD create_document_post.

    DATA: lt_amount            TYPE STANDARD TABLE OF bapiaccr09,
          lt_accountgl         TYPE STANDARD TABLE OF bapiacgl09,
          lt_accountreceivable TYPE STANDARD TABLE OF bapiacar09,
          lt_accountpayable    TYPE STANDARD TABLE OF bapiacap09,
          lt_extension2        TYPE STANDARD TABLE OF bapiparex,
          lt_return            TYPE bapiret2_t,

          ls_header            TYPE bapiache09,
          lv_itemno            TYPE posnr_acc.

    FREE: ev_obj_type, ev_obj_key, ev_obj_sys, et_return.


* ---------------------------------------------------------------------------
* Recupera dados da linha de crédito
* ---------------------------------------------------------------------------
    SELECT SINGLE *
        FROM zi_fi_reversao_provisao_pdc_50
        WHERE companycode            = @is_reversao-companycode
          AND accountingdocument     = @is_reversao-accountingdocument
          AND fiscalyear             = @is_reversao-fiscalyear
        INTO @DATA(ls_reversao_50).

    IF sy-subrc NE 0.
      CLEAR ls_reversao_50.
    ENDIF.

* ---------------------------------------------------------------------------
* Preenche dados de cabeçalho
* ---------------------------------------------------------------------------
    ls_header       = VALUE #( pstng_date   = is_reversao_popup-postingdate
                               doc_date     = is_reversao_popup-documentdate
                               fis_period   = is_reversao_popup-postingdate+4(2)
*                               doc_type     = is_reversao-accountingdocumenttype
                               doc_type     = me->gs_parameter-tipo_doc_reversao
                               comp_code    = is_reversao-companycode
                               ref_doc_no   = is_reversao-documentreferenceid
                               header_txt   = is_reversao-accountingdocumentheadertext
                               username     = sy-uname ).

* ---------------------------------------------------------------------------
* Preenche dados de item - Lançamento a débito (cliente)
* ---------------------------------------------------------------------------
    ADD 1 TO lv_itemno.

    lt_accountreceivable[]  = VALUE #( BASE lt_accountreceivable (
                                       itemno_acc   = lv_itemno
                                       customer     = is_reversao-customer
                                       pmnt_block   = gc_bapi_contabil-chave_bloq_a
                                       pymt_meth    = is_reversao-paymentmethod
                                       sp_gl_ind    = gc_bapi_contabil-cod_razao_esp_c
                                       bus_area     = is_reversao-businessarea
*                                       branch       = is_reversao-BusinessPlace
                                       alloc_nmbr   = is_reversao-assignmentreference
                                       item_text    = is_reversao-documentitemtext
                                       profit_ctr   = is_reversao-profitcenter ) ).

    lt_amount[]             = VALUE #( BASE lt_amount (
                                       itemno_acc   = lv_itemno
                                       currency     = is_reversao-balancetransactioncurrency
                                       currency_iso = ls_reversao_50-balancetransactioncurrency
                                       amt_doccur   = abs( is_reversao-amountinbalancetransaccrcy ) ) ).

    lt_extension2[]         = VALUE #( BASE lt_extension2 (
                                       structure  = 'BUPLA'
                                       valuepart1 = lv_itemno
                                       valuepart2 = is_reversao-businessplace )
                                       (
                                       structure  = 'BSCHL'
                                       valuepart1 = lv_itemno
                                       valuepart2 = gc_bapi_contabil-chave_lanc_09 )
                                       (
                                       structure  = 'SHKZG'
                                       valuepart1 = lv_itemno
                                       valuepart2 = gc_bapi_contabil-codigo_debito_s )
                                       (
                                       structure  = 'XREF1_HD'
                                       valuepart1 = lv_itemno
                                       valuepart2 = is_reversao-reference1indocumentheader )
                                       (
                                       structure  = 'XREF2_HD'
                                       valuepart1 = lv_itemno
                                       valuepart2 = is_reversao-reference2indocumentheader )
                                       (
                                       structure  = 'XREF1'
                                       valuepart1 = lv_itemno
                                       valuepart2 = is_reversao-reference1idbybusinesspartner )
                                       (
                                       structure  = 'XREF2'
                                       valuepart1 = lv_itemno
                                       valuepart2 = gc_bapi_contabil-app )
                                       (
                                       structure  = 'XREF3'
                                       valuepart1 = lv_itemno
                                       valuepart2 = |{ is_reversao-accountingdocument }-{ is_reversao-fiscalyear }-{ is_reversao-accountingdocumentitem  }| ) ).

* ---------------------------------------------------------------------------
* Preenche dados de item - Lançamento a crédito
* ---------------------------------------------------------------------------
    ADD 1 TO lv_itemno.

*    lt_accountgl[]          = VALUE #( BASE lt_accountgl (
*                                       itemno_acc   = lv_itemno
*                                       gl_account   = COND #( WHEN is_reversao_popup-reverttype = gc_tipo_reversao-reverter_fi
*                                                              THEN me->gs_parameter-saknr_50_fi
*                                                              WHEN is_reversao_popup-reverttype = gc_tipo_reversao-reverter_fi_co_pa
*                                                              THEN me->gs_parameter-saknr_50_fi_co_pa
*                                                              ELSE space )
*                                       plant        = ls_reversao_50-Plant
*                                       ac_doc_no    = ls_reversao_50-AssignmentReference
*                                       item_text    = ls_reversao_50-DocumentItemText
*                                       costcenter   = ls_reversao_50-CostCenter
*                                       bus_area     = ls_reversao_50-BusinessArea
*                                       profit_ctr   = ls_reversao_50-ProfitCenter
*                                       segment      = ls_reversao_50-Segment ) ).

    lt_accountpayable[]     = VALUE #( BASE lt_accountpayable (
                                       itemno_acc   = lv_itemno
                                       gl_account   = COND #( WHEN is_reversao_popup-reverttype = gc_tipo_reversao-reverter_fi
                                                              THEN me->gs_parameter-saknr_50_fi
                                                              WHEN is_reversao_popup-reverttype = gc_tipo_reversao-reverter_fi_co_pa
                                                              THEN me->gs_parameter-saknr_50_fi_co_pa
                                                              ELSE space )
                                       alloc_nmbr   = ls_reversao_50-assignmentreference
                                       item_text    = ls_reversao_50-documentitemtext
                                       bus_area     = ls_reversao_50-businessarea
                                       profit_ctr   = ls_reversao_50-profitcenter ) ).

    lt_amount[]             = VALUE #( BASE lt_amount (
                                       itemno_acc   = lv_itemno
                                       currency     = ls_reversao_50-balancetransactioncurrency
                                       currency_iso = ls_reversao_50-balancetransactioncurrency
                                       amt_doccur   = - abs( ls_reversao_50-amountinbalancetransaccrcy ) ) ).

    lt_extension2[]         = VALUE #( BASE lt_extension2 (
                                       structure  = 'BUPLA'
                                       valuepart1 = lv_itemno
                                       valuepart2 = ls_reversao_50-businessplace )
                                       (
                                       structure  = 'WERKS'
                                       valuepart1 = lv_itemno
                                       valuepart2 = ls_reversao_50-plant )
                                       (
                                       structure  = 'KOSTL'
                                       valuepart1 = lv_itemno
                                       valuepart2 = ls_reversao_50-costcenter )
                                       (
                                       structure  = 'SEGMENT'
                                       valuepart1 = lv_itemno
                                       valuepart2 = ls_reversao_50-segment ) ).

* ---------------------------------------------------------------------------
* Chama BAPI de lançamento contábil
* ---------------------------------------------------------------------------
    CALL FUNCTION 'BAPI_ACC_DOCUMENT_POST'
      EXPORTING
        documentheader    = ls_header
      IMPORTING
        obj_type          = ev_obj_type
        obj_key           = ev_obj_key
        obj_sys           = ev_obj_sys
      TABLES
        accountgl         = lt_accountgl
        accountreceivable = lt_accountreceivable
        accountpayable    = lt_accountpayable
        currencyamount    = lt_amount
        extension2        = lt_extension2
        return            = lt_return.

    IF line_exists( lt_return[ id = 'RW' number = 605 ] ).
      READ TABLE lt_return ASSIGNING FIELD-SYMBOL(<fs_return>) WITH KEY id = 'RW'
                                                                    number = 605.
      IF <fs_return> IS ASSIGNED.
        et_return = VALUE #( ( id         = 'ZFI_DESCONTO_COND'
                               type       = 'S'
                               number     = 007
                               message_v1 = <fs_return>-message_v2+10(4)
                               message_v2 = <fs_return>-message_v2(10)
                               message_v3 = <fs_return>-message_v2+14(4) ) ).
        DELETE lt_return WHERE id = 'RW' AND number = 605.
      ENDIF.
    ENDIF.

    DELETE lt_return WHERE type = 'W'.

    INSERT LINES OF lt_return[] INTO TABLE et_return[].

    IF line_exists( lt_return[ type = 'E' ] ).
      CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
      RETURN.
    ENDIF.

*    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
*      EXPORTING
*        wait = abap_true.

  ENDMETHOD.


  METHOD create_copa_post_cost.

    DATA: lt_inputdata TYPE STANDARD TABLE OF bapi_copa_data,
          lt_fieldlist TYPE STANDARD TABLE OF bapi_copa_field,
          lt_return    TYPE bapiret2_t.

    DATA: lv_operatingconcern TYPE erkrs,
          lv_testrun          TYPE testrun,
          lv_record_id        TYPE rke_record_id,
          lv_bzirk            TYPE bzirk.

    FREE: et_return.

* ---------------------------------------------------------------------------
* Preenche dados de cabeçalho
* ---------------------------------------------------------------------------
    lv_operatingconcern = gc_bapi_copa-area_ar3c.

* ---------------------------------------------------------------------------
* Preenche dados de item
* ---------------------------------------------------------------------------
    ADD 1 TO lv_record_id.

    SPLIT is_reversao-accountingdocumentheadertext AT '-' INTO lv_bzirk DATA(lv_text).


    lt_inputdata[] = VALUE #( BASE lt_inputdata ( record_id = lv_record_id
                                                  fieldname = 'BUKRS'
                                                  value     = is_reversao-companycode
                                                  currency  = is_reversao-balancetransactioncurrency )

                                                ( record_id = lv_record_id
                                                  fieldname = 'BUDAT'
                                                  value     = is_reversao-documentdate
                                                  currency  = is_reversao-balancetransactioncurrency )

                                                ( record_id = lv_record_id
                                                  fieldname = 'KNDNR'
                                                  value     = is_reversao-customer
                                                  currency  = is_reversao-balancetransactioncurrency )

                                                ( record_id = lv_record_id
                                                  fieldname = 'VTWEG'
                                                  value     = is_reversao-reference2indocumentheader+2(2)
                                                  currency  = is_reversao-balancetransactioncurrency )

                                                ( record_id = lv_record_id
                                                  fieldname = 'BZIRK'
*                                                  value     = is_reversao-accountingdocumentheadertext+0(6)
                                                  value     = lv_bzirk
                                                  currency  = is_reversao-balancetransactioncurrency )

                                                ( record_id = lv_record_id
                                                  fieldname = 'WWMT1'
                                                  value     = is_reversao-profitcenter+0(2)
                                                  currency  = is_reversao-balancetransactioncurrency )

                                                ( record_id = lv_record_id
                                                  fieldname = 'WERKS'
                                                  value     = is_reversao-plant
                                                  currency  = is_reversao-balancetransactioncurrency )

                                                ( record_id = lv_record_id
                                                  fieldname = 'VV002'
                                                  value     = is_reversao-amountinbalancetransaccrcy
                                                  currency  = is_reversao-balancetransactioncurrency )

                                                ( record_id = lv_record_id
                                                  fieldname = 'VRGAR'
                                                  value     = 'Z'
                                                  currency  = is_reversao-balancetransactioncurrency )

*                                                ( record_id = lv_record_id
*                                                  fieldname = 'PRCTR'
*                                                  value     = lv_prctr
*                                                  currency  = is_reversao-balancetransactioncurrency )
                                                 ).

    lt_fieldlist[] = VALUE #( BASE lt_fieldlist ( fieldname = 'BUKRS' )
                                                ( fieldname = 'BUDAT' )
                                                ( fieldname = 'KNDNR' )
                                                ( fieldname = 'VTWEG' )
                                                ( fieldname = 'BZIRK' )
                                                ( fieldname = 'WWMT1' )
                                                ( fieldname = 'WERKS' )
                                                ( fieldname = 'VV002' )
                                                ( fieldname = 'VRGAR' )
*                                                ( fieldname = 'PRCTR' )
                                                 ).

* ---------------------------------------------------------------------------
* Chama BAPI para processamento do CO-PA
* ---------------------------------------------------------------------------
    CALL FUNCTION 'BAPI_COPAACTUALS_POSTCOSTDATA'
      EXPORTING
        operatingconcern = lv_operatingconcern
        testrun          = iv_testrun
      TABLES
        inputdata        = lt_inputdata
        fieldlist        = lt_fieldlist
        return           = lt_return.

    INSERT LINES OF lt_return[] INTO TABLE et_return[].

    IF line_exists( lt_return[ type = 'E' ] ).

      APPEND INITIAL LINE TO et_return ASSIGNING FIELD-SYMBOL(<fs_ret>).
      <fs_ret>-id     = 'ZFI_BASE_CALCULO'.
      <fs_ret>-type   = 'E'.
      <fs_ret>-number = 035.
      CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
      RETURN.
    ELSE.
      IF iv_testrun IS INITIAL.
        et_return = VALUE #( ( id     = 'ZFI_BASE_CALCULO'
                               type   = 'S'
                               number = 034 ) ).
      ENDIF.
    ENDIF.

    IF iv_testrun IS INITIAL.
      CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
        EXPORTING
          wait = abap_true.
    ENDIF.

  ENDMETHOD.


  METHOD change_document.

    DATA: lt_accchg TYPE STANDARD TABLE OF accchg.

    FREE: et_return.

* ---------------------------------------------------------------------------
* Indica os campos que serão atualizados
* ---------------------------------------------------------------------------
    lt_accchg[] = VALUE #( BASE lt_accchg (
                           fdname = 'XREF1_HD'
                           newval = me->gc_revertido ) ).

* ---------------------------------------------------------------------------
* Chama BAPI para para atualizar os documentos Prov.Desconto Client
* ---------------------------------------------------------------------------
    CALL FUNCTION 'FI_DOCUMENT_CHANGE'
      EXPORTING
        i_buzei              = is_reversao-accountingdocumentitem
        i_bukrs              = is_reversao-companycode
        i_belnr              = is_reversao-accountingdocument
        i_gjahr              = is_reversao-fiscalyear
      TABLES
        t_accchg             = lt_accchg
      EXCEPTIONS
        no_reference         = 1
        no_document          = 2
        many_documents       = 3
        wrong_input          = 4
        overwrite_creditcard = 5
        OTHERS               = 6.

    IF sy-subrc <> 0.
      et_return[] = VALUE #( BASE et_return (
                             type       = sy-msgty
                             id         = sy-msgid
                             number     = sy-msgno
                             message_v1 = sy-msgv1
                             message_v2 = sy-msgv2
                             message_v3 = sy-msgv3
                             message_v4 = sy-msgv4 ) ).
    ELSE.
      " Documento antigo &1/&2/&3 atualizado com sucesso.
      et_return[] = VALUE #( BASE et_return (
                             type       = 'S'
                             id         = 'ZFI_DESCONTO_COND'
                             number     = '006'
                             message_v1 = is_reversao-companycode
                             message_v2 = is_reversao-accountingdocument
                             message_v3 = is_reversao-fiscalyear ) ).
    ENDIF.

    IF line_exists( et_return[ type = 'E' ] ).
      CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
      RETURN.
    ENDIF.

*    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
*      EXPORTING
*        wait = abap_true.

  ENDMETHOD.


  METHOD format_return.

    DATA: ls_return_format TYPE bapiret2.

* ---------------------------------------------------------------------------
* Format mensagens de retorno
* ---------------------------------------------------------------------------
    LOOP AT ct_return REFERENCE INTO DATA(ls_return).

      " ---------------------------------------------------------------------------
      " Ao processar a Action com múltiplas linhas, quando há qualquer mensagem de
      " erro ele acaba ocultando as outras mensagens de Sucesso, Informação e
      " Aviso. Esta alternativa foi encontrada para exibir todas as mensagens
      " ---------------------------------------------------------------------------
      ls_return->type = COND #( WHEN ls_return->type EQ 'E' AND iv_change_error_type IS NOT INITIAL
                                THEN 'I'
                                WHEN ls_return->type EQ 'W' AND iv_change_warning_type IS NOT INITIAL
                                THEN 'I'
                                ELSE ls_return->type ).

      IF  ls_return->message IS INITIAL.

        TRY.
            CALL FUNCTION 'FORMAT_MESSAGE'
              EXPORTING
                id        = ls_return->id
                lang      = sy-langu
                no        = ls_return->number
                v1        = ls_return->message_v1
                v2        = ls_return->message_v2
                v3        = ls_return->message_v3
                v4        = ls_return->message_v4
              IMPORTING
                msg       = ls_return->message
              EXCEPTIONS
                not_found = 1
                OTHERS    = 2.

            IF sy-subrc <> 0.
              CLEAR ls_return->message.
            ENDIF.

          CATCH cx_root INTO DATA(lo_root).
            DATA(lv_message) = lo_root->get_longtext( ).
        ENDTRY.

      ENDIF.

    ENDLOOP.

  ENDMETHOD.


  METHOD get_configuration.

    FREE: et_return, es_parameter.

* ---------------------------------------------------------------------------
* Recupera Parâmetro Conta razão - Reversão FI
* ---------------------------------------------------------------------------
    IF me->gs_parameter-saknr_50_fi IS INITIAL.

      DATA(ls_parametro) = VALUE ztca_param_val( modulo = gc_param_saknr_fi-modulo
                                                 chave1 = gc_param_saknr_fi-chave1
                                                 chave2 = gc_param_saknr_fi-chave2
                                                 chave3 = gc_param_saknr_fi-chave3 ).

      me->get_parameter( EXPORTING is_param = ls_parametro
                         IMPORTING ev_value = me->gs_parameter-saknr_50_fi ).

    ENDIF.

    IF me->gs_parameter-saknr_50_fi  IS INITIAL.
      " Param. 'Conta Razão FI' não cadastrado: [&1/&2/&3/&4]
      et_return = VALUE #( BASE et_return ( type = 'E' id = 'ZFI_DESCONTO_COND' number = '004'
                                            message_v1 = ls_parametro-modulo
                                            message_v2 = ls_parametro-chave1
                                            message_v3 = ls_parametro-chave2
                                            message_v4 = ls_parametro-chave3 ) ).
    ENDIF.

* ---------------------------------------------------------------------------
* Recupera Parâmetro Conta razão - Reversão FI + CO-PA
* ---------------------------------------------------------------------------
    IF me->gs_parameter-saknr_50_fi_co_pa IS INITIAL.

      ls_parametro = VALUE ztca_param_val( modulo = gc_param_saknr_fi_co_pa-modulo
                                           chave1 = gc_param_saknr_fi_co_pa-chave1
                                           chave2 = gc_param_saknr_fi_co_pa-chave2
                                           chave3 = gc_param_saknr_fi_co_pa-chave3 ).

      me->get_parameter( EXPORTING is_param = ls_parametro
                         IMPORTING ev_value = me->gs_parameter-saknr_50_fi_co_pa ).

    ENDIF.

    IF me->gs_parameter-saknr_50_fi_co_pa  IS INITIAL.
      " Param. 'Conta Razão FI CO-PA' não cadastrado: [&1/&2/&3/&4]
      et_return = VALUE #( BASE et_return ( type = 'E' id = 'ZFI_DESCONTO_COND' number = '005'
                                            message_v1 = ls_parametro-modulo
                                            message_v2 = ls_parametro-chave1
                                            message_v3 = ls_parametro-chave2
                                            message_v4 = ls_parametro-chave3 ) ).
    ENDIF.

* ---------------------------------------------------------------------------
* Recupera Parâmetro Tipo de Documento - Reversão FI + CO-PA
* ---------------------------------------------------------------------------
    IF me->gs_parameter-tipo_doc_reversao IS INITIAL.

      ls_parametro = VALUE ztca_param_val( modulo = gc_param_blart_fi-modulo
                                           chave1 = gc_param_blart_fi-chave1
                                           chave2 = gc_param_blart_fi-chave2
                                           chave3 = gc_param_blart_fi-chave3 ).

      me->get_parameter( EXPORTING is_param = ls_parametro
                         IMPORTING ev_value = me->gs_parameter-tipo_doc_reversao ).

    ENDIF.

    IF me->gs_parameter-tipo_doc_reversao  IS INITIAL.
      " Param. 'PDC-REVERSAO-TIPODOC' não cadastrado: [&1/&2/&3/&4]
      et_return = VALUE #( BASE et_return ( type = 'E' id = 'ZFI_DESCONTO_COND' number = '012'
                                            message_v1 = ls_parametro-modulo
                                            message_v2 = ls_parametro-chave1
                                            message_v3 = ls_parametro-chave2
                                            message_v4 = ls_parametro-chave3 ) ).
    ENDIF.

    me->format_return( CHANGING ct_return = et_return ).

    es_parameter = me->gs_parameter.

  ENDMETHOD.


  METHOD get_parameter.

    FREE et_value.

    TRY.
        DATA(lo_param) = NEW zclca_tabela_parametros( ).

        " Recupera valor único
        IF ev_value IS SUPPLIED.
          lo_param->m_get_single( EXPORTING iv_modulo = is_param-modulo
                                            iv_chave1 = is_param-chave1
                                            iv_chave2 = is_param-chave2
                                            iv_chave3 = is_param-chave3
                                  IMPORTING ev_param  = ev_value ).
        ENDIF.

        " Recupera lista de valores
        IF et_value IS SUPPLIED.
          lo_param->m_get_range( EXPORTING iv_modulo = is_param-modulo
                                           iv_chave1 = is_param-chave1
                                           iv_chave2 = is_param-chave2
                                           iv_chave3 = is_param-chave3
                                 IMPORTING et_range  = et_value ).
        ENDIF.

      CATCH zcxca_tabela_parametros.
        FREE et_value.
    ENDTRY.

  ENDMETHOD.


  METHOD create_copa_post_cost_list.

    DATA: lt_inputdata TYPE STANDARD TABLE OF bapi_copa_data,
          lt_fieldlist TYPE STANDARD TABLE OF bapi_copa_field,
          lt_return    TYPE bapiret2_t.

    DATA: lv_operatingconcern TYPE erkrs,
          lv_testrun          TYPE testrun,
          lv_record_id        TYPE rke_record_id,
          lv_valor_rateio     TYPE wrbtr.

    FREE: et_return.

* ---------------------------------------------------------------------------
* Preenche dados de cabeçalho
* ---------------------------------------------------------------------------
    lv_operatingconcern = gc_bapi_copa-area_ar3c.

* ---------------------------------------------------------------------------
* Preenche dados de item
* ---------------------------------------------------------------------------
    LOOP AT is_contratopar-lista_rateio ASSIGNING FIELD-SYMBOL(<fs_rateio>).

      ADD 1 TO lv_record_id.

      lt_inputdata[] = VALUE #( BASE lt_inputdata ( record_id = lv_record_id
                                                    fieldname = 'BUKRS'
                                                    value     = is_reversao-companycode
                                                    currency  = is_reversao-balancetransactioncurrency )

                                                  ( record_id = lv_record_id
                                                    fieldname = 'BUDAT'
                                                    value     = is_reversao-documentdate
                                                    currency  = is_reversao-balancetransactioncurrency )

                                                  ( record_id = lv_record_id
                                                    fieldname = 'KNDNR'
                                                    value     = is_reversao-customer
                                                    currency  = is_reversao-balancetransactioncurrency )

                                                  ( record_id = lv_record_id
                                                    fieldname = 'VTWEG'
                                                    value     = is_reversao-reference2indocumentheader+2(2)
                                                    currency  = is_reversao-balancetransactioncurrency )

                                                  ( record_id = lv_record_id
                                                    fieldname = 'BZIRK'
                                                    value     = is_reversao-accountingdocumentheadertext+0(6)
                                                    currency  = is_reversao-balancetransactioncurrency )

                                                  ( record_id = lv_record_id
                                                    fieldname = 'WWMT1'
                                                    value     = is_reversao-profitcenter+0(2)
                                                    currency  = is_reversao-balancetransactioncurrency )

                                                  ( record_id = lv_record_id
                                                    fieldname = 'WERKS'
                                                    value     = is_reversao-plant
                                                    currency  = is_reversao-balancetransactioncurrency )

                                                  ( record_id = lv_record_id
                                                    fieldname = 'VV002'
                                                    value     = <fs_rateio>-vv001
                                                    currency  = is_reversao-balancetransactioncurrency )

                                                  ( record_id = lv_record_id
                                                    fieldname = 'KOKRS'
                                                    value     = 'AC3C'
                                                    currency  = is_reversao-balancetransactioncurrency )

                                                  ( record_id = lv_record_id
                                                    fieldname = 'VRGAR'
                                                    value     = 'Z'
                                                    currency  = is_reversao-balancetransactioncurrency )

                                                  ( record_id = lv_record_id
                                                    fieldname = 'PRCTR'
                                                    value     = <fs_rateio>-prctr
                                                    currency  = is_reversao-balancetransactioncurrency )

                                                  ( record_id = lv_record_id
                                                    fieldname = 'WWMT1'
                                                    value     = <fs_rateio>-prctr(02)
                                                    currency  = is_reversao-balancetransactioncurrency )

                                                  ( record_id = lv_record_id
                                                    fieldname = 'WWMT2'
                                                    value     = <fs_rateio>-prctr+04(02)
                                                    currency  = is_reversao-balancetransactioncurrency )

                                                  ( record_id = lv_record_id
                                                    fieldname = 'WWMT3'
                                                    value     =  <fs_rateio>-prctr+06(02)
                                                    currency  = is_reversao-balancetransactioncurrency )

                                                  ( record_id = lv_record_id
                                                    fieldname = 'WWMT4'
                                                    value     =  <fs_rateio>-prctr+08(02)
                                                    currency  = is_reversao-balancetransactioncurrency )

                                                  ( record_id = lv_record_id
                                                    fieldname = 'WWMT5'
                                                    value     =  <fs_rateio>-prctr+02(02)
                                                    currency  = is_reversao-balancetransactioncurrency )

                                                  ( record_id = lv_record_id
                                                    fieldname = 'GSBER'
                                                    value     = is_contratopar-gsber
                                                    currency  = is_reversao-balancetransactioncurrency )

*                                                  ( record_id = lv_record_id
*                                                    fieldname = 'VV001'
*                                                    value     = <fs_rateio>-vv001
*                                                    currency  = is_reversao-balancetransactioncurrency )

                                                   ).

      lv_valor_rateio = lv_valor_rateio + <fs_rateio>-vv001.

    ENDLOOP.

    IF is_contratopar-zvalorparcela NE lv_valor_rateio.
      et_return = VALUE #( ( id     = 'ZFI_BASE_CALCULO'
                             type   = 'E'
                             number = 048 ) ).
      RETURN.
    ENDIF.

    lt_fieldlist[] = VALUE #( BASE lt_fieldlist ( fieldname = 'BUKRS' )
                                                ( fieldname = 'BUDAT' )
                                                ( fieldname = 'KNDNR' )
                                                ( fieldname = 'VTWEG' )
                                                ( fieldname = 'BZIRK' )
                                                ( fieldname = 'WWMT1' )
                                                ( fieldname = 'WERKS' )
                                                ( fieldname = 'VV002' )
                                                ( fieldname = 'KOKRS' )
                                                ( fieldname = 'VRGAR' )
                                                ( fieldname = 'PRCTR' )
                                                ( fieldname = 'WWMT1' )
                                                ( fieldname = 'WWMT2' )
                                                ( fieldname = 'WWMT3' )
                                                ( fieldname = 'WWMT4' )
                                                ( fieldname = 'WWMT5' )
                                                ( fieldname = 'GSBER' )
*                                                ( fieldname = 'VV001' )
                                                 ).

* ---------------------------------------------------------------------------
* Chama BAPI para processamento do CO-PA
* ---------------------------------------------------------------------------
    CALL FUNCTION 'BAPI_COPAACTUALS_POSTCOSTDATA'
      EXPORTING
        operatingconcern = lv_operatingconcern
        testrun          = iv_testrun
      TABLES
        inputdata        = lt_inputdata
        fieldlist        = lt_fieldlist
        return           = lt_return.

    INSERT LINES OF lt_return[] INTO TABLE et_return[].

    IF line_exists( lt_return[ type = 'E' ] ).
      et_return = VALUE #( ( id     = 'ZFI_BASE_CALCULO'
                             type   = 'E'
                             number = 035 ) ).
      CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
      RETURN.
    ELSE.
      IF iv_testrun IS INITIAL.
        et_return = VALUE #( ( id     = 'ZFI_BASE_CALCULO'
                               type   = 'S'
                               number = 034 ) ).
      ENDIF.
    ENDIF.

    IF iv_testrun IS INITIAL.
      CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
        EXPORTING
          wait = abap_true.
    ENDIF.

  ENDMETHOD.
ENDCLASS.
