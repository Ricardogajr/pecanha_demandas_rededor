#Include 'Protheus.ch'
//---------------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} F0500410
Tela para atualizar alguns os parametros especificos 
@type function
@author Cris
@since 16/12/2016
@version 1.0
@version P12.1.7
@Project MAN0000007423039_EF_004
@return ${return}, ${não há}
/*///---------------------------------------------------------------------------------------------------------------------------
User Function F0500410()

Local aPergs := {}
Local cCodRec := space(08)
Local aRet := {}
Local lRet   
Local cCodTab	:= GetMV('FS_CTABAXV')//Codigo da Tabela da Visão x mvto
Local cBlqSlTF	:= Alltrim(GetMV('FS_BLQSLTF'))//Indica se bloqueia a solicitação de transf com aumento salarial
Local cDeptCan	:= GetMV('FS_DEPTCAN')//departamentos que podem ter acesso ao botar cancelar solicitação
Local cVSalSup	:= GetMV('FS_VSALSUP')//coodiusuarioogo da visão diferenciada
Local pSalSup	:= GetMV('FS_PSALSUP')//percentual do atingido para acionar a visão diferenciada
Local aOpcSN	:= {}
Local cOpcBlq	:= ''

	if cBlqSlTF == 'S' .OR. Empty(cBlqSlTF)
	
		aOpcSN	:= {"Sim", "Nao"}
	
	Else
	
		aOpcSN	:= {"Nao","Sim"}
		
	EndIf
	
 	AAdd( aPergs ,{3,"Bloqueia Solicitação de Transferência com alteração de Salário",1,aOpcSN , 50,'.T.',.T.})
 	//AAdd( aPergs ,{9,"FS_BLQSLTF",50,70,.T.})
 	AAdd( aPergs ,{1,"Visão Diferenciada",cVSalSup,"@!",'.T.','RDK','.T.',50,.F.})
 	AAdd( aPergs ,{1,"Percentual de Aumento Salarial",pSalSup,"@ 99.99",'positivo()',,'.T.',50,.F.}) 
 	AAdd( aPergs ,{1,"Tabela Visão X Tipos Mvto",cCodTab,"@!",'.T.','RCB','.T.',50,.F.})    
  	AAdd( aPergs ,{1,"Departamentos x botão Cancelar",cDeptCan + space(32),"@!",'.T.',,'.T.',50,.F.}) 
  	    
	 If ParamBox(aPergs ,"Parametros ",aRet)      
	 	
		//Início - Thais Paiva - Compatibilização P27
	 	//dbSelectArea('SX6')
	 	cOpcBlq	:= Iif(aRet[1]==1,IIF(cBlqSlTF== 'S','S','N'),IIF(cBlqSlTF=='N','N','S'))
	 	if cOpcBlq <> cBlqSlTF
	 	   
	 	   /*if SX6->(DbSeek(FwxFilial('SX6') + 'FS_BLQSLTF'))
	 	   
	 	   		SX6->(Reclock('SX6',.F.))
	 	   		SX6->X6_CONTEUD	:= cOpcBlq
	 	   		SX6->(MsUnlock())
	 	   		
	 	   EndIf*/
			If FWSX6Util():ExistsParam( "FS_BLQSLTF" )
			
				PUTMV("FS_BLQSLTF", cOpcBlq)
				   
			EndIf
	 	   
 		EndIf
 		
 		if Alltrim(aRet[2]) <> Alltrim(cVSalSup)
 		
	 		 /*if SX6->(DbSeek(FwxFilial('SX6') + 'FS_VSALSUP'))
		 	   
		 	   		SX6->(Reclock('SX6',.F.))
		 	   		SX6->X6_CONTEUD	:= Alltrim(aRet[2]) 
		 	   		SX6->(MsUnlock())
		 	   		
		 	 EndIf*/
			If FWSX6Util():ExistsParam( "FS_VSALSUP" )
			
				PUTMV("FS_VSALSUP", Alltrim(aRet[2]) )
				   
			EndIf
	 	   
 		EndIf
 		
 		if  aRet[3] <> pSalSup
  		
	 		 /*if SX6->(DbSeek(FwxFilial('SX6') + 'FS_PSALSUP'))
		 	   
		 	   		SX6->(Reclock('SX6',.F.))
		 	   		SX6->X6_CONTEUD	:= Transform(aRet[3],'@ 99.99')
		 	   		SX6->(MsUnlock())
		 	   		
		 	 EndIf*/
			If FWSX6Util():ExistsParam( "FS_PSALSUP" )
			
				PUTMV("FS_PSALSUP", Transform(aRet[3],'@ 99.99'))
				   
			EndIf
		 	 		
 		EndIf
 
  		if  aRet[4] <> cCodTab
   		
	 		 /*if SX6->(DbSeek(FwxFilial('SX6') + 'FS_CTABAXV'))
		 	   
		 	   		SX6->(Reclock('SX6',.F.))
		 	   		SX6->X6_CONTEUD	:= aRet[4] 
		 	   		SX6->(MsUnlock())
		 	   		
		 	 EndIf*/
			If FWSX6Util():ExistsParam( "FS_CTABAXV" )
			
				PUTMV("FS_CTABAXV", aRet[4])
				   
			EndIf
		 	 		
 		EndIf		
 
   		if  Alltrim(aRet[5]) <> cDeptCan		
 	 		 
 	 		 /*if SX6->(DbSeek(FwxFilial('SX6') + 'FS_DEPTCAN'))
		 	   
		 	   		SX6->(Reclock('SX6',.F.))
		 	   		SX6->X6_CONTEUD	:= Alltrim(aRet[5])
		 	   		SX6->(MsUnlock())
		 	   		
		 	 EndIf*/
			If FWSX6Util():ExistsParam( "FS_DEPTCAN" )
			
				PUTMV("FS_DEPTCAN",  Alltrim(aRet[5]))
				   
			EndIf
		 	 	
 		EndIf 
 		
 	 Else      
 	 	Alert("Pressionado Cancel")     
		lRet := .F.   
	EndIf

Return