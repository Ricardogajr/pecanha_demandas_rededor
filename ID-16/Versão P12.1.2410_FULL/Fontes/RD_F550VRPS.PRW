#Include 'Protheus.ch' 
#Include 'TopConn.Ch'

/*
{Protheus.doc}  F550VRPS()
PE para Gerar títulos a pagar no momento da reposição do caixinha. 
@Author  Ramon Teodoro e Silva	
@Since   16/03/2016       
@Version P12.7
*/
User Function F550VRPS()

Local lRet     := .F.
Local aArea    := GetArea()
Local cNumTit  := CriaVar("E2_NUM") //"000000022"
Local aTit     := {}
Local nValRep  := Paramixb[1]
Local cPrefix  := PadR("FF", TamSx3("E2_PREFIXO")[1])
Local cTipo    := PadR("CX", TamSx3("E2_TIPO")[1])
Local cFormPag := PadR("10", TamSx3("E2_FORMPAG")[1])
Local nDias    := 5
Local aUltMov  := U_RetUltMov(SET->ET_CODIGO)

Private lMsErroAuto := .F.

Public lGerouRep := .F. //Thais Paiva - 13596614

If IsInCallStack("FINA080") .Or. IsInCallStack("Fa550Baixa")
	lRet := .T.
Else
	If nValRep > 0
	
		//If MsgYesNo("Deseja fazer a reposição de " + Str(nValRep) + "?","Atenção!")
		
			If U_VerTitCx(SET->ET_CODIGO, aUltMov) .And. U_VerAdto(aUltMov)
					
				cNumTit := U_RetSeqNum() //GetSxeNum("SE2", "E2_NUM", 1)
				//ConfirmSx8()
				
				aTit := { { "E2_PREFIXO"  , cPrefix         	    , NIL },;
				          { "E2_NUM"      , cNumTit                 , NIL },;
				          { "E2_TIPO"     , cTipo            	    , NIL },;
				          { "E2_NATUREZ"  , SET->ET_NATUREZ  	    , NIL },;
				          { "E2_FORNECE"  , SET->ET_FORNECE  	    , NIL },;
				          { "E2_EMISSAO"  , dDataBase        	    , NIL },;
				          { "E2_VENCTO"   , DaySum(dDataBase,nDias) , NIL },;
				          { "E2_VENCREA"  , LastDay(DaySum(dDataBase,nDias),3) , NIL },;
				          { "E2_VALOR"    , nValRep           		, NIL },;
				          { "E2_PORTADO"  , SET->ET_BANCO    		, NIL },;
				          { "E2_XAGEPOR"  , SET->ET_AGEBCO   		, NIL },;
				          { "E2_XCONPOR"  , SET->ET_CTABCO   		, NIL },;
				          { "E2_FORMPAG"  , cFormPag        		, NIL },;
				          { "E2_CCUSTO"   , SET->ET_CC              , NIL },;
				          { "E2_ORIGEM"   , "FINA050"      		 	, NIL },;
				          { "E2_XCAIXIN"  , SET->ET_CODIGO    		, NIL }}
				
				MsExecAuto( { |x,y,z| FINA050(x,y,z)}, aTit,, 3)   
				 
				If lMsErroAuto
					U_GrInfMov(aUltMov, cNumTit, .T.)
					RollBackSx8()
					If !(IsBlind())
						MostraErro()
					EndIf
				Else
					U_GrInfMov(aUltMov, cNumTit, .F. ) //GRAVAÇÃO DO NUMERO DO TÍTULO NA SEU
					If SET->ET_SALDO > 0 .And. !Empty(SET->ET_ULTREP) 
						RecLock("SET",.F.)
						SET->ET_SEQCXA := SOMA1(SET->ET_SEQCXA)
						MsUnlock()
					EndIf
					//MsgInfo("Foi criado o título a pagar " + Alltrim(cNumTit) + " no valor de R$" + Alltrim(Transform(nValRep,PesqPict("SE2","E2_VALOR"))) + " com vencimento para " + DtoC(LastDay(DaySum(dDataBase,nDias),3)) + ". É necessário realizar a baixa para que a reposição seja concluída" ) Thais Paiva - 13596614
					lGerouRep := .T. //Thais Paiva - 13596614
				Endif
			EndIf
		//EndIf
	EndIf
EndIf

RestArea(aArea)

Return lRet



/*
{Protheus.doc}  VerTitCx)
Verifica se já existe título em aberto para o caixinha 
@Author  Ramon Teodoro e Silva	
@Since   22/09/2016       
@Version P12.7
*/
User Function VerTitCx(cCaixa, aUltMov)

Local lRet   := .T.
Local aArea  := GetArea()
Local cQuery := ""
Local cAliasCx 	:= GetNextAlias()

cQuery := "SELECT R_E_C_N_O_ RECCX FROM " + RetSqlName("SE2")
cQuery += " WHERE E2_FILIAL = '" + xFilial("SE2") + "' AND E2_PREFIXO = 'FF ' AND E2_SALDO > 0 AND "
cQuery += " E2_XCAIXIN = '" + cCaixa + "' AND D_E_L_E_T_ = ''"
cQuery := ChangeQuery( cQuery ) 

If Select(cAliasCx) > 0
	(cAliasCx)->(DbCloseArea())
EndIf
			
DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasCx,.F.,.T.)

If (cAliasCx)->(!Eof())
	MsgStop("Existe um título a pagar em aberto para este caixinha, é necessário que seja feita a baixa do mesmo antes de uma nova reposição.")
	lRet := .F.
	U_GrInfMov(aUltMov,"", .T.)	
EndIf

(cAliasCx)->(DbCloseArea())

RestArea(aArea)

Return lRet



/*
{Protheus.doc}  VerAdto)
Verifica se existe adiantamento em aberto para o caixinha e altera a data de baixa das despesas como vazio (a data da baixa só deverá ser feita no momento da reposição)
@Author  Ramon Teodoro e Silva	
@Since   07/03/2017       
@Version P12.7
*/
User Function VerAdto(aUltMov)

Local lRet    := .T.
Local aArea   := GetArea()
Local nD      := 0

For nD := 1 to Len(aUltMov)

	If aUltMov[nD][5] == "01"
		lRet := .f.
	EndIf

Next nD

RestArea(aArea)
Return lRet


/*
{Protheus.doc}  GrInfMov)
Grava o número do título gerado nas despesas em aberto, para rastreamento do banco de conhecimento
@Author  Ramon Teodoro e Silva	
@Since   27/06/2017       
@Version P12.7
*/
User Function GrInfMov(aUltMov, cNumTit, lFoundTit)

Local lRet   := .T.
Local aArea  := GetArea()
Local nC     := 0

Default lFoundTit := .F.

DbSelectArea("SEU")
SEU->(DbSetOrder(5))
 
For nC := 1 to Len(aUltMov)

	If DbSeek(xFilial("SEU") + aUltMov[nC][2] + aUltMov[nC][3] + aUltMov[nC][4] )	
		RecLock("SEU", .F.)
		SEU->EU_BAIXA   := CtoD(" ")
		If !lFoundTit
			SEU->EU_XNUMTIT := cNumTit
		EndIf
		SEU->(MsUnLock())
	EndIf

Next nC

RestArea(aArea)

Return lRet



/*
{Protheus.doc}  RetUltMov)
Função para trazer as últimas despesas realizadas após a ultima reposição
@Author  Ramon Teodoro e Silva	
@Since  30/06/2017       
@Version P12.7
*/

User Function RetUltMov(cCaixa, cSeqAnt )

Local aRet    := {} 
Local aArea   := GetArea()
Local cSeqCxa := ""

Default cSeqAnt := ""

cSeqCxa := IIf(Empty(cSeqAnt), Fa570SeqAtu(cCaixa), cSeqAnt)

DbSelectArea("SEU")
SEU->(DbSetOrder(5))  // filial + caixa + sequencia + num
SEU->(DbSeek( xFilial("SEU")+ cCaixa + cSeqCxa))
While !SEU->(Eof()) .And. xFilial("SEU")+cCaixa+cSeqCxa == SEU->(EU_FILIAL+EU_CAIXA+EU_SEQCXA) 
	
	If SEU->EU_TIPO == "00" 
	
		If !Empty(SEU->EU_BAIXA)
		
			aAlias := GetArea()
			cNumAd := SEU->EU_NUM
			cNroAd := SEU->EU_NROADIA
					
			SEU->(DbSetOrder(6))
			If Dbseek(xFilial("SEU")+cCaixa+"02"+ cNumAd) // Verifica se se a depesa nao foi cancelada
				RestArea(aAlias)
				SEU->(DbSkip())
				Loop
			Else
				RestArea(aAlias)
				Aadd(aRet, {SEU->EU_FILIAL, SEU->EU_CAIXA, SEU->EU_SEQCXA, SEU->EU_NUM, SEU->EU_TIPO})
		 	EndIf
		
		Else
			Aadd(aRet, {SEU->EU_FILIAL, SEU->EU_CAIXA, SEU->EU_SEQCXA, SEU->EU_NUM, SEU->EU_TIPO})		
		EndIf
	
	EndIf
	
	SEU->(DbSkip())
		
End

RestArea(aArea)

Return aRet

/*
{Protheus.doc}  RetSeqNum()
Função feita para retornar a sequencia de número de títulos para o caixinha, evitando duplicidades com a GetSxeNum.  
@Author  Ramon Teodoro e Silva	
@Since   20/07/2017       
@Version P12.7
*/

User Function RetSeqNum() 
Local cRet   := ""
Local aArea  := GetArea()
Local cQuery := ""

cQuery := " SELECT E2_NUM FROM " + RetSqlName("SE2") + " "
cQuery += " WHERE E2_FILIAL = '" + xFilial("SE2") + "' AND E2_XCAIXIN <> ' ' AND E2_PREFIXO = 'FF' AND"
cQuery += " ROWNUM = 1  AND D_E_L_E_T_ = ' ' ORDER BY  E2_NUM DESC " //Pega o 

If Select("TMPTCX") > 0
	DbSelectArea("TMPTCX")
	TMPTCX->(DbCloseArea())
EndIf

TCQUERY cQuery New Alias "TMPTCX"

If !TMPTCX->(Eof())
	cRet := Soma1(TMPTCX->E2_NUM)
Else
	cRet := StrZero( 1, TamSx3("E2_NUM")[1])
EndIf

TMPTCX->(DbCloseArea())

RestArea(aArea)

Return cRet

