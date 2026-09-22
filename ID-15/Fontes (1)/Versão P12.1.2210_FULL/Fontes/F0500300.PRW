#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'FILEIO.CH'
static cFilF3
static cCodF3
 
/*{Protheus.doc} F0500300
Formulário de Aprovação Profissional – Requisito N004
@author Kaiam Rodrigues
@since 17/10/2016
@Project MAN0000007423039_EF_003 
*/
User Function F0500300()
	
	Local   oBrowse
	
	Private aRotina := MenuDef()
	
	//Ticket No.4724773 - 418497 - Don Junior - Gravação dados na PA2
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
	
	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias('PA2')
	oBrowse:SetDescription("Formulário de Aprovação Profissional")
	oBrowse:AddLegend("PA2_SIT =='AP'","BR_VERDE","Em admissão")
	oBrowse:AddLegend("PA2_SIT =='AG'","BR_AMARELO","Aguardando Aprovação")
	oBrowse:AddLegend("PA2_SIT =='RE'","BR_VERMELHO","Reprovado")
	oBrowse:AddLegend("PA2_SIT =='CL'","BR_AZUL","Concluído")
	oBrowse:AddLegend("PA2_SIT =='RI'","BR_LARANJA","Aguandando Efetivação do RH")
	oBrowse:Activate()
	
Return Nil

/*{Protheus.doc} MenuDef
Criaçao do Menu
@author Kaiam Rodrigues
@since 17/10/2016
@Project MAN0000007423039_EF_003
*/
Static Function MenuDef()
	
	Local aRotina := {}
	
	ADD OPTION aRotina TITLE "Visualizar"             ACTION "VIEWDEF.F0500300" OPERATION MODEL_OPERATION_VIEW   ACCESS 0 //"Visualizar"
	ADD OPTION aRotina TITLE "Incluir"                ACTION "VIEWDEF.F0500300" OPERATION MODEL_OPERATION_INSERT ACCESS 0 //"Incluir"
	ADD OPTION aRotina Title "Cancelar Solicitação"   Action 'U_F0500325' 		OPERATION 6 ACCESS 0
	
Return aRotina

/*{Protheus.doc} ModelDef
Criacao do Model
@author Kaiam Rodrigues
@since 17/10/2016
@Project MAN0000007423039_EF_003
*/
Static Function ModelDef()
	
	Local oStructPA2 := FWFormStruct(1,"PA2")
	Local oModel 	 := Nil
	
	oStructPA2:SetProperty( "PA2_LOGTOR", MODEL_FIELD_INIT, {|| __cUserId } )
	oStructPA2:SetProperty( "PA2_LOGTOR", MODEL_FIELD_WHEN, {|| .F. } )
	
	// Ticket No.4724773 - 418497 - Don Junior - Gravação dados na PA2
//	oModel:= MPFormModel():New("M0500300",/*Pre-Validacao*/,{|oModel| PreVal(oModel)}/*Pos-Validacao*/,/*Commit*/,/*Cancel*/)
	oModel:= MPFormModel():New("M0500300",/*Pre-Validacao*/,{|oModel| PreVal(oModel)}/*Pos-Validacao*/,{|oModel|F0500Grv(oModel)}/*Commit*/,/*Cancel*/)

	oModel:AddFields("F05003_PA2", Nil/*cOwner*/, oStructPA2 ,/*Pre-Validacao*/,/*Pos-Validacao*/,/*Carga*/)
	oModel:SetPrimaryKey( { "PA2_FILIAL", "PA2_CDVAGA","PA2_CDCAND"})
	oModel:GetModel("F05003_PA2"):SetDescription("TESTE")
	
Return oModel

/*{Protheus.doc} ViewDef
Criacao da View
@author Kaiam Rodrigues
@since 17/10/2016
@Project MAN0000007423039_EF_003
*/
Static Function ViewDef()
	
	Local oView      := Nil
	Local oModel     := FWLoadModel("F0500300")
	Local oStructPA2 := FWFormStruct(2,"PA2")
	
	//oStructPA2:RemoveField("PA2_FILCAN")
	//oStructPA2:RemoveField("PA2_FILSOL")
	
	oView := FWFormView():New()
	oView:SetModel(oModel)
	oView:EnableControlBar(.T.)
	oView:AddField( "F05003_PA2" , oStructPA2 )
	oView:CreateHorizontalBox( "HEADER" , 100 )
	oView:SetOwnerView( "F05003_PA2" , "HEADER" )
	
Return oView

/*{Protheus.doc} EnvAprova
Envio de Aprovação para o Portal
@author  Kaiam Rodrigues
@since   17/10/2016
@Project MAN0000007423039_EF_003
*/
Static Function EnvAprova(cSubGrp)
	
	Local lRet     := .T.
	Local nX       := 0
	Local cMatSoli := ""
	Local cFilSoli := ""
	Local aDdSolic := {}
	Local aDados   := {}
	Local aCampos  := {}
	Local aAreas   := {SRA->(GetArea()),PA2->(GetArea()),GetArea()}
	
	Private cFuncion  := oMdl:getValue('PA2_CPFCAN')
	Private cNomeCand := oMdl:getValue('PA2_NMCAND')
	Private cFilCand  := oMdl:getValue('PA2_FILCAN')
	
	aCampos   := { "PA2_FILIAL",; // Filial da solicitação
	"TMP_FILVAG",; //Filial da vaga
	"TMP_DESCVG",; // Descrição da filial
	"PA2_CDVAGA",; // Codigo da vaga
	"PA2_VLVAGA",; // Valor da vaga
	"TMP_TIPOFA",; // Tipo da fap
	"TMP_FPOSTO",; // Filial do posto
	"TMP_POSTO" ,; // Posto
	"TMP_CARGOV",; // Cargo vaga
	"TMP_DSCCGV",; // Descrição cargo vaga
	"TMP_CCVAGA",; // CC vaga
	"TMP_DSCVAG",; // Descrição cc vaga
	"TMP_DPTVAG",; // Departamento
	"TMP_DSCDVA",; // Descrição do departamento
	"PA2_SLFECH",; // Salario fechamento
	"TMP_TURVAG",; // Turno Vaga
	"TMP_JORNVG",; // Jornada Vaga
	"PA2_CDCAND",; // Codigo do candidato
	"PA2_NMCAND",; // Nome do candidato
	"PA2_CPFCAN",; // CPF do candidato
	"PA2_DTMOV ",; // Data da movimentação
	"PA2_FILCAN",; // Filial do Cnadidato
	"PA2_DESFIL",; // Descrição da filial
	"TMP_MATCOL",; // Matricula colaborador
	"TMP_NOMECO",; // Nome colaborador
	"TMP_FILPOS",; // Filial posto colaborador
	"TMP_CODPOS",; // posto colaborador
	"PA2_CARGO ",; // Codigo do cargo
	"PA2_DESCAR",; // Descrição do cargo
	"PA2_TURNO ",; // Turno
	"PA2_DESCTU",; // Descrição do Turno
	"PA2_DEPART",; // Departamento
	"PA2_DESDEP",; // Descrição do departamento
	"PA2_CC    ",; // Centro de custo
	"PA2_DESCC ",; // Descrição do centro de custo
	"PA2_HRMES ",; // Horas mês
	"PA2_SALHR ",; // Salario hora
	"TMP_SALFUN",; // Salario
	"PA2_DTADMI",; // Data de admissão
	"PA2_TPALTS" } // Tipo de Aumento salarial
	
	Private cEmp := FWCodEmp()
	
	aDados := RetDados()
	
	If (PswSeek(__cUserId,.T.))
		aDdSolic := PswRet()
		
		///cMatSoli := SubString(aDdSolic[1][22], Len(cEmpAnt) + Len(cFilAnt) + 1, 12)
		cMatSoli := SubString(aDdSolic[1][22], (Len(aDdSolic[1,22])-6) + 1 , 12)
		cFilSoli := SubString(aDdSolic[1][22], Len(cEmpAnt) + 1, Len(cFilAnt))
	
		If !Empty(cMatSoli)
			//Chamada da Função que Realiza a Gravação dos campos nas Tabelas RH3 e RH4
			lRet := GrvRH3RH4(cMatSoli, cFilSoli, cSubGrp, "004", "PORTAL", aCampos, aDados)
		Else
			Help( ,, 'HELP',, 'Não há Vínculo entre o Solicitante e o cadastro de Funcionários.', 1, 0)
			lRet := .F.
		EndIf
		
	EndIf
	
	AEval(aAreas, {|aArea| RestArea(aArea)} )
	
Return lRet

/*{Protheus.doc} getFilial
Executa busca para pegar a filial correta do candidato
@author Henrique Madureira
@since 03/05/2017
@Project MAN0000007423039_EF_003
@Return cRet, filial do SRA
*/
Static Function GetFilial()

	Local cRet      := ""
	Local cQuery    := ""
	Local cAliasSra := "RETSRA"
	
	cQuery := "SELECT SRA.RA_FILIAL "
	cQuery += "FROM " + RetSqlName("SRA") + " SRA "
	cQuery += "WHERE 	SRA.RA_CIC = '" + cFuncion + "' "
	cQuery += "		AND SRA.RA_SITFOLH IN( ' ', 'A','F' ) "
	cQuery += "		AND SRA.D_E_L_E_T_ = ' ' "
	
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSra)
	
	cRet := (cAliasSra)->(RA_FILIAL)
	
	(cAliasSra)->(DbCloseArea())

Return cRet

/*{Protheus.doc} RetDados
Executa busca para pegar a filial correta do candidato
@author Henrique Madureira
@since 03/05/2017
@Project MAN0000007423039_EF_003
@Return aDados, Conteudo da solicitação
*/
Static Function RetDados()

	Local aDados	:= {}
	Local cFilSra 	:= ""
	Local lFatInt	:= .F.
	
	cFilSra := GetFilial()
	
	If Empty(cFilF3)
		cFilF3 := M->PA2_FILVG
		cCodF3 := M->PA2_CDVAGA
	EndIf
	
	lFatInt := SitCand()
	SQS->(DbSetOrder(1))
	If lFatInt
		aDados := { XFilial("PA2"),;
			SQS->QS_FILIAL,;
			FWFilialName(,SQS->QS_FILIAL,1),;
			M->PA2_CDVAGA,;
			M->PA2_VLVAGA,;
			"INTERNO",;
			SQS->QS_FILPOST,;
			SQS->QS_POSTO,;
			SQS->QS_FUNCAO,;
			POSICIONE("SRJ",1,XFILIAL("SRJ") + SQS->QS_FUNCAO, "RJ_DESC"),;
			SQS->QS_CC,;
			Posicione("CTT", 1, XFilial("CTT") + SQS->QS_CC, "CTT_DESC01"),;
			Posicione("RCL", 2, SQS->QS_FILPOST + SQS->QS_POSTO, "RCL_DEPTO"),;
			Posicione("SQB", 1, XFilial("SQB") + RCL->RCL_DEPTO, "QB_DESCRIC"),;
			M->PA2_SLFECH,;
			SQS->QS_XTURNO,;
			SQS->QS_XJORN,;
			M->PA2_CDCAND,;
			cNomeCand,;
			cFuncion,;
			M->PA2_DTMOV,;
			cFilSra,;
			FWFilialName(,cFilSra,1),;	//?cFilCand
			SRA->RA_MAT,;
			SRA->RA_NOME,;
			POSICIONE("RCX",2,XFILIAL("RCX") + SRA->(RA_POSTO + RA_FILIAL + RA_MAT),"RCX_FILIAL"),;
			SRA->RA_POSTO,;
			SRA->RA_CARGO,;
			Posicione("SQ3", 1, XFilial("SQ3") + SRA->RA_CARGO + Space(TamSX3("Q3_CC")[1]), "Q3_DESCSUM"),;
			SRA->RA_TNOTRAB,;
			Posicione("SR6", 1, XFilial("SR6") + SRA->RA_TNOTRAB, "R6_DESC"),;
			SRA->RA_DEPTO,;
			Posicione("SQB", 1, XFilial("SQB") + SRA->RA_DEPTO, "QB_DESCRIC"),;
			SRA->RA_CC,;
			Posicione("CTT", 1, XFilial("CTT") + SRA->RA_CC, "CTT_DESC01"),;
			SRA->RA_HRSMES,;
			(SRA->RA_SALARIO / SRA->RA_HRSMES),;
			SRA->RA_SALARIO,;
			(SRA->RA_ADMISSA),;
			M->PA2_TPALTS}
	Else
			aDados := { XFilial("PA2"),;
				SQS->QS_FILIAL,;
				FWFilialName(,SQS->QS_FILIAL,1),;
				M->PA2_CDVAGA,;
				M->PA2_VLVAGA,;
				"EXTERNO",;
				SQS->QS_FILPOST,;
				SQS->QS_POSTO,;
				SQS->QS_FUNCAO,;
				POSICIONE("SRJ",1,XFILIAL("SRJ") + SQS->QS_FUNCAO, "RJ_DESC"),;
				SQS->QS_CC,;
				Posicione("CTT", 1, XFilial("CTT") + SQS->QS_CC, "CTT_DESC01"),;
				Posicione("RCL", 2, SQS->QS_FILPOST + SQS->QS_POSTO, "RCL_DEPTO"),;
				Posicione("SQB", 1, XFilial("SQB") + RCL->RCL_DEPTO, "QB_DESCRIC"),;
				M->PA2_SLFECH,;
				SQS->QS_XTURNO,;
				SQS->QS_XJORN,;
				M->PA2_CDCAND,;
				cNomeCand,;
				cFuncion,;
				M->PA2_DTMOV,;
				"",;//? cFilCand,;
				"",;//? FWFilialName(,cFilCand,1),;
				"",;
				"",;
				"",;
				"",;
				"",;
				"",;
				"",;
				"",;
				"",;
				"",;
				"",;
				"",;
				0,;
				0,;
				0,;
				STOD(" / / "),;
				""}
	EndIf

Return aDados


/*{Protheus.doc} ValSalario
Validação do Salário de Fechamento
@author Kaiam Rodrigues
@since 17/10/2016
@Project MAN0000007423039_EF_003
*/
Static Function ValSalario(oModel)
	
	Local lRet 	 	:= .T.  //Retorno da Função
	Local cTipo 	:= "E"  //Tipo de Movimentação(E=Externa/I=Interna)
	Local lOrca		:= .T.  //Retorna Da Função de Verificação de Orçamento
	Local aRH3		:= {}
	Local aRH4		:= {}
	Local cAssunto	:= ""
	Local cBody		:= ""
	Local cEmail	:= ""
	Local nOpera 	:= oModel:GetOperation()
	Local cTip		:= ""
	Local lEnvio	:= .T.
	
	Private cFilSra     := XFilial("SRA")
	Private bFiltraBrw  := { || NIL }	//Variavel para Filtro
	Private oMdl        := oModel:getModel('F05003_PA2')
	Private oModel      := FwModelActive()
	
	If nOpera != 5 .AND. lRet// TUDO MENOS EXCLUSAO
		
		SQS->(DbSetOrder(1))
		SQ3->(DbSetOrder(1))
		SRJ->(DbSetOrder(1))
		RB6->(DbSetOrder(1))
		
		SQG->(DbSetOrder(1))
		SQG->(DbSeek(XFilial("SQG")+M->PA2_CDCAND))
		
		If SitCand()
			cTip := "I" //Interno
		Else
			cTip := "E" //Externo
		EndIf
		
		cCand := oMdl:GetValue('PA2_CDCAND')
		
		If SQS->(DbSeek(XFilial("SQS")+M->PA2_CDVAGA))
			nSolici := SQS->QS_VCUSTO
			
			cFlSolSqs := SQS->QS_XSOLFIL
			cCdSolSqs := SQS->QS_XSOLPTL
			
			If SRJ->(DbSeek(XFilial("SRJ")+SQS->QS_FUNCAO))
				If SQ3->(DbSeek(XFilial("SQ3")+SRJ->RJ_CARGO))
					
					aAux := BscFxSal(SQ3->Q3_CARGO,XFilial("SQS"),cFlSolSqs,cCdSolSqs)
					
					//If RB6->(DbSeek(XFilial("RB6")+SQ3->Q3_TABELA+SQ3->Q3_TABNIVE))
					If !(Empty(aAux))
						If cTip == "I"
							cSubGrp := "001"
							lRet := EnvAprova(cSubGrp)
							If lRet
								oMdl:SetValue('PA2_FILSOL',RH3->RH3_FILIAL)
								oMdl:SetValue('PA2_SOL',RH3->RH3_CODIGO)
								If RH3->RH3_STATUS == '4'
									oMdl:SetValue('PA2_SIT',"RI")
								EndIf
								DataMov(,RH3->RH3_CODIGO)
							EndIf
						ElseIf cTip == "E" .And. oMdl:getValue('PA2_SLFECH') > aAux[LEN(aAux)][3] //ACIMA DA FAIXA
							cSubGrp := "002"
							//Verifica se Existe Orçamento disponível para o Valor
							lOrca := VerOrcament()
							If lOrca
									
								lRet := EnvAprova(cSubGrp)
								If lRet
									oMdl:setValue('PA2_FILSOL',RH3->RH3_FILIAL)
									oMdl:setValue('PA2_SOL',RH3->RH3_CODIGO)
									If RH3->RH3_STATUS == '4'
										oMdl:SetValue('PA2_SIT',"RI")
									EndIf
									DataMov(,PA2_SOL)
								EndIf
									
							Else
									
								//Mensagem de que não Existe Orçamento Disponível para a Vaga
								Aviso("Atenção","Não existe orçamento disponível para realizar a Contratação.",{"Ok"})
								lRet := .F.
									
							EndIf
						Else
							cSubGrp := "003"
							lRet := EnvAprova(cSubGrp)
							If lRet
								oMdl:SetValue('PA2_FILSOL',RH3->RH3_FILIAL)
								oMdl:SetValue('PA2_SOL',RH3->RH3_CODIGO)
								If RH3->RH3_STATUS == '4'
									oMdl:SetValue('PA2_SIT',"RI")
								EndIf
								DataMov(,RH3->RH3_CODIGO)
							EndIf
						EndIf
					Else
						Help( ,, 'HELP',, 'Tabela Salarial vínculada ao Cargo não encontrada!', 1, 0)
						lRet := .F.
					EndIf
				Else
					Help( ,, 'HELP',, 'Cargo vínculado a Função não encontrado!', 1, 0)
					lRet := .F.
				EndIf
			Else
				Help( ,, 'HELP',, 'Função vínculada a vaga não encontrada!', 1, 0)
				lRet := .F.
			EndIf
		Else
			Help( ,, 'HELP',, 'Vaga não encontrada!', 1, 0)
			lRet := .F.
		EndIf
		
		If lRet
			If cTip == "I"
				SQS->(DbSetOrder(1))
				If SQS->(DbSeek(XFilial("SQS")+M->PA2_CDVAGA))
					If SQS->QS_XSTATUS != "3" 
						RecLock("SQS",.F.)
						SQS->QS_XSTATUS := "3" //Em Movimentação (RI)
						SQS->(MsUnLock())
						
						U_F0500211(SQS->QS_FILIAL,SQS->QS_VAGA,"3")	//Status da Vaga na FAP
						U_F0500201(SQS->QS_XSOLFIL, SQS->QS_XSOLPTL, "012")
					EndIf
				EndIf
			EndIf			 
		EndIf
		
	EndIf
	
Return lRet

/*{Protheus.doc} F0500302
Encerra a FAP
@author Kaiam Rodrigues
@since 17/10/2016
@Param		 cFil
@Param		 cSol
@Param		 cTipo
@Param		 cFilPa2
@Project MAN0000007423039_EF_003
*/
User Function F0500302(cFilPa2, cFil, cSol, cTipo)
	
	Local lRet    := .T.
	Local cHrMes  := ""
	Local cVlMes  := ""
	Local nValFun := 0
	Local aAreas := {PA2->(GetArea()),SQS->(GetArea()),GetArea()}
	
	PA2->(DbSetOrder(7))
	If PA2->(DbSeek(cFilPa2 + cFil + cSol))
		SQG->(DbSetOrder(1))
		
		If SQG->(DbSeek(XFilial("SQG")+PA2->PA2_CDCAND))
			
			If cTipo == "AP"
								
				If !SitCand(SQG->QG_CIC) //CANDIDATO SEM MATRICULA - EXTERNO
					
					SQS->(DbSetOrder(1))
					If SQS->(DbSeek(PA2->PA2_FILVG+PA2->PA2_CDVAGA))
						RecLock("SQS",.F.)
						SQS->QS_XSTATUS := "8" // 8=Exame-Docto; Jamer Nunes pedroso 19/05/2017 
						SQS->(MsUnLock())
						
						U_F0500211(SQS->QS_FILIAL,SQS->QS_VAGA,"8")	//Status da Vaga na FAP
						U_F0500201(SQS->QS_XSOLFIL, SQS->QS_XSOLPTL, "021")
						U_F0500201(SQS->QS_XSOLFIL, SQS->QS_XSOLPTL, "019")
				
					EndIF
					Reclock("PA2",.F.)
					PA2->PA2_SIT := "AP" //APROVADO
					PA2->(MsUnLock())
				Else
					SQS->(DbSetOrder(1))
					If SQS->(DbSeek(PA2->PA2_FILVG+PA2->PA2_CDVAGA))
						
						// Chamado No.5140150 - 418497 - Don Junior - Alteração campo QS_VCUSTO para salario fechamento (PA2_SLFECH)
						nSolici := PA2->PA2_SLFECH // SQS->QS_VCUSTO

						cFlSolSqs := SQS->QS_XSOLFIL
						cCdSolSqs := SQS->QS_XSOLPTL
					
						RH4->(DbSetOrder(1))
			
						If RH4->(DbSeek(cFlSolSqs + cCdSolSqs + "19"))
							cHrMes := ALLTRIM(RH4->RH4_VALNOV)
						EndIf
					
						If RH4->(DbSeek(cFlSolSqs + cCdSolSqs + "14"))
							cVlMes := ALLTRIM(RH4->RH4_VALNOV)
						EndIf
						If !(EMPTY(cHrMes))
							nValVg := nSolici / VAL(cHrMes)
						Else
							nValVg := nSolici / 220
						EndIf
						
						SRA->(DbSetOrder(1))
						If SRA->(DbSeek(SQG->QG_FILMAT + SQG->QG_MAT))
							nSlMesFun := SRA->RA_SALARIO
							nHrMesFun := SRA->RA_HRSMES
							
							nValFun := nSlMesFun/ nHrMesFun
						EndIf
						
						If nValFun != 0 .AND. nValVg != 0
							If nValFun <= nValVg
								lRet := .T.
							Else
								lRet := .F.
							EndIf
						EndIf
						
						If lRet
							RecLock("SQS",.F.)
							SQS->QS_XSTATUS := "7" //Concluida 
							SQS->(MsUnLock())
							
							U_F0500211(SQS->QS_FILIAL,SQS->QS_VAGA,"7")	//Status da Vaga na FAP
							
							U_F0500201(SQS->QS_XSOLFIL, SQS->QS_XSOLPTL, "014")
							U_F0500201(PA2->PA2_FILSOL, PA2->PA2_SOL, "014")
							Reclock("PA2",.F.)
							PA2->PA2_SIT := "CL" //APROVADO
							PA2->(MsUnLock())
						Else
							Reclock("PA2",.F.)
							PA2->PA2_SIT := "RE" //AGUARDANDO MOVIMENTAÇÃO RH
							PA2->(MsUnLock())
						EndIf
					EndIF
					
					If !lRet
						Reclock("PA2",.F.)
						PA2->PA2_SIT := "RE" //AGUARDANDO MOVIMENTAÇÃO RH
						PA2->(MsUnLock())
						MsgAlert("FAP Reprovada, Valor do sálario hora atual maior que o da vaga!")
					EndIf
					
				EndIf
			ElseIf cTipo == "RI"
				Reclock("PA2",.F.)
				PA2->PA2_SIT := "RI" //Aguandando Efetivação do RH
				PA2->(MsUnLock())
				
				SQS->(DbSetOrder(1))
				If SQS->(DbSeek(PA2->PA2_FILVG+PA2->PA2_CDVAGA))
					If SitCand(SQG->QG_CIC) .And. SQS->QS_XSTATUS != "3"
						RecLock("SQS",.F.)
							SQS->QS_XSTATUS := "3" 
						SQS->(MsUnLock())
						U_F0500211(SQS->QS_FILIAL,SQS->QS_VAGA,"3")	//Status da Vaga na FAP
						U_F0500201(SQS->QS_XSOLFIL, SQS->QS_XSOLPTL, "012")
					EndIf
				EndIF
			Else
				Reclock("PA2",.F.)
				PA2->PA2_SIT := "RE" //REPROVADO
				PA2->(MsUnLock())
				
				SQS->(DbSetOrder(1))
				If SQS->(DbSeek(PA2->PA2_FILVG+PA2->PA2_CDVAGA))
					U_F0500211(SQS->QS_FILIAL,SQS->QS_VAGA,"2")	//Status da Vaga na FAP					
					If SQS->QS_XSTATUS != "2"
						RecLock("SQS",.F.)
						SQS->QS_XSTATUS := "2" //Em Recrutamento 
						SQS->(MsUnLock())
						
						U_F0500201(SQS->QS_XSOLFIL, SQS->QS_XSOLPTL, "011")
					EndIf
				EndIF
				 
			EndIf
		Else
			Reclock("PA2",.F.)
			PA2->PA2_SIT := "RE" //REPROVADO
			PA2->(MsUnLock())
			
			SQS->(DbSetOrder(1))
			If SQS->(DbSeek(PA2->PA2_FILVG+PA2->PA2_CDVAGA))
				RecLock("SQS",.F.)
				SQS->QS_XSTATUS := "2" //Em Recrutamento 
				SQS->(MsUnLock())
				
				U_F0500211(SQS->QS_FILIAL,SQS->QS_VAGA,"2")	//Status da Vaga na FAP
				U_F0500201(SQS->QS_XSOLFIL, SQS->QS_XSOLPTL, "011")
				U_F0500201(PA2->PA2_FILSOL,PA2->PA2_SOL,"004") //FAP REPROVADA
			EndIF

		EndIf
	EndIf
	
	AEval(aAreas, {|x| RestArea(x)} )
	
Return lRet
/*{Protheus.doc} GrvRH3RH4
Grava os dados das Tabelas RH3 e RH4
@author Kaiam Rodrigues
@since 17/10/2016
@Project MAN0000007423039_EF_003
*/
Static Function GrvRH3RH4(cMatric, cFilOri, cSubGrp, cTipo, cOrigem, aCampos, aDados)
	
	Local aArea     := GetArea()
	Local cValAux   := ""
	Local nX        := 0
	Local cMatResp  := ""
	Local lRet      := .T.
	Local cFilResp  := ""
	Local cCodDep   := ""
	Local nNivel    := 0
	Local aRetSup   := {}
	Local cDepto    := Alltrim(Posicione("SRA",1,cFilOri+cMatric,"RA_DEPTO"))
	Local cRh3Cod   := ""
	Local cStatus   := ""
	Local cNotif    := ""
	Local cObsLog   := "Solicitação da FAP Aberta"
	Local aEmail    := {}
	Local cEmail    := ""
	Local cQueryChv := ""
	Local cQuery    := ""
	Local cAlias1   := GetNextAlias()
	Local cChave    := ""
	Local cFilPost  := ""
	Local cCodPost  := ""
	
	cRh3Cod  := U_F1302201({XFilial("RH3"),"",""}, .T.)
	
	DbSelectArea("SQS")
	SQS->(DbSetOrder(1))
	If SQS->(DbSeek(aDados[1]+aDados[4]))
		cFilResp := SQS->QS_FILRESP
		cMatResp := SQS->QS_MATRESP
	EndIf
	
	//Busca o Superior - cCod = cSubGrp
	aRetSup := U_F0800501("1",,,cTipo ,cSubGrp,cFilResp,cMatResp,,,,,@aEmail,.F.)
	If aRetSup[1][1]
		
		cNotif := Posicione("PAC",1,XFilial("PAC")+aRetSup[1][6]+aRetSup[1][4],"PAC_APRNOT")
		
		If (aRetSup[1][5] == "FM" .And. cNotif == "2") .Or. (aRetSup[1][5] == "FM" .And. ("aprova direto" $ aRetSup[1][8] .OR. "Terminou a estrutura da visão!" $ aRetSup[1][8] ))
			cStatus := "4"
		Else
			cStatus := "1"
		EndIf
		
		cVisPAB := POSICIONE("PAB",1,xFilial("PAB")+aRetSup[1][6],"PAB_VISAO")
		//Chave do solicitante da FAP
		cQueryChv := "SELECT RD4_CHAVE,RD4_FILIDE,RD4_CODIDE "
		cQueryChv += "FROM " + RetSqlName("RCX") + " RCX "
		cQueryChv += "INNER JOIN " + RetSqlName("RD4") + " RD4 ON(RD4.RD4_FILIDE = RCX.RCX_FILIAL AND "
		cQueryChv += "RD4.RD4_CODIDE = RCX.RCX_POSTO AND RD4.D_E_L_E_T_ = ' ') "
		cQueryChv += "WHERE RCX.RCX_FILFUN = '" + cFilResp  + "' AND "
		cQueryChv += "RCX.RCX_MATFUN = '" + cMatResp + "' AND "
		cQueryChv += "RD4.RD4_CODIGO = '" + cVisPAB + "' AND "
		cQueryChv += "RCX.D_E_L_E_T_ = ' '"
		
		cQueryChv := ChangeQuery(cQueryChv)
		DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQueryChv),cAlias1,.T.,.T.)
		
		If !(cAlias1)->(EOF())
			cChave := (cAlias1)->RD4_CHAVE
		EndIf
		(cAlias1)->(DbCloseArea())
		
		cAlias1 := GetNextAlias()
		//Filial e posto do solicitante da vaga
		cQuery := "SELECT RD4_CHAVE,RD4_FILIDE,RD4_CODIDE "
		cQuery += "FROM " + RetSqlName("RCX") + " RCX "
		cQuery += "INNER JOIN " + RetSqlName("RD4") + " RD4 ON(RD4.RD4_FILIDE = RCX.RCX_FILIAL AND "
		cQuery += "RD4.RD4_CODIDE = RCX.RCX_POSTO AND RD4.D_E_L_E_T_ = ' ') "
		cQuery += "WHERE RCX.RCX_FILFUN = '" + cFilResp  + "' AND "
		cQuery += "RCX.RCX_MATFUN = '" + cMatResp + "' AND "
		cQuery += "RD4.RD4_CODIGO = '" + cVisPAB + "' AND "
		cQuery += "RCX.D_E_L_E_T_ = ' '"
		
		cQueryChv := ChangeQuery(cQueryChv)
		DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias1,.T.,.T.)
		
		If !(cAlias1)->(EOF())
			cFilPost := (cAlias1)->RD4_FILIDE
			cCodPost := (cAlias1)->RD4_CODIDE
		EndIf
		
		DbSelectArea("RH3")
		RecLock("RH3",.T.)
		RH3->RH3_FILIAL := XFilial("RH3")
		RH3->RH3_CODIGO := cRh3Cod
		RH3->RH3_MAT	:= cMatric
		RH3->RH3_TIPO   := ""
		RH3->RH3_ORIGEM := cOrigem
		RH3->RH3_STATUS := cStatus
		RH3->RH3_DTSOLI := dDataBase
		RH3->RH3_FILINI := cFilOri
		RH3->RH3_MATINI := cMatric
		RH3->RH3_NVLAPR	:= val(aRetSup[1][4])
		RH3->RH3_FILAPR := aRetSup[1][2]
		RH3->RH3_MATAPR := aRetSup[1][3]
		RH3->RH3_EMP    := cEmp
		RH3->RH3_EMPINI := cEmp
		RH3->RH3_EMPAPR := cEmp
		RH3->RH3_XTPCTM	:= cTipo
		RH3->RH3_XCODAL := aRetSup[1][6]
		RH3->RH3_XPRXNV := aRetSup[1][5]
		If !Empty(aRetSup[1][9]) .AND. !Empty(aRetSup[1][10])
			RH3->RH3_XSUBST := "S"
			RH3->RH3_XFILSU := aRetSup[1][9]
			RH3->RH3_XMATSU := aRetSup[1][10]
		EndIf
		RH3->RH3_VISAO  := cVisPAB
		RH3->RH3_XCHAVE := cChave
		RH3->RH3_XFILPO := cFilPost
		RH3->RH3_XCODPO := cCodPost
		RH3->(MsUnLock())
		
		// Ticket No.4724773 - 418497 - Don Junior - Gravação dados na PA2
		cP2Sol := RH3->RH3_CODIGO
		
		U_F0801201(RH3->RH3_FILAPR, RH3->RH3_MATAPR, RH3->RH3_FILIAL, RH3->RH3_CODIGO, RH3->RH3_NVLAPR, RH3->RH3_XCODAL)
		
		DbSelectArea("RH4")
		
		For nX := 1 to Len(aCampos)
			
			If RH4->(DbSeek(XFilial("RH4")+ RH3->RH3_CODIGO + STR(nX,3,0)))
				RecLock("RH4",.F.)
			Else
				RecLock("RH4",.T.)
			EndIf
			
			If Posicione("SX3", 2, aCampos[nX], "X3_TIPO") == "C"
				cValAux := aDados[nX]
			ElseIf Posicione("SX3", 2, aCampos[nX], "X3_TIPO") == "D"
				cValAux := DtoS(aDados[nX])
			ElseIf Posicione("SX3", 2, aCampos[nX], "X3_TIPO") == "N"
				cValAux := AllTrim(STR(aDados[nX]))
			Else
				cValAux := cValToChar(aDados[nX])
			EndIf
			
			If ALLTRIM(aCampos[nX]) == "PA2_DTADMI"
				cValAux := cValToChar(StoD(cValAux))
			EndIf
			
			RH4->RH4_FILIAL := XFilial("RH4")
			RH4->RH4_CODIGO := RH3->RH3_CODIGO
			RH4->RH4_ITEM   := nX
			RH4->RH4_CAMPO  := aCampos[nX]
			RH4->RH4_VALNOV := cValAux
			RH4->(MsUnLock())

			// Ticket No.4724773 - 418497 - Don Junior - Gravação dados na PA2
			Do Case
				Case RH4_CAMPO == 'PA2_FILIAL'
					cP2Filia := AllTrim(RH4_VALNOV)
				Case RH4_CAMPO == 'PA2_CDVAGA'
					cP2Vaga := RH4_VALNOV
				Case RH4_CAMPO == 'TMP_FILVAG'
					cP2FilVg := RH4_VALNOV
				Case RH4_CAMPO == 'PA2_VLVAGA'
					cP2Vlr := Val(RH4_VALNOV)
				Case RH4_CAMPO == 'PA2_SLFECH'
					cP2Slfech := Val(RH4_VALNOV)
				Case RH4_CAMPO == 'PA2_CDCAND'
					cP2CdCand := RH4_VALNOV
				Case RH4_CAMPO == 'PA2_NMCAND'
					cP2Nome := RH4_VALNOV
				Case RH4_CAMPO == 'PA2_CPFCAN'
					cP2CPF := RH4_VALNOV
				Case RH4_CAMPO == 'PA2_TPALTS'
					cP2TpAlts := RH4_VALNOV
			EndCase
			
		Next nX
		
		If Len(aEmail) > 0
			For nX := 1 To Len(aEmail)
				cEmail += AllTrim(aEmail[nX]) + ";"
				
				U_F0800201("1",;
					xFilial("RH3"),;
					cRh3Cod,;
					RH3->RH3_XCODAL,;	//-15
					RH3->RH3_FILINI,;	//-04
					RH3->RH3_MATINI,;	//-05
					RH3->RH3_FILAPR,;	//-11
					RH3->RH3_MATAPR,;	//-12
					"Notificador-Inclusão",;
					aEmail[nX],;
					Strzero(RH3->RH3_NVLAPR,TAMSX3("RH3_XPRXNV")[1]))	//-10			
			Next	
			U_F0800901("3",cEmail,RH3->RH3_FILIAL,cRh3Cod,POSICIONE("SRA",1,RH3->RH3_FILINI + RH3->RH3_MATINI,"RA_NOME" ),'004',cSubGrp,Strzero(RH3->RH3_NVLAPR,TAMSX3("RH3_XPRXNV")[1]),"Notificação")
		Else
			SRA->(DbSetOrder(1)) 
			SRA->(DbSeek(RH3->RH3_FILAPR + RH3->RH3_MATAPR))
			U_F0800901("1",SRA->RA_EMAIL,RH3->RH3_FILIAL,RH3->RH3_CODIGO,SRA->RA_NOME,"004",cSubGrp,Strzero(RH3->RH3_NVLAPR,TAMSX3("RH3_XPRXNV")[1]),"")
		EndIf		
		
		DbSelectARea("SQG")
		SQG->(dbSetOrder(1))
		cFILsQG := U_F0600402( FWXFilial("PA2"), "SQG")
		If SQG->(dbSeek(cFILsQG + M->PA2_CDCAND))
			Reclock("SQG",.f.)
			SQG->QG_XFILFAP := FWXFilial("PA2")
			SQG->QG_XCODFAP := cRh3Cod
			SQG->(MsUnLock())
		EndIf
		
		//Grava o log de inclusão da solicitação 
		U_F0800201("1",XFilial("RH3"),cRh3Cod,aRetSup[1][6],cFilOri,cMatric,aRetSup[1][2],aRetSup[1][3],cObsLog,aRetSup[1][7],aRetSup[1][4])
				
		If cStatus == "4"
			U_F0500302(xFilial("PA2"), RH3->RH3_FILIAL, RH3->RH3_CODIGO, "RI")		
		EndIf
	Else
		
		Help( ,, 'Atenção',, aRetSup[1][8], 1, 0 )
		lRet := .F.
		
	EndIf
	
	RestArea( aArea )
	
Return lRet

/*{Protheus.doc} F0500303
Cria Tela de Legendas
@author Kaiam Rodrigues
@since 17/11/2016
@Project MAN0000007423039_EF_003
*/
User Function F0500303()
	BrwLegenda("FAP","Legenda", {;
		{"BR_VERDE" 	,"Aprovado"},;
		{"BR_AMARELO"   ,"Aguardando Aprovação"},;
		{"BR_VERMELHO" 	,"Rejeitado"}})
Return

/*{Protheus.doc} F0500304
Consulta Padrão "Customizada" - FSSQS2
@author Kaiam Rodrigues
@since 17/10/2016
@Project MAN0000007423039_EF_003
*/
User Function F0500304()
	
	Local bRet := .F.
	
	Private cCodigo    := Alltrim(&(ReadVar()))
	
	bRet := FiltraPA2()
	
Return(bRet)

/*{Protheus.doc} FiltraPA2
Função específica para Consulta específica SQS2
@author Kaiam Rodrigues
@since 17/10/2016
@Project MAN0000007423039_EF_003
*/
Static Function FiltraPA2()
	
	Local CALIAS1 		:= GetNextAlias()
	Local cQuery		:= ""
	Local oLstSB1 		:= nil
	
	Private oDlgPA2 	:= nil
	Private lRet 		:= .F.
	Private aDadosPA2 	:= {}
	
	cQuery := " SELECT SQS.QS_FILIAL, SQS.QS_VAGA, SQS.QS_DESCRIC,SQS.QS_NRVAGA,SQS.QS_VAGAFEC, SQS.R_E_C_N_O_ RECNO  "
	cQuery += " FROM "+RetSQLName("SQS") + " SQS"
	cQuery += " WHERE SQS.D_E_L_E_T_ = ' ' "
	cQuery += " AND SQS.QS_XSTATUS IN ('1','2','3','4')"
	cQuery += " ORDER BY QS_FILIAL,QS_VAGA "
	
	DbUseArea(.T.,"TOPCONN", TCGENQRY(,,cQuery),cAlias1, .F., .T.)
	
	(cAlias1)->(DbGoTop())
	
	Do While (cAlias1)->(!Eof())
		
		If ((cAlias1)->QS_NRVAGA - (cAlias1)->QS_VAGAFEC) > 0
			aAdd( aDadosPA2, { (cAlias1)->QS_FILIAL, (cAlias1)->QS_VAGA, (cAlias1)->QS_DESCRIC, (cAlias1)->RECNO} )
		EndIf
		
		(cAlias1)->(DbSkip())
	Enddo
	
	(cAlias1)->(DbCloseArea())
	
	If Len(aDadosPA2) > 0
		nList := aScan(aDadosPA2, {|x| alltrim(x[3]) == alltrim(cCodigo)})
		
		iif(nList = 0,nList := 1,nList)
		
		Define MsDialog oDlgPA2 Title "Busca de Vagas" From 0,0 To 280, 500 Of oMainWnd Pixel
		
		@ 5,5 LISTBOX oLstPA2 	VAR lVarMat Fields HEADER "Filial", "Vaga", "Descrição"	SIZE 245,110 On;
			DblClick ( ConfPA2(oLstPA2:nAt, @aDadosPA2, @lRet) ) OF oDlgPA2 PIXEL
		
		oLstPA2:SetArray(aDadosPA2)
		oLstPA2:nAt := nList
		oLstPA2:bLine := { || {aDadosPA2[oLstPA2:nAt,1], aDadosPA2[oLstPA2:nAt,2], aDadosPA2[oLstPA2:nAt,3]}}
		
		DEFINE SBUTTON FROM 122,5 TYPE 1 ACTION ConfPA2(oLstPA2:nAt, @aDadosPA2, @lRet) ENABLE OF oDlgPA2
		DEFINE SBUTTON FROM 122,40 TYPE 2 ACTION oDlgPA2:End() ENABLE OF oDlgPA2
		
		Activate MSDialog oDlgPA2 Centered
	Else
		Help( ,, "HELP",, "Não existem vagas disponíveis!", 1, 0)
		lRet := .F.
	EndIf
	
Return lRet

Static Function ConfPA2(nPos, aDadosPA2, lRet)
	
	SQS->(DBGoTo(aDadosPA2[nPos][4]))
	lRet := .T.
	
	oDlgPA2:End()
	
Return .T.

/*{Protheus.doc} PreVal
Pre Validação do Model
@author Kaiam Rodrigues
@since 17/10/2016
@Project MAN0000007423039_EF_003
*/
Static Function PreVal(oModel)
	
	Local aAreaSQG := SQG->(GetArea())
	Local lRet     := .T.  //Retorno da Função
	Local nOpera   := oModel:GetOperation()
	Local lLibPst  := SuperGetMv("FS_BLQSOL",,.F.)
	Local cQuery   := ""
	
	Private oMdl   := oModel:getModel('F05003_PA2')
	Private oModel := FwModelActive()
	
	If nOpera != 5
		If !Empty(oMdl:getValue('PA2_FILVG'))
			PA2->(DbSetOrder(1))
			If PA2->(DbSeek(PA2->(XFILIAL("PA2") + oMdl:getValue('PA2_CDVAGA'))))
				while PA2->(PA2_FILIAL+PA2_CDVAGA) == PA2->(XFilial("PA2") + oMdl:getValue('PA2_CDVAGA') )
					If ALLTRIM(PA2->(PA2_SIT)) != "RE"
						Help( ,, 'Atenção',, 'Já existe uma solicitação de FAP em aberto para esta vaga.', 1, 0 )
						lRet := .F.
						Exit
					Else
						lRet := .T.
					EndIf
					PA2->(DbSkip())
				EndDo
			EndIf
			If lRet .And. !VldCand(xFilial("PA2"),oMdl:getValue('PA2_CDCAND'))
				Help( ,, 'Atenção',, 'O Candidato selecionado já está alocado em uma FAP.', 1, 0 )
				lRet := .F.
			EndIf
		Else
			Help( ,, 'Atenção',, 'Filial da Vaga Não Preenchida, faça a Busca da Vaga pelo botão F3', 1, 0 )
			lRet := .F.
		EndIf
	EndIf
	If lRet
		SQG->(DbSetOrder(1))
		If SQG->(DbSeek(XFilial("SQG")+oMdl:getValue('PA2_CDCAND')))		
			If SitCand() .And. Empty(oMdl:getValue('PA2_TPALTS'))
				Help( ,, 'Atenção',, 'Necessário informar o tipo de aumento para FAP Interna', 1, 0 )
				lRet := .F.				
			EndIf
		Else
			Help( ,, 'Atenção',, 'Currículo Não Encontrado', 1, 0 )
			lRet := .F.
		EndIf				
	EndIf
	
	If lRet
		lRet := ValSalario(oModel)
	EndIf
	
	If lRet
		If nOpera == 3
			If lLibPst
			
				cAlias1 := GetNextAlias()
			
				cQuery := "SELECT SQS.QS_FILPOST, SQS.QS_POSTO, RCL.RCL_NPOSTO, RCL.RCL_OPOSTO "
				cQuery += "FROM " + RetSqlName("SQS") + " SQS "
				cQuery += "INNER JOIN " + RetSqlName("RCL") + " RCL "
				cQuery += "ON ( RCL.RCL_FILIAL = SQS.QS_FILPOST AND RCL.RCL_POSTO = SQS.QS_POSTO "
				cQuery += "AND RCL.D_E_L_E_T_ = ' ') "
				cQuery += "WHERE SQS.QS_FILIAL = '" + AllTrim(oMdl:getValue('PA2_FILVG')) + "' "
				cQuery += "AND SQS.QS_VAGA = '" + AllTrim(oMdl:getValue('PA2_CDVAGA')) + "' "
				cQuery += "AND SQS.D_E_L_E_T_ = ' ' "
				
				cQuery := ChangeQuery(cQuery)
				dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias1)
				
				If (cAlias1)->(!EOF())
					If ((cAlias1)->RCL_NPOSTO - (cAlias1)->RCL_OPOSTO) == 0
						If SitCand()
//							MsgAlert("Este posto está ocupado. A solicitação será processada, mas o colaborador será movimentado somente após a desocupação do posto.") //Interno
							MsgAlert("Este posto está ocupado. Caso não realize a adequação, a quantidade de colaboradores existentes será maior que a quantidade prevista.") //Interno
						Else
//							MsgAlert("Este posto está ocupado. A solicitação seguirá para Recrutamento e Seleção, mas o candidato será admitido somente após a desocupação do posto.") //Externo
							MsgAlert("Este posto está ocupado. Caso não realize a adequação, a quantidade de colaboradores existentes será maior que a quantidade prevista.") //Externo
						EndIf						
					EndIf
				EndIf
				
				(cAlias1)->(DbCloseArea())
			
			EndIf
			
			If AllTrim(oMdl:getValue('PA2_SIT')) == "RI"
				AtuVaga(AllTrim(oMdl:getValue('PA2_FILVG')),AllTrim(oMdl:getValue('PA2_CDVAGA')))
			EndIf
			
			U_F0500201(RH3->RH3_FILIAL,RH3->RH3_CODIGO,"001")
			
			If RH3->RH3_STATUS == "4"
				U_F0500201(RH3->RH3_FILIAL,RH3->RH3_CODIGO,"005")			
			Else
				U_F0500201(RH3->RH3_FILIAL,RH3->RH3_CODIGO,"002")
			EndIf
			
	//		MsgAlert("Solicitação da FAP " + AllTrim(oMdl:getValue('PA2_SOL')) + " foi efetuada com sucesso.")
			Aviso("AVISO","Solicitação da FAP " + AllTrim(oMdl:getValue('PA2_SOL')) + " foi efetuada com sucesso.",,1,,,,,5000,)	

		
		Endif
	
	Endif
	
	RestArea(aAreaSQG)
Return lRet

/*{Protheus.doc} DataMov
Ajusta data de Movimentação
@author Kaiam Rodrigues
@since 17/10/2016
@Project MAN0000007423039_EF_003
*/
Static Function DataMov()
	
	Local lRet             := .T.  //Retorno da Função
	Local dData             := dDataBase
	Private oModel          := FwModelActive()
	Private nOpera          := oModel:GetOperation()
	Private oMdl            := oModel:getModel('F05003_PA2')
	
	SQG->(DbSetOrder(1))
	If SQG->(DbSeek(XFilial("SQG")+oMdl:getValue('PA2_CDCAND')))
		If SitCand(SQG->QG_CIC) //CANDIDATO INTERNO
			If Day(dData) <= 20
				dData := Firstday(Lastday(dDatabase)+1)
			Else
				dData := Firstday(Lastday(Firstday(Lastday(dDatabase)+1))+1)
			EndIf
			oMdl:setValue('PA2_DTMOV',dData)
		EndIf
	EndIf
	
Return lRet

/*{Protheus.doc} VerOrcament
Verifica se Existe Verba Disponível no Orçamento
@author Kaiam Rodrigues
@since 17/10/2016
@Project MAN0000007423039_EF_003
*/
Static Function VerOrcament()
	Local lRet := .T.
Return lRet

/*{Protheus.doc} BscFxSal
Pega tabela salarial
@author Henrique Madureira
@since 
@Project MAN0000007423039_EF_003
*/
Static Function BscFxSal(cCodVg, cFilP, cFlSolSqs, cCdSolSqs)

	Local cQuery 	:= ""
	Local cAliRB6	:= "INFRB6"
	Local cHrMes  := "1"
	Local aAux		:= {}
	
	Default cFlSolSqs := ""
	Default cCdSolSqs := ""

	RH4->(DbSetOrder(1))
			
	If RH4->(DbSeek(cFlSolSqs + cCdSolSqs + "19"))
		cHrMes := ALLTRIM(RH4->RH4_VALNOV)
	EndIf
	
	cFilRb6 := U_F0600402( cFilP, "RB6")
	cFilSq3 := U_F0600402( cFilP, "SQ3")
	
	cQuery := "SELECT RB6.RB6_VALOR,RB6.RB6_FAIXA,RB6.RB6_NIVEL FROM " + RetSqlName("RBR") + " RBR "
	cQuery += "INNER JOIN " + RetSqlName("RB6") + " RB6 "
	cQuery += "ON RB6.RB6_FILIAL = '" + cFilRb6 + "' AND "
	cQuery += "RB6.RB6_TABELA     = (SELECT Q3_TABELA FROM " + RetSqlName("SQ3") + " "
	cQuery += "				WHERE  Q3_FILIAL = '" + cFilSq3 + "' AND Q3_CARGO = '" + cCodVg + "' AND D_E_L_E_T_ = ' ') "
	cQuery += "AND RB6.RB6_NIVEL  = (SELECT Q3_TABNIVE FROM " + RetSqlName("SQ3") + " "
	cQuery += "				WHERE  Q3_FILIAL = '" + cFilSq3 + "' AND Q3_CARGO = '" + cCodVg + "' AND D_E_L_E_T_ = ' ') "
	cQuery += "AND RB6.RB6_DTREF = RBR.RBR_DTREF "
	cQuery += "AND RB6.D_E_L_E_T_ = ' '  "
	cQuery += "WHERE RBR.RBR_FILIAL = '" + cFilRb6 + "' "
	cQuery += "AND RBR.RBR_TABELA = (SELECT Q3_TABELA FROM " + RetSqlName("SQ3") + " WHERE  Q3_FILIAL = '" + cFilSq3 + "' AND Q3_CARGO = '" + cCodVg + "' AND D_E_L_E_T_ = ' ') "
	cQuery += "AND RBR.RBR_APLIC = '1' "
	cQuery += "AND RBR.D_E_L_E_T_ = ' ' "
	cQuery += "ORDER BY RB6.RB6_NIVEL, RB6.RB6_FAIXA "
	
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliRB6)
	
	DbSelectArea(cAliRB6)
	While ! (cAliRB6)->(EOF())
		If cHrMes == "1"
			AADD(aAux, {(cAliRB6)->RB6_NIVEL,(cAliRB6)->RB6_FAIXA,(cAliRB6)->RB6_VALOR})
		Else
			AADD(aAux, {(cAliRB6)->RB6_NIVEL,(cAliRB6)->RB6_FAIXA,(((cAliRB6)->RB6_VALOR * val(cHrMes)) / 220)})
		EndIf
		(cAliRB6)->(DbSkip())
	End
	(cAliRB6)->(DbCloseArea())

Return aAux

/*/{Protheus.doc} FSSQS3
Função para criar tela com F3 com Filtro
@author Fernando Carvalho
@since 03/05/2017
@version undefined

@type function
/*/
User Function FSSQS3()
	Local lRet			:= .F.
	Local oLayer 		:= FWLayer():new()
	Local aBrowse 	:= {}
	Local aFieFilter	:= {}
	Local aStru 		:= {}
	Local aCampos 	:= {}
	Local aColumns	:= {}
	Local nFor			:= 0
	
	cAliasF3	:= GetNextAlias()
	
	cQuery := " SELECT SQS.QS_FILIAL, SQS.QS_VAGA, SQS.QS_DESCRIC,SQS.QS_NRVAGA,SQS.QS_VAGAFEC, SQS.R_E_C_N_O_ RECNO  "
	cQuery += " FROM "+RetSQLName("SQS") + " SQS"
	cQuery += " WHERE SQS.D_E_L_E_T_ = ' ' "
	cQuery += " AND SQS.QS_XSTATUS IN ('1','2','3','4','8','9')"
	cQuery += " ORDER BY QS_FILIAL,QS_VAGA "
	
	cQuery := ChangeQuery(cQuery)
	
	DEFINE MSDIALOG oDlg FROM 0,0 TO 500,800 TITLE OemToAnsi("Consulta Padrão") PIXEL OF oMainWnd
	oLayer:init(oDlg,.F., .T.)
	
	oLayer:addLine('Sup',80,.F.)
	oLayer:addLine('Inf',90,.F.)
	oLayer:addCollumn('Col',100,.F.,'Sup')
	oLayer:addCollumn('Col',100,.F.,'Inf')
	
	oLayer:addWindow('Col','Browse' ,''	,100,.T.,.F.,{|| /*"Clique janela 01!"*/ },'Sup',{|| /*"Janela 01 recebeu foco!"*/ })
	oLayer:addWindow('Col','Button' ,''	,100,.T.,.T.,{|| /*"Clique janela 02!"*/ },'Inf',{|| /*"Janela 02 recebeu foco!"*/ })
	
	oPanel1 	:= oLayer:GetWinPanel('Col','Browse','Sup')
	oPanel1:FreeChildren()
	oPanel2 	:= oLayer:GetWinPanel('Col','Button','Inf')
	oPanel2:FreeChildren()
	//Browse
	//
	//Monta colunas
	aAdd(aCampos, {"QS_FILIAL"	,"Filial"		, "C"	, 08  , 	0 ,	"@!" })
	aAdd(aCampos, {"QS_VAGA"		,"Vaga"		, "C"	, 08  , 	0 ,	"@!" })
	aAdd(aCampos, {"QS_DESCRIC"	,"Descrição"	, "C"	, 08  , 	0 ,	"@!" })
	
	For nFor := 1 To Len(aCampos)
		AAdd( aColumns, FWBrwColumn():New() )
		
		aColumns[Len(aColumns)]:SetData( &("{||" + aCampos[nFor][1] + "}") )
		aColumns[Len(aColumns)]:SetTitle( aCampos[nFor][2] )
		aColumns[Len(aColumns)]:SetType( aCampos[nFor][3] )
		aColumns[Len(aColumns)]:SetSize( aCampos[nFor][4] )
		aColumns[Len(aColumns)]:SetDecimal( aCampos[nFor][5] )
		aColumns[Len(aColumns)]:SetPicture( aCampos[nFor][6] )
	Next nFor
	
	oBrowse 	:= FWBrowse():New()
	//oBrowse:SetDataTable()
	oBrowse:SetDataQuery(.T.)
	oBrowse:SetQuery(cQuery)
	oBrowse:SetAlias(cAliasF3)
	oBrowse:SetOwner(oPanel1)
	oBrowse:SetDescription("Consulta Padrão")
	oBrowse:SetColumns( aClone(aColumns) )
	Aadd(aFieFilter,{'QS_FILIAL' , "Filial"		,'C', 08, 0,""})
	Aadd(aFieFilter,{'QS_VAGA'	 , "Vaga"		,'C', 06, 0,""})
	Aadd(aFieFilter,{'QS_DESCRIC', "Descrição"	,'C', 30, 0,""})
			
	oBrowse:setFieldFilter(aFieFilter)
	
	// Habilita/Desabilita opções de Salvar, Imprimir, etc.
	oBrowse:SetUseFilter() // Habilita a utilização do Filtro de registros
	oBrowse:SetLocate() // Habilita a Localização de registros
	oBrowse:SetSeek() // Habilita a Pesquisa de registros
	
	oBrowse:Activate()
	
	TButton():New( 010, 002, "OK"			, oPanel2,{||OK(), lRet := .T.,oDlg:End() },40,010,,,.F.,.T.,.F.,,.F.,,,.F. )
	TButton():New( 010, 052, "Visualizar" 	, oPanel2,{|| VisualF3(oBrowse) },40,010,,,.F.,.T.,.F.,,.F.,,,.F. )
	TButton():New( 010, 102, "Cancelar"   	, oPanel2,{|| lRet := .F.,oDlg:End() },40,010,,,.F.,.T.,.F.,,.F.,,,.F. )
        
	ACTIVATE MSDIALOG oDLG  CENTER
	
Return lRet

/*/{Protheus.doc} OK
Executa quandro clicado no ok da consulta
@author Fernando Carvalho
@since 03/05/2017
@version undefined

@type function
/*/
Static Function OK()
	Local cAliasF3 := Alias()
	cFilF3 	:= (cAliasF3)->QS_FILIAL
	cCodF3	:= (cAliasF3)->QS_VAGA
Return

/*/{Protheus.doc} VisualF3

@author Fernando Carvalho
@since 03/05/2017
@version undefined

@type function
/*/	
Static Function VisualF3(oBrowse)
	Local cAliasF3		:= Alias()
	Local cFilSQS 		:= (cAliasF3)->QS_FILIAL
	Local cVagaSQS		:= (cAliasF3)->QS_VAGA
	Private cCadastro	:= "SQS"
	
	DbSelectArea("SQS")
	SQS->(DbSetOrder(1))
	SQS->(DbSeek(cFilSQS + cVagaSQS))
	AxVisual("SQS",SQS->(Recno()),2)
Return

/*/{Protheus.doc} FSSQS3R1

@author Fernando Carvalho
@since 03/05/2017
@version undefined

@type function
/*/	
User Function FSSQS3R1()
Return(cFilF3)

/*/{Protheus.doc} FSSQS3R2

@author Fernando Carvalho
@since 03/05/2017
@version undefined

@type function
/*/	
User Function FSSQS3R2()
Return(cCodF3)


Static Function AtuVaga(cFilVg,cCodVg)
	Local aAreaSQS	:=	SQS->(GetArea())
	SQS->(DbSetOrder(1))
	If SQS->(DbSeek(cFilVg+cCodVg))
		RecLock("SQS",.F.)
		If SitCand()//! (Empty(SQG->QG_MAT))
			If SQS->QS_XSTATUS != "3" //Em Recrutamento (RI)
				SQS->QS_XSTATUS := "3" //Em Recrutamento (RI)	
				U_F0500201(SQS->QS_XSOLFIL, SQS->QS_XSOLPTL, "012")
			EndIf			
		Else
			If SQS->QS_XSTATUS != "2"
				SQS->QS_XSTATUS := "2" //Em Recrutamento		
				U_F0500201(SQS->QS_XSOLFIL, SQS->QS_XSOLPTL, "011")
			EndIf
		EndIf
		SQS->(MsUnLock())
		
		U_F0500211(SQS->QS_FILIAL,SQS->QS_VAGA,SQS->QS_XSTATUS)	//Status da Vaga na FAP
	EndIf
	RestArea(aAreaSQS)
Return

//////////////////////////////////////////////////
// Valida se o candidato já está em alguma vaga //
//////////////////////////////////////////////////
Static Function VldCand(cFilPA2,cCodCand)

Local lRet			:= .T.
Local cTempAlias	:= GetNextAlias()

cQuery := " SELECT PA2_FILIAL FROM " + RetSqlName("PA2") + " PA2 "
cQuery += " WHERE "
cQuery += " PA2_FILIAL = '"+cFilPA2+"' "
cQuery += " AND PA2_CDCAND = '"+cCodCand+"' "

// Ticket No.5473899 - 418497 - Don Junior - Alteração query para não listar FAPs concluídas (CL)
cQuery += " AND PA2_SIT NOT IN ('RE','CL')" // " AND PA2_SIT <> 'RE' "

cQuery += " AND PA2.D_E_L_E_T_ = ' ' "
cQuery := ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cTempAlias)

If (cTempAlias) -> (!EOF())
	lRet := .F.
Endif

(cTempAlias)->(DbCloseArea())
	
Return lRet

//////////////////////////////////////////////////
// Verifica se o Candidato é interno ou externo //
//////////////////////////////////////////////////
Static Function SitCand(cCIC)
	Local cTempAlias	:= GetNextAlias()
	Local lRet 	:= .F.

	Default cCIC	:= oMdl:getValue('PA2_CPFCAN')
		
	cQuery := " SELECT SRA.R_E_C_N_O_ NumRec FROM " + RetSqlName("SRA") + " SRA "
	cQuery += " WHERE "
	cQuery += " SRA.RA_CIC = '"+cCIC+"' "
	cQuery += " AND SRA.RA_SITFOLH <> 'D' "
	cQuery += " AND SRA.D_E_L_E_T_ = ' ' "
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cTempAlias)
	
	If (cTempAlias) -> (!EOF())
		SRA->(DbGoTo((cTempAlias) -> NumRec))
		lRet := .T.
	Endif

	(cTempAlias)->(DbCloseArea())
Return lRet

/*
{Protheus.doc} F0500325()
Validação para cancelamento da solicitação
@Author     Bruno de Oliveira
@Since      15/12/2017
@Version    P12.1.07
@Project    MAN0000007423048_EF_025
*/
User Function F0500325()

	Local aUser := {}
	Local cQuery 
	Local cFSolic := ""
	Local cMSolic := ""
	Local cStatus := ""
	Local cSubGrp := ""
	Local cCodPA2 := PA2->(PA2_FILIAL+PA2_SOL)
	
	DbSelectArea("RH3")
	RH3->(DbSetOrder(1))
	If RH3->(DbSeek(cCodPA2))
		cFilSol := RH3->RH3_FILIAL
		cCodSol := RH3->RH3_CODIGO
		cFSolic := RH3->RH3_FILINI
		cMSolic := RH3->RH3_MATINI
		cStatus := RH3->RH3_STATUS
	EndIf
	
	aUser	:= U_GetInfMat()
	
	If !Empty(aUser[1]) .AND. !Empty(aUser[2])
		If aUser[1]+aUser[2] == cFSolic+cMSolic //Solicitante?		
			If cStatus == "1" .OR. cStatus == "4"			
				U_CanclSlc(cFilSol,cCodSol,cCodPA2,cFSolic,cMSolic,"004")
			Else
				MsgAlert("Usuário não tem permissão para cancelar a solicitação")
			EndIf		
		Else
			MsgAlert("Usuário não tem permissão para cancelar a solicitação")
		EndIf
	EndIf

Return

//-------------------------------------------------
// Função de validação/gravação da PA2
//-------------------------------------------------
Static Function F0500Grv(oModel)

	FWFormCommit(oModel)//Salvando o formulario.

	PA2->(DbSetOrder(6))
	DbGotop()
	If !PA2->(DbSeek(cP2Filia+cP2Sol)) // verifica se existe na PA2 (FAP)
	
		RecLock("PA2",.T.)
			PA2_FILIAL  := cP2Filia   
			PA2_CDVAGA  := cP2Vaga   
			PA2_FILVG   := cP2FilVg
			PA2_VLVAGA  := cP2Vlr
			PA2_SLFECH  := cP2Slfech
			PA2_CDCAND  := cP2CdCand
			PA2_NMCAND  := cP2Nome
			PA2_CPFCAN  := cP2CPF
			PA2_SIT     := 'AG'
			PA2_SOL     := cP2Sol
			PA2_TPALTS  := cP2TpAlts
		PA2->(MsUnLock())
	EndIf
		
Return(.T.)
