@EndUserText.label: 'CDS Consumo - Canc. banc. de faturas com base em devoluções'
@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
@Search.searchable: true
@ObjectModel.semanticKey: ['bukrs', 'belnr','buzei','gjahr']

define root view entity ZC_FI_DOC_CANC_BANC
  as projection on ZI_FI_DOC_CANC_BANC as CancBanc

  association [0..1] to ZI_CA_VH_COMPANY as _Company on CancBanc.bukrs = _Company.CompanyCode
{
      @Search.defaultSearchElement: true
      @Consumption.valueHelpDefinition: [{ entity : {name: 'ZI_CA_VH_COMPANY', element: 'CompanyCode'  } }]
  key bukrs,
  key belnr,
  key buzei,
  key budat,
  key gjahr,
      bldat,
      bschl,      
      kunnr,
      rebzg,
      rebzj,
      rebzz,
      @Semantics.amount.currencyCode: 'waers'
      dmbtr,
      @Semantics.amount.currencyCode: 'waers'
      wrbtr,
      blart,
      xblnr,
      zuonr,
      hbkid,
      zlsch,
      anfbn,
      waers,
      zfbdt,
      zbd1t,
      zbd2t,
      zbd3t,
      Quantidade,
      @Semantics.amount.currencyCode: 'waers'
      Val_Estorno,

      //Association
      _Company

}
