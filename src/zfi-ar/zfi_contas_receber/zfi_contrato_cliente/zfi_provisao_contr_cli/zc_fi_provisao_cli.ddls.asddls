@EndUserText.label: 'Projection Prov. de Contr. Cliente'
@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
define root view entity ZC_FI_PROVISAO_CLI
  as projection on ZI_FI_PROVISAO_CLI
{
  key NumContrato,
  key NumAditivo,
  key Empresa,
  key Cliente,
  key NumDoc,
  key Item,
  key Exercicio,
      DataLanc,
      Montante,
      RegVendas,
      CanalDist,
      SetorAtivid,
      OrgVendas,
      StatusProv,
      DocProv,
      ExercProv,
      MontProv,
      DocLiq,
      ExercLiq,
      MontLiq,
      DocEstorno,
      ExcEstorno,
      MontEstorno,
      TipDesc,
      TipDado,
      Moeda,
      Referencia,
      FormaPgto,
      ChaveRef,
      BloqAdv,
      venc_prov,
      venc_liqui
}
