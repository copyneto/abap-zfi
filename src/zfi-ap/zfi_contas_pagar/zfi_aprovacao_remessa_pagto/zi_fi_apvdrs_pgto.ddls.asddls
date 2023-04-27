@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Gestão de Aprovadores de Pagamento'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define root view entity ZI_FI_APVDRS_PGTO
  as select from ztfi_apvdrs_pgto
  association to C_CompanyCodeValueHelp as _Empresa on _Empresa.CompanyCode = $projection.Empresa
  association to P_USER_ADDR            as _Usuario on _Usuario.bname = $projection.Usuario
  association to ZI_FI_VH_NIVEL_APROV   as _Nivel   on _Nivel.DomvalueL = $projection.Nivel
{
      @EndUserText.label: 'Empresa'
  key bukrs                    as Empresa,
      @EndUserText.label: 'Usuário'
  key uname                    as Usuario,
      @EndUserText.label: 'Nível'
   nivel                    as Nivel,
      @EndUserText.label: 'Início da Validade'
      begda                    as DataInicio,
      @EndUserText.label: 'Fim da Validade'
      endda                    as DataFim,

      //Controle
      @EndUserText.label: 'Criado por'
      @Semantics.user.createdBy: true
      created_by               as CreatedBy,
      @EndUserText.label: 'Criado em'
      @Semantics.systemDateTime.createdAt: true
      created_at               as CreatedAt,
      @EndUserText.label: 'Última modificação por'
      @Semantics.user.lastChangedBy: true
      last_changed_by          as LastChangedBy,
      @EndUserText.label: 'Última modificação em'
      @Semantics.systemDateTime.lastChangedAt: true
      last_changed_at          as LastChangedAt,
      @EndUserText.label: 'Última modificação local em'
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      local_last_changed_at    as LocalLastChangedAt,

      //Associações
      _Empresa.CompanyCodeName as TextoEmpresa,
      _Usuario.NAME_TEXTC      as TextoUsuario,
      _Nivel.Text              as TextoNivel
}
