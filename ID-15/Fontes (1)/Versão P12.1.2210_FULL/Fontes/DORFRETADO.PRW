#INCLUDE "PROTHEUS.CH"
//==========================================================================================
/*/
/  Funcao calcular o desconto do fretado conforme verba enviada pela empresa do fretado.
@author     A.Shibao
@since      02/09/16
@param		
@version    P12
@return      
@project 
@client    RedeDor   
/*/
//==========================================================================================  
User Function DorFretado() 

Local aSHFreta	:= {}
Local nPosFretad:= 0 
Local nTabFretad:= 0 
Local nShConta  := 0 
Local nShSalario:= (PosSrv(acodfol[51,1],SRA->RA_FILIAL,"RV_PERC") /100 ) * SRA->RA_SALARIO

fCarrTab( @aSHFreta,"U106", Nil)  
 
// Verifico se existe registros na tabela com as verbas que devem ser deletadas.		   
If ( nPosFretad := Ascan(aSHFreta,{ |x| x[1] == "U106"}))  > 0  
	
         // Caso a tabela tenha mais de um registro nao deixo seguir.
	     For nShCont := nPosFretad to len(aSHFreta)
	     	If aSHFreta[nShCont,1] == "U106"
	            nShConta+=1
	        Endif    
		 Next nShCont  
		 
		 If nShConta > 1
		 	Alert("Tabela U106 - CALCULA FRETADO possui mais de um registro vinculado, favor ajustar para um registro apenas")
		 	Return
		 Endif
		 
	     If Empty(aSHFreta[nPosFretad,5])
		 	Alert("Nao existe a verba de base de fretado na tabela U106")	
		 	Return     
	     Endif
	     
	     If Empty(aSHFreta[nPosFretad,6])
		 	Alert("Nao existe a verba de base de desconto na tabela U106")
		 	Return		 		     	     
	     Endif
	     
	     If Empty(aSHFreta[nPosFretad,7]) .or. aSHFreta[nPosFretad,7] == 0 
		 	Alert("Nao existe o valor do teto para desconto do fretado na tabela U106")	     	     
		 	Return		 	
	     Endif  
	     
	     If !(SRV->(dbSeek(xFilial("SRV")+aSHFreta[nPosFretad,4])))
		 	Alert("Nao existe a verba " +  aSHFreta[nPosFretad,4] + " no cadastro de verbas ")	     	     	     
		 	Return		 	
	     Endif
	     
	     If !(SRV->(dbSeek(xFilial("SRV")+aSHFreta[nPosFretad,5])))
		 	Alert("Nao existe a verba " +  aSHFreta[nPosFretad,5] + " no cadastro de verbas ")	     	     	     	     
		 	Return		 	
	     Endif
	     
	     If (nShPerc	 := PosSrv(aSHFreta[nPosFretad,6],SRA->RA_FILIAL,"RV_PERC") /100 ) == 0
		 	Alert("Nao existe o % na verba " +  aSHFreta[nPosFretad,6] + " no cadastro de verbas ")	     	     	     	     	     
		 	Return		 	
	     Endif
	     
	     If ! (( Ascan(aPd,{|X| X[1] == aCodFol[3,1].And. X[9] <> "D" .And. X[7] == "I"}) > 0 ) )
	         nShBase:= fBuscaPD(aSHFreta[nPosFretad,5])  
			 nShPerc:= PosSrv(aSHFreta[nPosFretad,6],SRA->RA_FILIAL,"RV_PERC") /100  
	         nShDesc:= Round(Iif( nShSalario > aSHFreta[nPosFretad,7], aSHFreta[nPosFretad,7] , nShSalario), MsDecimais(1))
	         //nShDesc:= Round(nShSalario, MsDecimais(1))
       	     fGeraVerba(aSHFreta[nPosFretad,6],nShDesc,nShPerc,,,,,,,,.T.)  
	     Endif

Endif	
	
Return()				 