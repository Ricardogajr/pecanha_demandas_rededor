#include "totvs.ch"
#include "protheus.ch"
#include "topconn.ch"  
#DEFINE  cEol         CHR(13)+CHR(10)

/*/{Protheus.doc} F1300501
Rotina de Importação Salarial
@author queizy.nascimento
@since 27/10/2017
@version 1.0
@return ${return}, ${return_description}
@project MAN0000007423048_EF_005
@type function
/*/
User Function F1300501()

	Local cLinha := ""
	Local lRet:= .T.
	Local lPrim := .F.
	Local aDados := {}
	Local cText := OemToAnsi("Selecione o Arquivo de Importação:")
	Local cFile := ""
	Local nCount := 1
	Local aRB6:={"RB6_FILIAL;RB6_TABELA;RB6_DESCTA;RB6_TIPOVL;RB6_NIVEL;RB6_FAIXA;RB6_PTOMIN;RB6_PTOMAX;RB6_CLASSE;RB6_DTREF;RB6_COEFIC;RB6_REGIAO;RB6_ATUAL;RB6_XCARGO;RB6_XDCARG;RB6_VALOR"}
	Local aRBR:={"RBR_FILIAL;RBR_TABELA;RBR_DESCTA;RBR_DTREF;RBR_VLREF;RBR_USAPTO;RBR_APLIC;RBR_TIPOVL;RBR_SIMBOL;RBR_TABINI"}
	Pergunte('FSW1300501',.T.)

	cFile := cGetFile( 'Todos os Arquivos | *.*' , cText, 0, 'C:\', .F., GETF_LOCALHARD,.F.)

	If !File(cFile)
		Alert("O arquivo inválido","[IMPEX01] - ERRO")
		Return
	EndIf

	FT_FUSE(cFile)
	ProcRegua(FT_FLASTREC())
	FT_FGOTOP()

	While !FT_FEOF()

		IncProc("Lendo arquivo...")

		cLinha := FT_FREADLN()


		If nCount != 1
			If lPrim
				aCampos := Separa(cLinha,";",.T.)
				lPrim := .F.
			Else
				If !(EMPTY(STRTRAN(cLinha, ";", "")))
					AAdd(aDados,Separa(cLinha,";",.T.))
				Else
					EXIT
				EndIf
			EndIf
		ElseIf MV_PAR07 <> 1 .AND. cLinha <>  aRB6[1] 
			Alert("Conteudo do cabeçalho  do arquivo está fora do esperado. Formato esperado: " +aRB6[1] +cEol+;
		           " Formato do arquivo: " + cLinha	,"[IMPEX01] - ATENCAO")
			lRet:= .F.
			EXIT

		ElseIf MV_PAR07 <> 2 .AND. cLinha <> aRBR[1]      
			Alert("Conteudo do cabeçalho  do arquivo está fora do esperado. Formato esperado: " +aRBR[1] +cEol+;
			      " Formato do arquivo: " + cLinha	,"[IMPEX01] - ATENCAO")		
			lRet:= .F.
			EXIT
		EndIf

		nCount++

		FT_FSKIP()

	EndDo
	If lRet== .F.
		Alert("Conteudo do " +cFile+ "inválido","[IMPEX01] - ATENCAO")

	Else
		If MV_PAR07 == 1
            Processa({|| ImportRBR(aDados)} , "Aguarde a importando cabeçalho da tabela...") 
			//ImportRBR(aDados)

		ElseIf MV_PAR07 == 2

			If ValidRB6(aDados)	    
				Processa({|| ImportRB6(aDados)} , "Aguarde a importando itens da tabela...")  			
				//ImportRB6(aDados)
			Else
				lRet := .F.
			Endif

		EndIf
	Endif
	FT_FUSE()

Return lRet

/*/{Protheus.doc} ImportRBR
Importação da Tabela RBR
@author queizy.nascimento
@since 27/10/2017
@version 1.0
@return ${return}, ${return_description}
@param aDados, array, descricao
@project MAN0000007423048_EF_005
@type function
/*/
Static Function ImportRBR(aDados)

	Local i := 0
	Local j := 0
	Local cRetorno :=""
	Local lRet:= .T.
	Local aRetorno:={}
                           
	ProcRegua(Len(aDados))
	For i:=1 to Len(aDados)

		dbSelectArea("RBR")
		RBR->(dbSetOrder(1))

		For j:= 1 to Len (aDados[i])
			If (Empty(aDados[i,j]) .AND. j <> 9 .AND. j <>10)
				lRet:= .F.

			EndIf
		Next j

		If lRet
			If !RBR->(DbSeek(PADL(aDados[i,1],TamSX3("RBR_FILIAL")[1],"0")+PADL(aDados[i,2],TamSX3("RBR_TABELA")[1],"0")+dtos(ctod(aDados[i,4]))))
				If PADL(aDados[i,1],TamSX3("RBR_FILIAL")[1],"0") $  AllTrim(MV_PAR01) .OR. PADL(aDados[i,1],TamSX3("RBR_FILIAL")[1],"0") $ AllTrim(MV_PAR02)
					If  aDados[i,4] >=   cValtochar(MV_PAR05)   .OR.	cValtochar(MV_PAR06) <= aDados[i,4]

						Begin Transaction
		

							IncProc("Importando Tabela...")

							Reclock("RBR",.T.)

							RBR->RBR_FILIAL										:= PADL(aDados[i,1],TamSX3("RBR_FILIAL")[1],"0")
							RBR->RBR_TABELA										:= PADL(aDados[i,2],TamSX3("RBR_TABELA	")[1],"0")
							RBR->RBR_DESCTA										:= aDados[i,3]
							RBR->RBR_DTREF 										:= ctod(aDados[i,4])
							RBR->RBR_VLREF  									:= Val(aDados[i,5])
							RBR->RBR_USAPTO 									:= Val(aDados[i,6])
							RBR->RBR_APLIC 										:= aDados[i,7]
							RBR->RBR_TIPOVL										:= Val(aDados[i,8])
							RBR->RBR_SIMBOL 									:= aDados[i,9]
							RBR->RBR_TABINI  									:= aDados[i,10]

							RBR->(MsUnlock())
							AADD(aRetorno,{PADL(aDados[i,1],TamSX3("RB6_FILIAL")[1],"0"),cvaltochar(date()),"Dado Importado: " + RBR->RBR_FILIAL +" | "+ RBR->RBR_TABELA +' - '+ RBR->RBR_DESCTA})
						End Transaction
					Else
						AADD(aRetorno,{PADL(aDados[i,1],TamSX3("RB6_FILIAL")[1],"0"),cvaltochar(date()),"Data informada não existe no  arquivo de importação"})
					EndIf
				Else
					AADD(aRetorno,{PADL(aDados[i,1],TamSX3("RB6_FILIAL")[1],"0"),cvaltochar(date()),"Filial informada não existe no  arquivo de importação"})
				EndIf
			Else
				AADD(aRetorno,{PADL(aDados[i,1],TamSX3("RB6_FILIAL")[1],"0"),cvaltochar(date()),"Linha já importada, por favor, verifique as informações importadas"})
			EndIf
		Else
			AADD(aRetorno,{PADL(aDados[i,1],TamSX3("RB6_FILIAL")[1],"0"),cvaltochar(date()),"Campo Vazio"})
			lRet:= .T.
		EndIf
	Next i

	If !Empty(aRetorno)
		oReport := reportDef(aRetorno)
		oReport:printDialog()
	Else
		Alert("Importação Realizada com Sucesso!")
	EndIf

Return
/*/{Protheus.doc} ImportRB6
Importação da tabela RB6.
@author queizy.nascimento
@since 27/10/2017
@version 1.0
@return ${return}, ${return_description}
@param aDados, array, descricao
@project MAN0000007423048_EF_005
@type function
/*/

Static Function ImportRB6(aDados)

	Local i := 0
	Local j := 0
	Local nX:=0
	Local cRetorno :=""
	Local lRet:= .T.
	Local nValor:= 0
	Local nCoef:= 0
	Local aRetorno:={}
	Local dData
                       
	ProcRegua(Len(aDados))
	For i:=1 to Len(aDados)

		dbSelectArea("RB6")
		RB6->(dbSetOrder(3)) //RB6_FILIAL+RB6_TABELA+DTOS(RB6_DTREF)+RB6_NIVEL+RB6_FAIXA


		For j:= 1 to Len (aDados[i])
			If (Empty(aDados[i,j]) .AND. j <> 7 .AND. j <> 8 .AND. j <> 11 .AND. j <> 12)
				lRet:= .F.

			EndIf
		Next j

		If lRet
			If !RB6->(DbSeek(PADL(aDados[i,1],TamSX3("RB6_FILIAL")[1],"0")+PADL(aDados[i,2],TamSX3("RB6_TABELA")[1],"0")+PADL(dtos(ctod(aDados[i,10])),TamSX3("RB6_DTREF")[1],"0")+PADL(aDados[i,5],TamSX3("RB6_NIVEL")[1],"0")+aDados[i,6]))
				If PADL(aDados[i,1],TamSX3("RB6_FILIAL")[1],"0") $  AllTrim(MV_PAR01) .AND.  PADL(aDados[i,1],TamSX3("RB6_FILIAL")[1],"0") $  AllTrim(MV_PAR02)
					If PADL(aDados[i,2],TamSX3("RB6_TABELA")[1],"0") $ AllTrim(MV_PAR03) .AND. PADL(aDados[i,2],TamSX3("RB6_TABELA	")[1],"0") $ AllTrim(MV_PAR04)
						If Dtos(ctod(aDados[i,10])) >=  dtos(MV_PAR05)   .AND.	Dtos(ctod(aDados[i,10]))   <= dtos(MV_PAR06)
							If RBR->(DbSeek(PADL(aDados[i,1],TamSX3("RBR_FILIAL")[1],"0")+PADL(aDados[i,2],TamSX3("RBR_TABELA")[1],"0")+dtos(ctod(aDados[i,10]))))
								dData:=  RBR->RBR_DTREF
								nValor:= RBR->RBR_VLREF
								//Calculo do Coeficiente
								nCoef:= Val(aDados[i,16]) / nValor
								If ctod(aDados[i,10])	== dData


									Begin Transaction

										IncProc("Importando Tabela...")

										Reclock("RB6",.T.)

										RB6->RB6_FILIAL		:= PADL(aDados[i,1],TamSX3("RB6_FILIAL")[1],"0")
										RB6->RB6_TABELA		:= PADL(aDados[i,2],TamSX3("RB6_TABELA")[1],"0")
										RB6->RB6_DESCTA		:= aDados[i,3]
										RB6->RB6_TIPOVL		:= Val(aDados[i,4])
										RB6->RB6_NIVEL  	:= PADL(aDados[i,5],TamSX3("RB6_NIVEL")[1],"0")
										RB6->RB6_FAIXA		:= aDados[i,6]
										RB6->RB6_PTOMIN		:= Val(aDados[i,7])
										RB6->RB6_PTOMAX  	:= Val(aDados[i,8])
										RB6->RB6_CLASSE  	:= PADL(aDados[i,9],TamSX3("RB6_CLASSE")[1],"0")
										RB6->RB6_DTREF   	:= ctod(aDados[i,10])
										RB6->RB6_COEFIC  	:= nCoef
										RB6->RB6_REGIAO 	:= aDados[i,12]
										RB6->RB6_ATUAL   	:= aDados[i,13]
										RB6->RB6_XCARGO  	:= PADL(aDados[i,14],TamSX3("RB6_XCARGO")[1],"0")
										RB6->RB6_XDCARG 	:= aDados[i,15]
										//RB6->RB6_VALOR 		:= Val(aDados[i,16])
										RB6->RB6_VALOR 		:= Val(StrTran(aDados[i,16],",",".")) 

										RB6->(MsUnlock())

										AADD(aRetorno,{PADL(aDados[i,1],TamSX3("RB6_FILIAL")[1],"0"),cvaltochar(date()),"Dado Importado: " + RB6->RB6_FILIAL + " | " + RB6->RB6_TABELA + " - " + RB6->RB6_DESCTA + " | " + RB6->RB6_XCARGO + " - " + RB6->RB6_XDCARG })
									End Transaction
								Else
									AADD(aRetorno,{PADL(aDados[i,1],TamSX3("RB6_FILIAL")[1],"0"),cvaltochar(date()),"Data do Item diferente da Data do Cabeçalho"})
								EndIf
							Else
								AADD(aRetorno,{PADL(aDados[i,1],TamSX3("RB6_FILIAL")[1],"0"),cvaltochar(date()),"Item sem cabeçalho"})
							EndIf
						Else
							AADD(aRetorno,{PADL(aDados[i,1],TamSX3("RB6_FILIAL")[1],"0"),cvaltochar(date()),"Data informada diferente do parametro"})
						EndIf
					Else
						AADD(aRetorno,{PADL(aDados[i,1],TamSX3("RB6_FILIAL")[1],"0"),cvaltochar(date()),"Tabela informada diferente do parametro"})
					EndIf
				Else
					AADD(aRetorno,{PADL(aDados[i,1],TamSX3("RB6_FILIAL")[1],"0"),cvaltochar(date()),"Filial informada diferente do parametro"})
				EndIf
			Else
				AADD(aRetorno,{PADL(aDados[i,1],TamSX3("RB6_FILIAL")[1],"0"),cvaltochar(date()),"Linha "+Alltrim(Str(i))+" já importada."})
				lRet:= .T.
			EndIf
		Else
			AADD(aRetorno,{PADL(aDados[i,1],TamSX3("RB6_FILIAL")[1],"0"),cvaltochar(date()),"Campo Em Branco"})
		EndIf
	Next i

	If !Empty(aRetorno)
		oReport := reportDef(aRetorno)
		oReport:printDialog()
	EndIf

Return
/*/{Protheus.doc} reportDef
//TODO Descrição auto-gerada.
@author queizy.nascimento
@since 07/11/2017
@version 1.0
@return ${return}, ${return_description}
@project MAN0000007423048_EF_005
@type function
/*/
Static Function reportDef(aRetorno)

	Local oReport := Nil
	Local oSection:= Nil
	Local cTitulo := 'Log Importação Tabela Salarial'
	Local lRet := .T.

	oReport := TReport():New('F1300501', cTitulo, , {|oReport| PrintReport(oReport,aRetorno)},"Este relatorio ira imprimir o Log da Importação.")
	oReport:SetPortrait()
	oReport:SetTotalInLine(.F.)
	oReport:ShowHeader()

	oSection := TRSection():New(oReport,"Filial",{"RBR"},,.F.,.T.)
	oSection:SetTotalInLine(.F.)

	TRCell():New(oSection, "RBR_FILIAL"		, "RBR", 'Filial'			,"@!" ,TamSX3("RBR_FILIAL")[1], .T.,/*{|| code-block de impressao }*/)
	TRCell():New(oSection, "Data"			, "RBR", 'Data da Importacao',"@!" ,11,.T.)
	TRCell():New(oSection, "Inconsistências", "RBR", 'Inconsistencias '	,"@!",100,.T.)

	oReport:SetTotalInLine(.T.)

	oSection:SetPageBreak(.T.)
	oSection:SetTotalText(" ")

Return (oReport)

/*/{Protheus.doc} PrintReport
//TODO Descrição auto-gerada.
@author queizy.nascimento
@since 07/11/2017
@version 1.0
@return ${return}, ${return_description}
@param oReport, object, descricao
@project MAN0000007423048_EF_005
@type function
/*/
Static Function PrintReport(oReport,aRetorno)

	Local oSection := oReport:Section(1)
	Local cQuery    := ""
	Local lPrim 	:= .T.
	Local lRet := .T.
	Local cPerg :="FSW1300501"
	Local nX:= 1

	oReport:SetMeter(Len(aRetorno))
	oReport:IncMeter()

	While nX <= Len(aRetorno)

		If oReport:Cancel()
			Exit
		EndIf

		oSection:Init()
		oReport:IncMeter()

		oSection:Cell("RBR_FILIAL"):SetValue(aRetorno[nX,1])
		oSection:Cell("Data"):SetValue(aRetorno[nX,2])
		oSection:Cell("Inconsistencias"):SetValue(aRetorno[nX,3])

		oSection:Printline()
		nX++
	EndDo
	oReport:ThinLine()
	oSection:Finish()
Return

//////////////////////////////////////////
// Valida se não já não existe o cargo  //
// em algum outro nível                 //
//////////////////////////////////////////
Static Function ValidRB6(aDados)
	Local nJ 	:= 0
	Local nI	:= 0
	Local lRet	:= .T.
	
	For nI:=1 to Len(aDados)
		For nJ:= 1 to Len (aDados[nI])
			If nJ <= Len(aDados) // ticket n° 7565267 - 415966 - Paulo Dias - validação tamanho do arquivo.
				If (Empty(aDados[nI,nJ]) .AND. nJ <> 7 .AND. nJ <> 8 .AND. nJ <> 11 .AND. nJ <> 12) .And. lRet
					Alert("O arquivo inválido. Preencha as colunar obrigatórias","[IMPEX06] - ERRO")
					lRet:= .F.
					nI:= Len(aDados)
					Exit
				Else
					If !ExitRB6(PADL(aDados[nI,1],TamSX3("RB6_FILIAL")[1],"0"), PADL(aDados[nI,2],TamSX3("RB6_TABELA")[1],"0"), PADL(aDados[nI,14],TamSX3("RB6_XCARGO")[1],"0"), PADL(aDados[nI,5],TamSX3("RB6_NIVEL")[1],"0"), aDados, ctod(aDados[nI,10]))
						Alert("O arquivo inválido. O cargo "+ PADL(aDados[nI,14],TamSX3("RB6_XCARGO")[1],"0") +" já existe na tabela "+ PADL(aDados[nI,2],TamSX3("RB6_TABELA")[1],"0") +" - Dt Ref.: "+aDados[nI,10],"[IMPEX07] - ERRO")				
						lRet := .F.
						nI:= Len(aDados)
						Exit
					EndIf   
					
					If PADL(aDados[nI,14],TamSX3("RB6_XCARGO")[1],"0") == PADL(aDados[nJ,14],TamSX3("RB6_XCARGO")[1],"0") .And. PADL(aDados[nI,5],TamSX3("RB6_NIVEL")[1],"0") != PADL(aDados[nJ,5],TamSX3("RB6_NIVEL")[1],"0") .And.  nI != nJ
							Alert("O arquivo inválido. O cargo "+ PADL(aDados[nI,14],TamSX3("RB6_XCARGO")[1],"0") +" já existe na tabela "+ PADL(aDados[nI,2],TamSX3("RB6_TABELA")[1],"0") +" - Dt Ref.: "+aDados[nI,10],"[IMPEX07] - ERRO")
							lRet := .F.
							nI := Len(aDados)
							Exit
					EndIf 
				EndIf
			EndIf
		Next nJ
	Next nI

Return lRet

Static Function ExitRB6(cFilRB6, cTabela, cCargo, cNivel, aDados,dDtRef)
	Local lRet	:= .T.
	Local cQuery	:= ""
	Local cAliasRB6 := GetNextAlias()
	Local nX, nY	:= 0
	
	cQuery 	:= " SELECT RB6_FILIAL "
	cQuery 	+= " FROM " + RetSqlName("RB6") + " RB6 "
	cQuery 	+= " WHERE "
	cQuery  += " RB6_FILIAL = '" + cFilRB6     + "' AND"
	cQuery  += " RB6_TABELA = '" + cTabela     + "' AND"
	cQuery  += " RB6_XCARGO = '" + cCargo      + "' AND"	 
	cQuery  += " RB6_DTREF  = '" + DTOS(dDtRef)+ "' AND"	 
	cQuery  += " RB6_NIVEL <> '" + cNivel      + "' AND"		
	cQuery 	+= " RB6.D_E_L_E_T_	= ' '"
			
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasRB6,.T.,.T.)

	If !(cAliasRB6) ->(EOF())
		lRet := .F.	
	EndIf

	(cAliasRB6) -> (DbCloseArea())
		
/*	If lRet
		For nX := 1 To Len (aDados)
			For nY := nX To Len (aDados)
				If PADL(aDados[nX,14],TamSX3("RB6_XCARGO")[1],"0") == PADL(aDados[nY,14],TamSX3("RB6_XCARGO")[1],"0") .And. PADL(aDados[nX,5],TamSX3("RB6_NIVEL")[1],"0") != PADL(aDados[nY,5],TamSX3("RB6_NIVEL")[1],"0") .And.  nX != nY
					Alert("O arquivo inválido. O cargo "+ PADL(aDados[nX,14],TamSX3("RB6_XCARGO")[1],"0") +" já existe na tabela "+ PADL(aDados[nX,2],TamSX3("RB6_TABELA")[1],"0") +" - Dt Ref.: "+DTOC(dDtRef),"[IMPEX07] - ERRO")
					lRet := .F.
					nX := Len(aDados)
					Exit
				EndIf 
			Next
		Next		
	EndIf   */
	
Return lRet
