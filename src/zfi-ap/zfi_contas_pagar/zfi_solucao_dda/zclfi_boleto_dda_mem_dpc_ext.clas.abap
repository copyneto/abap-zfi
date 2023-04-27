class ZCLFI_BOLETO_DDA_MEM_DPC_EXT definition
  public
  inheriting from ZCLFI_BOLETO_DDA_MEM_DPC
  create public .

public section.
protected section.

  methods MEMORYSET_GET_ENTITY
    redefinition .
private section.
ENDCLASS.



CLASS ZCLFI_BOLETO_DDA_MEM_DPC_EXT IMPLEMENTATION.


  METHOD memoryset_get_entity.

    FREE MEMORY ID 'ZFI_REF'.

    TRY.

        IF it_key_tab IS NOT INITIAL.

          EXPORT tab FROM it_key_tab
          TO DATABASE indx(xy)
          CLIENT sy-mandt
          ID 'ZFI_REF'.

          er_entity-referenceno = VALUE #( it_key_tab[ NAME = 'ReferenceNo' ]-value OPTIONAL ).
          er_entity-fiscalyear = VALUE #( it_key_tab[ NAME = 'FiscalYear' ]-value OPTIONAL ).
          er_entity-docnumber = VALUE #( it_key_tab[ NAME = 'DocNumber' ]-value OPTIONAL ).

        ENDIF.
      CATCH cx_root.
    ENDTRY.

  ENDMETHOD.
ENDCLASS.
