#include "Protheus.ch"

/*/{Protheus.doc} MSLOGE5
    @Description Função para gravar os logs de usuário na tabela SE5.
    @type  Function
    @author Lucas Miranda
    @since 17/05/2024
    @version 2210
    /*/
User Function MSLOGE5(nOper)

	Local aAreaE5 := SE5->(GetArea())
	Local cUsrAlt := UsrFullName(__cUserId)

	Default nOper := 1 //Operação  1 - Inclui o LOG; 2 - Deleta

	If Empty(cUsrAlt)
		cUsrAlt := "RPC"
	EndIf

	If nOper == 1
		RecLock("SE5", .F. )
		SE5->E5_XLOGMOV  := cUsrAlt
		SE5->E5_XHORMOV  := TIME()
		SE5->E5_XDATMOV  := Date()
		SE5->(MsUnlock())
	Elseif nOper == 2
		RecLock("SE5", .F. )
		SE5->E5_XLOGALT := ""
		SE5->E5_XHORALT := ""
		SE5->E5_XDATALT := ctod("//")
		SE5->(MsUnLock())
	Else
		RecLock("SE5", .F. )
		SE5->E5_XLOGALT := cUsrAlt
		SE5->E5_XHORALT := Time()
		SE5->E5_XDATALT := Date()
		SE5->(MsUnLock())
	EndIf
	RestArea(aAreaE5)
Return
