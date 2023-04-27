@EndUserText.label: 'CGC das Coligadas por Empresa'
@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
define root view entity ZC_FI_CGC_COLIGADAS_EMPRES
  as projection on ZI_FI_CGC_COLIGADAS_EMPRES
{
      @ObjectModel.text.element: ['TextEmp']
  key Bukrs,
      @ObjectModel.text.element: ['TextBupl']
  key Bupla,
      @ObjectModel.text.element: ['CNPJText']
  key Cgc,
      @ObjectModel.text.element: ['TextKunnr']
      Kunnr,
      @ObjectModel.text.element: ['TextLifnr']
      Lifnr,
      Filial,
      @ObjectModel.text.element: ['TextOrgv']
      Vkorg,
      @ObjectModel.text.element: ['TextClient']
      ColCi,
      @ObjectModel.text.element: ['TextUserCrea']
      CreatedBy,
      CreatedAt,
      @ObjectModel.text.element: ['TextUserMod']
      LastChangedBy,
      LastChangedAt,
      LocalLastChangedAt,

      CNPJText,
      _Bukrs.EmpresaText   as TextEmp,
      _Bupla.Name          as TextBupl,
      _Kunnr.KunnrName     as TextKunnr,
      _Lifnr.LifnrCodeName as TextLifnr,
      _Vkorg.OrgVendasText as TextOrgv,
      _Client.KunnrName    as TextClient,
      _UserCre.Text        as TextUserCrea,
      _UserMod.Text        as TextUserMod
}
