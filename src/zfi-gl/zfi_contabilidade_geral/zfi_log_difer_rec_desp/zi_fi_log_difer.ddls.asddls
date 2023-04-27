@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Log de Diferimento'
@Metadata.ignorePropagatedAnnotations: true

root view entity zi_fi_log_difer
  as select from ztfi_log_difer
  association [1..1] to I_CompanyCode as _Company on $projection.Empresa = _Company.CompanyCode
{
  key int_num   as IntNum,
      empresa   as Empresa,
      numr_doc  as NumrDoc,
      ano       as Ano,
      @EndUserText.label: 'Data de Lançamento'
      data_lanc as DataLanc,
      @Semantics.systemDateTime.createdAt: true
      hora      as Hora,
      message   as Message,
      
      _Company
}
