#INCLUDE 'TOTVS.CH'

/*{Protheus.doc} F0702904
Validação na inclusão de Nota Fiscal de Entrada
@author Paulo Krüger
@since 17/11/2017
@project	MAN0000007423041_EF_029
@return lRet
*/

User Function F0702904()

Local lRet		:=	.F.
Local nPosCod	:=	0
Local nPosItm	:=	0
Local nLin		:=	0
Local cMensagem	:=	''
Local aEstocavel:=	{}
Local aWBrowse1	:=	{}
Local aArea		:=	{}

Private	oDlg

If IsInCallStack('U_F0703301') .Or. FwIsInCallStack("U_F1304701") .Or. FwIsInCallStack("U_xKPTInbAll") .Or. FwIsInCallStack("U_RDNFUPLOAD") //Caso venha de integração
	lRet		:=	.T.
	Return(lRet)
EndIf

aArea	:= GetArea()
nPosCod := Ascan(aHeader,{|x|Alltrim(x[2]) == 'D1_COD' })
nPosItm := Ascan(aHeader,{|x|Alltrim(x[2]) == 'D1_ITEM'})

For nLin := 01 To Len(aCols)
	If !aCols[nLin][Len(aHeader) + 01]
		aProdEst := {}
		//P17->(DbSetOrder(01))
		//If P17->(DbSeek(xFilial('P17') + aCols[nLin][nPosCod] + cFilAnt))
			aProdEst := fQryEst(cFilAnt, aCols[nLin][nPosCod])
			If aProdEst[1] == "S"
			//If P17->P17_ESTOQ == 'S'
				//SB1->(DbSetOrder(01))
				//If SB1->(DbSeek(xFilial('SB1') + aCols[nLin][nPosCod]))
					//Aadd(aWBrowse1,{aCols[nLin][nPosItm], SB1->B1_COD, SB1->B1_DESC})
					Aadd(aWBrowse1,{aCols[nLin][nPosItm], aProdEst[2], aProdEst[3]})
				//EndIf
			Else
				cMensagem := 'Produto ' + aCols[nLin][nPosCod] + ' não cadastrado na tabela P17 (Tratamento excl. por filiais).'
			EndIf	
			//EndIf
	EndIf
Next nLin

If !Empty(aWBrowse1)
	cMensagem := 'Notas Fiscais de produtos estocáveis somente podem ser incluídas manualmente nos Fronts e deverão ser recebidas via integração no Protheus.'
	DEFINE MSDIALOG oDlg TITLE 'Ítens estocáveis.' FROM 000, 000  TO 300, 700 COLORS 0, 16777215 PIXEL
	@ 024, 024 SAY  oSay1 PROMPT cMensagem SIZE 193, 016 OF oDlg COLORS 0, 16777215 PIXEL
	@ 015, 020 GROUP oGroup1  TO 045, 330 PROMPT '' OF oDlg COLOR 0, 16777215 PIXEL
	@ 047, 020 GROUP oGroup2  TO 120, 330 PROMPT '' OF oDlg COLOR 0, 16777215 PIXEL
	@ 012, 016 GROUP oGroup3  TO 123, 333 PROMPT '' OF oDlg COLOR 0, 16777215 PIXEL
	fGetDados1(aWBrowse1)
	DEFINE SBUTTON oSButton1 FROM 130, 320 TYPE 02 OF oDlg ENABLE ACTION oDlg:End()
	ACTIVATE MSDIALOG oDlg CENTERED
Else
	lRet := .T.
EndIf

RestArea(aArea)
Return(lRet)

/*/{Protheus.doc} fGetDados1
Monta linhas do grid da mensagem de alerta.
@author 	Paulo Krüger
@since 		17/11/2017
@version 	P12.7
@project	MAN0000007423041_EF_029
@Return		lRet
/*/

Static Function fGetDados1(aWBrowse1)

Local oWBrowse1

@ 050, 022 	LISTBOX oWBrowse1 Fields HEADER 	'Item'			,	;
												'Produto'		,	;
												'Descrição'			;
			SIZE 301, 069 OF oDlg PIXEL ColSizes 50,50

oWBrowse1:SetArray(aWBrowse1)
oWBrowse1:bLine := {|| {;
						aWBrowse1[oWBrowse1:nAt,01],	;
						aWBrowse1[oWBrowse1:nAt,02],	;
						aWBrowse1[oWBrowse1:nAt,03]}}


Return

Static Function fQryEst(cFilP17, cCodP17)
	Local aArea 	:= GetArea()
	Local cAliasQry := GetNextAlias()
	Local aRet		:= {"","",""}
	
	cQuery := " SELECT P17_ESTOQ, SB1.B1_COD, SB1.B1_DESC FROM " + RetSqlName("P17") + " P17 "
	cQuery += " INNER JOIN "+RetSqlName("SB1")+" SB1 " + CRLF
	cQuery += " ON SB1.B1_FILIAL = '"+xFilial("SB1")+"' " + CRLF
	cQuery += " AND SB1.B1_COD = P17.P17_COD " + CRLF
	cQuery += " AND SB1.D_E_L_E_T_  = P17.D_E_L_E_T_  " + CRLF
	cQuery += " WHERE P17.D_E_L_E_T_ = ' '  " + CRLF
	cQuery += " AND P17.P17_FTRATA = '"+cFilP17+"'  " + CRLF
	cQuery += " AND P17.P17_COD = '"+cCodP17+"' " + CRLF
	
	dbUseArea( .T., "TOPCONN", TcGenQry( ,,cQuery ), cAliasQry, .F., .T. )
	
	If Select(cAliasQry) > 0
		If P17_ESTOQ == "S"
			aRet := {(cAliasQry)->P17_ESTOQ,(cAliasQry)->B1_COD, (cAliasQry)->B1_DESC}
		EndIf
	EndIf
	RestArea(aArea)
Return aRet

