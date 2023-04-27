@EndUserText.label: 'Retorno de pagto. Segmento Z'
@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
@ObjectModel.semanticKey: ['Empresa', 'Fornecedor', 'Fatura', 'DocContabAuxiliar']
define root view entity ZC_FI_RETPAGTO_SEGMENTOZ
  as projection on ZI_FI_RETPAGTO_SEGMENTOZ
{
         @Consumption.valueHelpDefinition: [{
             entity: {
                 name: 'ZI_CA_VH_COMPANY',
                 element: 'CompanyCode'
             }
         }]
         @ObjectModel.text.element: ['NomeEmpresa']
  key    Empresa,

         @Consumption.valueHelpDefinition: [{
             entity: {
                 name: 'I_BusinessPartnerVH',
                 element: 'BusinessPartner'
             }
         }]
         @ObjectModel.text.element: ['NomeFornecedor']
  key    Fornecedor,
  key    Fatura,
         @EndUserText.label: 'NºDoc. Compensação'
  key    DocContabAuxiliar,
         @Consumption.valueHelpDefinition: [{
             entity: {
                 name: 'C_CnsldtnFiscalYearVH',
                 element: 'FiscalYear'
             }
         }]
  key    ExercicioCompensacao,

         @Consumption.valueHelpDefinition: [{
             entity: {
                 name: 'ZI_FI_VH_HOUSE_BANK',
                 element: 'HouseBankId'
             }
         }]
         @ObjectModel.text.element: ['NomeBancoEmpresa']
  key    BancoEmpresa,

  key    FormaPagto,

         Item,

         @Consumption.valueHelpDefinition: [{
             entity: {
                 name: 'C_CnsldtnFiscalYearVH',
                 element: 'FiscalYear'
             }
         }]
         Exercicio,

         Montante,

         @Consumption.filter: {
             selectionType: #INTERVAL,
             multipleSelections: false
         }
         DataCompensacao,

         ChaveBreve,

         AutenticacaoBanc,

         ControleBanc,

         @ObjectModel.text.element: ['NomeBanco']
         Banco,

         Agencia,

         ContaCorrente,

         @ObjectModel.text.element: ['NomeBancoFavor']
         BancoFavor,

         AgenciaFavor,

         ContaFavor,

         @Consumption.hidden: true
         CreatedBy,

         @EndUserText.label: 'Data e hora de criação'
         CreatedAt,

         @Consumption.hidden: true
         LastChangedBy,

         @Consumption.hidden: true
         LastChangedAt,

         @Consumption.hidden: true
         LocalLastChangedAt,

         @Consumption.hidden: true
         Moeda,

         @EndUserText.label: 'Nome Fornecedor'
         _Fornecedor.BusinessPartnerName as NomeFornecedor,
         @EndUserText.label: 'Nome Empresa'
         _Empresas.butxt                 as NomeEmpresa,
         @EndUserText.label: 'Nome Banco'
         _Bancos.NomeBanco               as NomeBanco,
         @EndUserText.label: 'Nome Banco Favorecido'
         _BancosFavorecido.NomeBanco     as NomeBancoFavor,
         @EndUserText.label: 'Nome Banco Empresa'
         _BancosEmpresa.NomeBanco        as NomeBancoEmpresa,

         _Empresas,
         _Fornecedor,
         _Bancos,
         _BancosFavorecido,
         _BancosEmpresa
}
