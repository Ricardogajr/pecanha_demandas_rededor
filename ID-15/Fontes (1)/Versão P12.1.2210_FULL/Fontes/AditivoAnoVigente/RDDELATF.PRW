#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"   
#include "PARMTYPE.CH"    
#INCLUDE "TOTVS.CH"
#INCLUDE "TRYEXCEPTION.CH"
#include "topconn.ch"
#INCLUDE "RPTDEF.CH"
#Include 'RwMake.Ch'

#DEFINE cEol CHR(13)+CHR(10)
#DEFINE STR0000 "Rotina de Exclusão de ativos por filial"
#DEFINE STR0001 "Este programa permite que os dados do ativo fixo, sejam apagados por filial!"
#DEFINE STR0002 "Importante frisar que esse processo é irreversível ! , "
#DEFINE STR0003 "portanto, é imprescindível verificar se a filial selecionada está correta !"
#DEFINE STR0004 "Para essa rotina foi criado um paramêtro : MV_XDELATF, para evitar execuções acidentais!"
#DEFINE STR0005 "caso seja necessário nova execução , solicitar o desbloqueio da rotina, limpando o parametro citado"
/*
 ativar parametro, existem 7 threds ativos, distribuidos 35000 registros entre os threads por execucao.
MV_XTPSALD    - preenchimento com varios tipos de saldo "1;2;3;4")
MV_XDIASAL    - dias para tolerancia dos calendÃ¡rios abertos em dias  60 preenchimento numerico 60
MV_XFILESL    - filiais que não serão consideradas no reprocessamento de saldo preenchimento "01010004|01310001|..."
MV_XFILSAL    - Processa o reprocessamento de saldo contábil por filial. preenchimento .T. / POR FILIAL
MV_XFOLLOG    - Pasta padrão para o log da rotina , preenchimento \SIGADOC\LOG_REPROCESSAMENTO_SALDOS\
*/


User Function RDDELATF()


 Local cMensagem    := ""
 Local oDlgDel
 Local lRet      := .F.
 //Local aAreaSX6   := SX6->(GetArea())

 Private cHoraIni    
 Private cSvFilAnt    := ""
 Private cSvEmpAnt    := ""
 Private cSvUser      := ""
 Private cParam := "MV_XDELATF" //parametro que identifica se a filial já foi processada
 Private cFilAtu   	:= ""
 Private cEmpAtu   	:= ""
 Private cEmpProc  	:= ""
 Private aProgs    	:= {}
 Private _aFilias  	:= {}
 Private cDtini    	:= SUBS(DTOS(date()),1,6)+"01" 
 Private cDtFim    	:= SUBS(DTOS(date()),1,8)   
 Private nTotReg  	:= 0       
 Private _cPathRoot := "" //"\SIGADOC\LOG_REPROCESSAMENTO_SALDOS\"
 Private _cPath 	:= "" //"\SIGADOC\LOG_REPROCESSAMENTO_SALDOS\"+cDtFim+"\" 
 //Private aAreaOri   := GetArea()     	
 Private nCount := 0
 Private _cEmpConec := U_GetFilP()[1]
 Private _cFilConec := U_GetFilP()[2]
 Private aSelFil := {}
 Private cMsg    := ""
 Private aLogs   :={}
 Private cFilProc := ""
 Private oException 
 Private nErro
 Private nTotal
 Private aTabDel := {'SN1','SN2','SN3','SN4','SN5','SN6','SN7','SN8','SN9','SNA','FN6','FN9'}
 Private aTabDelOk := {}
 Private cDtParam := ""
 /*
SN1 CADASTRO DE ATIVO IMOBILIZADO
SN2 DESCRIÇÕES ESTENDIDAS
SN3 CADASTRO DE SALDOS E VALORES
SN4 MOVIMENTAÇÕES DO ATIVO FIXO
SN5 ARQUIVOS DE SALDOS
SN6 SALDOS POR CONTA E ITEM
SN7 CADASTRO DE SIMULAÇÃO VENDAS
SN8 CADASTRO DE INVENTÁRIO
SN9 CADASTRO DE AÇÕES
SNA SALDOS POR CTA, ITEM E CL VLR
FN6 BAIXA DE ATIVOS
FN9 CABEÇALHO DA TRANSFERÊNCIA
*/
cHoraIni := Time()

//If	TCGetConn() < 0
//    RpcSetType(3)
    //U_RpcSethtk(_cEmpConec, _cFilConec )
//    RpcSetEnv(_cEmpConec,_cFilConec)
//EndIf

cSvFilAnt    := cFilANt
cSvEmpAnt    := cEmpAnt
cSvUser      := cUserName 

  cMensagem := "Hora Inicio do Processamento :"+cHoraIni
  Aadd(aLogs, cMensagem) 


  //lRet:= FWDlgModal()


 DEFINE MSDIALOG oDlgDel FROM  96,9 TO 320,612 TITLE OemToAnsi(STR0000) PIXEL //"Contabilização dos Custo Medio"
	 @ 11,6 TO 90,287 LABEL "" OF oDlgDel  PIXEL
	 @ 16, 15 SAY OemToAnsi(STR0001) SIZE 268, 8 OF oDlgDel PIXEL //"Este programa permite que os lançamentos contabeis do periodo selecionado sejam refeitos sem que "
	 @ 26, 15 SAY OemToAnsi(STR0002) SIZE 268, 8 OF oDlgDel PIXEL //"seja necessario rodar novamente a rotina de Recalculo do Custo Medio."
	 @ 36, 15 SAY OemToAnsi(STR0003) SIZE 268, 8 OF oDlgDel PIXEL //"Atenção: As perguntas utilizadas nesta rotina são as mesmas utilizadas na rotina do Recalculo"
	 @ 46, 15 SAY OemToAnsi(STR0004) SIZE 268, 8 OF oDlgDel PIXEL //"do Custo Medio, porem somente as perguntas referentes a contabilização são utilizadas."
	 @ 56, 15 SAY OemToAnsi(STR0005) SIZE 268, 8 OF oDlgDel PIXEL //"Importante: somente serão contabilizados na rotina os dados de custo medio aglutinados"
	 //@ 56, 15 SAY "Importante: somente serão contabilizados na rotina os dados de custo medio aglutinados" SIZE 268, 8 OF oDlgDel PIXEL
	// @ 66, 15 SAY OemToAnsi(STR0012) SIZE 268, 8 OF oDlgDel PIXEL //"Médio."
	 //@ 80, 15 SAY OemToAnsi(FWI18NLang("MATA331","STR0006",6)) + DTOC(dInicio) SIZE 268, 8 OF oDlgDel PIXEL //"Data Inicial de Processamento : "
	
	 //DEFINE SBUTTON FROM 93, 163 TYPE 11 ACTION valParam() ENABLE OF oDlgDel
     //DEFINE SBUTTON FROM 93, 193 TYPE 12 ACTION valParam() ENABLE OF oDlgDel
	// DEFINE SBUTTON FROM 93, 193 TYPE 5  ACTION Pergunte(cPerg,.T.) ENABLE OF oDlgDel
	 DEFINE SBUTTON FROM 93, 223 TYPE 1  ACTION Processa({|lEnd| lRet := fProcess() },"Processando","Rotina de Exclusão de ativos",.F.) ENABLE OF oDlgDel //##"Processando ..."##"Contabilizacao do Custo Medio"
     //DEFINE SBUTTON FROM 93, 223 TYPE 1  ACTION Processa({|lEnd| lRet := fProcess()},"Processando","Rotina de Exclusão de ativos",.F.) ENABLE OF oDlgDel //##"Processando ..."##"Contabilizacao do Custo Medio"
	 DEFINE SBUTTON FROM 93, 253 TYPE 2  ACTION oDlgDel:End() ENABLE OF oDlgDel
 ACTIVATE MSDIALOG oDlgDel CENTERED
	//	Else
	//		Processa({|lEnd| fProcess(aListaFil,lBat,@lEnd)},OemToAnsi(STR0007),OemToAnsi(STR0008),.F.)
	//	EndIf	


//Processa({|lEnd| fProcess(aListaFil,lBat,@lEnd)},OemToAnsi(STR0007),OemToAnsi(STR0008),.F.)
//Processa()
//oDlgDel:Destroy()

If lRet 
    cHoraFim := Time()
    cMensagem := "Hora Fim do Processamento :"+cHoraFim
    Aadd(aLogs, cMensagem) 
    
    _cPathRoot := Alltrim(SuperGetMV("MV_XDELLOG",.F., "\LOG_DELECAO_ATIVO\"))
    _cPath := _cPathRoot+cDtFim+"\" 

    Makedir(_cPathRoot)
    MakeDir(_cPath)

    U_GConout(cMensagem,nTotal, nErro,cFilAnt)
    U_fGeraLog(aLogs,_cPath)

    cLastDay := DTOS(LastDay(Date()))
    PutMv(cParam, cDtParam + " Usuario:"+ cSvUser)
    PutMv("MV_ULTDEPR", cLastDay)
EndIf

If cFilAnt <> cSvFilAnt

    cEmpAnt := cSvEmpAnt
    cFilAnt := cSvFilAnt
    
    //RpcClearEnv() // fecha algum ambiente aberto anteriormente
    //RpcSetType(1) // indica que é uma execução automática, portando não deve consumir licenças
  //  RpcSetEnv(cSvEmpAnt,cSvFilAnt)
EndIf 
//RestArea(aAreaOri)
//RestArea(aAreaSX6)
Return

Static Function fProcess()
Local Ny, Ni 

 cHoraIni   := Time()
 aArea      := GetArea()
 
 // aAdd( aProgs, { "CTBA190" } )  
  aAdd( aProgs, { "RDDELATF" } )  
  
//If lRet .And. mv_par23 == 1 .And. Len( aSelFil ) <= 0 
	aSelFil := AdmGetFil()
	If Len( aSelFil ) <= 0
        cMsg += '<br>'
        cMsg += '<font size="4">Nenhuma Filial foi selecionada!</font>'
        FWAlertInfo( cMsg, 'Por favor Selecione uma Filial' )
        cMsg := ""
        aSelFil := {}
		Return .F.
    ElseIf Len( aSelFil ) > 1
        cMsg += '<br>'
        cMsg += '<font size="4">Por favor selecione apenas uma filial!</font>'
        FWAlertInfo( cMsg, 'Por favor Selecione apenas uma Filial' )
        cMsg := ""
        aSelFil := {}
        Return .F.
	EndIf 

    cFilProc := aSelFil[1]

    //RpcClearEnv() // fecha algum ambiente aberto anteriormente
    //RpcSetType(1) // indica que é uma execução automática, portando não deve consumir licenças
    //RpcSetEnv(cSvEmpAnt,cFilProc)
    cEmpAnt := cSvEmpAnt
    cFilAnt := cFilProc
    
    cDtParam := dtos(date())+replace(substr(time(), 1, 8),":","")
    If FWSX6Util():ExistsParam( cParam ) //verifica se parametro existe na filial
        If !Empty(GetMv(cParam))
            //PutMv(cParam, cDtParam)
            cDataExec := GetMv(cParam)
            cUserExec := Alltrim(Substring(cDataExec,16,100))
            cDataExec := substring(cDataExec,7,2)+"/"+substring(cDataExec,5,2)+"/"+substring(cDataExec,1,4)+" AS "+ substring(cDataExec,9,2) + ":" + substring(cDataExec,11,2)+":" + substring(cDataExec,13,2)
            cMsg += '<br>'
            cMsg += '<font size="4">A Filial seleciona já executou essa rotina e está bloqueada</font>'
            cMsg += '<br>'
            cMsg += '<font size="4">Se for preciso deletar novamente as tabelas, solicitar o desbloqueio do Parametro :</font>'
            cMsg += '<br>'
            cMsg += '<br>'
            cMsg += '<font size="4"><b>MV_XDELATF<b></font>'
            cMsg += '<br>'
            cMsg += '<br>'
            cMsg += '<font size="4">ultima execução : '+cDataExec+'</font>'
            cMsg += '<br>'
            cMsg += '<font size="4">'+cUserExec+'</font>'
            cMsg += '<br>'
            FWAlertInfo( cMsg, 'Filial Bloqueada' )
            cMsg := ""
            Return .F.
        EndIf
    Else 
        lRet := fCriaParam()
    EndIf 

    cMsg := ""
    For nI:=1 to Len(aTabDel)
        cAliasTab := aTabDel[nI]
        cMsg += fCountTab(cFilProc, cAliasTab) 
    Next nI

    If Empty(cMsg)
        cMsg += '<br>'
        cMsg += '<br>'+cEol
        cMsg += '<font size="4"><b>Não foram localizados dados na Filial : '+cFilProc+' </b></font>'     
        FWAlertInfo( cMsg, 'Não existem dados a serem deletados na Filial')
        cMsg := ""
        Return .F.
    EndIf 

    cMsg += '<br>'
    cMsg += '<br>'+cEol
    cMsg += '<font size="4"><b>CONFIRMAR DELEÇÃO PARA A FILIAL : '+cFilProc+' </b></font>'
//EndIf 
/*
cMsg := '<b>Negrito</b>'
cMsg += '<br>'
cMsg += '<i>Italico</i>'
cMsg += '<br>'
cMsg += '<font color="#FF00FF">Mensagem 2</font>'
cMsg += '<br>'
cMsg += '<font color="#0FFF00" size="20">Mensagem 2</font>'
cMsg += '<br>'
cMsg += '<font color="#0F0F00" size="50">Mensagem 3</font>'
FWAlertYesNo( cMsg, 'Universo do Desenvolvedor' )
FWAlertWarning( cMsg, 'Universo do Desenvolvedor' )
FWAlertSuccess( cMsg, 'Universo do Desenvolvedor' )
FWAlertNoYes( cMsg, 'Universo do Desenvolvedor' )
FWAlertInfo( cMsg, 'Universo do Desenvolvedor' )
FWAlertHelp( cMsg, 'Universo do Desenvolvedor' )
FWAlertError( cMsg, 'Universo do Desenvolvedor' )
*/

If FWAlertNoYes( cMsg, 'Total de Registros que Serão deletados!' )
    cMsg := ""
    For Ny:=1 to Len(aTabDelOk) 
        cAliasTab := aTabDelOk[Ny]
        cMsg += fProcDel(cAliasTab)
    Next Ny
    cMsg += '<br>'
    FWAlertSuccess( cMsg, 'Registros de tabelas deletados com sucesso' )
Else 
    cMsg += '<br>'
    cMsg += '<font size="5">Nenhum dado foi excluido</font>'
    FWAlertInfo( cMsg, 'Rotina Cancelada pelo usuário' )
    cMsg:= ""
    Return .F.
EndIf 

cHoraFim := Time()
cMensagem := "Hora Fim do Processamento :"+cHoraFim
Aadd(aLogs, cMensagem) 

Return .T.

Static Function fCountTab(cFilProc, cAliasTab)
Local cQry      := ""
Local cAliasTmp := GetNextAlias()

Local cMsgHtml  := ""
/*
SN1 CADASTRO DE ATIVO IMOBILIZADO
SN2 DESCRIÇÕES ESTENDIDAS
SN3 CADASTRO DE SALDOS E VALORES
SN4 MOVIMENTAÇÕES DO ATIVO FIXO
SN5 ARQUIVOS DE SALDOS
SN6 SALDOS POR CONTA E ITEM
SN7 CADASTRO DE SIMULAÇÃO VENDAS
SN8 CADASTRO DE INVENTÁRIO
SN9 CADASTRO DE AÇÕES
SNA SALDOS POR CTA, ITEM E CL VLR
FN6 BAIXA DE ATIVOS
FN9 CABEÇALHO DA TRANSFERÊNCIA
*/
        TRYEXCEPTION
            cCampoFil := If(substring(cAliasTab,1,1) == 'S', substring(cAliasTab,2,2)+"_FILIAL",substring(cAliasTab,1,3)+"_FILIAL" )
            cQry  :=  " select count(*) TOTAL FROM "+RetSqlName(cAliasTab)+ " WHERE D_E_L_E_T_ = ' ' AND "+cCampoFil+" =  '"+cFilProc+"'"   
            DbUseArea(.T., 'TOPCONN', TCGenQry(,,cQry), cAliasTmp, .F., .T.)
            
            If !(cAliasTmp)->(Eof())
                nTotalCont := (cAliasTmp)->TOTAL
                (cAliasTmp)->(dbCloseArea())

                If nTotalCont > 0 
                    cMsgHtml += '<br>'
                    cTexto := PADR(Alltrim(cAliasTab)+"- "+FwSX2Util():GetX2Name( Alltrim(cAliasTab) , .F. ),50)+' : '+cValtoChar(nTotalCont)
                    cMsgHtml += '<font size="4">'+cTexto+'</font>'
                    aAdd(aTabDelOk,cAliasTab)
                EndIf 
            EndIf 
        CATCHEXCEPTION USING oException
            nErro++
            FWLogMsg("*** ERRO TRYEXCEPTION ", /*cTransactionId*/, "MeuGrupo", /*cCategory*/, /*cStep*/, /*cMsgId*/, OemToAnsi(oException:Description), /*nMensure*/, /*nElapseTime*/, /*aMessage*/)
            Conout("**** ERRO TRYEXCEPTION "+ OemToAnsi(oException:Description))
            cMensagem := OemToAnsi(oException:Description)
            U_GConout(cMensagem,nTotal, nErro,cFilProc)
  		ENDEXCEPTION


Return cMsgHtml

Static Function fProcDel(aTabDelOk)
Local cQryDel   := ""
Local cCampoFil := "" 
Local cMsgDel := ""

        TRYEXCEPTION
            cCampoFil := If(substring(cAliasTab,1,1) == 'S', substring(cAliasTab,2,2)+"_FILIAL",substring(cAliasTab,1,3)+"_FILIAL" )
            cQryDel  :=  " UPDATE "+RetSqlName(cAliasTab)+cEol 
            If cAliasTab == "SN4"
                cQryDel  +=  " SET D_E_L_E_T_ = '*' "+cEol
            Else 
                cQryDel  +=  " SET D_E_L_E_T_ = '*' , R_E_C_D_E_L_ = R_E_C_N_O_ "+cEol
            EndIf 
            cQryDel  +=  " WHERE D_E_L_E_T_ = ' ' AND "+cCampoFil+" =  '"+cFilProc+"'" 
            //cQryDel  +=  " COMMIT ;"

            If TcSqlExec(Alltrim(cQryDel))	< 0
	            ConOut(TcSqlError())
            Else 
                //aAdd(aDelOk,cAliasTab)
                cMsgDel += '<br>'
                cTexto := PADR('Tabela deletada com sucesso :'+cAliasTab,50)
                cMsgDel += '<font size="4">'+cTexto+'</font>'
            EndIf	
            
        CATCHEXCEPTION USING oException
            nErro++
            FWLogMsg("*** ERRO TRYEXCEPTION ", /*cTransactionId*/, "MeuGrupo", /*cCategory*/, /*cStep*/, /*cMsgId*/, OemToAnsi(oException:Description), /*nMensure*/, /*nElapseTime*/, /*aMessage*/)
            Conout("**** ERRO TRYEXCEPTION "+ OemToAnsi(oException:Description))
            cMensagem := OemToAnsi(oException:Description)
            U_GConout(cMensagem,nTotal, nErro,cFilProc)
		ENDEXCEPTION
Return cMsgDel


Static Function fCriaParam()
Local aArea := GetArea()
Local lRet := .F.

//If	TCGetConn() > 0
    //RpcClearEnv() // fecha algum ambiente aberto anteriormente
    //RpcSetType(1) // indica que é uma execução automática, portando não deve consumir licenças
    //U_RpcSethtk(_cEmpConec, _cFilConec )
    //RpcSetEnv(_cEmpConec,_cFilConec)
//EndIf

    cEmpAnt := _cEmpConec
    cFilAnt := _cFilConec

If FWSX6Util():ExistsParam( cParam ) 
    If FWSX6Util():ReplicateParam( "MV_XDELATF" , '*' , .F. , .F. )
        cMsg += '<br>'
        cMsg += '<br>'+cEol
        cMsg += '<font size="4"><b>o Parametro foi replicado com sucesso</b></font>'     
        FWAlertSuccess( cMsg,'Replica de parametro')
        lRet := .T.
    Else 
        If !FWSX6Util():ReplicateParam( "MV_XDELATF" , cFilProc , .F. , .F. )
            cMsg += '<br>'
            cMsg += '<br>'+cEol
            cMsg += '<font size="4"><b>Não foi possivel replicar o parametro para as demais filiais  </b></font>'     
            FWAlertInfo( cMsg, 'Replica de parametro')
        Else 
            cMsg += '<br>'
            cMsg += '<br>'+cEol
            cMsg += '<font size="4"><b>o Parametro foi replicado com sucesso para a filial '+cFilProc+'</b></font>'     
            FWAlertSuccess( cMsg,'Replica de parametro por filial')
            lRet := .T.
        EndIf 
    EndIf 
Else 
    cMsg += '<br>'
    cMsg += '<br>'+cEol
    cMsg += '<font size="4"><b>Não foi possivel replicar o parametro para as demais filiais  </b></font>'     
    cMsg += '<font size="4"><b>Favor solicitar a criação do parametro: MV_XDELATF para a filial'+cFilProc+'</b></font>'     
    FWAlertInfo( cMsg, 'Parametro não existe')
EndIf 

RestArea(aArea)

Return lRet


Static Function FWDlgModal()
Local bConfirm
Local bSair 
Local lRet := .F.
    
Local oDialog 

//bConfirm := {|| MsgInfo('Insira seu processamento aqui','Processando') }
bConfirm := {||Processa({|lEnd| lRet := fProcess()})}

bSair    := {|| Iif(MsgYesNo( 'Você tem certeza que deseja sair da rotina? ',;
'Sair da rotina'),(oDialog:DeActivate()),NIL) }

// Método responsável por criar a janela e montar os paineis.
oDialog := FWDialogModal():New()

// Métodos para configurar o uso da classe.
oDialog:SetBackground( .T. ) 
oDialog:SetTitle( 'ROTINA DELETAR ATIFO FIXO' )
oDialog:SetSize( 240, 480 )
oDialog:EnableFormBar( .T. )
oDialog:SetCloseButton( .F. )
oDialog:SetEscClose( .F. )
oDialog:CreateDialog()
oDialog:CreateFormBar()
oDialog:AddButton( 'Confirmar', bConfirm, 'Confirmar', , .T., .F., .T., )
oDialog:AddButton( 'Sair' , bSair   , 'Sair' , , .T., .F., .T., )

// Capturar o objeto do FwDialogModal para alocar outros objetos se necessário.
oPanel := oDialog:GetPanelMain()

oDialog:Activate()

Return lRet 
