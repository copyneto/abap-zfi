FUNCTION zfmfi_wf_docpagar.
*"----------------------------------------------------------------------
*"*"Interface local:
*"  IMPORTING
*"     VALUE(I_BKDF) LIKE  BKDF STRUCTURE  BKDF
*"     VALUE(I_UF05A) LIKE  UF05A STRUCTURE  UF05A
*"     VALUE(I_XVBUP) LIKE  OFIWA-XVBUP DEFAULT 'X'
*"  TABLES
*"      T_AUSZ1 STRUCTURE  AUSZ1 OPTIONAL
*"      T_AUSZ2 STRUCTURE  AUSZ2 OPTIONAL
*"      T_AUSZ3 STRUCTURE  AUSZ_CLR OPTIONAL
*"      T_BKP1 STRUCTURE  BKP1
*"      T_BKPF STRUCTURE  BKPF
*"      T_BSEC STRUCTURE  BSEC
*"      T_BSED STRUCTURE  BSED
*"      T_BSEG STRUCTURE  BSEG
*"      T_BSET STRUCTURE  BSET
*"      T_BSEU STRUCTURE  BSEU
*"----------------------------------------------------------------------

  IF NOT t_bseg[] IS INITIAL.

    IF line_exists( t_bseg[ koart = 'K' ] ).             "#EC CI_STDSEQ

*      NEW zclfi_doc_pagar_wf( iv_belnr = t_bseg[ 1 ]-belnr
*                              iv_bukrs = t_bseg[ 1 ]-bukrs
*                              iv_gjahr = t_bseg[ 1 ]-gjahr
*                              iv_buzei = t_bseg[ 1 ]-buzei )->trigger_start_wf( ).

    ENDIF.

  ENDIF.

  IF sy-tcode EQ 'FB08' AND sy-batch NE abap_true.

    IF t_bkpf[] IS NOT INITIAL.

      SELECT SINGLE wf_id
           FROM ztfi_wf_log
           INTO @DATA(lt_log)
          WHERE empresa          EQ @t_ausz1-bukrs
            AND documento        EQ @t_ausz1-belnr
            AND exercicio        EQ @t_ausz1-gjahr
            AND status_aprovacao EQ '2'.

      IF sy-subrc EQ 0.
        MESSAGE e003(zfi_wf_docpagar).
      ENDIF.

    ENDIF.

  ENDIF.

ENDFUNCTION.                                             "#EC CI_VALPAR
