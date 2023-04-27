@EndUserText.label: 'Estorno de Solicitação LC - Log'
@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
@Search.searchable: true
@ObjectModel.semanticKey: ['Bukrs', 'Belnr','Buzei','Gjhar','Datac','Horac']
define root view entity ZC_FI_SOLICIT_CORRE
  as projection on ZI_FI_SOLICIT_CORRE
{
      @Search.defaultSearchElement: true
  key Bukrs,
      @Search.defaultSearchElement: true
  key Kunnr,
      @Search.defaultSearchElement: true
  key Belnr,
      @Search.defaultSearchElement: true
  key Buzei,
      @Search.defaultSearchElement: true
  key Gjhar,
      @Search.defaultSearchElement: true
  key Datac,
      @Search.defaultSearchElement: true
  key Horac,
      Wrbtr,
      Netdt,
      Motivo,
      Tipo,
      Belnrestorno,
      Buzeiestorno,
      Gjharestorno,
      Verzn,
      Waers,
      @UI.hidden: true
      CreatedBy,
      @UI.hidden: true
      CreatedAt,
      @UI.hidden: true
      LastChangedBy,
      @UI.hidden: true
      LastChangedAt,
      @UI.hidden: true
      LocalLastChangedAt
}
