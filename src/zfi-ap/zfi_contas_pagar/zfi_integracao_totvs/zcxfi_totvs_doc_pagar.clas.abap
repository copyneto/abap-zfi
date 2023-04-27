CLASS ZCXFI_TOTVS_DOC_PAGAR DEFINITION
  PUBLIC
  INHERITING FROM cx_static_check
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_t100_dyn_msg .
    INTERFACES if_t100_message .

    CONSTANTS:
      BEGIN OF gc_cxFI_TOTVS_DOC_PAGAR,
        msgid TYPE symsgid VALUE 'ZFI_TOTVS_DOC_PAGAR',
        msgno TYPE symsgno VALUE '000',
        attr1 TYPE scx_attrname VALUE 'GV_MSGV1',
        attr2 TYPE scx_attrname VALUE 'GV_MSGV2',
        attr3 TYPE scx_attrname VALUE 'GV_MSGV3',
        attr4 TYPE scx_attrname VALUE 'GV_MSGV4',
      END OF gc_cxFI_TOTVS_DOC_PAGAR .
    CONSTANTS:
      BEGIN OF gc_cxvalidacao_dados,
        msgid TYPE symsgid VALUE 'ZFI_TOTVS_DOC_PAGAR',
        msgno TYPE symsgno VALUE '001',
        attr1 TYPE scx_attrname VALUE '',
        attr2 TYPE scx_attrname VALUE '',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF gc_cxvalidacao_dados .
    CONSTANTS:
      BEGIN OF gc_cxcentro_custo_nao_existe,
        msgid TYPE symsgid VALUE 'ZFI_TOTVS_DOC_PAGAR',
        msgno TYPE symsgno VALUE '002',
        attr1 TYPE scx_attrname VALUE 'GV_MSGV1',
        attr2 TYPE scx_attrname VALUE '',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF gc_cxcentro_custo_nao_existe .
    CONSTANTS:
      BEGIN OF gc_cxfilial_nao_existe,
        msgid TYPE symsgid VALUE 'ZFI_TOTVS_DOC_PAGAR',
        msgno TYPE symsgno VALUE '003',
        attr1 TYPE scx_attrname VALUE 'GV_MSGV1',
        attr2 TYPE scx_attrname VALUE '',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF gc_cxfilial_nao_existe .
    CONSTANTS:
      BEGIN OF gc_cxcnpj_nao_existe,
        msgid TYPE symsgid VALUE 'ZFI_TOTVS_DOC_PAGAR',
        msgno TYPE symsgno VALUE '004',
        attr1 TYPE scx_attrname VALUE 'GV_MSGV1',
        attr2 TYPE scx_attrname VALUE '',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF gc_cxcnpj_nao_existe .
    CONSTANTS:
      BEGIN OF gc_cxconta_razao_nao_existe,
        msgid TYPE symsgid VALUE 'ZFI_TOTVS_DOC_PAGAR',
        msgno TYPE symsgno VALUE '005',
        attr1 TYPE scx_attrname VALUE 'GV_MSGV1',
        attr2 TYPE scx_attrname VALUE 'GV_MSGV2',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF gc_cxconta_razao_nao_existe .
    CONSTANTS:
      BEGIN OF gc_cxdocument_post_erro,
        msgid TYPE symsgid VALUE 'ZFI_TOTVS_DOC_PAGAR',
        msgno TYPE symsgno VALUE '006',
        attr1 TYPE scx_attrname VALUE '',
        attr2 TYPE scx_attrname VALUE '',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF gc_cxdocument_post_erro .
    CONSTANTS:
      BEGIN OF gc_cxconta_razao_nao_informada,
        msgid TYPE symsgid VALUE 'ZFI_TOTVS_DOC_PAGAR',
        msgno TYPE symsgno VALUE '007',
        attr1 TYPE scx_attrname VALUE 'GV_MSGV1',
        attr2 TYPE scx_attrname VALUE '',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF gc_cxconta_razao_nao_informada .
    DATA gv_msgv1 TYPE msgv1 .
    DATA gv_msgv2 TYPE msgv2 .
    DATA gv_msgv3 TYPE msgv3 .
    DATA gv_msgv4 TYPE msgv4 .
    DATA gt_bapiret2 TYPE bapiret2_tab .

    METHODS constructor
      IMPORTING
        !iv_textid   LIKE if_t100_message=>t100key OPTIONAL
        !iv_previous LIKE previous OPTIONAL
        !iv_msgv1    TYPE msgv1 OPTIONAL
        !iv_msgv2    TYPE msgv2 OPTIONAL
        !iv_msgv3    TYPE msgv3 OPTIONAL
        !iv_msgv4    TYPE msgv4 OPTIONAL
        !it_bapiret2 TYPE bapiret2_tab OPTIONAL .
    METHODS get_bapiretreturn
      RETURNING
        VALUE(rt_bapiret2) TYPE bapiret2_tab .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCXFI_TOTVS_DOC_PAGAR IMPLEMENTATION.


  METHOD constructor ##ADT_SUPPRESS_GENERATION.
    CALL METHOD super->constructor
      EXPORTING
        previous = previous.
    me->gv_msgv1 = iv_msgv1 .
    me->gv_msgv2 = iv_msgv2 .
    me->gv_msgv3 = iv_msgv3 .
    me->gv_msgv4 = iv_msgv4 .
    me->gt_bapiret2 = it_bapiret2 .
    CLEAR me->textid.
    IF iv_textid IS INITIAL.
      if_t100_message~t100key = gc_cxFI_TOTVS_DOC_PAGAR .
    ELSE.
      if_t100_message~t100key = iv_textid.
    ENDIF.
  ENDMETHOD.


  METHOD get_bapiretreturn.
    IF if_t100_message~t100key-msgid IS NOT INITIAL.
      APPEND INITIAL LINE TO rt_bapiret2 ASSIGNING FIELD-SYMBOL(<fs_s_bapiret2>).

      <fs_s_bapiret2>-id         = if_t100_message~t100key-msgid.
      <fs_s_bapiret2>-number     = if_t100_message~t100key-msgno.
      <fs_s_bapiret2>-type       = 'E'.
      <fs_s_bapiret2>-message_v1 = gv_msgv1.
      <fs_s_bapiret2>-message_v2 = gv_msgv2.
      <fs_s_bapiret2>-message_v3 = gv_msgv3.
      <fs_s_bapiret2>-message_v4 = gv_msgv4.
    ENDIF.

    LOOP AT gt_bapiret2 ASSIGNING FIELD-SYMBOL(<fs_bapiret2>).
      APPEND INITIAL LINE TO rt_bapiret2 ASSIGNING <fs_s_bapiret2>.

      MOVE-CORRESPONDING <fs_bapiret2> TO <fs_s_bapiret2>.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
