CLASS zclfi_lancamento_contabil DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    CONSTANTS:
        "!Classe de mensagens
      gc_msg_class TYPE symsgid VALUE 'ZFI_ERROINTERFACE_RM'.

    METHODS:
      get_data
        IMPORTING
          is_input TYPE zclfi_mt_contabil_lancamento
        RAISING
          zclfi_cx_lancamento_contabil.

* Cabeçalho: ztfi_contab_cab
* Item: ztfi_contab_item
* SNUM: ZFI_MOVFOL - Intervalo de numeração

  PROTECTED SECTION.
  PRIVATE SECTION.

    DATA: gs_input       TYPE zclfi_mt_contabil_lancamento,
          gs_contab_cab  TYPE ztfi_contab_cab,
          gt_contab_item TYPE TABLE OF ztfi_contab_item,
          gs_contab_item TYPE ztfi_contab_item.

    METHODS:
      process_data
        RAISING
          zclfi_cx_lancamento_contabil,

      "! Raising erro
      erro
        IMPORTING
          is_erro TYPE scx_t100key
        RAISING
          zclfi_cx_lancamento_contabil.
ENDCLASS.



CLASS ZCLFI_LANCAMENTO_CONTABIL IMPLEMENTATION.


  METHOD get_data.
    MOVE-CORRESPONDING is_input TO gs_input.
    me->process_data( ).
  ENDMETHOD.


  METHOD process_data.

    TYPES: BEGIN OF  ty_skb1,
             saknr TYPE esh_n_gl_acc_cocd_skb1-saknr,
             bukrs TYPE esh_n_gl_acc_cocd_skb1-saknr,
           END OF ty_skb1.

    TYPES: BEGIN OF ty_no_auth,
             kostl TYPE vfco_csks_shv_no_auth-kostl,
             kokrs TYPE vfco_csks_shv_no_auth-kostl,
           END OF ty_no_auth.

    DATA: lt_no_auth         TYPE TABLE OF ty_no_auth,
          lt_skb1            TYPE TABLE OF ty_skb1,
          lv_cnpj_fmt        TYPE pbr99_cgc,
          lv_cgc_number_raw  TYPE pbr99_cgc,
          lv_check_conta     TYPE c,
          lv_range           TYPE inri-nrrangenr VALUE '01',
          lv_object          TYPE inri-object    VALUE 'ZFI_MOVFOL',
          lv_identificacao   TYPE char10,
          lv_data            TYPE sy-datum,
          lv_hora            TYPE sy-uzeit,
          lv_data_char10     TYPE char10,
          lv_text_status(50) TYPE c.

    DATA(lv_comp_code_length) = strlen( gs_input-mt_contabil_lancamento-bukrs ).
    IF lv_comp_code_length = 14.

      lv_cnpj_fmt = gs_input-mt_contabil_lancamento-bukrs.
      CALL FUNCTION 'HR_BR_CHECK_CGC_FORMAT' "
        EXPORTING
          cgc_number               = lv_cnpj_fmt
        IMPORTING
*         cgc_number_formatted     =      " pbr99_cgc
          cgc_number_raw           = lv_cgc_number_raw
        EXCEPTIONS
          cgc_format_not_supported = 1
          cgc_check_digit          = 2.
      IF sy-subrc = 0.
        gs_input-mt_contabil_lancamento-bukrs = lv_cgc_number_raw(8).
      ENDIF.

    ENDIF.

    SELECT SINGLE companycode
        INTO @DATA(lv_companycode)
        FROM p_companycodeaddl
        WHERE paval = @gs_input-mt_contabil_lancamento-bukrs
        AND   party = 'J_1BCG'.
    IF sy-subrc = 0.

      SELECT saknr,
             bukrs
          INTO TABLE @lt_skb1
          FROM esh_n_gl_acc_cocd_skb1
          WHERE bukrs = @lv_companycode.

      SORT lt_skb1 BY saknr.

      SELECT kostl,
             kokrs
          INTO TABLE @lt_no_auth
          FROM vfco_csks_shv_no_auth
          WHERE kokrs = 'AC3C'.

      IF sy-subrc = 0.

        SORT lt_no_auth BY kostl."kokrs.

        CALL FUNCTION 'NUMBER_GET_NEXT'
          EXPORTING
            nr_range_nr             = lv_range
            object                  = lv_object
          IMPORTING
            number                  = lv_identificacao
          EXCEPTIONS
            interval_not_found      = 1
            number_range_not_intern = 2
            object_not_found        = 3
            quantity_is_0           = 4
            quantity_is_not_1       = 5
            interval_overflow       = 6
            buffer_overflow         = 7
            OTHERS                  = 8.
        IF sy-subrc <> 0.
          MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                  WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
        ENDIF.

        TRY.
            DATA(lv_guid) = cl_system_uuid=>create_uuid_x16_static( ).
          CATCH cx_uuid_error.
        ENDTRY.

        gs_contab_cab-client          = sy-mandt.
        gs_contab_cab-id              = lv_guid.
        gs_contab_cab-identificacao   = lv_identificacao.
        gs_contab_cab-status          = 'S'.
        gs_contab_cab-empresa         = lv_companycode.

*      CONVERT TIME STAMP gs_input-mt_contabil_lancamento-bldat TIME ZONE sy-zonlo INTO DATE lv_data TIME lv_hora.

        lv_data_char10 = gs_input-mt_contabil_lancamento-bldat.
        REPLACE ALL OCCURRENCES OF '-' IN lv_data_char10 WITH ''.
        gs_contab_cab-data_documento  = lv_data_char10.

*      CONVERT TIME STAMP gs_input-mt_contabil_lancamento-budat TIME ZONE sy-zonlo INTO DATE lv_data TIME lv_hora.
        lv_data_char10 = gs_input-mt_contabil_lancamento-budat.
        REPLACE ALL OCCURRENCES OF '-' IN lv_data_char10 WITH ''.
        gs_contab_cab-data_lancamento = lv_data_char10(8).


        gs_contab_cab-tipo_documento  = gs_input-mt_contabil_lancamento-blart.
        gs_contab_cab-referencia      = gs_input-mt_contabil_lancamento-xblnr.
        gs_contab_cab-text_cab        = gs_input-mt_contabil_lancamento-bgtxt.
        gs_contab_cab-text_status     = ''.

        LOOP AT gs_input-mt_contabil_lancamento-itens ASSIGNING FIELD-SYMBOL(<fs_itens>).
          CONCATENATE TEXT-003 <fs_itens>-hkont TEXT-004 gs_contab_cab-empresa INTO lv_text_status SEPARATED BY space.
          TRANSLATE <fs_itens>-kostl TO UPPER CASE.

          READ TABLE lt_skb1 ASSIGNING FIELD-SYMBOL(<fs_skb1>) WITH KEY saknr = <fs_itens>-hkont BINARY SEARCH.
          IF sy-subrc <> 0.
            gs_contab_cab-status          = 'E'.
            gs_contab_cab-text_status     = lv_text_status.
            MODIFY ztfi_contab_cab FROM gs_contab_cab.
            IF sy-subrc = 0.
              COMMIT WORK.
            ENDIF.
            DATA: lt_return TYPE bapiret2_t.
            RAISE EXCEPTION TYPE zclfi_cx_lancamento_contabil
              EXPORTING
                textid   = zclfi_cx_lancamento_contabil=>gc_erro_proc_lanc
                iv_msgv1 = CONV #( <fs_itens>-hkont )
                iv_msgv2 = CONV #( gs_contab_cab-empresa ).
          ENDIF.

          IF <fs_itens>-hkont(1) = 4.
            IF <fs_itens>-kostl IS INITIAL.
*              EXIT.

              READ TABLE lt_no_auth ASSIGNING FIELD-SYMBOL(<fs_no_auth1>) WITH KEY kostl = <fs_itens>-kostl BINARY SEARCH.
              IF sy-subrc <> 0.

                CALL FUNCTION 'NUMBER_GET_NEXT'
                  EXPORTING
                    nr_range_nr             = lv_range
                    object                  = lv_object
                  IMPORTING
                    number                  = lv_identificacao
                  EXCEPTIONS
                    interval_not_found      = 1
                    number_range_not_intern = 2
                    object_not_found        = 3
                    quantity_is_0           = 4
                    quantity_is_not_1       = 5
                    interval_overflow       = 6
                    buffer_overflow         = 7
                    OTHERS                  = 8.
                IF sy-subrc <> 0.
                  MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                          WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
                ENDIF.

                TRY.
                    DATA(lv_guid_error_c1) = cl_system_uuid=>create_uuid_x16_static( ).
                  CATCH cx_uuid_error.
                ENDTRY.

                READ TABLE gs_input-mt_contabil_lancamento-itens ASSIGNING FIELD-SYMBOL(<fs_itens_erro_c1>) INDEX 1.

                gs_contab_cab-client          = sy-mandt.
                gs_contab_cab-id              = lv_guid_error_c1.
                gs_contab_cab-identificacao   = lv_identificacao.
                gs_contab_cab-empresa         = lv_companycode.
                CONCATENATE TEXT-001 <fs_itens_erro_c1>-kostl TEXT-002 INTO lv_text_status SEPARATED BY space.
                gs_contab_cab-status          = 'E'.
                gs_contab_cab-text_status     = lv_text_status.
                MODIFY ztfi_contab_cab FROM gs_contab_cab.
                IF sy-subrc = 0.
                  COMMIT WORK.
                ENDIF.
                RAISE EXCEPTION TYPE zclfi_cx_lancamento_contabil
                  EXPORTING
                    textid   = zclfi_cx_lancamento_contabil=>gc_erro_proc_lanc_centro
                    iv_msgv1 = CONV #( gs_contab_cab-empresa ).

                EXIT.
              ENDIF.
            ENDIF.

          ELSE.

            IF <fs_itens>-kostl IS NOT INITIAL.
              READ TABLE lt_no_auth ASSIGNING FIELD-SYMBOL(<fs_no_auth2>) WITH KEY kostl = <fs_itens>-kostl BINARY SEARCH.
              IF sy-subrc <> 0.

                CALL FUNCTION 'NUMBER_GET_NEXT'
                  EXPORTING
                    nr_range_nr             = lv_range
                    object                  = lv_object
                  IMPORTING
                    number                  = lv_identificacao
                  EXCEPTIONS
                    interval_not_found      = 1
                    number_range_not_intern = 2
                    object_not_found        = 3
                    quantity_is_0           = 4
                    quantity_is_not_1       = 5
                    interval_overflow       = 6
                    buffer_overflow         = 7
                    OTHERS                  = 8.
                IF sy-subrc <> 0.
                  MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                          WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
                ENDIF.

                TRY.
                    DATA(lv_guid_error_c2) = cl_system_uuid=>create_uuid_x16_static( ).
                  CATCH cx_uuid_error.
                ENDTRY.

                READ TABLE gs_input-mt_contabil_lancamento-itens ASSIGNING FIELD-SYMBOL(<fs_itens_erro_c2>) INDEX 1.

                gs_contab_cab-client          = sy-mandt.
                gs_contab_cab-id              = lv_guid_error_c2.
                gs_contab_cab-identificacao   = lv_identificacao.
                gs_contab_cab-empresa         = lv_companycode.
                CONCATENATE TEXT-001 <fs_itens_erro_c2>-kostl TEXT-002 INTO lv_text_status SEPARATED BY space.
                gs_contab_cab-status          = 'E'.
                gs_contab_cab-text_status     = lv_text_status.
                MODIFY ztfi_contab_cab FROM gs_contab_cab.
                IF sy-subrc = 0.
                  COMMIT WORK.
                ENDIF.
                RAISE EXCEPTION TYPE zclfi_cx_lancamento_contabil
                  EXPORTING
                    textid   = zclfi_cx_lancamento_contabil=>gc_erro_proc_lanc_centro
                    iv_msgv1 = CONV #( gs_contab_cab-empresa ).

                EXIT.

              ENDIF.
            ENDIF.
          ENDIF.

          gs_contab_item-id            = lv_guid.
          gs_contab_item-client        = sy-mandt.
          gs_contab_item-identificacao = lv_identificacao.
          gs_contab_item-item          = <fs_itens>-buzei.
          gs_contab_item-deb_cred      = <fs_itens>-stat_con.
          gs_contab_item-atribuicao    = <fs_itens>-zuonr.
          gs_contab_item-conta         = <fs_itens>-hkont.
          gs_contab_item-divisao       = <fs_itens>-gsber.
          gs_contab_item-centro_custo  = <fs_itens>-kostl.
          gs_contab_item-centro_lucro  = <fs_itens>-prctr.
          gs_contab_item-segmento      = ''.
          gs_contab_item-texto_item    = <fs_itens>-sgtxt.

          DATA: lv_valor(10) TYPE c.
          lv_valor = <fs_itens>-dmbtr_shl.
          REPLACE ',' WITH '.' INTO lv_valor.
          gs_contab_item-valor         = lv_valor.
          gs_contab_item-moeda         = 'BRL'.
          gs_contab_item-texto_erro    = ''.
          APPEND gs_contab_item TO gt_contab_item.
          CLEAR: gs_contab_item.
        ENDLOOP.

        IF gt_contab_item IS NOT INITIAL.
          MODIFY ztfi_contab_cab FROM gs_contab_cab.
          IF sy-subrc = 0.
            COMMIT WORK.
          ENDIF.

          MODIFY ztfi_contab_item FROM TABLE gt_contab_item.

          IF sy-subrc = 0.
            COMMIT WORK.
          ENDIF.

*          LOOP AT gt_contab_item ASSIGNING FIELD-SYMBOL(<fs_contab_item>).
*            MODIFY ztfi_contab_item FROM <fs_contab_item>.
*            IF sy-subrc = 0.
*              COMMIT WORK.
*            ENDIF.
*
*          ENDLOOP.

        ENDIF.

      ENDIF.
    ELSE.

      CALL FUNCTION 'NUMBER_GET_NEXT'
        EXPORTING
          nr_range_nr             = lv_range
          object                  = lv_object
        IMPORTING
          number                  = lv_identificacao
        EXCEPTIONS
          interval_not_found      = 1
          number_range_not_intern = 2
          object_not_found        = 3
          quantity_is_0           = 4
          quantity_is_not_1       = 5
          interval_overflow       = 6
          buffer_overflow         = 7
          OTHERS                  = 8.
      IF sy-subrc <> 0.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      ENDIF.

      TRY.
          DATA(lv_guid_error_e) = cl_system_uuid=>create_uuid_x16_static( ).
        CATCH cx_uuid_error.
      ENDTRY.

      gs_contab_cab-client          = sy-mandt.
      gs_contab_cab-id              = lv_guid_error_e.
      gs_contab_cab-identificacao   = lv_identificacao.
*      gs_contab_cab-empresa         = gs_input-mt_contabil_lancamento-bukrs.
      CONCATENATE TEXT-005 gs_input-mt_contabil_lancamento-bukrs TEXT-002 INTO lv_text_status SEPARATED BY space.
      gs_contab_cab-status          = 'E'.
      gs_contab_cab-text_status     = lv_text_status.
      MODIFY ztfi_contab_cab FROM gs_contab_cab.
      IF sy-subrc = 0.
        COMMIT WORK.
      ENDIF.
      RAISE EXCEPTION TYPE zclfi_cx_lancamento_contabil
        EXPORTING
          textid   = zclfi_cx_lancamento_contabil=>gc_erro_proc_lanc_empresa
          iv_msgv1 = CONV #( gs_contab_cab-empresa ).

    ENDIF.

  ENDMETHOD.


  METHOD erro.

*    RAISE EXCEPTION TYPE zcxfi_erro_interface
*      EXPORTING
*        textid = is_erro.

    DATA: lt_bapireturn_tab TYPE bapirettab,
          ls_bapiret2       TYPE bapiret2.

    APPEND VALUE #(
        id = 'ZTESTE'
        number = '002'
        message = text-006
    ) TO lt_bapireturn_tab.

    CALL METHOD cl_proxy_fault=>raise
      EXPORTING
        exception_class_name = 'ZCLFI_CX_FMT_CONTABI_LANCAMENT'
        bapireturn_tab       = lt_bapireturn_tab.


  ENDMETHOD.
ENDCLASS.
