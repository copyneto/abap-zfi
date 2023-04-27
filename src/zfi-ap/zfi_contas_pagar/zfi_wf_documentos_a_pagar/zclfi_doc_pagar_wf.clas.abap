"!<p>Classe utilizada para fluxo de aprovação
"!<p><strong>Autor:</strong> Bruno Costa - Meta</p>
"!<p><strong>Data:</strong> 25/03/2022</p>
class ZCLFI_DOC_PAGAR_WF definition
  public
  final
  create public .

public section.

  interfaces BI_OBJECT .
  interfaces BI_PERSISTENT .
  interfaces IF_WORKFLOW .

  data GV_BELNR type BELNR_D read-only .
  data GV_BUKRS type BUKRS read-only .
  data GV_GJAHR type GJAHR read-only .
  data GV_BUZEI type BUZEI read-only .

    "! Evento para iniciar o fluxo de aprovação
  events START_WF
    exporting
      value(EV_BELNR) type BELNR_D
      value(EV_BUKRS) type BUKRS
      value(EV_GJAHR) type GJAHR
      value(EV_BUZEI) type BUZEI .

    "! Instancia a chave para o fluxo
  methods CONSTRUCTOR
    importing
      !IV_BELNR type BELNR_D
      !IV_BUKRS type BUKRS
      !IV_GJAHR type GJAHR
      !IV_BUZEI type BUZEI .
    "! Inicia o fluxo de aprovação
  methods TRIGGER_START_WF .
    "! Buscar os dados da movimentação
  methods GET_DATA
    importing
      !IV_BELNR type BELNR_D
      !IV_BUKRS type BUKRS
      !IV_GJAHR type GJAHR
      !IV_BUZEI type BUZEI optional
    exporting
      !ES_BKPF type BKPF
      !ES_BSEG type BSEG
      !ET_BSEG type BSEG_T
      !EV_BUTXT type BUTXT
      !ET_HTML type SWL_HTML_T
      !ET_URL type THCS_STRING
      !EV_URL type W3_HTML
      !EV_URL2 type W3_HTML
      !EV_URL3 type W3_HTML
      !EV_URL4 type W3_HTML .
    "! Busca aprovadores
  methods GET_APPROVERS
    importing
      !IV_BELNR type BELNR_D
      !IV_BUKRS type BUKRS
      !IV_GJAHR type GJAHR
      !IV_BUZEI type BUZEI
    exporting
      !ET_APPROVERS type ZCTGFI_APROVADORES
      !EV_TOTAL type CHAR02 .
  methods READ_CURRENT_APPROVER
    importing
      !IV_NIVEL type NUMC2
    exporting
      !ET_APPROVER type SWFUAGENTS
    changing
      !CT_APPROVERS type ZCTGFI_APROVADORES .
  methods PYMNTBLK_UPDATE
    importing
      !IV_BELNR type BELNR_D
      !IV_BUKRS type BUKRS
      !IV_GJAHR type GJAHR
      !IV_BUZEI type BUZEI
      !IV_ZLSPR type DZLSPR
      !IV_USER type WFSYST-AGENT optional .
  methods REVERSE_POSTING
    importing
      !IV_BUKRS type BUKRS
      !IV_GJAHR type GJAHR
      !IV_BELNR type BELNR_D
      !IV_STGRD type STGRD optional
      !IV_USER type WFSYST-AGENT optional .
  methods APPROVER_LEVEL
    changing
      !CV_NIVEL type NUM02 .
  methods READ_TEXT
    importing
      !IV_WI_ID type SWW_WIID
    exporting
      !ET_TEXT type TCHAR255 .
  methods GET_EMAIL
    importing
      !IT_APPROVERS type SWFUAGENTS
      !IV_USER type SWP_INITIA
    exporting
      !ET_MAIL type CRMTT_EMAIL_ADDRESS .
  methods LOG
    importing
      !IV_ACTION type CHAR01
      !IV_WF_ID type SWW_CHCKWI
      !IV_TASK_ID type SWW_WIID
      !IV_USER type WFSYST-AGENT optional
      !IT_APROVADORES type ZCTGFI_APROVADORES optional
      !IV_NIVEL type NUMC2 optional .
  PROTECTED SECTION.

private section.

  data GS_SIBFLPOR type SIBFLPOR .
  constants GC_FI type ZTCA_PARAM_VAL-MODULO value 'FI' ##NO_TEXT.
  constants GC_WF type ZTCA_PARAM_VAL-CHAVE1 value 'WF' ##NO_TEXT.
  constants GC_URL type ZTCA_PARAM_VAL-CHAVE2 value 'URL' ##NO_TEXT.
ENDCLASS.



CLASS ZCLFI_DOC_PAGAR_WF IMPLEMENTATION.


  METHOD approver_level.

    ADD 1 TO cv_nivel.

  ENDMETHOD.


  METHOD bi_object~default_attribute_value.
  ENDMETHOD.


  METHOD bi_object~execute_default_method.
  ENDMETHOD.


  METHOD bi_object~release.
  ENDMETHOD.


  METHOD bi_persistent~find_by_lpor.

    DATA: lv_belnr TYPE belnr_d,
          lv_bukrs TYPE bukrs,
          lv_gjahr TYPE gjahr,
          lv_buzei TYPE buzei.

    lv_belnr = lpor-instid(10).
    lv_bukrs = lpor-instid+10(4).
    lv_gjahr = lpor-instid+14(4).
    lv_buzei = lpor-instid+18(3).

    CREATE OBJECT result TYPE zclfi_doc_pagar_wf
      EXPORTING
        iv_belnr = lv_belnr
        iv_bukrs = lv_bukrs
        iv_gjahr = lv_gjahr
        iv_buzei = lv_buzei.

  ENDMETHOD.


  METHOD bi_persistent~lpor.

    me->gs_sibflpor-catid  = 'CL'.
    me->gs_sibflpor-typeid = 'ZCLFI_DOC_PAGAR_WF'.

    CONCATENATE me->gv_belnr me->gv_bukrs me->gv_gjahr me->gv_buzei INTO me->gs_sibflpor-instid.

    result = me->gs_sibflpor.

  ENDMETHOD.


  METHOD bi_persistent~refresh.
  ENDMETHOD.


  METHOD constructor.

    gv_belnr           = iv_belnr.
    gv_bukrs           = iv_bukrs.
    gv_gjahr           = iv_gjahr.
    gv_buzei           = iv_buzei.

    gs_sibflpor-catid  = 'CL'.
    gs_sibflpor-typeid = 'ZCLFI_DOC_PAGAR_WF'.

    CONCATENATE iv_belnr iv_bukrs iv_gjahr iv_buzei INTO gs_sibflpor-instid.

  ENDMETHOD.


  METHOD get_approvers.

    DATA: lr_id          TYPE RANGE OF hrobjid,
          lr_kostl       TYPE RANGE OF kostl,
          lv_bukrs       TYPE c,
          lv_blart       TYPE c,
          lv_bktxt       TYPE c,
          lv_kostl       TYPE c,
          lv_bukrs_valid TYPE c,
          lv_blart_valid TYPE c,
          lv_bktxt_valid TYPE c,
          lv_kostl_valid TYPE c.

    me->get_data(
      EXPORTING
        iv_belnr = iv_belnr
        iv_bukrs = iv_bukrs
        iv_gjahr = iv_gjahr
      IMPORTING
        es_bkpf  = DATA(ls_bkpf)
        et_bseg  = DATA(lt_bseg)
    ).

    SELECT b~respymgmtteamid, b~respymgmtteamtype, b~respymgmtteamcategory,
           c~respymgmtreferenceattribname, c~respymgmtattributelowvalue,
           a~respymgmtbusinesspartner,
           d~respymgmtfunction
      FROM i_respymgmtteammembertp AS a
      INNER JOIN i_respymgmtteamheadertp AS b
        ON b~respymgmtteamid EQ a~respymgmtteamid
      INNER JOIN i_respymgmtteamattributetp AS c
        ON b~respymgmtteamid EQ c~respymgmtteamid
      INNER JOIN i_respymgmtteammbrfunctp AS d
        ON d~respymgmtteamid EQ c~respymgmtteamid
       AND d~respymgmtbusinesspartner EQ a~respymgmtbusinesspartner
      INTO TABLE @DATA(lt_resp_att)
     WHERE b~respymgmtteamtype     EQ 'FGLVG'
       AND b~respymgmtteamcategory EQ 'FGJEV'.          "#EC CI_SEL_DEL

    IF sy-subrc EQ 0.

      SORT lt_bseg BY buzei.

      LOOP AT lt_bseg ASSIGNING FIELD-SYMBOL(<fs_bseg>).
        IF <fs_bseg>-koart = 'S' AND <fs_bseg>-shkzg = 'S'.
          APPEND VALUE #( sign = 'I' option = 'EQ' low = <fs_bseg>-kostl ) TO lr_kostl.
        ENDIF.
      ENDLOOP.

      DATA(lt_resp_id) = lt_resp_att[].
      SORT lt_resp_id BY respymgmtteamid.
      DELETE ADJACENT DUPLICATES FROM lt_resp_id COMPARING respymgmtteamid.

      DO.
        READ TABLE lt_resp_id ASSIGNING FIELD-SYMBOL(<fs_resp_id>) INDEX 1.
        IF sy-subrc EQ 0.


          CLEAR: lv_bukrs_valid, lv_blart_valid, lv_bktxt_valid, lv_kostl_valid.
          CLEAR: lv_bukrs, lv_blart, lv_bktxt, lv_kostl.

          LOOP AT lt_resp_att ASSIGNING FIELD-SYMBOL(<fs_resp_att>) "#EC CI_NESTED
            WHERE respymgmtteamid EQ <fs_resp_id>-respymgmtteamid. "#EC CI_STDSEQ

            CASE <fs_resp_att>-respymgmtreferenceattribname.
              WHEN 'JOURNALENTRYTYPE'.
                lv_blart_valid = abap_true.
                IF lv_blart IS INITIAL.
                  IF <fs_resp_att>-respymgmtattributelowvalue EQ ls_bkpf-blart.
                    lv_blart = abap_true.
                  ENDIF.
                ENDIF.
              WHEN 'COMPANY_CODE'.
                lv_bukrs_valid = abap_true.
                IF lv_bukrs IS INITIAL.
                  IF <fs_resp_att>-respymgmtattributelowvalue EQ ls_bkpf-bukrs.
                    lv_bukrs = abap_true.
                  ENDIF.
                ENDIF.
              WHEN 'Z_FI_BKTXT'.
                lv_bktxt_valid = abap_true.
                IF lv_bktxt IS INITIAL.
                  IF <fs_resp_att>-respymgmtattributelowvalue EQ ls_bkpf-bktxt.
                    lv_bktxt = abap_true.
                  ENDIF.
                ENDIF.
              WHEN 'COST_CENTER'.
                lv_kostl_valid = abap_true.
                IF NOT lr_kostl[] IS INITIAL.
                  IF lv_kostl IS INITIAL.
                    IF <fs_resp_att>-respymgmtattributelowvalue IN lr_kostl.
                      lv_kostl = abap_true.
                    ENDIF.
                  ENDIF.
                ENDIF.
            ENDCASE.

            IF NOT lr_kostl[] IS INITIAL.
*              lv_kostl_valid = abap_true.
            ENDIF.

            IF ( lv_bukrs_valid EQ abap_true AND lv_blart_valid EQ abap_true   AND
                 lv_bktxt_valid EQ abap_true AND lv_kostl_valid EQ abap_true ) AND
               ( lv_bukrs       EQ abap_true AND lv_blart       EQ abap_true   AND
                 lv_bktxt       EQ abap_true AND lv_kostl       EQ abap_true ) .

              APPEND VALUE #( sign = 'I' option = 'EQ' low = <fs_resp_att>-respymgmtteamid ) TO lr_id.

            ENDIF.

            IF ( lv_bukrs_valid EQ abap_true AND lv_blart_valid EQ abap_true    AND
                 lv_bktxt_valid EQ abap_true AND lv_kostl_valid EQ abap_false ) AND
               ( lv_bukrs       EQ abap_true AND lv_blart       EQ abap_true    AND
                 lv_bktxt       EQ abap_true ).

              APPEND VALUE #( sign = 'I' option = 'EQ' low = <fs_resp_att>-respymgmtteamid ) TO lr_id.

            ENDIF.

            IF ( lv_bukrs_valid EQ abap_true  AND lv_blart_valid EQ abap_true   AND
                 lv_bktxt_valid EQ abap_false AND lv_kostl_valid EQ abap_true ) AND
               ( lv_bukrs       EQ abap_true  AND lv_blart       EQ abap_true   AND
                 lv_kostl       EQ abap_true  ).

              APPEND VALUE #( sign = 'I' option = 'EQ' low = <fs_resp_att>-respymgmtteamid ) TO lr_id.

            ENDIF.

            IF ( lv_bukrs_valid EQ abap_true AND lv_blart_valid EQ abap_false  AND
                 lv_bktxt_valid EQ abap_true AND lv_kostl_valid EQ abap_true ) AND
               ( lv_bukrs       EQ abap_true AND
                 lv_bktxt       EQ abap_true AND lv_kostl       EQ abap_true ).

              APPEND VALUE #( sign = 'I' option = 'EQ' low = <fs_resp_att>-respymgmtteamid ) TO lr_id.

            ENDIF.

            IF ( lv_bukrs_valid EQ abap_false AND lv_blart_valid EQ abap_true AND
                 lv_bktxt_valid EQ abap_true AND lv_kostl_valid EQ abap_true ) AND
               ( lv_blart EQ abap_true  AND
                lv_bktxt EQ abap_true AND lv_kostl EQ abap_true ).

              APPEND VALUE #( sign = 'I' option = 'EQ' low = <fs_resp_att>-respymgmtteamid ) TO lr_id.

            ENDIF.

          ENDLOOP.

          DELETE lt_resp_id INDEX 1.

        ELSE.

          EXIT.

        ENDIF.

      ENDDO.

      IF NOT lr_id[] IS INITIAL.
        DELETE lt_resp_att WHERE respymgmtteamid NOT IN lr_id. "#EC CI_STDSEQ
      ELSE.
        FREE lt_resp_att.
      ENDIF.

      IF NOT lt_resp_att[] IS INITIAL.

        SELECT a~partner, a~type, a~idnumber, b~usrid
          FROM but0id AS a
          INNER JOIN pa0105 AS b
            ON b~pernr EQ a~idnumber
           AND b~endda GT @sy-datum
           AND b~begda LT @sy-datum
          INTO TABLE @DATA(lt_but0id)
          FOR ALL ENTRIES IN @lt_resp_att
         WHERE partner EQ @lt_resp_att-respymgmtbusinesspartner. "#EC CI_SEL_DEL

        IF sy-subrc EQ 0.

          DELETE lt_but0id WHERE usrid IS INITIAL.       "#EC CI_STDSEQ

          SORT lt_resp_att BY respymgmtbusinesspartner.
          DELETE ADJACENT DUPLICATES FROM lt_resp_att COMPARING respymgmtbusinesspartner.

          SORT lt_resp_att BY respymgmtteamid.

          LOOP AT lt_resp_att ASSIGNING <fs_resp_att>.

            READ TABLE lt_but0id ASSIGNING FIELD-SYMBOL(<fs_but0id>) WITH KEY partner = <fs_resp_att>-respymgmtbusinesspartner. "#EC CI_STDSEQ
            IF sy-subrc EQ 0.

              APPEND VALUE #( otype  = 'US'
                              objid  = <fs_but0id>-usrid
                              zlevel = <fs_resp_att>-respymgmtfunction+7  )
                         TO et_approvers.

            ENDIF.

          ENDLOOP.

          DELETE et_approvers WHERE objid EQ ls_bkpf-usnam.

          DATA(lt_approvers) = et_approvers[].
          SORT lt_approvers BY zlevel.
          DELETE ADJACENT DUPLICATES FROM lt_approvers COMPARING zlevel.
          DESCRIBE TABLE lt_approvers LINES ev_total.

        ENDIF.

      ENDIF.

    ENDIF.

  ENDMETHOD.


  METHOD get_data.

    DATA lv_url TYPE string.

    SELECT SINGLE *
             FROM bkpf
             INTO @es_bkpf
            WHERE bukrs EQ @iv_bukrs
              AND belnr EQ @iv_belnr
              AND gjahr EQ @iv_gjahr.

    IF sy-subrc EQ 0.

      IF iv_buzei IS NOT INITIAL.

        SELECT SINGLE *
          FROM bseg
          INTO @es_bseg
         WHERE bukrs EQ @iv_bukrs
           AND belnr EQ @iv_belnr
           AND gjahr EQ @iv_gjahr
           AND buzei EQ @iv_buzei.

      ELSE.

        SELECT *
          FROM bseg
          INTO TABLE @et_bseg
         WHERE bukrs EQ @iv_bukrs
           AND belnr EQ @iv_belnr
           AND gjahr EQ @iv_gjahr.
      ENDIF.

    ENDIF.

    SELECT SINGLE butxt
             FROM t001
             INTO @ev_butxt
            WHERE bukrs EQ @iv_bukrs.

    SELECT SINGLE low
             FROM ztca_param_val
             INTO @DATA(lv_low_url)
            WHERE modulo EQ @gc_fi
              AND chave1 EQ @gc_wf
              AND chave2 EQ @gc_url.

    IF sy-subrc EQ 0.

*    ev_url  = |https://fiori-dev.3coracoes.com.br/sap/bc/ui2/flp|.
      ev_url  = |https://{ lv_low_url }/sap/bc/ui2/flp|.
      ev_url2 = |?sap-client={ es_bkpf-mandt }&sap-language=PT#AccountingDocumen|.
      ev_url3 = |t-manage?AccountingDocument={ es_bkpf-belnr }&CompanyCod|.
      ev_url4 = |e={ es_bkpf-bukrs }&FiscalYear={ es_bkpf-gjahr }|.

    ENDIF.

  ENDMETHOD.


  METHOD pymntblk_update.

*    DATA: ls_bseg   TYPE bseg,
*          lt_buztab TYPE tpit_t_buztab,
*          lt_fldtab TYPE tpit_t_fname,
*          lt_errtab TYPE tpit_t_errdoc.
*
*    DATA: lv_wf TYPE char02.
*
*    lv_wf = abap_true.
*
*    EXPORT lv_wf FROM lv_wf TO MEMORY ID 'ZCLFI_DOC_PAGAR_WF'.
*
*    SELECT bukrs belnr gjahr buzei koart bschl
*    APPENDING CORRESPONDING FIELDS OF TABLE lt_buztab
*      FROM bseg
*     WHERE bukrs EQ iv_bukrs
*       AND belnr EQ iv_belnr
*       AND gjahr EQ iv_gjahr
*       AND buzei EQ iv_buzei.
*
*    ls_bseg-zlspr = iv_zlspr.
*
*    APPEND INITIAL LINE TO lt_fldtab ASSIGNING FIELD-SYMBOL(<fs_fldtab>).
*    <fs_fldtab>-fname = 'ZLSPR'.
*
*    IF NOT lt_buztab[] IS INITIAL.
*
*      CALL FUNCTION 'FI_ITEMS_MASS_CHANGE'
*        EXPORTING
*          s_bseg     = ls_bseg
*        IMPORTING
*          errtab     = lt_errtab[]
*        TABLES
*          it_buztab  = lt_buztab
*          it_fldtab  = lt_fldtab
*        EXCEPTIONS
*          bdc_errors = 1
*          OTHERS     = 2.
*
*      IF sy-subrc EQ 0.
*
*        CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
*          EXPORTING
*            wait = 'X'.
*
*      ENDIF.
*
*    ENDIF.

    DATA: lv_jobname  TYPE tbtcjob-jobname,
          lv_jobcount TYPE tbtcjob-jobcount,
          lv_user     TYPE syuname.

    lv_jobname = |{ iv_belnr }{ iv_bukrs }{ iv_gjahr }|.

    CALL FUNCTION 'JOB_OPEN'
      EXPORTING
        jobname          = lv_jobname
      IMPORTING
        jobcount         = lv_jobcount
      EXCEPTIONS
        cant_create_job  = 1
        invalid_job_data = 2
        jobname_missing  = 3
        OTHERS           = 4.

    IF sy-subrc <> 0.
      MESSAGE e028(zes_job) WITH sy-subrc.
    ENDIF.

    lv_user = iv_user+2.

    SUBMIT zfir_doc_pagar_wf AND RETURN
           USER lv_user VIA JOB lv_jobname NUMBER lv_jobcount
           WITH p_belnr = iv_belnr
           WITH p_bukrs = iv_bukrs
           WITH p_gjahr = iv_gjahr
           WITH p_buzei = iv_buzei
           WITH p_zlspr = iv_zlspr
           WITH p_pymnt = abap_true.

    CALL FUNCTION 'JOB_CLOSE'
      EXPORTING
        jobcount             = lv_jobcount
        jobname              = lv_jobname
        strtimmed            = 'X'
      EXCEPTIONS
        cant_start_immediate = 1
        invalid_startdate    = 2
        jobname_missing      = 3
        job_close_failed     = 4
        job_nosteps          = 5
        job_notex            = 6
        lock_failed          = 7
        OTHERS               = 8.

    IF sy-subrc <> 0.
      MESSAGE e029(zes_job) WITH sy-subrc.
    ENDIF.

  ENDMETHOD.


  METHOD read_current_approver.

    LOOP AT ct_approvers ASSIGNING FIELD-SYMBOL(<fs_approvers>).

      IF <fs_approvers>-zlevel EQ iv_nivel.

        APPEND VALUE #( otype  = <fs_approvers>-otype
                                  objid  = <fs_approvers>-objid )
                   TO et_approver.

      ENDIF.

    ENDLOOP.

  ENDMETHOD.


  METHOD reverse_posting.

*    CALL FUNCTION 'CALL_FB08'
*      EXPORTING
*        i_bukrs      = iv_bukrs
*        i_belnr      = iv_belnr
*        i_gjahr      = iv_gjahr
*        i_stgrd      = iv_stgrd
*      EXCEPTIONS
*        not_possible = 1
*        OTHERS       = 2.
*
*    IF sy-subrc EQ 0.
*
*      CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
**       EXPORTING
**         WAIT          =
**       IMPORTING
**         RETURN        =
*        .
*
*    ENDIF.

    DATA: lv_jobname  TYPE tbtcjob-jobname,
          lv_jobcount TYPE tbtcjob-jobcount,
          lv_user     TYPE syuname.

    lv_jobname = |{ iv_belnr }{ iv_bukrs }{ iv_gjahr }|.

    CALL FUNCTION 'JOB_OPEN'
      EXPORTING
        jobname          = lv_jobname
      IMPORTING
        jobcount         = lv_jobcount
      EXCEPTIONS
        cant_create_job  = 1
        invalid_job_data = 2
        jobname_missing  = 3
        OTHERS           = 4.

    IF sy-subrc <> 0.
      MESSAGE e028(zes_job) WITH sy-subrc.
    ENDIF.

    lv_user = iv_user+2.

    SUBMIT zfir_doc_pagar_wf AND RETURN
           USER lv_user VIA JOB lv_jobname NUMBER lv_jobcount
           WITH p_belnr = iv_belnr
           WITH p_bukrs = iv_bukrs
           WITH p_gjahr = iv_gjahr
           WITH p_stgrd = iv_stgrd
           WITH p_rever = abap_true.

    CALL FUNCTION 'JOB_CLOSE'
      EXPORTING
        jobcount             = lv_jobcount
        jobname              = lv_jobname
        strtimmed            = 'X'
      EXCEPTIONS
        cant_start_immediate = 1
        invalid_startdate    = 2
        jobname_missing      = 3
        job_close_failed     = 4
        job_nosteps          = 5
        job_notex            = 6
        lock_failed          = 7
        OTHERS               = 8.

    IF sy-subrc <> 0.
      MESSAGE e029(zes_job) WITH sy-subrc.
    ENDIF.

  ENDMETHOD.


  METHOD trigger_start_wf.

    TRY .

        CALL METHOD cl_swf_evt_event=>raise
          EXPORTING
            im_objcateg = gs_sibflpor-catid
            im_objtype  = gs_sibflpor-typeid
            im_event    = 'START_WF'
            im_objkey   = gs_sibflpor-instid.

*        COMMIT WORK.

      CATCH cx_swf_evt_invalid_objtype. " Error in Class / Object Type

      CATCH cx_swf_evt_invalid_event.   " Error in Event

    ENDTRY.

  ENDMETHOD.


  METHOD get_email.

    DATA: ls_address TYPE bapiaddr3,
          lt_return  TYPE TABLE OF bapiret2.

    LOOP AT it_approvers ASSIGNING FIELD-SYMBOL(<fs_approvers>).

      CALL FUNCTION 'BAPI_USER_GET_DETAIL'
        EXPORTING
          username = <fs_approvers>-objid
        IMPORTING
          address  = ls_address
        TABLES
          return   = lt_return.

      IF NOT ls_address-e_mail IS INITIAL.
        APPEND ls_address-e_mail TO et_mail.
      ENDIF.

    ENDLOOP.

    IF NOT iv_user IS INITIAL.

      CALL FUNCTION 'BAPI_USER_GET_DETAIL'
        EXPORTING
          username = iv_user+2
        IMPORTING
          address  = ls_address
        TABLES
          return   = lt_return.

      IF NOT ls_address-e_mail IS INITIAL.
        APPEND ls_address-e_mail TO et_mail.
      ENDIF.

    ENDIF.

  ENDMETHOD.


  METHOD read_text.

    DATA: lv_predecessor_wi           TYPE sww_wiid,
          lv_return_code              LIKE sy-subrc,
          lv_ifs_xml_container        TYPE xstring,
          lv_ifs_xml_container_schema TYPE xstring,
          lt_simple_container         TYPE TABLE OF swr_cont,
          lt_message_lines            TYPE TABLE OF swr_messag,
          lt_message_struct           TYPE TABLE OF swr_mstruc,
          lt_subcontainer_bor_objects TYPE TABLE OF swr_cont,
          lt_subcontainer_all_objects TYPE TABLE OF swr_cont,
          lv_no_att                   TYPE sy-index,
          lv_wa_reason                TYPE swr_cont,
          lv_document_id              TYPE sofolenti1-doc_id,
          lt_object_content           TYPE TABLE OF solisti1,
          lv_reason_txt               TYPE swcont-value,
          lt_reason_txt               TYPE tchar255.

    CALL FUNCTION 'SAP_WAPI_READ_CONTAINER'
      EXPORTING
        workitem_id              = iv_wi_id
        language                 = sy-langu
        user                     = sy-uname
      IMPORTING
        return_code              = lv_return_code
        ifs_xml_container        = lv_ifs_xml_container
        ifs_xml_container_schema = lv_ifs_xml_container_schema
      TABLES
        simple_container         = lt_simple_container
        message_lines            = lt_message_lines
        message_struct           = lt_message_struct
        subcontainer_bor_objects = lt_subcontainer_bor_objects
        subcontainer_all_objects = lt_subcontainer_all_objects.

    lv_no_att = 0.

    DELETE lt_subcontainer_all_objects WHERE element NE '_ATTACH_OBJECTS'. "#EC CI_STDSEQ

    LOOP AT lt_subcontainer_all_objects ASSIGNING FIELD-SYMBOL(<fs_reason>).
      lv_no_att      = lv_no_att + 1.
      lv_document_id = <fs_reason>-value.
    ENDLOOP.

    CHECK lv_document_id IS NOT INITIAL.

    CALL FUNCTION 'SO_DOCUMENT_READ_API1'
      EXPORTING
        document_id    = lv_document_id
      TABLES
        object_content = lt_object_content.

    LOOP AT lt_object_content ASSIGNING FIELD-SYMBOL(<fs_reason_txt>).
      SPLIT <fs_reason_txt> AT cl_abap_char_utilities=>newline INTO TABLE et_text.
    ENDLOOP.

  ENDMETHOD.


  METHOD log.

    DATA: lt_log TYPE TABLE OF ztfi_wf_log.

    CASE iv_action.
      WHEN 'N'. "New

        TRY.
            DATA(lv_uuid) = cl_system_uuid=>create_uuid_x16_static( ).
          CATCH cx_uuid_error.
        ENDTRY.

        DATA(lt_approvers) = it_aprovadores[].

        DELETE lt_approvers WHERE zlevel NE iv_nivel.

        LOOP AT lt_approvers ASSIGNING FIELD-SYMBOL(<fs_approvers>).
          APPEND INITIAL LINE TO lt_log ASSIGNING FIELD-SYMBOL(<fs_log>).
          <fs_log>-uuid             = lv_uuid.
          <fs_log>-wf_id            = iv_wf_id.
          <fs_log>-task_id          = iv_task_id.
          <fs_log>-nivel_aprovacao  = <fs_approvers>-zlevel.
          <fs_log>-aprovador        = <fs_approvers>-objid.
          <fs_log>-data             = sy-datum.
          <fs_log>-hora             = sy-uzeit.
          <fs_log>-empresa          = gv_bukrs.
          <fs_log>-documento        = gv_belnr.
          <fs_log>-exercicio        = gv_gjahr.
          <fs_log>-item             = gv_buzei.
          <fs_log>-status_aprovacao = '2'.
        ENDLOOP.

      WHEN OTHERS.

*        SELECT *
*          FROM ztfi_wf_log
*          INTO TABLE lt_log
*         WHERE wf_id   EQ iv_wf_id
*           AND task_id EQ iv_task_id.
*
*        IF sy-subrc EQ 0.
*
*          LOOP AT lt_log ASSIGNING <fs_log>.
*
*            IF iv_action EQ 'A'. "Aprovado
*              <fs_log>-status_aprovacao = COND #( WHEN <fs_log>-aprovador EQ iv_user
*                                                  THEN '1'
*                                                  ELSE '3' ).
*            ELSEIF iv_action EQ 'R'. "Rejeitado
*              <fs_log>-status_aprovacao = '4'.
*            ELSEIF iv_action EQ 'E'. "Rejeitado com Estorno
*              <fs_log>-status_aprovacao = '5'.
*            ENDIF.
*
*          ENDLOOP.
*
*        ENDIF.

    ENDCASE.

    MODIFY ztfi_wf_log FROM TABLE lt_log.

  ENDMETHOD.
ENDCLASS.
