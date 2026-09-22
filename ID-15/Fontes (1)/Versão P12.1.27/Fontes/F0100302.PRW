#Include 'Protheus.ch'
#INCLUDE "APWEBEX.CH"
/*
{Protheus.doc} F0100302()
Busca o departamento da matricula referente a visão 
@Author     Bruno de Oliveira
@Since      07/10/2016
@Version    P12.1.07
@Project    MAN00000462901_EF_003
@Return 	cHtml, página html
*/
User Function F0100302()

	Local oOrg
	Local cHtml   := ""
	Local aEstrutura	:= {}
	Local cPosto		:= {}
	Local nX			:= 0
	Local nY			:= 0
	Local cAux			:= ""
	Local aAux			:= {}
	Local oInfUsr
	Local aPostos		:= {}
	
	Private nPTotal
	Private nCPage

	WEB EXTENDED INIT cHtml START "InSite"

	Default HttpGet->Page         := "1"
	Default HttpGet->FilterField  := ""
	Default HttpGet->FilterValue  := ""
	Default HttpGet->Page         := "1"
	Default HttpGet->nIndiceDepto := "1"
	Default HttpGet->nCurrentPage := 0
	Default HttpGet->nTotalPage   := "1"
	 	
	nCPage:= Val(HttpGet->Page)

	oOrg := WSORGSTRUCTURE():New()
	WsChgURL(@oOrg,"ORGSTRUCTURE.APW")
		
	nCurrentPage := IIF(!(EMPTY(HttpGet->nCurrentPage)),VAL(HttpGet->nCurrentPage),1)
		
	oInfUsr := WSW0500308():New()
	WsChgURL(@oInfUsr,"W0500308.apw")
	
	fGetInfRotina("U_F0100301.APW") //Verificar
	GetMat()							//Pega a Matricula e a filial do participante logado
	     
	oInfUsr:cVISION        := HttpSession->aInfRotina:cVisao
	oInfUsr:cPARTICIPANTID := HttpSession->cParticipantID
	oInfUsr:nPAGE          := nCurrentPage
	oInfUsr:cFilterField   := HttpGet->FilterField
	oInfUsr:cFilterValue   := HttpGet->FilterValue
	oInfUsr:cControlPost   := "N"
			
	If oInfUsr:GetDepartmentD()
		HttpSession->Department := oInfUsr:oWSGETDEPARTMENTDRESULT:oWSLISTOFDEPARTMENT:OWSDTDEPARTMENT
		nPTotal 		          := oInfUsr:oWSGETDEPARTMENTDRESULT:nPagesTotal
		nTotalPage              := val(HttpGet->nTotalPage)
	Else
		HttpSession->Department := {}
		nPTotal 		         := 1
	EndIf
	
	oInfUsr:RetInfUsr(HttpSession->aUser[2],HttpSession->RHMat)
	If ValType(oInfUsr:cRETINFUSRRESULT) == "C"
		aPostos := STRTOKARR( oInfUsr:cRETINFUSRRESULT, ',' )
	EndIf
	
	If Len(HttpSession->Department) > 0
		For nX := 1 To Len(HttpSession->Department)
			For nY := 1 To Len(aPostos)
				if HttpSession->aUser[2] == HttpSession->Department[nX]:cFILPOSTOVIS // DOR07339726_TK_8444453
					If AllTrim(aPostos[nY]) $ HttpSession->Department[nX]:CPOSTOVIS
						cAux :=HttpSession->Department[nX]:CPOSTOVIS
						If ","+aPostos[nY]+"," $  cAux
							cAux := StrTran(cAux,","+aPostos[nY]+"","")
						ElseIf ","+aPostos[nY]+"" $ cAux
							cAux := StrTran(cAux,","+aPostos[nY]+"","")
						ElseIf ""+aPostos[nY]+"," $ cAux
							cAux := StrTran(cAux,""+aPostos[nY]+",","")
						Else
							cAux := StrTran(cAux,""+aPostos[nY]+"","")
						EndIf
							
						HttpSession->Department[nX]:CPOSTOVIS := cAux
						If Empty(cAux)
							Aadd(aAux,nX)
						EndIf
					ElseIf Empty(HttpSession->Department[nX]:CPOSTOVIS)
						Aadd(aAux,nX)
					EndIf
				endif // DOR07339726_TK_8444453
			Next
		Next
	EndIf
		
	For nX := 1 To Len(aAux)
		ADel ( HttpSession->Department, aAux[nX] )
		ASize( HttpSession->Department, Len(HttpSession->Department)-1 )
	Next

	HttpCTType("text/html; charset=ISO-8859-1")
	cHtml := ExecInPage( "F0100302" )
		
	WEB EXTENDED END
	
Return cHtml