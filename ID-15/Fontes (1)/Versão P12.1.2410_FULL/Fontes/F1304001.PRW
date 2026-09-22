#Include "Protheus.ch"

/*/{Protheus.doc} F1304001
Exclui a Nota Fiscal original.

@project    MAN0000007423048_EF_040
@@type      User Function 
@author     Nairan Alves Silva
@since      02/05/2018
@version    12.1.7
@param      nRecSF1, numeric, recno do cabeçalho da nota fiscal de entrada
@param      cNovIdInt, character, id da integração da exclusão/devolução
@return     aItens, itens da nota fiscal de entrada
/*/
User Function F1304001(nRecSF1, cNovIdInt, dData)

    Local aArea     := {}
    Local aItens    := {}
    Local aLog      := {} 
    Local aNota     := {}

    Local cChaveSF1 := ""
    Local cErro     := ""

    Local dDataBkp  := CToD("  /  /    ")

    Local lOk      := .T.

    Local nErro     := 0
    
    Local aPergMTA := {} // ticket n° 10631343
	Local nMta1 := GETMV("FS_MTA1") // ticket n° 10631343
	Local nMta2 := GETMV("FS_MTA2") // ticket n° 10631343

    Private lMsErroAuto     := .F.

    Default cNovIdInt   := ""
    Default nRecSF1     := 0
    Default dData       := CToD("  /  /    ")

    aArea := {GetArea(), SF1->(GetArea()), SD1->(GetArea())}

    If !(Empty(nRecSF1))
        SF1->(DbGoTo(nRecSF1))
    Else
        nRecSF1 := SF1->(Recno())
    EndIf

    //Grava Novo id de Integração na nota antes de deletá-la
    RecLock("SF1", .F.)
    SF1->F1_XIDEXNF := cNovIdInt
    SF1->(MsUnlock())

    cChaveSF1 := FwXFilial("SD1") + SF1->F1_DOC + SF1->F1_SERIE + SF1->F1_FORNECE + SF1->F1_LOJA

    SD1->(DbSetOrder(1))
    If SD1->(DbSeek(cChaveSF1))
        While SD1->D1_FILIAL + SD1->D1_DOC + SD1->D1_SERIE + SD1->D1_FORNECE +SD1->D1_LOJA == cChaveSF1
            //Grava Id de integração nos itens da nota
            RecLock("SD1", .F.)
            SD1->D1_XIDEXNF := cNovIdInt
            SD1->(MsUnlock())
            AAdd(aItens, {SD1->D1_COD, SD1->D1_QUANT, SD1->D1_LOCAL, SD1->D1_CC, SD1->D1_DTDIGIT, SD1->D1_CUSTO, SD1->D1_PEDIDO, SD1->D1_ITEMPC})
            SD1->(DbSkip())
        End
    EndIf

    //F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA+F1_FORMUL
    AAdd(aNota, {"F1_FILIAL",   SF1->F1_FILIAL,     NIL})
    AAdd(aNota, {"F1_DOC",      SF1->F1_DOC,        NIL})
    AAdd(aNota, {"F1_SERIE",    SF1->F1_SERIE,      NIL})
    AAdd(aNota, {"F1_FORNECE",  SF1->F1_FORNECE,    NIL})
    AAdd(aNota, {"F1_LOJA",     SF1->F1_LOJA,       NIL})
    AAdd(aNota, {"F1_FORMUL",   SF1->F1_FORMUL,     NIL})

    dDataBkp    := dDataBase
    dDataBase   := dData
    
    aAdd(aPergMTA, {"MV_PAR01", nMta1}) // Mostra Lanc Contábeis? 1 = Sim, 2 = Não  // ticket n° 10631343
    aAdd(aPergMTA, {"MV_PAR02", nMta2}) // Aglut Lançamentos?     1 = Sim, 2 = Não  // ticket n° 10631343
				
    MsExecAuto({|nota, itens, operacao, perg| MATA103(nota, itens, operacao,,,,perg,,,,)}, aNota, {}, 5, aPergMTA) // ticket n° 10631343
    //MsExecAuto({|nota, itens, operacao| MATA103(nota, itens, operacao)}, aNota, {}, 5)

    dDataBase := dDataBkp

    If lMsErroAuto
        cErro += "INCONSISTENCIA DE ROTINA AUTOMATICA - EXCLUSÃO DE Nota Fiscal | " + CRLF
        aLog := GetAutoGRLog()
        For nErro := 1 To Len(aLog)
            cErro += aLog[nErro] + CRLF
        Next nErro
        lOk := .F.
        U_F1303703(cErro, lOk)
    EndIf

    AEval(aArea, {|area| RestArea(area)})

    If lOk
        FwFreeObj(aNota)
        aNota := Nil
        aNota := {}

        //Força o posicionamento na nota deletada
        SF1->(DbGoTo(nRecSF1))
        AAdd(aNota, SF1->F1_FILIAL)
        AAdd(aNota, SF1->F1_DOC)
        AAdd(aNota, SF1->F1_SERIE)
        AAdd(aNota, SF1->F1_FORNECE)
        AAdd(aNota, SF1->F1_LOJA)
        AAdd(aNota, SF1->F1_FORMUL)

        If ExistBlock("F13040I")
            ExecBlock("F13040I", .F., .F., {aNota, aItens})
        EndIf
    EndIf

    FwFreeObj(aNota)
    FwFreeObj(aItens)
    aNota := Nil
    aItens := Nil

Return aItens
