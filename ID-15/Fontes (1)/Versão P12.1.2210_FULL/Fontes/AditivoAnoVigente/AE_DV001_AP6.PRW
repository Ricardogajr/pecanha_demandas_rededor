#INCLUDE "AE_Dv001_Ap6.ch"
#INCLUDE "PROTHEUS.CH"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAE_DV001  บAutor  ณArmando / Willy     บ Data ณ  09/06/02   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Inclusao / Alteracao da Presta็ใo de Contas das despesas   บฑฑ
ฑฑบ          ณ de viagem.                                                 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ CDV - Controle de Despesas de Viagens 					  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function AE_DV001(_nStatus)
//nStatus = 0 - Visualizacao
//nStatus = 1 - Apontamento de Despesas padrao
//nStatus = 2 - Apontamento de Despesas avulso

Local _nQuem
Local _nT
Local _aArea
Local aColA			:= {}
Local aColG			:= {}
Local aColR			:= {}
Local aColD			:= {} 
Local _nRow 		:= 0
Local _lAdiant 		:= .T.
Local nOpcMoeda		:= 0
Local cAliasAprov	:= ""  
Local lPermiteAvl := ExistBlock("AEDVLCAVL")      
Local lTrataLcAvl := .F.
Local cPict	:= ""
Private aMemos		:= {{"LHQ_CODOBS","LHQ_OBSMEM"}},aButtons,_cRotPrest:= 'AE_DV001'
Private _nRBDifer
Private _nAdiant
Private _nDesemb
Private _nI
Private _nFatCli 	:= GetMv('MV_PORCCLI')
Private _nFatMic 	:= GetMv('MV_PRCNFAT')
Private _nAdtUS
Private _nGastoUS
Private _nReembUS
Private _nDiferUS
Private _oAdtUS
Private _oGastoUS
Private _oReembUS
Private _oDiferUS
Private _mObs		:= ""
Private _cCheque
Private _dEmiss
Private _dVooS
Private _cVooS		:=Space(05)
Private _dVooC
Private _cVooC		:=Space(05)
Private _nDifer
Private _nDiasRea
Private _dSaida
Private _cHoraId
Private _dChegad
Private _cHoraVt
Private _nVlrCPMF
Private _nACPMF
Private _nItLHR
Private _nPosDat
Private _nPosCod
Private _nPosQtd
Private _nPosVrt
Private _nPosVbn
Private _nPosVbs
Private _nPosTax
Private _nPosDesc
Private _cCC
Private _nPosMoe
Private _nReembo	:=0
Private _oReembo
Private _oAdiant
Private _oCPMF
Private _nCPMF		:=0
Private _ConCC		:= GetMv('MV_CCCDV')
Private _cFunc 	:= Space(TamSX3("LHT_CODMAT")[1])
Private _cNFunc	:= Space(TamSX3("LHT_NOME")[1])
Private _cSupImd 	:= Space(TamSX3("LHT_CODMAT")[1])
Private _cNSupImd 	:= Space(TamSX3("LHT_NOME")[1])
Private _cEmpCli 	:= Space(TamSX3("A1_COD")[1])
Private _cNEmpCli 	:= Space(TamSX3("A1_NOME")[1])
Private _cLojaCli 	:= Space(TamSX3("A1_LOJA")[1])
Private _cConta  	:= Space(TamSX3("LHT_CTDEPS")[1])
Private _cBanco 	:= Space(03)
Private _cAgenci	:= Space(05)
Private _oConta
Private _oBanco
Private _oAgenci
Private _lAltera 	:= .F.
Private EhInter 	:= .F.
Private _lVisua 	:= .F.
Private cDGRAR 	:= Space(TamSX3("LHT_CODMAT")[1])
Private cNDGRAR	:= Space(TamSX3("LHT_NOME")[1])
Private oPrincipal
Private oDlg01
Private lCalcKMI	:= .F.
Private _nAbatN
Private _nAbatI

Private _nStatusP	:= _nStatus

ChkTemplate("CDV")

If lPermiteAvl //Existe o ponto de entrada AEDVLCAVL
	lTrataLcAvl := ExecBlock("AEDVLCAVL",.F.,.F.)
	If ValType(lTrataLcAvl) <> "L"
		lTrataLcAvl := .F.
	EndIf			
EndIf
//Alteracao no modo de abertura da tela para edicao, para evitar que apos a confirmacao dos dados, a tela seja aberta novamente com os dados editados
ALTERA := .T.
INCLUI := .F.

dbSelectArea('LHP')
LHP->(dbSetOrder(1))
If _nStatus == 2	//Avulso
	If AllTrim(PtGetTheme()) $ "MDI/TEMAP10"
		oDlg01 := TDialog():New(180,180,293,418,STR0001,,,,,CLR_BLACK,CLR_WHITE,,,.T.)		//'Despesa avulsa - tipo de viagem'
	Else 
		oDlg01 := TDialog():New(180,180,290,420,STR0001,,,,,CLR_BLACK,CLR_WHITE,,,.T.)		 //'Despesa avulsa - tipo de viagem'
	Endif
	@02,02 TO 55,120 OF oDlg01 PIXEL
	oRadio := TRadMenu():New(10,10,{STR0002,STR0003},,oDlg01,,,,,,,,80,40,,,,.T.) //'Viagem nacional'###'Viagem internacional'
	oRadio:bSetGet := {|x| IIf(PCount() > 0, nOpcMoeda := x, nOpcMoeda)}
	oRadio:SetOption(1)     
	oBotao01 := TButton():New(40,10,STR0004,oDlg01,{||oDlg01:End()},40,10,,,.F.,.T.,.F.,,.F.,,,.F.) //"Confirmar"
	oBotao02 := TButton():New(40,60,STR0005,oDlg01,{||nOpcMoeda :=0, oDlg01:End()},40,10,,,.F.,.T.,.F.,,.F.,,,.F.) //"Cancelar"
	oDlg01:Activate(,,,.T.,/*validacao*/,,/*inicializacao*/ )
	Do Case
		Case nOpcMoeda == 1
			EhInter := .F.
		Case nOpcMoeda == 2
			EhInter := .T.
		Otherwise
			Return Nil
	EndCase
Else
	LHP->(MsSeek(xFilial('LHP') + LHQ->LHQ_CODIGO))
	EhInter := LHP->LHP_EINTER
Endif

If _nStatus == 0 .OR. _nStatus == 1
	If LHQ->LHQ_TPDES == "A"
		_nStatus := 2
		_lAltera := .T.
	Else
		_nStatus := 1
	Endif
	If _nStatus == 0
		_lVisua := .T.
	Endif
Endif

If _nStatus == 1
	If !LHQ->LHQ_FLAG $ 'VDPL' .And. !_lVisua
		MsgInfo(STR0006, STR0007) //'Esta Presta็ใo de Contas nใo pode ser Alterada !'###'Aten็ใo'
		Return
	EndIf
	//Solicitacao cancelada	
	If LHQ->LHQ_FLAG == 'K' .And. !_lVisua 
		MsgInfo(STR0008) //"Esta solicita็ใo estแ cancelada e nใo pode ser alterada."
		Return
	EndIf
	If LHP->LHP_XESTIT = "S" .And. !(LHP->LHP_OKADIA)
		MsgAlert("Esta solicita็ใo de viagem estแ com adiantamento pendente", "Altera็ใo nใo permitida") 
		Return
	EndIf
	_cFunc := LHP->LHP_Func
	If LHQ->LHQ_TPDES == "A"
		_lAltera := .T.
		_lAdiant := .F.
	EndIf
ElseIf _nStatus == 2
	//Presta็ใo de contas sem solicita็ใo liberada, vetar
	If LHQ->LHQ_FLAG == 'B' .AND. !Empty(LHQ->LHQ_DFECHA) .AND. !_lVisua .AND. _lAltera 
		MsgInfo(STR0006, STR0007)
		Return
	EndIf
	_lAdiant := .F.
EndIf

If GetMv('MV_MCONTAB') == "CTB"
	_cCC := " "
	If Empty(_ConCC)
		_ConCC := 'CTT'
	EndIf
Else
	_cCC := " "
	If Empty(_ConCC)
		_ConCC := 'SI3'
	EndIf
EndIf

//Pesquisar se a consulta padrใo de viajantes do tipo aprovador existe

dbSelectArea("SXB")
SXB->(dbSetOrder(1))
If SXB->(dbSeek("LHTAPR"))
	cAliasAprov := "LHTAPR"
Else                     
	cAliasAprov := "LHT"
Endif

If _nStatus == 1 .And. 	!_lAltera
	If EhInter                              
		If AllTrim(PtGetTheme()) $ "MDI/TEMAP10"
			DEFINE MSDIALOG oPrincipal FROM  000,000 TO 510,800 TITLE OemToAnsi(STR0009) PIXEL //'Despesas - Viagem Internacional'
		Else 
			DEFINE MSDIALOG oPrincipal FROM  000,000 TO 480,800 TITLE OemToAnsi(STR0009) PIXEL //'Despesas - Viagem Internacional'
		Endif
	Else                                        
		If AllTrim(PtGetTheme()) $ "MDI/TEMAP10"
			DEFINE MSDIALOG oPrincipal FROM  000,000 TO 470,800 TITLE OemToAnsi(STR0010) PIXEL //'Despesas - Viagem Nacional'
		Else
			DEFINE MSDIALOG oPrincipal FROM  000,000 TO 440,800 TITLE OemToAnsi(STR0010) PIXEL //'Despesas - Viagem Nacional'
		Endif
	EndIf
Else
	If EhInter                              
		If AllTrim(PtGetTheme()) $ "MDI/TEMAP10"
			DEFINE MSDIALOG oPrincipal FROM  000,000 TO 590,800 TITLE OemToAnsi(STR0011) PIXEL //'Despesas Avulsas - Viagem Internacional'
		Else 
			DEFINE MSDIALOG oPrincipal FROM  000,000 TO 560,800 TITLE OemToAnsi(STR0011) PIXEL //'Despesas Avulsas - Viagem Internacional'
		Endif
	Else                                    
		If AllTrim(PtGetTheme()) $ "MDI/TEMAP10"
			DEFINE MSDIALOG oPrincipal FROM  000,000 TO 550,800 TITLE OemToAnsi(STR0012) PIXEL //'Despesas Avulsas - Viagem nacional'
		Else
			DEFINE MSDIALOG oPrincipal FROM  000,000 TO 520,800 TITLE OemToAnsi(STR0012) PIXEL //'Despesas Avulsas - Viagem nacional'
		Endif
	Endif
EndIf
                                     
aButtons := {}
//AaDd(aButtons, {"BUDGET",   {|| Parametros()}, "Parโmetros" })
//AaDd(aButtons, {"Calculo", {|| U_CALCULO()}, "Calculo do Reembolso / Devolu็ใo" })

_nRow := 35
If _nStatus == 2 .Or. _lAltera  
	If _lAltera
		_cFunc		:= LHP->LHP_Func
		_cNFunc		:= LHP->LHP_NFunc
		_cBanco		:= LHP->LHP_Banco
		_cAgenci	:= LHP->LHP_Agenci
		_cConta		:= LHP->LHP_Conta
		_cSupImd	:= LHP->LHP_SupImd
		_cEmpCli	:= LHP->LHP_EmpCli
		_cCC		:= LHP->LHP_CC
		//FNC : 00000025604/2009
		cDGRAR		:= LHP->LHP_DGRAR
		VSupImd(1)	//Validacao do primeiro aprovador
		VSupImd(2)	//Validacao do segundo aprovador
		//
		VEmpCli()
	EndIf
	
	@ _nRow+1,005 SAY STR0013 OF oPrincipal PIXEL //'Colaborador'
	@ _nRow+1,097 SAY STR0014 OF oPrincipal PIXEL //'Nome'
	@ _nRow,055 MSGET _cFunc  Picture '@!' Valid VFunc() F3("LHT") Size 25,07 When (!_lVisua) OF oPrincipal PIXEL
	@ _nRow,117 MSGET _cNFunc Picture '@!' Size 163,07 When .F. OF oPrincipal PIXEL

   	@ _nRow+1,292 SAY STR0015 Of oPrincipal PIXEL //"Bco:"
	_oBanco:= TSay():New(_nRow+1,304,{|| _cBanco },oPrincipal,,,,,,.T.,CLR_HBLUE,CLR_WHITE)
		
	@ _nRow+1,316 SAY STR0016 Of oPrincipal PIXEL //"Ag:"
	_oAgenci:= TSay():New(_nRow+1,326,{|| _cAgenci },oPrincipal,,,,,,.T.,CLR_HBLUE,CLR_WHITE)
	
	@ _nRow+1,345 SAY STR0017 Of oPrincipal PIXEL //"Cta:"
	_oConta:= TSay():New(_nRow+1,356,{|| _cConta },oPrincipal,,,,,,.T.,CLR_HBLUE,CLR_WHITE)	
	
	_nRow += 12
	@ _nRow+1,005 SAY STR0018 OF oPrincipal PIXEL //'Aprovador I'
	@ _nRow+1,097 SAY STR0014 OF oPrincipal PIXEL //'Nome'
	@ _nRow,055 MSGET _cSupImd  Picture '@!' Valid vSupImd(1) F3(cAliasAprov) Size 25,07 When (!_lVisua) OF oPrincipal PIXEL
	@ _nRow,117 MSGET _cNSupImd Picture '@!' Size 163,07 When .F. OF oPrincipal PIXEL
	
	//FNC : 00000025604/2009	
	_nRow += 12
	@ _nRow+1,005 SAY STR0019 OF oPrincipal PIXEL //"Aprovador II"
	@ _nRow+1,097 SAY STR0020 OF oPrincipal PIXEL //"Nome"
	@ _nRow,055 MSGET cDGRAR Picture "@!" Valid vSupImd(2) F3(cAliasAprov) Size 25,07 When (!_lVisua) OF oPrincipal PIXEL
	@ _nRow,117 MSGET cNDGRAR Picture "@!" Size 163,07 When .F. OF oPrincipal PIXEL
	//
	
	_nRow += 12
	@ _nRow+1,005 SAY STR0021 OF oPrincipal PIXEL //'Empresa / Cliente'
	@ _nRow+1,097 SAY STR0014 OF oPrincipal PIXEL //'Nome'
	@ _nRow,055 MSGET _cEmpCli  Picture '@!' Valid VEmpCli() F3('SA1') Size 20,07 When (!_lVisua) OF oPrincipal PIXEL
	@ _nRow,117 MSGET _cNEmpCli Picture '@!' Size 163,07 When .F. OF oPrincipal PIXEL
	
	@ _nRow+1,320 SAY STR0022 OF oPrincipal PIXEL //'CC'
	@ _nRow,330 MSGET _cCC  Picture '@!' Size 58,07 When (!_lVisua) Valid VCC() F3(_ConCC) OF oPrincipal PIXEL
	_nRow += 12
EndIf

@_nRow,003 TO _nRow+25,050 OF oPrincipal PIXEL

If _nStatus == 1 .Or. _lAltera
	_dEmiss := LHQ->LHQ_Emiss
	If Empty(_dEmiss)
		_dEmiss := dDataBase
	EndIf   
ElseIf _nStatus == 2          

	_dEmiss := dDataBase
EndIf

_nRow+=3
@ _nRow,007 SAY STR0023 OF oPrincipal PIXEL //'Emissใo'
_nRow+=9
@ _nRow,007 MSGET _dEmiss Picture '@D' Size 40,07 Valid !Empty(_dEmiss) When .F. OF oPrincipal PIXEL

If _nStatus == 1 .And. !_lAltera
	_nRow-=12
	@ _nRow,052 TO _nRow+25,185 OF oPrincipal PIXEL
	_nRow+=3
	@ _nRow,054 SAY STR0024 OF oPrincipal PIXEL //'Data e Hora do Previsto na Solicita็ใo'
	_dSaida  := LHQ->LHQ_Saida
	_cHoraId := LHQ->LHQ_HoraId
	_nRow+=9
	@ _nRow,054 MSGET _dSaida Picture '@D' Size 35,07 When .F. OF oPrincipal PIXEL
	@ _nRow,089 MSGET _cHoraId Size 05,07 When .F. OF oPrincipal PIXEL

	_dChegad := LHQ->LHQ_Chegad
	_cHoraVt := LHQ->LHQ_HoraVt
	@ _nRow,120 MSGET _dChegad Picture '@D' Size 35,07 When .F. OF oPrincipal PIXEL
	@ _nRow,155 MSGET _cHoraVt Size 05,07 When .F. OF oPrincipal PIXEL
	
	_nRow-=12
	@ _nRow,187 TO _nRow+25,382 OF oPrincipal PIXEL
	_nRow+=3
	@ _nRow,194 SAY STR0025 OF oPrincipal PIXEL //'Data e Hora do Realizado na Viagem'
	
	_dVooS := LHQ->LHQ_DtSaid
	If Empty(_dVooS)
		_dVooS := LHQ->LHQ_Saida
	EndIf
	_cVooS := LHQ->LHQ_HorSai
	If Empty(_cVooS)
		_cVooS := LHQ->LHQ_HoraId
	EndIf
	_nRow+=9
	@ _nRow+1,189 SAY 'Saํda' OF oPrincipal PIXEL
	@ _nRow,206 MSGET _dVooS Picture '@D' Size 35,07 When (!_lVisua) Valid !Empty(_dVooS) .And. _dVooS <= _dEmiss OF oPrincipal PIXEL
	@ _nRow+1,242 SAY 'เs' OF oPrincipal PIXEL
	@ _nRow,250 MSGET _cVooS Picture '99:99' Size 05,07 When (!_lVisua) Valid SetHora(_cVooS) OF oPrincipal PIXEL
	
	_dVooC := LHQ->LHQ_DtCheg
	If Empty(_dVooC)
		_dVooC := LHQ->LHQ_Chegad
	EndIF
	_cVooC := LHQ->LHQ_HorChg
	If Empty(_cVooC)
		_cVooC := LHQ->LHQ_HoraVt
	EndIf
	
	@ _nRow+1,284 SAY STR0026 OF oPrincipal PIXEL //'Retorno'
	@ _nRow,305 MSGET _dVooC Picture '@D' Size 35,07 When (!_lVisua) Valid !Empty(_dVooC) .And. _dVooC <= _dEmiss .And. _dVooC >= _dVooS OF oPrincipal PIXEL
	@ _nRow+1,341 SAY 'เs' OF oPrincipal PIXEL
	@ _nRow,350 MSGET _cVooC Picture '99:99' Size 05,07 When (!_lVisua) Valid SetHora(_cVooC) OF oPrincipal PIXEL
Else
	If _lAltera //Alteracao de uma prestacao de contas Avulsa
		_dVooS := LHQ->LHQ_DtSaid
		If Empty(_dVooS)
			_dVooS := LHQ->LHQ_Saida
		EndIf

		_cVooS := LHQ->LHQ_HorSai
		If Empty(_cVooS)
			_cVooS := LHQ->LHQ_HoraId
		EndIf

		_dVooC := LHQ->LHQ_DtCheg
		If Empty(_dVooC)
			_dVooC := LHQ->LHQ_Chegad
		EndIF                                                                                      

		_cVooC := LHQ->LHQ_HorChg
		If Empty(_cVooC)
			_cVooC := LHQ->LHQ_HoraVt
		EndIf

		_nFatCli := LHP->LHP_FatCLi
		_nFatMic := LHP->LHP_FatMic
	Else
		_dVooS := CtoD("  /  /  ")
		_dVooC := CtoD("  /  /  ")
	EndIf
	
	_nRow-=12
	@ _nRow,052 TO _nRow+25,265 OF oPrincipal PIXEL
	@ _nRow,267 TO _nRow+25,388 OF oPrincipal PIXEL

	@ _nRow+3,55 SAY STR0027 OF oPrincipal PIXEL //'Perํodo realizado'
	@ _nRow+3,270 SAY STR0028 OF oPrincipal PIXEL //'Faturamento %'
	
	_nRow += 12
	@ _nRow+1,55 SAY STR0029 OF oPrincipal PIXEL //'Saํda:'
	@ _nRow,072 MSGET _dVooS Picture '@D' Size 40,07 When (!_lVisua) Valid _dVooS <= _dEmiss OF oPrincipal PIXEL
	@ _nRow+1,114 SAY 'เs' OF oPrincipal PIXEL
	@ _nRow,121 MSGET _cVooS Picture '99:99' When (!_lVisua) Size 20,07 OF oPrincipal PIXEL

	@ _nRow+1,155 SAY STR0030 OF oPrincipal PIXEL   //'Retorno:'
	@ _nRow,177 MSGET _dVooC Picture '@D' Size 40,07 When (!_lVisua) Valid !Empty(_dVooC) .And. _dVooC <= _dEmiss .And. _dVooC >= _dVooS OF oPrincipal PIXEL
	@ _nRow+1,217 SAY 'เs' OF oPrincipal PIXEL
	@ _nRow,226 MSGET _cVooC Picture '99:99' Size 20,07 When (!_lVisua) Valid SetHora(_cVooC) OF oPrincipal PIXEL
	
	@ _nRow+1,270 SAY STR0031 OF oPrincipal PIXEL //'Cliente'
	@ _nRow,289 MSGET _nFatCli Picture '@E 999.99' Size 20,07 When (!_lVisua) OF oPrincipal PIXEL
	@ _nRow+1,325 SAY STR0032 OF oPrincipal PIXEL //'Nใo Fatura'
	@ _nRow,353 MSGET _nFatMic Picture '@E 999.99' Size 20,07 When (!_lVisua) OF oPrincipal PIXEL
EndIf
dbSelectArea('LHP')
LHP->(dbSetOrder(1))
LHP->(MsSeek(xFilial('LHP') + LHQ->LHQ_CODIGO))

If _nStatus == 1 .Or. _lVisua
	_nAdiant := LHP->LHP_ValorR
	_nAdtUS := LHP->LHP_ValorU
ElseIf _nStatus == 2 
	If lTrataLcAvl
		_nAdiant := LHP->LHP_ValorR
		_nAdtUS := LHP->LHP_ValorU
	Else
		_nAdiant := 0
		_nAdtUS	:= 0
	EndIf		
EndIf
       
aHeader := {}
DbSelectArea('SX3')
DbSetOrder(1)
MsSeek('LHR')
_nUsado := 0
Do While !Eof() .and. SX3->X3_Arquivo == 'LHR'
	If SX3->X3_Usado <> ' ' .And. cNivel >= SX3->X3_Nivel .And. SX3->X3_Browse <> 'N' .Or. SX3->X3_PROPRI == "U"
			_nUsado++
			AaDd(aHeader, {Trim(SX3->X3_Titulo),SX3->X3_Campo,SX3->X3_Picture,SX3->X3_Tamanho,;
			SX3->X3_Decimal,SX3->X3_Valid,SX3->X3_Usado,SX3->X3_Tipo,SX3->X3_Arquivo,SX3->X3_Context})
	EndIf
	DbSkip()
EndDo

aCols := {}    
_nY := 1
_nACPMF  := GetMV('MV_ACPMF')  // Aliquota da CPMF
_nVlrCPMF:= 0

If _nStatus == 1 .Or. _lAltera
	DbSelectArea('LHR')
	DbSetOrder(1)
	MsSeek(xFilial('LHR') + LHQ->LHQ_Codigo)
	_nItLHR:= 1
	
	Do While !Eof() .And.;
		LHR->LHR_Filial == xFilial('LHR') .And.;
		LHR->LHR_Codigo == LHQ->LHQ_Codigo
		
		_nItLHR++

		AAdd(aCols,Array(_nUsado+1))     
		For _nT:=1 to _nUsado
			aCols[_nY,_nT]:=&(aHeader[_nT,2])
		Next                           
		aCols[_nY,_nUsado+1]:=.F.
		_nY++				
		//	AaDd(aCols,{LHR->LHR_Item,LHR->LHR_Data,LHR->LHR_CodDes,LHR->LHR_Qtdade,;
		//	LHR->LHR_VlrTot,LHR->LHR_MOEDA,LHR->LHR_ValRbN,LHR->LHR_ValRbS,LHR->LHR_Descr,LHR->LHR_TipCal,.F.})
		DbSkip()
	EndDo
EndIf
	
IF Empty(aCols)
	aCols:={Array(_nUsado+1)}
	aCols[1,_nUsado+1]:=.F.
	For _nT:=1 to _nUsado
		aCols[1,_nT]:=CriaVar(aHeader[_nT,2])
	Next
Endif                                           

//Ponto de entrada para manipular as despesas (aCols)
If ExistBlock("PRESTCONT")
	ExecBlock("PRESTCONT",.F.,.F.,{aCols})
EndIf

_nPosDat := aScan(aHeader,{|x| AllTrim(Upper(x[2]))=="LHR_DATA" })
_nPosCod := aScan(aHeader,{|x| AllTrim(Upper(x[2]))=="LHR_CODDES" })
_nPosQtd := aScan(aHeader,{|x| AllTrim(Upper(x[2]))=="LHR_QTDADE" })
_nPosVrt := aScan(aHeader,{|x| AllTrim(Upper(x[2]))=="LHR_VLRTOT" })
_nPosVbn := aScan(aHeader,{|x| AllTrim(Upper(x[2]))=="LHR_VALRBN" })
_nPosVbs := aScan(aHeader,{|x| AllTrim(Upper(x[2]))=="LHR_VALRBS" })
//If EhInter 
//	_nPosTax := aScan(aHeader,{|x| AllTrim(Upper(x[2]))=="LHR_TAXA" })
	_nPosMoe := aScan(aHeader,{|x| AllTrim(Upper(x[2]))=="LHR_MOEDA" })
//EndIf
_nPosDesc:= aScan(aHeader,{|x| AllTrim(Upper(x[2]))=="LHR_DESCR" })
_nPosTCal:= aScan(aHeader,{|x| AllTrim(Upper(x[2]))=="LHR_TIPCAL" })

_nRow += 19
//( nT, nL ,nB, nR,nOPCX, cLinhaOk   , cTudoOk     ,  cIniCpos ,lDeleta, aAlter,nFreeze,lEmpty,nMax,cFieldOk,cSuperDel,aTeclas,cDelOk,oWnd)
If _nStatus == 1
	If _lVisua
		oGet := MSGetDados():New(_nRow,005,_nRow+130,382, 2,"U_ViagLineOk()","AllWaysTrue","+LHR_ITEM",.F.    ,       ,       ,.T.   ,999,        ,         ,       , "U_DelItem()",    )
	Else
		oGet := MSGetDados():New(_nRow,005,_nRow+130,382, 3,"U_ViagLineOk()","AllWaysTrue","+LHR_ITEM",.T.    ,       ,       ,.T.   ,999,        ,         ,       , "U_DelItem()",    )
	EndIf
Else
	If _lVisua
		oGet := MSGetDados():New(_nRow,005,_nRow+130,392, 2,"U_ViagLineOk()","AllWaysTrue","+LHR_ITEM",.F.    ,       ,       ,.T.   ,999,        ,         ,       , "U_DelItem()",    )
	Else
		oGet := MSGetDados():New(_nRow,005,_nRow+130,392, 3,"U_ViagLineOk()","AllWaysTrue","+LHR_ITEM",.T.    ,       ,       ,.T.   ,999,        ,         ,       , "U_DelItem()",    )
	EndIf
EndIf

_nRow += 135

@ _nRow,003 TO _nRow+18,387 OF oPrincipal PIXEL

If GetMv('MV_INICPMF') //Iniciar com a despesa de CPMF?
	AADD(aColA, {005, 031})
	AADD(aColG, {077, 096})
	AADD(aColR, {142, 169})
	AADD(aColD, {260, 285})
Else
	AADD(aColA, {007, 035})
	AADD(aColG, {090, 113})
	AADD(aColR, {167, 195})
	AADD(aColD, {252, 280})
EndIf

cPict := "@E 999,999,999.99"

_nRow += 6
If _nStatus <> 2
	@ _nRow,aColA[1][1] SAY STR0033 OF oPrincipal PIXEL COLOR CLR_HBLUE //'Adiantado'
	@ _nRow-1,aColA[1][2] MSGET _oAdiant VAR _nAdiant Picture cPict Valid U_Calcula() Size 55,07 When (!_lVisua) OF oPrincipal PIXEL 
	_oAdiant:lReadOnly := _lAdiant
Endif

_nDesemb := 0
@ _nRow,aColG[1][1] SAY STR0034 OF oPrincipal PIXEL COLOR CLR_HBLUE //'Gastos'
@ _nRow-1,aColG[1][2] MSGET _oDesemb VAR _nDesemb Picture cPict Size 55,07 When (!_lVisua) OF oPrincipal PIXEL 
_oDesemb:lReadOnly := .T.

_nDifer  := 0
@ _nRow,aColR[1][1] SAY STR0035 OF oPrincipal PIXEL COLOR CLR_HBLUE //'Reembols.'
@ _nRow-1,aColR[1][2] MSGET _oReembo VAR _nReembo Picture cPict Size 55,07 When (!_lVisua) OF oPrincipal PIXEL 
_oReembo:lReadOnly := .T.

If GetMv('MV_INICPMF')
	_nCPMF := 0
	@ _nRow,215 SAY STR0036 OF oPrincipal PIXEL COLOR CLR_HBLUE //'CPMF'
	@ _nRow-1,230 MSGET _oCPMF VAR _nCPMF Picture '@E 99.99' Size 45,07 When (!_lVisua) OF oPrincipal PIXEL
	_oCPMF:lReadOnly := .T.
EndIf

_nDifer  := 0
@ _nRow,aColD[1][1] SAY STR0037 OF oPrincipal PIXEL COLOR CLR_HBLUE //'Diferen็a'
@ _nRow-1,aColD[1][2] MSGET _oDifer VAR _nDifer Picture cPict Size 55,07 When (!_lVisua) OF oPrincipal PIXEL
_oDifer:lReadOnly := .T.

If _lAltera .or. _nStatus == 1
	_mObs := MSMM(LHQ->LHQ_CodObs,,,,3)
Endif
@ _nRow-2,335 Button STR0038 Size 45,12 Action _mObs := U_EditaTexto(STR0038, _mObs, .T.) OF oPrincipal PIXEL //"Observa็๕es"###'Observa็๕es'

If EhInter //Viagem Internacional
	cPict := PesqPict("LHP","LHP_VALORU")

	_nRow+=15
	@ _nRow,003 TO _nRow+18,387 OF oPrincipal PIXEL

	_nRow += 6
	@ _nRow,007 SAY STR0040 OF oPrincipal PIXEL COLOR CLR_HBLUE //'Adiant US$'
	@ _nRow-1,035 MSGET _oAdtUS VAR _nAdtUS Picture cPict Valid U_Calcula() Size 55,07 When (!_lVisua) OF oPrincipal PIXEL 
	_oAdtUS:lReadOnly := .T.

	_nGastoUS := 0
	@ _nRow,090 SAY STR0034 OF oPrincipal PIXEL COLOR CLR_HBLUE //'Gastos'
	@ _nRow-1,113 MSGET _oGastoUS VAR _nGastoUS Picture cPict Size 55,07 When (!_lVisua) OF oPrincipal PIXEL 
	_oGastoUS:lReadOnly := .T.
	
	_nReembUS := 0
	@ _nRow,167 SAY STR0035 OF oPrincipal PIXEL COLOR CLR_HBLUE //'Reembols.'
	@ _nRow-1,195 MSGET _oReembUS VAR _nReembUS Picture cPict Size 55,07 When (!_lVisua) OF oPrincipal PIXEL 
	_oReembUS:lReadOnly := .T.
	
	_nDiferUS := 0
	@ _nRow,252 SAY STR0037 OF oPrincipal PIXEL COLOR CLR_HBLUE //'Diferen็a'
	@ _nRow-1,280 MSGET _oDiferUS VAR _nDiferUS Picture cPict Size 55,07 When (!_lVisua) OF oPrincipal PIXEL
	_oDiferUS:lReadOnly := .T.
EndIf
U_Calcula()
ACTIVATE MSDIALOG oPrincipal CENTERED ON INIT EnchoiceBar(oPrincipal, {|| IIf(GravaDesp(_nStatus),oPrincipal:End(),)}, {|| oPrincipal:End()}, , aButtons)

Return Nil

*------------------------------------------------------------------------------------------------
User Function ViagLineOk()
*------------------------------------------------------------------------------------------------
Local _lLineOk := .T. , _cMsgLOk, _nI

chktemplate("CDV")

aCols[n][1] := StrZero(n,3)

If Len(aCols) > 1 .And. !aCols[n][_nUsado+1]
	For _nI = 1 to n-1
		If !aCols[_nI][_nUsado+1]
			If aCols[n][_nPosDat] < aCols[_nI][_nPosDat]
				_lLineOk := .F.
				_cMsgLOk := STR0041 //'Data fora da Sequencia, Coloque seus Recibos em Ordem de Data.'
				Exit
			EndIf
		EndIf
	Next
	
	For _nI = n+1 to Len(aCols)
		If !aCols[_nI][_nUsado+1]
			If aCols[n][_nPosDat] > aCols[_nI][_nPosDat]
				_lLineOk := .F.
				_cMsgLOk := STR0041 //'Data fora da Sequencia, Coloque seus Recibos em Ordem de Data.'
				Exit
			EndIf
		EndIf
	Next
EndIf

If aCols[n][_nPosDat] < _dVooS .or. aCols[n][_nPosDat] > _dVooC .And. !aCols[n][_nUsado+1] // Data
	_cMsgLOk := STR0042 //'Dados Incorretos, Verificar Perํodo Realizado na Viagem.'
	_lLineOk := .F.
EndIf

If Empty(aCols[n][_nPosCod]) .And. !aCols[n][_nUsado+1] // Cod Despesa
	_cMsgLOk := STR0043 //'Dados Incorretos, Selecione a Despesa.'
	_lLineOk := .F.
EndIf

If aCols[n][_nPosTCal] == 'ZEROM1' .And. _nAdiant <> 0 .And. !aCols[n][_nUsado+1]
	_lLineOk := .F.
	_cMsgLOk := STR0044 //'Dados Incorretos, Colaborador obteve Adiantamento.'
Endif

If Empty(aCols[n][_nPosQtd]) .And. aCols[n][_nPosTCal] <> 'ZEROM1' .And. !aCols[n][_nUsado+1] // Quant./ Colaborador sem Despesa
	_cMsgLOk := STR0045 //'Dados Incorretos, Verificar o campo Quantidade.'
	_lLineOk := .F.
EndIf

If Empty(aCols[n][_nPosVrt]) .And. aCols[n][_nPosTCal] <> 'ZEROM1' ;
	/*.And. aCols[n][_nPosTCal] <> 'CPMFM1'*/ .And. !aCols[n][_nUsado+1] // Valor / Colaborador sem Despesa
	_cMsgLOk := STR0046 //'Dados Incorretos, Verificar o campo Valor.'
	_lLineOk := .F.
EndIf

If aCols[n][_nUsado+1] .And. Len(aCols) == 0   // vazio
	_cMsgLOk := STR0047 //'Dados Incompletos, Incluir os Itens.'
	_lLineOk := .F.
EndIf

If aCols[n][_nUsado+1] // Deletado
	_lLineOk := .T.
EndIf

_nDiasRea := _dVooC - _dVooS + 1
If aCols[n][_nPosTCal] == 'LAV6M1' .And. _nDiasRea < GetMv("MV_LAVAN") .And. !aCols[n][_nUsado+1] // Lavanderia
	_cMsgLOk := STR0048 + AllTrim(Str(GetMv("MV_LAVAN"))) + STR0049 //'Dados Incorretos. O Perํodo Realizado na Viagem deverแ ter dura็ใo igual ou superior a '###' Dias para uso desta despesa!'
	_lLineOk := .F.
Endif

If _nDiasRea < 1 // Perํodo Realizado
	_cMsgLOk:= STR0050 //'Dados Incorretos, Perํodo Realizado na Viagem, Deverแ ter Dura็ใo Igual ou Superior a 1 (Um) Dia !'
	_lLineOk := .F.
Endif

If !_lLineOk
	MsgInfo(_cMsgLOk,STR0007) //'Aten็ใo'
EndIf

Return(_lLineOk)
*--------------------------------------------------------------------------------------

*--------------------------------------------------------------------------------------
Static Function SetHora(_cHora)
*--------------------------------------------------------------------------------------
Private _lSetHora := .T.

Do Case
	Case Len(Trim(_cHora)) < 5
		_lSetHora := .F.
	Case (Val(SubStr(_cHora,1,2)) < 0 .Or. Val(SubStr(_cHora,1,2)) > 23)
		_lSetHora := .F.
	Case (Val(SubStr(_cHora,4,2)) < 0 .or. Val(SubStr(_cHora,4,2)) > 59)
		_lSetHora := .F.
EndCase

If Empty(_cHora)
	_lSetHora := .T.
EndIf

Return(_lSetHora)

*--------------------------------------------------------------------------------------
Static Function GravaDesp(_nStatus)
*--------------------------------------------------------------------------------------
Local _nItem		:= 0
Local _nI
Local _cTpDes		:= Space(01)
Local _lDadosOk		:= .T.
Local _cCodPrest	:= Space(06)
Local _cUsLgAvulso 	:= AllTrim(SubStr(cUsuario,07,15))  
Local lPermiteAvl := ExistBlock("AEDVLCAVL")      
Local lTrataLcAvl := .F.
Local nX := 0

If lPermiteAvl //Existe o ponto de entrada AEDVLCAVL
	lTrataLcAvl := ExecBlock("AEDVLCAVL",.F.,.F.)
	If ValType(lTrataLcAvl) <> "L"
		lTrataLcAvl := .F.
	EndIf			
EndIf

If _lVisua //Se for visualizacao
	oPrincipal:End()
	Return .T.
EndIf

If _nStatus == 2 .OR. _lAltera
	_cTpDes := "A" //Despesa do tipo "Avulsa"
Else
	_cTpDes := "D"
EndIf

If Empty(LHP->LHP_Codigo) .Or. (_nStatus == 2 .And. !_lAltera)
	_cCodPrest:= GetSxeNum('LHP','LHP_CODIGO')	
Else
	_cCodPrest:= LHP->LHP_Codigo
EndIf

If !DadosOk(_nStatus)
	Return .F.
EndIf
  
If ExistBlock("VALIDPRES")
	_lDadosOk := ExecBlock("VALIDPRES", .F., .F.,{_cCodPrest,_dVooS,_cVooS,_dVooC,_cVooC,aHeader,aCols})
	If !_lDadosOk
		Return _lDadosOk 
	EndIf
EndIf       
U_Calcula()

Begin Transaction
If _nStatus == 2 .Or. _lAltera //Despesa Avulsa - Realizar gravacao dos itens de solicitacao
	//Grava dados na tabela de solicitacao
	If !_lAltera
		RecLock("LHP", .T.)
	Else
		RecLock("LHP", .F.)
	EndIf
	LHP->LHP_Codigo := _cCodPrest
	LHP->LHP_Filial := xFilial('LHP')
	LHP->LHP_Quem	:= STR0051 //'Despesa avulsa'
	LHP->LHP_Antec	:= STR0051 //'Despesa avulsa'
	LHP->LHP_FPrazo := .F. 
	LHP->LHP_Emiss	:= _dEmiss
	LHP->LHP_CC		:= _cCC
	LHP->LHP_Func	:= _cFunc
	LHP->LHP_NFunc	:= _cNFunc
	LHP->LHP_SupImd := _cSupImd
	//FNC : 00000025604/2009
	LHP->LHP_DGRAR	:= cDGRAR
	//
	LHP->LHP_EmpCli := _cEmpCli
	LHP->LHP_FatCLi := _nFatCli
	LHP->LHP_FatMic := _nFatMic
	LHP->LHP_Sistem := STR0052 //"CONTRA RECIBOS"
	LHP->LHP_Local	:= STR0053 //"Despesa avulsa"
	LHP->LHP_Saida	:= _dVooS
	LHP->LHP_Chegad := _dVooC
	If _nStatus == 2	//Avulso 
		//Nao existe antecipacao, estes campos de valor devem ficar zerados
		If lTrataLcAvl
			LHP->LHP_ValorR := _nAdiant
			LHP->LHP_ValorU := _nAdtUS
		Else
			LHP->LHP_ValorR := 0
			LHP->LHP_ValorU := 0
		EndIf
		LHP->LHP_EINTER := EhInter
	Else 
		LHP->LHP_ValorR := _nAdiant
		LHP->LHP_ValorU := 0       		
	Endif
	LHP->LHP_Banco	:= _cBanco
	LHP->LHP_Agenci := _cAgenci
	LHP->LHP_Conta	:= _cConta
	LHP->LHP_Flag	:= 'B'
	LHP->LHP_Flag1	:= 'B'
//	LHP->LHP_UmDia	:= Trim(Str(GetMV('MV_UmDia')))
//	LHP->LHP_RDia	:= Trim(Str(GetMV('MV_RDia')))
	LHP->LHP_ViaNac := '0'
	LHP->LHP_ViaInt := '0'
	LHP->LHP_KMI	:= GetMV('MV_KMI')
//	LHP->LHP_HSai	:= Trim(Str(GetMV('MV_HSai')))
//	LHP->LHP_HCheg	:= Trim(Str(GetMV('MV_HCheg')))
	LHP->LHP_SolPor := _cUsLgAvulso
	LHP->LHP_HrSolP := Time()
	MsUnLock('LHP')

	MSMM(,80,,STR0054,1,,,"LHP","LHP_CODMOT") //'Presta็ใo de Contas Avulsa, sem Solicita็ใo de Viagem.'

	If !_lAltera
		RecLock('LHQ', .T.)	
	Else
		RecLock('LHQ', .F.)	
	EndIf

	//Grava dados na tabela de despesas
	LHQ->LHQ_Filial := xFilial('LHQ')
	LHQ->LHQ_Codigo := _cCodPrest
	LHQ->LHQ_EmpCli := _cEmpCli
	LHQ->LHQ_Func	:= _cFunc
	LHQ->LHQ_SupImd := _cSupImd
	//FNC : 00000025604/2009
	LHQ->LHQ_DGRAR	:= cDGRAR
	//
	LHQ->LHQ_CC		:= _cCC
	LHQ->LHQ_FatCli := _nFatCli
	LHQ->LHQ_FatMic := _nFatMic
	
	If LHQ->LHQ_Flag <> 'P'
		LHQ->LHQ_Flag:= 'M'
	Endif

	LHQ->LHQ_SolPor := _cUsLgAvulso
	LHQ->LHQ_Login	:= _cUsLgAvulso
	MsUnLock('LHQ')
		
	If !Empty(_mObs)
		MSMM(,80,,_mObs,1,,,"LHQ","LHQ_CODOBS")
	Endif

EndIf

ConfirmSX8()

DbSelectArea('LHQ')
RecLock('LHQ',.F.)
LHQ->LHQ_Emiss	:= _dEmiss
LHQ->LHQ_DtSaid := _dVooS
LHQ->LHQ_HorSai := _cVooS
LHQ->LHQ_DtCheg := _dVooC
LHQ->LHQ_HorChg := _cVooC
If LHQ->LHQ_Flag <> 'P'
	LHQ->LHQ_Flag:= 'D'
Endif
LHQ->LHQ_Cheque := _cCheque

If _nDifer > 0 .And. _nReembo = 0
	_nReembo := _nDifer
EndIf

If _nDiferUS > 0 .And. _nReembUS = 0
	_nReembUS := _nDiferUS
EndIf

LHQ->LHQ_ValNR	:= _nDesemb - _nReembo
LHQ->LHQ_ValRb	:= _nReembo
LHQ->LHQ_CPMF	:= _nCPMF
LHQ->LHQ_ValNRD	:= _nGastoUS - _nReembUS
LHQ->LHQ_ValRbD	:= _nReembUS
LHQ->LHQ_TPDES	:= _cTpDes //Tipo da Despesa

MsUnLock('LHQ')

If !Empty(_mObs)
	MSMM(,80,,_mObs,1,,,"LHQ","LHQ_CODOBS")
Endif

_nItem := 0
For _nI := 1 to Len(aCols)
	If !aCols[_nI][_nUsado+1] // Deletado
		DbSelectArea('LHS')
		DbSetOrder(1)
		MsSeek(xFilial('LHS') + aCols[_nI][_nPosCod])
		
		DbSelectArea('LHR')
		DbSetOrder(1)
		If MsSeek(xFilial('LHR') + LHQ->LHQ_Codigo + aCols[_nI][1] )
			RecLock('LHR',.F.)
		Else
			RecLock('LHR',.T.)
		EndIf
		_nItem++

		For nX := 1 To Len(aHeader)
			If ( aHeader[nX][10] != "V" )
				If AllTrim(Upper(aHeader[nX][2])) == "LHR_MOEDA" .And. !EhInter
					LHR->(FieldPut(FieldPos(aHeader[nX][2]),1))				
				Else
					LHR->(FieldPut(FieldPos(aHeader[nX][2]),aCols[_nI][aScan(aHeader,{|x| AllTrim(Upper(x[2])) == AllTrim(Upper(aHeader[nX][2]))})]))
				EndIf
			EndIf
		Next nX

		LHR->LHR_Filial := xFilial('LHR')
		LHR->LHR_Item	:= StrZero(_nItem,3)
		LHR->LHR_Codigo := LHQ->LHQ_Codigo		

		//Ponto de entrada para gravacao de dados adicionais na tabela de itens de despesas
		If ExistBlock("AE_GRDESP")
			ExecBlock("AE_GRDESP",.F.,.F.)
		EndIf
		MsUnLock('LHR')
	Else
		DbSelectArea('LHR')
		DbSetOrder(1)
		If MsSeek(xFilial('LHR') + LHQ->LHQ_Codigo + aCols[_nI][1] )
			RecLock('LHR',.F.)
			dbDelete()
			MsUnLock('LHR')
		EndIf
	EndIf
Next    
End Transaction

Return .T.

*--------------------------------------------------------------------------------------
Static Function DadosOk(_nStatus)
*--------------------------------------------------------------------------------------
Local _lDadosOk := .T. , _cMsgDOk

If _lDadosOk .And. Empty(_dEmiss)
	_cMsgDOk  := STR0055 //'Data de Emissใo deve ser Informada.'
	_lDadosOk := .F.
EndIf

If _lDadosOk .And. Empty(_dVooS)
	_cMsgDOk  := STR0056 //'Data de Saํda do V๔o/Viagem deve ser Informada.'
	_lDadosOk := .F.
EndIf

If _lDadosOk .And. Empty(_cVooS)
	_cMsgDOk  := STR0057 //'Hora de Saํda do V๔o/Viagem deve ser Informada.'
	_lDadosOk := .F.
EndIf

If _lDadosOk .And. Empty(_dVooC)
	_cMsgDOk  := STR0058 //'Data de Chegada do V๔o/Viagem deve ser Informada.'
	_lDadosOk := .F.
EndIf

If _lDadosOk .And. Empty(_cVooC)
	_cMsgDOk  := STR0059 //'Hora de Chegada do V๔o/Viagem deve ser Informada.'
	_lDadosOk := .F.
EndIf

If _lDadosOk .And. !aCols[n][_nUsado+1] .And. (aCols[n][_nPosDat] < _dVooS .Or. aCols[n][_nPosDat] > _dVooC) // Data
	_cMsgDOk  := STR0060 //'Data Fora do Perํodo.'
	_lDadosOk := .F.
EndIf

If _lDadosOk .And. !aCols[n][_nUsado+1] .And. Empty(aCols[n][_nPosCod]) // Cod Despesa
	_cMsgDOk  := STR0061 //'C๓digo da Despesa nใo Informado.'
	_lDadosOk := .F.
EndIf

If _lDadosOk .And. !aCols[n][_nUsado+1] .And. Empty(aCols[n][_nPosQtd]) .And. aCols[n][_nPosTCal] <> 'ZEROM1' // Qtdade
	_cMsgDOk  := STR0062 //'Quantidade nใo Informada.'
	_lDadosOk := .F.
EndIf

If _lDadosOk .And. !aCols[n][_nUsado+1] .And. Empty(aCols[n][_nPosVrt]) .And. aCols[n][_nPosTCal] <> 'ZEROM1'
//	.And. aCols[n][_nPosTCal] <> 'CPMFM1' // Valor
	_cMsgDOk  := STR0063 //'Valor nใo Informado.'
	_lDadosOk := .F.
EndIf

If _lDadosOk .And. !aCols[n][_nUsado+1] .And. Empty(aCols[n][_nPosDesc]) // Descricao
	_cMsgDOk  := STR0064 //'Descri็ใo da Despesa nใo Informada.'
	_lDadosOk := .F.
EndIf

If _nStatus == 2 .OR. _lAltera	//Avulso
	If _nStatus # 2
		If _lDadosOk .And. Empty(_cSupImd)
			_cMsgDOk  := STR0065 //'Aprovador I nใo preenchido.'
			_lDadosOk := .F.
		EndIf
	
		If _lDadosOk .And. Empty(cDGRAR)
			_cMsgDOk  := STR0066 //'Aprovador II nใo preenchido.'
			_lDadosOk := .F.
		EndIf
	Endif	
	If _lDadosOk .And. Empty(_cCC)
		_cMsgDOk  := STR0067 //'Centro de custo nใo preenchido.'
		_lDadosOk := .F.
	EndIf
EndIf
	
If !_lDadosOk
	MsgInfo(_cMsgDOk,STR0007) //'Aten็ใo'
EndIf               

Return(_lDadosOk)

*--------------------------------------------------------------------------------------
User Function Calcula()
*--------------------------------------------------------------------------------------
Local _nI

_nAbatN 	 := 0
_nAbatI 	 := 0
_nVlrCPMF := 0
_nDesemb  := 0 //Valor Total em Reais
_nReembo  := 0 //Reembolsavel em Reais
_nGastoUS := 0 //Valor Total em Dolar
_nReembUS := 0 //Reembolsavel em Dolar
_nDifer   := 0
_nDiferUS := 0

LHS->(DbSetOrder(1))

For _nI := 1 To Len(aCols)
	If !aCols[_nI][_nUsado+1]
		If _nI == n .And. Type("M->LHR_VLRTOT") == "N"
			If aCols[_nI][_nPosMoe] <> 1 
				_nGastoUS += M->LHR_VLRTOT //Valor Total
			Else
				_nDesemb += M->LHR_VLRTOT //Valor Total
			EndIf
		Else
			If _nI == n .And. Type("M->LHR_MOEDA") == "N"
				If M->LHR_MOEDA <> 1 
					_nGastoUS += aCols[_nI][_nPosVrt] //Valor Total
				Else
					_nDesemb += aCols[_nI][_nPosVrt] //Valor Total
				EndIf
			Else
				If aCols[_nI][_nPosMoe] <> 1 
					_nGastoUS += aCols[_nI][_nPosVrt] //Valor Total
				Else
					_nDesemb += aCols[_nI][_nPosVrt] //Valor Total
				EndIf
			EndIf
		EndIf
                 
		If _nI == n .And. Type("M->LHR_MOEDA") == "N"
			If M->LHR_MOEDA <> 1
				_nReembUS += aCols[_nI][_nPosVbs] //Reembolsavel
			Else
				_nReembo += aCols[_nI][_nPosVbs] //Reembolsavel
			EndIf
		Else
			If aCols[_nI][_nPosMoe] <> 1 
				_nReembUS += aCols[_nI][_nPosVbs] //Reembolsavel
			Else
				_nReembo += aCols[_nI][_nPosVbs] //Reembolsavel
			EndIf
		EndIf

		LHS->(DbSeek(xFilial("LHS")+aCols[_nI][_nPosCod]))	
		If LHS->LHS_TIPO $ "E"
			If _nI == n .And. Type("M->LHR_MOEDA") == "N"
				If M->LHR_MOEDA <> 1
					_nAbatI += aCols[_nI][_nPosVrt]
				Else
					_nAbatN += aCols[_nI][_nPosVrt]
				EndIf
			Else
				If aCols[_nI][_nPosMoe] <> 1 
					_nAbatI += aCols[_nI][_nPosVrt]
				Else
					_nAbatN += aCols[_nI][_nPosVrt]
				EndIf
			EndIf		
		EndIf	
	EndIf
Next

If _nAbatN <= _nAdiant
	_nDifer = _nAdiant - _nReembo - _nAbatN
Else
	_nDifer = _nAbatN - _nAdiant
EndIf

If EhInter
	If _nAbatI <= _nAdtUS 
		_nDiferUS = _nAdtUS - _nReembUS - _nAbatI
	Else
		_nDiferUS = _nAbatI - _nAdtUS
	EndIf
EndIf

If GetMv('MV_INICPMF') //Se a empresa paga o CPMF, calcular...
	If _nDifer < 0
		_nCPMF := _nReembo * _nACPMF / 100
	Else
		_nCPMF := _nAdiant * _nACPMF / 100
	EndIf

	If _nAbatN <= _nAdiant
		_nDifer = _nAdiant - _nReembo - _nAbatN - _nCPMF
	Else
		_nDifer = _nAbatN - _nAdiant - _nReembo - _nCPMF
	EndIf

	_oCPMF:Refresh()
EndIf

_oDesemb:Refresh()
_oReembo:Refresh()
_oDifer:Refresh()

If EhInter
	_oGastoUS:Refresh()
	_oReembUS:Refresh()
	_oDiferUS:Refresh()
EndIf

Return

*--------------------------------------------------------------------------------------
/*Static Function Parametros()
*--------------------------------------------------------------------------------------
Local _xPar01,_xPar02,_xPar03,_xPar04,_xPar05,_xPar06,_xPar07,_xPar08

DEFINE MSDIALOG oParametros FROM  000,000 TO 285,350 TITLE OemToAnsi('Parโmetros do Processo') PIXEL

_xPar01 := LHP->LHP_Codigo
@ 010,005 SAY 'C๓digo da Solicita็ใo' OF oParametros PIXEL
@ 010,090 MSGET _xPar01 Picture '@!' When .F. Size 45,07 OF oParametros PIXEL

_xPar02 := Val(LHP->LHP_RDia)
@ 035,005 SAY 'Diแria em Reais    ' OF oParametros PIXEL
@ 035,090 MSGET _xPar02 Picture '@E 999,999.99' When .F. Size 40,07 OF oParametros PIXEL

_xPar03 := 'Reais'
@ 050,005 SAY 'Calcula em         ' OF oParametros PIXEL
@ 050,090 MSGET _xPar03 When .F. Size 45,07 OF oParametros PIXEL

_xPar04 := LHP->LHP_HSai
@ 065,005 SAY 'Hora Saํda Limite  ' OF oParametros PIXEL
@ 065,090 MSGET _xPar04 When .F. Size 45,07 OF oParametros PIXEL

_xPar05 := LHP->LHP_HCheg
@ 080,005 SAY 'Hora Chegada Limite' OF oParametros PIXEL
@ 080,090 MSGET _xPar05 When .F. Size 45,07 OF oParametros PIXEL

_xPar06 := Val(LHP->LHP_ViaNac)
@ 095,005 SAY 'Valor Translado R$ ' OF oParametros PIXEL
@ 095,090 MSGET _xPar06 Picture '@E 999,999.99' When .F. Size 40,07 OF oParametros PIXEL

_xPar08 := Val(SubStr(LHP->LHP_KmI,8,4))
@ 110,005 SAY 'Valor Quilometro I ' OF oParametros PIXEL
@ 110,090 MSGET _xPar08 Picture '@E 999,999.99' When .F. Size 40,07 OF oParametros PIXEL

_nDiasRea := _dVooC - _dVooS + 1
@ 125,005 SAY 'Quantidade de Diแria Realizada' OF oParametros PIXEL
@ 125,090 MSGET _nDiasRea Picture '@E 999999' When .F. Size 45,07 OF oParametros PIXEL

ACTIVATE DIALOG oParametro CENTERED

Return*/

//--------------------------------------------------------------------------------------
//Static Function LasU_Of(_cNomeL, _cTipoL, _nLinL, _nColL)
//--------------------------------------------------------------------------------------
/*Local _vChaveL, _lFlag

If _cTipoL == 'A' // Array de mem๓ria
	_lFlag := .F.
	If _nLinL + 1 > Len(&_cNomeL) // aCols
		_lFlag := .T.
	Else
		If &_cNomeL[_nLinL][_nColL] <> &_cNomeL[_nLinL + 1][_nColL]
			_lFlag := .T.
		EndIf
	EndIf
EndIf

Return(_lFlag)*/
                    
//--------------------------------------------------------------------------------------
Static Function VFunc() //Funcao para validacao do funcionario
//--------------------------------------------------------------------------------------
Local _lFunc := .T., _aAreaX := GetArea(), _nRegistro := LHQ->(Recno())

If !Empty(_cFunc)
	DbSelectArea('LHT')
	DbSetOrder(1)
	If MsSeek(xFilial('LHT') + _cFunc)
		_cNFunc	:= LHT->LHT_Nome
		_cBanco	:= SubStr(LHT->LHT_BcDepS,1,3)
		_cAgenci := SubStr(LHT->LHT_BcDepS,4,9)
		_cConta	:= LHT->LHT_CtDepS
		If GetMV('MV_MCONTAB') == "CTB"
			dbSelectArea("CTT")
			CTT->(dbSetOrder(1))
			If CTT->(dbSeek(xFilial("CTT") + LHT->LHT_CC)) .AND. !Empty(LHT->LHT_CC)
				If !Empty(_cCC) .AND. _cCC # LHT->LHT_CC
					If ApMsgYesNo(STR0068 + AllTrim(LHT->LHT_CC) + STR0069 + CRLF + STR0070) //"O CC associado do solicitador ("###") ้ diferente do estabelecido no campo de CC."###"Deseja alterแ-lo?"
						_cCC := LHT->LHT_CC
					Endif
				Else
					_cCC := LHT->LHT_CC
				Endif
			Else
				If Empty(_cCC) 
					_cCC := " "
				Endif
			Endif
        Else 
			dbSelectArea("SI3")
			SI3->(dbSetOrder(1))
			If SI3->(dbSeek(xFilial("SI3") + LHT->LHT_CC)) .AND. !Empty(LHT->LHT_CC)
				If !Empty(_cCC) .AND. _cCC # LHT->LHT_CC
					If ApMsgYesNo(STR0068 + AllTrim(LHT->LHT_CC) + STR0069 + CRLF + STR0070) //"O CC associado do solicitador ("###") ้ diferente do estabelecido no campo de CC."###"Deseja alterแ-lo?"
						_cCC := LHT->LHT_CC
					Endif
				Else
					_cCC := LHT->LHT_CC
				Endif
			Else
				If Empty(_cCC) 
					_cCC := Space(TamSX3("I3_CUSTO")[1])
				Endif
			Endif        
        Endif
		If Empty(LHT->LHT_EMAIL)
			MsgInfo(STR0071, STR0007) //'Colaborador nใo possui Conta de Email Cadastrado.'###'Aten็ใo'
			_lFunc := .F.
		Endif
	Else
		MsgInfo(STR0072, STR0007) //'Colaborador nใo Cadastrado.'###'Aten็ใo'
		_lFunc := .F.
	EndIf
Else
	_cNFunc  := ''
	_cBanco  := ''
	_cAgenci := ''
	_cConta  := ''
EndIf

_oBanco:Refresh()
_oAgenci:Refresh()
_oConta:Refresh()

If _lFunc .And. !Empty(_cFunc) // Verifica atraso na prestacao de contas do Colaborador
	_aAreaLHQa := GetArea()
	
	DbSelectArea('LHQ')
	DbSetOrder(4)
	If MsSeek(xFilial('LHQ') + _cFunc)
		Do While !Eof() .And.;
			LHQ->LHQ_Filial == xFilial('LHQ') .And.;
			LHQ->LHQ_FUNC  == _cFunc
			If LHQ->LHQ_FLAG == 'P'
				MsgInfo(STR0073, STR0074) //'Colaborador com Presta็ใo de Contas em Atraso, Solicita็ใo Bloqueada !'###"Aten็ใo"
				_lFunc := .F.
				Exit
			EndIf
			DbSkip()
		EndDo
	EndIf
	DbSetOrder(1)
	RestArea(_aAreaLHQa)
Endif
RestArea(_aAreaX)         
DbSelectArea('LHQ')
DbSetOrder(1)
DbGoto(_nRegistro)
Return(_lFunc)

//--------------------------------------------------------------------------------------
Static Function VSupImd(nAprov) //Valida Primeiro Aprovador e exibe seu nome 
//--------------------------------------------------------------------------------------
Local _lSupImd 		:= .T.
Local _aAreaLHQa	:= GetArea()

If !Empty(IIf(nAprov==1,_cSupImd,cDGRAR))
	dbSelectArea('LHT')
	LHT->(dbSetOrder(1))
	If MsSeek(xFilial('LHT') + IIf(nAprov==1,_cSupImd,cDGRAR))
		Do Case 
			Case nAprov == 1
				_cNSupImd := LHT->LHT_Nome
				If _cSupImd == _cFunc
					MsgInfo(STR0075, 'Aten็ใo') //'Colaborador nใo pode Aprovar sua Pr๓pria Viagem.'
					_lSupImd := .F.
				Endif
				If Empty(LHT->LHT_EMAIL) 
					MsgInfo(STR0071, 'Aten็ใo') //'Colaborador nใo possui conta de Email Cadastrado.'
					_lSupImd := .F.
				Endif
				If LHT->LHT_FLAGAP # '1'
					If LHT->LHT_APFIN # "1"
						MsgInfo(STR0076, 'Aten็ใo') //'Colaborador nใo autorizado a aprovar solicita็๕es de viagens.'
					Else                
						MsgInfo(STR0077, STR0007) //'Colaborador aut. a aprovar solicita็๕es de viagens apenas como aprovador II.'###'Aten็ใo'
					Endif
					_lSupImd := .F.
				Endif
			Case nAprov == 2
				cNDGRAR := LHT->LHT_Nome
				If cDGRAR == _cFunc
					MsgInfo(STR0075, STR0007) //'Colaborador nใo pode Aprovar sua Pr๓pria Viagem.'###'Aten็ใo'
					_lSupImd := .F.
				Endif
				If Empty(LHT->LHT_EMAIL)
					MsgInfo(STR0071, STR0007) //'Colaborador nใo possui conta de Email Cadastrado.'###'Aten็ใo'
					_lSupImd := .F.
				Endif
				If LHT->LHT_APFIN # "1"
					If LHT->LHT_FLAGAP # "1"
						MsgInfo(STR0076, STR0007) //'Colaborador nใo autorizado a aprovar solicita็๕es de viagens.'###'Aten็ใo'
					Else                
						MsgInfo(STR0078, STR0007) //'Colaborador aut. a aprovar solicita็๕es de viagens apenas como aprovador I.'###'Aten็ใo'
					Endif
					_lSupImd := .F.
				Endif			
		EndCase
	Else
		MsgInfo(STR0072, STR0007) //'Colaborador nใo Cadastrado.'###'Aten็ใo'
		_lSupImd := .F.
	EndIf
Else
	If nAprov == 1
		_cNSupImd := ""
	Else
		cNDGRAR	:= ""
	Endif
EndIf
RestArea(_aAreaLHQa)

Return(_lSupImd)

//--------------------------------------------------------------------------------------
Static Function VEmpCli() //Valida codigo do cliente, exibe nome e cidade do cliente
//--------------------------------------------------------------------------------------
Local _lEmpCli := .T., _aAreaLHQa := GetArea()

If !Empty(_cEmpCli)
	DbSelectArea('SA1')
	DbSetOrder(1)
	_cLojaCli := SA1->A1_LOJA 
	If MsSeek(xFilial('SA1') + _cEmpCli + _cLojaCli)
		_cNEmpCli := SA1->A1_Nome
		DbSelectArea('LDY')
		DbSetOrder(2)
		//Procura Cidade + Estado na tabela de municipios para trazer o codigo automatico 
		//do cliente case esteja cadastrado.
		If MsSeek(xFilial('LDY') + 	Left( (SA1->A1_MUN + Space(TamSX3('LDY_NOME')[1])), TamSX3('LDY_NOME')[1] ) + SA1->A1_EST )
			_cCodCidade	:= LDY->LDY_CODIGO
			_cMun 		:= LDY->LDY_NOME
		EndIf			
	Else
		_lEmpCli := .F.
		MsgInfo(STR0079, STR0007) //'Empresa/Cliente nใo Cadastrado.'###'Aten็ใo'
	EndIf
Else
	_cNEmpCli := ''
EndIf

SA1->(DbGoTop())
RestArea(_aAreaLHQa)

Return(_lEmpCli)

//--------------------------------------------------------------------------------------
Static Function VCC() //Valida Centro de Custo Preenchido na Solicitacao
//--------------------------------------------------------------------------------------
Local _lVCC := .T., _aAreaLHQa := GetArea()
Local cContab:=GetMV('MV_MCONTAB')

If !Empty(_cCC)

	If cContab == 'CON'
		DbSelectArea('SI3')
		DbSetOrder(1)
		If !MsSeek(xFilial('SI3') + _cCC)
			MsgInfo(STR0080, STR0007) //'Centro de Custo nใo Cadastrado !'###'Aten็ใo'
			_lVCC := .F.
		EndIf
	ElseIf cContab == 'CTB'
		DbSelectArea('CTT')
		DbSetOrder(1)
		If !MsSeek(xFilial('CTT') + _cCC)
			MsgInfo(STR0080, STR0007) //'Centro de Custo nใo Cadastrado !'###'Aten็ใo'
			_lVCC := .F.
		EndIf
		If CTT->CTT_BLOQ == "1" //Valida se o centro de custo selecionado estแ bloqueado
			MsgInfo(STR0089, STR0007) //'Centro de Custo Bloqueado!'###'Aten็ใo'
			_lVCC := .F.
		EndIf
	EndIf
EndIf
RestArea(_aAreaLHQa)
Return(_lVCC)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบProgramaณAE_AprovFin บAutor  ณRicardo A. Canteras บ Data ณ  13/04/07   บฑฑ
ฑฑฬออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.   ณ Funcao para alteracao dos Parametros SX6					        บฑฑ
ฑฑฬออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso     ณ CDV - Controle de Despesas de Viagens 					  		  บฑฑ
ฑฑศออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

User Function AE_AprovFin()
                                  
Local oPanel

PRIVATE _cWFANAC1 := Pad(GetMv("MV_WFANAC1",,""),TamSX3("LHT_CODMAT")[1])//Matricula Aprovador Suplente (1a Aprova็ใo)
PRIVATE _cWFANAC2 := Pad(GetMv("MV_WFANAC2",,""),TamSX3("LHT_CODMAT")[1])//Matricula Aprovador Suplente (2a Aprova็ใo)
PRIVATE _cWFCPMF  := GetMv("MV_ACPMF",,"0.38")//Porcentagem CPMF
PRIVATE _cWFLAVAN := GetMv("MV_LAVAN",,"3")//Dias para autorizar uso de lavanderia
PRIVATE _cWFHRINI := GetMv("MV_WFHINI",,"0600")//Horario Inicio Workflow
PRIVATE _cWFHRFIM := GetMv("MV_WFHFIM",,"2400")//Horario Fim Workflow
PRIVATE _cWFAGTUR := Pad(GetMv("MV_WFAGTUR",,""),60)//Conta de Email da agencia de Viagem

DEFINE MSDIALOG oAprovador FROM  000,000 TO 190,490 TITLE STR0081 PIXEL //'Parโmetros Principais do Template - CDV'

oPanel := TPanel():New(0,0,'',oAprovador,, .T., .T.,, ,140,140,.T.,.T. )
oPanel:Align := CONTROL_ALIGN_TOP

_nRow:= 6
_nRow+=9
@ _nRow,005 SAY STR0082 OF oPanel PIXEL   //'Porc. CPMF %'
@ _nRow,075 MSGET _cWFCPMF Picture '@E 99.99' Size 35,07 OF oPanel PIXEL

@ _nRow,130 SAY STR0083 OF oPanel PIXEL //'No. Dias Lavanderia'
@ _nRow,200 MSGET _cWFLAVAN Picture '999999' Size 35,07 OF oPanel PIXEL

_nRow+=13
@ _nRow,005 SAY STR0084 OF oPanel PIXEL //'Matricula 1o. Aprov. Sup.'
@ _nRow,075 MSGET _cWFANAC1 Picture '@!' Size 35,07 OF oPanel PIXEL

@ _nRow,130 SAY STR0085 OF oPanel PIXEL //'Matricula 2o. Aprov. Sup.'
@ _nRow,200 MSGET _cWFANAC2 Picture '@!' Size 35,07 OF oPanel PIXEL

_nRow+=13
@ _nRow,005 SAY STR0086 OF oPanel PIXEL //'Hora Inicio WorkFlow'
@ _nRow,075 MSGET _cWFHRINI Picture '9999' Size 35,07 OF oPanel PIXEL

@ _nRow,130 SAY STR0087 OF oPanel PIXEL //'Hora Fim WorkFlow'
@ _nRow,200 MSGET _cWFHRFIM Picture '9999' Size 35,07 OF oPanel PIXEL

_nRow+=17

@ _nRow,005 SAY STR0088 OF oPanel PIXEL //'E-mail Ag. de Viagem'
@ _nRow,060 MSGET _cWFAGTUR Picture '@!' Size 175,07 OF oPanel PIXEL

ACTIVATE MSDIALOG oAprovador ON INIT EnchoiceBar( oAprovador, { || WFGravaSx6()}, { || oAprovador:End()} ) CENTERED

Return(.T.)

*--------------------------------------------------------------------------------------
Static Function WFGravaSx6()
*--------------------------------------------------------------------------------------

PutMv("MV_WFANAC1",_cWFANAC1)//Matricula Aprovador Suplente (1a Aprova็ใo)
PutMv("MV_WFANAC2",_cWFANAC2)//Matricula Aprovador Suplente (2a Aprova็ใo)
PutMv("MV_ACPMF",_cWFCPMF)//Porcentagem CPMF
PutMv("MV_LAVAN",_cWFLAVAN)//Dias para autorizar uso de lavanderia
PutMv("MV_WFHINI",_cWFHRINI)//Horario Inicio Workflow
PutMv("MV_WFHFIM",_cWFHRFIM)//Horario Fim Workflow
PutMv("MV_WFAGTUR",_cWFAGTUR)//Conta de Email da agencia de Viagem

oAprovador:End()

Return(Nil)
