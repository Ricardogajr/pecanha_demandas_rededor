
#INCLUDE "AE_FV001_AP6.ch"
#INCLUDE "Protheus.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³AE_FV001  ºAutor  ³Willy               º Data ³  09/06/02   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Encaminhamento da Solicitação para o Depto de Viagem e Deptoº±±
±±º          ³Financeiro                                                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³CDV - Controle de Despesas de Viagens                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function AE_FV001()

Local _nRow
Local cNumTit			:= ""
Local aAreaSX5			:= SX5->(GetArea())
Local aAreaSED			:= SED->(GetArea())

Private _cProcesso
Private _nValorR
Private _nValorU
Private _cPerg 
Private _nValorAnt
Private _cHPASS
Private _ConCC 		:= GetMv("MV_CCCDV")
Private _cCodForne
Private _cCodLojaF
Private _cPrefixo
Private _cParcela
Private _cParcela02	:= StrZero(0,TamSX3("E2_PARCELA")[1])
Private _cTipo 		:= Space(TamSX3("E2_TIPO")[1])
Private _cBanco 		:= Space(TamSX3("LHP_BANCO")[1])
Private _cAgenci 		:= Space(TamSX3("LHP_AGENCI")[1])
Private _cConta  		:= Space(TamSX3("LHT_CTDEPS")[1])
Private _cNaturez 		:= Space(TamSX3("ED_CODIGO")[1])
Private _cCC
Private _cCCF
Private _lGeraFin		:= .F.
Private lMSErroAuto	:= .F.
Private _lAdiant 		:= .F.
Private _dVencRea		:= CtoD("  /  /  ")
Private _lInternacional := .F.
Private _cBancoInt	:= Space(03)
Private _cAgenciInt 	:= Space(05)
Private _cContaInt	:= Space(TamSX3("LHT_CTDEPS")[1])
Private _lMultSld    := FindFunction("FXMultSld")    
Private _cNaturezInt := Space(TamSX3("ED_CODIGO")[1])
Private _cCCFInt     

ChkTemplate("CDV")

dbSelectArea("LHP")
If LHP->LHP_Flag1 == 'K' //Solicitacao cancelada
	MsgInfo(STR0001) //"Esta solicitação está cancelada e não pode ser encaminhada."
	Return
ElseIf LHP->LHP_Flag1 <> 'A' .Or. (!Empty(LHP->LHP_Codigo) .And. LHP->LHP_XESTIT <> "S")
	MsgInfo(STR0002,STR0003) //'Esta Solicitação não pode ser Encaminhada.'###'Atenção'
	Return
EndIf
_lAdiant := IIf(Empty(LHP->LHP_ADIANT),.F.,LHP->LHP_ADIANT)

If !GetMV("MV_GERAFIN")
	_cFunc	:= LHP->LHP_Func
	_aArea := GetArea()
	dbSelectArea('LHT')
	LHT->(dbSetOrder(1))
	LHT->(MsSeek(xFilial('LHT') + _cFunc))
	_cUsLogin := AllTrim(LHT->LHT_Login)
	RestArea(_aArea)

	_cProcesso := GetSxENum("LHP","LHP_CODIGO")
	_nRecno    := Recno()
	Efetiva() 
	Return
EndIf 

_lGeraFin:=.T. 

_lInternacional := LHP->LHP_EINTER

DEFINE MSDIALOG oPrincipal FROM  000,000 TO IIf(_lInternacional,480,370),610 TITLE STR0004 PIXEL //'Departamento de Viagem'
aButtons := {}
AaDd(aButtons, {"ALTERA", {|| CadForn()}, STR0005 }) //"Colaboradores em Fornecedores"

_nRow := 15
@ _nRow,008 SAY STR0006 OF oPrincipal PIXEL //'Dados da Solicitação de Viagem'
@ _nRow+9,003 TO _nRow+85,304 OF oPrincipal PIXEL

_cProcesso := IIF( LHP->LHP_XESTIT <> "S",GetSxENum('LHP','LHP_CODIGO'),LHP->LHP_CODIGO)
_nRecno    := Recno()

_nRow+=17
@ _nRow,008 SAY STR0007 OF oPrincipal PIXEL //'Código da Solicitação de Viagem'
@ _nRow,090 MSGET _cProcesso Picture '999999' Size 30,07 OF oPrincipal PIXEL

_nValorR  := LHP->LHP_ValorR
_nValorAnt:= _nValorR
_nValorU  := LHP->LHP_ValorU + LHP->LHP_VAdiM2
@ _nRow,137 SAY STR0008 OF oPrincipal PIXEL //'Valor R$'
@ _nRow,165 MSGET _nValorR Picture '@E 999,999.99' When .F. Size 40,07 OF oPrincipal PIXEL
@ _nRow,222 SAY STR0009 OF oPrincipal PIXEL //'Valor US$'
@ _nRow,255 MSGET _nValorU Picture '@E 999,999.99' When .F. Size 40,07 OF oPrincipal PIXEL

_nRow+=15
_dEmissao := dDataBase
@ _nRow,008 SAY STR0010 OF oPrincipal PIXEL //'Data da Emissão'
@ _nRow,055 MSGET _dEmissao Picture '@D' Size 35,07 When .F. OF oPrincipal PIXEL

_cCC := LHP->LHP_CC
@ _nRow,110 SAY STR0011 OF oPrincipal PIXEL //'CC'
@ _nRow,130 MSGET _cCC  Picture '@!' Size 60,07 When .F. OF oPrincipal PIXEL

_dSaida   := LHP->LHP_Saida
_dChegada := LHP->LHP_Chegad
@ _nRow,195 SAY STR0012 OF oPrincipal PIXEL //'Período'
@ _nRow,258 SAY STR0013 OF oPrincipal PIXEL //'à'
@ _nRow,220 MSGET _dSaida   Picture '@D' Size 35,07 When .F. OF oPrincipal PIXEL
@ _nRow,265 MSGET _dChegada Picture '@D' Size 35,07 When .F. OF oPrincipal PIXEL

_nRow+=15
_cFunc	:= LHP->LHP_Func
_cNFunc := LHP->LHP_NFunc
LHT->(MsSeek(xFilial('LHT') + _cFunc))
_cUsLogin := AllTrim(LHT->LHT_Login)

@ _nRow,008 SAY STR0014 OF oPrincipal PIXEL //'Colaborador'
@ _nRow,110 SAY STR0015 OF oPrincipal PIXEL //'Nome'
@ _nRow,055 MSGET _cFunc  Picture '@!' Size 35,07 When .F. OF oPrincipal PIXEL
@ _nRow,130 MSGET _cNFunc Picture '@!' Size 170,07 When .F. OF oPrincipal PIXEL

_nRow+=13
_cSupImd  := LHP->LHP_SupImd
LHT->(MsSeek(xFilial('LHT') + _cSupImd))
_cNSupImd := LHT->LHT_Nome

@ _nRow,008 SAY STR0016 OF oPrincipal PIXEL //'Aprovador I'
@ _nRow,110 SAY STR0015 OF oPrincipal PIXEL //'Nome'
@ _nRow,055 MSGET _cSupImd  Picture '@!' Size 35,07 When .F. OF oPrincipal PIXEL
@ _nRow,130 MSGET _cNSupImd Picture '@!' Size 170,07 When .F. OF oPrincipal PIXEL

_nRow+=13
_cDGRar  := LHP->LHP_DGRar
LHT->(MsSeek(xFilial('LHT') + _cDGRar))
_cNDGRar := LHT->LHT_Nome
@ _nRow,008 SAY STR0017 OF oPrincipal PIXEL //'Aprovador II'
@ _nRow,110 SAY STR0015 OF oPrincipal PIXEL //'Nome'
@ _nRow,055 MSGET _cDGRar  Picture '@!' Size 35,07 When .F. OF oPrincipal PIXEL
@ _nRow,130 MSGET _cNDGRar Picture '@!' Size 170,07 When .F. OF oPrincipal PIXEL

_nRow+=22
@ _nRow,008 SAY STR0018 + IIf(_lInternacional .And. (_lMultSld .And. FXMultSld())," - R$","") OF oPrincipal PIXEL //'Dados do Título a Pagar'
@ _nRow+9,003 TO _nRow+60,304 OF oPrincipal PIXEL

_nRow+=19                                 
If _lAdiant
	_cPrefixo:= PadR(AllTrim(GetMV('MV_PREADIA')),TamSX3("E2_PREFIXO")[1])
Endif
@ _nRow,008 SAY STR0019 OF oPrincipal PIXEL //'Prefixo'
@ _nRow,032 MSGET _cPrefixo Picture '@!' Size 30,07 When .F. OF oPrincipal PIXEL

@ _nRow,070 SAY STR0020 OF oPrincipal PIXEL //'Número'
@ _nRow,095 MSGET _oProcesso VAR IIf(_lAdiant,_cProcesso,cNumTit) Picture '@!' When .F. Size 30,07 OF oPrincipal PIXEL
_oProcesso:Refresh()

If _lAdiant
	_cParcela := PadR(AllTrim(GetMV("MV_PARADIA")),TamSX3("E2_PARCELA")[1])
Endif
@ _nRow,135 SAY STR0021 OF oPrincipal PIXEL //'Parcela'
@ _nRow,158 MSGET _cParcela  Picture '@!' Size 20,07 When .F. OF oPrincipal PIXEL

If _lAdiant
	_cTipo := PadR(GetMV("MV_TIPADIA"),Len(_cTipo))
	//Validando a existencia do tipo determinado no paramentro, caso nao exista ignorar
	If Empty(_cTipo) .OR. Empty(Posicione("SX5",1,xFilial("SX5")+"05"+AllTrim(_cTipo),"X5_CHAVE"))
		_cTipo := TamSX3("E2_TIPO")[1]
	Endif
Endif
@ _nRow,187 SAY STR0022 OF oPrincipal PIXEL //'Tipo'
@ _nRow,202 MSGET _cTipo  Picture '@!' Size 20,07 When .F. OF oPrincipal PIXEL

If _lAdiant
	If LHP->LHP_Saida - 1 <= dDatabase + 1
		_dVencRea := DataValida(dDatabase + 1)
	Else
		If (Dow(LHP->LHP_Saida) == 2 .And. LHP->LHP_Emiss < LHP->LHP_Saida - 2)
			_dVencRea := DataValida(LHP->LHP_Saida - 3)
		ElseIf  Dow(LHP->LHP_Saida) == 1 .And. Dow(LHP->LHP_EMISS) < 7
			_dVencRea := DataValida(LHP->LHP_Saida,.F.)
		Else
			_dVencRea := DataValida(LHP->LHP_Saida - 1)
		Endif
	Endif
Endif
@ _nRow,235 SAY STR0023 OF oPrincipal PIXEL //'Vencimento'
@ _nRow,265 MSGET _dVencRea Picture '@D' Size 35,07 WHEN _lAdiant OF oPrincipal PIXEL

dbSelectArea('LHP')
_nRow+=13
@ _nRow,008 SAY STR0024 OF oPrincipal PIXEL //'Banco'
@ _nRow,032 MSGET _cBanco Picture '@!' Size 15,07 When _cTipo $ MVPAGANT .AND. _lAdiant Valid CarregaSa6(@_cBanco) F3("CPCDV") OF oPrincipal PIXEL

@ _nRow,070 SAY STR0025 OF oPrincipal PIXEL //'Agencia'
@ _nRow,095 MSGET _cAgenci Picture '@!' Size 20,07 When _cTipo $ MVPAGANT .AND. _lAdiant Valid CarregaSa6(@_cBanco,@_cAgenci) OF oPrincipal PIXEL

@ _nRow,135 SAY STR0026 OF oPrincipal PIXEL //'Conta'
@ _nRow,158 MSGET _cConta Picture '@!' Size 40,07 When _cTipo $ MVPAGANT .AND. _lAdiant Valid CarregaSa6(@_cBanco,@_cAgenci,@_cConta,,,.T.) OF oPrincipal PIXEL

If _lAdiant
	_cNaturez := "20600003"
	//Caso a natureza nao exista, ignorar o conteudo do parametro
	If Empty(_cNaturez) .OR. Empty(Posicione("SED",1,xFilial("SED")+AllTrim(_cNaturez),"ED_CODIGO"))
		_cNaturez := Space(TamSX3("ED_CODIGO")[1])
	Endif		
	_cCCF	 := LHP->LHP_CC
Endif
_nRow+=13
@ _nRow,008 SAY STR0027 OF oPrincipal PIXEL //'Natureza'
@ _nRow,032 MSGET _cNaturez Picture '@!' Size 50,07 WHEN _lAdiant Valid VNATUREZ(_cNaturez) F3('SED') OF oPrincipal PIXEL
@ _nRow,135 SAY STR0011 OF oPrincipal PIXEL //'CC'
@ _nRow,158 MSGET _cCCF Picture '@!' Size 58,07 WHEN _lAdiant Valid VCC(_cCCF) F3(_ConCC) OF oPrincipal PIXEL

If _lInternacional .And. (_lMultSld .And. FXMultSld())
	_cParcela02 := Soma1(_cParcela)
	_nRow+=22
	@ _nRow,008 SAY STR0018 + " - US$" OF oPrincipal PIXEL //'Dados do Título a Pagar'
	@ _nRow+9,003 TO _nRow+60,304 OF oPrincipal PIXEL
	
	_nRow+=19                                 
	If _lAdiant
		_cPrefixo:= PadR(AllTrim(GetMV('MV_PREADIA')),TamSX3("E2_PREFIXO")[1])
	Endif
	@ _nRow,008 SAY STR0019 OF oPrincipal PIXEL //'Prefixo'
	@ _nRow,032 MSGET _cPrefixo Picture '@!' Size 30,07 When .F. OF oPrincipal PIXEL
	
	@ _nRow,070 SAY STR0020 OF oPrincipal PIXEL //'Número'
	@ _nRow,095 MSGET _oProcesso VAR IIf(_lAdiant,_cProcesso,cNumTit) Picture '@!' When .F. Size 30,07 OF oPrincipal PIXEL
	_oProcesso:Refresh()
	
	If _lAdiant
		_cParcela := PadR(AllTrim(GetMV("MV_PARADIA")),TamSX3("E2_PARCELA")[1])
	Endif
	@ _nRow,135 SAY STR0021 OF oPrincipal PIXEL //'Parcela'
	@ _nRow,158 MSGET _cParcela02  Picture '@!' Size 20,07 When .F. OF oPrincipal PIXEL
	
	If _lAdiant
		_cTipo := PadR(GetMV("MV_TIPADIA"),Len(_cTipo))
		//Validando a existencia do tipo determinado no paramentro, caso nao exista ignorar
		If Empty(_cTipo) .OR. Empty(Posicione("SX5",1,xFilial("SX5")+"05"+AllTrim(_cTipo),"X5_CHAVE"))
			_cTipo := TamSX3("E2_TIPO")[1]
		Endif
	Endif
	@ _nRow,187 SAY STR0022 OF oPrincipal PIXEL //'Tipo'
	@ _nRow,202 MSGET _cTipo  Picture '@!' Size 20,07 When .F. OF oPrincipal PIXEL
	
	If _lAdiant
		If LHP->LHP_Saida - 1 <= dDatabase + 1
			_dVencRea := DataValida(dDatabase + 1)
		Else
			If Dow(LHP->LHP_Saida) == 2 .And. LHP->LHP_Emiss < LHP->LHP_Saida - 2
				_dVencRea := DataValida(LHP->LHP_Saida - 3)
			Else
				_dVencRea := DataValida(LHP->LHP_Saida - 1)
			Endif
		Endif
	Endif
	@ _nRow,235 SAY STR0023 OF oPrincipal PIXEL //'Vencimento'
	@ _nRow,265 MSGET _dVencRea Picture '@D' Size 35,07 WHEN _lAdiant OF oPrincipal PIXEL
	
	dbSelectArea('LHP')
	_nRow+=13
	@ _nRow,008 SAY STR0024 OF oPrincipal PIXEL //'Banco'
	@ _nRow,032 MSGET _cBancoInt Picture '@!' Size 15,07 When _cTipo $ MVPAGANT .AND. _lAdiant Valid CarregaSa6(@_cBancoInt) F3("CPCDV") OF oPrincipal PIXEL
	
	@ _nRow,070 SAY STR0025 OF oPrincipal PIXEL //'Agencia'
	@ _nRow,095 MSGET _cAgenciInt Picture '@!' Size 20,07 When _cTipo $ MVPAGANT .AND. _lAdiant Valid CarregaSa6(@_cBancoInt,@_cAgenciInt) OF oPrincipal PIXEL
	
	@ _nRow,135 SAY STR0026 OF oPrincipal PIXEL //'Conta'
	@ _nRow,158 MSGET _cContaInt Picture '@!' Size 40,07 When _cTipo $ MVPAGANT .AND. _lAdiant Valid CarregaSa6(@_cBancoInt,@_cAgenciInt,@_cContaInt,,,.T.) OF oPrincipal PIXEL
	
	If _lAdiant
		_cNaturezInt := "20600003"//PadR(SuperGetMV("MV_U_NATUR",.F.,""),Len(_cNaturezInt))
		//Caso a natureza nao exista, ignorar o conteudo do parametro
		If Empty(_cNaturezInt) .OR. Empty(Posicione("SED",1,xFilial("SED")+AllTrim(_cNaturezInt),"ED_CODIGO"))
			_cNaturezInt := Space(TamSX3("ED_CODIGO")[1])
		Endif		
		_cCCFInt	 := LHP->LHP_CC
	Endif
	_nRow+=13
	@ _nRow,008 SAY STR0027 OF oPrincipal PIXEL //'Natureza'
	@ _nRow,032 MSGET _cNaturezInt Picture '@!' Size 50,07 WHEN _lAdiant Valid VNATUREZ(_cNaturezInt) F3('SED') OF oPrincipal PIXEL
	@ _nRow,135 SAY STR0011 OF oPrincipal PIXEL //'CC'
	@ _nRow,158 MSGET _cCCFInt Picture '@!' Size 58,07 WHEN _lAdiant Valid VCC(_cCCFInt) F3(_ConCC) OF oPrincipal PIXEL
EndIf

ACTIVATE DIALOG oPrincipal CENTERED ON INIT EnchoiceBar(oPrincipal, {|| Efetiva()}, {|| CloseWindow(oPrincipal)}, , aButtons)

If ExistBlock("POS_ENCAM")
	ExecBlock("POS_ENCAM", .F., .F.)
EndIf
RestArea(aAreaSX5)
RestArea(aAreaSED)

Return

*----------------------------------------------------------------------------------------
Static Function Efetiva()
*----------------------------------------------------------------------------------------

Local aAreaSA2 := SA2->(GetArea())
Local aChaveSE2		:= {"E2_FILIAL","E2_PREFIXO","E2_NUM","E2_PARCELA","E2_TIPO","E2_FORNECE","E2_LOJA"}
Local nTamChave		:= 0

aEval(aChaveSE2,{|x|nTamChave += TamSX3(x)[1]})

If _lGeraFin // Se for gerar financeiro
	DbSelectArea('SA2')
	SA2->(DbOrderNickName("SA2CDV6")) //A2_FILIAL+A2_MAT - Nickname -> SA2CDV6 
	If !MsSeek(xFilial('SA2') + LHP->LHP_Func)
		If MsgYESNO(STR0028, STR0029) //'Colaborador não está Cadastrado como Fornecedor, Deseja Cadastrar ?'###'Dados Incompletos'
			CadForn()
			If !MsSeek(xFilial('SA2') + LHP->LHP_Func)
				Return
			EndIf
		Else
			Return
		EndIf
	EndIf
	
	DbSelectArea('SA2')
	SA2->(DbOrderNickName("SA2CDV6")) //A2_FILIAL+A2_MAT - Nickname -> SA2CDV6 
	If MsSeek(xFilial('SA2') + LHP->LHP_Func)
		_cCodForne:= SA2->A2_COD
		_cCodLojaF:= SA2->A2_Loja
		If Empty(_cBanco) .OR. Empty(_cAgenci) .OR. Empty(_cConta)
			_cBanco  := SA2->A2_BANCO
			_cAgenci := SA2->A2_AGENCIA
			_cConta  := SA2->A2_NUMCON
		EndIf
	Else
		MsgInfo(STR0030,STR0029) //'Colaborador não está Cadastrado como Fornecedor!'###'Dados Incompletos'
		Return
	EndIf            
	
	RestArea(aAreaSA2)

	DbSelectArea('LHP')
	If Len(AllTrim(_cProcesso)) < 6
		MsgInfo(STR0031, STR0032) //'Codigo da Solicitação somente com 6 Digitos.'###'Dados Incorretos'
		Return
	EndIf

EndIf
	
If Empty(_cProcesso)
	If _lGeraFin //Se for gerar financeiro
		MsgInfo(STR0033, STR0029) //'Codigo da Solicitação não Informado.'###'Dados Incompletos'
	Else 
		MsgInfo(STR0034, STR0029)  //'Não foi possível gerar o c´dogio da solicitação.'###'Dados Incompletos'
	EndIf 
	Return
Else
	_aArLHP:= GetArea()
	DbSelectArea('LHQ')
	DbSetOrder(1)
	If MsSeek(xFilial('LHQ') + _cProcesso) .And. LHP->LHP_XESTIT <> 'S'  
		If _lGeraFin // Se for gerar financeiro
			MsgInfo(STR0035, STR0032) //'Codigo da Solicitação já Existe na Prestacao de Contas! Informe Outro.'###'Dados Incorretos'
		Else 
			MsgInfo(STR0036, STR0032) //'Codigo da Solicitação já Existe na Prestacao de Contas!'###'Dados Incorretos'
		EndIf
		RestArea(_aArLHP)
		Return
	Else
		DbSelectArea('LHP')
		DbSetOrder(1)
		If MsSeek(xFilial('LHP') + _cProcesso) .And. LHP->LHP_XESTIT <> 'S'
			If _lGeraFin // Se for gerar financeiro
				MsgInfo(STR0037, STR0032) //'Codigo da Solicitação já Existe! Informe Outro.'###'Dados Incorretos'
			Else 
				MsgInfo(STR0038, STR0032) //'Codigo da Solicitação já Existe!'###'Dados Incorretos'
			EndIf 
			RestArea(_aArLHP)
			Return
		EndIf
		RestArea(_aArLHP)
		If _lGeraFin // Se for gerar financeiro
			RestArea(_aArLHP)
			_aAreaSE2W:= GetArea()
			dbSelectArea('SE2')
			SE2->(dbSetOrder(6))
			If MsSeek(xFilial('SE2') + _cCodForne + _cCodLojaF + _cPrefixo + PadR(_cProcesso,TamSX3("E2_NUM")[1]) + _cParcela + _cTipo )
				MsgInfo(STR0039, STR0032) //'Existe Título no Contas a Pagar, com estes Dados! Informe Outro Código.'###'Dados Incorretos'
				RestArea(_aAreaSE2W)
				Return
			EndIf
			RestArea(_aAreaSE2W)
		EndIf
	EndIf
EndIf

If _lGeraFin // Se for gerar financeiro
	/*If Empty(LHP->LHP_EmpCLi)
		MsgInfo('Impossivel Efetivar, Empresa/Cliente não Informado.', 'Dados Incompletos')
		Return
	EndIf*/
	
	If Empty(LHP->LHP_Func)
		MsgInfo(STR0040, STR0029) //'Impossivel Efetivar, Colaborador não Informado.'###'Dados Incompletos'
		Return
	EndIf
	
	If Empty(LHP->LHP_SupImd)
		MsgInfo(STR0041, STR0029) //'Impossivel Efetivar, Aprovador I  não Informado.'###'Dados Incompletos'
		Return
	EndIf
	
	If Empty(LHP->LHP_Saida)
		MsgInfo(STR0042, STR0029) //'Impossivel Efetivar, Data de Saída não Informada.'###'Dados Incompletos'
		Return
	EndIf
	
	If Empty(LHP->LHP_Chegad)
		MsgInfo(STR0043, STR0029) //'Impossivel Efetivar, Data de Retorno não Informada.'###'Dados Incompletos'
		Return
	EndIf
	
	If Empty(LHP->LHP_CC)
		MsgInfo(STR0044, STR0029) //'Impossivel Efetivar, Percentual a Faturar Diferente de 100%.'###'Dados Incompletos'
		Return
	EndIf
	
	If LHP->LHP_FatCLi + LHP->LHP_FatFra + LHP->LHP_FatMic <> 100
		MsgInfo(STR0044, STR0032) //'Impossivel Efetivar, Percentual a Faturar Diferente de 100%.'###'Dados Incorretos'
		Return
	EndIf
EndIf

If LHP->LHP_Flag1 <> 'A'
	MsgInfo(STR0045, STR0032) //'Esta Solicitação não pode ser Efetivada. Apenas solicitações com legenda Azul (Aprovada) poderão ser encaminhadas.'###'Dados Incorretos'
	Return
EndIf

If _lGeraFin // Se for gerar financeiro
	If (_nValorR <= 0 .AND. _nValorU <= 0 ) .AND. _lAdiant
		If .not. MsgInfo(STR0046, STR0029) //'Solicitação sem Valor não gera Título no Financeiro!'###'Dados Incompletos'
			Return
		EndIf
	EndIf
EndIf

If _lGeraFin .AND. _lAdiant // Se for gerar financeiro
	_cPerg := STR0047 //"Deseja Enviar para Agencia de Viagem e Adiantamento ?"
Else
	_cPerg := STR0048 //"Deseja Enviar para Agencia de Viagem?"
EndIf

IF MsgYESNO(_cPerg, STR0049) //"Atenção"
	Begin Transaction
	_copcao := "SCA"
	RecLock('LHP', .F.)
	LHP->LHP_Codigo:= _cProcesso
	LHP->LHP_OkAdia:= .T.
	LHP->LHP_FLAG  := 'E'
	LHP->LHP_FLAG1 := 'E'
	LHP->LHP_ValorR:= _nValorR
	LHP->LHP_HPASS := _cHPASS
	LHP->LHP_XESTIT:=  ' '
	MsUnLock('LHP')
	ConfirmSX8()
	_aAreaLHQ := GetArea()
	
	DbSelectArea('LHQ')
	DbSetOrder(1)
	If DbSeek(xFilial("LHQ")+_cProcesso)
		RecLock('LHQ',.F.)
	Else
		RecLock('LHQ',.T.)
	EndIF
	LHQ->LHQ_Filial := xFilial('LHQ')
	LHQ->LHQ_Codigo := _cProcesso
	LHQ->LHQ_EmpCli := LHP->LHP_EmpCLi
	LHQ->LHQ_Func	:= LHP->LHP_Func
	LHQ->LHQ_SupImd := LHP->LHP_SupImd
	LHQ->LHQ_Saida	:= LHP->LHP_Saida
	LHQ->LHQ_HoraId := LHP->LHP_HoraId
	LHQ->LHQ_Chegad := LHP->LHP_Chegad
	LHQ->LHQ_HoraVt := LHP->LHP_HoraVt
	LHQ->LHQ_CC	:= LHP->LHP_CC
	LHQ->LHQ_FatCli := LHP->LHP_FatCLi
	LHQ->LHQ_FatFra := LHP->LHP_FatFra
	LHQ->LHQ_FatMic := LHP->LHP_FatMic
	LHQ->LHQ_Flag	:= 'V'
	LHQ->LHQ_DGRar	:= LHP->LHP_DGRar
	LHQ->LHQ_SolPor := LHP->LHP_SolPor
	LHQ->LHQ_Login	:= _cUsLogin                                     
	MsUnLock('LHQ')

	If _lGeraFin .AND. _lAdiant // Se for gerar financeiro
		If _nValorR > 0
			If "AP7" $ GetVersao(.F.)
				dbSelectArea('SE2')
				RecLock('SE2',.T.)
				SE2->E2_Naturez := _cNaturez
				SE2->E2_CCUsto  := _cCCF           
				SE2->E2_Filial	:= xFilial("SE2")
				SE2->E2_Prefixo := _cPrefixo
				SE2->E2_Num     := _cProcesso
				SE2->E2_Parcela := _cParcela
				SE2->E2_Tipo    := _cTipo
				SE2->E2_Fornece := _cCodForne
				SE2->E2_Loja    := _cCodLojaF
				SE2->E2_Portado := _cBanco
				SE2->E2_Nomfor	:= LHP->LHP_NFunc
				SE2->E2_Emissao := dDataBase
				SE2->E2_Vencto  := _dVencRea
				SE2->E2_VencRea := _dVencRea
				SE2->E2_Valor   := _nValorR
				SE2->E2_Emis1   := dDataBase
				SE2->E2_Saldo   := _nValorR
				SE2->E2_VencOri := _dVencRea
				SE2->E2_Moeda   := 1
				SE2->E2_Rateio  := 'N'
				SE2->E2_VlCruz  := _nValorR
				SE2->E2_Ocorren := '01'
				SE2->E2_Origem  := 'FINA050'
				SE2->E2_Fluxo   := 'S'
				SE2->E2_Desdobr := 'N'
				If ExistBlock("GRAVASE2") 
					ExecBlock("GRAVASE2", .F., .F.,{_cProcesso})
				EndIf
				MsUnLock('SE2')			
			Else
				aGrvSe2 := {{ "E2_FILIAL"	, xFilial("SE2")	, Nil },;
								{ "E2_CCUSTO"	, _cCCF				, Nil },;
								{ "E2_PREFIXO"	, _cPrefixo			, Nil },;
								{ "E2_PARCELA"	, _cParcela			, Nil },;
								{ "E2_NUM"		, _cProcesso		, Nil },;
								{ "E2_TIPO"		, _cTipo				, Nil },;
								{ "E2_NATUREZ"	, _cNaturez			, Nil },;
								{ "E2_FORNECE"	, _cCodForne		, Nil },;
								{ "E2_LOJA"   	, _cCodLojaF		, Nil },;
								{ "E2_NOMFOR"	, LHP->LHP_NFunc	, Nil },;
								{ "E2_EMISSAO"	, dDataBase			, Nil },;
								{ "E2_VENCTO"	, _dVencRea			, Nil },;
								{ "E2_VENCREA"	, _dVencRea			, Nil },;
								{ "E2_VALOR"  	, _nValorR			, Nil },;
								{ "E2_SALDO"  	, _nValorR			, Nil },;
								{ "E2_MOEDA"	, 1					, Nil },;
								{ "E2_VLCRUZ" 	, _nValorR			, Nil },;
								{ "E2_ORIGEM" 	, 'FINA050'			, Nil },;
								{ "E2_Emis1" 	, dDataBase			, Nil },;
								{ "E2_VencOri"	, _dVencRea			, Nil },;
								{ "E2_Rateio" 	, 'N'					, Nil },;
								{ "E2_Ocorren"	, '01'				, Nil },;
								{ "E2_Fluxo" 	, 'S'					, Nil },;
								{ "E2_Portado"	, _cBanco			, Nil },;
								{ "E2_Desdobr" , 'N'					, Nil }}   				

				If _cTipo $ MVPAGANT
					AADD(aGrvSe2,{"AUTBANCO",_cBanco						, Nil })
					AADD(aGrvSe2,{"AUTAGENCIA",_cAgenci					, Nil })
					AADD(aGrvSe2,{"AUTCONTA",_cConta						, Nil })	
					lContinua := ( !Empty(_cBanco) .AND. !Empty(_cAgenci) .AND. !Empty(_cConta) )					
            	Else
            		lContinua := .T.
				EndIf						
				If ExistBlock("GRAVASE2") 
					aGrvSe2 := ExecBlock("GRAVASE2", .F., .F.,{_cProcesso, aGrvSe2})
				EndIf
				if lContinua
					//MsExecAuto({ | x,y,z | Fina050(x,y,z) }, aGrvSe2,, 3) // 3- Opcao de Inclusao
					MsExecAuto({ | a,b,c,d,e,f,g,h,i,j,k | Fina050(a,b,c,d,e,f,g,h,i,j,k) }, aGrvSe2,,3,,,,,,,,.F.) // Alteração para não gerar movimentação bancária para PA
				else 
					MsgInfo("Banco/Agencia/Conta divergente do cadastro fornecedor","Dados Incorretos") //'Colaborador não está Cadastrado como Fornecedor!'###'Dados Incompletos'
					disarmtransaction()
					Return
				endif
				If lMSErroAuto 
					DisarmTransaction()
					MsgInfo(STR0050 + CRLF + ; //'Ocorreu um erro na gravação do Contas a Pagar.'
						STR0051) //'Verifique a mensagem de erro e caso necessário abra um chamado no help desk para que esse erro seja corrigido.'
					MostraErro()
					RollBackSX8()
					If _lGeraFin 
						oPrincipal:End()
					EndIf
					Return Nil
				Endif
				ConfirmSX8()
			EndIf
			//Apos a gravacao do titulo. gravar referencia do titulo de PA gerado na despesa de viagem
			If _lGeraFin .AND. LHP->(FieldPos("LHP_DOCUME")) # 0
				Reclock("LHP",.F.,.T.)
				LHP->LHP_DOCUME	:= (xFilial("SE2") + ;
									PadR(_cPrefixo,TamSX3("E2_PREFIXO")[1]) + ;
									PadR(_cProcesso,TamSX3("E2_NUM")[1]) + ;
									PadR(_cParcela,TamSX3("E2_PARCELA")[1]) + ;
									PadR(_cTipo,TamSX3("E2_TIPO")[1]) + ;
									PadR(_cCodForne,TamSX3("E2_FORNECE")[1]) + ;
									PadR(_cCodLojaF,TamSX3("E2_LOJA")[1]))
				MsUnlock("LHP")
			Endif			
		Else
			ConfirmSX8()
		EndIf
		If LHP->LHP_EINTER //Viagem internacional
			If _nValorU > 0
				If _nValorR > 0
					//Caso jah tenha sido gravado um titulo para valores em Reais, manter o mesmo processo e alterar apenas a parcela, para facilitar a rastreabilidade
					If Empty(_cParcela)
						_cParcela02 := Soma1(_cParcela02,Len(_cParcela02))
					Else                           
						_cParcela02 := Soma1(AllTrim(_cParcela),Len(_cParcela02))
					Endif
				Else
					_cParcela02 := _cParcela
				EndIf
				If "AP7" $ GetVersao()
					DbSelectArea('SE2')
					RecLock('SE2',.T.)
					SE2->E2_Naturez := _cNaturez
					SE2->E2_CCUsto  := _cCCF
					SE2->E2_Filial	:= xFilial("SE2")
					SE2->E2_Prefixo := _cPrefixo
					SE2->E2_Num     := _cProcesso
					SE2->E2_Parcela := _cParcela02
					SE2->E2_Tipo    := _cTipo
					SE2->E2_Fornece := _cCodForne
					SE2->E2_Loja    := _cCodLojaF
					SE2->E2_Portado := _cBanco
					SE2->E2_Nomfor	:= LHP->LHP_NFunc
					SE2->E2_Emissao := dDataBase
					SE2->E2_Vencto  := _dVencRea
					SE2->E2_VencRea := _dVencRea
					SE2->E2_Valor   := _nValorU
					SE2->E2_Emis1   := dDataBase
					SE2->E2_Saldo   := _nValorU
					SE2->E2_VencOri := _dVencRea
					SE2->E2_Moeda   := 2
					SE2->E2_Rateio  := 'N'
					SE2->E2_VlCruz  := xMoeda(_nValorU,2,1,dDataBase)
					SE2->E2_Ocorren := '01'
					SE2->E2_Origem  := 'FINA050'
					SE2->E2_Fluxo   := 'S'
					SE2->E2_Desdobr := 'N'
					If ExistBlock("GRVSE2_U") 
						ExecBlock("GRVSE2_U", .F., .F.,{_cProcesso})
					EndIf					
					MsUnLock('SE2')			
				Else
					If (_lMultSld .And. FXMultSld())
						aGrvSe2 := {{ "E2_FILIAL"	, xFilial("SE2")						, Nil },;
										{ "E2_CCUSTO"	, _cCCFInt									, Nil },;
										{ "E2_PREFIXO"	, _cPrefixo								, Nil },;
										{ "E2_NUM"		, _cProcesso							, Nil },;
										{ "E2_TIPO"		, _cTipo									, Nil },;
										{ "E2_NATUREZ"	, _cNaturezInt								, Nil },;
										{ "E2_FORNECE"	, _cCodForne							, Nil },;
										{ "E2_LOJA"   	, _cCodLojaF							, Nil },;
										{ "E2_NOMFOR"	, LHP->LHP_NFunc						, Nil },;
										{ "E2_EMISSAO"	, dDataBase								, Nil },;
										{ "E2_VENCTO"	, _dVencRea								, Nil },;
										{ "E2_VENCREA"	, _dVencRea								, Nil },;
										{ "E2_VALOR"  	, _nValorU								, Nil },;
										{ "E2_SALDO"  	, _nValorU								, Nil },;
										{ "E2_MOEDA"	, 2										, Nil },;
										{ "E2_VLCRUZ" 	, xMoeda(_nValorU,2,1,dDataBase)	, Nil },;
										{ "E2_PARCELA"	, _cParcela02							, Nil },;
										{ "E2_ORIGEM" 	, 'FINA050'								, Nil },;
										{ "E2_Emis1" 	, dDataBase								, Nil },;
										{ "E2_VencOri"	, _dVencRea								, Nil },;
										{ "E2_Rateio" 	, 'N'										, Nil },;
										{ "E2_Ocorren"	, '01'									, Nil },;
										{ "E2_Fluxo" 	, 'S'										, Nil },;
										{ "E2_Portado"	, _cBancoInt							, Nil },;
										{ "E2_Desdobr" , 'N'										, Nil }}   
				      
						If _cTipo $ MVPAGANT
							AADD(aGrvSe2,{"AUTBANCO",_cBancoint						, Nil })
							AADD(aGrvSe2,{"AUTAGENCIA",_cAgenciInt					, Nil })
							AADD(aGrvSe2,{"AUTCONTA",_cContaInt						, Nil })	
						EndIf						 
					Else
						aGrvSe2 := {{ "E2_Filial"	, xFilial("SE2")						, Nil },;
										{ "E2_CCUsto"	, _cCCF									, Nil },;
										{ "E2_PREFIXO"	, _cPrefixo								, Nil },;
										{ "E2_NUM"		, _cProcesso							, Nil },;
										{ "E2_TIPO"		, _cTipo									, Nil },;
										{ "E2_NATUREZ"	, _cNaturez								, Nil },;
										{ "E2_FORNECE"	, _cCodForne							, Nil },;
										{ "E2_LOJA"   	, _cCodLojaF							, Nil },;
										{ "E2_NOMFOR"	, LHP->LHP_NFunc			 			, Nil },;
										{ "E2_EMISSAO"	, dDataBase						  		, Nil },;
										{ "E2_VENCTO"	, _dVencRea								, Nil },;
										{ "E2_VENCREA"	, _dVencRea								, Nil },;
										{ "E2_VALOR"  	, _nValorU								, Nil },;
										{ "E2_SALDO"  	, _nValorU								, Nil },;
										{ "E2_MOEDA"	, 2										, Nil },;
										{ "E2_VLCRUZ" 	, xMoeda(_nValorU,2,1,dDataBase)	, Nil },;
										{ "E2_PARCELA"	, _cParcela02							, Nil },;
										{ "E2_ORIGEM" 	, 'FINA050'								, Nil },;
										{ "E2_Emis1" 	, dDataBase								, Nil },;
										{ "E2_VencOri"	, _dVencRea								, Nil },;
										{ "E2_Rateio" 	, 'N'										, Nil },;
										{ "E2_Ocorren"	, '01'									, Nil },;
										{ "E2_Fluxo" 	, 'S'										, Nil },;
										{ "E2_Portado"	, _cBanco								, Nil },;     
										{ "E2_Desdobr"	, 'N'										, Nil } }
				      
						If _cTipo $ MVPAGANT
							AADD(aGrvSe2,{"AUTBANCO",_cBanco						, Nil })
							AADD(aGrvSe2,{"AUTAGENCIA",_cAgenci					, Nil })
							AADD(aGrvSe2,{"AUTCONTA",_cConta						, Nil })
						EndIf																							
		         	EndIf
					If ExistBlock("GRVSE2_U") 
						aGrvSe2 := ExecBlock("GRVSE2_U", .F., .F.,{_cProcesso, aGrvSe2})
					EndIf
					//MsExecAuto({ | x,y,z | Fina050(x,y,z) }, aGrvSe2,, 3) // 3- Opcao de Inclusao
					MsExecAuto({ | a,b,c,d,e,f,g,h,i,j,k | Fina050(a,b,c,d,e,f,g,h,i,j,k) }, aGrvSe2,,3,,,,,,,,.F.) // Alteração para não gerar movimentação bancária para PA
					If lMSErroAuto
						DisarmTransaction()
						MsgInfo(STR0050+CHR(13)+CHR(10)+STR0051) //'Ocorreu um erro na gravação do Contas a Pagar.'###'Verifique a mensagem de erro e caso necessário abra um chamado no help desk para que esse erro seja corrigido.'
						MostraErro()
						RollBackSX8()
						If _lGeraFin //Se for gerar financeiro
							oPrincipal:End()
						EndIf
						Return Nil
					Endif
					ConfirmSX8()
				EndIf
				
				//Depois da gravacao efetuada, gravar referencia do titulo de PA gerado a partir da solicitacao de viagem
				If LHP->(FieldPos("LHP_DOCUME")) # 0
					RecLock("LHP",.F.,.T.)
					If Empty(LHP->LHP_DOCUME)
						LHP->LHP_DOCUME	:= (xFilial("SE2") + ;
											PadR(_cPrefixo,TamSX3("E2_PREFIXO")[1]) + ;
											PadR(_cProcesso,TamSX3("E2_NUM")[1]) + ;
											PadR(_cParcela02,TamSX3("E2_PARCELA")[1]) + ;
											PadR(_cTipo,TamSX3("E2_TIPO")[1]) + ;
											PadR(_cCodForne,TamSX3("E2_FORNECE")[1]) + ;
											PadR(_cCodLojaF,TamSX3("E2_LOJA")[1]))
					Else              
						//Como o campo foi utilizado pela moeda 1 com o titulo gravado, gravar a outra parcela
						LHP->LHP_DOCUME	:= Substr(LHP->LHP_DOCUME,1,nTamChave) + "," + PadR(_cParcela02,TamSX3("E2_PARCELA")[1])				
					Endif
					MsUnlock("LHP")
				Endif
			EndIf
		EndIf
	EndIf
	RestArea(_aAreaLHQ)
	If ExistBlock("CUSU_EN2")
		ExecBlock("CUSU_EN2",.F.,.F.)	
	Else	
		U_AEWF001(1,_nRecno,.F.,_cOpcao,NIL)
	EndIf 
	 
	End Transaction

	If _lGeraFin //Se for gerar financeiro
		oPrincipal:End()
	EndIf
Else     
	If _lGeraFin // Se for gerar financeiro
		CloseWindow(oPrincipal)
	EndIf
EndIf

Return
*----------------------------------------------------------------------------------------

*----------------------------------------------------------------------------------------
Static Function CadForn()
*----------------------------------------------------------------------------------------
Local aAreaSA2 := SA2->(GetArea())  
Local lBlqForn := ExistBlock("BLQFORN")
Local lTeste := .T.

IF lBlqForn
	lTeste = ExecBlock("BLQFORN",.F.,.F.)
Endif

IF lTeste
	DbSelectArea('SA2')
	SA2->(DbOrderNickName("SA2CDV6")) //A2_FILIAL+A2_MAT - Nickname -> SA2CDV6 
	If MsSeek(xFilial('SA2') + LHP->LHP_Func)
	MsgInfo(STR0052) //'Colaborador já Possui Cadastro em Fornecedores.'
	Else
	AxIncluiLoc('SA2', , , , , , 'A020TudoOk()')
	EndIf            
EndIf
RestArea(aAreaSA2)

Return
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
lInit   := .f.
aCRA    := { oemtoansi(STR0053),oemtoansi(STR0054),oemtoansi(STR0055) } //"Confirma"###"Redigita"###"Abandona"
lNumSeq := .f.
lF3     := .f.
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
FOR i := 1 TO FCount()
	DbSelectArea(cAlias)
	cCampo := EVAL(bCampo,i)
	lInit := .f.
	If ExistIni(cCampo)
		lInit := .t.
		M->&(cCampo) := InitPad(SX3->X3_RELACAO)
		If ValType(M->&(cCampo)) = "C"
			M->&(cCampo) := PADR(M->&(cCampo),SX3->X3_TAMANHO)
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
			&cMemo := InitPad(SX3->X3_RELACAO)
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
M->A2_NOME    := LHT->LHT_Nome
M->A2_NREDUZ  := LHT->LHT_Nome
M->A2_TIPO    := 'F'
M->A2_EMAIL   := LHT->LHT_EMail
M->A2_BANCO   := SubStr(LHT->LHT_BcDepS,1,3)
M->A2_AGENCIA := SubStr(LHT->LHT_BcDepS,4,9)
M->A2_NUMCON  := LHT->LHT_CtDepS
M->A2_MAT     := LHT->LHT_CodMat

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Envia para processamento dos Gets					 		³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

DEFINE MSDIALOG oDlg TITLE STR0056 FROM 009,000 TO 700,650 OF oPrincipal PIXEL //'Cadastramento de Fornecedores'

aPosEnch := {,,(oDlg:nClientHeight - 4)/2,}  // ocupa todo o espaço da janela

EnChoice( cAlias, nReg, nOpc, aCRA,"CRA",OemToAnsi(STR0057),aAcho, aPosEnch , aCpos, , , ,cTudoOk,,lF3 ) //'Quanto a Inclusão'

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

Return
*----------------------------------------------------------------------------------------

*----------------------------------------------------------------------------------------
Static Function CloseWindow(oPrincipal)
*----------------------------------------------------------------------------------------
RollBackSX8()
oPrincipal:End()

Return

*--------------------------------------------------------------------------------------
Static Function VCC(cCCust)
*--------------------------------------------------------------------------------------
Local _lVCC := .T.
Local cContab:=GetMV('MV_MCONTAB')

If !Empty(cCCust)

	If cContab == 'CON'
		DbSelectArea('SI3')
		DbSetOrder(1)
		If !MsSeek(xFilial('SI3') + cCCust)
			MsgInfo(STR0058, STR0003) //'Centro de Custo não Cadastrado !'###'Atenção'
			_lVCC := .F.
		EndIf
	ElseIf cContab == 'CTB'
		DbSelectArea('CTT')
		DbSetOrder(1)
		If !MsSeek(xFilial('CTT') + cCCust)
			MsgInfo(STR0058, STR0003) //'Centro de Custo não Cadastrado !'###'Atenção'
			_lVCC := .F.
		EndIf
	EndIf
EndIf

Return(_lVCC)
*--------------------------------------------------------------------------------------


*--------------------------------------------------------------------------------------
Static Function VNATUREZ(cNatur)
*--------------------------------------------------------------------------------------
Local _lNATUREZ := .T.

If !Empty(cNatur)
	DbSelectArea('SED')
	DbSetOrder(1)
	If !MsSeek(xFilial('SED') + cNatur)
		MsgInfo(STR0059, STR0003) //'Natureza não Cadastrada !'###'Atenção'
		_lNATUREZ := .F.
	EndIf
EndIf

Return(_lNATUREZ)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³MenuDef   ³ Autor ³ Ana Paula N. Silva     ³ Data ³08/12/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Utilizacao de menu Funcional                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Array com opcoes da rotina.                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Parametros do array a Rotina:                               ³±±
±±³          ³1. Nome a aparecer no cabecalho                             ³±±
±±³          ³2. Nome da Rotina associada                                 ³±±
±±³          ³3. Reservado                                                ³±±
±±³          ³4. Tipo de Transa‡„o a ser efetuada:                        ³±±
±±³          ³		1 - Pesquisa e Posiciona em um Banco de Dados     ³±±
±±³          ³    2 - Simplesmente Mostra os Campos                       ³±±
±±³          ³    3 - Inclui registros no Bancos de Dados                 ³±±
±±³          ³    4 - Altera o registro corrente                          ³±±
±±³          ³    5 - Remove o registro corrente do Banco de Dados        ³±±
±±³          ³5. Nivel de acesso                                          ³±±
±±³          ³6. Habilita Menu Funcional                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MenuDef()

Local aRotina := { { " "," ",0,1 } ,{ " "," ",0,2 },{ " "," ",0,3 } }

Return(aRotina)
 