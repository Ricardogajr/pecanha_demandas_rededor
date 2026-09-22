#INCLUDE "FWMVCDEF.CH"
#INCLUDE "Protheus.ch"
#include "fileio.ch"

//-------------------------------------------------------------------
/*/{Protheus.doc} DORALTVAG
description Rotina responsável alteração dos status da vaga
@author  Laura Peghini  
@since   04/06/2025
@version 1.0
/*/ 
//-------------------------------------------------------------------
User function DORALTVAG( cStatus, cFilFap, cFap, cMotivo, cVaga )

Local aRet := {}

	If !Empty(cVaga) .AND. cStatus$('5,6,10')
		If cStatus == '5' //cancela vaga
			aRet := VagaCan( cFilFap, cVaga, cMotivo )
		ElseIf cStatus == '6' //vaga suspensa
			aRet := VagaSusp(cFilFap, cVaga,  cMotivo)	
		ElseIf cStatus == '10' //vaga reaberta
			aRet := VagaReab( cFilFap, cVaga, cMotivo )
		EndIf
	Else
		DbSelectArea("PA2")
		PA2->(DbSetOrder(6)) 
		If PA2->(DbSeek(cFilFap + cFap))
			If !(PA2->PA2_SIT $ ("RE,CL,AG"))
				cFilFap := PA2->PA2_FILIAL
				cVaga 	:= PA2->PA2_CDVAGA
				cFilSol := PA2->PA2_FILSOL
				cSol 	:= PA2->PA2_SOL
				cCandit := PA2->PA2_CDCAND
				If cStatus == '8' //exame docto
					aRet := U_ExameDocto( cFilFap, cFap, cVaga, cFilSol, cSol )
				ElseIf cStatus == '3' //inapto
					aRet := Inapto( cFilFap, cFap, cVaga )
				ElseIf cStatus == '12' //desistiu exame
					aRet := DesisDocEx( cFilFap, cFap, cVaga )
				ElseIf cStatus == '4'
					aRet := CelCad( cFilFap, cVaga, cFilSol, cSol )
				ElseIf cStatus == '11' //docto inconsistente
					aRet := DocIncon( cFilFap, cVaga, cFilSol, cSol )
				ElseIf cStatus == '9' //assinatura contrato
					aRet := AssContra( cFilFap, cVaga, cFilSol, cSol ) 
				ElseIf cStatus == '2' //desistiu contrato
					aRet := DesisContra( cFilFap, cVaga, cCandit )
				ElseIf cStatus == '7' //Vaga Concluida
					aRet := ConcluVag( cFilFap, cVaga, cFilSol, cSol )									
				ElseIf cStatus == '5' //cancela vaga
					aRet := VagaCan( cFilFap, cVaga, cMotivo )
				ElseIf cStatus == '6' //vaga suspensa
					aRet := VagaSusp(cFilFap, cVaga,  cMotivo)	
				ElseIf cStatus == '1' //cancela fap
					aRet := FapCan(cFilFap, cFap, cVaga, cMotivo)					
				EndIf
			Else
				If PA2->PA2_SIT == "RE" .OR. !(PA2->PA2_SIT $ ("CL,AG"))
					If cStatus == '10' //vaga reaberta
						aRet := VagaReab( cFilFap, cVaga, cMotivo )
					EndIf
				Else
					lRet := .F.		
					cRet := "Status não permite alteração."
					aRet := {lRet,cRet}
				EndIf
			EndIf
		EndIf
	EndIf

return aRet

/*/{Protheus.doc} ExameDocto
Enc. Exame/Documento
@author  Laura Peghini
@since 04/06/2025
@version 1.0
/*/
User Function ExameDocto( cFilFap, cFap, cVaga, cFilSol, cSol )

Local aArea	:= GetArea()
Local lRet	:= .T. 
Local cRet  := ""
	
	cFILsQG := U_F0600402( cFilFap, "SQS")
	DbSelectArea("SQS")
	SQS->(DbSetOrder(1))
	If SQS->(DbSeek(cFILsQG + cVaga))
		If !(SQS->QS_XSTATUS $ "5/7") 
			RecLock("SQS",.F.)
				SQS->QS_XMOTIVO := "Exame-Docto"	
				SQS->QS_XSTATUS := '8' //Exame-Docto	'		
			SQS->(MsUnLock())
			
			U_F0500211(SQS->QS_FILIAL,SQS->QS_VAGA,"8")	//Status da Vaga na FAP
			U_F0500201(SQS->QS_XSOLFIL, SQS->QS_XSOLPTL, "021")
			U_F0500201(SQS->QS_XSOLFIL, SQS->QS_XSOLPTL, "019")

			U_F0500201(cFilFap, cFap, "006")//Atendido
			U_F0500201(cFilFap, cFap, "019")		

			DbSelectArea("PA2")
			PA2->(DbSetOrder(6))
			If PA2->(DbSeek(cFilFap + cFap))
				Reclock("PA2",.F.)
					PA2->PA2_SIT := "AP" //APROVADO
				PA2->(MsUnLock())
			EndIf
			PA2->(DbCloseArea())

			DbSelectArea("RH3")
			RH3->(DbSetOrder(1))
			If RH3->(DbSeek(cFilSol+cSol))
				RecLock("RH3",.F.)
				RH3->RH3_STATUS := "2"
				RH3->RH3_DTATEN := dDataBase 
				RH3->RH3_XDTAPV := DATE()
					
				RH3->(MsUnLock())
			EndIf
			RH3->(DbCloseArea())
			cRet := "Processo efetuado com sucesso"
		Else
			If SQS->QS_XSTATUS == '5'  
				lRet := .F.		
				cRet := "Vaga já se encontra cancelada!"
			elseif SQS->QS_XSTATUS == '7'	
				lRet := .F.			
				cRet := "Vaga já se encontra Concluída!"				
			endif
		EndIf
	Else
		lRet := .F.
		cRet := "Vaga não encontrada."
	EndIf

	RestArea(aArea)

Return {lRet,cRet}

/*/{Protheus.doc} Inapto
Candidato Inapto Exame
@author  Laura Peghini
@since 04/06/2025
@version 1.0
/*/
Static Function Inapto( cFilFap, cFap, cVaga )

Local lRet		:= .T.
Local cRet		:= ""
Local cFILsQG 	:= ""

	cFILsQG := U_F0600402( cFilFap, "SQS")
	DbSelectArea("SQS")
	SQS->(DbSetOrder(1))
	If SQS->(DbSeek(cFILsQG + cVaga))
		If SQS->QS_XSTATUS == '5'  
			lRet := .F.
			cRet := "Vaga já se encontra cancelada!"		
		elseif SQS->QS_XSTATUS == '7'			
			lRet := .F.
			cRet := "Vaga já se encontra Concluída!"	
		Else	
			If SQS->QS_XSTATUS == '8'
				RecLock("SQS",.F.)
					SQS->QS_XMOTIVO := "Inapto Exame"	
					SQS->QS_XSTATUS := '2' // Em Recrutamento		'		
				SQS->(MsUnLock())
				
				U_F0500211(SQS->QS_FILIAL,SQS->QS_VAGA,"2")	//Status da Vaga na FAP
				
				U_F0500201(SQS->QS_XSOLFIL, SQS->QS_XSOLPTL, "017")
				U_F0500201(SQS->QS_XSOLFIL, SQS->QS_XSOLPTL, "011")
				U_F0802001(cFILsQG,cVaga)
				U_F0500201(cFilFap,cFap,"004")					
				U_ReprovaPA2("017")
				cRet := "Processo efetuado com sucesso"
			Else
				lRet := .F.
				cRet := "Status da vaga não permite está alteração (<> 8)."
			EndIf
		EndIf
	EndIf		
	
Return{lRet,cRet}

/*/{Protheus.doc} DesisDocEx
Candidato Desistente Docs./Exame
@author  Laura Peghini
@since 04/06/2025
@version 1.0
/*/
Static Function DesisDocEx( cFilFap, cFap, cVaga )

Local lRet 	:= .T.
Local cRet	:= ""

	cFILsQG := U_F0600402( cFilFap, "SQS")
	DbSelectArea("SQS")
	SQS->(DbSetOrder(1))
	If SQS->(DbSeek(cFILsQG + cVaga))
		If SQS->QS_XSTATUS == '5'  
			lRet := .F.
			cRet := "Vaga já se encontra cancelada!"		
		elseif SQS->QS_XSTATUS == '7'			
			lRet := .F.
			cRet := "Vaga já se encontra Concluída!"	
		Else
			If SQS->QS_XSTATUS == "8"
				RecLock("SQS",.F.)
					SQS->QS_XMOTIVO := "Desistente Docs./Exame"	
					SQS->QS_XSTATUS := '2' // Em Recrutamento		'		
				SQS->(MsUnLock())

				U_F0500211(SQS->QS_FILIAL,SQS->QS_VAGA,"2")	//Status da Vaga na FAP
				
				U_F0500201(SQS->QS_XSOLFIL, SQS->QS_XSOLPTL, "015")
				U_F0500201(SQS->QS_XSOLFIL, SQS->QS_XSOLPTL, "011")
				U_F0802001(cFILsQG,cVaga)
				U_F0500201(cFilFap,cFap,"004")	
				U_ReprovaPA2("015")
				cRet := "Processo efetuado com sucesso"
			Else
				lRet := .F.
				cRet := "Status da vaga não permite está alteração (<> 8)."
			EndIf
		EndIf
	Else
		lRet := .F.
		cRet := "Vaga não encontrada."
	EndIf		

Return{lRet,cRet}

/*/{Protheus.doc} CelCad
Enc. Célula de Cadastro
@author  Laura Peghini
@since 04/06/2025
@version 1.0
/*/
Static Function CelCad( cFilFap, cVaga, cFilSol, cSol )

Local aArea	:= GetArea()
Local lRet	:= .T. 
Local cRet  := ""
	
	cFILsQG := U_F0600402( cFilFap, "SQS")
	DbSelectArea("SQS")
	SQS->(DbSetOrder(1))
	If SQS->(DbSeek(cFILsQG + cVaga))
		If SQS->QS_XSTATUS == '5'  
			lRet := .F.
			cRet := "Vaga já se encontra cancelada!"		
		elseif SQS->QS_XSTATUS == '7'			
			lRet := .F.
			cRet := "Vaga já se encontra Concluída!"	
		Else	
			RecLock("SQS",.F.)
			SQS->QS_XMOTIVO := "Em cadastro"	
			SQS->QS_XSTATUS := '4' // Em Cadastro		'		
			SQS->(MsUnLock())
			
			U_F0500211(SQS->QS_FILIAL,SQS->QS_VAGA,"4")	//Status da Vaga na FAP
			
			U_F0500201(SQS->QS_XSOLFIL, SQS->QS_XSOLPTL, "022")
			U_F0500201(SQS->QS_XSOLFIL, SQS->QS_XSOLPTL, "013")
			
			U_F0500201(cFilSol, cSol, "022")
			U_F0500201(cFilSol, cSol, "013") 
			
			cRet := "Processo efetuado com sucesso"
		EndIf
	Else
		lRet := .F.
		cRet := "Vaga não encontrada."
	EndIf

	RestArea(aArea)

Return {lRet,cRet}

/*/{Protheus.doc} DocIncon
Candidato Doc. Inconsistente
@author  Laura Peghini
@since 04/06/2025
@version 1.0
/*/
Static Function DocIncon( cFilFap, cVaga, cFilSol, cSol )
	
Local lRet		:= .T.
Local cRet		:= ""
Local cFILsQG 	:= ""

	cFILsQG := U_F0600402( cFilFap, "SQS")
	DbSelectArea("SQS")
	SQS->(DbSetOrder(1))
	If SQS->(DbSeek(cFILsQG + cVaga))
		If SQS->QS_XSTATUS == '5'  
			lRet := .F.
			cRet := "Vaga já se encontra cancelada!"		
		elseif SQS->QS_XSTATUS == '7'			
			lRet := .F.
			cRet := "Vaga já se encontra Concluída!"	
		Else
			If SQS->QS_XSTATUS == '4'	
				RecLock("SQS",.F.)
					SQS->QS_XMOTIVO := "Documento Suspenso"	
					SQS->QS_XSTATUS := '8' 	
				SQS->(MsUnLock())
				
				U_F0500211(SQS->QS_FILIAL,SQS->QS_VAGA,"8")	//Status da Vaga na FAP			
				U_F0500201(SQS->QS_XSOLFIL, SQS->QS_XSOLPTL, "016")
				U_F0500201(SQS->QS_XSOLFIL, SQS->QS_XSOLPTL, "019")
				U_F0500201(cFilSol, cSol, "016")
				U_F0500201(cFilSol, cSol, "019") 
				U_F0802001(cFILsQG,cVaga)
				cRet := "Processo efetuado com sucesso"
			Else
				lRet := .F.
				cRet := "Status da vaga não permite está alteração (<> 4)."
			EndIf
		EndIf
	Else
		lRet := .F.
		cRet := "Vaga não encontrada."
	EndIf

Return{lRet,cRet}


/*/{Protheus.doc} AssContra
Assinatura de Contrato
@author  Laura Peghini
@since 04/06/2025
@version 1.0
/*/
Static Function AssContra( cFilFap, cVaga, cFilSol, cSol )
	
Local lRet 	:= .T. 
Local aAreaSRA	:= SRA->(GetArea())
Local aAreaRH3	:= RH3->(GetArea())
Local aAreaSQG	:= SQG->(GetArea())	

	cFILsQG := U_F0600402( cFilFap, "SQS")
	DbSelectArea("SQS")
	SQS->(DbSetOrder(1))
	If SQS->(DbSeek(cFILsQG + cVaga))
		If !(SQS->QS_XSTATUS $ "5/7")
			RecLock("SQS",.F.)
				SQS->QS_XMOTIVO := "Assinatura de contrato"	
				SQS->QS_XSTATUS := '9' // Assinatura de contrato'		
			SQS->(MsUnLock())
			
			U_F0500211(SQS->QS_FILIAL,SQS->QS_VAGA,"9")	//Status da Vaga na FAP
			U_F0500201(SQS->QS_XSOLFIL, SQS->QS_XSOLPTL, "020")
			U_F0500201(SQS->QS_XSOLFIL, SQS->QS_XSOLPTL, "023")
			U_F0500201(cFilSol, cSol, "020")
			U_F0500201(cFilSol, cSol, "023")

			cRet := "Processo efetuado com sucesso"
		Else
			If SQS->QS_XSTATUS == '5'  
				lRet := .F.		
				cRet := "Vaga já se encontra cancelada!"
			elseif SQS->QS_XSTATUS == '7'	
				lRet := .F.			
				cRet := "Vaga já se encontra Concluída!"				
			endif
		EndIf
		
	EndIf
	
	RestArea(aAreaSRA)
	RestArea(aAreaRH3)
	RestArea(aAreaSQG)

Return{lRet,cRet}

/*/{Protheus.doc} DesisContra
Candidato Desistente Contratoe
@author  Laura Peghini
@since 04/06/2025
@version 1.0
/*/
Static Function DesisContra( cFilFap, cVaga, cCandit )
	
Local lRet	:= .T.
Local cRet	:= ""

	cFILsQG := U_F0600402( cFilFap, "SQS")
	DbSelectArea("SQS")
	SQS->(DbSetOrder(1))
	If SQS->(DbSeek(cFILsQG + cVaga))
		If SQS->QS_XSTATUS == '5'  
			lRet := .F.
			cRet := "Vaga já se encontra cancelada!"		
		elseif SQS->QS_XSTATUS == '7'			
			lRet := .F.
			cRet := "Vaga já se encontra Concluída!"	
		Else	
			If SQS->QS_XSTATUS == '9' 
				RecLock("SQS",.F.)
				SQS->QS_XMOTIVO := "Desistente Contrato"	
				SQS->QS_XSTATUS := '2' // Em Recrutamento		'		
				SQS->(MsUnLock())
				
				U_F0500211(SQS->QS_FILIAL,SQS->QS_VAGA,"2")	//Status da Vaga na FAP	
				U_F0500201(SQS->QS_XSOLFIL, SQS->QS_XSOLPTL, "018")
				U_F0500201(SQS->QS_XSOLFIL, SQS->QS_XSOLPTL, "011")

				DbSelectArea("RH3")
				RH3->(DbSetOrder(1))
				If RH3->(DbSeek(cFilSol + cSol))
					Reclock("RH3", .F.)
					RH3->RH3_STATUS := '3'
					RH3->(MsUnlock())
				EndIf
				
				If !U_F0802001(cFILsQG,cVaga)
					lRet := .F.
					cRet := "Não foi possível atualizar a vaga. Comunique aos envolvidos!" 
				EndIf	
				If !U_F0802002(cFilFap, cCandit)
					lRet := .F.
					cRet := "Não foi possível desocupar o participante do posto. Comunique aos envolvidos!" 	
				Endif

				U_ReprovaPA2("018")
				cRet := "Processo efetuado com sucesso"	
			Else
				lRet := .F.
				cRet := "Status da vaga não permite está alteração (<> 9)."
			EndIf
		EndIf
	EndIf	
	
Return {lRet,cRet}

/*/{Protheus.doc} ConcluVag
Vaga Concluida
@author  Laura Peghini
@since 04/06/2025
@version 1.0
/*/
Static Function ConcluVag( cFilFap, cVaga, cFilSol, cSol, cCandit )
	
Local lRet 	:= .T. 
Local aAreaSRA	:= SRA->(GetArea())
Local aAreaRH3	:= RH3->(GetArea())
Local aAreaSQG	:= SQG->(GetArea())	

	cFILsQG := U_F0600402( cFilFap, "SQS")
	DbSelectArea("SQS")
	SQS->(DbSetOrder(1))
	If SQS->(DbSeek(cFILsQG + cVaga))
		If !(SQS->QS_XSTATUS $ "5/7")
			RecLock("SQS",.F.)
				SQS->QS_XMOTIVO := "Concluida"	
				SQS->QS_XSTATUS := '7' // Assinatura de contrato'		
			SQS->(MsUnLock())
			
			U_F0500211(SQS->QS_FILIAL,SQS->QS_VAGA,"7")	//Status da Vaga na FAP
			U_F0500201(SQS->QS_XSOLFIL, SQS->QS_XSOLPTL, "014")//Atendido
			U_F0500201(cFilSol, cSol, "014")

			DbSelectArea("PA2")
			PA2->(DbSetOrder(6))
			If PA2->(DbSeek(cFilSol + cSol))
				Reclock("PA2",.F.)
					PA2->PA2_SIT := "CL" //APROVADO
				PA2->(MsUnLock())
			EndIf
			PA2->(DbCloseArea())

			DbSelectArea("RH3")
			RH3->(DbSetOrder(1))
			If RH3->(DbSeek(cFilSol+cSol))
				RecLock("RH3",.F.)
				RH3->RH3_STATUS := "2"
				RH3->RH3_DTATEN := dDataBase 
				RH3->RH3_XDTAPV := DATE()					
				RH3->(MsUnLock())
			EndIf
			RH3->(DbCloseArea())

			cRet := "Processo efetuado com sucesso"
		Else
			If SQS->QS_XSTATUS == '5'  
				lRet := .F.		
				cRet := "Vaga já se encontra cancelada!"			
			elseif SQS->QS_XSTATUS == '7'			
				lRet := .F.
				cRet := "Vaga já se encontra Concluída!"
			endif
		EndIf		
	EndIf
	
	RestArea(aAreaSRA)
	RestArea(aAreaRH3)
	RestArea(aAreaSQG)

Return{lRet,cRet}

/*/{Protheus.doc} VagaCan
Vaga Cancelada
@author  Laura Peghini
@since 04/06/2025
@version 1.0
/*/
Static Function VagaCan( cFilFap, cVaga, cMotivo ) 
	
Local aArea	:= GetArea()
Local lRet	:= .T.
Local cRet	:= ""
	
	cFILsQG := U_F0600402( cFilFap, "SQS")
	DbSelectArea("SQS")
	SQS->(DbSetOrder(1))
	If SQS->(DbSeek(cFILsQG + cVaga))
		If SQS->QS_XSTATUS == '7'			
			lRet := .F.
			cRet := "Vaga já se encontra Concluída!"
		Else
			If Empty(cMotivo)
				lRet := .F.
				cRet := "É obrigatório o preenchimento de uma justificativa para alteração do Status!"	
			Else	
				RecLock("SQS",.F.)
					SQS->QS_XMOTIVO := cMotivo
					SQS->QS_XSTATUS := '5'
				SQS->(MsUnLock())
				
				U_F0500211(SQS->QS_FILIAL,SQS->QS_VAGA,"5")	//Status da Vaga na FAP
				U_F0500201(SQS->QS_XSOLFIL,SQS->QS_XSOLPTL,"008")

				DbSelectArea("PA2")
				PA2->(DbSetOrder(8))	//-PA2_FILVG+PA2_CDVAGA
				If PA2->(dbSeek(SQS->(QS_FILIAL + QS_VAGA),.F.))
					cCodVag := SQS->(QS_FILIAL+QS_VAGA)				
					While !(PA2->(EOF())) .AND. PA2->(PA2_FILVG + PA2_CDVAGA) == cCodVag
						DbSelectArea("RH3") // Cancelamento da FAP na RH3
						RH3->(DbSetOrder(1))
						If RH3->(DbSeek(PA2->PA2_FILIAL+PA2->PA2_SOL))
							Reclock("RH3", .F.)
							RH3->RH3_STATUS := '3'
							RH3->RH3_XCANCL := "1" //Cancelado Sim
							RH3->(MsUnlock())
						EndIf

						U_F0500201(PA2->PA2_FILIAL,PA2->PA2_SOL,"008")
						U_ReprovaPA2("024")
						PA2->(DbSkip())
					EndDo
				EndIf							
				cRet := "Vaga cancelada!"
			EndIf	
		EndIf
	Else
		lRet := .F.
		cRet := "Vaga não encontrada!"
	EndIf
	
	RestArea(aArea)	

Return {lRet,cRet}

/*/{Protheus.doc} VagaSusp
Vaga Suspensa
@author  Laura Peghini
@since 04/06/2025
@version 1.0
/*/
Static Function VagaSusp( cFilFap, cVaga, cMotivo )

Local aArea   := GetArea()
Local lMotivo := .F.
Local aMotivo := ""
Local cCodVag := ""
Local lRet	:= .T.
Local cRet	:= ""

	cFILsQG := U_F0600402( cFilFap, "SQS")
	DbSelectArea("SQS")
	SQS->(DbSetOrder(1))
	If SQS->(DbSeek(cFILsQG + cVaga))
		If SQS->QS_XSTATUS == '5'  
			lRet := .F.
			cRet := "Vaga já se encontra cancelada!"		
		elseif SQS->QS_XSTATUS == '7'			
			lRet := .F.
			cRet := "Vaga já se encontra Concluída!"	
		Else		
			If !Empty(cMotivo)
				DbSelectArea("SQS")
				SQS->(DbSetOrder(1))
				RecLock("SQS",.F.)
					SQS->QS_XMOTIVO := cMotivo
					SQS->QS_XSUSPEN := SQS->QS_XSTATUS
					SQS->QS_XSTATUS := '6'
				SQS->(MsUnLock())
				U_F0500211(SQS->QS_FILIAL,SQS->QS_VAGA,"6")	//Status da Vaga na FAP						
				U_F0500201(SQS->QS_XSOLFIL, SQS->QS_XSOLPTL, "011") //Em Recrutamento
				U_F0500201(SQS->QS_XSOLFIL,SQS->QS_XSOLPTL,"009")
				DbSelectArea("PA2")
				PA2->(DbSetOrder(8))	//-PA2_FILVG+PA2_CDVAGA
				If PA2->(dbSeek(SQS->(QS_FILIAL + QS_VAGA),.F.))
					cCodVag := SQS->(QS_FILIAL+QS_VAGA)
					While !(PA2->(EOF())) .AND. PA2->(PA2_FILVG+PA2_CDVAGA) == cCodVag
						U_F0500201(PA2->PA2_FILIAL,PA2->PA2_SOL,"009")
						U_ReprovaPA2()
						PA2->(DbSkip())
					EndDo
				EndIf							
				cRet := "Vaga Suspensa!"
			Else
				lRet := .F.
				cRet := "É obrigatório o preenchimento de uma justificativa para alteração do Status!"
			EndIf
		EndIf
	EndIf
	
	RestArea(aArea)
	
Return {lRet,cRet}

/*/{Protheus.doc} VagaReab
Vaga Reaberta
@author  Laura Peghini
@since 04/06/2025
@version 1.0
/*/
Static Function VagaReab( cFilFap, cVaga, cMotivo )

Local lMotivo := .F.
Local cMotivo := ""
Local lRet    := .T.
Local cRet	  := ""
	
	cFILsQG := U_F0600402( cFilFap, "SQS")
	DbSelectArea("SQS")
	SQS->(DbSetOrder(1))
	If SQS->(DbSeek(cFILsQG + cVaga))
		If !(SQS->QS_XSTATUS $ "5/7") 
			If SQS->QS_XSTATUS == '6' 
				RecLock("SQS",.F.)
				SQS->QS_XMOTIVO := cMotivo
				SQS->QS_XSTATUS := '2' //SQS->QS_XSUSPEN
				SQS->QS_XSUSPEN := ''
				SQS->(MsUnLock())
				
				U_F0500211(SQS->QS_FILIAL,SQS->QS_VAGA,"2")	//Status da Vaga na FAP	
				U_F0500201(SQS->QS_XSOLFIL, SQS->QS_XSOLPTL, "010")
				U_F0500201(SQS->QS_XSOLFIL, SQS->QS_XSOLPTL, "011")
				
				cRet := "Vaga Reaberta!"		
			Else
				lRet := .F.		
				cRet := "Status da vaga não permite está alteração (<> 6)."
			EndIf	
		Else
			If SQS->QS_XSTATUS == '5'  
				lRet := .F.		
				cRet := "Vaga já se encontra cancelada!"
			elseif SQS->QS_XSTATUS == '7'	
				lRet := .F.			
				cRet := "Vaga já se encontra Concluída!"				
			endif
		EndIf
	EndIf

Return{lRet,cRet}

/*/{Protheus.doc} FapCan
Cancela FAP
@author  Laura Peghini
@since 04/06/2025
@version 1.0
/*/
Static Function FapCan( cFilFap, cFap, cVaga, cMotivo )

Local lMotivo := .F.
Local cMotivo := ""
Local lRet    := .T.
Local cRet	  := ""
	
	DbSelectArea("RH3")
	RH3->(DbSetOrder(1))
	If RH3->(DbSeek(cFilFap + cFap))
		If RH3->RH3_STATUS == "1" .OR. RH3->RH3_STATUS == "4"
			cFilSol := RH3->RH3_FILIAL
			cCodSol := RH3->RH3_CODIGO
			cFSolic := RH3->RH3_FILINI
			cMSolic := RH3->RH3_MATINI
			RH3->(RecLock("RH3",.F.))
				RH3->RH3_STATUS := "3" //Reprovados
				RH3->RH3_XCANCL := "1" //Cancelado Sim
				RH3->RH3_DTATEN := Date()
			RH3->(MsUnLock())

			DbSelectArea("PA2")
			PA2->(DbSetOrder(6))
			If PA2->(DbSeek(cFilFap + cFap))
				PA2->(Reclock("PA2",.F.))
					PA2->PA2_SIT := "RE"
				PA2->(MsUnlock())
			EndIf
			PA2->(DbCloseArea())
			//Indicador
			U_F0500201(cFilSol, cCodSol, "024", cFSolic,cMSolic) //Cancelamento da solicitação				
			cObserv := "Cancelamento: " + cMotivo			
			//Historico Cancelamento
			U_F0801402(cFilSol, cCodSol, cFSolic, cMSolic, cObserv)	

			cFILsQG := U_F0600402( cFilFap, "SQS")
			DbSelectArea("SQS")
			SQS->(DbSetOrder(1))
			If SQS->(DbSeek(cFILsQG + cVaga))
				RecLock("SQS",.F.)
					SQS->QS_XMOTIVO := cMotivo
					SQS->QS_XSTATUS := '2' 
				SQS->(MsUnLock())
				
				U_F0500211(SQS->QS_FILIAL,SQS->QS_VAGA,"2")	//Status da Vaga na FAP	
				U_F0500201(SQS->QS_XSOLFIL, SQS->QS_XSOLPTL, "011")
			EndIf
			lRet := .T.
			cRet := "FAP cancelada com sucesso."	
		Else
			lRet := .F.
			cRet := "Status não permite cancelamento."	
		EndIf
	Else
		lRet := .F.
		cRet := "FAP não encontrada."		
	EndIf
	RH3->(DBCloseArea())

Return{lRet,cRet}
