#INCLUDE "PROTHEUS.CH"


//MSLP001 - Fonte para LP customizada.
//Dev - Lucas Miranda de Aguiar
//Data - 13/05/2024

User Function MSLP001()

	Local cProds := GetNewPar("FS_MSLP001","TST123456789")
	Local nx := 0
    Local cChaveD1 := SE2->(E2_FILIAL+E2_NUM+E2_PREFIXO+E2_FORNECE+E2_LOJA)
    Local lAchou := .F.


    
	DbSelectArea("SD1")
	SD1->(DbSetOrder(1))

	If SD1->(DbSeek(cChaveD1))
        While (!(SD1->(EOF())) .And. AllTrim(SD1->(D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA)) == AllTrim(cChaveD1))
            If ";"+AllTrim(SD1->D1_COD) +";" $ cProds
               lAchou := .T.
               Exit
            EndIf
        SD1->(DbSkip())
        EndDo
	EndIf


Return lAchou
