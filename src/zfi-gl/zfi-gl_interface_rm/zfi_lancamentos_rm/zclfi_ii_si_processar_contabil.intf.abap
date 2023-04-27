interface ZCLFI_II_SI_PROCESSAR_CONTABIL
  public .


  methods SI_PROCESSAR_CONTABIL_LANCAMEN
    importing
      !INPUT type ZCLFI_MT_CONTABIL_LANCAMENTO
    raising
      ZCLFI_CX_FMT_CONTABI_LANCAMENT .
endinterface.
