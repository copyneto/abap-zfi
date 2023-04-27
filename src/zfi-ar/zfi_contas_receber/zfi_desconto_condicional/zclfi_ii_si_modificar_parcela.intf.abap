interface ZCLFI_II_SI_MODIFICAR_PARCELA
  public .


  methods SI_MODIFICAR_PARCELA_AGENDAMEN
    importing
      !INPUT type ZCLFI_MT_PARCELA_AGENDAMENTO
    exporting
      !OUTPUT type ZCLFI_MT_PARCELA_AGENDAMENTO_R
    raising
      ZCLFI_CX_FMT_PARCELA_AGENDAMEN .
endinterface.
