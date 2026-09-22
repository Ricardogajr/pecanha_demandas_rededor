#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'

/*/{Protheus.doc} F0700003
Monitor Integração Log de Saída
@author Alex Sandro
@since 27/12/2016
@param cFiltro, caracter, filtro de browse
@Project MAN0000007423041_EF_000 - Log de Saída
/*/
User Function F0700003(cFiltro)
	Local oBrowse := FWMBrowse():New()
	
	oBrowse:SetAlias('P20')
	oBrowse:SetDescription('Monitor Integração Log de Saída')
	oBrowse:AddLegend( "P20_STATUS == '1' .AND. ! Empty(P20_DTHRR)", "BLUE", "Reprocessado"  )
	oBrowse:AddLegend( "P20_STATUS == '2'", "GREEN", "Sucessso"  )
	oBrowse:AddLegend( "P20_STATUS == '1'", "RED", "Falha"  )
	oBrowse:AddLegend( "P20_STATUS == '0'", "BLACK", "Baixado" )
	oBrowse:SetMenuDef("F0700003")
	If ! cFiltro==NIL
		oBrowse:SetFilterDefault( cFiltro )
	EndIf
	oBrowse:Activate()
Return

/*{Protheus.doc} MenuDef
Menu do Monitor Integração Log de Saída
@author CDE - Célula de Desenvolvimento Especifico
@Project MAN0000007423041_EF_000 - Log de Saída
*/
Static Function MenuDef()
	Local aRotina := {}
	
	ADD OPTION aRotina Title 'Visualizar' Action 'VIEWDEF.F0700003' OPERATION 2 ACCESS 0
	ADD OPTION aRotina Title 'Executar'   Action 'U_F07ExP20(1)' OPERATION 4 ACCESS 0
	ADD OPTION aRotina Title 'Baixar'     Action 'U_F07ExP20(2)' OPERATION 4 ACCESS 0
	
Return aRotina

/*{Protheus.doc} ModelDef
Modelo de dados do Monitor Integração Log de Saída
@author CDE - Célula de Desenvolvimento Especifico
@Project MAN0000007423041_EF_000 - Log de Saída
*/
Static Function ModelDef()
	Local oStruMod 	:= FWFormStruct(1,'P20')
	Local oModel	:= MPFormModel():New('M0700003') //Model com 7 caracteres
	
	oModel:AddFields('MASTER',, oStruMod)
	oModel:SetPrimaryKey({})
	oModel:SetDescription('Monitor Integração Log de Saída')
	oModel:GetModel('MASTER'):SetDescription('Monitor Integração Log de Saída')
Return oModel

/*{Protheus.doc} ViewDef
Tela do Monitor Integração Log de Saída
@author CDE - Célula de Desenvolvimento Especifico
@Project MAN0000007423041_EF_000 - Log de Saída
*/
Static Function ViewDef()
	Local oModel 	:= FWLoadModel('F0700003')
	Local oStruView := FWFormStruct(2,'P20')
	Local oView		:= FWFormView():New()
	
	oView:SetModel(oModel)
	oView:AddField('VIEW_MASTER', oStruView, 'MASTER')
	oView:CreateHorizontalBox('SUPERIOR', 100 )
	oView:SetOwnerView('VIEW_MASTER', 'SUPERIOR')
Return oView

/*{Protheus.doc} F07ExP20
Validação dos status para execução
@author Alex Sandro
@since 27/12/2016
@Project MAN0000007423041_EF_000 - Log de Saída
*/
User Function F07ExP20(nBtn)
	If P20->P20_STATUS == "2"
		MsgStop('WS Client já foi processado com sucesso anteriormente!!')
		Return
	EndIf
	
	If P20->P20_STATUS == "1" .and. ! Empty(P20->P20_DTHRR)
		MsgStop('WS Client já foi reprocessado anteriormente!!')
		Return
	EndIf
	
	If nBtn == 1
		If P20->P20_STATUS == "0"
			MsgStop('WS Client já foi baixada anteriormente!!')
			Return
		EndIf
	EndIf
	
	If ! MsgYesno("Confirma a execução do WSC?")
		Return
	EndIf
	
	If nBtn == 1
		MsAguarde({|| ExecP20()},"Aguarde...","Reprocessando WS Client" ,.T.)
	Else
		MsAguarde({|| BaixP20()},"Aguarde...","Baixando WS Client" ,.T.)
	EndIf
Return

/*{Protheus.doc} F07ExP20
Execução do Reprocessamento
@author Alex Sandro
@since 27/12/2016
@Project MAN0000007423041_EF_000 - Log de Saída
*/
Static Function ExecP20()
	Local bExec := {|| .t. }
	Local aPar	:= {}
	Local cRet
	Local nRecno := P20->(Recno())
	LocaL nIDJOB := ''
	Local cRotina:= ''
	
	If "(" $ P20->P20_INPUT
		// Tratamento do do imput
		// Exemplo
		// Antes 'U_F0702902(01,000001,01,1232  ,  ,   ,NF,3,,10.4)'
		// no input a função poderá ter somente parametros com string e com a opcao de NIL
		// Depois 'U_F0702902("01","000001","01","1232  ","  ","   ","NF","3",,"10.4")'
		
		
		cRotina := Alltrim(P20->P20_INPUT)
		FWJsonDeserialize(cRotina,@cRotina)
		cRotina := StrTran(cRotina,',','","')
		cRotina := StrTran(cRotina,'(','("')
		cRotina := StrTran(cRotina,')','")')
		cRotina := StrTran(cRotina,'""','')
		cRotina := '{|x| ' + cRotina + '}'
		bExec := &cRotina
		eval(bExec)
	Else
		cRotina := Alltrim(P20->P20_ROTINA)
		FWJsonDeserialize(Alltrim(P20->P20_INPUT),aPar)
		bExec := &('{|x| ' + cRotina + '(x)}')
		eval(bExec,aPar)
	EndIf
	
	cRet := ALLTRIM(P20->P20_OUTPUT)
	nIDJOB := P20->P20_ID
	
	P20->(DbGoto(nRecno))
	P20->(RecLock('P20',.F.))
	P20->P20_IDJOB := nIDJOB
	P20->P20_DTHRR  := FwTimeStamp()
	P20->(MsUnLock())
	
	AutoGrLog('')
	FErase(NomeAutoLog())
	AutoGrLog(cRet)
	If !(IsBlind())
		MostraErro()
	EndIf
	
Return

/*{Protheus.doc} BaixP20
Execução da Baixa
@author CDE - Célula de Desenvolvimento Especifico
@since 18/09/2018
@Project MAN0000007423041_EF_000 - Log de Saída
*/
Static Function BaixP20()

	Local nRecno := P20->(Recno())
	P20->(DbGoto(nRecno))
	P20->(RecLock('P20',.F.))
	P20->P20_STATUS := "0"
	P20->(MsUnLock())

Return