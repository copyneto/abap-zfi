"!<p><h2>Geração e impressão do comprovante de pagamentos</h2></p>
"!<p><strong>Autor:</strong> Marcos Roberto de Souza</p>
"!<p><strong>Data:</strong> 26 de ago de 2021</p>
CLASS zclfi_comprovante_pagamento DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES:
      if_badi_interface,
      if_fagl_lib.

    "!Nome do formulário Adobe a ser gerado
    CONSTANTS gc_form TYPE fpname VALUE 'ZAFFI_COMPROVANTE_PAGAMENTO' ##NO_TEXT.

    METHODS constructor .
    "! Realiza a geração do comprovante de pagamento
    "! @parameter is_campos_chave | Campos chave do comprovante de pagamento
    "! @parameter iv_print_dialog | Marcar com <em>ABAP_TRUE</em> para exibir o diálogo de impressão
    "! @parameter ev_comprovante | PDF com o comprovante gerado no formato binário
    "! @parameter et_comprovante_tab | PDF com o comprovante gerado no formato de tabela binária
    "! @parameter ev_no_record_found | Retorna "true" caso não encontre registros
    METHODS gerar_comprovante IMPORTING is_campos_chave    TYPE zsfi_comprov_pagto_chave
                                        iv_print_dialog    TYPE abap_bool DEFAULT abap_false
                              EXPORTING ev_comprovante     TYPE xstring
                                        et_comprovante_tab TYPE solix_tab
                                        ev_no_record_found TYPE abap_bool.
  PRIVATE SECTION.
    DATA:
       "!Instância do gerenciador de formulário do Adobe
       go_adobe TYPE REF TO zclfi_adobeform.

    METHODS:
      "! Realiza a busca e formatação do CNPJ da empresa pagadora
      "! @parameter iv_empresa | Código da empresa
      "! @parameter cs_comprovante | Estrutura a ser atualizada com a informação
      obter_cnpj_empresa IMPORTING iv_empresa     TYPE bukrs
                         CHANGING  cs_comprovante TYPE zsfi_dados_comprovante,

      "! Obtém os dados do recebedor do pagamento
      "! @parameter iv_fornecedor | Código do fornecedor
      "! @parameter cs_comprovante | Estrutura a ser atualizada com a informação
      obter_dados_favorecido IMPORTING iv_fornecedor  TYPE zi_fi_retpagto_segmentoz-fornecedor
                             CHANGING  cs_comprovante TYPE zsfi_dados_comprovante,

      "! Seleciona o logotipo a ser utilizado baseado no código bancário
      "! @parameter iv_banco | Código do banco
      "! @parameter ev_logotipo | String contendo o nome do logotipo na SE78
      definir_logotipo IMPORTING iv_banco    TYPE zi_fi_retpagto_segmentoz-bancoempresa
                       EXPORTING ev_logotipo TYPE zsfi_dados_comprovante-logotipo,

      "! Obter e formata o código de barras de acordo com os parâmetros de entrada
      "! @parameter iv_bukrs | Código da empresa
      "! @parameter iv_belnr | Fatura a ter o comprovante impresso
      "! @parameter iv_gjahr | Ano da fatura
      "! @parameter iv_buzei | Ítem da fatura a ser impresso
      "! @parameter cs_comprovante | Estrutura a ser atualizada com a informação
      obter_codigo_barras IMPORTING iv_bukrs       TYPE zi_fi_retpagto_segmentoz-empresa
                                    iv_belnr       TYPE zi_fi_retpagto_segmentoz-fatura
                                    iv_gjahr       TYPE zi_fi_retpagto_segmentoz-exercicio
                                    iv_buzei       TYPE zi_fi_retpagto_segmentoz-item
                          CHANGING  cs_comprovante TYPE zsfi_dados_comprovante.
ENDCLASS.



CLASS ZCLFI_COMPROVANTE_PAGAMENTO IMPLEMENTATION.


  METHOD constructor.
    FREE go_adobe.
    TRY.
        go_adobe = NEW zclfi_adobeform( iv_formname = gc_form ).
      CATCH zcxfi_adobe_error.
    ENDTRY.
  ENDMETHOD.


  METHOD gerar_comprovante.

    DATA: ls_info_comprovante TYPE zsfi_dados_comprovante.

    "Ler dados do segmento 'Z'
    SELECT SINGLE empresa,     fornecedor,  fatura,         doccontabauxiliar,  exerciciocompensacao,  bancoempresa,
                  formapagto,  item,        exercicio,      montante,           datacompensacao,       autenticacaobanc,
                  banco,       agencia,     contacorrente,  bancofavor,         agenciafavor,          contafavor,
                  \_empresas-butxt
       FROM zi_fi_retpagto_segmentoz
       WHERE empresa              = @is_campos_chave-empresa              AND
             fornecedor           = @is_campos_chave-fornecedor           AND
             fatura               = @is_campos_chave-fatura               AND
             doccontabauxiliar    = @is_campos_chave-doccontabauxiliar    AND
             exerciciocompensacao = @is_campos_chave-exerciciocompensacao AND
             bancoempresa         = @is_campos_chave-bancoempresa         AND
             formapagto           = @is_campos_chave-formapagto
       INTO @DATA(ls_segmentoz).                     "#EC CI_SEL_NESTED
    IF sy-subrc <> 0.

      "Cenário quando houver estorno da compensação, precisa emitir o comprovante já pago
      SELECT SINGLE empresa,     fornecedor,  fatura,         doccontabauxiliar,  exerciciocompensacao,  bancoempresa,
                    formapagto,  item,        exercicio,      montante,           datacompensacao,       autenticacaobanc,
                    banco,       agencia,     contacorrente,  bancofavor,         agenciafavor,          contafavor,
                    \_empresas-butxt
         FROM zi_fi_retpagto_segmentoz
         WHERE empresa              = @is_campos_chave-empresa              AND
               fornecedor           = @is_campos_chave-fornecedor           AND
               fatura               = @is_campos_chave-fatura               AND
*             doccontabauxiliar    = @is_campos_chave-doccontabauxiliar    AND
               exerciciocompensacao = @is_campos_chave-exerciciocompensacao AND
               bancoempresa         = @is_campos_chave-bancoempresa         AND
               formapagto           = @is_campos_chave-formapagto
         INTO @ls_segmentoz.                         "#EC CI_SEL_NESTED

      IF sy-subrc <> 0.
        ev_no_record_found = abap_true.
        RETURN.
      ENDIF.
    ENDIF.

    "Preencher cabeçalho do comprovante
    definir_logotipo( EXPORTING iv_banco    = ls_segmentoz-bancoempresa
                      IMPORTING ev_logotipo = ls_info_comprovante-logotipo ).
    ls_info_comprovante-agencia = ls_segmentoz-agencia.
    ls_info_comprovante-conta   = ls_segmentoz-contacorrente.

    ls_info_comprovante-agencia_fav = ls_segmentoz-agenciafavor.
    ls_info_comprovante-conta_fav   = ls_segmentoz-contafavor.
    ls_info_comprovante-banco_fav   = ls_segmentoz-bancofavor.

    ls_info_comprovante-tipo    = TEXT-001. "'CONTA CORRENTE'.
    ls_info_comprovante-empresa = ls_segmentoz-butxt.
    "Obter o cnpj da empresa pagadora
    obter_cnpj_empresa( EXPORTING iv_empresa     = ls_segmentoz-empresa
                        CHANGING  cs_comprovante = ls_info_comprovante ).


    "Preencher dados da transferência
    "Obter Código de Barras
    obter_codigo_barras( EXPORTING iv_bukrs       = ls_segmentoz-empresa
                                   iv_belnr       = ls_segmentoz-fatura
                                   iv_gjahr       = ls_segmentoz-exercicio
                                   iv_buzei       = ls_segmentoz-item
                         CHANGING  cs_comprovante = ls_info_comprovante ).

    "Obter o favorecido do pagamento e CNPJ
    obter_dados_favorecido( EXPORTING iv_fornecedor  = ls_segmentoz-fornecedor
                            CHANGING  cs_comprovante = ls_info_comprovante ).
    ls_info_comprovante-valor   = ls_segmentoz-montante.
    ls_info_comprovante-data_debito  = |{ ls_segmentoz-datacompensacao DATE = USER }|.

    "Dados de crédito
    IF ls_segmentoz-formapagto = 'G' OR
       ls_segmentoz-formapagto = 'O'.

      ls_info_comprovante-credito = |{ TEXT-002 } { ls_segmentoz-bancofavor } { TEXT-003 } { ls_segmentoz-agenciafavor } { TEXT-004 } { ls_segmentoz-contafavor }|.

    ELSE.
      CLEAR ls_info_comprovante-credito.
    ENDIF.

    "Tipo de Transferência
    IF ls_segmentoz-formapagto = 'T'.
      ls_info_comprovante-tipo_transf = TEXT-005. "Tipo de Transferência: TED
    ENDIF.


    "Preencher autenticação
    ls_info_comprovante-autenticacao = ls_segmentoz-autenticacaobanc.


    "Preparar dados do formulário e efetuar a geração do comprovante
    TRY.
        go_adobe->setup_data( is_data = VALUE #( parametro = 'INFO' valor = REF #( ls_info_comprovante ) ) ).

        IF iv_print_dialog = abap_true.
          go_adobe->show_dialog( iv_print_dialog = abap_true ).
        ENDIF.

        IF ev_comprovante     IS SUPPLIED AND
           et_comprovante_tab IS SUPPLIED.
          go_adobe->get_pdf(
            IMPORTING
              ev_pdf = ev_comprovante
              et_pdf = et_comprovante_tab ).

        ELSEIF ev_comprovante IS SUPPLIED.
          go_adobe->get_pdf(
            IMPORTING
              ev_pdf = ev_comprovante ).

        ELSEIF et_comprovante_tab IS SUPPLIED.
          go_adobe->get_pdf(
            IMPORTING
              et_pdf = et_comprovante_tab ).

        ELSE.
          go_adobe->print( ).
          MESSAGE s105(zfi_compr_pagtos).
        ENDIF.

      CATCH zcxfi_adobe_error INTO DATA(lo_error).
        MESSAGE lo_error->get_text( ) TYPE 'S' DISPLAY LIKE 'E'.
        RETURN.
    ENDTRY.
  ENDMETHOD.


  METHOD obter_cnpj_empresa.

    DATA: lv_cgc TYPE j_1bwfield-cgc_number.

    "Montar o CNPJ do pagador
    SELECT party, paval                              "#EC CI_SEL_NESTED
      FROM t001z
      WHERE bukrs EQ @iv_empresa AND
            party IN ('J_1BBR', 'J_1BCG')
      ORDER BY party
      INTO TABLE @DATA(lt_t001z).                        "#EC CI_BYPASS

    IF lines( lt_t001z ) = 2.
      CALL FUNCTION 'J_1BBUILD_CGC'
        EXPORTING
          cgc_company = CONV j_1bwfield-cgc_compan( lt_t001z[ 2 ]-paval )
          cgc_branch  = CONV j_1bwfield-cgc_branch( lt_t001z[ 1 ]-paval )
        IMPORTING
          cgc_number  = lv_cgc.

      CALL FUNCTION 'CONVERSION_EXIT_CGCBR_OUTPUT'
        EXPORTING
          input  = lv_cgc
        IMPORTING
          output = cs_comprovante-cnpj_empresa.
    ENDIF.
  ENDMETHOD.


  METHOD obter_dados_favorecido.

    SELECT SINGLE name1, stcd1
        FROM fndei_lfa1_filter
        WHERE lifnr = @iv_fornecedor
        INTO (@cs_comprovante-favorecido, @cs_comprovante-cnpj_favorecido). "#EC CI_SEL_NESTED

    CALL FUNCTION 'CONVERSION_EXIT_CGCBR_OUTPUT'
      EXPORTING
        input  = cs_comprovante-cnpj_favorecido
      IMPORTING
        output = cs_comprovante-cnpj_favorecido.
  ENDMETHOD.


  METHOD definir_logotipo.

    ev_logotipo = COND #( WHEN iv_banco = 'BRA01' THEN 'BRADESCO'
                          WHEN iv_banco = 'BRA02' THEN 'BRADESCO'
                          WHEN iv_banco = 'BRA03' THEN 'BRADESCO'
                          WHEN iv_banco = 'ITA01' THEN 'ITAU'
                          WHEN iv_banco = 'ITA02' THEN 'ITAU'
                          WHEN iv_banco = 'SAN01' THEN 'SANTANDER'
                          WHEN iv_banco = 'SAF01' THEN 'SAFRA'
                          WHEN iv_banco = 'BBR01' THEN 'BANCOBRASIL'
                          WHEN iv_banco = 'BBR02' THEN 'BANCOBRASIL'
                          WHEN iv_banco = 'CIT01' THEN 'CITIBANK'
                          WHEN iv_banco = 'CIT02' THEN 'CITIBANK' ).
    ev_logotipo = |Z_LOGO_{ ev_logotipo }|.
  ENDMETHOD.


  METHOD obter_codigo_barras.

    DATA lv_digit TYPE c LENGTH 1.

    SELECT SINGLE zlsch, glo_ref1 AS bc
        FROM p_bseg_com1
        WHERE bukrs = @iv_bukrs AND
              belnr = @iv_belnr AND
              gjahr = @iv_gjahr AND
              buzei = @iv_buzei
        INTO @DATA(ls_barcode).                      "#EC CI_SEL_NESTED

    CASE ls_barcode-zlsch.
      WHEN 'B'.
        cs_comprovante-codbarras = |{ ls_barcode-bc(5) }.{ ls_barcode-bc+5(5) } { ls_barcode-bc+10(5) }.{ ls_barcode-bc+15(6) } { ls_barcode-bc+21(5) }.{ ls_barcode-bc+26(6) } { ls_barcode-bc+32(1) } { ls_barcode-bc+33 }|.

      WHEN 'G' OR 'O'.
        CALL FUNCTION 'CALCULATE_CHECK_DIGIT_MOD10'
          EXPORTING
            number_part = ls_barcode-bc
          IMPORTING
            check_digit = lv_digit.
        ls_barcode-bc = ls_barcode-bc && lv_digit.

        cs_comprovante-codbarras = |{ ls_barcode-bc(11) }-{ ls_barcode-bc+11(1) } { ls_barcode-bc+12(11) }-{ ls_barcode-bc+23(1) } { ls_barcode-bc+24(11) }-{ ls_barcode-bc+35(1) } { ls_barcode-bc+36(11) }-{ ls_barcode-bc+47(1) }|.
    ENDCASE.
  ENDMETHOD.


  METHOD if_fagl_lib~add_fields.
    RETURN.
  ENDMETHOD.


  METHOD if_fagl_lib~add_secondary_fields.
    RETURN.
  ENDMETHOD.


  METHOD if_fagl_lib~column_visibility_change.
    RETURN.
  ENDMETHOD.


  METHOD if_fagl_lib~create_default_restrictions.
    RETURN.
  ENDMETHOD.


  METHOD if_fagl_lib~main_toolbar_handle.

    CONSTANTS: gc_zp TYPE blart VALUE 'ZP'.
    CONSTANTS: gc_31 TYPE bschl VALUE '31'.
    CONSTANTS: gc_25 TYPE bschl VALUE '25'.

    DATA: ls_key_fields TYPE zsfi_comprov_pagto_chave,
          lv_dir        TYPE string.
    FIELD-SYMBOLS <fs_montante> TYPE fagl_currval_0d.

    IF iv_ucomm = 'ZIMP_PAGTO' OR
       iv_ucomm = 'ZPDF_PAGTO' .

      IF lines( it_outtab_selected_rows ) <> 1.
        MESSAGE s102(zfi_compr_pagtos) DISPLAY LIKE 'E'. "Selecionar apenas um registro para cada impressão
        RETURN.
      ENDIF.

      ASSIGN it_outtab[ it_outtab_selected_rows[ 1 ]-row_id ] TO FIELD-SYMBOL(<fs_data>).

      ASSIGN COMPONENT 'BUKRS' OF STRUCTURE <fs_data> TO FIELD-SYMBOL(<fs_empresa>).
      IF sy-subrc = 0.
        ls_key_fields-empresa = <fs_empresa>.
      ELSE.
        MESSAGE s101(zfi_compr_pagtos) WITH TEXT-e01 DISPLAY LIKE 'E'. "Empresa
        RETURN.
      ENDIF.

      ASSIGN COMPONENT 'LIFNR' OF STRUCTURE <fs_data> TO FIELD-SYMBOL(<fs_fornecedor>).
      IF sy-subrc = 0.
        ls_key_fields-fornecedor = <fs_fornecedor>.
      ELSE.
        MESSAGE s101(zfi_compr_pagtos) WITH TEXT-e02 DISPLAY LIKE 'E'. "Fornecedor
        RETURN.
      ENDIF.


      ASSIGN COMPONENT 'BELNR' OF STRUCTURE <fs_data> TO FIELD-SYMBOL(<fs_doc_aux>).
      IF sy-subrc = 0.
        ls_key_fields-doccontabauxiliar = <fs_doc_aux>."    : nbbln_eb;
      ELSE.
        MESSAGE s101(zfi_compr_pagtos) WITH TEXT-e04 DISPLAY LIKE 'E'. "Docto. Contábil
        RETURN.
      ENDIF.

      ASSIGN COMPONENT 'GJAHR' OF STRUCTURE <fs_data> TO FIELD-SYMBOL(<fs_exercicio>).
      IF sy-subrc = 0.
        ls_key_fields-exerciciocompensacao = <fs_exercicio>.
      ELSE.
        MESSAGE s101(zfi_compr_pagtos) WITH TEXT-e05 DISPLAY LIKE 'E'. "Exercício
        RETURN.
      ENDIF.

      ASSIGN COMPONENT 'HBKID' OF STRUCTURE <fs_data> TO FIELD-SYMBOL(<fs_banco>).
      IF sy-subrc = 0.
        ls_key_fields-bancoempresa = <fs_banco>.

**        SELECT SINGLE bankl
**            FROM t012
**            WHERE bukrs = @ls_key_fields-empresa AND
**                  hbkid = @ls_key_fields-bancoempresa
**            INTO @DATA(lv_banco).
**        IF strlen( lv_banco ) >= 3.
**          ls_key_fields-bancoempresa = lv_banco(3).
**        ENDIF.

      ELSE.
        MESSAGE s101(zfi_compr_pagtos) WITH TEXT-e06 DISPLAY LIKE 'E'. "Chave de Banco
        RETURN.
      ENDIF.

      ASSIGN COMPONENT 'ZLSCH' OF STRUCTURE <fs_data> TO FIELD-SYMBOL(<fs_forma_pagto>).
      IF sy-subrc = 0.
        ls_key_fields-formapagto = <fs_forma_pagto>. " : schzw_bseg;
      ELSE.
        MESSAGE s101(zfi_compr_pagtos) WITH TEXT-e07 DISPLAY LIKE 'E'. "Tipo de Pagto.
        RETURN.
      ENDIF.

      IF iv_ucomm = 'ZPDF_PAGTO'.
        "Campos para a formação do nome do arquivo
        ASSIGN COMPONENT 'AUGBL' OF STRUCTURE <fs_data> TO FIELD-SYMBOL(<fs_dt_comp>).
        IF sy-subrc <> 0.
          MESSAGE s101(zfi_compr_pagtos) WITH TEXT-e08 DISPLAY LIKE 'E'. ""DocCompens"
          RETURN.
        ENDIF.

        ASSIGN COMPONENT 'CURRVAL_10' OF STRUCTURE <fs_data> TO <fs_montante>.
        IF sy-subrc <> 0.
          MESSAGE s101(zfi_compr_pagtos) WITH TEXT-e09 DISPLAY LIKE 'E'. ""Val.em moeda doc."
          RETURN.
        ENDIF.
      ENDIF.



      IF ls_key_fields-bancoempresa(3) = 'SAN' .

        DATA: lv_xblnr TYPE bkpf-xblnr.

        ASSIGN COMPONENT 'XBLNR' OF STRUCTURE <fs_data> TO FIELD-SYMBOL(<fs_ref>).
        IF sy-subrc <> 0.
          MESSAGE s101(zfi_compr_pagtos) WITH TEXT-e10 DISPLAY LIKE 'E'. """Campo Referência"
          RETURN.
        ENDIF.

        lv_xblnr = <fs_ref>.

        SELECT COUNT(*)
         FROM bkpf
         WHERE bukrs = @ls_key_fields-empresa
             AND belnr = @ls_key_fields-doccontabauxiliar
             AND gjahr = @ls_key_fields-exerciciocompensacao
             AND blart = @gc_zp.
        IF sy-subrc = 0.

          SELECT SINGLE belnr
             FROM bseg
               INTO @ls_key_fields-fatura
               WHERE bukrs = @ls_key_fields-empresa
               AND augbl = @ls_key_fields-doccontabauxiliar
               AND gjahr = @ls_key_fields-exerciciocompensacao
               AND bschl = @gc_31.

          ls_key_fields-doccontabauxiliar = lv_xblnr.

        ELSE.

          ls_key_fields-fatura = ls_key_fields-doccontabauxiliar.
          ls_key_fields-doccontabauxiliar = lv_xblnr.

        ENDIF.


      ELSE.

        SELECT COUNT(*)
          FROM bkpf
          WHERE bukrs = @ls_key_fields-empresa
              AND belnr = @ls_key_fields-doccontabauxiliar
              AND gjahr = @ls_key_fields-exerciciocompensacao
              AND blart = @gc_zp.
        IF sy-subrc = 0.

          SELECT SINGLE belnr
             FROM bseg
               INTO @ls_key_fields-fatura
               WHERE bukrs = @ls_key_fields-empresa
               AND augbl = @ls_key_fields-doccontabauxiliar
               AND gjahr = @ls_key_fields-exerciciocompensacao
               AND bschl = @gc_31.

        ELSE.

          SELECT SINGLE augbl
             FROM bseg
               INTO @DATA(lv_doc_comp)
               WHERE bukrs = @ls_key_fields-empresa
               AND belnr = @ls_key_fields-doccontabauxiliar
               AND gjahr = @ls_key_fields-exerciciocompensacao
               AND bschl = @gc_31.

          ls_key_fields-fatura = ls_key_fields-doccontabauxiliar.
          ls_key_fields-doccontabauxiliar = lv_doc_comp.

        ENDIF.

      ENDIF.


*      ASSIGN COMPONENT 'AWKEY' OF STRUCTURE <fs_data> TO FIELD-SYMBOL(<fs_fatura>).
*      IF sy-subrc = 0.
*        ls_key_fields-fatura = <fs_fatura>(10).
*      ELSE.
*        SELECT SINGLE awkey
*          FROM bseg
*          INTO @DATA(lv_awkey)
*          WHERE bukrs = @ls_key_fields-empresa
*            AND belnr = @ls_key_fields-doccontabauxiliar
*            AND gjahr = @ls_key_fields-exerciciocompensacao.
*
*        IF lv_awkey IS NOT INITIAL.
*          ASSIGN lv_awkey TO <fs_fatura>.
*        ELSE.
** ECOSTA
*          MESSAGE s101(zfi_compr_pagtos) WITH TEXT-e03 DISPLAY LIKE 'E'. "Fatura
*          RETURN.
*        ENDIF.
*      ENDIF.

      CASE iv_ucomm.
        WHEN 'ZIMP_PAGTO'.
          gerar_comprovante( EXPORTING is_campos_chave    = ls_key_fields
                                       iv_print_dialog    = abap_true
                             IMPORTING ev_no_record_found = DATA(lv_no_data) ).

        WHEN 'ZPDF_PAGTO' .
          gerar_comprovante( EXPORTING is_campos_chave    = ls_key_fields
                             IMPORTING et_comprovante_tab = DATA(lt_pdf_tab)
                                       ev_no_record_found = lv_no_data ).

          IF lv_no_data = abap_false.
            cl_gui_frontend_services=>get_desktop_directory( CHANGING desktop_directory = lv_dir ).

            cl_gui_frontend_services=>directory_browse(
              EXPORTING
                window_title         = CONV #( TEXT-010 )
                initial_folder       = lv_dir
              CHANGING
                selected_folder      = lv_dir
              EXCEPTIONS
                cntl_error           = 1
                error_no_gui         = 2
                not_supported_by_gui = 3
                OTHERS               = 4 ).
            IF sy-subrc <> 0 OR
               lv_dir IS INITIAL.
              RETURN.
            ENDIF.

            "Quando executa pelo WEBGUI, a barra já vem no final do diretório, então só é necessário adicionar caso não haje (SAP GUI).
            DATA(lv_length) = strlen( lv_dir ) - 1.
            IF lv_dir+lv_length(1) <> '\'.
              lv_dir = lv_dir && '\'.
            ENDIF.

            lv_dir = |{ lv_dir }{ ls_key_fields-empresa }_{ ls_key_fields-fornecedor }_{ <fs_dt_comp> }_{ <fs_montante> DECIMALS = 0 }.pdf|.

            cl_abap_memory_utilities=>get_memory_size_of_object(
              EXPORTING
                object                     = lt_pdf_tab
              IMPORTING
                bound_size_used            = DATA(lv_size) ).

            cl_gui_frontend_services=>gui_download(
              EXPORTING
                filename                  = lv_dir
                bin_filesize              = CONV #( lv_size )
                filetype                  = 'BIN'
              CHANGING
                data_tab                  = lt_pdf_tab
              EXCEPTIONS
                file_write_error          = 1
                no_batch                  = 2
                gui_refuse_filetransfer   = 3
                invalid_type              = 4
                no_authority              = 5
                unknown_error             = 6
                header_not_allowed        = 7
                separator_not_allowed     = 8
                filesize_not_allowed      = 9
                header_too_long           = 10
                dp_error_create           = 11
                dp_error_send             = 12
                dp_error_write            = 13
                unknown_dp_error          = 14
                access_denied             = 15
                dp_out_of_memory          = 16
                disk_full                 = 17
                dp_timeout                = 18
                file_not_found            = 19
                dataprovider_exception    = 20
                control_flush_error       = 21
                not_supported_by_gui      = 22
                error_no_gui              = 23
                OTHERS                    = 24 ).
            IF sy-subrc <> 0.
              MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.

            ELSE.
              MESSAGE s104(zfi_compr_pagtos). "Download efetuado
            ENDIF.
          ENDIF.
      ENDCASE.

      IF lv_no_data = abap_true.
        MESSAGE s103(zfi_compr_pagtos) DISPLAY LIKE 'E'. "Dados de pagamento ainda não recebidos do banco
      ENDIF.
    ENDIF.
  ENDMETHOD.


  METHOD if_fagl_lib~main_toolbar_handle_menu.
    RETURN.
  ENDMETHOD.


  METHOD if_fagl_lib~main_toolbar_set.
    IF sy-tcode = 'FBL1H'.
      "Adicionar botão para impressão de comprovante de pagamento
      APPEND INITIAL LINE TO ct_toolbar ASSIGNING FIELD-SYMBOL(<fs_btn>).
      <fs_btn>-function  = 'ZIMP_PAGTO'.
      <fs_btn>-quickinfo = TEXT-007.
      <fs_btn>-text      = TEXT-006.

      APPEND INITIAL LINE TO ct_toolbar ASSIGNING <fs_btn>.
      <fs_btn>-function  = 'ZPDF_PAGTO'.
      <fs_btn>-quickinfo = TEXT-009.
      <fs_btn>-text      = TEXT-008.
    ENDIF.
  ENDMETHOD.


  METHOD if_fagl_lib~modify_rri_restrictions.
    RETURN.
  ENDMETHOD.


  METHOD if_fagl_lib~select_data.
    RETURN.
  ENDMETHOD.


  METHOD if_fagl_lib~sidebar_actions_handle.
    RETURN.
  ENDMETHOD.


  METHOD if_fagl_lib~sidebar_actions_set.
    RETURN.
  ENDMETHOD.
ENDCLASS.
