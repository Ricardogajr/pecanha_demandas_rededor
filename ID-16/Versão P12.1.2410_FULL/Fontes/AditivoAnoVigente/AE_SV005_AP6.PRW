#INCLUDE "AE_SV005_AP6.ch"
#INCLUDE "Protheus.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAE_SV005  บAutor  ณArmando / Willy     บ Data ณ  09/06/02   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณLegenda                                                     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณTemplate CDV - Controle de Despesas de Viagens              บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

User Function AE_SV005()

Local cCadastro := STR0001 //"Solicita็ใo de Viagem"

ChkTemplate("CDV")

aCores2 := { 	{ 'BR_VERDE'   	, STR0002 },; //"Montando Solicita็ใo                  "
				{ 'BR_AMARELO' 	, STR0003 },; //"Aguardando Aprova็ใo Workflow         "
				{ 'BR_AZUL'    	, STR0004 },; //"Solicita็ใo Aprovada         		 "
				{ 'BR_PRETO'   	, STR0005 },; //"Solicita็ใo Reprovada                 "
				{ 'BR_MARROM'  	, STR0006 },; //"Aguardando Libera็ใo do Depto Viagem  "
				{ 'BR_LARANJA' 	, STR0007 },; //"Liberado para Presta็ใo de Contas     "
				{ 'BR_BRANCO'  	, STR0008 },; //"Presta็ใo de Contas sem Solicita็ใo   " 
				{ 'BR_VERMELHO'	, STR0009 },; //"Respectivo Acerto Concluido           "
				{ 'BR_PINK'		, STR0010 },;   //"Solicita็ใo Cancelada                 "
				{ 'BR_CINZA'   	, STR0011 }} //"Fechamento da Viagem                  "

BrwLegenda(cCadastro,STR0012,aCores2) //"Legenda da Solicita็ใo"

Return
