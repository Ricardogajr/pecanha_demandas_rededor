#include 'protheus.ch'
#include 'parmtype.ch'
#include 'tbiconn.ch'
#include 'rwmake.ch'

Static cMsgETL    := ""
Static oDbApData  := NIL

User function REDF001()

/*/
Rotina de tela para seleção de filiais para rodar o fechamento de estoque.
Autor: Lucas Miranda de Aguiar
Data: 14/01/2019
/*/

	Local   aArea   := GetArea()
	Local nX
	Local aColumns		:= {}
	Private cAliasTemp := GetNextAlias()
	Private aCampos := {} 
		
	aAdd(aCampos,{"OK",       "C",02,0})	
	aAdd(aCampos,{"P26_FILIAL","C",08,0})
	aAdd(aCampos,{"P26_CODFEC","C",19,0})
	aAdd(aCampos,{"P26_DTFECH","C",20,0})
	aAdd(aCampos,{"P26_QTDTOT","C",20,0})

	RPCSetType(3)
	RpcSetEnv("01","01010001")
/*/Função para conectar na base externa e retirar os dados para o fechamento./*/
	InicioETL()

/*/Criação de tabela temporária para adicionar na tela/*/	
	//Início - Thais Paiva - Compatibilização P27
	//cArq := Criatrab( aCampos, .T.)
	//DbUseArea(.T.,,cArq,"TMP")
	oTempTable := FWTemporaryTable():New( "TMP" )
	oTemptable:SetFields( aCampos )
	oTempTable:AddIndex( '01' , { "P26_FILIAL","P26_CODFEC"} ) //Thais Paiva - 04/12/2020
	oTempTable:Create()
	//Fim - Thais Paiva - Compatibilização P27
	TEMPO->(DbGoTop())
	While !TEMPO->(Eof())
		RecLock("TMP",.T.)
		TMP->OK := ""
		TMP->P26_FILIAL := TEMPO->P26_FILIAL
		TMP->P26_CODFEC := TEMPO->P26_CODFEC
		TMP->P26_DTFECH := TEMPO->P26_DTFECH
		TMP->P26_QTDTOT := TEMPO->P26_QTDTOT
		TEMPO->(DbSkip())
	EndDo

/*/Montagem da tela para exibir as filiais/*/
	aCpoBro	:= {{"OK",, "", 					  "@!"},;
	{"P26_FILIAL",, "Código Filial",    	      "@!"},;
	{"P26_CODFEC",, "Código do Fechamento",		  "@!"},;
	{"P26_DTFECH",, "Data do fechamento",  		  "@!"},;
	{"P26_QTDTOT",, "Quantidade de registros",    "@!"}}
	

	oDlg1      := MSDialog():New( 145,254,673,957,"Fechamento de Estoque",,,.F.,,,,,,.T.,,,.T. )
	oGrp2      := TGroup():New( 000,010,184,350,"Seleção de Filiais",oDlg1,CLR_BLACK,CLR_WHITE,.T.,.F. )
	For nX := 2 To Len(aCampos)    
		AAdd(aColumns,FWBrwColumn():New())
		aColumns[Len(aColumns)]:SetData( &("{||"+aCampos[nX][1]+"}") )
		aColumns[Len(aColumns)]:SetTitle(aCampos[nX][1])
		aColumns[Len(aColumns)]:SetSize(aCampos[nX][3])
		aColumns[Len(aColumns)]:SetDecimal(aCampos[nX][4])              
	Next nX
	oBrw1:= FWMarkBrowse():New()
	oBrw1:SetAlias("TRB")      
	oBrw1:DisableReport()
	oBrw1:SetOwner(oDlg1)
	oBrw1:SetAllMark({|| SetMrkAll(oBrw1,"TMP","OK") })        
	oBrw1:SetDescription("")
	oBrw1:SetFieldMark( 'OK' )    //Campo que será marcado/descmarcado
	oBrw1:SetTemporary(.T.)
	oBrw1:SetColumns(aColumns)

	oBrw1:Activate()
	///oBrw1      := ():New("TMP","OK","", aCpoBro,, GetMark(,"TMP","OK"),{008,020,180,332},,, oDlg1 )
	oGrp1      := TGroup():New( 184,010,260,350,"Data do Fechamento",oDlg1,CLR_BLACK,CLR_WHITE,.T.,.F. )
	oMsCalen1  := MsCalend():New(190, 100, oDlg1, .F.)
	oMsCalen1:dDiaAtu := GetMv("MV_ULMES")
	oSBtn1     := SButton():New( 220,308,1,{||U_JOB()},oDlg1,,"", )
	oSBtn2     := SButton():New( 220,276,2,{||oDlg1:End(), TerminoETL()  },oDlg1,,"", )
	TMP->(DbGoTop())

	oDlg1:Activate(,,,.T.)

	TMP->(DbCloseArea())
	oTempTable:Delete() //Thais Paiva - 04/12/2020
	TEMPO->(DbCloseArea())
	cFilAnt := "01010001"
	RpcClearEnv()
	RestArea(aArea)
Return

User Function JOB()
/*/Função que vai verificar quais filiais foram selecionadas, iniciar o pergunte para definir as datas e executar o fechamento./*/
	Local aArea := GetArea()
	Local lRet := .T.
	Private aParam   := {}
	Private aCodFec  := {}
	Private cDataFC  := " "
	Private aOk      := {}
	Private lRet	 := .T.
	Private lEnd     := .F.

	If Lastday(oMsCalen1:dDiaAtu,0) == oMsCalen1:dDiaAtu
		cDataFC := DtoS(FirstDay(oMsCalen1:dDiaAtu)-1)
		If MsgYesNo( "Confirma o fechamento das filiais selecionadas?", "Confirmar fechamento" )
			TMP->(DbGoTop())
			While !TMP->(Eof())
				If AllTrim(TMP->OK) != ""
					cFilAnt := TMP->P26_FILIAL
					cEmpAnt := "01"
					aParam  := {{cEmpAnt,cFilAnt}}
					PutMv("MV_ULMES",cDataFC)
					PutMv("FS_ULMES",cDataFC)
					StartJob("U_F0703001", GetEnvServer(),.F.,aParam)
				Endif
				TMP->(DbSkip())
			Enddo
			oDlg3      := MSDialog():New( 222,466,346,686,"Fechamento de Estoque",,,.F.,,,,,,.T.,,,.T. )
			oSay3      := TSay():New( 004,008,{||"Fechamento iniciado com sucesso! Consulte o LOG de fechamento para mais informações."},oDlg3,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,088,024)
			oBtn3      := SButton():New( 036,038,1,{||oDlg3:End()},oDlg3,,"", )
			oDlg3:Activate(,,,.T.)
		Endif
	Else
		ShowHelpDlg("Fechamento de Estoque", {"Não é possível realizar o fechamento com a data anterior ao último dia do mês do fechamento. Data Selecionada: " + DtoC(oMsCalen1:dDiaAtu)}, 5, {" "}, 5)
	Endif
	RestArea(aArea)
Return

Static Function InicioETL()
	Local aArea := GetArea()
	Local cDBMS   := GETMV("FS_DBMS")
	Local cBanco  := GETMV("FS_DTBASE")
	Local cServer := GETMV("FS_SERVER")
	Local nPort	  := Val(GETMV("FS_PORT"))
	Local cOwner   := GetMV('FS_OWNER',,'')
	Local cTbl     := "F0703001"
	Private cQuery := ""

	If Empty(cDBMS) .Or. Empty(cBanco) .Or. Empty(cServer) .Or. Empty(nPort)
		cMsgETL := "Parametros de conexao nao preenchidos FS_DBMS|FS_DTBASE|FS_SERVER|FS_PORT"
		Break
	EndIf

	If ValType(oDbApData) == "O" .And. oDbApData:HasConnection()
		cMsgETL := "Conexão com o ApData ja esta Ativa"
		Break
	EndIf

	oDbApData := FWDBAccess():New(cDBMS + "/" + cBanco, cServer, nPort)
	oDbApData:SetConsoleError( .T. )

	If !oDbApData:OpenConnection()
		cMsgETL := "Falha Conexão com a base Externa - Erro: " + AllTrim( oDbApData:ErrorMessage() )
		Break
	Else
		cQuery := ""

		cQuery := " SELECT DISTINCT " 						 + CRLF
		cQuery += " P26_FILIAL " 							 + CRLF
		cQuery += " ,P26_CODFEC " 							 + CRLF
		cQuery += " ,P26_DTFECH " 							 + CRLF
		cQuery += " ,P26_QTDTOT "					 		 + CRLF
		cQuery += " FROM " +cOwner+cTbl 			 	     + CRLF
		cQuery += " WHERE P26_STATUS =  '1'"     			 + CRLF
		cQuery += " ORDER BY P26_DTFECH, P26_QTDTOT"+ CRLF
		cQuery := ChangeQuery(cQuery)
		/*/Criação da tabela temporária com dados da tabela externa para gravar as filiais./*/
		DbUseArea( .T., 'TOPCONN', TCGENQRY(,,cQuery), "TEMPO", .F., .T.)

		If ("TEMPO")->(Eof())
			conout("Não foram encontrados dados para a consulta")			
		EndIf
	EndIf

	RestArea(aArea)
Return

Static Function TerminoETL()

	If ValType(oDbApData) == "O" .And. ! oDbApData:HasConnection()
		cMsgETL := "Conexao com o ApData nao esta Ativa"
		Break
	EndIf
	oDbApData:CloseConnection()
	oDbApData:Finish()
	oDbApData := Nil

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} SetMrkAll
Função para execução do MarkAll da MarkBrowse
/*/
//-------------------------------------------------------------------
Static Function SetMrkAll(oObjTmp As Object,cAliasMrk As Character,cFlag As Character)

cMarca := oObjTmp:cMark

TRX->(dbGotop())

While TRX->(!Eof())
RecLock("TRB",.F.)
If Empty(TRX->&(cFlag))
TRX->&(cFlag) := cMarca
Else
TRX->&(cFlag) := "  "
Endif
MsUnlock()
TRX->(dbSkip())
EndDo

TRX->(dbGotop())

If oObjTmp <> nil
oObjTmp:Refresh()
Endif

Return
