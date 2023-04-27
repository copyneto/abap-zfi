@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Difer Rec e Deduções (De/Para Contas)'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define root view entity ZI_FI_DEFRECE_HKONT as select from ztfi_defrece_dep
   
   composition [0..*] of ZI_fi_defrece_hkoncontra as _hkoncontra
   association [0..*] to ZI_FI_DEFRECE_VH_TYP as _tpcntsearch on $projection.Tpcnt = _tpcntsearch.DomvalueL 
{
   @EndUserText.label: 'Conta De'
    key hkont_from as HkontFrom,
    @EndUserText.label: 'Conta Para'
    hkont_to as HkontTo,
    @EndUserText.label: 'Tipo de Conta'
    
    tpcnt as Tpcnt,
    @Semantics.user.createdBy: true
    created_by as CreatedBy,
    @Semantics.systemDateTime.createdAt: true
    created_at as CreatedAt,
    @Semantics.user.lastChangedBy: true
    last_changed_by as LastChangedBy,
    @Semantics.systemDateTime.lastChangedAt: true
    last_changed_at as LastChangedAt,
    @Semantics.systemDateTime.localInstanceLastChangedAt: true
    local_last_changed_at as LocalLastChangedAt,
/*  @ObjectModel.readOnly: true
    @ObjectModel.virtualElement: true
    @ObjectModel.virtualElementCalculatedBy: 'ABAP:ZCLFI_DEFRECE_VIR_ELEM_ITENS'
    ' ' as displayContraPartida, */
    
    case tpcnt
      when 'I' then ' ' 
      else 'X' 
      end as displayContraPartida,
       
    
    _tpcntsearch,
    _hkoncontra
}
