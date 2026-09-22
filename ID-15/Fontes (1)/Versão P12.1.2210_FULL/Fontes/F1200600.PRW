#INCLUDE 'PROTHEUS.CH'

/*
{Protheus.doc} F1200600()
Job de medições automáticas.
@Author		Paulo Krüger
@Since		14/08/2017
@Version	P12.7
@Project    MAN0000007423046_EF_001
@Param		
*/

User Function F1200600(aParams)

Local aFiles	:= {}
Local dDtIni    := CTOD('  /  /  ')
Local cHora     := '' 
Local cEmpIni   := ''
Local cFilIni   := ''
 	
Default aParams := {'01','01010001',.T.}
	
cEmpIni := aParams[1]
cFilIni := aParams[2]
aFiles	  := {'AIA', 'AIB', 'CN9', 'CNA', 'CND', 'CNE', 'SA2', 'SB1', 'SC1', 'SC7'}
dDtIni    := Date()
cHora     := Time()

//Verifica se já existe um Job em execução com o mesmo nome.
If !LockByName('F1200600_' + cFilIni ,.F.,.F. )
	Conout('F1200600 - Ja existe um Job com mesmo nome em execucao!')
Else
	ConOut("**************************************************************************")
	ConOut("* F1200600: Medicoes automaticas de contratos de compras.                *")
	ConOut("* Inicio: " + Dtos(dDtIni) + " - " + cHora + "                   		 	 *")
	ConOut("* Montagem do ambiente na empresa " + cEmpIni + " - " + cFilIni + " 		 *")
	Conout("* F1200600 - Inicio Thread: '" + cValToChar(ThreadID()) 					   )
	ConOut("**************************************************************************")	  	  

	If Select('SX2') == 0 
		If !RpcSetEnv( cEmpIni, cFilIni,,,,, aFiles )
			Conout('F1200600 - Nao foi possivel inicializar o ambiente')
			UnLockByName('F1200600_' + cFilIni,.F.,.F. )
			Return .F.
		Endif
		lMontaAmb := .T.
	EndIf

	U_F1200701(.F.,.F.,.F., cFilIni)	//Seleciona solicitacoes de compras para medicao
	
	If lMontaAmb
		RpcClearEnv() //Desconecta ambiente 						
	Endif		
		
	Conout('F1200600 - Final Thread: ' + cValToChar(ThreadID()) )
	UnLockByName('F1200600_' + cFilIni,.F.,.F. )			 				
EndIf
Return Nil
