CLASS zclfi_gko_clearing DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    TYPES:
      BEGIN OF ty_s_header_data,
        bukrs TYPE bukrs,
        waers TYPE waers,
        bldat TYPE bldat,
        budat TYPE budat,
        blart TYPE blart,
        bktxt TYPE bktxt,
        monat TYPE monat,
        xblnr TYPE xblnr,
      END OF ty_s_header_data .
    TYPES:
      BEGIN OF ty_s_item_data,
        buzei TYPE buzei,
        bschl TYPE bschl,
        bupla TYPE bupla,
        zlsch TYPE dzlsch,
        zlspr TYPE dzlspr,
        zterm TYPE dzterm,
        zfbdt TYPE dzfbdt,
        hkont TYPE hkont,
        wrbtr TYPE wrbtr,
        zuonr TYPE dzuonr,
        sgtxt TYPE sgtxt,
        prctr TYPE prctr,
        kostl TYPE kostl,
        xref2 TYPE xref2,
        gsber TYPE gsber,
        augtx TYPE augtx_f05a,
      END OF ty_s_item_data .
    TYPES:
      ty_t_item_data TYPE TABLE OF ty_s_item_data WITH DEFAULT KEY .
    TYPES:
      BEGIN OF ty_s_documents,
        bukrs TYPE bukrs,
        koart TYPE koart,
        agums TYPE agums,
        hkont TYPE hkont,
        belnr TYPE belnr_d,
        gjahr TYPE gjahr,
        buzei TYPE buzei,
      END OF ty_s_documents .
    TYPES:
      ty_t_documents TYPE TABLE OF ty_s_documents WITH DEFAULT KEY .

    CONSTANTS gC_TCODE TYPE sy-tcode VALUE 'FB05' ##NO_TEXT.
    CONSTANTS gC_SGFUNCT TYPE rfipi-sgfunct VALUE 'C' ##NO_TEXT.

    CLASS-METHODS conv_amount
      IMPORTING
        !iv_amount            TYPE wrbtr
      RETURNING
        VALUE(rv_conv_amount) TYPE char20 .
    CLASS-METHODS conv_date
      IMPORTING
        !iv_datum      TYPE datum
      RETURNING
        VALUE(rv_date) TYPE char10 .
    CLASS-METHODS get_msg_text
      IMPORTING
        !is_mensagem       TYPE bapiret2
      RETURNING
        VALUE(rv_msg_text) TYPE bapiret2-message .
    METHODS set_header_data
      IMPORTING
        !is_header TYPE ty_s_header_data .
    METHODS set_item_data
      IMPORTING
        !it_item TYPE ty_t_item_data .
    METHODS set_documents
      IMPORTING
        !it_documents TYPE ty_t_documents .
    METHODS clear_documents
      EXPORTING
        !et_return       TYPE bapiret2_t
      RETURNING
        VALUE(rt_blntab) TYPE re_t_ex_blntab .
    METHODS constructor
      IMPORTING
        !iv_augvl TYPE t041a-auglv .
  PROTECTED SECTION.
  PRIVATE SECTION.

    DATA ls_header TYPE ty_s_header_data .
    DATA lt_item TYPE ty_t_item_data .
    DATA lt_documents TYPE ty_t_documents .
    DATA lt_ftpost TYPE feb_t_ftpost .
    DATA lt_ftclear TYPE feb_t_ftclear .
    DATA lv_augvl TYPE t041a-auglv .

    METHODS get_zlsch
      IMPORTING
        !iv_lifnr       TYPE char10
        !iv_bukrs       TYPE char4
      RETURNING
        VALUE(rv_zlsch) TYPE char1 .
    METHODS set_value_ftpost
      IMPORTING
        !iv_type   TYPE stype_pi
        !iv_screen TYPE count_pi
        !iv_field  TYPE bdc_fnam
        !iv_value  TYPE any .
    METHODS mount_header .
    METHODS mount_item .
    METHODS mount_clearing_documents .
ENDCLASS.



CLASS zclfi_gko_clearing IMPLEMENTATION.


  METHOD clear_documents.

    FREE: et_return.

    DATA lt_fttax    TYPE STANDARD TABLE OF fttax.
    DATA ls_mensagem TYPE bapiret2.
    DATA lv_mode(1)  TYPE c VALUE 'N'.

    CALL FUNCTION 'POSTING_INTERFACE_START'
      EXPORTING
        i_function         = 'C'
        i_mode             = lv_mode
        i_user             = sy-uname
      EXCEPTIONS
        client_incorrect   = 1
        function_invalid   = 2
        group_name_missing = 3
        mode_invalid       = 4
        update_invalid     = 5
        OTHERS             = 6.

    IF sy-subrc IS NOT INITIAL.
      "Erro ao iniciar compensação dos documentos
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 INTO DATA(lv_message_error).
    ENDIF.

    mount_header( ).

    mount_item( ).

    mount_clearing_documents( ).

    CALL FUNCTION 'POSTING_INTERFACE_CLEARING'
      EXPORTING
        i_auglv                    = lv_augvl
        i_tcode                    = gc_tcode
        i_sgfunct                  = gc_sgfunct
        i_no_auth                  = abap_true
      IMPORTING
        e_msgid                    = ls_mensagem-id
        e_msgno                    = ls_mensagem-number
        e_msgty                    = ls_mensagem-type
        e_msgv1                    = ls_mensagem-message_v1
        e_msgv2                    = ls_mensagem-message_v2
        e_msgv3                    = ls_mensagem-message_v3
        e_msgv4                    = ls_mensagem-message_v4
      TABLES
        t_blntab                   = rt_blntab
        t_ftclear                  = lt_ftclear
        t_ftpost                   = lt_ftpost
        t_fttax                    = lt_fttax
      EXCEPTIONS
        clearing_procedure_invalid = 1
        clearing_procedure_missing = 2
        table_t041a_empty          = 3
        transaction_code_invalid   = 4
        amount_format_error        = 5
        too_many_line_items        = 6
        company_code_invalid       = 7
        screen_not_found           = 8
        no_authorization           = 9
        OTHERS                     = 10.

    IF sy-subrc  IS NOT INITIAL OR ls_mensagem-type = 'E' OR
       rt_blntab IS INITIAL.

      IF ls_mensagem IS INITIAL.
        ls_mensagem-id         = sy-msgid.
        ls_mensagem-number     = sy-msgno.
        ls_mensagem-type       = COND #( WHEN rt_blntab IS INITIAL  " INSERT - JWSILVA - 20.02.2023
                                         THEN 'E'                   " INSERT - JWSILVA - 20.02.2023
                                         ELSE sy-msgty ).           " INSERT - JWSILVA - 20.02.2023
        ls_mensagem-message_v1 = sy-msgv1.
        ls_mensagem-message_v2 = sy-msgv2.
        ls_mensagem-message_v3 = sy-msgv3.
        ls_mensagem-message_v4 = sy-msgv4.
      ENDIF.

      IF ls_mensagem IS NOT INITIAL.

        ls_mensagem-type       = COND #( WHEN rt_blntab IS INITIAL  " INSERT - JWSILVA - 20.02.2023
                                         THEN 'E'                   " INSERT - JWSILVA - 20.02.2023
                                         ELSE ls_mensagem-type ).   " INSERT - JWSILVA - 20.02.2023

        ls_mensagem-message = get_msg_text( ls_mensagem ).
        APPEND ls_mensagem TO et_return.

      ENDIF.

    ENDIF.

  ENDMETHOD.


  METHOD constructor.
    lv_augvl = iv_augvl.
  ENDMETHOD.


  METHOD conv_amount.
    WRITE iv_amount TO rv_conv_amount CURRENCY 'BRL'.
    CONDENSE rv_conv_amount NO-GAPS.
  ENDMETHOD.


  METHOD conv_date.
    WRITE iv_datum TO rv_date.
  ENDMETHOD.


  METHOD get_msg_text.
    MESSAGE ID     is_mensagem-id
            TYPE   is_mensagem-type
            NUMBER is_mensagem-number
            WITH   is_mensagem-message_v1
                   is_mensagem-message_v2
                   is_mensagem-message_v3
                   is_mensagem-message_v4
            INTO   rv_msg_text.
  ENDMETHOD.


  METHOD mount_clearing_documents.

    "Estruturas
    DATA: ls_ftclear LIKE LINE OF lt_ftclear.

    "Field Symbols
    FIELD-SYMBOLS <fs_s_document> LIKE LINE OF lt_documents.

    LOOP AT lt_documents ASSIGNING <fs_s_document>.

      ls_ftclear-agkoa = <fs_s_document>-koart. "Account Type
      ls_ftclear-xnops = abap_true.             "Indicator: Select only open items which are not special G/L?
      ls_ftclear-selfd = 'BELNR'.               "Selection Field
      ls_ftclear-agums = <fs_s_document>-agums. "Códigos de razão especial que vai ser selecionado
      ls_ftclear-agbuk = <fs_s_document>-bukrs. "Company code
      ls_ftclear-agkon = <fs_s_document>-hkont. "Account
      CONCATENATE <fs_s_document>-belnr
                  <fs_s_document>-gjahr
                  <fs_s_document>-buzei
             INTO ls_ftclear-selvon.

      ls_ftclear-selbis = ls_ftclear-selvon.
      APPEND ls_ftclear TO lt_ftclear.

    ENDLOOP.


  ENDMETHOD.


  METHOD mount_header.
    DATA lv_value TYPE bdc_fval.

    FREE lv_value.
    lv_value = conv_date( ls_header-bldat ).

    "Data do documento
    set_value_ftpost( iv_type   = 'K'
                      iv_screen = 1
                      iv_field  = 'BKPF-BLDAT'
                      iv_value  = lv_value ).

    FREE lv_value.
    lv_value = conv_date( ls_header-budat ).

    "Data do lançamento
    set_value_ftpost( iv_type   = 'K'
                      iv_screen = 1
                      iv_field  = 'BKPF-BUDAT'
                      iv_value  = lv_value ).

    FREE lv_value.
    lv_value = ls_header-blart.

    "Tipo do Documento
    set_value_ftpost( iv_type   = 'K'
                      iv_screen = 1
                      iv_field  = 'BKPF-BLART'
                      iv_value  = lv_value ).

    FREE lv_value.
    lv_value = ls_header-bukrs.

    "Empresa
    set_value_ftpost( iv_type   = 'K'
                      iv_screen = 1
                      iv_field  = 'BKPF-BUKRS'
                      iv_value  = lv_value ).

    FREE lv_value.
    lv_value = ls_header-waers.

    "Moeda
    set_value_ftpost( iv_type   = 'K'
                      iv_screen = 1
                      iv_field  = 'BKPF-WAERS'
                      iv_value  = lv_value ).

    FREE lv_value.
    lv_value = ls_header-bktxt.

    "Texto do Documento
    set_value_ftpost( iv_type   = 'K'
                      iv_screen = 1
                      iv_field  = 'BKPF-BKTXT'
                      iv_value  = lv_value ).

    FREE lv_value.
    lv_value = ls_header-xblnr.

    "Texto do Documento
    set_value_ftpost( iv_type   = 'K'
                      iv_screen = 1
                      iv_field  = 'BKPF-XBLNR'
                      iv_value  = lv_value ).

    FREE lv_value.
    lv_value = ls_header-monat.

    "Texto do Documento
    set_value_ftpost( iv_type   = 'K'
                      iv_screen = 1
                      iv_field  = 'BKPF-MONAT'
                      iv_value  = lv_value ).


  ENDMETHOD.


  METHOD mount_item.
    DATA lv_tela  TYPE ftpost-count.
    DATA lv_value TYPE bdc_fval.

    FIELD-SYMBOLS <fs_s_item> LIKE LINE OF lt_item.

    SORT lt_item ASCENDING BY buzei.

    LOOP AT lt_item ASSIGNING <fs_s_item>.

      lv_tela = <fs_s_item>-buzei.

      IF <fs_s_item>-zfbdt IS NOT INITIAL.

        FREE lv_value.
        lv_value = conv_date( <fs_s_item>-zfbdt ).

        "Data de vencimento
        set_value_ftpost( iv_type   = 'P'
                          iv_screen = lv_tela
                          iv_field  = 'BSEG-ZFBDT'
                          iv_value  = lv_value ).

      ENDIF.

      FREE lv_value.
      lv_value = <fs_s_item>-bschl.

      "Chave de Lançamento
      set_value_ftpost( iv_type   = 'P'
                        iv_screen = lv_tela
                        iv_field  = 'RF05A-NEWBS'
                        iv_value  = lv_value ).

      FREE lv_value.
      lv_value = <fs_s_item>-bupla.

      "Local de negócios
      set_value_ftpost( iv_type   = 'P'
                        iv_screen = lv_tela
                        iv_field  = 'BSEG-BUPLA'
                        iv_value  = lv_value ).

      IF <fs_s_item>-zlsch IS NOT INITIAL.

        FREE lv_value.
        lv_value = <fs_s_item>-zlsch.

        "Forma de pagamento
        set_value_ftpost( iv_type   = 'P'
                          iv_screen = lv_tela
                          iv_field  = 'BSEG-ZLSCH'
                          iv_value  = lv_value ).

      ENDIF.

      IF <fs_s_item>-zterm IS NOT INITIAL.

        FREE lv_value.
        lv_value = <fs_s_item>-zterm.

        "Condição de Pagamento
        set_value_ftpost( iv_type   = 'P'
                          iv_screen = lv_tela
                          iv_field  = 'BSEG-ZTERM'
                          iv_value  = lv_value ).

      ENDIF.

      FREE lv_value.
      lv_value = <fs_s_item>-hkont.

      "Conta
      set_value_ftpost( iv_type   = 'P'
                          iv_screen = lv_tela
                          iv_field  = 'BSEG-HKONT'
                          iv_value  = lv_value ).

      FREE lv_value.
      lv_value = conv_amount( <fs_s_item>-wrbtr ).

      "Valor
      set_value_ftpost( iv_type   = 'P'
                        iv_screen = lv_tela
                        iv_field  = 'BSEG-WRBTR'
                        iv_value  = lv_value ).

      FREE lv_value.
      lv_value = <fs_s_item>-zuonr.

      "Campo Atribuição
      set_value_ftpost( iv_type   = 'P'
                        iv_screen = lv_tela
                        iv_field  = 'BSEG-ZUONR'
                        iv_value  = lv_value ).

      FREE lv_value.
      lv_value = <fs_s_item>-sgtxt.

      "Texto
      set_value_ftpost( iv_type   = 'P'
                        iv_screen = lv_tela
                        iv_field  = 'BSEG-SGTXT'
                        iv_value  = lv_value ).

      IF <fs_s_item>-xref2 IS NOT INITIAL.

        FREE lv_value.
        lv_value = <fs_s_item>-xref2.

        "Chave de referência 2
        set_value_ftpost( iv_type   = 'P'
                          iv_screen = lv_tela
                          iv_field  = 'BSEG-XREF2'
                          iv_value  = lv_value ).

      ENDIF.


      IF <fs_s_item>-gsber IS NOT INITIAL.

        FREE lv_value.
        lv_value = <fs_s_item>-gsber.

        "Centro de Lucro
        set_value_ftpost( iv_type   = 'P'
                          iv_screen = lv_tela
                          iv_field  = 'COBL-GSBER'
                          iv_value  = lv_value ).
      ENDIF.

      IF <fs_s_item>-prctr IS NOT INITIAL.

        FREE lv_value.
        lv_value = <fs_s_item>-prctr.

        "Centro de Lucro
        set_value_ftpost( iv_type   = 'P'
                          iv_screen = lv_tela
                          iv_field  = 'COBL-PRCTR'
                          iv_value  = lv_value ).
      ENDIF.

      IF <fs_s_item>-kostl IS NOT INITIAL.

        FREE lv_value.
        lv_value = <fs_s_item>-kostl.

        "Centro de Custo
        set_value_ftpost( iv_type   = 'P'
                          iv_screen = lv_tela
                          iv_field  = 'COBL-KOSTL'
                          iv_value  = lv_value ).
      ENDIF.

      IF <fs_s_item>-augtx IS NOT INITIAL.

        FREE lv_value.
        lv_value = <fs_s_item>-kostl.

        "Texto da compensação
        set_value_ftpost( iv_type   = 'P'
                          iv_screen = lv_tela
                          iv_field  = 'RF05A-AUGTX'
                          iv_value  = lv_value ).
      ENDIF.

      FREE lv_value.

     " Recupera Lista de formas de pagamentos a considerar
      lv_value =  get_zlsch( iv_lifnr = <fs_s_item>-hkont
                             iv_bukrs = ls_header-bukrs ).

      " Apenas pro primeiro item
      IF <fs_s_item>-buzei EQ '001'.                    " INSERT - JWSILVA - 20.02.2023
        set_value_ftpost( iv_type   = 'P'
                          iv_screen = lv_tela
                          iv_field  = 'BSEG-ZLSCH'
                          iv_value  = lv_value ).
      ENDIF.                                            " INSERT - JWSILVA - 20.02.2023

    ENDLOOP.

  ENDMETHOD.


  METHOD set_documents.
    lt_documents = it_documents.
  ENDMETHOD.


  METHOD set_header_data.
    ls_header = is_header.
  ENDMETHOD.


  METHOD set_item_data.
    lt_item = it_item.
  ENDMETHOD.


  METHOD set_value_ftpost.

    FIELD-SYMBOLS <fs_s_ftpost> LIKE LINE OF lt_ftpost.

    APPEND INITIAL LINE TO lt_ftpost ASSIGNING <fs_s_ftpost>.

    <fs_s_ftpost>-stype = iv_type.
    <fs_s_ftpost>-count = iv_screen.
    <fs_s_ftpost>-fnam  = iv_field.

    TRY.
        <fs_s_ftpost>-fval  = iv_value.
      CATCH cx_root.
    ENDTRY.

  ENDMETHOD.


  METHOD get_zlsch.

    SELECT SINGLE zwels
      FROM lfb1
      INTO @DATA(lv_zwels)
      WHERE lifnr = @iv_lifnr
        AND bukrs = @iv_bukrs.

    IF sy-subrc = 0.
      rv_zlsch = lv_zwels(1).
    ENDIF.

  ENDMETHOD.
ENDCLASS.
