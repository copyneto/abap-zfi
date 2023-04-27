@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'CDS de Contrato Cliente'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define root view entity ZI_FI_CONTRATO_CLIENTE
  as select from           ztfi_contrato               as _Contrato

  //    left outer join        ztfi_log_clcresc            as _Status on  _Contrato.contrato = _Status.contrato
  //                                                                  and _Contrato.aditivo  = _Status.aditivo

    left outer to one join ZI_FI_FILTRO_ULT_LOG_CLIENT as _UltLog on  _UltLog.Contrato = _Contrato.contrato
                                                                  and _UltLog.Aditivo  = _Contrato.aditivo

    left outer to one join ztfi_log_clcresc            as _Log2   on  _Log2.contrato  = _UltLog.Contrato
                                                                  and _Log2.aditivo   = _UltLog.Aditivo
                                                                  and _Log2.timestamp = _UltLog.Timestamp

    left outer to one join ZI_FI_FILTRO_ULT_CNPJRAIZ   as _Razsoc on  _Razsoc.Contrato = _Contrato.contrato
                                                                  and _Razsoc.Aditivo  = _Contrato.aditivo

    left outer to one join ZI_FI_FILTRO_ULT_CLIENT     as _UltCli on  _UltCli.Contrato = _Razsoc.Contrato
                                                                  and _UltCli.Aditivo  = _Razsoc.Aditivo
                                                                  and _UltCli.CnpjRaiz = _Razsoc.CNPJRaiz

  composition [0..*] of ZI_FI_LOG_CALC_CRESCIMENTO as _LOG

  association [0..1] to ZI_FI_VH_CONTRATO          as _Cont    on  _Cont.Contrato = $projection.Contrato
                                                               and _Cont.Aditivo  = $projection.Aditivo



  association [0..1] to ZI_CA_VH_BUKRS             as _Empresa on  _Empresa.Empresa = $projection.Empresa
  association [0..1] to ZI_CA_VH_BRANCH            as _LocNeg  on  _LocNeg.CompanyCode   = $projection.Empresa
                                                               and _LocNeg.BusinessPlace = $projection.LocalNegocios

  //  association [0..1] to ZC_FI_PARAM_CALC_CRES      as _ParamGjahr on  _ParamGjahr.gjahr = $projection.Gjahr
  //  association [0..1] to ZC_FI_PARAM_CONTABILI      as _ParamBudat on  _ParamBudat.budat = $projection.Budat

{
      @Consumption.valueHelpDefinition:   [{ entity: {name: 'ZI_FI_VH_CONTRATO', element: 'Contrato' } }]
  key _Contrato.contrato              as Contrato,
      @Consumption.valueHelpDefinition:   [{ entity: {name: 'ZI_FI_VH_CONTRATO', element: 'Aditivo' } }]
  key _Contrato.aditivo               as Aditivo,

      _Contrato.razao_social          as RazaoSocial,
      _Contrato.nome_fantasia         as NomeFantasia,
      _Contrato.contrato_proprio      as ContratoProprio,
      @Consumption.valueHelpDefinition:   [{ entity: {name: 'ZI_CA_VH_BUKRS', element: 'Empresa' } }]
      _Contrato.bukrs                 as Empresa,
      @Consumption.valueHelpDefinition:   [{ entity: {name: 'ZI_CA_VH_BRANCH', element: 'BusinessPlace' } }]
      _Contrato.branch                as LocalNegocios,
      _Contrato.data_ini_valid        as DataIniValid,
      _Contrato.data_fim_valid        as DataFinValid,
      @Consumption.valueHelpDefinition:   [{ entity: {name: 'ZI_CA_VH_KUNNR', element: 'Kunnr' } }]
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
      //      ''                              as Cliente,
      //      ''                              as CNPJ,
      //      '0'                             as RazaoSoci,
      _Contrato.prod_contemplado      as ProdContemplado,
      _Contrato.status                as Status,
      _Contrato.grp_economico         as GrpEconomico,
      //      case coalesce( _Status.contrato, '')
      case coalesce( _Log2.contrato, '')
      when '' then 'Não Calculado'                  -- Sem Crescimento
              else 'Calculado'                  -- Crescimento
                 end                  as Crescimento,
      //      _Contrato.crescimento           as Crescimento,
      //      case coalesce( _Status.contrato, '')
      case coalesce( _Log2.contrato, '')
            when '' then 2                        -- Sem Crescimento
                    else 3                        -- Crescimento
                       end            as CrescCriticality,
      //      case coalesce( _Status.belnr,'')
      case coalesce( _Log2.belnr,'')
            when '' then 'Não'                  -- Sem Crescimento
                    else 'Sim'                  -- Crescimento
                       end            as Contabilizado,
      //      case coalesce( _Status.belnr,'')
      case coalesce( _Log2.belnr,'')
            when '' then 2                        -- Sem Crescimento
                    else 3                        -- Crescimento
                       end            as ContabilizadoCriti,

      //      ''                              as Crescimento,
      //      ''                              as CrescCriticality,
      //      ''                              as Contabilizado,
      //      ''                              as ContabilizadoCriti,

      @Consumption.valueHelpDefinition:   [{ entity: {name: 'ZI_FI_VH_AJUSTE_ANUAL', element: 'XFLD' } }]
      _Contrato.ajuste_anual          as AjusteAnual,
      _Log2.exerc_atual               as ExercAtual,

      //      @Semantics.dateTime: true
      //      concat(
      //     concat(substring( cast( _UltLog.Timestamp as abap.char( 19 ) ), 7, 2 ), '.'),
      //     concat(substring( cast( _UltLog.Timestamp as abap.char( 19 ) ), 5, 2 ),
      //      concat('.', substring( cast( _UltLog.Timestamp as abap.char( 19 ) ), 1, 4 ))) )as ExecutadoEm,



      @Semantics.user.createdBy: true
      _Contrato.created_by            as CreatedBy,
      @Semantics.systemDate.createdAt: true
      _Contrato.created_at            as CreatedAt,
      @Semantics.user.lastChangedBy: true
      _Contrato.last_changed_by       as LastChangedBy,
      @Semantics.systemDate.lastChangedAt: true
      _Contrato.last_changed_at       as LastChangedAt,
      @Semantics.systemDate.localInstanceLastChangedAt: true
      _Contrato.local_last_changed_at as LocalLastChangedAt,
      @Consumption.valueHelpDefinition:   [{ entity: {name: 'C_FiscalYearForCompanyCodeVH', element: 'FiscalYear' } }]
      cast('' as abap.numc( 4 ))      as Gjahr,
      cast('00000000' as abap.dats)   as Budat,

      _LOG,
      _Empresa,
      _LocNeg,
      //      _ParamGjahr,
      //      _ParamBudat,
      _Cont

}
where
       _Contrato.crescimento = 'X'
  and(
       _Contrato.status      = '4'
    or _Contrato.status      = '7'
    or _Contrato.status      = '8'
  )
//  4 Aprovado
//  7 Aditivado
//  8 Renovado
//
