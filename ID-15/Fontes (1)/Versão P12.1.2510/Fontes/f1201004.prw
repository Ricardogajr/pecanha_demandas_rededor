#Include 'Protheus.ch'

/*
Fonte antigo - Inicializador de Browse dos campos virtuais novos - 04/04/2018
{Protheus.doc} F1201004()
Gravação dos campos customizados 
@Author  Fabrica de Software
@Since   14/01/2019
*/
User Function F1201004(cFilSCR,cPedido,cTipDoc)

	Local aArea   := SCR->(GetArea())
	Local cFornec := ""
	Local cLoja   := ""
	Local cUser   := ""
	Local cDocNf  := ""
	Local cDescTp := ""
	Local cNome	  := ""
	Local dEmSCR  := ddatabase // SCR->CR_EMISSAO //CTOD(" / / ") // Ticket #9500321 ID 100 10/08/2020 - Eduardo Williams - CR_EMISSAO EM BRANCO
	Local cCC     := ""
	Local cNumCtr := ""
	Local cRevCrt := ""
	Local cRepasse := ""
	If cTipDoc == "PC"

		DbSelectArea("SC7")
		SC7->(DbSetOrder(1))
		If SC7->(DbSeek(cFilSCR+cPedido))
			cFornec := SC7->C7_FORNECE
			cLoja   := SC7->C7_LOJA
			cNome   := GetAdvFVal("SA2","A2_NOME",xFilial("SA2")+SC7->C7_FORNECE+SC7->C7_LOJA,1,"Fornecedor nao cadastrado")
			cUser   := IF(SC7->C7_XSOLPAG="1", SC7->C7_XUSR,SC7->C7_USER)
			cDocNf  := SC7->C7_XDOC

			If SC7->C7_XSOLPAG == "1"
				dEmSCR := SC7->C7_EMISSAO
			EndIf
		EndIf

	ElseIf cTipDoc == "SC"

		DbSelectArea("SC1")
		SC1->(DbSetOrder(1))
		If SC1->(DbSeek(cFilSCR+cPedido))
			cUser   := SC1->C1_USER
			cDescTp := POSICIONE("SX5",1,XFILIAL("SX5")+"ZX" + SC1->C1_XTPSC,"X5_DESCRI")
		EndIf
	Else //Correcao para chamado 10171168(znd) ID 176 projeto
		cUser := retcodusr()
	EndIf

	//Lucas Miranda de Aguiar - Resolução chamado DOR012245152
	If (Empty(cNome) .And. (cTipDoc == "CT" .Or. cTipDoc == "RV"))
		DbSelectArea("CNA")
		CNA->(DbSetOrder(3))
		cNumCtr := SubStr( SCR->CR_NUM, 1, TamSX3("CNA_CONTRA")[1] )
		cRevCrt := SubStr( SCR->CR_NUM, 16, TamSX3("CNA_REVISA")[1] )
		If CNA->(DbSeek(cFilSCR+cNumCtr+cRevCrt))
			cNome := GetAdvFVal("SA2","A2_NOME",xFilial("SA2")+CNA->CNA_FORNECE+CNA->CNA_LJFORN,1,"Fornecedor nao cadastrado")
			cFornec := CNA->CNA_FORNECE 
			cLoja   := CNA->CNA_LJFORN
		Else
			cNome := "Fornecedor nao cadastrado"
		EndIf
	EndIf
	cCC := fVeriCC(cFilSCR,cPedido,cTipDoc)//Lucas Miranda de Aguiar - Resolução chamado DOR012245152
	cRepasse := fVeriRep(cFilSCR,cPedido,cTipDoc)
	//Fim
	RecLock("SCR", .F.)
	SCR->CR_XFORNEC := cFornec
	SCR->CR_XLOJA   := cLoja
	SCR->CR_XNOMFOR := cNome 
	SCR->CR_XCOMSOL := UsrFullName(cUser)
	SCR->CR_XDOC    := cDocNf
	SCR->CR_XDESCTP := cDescTp
	SCR->CR_EMISSAO := dEmSCR
	SCR->CR_XCC 	:= cCC ////Lucas Miranda de Aguiar - Resolução chamado DOR012245152
	If !Empty(cRepasse)
		SCR->CR_XRPMED := cRepasse
	EndIf
	MsUnLock()

	RestArea(aArea)

Return

/*/{Protheus.doc} fVeriRep
	(long_description)
	@type  Static Function
	@author user
	@since 11/07/2023
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
/*/
Static Function fVeriRep(cFilSCR,cPedido,cTipDoc)

	Local cRet := ""

	If cTipDoc == "PC"
		DbSelectArea("SC7")
		SC7->(DbSetOrder(1))
		SC7->(DbGoTop())
		If SC7->(DbSeek(cFilSCR+AllTrim(cPedido)))
			If SC7->C7_XREPMED == "2"
				cRet := "R"
			ElseIf SC7->C7_XREPMED == "3"
				cRet := "H"
			Else
				cRet := ""
			EndIf
		EndIf
	EndIf
	
Return cRet

/*
{Protheus.doc} fVeriCC()
Busca o centro de custo do documento
@Author  Lucas Miranda de Aguiar - Resolução chamado DOR012245152
@Since   06/01/2023
*/
Static Function fVeriCC(cFilSCR,cPedido,cTipDoc)

	Local cCC     := ""
	Local cNDoc   := ""
	Local cNSerie := ""
	Local cNForn  := ""
	Local cNLj    := ""

	Do Case
	Case cTipDoc == "SC"
		DbSelectArea("SC1")
		SC1->(DbSetOrder(1))
		SC1->(DbGoTop())
		If SC1->(DbSeek(cFilSCR+AllTrim(cPedido)))
			cCC := SC1->C1_CC
			/*/While (SC1->(!EOF()) .And. SC1->C1_FILIAL == cFilSCR .And. SC1->C1_NUM == cPedido)
			If SC1->C1_CC <> cCC
				cCC := "RATEIO"
				Exit
			EndIf
			SC1->(DbSkip())
			Enddo/*/
		EndIf
	Case cTipDoc == "PC"
		DbSelectArea("SC7")
		SC7->(DbSetOrder(1))
		SC7->(DbGoTop())
		If SC7->(DbSeek(cFilSCR+AllTrim(cPedido)))
			cCC := SC7->C7_CC
			While (SC7->(!EOF()) .And. SC7->C7_FILIAL == cFilSCR .And. SC7->C7_NUM == cPedido)
				If SC7->C7_CC <> cCC
					cCC := "RATEIO"
					Exit
				EndIf
				SC7->(DbSkip())
			EndDo
		EndIf
	Case cTipDoc == "NF"
		DbSelectArea("SD1")
		SD1->(DbSetOrder(1))
		cNDoc 	:= SubStr( cPedido, 1, TamSX3("D1_DOC")[1] )
		cNSerie := SubStr( cPedido, TamSX3("D1_DOC")[1]+1, TamSX3("D1_SERIE")[1] )
		cNForn  := SubStr( cPedido, TamSX3("D1_DOC")[1]+TamSX3("D1_SERIE")[1]+1, TamSX3("D1_FORNECE")[1] )
		cNLj 	:= SubStr( cPedido, TamSX3("D1_DOC")[1]+TamSX3("D1_SERIE")[1]+TamSX3("D1_FORNECE")[1]+1, TamSX3("D1_LOJA")[1] )
		If SD1->(DbSeek(cFilSCR+cNDoc+cNSerie+cNForn+cNLj))
			cCC := SD1->D1_CC
		EndIf
	EndCase
Return cCC

/*
{Protheus.doc} F1201005()
Gravação dos campos customizados
@Author  Fabrica de Software
@Since   14/01/2019
*/
User Function F1201005()

	Local cQry := ""
	Local cAlias1 := GetNextAlias()
	Local cFornec := ""
	Local cLoja   := ""
	Local cUser   := ""
	Local cDocNf  := ""
	Local cDescTp := ""
	Local cNome	  := ""

	cQry += "SELECT * FROM " + RetSqlName("SCR") + " "
	cQry += "WHERE CR_TIPO IN ('PC','SC') AND D_E_L_E_T_ = ' '"

	cQuery := changeQuery(cQry)
	dbUseArea(.T., "TOPCONN", TcGenQry(, ,cQuery), cAlias1, .T., .T.)

	While !(cAlias1)->(EOF())

		If Empty((cAlias1)->(CR_XCOMSOL))
			If (cAlias1)->(CR_TIPO) == "PC"

				DbSelectArea("SC7")
				SC7->(DbSetOrder(1))
				If SC7->(DbSeek((cAlias1)->(CR_FILIAL)+Alltrim((cAlias1)->(CR_NUM))))
					cFornec := SC7->C7_FORNECE
					cLoja   := SC7->C7_LOJA
					cNome   := GetAdvFVal("SA2","A2_NOME",xFilial("SA2")+SC7->C7_FORNECE+SC7->C7_LOJA,1,"Fornecedor nao cadastrado")
					cUser   := IF(SC7->C7_XSOLPAG=="1", SC7->C7_XUSR,SC7->C7_USER)
					cDocNf  := SC7->C7_XDOC
				EndIf

			ElseIf (cAlias1)->(CR_TIPO) == "SC"

				DbSelectArea("SC1")
				SC1->(DbSetOrder(1))
				If SC1->(DbSeek((cAlias1)->(CR_FILIAL)+Alltrim((cAlias1)->(CR_NUM))))
					cUser   := SC1->C1_USER
					cDescTp := POSICIONE("SX5",1,XFILIAL("SX5")+"ZX" + SC1->C1_XTPSC,"X5_DESCRI")
				EndIf

			EndIf

			RecLock("SCR", .F.)
			SCR->CR_XFORNEC := cFornec
			SCR->CR_XLOJA   := cLoja
			SCR->CR_XNOMFOR := cNome
			SCR->CR_XCOMSOL := FwretUserName(cUser) //UsrFullName(cUser) - //Thiago Marques - 23781643 - 12/06/2025 - Depreciado o uso da função UsrFullName
			SCR->CR_XDOC    := cDocNf
			SCR->CR_XDESCTP := cDescTp
			MsUnLock()

		EndIf

		(cAlias1)->(DbSkip())
	End

Return

static function FwretUserName(cUser)
return FwGetUserName(cUser)