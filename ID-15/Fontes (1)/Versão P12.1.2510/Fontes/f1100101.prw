#INCLUDE 'Protheus.ch'

/*{Protheus.doc} F1100101
Pto.Entrada (MDTA6854) criado após a inclusão do Atestado Médico, possibilitando a alteração da tabela TNY.

@author		Ademar Fernandes
@since		26/07/2017
@project	MAN0000007423045_EF_003 
*/
User Function F1100101(nOpcao)
	Local lRet 		:= .T.
	Local cMyChave
	Local aGravar	:= {}
	Local nOpcao := 4
	
	If INCLUI
		nOpcao := 3
	ElseIf ALTERA
		nOpcao := 4
	Else
		nOpcao := 5
	Endif
	
	//-Pesquisar SR8 para confirmar se gravou la
	If RetSR8() .And. (SubStr(DTOS(SR8->R8_DATAINI),1,6) < SubStr(DTOS(Date()),1,6) .And. !Empty(SR8->R8_DATAINI)) .OR.;
		(SubStr(DTOS(SR8->R8_DATAFIM),1,6) < SubStr(DTOS(Date()),1,6) .And. !Empty(SR8->R8_DATAFIM))
			aAdd(aGravar,{	SR8->R8_FILIAL,;//-01 //-SR8->R8_FILIAL
					SR8->R8_MAT,;//-03 //-SR8->R8_MAT
					SRA->RA_CC,;//-02 //-SR8->R8_CC
					SRA->RA_ADMISSA,;//-04 //-
					SRA->RA_SITFOLH,;//-05 //-
					SRA->RA_CATFUNC,;//-06 //-
					,;//-07 //-SR8->R8_TIPO
					SR8->R8_TIPOAFA,;//-08 //-SR8->R8_TIPOAFA	//-(*) Campo novo
					SR8->R8_SEQ,;//-09 //-SR8->R8_SEQ
					SR8->R8_DATAINI,;//-10 //-SR8->R8_DATAINI
					SR8->R8_DATAFIM ; //-11 //-SR8->R8_DATAFIM
				})			
		//-Grava a tabela de Afastamentos cadastrados de forma retroativa
		U_F1100102(nOpcao,aGravar)
	EndIf
Return(lRet)


Static Function RetSR8()
	Local cNewAlias	:= GetNextAlias()
	Local lRet		:= .F.	

	cQuery := " SELECT R8_MAT, SR8.R_E_C_N_O_ NumRec From "+RetSqlName("SR8")+" SR8 " 
	cQuery += " WHERE "
	cQuery += " R8_FILIAL = '"+TNY->TNY_FILIAL+"'"
	cQuery += " AND R8_DATAFIM = '"+DTOS(TNY->TNY_DTFIM)+"'"
	cQuery += " AND R8_TIPO = '"+TNY->TNY_TIPAFA+"'"
	cQuery += " AND R8_TIPOAFA = '"+TNY->TNY_CODAFA+"'"
	cQuery += " AND R8_MAT = '"+SubStr(TNY->TNY_NUMFIC,1,6)+"' "
	cQuery += " AND D_E_L_E_T_ = '' "

	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T., "TOPCONN", TcGenQry(, ,cQuery), cNewAlias, .T., .T.)

	While (cNewAlias)->(!EOF())
		SR8->(dbGoTo((cNewAlias)->NumRec))
		SRA->(DbSeek(SR8->(R8_FILIAL+R8_MAT)))
		lRet	:= .T.
		(cNewAlias)->(DbSkip())
	End
	(cNewAlias)->(DbCloseArea())
	
Return lRet