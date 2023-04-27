CLASS zclfi_venc_exec DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    TYPES:
      ty_t_venc TYPE TABLE OF zi_fi_venc_cli_f01 WITH DEFAULT KEY .

    METHODS constructor
      IMPORTING
        !it_venc TYPE ty_t_venc OPTIONAL .
    METHODS execute
      IMPORTING
        !is_param     TYPE zi_fi_venc_f01_popup
        !iv_doc       TYPE belnr_d
        !iv_emp       TYPE bukrs
        !iv_year      TYPE gjahr
        !iv_item      TYPE buzei
        !iv_cliente   TYPE kunnr
      RETURNING
        VALUE(rt_msg) TYPE bapiret2_tab .
    METHODS task_finish
      IMPORTING
        !p_task TYPE clike .
  PROTECTED SECTION.
  PRIVATE SECTION.

    DATA gt_return TYPE bapiret2_tab .
    DATA gt_venc TYPE ty_t_venc .
ENDCLASS.



CLASS ZCLFI_VENC_EXEC IMPLEMENTATION.


  METHOD execute.

    DATA: ls_bseg TYPE bseg.
    DATA: ls_param TYPE zi_fi_venc_f01_popup.

    DATA: lt_return TYPE bapiret2_tab.

    SORT gt_venc BY nodocumento
                    empresa
                    exercicio
                    item
                    cliente.


    READ TABLE gt_venc ASSIGNING FIELD-SYMBOL(<fs_venc>) WITH KEY nodocumento = iv_doc
                                                                  empresa     = iv_emp
                                                                  exercicio   = iv_year
                                                                  item        = iv_item
                                                                  cliente     = iv_cliente
                                                         BINARY SEARCH.

    IF sy-subrc = 0.

      ls_bseg-belnr   = <fs_venc>-nodocumento.
      ls_bseg-bukrs   = <fs_venc>-empresa.
      ls_bseg-gjahr   = <fs_venc>-exercicio.
      ls_bseg-buzei   = <fs_venc>-item.
      ls_bseg-kunnr   = <fs_venc>-cliente.
      ls_bseg-anfbn   = <fs_venc>-docproc.
      ls_bseg-h_bldat = <fs_venc>-datalanc.

      ls_param = is_param.

      CALL FUNCTION 'ZFMFI_MODVENCIMENTO'
        STARTING NEW TASK 'BACKGROUND' CALLING task_finish ON END OF TASK
        EXPORTING
          is_bseg   = ls_bseg
          is_param  = ls_param
        TABLES
          ct_return = gt_return.

      WAIT FOR ASYNCHRONOUS TASKS UNTIL gt_return IS NOT INITIAL.

      APPEND LINES OF gt_return TO rt_msg.

    ENDIF.


  ENDMETHOD.


  METHOD task_finish.

    RECEIVE RESULTS FROM FUNCTION 'ZFMFI_MODVENCIMENTO'
      TABLES
        ct_return = gt_return.

    RETURN.

  ENDMETHOD.


  METHOD constructor.

    gt_venc = it_venc.

  ENDMETHOD.
ENDCLASS.
