#INCLUDE "PROTHEUS.CH"

/*
{Protheus.doc}  TEWBTYI3()
Importação de funcionários da SRA para a LHT, semelhante a rotina original do CDV, porém gravando os campos de
email, login, cargo padrão e atualizando a metrícula do fornecedor na SA2
@Author  Ramon Teodoro e Silva	
@Since   10/05/2017       
@Version P12.7
*/

User Function TEWBTYI3
Local cMens:=Space(200)
     
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de Variaveis                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ChkTemplate("CDV")  

cMens:="Esta rotina importa o cadastro de funcionarios do modulo de folha de pagamento da Microsiga para "
cMens+="o cadastro de usuarios de viagem. Confirma IMPORTACAO?"

If MsgYesNo(cMens,"MANUTENCAO DE USUARIOS")
	Processa({||U_ImpUser()})
Endif

Return(.T.)

/**********************************************************************/
User Function ImpUser()
Local lVazio	:=.T.
Local _cMens	:= ""
Local lAchou 	:= .F.  
Local cAliasFIN	:= ""
Local nTotREG	:= 0
Local cArq		:= Nil
Local aArea		:= GetArea()
Local cCond		:= ""
Local aCampos	:= {}
Local aUsers    := {} 
Local aMatFor   := {}
Local nF        := 0 
Local cCargoPad := GetMV("FS_CARGOPD")

//#IFDEF TOP
	Local cQuery	:= ""
	Local aSelFil := {}
	Local cInFilial := ""
//#ENDIF              

IncProc("Acessando dados de usuários...")
aUsers    := FwsfAllUsers()

ChkTemplate("CDV")
//AjustaSx3() Thais Paiva - Compatibilização P27
//Montando matriz compatibilizadora de tamanho de campos
aAdd(aCampos,{"LHT_FILIAL",TamSX3("LHT_FILIAL")[1]})
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
	cAliasFIN 	:= "QrySRA"
	cQuery 		:= "SELECT RA_FILIAL,RA_CC,RA_MAT,RA_NOME,RA_SITFOLH,RA_BCDEPSA,RA_CTDEPSA,RA_EMAIL,RA_ESTADO,RA_MUNICIP,RA_CARGO, RA_CIC "
	cQuery 		+= " FROM "+ RetSqlName("SRA") + " SRA "
	cQuery 		+= " WHERE RA_SITFOLH <> 'D' "	
	cQuery			+= " AND RA_FILIAL IN " + FormatIn( Substr( cInFilial , 1 , Len( cInFilial ) - 1 ) , "|" )
	If TcSrvType() == "AS/400"
		cQuery += " AND SRA.@DELETED@ = ' ' "
	Else
		cQuery += " AND SRA.D_E_L_E_T_ = ' ' "
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
//          
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
			LHT->LHT_FILIAL		:= Substr((cAliasFIN)->RA_FILIAL,1,aCampos[aScan(aCampos,{|x|x[1]=="LHT_FILMAT"})][2])
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
		LHT->LHT_CC 		:= Substr((cAliasFIN)->RA_CC,1,aCampos[aScan(aCampos,{|x|x[1]=="LHT_CC"})][2])
		LHT->LHT_CARGO 		:= IIF(!Empty(cCargoPad), cCargoPad, Substr((cAliasFIN)->RA_CARGO,1,aCampos[aScan(aCampos,{|x|x[1]=="LHT_CARGO"})][2]))
		If !lAchou                                  
			LHT->LHT_FLAGAP 	:= "2"
			LHT->LHT_APFIN		:= "2"
			LHT->LHT_LIMDES 	:= "1" 
		EndIf                      
				
		nPosUsr := Ascan(aUsers,{|x|Alltrim(x[3])==Alltrim((cAliasFIN)->RA_CIC)})
		If nPosUsr > 0
			LHT->LHT_EMAIL := aUsers[nPosUsr][5]
		Else
			LHT->LHT_EMAIL := Substr((cAliasFIN)->RA_EMAIL,1,aCampos[aScan(aCampos,{|x|x[1]=="LHT_EMAIL"})][2])
		EndIf
		LHT->LHT_LOGIN      := Alltrim((cAliasFIN)->RA_CIC)
		
		Aadd(aMatFor, { Alltrim((cAliasFIN)->RA_CIC), (cAliasFIN)->RA_MAT }) 
			
		MsUnlock()
		
	EndIf
	(cAliasFIN)->(dbSkip())
	IncProc("Processando......")	 
End

If Len(aMatFor) > 0

	DbSelectArea("SA2")
	DbSetOrder(3)

	For nF := 1 to Len(aMatFor)
	
		If DbSeek(xFilial("SA2")+aMatFor[nF][1])
			Reclock("SA2",.F.)
			SA2->A2_MAT := aMatFor[nF][2]	
			MsUnlock()
		EndIf
		
	Next nF

EndIf

If lVazio 
	MsgInfo('Nao existem registros no arquivo de funcionarios do modulo folha de pagamentos Microsiga', 'Aviso') 
Else
	_cMens:="Importacao Finalizada. Será necessário atualizar alguns dados no cadastro de colaboradores "
	_cMens+="do template. Deverão ser informados os seguintes dados: " + Chr(13) + Chr(13) 
	_cMens+=" - Login do sistema Microsiga" + Chr(13) 
	_cMens+=" - Informar se o colaborador é aprovador" 
	MsgInfo(_cMens, 'Aviso') 
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
/* Início - Thais Paiva - Compatibilização P27
STATIC Function AjustaSx3()

Local aArea := GetArea()
Local cExpres1 := " "
Local cExpres2 := " "
Local cExpres3 := " "

DbSelectArea("SX3")
DbSetOrder(2)

//Altera Picture do campo de Banco/Agencia do Colaborador
If MsSeek("LHT_BCDEPS")
	If !("@R 999/99999" $ UPPER(X3_PICTURE))
		RecLock("SX3")
		cExpres1 := "@R 999/99999"
		Replace X3_PICTURE With cExpres1
		MsUnlock()
	Endif
Endif    

//Altera Picture do campo de Cargo do Colaborador
If MsSeek("LHT_CARGO")
	If !("99999" $ UPPER(X3_PICTURE))
		RecLock("SX3")
		cExpres2 := "99999"
		Replace X3_PICTURE With cExpres2
		MsUnlock()
	Endif
Endif   

//Altera Picture do campo de Cargo do Colaborador
If MsSeek("LJL_CODCAR")
	If !("99999" $ UPPER(X3_PICTURE))
		RecLock("SX3")
		cExpres3 := "99999"
		Replace X3_PICTURE With cExpres3
		MsUnlock()
	Endif
Endif   

SX3->(dbSetOrder(1))

RestArea(aArea)

Return .T.
Fim - Thais Paiva - Compatibilização P27*/


