#INCLUDE "Protheus.ch"


/*-----------------------------------------------------------------------------+
* Programa  * WF002  º Business Inteligence            * Data ³  01/04/2003    *
*------------------------------------------------------------------------------*
* Autores: Luciana / Willy                                                     *
* Objetivo  * Programa Agendado (SXM) para envio de e-mail do                  *
*	    * Processo de Prestação de Contas - LHQ_FLAG == "P"                *
*------------------------------------------------------------------------------*/

User Function AEWF002(aParam)

//Prepara o Ambiente com os parametros de empresa e filial incluidas na tabela SXM.
WfPrepEnv(aParam[1] , aParam[2] ,,{"LHP","LHQ"})

ChkTemplate("CDV")

dbSelectArea("LHQ")
LHQ->(dbSetOrder(1))
Do While !LHQ->(Eof()) 
	//Envia e-mail informativo apenas para os registros que possuem Flag = P
	If LHQ->LHQ_FLAG <> "P"
		LHQ->(DBSKIP())
		Loop
	Endif
	//Funcao que monta e-mail informativo para Prestacao de Contas
	U_AEMlPrest(LHQ->LHQ_CODIGO)
	LHQ->(DbSkip())
EndDo

Return(Nil)
