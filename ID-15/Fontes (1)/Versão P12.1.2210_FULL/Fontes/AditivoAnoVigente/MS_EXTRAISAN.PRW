#Include "Protheus.ch"
#INCLUDE "TopConn.ch"
#Include "Totvs.ch"

//-------------------------------------------------------------------
/*/{Protheus.doc} EXTRAISAN()
Automação de cadastros - Gera arquivo do saneamento de cadastros no P12S
@author Lucas Miranda de Aguiar
@since 17/11/2023
@version 1.0
Inicial
@return NIL
/*/
//-------------------------------------------------------------------

User Function EXTRAISAN()

	Local aArea := GetArea()
	Local cWarn := ""
	Local aPergs := {}
	Local nX := 0
	Local aRet := {}
	Private cFilSel := ""
	Private cQry := ""
	Private cTmpTbl := GetNextalias()
	Private oFWMsExcel
	Private oExcel
	Private cArquivo    := " "

	cWarn += '<b>'
	cWarn += '<center><h2><font color="#ff0000">Atenção!</font></h2></center><br>'
	cWarn += "Essa rotina tem o objetivo de gerar o relatório para a realização do saneamento, na próxima tela "
	cWarn += "será apresentada uma box para preencher o código da filial desejada e "
	cWarn += "após a confirmação o processo terá inicio."+CRLF
	cWarn += "O processo pode levar alguns minutos."+CRLF
	cWarn += '<h3><font color="#ff0000">DESEJA CONTINUAR?</font></h3><br>'
	cWarn += '<b>'

	If MsgYesNo(cWarn)

		aAdd( aPergs ,{9,"Saneamento de fornecedores",200, 40,.T.})

		aAdd( aPergs ,{9,"Digite o código da filial do saneamento:",200, 40,.T.})

		aAdd(aPergs,{1,"Código da filial?",Space(8),"","","SM0","",0,.F.})

		If ParamBox(aPergs,"Saneamento de cadastros RDSL",@aRet)
			For nX:=1 To Len(aRet)
				If !Empty(aRet[nX])
					cFilSel := AllTrim(aRet[nX])
				EndIf
			Next nX

			If !FWFilExist("01",cFilSel)
				Alert("A filial informada no parâmetro não existe!" + CRLF + " O processo será abortado.")
				Return
			Else
				MsgRun("Gerando planilha de saneamento...", "Saneamento de fornecedores " + cFilSel, {|| fProcessa() })
			EndIf
		Else
			Alert("Processo abortado.")
			Return
		Endif
	Else
		MsgInfo("Rotina finalizada.")
	EndIf

	RestArea(aArea)
Return

Static Function fProcessa()

	cQry += " SELECT SA2.A2_COD,   "
	cQry += " SA2.A2_LOJA,         "
	cQry += " SA2.A2_NOME,         "
	cQry += " SA2.A2_CGC,          "
	cQry += " SA2.A2_BANCO,        "
	cQry += " SA2.A2_AGENCIA,      "
	cQry += " SA2.A2_NUMCON,       "
	cQry += " CASE WHEN SA2.A2_MSBLQL = '1' THEN 'SIM' ELSE 'NÃO' END AS BLOQUEADO, "
	cQry += " SA2.A2_XCODCOR, SA2.A2_XLOJCOR"
	cQry += " FROM  " + RetSqlName("SA2") +  " SA2 "
	cQry += " WHERE SA2.D_E_L_E_T_ = ' ' "
	cQry += " AND (EXISTS (SELECT * FROM " + RetSqlName("SE2") + " SE2 WHERE  SE2.D_E_L_E_T_ =  ' ' "
	cQry += " AND SE2.E2_FILIAL = '" + cFilSel + "' AND SE2.E2_FORNECE = SA2.A2_COD AND SE2.E2_LOJA = SA2.A2_LOJA) "
	cQry += " OR EXISTS (SELECT * FROM  " + RetSqlName("SE5") + " SE5 WHERE  SE5.D_E_L_E_T_ =  ' ' "
	cQry += " AND SE5.E5_FILIAL = '" + cFilSel + "' AND SE5.E5_CLIFOR = SA2.A2_COD AND SE5.E5_LOJA = SA2.A2_LOJA)) "

	TcQuery cQry Alias ( cTmpTbl ) New

	//Criando o objeto que irá gerar o conteúdo do Excel
	oFWMsExcel := FWMSExcel():New()



	oFWMsExcel:AddworkSheet("Fornecedores P12S")
	oFWMsExcel:AddworkSheet("Forns sem COD P12FULL")
	oFWMsExcel:AddworkSheet("Fornecedores Faltando dados")
	//Criando a Tabelas
	oFWMsExcel:AddTable("Fornecedores P12S","Fornecedores P12S")
	oFWMsExcel:AddTable("Forns sem COD P12FULL","Forns sem COD P12FULL")
	oFWMsExcel:AddTable("Fornecedores Faltando dados","Fornecedores Faltando dados")

	//Criando colunas tabela 1
	oFWMsExcel:AddColumn("Fornecedores P12S","Fornecedores P12S","Código P12S",1)
	oFWMsExcel:AddColumn("Fornecedores P12S","Fornecedores P12S","Loja P12S",1)
	oFWMsExcel:AddColumn("Fornecedores P12S","Fornecedores P12S","Nome",1)
	oFWMsExcel:AddColumn("Fornecedores P12S","Fornecedores P12S","CPF/CNPJ",1)
	oFWMsExcel:AddColumn("Fornecedores P12S","Fornecedores P12S","Cod Banco",1)
	oFWMsExcel:AddColumn("Fornecedores P12S","Fornecedores P12S","Cod Agencia",1)
	oFWMsExcel:AddColumn("Fornecedores P12S","Fornecedores P12S","Cod Conta",1)
	oFWMsExcel:AddColumn("Fornecedores P12S","Fornecedores P12S","Bloqueado P12S?",1)
	oFWMsExcel:AddColumn("Fornecedores P12S","Fornecedores P12S","Código P12FULL",1)
	oFWMsExcel:AddColumn("Fornecedores P12S","Fornecedores P12S","Loja P12FULL",1)

	//Criando colunas tabela 2
	oFWMsExcel:AddColumn("Forns sem COD P12FULL","Forns sem COD P12FULL","Código P12S",1)
	oFWMsExcel:AddColumn("Forns sem COD P12FULL","Forns sem COD P12FULL","Loja P12S",1)
	oFWMsExcel:AddColumn("Forns sem COD P12FULL","Forns sem COD P12FULL","Nome",1)
	oFWMsExcel:AddColumn("Forns sem COD P12FULL","Forns sem COD P12FULL","CPF/CNPJ",1)
	oFWMsExcel:AddColumn("Forns sem COD P12FULL","Forns sem COD P12FULL","Cod Banco",1)
	oFWMsExcel:AddColumn("Forns sem COD P12FULL","Forns sem COD P12FULL","Cod Agencia",1)
	oFWMsExcel:AddColumn("Forns sem COD P12FULL","Forns sem COD P12FULL","Cod Conta",1)
	oFWMsExcel:AddColumn("Forns sem COD P12FULL","Forns sem COD P12FULL","Bloqueado P12S?",1)

	//Criando colunas tabela 3
	oFWMsExcel:AddColumn("Fornecedores Faltando dados","Fornecedores Faltando dados","Código P12S",1)
	oFWMsExcel:AddColumn("Fornecedores Faltando dados","Fornecedores Faltando dados","Loja P12S",1)
	oFWMsExcel:AddColumn("Fornecedores Faltando dados","Fornecedores Faltando dados","Nome",1)
	oFWMsExcel:AddColumn("Fornecedores Faltando dados","Fornecedores Faltando dados","CPF/CNPJ",1)
	oFWMsExcel:AddColumn("Fornecedores Faltando dados","Fornecedores Faltando dados","Cod Banco",1)
	oFWMsExcel:AddColumn("Fornecedores Faltando dados","Fornecedores Faltando dados","Cod Agencia",1)
	oFWMsExcel:AddColumn("Fornecedores Faltando dados","Fornecedores Faltando dados","Cod Conta",1)
	oFWMsExcel:AddColumn("Fornecedores Faltando dados","Fornecedores Faltando dados","Bloqueado P12S?",1)
	oFWMsExcel:AddColumn("Fornecedores Faltando dados","Fornecedores Faltando dados","Código P12FULL",1)
	oFWMsExcel:AddColumn("Fornecedores Faltando dados","Fornecedores Faltando dados","Loja P12FULL",1)

	(cTmpTbl)->(DbGoTop())

	While !( cTmpTbl )->( Eof() )
		oFWMsExcel:AddRow("Fornecedores P12S","Fornecedores P12S",{;
			(cTmpTbl)->A2_COD,;
			(cTmpTbl)->A2_LOJA,;
			(cTmpTbl)->A2_NOME,;
			(cTmpTbl)->A2_CGC,;
			(cTmpTbl)->A2_BANCO,;
			(cTmpTbl)->A2_AGENCIA,;
			(cTmpTbl)->A2_NUMCON,;
			(cTmpTbl)->BLOQUEADO,;
			(cTmpTbl)->A2_XCODCOR,;
			(cTmpTbl)->A2_XLOJCOR;
			})

		(cTmpTbl)->(DbSkip())
	EndDo

	(cTmpTbl)->(DBCLOSEAREA())

	cQry := " SELECT SA2.A2_COD,   "
	cQry += " SA2.A2_LOJA,         "
	cQry += " SA2.A2_NOME,         "
	cQry += " SA2.A2_CGC,          "
	cQry += " SA2.A2_BANCO,        "
	cQry += " SA2.A2_AGENCIA,      "
	cQry += " SA2.A2_NUMCON,       "
	cQry += " CASE WHEN SA2.A2_MSBLQL = '1' THEN 'SIM' ELSE 'NÃO' END AS BLOQUEADO "
	cQry += " FROM  " + RetSqlName("SA2") +  " SA2 "
	cQry += " WHERE SA2.D_E_L_E_T_ = ' ' AND A2_XCODCOR = ' '"
	cQry += " AND (EXISTS (SELECT * FROM " + RetSqlName("SE2") + " SE2 WHERE  SE2.D_E_L_E_T_ =  ' ' "
	cQry += " AND SE2.E2_FILIAL = '" + cFilSel + "' AND SE2.E2_FORNECE = SA2.A2_COD AND SE2.E2_LOJA = SA2.A2_LOJA) "
	cQry += " OR EXISTS (SELECT * FROM  " + RetSqlName("SE5") + " SE5 WHERE  SE5.D_E_L_E_T_ =  ' ' "
	cQry += " AND SE5.E5_FILIAL = '" + cFilSel + "' AND SE5.E5_CLIFOR = SA2.A2_COD AND SE5.E5_LOJA = SA2.A2_LOJA)) "

	TcQuery cQry Alias ( cTmpTbl ) New

	(cTmpTbl)->(DbGoTop())

	While !( cTmpTbl )->( Eof() )
		oFWMsExcel:AddRow("Forns sem COD P12FULL","Forns sem COD P12FULL",{;
			(cTmpTbl)->A2_COD,;
			(cTmpTbl)->A2_LOJA,;
			(cTmpTbl)->A2_NOME,;
			(cTmpTbl)->A2_CGC,;
			(cTmpTbl)->A2_BANCO,;
			(cTmpTbl)->A2_AGENCIA,;
			(cTmpTbl)->A2_NUMCON,;
			(cTmpTbl)->BLOQUEADO;
			})

		(cTmpTbl)->(DbSkip())
	EndDo

	(cTmpTbl)->(DBCLOSEAREA())

	cQry := " SELECT SA2.A2_COD,   "
	cQry += " SA2.A2_LOJA,         "
	cQry += " SA2.A2_NOME,         "
	cQry += " SA2.A2_CGC,          "
	cQry += " SA2.A2_BANCO,        "
	cQry += " SA2.A2_AGENCIA,      "
	cQry += " SA2.A2_NUMCON,       "
	cQry += " CASE WHEN SA2.A2_MSBLQL = '1' THEN 'SIM' ELSE 'NÃO' END AS BLOQUEADO, "
	cQry += " SA2.A2_XCODCOR, SA2.A2_XLOJCOR"
	cQry += " FROM  " + RetSqlName("SA2") +  " SA2 "
	cQry += " WHERE SA2.D_E_L_E_T_ = ' ' "
	cQry += " AND (SA2.A2_BANCO = ' ' OR SA2.A2_AGENCIA = ' ' OR SA2.A2_NUMCON = ' ' OR SA2.A2_CGC = ' ') "
	cQry += " AND (EXISTS (SELECT * FROM " + RetSqlName("SE2") + " SE2 WHERE  SE2.D_E_L_E_T_ =  ' ' "
	cQry += " AND SE2.E2_FILIAL = '" + cFilSel + "' AND SE2.E2_FORNECE = SA2.A2_COD AND SE2.E2_LOJA = SA2.A2_LOJA) "
	cQry += " OR EXISTS (SELECT * FROM  " + RetSqlName("SE5") + " SE5 WHERE  SE5.D_E_L_E_T_ =  ' ' "
	cQry += " AND SE5.E5_FILIAL = '" + cFilSel + "' AND SE5.E5_CLIFOR = SA2.A2_COD AND SE5.E5_LOJA = SA2.A2_LOJA)) "

	TcQuery cQry Alias ( cTmpTbl ) New

	(cTmpTbl)->(DbGoTop())

	While !( cTmpTbl )->( Eof() )
		oFWMsExcel:AddRow("Fornecedores Faltando dados","Fornecedores Faltando dados",{;
			(cTmpTbl)->A2_COD,;
			(cTmpTbl)->A2_LOJA,;
			(cTmpTbl)->A2_NOME,;
			(cTmpTbl)->A2_CGC,;
			(cTmpTbl)->A2_BANCO,;
			(cTmpTbl)->A2_AGENCIA,;
			(cTmpTbl)->A2_NUMCON,;
			(cTmpTbl)->BLOQUEADO,;
			(cTmpTbl)->A2_XCODCOR,;
			(cTmpTbl)->A2_XLOJCOR;
			})

		(cTmpTbl)->(DbSkip())
	EndDo

	(cTmpTbl)->(DBCLOSEAREA())


	//Ativando o arquivo e gerando o xml
	cArquivo    := GetTempPath()+'SANEAMENTO_' + cFilSel + '.xml'

	oFWMsExcel:Activate()
	oFWMsExcel:GetXMLFile(cArquivo)

	//Abrindo o excel e abrindo o arquivo xml
	oExcel := MsExcel():New()             //Abre uma nova conexão com Excel
	oExcel:WorkBooks:Open(cArquivo)     //Abre uma planilha
	oExcel:SetVisible(.T.)                 //Visualiza a planilha
	oExcel:Destroy()                        //Encerra o processo do gerenciador de tarefas


Return
