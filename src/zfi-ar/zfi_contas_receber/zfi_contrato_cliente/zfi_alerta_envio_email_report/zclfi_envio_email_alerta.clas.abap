CLASS zclfi_envio_email_alerta DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    TYPES:
      BEGIN OF  ty_envio,
        contrato          TYPE ztfi_contrato-contrato,
        aditivo           TYPE ztfi_contrato-aditivo,
        data_fim_valid    TYPE ztfi_contrato-data_fim_valid,
        bukrs             TYPE ztfi_contrato-bukrs,
        branch            TYPE ztfi_contrato-branch,
        prazo_pagto       TYPE ztfi_contrato-prazo_pagto,
        renov_aut         TYPE ztfi_contrato-renov_aut,
        alerta_enviado    TYPE ztfi_contrato-alerta_enviado,
        alerta_data_envio TYPE ztfi_contrato-alerta_data_envio,
        email             TYPE ztfi_contratos13-email.
    TYPES: END OF ty_envio .

    DATA:
      gt_envio TYPE SORTED TABLE OF ty_envio WITH NON-UNIQUE KEY contrato .

    "! @parameter IT_EMAILAPP | Tabela de retorno para o APP
    METHODS envio_emailapp
      IMPORTING
        !it_emailapp       TYPE zctgfi_rfc_envioemail OPTIONAL
      EXPORTING
        !ev_status_retorno TYPE char1
        !et_return         TYPE bapiret2_tab .
    METHODS initialize_log .
  PROTECTED SECTION.
  PRIVATE SECTION.

    DATA gs_return TYPE bapiret2 .
    DATA gt_return TYPE bapiret2_t .
    DATA gv_job TYPE btcjob .
    DATA gv_log_handle TYPE balloghndl .

    METHODS message_save
      IMPORTING
        !is_msg TYPE bapiret2 .
ENDCLASS.



CLASS zclfi_envio_email_alerta IMPLEMENTATION.


  METHOD envio_emailapp.

    CONSTANTS: lc_type            TYPE so_obj_tp VALUE 'RAW'.
    DATA:
      lv_size         TYPE i,
      lv_error_log    TYPE abap_bool,
      lv_email_sub    TYPE string,
      lv_subject      TYPE so_obj_des,
      lv_dummy        TYPE string,
      lt_bindata      TYPE solix_tab,
      lt_message_body TYPE bcsy_text              VALUE IS INITIAL,
      lo_document     TYPE REF TO cl_document_bcs VALUE IS INITIAL,
      ls_cond_text    TYPE ztfi_cad_cond.

    DATA: lt_text       TYPE char255,
          lv_percet     TYPE char11,
          lv_mont       TYPE char11,
          lv_output     TYPE char10,
          lv_percentual TYPE char30,
          lv_montante   TYPE char30,
          lv_cnpj       TYPE char20.

    DATA: lo_send_request TYPE REF TO cl_bcs        VALUE IS INITIAL,
          lo_sender       TYPE REF TO if_sender_bcs VALUE IS INITIAL,
          lv_send         TYPE adr6-smtp_addr       VALUE IS INITIAL.

    DATA: lt_emailapp	TYPE zctgfi_rfc_envioemail.

    lt_emailapp[] = it_emailapp.
    SORT lt_emailapp BY doc_uuid_h.
    DELETE ADJACENT DUPLICATES FROM lt_emailapp COMPARING doc_uuid_h.

    IF lt_emailapp[] IS NOT INITIAL.
      SELECT empresa,
             local_negocio,
             email
      FROM ztfi_contratos13
      INTO TABLE @DATA(lt_emails)
      FOR ALL ENTRIES IN @lt_emailapp
      WHERE empresa EQ @lt_emailapp-bukrs
      AND local_negocio EQ @lt_emailapp-branch .

      SORT: lt_emails BY empresa local_negocio.

      SELECT doc_uuid_h,
             tipo_cond,
             percentual,
             montante
      FROM ztfi_cont_cond
      INTO TABLE @DATA(lt_cond)
      FOR ALL ENTRIES IN @lt_emailapp
      WHERE doc_uuid_h EQ @lt_emailapp-doc_uuid_h.

      SORT lt_cond BY doc_uuid_h.

    ENDIF.


    IF lt_cond[] IS NOT INITIAL.
      SELECT *
       FROM ztfi_cad_cond
       INTO TABLE @DATA(lt_cond_text)
       FOR ALL ENTRIES IN @lt_cond
       WHERE tipo_cond = @lt_cond-tipo_cond.
      SORT lt_cond_text BY tipo_cond.
    ENDIF.

    LOOP AT lt_emailapp ASSIGNING FIELD-SYMBOL(<fs_envio>).

      CLEAR:lt_message_body.
      REFRESH: lt_message_body.

      WRITE <fs_envio>-cnpj_principal USING EDIT MASK '__.___.___/____-__' TO lv_cnpj.

      CONCATENATE: TEXT-000 <fs_envio>-contrato
                   TEXT-001 <fs_envio>-aditivo ','
                   TEXT-015 <fs_envio>-razao_social ','
                   'CNPJ' lv_cnpj   INTO lt_text SEPARATED BY space.
      APPEND lt_text TO lt_message_body. CLEAR:lt_text.

      CONCATENATE: ',' TEXT-014 INTO lt_text SEPARATED BY space.
      APPEND lt_text TO lt_message_body. CLEAR:lt_text.

      CALL FUNCTION 'CONVERSION_EXIT_PDATE_OUTPUT'
        EXPORTING
          input  = <fs_envio>-data_fim_valid
        IMPORTING
          output = lv_output.


      IF lv_output IS NOT INITIAL.
        CONCATENATE: TEXT-012
                      lv_output
                      TEXT-013 INTO lt_text SEPARATED BY space.
        APPEND lt_text TO lt_message_body. CLEAR:lt_text.
      ELSE.
        CONCATENATE: TEXT-012
                      <fs_envio>-data_fim_valid
                      TEXT-013 INTO lt_text SEPARATED BY space.
        APPEND lt_text TO lt_message_body.
      ENDIF.



      APPEND TEXT-011 TO lt_message_body. CLEAR:lt_text.

      CONCATENATE: TEXT-006 <fs_envio>-bukrs INTO lt_text SEPARATED BY space.
      APPEND lt_text TO lt_message_body. CLEAR:lt_text.

      CONCATENATE: TEXT-007 <fs_envio>-branch INTO lt_text SEPARATED BY space.
      APPEND lt_text TO lt_message_body. CLEAR:lt_text.

      CONCATENATE: TEXT-005 <fs_envio>-prazo_pagto INTO lt_text SEPARATED BY space.
      APPEND lt_text TO lt_message_body. CLEAR:lt_text.

      READ TABLE lt_cond TRANSPORTING NO FIELDS WITH KEY doc_uuid_h = <fs_envio>-doc_uuid_h BINARY SEARCH.
      IF sy-subrc IS INITIAL.
        LOOP AT lt_cond ASSIGNING FIELD-SYMBOL(<fs_cond>) FROM sy-tabix.
          IF <fs_cond>-doc_uuid_h <> <fs_envio>-doc_uuid_h.
            EXIT.
          ENDIF.
          lv_percet = <fs_cond>-percentual.
          lv_mont   = <fs_cond>-montante.

          WRITE <fs_cond>-percentual TO lv_percentual.
          CONDENSE lv_percentual NO-GAPS.
          CONCATENATE lv_percentual '%' INTO lv_percentual SEPARATED BY space.
          WRITE <fs_cond>-montante TO lv_montante CURRENCY 'BRL'.
          CONDENSE lv_montante NO-GAPS.
          CONCATENATE 'R$:' lv_montante INTO lv_montante SEPARATED BY space.

          READ TABLE lt_cond_text INTO ls_cond_text WITH KEY tipo_cond = <fs_cond>-tipo_cond
                                                                          BINARY SEARCH.

          CONCATENATE: TEXT-008 <fs_cond>-tipo_cond ls_cond_text-text_tipo_cond lv_percentual lv_montante INTO lt_text SEPARATED BY space.
          APPEND lt_text TO lt_message_body. CLEAR:lt_text.

        ENDLOOP.
      ENDIF.


      lv_subject = TEXT-010.

      TRY.
          lo_send_request = cl_bcs=>create_persistent( ).
        CATCH cx_send_req_bcs.

      ENDTRY.


      TRY.
          lo_document = cl_document_bcs=>create_document(
            i_type    = lc_type
            i_text    = lt_message_body
            i_subject = lv_subject ).
        CATCH cx_document_bcs.
          "handle exception
      ENDTRY.

      TRY.
          lo_send_request->set_document( lo_document ).
        CATCH cx_send_req_bcs.
          "handle exception
      ENDTRY.


      DATA:lo_recipient TYPE REF TO if_recipient_bcs VALUE IS INITIAL.

      READ TABLE lt_emails TRANSPORTING NO FIELDS WITH KEY empresa = <fs_envio>-bukrs
                                                           local_negocio = <fs_envio>-branch
                                                           BINARY SEARCH.
      IF sy-subrc = 0.
        LOOP AT lt_emails ASSIGNING FIELD-SYMBOL(<fs_email>) FROM sy-tabix.

          IF <fs_envio>-bukrs <> <fs_email>-empresa OR
             <fs_envio>-branch <> <fs_email>-local_negocio.
            EXIT.
          ENDIF.

          lv_send = <fs_email>-email.
          TRY.
              lo_recipient = cl_cam_address_bcs=>create_internet_address( lv_send ).
            CATCH cx_address_bcs.
              "handle exception
          ENDTRY.

          TRY.
              lo_send_request->add_recipient(
                EXPORTING
                  i_recipient = lo_recipient
                  i_express   = abap_true ).
            CATCH cx_send_req_bcs.
              "handle exception
          ENDTRY.

        ENDLOOP.
      ENDIF.

      DATA: lv_sent_to_all(1) TYPE c VALUE IS INITIAL.
      TRY.
          lo_send_request->send(
            EXPORTING
              i_with_error_screen = abap_true
            RECEIVING
              result              = lv_sent_to_all ).
        CATCH cx_send_req_bcs.
          "handle exception
      ENDTRY.

      IF lv_sent_to_all EQ abap_true.

        UPDATE ztfi_contrato SET alerta_enviado = abap_true "#EC CI_IMUD_NESTED
                                 alerta_data_envio = sy-datum
                              WHERE doc_uuid_h = <fs_envio>-doc_uuid_h
                                AND contrato   = <fs_envio>-contrato
                                AND aditivo    = <fs_envio>-aditivo.
        COMMIT WORK AND WAIT.

        CLEAR gs_return.
        MESSAGE s002 INTO lv_dummy WITH <fs_envio>-contrato <fs_envio>-aditivo.
        gs_return-type       = sy-msgty.
        gs_return-id         = sy-msgid.
        gs_return-number     = sy-msgno.
        gs_return-message_v1 = sy-msgv1.
        gs_return-message_v2 = sy-msgv2.
        gs_return-message_v3 = sy-msgv3.
        gs_return-message_v4 = sy-msgv4.
        APPEND gs_return TO gt_return.

        MESSAGE i013(zfi_contrato_cliente) INTO lv_dummy.
        gs_return-type       = sy-msgty.
        gs_return-id         = sy-msgid.
        gs_return-number     = sy-msgno.
        gs_return-message_v1 = sy-msgv1.
        gs_return-message_v2 = sy-msgv2.
        gs_return-message_v3 = sy-msgv3.
        gs_return-message_v4 = sy-msgv4.
        APPEND gs_return TO gt_return.


        IF sy-batch EQ abap_true.
          message_save( is_msg = gs_return ).
*          MESSAGE s002.
        ENDIF.
      ELSE.

        "Erro ao enviar e-mail:contrato &1 / aditivo &2
        MESSAGE i004 INTO lv_dummy WITH <fs_envio>-contrato <fs_envio>-aditivo.
        gs_return-type       = sy-msgty.
        gs_return-id         = sy-msgid.
        gs_return-number     = sy-msgno.
        gs_return-message_v1 = sy-msgv1.
        gs_return-message_v2 = sy-msgv2.
        gs_return-message_v3 = sy-msgv3.
        gs_return-message_v4 = sy-msgv4.
        APPEND gs_return TO gt_return.

        MESSAGE i013(zfi_contrato_cliente) INTO lv_dummy.
        gs_return-type       = sy-msgty.
        gs_return-id         = sy-msgid.
        gs_return-number     = sy-msgno.
        gs_return-message_v1 = sy-msgv1.
        gs_return-message_v2 = sy-msgv2.
        gs_return-message_v3 = sy-msgv3.
        gs_return-message_v4 = sy-msgv4.
        APPEND gs_return TO gt_return.

        IF sy-batch EQ abap_true.
          message_save( is_msg = gs_return ).
*          MESSAGE s002.
        ENDIF.

      ENDIF.
    ENDLOOP.

    et_return = gt_return.

  ENDMETHOD.


  METHOD initialize_log.

    CONSTANTS: BEGIN OF lc_log,
                 obj TYPE bal_s_log-object    VALUE 'ZFI_ALERTA_CONTRATO',
                 sub TYPE bal_s_log-subobject VALUE 'EMAIL',
               END OF lc_log.


    DATA: ls_log        TYPE bal_s_log.

    ls_log-extnumber = gv_job.
    ls_log-aluser    = sy-uname.
    ls_log-alprog    = sy-repid.
    ls_log-object    = lc_log-obj.
    ls_log-subobject = lc_log-sub.

    CALL FUNCTION 'BAL_LOG_CREATE'
      EXPORTING
        i_s_log      = ls_log
      IMPORTING
        e_log_handle = gv_log_handle
      EXCEPTIONS
        OTHERS       = 1.

    IF sy-subrc IS NOT INITIAL.
      DATA(lv_erro) = abap_true.
    ENDIF.

    IF NOT sy-batch IS INITIAL.

      CALL FUNCTION 'BP_ADD_APPL_LOG_HANDLE'
        EXPORTING
          loghandle = gv_log_handle
        EXCEPTIONS
          OTHERS    = 4.

      IF sy-subrc IS NOT INITIAL.
        lv_erro = abap_true.
      ENDIF.

    ENDIF.

  ENDMETHOD.


  METHOD message_save.
    DATA: ls_msg        TYPE bal_s_msg,
          lt_log_handle TYPE bal_t_logh.

    APPEND gv_log_handle TO lt_log_handle.

    ls_msg-msgty     = is_msg-type.
    ls_msg-msgid     = is_msg-id.
    ls_msg-msgno     = is_msg-number.
    ls_msg-msgv1     = is_msg-message_v1.
    ls_msg-msgv2     = is_msg-message_v2.
    ls_msg-msgv3     = is_msg-message_v3.
    ls_msg-msgv4     = is_msg-message_v4.
    ls_msg-probclass = '1'.


    CALL FUNCTION 'BAL_LOG_MSG_ADD'
      EXPORTING
        i_log_handle     = gv_log_handle
        i_s_msg          = ls_msg
      EXCEPTIONS
        log_not_found    = 1
        msg_inconsistent = 2
        log_is_full      = 3
        OTHERS           = 4.

    IF sy-subrc IS NOT INITIAL.
      DATA(lv_erro) = abap_true.
    ENDIF.

    CALL FUNCTION 'BAL_DB_SAVE'
      EXPORTING
*       i_save_all     = 'X' "can cause dumps
        i_t_log_handle = lt_log_handle
      EXCEPTIONS
        OTHERS         = 4.

    IF sy-subrc IS NOT INITIAL.
      lv_erro = abap_true.
    ENDIF.

  ENDMETHOD.
ENDCLASS.
