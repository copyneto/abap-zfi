@EndUserText.label: 'Denominação Coligadas por Empresa'
@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
define root view entity ZC_FI_DENM_COLIGADA_EMPRESA
  as projection on ZI_FI_DENM_COLIGADA_EMPRESA
{
      @ObjectModel.text.element: ['TextBukrs']
  key Bukrs,
      @ObjectModel.text.element: ['TextBranch']
  key Branch,
  key Chave,
      Conteudo,
      Descricao,
      @ObjectModel.text.element: ['TextCreat']
      CreatedBy,
      CreatedAt,
      @ObjectModel.text.element: ['TextMod']
      LastChangedBy,
      LastChangedAt,
      LocalLastChangedAt,

      _Bukrs.EmpresaText        as TextBukrs,
      _Branch.BusinessPlaceName as TextBranch,
      _UserCre.Text             as TextCreat,
      _UserMod.Text             as TextMod
}
