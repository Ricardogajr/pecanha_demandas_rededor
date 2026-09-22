#Include 'Protheus.ch' 

/*
{Protheus.doc}  F300SE5()
PE para identificar e baixar títulos gerados na reposição do caixinha, no momento do retorno de SISPAG. 
@Author  Ramon Teodoro e Silva	
@Since   10/01/2017       
@Version P12.7
*/
User Function F300SE5()

Local lRet     := .T.
Local aAreaSE2 := SE2->(GetArea())
Local aAreaSE5 := SE5->(GetArea())
Local nSaldoAn := 0
Local nValRep  := SE2->E2_VALOR
Local cCaixa     := SE2->E2_XCAIXIN
Local cSeqCxa 	 := IIF( !Empty(Alltrim(cCaixa)), U_RetSeqAnt(SE2->E2_XCAIXIN, SE2->E2_NUM), "") //Fa570SeqAtu( cCaixa)

If !Empty(cCaixa) .And. Alltrim(SE2->E2_ORIGEM) == "FINA050"
	
	DbSelectArea("SET")
	DbSetOrder(1)
	DbGoTop()
	
	PcoIniLan("000359")
	
	If DbSeek(xFilial("SET")+cCaixa)
		
		nSaldoAn := SET->ET_SALDO

		If ((SET->ET_SALDO+nValRep)>SET->ET_VALOR).and.GetNewPar("MV_RPCXMN","1")== "1"
			MsgAlert("Valor de reposição maior que o permitido", "Erro no momento da reposição do caixinha") //"Valor maior que o permitido."
			lRet := .F.
		Else
		
			//Baixa das despesas
          	DbSelectArea("SEU")
			SEU->(DbSetOrder(5))  // filial + caixa + sequencia + num
			SEU->(DbSeek( xFilial("SEU")+ cCaixa + cSeqCxa))
			While !SEU->(Eof()) .And. xFilial("SEU")+cCaixa+cSeqCxa == SEU->(EU_FILIAL+EU_CAIXA+EU_SEQCXA)
	
				If SEU->EU_TIPO == "00" .And. Empty(SEU->EU_BAIXA) .And. SEU->EU_XNUMTIT == SE2->E2_NUM
					RecLock("SEU", .F.)
					SEU->EU_BAIXA := dDataBase
					SEU->(MsUnLock())
				Endif
	
				SEU->(DbSkip())
			End
			
			//Reposição
			RecLock("SET",.F.)
			SET->ET_SALDO  := nSaldoAn+ nValRep
			SET->ET_ULTREP := dDataBase
			SET->ET_SALANT := nSaldoAn
			//If nSaldoAn > 0
			//	SET->ET_SEQCXA := SOMA1(SET->ET_SEQCXA)
			//EndIf
			MsUnlock()
			PcoDetLan("000359","01","FINA550")
					
			Fa550Mov( SET->ET_CODIGO, "10", nValRep,"Reposição de Banco"+SET->ET_BANCO)
			AtuSalCxa( SET->ET_CODIGO, dDataBase, nValRep, .F. )
			
		EndIf
	
	EndIf
		
	PcoFinLan("000359")

EndIf

//Incluido por Thiago Goes em 16/09/2021
RestArea(aAreaSE2)
RestArea(aAreaSE5)

DbselectArea("SA2")
dbSetOrder(1)

SA2->(Dbseek(xFilial("SA2")+SE2->(E2_FORNECE+E2_LOJA)))

Return lRet


