// #########################################################################################
// Projeto: Monkey
// Modulo : Integração API
// Fonte  : MNKXFUN
// ---------+-------------------+-----------------------------------------------------------
// Data     | Autor             | Descricao
// ---------+-------------------+-----------------------------------------------------------
// 13/09/20 | Rafael Yera Barchi| Funções genéricas
// ---------+-------------------+-----------------------------------------------------------

#INCLUDE 	"PROTHEUS.CH"

#DEFINE 	cEOL			Chr(13) + Chr(10)


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} ADRetParc
//Query de seleção de registros
@author Rafael Yera Barchi
@since 13/09/2020
@version 1.00

@type function
/*/
//------------------------------------------------------------------------------------------
User Function ADRetParc(_cFilial, _cPrefixo, _cNum, _cFornece, _cLoja)

    Local   nParcelas   := 0
    Local   nRegs       := 0
    Local 	cSQL 		:= ""
    Local	cAliasTRB	:= GetNextAlias()
    Local   cLogDir		:= SuperGetMV("MK_LOGDIR", , "\log\")
    Local   cLogArq		:= "ADRetParc"


    cSQL := "          SELECT COUNT(*) PARCELAS " + cEOL
    cSQL += "            FROM " + RetSQLName("SE2") + " SE2 "
    If "MSSQL" $ Upper(AllTrim(TCGetDB()))
        cSQL += " (NOLOCK) " + cEOL
    Else
        cSQL += cEOL
    EndIf
    cSQL += "           WHERE E2_FILIAL = '" + _cFilial + "' " + cEOL
    cSQL += "             AND E2_PREFIXO = '" + _cPrefixo + "' " + cEOL
    cSQL += "             AND E2_NUM = '" + _cNum + "' " + cEOL
    cSQL += "             AND E2_FORNECE = '" + _cFornece + "' " + cEOL
    cSQL += "             AND E2_LOJA = '" + _cLoja + "' " + cEOL
    cSQL += "             AND D_E_L_E_T_ = ' ' " + cEOL

    MemoWrite(cLogDir + cLogArq + ".sql", cSQL)

    //	cSQL := ChangeQuery(cSQL)
    If Select(cAliasTRB) > 0
        (cAliasTRB)->(DBCloseArea())
    EndIf
    DBUseArea(.T., "TOPCONN", TCGenQry( , , cSQL), (cAliasTRB), .F., .T.)

    Count To nRegs

    (cAliasTRB)->(DBSelectArea(cAliasTRB))
    (cAliasTRB)->(DBGoTop())
    While !(cAliasTRB)->(EOF())
        nParcelas := (cAliasTRB)->PARCELAS
        (cAliasTRB)->(DBSkip())
    EndDo

    If Select(cAliasTRB) > 0
        (cAliasTRB)->(DBCloseArea())
    EndIf

Return nParcelas



//------------------------------------------------------------------------------------------
/*/{Protheus.doc} ADConvParc
//Query de seleção de registros
@author Rafael Yera Barchi
@since 13/09/2020
@version 1.00

@type function
/*/
//------------------------------------------------------------------------------------------
User Function ADConvParc(cParcela, nTipo)

    Local   xRet        := Nil
    Local   lAlfaNum    := SuperGetMV("MK_PARCMIS", , .F.)

    Default nTipo       := 1


    // Ambiente com parcelas com números e letras
    If lAlfaNum
        Do Case
            Case cParcela == "A"
                xRet := "10"
            Case cParcela == "B"
                xRet := "11"
            Case cParcela == "C"
                xRet := "12"
            Case cParcela == "D"
                xRet := "13"
            Case cParcela == "E"
                xRet := "14"
            Case cParcela == "F"
                xRet := "15"
            Case cParcela == "G"
                xRet := "16"
            Case cParcela == "H"
                xRet := "17"
            Case cParcela == "I"
                xRet := "18"
            Case cParcela == "J"
                xRet := "19"
            Case cParcela == "K"
                xRet := "20"
            Case cParcela == "L"
                xRet := "21"
            Case cParcela == "M"
                xRet := "22"
            Case cParcela == "N"
                xRet := "23"
            Case cParcela == "O"
                xRet := "24"
            Case cParcela == "P"
                xRet := "25"
            Case cParcela == "Q"
                xRet := "26"
            Case cParcela == "R"
                xRet := "27"
            Case cParcela == "S"
                xRet := "28"
            Case cParcela == "T"
                xRet := "29"
            Case cParcela == "U"
                xRet := "30"
            Case cParcela == "V"
                xRet := "31"
            Case cParcela == "W"
                xRet := "32"
            Case cParcela == "X"
                xRet := "33"
            Case cParcela == "Y"
                xRet := "34"
            Case cParcela == "Z"
                xRet := "35"
            OtherWise
                xRet := cParcela
        EndCase    
    Else
        If GetMV("MV_1DUP") == "A"
            Do Case
                Case cParcela == "A"
                    xRet := "1"
                Case cParcela == "B"
                    xRet := "2"
                Case cParcela == "C"
                    xRet := "3"
                Case cParcela == "D"
                    xRet := "4"
                Case cParcela == "E"
                    xRet := "5"
                Case cParcela == "F"
                    xRet := "6"
                Case cParcela == "G"
                    xRet := "7"
                Case cParcela == "H"
                    xRet := "8"
                Case cParcela == "I"
                    xRet := "9"
                Case cParcela == "J"
                    xRet := "10"
                Case cParcela == "K"
                    xRet := "11"
                Case cParcela == "L"
                    xRet := "12"
                Case cParcela == "M"
                    xRet := "13"
                Case cParcela == "N"
                    xRet := "14"
                Case cParcela == "O"
                    xRet := "15"
                Case cParcela == "P"
                    xRet := "16"
                Case cParcela == "Q"
                    xRet := "17"
                Case cParcela == "R"
                    xRet := "18"
                Case cParcela == "S"
                    xRet := "19"
                Case cParcela == "T"
                    xRet := "20"
                Case cParcela == "U"
                    xRet := "21"
                Case cParcela == "V"
                    xRet := "22"
                Case cParcela == "W"
                    xRet := "23"
                Case cParcela == "X"
                    xRet := "24"
                Case cParcela == "Y"
                    xRet := "25"
                Case cParcela == "Z"
                    xRet := "26"
                OtherWise
                    xRet := cParcela
            EndCase
        Else
            Do Case
                Case cParcela == "1" .Or. cParcela == "01" .Or. cParcela == "001"
                    xRet := "1"
                Case cParcela == "2" .Or. cParcela == "02" .Or. cParcela == "002"
                    xRet := "2"
                Case cParcela == "3" .Or. cParcela == "03" .Or. cParcela == "003"
                    xRet := "3"
                Case cParcela == "4" .Or. cParcela == "04" .Or. cParcela == "004"
                    xRet := "4"
                Case cParcela == "5" .Or. cParcela == "05" .Or. cParcela == "005"
                    xRet := "5"
                Case cParcela == "6" .Or. cParcela == "06" .Or. cParcela == "006"
                    xRet := "6"
                Case cParcela == "7" .Or. cParcela == "07" .Or. cParcela == "007"
                    xRet := "7"
                Case cParcela == "8" .Or. cParcela == "08" .Or. cParcela == "008"
                    xRet := "8"
                Case cParcela == "9" .Or. cParcela == "09" .Or. cParcela == "009"
                    xRet := "9"
                OtherWise
                    xRet := cParcela
            EndCase
        EndIf
    EndIf

    If nTipo == 2
        xRet := Val(xRet)
    EndIf

Return xRet



//------------------------------------------------------------------------------------------
/*/{Protheus.doc} MNKRetUsr
Função para validação de usuário da API

@author    Rafael Yera Barchi
@version   1.xx
@since     18/10/2018
/*/
//------------------------------------------------------------------------------------------
User Function MNKRetUsr(cHeader)

	Local 	cUserAPI 	:= ""
	Local 	cCodUser 	:= ""
	
	
	cUserAPI := StrTran(cHeader, "Basic ", "")
	cUserAPI := Decode64(cUserAPI)
	cUserAPI := StrTokArr(cUserAPI, ":")[1]
	PswOrder(2)
	If (PswSeek(cUserAPI, .T.))            
		cCodUser := PswId()
	EndIf
	
Return cCodUser



//------------------------------------------------------------------------------------------
/*/{Protheus.doc} MKPutSx1
Rotina que cria o grupo de perguntas - Original da Totvs - utilizada aqui pois descontinuou 
no Protheus 12

@author    Márcio Martins Pereira
@version   1.xx
@since     14/07/2021
/*/
//------------------------------------------------------------------------------------------

//User Function MKPutSx1(cGrupo,cOrdem,cPergunt,cPerSpa,cPerEng,cVar,;
//		cTipo ,nTamanho,nDecimal,nPresel,cGSC,cValid,;
//		cF3, cGrpSxg,cPyme,;
//		cVar01,cDef01,cDefSpa1,cDefEng1,cCnt01,;
//		cDef02,cDefSpa2,cDefEng2,;
//		cDef03,cDefSpa3,cDefEng3,;
//		cDef04,cDefSpa4,cDefEng4,;
//		cDef05,cDefSpa5,cDefEng5,;
//		aHelpPor,aHelpEng,aHelpSpa,cHelp)
//
//	LOCAL aArea := GetArea()
//	Local cKey
//	Local lPort := .f.
//	Local lSpa  := .f.
//	Local lIngl := .f.
//
//	cKey  := "P." + AllTrim( cGrupo ) + AllTrim( cOrdem ) + "."
//
//	cPyme    := Iif( cPyme 		== Nil, " ", cPyme		)
//	cF3      := Iif( cF3 		== NIl, " ", cF3		)
//	cGrpSxg  := Iif( cGrpSxg	== Nil, " ", cGrpSxg	)
//	cCnt01   := Iif( cCnt01		== Nil, "" , cCnt01 	)
//	cHelp	 := Iif( cHelp		== Nil, "" , cHelp		)
//
//	dbSelectArea( "SX1" )
//	dbSetOrder( 1 )
//
//	// Ajusta o tamanho do grupo. Ajuste emergencial para validação dos fontes.
//	// RFC - 15/03/2007
//	cGrupo := PadR( cGrupo , Len( SX1->X1_GRUPO ) , " " )
//
//	If !( DbSeek( cGrupo + cOrdem ))
//
//		cPergunt:= If(! "?" $ cPergunt .And. ! Empty(cPergunt),Alltrim(cPergunt)+" ?",cPergunt)
//		cPerSpa	:= If(! "?" $ cPerSpa  .And. ! Empty(cPerSpa) ,Alltrim(cPerSpa) +" ?",cPerSpa)
//		cPerEng	:= If(! "?" $ cPerEng  .And. ! Empty(cPerEng) ,Alltrim(cPerEng) +" ?",cPerEng)
//
//		Reclock( "SX1" , .T. )
//
//		Replace X1_GRUPO   With cGrupo
//		Replace X1_ORDEM   With cOrdem
//		Replace X1_PERGUNT With cPergunt
//		Replace X1_PERSPA  With cPerSpa
//		Replace X1_PERENG  With cPerEng
//		Replace X1_VARIAVL With cVar
//		Replace X1_TIPO    With cTipo
//		Replace X1_TAMANHO With nTamanho
//		Replace X1_DECIMAL With nDecimal
//		Replace X1_PRESEL  With nPresel
//		Replace X1_GSC     With cGSC
//		Replace X1_VALID   With cValid
//
//		Replace X1_VAR01   With cVar01
//
//		Replace X1_F3      With cF3
//		Replace X1_GRPSXG  With cGrpSxg
//
//		If Fieldpos("X1_PYME") > 0
//			If cPyme != Nil
//				Replace X1_PYME With cPyme
//			Endif
//		Endif
//
//		Replace X1_CNT01   With cCnt01
//		If cGSC == "C"			// Mult Escolha
//			Replace X1_DEF01   With cDef01
//			Replace X1_DEFSPA1 With cDefSpa1
//			Replace X1_DEFENG1 With cDefEng1
//
//			Replace X1_DEF02   With cDef02
//			Replace X1_DEFSPA2 With cDefSpa2
//			Replace X1_DEFENG2 With cDefEng2
//
//			Replace X1_DEF03   With cDef03
//			Replace X1_DEFSPA3 With cDefSpa3
//			Replace X1_DEFENG3 With cDefEng3
//
//			Replace X1_DEF04   With cDef04
//			Replace X1_DEFSPA4 With cDefSpa4
//			Replace X1_DEFENG4 With cDefEng4
//
//			Replace X1_DEF05   With cDef05
//			Replace X1_DEFSPA5 With cDefSpa5
//			Replace X1_DEFENG5 With cDefEng5
//		Endif
//
//		Replace X1_HELP  With cHelp
//
//		PutSX1Help(cKey,aHelpPor,aHelpEng,aHelpSpa)
//
//		MsUnlock()
//	Else
//
//		lPort := ! "?" $ X1_PERGUNT .And. ! Empty(SX1->X1_PERGUNT)
//		lSpa  := ! "?" $ X1_PERSPA  .And. ! Empty(SX1->X1_PERSPA)
//		lIngl := ! "?" $ X1_PERENG  .And. ! Empty(SX1->X1_PERENG)
//
//		If lPort .Or. lSpa .Or. lIngl
//			RecLock("SX1",.F.)
//			If lPort
//				SX1->X1_PERGUNT:= Alltrim(SX1->X1_PERGUNT)+" ?"
//			EndIf
//			If lSpa
//				SX1->X1_PERSPA := Alltrim(SX1->X1_PERSPA) +" ?"
//			EndIf
//			If lIngl
//				SX1->X1_PERENG := Alltrim(SX1->X1_PERENG) +" ?"
//			EndIf
//			SX1->(MsUnLock())
//		EndIf
//	Endif
//
//	RestArea( aArea )
//
//Return
