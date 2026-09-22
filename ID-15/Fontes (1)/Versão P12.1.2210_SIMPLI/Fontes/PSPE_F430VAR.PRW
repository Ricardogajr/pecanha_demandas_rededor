#INCLUDE "rwmake.ch"
#include "protheus.ch"

Static _lIncSEU := .T.

/*
{Protheus.doc} PE_F430VAR
Ponto de entrada para manipular valores dos títulos antes da baixa pela rotina de retorno de CNAB
@Author     Ramon Teodoro e Silva
@Alteracao  ticket #16041365
@Since      16/12/2020     
@Version    P12.27
@Return
*/
User Function F430VAR

Local lRet          := .T.
Local aArea         := GetArea()
Local aParam        := Paramixb
Local cFsFincond    := AllTrim(SuperGetMV("FS_FINCOND",,""))

If !Empty(aParam[1][1])
    dbSelectArea("SE2")
    SE2->(DbSetOrder(11))
    If SE2->(DbSeek(xFilial("SE2")+aParam[1][1]))
		If (Alltrim(SE2->E2_FORMPAG) $ cFsFincond) .AND. (SE2->E2_SALDO > 0) //Início Thais Paiva - 16597315
			RecLock("SE2", .F.)
			If Alltrim(SE2->E2_PORTADO) = "341"
                nVlAcresc :=  (aParam[1][9] - (SE2->E2_MULTA +SE2->E2_JUROS))
                SE2->E2_ACRESC  := nVlAcresc //aParam[1][9]
                SE2->E2_SDACRES := nVlAcresc //aParam[1][9]
            Else
                SE2->E2_ACRESC  := aParam[1][9]
				SE2->E2_SDACRES := aParam[1][9]
			EndIf
            SE2->E2_DECRESC := (aParam[1][6] + aParam[1][7]) //Desconto + Abatimento
			SE2->E2_SDDECRE := (aParam[1][6] + aParam[1][7]) //Desconto + Abatimento
			SE2->(MsUnlock())
			SE2->(Dbcommit())     
		Endif //Fim Thais Paiva - 16597315
        If SE2->E2_SALDO <=0
            U__GrvStatic(.F.)
        else
            U__GrvStatic(.T.)    
        endif
    Endif
EndIf

RestArea(aArea)
Return lRet
 
User function _GrvStatic(lOper)
    _lIncSEU := lOper
Return

User function _RetStatic()
return(_lIncSEU)


