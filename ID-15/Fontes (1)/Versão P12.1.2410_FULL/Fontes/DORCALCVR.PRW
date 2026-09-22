#INCLUDE "PROTHEUS.CH"  
/*================================================================================================================================================ 
//  Funcao calcular o vale refeicao 
@author     A.Shibao
@since      02/09/16
@param		
@version    P12
@return      
@project 
@client    RedeDor     
//       Tabela U10A
//		 aSHCalVR[1] - TABELA
//		 aSHCalVR[2] - FILIAL
//		 aSHCalVR[3] - DATA
//		 aSHCalVR[4] - SEQUENCIA
//		 aSHCalVR[5] - SINDICATO
//		 aSHCalVR[6] - DESCONTO SOBRE 1-SALARIO 2-BENEFICIO 3-FIXO
//		 aSHCalVR[7] - CONTROLE       1- REFEITORIO(RGB)    2- ALELO(SR0)
//		 aSHCalVR[8] - % DE DESCONTO
//		 aSHCalVR[9] - VALOR UNITARIO
//		 aSHCalVR[10]- VALOR FIXO
//		 aSHCalVR[11]- VALOR ATE
//		 aSHCalVR[12]- TETO
//		 aSHCalVR[13]- VERBA DESCONTO
//		 aSHCalVR[14]- VERBA BASE
//      a variavel cControle está fixo na chamada da formula e para o roteiro FOL deve estar DorCalcVR("1") e para o VRF DorCalcVR("2")
//================================================================================================================================================*/
User Function DorCalcVR(cControle) 

Local nPosCalVr := 0 
Local nShConta  := 0 
Local nShSalario:= 0
Local nShDesc   := 0 
Local cShVerba  := "" 
Local cShVerbaB := "" 
Local nShSr0    := 0 
Local nShFixo   := 0
Local nShBasD   := 0
Local lSalario  := .F.
Local lFixo     := .F.
Local lBeneficio:= .F. 
Local lAchou    := .F.
Local lFaltaCad := .F.

Private aSHCalVR	:= {}
  
fCarrTab( @aSHCalVR,"U10A", Nil,.T.)      

//fOrdenU10(@aSHCalVR) 
 
// Verifico se existe registros na tabela com a filial + sindicato a ser processada		   
If ( nPosCalVr := Ascan(aSHCalVR,{ |x| x[1] == "U10A" .And. alltrim(x[2]) == alltrim(SRA->RA_FILIAL) .And. x[5] == SRA->RA_SINDICA .And. x[7]== cControle}))  > 0  

         // Verifico qtos registros tem para a filial 
	     For nShCont := nPosCalVr to len(aSHCalVR)
	         
	        // busco somente os registros conforme a paremtrizacao
	     	If aSHCalVR[nShCont,1] == "U10A" .And. alltrim(aSHCalVR[nShCont,2]) == alltrim(SRA->RA_FILIAL) .And. aSHCalVR[nShCont,5] == SRA->RA_SINDICA
	     
	     	    // 1º validacao
	     	    If  !(aSHCalVR[nShCont,6] $ "1/2/3") .Or.  Empty(aSHCalVR[nShCont,6])
     	    	 	Alert("Na tabela U10A, nao está paremetrizado a coluna '1-SALARIO 2-BENEFICIO 3-FIXO' para essa filial")
     	    	 	lFaltaCad:= .T.
	            Endif  
	     
	            // 2º validacao  
	     	    If  !(aSHCalVR[nShCont,7] $ "1/2") .Or.  Empty(aSHCalVR[nShCont,7])
     	    	 	Alert("Na tabela U10A, nao está paremetrizado a coluna '1- REFEITORIO(RGB)    2- ALELO(SR0)' para essa filial")
     	    	 	lFaltaCad:= .T.
	            Endif                                                              
	     
	            // 3º validacao onde deve ser igual o tipo de calculo para todos os registros ( filial + desconto sobre + tipo sr0 ou rgb + sindicato )
				If aSHCalVR[nShCont,6] == "1"
					lSalario     := .T.
				ElseIf aSHCalVR[nShCont,6] == "2"					
				    lBeneficio   := .T.
				Else					
					lFixo        := .T.					            
	            Endif
	     
	            // 4º validacao
   	     	    If  Empty(aSHCalVR[nShCont,13]) 
     	    	 	Alert("Na tabela U10A, nao está paremetrizado a coluna 'Verba de Base' para essa filial")
     	    	 	lFaltaCad:= .T.	   
     	    	Endif 
	     
	            // 5º validacao
   	     	    If  Empty(aSHCalVR[nShCont,14]) 
     	    	 	Alert("Na tabela U10A, nao está paremetrizado a coluna 'Verba de Desconto' para essa filial")
     	    	 	lFaltaCad:= .T.	   
     	    	Endif   
       
     	 	    	// Sai da rotina   	    		         
	            If lFaltaCad
	                Return
	            Endif
	                       
	        Endif    
		 Next nShCont  

	     
   	     If !(SRV->(dbSeek(xFilial("SRV")+aSHCalVR[nPosCalVr,13])))
		 	Alert("Nao existe a verba " +  aSHCalVR[nPosCalVr,13] + " no cadastro de verbas ")	     	     	     
		 	Return		 	
	     Endif   
	     
   	     If !(SRV->(dbSeek(xFilial("SRV")+aSHCalVR[nPosCalVr,14])))
		 	Alert("Nao existe a verba " +  aSHCalVR[nPosCalVr,14] + " no cadastro de verbas ")	     	     	     
		 	Return		 	
	     Endif
	     
	     If lSalario 
	     
		         // Verifico qtos registros tem para a filial 
				 For nShCont := nPosCalVr to len(aSHCalVR)
	         
			        // busco somente os registros conforme a paremtrizacao do calculo 
	    		 	If aSHCalVR[nShCont,1] == "U10A" .And. alltrim(aSHCalVR[nShCont,2]) == alltrim(SRA->RA_FILIAL) .And. aSHCalVR[nShCont,5] == SRA->RA_SINDICA	 .And. aSHCalVR[nShCont,6] == "1"
	    		 	
	     	             If SRA->RA_SALARIO < aSHCalVR[nShCont,11] 
	     	             
	     	                // calcula sobre o % 
	     	  				If !(Empty(aSHCalVR[nShCont,8])) .And. !(lAchou) 
	     	  				     // 1 - salario ; 2 - beneficio 
	     	  					 If aSHCalVR[nShCont,6] == "2"   
	     	  					 	 //nShSr0 := Posicione("SR0",3,xFilial("SRA")+ SRA->RA_MAT + "1","R0_VALCAL")
			 	        	         If len(AVRCALC) > 0
						       	        nShSr0:= AVRCALC[1,4]
						       	     Endif	     	  					 	 
		     	  				     nShDesc:= Round( nShSr0 * (aSHCalVR[nShCont,8]/100) ,   MsDecimais(1))
	     	  					 Else
		     	  				     nShDesc:= Round( SRA->RA_SALARIO * (aSHCalVR[nShCont,8]/100) ,   MsDecimais(1))  
		     	  				 Endif    	     	  				     
	     	  				     
					             // verifica o teto
	     	  				     If nShDesc > aSHCalVR[nShCont,12]  
	     	  				     	nShDesc := aSHCalVR[nShCont,12]  
	     	  				     Endif 
	     	  				     // encontrou a linha correspondente e para aqui para gerar o valor.	     	  				     	     	  				     
                                 cShVerba   := aSHCalVR[nShCont,13]   
                                 cShVerbaB  := aSHCalVR[nShCont,14]                                    
	     	  				     //nShCont	:= len(aSHCalVR)	
	     	  				     lAchou 	:= .T.     	  				     
	     	  				Endif
	     	  				
	     	                // calcula sobre o valor do beneficio
	     	  				If !(Empty(aSHCalVR[nShCont,9])) .And. !(lAchou)
	     	  				     // Busca da SR0 ou RGB 
	     	  					 If aSHCalVR[nShCont,7] == "2"   
	     	  					 	 //nShSr0 := Posicione("SR0",3,xFilial("SRA")+ SRA->RA_MAT + "1","R0_VALCAL")
			 	        	         If len(AVRCALC) > 0
						       	        nShSr0:= AVRCALC[1,4]
						       	     Endif	     	  					 	 
		     	  				     nShDesc:= Round( nShSr0 * (aSHCalVR[nShCont,9]) ,   MsDecimais(1))
	     	  					 Else
		     	  				     nShDesc:= Round( fBuscaPD(aSHCalVR[nShCont,14],"H") * (aSHCalVR[nShCont,9]) ,   MsDecimais(1))
		     	  				 Endif    
   					             // verifica o teto
	     	  				     If nShDesc > aSHCalVR[nShCont,12]  
	     	  				     	nShDesc := aSHCalVR[nShCont,12]  
	     	  				     Endif         
	     	  				     // encontrou a linha correspondente e para aqui para gerar o valor.	     	  				     
                                 cShVerba   := aSHCalVR[nShCont,13] 
                                 cShVerbaB  := aSHCalVR[nShCont,14]                                                                     
	     	  				     //nShCont	:= len(aSHCalVR)	
	     	  				     lAchou 	:= .T. 	     	  				     
	     	  				Endif
	     	  				
	     	  				If lAchou
	     	  				     nShCont	:= len(aSHCalVR)
	     	  				Endif	     	  				
	     	  
	     	             Endif	
	     	             
	     		    Endif    
		
				 Next nShCont  
	     
	     Elseif lBeneficio
	            //Alert("Calculo sobre o beneficio")  
	            
		         // Verifico qtos registros tem para a filial 
				 For nShCont := nPosCalVr to len(aSHCalVR)
	         
			        // busco somente os registros conforme a paremtrizacao do calculo sobre o beneficio "2" ==  aSHCalVR[nShCont,6]
	    		 	If aSHCalVR[nShCont,1] == "U10A" .And. alltrim(aSHCalVR[nShCont,2]) == alltrim(SRA->RA_FILIAL) .And. aSHCalVR[nShCont,5] == SRA->RA_SINDICA	 .And. aSHCalVR[nShCont,6] == "2"
	     	             
	     	             If SRA->RA_SALARIO < aSHCalVR[nShCont,11] 
    	  				
	     	                // calcula sobre o % 
	     	  				If !(Empty(aSHCalVR[nShCont,8])) .And. !(lAchou) 
								 // 1 - salario ; 2 - beneficio 
	     	  					 If aSHCalVR[nShCont,6] == "2"   
	     	  					 	 //nShSr0 := Posicione("SR0",3,xFilial("SRA")+ SRA->RA_MAT + "1","R0_VALCAL")
			 	        	         If len(AVRCALC) > 0
						       	        nShSr0:= AVRCALC[1,4]
						       	     Endif	     	  					 	 
		     	  				     nShDesc:= Round( nShSr0 * (aSHCalVR[nShCont,8]/100) ,   MsDecimais(1))
	     	  					 Else
		     	  				     nShDesc:= Round( (fBuscaPD(aSHCalVR[nShCont,14],"H") * (aSHCalVR[nShCont,9])) * (aSHCalVR[nShCont,8]/100) ,   MsDecimais(1))
		     	  				     nShBasD:= Round( (fBuscaPD(aSHCalVR[nShCont,14],"H") * (aSHCalVR[nShCont,9])) ,   MsDecimais(1))
		     	  				 Endif    	     	  				     
	     	  				     
					             // verifica o teto
	     	  				     If nShDesc > aSHCalVR[nShCont,12]  
	     	  				     	nShDesc := aSHCalVR[nShCont,12]  
	     	  				     Endif 
	     	  				     // encontrou a linha correspondente e para aqui para gerar o valor.	     	  				     	     	  				     
                                 cShVerba   := aSHCalVR[nShCont,13]   
                                 cShVerbaB  := aSHCalVR[nShCont,14]                                                                     
	     	  				     //nShCont	:= len(aSHCalVR)	
	     	  				     lAchou 	:= .T.     	  				     
	     	  				Endif
	     	  				
	     	                // calcula sobre o valor do beneficio
	     	  				If !(Empty(aSHCalVR[nShCont,9])) .And. !(lAchou)
	     	  				     // Busca da SR0 ou RGB
	     	  					 If aSHCalVR[nShCont,7] == "2"   
	     	  					 	 //nShSr0 := Posicione("SR0",3,xFilial("SRA")+ SRA->RA_MAT + "1","R0_VALCAL")
			 	        	         If len(AVRCALC) > 0
						       	        nShSr0:= AVRCALC[1,4]
						       	     Endif	     	  					 	 
		     	  				     nShDesc:= Round( nShSr0 * (aSHCalVR[nShCont,9]) ,   MsDecimais(1))
	     	  					 Else
		     	  				     nShDesc:= Round( fBuscaPD(aSHCalVR[nShCont,14],"H") * (aSHCalVR[nShCont,9]) ,   MsDecimais(1))
		     	  				     nShBasD:= Round( (fBuscaPD(aSHCalVR[nShCont,14],"H") * (aSHCalVR[nShCont,9])) ,   MsDecimais(1))		     	  				     
		     	  				 Endif    
   					             // verifica o teto
	     	  				     If nShDesc > aSHCalVR[nShCont,12]  
	     	  				     	nShDesc := aSHCalVR[nShCont,12]  
	     	  				     Endif         
	     	  				     // encontrou a linha correspondente e para aqui para gerar o valor.	     	  				     
                                 cShVerba   := aSHCalVR[nShCont,13] 
                                 cShVerbaB  := aSHCalVR[nShCont,14]                                                                     
	     	  				     //nShCont	:= len(aSHCalVR)	
	     	  				     lAchou 	:= .T. 	     	  				     
	     	  				Endif  
	     	  				
	     	  				If lAchou
	     	  				     nShCont	:= len(aSHCalVR)
	     	  				Endif	     	  			     	  					 
	     	  				
	     	             Endif	
	     	             
	     		    Endif    
		
				 Next nShCont  	            
	     Elseif lFixo
	            //Alert("Calculo valor fixo ")    
	            
		         // Verifico qtos registros tem para a filial 
				 For nShCont := nPosCalVr to len(aSHCalVR)
	         
			        // busco somente os registros conforme a paremtrizacao do calculo fixo "3" ==  aSHCalVR[nShCont,6]
	    		 	If aSHCalVR[nShCont,1] == "U10A" .And. alltrim(aSHCalVR[nShCont,2]) == alltrim(SRA->RA_FILIAL) .And. aSHCalVR[nShCont,5] == SRA->RA_SINDICA	 .And. aSHCalVR[nShCont,6] == "3"
	     	             If SRA->RA_SALARIO < aSHCalVR[nShCont,11] 
	     	  				
	     	                // calcula valor fixo
	     	  				If !(Empty(aSHCalVR[nShCont,10])) .And. !(lAchou) 
	     	  				
	     	  				     // busca verba de base no movimento podendo ser em hora ou valor ou dias.
	     	  				     nShFixo:= fBuscaPD(aSHCalVR[nShCont,14]) + fBuscaPD(aSHCalVR[nShCont,14],"H")
	     	  				     
	     	  				     If nShFixo > 0
		     	  				     nShDesc:= Round( aSHCalVR[nShCont,10] / 30 * diastrab,   MsDecimais(1)) 
								 Endif	     	  				     
	
	     	  				     // encontrou a linha correspondente e para aqui para gerar o valor.	     	  				     
                                 cShVerba   := aSHCalVR[nShCont,13] 
                                 cShVerbaB  := aSHCalVR[nShCont,14]                                                                     
	     	  				     //nShCont	:= len(aSHCalVR)	
	     	  				     lAchou 	:= .T. 	     	  				     
	     	  				Endif  
	     	  				
	     	  				If lAchou
	     	  				     nShCont	:= len(aSHCalVR)
	     	  				Endif	     	  			     	  					     	  				
	     	  
	     	             Endif	
	     		    Endif    
		
				 Next nShCont  	            	     
	     Endif
	     
	     If ! (( Ascan(aPd,{|X| X[1] == cShVerba .And. X[9] <> "D" .And. X[7] == "I"}) > 0 ) )  .And. nShDesc > 0
       	     //Grava na SR0 no array AVRCALC
       	     If cControle == "2"
       	        If len(AVRCALC) > 0
	       	        AVRCALC[1,5]:= nShDesc
					AVRCALC[1,6]:=AVRCALC[1,4] - nShDesc	       	        
       	        Endif
       	     Else //Grava na RGB 
	       	     fGeraVerba(cShVerba ,nShDesc,fBuscaPD(cShVerba,"D") ,,,,,,,,.T.) 
	       	     If fBuscaPd(cShVerbaB,"D") > 0
	    	   	     //fGeraVerba(cShVerbaB,IIf(lBeneficio,nShBasD,nShDesc),fBuscaPD(cShVerbaB,"D"),,,,,,,,.T.)   
    	   	         aPd[fLocaliaPD(cShVerbaB),5] := IIf(lBeneficio,nShBasD,nShDesc)   	   	     	    	   	     
	    	   	 Endif    	       	      

    	   	 Endif 
	     Endif
Else
	// Verifico se existe registros na tabela apenas com a filial sem sindicato a ser processa que são a maioria.	   	
	If ( nPosCalVr := Ascan(aSHCalVR,{ |x| x[1] == "U10A" .And. alltrim(x[2]) == alltrim(SRA->RA_FILIAL) .And. Empty(x[5]) .And. x[7]== cControle}))  > 0  

         // Verifico qtos registros tem para a filial 
	     For nShCont := nPosCalVr to len(aSHCalVR)
	         
	        // busco somente os registros conforme a paremtrizacao
	     	If aSHCalVR[nShCont,1] == "U10A" .And. alltrim(aSHCalVR[nShCont,2]) == alltrim(SRA->RA_FILIAL) .And. Empty(aSHCalVR[nShCont,5])
	     		     
	     	    // 1º validacao
	     	    If  !(aSHCalVR[nShCont,6] $ "1/2/3") .Or.  Empty(aSHCalVR[nShCont,6])
     	    	 	Alert("Na tabela U10A, nao está paremetrizado a coluna '1-SALARIO 2-BENEFICIO 3-FIXO' para essa filial")
     	    	 	lFaltaCad:= .T.
	            Endif  
	     
	            // 2º validacao  
	     	    If  !(aSHCalVR[nShCont,7] $ "1/2") .Or.  Empty(aSHCalVR[nShCont,7])
     	    	 	Alert("Na tabela U10A, nao está paremetrizado a coluna '1- REFEITORIO(RGB)    2- ALELO(SR0)' para essa filial")
     	    	 	lFaltaCad:= .T.
	            Endif                                                              
	     
	            // 3º validacao onde deve ser igual o tipo de calculo para todos os registros ( filial + desconto sobre + tipo sr0 ou rgb + sindicato )
				If aSHCalVR[nShCont,6] == "1"
					lSalario     := .T.
				ElseIf aSHCalVR[nShCont,6] == "2"					
				    lBeneficio   := .T.
				Else					
					lFixo        := .T.					            
	            Endif
	     
	            // 4º validacao
   	     	    If  Empty(aSHCalVR[nShCont,13]) 
     	    	 	Alert("Na tabela U10A, nao está paremetrizado a coluna 'Verba de Base' para essa filial")
     	    	 	lFaltaCad:= .T.	   
     	    	Endif 
	     
	            // 5º validacao
   	     	    If  Empty(aSHCalVR[nShCont,14]) 
     	    	 	Alert("Na tabela U10A, nao está paremetrizado a coluna 'Verba de Desconto' para essa filial")
     	    	 	lFaltaCad:= .T.	   
     	    	Endif   
       
     	 	    	// Sai da rotina   	    		         
	            If lFaltaCad
	                Return
	            Endif
	                       
	        Endif    
		 Next nShCont  

	     
   	     If !(SRV->(dbSeek(xFilial("SRV")+aSHCalVR[nPosCalVr,13])))
		 	Alert("Nao existe a verba " +  aSHCalVR[nPosCalVr,13] + " no cadastro de verbas ")	     	     	     
		 	Return		 	
	     Endif   
	     
   	     If !(SRV->(dbSeek(xFilial("SRV")+aSHCalVR[nPosCalVr,14])))
		 	Alert("Nao existe a verba " +  aSHCalVR[nPosCalVr,14] + " no cadastro de verbas ")	     	     	     
		 	Return		 	
	     Endif
	     
	     If lSalario 
	     
		         // Verifico qtos registros tem para a filial 
				 For nShCont := nPosCalVr to len(aSHCalVR)
	         
			        // busco somente os registros conforme a paremtrizacao do calculo 
	    		 	If aSHCalVR[nShCont,1] == "U10A" .And. alltrim(aSHCalVR[nShCont,2]) == alltrim(SRA->RA_FILIAL) .And. aSHCalVR[nShCont,6] == "1" .And. Empty(aSHCalVR[nShCont,5])
	    		 	
	     	             If SRA->RA_SALARIO < aSHCalVR[nShCont,11] 
	     	             
	     	                // calcula sobre o % 
	     	  				If !(Empty(aSHCalVR[nShCont,8])) .And. !(lAchou) 
	     	  				     // 1 - salario ; 2 - beneficio
	     	  					 If aSHCalVR[nShCont,6] == "2"   
	     	  					 	 //nShSr0 := Posicione("SR0",3,xFilial("SRA")+ SRA->RA_MAT + "1","R0_VALCAL")
			 	        	         If len(AVRCALC) > 0
						       	        nShSr0:= AVRCALC[1,4]
						       	     Endif
		     	  				     nShDesc:= Round( nShSr0 * (aSHCalVR[nShCont,8]/100) ,   MsDecimais(1))
	     	  					 Else
		     	  				     nShDesc:= Round( SRA->RA_SALARIO * (aSHCalVR[nShCont,8]/100) ,   MsDecimais(1))  
		     	  				 Endif    	     	  				     
	     	  				     
					             // verifica o teto
	     	  				     If nShDesc > aSHCalVR[nShCont,12]  
	     	  				     	nShDesc := aSHCalVR[nShCont,12]  
	     	  				     Endif 
	     	  				     // encontrou a linha correspondente e para aqui para gerar o valor.	     	  				     	     	  				     
                                 cShVerba   := aSHCalVR[nShCont,13]   
                                 cShVerbaB  := aSHCalVR[nShCont,14]                                    
	     	  				     //nShCont	:= len(aSHCalVR)	
	     	  				     lAchou 	:= .T.     	  				     
	     	  				Endif
	     	  				
	     	                // calcula sobre o valor do beneficio
	     	  				If !(Empty(aSHCalVR[nShCont,9])) .And. !(lAchou)
					             // Busca da SR0 ou RGB 
	     	  					 If aSHCalVR[nShCont,7] == "2"   
	     	  					 	 //nShSr0 := Posicione("SR0",3,xFilial("SRA")+ SRA->RA_MAT + "1","R0_VALCAL")
			 	        	         If len(AVRCALC) > 0
						       	        nShSr0:= AVRCALC[1,4]
						       	     Endif	     	  					 	 
		     	  				     nShDesc:= Round( nShSr0 * (aSHCalVR[nShCont,9]) ,   MsDecimais(1))
	     	  					 Else
		     	  				     nShDesc:= Round( fBuscaPD(aSHCalVR[nShCont,14],"H") * (aSHCalVR[nShCont,9]) ,   MsDecimais(1))
		     	  				 Endif    
   					             // verifica o teto
	     	  				     If nShDesc > aSHCalVR[nShCont,12]  
	     	  				     	nShDesc := aSHCalVR[nShCont,12]  
	     	  				     Endif         
	     	  				     // encontrou a linha correspondente e para aqui para gerar o valor.	     	  				     
                                 cShVerba   := aSHCalVR[nShCont,13] 
                                 cShVerbaB  := aSHCalVR[nShCont,14]                                                                     
	     	  				     //nShCont	:= len(aSHCalVR)	
	     	  				     lAchou 	:= .T. 	     	  				     
	     	  				Endif
	     	  				
	     	  				If lAchou
	     	  				     nShCont	:= len(aSHCalVR)
	     	  				Endif	     	  				
	     	  
	     	             Endif	
	     	             
	     		    Endif    
		
				 Next nShCont  
	     
	     Elseif lBeneficio
	            //Alert("Calculo sobre o beneficio")  
	            
		         // Verifico qtos registros tem para a filial 
				 For nShCont := nPosCalVr to len(aSHCalVR)
	         
			        // busco somente os registros conforme a paremtrizacao do calculo sobre o beneficio "2" ==  aSHCalVR[nShCont,6]
	    		 	If aSHCalVR[nShCont,1] == "U10A" .And. alltrim(aSHCalVR[nShCont,2]) == alltrim(SRA->RA_FILIAL) .And. aSHCalVR[nShCont,6] == "2" .And. Empty(aSHCalVR[nShCont,5])
	     	             
	     	             If SRA->RA_SALARIO < aSHCalVR[nShCont,11] 
    	  				
	     	                // calcula sobre o % 
	     	  				If !(Empty(aSHCalVR[nShCont,8])) .And. !(lAchou) 
					             // 1 - salario ; 2 - beneficio 
	     	  					 If aSHCalVR[nShCont,6] == "2"   
	     	  					 	 //nShSr0 := Posicione("SR0",3,xFilial("SRA")+ SRA->RA_MAT + "1","R0_VALCAL")
 			 	        	         If len(AVRCALC) > 0
						       	        nShSr0:= AVRCALC[1,4]
						       	     Endif
		     	  				     nShDesc:= Round( nShSr0 * (aSHCalVR[nShCont,8]/100) ,   MsDecimais(1))
	     	  					 Else
		     	  				     nShDesc:= Round( (fBuscaPD(aSHCalVR[nShCont,14],"H") * (aSHCalVR[nShCont,9])) * (aSHCalVR[nShCont,8]/100) ,   MsDecimais(1))
		     	  				     nShBasD:= Round( (fBuscaPD(aSHCalVR[nShCont,14],"H") * (aSHCalVR[nShCont,9])) ,   MsDecimais(1))		     	  				     		     	  				     
		     	  				 Endif    	     	  				     
	     	  				     
					             // verifica o teto
	     	  				     If nShDesc > aSHCalVR[nShCont,12]  
	     	  				     	nShDesc := aSHCalVR[nShCont,12]  
	     	  				     Endif 
	     	  				     // encontrou a linha correspondente e para aqui para gerar o valor.	     	  				     	     	  				     
                                 cShVerba   := aSHCalVR[nShCont,13]   
                                 cShVerbaB  := aSHCalVR[nShCont,14]                                                                     
	     	  				     //nShCont	:= len(aSHCalVR)	
	     	  				     lAchou 	:= .T.     	  				     
	     	  				Endif                        
	     	  				
	     	                // calcula sobre o valor do beneficio
	     	  				If !(Empty(aSHCalVR[nShCont,9])) .And. !(lAchou)
 					             // Busca da SR0 ou RGB 
	     	  					 If aSHCalVR[nShCont,7] == "2"   
	     	  					 	 //nShSr0 := Posicione("SR0",3,xFilial("SRA")+ SRA->RA_MAT + "1","R0_VALCAL")
			 	        	         If len(AVRCALC) > 0
						       	        nShSr0:= AVRCALC[1,4]
						       	     Endif	     	  					 	 
		     	  				     nShDesc:= Round( nShSr0 * (aSHCalVR[nShCont,9]) ,   MsDecimais(1))
	     	  					 Else
		     	  				     nShDesc:= Round( fBuscaPD(aSHCalVR[nShCont,14],"H") * (aSHCalVR[nShCont,9]) ,   MsDecimais(1))
		     	  				     nShBasD:= Round( (fBuscaPD(aSHCalVR[nShCont,14],"H") * (aSHCalVR[nShCont,9])) ,   MsDecimais(1))		     	  				     		     	  				     		     	  				     
		     	  				 Endif    
   					             // verifica o teto
	     	  				     If nShDesc > aSHCalVR[nShCont,12]  
	     	  				     	nShDesc := aSHCalVR[nShCont,12]  
	     	  				     Endif         
	     	  				     // encontrou a linha correspondente e para aqui para gerar o valor.	     	  				     
                                 cShVerba   := aSHCalVR[nShCont,13] 
                                 cShVerbaB  := aSHCalVR[nShCont,14]                                                                     
	     	  				     //nShCont	:= len(aSHCalVR)	
	     	  				     lAchou 	:= .T. 	     	  				     
	     	  				Endif  
	     	  				
	     	  				If lAchou
	     	  				     nShCont	:= len(aSHCalVR)
	     	  				Endif	     	  			     	  					 
	     	  				
	     	             Endif	
	     	             
	     		    Endif    
		
				 Next nShCont  	            
	     Elseif lFixo
	            //Alert("Calculo valor fixo ")    
	            
		         // Verifico qtos registros tem para a filial 
				 For nShCont := nPosCalVr to len(aSHCalVR)
	         
			        // busco somente os registros conforme a paremtrizacao do calculo fixo "3" ==  aSHCalVR[nShCont,6]
	    		 	If aSHCalVR[nShCont,1] == "U10A" .And. alltrim(aSHCalVR[nShCont,2]) == alltrim(SRA->RA_FILIAL) .And. aSHCalVR[nShCont,6] == "3" .And. Empty(aSHCalVR[nShCont,5])
	     	             If SRA->RA_SALARIO < aSHCalVR[nShCont,11] 
	     	  				
	     	                // calcula valor fixo
	     	  				If !(Empty(aSHCalVR[nShCont,10])) .And. !(lAchou) 
	     	  				
	     	  				     // busca verba de base no movimento podendo ser em hora ou valor ou dias.
	     	  				     nShFixo:= fBuscaPD(aSHCalVR[nShCont,14]) + fBuscaPD(aSHCalVR[nShCont,14],"H")
	     	  				     
	     	  				     If nShFixo > 0
		     	  				     nShDesc:= Round( aSHCalVR[nShCont,10] / 30 * diastrab,   MsDecimais(1)) 
								 Endif	     	  				     
	
	     	  				     // encontrou a linha correspondente e para aqui para gerar o valor.	     	  				     
                                 cShVerba   := aSHCalVR[nShCont,13] 
                                 cShVerbaB  := aSHCalVR[nShCont,14]                                                                     
	     	  				     //nShCont	:= len(aSHCalVR)	
	     	  				     lAchou 	:= .T. 	     	  				     
	     	  				Endif  
	     	  				
	     	  				If lAchou
	     	  				     nShCont	:= len(aSHCalVR)
	     	  				Endif	     	  			     	  					     	  				
	     	  
	     	             Endif	
	     		    Endif    
		
				 Next nShCont  	            	     
	     Endif
	     
	     If ! (( Ascan(aPd,{|X| X[1] == cShVerba .And. X[9] <> "D" .And. X[7] == "I"}) > 0 ) )  .And. nShDesc > 0
       	     //Grava na SR0 no array AVRCALC
       	     If cControle == "2"
       	        If len(AVRCALC) > 0
	       	        AVRCALC[1,5]:= nShDesc
					AVRCALC[1,6]:=AVRCALC[1,4] - nShDesc	       	        
       	        Endif
       	     Else //Grava na RGB 
	       	     fGeraVerba(cShVerba ,nShDesc,fBuscaPD(cShVerba,"D") ,,,,,,,,.T.)
	       	     If fBuscaPd(cShVerbaB,"D") > 0  
	    	   	     //fGeraVerba(cShVerbaB,IIf(lBeneficio,nShBasD,nShDesc),fBuscaPD(cShVerbaB,"D"),,,,,,,,.T.)   
    	   	         aPd[fLocaliaPD(cShVerbaB),5] := IIf(lBeneficio,nShBasD,nShDesc)   	   	     	    	   	     
	    	   	 Endif    
    	   	 Endif    
	     Endif	
	
	
	Endif
	
Endif
	
Return() 

Static Function fOrdenU10()

cTab    := "U10A"
aTab_Fol:= {}     

//--Pocisiona no Primeiro Elemento do Cabecalho da Tabela
dbSelectArea("RCB")
dbSeek( xFilial("RCB") + cTab, .T. )

While ! Eof() 

	If cTab # RCB->RCB_CODIGO
		Exit
	Endif

	//--Carrega o Cabecalho da Tabela 
	aCabTab := {}
	While ! Eof() .And. cTab == RCB->RCB_CODIGO 

		RCB->(Aadd(aCabTab,{RCB_CAMPOS,RCB_TIPO,RCB_TAMAN,RCB_DECIMA}))
		dbSelectArea("RCB") 
		dbSkip()
	Enddo				

	//--Carregar Dados das Tabelas 
	dbSelectArea("RCC")
	dbSeek( xFilial("RCC") + cTab, .T. )
	While ! Eof() .And. RCC->RCC_FILIAL+RCC->RCC_CODIGO == xFilial("RCC")+cTab
	
		If Empty(RCC->RCC_CHAVE) 

	 		Aadd(aTab_Fol,{cTab,RCC->RCC_FIL,RCC->RCC_CHAVE,RCC->RCC_CONTEU})
	                                             
			nPosIni := 1
			nColAte := 1
			For nT:= 1 To Len(aCabTab) 
                                         
				//--Tamanho do Campo                                          	                
				nTamCpo := aCabTab[nT,3]
				
				//--Guarda conteudo do campo na Variavel 				
				If aCabTab[nT,2] == "C"
					cConteudo := Subs(RCC->RCC_CONTEU,nPosIni,nTamCpo)
				ElseIf aCabTab[nT,2] == "N"
					cConteudo := Val(Subs(RCC->RCC_CONTEU,nPosIni,nTamCpo))
				ElseIf aCabTab[nT,2] == "D"
					cConteudo := Subs(RCC->RCC_CONTEU,nPosIni,nTamCpo)
					cConteudo := If("/" $ cConteudo , CtoD(cConteudo) , StoD(cConteudo))
				Endif             

		 		Aadd(aTab_Fol[Len(aTab_Fol)],cConteudo)
				       
				//--Posicao Proximo Campo
				nPosIni += nTamCpo
					
			Next nT		  

			// Criacao do ULTIMO elemento no aTab_Fol. Sera a Filial da tabela carregada, pois na Gestao Corporativa quando envolve
			// processamento de Filial Branco a ZZZZZZ o aTab_Fol continuava preenchido com informacoes da filial anterior
			Aadd( aTab_Fol[ Len( aTab_Fol ) ], xFilial("RCC") )

		Endif	

		dbSelectArea("RCC")
		dbSkip()
	Enddo	

	dbSelectArea("RCB")
	dbSkip()
Enddo	

If len(aTab_Fol) > 0
	aSHCalVR:={}
	aSHCalVR:= aclone(aTab_Fol)
Endif                          

Return              
