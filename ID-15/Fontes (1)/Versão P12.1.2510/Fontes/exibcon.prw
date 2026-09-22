//#INCLUDE "PROTHEUS.CH"
#INCLUDE "rwmake.ch"
#INCLUDE "TopConn.ch"
/*
|----------------------------------------------------------------------------|
|Programa  |BCOSIM  |Autor  |Marcus Peçanha	      | Data |  08/03/2018       |
|----------------------------------------------------------------------------|
|Descrição |Informa se Existe banco do conhecimento no Documento de Entrada  |						  
|----------------------------------------------------------------------------|
|Uso       |REDEDOR                                                          |						  
|----------------------------------------------------------------------------|
*/
User Function EXIBCON()

	Local cQuery := ""
	Local cRet	 := " "
	Local aArea  := GetArea()

	cQuery := " SELECT P09_CODDOC FROM "+ RetSqlName("P09") 
	cQuery += " WHERE D_E_L_E_T_ = ' ' " 
	cQuery += " AND P09_FILIAL = '" + F1_FILIAL + "' " 
	cQuery += " AND P09_CODORI = '" + F1_DOC + F1_SERIE + F1_FORNECE + F1_LOJA + "'" 

   If select("Arq") > 0
   	ARQ->(Dbclosearea()) 
   EndIf

	TCQUERY cQuery NEW ALIAS "Arq" 
	
	If !ARQ->(Eof())
		cRet := "Sim"
	EndIf
	
	RestArea(aArea)
Return cRet