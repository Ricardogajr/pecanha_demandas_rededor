#include "rwmake.ch"
#include "topconn.ch" 
#include "protheus.ch"
#include "vkey.ch"
#include "fileio.ch"

/*
Funcao: RHNDORMA - Importa tabela RHN
Autor : Mauricio Siqueira
Data..: 06/12/19
Versão: Protheus12
Menu..: SIGAGPE\MISCELANEA\ESPECIFICOS\Importa RHN
Função: RHN_PROCES() - Rotina Principal
Função: RHN_GRV_LOG() - Grava Arquivo de Log
Função: RHN_VLD_ARQ() - Seleciona Arqvui   
Função: RHN_VLD_UNI() - Verifica Chave Unica
*/

User Function RHNDORMA()

Local oDlgLeTxt
Local aArea := GetArea()

Private cArquivo := ""
Private lOk      :=.F.
Private bOk      := { || If(Proc_RHN(cArquivo), (lOk:=.T., oDlgLeTxt:End()) ,) }
Private bCancel  := { || lOk:=.F.,oDlgLeTxt:End() }
Private cArq_CSV := ""
Private cQuery
Private c_RHN_UNQ := ""

// Variáveis da RHN a serem gravadas...
Private c_Filial := ""
Private c_Mat    := ""
Private d_Data   := ctod("//")
Private c_Operac := ""
Private c_Origem := ""
Private c_TpAlt  := ""
Private c_Codigo := SPACE(02)
Private c_Nome   := ""
Private c_TpForn := ""
Private c_CodFor := ""
Private c_TpPlan := ""
Private c_Plano  := ""
Private c_PD     := SPACE(03)
Private c_AgrPD  := SPACE(03)
Private c_PerIni := ""
Private c_PerFim := ""
Private d_DatFim := ""
Private c_PDDifT := ""
Private c_PDDifD := ""

Private l_LogRHN := .F.
Private c_Status  := ""


Define MsDialog oDlgLeTxt Title "Importação de Trocas de Planos (RHN)" From 08,15 To 18,080 Of GetWndDefault()
      
@ 050,028  Say 	 "Selecione o Arquivo:" 	Size 060,015 Of oDlgLeTxt Pixel
@ 050,082  MsGet  cArquivo 		            Size 122,008 Of oDlgLeTxt Pixel
@ 050,210  Button "…"			            Size 010,010 Action Eval({|| cArquivo:=RHN_VLD_ARQ() }) Of oDlgLeTxt Pixel

Activate MsDialog oDlgLeTxt Centered On Init (EnchoiceBar(oDlgLeTxt, bOk, bCancel))

//-- encerramento ----------------------------------------------------------------------
oDlgLeTxt := nil

RestArea(aArea)

Return


//------------------------------------------------------------------------------------------
Static Function PROC_RHN(cArq_CSV)

Processa({|| RHN_PROCES(cArq_CSV)},"Aguarde Processando...")

Return


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} RHN_PROCES
Processa leitura e gravação do arquivo texto.

@author    Mauricio Siqueira
@version   11.3.7.201712061349
@since     10/10/2019
/*/
//------------------------------------------------------------------------------------------
Static Function RHN_PROCES(c_Arq_CSV)

Local aDados   := {}
Local nTot_lin := 0
Local nLInha   :=0

// Variaveis de log...
Local nTot_REJ  := 0
Local nTot_OK   := 0

// Tratamento de Log...
cArq_Log  := "C:\TEMP\RHN_LOG_"+DTOS(dDataBase)+".CSV"
nHdl := fCreate(cArq_Log)
If nHdl == -1
   MsgAlert("O arquivo "+ cArq_Log + " não pôde ser criado! Verifique se existe a pasta C:\TEMP em sua máquina.","Atenção !")
   Return
Endif

If (nHandle := FT_FUse(AllTrim(c_Arq_CSV)))== -1
   MsgStop( "Erro na abertura do arquivo "+c_Arq_CSV)
   Return
EndIf


//inicialização de 'buffer' e primeira leitura
nTot_Lin := FT_FLASTREC()
nLinha := 1
FT_FGOTOP()
                          
ProcRegua(nTot_Lin)

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

ProcRegua(nTot_Lin)
 
// Processa as alterações...
Begin Transaction
 
   c_Status := "CAB"
   RHN_GRV_LOG(c_Status)      
   c_Status := ""
   
   For i:=1 to Len(aDados)
      
      IncProc("Importando ..."+ALLTRIM(STR(i))+"/"+ALLTRIM(STR(nTot_Lin)) )
        
      // Monta variáveis da RHN a ser gravada...
	  c_Filial := aDados[i, 1]
	  c_Mat    := aDados[i, 2]
 	  d_Data   := aDados[i, 3]
	  c_Operac := aDados[i, 4]
	  c_Origem := aDados[i, 5]
	  c_TpAlt  := aDados[i, 6]
	  c_Codigo := if( Len( aDados[i, 7] ) > 0, aDados[i, 7], SPACE(02) )
	  c_Nome   := aDados[i, 8] 
	  c_TpForn := aDados[i, 9]
	  c_CodFor := aDados[i, 10]
	  c_TpPlan := aDados[i, 11]
	  c_Plano  := aDados[i, 12]
	  c_PD     := if( Len( aDados[i, 13] ) > 0, aDados[i, 13], SPACE(03) )
	  c_AgrPD  := if( Len( aDados[i, 14] ) > 0, aDados[i, 14], SPACE(03) )
	  c_PerIni := aDados[i, 15]
	  c_PerFim := aDados[i, 16]
	  d_DatFim := aDados[i, 17]
	  c_PdDifT := aDados[i, 18]
	  c_PdDifD := aDados[i, 19]

      // Verifica se a matrícula existe na SRA
	  dbSelectArea("SRA")
	  dbSetOrder(1)
      If !dbseek(c_Filial+c_Mat)
         // Gravar log
         c_Status := "Rejeitado. Matricula nao localizada na SRA"
         RHN_GRV_LOG(c_Status)
         nTot_Rej ++
         l_LogRHN := .T.
         FT_FSKIP()
         Loop
      EndIf

      // Valida Data.
      If Empty(d_Data)
         // Gravar log
         c_Status := "Rejeitado. Campo RHN_DATA vazio(campo obrigatorio)."
         RHN_GRV_LOG(c_Status)
         nTot_Rej ++
         l_LogRHN := .T.
         FT_FSKIP()
         Loop
      EndIf

      // Valida Operação
      If Empty(c_Operac)
         // Gravar log
         c_Status := "Rejeitado. Campo RHN_OPERAC vazio(campo obrigatorio)."
         RHN_GRV_LOG(c_Status)
         nTot_Rej ++
         l_LogRHN := .T.
         FT_FSKIP()
         Loop
      EndIf

      // Valida Origem
      If Empty(c_Origem)
         // Gravar log
         c_Status := "Rejeitado. Campo RHN_ORIGEM vazio(campo obrigatorio)."
         RHN_GRV_LOG(c_Status)
         nTot_Rej ++
         l_LogRHN := .T.
         FT_FSKIP()
         Loop
      EndIf

      // Valida TpAlt
      If Empty(c_TpAlt)
         // Gravar log
         c_Status := "Rejeitado. Campo RHN_TPALT vazio(campo obrigatorio)."
         RHN_GRV_LOG(c_Status)
         nTot_Rej ++
         l_LogRHN := .T.
         FT_FSKIP()
         Loop
      EndIf

      // Valida Código de Dependente
      If Empty(c_Codigo) .And. ( c_Origem = "2" )
         // Gravar log
         c_Status := "Rejeitado. Informacao de dependente sem a devida identificacao do mesmo, campo RHN_CODIGO vazio(campo obrigatorio)."
         RHN_GRV_LOG(c_Status)
         nTot_Rej ++
         l_LogRHN := .T.
         FT_FSKIP()
         Loop
      EndIf

      // Valida Tipo de Fornecedor
      If !(c_TpForn $ '12')
         // Gravar log
         c_Status := "Rejeitado. Tipo de fornecedor invalido, campo RHN_TPFORN (campo obrigatorio)."
         RHN_GRV_LOG(c_Status)
         nTot_Rej ++
         l_LogRHN := .T.
         FT_FSKIP()
         Loop
      EndIf

      // Valida codigo do fornecedor
      If Empty(c_CodFor)
         // Gravar log
         c_Status := "Rejeitado. Campo RHN_CODFOR vazio(campo obrigatorio)."
         RHN_GRV_LOG(c_Status)
         nTot_Rej ++
         l_LogRHN := .T.
         FT_FSKIP()
         Loop
      EndIf

      // Valida Tipo de Plano
      If !(c_TpPlan $ '12345')
         // Gravar log
         c_Status := "Rejeitado. Tipo de plano invalido, campo RHN_TPPLAN (campo obrigatorio)."
         RHN_GRV_LOG(c_Status)
         nTot_Rej ++
         l_LogRHN := .T.
         FT_FSKIP()
         Loop
      EndIf

      // Valida Plano
      If Empty(c_Plano)
         // Gravar log
         c_Status := "Rejeitado. Plano invalido, campo RHN_PLANO (campo obrigatorio)."
         RHN_GRV_LOG(c_Status)
         nTot_Rej ++
         l_LogRHN := .T.
         FT_FSKIP()
         Loop
      EndIf

      // Valida Verba de Titular
      If Empty(c_PD) .And. ( c_Origem = "1" )
         // Gravar log
         c_Status := "Rejeitado. Informacao de TITULAR sem a devida identificacao da verba, campo RHN_PD (campo obrigatorio)."
         RHN_GRV_LOG(c_Status)
         nTot_Rej ++
         l_LogRHN := .T.
         FT_FSKIP()
         Loop
      EndIf

      // Valida Verba de Dependente
      If Empty(c_AGRPD) .And. ( c_Origem = "2" )
         // Gravar log
         c_Status := "Rejeitado. Informacao de DEPENDENTE sem a devida identificacao da verba, campo RHN_PDAGR (campo obrigatorio)."
         RHN_GRV_LOG(c_Status)
         nTot_Rej ++
         l_LogRHN := .T.
         FT_FSKIP()
         Loop
      EndIf

      // Valida Plano
      If Empty(c_Perini)
         // Gravar log
         c_Status := "Rejeitado. Periodo invalido, campo RHN_PERINI (campo obrigatorio)."
         RHN_GRV_LOG(c_Status)
         nTot_Rej ++
         l_LogRHN := .T.
         FT_FSKIP()
         Loop
      EndIf

      
      // Monta chave única da tabela RHN
      c_RHN_UNQ  := c_Filial+c_Mat+DTOS(CTOD(d_Data))+c_Codigo+c_TpForn
      If RHN_VLD_UNI()
         // Gravar log
         c_Status := "Rejeitado. Historico ja existe."
         RHN_GRV_LOG(c_Status)
         nTot_Rej ++
         l_LogRHN := .T.
         FT_FSKIP()
         Loop
      Else
         // Popula RHN...
	     Reclock("RHN", .T.)
	     RHN_FILIAL := c_Filial
	  	 RHN_MAT    := c_Mat
	  	 RHN_DATA   := CTOD(d_Data)
	  	 RHN_OPERAC := c_Operac 
	  	 RHN_ORIGEM := c_Origem
	  	 RHN_TPALT  := c_TpAlt
	  	 RHN_CODIGO := c_Codigo 
	  	 RHN_NOME   := c_Nome 
	  	 RHN_TPFORN := c_TpForn 
	  	 RHN_CODFOR := c_CodFor
	  	 RHN_TPPLAN := c_TpPlan 
	  	 RHN_PLANO  := c_Plano
	  	 RHN_PD     := c_PD 
	  	 RHN_PDAGR  := c_AgrPD
	  	 RHN_PERINI := c_PerIni 
	  	 RHN_PERFIM := c_PerFim
	  	 RHN_DATFIM := CTOD(d_DatFim)
	  	 RHN_PDDIFT := c_PdDifT
	  	 RHN_PDDIFD := c_PdDifD
 	
		 RHN->(MsUnlock())

         // Atualiza Log ...
         c_Status := "Ok"
         RHN_GRV_LOG(c_Status)
         nTot_Ok ++
	  EndIf
 
      FT_FSKIP()
   Next i
End Transaction
 
fClose(nHdl)

fClose(nHandle)

MsgInfo("Total de registros gerados: "+Strzero(nTot_OK,6))

MsgInfo("Total de registros rejeitados: "+Strzero(nTot_REJ,6))


Return
	

/*
Função 	RHN_GRV_LOG - Gravar log da operação
Param	cTipoLog, caracter, Tipo de Linha de Log
Return	lRet, Se tudo ok, continua...
*/
Static Function RHN_GRV_LOG(cTipoLog)


Local cTexto := ""

If cTipoLog = "CAB"					// Cabeçalho
   cTexto += "RHN_FILIAL" 			// Filial Processada
   cTexto += ";"					// Separador
   cTexto += "RHN_MAT"  			// Matricula
   cTexto += ";"					// Separador
   cTexto += "RHN_DATA" 			// Data do Movimento  
   cTexto += ";"					// Separador
   cTexto += "RHN_OPERAC"     		// Operação
   cTexto += ";"					// Separador
   cTexto += "RHN_ORIGEM"     		// Origem da Informação
   cTexto += ";"					// Separador
   cTexto += "RHN_TPALT"     		// Tipo de Alteração
   cTexto += ";"					// Separador
   cTexto += "RHN_CODIGO"     		// Cod. Dependente
   cTexto += ";"					// Separador
   cTexto += "RHN_NOME"     		// Nome
   cTexto += ";"					// Separador
   cTexto += "RHN_TPFORN"     		// Tipo Fornecedor
   cTexto += ";"					// Separador
   cTexto += "RHN_CODFOR"     		// Cod. Fornecedor
   cTexto += ";"					// Separador
   cTexto += "RHN_TPPLAN"     		// Tipo Plano
   cTexto += ";"					// Separador
   cTexto += "RHN_PLANO"     		// Cod. Plano
   cTexto += ";"					// Separador
   cTexto += "RHN_PD"     			// Verba Titular
   cTexto += ";"					// Separador
   cTexto += "RHN_PDAGR"     		// Verba Dependente
   cTexto += ";"					// Separador
   cTexto += "RHN_PERINI"     		// Periodo Inicial
   cTexto += ";"					// Separador
   cTexto += "RHN_PERFIM"     		// Periodo Final
   cTexto += ";"					// Separador
   cTexto += "RHN_DATFIM"     		// Data Fim Plano
   cTexto += ";"					// Separador
   cTexto += "RHN_PDDIFT"     		// Verba Dif. Tit.
   cTexto += ";"					// Separador
   cTexto += "RHN_PDDIFD"     		// Verba Dif. Dep.
   cTexto += ";"					// Separador
   cTexto += "STATUS"     			// Status
Else
   cTexto += c_Filial     			// Filial Processada
   cTexto += ";"					// Separador
   cTexto += c_Mat       			// Matricula
   cTexto += ";"					// Separador
   cTexto += d_Data     			// Data do Movimento  
   cTexto += ";"					// Separador
   cTexto += c_Operac		   		// Operação
   cTexto += ";"					// Separador
   cTexto += c_Origem	     		// Origem da Informação
   cTexto += ";"					// Separador
   cTexto += c_TpAlt	     		// Tipo de Alteração
   cTexto += ";"					// Separador
   cTexto += c_Codigo	     		// Cod. Dependente
   cTexto += ";"					// Separador
   cTexto += c_Nome		     		// Nome
   cTexto += ";"					// Separador
   cTexto += c_TpForn	     		// Tipo Fornecedor
   cTexto += ";"					// Separador
   cTexto += c_CodFor	     		// Cod. Fornecedor
   cTexto += ";"					// Separador
   cTexto += c_TpPlan	     		// Tipo Plano
   cTexto += ";"					// Separador
   cTexto += c_Plano	     		// Cod. Plano
   cTexto += ";"					// Separador
   cTexto += c_PD	     			// Verba Titular
   cTexto += ";"					// Separador
   cTexto += c_AgrPD	     		// Verba Dependente
   cTexto += ";"					// Separador
   cTexto += c_PerIni	     		// Periodo Inicial
   cTexto += ";"					// Separador
   cTexto += c_PerFim	     		// Periodo Final
   cTexto += ";"					// Separador
   cTexto += d_DatFim	     		// Data Fim Plano
   cTexto += ";"					// Separador
   cTexto += c_PDDifT	     		// Verba Dif. Tit.
   cTexto += ";"					// Separador
   cTexto += c_PDDifD	     		// Verba Dif. Dep.
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
/*/{Protheus.doc} RHN_VLD_ARQ
Seleciona o Arqueivo

@author    Mauricio Siqueira
@version   11.3.7.201712061349
@since     10/10/2019
/*/
//------------------------------------------------------------------------------------------
Static Function RHN_VLD_ARQ()

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


/*
Função 	RHN_VLD_UNI - Validar Chave única
Return	lRet
*/
Static Function RHN_VLD_UNI(cTipoLog)

Local c_REG_RHN := ""
Local l_Ret     := .T.

// c_RHN_Unik  := c_Filial+c_Mat+Dtod(c_Data)+c_Codigo+c_TpForn

// Chave Única ...
cQuery := "SELECT RHN_FILIAL, RHN_MAT, RHN_DATA, RHN_CODIGO, RHN_TPFORN FROM " + RETSQLNAME("RHN") + " "
cQuery += "WHERE D_E_L_E_T_ <> '*' "
cQuery += "AND RHN_FILIAL = '" + c_Filial + "' "
cQuery += "AND RHN_MAT = '" + c_Mat + "' "
cQuery += "AND RHN_DATA = '" + DTOS(CTOD(d_Data)) + "' "
cQuery += "AND RHN_CODIGO = '" + c_Codigo + "' " 
cQuery += "AND RHN_TPFORN = '" + c_TpForn + "' "
cQuery := ChangeQuery( cQuery )

dbUseArea( .T., 'TOPCONN', TCGenQry( , , cQuery ), 'TRHN', .F., .T. )

c_REG_RHN := TRHN->RHN_FILIAL+TRHN->RHN_MAT+TRHN->RHN_DATA+TRHN->RHN_CODIGO+TRHN->RHN_TPFORN

TRHN->(DbCloseArea())

If c_RHN_UNQ = c_REG_RHN
   l_Ret := .T.
Else
   l_Ret := .F.
EndIf

Return(l_Ret)                                                         
