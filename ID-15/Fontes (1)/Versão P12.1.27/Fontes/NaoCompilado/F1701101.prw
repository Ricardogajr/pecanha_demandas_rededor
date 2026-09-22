#Include "Protheus.ch"
#INCLUDE "APWebSrv.ch"

#DEFINE DEF_DOCUMENTO   01 //[01] Número do Documento
#DEFINE DEF_TIPO_DOC    02 //[02] Tipo de Documento
#DEFINE DEF_VALOR_DOC   03 //[03] Valor do Documento
#DEFINE DEF_APROVADOR   04 //[04] Código do Aprovador
#DEFINE DEF_USUARIO     05 //[05] Código do Usuário
#DEFINE DEF_GRP_APROV   06 //[06] Grupo do Aprovador
#DEFINE DEF_APROV_SUP   07 //[07] Aprovador Superior
#DEFINE DEF_MOEDA_DOC   08 //[08] Moeda do Documento
#DEFINE DEF_TX_MOEDA    09 //[09] Taxa da Moeda
#DEFINE DEF_DT_EMISSAO  10 //[10] Data de Emissão do Documento
#DEFINE DEF_NIVEL       13 //[13] Nivel

//ANEXOS
#DEFINE FILE_NAME       01 //Nome do arquivo
#DEFINE FILE_CONT       02 //Conteudo do Arquivo
#DEFINE FILE_SIZE       03 //Tamanho do arquivo
#DEFINE DF_SENHA        "R&dD0r_12!" //senha do arquivo zipado RDSL

Static lRmtHTM    := (GetRemoteType() == REMOTE_HTML)
Static nRecnoSCR := 0

/*/{Protheus.doc} F1700101
Efetua o envio ou cancelamento das alçadas no Fluig.

@project
@type       User Function
@author     Rafael Riego
@since      01/11/2018
@version    12.1.17
@param      lBackOffic, boolean, BackOffice se verdadeiro, RH caso falso
@param      aDocument, array, informações da alçada
@param      nOperation, numeric, operação que deverá ser realizada 1-Envio/Demais=Cancelamento
@param      nInstancId, numeric, número da instância do processo inciiado no Fluig (somente cancelamento)
@param      cComments, character, comentário enviado ao Fluig no momento de integração.
@param      aSolicRH, array, informações para montagem de carddata RH
@param      oAttach, object, objeto de anexo
@return     aRetorno, [1] lRetorno, [2] InstanceId, [3] Mensagem de Resultado
/*/
User Function F1700101(lBackOffic, aDocument, nOperation, nInstancId, cComments, aSolicRH, oAttach)

	Local aArea         := {}
	Local aRetorno      := {}
	Local cCancelTxt    := ""
	Local cIdentity     := ""
	Local cLoginApr     := ""
	Local cNivel        := ""
	Local cPassFluig    := ""
	Local cProcessId    := ""
	Local cUserFluig    := ""
	Local cFilSCR		:= ""
	Local lCmpltTask    := .T.
	Local lMngrMode     := .F.
	Local nCompanyId    := 0
	Local oCardData   := Nil

	If Type("cUsrAprov") == "U"
		Static cUsrAprov := SCR->CR_USER
	EndIf

	Default lBackOffic  := .T.
	Default aDocument   := {}
	Default nOperation  := 1
	Default nInstancId  := 0
	Default cComments   := ""
	Default aSolicRH    := {}
	Default oAttach     := Nil

	Private cNomeFil    := ""

	If Empty(aDocument)
		aDocument := aDocument2
	EndIf

	If Empty(cComments)
		If nOperation == 1
			//cComments := "Processo iniciado automaticamente via Protheus para alçada de aprovação Protheus."
			cComments := RetHistori(aDocument)
		ElseIf nOperation == 15
			cComments   := "Envio de Anexo - Banco de conhecimento"
			lCmpltTask  := .F.
		ElseIf nOperation == 16
			cComments := "Deleção de Anexo - Banco de conhecimento"
		Else
			cComments := "Cancelado por contingência."
		EndIf
	EndIf

	If lBackOffic
		cLoginApr  := Identity(SCR->CR_USER)

		If AllTrim(cLoginApr) == ""
			cLoginApr := Identity(cUsrAprov)
		EndIf

		If !(Empty(cLoginApr))
			cUserFluig  := AllTrim(SuperGetMv("FS_USRFLG", .F., "admin"))   //login de integração Fluig
			cPassFluig  := AllTrim(SuperGetMv("FS_PSWFLG", .F., "admin"))   //senha de integração Fluig
			nCompanyId  := SuperGetMv("FS_EMPFLG", .F., 1)                  // Codigo da empresa integracao

			aArea := {GetArea(), SCR->(GetArea())}
			If !Empty(aDocument)
				cProcessId  := ProcIdBO(aDocument[1], aDocument[2])
			EndIf
			//verificar qual o tipo de integração que deverá ser feito através do campo CR_TIPO
			//Para cada tipo de alçada deverá ser criada
			If nOperation == 1
				cNomeFil  := NomFil(SCR->CR_FILIAL)
				oCardData   := CardDataBO(aDocument, cLoginApr)
				cProcessId  := ProcIdBO(aDocument[1], aDocument[2])

			EndIf

			cIdentity   := cLoginApr

			aRetorno := FluigInteg(nOperation, cUserFluig, cPassFluig, nCompanyId, cProcessId, cIdentity, cComments, oCardData, nInstancId, lCmpltTask, lMngrMode,, lBackOffic, oAttach,aDocument)

		EndIf
	Else
		aArea := {GetArea(), RH3->(GetArea()), RH4->(GetArea())}

		If nOperation == 1
			oCardData  := U_F1700201(aSolicRH) //CardData das solicitações de RH
			cProcessId := U_F1700202(aSolicRH[3]) //ID de processo do Fluig
			cIdentity  := "" //??? Falta definição
		EndIf

		aRetorno := FluigInteg(nOperation, cUserFluig, cPassFluig, nCompanyId, cProcessId, cIdentity, cComments, oCardData, nInstancId, lCmpltTask, lMngrMode, aSolicRH, lBackOffic, oAttach,aDocument)
	EndIf
	AEval(aArea, {|area| RestArea(area)})

Return aRetorno

/*/{Protheus.doc} RetHistori
Efetua o envio ou cancelamento das alçadas no Fluig.

@project
@type       Static Function
@author     Rafael Riego
@since      01/11/2018
@version    12.1.17
@param      aDocument, array, informações da alçada
@return     cHistorico, histórico de aprovação da alçada
/*/
Static Function RetHistori(aDocument)

	Local cAliasQry     := ""
	Local cHistorico    := ""
	Local cQuerySCR     := ""
	Local lFilSAK		:= U_fFilialEx("SAK")

	cQuerySCR := "SELECT SCR.CR_USERLIB, SCR.CR_NIVEL, SCR.CR_DATALIB, SAK.AK_NOME "
	cQuerySCR += " FROM " + RetSQLName("SCR") + " SCR "
	cQuerySCR += " INNER JOIN " + RetSQLName("SAK") + " SAK ON"
	If lFilSAK
		cQuerySCR += " SCR.CR_FILIAL = SAK.AK_FILIAL "
	EndIf
	cQuerySCR += " SCR.CR_USERLIB = SAK.AK_USER "
	cQuerySCR += " WHERE SCR.D_E_L_E_T_ = ' ' "
	cQuerySCR += "   AND SAK.D_E_L_E_T_ = ' ' "
	cQuerySCR += "   AND SCR.CR_FILIAL = '" + FwXFilial("SCR") + "' "
	If !lFilSAK
		cQuerySCR += "   AND SAK.AK_FILIAL = '" + FwXFilial("SAK") + "' "
	EndIf
	cQuerySCR += "   AND SCR.CR_NUM = '" + aDocument[DEF_DOCUMENTO] + "'"
	cQuerySCR += "   AND SCR.CR_TIPO = '" + aDocument[DEF_TIPO_DOC] + "'"
	cQuerySCR += "   AND SCR.CR_STATUS = '03' " //Aprovado

	cQuerySCR := ChangeQuery(cQuerySCR)

	cAliasQry := MPSysOpenQuery(cQuerySCR)

	While (cAliasQry)->(!(EoF()))

		cHistorico += " Alçada nível " + (cAliasQry)->CR_NIVEL + " Aprovada por " + AllTrim((cAliasQry)->AK_NOME) + " em " + DToC(SToD((cAliasQry)->CR_DATALIB)) + "." + CRLF

		(cAliasQry)->(DbSkip())
	End

	(cAliasQry)->(DbCloseArea())

	If Empty(cHistorico)
		cHistorico := "Processo iniciado automaticamente via Protheus para alcada de aprovacao Protheus."
	EndIf

Return cHistorico

/*/{Protheus.doc} F1701101
Rotina utilizada dentro do ponto de entrada MtAlcDoc, localizado dentro do fonte MatXAlc, utilizado para efetuar integração das alçadas de aprovação
com o Fluig.

aDocument: [1] Número do Documento
[2] Tipo de Documento
[3] Valor do Documento
[4] Código do Aprovador
[5] Código do Usuário
[6] Grupo do Aprovador
[7] Aprovador Superior
[8] Moeda do Documento
[9] Taxa da Moeda
[10] Data de Emissão do Documento

nOperation: 1 = Inclusão de Documento
2 = Transferência da Alçada para o Superior
3 = Exclusão do Documento
4 = Aprovação do Documento
5 = Estorno da Aprovação
6 = Bloqueio Manual
7 = Evento de Rejeição

@project    MAN0000007423048_EF_037
@type       User Function
@author     Rafael Riego
@since      01/11/2018
@version    12.1.17
@param      aDocument, array, informações da alçada.
@param      dDataRef, date, data de referência da alçada.
@param      nOperation, numeric, número da operação que está sendo realizada.
@return     lOk, verdadeiro em caso de sucesso
/*/
User Function F1701101(aDocument, dDataRef, nOperation, cEmpCon, cFilCon)

	Local aArea         := {}

	Local lAlcada       := .T.
	Local lOk           := .T.
	Local lEnvAberto    := .T.

	Local cTipFluig := GETNEWPAR( "FS_DCFLUIG" , "SC|PC|CT|MD",  ) // "SC|PC|CT|MD|RV"

	Private cStatus := "1"
	Private cOutput := ""
	Private cRotina := "U_FLUIGP20"
	Private cAlias  := "SCR"
	Private cTipo    := ""
	Private cIndkey := ""
	Private cInput	:= ""
	Private cUsrAprov  := ""
	Private cNivelAprov := ""
	Private cFilialAprov	:= ""
	Private aDocument2 	:= {}

	Default aDocument   := {}
	Default dDataRef    := CToD("  /  /    ")
	Default nOperation  := 0
	Default cEmpCon     := ""
	Default cFilCon     := ""

	If !(Empty(cEmpCon)) .And. !(Empty(cFilCon))
		If !(Select("SX2") > 0)
			RpcSetEnv(cEmpCon, cFilCon)
			If !(Select("SX2") > 0)
				lEnvAberto  := .F.
				lOk         := .F.
			EndIf
		EndIf
	EndIf

	If lEnvAberto
		aArea := {SCR->(GetArea()), GetArea()}

		SCR->(DBSETORDER(1))
		If !(SCR->(DbSeek(FwXFilial("SCR") + aDocument[DEF_TIPO_DOC] + aDocument[DEF_DOCUMENTO])))
			lAlcada := .F.
		EndIf

		AEval(aArea, {|area| RestArea(area)})

		//Inclusão | Exclusão | Aprovação | Bloqueio | Rejeição
		If !lAlcada .And. AllTrim(aDocument[2]) == "SC"
			If nOperation == 1 //Inclusão
				If Empty(aDocument[DEF_DT_EMISSAO])
					aDocument[DEF_DT_EMISSAO] := dDataRef
				EndIf
				aRetorno := FlgIntInc(aDocument)
			ElseIf nOperation == 3 // Exclusão
				aRetorno := FlgIntExc(aDocument)
			ElseIf nOperation == 4 //Aprovação
				aRetorno := FlgIntAprv(aDocument)
			ElseIf nOperation == 6 .Or. nOperation == 7 //Bloqueado ou Rejeitado
				aRetorno := FlgBlqRej(aDocument)
			EndIf
		EndIf
		If (lAlcada .Or. nOperation == 3) .And. aDocument[DEF_TIPO_DOC] $ cTipFluig .And.;
		(nOperation == 1 .Or. nOperation == 3 .Or. nOperation == 4 .Or. nOperation == 6 .Or. nOperation == 7)
			If nOperation == 1 //Inclusão
				If Empty(aDocument[DEF_DT_EMISSAO])
					aDocument[DEF_DT_EMISSAO] := dDataRef
				EndIf
				aRetorno := FlgIntInc(aDocument)
			ElseIf nOperation == 3 // Exclusão
				aRetorno := FlgIntExc(aDocument)
			ElseIf nOperation == 4 //Aprovação
				aRetorno := FlgIntAprv(aDocument)
			ElseIf nOperation == 6 .Or. nOperation == 7 //Bloqueado ou Rejeitado
				aRetorno := FlgBlqRej(aDocument)
			EndIf
		EndIf

		AEval(aArea, {|area| RestArea(area)})
	EndIf

Return lOk

/*/{Protheus.doc} FlgIntInc
Efetua o envio das alçadas ao Fluig no momento de inclusão.

@project
@type       Static Function
@author     Rafael Riego
@since      01/11/2018
@version    12.1.17
@param      aDocument, array, informações da alçada
@return     aRetorno, [1] lRetorno, [2] InstanceId, [3] Mensagem de Resultado
/*/
Static Function FlgIntInc(aDocument)

	Local aRetorno  := {}

	Local cFilSCR   := ""
	Local cNivel    := ""

	Local oAttach   := Nil

	//Posiciona no primeiro registro da tabela SCR
	SCR->(DbSetOrder(1))
	SCR->(DbSeek(FwXFilial("SCR") + aDocument[DEF_TIPO_DOC] + aDocument[DEF_DOCUMENTO]))

	If Len(aDocument) == 10
		AAdd(aDocument, Nil)
		AAdd(aDocument, Nil)
		AAdd(aDocument, SCR->CR_NIVEL)
	ElseIf Len(aDocument) == 11
		AAdd(aDocument, Nil)
		AAdd(aDocument, SCR->CR_NIVEL)
	ElseIf Len(aDocument) == 12
		AAdd(aDocument, SCR->CR_NIVEL)
	EndIf

	cFilSCR := SCR->CR_FILIAL
	cNivel  := SCR->CR_NIVEL

	While SCR->(!(EoF())) .And.;
	SCR->CR_FILIAL == cFilSCR .And. SCR->CR_TIPO == aDocument[DEF_TIPO_DOC] .And.;
	SCR->CR_NUM == PadR(aDocument[DEF_DOCUMENTO], TamSX3("CR_NUM")[1]) .And. SCR->CR_NIVEL == cNivel
		aDocument[DEF_USUARIO]      := SCR->CR_USER
		aDocument[DEF_APROVADOR]    := SCR->CR_APROV

		oAttach     := U_F1701102(, Identity(SCR->CR_USER),, AllTrim(SCR->CR_NUM),,, SCR->CR_TIPO)

		aRetorno := U_F1700101(.T., aDocument, 1,,,, oAttach)

		If Empty(aRetorno)
			Conout("FLUIG aRetorno vazio.(Não voltou resposta nenhuma do FLUIG.)")
		Else
			If aRetorno[1]
				GrvXFluig(aRetorno[2], "2")
			EndIf
		EndIf

		ASize(aRetorno, 0)
		FwFreeObj(aRetorno)
		FwFreeObj(oAttach)
		SCR->(DbSkip())

	End
	//Gravar LOG de envio na tabela P33
	//U_GRVP33(cRotina,cOutput,cStatus,cAlias,1,cIndKey)
	U_F07Log03(cRotina,AllTrim(cInput),cOutput,cStatus,cAlias,1,cIndKey)
	ASize(aDocument, 0)
	FwFreeObj(aDocument)

	aDocument := {}

Return aRetorno

/*/{Protheus.doc} RecNoSCR
Guarda o recno antes da atualização das alçadas.

@project
@type       User Function
@author     Rafael Riego
@since      01/11/2018
@version    12.1.17
@param      nSCRRecno, numeric, número do recno da SCR
@return     Nil
/*/
User Function RecNoSCR(nSCRRecno)

	nRecnoSCR := nSCRRecno

Return Nil

/*/{Protheus.doc} FlgIntAprv
Efetua o cancelamento das alçadas ao Fluig após a aprovação no Protheus. Também será verificado se existe um próximo nível de alçada para envio ao Fluig.

@project
@type       Static Function
@author     Rafael Riego
@since      01/11/2018
@version    12.1.17
@param      aDocument, array, informações da alçada
@return     aRetorno, [1] lRetorno, [2] InstanceId, [3] Mensagem de Resultado
/*/
/*/{Protheus.doc} FlgIntAprv
//TODO Descrição auto-gerada.
@author lucas
@since 28/11/2019
@version 1.0
@return ${return}, ${return_description}
@param aDocument, array, descricao
@type function
/*/
Static Function FlgIntAprv(aDocument)

	Local aArea         := {}
	Local aRetorno      := {}

	Local cFilSCR       := ""
	Local cNivel        := ""
	Local cTipoDoc      := ""
	Local cNumDoc       := ""

	Local lAprovado     := .F.
	Local lEnvProxNv    := .T.

	aArea := {GetArea(), SCR->(GetArea())}

	If nRecnoSCR == 0
		Return aRetorno
	Else
		SCR->(DbGoTo(nRecnoSCR))
	EndIf

	If Len(aDocument) == 10
		AAdd(aDocument, Nil)
		AAdd(aDocument, Nil)
		AAdd(aDocument, SCR->CR_NIVEL)
	ElseIf Len(aDocument) == 11
		AAdd(aDocument, Nil)
		AAdd(aDocument, SCR->CR_NIVEL)
	ElseIf Len(aDocument) == 12
		AAdd(aDocument, SCR->CR_NIVEL)
	EndIf

	cFilSCR := FwXFilial("SCR")

	cNumDoc     := PadR(aDocument[DEF_DOCUMENTO], TamSX3("CR_NUM")[1])
	cTipoDoc    := aDocument[DEF_TIPO_DOC]
	cNivelAprov := SCR->CR_NIVEL
	cNivel := SCR->CR_NIVEL
	If SCR->CR_STATUS $ "03|05"
		lAprovado := .T.
	EndIf

	If lAprovado
		SCR->(DbSetOrder(1))
		If SCR->(DbSeek(cFilSCR + cTipoDoc + cNumDoc + cNivel))

			While !(SCR->((EoF()))) .And. SCR->CR_FILIAL == cFilSCR .And. SCR->CR_TIPO == cTipoDoc .And.;
			SCR->CR_NUM == cNumDoc .And. SCR->CR_NIVEL == cNivel
				If SCR->CR_STATUS $ "03|05"
					If SCR->CR_XFLINTE == "2"
						aRetorno := U_F1700101(.T.,aDocument, 4, Val(AllTrim(SCR->CR_XIDFLG)), "Cancelado por contingência.")

						If Empty(aRetorno)
							Conout("FLUIG aRetorno vazio.(Não voltou resposta nenhuma do FLUIG.)")
						Else
							If aRetorno[1]
								GrvXFluig(, "3")
							EndIf
						EndIf
					Else
						GrvXFluig(, "3")
					EndIf
				Else
					lEnvProxNv := .F.
				EndIf
				SCR->(DbSkip())
				cRotina := "U_FLUIGP20"

			End
			//U_GRVP33(cRotina,cOutput,cStatus,cAlias,1,cIndKey)
			U_F07Log03(cRotina,AllTrim(cInput),cOutput,cStatus,cAlias,1,cIndKey)
			cOutput := ""
			//verifica se deve enviar o próximo nível
			If lEnvProxNv
				ASize(aDocument, 0)
				aDocument := Nil
				aDocument := {}
				cPrxNivel := SCR->CR_NIVEL

				While !(SCR->((EoF()))) .And. SCR->CR_FILIAL == cFilSCR .And. SCR->CR_TIPO == cTipoDoc .And.;
				SCR->CR_NUM == cNumDoc .And. SCR->CR_NIVEL == cPrxNivel
					If SCR->CR_STATUS $ "02" .And. (SCR->CR_XFLINTE == "1" .Or. Empty(SCR->CR_XFLINTE))
						AAdd(aDocument, SCR->CR_NUM)        // DEF_DOCUMENTO  01 - [01] Número do Documento
						AAdd(aDocument, SCR->CR_TIPO)       // DEF_TIPO_DOC   02 - [02] Tipo de Documento
						AAdd(aDocument, SCR->CR_TOTAL)      // DEF_VALOR_DOC  03 - [03] Valor do Documento
						AAdd(aDocument, SCR->CR_APROV)      // DEF_APROVADOR  04 - [04] Código do Aprovador
						AAdd(aDocument, SCR->CR_USER)       // DEF_USUARIO    05 - [05] Código do Usuário
						AAdd(aDocument, SCR->CR_GRUPO)      // DEF_GRP_APROV  06 - [06] Grupo do Aprovador
						AAdd(aDocument, "")                 // DEF_APROV_SUP  07 - [07] Aprovador Superior
						AAdd(aDocument, SCR->CR_MOEDA)      // DEF_MOEDA_DOC  08 - [08] Moeda do Documento
						AAdd(aDocument, SCR->CR_TXMOEDA)    // DEF_TX_MOEDA   09 - [09] Taxa da Moeda
						AAdd(aDocument, SCR->CR_EMISSAO)    // DEF_DT_EMISSAO 10 - [10] Data de Emissão do Documento
						AAdd(aDocument, "")                 //                11 - [11]
						AAdd(aDocument, "")                 //                12 - [12]
						AAdd(aDocument, SCR->CR_NIVEL)      // DEF_NIVEL      13 - [13] Nível de aprovação

						oAttach     := U_F1701102(, Identity(SCR->CR_USER),, AllTrim(SCR->CR_NUM),,, SCR->CR_TIPO)

						aRetorno := U_F1700101(.T., aDocument, 1,,,, oAttach)

						If Empty(aRetorno)
							Conout("FLUIG aRetorno vazio.(Não voltou resposta nenhuma do FLUIG.)")
						Else
							If aRetorno[1]
								GrvXFluig(aRetorno[2], "2")
							EndIf
						EndIf

						ASize(aDocument, 0)
						FwFreeObj(aDocument)
						aDocument := {}
					EndIf
					SCR->(DbSkip())
				End
				//U_GRVP33(cRotina,cOutput,cStatus,cAlias,1,cIndKey)
				U_F07Log03(cRotina,AllTrim(cInput),cOutput,cStatus,cAlias,1,cIndKey)
			EndIf
		EndIf
	EndIf
	AEval(aArea, {|area| RestArea(area)})

Return aRetorno

/*/{Protheus.doc} FlgBlqRej
Efetua o cancelamento das alçadas ao Fluig após o bloqueio ou reijeção no Protheus.

@project
@type       Static Function
@author     Rafael Riego
@since      01/11/2018
@version    12.1.17
@param      aDocument, array, informações da alçada
@return     aRetorno, [1] lRetorno, [2] InstanceId, [3] Mensagem de Resultado
/*/
Static Function FlgBlqRej(aDocument)

	Local aArea         := {}
	Local aRetorno      := {}

	Local cFilSCR       := ""
	Local cNivel        := ""
	Local cNumSCR       := ""
	Local cTipoDoc      := ""
	Local cCodAprov		:= ""

	Local lBloqueado    := .F.
	Local lEnvProxNv    := .T.
	Local lReprovado    := .F.

	aArea := {GetArea(), SCR->(GetArea())}

	If nRecnoSCR == 0
		Return aRetorno
	Else
		SCR->(DbGoTo(nRecnoSCR))
	EndIf

	cFilSCR     := FwXFilial("SCR")

	cTipoDoc    := aDocument[DEF_TIPO_DOC]
	cNumSCR     := PadR(aDocument[DEF_DOCUMENTO], TamSX3("CR_NUM")[1])
	cCodAprov	:= aDocument[DEF_APROVADOR]
	cNivel 		:= SCR->CR_NIVEL
	cNivelAprov	:= SCR->CR_NIVEL

	If SCR->CR_STATUS == "04"
		lBloqueado := .T.
	ElseIf SCR->CR_STATUS $ "05|06"
		lReprovado := .T.
	EndIf

	If lReprovado .Or. lBloqueado
		SCR->(DbGoTop())
		SCR->(DbSetOrder(1))
		If SCR->(DbSeek(cFilSCR + cTipoDoc + cNumSCR + cNivel))
			While !(SCR->((EoF()))) .And. SCR->CR_FILIAL == cFilSCR .And. SCR->CR_TIPO == cTipoDoc .And.;
			SCR->CR_NUM == cNumSCR// .And. SCR->CR_NIVEL == cNivel
				If SCR->CR_STATUS $ "04|05|06"
					If SCR->CR_XFLINTE == "2"
						If !(Empty(SCR->CR_XIDFLG))
							aRetorno := U_F1700101(.T.,aDocument, 4, Val(SCR->CR_XIDFLG), IIf(lReprovado, "Reprovado", "Bloqueado") + " no Protheus.")

							If !Empty(aRetorno)
								If aRetorno[1]
									GrvXFluig(, "3")
								Else
									If "que é o requisitante não foi encontrado." $ aRetorno[3]
										GrvXFluig(, "3")
									EndIf
									If "Envio cancelado, o usuário não está cadastrado no FLUIG " $ aRetorno[3]
										GrvXFluig(, "3")
									EndIf
								EndIf
							EndIf
						EndIf
					Else
						GrvXFluig(, "3")
					EndIf
				EndIf
				SCR->(DbSkip())
				cRotina := "U_FLUIGP20"
			End
			//U_GRVP33(cRotina,cOutput,cStatus,cAlias,1,cIndKey)
			U_F07Log03(cRotina,AllTrim(cInput),cOutput,cStatus,cAlias,1,cIndKey)
		EndIf
	EndIf
	AEval(aArea, {|area| RestArea(area)})

Return aRetorno

/*/{Protheus.doc} FlgIntExc
Efetua o cancelamento das alçadas ao Fluig após a exclusão no Protheus.

@project
@type       Static Function
@author     Rafael Riego
@since      01/11/2018
@version    12.1.17
@param      aDocument, array, informações da alçada
@return     aRetorno, [1] lRetorno, [2] InstanceId, [3] Mensagem de Resultado
/*/
Static Function FlgIntExc(aDocument)

	Local aArea         := {}
	Local aRetorno      := {}

	Local cAliasSCR     := ""
	Local cNivel        := ""
	Local cNumSCR       := ""
	Local cTipoDoc      := ""

	Local lExcluido     := .F.

	aDocument2 := aDocument

	aArea := {GetArea(), SCR->(GetArea()), SAL->(GetArea())}

	cNumSCR     := PadR(aDocument[DEF_DOCUMENTO], TamSX3("CR_NUM")[1])

	cTipoDoc    := aDocument[DEF_TIPO_DOC]

	SCR->(DbSetOrder(1))
	If !(SCR->(DbSeek(FwXFilial("SCR") + cTipoDoc + cNumSCR)))// + aDocument[DEF_USUARIO])))
		lExcluido := .T.
	EndIf

	If lExcluido
		cQuery := QrySCRExc(cTipoDoc, cNumSCR)
		cAliasSCR := MPSysOpenQuery(cQuery)
		If (cAliasSCR)->(!(EoF()))
			SET DELETED OFF
			While (cAliasSCR)->(!(EoF()))
				cUsrAprov := (cAliasSCR)->CR_USER
				cNivelAprov := (cAliasSCR)->CR_NIVEL
				cFilialAprov := (cAliasSCR)->CR_FILIAL
				aRetorno := U_F1700101(.T., {}, 3, Val((cAliasSCR)->CR_XIDFLG), "Excluído no Protheus.")
				SCR->(DbGoTo((cAliasSCR)->R_E_C_N_O_))
				If Empty(aRetorno)
					Conout("FLUIG aRetorno vazio.(Não voltou resposta nenhuma do FLUIG.)")
				Else
					If aRetorno[1]
						GrvXFluig(, "3")
					EndIf
				EndIf
				(cAliasSCR)->(DbSkip())
			End
			//U_GRVP33(cRotina,cOutput,cStatus,cAlias,1,cIndKey)
			U_F07Log03(cRotina,AllTrim(cInput),cOutput,cStatus,cAlias,1,cIndKey)
			SET DELETED ON
		EndIf
	EndIf

	(cAliasSCR)->(DbCloseArea())

	AEval(aArea, {|area| RestArea(area)})

Return aRetorno

/*/{Protheus.doc} QrySCRExc
Monta a query utilizada para encontrar as alçadas que precisam ser excluídas no Protheus.

@project
@type       Static Function
@author     Rafael Riego
@since      01/11/2018
@version    12.1.17
@param      cTipoSCR, character, tipo do documento
@param      cNumSCR, character, número do documento
@return     cQuery, query montada pronta para execução
/*/
Static Function QrySCRExc(cTipoSCR, cNumSCR)

	Local cQuery    := ""

	cQuery := " SELECT SCR.R_E_C_N_O_ , SCR.CR_XFLINTE, SCR.CR_XIDFLG, SCR.CR_NUM, SCR.CR_FILIAL, SCR.CR_NUM, SCR.CR_TIPO, SCR.CR_APROV, SCR.CR_USER, SCR.CR_NIVEL, SCR.CR_FILIAL, SCR.D_E_L_E_T_ DELETADO"
	cQuery += " FROM " + RetSQLName("SCR") + " SCR "
	cQuery += " WHERE SCR.CR_FILIAL     =   '" + FwXFilial("SCR") + "' "
	cQuery += "   AND SCR.CR_TIPO       =   '" + cTipoSCR + "' "
	cQuery += "   AND SCR.CR_NUM        =   '" + cNumSCR + "' "
	cQuery += "   AND SCR.CR_XFLINTE    =   '2'"
	cQuery += "   AND SCR.CR_XIDFLG     <>  ' ' "
	cQuery += "   AND SCR.D_E_L_E_T_ = '*' "

	cQuery := ChangeQuery(cQuery)

Return cQuery

/*/{Protheus.doc} GrvXFluig
Efetua o cancelamento das alçadas ao Fluig após a exclusão no Protheus.

@project
@type       Static Function
@author     Rafael Riego
@since      01/11/2018
@version    12.1.17
@param      cFluigId, character, id da instância do Fluig que deverá ser gravado.
@param      cStatus, character, status
@return     Nil
/*/
Static Function GrvXFluig(cFluigId, cStatus1)

	Local cUsrFlg := "2"

	Default cFluigId    := ""
	Default cStatus1 	:= ""

	If !U_fFilialEx("SAK")
		If AllTrim(SCR->CR_USER) == ""
			cUsrFlg := Posicione("SAK",02,FWxFilial("SAK")+cUsrAprov,'AK_XUSRFLG')    // 1 Para usuário FLUIG e 2 para Não
		Else
			cUsrFlg := Posicione("SAK",02,FWxFilial("SAK")+SCR->CR_USER,'AK_XUSRFLG')    // 1 Para usuário FLUIG e 2 para Não
		EndIf
	Else
		If AllTrim(SCR->CR_USER) == ""
			cUsrFlg := Posicione("SAK",02,SCR->CR_FILIAL+cUsrAprov,'AK_XUSRFLG')    // 1 Para usuário FLUIG e 2 para Não
		Else
			cUsrFlg := Posicione("SAK",02,SCR->CR_FILIAL+SCR->CR_USER,'AK_XUSRFLG')    // 1 Para usuário FLUIG e 2 para Não
		EndIf
	EndIf
	If AllTrim(cUsrFlg) == "S"
		RecLock("SCR", .F.)
		SCR->CR_XFLINTE := cStatus1
		If !(Empty(cFluigId))
			SCR->CR_XIDFLG  := cFluigId
		EndIf
		SCR->(MsUnlock())
	EndIf

Return Nil

/*/{Protheus.doc} Identity
Retorna o identity do usuário que está fazendo o processo.

@project
@type       Static Function
@author     Rafael Riego
@since      01/11/2018
@version    12.1.17
@param      cCodUser, character, código do usuário
@return     cIdentity, identity do usuário para envio ao Fluig
/*/
Static Function Identity(cCodUser)

	Local cIdentity := ""

	cIdentity := UsrRetCPF(cCodUser)

Return cIdentity

/*/{Protheus.doc} UsrRetCPF
Devolve o CPF do usuário.

@project
@type       Static Function
@author     Rafael Riego
@since      01/11/2018
@version    12.1.17
@param      cCodUser, character, código do usuário
@return     cIdentity, CPF (login Fluig) do usuário
/*/
Static Function UsrRetCPF(cCodUser)

	Local aArea     := {}
	//Local aUser     := {}

	Local cFilUser  := ""
	Local cMatUser  := ""
	Local cFilMat   := ""

	Local nTamEmp   := 0
	Local nTamFil   := 0

	nTamEmp := Len(AllTrim(FwCodEmp()))
	nTamFil := Len(AllTrim(FwCodFil()))

	//Busca vinculo funcional
	PswOrder(1)
	If (PswSeek(cCodUser, .T.))
		cFilMat := PswRet()[1][22]

		cFilUser := SubStr(cFilMat, nTamEmp + 1, nTamFil)
		cMatUser := SubStr(cFilMat, nTamEmp + nTamFil + 1, 6)

		If !(Empty(cFilUser)) .And. !(Empty(cMatUser))
			SRA->(DbSetOrder(1))
			If SRA->(DbSeek(cFilUser + cMatUser))
				cIdentity := SRA->RA_CIC
			EndIf
		EndIf
	EndIf

Return cIdentity

/*/{Protheus.doc} SolitPagto
Verifica se o pedido de compra é solicitação de pagamento.

@project
@type       Static Function
@author     Rafael Riego
@since      01/11/2018
@version    12.1.17
@param      cSCRNum, character, número do pedido de compra
@param      cSCRTipo, character, tipo de solicitação
@return     lSolitPagt, se é solicitação de pagamento ou não
/*/
Static Function SolitPagto(cSCRNum, cSCRTipo)

	Local aArea         := {}

	Local lSolitPagt    := .F.

	aArea := {GetArea(), SC7->(GetArea())}

	SC7->(DbSetOrder(1))

	If AllTrim(SCR->CR_FILIAL) == ""
		If SC7->(DbSeek(cFilialAprov + PadR(cSCRNum, TamSX3("C7_NUM")[1])))
			If SC7->C7_XSOLPAG == "1"
				lSolitPagt  := .T.
			EndIf
		EndIf
	Else
		If SC7->(DbSeek(SCR->CR_FILIAL + PadR(cSCRNum, TamSX3("C7_NUM")[1])))
			If SC7->C7_XSOLPAG == "1"
				lSolitPagt  := .T.
			EndIf
		EndIf
	EndIf
	AEval(aArea, {|area| RestArea(area)})

Return lSolitPagt

/*/{Protheus.doc} ProcIdBO
Retorna o id do processo do Fluig com base no tipo da alçada.

@project
@type       Static Function
@author     Rafael Riego
@since      01/11/2018
@version    12.1.17
@param      cSCRNum, character, chave do documento
@param      cSCRTipo, character, tipo do documento
@return     lSolitPagt, se é solicitação de pagamento ou não
/*/
Static Function ProcIdBO(cSCRNum, cSCRTipo)

	Local aArea         := {}

	Local cProcessId    := ""

	Default cSCRNum     := ""
	Default cSCRTipo    := ""

	If cSCRTipo == "SC"
		cProcessId := SuperGetMv("FS_SCFLG", .F., "app_solicitacao_compras")
	ElseIf cSCRTipo == "PC"
		If SolitPagto(cSCRNum, cSCRTipo)
			cProcessId := SuperGetMv("FS_SPFLG", .F., "app_solicitacao_pagamento")
		Else
			cProcessId := SuperGetMv("FS_PCFLG", .F., "app_pedido_compras")
		EndIf
	ElseIf cSCRTipo == "CT"
		cProcessId := SuperGetMv("FS_ICFLG", .F., "app_ctr_manut_compras")  // mmt
		//        cProcessId := SuperGetMv("FS_ICFLG", .F., "app_inclusao_contrato")

	ElseIf cSCRTipo == "MD"
		//        cProcessId := SuperGetMv("FS_RCFLG", .F., "app_medicao_contrato")
		cProcessId := SuperGetMv("FS_RCFLG", .F., "app_ctr_med_compras")

	ElseIf cSCRTipo == "RV"
		//        cProcessId := SuperGetMv("FS_RCFLG", .F., "app_revisao_contrato")
		cProcessId := SuperGetMv("FS_RCFLG", .F., "app_ctr_rev_compras")

	EndIf

Return cProcessId

/*/{Protheus.doc} CardDataBO
Monta o cardData para envio ao formulário do Fluig conforme tipo do documento.

@project
@type       Static Function
@author     Rafael Riego
@since      01/11/2018
@version    12.1.17
@param      aDocument, array, informações da alçada
@param      cLoginApr, character, login do aprovador
@return     lSolitPagt, se é solicitação de pagamento ou não
/*/
Static Function CardDataBO(aDocument, cLoginApr)

	Local aArea         := {}
	Local aCardData     := {}

	Local oCardData     := Nil

	Default aDocument   := {}
	Default cLoginApr   := ""

	aArea := {GetArea(), SCR->(GetArea())}

	If !(Empty(aDocument))
		If aDocument[DEF_TIPO_DOC] == "SC"
			aCardData := CardDataSC(aDocument, cLoginApr)
		ElseIf aDocument[DEF_TIPO_DOC] == "PC"
			If SolitPagto(aDocument[DEF_DOCUMENTO], aDocument[DEF_TIPO_DOC])
				aCardData := CardDataSP(aDocument, cLoginApr)
			Else
				aCardData := CardDataPC(aDocument, cLoginApr)
			EndIf
		ElseIf aDocument[DEF_TIPO_DOC] == "CT"
			aCardData := CardDataCT(aDocument)
		ElseIf aDocument[DEF_TIPO_DOC] == "MD"
			aCardData := CardDataMD(aDocument)
		ElseIf aDocument[DEF_TIPO_DOC] == "RV"
			aCardData := CardDataRV(aDocument)
		EndIf

		oCardData := CardData(aCardData)

		FwFreeObj(aCardData)
		aCardData   := Nil
	EndIf

Return oCardData

/*/{Protheus.doc} CardData
Monta o carddata Fluig baseado no array carddata {{campo, valor}}.

@project
@type       Static Function
@author     Rafael Riego
@since      01/11/2018
@version    12.1.17
@param      aCardData, array, array contendo as informação do cardData
@return     oCardData, object, objeto cardData para envio ao Fluig
/*/
Static Function CardData(aCardData)

	Local aFormulari    := {}

	Local nCardData     := 0
	Local nTamCardDt    := 0

	Default aCardData   := {}

	nTamCardDt := Len(aCardData)

	For nCardData := 1 To nTamCardDt
		AAdd(aFormulari, WSClassNew("ECMWorkflowEngineServiceService_stringArray"))
		aFormulari[nCardData]:cItem   := AClone(aCardData[nCardData])
	Next nCardData

	oCardData   := WSClassNew("ECMWorkflowEngineServiceService_stringArrayArray")

	oCardData:oWSItem := AClone(aFormulari)

Return oCardData

/*/{Protheus.doc} CardDataBO
Monta o cardData para solicitação de compras.

@project
@type       Static Function
@author     Rafael Riego
@since      01/11/2018
@version    12.1.17
@param      aDocument, array, informações da alçada
@return     array contendo as informação do cardData
/*/
Static Function CardDataSC(aDocument)

	Local aArea         := {}
	Local aCardData     := {}

	Local cCodFornec    := ""
	Local cDescricao    := ""
	Local cFilialSC1    := ""
	Local cScNum		:= ""
	Local cFornecedor   := ""
	Local cLinhaDesc    := ""
	Local cLoginApr     := ""
	Local cNomeAprv     := ""
	Local nItemCod      := 0
	Local nItemDesc     := 0
	Local nItemQuant    := 0
	Local nItemVUnit	:= 0
	Local nItemSubTot   := 0
	Local nQtdCount		:= 0

	Default aDocument   := {}

	aArea := {GetArea(), SCR->(GetArea()), SC1->(GetArea())}

	cNomeAprv := AllTrim(UsrFullName(SCR->CR_USER))

	cLoginApr := Identity(SCR->CR_USER)

	SC1->(DbSetOrder(1))
	cFilialSC1 := SCR->CR_FILIAL
	If SC1->(DbSeek(cFilialSC1 + PadR(SCR->CR_NUM, TamSX3("C1_NUM")[1])))

		cCodFornec  := SC1->C1_FORNECE
		cFornecedor := AllTrim(Posicione("SA2",1,xFilial("SA2")+SC1->C1_FORNECE+SC1->C1_LOJA,"SA2->A2_NOME"))
		cScNum	:= SC1->C1_NUM

		cDescricao := "Solicitante: " + AllTrim(SCR->CR_XCOMSOL) + CRLF
		cDescricao += "FILIAL: " + cFilialSC1 + " -  " + cNomeFil + CRLF //+ "|"
		//cDescricao += " FORN: " + AllTrim(SC1->C1_FORNECE) + " - " + cFornecedor + CRLF + CRLF
		cDescricao += "ITENS: " + CRLF

		While !(SC1->(EoF())) .And. SC1->C1_FILIAL == cFilialSC1 .And. SC1->C1_NUM == cScNum
			cLinhaDesc := "Produto: " + AllTrim(SC1->C1_DESCRI) + " | " + "QUANTIDADE: " + CValToChar(SC1->C1_QUANT) + " | " + "VALOR: " + AllTrim(Transform(SC1->C1_XTOTAL, AllTrim(X3Picture("C1_XTOTAL")))) + CRLF
			cDescricao  += cLinhaDesc
			nQtdCount := nQtdCount + 1
			AAdd(aCardData, {"itemCodigo___"       +cValToChar(nItemCod := nItemCod + 1),         AllTrim(SC1->C1_PRODUTO)})
			AAdd(aCardData, {"itemDescricao___"    +cValToChar(nItemDesc := nItemDesc + 1),       AllTrim(SC1->C1_DESCRI)})
			AAdd(aCardData, {"itemQuantidade___"   +cValToChar(nItemQuant := nItemQuant + 1),     CValToChar(SC1->C1_QUANT)})
			AAdd(aCardData, {"itemValorUnitario___"+cValToChar(nItemVUnit := nItemVUnit + 1),     CValToChar(SC1->C1_VUNIT)})
			AAdd(aCardData, {"itemSubTotal___"     +cValToChar(nItemSubTot := nItemSubTot + 1),   AllTrim(Transform(SC1->C1_XTOTAL, AllTrim(X3Picture("C1_XTOTAL"))))})
			SC1->(DbSkip())
		End
		cDescricao += CRLF + "Solicitação de Compra"
	EndIf

	AAdd(aCardData, {"txt_empresa",             FwCodEmp()})
	AAdd(aCardData, {"txt_filial",              AllTrim(SCR->CR_FILIAL)})
	AAdd(aCardData, {"txt_nomefilial",          cNomeFil})
	AAdd(aCardData, {"txt_codigofornecedor",    cCodFornec})
	AAdd(aCardData, {"txt_nomefornecedor",      cFornecedor})
	AAdd(aCardData, {"txt_tipo",                aDocument[2]})
	AAdd(aCardData, {"txt_documento",           AllTrim(aDocument[1])})
	AAdd(aCardData, {"txt_nivel",               aDocument[13]})
	AAdd(aCardData, {"txt_descricao",           cDescricao})
	AAdd(aCardData, {"txt_data",                DToC(aDocument[10])})
	AAdd(aCardData, {"txt_valortotal",          AllTrim(Transform(aDocument[3], AllTrim(X3Picture("CR_TOTAL"))))})
	AAdd(aCardData, {"txt_nome_aprovador",      cNomeAprv})
	AAdd(aCardData, {"txt_login_aprovador",     cLoginApr})
	AAdd(aCardData, {"txt_cod_usuario",         aDocument[5]})
	AAdd(aCardData, {"txt_totalItens",   	cValToChar(nQtdCount)})

	AEval(aArea, {|area| RestArea(area)})

Return aCardData

/*/{Protheus.doc} CardDataPC
Monta o cardData para pedido de compras.

@project
@type       Static Function
@author     Rafael Riego
@since      01/11/2018
@version    12.1.17
@param      aDocument, array, informações da alçada
@return     aCardData, array contendo as informação do cardData
/*/
Static Function CardDataPC(aDocument, cLoginApr)

	Local aArea         := {}
	Local aCardData     := {}

	Local cCodFornec    := ""
	Local cDescricao    := ""
	Local cFilialSC7    := ""
	Local cFornecedor   := ""
	Local cLinhaDesc    := ""
	Local cNomeAprv     := ""
	Local cNumPedCom    := ""
	Local nItemCod      := 0
	Local nItemDesc     := 0
	Local nItemQuant    := 0
	Local nItemVUnit	:= 0
	Local nItemSubTot   := 0
	Local nQtdCount		:= 0

	Default aDocument   := {}
	Default cLoginApr   := ""

	aArea := {GetArea(), SCR->(GetArea()), SC7->(GetArea())}

	cNomeAprv := AllTrim(UsrFullName(SCR->CR_USER))

	cNumPedCom := PadR(aDocument[1], TamSX3("C7_NUM")[1])

	SC7->(DbSetOrder(1))
	cFilialSC7 := SCR->CR_FILIAL
	If SC7->(DbSeek(cFilialSC7 + cNumPedCom))

		cCodFornec  := AllTrim(SC7->C7_FORNECE)
		cFornecedor := AllTrim(Posicione("SA2",1,xFilial("SA2")+SC7->C7_FORNECE+SC7->C7_LOJA,"SA2->A2_NOME"))

		cDescricao := "Solicitante: " + AllTrim(SCR->CR_XCOMSOL) + CRLF
		cDescricao += "FILIAL: " + cFilialSC7 + " - " + cNomeFil + CRLF + "|"
		cDescricao += " FORN: " + cCodFornec + " - " + cFornecedor + CRLF + CRLF
		cDescricao += "ITENS: " + CRLF

		While !(SC7->(EoF())) .And. SC7->C7_FILIAL == cFilialSC7 .And. SC7->C7_NUM == cNumPedCom
			cLinhaDesc  := AllTrim(SC7->C7_DESCRI) + ": QTE: " + CValToChar(SC7->C7_QUANT) + ": VALOR: " + AllTrim(Transform(SC7->C7_TOTAL, AllTrim(X3Picture("C7_TOTAL")))) + CRLF
			cDescricao  += cLinhaDesc
			nQtdCount := nQtdCount + 1
			AAdd(aCardData, {"itemCodigo___"       +cValToChar(nItemCod := nItemCod + 1),         AllTrim(SC7->C7_PRODUTO)})
			AAdd(aCardData, {"itemDescricao___"    +cValToChar(nItemDesc := nItemDesc + 1),       AllTrim(SC7->C7_DESCRI)})
			AAdd(aCardData, {"itemQuantidade___"   +cValToChar(nItemQuant := nItemQuant + 1),     CValToChar(SC7->C7_QUANT)})
			AAdd(aCardData, {"itemValorUnitario___"+cValToChar(nItemVUnit := nItemVUnit + 1),     CValToChar(SC7->C7_PRECO)})
			AAdd(aCardData, {"itemSubTotal___"     +cValToChar(nItemSubTot := nItemSubTot + 1),   AllTrim(Transform(SC7->C7_TOTAL, AllTrim(X3Picture("C7_TOTAL"))))})
			SC7->(DbSkip())
		End
	EndIf

	AAdd(aCardData, {"txt_empresa",             FwCodEmp()})
	AAdd(aCardData, {"txt_filial",              AllTrim(SCR->CR_FILIAL)})
	AAdd(aCardData, {"txt_nomefilial",          cNomeFil})
	AAdd(aCardData, {"txt_codigofornecedor",    cCodFornec})
	AAdd(aCardData, {"txt_nomefornecedor",      cFornecedor})
	AAdd(aCardData, {"txt_tipo",                aDocument[2]})
	AAdd(aCardData, {"txt_documento",           AllTrim(aDocument[1])})
	AAdd(aCardData, {"txt_nivel",               aDocument[13]})
	AAdd(aCardData, {"txt_descricao",           cDescricao})
	AAdd(aCardData, {"txt_data",                DToC(aDocument[10])})
	AAdd(aCardData, {"txt_valortotal",          AllTrim(Transform(aDocument[3], AllTrim(X3Picture("CR_TOTAL"))))})
	AAdd(aCardData, {"txt_nome_aprovador",      cNomeAprv})
	AAdd(aCardData, {"txt_login_aprovador",     cLoginApr})
	AAdd(aCardData, {"txt_cod_usuario",         aDocument[5]})
	AAdd(aCardData, {"txt_totalItens",   	cValToChar(nQtdCount)})

	AEval(aArea, {|area| RestArea(area)})

Return aCardData

/*/{Protheus.doc} CardDataSP
Monta o cardData para solicitação de pagamento.

@project
@type       Static Function
@author     Rafael Riego
@since      01/11/2018
@version    12.1.17
@param      aDocument, array, informações da alçada
@return     aCardData, array contendo as informação do cardData
/*/
Static Function CardDataSP(aDocument, cLoginApr)

	Local aArea         := {}
	Local aCardData     := {}

	Local cCodFornec    := ""
	Local cDescricao    := ""
	Local cFilialSC7    := ""
	Local cFornecedor   := ""
	Local cLinhaDesc    := ""
	Local cNomeAprv     := ""
	Local cNumPedCom    := ""
	Local nItemCod      := 0
	Local nItemDesc     := 0
	Local nItemQuant    := 0
	Local nItemVUnit	:= 0
	Local nItemSubTot   := 0
	Local nQtdCount		:= 0

	Default aDocument   := {}
	Default cLoginApr   := ""

	aArea := {GetArea(), SCR->(GetArea()), SC7->(GetArea())}

	/*/If !(Empty(nSCRRecno))
	SCR->(DbSeek(nSCRRecno))
	EndIf/*/

	cNomeAprv := AllTrim(UsrFullName(SCR->CR_USER))

	cNumPedCom  := PadR(aDocument[DEF_DOCUMENTO], TamSX3("C7_NUM")[1])

	SC7->(DbSetOrder(1))
	cFilialSC7 := SCR->CR_FILIAL
	If SC7->(DbSeek(cFilialSC7 + cNumPedCom))

		cCodFornec  := AllTrim(SC7->C7_FORNECE)
		cFornecedor := AllTrim(Posicione("SA2",1,xFilial("SA2")+SC7->C7_FORNECE+SC7->C7_LOJA,"SA2->A2_NOME"))

		cDescricao := "Solicitante: " + AllTrim(SCR->CR_XCOMSOL) + CRLF
		cDescricao += "FILIAL: " + cFilialSC7 + " - " + cNomeFil + CRLF
		cDescricao += "FORNECEDOR: " + cCodFornec + " - " + cFornecedor + CRLF + CRLF
		cDescricao += "ITENS: " + CRLF

		While !(SC7->(EoF())) .And. SC7->C7_FILIAL == cFilialSC7 .And. SC7->C7_NUM == cNumPedCom
			cLinhaDesc := AllTrim(SC7->C7_DESCRI) + ": QTE: " + CValToChar(SC7->C7_QUANT) + ": VALOR: " + AllTrim(Transform(SC7->C7_TOTAL, AllTrim(X3Picture("C7_TOTAL")))) + CRLF
			cDescricao  += cLinhaDesc
			nQtdCount := nQtdCount + 1
			AAdd(aCardData, {"itemCodigo___"       +cValToChar(nItemCod := nItemCod + 1),         AllTrim(SC7->C7_PRODUTO)})
			AAdd(aCardData, {"itemDescricao___"    +cValToChar(nItemDesc := nItemDesc + 1),       AllTrim(SC7->C7_DESCRI)})
			AAdd(aCardData, {"itemQuantidade___"   +cValToChar(nItemQuant := nItemQuant + 1),     CValToChar(SC7->C7_QUANT)})
			AAdd(aCardData, {"itemValorUnitario___"+cValToChar(nItemVUnit := nItemVUnit + 1),     CValToChar(SC7->C7_PRECO)})
			AAdd(aCardData, {"itemSubTotal___"     +cValToChar(nItemSubTot := nItemSubTot + 1),   AllTrim(Transform(SC7->C7_TOTAL, AllTrim(X3Picture("C7_TOTAL"))))})
			SC7->(DbSkip())
		End
	EndIf

	AAdd(aCardData, {"txt_empresa",             FwCodEmp()})
	AAdd(aCardData, {"txt_filial",              AllTrim(SCR->CR_FILIAL)})
	AAdd(aCardData, {"txt_nomefilial",          cNomeFil})
	AAdd(aCardData, {"txt_codigofornecedor",    cCodFornec})
	AAdd(aCardData, {"txt_nomefornecedor",      cFornecedor})
	AAdd(aCardData, {"txt_tipo",                aDocument[2]})
	AAdd(aCardData, {"txt_documento",           AllTrim(aDocument[1])})
	AAdd(aCardData, {"txt_nivel",               aDocument[13]})
	AAdd(aCardData, {"txt_descricao",           cDescricao})
	AAdd(aCardData, {"txt_data",                DToC(aDocument[10])})
	AAdd(aCardData, {"txt_valortotal",          AllTrim(Transform(aDocument[3], AllTrim(X3Picture("CR_TOTAL"))))})
	AAdd(aCardData, {"txt_nome_aprovador",      cNomeAprv})
	AAdd(aCardData, {"txt_login_aprovador",     cLoginApr})
	AAdd(aCardData, {"txt_cod_usuario",         aDocument[5]})
	AAdd(aCardData, {"txt_totalItens",   	cValToChar(nQtdCount)})

	AEval(aArea, {|area| RestArea(area)})

Return aCardData

/*/{Protheus.doc} CardDataCT
Monta o cardData para contratos.

@project
@type       Static Function
@author     Rafael Riego
@since      01/11/2018
@version    12.1.17
@param      aDocument, array, informações da alçada
@return     aCardData, array contendo as informação do cardData
/*/
Static Function CardDataCT(aDocument, cLoginApr)

	Local aArea         := {}
	Local aCardData     := {}

	Local cDescricao    := ""
	Local cFilialCN9    := ""
	Local cLinhaDesc    := ""
	Local cNomeAprv     := ""

	Default aDocument   := {}
	Default cLoginApr   := ""

	aArea := {GetArea(), SCR->(GetArea()), SC7->(GetArea())}
	/*
	IF TYPE("nSCRRecno") == 'N'
	If !(Empty(nSCRRecno))
	SCR->(DbSeek(nSCRRecno))
	EndIf
	Endif
	*/
	cLoginApr := Identity(SCR->CR_USER)

	cNomeAprv := AllTrim(UsrFullName(SCR->CR_USER))

	cDescricao += CRLF + "Atualização de Contrato"

	AAdd(aCardData, {"txt_empresa",         FwCodEmp()})
	AAdd(aCardData, {"txt_filial",              AllTrim(SCR->CR_FILIAL)})
	AAdd(aCardData, {"txt_nomefilial",          cNomeFil})
	AAdd(aCardData, {"txt_tipo",            aDocument[2]})
	AAdd(aCardData, {"txt_documento",       AllTrim(aDocument[1])})
	AAdd(aCardData, {"txt_nivel",           aDocument[13]})
	AAdd(aCardData, {"txt_descricao",       cDescricao})
	AAdd(aCardData, {"txt_data",            DToC(aDocument[10])})
	AAdd(aCardData, {"txt_valortotal",      AllTrim(Transform(aDocument[3], AllTrim(X3Picture("CR_TOTAL"))))})
	AAdd(aCardData, {"txt_nome_aprovador",  cNomeAprv})
	AAdd(aCardData, {"txt_login_aprovador", cLoginApr})
	AAdd(aCardData, {"txt_cod_usuario",     aDocument[5]})

	AEval(aArea, {|area| RestArea(area)})

Return aCardData

/*/{Protheus.doc} CardDataCT
Monta o cardData para medição de contrato.

@project
@type       Static Function
@author     Rafael Riego
@since      01/11/2018
@version    12.1.17
@param      aDocument, array, informações da alçada
@return     aCardData, array contendo as informação do cardData
/*/
Static Function CardDataMD(aDocument, cLoginApr)

	Local aArea         := {}
	Local aCardData     := {}

	Local cDescricao    := ""
	Local cFilialCN9    := ""
	Local cLinhaDesc    := ""
	Local cNomeAprv     := ""

	Default aDocument   := {}
	Default cLoginApr   := ""

	aArea := {GetArea(), SCR->(GetArea()), CN9->(GetArea())}
	/*
	IF TYPE("nSCRRecno") == "N"
	If !(Empty(nSCRRecno))
	SCR->(DbSeek(nSCRRecno))
	EndIf
	Endif
	*/
	cNomeAprv := AllTrim(UsrFullName(SCR->CR_USER))

	cLoginApr := Identity(SCR->CR_USER)

	cDescricao += CRLF + "Medição de Contrato"

	AAdd(aCardData, {"txt_empresa",         FwCodEmp()})
	AAdd(aCardData, {"txt_filial",              AllTrim(SCR->CR_FILIAL)})
	AAdd(aCardData, {"txt_nomefilial",          cNomeFil})
	AAdd(aCardData, {"txt_tipo",            aDocument[2]})
	AAdd(aCardData, {"txt_documento",       AllTrim(aDocument[1])})
	AAdd(aCardData, {"txt_nivel",           aDocument[DEF_NIVEL]})
	AAdd(aCardData, {"txt_descricao",       cDescricao})
	AAdd(aCardData, {"txt_data",            DToC(aDocument[10])})
	AAdd(aCardData, {"txt_valortotal",      AllTrim(Transform(aDocument[3], AllTrim(X3Picture("CR_TOTAL"))))})
	AAdd(aCardData, {"txt_nome_aprovador",  cNomeAprv})
	AAdd(aCardData, {"txt_login_aprovador", cLoginApr})
	AAdd(aCardData, {"txt_cod_usuario",     aDocument[5]})

	AEval(aArea, {|area| RestArea(area)})

Return aCardData

/*/{Protheus.doc} CardDataRV
Monta o cardData para revisão de contratos..

@project
@type       Static Function
@author     Rafael Riego
@since      01/11/2018
@version    12.1.17
@param      aDocument, array, informações da alçada
@return     aCardData, array contendo as informação do cardData
/*/
Static Function CardDataRV(aDocument, cLoginApr)

	Local aArea         := {}
	Local aCardData     := {}

	Local cDescricao    := ""
	Local cFilialCN9    := ""
	Local cLinhaDesc    := ""
	Local cNomeAprv     := ""

	Default aDocument   := {}
	Default cLoginApr   := ""

	aArea := {GetArea(), SCR->(GetArea()), CN9->(GetArea())}
	/*
	IF Type("nSCRRecno")=="N"
	If !(Empty(nSCRRecno))
	SCR->(DbSeek(nSCRRecno))
	EndIf
	Endif
	*/
	cNomeAprv := AllTrim(UsrFullName(SCR->CR_USER))
	cLoginApr := Identity(SCR->CR_USER)

	//TODO não existe valor referente a essa informação
	cDescricao += CRLF + "Revisão de Contratos"

	AAdd(aCardData, {"txt_empresa",         FwCodEmp()})
	AAdd(aCardData, {"txt_filial",              AllTrim(SCR->CR_FILIAL)})
	AAdd(aCardData, {"txt_nomefilial",          cNomeFil})
	AAdd(aCardData, {"txt_tipo",            aDocument[2]})
	AAdd(aCardData, {"txt_documento",       AllTrim(aDocument[1])})
	AAdd(aCardData, {"txt_nivel",           aDocument[DEF_NIVEL]})
	AAdd(aCardData, {"txt_descricao",       cDescricao})
	AAdd(aCardData, {"txt_data",            DToC(aDocument[10])})
	AAdd(aCardData, {"txt_valortotal",      AllTrim(Transform(aDocument[3], AllTrim(X3Picture("CR_TOTAL"))))})
	AAdd(aCardData, {"txt_nome_aprovador",  cNomeAprv})
	AAdd(aCardData, {"txt_login_aprovador", cLoginApr})
	AAdd(aCardData, {"txt_cod_usuario",     aDocument[5]})

	AEval(aArea, {|area| RestArea(area)})

Return aCardData

/*/{Protheus.doc} FluigInteg
Efetua a integração com o Fluig conforme operação informada.

nOperation: 1 = Envio de Alçada
Outros = Cancelamento de Alçada

@project
@type       Static Function
@author     Rafael Riego
@since      01/11/2018
@version    12.1.17
@param      nOperation, numeric, operação que deverá ser realizada 1-Envio/Demais=Cancelamento
@param      cUserFluig, character, usuário Fluig para realizar integração
@param      cPassFluig, character, senha do usuário Fluig para realizar integração
@param      nCompanyId, numeric, número da empresa no Fluig
@param      cProcessId, character, id do processo que será iniciado no Fluig
@param      cIdentity, character, identity referente ao usuário aprovador
@param      cComments, character, comentários de inicialização do processo
@param      oCardData, object, objeto cardData para envio ao Fluig
@param      nPrcInstId, numeric, número da instância (processo) criado no Fluig (utilizado somente no cancelamento)
@param      lCmpltTask, boolean, se deve completar a tarefa ou não
@param      lMngrMode, boolean, se deve executar como gerente ou não
@param      aSolicRH, array, informações das alçadas de RH
@param      lBackOffic, boolean, BackOffice se verdadeiro, RH caso falso
@param      oAttach, object, objeto de anexo
@return     aRetorno, [1] lRetorno, [2] InstanceId, [3] Mensagem de Resultado
/*/
Static Function FluigInteg(nOperation, cUserFluig, cPassFluig, nCompanyId, cProcessId, cIdentity, cComments, oCardData, nPrcInstId, lCmpltTask, lMngrMode, aSolicRH, lBackOffic, oAttach,aDocument)

	Local cUsrFlg := "2"
	Local lRetorno := .T.
	Local aRetorno := {}

	Default aDocument := {}

	If !U_fFilialEx("SAK")
		If AllTrim(SCR->CR_USER) == ""
			cUsrFlg := Posicione("SAK",02,FWxFilial("SAK")+cUsrAprov,'AK_XUSRFLG')    // 1 Para usuário FLUIG e 2 para Não
		Else
			cUsrFlg := Posicione("SAK",02,FWxFilial("SAK")+SCR->CR_USER,'AK_XUSRFLG')    // 1 Para usuário FLUIG e 2 para Não
		EndIf
	Else
		If AllTrim(SCR->CR_USER) == ""
			cUsrFlg := Posicione("SAK",02,SCR->CR_FILIAL+cUsrAprov,'AK_XUSRFLG')    // 1 Para usuário FLUIG e 2 para Não
		Else
			cUsrFlg := Posicione("SAK",02,SCR->CR_FILIAL+SCR->CR_USER,'AK_XUSRFLG')    // 1 Para usuário FLUIG e 2 para Não
		EndIf
	EndIf
	If AllTrim(cUsrFlg) != "S"
		lRetorno := .F.
		AAdd(aRetorno, lRetorno)
		AAdd(aRetorno, "")
		AAdd(aRetorno, "Envio cancelado, o usuário não está cadastrado no FLUIG ")
		Conout("----------------REDEDOR FLUIG--------------------------------------------")
		Conout("FLUIG - Envio de Alçada")
		Conout("FLUIG - Identity: " + cIdentity)
		Conout("FLUIG - O usuário " + cIdentity + " não está cadastrado no FLUIG ou não está como usuário FLUIG na SAK.")
		Conout("-------------------------------------------------------------------------")
		cRotina := "U_FLUIGP20"
		cAlias  := "SCR"
		cInput 	:= "U_FLUIGP20(,,,"+ AllTrim(SCR->CR_NUM) +")"
		If AllTrim(SCR->CR_TIPO) != "PC"
			cIndkey := "FLUIG|"+AllTrim(SCR->CR_FILIAL) + "|" + AllTrim(SCR->CR_NUM) + "|" + AllTrim(SCR->CR_TIPO)+ "|" + AllTrim(SCR->CR_NIVEL)+"|"+cProcessId
		Else
			If SolitPagto(AllTrim(SCR->CR_NUM), AllTrim(SCR->CR_TIPO))
				cTipo := "SP"
			Else
				cTipo := "PC"
			EndIf
			cIndkey := "FLUIG|"+AllTrim(SCR->CR_FILIAL) + "|" + AllTrim(SCR->CR_NUM) + "|" + AllTrim(cTipo)+ "|" + AllTrim(SCR->CR_NIVEL)+"|"+cProcessId
		EndIf
		If cOutput == ""
			cOutput := "FLUIG - O usuário " + cIdentity + " não está cadastrado no FLUIG ou não está como usuário FLUIG na SAK."
		Else
			cOutput  :=  cOutput + Chr(13) + Chr(10)  + "FLUIG - O usuário " + cIdentity + " não está cadastrado no FLUIG ou não está como usuário FLUIG na SAK."
		EndIf

		If "Login failed" $ cOutput .Or. "NOK" $ cOutput .Or. "Erro no cancelamento do processo" $ cOutput .Or. "ERRO" $ cOutput .Or. "Erro" $ cOutput .Or. "erro" $ cOutput
			cStatus := "1"
		Else
			cStatus := "2"
		EndIf
	Else
		If nOperation == 1 //Apenas quando for inclusão
			aRetorno := StartProce(cUserFluig, cPassFluig, nCompanyId, cProcessId, cIdentity, cComments, oCardData, lCmpltTask, lMngrMode, aSolicRH, lBackOffic, oAttach)
		ElseIf nOperation == 15 .Or. nOperation == 16//Apenas anexo de arquivos
			aRetorno := SaveNSendT(cUserFluig, cPassFluig, nCompanyId, nPrcInstId, cComments, cIdentity, lCmpltTask, lMngrMode, oAttach)
		Else
			aRetorno := CancInstan(cUserFluig, cPassFluig, nCompanyId, nPrcInstId, cIdentity, cComments,aDocument)
		EndIf
	EndIf
Return aRetorno

/*/{Protheus.doc} StartProce
Efetua a integração com o Fluig através do método startProcess presente no serviço WSECMWorkflowEngineServiceService.

@project
@type       Static Function
@author     Rafael Riego
@since      01/11/2018
@version    12.1.17
@param      cUserFluig, character, usuário Fluig para realizar integração
@param      cPassFluig, character, senha do usuário Fluig para realizar integração
@param      nCompanyId, numeric, número da empresa no Fluig
@param      cProcessId, character, id do processo que será iniciado no Fluig
@param      cIdentity, character, identity referente ao usuário aprovador
@param      cComments, character, comentários de inicialização do processo
@param      oCardData, object, objeto cardData para envio ao Fluig
@param      lCmpltTask, boolean, se deve completar a tarefa ou não
@param      lMngrMode, boolean, se deve executar como gerente ou não
@param      aSolicRH, array, informações das alçadas de RH
@param      lBackOffic, boolean, BackOffice se verdadeiro, RH caso falso
@param      oAttach, object, objeto de anexo
@return     aRetorno, [1] lRetorno, [2] InstanceId, [3] Mensagem de Resultado
/*/
Static Function StartProce(cUserFluig, cPassFluig, nCompanyId, cProcessId, cIdentity, cComments, oCardData, lCmpltTask, lMngrMode, aSolicRH, lBackOffic, oAttach)

	Local aRetorno          := {}
	Local aResultado        := {}
	Local lRetorno          := .T.

	Local nLinha            := 0
	Local nVarLen           := 0
	Local oAppointment      := Nil
	Local oUsers            := Nil
	Local oWSECMWf          := Nil
	Local cUsrFlg			:= "2"
	Local cStatus1 			:= ""

	cStatus := "1"
	cRotina := "U_FLUIGP20"
	cAlias  := "SCR"
	cInput := "U_FLUIGP20(,,,"+ AllTrim(SCR->CR_NUM) +")"

	If AllTrim(SCR->CR_TIPO) != "PC"
		cIndkey := "FLUIG|"+AllTrim(SCR->CR_FILIAL) + "|" + AllTrim(SCR->CR_NUM) + "|" + AllTrim(SCR->CR_TIPO)+ "|" + AllTrim(SCR->CR_NIVEL)+"|"+cProcessId
	Else
		If SolitPagto(AllTrim(SCR->CR_NUM), AllTrim(SCR->CR_TIPO))
			cTipo := "SP"
		Else
			cTipo := "PC"
		EndIf
		cIndkey := "FLUIG|"+AllTrim(SCR->CR_FILIAL) + "|" + AllTrim(SCR->CR_NUM) + "|" + AllTrim(cTipo)+ "|" + AllTrim(SCR->CR_NIVEL)+"|"+cProcessId
	EndIf

	If !U_fFilialEx("SAK")
		If AllTrim(SCR->CR_USER) == ""
			cUsrFlg := Posicione("SAK",02,FWxFilial("SAK")+cUsrAprov,'AK_XUSRFLG')    // 1 Para usuário FLUIG e 2 para Não
		Else
			cUsrFlg := Posicione("SAK",02,FWxFilial("SAK")+SCR->CR_USER,'AK_XUSRFLG')    // 1 Para usuário FLUIG e 2 para Não
		EndIf
	Else
		If AllTrim(SCR->CR_USER) == ""
			cUsrFlg := Posicione("SAK",02,SCR->CR_FILIAL+cUsrAprov,'AK_XUSRFLG')    // 1 Para usuário FLUIG e 2 para Não
		Else
			cUsrFlg := Posicione("SAK",02,SCR->CR_FILIAL+SCR->CR_USER,'AK_XUSRFLG')    // 1 Para usuário FLUIG e 2 para Não
		EndIf
	EndIf
	If AllTrim(cUsrFlg) != "S"
		lRetorno := .F.
		AAdd(aRetorno, lRetorno)
		AAdd(aRetorno, "")
		AAdd(aRetorno, "Envio cancelado, o usuário não está cadastrado no FLUIG ")
		Conout("----------------REDEDOR FLUIG--------------------------------------------")
		Conout("FLUIG - Envio de Alçada")
		Conout("FLUIG - Identity: " + cIdentity)
		Conout("FLUIG - O usuário " + cIdentity + " não está cadastrado no FLUIG ou não está como usuário FLUIG na SAK.")
		Conout("-------------------------------------------------------------------------")
		If cOutput == ""
			cOutput := "FLUIG - O usuário " + cIdentity + " não está cadastrado no FLUIG ou não está como usuário FLUIG na SAK."
		Else
			cOutput  :=  cOutput + Chr(13) + Chr(10)  + "FLUIG - O usuário " + cIdentity + " não está cadastrado no FLUIG ou não está como usuário FLUIG na SAK."
		EndIf
	Else

		nVarLen := SetVarNameLen(100)

		oWSECMWf    := WSECMWorkflowEngineServiceService():New()

		oAppointment    := oWSECMWf:oWSStartProcessAppointment
		oUsers          := oWSECMWf:oWSStartProcessColleagueIds

		AAdd(oUsers:cItem, cIdentity)//Aqui deverá ser colocado o login do usuário no Fluig

		If !Empty(oAttach:OWSITEM)
			oAttach:OWSITEM[1]:CFILENAME    := EncodeUTF8(oAttach:OWSITEM[1]:CFILENAME)
			oAttach:OWSITEM[1]:CDESCRIPTION := EncodeUTF8(oAttach:OWSITEM[1]:CDESCRIPTION)
			oAttach:OWSITEM[1]:OWSATTACHMENTS[1]:CFILENAME := EncodeUTF8(oAttach:OWSITEM[1]:OWSATTACHMENTS[1]:CFILENAME)
		EndIf

		If !lBackOffic
			U_F1700401(aSolicRH, @oUsers)
		EndIf

		//cusername,cpassword,ncompanyId,cprocessId,nchoosedState,colleagueIds,comments,cuserId,lcompleteTask,attachments,cardData,appointment,lmanagerMode
		If oWSECMWf:StartProcess( ;
		cUserFluig                ;   // Usuario integração
		, cPassFluig                ;   // Senha integracao
		, nCompanyId                ;   // Codigo da empresa integracao
		, cProcessId                ;   // Nome do processo
		, 5                         ;   // Proxima atividade. Passando zero ele calcula a proxima atividade automaticamente
		, oUsers                    ;   // StringArray com a lista de usuarios que vão receber a tarefa
		, cComments                 ;   // Cometario da tarefa
		, cIdentity                 ;   // Usuario que executou o processo Workflow
		, lCmpltTask                ;   // Completa ou não a atividade
		, oAttach                   ;   // Anexos
		, oCardData                 ;   // Dados da ficha (em formato gzip + base64)
		, oAppointment              ;   // Apontamentos
		, lMngrMode)                    // Modo manager

			AEval(oWSECMWf:oWSStartProcessResult:oWSItem, {|resultado| AAdd(aResultado, {resultado:cItem[1], resultado:cItem[2]})})

			nLinha := AScan(aResultado, {|resultado| Upper(resultado[1]) == "ERROR"})

			If nLinha == 0 //Caso de envio com sucesso
				nLinha := AScan(aResultado, {|tag| Upper(tag[1] ) == "IPROCESS"})
				Conout("Processo " + aResultado[nLinha][2] + " da tarefa " + cProcessId + " iniciado com sucesso!")
				AAdd(aRetorno, lRetorno)
				AAdd(aRetorno, aResultado[nLinha][2])
				AAdd(aRetorno, "Processo " + aResultado[nLinha][2] + " da tarefa " + cProcessId + " iniciado com sucesso!")
			Else
				lRetorno := .F.
				AAdd(aRetorno, lRetorno)
				AAdd(aRetorno, "")
				AAdd(aRetorno, "Erro: " + aResultado[nLinha][2])
			EndIf
		Else
			lRetorno := .F.
			AAdd(aRetorno, lRetorno)
			AAdd(aRetorno, "")
			AAdd(aRetorno, "Processo " + cProcessId + " iniciado com erro: " + GetWSCError())
		EndIf
		If Empty(aRetorno)
			Conout("FLUIG aRetorno vazio.(Não voltou resposta nenhuma do FLUIG.)")
		Else
			Conout("FLUIG - Envio de Alçada")
			Conout("FLUIG - Identity: " + cIdentity)
			Conout("FLUIG - Resultado: " + IIf(lRetorno, "OK - ", "NOK - ") + aRetorno[3])
			If cOutput == ""
				cOutput := aRetorno[3]
			Else
				cOutput  :=  cOutput + Chr(13) + Chr(10)  + aRetorno[3]
			EndIf
			If "iniciado com sucesso!" $ aRetorno[3]
				cStatus1 := "2"
			EndIf
		EndIf

		If cStatus1 == "2"
			cStatus := "2"
		EndIf

		SetVarNameLen(nVarLen)

	EndIf
Return aRetorno

/*/{Protheus.doc} CancInstan
Efetua a integração com o Fluig através do método CancelInstance presente no serviço WSECMWorkflowEngineServiceService.

@project
@type       Static Function
@author     Rafael Riego
@since      01/11/2018
@version    12.1.17
@param      cUserFluig, character, usuário Fluig para realizar integração
@param      cPassFluig, character, senha do usuário Fluig para realizar integração
@param      nCompanyId, numeric, número da empresa no Fluig
@param      nPrcInstId, numeric, número da instância (processo) criado no Fluig (utilizado somente no cancelamento)
@param      cIdentity, character, identity referente ao usuário aprovador
@param      cCancelTxt, character, texto de cancelamento
@return     aRetorno, [1] lRetorno, [2] InstanceId, [3] Mensagem de Resultado
/*/
Static Function CancInstan(cUserFluig, cPassFluig, nCompanyId, nPrcInstId, cIdentity, cCancelTxt,aDocument)

	Local aRetorno          := {}

	Local nVarLen           := 0

	Local oWSECMWf          := Nil
	Local cUsrFlg			:= "2"
	Local cStatus1			:= ""

	Default cCancelTxt      := "Cancelado por contingência."
	Default aDocument		:= {}

	nVarLen := SetVarNameLen(100)

	oWSECMWf := WSECMWorkflowEngineServiceService():New()

	If !U_fFilialEx("SAK")
		If AllTrim(SCR->CR_USER) == ""
			cUsrFlg := Posicione("SAK",02,FWxFilial("SAK")+cUsrAprov,'AK_XUSRFLG')    // 1 Para usuário FLUIG e 2 para Não
		Else
			cUsrFlg := Posicione("SAK",02,FWxFilial("SAK")+SCR->CR_USER,'AK_XUSRFLG')    // 1 Para usuário FLUIG e 2 para Não
		EndIf
	Else
		If AllTrim(SCR->CR_USER) == ""
			cUsrFlg := Posicione("SAK",02,cFilialAprov+cUsrAprov,'AK_XUSRFLG')    // 1 Para usuário FLUIG e 2 para Não
		Else
			cUsrFlg := Posicione("SAK",02,SCR->CR_FILIAL+SCR->CR_USER,'AK_XUSRFLG')    // 1 Para usuário FLUIG e 2 para Não
		EndIf
	EndIf
	If AllTrim(cUsrFlg) != "S"
		lRetorno := .F.
		AAdd(aRetorno, lRetorno)
		AAdd(aRetorno, "")
		AAdd(aRetorno, "CancelInstance não executado, o usuário não está cadastrado no FLUIG ")
		Conout("----------------REDEDOR FLUIG--------------------------------------------")
		Conout("FLUIG - Envio de Alçada")
		Conout("FLUIG - Identity: " + cIdentity)
		Conout("FLUIG - O usuário " + cIdentity + " não está cadastrado no FLUIG ou não está como usuário FLUIG na SAK.")
		Conout("-------------------------------------------------------------------------")
		cStatus := "1"
		cRotina := "U_FLUIGP20"
		If AllTrim(SCR->CR_NUM) == ""
			cInput := "U_FLUIGP20(,,,"+ aDocument[1]+ ")"
		Else
			cInput := "U_FLUIGP20(,,,"+ AllTrim(SCR->CR_NUM) +")"
		EndIf
		cAlias  := "SCR"
		If AllTrim(SCR->CR_TIPO) != "PC"
			If AllTrim(SCR->CR_FILIAL) != ""
				cIndkey := "FLUIG|"+AllTrim(SCR->CR_FILIAL) + "|" + AllTrim(aDocument[1]) + "|" + AllTrim(aDocument[2])+ "|" + AllTrim(cNivelAprov)+"|"+"Cancelamento de SC"
			Else
				cIndkey := "FLUIG|"+AllTrim(cFilialAprov) + "|" + AllTrim(aDocument[1]) + "|" + AllTrim(aDocument[2])+ "|" + AllTrim(cNivelAprov)+"|"+"Cancelamento de SC"
			EndIf
		Else
			If SolitPagto(AllTrim(aDocument[1]), AllTrim(aDocument[2]))
				cTipo := "SP"
			Else
				cTipo := "PC"
			EndIf
			If AllTrim(SCR->CR_FILIAL) != ""
				cIndkey := "FLUIG|"+AllTrim(SCR->CR_FILIAL) + "|" + AllTrim(aDocument[1]) + "|" + AllTrim(cTipo)+ "|" + AllTrim(cNivelAprov)+"|"+"Cancelamento de " + cTipo
			Else
				cIndkey := "FLUIG|"+AllTrim(cFilialAprov) + "|" + AllTrim(aDocument[1]) + "|" + AllTrim(cTipo)+ "|" + AllTrim(cNivelAprov)+"|"+"Cancelamento de " + cTipo
			EndIf
		EndIf

	Else
		cStatus := "1"
		cRotina := "U_FLUIGP20"
		If AllTrim(SCR->CR_NUM) == ""
			cInput := "U_FLUIGP20(,,,"+ aDocument[1]+ ")"
		Else
			cInput := "U_FLUIGP20(,,,"+ AllTrim(SCR->CR_NUM) +")"
		EndIf
		cAlias  := "SCR"

		If cOutput == ""
			cOutput :=  "O usuário "  + cIdentity + " não está cadastrado no FLUIG ou não está como usuário FLUIG na SAK."
		Else
			cOutput  :=  cOutput + Chr(13) + Chr(10)  + "O usuário "  + cIdentity + " não está cadastrado no FLUIG ou não está como usuário FLUIG na SAK."
		EndIf

		If AllTrim(SCR->CR_TIPO) != "PC"
			If AllTrim(SCR->CR_FILIAL) != ""
				cIndkey := "FLUIG|"+AllTrim(SCR->CR_FILIAL) + "|" + AllTrim(aDocument[1]) + "|" + AllTrim(aDocument[2])+ "|" + AllTrim(cNivelAprov)+"|"+"Cancelamento de SC"
			Else
				cIndkey := "FLUIG|"+AllTrim(cFilialAprov) + "|" + AllTrim(aDocument[1]) + "|" + AllTrim(aDocument[2])+ "|" + AllTrim(cNivelAprov)+"|"+"Cancelamento de SC"
			EndIf
		Else
			If SolitPagto(AllTrim(aDocument[1]), AllTrim(aDocument[2]))
				cTipo := "SP"
			Else
				cTipo := "PC"
			EndIf
			If AllTrim(SCR->CR_FILIAL) != ""
				cIndkey := "FLUIG|"+AllTrim(SCR->CR_FILIAL) + "|" + AllTrim(aDocument[1]) + "|" + AllTrim(cTipo)+ "|" + AllTrim(cNivelAprov)+"|"+"Cancelamento de " + cTipo
			Else
				cIndkey := "FLUIG|"+AllTrim(cFilialAprov) + "|" + AllTrim(aDocument[1]) + "|" + AllTrim(cTipo)+ "|" + AllTrim(cNivelAprov)+"|"+"Cancelamento de " + cTipo
			EndIf
		EndIf

		If oWSECMWf:CancelInstance( ;
		cUserFluig          ;   // Usuario integração
		, cPassFluig            ;   // Senha integracao
		, nCompanyId            ;   // Codigo da empresa integracao
		, nPrcInstId            ;   // número da solicitação
		, cIdentity             ;   // Usuario que executou o processo Workflow
		, cCancelTxt)               // Comentário do cancelamento

			cResultado := oWSECMWf:cResult

			If !(cResultado == "OK")
				AAdd(aRetorno, .F.)
				AAdd(aRetorno, "")
				AAdd(aRetorno, "Erro: " + cResultado)
			Else
				AAdd(aRetorno, .T.)
				AAdd(aRetorno, "")
				AAdd(aRetorno, "Processo " + CValToChar(nPrcInstId) + " cancelado com sucesso.")
			EndIf
		Else
			AAdd(aRetorno, .F.)
			AAdd(aRetorno, "")
			AAdd(aRetorno, "Erro no cancelamento do processo . " + CValToChar(nPrcInstId) + " - " + GetWSCError())
		EndIf

		If Empty(aRetorno)
			Conout("FLUIG aRetorno vazio.(Não voltou resposta nenhuma do FLUIG.)")
		Else
			If cOutput == ""
				cOutput := aRetorno[3]
			Else
				cOutput  :=  cOutput + Chr(13) + Chr(10)  + aRetorno[3]
			EndIf

			If " cancelado com sucesso." $ aRetorno[3] .Or. " invalida ou está inativa." $ aRetorno[3]
				cStatus1 := "2"
			EndIf
		EndIf
		If cStatus1 == "2"
			cStatus := "2"
		EndIf

		SetVarNameLen(nVarLen)
	EndIf
Return aRetorno

/*/{Protheus.doc} TipoSCR
Devolve o tipo de documento de alçada sendo executado.

@project
@type       Static Function
@author     Rafael Riego
@since      01/11/2018
@version    12.1.17
@param      cFunName, character, nome da função em execução
@return     cTipoDoc, tipo do documento de alçada
/*/
Static Function TipoSCR(cFunName)

	Local cTipoDoc  := ""

	Default cFunName  := FunName()

	If cFunName $ "MATA120|MATA121|F0100401"
		cTipoDoc    := "PC"
	ElseIf cFunName == "MATA110"
		cTipoDoc    := "SC"
	ElseIf cFunName == "CNTA300"
		cTipoDoc    := "CT"
	ElseIf cFunName == "XXXX"//TODO -> MEDIÇÃO DE CONTRATO
		cTipoDoc    := "MD"
	ElseIf cFunName == "YYYY"//TODO -> REVISÃO DE CONTRATO
		cTipoDoc    := "RV"
	EndIf

Return cTipoDoc

/*/{Protheus.doc} F1701102
Retorna os anexos do item do banco de conhecimento customizado.

@project
@type       User Function
@author     Rafael Riego
@since      01/11/2018
@version    12.1.17
@param      cIdentity, character, login do usuário no fluig
@param      nCompanyId, numeric, id da empresa no Fluig
@param      cCodigoP09, character, código origem referente a tabela de banco de conhecimento (anexos)
@param      lDelete, boolean, se deletado ou não
@param      nInstanceId, numeric, número de instancia (caso seja uma atualização de alçada)
@param      cSCRTipo, character, tipo do documento de alçada
@return     oAttach, objeto de anexo do Fluig
/*/
User Function F1701102(aAttach, cIdentity, nCompanyId, cCodigoP09, lDelete, nInstanceId, cSCRTipo)

	Local cAdmin    := ""

	Local oAttach   := Nil

	Local nAttach   := 0
	Local nQtdAnex  := 0

	Default aAttach     := {}
	Default cIdentity   := ""
	Default nCompanyId  := SuperGetMv("FS_EMPFLG", .F., 1)
	Default cCodigoP09  := ""
	Default lDelete     := .F.
	Default nInstanceId := 0
	Default cSCRTipo    := ""

	nQtdAnex := Len(aAttach)

	If nQtdAnex == 0 .And. !(Empty(cCodigoP09))
		aAttach := CarregAnexo(cCodigoP09, cSCRTipo)

		nQtdAnex := Len(aAttach)
	EndIf

	oProcessAttach    := ECMWorkflowEngineServiceService_ProcessAttachmentdToArray():New()

	If nQtdAnex > 0
		cAdmin := SuperGetMv("FS_USRFLG", .F., "admin")
		For nAttach := 1 To nQtdAnex
			//Anexar arquivo
			oAnexo := ECMWorkflowEngineServiceService_processAttachmentDto():New()

			oAnexo:cColleagueId                 := cAdmin
			oAnexo:cColleagueName               := cAdmin
			oAnexo:cDescription                 := aAttach[nAttach][FILE_NAME]
			oAnexo:cFileName                    := aAttach[nAttach][FILE_NAME]
			oAnexo:cPermission                  := "3"
			oAnexo:lDeleted                     := lDelete
			oAnexo:lNewAttach                   := .T.
			oAnexo:nAttachmentSequence          := nAttach
			oAnexo:nCompanyId                   := nCompanyId
			oAnexo:nOriginalMovementSequence    := 1
			oAnexo:nProcessInstanceId           := nInstanceId
			oAnexo:nVersion                     := 0
			oAnexo:nCRC                         := 0
			oAnexo:nSize                        := aAttach[nAttach][FILE_SIZE]

			oAttach := ECMWorkflowEngineServiceService_attachment():New()
			oAttach:lAttach         := .T.
			oAttach:lDescriptor     := .F.
			oAttach:lEditing        := .T.
			oAttach:cFileName       := aAttach[nAttach][FILE_NAME]
			oAttach:cFileContent    := aAttach[nAttach][FILE_CONT]
			oAttach:nFileSize       := aAttach[nAttach][FILE_SIZE]

			AAdd(oAnexo:oWSAttachments, oAttach)
			AAdd(oProcessAttach:oWSItem, oAnexo)
		Next nAttach
	EndIf

Return oProcessAttach

/*/{Protheus.doc} CarregAnexo
Carrega anexo da tabela P09.

@project
@type       Static Function
@author     Rafael Riego
@since      01/11/2018
@version    12.1.17
@param      cCodigoP09, character, código origem referente a tabela de banco de conhecimento (anexos)
@param      cSCRTipo, character, tipo do documento de alçada
@return     aAttach, array[n][1] nome_arquivo.extensao | array[n][2] conteudo do arquivo | array[n][3] tamanho do arquivo
/*/
Static Function CarregAnexo(cCodigoP09, cSCRTipo)

	Local aAttach       := {}
	Local aInfo         := {}

	Local cAliasTMP     := ""
	Local cArquivo      := ""
	Local cArqRed       := ""
	Local cClausu       := ""
	Local cFunName      := ""
	Local cQuery        := ""
	Local cWebAnexo     := ""

	Default cCodigoP09  := ""
	Default cSCRTipo    := ""

	cArqRed     := "\RDANEXOS\"
	cWebAnexo   := "\WEBANEXOS\"

	If !(Empty(cSCRTipo))
		If cSCRTipo == "CT"
			cClausu := " AND P09_ROTINA IN ('CNTA300') "
		ElseIf cSCRTipo == "PC"
			cClausu := " AND (P09_ROTINA = 'MATA121' OR P09_ROTINA = 'F0100401') "
		ElseIf cSCRTipo == "SC"
			cClausu := " AND P09_ROTINA IN ('MATA110') "
		ElseIf cSCRTipo == "RV"
			cClausu := "" //TODO -> REVISÃO DE CONTRATO
		ElseIf cSCRTipo == "MD"
			cClausu := ""//TODO -> MEDIÇÃO DE CONTRATO
		EndIf
	EndIf

	cQuery := "SELECT * "
	cQuery += " FROM " + RetSQLName("P09") + " P09 "
	cQuery += " WHERE P09.P09_FILIAL = '" + FwXFilial("P09") + "' "
	cQuery += "   AND P09.P09_CODORI = '" + cCodigoP09 + "' "
	cQuery += "   AND P09.D_E_L_E_T_ = ' ' "

	If !(Empty(cClausu))
		cQuery += cClausu
	EndIf

	cQuery := ChangeQuery(cQuery)

	cAliasTMP := MPSysOpenQuery(cQuery)

	While (cAliasTMP)->(!(EoF()))
		cArqZip     := cArqRed + (cAliasTMP)->P09_FILIAL + AllTrim((cAliasTMP)->P09_CODDOC) + ".MZP" //em caso de erro verificar função AbriArq() do fonte F0400101
		//        cArquivo    := cArqRed + (cAliasTMP)->P09_FILIAL + AllTrim((cAliasTMP)->P09_NOMDOC) // verificar de na inclusao so anexo passa por aqui
		cArquivo    := cArqRed + AllTrim((cAliasTMP)->P09_NOMDOC) // verificar de na inclusao so anexo passa por aqui

		If File(cArqZip)
			If MsDecomp(cArqZip, cArqRed, DF_SENHA) // ok no 2o nivel
				aInfo := {}
				aInfo := U_CopyConteu(cArquivo)
				AAdd(aAttach, {AllTrim((cAliasTMP)->P09_NOMDOC), aInfo[1], aInfo[2]})
				FErase(cArquivo)
				aInfo := Nil
			EndIf
		EndIf

		(cAliasTMP)->(DbSkip())
	End

	(cAliasTMP)->(DbCloseArea())

Return aAttach

/*/{Protheus.doc} F1701104
Carrega anexo da tabela P09.

@project
@type       User Function
@author     Rafael Riego
@since      01/11/2018
@version    12.1.17
@param      aAttach, array, aAttach[n][1] nome_arquivo.extensao | aAttach[n][2] conteudo do arquivo | aAttach[n][3] tamanho do arquivo
@param      cCodigoP09, character, código origem referente a tabela de banco de conhecimento (anexos)
@return     Nil
/*/
User Function F1701104(aAttach, cCodigoP09, lDeletado)

	Local aArea         := {}
	Local aRetorno      := {}

	Local cFilSCR       := ""
	Local cFunName      := ""
	Local cNumSCR       := ""
	Local cTipoSCR      := ""

	Local lBackOffic    := .T.

	Private cStatus := "1"
	Private cOutput := ""
	Private cRotina := "U_FLUIGP20"
	Private cAlias  := "SCR"
	Private cTipo    := ""
	Private cIndkey := ""
	Private cInput	:= ""
	Private aDocument	:= {}
	Private aDocument2	:= {}

	Default aAttach     := {}
	Default cCodigoP09  := ""

	aArea       := {SCR->(GetArea()), GetArea()}

	cFilSCR     := FwXFilial("SCR")
	cTipoSCR    := TipoSCR()
	cNumSCR     := PadR(U_F1701103(FunName())[1], TamSX3("CR_NUM")[1])

	SCR->(DbSetOrder(1))
	If SCR->(DbSeek(cFilSCR + cTipoSCR + cNumSCR))
		While SCR->(!(EoF())) .And.;
		SCR->CR_FILIAL == cFilSCR .And. SCR->CR_TIPO == cTipoSCR .And.;
		SCR->CR_NUM == cNumSCR
			If SCR->CR_STATUS == "02" .And. SCR->CR_XFLINTE == "2" .And. !(Empty(SCR->CR_XIDFLG))
				oAttach     := U_F1701102(aAttach, Identity(SCR->CR_USER),, cCodigoP09, lDeletado, Val(SCR->CR_XIDFLG))
				aRetorno    := U_F1700101(,, 15, Val(SCR->CR_XIDFLG),,, oAttach)
			EndIf
			SCR->(DbSkip())
		End
		U_F07Log03(cRotina,AllTrim(cInput),cOutput,cStatus,cAlias,1,cIndKey)
	EndIf

	AEval(aArea, {|area| RestArea(area)})

Return Nil

/*/{Protheus.doc} SaveNSendT
Efetua a integração com o Fluig através do método SaveAndSendTask presente no serviço WSECMWorkflowEngineServiceService.

@project
@type       Static Function
@author     Rafael Riego
@since      01/11/2018
@version    12.1.17
@param      cUserFluig, character, usuário Fluig para realizar integração
@param      cPassFluig, character, senha do usuário Fluig para realizar integração
@param      nCompanyId, numeric, número da empresa no Fluig
@param      nPrcInstId, numeric, número da instância (processo) criado no Fluig (utilizado somente no cancelamento)
@param      cComments, character, comentários de inicialização do processo
@param      cIdentity, character, identity referente ao usuário aprovador
@param      lCmpltTask, boolean, se deve completar a tarefa ou não
@param      lMngrMode, boolean, se deve executar como gerente ou não
@param      oAttach, object, objeto de anexo
@return     aRetorno, [1] lRetorno, [2] InstanceId, [3] Mensagem de Resultado
/*/
Static Function SaveNSendT(cUserFluig, cPassFluig, nCompanyId, nPrcInstId, cComments, cIdentity, lCmpltTask, lMngrMode, oAttach)

	Local aRetorno          := {}
	Local aResultado        := {}
	Local lRetorno          := .T.
	Local cUsrFlg			:= "2"
	Local cStatus1			:= ""

	Local nLinha            := 0
	Local nVarLen           := 0

	Local oAppointment      := Nil
	Local oWSECMWf          := Nil

	Default oAttach         := ECMWorkflowEngineServiceService_AttachmentArray():New()

	If !U_fFilialEx("SAK")
		If AllTrim(SCR->CR_USER) == ""
			cUsrFlg := Posicione("SAK",02,FWxFilial("SAK")+cUsrAprov,'AK_XUSRFLG')    // 1 Para usuário FLUIG e 2 para Não
		Else
			cUsrFlg := Posicione("SAK",02,FWxFilial("SAK")+SCR->CR_USER,'AK_XUSRFLG')    // 1 Para usuário FLUIG e 2 para Não
		EndIf
	Else
		If AllTrim(SCR->CR_USER) == ""
			cUsrFlg := Posicione("SAK",02,SCR->CR_FILIAL+cUsrAprov,'AK_XUSRFLG')    // 1 Para usuário FLUIG e 2 para Não
		Else
			cUsrFlg := Posicione("SAK",02,SCR->CR_FILIAL+SCR->CR_USER,'AK_XUSRFLG')    // 1 Para usuário FLUIG e 2 para Não
		EndIf
	EndIf
	If AllTrim(cUsrFlg) != "S"
		lRetorno := .F.
		AAdd(aRetorno, lRetorno)
		AAdd(aRetorno, "")
		AAdd(aRetorno, "Documento não anexado ao processo, o usuário não está cadastrado no FLUIG ")
		Conout("----------------REDEDOR FLUIG--------------------------------------------")
		Conout("FLUIG - Envio de Alçada")
		Conout("FLUIG - Identity: " + cIdentity)
		Conout("FLUIG - O usuário " + cIdentity + " não está cadastrado no FLUIG ou não está como usuário FLUIG na SAK.")
		Conout("-------------------------------------------------------------------------")

		cStatus := "1"
		cRotina := "U_FLUIGP20"
		cInput := "U_FLUIGP20(,,,"+ AllTrim(SCR->CR_NUM) +")"
		cAlias  := "SCR"

		If AllTrim(SCR->CR_TIPO) != "PC"
			cIndkey := "FLUIG|"+AllTrim(SCR->CR_FILIAL) + "|" + AllTrim(SCR->CR_NUM) + "|" + AllTrim(SCR->CR_TIPO)+ "|" + AllTrim(SCR->CR_NIVEL)+"|"+"SaveNSend"
		Else
			If SolitPagto(AllTrim(SCR->CR_NUM), AllTrim(SCR->CR_TIPO))
				cTipo := "SP"
			Else
				cTipo := "PC"
			EndIf
			cIndkey := "FLUIG|"+AllTrim(SCR->CR_FILIAL) + "|" + AllTrim(SCR->CR_NUM) + "|" + AllTrim(cTipo)+ "|" + AllTrim(SCR->CR_NIVEL)+"|"+"SaveNSend"
		EndIf
		If cOutput == ""
			cOutput := "FLUIG - O usuário " + cIdentity + " não está cadastrado no FLUIG ou não está como usuário FLUIG na SAK."
		Else
			cOutput  :=  cOutput + Chr(13) + Chr(10)  + "FLUIG - O usuário " + cIdentity + " não está cadastrado no FLUIG ou não está como usuário FLUIG na SAK."
		EndIf

		Return aRetorno
	Else
		cStatus := "1"
		cRotina := "U_FLUIGP20"
		cInput := "U_FLUIGP20(,,,"+ AllTrim(SCR->CR_NUM) +")"
		cAlias  := "SCR"

		If AllTrim(SCR->CR_TIPO) != "PC"
			cIndkey := "FLUIG|"+AllTrim(SCR->CR_FILIAL) + "|" + AllTrim(SCR->CR_NUM) + "|" + AllTrim(SCR->CR_TIPO)+ "|" + AllTrim(SCR->CR_NIVEL)+"|"+"SaveNSend"
		Else
			If SolitPagto(AllTrim(SCR->CR_NUM), AllTrim(SCR->CR_TIPO))
				cTipo := "SP"
			Else
				cTipo := "PC"
			EndIf
			cIndkey := "FLUIG|"+AllTrim(SCR->CR_FILIAL) + "|" + AllTrim(SCR->CR_NUM) + "|" + AllTrim(cTipo)+ "|" + AllTrim(SCR->CR_NIVEL)+"|"+"SaveNSend"
		EndIf

		nVarLen := SetVarNameLen(100)

		oWSECMWf    := WSECMWorkflowEngineServiceService():New()

		oAppointment    := oWSECMWf:oWSSaveAndSendTaskAppointment
		oUsers          := oWSECMWf:oWSSaveAndSendTaskColleagueIds
		oCardData       := oWSECMWf:oWSSaveAndSendTaskCardData

		AAdd(oUsers:cItem, cIdentity)//Aqui deverá ser colocado o identity do usuário
		//Encode no nome do arquivo para não dar erro de UTF8 no envio para o FLUIG(Arquivos com caractere especial no nome)
		oAttach:OWSITEM[1]:CFILENAME    := EncodeUTF8(oAttach:OWSITEM[1]:CFILENAME)
		oAttach:OWSITEM[1]:CDESCRIPTION := EncodeUTF8(oAttach:OWSITEM[1]:CDESCRIPTION)
		oAttach:OWSITEM[1]:OWSATTACHMENTS[1]:CFILENAME := EncodeUTF8(oAttach:OWSITEM[1]:OWSATTACHMENTS[1]:CFILENAME)
		//String user, String password, int companyId, int processInstanceId, int choosedState, String[] colleagueIds, String comments,
		//String userId, boolean completeTask, ProcessAttachmentDto[] attachments, String[][] cardData, ProcessTaskAppointmentDto[] appointment,
		//boolean managerMode, int threadSequence)
		If oWSECMWf:SaveAndSendTask( ;
		cUserFluig              ;   // Usuario integração
		, cPassFluig                ;   // Senha integracao
		, nCompanyId                ;   // Codigo da empresa integracao
		, nPrcInstId                ;   // número da solicitação
		, 5                         ;   // Proxima atividade. Passando zero ele calcula a proxima atividade automaticamente
		, oUsers                    ;   // StringArray com a lista de usuarios que vão receber a tarefa
		, cComments                 ;   // Cometario da tarefa
		, cIdentity                 ;   // Usuario que executou o processo Workflow
		, lCmpltTask                ;   // Completa ou não a atividade
		, oAttach                   ;   // Anexos
		, oCardData                 ;   // Dados da ficha (em formato gzip + base64)
		, oAppointment              ;   // Apontamentos
		, lMngrMode                 ;   // Se executa tarefa como gerente ou não
		, 0                         ;   //
		)

			AEval(oWSECMWf:oWSsaveAndSendTaskResult:oWsItem, {|resultado| AAdd(aResultado, {resultado:cItem[1], resultado:cItem[2]})})

			nLinha := AScan(aResultado, {|resultado| Upper(resultado[1]) == "WDNRDOCTO"})

			If nLinha > 0 //Caso de envio com sucesso
				Conout("Documento " + aResultado[nLinha][2] + " da tarefa " + Str(nPrcInstId) + " anexado com sucesso!")
				AAdd(aRetorno, lRetorno)
				AAdd(aRetorno, aResultado[nLinha][2])
				AAdd(aRetorno, "Documento " + aResultado[nLinha][2] + " da tarefa " + Str(nPrcInstId) + " anexado com sucesso!")
			Else
				lRetorno := .F.
				AAdd(aRetorno, lRetorno)
				AAdd(aRetorno, "")
				AAdd(aRetorno, "Erro: Não foi possivel integrar:" + GetWSCError())
			EndIf
		Else
			lRetorno := .F.
			AAdd(aRetorno, lRetorno)
			AAdd(aRetorno, "")
			AAdd(aRetorno, {"Documento não anexado ao processo devido a erro : " + GetWSCError()})
		EndIf
		If Empty(aRetorno)
			Conout("FLUIG aRetorno vazio.(Não voltou resposta nenhuma do FLUIG.)")
		Else

			If cOutput == ""
				cOutput := aRetorno[3]
			Else
				cOutput  :=  cOutput + Chr(13) + Chr(10)  + aRetorno[3]
			EndIf

			If " anexado com sucesso!" $ aRetorno[3]
				cStatus1 := "2"
			EndIf
		EndIf
		If cStatus1 == "2"
			cStatus := "2"
		EndIf

		SetVarNameLen(nVarLen)
	EndIf
Return aRetorno

User Function fFilialEx(cTab)
	Local cRetorno := ""
	Local lRet := .F.

	//Início - Thais Paiva - Compatibilização P27
	//If SX2->(DbSeek(cTab))
	
		//cRetorno := SX2->X2_MODO
	aReturn:= FwSX2Util():GetSX2data(cTab, {"X2_MODO"})
	
	If Len(aReturn) > 0
		cRetorno := aReturn[1][2] 
	Endif
	//Fim - Thais Paiva - Compatibilização P27
	
	If cRetorno == "E"
		lRet := .T.
	EndIf

Return lRet

Static Function NomFil(cFil)

	Local aAreaSM0 := SM0->(GetArea())
	Local cNomeFil := ""

	Default cFil := ""

	cNomeFil := AllTrim(Posicione("SM0",1,"01"+cFil,"M0_FILIAL"))

	RestArea(aAreaSM0)

Return cNomeFil