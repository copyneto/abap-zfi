@AbapCatalog.sqlViewName: 'ZVPRGPGTO'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Programa de pagamento'
@Metadata.ignorePropagatedAnnotations: true
define view ZI_FI_PROG_PAGAMENTO
  as select distinct from I_PaymentProposalHeader as _Payment

    inner join            regup                   as _PaymentItem on  _PaymentItem.zbukr = _Payment.PayingCompanyCode
                                                                  and _PaymentItem.laufd = _Payment.PaymentRunDate
                                                                  and _PaymentItem.laufi = _Payment.PaymentRunID
                                                                  and _PaymentItem.xvorl = _Payment.PaymentRunIsProposal
                                                                  and _PaymentItem.lifnr = _Payment.Supplier
                                                                  and _PaymentItem.empfg = _Payment.PaymentRecipient
                                                                  and _PaymentItem.vblnr = _Payment.PaymentDocument

    inner join            zi_regut_last_creation  as _Regut       on  _Payment.PayingCompanyCode    = _Regut.zbukr
                                                                  and _Payment.PaymentRunDate       = _Regut.laufd
                                                                  and _Payment.PaymentRunID         = _Regut.laufi
                                                                  and _Payment.PaymentRunIsProposal = _Regut.xvorl

    inner join            I_CompanyCode           as _Bukrs       on _Bukrs.CompanyCode = _Payment.PayingCompanyCode

    inner join            I_SupplierCompany       as _Supplier    on  _Supplier.Supplier    = _Payment.Supplier
                                                                  and _Supplier.CompanyCode = _Payment.PayingCompanyCode

    left outer join       ZI_FI_DOC_FDGRV         as _Fdgrv       on  _PaymentItem.zbukr = _Fdgrv.Bukrs
                                                                  and _PaymentItem.gjahr = _Fdgrv.Gjahr
                                                                  and _PaymentItem.belnr = _Fdgrv.Belnr
                                                                  and _PaymentItem.buzei = _Fdgrv.Buzei

    left outer join       bseg                    as _Bseg        on  _PaymentItem.zbukr = _Bseg.bukrs
                                                                  and _PaymentItem.gjahr = _Bseg.gjahr
                                                                  and _PaymentItem.belnr = _Bseg.belnr
                                                                  and _PaymentItem.buzei = _Bseg.buzei

{
  key _Payment.PayingCompanyCode                                             as CompanyCode,
  key _Payment.PaymentRunID,
      //  key cast( _PaymentItem.laufd as netdt )                                          as NetDueDate,
      //  key cast( _Bseg.netdt as netdt )                                           as NetDueDate,
  key case when _PaymentItem.vblnr is initial
                 then _Bseg.netdt
                 else  cast( _PaymentItem.laufd as netdt ) end               as NetDueDate,


      //  key _Regut.tstim                                                           as RunHourTo,

  key case tims_is_valid(_Regut.tstim)
      when 1 then _Regut.tstim else '000000' end                             as RunHourTo,

  key cast( coalesce( _Fdgrv.Fdgrv, _Supplier.CashPlanningGroup ) as fdgrv ) as CashPlanningGroup,
  key _Payment.Supplier,

      //Item do documento
  key _PaymentItem.buzei                                                     as AccountingDocumentItem,

      case tims_is_valid(_Regut.tstim)
      when 1 then _Regut.tstim else '000000' end                             as dataConv,

      // pferraz 10.05.23 - Valores credito/debito - inicio
      //      cast( case when _PaymentItem.vblnr is initial
      //                 then 0
      //                 else abs( _PaymentItem.wrbtr )
      //            end as rwbtr )                                                   as PaidAmountInPaytCurrency,

      case _PaymentItem.shkzg
        when 'S'
            then cast(  abs( _PaymentItem.wrbtr )   as rwbtr )
        else
            cast(  ( -1 * abs( _PaymentItem.wrbtr ) )  as rwbtr )  end       as PaidAmountInPaytCurrency,

      //     cast(  _Payment.PaidAmountInPaytCurrency   as rwbtr )                                 as PaidAmountInPaytCurrency,
      // pferraz 10.05.23 - Valores credito/debito - fim
      //      cast( abs( _Payment.PaidAmountInPaytCurrency ) as rwbtr )                as PaidAmountInPaytCurrency,

      cast( _PaymentItem.waers  as waers )                                   as PaymentCurrency,

      cast( _Regut.dwdat as dodat )                                          as DownloadDate,

      cast( case when _Regut.laufd > _Regut.tsdat then 'P'
                 when _Regut.laufd = _Regut.tsdat then 'E'
                 else ''
             end
      as ze_tiporel )                                                        as RepType,


      cast( case when  ( _PaymentItem.vblnr is initial and _PaymentItem.zlspr is initial )
                 then abs( _PaymentItem.wrbtr )
                 else 0
            end as dmbtr )                                                   as OpenAmount,

      cast( case when ( _PaymentItem.vblnr is initial and _PaymentItem.zlspr is not initial )
                 then abs( _PaymentItem.wrbtr )
                 else 0
            end as dmbtr )                                                   as BlockedAmount,

      //      AccountingDocumentItem,

      cast( case when _PaymentItem.hbkid is initial and _PaymentItem.vblnr is not initial
                 then _Supplier.HouseBank
                 else _PaymentItem.hbkid
            end as hbkid )                                                   as HouseBank,
      cast( _PaymentItem.zlsch as rzawe )                                    as PaymentMethod,
      cast( _PaymentItem.zlspr as dzlspr )                                   as PaymentBlockingReason,


      _PaymentItem.vblnr                                                     as PaymentDocument,
      _PaymentItem.belnr                                                     as AccountingDocument,
      _PaymentItem.gjahr                                                     as FiscalYear,
      cast( '' as   bstat_d)                                                 as Bstat,
      _PaymentItem.umskz                                                     as Umskz,
      @Semantics.amount.currencyCode: 'PaymentCurrency'
      cast( abs( _PaymentItem.wrbtr ) as dmbtr )                             as Amount,
      _PaymentItem.blart                                                     as DocType,
      _PaymentItem.bupla                                                     as Branch,
      _PaymentItem.xblnr                                                     as Reference




}
where
      _Payment.PaymentDocument <> ''
  and _Payment.PaymentMethod   <> 'G'

union select distinct from ZC_FI_APROV_BSIK  as _bsik

  inner join               I_CompanyCode     as _Bukrs       on _Bukrs.CompanyCode = _bsik.bukrs

  inner join               I_SupplierCompany as _Supplier    on  _Supplier.Supplier    = _bsik.lifnr
                                                             and _Supplier.CompanyCode = _bsik.bukrs

//pferraz 18.07.23 - Documentos em aberto duplicados - inicio

  left outer join          regup             as _PaymentItem on  _PaymentItem.zbukr = _bsik.bukrs
                                                             and _PaymentItem.belnr = _bsik.belnr
                                                             and _PaymentItem.gjahr = _bsik.gjahr
                                                             and _PaymentItem.buzei = _bsik.buzei

//pferraz 18.07.23 - Documentos em aberto duplicados - fim

  left outer join          ZI_FI_DOC_FDGRV   as _Fdgrv       on  _bsik.bukrs = _Fdgrv.Bukrs
                                                             and _bsik.gjahr = _Fdgrv.Gjahr
                                                             and _bsik.belnr = _Fdgrv.Belnr
                                                             and _bsik.buzei = _Fdgrv.Buzei



{
  key _bsik.bukrs                                                            as CompanyCode,
  key cast( '' as laufi )                                                    as PaymentRunID,
  key cast( _bsik.laufd as netdt )                                           as NetDueDate,
      //  key _bsik.lauhr                                                            as RunHourTo,
  key case tims_is_valid(_bsik.lauhr)
    when 1 then _bsik.lauhr else '000000' end                                as RunHourTo,

  key cast( coalesce( _Fdgrv.Fdgrv, _Supplier.CashPlanningGroup ) as fdgrv ) as CashPlanningGroup,
  key _bsik.lifnr                                                            as Supplier,

      //Item do documento
  key _bsik.buzei                                                            as AccountingDocumentItem,


      case tims_is_valid( _bsik.lauhr)
      when 1 then  _bsik.lauhr else '000000' end                             as dataConv,


      cast( 0 as rwbtr )                                                     as PaidAmountInPaytCurrency,

      cast( _bsik.waers as waers )                                           as PaymentCurrency,

      cast( '00000000' as dodat )                                            as DownloadDate,

      cast( 'P' as ze_tiporel )                                              as RepType,

      cast(
        case coalesce( _bsik.zlspr, '' )
          when ''
            then abs( coalesce( _bsik.dmbtr, 0 ) )
          else 0
        end
      as dmbtr )                                                             as OpenAmount,

      cast(
        case coalesce( _bsik.zlspr, '' )
          when ''
            then 0
          else abs( coalesce( _bsik.dmbtr, 0 ) )
        end
      as dmbtr )                                                             as BlockedAmount,

      //      _bsik.buzei                                                            as AccountingDocumentItem,

      //      cast( '' as hbkid )                                                    as HouseBank,
      _bsik.hbkid                                                            as HouseBank,
      _bsik.zlsch                                                            as PaymentMethod,
      //      cast( '' as rzawe )                                                    as PaymentMethod,
      _bsik.zlspr                                                            as PaymentBlockingReason,


      _bsik.augbl                                                            as PaymentDocument,
      _bsik.belnr                                                            as AccountingDocument,
      _bsik.gjahr                                                            as FiscalYear,
      _bsik.bstat                                                            as Bstat,
      _bsik.umskz                                                            as Umskz,
      cast( abs( coalesce( _bsik.dmbtr, 0 ) ) as dmbtr )                     as Amount,

      _bsik.blart                                                            as DocType,
      _bsik.bupla                                                            as Branch,
      _bsik.xblnr                                                            as Reference


}
//pferraz 18.07.23 - Documentos em aberto duplicados - inicio
where
  _PaymentItem.vblnr = ''
//pferraz 18.07.23 - Documentos em aberto duplicados - Fim

union select distinct from ZC_FI_APROV_BSIK  as _bsik

  inner join               I_CompanyCode     as _Bukrs    on _Bukrs.CompanyCode = _bsik.bukrs

  inner join               I_SupplierCompany as _Supplier on  _Supplier.Supplier    = _bsik.lifnr
                                                          and _Supplier.CompanyCode = _bsik.bukrs

  left outer join          ZI_FI_DOC_FDGRV   as _Fdgrv    on  _bsik.bukrs = _Fdgrv.Bukrs
                                                          and _bsik.gjahr = _Fdgrv.Gjahr
                                                          and _bsik.belnr = _Fdgrv.Belnr
                                                          and _bsik.buzei = _Fdgrv.Buzei
{
  key _bsik.bukrs                                                            as CompanyCode,
  key cast( '' as laufi )                                                    as PaymentRunID,
  key cast( _bsik.laufd as netdt )                                           as NetDueDate,
      //  key _bsik.lauhr                                                            as RunHourTo,

  key case tims_is_valid(_bsik.lauhr)
      when 1 then _bsik.lauhr else '000000' end                              as RunHourTo,


  key cast( coalesce( _Fdgrv.Fdgrv, _Supplier.CashPlanningGroup ) as fdgrv ) as CashPlanningGroup,
  key _bsik.lifnr                                                            as Supplier,

      //Item do documento
  key _bsik.buzei                                                            as AccountingDocumentItem,


      case tims_is_valid( _bsik.lauhr)
      when 1 then  _bsik.lauhr else '000000' end                             as dataConv,


      //      cast( case when _bsik.lauhr = '120000'
      //                 then '000000'
      //                 else  _bsik.lauhr
      //                 end as abap.char(6) )    as dataConv,

      cast( 0 as rwbtr )                                                     as PaidAmountInPaytCurrency,

      cast( _bsik.waers as waers )                                           as PaymentCurrency,

      cast( '00000000' as dodat )                                            as DownloadDate,

      cast( 'E' as ze_tiporel )                                              as RepType,

      cast(
        case coalesce( _bsik.zlspr, '' )
          when ''
            then abs( coalesce( _bsik.dmbtr, 0 ) )
          else 0
        end
      as dmbtr )                                                             as OpenAmount,

      cast(
        case coalesce( _bsik.zlspr, '' )
          when ''
            then 0
          else abs( coalesce( _bsik.dmbtr, 0 ) )
        end
      as dmbtr )                                                             as BlockedAmount,

      //      _bsik.buzei                                                            as AccountingDocumentItem,

      //      cast( '' as hbkid )                                                    as HouseBank,
      _bsik.hbkid                                                            as HouseBank,
      _bsik.zlsch                                                            as PaymentMethod,
      //      cast( '' as rzawe )                                                    as PaymentMethod,
      _bsik.zlspr                                                            as PaymentBlockingReason,


      _bsik.augbl                                                            as PaymentDocument,
      _bsik.belnr                                                            as AccountingDocument,
      _bsik.gjahr                                                            as FiscalYear,
      _bsik.bstat                                                            as Bstat,
      _bsik.umskz                                                            as Umskz,
      cast( abs( coalesce( _bsik.dmbtr, 0 ) ) as dmbtr )                     as Amount,

      _bsik.blart                                                            as DocType,
      _bsik.bupla                                                            as Branch,
      _bsik.xblnr                                                            as Reference


}
