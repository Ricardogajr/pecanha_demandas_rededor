#INCLUDE "Protheus.ch"

User Function F1600201

    Local aSay    := {}
    Local aButton := {}
    Local lOk     := .F.
    
    Private lEnd := .F.
    Private oProcess

    AAdd( aSay, "Esta rotina tem como objetivo a geração de dados para o cadastro de: "                     )
    AAdd( aSay, "                        Tratamento Exclusivo por Filial (P17)."                            )
    AAdd( aSay, ""                                                                                          )
    AAdd( aSay, "ATENÇÃO!"                                                                                  )
    AAdd( aSay, "A rotina pode ser demorada pois irá executar a verificação para todos os produtos e para " )
    AAdd( aSay, "todas as filiais que tiverem o parâmetro FS_REPLP17 = S garantindo que todosos produtos"   )
    AAdd( aSay, "tenham os dados exclusivos sem sobrepor os dados que já existirem."                        )

    aAdd( aButton, { 1, .T., {|| lOk := .T., FechaBatch() } } )
    aAdd( aButton, { 2, .T., {|| lOk := .F., FechaBatch() } } )

    FormBatch( "Geração de Tratamento Exclusivo por Filial.", aSay, aButton )

    If lOk
        oProcess := MsNewProcess():New( { | lEnd | MProcP17( @lEnd ) }, "Atualizando", "Aguarde, atualizando ...", .F. )
        oProcess:Activate()
    EndIf
    
Return


Static Function MProcP17

    Local aAreaSM0  := SM0->(GetArea())
    Local aFilP17   := {}
    Local nProdTot  := 0
    Local cProdTot  := ""
    Local nProdProc := 0
    Local nFilProc  := 0
    Local nFilTot   := 0

    If Select("P17") == 0 
        ChkFile("P17")
    EndIf
    If Select("SB1") == 0 
        ChkFile("SB1")
    EndIf

    oProcess:SetRegua1( nProdTot := ContaProduto() )
    cProdTot := AllTrim(Str(nProdTot))

    SM0->(DbSetOrder(1))
    SM0->(MsSeek(cEmpAnt))
    
    While SM0->( !Eof() .And. M0_CODIGO == cEmpAnt )
        If GETMVCUS(SM0->M0_CODFIL ) == "S"
            AAdd(aFilP17, { SM0->M0_CODFIL, SM0->M0_FILIAL, 0 } )
        EndIf
        SM0->(DbSkip())
    EndDo

    oProcess:SetRegua2( ( nFilTot := Len(aFilP17) ) * nProdTot )

    P17->(DbSetOrder(1))

    DbSelectArea("SB1")
    SB1->(DbGoTop())

    Do While SB1->(!Eof())
        nProdProc++
        oProcess:IncRegua1("Processando produto [" + SB1->B1_COD + "] - " + AllTrim(Str(nProdProc)) + "/" + cProdTot )
        For nFilProc := 1 To nFilTot
            oProcess:IncRegua2("Processando Filial " + aFilP17[nFilProc][2] )
            If !P17->(DbSeek(XFilial("P17")+SB1->B1_COD+aFilP17[nFilProc][1]))
                U_F0702405(aFilP17[nFilProc][1])
                aFilP17[nFilProc][3]++
            EndIf
        Next
        SB1->(DbSkip())
    EndDo

    RestArea(aAreaSM0)

    P17Result(aFilP17,AllTrim(Str(nProdProc)) + "/" + cProdTot)

Return

Static Function ContaProduto()
    
    Local cQuery   := ""
    Local cAlsQry  := GetNextAlias()
    Local nQtdProd := 0

    cQuery := "SELECT COUNT(1) QTDPROD " + CRLF
    cQuery += "FROM " + RetSqlName("SB1") + " SB1 " + CRLF
    cQuery += "WHERE " + CRLF
    cQuery += "  SB1.B1_FILIAL = '" + XFilial("SB1") + "' AND " + CRLF
    cQuery += "  SB1.D_E_L_E_T_ = ' ' " + CRLF
    cQuery := ChangeQuery(cQuery)
    dbUseArea(.T., "TOPCONN", TcGenQry(, ,cQuery), cAlsQry, .T., .T.)

    nQtdProd := (cAlsQry)->QTDPROD

    (cAlsQry)->(DbCloseArea())

Return nQtdProd

/*{Protheus.doc} P17Result
Exibe tela de resultado de processamento por Filial
@param aMsgErr Vetor de mensgens com mensagem, detalhe
@param cMsg Subtítulo da mensagem de erro.
*/
Static Function P17Result(aFilproc,cQtdProd)

	Local oDlgEsp
	Local oLbxEsp
	Local cLbx    := ''
	
	DEFINE MSDIALOG oDlgEsp TITLE "Resumo do processamento: Produtos processados " + cQtdProd FROM 00,00 TO 370,769 PIXEL
		@ 05,01 LISTBOX oLbxEsp VAR cLbx FIELDS HEADER "Filial","Descrição","Qtd.Itens Incluidos" SIZE 383,142 OF oDlgEsp PIXEL
		oLbxEsp:SetArray( aFilproc )
		oLbxEsp:bLine	:= { || { aFilproc[ oLbxEsp:nAT, 1 ], aFilproc[ oLbxEsp:nAT, 2 ], aFilproc[ oLbxEsp:nAT, 3 ] } }
		@ 160, 340 BUTTON oBut PROMPT "Sair" SIZE 037, 012 OF oDlgEsp PIXEL ACTION oDlgEsp:End()
	ACTIVATE MSDIALOG oDlgEsp CENTERED

Return
Static Function GETMVCUS(cFilCod)

Return SuperGetMV("FS_REPLP17", .F., "N", cFilCod )
