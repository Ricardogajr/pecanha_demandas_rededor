#include 'protheus.ch'
#include 'parmtype.ch'
/*/{Protheus.doc} REDWSDL2
Rotina responsavel por montar a estrutura de envio e recebimento dos xml's da integração Bionexo.
@author Ricardo junior
@since 25/05/17
@version 1.1		
/*/

*----------------------------------------------*
User Function REDWSDL2(cOperation, aAux)
*----------------------------------------------*
	Local oWsdl        := NIL
	Local nRecLog	   := NIL
	Local cID		   := NIL
	Local aOps         := {}
	Local aComplex     := {}
	Local aSimple      := {}
	Local nOrdKey	   := NIL
	Local nX		   := 00
	Local nY		   := 00
	Local lRetBase	   := .T.  
	Local lRet         := .T.
	Local aRet	       := {}	
	Local cInput	   := NIL
	Local cOutput 	   := NIL
	Local cStatus 	   := NIL
	Local cIndKey 	   := NIL
	Local cRotina      := NIL
	Local cAlias       := NIL
	Private cErro	   := ""
	Private cAviso	   := ""

	Default cOperation := ""
	Default aAux       := {}

	oWsdl := TWsdlManager():New()
	cUrl  := SuperGetMv("MV_XURLIBM",,"http://10.25.136.22:7800") + "/conectador/Suprimentos/ManterSolicitacaoCompraProtheusSA/V1?wsdl"
	//cUrl  := SuperGetMv("MV_XURLIBM",,"http://10.15.34.46:8090/REDWS1.apw?WSDL")
	
	oWsdl:bNoCheckPeerCert := .T.
	If !oWsdl:ParseURL(cUrl)
        U_WsLogBio("REDWSDL2", 2, oWsdl:cError)
		Return {"-1", oWsdl:cError, ""}
	EndIf

	aOps := oWsdl:ListOperations()

	If Len(aOps) == 0
		conout("Erro: " + oWsdl:cError)
		Return
	EndIf

	If !oWsdl:SetOperation(cOperation)
		conout("Erro: " + oWsdl:cError)
		Return
	EndIf

	aComplex  := oWsdl:NextComplex()

	while ValType( aComplex ) == "A"

		If ( aComplex[2] == fMacroNo(cOperation, 5)  ) .And. ( aComplex[5] == fMacroNo(cOperation, 3) )
			nOccurs := 1
		ElseIf ( aComplex[2] == fMacroNo(cOperation, 6)  ) .And. ( aComplex[5] == fMacroNo(cOperation, 4) )
			nOccurs := Len(aAux) -1  
		ElseIf  ( aComplex[2] == fMacroNo(cOperation, 7)  ) .And. ( aComplex[5] == fMacroNo(cOperation, 8) )
			nOccurs := 1
		Else
			nOccurs := 0
		EndIf

		xRet := oWsdl:SetComplexOccurs( aComplex[1], nOccurs )

		If xRet == .F.
			conout( "Erro ao definir elemento " + aComplex[2] + ", ID " + cValToChar( aComplex[1] ) + ", com " + cValToChar( nOccurs ) + " ocorrencias" )
			return
		EndIf

		aComplex := oWsdl:NextComplex()
	EndDo

	aSimple   := oWsdl:SimpleInput()


	//Inicio da Estrutura base que é obrigatória no envio.
	For nY := 01 To Len(aAux[1])
		nPos := aScan(aSimple, {|x| x[2] == aAux[1][nY][1] .And. x[5] == fMacroNo(cOperation, 1) })
		If nPos > 0
			If !oWsdl:SetValue(aSimple[nPos][1], aAux[1][nY][2])
				conout("Erro: " + oWsdl:cError)        
				Return
			EndIf
		EndIf     
	Next nY	  

	//Fim da estrutura base
	For nX := 02 To Len(aAux)   	
		For nY := 01 To Len(aAux[nX])
			nPos := aScan(aSimple, {|x| AllTrim(x[2]) == AllTrim(aAux[nX][nY][1]) .And. AllTrim(x[5]) == AllTrim(fMacroNo(cOperation, 2, nX - 1))})
			If nPos > 0
				If !oWsdl:SetValue(aSimple[nPos][1], aAux[nX][nY][2])
					conout("Erro: " + oWsdl:cError )        
					lRet := .F.
					Exit		   
				EndIf
			EndIf
		Next nY	    
	Next nX	  

	If !lRet     //== .T. // 29/09/2017 RTEo
		Return
	EndIf
    U_WsLogBio("REDWSDL2", 2, oWsdl:GetSoapMsg())
	If !oWsdl:SendSoapMsg(oWsdl:GetSoapMsg())
		cXml := oWsdl:GetSoapResponse()
        U_WsLogBio("REDWSDL2", 2, oWsdl:GetSoapResponse())
		Return {"-1", oWsdl:cError}
	EndIf

	cXml := oWsdl:GetSoapResponse()
	
	
	If Empty(cXml)
		Return {"-1", oWsdl:cError}
	EndIf

	cXml := fTrataXml(cXml)  
    U_WsLogBio("REDWSDL2", 2, cXml)
	oXml := XmlParser(cXml,"_",@cErro,@cAviso)
	
	If Type("oXml:_SOAPENV_ENVELOPE:_SOAPENV_BODY:_WDGRESPONSE:_WDGRESULT:TEXT") != "U"
		If oXml:_SOAPENV_ENVELOPE:_SOAPENV_BODY:_WDGRESPONSE:_WDGRESULT:TEXT == "1"
			aRet :=  {"1", "", oXml}
            U_WsLogBio("REDWSDL2 - WDGRESULT", 2, "RETORNO: 1 SUCESSO ")
			cRotina := "U_REDSCH1"
		EndIf  
	EndIf
	
	If Type("oXml:_SOAPENV_ENVELOPE:_SOAPENV_BODY:_WFGRESPONSE:_WFGRESULT:TEXT") != "U"
		If oXml:_SOAPENV_ENVELOPE:_SOAPENV_BODY:_WFGRESPONSE:_WFGRESULT:TEXT == "1"
			aRet :=  {"1", "", oXml}
            U_WsLogBio("REDWSDL2 - WFGRESULT", 2, "RETORNO: 1 SUCESSO")
			cRotina := "U_REDSCH4"
		EndIf  
	EndIf
	
	If Type("oXml:_SOAPENV_ENVELOPE:_SOAPENV_BODY:_WASERESPONSE:_WASERESULT:TEXT") != "U"
		If oXml:_SOAPENV_ENVELOPE:_SOAPENV_BODY:_WASERESPONSE:_WASERESULT:TEXT == "1"
			aRet :=  {"1", "", oXml}
            U_WsLogBio("REDWSDL2 - WASERESULT", 2, "RETORNO: 1 SUCESSO ")			
			cAlias  := "SC1"
			cIndKey := SC1->C1_FILIAL + "|" + SC1->C1_NUM
			cRotina := "U_REDA002"
		EndIf  
	EndIf	
	If Type("oXml:_SOAPENV_ENVELOPE:_SOAPENV_BODY:_WAURESPONSE:_WAURESULT:TEXT") != "U"
		If oXml:_SOAPENV_ENVELOPE:_SOAPENV_BODY:_WAURESPONSE:_WAURESULT:TEXT == "1"
			aRet :=  {"1", "", oXml}
			cAlias  := "SC1"
			cIndKey := SC1->C1_FILIAL + "|" + SC1->C1_NUM
			cRotina := "U_REDA004"
		EndIf      
	EndIf
	
	If Type("oXml:_SOAPENV_ENVELOPE:_SOAPENV_BODY:_WBSRESPONSE:_WBSRESULT:TEXT") != "U"
		If oXml:_SOAPENV_ENVELOPE:_SOAPENV_BODY:_WBSRESPONSE:_WBSRESULT:TEXT == "1"
			aRet 	:=  {"1", "", oXml}
			cAlias  := "SC7"
			cIndKey := SC7->C7_FILIAL + "|" + SC7->C7_NUM
            U_WsLogBio("REDWSDL2 - _WBSRESULT", 2, "RETORNO: 1 SUCESSO ")
			cRotina := "U_REDSCH3"
		EndIf  
	EndIf
	If cRotina $ "U_REDSCH3|U_REDA004|U_REDA002"
		U_F07Log03(cRotina,cRotina + "("+ AllTrim(SC1->C1_XIDPROC) +")",cXml,If(aRet[1]=="1","2","1"),cAlias,1,cIndKey)
	EndIf
	oWsdl	:= Nil
	oXml 	:= Nil
	
Return aRet 
	
*--------------------------------------------------------*
Static Function fMacroNo(cOperation, nTipoRet, nX)
*--------------------------------------------------------*  
	Local cMacro := ""

	Default cOperation := ""
	Default nTipoRet := 0
	Default nX := 0

	If cOperation == "WASE"
		If nTipoRet == 1
			cMacro := "WASE#1.WSBASE#1"
		ElseIf nTipoRet == 2
			cMacro := "WASE#1.WSSOLIC#1.LSOLIC#1.STRWASE#"+ cValToChar(nX)
		ElseIf nTipoRet == 3
			cMacro := "WASE#1"
		ElseIf nTipoRet == 4 
			cMacro := "WASE#1.WSSOLIC#1.LSOLIC#1"      
		ElseIf nTipoRet == 5
			cMacro := "WSBASE"
		ElseIf nTipoRet == 6
			cMacro := "STRWASE"        
		EndIf  
	ElseIf cOperation == "WBS"
		If nTipoRet == 1
			cMacro := "WBS#1.WSBASE#1"
		ElseIf nTipoRet == 2
			cMacro := "WBS#1.WSCONF#1.ACONF#1.STRWBS#"+ cValToChar(nX)
		ElseIf nTipoRet == 3
			cMacro := "WBS#1"
		ElseIf nTipoRet == 4 
			cMacro := "WBS#1.WSCONF#1.ACONF#1"      
		ElseIf nTipoRet == 5
			cMacro := "WSBASE"
		ElseIf nTipoRet == 6
			cMacro := "STRWBS"        
		EndIf
	ElseIf cOperation == "WAU"
		If nTipoRet == 1
			cMacro := "WAU#1.WSBASE#1"
		ElseIf nTipoRet == 2
			cMacro := "WAU#1.WSSOLIC#1.LSOLIC#1.STRWASE#"+ cValToChar(nX)
		ElseIf nTipoRet == 3
			cMacro := "WAU#1" 
		ElseIf nTipoRet == 4
			cMacro := "WAU#1.WSSOLIC#1.LSOLIC#1"
		ElseIf nTipoRet == 5
			cMacro := "WSBASE"  
		ElseIf nTipoRet == 6
			cMacro := "STRWASE"  
		EndIf  
	ElseIf cOperation == "WDG"
		If nTipoRet == 1
			cMacro := "WDG#1.WSBASE#1"
		ElseIf nTipoRet == 3
			cMacro := "WDG#1" 
		ElseIf nTipoRet == 5
			cMacro := "WSBASE"  
		EndIf    
	ElseIf cOperation == "WFG"
		If nTipoRet == 1
			cMacro := "WFG#1.WSBASE#1"
		ElseIf nTipoRet == 3
			cMacro := "WFG#1" 
		ElseIf nTipoRet == 5
			cMacro := "WSBASE"  
		EndIf
	EndIf
	Return cMacro

*-----------------------------------*
Static Function fTrataXml(cXml)
*-----------------------------------*
	Local cQuali  := ""
	Local nPos    := 00
	Local nX      := 00
	Local aResponses := {":WDGRESPONSE", ":WASERESPONSE", ":WAURESPONSE", ":WBSRESPONSE", ":WFGRESPONSE" }
	Local cP20lg  := ' '
	For nX := 01 To Len(aResponses)
		nPos := AT(aResponses[nX], cXml)
		If nPos > 0
			Exit
		EndIf
	Next nX 

	If nPos > 0
		cQuali := SubStr(cXml, nPos - 3 , 4)
		nPosMenor := AT( "<", cQuali)
		If nPosMenor > 0
			cQuali := SubStr(cQuali, nPosMenor + 1, Len(cQuali))
		EndIf
		cXml := StrTran(cXml, cQuali, "")
	EndIf
Return cXml