#INCLUDE 'TOTVS.CH'
/*/{Protheus.doc} GetSm0

    Tratar retorno do SM0

    @type Function - User function
    @author Cleiton Genuino
    @since 12/05/2023
    @version 1.0
	@example
	u_GetSm0()
/*/
User Function GetSm0(cAEmpAnt,cAFilAnt,cCampo)
    Local cRet       := ''        as character
    Local aRet       := {}        as array
    Local aArea      := GetArea() as array
    Default cAEmpAnt := cEmpAnt
    Default cAFilAnt := cFilAnt
    Default cCampo   := ''

    IF u_fListSm0(@cCampo)
        aRet := FWSM0Util():GetSM0Data(cAEmpAnt,cAFilAnt,{cCampo})
        If len(aRet)> 0
            cRet := aRet[1][2]
        EndIf
    EndIf

    Restarea(aArea)

Return cRet
/*/{Protheus.doc} fListSm0

    Tratar retorno do SM0

    @type Function - User function
    @author Cleiton Genuino
    @since 12/05/2023
    @version 1.0
	@example
	u_fListSm0()
/*/
User Function fListSm0(cCampo)
    Local aSm0  := {}        as array
    Local lRet  := .F.       as logical
    Local aArea := GetArea() as array

    If !Empty(cCampo)

        cCampo := AllTrim(cCampo)

        AADD(aSm0,'M0_CODIGO')
        AADD(aSm0,'M0_CODFIL')
        AADD(aSm0,'M0_FILIAL')
        AADD(aSm0,'M0_NOME')
        AADD(aSm0,'M0_NOMECOM')
        AADD(aSm0,'M0_FULNAME')
        AADD(aSm0,'M0_TEL')
        AADD(aSm0,'M0_FAX')
        AADD(aSm0,'M0_EQUIP')
        AADD(aSm0,'M0_TPINSC')
        AADD(aSm0,'M0_CGC')
        AADD(aSm0,'M0_CEI')
        AADD(aSm0,'M0_INSC')
        AADD(aSm0,'M0_INSCM')
        AADD(aSm0,'M0_ENDENT')
        AADD(aSm0,'M0_COMPENT')
        AADD(aSm0,'M0_BAIRENT')
        AADD(aSm0,'M0_CIDENT')
        AADD(aSm0,'M0_ESTENT')
        AADD(aSm0,'M0_CEPENT')
        AADD(aSm0,'M0_CODMUN')
        AADD(aSm0,'M0_ENDCOB')
        AADD(aSm0,'M0_COMPCOB')
        AADD(aSm0,'M0_BAIRCOB')
        AADD(aSm0,'M0_CIDCOB')
        AADD(aSm0,'M0_ESTCOB')
        AADD(aSm0,'M0_CEPCOB')
        AADD(aSm0,'M0_PRODRUR')
        AADD(aSm0,'M0_FPAS')
        AADD(aSm0,'M0_NATJUR')
        AADD(aSm0,'M0_DTBASE')
        AADD(aSm0,'M0_CNAE')
        AADD(aSm0,'M0_ACTRAB')
        AADD(aSm0,'M0_NUMPROP')
        AADD(aSm0,'M0_MODEND')
        AADD(aSm0,'M0_MODINSC')
        AADD(aSm0,'M0_CAUSA')
        AADD(aSm0,'M0_INSCANT')
        AADD(aSm0,'M0_TPESTAB')
        AADD(aSm0,'M0_TEL_IMP')
        AADD(aSm0,'M0_FAX_IMP')
        AADD(aSm0,'M0_IMP_CON')
        AADD(aSm0,'M0_TEL_PO')
        AADD(aSm0,'M0_FAX_PO')
        AADD(aSm0,'M0_CODZOSE')
        AADD(aSm0,'M0_DESZOSE')
        AADD(aSm0,'M0_COD_ATV')
        AADD(aSm0,'M0_INS_SUF')
        AADD(aSm0,'M0_NIRE')
        AADD(aSm0,'M0_DTRE')
        AADD(aSm0,'M0_DSCCNA')
        AADD(aSm0,'M0_ASSPAT1')
        AADD(aSm0,'M0_ASSPAT2')
        AADD(aSm0,'M0_ASSPAT3')
        AADD(aSm0,'M0_RNTRC')
        AADD(aSm0,'M0_DTRNTRC')
        AADD(aSm0,'M0_SEQUENC')
        AADD(aSm0,'M0_DOCSEQ')
        AADD(aSm0,'M0_EMERGEN')
        AADD(aSm0,'M0_LIBMOD')
        AADD(aSm0,'M0_DTAUTOR')
        AADD(aSm0,'M0_EMPB2B')
        AADD(aSm0,'M0_CAIXA')
        AADD(aSm0,'M0_LICENSA')
        AADD(aSm0,'M0_CORPKEY')
        AADD(aSm0,'M0_CHKSUM')
        AADD(aSm0,'M0_DTVLD')
        AADD(aSm0,'M0_PSW')
        AADD(aSm0,'M0_CTPSW')
        AADD(aSm0,'M0_INTCTRL')
        AADD(aSm0,'M0_PSWSTRT')
        AADD(aSm0,'M0_CNES')
        AADD(aSm0,'M0_SIZEFIL')
        AADD(aSm0,'M0_LEIAUTE')
        AADD(aSm0,'M0_PICTURE')
        AADD(aSm0,'M0_STATUS')

        If aScan(aSm0, {|x| AllTrim(Upper(x)) == cCampo}) > 0
            lRet := .T.
        EndIf

    EndIf

    Restarea(aArea)

Return lRet
