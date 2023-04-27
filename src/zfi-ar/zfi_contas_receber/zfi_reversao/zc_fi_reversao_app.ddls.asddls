@EndUserText.label: 'Projection Reversão Abatimento'
@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
define root view entity ZC_FI_REVERSAO_APP
  as projection on ZI_FI_REVERSAO_APP
  association [0..1] to ZI_CA_STGRD as _Mot on $projection.motEstorno = _Mot.MotEstorno
{
      @Consumption.valueHelpDefinition: [{entity: {name: 'I_COMPANYCODEVH', element: 'CompanyCode' }}]
  key Empresa,
  key Documento,
  key Exercicio,
  key Item,
  key TpDocSub,
      DocComp,
      @Consumption.filter.selectionType: #SINGLE
      DataComp,
      ChaveLanc,
      TpDoc,
      DataLanc,
      Moeda,
      Montante,
      RefFatura,
      Cliente,
      Nome1,
      Atribuicao,
      //    motivoEstorno,
      motEstorno,
      dataLancEst,

      _Mot
}
