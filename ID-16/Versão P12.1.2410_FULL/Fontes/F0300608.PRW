#Include 'Protheus.ch'
#include 'FILEIO.ch'

/*{Protheus.doc} F0300608
(long_description)
@type function
@author Cris
@since 22/12/2016
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
@Project    MAN00000463701_EF_006
*/
User Function F0300608(nTipImp,cCamIni)
	
	Local lVlArq	:= .T.
	Local cExtens	:= ''
	
	DeFault nTipImp	:= 1
	Default cCamIni	:= ''
	
	if len(aRet) > 0
		
		SplitPath(aRet[3],@cDrvAt,@cDirect,@cArqImp,@cExtens)
		
		if Valtype(aRet[2]) == 'C'
			
			nTipImp		:= Val(Substring(aRet[2],1,1))
			
		Else
			
			nTipImp	:= aRet[2]
			
		EndIf
		
	Else
		
		SplitPath(cCamIni,@cDrvAt,@cDirect,@cArqImp,@cExtens)
		
	EndIf
	
	If Empty(cArqImp)
		If nTipImp == 1
			cTpForn	:= '1'
		Else
			cTpForn	:= '2'
		EndIf
		Return .T.
	Endif
	
	if nTipImp == 1
		
		if !'SAUDE' $ UPPER(cArqImp)
			
			Help("",1, "Help", "Tipo X Nome do Arquivo(VlArq_01)", "O tipo esta como 'SAUDE' selecione  um arquivo referente ao Plano de Saúde,contendo em seu nome a palavra 'SAUDE'!" , 3, 0)
			lVlArq	:= .F.
			
		EndIf
		
		cTpForn	:= '1'
		
	Elseif nTipImp == 2
		
		if !'ODONTOLOGIC' $ UPPER(cArqImp)
			
			Help("",1, "Help", "Tipo X Nome do Arquivo(VlArq_01)", "O tipo esta como 'ODONTOLOGICO' selecione  um arquivo referente ao Plano Odontológico,contendo em seu nome a palavra 'ODONTOLOGIC'!" , 3, 0)
			lVlArq	:= .F.
			
		EndIf
		
		cTpForn	:= '2'
		
	Else
		
		lVlArq	:= .F.
		
	EndIf
	
Return lVlArq
