#INCLUDE "AE_DV004_AP6.ch"
#INCLUDE "PROTHEUS.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³AE_DV004_AP6ºAutor  ³Armando / Willy   º Data ³  09/06/02   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³  Legenda                                                   º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP6                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
// V - Verde     -> Colaborador Viajando
// D - Amarela   -> Iniciado Processo de Acerto 
// L - Laranja   -> Encaminhado e Aguardando Confirmacao
// C - Vermelho  -> Autorizado e Concluido
// M - Marrom    -> Iniciado a Prestação de Contas sem Solicitação
// B - Branco    -> Prestação de Contas sem Solicitação
// P - Preto     -> Processo de acerto em atraso
// Z - Cinza     -> Fechamento da Viagem          
// K - Pink		 -> Solicitação cancelada

//user Function AE_DV004()
User Function AE_DV004()

Local cCadastro := STR0001 //"Prestação de Contas"

Local aCores2 := {	{ 'BR_VERDE',	STR0002 },; //"Colaborador Viajando"
					{ 'BR_AMARELO',	STR0003 },; //"Iniciado Processo de Acerto"
					{ 'BR_LARANJA', STR0004 },; //"Encaminhado e Aguardando Confirmação "
					{ 'BR_VERMELHO',STR0005 },; //"Autorizado e Liberado"
					{ 'BR_PINK', 	STR0006 },; //"Solicitação Cancelada"
					{ 'BR_CINZA',  	STR0007 },; //"Fechamento da Viagem"
					{ 'BR_MARROM',  STR0008 },; //"Iniciado Prest.Contas sem Solicitação "
					{ 'BR_BRANCO' , STR0009 },; //"Prestação de Contas sem Solicitação "
					{ 'BR_PRETO',   STR0010 },;//"Acerto da Despesa em Atraso"
					{ 'BR_AZUL',  STR0012 }} 

ChkTemplate("CDV")

BrwLegenda(cCadastro,STR0011,aCores2) //"Legenda"

Return
