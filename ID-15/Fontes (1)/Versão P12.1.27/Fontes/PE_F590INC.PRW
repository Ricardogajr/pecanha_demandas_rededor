 #include 'TOTVS.CH'
 
/*/{Protheus.doc} F590INC
Ponto de entrada  que permite a manipulação da rotina, sendo acionado apos a inclusao do bordero.
@type User function
@author Paulo Krüger
@since 17/03/2017
@version 12.7
@project MAN0000007423041_EF_029
@return NIL
/*/

User Function F590INC()

Local aArea		:= GetArea()
Local cAlias01	:= ''
Local cFilOri	:= xFilial('SEA')
Local cNumBord	:= cNumBor

cAlias01 := GetNextAlias()
BeginSql Alias cAlias01
%noparser%
SELECT	SE2.E2_XID	FILIDINTE
FROM	%Table:SEA% SEA 
			INNER JOIN %Table:SE2% SE2 ON		SE2.E2_FILORIG	=	SEA.EA_FILIAL
											AND	SE2.E2_PREFIXO	=	SEA.EA_PREFIXO
											AND	SE2.E2_PARCELA	=	SEA.EA_PARCELA
											AND SE2.E2_TIPO		=	SEA.EA_TIPO
											AND SE2.E2_FORNECE	=	SEA.EA_FORNECE
											AND	SE2.E2_LOJA		=	SEA.EA_LOJA
WHERE		SEA.%notDel%
		AND	SE2.%notDel%
		AND	SEA.EA_FILIAL	=	%Exp:cFilOri%
		AND	SEA.EA_NUMBOR	=	%Exp:cNumBord%
EndSql

(cAlias01)->(DbGoTop())

While (cAlias01)->(!Eof())

	U_F0702901((cAlias01)->FILIDINTE)
	
	(cAlias01)->(DbSkip())
	Loop
EndDo

If Select(cAlias01) > 0
	(cAlias01)->(dbCloseArea()) 
EndIf

RestArea(aArea)

Return