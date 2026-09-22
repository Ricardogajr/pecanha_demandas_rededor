#Include 'Protheus.ch'

User Function F0801602()
	Local aArea := GetArea()
	Local oMdl  := FwModelActivate()
	Local oMdlPAF := oMdl:GetModel("PAFMASTER")
	Local aTpSolic := {}
	Local lRet := .F.
	Local oDlg
	Local aRet := {}
	
	Local oList := Nil
	
	DbSelectArea("PA7")
	PA7->(DbGotop())
	While PA7->(!EOF())
		
		nPos := aScan(aTpSolic,{|x| x[1] == PA7->PA7_CODIGO})
		If nPos == 0
			aAdd(aTpSolic,{PA7->PA7_CODIGO,PA7->PA7_DESCR})
		EndIf
		
		PA7->(DbSkip())
	End
	
	If Len(aTpSolic) > 0
	
		Define MsDialog oDlg Title "Tipos de Solicitação" From 0,0 To 260, 435 Of oMainWnd Pixel
		
		@ 5,5 LISTBOX oList VAR lVar Fields HEADER "Tipo", "Descrição" SIZE 200,100 OF oDlg PIXEL
		
		oList:SetArray( aTpSolic )
		oList:bLine := {|| { aTpSolic[oList:nAt,1], aTpSolic[oList:nAt,2]} }
		oList:bLDblClick := {|| {oDlg:End(), aRet := {oList:aArray[oList:nAt,1]}}}
		
		DEFINE SBUTTON FROM 112,005 TYPE 1 ACTION (oDlg:End(), aRet := {oList:aArray[oList:nAt,1]}) ENABLE OF oDlg
		DEFINE SBUTTON FROM 112,040 TYPE 2 ACTION oDlg:End() ENABLE OF oDlg
		
		Activate MSDialog oDlg Centered
	
	Else
	
		MsgAlert("Não existem registros na tabela de tipos de solicitação")
	
	EndIf
	
	If Len(aRet) > 0
		lRet := .T.
		oMdlPAF:SetValue("PAF_TIPO", aRet[1] )
		aTpSolic := {}
	EndIf
	
	RestArea(aArea)
	
Return lRet
