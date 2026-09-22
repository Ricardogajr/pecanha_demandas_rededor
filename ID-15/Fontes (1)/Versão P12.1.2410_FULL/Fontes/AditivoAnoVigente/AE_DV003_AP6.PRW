#INCLUDE "AE_DV003_AP6.ch"
#INCLUDE "Protheus.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³AE_DV003  ºAutor  ³Willy               º Data ³  09/06/02   º±±
±±           ³Inclusao da rotina de Reembolso          Data ³  05/09/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³  Encaminha e Libera o Colaborador para nova Viagem.        º±±
±±º          ³  Geração do Reembolso do Colaborador.                      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP7                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function AE_DV003()
	Local lVldLibViag := ExistBlock("CDVLIBVLD")
	Local lRetLib     := .T.

	Private oDlgLib
	Private lMSErroAuto := .F.

	ChkTemplate("CDV")                                                

	If lVldLibViag
		lRetLib := ExecBlock("CDVLIBVLD",.F.,.F.)
		If ValType(lRetLib) == "L"
			If !lRetLib
				Return
			EndIf
		EndIf
	EndIf

	If LHQ->LHQ_Flag == 'K'
		MsgInfo(STR0001, STR0002) //'Esta solicitação está cancelada e não poderá se encaminhada!'###'Atenção'
		Return
	EndIf

	If LHQ->LHQ_Flag == 'P'
		MsgInfo(STR0003 + CRLF + STR0004, STR0002) //'Prestação de contas em atraso.'###'Favor entrar em contato com o Depto. Financeiro para liberá-la através da rotina Lib.atraso.'###'Atenção'
		Return
	EndIf

	If !LHQ->LHQ_Flag $ 'LM'
		MsgInfo(STR0005, STR0002) //'Somente a Despesa Impressa e Encaminhada Poderá ser Concluida !'###'Atenção'
		Return
	EndIf

	If LHP->LHP_XESTIT == "S" .And. LHP->LHP_ADIANT .And. !(U_TemDesp())
		MsgInfo("Liberação não permitida! Solicitação de viagem com adiantamento pendente.", "Atenção") //'Somente a Despesa Impressa e Encaminhada Poderá ser Concluida !'###'Atenção'
		Return
	EndIf

	If MsgYESNO(STR0006+ LHQ->LHQ_Codigo +STR0007, STR0002) //'Esta rotina tem o objetivo de concluir e liberar o relatório de despesa numero: '###'. Deseja Liberar ?'###'Atenção'
		Pergunte("VIA003")
		Efetiva()
	Else
		Return
	EndIf

	Return

	*----------------------------------------------------------------------------------------
Static Function Efetiva()
	*----------------------------------------------------------------------------------------
	Local _aAreaLHP			:= GetArea()
	Local _nRow
	Local lGerTotal 		:= SuperGetMv("MV_TOTDESP",.F.,"2") == "1"
	Local aAreaSED			:= SED->(GetArea())
	Local lEstorna       := .F.
	Private aButtons
	Private _nVlTotGasto	:= 0
	Private _nVlReembolso	:= 0
	Private _nVlDiferenca   := 0
	Private _ConCC			:= GetMv("MV_CCCDV")
	Private _cProcesso
	Private _nValTotR		:= 0
	Private _nValTotU		:= 0
	Private _nValorR		:= 0
	Private _nValorU		:= 0
	Private _nValorAnt		:= 0
	Private _cCodForne
	Private _cCodLojaF
	Private _cPrefixoR      := _cPrefixoR:= AllTrim(GetMV('MV_PREREEM'))
	Private _cParcelaR
	Private _cParcelaR02	:= StrZero(0,TamSX3("E2_PARCELA")[1])
	Private _cTipoR         := AllTrim(GetMV('MV_TIPREEM'))
	Private _cCCSpace
	Private _cNaturez		:= Space(TamSX3("ED_CODIGO")[1])
	Private lGeraReem		:= .F.
	Private _nVlAntU		:= 0
	Private _dVencRea       := DataValida(dDataBase+1)

	dbSelectArea('LHP')
	LHP->(dbSetOrder(1))
	If LHP->(MsSeek(xFilial('LHP') + LHQ->LHQ_Codigo))
		//Valores totais
		_nValTotR := LHQ->LHQ_ValRB + LHQ->LHQ_CPMF
		_nValTotU := LHQ->LHQ_ValRBD
		//Valores de reembolso
		_nVlReembolso := LHQ->(LHQ_ValRB + LHQ_CPMF)
		_nVlDiferenca := LHP->LHP_VALORR - (LHQ->(LHQ_ValRB + LHQ_CPMF))
		_nValorU := LHP->LHP_VALORU - LHQ->LHQ_ValRBD                                                     
		//Se o valor for negativo, indica que a despesa foi superior ao adiantamento
		If (LHP->LHP_VALORR - (LHQ->(LHQ_ValRB + LHQ_CPMF))) > 0 .OR. (LHP->LHP_VALORU - LHQ->LHQ_ValRBD) > 0
			lGeraReem := .T.
		Endif
		If _nVlDiferenca > 0 .And. !lGerTotal .AND. .F.
			RecLock('LHP',.F.)
			If Empty(LHQ->LHQ_SAIDA)
				LHP->LHP_FLAG  := 'B'
				LHP->LHP_FLAG1 := 'B'
			Else
				LHP->LHP_FLAG  := 'C'
				LHP->LHP_FLAG1 := 'C'
			EndIf
			MsUnLock('LHP')

			RecLock('LHQ',.F.)
			If Empty(LHQ->LHQ_SAIDA)
				LHQ->LHQ_Flag	:= 'B'
				LHQ->LHQ_DFECHA := dDatabase
			Else
				LHQ->LHQ_Flag	:= 'C'
				LHQ->LHQ_DFECHA := dDatabase
			EndIf
			MsUnLock('LHQ')
			Return
		EndIf

		aButtons := {}
		AaDd(aButtons, {"ALTERA", {|| CadForn()}, STR0009 }) //"ALTERA"###"Colaboradores em Fornecedores"

		lEstorna := CDVTipDesp(LHQ->LHQ_CODIGO)

		DEFINE MSDIALOG oPrincipal FROM  000,000 TO 385,610 TITLE OemToAnsi(STR0010) PIXEL //'Departamento de Viagens'

		_cNaturez:= Pad(SuperGetMV("MV_U_NATUR",.F.,""),Len(_cNaturez)) // alterado tadeu
		//Caso a natureza nao exista, ignorar o conteudo do parametro
		If Empty(_cNaturez) .OR. Empty(Posicione("SED",1,xFilial("SED")+AllTrim(_cNaturez),"ED_CODIGO"))
			_cNaturez := Space(TamSX3("ED_CODIGO")[1])
		Endif			
		_cCC	 := LHP->LHP_CC

		_nRow := 33
		@ _nRow,008 SAY STR0011 OF oPrincipal PIXEL //'Dados da Solicitação de Viagem'
		@ _nRow+6,003 TO _nRow+85,304 OF oPrincipal PIXEL

		_cProcesso := LHP->LHP_Codigo
		_nRow+=14
		@ _nRow,008 SAY STR0012 OF oPrincipal PIXEL //'Código da Solicitação de Viagem'
		@ _nRow,090 MSGET _cProcesso Picture '999999' SIZE 30,07 OF oPrincipal PIXEL When .F.

		_nValorR := IIf(_nVlDiferenca <= 0, _nVlDiferenca * (-1), _nVlDiferenca)
		_nValorAnt := _nValorR
		_nValorU := IIf(_nValorU < 0, _nValorU * (-1), _nValorU)
		_nVlAntU := _nValorU

		@ _nRow,137 SAY STR0013 + " " + GetMv("MV_SIMB1") OF oPrincipal PIXEL //'Valor R$'
		@ _nRow,165 MSGET If(lGerTotal.Or.lGeraReem,_nValTotR,_nValorR) Picture '@E 999,999.99' When .F. Size 40,07 OF oPrincipal PIXEL
		@ _nRow,222 SAY STR0014 + " " + GetMv("MV_SIMB2") OF oPrincipal PIXEL //'Valor US$'
		@ _nRow,255 MSGET If(lGerTotal.Or.lGeraReem,_nValTotU,_nValorU) Picture '@E 999,999.99' When .F. Size 40,06  OF oPrincipal PIXEL

		_nRow+=15
		_dEmissao := dDataBase
		@ _nRow,008 SAY STR0015 OF oPrincipal PIXEL //'Data da Emissão'
		@ _nRow,055 MSGET _dEmissao Picture '@D' Size 35,07 OF oPrincipal PIXEL When .F.

		@ _nRow,98 SAY 'CC' OF oPrincipal PIXEL
		@ _nRow,117 MSGET _cCC  Picture '@!' Size 58,07 OF oPrincipal PIXEL Valid VCC() F3(_ConCC) When .F.

		_dSaida   := LHP->LHP_Saida
		_dChegada := LHP->LHP_Chegad
		@ _nRow,195 SAY STR0016 OF oPrincipal PIXEL //'Período'
		@ _nRow,258 SAY STR0017 OF oPrincipal PIXEL //'à'
		@ _nRow,220 MSGET _dSaida   Picture '@D' Size 35,07  OF oPrincipal PIXEL When .F.
		@ _nRow,265 MSGET _dChegada Picture '@D' Size 35,07 OF oPrincipal PIXEL When .F.

		_nRow+=15
		_cFunc	:= LHP->LHP_Func
		_cNFunc := LHP->LHP_NFunc
		dbSelectArea('LHT')
		LHT->(dbSetOrder(1))
		LHT->(MsSeek(xFilial('LHT') + _cFunc))
		_cUsLogin := AllTrim(LHT->LHT_Login)

		@ _nRow,008 SAY STR0018 OF oPrincipal PIXEL //'Colaborador'
		@ _nRow,097 SAY STR0019 OF oPrincipal PIXEL //'Nome'
		@ _nRow,055 MSGET _cFunc  Picture '@!' Size 35,07 OF oPrincipal PIXEL When .F.
		@ _nRow,117 MSGET _cNFunc Picture '@!' Size 183,07 OF oPrincipal PIXEL When .F.

		_nRow+=13
		_cSupImd  := LHP->LHP_SupImd
		dbSelectArea('LHT')
		LHT->(dbSetOrder(1))
		LHT->(MsSeek(xFilial('LHT') + _cSupImd))
		_cNSupImd := LHT->LHT_Nome

		@ _nRow,008 SAY STR0020 OF oPrincipal PIXEL //'Aprovador I     '
		@ _nRow,097 SAY STR0019 OF oPrincipal PIXEL //'Nome'
		@ _nRow,055 MSGET _cSupImd  Picture '@!' Size 35,07 OF oPrincipal PIXEL When .F.
		@ _nRow,117 MSGET _cNSupImd Picture '@!' Size 170,07 OF oPrincipal PIXEL When .F.

		_nRow+=13
		_cDGRar  := LHP->LHP_DGRar
		dbSelectArea('LHT')
		LHT->(dbSetOrder(1))
		LHT->(MsSeek(xFilial('LHT') + _cDGRar))
		_cNDGRar := LHT->LHT_Nome
		@ _nRow,008 SAY STR0021 OF oPrincipal PIXEL //'Aprovador II'
		@ _nRow,097 SAY STR0019 OF oPrincipal PIXEL //'Nome'
		@ _nRow,055 MSGET _cDGRar  Picture '@!' Size 35,07 OF oPrincipal PIXEL When .F.
		@ _nRow,117 MSGET _cNDGRar Picture '@!' Size 170,07 OF oPrincipal PIXEL When .F.

		If !lEstorna
			_nRow+=25
			@ _nRow,008 SAY STR0022 OF oPrincipal PIXEL //'Dados do Título a Pagar'
			@ _nRow+6,003 To _nRow+60,304 OF oPrincipal PIXEL

			_nRow+=16
			_cPrefixoR:= AllTrim(GetMV('MV_PREREEM'))
			@ _nRow,008 SAY STR0023 OF oPrincipal PIXEL //'Prefixo'
			@ _nRow,032 MSGET _cPrefixoR Picture '@!' Size 30,07 OF oPrincipal PIXEL When .F.

			@ _nRow,070 SAY STR0024 OF oPrincipal PIXEL //'Número'
			@ _nRow,095 MSGET _oProcesso VAR _cProcesso Picture '@!' When .F. Size 30,07 OF oPrincipal PIXEL
			_oProcesso:Refresh()

			_cParcelaR := AllTrim(GetMV('MV_PARREEM'))
			@ _nRow,135 SAY STR0025 OF oPrincipal PIXEL //'Parcela'
			@ _nRow,158 MSGET _cParcelaR  Picture '@!' Size 20,07 OF oPrincipal PIXEL  //When .F.

			_cTipoR := AllTrim(GetMV('MV_TIPREEM'))
			@ _nRow,187 SAY STR0026 OF oPrincipal PIXEL //'Tipo'
			@ _nRow,202 MSGET _cTipoR  Picture '@!' Size 20,07 When .F. OF oPrincipal PIXEL

			_dVencRea := DataValida(dDataBase+1)
			@ _nRow,235 SAY STR0027 OF oPrincipal PIXEL //'Vencimento'
			@ _nRow,265 MSGET _dVencRea Picture '@D' Size 35,07 OF oPrincipal PIXEL
		EndIf			

		aAreaSA2 := SA2->(GetArea())
		DbSelectArea('SA2')
		DbSetOrder(12) //A2_FILIAL+A2_MAT
		If MsSeek(xFilial('SA2') + LHP->LHP_Func)
			_cBanco  := SA2->A2_Banco
			_cAgenci := SA2->A2_Agencia
			_cConta  := SA2->A2_Numcon
		Else
			_cBanco  := LHP->LHP_Banco
			_cAgenci := LHP->LHP_Agenci
			_cConta  := LHP->LHP_Conta
		EndIf

		RestArea(aAreaSED)
		RestArea(aAreaSA2)

		If !lEstorna		
			_nRow+=13
			@ _nRow,008 SAY STR0028 OF oPrincipal PIXEL //'Banco'
			@ _nRow,032 MSGET _cBanco Picture '@!' When .F. Size 15,07 OF oPrincipal PIXEL
			@ _nRow,070 SAY STR0029 OF oPrincipal PIXEL //'Agencia'
			@ _nRow,095 MSGET _cAgenci Picture '@!' When .F. Size 20,07 OF oPrincipal PIXEL
			@ _nRow,135 SAY STR0030 OF oPrincipal PIXEL //'Conta'
			@ _nRow,158 MSGET _cConta Picture '@!' When .F. Size 40,07 OF oPrincipal PIXEL

			_nRow+=13
			@ _nRow,008 SAY STR0031 OF oPrincipal PIXEL //'Natureza'
			@ _nRow,032 MSGET _cNaturez Picture '@!' Size 50,07 Valid VNATUREZ() F3('SED') OF oPrincipal PIXEL
			@ _nRow,087 SAY 'CC' OF oPrincipal PIXEL
			@ _nRow,097 MSGET _cCC  Picture '@!' Size 58,07 Valid VCC() F3(_ConCC) OF oPrincipal PIXEL
			@ _nRow,158 SAY STR0013 + " " + GetMv("MV_SIMB1") OF oPrincipal PIXEL //'Valor R$'
			@ _nRow,181 MSGET If(lGerTotal.Or.lGeraReem,_nValTotR,_nValorR) Picture '@E 999,999.99' When .F. Size 40,07 OF oPrincipal PIXEL
			@ _nRow,226 SAY STR0032 + " " + GetMv("MV_SIMB2") OF oPrincipal PIXEL //'Valor U$'
			@ _nRow,252 MSGET If(lGerTotal.Or.lGeraReem,_nValTotU,_nValorU) Picture '@E 999,999.99' When .F. Size 40,07 OF oPrincipal PIXEL	
		EndIf

		ACTIVATE MSDIALOG oPrincipal CENTERED ON INIT EnchoiceBar(oPrincipal, {|| GReembolso()}, {|| oPrincipal:End()},,aButtons)

	Else
		MsgInfo(STR0033) //'Processo Cancelado, Solicitação não Localizada !'
		Return
	EndIf

	RestArea(_aAreaLHP)

	Return

	*----------------------------------------------------------------------------------------
Static Function GReembolso()
	*----------------------------------------------------------------------------------------
	Local aArea			:= GetArea()
	Local _aAreaSE2W
	Local _cE2HIST
	Local aAreaSA2		:= SA2->(GetArea())
	Local lGerTotal		:= SuperGetMv("MV_TOTDESP",,"2") == "1"
	Local aBaixa		:= {}
	Local cChaveSE2		:= ""
	Local lAutCmpRA		:= SuperGetMV("MV_AUTCPPA",.F.,.F.)
	Local nTotalPA		:= 0
	Local nPARecno		:= 0
	Local nCMPRecno		:= 0
	Local nSaldo		:= 0
	Local cHistPA		:= ""
	Local aChaveSE2		:= {"E2_FILIAL","E2_PREFIXO","E2_NUM","E2_PARCELA","E2_TIPO","E2_FORNECE","E2_LOJA"}
	Local aTamChave		:= {}
	Local nTamChave		:= 0                                            
	Local ni			:= 0         
	Local lGeraRU		:= {.F.,.F.}	//Indica se foi gerado titulo em Reais e em Dolares     
	Local lContab     := Iif(mv_par01 == 1,.T.,.F.)
	Local lAglut      := Iif(mv_par02 == 1,.T.,.F.)
	Local lEstorna    := .F.

	If lGerTotal .Or. lGeraReem
		_nValorR := _nValTotR
		_nValorU := _nValTotU
	EndIf                    

	aEval(aChaveSE2,{|x|nTamChave += TamSX3(x)[1]})
	For ni := 1 to Len(aChaveSE2)
		aAdd(aTamChave,TamSX3(aChaveSE2[ni])[1])
	Next ni
	//Se o valor for negativo, indica que a despesa foi superior ao adiantamento
	If (LHP->LHP_VALORR - (_nValTotR + (_nValorR - _nValorAnt))) < 0 .OR. (LHP->LHP_VALORU - (_nValTotU + (_nValorU - _nVlAntU))) < 0
		lGeraReem := .T.
	Else
		lGeraReem := .F.
	Endif
	//Caso a compensacao automatica esteja definida, processar o reembolso para poder utilizar a compensacao que deixara saldo para o PA, indicando
	//saldo que o viajante tem a devolver
	If !lGeraReem .AND. lAutCmpRA
		lGeraReem := .T.
	Endif

	lEstorna := CDVTipDesp(LHQ->LHQ_CODIGO)

	If lEstorna
		cMsg := STR0064
	Else
		cMsg := STR0034 + IIf(lGerTotal,STR0035,STR0036) + STR0037 //"Deseja gerar Título, com o valor"###" do total dos Gastos (Incluido CPMF) "###" do Reembolso "###"para o Colaborador ?"
	EndIf

	If GetMV('MV_GERAFIN') .AND. lGeraReem
		If MsgYESNO(cMsg,STR0038)
			dbSelectArea('SA2')
			SA2->(DbOrderNickName("SA2CDV6")) //A2_FILIAL+A2_MAT
			If !SA2->(MsSeek(xFilial('SA2') + LHP->LHP_Func))
				If MsgYesNo(STR0039,STR0040) //'Colaborador não está Cadastrado como Fornecedor, Deseja Cadastrar ?'###'Dados Incompletos'
					CadForn()
					If !SA2->(MsSeek(xFilial('SA2') + LHP->LHP_Func))
						Return
					EndIf
				Else
					Return
				EndIf
			EndIf

			dbSelectArea('SA2')
			SA2->(DbOrderNickName("SA2CDV6")) //A2_FILIAL+A2_MAT
			If MsSeek(xFilial('SA2') + LHP->LHP_Func)
				_cCodForne:= SA2->A2_COD
				_cCodLojaF:= SA2->A2_LOJA
				_cBanco   := SA2->A2_BANCO
			Else
				MsgInfo(STR0041,STR0040) //'Colaborador não está Cadastrado como Fornecedor !'###'Dados Incompletos'
				Return(Nil)
			EndIf
			_cE2HIST := STR0042 + _cProcesso //"Solicitacao n. "
			If _nValorAnt <> _nValorR .And. !lGerTotal .And. !lGeraReem
				IF MsgYESNO(STR0043, STR0038) //'O Valor do Reembolso (R$) foi Alterado, deseja manter o Valor Atual ?'###"Atenção"
					_cE2HIST := STR0044 + _cProcesso //'Vlr Reemb. Alter.-'
				Else
					_nValorR := _nValorAnt
				Endif
			EndIf            
			If _nVlAntU <> _nValorU .And. !lGerTotal
				IF MsgYESNO(STR0045, STR0038) //'O Valor do Reembolso (U$) foi Alterado, deseja manter o Valor Atual ?'###"Atenção"
					_cE2HIST:= STR0044 + _cProcesso //'Vlr Reemb. Alter.-'
				Else
					_nValorU := _nVlAntU
				Endif
			EndIf            		
			RestArea(aAreaSA2)  

			dbSelectArea("LHP")
			LHP->(dbSetOrder(1))
			If LHP->(MsSeek(xFilial("LHP") + _cProcesso))
				_aAreaSE2W:= GetArea()
				dbSelectArea("SE2")
				SE2->(dbSetOrder(6))
				If SE2->(MsSeek(xFilial("SE2")+PadR(_cCodForne,TamSX3("E2_FORNECE")[1])+PadR(_cCodLojaF,TamSX3("E2_LOJA")[1])+PadR(_cPrefixoR,TamSX3("E2_PREFIXO")[1])+PadR(_cProcesso,TamSX3("E2_NUM")[1])+PadR(_cParcelaR,TamSX3("E2_PARCELA")[1])+PadR(_cTipoR,TamSX3("E2_TIPO")[1])))
					MsgInfo(STR0046, STR0047) //'Existe Título no Contas a Pagar, com estes Dados! Informe Outro Código.'###'Dados Incorretos'
					RestArea(_aAreaSE2W)
					Return
				EndIf
				RestArea(_aAreaSE2W)
			EndIf

			Begin Transaction
				RecLock("LHP",.F.)
				If Empty(LHQ->LHQ_SAIDA)
					LHP->LHP_FLAG  := 'B'
					LHP->LHP_FLAG1 := 'B'
				Else
					LHP->LHP_FLAG  := 'C'
					LHP->LHP_FLAG1 := 'C'
				EndIf
				If LHP->LHP_XESTIT == "S"
					LHP->LHP_XESTIT := " "
				EndIf
				LHP->LHP_DOCUME	:= (xFilial("SE2") + ;
				PadR(_cPrefixoR,TamSX3("E2_PREFIXO")[1]) + ;
				PadR(_cProcesso,TamSX3("E2_NUM")[1]) + ;
				PadR(_cParcelaR,TamSX3("E2_PARCELA")[1]) + ;
				PadR(_cTipoR,TamSX3("E2_TIPO")[1]) + ;
				PadR(_cCodForne,TamSX3("E2_FORNECE")[1]) + ;
				PadR(_cCodLojaF,TamSX3("E2_LOJA")[1]))
				MsUnLock("LHP")

				RecLock("LHQ",.F.)
				If Empty(LHQ->LHQ_SAIDA)
					LHQ->LHQ_Flag	:= 'B'
					LHQ->LHQ_DFECHA := dDatabase
				Else
					LHQ->LHQ_Flag	:= 'C'
					LHQ->LHQ_DFECHA := dDatabase
				EndIf
				MsUnLock("LHQ")

				//Viagem nacional		
				If _nValorR > 0	 .OR. (lAutCmpRA .AND. _nValorR != 0 .AND. (!LHP->LHP_EINTER .OR. _nValTotR > 0)) //Se houver valor de reembolso OU compensacao nao intern. / intern. c/ val. Reais
					If lAutCmpRA
						If LHP->(FieldPos("LHP_DOCUME")) # 0
							If !Empty(LHP->LHP_DOCUME) 
								cChaveSE2 := Substr(LHP->LHP_DOCUME,1,nTamChave)
							Endif
						Endif
						If Empty(cChaveSE2)
							cChaveSE2 := xFilial("SE2") + AllTrim(SuperGetMV("MV_PREADIA",.F.,Space(TamSX3("E2_PREFIXO")[1]))) 
							cChaveSE2 += PadR(LHP->LHP_CODIGO,TamSX3("E2_NUM")[1]) + AllTrim(SuperGetMV("MV_PARADIA",.F.,Space(TamSX3("E2_PARCELA")[1]))) 
							cChaveSE2 += AllTrim(SuperGetMV("MV_TIPADIA",.F.,Space(TamSX3("E2_TIPO")[1]))) 
							cChaveSE2 += _cCodForne + _cCodLojaF				
						Endif
						dbSelectArea("SE2")
						SE2->(dbSetOrder(1))
						If SE2->(dbSeek(cChaveSE2))
							nTotalPA := SE2->E2_SALDO
							nPARecno := SE2->(Recno())
							If nTotalPA > LHQ->LHQ_VALRB	//Valor a dever, registrar no titulo apenas o quanto foi gasto
								nSaldo := LHQ->LHQ_VALRB
							Else                   			//Valor a receber, registrar no titulo o valor do reembolso + valor do pa (para compensacao)
								nSaldo := nTotalPA + _nValorR
							Endif            
						Else 
							nSaldo := _nValorR
							lAutCmpRA := .F.	//Nao fazer a compensacao, pois o PA nao foi encontrado
						Endif
					Else
						nSaldo := _nValorR		
					Endif    			

					If nSaldo > 0
						aGrvSe2 := {{ "E2_FILIAL"	, LHP->LHP_FILIAL				, Nil },;
						{ "E2_CCUSTO"	, _cCC							, Nil },;
						{ "E2_PREFIXO"	, _cPrefixoR					, Nil },;
						{ "E2_NUM"		, _cProcesso					, Nil },;
						{ "E2_TIPO"		, _cTipoR						, Nil },;
						{ "E2_NATUREZ"	, _cNaturez						, Nil },;
						{ "E2_FORNECE"	, _cCodForne					, Nil },;
						{ "E2_LOJA"   	, _cCodLojaF					, Nil },;
						{ "E2_NOMFOR"	, LHP->LHP_NFUNC			 	, Nil },;
						{ "E2_EMISSAO"	, dDataBase						, Nil },;
						{ "E2_VENCTO"	, _dVencRea						, Nil },;
						{ "E2_VENCREA"	, _dVencRea						, Nil },;
						{ "E2_VALOR"  	, _nValorR						, Nil },;
						{ "E2_SALDO"  	, _nValorR						, Nil },;
						{ "E2_MOEDA"	, 1								, Nil },;
						{ "E2_VLCRUZ" 	, _nValorR						, Nil },;
						{ "E2_PARCELA"	, _cParcelaR					, Nil },;
						{ "E2_ORIGEM" 	, 'FINA050'						, Nil },;
						{ "E2_EMIS1" 	, dDataBase						, Nil },;
						{ "E2_VENCORI" 	, _dVencRea						, Nil },;
						{ "E2_RATEIO" 	, 'N'							, Nil },;
						{ "E2_OCORREN" 	, '01'							, Nil },;
						{ "E2_FLUXO" 	, 'S'							, Nil },;
						{ "E2_PORTADO" 	, _cBanco						, Nil },;    
						{ "E2_HIST"		, _cE2HIST						, Nil },;
						{ "E2_DESDOBR" 	, 'N'							, Nil } }

						If ExistBlock("AE_GRVSE2")
							aGrvSe2 := ExecBlock("AE_GRVSE2",.F., .F.,{_cProcesso,aGrvSe2})   
						EndIF
						MsExecAuto({| x,y,z | Fina050(x,y,z) }, aGrvSe2,, 3) // 3- Opcao de Inclusao
						If lMSErroAuto
							DisarmTransaction()                  
							MsgInfo(STR0048+CRLF+STR0049) //'Ocorreu um erro na gravação do Adiantamento.'###'Verifique a mensagem de erro e caso necessário abra um chamado no help desk para que esse erro seja corrigido.'
							If (!IsBlind()) // COM INTERFACE GRÁFICA
								MostraErro() // TELA
							Else // EM ESTADO DE JOB
								cError := MostraErro("/dirdoc", "error.log") // ARMAZENA A MENSAGEM DE ERRO

								ConOut(PadC("Automatic routine ended with error", 80))
								ConOut("Error: "+ cError)
							EndIf


							oPrincipal:End()  
							RestArea(aArea)
						break				
						Endif
					EndIf

					SE2->(DbSeek(xFilial("SE2")+Padr(_cPrefixoR,TamSX3("E2_PREFIXO")[1])+Padr(_cProcessoR,TamSX3("E2_NUM")[1])+Padr(_cParcelaR,TamSX3("E2_PARCELA")[1]);
					+Padr(_cTipoR,TamSX3("E2_TIPO")[1])+Padr(_cCodForne,TamSX3("E2_FORNECE")[1])+Padr(_cCodLojaF,TamSX3("E2_LOJA")[1])))
					nCMPRecno := SE2->(Recno())

					lGeraRU[1] := .T.
					//Caso a compensacao automatica esteja ativa
					If lAutCmpRA
						If nSaldo >= nTotalPA	//DP -> RA
							MaIntBxCP(2,{nCMPRecno},,{nPARecno},,{lContab,lAglut,.F.,.F.,.F.,.F.})
							cHistPA	:= STR0050 + _cProcesso //"CDV-COMP.TOT.PROC."
						ElseIf nSaldo > 0  					//RA -> DP
							MaIntBxCP(2,{nCMPRecno},,{nPARecno},,{lContab,lAglut,.F.,.F.,.F.,.F.})
							cHistPA	:= STR0051 + _cProcesso //"CDV-COMP.PARC.PROC."
						Endif
						//Gravar o historico de compensacao no PA que foi compensado
						If nSaldo > 0
							SE2->(dbGoto(nPARecno))
							Reclock("SE2",.F.,.T.)
							SE2->E2_HIST := Substr(AllTrim(cHistPA),1,TamSX3("E2_HIST")[1])
							MsUnlock()
						ElseIf lEstorna
							EstornaPA(cChaveSE2,_cBanco,_cAgenci,_cConta)
						EndIf
					Endif
				EndIf
				If LHP->LHP_EINTER //Viagem internacional
					If _nValorU > 0 .OR. ( lAutCmpRA .And. _nValorU != 0 )
						If lAutCmpRA
							If LHP->(FieldPos("LHP_DOCUME")) # 0
								If !Empty(LHP->LHP_DOCUME) 
									If At(",",LHP->LHP_DOCUME) == 0
										cChaveSE2 := RTrim(LHP->LHP_DOCUME)
									Else                                       
										//{"E2_FILIAL","E2_PREFIXO","E2_NUM","E2_PARCELA","E2_TIPO","E2_FORNECE","E2_LOJA"}
										cChaveSE2 := Substr(LHP->LHP_DOCUME,1,aTamChave[1]+aTamChave[2]+aTamChave[3])
										cChaveSE2 += Substr(LHP->LHP_DOCUME,At(",",LHP->LHP_DOCUME)+1,aTamChave[4])
										cChaveSE2 += Substr(LHP->LHP_DOCUME,aTamChave[1]+aTamChave[2]+aTamChave[3]+aTamChave[4]+1,aTamChave[5]+aTamChave[6]+aTamChave[7])
									Endif
								Endif
							Endif
							If Empty(cChaveSE2)
								cChaveSE2 := xFilial("SE2") + AllTrim(SuperGetMV("MV_PREADIA",.F.,Space(TamSX3("E2_PREFIXO")[1]))) 
								cChaveSE2 += PadR(LHP->LHP_CODIGO,TamSX3("E2_NUM")[1]) + AllTrim(SuperGetMV("MV_PARADIA",.F.,Space(TamSX3("E2_PARCELA")[1]))) 
								cChaveSE2 += AllTrim(SuperGetMV("MV_TIPADIA",.F.,Space(TamSX3("E2_TIPO")[1]))) 
								cChaveSE2 += _cCodForne + _cCodLojaF				
							Endif
							dbSelectArea("SE2")
							SE2->(dbSetOrder(1))
							If SE2->(dbSeek(cChaveSE2))
								nTotalPA := SE2->E2_SALDO
								nPARecno := SE2->(Recno())
								If nTotalPA > LHQ->LHQ_ValRBD	//Valor a dever, registrar no titulo apenas o quanto foi gasto
									nSaldo := LHQ->LHQ_ValRBD
								Else                   //Valor a receber, registrar no titulo o valor do reembolso + valor do pa (para compensacao)
									nSaldo := nTotalPA + _nValorU
								Endif            
							Else 
								nSaldo := _nValorU
								lAutCmpRA := .F.	//Nao fazer a compensacao, pois o PA nao foi encontrado
							Endif
						Else
							nSaldo := _nValorU
						Endif    					
						If lGeraRU[1] //Se foi gerado titulo em reais
							//Caso jah tenha sido gravado um titulo para valores em Reais, manter o mesmo processo e alterar apenas a parcela, para facilitar a rastreabilidade
							If Empty(_cParcelaR)
								_cParcelaR02 := Soma1(_cParcelaR02,Len(_cParcelaR02))
							Else                           
								_cParcelaR02 := Soma1(AllTrim(_cParcelaR),Len(_cParcelaR02))
							Endif
						Else
							_cParcelaR02 := _cParcelaR
						Endif

						If nSaldo > 0
							aGrvSe2 := {{ "E2_FILIAL"	, LHP->LHP_FILIAL				, Nil },;
							{ "E2_CCUSTO"	, _cCC							, Nil },;
							{ "E2_PREFIXO"	, _cPrefixoR					, Nil },;
							{ "E2_NUM"		, _cProcesso					, Nil },;
							{ "E2_TIPO"		, _cTipoR						, Nil },;
							{ "E2_NATUREZ"	, _cNaturez						, Nil },;
							{ "E2_FORNECE"	, _cCodForne					, Nil },;
							{ "E2_LOJA"   	, _cCodLojaF					, Nil },;
							{ "E2_NOMFOR"	, LHP->LHP_NFUNC			 	, Nil },;
							{ "E2_EMISSAO"	, dDataBase						, Nil },;
							{ "E2_VENCTO"	, _dVencRea						, Nil },;
							{ "E2_VENCREA"	, _dVencRea						, Nil },;
							{ "E2_VALOR"  	, _nValorU						, Nil },;
							{ "E2_SALDO"  	, _nValorU						, Nil },;
							{ "E2_MOEDA"	, 2								, Nil },;
							{ "E2_VLCRUZ" 	, xMoeda(nSaldo,2,1,dDataBase)	, Nil },;
							{ "E2_PARCELA"	, _cParcelaR02					, Nil },;
							{ "E2_ORIGEM" 	, 'FINA050'						, Nil },;
							{ "E2_EMIS1" 	, dDataBase						, Nil },;
							{ "E2_VENCORI" 	, _dVencRea						, Nil },;
							{ "E2_RATEIO" 	, 'N'							, Nil },;
							{ "E2_OCORREN" 	, '01'							, Nil },;
							{ "E2_FLUXO" 	, 'S'							, Nil },;
							{ "E2_PORTADO" 	, _cBanco						, Nil },;  
							{ "E2_HIST"		, _cE2HIST						, Nil },;
							{ "E2_DESDOBR" 	, 'N'							, Nil } }
							If ExistBlock("AGRVSE2_U")
								aGrvSe2 := ExecBlock("AGRVSE2_U",.F., .F.,{_cProcesso,aGrvSe2})   
							EndIF								
							MsExecAuto({ | x,y,z | Fina050(x,y,z) }, aGrvSe2,, 3) // 3- Opcao de Inclusao
							If lMSErroAuto
								DisarmTransaction()
								MsgInfo(STR0052+CRLF+STR0049) //'Ocorreu um erro na gravação do Contas a Pagar.'###'Verifique a mensagem de erro e caso necessário abra um chamado no help desk para que esse erro seja corrigido.'
								If (!IsBlind()) // COM INTERFACE GRÁFICA
									MostraErro() // TELA
								Else // EM ESTADO DE JOB
									cError := MostraErro("/dirdoc", "error.log") // ARMAZENA A MENSAGEM DE ERRO

									ConOut(PadC("Automatic routine ended with error", 80))
									ConOut("Error: "+ cError)
								EndIf


								oPrincipal:End()
								RestArea(aArea)
								break
							Endif
						EndIf

						nCMPRecno := SE2->(Recno())

						lGeraRU[2] := .T.
						//Caso a compensacao automatica esteja ativa, compensar o titulo gerado com o PA gerado anteriormente
						If lAutCmpRA
							If nSaldo > nTotalPA	//DP -> RA
								MaIntBxCP(2,{nCMPRecno},,{nPARecno},,{lContab,lAglut,.F.,.F.,.F.,.F.})
								cHistPA	:= STR0050 + _cProcesso //"CDV-COMP.TOT.PROC."
							ElseIf nSaldo > 0  					//RA -> DP
								MaIntBxCP(2,{nPARecno},,{nCMPRecno},,{lContab,lAglut,.F.,.F.,.F.,.F.})
								cHistPA	:= STR0051 + _cProcesso //"CDV-COMP.PARC.PROC."
							Endif
							//Gravar o historico de compensacao no PA que foi compensado
							If nSaldo > 0
								SE2->(dbGoto(nPARecno))
								Reclock("SE2",.F.,.T.)
								SE2->E2_HIST := Substr(AllTrim(cHistPA),1,TamSX3("E2_HIST")[1])
								MsUnlock()   
							ElseIf lEstorna
								EstornaPA(cChaveSE2,_cBanco,_cAgenci,_cConta)
							EndIf
						Endif				
					Endif
				Endif
			End Transaction
			If ExistBlock("CONTABPR")
				ExecBlock("CONTABPR", .F., .F.,{_cProcesso})
			EndIf       
		EndIf   
	Else
		If MsgYesNo(STR0053,STR0002) //'Confirma a liberação sem a geração do financeiro?'###'Atenção'
			dbSelectArea('LHP')
			LHP->(dbSetOrder(1))
			If LHP->(MsSeek(xFilial('LHP') + _cProcesso))
				RecLock('LHP',.F.)
				If Empty(LHQ->LHQ_SAIDA)
					LHP->LHP_FLAG  := 'B'
					LHP->LHP_FLAG1 := 'B'
				Else
					LHP->LHP_FLAG  := 'C'
					LHP->LHP_FLAG1 := 'C'
				EndIf
				MsUnLock('LHP')

				RecLock('LHQ',.F.)
				If Empty(LHQ->LHQ_SAIDA)
					LHQ->LHQ_Flag	:= 'B'
					LHQ->LHQ_DFECHA := dDatabase
				Else
					LHQ->LHQ_Flag	:= 'C'
					LHQ->LHQ_DFECHA := dDatabase
				EndIf
				MsUnLock('LHQ')
			Else
				MsgInfo(STR0054) //'O Processo não foi encontrado. Por favor, contate o administrador do sistema.'
			EndIf
		EndIf
	EndIf
	oPrincipal:End()
	RestArea(aArea)

	Return
	*----------------------------------------------------------------------------------------


	*----------------------------------------------------------------------------------------
Static Function CadForn()
	*----------------------------------------------------------------------------------------
	Local aAreaSA2 := SA2->(GetArea())

	DbSelectArea('SA2')
	DbSetOrder(8) //A2_FILIAL+A2_MAT
	If MsSeek(xFilial('SA2') + LHP->LHP_Func)
		MsgInfo(STR0055) //'Colaborador já possui Cadastro em Fornecedores.'
	Else
		AxIncluiLoc('SA2', , , , , , 'A020TudoOk()')
	EndIf

	RestArea(aAreaSA2)

	Return(Nil)
	*----------------------------------------------------------------------------------------


	*----------------------------------------------------------------------------------------
Static Function AxIncluiLoc(cAlias,nReg,nOpc,aAcho,cFunc,aCpos,cTudoOk,lF3,cTransact)
	*----------------------------------------------------------------------------------------
	Local i
	SetPrvt('LVar01, nLinhas, bCampo, nOpca, cCampo, lInit, i, aCRA, lNumSeq, cNum, cFieldNum')
	SetPrvt('bOk, oDlg, aSvRot, aPosEnch, lX, lF3, cTudoOk')

	LVar01  := 1
	nLinhas := 0
	nOpca   := 0
	lInit   := .F.
	aCRA    := {OemToAnsi(STR0056),OemToAnsi(STR0057),OemToAnsi(STR0058) } //"Confirma"###"Redigita"###"Abandona"
	lNumSeq := .F.
	lF3     := .F.
	//cTudoOk := ".t."

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta a entrada de dados do arquivo							     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Private lIntLox := GetMV("MV_QALOGIX") == "1"
	bOk := &("{|| "+cTudoOk+"}")
	Private aTELA[0][0],aGETS[0]

	bCampo := {|nCPO| Field(nCPO) }
	If nOpc == Nil
		nOpc := 3
		If Type("aRotina") == "A"
			aSvRot := aClone(aRotina)
		EndIf
		Private aRotina := MenuDef()
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Salva a integridade dos campos de Bancos de Dados 			  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	For i := 1 TO FCount()
		dbSelectArea(cAlias)
		cCampo := EVAL(bCampo,i)
		lInit := .f.
		If ExistIni(cCampo)
			lInit := .t.
			M->&(cCampo) := InitPad(getsx3campo(cCampo,"X3_RELACAO"))
			If ValType(M->&(cCampo)) = "C"
				M->&(cCampo) := PADR(M->&(cCampo),getsx3campo(cCampo,"X3_TAMANHO"))
			EndIf
			If M->&(cCampo) == NIL
				lInit := .f.
			EndIf
		EndIf
		If !lInit
			M->&(cCampo) := FieldGet(i)
			If ValType(M->&(cCampo)) = "C"
				M->&(cCampo) := SPACE(LEN(M->&(cCampo)))
			ElseIf ValType(M->&(cCampo)) = "N"
				M->&(cCampo) := 0
			ElseIf ValType(M->&(cCampo)) = "D"
				M->&(cCampo) := CtoD("  /  /  ")
			ElseIf ValType(M->&(cCampo)) = "L"
				M->&(cCampo) := .F.
			EndIf
		EndIf
	Next i

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Inicializa variaveis para campos Memos Virtuais (GILSON)				 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Type("aMemos")=="A"
		For i:=1 to Len(aMemos)
			cMemo := aMemos[i][2]
			If ExistIni(cMemo)
				&cMemo := InitPad(getsx3campo(cCampo,"X3_RELACAO"))
			Else
				&cMemo := ""
			EndIf
		Next i
	EndIf

	If cFunc != NIL
		&cFunc.()
	EndIf

	DbSelectArea('LHT')
	DbSetOrder(1)
	MsSeek(xFilial('LHT') + LHP->LHP_Func)
	M->A2_LOJA    := Replicate("0",TamSX3("A2_LOJA")[1]-1) + "1"
	M->A2_Nome    := LHT->LHT_Nome
	M->A2_NReduz  := LHT->LHT_Nome
	M->A2_Tipo    := 'F'
	M->A2_EMail   := LHT->LHT_EMail
	M->A2_Banco   := SubStr(LHT->LHT_BcDepS,1,3)
	M->A2_Agencia := SubStr(LHT->LHT_BcDepS,4,9)
	M->A2_NumCon  := LHT->LHT_CtDepS
	M->A2_Mat     := LHT->LHT_CodMat

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Envia para processamento dos Gets					 		³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	DEFINE MSDIALOG oDlg TITLE STR0059 FROM 009,000 TO 370,650 OF oPrincipal PIXEL //'Cadastramento de Fornecedores'

	aPosEnch := {,,(oDlg:nClientHeight - 4)/2,}  // ocupa todo o  espaço da janela

	EnChoice( cAlias, nReg, nOpc, aCRA,"CRA",oemtoansi(STR0060),aAcho, aPosEnch , aCpos, , , ,cTudoOk,,lF3 ) //'Quanto a Inclusão'

	If lF3  // Esta na conpad, desabilita o trigger por execblock
		SetEntryPoint(.f.)
	EndIf
	nOpca := 3
	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| nOpca := 1,If(Obrigatorio(aGets,aTela).and. Eval(bOk),oDlg:End(),(nOpca:=3,.f.))},{|| nOpca := 3,oDlg:End()})

	If nOpcA == 1
		Begin Transaction ExtEnded
			RecLock(cAlias,.T.)
			For i := 1 TO FCount()
				If "_FILIAL"$Field(i)
					FieldPut(i,cFilial)
				Else
					FieldPut(i,M->&(EVAL(bCampo,i)))
				EndIf
			Next i

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Grava os campos Memos Virtuais					 				  			 ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If Type("aMemos") == "A"
				For i := 1 to Len(aMemos)
					cVar := aMemos[i][2]
					MSMM(,TamSx3(aMemos[i][2])[1],,&cVar,1,,,cAlias,aMemos[i][1])
				Next i
			EndIf

			dbCommit()
			If cTransact != Nil
				If !("("$cTransact)
					cTransact+="()"
				EndIf
				lX := &cTransact
			EndIf
			If __lSX8
				ConfirmSX8()
			EndIf
		End Transaction ExtEnded
	ElseIf nOpcA == 3
		If __lSX8
			RollBackSX8()
		EndIf
	EndIf
	DbSelectArea(cAlias)

	If aSvRot != Nil
		aRotina := aClone(aSvRot)
	EndIf
	lRefresh := .t.

	Return(Nil)
	*----------------------------------------------------------------------------------------

	*--------------------------------------------------------------------------------------
Static Function VCC()
	*--------------------------------------------------------------------------------------
	Local _lVCC := .T.
	Local cContab:=GetMV('MV_MCONTAB')

	If !Empty(_cCC)

		If cContab == 'CON'
			DbSelectArea('SI3')
			DbSetOrder(1)
			If !MsSeek(xFilial('SI3') + _cCC)
				MsgInfo(STR0061, STR0002) //'Centro de Custo não Cadastrado !'###'Atenção'
				_lVCC := .F.
			EndIf
		ElseIf cContab == 'CTB'
			DbSelectArea('CTT')
			DbSetOrder(1)
			If !MsSeek(xFilial('CTT') + _cCC)
				MsgInfo(STR0061, STR0002) //'Centro de Custo não Cadastrado !'###'Atenção'
				_lVCC := .F.
			EndIf
		EndIf
	EndIf

	Return(_lVCC)
	*--------------------------------------------------------------------------------------


	*--------------------------------------------------------------------------------------
Static Function VNATUREZ()
	*--------------------------------------------------------------------------------------
	Local _lNATUREZ := .T.

	If !Empty(_cNaturez)
		DbSelectArea('SED')
		DbSetOrder(1)
		If !MsSeek(xFilial('SED') + _cNaturez)
			MsgInfo(STR0062, STR0002) //'Natureza não Cadastrada !'###'Atenção'
			_lNATUREZ := .F.
		EndIf
	EndIf

Return(_lNATUREZ)


Static Function MenuDef()  

	Local aRotina := { { " "," ",0,1 } ,{ " "," ",0,2 },{ " "," ",0,3 } }

Return(aRotina)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ EstornaPA  ºAutor  ³ Pedro Pereira Lima º Data ³  09/06/11 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Baixa o PA gerado como adiantamento quando for feito o     º±±
±±º          ³ estorno dos valores atraves de despesa do tipo "E"         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AE_DV003_AP6                                               º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function EstornaPA(cSE2Key,cBco,cAg,cConta)
	Local aArea			:= GetArea()
	Local aAreaSE2		:= SE2->(GetArea()) 
	Local aAreaLHQ		:= LHQ->(GetArea())
	Local aBaixa 		:= {} 
	Local lMsErroAuto	:= .F.	
	Local lProcPA     := SuperGetMV("MV_CDVBXPA",.F.,.T.) //Baixa PA (.T.) ou exclui (.F.)

	Default cSE2Key := ""
	Default cBco    := ""
	Default cAg		 := ""
	Default cConta  := ""	 

	DbSelectArea("SE2")
	SE2->(DbSetOrder(1))

	If lProcPA
		If !Empty(cSE2Key)
			If SE2->(DbSeek(cSE2Key))

				AADD(aBaixa,{"E2_FILIAL" ,SE2->E2_FILIAL 	, Nil})	
				AADD(aBaixa,{"E2_PREFIXO",SE2->E2_PREFIXO	, Nil})	
				AADD(aBaixa,{"E2_NUM"    ,SE2->E2_NUM		, Nil})	
				AADD(aBaixa,{"E2_PARCELA",SE2->E2_PARCELA	, Nil})	
				AADD(aBaixa,{"E2_TIPO"   ,SE2->E2_TIPO		, Nil})	
				AADD(aBaixa,{"E2_FORNECE",SE2->E2_FORNECE	, Nil})	
				AADD(aBaixa,{"E2_LOJA"   ,SE2->E2_LOJA		, Nil})	
				AADD(aBaixa,{"AUTMOTBX"  ,"NOR"				, Nil})	
				AADD(aBaixa,{"AUTBANCO"  ,cBco				, Nil})
				AADD(aBaixa,{"AUTAGENCIA",cAg					, Nil})
				AADD(aBaixa,{"AUTCONTA"  ,cConta				, Nil})
				AADD(aBaixa,{"AUTDTBAIXA",dDataBase			, Nil})
				AADD(aBaixa,{"AUTHIST"   ,STR0063			, Nil})

				lMsErroAuto := .F.
				MSExecAuto({|x,y| Fina080(x,y)},aBaixa,3)

				If lMsErroAuto
					If (!IsBlind()) // COM INTERFACE GRÁFICA
						MostraErro() // TELA
					Else // EM ESTADO DE JOB
						cError := MostraErro("/dirdoc", "error.log") // ARMAZENA A MENSAGEM DE ERRO

						ConOut(PadC("Automatic routine ended with error", 80))
						ConOut("Error: "+ cError)
					EndIf


				EndIf

			EndIf 
		EndIf
	Else
		If !Empty(cSE2Key)
			If SE2->(DbSeek(cSE2Key))                  

				AADD(aBaixa , {"E2_FILIAL"		, SE2->E2_FILIAL	, NIL})						
				AADD(aBaixa , {"E2_PREFIXO"	, SE2->E2_PREFIXO	, NIL})
				AADD(aBaixa , {"E2_NUM"    	, SE2->E2_NUM     , NIL})
				AADD(aBaixa , {"E2_PARCELA"	, SE2->E2_PARCELA , NIL})
				AADD(aBaixa , {"E2_TIPO"   	, SE2->E2_TIPO		, NIL})
				AADD(aBaixa , {"E2_NATUREZ"	, SE2->E2_NATUREZ , NIL})
				AADD(aBaixa , {"E2_FORNECE"	, SE2->E2_FORNECE , NIL})
				AADD(aBaixa , {"E2_LOJA"   	, SE2->E2_LOJA    , NIL})

				lMsErroAuto := .F.
				MSExecAuto({|x,y,z| Fina050(x,y,z)},aBaixa,5,5)

				If lMsErroAuto
					If (!IsBlind()) // COM INTERFACE GRÁFICA
						MostraErro() // TELA
					Else // EM ESTADO DE JOB
						cError := MostraErro("/dirdoc", "error.log") // ARMAZENA A MENSAGEM DE ERRO

						ConOut(PadC("Automatic routine ended with error", 80))
						ConOut("Error: "+ cError)
					EndIf


				EndIf

			EndIf 
		EndIf			
	EndIf

	RecLock("LHQ",.F.)
	LHQ->LHQ_FLAG := "E"
	MsUnlock("LHQ")

	RestArea(aAreaLHQ)
	RestArea(aAreaSE2)
	RestArea(aArea)
Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ CDVTipDesp ºAutor  ³ Pedro Pereira Lima º Data ³  10/06/11 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function CDVTipDesp(cCodDesp)
	Local lRet := .F.

	LHR->(DbSetOrder(1))
	LHR->(DbSeek(xFilial("LHR")+cCodDesp))

	While !LHR->(Eof()) .And. LHR->(LHR_FILIAL+LHR_CODIGO) == xFilial("LHR")+cCodDesp
		lRet := U_CDVRetDsp(LHR->LHR_CODDES) $ "E"
		If lRet
			Exit		
		EndIf
		LHR->(DbSkip())	
	EndDo

Return lRet      

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºProgrU_a  ³T_CDVRetDsp ºAutor  ³ Pedro Pereira Lima º Data ³  10/06/11 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function CDVRetDsp(cCodDesp)
	Local cRet := ""

	LHS->(DbSetOrder(1))

	If LHS->(DbSeek(xFilial("LHS")+cCodDesp))
		cRet := LHS->LHS_TIPO
	EndIf

Return cRet

/*{Protheus.doc} TemDesp()
Função para verificar se já foram lançadas despesas para a solicitação de viagem 
@Author			Ramon Teodoro e Silva
@Since			30/07/2024
@Version		P12.2210
@Project    	
@Return		Nil	 */

User Function TemDesp()

	Local lRet 
	Local aArea := GetArea()

	DbSelectArea("LHR")
	DbSetOrder(1)

	lRet := DbSeek(XFilial("LHR")+LHP->LHP_CODIGO)

	RestArea(aArea) 
Return lRet
