#Include "totvs.ch"
/*{Protheus.doc} F1200401
Rotina para ajustar a liberação quando for executado pela rotina de medição automatizada
@author Sandro
@since 18/08/2017
@project MAN0000007423046_EF_004
*/
User Function F1200401()

    If IsInCallStack('U_F0100109') .OR. IsInCallStack('U_F1200709') .OR. IsInCallStack("U_F0100401")
        If CND->CND_ALCAPR == "B" 
            CND->(RecLock("CND", .F.))
            CND->CND_ALCAPR := "L"
            CND->(MsUnlock())
        EndIf
    EndIf
Return