@AbapCatalog.sqlViewName: 'ZVCFICPC2L'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Query CPC2L'
define view ZC_FI_CPC2L
  as select distinct from ZI_FI_CPC2L as _Cpc2l
    left outer join       nsdm_e_mseg as _Mseg on  _Mseg.mblnr = _Cpc2l.awref
                                               and _Mseg.mjahr = _Cpc2l.kjahr
    left outer join       rbkp        as _Rbkp on  _Rbkp.belnr = _Cpc2l.awref
                                               and _Rbkp.gjahr = _Cpc2l.kjahr
    left outer join       rseg        as _Rseg on  _Rbkp.belnr = _Rseg.belnr
                                               and _Rbkp.gjahr = _Rseg.gjahr
{

  key _Cpc2l.belnr,
  key _Cpc2l.poper,
  key _Cpc2l.bdatj,
  key _Cpc2l.bwkey,
  key _Cpc2l.bwtar,
  key _Cpc2l.matnr,

      case
        when kategorie = 'VN' or kategorie = 'ZU'
          then
            case
              when kjahr != aworg
                then 0
              else
                _Cpc2l.lbkum
              end
          else
            _Cpc2l.lbkum
      end                                     as lbkum,

      _Cpc2l.meins,
      _Cpc2l.psart,

      case psart
        when 'MS'
          then psart
        else
          _Cpc2l.ptyp_proc
      end                                     as ptyp_proc,

      _Cpc2l.kategorie,
      _Cpc2l.awref,
      _Cpc2l.awtyp,
      _Cpc2l.vgart,
      _Cpc2l.stprs_old,
      _Cpc2l.waers,
      _Cpc2l.pvprs_old,
      _Cpc2l.salkv,

      case
        when kategorie = 'VN' or kategorie = 'ZU'
          then
            case
              when kjahr != aworg
                then 0
              else
                _Cpc2l.salk3
              end
          else
            _Cpc2l.salk3
      end                                     as salk3,

      _Cpc2l.curtp,
      _Cpc2l.posnr,
      _Cpc2l.peinh,
      _Cpc2l.ptyp,
      _Cpc2l.bvalt,
      _Cpc2l.ptyp_kat,
      _Cpc2l.ptyp_bvalt,
      _Cpc2l.process,
      _Cpc2l.budat,
      _Cpc2l.cpudt,
      _Cpc2l.tcode,

      case _Cpc2l.tcode
      when 'MIRO'
        then _Rbkp.xblnr
      else
        _Mseg.xblnr_mkpf
      end                                     as xblnr,

      case _Cpc2l.tcode
        when 'MIRO'
          then _Rbkp.lifnr
        when 'VL01N'
          then _Mseg.wempf
        when 'VL02N'
          then _Mseg.wempf
        else
          _Mseg.lifnr
       end                                    as lifnr,

      _Mseg.lifnr                             as lifnr_mseg,
      _Mseg.kunnr                             as kunnr_mseg,

      case _Cpc2l.kategorie
        when 'VN'
          then cast( _Cpc2l.ea_prod as dmbtr ) + cast( _Cpc2l.ma_prod as dmbtr )
        when 'ZU'
          then
            case when _Cpc2l.mlcrf_prod = 0
              then _Cpc2l.mlkeph_prod
            else
              0
            end
        else
          _Cpc2l.mlkeph_prod
      end                                     as prod,

      //@Semantics.amount.currencyCode: 'waers'
      cast( _Rseg.wrbtr as abap.dec(23,2) )  as wrbtr,
      //@Semantics.quantity.unitOfMeasure: 'meins'
      cast( _Rseg.menge as abap.dec(18,2) ) as menge

}
