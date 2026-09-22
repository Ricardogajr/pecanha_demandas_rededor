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
User Function ChkFile()

	Local cNomAlias    := PARAMIXB[2]
    //Local cTbCaptura := GetNewPar("FS_XTABCPN","SB1;")
 
    //If cNomAlias $ cTbCaptura
    If FwIsInCallStack("U_xKPTMntLog") .OR.;
        FwIsInCallStack("U_xKPTExcAll") .OR. ;
        FwIsInCallStack("U_xKPTOutExc") .OR. ;
        FwIsInCallStack("U_xKPTOSC7") .OR. ;
        FwIsInCallStack("U_xKPTOKT0") .OR. ;
        FwIsInCallStack("U_xKPTOSM0") .OR. ;
        FwIsInCallStack("U_xKPTOSF4") .OR. ;
        FwIsInCallStack("U_xKPTOSED") .OR. ;
        FwIsInCallStack("U_xKPTOSE4") .OR. ;
        FwIsInCallStack("U_xKPTOSB1") .OR. ;
        FwIsInCallStack("U_xKPTOSA5") .OR. ;
        FwIsInCallStack("U_xKPTOCTT") .OR. ;
        FwIsInCallStack("U_xKPTOP02") .OR. ;
        FwIsInCallStack("U_xKPTOP11") .OR. ;
        FwIsInCallStack("U_xKPTOP13")
        Return .T.
    EndIf
    //EndIf
 
    U_F1400101(/*cTabela,*/cNomAlias)
 
    //U_F0400106(/*cTabela,*/cNomAlias)
 
    //U_F0600106(/*cTabela,*/cNomAlias)

Return .T.
