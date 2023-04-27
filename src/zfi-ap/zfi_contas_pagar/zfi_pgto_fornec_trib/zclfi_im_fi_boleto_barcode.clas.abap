class ZCLFI_IM_FI_BOLETO_BARCODE definition
  public
  final
  create public .

public section.

  interfaces IF_EX_BOLETO_BARCODE .
protected section.
private section.
ENDCLASS.



CLASS ZCLFI_IM_FI_BOLETO_BARCODE IMPLEMENTATION.


  method IF_EX_BOLETO_BARCODE~CONVERT.
    return.
  endmethod.


  METHOD if_ex_boleto_barcode~revert.
    RETURN.
  ENDMETHOD.


  METHOD if_ex_boleto_barcode~validate.
    RETURN.
  ENDMETHOD.
ENDCLASS.
