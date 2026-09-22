#Include 'Protheus.ch'

/*/{Protheus.doc} F0500208
Função do F3 do RH3 para o relatório
@author Fernando Carvalho
@since 14/12/2016
@version 1.0
@project MAN0000007423039_EF_002
@param nMomento, numerico, Momento de acionamento
/*/
User Function F0500208(nMomento)
	Local cSeeFil		:= ""
	Local cSeeCod		:= ""
	Local cQuery 		:= ""
	Local cAliasRH3	:= GetNextAlias()	
	Local oDlg 
	Local aBrowse		:= {}
  	Local oBrowse	
	Local lRet			:= .F.	
	
   	cQuery	+= " SELECT RH3.RH3_FILIAL,RH3.RH3_CODIGO,RH3.RH3_XTPCTM, PA7.PA7_DESCR "
   	cQuery	+= " FROM "+RETSQLNAME("RH3")+" RH3 "
	cQuery	+= " INNER JOIN "+RETSQLNAME("PA7")+" PA7 "
	cQuery	+= " ON PA7.PA7_CODIGO = RH3.RH3_XTPCTM "
	cQuery	+= " AND PA7.D_E_L_E_T_ ='' "
	cQuery	+= " WHERE RH3.D_E_L_E_T_='' "
	cQuery	+= " ORDER BY RH3.RH3_FILIAL,RH3.RH3_CODIGO "
	
	 
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasRH3,.T.,.T.)
	
	While (cAliasRH3)->(!EOF())
		aAdd(aBrowse,  {(cAliasRH3)->(RH3_FILIAL),(cAliasRH3)->(RH3_CODIGO),(cAliasRH3)->(PA7_DESCR)})
		(cAliasRH3)->(Dbskip())
	EndDo
  
   
   DEFINE DIALOG oDlg TITLE "Consulta RH3" FROM 180,180 TO 550,700 PIXEL     	
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
		dbSelectArea("RH3")
		RH3->(dbSetOrder(1))
		RH3->(dbSeek(cSeeFil + cSeeCod))
	EndIf	
Return lRet

Static Function OK(oBrowse,aBrowse,cSeeFil ,cSeeCod)
	cSeeFil	:= aBrowse[oBrowse:nAt,01]
    cSeeCod	:= aBrowse[oBrowse:nAt,02]
Return
