CLASS zclfi_clientes_raiz_cnpj DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    TYPES ty_cnpj_raiz TYPE ze_cpnj_princi .
    TYPES:
      tt_cnpj_raiz TYPE TABLE OF ty_cnpj_raiz .
    TYPES:
      tt_clientes  TYPE TABLE OF ztfi_raiz_cnpj .

    METHODS atualizar_todos_clientes .
*    "!
*    "! @parameter iv_raiz_uuid |
    METHODS atualizar_por_uuid
      IMPORTING
        !iv_raiz_uuid TYPE sysuuid_x16.

*    "!
*    "! @parameter iv_cnpj_raiz |
*    "! @parameter it_cnpj_raiz |
*    "! @raising cx_mdg_missing_input_parameter |
    METHODS atualizar_por_raiz_cnpj
      IMPORTING
        !iv_cnpj_raiz TYPE ty_cnpj_raiz OPTIONAL
        !it_cnpj_raiz TYPE tt_cnpj_raiz OPTIONAL
      RAISING
        cx_mdg_missing_input_parameter .
  PROTECTED SECTION.
  PRIVATE SECTION.
    METHODS atualizar_tabela_clientes IMPORTING !iv_clientes TYPE tt_clientes.
ENDCLASS.



CLASS ZCLFI_CLIENTES_RAIZ_CNPJ IMPLEMENTATION.


  METHOD atualizar_todos_clientes.

    ""Atualiza todos os dados com base da Tabela Raiz.
    SELECT * FROM ztfi_raiz_cnpj INTO TABLE @DATA(lt_raiz).

    ""Será Nescessario manter as informações de UUID.
    IF sy-subrc IS INITIAL.

      me->atualizar_tabela_clientes( iv_clientes = lt_raiz ).

    ENDIF.

  ENDMETHOD.


  METHOD atualizar_por_raiz_cnpj.

    DATA lt_cnpjs TYPE me->tt_cnpj_raiz.

    IF iv_cnpj_raiz IS SUPPLIED.
      APPEND  iv_cnpj_raiz TO lt_cnpjs.
    ENDIF.
    IF it_cnpj_raiz IS SUPPLIED.
      APPEND LINES OF it_cnpj_raiz TO lt_cnpjs.
    ENDIF.

    IF lt_cnpjs IS NOT INITIAL.

      ""Atualiza todos os dados com base da Tabela Raiz.
      SELECT * FROM ztfi_raiz_cnpj INTO TABLE @DATA(lt_raiz)
               FOR ALL ENTRIES IN @lt_cnpjs
               WHERE cnpj_raiz = @lt_cnpjs-table_line.

      ""Será Nescessario manter as informações de UUID.
      IF sy-subrc IS INITIAL.

        me->atualizar_tabela_clientes( iv_clientes = lt_raiz ).

      ENDIF.

    ELSE.

      RAISE EXCEPTION TYPE cx_mdg_missing_input_parameter .

    ENDIF.

  ENDMETHOD.


  METHOD atualizar_tabela_clientes.

    DATA lt_cnpj TYPE TABLE OF ztfi_cnpj_client.
    TYPES ty_range TYPE RANGE OF char8.

    DATA(lt_clientes) = iv_clientes.

    SORT lt_clientes ASCENDING.
    DELETE ADJACENT DUPLICATES FROM lt_clientes.

    DATA(lr_range_raiz) = VALUE ty_range( FOR ls_clientes IN lt_clientes (
                                      sign   = 'I'
                                      option = 'EQ'
                                      low =  ls_clientes-cnpj_raiz(8)
                                      high = '')
                                 ).
    IF lt_clientes[] IS NOT INITIAL.

    SELECT name1, stcd1
    FROM kna1
    INTO TABLE  @DATA(lt_nome)
    FOR ALL ENTRIES IN @lt_clientes
    WHERE stcd1 = @lt_clientes-cnpj_raiz.

    ENDIF.

    IF sy-subrc IS INITIAL.

      SORT lt_nome BY stcd1. " Binary search

    ENDIF.


    SELECT * FROM zi_fi_taxnumber
            WHERE raizsub IN @lr_range_raiz
            INTO TABLE @DATA(lt_taxnumber).

      IF sy-subrc IS INITIAL.

        LOOP AT lt_taxnumber ASSIGNING FIELD-SYMBOL(<fs_taxnumber>).

          LOOP AT iv_clientes INTO DATA(ls_raiz) WHERE cnpj_raiz(8) = <fs_taxnumber>-raizsub.

            APPEND INITIAL LINE TO lt_cnpj ASSIGNING FIELD-SYMBOL(<fs_cnpj>).
            <fs_cnpj>-doc_uuid_h        = ls_raiz-doc_uuid_h.
            <fs_cnpj>-doc_uuid_raiz     = ls_raiz-doc_uuid_raiz.
            <fs_cnpj>-contrato          = ls_raiz-contrato.
            <fs_cnpj>-aditivo           = ls_raiz-aditivo.
            <fs_cnpj>-cnpj_raiz         = ls_raiz-cnpj_raiz.
            <fs_cnpj>-cliente           = <fs_taxnumber>-businesspartner.

            READ TABLE lt_nome ASSIGNING FIELD-SYMBOL(<fs_nome>) WITH KEY stcd1 = ls_raiz-cnpj_raiz
                                                                 BINARY SEARCH.
            IF sy-subrc IS INITIAL.
              <fs_cnpj>-cnpj = <fs_nome>-stcd1.
              <fs_cnpj>-nome1 =  <fs_nome>-name1.

            ENDIF.


            ""TimeStamp Gang.
            GET TIME STAMP FIELD DATA(lv_ts) .

            <fs_cnpj>-created_by = sy-uname.
            <fs_cnpj>-created_at = lv_ts.

            <fs_cnpj>-last_changed_by = sy-uname.
            <fs_cnpj>-last_changed_at = lv_ts.
            <fs_cnpj>-local_last_changed_at = lv_ts.

          ENDLOOP.

        ENDLOOP.

        IF lt_cnpj IS NOT INITIAL.
          MODIFY ztfi_cnpj_client FROM TABLE lt_cnpj.
          COMMIT WORK AND WAIT.
        ENDIF.

      ENDIF.

    ENDMETHOD.


  METHOD atualizar_por_uuid.

    DATA lt_cnpjs TYPE me->tt_cnpj_raiz.


      SELECT * FROM ztfi_raiz_cnpj INTO TABLE @DATA(lt_raiz)
               WHERE doc_uuid_raiz = @iv_raiz_uuid.

      ""Será Nescessario manter as informações de UUID.
      IF sy-subrc IS INITIAL.

        me->atualizar_tabela_clientes( iv_clientes = lt_raiz ).

      ENDIF.

  ENDMETHOD.
ENDCLASS.
