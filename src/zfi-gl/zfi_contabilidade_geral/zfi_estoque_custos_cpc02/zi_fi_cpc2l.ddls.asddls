@AbapCatalog.sqlViewName: 'ZVIFICPC2L'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Query CPC2L'
define view ZI_FI_CPC2L
  as select from    mlpp
    inner join      mlcr                      on  mlcr.belnr = mlpp.belnr
                                              and mlcr.kjahr = mlpp.kjahr
                                              and mlcr.posnr = mlpp.posnr
                                              and mlcr.bdatj = mlpp.bdatj
                                              and mlcr.poper = mlpp.poper
    inner join      mlit                      on  mlit.belnr = mlpp.belnr
                                              and mlit.kjahr = mlpp.kjahr
                                              and mlit.posnr = mlpp.posnr
    inner join      mlhd                      on  mlhd.belnr = mlit.belnr
                                              and mlhd.kjahr = mlit.kjahr
    left outer join ZI_FI_CPC2L_CKML as _ckml on  mlit.kalnr = _ckml.Kalnr
                                              and mlcr.bdatj = _ckml.Bdatj
                                              and mlcr.poper = _ckml.Poper
    left outer join mlcrf            as _mlcrf           on  _mlcrf.belnr = mlit.belnr
                                                         and _mlcrf.posnr = mlit.posnr
                                                         and _mlcrf.bdatj = mlcr.bdatj
                                                         and _mlcrf.poper = mlcr.poper
                                                         and _mlcrf.curtp = '10'
                                                         and _mlcrf.feldg = 'ZUO'
    left outer join mlkeph           as _mlkeph         on  _mlkeph.belnr = mlit.belnr
                                                        and _mlkeph.kjahr = mlit.kjahr
                                                        and _mlkeph.posnr = mlit.posnr
                                                        and _mlkeph.bdatj = mlcr.bdatj
                                                        and _mlkeph.poper = mlcr.poper
                                                        and _mlkeph.kkzst = ''
                                                        and _mlkeph.curtp = '10'
{
  key mlpp.belnr,
  key mlpp.poper,
  key mlpp.bdatj,
  key mlit.bwkey,
  key mlit.bwtar,
  key mlit.matnr,

      mlpp.lbkum,
      mlit.meins,

      case
        when mlit.kategorie is initial
          then 'BB'
        else
          mlit.ptyp_proc
      end                                                                                                                                               as ptyp_proc,

      case
      when mlit.kategorie is initial
        then 'ZU'
      else
        mlit.kategorie
      end                                                                                                                                               as kategorie,

      mlhd.awref,
      mlhd.awtyp,
      mlhd.vgart,
      mlcr.stprs_old,
      mlcr.waers,
      mlcr.pvprs_old,
      mlcr.salkv,
      mlcr.salk3,
      mlcr.curtp,
      mlpp.posnr,
      mlcr.peinh,
      mlit.ptyp,
      mlit.bvalt,
      mlit.ptyp_kat,
      mlit.ptyp_bvalt,
      mlit.process,
      mlit.psart,
      mlpp.budat,
      mlhd.cpudt,
      mlhd.tcode,
      mlhd.kjahr,
      mlhd.aworg,

      division( _ckml.vnkdm_ea * mlpp.lbkum, coalesce( _ckml.vnkumo, 1 ), 3 ) + division( _ckml.vnprd_ea * mlpp.lbkum, coalesce( _ckml.vnkumo, 1 ), 3 ) as ea_prod,

      division( _ckml.vnkdm_ma * mlpp.lbkum, coalesce( _ckml.vnkumo, 1 ), 3 ) + division( _ckml.vnprd_ma * mlpp.lbkum, coalesce( _ckml.vnkumo, 1 ), 3 ) as ma_prod,

      _mlcrf.prdif + _mlcrf.krdif                                                                                                                       as mlcrf_prod,

      _mlkeph.kst001 + _mlkeph.kst003 + _mlkeph.kst005 + _mlkeph.kst007 +
      _mlkeph.kst009 + _mlkeph.kst011 + _mlkeph.kst013 + _mlkeph.kst015 +
      _mlkeph.kst017 + _mlkeph.kst019 + _mlkeph.kst021 + _mlkeph.kst023 +
      _mlkeph.kst025 + _mlkeph.kst027 + _mlkeph.kst029 + _mlkeph.kst031 +
      _mlkeph.kst033 + _mlkeph.kst035 + _mlkeph.kst037 + _mlkeph.kst039                                                                                 as mlkeph_prod

}
where
      mlcr.curtp =       '10'
  //and mlit.psart between 'MS' and 'UP'
