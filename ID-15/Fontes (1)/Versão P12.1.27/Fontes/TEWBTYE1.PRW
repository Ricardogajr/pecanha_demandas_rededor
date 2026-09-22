#Include 'Protheus.ch'
#INCLUDE "FONT.CH"
#INCLUDE "FILEIO.CH"
/*
{Protheus.doc} TEWBTYE1
Exportação de Lançamentos Contábeis via arquivo auxiliar 
@Author     Ramon Teodoro e Silva
@Since      10/10/2016     
@Version    P12.7
@Return
*/

User Function TEWBTYE1()

	Local lRet     := .T.
	Local aArea    := GetArea()
	Local aSays    := {}
	Local aButtons := {}
	Local nOpca    := 0 

	Private cPerg := "TEWBTYE1"
	Private cFilP10 := ""
	Private cFilP12 := ""
	Private cCCP10  := ""
	Private cCCP12  := ""

	Pergunte(cPerg, .F.)

	AADD(aSays, "Esta rotina faz a integração dos Lançamentos Contábeis entre as ")
	AADD(aSays, "versões 12 e 10 do Protheus via arquivo CSV. Informe os dados " )
	AADD(aSays, "necessários e o diretótio onde o arquivo será gerado." )

	AADD(aButtons, { 1,.T.,{|o| nOpca:= 1,o:oWnd:End()}} )
	AADD(aButtons, { 2,.T.,{|o| o:oWnd:End() }} )
	AADD(aButtons, { 5,.T.,{|| Pergunte(cPerg, .T. ) } } )

	FormBatch( "Exportação CT2", aSays, aButtons )

	If nOpca == 1
		//MsAguarde({||U_ExpCT2()},"Aguarde","Gerando Arquivo de Exportação...",.T.)
		Processa({||U_ExpCT2()}, "Processando...")
	EndIf

	RestArea(aArea)

Return lRet

/*
{Protheus.doc} TEWBTYE1
Processa a montagem do TXT
@Author     Ramon Teodoro e Silva
@Since      10/10/2016     
@Version    P12.7
@Return
*/
User Function ExpCT2

	Local lRet     := .T.
	Local aArea    := GetArea()
	Local cQuery   := ""
	Local cDiret   := Alltrim(mv_par07) + "\"
	Local cArquivo := "CT2P12-"+CriaTrab(,.F.)
	Local cFilCT2  := ""
	Local cTpLcto  := ""
	Local cCust10D := ""
	Local cCust10C := ""
	Local cArqTrb1 := CriaTrab(NIL,.F.)
	Local aStru    := {}
	Local aHeader  := {}
	Local oExcelApp
	Local nHandle
	Local cCrLf 	:= Chr(13) + Chr(10)
	Local nX
	Local cPath		:= AllTrim(GetTempPath())
	Local _uValor   := ""
	Local cFilNDel  := Alltrim(SuperGetMV( "FS_FILNDEL",.F.,.F.))
	Local nRegs     := 0
	Local nTotRec   := 0
	Local _aCmpCT2	:= {} //Thais Paiva - Compatibilização P27

//mv_par01 - Filial De
//mv_par02 - Filail Ate
//mv_par03 - Dt Lancto De
//mv_par04 - Dt Lancto Ate
//mv_par05 - Lote De
//mv_par06 - Lote Ate
//mv_par07 - Diretorio Arq. Saida

//Início - Thais Paiva - Compatibilização P27
//DbSelectArea("SX3")
//SX3->(DbSetOrder(1))
//SX3->(DbSeek("CT2"))

	_aCmpCT2 := FWSX3Util():GetAllFields( "CT2" , .F. )

//While SX3->(!Eof()) .And. (SX3->X3_ARQUIVO == "CT2")
	For _nCt := 1 to Len(_aCmpCT2)

		//If (X3USO(SX3->X3_USADO) .Or. Alltrim(SX3->X3_CAMPO) $ "CT2_FILIAL|CT2_LINHA") .And. cNivel >= SX3->X3_NIVEL .And. Alltrim(SX3->X3_CONTEXT) <> "V"
		If (X3USO(GetSx3Cache(_aCmpCT2[_nCt], 'X3_USADO')) .Or. Alltrim(GetSx3Cache(_aCmpCT2[_nCt], 'X3_CAMPO')) $ "CT2_FILIAL|CT2_LINHA") .And. cNivel >= GetSx3Cache(_aCmpCT2[_nCt], 'X3_NIVEL')
			//If cNivel >= SX3->X3_NIVEL .And. Alltrim(SX3->X3_CONTEXT) <> "V" .And. !(Alltrim(SX3->X3_CAMPO) $ "CT2_USERGI|CT2_USERGA|CT2_AT01DB")
			//aAdd(aHeader, {Alltrim(SX3->X3_TITULO), SX3->X3_CAMPO, SX3->X3_PICTURE,	SX3->X3_TAMANHO, SX3->X3_DECIMAL,"ALLWAYSTRUE()", SX3->X3_USADO, SX3->X3_TIPO, SX3->X3_F3, SX3->X3_CONTEXT})
			aAdd(aHeader, {Alltrim(GetSx3Cache(_aCmpCT2[_nCt], 'X3_TITULO')), GetSx3Cache(_aCmpCT2[_nCt], 'X3_CAMPO'), ;
				GetSx3Cache(_aCmpCT2[_nCt], 'X3_PICTURE'), GetSx3Cache(_aCmpCT2[_nCt], 'X3_TAMANHO'), ;
				GetSx3Cache(_aCmpCT2[_nCt], 'X3_DECIMAL'),"ALLWAYSTRUE()", GetSx3Cache(_aCmpCT2[_nCt], 'X3_USADO'), ;
				GetSx3Cache(_aCmpCT2[_nCt], 'X3_TIPO'), GetSx3Cache(_aCmpCT2[_nCt], 'X3_F3'), ;
				GetSx3Cache(_aCmpCT2[_nCt], 'X3_CONTEXT')})
		EndIf
		//SX3->(DbSkip())
//End
	Next _nCt
//Fim - Thais Paiva - Compatibilização P27

	DbSelectArea("CT2")
	DbSetOrder(1)

	cQuery := " SELECT * FROM " + RetSqlName("CT2") + " WHERE "
	cQuery += " CT2_FILIAL BETWEEN '" + mv_par01 + "' AND '" + mv_par02 + "' AND "
	cQuery += " CT2_DATA BETWEEN '" + DtoS(mv_par03) + "' AND '" + DtoS(mv_par04) + "' AND "
	cQuery += " CT2_LOTE BETWEEN '" + mv_par05 + "' AND '" + mv_par06 + "' AND "
	cQuery += " D_E_L_E_T_ = ' '"
	cQuery += " ORDER BY CT2_FILIAL"

	//cQuery := ChangeQuery(cQuery)

	DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TMPCT2",.T.,.T.)

	If !ExistDir(cDiret) .And. !TMPCT2->(Eof())
		MakeDir(cDiret)
	EndIf

	If TMPCT2->(Eof())
		MsgAlert("Não foram encontrados registros para os parâmetros solicitados.")
		TMPCT2->(DbCloseArea())
		Return .F.
	EndIf

//	nHandle := MsfCreate(cDiret+""+cArquivo+".CSV",0)
	nHandle := fcreate(cDiret+""+cArquivo+".CSV", 0)

	If nHandle > 0

		aEval(aHeader, {|e, nX| fWrite(nHandle, e[2] + If(nX < Len(aHeader), ";", "") ) } )
		fWrite(nHandle, cCrLf ) // Pula linha

		Count To nTotRec
		ProcRegua(nTotRec)
		TMPCT2->(DbGoTop())

		While !TMPCT2->(Eof())
			lFazDePara := .T.
			if P33->(DbSeek(xFilial("P33")+TMPCT2->CT2_FILIAL))
				if P33->P33_STATUS == "1"
					lFazDePara := .F.
				endif
			endif
			nRegs += 1

			IncProc( "Exportando Registros... " + AllTrim( Str( nRegs ) ) + " de " + AllTrim( Str( ntotrec ) ) )

			For nE := 1 to len(aHeader)

				uConteudo := &("TMPCT2->" + aHeader[nE,2])

				If aHeader[nE,8] == "D" // Trata campos data
					_uValor := _uValor + uConteudo //+ ";" //&("TMPCT2->" + aHeader[nE,2])
				ElseIf aHeader[nE,8] == "N" // Trata campos numericos
					_uValor := _uValor + Transform(uConteudo,aHeader[nE,3]) //+ ";"
				Elseif aHeader[nE,8] == "C" // Trata campos caracter

					If Alltrim(aHeader[nE,2]) == "CT2_FILIAL"
						If !Empty(uConteudo)
							//_uValor := _uValor + TMPCT2->FILP10 //+ ";"
							if lFazDePara
								_uValor := _uValor + U_DP10("CT2_FILIAL", uConteudo)
							else
								_uValor := _uValor + uConteudo
							endif
						EndIf
					ElseIf Alltrim(aHeader[nE,2]) == "CT2_CCD"
						If !Empty(uConteudo)
							//_uValor := _uValor + TMPCT2->CCP10 //+ ";"
							if lFazDePara
								_uValor := _uValor + U_DP10("CT2_CCD", uConteudo)
							else
								_uValor := _uValor + uConteudo
							endif
						EndIf
					ElseIf Alltrim(aHeader[nE,2]) == "CT2_CCC"
						If !Empty(uConteudo)
							//_uValor := _uValor + TMPCT2->CCP10 //+ ";"
							if lFazDePara
								_uValor := _uValor + U_DP10("CT2_CCC", uConteudo)
							else
								_uValor := _uValor + uConteudo
							endif
						EndIf
					ElseIf Alltrim(aHeader[nE,2]) $ "CT2_ITEMD|CT2_ITEMC|CT2_CLVLDB|CT2_CLVLCR"
						_uValor := _uValor + " " //+ ";"
					Else
						_uValor := _uValor + &("TMPCT2->" + aHeader[nE,2]) //+ ";"
					EndIf

				EndIf
				If nE <> Len(aHeader)
					_uValor := _uValor + ";"
					_uValorBkp := _uValor
				Else
					_uValor := _uValorBkp
				EndIf

				//If nE <> Len(aHeader)
				//	fWrite(nHandle, _uValor + ";" )
				//EndIf

			Next nE

			fWrite(nHandle, _uValor )
			fWrite(nHandle, cCrLf )
			_uValor := ""

			TMPCT2->(DbSkip())

		End

		fClose(nHandle)
		//CpyS2T( cDiret+""+cArquivo+".CSV" , cPath, .T. )

		If ! ApOleClient( 'MsExcel' )
			MsgAlert( 'MsExcel nao instalado')
			Return .f.
		EndIf

		TMPCT2->(DbGoTop())
		While !TMPCT2->(Eof())

			If !(TMPCT2->CT2_FILIAL $ cFilNDel)

				If CT2->(DbSeek(TMPCT2->(CT2_FILIAL + CT2_DATA + CT2_LOTE + CT2_SBLOTE + CT2_DOC + CT2_LINHA + CT2_TPSALD + CT2_EMPORI + CT2_FILORI + CT2_MOEDLC )))

					IncProc( "Apagando dados para a filial " + AllTrim( TMPCT2->(CT2_FILIAL) ) )
					Reclock("CT2", .F., .T. )
					CT2->( DbDelete() )
					MsUnlock()

				EndIf

			EndIf


			TMPCT2->(DbSkip())

		End

		//oExcelApp := MsExcel():New()
		//oExcelApp:WorkBooks:Open( cPath+cArquivo+".CSV" ) // Abre uma planilha
		//oExcelApp:SetVisible(.T.)
	Else
		MsgAlert("Falha na criação do arquivo")
	Endif

	If nRegs > 0
		MsgAlert("Exportação realizada com sucesso.")
	EndIf

	TMPCT2->(DbCloseArea())

	RestArea(aArea)
Return lRet


/*
{Protheus.doc} DeParaFil
Cadastro para relacionar as empresas e filiais da versão 12 com a 10.
@Author     Ramon Teodoro e Silva
@Since      10/10/2016     
@Version    P12.7
@Return
*/
User Function DeParaFil()

	Local cVldAlt := ".T." // Validacao para permitir a alteracao. Pode-se utilizar ExecBlock.
	Local cVldExc := ".T." // Validacao para permitir a exclusao. Pode-se utilizar ExecBlock.

	Private cString := "PZB"

	DbSelectArea("PZB")
	DbSetOrder(1)

	AxCadastro(cString,"Depara Filial P12 x Filial P10",cVldExc,cVldAlt)

Return

/*
{Protheus.doc} DeParaCC
Cadastro para relacionar as empresas centros de custo da versão 12 com a 10.
@Author     Ramon Teodoro e Silva
@Since      10/10/2016     
@Version    P12.7
@Return
*/
User Function DeParaCC()

	Local cVldAlt := ".T." // Validacao para permitir a alteracao. Pode-se utilizar ExecBlock.
	Local cVldExc := ".T." // Validacao para permitir a exclusao. Pode-se utilizar ExecBlock.

	Private cString := "SZY"

	DbSelectArea("SZY")
	DbSetOrder(1)

	AxCadastro(cString,"Depara Centro de Custo P12 x Centro de Custo P10",cVldExc,cVldAlt)

Return

/*
{Protheus.doc} DP10
Função para buscar os códigos P12 X P10 de filial e centro de custo.
@Author     Ramon Teodoro e Silva
@Since      25/10/2016     
@Version    P12.7
@Return
*/
User Function DP10(cCampo, cValor)

	Local cRet  := ""
	Local aArea := GetArea()

	If cCampo == "CT2_FILIAL"

		If cFilP12 <> cValor
			DbSelectArea("PZB")
			DbSetOrder(1)

			If PZB->(DbSeek(cValor))
				cRet := PZB_CFIL10
				cFilP10 := PZB_CFIL10
				cFilP12 := cValor
			Else
				MsgAlert("Filial não encontrada no depara de Filiais P12 X P10 - " + cValor)
			EndIf
		Else
			cRet := cFilP10
		EndIf
	ElseIf cCampo $ "CT2_CCD|CT2_CCC"

		DbSelectArea("SZY")
		DbSetOrder(2)

		If cCCP12 <> cValor
			If SZY->(DbSeek(cValor))
				cRet := ZY_CCP10
				cCCP10 := ZY_CCP10
				cCCP12 := cValor
			Else
				MsgAlert("Centro de Custo não encontrado no depara de Centro de Custo P12 X P10 - " + cValor)
			EndIf
		Else
			cRet := cCCP10
		EndIf
	EndIf

	RestArea(aArea)

Return cRet




