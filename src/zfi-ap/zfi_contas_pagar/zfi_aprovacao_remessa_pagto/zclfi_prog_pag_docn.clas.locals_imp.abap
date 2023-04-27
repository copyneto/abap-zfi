CLASS lcl_uploadgrptesouraria DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS read FOR READ
      IMPORTING keys FOR READ grupotesouraria RESULT result.

    METHODS changegroup FOR MODIFY
      IMPORTING keys FOR ACTION grupotesouraria~changegroup.

ENDCLASS.

CLASS lcl_uploadgrptesouraria IMPLEMENTATION.

  METHOD read.
    IF keys IS NOT INITIAL.
      SELECT *
      FROM zi_fi_prog_pag_docn
      FOR ALL ENTRIES IN @keys
      WHERE companycode = @keys-companycode
        AND accountingdocument = @keys-accountingdocument
        AND fiscalyear = @keys-fiscalyear
        AND  accountingdocumentitem = @keys-accountingdocumentitem
        AND netduedate = @keys-netduedate
        AND cashplanninggroup = @keys-cashplanninggroup
        INTO CORRESPONDING FIELDS OF TABLE @result.
    ENDIF.
  ENDMETHOD.

  METHOD changegroup.
    DATA lt_doc_fdgrv TYPE zctgfi_doc_fdgrv.

    DATA(lv_fdgrv) = keys[ 1 ]-%param-novogrptesouraria.

    READ ENTITIES OF zi_fi_prog_pag_docn IN LOCAL MODE
      ENTITY grupotesouraria
        ALL FIELDS
          WITH CORRESPONDING #( keys )
            RESULT DATA(lt_keys).

    LOOP AT lt_keys ASSIGNING FIELD-SYMBOL(<fs_keys>).
      APPEND VALUE #(   bukrs = <fs_keys>-companycode
                        belnr = <fs_keys>-accountingdocument
                        gjahr = <fs_keys>-fiscalyear
                        buzei = <fs_keys>-accountingdocumentitem
                        netduedate = <fs_keys>-netduedate
                        fdgrv = <fs_keys>-cashplanninggroup
                        newfdgrv = lv_fdgrv "<fs_keys>-%param-novogrptesouraria
                        tipo_rel = <fs_keys>-reptype ) TO lt_doc_fdgrv.  "%param-reptype

    ENDLOOP.

    NEW zclfi_aprov_contas_pagar_util( )->set_fdgrv( it_doc_fdgrv = lt_doc_fdgrv ).

  ENDMETHOD.

ENDCLASS.

CLASS lcl_zi_fi_prog_pag_docn DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.

    METHODS check_before_save REDEFINITION.

    METHODS finalize          REDEFINITION.

    METHODS save              REDEFINITION.

ENDCLASS.

CLASS lcl_zi_fi_prog_pag_docn IMPLEMENTATION.

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
