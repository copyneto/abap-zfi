@AccessControl.authorizationCheck: #CHECK
@AbapCatalog.viewEnhancementCategory: [#NONE]

@EndUserText.label: 'Cnpj Raiz'

@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define root view entity ZI_FI_RAIZ_CNPJ
  as select from ztfi_raiz_cnpj as _Raiz

  association [1..1] to ZI_FI_CONTRATO      as _Contrato on $projection.DocUuidH = _Contrato.DocUuidH
  composition [0..*] of ZI_FI_RAIZ_CLIENTES as _Clientes
{
  key doc_uuid_h                   as DocUuidH, 
  key doc_uuid_raiz                as DocUuidRaiz,
      cnpj_raiz                    as CnpjRaiz,
      case
          when _Raiz.contrato is initial then _Contrato.Contrato
          else _Raiz.contrato end  as Contrato,
      case
          when _Raiz.aditivo   is initial then _Contrato.Aditivo
          else _Raiz.aditivo   end as Aditivo,
      razao_soci                   as RazaoSoci,
      nome_fanta                   as NomeFanta,
      @Semantics.user.createdBy: true
      created_by                   as CreatedBy,
      @Semantics.systemDateTime.createdAt: true
      created_at                   as CreatedAt,
      @Semantics.user.lastChangedBy: true
      last_changed_by              as LastChangedBy,
      @Semantics.systemDateTime.lastChangedAt: true
      last_changed_at              as LastChangedAt,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      local_last_changed_at        as LocalLastChangedAt,
      _Clientes // Make association public
}
