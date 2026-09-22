#INCLUDE "PROTHEUS.CH"
//==========================================================================================
/*/
/  Funcao para controlar o saldo do VT
@author     A.Shibao
@since      06/12/2016
@param		
@version    P12
@return      
@project 
@client    RedeDor   
/*/
//==========================================================================================  
User Function DorSaldVT() 

Local aSHSaldVt	 := {}
Local aSHVTD     := {}  

Local nPosSaldVt := 0
Local nPosVTD    := 0
Local nShPerc    := 0
 
// tabela para controle de saldo de VT
fCarrTab( @aSHSaldVt,"U10G", Nil)  

// % de desconto de VT diferenciado
fCarrTab( @aSHVTD,"U102", Nil)  

// verifico se existe a verba de desconto no movimento
If  abs(fBuscaPD(aCodFol[051,1])) > 0 
	
	// Verifico se existe registros na tabela de controle de saldo VT com as verba de base para a filial calculada
//	If ( nPosSaldVt := Ascan(aSHSaldVt,{ |x| x[1] == "U10G" .And. alltrim(x[2]) == alltrim(SRA->RA_FILIAL) } ) )  > 0  
	If ( nPosSaldVt := Ascan(aSHSaldVt,{ |x| x[1] == "U10G" } ) )  > 0  	
	    
		// verifico se existe a verba de base no movimento
		If !Empty(aSHSaldVt[nPosSaldVt,5]) .And. fBuscaPD(aSHSaldVt[nPosSaldVt,5]) > 0 
			
		    If fBuscaPD(aSHSaldVt[nPosSaldVt,5]) <> 0.01	
				If  abs(fBuscaPD(aCodFol[051,1])) > abs(fBuscaPD(aSHSaldVt[nPosSaldVt,5])) // ticket n° 8393638
					fDelPD(aCodFol[051,1]) // ticket n° 8393638
					fDelPD(aCodFol[052,1]) // ticket n° 8393638
					// pego o % diferenciado caso tenha, senao 6%
					//If ( nPosVTD := Ascan(aSHVTD,{ |x| x[1] == "U102" .And. alltrim(x[2]) == alltrim(SRA->RA_FILIAL) .And. alltrim(x[5]) == SRA->RA_SINDICA } ) ) > 0  	
					If ( nPosVTD := Ascan(aSHVTD,{ |x| x[1] == "U102" .And. alltrim(x[5]) == SRA->RA_SINDICA } ) ) > 0  	
						nShPerc := aSHVTD[nPosVTD,6] / 100
					Else
						nShPerc := 0.06		
					Endif 
					
					//monto o salario para comparacao
					nShSalario:= Round(nShPerc * SRA->RA_SALARIO, MsDecimais(1))
					
					//Regravo o menor valor
					If nShSalario < abs(fBuscaPD(aSHSaldVt[nPosSaldVt,5])) 
						fGeraVerba(acodfol[51,1],nShSalario,nShPerc,,,,,,,,.T.) 
						//regrava a verba de base de VT ( base informada - desc. Vt )
						fGeraVerba(acodfol[210,1],fBuscaPD(aSHSaldVt[nPosSaldVt,5]) - nShSalario ,,,,,,,,,.T.) 
					Endif
					
					// qdo o valor importado é menor que o desconto, regravo o valor importado no desconto.				
					If abs(fBuscaPD(aSHSaldVt[nPosSaldVt,5])) < nShSalario
						fGeraVerba(acodfol[51,1],abs(fBuscaPD(aSHSaldVt[nPosSaldVt,5])),nShPerc,,,,,,,,.T.) 
						//regrava a verba de base de VT ( base informada - desc. Vt )
						If fBuscaPD(aSHSaldVt[nPosSaldVt,5]) - nShSalario > 0
							fGeraVerba(acodfol[210,1],fBuscaPD(aSHSaldVt[nPosSaldVt,5]) - nShSalario ,,,,,,,,,.T.) 	
						Else
							fDelPD(aCodFol[210,1])
						Endif	
					Endif
				EndIf // ticket n° 8393638
		    Else
				fDelPD(aCodFol[051,1])
				fDelPD(aCodFol[052,1])
				fDelPD(aCodFol[210,1])				
		  Endif      
	
		Endif				   

	Endif	

Endif
	
Return("FIM")				 