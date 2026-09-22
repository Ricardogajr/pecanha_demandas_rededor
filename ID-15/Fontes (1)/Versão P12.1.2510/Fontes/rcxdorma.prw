#include "rwmake.ch"
#include "topconn.ch" 
#include "protheus.ch"
#include "vkey.ch"
#include 'fileio.ch'

/*
Funcao: RCXDORMA - Inclui Ocupantes de Posto (RCX) e atualiza SRA e RCLGera Tabelas de Periodos da Folha
Autor : Mauricio Siqueira
Data..: 21/11/19
Versão: Protheus12
Menu..: SIGAORG\MISCELANEA\EXTRAS\Ocupantes do Posto
Função: RCX_PROCES() - Rotina Principal
Função: RCX_GRV_LOG() - Grava Arquivo de Log
Função: RCX_VLD_ARQ() - Seleciona Arqvui
*/

User Function RCXDORMA()

Local oDlgLeTxt
Local aArea := GetArea()

Private cArquivo := ""
Private lOk      :=.F.
Private bOk      := { || If(RCX_PROCES(cArquivo), (lOk:=.T., oDlgLeTxt:End()) ,) }
Private bCancel  := { || lOk:=.F.,oDlgLeTxt:End() }

// Variáveis da RCX a serem gravadas...
Private c_Filial := ""
Private c_Posto  := ""
Private c_TipOcu := ""
Private d_DtIni  := ctod("//")
Private d_DtFim  := ctod("//")
Private c_FilFun := ""
Private c_MatFun := ""
Private c_FilOcu := ""
Private c_CodUsu := ""
Private c_Subst  := ""

Private l_LogRCX := .F.
Private c_Status  := ""


Define MsDialog oDlgLeTxt Title "Importação de Ocupantes de Postos (RCX)" From 08,15 To 18,080 Of GetWndDefault()
      
@ 050,028  Say 	 "Selecione o Arquivo:" 	Size 060,015 Of oDlgLeTxt Pixel
@ 050,082  MsGet  cArquivo 		            Size 122,008 Of oDlgLeTxt Pixel
@ 050,210  Button "…"			            Size 010,010 Action Eval({|| cArquivo:=RCX_VLD_ARQ() }) Of oDlgLeTxt Pixel

Activate MsDialog oDlgLeTxt Centered On Init (EnchoiceBar(oDlgLeTxt, bOk, bCancel))

//-- encerramento ----------------------------------------------------------------------
oDlgLeTxt := nil

RestArea(aArea)

Return


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} RCX_PROCES
Processa leitura e gravação do arquivo texto.

@author    Mauricio Siqueira
@version   11.3.7.201712061349
@since     10/10/2019
/*/
//------------------------------------------------------------------------------------------
Static Function RCX_PROCES(cArq_CSV)

Local aDados   := {}
Local nTot_lin := 0
Local nLInha   :=0

// Variaveis de log...
Local nTot_REJ  := 0
Local nTot_OK   := 0

// Tratamento de Log...
cArq_Log  := "C:\TEMP\RCX_LOG_"+DTOS(dDataBase)+".CSV"
nHdl := fCreate(cArq_Log)
If nHdl == -1
   MsgAlert("O arquivo "+ cArq_Log + " não pôde ser criado! Verifique se existe a pasta C:\TEMP em sua máquina.","Atenção !")
   Return
Endif

If (nHandle := FT_FUse(AllTrim(cArq_CSV)))== -1
   MsgStop( "Erro na abertura do arquivo "+cArq_CSV)
   Return
EndIf

//inicialização de 'buffer' e primeira leitura
nTot_Lin := FT_FLASTREC()
nLinha := 1

FT_FGOTOP()

// Carrega o arquivo texto...
While !FT_FEOF()
   IncProc("Lendo arquivo texto, linha "+Strzero(nLinha, 4))
 
   cLinha := FT_FREADLN()
   If nLinha > 1 // Cabeçalho
	  AADD(aDados,Separa(cLinha, ";", .T.))
   EndIf
 
   FT_FSKIP()
   nLinha ++

EndDo
 
// Processa as alterações...
Begin Transaction
   
   ProcRegua(Len(aDados))      
   
   c_Status := "CAB"
   RCX_GRV_LOG(c_Status)      
   c_Status := ""
   
   For i:=1 to Len(aDados)
      
      IncProc("Importando ...")
        
      // Monta variáveis da RCX a ser gravada...
      c_Filial := aDados[i, 1]
      c_Posto  := aDados[i, 2]
      c_TipOcu := aDados[i, 3]
      d_DtIni  := aDados[i, 4]
      d_DtFim  := aDados[i, 5]
      c_FilFun := aDados[i, 6]
      c_MatFun := aDados[i, 7]
      c_FilOcu := aDados[i, 8]
      c_Subst  := aDados[i, 10]
      c_CodUsu := ""
      l_LogRCX := .F.

      // Verifica se o "posto" existe no Cadastro de postos
	  dbSelectArea("RCL")
	  dbSetOrder(2)
      If !dbseek(c_Filial+c_Posto)
         // Gravar log
         c_Status := "Rejeitado. Posto ("+c_Posto+") nao cadastrado na RCL."
         RCX_GRV_LOG(c_Status)
         nTot_Rej ++
         l_LogRCX := .T.
         FT_FSKIP()
         Loop
      EndIf

      // Verifica se existem postos disponiveis.
      If RCL_OPOSTO >= RCL_NPOSTO
         // Gravar log
         c_Status := "Rejeitado. Posto ("+c_Posto+") nao possui vagas disponiveis."
         RCX_GRV_LOG(c_Status)
         nTot_Rej ++
         l_LogRCX := .T.
         FT_FSKIP()
         Loop
      EndIf
        
      // Recupera Dados do Posto
      c_Depto_RCL  := RCL_DEPTO
      c_Cargo_RCL  := RCL_CARGO
      c_Funcao_RCL := RCL_FUNCAO
      c_CCusto_RCL := RCL_CC
      c_CCust_RCL  := RCL_CC

      // Verifica se a matrícula existe na SRA
	  dbSelectArea("SRA")
	  dbSetOrder(1)
      If !dbseek(c_Filial+c_MatFun)
         // Gravar log
         c_Status := "Rejeitado. Matricula nao localizada na SRA"
         RCX_GRV_LOG(c_Status)
         nTot_Rej ++
         l_LogRCX := .T.
         FT_FSKIP()
         Loop
      EndIf

      // Verifica se o funcionário está demitido
      If RA_SITFOLH = "D"
         // Gravar log
         c_Status := "Rejeitado. Funcionario demitido."
         RCX_GRV_LOG(c_Status)
         nTot_Rej ++
         l_LogRCX := .T.
         FT_FSKIP()
         Loop
      Endif
        
      // Verifica se o funcionário ja está com posto
      If !Empty(RA_POSTO)
         // Gravar log
         c_Status := "Rejeitado. Matricula ja possui um posto cadastrado ("+RA_POSTO+")."
         RCX_GRV_LOG(c_Status)
         nTot_Rej ++
         l_LogRCX := .T.
         FT_FSKIP()
         Loop
      Endif
        
      // Recupera dados do Cadastro de Funcionários
      c_CIC       := RA_CIC		// Cic
      c_Depto_SRA := RA_DEPTO	// Departamento
      c_CCust_SRA := RA_CC		// Centro de Custo
      c_Cargo_SRA := RA_CARGO	// Cargo

      // Verifica Divergência de Cargo
      If c_Cargo_SRA <> c_Cargo_RCL
         // Gravar log
         c_Status := "Rejeitado. Cargo SRA ("+c_Cargo_SRA+") diferente do cargo na RCL ("+c_Cargo_RCL+")."
         RCX_GRV_LOG(c_Status)
         nTot_Rej ++
         l_LogRCX := .T.
         FT_FSKIP()
         Loop
      EndIf
		
      // Verifica Divergência de Centro de Custos
      If c_CCust_SRA <> c_CCust_RCL
         // Gravar log
         c_Status := "Rejeitado. C.Custo SRA ("+c_CCust_SRA+") diferente do C.Custo na RCL ("+c_CCust_RCL+")."
         RCX_GRV_LOG(c_Status)
         nTot_Rej ++
         l_LogRCX := .T.
         FT_FSKIP()
         Loop
      EndIf
        
      // Verifica se a matrícula possui cadastro de pessoas
	  dbSelectArea("RD0")
	  dbSetOrder(6)
	  dbGoTop()
      If !dbseek(Space(08)+c_CIC)	// A RD0 é compartilhada...
         c_Status := "Rejeitado. Matricula nao encontrada no Cadastro de Pessoas (RD0)."
         RCX_GRV_LOG(c_Status)
         nTot_Rej ++
         l_LogRCX := .T.
         FT_FSKIP()
         Loop
      EndIf
      
      c_CodUsu := RD0_CODIGo
        
      // Popula RCX...
	  dbSelectArea("RCX")
	  dbSetOrder(1)
	  dbGoTop()
	  If !dbSeek(c_Filial+c_Posto+c_FilOcu+c_CodUsu)
         Reclock("RCX", .T.)
	     RCX_FILIAL := c_Filial
	 	 RCX_POSTO  := c_Posto
	 	 RCX_TIPOCU := c_TipOcu
	  	 RCX_DTINI  := Ctod(d_DtIni)
	  	 RCX_FILFUN := c_Filial
	  	 RCX_MATFUN := c_MatFun
	  	 RCX_CODOCU := c_CodUsu
	  	 RCX_SUBST  := c_Subst 
	 	
		 RCX->(MsUnlock())
         // Atualiza Log ...
         c_Status := "Ok"
         RCX_GRV_LOG(c_Status)
         nTot_Ok ++
      Else
         c_Status := "Rejeitado. Ocupante ("+c_Matfun+"), ja cadastrado na ( RCX )."
         RCX_GRV_LOG(c_Status)
         nTot_Rej ++
         l_LogRCX := .T.
         Loop
	  EndIf
		
      // Atualiza SRA...
	  dbSelectArea("SRA")
	  dbSetOrder(1)
	  dbGoTop()
	  If dbSeek(c_Filial+c_MatFun)
         Reclock("SRA",.F.)
		 RA_POSTO := c_Posto
		 RA_DEPTO := c_Depto_RCL

         SRA->(MsUnlock())
      EndIf
		   	
      // Atualiza RCL...
	  dbSelectArea("RCL")
	  dbSetOrder(2)
      If dbSeek(c_Filial+c_Posto)
		 Reclock("RCL",.F.)
         RCL_OPOSTO := RCL_OPOSTO + 1
         RCL_STATUS := "2"
         RCL->(MsUnlock())
	  EndIf
	  
      FT_FSKIP()
   Next i
End Transaction
 
fClose(nHdl)

fClose(nHandle)

MsgInfo("Total de ocupantes gerados: "+Strzero(nTot_OK,6))

MsgInfo("Total de ocupantes rejeitados: "+Strzero(nTot_REJ,6))


Return
	

/*
Função 	RCX_GRV_LOG - Gravar log da operação
Param	cTipoLog, caracter, Tipo de Linha de Log
Return	lRet, Se tudo ok, continua...
*/
Static Function RCX_GRV_LOG(cTipoLog)


Local cTexto := ""

If cTipoLog = "CAB"							// Cabeçalho
   cTexto += "RCX_FILIAL"     				// Filial Processada
   cTexto += ";"							// Separador
   cTexto += "RCX_POSTO"     				// Posto   	
   cTexto += ";"							// Separador
   cTexto += "RCX_TIPOCU"     				// Tipo Ocupante   
   cTexto += ";"							// Separador
   cTexto += "RCX_DTINI"     				// Data Inicial da Ocupação	
   cTexto += ";"							// Separador
   cTexto += "RCX_DTFIM"     				// Data Inicial da Ocupação 
   cTexto += ";"							// Separador
   cTexto += "RCX_FILFUN"     				// Filial do Funcionario   	
   cTexto += ";"							// Separador
   cTexto += "RCX_MATFUN"     				// Matricula do funcionario	
   cTexto += ";"							// Separador
   cTexto += "RCX_FILOCU"     				// Filial do Ocupante   	
   cTexto += ";"							// Separador
   cTexto += "RCX_CODOCU"     				// Cod. Ocupante do Posto	
   cTexto += ";"							// Separador
   cTexto += "RCX_SUBST"     				// Cod. Substituto
   cTexto += ";"							// Separador
   cTexto += "RCX_CODMOV"     				// Vazio
   cTexto += ";"							// Separador
   cTexto += "RCX_AFAS"     				// Vazio
   cTexto += ";"							// Separador
   cTexto += "RCX_DTCADS"     				// Vazio
   cTexto += ";"							// Separador
   cTexto += "STATUS"     				    // Status
Else
   cTexto += c_Filial     					// Filial Processada
   cTexto += ";"							// Separador
   cTexto += c_Posto     					// Posto   	
   cTexto += ";"							// Separador
   cTexto += c_TipOcu     					// Tipo Ocupante   
   cTexto += ";"							// Separador
   cTexto += d_DtIni     					// Data Inicial da Ocupação	
   cTexto += ";"							// Separador
   cTexto += d_DtFim     	   				// Data Inicial da Ocupação	
   cTexto += ";"							// Separador
   cTexto += c_FilFun     					// Filial do Funcionario 	
   cTexto += ";"							// Separador
   cTexto += c_MatFun     					// Matricula do Funcionario
   cTexto += ";"							// Separador
   cTexto += c_FilOcu     					// Filial do Ocupante
   cTexto += ";"							// Separador
   cTexto += c_CodUsu     					// Código do Usuário
   cTexto += ";"							// Separador
   cTexto += c_Status						// Status
EndIf

// Salto de Linha ...
cTexto += CHR(13)+CHR(10)

If fWrite(nHdl,cTexto,Len(cTexto)) != Len(cTexto)
	Alert("Atenção ! ERRO gravando o arquivo de log ")
Endif

Return

	
//------------------------------------------------------------------------------------------
/*/{Protheus.doc} RCX_VLD_ARQ
Seleciona o Arqueivo

@author    Mauricio Siqueira
@version   11.3.7.201712061349
@since     10/10/2019
/*/
//------------------------------------------------------------------------------------------
Static Function RCX_VLD_ARQ()

Local cMaskDir     := "Arquivos .CSV (*.CSV) |*.CSV|"
Local cTitTela     := "Arquivo para Importação"
Local lInfoOpen    := .T.
Local lDirServidor := .T.
Local lKeepCase    := .T.
Local cOldFile     := cArquivo
	
cArquivo := cGetFile(cMaskDir,cTitTela,NIL,cArquivo,lInfoOpen, (GETF_LOCALHARD+GETF_NETWORKDRIVE) ,lDirServidor,lKeepCase)
	
If !File(cArquivo)
   MsgStop("Arquivo Não Existe!")
   cArquivo := cOldFile
   Return .F.
EndIf
	
Return cArquivo
