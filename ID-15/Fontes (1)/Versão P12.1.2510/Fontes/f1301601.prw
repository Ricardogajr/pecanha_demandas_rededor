#include "totvs.ch"
#include "protheus.ch"
#include "topconn.ch"
                 

/*/{Protheus.doc} F1301601
Importação da Faixa Salarial
@author queizy.nascimento
@since 09/11/2017
@version 1.0
@return ${return}, ${return_description}
@project MAN0000007423048_EF_016
@type function
/*/
User Function F1301601()

	Local cLinha 	:= ""
	Local lRet		:= .T.
	Local lPrim 	:= .F.
	Local aDados 	:= {}
	Local cText 	:= OemToAnsi("Selecione o Arquivo de Importação:")

	Pergunte('FSW1301601',.T.)

	Processa({|| LerArq(@aDados)}, "Lendo Arquivo...")
	Processa({|| ImportSal(aDados)}, "Importando...")
	FT_FUSE()

Return

/*/{Protheus.doc} ImportSal
//TODO Descrição auto-gerada.
@author queizy.nascimento
@since 09/11/2017
@version 1.0
@return ${return}, ${return_description}
@param aDados, array, descricao
@project MAN0000007423048_EF_016
@type function
/*/
Static Function ImportSal(aDados)

	Local i 		  := 0
	Local j 		  := 0
	Local lRet		  := .T.
	Local aRetorno	  :={}
	Local nSalario 	  := 0
	Local cNome		  :=""
	Local cSeq		  :=""
	Local cCargo	  :=""
	Local cCentroC 	  :=""
	Local cSindica	  :=""
	Local cCatFunc    :=""
	Local SitFolh     :=""
	Local aAreaSRA    := SRA->(GetArea())
	Local aAreaSR3    := SR3->(GetArea())
	Local aAreaSR7    := SR7->(GetArea())
	Local aAreaSRJ	  :=SRJ->(GetArea())

	For i:=1 to Len(aDados)

		SRA->(DbSetOrder(1))
		If SRA->(DbSeek(PADL(aDados[i,1],TamSX3("RA_FILIAL")[1],"0")+PADL(aDados[i,2],TamSX3("RA_MAT")[1],"0")))
			nSalario:= 	SRA->RA_SALARIO
			cCentroC:= SRA->RA_CC
			cSindica:= SRA->RA_SINDICA
			cCatFunc:= SRA->RA_CATFUNC
			SitFolh := SRA->RA_SITFOLH

			cNome	:= Posicione("SRA",1,PADL(aDados[i,1],TamSX3("RA_FILIAL")[1],"0")+PADL(aDados[i,2],TamSX3("RA_MAT")[1],"0"),"RA_NOME")

			If  Dtos(ctod(aDados[i,3])) >=   dtos(MV_PAR16)   .AND.	 Dtos(ctod(aDados[i,3])) <=   dtos(MV_PAR17)

				If PADL(aDados[i,4],TamSX3("RA_TIPOALT")[1],"0") >=  AllTrim(MV_PAR12) .AND. PADL(aDados[i,4],TamSX3("RA_TIPOALT")[1],"0") <=  AllTrim(MV_PAR13)

					If PADL(aDados[i,1],TamSX3("RA_FILIAL")[1],"0") >=  AllTrim(MV_PAR02) .AND.  PADL(aDados[i,1],TamSX3("RA_FILIAL")[1],"0") <=  AllTrim(MV_PAR03)

						If PADL(aDados[i,2],TamSX3("RA_MAT")[1],"0") >=   AllTrim(MV_PAR10) .AND. PADL(aDados[i,2],TamSX3("RA_MAT")[1],"0") <=   AllTrim(MV_PAR11)

							If  PADL(aDados[i,6],TamSX3("RA_CODFUNC")[1],"0") >=   AllTrim(MV_PAR08) .AND.  PADL(aDados[i,6],TamSX3("RA_CODFUNC")[1],"0") <=   AllTrim(MV_PAR09)

								If  cCentroC >= AllTrim(MV_PAR04)    .AND. cCentroC <= AllTrim(MV_PAR05)

									If cSindica >= AllTrim(MV_PAR06) .AND. cSindica <= AllTrim (MV_PAR07)

										If cCatFunc $ Alltrim(MV_PAR14)

											If  SitFolh $  MV_PAR15

												SR7->(DbSetOrder(1))
												If !SR7->(DbSeek(PADL(aDados[i,1],TamSX3("R7_FILIAL")[1],"0")+PADL(aDados[i,2],TamSX3("R7_MAT")[1],"0")+dtos(ctod(aDados[i,3]))))


													cFuncao	:= Posicione("SRJ",1,xFilial("SRJ") +SRA->RA_CODFUNC,"RJ_DESC")


													cCargo	:= Posicione("SQ3",1,xFilial("SQ3") +SRA->RA_CODFUNC,"Q3_DESCSUM")

													SR3->(DbSetOrder(1))
													If !SR3->(DbSeek(PADL(aDados[i,1],TamSX3("R3_FILIAL")[1],"0")+PADL(aDados[i,2],TamSX3("R3_MAT")[1],"0")+dtos(ctod(aDados[i,3]))))

														While PADL(aDados[i,1],TamSX3("R3_FILIAL")[1],"0")+PADL(aDados[i,2],TamSX3("RA_MAT")[1],"0")+ dtos(ctod(aDados[i,3])) == SR3->(R3_FILIAL+R3_MAT+Dtos(R3_DATA))

															cSeq	:= SR3->R3_SEQ

															SR3->(dbSkip())

														EndDo
														If  Val(aDados[i,5]) >= nSalario
															AADD(aRetorno,{PADL(aDados[i,1],TamSX3("RA_FILIAL")[1],"0"),PADL(aDados[i,2],TamSX3("RA_MAT")[1],"0"),cNome,"Importação realizada com sucesso"})
															Begin Transaction
																ProcRegua(Len(aDados))

																IncProc("Importando Tabela...")

																SRA->(RecLock("SRA",.F.))
													 			SRA->RA_SALARIO										:=  Val(aDados[i,5])
																SRA->RA_ANTEAUM										:=  Val(aDados[i,5])
																SRA->(MsUnlock())

																SR3->(RecLock("SR3",.T.))
																SR3->R3_FILIAL										:= PADL(aDados[i,1],TamSX3("R3_FILIAL")[1],"0")
																SR3->R3_MAT											:= PADL(aDados[i,2],TamSX3("R3_MAT")[1],"0")
																SR3->R3_DATA										:= ctod(aDados[i,3])
																SR3->R3_SEQ											:= StrZero(Val(cSeq)+1,1)
																SR3->R3_PD      									:= "000"
																SR3->R3_DESCPD 										:= "SALARIO BASE"
																SR3->R3_VALOR										:= Val(aDados[i,5])
																SR3->R3_TIPO										:= PADL(aDados[i,4],TamSX3("R3_TIPO")[1],"0")
																SR3->R3_ANTEAUM										:=	Val(aDados[i,5])
																SR3->(MsUnlock())

																SR7->(RecLock("SR7",.T.))
																SR7->R7_FILIAL										:= PADL(aDados[i,1],TamSX3("R7_FILIAL")[1],"0")
																SR7->R7_MAT											:= PADL(aDados[i,2],TamSX3("R7_MAT")[1],"0")
																SR7->R7_DATA										:= ctod(aDados[i,3])
																SR7->R7_SEQ											:= StrZero(Val(cSeq)+1,1)
																SR7->R7_TIPO										:= PADL(aDados[i,4],TamSX3("R7_TIPO")[1],"0")
																SR7->R7_FUNCAO										:= PADL(aDados[i,6],TamSX3("R7_FUNCAO")[1],"0")
																SR7->R7_DESCFUN										:= cFuncao
																SR7->R7_TIPOPGT										:= SRA->RA_TIPOPGT
																SR7->R7_CATFUNC										:= SRA->RA_CATFUNC
																SR7->R7_CARGO										:= SRA->RA_CARGO
																SR7->R7_DESCCAR										:= cCargo
																SR7->R7_USUARIO										:= Alltrim(cUsername)+'|'+Alltrim(LogUserName())
																//////////////////////////////////////////
																// NOVOS CAMPOS INCLUIDOS EM 22/03/2019 //
																//////////////////////////////////////////
																SR7->R7_DTDIS                                       := ctod(aDados[i,7])
																SR7->R7_XDTEAC                                      := ctod(aDados[i,8])
																SR7->R7_XDSC                                        := aDados[i,9]
																///////////////////////////////////////////////////////////////////////////////////////////////////////
																SR7->(MsUnlock())

															End Transaction
														Else
															AADD(aRetorno,{PADL(aDados[i,1],TamSX3("RA_FILIAL")[1],"0"),PADL(aDados[i,2],TamSX3("RA_MAT")[1],"0"),cNome,"Salario da Importação menor ou igual ao salário atual"})
														EndIf
													Else
														AADD(aRetorno,{PADL(aDados[i,1],TamSX3("R3_FILIAL")[1],"0"),PADL(aDados[i,2],TamSX3("RA_MAT")[1],"0"),cNome,"Linha já importada"})
													EndIf
												Else
													AADD(aRetorno,{PADL(aDados[i,1],TamSX3("RA_FILIAL")[1],"0"),PADL(aDados[i,2],TamSX3("RA_MAT")[1],"0"),cNome,"Linha já importada"})
												EndIf
											Else
												AADD(aRetorno,{PADL(aDados[i,1],TamSX3("RA_FILIAL")[1],"0"),PADL(aDados[i,2],TamSX3("RA_MAT")[1],"0"),cNome,"Situação do Funcionário diferente do informado"})
											EndIf
										Else
											AADD(aRetorno,{PADL(aDados[i,1],TamSX3("RA_FILIAL")[1],"0"),PADL(aDados[i,2],TamSX3("RA_MAT")[1],"0"),cNome,"Categoria do Funcionário diferente do informado"})
										EndIf
									Else
										AADD(aRetorno,{PADL(aDados[i,1],TamSX3("RA_FILIAL")[1],"0"),PADL(aDados[i,2],TamSX3("RA_MAT")[1],"0"),cNome,"Sindicato do Funcionário diferente do informado"})
									EndIf
								Else
									AADD(aRetorno,{PADL(aDados[i,1],TamSX3("RA_FILIAL")[1],"0"),PADL(aDados[i,2],TamSX3("RA_MAT")[1],"0"),cNome,"Centro de Custo do Funcionário diferente do informado"})
								EndIf
							Else
								AADD(aRetorno,{PADL(aDados[i,1],TamSX3("RA_FILIAL")[1],"0"),PADL(aDados[i,2],TamSX3("RA_MAT")[1],"0"),cNome,"Cod Funcionário diferente do informado"})
							EndIf
						Else
							AADD(aRetorno,{PADL(aDados[i,1],TamSX3("RA_FILIAL")[1],"0"),PADL(aDados[i,2],TamSX3("RA_MAT")[1],"0"),cNome,"Matricula diferente da informada"})
						EndIf

					Else
						AADD(aRetorno,{PADL(aDados[i,1],TamSX3("R7_FILIAL")[1],"0"),PADL(aDados[i,2],TamSX3("RA_MAT")[1],"0"),cNome,"Filial diferente da informada"})
					EndIf
				Else
					AADD(aRetorno,{PADL(aDados[i,1],TamSX3("R3_FILIAL")[1],"0"),PADL(aDados[i,2],TamSX3("RA_MAT")[1],"0"),cNome,"Motivo diferente do informado"})
				EndIf
			Else
				AADD(aRetorno,{PADL(aDados[i,1],TamSX3("R3_FILIAL")[1],"0"),PADL(aDados[i,2],TamSX3("RA_MAT")[1],"0"),cNome,"Data fora do periodo informado"})
			EndIf

		Else
			AADD(aRetorno,{PADL(aDados[i,1],TamSX3("RA_FILIAL")[1],"0"),PADL(aDados[i,2],TamSX3("RA_MAT")[1],"0"),"Não","Filial e Matricula não encontrado no sistema"})
		EndIf
	Next i

	If !Empty(aRetorno)
		Aviso('Processamento Realizado!',"Verifique o log da importação", {'OK'}, 1)
		oReport := reportDef(aRetorno)
		oReport:printDialog()
	EndIf
	RestArea(aAreaSRA)
	RestArea(aAreaSR3)
	RestArea(aAreaSR7)
	RestArea(aAreaSRJ)

Return


/*/{Protheus.doc} reportDef
//TODO Descrição auto-gerada.
@author queizy.nascimento
@since 09/11/2017
@version 1.0
@return ${return}, ${return_description}
@param aRetorno, array, descricao
@project MAN0000007423048_EF_016
@type function
/*/
Static Function reportDef(aRetorno)

	Local oReport 	:= Nil
	Local oSection	:= Nil
	Local cTitulo 	:= 'Log Importação Tabela Salarial'
	Local lRet		 := .T.

	oReport := TReport():New('F1301601', cTitulo, , {|oReport| PrintReport(oReport,aRetorno)},"Este relatorio ira imprimir o Log da Importação.")
	oReport:SetPortrait()
	oReport:SetTotalInLine(.F.)
	oReport:ShowHeader()

	oSection := TRSection():New(oReport,"Filial",{"SRA"},,.F.,.T.)
	oSection:SetTotalInLine(.F.)

	TRCell():New(oSection, "RA_FILIAL"		, "SRA", 'Filial'			,"@!" ,TamSX3("RA_FILIAL")[1], .T.,/*{|| code-block de impressao }*/)
	TRCell():New(oSection, "RA_MAT"			, "SRA", 'Matricula'		,"@!" ,TamSX3("RA_MAT")[1], .T.,/*{|| code-block de impressao }*/)
	TRCell():New(oSection, "RA_NOME"		, "SRA", 'Nome'				,"@!" ,TamSX3("RA_NOME")[1], .T.,/*{|| code-block de impressao }*/)
	TRCell():New(oSection, "Log"            , "SRA", 'Log '	,"@!",100,.T.)

	oReport:SetTotalInLine(.T.)

	oSection:SetPageBreak(.T.)
	oSection:SetTotalText(" ")

Return (oReport)

/*/{Protheus.doc} PrintReport
//TODO Descrição auto-gerada.
@author queizy.nascimento
@since 08/11/2017
@version 1.0
@return ${return}, ${return_description}
@param oReport, object, descricao
@project MAN0000007423048_EF_016
@type function
/*/
Static Function PrintReport(oReport,aRetorno)

	Local oSection 	:= oReport:Section(1)
	Local lPrim 	:= .T.
	Local lRet 		:= .T.
	Local cPerg		:="FSW1301601"
	Local nX		:= 1

	oReport:SetMeter(Len(aRetorno))
	oReport:IncMeter()

	While nX <= Len(aRetorno)

		If oReport:Cancel()
			Exit
		EndIf

		oSection:Init()
		oReport:IncMeter()

		oSection:Cell("RA_FILIAL"):SetValue(aRetorno[nX,1])
		oSection:Cell("RA_MAT"):SetValue(aRetorno[nX,2])
		oSection:Cell("RA_NOME"):SetValue(aRetorno[nX,3])
		oSection:Cell("Log"):SetValue(aRetorno[nX,4])

		oSection:Printline()
		nX++
	EndDo
	oReport:ThinLine()
	oSection:Finish()
Return

Static Function LerArq(aDados)

	Local cLinha 	:= ""
	Local lPrim 	:= .F.
	Local aCampos	:= {}
	
	FT_FUSE(MV_PAR01)
	ProcRegua(FT_FLASTREC())
	FT_FGOTOP()
	////////////////////////////
	// COLUNAS DO ARQUIVO CSV //
	///////////////////////////////////////////////
	// COLUNA A = FILIAL                         //
	// COLUNA B = MATRICULA                      //
	// COLUNA C = DATA DO PAGAMENTO              //
	// COLUNA D = TIPO DE ACORDO                 //
	// COLUNA E = VALOR                          //
	// COLUNA F = FUNCAO                         //
	// COLUNA G = DATA DO ACORDO                 //
	// COLUNA H = DATA DO EFETIVO ACORDO         //
	// COLUNA I = DESCRICAO DO MOTIVO DO ACORDO  //
	///////////////////////////////////////////////

	While !FT_FEOF()

		cLinha := FT_FREADLN()

		cLinha := STRTRAN(cLinha, ",", ".")
		
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


		FT_FSKIP()

	EndDo

Return aDados