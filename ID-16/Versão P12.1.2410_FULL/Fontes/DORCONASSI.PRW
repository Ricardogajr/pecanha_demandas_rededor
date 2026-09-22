#INCLUDE "PROTHEUS.CH"
//==========================================================================================
/*/
Rotinas para regravar a contribuicao assistencial conforme tabela U101
@author     A.Shibao
@since      23/08/16
@param		
@version    P12
@return      
@project 
@client    RedeDor      
/*/
//==========================================================================================  
User Function DorConAssi()

Local cVerba    := aCodFol[69,1]
Local aShCAss   := {}
Local nSalM     := SRA->RA_SALARIO
Local cBase     := ""
Local nShPerc   := 0

fCarrTab( @aShCAss,"U101", Nil )
 
If ((nPoSu005	:=	Ascan(aShCAss,{|x| x[1] == "U101"})   ) > 0  .And. SRA->RA_SITFOLH <> "A" )  .Or. ( (nPoSu005	:=	Ascan(aShCAss,{|x| x[1] == "U101"})   ) > 0 .And. (nDPrgSalMa > 0 .Or. NDIASMAT > 0) )
	If Empty(aShCAss[nPoSu005,5]) .Or. Empty(aShCAss[nPoSu005,6]) .Or. Empty(aShCAss[nPoSu005,7])                                                                     
     	Alert("Tabelas U101 não possui registros, favor verificar")
	    Return
	ElseIf SRA->RA_ASSIST == "1" .And. SRA->RA_SINDICA == aShCAss[nPoSu005,5] 

			 For nShCont := nPoSu005 to len(aShCAss)
			 	If aShCAss[nShCont,5] == SRA->RA_SINDICA 
		         If nSalM > &(aShCAss[nShCont,6]) .And.  nSalM < &(aShCAss[nShCont,7])
		         	nShPerc := aShCAss[nShCont,8] / 100
		         	nShCont := len(aShCAss)
		         	cBase   := aShCAss[nShCont,9]
		         Endif
		        Endif 	 	
		     Next nShCont
		     
			 If Empty(nShPerc) .or. nShPerc == 0 
			 	Alert("Percentual nao cadastrado na tabela especifica U101")
			 	Return("FIM")
			 Endif 
			 
		 	 If Empty(cBase) .or. !( cBase $ "1/2" )
			 	Alert("Base para calculo nao cadastrado na tabela especifica U101")
			 	Return("FIM")
			 Endif	   	               
		     
		     // verifico se o usuario nao informou a verba por motivo qualquer onde devo considerar o informado.
			 If ! (( Ascan(aPd,{|X| X[1] == cVerba .And. X[9] <> "D" .And. X[7] == "I"}) > 0 ) )
			 	nShCalc:= Iif(cBase == "1",SRA->RA_SALARIO,VAL_SALMIN)  
			    nShCalc:= nShCalc * nShPerc
				fGeraVerba(cVerba,nShCalc,nShPerc,,,,,,,,.T.) 
			 Endif
	Endif	
	
Endif

Return("FIM") 

//==========================================================================================
/*/
Rotinas para executar o conteudo da tabela
@author     A.Shibao
@since      23/08/16
@param		
@version    P12
@return      
@project 
@client    RedeDor   
/*/
//==========================================================================================  
Static Function DorExecFr( cFormula )

	Local lRet
	
	Begin Sequence
	    cFormula := &(cFormula)
	    lRet := .T.
		Recover
	    lRet := .F.
	End Sequence

Return lRet