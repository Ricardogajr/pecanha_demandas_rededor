#Include 'PROTHEUS.CH'
#Include 'PARMTYPE.CH' 
//-------------------------------------------------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} AE_GRDESP
Ponto de entrada após criação da prestação de conta avulsa para possibilitar aprovação de uma despesa avulsa.
@author Reinaldo Dias
@since 07/06/2018
@version undefined
/*/
//-------------------------------------------------------------------------------------------------------------------------------------------------------------
User Function AE_GRDESP()
Local aArea     := GetArea()

RecLock("LHP",.F.)
LHP->LHP_HORAID := _cVooS
LHP->LHP_HORAVT := _cVooC
LHP->LHP_FLAG   := "I"
LHP->LHP_FLAG1  := "M"
LHP->LHP_STATUS := "1"
LHP->LHP_VALORR := _nReembo
LHP->LHP_XUSINC := __cUserID
LHP->(MsUnlock())

RecLock("LHQ",.F.)
LHQ->LHQ_USRINC := __cUserID
LHQ->(MsUnlock())


RestArea(aArea)                                             

Return