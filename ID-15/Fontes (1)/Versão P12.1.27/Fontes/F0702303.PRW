#Include 'Protheus.ch'
#INCLUDE "TBICONN.CH"

/*/{Protheus.doc} F0702303
Job para calcular custo médio corporativo
@type function
@author queizy.nascimento
@since 13/02/2017
@version 1.0
@param aParam, array, (Descrição do parâmetro)
@project MAN0000007423041_EF_023
/*/
User Function F0702303(aParam)
	Local cFilJob := aParam[2] //Recebe Filial
	Local cEmpJob := aParam[1] //Recebe Empresa

	If IsBlind()
		RpcSetEnv(cEmpJob,cFilJob)

		CMedCorp() //Calculo de Custo Médio Corporativo
		CMedFil()//Calculo de Custo Médio por Filial
		
		RpcClearEnv()
	
	Endif

Return

/*/{Protheus.doc} CMedCorp
Calculo de Custo Médio Corporativo
@type function
@author queizy.nascimento
@since 14/02/2017
@version 1.0
@project MAN0000007423041_EF_023
/*/
Static Function CMedCorp()
	Local cQuery  := ""
	Local cAliSB2 := GetNextAlias()

	cQuery:=" SELECT SUM (B2_VATU1) /SUM(B2_QATU)AS MEDIA, B.R_E_C_N_O_ SB1REC " + CRLF
	cQuery +=" FROM " + RETSQLNAME('SB2') + " A  INNER JOIN " + RETSQLNAME('SB1') + " B ON A.B2_COD=B.B1_COD" + CRLF
	cQuery +=" WHERE A.D_E_L_E_T_ = ' ' AND  B.D_E_L_E_T_ = ' '" + CRLF
	cQuery +=" AND A.B2_QATU > 0" + CRLF
	cQuery +=" GROUP BY B.B1_COD,B.R_E_C_N_O_" + CRLF
	cQuery +=" ORDER BY B.B1_COD" + CRLF
	cQuery := ChangeQuery(cQuery)
		
	DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliSB2)

	While ! (cAliSB2)->(EOF())

		SB1->(dbGoto((cAliSB2)->SB1REC))
   
		SB1->(RECLOCK("SB1", .F.))
		SB1->B1_XCMCORP := (cAliSB2)->MEDIA
		SB1->(MSUNLOCK("SB1"))
		(cAliSB2)->(DbSkip())
	EndDo
 
	(cAliSB2)->(DbCloseArea())
		
Return

/*/{Protheus.doc} CMedFil
Custo médio por Filial 
@type function
@author queizy.nascimento
@since 10/02/2017
@version 1.0
@project MAN0000007423041_EF_023
/*/
Static Function CMedFil()
	Local cQuery := ""
	Local cAliSB2:= GetNextAlias()
	
	cQuery:=" SELECT A.B2_FILIAL, SUM (B2_VATU1) /SUM(B2_QATU)AS MEDIA, B.R_E_C_N_O_ SBZREC " + CRLF
	cQuery +=" FROM " + RETSQLNAME('SB2') + "  A  " + CRLF
	cQuery +=" INNER JOIN " + RETSQLNAME('SBZ') + "  B ON  A.B2_FILIAL = B.BZ_FILIAL AND A.B2_COD=B.BZ_COD" + CRLF
	cQuery +=" WHERE A.D_E_L_E_T_ = ' ' AND  B.D_E_L_E_T_ = ' ' " + CRLF
	cQuery +=" AND A.B2_QATU > 0" + CRLF
	cQuery +=" GROUP BY A.B2_FILIAL,B.R_E_C_N_O_" + CRLF
	cQuery +=" ORDER BY A.B2_FILIAL" + CRLF
	cQuery := ChangeQuery(cQuery)

	DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliSB2)

	While ! (cAliSB2)->(EOF())

		SBZ->(dbGoto((cAliSB2)->SBZREC))
   
		SBZ->(RECLOCK("SBZ", .F.))
		SBZ->BZ_XCMCORP := (cAliSB2)->MEDIA
		SBZ->(MSUNLOCK("SBZ"))
		(cAliSB2)->(DbSkip())
	EndDo
 
	(cAliSB2)->(DbCloseArea())

Return



