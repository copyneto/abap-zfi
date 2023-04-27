@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Contas do balanço das áreas de avaliação'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZI_FI_CONTA_AVA
  as select from t095

  association [0..*] to t095b as t095b on  t095.ktopl = t095b.ktopl
                                       and t095.ktogr = t095b.ktogr
                                       and t095.afabe = t095b.afabe
{
  key t095.ktopl  as Ktopl,
  key t095.afabe  as Afabe,
      t095.ktogr  as Ktogr,
      t095.ktansw as Ktansw,
      t095.ktanza as Ktanza,
      t095.kterlw as Kterlw,
      t095.ktmehr as Ktmehr,
      t095.ktmahk as Ktmahk,
      t095.ktmind as Ktmind,
      t095.ktrest as Ktrest,
      t095.ktapfg as Ktapfg,
      t095.ktaufw as Ktaufw,
      t095.ktaufg as Ktaufg,
      t095.ktansg as Ktansg,
      t095.ktanzg as Ktanzg,
      t095.ktvbab as Ktvbab,
      t095.ktvzu  as Ktvzu,
      t095.ktvizu as Ktvizu,
      t095.ktrizu as Ktrizu,
      t095.ktariz as Ktariz,
      t095.ktverk as Ktverk,
      t095.ktcoab as Ktcoab,
      t095.ktenak as Ktenak,
      t095.ktnaib as Ktnaib,
      t095b
}
