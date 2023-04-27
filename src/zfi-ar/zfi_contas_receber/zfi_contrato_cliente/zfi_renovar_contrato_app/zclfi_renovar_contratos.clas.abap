CLASS zclfi_renovar_contratos DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    METHODS constructor
      IMPORTING
        !iv_doc_uuid_h TYPE sysuuid_x16
        !iv_contrato   TYPE ze_num_contrato
        !iv_aditivo    TYPE ze_num_aditivo
      RAISING
        cx_cnv_00001_entry_not_found .
    METHODS renovar_contrato
      IMPORTING
        !iv_data_fim TYPE ze_fim_validade .
    CLASS-METHODS checar_datas
      IMPORTING
        !iv_data_inicio TYPE ze_ini_validade
        !iv_data_fim    TYPE ze_fim_validade
      RAISING
        cx_invalid_date .



    DATA gs_contrato TYPE ztfi_contrato .
  PROTECTED SECTION.
  PRIVATE SECTION.

ENDCLASS.



CLASS zclfi_renovar_contratos IMPLEMENTATION.


  METHOD checar_datas.

*    IF iv_data_fim < gs_contrato-data_ini_valid .
*
*      RAISE EXCEPTION TYPE cx_invalid_date MESSAGE
*        ID 'ZFI_RENOVACAO_CONT' TYPE 'E'
*        NUMBER '000'.
*
*    ENDIF.

    RETURN.

  ENDMETHOD.


  METHOD constructor.

    SELECT SINGLE *
      FROM ztfi_contrato
      INTO @me->gs_contrato
      WHERE doc_uuid_h = @iv_doc_uuid_h AND
            contrato   = @iv_contrato   AND
            aditivo    = @iv_aditivo.

    IF sy-subrc IS NOT INITIAL.

      RAISE EXCEPTION TYPE cx_cnv_00001_entry_not_found .

    ENDIF.

  ENDMETHOD.


  METHOD renovar_contrato.

*    me->checar_datas(
*      EXPORTING
*        iv_data_fim    = iv_data_fim                " Data fim validade
*    ).

    me->gs_contrato-data_fim_valid = iv_data_fim.
*    me->gs_contrato-data_ini_valid = iv_data_inicio.
    me->gs_contrato-status = '8'.
    me->gs_contrato-desativado = space.
    me->gs_contrato-last_changed_by = sy-uname.
    GET TIME STAMP FIELD DATA(lv_ts) .
    me->gs_contrato-last_changed_at = lv_ts.

    MODIFY ztfi_contrato FROM me->gs_contrato.
    COMMIT WORK AND WAIT.



  ENDMETHOD.
ENDCLASS.
