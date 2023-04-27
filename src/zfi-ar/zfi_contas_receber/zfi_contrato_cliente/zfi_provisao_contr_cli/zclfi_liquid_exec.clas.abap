"! <p class="shorttext synchronized">Classe Atualização de documentos com Bloqueio de Advertência</p>
"! Autor: Anderson Macedo
"! Data: 02/02/2022
class ZCLFI_LIQUID_EXEC definition
  public
  final
  create public .

public section.

  types:
    ty_t_liquid TYPE TABLE OF zi_fi_provisao_cli WITH DEFAULT KEY .

  constants:
    gc_id TYPE c LENGTH 21 value 'ZFI_CONTRATO_CLIENTE' ##NO_TEXT.
  constants GC_S type C value 'S' ##NO_TEXT.

  methods CONSTRUCTOR
    importing
      !IT_LIQUID type TY_T_LIQUID optional .
    "! Chama o processo principal
    "! @parameter iv_contrato        | Contrato
    "! @parameter iv_aditivo         | Aditivo
    "! @parameter rt_msg             | Mensagens
  methods EXECUTE
    importing
      !IV_CONTRATO type ZE_NUM_CONTRATO
      !IV_ADITIVO type ZE_NUM_ADITIVO
      !IV_CLIENTE type KUNNR
      !IV_EMPRESA type BUKRS
      !IV_EXERCICIO type GJAHR
      !IV_ITEM type BUZEI
      !IV_NUMDOC type BELNR_D
      !IV_LANC type SY-DATUM optional
    returning
      value(RT_MSG) type BAPIRET2_TAB .
    "! Retorno da função
    "! @parameter p_task             | Tarefa
  methods TASK_FINISH
    importing
      !P_TASK type CLIKE .
  PROTECTED SECTION.
  PRIVATE SECTION.

    DATA gt_liquid TYPE ty_t_liquid .
    DATA gt_return TYPE bapiret2_tab .
ENDCLASS.



CLASS ZCLFI_LIQUID_EXEC IMPLEMENTATION.


  METHOD constructor.

    gt_liquid = it_liquid.

  ENDMETHOD.


  METHOD execute.

    SORT gt_liquid BY numcontrato numaditivo empresa cliente numdoc item exercicio.

    READ TABLE gt_liquid ASSIGNING FIELD-SYMBOL(<fs_est>) WITH KEY numcontrato = iv_contrato
                                                                   numaditivo  = iv_aditivo
                                                                   empresa     = iv_empresa
                                                                   cliente     = iv_cliente
                                                                   numdoc      = iv_numdoc
                                                                   item        = iv_item
                                                                   exercicio   = iv_exercicio
                                                           BINARY SEARCH.

    IF sy-subrc = 0.

      IF <fs_est>-docliq IS NOT INITIAL.
        rt_msg = VALUE #( ( id = gc_id type = gc_s number = 013  )
                          ( id = gc_id type = gc_s number = 020 message_v1 = <fs_est>-docliq  )
                            ).
      ELSE.

        <fs_est>-venc_liqui = iv_lanc.

        CALL FUNCTION 'ZFMFI_LIQUIDACAO'
          STARTING NEW TASK 'BACKGROUND' CALLING task_finish ON END OF TASK
          EXPORTING
            is_app    = <fs_est>
          CHANGING
            ct_return = gt_return.

        WAIT FOR ASYNCHRONOUS TASKS UNTIL gt_return IS NOT INITIAL.

        APPEND LINES OF gt_return TO rt_msg.
      ENDIF.

    ENDIF.

  ENDMETHOD.


  METHOD task_finish.

    RECEIVE RESULTS FROM FUNCTION 'ZFMFI_LIQUIDACAO'
      TABLES
        ct_return = gt_return.

    RETURN.

  ENDMETHOD.
ENDCLASS.
