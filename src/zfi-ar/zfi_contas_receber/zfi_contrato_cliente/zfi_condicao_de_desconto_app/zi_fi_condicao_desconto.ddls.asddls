@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Codição de Deconto'
define root view entity ZI_FI_CONDICAO_DESCONTO
  as select from ztfi_cad_cond
//  association [0..1] to I_SalesPricingConditionTypeVH as _Condition on $projection.TipoCond = _Condition.ConditionType

{
  key tipo_cond                    as TipoCond,
//      _Condition.ConditionTypeName as Name,
     text_tipo_cond               as Text,
      @Semantics.user.createdBy: true
      created_by                   as CreatedBy,
      @Semantics.systemDateTime.createdAt: true
      created_at                   as CreatedAt,
      @Semantics.user.lastChangedBy: true
      last_changed_by              as LastChangedBy,
      @Semantics.systemDateTime.lastChangedAt: true
      last_changed_at              as LastChangedAt,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      local_last_changed_at        as LocalLastChangedAt
}
