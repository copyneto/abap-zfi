CLASS zclfi_atualiza_contrato_anexo DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    METHODS atualiza_campo
      IMPORTING
        !iv_anexo  TYPE ze_tipo_anexo
        !iv_uuid   TYPE sysuuid_x16
      EXPORTING
        !et_return TYPE bapiret2_t .
  PROTECTED SECTION.
  PRIVATE SECTION.

    METHODS salva_tabela
      IMPORTING
        !is_contrato TYPE ztfi_contrato
      EXPORTING
        !et_return   TYPE bapiret2_t .
ENDCLASS.



CLASS zclfi_atualiza_contrato_anexo IMPLEMENTATION.


  METHOD atualiza_campo.

    TYPES: BEGIN OF ty_tp,
             tp TYPE char50,
           END OF ty_tp.

    DATA: lt_tp TYPE TABLE OF ty_tp.

    DATA: lv_campo1 TYPE ze_status_anexo,
          lv_campo2 TYPE ze_status_anexo,
          lv_campo3 TYPE ze_status_anexo,
          lv_campo4 TYPE ze_status_anexo,
          lv_anexo  TYPE ze_status_anexo.

    SELECT SINGLE *
      FROM ztfi_contrato
      INTO @DATA(ls_anexo)
      WHERE doc_uuid_h = @iv_uuid.

*    SELECT doc_uuid_h status_anexo
*      FROM ztfi_contrato
*      INTO TABLE @DATA(lt_anexo)
*      WHERE doc_uuid_h = @iv_uuid.

    IF sy-subrc IS INITIAL.

      SELECT COUNT( * )
      FROM ztfi_cont_anexo
      WHERE doc_uuid_h = @ls_anexo-doc_uuid_h
      AND   tipo_doc   = @iv_anexo.

      IF sy-dbcnt < 1.

        SPLIT ls_anexo-status_anexo AT '-' INTO lv_campo1 lv_campo2 lv_campo3 lv_campo4.

        CASE iv_anexo.
          WHEN '1'.
            lv_anexo = 'Contrato Assinado'.
          WHEN '2'.
            lv_anexo = 'Minuta'.
          WHEN '3'.
            lv_anexo = 'Outros'.
          WHEN '4'.
            lv_anexo = 'Parecer'.
        ENDCASE.

        APPEND VALUE #( tp = lv_campo1 ) TO lt_tp.
        APPEND VALUE #( tp = lv_campo2 ) TO lt_tp.
        APPEND VALUE #( tp = lv_campo3 ) TO lt_tp.
        APPEND VALUE #( tp = lv_campo4 ) TO lt_tp.
*        APPEND VALUE #( tp = lv_anexo )  TO lt_tp.

        SORT lt_tp BY tp.
        DELETE ADJACENT DUPLICATES FROM lt_tp COMPARING tp.
        DELETE lt_tp WHERE tp = lv_anexo. "#EC CI_STDSEQ
        DELETE lt_tp WHERE tp IS INITIAL. "#EC CI_STDSEQ

        LOOP AT lt_tp ASSIGNING FIELD-SYMBOL(<fs_tp>).
          IF sy-tabix = 1.
            ls_anexo-status_anexo = <fs_tp>-tp.
          ELSE.
            ls_anexo-status_anexo = |{ ls_anexo-status_anexo }-{ <fs_tp>-tp }|.
          ENDIF.
        ENDLOOP.

*        IF lv_campo1 CS lv_anexo.
*          IF lv_campo3 IS INITIAL AND
*             lv_campo2 IS NOT INITIAL.
*            ls_anexo-status_anexo = lv_campo2.
*          ELSEIF lv_campo3 IS NOT INITIAL AND
*                  lv_campo2 IS NOT INITIAL.
*            ls_anexo-status_anexo = lv_campo2 && '-' && lv_campo3.
*          ELSE.
*            ls_anexo-status_anexo = space.
*          ENDIF.
*
*        ELSEIF lv_campo2 CS lv_anexo.
*          IF lv_campo3 IS INITIAL AND
*             lv_campo1 IS NOT INITIAL.
*            ls_anexo-status_anexo = lv_campo1.
*          ELSEIF lv_campo3 IS NOT INITIAL AND
*                  lv_campo1 IS NOT INITIAL.
*            ls_anexo-status_anexo = lv_campo1 && '-' && lv_campo3.
*          ELSE.
*            ls_anexo-status_anexo = space.
*          ENDIF.
*
*        ELSEIF lv_campo3 CS lv_anexo.
*          IF lv_campo2 IS INITIAL AND
*             lv_campo1 IS NOT INITIAL.
*            ls_anexo-status_anexo = lv_campo1.
*          ELSEIF lv_campo2 IS NOT INITIAL AND
*                  lv_campo1 IS NOT INITIAL.
*            ls_anexo-status_anexo = lv_campo1 && '-' && lv_campo2.
*          ELSE.
*            ls_anexo-status_anexo = space.
*          ENDIF.
*        ENDIF.

        me->salva_tabela(
         EXPORTING
             is_contrato = ls_anexo
        IMPORTING
          et_return = et_return ).
      ENDIF.
    ENDIF.

    IF et_return IS INITIAL.
      et_return[] = VALUE #( BASE et_return ( type = 'S' id = 'ZFI_CARGA_CONTRATO' number = '008' ) ).
      RETURN.
    ENDIF.

  ENDMETHOD.


  METHOD salva_tabela.

    MODIFY ztfi_contrato FROM is_contrato.
    COMMIT WORK AND WAIT.

    IF sy-subrc NE 0.
      " Falha ao atualizae dados na tabela.
      et_return[] = VALUE #( BASE et_return ( type = 'E' id = 'ZFI_CARGA_CONTRATO' number = '008' ) ).
      RETURN.
    ENDIF.

  ENDMETHOD.
ENDCLASS.
