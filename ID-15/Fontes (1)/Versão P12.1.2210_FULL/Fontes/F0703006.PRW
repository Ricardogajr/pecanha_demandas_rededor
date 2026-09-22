#INCLUDE 'TOTVS.CH' 

/*{Protheus.doc} F0703006
Retorna Custo Médio.
@author Paulo Krüger
@since  11/12/2017
@project MAN0000007423041_EF_030
@version P12.1.7
@param cFilOri - Filial
@param cProd - Código do Produto
@param cLocal - Local de estoque
@param dDataFim - Data de referência
@return nCusMed - Custo Médio 
*/ 

User Function F0703006(cFilOri, cProd, cLocal, dDataFim) 

Local	nCusMed		:=	0
Local	cAlias02	:=	''
Local	cDataRef	:=	''

Default cFilOri		:=	''
Default cProd		:=	''
Default cLocal		:=	''
Default dDataFim	:=	''

cAlias02	:=	GetNextAlias()
cDataRef	:=	SUBSTR(DTOS(dDataFim),01,06)	

BeginSql Alias cAlias02
SELECT	CASE WHEN SB9.B9_QINI <> 0 THEN SB9.B9_VINI1 / B9_QINI ELSE 0 END CUSTO 
FROM	%Table:SB9% SB9
WHERE		SB9.%notDel%
		AND SB9.B9_FILIAL	=	%Exp:cFilOri%
		AND SB9.B9_COD		=	%Exp:cProd%
		AND SB9.B9_LOCAL	=	%Exp:cLocal%
		AND SUBSTRING(SB9.B9_DATA,01,06) =	%Exp:cDataRef%
EndSql

(cAlias02)->(DbGoTop())

IF EOF() .AND. BOF()
	nCusMed := 0
ELSE		
	nCusMed :=  (cAlias02)->CUSTO
ENDIF

(cAlias02)->(dbCloseArea())

Return(nCusMed)