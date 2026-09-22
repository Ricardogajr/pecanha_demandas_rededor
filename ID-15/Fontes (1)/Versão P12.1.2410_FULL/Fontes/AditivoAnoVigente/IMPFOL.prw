#INCLUDE "IMPFOL.ch"
#INCLUDE "PROTHEUS.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³AE_IMPFOL º Autor ³ Roberto Sidney     º Data ³  27/12/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Importa usuarios do modulo folha caso o cliente utilize.	  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Clientes que utilizam a folha microsiga e o template		  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function AE_IMPFOL()
Local cMens:=Space(200)
Local cMens1:=Space(200) 
Local oSection        

Private _cPerg := "IMPFUN"
Private lCargos := .F.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de Variaveis                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ChkTemplate("CDV")  

cMens1:=STR0001 //"Deseja importar a tabela de cargos do módulo de folha de pagamento da Microsiga "
cMens1+=STR0002 //"antes de importar os colaboradores ?"

If MsgYesNo(cMens1,STR0003) //"IMPORTAR CARGOS"
	Processa({||U_ProcCargos()})
Endif 

cMens:=STR0004 //"Esta rotina importa o cadastro de funcionarios do modulo de folha de pagamento da Microsiga para "
cMens+=STR0005 //"o cadastro de usuarios de viagem. Confirma IMPORTACAO?"

If Pergunte(_cPerg,.T.)
    
	If MsgYesNo(cMens,STR0006) //"MANUTENCAO DE USUARIOS"
		Processa({||U_ProcUser()})
	Endif

Endif
Return(.T.)

/**********************************************************************/
User Function ProcUser()
Local lVazio	:=.T.
Local _cMens	:= ""
Local lAchou 	:= .F.  
Local cAliasFIN	:= ""
Local nTotREG	:= 0
Local cArq		:= Nil
Local aArea		:= GetArea()
Local cCond		:= ""
Local aCampos	:= {}
//#IFDEF TOP
	Local nReg		:= 1
	Local cSitQuery	:= "" 
	Local cQuery	:= ""
	Local aSelFil := {}
	Local cInFilial := ""
//#ENDIF              

Private cSituacao  := mv_par01							// Situacao
Private cAlias		:= "SRA"

ChkTemplate("CDV")
// AjustaSx3()         
//Montando matriz compatibilizadora de tamanho de campos



aAdd(aCampos,{"LHT_CODMAT",TamSX3("LHT_CODMAT")[1]})
aAdd(aCampos,{"LHT_FILMAT",TamSX3("LHT_FILMAT")[1]})
aAdd(aCampos,{"LHT_NOME",TamSX3("LHT_NOME")[1]})
aAdd(aCampos,{"LHT_BCDEPS",TamSX3("LHT_BCDEPS")[1]})
aAdd(aCampos,{"LHT_CTDEPS",TamSX3("LHT_CTDEPS")[1]})
aAdd(aCampos,{"LHT_SITFOL",TamSX3("LHT_SITFOL")[1]})
aAdd(aCampos,{"LHT_EMAIL",TamSX3("LHT_EMAIL")[1]})
aAdd(aCampos,{"LHT_CC",TamSX3("LHT_CC")[1]})
aAdd(aCampos,{"LHT_CARGO",TamSX3("LHT_CARGO")[1]})
aAdd(aCampos,{"LHT_CARGO",TamSX3("LHT_CARGO")[1]})
aAdd(aCampos,{"LHT_FLAGAP",TamSX3("LHT_FLAGAP")[1]})
aAdd(aCampos,{"LHT_APFIN",TamSX3("LHT_APFIN")[1]})
aAdd(aCampos,{"LHT_LIMDES",TamSX3("LHT_LIMDES")[1]})
//#IFDEF TOP
	If FindFunction("AdmSelctGC") .And. AdmSelctGC()
	  aSelFil := FwSelectGC()
	Else
	  aSelFil := AdmGetFil(.F.,.F.,"SRA")
	EndIf
	If Empty( aSelFil )
		Return (.T.)
	EndIf
	aEval( aSelFil , { |aTst| cInFilial += aTst + "|" } )
	For nReg := 1 to Len(cSituacao)
		cSitQuery += "'" + Subs(cSituacao,nReg,1) + "'"
		If (nReg + 1) <= Len(cSituacao)
			cSitQuery += "," 
		Endif
	Next nReg     
	cAliasFIN 	:= "QrySRA"
	cQuery 		:= "SELECT RA_FILIAL,RA_CC,RA_MAT,RA_NOME,RA_SITFOLH,RA_BCDEPSA,RA_CTDEPSA,RA_EMAIL,RA_ESTADO,RA_MUNICIP,RA_CARGO "
	cQuery 		+= " FROM "+ RetSqlName("SRA") + " SRA "
	cQuery 		+= " WHERE RA_SITFOLH IN (" + Upper(cSitQuery) + ") "	
	cQuery			+= " AND RA_FILIAL IN " + FormatIn( Substr( cInFilial , 1 , Len( cInFilial ) - 1 ) , "|" )
	If TcSrvType() == "AS/400"
		cQuery += " AND SRA.@DELETED@ = ' ' "
	Else
		cQuery += " AND SRA.D_E_L_E_U_ = ' ' "
	Endif
	cQuery 		:= ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasFIN)	
	(cAliasFIN)->(dbGoTop())
	dbEval({||nTotREG++})
//#ELSE             
//	//Transforma parametros do tipo Range em expressao ADVPL para ser utilizada no filtro
//	MakeAdvplExpr("IMPFOL")
//	cAliasFIN := "SRA"
//	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//	//³ Verifica a ordem selecionada                                             ³
//	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//	If !Empty(cSituacao)
//	   	cCond += Iif(!Empty(cCond)," .AND. ","")
//	   	cCond += "(SRA->RA_SITFOLH  $ '" + cSituacao  + "')"
// 	EndIf           
// 	cArq := CriaTrab(Nil,.F.)
// 	IndRegua(cAliasFIN,cArq,"RA_SITFOLH",,cCond)
// 	dbSelectArea(cAliasFIN)
// 	dbSetIndex(cAliasFIN + OrdBagExt())
// 	(cAliasFIN)->(dbSetOrder(RetIndex(cAliasFIN)+1))
// 	nTotREG := (cAliasFIN)->(RecCount())
//#ENDIF
//Posicionando a tabela LHT e definindo ordem de pesquisa
dbSelectarea("LHT")
LHT->(dbSetOrder(1))
//Posicionando o arquivo de funcionarios e definindo a regua de progressao
dbSelectArea(cAliasFIN)
Procregua(nTotREG)
(cAliasFIN)->(dbGoTop())
While !(cAliasFIN)->(Eof())
	lVazio := .F.           
	lAchou := .F.
	_cChaveLHT := xFilial("LHT") + (cAliasFIN)->RA_MAT
	_cChaveLDY := xFilial("LDY") + (cAliasFIN)->(RA_ESTADO + RA_MUNICIP)
	dbSelectArea("LDY")
	LDY->(dbSetorder(3))
	_cCodMun := "" 
	_cNomeMun:= ""
	IF LDY->(DbSeek(_cChaveLDY))
		_cCodMun := LDY->LDY_CODIGO
		_cNomeMun := LDY->LDY_NOME
	Endif
	//Apenas atualizar situacao de funcionarios demitidos
	If AllTrim((cAliasFIN)->RA_SITFOLH) == "D"
		dbSelectArea("LHT")
		If LHT->(dbSeek(_cChaveLHT))
			Reclock("LHT",.F.)
			LHT->LHT_SITFOL := (cAliasFIN)->RA_SITFOLH
			MsUnlock()
		Endif
	Else
 	  	dbSelectArea("LHT")
		If !LHT->(dbSeek(_cChaveLHT))
			Reclock("LHT",.T.)
			LHT->LHT_FILIAL		:= xFilial("LHT")
			LHT->LHT_CODMAT 	:= Substr((cAliasFIN)->RA_MAT,1,aCampos[aScan(aCampos,{|x|x[1]=="LHT_CODMAT"})][2])
		Else
			Reclock("LHT",.F.)
			lAchou := .T.
		Endif
		LHT->LHT_FILMAT		:= Substr((cAliasFIN)->RA_FILIAL,1,aCampos[aScan(aCampos,{|x|x[1]=="LHT_FILMAT"})][2])
		LHT->LHT_NOME  		:= Substr((cAliasFIN)->RA_NOME,1,aCampos[aScan(aCampos,{|x|x[1]=="LHT_NOME"})][2])
		LHT->LHT_BCDEPS		:= Substr((cAliasFIN)->RA_BCDEPSA,1,aCampos[aScan(aCampos,{|x|x[1]=="LHT_BCDEPS"})][2])
		LHT->LHT_CTDEPS		:= Substr((cAliasFIN)->RA_CTDEPSA,1,aCampos[aScan(aCampos,{|x|x[1]=="LHT_CTDEPS"})][2])
		LHT->LHT_SITFOL		:= Substr((cAliasFIN)->RA_SITFOLH,1,aCampos[aScan(aCampos,{|x|x[1]=="LHT_SITFOL"})][2])
		LHT->LHT_EMAIL		:= Substr((cAliasFIN)->RA_EMAIL,1,aCampos[aScan(aCampos,{|x|x[1]=="LHT_EMAIL"})][2])
		LHT->LHT_CC 		:= Substr((cAliasFIN)->RA_CC,1,aCampos[aScan(aCampos,{|x|x[1]=="LHT_CC"})][2])
		LHT->LHT_CARGO 		:= Substr((cAliasFIN)->RA_CARGO,1,aCampos[aScan(aCampos,{|x|x[1]=="LHT_CARGO"})][2])
		If !lAchou                                  
			LHT->LHT_FLAGAP 	:= "2"
			LHT->LHT_APFIN		:= "2"
			LHT->LHT_LIMDES 	:= "1" 
		EndIf                      
		If lCargos
			LHT->LHT_CARGO := Substr((cAliasFIN)->RA_CARGO,1,aCampos[aScan(aCampos,{|x|x[1]=="LHT_CARGO"})][2])
		EndIf	
		MsUnlock()
	Endif
	(cAliasFIN)->(dbSkip())
	IncProc(STR0007)	 //"Processando......"
Enddo
If lVazio 
	MsgInfo(STR0008, STR0009) //'Nao existem registros no arquivo de funcionarios do modulo folha de pagamentos Microsiga'###'Aviso'
Else
	_cMens:=STR0010 //"Importacao Finalizada. Será necessário atualizar alguns dados no cadastro de colaboradores "
	_cMens+=STR0011 + Chr(13) + Chr(13) //"do template. Deverão ser informados os seguintes dados: "
	_cMens+=STR0012 + Chr(13) //" - Login do sistema Microsiga"
	_cMens+=STR0013 //" - Informar se o colaborador é aprovador"
	MsgInfo(_cMens, STR0009) //'Aviso'
Endif	
//#IFDEF TOP
	If Select(cAliasFIN) # 0
		dbSelectArea(cAliasFIN)
		dbCloseArea()
		fErase(cAliasFIN + OrdBagExt())
		fErase(cAliasFIN + GetDbExtension())
	Endif
//#ELSE
//	fErase(cAliasFIN + OrdBagExt())
//	RetIndex(cAliasFIN)
//#ENDIF
RestArea(aArea)
	
Return(.T.)        

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ ProcCargos   ³ Autor ³ Ricardo A. Canteras	³ Data ³ 23/03/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Importa cargos do modulo folha caso o cliente o utilize.       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ ProcCargos()                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ Clientes que utilizam a folha microsiga e o template.          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function ProcCargos()
Local lVazio:=.T., _cMens, _cMens1,  _cMens2, _cCargo 
Local lAchou := .T., lAltCargo := .F.
Local nTamCar1  := TamSX3("LJL_CODCAR")[1]
Local nTamCar2  := TamSX3("LHT_CARGO")[1]
Local nTamCar3  := TamSX3("LJJ_CODCAR")[1]
Local nTamCarg  := TamSX3("Q3_CARGO")[1]

ChkTemplate("CDV")  

// AjustaSx3() 

If nTamCar1 <> nTamCarg .Or. nTamCar2 <> nTamCarg .Or. nTamCar3 <> nTamCarg

	_cMens2:=STR0014 //"Favor alterar o tamanho dos campos a seguir no configurador, de acordo com o "
	_cMens2+=STR0015 + Chr(13) + Chr(13) //"tamanho do campo Q3_CARGO (Código do Cargo no Módulo Folha): "
	_cMens2+=STR0016 + AllTrim(STR(nTamCarg)) + Chr(13) + Chr(13) //"Tamanho do Código do Cargo no Folha (Q3_CARGO) :  "
	_cMens2+=STR0017 + Chr(13) + Chr(13)	 //"Veja abaixo os campos que devem ser alterados: "

	If nTamCar1 <> nTamCarg
		_cMens2+=STR0018 + AllTrim(STR(nTamCar1)) + Chr(13) //"Tabela de CARGOS ( LJL_CODCAR ) - Tamanho atual :  "
	EndIf

	If nTamCar2 <> nTamCarg
		_cMens2+=STR0019 + AllTrim(STR(nTamCar2)) + Chr(13) //"Tabela de USUARIO X VIAGEM ( LHT_CARGO ) - Tamanho atual :  "
	EndIf

	If nTamCar3 <> nTamCarg
		_cMens2+=STR0020 + AllTrim(STR(nTamCar3)) + Chr(13) //"Tabela de DESPESAS X CARGOS ( LJJ_CODCAR ) - Tamanho atual :  "
	EndIf	                                                               
	
	_cMens2+=+ Chr(13)+STR0021 + Chr(13)	 //"A rotina de importação de Cargos não prosseguirá sem essas alterações."

	MsgInfo(_cMens2, 'Aviso')

Else

	DbSelectArea("SQ3")
	Procregua(Reccount())
	dbSetOrder(1)
	DbGotop()
	
	While ! SQ3->(EOF()) 
		lVazio:=.F.
		
		_cChaveLJL := xFilial("LJL")+SQ3->Q3_CARGO
		
		_cCargo := SQ3->Q3_CARGO
	   
		DbSelectarea("LJL")
		If ! LJL->(DbSeek(_cChaveLJL))
			Reclock("LJL",.T.)
			lAchou := .F.
		Else
			_cMens1:=STR0022+_cCargo+STR0023 //"Cargo "###" já cadastrado, deseja sobescrever as informações?"
			If MsgYesNo(_cMens1,STR0024) //"CARGO EXISTENTE"
				lAltCargo := .T.
				Reclock("LJL",.F.)
			EndIf
		Endif
			
		If lAltCargo .Or. !lAchou
		
			LJL->LJL_FILIAL := xFilial("LJL")
			LJL->LJL_CODCAR := SQ3->Q3_CARGO
			LJL->LJL_CARGO  := SQ3->Q3_DESCSUM
		
			MsUnlock()	
	
			lCargos   := .T. 
	
		EndIf

		lAltCargo := .F.
		lAchou    := .T.
	
		DbSelectArea("SQ3")
		SQ3->(Dbskip())
		IncProc(STR0007) //"Processando......"
	
	Enddo
	
	If lVazio 
		MsgInfo('Nao existem registros no arquivo de cargos do módulo de folha de pagamentos Microsiga!', 'Aviso')
	Else
		_cMens:=STR0025+CHR(13) //"Importação Finalizada."
		_cMens+=STR0026 //"Será necessário atualizar os valores de pernoites e serviço de taxi de acordo com os Cargos."
	
		MsgInfo(_cMens, 'Aviso')
	EndIf

EndIf

Return(.T.)

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ AjustaSX3    ³ Autor ³ Ricardo A. Canteras	³ Data ³ 22/03/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Ajusta campos do SX3                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ AjustaSx3( )                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ Generico                                                   	   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
// STATIC Function AjustaSx3()

// Local aArea := GetArea()
// Local cExpres1 := " "
// Local cExpres2 := " "
// Local cExpres3 := " "

// DbSelectArea("SX3")
// DbSetOrder(2)

// //Altera Picture do campo de Banco/Agencia do Colaborador
// If MsSeek("LHT_BCDEPS")
// 	If !("@R 999/99999" $ UPPER(X3_PICTURE))
// 		RecLock("SX3")
// 		cExpres1 := "@R 999/99999"
// 		Replace X3_PICTURE With cExpres1
// 		MsUnlock()
// 	Endif
// Endif    

// //Altera Picture do campo de Cargo do Colaborador
// If MsSeek("LHT_CARGO")
// 	If !("99999" $ UPPER(X3_PICTURE))
// 		RecLock("SX3")
// 		cExpres2 := "99999"
// 		Replace X3_PICTURE With cExpres2
// 		MsUnlock()
// 	Endif
// Endif   

// //Altera Picture do campo de Cargo do Colaborador
// If MsSeek("LJL_CODCAR")
// 	If !("99999" $ UPPER(X3_PICTURE))
// 		RecLock("SX3")
// 		cExpres3 := "99999"
// 		Replace X3_PICTURE With cExpres3
// 		MsUnlock()
// 	Endif
// Endif   

// SX3->(dbSetOrder(1))

// RestArea(aArea)

// Return .T.
