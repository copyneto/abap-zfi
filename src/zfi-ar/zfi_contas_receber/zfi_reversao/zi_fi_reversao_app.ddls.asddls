@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Interface Reversão Abatimento'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define root view entity ZI_FI_REVERSAO_APP
  as select from ZI_FI_REVERSAO
  
{
  key bukrs as Empresa,
  key belnr as Documento,
  key gjahr as Exercicio,
  key buzei as Item,
  key rebzt as TpDocSub,
      augbl as DocComp,
      augdt as DataComp,
      bschl as ChaveLanc,
      blart as TpDoc,
      budat as DataLanc,
      waers as Moeda,
      @Semantics.amount.currencyCode: 'Moeda'
      wrbtr as Montante,
      rebzg as RefFatura,
      kunnr as Cliente,
      name1 as Nome1,
      zuonr as Atribuicao,
//      ''    as motivoEstorno,
      ''    as motEstorno,
      ''    as dataLancEst

}
