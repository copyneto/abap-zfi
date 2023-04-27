class ZCL_IM_FI_FEBBADI definition
  public
  final
  create public .

public section.

  interfaces IF_EX_FEB_BADI .
protected section.
private section.
ENDCLASS.



CLASS ZCL_IM_FI_FEBBADI IMPLEMENTATION.


  METHOD if_ex_feb_badi~change_posting_data.

    NEW zclfi_creditocliente( )->creditocliente_memo(
      EXPORTING
        is_febko   = i_febko
        it_ftclear = t_ftclear
      CHANGING
        ct_ftpost  = t_ftpost
    ).

  ENDMETHOD.
ENDCLASS.
