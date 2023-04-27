@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Interface Rel. Venc Mod Part. de Cliente'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define root view entity ZI_FI_VENC_CLI
  as select from ZI_FI_VENC_CLI_BASE
{
  key Empresa,
  key NoDocumento,
  key Exercicio,
  key Cliente,
      NomeCliente,
      DataMod,
      Item,
      TpDocumento,
      DataLanc,
      DtBase,
      BlocAdvert,
      DocFaturamento,
      FormaPagto,
      @Semantics.amount.currencyCode: 'Moeda'
      MontMoedaInt,
      Dia1,
      Dia2,
      DiasLiq,
      Moeda,
      VencimentoEm,
      DataComp,
      EscritorioVendas,
      RegiaoVendas,
      CanalDist,
      SetorAtiv,
      ContRegist,
      UsuarioMod,
      dats_days_between(VencimentoEm,Hoje) as DiasAtraso,
      @ObjectModel.virtualElement: true
      @ObjectModel.virtualElementCalculatedBy: 'ABAP:ZCLFI_GET_VENC_ORIG'
      cast( ' ' as abap.dats(8) )          as VencOrigem,
      @ObjectModel.virtualElement: true
      @ObjectModel.virtualElementCalculatedBy: 'ABAP:ZCLFI_GET_VENC_ORIG'   
      cast( ' ' as abap.numc( 4 ) )        as DiasProrrog,
      Observacao

}
