interface ZII_SI_GRAVAR_DADOS_CONTAS_PAG
  public .


  methods SI_GRAVAR_DADOS_CONTAS_PAGAR_R
    importing
      !INPUT type ZMT_DADOS_CONTAS_PAGAR_RH
    raising
      ZFI_CX_FMT_DADOS_CONTAS_PAGAR .
endinterface.
