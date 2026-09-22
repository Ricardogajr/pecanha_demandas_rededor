#Include 'Protheus.ch'
#INCLUDE "APWEBEX.CH" 
/*
{Protheus.doc} F0300402()

@Author     Henrique Madureira
@Since      
@Version    P12.7
@Project    MAN00000463701_EF_004
@Return	 cHtml
*/
User Function F0300402()
Local cHtml   	:= ""
Local cTela      := "F0300402"

WEB EXTENDED INIT cHtml START "InSite"	         
	
	cMat := HTTPSession->RHMat
	cNome := HttpSession->Login
	
	oAcao  := WSW0300401():new()
	WsChgURL(@oAcao,"W0300401.APW")
	
	If oAcao:LogFunc(cMat)
		cMatricula    := oAcao:oWSLogFuncRESULT:cMatricula
		cNome         := oAcao:oWSLogFuncRESULT:cNOME
		cAdmissao     := oAcao:oWSLogFuncRESULT:cAdmissao
		cDepartamento := oAcao:oWSLogFuncRESULT:cDepartamento
		cSituacao     := oAcao:oWSLogFuncRESULT:cSituacao
	Else
		cTela := "F0300405"
	EndIf

	cHtml := ExecInPage(cTela)

WEB EXTENDED END
Return cHtml

