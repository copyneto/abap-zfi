CLASS lcl_bhv_validation DEFINITION
  INHERITING FROM cx_static_check
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF gc_duplicated_customer,
        msgid TYPE symsgid VALUE 'ZBP',
        msgno TYPE symsgno VALUE '004',
      END OF gc_duplicated_customer.

    INTERFACES if_abap_behv_message.
    INTERFACES if_t100_dyn_msg.
    INTERFACES if_t100_message.

    METHODS constructor
      IMPORTING
        iv_severity TYPE if_abap_behv_message=>t_severity DEFAULT if_abap_behv_message=>severity-error
        it_textid   LIKE if_t100_message=>t100key OPTIONAL
        io_previous TYPE REF TO cx_root OPTIONAL.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.

CLASS lcl_bhv_validation IMPLEMENTATION.
  METHOD constructor.
    CALL METHOD super->constructor
      EXPORTING
        previous = io_previous.

    CLEAR me->textid.

    IF it_textid IS INITIAL.
      if_t100_message~t100key = if_t100_message=>default_textid.
    ELSE.
      if_t100_message~t100key = it_textid.
    ENDIF.

    me->if_abap_behv_message~m_severity = iv_severity.
  ENDMETHOD.
ENDCLASS.

CLASS lhc_clientes DEFINITION INHERITING FROM cl_abap_behavior_handler.

  PRIVATE SECTION.

    METHODS validarDados FOR VALIDATE ON SAVE
      IMPORTING keys FOR Clientes~validarDados.

ENDCLASS.

CLASS lhc_clientes IMPLEMENTATION.

  METHOD validarDados.
    CONSTANTS lc_area TYPE string VALUE 'VALIDATE_CREATE'.

    READ ENTITIES OF zi_fi_raiz_cnpj IN LOCAL MODE
        ENTITY Raiz BY \_Clientes
        ALL FIELDS WITH CORRESPONDING #( keys )
        RESULT DATA(lt_data).

    TRY.
        DATA(ls_key) = keys[ 1 ].
        DELETE lt_data WHERE Cliente <> ls_key-Cliente. "#EC CI_STDSEQ
        CHECK lines( lt_data ) > 1.

        APPEND VALUE #( %tky        = ls_key-%tky
                        %state_area = lc_area )
        TO reported-clientes.

        APPEND VALUE #( %tky = ls_key-%tky ) TO failed-clientes.

        APPEND VALUE #( %tky        = ls_key-%tky
                        %state_area = lc_area
                        %msg        = NEW lcl_bhv_validation(
                                          iv_severity = if_abap_behv_message=>severity-error
                                          it_textid   = VALUE #( msgid = lcl_bhv_validation=>gc_duplicated_customer-msgid
                                                                 msgno = lcl_bhv_validation=>gc_duplicated_customer-msgno
                                                                 attr1 = ls_key-Cliente
                                                               )
                                      )
                        %element-Cliente = if_abap_behv=>mk-on )
          TO reported-clientes.
      CATCH cx_sy_itab_line_not_found.
    ENDTRY.
  ENDMETHOD.

ENDCLASS.

CLASS lhc_Raiz DEFINITION INHERITING FROM cl_abap_behavior_handler.

  PUBLIC SECTION.
    METHODS setup_messages IMPORTING p_task TYPE clike.

  PRIVATE SECTION.

    CONSTANTS gc_table TYPE tabname_auth VALUE 'ZTFI_RAIZ_CNPJ'.

    METHODS AtualizarClientes FOR MODIFY
      IMPORTING keys FOR ACTION Raiz~AtualizarClientes.

    METHODS get_authorizations FOR AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR Raiz RESULT result.

    DATA gt_messages       TYPE STANDARD TABLE OF bapiret2.
    DATA gv_wait_async     TYPE abap_bool.

ENDCLASS.

CLASS lhc_Raiz IMPLEMENTATION.

  METHOD AtualizarClientes.


    READ ENTITIES OF zi_fi_raiz_cnpj IN LOCAL MODE
      ENTITY Raiz FIELDS ( docuuidh DocUuidRaiz ) WITH CORRESPONDING #( keys )
      RESULT DATA(lt_cnpj_raiz)
      FAILED failed.

    IF lt_cnpj_raiz IS NOT INITIAL.

      DATA(ls_cnpj_raiz) = lt_cnpj_raiz[ 1 ].

      CALL FUNCTION 'ZFMFI_CONTROLE_RAIZ_CNPJ'
        STARTING NEW TASK 'CONTROLERAIZ'
        CALLING setup_messages ON END OF TASK
        EXPORTING
          iv_uuid = ls_cnpj_raiz-DocUuidRaiz.

      WAIT UNTIL gv_wait_async = abap_true.


      IF line_exists( gt_messages[ type = 'E' ] ).       "#EC CI_STDSEQ
        APPEND VALUE #(  %tky = ls_cnpj_raiz-%tky ) TO failed-raiz.
      ENDIF.

      LOOP AT gt_messages INTO DATA(ls_message).         "#EC CI_NESTED

        APPEND VALUE #( %tky        = ls_cnpj_raiz-%tky
                        %msg        = new_message( id       = ls_message-id
                                                   number   = ls_message-number
                                                   v1       = ls_message-message_v1
                                                   v2       = ls_message-message_v2
                                                   v3       = ls_message-message_v3
                                                   v4       = ls_message-message_v4
                                                   severity = CONV #( ls_message-type ) )
                         )
          TO reported-raiz.

      ENDLOOP.


    ENDIF.


  ENDMETHOD.

  METHOD setup_messages.

    RECEIVE RESULTS FROM FUNCTION 'ZFMFI_CONTROLE_RAIZ_CNPJ'
          IMPORTING
            et_return = gt_messages.

    gv_wait_async = abap_true.

  ENDMETHOD.

  METHOD get_authorizations.

    READ ENTITIES OF zi_fi_raiz_cnpj IN LOCAL MODE
         ENTITY Raiz
         ALL FIELDS WITH CORRESPONDING #( keys )
         RESULT DATA(lt_data)
         FAILED failed.

    CHECK lt_data IS NOT INITIAL.

    DATA lv_update TYPE if_abap_behv=>t_xflag.

    LOOP AT lt_data ASSIGNING FIELD-SYMBOL(<fs_data>).

      IF requested_authorizations-%update EQ if_abap_behv=>mk-on.

        IF zclfi_auth_zfimtable=>update( gc_table ).
          lv_update = if_abap_behv=>auth-allowed.
        ELSE.
          lv_update = if_abap_behv=>auth-unauthorized.
        ENDIF.

      ENDIF.

      APPEND VALUE #( %tky             = <fs_data>-%tky
                      %update          = if_abap_behv=>auth-unauthorized
                      %assoc-_Clientes = lv_update )
             TO result.

    ENDLOOP.

  ENDMETHOD.

ENDCLASS.
*"* use this source file for the definition and implementation of
*"* local helper classes, interface definitions and type
*"* declarations
