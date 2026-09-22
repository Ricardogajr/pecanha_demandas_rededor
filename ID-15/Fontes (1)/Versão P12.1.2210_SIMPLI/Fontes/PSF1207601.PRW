#Include "Protheus.ch"

/*/{Protheus.doc} F1207601
Rotina desenvolvida para Exibir a Alçada de aprovação do documento
Esta rotina é executada a partir do ponto de entrada MTA094RO.

@Project    MAN0000007423048_ID_076
@Author     Alceu Pereira
@Since      18/04/2019
@Version    12.1.17
@Return
/*/
User Function F1207601()

    Local aArea     := {}
    Local aBrowse   := {}

    Local cAliasTMP := GetNextAlias()
    Local cRespons  := ""
    Local cStatus   := ""
    Local cTipo     := ""
    Local cNumero   := ""

    Local cNumDoc := SCR->CR_NUM
    Local cTipo   := SCR->CR_TIPO 

    aArea   := {GetArea()}

    BeginSQL alias cAliasTMP

        SELECT 
            SCR.CR_XNOME,
            SCR.CR_NIVEL, 
            SCR.CR_STATUS, 
            SCR.CR_APROV, 
            SCR.CR_TIPO, 
            SCR.CR_USER
        FROM 
            %table:SCR% SCR
        WHERE
            SCR.CR_FILIAL = %exp:FwXFilial("SCR")% AND 
            SCR.CR_NUM    = %exp:cNumDoc%          AND 
            SCR.CR_TIPO   = %exp:cTipo%            AND 
            SCR.%notDel%                           
        ORDER BY 
            SCR.CR_FILIAL, 
            SCR.CR_NUM, 
            SCR.CR_TIPO, 
            SCR.CR_NIVEL
    EndSql

    If (cAliasTMP)->(!(EoF()))
        If (cAliasTMP)->CR_TIPO == "IP"
            cTipo := "ITEM PEDIDO"
        ElseIf (cAliasTMP)->CR_TIPO == "PC"
            cTipo := "PEDIDO     "
        ElseIf (cAliasTMP)->CR_TIPO == "SC"
            cTipo := "SOL. COMPRA"
        ElseIf (cAliasTMP)->CR_TIPO == "NF"
            cTipo := "NOTA FISCAL"
        ElseIf (cAliasTMP)->CR_TIPO == "SP"
            cTipo := "SOL. PAGTO"
        ElseIf (cAliasTMP)->CR_TIPO == "AE"
            cTipo := "AUT. ENTREGA"
        ElseIf (cAliasTMP)->CR_TIPO == "SA"
            cTipo := "SOL. ADIANT."
        ElseIf (cAliasTMP)->CR_TIPO == "RV"
            cTipo := "REVISAO    "
        ElseIf (cAliasTMP)->CR_TIPO == "CT"
            cTipo := "CONTRATO   "
        ElseIf (cAliasTMP)->CR_TIPO == "IT"
            cTipo := "ITEM CONTRATO"
        ElseIf (cAliasTMP)->CR_TIPO == "MD"
            cTipo := "MEDIÇÃO    "
        ElseIf (cAliasTMP)->CR_TIPO == "IM"
            cTipo := "ITEM MEDIÇÃO"
        ElseIf (cAliasTMP)->CR_TIPO == "IR"
            cTipo := "ITEM REVISÃO"
        EndIf

        While (cAliasTMP)->(!(EoF()))

            //De acordo com a legenda
            If (cAliasTMP)->CR_STATUS == "01"
                cStatus := "Bloqueado p/ sistema(aguardando outros niveis)"
            ElseIf (cAliasTMP)->CR_STATUS == "02"
                cStatus := "Aguardando Liberacao do usuario"
            ElseIf (cAliasTMP)->CR_STATUS == "03"
                cStatus := "Pedido Liberado pelo usuario"
            ElseIf (cAliasTMP)->CR_STATUS == "04"
                cStatus := "Pedido Bloqueado pelo usuario"
            ElseIf (cAliasTMP)->CR_STATUS == "05"
                cStatus := "Pedido Liberado por outro usuario"
            EndIf

            AAdd(aBrowse, {(cAliasTMP)->CR_XNOME, (cAliasTMP)->CR_NIVEL, (cAliasTMP)->CR_APROV, cStatus})

            (cAliasTMP)->(DbSkip())
        End

        (cAliasTMP)->(DbCloseArea())

        DEFINE DIALOG oDlg TITLE "Aprovação do Pedido de Compras" FROM 180, 180 TO 470, 760 PIXEL

        DEFINE SBUTTON FROM 125, 250 TYPE 2 ACTION (/*0, */oDlg:End()) ENABLE OF oDlg
        @ 08,08 SAY cTipo + Space(10) + cNumero + Space(2) + cRespons SIZE 88, 8 OF oDlg PIXEL

        //Colunas ->//param1 = Linha | param2 = Coluna | param3 = Largura | param4 = Altura
        oBrowse := TWBrowse():New(25, 6, 287, 90,, {"Nome Aprovador   ", "Nível", "Aprovador Responsável   ", "Situação                           "};
            , {20, 30, 30}, oDlg,,,,, {||},,,,,,, .F.,, .T.,, .F.,,,)

        oBrowse:SetArray(aBrowse)

        oBrowse:bLine := {|| {aBrowse[oBrowse:nAt][01], aBrowse[oBrowse:nAt][02], aBrowse[oBrowse:nAt][03], aBrowse[oBrowse:nAt][04]}}

        ACTIVATE DIALOG oDlg CENTERED
    EndIf

    AEval(aArea, {|area| RestArea(area)})

Return .T.