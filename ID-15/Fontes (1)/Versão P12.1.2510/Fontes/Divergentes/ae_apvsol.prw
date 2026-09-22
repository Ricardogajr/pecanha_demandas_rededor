#INCLUDE "AE_APVSOL.CH"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออปฑฑ
ฑฑบPrograma  ณAE_APVSOL_AP6บAutor  ณMarcel Borges       บ Data ณ  26/12/07 บฑฑ
ฑฑฬออออออออออุอออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออนฑฑ
ฑฑบDesc.     ณMbrowse da Aprovacao da Solicita็ใo de Viagem.               บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณAP6                                                          บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

User Function AE_APVSOL()

Local cUsLogin		:= Alltrim(Substr(UsrRetName(__cUserID),1,TamSX3("LHT_LOGIN")[1]))
Local cCodUsr		:= ""
Private aCores
Private aRotina 
Private cCadastro
Private _cPerg 	:= "VIA002"
Private _cFilSOl 	:= ""
Private _aIndexLHP	:= {}
Private bFiltraBrw	:= {|| Nil}

ChkTemplate("CDV")

// M - Marrom    -> Solicita็ใo Iniciada
// D - Verde     -> Para Aprova็ใo
// I - Amarela   -> Aguardando Aprovacao
// A - AZUL      -> Solicita็ใo Aprovada
// P - PRETO     -> Solicita็ใo Reprovada
// E - Laranja   -> Encaminhado
// B - Branco    -> Presta็ใo de Contas sem Solicita็ใo
// C - Vermelho  -> Respectivo acerto concluido
// Z - Cinza     -> Fechamento da Viagem

aCores := {	{ 'LHP_Flag1 = "M"', 'BR_MARROM'  	},;
			{ 'LHP_Flag = "D" .or. LHP_Flag1 = "D"', 'BR_VERDE'   	},;
			{ 'LHP_Flag = "I" .or. LHP_Flag1 = "I"', 'BR_AMARELO' 	},;
			{ 'LHP_Flag1 = "A"', 'BR_AZUL'    	},;
			{ 'LHP_Flag1 = "P"', 'BR_PRETO'   	},;
			{ 'LHP_Flag1 = "E"', 'BR_LARANJA' 	},;
			{ 'LHP_Flag1 = "K"', 'BR_PINK'		},;
			{ 'LHP_Flag1 = "B"', 'BR_BRANCO'  	},;
			{ 'LHP_Flag1 = "C"', 'BR_VERMELHO'	},;
			{ 'LHP_Flag1 = "Z"', 'BR_CINZA'   	} }

dbSelectArea('LHP')

aRotina := {{STR0001	,'PesqBrw'			,0, 1},; //"Pesquisa"
			{STR0002	,'U_AE_SV001(0)'	,0, 2},; //"Visualiza"
			{STR0003	,'U_AE_SV003(.F.)'	,0, 2},; //"Imprimir"
			{STR0004	,'U_AE_SV006(1)'	,0, 4},; //"Aprovador  1"
			{STR0005   	,'U_AE_SV006(2)'	,0, 5},; //"Aprovador  2"
			{STR0006	,'U_Cancela("D")'	,0, 6},; //"Cancelar"
			{STR0007	,'U_AE_AprovFin()'  ,0, 7},; //"Parametros"
			{STR0008	,'U_AE_FV002'		,0, 2} } //"Legenda"
cCadastro := STR0009  //"Departamento de Viagem"

dbSelectArea("LHT")
LHT->(dbSetOrder(4))
If LHT->(dbSeek(xFilial("LHT")+ cUsLogin))
	cCodUsr := LHT->LHT_CODMAT
Else
	Msgalert(STR0010)      //"Usuแrio nใo cadastrado como Colaborador/Aprovador"
    Return
Endif

If Pergunte(_cPerg,.T.)
	dbSelectArea("LHP")
	LHP->(dbSetOrder(1))
	If Mv_Par01 == 1 //"Para Aprova็ใo"
		_cFilSOl := '(LHP->LHP_Flag == "D" .or. LHP->LHP_Flag1 == "D").And.'
	ElseIf Mv_Par01 == 2 //"Aguardando Ap."
		_cFilSOl := '(LHP->LHP_Flag == "I" .or. LHP->LHP_Flag1 == "I").And.'
	ElseIf Mv_Par01 == 3// "Aprovadas"
		_cFilSOl := 'LHP->LHP_Flag1 == "A".And.'
	ElseIf Mv_Par01 == 4 //"Encaminhadas"
		_cFilSOl := 'LHP->LHP_Flag1 == "E".And.'
	Endif
	_cFilSOl += '(dTos(LHP_EMISS)>="' + dTos(Mv_PAR02) + '" .And. dTos(LHP_EMISS)<="' + dTos(Mv_PAR03) + '" ).And.'
	_cFilSOl += '(dTos(LHP_SAIDA)>="' + dTos(Mv_PAR04) + '" .And. dTos(LHP_SAIDA)<="' + dTos(Mv_PAR05) + '" ).And.'
	_cFilSOl += '(Alltrim(LHP->LHP_SUPIMD) $ "' + AllTrim(cCodUsr) +  '" .OR. AllTrim(LHP->LHP_DGRAR)$ "' + AllTrim(cCodUsr) + '")'

	MsAguarde({ || LHPFilter() }, STR0011) //"Selecionando Viagens ..."
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Endereca a funcao de BROWSE                              ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	
	mBrowse(6, 1, 22, 75, "LHP",,,,,, aCores)
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Finaliza o uso da funcao FilBrowse e retorna os indices padroes.       ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	EndFilBrw("LHP",_aIndexLHP)
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณRestaura a condicao de Entrada                                          ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
EndIf	                       

Return

*--------------------------------------------------------------------------------------
Static Function LHPFilter()
*--------------------------------------------------------------------------------------

bFiltraBrw	:= {|| FilBrowse("LHP",@_aIndexLHP,@_cFilSOl)}
Eval(bFiltraBrw)

Return(.T.)
