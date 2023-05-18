CLASS lcl_aprovacao DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS read FOR READ
      IMPORTING keys FOR READ aprovacao RESULT result.

    METHODS approv FOR MODIFY
      IMPORTING keys FOR ACTION aprovacao~approv.

*    METHODS get_features FOR FEATURES
*      IMPORTING keys REQUEST requested_features FOR aprovacao RESULT result.

ENDCLASS.

CLASS lcl_aprovacao IMPLEMENTATION.

  METHOD read.

    DATA(lr_filter) = VALUE  if_rap_query_filter=>tt_name_range_pairs(  ).

    LOOP AT keys ASSIGNING FIELD-SYMBOL(<fs_key>).
      lr_filter = VALUE #( BASE lr_filter
        ( name = 'COMPANYCODE'       range = VALUE #( ( sign = 'I' option = 'EQ' low = <fs_key>-companycode ) ) )
        ( name = 'NETDUEDATE'        range = VALUE #( ( sign = 'I' option = 'EQ' low = <fs_key>-netduedate ) ) )
        ( name = 'REPTYPE'           range = VALUE #( ( sign = 'I' option = 'EQ' low = <fs_key>-reptype ) ) )
        ( name = 'CASHPLANNINGGROUP' range = VALUE #( ( sign = 'I' option = 'EQ' low = <fs_key>-cashplanninggroup ) ) )
        ( name = 'RUNHOURTO'         range = VALUE #( ( sign = 'I' option = 'EQ' low = <fs_key>-runhourto ) ) )
*        ( name = 'RZAWE'             range = VALUE #( ( sign = 'I' option = 'EQ' low = <fs_key>-rzawe ) ) )
        ).
    ENDLOOP.

    SORT lr_filter BY name range.
    DELETE ADJACENT DUPLICATES FROM lr_filter COMPARING name range.

*    DATA(lt_entity) = NEW zclfi_aprov_contas_pagar_util( )->get_contas_pagar( lr_filter ).
    DATA(lt_entity) = NEW zclfi_aprov_contas_pagar_util( )->get_contas_pagar_2( it_filtro_ranges = lr_filter iv_filtro_aprov = abap_false ).
    result = CORRESPONDING #( lt_entity ).
  ENDMETHOD.

  METHOD approv.
    DATA(lt_keys) = keys.
*    LOOP AT lt_keys ASSIGNING FIELD-SYMBOL(<fs_keys>).
*      IF <fs_keys>-NetDueDate IS NOT INITIAL AND <fs_keys>-NetDueDate <> '000000'.
*        DATA(lv_netduedate) = conv sy-datum( <fs_keys>-NetDueDate ).
*        lv_netduedate = lv_netduedate + 1.
*        <fs_keys>-NetDueDate = lv_netduedate.
*      ENDIF.
*    ENDLOOP.

    READ ENTITIES OF zc_fi_aprov_contas_pagar
      ENTITY aprovacao
        ALL FIELDS WITH CORRESPONDING #( lt_keys )
      RESULT DATA(lt_entity)
      FAILED failed.

*    DATA(lr_util) = NEW zclfi_aprov_contas_pagar_util( ).
*
*    lr_util->approve( EXPORTING is_entity = CORRESPONDING #( lt_entity[ 1 ] )
*                      IMPORTING et_message = DATA(lt_message)
*                      RECEIVING rs_return  = DATA(ls_return) ).
*
*    IF line_exists( lt_message[ type = 'E' ] ).
*      failed-aprovacao = VALUE #( BASE failed-aprovacao FOR ls_key IN keys ( %tky = ls_key-%tky ) ).
*    ENDIF.
*
*    reported-aprovacao = VALUE #( BASE reported-aprovacao
*                                  FOR ls_entity IN lt_entity
*                                  FOR ls_message IN lt_message
*                                    ( %tky = CORRESPONDING #( ls_entity )
*                                      %msg = new_message( id = ls_message-id number = ls_message-number severity = CONV #( ls_message-type ) v1 = ls_message-message_v1 v2 = ls_message-message_v2 ) ) ).

* pferraz - 18.05.23 - inicio

    DATA: lt_aprov_remessa TYPE zctgfi_aprov_remessa.

    lt_aprov_remessa = VALUE #( BASE lt_aprov_remessa FOR ls_entity IN lt_entity
                                    ( CORRESPONDING #( ls_entity ) )  ).

*    LOOP AT lt_entity ASSIGNING FIELD-SYMBOL(<fs_entity>).
    NEW zclfi_aprov_contas_pagar_util(  )->approve( CHANGING ct_entity = lt_aprov_remessa ) .
*      NEW zclfi_aprov_contas_pagar_util(  )->approve( CHANGING ct_entity =  CORRESPONDING #( <fs_entity> ) ).
*    ENDLOOP.

    MOVE-CORRESPONDING lt_aprov_remessa TO lt_entity.
* pferraz - 18.05.23 - fim

*    result = VALUE #( FOR ls_entity IN lt_entity
*      LET ls_result = NEW zclfi_aprov_contas_pagar_util(  )->approve( CORRESPONDING #( ls_entity ) )
*      IN  %param = CORRESPONDING #( ls_entity )
*      ( companycode       = ls_result-companycode
*        netduedate        = ls_result-netduedate
*        reptype           = ls_result-reptype
*        cashplanninggroup = ls_result-cashplanninggroup ) ).

  ENDMETHOD.

*  METHOD get_features.
*
*    READ ENTITIES OF zc_fi_aprov_contas_pagar
*      ENTITY aprovacao
*        ALL FIELDS WITH CORRESPONDING #( keys )
*      RESULT DATA(lt_entity)
*      FAILED failed.
*
*    result = VALUE #( FOR ls_entity IN lt_entity
*            ( %key = ls_entity-%key
*              %action-approv = COND #( WHEN ls_entity-encerrador = space
*                                       THEN zclfi_aprov_contas_pagar_util=>get_features( iv_bukrs = ls_entity-companycode iv_nivel = '0' )
*                                       WHEN ls_entity-aprov1 = space
*                                       THEN zclfi_aprov_contas_pagar_util=>get_features( iv_bukrs = ls_entity-companycode iv_nivel = '1' )
*                                       WHEN ls_entity-aprov2 = space
*                                       THEN zclfi_aprov_contas_pagar_util=>get_features( iv_bukrs = ls_entity-companycode iv_nivel = '2' )
*                                       WHEN ls_entity-aprov3 = space
*                                       THEN zclfi_aprov_contas_pagar_util=>get_features( iv_bukrs = ls_entity-companycode iv_nivel = '3' )
*                                       WHEN ls_entity-aprov3 = abap_true
*                                       THEN if_abap_behv=>fc-o-disabled )
*             ) ).
*  ENDMETHOD.

ENDCLASS.


CLASS lcl_zc_fi_aprov_contas_pagar DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.

    METHODS check_before_save REDEFINITION.

    METHODS finalize          REDEFINITION.

    METHODS save              REDEFINITION.

ENDCLASS.

CLASS lcl_zc_fi_aprov_contas_pagar IMPLEMENTATION.

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
