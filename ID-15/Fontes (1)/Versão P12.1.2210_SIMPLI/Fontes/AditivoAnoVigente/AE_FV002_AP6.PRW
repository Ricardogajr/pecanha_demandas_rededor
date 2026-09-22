#INCLUDE "AE_FV002_AP6.ch"
#INCLUDE "Protheus.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออหออออออัอออออออออออออออปฑฑ
ฑฑบPrograma  ณAE_FV002  บAutor  ณWilly             บ Data ณ  27/02/03     บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออสออออออฯอออออออออออออออนฑฑ
ฑฑบDesc.     ณ  Legenda                                                   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP6                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

User Function AE_FV002()

Local cCadastro := STR0001, aCores3 //"Departamento de Viagem"

chktemplate("CDV")

aCores3 := {	{ 'BR_MARROM'  	, STR0002 },; //"Solicita็ใo Iniciada					"
				{ 'BR_VERDE'   	, STR0003 },; //"Para Aprova็ใo              		   	"
				{ 'BR_AMARELO' 	, STR0004 },; //"Aguardando Aprovacao Workflow		"
				{ 'BR_AZUL'    	, STR0005 },; //"Solicita็ใo Aprovada        	       	"
				{ 'BR_PRETO'   	, STR0006 },; //"Solicita็ใo Reprovada       		   	"
				{ 'BR_LARANJA' 	, STR0007 },; //"Encaminhado Ag๊ncia Viagem/Financeiro"
				{ 'BR_PINK'		, STR0008 },; //"Solicita็ใo Cancelada				"
				{ 'BR_BRANCO'  	, STR0009 },; //"Presta็ใo de Contas sem Solicita็ใo 	"
				{ 'BR_VERMELHO'	, STR0010 },; //"Respectivo Acerto Concluido 		   	"
				{ 'BR_CINZA'   	, STR0011 } } //"Fechamento da Viagem 			   		"

BrwLegenda(cCadastro,STR0012,aCores3) //"Legenda Depto de Viagem"

Return
 