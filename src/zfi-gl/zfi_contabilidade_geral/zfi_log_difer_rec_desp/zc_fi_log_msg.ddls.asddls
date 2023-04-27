@EndUserText.label: 'CDS de Projeção - Log Diferimento Mensagens'
@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
define view entity ZC_FI_LOG_MSG
  as projection on ZI_FI_LOG_MSG 
{
  key Empresa,
  key NumDoc,
  key Ano,
  key Contador,
      @EndUserText.label: 'Tipo execução'
      TipoBapi,
      @EndUserText.label: 'Empresa contab.'
      EmpresaCont,
      @EndUserText.label: 'Documento contabilizado'
      NumDocCont,
      @EndUserText.label: 'Ano contab.'
      AnoCont,
      @EndUserText.label: 'Empresa est.'
      EmpresaEst,
      @EndUserText.label: 'Documento estorno'
      NumcDocEst,
      @EndUserText.label: 'Ano est.'
      AnoEst,
      Text,

      _LogDif : redirected to parent ZC_FI_LOG_DIF
}
