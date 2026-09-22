#include "TOTVS.CH"  
#include "TbiConn.ch" 
#include "TbiCode.ch" 
#include "TopConn.ch"      
#INCLUDE 'FWMVCDEF.CH'

/*/
{Protheus.doc} F1207401
Rotina para bloquear o produto de forma definitiva
@author William Souza 
@since 23/04/2019
@project MAN0000007423041_EF_074
/*/
User Function F1207401()

//Verificar se o produto é bloqueado ou não
If Empty(SB1->B1_XBLQPER) .or. SB1->B1_XBLQPER == "2"
        validBloq('B')
    Else
        validBloq('D')
    EndIf
	
Return

/*/
{Protheus.doc} validBloq
Static Function para validar o bloqueio do produto
@author William Souza 
@since 23/04/2019
@project MAN0000007423041_EF_074
/*/ 
 
Static Function validBloq(cTipo)

Local aSql   := {}
Local cAliasTMP := ""
Local lTrava := .F.
Local nI     := 0
Local nTOTAL   := 0

    If cTipo == "B"
		        /*-- PEDIDO DE COMPRA --*/
        //1. Quantidade entregue < Quantidade de consumo
        aAdd(aSql,"SELECT COUNT(*) AS TOTAL FROM "+RetSqlName("SC7")+" WHERE C7_QUJE < C7_QUANT AND C7_PRODUTO = '"+SB1->B1_COD+"' AND D_E_L_E_T_ = ''")

        //2. Quando o pedido tiver saldo e não foi atendido (C7_RESIDUO = ‘’)
        aAdd(aSql,"SELECT COUNT(*) AS TOTAL FROM "+RetSqlName("SC7")+" WHERE C7_RESIDUO <> '' AND C7_PRODUTO = '"+SB1->B1_COD+"' AND D_E_L_E_T_ = ''")

        //3. Quando o pedido não estiver encerrado (C7_ENCER <> ‘’)
        aAdd(aSql,"SELECT COUNT(*) AS TOTAL FROM "+RetSqlName("SC7")+" WHERE C7_ENCER <> '' AND C7_PRODUTO = '"+SB1->B1_COD+"' AND  D_E_L_E_T_ = ''")
        
        /*-- SOLICITAÇÃO DE COMPRA --*/
        //1.	Quantidade entregue < Quantidade de consumo (C1_QUJE < C1_QUANT)
        aAdd(aSql,"SELECT COUNT(*) AS TOTAL FROM "+RetSqlName("SC1")+" WHERE C1_QUJE < C1_QUANT AND C1_PRODUTO = '"+SB1->B1_COD+"' AND  D_E_L_E_T_ = ''")

        //2.	Quando a solicitação tiver saldo e não foi atendido (C1_RESIDUO = ‘’)
        aAdd(aSql,"SELECT COUNT(*) AS TOTAL FROM "+RetSqlName("SC1")+" WHERE C1_RESIDUO = '' AND C1_PRODUTO = '"+SB1->B1_COD+"' AND  D_E_L_E_T_ = ''")

        //3.	Quando não houver medição para a solicitação (C1_XNUMMED = ‘’)
        aAdd(aSql,"SELECT COUNT(*) AS TOTAL FROM "+RetSqlName("SC1")+" WHERE C1_XNUMMED = '' AND C1_PRODUTO = '"+SB1->B1_COD+"' AND  D_E_L_E_T_ = ''")

        /*-- SOLICITAÇÃO DE PAGAMENTO --*/
        //1.	Em aprovação (Azul) C7_CONAPRO == 'B' e C7_< C7_QUANT
        aAdd(aSql,"SELECT COUNT(*) AS TOTAL FROM "+RetSqlName("SC7")+" WHERE C7_XSOLPAG = '1' AND C7_ENCER <> '' AND C7_PRODUTO = '"+SB1->B1_COD+"' AND  D_E_L_E_T_ = ''")

        //2.	Em recebimento pré-nota (Laranja) C7_QTDCLA > 0
        aAdd(aSql,"SELECT COUNT(*) AS TOTAL FROM "+RetSqlName("SC7")+" WHERE C7_XSOLPAG = '1' AND C7_CONAPRO = 'B' AND C7_QUJE < C7_QUANT AND C7_PRODUTO = '"+SB1->B1_COD+"' AND  D_E_L_E_T_ = ''")

        //3.	Recebido (Vermelho) C7_QUJE >= C7_QUANT 
        aAdd(aSql,"SELECT COUNT(*) AS TOTAL FROM "+RetSqlName("SC7")+" WHERE C7_XSOLPAG = '1' AND C7_QUJE >= C7_QUANT AND C7_PRODUTO = '"+SB1->B1_COD+"' AND  D_E_L_E_T_ = ''")

        //4.	Pendente (verde) C7_QUJE = 0 E C7_QTDACLA = 0
        aAdd(aSql,"SELECT COUNT(*) AS TOTAL FROM "+RetSqlName("SC7")+" WHERE C7_XSOLPAG = '1' AND C7_QUJE = '0' AND C7_QTDACLA = '0' AND C7_PRODUTO = '"+SB1->B1_COD+"' AND  D_E_L_E_T_ = ''")

        For nI := 1 to len(aSql)
            cAliasTMP := GetNextAlias()
            
            mpsysopenquery(ChangeQuery(aSql[nI]),cAliasTMP)
	
            ( cAliasTMP )->(DbGoTop())
            
            If ( cAliasTMP )->( !Eof() )
                nTOTAL := ( cAliasTMP )->TOTAL
                           
                If nTOTAL > 0
                    lTrava := .T.
                    ( cAliasTMP )->( DbCloseArea() )
                    Exit
                Endif
            EndIF
            
            ( cAliasTMP )->( DbCloseArea() )           
        Next

        if lTrava
            Help('',1,'Help',"MATA010","O produto ("+ALLTRIM(SB1->B1_COD)+" - "+ALLTRIM(SB1->B1_DESC)+") não poderá ser bloqueado, pois há movimentação deste produto nos processos de compras e financeiro. ",1,0)
        Else
            exibeTela(cTipo)
        EndIf    

    Else
        exibeTela(cTipo)
    EndIF

Return 


/*/
{Protheus.doc} exibeTela
Static Function para exibir tela
@author William Souza 
@since 23/04/2019
@project MAN0000007423041_EF_074
/*/ 
 
Static Function exibeTela(cTipo)

Local oButton1
Local oButton2
Local oGroup1
Local oSay1
Local oSay2
Local oSay3
Local oMultiGe1
Local cString
Private cMultiGe1 
Private oDlg

If cTipo == "D"
    cMultiGe1  := MSMM(,TamSx3("B1_XBLQOBS")[1],,SB1->B1_XBLQOBS,3,,,"SB1","B1_XBLQOBS")
Else
    cMultiGe1  := space(TamSx3("B1_XBLQOBS")[1])
End

  DEFINE MSDIALOG oDlg TITLE IIF(cTipo == "B","Bloqueio","Desbloqueio") + " Permanente de Produto" FROM 000, 000  TO 400, 590 COLORS 0, 16777215 PIXEL

    @ 002, 003 GROUP oGroup1 TO 197, 295 PROMPT IIF(cTipo == "B","Bloqueio","Desbloqueio") + " Permanente de Produto" OF oDlg COLOR 0, 16777215 PIXEL
    @ 015, 008 SAY oSay1 PROMPT "Produto" SIZE 025, 007 OF oDlg COLORS 0, 16777215 PIXEL
    @ 023, 008 SAY oSay2 PROMPT alltrim(SB1->B1_COD) + "-" + SB1->B1_DESC SIZE 272, 007 OF oDlg COLORS 0, 16777215 PIXEL
    @ 181, 252 BUTTON oButton1 PROMPT "Fechar" SIZE 037, 012 OF oDlg PIXEL action(oDlg:end())
    @ 181, 211 BUTTON oButton2 PROMPT IIF(cTipo == "B","Bloqueio","Desbloqueio") SIZE 037, 012 OF oDlg PIXEL action(IIF(cTipo == "B",grvDados('B'),grvDados("D")))
    @ 045, 007  GET oMultiGe1 VAR cMultiGe1 OF oDlg MULTILINE SIZE 283, 131 COLORS 0, 16777215 HSCROLL PIXEL
    @ 037, 008 SAY oSay3 PROMPT "Motivo do Bloqueio" SIZE 073, 007 OF oDlg COLORS 0, 16777215 PIXEL

  ACTIVATE MSDIALOG oDlg CENTERED


Return

/*/
{Protheus.doc} grvDados
Static Function para gravar os dados
@author William Souza 
@since 23/04/2019
@project MAN0000007423041_EF_074
/*/ 
Static Function grvDados(cTipo)

Local cTitulo  := IIF(cTipo == "B","Bloqueio do Produto","Desbloqueio do Produto")
Local cTexto   := "O produto "+alltrim(SB1->B1_COD)+" foi "+IIF(cTipo == "B","bloqueado","desbloqueado")+" com sucesso."
Local nStatus  := 0

    //atualiza a tabela SB1
    Reclock("SB1",.F.)
    SB1->B1_MSBLQL := IIF(cTipo == "B","1","2")
SB1->B1_XBLQOBS := MSMM(,TamSx3("B1_XBLQOBS")[1],,IIF(cTipo == "B",cMultiGe1,Space(500)),3,,,"SB1","B1_XBLQOBS") 
SB1->B1_XBLQPER := IIF(cTipo == "B","1","2")
    SB1->(MsUnLock())
    
    //bloqueio produtos na P17
    if cTipo == "B"
        nStatus := TCSqlExec("UPDATE "+RetSqlName("P17")+" SET P17_BLOQ = 'S' WHERE P17_COD = '"+SB1->B1_COD+"'")
        if (nStatus < 0)
            Help('',1,'Help',"MATA010","Houve um problema no bloqueio do produto na tabela P17: "+ TCSQLError(),1,0)
        endif
    EndIf

    
    RegToMemory("SB1", .F., .T.)
    
    AVISO(cTitulo, cTexto, {"Fechar"}, 1)
    oDlg:end()

Return