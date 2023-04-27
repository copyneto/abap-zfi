"Name: \TY:CL_GOS_DOCUMENT_SERVICE\ME:CREATE_ATTACHMENT\SE:END\EI
ENHANCEMENT 0 ZEIFI_ATT_WF.

  IF is_object-objtype EQ 'BKPF'.

    SELECT *
      FROM ztfi_wf_log
      INTO TABLE @DATA(lt_wf_log)
     WHERE empresa          EQ @is_object-objkey(4)
       AND documento        EQ @is_object-objkey+4(10)
       AND exercicio        EQ @is_object-objkey+14(4)
       AND status_aprovacao EQ '2'.

    IF sy-subrc EQ 0.

      SORT lt_wf_log BY task_id.
      DELETE lt_wf_log WHERE task_id IS INITIAL.
      DELETE ADJACENT DUPLICATES FROM lt_wf_log COMPARING task_id.
      READ TABLE lt_wf_log ASSIGNING FIELD-SYMBOL(<fs_wf_log>) INDEX 1.

      DATA: lv_document_id   TYPE sofolenti1-doc_id,
            ls_document_data TYPE sofolenti1.
      DATA: lt_obj_content TYPE TABLE OF solisti1,
            lt_obj_hex     TYPE TABLE OF solix.

      lv_document_id = document(34).

      CALL FUNCTION 'SO_DOCUMENT_READ_API1'
        EXPORTING
          document_id                = lv_document_id
        IMPORTING
          document_data              = ls_document_data
        TABLES
          object_content             = lt_obj_content
          contents_hex               = lt_obj_hex
        EXCEPTIONS
          document_id_not_exist      = 1
          operation_no_authorization = 2
          x_error                    = 3
          OTHERS                     = 4.

      IF sy-subrc <> 0.
*       Implement suitable error handling here
      ENDIF.

      DATA(ls_header) = VALUE swr_att_header(
        file_type      = 'B'
        file_name      = ls_document_data-obj_descr
        file_extension = ls_document_data-obj_type
        language       = sy-langu
      ).

      DATA: lv_id      TYPE swr_struct-workitemid,
            lv_att_bin TYPE xstring.

      lv_id = <fs_wf_log>-task_id.

      DESCRIBE TABLE lt_obj_hex LINES DATA(lv_line).
      DATA(lv_input_len)  = lv_line * 255.

      CALL FUNCTION 'SCMS_BINARY_TO_XSTRING'
        EXPORTING
          input_length = lv_input_len
          first_line   = 1
          last_line    = lv_line
        IMPORTING
          buffer       = lv_att_bin
        TABLES
          binary_tab   = lt_obj_hex
        EXCEPTIONS
          failed       = 1
          OTHERS       = 2.

      IF sy-subrc <> 0.
*       Implement suitable error handling here
      ENDIF.

      DATA: return_code TYPE  sy-subrc,
            att_id      TYPE  swr_att_id,
            doc_size    TYPE  i.

      CALL FUNCTION 'SAP_WAPI_ATTACHMENT_ADD'
        STARTING NEW TASK lv_id
        EXPORTING
          workitem_id = lv_id
          att_header  = ls_header
          att_bin     = lv_att_bin
          do_commit   = 'X'.

    ENDIF.

  ENDIF.

ENDENHANCEMENT.
