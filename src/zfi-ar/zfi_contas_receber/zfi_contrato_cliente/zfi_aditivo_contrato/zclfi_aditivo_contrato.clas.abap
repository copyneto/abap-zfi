"! Classe utilitária para execução do aditivo
CLASS zclfi_aditivo_contrato DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    "! Variavel com o campo aditivo calculo
    DATA gv_qtd_aditivo TYPE ze_num_aditivo .
    "! Variavel com o GUID novo gerado
    DATA gv_guid_h TYPE sysuuid_x16 .

    "! Método publico para execução do aditivo
    METHODS executa
      IMPORTING
        !iv_doc_uuid_h TYPE ztfi_contrato-doc_uuid_h
      EXPORTING
        !et_return     TYPE bapiret2_tab .
  PROTECTED SECTION.
  PRIVATE SECTION.

    METHODS janela_contrato
      IMPORTING
        !is_contrato TYPE ztfi_contrato .
    "! Método para calculo o valor do campo aditivo
    METHODS check_qtd_aditivo
      IMPORTING
        !is_contrato TYPE ztfi_contrato .
    "! Método para copiar os dados para o novo contrato
    METHODS copiar_dados_contrato
      IMPORTING
        !is_contrato TYPE ztfi_contrato .
    "! Método para gerar os raiz cnpjs para o novo contrato
    METHODS atualiza_raiz_cnpj
      IMPORTING
        !is_contrato TYPE ztfi_contrato .
    "! Método para copiar os anexos para o novo contrato
    METHODS atualiza_anexos
      IMPORTING
        !is_contrato TYPE ztfi_contrato .
    "! Método para copiar as condições para o novo contrato
    METHODS atualiza_condicoes
      IMPORTING
        !is_contrato TYPE ztfi_contrato .
    "! Método para criar o novo contrato e GUID
    METHODS novo_contrato
      IMPORTING
        !is_contrato TYPE ztfi_contrato .
    "! Método para atualizar status do antigo contrato e encerrar
    METHODS encerra_contrato
      IMPORTING
        !is_contrato TYPE ztfi_contrato .
ENDCLASS.



CLASS zclfi_aditivo_contrato IMPLEMENTATION.


  METHOD executa.

    SELECT SINGLE *
    FROM ztfi_contrato
    INTO @DATA(ls_contrato)
    WHERE doc_uuid_h = @iv_doc_uuid_h.

    IF sy-subrc = 0.

      check_qtd_aditivo( ls_contrato ).

      copiar_dados_contrato( ls_contrato ).

      "Contrato cliente aditivado: &1
      et_return = VALUE #( ( id = 'ZFI_CONTRATO_CLIENTE'
                             type = 'S'
                             number = '001'
                             message_v1 = gv_qtd_aditivo ) ).
    ENDIF.


  ENDMETHOD.


  METHOD check_qtd_aditivo.

    CLEAR: gv_qtd_aditivo.

    SELECT COUNT(*)
        FROM ztfi_contrato
        WHERE contrato = is_contrato-contrato.

    gv_qtd_aditivo = is_contrato-contrato && '-' && sy-dbcnt.
    CONDENSE gv_qtd_aditivo NO-GAPS.


  ENDMETHOD.


  METHOD copiar_dados_contrato.

    "@@ Novo Contrato
    novo_contrato( is_contrato ).

    "@@ Encerrar Contrato
    encerra_contrato( is_contrato ).

    "@@ Raiz CNPJ
    atualiza_raiz_cnpj( is_contrato ).

    "@@ Anexos
*    atualiza_anexos( is_contrato ).

    "@@ Condições
    atualiza_condicoes( is_contrato ).

    "@@ Janela
    janela_contrato( is_contrato ).

    COMMIT WORK AND WAIT.

  ENDMETHOD.


  METHOD atualiza_raiz_cnpj.

    "@@ Raiz CNPJ
    SELECT * FROM ztfi_raiz_cnpj INTO TABLE @DATA(lt_cnpj_raiz) WHERE doc_uuid_h = @is_contrato-doc_uuid_h.
    IF sy-subrc = 0.

      LOOP AT lt_cnpj_raiz ASSIGNING FIELD-SYMBOL(<fs_cnpj_raiz>).
        TRY.
            <fs_cnpj_raiz>-doc_uuid_h = gv_guid_h.
            <fs_cnpj_raiz>-aditivo = gv_qtd_aditivo.
          CATCH cx_uuid_error.
            "handle exception
        ENDTRY.
      ENDLOOP.

      MODIFY ztfi_raiz_cnpj FROM TABLE lt_cnpj_raiz.
    ENDIF.

  ENDMETHOD.


  METHOD atualiza_anexos.

    SELECT * FROM ztfi_cont_anexo INTO TABLE @DATA(lt_anexo) WHERE doc_uuid_h = @is_contrato-doc_uuid_h.
    IF sy-subrc = 0.

      LOOP AT lt_anexo ASSIGNING FIELD-SYMBOL(<fs_anexo>).
        TRY.
            <fs_anexo>-doc_uuid_h = gv_guid_h.
            <fs_anexo>-aditivo = gv_qtd_aditivo.
          CATCH cx_uuid_error.
            "handle exception
        ENDTRY.
      ENDLOOP.

      MODIFY ztfi_cont_anexo FROM TABLE lt_anexo.
    ENDIF.

  ENDMETHOD.


  METHOD atualiza_condicoes.

    SELECT * FROM ztfi_cont_cond INTO TABLE @DATA(lt_cond) WHERE doc_uuid_h = @is_contrato-doc_uuid_h.
    IF sy-subrc = 0.

      LOOP AT lt_cond ASSIGNING FIELD-SYMBOL(<fs_cond>).
        TRY.
            <fs_cond>-doc_uuid_h = gv_guid_h.
            <fs_cond>-aditivo = gv_qtd_aditivo.
          CATCH cx_uuid_error.
            "handle exception
        ENDTRY.
      ENDLOOP.

      MODIFY ztfi_cont_cond FROM TABLE lt_cond.
    ENDIF.

  ENDMETHOD.


  METHOD novo_contrato.

    CLEAR: gv_guid_h.

    DATA(ls_novo_contrato) = CORRESPONDING ztfi_contrato( is_contrato ) .

    TRY.
        ls_novo_contrato-doc_uuid_h = gv_guid_h = cl_system_uuid=>create_uuid_c32_static( ).
        ls_novo_contrato-aditivo = gv_qtd_aditivo.
        ls_novo_contrato-status = '1'.

        ls_novo_contrato-created_by  = sy-uname.
        GET TIME STAMP FIELD ls_novo_contrato-created_at.

        CLEAR: ls_novo_contrato-last_changed_by,
               ls_novo_contrato-local_last_changed_at,
               ls_novo_contrato-last_changed_at,
               ls_novo_contrato-observacao,
               ls_novo_contrato-aprov1,
               ls_novo_contrato-aprov2,
               ls_novo_contrato-aprov3,
               ls_novo_contrato-aprov4,
               ls_novo_contrato-aprov5,
               ls_novo_contrato-aprov6,
               ls_novo_contrato-aprov7,
               ls_novo_contrato-aprov8,
               ls_novo_contrato-aprov9,
               ls_novo_contrato-dataaprov1,
               ls_novo_contrato-dataaprov2,
               ls_novo_contrato-dataaprov3,
               ls_novo_contrato-dataaprov4,
               ls_novo_contrato-dataaprov5,
               ls_novo_contrato-dataaprov6,
               ls_novo_contrato-dataaprov7,
               ls_novo_contrato-dataaprov8,
               ls_novo_contrato-dataaprov9,
               ls_novo_contrato-dataaprov10,
               ls_novo_contrato-hora_aprov1,
               ls_novo_contrato-hora_aprov2,
               ls_novo_contrato-hora_aprov3,
               ls_novo_contrato-hora_aprov4,
               ls_novo_contrato-hora_aprov5,
               ls_novo_contrato-hora_aprov6,
               ls_novo_contrato-hora_aprov7,
               ls_novo_contrato-hora_aprov8,
               ls_novo_contrato-hora_aprov9,
               ls_novo_contrato-hora_aprov10,
               ls_novo_contrato-last_changed_by,
               ls_novo_contrato-status_anexo.

      CATCH cx_uuid_error.
        "handle exception
    ENDTRY.

    MODIFY ztfi_contrato FROM ls_novo_contrato.

  ENDMETHOD.


  METHOD encerra_contrato.

    UPDATE ztfi_contrato SET status = '7' "aditivado
                  WHERE doc_uuid_h = is_contrato-doc_uuid_h.

  ENDMETHOD.


  METHOD janela_contrato.

    SELECT * FROM ztfi_cont_janela INTO TABLE @DATA(lt_janela) WHERE doc_uuid_h = @is_contrato-doc_uuid_h.
    IF sy-subrc = 0.

      LOOP AT lt_janela ASSIGNING FIELD-SYMBOL(<fs_janela>).
        TRY.
            <fs_janela>-doc_uuid_h = gv_guid_h.
            <fs_janela>-aditivo = gv_qtd_aditivo.
          CATCH cx_uuid_error.
            "handle exception
        ENDTRY.
      ENDLOOP.

      MODIFY ztfi_cont_janela FROM TABLE lt_janela.
    ENDIF.


  ENDMETHOD.
ENDCLASS.
