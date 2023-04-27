class ZCLFI_CL_SI_CONTABILZACAO_PROC definition
  public
  create public .

public section.

  interfaces ZCLFI_II_SI_CONTABILZACAO_PROC .
protected section.
private section.
ENDCLASS.



CLASS ZCLFI_CL_SI_CONTABILZACAO_PROC IMPLEMENTATION.


  METHOD zclfi_ii_si_contabilzacao_proc~si_contabilzacao_processamento.

    TYPES: ty_r_bstkd TYPE RANGE OF ztfi_wevo_contab-bstkd.

    DATA: lt_contab TYPE STANDARD TABLE OF ztfi_wevo_contab.

    DATA: lr_bstkd TYPE RANGE OF ztfi_wevo_contab-bstkd.

    DATA: ls_contab TYPE ztfi_wevo_contab,
          ls_bstkd  LIKE LINE OF lr_bstkd.

    DATA: lv_zvou     TYPE string,
          lv_vlr_rest TYPE string,
          lv_dt_venda TYPE string.

    CONSTANTS: lc_sign   TYPE char1           VALUE 'I',
               lc_option TYPE char2           VALUE 'EQ'.

    IF input-mt_processamento_reversa-i_bstkd IS NOT INITIAL.

      ls_contab-cod_cenario       = input-mt_processamento_reversa-i_cenario.
      ls_contab-bukrs             = input-mt_processamento_reversa-i_bukrs.
      ls_contab-bstkd             = input-mt_processamento_reversa-i_bstkd.
      ls_contab-bupla             = input-mt_processamento_reversa-i_bupla.
      ls_contab-zlsch             = input-mt_processamento_reversa-i_zlsch.
      ls_contab-cod_ressarcimento = input-mt_processamento_reversa-i_ressarcimento.
      ls_contab-vbeln             = input-mt_processamento_reversa-i_ordem_venda.
      ls_contab-voucher           = input-mt_processamento_reversa-i_voucher.
      ls_contab-datum             = sy-datum.
      ls_contab-uzeit             = sy-uzeit.
      ls_contab-uname             = sy-uname.
      ls_contab-tipo_cenario      = input-mt_processamento_reversa-i_tipo_cenario.
      ls_contab-ordem             = input-mt_processamento_reversa-i_ordem.
      ls_contab-pagamento         = input-mt_processamento_reversa-i_pagamento.
      ls_contab-mercadoria        = input-mt_processamento_reversa-i_mercadoria.
      ls_contab-lifnr             = input-mt_processamento_reversa-i_lifnr.
      ls_contab-dias              = input-mt_processamento_reversa-i_dias.
      ls_contab-adm               = input-mt_processamento_reversa-i_adm.
      ls_contab-nsu               = input-mt_processamento_reversa-i_nsu.
      ls_contab-id_pedido         = input-mt_processamento_reversa-i_id_pedido.

*      lv_dt_venda = input-mt_processamento_reversa-i_dt_venda.
*      TRANSLATE lv_dt_venda USING '. '.
*      CONDENSE lv_dt_venda NO-GAPS.
*      ls_contab-dt_venda = |{ lv_dt_venda+4(4) }{ lv_dt_venda+2(2) }{ lv_dt_venda(2) }|.
      ls_contab-dt_venda = input-mt_processamento_reversa-i_dt_venda.

*      lv_zvou = input-mt_processamento_reversa-i_zvou.
*      TRANSLATE lv_zvou USING '. '.
*      TRANSLATE lv_zvou USING ',.'.
*      CONDENSE lv_zvou NO-GAPS.
*      ls_contab-zvou = lv_zvou.
      ls_contab-zvou = input-mt_processamento_reversa-i_zvou.

*      lv_vlr_rest = input-mt_processamento_reversa-i_vlr_restituir.
*      TRANSLATE lv_vlr_rest USING '. '.
*      TRANSLATE lv_vlr_rest USING ',.'.
*      CONDENSE lv_vlr_rest NO-GAPS.
*      ls_contab-vlr_restituir = lv_vlr_rest.
      ls_contab-vlr_restituir = input-mt_processamento_reversa-i_vlr_restituir.

      APPEND ls_contab TO lt_contab.
      MODIFY ztfi_wevo_contab FROM ls_contab.

      IF sy-subrc IS INITIAL.
        COMMIT WORK AND WAIT.
      ENDIF.

*      lr_bstkd = VALUE ty_r_bstkd( BASE lr_bstkd ( sign   = lc_sign
*                                                   option = lc_option
*                                                   low    = input-mt_processamento_reversa-i_bstkd ) ).
*
*      WAIT UP TO 1 SECONDS.
*
*      SUBMIT zfir_contab_ecommerce
*        WITH s_bstkd IN lr_bstkd
*        WITH p_nomsg EQ abap_true
*         AND RETURN.

      DATA(lo_contab) = NEW zclfi_contab_reversa( ).

      lo_contab->main( EXPORTING it_contab  = lt_contab
                       IMPORTING et_retorno = DATA(lt_return) ).

      IF lt_return[] IS NOT INITIAL.

        READ TABLE lt_return INDEX 1 INTO DATA(ls_return).

        output-mt_processamento_reversa_respo-e_subrc = COND #( WHEN ls_return-subrc IS INITIAL THEN 'S' ELSE 'E' ).
        output-mt_processamento_reversa_respo-e_msg = ls_return-msg.
        output-mt_processamento_reversa_respo-e_belnr = ls_return-belnr.
        output-mt_processamento_reversa_respo-e_gjahr = ls_return-gjahr.
        output-mt_processamento_reversa_respo-e_bukrs = ls_return-bukrs.
        output-mt_processamento_reversa_respo-e_belnr_f = ls_return-belnr_f.
        output-mt_processamento_reversa_respo-e_gjahr_f = ls_return-gjahr_f.
        output-mt_processamento_reversa_respo-e_bukrs_f = ls_return-bukrs_f.

      ENDIF.

    ENDIF.

  ENDMETHOD.
ENDCLASS.
