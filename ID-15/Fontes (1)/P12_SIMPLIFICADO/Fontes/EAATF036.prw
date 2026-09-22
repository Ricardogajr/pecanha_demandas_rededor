#INCLUDE "Protheus.ch"

User Function EAATF036(cBase,cNumNF,cSerieNf)
Local aArea := GetArea()
//Local cBase := "0000000005"
Local cItem := "0001"
Local cTipo := "01"
Local cTpSaldo := "1"
Local cBaixa := "0"
Local nQtdAtu := 1
Local nQtdBaixa := 1

Local cMetDepr := GetMV('MV_ATFDPBX')
Local nValNF := 0

Local aCab := {}
Local aAtivo := {}
Local aParam := {}
Local lRet   := .T.

Private lMsErroAuto := .F.
Private lMsHelpAuto := .T.
Private cBkpUldepr  := GetMv("MV_ULTDEPR")
Default cMotivo := "22"
Default cNumNF := ""
Default cSerieNF := ""

aCab := { {"FN6_FILIAL" ,XFilial("FN6") ,NIL},;
{"FN6_CBASE" ,cBase ,NIL},;
{"FN6_CITEM" ,cItem ,NIL},;
{"FN6_MOTIVO" ,cMotivo ,NIL},;
{"FN6_BAIXA" ,100 ,NIL},;
{"FN6_QTDBX" ,nQtdBaixa ,NIL},;
{"FN6_DTBAIX" ,dDatabase ,NIL},;
{"FN6_DEPREC" ,cMetDepr ,NIL}}

aAtivo := {{"N3_FILIAL" ,XFilial("SN3") ,NIL},;
{"N3_CBASE" ,cBase ,NIL},;
{"N3_ITEM" ,cItem ,NIL},;
{"N3_TIPO" ,cTipo ,NIL},;
{"N3_BAIXA" ,cBaixa ,NIL},;
{"N3_TPSALDO" ,cTpSaldo ,NIL}}

Begin Transaction
MsExecAuto({|a,b,c,d,e,f|ATFA036(a,b,c,d,e,f)},aCab,aAtivo,3,,.T./*lBaixaTodos*/,aParam)
If lMsErroAuto
    MostraErro()
    DisarmTransaction()
    lRet := .F.
EndIf
End Transaction

RestArea(aArea)

Return(lRet)
