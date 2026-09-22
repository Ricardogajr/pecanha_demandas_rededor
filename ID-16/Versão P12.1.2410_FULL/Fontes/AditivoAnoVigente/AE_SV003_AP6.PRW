#INCLUDE "AE_SV003_AP6.ch"
#INCLUDE "Protheus.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³AE_SV003  ºAutor  ³Armando / Willy     º Data ³  09/06/02   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³  Impressão da Solicitação de Viagem.                       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP6                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function AE_SV003(_lSV003)

Local lImpres  := ExistBlock("SVIMPRES")
Private aMemos := {{"LHP_CODMOT","LHP_MOTMEM","LHP_CODOBS","LHP_OBSMEM"}}
Private _cUsuaViagem := GetMv('MV_USVIAGE')
Private _cUsLogin    := AllTrim(SubStr(cUsuario,7,15))

chktemplate("CDV")

IF lImpres
	ExecBlock("SVIMPRES",.F.,.F.)	
Else
	If _cUsLogin $ AllTrim(_cUsuaViagem) // Verifica se eh o usuario do Depto de Viagem.
		_lSV003:= .F.
	Endif
	
	If _lSV003
		If LHP->LHP_Flag == 'K' //Solicitacao cancelada
			MsgInfo(STR0001) //"Esta solicitação está cancelada e não pode ser Reimpressa."
			Return
		EndIf
		If LHP->LHP_Flag <> 'D'
			MsgInfo(STR0002, STR0003) //'Solicitação Encaminhada não pode ser Reimpressa !'###'Atenção'
			Return(Nil)
		EndIf
	EndIf
EndIf

oPrint := fwMSPrinter():New(STR0004) //'Solicitação de Viagem'
// nome          Li  Co  Fro   N  ? ? ?   I    U
oFont10  := TFont():New("Courier New", 10, 10, .F., .F., , , , .F., .F.)
oFont11N := TFont():New("Courier New", 11, 11, .F., .T., , , , .F., .F.)
oFont12  := TFont():New("Tahoma", 12, 12, .F., .F., , , , .F., .F.)
oFont12N := TFont():New("Tahoma", 12, 12, .F., .T., , , , .F., .F.)
oFont14  := TFont():New("Tahoma", 14, 14, .F., .F., , , , .F., .F.)
oFont14N := TFont():New("Tahoma", 14, 14, .F., .T., , , , .F., .F.)
oFont20N := TFont():New("Tahoma", 20, 20, .F., .T., , , , .F., .F.)
oFont26N := TFont():New("Tahoma", 26, 26, .F., .T., , , , .F., .F.)

oPrint:SetPortrait()

MsgRun(STR0005,"",{|| CursorWait(), MontaRel(oPrint) ,CursorArrow()}) //'Gerando Visualização, Aguarde...'

oPrint:Preview()

Return(Nil)
*--------------------------------------------------------------------------------------


*--------------------------------------------------------------------------------------
Static Function MontaRel()
*--------------------------------------------------------------------------------------
Local _nValorU

oPrint:SayBitmap(100, 100, "\sigaadv\Lgrl00.bmp", 530, 120)

oPrint:Say(100, 750, STR0006, oFont26N) //"Solicitação de Viagem"

If LHP->LHP_FLAG == "K"
	oPrint:Say(110, 1560, "(" + STR0047 + ")", oFont20N)
EndIf

oPrint:Box( 0125, 2000, 0210, 2300 )
oPrint:Say(135, 2050, LHP->LHP_Codigo, oFont14N)

oPrint:Line( 0250, 0100, 0250, 2300 )

oPrint:Box( 0470, 1695, 0550, 2315 )
oPrint:Say(0410, 1695, STR0007, oFont14N) //'Solicitante / País'
If SubStr(LHP->LHP_Quem,1,1) == 'M'
	oPrint:Say(0480, 1700, SubStr(LHP->LHP_Quem,1,30), oFont14)
Else
	oPrint:Say(0480, 1700, SubStr(LHP->LHP_Quem,5,30), oFont12)
EndIf
DbSelectArea('LHT')
DbSetOrder(1)
MsSeek(xFilial('LHT') + LHP->LHP_Func)
oPrint:Say(0300, 0100, STR0008, oFont14N) //'Colaborador'
oPrint:Say(0300, 0600, LHT->LHT_CODMAT + ' - ' + LHT->LHT_Nome, oFont14)

oPrint:Say(0300, 1695, STR0009, oFont14N) //'C. Custo'
oPrint:Say(0300, 1935, LHP->LHP_CC, oFont14)

MsSeek(xFilial('LHT') + LHP->LHP_SupImd)
oPrint:Say(0400, 0100, STR0010, oFont14N) //'Aprovador I '
oPrint:Say(0400, 0600, LHT->LHT_CODMAT + ' - ' + LHT->LHT_Nome, oFont14)

MsSeek(xFilial('LHT') + LHP->LHP_DGRar)
oPrint:Say(0500, 0100, STR0011, oFont14N) //'Aprovador II'
oPrint:Say(0500, 0600, LHT->LHT_CODMAT + ' - ' + LHT->LHT_Nome, oFont14)

DbSelectArea('SA1')
DbSetOrder(1)
MsSeek(xFilial('SA1') + LHP->LHP_EmpCli)
oPrint:Say(600, 100, STR0012, oFont14N) //'Empresa'
oPrint:Say(600, 0600, SA1->A1_Cod + ' - ' + SA1->A1_Nome, oFont14)

oPrint:Say(700, 100, STR0013, oFont14N) //'Local da Viagem'
oPrint:Say(700, 0600, LHP->LHP_Local, oFont14)

oPrint:Say(700, 1350, STR0014, oFont14N) //'Sistema Adotado'
oPrint:Say(700, 1800, LHP->LHP_Sistem, oFont14)

oPrint:Say(0800, 0100, STR0015, oFont12N) //'Período da Viagem'
oPrint:Box( 0850, 0100, 0950, 2300 )

_cData := SubStr(DtoS(LHP->LHP_Saida),7,2) + '/' +;
SubStr(DtoS(LHP->LHP_Saida),5,2) + '/' +;
SubStr(DtoS(LHP->LHP_Saida),1,4)
oPrint:Say(0880, 0130, STR0016, oFont12N) //'Data da Saída'
oPrint:Say(0880, 0450, _cData,  oFont14)

_cData := SubStr(DtoS(LHP->LHP_Chegad),7,2) + '/' +;
SubStr(DtoS(LHP->LHP_Chegad),5,2) + '/' +;
SubStr(DtoS(LHP->LHP_Chegad),1,4)
oPrint:Say(0880, 1280, STR0017, oFont12N) //'Data do Retorno'
oPrint:Say(0880, 1650, _cData,  oFont14)

// U_MRegua(900,.T.)

oPrint:Say(1000, 0100, STR0018, oFont12N) //'Motivo da Viagem'
oPrint:Box( 1050, 0100, 1300, 2300 )

_mMotivo := MSMM(LHP->LHP_CodMot,,,,3)
U_ImpMemo(1070, 0130, 45, 7, 97, oFont10, _mMotivo, oPrint)
// 01-> Posicao em Pixel da Linha
// 02-> Posicao em Pixel da Coluna
// 03-> Tamanho em Pixel da largura da linha
// 04-> Tamanho de caracteres e imprimir na linha
// 05-> Numero maximo de linhas a imprimir
// 06-> Fonte utilizada na impressao (Courrier New)
// 07-> Texto a ser impresso

oPrint:Say(1350, 0100, STR0019, oFont12N) //'Preferência por Vôo'
oPrint:Box( 1400, 0100, 1580, 2300 )

oPrint:Say(1430, 0130, STR0020, oFont12N) //'Ida Vôo'
oPrint:Say(1430, 0400, LHP->LHP_VooIda,  oFont12)

oPrint:Say(1500, 0130, STR0021, oFont12N) //'Volta Vôo'
oPrint:Say(1500, 0400, LHP->LHP_VooVta,  oFont12)

oPrint:Say(1430, 0900, STR0022, oFont12N) //'Horário'
oPrint:Say(1430, 1100, LHP->LHP_HoraId,  oFont12)

oPrint:Say(1500, 0900, STR0022, oFont12N) //'Horário'
oPrint:Say(1500, 1100, LHP->LHP_HoraVt,  oFont12)

oPrint:Say(1430, 1700, STR0023, oFont12N) //'Cia Aérea'
oPrint:Say(1430, 1950, LHP->LHP_AirIda,  oFont12)

oPrint:Say(1500, 1700, STR0023, oFont12N) //'Cia Aérea'
oPrint:Say(1500, 1950, LHP->LHP_AirVta,  oFont12)

oPrint:Say(1650, 0100, STR0024, oFont14N) //'Fatura Cliente'
oPrint:Say(1650, 0500, Transform(LHP->LHP_FatCli, '@E 999') + ' %', oFont14)

oPrint:Say(1650, 0950, STR0025, oFont14N) //'Fatura Franquia'
oPrint:Say(1650, 1400, Transform(LHP->LHP_FatFra, '@E 999') + ' %', oFont14)

oPrint:Say(1650, 1750, STR0026, oFont14N) //'Não Faturar'
oPrint:Say(1650, 2130, Transform(LHP->LHP_FatMic, '@E 999') + ' %', oFont14)

// U_MRegua(1750,.F.)

If LHP->LHP_Adiant
	oPrint:Say(1750, 0100, STR0027, oFont14N) //'[Sim]'
Else
	oPrint:Say(1750, 0100, STR0028, oFont14N) //'[Não]'
EndIf
oPrint:Say(1750, 0250, STR0029, oFont14) //'Adiantamento'

If LHP->LHP_Passag
	oPrint:Say(1850, 0100, STR0027, oFont14N) //'[Sim]'
Else
	oPrint:Say(1850, 0100, STR0028, oFont14N) //'[Não]'
EndIf
oPrint:Say(1850, 0250, STR0030, oFont14) //'Passagem'
oPrint:Say(1850, 0600, STR0031, oFont14N) //'Obs:'
oPrint:Say(1860, 0730, LHP->LHP_HPass, oFont12)

If LHP->LHP_Hosped
	oPrint:Say(1950, 0100, STR0027, oFont14N) //'[Sim]'
Else
	oPrint:Say(1950, 0100, STR0028, oFont14N) //'[Não]'
EndIf
oPrint:Say(1950, 0250, STR0032, oFont14) //'Hospedagem'
oPrint:Say(1950, 0600, STR0031, oFont14N) //'Obs:'
oPrint:Say(1960, 0730, LHP->LHP_HHosp, oFont12)

oPrint:Say(2050, 0100, STR0033, oFont12N) //'Observações Gerais'
oPrint:Box( 2100, 0100, 2300, 2300 )

_mObs := MSMM(LHP->LHP_CodObs,,,,3)
If LHP->LHP_FPrazo
	_mObs:= STR0034+ ; //'Solicitação de viagem esta sendo realizada fora do prazo de antecedência conforme regulamento de '
	STR0035+; //'viagem no item 3.1.2 contida no ITA (Instrução de Trabalho Administrativa) número 000201 de 26/11/2001 '
	STR0036+ _mObs //'versão 00, com vigência a partir de 01/12/2001.'
EndIf

U_ImpMemo(2120, 0130, 45, 4, 97, oFont10, _mObs, oPrint)
// 01-> Posicao em Pixel da Linha
// 02-> Posicao em Pixel da Coluna
// 03-> Tamanho em Pixel da largura da linha
// 04-> Numero maximo de linhas a imprimir
// 05-> Tamanho de caracteres e imprimir na linha
// 06-> Fonte utilizada na impressao (Courrier New)
// 07-> Texto a ser impresso

oPrint:Box( 2370, 0100, 2580, 2300 )
oPrint:Say(2400, 0130, STR0037, oFont14N) //'Valores em R$'
oPrint:Say(2400, 0600, Transform(LHP->LHP_ValorR, '@E 999,999.99'), oFont14)

_nValorU  := LHP->LHP_ValorU + LHP->LHP_VAdiM2
oPrint:Say(2400, 1350, STR0038, oFont14N) //'Valores em US$'
oPrint:Say(2400, 1820, Transform(_nValorU, '@E 999,999.99'), oFont14)

oPrint:Say(2500, 0130, STR0039, oFont14N) //'Depósito em conta corrente n.'
oPrint:Say(2500, 0910, LHP->LHP_Conta, oFont14)

oPrint:Say(2500, 1350, STR0040, oFont14N) //'Agência'
oPrint:Say(2500, 1600, LHP->LHP_Agenci, oFont14)

oPrint:Say(2500, 1980, STR0041, oFont14N) //'Banco'
oPrint:Say(2500, 2150, LHP->LHP_Banco, oFont14)

_cData := SubStr(DtoS(LHP->LHP_Emiss),7,2) + '/' +;
SubStr(DtoS(LHP->LHP_Emiss),5,2) + '/' +;
SubStr(DtoS(LHP->LHP_Emiss),1,4)

oPrint:Say(2620, 0100, STR0042, oFont12N) //'Solicitado'
oPrint:Say(2620, 0370, _cData, oFont12N)
oPrint:Say(2620, 0657, STR0043, oFont12N) //'Por'
oPrint:Say(2620, 0747, LHP->LHP_SolPor, oFont12N)

oPrint:Say(2620, 1900, STR0044, oFont14N) //'Revisão =>'
oPrint:Say(2620, 2235, StrZero(LHP->LHP_Impres,2), oFont14N)

oPrint:Line( 3000, 0200, 3000, 0700 )
oPrint:Say(3000, 0270, STR0010, oFont10) //'Aprovador I '

oPrint:Line( 3000, 0950, 3000, 1450 )
oPrint:Say(3000, 1040, STR0045, oFont10) //'Diretor Controller'

oPrint:Line( 3000, 1700, 3000, 2200 )
oPrint:Say(3000, 1800, STR0046, oFont10) //'Contas a Pagar'

Return(Nil)

 