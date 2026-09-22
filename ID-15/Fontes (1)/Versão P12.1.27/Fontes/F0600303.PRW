#Include 'Protheus.ch'

/*/{Protheus.doc} F0600303

@type function
@author alexandre.arume
@since 11/11/2016
@version 1.0
@param aParam, array, conjunto dos parâmetros 
@return ${return}, ${return_description}
@project	MAN0000007423040_EF_003

/*/
User Function F0600303(aParam)

	Local cDbms   := GetMv("FS_DBMS")   // Gerenciador do Banco de Dados (MSSQL,ORACLE...)
	Local cDTBASE := GetMv("FS_DTBASE") // Nome do Banco de Dados
	Local cPORT   := GetMv("FS_PORT")   // Porta do Banco de Dados
	Local cSERVER := GetMv("FS_SERVER") // Caminho do servidor.
	Local cSql    := ""
	Local nHnd1   := 0
	Local nStatus := 0
	
	If aParam[1] == 4
		cSql += "UPDATE EF06003 "
		cSql += "SET    EF06003_TURNO = '" + M->RA_TNOTRAB + "' "
		cSql += "WHERE  EF06003_FILIAL = '" + SRA->RA_FILIAL + "' "
		cSql += "       AND EF06003_MATRICULA = '" + SRA->RA_MAT + "' "
		If !(EMPTY(cDbms)) .AND. !(EMPTY(cDTBASE)).AND. !(EMPTY(cSERVER)) .AND. !(EMPTY(cPORT))
			nHnd1 := TCLink(cDbms + "/" + cDTBASE,cSERVER,VAL(cPORT))
	
			nStatus := TCSqlExec(cSql)
   
			If (nStatus < 0)
				conout("TCSQLError() " + TCSQLError())
			EndIf
   
			TCUnlink(nHnd1)
		EndIf
	EndIf
Return