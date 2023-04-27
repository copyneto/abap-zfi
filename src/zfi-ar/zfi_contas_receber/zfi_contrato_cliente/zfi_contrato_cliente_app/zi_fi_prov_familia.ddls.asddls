@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Familias da Provisão'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity zi_fi_prov_familia
  as select from ztfi_prov_fam as _Fam

  association        to parent ZI_FI_PROV_CONT as _Prov     on  $projection.DocUuidH    = _Prov.DocUuidH
                                                            and $projection.DocUuidProv = _Prov.DocUuidProv

  association [1..1] to ZI_FI_CONTRATO         as _Contrato on  $projection.DocUuidH = _Contrato.DocUuidH

  association        to ZI_CO_FAMILIA_CL       as _Familia  on  $projection.Familia = _Familia.Wwmt1
                                                            and _Familia.Spras      = $session.system_language
{

  key _Fam.doc_uuid_h          as DocUuidH,
  key _Fam.doc_uuid_prov       as DocUuidProv,
      @Consumption.valueHelpDefinition: [{ entity: { name: 'ZI_CO_FAMILIA_CL', element: 'Wwmt1' }}]
      @ObjectModel.text: { element: ['FamiliaClTxt'] }
  key _Fam.familia             as Familia,
      _Familia.Bezek           as FamiliaClTxt,
      _Prov._Contrato.Contrato as Contrato,
      _Prov._Contrato.Aditivo  as Aditivo,

      @Semantics.user.createdBy: true
      created_by               as CreatedBy,
      @Semantics.systemDateTime.createdAt: true
      created_at               as CreatedAt,
      @Semantics.user.lastChangedBy: true
      last_changed_by          as LastChangedBy,
      @Semantics.systemDateTime.lastChangedAt: true
      last_changed_at          as LastChangedAt,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      local_last_changed_at    as LocalLastChangedAt,

      // Make association public
      _Contrato,
      _Prov

}
