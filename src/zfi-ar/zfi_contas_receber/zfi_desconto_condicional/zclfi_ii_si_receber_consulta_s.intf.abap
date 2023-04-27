interface ZCLFI_II_SI_RECEBER_CONSULTA_S
  public .


  methods SI_RECEBER_CONSULTA_STATUS_PAR
    importing
      !INPUT type ZCLFI_MT_CONSULTA_STATUS_PARC1
    exporting
      !OUTPUT type ZCLFI_MT_CONSULTA_STATUS_PARCE
    raising
      ZCLFI_CX_FMT_CONSULTA_STATUS_P .
endinterface.
