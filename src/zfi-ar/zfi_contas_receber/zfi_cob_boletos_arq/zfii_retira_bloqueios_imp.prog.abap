***********************************************************************
***                      © 3corações                                ***
***********************************************************************
***                                                                   *
*** DESCRIÇÃO: Retirada de Bloqueios das faturas para execução em JOB.*
*** AUTOR    : [Denilson Pasini Pina] –[META]                         *
*** FUNCIONAL: [Raphael Rocha]                                        *
*** DATA     : [10.09.2021]                                           *
***********************************************************************
*** HISTÓRICO DAS MODIFICAÇÕES                                        *
***-------------------------------------------------------------------*
*** DATA      | AUTOR        | DESCRIÇÃO                              *
***-------------------------------------------------------------------*
***           |              |                                        *
***********************************************************************
CLASS lcl_report IMPLEMENTATION.

  METHOD constructor.

    gt_outtab = it_tab.

  ENDMETHOD.

  METHOD display_report.

    IF gt_outtab IS NOT INITIAL.

      TRY.
          cl_salv_table=>factory(
            IMPORTING
              r_salv_table = go_table
            CHANGING
              t_table      = gt_outtab ).
        CATCH cx_salv_msg.                              "#EC NO_HANDLER
      ENDTRY.


      go_table->set_screen_status(
        pfstatus      = gc_status
        report        = sy-repid
        set_functions = go_table->c_functions_all ).


      go_table->get_columns( )->set_optimize( abap_true ).

      SET HANDLER me->on_user_command FOR go_table->get_event( ).


      go_table->get_selections( )->set_selection_mode( if_salv_c_selection_mode=>cell ).

      go_table->display( ).

    ELSE.

      MESSAGE s208(00) WITH TEXT-001 DISPLAY LIKE gc_error.

    ENDIF.


  ENDMETHOD.

  METHOD on_user_command.

    DATA: lt_des_tab TYPE zctgfi_retira_bloq.

    DATA(lt_rows) = go_table->get_selections( )->get_selected_rows( ).

    IF lt_rows IS NOT INITIAL.

      LOOP AT lt_rows ASSIGNING FIELD-SYMBOL(<fs_row>).

        APPEND gt_outtab[ <fs_row> ] TO lt_des_tab.

      ENDLOOP.

      IF lt_des_tab IS NOT INITIAL.
        go_desb->exec_unlock( lt_des_tab ).
      ENDIF.

    ELSE.

      MESSAGE s208(00) WITH TEXT-002 DISPLAY LIKE gc_error.

    ENDIF.


  ENDMETHOD.

ENDCLASS.
