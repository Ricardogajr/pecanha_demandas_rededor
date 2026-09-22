#include 'protheus.ch'
#include 'parmtype.ch'

/*
{Protheus.doc} VALIDEMP()
Fonte criado para validar(Parâmetro) e não executar as customizações do RH
Se estiver .T. ele executa, caso esteja .F. não executa. 
@Author     Ricardo Aguiar
@Since      14/01/2020
@Version    P12.1.07
@Project    
*/

User Function VALIDEMP()
	Local lRet := SuperGetMv("MV_XVALEMP",,.F.)
Return lRet