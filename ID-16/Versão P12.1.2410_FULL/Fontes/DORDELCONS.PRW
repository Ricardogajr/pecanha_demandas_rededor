#INCLUDE "PROTHEUS.CH"
//==========================================================================================
/*/
/  Funcao para deletar as verbas de consignado qdo funcionario afastado menos qdo estiver de maternidade.
@author     A.Shibao
@since      31/08/16
@param		
@version    P12
@return      
@project 
@client    RedeDor   
/*/
//==========================================================================================  
User Function DorDelCons() 

Local aSHConsi	:= {}
Local nPosConsig:= 0 
Local nTabConsig := 0 

fCarrTab( @aSHConsi,"U105", Nil)  
 
If (SRA->RA_SITFOLH == "A" .And. nDPrgSalMa = 0 .And. NDIASMAT = 0 ) //(!fBuscaPD(aCodFol[40,1]) > 0)) .or. ( SRA->RA_SITFOLH = "A" .And. (!fBuscaPD(aCodFol[927,1])> 0 ))
	
	// Verifico se existe registros na tabela com as verbas que devem ser deletadas.		   
	If ( nPosConsig := Ascan(aSHConsi,{ |x| x[1] == "U105"}))  > 0  
	
	     //Tabelas U104 - Verbas que devem ser deletas qdo funcionario estiver afastado
	     For nShCont := nPosConsig to len(aSHConsi)
	     	 //If aSHConsi[nShCont,2] == cFilAnt
			     // busco as verbas na tabela U104
			     cShVrbP :=  Alltrim(aSHConsi[nShCont,5])                              
				 For nTp := 1 to Len(cShVrbP) Step 4
					cFindVrb := SubStr(cShVrbP, nTp, 3)
				    If !Empty(cFindVrb) .And. abs(fBuscaPd(cFindVrb)) > 0
						fDelPD(cFindVrb)
				    Endif
				 Next    
	         //Endif 
		 Next nShCont  
	Endif	

Endif
	
Return()				 