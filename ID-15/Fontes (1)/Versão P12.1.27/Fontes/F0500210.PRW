#Include 'Protheus.ch'

/*
{Protheus.doc} F0500210()
Busca solicitaçãoes da PA7
@Author     Henrique Madureira
@Since      26/05/2017
@Version    P12.7
@Project    MAN00000462901_EF_002
@Return	 Nil
*/
User Function F0500210()

	Local cSeeFil		:= ""
	Local cSeeCod		:= ""
	Local cQuery 		:= ""
	Local cAliasPa5	:= GetNextAlias()	
	Local oDlg 
	Local aBrowse		:= {}
  	Local oBrowse	
	Local lRet			:= .F.	
	
   	cQuery	+= " SELECT DISTINCT PA7_FILIAL, PA7_CODIGO, PA7_DESCR FROM " + RETSQLNAME("PA7") + " WHERE D_E_L_E_T_ = ' ' "	
	 
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasPa5,.T.,.T.)
	
	While (cAliasPa5)->(!EOF())
		aAdd(aBrowse,  {(cAliasPa5)->(PA7_FILIAL),(cAliasPa5)->(PA7_CODIGO),(cAliasPa5)->(PA7_DESCR)})
		(cAliasPa5)->(Dbskip())
	EndDo
  
   
   DEFINE DIALOG oDlg TITLE "Tipo de solicitação" FROM 180,180 TO 550,700 PIXEL     	
		oBrowse := TcBrowse():New( 01 , 01, 260, 156,,{'Filial','Codigo','Descrição'},{20,30,50},oDlg,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )
		oBrowse:SetArray(aBrowse)
		oBrowse:bLine := {||{ 	aBrowse[oBrowse:nAt,01],;
                        			aBrowse[oBrowse:nAt,02],;
                        			aBrowse[oBrowse:nAt,03]}}
                               //	aBrowse[oBrowse:nAt,04]}}
                               	
       TButton():New( 160, 082, "OK"		, oDlg,{||OK(oBrowse,aBrowse,@cSeeFil ,@cSeeCod),oDlg:End(), lRet := .T. },40,010,,,.F.,.T.,.F.,,.F.,,,.F. )
		TButton():New( 160, 202, "Sair"		, oDlg,{||lRet := .f.,oDlg:End() },40,010,,,.F.,.T.,.F.,,.F.,,,.F. )		
	ACTIVATE DIALOG oDlg CENTERED 
	If lRet
		dbSelectArea("PA7")
		PA7->(dbSetOrder(1))
		PA7->(dbSeek(cSeeFil + cSeeCod))
	EndIf	
Return lRet

Static Function OK(oBrowse,aBrowse,cSeeFil ,cSeeCod)
	cSeeFil	:= aBrowse[oBrowse:nAt,01]
    cSeeCod	:= aBrowse[oBrowse:nAt,02]
Return
