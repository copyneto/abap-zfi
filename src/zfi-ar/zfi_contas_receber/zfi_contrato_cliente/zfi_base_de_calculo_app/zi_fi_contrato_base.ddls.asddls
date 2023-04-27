@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Contrato de cliente Base de Calculo'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define root view entity ZI_FI_CONTRATO_BASE
  as select from           ztfi_contrato               as _Contrato

    left outer join        ZI_FI_FILTRO_ULT_LOG_CLIENT as _UltLog on  _UltLog.Contrato = _Contrato.contrato
                                                                  and _UltLog.Aditivo  = _Contrato.aditivo
    left outer join        ztfi_log_clcresc            as _Log2   on  _Log2.contrato  = _UltLog.Contrato
                                                                  and _Log2.aditivo   = _UltLog.Aditivo
                                                                  and _Log2.timestamp = _UltLog.Timestamp

    left outer to one join ZI_FI_FILTRO_ULT_CNPJRAIZ   as _Razsoc on  _Razsoc.Contrato = _Contrato.contrato
                                                                  and _Razsoc.Aditivo  = _Contrato.aditivo

    left outer to one join ZI_FI_FILTRO_ULT_CLIENT     as _UltCli on  _UltCli.Contrato = _Razsoc.Contrato
                                                                  and _UltCli.Aditivo  = _Razsoc.Aditivo
                                                                  and _UltCli.CnpjRaiz = _Razsoc.CNPJRaiz

  composition [0..*] of ZI_FI_BASE_DE_CALCULO as _BASE


  association [0..1] to ZI_CA_VH_BUKRS        as _Empresa on  _Empresa.Empresa = $projection.Empresa
  association [0..1] to ZI_CA_VH_BRANCH       as _LocNeg  on  _LocNeg.CompanyCode   = $projection.Empresa
                                                          and _LocNeg.BusinessPlace = $projection.LocalNegocios

  //  association [0..1] to ZC_FI_PARAM_CALC_CRES      as _ParamGjahr on  _ParamGjahr.gjahr = $projection.Gjahr
  //  association [0..1] to ZC_FI_PARAM_CONTABILI      as _ParamBudat on  _ParamBudat.budat = $projection.Budat

{
  key _Contrato.contrato              as Contrato,
  key _Contrato.aditivo               as Aditivo,
      _Contrato.contrato_proprio      as ContratoProprio,
      @Consumption.valueHelpDefinition:   [{ entity: {name: 'ZI_CA_VH_BUKRS', element: 'Empresa' } }]
      _Contrato.bukrs                 as Empresa,
      @Consumption.valueHelpDefinition:   [{ entity: {name: 'ZI_CA_VH_BRANCH', element: 'BusinessPlace' } }]
      _Contrato.branch                as LocalNegocios,
      _Contrato.data_ini_valid        as DataIniValid,
      _Contrato.data_fim_valid        as DataFinValid,
      _UltCli.Cliente                 as Cliente,
      case when _UltCli.Cnpj is initial then ''
           else concat( substring(_UltCli.Cnpj, 1, 2),
                concat( '.',
                concat( substring(_UltCli.Cnpj, 3, 3),
                concat( '.',
                concat( substring(_UltCli.Cnpj, 6, 3),
                concat( '/',
                concat( substring(_UltCli.Cnpj, 9, 4),
                concat( '-',  substring(_UltCli.Cnpj, 13, 2) ) ) ) ) ) ) ) )
                                  end as CNPJ,

      _Razsoc.RazaoSoci               as RazaoSoci,
      _Contrato.prod_contemplado      as ProdContemplado,
      _Contrato.status                as Status,
      _Contrato.grp_economico         as GrpEconomico,
      _Contrato.crescimento           as Crescimento,
      case _Contrato.crescimento
      when 'X' then 3                                 -- Crescimento
      when ''  then 1                                 -- Sem Crescimento
               else 0 end             as CrescCriticality,
      _Contrato.ajuste_anual          as AjusteAnual,
      _Log2.exerc_atual               as ExercAtual,
      _Contrato.created_by            as CreatedBy,
      _Contrato.created_at            as CreatedAt,
      _Contrato.last_changed_by       as LastChangedBy,
      _Contrato.last_changed_at       as LastChangedAt,
      _Contrato.local_last_changed_at as LocalLastChangedAt,
      //      @Consumption.valueHelpDefinition:   [{ entity: {name: 'C_FiscalYearForCompanyCodeVH', element: 'FiscalYear' } }]
      //      cast('' as abap.numc( 4 ))      as Gjahr,
      //      cast('00000000' as abap.dats)   as Budat,



      /* Associations */
      _BASE,
      _Empresa,
      _LocNeg
      //      _ParamGjahr,
      //      _ParamBudat

}
where
    _Contrato.crescimento =  'X'
  and(
    _UltLog.Contrato      <> ''
  )
