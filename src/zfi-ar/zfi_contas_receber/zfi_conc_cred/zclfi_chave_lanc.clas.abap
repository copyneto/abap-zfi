class ZCLFI_CHAVE_LANC definition
  public
  final
  create public .

public section.

  interfaces IF_BADI_INTERFACE .
  interfaces IF_EX_ACC_DOCUMENT .
protected section.
private section.
ENDCLASS.



CLASS ZCLFI_CHAVE_LANC IMPLEMENTATION.


  METHOD if_ex_acc_document~change.

    SORT c_accit BY posnr.

    IF c_extension2 IS NOT INITIAL.

      LOOP AT c_extension2 ASSIGNING FIELD-SYMBOL(<fs_ext>).

        READ TABLE c_accit ASSIGNING FIELD-SYMBOL(<fs_it>) WITH KEY posnr = <fs_ext>-valuepart1
                                                           BINARY SEARCH.
        IF sy-subrc = 0.

          ASSIGN COMPONENT <fs_ext>-structure OF STRUCTURE <fs_it> TO FIELD-SYMBOL(<fs_field>).
          IF <fs_field> IS ASSIGNED.
            <fs_field> = <fs_ext>-valuepart2.
          ENDIF.

        ENDIF.

      ENDLOOP.

    ENDIF.

  ENDMETHOD.


  METHOD if_ex_acc_document~fill_accit.
    RETURN.
  ENDMETHOD.
ENDCLASS.
