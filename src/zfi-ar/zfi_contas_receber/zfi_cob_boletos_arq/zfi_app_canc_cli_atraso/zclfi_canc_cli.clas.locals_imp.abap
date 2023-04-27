CLASS lcl_Cancelar DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS read FOR READ
      IMPORTING keys FOR READ zc_fi_canc_cli RESULT result.

    METHODS cancelar FOR MODIFY
      IMPORTING keys FOR ACTION zc_fi_canc_cli~cancelar.


    METHODS get_features FOR FEATURES
      IMPORTING keys REQUEST requested_features FOR zc_fi_canc_cli RESULT result.


ENDCLASS.

CLASS lcl_Cancelar IMPLEMENTATION.

  METHOD read.
    RETURN.
  ENDMETHOD.

  METHOD cancelar.

    CONSTANTS: BEGIN OF lc_value,
                 v1 TYPE symsgno      VALUE '011',
                 v2 TYPE symsgno      VALUE '012',
                 v3 TYPE symsgno      VALUE '019',
                 i  TYPE bapi_mtype   VALUE 'I',
                 s  TYPE bapi_mtype   VALUE 'S',
                 id TYPE symsgid      VALUE 'ZFI_CONT_RCB',
               END OF lc_value.

    DATA lt_result TYPE TABLE OF zi_fi_canc_cli.

    IF keys IS NOT INITIAL.

      SELECT bukrs, kunnr, belnr, buzei, gjahr, wrbtr, bldat, dmbtr, waers, anfbn  FROM zi_fi_canc_cli
       FOR ALL ENTRIES IN @keys
       WHERE bukrs EQ @keys-bukrs
         AND belnr EQ @keys-belnr
         AND buzei EQ @keys-buzei
         AND gjahr EQ @keys-gjahr
       INTO CORRESPONDING FIELDS OF TABLE @lt_result.

      IF sy-subrc EQ 0.

        NEW zclfi_exec_canc_cliente( )->executar(
         EXPORTING
           it_can_cli = lt_result
           IMPORTING
           et_msg = DATA(lt_msg)
         ).


      ENDIF.

      IF lines( lt_msg ) GT 120.

        reported-zc_fi_canc_cli = VALUE #( (
                              %msg = new_message(   id       = lc_value-id
                                                    number   = lc_value-v1
                                                    severity = CONV #( lc_value-s ) ) )
                           (
                              %msg = new_message(   id       = lc_value-id
                                                    number   = lc_value-v2
                                                    severity = CONV #( lc_value-s ) ) )
                           ) .
      ELSE.

        IF lines( lt_msg )               EQ 1 AND
           lines( lt_msg[ 1 ]-bapiret2 ) EQ 1.

          lt_msg[ 1 ]-bapiret2 = VALUE #( BASE lt_msg[ 1 ]-bapiret2 (
                       type       = lc_value-s
                       id         = lc_value-id
                       number     = lc_value-v1 )
                  ).

        ENDIF.

        reported-zc_fi_canc_cli = VALUE #( FOR ls_resul IN lt_result
                                     FOR ls_msg   IN lt_msg
                                        WHERE ( belnr = ls_resul-belnr AND
                                                buzei = ls_resul-buzei )
                                     FOR ls_item IN  ls_msg-bapiret2  (
                                  %key = VALUE #(
                                                 bukrs = ls_resul-bukrs
                                                 belnr = ls_resul-belnr
                                                 buzei = ls_resul-buzei
                                                 gjahr = ls_resul-gjahr
                                                )
                                   %tky = VALUE #(
                                                 bukrs = ls_resul-bukrs
                                                 belnr = ls_resul-belnr
                                                 buzei = ls_resul-buzei
                                                 gjahr = ls_resul-gjahr
                                                )
                                  %msg = new_message(   id       = COND #( WHEN ls_item-type NE lc_value-s
                                                                             OR ls_item-id   EQ lc_value-id   THEN ls_item-id         ELSE lc_value-id )
                                                        number   = COND #( WHEN ls_item-type NE lc_value-s
                                                                             OR ls_item-id   EQ lc_value-id   THEN ls_item-number     ELSE lc_value-v3 )
                                                        v1       = COND #( WHEN ls_item-type NE lc_value-s
                                                                             OR ls_item-id   EQ lc_value-id   THEN ls_item-message_v1 ELSE ls_resul-belnr )
                                                        v2       = COND #( WHEN ls_item-type NE lc_value-s
                                                                             OR ls_item-id   EQ lc_value-id   THEN ls_item-message_v2 ELSE ls_resul-bukrs )
                                                        v3       = COND #( WHEN ls_item-type NE lc_value-s
                                                                             OR ls_item-id   EQ lc_value-id   THEN ls_item-message_v3 ELSE ls_resul-gjahr )
                                                        v4       = ls_item-message_v4
                                                        severity = CONV #( lc_value-i ) )
                                    ) ) .

      ENDIF.

    ENDIF.

  ENDMETHOD.

  METHOD get_features.
    RETURN.
  ENDMETHOD.

ENDCLASS.

CLASS lcl_ZI_FI_CANC_CLI DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.

    METHODS check_before_save REDEFINITION.

    METHODS finalize          REDEFINITION.

    METHODS save              REDEFINITION.

ENDCLASS.

CLASS lcl_ZI_FI_CANC_CLI IMPLEMENTATION.

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
