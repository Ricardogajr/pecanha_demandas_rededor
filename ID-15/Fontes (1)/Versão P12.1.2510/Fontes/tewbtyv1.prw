#Include 'Protheus.ch'

/*
{Protheus.doc} F01VldCod
Valida o códido do Bem já foi veiculado a outro responsável. Está sendo chamada na validação de usuário do campo ND_ITEM
@Author     Ramon Teodoro
@Since      22/02/2016       
@Version    P12.7
@Return     lRet
*/

User Function F01VldCod()

Local lRet    := .t. 
Local aArea   := GetArea()
Local aAreaND := SND->(GetArea())

If IsInCallStack("ATFA190")

	DbSelectArea("SND")
	SND->(DbSetOrder(2))
	
	If SND->(DbSeek(xFilial("SND")+M->ND_CBASE+M->ND_ITEM))
		lRet := .F.
		MsgStop("Este ativo já está vinculado a outro responsável, não é possível continuar a operação", "Atenção")	
	EndIf

EndIf

RestArea(aAreaND)
RestArea(aArea)
Return lRet
                       

/*
{Protheus.doc} F01VldCod
Valida se o responsável já foi relacionado a outros bens do grupo do bem atual. Está sendo chamada na 
validação de usuário do campo ND_CODRESP
@Author     Ramon Teodoro
@Since      22/02/2016       
@Version    P12.7
@Return     lRet
*/

User Function F01VldRes()

Local lRet    := .t. 
Local aArea   := GetArea()
Local aAreaND := SND->(GetArea())
Local cGrpAt  := ""     
Local cDescAt := ""

If IsInCallStack("ATFA190")

	DbSelectArea("SN1")
	SN1->(DbSetOrder(1))
	
	If SN1->(DbSeek(xFilial("SN1")+M->ND_CBASE+M->ND_ITEM))  
	
		cGrpAt  := SN1->N1_GRUPO
		
		SND->(DbSetOrder(2))
		SND->(DbGoTop())   
		
		While !SND->(Eof())
	
			If SN1->(DbSeek(xFilial("SN1")+SND->ND_CBASE+SND->ND_ITEM))    
				cDescAt := Alltrim(SN1->N1_DESCRIC)
				If SN1->N1_GRUPO == cGrpAt .And. SND->ND_CODRESP == M->ND_CODRESP 
					MsgAlert("Já existe um ativo do mesmo grupo em posse do participante. Verificar o código: " + Alltrim(SND->ND_CBASE) + "  " + Alltrim(SND->ND_ITEM) + " - " + cDescAt, "Atenção" )	
				EndIf
			EndIf
			
	        SND->(DbSkip())
		End
		
	EndIf

EndIf

RestArea(aAreaND)
RestArea(aArea)
Return lRet
