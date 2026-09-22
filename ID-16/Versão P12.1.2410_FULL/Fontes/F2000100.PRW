#Include 'Totvs.ch'

#Define INCLUI_PREV 01
#Define ALTERA_PREV 02
#Define EXCLUI_PREV 03
#Define ENVBAN_PREV 04
#Define REJBAN_PREV 05
#Define BAIXAT_PREV 06
#Define ESTBXA_PREV 07
#Define GRVCHQ_PREV 08
#Define ESTCHQ_PREV 09
#Define ENVBAN_REAL 21
#Define REJBAN_REAL 22
#Define BAIXAT_REAL 23
#Define ESTBXA_REAL 24
#Define GRVCHQ_REAL 31
#Define ESTCHQ_REAL 32
#Define PAGADT_REAL 41
#Define RECADT_REAL 42

/*/{Protheus.doc} User Function F2000100
    Realiza gravação da PX0 com os dados do título, para posterior
    integração destes.
    Deverá obrigatóriamente estar posicionado na SE2 no momento da chamada
    Caso seja chamado para gerar a partir da FK2, também deve estar posicionado
    na linha da movimentação.
    @param cOrig, Character, Tabela de origem (SE2 ou FK2)
    @param nOpc, Numeric, Indica a operação a ser realizada na PX0
    @type  Function
    @author Gianluca Moreira
    @since 19/05/2021
    /*/
User Function F2000100(cOrig, nOpc)
	Local aArea     := GetArea()
	Local aAreaSE2  := SE2->(GetArea())
	Local aAreaFK2  := FK2->(GetArea())
	Local aAreaFK5  := FK5->(GetArea())
	Local aAreaPX0  := PX0->(GetArea())
	Local aAreas    := {aAreaSE2, aAreaFK2, aAreaFK5, aAreaPX0, aArea}
	Local aTemp     := {'2', '3'} //Temperaturas de previsão
	Local cChave    := ''
	Local cStTit    := ''
	Local cStXRT    := '1' //Pendente Integração
	Local cFlagInt  := '2' //Nunca integrado
	Local nValor    := 0
	Local cIDCNAB   := ''
	Local cBordero  := ''
	Local cCheque   := ''
	Local cChvXRT   := ''
	Local cExc      := '2' //Não excluído
	Local cDados    := ''
	//Local nMoviment := 0
	Local lNewLine  := .T.
	Local nRecPX0   := 0
	Local nTemp     := 0
	Local lGrpHblt  := U_F2000132() //Verifica tabela PX1 para a empresa/filial atual

	//Integração não habilitada neste grupo
	If !lGrpHblt
		AEval(aAreas, {|x| RestArea(x)})
		U_LimpaArr(aAreas)
		Return nRecPX0
	EndIf

	//Verifica regras da integração
	If !U_F2000200(nOpc)
		AEval(aAreas, {|x| RestArea(x)})
		U_LimpaArr(aAreas)
		Return nRecPX0
	EndIf


	If cOrig == 'SE2'
		cChave := SE2->(E2_FILIAL+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA)
	ElseIf cOrig == 'FK2'
		cChave := FK2->(FK2_FILIAL+FK2_IDFK2)
	ElseIf cOrig == 'FK5'
		cChave := FK5->(FK5_FILIAL+FK5_IDMOV)
	Else
		UserException('Gravação PX0 - Origem '+cOrig+' inválida')
	EndIf

	PX0->(DbSetOrder(2)) //PX0_FILIAL+PX0_STTIT+PX0_ORIGEM+PX0_CHAVE+PX0_EXC
	//Inclusão de novos registros em aberto
	If nOpc == INCLUI_PREV
		//Busca se existe registro não excluído em aberto para este título
		For nTemp := 1 To Len(aTemp)
			cStTit := aTemp[nTemp]
			If PX0->(DbSeek(FWXFilial('PX0')+cStTit+cOrig+AvKey(cChave, 'PX0_CHAVE')+'2'))
				lNewLine := .F.
				cFlagInt := PX0->PX0_STINT
				cChvXRT  := PX0->PX0_CHVXRT
				cStTit   := PX0->PX0_STTIT
				Exit
			EndIf
		Next nTemp


		//nValor := SE2->(E2_SALDO+E2_SDACRES-E2_SDDECRE)
		nValor := SE2->(E2_VALOR+E2_MULTA+E2_JUROS+E2_ACRESC-E2_DECRESC)
		nValor -= SE2->E2_VALLIQ //Total de baixas

		If SE2->E2_TIPO $ MVPAGANT
			nValor -= U_F200010B() //Calcula valor total movimentado do adiantamento
		EndIf
		If nValor <= 0
			AEval(aAreas, {|x| RestArea(x)})
			U_LimpaArr(aAreas)
			Return 0
		EndIf
		If lNewLine
			cChvXRT  := GeraChav()
			If U_F2000201() //Títulos de gestão de pessoas
				cStTit := '2' //Temp 1
			Else
				cStTit   := '3' //Temp 2
			EndIf
		EndIf
		cDados   := GeraDados(SE2->E2_VENCREA)
		cIDCNAB  := SE2->E2_IDCNAB
		cCheque  := SE2->E2_NUMBCO
		cBordero := SE2->E2_NUMBOR
		If !Empty(cBordero)
			cStTit := '2' //Temp 1
		EndIf
		If !Empty(cCheque)
			cStTit := '2' //Temp 1
		EndIf

		//Alteração do título em aberto
	ElseIf nOpc == ALTERA_PREV
		//Busca se existe registro não excluído em aberto para este título
		For nTemp := 1 To Len(aTemp)
			cStTit := aTemp[nTemp]
			If PX0->(DbSeek(FWXFilial('PX0')+cStTit+cOrig+AvKey(cChave, 'PX0_CHAVE')+'2'))
				lNewLine := .F.
				cFlagInt := PX0->PX0_STINT
				cChvXRT  := PX0->PX0_CHVXRT
				cStTit   := PX0->PX0_STTIT
				Exit
			EndIf
		Next nTemp
		If lNewLine
			//Linhas novas de registros não são inclusas caso o registro não exista
			AEval(aAreas, {|x| RestArea(x)})
			U_LimpaArr(aAreas)
			Return nRecPX0
		EndIf

		//nValor := SE2->(E2_SALDO+E2_SDACRES-E2_SDDECRE)
		nValor := SE2->(E2_VALOR+E2_MULTA+E2_JUROS+E2_ACRESC-E2_DECRESC)
		nValor -= SE2->E2_VALLIQ //Total de baixas

		If SE2->E2_TIPO $ MVPAGANT
			nValor -= U_F200010B() //Calcula valor total movimentado do adiantamento
		EndIf
		If nValor <= 0
			nValor   := 0
			cExc     := '1'
		EndIf
		cIDCNAB  := SE2->E2_IDCNAB
		cCheque  := SE2->E2_NUMBCO
		cBordero := SE2->E2_NUMBOR
		If !Empty(cBordero)
			cStTit := '2' //Temp 1
			nValor := SE2->(E2_SALDO+E2_MULTA+E2_JUROS+E2_ACRESC-E2_DECRESC-E2_DESCONT)//Solicitado alteração pelo Chistian.
			Conout("---------------------------Entrou na REGRA DO BORDERO")
		EndIf
		If !Empty(cCheque)
			cStTit := '2' //Temp 1
			nValor := SE2->(E2_SALDO+E2_MULTA+E2_JUROS+E2_ACRESC-E2_DECRESC-E2_DESCONT)//Solicitado alteração pelo Chistian.
			Conout("---------------------------Entrou na REGRA DO CHEQUE")
		EndIf
		cDados   := GeraDados(SE2->E2_VENCREA)

		//Exclusão de título em aberto
	ElseIf nOpc == EXCLUI_PREV
		//Busca se existe registro não excluído em aberto para este título
		For nTemp := 1 To Len(aTemp)
			cStTit := aTemp[nTemp]
			If PX0->(DbSeek(FWXFilial('PX0')+cStTit+cOrig+AvKey(cChave, 'PX0_CHAVE')+'2'))
				lNewLine := .F.
				cFlagInt := PX0->PX0_STINT
				cChvXRT  := PX0->PX0_CHVXRT
				cStTit   := PX0->PX0_STTIT
				Exit
			EndIf
		Next nTemp
		If lNewLine
			//Linhas novas de registros não são inclusas caso o registro não exista
			AEval(aAreas, {|x| RestArea(x)})
			U_LimpaArr(aAreas)
			Return nRecPX0
		EndIf
		nValor   := 0
		cExc     := '1'
		cIDCNAB  := SE2->E2_IDCNAB
		cCheque  := SE2->E2_NUMBCO
		cBordero := SE2->E2_NUMBOR
		cDados   := GeraDados(SE2->E2_VENCREA)

		//Envio ao banco do título em aberto - Previsto
	ElseIf nOpc == ENVBAN_PREV
		//Busca se existe registro não excluído em aberto para este título
		For nTemp := 1 To Len(aTemp)
			cStTit := aTemp[nTemp]
			If PX0->(DbSeek(FWXFilial('PX0')+cStTit+cOrig+AvKey(cChave, 'PX0_CHAVE')+'2'))
				lNewLine := .F.
				cFlagInt := PX0->PX0_STINT
				cChvXRT  := PX0->PX0_CHVXRT
				Exit
			EndIf
		Next nTemp

		cStTit   := '2' //Temp 1
		If SE2->(FieldPos('E2_XVLLIQ')) > 0 .And. SE2->E2_XVLLIQ > 0 .And. !(SE2->E2_TIPO $ MVPAGANT)
			nValor := SE2->E2_XVLLIQ
		Else
			nValor := SE2->(E2_SALDO+E2_SDACRES-E2_SDDECRE)
		EndIf
		If SE2->E2_TIPO $ MVPAGANT
			nValor -= U_F200010B() //Calcula valor total movimentado do adiantamento
		EndIf
		If nValor <= 0
			AEval(aAreas, {|x| RestArea(x)})
			U_LimpaArr(aAreas)
			Return 0
		EndIf

		If lNewLine
			cChvXRT  := GeraChav()
		EndIf

		cIDCNAB  := SE2->E2_IDCNAB
		cCheque  := SE2->E2_NUMBCO
		cBordero := SE2->E2_NUMBOR
		cDados   := GeraDados(SE2->E2_VENCREA)
		//Baixa do título em aberto - Previsto
	ElseIf nOpc == BAIXAT_PREV
		//já foi enviado e não retornou ainda
        /*If nOpc == ENVBAN_PREV .And. SE2->E2_XENVBCO == '1' 
            AEval(aAreas, {|x| RestArea(x)})
            U_LimpaArr(aAreas)
            Return nRecPX0
	EndIf*/
        //Busca se existe registro não excluído em aberto para este título
	For nTemp := 1 To Len(aTemp)
            cStTit := aTemp[nTemp]
		If PX0->(DbSeek(FWXFilial('PX0')+cStTit+cOrig+AvKey(cChave, 'PX0_CHAVE')+'2'))
                lNewLine := .F.
                cFlagInt := PX0->PX0_STINT
                cChvXRT  := PX0->PX0_CHVXRT
                Exit
		EndIf
	Next nTemp

	If lNewLine
            //Linhas novas de registros não são inclusas caso o registro não exista
            //Se ainda houver saldo, ele será criado pelo webservice
            AEval(aAreas, {|x| RestArea(x)})
            U_LimpaArr(aAreas)
            Return nRecPX0
	EndIf

        cStTit   := '2' //Temp 1
        //nValor := SE2->(E2_SALDO+E2_SDACRES-E2_SDDECRE)
        nValor := SE2->(E2_VALOR+E2_MULTA+E2_JUROS+E2_ACRESC-E2_DECRESC)
        nValor -= SE2->E2_VALLIQ //Total de baixas
        nValor   += IIf(FK2->FK2_RECPAG == 'P', -FK2->FK2_VALOR, FK2->FK2_VALOR)
	If nValor <= 0
            nValor := 0
	EndIf
        cExc     := IIf(nValor <= 0, '1', '2')
        cIDCNAB  := SE2->E2_IDCNAB
        cCheque  := SE2->E2_NUMBCO
        cBordero := SE2->E2_NUMBOR
        cDados   := GeraDados(SE2->E2_VENCREA)

    //Rejeição bancária do título - Previsto
ElseIf nOpc == REJBAN_PREV
        //Conforme MIT31 - inclusão de nova temperatura - na rejeição bancária
        //não deve realizar nenhuma operação, pois o título não foi pago
        //e já está com temperatura 1
        AEval(aAreas, {|x| RestArea(x)})
        U_LimpaArr(aAreas)
        Return nRecPX0

    //Estorno da baixa - Previsto
ElseIf nOpc == ESTBXA_PREV
        //já retornou, ou nem foi enviado
        /*If nOpc == REJBAN_PREV .And. SE2->E2_XENVBCO $ ' 2' 
            AEval(aAreas, {|x| RestArea(x)})
            U_LimpaArr(aAreas)
            Return nRecPX0
EndIf*/
For nTemp := 1 To Len(aTemp)
            cStTit := aTemp[nTemp]
	If PX0->(DbSeek(FWXFilial('PX0')+cStTit+cOrig+AvKey(cChave, 'PX0_CHAVE')+'2'))
                lNewLine := .F.
                cFlagInt := PX0->PX0_STINT
                cChvXRT  := PX0->PX0_CHVXRT
                Exit
	EndIf
Next nTemp

        //Não é preciso enviar previsto com data retroativa/do dia caso ele não exista
If lNewLine .And. Date() >= SE2->E2_VENCREA
            AEval(aAreas, {|x| RestArea(x)})
            U_LimpaArr(aAreas)
            Return nRecPX0
EndIf
If lNewLine
            cChvXRT := GeraChav()
EndIf
        cStTit   := '2' //Temp 1
        //nValor := SE2->(E2_SALDO+E2_SDACRES-E2_SDDECRE)
        nValor := SE2->(E2_VALOR+E2_MULTA+E2_JUROS+E2_ACRESC-E2_DECRESC)
        nValor -= SE2->E2_VALLIQ //Total de baixas
        /*Else //ESTBXA_PREV
            nValor := IIf(lNewLine, 0, PX0->PX0_VALOR)
            nValor += IIf(FK2->FK2_RECPAG == 'P', -FK2->FK2_VALOR, FK2->FK2_VALOR)
EndIf*/
If nValor <= 0
            nValor := 0 
EndIf
        cExc     := IIf(nValor == 0, '1', '2')
        cIDCNAB  := SE2->E2_IDCNAB
        cCheque  := SE2->E2_NUMBCO
        cBordero := SE2->E2_NUMBOR
        cDados   := GeraDados(SE2->E2_VENCREA)

    //Geração de cheque - Previsto
ElseIf nOpc == GRVCHQ_PREV
	For nTemp := 1 To Len(aTemp)
            cStTit := aTemp[nTemp]
		If PX0->(DbSeek(FWXFilial('PX0')+cStTit+cOrig+AvKey(cChave, 'PX0_CHAVE')+'2'))
                lNewLine := .F.
                cFlagInt := PX0->PX0_STINT
                cChvXRT  := PX0->PX0_CHVXRT
                Exit
		EndIf
	Next nTemp

	If lNewLine
            //Linhas novas de registros não são inclusas caso o registro não exista
            //Se ainda houver saldo, ele será criado pelo webservice
            AEval(aAreas, {|x| RestArea(x)})
            U_LimpaArr(aAreas)
            Return nRecPX0
	EndIf

        cStTit   := '2' //Temp 1
        //nValor   := Max(SE2->(E2_SALDO+E2_SDACRES-E2_SDDECRE) - SEF->EF_VALOR, 0)
	If SE2->(FieldPos('E2_XVLLIQ')) > 0 .And. SE2->E2_XVLLIQ > 0 .And. !(SE2->E2_TIPO $ MVPAGANT)
            nValor := SE2->E2_XVLLIQ
	Else
            //nValor := SE2->(E2_SALDO+E2_SDACRES-E2_SDDECRE)
            //nValor := SE2->(E2_VALOR+E2_MULTA+E2_JUROS+E2_ACRESC-E2_DECRESC)
            nValor := SE2->(E2_SALDO+E2_MULTA+E2_JUROS+E2_ACRESC-E2_DECRESC-E2_DESCONT)//Solicitado alteração pelo Chistian.
            //nValor -= SE2->E2_VALLIQ //Total de baixas
	EndIf
        cExc     := IIf(nValor <= 0, '1', '2')
        cIDCNAB  := SE2->E2_IDCNAB
        cCheque  := SEF->EF_NUM
        cBordero := SE2->E2_NUMBOR
        cDados   := GeraDados(SE2->E2_VENCREA)
    
    //Estorno de cheque - Previsão
ElseIf nOpc == ESTCHQ_PREV
	For nTemp := 1 To Len(aTemp)
            cStTit := aTemp[nTemp]
		If PX0->(DbSeek(FWXFilial('PX0')+cStTit+cOrig+AvKey(cChave, 'PX0_CHAVE')+'2'))
                lNewLine := .F.
                cFlagInt := PX0->PX0_STINT
                cChvXRT  := PX0->PX0_CHVXRT
                Exit
		EndIf
	Next nTemp

	If lNewLine
            //Linhas novas de registros não são inclusas caso o registro não exista
            //Se ainda houver saldo, ele será criado pelo webservice
            AEval(aAreas, {|x| RestArea(x)})
            U_LimpaArr(aAreas)
            Return nRecPX0
	EndIf

        cStTit   := '3' //Temp 2
        //nValor   := Max(SE2->(E2_SALDO+E2_SDACRES-E2_SDDECRE) - SEF->EF_VALOR, 0)
	If SE2->(FieldPos('E2_XVLLIQ')) > 0 .And. SE2->E2_XVLLIQ > 0 .And. !(SE2->E2_TIPO $ MVPAGANT)
            nValor := SE2->E2_XVLLIQ
	Else
            //nValor := SE2->(E2_SALDO+E2_SDACRES-E2_SDDECRE)
            //nValor := SE2->(E2_VALOR+E2_MULTA+E2_JUROS+E2_ACRESC-E2_DECRESC)
            nValor := SE2->(E2_SALDO+E2_MULTA+E2_JUROS+E2_ACRESC-E2_DECRESC-E2_DESCONT)//Solicitado alteração pelo Chistian.
            //nValor -= SE2->E2_VALLIQ //Total de baixas
	EndIf
        cExc     := IIf(nValor <= 0, '1', '2')
        cIDCNAB  := SE2->E2_IDCNAB
        cCheque  := SE2->E2_NUMBCO
        cBordero := SE2->E2_NUMBOR
        cDados   := GeraDados(SE2->E2_VENCREA)

    //Envio bancário - Realizado
ElseIf nOpc == ENVBAN_REAL
        //Conforme MIT31 - inclusão de nova temperatura - no envio bancário
        //não deve realizar nenhuma operação de título realizado pois
        //ele constará como temperatura 1
        AEval(aAreas, {|x| RestArea(x)})
        U_LimpaArr(aAreas)
        Return nRecPX0

        /*
        //já foi enviado e não retornou ainda
	If SE2->E2_XENVBCO == '1'
            AEval(aAreas, {|x| RestArea(x)})
            U_LimpaArr(aAreas)
            Return nRecPX0
	EndIf

        cStTit := '2' //Realizado
	If SE2->(FieldPos('E2_XVLLIQ')) > 0 .And. SE2->E2_XVLLIQ > 0 .And. !(SE2->E2_TIPO $ MVPAGANT)
            nValor := SE2->E2_XVLLIQ
	Else
            nValor := SE2->(E2_SALDO+E2_SDACRES-E2_SDDECRE)
	EndIf
        cIDCNAB  := SE2->E2_IDCNAB
        cCheque  := SE2->E2_NUMBCO
        cBordero := SE2->E2_NUMBOR
	If lNewLine
            cChvXRT := GeraChav()
	EndIf
        cDados   := GeraDados(Date()) //Data de pagamento
        */
	//Rejeição Bancária - Realizado
ElseIf nOpc == REJBAN_REAL
	//Conforme MIT31 - inclusão de nova temperatura - no envio bancário
	//não deve realizar nenhuma operação de título realizado pois
	//ele constará como temperatura 1
	AEval(aAreas, {|x| RestArea(x)})
	U_LimpaArr(aAreas)
Return nRecPX0
        /*
        //já retornou, ou nem foi enviado
	If SE2->E2_XENVBCO $ ' 2'
            AEval(aAreas, {|x| RestArea(x)})
            U_LimpaArr(aAreas)
            Return nRecPX0
	EndIf

        cStTit   := '2' //Realizado
	If SE2->(FieldPos('E2_XVLLIQ')) > 0 .And. SE2->E2_XVLLIQ > 0 .And. !(SE2->E2_TIPO $ MVPAGANT)
            nValor := -SE2->E2_XVLLIQ
	Else
            nValor := -SE2->(E2_SALDO+E2_SDACRES-E2_SDDECRE)
	EndIf
        cIDCNAB  := SE2->E2_IDCNAB
        cCheque  := SE2->E2_NUMBCO
        cBordero := SE2->E2_NUMBOR
        cChvXRT  := GeraChav()
        cDados   := GeraDados(Date()) //Data de pagamento
        */
	//Ocorreu baixa do título
ElseIf nOpc == BAIXAT_REAL .Or. nOpc == ESTBXA_REAL
	//Procura se já foi gerada integração para esta baixa, pois o IDFK2 é único por linha
	cStTit := '1' //Temp -1
	If PX0->(DbSeek(FWXFilial('PX0')+cStTit+cOrig+AvKey(cChave, 'PX0_CHAVE')+'2'))
		AEval(aAreas, {|x| RestArea(x)})
		U_LimpaArr(aAreas)
		Return nRecPX0
	EndIf

	nValor   := IIf(nOpc == BAIXAT_REAL, FK2->FK2_VALOR, -FK2->FK2_VALOR)
	cIDCNAB  := SE2->E2_IDCNAB
	cCheque  := SE2->E2_NUMBCO
	cBordero := SE2->E2_NUMBOR
	cChvXRT  := GeraChav()
	cDados   := GeraDados(FK2->FK2_DATA) //Data de pagamento
/*
    //Geração de cheque - Realizado
ElseIf nOpc == GRVCHQ_REAL
        cStTit := '1' //Realizado
	If SE2->(FieldPos('E2_XVLLIQ')) > 0 .And. SE2->E2_XVLLIQ > 0 .And. !(SE2->E2_TIPO $ MVPAGANT)
            nValor := SE2->E2_XVLLIQ
	Else
            nValor := SE2->(E2_SALDO+E2_SDACRES-E2_SDDECRE)
	EndIf
        cIDCNAB  := SE2->E2_IDCNAB
        cCheque  := SE2->E2_NUMBCO
        cBordero := SE2->E2_NUMBOR
	If lNewLine
            cChvXRT := GeraChav()
	EndIf
        cDados   := GeraDados(Date()) //Data de pagamento

    //Estorno de cheque - Realizado
ElseIF nOpc == ESTCHQ_REAL
*/
ElseIf nOpc == PAGADT_REAL .Or. nOpc == RECADT_REAL
	//Procura se já foi gerada integração para esta baixa, pois o IDMOV é único por linha
	cStTit := '1' //Temp -1
	If PX0->(DbSeek(FWXFilial('PX0')+cStTit+cOrig+AvKey(cChave, 'PX0_CHAVE')+'2'))
		AEval(aAreas, {|x| RestArea(x)})
		U_LimpaArr(aAreas)
		Return nRecPX0
	EndIf

	nValor   := IIf(nOpc == PAGADT_REAL, FK5->FK5_VALOR, -FK5->FK5_VALOR)
	cIDCNAB  := SE2->E2_IDCNAB
	cCheque  := SE2->E2_NUMBCO
	cBordero := SE2->E2_NUMBOR
	cChvXRT  := GeraChav()
	cDados   := GeraDados(FK5->FK5_DATA) //Data de pagamento
Else
	UserException('Operacao PX0 '+cValToChar(nOpc)+' inválida!')
EndIf

If RecLock('PX0', lNewLine)
	PX0->PX0_FILIAL := FWXFilial('PX0')
	PX0->PX0_ORIGEM := cOrig
	PX0->PX0_CHAVE  := cChave
	PX0->PX0_STTIT  := cStTit
	PX0->PX0_STXRT  := cStXRT
	PX0->PX0_STINT  := cFlagInt
	PX0->PX0_VALOR  := nValor
	PX0->PX0_CNAB   := cIDCNAB
	PX0->PX0_NUMBOR := cBordero
	PX0->PX0_NUMBCO := cCheque
	If lNewLine
		PX0->PX0_CHVXRT := cChvXRT
	EndIf
	PX0->PX0_EXC    := cExc
	PX0->PX0_DADOS  := cDados
	PX0->PX0_DTHR   := FwTimeStamp(1)
	PX0->(MsUnlock())
EndIf

nRecPX0 := PX0->(Recno())

AEval(aAreas, {|x| RestArea(x)})
U_LimpaArr(aAreas)
Return nRecPX0

/*/{Protheus.doc} GeraChav
    Gera uma nova chave para a integração
    @type  Static Function
    @author Gianluca Moreira
    @since 19/05/2021
    @version version
    /*/
Static Function GeraChav(dDataBx)
	Local aArea     := GetArea()
	Local aAreaPX0  := PX0->(GetArea())
	Local aAreas    := {aAreaPX0, aArea}
	Local cChvXRT := ''

	cChvXRT := GetSXENum('PX0', 'PX0_CHVXRT',, 3)
	PX0->(DbSetOrder(3)) //PX0_FILIAL+PX0_CHVXRT
	While PX0->(DbSeek(FWXFilial('PX0')+cChvXRT))
		ConfirmSX8()
		cChvXRT := GetSXENum('PX0', 'PX0_CHVXRT',, 3)
	EndDo
	ConfirmSX8()

	AEval(aAreas, {|x| RestArea(x)})
	U_LimpaArr(aAreas)
Return cChvXRT

/*/{Protheus.doc} GeraDados
    Prepara o JSON com os dados do título que serão integrados posteriormente
    @type  Static Function
    @author Gianluca Moreira
    @since 19/05/2021
    @version version
    /*/
Static Function GeraDados(dDataBx)
	Local aArea     := GetArea()
	Local aAreaSA2  := SA2->(GetArea())
	Local aAreaSE2  := SE2->(GetArea())
	Local aAreaSF1  := SF1->(GetArea())
	Local aAreas    := {aAreaSA2, aAreaSE2, aAreaSF1, aArea}
	Local cDados    := ''
	Local dDtVenc   := ''
	Local jDados    := JSonObject():New()

	Default dDataBx := SE2->E2_VENCREA

	dDtVenc := SE2->E2_VENCREA
	jDados['E5_DATA']    := Year2Str(dDataBx)+'-'+Month2Str(dDataBx)+'-'+Day2Str(dDataBx)+'T00:00:00.000'
	jDados['E2_VENCREA'] := Year2Str(dDtVenc)+'-'+Month2Str(dDtVenc)+'-'+Day2Str(dDtVenc)+'T00:00:00.000'
	jDados['E2_NATUREZ'] := AllTrim(SE2->E2_NATUREZ)
	jDados['E2_TIPO']    := AllTrim(SE2->E2_TIPO)
	If SE2->(FieldPos('E2_XAGEPOR')) > 0
		jDados['E2_PORTADO'] := AllTrim(IIf(Empty(SE2->E2_PORTADO), U_PortAuto('E2_PORTADO'), SE2->E2_PORTADO))
		jDados['E2_XAGEPOR'] := AllTrim(IIf(Empty(SE2->E2_XAGEPOR), U_PortAuto('E2_XAGEPOR'), SE2->E2_XAGEPOR))
		jDados['E2_XCONPOR'] := AllTrim(IIf(Empty(SE2->E2_XCONPOR), U_PortAuto('E2_XCONPOR'), SE2->E2_XCONPOR))
	EndIf
	jDados['E2_FORMPAG'] := AllTrim(IIf(Empty(SE2->E2_FORMPAG), '.', SE2->E2_FORMPAG))
	If Empty(SE2->E2_HIST)
		jDados['E2_HIST'] := AllTrim(SE2->(E2_FILIAL+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA))
	Else
		jDados['E2_HIST'] := AllTrim(SE2->E2_HIST)
	EndIf
	jDados['E2_MOEDA']   := Val(cValToChar(SE2->E2_MOEDA))
	jDados['E2_TXMOEDA'] := SE2->E2_TXMOEDA//IIf(SE2->E2_TXMOEDA <= 0, 1, SE2->E2_TXMOEDA)
	jDados['E2_XOPFXRT'] := AllTrim(IIf(SE2->(FieldPos('E2_XOPFXRT'))>0, SE2->E2_XOPFXRT, ''))

	jDados['A2_NOME'] := ' '
	jDados['A2_CGC']  := ' '
	SA2->(DbSetOrder(1)) //A2_FILIAL+A2_COD+A2_LOJA
	If SA2->(DbSeek(FWXFilial('SA2')+SE2->(E2_FORNECE+E2_LOJA)))
		jDados['A2_NOME'] := AllTrim(SA2->A2_NREDUZ)
		jDados['A2_CGC']  := AllTrim(SA2->A2_CGC)
	EndIf

	jDados['F1_NOTA'] := ' '
	If SE2->E2_ORIGEM == 'MATA100' .Or. (SE2->E2_ORIGEM == 'FINA050' .And. !Empty(SE2->E2_XID))
		SF1->(DbSetOrder(1)) //F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA+F1_TIPO
		If SF1->(DbSeek(FWXFilial('SF1')+AvKey(SE2->E2_NUM, 'F1_DOC')+AvKey(SE2->E2_PREFIXO, 'F1_SERIE')+SE2->(E2_FORNECE+E2_LOJA)))
			jDados['F1_NOTA'] := AllTrim(SF1->(F1_DOC+F1_SERIE))
		EndIf
	EndIf
	If Empty(jDados['F1_NOTA'])
		jDados['F1_NOTA'] := AllTrim(SE2->E2_PREFIXO)+'.'
		jDados['F1_NOTA'] += AllTrim(SE2->E2_NUM)+'.'
		jDados['F1_NOTA'] += AllTrim(SE2->E2_PARCELA)+'.'
		jDados['F1_NOTA'] += AllTrim(SE2->E2_TIPO)+'.'
		jDados['F1_NOTA'] += AllTrim(SE2->E2_FORNECE)+'.'
		jDados['F1_NOTA'] += AllTrim(SE2->E2_LOJA)
	EndIf

	jDados['F1_NOTA'] := Left(jDados['F1_NOTA'], 15)

	//Callstack para rastreabilidade
	jDados['CALLSTACK'] := RetCStack()

	AEval(aAreas, {|x| RestArea(x)})
	U_LimpaArr(aAreas)

	cDados := jDados:ToJson()
Return cDados


/*/{Protheus.doc} F200010B
    Calcula o total de movimentos bancários de adiantamento
    para um título de PA
    @type  Static Function
    @author Gianluca Moreira
    @since 25/05/2021
    @version version
    /*/
User Function F200010B()
	Local aAreaSE5  := SE5->(GetArea())
	Local aAreas    := {aAreaSE5, GetArea()}
	Local cChvSE2   := ''
	Local nValor    := 0

	cChvSE2 := FWXFilial('SE5')+SE2->(E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA)
	SE5->(DbSetOrder(7)) //E5_FILIAL + E5_PREFIXO + E5_NUMERO + E5_PARCELA + E5_TIPO + E5_CLIFOR + E5_LOJA + E5_SEQ
	If SE5->(DbSeek(cChvSE2))
		While !SE5->(EoF()) .And. cChvSE2 == SE5->(E5_FILIAL+E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+E5_CLIFOR+E5_LOJA)
			If Empty(SE5->E5_SITUACA) //Não cancelado/estornado/excluido
				nValor += IIf(SE5->E5_RECPAG == 'P', SE5->E5_VALOR, -SE5->E5_VALOR)
			EndIf
			SE5->(DbSkip())
		EndDo
	EndIf

	AEval(aAreas, {|x| RestArea(x)})
	U_LimpaArr(aAreas)
Return nValor

/*/{Protheus.doc} RetCStack
    Retorna a pilha de chamadas
    @type  Static Function
    @author user
    /*/
Static Function RetCStack()
	Local cStack := ''
	Local nI     := 0

	For nI := 1 To 25
		cStack += CRLF+ProcName(nI)+' - Linha: ('+cValToChar(ProcLine(nI))+')'
	Next nI
Return cStack
