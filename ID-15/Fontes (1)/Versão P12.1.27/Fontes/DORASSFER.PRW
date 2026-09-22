#INCLUDE "PROTHEUS.CH"
//==========================================================================================
/*/
/  Funcao para pagamento de assiduidade.
@author     A.Shibao
@since      06/12/2016
@param		
@version    P12
@return      
@project 
@client    RedeDor   
/*/
//==========================================================================================  
User Function DorAssFer() 

Local aShArea	:= GetArea()
Local cAliasQry	:= ""
Local cWhere	:= ""
Local cWhere1	:= ""
Local aSHU10H   := {}
Local dSPerIni	:= ctod("//") 
Local dSPerFim	:= ctod("//") 
Local nPos1     := 0
Local cShVrbDes := ""
Local cShVrbGrv := ""
Local nShTotal  := 0  
Local nShDias	:= 0  
Local nFHoras   := 0
Local nShFator  := 0

//Tabela que armazena a escala de calculo
//fCarrTab( @aSHU10H,"U10H", Nil) Thais Paiva
fCarrTab( @aSHU10H,"U10H", Nil,.T.)

dSPerIni:= SRF->RF_DATABAS
dSPerFim:= fcalcfimaq(dSPerIni)

If (nPos1:= Ascan(aSHU10H, { |X| X[1] == "U10H" .And. Alltrim(X[2]) == Alltrim(SRA->RA_FILIAL) .And. Alltrim(X[5]) == Alltrim(SRA->RA_SINDICA) })) > 0
		
//	If !Empty(aSHU10H[nPos1,6])	.And. !Empty(aSHU10H[nPos1,7])
		
		// verbas para fazer a busca
		cShVrbDes := Alltrim(aSHU10H[nPos1,8])
		// verba que sera gerada nas ferias
		cShVrbGrv := Alltrim(aSHU10H[nPos1,9])
        
		cSPerIni  := Anomes(dSPerIni)
		cSPerFim  := Anomes(dSPerFim)
		
		cWhere1   := ""
		
		cWhere1 += " SRD.RD_FILIAL = '"	    + SRA->RA_FILIAL  + "' "
		cWhere1 += " AND SRD.RD_MAT = '" 	+ SRA->RA_MAT     + "' "
		cWhere1 += " AND SRD.RD_PROCES = '"	+ SRA->RA_PROCES  + "' "
		cWhere1 += " AND SRD.RD_PERIODO> = '"	+ cSPerIni    + "' "
		cWhere1 += " AND SRD.RD_PERIODO< = '"	+ cSPerFim    + "' "		
		cWhere1 += " AND SRD.RD_ROTEIR = 'FOL'                     "
		cWhere1 += " AND SRD.RD_SEMANA = '01' "	
		cWhere1 += " AND SRD.RD_PD IN (" 	    + cShVrbDes   + ") "
		
		cWhere := "%" + cWhere1 + " AND SRD.RD_TIPO1 = 'D'"
		cWhere += "%"
	
		cAliasQry:= GetNextAlias() //"QSRD" Thais Paiva - 10098042
		BeginSql alias cAliasQry
			SELECT SUM(RD_HORAS) TOTALFAL
			FROM %table:SRD% SRD
			WHERE 		%exp:cWhere% AND
	 	    SRD.%notDel%   
		EndSql
		nShDias := (cAliasQry)->TOTALFAL
		(cAliasQry)->(DbCloseArea())
	
	
		cWhere := "%" + cWhere1 + " AND SRD.RD_TIPO1 = 'H'"
		cWhere += "%"
		cAliasQry:= GetNextAlias() //"QSRD" Thais Paiva - 10098042
		BeginSql alias cAliasQry
			SELECT SUM(RD_HORAS) TOTALFAL
			FROM %table:SRD% SRD
			WHERE 		%exp:cWhere% AND
	 	    SRD.%notDel%   
		EndSql
		nFHoras := Round((cAliasQry)->TOTALFAL / SRA->RA_HRSDIA,0) 
		(cAliasQry)->(DbCloseArea())
	
		nShTotal := nShDias + nFHoras
        
//	Endif
    
	// percorro a tabela para verificar se tem direito 
	//If nShTotal > 0  
		
		For nSh:= nPos1 to Len(aSHU10H)
 		    //If nShTotal <= aSHU10H[nSh,6] .And. aSHU10H[nSh,5] == SRA->RA_SINDICA Thais Paiva
			If nShTotal == aSHU10H[nSh,6] .And. Alltrim(aSHU10H[nSh,5]) == Alltrim(SRA->RA_SINDICA) .And. Alltrim(aSHU10H[nSh,2]) == Alltrim(SRA->RA_FILIAL)
		       nShFator:= aSHU10H[nSh,7]
		       nSh     := Len(aSHU10H)	
		       nAssid := Round(nShFator * (SRA->RA_SALARIO / 30) , MsDecimais(1))
	           fGeraVerba(aSHU10H[nSh,9],nAssid,,,,,,,,,.T.) 
		    Endif
   		Next
	
	//Endif
/*	   // filial em branco, buscando somente o sindicato
ElseIf (nPos1:= Ascan(aSHU10H, { |X| X[1] == "U10H" .And. Alltrim(X[2]) == Alltrim(SRA->RA_SINDICA) })) > 0
	
			// verbas para fazer a busca
		cShVrbDes := Alltrim(aSHU10H[nPos1,8])
		// verba que sera gerada nas ferias
		cShVrbGrv := Alltrim(aSHU10H[nPos1,9])
        
		cSPerIni  := Anomes(dSPerIni)
		cSPerFim  := Anomes(dSPerFim)
		
		cWhere1   := ""
		
		cWhere1 += " SRD.RD_FILIAL = '"	    + SRA->RA_FILIAL  + "' "
		cWhere1 += " AND SRD.RD_MAT = '" 	+ SRA->RA_MAT     + "' "
		cWhere1 += " AND SRD.RD_PROCES = '"	+ SRA->RA_PROCES  + "' "
		cWhere1 += " AND SRD.RD_PERIODO> = '"	+ cSPerIni    + "' "
		cWhere1 += " AND SRD.RD_PERIODO< = '"	+ cSPerFim    + "' "		
		cWhere1 += " AND SRD.RD_ROTEIR = 'FOL'                     "
		cWhere1 += " AND SRD.RD_SEMANA = '01' "	
		cWhere1 += " AND SRD.RD_PD IN (" 	    + cShVrbDes   + ") "
		
		cWhere := "%" + cWhere1 + " AND SRD.RD_TIPO1 = 'D'"
		cWhere += "%"
	
		cAliasQry:= "QSRD"
		BeginSql alias cAliasQry
			SELECT SUM(RD_HORAS) TOTALFAL
			FROM %table:SRD% SRD
			WHERE 		%exp:cWhere% AND
	 	    SRD.%notDel%   
		EndSql
		nShDias := (cAliasQry)->TOTALFAL
		(cAliasQry)->(DbCloseArea())
	
	
		cWhere := "%" + cWhere1 + " AND SRD.RD_TIPO1 = 'H'"
		cWhere += "%"
		cAliasQry:= "QSRD"
		BeginSql alias cAliasQry
			SELECT SUM(RD_HORAS) TOTALFAL
			FROM %table:SRD% SRD
			WHERE 		%exp:cWhere% AND
	 	    SRD.%notDel%   
		EndSql
		nFHoras := Round((cAliasQry)->TOTALFAL / SRA->RA_HRSDIA,0) 
		(cAliasQry)->(DbCloseArea())
	
		nShTotal := nShDias + nFHoras
        
//	Endif
    
	// percorro a tabela para verificar se tem direito 
	//If nShTotal > 0  
		
		For nSh:= nPos1 to Len(aSHU10H)
 		    If nShTotal <= aSHU10H[nSh,6]
		       nShFator:= aSHU10H[nSh,7]
		       nSh     := Len(aSHU10H)	
		       nAssid := Round(nShFator * (SRA->RA_SALARIO / 30) , MsDecimais(1))
	           fGeraVerba(aSHU10H[nSh,9],nAssid,,,,,,,,,.T.) 
		    Endif
   		Next
	
	//Endif
*/
Endif

RestArea(aShArea)

Return ("FIM")
