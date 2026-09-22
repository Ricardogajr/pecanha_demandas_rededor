
#INCLUDE "PROTHEUS.CH"
//========================================================================================================================================
/*/
/  Funcao para calculo do VT, existem 3 casos :
/  TIPO 1 - EXTRA - Calculo do Vale Transporte que será pago via rotina de valores extras e NAO vai para o arquivo de compra alelo
/  TIPO 2 - FOLHA - Calculo do Vale Transporte padrao provento e desconto                 e NAO vai para o alelo
/  DIFERENTE DE 1 E 2 - Deleta a verba de Provento, mantem a verba de desconto            e VAI para o arquivo da alelo  
/  @author     A.Shibao                                                 
/  @since      08/09/16
/  @param		
/  @version    P12
/  @return      
/  @project 
/  @client    RedeDor   
/  @ adicionar ao roteiro da FOL
/  27.10.2017 -> Ajuste para nao ser calculada o ID 52 na rescisao.
//========================================================================================================================================*/  
User Function DorValeTr() 

Local aSHValTra	:= {}
Local nPosValTra:= 0 
Local nTabValTra:= 0 
Local nShSalario:= 0
Local cShCatFun := SRA->RA_CATFUNC 
Local cShProvVt := aCodFol[52,1]

fCarrTab( @aSHValTra,"U109", Nil,.T.)  

// Verifico se existe registros na tabela, para que seja deletado o provento a filial nao deve estar na tabela especifica.		   
If Len(aSHValTra) > 0 
//If If Len(aSHValTra) > 0  .And. ;
	If  !(( nPosValTra := Ascan(aSHValTra,{ |x| alltrim(x[1]) == "U109" .And. alltrim(x[2]) == alltrim(SRA->RA_FILIAL) .And.  (alltrim(x[5]) $ "1/2")  }))  > 0)  .And. ;
         fBuscaPD(cShProvVt) > 0

		// Deleta a verba de Provento de VT 
		fDelPD(cShProvVt)					 
    EndIf                
Else
	fDelPD(cShProvVt)    
Endif

// Solicitado ajuste na rotina para nunca gerar o ID 0052 ( VT ) na rescisao.
If cRot == "RES"
	If (nPosRes:= Ascan(APD,{ |x| x[1] == cShProvVt .And. x[7] <> "I" })) > 0
		aPd[nPosRes,4]:=0
		aPd[nPosRes,5]:=0
		aPd[nPosRes,9]:="D"
	Endif
Endif	
	
Return()				 