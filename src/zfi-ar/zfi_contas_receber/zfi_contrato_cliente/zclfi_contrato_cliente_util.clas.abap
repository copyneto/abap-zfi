CLASS zclfi_contrato_cliente_util DEFINITION INHERITING FROM cl_abap_behv
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    TYPES:
      ty_reported          TYPE RESPONSE FOR REPORTED EARLY zi_fi_contrato.

    "! Desativar contrato
    "! @parameter iv_doc_uuid | UUID do Contrato
    METHODS desativar
      IMPORTING
        iv_doc_uuid TYPE sysuuid_x16.

    "! Valida campos de contrato de cliente
    "! @parameter is_contrato | Contrato
    "! @parameter et_return | Mensagens de retorno
    METHODS valida_contrato
      IMPORTING is_contrato TYPE zi_fi_contrato
      EXPORTING et_return   TYPE bapiret2_t.

    "! Valida campos de Cnpj Raiz
    "! @parameter is_raiz | Cnpj Raiz
    "! @parameter et_return | Mensagens de retorno
    METHODS valida_raiz
      IMPORTING is_raiz   TYPE zi_fi_raiz_cnpj_cont
      EXPORTING et_return TYPE bapiret2_t.

    "! Valida campos de Condições Desconto
    "! @parameter is_cond | Condições Desconto
    "! @parameter et_return | Mensagens de retorno
    METHODS valida_cond
      IMPORTING is_cond   TYPE zi_fi_cond_cont
      EXPORTING et_return TYPE bapiret2_t.

    "! Valida campos de Provisão
    "! @parameter is_prov | Provisão
    "! @parameter et_return | Mensagens de retorno
    METHODS valida_prov
      IMPORTING is_prov   TYPE zi_fi_prov_cont
      EXPORTING et_return TYPE bapiret2_t.

    "! Valida campos da Familias da Provisão
    "! @parameter is_familia | Familias da Provisão
    "! @parameter et_return | Mensagens de retorno
    METHODS valida_prov_familia
      IMPORTING is_familia TYPE zi_fi_prov_familia
      EXPORTING et_return  TYPE bapiret2_t.

    "! Valida campos de Janela
    "! @parameter is_janela | Janela do Contrato
    "! @parameter et_return | Mensagens de retorno
    METHODS valida_janela
      IMPORTING is_janela TYPE zi_fi_janela_cont
      EXPORTING et_return TYPE bapiret2_t.

    "! Constrói mensagens retorno do aplicativo
    "! @parameter it_return | Mensagens de retorno
    "! @parameter es_reported | Retorno do aplicativo
    METHODS reported
      IMPORTING it_return   TYPE bapiret2_t
      EXPORTING es_reported TYPE ty_reported.

  PROTECTED SECTION.

  PRIVATE SECTION.

ENDCLASS.



CLASS zclfi_contrato_cliente_util IMPLEMENTATION.


  METHOD desativar.

    DATA: lv_ts TYPE timestampl.

    GET TIME STAMP FIELD lv_ts.

    UPDATE ztfi_contrato SET status                 = '6' "Desativar
                             desativado             = abap_true
                             last_changed_by        = sy-uname
                             last_changed_at        = lv_ts
                             local_last_changed_at  = lv_ts
                       WHERE doc_uuid_h             = iv_doc_uuid.

    COMMIT WORK.

  ENDMETHOD.


  METHOD valida_contrato.

    FREE: et_return.

* ---------------------------------------------------------------------------
* Valida campos
* ---------------------------------------------------------------------------
    IF is_contrato-cnpjprincipal IS INITIAL.

      " Preencher todos os campos obrigatórios.
      et_return = VALUE #( BASE et_return ( parameter   = gc_cds-contrato
                                            field       = 'CNPJPRINCIPAL'
                                            type        = 'E'
                                            id          = 'ZFI_CONTRATO_CLIENTE'
                                            number      = '000' ) ).
    ENDIF.

    IF is_contrato-razaosocial IS INITIAL.

      " Preencher todos os campos obrigatórios.
      et_return = VALUE #( BASE et_return ( parameter   = gc_cds-contrato
                                            field       = 'RAZAOSOCIAL'
                                            type        = 'E'
                                            id          = 'ZFI_CONTRATO_CLIENTE'
                                            number      = '000' ) ).
    ENDIF.

    IF is_contrato-nomefantasia IS INITIAL.

      " Preencher todos os campos obrigatórios.
      et_return = VALUE #( BASE et_return ( parameter   = gc_cds-contrato
                                            field       = 'NOMEFANTASIA'
                                            type        = 'E'
                                            id          = 'ZFI_CONTRATO_CLIENTE'
                                            number      = '000' ) ).
    ENDIF.

    IF is_contrato-renovaut IS INITIAL AND is_contrato-alertavig IS INITIAL.

      "&1 &2 sem renovação automática, acionar Alerta de Vigência.
      et_return = VALUE #( BASE et_return ( parameter   = gc_cds-contrato
                                            field       = 'ALERTAVIG'
                                            type        = 'E'
                                            id          = 'ZFI_CONTRATO_CLIENTE'
                                            number      = '044'
                                            message_v1 = is_contrato-contrato
                                            message_v2 = is_contrato-aditivo ) ).
    ENDIF.

    IF is_contrato-renovaut IS NOT INITIAL AND is_contrato-alertavig IS NOT INITIAL.

      "&1 &2 com renovação automática, não acionar Alerta de vigência
      et_return = VALUE #( BASE et_return ( parameter   = gc_cds-contrato
                                            field       = 'ALERTAVIG'
                                            type        = 'E'
                                            id          = 'ZFI_CONTRATO_CLIENTE'
                                            number      = '045'
                                            message_v1 = is_contrato-contrato
                                            message_v2 = is_contrato-aditivo ) ).
    ENDIF.


  ENDMETHOD.


  METHOD valida_raiz.

    FREE: et_return.

* ---------------------------------------------------------------------------
* Verifica se o registro atual foi duplicado
* ---------------------------------------------------------------------------
    IF is_raiz-cnpjraiz IS NOT INITIAL.

      SELECT COUNT(*)
          FROM ztfi_raiz_cnpj
          WHERE doc_uuid_h    EQ is_raiz-docuuidh
            AND doc_uuid_raiz NE is_raiz-docuuidraiz
            AND cnpj_raiz     EQ is_raiz-cnpjraiz.

      IF sy-subrc EQ 0.
        " Já existe linha cadastrada com a mesma chave.
        et_return = VALUE #( BASE et_return ( parameter   = gc_cds-raiz
                                              field       = 'CNPJRAIZ'
                                              type        = 'E'
                                              id          = 'ZFI_CONTRATO_CLIENTE'
                                              number      = '040' ) ).
      ENDIF.
    ENDIF.

* ---------------------------------------------------------------------------
* Valida campos
* ---------------------------------------------------------------------------
    IF is_raiz-cnpjraiz IS INITIAL.

      " Preencher todos os campos obrigatórios.
      et_return = VALUE #( BASE et_return ( parameter   = gc_cds-raiz
                                            field       = 'CNPJRAIZ'
                                            type        = 'E'
                                            id          = 'ZFI_CONTRATO_CLIENTE'
                                            number      = '000' ) ).
    ENDIF.

  ENDMETHOD.


  METHOD valida_cond.

    FREE: et_return.

* ---------------------------------------------------------------------------
* Verifica se o registro atual foi duplicado
* ---------------------------------------------------------------------------
    IF is_cond-tipocond IS NOT INITIAL.

      SELECT COUNT(*)
          FROM ztfi_cont_cond
          WHERE doc_uuid_h    EQ is_cond-docuuidh
            AND doc_uuid_cond NE is_cond-docuuidcond
            AND tipo_cond     EQ is_cond-tipocond.

      IF sy-subrc EQ 0.
        " Já existe linha cadastrada com a mesma chave.
        et_return = VALUE #( BASE et_return ( parameter   = gc_cds-cond
                                              field       = 'TIPOCOND'
                                              type        = 'E'
                                              id          = 'ZFI_CONTRATO_CLIENTE'
                                              number      = '040' ) ).
      ENDIF.
    ENDIF.

* ---------------------------------------------------------------------------
* Valida campos
* ---------------------------------------------------------------------------
    IF is_cond-tipocond IS INITIAL.

      " Preencher todos os campos obrigatórios.
      et_return = VALUE #( BASE et_return ( parameter   = gc_cds-cond
                                            field       = 'TIPOCOND'
                                            type        = 'E'
                                            id          = 'ZFI_CONTRATO_CLIENTE'
                                            number      = '000' ) ).
    ENDIF.

    IF is_cond-aplicacao IS INITIAL.

      " Preencher todos os campos obrigatórios.
      et_return = VALUE #( BASE et_return ( parameter   = gc_cds-cond
                                            field       = 'APLICACAO'
                                            type        = 'E'
                                            id          = 'ZFI_CONTRATO_CLIENTE'
                                            number      = '000' ) ).
    ENDIF.

    IF ( is_cond-percentual IS NOT INITIAL AND is_cond-montante IS NOT INITIAL )
    OR ( is_cond-percentual IS INITIAL AND is_cond-montante IS INITIAL ).

      " Obrigatório preencher apenas uma das informações: percentual ou montante.
      et_return = VALUE #( BASE et_return ( parameter   = gc_cds-cond
                                            field       = 'PERCENTUAL'
                                            type        = 'E'
                                            id          = 'ZFI_CONTRATO_CLIENTE'
                                            number      = '041' ) ).

      " Obrigatório preencher apenas uma das informações: percentual ou montante.
      et_return = VALUE #( BASE et_return ( parameter   = gc_cds-cond
                                            field       = 'MONTANTE'
                                            type        = 'E'
                                            id          = 'ZFI_CONTRATO_CLIENTE'
                                            number      = '041' ) ).

    ENDIF.

  ENDMETHOD.


  METHOD valida_prov.

    FREE: et_return.

* ---------------------------------------------------------------------------
* Valida campos
* ---------------------------------------------------------------------------
    IF is_prov-tipodesconto IS INITIAL.

      " Preencher todos os campos obrigatórios.
      et_return = VALUE #( BASE et_return ( parameter   = gc_cds-prov
                                            field       = 'TIPODESCONTO'
                                            type        = 'E'
                                            id          = 'ZFI_CONTRATO_CLIENTE'
                                            number      = '000' ) ).
    ENDIF.

    IF is_prov-aplicadesconto IS INITIAL.

      " Preencher todos os campos obrigatórios.
      et_return = VALUE #( BASE et_return ( parameter   = gc_cds-prov
                                            field       = 'APLICADESCONTO'
                                            type        = 'E'
                                            id          = 'ZFI_CONTRATO_CLIENTE'
                                            number      = '000' ) ).
    ENDIF.

    IF is_prov-conddesconto IS INITIAL.

      " Preencher todos os campos obrigatórios.
      et_return = VALUE #( BASE et_return ( parameter   = gc_cds-prov
                                            field       = 'CONDDESCONTO'
                                            type        = 'E'
                                            id          = 'ZFI_CONTRATO_CLIENTE'
                                            number      = '000' ) ).
    ENDIF.

    IF is_prov-tipoapuracao IS INITIAL.

      " Preencher todos os campos obrigatórios.
      et_return = VALUE #( BASE et_return ( parameter   = gc_cds-prov
                                            field       = 'TIPOAPURACAO'
                                            type        = 'E'
                                            id          = 'ZFI_CONTRATO_CLIENTE'
                                            number      = '000' ) ).
    ENDIF.

    IF is_prov-percconddesc IS INITIAL.

      " Preencher todos os campos obrigatórios.
      et_return = VALUE #( BASE et_return ( parameter   = gc_cds-prov
                                            field       = 'PERCCONDDESC'
                                            type        = 'E'
                                            id          = 'ZFI_CONTRATO_CLIENTE'
                                            number      = '000' ) ).
    ENDIF.

    IF is_prov-tipoapimposto IS INITIAL.

      " Preencher todos os campos obrigatórios.
      et_return = VALUE #( BASE et_return ( parameter   = gc_cds-prov
                                            field       = 'TIPOAPIMPOSTO'
                                            type        = 'E'
                                            id          = 'ZFI_CONTRATO_CLIENTE'
                                            number      = '000' ) ).
    ENDIF.

    IF is_prov-mesvigencia IS INITIAL AND is_prov-recoanualdesc IS NOT INITIAL .

      " Não é possível marcar Recorrência anual com Período de Vigência informado
      et_return = VALUE #( BASE et_return ( parameter   = gc_cds-prov
                                            field       = 'RECOANUALDESC'
                                            type        = 'E'
                                            id          = 'ZFI_CONTRATO_CLIENTE'
                                            number      = '042' ) ).

    ENDIF.

  ENDMETHOD.


  METHOD valida_prov_familia.

    FREE: et_return.

* ---------------------------------------------------------------------------
* Valida campos
* ---------------------------------------------------------------------------
    IF is_familia-familia IS INITIAL.

      " Preencher todos os campos obrigatórios.
      et_return = VALUE #( BASE et_return ( parameter   = gc_cds-prov_familia
                                            field       = 'FAMILIA'
                                            type        = 'E'
                                            id          = 'ZFI_CONTRATO_CLIENTE'
                                            number      = '000' ) ).
    ENDIF.

  ENDMETHOD.


  METHOD valida_janela.

    FREE: et_return.

* ---------------------------------------------------------------------------
* Verifica se o registro atual foi duplicado
* ---------------------------------------------------------------------------
    IF is_janela-grpcond IS NOT INITIAL.

      SELECT COUNT(*)
          FROM ztfi_cont_janela
          WHERE doc_uuid_h      EQ is_janela-docuuidh
            AND doc_uuid_janela NE is_janela-docuuidjanela
            AND grp_cond        EQ is_janela-grpcond
            AND atributo_2      EQ is_janela-atributo2
            AND familia_cl      EQ is_janela-familiacl.

      IF sy-subrc EQ 0.
        " Já existe linha cadastrada com a mesma chave.
        et_return = VALUE #( BASE et_return ( parameter   = gc_cds-janela
                                              field       = 'GRPCOND'
                                              type        = 'E'
                                              id          = 'ZFI_CONTRATO_CLIENTE'
                                              number      = '040' ) ).
      ENDIF.
    ENDIF.

* ---------------------------------------------------------------------------
* Valida campos
* ---------------------------------------------------------------------------
    IF is_janela-grpcond IS INITIAL.

      " Preencher todos os campos obrigatórios.
      et_return = VALUE #( BASE et_return ( parameter   = gc_cds-janela
                                            field       = 'GRPCOND'
                                            type        = 'E'
                                            id          = 'ZFI_CONTRATO_CLIENTE'
                                            number      = '000' ) ).
    ENDIF.

    IF is_janela-prazo IS INITIAL.

      " Preencher todos os campos obrigatórios.
      et_return = VALUE #( BASE et_return ( parameter   = gc_cds-janela
                                            field       = 'PRAZO'
                                            type        = 'E'
                                            id          = 'ZFI_CONTRATO_CLIENTE'
                                            number      = '000' ) ).
    ENDIF.


    IF  is_janela-diasemana  IS NOT INITIAL
    AND is_janela-diamesfixo IS NOT INITIAL.

      " Somente é posível gravar dia da Semana ou Mês fixo.
      et_return = VALUE #( BASE et_return ( parameter   = gc_cds-janela
                                            field       = 'DIASEMANA'
                                            type        = 'E'
                                            id          = 'ZFI_CONTRATO_CLIENTE'
                                            number      = '038' ) ).

      " Somente é posível gravar dia da Semana ou Mês fixo.
      et_return = VALUE #( BASE et_return ( parameter   = gc_cds-janela
                                            field       = 'DIAMESFIXO'
                                            type        = 'E'
                                            id          = 'ZFI_CONTRATO_CLIENTE'
                                            number      = '038' ) ).
    ENDIF.

  ENDMETHOD.


  METHOD reported.

    DATA: lo_dataref      TYPE REF TO data,
          ls_contrato     TYPE zi_fi_contrato,
          ls_raiz         TYPE zi_fi_raiz_cnpj_cont,
          ls_cliente      TYPE zi_fi_clientes_cont,
          ls_anexo        TYPE zi_fi_anexos,
          ls_cond         TYPE zi_fi_cond_cont,
          ls_janela       TYPE zi_fi_janela_cont,
          ls_prov         TYPE zi_fi_prov_cont,
          ls_prov_familia TYPE zi_fi_prov_familia,
          ls_aprovadores  TYPE zi_fi_niveis_aprov_contrato.

    FIELD-SYMBOLS: <fs_cds>  TYPE any.

    FREE: es_reported.

    LOOP AT it_return INTO DATA(ls_return).

* ---------------------------------------------------------------------------
* Determina tipo de estrutura CDS
* ---------------------------------------------------------------------------
      CASE ls_return-parameter.
        WHEN gc_cds-contrato.
          CREATE DATA lo_dataref TYPE LINE OF ty_reported-_contrato.
        WHEN gc_cds-raiz.
          CREATE DATA lo_dataref TYPE LINE OF ty_reported-_raiz.
        WHEN gc_cds-cliente.
          CREATE DATA lo_dataref TYPE LINE OF ty_reported-_cliente.
        WHEN gc_cds-anexo.
          CREATE DATA lo_dataref TYPE LINE OF ty_reported-_anexos.
        WHEN gc_cds-cond.
          CREATE DATA lo_dataref TYPE LINE OF ty_reported-_cond.
        WHEN gc_cds-janela.
          CREATE DATA lo_dataref TYPE LINE OF ty_reported-_janela.
        WHEN gc_cds-prov.
          CREATE DATA lo_dataref TYPE LINE OF ty_reported-_prov.
        WHEN gc_cds-prov_familia.
          CREATE DATA lo_dataref TYPE LINE OF ty_reported-_provfamilia.
        WHEN gc_cds-aprovadores.
          CREATE DATA lo_dataref TYPE LINE OF ty_reported-_aprovadores.
        WHEN OTHERS.
          CREATE DATA lo_dataref TYPE LINE OF ty_reported-_contrato.
      ENDCASE.

      ASSIGN lo_dataref->* TO <fs_cds>.

* ---------------------------------------------------------------------------
* Converte mensagem
* ---------------------------------------------------------------------------
      ASSIGN COMPONENT '%msg' OF STRUCTURE <fs_cds> TO FIELD-SYMBOL(<fs_msg>).

      IF sy-subrc EQ 0.
        TRY.
            <fs_msg>  = new_message( id       = ls_return-id
                                     number   = ls_return-number
                                     v1       = ls_return-message_v1
                                     v2       = ls_return-message_v2
                                     v3       = ls_return-message_v3
                                     v4       = ls_return-message_v4
                                     severity = CONV #( ls_return-type ) ).
          CATCH cx_root.
        ENDTRY.
      ENDIF.

* ---------------------------------------------------------------------------
* Marca o campo com erro
* ---------------------------------------------------------------------------
      IF ls_return-field IS NOT INITIAL.
        ASSIGN COMPONENT |%element-{ ls_return-field }| OF STRUCTURE <fs_cds> TO FIELD-SYMBOL(<fs_field>).

        IF sy-subrc EQ 0.
          TRY.
              <fs_field> = if_abap_behv=>mk-on.
            CATCH cx_root.
          ENDTRY.
        ENDIF.
      ENDIF.

* ---------------------------------------------------------------------------
* Adiciona o erro na CDS correspondente
* ---------------------------------------------------------------------------
      CASE ls_return-parameter.
        WHEN gc_cds-contrato.
          es_reported-_contrato[]       = VALUE #( BASE es_reported-_contrato[] ( CORRESPONDING #( <fs_cds> ) ) ).
        WHEN gc_cds-raiz.
          es_reported-_raiz[]           = VALUE #( BASE es_reported-_raiz[] ( CORRESPONDING #( <fs_cds> ) ) ).
        WHEN gc_cds-cliente.
          es_reported-_cliente[]        = VALUE #( BASE es_reported-_cliente[] ( CORRESPONDING #( <fs_cds> ) ) ).
        WHEN gc_cds-anexo.
          es_reported-_anexos[]         = VALUE #( BASE es_reported-_anexos[] ( CORRESPONDING #( <fs_cds> ) ) ).
        WHEN gc_cds-cond.
          es_reported-_cond[]           = VALUE #( BASE es_reported-_cond[] ( CORRESPONDING #( <fs_cds> ) ) ).
        WHEN gc_cds-janela.
          es_reported-_janela[]         = VALUE #( BASE es_reported-_janela[] ( CORRESPONDING #( <fs_cds> ) ) ).
        WHEN gc_cds-prov.
          es_reported-_prov[]           = VALUE #( BASE es_reported-_prov[] ( CORRESPONDING #( <fs_cds> ) ) ).
        WHEN gc_cds-prov_familia.
          es_reported-_provfamilia[]    = VALUE #( BASE es_reported-_provfamilia[] ( CORRESPONDING #( <fs_cds> ) ) ).
        WHEN gc_cds-aprovadores.
          es_reported-_aprovadores[]    = VALUE #( BASE es_reported-_aprovadores[] ( CORRESPONDING #( <fs_cds> ) ) ).
        WHEN OTHERS.
          es_reported-_contrato[]       = VALUE #( BASE es_reported-_contrato[] ( CORRESPONDING #( <fs_cds> ) ) ).
      ENDCASE.

    ENDLOOP.

  ENDMETHOD.


ENDCLASS.
