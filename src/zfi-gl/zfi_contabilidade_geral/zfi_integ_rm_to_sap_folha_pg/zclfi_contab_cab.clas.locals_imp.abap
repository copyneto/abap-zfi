CLASS lcl_Header DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS simular FOR MODIFY
      IMPORTING keys FOR ACTION Header~simular.

    METHODS contabilizar FOR MODIFY
      IMPORTING keys FOR ACTION Header~contabilizar.

ENDCLASS.

CLASS lcl_Header IMPLEMENTATION.

  METHOD simular.
    RETURN.
*
*    DATA: lt_header_aux TYPE TABLE OF zi_fi_contab_cab  WITH DEFAULT KEY,
*          lt_item_aux   TYPE TABLE OF zi_fi_contab_item WITH DEFAULT KEY.
*
*    SELECT *
*    FROM zi_fi_contab_cab
*    WHERE StatusCode = 'S'
*    INTO TABLE @DATA(lt_header).
*
*    IF sy-subrc = 0.
*
*      SELECT *
*      FROM zi_fi_contab_item
*      FOR ALL ENTRIES IN @lt_header
*      WHERE Identificacao = @lt_header-Identificacao
*      AND   Id            = @lt_header-Id
*      INTO TABLE @DATA(lt_item).
*
*      MOVE-CORRESPONDING lt_header TO lt_header_aux.
*      MOVE-CORRESPONDING lt_item   TO lt_item_aux.
*
*      EXPORT  lt_header_aux = lt_header_aux
*              lt_item_aux   = lt_item_aux  TO DATABASE indx(zw) ID gc_value-memory.
*
*      IF lt_header_aux IS NOT INITIAL.
*
*        CALL FUNCTION 'ZFMFI_CONTABILIZACAO_MASSA'
*          STARTING NEW TASK 'BACKGROUND_MASS'
*          EXPORTING
*            iv_simular = abap_true.
*
*        APPEND VALUE #( %msg = new_message( id       = gc_value-zfi_contab_fp
*                                            number   = gc_value-number
*                                            severity = CONV #( gc_value-type ) ) ) TO reported-header.
*      ENDIF.
*    ENDIF.

  ENDMETHOD.

  METHOD contabilizar.
    RETURN.
*    DATA: lt_header_aux TYPE TABLE OF zi_fi_contab_cab  WITH DEFAULT KEY,
*          lt_item_aux   TYPE TABLE OF zi_fi_contab_item WITH DEFAULT KEY.
*
*    SELECT *
*    FROM zi_fi_contab_cab
*    WHERE StatusCode = 'S'
*    INTO TABLE @DATA(lt_header).
*
*    IF sy-subrc = 0.
*
*      SELECT *
*      FROM zi_fi_contab_item
*      FOR ALL ENTRIES IN @lt_header
*      WHERE Identificacao = @lt_header-Identificacao
*      AND   Id            = @lt_header-Id
*      INTO TABLE @DATA(lt_item).
*
*      MOVE-CORRESPONDING lt_header TO lt_header_aux.
*      MOVE-CORRESPONDING lt_item   TO lt_item_aux.
*
*      EXPORT  lt_header_aux = lt_header_aux
*              lt_item_aux   = lt_item_aux  TO DATABASE indx(zw) ID gc_value-memory.
*
*      IF lt_header_aux IS NOT INITIAL.
*
*        CALL FUNCTION 'ZFMFI_CONTABILIZACAO_MASSA'
*          STARTING NEW TASK 'BACKGROUND_MASS'.
*
*        APPEND VALUE #( %msg = new_message( id       = gc_value-zfi_contab_fp
*                                            number   = gc_value-number
*                                            severity = CONV #( gc_value-type ) ) ) TO reported-header.
*      ENDIF.
*    ENDIF.
  ENDMETHOD.


ENDCLASS.
