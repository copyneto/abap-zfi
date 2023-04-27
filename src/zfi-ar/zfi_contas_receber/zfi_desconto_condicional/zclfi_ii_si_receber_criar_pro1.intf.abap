interface ZCLFI_II_SI_RECEBER_CRIAR_PRO1
  public .


  methods SI_RECEBER_CRIAR_PROPOSTA_IN_S
    importing
      !INPUT type ZCLFI_MT_CRIAR_PROPOSTA
    exporting
      !OUTPUT type ZCLFI_MT_CRIAR_PROPOSTA_RESP
    raising
      ZCLFI_CX_FMT_CRIAR_PROPOSTA .
endinterface.
