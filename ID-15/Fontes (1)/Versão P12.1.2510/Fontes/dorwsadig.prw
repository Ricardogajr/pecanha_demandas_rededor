#INCLUDE "totvs.ch"
#INCLUDE "RESTFUL.CH"
#Include "FWMVCDEF.CH"

/*/{Protheus.doc} DORWSADIG
description: WebServices Rest de admissão digital.
@type function
@version 1.0 
@author Laura Peghini 
@since 07/05/2025
@return variant, return_description
/*/ 

WSRESTFUL DORWSADIG DESCRIPTION "Metodo disponível para Admissão Digital" FORMAT APPLICATION_JSON_TYPE

	WSMETHOD POST DESCRIPTION "Metodo para inclui da FAP." 			 		WSSYNTAX "/api/admdig/v1/dorwsadig"  PATH "/api/admdig/v1/dorwsadig" PRODUCES APPLICATION_JSON
	WSMETHOD PUT  DESCRIPTION "Metodo para alteração status da FAP." 		WSSYNTAX "/api/admdig/v1/dorwsadig"  PATH "/api/admdig/v1/dorwsadig" PRODUCES APPLICATION_JSON
    WSMETHOD POST ID  DESCRIPTION "Metodo para consultar status da FAP." 	WSSYNTAX "/api/admdig/v1/dorwsadig/get"  PATH "/api/admdig/v1/dorwsadig/get" PRODUCES APPLICATION_JSON
	/*alteraçao por limitação da ferramenta fluig troca do get para post, conforme solicitado pela equipe da Digite*/
	//WSMETHOD GET  DESCRIPTION "Metodo para consultar status da FAP." 	WSSYNTAX "/api/admdig/v1/dorwsadig"  PATH "/api/admdig/v1/dorwsadig" PRODUCES APPLICATION_JSON

END WSRESTFUL


WSMETHOD POST WSSERVICE DORWSADIG

Local aArea 	:= GetArea()
Local cjson 	:= Self:GetContent()
Local oJson 	:= JsonObject():New()
Local aRetFAP	:= {}
Local cCodFAP	:= ""

Private cRetJson 	:= ""
Private cRequisit 	:= ""

	::SetContentType("application/json;charset=utf-8")
	::SetHeader("Accept","application/json;charset=utf-8")

	oJson:FromJson(cjson)

	//Loga na empresa e filial.
	RpcSetEnv("01", oJson["FILIAL"])

	cRequisit := oJson["REQUISITANTE"]
	aRetUsr := U_ValidUsa()
	If aRetUsr[1]
		cCpfUsr := StrTokArr(oJson["REQUISITANTE"],"@")
		If cUserName <> cCpfUsr[1]
			cUserName := cCpfUsr[1]
		EndIf
		cRetCur	:= SetCurriculum(oJson,cjson)
		aRetFAP := IncFAP(oJson,cRetCur)
		If aRetFAP[1]
			If aRetFAP[2][1] == "SUCESSO"
				cCodFAP := aRetFAP[2][3]
				cMsgError := "FAP criada com sucesso!"
			Else
				cCodFAP := aRetFAP[2][3]
				cMsgError := aRetFAP[2][2]
			EndIf
		Else
			cCodFAP := aRetFAP[2][3]
			cMsgError := aRetFAP[2][2]
		EndIf
		fResp(aRetFAP[1], cCodFAP, cMsgError)		
	Else
		fResp(.F., "", 'Usuário não tem permissão.')	
	EndIf

	::setResponse(cRetJson)

	RestArea(aArea)

Return .T.

//WSMETHOD GET WSSERVICE DORWSADIG
WSMETHOD POST ID WSSERVICE DORWSADIG

Local lRet       := .T.
Local lAcho		 := .F.
Local jResponse  := JsonObject():New()
Local cjson 	 := Self:GetContent()
Local oJson 	 := JsonObject():New()
Local aCmpJson 	 := oJson:GetNames()
Local cSttFAP	 := ""
Local cCdStFAP	 := ""
Local cFicMed	 := ""
Local cNumFAP	 := ""
Local cFilFAP	 := ""
Local cQualiFunc := ""
Local cCpfUsr 	 := ""

Private cRequisit 	:= ""

	::SetContentType("application/json;charset=utf-8")
	::SetHeader("Accept","application/json;charset=utf-8")

	oJson:FromJson(cjson)
	aCmpJson := oJson:GetNames()

	//Loga na empresa e filial.
	RpcSetEnv("01", oJson["FILIAL"] )

	cRequisit := oJson["REQUISITANTE"]
	aRetUsr := U_ValidUsa()
	If aRetUsr[1]
		cCpfUsr := StrTokArr(oJson["REQUISITANTE"],"@")
		If cUserName <> cCpfUsr[1]
			cUserName := cCpfUsr[1]
		EndIf
		//Consulta status da FAP
		If aScan(aCmpJson, {|x| AllTrim(x) == "FAP" }) > 0	
			DbSelectArea("PA2")
			PA2->(DbSetOrder(6)) 
			If PA2->(DbSeek(oJson["FILIAL"] + oJson["FAP"]))
				If AllTrim(PA2->PA2_XORIGE) == '2'
					cNumFAP := PA2->PA2_SOL
					cFilFAP := PA2->PA2_FILIAL
					//se status permite ou não proceguir com o processo	
					If PA2->PA2_SIT $ ("AP/RI")				
						If PA2->PA2_SIT == 'RI' 
							cFicMed := U_DORADFMED(PA2->PA2_FILIAL, PA2->PA2_CDCAND, PA2->PA2_CDVAGA)
							U_ExameDocto( PA2->PA2_FILIAL, PA2->PA2_SOL, PA2->PA2_CDVAGA, PA2->PA2_FILSOL, PA2->PA2_SOL )
						EndIf
						cCdStFAP := Posicione("PA2",6,cFilFAP+cNumFAP,"PA2_SIT")
						Do Case
							Case cCdStFAP == 'AP'
								cSttFAP := "AP - Em admissão"
							Case cCdStFAP == 'AG'
								cSttFAP := "AG - Aguardando Aprovação"
							Case cCdStFAP == 'RE'
								cSttFAP := "RE - Reprovado"
							Case cCdStFAP == 'CL'
								cSttFAP := "CL - Concluído"
							Case cCdStFAP == 'RI'
								cSttFAP := "RI - Aguandando Efetivação do RH"
						EndCase		
						jResponse['STATUS'] := .T.
						jResponse['MSG'] 	:= cSttFAP
						jResponse['FMED'] 	:= cFicMed
					Else
						Do Case
							Case PA2->PA2_SIT == 'AP'
								cSttFAP := "AP - Em admissão"
							Case PA2->PA2_SIT == 'AG'
								cSttFAP := "AG - Aguardando Aprovação"
							Case PA2->PA2_SIT == 'RE'
								cSttFAP := "RE - Reprovado"
							Case PA2->PA2_SIT == 'CL'
								cSttFAP := "CL - Concluído"
							Case PA2->PA2_SIT == 'RI'
								cSttFAP := "RI - Aguandando Efetivação do RH"
						EndCase		
						jResponse['STATUS'] := .F.
						jResponse['MSG'] 	:= cSttFAP
					EndIf
				Else
					jResponse['STATUS'] := .F.
					jResponse['MSG'] 	:= 'Processo não permitido.'
				EndIf
			Else
				jResponse['STATUS'] := .F.
				jResponse['MSG'] 	:= 'FAP não encontrada.'
			EndIf
			PA2->(DbCloseArea())
		EndIf
		
		//Consulta status da vaga
		If aScan(aCmpJson, {|x| AllTrim(x) == "VAGA" }) > 0
			DbSelectArea("SQS")
			If !Empty(oJson["VAGA"])				
				SQS->(DbSetOrder(1))
				If SQS->(DbSeek(oJson["FILIAL"] + oJson["VAGA"]))
					lAcho 		:= .T.
					cStatus 	:= SQS->QS_XSTATUS
					nValor 		:= SQS->QS_VCUSTO
					cCCusto		:= SQS->QS_CC
					cFuncao		:= SQS->QS_FUNCAO
					nJornad		:= SQS->QS_XJORN
					cTurno		:= Alltrim(SQS->QS_XTURNO)
					cSolicit	:= Alltrim(SQS->QS_SOLICIT)
					dDtAbert	:= DtoC(SQS->QS_DTABERT)
					cTipo		:= SQS->QS_TIPO
					cPortal		:= SQS->QS_XSOLPTL
					cFilPor		:= SQS->QS_XSOLFIL
					cAnResp		:= Alltrim(SQS->QS_XANRESP)
					cDescri		:= Alltrim(SQS->QS_DESCRIC)
					cPosto		:= SQS->QS_POSTO
					cFilPost	:= SQS->QS_FILPOST
					cCdVaga		:= SQS->QS_VAGA
					cDepto		:= Posicione("RCL",2,SQS->QS_FILPOST+SQS->QS_POSTO,"RCL_DEPTO")
				EndIf
			Else
				SQS->(DbSetOrder(6))
				If SQS->(DbSeek(oJson["FILIAL"] + oJson["PORTAL"]))
					lAcho 		:= .T.
					cStatus 	:= SQS->QS_XSTATUS
					nValor 		:= SQS->QS_VCUSTO
					cCCusto		:= SQS->QS_CC
					cFuncao		:= SQS->QS_FUNCAO
					nJornad		:= SQS->QS_XJORN
					cTurno		:= Alltrim(SQS->QS_XTURNO)
					cSolicit	:= Alltrim(SQS->QS_SOLICIT)
					dDtAbert	:= DtoC(SQS->QS_DTABERT)
					cTipo		:= SQS->QS_TIPO
					cPortal		:= SQS->QS_XSOLPTL
					cFilPor		:= SQS->QS_XSOLFIL
					cAnResp		:= Alltrim(SQS->QS_XANRESP)
					cDescri		:= Alltrim(SQS->QS_DESCRIC)
					cPosto		:= SQS->QS_POSTO
					cFilPost	:= SQS->QS_FILPOST
					cCdVaga		:= SQS->QS_VAGA
					cDepto		:= Posicione("RCL",2,SQS->QS_FILPOST+SQS->QS_POSTO,"RCL_DEPTO")
				EndIf
			EndIf			
			If lAcho
				cQualiFunc := CheckQualific( oJson["FILIAL"], cCdVaga ) 
				Do Case
					Case cStatus == '1'
						cSttFAP := "Em admissão"
					Case cStatus == '2'
						cSttFAP := "Em Recrutamento"
					Case cStatus == '3'
						cSttFAP := "Em Movimentação (RI)"
					Case cStatus == '4'
						cSttFAP := "Cadastro"
					Case cStatus == '5'
						cSttFAP := "Cacelada"
					Case cStatus == '6'
						cSttFAP := "Suspensa"
					Case cStatus == '7'
						cSttFAP := "Concluída"
					Case cStatus == '8'
						cSttFAP := "Exame-Docto"
					Case cStatus == '9'
						cSttFAP := "Ass.Contrato"
				EndCase	
				If !(cStatus $ ("5/6/7"))
					jResponse['STATUS'] 	:= .T.
					jResponse['MSG'] 		:= cStatus +" - " + cSttFAP
					jResponse['VALOR'] 		:= nValor
					jResponse['CC'] 		:= cCCusto
					jResponse['FUNCAO'] 	:= cFuncao
					jResponse['XJORN'] 		:= nJornad
					jResponse['XTURNO'] 	:= cTurno
					jResponse['SOLICIT'] 	:= cSolicit
					jResponse['DTABERT'] 	:= dDtAbert
					jResponse['TIPO'] 		:= cTipo
					jResponse['XSOLPTL'] 	:= cPortal
					jResponse['XSOLFIL'] 	:= cFilPor
					jResponse['XANRESP'] 	:= cAnResp
					jResponse['DESCRIC'] 	:= cDescri
					jResponse['POSTO'] 		:= cPosto
					jResponse['FILPOST'] 	:= cFilPost
					jResponse['CDVAGA'] 	:= cCdVaga
					jResponse['DEPTO'] 		:= cDepto
					jResponse['QUALIFIC'] 	:= Alltrim(cQualiFunc)
				Else
					jResponse['STATUS'] 	:= .F.
					jResponse['MSG'] 		:= cStatus +" - " + cSttFAP
					jResponse['VALOR'] 		:= 0
					jResponse['CC'] 		:= cCCusto
					jResponse['FUNCAO'] 	:= cFuncao
					jResponse['XJORN'] 		:= 0
					jResponse['XTURNO'] 	:= cTurno
					jResponse['SOLICIT'] 	:= cSolicit
					jResponse['DTABERT'] 	:= dDtAbert
					jResponse['TIPO'] 		:= cTipo
					jResponse['XSOLPTL'] 	:= cPortal
					jResponse['XSOLFIL'] 	:= cFilPor
					jResponse['XANRESP'] 	:= cAnResp
					jResponse['DESCRIC'] 	:= cDescri
					jResponse['POSTO'] 		:= cPosto
					jResponse['FILPOST'] 	:= cFilPost
					jResponse['CDVAGA'] 	:= cCdVaga
					jResponse['DEPTO'] 		:= cDepto
					jResponse['QUALIFIC'] 	:= Alltrim(cQualiFunc)
				EndIf
			Else
				jResponse['STATUS'] 	:= .F.
				jResponse['MSG'] 		:= 'Vaga não encontrada'
				jResponse['VALOR'] 		:= 0
				jResponse['CC'] 		:= ""
				jResponse['FUNCAO'] 	:= ""
				jResponse['XJORN'] 		:= 0
				jResponse['XTURNO'] 	:= ""
				jResponse['SOLICIT'] 	:= ""
				jResponse['DTABERT'] 	:= ""
				jResponse['TIPO'] 		:= ""
				jResponse['XSOLPTL'] 	:= ""
				jResponse['XSOLFIL'] 	:= ""
				jResponse['XANRESP'] 	:= ""
				jResponse['DESCRIC'] 	:= ""
				jResponse['POSTO'] 		:= ""
				jResponse['FILPOST'] 	:= ""
				jResponse['CDVAGA'] 	:= ""
				jResponse['DEPTO'] 		:= ""
				jResponse['QUALIFIC'] 	:= ""
			EndIf
			SQS->(DbCloseArea())
		EndIf
	Else
		jResponse['STATUS'] := .F.
		jResponse['MSG'] := 'Usuário não tem permissão.'
	EndIf
		
	//Define o retorno
	Self:SetContentType('application/json')
	Self:SetResponse(jResponse:toJSON())

Return lRet

WSMETHOD PUT WSSERVICE DORWSADIG

Local aArea 	:= GetArea()
Local cjson 	:= Self:GetContent()
Local oJson 	:= JsonObject():New()
Local jResponse := JsonObject():New()
Local aRetAlt	:= {}
Local aRetUsr	:= {}

Private cRetJson 	:= ""
Private cRequisit 	:= ""

	::SetContentType("application/json;charset=utf-8")
	::SetHeader("Accept","application/json;charset=utf-8")

	oJson:FromJson(cjson)
	aCmpJson := oJson:GetNames()

	//Loga na empresa e filial.
	RpcSetEnv("01", oJson["FILIAL"] )

	cRequisit := oJson["REQUISITANTE"]
	aRetUsr := U_ValidUsa()
	If aRetUsr[1]
		cCpfUsr := StrTokArr(oJson["REQUISITANTE"],"@")
		If cUserName <> cCpfUsr[1]
			cUserName := cCpfUsr[1]
		EndIf
		If !Empty(oJson["VAGA"])
			aRetAlt := U_DORALTVAG( oJson["STATUS"], oJson["FILIAL"], oJson["FAP"], oJson["MOTIVO"], oJson["VAGA"] )	
			jResponse['STATUS'] := aRetAlt[1]	
			jResponse['MSG'] 	:= aRetAlt[2]	
		Else
			DbSelectArea("PA2")
			PA2->(DbSetOrder(6)) 
			If PA2->(DbSeek(oJson["FILIAL"] + oJson["FAP"]))
				If AllTrim(PA2->PA2_XORIGE)  == '2'
					aRetAlt := U_DORALTVAG( oJson["STATUS"], oJson["FILIAL"], oJson["FAP"], oJson["MOTIVO"], oJson["VAGA"] )	
					jResponse['STATUS'] := aRetAlt[1]	
					jResponse['MSG'] 	:= aRetAlt[2]	
				Else
					jResponse['STATUS'] := .F.
					jResponse['MSG'] 	:= 'Processo não permitido.'
				EndIf	
			Else
				jResponse['STATUS'] := .F.
				jResponse['MSG'] 	:= 'FAP não encontrada.'	
			EndIf
			PA2->(DbCloseArea())	
		EndIf	
	Else
		jResponse['STATUS'] := .F.
		jResponse['MSG'] 	:= 'Usuário não tem permissão.'
	EndIf

	//Define o retorno
	Self:SetContentType('application/json')
	Self:SetResponse(jResponse:toJSON())

	RestArea(aArea)

Return .T.

/*/{Protheus.doc} SetCurriculum
//Função de encapsulamento da gravação do currículo
@author Laura Peghini
@since 14/05/2025
@version 1.0
@param oJson, object, descricao
@return return, return_description
/*/
Static Function SetCurriculum(oJson,cBody)

Local cSeek			As Character
Local nx			As Integer
Local lAlter		As Logical
Local aCampos		As Array
Local lRetorno  	As Logical
Local nSaveSX8 		As Integer
Local cRetSqlName	:= ""

Private cCdCurric	As Character

	//===============================================
	//ANALISE DOS DADOS ENVIADOS ANTES DE COMEÇAR 	||
	// O PREENCHIMENTO DA TABELA COM OS MESMOS		||
	//=============================================== 
	lRetorno:= .T.
	lAlter	:= .F.
	nSaveSX8:= GetSX8Len()
	
	//======================================
	//CARREGAMENTO DO ACAMPOS EM UMA FUNÇÃO 
	//PARA FACILITAR A LEITURA DO FONTE. 
	//======================================
	fCargArraySQG(@aCampos,oJson)

	Begin Transaction
		cRetSqlName := RetSqlName( "SQG" )+"\3"
		dbSelectArea("SQG")
		SQG->(dbSetOrder(3))//QG_FILIAL+QG_CIC
		cSeek := xFilial("SQG")+oJson["CIC"]
		If SQG->(dbSeek(cSeek))
			cCdCurric := SQG->QG_CURRIC
		Else			//Inclusao
			DbSelectArea("SQG")
			/*COMPATIBILIZADO COM A ROTINA RSPA010 - LAURA PEGHINI 02/03/2026
			cRetSqlName := RetSqlName( "SQG" )+"\3"
			nCodSQG:= (Val(GetSXENum("SQG","QG_CURRIC",xFilial('SQG')+cRetSqlName)))
			cCodSQG:= STRZero(nCodSQG,6)
			M->&(Eval(bCampo,nI)):= cCodSQG*/
			cCdCurric		:= 	GetSx8Num("SQG","QG_CURRIC",xFilial('SQG')+cRetSqlName) //GetSx8Num("SQG","QG_CURRIC")
			SQG->(Reclock("SQG",.T.))
				SQG->QG_FILIAL		:=	xFilial("SQG")//Filial
				SQG->QG_CURRIC		:= cCdCurric
				//==============================================================
				// GRAVA TODOS OS CAMPOS PADROES (CARACTER) UTILIZANDO PICTURE
				//==============================================================
				For nx := 1 To Len(aCampos)		
					If aCampos[nx][1] == "XOBS"
						If nInc== 0 
							APDMSMM(,TamSX3("XOBS")[1],,aCampos[nx][2],1,,,"SQG","XOBS")
						Else
							APDMSMM(SQG->XOBS  ,TamSX3("XOBS")[1],,aCampos[nx][2],1,,,"SQG","XOBS")
						EndIf 
					Else
						If !Empty(aCampos[nx][3]) .And.  Valtype(&(aCampos[nx][1])) == "C"
							SQG->( FieldPut(FieldPos(aCampos[nx][1]), Transform(aCampos[nx][2], aCampos[nx][3] ) ) )
						Else
							SQG->( FieldPut(FieldPos(aCampos[nx][1]), aCampos[nx][2]) )
						EndIf
					EndIf
				Next nx
				SQG->(ConfirmSX8())
			SQG->(MsUnlock())		
		EndIf
		SQG->(DbCloseArea())
	End Transaction

Return cCdCurric


/*/{Protheus.doc} fCargArraySQG
//Montagem do Array para carregar dados a serem enviados para SQG
@author Laura Peghini
@since 14/05/2025
@return return, return_description
@param aCampos, array, descricao
@param jCandit, , descricao
/*/
Static Function fCargArraySQG(aCampos,jCandit)

	DEFAULT aCampos 	:= {}

	aCampos:= { {"QG_AREA"		, DecodeUtf8(jCandit:GetJsonText("AREA"))						,X3Picture("QG_AREA") 		},;   
				{"QG_NOME"		, DecodeUtf8(jCandit:GetJsonText("NOME"))						,X3Picture("QG_NOME") 		},;   	
				{"QG_ENDEREC"	, DecodeUtf8(jCandit:GetJsonText("ENDEREC"))					,X3Picture("QG_ENDEREC") 	},;		
				{"QG_COMPLEM"	, DecodeUtf8(jCandit:GetJsonText("COMPLEM"))					,X3Picture("QG_COMPLEM") 	},;	
				{"QG_BAIRRO"	, DecodeUtf8(jCandit:GetJsonText("BAIRRO"))						,X3Picture("QG_BAIRRO") 	},; 	
				{"QG_MUNICIP"	, DecodeUtf8(jCandit:GetJsonText("MUNICIP"))					,X3Picture("QG_MUNICIP") 	},;	
				{"QG_ESTADO"	, UPPER(jCandit:GetJsonText("ESTADO"))							,X3Picture("QG_ESTADO") 	},; 	
				{"QG_CEP"		, jCandit:GetJsonText("CEP")									,X3Picture("QG_CEP") 		},;   	
				{"QG_FONE"		, jCandit:GetJsonText("FONE")									,X3Picture("QG_FONE") 		},;   	
				{"QG_EMAIL"		, jCandit:GetJsonText("EMAIL")									,X3Picture("QG_EMAIL") 		},;  	
				{"QG_FONECEL"	, jCandit:GetJsonText("FONECEL")								,X3Picture("QG_FONECEL") 	},;	
				{"QG_FONECOM"	, jCandit:GetJsonText("FONECOM")								,X3Picture("QG_FONECOM") 	},;
				{"QG_RG"		, jCandit:GetJsonText("RG")										,X3Picture("QG_RG") 		},;     	
				{"QG_CIC"		, jCandit:GetJsonText("CIC")									,X3Picture("QG_CIC") 		},;						
				{"QG_NUMCP"		, jCandit:GetJsonText("NUMCP")									,X3Picture("QG_NUMCP") 		},;
				{"QG_SERCP"		, jCandit:GetJsonText("SERCP")									,X3Picture("QG_SERCP") 		},;
				{"QG_UFCP"		, UPPER(jCandit:GetJsonText("UFCP"))							,X3Picture("QG_UFCP") 		},;
				{"QG_HABILIT"	, jCandit:GetJsonText("HABILIT")								,X3Picture("QG_HABILIT") 	},;
				{"QG_RESERV"	, jCandit:GetJsonText("RESERV")									,X3Picture("QG_RESERV") 	},;
				{"QG_TITULOE"	, jCandit:GetJsonText("TITULOE")								,X3Picture("QG_TITULOE") 	},;
				{"QG_ZONASEC"	, jCandit:GetJsonText("ZONASEC")								,X3Picture("QG_ZONASEC") 	},;
				{"QG_PAI"		, DecodeUtf8(jCandit:GetJsonText("PAI"))						,X3Picture("QG_PAI") 		},;
				{"QG_MAE"		, DecodeUtf8(jCandit:GetJsonText("MAE"))						,X3Picture("QG_MAE") 		},;
				{"QG_SEXO"		, UPPER(jCandit:GetJsonText("SEXO"))							,X3Picture("QG_SEXO") 		},;
				{"QG_ESTCIV"	, UPPER(jCandit:GetJsonText("ESTCIV"))							,X3Picture("QG_ESTCIV") 	},;
				{"QG_NATURAL"	, DecodeUtf8(jCandit:GetJsonText("NATURAL"))					,X3Picture("QG_NATURAL") 	},;
				{"QG_NACIONA"	, jCandit:GetJsonText("NACIONA")								,X3Picture("QG_NACIONA") 	},;
				{"QG_ANOCHEG"	, Substr(StrTran(jCandit:GetJsonText("ANOCHEG"),"-",""),3,2)	,X3Picture("QG_ANOCHEG") 	},;
				{"QG_DTNASC"	, CTOD(jCandit:GetJsonText("DTNASC"))							,X3Picture("QG_DTNASC") 	},; //Stod(Left(StrTran(jCandit:GetJsonText("DTNASC"),"-",""),8))
				{"QG_DTCAD"		, Date()														,X3Picture("QG_DTCAD") 		},; //Stod(Left(StrTran(jCandit:GetJsonText("DTCAD"),"-",""),8))
				{"QG_ULTSAL"	, Val(StrTran(jCandit:GetJsonText("ULTSAL"),",","."))			,X3Picture("QG_ULTSAL") 	},;
				{"QG_PRETSAL"	, Val(StrTran(jCandit:GetJsonText("PRETSAL"),",","."))			,X3Picture("QG_PRETSAL") 	},;												
				{"QG_ANALISE"	, DecodeUtf8(jCandit:GetJsonText("ANALISE"))					,X3Picture("QG_ANALISE") 	},;
				{"QG_PIS"		, jCandit:GetJsonText("PIS")									,X3Picture("QG_PIS") 		},;
				{"QG_INDICAD"	, DecodeUtf8(jCandit:GetJsonText("INDICAD"))					,X3Picture("QG_INDICAD") 	},;
				{"QG_NOTA"		, Val(StrTran(jCandit:GetJsonText("NOTA"),",","."))				,X3Picture("QG_NOTA") 		},;
				{"QG_SITUAC"	, "001"															,X3Picture("QG_SITUAC") 	},; 	
				{"QG_TPTRAB"	, Val(StrTran(jCandit:GetJsonText("TPTRAB"),",","."))			,X3Picture("QG_TPTRAB") 	},;
				{"QG_TPEXPER"	, Val(StrTran(jCandit:GetJsonText("TPEXPER"),",","."))			,X3Picture("QG_TPEXPER") 	},;
				{"QG_ULTETAP"	, jCandit:GetJsonText("ULTETAP")								,X3Picture("QG_ULTETAP") 	},;
				{"QG_ULTDATA"	, CtoD(jCandit:GetJsonText("ULTDATA"))							,X3Picture("QG_ULTDATA") 	},; //Stod(Left(StrTran(jCandit:GetJsonText("ULTDATA"),"-",""),8))
				{"QG_DFISICO"	, jCandit:GetJsonText("DFISICO")								,X3Picture("QG_DFISICO") 	},;
				{"QG_XOBS"		, jCandit:GetJsonText("XOBS")									,X3Picture("QG_XOBS") 		},;
				{"QG_XDTUATU"	, CtoD(jCandit:GetJsonText("XDTUATU"))							,X3Picture("QG_XDTUATU") 	},; //Stod(Left(StrTran(jCandit:GetJsonText("XDTUATU"),"-",""),8))
				{"QG_XDEFIC"	, DecodeUtf8(jCandit:GetJsonText("XDEFIC"))						,X3Picture("QG_XDEFIC") 	},;
				{"QG_CODMUNN"	, jCandit:GetJsonText("CODMUNN")								,X3Picture("QG_CODMUNN")	}}
				
Return .T.

/*/{Protheus.doc} IncFAP
Função para inclusão da FAP
@type function
@version 1.0 
@author Laura Peghini
@since 14/05/2025
@param oJson, object, objeto json
@param cCdCur, caracter, codigo curriculo
@return variant, logico
/*/
Static Function IncFAP(oJson,cCdCur)

Local aCmpJson 	:= oJson:GetNames()
Local nOpc 		:= 3
Local aDados 	:= {}
Local aError	:= {}
Local nFilial	:= 0
Local nVaga		:= 0
Local cStaVg	:= 0
Local cVgFil	:= ""
Local cVaga		:= ""
Local lVaga		:= .T.
Local lRet		:= .T.
Local cVlrVag	:= 0

Private oModel 		:= FWLoadModel('F0500300')
Private lMsErroAuto := .F.
Private aHeader := {}
Private aCols   := {}
Private cP2Filia   
Private cP2Vaga   
Private cP2FilVg
Private cP2Vlr
Private cP2Slfech
Private cP2CdCand
Private cP2Nome
Private cP2CPF
Private cP2Sol
Private cP2TpAlts
Private cGetError := ""
Private cRequisit := ""

Default aDados 		:= {}
Default nOpc   		:= 3

	nFilial := aScan(aCmpJson, {|x| AllTrim(x) == "FILIAL" })
	cVgFil := oJson[aCmpJson[nFilial]]
	nVaga  	:= aScan(aCmpJson, {|x| AllTrim(x) == "VAGA" })
	cVaga 	:= oJson[aCmpJson[nVaga]]
	nVlVaga := aScan(aCmpJson, {|x| AllTrim(x) == "VLRVAGA" })
	cVlVaga := oJson[aCmpJson[nVlVaga]]
	nMultVinc := aScan(aCmpJson, {|x| AllTrim(x) == "XMULTI" })
	cMultVinc := oJson[aCmpJson[nMultVinc]]

	cRequisit := oJson["REQUISITANTE"]

	DbSelectArea("SQS")
	SQS->(DbSetOrder(1))
	If SQS->(DbSeek(cVgFil+cVaga))
		cStaVg := SQS->QS_XSTATUS
		If cStaVg <> '2'
			lVaga := .F.
			aAdd(aError, "ERRO")
			aAdd(aError, "Vaga já utilizada.")
			aAdd(aError, "")
		EndIf
	Else
		lVaga := .F.
		aAdd(aError, "ERRO")
		aAdd(aError, "Vaga não encontrada.")
		aAdd(aError, "")
	EndIf

	If lVaga 
		If oJson[aCmpJson[nVlVaga]] > 0			
			cVlrVag := oJson[aCmpJson[nVlVaga]]
		Else
			cVlrVag := SQS->QS_VCUSTO
		EndIf
		If Empty(oJson[aCmpJson[nMultVinc]])
			cMultVinc := "1"
		Else
			cMultVinc := oJson[aCmpJson[nMultVinc]]
		EndIf
		aDados   := { 	{ "PA2_FILIAL", oJson[aCmpJson[nFilial]] },;
						{ "PA2_CDVAGA", oJson[aCmpJson[nVaga]] },;	
						{ "PA2_FILVG" , oJson[aCmpJson[nFilial]] },;	
						{ "PA2_SLFECH", cVlrVag },;	
						{ "PA2_CDCAND", cCdCur },;	
						{ "PA2_TPALTS", "001" },;	
						{ "PA2_XMULTI", cMultVinc },;	
						{ "PA2_XORIGE", "2" }}	

		aError := U_DOREXCFAP(aDados, nOpc)
		If aError[1] == "ERRO" 
			lRet := .F.
		EndIf
	Else
		lRet := .F.
	EndIf
		

Return {lRet,aError}

/*/{Protheus.doc} fResp
Retornar a String de resposta para o Cavok
@type function
@version  1.0
@author Laura Peghini
@since 15/05/2025
@param cCod, character, código do cliente
@param cLoja, character, loja do cliente
@param cMsgError, character, Mensagem de erro
@return nil
/*/
Static Function fResp(lRet, cCodFAP, cMsgError)
	Default cCod  := ""
	Default cLoja := ""
	Default cMsgError := ""

	cMsgError := EncodeUTF8(Replace(Replace(cMsgError, CRLF, ''), '"', ''))
	oJson := JsonObject():new()
	oJson["STATUS"] := lRet
	oJson["FAP"] := AllTrim(cCodFAP)
	oJson["MSG"] := AllTrim(cMsgError)
	//cRetJson := '{"FAP":"'+cCodFAP+'","MSGERROR":"'+cMsgError+'"}'
	cRetJson := oJson:toJson()

Return


/*/{Protheus.doc} CheckQualific
 Função busca o qualificador de função a partida dos dados da vaga
@type  Static Function
@author Laura Peghini
@since 16/01/2026
@version 1.0
@param filial e vaga informada
@return qualificar de função encontrado
/*/
Static Function CheckQualific ( cFilVag, cCodVag )

Local cArea 	:= GetArea()
Local cFuncao	:= ""
Local cAgrFil	:= ""
Local cAgrBen	:= ""
Local cAgrFun	:= ""

	DbSelectArea("SQS")
	SQS->(DbSetOrder(1))
	If SQS->(DbSeek(cFilVag+cCodVag))
		cFuncao := SQS->QS_FUNCAO
	EndIf
	SQS->(DbCloseArea())

	DbSelectArea("PAQ")
	PAQ->(DbSetOrder(1))
	If PAQ->(DbSeek(xFilial("PAQ")+cFilVag))
		cAgrFil := PAQ->PAQ_CDAGRU
	EndIf
	PAQ->(DbCloseArea())

	DbSelectArea("PAS")
	PAS->(DbSetOrder(1))
	If PAS->(DbSeek(xFilial("PAS")+cAgrFil))
		cAgrBen := PAS->PAS_GRPBEN
	EndIf
	PAS->(DbCloseArea())

	DbSelectArea("PAR")
	PAR->(DbSetOrder(1))
	If PAR->(DbSeek(xFilial("PAR")+cAgrBen+cAgrFil+cFuncao))
		cAgrFun := PAR->PAR_AGRFUN
	EndIf
	PAR->(DbCloseArea())

	RestArea(cArea)

Return cAgrFun 
