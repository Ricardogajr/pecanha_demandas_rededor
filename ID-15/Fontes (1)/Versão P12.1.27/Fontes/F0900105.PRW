#INCLUDE "PROTHEUS.CH"
/*{Protheus.doc} F0900105
Utilizado para filtrar consulta padrão de produto no pedido de compra
@author Alex Sandro Valario
@since 26/05/2017
@Project MAN0000007423043_EF_001
*/

User Function F0900105()

	Local aGrupos      := {}
    Local cAliasP21    := GetNextAlias()
    Local cQuery       := ""
	Local cFiltroProd  := ""
	Local cUser	       := RetCodUsr()
	Local nX	       := 0
	
    BeginSql Alias cAliasP21
       SELECT 
          P21.P21_TPPRD
       FROM %table:P21% P21
       INNER JOIN  %table:SAJ% SAJ
           ON SAJ.AJ_FILIAL = %xFilial:SAJ%
          AND SAJ.AJ_GRCOM  = P21.P21_GRCOM
          AND SAJ.AJ_USER   = %exp:cUser%
          AND SAJ.%notDel%
       WHERE
           P21.P21_FILIAL   = %xFilial:P21%
       AND P21.%notDel%
	EndSql

    While (cAliasP21)->(!Eof())
        AAdd(aGrupos, (cAliasP21)->P21_TPPRD)
        (cAliasP21)->(DbSkip())
    EndDo
    (cAliasP21)->(DbCloseArea())

	If Empty(aGrupos)
		Return ""
	EndIf

	cFiltroProd	:= "B1_GRUPO IN ( "
	For nX := 1 to Len(aGrupos)
		cFiltroProd += "'" + aGrupos[nX] + "'"
		If nX < Len(aGrupos)
			cFiltroProd += ", "
		EndIf
	Next
	cFiltroProd +=" ) "

	cFiltroProd := "@" + cFiltroProd

Return cFiltroProd