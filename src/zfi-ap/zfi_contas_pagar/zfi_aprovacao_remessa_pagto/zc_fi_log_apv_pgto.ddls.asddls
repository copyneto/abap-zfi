@EndUserText.label: 'Log de Aprovação dos Documentos'
@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
define root view entity ZC_FI_LOG_APV_PGTO
  as projection on ZI_FI_LOG_APV_PGTO 
{

  key Empresa,
  key Data,
  key TipoRelatorio,
  key Hora,  
  key GrpTesouraria,
      @Aggregation.default: #SUM
      Valor,
      Encerrador,
      Moeda,
      Aprov1,
      Aprov2,
      Aprov3,
      CompanyCodeName,
      Text,

      /* Associations */
      _Empresa,
      _TpRel,
      _Item : redirected to composition child ZC_FI_LOG_APV_PGTO_ITEM      
}
