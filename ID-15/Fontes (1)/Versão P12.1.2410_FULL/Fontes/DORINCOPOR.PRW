#INCLUDE "PROTHEUS.CH"
//======================================================================================================
/*/
/  Funcao para incorporar verbas ao salario para os calculos conforme filia ( tabela especifica)
@author     A.Shibao
@since      23/08/16
@param		
@version    P12
@return      
@project 
@client    RedeDor              
// 05/07/17 - A.Shibao - Ajuste para nao alterar a incidencia de incorporar o salario e passar a alterar
            a incidencia para Base para calculo (Salario Base ou Salario Incorporado).    
//======================================================================================================  */            
User Function DorIncopor() 

Local aSHvrbIn	:= {}
Local nPosTabInc:= 0 
Local nTabInFil := 0 

fCarrTab( @aSHvrbIn,"U103", Nil)  
 
// Verifico se existe registros na tabela de verbas que irao incoporar salario e filial.		   
If ( nPosTabInc := Ascan(aSHvrbIn,{ |x| x[1] == "U103"}))  > 0  .And. ( nTabInFil := Ascan(aSHvrbIn,{ |x| x[2] == cFilAnt }))  > 0 

     //Tabelas U103 - Verbas que incorporam Salario por filial
     For nShCont := nPosTabInc to len(aSHvrbIn)
     	 If aSHvrbIn[nShCont,2] == cFilAnt
		     // busco as verbas na tabela U103
		     cShVrbP :=  Alltrim(aSHvrbIn[nShCont,5])                              
			 For nTp := 1 to Len(cShVrbP) Step 4
				cFindVrb := SubStr(cShVrbP, nTp, 3)
				// monta o array com incidencias da verba
				fIncide(cFindVrb)               
				nPoInci:= 0
				//garanto que a verba esteja no apdv
				If 	(nPoInci :=	Ascan(Apdv,{|x| x[1] == cFindVrb })   ) > 0 
					// altera a incidencias para incorporar o salario. - comentado em 05/07/17 por alteracao da regra.
					//Apdv[nPoInci,18]:= "S"                            
					// altera a incidencias para Base para calculo (Salario Base ou Salario Incorporado) 
					Apdv[nPoInci,34]:= "2"					
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