#Include 'Protheus.ch' 
 
// ###########################################################################################
// Projeto:
// Modulo :
// Função : 
// -----------+-------------------+-----------------------------------------------------------
// Data       | Autor             | Descricao
// -----------+-------------------+-----------------------------------------------------------
// 18/05/2017 | Miqueias Dernier  | Monta tela de amarração Módulos x Tabelas 
//            |                   |
// -----------+-------------------+-----------------------------------------------------------
Static nPosMod
Static aTabsBkp

User Function RDDA004()
Local aObjects, aSize, aObjects, aInfo, aPosObj, oDlg
Local aField := {}
Local aButtons := {}
Local lConfirma := .F.
Local aCols1 := {} //Array com as linhas do grid de Módulos
Local aCols2 := {} //Array com as linhas do grid de Tabelas
Local aAlter := {}
Local aHeader1,aHeader2
Local oGrp1,oGrp2,oGrp3,oGrp4,oGrp5
Local cGetMarca, oGetMarca
Local cGetPesq, oGetPesq
Local cTextTab

Private oMSNewGe1,oMSNewGe2

Private aTabelas := {}

Private oOk       		:= LoadBitmap( GetResources(), "LBOK" )
Private oNo       		:= LoadBitmap( GetResources(), "LBNO" )


Aadd( aButtons, {"Salva", {|| Salva(oMsNewGe1:aCols)}, "Salvando...", "Salva" , {|| .T.}} )

//+-----------------------------------------------+
//¦ Montando aHeader para a Getdados              ¦
//+-----------------------------------------------+
aHeader1:={}
//Início - Thais Paiva - Compatibilização P27
//dbSelectArea("SX3")
//dbSetOrder(2)
AADD(aHeader1,{ "Código",'X_CODMOD',;
	'',2,0,;
	'00','',;
	'N', '', '' } )

//Z1_MODULO
/*If dbSeek("Z1_MODULO")
	AADD(aHeader1,{ TRIM(x3_titulo),x3_campo,;
		x3_picture,x3_tamanho,x3_decimal,;
		X3_VLDUSER,x3_usado,;
		x3_tipo, x3_f3, x3_context } )
EndIf*/
AADD(aHeader1,{ AllTRIM(GetSx3Cache("Z1_MODULO", 'X3_TITULO')),GetSx3Cache("Z1_MODULO", 'X3_CAMPO'),;
		GetSx3Cache("Z1_MODULO", 'X3_PICTURE'),GetSx3Cache("Z1_MODULO", 'X3_TAMANHO'),GetSx3Cache("Z1_MODULO", 'X3_DECIMAL'),;
		GetSx3Cache("Z1_MODULO", 'X3_VLDUSER'),GetSx3Cache("Z1_MODULO", 'X3_USADO'),;
		GetSx3Cache("Z1_MODULO", 'X3_TIPO'), GetSx3Cache("Z1_MODULO", 'X3_F3'),GetSx3Cache("Z1_MODULO", 'X3_CONTEXT')} )
//Fim - Thais Paiva - Compatibilização P27

AADD(aHeader1,{ "Descrição",'X_MODDESC',;
	'',15,0,;
	'','',;
	'C', '', '' } )

//Popula o aCols dos módulos
aCols1 := PegaMods()

//+-----------------------------------------------+
//¦ Montando aHeader para a Getdados              ¦
//+-----------------------------------------------+
aHeader2:={}
aAdd(aHeader2, {' ', 'SELECAO', '@BMP', 1, 0, '',, 'C',,,,,, 'V',,, .F.})
//Início - Thais Paiva - Compatibilização P27
//dbSelectArea("SX3")
//dbSetOrder(2)
//Z1_TABELA
/*If dbSeek("Z1_TABELA")
	AADD(aHeader2,{ TRIM(x3_titulo),x3_campo,;
		x3_picture,x3_tamanho,x3_decimal,;
		X3_VLDUSER,x3_usado,;
		x3_tipo, x3_f3, x3_context } )
EndIf*/
AADD(aHeader2,{ AllTRIM(GetSx3Cache("Z1_TABELA", 'X3_TITULO')),GetSx3Cache("Z1_TABELA", 'X3_CAMPO'),;
		GetSx3Cache("Z1_TABELA", 'X3_PICTURE'),GetSx3Cache("Z1_TABELA", 'X3_TAMANHO'),GetSx3Cache("Z1_TABELA", 'X3_DECIMAL'),;
		GetSx3Cache("Z1_TABELA", 'X3_VLDUSER'),GetSx3Cache("Z1_TABELA", 'X3_USADO'),;
		GetSx3Cache("Z1_TABELA", 'X3_TIPO'), GetSx3Cache("Z1_TABELA", 'X3_F3'),GetSx3Cache("Z1_TABELA", 'X3_CONTEXT') } )
//Fim - Thais Paiva - Compatibilização P27
AADD(aHeader2,{ "Descrição",'X_TABDESC',;
	'',15,0,;
	'','',;
	'C', '', '' } )

//Popula aCols das tabelas
aTabelas := CargaTabs(aCols1)


//Monta Tela
aObjects := {}
aSize := {0,30,674.5,301.5,1349,603,0}//MsAdvSize(.t.)//Posições da Dialog//

AAdd(aObjects,{100,100,.T.,.T.,.F.})
AAdd(aObjects,{55,100,.t.,.t.,.F.})
AAdd(aObjects,{100,100,.t.,.t.,.F.})

aInfo := {aSize[1],aSize[2],aSize[3],aSize[4],15,10}
aPosObj := MsObjSize(aInfo,aObjects,.T.,.T.)
oDlg:=MSDialog():New(aSize[1],aSize[2],aSize[6],aSize[5],'Módulos x Tabelas',,,,,CLR_BLACK,CLR_WHITE,,,.T.)

oGrp1 := TGroup():New(aPosObj[1,1], aPosObj[1,2], aPosObj[1,3], aPosObj[1,4], 'Módulos', oDlg,,, .T.)
aCols2 := PegaTabs()
SyncArr(@aCols2,aTabelas[1])
oMSNewGe1 := MsNewGetDados():New(aPosObj[1,1], aPosObj[1,2], aPosObj[1,3], aPosObj[1,4],GD_UPDATE , 'AllwaysTrue()', 'AllwaysTrue()', '',aAlter ,, 999, 'AllwaysTrue()', '' , 'AllwaysTrue()', oGrp1, aHeader1, aCols1,{|| nPosMod:= oMsNewGe1:nAt,MudaMod(self,@aCols2,@cTextTab),self:refresh()})
oMSNewGe1:oBrowse:lUseDefaultColors := .F.
oMSNewGe1:oBrowse:SetBlkBackColor({ || ACGetColor(oMSNewGe1:aCols, oMSNewGe1:nAt)})
oMSNewGe1:oBrowse:SetBlkColor({ || ACFontColor(oMSNewGe1:aCols, oMSNewGe1:nAt)})
oMSNewGe1:Refresh()



//oGrp2 := TGroup():New(aPosObj[2,1], aPosObj[2,2], aPosObj[2,3], aPosObj[2,4], 'Pesquisa', oDlg,,, .T.)
cGetPesq := Space(3)
oGetPesq := TGet():New( aPosObj[2,1], aPosObj[2,2],{| u | if( pCount() > 0,cGetPesq := u, cGetPesq )},oDlg,026,009,"@!",,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,,"cGetPesq",,,,,,,'Pesquisa',1,,, )
TButton():New( aPosObj[2,1]+8, aPosObj[2,2]+32, "Pesquisa",oDlg,{|| Pesquisa(cGetPesq,oMsNewGe2) }, 40,10,,,.F.,.T.,.F.,,.F.,,,.F. )


cGetMarca := Space(3)
oGetMarca := TGet():New( aPosObj[2,1]+30, aPosObj[2,2],{| u | if( pCount() > 0,cGetMarca := u, cGetMarca )},oDlg,026,009,"@!",,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,,cGetMarca,,,,,,,'Marcar/Desmarcar por máscara (???)',1,,,'???' )
TButton():New( aPosObj[2,1]+30+8, aPosObj[2,2]+32, "Marcar",oDlg,{|| MarcaDesm(@oMsNewGe2:aCols,cGetMarca,@cTextTab,.T.)}, 40,10,,,.F.,.T.,.F.,,.F.,,,.F. )
TButton():New( aPosObj[2,1]+30+8, aPosObj[2,2]+36+43, "Desmarcar",oDlg,{|| MarcaDesm(@oMsNewGe2:aCols,cGetMarca,@cTextTab,.F.)}, 40,10,,,.F.,.T.,.F.,,.F.,,,.F. )

oGrp3 := TGroup():New(aPosObj[3,1], aPosObj[3,2], aPosObj[3,3]-100, aPosObj[3,4], 'Tabelas', oDlg,,, .T.)

oMSNewGe2 := MsNewGetDados():New(aPosObj[3,1], aPosObj[3,2], aPosObj[3,3]-100, aPosObj[3,4],GD_UPDATE , 'AllwaysTrue()', 'AllwaysTrue()', '',aAlter ,, 999, 'AllwaysTrue()', '' , 'AllwaysTrue()', oGrp3, aHeader2, aCols2)
oMSNewGe2:oBrowse:blDblClick:={|| oMsNewGe2:aCols[oMsNewGe2:nAt,1] := If(oMsNewGe2:aCols[oMsNewGe2:nAt,1]==oOk,oNo,oOk),oMsNewGe2:Refresh(),SyncTexto(@oMsNewGe2:aCols,@cTextTab,oMsNewGe1:nAt),oTMultiget1:Refresh() }

oGrp4 := TGroup():New(aPosObj[3,3]-90, aPosObj[3,2], aPosObj[3,3], aPosObj[3,4], 'Tabelas', oDlg,,, .T.)

cTextTab := aTabelas[1]
oTMultiget1 := tMultiget():new(aPosObj[3,3]-90, aPosObj[3,2],{| u | if( pCount() > 0,( cTextTab := u), cTextTab )},oDlg,aPosObj[3,4]-(aPosObj[3,2]),aPosObj[3,3]-(aPosObj[3,3]-90),,,,,,.T.,,,,,,.T.)
//oTMultiget1:bWhen := {|| SyncArr(@aCols,@cTexto)}

ACTIVATE MSDIALOG oDlg CENTERED on init (EnchoiceBar(oDlg,{|| lConfirma:=.T.,oDlg:End()},{|| lConfirma:=.F., oDlg:End()},,@aButtons))

If lConfirma
	Salva(oMsNewGe1:aCols)
EndIf


Return


// ###########################################################################################
// Projeto:
// Modulo :
// Função : 
// -----------+-------------------+-----------------------------------------------------------
// Data       | Autor             | Descricao
// -----------+-------------------+-----------------------------------------------------------
// 18/05/2017 | Miqueias Dernier  | Alimenta aCols com a lista de módulos disponíveis no sistema 
//            |                   |
// -----------+-------------------+-----------------------------------------------------------
Static Function PegaMods()
Local aModulos := RetModName()
Local nI
Local aCols := {}

For nI:=1 To Len(aModulos)
	If aModulos[nI,4]
		AAdd(aCols,{aModulos[nI,1],aModulos[nI,2],aModulos[nI,3],.F.})
	EndIf
Next

Return aCols


// ###########################################################################################
// Projeto:
// Modulo :
// Função : 
// -----------+-------------------+-----------------------------------------------------------
// Data       | Autor             | Descricao
// -----------+-------------------+-----------------------------------------------------------
// 18/05/2017 | Miqueias Dernier  | Alimenta aCols com a lista de tabelas disponíveis no sistema 
//            |                   |
// -----------+-------------------+-----------------------------------------------------------
Static Function PegaTabs()
Local aArea := GetArea()
Local aAreaSX2
Local nI
Local aCols := {}

//Início - Thais Paiva - Compatibilização P27
OpenSxs(,,,,cEmpAnt,"SX2TAB","SX2",,.F.)
//dbSelectArea("SX2")
//aAreaSX2 := GetArea()
//dbSetOrder(1)
//SX2->(dbGoTop())
//While SX2->(!EoF())
If Select("SX2TAB") > 0
	While SX2TAB->(!EOF())
		// Itens a serem executados caso o dicionário seja aberto com sucesso
		//AAdd(aCols, {oNo, SX2->X2_CHAVE,SX2->X2_NOME, .F.})
		AAdd(aCols, {oNo, SX2TAB->&(X2_CHAVE),SX2TAB->&(X2_NOME), .F.})
		//SX2->(dbSkip())
		SX2TAB->(dbSkip())
	EndDo
EndIf
 //Fim - Thais Paiva - Compatibilização P27

RestArea(aAreaSX2)
RestArea(aArea)
Return aCols

// ###########################################################################################
// Projeto:
// Modulo :
// Função : 
// -----------+-------------------+-----------------------------------------------------------
// Data       | Autor             | Descricao
// -----------+-------------------+-----------------------------------------------------------
// 23/05/2017 | Miqueias Dernier  | Atualiza variável cTexto de acordo com o aCols da lista de  
//            |                   | tabelas.
// -----------+-------------------+-----------------------------------------------------------
Static Function SyncTexto(aCols,cTexto,nAt)
Local nI

cTexto := ""
For nI:=1 To Len(aCols)
	If aCols[nI,1] == oOk 
		cTexto += aCols[nI,2] + " "
	EndIf
Next


//Mantém a ordem
//For nI:=1 To Len(aCols)
//	If aCols[nI,1] == oOk 
//		If !(aCols[nI,2] + " " $ cTexto)
//			cTexto += aCols[nI,2] + " "
//		EndIf
//	Else
//		cTexto := StrTran(cTexto,aCols[nI,2] + " ")
//	EndIf
//Next

aTabelas[nAt] := cTexto

Return

// ###########################################################################################
// Projeto:
// Modulo :
// Função : 
// -----------+-------------------+-----------------------------------------------------------
// Data       | Autor             | Descricao
// -----------+-------------------+-----------------------------------------------------------
// 23/05/2017 | Miqueias Dernier  | Atualiza as marcações da lista de tabelas baseada na string
//            |                   | passada
// -----------+-------------------+-----------------------------------------------------------
Static Function SyncArr(aCols,cTexto)
Local nI

For nI:=1 To Len(aCols)
	If aCols[nI,2]+" " $ cTexto
		aCols[nI,1] := oOk
	Else
		aCols[nI,1] := oNo
	EndIf
Next
Return aCols

// ###########################################################################################
// Projeto:
// Modulo :
// Função : 
// -----------+-------------------+-----------------------------------------------------------
// Data       | Autor             | Descricao
// -----------+-------------------+-----------------------------------------------------------
// 23/05/2017 | Miqueias Dernier  | Posiciona getdados das tabelas 
//            |                   |
// -----------+-------------------+-----------------------------------------------------------
Static Function Pesquisa(cPesq,oGetDados)
Local aCols := oGetDados:aCols
Local nPos := ASCan(aCols,{|x| x[2]=RTrim(cPesq)})
If nPos>0
	oGetDados:GoTo(nPos)
EndIf

Return

// ###########################################################################################
// Projeto:
// Modulo :
// Função : 
// -----------+-------------------+-----------------------------------------------------------
// Data       | Autor             | Descricao
// -----------+-------------------+-----------------------------------------------------------
// 23/05/2017 | Miqueias Dernier  | Popula array com todas as tabelas marcadas por módulo 
//            |                   | em formato de string
// -----------+-------------------+-----------------------------------------------------------
Static Function CargaTabs(aColsMod)
Local aTabelas := {}
Local nI
Local aCols
Local cModulo
Local nPos
Local cQryAlias
Local cQuery := ""

For nI:=1 To Len(aColsMod)
	cModulo := aColsMod[nI,2]
	cTabelas := GetTabs(cModulo)
	AAdd(aTabelas,cTabelas)
Next
aTabsBkp := AClone(aTabelas)
Return aTabelas

// ###########################################################################################
// Projeto:
// Modulo :
// Função : 
// -----------+-------------------+-----------------------------------------------------------
// Data       | Autor             | Descricao
// -----------+-------------------+-----------------------------------------------------------
// 23/05/2017 | Miqueias Dernier  | Recupera da base de dados (SZ1) as tabelas associadas ao módulo 
//            |                   |
// -----------+-------------------+-----------------------------------------------------------
Static Function GetTabs(cModulo)
Local cRet := ""
Local cQryAlias
Local cQuery := ""

cQuery += " SELECT * FROM "+RetFullName("SZ1")+" SZ1 "+CRLF
cQuery += " 	WHERE SZ1.D_E_L_E_T_=' ' AND Z1_FILIAL = '"+XFilial("SZ1")+"' "+CRLF
cQuery += " 		AND Z1_MODULO = '"+cModulo+"' "+CRLF

cQuery := ChangeQuery(cQuery)
dbUseArea(.T.,'TOPCONN', TCGenQry(,,cQuery),(cQryAlias:=GetNextAlias()), .F., .T.)
While (cQryAlias)->(!Eof())
	cRet += (cQryAlias)->Z1_TABELA+" "
	(cQryAlias)->(dbSkip())
EndDo
(cQryAlias)->(dbCloseArea())

Return cRet

// ###########################################################################################
// Projeto:
// Modulo :
// Função : 
// -----------+-------------------+-----------------------------------------------------------
// Data       | Autor             | Descricao
// -----------+-------------------+-----------------------------------------------------------
// 23/05/2017 | Miqueias Dernier  | Atualiza getdados de tabelas com as tabelas do módulo 
//            |                   | posicionado.
// -----------+-------------------+-----------------------------------------------------------
Static Function MudaMod(self,aCols2,cTextTab)
cTextTab:=aTabelas[self:nAt]
aCols2 := SyncArr(@aCols2,@cTextTab)
oMsNewGe2:aCols := aCols2
oMsNewGe2:Refresh()
oTMultiget1:Refresh()
Return

// ###########################################################################################
// Projeto:
// Modulo :
// Função : 
// -----------+-------------------+-----------------------------------------------------------
// Data       | Autor             | Descricao
// -----------+-------------------+-----------------------------------------------------------
// 23/05/2017 | Miqueias Dernier  | Compara máscara com a tabela passados por parâmetro. 
//            |                   | Retorna True ou False. A comparação é feita considerando o caracter '?'
//            |                   | como curinga
// -----------+-------------------+-----------------------------------------------------------
Static Function CompMask(cMask,cTab)
Local lRet := .T.
Local nJ
Local cC

For nJ:=1 To Len(cTab)
	If lRet
		c1Mask := SubStr(cMask,nJ,1)
		c1Tab := SubStr(cTab,nJ,1)
		lRet := (c1Mask == '?' .And. !Empty(c1Tab)) .Or. (c1Mask  == c1Tab)
	Else
		exit
	EndIf
Next
Return lRet

// ###########################################################################################
// Projeto:
// Modulo :
// Função : 
// -----------+-------------------+-----------------------------------------------------------
// Data       | Autor             | Descricao
// -----------+-------------------+-----------------------------------------------------------
// 23/05/2017 | Miqueias Dernier  | Marca/desmarca as tabelas que correspondem à máscara passada  
//            |                   |
// -----------+-------------------+-----------------------------------------------------------
Static Function MarcaDesm(aCols,cMask,cTexto,lMarca)
Local oObj := If(lMarca,oOk,oNo)
Local nI

For nI:=1 To Len(acols)
	If !(aCols[nI,1] == oObj) .And. CompMask(cMask,aCols[nI,2])
		aCols[nI,1] := oObj
	EndIf
Next

SyncTexto(aCols,@cTexto,oMsNewGe1:nAt)
oMsNewGe2:Refresh()
oTMultiget1:Refresh()
Return


// ###########################################################################################
// Projeto: Bloco K
// Modulo :
// Função : 
// -----------+-------------------+-----------------------------------------------------------
// Data       | Autor             | Descricao
// -----------+-------------------+-----------------------------------------------------------
// 26/11/2015 | Miqueias Dernier  | Define as cores das linhas do Grid
//            |                   |
// -----------+-------------------+-----------------------------------------------------------
Static Function ACGetColor(aLinha, nLinha)
Local nRet
Local nCor1 := omsnewge1:obrowse:nclrforefocus	// Azul RGB(178,203,231)//
Local nCor2 := RGB(245,245,245)	// Branco
Local nCor3 := RGB(186,222,158)	// Verde
Local nCor4 := RGB(255,255,145)	// Amarelo
Local nCor5 := RGB(200,200,200) // Cinza
Local nCor6 := RGB(138,43,226) // Roxo 
Local nCorPar
Local nCorImpar 

nCorPar := nCor1
nCorImpar := nCor2

If Mod(nLinha,2)>0
	nRet := nCorImpar
Else
	nRet := nCorPar
EndIf


If nLinha == nPosMod
	nRet := nCor6
EndIf

Return(nRet)


// ###########################################################################################
// Projeto: Bloco K
// Modulo :
// Função : 
// -----------+-------------------+-----------------------------------------------------------
// Data       | Autor             | Descricao
// -----------+-------------------+-----------------------------------------------------------
// 26/11/2015 | Miqueias Dernier  | Define as cores das linhas do Grid
//            |                   |
// -----------+-------------------+-----------------------------------------------------------

Static Function ACFontColor(aLinha, nLinha)
Local nRet
Local nCor1 := omsnewge1:obrowse:nclrforefocus	// Azul
Local nCor2 := RGB(255,255,255)	// Branco
Local nCor3 := RGB(186,222,158)	// Verde
Local nCor4 := RGB(255,255,145)	// Amarelo
Local nCor5 := RGB(200,200,200) // Cinza
Local nCor6 := RGB(138,43,226) // Roxo 
Local nCor7 := RGB(000,000,000) // Preto 

Local nCorPar
Local nCorImpar 

nCorPar := nCor7
nCorImpar := nCor7

If Mod(nLinha,2)>0
	nRet := nCorImpar
Else
	nRet := nCorPar
EndIf


If nLinha == nPosMod
	nRet := nCor2
EndIf

Return(nRet)

// ###########################################################################################
// Projeto:
// Modulo :
// Função : 
// -----------+-------------------+-----------------------------------------------------------
// Data       | Autor             | Descricao
// -----------+-------------------+-----------------------------------------------------------
// 23/05/2017 | Miqueias Dernier  | Salva na SZ1 todas as marcações feitas em memória 
//            |                   |
// -----------+-------------------+-----------------------------------------------------------
Static Function Salva(aColsMod)
Local nI

For nI:=1 To Len(aTabelas)
	If !(aTabelas[nI] == aTabsBkp[nI])
		SalvaText(aTabelas[nI],aColsMod[nI,2])
	EndIf
Next
Return

// ###########################################################################################
// Projeto:
// Modulo :
// Função : 
// -----------+-------------------+-----------------------------------------------------------
// Data       | Autor             | Descricao
// -----------+-------------------+-----------------------------------------------------------
// 23/05/2017 | Miqueias Dernier  | Função auxiliar. Salva cada módulo passada na SZ1 
//            |                   |
// -----------+-------------------+-----------------------------------------------------------
Static Function SalvaText(cTexto,cMod)
Local nI
Local aTabs := StrTokArr(cTexto,' ')

dbSelectArea("SZ1")
dbSetOrder(1)

For nI:=1 To Len(aTabs)
	If !Empty(aTabs[nI]) .And. !dbSeek(XFilial("SZ1")+PADR(cMod,TAMSX3('Z1_MODULO')[1])+PADR(aTabs[nI],TAMSX3('Z1_TABELA')[1]))
		RecLock("SZ1",.T.)
		SZ1->Z1_FILIAL := XFilial("SZ1")
		SZ1->Z1_MODULO := cMod
		SZ1->Z1_TABELA := aTabs[nI]
		SZ1->(MSUnlock())
	EndIf
Next

If SZ1->(dbSeek(XFilial("SZ1")+PADR(cMod,TAMSX3("Z1_MODULO")[1])))
	While SZ1->(!EoF()) .And. SZ1->(Z1_FILIAL+Z1_MODULO) == XFilial("SZ1")+PADR(cMod,TAMSX3('Z1_MODULO')[1])
		If !(SZ1->Z1_TABELA $ cTexto)
			RecLock("SZ1",.F.)
			SZ1->(dbDelete())
			SZ1->(MSUnlock())
		EndIf
		SZ1->(dbSkip())
	EndDo 
EndIf
Return

// ###########################################################################################
// Projeto:
// Modulo :
// Função : 
// -----------+-------------------+-----------------------------------------------------------
// Data       | Autor             | Descricao
// -----------+-------------------+-----------------------------------------------------------
// 07/08/2017 | Miqueias Dernier  | 
//            |                   |
// -----------+-------------------+-----------------------------------------------------------
Static Function MenuDef()
PRIVATE aRotina := {{"Altera","U_RDDA004"	, 0 , 4, 0 , nil}}

Return(aRotina)
