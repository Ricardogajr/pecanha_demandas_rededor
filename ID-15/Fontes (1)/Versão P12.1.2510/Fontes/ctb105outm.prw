#Include "Protheus.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CTB105OUTM  ºAutor  ³ Auremar Duarte   º Data ³ 31/07/2017  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Programa para validar alterações de lançamentos (CT2) que  º±±
±±º          ³ não tenham sido feitos manualmente                         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

USER FUNCTION CTB105OUTM()

//Local dDataLanc := PARAMIXB[1]
//Local cLote     := PARAMIXB[2]
//Local cSubLote  := PARAMIXB[3]
//Local cDoc      := PARAMIXB[4]
Local lRet      := .T.
Local cMensagem := ""
Local _lLp      := Iif(Alltrim(CT2->CT2_LP) <> "",.T.,.F.)
Local _lLibera  := GetNewPar("MV_LIBALTI","N") == "S" //Rota de Saída prevista

// If !IsBlind()//Não passar por off-line - Rotina de contabilização da Folha não reconhe Variável ALTERA
If IsInCallStack("CTBA102")

	If ALTERA
	
		If Alltrim(CT2->CT2_MANUAL) = "2" .OR. _lLp 
	
			If !_lLibera		
				lRet := .F.   
				cMensagem := "Não pode ser Alterado um documento "+CRLF   
				cMensagem += "contábil oriundo de integrações "+CRLF   
					
				Help("CTBA102",1,"HELP","CTB_MOV_INT",cMensagem,1,0)
			Endif
		Endif
	Endif
Endif	

RETURN lRet