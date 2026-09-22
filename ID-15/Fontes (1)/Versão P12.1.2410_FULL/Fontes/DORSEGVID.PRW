#INCLUDE "PROTHEUS.CH"
//==========================================================================================
/*/
/  Funcao montar o salario dos comissionados e tarefeiros p/ calculo do seguro de vida.
@author     A.Shibao
@since      08/09/16
@param		
@version    P12
@return      
@project 
@client    RedeDor   
/*/
//==========================================================================================  
User Function DorSegVid() 

Local aSHSegVi	:= {}
Local nPosSegVid:= 0 
Local nTabSegVid:= 0 
Local nShSalario:= 0
Local cShCatFun := SRA->RA_CATFUNC 

fCarrTab( @aSHSegVi,"U107", Nil)  

// Verifico se existe registros na tabela com as verbas para montar o salario 		   
If ( nPosSegVid := Ascan(aSHSegVi,{ |x| x[1] == "U107"  .And. x[5] $ cShCatFun }))  > 0  
	
	     //Tabelas U107 - Verbas que montam o salario dos comissionados e tarefeiros
	     For nShCont := nPosSegVid to len(aSHSegVi)
	     	 //If aSHSegVi[nShCont,2] == cFilAnt
			     // busco as verbas na tabela U107
			     cShVrbP :=  Alltrim(aSHSegVi[nShCont,6])
			     If !Empty(cShVrbP) .or. !Empty(aSHSegVi[nShCont,5])
					 For nTp := 1 to Len(cShVrbP) Step 4
						cFindVrb := SubStr(cShVrbP, nTp, 3)
						nShSalario += fBuscaPD(cFindVrb)
					 Next 
				 Else
				   Alert("Tabela U017 - Base Salario para Seguro de Vida nao está parametrizada corretamente.")
				   Return
				 Endif	    
	         //Endif 
		 Next nShCont
		 
		SALMES := MAX(SALMES+nShSalario,NGTARPRO)		 
Endif	
	
Return()				 