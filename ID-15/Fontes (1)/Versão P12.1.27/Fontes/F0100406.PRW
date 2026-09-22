#Include 'Protheus.ch'

/*/{Protheus.Doc} F0100406    
Altera campo customizado de status do PC quando bloqueado pelo módulo PCO.
Executada no PE MT120PCOK. 
@project	MAN00000462901_EF_004     
@author		Paulo Krüger
@version	P12
@since		15/06/2016  
/*/
User Function F0100406()

	Local aAreas    := {SAJ->(GetArea()),GetArea()}
	Local lAtualiz  := .T.
	Local lPCValido := .T.

//  ticket n° 12314715
	Local _cUserPar := GetMV("FS_XUSRINT")
	Local _cUserCom := RetCodUsr()

	Begin Sequence

		If IsInCallStack("U_F0100401")  // Quando PC originado de Solicitação de Pagamentos.
			Break
		EndIf

//		If IsInCallStack('U_F0100113')	// Quando PC originado de Medição Automática.
		If IsInCallStack('U_F1200709')	// Quando PC originado de Medição Automática.
			Break
		EndIf	

//      ticket n° 12314715	
		If Empty(_cUserCom)
			_cUserCom := _cUserPar
		EndIf 

		SAJ->(DbSetOrder(2))
		If !SAJ->(DbSeek(xFilial('SAJ') + _cUserCom)) // ticket n° 12314715
			Help( , , 'F0100406', , 'Usuário sem Grupo de compras!', 1, 0, , , , , , {"Solicite seu cadastro para a equipe responsável."} )
			lPCValido := .F.
			Break
		EndIf	
			
	End Sequence
	
	
	If GetMV('MV_PCOINTE') == '1'
		If nTipoPed == 1
			lAtualiz := PcoVldLan('000052','01','MATA121',/*lUsaLote*/,/*lDeleta*/, .F./*lVldLinGrade*/)
		ElseIf nTipoPed == 2
			lAtualiz := PcoVldLan('000053','01','MATA122',/*lUsaLote*/,/*lDeleta*/, .F./*lVldLinGrade*/)
		EndIf
	EndIf

	AEval(aAreas, {|aArea| RestArea(aArea) })

Return lPCValido
