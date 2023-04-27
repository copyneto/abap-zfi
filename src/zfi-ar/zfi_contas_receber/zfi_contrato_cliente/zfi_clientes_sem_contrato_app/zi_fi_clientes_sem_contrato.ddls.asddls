@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Clientes Sem Contrato'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define root view entity ZI_FI_CLIENTES_SEM_CONTRATO
  as select from ztfi_cad_semcont
  association [0..1] to ZI_FI_DIA_SEMANA    as _Semana   on _Semana.StatusId = $projection.DiaSemana
  association [0..1] to I_CompanyCodeVH     as _Company  on $projection.Bukrs = _Company.CompanyCode
  association [0..1] to I_Customer_VH       as _Customer on $projection.Kunnr = _Customer.Customer

  association [0..1] to ZI_FI_CLIENTE_KDKG1 as _kna1     on $projection.Kunnr = _kna1.Kunnr
{
  key bukrs                    as Bukrs,
  key kunnr                    as Kunnr,
     _kna1.Kdkg1              as GrupoCond,
      _Company.CompanyCodeName as CompanyCodeName,
      _Customer.CustomerName   as CustomerName,
      _kna1.Vtext              as Vtext,
      dia_fixo                 as DiaFixo,
      @Semantics.calendar.week: true
      dia_semana               as DiaSemana,
      _Semana.StatusText       as DiaSemanaText,
      @Semantics.user.createdBy: true
      created_by               as CreatedBy,
      @Semantics.systemDateTime.createdAt: true
      created_at               as CreatedAt,
      @Semantics.user.lastChangedBy: true
      last_changed_by          as LastChangedBy,
      @Semantics.systemDateTime.lastChangedAt: true
      last_changed_at          as LastChangedAt,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      local_last_changed_at    as LocalLastChangedAt
}
