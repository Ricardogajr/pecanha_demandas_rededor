#Include 'Protheus.ch'

/*
{Protheus.doc} F0800801()
Validar se o usuário solicitado está abaixo do nível do solicitante
@Author  Bruno de Oliveira
@Since   10/03/2017
@Version P12.1.07
@Project MAN0000007423042_EF_005
@param   cFilResp, characters, descricao
@param   cMatResp, characters, descricao
@param   cFilSol, characters, descricao
@param   cMatSol, characters, descricao
@param   cTpSol, characters, descricao
@param   cCodVis, characters, descricao
@Return  aRet, parametros referente ao aprovador
*/

User Function F0800801(cFilResp, cMatResp, cFilSol, cMatSol, cTpSol, cCodVis)

	Local aRetSol := {}
	Local nPos := 0
	Local lRet := .F.
		
	If cTpSol == "1" //Todos os níveis inferiores
		aRetSol := U_F0500198(cFilResp,cMatResp,cCodVis)
	ElseIf cTpSol == "2" //Apenas nível inferior imediato
		aRetSol := FsImediats(cFilResp,cMatResp,cCodVis)
	EndIf

	nPos := AScan(aRetSol,{|x| x[3] + x[4] == cFilSol + cMatSol})
	If nPos > 0
		lRet := .T.
	EndIf

Return lRet

/*
{Protheus.doc} FsImediats()
Busca os funcionários imediatos da visão referente ao solicitante
@Author     Bruno de Oliveira
@Since      10/03/2017
@Version    P12.1.07
@Project    MAN0000007423042_EF_005
@Param		cFilSol,caracter, 
@Param		cMatSol,caracter,  
@Param		cCodVis,caracter, 
@Return     aRet, parametros referente ao aprovador
*/
Static Function FsImediats(cFilSol, cMatSol, cCodVis)

	Local cAlias1 := GetNextAlias()
	Local cAlias3 := GetNextAlias()
	Local cAlias4 := GetNextAlias()
	Local aPostos := {}
	Local nX      := 0
	Local aImedts := {}
	Local cRCX    := "%" + RetFullName("RCX",cEmpAnt) + "%"
	Local cRD4    := "%" + RetFullName("RD4",cEmpAnt) + "%"

	BeginSql alias cAlias1
		
		SELECT RD4.RD4_ITEM
		FROM %EXP:cRCX% RCX
		INNER JOIN %table:RD4% RD4 ON RD4.RD4_CODIDE = RCX.RCX_POSTO AND RCX.RCX_FILIAL = RD4.RD4_FILIDE
		WHERE
		RD4.RD4_FILIAL    = %xfilial:RD4% AND
		RD4.RD4_CODIGO    = %exp:cCodVis% AND
		RCX.RCX_MATFUN    = %exp:cMatSol% AND
		RCX.RCX_FILFUN    = %exp:cFilSol% AND
		RCX.RCX_SUBST     = '2'           AND
		RCX.RCX_TIPOCU    = '1'           AND
		RD4.%notDel%                      AND
		RCX.%notDel%
		
	EndSql
	
	If (cAlias1)->(!EOF())
	
		cItem := (cAlias1)->RD4_ITEM
		
		BeginSql alias cAlias3
				
			SELECT RD4.RD4_CODIDE,RD4.RD4_FILIDE
			FROM %Exp:cRD4% RD4
			WHERE RD4.RD4_FILIAL = %xfilial:RD4% AND
			RD4.RD4_CODIGO = %exp:cVisao%  AND
			RD4.RD4_TREE   = %exp:cItem%   AND
			RD4.%notDel%
				
		EndSql
		
		While (cAlias3)->(!EOF())
			AAdd(aPostos, { (cAlias3)->RD4_FILIDE,;
				            (cAlias3)->RD4_CODIDE })
		(cAlias3)->(DbSkip())
		End
		
		(cAlias3)->(DbCloseArea())
		
		For nX := 1 To Len(aPostos)
		
			cFilPost := aPostos[nX][1]
			cCodPost := aPostos[nX][2]
			
			BeginSql alias cAlias4
				
				SELECT RCX.RCX_FILFUN,RCX.RCX_MATFUN,RCX.RCX_POSTO,RCX.RCX_FILIAL
				FROM %Exp:cRCX% RCX
				WHERE RCX.RCX_FILIAL = %exp:cFilPost% AND
				RCX.RCX_POSTO = %exp:cCodPost%  AND
				RCX.%notDel%
				
			EndSql
			
			While (cAlias4)->(!EOF())
				AAdd(aImedts, { (cAlias4)->RCX_FILIAL,;
					            (cAlias4)->RCX_POSTO,;
					            (cAlias4)->RCX_FILFUN,;
					            (cAlias4)->RCX_MATFUN })
			(cAlias4)->(DbSkip())
			End
 			(cAlias4)->(DbCloseArea())
		
		Next nX
		
	EndIf

	(cAlias1)->(DbCloseArea())

Return aImedts