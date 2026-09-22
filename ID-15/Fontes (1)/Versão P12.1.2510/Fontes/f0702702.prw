#INCLUDE "TOTVS.CH"

/*/{Protheus.doc} F0702702
Função responsável pelo consumo do WebService de recebimento antecipado
@type Static function
@author anieli.rodrigues
@since 09/03/2017
@version 12.7
@param aDados, array, Dados a serem enviados no consumo do WS. A primeira posicao corresponde à operação realizada. 
@project MAN0000007423041_EF_027
/*/

User Function F0702702(aDados) 

	Local cChave	:= ""
	Local cMetodo	:= ""
	Local cSep		:= "|"
	Local cRet  	:= ""
	Local cStatus	:= "2"  //"1-ERRO,2-OK
	Local cURL		:= SuperGetMV("FS_URLRECA")  
	Local lRet		:= .T.
	Local nSet		:= 0
	Local nX		:= 0 
	Local oWSDL		:= Nil
	
	Do Case 
		Case aDados[1] == 3 
			cMetodo := "IncluirRecebimentoAntecipado"
		Case aDados[1] == 4
			cMetodo := "AlterarRecebimentoAntecipado" 
		Case aDados[1] == 5
			cMetodo := "ExcluirRecebimentoAntecipado" 
	EndCase
	
	oWSDL := TWSDLManager():New()
	
	cChave := aDados[2] + cSep + aDados[3] + cSep + aDados[11] + cSep + aDados[4] + cSep + aDados[5]

	If !oWSDL:ParseURL(cURL)	
		cRet := "[" + FwTimeStamp(2) + "] - Arquivo WSDL informado invalido"
		cRet += CRLF + oWsdl:cError
		lRet := .F.		
	EndIf

	If lRet .And. !oWSDL:SetOperation(cMetodo)
		cRet := "[" + FwTimeStamp(2) + "] - " + cMetodo + ": Não foi possível estabelecer a chamada do método!"
		lRet := .F.
	EndIf

	If lRet 

		oWSDL:lUseNSPrefix := .T.

		For nX := 2 to Len(aDados)
			oWSDL:SetValue(nSet,EncodeUTF8(Alltrim(aDados[nX])))
			nSet ++
		Next nX
			
		cRet := oWSDL:GetSoapMsg()
		
		If Empty(cRet)
			cRet := oWSDL:cError
			lRet := .F. 
		Endif 
	EndIf 
	
	If lRet .And. !oWSDL:SendSoapMsg()
		cRet := "[" + FwTimeStamp(2) + "] - " + cMetodo + ": erro ao enviar requisição ao servidor!"
		lRet := .F.	
	EndIf
	
	If lRet
		cRet := oWSDL:GetSoapResponse()
	EndIf

	FreeObj(oWSDL)

	If !lRet 
		cStatus := "1"
	EndIf 

	U_F07Log03('U_F0702702',aDados,cRet,cStatus,"SE1",1,cChave)
	
Return cRet