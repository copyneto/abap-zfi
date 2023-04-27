"Name: \TY:CL_GOS_DOCUMENT_SERVICE\ME:DELETE_ATTACHMENT\SE:END\EI
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
    DELETE ADJACENT DUPLICATES FROM lt_wf_log COMPARING task_id.
    READ TABLE lt_wf_log ASSIGNING FIELD-SYMBOL(<fs_wf_log>) INDEX 1.

    DATA: lv_id     TYPE swr_struct-workitemid,
          ls_att_id TYPE swr_att_id.

    lv_id = <fs_wf_log>-task_id.

    ls_att_id-doc_cat = 'SO'."ls_object-catid.
    ls_att_id-doc_id  = ls_object-instid.

    data(lv_reg) = ls_att_id-doc_id+31(4).
    add 1 to lv_reg.
    ls_att_id-doc_id+31(4) = lv_reg.

    CALL FUNCTION 'SAP_WAPI_ATTACHMENT_DELETE'
      STARTING NEW TASK lv_id
      EXPORTING
        workitem_id     = lv_id
        att_id          = ls_att_id
        do_commit       = 'X'
        delete_document = 'X'.

  ENDIF.

ENDIF.
ENDENHANCEMENT.
