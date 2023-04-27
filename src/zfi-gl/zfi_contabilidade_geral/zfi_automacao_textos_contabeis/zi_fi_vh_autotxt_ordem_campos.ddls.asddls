@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Help search Ordem Campo Autom.Txt.Contab'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
@ObjectModel.resultSet.sizeCategory: #XS
define view entity ZI_FI_VH_AUTOTXT_ORDEM_CAMPOS
  as select from    dd07l as Domain
    left outer join dd07t as Text
      on  Text.domname    = Domain.domname
      and Text.as4local   = Domain.as4local
      and Text.valpos     = Domain.valpos
      and Text.as4vers    = Domain.as4vers
      and Text.ddlanguage = $session.system_language
{

      @UI.hidden: true
  key Domain.domname    as Dominio,
      @ObjectModel.text.element: ['Texto']
      @UI.textArrangement: #TEXT_LAST
  key Domain.domvalue_l as Valor,
      Text.ddtext       as Texto
}
where
      Domain.domname  = 'ZD_FI_AUTOTXT_ORDEM'
  and Domain.as4local = 'A';
