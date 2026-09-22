#INCLUDE 'Protheus.ch'

/*{Protheus.doc} F1200901
Pto.Entrada criado após limpar as marcas realizadas no C1_OK de todos os registros marcados pelo usuario

@author	Ademar Fernandes
@since	15/08/2017
@project	MAN0000007423046_EF_009 
*/
User Function F1200901(cMarca,cQuerySC1)

	Local aArea     := GetArea()
	Local lRet      := .T.
	Local nProd     := 0
	Local aSolic    := {}
	Local aMsgErr   := {}
	Local nx		:= 0
	
	DbSelectArea("SC1")

	For nx := 1 To Len(aRecMark)	
		SC1->( DbGoto( aRecMark[nX] ) )
		
		If IsMark("C1_OK",cMarca)
			nProd := aScan(aSolic,{|x| x[1] == SC1->C1_PRODUTO })
			
			If nProd = 0
				aAdd(aSolic, {SC1->C1_PRODUTO, SC1->C1_DATPRF, SC1->C1_LOCAL, SC1->C1_CC, SC1->C1_NUM})
			Else
				If !( SC1->(C1_PRODUTO+DTOS(C1_DATPRF)+C1_LOCAL+C1_CC) == aSolic[nProd,1]+DTOS(aSolic[nProd,2])+aSolic[nProd,3]+aSolic[nProd,4] )
					SC1->(AAdd(aMsgErr,{"Produto [" + C1_PRODUTO + "] SC [" + aSolic[nProd,5] + "] e SC [" + C1_NUM + "] com campos Data de Necessidade, Setor ou Centro de Custo diferentes.","Data: "+DtoC(C1_DATPRF) +" # " + DtoC(aSolic[nProd,2]) + CRLF + "Local: "+ C1_LOCAL + " # " + aSolic[nProd,3] + CRLF + "C.Custo: " + C1_CC +" # "+aSolic[nProd,4]}))
					lRet := .F.
				EndIf
			EndIf
		EndIf

	Next

	If Len(aMsgErr) > 0
		U_F12MsgErr(aMsgErr,"Dados inconsistentes para geração.")
	EndIf

	RestArea(aArea)

Return lRet


/*{Protheus.doc} F12MsgErr
Função de mensagem de erro em grid
@param aMsgErr Vetor de mensgens com mensagem, detalhe
@param cMsg Subtítulo da mensagem de erro.
*/
User Function F12MsgErr(aMsgErr,cMsg)

	Local oDlgEsp
	Local oLbxEsp
	Local cLbx    := ''
	
	DEFAULT aMsgErr := {{"Erro 01","Detalhe"},{"Erro 02","Detalhe"}}
	DEFAULT cMsg    := "Dados do Erro."

	DEFINE MSDIALOG oDlgEsp TITLE "Verifique os dados..." FROM 00,00 TO 350,769 PIXEL
		@ 05,01 LISTBOX oLbxEsp VAR cLbx FIELDS HEADER cMsg SIZE 383,142 OF oDlgEsp PIXEL
		oLbxEsp:SetArray( aMsgErr )
		oLbxEsp:bLine	:= { || { aMsgErr[ oLbxEsp:nAT, 1 ] } }
		@ 160, 340 BUTTON oBut PROMPT "Sair" SIZE 037, 012 OF oDlgEsp PIXEL ACTION oDlgEsp:End()
		oLbxEsp:blDblClick := {|| MsgInfo(aMsgErr[ oLbxEsp:nAT, 2 ],"Detalhe do Erro.") }
	ACTIVATE MSDIALOG oDlgEsp CENTERED

Return
