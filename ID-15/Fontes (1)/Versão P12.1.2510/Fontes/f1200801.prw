#Include "totvs.ch"
#INCLUDE "TBICONN.CH"
#INCLUDE "FWMVCDEF.CH"


/*{Protheus.doc} F1200801
Rotina para gerar copia da tabela de preço de compras
@author Sandro
@since 18/08/2017
@project MAN0000007423046_EF_008
@obs 
    Utilizando no ponto de entrada

*/

User Function F1200801(oObj)
    
    Local aAreas    := {CNA->(GetArea()), GetArea()}
    Local nOpc      := oObj:nOperation
    Local oModelCNA := oObj:GetModel("CNADETAIL")
    Local oModel 	:= oObj:GetModel('CN9MASTER')
    Local cSituac   := oModel:GetValue("CN9_SITUAC")
    Local nX        := 0
    Local cCodFor   := ""
    Local cCodLoja  := ""
    Local cTabPreco := ""
    Local aCabec    := {} 
    Local aItens    := {}
    
    Private lMsErroAuto := .F.

    If !cSituac == "09"  //09- Revisão
        Return
    EndIf

    // Revisão - Paralisação
    //IF A300GTpRev() == "5" .And. !Empty(oModel:GetValue("CN9_MOTPAR")) .And. !Empty(oModel:GetValue("CN9_DTFIMP"))
    //   Return
    //EndIf
/*
X5_TABELA X5_CHAVE X5_DESCRI
GC	      1	       Aditivo
GC	      2	       Reajuste
GC	      3	       Realinhamento
GC	      4	       Readequação
GC	      5	       Paralisação
GC	      6	       Reinicio
GC	      7	       Cláusulas
GC	      8	       Contábil
GC	      9	       Índices
GC	      A	       Fornecedor/Cliente
GC	      B	       Grupos de Aprovadores
GC	      E	       Caução */    
        
    // Conforme solicitação do Marcus deve filtrar todas as revisões
    IF A300GTpRev() $ "1|2|3|4|5|6|7|8|9|A|B|E" 
       Return
    EndIf    

    For nX := 1 To oModelCNA:Length() //definido que é para pegar a primeira tabela de preço e que não haverá mais planilhas com outras tabelas
		oModelCNA:GoLine(nX)
		If !oModelCNA:IsDeleted() 
           cCodFor   := oModelCNA:GetValue("CNA_FORNEC")
           cCodLoja  := oModelCNA:GetValue("CNA_LJFORN")
           cTabPreco := oModelCNA:GetValue("CNA_XTABPC")
           Exit
        EndIf
	Next nX

    If Empty(cTabPreco)
        DisarmTransaction()
        Help( , , "Help", "F120080101", "Tabela não informada!", 1, 0 )
        Break
    EndIf

    If !CarregaTab(cCodFor, cCodLoja, cTabPreco, aCabec, aItens, nOpc)
        DisarmTransaction()
        Help( , , "Help", "F120080102", "Tabela não encontrada!", 1, 0 )
        Break
    EndIf

    MSExecAuto({|x,y,z| COMA010(x,y,z)},nOpc ,aCabec, aItens)		
    If lMsErroAuto		
        DisarmTransaction()
		If (!IsBlind())
			MostraErro()
		EndIf

        Break            
    EndIf	

    If nOpc == 3
        //atualizar a tabela CNA com o codigo da nova tabela
        CNA->(MsSeek(CN9->(CN9_FILIAL+CN9_NUMERO+CN9_REVISA)))
        CNA->(RecLock('CNA', .F.))
        CNA->CNA_XTABPC := AIA->AIA_CODTAB
        CNA->(MsUnlock())
    EndIf
    
    AEval(aAreas,{|aArea| RestArea(aArea) })

Return


Static Function CarregaTab(cCodFor, cCodLoja, cTabPreco, aCabec, aItens, nOpc)

    Local aAreaAIA := AIA->(GetArea("AIA"))
    Local aAreaAIB := AIB->(GetArea("AIB"))
    Local cNomeCpo := ""
    Local uConteudo:= NIL
    Local nx       := 0
    Local aItem    := {}
    Local cNovaTab := NextTab(cCodFor, cCodLoja)

    AIA->(DbSetOrder(1))
    If ! AIA->(DbSeek(xFilial("AIA") + cCodFor + cCodLoja + cTabPreco))
        RestArea(aAreaAIB)
        RestArea(aAreaAIA)
        Return .F.
    EndIf

    aCabec := {}
    For nx := 1  to AIA->(Fcount())
        cNomeCpo := AIA->(FieldName(nx))
        uConteudo:= AIA->(FieldGet(nx))
        If cNomeCpo == "AIA_FILIAL" .Or. ( cNomeCpo == "AIA_CODTAB" .And. nOpc == 3 )
            If cNomeCpo == "AIA_CODTAB"
                AAdd(aCabec,{"AIA_CODTAB", cNovaTab, Nil})
            EndIf
            Loop
        EndIf

        AAdd(aCabec, {cNomeCpo, uConteudo, NIL})
    Next

    AIB->(DbSetOrder(1))
    AIB->(DbSeek(xFilial("AIB")+(AIA->(AIA_CODFOR + AIA_LOJFOR + AIA_CODTAB))))
    While AIB->(! Eof() .and.  AIB_FILIAL+AIB_CODFOR+AIB_LOJFOR+AIB_CODTAB == ;
                               xFilial("AIB")+(AIA->(AIA_CODFOR + AIA_LOJFOR + AIA_CODTAB)))

        aItem := {}
        For nx := 1  to AIB->(Fcount())
            cNomeCpo := AIB->(FieldName(nx))
            uConteudo:= AIB->(FieldGet(nx))
            If cNomeCpo $ "AIB_FILIAL|AIB_FILIAL|AIB_CODFOR|AIB_LOJFOR|AIB_CODTAB" 
                Loop
            EndIf

            AAdd(aItem, {cNomeCpo, uConteudo, NIL})
        Next
        aAdd(aItens,aClone(aItem))

        AIB->(DbSkip())
    End 

    RestArea(aAreaAIB)
    RestArea(aAreaAIA)

Return .T.

/*{Protheus.doc} NextTab
Busca próximo código de tabela para o Fornecedor.
@author  Carlao
@since   04/09/2017
@project MAN0000007423046_EF_008
*/
Static Function NextTab(cCodFor, cCodLoja)

    Local cNextTab  := "001"
    Local cQuery    := ""
    Local aArea     := GetArea()
    Local cQryAlias := GetNextAlias()
    
    cQuery += "SELECT MAX(AIA.AIA_CODTAB) ULTTAB " + CRLF
    cQuery += "FROM " + RetSQLName("AIA") + " AIA " + CRLF
    cQuery += "WHERE " + CRLF
    cQuery += "AIA.AIA_FILIAL = '" + XFilial("AIA") + "' AND " + CRLF
    cQuery += "AIA.AIA_CODFOR = '" + cCodFor + "' AND " + CRLF
    cQuery += "AIA.AIA_LOJFOR = '" + cCodLoja + "' AND " + CRLF
    cQuery += "AIA.D_E_L_E_T_ = ' ' " + CRLF

	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cQryAlias)

    If !(cQryAlias)->(Eof())
        cNextTab := Soma1((cQryAlias)->ULTTAB)
    EndIf

    (cQryAlias)->(DbCloseArea())

    RestArea(aArea)

Return cNextTab
