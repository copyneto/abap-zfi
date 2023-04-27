interface ZCLFI_II_SI_RECEBER_AGENDAMENT
  public .


  methods SI_RECEBER_AGENDAMENTO_PARCELA
    importing
      !INPUT type ZCLFI_MT_AGENDAMENTO_PARCELAS1
    exporting
      !OUTPUT type ZCLFI_MT_AGENDAMENTO_PARCELAS
    raising
      ZCLFI_CX_FMT_AGENDAMENTO_PARCE .
endinterface.
