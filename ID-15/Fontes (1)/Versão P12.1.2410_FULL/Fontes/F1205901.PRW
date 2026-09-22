#Include 'Protheus.ch'

/*{Protheus.doc} F1205901
Execução da baixa e do reprocessamento de registro da tabela P20
@author CDE - Célula de Desenvolvimento Especifico
@since  19/09/2018
@Project MAN0000007423048_EF_059
*/
User Function F1205901(cFilID,cIDLOG,cTpMethd)
	
	Local bExec   := {|| .T. }
	Local aPar    := {}
	Local nRecno  := 0
	LocaL nIDJOB  := ""
	Local cRotina := ""
	Local cRetMsg := "OK|REGISTRO PROCESSADO"
	Local cFilAux := cFilAnt
	
	cFilAnt := cFilID
	
	DbSelectArea("P20")
	P20->(DbSetOrder(2)) //P20_FILIAL+P20_ID
	If P20->(DbSeek(cFilID+cIDLOG))
		nRecno := P20->(Recno())
		If P20->P20_STATUS == "1" .AND. Empty(P20->P20_DTHRR)
			If cTpMethd == "1"
				P20->(DbGoto(nRecno))
				P20->(RecLock("P20",.F.))
				P20->P20_STATUS := "0"
				P20->(MsUnLock())
			Else
				If "(" $ P20->P20_INPUT
					// Tratamento do imput
					// Exemplo: Antes 'U_F0702902(01,000001,01,1232  ,  ,   ,NF,3,,10.4)'
					// no input a função poderá ter somente parametros com string e com a opcao de NIL
					// Depois 'U_F0702902("01","000001","01","1232  ","  ","   ","NF","3",,"10.4")'
					cRotina := Alltrim(P20->P20_INPUT)
					FWJsonDeserialize(cRotina,@cRotina)
					cRotina := StrTran(cRotina,',','","')
					cRotina := StrTran(cRotina,'(','("')
					cRotina := StrTran(cRotina,')','")')
					cRotina := StrTran(cRotina,'""','')
					cRotina := '{|x| ' + cRotina + '}'
					bExec := &cRotina
					eval(bExec)
				Else
					cRotina := Alltrim(P20->P20_ROTINA)
					FWJsonDeserialize(Alltrim(P20->P20_INPUT),aPar)
					bExec := &('{|x| ' + cRotina + '(x)}')
					eval(bExec,aPar)
				EndIf
				
				nIDJOB := P20->P20_ID
				
				P20->(DbGoto(nRecno))
				P20->(RecLock("P20",.F.))
				P20->P20_IDJOB := nIDJOB
				P20->P20_DTHRR := FwTimeStamp()
				P20->(MsUnLock())
			EndIf
		ELSE
			cRetMsg := "ERRO|REGISTRO NÃO É DE FALHA"
		EndIf
	Else
		cRetMsg := "ERRO|REGISTRO NÃO ENCONTRADO"
	EndIf
	
	cFilAnt := cFilAux
	
Return cRetMsg