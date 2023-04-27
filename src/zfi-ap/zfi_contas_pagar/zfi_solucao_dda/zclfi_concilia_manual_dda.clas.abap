"!<p><h2>Conciliação manual de boletos DDA</h2></p>
"!<p><strong>Autor:</strong> Anderson Miazato</p>
"!<p><strong>Data:</strong> 12 de out de 2021</p>
CLASS zclfi_concilia_manual_dda DEFINITION
PUBLIC
FINAL
CREATE PUBLIC.

  PUBLIC SECTION.

    CONSTANTS:
      "! Classe de mensagens
      gc_msg_id TYPE sy-msgid VALUE 'ZFI_SOLUCAO_DDA'.

    METHODS:
      "! Executa a Conciliação manual do boleto DDA
      "! @parameter is_conciliacao | Dados do boleto DDA e fatura p/ Conciliação
      "! @parameter rt_mensagens   | Retorno de mensagens da BAPI
      executar
        IMPORTING
          is_conciliacao      TYPE zi_fi_conciliacao_manual_dda
          iv_xblnr            TYPE xblnr OPTIONAL
          iv_fiscalyear       TYPE gjahr OPTIONAL
          iv_docnumber        type belnr_d OPTIONAL
        RETURNING
          VALUE(rt_mensagens) TYPE bapiret2_tab,

      "! Método executado após chamada da função background
      "! @parameter p_task | Parametro obrigatório do método ON END OF TASK
      task_finish
        IMPORTING
          p_task TYPE clike.

  PRIVATE SECTION.

    DATA:
      "! <p class="shorttext synchronized">Tabela de retorno de mensagens</p>
      gt_return TYPE STANDARD TABLE OF bapiret2 .

    METHODS:
      "! Valida campos obrigatórios
      "! @parameter is_conciliacao | Dados do boleto DDA e fatura p/ Conciliação
      "! @parameter rt_mensagens | Mensagens de retorno
      valida_campos
        IMPORTING
          is_conciliacao      TYPE zi_fi_conciliacao_manual_dda
        RETURNING
          VALUE(rt_mensagens) TYPE bapiret2_tab.


ENDCLASS.



CLASS zclfi_concilia_manual_dda IMPLEMENTATION.


  METHOD executar.

    DATA:
      lt_return TYPE bapiret2_tab.

    DATA:
      ls_conc_manual_dda TYPE zsfi_conciliacao_manual.

    me->gt_return = me->valida_campos( is_conciliacao ).

    IF me->gt_return IS NOT INITIAL.

      rt_mensagens = me->gt_return.
      RETURN.

    ENDIF.

    ls_conc_manual_dda = VALUE #( err_reason       = is_conciliacao-errreason
                                  bukrs            = is_conciliacao-companycode
                                  lifnr            = is_conciliacao-supplier
                                  xblnr            = is_conciliacao-referenceno
                                  belnr            = is_conciliacao-docnumber
                                  gjahr            = is_conciliacao-fiscalyear
                                  due_date         = is_conciliacao-duedate
                                  duedateconverted = is_conciliacao-duedateconverted
                                  buzei            = is_conciliacao-accountingitem
                                  montante_dda     = is_conciliacao-amount
                                  montante_fatura  = is_conciliacao-accountingdocumentamount
                                  barcode          = is_conciliacao-barcode
                                  blart            = is_conciliacao-accountingdocumenttype
                                  waers            = is_conciliacao-currencycode
                                  sgtxt            = is_conciliacao-itemtext
                                  bktxt            = is_conciliacao-bktxt
                                  zlsch            = is_conciliacao-PaymentMethod ).

    FREE me->gt_return.

*    CALL FUNCTION 'ZFMFI_CONCILIACAO_MANUAL_DDA'
    CALL FUNCTION 'ZFMFI_CONCILIACAO_MANUAL_DDA_2'
      STARTING NEW TASK 'CONCILIA_MANUAL'
      CALLING task_finish ON END OF TASK
      EXPORTING
        is_conciliacao = ls_conc_manual_dda
        iv_xblnr       = iv_xblnr
        iv_fiscalyear  = iv_fiscalyear
        iv_docnumer    = iv_docnumber
      TABLES
        et_return      = lt_return.

    WAIT FOR ASYNCHRONOUS TASKS UNTIL lt_return IS NOT INITIAL.

    rt_mensagens = me->gt_return.

  ENDMETHOD.


  METHOD task_finish.

    RECEIVE RESULTS FROM FUNCTION 'ZFMFI_CONCILIACAO_MANUAL_DDA_2'
*    RECEIVE RESULTS FROM FUNCTION 'ZFMFI_CONCILIACAO_MANUAL_DDA'
      TABLES
        et_return = gt_return.

    RETURN.

  ENDMETHOD.


  METHOD valida_campos.

    IF is_conciliacao-Supplier IS INITIAL.

      me->gt_return = VALUE #( BASE me->gt_return
                               ( type = if_xo_const_message=>error
                                 id = gc_msg_id
                                 number = 006
                                 message_v1 = 'Fornecedor'(001) ) ).

    ENDIF.

    IF is_conciliacao-CompanyCode IS INITIAL.

      me->gt_return = VALUE #( BASE me->gt_return
                               ( type = if_xo_const_message=>error
                                 id = gc_msg_id
                                 number = 006
                                 message_v1 = 'Empresa'(002) ) ).

    ENDIF.

    IF is_conciliacao-ReferenceNo IS INITIAL.

      me->gt_return = VALUE #( BASE me->gt_return
                               ( type = if_xo_const_message=>error
                                 id = gc_msg_id
                                 number = 006
                                 message_v1 = 'Referência'(003) ) ).

    ENDIF.

    IF is_conciliacao-FiscalYear IS INITIAL.

      me->gt_return = VALUE #( BASE me->gt_return
                               ( type = if_xo_const_message=>error
                                 id = gc_msg_id
                                 number = 006
                                 message_v1 = 'Exercício'(004) ) ).

    ENDIF.

    IF is_conciliacao-DocNumber IS INITIAL.

      me->gt_return = VALUE #( BASE me->gt_return
                               ( type = if_xo_const_message=>error
                                 id = gc_msg_id
                                 number = 006
                                 message_v1 = 'Nº documento'(005) ) ).

    ENDIF.

    rt_mensagens = me->gt_return.

  ENDMETHOD.
ENDCLASS.
