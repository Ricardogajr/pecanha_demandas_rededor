//==========================================================================================
/*/
/  Ponto de Entrada para alterar o % de desconto do vale transporte conforme tabela espec u102
@author     A.Shibao
@since      23/08/16
@param		
@version    P12
@return      
@project                       
@client    RedeDor   
/*/
//==========================================================================================  
User Function GP210SAL()      

Local aShVT := {}

//Valida pelos parametros se essa empresa irá executar essas chamadas.
If !U_VALIDEMP()
	Return("FIM")
EndIf

fCarrTab( @aShVT,"U102" )
 
If 	(nPoSu102	:=	Ascan(aShVT,{|x| x[1] == "U102" .And. alltrim(x[2]) == ALLTRIM(SRA->RA_FILIAL) })) > 0 
	If Empty(aShVT[nPoSu102,5]) .Or. Empty(aShVT[nPoSu102,6])
     	Alert("Tabelas U102 - % Desc Vale Transporte não possui registros, favor verificar")
   	    Return
    Elseif SRA->RA_SINDICA == (aShVT[nPoSu102,5])
  		nPercentual:= (aShVT[nPoSu102,6])
	Endif     
Endif

Return("FIM")

