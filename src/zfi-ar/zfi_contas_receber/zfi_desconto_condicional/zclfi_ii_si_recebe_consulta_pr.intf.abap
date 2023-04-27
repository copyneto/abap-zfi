interface ZCLFI_II_SI_RECEBE_CONSULTA_PR
  public .


  methods SI_RECEBE_CONSULTA_PROPOSTA_IN
    importing
      !INPUT type ZCLFI_MT_CONSULTAR_PROPOSTA
    exporting
      !OUTPUT type ZCLFI_MT_RETORNO_CONSULTA_PROP
    raising
      ZCLFI_CX_FMT_CONSULTA_PROPOSTA .
endinterface.
