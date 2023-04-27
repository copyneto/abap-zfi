FUNCTION zfmfi_replicar_aprov.
*"----------------------------------------------------------------------
*"*"Interface local:
*"  IMPORTING
*"     VALUE(IS_APROV) TYPE  ZTFI_CAD_APROVAD
*"     VALUE(IV_BUKRS) TYPE  BUKRS
*"  EXPORTING
*"     VALUE(ET_RETURN) TYPE  BAPIRET2_T
*"----------------------------------------------------------------------

  DATA: ls_aprov TYPE ztfi_cad_aprovad.

  SELECT bukrs, branch
    FROM j_1bbranch
    INTO TABLE @DATA(lt_local)
    WHERE bukrs = @iv_bukrs.

  IF sy-subrc = 0.

    LOOP AT lt_local ASSIGNING FIELD-SYMBOL(<fs_local>).

      CLEAR: ls_aprov.

      SELECT COUNT(*)
        FROM ztfi_cad_aprovad
        WHERE bukrs = <fs_local>-bukrs
           AND branch = <fs_local>-branch
           AND nivel = is_aprov-nivel
           AND bname = is_aprov-bname.

      IF sy-subrc <> 0.

        MOVE-CORRESPONDING is_aprov TO ls_aprov.
        ls_aprov-bukrs = <fs_local>-bukrs.
        ls_aprov-branch = <fs_local>-branch.
        ls_aprov-created_by = sy-uname.

        GET TIME STAMP FIELD ls_aprov-created_at.


        MODIFY ztfi_cad_aprovad FROM ls_aprov.
        IF sy-subrc = 0.
          COMMIT WORK AND WAIT.
        ENDIF.

      ENDIF.

    ENDLOOP.

  ENDIF.

ENDFUNCTION.
