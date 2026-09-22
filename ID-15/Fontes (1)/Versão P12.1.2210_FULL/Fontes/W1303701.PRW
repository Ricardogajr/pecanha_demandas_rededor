#Include "Protheus.ch"
#Include "APWEBSRV.CH"

//Filial-Doc-Serie-Fornece-Loja
WsStruct CabecalhoDocumentoEntrada
    WSData cFilialDoc   As String
    WSData cDoc         As String
    WSData cSerie       As String
    WSData cFornecedor  As String
    WSData cLoja        As String
EndWsStruct

/*/{Protheus.doc} W1303701
Serviço para inclusão e deleção de nota fiscal de entrada com mês fechado.

@project    MAN0000007423048_EF_037
@type       service
@author     Rafael Riego
@since      10/05/2018
@version    12.1.7
/*/
WSService W1303701 Description "WebService para integrar as Notas Fiscais devolvidas através dos Fronts para meses já fechados dentro do Protheus"

    WSData cResposta    As String
    WSData cData        As String
    WSData oCabDocEnt   As CabecalhoDocumentoEntrada
    WSData cDocNum      As String

    WSMethod UpSertDocDev   Description "Inclui uma Nota Fiscal de Entrada"
    WSMethod DelDocDev      Description "Exclui uma Nota Fiscal de Entrada"

EndWSService
    /*/{Protheus.doc} UpSertDocDev
    Inclui a Nota Fiscal de Entrada.

    @project    MAN0000007423048_EF_037
    @type       method
    @author     Rafael Riego
    @since      10/05/2018
    @version    12.1.7
    /*/
    WSMethod UpSertDocDev WSReceive oCabDocEnt, cData, cDocNum WSSend cResposta WSService W1303701

        Local cNovIdInt := ""
        Local cRetorno  := ""

        Local nRecLog   := 0

        Local oDocEnt   := Nil

        oDocEnt := ::oCabDocEnt

        Begin WSMethod
            If U_F1303707(@oDocEnt, ::cData, @cNovIdInt, @nRecLog, @cRetorno, 1)
                cRetorno := U_F1303704("U_F1303701", oDocEnt, ::cData, cNovIdInt, nRecLog, cEmpAnt, cFilAnt, ::cDocNum)//cRotina, oDocEnt, cData, cNovIdInt, nRecLog, cEmpLog, cFilLog)
            EndIf

            If !(Empty(cRetorno))
                ::cResposta := cRetorno
            Else
                ::cResposta := "OK| Processo efetuado com sucesso."
            EndIf
        End WSMethod

    Return .T.
 
 

    /*/{Protheus.doc} DelDocDev
    Exclui a Nota Fiscal de Entrada.

    @project    MAN0000007423048_EF_037
    @type       method
    @author     Rafael Riego
    @since      10/05/2018
    @version    12.1.7
    /*/
    WSMethod DelDocDev WSReceive oCabDocEnt, cDocNum WSSend cResposta WSService W1303701

        Local cNovIdInt := ""
        Local cRetorno  := ""

        Local nRecLog   := 0

        Local oDocEnt   := Nil

        oDocEnt := ::oCabDocEnt

        Begin WSMethod
            If U_F1303707(@oDocEnt,, @cNovIdInt, @nRecLog, @cRetorno, 2)
                cRetorno := U_F1303704("U_F1303702", oDocEnt,, cNovIdInt, nRecLog, cEmpAnt, cFilAnt, ::cDocNum)
            EndIf

            If !(Empty(cRetorno))
                ::cResposta := cRetorno
            Else
                ::cResposta := "OK| Processo efetuado com sucesso."
            EndIf
        End WSMethod

        Return .T.

    