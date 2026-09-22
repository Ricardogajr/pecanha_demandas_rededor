#INCLUDE "PROTHEUS.CH"
/*/==========================================================================================
/  Rotina para calculo do adicional por tempo de servico trienio + bienio
@author     A.Shibao
@since      29/08/16
@param		
@version    P12
@return      
@project 
@client    RedeDor   
/*/
//11/05/17 - A.shibao -> Ajuste para tratar as verbas no roteiro FER.
//==========================================================================================  
User Function DorAdts()

Local aSHAdts	:= {}
Local nPosTabAdt:= 0 
Local nTabAdts  := 0 
Local nShBsAdt  := 0
Local nSHTrie   := 0   
Local nSHBien   := 0
Local nShFimTri := 0 
Local nShFimBie := 0
Local lRegrava  := .F.
Local lRegravaB := .F.
Local nShAcum   := 0   // trienio
Local nShAcum2  := 0   // bienio
//ferias
Local nShAtsMes := 0  
Local nShAtsSeg := 0  
Local nAtsSSVM  := 0  
Local nAtsSSVSeg:= 0  
Local nAtsAboM  := 0  
Local nAtsAboMSe:= 0  
Local nAtsAboVrM:= 0
Local nAtsAboVrS:= 0  
// 13
Local nAts13Mes := 0  
Local nAts13MSV := 0  
Local cSindica  := "" 

Local nSindiB   := 0
Local nSindiT   := 0
Local nCarTri   := CAR_TRI  // variavel private do sistema 
Local nCarBie   := CAR_BIE  // variavel private do sistema    
If Right(SRA->RA_ADTPOSE,1) == "T"		

	//Carrega tabela especifica com filiais e sindicatos 
	fCarrTab( @aSHAdts,"U104", Nil,.T.) 

	// Verifico se existe registros na tabela U014 e se recebe trienio.	   
	If ( nPosTabAdt := Ascan(aSHAdts,{ |x| x[1] == "U104" .And. Alltrim(X[2]) == Alltrim(SRA->RA_FILIAL) .And.  Alltrim(SRA->RA_SINDICA) $ Alltrim(X[5])}))  > 0 
	
		cSindica:= alltrim(substr(aSHAdts[nPosTabAdt, 5],1,len(aSHAdts[nPosTabAdt, 5])))
	
		If SRA->RA_SINDICA $ cSindica
		
		    // Verifico se existe as verba criadas
		    If !(SRV->(dbSeek(xFilial("SRV")+aCodFol[2,1])))
			   Alert("Nao encontrada a verba de bienio cadastrada, favor verificar")
			   Return                          '
			Endif
			
			If !(SRV->(dbSeek(xFilial("SRV")+aCodFol[3,1])))
			   Alert("Nao encontrada a verba de trienio cadastrada, favor verificar")
			   Return		   
			Endif
            
			// Ferias 
			If 	CTIPOROT == "3"
				If !(SRV->(dbSeek(xFilial("SRV")+aCodFol[1296,1]))) // ATS FERIAS MES
				   Alert("Nao encontrada a verba de ATS - Ferias ID 1296 não esta cadastrada, favor verificar")
				   Return		   
				Endif   
			   If !(SRV->(dbSeek(xFilial("SRV")+aCodFol[1297,1]))) // ATS FERIAS MES SEGUINTE
				   Alert("Nao encontrada a verba de ATS - Ferias ID 1297 não esta cadastrada, favor verificar")
				   Return		   
			   Endif           
			   If !(SRV->(dbSeek(xFilial("SRV")+aCodFol[1298,1]))) // ATS FERIAS MES SOBRE VERBAS
				   Alert("Nao encontrada a verba de ATS - Ferias ID 1298 não esta cadastrada, favor verificar")
				   Return		   
			   Endif 
			   If !(SRV->(dbSeek(xFilial("SRV")+aCodFol[1299,1])))// ATS FERIAS MES SEGUINTE SOBRE VERBAS
				   Alert("Nao encontrada a verba de ATS - Ferias ID 1299 não esta cadastrada, favor verificar")
				   Return		   
			   Endif   
  			   If !(SRV->(dbSeek(xFilial("SRV")+aCodFol[1312,1]))) // ATS ABONO MES
				   Alert("Nao encontrada a verba de ATS - Ferias ID 1312 não esta cadastrada, favor verificar")
				   Return		   
			   Endif   			     			   
			   If !(SRV->(dbSeek(xFilial("SRV")+aCodFol[1313,1]))) // ATS ABONO MES SEGUINTE
				   Alert("Nao encontrada a verba de ATS - Ferias ID 1313 não esta cadastrada, favor verificar")
				   Return		   
			   Endif   
			   If !(SRV->(dbSeek(xFilial("SRV")+aCodFol[1314,1]))) // ATS ABONO MES SOBRE VERBAS
				   Alert("Nao encontrada a verba de ATS - Ferias ID 1314 não esta cadastrada, favor verificar")
				   Return		   
			   Endif 
			   If !(SRV->(dbSeek(xFilial("SRV")+aCodFol[1315,1]))) // ATS ABONO MES SEGUINTE SOBRE VERBAS
				   Alert("Nao encontrada a verba de ATS - Ferias ID 1315 não esta cadastrada, favor verificar")
				   Return		   
			   Endif   				     			   			   
			Endif
			
			// 131/132 
			If 	CTIPOROT $ "5/6"
				If !(SRV->(dbSeek(xFilial("SRV")+aCodFol[1288,1]))) // ATS 13º MES
				   Alert("Nao encontrada a verba de ATS - 13º ID 1288 não esta cadastrada, favor verificar")
				   Return		   
				Endif   
			   If !(SRV->(dbSeek(xFilial("SRV")+aCodFol[1289,1]))) // ATS 13º MES SOBRE VERBAS
				   Alert("Nao encontrada a verba de ATS - 13º ID 1289 não esta cadastrada, favor verificar")
				   Return		   
			   Endif 			   
			Endif
			
			
			// datas usadas no calculo
			dShDtFim:= If(!Empty(SRA->RA_DEMISSA) .and.(SRA->RA_DEMISSA<dDataAte),SRA->RA_DEMISSA,dDataAte)
			dShDtIni:= SRA->RA_ADMISSAO
	        nSHTrie := nSHBien := SRA->RA_SALARIO
	
			// tempo de empresa		
			TimeHouse := Year(dShDtFim) - ( Year(dShDtIni) + CAR_TRI )
			If Month(dShDtIni) > Month(dShDtFim)
				TimeHouse --
			EndIf		
	        
			//trienio
			If TimeHouse > 0
			    If 	nShAcum:= Int(TimeHouse/3)  >= 15
				    nShAcum:= 15              
				    lRegrava:= .T.		                     				    
				Else
				    nShAcum:= Int(TimeHouse/3)  
				    lRegrava:= .T.		                     				
				Endif    
			Endif
			
	        //bienio
			If TimeHouse >= 17  .And. TimeHouse < 19
			    If 	nShAcum2:= Int(TimeHouse/3)  >= 15
				    nShAcum2:= 15              
				    lRegravab:= .T.		                     				    
				Else
				    nShAcum2:= Int(TimeHouse/3)  
				    lRegravab:= .T.		                     				
				Endif    		    
			Endif   
			
			// parametros no sindicato do trienio
			If lRegrava
				If RCE->RCE_TPCATS == "1"
				   nSindiT:= RCE->RCE_PERTR/100
				Elseif RCE->RCE_TPCATS == "2"
				   nSindiT:= Iif(Empty(RCE->RCE_PERTR), RCE->RCE_VLRTR, RCE->RCE_PERTR / 100 )
				Else
				   nSindiT:= RCE->RCE_VLRTR
				Endif   				   
			Endif

			// parametros no sindicato do bienio
			If lRegravaB			
				If RCE->RCE_TPCATS == "1"
				   nSindiB:= RCE->RCE_PERBI/100
				Elseif RCE->RCE_TPCATS == "2"
				   nSindiB:= Iif(Empty(RCE->RCE_PERBI), RCE->RCE_VLRBI, RCE->RCE_PERBI / 100 )
				Else
				   nSindiB:= RCE->RCE_VLRBI
				Endif   
			EndIf	   
	
			// Ferias 
			If 	CTIPOROT == "3"

			  If cBCalATS == "1"
				   	
				   	 // verifico se precisa recalcular e nao esta informada, deleto a verba caso exista. 			  
				   	 If lRegrava .And. ! (( Ascan(aPd,{|X| X[1] == aCodFol[1296,1].And. X[9] <> "D" .And. X[7] == "I"}) > 0 ) )
				   	    //guardo a referencia da verba de ats mes
				   	 	nShAtsMes:= fBuscaPD(aCodFol[1296,1],"D")
				   	    If fBuscaPD(aCodFol[1296,1]) > 0 
					   	    FdelPD(aCodFol[1296,1]) 
					   	Endif    
				   	    nShFimTri:= Round((( nSHTrie * nShAcum ) * nSindiT) / 30 * nShAtsMes, 2)
				   	    // somo o bienio junto com o trienio.
						If lRegravaB
					   	    nShFimBie:= Round((( nSHBien * nShAcum2 ) * nSindiB) / 30 * nShAtsMes, 2)						   	    					   	    					   	         
				    	    fGeraVerba(aCodFol[1296,1],nShFimTri + nShFimBie,nShAtsMes,,,,,,,,.T.)  				   	    							
						Else					   	    
				    	    fGeraVerba(aCodFol[1296,1],nShFimTri,nShAtsMes,,,,,,,,.T.)  				   	    
				    	Endif    
				
					 Endif                                                                                            
				   	 
				   	 // verifico se precisa recalcular e nao esta informada, deleto a verba caso exista. 			  					 
				   	 If lRegrava .And. ! (( Ascan(aPd,{|X| X[1] == aCodFol[1297,1].And. X[9] <> "D" .And. X[7] == "I"}) > 0 ) )
				   	    //guardo a referencia da verba de ats mes seguinte
				   	 	nShAtsSeg:= fBuscaPD(aCodFol[1297,1],"D")
				   	    If fBuscaPD(aCodFol[1297,1]) > 0 
					   	    FdelPD(aCodFol[1297,1])
					   	Endif    
				   	    nShFimTri:= Round((( nSHTrie * nShAcum ) * nSindiT) / 30 * nShAtsSeg, 2) 
				   	    // somo o bienio junto com o trienio.					   	    					   	    
				   	    If lRegravaB
					   	    nShFimBie:= Round((( nSHBien * nShAcum2 ) * nSindiB)/ 30 * nShAtsSeg, 2)						   	    					   	    					   	         
				    	    fGeraVerba(aCodFol[1297,1],nShFimTri + nShFimBie,nShAtsSeg,,,,,,,,.T.)  								   	    
				   	    Else
				    	    fGeraVerba(aCodFol[1297,1],nShFimTri,nShAtsSeg,,,,,,,,.T.)  			
					   	Endif    
					   	
					 Endif 	       
					 
				   	 // verifico se precisa recalcular e nao esta informada, deleto a verba caso exista. 			  					 					 
				   	 If lRegrava .And. ! (( Ascan(aPd,{|X| X[1] == aCodFol[1312,1].And. X[9] <> "D" .And. X[7] == "I"}) > 0 ) )
				   	    //guardo a referencia da verba de ats abono mes
				   	 	nAtsAboM:= fBuscaPD(aCodFol[1312,1],"D")
				   	    If fBuscaPD(aCodFol[1312,1]) > 0 
					   	    FdelPD(aCodFol[1312,1])
					   	Endif    
				   	    nShFimTri:= Round((( nSHTrie * nShAcum ) * nSindiT) / 30 * nAtsAboM, 2)
				   	    // somo o bienio junto com o trienio.					   	    
				   	    If lRegravaB  
					   	    nShFimBie:= Round((( nSHBien * nShAcum2 ) * nSindiB) / 30 * nAtsAboM, 2)						   	    					   	    					   	         
				    	    fGeraVerba(aCodFol[1312,1],nShFimTri + nShFimBie,nAtsAboM,,,,,,,,.T.)  								   	    
				   	    Else
				    	    fGeraVerba(aCodFol[1312,1],nShFimTri,nAtsAboM,,,,,,,,.T.)  			
				    	Endif    
					   	
					 Endif    
					 
				   	 // verifico se precisa recalcular e nao esta informada, deleto a verba caso exista. 			  					 					 
				   	 If lRegrava .And. ! (( Ascan(aPd,{|X| X[1] == aCodFol[1313,1].And. X[9] <> "D" .And. X[7] == "I"}) > 0 ) )
				   	    //guardo a referencia da verba de ats abono mes seguinte
				   	 	nAtsAboMSe:= fBuscaPD(aCodFol[1313,1],"D")
				   	    If fBuscaPD(aCodFol[1313,1]) > 0 
					   	    FdelPD(aCodFol[1313,1])
					   	Endif    
				   	    nShFimTri:= Round((( nSHTrie * nShAcum ) * nSindiT) / 30 * nAtsAboMSe, 2)
				   	    // somo o bienio junto com o trienio.					   	    					   	    
				   	    If lRegravaB                                                            
					   	    nShFimBie:= Round((( nSHBien * nShAcum2 ) * nSindiB) / 30 * nAtsAboMSe, 2)						   	    					   	    
				    	    fGeraVerba(aCodFol[1313,1],nShFimTri + nShFimBie,nAtsAboMSe,,,,,,,,.T.)  								   	    
				   	    Else
				    	    fGeraVerba(aCodFol[1313,1],nShFimTri,nAtsAboMSe,,,,,,,,.T.)  			
				    	Endif    
					   	
					 Endif	  
					 
	 		    	 // caso o sindicato do funcionario esteja na tabela especifica e nao tem tempo para o adts, apago o gerado pelo padrao do sistema.
		    	     If !(lRegrava) 
		    	        FdelPD(aCodFol[1296,1]) 
		    	        FdelPD(aCodFol[1297,1])
			   	    	FdelPD(aCodFol[1312,1])
			   	    	FdelPD(aCodFol[1313,1])
			    	 Endif 						 
			  
			  Endif 
			  
			  If cBCalATS == "2"	                                                                                                 
			  
				   	 // verifico se precisa recalcular e nao esta informada, deleto a verba caso exista. 			  					 			  
				   	 If lRegrava .And. ! (( Ascan(aPd,{|X| X[1] == aCodFol[1298,1].And. X[9] <> "D" .And. X[7] == "I"}) > 0 ) )
				   	    //guardo a referencia da verba de ats mes sobre verbas
				   	 	nAtsSSVM:= fBuscaPD(aCodFol[1298,1],"D")
				   	    If fBuscaPD(aCodFol[1298,1]) > 0 
					   	    FdelPD(aCodFol[1298,1])
					   	Endif    
				   	    nShFimTri:= Round((( nSHTrie * nShAcum ) * nSindiT) / 30 * nAtsSSVM, 2)
				   	    // somo o bienio junto com o trienio.					   	    
						If lRegravaB            
					   	    nShFimBie:= Round((( nSHBien * nShAcum2 ) * nSindiB) / 30 * nAtsSSVM, 2)						   	    
				    	    fGeraVerba(aCodFol[1298,1],nShFimTri + nShFimBie,nAtsSSVM,,,,,,,,.T.)  			
						Else					   	    
				    	    fGeraVerba(aCodFol[1298,1],nShFimTri,nAtsSSVM,,,,,,,,.T.)  			
					   	Endif    
					   	
					 Endif  

				   	 // verifico se precisa recalcular e nao esta informada, deleto a verba caso exista. 			  					 					 
				   	 If lRegrava .And. ! (( Ascan(aPd,{|X| X[1] == aCodFol[1299,1].And. X[9] <> "D" .And. X[7] == "I"}) > 0 ) )
				   	    //guardo a referencia da verba de ats mes sobre verbas
				   	 	nAtsSSVSeg:= fBuscaPD(aCodFol[1299,1],"D")
				   	    If fBuscaPD(aCodFol[1299,1]) > 0 
					   	    FdelPD(aCodFol[1299,1])
					   	Endif    
				   	    nShFimTri:= Round((( nSHTrie * nShAcum ) * nSindiT) / 30 * nAtsSSVSeg, 2)
				   	    // somo o bienio junto com o trienio.					   	    
				   	    If lRegravaB                                                            
					   	    nShFimBie:= Round((( nSHBien * nShAcum2 ) * nSindiB) / 30 * nAtsSSVSeg, 2)						   	    					   	    
				    	    fGeraVerba(aCodFol[1299,1],nShFimTri + nShFimBie,nAtsSSVSeg,,,,,,,,.T.)  								   	    
				   	    Else
				    	    fGeraVerba(aCodFol[1299,1],nShFimTri,nAtsSSVSeg,,,,,,,,.T.)  			
				    	Endif    
					   	
					 Endif
	
				   	 If lRegrava .And. ! (( Ascan(aPd,{|X| X[1] == aCodFol[1314,1].And. X[9] <> "D" .And. X[7] == "I"}) > 0 ) )
				   	    //guardo a referencia da verba de ats abono mes sobre verbas
				   	 	nAtsAboVrM:= fBuscaPD(aCodFol[1314,1],"D")
				   	    If fBuscaPD(aCodFol[1314,1]) > 0 
					   	    FdelPD(aCodFol[1314,1])
					   	Endif    
				   	    nShFimTri:= Round((( nSHTrie * nShAcum ) * nSindiT) / 30 * nAtsAboVrM, 2 )
				   	    // somo o bienio junto com o trienio.					   	    							
						If lRegravaB					   	    
					   	    nShFimBie:= Round((( nSHBien * nShAcum2 ) * nSindiB) / 30 * nAtsAboVrM, 2)	   
				    	    fGeraVerba(aCodFol[1314,1],nShFimTri + nShFimBie ,nAtsAboVrM,,,,,,,,.T.)  									   	    					   	    					   	    				    	    
			    	    Else
				    	    fGeraVerba(aCodFol[1314,1],nShFimTri,nAtsAboVrM,,,,,,,,.T.)  			
				    	Endif    
					   	
					 Endif 
				   	 If lRegrava .And. ! (( Ascan(aPd,{|X| X[1] == aCodFol[1315,1].And. X[9] <> "D" .And. X[7] == "I"}) > 0 ) )
				   	    //guardo a referencia da verba de ats abono mes seguinte sobre verbas
				   	 	nAtsAboVrS:= fBuscaPD(aCodFol[1315,1],"D")
				   	    If fBuscaPD(aCodFol[1315,1]) > 0 
					   	    FdelPD(aCodFol[1315,1])
					   	Endif    
				   	    nShFimTri:= Round((( nSHTrie * nShAcum ) * nSindiT) / 30 * nAtsAboVrS, 2)
				   	    // somo o bienio junto com o trienio.					   	    														
						If lRegravaB					   	                               
					   	    nShFimBie:= Round((( nSHBien * nShAcum2 ) * nSindiB) / 30 * nAtsAboVrS, 2)	   							                         
				    	    fGeraVerba(aCodFol[1315,1],nShFimTri + nShFimBie,nAtsAboVrS,,,,,,,,.T.)  			
			    	    Else
				    	    fGeraVerba(aCodFol[1315,1],nShFimTri,nAtsAboVrS,,,,,,,,.T.)  			
				    	Endif    
					   	
					 Endif 
					 
					 // caso o sindicato do funcionario esteja na tabela especifica e nao tem tempo para o adts, apago o gerado pelo padrao do sistema.
		    	     If !(lRegrava) 
		    	        FdelPD(aCodFol[1298,1]) 
		    	        FdelPD(aCodFol[1299,1])
			   	    	FdelPD(aCodFol[1314,1])
			   	    	FdelPD(aCodFol[1315,1])
			    	 Endif 					 					  				  				  				 				 			  
				              
              Endif
            
		   	Endif
			
			
			//131 / 132 		   	
		  	If 	CTIPOROT $ "5/6"
				  
				  If cBCalATS == "1" 
				                     
				   	 // verifico se precisa recalcular e nao esta informada, deleto a verba caso exista. 			  					 				  
				   	 If lRegrava .And. ! (( Ascan(aPd,{|X| X[1] == aCodFol[1288,1].And. X[9] <> "D" .And. X[7] == "I"}) > 0 ) )
				   	    //guardo a referencia da verba de ats mes
				   	 	nAts13Mes:= fBuscaPD(aCodFol[1288,1],"D")
				   	    If fBuscaPD(aCodFol[1288,1]) > 0 
					   	    FdelPD(aCodFol[1288,1])
					   	Endif     
				   	    nShFimTri:= Round((( nSHTrie * nShAcum ) * nSindiT) / 30 * nAts13Mes, 2) 
				   	    // somo o bienio junto com o trienio.
				   	    If  lRegravaB 
					   	    nShFimBie:= Round((( nSHBien * nShAcum2 ) * nSindiB) / 30 * nAts13Mes, 2)						   	    
				    	    fGeraVerba(aCodFol[1288,1],nShFimTri + nShFimBie,nShAcum,,,,,,,,.T.)  				   	    					   	    
				   	    Else
				    	    fGeraVerba(aCodFol[1288,1],nShFimTri,nShAcum,,,,,,,,.T.)  				   	    
				    	Endif    
					   	
					 Endif    
					       
				  Endif
				  	
				  If cBCalATS == "2"

				   	 // verifico se precisa recalcular e nao esta informada, deleto a verba caso exista. 			  					 				  	 
				   	 If lRegrava .And. ! (( Ascan(aPd,{|X| X[1] == aCodFol[1289,1].And. X[9] <> "D" .And. X[7] == "I"}) > 0 ) )
				   	    //guardo a referencia da verba de ats mes seguinte
				   	 	nAts13MSV:= fBuscaPD(aCodFol[1289,1],"D")
				   	    If fBuscaPD(aCodFol[1289,1]) > 0 
					   	    FdelPD(aCodFol[1289,1])
						Endif
				   	    nShFimTri:= Round((( nSHTrie * nShAcum ) * nSindiT) / 30 * nAts13MSV, 2) 
				   	    // somo o bienio junto com o trienio.
				   	    If  lRegravaB 
					   	    nShFimBie:= Round((( nSHBien * nShAcum2 ) * nSindiB) / 30 * nAts13MSV,2 ) 
				    	    fGeraVerba(aCodFol[1289,1],nShFimTri + nShFimBie ,nShAcum,,,,,,,,.T.)  						   	    						   	    					   	    
				   	    Else					   	    
				    	    fGeraVerba(aCodFol[1289,1],nShFimTri,nShAcum,,,,,,,,.T.)  		
				    	Endif    
				   	
					 Endif 		   	

				  Endif 
				  
 				  // caso o sindicato do funcionario esteja na tabela especifica e nao tem tempo para o adts, apago o gerado pelo padrao do sistema.
		    	  If !(lRegrava) 
		    	       FdelPD(aCodFol[1288,1]) 
		    	       FdelPD(aCodFol[1289,1])
		    	  Endif 	
					
  		   	Endif		   	

			// FOL / RES 
		  	If 	CTIPOROT $ "1/4"

		   	    //trienio
		   	    // verifico se precisa recalcular e nao esta informada, deleto a verba caso exista. 			  					 		   	    		   	
			   	If lRegrava .And. ! (( Ascan(aPd,{|X| X[1] == aCodFol[3,1].And. X[9] <> "D" .And. X[7] == "I"}) > 0 ) )

			   	    If fBuscaPD(aCodFol[3,1]) > 0 
			   	    	FdelPD(aCodFol[3,1])
			   	    Endif				   	    	
			   	    nShFimTri:= Round((( nSHTrie * nShAcum ) * nSindiT) / 30 * diastrab, 2 )
		    	    fGeraVerba(aCodFol[3,1],nShFimTri,nShAcum,,,,,,,,.T.)  			   	    	


				Endif	

				//bienio
				// verifico se precisa recalcular e nao esta informada, deleto a verba caso exista. 			  					 								   	
			   	If lRegravaB .And. ! (( Ascan(aPd,{|X| X[1] == aCodFol[2,1].And. X[9] <> "D" .And. X[7] == "I"}) > 0 ) )
			   	    
			   	    If fBuscaPD(aCodFol[2,1]) > 0 
				   	    FdelPD(aCodFol[2,1])
				   	Endif
			   	    nShFimBie:= Round((( nSHBien * nShAcum2 ) * nSindiB) / 30 * diastrab, 2)	
		    	    fGeraVerba(aCodFol[2,1],nShFimBie,nShAcum2,,,,,,,,.T.) 					   	    
    
 
		    	 Endif 
		    	 
		    	 // caso o sindicato do funcionario esteja na tabela especifica e nao tem tempo para o adts, apago o gerado pelo padrao do sistema.
		    	 If !(lRegrava)
		   	    	FdelPD(aCodFol[3,1])
		   	    	FdelPD(aCodFol[2,1])
		    	 Endif 			   	    
	                                                
	        Endif
	    

	     
	    Endif   
	  
	Endif  
	     
Endif
	
Return("FIM")