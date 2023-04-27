class ZCLFI_CONC_CRED_UPLOAD definition
  public
  final
  create public .

public section.

  types:
    BEGIN OF ty_estrutura_cliente,
             cliente TYPE c LENGTH 10,
           END OF ty_estrutura_cliente .

  data:
    gt_clientes TYPE TABLE OF ty_estrutura_cliente .

  methods CARGA
    importing
      !IV_MEDIA_RESOURCE_VALUE type XSTRING optional
      !IV_NOME_ARQ type RSFILENM optional .
protected section.
private section.
ENDCLASS.



CLASS ZCLFI_CONC_CRED_UPLOAD IMPLEMENTATION.


  METHOD CARGA.

    NEW zclpp_preenche_tabelas( )->converte_xstring_para_it(
    EXPORTING
      iv_nome_arq = iv_nome_arq
      iv_xstring  = iv_media_resource_value
    CHANGING
      ct_tabela   = me->gt_clientes ).

    LOOP AT  me->gt_clientes ASSIGNING FIELD-SYMBOL(<fs_clientes>).
      IF <fs_clientes>-cliente IS INITIAL.
        DELETE me->gt_clientes INDEX sy-tabix.
      ENDIF.
    ENDLOOP.

    IF me->gt_clientes IS INITIAL.
      RETURN.
    ENDIF.

    DATA lt_dados_upload TYPE TABLE OF ztfi_exc_cli WITH DEFAULT KEY.

    LOOP AT me->gt_clientes ASSIGNING <fs_clientes>.
      APPEND VALUE #( kunnr = |{ <fs_clientes>-cliente ALPHA = IN }| ) TO lt_dados_upload.
    ENDLOOP.

    SORT lt_dados_upload BY kunnr.

    SELECT kunnr FROM ztfi_exc_cli
      FOR ALL ENTRIES IN @lt_dados_upload
      WHERE kunnr = @lt_dados_upload-kunnr
      INTO TABLE @DATA(lt_exc_cli).

    IF sy-subrc IS INITIAL.
      SORT lt_dados_upload BY kunnr.
    ENDIF.

    IF lines( lt_exc_cli ) = lines( lt_dados_upload ).
      RETURN.
    ENDIF.

    LOOP AT lt_exc_cli ASSIGNING FIELD-SYMBOL(<fs_exc_cli>).

      READ TABLE lt_dados_upload ASSIGNING FIELD-SYMBOL(<fs_dados_upload>)
      WITH KEY kunnr = <fs_exc_cli>-kunnr
      BINARY SEARCH.

      IF sy-subrc IS INITIAL.
        DELETE lt_dados_upload INDEX sy-tabix.
      ENDIF.

    ENDLOOP.

    IF lt_dados_upload[] IS NOT INITIAL.
      INSERT ztfi_exc_cli FROM TABLE lt_dados_upload.
    ENDIF.

  ENDMETHOD.
ENDCLASS.
