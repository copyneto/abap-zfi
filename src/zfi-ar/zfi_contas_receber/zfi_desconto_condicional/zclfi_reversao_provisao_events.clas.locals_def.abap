*"* use this source file for any type of declarations (class
*"* definitions, interfaces or type declarations) you need for
*"* components in the private section

* ===========================================================================
* CONSTANTES GLOBAIS
* ===========================================================================

CONSTANTS:

  BEGIN OF gc_tipo_reversao,
    reverter_fi_co_pa TYPE zi_fi_reversao_provisao_pdc-reverttype VALUE '1', " Reversão da Provisão PDC - Tipo de reversão: Reverter FI + CO-PA
    reverter_fi       TYPE zi_fi_reversao_provisao_pdc-reverttype VALUE '2', " Reversão da Provisão PDC - Tipo de reversão: Reverter FI
  END OF  gc_tipo_reversao,

  BEGIN OF gc_bapi_contabil,
    chave_bloq_a    TYPE bseg-zlspr VALUE 'A',   " Chave para o bloqueio de pagamento:           Bloqueado p/pgto.
    cod_razao_esp_c TYPE bseg-umskz VALUE 'C',   " Código de Razão Especial:                     Adiant. Desconto de Cliente
    app             TYPE bseg-xref2 VALUE 'APP', " Chave de referência do parceiro de negócios:  APP
    chave_lanc_09   TYPE bseg-bschl VALUE '09',  " Chave de lançamento:                          Est.Desconto de Clie
    codigo_debito_s TYPE bseg-shkzg VALUE 'S',   " Código débito/crédito:                        Débito
  END OF gc_bapi_contabil,

  BEGIN OF gc_bapi_copa,
    area_ar3c TYPE erkrs VALUE 'AR3C', " Área de resultado:         Área de Resultado 3Corações
  END OF gc_bapi_copa,

  BEGIN OF gc_param_saknr_fi,
    modulo TYPE ztca_param_val-modulo VALUE 'FI-AR' ##NO_TEXT,
    chave1 TYPE ztca_param_val-chave1 VALUE 'PDC' ##NO_TEXT,
    chave2 TYPE ztca_param_val-chave2 VALUE 'REVERSAO' ##NO_TEXT,
    chave3 TYPE ztca_param_val-chave3 VALUE 'CON50FI' ##NO_TEXT,
  END OF gc_param_saknr_fi,

  BEGIN OF gc_param_saknr_fi_co_pa,
    modulo TYPE ztca_param_val-modulo VALUE 'FI-AR' ##NO_TEXT,
    chave1 TYPE ztca_param_val-chave1 VALUE 'PDC' ##NO_TEXT,
    chave2 TYPE ztca_param_val-chave2 VALUE 'REVERSAO' ##NO_TEXT,
    chave3 TYPE ztca_param_val-chave3 VALUE 'CON50FPA' ##NO_TEXT,
  END OF gc_param_saknr_fi_co_pa,

  BEGIN OF gc_param_blart_fi,
    modulo TYPE ztca_param_val-modulo VALUE 'FI-AR' ##NO_TEXT,
    chave1 TYPE ztca_param_val-chave1 VALUE 'PDC' ##NO_TEXT,
    chave2 TYPE ztca_param_val-chave2 VALUE 'REVERSAO' ##NO_TEXT,
    chave3 TYPE ztca_param_val-chave3 VALUE 'TIPODOC' ##NO_TEXT,
  END OF gc_param_blart_fi.
