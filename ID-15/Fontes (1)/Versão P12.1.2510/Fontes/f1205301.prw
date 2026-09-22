#Include 'Protheus.ch'

/*{Protheus.doc} F1205301
Schedule responsável pela atualização da tabela P28
@author  Equipe CDE
@since   11/06/2018
@version 12.7
@param   aParams, array, empresa e filial
@project MAN0000007423048_EF_053
*/ 
User Function F1205301(aParams) 

Local aFiles  := {}
Local dData   := CTOD('  /  /  ')
Local cNomArq := "" // "LogSchedule_F1205301_"+ DTOS(Date())+".txt"
Local cCamArq := "" // SuperGetMv("FS_LOGP28",.F.,"\system\")
Local cArqGrv := ""
Local cRegLog := ""
Local lRet    := .T.
Local lMontaAmb := .F.
 	
Default aParams := {'01','01010002',.T.}

//cEmpAnt := aParams[1] //Thiago Marques - 23781643 - 12/06/2025 - Atribuição incorreta das variaveis de empresa e filial
//cFilAnt := aParams[2]
RpcSetEnv( aParams[1], aParams[2]  )

cNomArq := "LogSchedule_F1205301_"+ DTOS(Date())+".txt"
cCamArq := SuperGetMv("FS_LOGP28",.F.,"\system\")

cArqGrv := cCamArq+cNomArq
	
cEmpIni := aParams[1]
cFilIni := aParams[2]

aFiles	:= {'SB2','SD3'}

//Verifica se já existe um Job em execução com o mesmo nome.
If !LockByName('F1205301_' + cFilIni ,.F.,.F. )
	Conout('F1205301 - Ja existe um Job com mesmo nome em execucao!')
Else
	ConOut("***************************************************************")
	ConOut("* F1205301: Atualização da tabela P28.                        *")
	ConOut("***************************************************************")	  	  

	If Select('SX2') == 0 
		If !RpcSetEnv( cEmpIni, cFilIni,,,,, aFiles )
			Conout('F1205301 - Nao foi possivel inicializar o ambiente')
			UnLockByName('F1205301_' + cFilIni,.F.,.F. )
			Return .F.
		Endif
		lMontaAmb := .T.
	EndIf														

	dData := SuperGetMv("MV_ULMES",.F.)
	
	cRegLog += ""
	
	If( nHdl := fCreate( cArqGrv ) ) == -1
		lRet := .F. 							
	EndIf
	
	SB2->(DbGoTop())
	While SB2->(!Eof())
		U_F0703005(cFilIni, dData, SB2->B2_COD, SB2->B2_LOCAL,@cRegLog)
		SB2->(DbSkip())
	EndDo
	
	If lRet
		fWrite(nHdl,cRegLog)				
		fclose(nHdl)
	EndIf
	
	If lMontaAmb
		RpcClearEnv() //Desconecta ambiente 						
	Endif		
		
	Conout('F1205301 - Final Thread: ' + cValToChar(ThreadID()) )
	UnLockByName('F1205301_' + cFilIni,.F.,.F. )			 				
EndIf

Return
