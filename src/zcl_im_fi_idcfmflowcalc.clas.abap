class ZCL_IM_FI_IDCFMFLOWCALC definition
  public
  final
  create public .

public section.

  interfaces IF_EX_IDCFMFLOWCALC .
protected section.
private section.
ENDCLASS.



CLASS ZCL_IM_FI_IDCFMFLOWCALC IMPLEMENTATION.


  METHOD if_ex_idcfmflowcalc~calculate_flows.

* calculate flows using condition technique
    CALL FUNCTION 'IDCFM_CALCULATE_FLOWS'
      EXPORTING
        s_fha_in   = s_fha_in
        t_fhapo_in = t_fhapo_in
      CHANGING
        t_result   = t_result.

  ENDMETHOD.


  method IF_EX_IDCFMFLOWCALC~GET_PERCENTAGE.
  endmethod.
ENDCLASS.
