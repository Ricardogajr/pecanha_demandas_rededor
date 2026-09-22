#INCLUDE "PROTHEUS.CH"
//==========================================================================================
/*/
/  Funcao para retirar a incidencia de INSS qdo for rescisao p/ determinada filial ( tabela especifica)
@author     A.Shibao
@since      28/11/2016
@param		
@version    P12
@return      
@project 
@client    RedeDor   
/*/
//==========================================================================================  
User Function DorNaoIns() 

Local aSHNoInss	:= {}
Local nPosTabInc:= 0 
Local nTabInFil := 0 

fCarrTab( @aSHNoInss,"U10D", Nil)  
 
// Verifico se existe registros na tabela, se rescisao e se de verbas que irao incoporar salario e filial.		   
If ( nPosTabInc := Ascan(aSHNoInss,{ |x| x[1] == "U10D" .And. alltrim(x[2]) == alltrim(SRA->RA_FILIAL) }))  > 0  

     //Tabelas U10D - Verbas que serao trocadas as incidencias de S para N p/ Inss
     For nShCont := nPosTabInc to len(aSHNoInss)
     	 If aSHNoInss[nShCont,2] == cFilAnt
		     // busco as verbas na tabela U10D
		     cShVrbP :=  Alltrim(aSHNoInss[nShCont,5])                              
			 For nTp := 1 to Len(cShVrbP) Step 4
				cFindVrb := SubStr(cShVrbP, nTp, 3)
				// monta o array com incidencias da verba
				fIncide(cFindVrb)               
				nPoInci:= 0
				//garanto que a verba esteja no apdv
				If 	(nPoInci :=	Ascan(Apdv,{|x| x[1] == cFindVrb })   ) > 0 
					// altera a incidencias para NAO p/Inss
					Apdv[nPoInci,4]:= "N"
				Endif     
				//If 
				//	apdv
				//Endif	
				//If (nTp + 4) < Len(cShVrbP)
				//	nTp:= nTp + 3
				//EndIf
			 Next nTp 
		 Endif 
	 Next nShCont  
Endif	

Return()				 