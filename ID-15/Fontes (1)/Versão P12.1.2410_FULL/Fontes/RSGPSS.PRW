#Include "PROTHEUS.Ch"
#Include "TopConn.ch"


User Function RSGPSS()

	Local aArea := GetArea()
	Private cArqTrb
	Private cIndice1, cIndice2, cIndice3,cIndice4 := ""

	If Pergunte("XRSGPSS", .T.)

		If MV_PAR05 == 1
			If Empty(AllTrim(MV_PAR02))
				Alert("O preenchimento do código de usuário é obrigatório para o relatório usuário X Grupo!")
				Return
			EndIf
		EndIf
		If MV_PAR05 == 1
			cRel := "usuário X grupo"
		ElseIf MV_PAR05 == 2
			cRel := "grupo X XNU"
		EndIf

		MsgRun("Relatório de " + cRel,"Processando",{|| fFunctions() })
	EndIf
	RestArea(aArea)
Return

Static Function fFunctions()

	Local aArea := GetArea()

	fCriaTrab() //Função para pegar a listagem de usuários e criar uma tabela temporária com os códigos
	fRecLock()  //Função para gravar os dados na tabela
	fCriaExl() //Função para gerar o relatório
	fExclTrb() //Função para excluir a tabela temporária

	RestArea(aArea)
Return

Static Function fCriaTrab()

	Local aArea := GetArea()
	Local aAuxUsr := {}
	Local aCampos := {}

	AAdd(aCampos,{"TR_INFO"        	,"C",020						,0})
	AAdd(aCampos,{"TR_GRUPO"        ,"C",100						,0})

	If (Select("TRB") <> 0)
		dbSelectArea("TRB")
		TRB->(dbCloseArea ())
	Endif
	//A Função CriaTrab() retorna o nome de um arquivo de trabalho que ainda nÃ£o existe e dependendo dos parÃ¢metros passados, pode criar um novo arquivo de trabalho.
	//Se indice existir excluir
	//A Função dbUseArea abre uma tabela de dados na Ã¡rea de trabalho atual ou na primeira Ã¡rea de trabalho disponÃ­vel

	oTempTable := FWTemporaryTable():New( "TRB" )
	oTemptable:SetFields( aCampos )
	oTempTable:Create()
	RestArea(aArea)

Return

Static Function fRecLock()

	Local aArea := GetArea()
	Local aAuxUsr := {}
	Local aAllGrp := {}
	Local nX := 1
	Local cQuery := ""
	Local cAliasUsr := GetNextAlias()

	DbSelectArea("TRB")

	If MV_PAR05 == 1 //Caso seja relatório pelo usuário
		//aAuxUsr := FwSFAllUsers(, {"USR_CODIGO"}) 					 //-- Obter todos os logins de usuário (USR_CODIGO) do arquivo de usuários

		cQuery := "SELECT USR_ID, USR_NOME FROM SYS_USR WHERE D_E_L_E_T_ = ' ' AND USR_ID BETWEEN '"+MV_PAR01+"' "
		cQuery += " AND '"+MV_PAR02+"' "

		DbUseArea(.T., "TOPCONN", TcGenQry(, , cQuery), cAliasUsr, .T., .T.)


		While (cAliasUsr)->(!EOF())

			//If (aAuxUsr[nX][2] >= AllTrim(MV_PAR01) .And. aAuxUsr[nX][2] <= AllTrim(MV_PAR02))
			RecLock("TRB",.T.)
			TRB->TR_INFO  := (cAliasUsr)->USR_ID
			TRB->TR_GRUPO := (cAliasUsr)->USR_NOME
			MsUnlock()
			//Else
			//		If aAuxUsr[nX][2] > AllTrim(MV_PAR02)
			//			Exit
			//		EndIf
			//	EndIf

			(cAliasUsr)->(DbSkip())
		EndDo
	ElseIf MV_PAR05 == 2//Caso seja relatório XNU
		aAllGrp := FWSFallGrps()

		For nX := 01 To Len(aAllGrp)
			If aAllGrp[nX][2] >= AllTrim(MV_PAR03) .And. aAllGrp[nX][2] <= AllTrim(MV_PAR04)
				RecLock("TRB",.T.)
				TRB->TR_INFO := AllTrim(aAllGrp[nX][3])
				TRB->TR_GRUPO := AllTrim(aAllGrp[nX][2])
				MsUnlock()
			EndIf
		Next nX
	EndIf
	RestArea(aArea)
Return

Static Function fCriaExl()

	Local aArea := GetArea()
	Local oFWExcel
	Local oExcel
	Local cArquivo    := GetTempPath()+'Relatorio_grupo_usuarios.xml'
	Local aGrupos := {}
	Local cAliasTRB := 'TRB'
	Local nX := 1
	Local nY := 1
	Local cGrupos := ""
	Local aGrpSep := {}
	Local cGrpSep := ""
	Local cBloq := ""
	Local aChave := {}
	Local cFilAcesso := ""
	Local cDbase := ""
	Local nFiliais := 0

//Criando o objeto que irÃ¡ gerar o conteÃºdo do Excel
	oFWExcel := FWMsExcel():New()
	//oFWExcel:SetUTF8Encode(.F.)

	If MV_PAR05 == 1
		//Criando a Tabela
		oFWExcel:AddworkSheet("Rel UsrXGrp")
		//Criando a Tabela
		oFWExcel:AddTable("Rel UsrXGrp" ,"UsrXGrp")
		oFWExcel:AddColumn("Rel UsrXGrp","UsrXGrp","Código do usuário",1)
		oFWExcel:AddColumn("Rel UsrXGrp","UsrXGrp","Login",1)
		oFWExcel:AddColumn("Rel UsrXGrp","UsrXGrp","Nome do usuário",1)
		oFWExcel:AddColumn("Rel UsrXGrp","UsrXGrp","Bloqueado?",1)
		oFWExcel:AddColumn("Rel UsrXGrp","UsrXGrp","Data De Inclusão",1)
		oFWExcel:AddColumn("Rel UsrXGrp","UsrXGrp","Data Da Ultima Alteração",1)
		oFWExcel:AddColumn("Rel UsrXGrp","UsrXGrp","Data de validade",1)
		oFWExcel:AddColumn("Rel UsrXGrp","UsrXGrp","Dias para expirar senha",1)
		oFWExcel:AddColumn("Rel UsrXGrp","UsrXGrp","Superior",1)
		oFWExcel:AddColumn("Rel UsrXGrp","UsrXGrp","Departamento",1)
		oFWExcel:AddColumn("Rel UsrXGrp","UsrXGrp","Cargo",1)
		oFWExcel:AddColumn("Rel UsrXGrp","UsrXGrp","Email",1)
		oFWExcel:AddColumn("Rel UsrXGrp","UsrXGrp","Número de acessos simultâneos",1)
		oFWExcel:AddColumn("Rel UsrXGrp","UsrXGrp","Filial",1)
		oFWExcel:AddColumn("Rel UsrXGrp","UsrXGrp","Empresa,Filial e Matrícula",1)
		oFWExcel:AddColumn("Rel UsrXGrp","UsrXGrp","Altera database?",1)
		oFWExcel:AddColumn("Rel UsrXGrp","UsrXGrp","Dias a retroceder",1)
		oFWExcel:AddColumn("Rel UsrXGrp","UsrXGrp","Dias a avançar",1)
		oFWExcel:AddColumn("Rel UsrXGrp","UsrXGrp","Data Ultimo Acesso",1)
		oFWExcel:AddColumn("Rel UsrXGrp","UsrXGrp","Grupos",1)

		//Colocar informações do sistema
		//Criando as Linhas... Enquanto nÃ£o for fim da query
		DbSelectArea("TRB")
		TRB->(dbGoTop())
		While  !TRB->( Eof() )
			Conout((cAliasTRB)->(Recno() ) )
			If TRB->(Recno() ) == 104
				nX := 01
			EndIf
			aGrupos := UsrRetGrp(PswChave(AllTrim(TRB->TR_INFO)),AllTrim(TRB->TR_INFO))
			cGrupos := ""
			For nX := 01 To Len(aGrupos)
				If nX == 01
					cGrupos := cGrupos + aGrupos[nX]
				Else
					cGrupos := cGrupos + " | " + aGrupos[nX]
				EndIf

			Next nX

			If Empty(AllTrim(cGrupos))
				cGrupos := "Usuário sem grupo."
			EndIf

			PswOrder(1)
			PswSeek(TRB->TR_INFO,.T.)

			aChave := PswRet()
			If aChave[1][17] == .T.
				cBloq := "S"
			Else
				cBloq := "N"
			EndIf

			If aChave[1][23][1] == .T.
				cDbase := "S"
			Else
				cDbase := "N"
			EndIf

			cFilAcesso := ""

			For nX := 1 To Len(aChave[2][6])
				If Len(aChave[2][6]) > 15
					cFilAcesso := "Acesso a todas empresas/filiais"
					Exit
				EndIf
				If achave[2][6][nX] == "@@@@"
					cFilAcesso := "Acesso a todas empresas/filiais"
					Exit
				EndIF
				cFilAcesso := cFilAcesso + achave[2][6][nX] + "|"
			Next nX

			If Year(aChave[1][24]) < 1900 .And. Year(aChave[1][24]) > 0
				aChave[1][24] := "Ano inválido(verificar no cadastro do usuário)"
			EndIf
			If Year(aChave[1][16]) < 1900 .And. Year(aChave[1][16]) > 0
				aChave[1][16] := "Ano inválido(verificar no cadastro do usuário)"
			EndIf
			If Year(aChave[1][6]) < 1900 .And. Year(aChave[1][6]) > 0
				aChave[1][6] := "Ano inválido(verificar no cadastro do usuário)"
			EndIf
			oFWExcel:AddRow("Rel UsrXGrp" ,"UsrXGrp",{;
				AllTrim(TRB->TR_INFO),;//Cod usuario
			aChave[1][2],;//Login
			AllTrim(TRB->TR_GRUPO),;//Nome
			cBloq,;//Bloqueado
			aChave[1][24],;//Data de inclusão no sistema
			aChave[1][16],;//Data da ultima alteração
			aChave[1][6],;//Data de validade
			aChave[1][7],;//Dias para expirar senha
			DecodeUtf8(aChave[1][11]),;//Superior
			DecodeUtf8(aChave[1][12]),;//Departamento
			DecodeUtf8(aChave[1][13]),;//Cargo
			DecodeUtf8(aChave[1][14]),;//Email
			aChave[1][15],;//Número de acessos simultâneos
			cFilAcesso,;//Filial
			aChave[1][22],;//Empresa filial e matricula
			cDbase,;//Altera database?
			aChave[1][23][2],;//Dias a retroceder
			aChave[1][23][3],;//Dias a avançar
			Dtoc(FWUsrUltLog(AllTrim(TRB->TR_INFO))[1]) + " " + FWUsrUltLog(AllTrim(TRB->TR_INFO))[2],;//Ultimo acesso
			cGrupos;//Grupos
			})
			(cAliasTRB)->( DbSkip() )
		EndDo
	ElseIf MV_PAR05 == 2
		//Criando a Tabela
		oFWExcel:AddworkSheet("Rel GrpxXNU")
		//Criando a Tabela
		oFWExcel:AddTable("Rel GrpxXNU" ,"GrpxXNU")
		oFWExcel:AddColumn("Rel GrpxXNU","GrpxXNU","Código do Grupo",1)
		oFWExcel:AddColumn("Rel GrpxXNU","GrpxXNU","Nome do Grupo",1)
		oFWExcel:AddColumn("Rel GrpxXNU","GrpxXNU","Filiais vinculadas")
		oFWExcel:AddColumn("Rel GrpxXNU","GrpxXNU","XNUS",1)
		//Criando as Linhas... Enquanto nÃ£o for fim da query

		nFiliais := Len(FWAllFilial(cEmpAnt,,,.F.))
		DbSelectArea("TRB")
		(cAliasTRB)->(dbGoTop())
		While  !(cAliasTRB)->( Eof() )
			aGrupos := FWGrpMenu(TRB->TR_INFO)
			cGrupos := ""

			For nX := 01 To Len(aGrupos)

			/*/Caso queria tirar o caminho completo e deixar só o nome do XNU 
				é só descomentar esse bloco abaixo.
			e colocar a variavel cgrpSep no lugar do agrupox[nX] onde o cgrupos recebe conteudo/*/

			/*/aGrpSep := StrTokArr(aGrupos[nX],"\")

				For nY := 01 To Len(aGrpSep)
					If "XNU" $ Upper(aGrpSep[nY])
						cGrpSep := aGrpSep[nY]
					EndIf
			Next nY/*/
					If SubStr(aGrupos[nX], 3, 1) == "X" .And. Len(aGrupos[nX]) > 3
						If nX == 01
							cGrupos := cGrupos + Right(aGrupos[nX],Len(aGrupos[nX])-3)
						Else
							cGrupos := cGrupos + " | " + Right(aGrupos[nX],Len(aGrupos[nX])-3)
						EndIf
					ElseIf SubStr(aGrupos[nX], 3, 1) <> "X"
						If nX == 01
							cGrupos := cGrupos + aGrupos[nX]
						Else
							cGrupos := cGrupos + " | " + aGrupos[nX]
						EndIf
					EndIf
				Next nX

				aChave := FWGrpEmp(TRB->TR_GRUPO)
				cFilAcesso := ""
				For nX := 1 To Len(aChave)

					If Len(aChave) >= nFiliais
						cFilAcesso := "Acesso a todas as filiais da empresa logada"
						Exit
					EndIF
					cFilAcesso := cFilAcesso + Substr(aChave[nX],3,10) + "|"
				Next nX
				oFWExcel:AddRow("Rel GrpxXNU" ,"GrpxXNU",{;
					AllTrim(TRB->TR_INFO),;
					AllTrim(TRB->TR_GRUPO),;
					AllTrim(cFilAcesso),;
					cGrupos;
					})
				(cAliasTRB)->( DbSkip() )
			EndDo
		EndIf

		//Ativando o arquivo e gerando o xml
		oFWExcel:Activate()
		oFWExcel:GetXMLFile(cArquivo)

		//Abrindo o excel e abrindo o arquivo xml
		oExcel := MsExcel():New()             //Abre uma nova conexÃ£o com Excel
		oExcel:WorkBooks:Open(cArquivo)     //Abre uma planilha
		oExcel:SetVisible(.T.)                 //Visualiza a planilha
		oExcel:Destroy()                        //Encerra o processo do gerenciador de tarefas

		RestArea(aArea)
		Return

Static Function fExclTRB()

	TRB->(DbCloseArea())

Return
Static Function NameFull(cParam1)
Return UsrFullName(cParam1)
