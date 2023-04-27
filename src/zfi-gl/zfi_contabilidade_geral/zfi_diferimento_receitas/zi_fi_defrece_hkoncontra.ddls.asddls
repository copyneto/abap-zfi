@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'CDS de Interface - Mercado Externo Item'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZI_fi_defrece_hkoncontra
  as select from ztfi_defrece_con
  association to parent ZI_FI_DEFRECE_HKONT as _DEFRECE_HKONT on _DEFRECE_HKONT.HkontFrom = $projection.HkontFrom 

{
   key hkont_from as HkontFrom,
   key hkont_contra as HkontContra,
   created_by as CreatedBy,
   created_at as CreatedAt,
   last_changed_by as LastChangedBy,
   last_changed_at as LastChangedAt,
   local_last_changed_at as LocalLastChangedAt,
   
   _DEFRECE_HKONT
      
}
