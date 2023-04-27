@EndUserText.label: 'Projection Venc Mod Partidas de Cliente'
@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
define root view entity ZC_FI_VENC_CLI_F01
  as projection on ZI_FI_VENC_CLI_F01
  association [0..1] to ZI_CA_VH_MANSP as _Mot on $projection.motivoProrrog = _Mot.BloqAdv
{
  key Empresa,
  key Cliente,
  key NoDocumento,
  key Exercicio,
  key Item,
      Cnpj,
      Cpf,
      Nome1,
      TpDocumento,
      Texto,
      Referencia,
      Atribuicao,
      DataLanc,
      Divisao,
      FormaPagto,
      BloqAdvert,
      Denominacao,
      VencimentoEm,
      CondPgto,
      DocProc,
      DiasAtraso,
      MontMoedaInt,
      Moeda,
      DocFaturamento,
      CanalDist,
      SetorAtiv,
      OrgVendas,
      Regiao,
      DataEntrega,
      DifLanc,
      Atributo10,
      GrpCondicoes,
      novaDataVenc,
      motivoProrrog,
      observ,
      
      _Mot
}
