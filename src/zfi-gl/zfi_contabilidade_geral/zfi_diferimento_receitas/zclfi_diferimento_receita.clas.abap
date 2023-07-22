"!<p><h2>Classe para manipular dados do mercado interno</h2></p>
"!<p><strong>Autor:</strong>Denilson Pina</p>
"!<p><strong>Data:</strong>11/02/2022</p>
class ZCLFI_DIFERIMENTO_RECEITA definition
  public
  final
  create public .

public section.

  types:
    ty_rang_bukrs TYPE RANGE OF bukrs .
  types:
    ty_rang_budat TYPE RANGE OF budat .

    "! Executa quando instância a classe
    "! @parameter ir_bukrs | Empresa
    "! @parameter ir_budat | Data de seleção
    "! @parameter iv_belnr | Numero documento
    "! @parameter iv_gjahr | Ano documento
  methods CONSTRUCTOR
    importing
      !IR_BUKRS type TY_RANG_BUKRS
      !IR_BUDAT type TY_RANG_BUDAT
      !IV_BELNR type BKPF-BELNR optional
      !IV_GJAHR type BKPF-GJAHR optional .
    "! Processa Mercado Interno
    "! @parameter rt_return | Retorna tabela final
  methods PROCESSA_MERC_INT
    returning
      value(RT_RETURN) type ZCTGFI_OUT_MERC_INT .
  PROTECTED SECTION.
  PRIVATE SECTION.

    CONSTANTS : gc_doc_type TYPE char4 VALUE 'Z002',
                gc_type     TYPE char4 VALUE 'TMFO',
                gc_dif      TYPE /scmtms/tor_event VALUE 'DIFERIMENTO',
                gc_entr_cli TYPE /scmtms/tor_event VALUE 'ENTREGUE_NO_CLIENTE',
                gc_entr_total TYPE /scmtms/tor_event VALUE 'ENTREGUE_TOTAL',
                gc_entr_parc TYPE /scmtms/tor_event VALUE 'ENTREGUE_PARCIAL',
                gc_modulo   TYPE ztca_param_par-modulo VALUE 'FI-GL'.

    DATA: gr_bukrs TYPE RANGE OF bukrs,
          gr_budat TYPE RANGE OF budat.

    DATA: gv_belnr TYPE bkpf-belnr,
          gv_gjahr TYPE bkpf-gjahr.


    METHODS:
      "! Seleção dos dados de mercado interno
      "! @parameter rt_return | Retorna tabela
      get_data_merc_int RETURNING VALUE(rt_return) TYPE zctgfi_out_merc_int,


      "! Busca unidade de frete
      "! @parameter it_remessa | Tabela com remessas
      "! @parameter rt_return  | Retorna tabela com unidade de frete
      get_unid_frete IMPORTING it_remessa       TYPE vbeln_vl_t
                     RETURNING VALUE(rt_return) TYPE zctgfi_rem_unid_frete,

      "! Cadastra deferimento
      "! @parameter iv_unid_frete | Unidade de frete
      "! @parameter iv_preventr   | Dias
      "! @parameter iv_doc_date   | Data documento
      set_diferimento IMPORTING iv_unid_frete TYPE vbeln
                                iv_preventr   TYPE i
                                iv_doc_date   TYPE datum,

      "! Busca parâmetro
      "! @parameter iv_chave1 | Chave 1
      "! @parameter iv_chave2 | Chave 2
      "! @parameter iv_chave3 | Chave 3
      "! @parameter rv_return | Retorna valor
      get_param IMPORTING iv_chave1        TYPE ztca_param_val-chave1
                          iv_chave2        TYPE ztca_param_val-chave2
                          iv_chave3        TYPE ztca_param_val-chave3
                RETURNING VALUE(rv_return) TYPE i.
ENDCLASS.



CLASS ZCLFI_DIFERIMENTO_RECEITA IMPLEMENTATION.


  METHOD constructor.

    gr_bukrs = ir_bukrs.
    gr_budat = ir_budat.

    gv_belnr = iv_belnr.
    gv_gjahr =  iv_gjahr.

  ENDMETHOD.


  METHOD get_data_merc_int.

    SELECT a~bukrs,
           a~belnr,
           a~gjahr,
           a~blart,
           a~bldat,
           a~budat,
           b~accountingdocument  ,
           b~billingdocument     ,
           b~billingdocumenttype ,
           b~billingdocumentdate,
           b~payerparty,
           vbelv AS remessa,
           d~billtopartyregion ,
           d~plantregion

      FROM p_bkpf_com AS a

       INNER JOIN i_billingdocumentbasic AS b
          ON b~accountingdocument EQ a~awkey

       INNER JOIN vbfa AS c
          ON c~vbeln EQ b~billingdocument
         AND vbtyp_v EQ 'J'

       LEFT OUTER JOIN  i_billingdocextditembasic  AS d
         ON  d~billingdocument EQ b~billingdocument

      WHERE a~bukrs IN @gr_bukrs
        AND a~budat IN @gr_budat
*        AND a~belnr EQ @gv_belnr
*        AND a~gjahr EQ @gv_gjahr
        AND b~billingdocumenttype NE @gc_doc_type

        INTO TABLE @rt_return.                          "#EC CI_SEL_DEL

    DELETE ADJACENT DUPLICATES FROM rt_return COMPARING bukrs belnr gjahr billingdocument.


    IF gv_belnr IS NOT INITIAL.
      DELETE rt_return WHERE belnr NE gv_belnr.          "#EC CI_STDSEQ
    ENDIF.

    IF gv_gjahr IS NOT INITIAL.
      DELETE rt_return WHERE gjahr NE  gv_gjahr.         "#EC CI_STDSEQ
    ENDIF.

  ENDMETHOD.


  METHOD get_unid_frete.

    DATA: lt_docflow TYPE tdt_docflow.

    LOOP AT it_remessa ASSIGNING FIELD-SYMBOL(<fs_remessa>).

      CALL FUNCTION 'SD_DOCUMENT_FLOW_GET' "#EC CI_SEL_NESTED
        EXPORTING
          iv_docnum  = <fs_remessa>
        IMPORTING
          et_docflow = lt_docflow.

      IF lt_docflow IS NOT INITIAL.

        TRY.
            DATA(ls_flow) = lt_docflow[ vbtyp_n = gc_type ]. "#EC CI_STDSEQ

            APPEND VALUE #( remessa = <fs_remessa>
                            unid_frete = ls_flow-docnum ) TO rt_return.
          CATCH cx_sy_itab_line_not_found.
        ENDTRY.

      ENDIF.

    ENDLOOP.

  ENDMETHOD.


  METHOD set_diferimento.

    CONSTANTS: lc_option TYPE char2 VALUE 'EQ',
               lc_sign   TYPE char2 VALUE 'I'.

    DATA: ls_selpar TYPE /bobf/s_frw_query_selparam,
          lt_selpar TYPE /bobf/t_frw_query_selparam.

    DATA: lt_root TYPE /scmtms/t_tor_root_k,
          lt_exec TYPE /scmtms/t_tor_exec_k,
          ls_exec TYPE /scmtms/s_tor_exec_k.

    DATA: lo_message2  TYPE REF TO /bobf/if_frw_message,
          lv_rejected  TYPE boole_d,
          lv_date_char TYPE string,
          lv_date      TYPE datum,
          lv_uzeit     TYPE uzeit,
          lv_timestamp TYPE tzonref-tstamps.

    DATA(lo_svc_mngr) = /bobf/cl_tra_serv_mgr_factory=>get_service_manager( /scmtms/if_tor_c=>sc_bo_key ).

    APPEND VALUE #( attribute_name = /scmtms/if_tor_c=>sc_query_attribute-root-root_elements-tor_id
                    option         = lc_option
                    sign           = lc_sign
                    low            = iv_unid_frete
                  ) TO lt_selpar.

    TRY.
        lo_svc_mngr->query(  EXPORTING
                                iv_query_key            = /scmtms/if_tor_c=>sc_query-root-root_elements
                                it_selection_parameters = lt_selpar
                                iv_fill_data            = abap_true
                             IMPORTING
                                eo_message              = DATA(lo_message)
                                et_data                 = lt_root  ) .

      CATCH /bobf/cx_frw_contrct_violation.
    ENDTRY.

    IF lt_root IS NOT INITIAL.

      "Definição das chaves do ROOT
      "==============================
      DATA(lt_keys) = VALUE /bobf/t_frw_key( FOR ls_root IN lt_root ( key = ls_root-key ) ).

      "Obter remessas
      "========================
      lo_svc_mngr->retrieve_by_association( EXPORTING iv_node_key   = /scmtms/if_tor_c=>sc_node-root
                                                     it_key         = lt_keys
                                                     iv_association = /scmtms/if_tor_c=>sc_association-root-exec
                                                     iv_fill_data   = abap_true
                                           IMPORTING et_data        = lt_exec  ).

      TRY.

          DATA(lv_consigneeid) = lt_root[ 1 ]-consigneeid.

        CATCH cx_sy_itab_line_not_found.
      ENDTRY.


      ASSIGN lt_exec[ ext_loc_id = lv_consigneeid ] TO FIELD-SYMBOL(<fs_exec>). "#EC CI_SORTSEQ

      IF <fs_exec>-event_code = gc_entr_total or <fs_exec>-event_code = gc_entr_parc.

        ls_exec-torstopuuid = <fs_exec>-torstopuuid.
        ls_exec-actual_date = <fs_exec>-actual_date.
        ls_exec-event_code  = gc_dif.
        ls_exec-ext_loc_id  = lv_consigneeid.

      ELSE.

        lv_date = iv_doc_date + iv_preventr.

        CALL FUNCTION 'CONVERT_INTO_TIMESTAMP'
          EXPORTING
            i_datlo     = lv_date
            i_timlo     = lv_uzeit
          IMPORTING
            e_timestamp = lv_timestamp.

        ls_exec-actual_date = lv_timestamp.
        ls_exec-event_code  = gc_dif.
        ls_exec-ext_loc_id  = lv_consigneeid.

      ENDIF.


      DATA: lo_exec TYPE REF TO data.
      CREATE DATA lo_exec LIKE ls_exec.

      ASSIGN ('lo_exec->*') TO <fs_exec>.

      IF <fs_exec> IS ASSIGNED.

        <fs_exec> = ls_exec.

        DATA(lo_txn_mngr)   = /bobf/cl_tra_trans_mgr_factory=>get_transaction_manager( ).

        lo_svc_mngr->modify( EXPORTING it_modification = VALUE #( ( node           = /scmtms/if_tor_c=>sc_node-executioninformation
                                                                    change_mode    = /bobf/if_frw_c=>sc_modify_create
                                                                    source_node    = /scmtms/if_tor_c=>sc_node-root
                                                                    source_key     = lt_keys[ 1 ]-key
                                                                    association    = /scmtms/if_tor_c=>sc_association-root-exec
                                                                    data           =  lo_exec ) )
                               IMPORTING eo_change = DATA(lo_change)
                                         eo_message = DATA(lo_msg) ).

        " Salva valores modificados
        "=================================
        lo_txn_mngr->save( IMPORTING ev_rejected = lv_rejected
                                     eo_message  = lo_message2 ).

      ENDIF.
    ENDIF.

  ENDMETHOD.


  METHOD processa_merc_int.

    DATA: lt_remessa TYPE vbeln_vl_t.

    DATA(lt_data) = me->get_data_merc_int(  ).

    lt_remessa = VALUE #(  FOR ls_data IN lt_data ( ls_data-vbeln ) ).

    DATA(lt_unidfrete) = me->get_unid_frete(  it_remessa = lt_remessa ).

    LOOP AT lt_data ASSIGNING FIELD-SYMBOL(<fs_data>).

      TRY.
          DATA(ls_unid_frete) = lt_unidfrete[ remessa = <fs_data>-vbeln ]. "#EC CI_STDSEQ
          DATA(lv_preventr) = me->get_param( iv_chave1 = CONV #(  <fs_data>-bukrs )
                                             iv_chave2 = CONV #( <fs_data>-billtopartyregion )
                                             iv_chave3 = CONV #( <fs_data>-plantregion ) ).
          me->set_diferimento(  iv_unid_frete = ls_unid_frete-unid_frete
                                iv_preventr = lv_preventr
                                iv_doc_date = <fs_data>-billingdocumentdate ).

          APPEND <fs_data> TO rt_return.

        CATCH cx_sy_itab_line_not_found.
      ENDTRY.

    ENDLOOP.

  ENDMETHOD.


  METHOD get_param.

    DATA: lr_range TYPE RANGE OF i.

    DATA(lo_param) = zclca_tabela_parametros=>get_instance( ). " CHANGE - LSCHEPP - 20.07.2023

    TRY.
        lo_param->m_get_range( EXPORTING iv_modulo = me->gc_modulo "#EC CI_SROFC_NESTED
                                         iv_chave1 = iv_chave1
                                         iv_chave2 = iv_chave2
                                         iv_chave3 = iv_chave3
                               IMPORTING et_range  = lr_range ).

        TRY.
            rv_return = lr_range[ 1 ]-low.
          CATCH cx_sy_itab_line_not_found.
        ENDTRY.

      CATCH zcxca_tabela_parametros.
    ENDTRY.


  ENDMETHOD.
ENDCLASS.
