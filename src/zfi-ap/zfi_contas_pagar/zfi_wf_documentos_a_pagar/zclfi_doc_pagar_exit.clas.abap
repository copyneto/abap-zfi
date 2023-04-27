class ZCLFI_DOC_PAGAR_EXIT definition
  public
  final
  create public .

public section.

  interfaces IF_SWF_IFS_WORKITEM_EXIT .
protected section.
private section.
ENDCLASS.



CLASS ZCLFI_DOC_PAGAR_EXIT IMPLEMENTATION.


  METHOD if_swf_ifs_workitem_exit~event_raised.

    DATA: ls_workitem  TYPE sibflporb,
          lt_approvers TYPE zctgfi_aprovadores,
          lv_nivel     TYPE n LENGTH 2,
          lt_log       TYPE TABLE OF ztfi_wf_log,
          lv_belnr     TYPE belnr_d,
          lv_bukrs     TYPE bukrs,
          lv_gjahr     TYPE gjahr,
          lv_buzei     TYPE buzei,
          ls_result    TYPE swd_lines-returncode.

    CASE im_event_name.

      WHEN 'CREATED'.

        TRY.

            CALL METHOD im_workitem_context->get_workitem_id
              RECEIVING
                re_workitem = DATA(lv_task_id).

            CALL METHOD im_workitem_context->get_wi_container
              RECEIVING
                re_container = DATA(ls_wi_container).

            CALL METHOD im_workitem_context->get_top_container
              RECEIVING
                re_container = DATA(lv_top_container).

            CALL METHOD lv_top_container->get
              EXPORTING
                name  = '_WORKITEM'
              IMPORTING
                value = ls_workitem.

            CALL METHOD lv_top_container->get
              EXPORTING
                name  = 'ET_APPROVERS'
              IMPORTING
                value = lt_approvers.

            CALL METHOD lv_top_container->get
              EXPORTING
                name  = 'GV_NIVEL'
              IMPORTING
                value = lv_nivel.

            CALL METHOD lv_top_container->get
              EXPORTING
                name  = 'GV_BUKRS'
              IMPORTING
                value = lv_bukrs.

            CALL METHOD lv_top_container->get
              EXPORTING
                name  = 'GV_BELNR'
              IMPORTING
                value = lv_belnr.

            CALL METHOD lv_top_container->get
              EXPORTING
                name  = 'GV_GJAHR'
              IMPORTING
                value = lv_gjahr.

            CALL METHOD lv_top_container->get
              EXPORTING
                name  = 'GV_BUZEI'
              IMPORTING
                value = lv_buzei.

            SELECT *
              FROM ztfi_wf_log
              INTO TABLE lt_log
             WHERE wf_id     EQ ls_workitem-instid
               AND empresa   EQ lv_bukrs
               AND documento EQ lv_belnr
               AND exercicio EQ lv_gjahr
               AND item      EQ lv_buzei.

            IF sy-subrc NE 0.

              TRY.
                  DATA(lv_uuid) = cl_system_uuid=>create_uuid_x16_static( ).
                CATCH cx_uuid_error.
              ENDTRY.

*            DELETE lt_approvers WHERE zlevel NE lv_nivel.

              LOOP AT lt_approvers ASSIGNING FIELD-SYMBOL(<fs_approvers>).
                APPEND INITIAL LINE TO lt_log ASSIGNING FIELD-SYMBOL(<fs_log>).
                <fs_log>-uuid             = lv_uuid.
                <fs_log>-wf_id            = ls_workitem-instid.
                IF <fs_approvers>-zlevel EQ lv_nivel.
                  <fs_log>-task_id          = lv_task_id.
                ENDIF.
                <fs_log>-nivel_aprovacao  = <fs_approvers>-zlevel.
                <fs_log>-aprovador        = <fs_approvers>-objid.
                <fs_log>-data             = sy-datum.
                <fs_log>-hora             = sy-uzeit.
                <fs_log>-empresa          = lv_bukrs.
                <fs_log>-documento        = lv_belnr.
                <fs_log>-exercicio        = lv_gjahr.
                <fs_log>-item             = lv_buzei.
                <fs_log>-status_aprovacao = '2'.
              ENDLOOP.

            ELSE.

              LOOP AT lt_log ASSIGNING <fs_log>.

                IF <fs_log>-nivel_aprovacao EQ lv_nivel.
                  <fs_log>-task_id = lv_task_id.
                ENDIF.

              ENDLOOP.

            ENDIF.

            MODIFY ztfi_wf_log FROM TABLE lt_log.

          CATCH cx_swf_cnt_elem_not_found.     " Name Entered Is Unknown
          CATCH cx_swf_cnt_elem_type_conflict. " Value Not Type Compatible to Current Parameter
          CATCH cx_swf_cnt_unit_type_conflict. " Unit Not Type Compatible to the Current Parameter
          CATCH cx_swf_cnt_container.          " Exception in the Container Service

        ENDTRY.

      WHEN 'AFT_EXEC'.

        TRY.

            CALL METHOD im_workitem_context->get_workitem_id
              RECEIVING
                re_workitem = lv_task_id.

            CALL METHOD im_workitem_context->get_wi_container
              RECEIVING
                re_container = ls_wi_container.

            CALL METHOD im_workitem_context->get_top_container
              RECEIVING
                re_container = lv_top_container.

            CALL METHOD lv_top_container->get
              EXPORTING
                name  = '_WORKITEM'
              IMPORTING
                value = ls_workitem.

            CALL METHOD ls_wi_container->get
              EXPORTING
                name  = '_WI_RESULT'
              IMPORTING
                value = ls_result.


            FREE lt_log.

            SELECT *
              FROM ztfi_wf_log
              INTO TABLE lt_log
             WHERE wf_id EQ ls_workitem-instid
               AND task_id EQ lv_task_id.

            IF sy-subrc EQ 0.

              LOOP AT lt_log ASSIGNING <fs_log>.

                CASE ls_result.
                  WHEN 0001. "Aprovar
                    IF <fs_log>-aprovador EQ sy-uname.
                      <fs_log>-status_aprovacao = '1'.
                    ELSE.
                      <fs_log>-status_aprovacao = '3'.
                    ENDIF.
                  WHEN 0002. "Rejeitar
                    <fs_log>-status_aprovacao = '4'.
                  WHEN 0003. "Rejeição com Estorno
                    <fs_log>-status_aprovacao = '5'.
                ENDCASE.

              ENDLOOP.

              MODIFY ztfi_wf_log FROM TABLE lt_log.

            ENDIF.

          CATCH cx_swf_cnt_elem_not_found.     " Name Entered Is Unknown
          CATCH cx_swf_cnt_elem_type_conflict. " Value Not Type Compatible to Current Parameter
          CATCH cx_swf_cnt_unit_type_conflict. " Unit Not Type Compatible to the Current Parameter
          CATCH cx_swf_cnt_container.          " Exception in the Container Service

        ENDTRY.

    ENDCASE.

  ENDMETHOD.
ENDCLASS.
