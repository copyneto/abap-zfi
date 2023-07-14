CLASS lhc__retbloq DEFINITION INHERITING FROM cl_abap_behavior_handler.

  PUBLIC SECTION.

    METHODS setup_messages IMPORTING p_task TYPE clike.

  PRIVATE SECTION.

    METHODS read FOR READ
      IMPORTING keys FOR READ _retbloq RESULT result.

    METHODS retbloq FOR MODIFY
      IMPORTING keys FOR ACTION _retbloq~retbloq.

    DATA gt_messages       TYPE STANDARD TABLE OF bapiret2.
    DATA gv_wait_async     TYPE abap_bool.

ENDCLASS.

CLASS lhc__retbloq IMPLEMENTATION.

  METHOD read.

    SELECT *
      FROM zc_ret_bloq
     FOR ALL ENTRIES IN @keys
     WHERE bukrs EQ @keys-bukrs
       AND kunnr EQ @keys-kunnr
       AND belnr EQ @keys-belnr
       AND buzei EQ @keys-buzei
       AND gjahr EQ @keys-gjahr
       INTO TABLE @DATA(lt_ret_bloq).

    result = CORRESPONDING #( lt_ret_bloq ).

  ENDMETHOD.

  METHOD retbloq.

    DATA ls_ret TYPE zsfi_retira_bloq.

    CONSTANTS: BEGIN OF lc_value,
                 v1   TYPE symsgno VALUE '011',
                 v2   TYPE symsgno VALUE '012',
                 type TYPE bapi_mtype  VALUE 'I',
               END OF lc_value.

*    SELECT * FROM zi_ret_bloq
*     FOR ALL ENTRIES IN @keys
*     WHERE bukrs EQ @keys-bukrs
*       AND kunnr EQ @keys-kunnr
*       AND belnr EQ @keys-belnr
*       AND buzei EQ @keys-buzei
*       AND gjahr EQ @keys-gjahr
*     INTO TABLE @DATA(lt_result).

    " Read the travel status of the existing travels
    READ ENTITIES OF zi_ret_bloq IN LOCAL MODE
      ENTITY _retbloq
        ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(lt_ret_bloq)
      FAILED failed.

    IF sy-subrc EQ 0.

      LOOP AT lt_ret_bloq ASSIGNING FIELD-SYMBOL(<fs_linha>).

        MOVE-CORRESPONDING <fs_linha> TO ls_ret.

        CALL FUNCTION 'ZFMFI_RET_BLOQ'
          DESTINATION 'NONE'
          STARTING NEW TASK ls_ret-belnr
          CALLING setup_messages ON END OF TASK
          EXPORTING
            is_linha = ls_ret.

        WAIT UNTIL gv_wait_async = abap_true.

        LOOP AT gt_messages INTO DATA(ls_message).       "#EC CI_NESTED

          APPEND VALUE #(
                         %tky = <fs_linha>-%tky
                         %msg   = new_message( id       = ls_message-id
                                                    number   = ls_message-number
                                                    v1       = ls_message-message_v1
                                                    v2       = ls_message-message_v2
                                                    v3       = ls_message-message_v3
                                                    v4       = ls_message-message_v4
                                                    severity = CONV #( ls_message-type ) )
                          )
           TO reported-_retbloq.

        ENDLOOP.

        CLEAR: gt_messages, gv_wait_async, ls_ret.

      ENDLOOP.

**      LOOP AT gt_msg INTO DATA(ls_message).              "#EC CI_NESTED
**
**        APPEND VALUE #( %tky = <fs_linha>-%tky
**                       %msg   = new_message( id       = ls_message-id
**                                                  number   = ls_message-number
**                                                  v1       = ls_message-message_v1
**                                                  v2       = ls_message-message_v2
**                                                  v3       = ls_message-message_v3
**                                                  v4       = ls_message-message_v4
**                                                  severity = CONV #( ls_message-type ) )
**                        )
**         TO reported-_retbloq.
**
**      ENDLOOP.

    ENDIF.

*    result = VALUE #( FOR key IN keys
*                       ( %tky   = key-%tky ) ).


  ENDMETHOD.

  METHOD setup_messages.

    RECEIVE RESULTS FROM FUNCTION 'ZFMFI_RET_BLOQ'
        IMPORTING
          et_return = gt_messages.

    gv_wait_async = abap_true.

  ENDMETHOD.

ENDCLASS.

CLASS lsc_zi_ret_bloq DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.

    METHODS check_before_save REDEFINITION.

    METHODS finalize          REDEFINITION.

    METHODS save              REDEFINITION.

ENDCLASS.

CLASS lsc_zi_ret_bloq IMPLEMENTATION.

  METHOD check_before_save.
    RETURN.
  ENDMETHOD.

  METHOD finalize.
    RETURN.
  ENDMETHOD.

  METHOD save.
    RETURN.
  ENDMETHOD.

ENDCLASS.
