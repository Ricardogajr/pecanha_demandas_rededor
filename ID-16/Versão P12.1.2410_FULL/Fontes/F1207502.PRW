#INCLUDE 'PROTHEUS.CH'

/*/{Protheus.doc} F1207502
Função para tratar os documentos com Pendência de Subordinados Específico.
@author Reinaldo Dias
@since  22/04/2019
@return Nil
@project MAN0000007423048_EF_74
@cliente Rededor
@version P12.1.17
/*/

User Function F1207502()
	Local aArea		:= GetArea()
	Local aCpos     := {"CR_NUM","CR_TIPO","CR_USER","CR_APROV","CR_STATUS","CR_TOTAL","CR_EMISSAO"}
	Local aHeadCpos := {}
	Local aHeadSize := {}
	Local aArraySCR	:= {}
	Local aCampos   := {}
	Local aCombo    := {}
	Local cAliasSCR := "SCR"
	Local cAprov    := ""
	Local cUserName := ""   
	Local cUsrApvSup:= "" 
	Local cUser     := RetCodUsr()
	Local nX        := 0
	Local nOpc      := 0
	Local nOk       := 0
	Local nRegSak   := 0
	Local oOk		:= LoaDBitMap(GetResources(), "LBOK")
	Local oNo		:= LoaDBitMap(GetResources(), "LBNO")
	Local oDlg
	Local oQual
	

	If Type("aIndexSCR") <> "U"	
		DBClearFilter()
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta o Header com os titulos do TWBrowse             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	AADD(aHeadCpos," ") //Utilizado para o Marca/Desmarca
	AADD(aHeadSize,01) //Utilizado para o Marca/Desmarca
	
	//Início - Thais Paiva - Compatibilização P27
	//DBSelectArea("SX3")
	//DBSetOrder(2)
	For nx	:= 1 to Len(aCpos)
		If FieldPos(aCpos[nx]) > 0
		//If MsSeek(aCpos[nx])
			//AADD(aHeadCpos,AllTrim(X3Titulo()))
			//AADD(aHeadSize,CalcFieldSize(SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_PICTURE,X3Titulo()))
			//AADD(aCampos,{SX3->X3_CAMPO,SX3->X3_TIPO,SX3->X3_CONTEXT,SX3->X3_PICTURE})
			AADD(aHeadCpos,AllTrim(GetSx3Cache(aCpos[nx], 'X3_TITULO')))
			AADD(aHeadSize,CalcFieldSize(Alltrim(GetSx3Cache(aCpos[nx], 'X3_TIPO')),;
										 GetSx3Cache(aCpos[nx], 'X3_TAMANHO'),;
										 GetSx3Cache(aCpos[nx], 'X3_DECIMAL'),;
										 Alltrim(GetSx3Cache(aCpos[nx], 'X3_PICTURE')),;
										 Alltrim(GetSx3Cache(aCpos[nx], 'X3_TITULO'))))
			AADD(aCampos,{GetSx3Cache(aCpos[nx], 'X3_CAMPO'),;
			              GetSx3Cache(aCpos[nx], 'X3_TIPO'),;
						  GetSx3Cache(aCpos[nx], 'X3_CONTEXT'),;
						  GetSx3Cache(aCpos[nx], 'X3_PICTURE')})
		EndIf
	Next
	//Fim -  Thais Paiva - Compatibilização P27
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Apartir do codigo do usuario do sistema, obtem o codigo|
	//³da cadeia de aprovadores superiores e os aprovadores   ³
	//³ausentes												  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DBSelectArea("SAK")
	DBSetOrder(2)
	DBSeek(xFilial("SAK")+cUser)
	While ( !Eof().And. SAK->AK_FILIAL == xFilial("SAK") .AND. SAK->AK_USER == cUser )
		 nRegSak :=Recno()    
		 cUsrApvSup := SAK->AK_COD
		 DBSetOrder(3) // AK_FILIAL+AK_APROSUP
		 DBSeek(cSeek:=xFilial("SAK")+cUsrApvSup)
		 While ( !Eof().And. SAK->AK_FILIAL+SAK->AK_APROSUP == cSeek )
			 AADD(aCombo,SAK->AK_COD+" - "+SAK->AK_NOME)
			 SAK->(DBSkip())
		 EndDo
		 DBSetOrder(2)
		 DBgoto(nRegSak)  
		 SAK->(DBSkip())
	EndDo                        
				   
	cUsrApvSup := ""

	If Len(aCombo) > 0
		
		fAprov(cAliasSCR,Substr(aCombo[1],1,6),@aArraySCR,aCampos,aCombo)
		
		DEFINE MSDIALOG oDlg FROM 000,000 TO 400,780 TITLE "Transferência por Ausência Temporária de Aprovadores" PIXEL  
		@ 001,001  TO 050,425 LABEL "" OF oDlg PIXEL
		
		@ 012,006 Say "Aprovador Ausente " OF oDlg PIXEL SIZE 080,009  
		@ 012,058 MSCOMBOBOX cAprov ITEMS aCombo SIZE 250,090 WHEN .T. VALID fAprov(cAliasSCR,cAprov,@aArraySCR,aCampos,aCombo,oQual) OF oDlg PIXEL
		
		@ 030,006 Say "Aprovador Superior" OF oDlg PIXEL SIZE 080,009   
		@ 030,058 MSGET cUserName : = (trim(A097UsuSup(cAprov))+If(Len(aCombo)>1,"   "+"Atenção: existe mais de um Aprovador Ausente para o Aprovador Superior","")) When .F. SIZE 250,009 OF oDlg PIXEL   
		
		oQual:= TWBrowse():New( 051,001,389,133,,aHeadCpos,aHeadSize,oDlg,,,,,,,,,,,,.F.,,.T.,,.F.,,,)
		oQual:SetArray(aArraySCR)
		oQual:bLDBlClick := { || aArraySCR[oQual:nAT,1] := !aArraySCR[oQual:nAT,1] }
		oQual:bLine := {|| { If(aArraySCR[oQual:nAT,1],oOk,oNo),aArraySCR[oQual:nAT,2],aArraySCR[oQual:nAT,3],aArraySCR[oQual:nAT,4],aArraySCR[oQual:nAT,5],aArraySCR[oQual:nAT,6],aArraySCR[oQual:nAT,7],aArraySCR[oQual:nAT,8] }}

		@ 187,190 BUTTON "Marca Todos"     SIZE 043,011 FONT oDlg:oFont ACTION (aEval( aArraySCR, {|x| x[1] := .T. }),oQual:Refresh())  OF oDlg PIXEL  
		@ 187,240 BUTTON "Desmarca Todos"  SIZE 043,011 FONT oDlg:oFont ACTION (aEval( aArraySCR, {|x| x[1] := .F. }),oQual:Refresh())  OF oDlg PIXEL  
		@ 187,290 BUTTON "Transferir"      SIZE 043,011 FONT oDlg:oFont ACTION (nOpc:=1,oDlg:End())  OF oDlg PIXEL  
		@ 187,340 BUTTON "Cancelar  "      SIZE 043,011 FONT oDlg:oFont ACTION (nOpc:=2,oDlg:End())  OF oDlg PIXEL  
		
		ACTIVATE MSDIALOG oDlg CENTERED

		If nOpc == 1 
			cUsrApvSup:=Substr(cUserName,1,6)

			If Len(aArraySCR) > 0
		 
				nOk := Aviso("Atenção!","Ao confirmar este processo todas aprovações pendentes selecionadas do aprovador serão transferidas ao aprovador superior. Confirma a Transferência ? ",{"Cancelar","Confirma"},2) 
		
				If  nOk == 2  // Confirma a transferencia
					For nX := 1 To Len(aArraySCR)
						IF aArraySCR[nX,1]
							DBSelectArea("SCR")                
							DBGoTo(aTail(aArraySCR[nX]))
							Begin Transaction
							  MaAlcDoc({SCR->CR_NUM,SCR->CR_TIPO,,cUsrApvSup,cUser,,,SCR->CR_MOEDA,SCR->CR_TXMOEDA,,"Tranferido por Ausencia"},,2)  
							End Transaction
						Endif 		
					Next nX
				EndIf 
			Else
				Aviso("F1207502","Não existem registros para serem transferidos",{"&Ok"}) //         
			EndIf
		EndIf	
	Else
		Aviso("F1207502","Para utilizar esta opção é necessário que exista no mínimo um aprovador com um superior cadastrado",{"&Ok"}) //
	EndIf

	If Type("cXFiltraSCR") <> "U"
		set filter to  &(cXFiltraSCR)
	EndIf

	RestArea(aArea)	
	
Return Nil


/*
{Protheus.doc} fAprov
Função para montar o array aArraySCR.
@Author  Fabrica de Software
@Since   24/04/2019
@project MAN0000007423048_EF_74
@Return  Nil
*/
Static Function fAprov(cAliasSCR,cAprov,aArraySCR,aCampos,aCombo,oQual)
	Local aStruSCR := {}
	Local cQuery   := ""
	Local nX       := 0
	Local oOk	   := LoaDBitMap(GetResources(), "LBOK")
	Local oNo	   := LoaDBitMap(GetResources(), "LBNO")

	DBSelectArea("SCR")
	DBSetOrder(1)

	aStruSCR  := SCR->(DBStruct())
	cAliasSCR := "QRYSCR"

	cQuery := "SELECT *"
	cQuery += "FROM "+RetSqlName("SCR")+" "
	cQuery += "WHERE CR_FILIAL='"+xFilial("SCR")+"' AND "
	cQuery += "CR_APROV='"+Substr(cAprov,1,6)+"' AND ( CR_STATUS='02' OR CR_STATUS='04' ) AND "
	cQuery += "D_E_L_E_T_ = ' ' "
	cQuery += "ORDER BY "+SqlOrder(SCR->(IndexKey()))
	cQuery := ChangeQuery(cQuery)
	DBUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSCR)

	For nX := 1 To len(aStruSCR)
		If aStruSCR[nX,2] <> "C" .And. FieldPos(aStruSCR[nX,1])<>0
			TcSetField(cAliasSCR,aStruSCR[nX,1],aStruSCR[nX,2],aStruSCR[nX,3],aStruSCR[nX,4])
		EndIf
	Next nX

	DBSelectArea(cAliasSCR)

	aArraySCR := {}

	While !(cAliasSCR)->(Eof()) .And. (cAliasSCR)->CR_FILIAL == xFilial("SCR") 
		
		Aadd(aArraySCR,Array(Len(aCampos)+2))

		aArraySCR[Len(aArraySCR),1] := .F.

		For nX := 1 To Len(aCampos)
			If Substr(aCampos[nX,1],1,2) == "CR"
				If aCampos[nX,2] == "N"
					aArraySCR[Len(aArraySCR),nX+1] := Transform((cAliasSCR)->(FieldGet(FieldPos(aCampos[nX,1]))),PesqPict("SCR",aCampos[nX,1]))
				Else
					aArraySCR[Len(aArraySCR),nX+1] := (cAliasSCR)->(FieldGet(FieldPos(aCampos[nX,1])))
				Endif
			EndIf
		Next nX

		aTail(aTail(aArraySCR)) := (cAliasSCR)->R_E_C_N_O_
		
		(cAliasSCR)->(DBSkip())
		
	EndDo

	If Len(aArraySCR) == 0
		aArraySCR := {{.F.,"","","","","",0,""}}
	EndIf

	If oQual <> Nil
		oQual:SetArray(aArraySCR)
		oQual:bLine := {|| { If(aArraySCR[oQual:nAT,1],oOk,oNo),aArraySCR[oQual:nAT,2],aArraySCR[oQual:nAT,3],aArraySCR[oQual:nAT,4],aArraySCR[oQual:nAT,5],aArraySCR[oQual:nAT,6],aArraySCR[oQual:nAT,7],aArraySCR[oQual:nAT,8] }}
		oQual:Refresh()
	EndIf

	DBSelectArea(cAliasSCR)
	DBCloseArea()

Return Nil