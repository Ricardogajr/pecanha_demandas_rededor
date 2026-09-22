/*/{Protheus.doc} F0703307
    PE MT103TRV executado no MATA103 - Desliga Lock de tabelas
    @author CDE-Private
    @since 25/01/2018
    /*/
User Function F0703307

    Local aRet     := ARRAY(4) 

    aRet[1] := .T. //.T. Liga, .F. Desliga trava da tabela SA1 
    aRet[2] := .F. //.T. Liga, .F. Desliga trava da tabela SA2 
    aRet[3] := .T. //.T. Liga, .F. Desliga trava da SB2 
    aRet[4] := .T. //Atualiza os Acumulados somente no final da gravacao dos itens da NFE

Return aRet