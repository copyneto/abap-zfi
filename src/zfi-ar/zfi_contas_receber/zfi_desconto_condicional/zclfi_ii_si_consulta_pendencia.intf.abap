interface ZCLFI_II_SI_CONSULTA_PENDENCIA
  public .


  methods SI_CONSULTA_PENDENCIA_FINANCEI
    importing
      !INPUT type ZCLFI_MT_CONSULTA_PENDENCIA_FI
    exporting
      !OUTPUT type ZCLFI_MT_RETORNA_PENDENCIA_FIN
    raising
      ZCLFI_CX_FMT_CONSULTA_PENDENCI .
endinterface.
