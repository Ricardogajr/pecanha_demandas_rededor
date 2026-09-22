 #include "totvs.ch"

/*/{Protheus.doc} F0702902
Webserviceclient Bloqueio de Nota Fiscal de Entrada
@type User function
@author Paulo Krüger
@since 16/03/2017
@version 12.7
@param	cFilOri , caracter, Filial
@param	cCodFor , caracter, Codigo do Fornecedor
@param	cLojFor , caracter, Loja do Fornecedor
@param	cNumTit , caracter, Numero do Titulo
@param	cParTit , caracter, Parcela do Titulo
@param	cPrfTit , caracter, Prefixo do Titulo
@param	cTipTit , caracter, Tipo do Titulo
@param	cOpcao	, caracter, Opcao 1=Bloqueio, 2=Desbloqueio
@param	nValTit , numerico, Valor do Titulo
@param	cValTit , caracter, Valor do Titulo
@project MAN0000007423041_EF_029
@return NIL
/*/

User Function F0702902(cFilOri, cCodFor, cLojFor, cNumTit, cParTit, cPrfTit, ;
						cTipTit, cOpcao, nValTit, cValTit, cTitFron)

Local cMsg  	:= ''
Local lRet		:= .T.
Local oWSDL     := Nil
Local cMetodo	:= ''
Local cURL		:= GetMV('FS_URLBLQN')

Local cInput  	:= ''
Local cStatus	:= ""  //"1-ERRO,2-OK

DEFAULT cFilOri  := ''
DEFAULT cCodFor  := '' 
DEFAULT cLojFor  := ''
DEFAULT cNumTit  := '' 
DEFAULT cParTit  := '' 
DEFAULT cPrfTit  := '' 
DEFAULT cTipTit  := '' 
DEFAULT cOpcao   := '' 
DEFAULT nValTit  := 0
DEFAULT cTitFron := ''

If cValTit == NIL
	cValTit := Alltrim(str(nValTit))	
EndIf
If nValTit == 0
	nValTit := Val(cValTit)
EndIf

cInput := "U_F0702902(" + cFilOri + "," + cCodFor + "," + cLojFor + "," + cNumTit + "," + cParTit + "," + cPrfTit + "," + cTipTit + "," + cOpcao + ",," + cValTit + "," + cTitFron + ")"

oWSDL := TWSDLManager():New()
		
If !oWSDL:ParseURL(cURL)	
	cMsg := '[' + FwTimeStamp(2) + '] - Arquivo WSDL informado invalido'
	cMsg += CRLF + oWSDL:cError
	lRet := .F.		
EndIf

If lRet
	aMethod := oWSDL:ListOperations() 
	Conout('[' + FwTimeStamp(2) + '] - Procurando método ' + cMetodo)
	cMetodo		:= If(cOpcao == '1','IncluirBloqueio','ExcluirBloqueio')
	If !oWSDL:SetOperation(cMetodo)
		cMsg := '[' + FwTimeStamp(2) + '] - ' + cMetodo + ': Não foi possível estabelecer a chamada do método!'
		Conout(cMsg)
		lRet := .F.
	EndIf

	If lRet
		
		oWSDL:lUseNSPrefix := .T.
	
		oWSDL:SetValue(0,EncodeUTF8(Alltrim(cFilOri     )))	//Filial
		oWSDL:SetValue(1,EncodeUTF8(Alltrim(cCodFor     )))	//Codigo do Fornecedor
		oWSDL:SetValue(2,EncodeUTF8(Alltrim(cLojFor     )))	//Loja do Fornecedor
		oWSDL:SetValue(3,EncodeUTF8(Alltrim(cNumTit     )))	//Numero do Titulo
		oWSDL:SetValue(4,EncodeUTF8(Alltrim(cParTit     )))	//Parcela do Titulo
		oWSDL:SetValue(5,EncodeUTF8(Alltrim(cPrfTit     )))	//Prefixo do Titulo
		oWSDL:SetValue(6,EncodeUTF8(Alltrim(cTipTit     )))	//Tipo do Titulo
		oWSDL:SetValue(7,EncodeUTF8(Alltrim(cOpcao      )))	//Opcao: 1=Bloqueia, 2=Desbloqueia
		oWSDL:SetValue(8,EncodeUTF8(Alltrim(Str(nValTit)))) //Valor do Titulo
		oWSDL:SetValue(9,EncodeUTF8(Alltrim(cTitFron    )))	//Numero do Titulo do Front
	
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

U_F07Log03('U_F0702902',cInput,cMsg,cStatus,"SE2",1,xFilial("SE2") + '|' + cPrfTit + '|' + cNumTit + '|' + cParTit + '|' + cTipTit + '|' + cCodFor + '|' + cLojFor)

Return