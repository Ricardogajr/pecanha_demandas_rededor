#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"

//-------------------------------------------------------------------
/*{Protheus.doc} 
Função para controlar os parâmetros de data do schedule CTBAFIN  

@author Ramon Teodoro
@since 19/08/2025	
@version 1.0
/*/
//-------------------------------------------------------------------

User Function Dt_ctbpar(cPar)

Local dRet      := date()
Local nDiasAnt  := 0 

nDiasAnt := GetNewPar("FS_DANTCT", 5)

If cPar == "1"
    dRet := DaySub(ddatabase, nDiasAnt)
Else
    dRet := ddatabase
EndIf

Return dRet 
