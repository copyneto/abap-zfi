*&---------------------------------------------------------------------*
*& Include zfii_fill_zlspr
*&---------------------------------------------------------------------*

CHECK sy-tcode EQ 'FB60' OR sy-tcode EQ 'FBA6'.

SELECT b~respymgmtteamid, b~respymgmtteamtype, b~respymgmtteamcategory,
       a~respymgmtreferenceattribname, a~respymgmtattributelowvalue
  FROM i_respymgmtteamattributetp AS a
  INNER JOIN i_respymgmtteamheadertp AS b
    ON b~respymgmtteamid EQ a~respymgmtteamid
  INTO TABLE @DATA(lt_resp_att)
 WHERE b~respymgmtteamtype     EQ 'FGLVG'
   AND b~respymgmtteamcategory EQ 'FGJEV'.

IF sy-subrc EQ 0.

  TRY.
      DATA(lv_journalentrytype) = lt_resp_att[ respymgmtreferenceattribname = 'JOURNALENTRYTYPE' ]-respymgmtattributelowvalue.
      DATA(lv_company_code)     = lt_resp_att[ respymgmtreferenceattribname = 'COMPANY_CODE' ]-respymgmtattributelowvalue.
      DATA(lv_cost_center)      = lt_resp_att[ respymgmtreferenceattribname = 'COST_CENTER' ]-respymgmtattributelowvalue.
      DATA(lv_z_fi_bktxt)       = lt_resp_att[ respymgmtreferenceattribname = 'Z_FI_BKTXT' ]-respymgmtattributelowvalue.
    CATCH cx_sy_itab_line_not_found INTO DATA(lr_exp).

  ENDTRY.

  IF bkpf-blart EQ lv_journalentrytype AND bkpf-bukrs EQ lv_company_code AND
     bkpf-bktxt EQ lv_z_fi_bktxt       AND bseg-kostl EQ lv_cost_center.
    bseg-zlspr = 'A'.
  ENDIF.

ENDIF.
