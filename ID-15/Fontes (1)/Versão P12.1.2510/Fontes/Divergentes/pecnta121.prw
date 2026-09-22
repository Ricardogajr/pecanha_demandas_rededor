#INCLUDE 'TOPCONN.CH'
#INCLUDE "Protheus.ch"
#INCLUDE "FWMVCDEF.CH"
#Include 'TOTVS.ch'
/*
{Protheus.doc} CNTA121()
Ponto de entrada novo(Modelo MVC) na Medição do contranto
@Author		Ricardo Junior
@Since		12/09/2023
@Version	1.0
*/
User Function CNTA121()
	#Define Enter Chr(13) + Chr(10)

	Local aParam 	:= PARAMIXB
	Local xRet 		:= .T.
	Local oModel 	:= ''
	Local cIdPonto 	:= ''
	Local cIdModel  := ''
	Local nI		:=	0
	Local aArea		:=  FwGetArea()
	Local cAliasAl  := GetNextAlias()
	Local cAliasCr  := GetNextAlias()
	Local cQuery	:= ""
	Local cFilOri	:=	xFilial('CND')
	Local cAlias01	:=	''
	Local cNumMed	:=	''
	Local cTipoCr 	:= "MD"
	Local cGrpAprov	:= ""
	Local cAprov 	:= ""
	Local cUser		:= ""
	Local lContinua := .F.
	Local lIsGrid   := .F.
	Local oModelCXN := Nil
	Local oModelCNE := Nil
	Local cEmail	:= ""
	Local cTpCto    := ""
	Local cNumCtr	:= ""
	Local cQtdVige := ""
	Local cTipoRev := ""
	Local cRevis   := ""
	Local nSldAtu  := ""
	Local nValor   := ""
	Local cUniVige := ""
	Local cFornece := ""
	Local cLojaFor := ""
	Local cNFornec := ""
	Local cNivel   := ""
	Local nMulta   := ""
	Local nJuros   := ""
	Local cn9Cont  := ""
	Local eZ_Tipo := SuperGetMV("EZ_XTIPO", .F.)
	Local eZ_ConSer := SuperGetMV("EZ_XCONSER", .F.)
	Local cEZ_Tpcont := SuperGetMV("EZ_TPCONT", .F.)//*** Tipo de Contrato que enviam email
	Local cTipo := ""
	Local lJuros := .F.
	Local lMulta := .F.
	Static lEmail  := .F.
	Static nXMulta := ""
	Static nXJuros := ""

	Private lRetorn    := .T.
	Private cNumCr 	:= ""
	Private cFilCR 	:= ""

	If aParam <> NIL
		oModel  	:= aParam[1]
		cIdPonto	:= aParam[2]
		cIdModel	:= aParam[3]
		lIsGrid    	:= ( Len( aParam ) > 3 )
        /*O evento de id <MODELVLDACTIVE> será sempre chamado ao iniciar uma operação com o modelo de dados via método Activate do MPFormModel,
        então para nos certificarmos que a validação só será executada no encerramento tal qual o p.e CN120ENVL, é necessário verificar se a chamada está sendo realizada
        através da função CN121MedEnc, pra isso utilizamos a função FwIsInCallStack
         */
		//If cIdPonto == 'CN121ATS'
		//	U_F1200401() // Rotina a ser executado por ultimo e ela não tem efeito de validação e sim de preparação
		//elseif cIdPonto == 'CN121PED'
		//	xRet := U_F1200718()//Ponto de entrada para tratamento de campos do pedido de compra
		If (cIdPonto == "MODELPOS") .AND. cIdModel == "CNTA121" .AND. oModel:GetOperation() == 3
			oModelCXN   := oModel:GetModel():GetModel("CXNDETAIL")//Obtêm o modelo da CNX, com ele é possível verificar valores da CNX
			oModelCNE   := oModel:GetModel():GetModel("CNEDETAIL")
			nXMulta := oModelCNE:GetValue("CNE_XMULTA")
			nXJuros := oModelCNE:GetValue("CNE_XJUROS")

			DbSelectArea("P35")
			DbSetOrder(1)
			DbGoTop()

			While P35->(!EOF())

				If P35->P35_TIPO == "1"
					nMulta := P35->P35_VALMIN
				ElseIf P35->P35_TIPO == "2"
					nJuros := P35->P35_VALMIN
				EndIf
				P35->(DbSkip())
			EndDo
			If nXMulta >= nMulta
				lMulta := .T.
			EndIf
			If nXJuros >= nJuros
				lJuros := .T.
			EndIf
			DbSelectArea("P34")
			DbSetOrder(2)
			DbGoTop()
			If P34->(DbSeek(xFilial("P34")+oModelCNE:GetValue("CNE_PRODUT")))
				If lMulta
					If P34->P34_MULTA <> "1"
						lContinua := .T.
					EndIf
				EndIf
				If lJuros
					If P34->P34_JUROS <> "1"
						lContinua := .T.
					EndIf
				EndIf
			Else
				If (lJuros .Or. lMulta)
					lContinua := .T.
				EndIf
			EndIf
			If (oModelCNE:GetValue("CNE_XMULTA") >= nMulta .Or. oModelCNE:GetValue("CNE_XJUROS") >= nJuros) .AND. !(IsIncallStack("U_XMATA094") .OR. IsInCallStack('MATA094')) .AND. lContinua
				cMsgMulJur := "Esta MD possui valor de Multa e/ou Juros e passará por alçada de "  + Chr(13) + Chr(10)
				cMsgMulJur += "aprovação de Multa/Juros " + Chr(13) + Chr(10)
				cMsgMulJur += "NUMERO DA MD: " + M->CND_NUMMED + Chr(13) + Chr(10)
				cMsgMulJur += "Deseja confirmar a gravação?"
				If !MsgYesNo(cMsgMulJur)
					Help("",1,"Medição",,"Operação abortada",1)
					Return .F.
				Else
					xRet := .T.
				EndIf
			EndIf
		ElseIf (cIdPonto == "MODELPOS") .AND. cIdModel == "CNTA121" .AND. oModel:GetOperation() == 4
			DBSELECTAREA("CNE")
			DBSETORDER(4)
			If CNE->(DBSEEK(XFILIAL("CNE")+CND->CND_NUMMED))
				oModelCXN   := oModel:GetModel():GetModel("CXNDETAIL")//Obtêm o modelo da CNX, com ele é possível verificar valores da CNX
				oModelCNE   := oModel:GetModel():GetModel("CNEDETAIL")
				nXMulta := oModelCNE:GetValue("CNE_XMULTA")
				nXJuros := oModelCNE:GetValue("CNE_XJUROS")
				cNumCr := CND->CND_NUMMED
				cFilCR := CND->CND_FILIAL
				DbSelectArea("P35")
				DbSetOrder(1)
				DbGoTop()
				While P35->(!EOF())
					If P35->P35_TIPO == "1"
						nMulta := P35->P35_VALMIN
					ElseIf P35->P35_TIPO == "2"
						nJuros := P35->P35_VALMIN
					EndIf
					P35->(DbSkip())
				EndDo
				If nXMulta >= nMulta
					lMulta := .T.
				EndIf
				If nXJuros >= nJuros
					lJuros := .T.
				EndIf
				DbSelectArea("P34")
				DbSetOrder(2)
				DbGoTop()
				If P34->(DbSeek(xFilial("P34")+oModelCNE:GetValue("CNE_PRODUT")))
					If lMulta
						If P34->P34_MULTA <> "1"
							lContinua := .T.
						EndIf
					EndIf
					If lJuros
						If P34->P34_JUROS <> "1"
							lContinua := .T.
						EndIf
					EndIf
				Else
					If (lJuros .Or. lMulta)
						lContinua := .T.
					EndIf
				EndIf
				//Obtêm o modelo da CNE, com ele é possível verificar valores da CNE
				If (oModelCNE:GetValue("CNE_XMULTA") >= nMulta .Or. oModelCNE:GetValue("CNE_XJUROS") >= nJuros) .AND. !(IsIncallStack("U_XMATA094") .OR. IsInCallStack('MATA094')) .AND. lContinua
					cMsgMulJur := "Esta MD possui valor de Multa e/ou Juros e passará por alçada de "  + Chr(13) + Chr(10)
					cMsgMulJur += "aprovação de Multa/Juros " + Chr(13) + Chr(10)
					cMsgMulJur += "NUMERO DA MD: " + CND->CND_NUMMED + Chr(13) + Chr(10)
					cMsgMulJur += "Deseja confirmar a gravação?"
					If !MsgYesNo(cMsgMulJur)
						Help("",1,"Medição",,"Operação abortada",1)
						Return .F.
					Else
						xRet := .T.
					EndIf
				EndIf
			EndIf
		ElseIf (cIdPonto == "MODELPRE") .AND. cIdModel == "CNTA121"
			If !Empty(M->CND_CONTRA) .AND. !Empty(M->CND_FILCTR)
				cTipo := Posicione("CN9",1,M->CND_FILCTR+M->CND_CONTRA+M->CND_REVISA,"CN9_TPCTO")
				If cTipo $ eZ_Tipo
					oModel:GetModel("CNEDETAIL"):GetStruct():SetProperty("CNE_VLUNIT", MODEL_FIELD_WHEN, FwBuildFeature(STRUCT_FEATURE_WHEN , ".T."))
					oModel:GetModel("CNEDETAIL"):GetStruct():SetProperty("CNE_CC", MODEL_FIELD_WHEN, FwBuildFeature(STRUCT_FEATURE_WHEN , ".T."))
				EndIf
			EndIf
		ElseIf cIdPonto == 'FORMCOMMITTTSPOS' .And. cIdModel == "CNEDETAIL" .And. oModel:GetOperation() == 5
			//U_F1200715(Paramixb[01]) //Ajusta Flag da Medição de Contrato
			cFilOri		:=	xFilial('CND')
			cNumMed		:=	oModel:getValue("CNE_NUMMED")
			For nI := 01 To oModel:Length()
				oModel:GoLine(nI)

				If !oModel:IsDeleted()//aCols[nI][Len(aHeader) + 01] == .F.

					cAlias01 := GetNextAlias()

					BeginSql Alias cAlias01
                    SELECT	SC1.R_E_C_N_O_ NUMREC
                    FROM	%Table:SC1% SC1
                    WHERE 		SC1.%notDel%
                            AND SC1.C1_FILIAL	= %Exp:cFilOri%
                            AND SC1.C1_XNUMMED	= %Exp:cNumMed%
                            AND	SC1.C1_XITEMED	= %Exp:oModel:getValue("CNE_ITEM")%//%Exp:aCols[nI][nColItmMed]%
					EndSql

					Do While !(cAlias01)->(Eof())
						SC1->(DbGoTo((cAlias01)->NUMREC))
						Reclock('SC1',.F.)
						SC1->C1_FLAGGCT	:=	''
						SC1->C1_XNUMMED	:=	''
						SC1->C1_XITEMED	:=	''
						SC1->C1_XITMED	:=	'MEDICAO EXCLUIDA'
						SC1->C1_XOBSMED	:=	'MEDICAO EXCLUIDA'
						SC1->C1_PEDIDO  :=	''
						SC1->C1_ITEMPED :=	''
						SC1->(MsUnLock())
						(cAlias01)->(DbSkip())
					EndDo

					(cAlias01)->(DbCloseArea())
				EndIf
			Next nI
		EndIf
		If (cIdModel == 'CXNDETAIL')
			If cIdPonto == "FORMLINEPOS"//Será ativado 1x por linha
				oModelCXN   := oModel:GetModel():GetModel("CXNDETAIL")//Obtêm o modelo da CNX, com ele é possível verificar valores da CNX
				oModelCNE   := oModel:GetModel():GetModel("CNEDETAIL")//Obtêm o modelo da CNE, com ele é possível verificar valores da CNE
				nXMulta := oModelCNE:GetValue("CNE_XMULTA")
				nXJuros := oModelCNE:GetValue("CNE_XJUROS")
				nXNumpl := oModelCXN:GetValue("CXN_NUMPLA")
				oModelCND   := oModelCXN:GetModel():GetModel("CNDMASTER")//Obtêm o modelo da CND, com ele é possível verificar valores da CND
				If !Empty(oModelCXN:GetValue("CXN_FORCLI") )
					oModelCND:LoadValue("CND_FORNEC", oModelCXN:GetValue("CXN_FORCLI"))
					oModelCND:LoadValue("CND_LJFORN", oModelCXN:GetValue("CXN_LOJA"))
					oModelCND:LoadValue("CND_NUMERO", oModelCXN:GetValue("CXN_NUMPLA"))
				Endif
			Endif
		EndIf
		If (cIdPonto == "MODELPOS")//CN130TOK
			oModel := aParam[1]//instância de MPFormModel
			if oModel:GetOperation() == 3 .OR. oModel:GetOperation() == 4 .AND. !(IsIncallStack("U_XMATA094") .OR. IsInCallStack('MATA094'))
				cTpCto := Posicione("CN9",1,M->CND_FILCTR+M->CND_CONTRA+M->CND_REVISA,"CN9_TPCTO")
				If Empty(oModel:GetValue("CNDMASTER", "CND_XTPREQ")) .AND. cTpCto $ eZ_ConSer
					Alert("Informe o Tipo da Requisição para Medição de Serviço.")
					xRet := .F.
				EndIf
			endif
		EndIf
		If (cIdPonto == "FORMPRE") .AND. (cIdModel == "CNDMASTER") .AND. (aParam[5] == "CND_XTPREQ") .AND. !(IsIncallStack("U_XMATA094") .OR. IsInCallStack('MATA094'))
			oModelCXN   := oModel:GetModel():GetModel("CXNDETAIL")//Obtêm o modelo da CNX, com ele é possível verificar valores da CNX
			oModelCNE   := oModel:GetModel():GetModel("CNEDETAIL")
			oModelCND   := oModelCXN:GetModel():GetModel("CNDMASTER")
			If Posicione("CN9",1,M->CND_FILCTR+M->CND_CONTRA+M->CND_REVISA,"CN9_TPCTO") $ eZ_ConSer .AND. aParam[6] <> Nil .AND. !Empty(aParam[6])
				cGpAprov1 := oModelCND:GetValue("CND_APROV")
				oModelCND:LoadValue("CND_APROV", " ")
				oModelCND:LoadValue("CND_APROV", Posicione("SY1",1,xFilial("SY1")+AllTrim(Posicione("P02",1,xFilial("P02")+aParam[6],"P02_COMPRA")),"Y1_GRAPROV"))
			Else
				cGpAprov1 := oModelCND:GetValue("CND_APROV")
				If Empty(cGpAprov1)
					oModelCND:LoadValue("CND_APROV", CN9->CN9_GRPAPR)
				EndIf 
			EndIf
		EndIf
		If (cIdPonto == "MODELCOMMITNTTS")
			cNumCr := CND->CND_NUMMED
			cFilCR := CND->CND_FILIAL

			lContinua := fValidProc()

			If lContinua

				cQuery := " SELECT * FROM " + RetSqlName("SCR")
				cQuery += " WHERE D_E_L_E_T_ = ' ' "
				cQuery += " AND CR_NUM = '"+cNumCr+"'"
				cQuery += " AND CR_FILIAL = '"+cFilCR+"'"
				cQuery += " AND CR_TIPO = '"+cTipoCr+"'"
				cQuery += " AND CR_STATUS = '02'"


				If Select( cAliasCr ) > 0
					( cAliasCr )->( DbCloseArea() )
				EndIf

				TcQuery cQuery Alias ( cAliasCr ) New
				If !( cAliasCr )->( Eof() )

					cGrpAprov := (cAliasCr)->CR_GRUPO

					cQuery := " SELECT * FROM " + RetSqlName("SAL") + " WHERE D_E_L_E_T_ = ' ' "
					cQuery += " AND AL_APROV NOT IN "
					cQuery += " (SELECT CR_APROV FROM SCR010 WHERE D_E_L_E_T_ = ' ' AND CR_NUM = '" +cNumCr + "' AND CR_FILIAL = '" +cFilCR+ "' AND CR_TIPO = '"+cTipoCr+"')"
					cQuery += " AND AL_COD = '" + cGrpAprov +"'"

					If Select( cAliasAl ) > 0
						( cAliasAl )->( DbCloseArea() )
					EndIf

					TcQuery cQuery Alias ( cAliasAl ) New
					While !( cAliasAl )->( Eof() )
						cAprov := ( cAliasAl )->AL_APROV
						lCria := fValAprov(cAprov)
						cFornece := Posicione("CNA",1,xFilial("CNA")+AllTrim(CND->CND_CONTRA)+CND->CND_REVISA,"CNA_FORNEC")
						cLojaFor := Posicione("CNA",1,xFilial("CNA")+AllTrim(CND->CND_CONTRA)+CND->CND_REVISA,"CNA_LJFORN")
						cNFornec := AllTrim(Posicione("SA2",1,xFilial("SA2")+AllTrim(cFornece)+AllTrim(cLojaFor),"A2_NOME"))
						If lCria
							Reclock("SCR",.T.)
							SCR->CR_FILIAL	:= ( cAliasCr )->CR_FILIAL
							SCR->CR_NUM		:= ( cAliasCr )->CR_NUM
							SCR->CR_TIPO	:= ( cAliasCr )->CR_TIPO
							SCR->CR_NIVEL	:= ( cAliasAl )->AL_NIVEL
							SCR->CR_USER	:= ( cAliasAl )->AL_USER
							SCR->CR_APROV	:= ( cAliasAl )->AL_APROV
							SCR->CR_STATUS	:= IIF(( cAliasAl )->AL_NIVEL == ( cAliasCr )->CR_NIVEL  ,"02","01")
							SCR->CR_TOTAL	:= ( cAliasCr )->CR_TOTAL
							SCR->CR_EMISSAO	:= STOD(( cAliasCr )->CR_EMISSAO)
							SCR->CR_MOEDA	:= ( cAliasCr )->CR_MOEDA
							SCR->CR_TXMOEDA	:= ( cAliasCr )->CR_TXMOEDA
							SCR->CR_PRAZO	:= STOD(( cAliasCr )->CR_PRAZO)
							SCR->CR_AVISO	:= STOD(( cAliasCr )->CR_AVISO)
							SCR->CR_ESCALON	:= IIF(( cAliasCr )->CR_ESCALON == "F"  ,.F.,.T.)
							SCR->CR_ESCALSP	:= IIF(( cAliasCr )->CR_ESCALSP == "F"  ,.F.,.T.)
							SCR->CR_GRUPO 	:= ( cAliasCr )->CR_GRUPO
							SCR->CR_ITGRP 	:= ( cAliasCr )->CR_ITGRP
							SCR->CR_XNOME	:= FullName(( cAliasAl )->AL_USER)
							SCR->CR_XFORNEC := CNA->CNA_FORNEC
							SCR->CR_XNOMFOR := cNFornec
							SCR->CR_XCOMSOL := UsrFullName()
							SCR->CR_XDOC	:= "" //SC7->C7_XDOC
							SCR->CR_XLOJA	:= CNA->CNA_LJFORN
							SCR->CR_XAPRO	:= ( cAliasCr )->CR_XAPRO

							SCR->(MsUnlock())
						EndIf
						( cAliasAl )->( DbSkip() )
					EndDo

					( cAliasAl )->( DbCloseArea() )
				EndIf

				( cAliasCr )->( DbCloseArea() )
			EndIf
			RestArea(aArea)

			cCodFil  := AllTrim(CND->CND_FILIAL)
			cNomeFil := AllTrim(FWFilialName())
			cNumCtr := CND->CND_CONTRA
			cTpCto := Posicione("CN9",1,M->CND_FILCTR+cNumCtr,"CN9_TPCTO")
			cRevis   := CND->CND_REVISA
			nSldAtu  := StrTran(AllTrim(Transform(Posicione("CN9",1,M->CND_FILCTR+cNumCtr+cRevis,"CN9_SALDO"),"9999999999999.99")),".",",")
			nValor   := StrTran(AllTrim(Transform(CND->CND_VLTOT,"9999999999999.99")),".",",")
			cUniVige := Posicione("CN9",1,M->CND_FILCTR+cNumCtr+cRevis,"CN9_UNVIGE")
			cNumCr   := CND->CND_NUMMED
			cNumPla  := Posicione("CXN",1,xFilial("CXN")+cNumCtr+cRevis+cNumCr,"CXN_NUMPLA")
			nMulta := Posicione("CNE",1,xFilial("CNE")+cNumCtr+cRevis+cNumPla+cNumCr,"CNE_XMULTA")
			nJuros := Posicione("CNE",1,xFilial("CNE")+cNumCtr+cRevis+cNumPla+cNumCr,"CNE_XJUROS")
			If nMulta <> 0
				nMulta   := StrTran(AllTrim(Transform(nMulta,"9999999999999.99")),".",",")
			Else
				nMulta   := "0,00"
			EndIf
			If nJuros <> 0
				nJuros   := StrTran(AllTrim(Transform(nJuros,"9999999999999.99")),".",",")
			Else
				nJuros   := "0,00"
			EndIf

			If cUniVige == "1"
				cUniVige := "Dias"
			ElseIf cUniVige == "2"
				cUniVige := "Meses" 
			ElseIf cUniVige == "3"
				cUniVige := "Anos"
			EndIf

			cQtdVige := Posicione("CN9",1,M->CND_FILCTR+cNumCtr,"CN9_VIGE")
			cTipoRev := Posicione("CN9",1,M->CND_FILCTR+cNumCtr,"CN9_REVATU")
			cFornece := Posicione("CNA",1,xFilial("CNA")+AllTrim(CND->CND_CONTRA)+CND->CND_REVISA,"CNA_FORNEC")
			cLojaFor := Posicione("CNA",1,xFilial("CNA")+AllTrim(CND->CND_CONTRA)+CND->CND_REVISA,"CNA_LJFORN")
			cNFornec := AllTrim(Posicione("SA2",1,xFilial("SA2")+AllTrim(cFornece)+AllTrim(cLojaFor),"A2_NOME"))
			cNumMed := Posicione("SCR",1,xFilial("SCR")+"MD"+CND->CND_NUMMED,"CR_NUM")
			cNivel := Posicione("SCR",1,xFilial("SCR")+"MD"+SCR->CR_NUM+"01","CR_NIVEL")
			If cTpCto $ eZ_ConSer  
				CND->CND_XUSER := RetCodUsr()
				cn9Cont := Posicione("CN9",1,M->CND_FILCTR+cNumCtr,"CN9_XCTSER")
				If cn9Cont == '' .OR. cn9Cont == '2'				
					CND->CND_XCTSER := '2'
				Else 
					CND->CND_XCTSER := '1'
				EndIf	
			Else
				CND->CND_XCTSER := '2'
				CND->CND_XUSER := RetCodUsr()
			EndIf
		

			While SCR->(CR_FILIAL+CR_NUM) == xFilial("SCR")+cNumMed
				If SCR->CR_NIVEL == "01" .AND. SCR->CR_STATUS == "02"
					cUser := SCR->CR_USER
					cEmail += AllTrim(UsrRetMail(cUser))+";"
					lEmail := .F.
					If 	Empty(SCR->CR_XFORNECE)
						Reclock("SCR",.F.)
						SCR->CR_XFORNECE := cFornece
						SCR->CR_XNOMFOR  := cNFornec
						SCR->CR_XLOJA	 := cLojaFor
						MsUnLock()
					EndIf
					If 	Empty(SCR->CR_XCC)
						Reclock("SCR",.F.)
						SCR->CR_XCC := Posicione("CNE",1,xFilial("CNE")+cNumCtr+cRevis,"CNE_CC")
						MsUnLock()
					EndIf
					SCR->(dbSkip())
				Else
					If Empty(SCR->CR_XFORNECE)
						Reclock("SCR",.F.)
						SCR->CR_XFORNECE := cFornece
						SCR->CR_XNOMFOR  := cNFornec
						SCR->CR_XLOJA	 := cLojaFor
						MsUnLock()
					EndIf
					If 	Empty(SCR->CR_XCC)
						Reclock("SCR",.F.)
						SCR->CR_XCC := Posicione("CNE",1,xFilial("CNE")+cNumCtr+cRevis,"CNE_CC")
						MsUnLock()
					EndIf
					SCR->(dbSkip())
				EndIf
			EndDo
			If cEmail <> "" .AND. lEmail == .F. .AND. cTpCto $ cEZ_Tpcont
				fWkApMHTML(cEmail,cNumCtr,cNumMed,cRevis,cNFornec,nValor,nSldAtu,cUniVige,cQtdVige,cNivel,nMulta,nJuros,cNomeFil,cCodFil)
				lEmail := .T.
			EndIf
		EndIf
	EndIf
	FwRestArea(aArea)
Return xRet

Static Function fValAprov(cAprov)

	Local aArea := GetArea()
	Local lRet := .F.

	Default cAprov := ""

	DbSelectArea("SAK")
	DbSetOrder(1)
	If SAK->(DbSeek(Xfilial("SAK")+cAprov))
		If AllTrim(SAK->AK_XMULJUR) <> "1"
			lRet := .T.
		EndIf
	EndIf

	RestArea(aArea)
Return lRet

Static Function fValidProc()

	Local lContinua := .F.
	Local lMulta := .F.
	Local lJuros := .F.
	Local nMulta	:= 9999999
	Local nJuros	:= 9999999

	Default cFilCR := CND->CND_FILIAL

	DbSelectArea("P35")
	DbSetOrder(1)
	DbGoTop()

	While P35->(!EOF())

		If P35->P35_TIPO == "1"
			nMulta := P35->P35_VALMIN
		ElseIf P35->P35_TIPO == "2"
			nJuros := P35->P35_VALMIN
		EndIf
		P35->(DbSkip())
	EndDo
	DbSelectArea("CNE")
	DbSetOrder(4)
	DbGoTop()
//CNE -> CNE posiciona pela CNE_NUMMED
	If CNE->(dbSeek(cFilCR+cNumCr))
		While CNE->(!EOF()) .And. AllTrim(CNE->CNE_FILIAL) == AllTrim(cFilCR) .And. AllTrim(CNE->CNE_NUMMED) == AllTrim(cNumCr)
			lMulta := .F.
			lJuros := .F.
			If Valtype(nXMulta) == "N"
				If Empty(cValToChar(nXMulta))
					nXMulta := CNE->CNE_XMULTA
				EndIf
			ElseIf Valtype(nXMulta) == "C"
				nXMulta := CNE->CNE_XMULTA
			EndIf
			If Valtype(nXJuros) == "N"
				If Empty(cValToChar(nXJuros))
					nXJuros := CNE->CNE_XJUROS
				EndIf
			ElseIf Valtype(nXJuros) == "C"
				nXJuros := CNE->CNE_XJUROS
			EndIf
			If nXMulta >= nMulta
				lMulta := .T.
			EndIf
			If nXJuros >= nJuros
				lJuros := .T.
			EndIf
			DbSelectArea("P34")
			DbSetOrder(2)
			DbGoTop()
			If P34->(DbSeek(xFilial("P34")+CNE->CNE_PRODUTO))
				If lMulta
					If P34->P34_MULTA <> "1"
						lContinua := .T.
					EndIf
				EndIf
				If lJuros
					If P34->P34_JUROS <> "1"
						lContinua := .T.
					EndIf
				EndIf
			Else
				If (lJuros .Or. lMulta)
					lContinua := .T.
				EndIf
			EndIf
			If lContinua
				Exit
			EndIf
			CNE->(DbSkip())
		EndDo
	EndIf

Return lContinua

Static Function FullName(cParam)
Return UsrFullName(cParam)

Static Function fWkApMHTML(cEmail,cNumCtr,cNumMed,cRevis,cNFornec,nValor,nSldAtu,cUniVige,cQtdVige,cNivel,nMulta,nJuros,cNomeFil,cCodFil)

	Local cRet        := ""
	Local aArea       := {}
	Local aRetMail    := {}

	Default cCodFil  := ""
	Default cNomeFil := ""
	Default cNivel   := ""
	Default nMulta   := ""
	Default nJuros   := ""
	Default cNFornec := ""
	Default cTipoRev := ""
	Default cDescRev := ""
	Default nValor   := ""
	Default nSldAtu  := ""
	Default cUniVige := ""
	Default cQtdVige := ""
	Default cMailCC  := ""
	Default cEmail   := ""
	Default cNumCtr  := ""
	Default cNumMed  := ""
	Default cRevis   := ""
	Default cNota    := ""
	Default cObra    := ""
	Default xTitulo  := "Notificação de Aprovação de Medição do Contrato "
	Default xTitul2  := "Fornecedor "

	//--- Monta formulario html
	cRet := '<style>'
	cRet += 'blockquote {'
	cRet += '    position: relative;'
	cRet += '    padding-left: 1em;'
	cRet += '    border-left: 0.2em solid #e50303;'
	cRet += "    font-family: 'Roboto', serif;"
	cRet += '    font-size: 0.8em;'
	cRet += '    line-height: 1.5em;'
	cRet += '    font-weight: 100;'
	cRet += '}'
	cRet += '</style>'
	cRet += '<table border="0" cellpadding="1" cellspacing="1" style="width:1128px">'
	cRet += '	<tbody>'
	cRet += '		<tr>'
	cRet += '			<td style="text-align:cEnter; width:927px"><span style="font-size:20px"><span style="font-family:Lucida Sans Unicode,Lucida Grande,sans-serIf"><strong>Aprovação da Medição de Contrato</strong></span></span></td>'    + Enter
	cRet += '		</tr>'
	cRet += '		<tr>'
	cRet += '			<td colspan="2" style="width:188px">&nbsp;</td>'
	cRet += '		</tr>'
	cRet += '		<tr>'
	cRet += '			<td colspan="2" style="width:188px">'
	cRet += '			<hr/>'
	cRet += '           <p> Prezado gestor(a), </p>'
	cRet += '           <p> A medição do contrato '+AllTrim(cNumCtr)+' encontra-se disponível para aprovação na rotina de liberação de documentos. </p>'
	cRet += ''
	cRet += '			<p> Filial: '+cCodFil+' - '+cNomeFil+'</p>'
	cRet += '			<p> Número da Medição: '+cNumMed+'</p>'
	cRet += '			<p> Fornec: '+cNFornec+'</p>'
	cRet += '			<p> Valor Total: R$ '+nValor+'</p>'
	cRet += '			<p> Multa: R$ '+nMulta+'</p>'
	cRet += '			<p> Juros: R$ '+nJuros+'</p>'
	cRet += '			<p> Vigência: '+cValToChar(cQtdVige)+' - '+cUniVige+'</p>'
	cRet += '			<p> Saldo atual do contrato: R$ '+nSldAtu+'</p>'
	cRet += '           <p> Nível: '+cNivel+'</p>'
	cRet += ''
	cRet += '			<p> Favor realizar a aprovação. </p>'
	cRet += ''
	cRet += '		</tr>'
	cRet += '		<tr>'
	cRet += '			<td colspan="2" style="width:188px">&nbsp;</td>'
	cRet += '		</tr>'
	cRet += '	</tbody>'
	cRet += '</table>'
	cRet += ''

	xTitulo := xTitulo+" - "+AllTrim(cNumCtr)+" - Filial "+cNomeFil+" "+xTitul2+" "+cNFornec

	aRetMail := u_xfSendMail(cEmail, cMailCC, xTitulo, cRet)

	RestArea(aArea)
Return
