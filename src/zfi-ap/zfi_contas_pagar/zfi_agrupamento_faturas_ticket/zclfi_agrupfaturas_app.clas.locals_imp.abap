CLASS lcl_arquivo DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS selFaturas FOR MODIFY
      IMPORTING keys FOR ACTION Arquivo~selFaturas RESULT result.

    METHODS agrupaFaturas FOR MODIFY
      IMPORTING keys FOR ACTION Arquivo~agrupaFaturas RESULT result.

    METHODS getFeatures FOR FEATURES
      IMPORTING keys REQUEST requested_features FOR Arquivo RESULT result.

ENDCLASS.

CLASS lcl_arquivo IMPLEMENTATION.

  METHOD selFaturas.

    DATA: lt_agrupfaturas TYPE STANDARD TABLE OF zi_fi_agrupafaturas.

    DATA(lt_keys) = keys.

    READ ENTITIES OF zi_fi_agrupafaturas IN LOCAL MODE
        ENTITY Arquivo
        ALL FIELDS WITH CORRESPONDING #( keys )
        RESULT DATA(lt_arquivo_entity).

    lt_agrupfaturas = CORRESPONDING #( lt_arquivo_entity ).

    DATA(lo_busca) = NEW zclfi_busca_faturas( lt_agrupfaturas ).

    reported-linhas = VALUE #( FOR ls_key IN keys
                                     FOR ls_mensagem IN lo_busca->execute( "iv_id_linha_arq = ls_key-IdArquivo
                                                                           is_busca = ls_key-%param )
                                     ( %tky = VALUE #( id        = ls_key-idarquivo )
                                       %msg = new_message(
                                                           id       = ls_mensagem-id
                                                           number   = ls_mensagem-number
                                                           severity = CONV #( ls_mensagem-type )
                                                           v1       = ls_mensagem-message_v1
                                                           v2       = ls_mensagem-message_v2
                                                           v3       = ls_mensagem-message_v3
                                                           v4       = ls_mensagem-message_v4  ) ) ).


    READ ENTITIES OF zi_fi_agrupafaturas IN LOCAL MODE
        ENTITY Arquivo
        ALL FIELDS WITH CORRESPONDING #( keys )
        RESULT lt_arquivo_entity.

    result = VALUE #( FOR ls_arquivo IN lt_arquivo_entity ( %tky = ls_arquivo-%tky
    %param = ls_arquivo )
    ).


  ENDMETHOD.

  METHOD agrupaFaturas.


    DATA:
      lt_dados_arq TYPE STANDARD TABLE OF zi_fi_agrupafaturas WITH DEFAULT KEY.


    READ ENTITIES OF zi_fi_agrupafaturas IN LOCAL MODE
        ENTITY Arquivo
        ALL FIELDS WITH CORRESPONDING #( keys )
        RESULT DATA(lt_arquivo_entity).

    lt_dados_arq = CORRESPONDING #( lt_arquivo_entity ).

    DATA(lo_agrupa) = NEW zclfi_agrupa_faturas( lt_dados_arq ).

    reported-linhas = VALUE #( FOR ls_key IN keys
                                      FOR ls_mensagem IN lo_agrupa->execute( is_campos_popup = ls_key-%param )
                                     ( %tky = VALUE #( IdArquivo = ls_key-idarquivo )
                                       %msg = new_message(
                                                           id       = ls_mensagem-id
                                                           number   = ls_mensagem-number
                                                           severity = CONV #( ls_mensagem-type )
                                                           v1       = ls_mensagem-message_v1
                                                           v2       = ls_mensagem-message_v2
                                                           v3       = ls_mensagem-message_v3
                                                           v4       = ls_mensagem-message_v4  ) ) ).

    READ ENTITIES OF zi_fi_agrupafaturas IN LOCAL MODE
        ENTITY Arquivo
        ALL FIELDS WITH CORRESPONDING #( keys )
        RESULT lt_arquivo_entity.

    result = VALUE #( FOR ls_arquivo IN lt_arquivo_entity ( %tky = ls_arquivo-%tky
    %param = ls_arquivo )
    ).


  ENDMETHOD.

  METHOD getfeatures.


    READ ENTITIES OF zi_fi_agrupafaturas IN LOCAL MODE
        ENTITY Arquivo
        ALL FIELDS WITH CORRESPONDING #( keys )
        RESULT DATA(lt_arquivo_entity).

    result = VALUE #( FOR ls_arquivo IN lt_arquivo_entity
             ( %key                          = ls_arquivo-%key

               %features-%action-selfaturas = SWITCH #( ls_arquivo-statusprocessamento
                                                        WHEN zclfi_busca_faturas=>gc_status_arq-disponivel
                                                             OR zclfi_busca_faturas=>gc_status_arq-agrupado
                                                           THEN if_abap_behv=>fc-o-disabled
                                                           ELSE if_abap_behv=>fc-o-enabled )

               %features-%action-agrupafaturas = SWITCH #( ls_arquivo-statusprocessamento
                                                            WHEN zclfi_busca_faturas=>gc_status_arq-pendente
                                                                OR zclfi_busca_faturas=>gc_status_arq-nao_processavel
                                                                OR zclfi_busca_faturas=>gc_status_arq-agrupado
                                                              THEN if_abap_behv=>fc-o-disabled
                                                              ELSE if_abap_behv=>fc-o-enabled )

              ) ).


  ENDMETHOD.

ENDCLASS.
