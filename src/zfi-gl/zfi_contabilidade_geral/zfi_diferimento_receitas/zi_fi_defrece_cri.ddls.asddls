@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Difer Rec e Deduções Critério de Seleção'
define root view entity ZI_FI_DEFRECE_CRI
  as select from ztfi_defrece_cri
  association [0..1] to I_CompanyCode as _CompanyCode on  _CompanyCode.CompanyCode = $projection.Bukrs

  association [0..1] to I_RegionText  as _RegionFrom  on  'BR'                  = _RegionFrom.Country
                                                      and 'P'                   = _RegionFrom.Language
                                                      and $projection.RegioFrom = _RegionFrom.Region

  association [0..1] to I_RegionText  as _RegionTo    on  'BR'                = _RegionTo.Country
                                                      and 'P'                 = _RegionTo.Language
                                                      and $projection.RegioTo = _RegionTo.Region

{
  key bukrs                 as Bukrs,
      @EndUserText.label: 'Região de Origem'
  key regio_from            as RegioFrom,
      @EndUserText.label: 'Região de Destino'
  key regio_to              as RegioTo,
      @EndUserText.label: 'Previsão Entrega'
      preventr              as Preventr,
      @Semantics.user.createdBy: true
      created_by            as CreatedBy,
      @Semantics.systemDateTime.createdAt: true
      created_at            as CreatedAt,
      @Semantics.user.lastChangedBy: true
      last_changed_by       as LastChangedBy,
      @Semantics.systemDateTime.lastChangedAt: true
      @EndUserText.label: 'Alterado Em'
      last_changed_at       as LastChangedAt,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      local_last_changed_at as LocalLastChangedAt,

      _CompanyCode,
      _RegionFrom,
      _RegionTo

}
