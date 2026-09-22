#INCLUDE "FWMVCDEF.CH"
#INCLUDE "Protheus.ch"
#include "fileio.ch"

//-------------------------------------------------------------------
/*/{Protheus.doc} RDCAR03
description Rotina responsável por Atualizar os campos XUSRIN e XUSRAL.
@author  Ricardo Junior	
@since   01/03/2021
@version 1.0
/*/
//-------------------------------------------------------------------
User function RDCAR03()
    RpcSetEnv("01", "04L10001")
    RpcSetType(3)
    
    oProcess := MsNewProcess():New({|| Atualiza(oProcess) }, "Processando...", "Aguarde...", .T.)
    oProcess:Activate()
    
    RpcClearEnv()
Return 

static function Atualiza(oProcess)

    Local aLista    := {"CVD","CVE","CVF","FIL","SE4","P32","SBZ","SF4","CTT","CTS","CTD","SEJ","SEB","LHT","SNG","CCQ"}
    Local cTime     := DToS(Date())+Space(1)+Time()
    Local aCampos   := {}
    Local nX        := 0
    Local nY        := 0
    
    oProcess:SetRegua1(Len(aLista))
    for nX := 01 To Len(aLista)
        cAlias := aLista[nX]
        
        aCampos := getCampos(cAlias)
        oProcess:IncRegua1("Processando a tabela [" + cAlias + "]")
        oProcess:SetRegua2(Len(aCampos))
        For nY := 01 To Len(aCampos)
            oProcess:IncRegua2("Atualizando campos em branco... [ " + aCampos[nY] +"]")
            cQuery := "UPDATE " + RetSqlName(cAlias) + " SET "+ aCampos[nY] + " = '" + cTime + "' WHERE " + aCampos[nY] + " = ' ' "
            cTcSql := TCSQLExec( cQuery )
        Next nY
    next nX

return

Static function getCampos(cAlias)
    Local aCampos := {}
    Local aArea := GetArea()
    If SubStr(cAlias,1,1) == "S"
        aAdd( aCampos, SubStr(cAlias,2,2) + "_XUSRIN")
        aAdd( aCampos, SubStr(cAlias,2,2) + "_XUSRAL")        
    Else
        aAdd(aCampos, cAlias +  "_XUSRIN")
        aAdd(aCampos, cAlias +  "_XUSRAL")
    Endif
    RestArea(aArea)
Return aCampos
