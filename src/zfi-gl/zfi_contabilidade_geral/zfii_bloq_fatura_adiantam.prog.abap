*&---------------------------------------------------------------------*
*& Include ZFII_BLOQ_FATURA_ADIANTAM
*&---------------------------------------------------------------------*
  CONSTANTS lc_down_payment TYPE bseg-zlspr VALUE 'D'. "Bloq. Adiantamento

  CONSTANTS: BEGIN OF gc_param,
               modulo    TYPE ze_param_modulo  VALUE 'FI-GL',
               chave1_bz TYPE ze_param_chave   VALUE '001',
               chave2_bz TYPE ze_param_chave   VALUE '002',
               chave3_bz TYPE ze_param_chave_3 VALUE '003',
             END OF gc_param.

  DATA: lt_values TYPE STANDARD TABLE OF rgsb4,
        lt_umskz  TYPE fdp_corr_umskz_rt.

  DATA: lr_umskz TYPE RANGE OF bsik_view-umskz.

  DATA lv_setid  TYPE sethier-setid.

  IF bseg-belnr IS NOT INITIAL.
    SELECT SINGLE belnr
      FROM bseg
      INTO @DATA(lv_belnr)
     WHERE bukrs EQ @bseg-bukrs
       AND belnr EQ @bseg-belnr
       AND gjahr EQ @bseg-gjahr
       AND buzei EQ @bseg-buzei.
  ENDIF.

  CHECK bseg-belnr IS INITIAL "Documento vazio (novo).
     OR lv_belnr IS INITIAL.  "Documento não encontrado na BSEG (considerando cenários onde novos documentos iniciam com código $00001, por exemplo).

  DATA(lo_object) = NEW zclca_tabela_parametros( ).

  TRY.
      lo_object->m_get_range( EXPORTING iv_modulo = gc_param-modulo
                                        iv_chave1 = gc_param-chave1_bz
                                        iv_chave2 = gc_param-chave2_bz
                                        iv_chave3 = gc_param-chave3_bz
                              IMPORTING et_range  = lr_umskz ).
    CATCH zcxca_tabela_parametros. " Classe de exceção Tabela de Parâmetros
  ENDTRY.

  IF lr_umskz[] IS NOT INITIAL.

    SELECT COUNT( * )
      FROM bsik_view
     WHERE lifnr EQ @bseg-lifnr "Fornecedor
       AND umskz IN @lr_umskz.  "Código de Razão Especial

    CHECK sy-subrc EQ 0.
    bseg-zlspr = lc_down_payment. "Campo blog.pgto.

  ENDIF.
