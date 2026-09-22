#Include 'Protheus.ch'

 /*
{Protheus.doc} F0500413()
Abertura da Movimentação do Funcionario posicionado
@Author     Bruno de Oliveira
@Since      21/06/2017
@Version    P12.1.07
@Project    MAN0000007423039_EF_004
*/
User Function F0500413(cFilRA,cMatRA,oBrowse)

	SRA->(DbSetOrder(1))
	SRA->(dbgotop())      // 416094 - Rogerio Carvalho - AMS Rio - 18/07/2018 - DOR04520620  

	// Ticket No.3985154 - 418497 - Don Junior - Correção erro Alias does not exist
//	If SRA->(DbSeek((oBrowse:Alias())->RA_FILIAL + (oBrowse:Alias())->RA_MAT))
	If SRA->(DbSeek(cFilRA + cMatRA))
		FWExecView('', 'F0500401', 3, , { || .T. })
		//oBrowse:ExecuteFilter(.T.)
		//oBrowse:Refresh()
	Else
		Help("",1, "Help", "Atenção", "Não foi encontrado o funcionário!." , 3, 0)	
	EndIf

Return