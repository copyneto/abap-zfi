CLASS lcl_semcontrato DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS validatedia FOR VALIDATE ON SAVE
      IMPORTING keys FOR semcontrato~validatedia.

    METHODS existecontr FOR VALIDATE ON SAVE
      IMPORTING keys FOR semcontrato~existecontr.

ENDCLASS.

CLASS lcl_semcontrato IMPLEMENTATION.

  METHOD validatedia.

    CONSTANTS: lc_id     TYPE sy-msgid VALUE '00',
               lc_number TYPE sy-msgno VALUE '398',
               lc_erro   TYPE sy-msgty VALUE 'E'.


    READ ENTITIES OF zi_fi_sem_contr_dde IN LOCAL MODE
        ENTITY semcontrato
        ALL FIELDS WITH CORRESPONDING #( keys )
        RESULT DATA(lt_scontr).

    LOOP AT lt_scontr ASSIGNING FIELD-SYMBOL(<fs_scontr>).


      IF <fs_scontr>-diames IS NOT INITIAL AND <fs_scontr>-diasemana IS NOT INITIAL.

        APPEND VALUE #( %tky = <fs_scontr>-%tky ) TO failed-semcontrato.

        APPEND VALUE #( %tky        = <fs_scontr>-%tky
                        %state_area = 'DIAMES'
                        %msg        = new_message( id       = lc_id
                                                   number   = lc_number
                                                   v1       = TEXT-e01
                                                   severity = CONV #( lc_erro ) )
                        %element-diames = if_abap_behv=>mk-on )  TO reported-semcontrato.

        APPEND VALUE #( %tky        = <fs_scontr>-%tky
                        %state_area = 'DIASEMANA'
                        %msg        = new_message( id       = lc_id
                                                   number   = lc_number
                                                   v1       = TEXT-e01
                                                   severity = CONV #( lc_erro ) )
                       %element-diasemana = if_abap_behv=>mk-on )  TO reported-semcontrato.
      ENDIF.

    ENDLOOP.

  ENDMETHOD.

  METHOD existecontr.

    CONSTANTS: lc_id     TYPE sy-msgid VALUE '00',
               lc_number TYPE sy-msgno VALUE '398',
               lc_erro   TYPE sy-msgty VALUE 'E'.

    READ ENTITIES OF zi_fi_sem_contr_dde IN LOCAL MODE
      ENTITY semcontrato
      ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(lt_scontr).

    READ TABLE lt_scontr ASSIGNING FIELD-SYMBOL(<fs_contr>) INDEX 1.

    IF sy-subrc = 0.
      SELECT SINGLE katr10
        FROM kna1
        INTO @DATA(lv_exist)
        WHERE kunnr = @<fs_contr>-cliente.

        if lv_exist is NOT INITIAL.

        APPEND VALUE #( %tky = <fs_contr>-%tky ) TO failed-semcontrato.

        APPEND VALUE #( %tky        = <fs_contr>-%tky
                        %state_area = 'CLIENTE'
                        %msg        = new_message( id       = lc_id
                                                   number   = lc_number
                                                   v1       = TEXT-e01
                                                   severity = CONV #( lc_erro ) )
                        %element-cliente = if_abap_behv=>mk-on )  TO reported-semcontrato.
        endif.

    ENDIF.



  ENDMETHOD.

ENDCLASS.
