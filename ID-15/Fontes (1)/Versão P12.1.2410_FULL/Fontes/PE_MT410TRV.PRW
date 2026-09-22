/*/{Protheus.doc} ChkFile
Ponto de Entrada após o MSUnLock.
@type User Function
@author nairan.silva
@since 01/11/2016
@version 12.7
@return True
@project	MAN000000463801_EF_001
@project	MAN0000007423040_EF_001,MAN0000007423040_EF_002,
@project	MAN0000007423040_EF_003,MAN0000007423040_EF_005,MAN0000007423040_EF_007
/*/
#INCLUDE "PROTHEUS.CH" 

User Function MT410TRV() 
Local cCliForn := ParamIXB[1] // Codigo do cliente/fornecedor 
Local cLoja := ParamIXB[2] // Loja 
Local cTipo := ParamIXB[3] // C=Cliente(SA1) - F=Fornecedor(SA2) 
Local aRet := Array(4) 
Local lTravaSA1 := .F. // Desliga trava da tabela SA1 
Local lTravaSA2 := .F. // Desliga trava da tabela SA2 
Local lTravaSB2 := .F. // Desliga trava da tabela SB2 

Local aRet[1] := lTravaSA1 
Local aRet[2] := lTravaSA2 
Local aRet[3] := lTravaSB2 
        
If IsInCallStack('U_F0703202')
            
	lTravaSA1 := .T. // Desliga trava da tabela SA1 
	lTravaSA2 := .T. // Desliga trava da tabela SA2 
	lTravaSB2 := .T. // Desliga trava da tabela SB2 
	
	aRet[1] := lTravaSA1 
	aRet[2] := lTravaSA2 
	aRet[3] := lTravaSB2 
	
EndIF

Return(aRet)