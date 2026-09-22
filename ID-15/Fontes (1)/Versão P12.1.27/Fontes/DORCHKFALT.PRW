#INCLUDE "rwmake.ch"
/*
//==========================================================================================
// Funcao para verificar as faltas no acumulado podendo ser pagas ou descontadas.
@author     A.Shibao
@since      28/11/2016
@param		
@version    P12
@return      
@project 
@client    RedeDor   
// Premissas:
// Inserir a formula no roteiro VTR APOS a fomula padrao - CALCULA FALTAS
// Inserir a formula no roteiro VRF APOS a fomula padrao - CALCULA FALTAS
// Parametrizar a tabela U10E e U10F com as verbas em formato de query ex: '123','345'
// 11/03/17 - A.Shibao - Ajuste para o acrescimo para o VR so estava fazendo para o VT.
//==========================================================================================  
*/
User Function DorChkFalt()   

Local aShArea	:= GetArea()
Local aAreaSR0:= SR0->(GetArea()) 
Local aShPeriodA:= {}
Local aShPeriodF:= {} 
Local aShPeriod := {}
Local cAliasQry	:= ""
Local cWhere	:= ""
Local cWhere1	:= ""
Local cShVrbPg  := ""
Local cShVrbDes := ""
Local nShDias	:= 0
Local nShHoras	:= 0
Local nShTotal  := 0  
Local aSHVrbDesc:= {}
Local aSHVrbPaga:= {}
Local dSDtUsad	:= ctod("//") 
Local nShTotalPg:= 0
Local nShTotalDe:= 0  
Local nFHoras   := 0
Local cTpVale   := ""  

If cRot == "VTR"
	aPergunte[6,3] := 0  
Else      
    aPergunte[5,3] := 0      
Endif
		  
// pega o periodo atual.
fGetPerAtual( @aShPeriod, , SRA->RA_PROCES , fGetRotOrdinar() )

dSDtUsad	:= aShPeriod[1,6]

// pega o periodo anterior.
//U_fShbMesAno( @dSDtUsad ) // ticket n° 5440070 - 415966 - Paulo Dias - linha comentada para não decrementar 2x

DbSelectArea( "RCH" )
DbOrderNickName("PROROTPER")
//DbSetOrder(7)



//verifica se o periodo anterior esta aberto, caso contrario pega o anterior.
If DbSeek(xFilial("RCH")+ SRA->RA_PROCES+"FOL"+AnoMes(dSDtUsad)) // // ticket n° 5440070 - 415966 - Paulo Dias - alteração na conversão da variável dSDtUsad
//	If !Empty(RCH->RCH_DTFECH) // ROGERIO CARVALHO
		U_fShbMesAno( @dSDtUsad )
//	EndIf  // ROGERIO CARVALHO
Endif   

//Tabela que armazena as verbas de faltas para descontar
fCarrTab( @aSHVrbDesc,"U10E", Nil) 

//If (nPos1:= Ascan(aSHVrbDesc, { |X| X[1] == "U10E" .And. Alltrim(X[2]) == Alltrim(SRA->RA_FILIAL) })) > 0
If (nPos1:= Ascan(aSHVrbDesc, { |X| X[1] == "U10E" })) > 0
	cShVrbDes := aSHVrbDesc[nPos1,5]
Endif 

//Tabela que armazena as verbas de faltas para pagar
fCarrTab( @aSHVrbPaga,"U10F", Nil) 

If (nPos2:= Ascan(aSHVrbPaga, { |X| X[1] == "U10F" })) > 0
	cShVrbPg:= aSHVrbPaga[nPos2,5]
Endif

If !Empty(cShVrbDes) 

		// Verbas para descontar
		cShVrbDes := Alltrim(aSHVrbDesc[nPos1,5])
		dtSIni    := dSDtUsad 
		cWhere1   := ""
		cWhere1 += " SRD.RD_FILIAL = '"	    + SRA->RA_FILIAL  + "' "
		cWhere1 += " AND SRD.RD_MAT = '" 	+ SRA->RA_MAT     + "' "
		cWhere1 += " AND SRD.RD_PROCES = '"	+ SRA->RA_PROCES  + "' "
		cWhere1 += " AND SRD.RD_PERIODO= '"	+ dtSIni          + "' "
		cWhere1 += " AND SRD.RD_ROTEIR = 'FOL'                     "
		cWhere1 += " AND SRD.RD_SEMANA = '01' "	
		cWhere1 += " AND SRD.RD_PD IN (" 	    + cShVrbDes   + ") "
		
		cWhere := "%" + cWhere1 + " AND SRD.RD_TIPO1 IN ('D','V')"
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
		nFHoras := INT((cAliasQry)->TOTALFAL / SRA->RA_HRSDIA) 

		(cAliasQry)->(DbCloseArea())
	
		nShTotalDe := nShDias + nFHoras

		nShDias    := nFHoras := 0

EndIf

If !Empty(cShVrbPg) 

		// Verbas para pagar
		cShVrbPg  := Alltrim(aSHVrbPaga[nPos2,5])
		dtSIni    := dSDtUsad 
		cWhere1   := ""		
		
		cWhere1 += " SRD.RD_FILIAL = '"	    + SRA->RA_FILIAL  + "' "
		cWhere1 += " AND SRD.RD_MAT = '" 	+ SRA->RA_MAT     + "' "
		cWhere1 += " AND SRD.RD_PROCES = '"	+ SRA->RA_PROCES  + "' "
		cWhere1 += " AND SRD.RD_PERIODO= '"	+ dtSIni          + "' "
		cWhere1 += " AND SRD.RD_ROTEIR = 'FOL'                        "
		cWhere1 += " AND SRD.RD_SEMANA = '01' "	
		cWhere1 += " AND SRD.RD_PD IN (" 	    + cShVrbPg    + ") "
		
		cWhere := "%" + cWhere1 + " AND SRD.RD_TIPO1 IN ('D','V')"
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
		nFHoras := INT((cAliasQry)->TOTALFAL / SRA->RA_HRSDIA)
		(cAliasQry)->(DbCloseArea())
	
		nShTotalPg:= nShDias + nFHoras	
		
		nShDias   := nFHoras := 0

Endif

//soma as faltas abonadas + as faltas padrao para abater do calculo
If nShTotalDe > 0   
	nFaltas := nShTotalDe
Endif 

// soma as faltas que foram abatidas indevidademente no mes anterior, nos dias do calculo.
If nShTotalPg > 0 
//+------------------------------------------------+//
//| Edsonho ® - 27/04/2017                         |//
//| Inserido o trecho, para ponterar na SR0        |//
//|    R0_TPVALE C 1                               |//
//|    0 -> Ticket Transporte                      |//
//|    1 -> Ticket Restaurante                     |//
//|    2 -> Ticket Canasta                         |//
//+------------------------------------------------+//
   cTpVale := IIf(cRot == "VTR","0","1")
   DbSelectArea("SR0")
   SR0->(DbSetOrder(3))
   If SR0->(dBSeek(SRA->RA_FILIAL+SRA->RA_MAT+cTpVale))
      // pergunte na rotina padrao "dias a deduzir" por isso eu negativo o valor para que seja somado.
      If cRot == "VTR"
      	  aPergunte[6,3] := 0
	      aPergunte[6,3]:= aPergunte[6,3]  - (nShTotalPg * SR0->R0_QDIAINF)
      Else      
      	  aPergunte[5,3] := 0      
		  aPergunte[5,3]:= aPergunte[5,3]  - (nShTotalPg * SR0->R0_QDIAINF)	
	  Endif	                             
	EndIf
Endif

RestArea(aAreaSR0) 
RestArea(aShArea)

Return ("FIM")


//==========================================================================================
/*/
/  Funcao para subtrair mes ano 
@author     A.Shibao
@since      28/11/2016
@param		
@version    P12
@return      
@project 
@client    RedeDor   
/*/
//========================================================================================== 
User Function fShbMesAno( xData )             

 Local nMes, nAno, uRet
 Local lData := If( ValType(xData)=="D",.T.,.F. )

 nMes := If( lData,Month( xData ),Val(Right( xData,2 )) )
 nAno := If( lData,Year( xData ),Val(Left( xData,4 )) )

 U_fShub1Mes( @nMes, @nAno )

 xData := StrZero(nAno,4) + StrZero(nMes,2)
 dtSIni  := ctod("01/"+StrZero(nMes,2)+"/"+StrZero(nAno,4))//substrMesAno(xData)
 dtSFim    := ctod(strzero(f_UltDia(dtSIni),2)+"/"+Strzero(Month(dtSIni),2)+"/"+right(str(Year(dtSIni)),2)) 

 
Return( dtSIni, dtSFim )	

//==========================================================================================
/*/
/  Funcao para subtrair mes  
@author     A.Shibao
@since      28/11/2016
@param		
@version    P12
@return      
@project 
@client    RedeDor   
/*/
//========================================================================================== 
User Function fShub1Mes( nMes, nAno )   


 nMes--
 If nMes == 0
    nMes := 12
    nAno--
 EndIf
 
Return   