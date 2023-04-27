FUNCTION zfmfi_atualiza_dados_tm.
*"----------------------------------------------------------------------
*"*"Interface local:
*"  IMPORTING
*"     VALUE(IV_UNID_FRETE) TYPE  VBELN
*"     VALUE(IV_PREVENTR) TYPE  INT1
*"     VALUE(IV_DOC_DATE) TYPE  DATUM
*"----------------------------------------------------------------------
  CONSTANTS: lc_option   TYPE char2 VALUE 'EQ',
             lc_sign     TYPE char2 VALUE 'I',
             lc_entr_total TYPE /scmtms/tor_event VALUE 'ENTREGA_TOTAL',
             lc_entr_parcial TYPE /scmtms/tor_event VALUE 'ENTREGA_PARCIAL',
             lc_entr_cli TYPE /scmtms/tor_event VALUE 'ENTREGUE_NO_CLIENTE',
             lc_dif      TYPE /scmtms/tor_event VALUE 'DIFERIMENTO'.

  DATA: ls_selpar TYPE /bobf/s_frw_query_selparam,
        lt_selpar TYPE /bobf/t_frw_query_selparam.

  DATA: lt_root TYPE /scmtms/t_tor_root_k,
        lt_exec TYPE /scmtms/t_tor_exec_k,
        ls_exec TYPE /scmtms/s_tor_exec_k,
        lt_exec_a type TABLE of /scmtms/s_tor_exec_k.

  DATA: lo_message2  TYPE REF TO /bobf/if_frw_message,
        lv_rejected  TYPE boole_d,
        lv_date_char TYPE string,
        lv_date      TYPE datum,
        lv_uzeit     TYPE uzeit,
        lv_date_aux      TYPE datum,
        lv_timestamp TYPE tzonref-tstamps,
        lv_covert    type char14.

  DATA(lo_svc_mngr) = /bobf/cl_tra_serv_mgr_factory=>get_service_manager( /scmtms/if_tor_c=>sc_bo_key ).
  DATA(lo_message_container) = /bobf/cl_frw_factory=>get_message( ).

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

    lt_exec_a = lt_exec.
    sort lt_exec_a by actual_date DESCENDING.

    loop at lt_exec_a ASSIGNING FIELD-SYMBOL(<fs_exec>).
    if <fs_exec>-event_code = lc_entr_total or <fs_exec>-event_code = lc_entr_parcial.
          ls_exec-torstopuuid = <fs_exec>-torstopuuid.
      ls_exec-actual_date = <fs_exec>-actual_date.
      ls_exec-event_code  = lc_dif.
      ls_exec-ext_loc_id  = lv_consigneeid.
      data(lv_achou) = abap_true.
      exit.
    endif.
    ENDLOOP.

    if lv_achou = abap_false.

      lv_date = iv_doc_date + iv_preventr.

      CALL FUNCTION 'CONVERT_INTO_TIMESTAMP'
        EXPORTING
          i_datlo     = lv_date
          i_timlo     = lv_uzeit
        IMPORTING
          e_timestamp = lv_timestamp.

      ls_exec-actual_date = lv_timestamp.
      ls_exec-event_code  = lc_dif.
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
                             IMPORTING eo_change  = DATA(lo_change)
                                       eo_message = DATA(lo_msg) ).

      " Salva valores modificados
      "=================================
      lo_txn_mngr->save( IMPORTING ev_rejected = lv_rejected
                                   eo_message  = lo_message2 ).

*      IF lv_rejected = abap_true.
*        lo_message_container->add( lo_message2 ).
*
*        lo_message_container->get_messages( IMPORTING et_message = DATA(lt_message) ).
*
*      ENDIF.

    ENDIF.
  ENDIF.

ENDFUNCTION.
