#INCLUDE "PROTHEUS.CH"
#INCLUDE 'TOPCONN.CH'   

************************
User function GP020LOK()
************************
// P10 e P12: ObrigatÃ³rio somente para dependentes maiores de 8 anos  
//--Mensagem para dependentes maiores que 30 (nessa hipotese impede registro do dependente)

Local aLinha	:= ParamIXB[1] 
Local aCampos	:= ParamIXB[2]       
Local nPosCIC	:= GdFieldPos("RB_CIC")  
Local nPosCod  := GdFieldPos("RB_COD")  

Private lRet   := .T.
Private _cAliasQry
 
cCIC := aLinha[nPosCIC]   
cCod := aLinha[nPosCOD]       
cMAT := SRA->RA_MAT

If Empty(Alltrim(strtran( strtran( cCIC, ".", " "), "-", " ")))
   //If U_Maior8(aLinha) 
      MsgStop("Favor preencher o para o Dependente")
      lRet := .F.
   // Endif 
Else 
    lRet := fPesqCPF()  
Endif

Return(lRet)  

****************************
User Function Maior8(aLinha)
****************************
Local nPosNasc	:= GdFieldPos("RB_DTNASC")  
Local nIdade := 0	
Local lRet   := .T.
nIdade	    := Year(dDataBase) - Year(aLinha[nPosNasc]) 
nIdade	    := IIF( ( Month( dDataBase )< Month( aLinha[nPosNasc] ) ), nIdade-1,nIdade)

if nIdade < 9	
   lRet := .F.
endif

Return (lRet)

//------------------------
Static Function fPesqCPF()
//------------------------

Local   _cQuery := "" 

_cQuery := " SELECT RB_COD AS RBCOD"                           + CRLF  
_cQuery += " FROM " + RetSqlName('SRB')                        + CRLF 
_cQuery += "     WHERE D_E_L_E_T_ <> '*' "                     + CRLF 
_cQuery += "        AND RB_FILIAL    =  '"  + xFilial( "SRB" ) + "' " + CRLF  
_cQuery += "        AND TRIM(RB_MAT) =  '"  + ALLTRIM(cMat)    + "' " + CRLF    
_cQuery += "        AND TRIM(RB_CIC) =  '"  + ALLTRIM(cCic)    + "' " + CRLF 

_cAliasQry := GetNextAlias()                                              

If Select(  _cAliasQry  ) > 0
  	( _cAliasQry )->( DbCloseArea() )
EndIf

TcQuery _cQuery New Alias _cAliasQry 
 
dbSelectArea( "_cAliasQry" )  

lRet := .T.   

If Inclui .and. Reccount( "_cAliasQry" ) > 0
   MsgStop("CPF já cadastrado para outro Dependente")   
   lRet := .F.
Endif
    
If lRet .and. Altera

   dbGotop()
   
   Do While !Eof()
      
      If cCod != _cAliasQry->RBCOD
 			 MsgStop("CPF já cadastrado para outro Dependente")   
          lRet := .F.   
          Exit   
      Endif
      
   	dbSkip() 
   Enddo

Endif  

If lRet
    If SRA->RA_CIC = cCIC
        MsgStop("CPF do Dependente igual ao do Titular")   
        lRet := .F.    
    Else 
    	  lRet := .T.
    Endif   
Endif 
      
dbCloseArea( "_cAliasQry" )   

Return( lRet )