#Include 'Protheus.ch' 
#Include 'TopConn.Ch'

/*
{Protheus.doc}  F560BLOCK 
Ponto de entrada para alterar a sequência das despesas relacionadas ao título que está sendo incluído, para que 
possam ser baixadas na próxima reposição. 
@Author  Ramon Teodoro e Silva	
@Since   22/08/2018       
@Version P12.7
*/

User Function FA050Del()

Local lRet    := .T.
Local aArea   := GetArea()
Local cQuery  := ""
Local cSeqCxa := "" 
Local cMV_FORINSS := SuperGetMV("MV_FORINSS",,"") //Thais Paiva - 11586347
Local cMV_LOJINSS := STRZERO(0,TamSX3("E2_LOJA")[1]) //Thais Paiva - 11586347

If !Empty(SE2->E2_XCAIXIN)

	cSeqCxa := Fa570SeqAtu(SE2->E2_XCAIXIN)

	DbSelectArea("SEU")
	DbSetOrder(1)

	cQuery := " SELECT R_E_C_N_O_ AS RECNO FROM " + RetSqlName("SEU") + " " 
	cQuery += " WHERE EU_FILIAL = '" + xFilial("SEU") + "' AND EU_CAIXA = '" + SE2->E2_XCAIXIN + "'"
	cQuery += " AND EU_XNUMTIT = '" + SE2->E2_NUM + "' AND EU_BAIXA = ' ' AND D_E_L_E_T_ = ' '"
	
	If Select("TMPSEU") > 0
		DbSelectArea("TMPSEU")
		TMPSEU->(DbCloseArea())
	EndIf
	
	TCQUERY cQuery New Alias "TMPSEU"
	
	While !TMPSEU->(Eof())
	
		SEU->(DbGoTo(TMPSEU->RECNO))
		RecLock("SEU", .F.)
		SEU->EU_SEQCXA  := cSeqCxa
		SEU->EU_XNUMTIT := " "
		SEU->(MsUnLock())
			
		TMPSEU->(DbSkip())
	
	End

EndIf

//Início - Thais Paiva - 11586347
cMV_FORINSS := LEFT(ALLTRIM(cMV_FORINSS)+SPACE(10),TamSX3("E2_FORNECE")[1])
If !(UPPER(ALLTRIM(funname())) $ "ETX_BRWS|AGL_MRKB|ETX_CANC|AGL_BRWE")
   If SE2->E2_PREFIXO = "AGI" .AND. SE2->E2_TIPO = "INS" .AND. SE2->E2_FORNECE = cMV_FORINSS   
      MsgStop("Este Título é um Aglutinador de INSS, para a Exclusão, deve-se utilizar a Rotina de Aglutinação de INSS","Erro")   
      lRet := .F.
   Endif                                                                      
Endif
//Fim - Thais Paiva - 11586347

RestArea(aArea)
Return lRet

