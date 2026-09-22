#include 'protheus.ch'
#include 'parmtype.ch'
/*/
    {Protheus.doc} MT120SCR
    Ponto de entrada para bloquear o campo despesa.
    @type  Ponto de entrada
    @author Ricardo Junior
    @since 19/12/2017
/*/
User Function MT120SCR()
	
	If SuperGetMv("MV_XATVDES",,.F.)
		ParamIxb:aControls[74]:oParent:oWnd:aControls[75]:bWhen := {|| .F. }
	EndIf	

Return