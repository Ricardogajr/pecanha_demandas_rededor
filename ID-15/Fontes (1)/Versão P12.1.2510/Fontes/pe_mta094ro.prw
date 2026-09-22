#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'PARMTYPE.CH'
#INCLUDE "FWMVCDEF.CH"

/*/{Protheus.doc} MTA094RO()

Aprovação de Documentos

Descrição:
LOCALIZAÇÃO : Function MATA094 - Rotina responsável pela Aprovação de Documentos

EM QUE PONTO : Antes de montar a tela do browser.

UTILIZAÇÃO : Para adicionar botões no menu principal da rotina.

Eventos
Acionar a rotina "Contratos" pelo menu do módulo SIGAGCT.

@param		Nenhum
@return		Nenhum
@author 	CDE PRIVATE
@since 		25/05/2018
@version 	1.0
@project	REDE'DOR
/*/

USER FUNCTION MTA094RO()

	Local aRotina 	:= PARAMIXB[1]
	
	U_F0400104(aRotina) //Adicionar botão para o Banco de Conhecimento 
		
	U_F1207501(aRotina) //Adicionar botão para Pendência de Subordinados

RETURN aRotina