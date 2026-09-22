#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TOPCONN.CH"

/*
{Protheus.doc} F0100106()
Tela de Visualização dos Logs da Medição de Contrato
@Author		Mick William da Silva
@Since		05/07/2016
@Version	P12.7
@Project    MAN00000462901_EF_001 
*/ 
 
User Function F0100106()
	Local cAliasP07	:= ""
	Local oModel    := Nil
	Local oExecView := Nil
	Local aButtons  := {;
							{.F., Nil        },; 
							{.F., Nil        },; 
							{.F., Nil        },; 
							{.F., Nil        },; 
							{.F., Nil        },;
							{.F., Nil        },;
							{.T., "Confirmar"},; 
							{.T., "Fechar"   },; 
							{.F., Nil        },; 
							{.F., Nil        },;
							{.F., Nil        },; 
							{.F., Nil        },; 
							{.F., Nil        },; 
							{.F., Nil        };
						}

	cAliasP07 := GetNextAlias()
	BeginSql Alias cAliasP07

	SELECT	MIN(P07.R_E_C_N_O_) REGP07
	FROM	%Table:P07% P07
	WHERE	P07.%notDel%
			AND P07_SOLCO	= %Exp:SC1->C1_NUM%
	EndSql
			
	If (cAliasP07)->REGP07>0
		P07->(DbGoTo((cAliasP07)->REGP07))
		FWExecView( "Log de Medição" , "F0100107", MODEL_OPERATION_VIEW, , {|| .T. } , , , aButtons, , , , )
	Else
		Help( , , "Help", "F0100107", "Não existem logs para esta Solicitação.", 1, 0 )
	EndIf

	(cAliasP07)->(DbCloseArea())

Return
