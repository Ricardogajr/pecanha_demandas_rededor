#INCLUDE "AE_Hoteis.ch"
#INCLUDE "Protheus.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³AE_HOTEIS º Autor ³ Itamar Oliveira    º Data ³  23/05/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³Cadastro de Hoteis 										  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Template CDV - Controle de Despesas de Viagens              º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function AE_HOTEIS
Local cVldAlt := ".T." // Validacao para permitir a alteracao. Pode-se utilizar ExecBlock.
Local cVldExc := "U_ValExcHot()" // Validacao para permitir a exclusao. Pode-se utilizar ExecBlock.

Private cString := "LJ3"

ChkTemplate("CDV")

dbSelectArea("LJ3")
LJ3->(dbSetOrder(1))

AxCadastro(cString,STR0001,cVldExc,cVldAlt) //"Cadastro de Hoteis"

Return          

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ValExcHot ºAutor ³Pablo Gollan Carrerasº Data ³  09/03/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Validacao da Exclusao do Hotel - Se estiver relacionada com º±±
±±º          ³alguma solicitacao nao sera apagada                         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³AE_HOTEIS                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function ValExcHot()

Local lRet 		:= .T.
Local _aArea	:= GetArea() 
Local cAlias	:= "TMP_AEHT"
Local lBDArq	:= .F.

//#IFDEF TOP
	If TcGetDb() # "AS/400"
		BeginSQL Alias cAlias
			Column nTotal As Numeric(10,0)
			SELECT COUNT(LHP_CODIGO) nTotal
			FROM %table:LHP% 
			WHERE ((%notDel%) AND (LHP_FILIAL = %xFilial:LHP%) AND (LHP_CODHOT = %exp:LJ3->LJ3_CODIGO%))
		EndSQL              
		dbSelectArea(cAlias)
		If !(cAlias)->(Eof())
			If (cAlias)->nTotal > 0
				lRet := .F.
			Endif
		Endif
	Else
		lBDArq := .T.
	Endif
//#ELSE               
//	lBDArq := .T.
//#ENDIF        
If lBDArq
	dbSelectArea("LHP")
	LHP->(dbSetOrder(1))	
	LHP->(dbGoTop())
	Do While !LHP->(Eof())
		If AllTrim(LHP->LHP_CODHOT) == AllTrim(LJ3->LJ3_CODIGO)
			lRet := .F.
			Exit
		Endif
		LHP->(dbSkip())
	EndDo
Endif
If !lRet
	MsgInfo(OemToAnsi(STR0002)) //"Este Hotel não poderá ser excluido por estar relacionado a solicitações de viagens."
Endif
If Select(cAlias) # 0
	dbSelectArea(cAlias)
	dbCloseArea()
	fErase(cAlias + OrdBagExt())
	fErase(cAlias + GetDbExtension())
Endif
RestArea(_aArea)

Return lRet
