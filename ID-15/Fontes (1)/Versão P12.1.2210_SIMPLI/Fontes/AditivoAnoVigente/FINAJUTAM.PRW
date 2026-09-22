#Include "Protheus.ch"
#INCLUDE "APWIZARD.CH"

STATIC __lBlind		:= IsBlind()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFINAJUTAM  บAutor  ณTOTVS SA           บ Data ณ  16/11/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Funcao principal para altera็ใo de campos na base de dados บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

User function FinAjuTam()
	Private oWizard
	Private aRet	:= { 0, 0, MsDate(),1}
	Private lOk		:= .T.
	Private lWizard:= .T. //Uso interno da fun็ใo parambox()

	oWizard := APWizard():New( "Assistente para Ajuste de campos." ,"Aten็ใo!" ,;
		"",;
		"Este assistente tem como finalidade alterar os valores dos campos E2_TITPAI, E1_TITPAI, E5_DOCUMEN, FK7_CHAVE e/ou PX0_CHAVE (tabela customizada) ap๓s altera็ใo do grupo de campos 'Parcela' no SIGACFG.";
		+CHR(10)+CHR(13)+"- Somente rodar este ajuste em modo exclusivo!";
		+CHR(10)+CHR(13)+"- Realizar backup do banco de dados antes da atualiza็ใo.";
		+CHR(10)+CHR(13)+"- Rodar a atualiza็ใo primeiramente em base de homologa็ใo.";
		+CHR(10)+CHR(13)+"- Esta rotina estแ preparada para ser rodada apenas 1 vez, portanto, tenha certeza dos dados que serใo informados na pr๓xima tela!"/*<cText>*/,;
		{||.T.}, {|| .T.},,,,)

	oWizard:NewPanel("Informe os dados abaixo.", "Informe o tamanho anterior e posterior do Grupo de Campos 'PARCELA' para que o ajuste possa corrigir o campo selecionado." ,{||.T.}/*<bBack>*/, ;
		{||.T.} /*<bNext>*/ , ;
		{||U_FinExecAj(@aRet)} ,;
		.T.  ,;
		{|| U_FinChoice(@oWizard,1)} )

	ACTIVATE WIZARD oWizard CENTERED  WHEN {||.T.}

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFinChoice บAutor  ณTOTVS SA            บ Data ณ  16/11/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFuncao que cria a parambox com os campos necessarios para a บฑฑ
ฑฑบ          ณ execu็ใo da rotina                                         บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

User function FinChoice(oWizard,nPanel)
	Local aOpcoes	:= {}
	Local aParamFields := {}
	Local lTitPai2 := !Empty( SE2->( FieldPos( "E2_TITPAI" ) ) )
	Local lTitPai1 := !Empty( SE1->( FieldPos( "E1_TITPAI" ) ) )
	Local lDocumen := !Empty( SE5->( FieldPos( "E5_DOCUMEN" ) ) )
	Local lChave   := !Empty( FK7->( FieldPos( "FK7_CHAVE" ) ) )
	Local lChavePx0   := !Empty( Px0->( FieldPos( "PX0_CHAVE" ) ) )

	If lTitPai2
		aadd(aOpcoes, "1=E2_TITPAI")
	Endif

	If lTitPai1
		aadd(aOpcoes, "2=E1_TITPAI")
	Endif

	If lDocumen
		aadd(aOpcoes, "3=E5_DOCUMEN")
	Endif

	If lChave
		aadd(aOpcoes, "4=FK7_CHAVE")
	EndIf

	If lChavePx0
		aadd(aOpcoes, "5=PX0_CHAVE")
	EndIf

	MV_PAR01 := 0
	MV_PAR02 := 0

	aAdd(aParamFields, {1,"Tamanho Antigo: ",1,"@E 999","MV_PAR01<4 .AND. MV_PAR01>0","","",20,.T.})
	aAdd(aParamFields, {1,"Novo Tamanho : ",1,"@E 999","MV_PAR02<4 .AND. MV_PAR02>0","","",20,.T.})
	aAdd(aParamFields, {1,"At้ Emissใo : ",aRet[3],"","","","",45,.T.})

	aAdd(aParamFields, {2,"Ajustar: ","1",aOpcoes,80,"",.T.})

	ParamBox(aParamFields ,"Executar Ajuste" , @aRet,,,.F.,120,3,oWizard:oMPanel[oWizard:nPanel],,.F. )

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFinExecAj บAutor  ณTOTVS SA            บ Data ณ  16/11/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Funcao que executa a query de acerto dos campos E2_TITPAI  บฑฑ
ฑฑบ          ณ e E5_DOCUMEN                                               บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

User Function FinExecAj(aRet)
	Local aLog2New	:= {}
	Local aLog2Old	:= {}
	Local nOldTam	:= 0
	Local nNewTam	:= 0
	Local nOpc		:= 0
	Local nX			:= 0
	Local nTamPre	:= 0
	Local nTamNum	:= 0
	Local nTamTotal:= 0
	Local cSinal	:= ""
	Local cQuery	:= ""
	Local cAlias	:= ""
	Local cRet		:= ""
	Local cEmissao	:= ""
	Local cFileLog	:= ""
	Local cPath		:= ""
	Local cTipoDB	:= Alltrim(Upper(TCGetDB()))

// Nใo ้ correto e aconselhado a diminui็ใo do tamanho do campo PARCELA por motivos inclusive se integridade dos dados na base.
	IF (MV_PAR01 >= MV_PAR02)
		MSGALERT("Caso tenha alterado o grupo de campos 'Parcela' para um tamanho menor, esta fun็ใo nใo serแ vแlida da forma que se encontra."+CHR(10)+CHR(13);
			+ "Execu็ใo desta fun็ใo serแ abortada!")
		lOk := .F.
	Else
		lOk := MsgYesNo("A base de dados serแ alterada ap๓s esta confirma็ใo! Tem certeza que deseja atualizแ-la?")
	Endif

	If lOk

		// Verifico qual o sinal correto para concatenar dados na query
		Do Case
		Case "MSSQL" $ cTipoDB
			cSinal := "+"
		Case cTipoDB $ "AS/400|DB2"
			cSinal := "concat"
		Otherwise
			cSinal := "||"
		End Case

		/////////// Alimento as variaves principais para o UPDATE /////////////
		nOldTam	:= aRet[1]
		nNewTam	:= aRet[2]
		cEmissao	:= DtoS(aRet[3])
		nOpc		:= If(ValType(aRet[4])=="N", aRet[4], Val(aRet[4]))
		///////////////////////////////////////////////////////////////////////

		If nOpc == 1
			cAlias := "SE2"  // E2_TITPAI
		Elseif nOpc == 2
			cAlias := "SE1"  // E1_TITPAI
		ElseIf nOpc == 3
			cAlias := "SE5"  // E5_DOCUMEN
		ElseIf nOpc == 4
			cAlias := "FK7" //FK7_CHAVE
		ElseIf nOpc == 5
			cAlias := "PX0" //Px0_CHAVE
		Endif

		// Tamanhos de campos que fazem parte da chave do E2_TITPAI e E5_DOCUMEN
		nTamPre	:= TamSx3("E2_PREFIXO")[1]
		nTamNum	:= TamSx3("E2_NUM")[1]
		nTamTotal:= TamSx3("E2_TIPO")[1] + TamSx3("E2_FORNECE")[1] + TamSx3("E2_LOJA")[1]
		nDifTam	:= Iif(nNewTam-nOldTam < 0, 0, nNewTam-nOldTam)

		// --> Gravo em um array os dados dos registros que serใo alterados para gera็ใo de LOG
		//aLog2Old := U_GetOldReg(cAlias,cEmissao)

		Begin Transaction
			cQuery := "UPDATE "+RetSqlName(cAlias)+" "
			If cAlias == "SE2"
				cQuery += " SET E2_XBKPTIT = E2_TITPAI, E2_TITPAI = SUBSTRING(E2_TITPAI,1,"+STR(nTamPre)+")"
				cQuery += cSinal+" SUBSTRING(E2_TITPAI,"+STR(nTamPre+1)+","+STR(nTamNum)+") "
				cQuery += cSinal+" SUBSTRING(E2_TITPAI,"+STR(nTamPre+nTamNum+1)+","+STR(nOldTam)+")"+cSinal+"'"+Space(nDifTam)+"' "
				cQuery += cSinal+" SUBSTRING(E2_TITPAI,"+STR(nTamPre+nTamNum+nOldTam+1)+","+STR(nTamTotal)+") "
				cQuery += "WHERE E2_TITPAI <> ' ' AND E2_EMISSAO <= '"+cEmissao+"' AND D_E_L_E_T_ <> '*' "
			Elseif cAlias == "SE1"
				cQuery += " SET E1_XBKPTIT = E1_TITPAI, E1_TITPAI = SUBSTRING(E1_TITPAI,1,"+STR(nTamPre)+")"
				cQuery += cSinal+" SUBSTRING(E1_TITPAI,"+STR(nTamPre+1)+","+STR(nTamNum)+") "
				cQuery += cSinal+" SUBSTRING(E1_TITPAI,"+STR(nTamPre+nTamNum+1)+","+STR(nOldTam)+")"+cSinal+"'"+Space(nDifTam)+"' "
				cQuery += cSinal+" SUBSTRING(E1_TITPAI,"+STR(nTamPre+nTamNum+nOldTam+1)+","+STR(nTamTotal)+") "
				cQuery += "WHERE E1_TITPAI <> ' ' AND E1_EMISSAO <= '"+cEmissao+"' AND D_E_L_E_T_ <> '*' "
			Elseif cAlias == "SE5"
				cQuery += " SET E5_XBKPMOV = E5_DOCUMEN, E5_DOCUMEN = SUBSTRING(E5_DOCUMEN,1,"+STR(nTamPre)+")"
				cQuery += cSinal+" SUBSTRING(E5_DOCUMEN,"+STR(nTamPre+1)+","+STR(nTamNum)+") "
				cQuery += cSinal+" SUBSTRING(E5_DOCUMEN,"+STR(nTamPre+nTamNum+1)+","+STR(nOldTam)+")"+cSinal+"'"+Space(nDifTam)+"' "
				cQuery += cSinal+" SUBSTRING(E5_DOCUMEN,"+STR(nTamPre+nTamNum+nOldTam+1)+","+STR(nTamTotal)+") "
				cQuery += "WHERE E5_DOCUMEN <> ' ' AND E5_DATA <= '"+cEmissao+"' AND E5_MOTBX = 'CMP' AND D_E_L_E_T_ <> '*' "
			ElseIf cAlias == "FK7" //Lucas Miranda de Aguiar - Inclusใo da FK7
				cQuery += "SET FK7_XBKPCH = FK7_CHAVE, FK7_CHAVE = SUBSTRING(FK7_CHAVE,1,              8)"
				cQuery += "|| SUBSTRING(FK7_CHAVE, 9, 4)"
				cQuery += "|| SUBSTRING(FK7_CHAVE,              13,              10)"
				cQuery += "|| SUBSTRING(FK7_CHAVE,              23,              2)"
				cQuery += "|| '" + Space(nDifTam) + "'"
				cQuery += "|| SUBSTRING(FK7_CHAVE,              25,              5)"
				cQuery += "|| SUBSTRING(FK7_CHAVE,              30,              6)"
				cQuery += "|| SUBSTRING(FK7_CHAVE,              36,              3)"
				cQuery += "WHERE FK7_CHAVE	 <> ' ' AND D_E_L_E_T_ <> '*' "
			ElseIf cAlias == "PX0"//Lucas Miranda de Aguiar - Inclusใo da PX0
				cQuery += "SET PX0_XBKPXR = PX0_CHAVE, PX0_CHAVE = SUBSTRING(PX0_CHAVE,1,              8)"
				cQuery += "|| SUBSTRING(PX0_CHAVE, 9, 3)"
				cQuery += "|| SUBSTRING(PX0_CHAVE,              12,              9)"
				cQuery += "|| SUBSTRING(PX0_CHAVE,              21,              1)"
				cQuery += "|| '" + Space(nDifTam) + "'"
				cQuery += "|| SUBSTRING(PX0_CHAVE,       		22,              2)"
				cQuery += "|| SUBSTRING(PX0_CHAVE,              24,              6)"
				cQuery += "|| SUBSTRING(PX0_CHAVE,              30,              3)"
				cQuery += "WHERE PX0_ORIGEM	 = 'SE2' AND D_E_L_E_T_ <> '*' "
			Endif

			// Prote็ใo de qual fun็ใo deverแ ser chamada caso nใo seja SQL.
			If cTipoDB != "MSSQL"
				cQuery:=StrTran(cQuery,"SUBSTRING","SUBSTR")
			Endif

			// *** Execu็ใo e valida็ใo do retorno *** //
			cRet := TcSqlExec(cQuery)
			If cRet <> 0
				If !__lBlind
					MsgAlert("Erro ao executar UPDATE: "+TCSqlError())  //'Erro criando a Stored Procedure:'
					conout('SQL Error - '+DtoC(MsDate())+" - " + Substr(Time(),1,5))
					conout(MsParseError())
				Endif
				lRet := .F.
			Else
				MsgAlert("UPDATE executado com sucesso!")
			Endif
			// *** *** *** *** *** *** *** *** *** *** //
		End Transaction

		// --> Grava็ใo dos registros depois de alterados para gera็ใo do LOG final
		//aLog2New := U_GetNewReg(cAlias,cEmissao)
	Endif
/*/
// ********* GERAวรO DO LOG ********* //
	If !Empty(aLog2New)
		If nOpc == 1
			AutoGrLog("LOG do campo 'E2_TITPAI' - " +DtoC(MsDate())+ ' ' + Time() )
		Elseif nOpc == 2
			AutoGrLog("LOG do campo 'E1_TITPAI' - " +DtoC(MsDate())+ ' ' + Time() )
		Else
			AutoGrLog("LOG do campo 'E5_DOCUMEN' - " +DtoC(MsDate())+ ' ' + Time() )
		Endif

		For nX := 1 To Len(aLog2New)
			AutoGrLog("-----------------------------------------------------")
			AutoGrLog("Valor Antigo  : "		+ aLog2Old[nX][1])
			AutoGrLog("Valor Novo    : "		+ aLog2New[nX][1])
			AutoGrLog("Recno do Registro : "	+ STR(aLog2Old[nX][2]))
		Next

		cFileLog := NomeAutoLog()

		If cFileLog <> ""
			MostraErro(cPath,cFileLog)
		Endif
	EndIf

	EcdClrMsg() // limpo o controle de mensagens de erro

// ********* FINAL DA GERAวรO DO LOG ********* //
/*/
Return lOk


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGetOldReg บAutor  ณMicrosiga           บ Data ณ  11/16/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
USER Function GetOldReg(cAlias,cEmissao)
	Local aRetOld	:= {}
	Local cSql		:= ""
	Local cAliasTmp:= ""

	If cAlias == "SE2"
		cSql := "SELECT SE2.E2_TITPAI TITPAI, SE2.R_E_C_N_O_ REC FROM "+RetSqlName(cAlias)+" SE2 "
		cSql += "WHERE E2_TITPAI != '' AND E2_EMISSAO <= '"+cEmissao+"' AND D_E_L_E_T_ != '*' "
	ElseIf cAlias == "SE1"
		cSql := "SELECT SE1.E1_TITPAI TITPAI, SE1.R_E_C_N_O_ REC FROM "+RetSqlName(cAlias)+" SE1 "
		cSql += "WHERE E1_TITPAI != '' AND E1_EMISSAO <= '"+cEmissao+"' AND D_E_L_E_T_ != '*' "
	Else
		cSql := "SELECT SE5.E5_DOCUMEN DOCUMENTO, SE5.R_E_C_N_O_ REC FROM "+RetSqlName(cAlias)+" SE5 "
		cSql += "WHERE E5_DOCUMEN != '' AND E5_MOTBX = 'CMP' AND D_E_L_E_T_ != '*' "
	Endif

	cSql := ChangeQuery(cSql)

	cAliasTmp := GetNextAlias()

	dbUseArea(.T., "TOPCONN", TcGenQry(,,cSql), cAliasTmp, .T., .T.)

	If cAlias $ "SE2|SE1"

		While (cAliasTmp)->(!EOF())
			aAdd(aRetOld, { (cAliasTmp)->(TITPAI) , (cAliasTmp)->(REC) } )
			(cAliasTmp)->(dbSkip())
		EndDo

	Else
		While (cAliasTmp)->(!EOF())
			aAdd(aRetOld, { (cAliasTmp)->(DOCUMENTO) , (cAliasTmp)->(REC) } )
			(cAliasTmp)->(dbSkip())
		EndDo

	EndIf

	If Select(cAliasTmp)>0
		(cAliasTmp)->(dbCloseArea())
	Endif

Return aRetOld


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGetNewReg บAutor  ณMicrosiga           บ Data ณ  11/16/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

USER Function GetNewReg(cAlias,cEmissao)
	Local aRetNew	:= {}
	Local cSql		:= ""
	Local cAliasTmp:= ""

	If cAlias == "SE2"
		cSql := "SELECT SE2.E2_TITPAI TITPAI, SE2.R_E_C_N_O_ REC FROM "+RetSqlName(cAlias)+" SE2 "
		cSql += "WHERE E2_TITPAI != '' AND E2_EMISSAO <= '"+cEmissao+"' AND D_E_L_E_T_ != '*' "

	ElseIf cAlias == "SE1"
		cSql := "SELECT SE1.E1_TITPAI TITPAI, SE1.R_E_C_N_O_ REC FROM "+RetSqlName(cAlias)+" SE1 "
		cSql += "WHERE E1_TITPAI != '' AND E1_EMISSAO <= '"+cEmissao+"' AND D_E_L_E_T_ != '*' "

	Else
		cSql := "SELECT SE5.E5_DOCUMEN DOCUMENTO, SE5.R_E_C_N_O_ REC FROM "+RetSqlName(cAlias)+" SE5 "
		cSql += "WHERE E5_DOCUMEN != '' AND E5_MOTBX = 'CMP' AND D_E_L_E_T_ != '*' "
	Endif

	cSql := ChangeQuery(cSql)

	cAliasTmp := GetNextAlias()

	dbUseArea(.T., "TOPCONN", TcGenQry(,,cSql), cAliasTmp, .T., .T.)

	If cAlias $ "SE2|SE1"

		While (cAliasTmp)->(!EOF())
			aAdd(aRetNew, { (cAliasTmp)->(TITPAI) , (cAliasTmp)->(REC) } )
			(cAliasTmp)->(dbSkip())
		EndDo

	Else
		While (cAliasTmp)->(!EOF())
			aAdd(aRetNew, { (cAliasTmp)->(DOCUMENTO) , (cAliasTmp)->(REC) } )
			(cAliasTmp)->(dbSkip())
		EndDo
	EndIf

	If Select(cAliasTmp)>0
		(cAliasTmp)->(dbCloseArea())
	Endif

Return aRetNew
