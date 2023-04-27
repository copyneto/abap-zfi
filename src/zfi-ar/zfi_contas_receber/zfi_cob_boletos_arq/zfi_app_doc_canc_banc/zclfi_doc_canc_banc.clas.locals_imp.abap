CLASS lcl_CancBanc DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS read FOR READ
      IMPORTING keys FOR READ Cancelar RESULT result.

    METHODS cancelar FOR MODIFY
      IMPORTING keys FOR ACTION Cancelar~cancelar.  "RESULT result.

    METHODS get_features FOR FEATURES
      IMPORTING keys REQUEST requested_features FOR Cancelar RESULT result.

ENDCLASS.

CLASS lcl_CancBanc IMPLEMENTATION.

  METHOD read.
    RETURN.
  ENDMETHOD.

  METHOD cancelar.

    CONSTANTS: BEGIN OF lc_value,
                 v1   TYPE symsgno      VALUE '011',
                 v2   TYPE symsgno      VALUE '012',
                 type TYPE bapi_mtype   VALUE 'I',
                 id   TYPE symsgid      VALUE 'ZFI_CONT_RCB',
               END OF lc_value.

    IF keys IS NOT INITIAL.

      SELECT bukrs,
             kunnr,
             belnr,
             buzei,
             gjahr,
             wrbtr,
             bldat,
             dmbtr,
             waers,
             anfbn,
             rebzg,
	         rebzj,
             rebzz
       FROM zi_fi_doc_canc_banc
       FOR ALL ENTRIES IN @keys
       WHERE bukrs EQ @keys-bukrs
         AND belnr EQ @keys-belnr
         AND buzei EQ @keys-buzei
         AND budat EQ @keys-budat
         AND gjahr EQ @keys-gjahr
       INTO TABLE @DATA(lt_result).

      IF sy-subrc EQ 0.

        DATA(lo_canc_banc) = NEW zclfi_exec_canc_bancario( ).

        lo_canc_banc->gt_bsid = CORRESPONDING #( lt_result ).

        lo_canc_banc->execute_app( IMPORTING et_msg = DATA(lt_msg) ).

        IF lines( lt_msg ) GT 120.

          reported-cancelar = VALUE #( (
                                %msg = new_message(   id       = 'ZFI_CONT_RCB'
                                                      number   = lc_value-v1
                                                      severity = CONV #( lc_value-type ) ) )
                             (
                                %msg = new_message(   id       = 'ZFI_CONT_RCB'
                                                      number   = lc_value-v2
                                                      severity = CONV #( lc_value-type ) ) )
                             ) .
        ELSE.

          IF lines( lt_msg[ 1 ]-bapiret2 ) EQ 1.

            lt_msg[ 1 ]-bapiret2 = VALUE #( BASE lt_msg[ 1 ]-bapiret2 (
                         type       = lc_value-type
                         id         = lc_value-id
                         number     = lc_value-v1 )
                    ).

          ENDIF.

          reported-cancelar = VALUE #( FOR ls_resul IN lt_result
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
                                    %msg = new_message(   id       = ls_item-id
                                                          number   = ls_item-number
                                                          v1       = ls_item-message_v1
                                                          v2       = ls_item-message_v2
                                                          v3       = ls_item-message_v3
                                                          v4       = ls_item-message_v4
                                                          severity = CONV #( lc_value-type ) )
                                      ) ) .

        ENDIF.

      ENDIF.

    ENDIF.

  ENDMETHOD.

  METHOD get_features.
    RETURN.
  ENDMETHOD.

ENDCLASS.

CLASS lcl_ZI_FI_DOC_CANC_BANC DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.

    METHODS check_before_save REDEFINITION.

    METHODS finalize          REDEFINITION.

    METHODS save              REDEFINITION.

ENDCLASS.

CLASS lcl_ZI_FI_DOC_CANC_BANC IMPLEMENTATION.

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
