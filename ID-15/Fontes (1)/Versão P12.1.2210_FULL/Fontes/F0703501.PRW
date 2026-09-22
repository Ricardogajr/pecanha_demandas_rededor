#INCLUDE "TOTVS.CH"
#INCLUDE "APWIZARD.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWLIBVERSION.CH"
#INCLUDE "FWEVENTVIEWCONSTS.CH"
#INCLUDE "SIGACUSA.CH"
#Include "fileio.ch"


#define F24CONSUMO    1
#define F24COMPRA     2
#define F24P12TOFRONT 1
#define F24FRONTTOP12 2

Static __lNoErro // Variavel nao deve ser removida !!!
Static lxProxNum
Static lFProxNum
Static __lD1D2D3
Static cMoeda330C  //Moedas para calculo do custo medio - Sempre processa moeda 1
Static cProdutoLog //Produtos a serem verificados no log de diferenca de saldo -
//deve ser colocado "/" apos cada produto para separacao dos codigos

Static aOpcCache    := {}
Static __aPrepared  := {}
Static __lCusaVLib
Static lA330ISMOD // Utilizado para testar a existencia da funcao A330ISMOD do fonte MATA330.PRX
Static _aTamSX3

Static __lSeekMOD   := nil
Static __cQryMOD    := nil
Static __cEmpOld    := nil
Static __cFilOld    := nil
Static __oProdMOD
Static __cEmpFilOld
Static __lChkNum    := .F.
Static __RpoRelease := nil


/*{Protheus.doc} F0703501
Função responsável pelas integração de movimentação de estoque
@author Alex Sandro Valario
@since 06/02/2017
@version 1.0
@Project MAN0000007423041_EF_035
@param oParam, object, descricao 
@param nOpcao, numeric, descricao
@return cRET
*/
User Function F0703501(oParam,nOpcao)
	Local cRetorno  := ''
	Local nRegLog   := 0
	Local cID       := U_GetIntegID()
	Local cIndKey   := ''
	Local nIndexSD3
	Local cConteudo := ""
	Local cNomeArq	:= AllTrim(oParam:cXIDEXT)+".txt"
	Local cCriaB2   := GetNewPar("FS_XCRIAB2","2")

	Private cChaveD3

	//Ajusta o número máximo de nomes a serem reservados pela função MayIUseCode.
	SetMaxCodes( 9999999 )

	cConteudo := "---------------------"  + CRLF
	cConteudo += "ID:" + oParam:cXIDEXT  + CRLF

	U_F07Log04(cConteudo, cNomeArq)

	cConteudo := "---------------------"  + CRLF
	cConteudo += "Filial Recebida:" + oParam:cFILREG  + CRLF

	U_F07Log04(cConteudo, cNomeArq)


	If !U_F07ChkFil(oParam:cFILREG)

		cRetorno:= "ERRO| Filial Invalida  "
	Else


		SD3->(DBOrderNickName('FSWSD301'))

		nIndexSD3 := SD3->(IndexOrd())

		cIndKey   := SD3->(xFilial('SD3') + '|' + oParam:cXIDEXT)

		cChaveD3  := SD3->(xFilial('SD3')) + PADR(Alltrim(oParam:cXIDEXT),TamSx3('D3_XIDEXT')[1])


		Begin Sequence

			Begin Transaction

				nRegLog := U_F07LOG01(cID,{oParam})
			End Transaction

			If Empty(oParam:cXIDEXT)
				cRetorno:= "ERRO| cXIDEXT Id de controle não informado! "
				Break
			EndIf

			//Controle de Semáforo para evitar duplicidade na gravação de registro na tabela SD3.

			lFree := MayIUseCode(cChaveD3) //Reservar nomes com o semáforo.

			If !lFree
				nTent := 0
				While !(lFree := MayIUseCode(cChaveD3))

					Sleep(2000) //Espera por 2 segundos
					If ++nTent > 50
						cConteudo := "---------------------"  					       + CRLF
						cConteudo += "Movimento Interno com concorrencia de thread no "+ CRLF
						cConteudo += "IDEXT: "+oParam:cXIDEXT 					       + CRLF

						U_F07Log04(cConteudo, cNomeArq)

						cRetorno:= "ERRO|  Movimento Interno com concorrencia de thread no ID! "
						Break
					Endif
				Enddo
				If lFree
					Sleep(2000) //Espera por 2 segundos para possibilitar a finalização da outra thread
				Endif
			Endif

			If nOpcao == 3
				cConteudo := "---------------------"  	+ CRLF
				cConteudo += "Início da Inclusão"  		+ CRLF
				cConteudo += "ID: " + cID 				+ CRLF

				U_F07Log04(cConteudo, cNomeArq)


				cRetorno := UpSertMovInt(oParam, cID, cChaveD3)

				If cRetorno == "OK"
					If cCriaB2 == "1"
						DbSelectArea("SB2")
						DbSetOrder(1)
						If !SB2->(dbSeek(oParam:CFILREG+Padr(oParam:CCOD,Tamsx3("B2_COD")[1])+oParam:CLOCAL))

							CriaSB2(oParam:CCOD,oParam:CLOCAL,oParam:CFILREG)
							If SB2->(dbSeek(oParam:CFILREG+Padr(oParam:CCOD,Tamsx3("B2_COD")[1])+oParam:CLOCAL))
								RecLock("SB2",.F.)
								SB2->B2_XDATA := GetNewPar("MV_ULMES","")
								Msunlock()
							EndIf

						EndIf
					EndIF
				EndIf
			Else
				cConteudo := "---------------------"  			+ CRLF
				cConteudo += "Início da Alteração/Exclusão"  	+ CRLF
				cConteudo += "ID: " + cID 						+ CRLF

				U_F07Log04(cConteudo, cNomeArq)

				If !ExistIDExt(oParam:cXIDEXT)
					cConteudo := "---------------------"  							+ CRLF
					cConteudo += "Movimento Interno para Estorno não encontrado"  	+ CRLF
					cConteudo += "IDEXT: " + oParam:cXIDEXT 						+ CRLF

					U_F07Log04(cConteudo, cNomeArq)

					cRetorno:= "ERRO|  Movimento Interno para Estorno não encontrado! "
					Break
				EndIf

				cRetorno := DeleteMovInt(cChaveD3)
				cRetorno += CRLF

			EndIf

			If Left(cRetorno,4) == 'ERRO' .And. InTransaction()
				DisarmTransaction()
			EndIf

		End Sequence
	EndIf

	If !Left(cRetorno,4) == 'ERRO'
		U_F07LOG02(nRegLog,cRetorno,.T.,"SD3",nIndexSD3,cIndKey)
	Else
		U_F07LOG02(nRegLog,cRetorno,.F.,"SD3",nIndexSD3,cIndKey)
	EndIf

Return cRetorno

/*{Protheus.doc} UpSertMovInt
*/
Static Function UpSertMovInt(oParam, cID, cChaveD3)

	Local cFILREG   := oParam:cFILREG                           //Filial
	Local cLOCAL    := Padr(oParam:cLOCAL,len(SD3->D3_LOCAL))   //Código do armazem
	Local cCOD      := Padr(oParam:cCOD,len(SD3->D3_COD))       //Código do Produto
	Local cXSETOR   := Padr(oParam:cXSETOR,len(SD3->D3_XSETOR)) //Código do Setor
	Local cXCONSIG  := oParam:cXCONSIG                          //Produto consignado (S/N)
	Local cXFORN    := Padr(oParam:cXFORN,len(SD3->D3_XFORN))   //Código do fornecedor
	Local cXLJFOR   := Padr(oParam:cXLJFOR,len(SD3->D3_XLJFOR)) //Loja do fornecedor
	Local nCUSTO1   := Val(oParam:cCUSTO1)                      //Custo Total do movimento
	Local dEMISSAO  := ctod(oParam:cEmissao)                    //Data de Emissão
	Local cXHORMOV  := oParam:cXHORMOV                          //Hora da Movimentação
	Local cDOC 	    := oParam:cDOC                              //Número do Documento
	Local nQUANT    := Val(oParam:cQUANT)                       //Quantidade do Movimento
	Local nSALDO    := Val(oParam:cSALDO)                       //Saldo de Inventário
	Local cXINVENT  := oParam:cXINVENT                          //Inventario (S/N)
	Local cTM       := oParam:cTM                               //Tipo de movimento
	Local cUM       := oParam:cUM                               //Unid. de Medida (consumo)
	Local cUSUARIO  := oParam:cUSUARIO                          //Usuário responsável pela digitação (login do usuário)
	Local cXNOTA    := oParam:cXNOTA                            //Numero da Nota
	Local cXSERIE   := oParam:cXSERIE                           //Serie da Nota
	Local cXIDEXT   := oParam:cXIDEXT                           //ID Externo (número + item)
	Local cFILORIG  := oParam:cFILORIG	                       //Filial de origem
	Local cFILDEST  := oParam:cFILDEST	                       //Filial de destino
	Local cCC		:= oParam:cCC							   //Centro de custo do Front
	Local cRetorno  := 'OK'
	Local aConv     := {}
	Local cTMCons   := ""
	Local cOp       := ""
	Local cConteudo := ""
	Local cCaminho	:= "\system\fs_log\"
	Local cNomeArq	:= AllTrim(oParam:cXIDEXT)+".txt"
	Local dDataFec  := GetNewPar("MV_ULMES","")
	Local bBlock
	Local cApropri
	Local cProxNum
	Local cDtTime    := DToS(Date())+Space(1)+Time()
	Local cLockKey       := 'MV_DOCSEQ_' +cEmpAnt //+cFilAnt
	Local nTentativas    := 0
	Local nTotTentativas := 120000 //- numero de tentativa para pegar o SX6

	Private cErrorL			:= ""
	Private lAutoErrNoFile 	:= .T.
	Private CUSERNAME 		:= "INTMOV"
	Private dDtValExec      := CToD("  /  /    ")

	cConteudo := "---------------------"  		+ CRLF
	cConteudo += "Posiciona Fornecedor"	  		+ CRLF
	cConteudo += "Filial 		: " + cFilAnt 	+ CRLF
	cConteudo += "Fornecedor 	: " + cXFORN 	+ CRLF
	cConteudo += "Loja 			: " + cXLJFOR 	+ CRLF


	U_F07Log04(cConteudo, cNomeArq)


	If cXCONSIG == "S" .And. !ExistCpo("SA2",cXFORN + cXLJFOR,1,NIL,.F.,.F.)
		cRetorno:= "ERRO| Fornecedor " + cXFORN + ' ' + cXLJFOR + " não cadastrado!"
		Return cRetorno
	EndIf

	//Valida se as rotinas externas podem prosseguir com a execução.
	dDtValExec := dEMISSAO

	If !(U_F1303806())
		cRetorno:= "ERRO| Arquivo de semaforo em utilizacao. Nao eh possivel prosseguir com a rotina."
		Return cRetorno
	EndIf

    /* Essa validação será verificada a sua utilização. 
    // Validações nos processos para não permitir a utilização de produtos que estejam bloqueados na filial em questão.
	If !(U_F0702404())
		cRetorno:= "ERRO| Produto com bloqueio da tabela P17. Nao eh possivel prosseguir com a rotina."
		Return cRetorno
	Endif
    */

	//Validar o calendário contábil
	//(dDtIni ,dDtFim ,nMoedas,cQualMoeda,lShowMsg,cTpSaldo)

	IF CtVlDTMoed(dEMISSAO,dEMISSAO,2     ,"01"      ,.F.     ,"1")
		cRetorno:= "ERRO| Bloqueio por calendario contabil. Nao eh possivel prosseguir com a rotina."
		Return cRetorno
	Endif

	//Validar o processo contábil

	IF !CtbValiDt(Nil,dEMISSAO,,Nil ,Nil ,{"EST001"})
		cRetorno:= "ERRO| Bloqueio por processo contabil (EST001). Nao eh possivel prosseguir com a rotina."
		Return cRetorno
	Endif

	// Validar fechamento de estoque
	IF dDataFec >= dEMISSAO
		cRetorno:= "ERRO| Bloqueio por data de fechamento de estoque (MV_ULMES). Nao eh possivel prosseguir com a rotina."
		Return cRetorno
	Endif

	cConteudo := "---------------------"  		+ CRLF
	cConteudo += "Posiciona Setor"		  		+ CRLF
	cConteudo += "Filial 		: " + cFilAnt 	+ CRLF
	cConteudo += "Setor 		: " + cXSETOR 	+ CRLF


	U_F07Log04(cConteudo, cNomeArq)


	If !Empty(cXSETOR) .And. !ExistCpo("P11",cXSETOR,1,NIL,.F.,.F.)
		cRetorno:= "ERRO| Setor " + cXSETOR + " não cadastrado!"
		Return cRetorno
	EndIf


	aConv := U_F07024X(cCOD, cFILREG , nQUANT, F24CONSUMO , F24FRONTTOP12, cUM)
	If !Empty(aConv[3])
		cRetorno:= "ERRO| " + aConv[3]
		Return cRetorno
	EndIf
	nQUANT := aConv[1]
	cUM    := aConv[2]

	cConteudo := "---------------------"  					+ CRLF
	cConteudo += "Tratamento de Custo Zerado"  				+ CRLF
	cConteudo += "Filial 		: " + cFilAnt 				+ CRLF
	cConteudo += "Custo		 	: " + cValtoChar(nCUSTO1) 	+ CRLF


	U_F07Log04(cConteudo, cNomeArq)

	If nCUSTO1 < 0
		cRetorno:= "ERRO| Não são permitidas movimentações de custo negativo!"
		Return cRetorno
	EndIf

	cConteudo := "---------------------"  					+ CRLF
	cConteudo += "Valida TM"				  				+ CRLF
	cConteudo += "Filial 		: " + cFilAnt 				+ CRLF
	cConteudo += "TM		 	: " + cTM				 	+ CRLF


	U_F07Log04(cConteudo, cNomeArq)

	DbSelectArea("SF5")
	SF5->(DbSetOrder(1))
	If !SF5->(DbSeek(xFilial("SF5") + cTM))
		cConteudo := "---------------------"  		+ CRLF
		cConteudo += "TM não encontra" 		 		+ CRLF
		cConteudo += "Filial 		: " + cFilAnt 	+ CRLF
		cConteudo += "Setor 		: " + cXSETOR 	+ CRLF


		U_F07Log04(cConteudo, cNomeArq)

		cRetorno:= "ERRO| Tipo de Movimento " + cTM + " não cadastrado!"
		Return cRetorno
	ElseIf SF5->F5_MSBLQL == "1"
		cConteudo := "---------------------"  		+ CRLF
		cConteudo += "TM Bloqueada na tabela SF5" 		 		+ CRLF
		cConteudo += "Filial 		: " + cFilAnt 	+ CRLF
		cConteudo += "TM 		: " + cTM 	+ CRLF


		U_F07Log04(cConteudo, cNomeArq)

		cRetorno:= "ERRO| O Tipo de Movimento " + cTM + " está bloqueado para uso na tabela SF5, favor verificar o campo F5_MSBLQL!"
		Return cRetorno

	ElseIf nCUSTO1 == 0 .And. SF5->F5_VAL == "S"
		cConteudo := "---------------------"  					+ CRLF
		cConteudo += "Valida TM - 2"			  				+ CRLF
		cConteudo += "Filial 		: " + cFilAnt 				+ CRLF
		cConteudo += "nCusto 1		: " + cValToChar(nCUSTO1) 	+ CRLF
		cConteudo += "Valorizado	: " + SF5->F5_VAL		 	+ CRLF


		U_F07Log04(cConteudo, cNomeArq)

		If Empty(SF5->F5_XTMNVAL)
			cRetorno:= "ERRO| Tipo de Movimento não valorizado não informado para o TM " + cTM + " !"
			Return cRetorno
		Else
			cTM := SF5->F5_XTMNVAL
			If !SF5->(DbSeek(xFilial("SF5") + cTM ))
				cRetorno:= "ERRO| Tipo de Movimento não valorizado " + cTM + " não cadastrado!"
				Return cRetorno
			ElseIf SF5->F5_VAL == "S"
				cRetorno:= "ERRO| Tipo de Movimento não valorizado " + cTM + " configurado errado (F5_VAL)!"
				Return cRetorno
			EndIf
		EndIf
	EndIf

	SB1->(DBSetOrder(1)) //B1_FILIAL+B1_COD
	SB1->(DBSeek(xFilial("SB1")+cCOD))

	//Valida se o produto está bloqueado no cadastro de produto.
	IF SB1->B1_MSBLQL == "1"
		cRetorno:= "ERRO| Produto com bloqueio no cadastro do produto (B1_MSBLQL). Nao eh possivel prosseguir com a rotina."
		Return cRetorno
	Endif

	If (SB1->B1_APROPRI == "I" .And. Empty(cOp)) .And. SF5->F5_APROPR != "S"
		cApropri := "3"
	Else
		cApropri := "0"
	EndIf
	If cApropri == "0" .And. SF5->F5_VAL == "S"
		cApropri := "6"
	Endif


	Begin Transaction

		bBlock := ErrorBlock({|e|ChkErr(e)})

		//SB2->(CriaSB2(cCOD,cLOCAL))


		If !ExistIDExt(cXIDEXT) //SD3->(DBOrderNickName('FSWSD301'))  // Índice D3_FILIAL+D3_XIDEXT


			cProxNum := _ProxNum()//Função customizada porque o padrão tá muito lento - Lucas Miranda 20/07/2023


			DBSelectArea("SD3")
			RecLock("SD3",.T.)
			SD3->D3_FILIAL  := xFilial("SD3")
			SD3->D3_XIDEXT  := cXIDEXT
			SD3->D3_NUMSEQ  := cProxNum
			SD3->D3_XUSRIN  := cDtTime
		Else
			If SD3->D3_XCONSIG == "S"
				IF Empty(SD3->D3_XFORN)
					cRetorno:= "ERRO| Codigo do fornecedor não informado."
					DisarmTransaction()
					Break
				Endif
				IF Empty(SD3->D3_XLJFOR)
					cRetorno:= "ERRO| Codigo da loja do fornecedor não informado."
					DisarmTransaction()
					Break
				Endif
				//Quando for alteração precisa primeiro estornar a quantidade anterior
				cTMCons := IIF(SD3->D3_TM >= "500", "S", "E")
				If !U_F0703504(SD3->D3_LOCAL,SD3->D3_COD,SD3->D3_XFORN,SD3->D3_XLJFOR,SD3->D3_CUSTO1,SD3->D3_QUANT ,cTMCons)
					cRetorno:= "ERRO| Não conseguiu atualizar a tabela P18."
					DisarmTransaction()
					Break
				EndIf
			Endif
			DBSelectArea("SD3")
			RecLock("SD3",.F.)
		Endif
		SD3->D3_XUSRAL  := cDtTime
		SD3->D3_EMISSAO := dEMISSAO
		SD3->D3_TM      := cTM
		SD3->D3_DOC     := cDOC
		SD3->D3_COD     := cCOD
		SD3->D3_LOCAL   := cLOCAL
		SD3->D3_QUANT   := nQUANT
		SD3->D3_QTSEGUM := ConvUM(SD3->D3_COD,SD3->D3_QUANT,0,2) // 2UM
		SD3->D3_GRUPO   := SB1->B1_GRUPO
		SD3->D3_TIPO    := SB1->B1_TIPO
		SD3->D3_UM      := cUM
		SD3->D3_SEGUM   := SB1->B1_SEGUM
		SD3->D3_USUARIO := cUSUARIO
		If SD3->D3_TM <= "500"
			SD3->D3_CF := "DE"+cApropri
		Else
			SD3->D3_CF := "RE"+cApropri
		EndIf
		SD3->D3_CHAVE   := SubStr(SD3->D3_CF,2,1)+IIF(D3_CF=="DE4","9","0")
		SD3->D3_CONTA   := SB1->B1_CONTA
		SD3->D3_XCONTA  := SF5->F5_XCONTA
		If !Empty(AllTrim(cCC))
			SD3->D3_CC      := cCC
		Else
			SD3->D3_CC      := IIF(!Empty(cXSETOR),Posicione("P11",1,xFilial("P11")+cXSETOR,"P11_CCUSTO"),Posicione("NNR",1,xFilial("NNR")+cLOCAL,"NNR_XCUSTO"))
		Endif
		SD3->D3_ITEMCTA := SB1->B1_ITEMCC
		SD3->D3_CLVL    := SB1->B1_CLVL
		SD3->D3_STSERV  := "1"
		SD3->D3_GARANTI := "N"
		SD3->D3_CUSTO1  := nCUSTO1
		SD3->D3_XSETOR  := cXSETOR
		SD3->D3_XINVENT := cXINVENT
		SD3->D3_XCONSIG := cXCONSIG
		SD3->D3_XFORN   := cXFORN
		SD3->D3_XLJFOR  := cXLJFOR
		SD3->D3_XHORMOV := cXHORMOV
		SD3->D3_XID     := cID
		SD3->D3_XIDEXT  := cXIDEXT
		SD3->D3_XNOTA   := cXNOTA
		SD3->D3_XSERIE  := cXSERIE
		SD3->D3_XFILORI := cFILORIG
		SD3->D3_XFILDES := cFILDEST
		SD3->D3_TEATF   := SF5->F5_TEATF
		//SD3->D3_XDESCTM := SF5->F5_TEXTO

		SD3->D3_SEQCALC := DTOS(FIRSTDATE(dEMISSAO))+RIGHT(GETSXENUM("SD3","D3_SEQCALC") ,6)

		SD3->(MsUnlock())

		If cXINVENT == "S"
			DBSelectArea("SB7")
			DBOrderNickName('FSWSB701')  //B7_FILIAL+B7_XID
			IF !DBSeek(xFilial("SB7")+SD3->D3_XIDEXT)
				RecLock("SB7",.T.)
				SB7->B7_FILIAL := xFilial("SB7")
				SB7->B7_XID    := SD3->D3_XIDEXT
			Else
				RecLock("SB7",.F.)
			Endif
			SB7->B7_DATA    := dEMISSAO
			SB7->B7_STATUS  := "2"
			SB7->B7_DOC     := cDOC
			SB7->B7_COD     := cCOD
			SB7->B7_LOCAL   := cLOCAL
			SB7->B7_TIPO    := SB1->B1_TIPO
			SB7->B7_QUANT   := nSALDO
			SB7->B7_QTSEGUM := ConvUm(SB7->B7_COD,SB7->B7_QUANT,0,2)
			SB7->(MsUnlock())
		Endif

		If cXCONSIG == "S"
			IF Empty(cXFORN)
				cRetorno:= "ERRO| Codigo do fornecedor não informado."
				DisarmTransaction()
				Break
			Endif
			IF Empty(cXLJFOR)
				cRetorno:= "ERRO| Codigo da loja do fornecedor não informado."
				DisarmTransaction()
				Break
			Endif
			cTMCons := IIF(SD3->D3_TM >= "500", "E", "S")
			If !U_F0703504(cLOCAL,cCOD,cXFORN,cXLJFOR,nCUSTO1,nQUANT,cTMCons)
				cRetorno:= "ERRO| Não conseguiu atualizar a tabela P18."
				DisarmTransaction()
				Break
			EndIf
		EndIf

	End Transaction

	If ValType(bBlock) != "U"
		ErrorBlock(bBlock)
		If !Empty(cErrorL)
			cRetorno := "ERRO DE PROGRAMACAO | " + CRLF + cErrorL
		EndIf
	EndIf

	If !ExistIDExt(cXIDEXT)
		cRetorno := "ERRO| O movimento não foi gravado na base do Protheus!"
	EndIf

Return cRetorno

/*{Protheus.doc} DeleteMovInt
*/
Static Function DeleteMovInt(cChaveD3)

	Local cRetorno  := 'OK'
	Local nRegLog   := 0
	Local cLOCAL    := ''
	Local cCOD 	    := ''
	Local nCUSTO1   := ''
	Local nQUANT    := ''
	Local cXINVENT  := ''
	Local cXCONSIG  := ''
	Local cXFORN    := ''
	Local cXLJFOR   := ''
	Local cXIDEXT 	:= ''
	Local cTMCons   := ''
	Local dDataFec  := GetNewPar("MV_ULMES","")
	Local bBlock

	Private cErrorL			:= ""
	Private lAutoErrNoFile 	:= .T.
	Private dDtValExec      := CToD("  /  /    ")

	SB1->(DBSetOrder(1)) //B1_FILIAL+B1_COD

	bBlock 	:= ErrorBlock({|e|ChkErr(e)})

	Begin Transaction

		SD3->(DBOrderNickName('FSWSD301')) //D3_FILIAL+D3_XIDEXT
		If SD3->(DbSeek(cChaveD3))
			While SD3->(!Eof()) .And. cChaveD3 == SD3->D3_FILIAL+SD3->D3_XIDEXT

				cCOD     := SD3->D3_COD
				cLOCAL   := SD3->D3_LOCAL
				cXFORN   := SD3->D3_XFORN
				cXLJFOR  := SD3->D3_XLJFOR
				nCUSTO1  := SD3->D3_CUSTO1
				nQUANT   := SD3->D3_QUANT
				cXINVENT := SD3->D3_XINVENT
				cXCONSIG := SD3->D3_XCONSIG
				cXIDEXT  := SD3->D3_XIDEXT
				dEMISSAO := SD3->D3_EMISSAO
				cTMCons  := IIF(SD3->D3_TM >= "500", "S", "E")

				//Valida se as rotinas externas podem prosseguir com a execução.
				dDtValExec := dEMISSAO
				If !(U_F1303806())
					cErrorL := "Arquivo de semaforo em utilizacao. Nao eh possivel prosseguir com a rotina."
					DisarmTransaction()
					Break
				EndIf

				//Validar o calendário contábil
				//(dDtIni,dDtFim  ,nMoedas,cQualMoeda,lShowMsg,cTpSaldo)
				IF CtVlDTMoed(dEMISSAO,dEMISSAO,2     ,"01"      ,.F.     ,"1")
					cErrorL := "ERRO| Bloqueio por calendario contabil. Nao eh possivel prosseguir com a rotina."
					DisarmTransaction()
					Break
				Endif

				//Validar o processo contábil
				IF !CtbValiDt(Nil,dEMISSAO,,Nil ,Nil ,{"EST001"})
					cErrorL := "ERRO| Bloqueio por processo contabil (EST001). Nao eh possivel prosseguir com a rotina."
					DisarmTransaction()
					Break
				Endif

				// Validar fechamento de estoque
				IF dDataFec >= dEMISSAO
					cErrorL := "ERRO| Bloqueio por data de fechamento de estoque (MV_ULMES). Nao eh possivel prosseguir com a rotina."
					DisarmTransaction()
					Break
				Endif

				//Valida se o produto está bloqueado no cadastro de produto.
				SB1->(DBSeek(xFilial("SB1")+cCOD))
				IF SB1->B1_MSBLQL == "1"
					cErrorL := "ERRO| Produto com bloqueio no cadastro do produto (B1_MSBLQL). Nao eh possivel prosseguir com a rotina."
					DisarmTransaction()
					Break
				Endif

				RecLock("SD3",.F.)
				SD3->(DBDelete())
				SD3->(MsUnlock())

				If cXINVENT == "S"
					DBSelectArea("SB7")
					DBOrderNickName('FSWSB701') //B7_FILIAL+B7_XID
					IF DBSeek(xFilial("SB7")+cXIDEXT)
						RecLock("SB7",.F.)
						DBDelete()
						MsUnlock()
					Endif
				EndIf

				If cXCONSIG == "S"
					IF Empty(cXFORN)
						cErrorL := "ERRO| Codigo do fornecedor não informado."
						DisarmTransaction()
						Break
					Endif
					IF Empty(cXLJFOR)
						cErrorL := "ERRO| Codigo da loja do fornecedor não informado."
						DisarmTransaction()
						Break
					Endif
					If !U_F0703504(cLOCAL,cCOD,cXFORN,cXLJFOR,nCUSTO1,nQUANT,cTMCons)
						cErrorL := "ERRO| Não conseguiu atualizar a tabela P18."
						DisarmTransaction()
						Break
					EndIf
				EndIf

				SD3->(DbSkip())

			Enddo
		EndIf

	End Transaction

	ErrorBlock(bBlock)

	If !Empty(cErrorL)
		cRetorno := "ERRO DE PROGRAMACAO | " + CRLF + cErrorL
	EndIf

Return cRetorno


/*{Protheus.doc} ChkErr
*/
Static Function ChkErr(oErroArq)

	Local nI:= 0

	If oErroArq:GenCode > 0
		cErrorL := '(' + Alltrim(Str(oErroArq:GenCode)) + ') : ' + AllTrim(oErroArq:Description) + CRLF
	EndIf

	nI := 2

	While (!Empty(ProcName(ni)))
		cErrorL += Trim(ProcName(ni)) + "(" + Alltrim(Str(ProcLine(ni))) + ") " + CRLF
		ni ++
	Enddo

/*	Desabilitado porque não estava retornando a mensagem de erro. A função DisarmTransaction foi colocada na linha 129.
	If InTransaction()
		c'	ErrorL +="Transacao aberta desarmada"
		DisarmTransaction()
	EndIf
*/	
	Break

Return

/*{Protheus.doc} ExistIDExt
Busca registros a partir do ID externo e verifica se não está extornado.
Mantem posicionado caso encontrado.
@author Alex Sandro Valario
@since 06/02/2017
@Project MAN0000007423041_EF_035
@return  lExist
*/
Static Function ExistIDExt(cXIDEXT)

	Local lExist    := .F.
	Local nRecnoSD3 := 0
	Local cChaveD3  := SD3->(xFilial('SD3')) + PADR(Alltrim(cXIDEXT),TamSx3('D3_XIDEXT')[1])

	SD3->(DBOrderNickName('FSWSD301')) //D3_FILIAL+D3_XIDEXT
	If SD3->(DbSeek(cChaveD3))
		While SD3->(!Eof()) .And. cChaveD3 == SD3->D3_FILIAL+SD3->D3_XIDEXT
			If SD3->D3_ESTORNO=="S"
				lExist    := .F.
			Else
				lExist    := .T.
				nRecnoSD3 := SD3->(RecNo())
			EndIf
			SD3->(DbSkip())
		End
	EndIf

	If lExist
		SD3->(DbGoTo(nRecnoSD3))
	EndIf

Return lExist


Static Function _ProxNum(lSave,lShowFinal)
	Local cAliasNum      := Alias()
	Local lFalhou
	Local cTexto         := STR0125 //"O parametro MV_DOCSEQ nao foi conseguiu ser travado. O numero sequencial do movimento sera "
	Local nTentativas    := 0
	Local nTam           := TamSx3("D3_NUMSEQ")[1]
	Local cNumSeq        := Replicate("0",nTam)
	Local cLockKey       := 'MV_DOCSEQ_' +cEmpAnt+cFilAnt //+cFilAnt
	Local nTotTentativas := 120000 //- numero de tentativa para pegar o SX6
	Local nWaitTime      := 275 //- tempo em milesegundos

//- valida se é diferente as empresas
	If !( __cEmpFilOld == cEmpAnt+cFilAnt )
		__lChkNum    := .F.//- RESETA A CHEQUESEQ
		__cEmpFilOld := cEmpAnt+cFilAnt
	EndIF

	IF lxProxNum == Nil
		lxProxNum := ExistBlock("XPROXNUM")
	Endif
	IF lxProxNum
		cNumSeq := ExecBlock("xProxNum",.f.,.f.)
		If ValType(cNumSeq) == "C"
			Return cNumSeq
		EndIf
	Endif

	If ValType(lShowFinal) != "L"
		lShowFinal := .T.
	Endif

	IF ValType(lSave) != "L"
		lSave := .t.
	Endif

	lFalhou := .T.

	IF lSave
		__lNoErro := nil

		//- garante que não haja outro processo
		While nTentativas <= nTotTentativas
			If LockByName(cLockKey,.F.,.F.,.F.)
				lFalhou := .F.
				Exit
			EndIf
			nTentativas++
			Sleep(nWaitTime)//- segura 1 segundo
		EndDo

		//- indica que não foi possivel exclusividade da chave
		If lFalhou
			If IsTelNet()
				VTAlert(cTexto+cNumSeq, STR0130) //"Prob. MV_DOCSEQ"
			Else
				MsgAlert(cTexto+cNumSeq)
			EndIf
			If !Empty(cAliasNum)
				DbSelectArea(cAliasNum)
			EndIf

			Return nil
		EndIf

		//- VALIDA apenas uma vez na chamada
		IF !__lChkNum
			_CheckSeque()
			__lChkNum := .T.
		Endif

		cNumSeq := Soma1(Substr(GETMV("MV_DOCSEQ"),1,nTam))

		//- efetua a gravação do valor da chave
		PutMV("MV_DOCSEQ",cNumSeq)

		IF lFProxNum == Nil
			lFProxNum := ExistBlock("FPROXNUM")
		Endif
		IF lFProxNum
			ExecBlock("FPROXNUM",.f.,.f.,cNumSeq)
		Endif

		//- Libera a chave para uso
		UnLockByName(cLockKey,.F.,.F.,.F.)
	Else
		//- pega o valor corrente, não podendo estar em CACHE
		cNumSeq := Soma1(Substr(GETMV("MV_DOCSEQ"),1,nTam))
	Endif

	If !Empty(cAliasNum)
		DbSelectArea(cAliasNum)
	EndIf

Return cNumSeq



Static Function _CheckSeque()
	Local cGreat  := Space(Len(Criavar("D1_NUMSEQ")))
	Local cText
	Local cAlias  := Alias()
	Local nTam    := TamSx3("D3_NUMSEQ")[1]
	Local cNumSeq := Replicate("0",nTam)
	Local cQuery   as Character
	Local aBindSeq as array

	Iif(lxProxNum == Nil,lxProxNum := ExistBlock("XPROXNUM"),lxProxNum)

	If lxProxNum
		__lNoErro := .t.
		Return
	EndIf

//- ENCONTRA O MAIS NUMSEQ ENTRE AS TABELAS
	cQuery := "SELECT MAX(NUMSEQ) NUMSEQ FROM ("
//- busca o maior do SD1
	cQuery += " SELECT MAX(D1_NUMSEQ) NUMSEQ FROM "
	cQuery += RetSqlName("SD1")
	cQuery += " WHERE D1_FILIAL = ? "
	cQuery += " AND D_E_L_E_T_ = ? "
	cQuery += " UNION ALL "
//- busca o maior do SD2
	cQuery += " SELECT MAX(D2_NUMSEQ) NUMSEQ FROM "
	cQuery += RetSqlName("SD2")
	cQuery += " WHERE D2_FILIAL = ? "
	cQuery += " AND D_E_L_E_T_ = ? "
	cQuery += " UNION ALL "
//- busca o maior do SD3
	cQuery += " SELECT MAX(D3_NUMSEQ) NUMSEQ FROM "
	cQuery += RetSqlName("SD3")
	cQuery += " WHERE D3_FILIAL = ? "
	cQuery += " AND D_E_L_E_T_ = ? "
	cQuery += " AND D3_EMISSAO >= ?"
	cQuery += ") MAIOR"
	cQuery := ChangeQuery(cQuery)

	aBindSeq := {}

	AAdd(aBindSeq,FWxFilial('SD1'))
	AAdd(aBindSeq,' ')
	AAdd(aBindSeq,FWxFilial('SD2'))
	AAdd(aBindSeq,' ')
	AAdd(aBindSeq,FWxFilial('SD3'))
	AAdd(aBindSeq,' ')
	AAdd(aBindSeq, "TO_CHAR(SYSDATE - INTERVAL '1' DAY, 'YYYYMMDD')")

	dbUseArea( .T., "TOPCONN", TcGenQry2(,,cQuery,aBindSeq), "_QPROXSEQ", .T., .T. )

	If _QPROXSEQ->(!Eof())
		cGreat := _QPROXSEQ->NUMSEQ
	EndIf

	_QPROXSEQ->(dbCloseArea())

	aSize(aBindSeq,0)
	aBindSeq := nil

	cNumSeq := Soma1(Substr(GETMV("MV_DOCSEQ"),1,nTam))

//- valida se o gravado nas tabelas é maior que a chave do MV_DOCSEQ
	If cGreat >= cNumSeq
		cText := STR0128+cGreat+"." //"Problema no conteudo do parametro MV_DOCSEQ. O valor correto deveria ser: " + cNext
		cNumSeq := Soma1(Substr(cGreat,1,nTam))
		PutMV("MV_DOCSEQ",cNumSeq)
	EndIf

	__lNoErro := .T.

	If !Empty(cAlias)
		dbSelectArea(cAlias)
	EndIf

Return Nil
