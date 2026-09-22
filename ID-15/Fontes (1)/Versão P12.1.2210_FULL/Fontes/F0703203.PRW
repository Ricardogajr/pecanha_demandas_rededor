#Include 'TOTVS.CH'

/*/{Protheus.doc} F0703203
Client resposta ao IIB
@author Paulo Krüger
@since  15/02/2017
@param	cFilOri, caracter, Filial de Origem
@param	cCodCli, caracter, C´doigo do Cliente
@param	cLojCli, caracter, Loja do Cliente
@param	cNumPed, caracter, Numero do Pedido de Venda
@param	cMensagem, caracter, Mensagem de Retorno
@return Nil  
@project MAN0000007423041_EF_032
@cliente Rededor
@version P12.1.7
@history Sandro - QALOG
/*/

User Function F0703203(cFilOri, cCodCli, cLojCli, cNumPed, cMensagem)  
	Local nX		:= 0
	Local nY		:= 0
	Local aMethod	:= {}
	Local cFileWsdl	:= ''
	Local cMetodo	:= ''
	Local cMsg		:= ''
	Local cURL		:= GETMV('FS_URLRTNF')
	Local lRet		:= .T.
	Local aParents	:= {}	
	Local oWSDL		:= Nil 
	
	Local cInput  	:= 'U_F0703203(' + cFilOri + ',' + cCodCli + ',' + cLojCli + ',' + cNumPed + ',' + cMensagem + ')'						
	Local cStatus	:= ""  //"1-ERRO,2-OK
	
	
	If Empty(cFilOri)
		cFilOri	:= '-'
	EndIf
	If Empty(cCodCli)
		cCodCli	:= '-'
	EndIf
	If Empty(cLojCli)
		cLojCli	:= '-'
	EndIf
	If Empty(cNumPed)
		cNumPed	:= '-'
	EndIf

	oWSDL	:= TWSDLManager():New()
	
	If !oWSDL:ParseURL(cURL)	
		cMsg := '[' + FwTimeStamp(2) + '] - Arquivo WSDL informado invalido'
		cMsg += CRLF + oWsdl:cError
		lRet := .F.		
	EndIf

	If lRet			
		aMethod := oWSDL:ListOperations() 
		Conout('[' + FwTimeStamp(2) + '] - Procurando método RetornarErroProtheusSA.')
		cMetodo := 'RetornarErro'
		If !oWSDL:SetOperation(cMetodo)
			cMsg := '[' + FwTimeStamp(2) + '] - ' + cMetodo + ': Não foi possível estabelecer a chamada do método!'
			Conout(cMsg)
			lRet := .F.
		EndIf

		If lRet
		
			oWSDL:lUseNSPrefix := .T.
		
			oWSDL:SetValue(0, EncodeUTF8(Alltrim(cFilOri  ))) //Filial
			oWSDL:SetValue(1, EncodeUTF8(Alltrim(cCodCli  ))) //Cod. Cliente
			oWSDL:SetValue(2, EncodeUTF8(Alltrim(cLojCli  ))) //Loja Cliente
			oWSDL:SetValue(3, EncodeUTF8(Alltrim(cNumPed  ))) //Num. Pedido
			oWSDL:SetValue(4, EncodeUTF8(Alltrim(cMensagem))) //Mensagem
			
			cMsg := oWSDL:GetSoapMsg()
		
			If !oWSDL:SendSoapMsg(cMsg)
				cMsg := '[' + FwTimeStamp(2) + '] - ' + cMetodo + ': erro ao enviar requisição ao servidor!'
				Conout(cMsg)
				lRet := .F.
			EndIf
	
		EndIf
	EndIf
	FreeObj(oWSDL)
	
	If lRet
		cStatus := "2" //OK
	Else
		cStatus := "1" // ERRO
	EndIf
	
	U_F07Log03('U_F0703203',cInput,cMsg,cStatus,"SC5",1,xFilial("SC5") + '|' + cNumPed)
Return