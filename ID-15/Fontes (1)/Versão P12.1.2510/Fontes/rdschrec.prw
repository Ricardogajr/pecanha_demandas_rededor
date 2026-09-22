#Include "Protheus.ch"
#include "rwmake.ch"
#include "ap5mail.ch"
/*/{Protheus.doc} RDSCHREC
Schedule para recusar nota fiscal de integração.
@author Carlos Alberto Gomes Junior
@since 05/12/2017
/*/
User function RDSCHREC(aEmp)

	Local cQuery := ""
	Local cAliasSE2 := GetNextAlias()
	Local cDiasRec := 0
	Local cTexto := ""
	Local lRecusa := .F.
	Local cTimeDesc := "00:00:00"

	//RpcSetEnv(aEmp[1],aEmp[2])
	RpcSetEnv("01","01010004")
	cDiasRec := SuperGetMv("MV_XDRECNF",,5)
	cTimeDesc := SuperGetMv("MV_XHRREC",,"02:00")

	cQuery += " SELECT SE2.R_E_C_N_O_ AS E2RECNO, SE2.E2_XDTRECU, SF1.F1_XSTRECU, SE2.E2_XSTRECU, SF1.F1_XDTVNF, SE2.E2_VENCREA, SF1.F1_FILIAL, SF1.F1_DOC, SF1.F1_SERIE, P09.P09_CODORI, SF1.R_E_C_N_O_ AS F1RECNO FROM " + RetSqlName("SE2") +" SE2 "+ CRLF
	cQuery += " INNER JOIN " + RetSqlName("SF1") + " SF1 " + CRLF
	cQuery += " ON SF1.D_E_L_E_T_ = ' ' " + CRLF 
	cQuery += " AND SF1.F1_FILIAL = SE2.E2_FILIAL " + CRLF
	cQuery += " AND SF1.F1_DOC = SE2.E2_NUM " + CRLF
	cQuery += " AND SF1.F1_SERIE = SE2.E2_PREFIXO " + CRLF
	cQuery += " AND SF1.F1_FORNECE = SE2.E2_FORNECE " + CRLF
	cQuery += " AND SF1.F1_LOJA = SE2.E2_LOJA " + CRLF
	cQuery += " INNER JOIN " + RetSqlName("SD1") + " SD1 " + CRLF
	cQuery += " ON SD1.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += " AND SD1.D1_FILIAL = SF1.F1_FILIAL " + CRLF
	cQuery += " AND SD1.D1_DOC =  SF1.F1_DOC " + CRLF
	cQuery += " AND SD1.D1_SERIE = SF1.F1_SERIE " + CRLF
	cQuery += " AND SD1.D1_FORNECE = SF1.F1_FORNECE " + CRLF
	cQuery += " AND SD1.D1_LOJA = SF1.F1_LOJA " + CRLF
	cQuery += " LEFT JOIN "+RetSqlName("P09")+" P09  " + CRLF
	cQuery += " ON P09_FILIAL = SE2.E2_FILIAL   " + CRLF
	cQuery += " AND (( P09_ROTINA = 'MATA103' AND P09_CODORI = SE2.E2_NUM||SE2.E2_PREFIXO||SE2.E2_FORNECE||SE2.E2_LOJA) OR (P09_ROTINA = 'MATA121' AND P09_CODORI = SD1.D1_PEDIDO))" + CRLF
	cQuery += " AND P09.D_E_L_E_T_ = ' '  " + CRLF
	cQuery += " WHERE SE2.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += " AND SF1.F1_XSOLPAG != '1' " 	+ CRLF
	cQuery += " AND (SF1.F1_XSTRECU = ' ' AND  SE2.E2_XSTRECU = ' ')" 	+ CRLF
	cQuery += " AND SE2.E2_SALDO > 0 "      + CRLF
	cQuery += " AND SF1.F1_XUSRIN BETWEEN '" + DTOS(dDatabase - 1) + " " + intToHora(SubTHoras(dDatabase,cTimeDesc,dDatabase,Time()))  + "' AND '" +  DtoS(dDatabase) +" "+ intToHora(SubTHoras(dDatabase,cTimeDesc,dDatabase,Time())) + "' " + CRLF
	cQuery += " GROUP BY SE2.R_E_C_N_O_, SE2.E2_XDTRECU, SF1.F1_XSTRECU, SE2.E2_XSTRECU, SF1.F1_XDTVNF, SE2.E2_VENCREA, SF1.F1_FILIAL, SF1.F1_DOC, SF1.F1_SERIE, P09.P09_CODORI, SF1.R_E_C_N_O_" + CRLF

/*	cQUery += " AND NOT EXISTS (SELECT R_E_C_N_O_ FROM " + RetSqlName("P00")+ " P00 " + CRLF
	cQuery += " WHERE P00.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += " AND P00_FILIAL = SE2.E2_FILIAL AND P00_NUM = SE2.E2_NUM AND P00_PREFIX = SE2.E2_PREFIXO AND P00_FORNEC = SE2.E2_FORNECE AND P00_LOJAF = SE2.E2_LOJA )" + CRLF*/
	
	DbUseArea(.T., "TOPCONN", TcGenQry(, , cQuery), cAliasSE2, .T., .T.)
	cFilBkp := cFilAnt
	While !(cAliasSE2)->(Eof())
		cFilAnt := (cAliasSE2)->F1_FILIAL
	 	ndiasUteis := zDiasUteis(dDatabase, SToD((cAliasSE2)->E2_VENCREA))
		lRecusa := .F.
		//Posiciona na nota.
		if Empty((cAliasSE2)->P09_CODORI)
			cTexto := GETSPARAM("MV_XREF01",,"Recusa automática NF Material - Documento esta sem anexo.") 
			lRecusa := .T.
		endif

		if ndiasUteis <= cDiasRec
			cTexto += GETSPARAM("MV_XREF02",,"Recusa automática NF Material - Vencimento menor ou igual a "+cValToChar(cDiasRec)+" dias.") 			
			lRecusa := .T.			
		endif

		if !lRecusa
			(cAliasSE2)->(DbSkip())
			loop
		endif
	

		SF1->(DbGoTo((cAliasSE2)->F1RECNO))
		//Posiciona no titulo
		SE2->(DbGoTo((cAliasSE2)->E2RECNO))
		//Executa Rotina de Recusa.
		U_F010101A(.F., cTexto)
		cTexto := ""
		(cAliasSE2)->(DbSkip())
	EndDo
	cFilAnt := cFilBkp
Return 

Static Function zDiasUteis(dDtIni, dDtFin)
    Local aArea    := FWGetArea()
    Local nDias    := 0
    Local dDtAtu   := sToD("")
    Default dDtIni := dDataBase
    Default dDtFin := dDataBase
     
    //Enquanto a data atual for menor ou igual a data final
    dDtAtu := dDtIni
	While dDtAtu <= dDtFin
        //Se a data atual for uma data Válida
		If dDtAtu == DataValida(dDtAtu)
            nDias++
		EndIf
         
        dDtAtu := DaySum(dDtAtu, 1)
	EndDo
     
    RestArea(aArea)
Return nDias

Static Function GETSPARAM(_cPar01,_lPar02,_cPar03,_cPar04)
Default _lPar02 := .F.
Default _cPar03 := ""
Default _cPar04 := cFilAnt
Return SUPERGETMV(_cPar01,_lPar02,_cPar03,_cPar04)
