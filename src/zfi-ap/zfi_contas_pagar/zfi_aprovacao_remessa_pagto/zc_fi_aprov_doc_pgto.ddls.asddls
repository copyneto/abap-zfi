@EndUserText.label: 'CDS Custom - Documentos de pagamento'
@ObjectModel.query.implementedBy: 'ABAP:ZCLFI_APROV_CONTAS_PAGAR_QUERY'
define custom entity ZC_FI_APROV_DOC_PGTO
{

      @Consumption.filter.hidden: true
      @EndUserText.label: 'Empresa'
  key CompanyCode       : bukrs;

      @Consumption.filter.hidden: true
      @EndUserText.label: 'Data de Vencimento'
  key NetDueDate        : netdt;

      @Consumption.filter.hidden: true
      @EndUserText.label: 'Grupo de Tesouraria'
  key CashPlanningGroup : fdgrv;

  key Tipo              : abap.char(1);

  key RepType           : ze_tiporel;

  key hbkid             : hbkid;

  key rzawe             : rzawe;
  key PaymentRunID      : laufi;
  
      @Consumption.filter.hidden: true
      @EndUserText.label: 'Hora Início'
      RunHourFrom       : uzeit;

      @Consumption.filter.hidden: true
      @EndUserText.label: 'Hora Fim'
      RunHourTo         : uzeit;

      @Consumption.filter.hidden: true
      @EndUserText.label: 'URL Pgto Dia'
      PaymentDocument   : eso_longtext;

      @Consumption.filter.hidden: true
      @EndUserText.label: 'URL Em Aberto'
      OpenDocument      : eso_longtext;

      @Consumption.filter.hidden: true
      @EndUserText.label: 'URL Bloqueado'
      BlockedDocument   : eso_longtext;
}
