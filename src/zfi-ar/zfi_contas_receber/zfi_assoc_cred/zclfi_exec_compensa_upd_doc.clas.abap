"!<p>Classe Executa Compensação e Atualização documento</p>
"!<p><strong>Autor:</strong>Marcos Rubik</p>
"!<p><strong>Data:</strong> 03 de Maio de 2022</p>
CLASS zclfi_exec_compensa_upd_doc DEFINITION
  PUBLIC
  CREATE PUBLIC .

  PUBLIC SECTION.

    "! Realizar Lançamento FM NEW TASK
    "! @parameter IS_COMPENSA_UPD_DOC   | Dados Entrada
    "! @parameter eS_COMPENSA_UPD_DOC   | Dados Saída
    "! @parameter rt_return             | Parâmetro de retorno
    METHODS executar_new_task
      IMPORTING
        !is_compensa_upd_doc TYPE    zsfi_compensa_upd_doc
      EXPORTING
        !es_compensa_upd_doc TYPE    zsfi_compensa_upd_doc
      RETURNING
        VALUE(rt_return)     TYPE bapiret2_t .
    "! Setup Messages
    "! @parameter p_task              | Task
    CLASS-METHODS setup_messages
      IMPORTING
        !p_task TYPE clike .
  PROTECTED SECTION.
  PRIVATE SECTION.

    CLASS-DATA:
      "!Armazenamento das mensagens de processamento
      gt_return           TYPE STANDARD TABLE OF bapiret2,

      "!Flag para sincronizar o processamento da função de criação de ordens de produção
      gv_wait_async       TYPE abap_bool,

      "!Retorno dos dados
      gs_compensa_upd_doc TYPE    zsfi_compensa_upd_doc.
ENDCLASS.



CLASS zclfi_exec_compensa_upd_doc IMPLEMENTATION.


  METHOD executar_new_task.

* ---------------------------------------------------------------------------
* Chama evento para criação de documentos
* ---------------------------------------------------------------------------
    gv_wait_async = abap_false.

    CALL FUNCTION 'ZFMFI_EXEC_COMPENSA_UPD_DOC'
      STARTING NEW TASK 'EXEC_COMPENSA_UPD_DOC'
      CALLING setup_messages ON END OF TASK
      EXPORTING
        is_compensa_upd_doc = is_compensa_upd_doc.

    WAIT UNTIL gv_wait_async = abap_true.

    es_compensa_upd_doc     = gs_compensa_upd_doc.
    rt_return   = gt_return.

  ENDMETHOD.


  METHOD setup_messages.

    CASE p_task.
      WHEN 'EXEC_COMPENSA_UPD_DOC'.
        RECEIVE RESULTS FROM FUNCTION 'ZFMFI_EXEC_COMPENSA_UPD_DOC'
            IMPORTING
                es_compensa_upd_doc     = gs_compensa_upd_doc
                et_return               = gt_return.

      WHEN OTHERS.
    ENDCASE.

    gv_wait_async = abap_true.

  ENDMETHOD.
ENDCLASS.
