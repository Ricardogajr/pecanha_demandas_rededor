// #########################################################################################
// Projeto: Monkey
// Modulo : Integração API
// Fonte  : WSMNK01
// ---------+-------------------+-----------------------------------------------------------
// Data     | Autor             | Descricao
// ---------+-------------------+-----------------------------------------------------------
// 13/09/20 | Rafael Yera Barchi| Rotina para obter os profiles
// ---------+-------------------+-----------------------------------------------------------

#INCLUDE 	"PROTHEUS.CH"

#DEFINE 	cFunction		"WSMNK01"
#DEFINE 	cPerg			PadR(cFunction, 10)
#DEFINE 	cTitleRot	 	"Profiles"
#DEFINE 	cEOL			Chr(13) + Chr(10)


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} WSMNK01
//Rotina para obter os profiles
@author Rafael Yera Barchi
@since 13/09/2020
@version 1.00
@type function

/*/
//------------------------------------------------------------------------------------------
User Function WSMNK01()

	//--< Variáveis >-----------------------------------------------------------------------
	Local	lSchedule	:= .F.
	Local	cObs		:= ""
	Local	oProcess	:= Nil


	//--< Procedimentos >-------------------------------------------------------------------
	ConOut(OEMToANSI(FWTimeStamp(2) + " * * * | " + cFunction + ": " + cTitleRot + " ------> Início... "))

	lSchedule 	:= FWGetRunSchedule()

	If !lSchedule
		cObs := "Essa rotina tem a finalidade de obter os profiles. "
		oProcess := TNewProcess():New(cFunction, cTitleRot, {|oSelf, lSchedule| MNK01Pro(oSelf, lSchedule)}, cObs)
		Aviso(cTitleRot, "Fim do processamento! ", {"OK"})
	Else
		MNK01Pro(Nil, lSchedule)
	EndIf

	ConOut(OEMToANSI(FWTimeStamp(2) + " * * * | " + cFunction + ": " + cTitleRot + " ------> Fim! "))

	If ValType(oProcess) == "O"
		FreeObj(oProcess)
	EndIf

Return Nil



//------------------------------------------------------------------------------------------
/*/{Protheus.doc} MNK01Pro
Rotina auxiliar de processamento

@author    Rafael Yera Barchi
@version   1.xx
@since     13/09/2020
/*/
//------------------------------------------------------------------------------------------
Static Function MNK01Pro(oSelf, lSchedule)

	//--< Variáveis >-----------------------------------------------------------------------
	Local 	nCont       := 0
	Local 	nRegua		:= 0
	Local   nPos        := 0
	Local   nTimeOut    := 120
	Local   cTipo       := ""
	Local   cRetMNK     := ""
	Local   cRetRec     := ""
	Local   cURL_MNK    := ""
	Local   cURL_Rec    := ""
	Local   cGetParms   := ""
	Local   cHeadGet1   := ""
	Local   cHeadGet2   := ""
	Local   cToken      := ""
	Local   cProgram    := "Program: UNIPAR"
	Local   cContent    := "Content-Type: application/x-www-form-urlencoded"
	Local   aHeadStr1   := {}
	Local   aHeadStr2   := {}
	Local   aSA2        := {}
	Local   aAuth       := U_MNKAUTH()
	Local   oRetMNK     := Nil
	Local   oRetRec     := Nil
	Local   lContinua   := .F.

	Default lSchedule	:= .F.


	//--< Procedimentos >-------------------------------------------------------------------
	If !lSchedule
		oSelf:SaveLog(" * * * Início do Processamento * * * ")
		oSelf:SaveLog("Executando para filial: " + cFilAnt)
	EndIf

	//URL da API Monkey
	cURL_MNK    := "https://hmg-zuul.monkeyecx.com/uaa/profiles"

	nPos    := AScan(aAuth, {|x| AllTrim(x[1]) == "access_token"})
	cToken  := "Authorization: Bearer " + aAuth[nPos,2]

	AAdd(aHeadStr1, cToken)
	AAdd(aHeadStr1, cProgram)
	AAdd(aHeadStr1, cContent)

	cRetMNK := HTTPGet(cURL_MNK, cGetParms, nTimeOut, aHeadStr1, @cHeadGet1)

	//Transforma o retorno em um JSON
	If FWJSONDeserialize(cRetMNK, @oRetMNK)

		nRegua := Len(oRetMNK:companies)

		If !lSchedule
			oSelf:SetRegua1(nRegua)
		EndIf

		For nCont := 1 To nRegua

			If !lSchedule
				oSelf:IncRegua1("Processando Registro: " + CValToChar(nCont) + " de " + CValToChar(nRegua))
			Else
				ConOut(OEMToANSI(FWTimeStamp(2) + " - Processando Registro: " + CValToChar(nCont) + " de " + CValToChar(nRegua)))
			EndIf

			If ValType(oRetMNK) == "O" .And. ValType(oRetMNK:companies[nCont]) == "O" 
				If ValType(oRetMNK:companies[nCont]:governmentId) == "C"
					cCNPJ := oRetMNK:companies[nCont]:governmentId
					lContinua := .T.
				Else
					lContinua := .F.
					MsgAlert("Não foi possível obter o CNPJ do profile. ")
				EndIf
			Else
				lContinua := .F.
				MsgAlert("Não foi possível obter os dados do profile. ")
				Exit
			EndIf

			If lContinua

				If !lSchedule
					oSelf:SetRegua2(2)
					oSelf:IncRegua2("Fornecedor: " + oRetMNK:companies[nCont]:name)
				Else
					ConOut(OEMToANSI(FWTimeStamp(2) + " - Fornecedor: " + oRetMNK:companies[nCont]:name))
				EndIf

				SA2->(DBSelectArea("SA2"))
				SA2->(DBSetOrder(3))
				If SA2->(DBSeek(FWxFilial("SA2") + oRetMNK:companies[nCont]:governmentId))

					If Empty(SA2->A2_XIDMNK)
						RecLock("SA2", .F.)
						SA2->A2_XIDMNK := oRetMNK:companies[nCont]:Id
						SA2->(MSUnLock())
					EndIf

				Else

					If ValType(oRetMNK:companies[nCont]:type) == "C"
						Do Case
							Case AllTrim(Upper(oRetMNK:companies[nCont]:type)) == "BUYER"
							cTipo := "1"
							Case AllTrim(Upper(oRetMNK:companies[nCont]:type)) == "SELLER"
							cTipo := "2"
							Case AllTrim(Upper(oRetMNK:companies[nCont]:type)) == "SPONSOR"
							cTipo := "3"
							OtherWise
							cTipo := "0"
						EndCase
					EndIf

					AAdd(aSA2, {"A2_COD"    , GetSXENum("SA2", "A2_COD")                                                    , Nil})
					AAdd(aSA2, {"A2_LOJA"   , "01"                                                                          , Nil})
					AAdd(aSA2, {"A2_NOME"   , Upper(Left(oRetMNK:companies[nCont]:name, TamSX3("A2_NOME")[1]))              , Nil})
					AAdd(aSA2, {"A2_NREDUZ" , Upper(Left(oRetMNK:companies[nCont]:name, TamSX3("A2_NREDUZ")[1]))            , Nil})
					AAdd(aSA2, {"A2_TIPO"   , IIf(Len(oRetMNK:companies[nCont]:governmentId) > 11, "J", "F")                , Nil})
					AAdd(aSA2, {"A2_CGC"    , oRetMNK:companies[nCont]:governmentId                                         , Nil})
					AAdd(aSA2, {"A2_XIDMNK" , oRetMNK:companies[nCont]:Id                                                   , Nil})
					AAdd(aSA2, {"A2_XTPMNK" , cTipo                                                                         , Nil})

					oRetRec     := Nil
					cURL_Rec    := "https://www.receitaws.com.br/v1/cnpj/" + oRetMNK:companies[nCont]:governmentId
					cRetRec     := HTTPGet(cURL_Rec, , nTimeOut, aHeadStr2, @cHeadGet2)

					If "200 OK" $ cHeadGet2 .Or. "HTTP/1.1 200" $ cHeadGet2
						If FWJSONDeserialize(cRetRec, @oRetRec)
							If ValType(oRetRec) == "O"
								If AllTrim(Upper(oRetRec:status)) == "OK"
									AAdd(aSA2, {"A2_END"    , Upper(Left(oRetRec:logradouro, TamSX3("A2_END")[1]))                          , Nil})
									AAdd(aSA2, {"A2_NR_END" , Upper(Left(oRetRec:numero, TamSX3("A2_NR_END")[1]))                           , Nil})
									AAdd(aSA2, {"A2_BAIRRO" , Upper(Left(oRetRec:bairro, TamSX3("A2_BAIRRO")[1]))                           , Nil})
									AAdd(aSA2, {"A2_EST"    , Upper(Left(oRetRec:uf, TamSX3("A2_EST")[1]))                                  , Nil})
									AAdd(aSA2, {"A2_COD_MUN", U_PegaCodMun(Upper(oRetRec:uf), Upper(oRetRec:municipio))                     , Nil})
									AAdd(aSA2, {"A2_MUN"    , Upper(Left(oRetRec:municipio, TamSX3("A2_END")[1]))                           , Nil})
									AAdd(aSA2, {"A2_CEP"    , StrTran(StrTran(oRetRec:cep, ".", ""), "-", "")                               , Nil})
								Else
									MsgAlert(AllTrim(Upper(oRetRec:message)))
								EndIf
							Else
								MsgAlert("Não foi possível obter os dados da empresa. ")
							EndIf
						Else
							MsgAlert("Não foi possível obter os dados da empresa. ")
						EndIf
						If ValType(oRetRec) == "O"
							FreeObj(oRetRec)
						EndIf
					Else
						MsgAlert("Erro na integração com a Receita Federal! ")
					EndIf

					lMSErroAuto := .F.

					MSExecAuto({|x,y| MATA020(x,y)}, aSA2, 3)

					If lMSErroAuto
						If (!IsBlind()) // COM INTERFACE GRÁFICA
							MostraErro() // TELA
						Else // EM ESTADO DE JOB
							cError := MostraErro("/dirdoc", "error.log") // ARMAZENA A MENSAGEM DE ERRO

							ConOut(PadC("Automatic routine ended with error", 80))
							ConOut("Error: "+ cError)
						EndIf


					Else
						ConfirmSX8()
					EndIf

					If !lSchedule
						oSelf:IncRegua2()
					EndIf

				EndIf

			EndIf

		Next nCont

	Else

		MsgAlert("Erro na integração com a API Monkey! ")

	EndIf

	If ValType(oRetMNK) == "O"
		FreeObj(oRetMNK)
	EndIf    

	If !lSchedule
		oSelf:SaveLog("Total de Registros Atualizados: " + CValToChar(nCont))
		oSelf:SaveLog(" * * * Fim do Processamento * * * ")
	EndIf

Return



//------------------------------------------------------------------------------------------
/*/{Protheus.doc} SchedDef
//Função para utilização no Schedule
@author Rafael Yera Barchi
@since 13/09/2020
@version 1.00
@type function
/*/
//------------------------------------------------------------------------------------------
Static Function SchedDef()

	Local _aPar 	:= {}	//array de retorno


	_aPar := { 	"P"		,;	//Tipo R para relatorio P para processo
	Nil	    ,;	//Nome do grupo de perguntas (SX1)
	Nil		,;	//cAlias (para Relatorio)
	Nil		,;	//aArray (para Relatorio)
	Nil		}	//Titulo (para Relatorio)

Return _aPar



//------------------------------------------------------------------------------------------
/*/{Protheus.doc} MNK01Dmy
//Dummy Function - Apenas para não apresentar warning na compilação
@author Rafael Yera Barchi
@since 13/09/2020
@version 1.00
@param Nil
@return Nil
@type function
/*/
//------------------------------------------------------------------------------------------
User Function MNK01Dmy()


	If .F.
		SchedDef()
	EndIf

Return
//--< fim de arquivo >----------------------------------------------------------------------
