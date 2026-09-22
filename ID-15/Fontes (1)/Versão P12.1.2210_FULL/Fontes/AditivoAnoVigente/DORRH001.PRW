#INCLUDE "TOTVS.CH"

/*
Funcao: DORRH001 - Importa Calendários de Turnos (RCF / RCG)
Autor : Mauricio Siqueira
Data..: 12/04/24
Versão: Protheus12
Menu..: SIGAGPE\ATUALIZAÇÃO\DEFINIÇÕES DE CÁLCULOS\Importa Calendários
Função: RH01_LEARQ - (Seleciona arquivo)
Função: RH01_EXEC()- (Executa Processamento Principal)
Função: RH01_BLOQ  - (Verifica bloqueios de período)
Função: RH01_LINHA - (Verifica Consistência da linha)
Função: RH01_EXC   - (Exclui Calendário)
Função: RH01_INC   - (Inclui Calendário)
*/

User Function DORRH001()

Local aArea    := FWGetArea()
Local aSays	   := {}
Local aButtons := {}	
Local nOpca    := 0

Private oArquivo
Private cArqCSV     := ""
Private cArqRCG     := ""
Private cDirArq     := ""
Private cLog        := ""
Private nTotLinhas  := 0
Private cLinAtu     := ""
Private nLinhaAtu   := 0
Private c_Filial    := ""
Private c_TnoTra    := ""
Private d_DiaMes    := CTOD("//")
Private c_TipDia    := ""
Private c_VT        := ""
Private c_DifVT     := ""
Private c_VR        := ""
Private c_VA        := ""
Private c_AnoMes    := ""
Private c_Acao      := ""
Private l_Proximo   := .T.
Private l_Log       := .F.
Private c_AcaoArq   := ""
Private c_FilArq    := ""
Private aLinha      := {}

cCadastro := OemToAnsi("Importa Calendário")
	
AADD(aSays,OemToAnsi("Este programa realiza a importação de Calendários") )
AADD(aSays,OemToAnsi("para as rotinas de Cadastro de Períodos.")) 
	
AADD(aButtons, { 1,.T.,{|o| nOpca := 1, If(RH01_LEARQ(), FechaBatch(), nOpca:=0) }} )
AADD(aButtons, { 2,.T.,{|o| FechaBatch() }} )
		
FormBatch(cCadastro,aSays,aButtons)

If nOpca == 1                      
   Processa({|lEnd| RH01_EXEC(),"Executando via Menu", "Atualizando Calendário . . ."})
EndIf

FWRestArea(aArea)

Return


/*
Função 	RH01_LEARQ - (Seleciona arquivo)
Return	lRet
*/
Static Function RH01_LEARQ()

Local cTipArq  := "Arquivos com separações (*.csv)"
Local cTitulo  := "Selecione o Arquivo de Calendário"
Local lRet := .T.

cArqCSV := tFileDialog( cTipArq, cTitulo, , cDirArq, .F.)
   
If Empty( cArqCSV )
   FWAlertError("Arquivo vazio ou não selecionado", )
   lRet := .F.
EndIf

Return lRet


/*
Função 	RH01_EXEC - Processa .CSV
Return	lRet, habilitado para continuar ou não
*/
Static Function RH01_EXEC()

Local aArea      := FWGetArea()
Local cArqRCG    := cArqCSV
Local cArqLog    := ""
Local c_HoraIni  := Time()
Local n_StaRen   := 0
Local cDrive     := ""
Local cDiretorio := ""
Local cNomeArq   := ""
Local cExtensao  := ""
Local cArqOk     := .T.
Local c_TnoAnt   := ""

SplitPath(cArqCSV, cDrive, cDiretorio, cNomeArq, cExtensao)

// Cabeçalho do Log
cArqLog := "LOG_"+ cNomeArq + "_" + DToS(Date()) + "_" + StrTran(Time(), ":", "-") + ".CSV"
cLog    := 'Inicio do Processamento do arquivo ('+ cArqRCG + ") " + FWTimeStamp(2, Date(), Time()) + CRLF
cLog    += " " + CRLF

oArquivo := FWFileReader():New(cArqRCG)
      
If (oArquivo:Open())

   If ! (oArquivo:EoF())

      nTotLinhas := Len(oArquivo:GetAllLines())
      ProcRegua(nTotLinhas)

      oArquivo:Close()
      oArquivo := FWFileReader():New(cArqRCG)
      oArquivo:Open()

      While (oArquivo:HasLine())
         nLinhaAtu++
         cLinAtu := oArquivo:GetLine()

         If nLinhaAtu = 1
            If cLinAtu <> "FILIAL;TURNO;DIA;TIPODIA;VT;DIFVT;VR;VA;ACAO"
               cLog += "*** ARQUIVO INVALIDO ! Verifique o cabeçalho." + CRLF
               cArqOk := .F.
               l_Log  := .T.
            Else
               cLog += Strzero(nLinhaAtu, 7) + ";" + cLinAtu + ";LOG " + CRLF
               Loop
            EndIf
         Elseif nLinhaAtu = 2
            aLinha    := StrTokArr(cLinAtu, ";")
            c_FilArq  := aLinha[1]
            c_AnoMes  := Substr(aLinha[3], 7, 4) + Substr(aLinha[3], 4, 2)
            c_TnoAnt  := ""
            c_AcaoArq := aLinha[9]

            If ! c_AcaoArq $ ('I,E')
               cLog += " " + CRLF
               cLog += "Tipo de ação invalida. Deve ser (I)nclusao ou (E)xclusao." + CRLF
               cArqOk := .F.
               l_Log  := .T.
               Exit
            Endif

         EndIf
         Exit
      EndDo
 
      If cArqOk
         If c_AcaoArq = "I"
            RH01_INC()
         Else
            RH01_EXC()
         EndIf
      EndIf
   Endif

   //Fecha o arquivo
   oArquivo:Close()

   If l_Log
      FWAlertError("Arquivo contém erro(s) ! Consulte o Log. ", "Arquivo contém ERRO(s) !")
   Else
      FwAlertSucces("Processamento Finalizado com Sucesso! ", "Arquivo sem erro(s) !")
   EndIf

Else

   FWAlertError("Arquivo não pode ser lido ", cArqRCG)

EndIf

// Tratamento do Log ...
If ! Empty(cLog)
   cLog += " " + CRLF
   cLog += "Total de linhas no arquivo: " + cValToChar(nTotLinhas) + " - Total de Linhas Processadas: " + cValToChar( (nLinhaAtu) ) + CRLF
   cLog += " " + CRLF
   cLog += "Termino do Processamento do arquivo ("+ cArqRCG + ") " + FWTimeStamp(2, Date(), Time()) + CRLF
   cLog += " " + CRLF
   cLog += "Tempo Decorrido: " + ElapTime(c_HoraIni, Time() )
   cLog += " " + CRLF

   MemoWrite(cDrive + cDiretorio + cArqLog, cLog)

   n_StaRen := FRename( cArqRCG, StrTran(cArqRCG, ".csv", ".old") , ,.T.)
   If n_StaRen == -1
      FWAlertError("Falha ao renomear o arquivo !")
   Endif

EndIf

FWRestArea(aArea)

Return


/*
Função 	RH01_BLOQ - (Verifica bloqueios de período...)
Return	lRet
*/
Static Function RH01_BLOQ()

Local c_RFQKey := c_FilArq + "00001" + c_AnoMes + "01"
Local c_RCHKey := c_RFQKey
Local lRet     := .F.

// Verifica se o período existe ou se já está Fechado ...
DbSelectArea("RFQ")
RFQ->(DbSetOrder(1)) // Filial + Processo Fixo (0001) + Periodo + NumPag (Fixo 01)
If RFQ->(DbSeek(c_RFQKey))
   If RFQ_STATUS = "2"
      cLog += Strzero(nLinhaAtu, 7) + ";" + cLinAtu + "; ERRO: Periodo (RFQ) Fechado." + CRLF
      lRet := .T.
   EndIf
Else
   cLog += Strzero(nLinhaAtu, 7) + ";" + cLinAtu + "; ERRO: Cadastro de Periodo (RFQ), não localizado." + CRLF
   lRet := .T.
EndIf

// Verifica se existe roteiro integrado ...
If ! lRet
   DbSelectArea("RCH")
   RCH->(DbSetOrder(1)) // Filial + Processo Fixo (0001) + Periodo + NumPag (Fixo 01)
   If RCH->(DbSeek(c_RCHKey))
      While ( (RCH_FILIAL+RCH_PROCES+RCH_PER+RCH_NUMPAG) = (c_RCHKey) ) .And. ! EOF()
         If (! Empty(RCH_DTFECH)) .OR. (! Empty(RCH_DTINTE)) 
            cLog += Strzero(nLinhaAtu, 7) + ";" + cLinAtu + "; ERRO: Periodo (RCH) Integrado ou Fechado." + CRLF
            lRet := .T.
            Exit
         EndIf
         RCH->(DbSkip())
      EndDo
   Else
      cLog += Strzero(nLinhaAtu, 7) + ";" + cLinAtu + "; ERRO: Periodo (RCH) nao localizado." + CRLF
      lRet := .T.
   EndIf
EndIf

Return lRet


/*
Função 	RH01_LINHA - (Verifica Consistência da linha...)
Return	lRet
*/
Static Function RH01_LINHA()

Local lRet := .T.

If ! c_TipDia $ ("1234") 
   cLog += Strzero(nLinhaAtu, 7) + ";" + cLinAtu + "; ERRO: Tipo de Dia, invalido." + CRLF
   lRet = .F.
EndIf
If ! c_VT $ ("12") 
   cLog += Strzero(nLinhaAtu, 7) + ";" + cLinAtu + "; ERRO: Tipo de VT, invalido." + CRLF
   lRet = .F.
EndIf
If ! c_DIFVT $ ("12") 
   cLog += Strzero(nLinhaAtu, 7) + ";" + cLinAtu + "; ERRO: Tipo de Dif. de VT, invalido." + CRLF
   lRet = .F.
EndIf
If ! c_VR $ ("12") 
   cLog += Strzero(nLinhaAtu, 7) + ";" + cLinAtu + "; ERRO: Tipo de VR, invalido." + CRLF
   lRet = .F.
EndIf
If ! c_VA $ ("12")
   cLog += Strzero(nLinhaAtu, 7) + ";" + cLinAtu + "; ERRO: Tipo de VA, invalido." + CRLF
   lRet = .F.
EndIf
If ! c_Acao $ ("EI")
   cLog += Strzero(nLinhaAtu, 7) + ";" + cLinAtu + "; ERRO: Tipo de Acao, invalido." + CRLF
   lRet = .F.
EndIf

Return lRet


/*
Função 	RH01_EXC - (Exclui Calendário...)
*/
Static Function RH01_EXC()

Local c_RCFKey := "" 
Local c_RCGKey := ""

cArqRCG := cArqCSV

oArquivo:Close()
oArquivo := FWFileReader():New(cArqRCG)
oArquivo:Open()
nLinhaAtu := 0

While (oArquivo:HasLine())
   If nLinhaAtu <= 1
      nLinhaAtu++
      IncProc("Lendo linha " + cValToChar(nLinhaAtu) + " de " + cValToChar(nTotLinhas) + "...")

      cLinAtu  := oArquivo:GetLine()
      aLinha   := StrTokArr(cLinAtu, ";")
      c_TnoAnt := aLinha[2]
      c_TnoTra := c_TnoAnt
      Loop
   EndIf

   If c_TnoTra <> "@@@"
      DbSelectArea("SR6")
      SR6->(DbSetOrder(1)) // Filial + Turno
      If ! SR6->(DbSeek(xFilial("SR6")+c_TnoTra))
         cLog += Strzero(nLinhaAtu, 7) + ";" + cLinAtu + "; ERRO: Turno não cadastrado." + CRLF
         l_Log := .T.
         nLinhaAtu++
         IncProc("Lendo linha " + cValToChar(nLinhaAtu) + " de " + cValToChar(nTotLinhas) + "...")

         cLinAtu  := oArquivo:GetLine()
         If cLinAtu = ""
            Exit
         EndIf
         aLinha   := StrTokArr(cLinAtu, ";")
         c_TnoAnt := aLinha[2]
         c_TnoTra := c_TnoAnt
         Loop
      EndIf
   EndIf

   // Verifica se existe bloqueio no período...
   If RH01_BLOQ()
      l_Log := .T.
      nLinhaAtu++
      IncProc("Lendo linha " + cValToChar(nLinhaAtu) + " de " + cValToChar(nTotLinhas) + "...")

      cLinAtu  := oArquivo:GetLine()
      If cLinAtu = ""
         Exit
      EndIf
      aLinha   := StrTokArr(cLinAtu, ";")
      c_TnoAnt := aLinha[2]
      c_TnoTra := c_TnoAnt
      Loop
   EndIf

   c_RCFKey := c_FilArq + "00001" + c_AnoMes + "   " + c_TnoTra + "01" 
   DbSelectArea("RCF")
   RCF->(DbSetOrder(2)) // Filial + Processo (0001) + Periodo + Roteiro + Turno
   If ! RCF->(DbSeek(c_RCFKey))
      cLog += Strzero(nLinhaAtu, 7) + ";" + cLinAtu + "; ERRO: Calendario NAO LOCALIZADO na (RCF)." + CRLF
      l_Log := .T.
   Else
      RecLock("RCF", .F.)
      DbDelete()
      RCF->( MsUnLock() )
      cLog += Strzero(nLinhaAtu, 7) + ";" + cLinAtu + "; Calendario Excluido na (RCF). " + CRLF
   EndIf

   c_RCGKey := c_FilArq + "00001" + c_AnoMes + "01" + "   " + c_TnoTra 
   DbSelectArea("RCG")
   RCG->(DbSetOrder(2)) // Filial + Processo (0001) + Periodo + Semana (01) + Roteiro + Turno + DiaMes
   If ! RCG->(DbSeek(c_RCGKey))
      cLog += Strzero(nLinhaAtu, 7) + ";" + cLinAtu + "; ERRO: Calendario NAO LOCALIZADO na (RCG)." + CRLF
      l_Log := .T.
   Else
      While ( (RCG_FILIAL+RCG_PROCES+RCG_PER+RCG_SEMANA+RCG_ROTEIR+RCG_TNOTRA) = ( c_RCGKey ) ) .And. ! EoF()
         If ( (RCG_FILIAL+RCG_PROCES+RCG_PER+RCG_SEMANA+RCG_ROTEIR+RCG_TNOTRA) = ( c_RCGKey ) )
            RecLock("RCG", .F.)
            DbDelete()
            RCG->( MsUnLock() )
         EndIf
         DbSkip()
      EndDo
      cLog += Strzero(nLinhaAtu, 7) + ";" + cLinAtu + "; Calendario Excluido na (RCG). " + CRLF
   EndIf

   While c_TnoAnt = c_TnoTra .And. (oArquivo:HasLine())
      nLinhaAtu++

      cLinAtu  := oArquivo:GetLine()
      If cLinAtu = ""
         Exit
      EndIf
      aLinha   := StrTokArr(cLinAtu, ";")
      c_TnoTra := aLinha[2]
      If c_TnoTra <> c_TnoAnt
         Exit
      EndIf

      IncProc("Lendo linha " + cValToChar(nLinhaAtu) + " de " + cValToChar(nTotLinhas) + "...")

      If l_Log
         cLog += Strzero(nLinhaAtu, 7) + ";" + cLinAtu + "; Erro na exclusão do calendario. " + CRLF
      Else
         cLog += Strzero(nLinhaAtu, 7) + ";" + cLinAtu + "; Calendario Excluido. " + CRLF
      EndIf

   EndDo
   c_TnoAnt := c_TnoTra
EndDo

Return


/*
Função 	RH01_INC - (Inclui Calendário...)
Return	lRet
*/
Static Function RH01_INC()

Local c_RCFKey := ""
Local c_RCGKey := ""

Local n_DUteis  := 0
Local n_DiaDSR  := 0
Local n_HrsDSR  := 0
Local n_DiaTra  := 0
Local n_HrsTra  := 0
Local n_DNTrab  := 0
Local n_DutilT  := 0
Local n_DNUtil  := 0
Local n_DDifVT  := 0
Local n_DRefei  := 0
Local n_DAlim   := 0
Local c_PegLin := .T.

cArqRCG := cArqCSV

oArquivo:Close()
oArquivo := FWFileReader():New(cArqRCG)
oArquivo:Open()
nLinhaAtu := 0

While (oArquivo:HasLine())
   If nLinhaAtu <= 1
      nLinhaAtu++
      IncProc("Lendo linha " + cValToChar(nLinhaAtu) + " de " + cValToChar(nTotLinhas) + "...")

      cLinAtu  := oArquivo:GetLine()
      aLinha   := StrTokArr(cLinAtu, ";")
      c_TnoAnt := aLinha[2]
      c_TnoTra := c_TnoAnt
      Loop
   EndIf

   If c_TnoTra <> "@@@"
      DbSelectArea("SR6")
      SR6->(DbSetOrder(1)) // Filial + Turno
      If ! SR6->(DbSeek(xFilial("SR6")+c_TnoTra))
         cLog += Strzero(nLinhaAtu, 7) + ";" + cLinAtu + "; ERRO: Turno não cadastrado." + CRLF
         l_Log := .T.
         nLinhaAtu++
         IncProc("Lendo linha " + cValToChar(nLinhaAtu) + " de " + cValToChar(nTotLinhas) + "...")

         cLinAtu  := oArquivo:GetLine()
         If cLinAtu = ""
            Exit
         EndIf
         aLinha   := StrTokArr(cLinAtu, ";")
         c_TnoAnt := aLinha[2]
         c_TnoTra := c_TnoAnt
         Loop
      EndIf
   EndIf

   // Verifica se existe bloqueio no período...
   If RH01_BLOQ()
      l_Log := .T.
      nLinhaAtu++
      IncProc("Lendo linha " + cValToChar(nLinhaAtu) + " de " + cValToChar(nTotLinhas) + "...")

      cLinAtu  := oArquivo:GetLine()
      If cLinAtu = ""
         Exit
      EndIf
      aLinha   := StrTokArr(cLinAtu, ";")
      c_TnoAnt := aLinha[2]
      c_TnoTra := c_TnoAnt
      Loop
   EndIf

   c_RCFKey := c_FilArq + "00001" + c_AnoMes + "   " + c_TnoTra + "01" 
   DbSelectArea("RCF")
   RCF->(DbSetOrder(2)) // Filial + Processo (0001) + Periodo + Roteiro + Turno
   If RCF->(DbSeek(c_RCFKey))
      cLog += Strzero(nLinhaAtu, 7) + ";" + cLinAtu + "; ERRO: Calendario JÁ EXISTE na (RCF)." + CRLF
      l_Log := .T.

      nLinhaAtu++
      IncProc("Lendo linha " + cValToChar(nLinhaAtu) + " de " + cValToChar(nTotLinhas) + "...")

      cLinAtu  := oArquivo:GetLine()
      If cLinAtu = ""
         Exit
      EndIf
      aLinha   := StrTokArr(cLinAtu, ";")
      c_TnoAnt := aLinha[2]
      c_TnoTra := c_TnoAnt
      Loop

   EndIf

   n_DUteis  := 0
   n_DiaDSR  := 0
   n_HrsDSR  := 0
   n_DiaTra  := 0
   n_HrsTra  := 0
   n_DNTrab  := 0
   n_DutilT  := 0
   n_DNUtil  := 0
   n_DDifVT  := 0
   n_DRefei  := 0
   n_DAlim   := 0

   c_TnoAnt := c_TnoTra
   c_PegLin := .F.
   While c_TnoAnt = c_TnoTra .And. (oArquivo:HasLine())
      IncProc("Lendo linha " + cValToChar(nLinhaAtu) + " de " + cValToChar(nTotLinhas) + "...")
      If c_PegLin
         cLinAtu   := oArquivo:GetLine()
         aLinha    := StrTokArr(cLinAtu, ";")
         c_TnoTra := aLinha[2]
         If c_TnoTra <> c_TnoAnt
            Exit
         EndIf
      Endif
      c_PegLin := .T.

      c_Filial := aLinha[1]
      d_DiaMes := CTOD(aLinha[3])
      c_TipDia := aLinha[4]
      c_VT     := aLinha[5]
      c_DifVT  := aLinha[6]
      c_VR     := aLinha[7]
      c_VA     := aLinha[8]
      c_Acao   := aLinha[9]

      // Valida linha...
      If ! RH01_LINHA()
         l_Log := .T.
         Loop
      EndIf

      c_RCGKey := c_Filial + "00001" + c_AnoMes + "01" + "   " + c_TnoTra + DTOS(d_DiaMes)
      DbSelectArea("RCG")
      RCG->(DbSetOrder(2)) // Filial + Processo (0001) + Periodo + Semana (01) + Roteiro + Turno + DiaMes
      If RCG->(DbSeek(c_RCGKey))
         cLog += Strzero(nLinhaAtu, 7) + ";" + cLinAtu + "; ERRO: DATA JÁ EXISTE na (RCG) para este calendario." + CRLF
         l_Log := .T.
      Else
         RecLock("RCG",.T.)
         RCG->RCG_FILIAL := c_Filial
         RCG->RCG_MES    := Substr(c_AnoMes, 5, 2)
         RCG->RCG_ANO    := Substr(c_AnoMes, 1, 4)
         RCG->RCG_PER    := c_AnoMes
         RCG->RCG_PROCES := "00001"
         RCG->RCG_ROTEIR := ""
         RCG->RCG_TNOTRA := c_TnoTra
         RCG->RCG_SEMANA := "01"
         RCG->RCG_DIAMES := d_DiaMes
         RCG->RCG_TIPDIA := c_TipDia
         RCG->RCG_VTRANS := c_VT
         RCG->RCG_DIFTRA := c_DifVT
         RCG->RCG_VREFEI := c_VR
         RCG->RCG_VALIM  := c_VA
         RCG->RCG_HRSTRA := If(c_TipDia $ ("1"), 8, 0)
         RCG->RCG_HRSDSR := If(c_TipDia $ ("34"), 8, 0)
         RCG->RCG_DTINI  := FirstDate(d_DiaMes)
         RCG->RCG_DTFIM  := LastDate(d_DiaMes)
         RCG->RCG_MODULO := "GPE"
         RCG->( MsUnLock() )

         n_DUteis  += If(c_TipDia $ ("12"), 1, 0)
         n_DiaDSR  += If(c_TipDia $ ("34"), 1, 0)
         n_HrsDSR  += If(c_TipDia $ ("34"), 8, 0)
         n_DiaTra  += If(c_TipDia $ ("1"), 1, 0)
         n_HrsTra  += If(c_TipDia $ ("1"), 8, 0)
         n_DNTrab  += If(c_TipDia $ ("2"), 1, 0)
         n_DutilT  += If(c_TipDia $ ("1") .And. c_VT = "1", 1, 0)
         n_DNUtil  += If(c_TipDia $ ("234") .And. c_VT = "1", 1, 0)
         n_DDifVT  += If(c_DifVT = "1", 1, 0)
         n_DRefei  += If(c_VR = "1", 1, 0)
         n_DAlim   += If(c_VA = "1", 1, 0)

      EndIf

      cLog += Strzero(nLinhaAtu, 7) + ";" + cLinAtu + "; OK" + CRLF

      nLinhaAtu++
   EndDo

   c_RCFKey := c_FilArq + "00001" + c_AnoMes + "   " + c_TnoAnt + "01" 
   DbSelectArea("RCF")
   RCF->(DbSetOrder(2)) // Filial + Processo (0001) + Periodo + Roteiro + Turno + Semana (01)
   If RCF->(DbSeek(c_RCFKey))
      cLog += Strzero(nLinhaAtu, 7) + ";" + cLinAtu + "; Erro na inclusão da (RCF)." + CRLF
      l_Log := .T.
   Else
      RecLock("RCF",.T.)
      RCF->RCF_FILIAL := c_Filial
      RCF->RCF_MES    := Substr(c_AnoMes, 5, 2)
      RCF->RCF_ANO    := Substr(c_AnoMes, 1, 4)
      RCF->RCF_PER    := c_AnoMes
      RCF->RCF_PROCES := "00001"
      RCF->RCF_ROTEIR := ""
      RCF->RCF_TNOTRA := c_TnoAnt
      RCF->RCF_SEMANA := "01"
      RCF->RCF_DTINI  := FirstDate(d_DiaMes)
      RCF->RCF_DTFIM  := LastDate(d_DiaMes)
      RCF->RCF_DCALCM := 30
      RCF->RCF_DPERIO := Day(LastDate(d_DiaMes))
      RCF->RCF_HRSDIA := 8
      RCF->RCF_DUTEIS := n_DUteis
      RCF->RCF_DIADSR := n_DiaDSR
      RCF->RCF_HRSDSR := n_HrsDSR
      RCF->RCF_DIATRA := n_DiaTra
      RCF->RCF_HRSTRA := n_HrsTra
      RCF->RCF_DNTRAB := n_DNTrab
      RCF->RCF_DUTILT := n_DutilT
      RCF->RCF_DNUTIL := n_DNUtil
      RCF->RCF_DDIFVT := n_DDifVT
      RCF->RCF_DREFEI := n_DRefei
      RCF->RCF_DALIM  := n_DAlim
      RCF->RCF_MODULO := "GPE"
      RCF->( MsUnLock() )
   EndIf

EndDo

Return
