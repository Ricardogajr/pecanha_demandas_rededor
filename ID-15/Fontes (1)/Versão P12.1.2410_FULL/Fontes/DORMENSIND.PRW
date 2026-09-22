#INCLUDE "PROTHEUS.CH"
//==========================================================================================
/*/
Rotinas para regravar a mensalidade sindical conforme tabela U100
@author     A.Shibao
@since      23/08/16
@param		
@version    P12
@return      
@project                  
@client    RedeDor   
/*/
//==========================================================================================  
User Function DorMenSind()

Local cVerba    := aCodFol[720,1]
Local aShMSin   := {}

fCarrTab( @aShMSin,"U100", Nil )
 
If ((nPoSu004	:=	Ascan(aShMSin,{|x| x[1] == "U100" .And. x[6] == SRA->RA_CODFUNC })   ) > 0   .And. SRA->RA_SITFOLH <> "A" ) .Or. ((nPoSu004	:=	Ascan(aShMSin,{|x| x[1] == "U100" .And. x[6] == SRA->RA_CODFUNC })   ) > 0   .And. (nDPrgSalMa > 0 .Or. NDIASMAT > 0) ) 
	If Empty(aShMSin[nPoSu004,5]) .Or. Empty(aShMSin[nPoSu004,6]) .Or. Empty(aShMSin[nPoSu004,7])
     	Alert("Tabelas U100 não possui registros, favor verificar")
	    Return
	ElseIf SRA->RA_MENSIND == "1" .And. SRA->RA_SINDICA == aShMSin[nPoSu004,5]  .And.  SRA->RA_CODFUNC == aShMSin[nPoSu004,6]             
	    // verifico se o usuario nao informou a verba por motivo qualquer onde devo considerar o informado.
		If ! (( Ascan(aPd,{|X| X[1] == cVerba .And. X[9] <> "D" .And. X[7] == "I"}) > 0 ) )
			fGeraVerba(cVerba,aShMSin[nPoSu004,7],,,,,,,,,.T.)
		Endif
	Endif
Elseif SRA->RA_SITFOLH == "A" .And. abs(fBuscaPD(cVerba)) > 0
   fDelPD(cVerba)
Endif	
    
Return("FIM")
