#INCLUDE "PROTHEUS.CH"
//==========================================================================================
/*/
/  Funcao para somar o salario familia na pensao.
@author     A.Shibao
@since      14/11/16
@param		
@version    P12
@return      
@project 
@client    RedeDor   
/05.05.17 -> Ajuste para aglutinar os valores qdo um beneficiario possui varios dependentes
/
//==========================================================================================*/
User Function DorPensSF()   

Local cSHVrbDep  := "" 
Local cSHOrdem   := "" 
Private cFindVrb := "" 
Private cShSeq   := ""
Private cShVrb   := ""

// verifico se tem pensao que deve ser somado o salario familia
If !Empty(M_XVRBPENS)

	     //For nShCont := 1 to len(ALLTRIM(M_XVRBPENS))
			     cShVrbP := Alltrim(M_XVRBPENS)                               
				 For nTp := 1 to Len(cShVrbP) Step 4
					cFindVrb := SubStr(cShVrbP, nTp, 3)
				    If !Empty(cFindVrb) .And. abs(fBuscaPd(cFindVrb)) > 0 .And. Len(cFindVrb) == 3
				        // busco a ordem do beneficiario conforme a verba gerada no movimento.
						cSHOrdem := fBuscaBN(@cShSeq,@cFindVrb)
						// busco a verba do dependente onde está vinculado o beneficiario.
						//cSHVrbDep:= fBuscaDP(@cShVrb,@cSHOrdem)                  
						// ajustado para gerar corretamente qdo um beneficiario tem mais de um dependente 05.05.17
						fBuscaDP(@cShVrb,@cSHOrdem)                  						
						// busco a verba de base do salario familia para ser somada a verba de pensao e nao estiver informada.
						//If fBuscaPD(cSHVrbDep) > 0 .And. !(( Ascan(aPd,{|X| X[1] == cSHVrbDep .And. X[9] <> "D" .And. X[7] == "I"}) > 0 ) )
						//	nShBsFam := fBuscaPD(cSHVrbDep)
			       	    // 	fGeraVerba(cFindVrb,abs(fBuscaPD(cFindVrb)) + nShBsFam,,,,,,,,,.T.)  
						//Endif						
						
						//If (nTp + 4) < Len(cShVrbP)
			   			//	nTp:= nTp + 3
						//EndIf

						cShSeq   := cSHOrdem:= cSHVrbDep:= cShVrb:= "" 
						nShBsFam := 0
													
				    Endif
				 Next nTp   
	         //Endif 
		 //Next nShCont  

Endif
Return 

//==========================================================================================
/*/
/  Funcao para buscar o beneficiario conforme a verba gerada
@author     A.Shibao
@since      14/11/16
@param		
@version    P12
@return      
@project 
@client    RedeDor   
/*/
//==========================================================================================  
Static Function fBuscaBN(cShSeq,cFindVrb)  

Local cQuery    := ""

cQuery := " SELECT RQ_ORDEM AS ORDEMBENEF "
cQuery += "  FROM "+ RetSqlName("SRQ")  
cQuery += "  WHERE RQ_FILIAL = '" + SRA->RA_FILIAL +"' "
cQuery += "  AND   RQ_MAT = '" + SRA->RA_MAT +"' "
cQuery += "  AND   RQ_VERBFOL = '" + cFindVrb +"' "
cQuery += "  AND   D_E_L_E_T_= ' '  "         

//Verifica Tabela Aberta
If Select("DORSRQ") > 0
	DbSelectArea("DORSRQ")
	DbCloseArea("DORSRQ")
Endif

DbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery), "DORSRQ", .T., .F.)

DbSelectArea("DORSRQ")
DORSRQ->(DbGoTop()) 
            
While (DORSRQ->(! EOF()))
	
		cShSeq := DORSRQ->ORDEMBENEF
		
		DORSRQ->(dbSkip())					
Enddo 

Return(cShSeq)


//==========================================================================================
/*/
/  Funcao para buscar o dependente conforme o vinculo 
@author     A.Shibao
@since      14/11/16
@param		
@version    P12
@return      
@project 
@client    RedeDor   
/*/
//==========================================================================================  
Static Function fBuscaDP(cShVrb,cSHOrdem)

Local cQuery    := ""  
Local nSHHCon   := 0

cQuery := " SELECT RB_XVERBAP AS VRBPENNSAO "
cQuery += "  FROM "+ RetSqlName("SRB")  
cQuery += "  WHERE RB_FILIAL = '" + SRA->RA_FILIAL + "' "
cQuery += "  AND   RB_MAT = '" + SRA->RA_MAT + "' "
cQuery += "  AND   RB_XPENSAO = '" + cSHOrdem + "' "
cQuery += "  AND   D_E_L_E_T_= ' '  "         

//Verifica Tabela Aberta
If Select("DORSRB") > 0
	DbSelectArea("DORSRB")
	DbCloseArea("DORSRB")
Endif

DbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery), "DORSRB", .T., .F.)

DbSelectArea("DORSRB")
DORSRB->(DbGoTop()) 

//conta qtos dependentes tem para o mesmo beneficiario.       
While (DORSRB->(! EOF()))
	
//		cShVrb := DORSRB->VRBPENNSAO
		nSHHCon+= 1
		DORSRB->(dbSkip())					
Enddo 
                   
DORSRB->(DbGoTop()) 
If nSHHCon == 1                                                                                                    
	If fBuscaPD(DORSRB->VRBPENNSAO) > 0 .And. !(( Ascan(aPd,{|X| X[1] == DORSRB->VRBPENNSAO .And. X[9] <> "D" .And. X[7] == "I"}) > 0 ) )
		nShBsFam := fBuscaPD(DORSRB->VRBPENNSAO)
	   	fGeraVerba(cFindVrb,abs(fBuscaPD(cFindVrb)) + nShBsFam,,,,,,,,,.T.)  
	Endif   	

ElseIf nSHHCon > 1                                                                                                  
	While (DORSRB->(! EOF()))   
		cSHVrbDep := DORSRB->VRBPENNSAO
		If fBuscaPD(cSHVrbDep) > 0 .And. !(( Ascan(aPd,{|X| X[1] == cSHVrbDep .And. X[9] <> "D" .And. X[7] == "I"}) > 0 ) )
			nShBsFam := fBuscaPD(cSHVrbDep)
   			fGeraVerba(cFindVrb,abs(fBuscaPD(cFindVrb)) + nShBsFam,,,,,,,,,.T.)  
		Endif						
	DORSRB->(dbSkip())		
	Enddo 
Endif
	
Return()