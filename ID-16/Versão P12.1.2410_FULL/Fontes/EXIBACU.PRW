#INCLUDE "PROTHEUS.CH"
#INCLUDE "rwmake.ch"
#INCLUDE "TopConn.ch"

user function EXIBACU()
	Local cQuery 	:= ""
	Local cDesc		:= ""
		
	cQuery := " SELECT ACU_DESC FROM "+RetSqlName("ACV")+" ACV "
	cQuery += " INNER JOIN "+RetSqlName("ACU")+" ACU " 
	cQuery += " ON ACU.ACU_FILIAL = ACV_FILIAL "
	cQuery += " AND ACU.ACU_COD = ACV_CATEGO " 
	cQuery += " AND ACU.D_E_L_E_T_ = ' ' " 
	cQuery += " WHERE ACV.D_E_L_E_T_ = ' ' " 
	cQuery += " AND ACV.ACV_CODPRO = '" + SBZ->BZ_COD + "'" 
	
   If select("TRAB") > 0
   	TRAB->(Dbclosearea()) 
   EndIf

	TCQUERY cQuery NEW ALIAS "TRAB" 
	
	If !TRAB->(Eof())
		cDesc := TRAB->ACU_DESC
	EndIf

Return cDesc