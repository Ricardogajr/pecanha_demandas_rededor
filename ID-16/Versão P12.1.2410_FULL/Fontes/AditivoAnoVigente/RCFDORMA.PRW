#INCLUDE "Protheus.ch"
#INCLUDE "TopConn.Ch"
#INCLUDE "FONT.CH"    


/*
Funcao: RCFDORMA - Gera Tabelas de Periodos da Folha
Autor : Mauricio Siqueira
Data..: 21/11/19
Versão: Protheus12
Menu..: SIGAGPE\MISCELANEA\ESPECIFICOS\Cria Periodos
Função: RCF_TELA()   - Tela de Parametros
Função: RCF_VALID()  - Valida Parametros
Função: RCF_PROCES() - Função Principal
Função: RCF_GRV_TAB  - Incluir registros nas tabelas
Data..: 03/07/22 - Mauricio Siqueira
Motivo: Inclusão de opção para professor - Projeto UNINEVES
*/

User Function RCFDORMA()

Local aArea    := GetArea()
Local aSays	   := {}
Local aButtons := {}	
Local nOpca    := 0

Private cPerg    := "RCFDORMA "

// Controle de Log...
Private cArqTXT  := ""
Private nRCF_ok  := 0
Private nRCF_REJ := 0

// Controle de texto do Log...
Private lCab_TXT    := 0
Private cStatus_TXT := ""
Private lGravou_RCF := .t.

// Variaveis dos campos da RCF...
Private c_Filial := SPACE(08)
Private c_Mes    := SPACE(08)
Private c_Ano    := SPACE(04)
Private c_Per    := SPACE(06)
Private c_Proces := SPACE(05)
Private c_TnoTra := "@@@"
Private c_Semana := "01"
Private d_DtIni  := CTOD("//")
Private d_DtFim  := CTOD("//")
Private n_DCalcm := 0
Private n_DPerio := 0
Private n_HrsDia := 0
Private n_DiaDSR := 0
Private n_DUteis := 0
Private n_HrsDSR := 0
Private n_DiaTra := 0
Private n_HrsTra := 0
Private n_DNTrab := 0
Private n_DUtilt := 0
Private n_DRefei := 0
Private n_DAlim  := 0
Private c_Modulo := "GPE"

// Variaveis dos campos da RCH/RFQ...
Private c_NumPag := "01"
Private c_Roteir := SPACE(03)
Private d_DtPago := CTOD("//")
Private d_DtInte := CTOD("//")
Private d_DtFech := CTOD("//")
Private c_PerSel := "2"
Private c_RCHSta := "5"
Private c_RFQSta := "2"
Private c_Compl  := "2"

// Tela de Parametros...
RCF_TELA()

cCadastro := OemToAnsi("Gerar tabelas de Período")
	
AADD(aSays,OemToAnsi("Este programa realiza o processo de geração do periodos") )
AADD(aSays,OemToAnsi("para as rotinas do módulo de Gestão de Pessoal.")) 
	
AADD(aButtons, { 5,.T.,{|| Pergunte(cPerg,.T.)  } } )
AADD(aButtons, { 1,.T.,{|o| nOpca := 1,If(RCF_VALID(MV_PAR01), FechaBatch(), nOpca:=0) }} )
AADD(aButtons, { 2,.T.,{|o| FechaBatch() }} )
		
FormBatch(cCadastro,aSays,aButtons)

If nOpca == 1                      
   Processa({|lEnd| RCF_PROCES(),"Gerando tabelas de período", "Gerando períodos . . ."})
EndIf

RestArea(aArea)

Return



/*
Função 	RCF_VALID - Validação dos Parâmetros
Param   MV_PAR01 - Filial a ser gerada
Return	lRet, Se tudo ok, continua...
*/
Static Function RCF_VALID(cFilial_De)

Local lRet := .F.

If MsgYesNo("Confirma a configuração dos parâmetros?","Atenção")

	lRet := .T.
                        
	// Incluir validações...
EndIf

Return lRet


/*
Função 	RCF_PROCES - Processa Rotina Principal
Return	lRet, habilitado para continuar ou não
*/
Static Function RCF_PROCES()

Local aArea   := GetArea()
Local cQuery  := ""
Local aFunc   := {}
Local nT       := 0

Local cCancela  := .F.
Local aStru     := Nil
Local d_Dt_Fim_Proc := CTOD("//")

Local aStru := SRA->( DBStruct() )

// Tratamento de Log...
cArqTXT  := "C:\TEMP\RCF_"+MV_PAR01+"_"+DTOS(dDataBase)+".TXT"
nHdl := fCreate(cArqTXT)
If nHdl == -1
	MsgAlert("O arquivo "+ cArqTXT + " não pôde ser criado! Verifique se existe a pasta C:\TEMP em sua máquina.","Atenção !")
	Return
Endif

// Identifica o primeiro periodo a ser gerado.
cQuery := "SELECT RA_FILIAL, RA_ADMISSA FROM " + RETSQLNAME("SRA") + " "
cQuery += "WHERE D_E_L_E_T_ = ' ' "                   
cQuery += "AND RA_FILIAL = '" + MV_PAR01 + "' "
cQuery += "ORDER BY RA_ADMISSA "    
cQuery := ChangeQuery( cQuery )

dbUseArea( .T., 'TOPCONN', TCGenQry( , , cQuery ), 'TSRA', .F., .T. )
                                                          
// Tratamento para campos diferentes de caracter
nT := len( aStru )
For nI := 1 to nT
  If ( aStru[nI][2] $ 'DNL' )
    TCSetField( 'TSRA', aStru[nI, 1], aStru[nI, 2], aStru[nI, 3], aStru[nI,4] )
  Endif
Next

// Busca admissão mais antiga...
TSRA->( dbGoTop() )          
d_DtIni := FirstDate(TSRA->RA_ADMISSA)

If Empty(d_DtIni)
   MsgInfo("Filial sem funcionários ou com a data de admissão inválida.","Atenção") 
   TSRA->(DbCloseArea())
   Return
EndIf	

c_Filial      := MV_PAR01
d_Dt_Fim_Proc := LastDate(MV_PAR05)
  
While d_DtIni <= d_Dt_Fim_Proc

   IncProc("Data: " + DTOC(d_DtIni) )

   // Variaveis dos campos da RCF...
// cFilial  := MV_PAR01
   c_Mes    := Strzero(Month(d_DtIni), 2)
   c_Ano    := Str(Year(d_DtIni), 4)
   c_Per    := c_Ano+c_Mes 
// c_TnoTra := "@@@"   
// c_Semana := "01"
// d_DtIni  := dDataAux
   d_DtFim  := LastDate(d_DtIni)
   n_DCalcm := d_DtFim - d_DtIni + 1
   n_DPerio := n_DCalcm
   n_HrsDia := 8
   n_DiaTra := DateWorkDay(d_DtIni, d_DtFim)
   n_DNTrab := ( d_DtFim - d_DtIni + 1 ) - n_DiaTra
   n_DiaDSR := n_DNTrab / 2
   n_DUteis := n_DPerio - n_DiaDSR
   n_HrsDSR := ( n_DNTrab / 2 ) * 8
   n_HrsTra := n_DiaTra * 8
   n_DUtilt := n_DiaTra
   n_DRefei := n_DiaTra
   n_DAlim  := n_DiaTra
   c_Modulo := "GPE"
      
   // Mensalistas/Estagiários 
   If MV_PAR02 = 1
      c_Proces := "00001"  
      RCF_GRV_TAB(c_Proces) 
   EndIf

   // Pro-labore/Autonomos
   If MV_PAR03 = 1
      c_Proces := "00003"  
      RCF_GRV_TAB(c_Proces) 
   EndIf

   // Horistas
   If MV_PAR04 = 1
      c_Proces := "00005"  
      RCF_GRV_TAB(c_Proces) 
   EndIf

   // Professores - 03/07/22 - Siqueira
   If MV_PAR06 = 1
      c_Proces := "00006"  
      RCF_GRV_TAB(c_Proces) 
   EndIf


   // Log de Processamento...
   If lCab_TXT = 0
      cStatus_TXT := "0"	// Cabeçalho
      RCF_GRV_LOG(cStatus_TXT) 
      lCab_TXT := 1
   EndIf
   If lGravou_RCF
      cStatus_TXT := "1"	// Incluiu Registro
      RCF_GRV_LOG(cStatus_TXT)
   Else 
      cStatus_TXT := "2"	// Registro Rejeitado
      RCF_GRV_LOG(cStatus_TXT)
   Endif
                       
   d_DtIni := d_DtFim + 1
Enddo

TSRA->(DbCloseArea())

fClose(nHdl)

MsgInfo("Total de períodos gerados: "+Strzero(nRCF_OK,6))

MsgInfo("Total de períodos rejeitados: "+Strzero(nRCF_REJ,6))


Return
   


/*
Função 	RCF_GRV_TAB - Incluir registros nas tabelas
Param   Nenhum
*/
Static Function RCF_GRV_TAB()

Local nCnt := 0
Local nVezes := If(MV_PAR03 = 1, 4, 3)

DbSelectArea("RCF") // ticket n° 9223897 
DbSetOrder(4) // ticket n° 9223897
If !RCF->(DbSeek(c_Filial+c_Per+c_Semana+c_Ano+c_Mes+c_Proces+Space(3)+c_TnoTra))
   RecLock("RCF",.T.)
					
   RCF->RCF_FILIAL	:= c_Filial
   RCF->RCF_MES   	:= c_Mes
   RCF->RCF_ANO   	:= c_Ano
   RCF->RCF_PER	    := c_Per
   RCF->RCF_PROCES	:= c_Proces
   RCF->RCF_TNOTRA	:= c_TnoTra
   RCF->RCF_SEMANA	:= c_Semana
   RCF->RCF_DTINI 	:= d_DtIni
   RCF->RCF_DTFIM 	:= d_DtFim
   RCF->RCF_DCALCM	:= n_DCalcm
   RCF->RCF_DPERIO	:= n_DPerio
   RCF->RCF_HRSDIA	:= n_HrsDia
   RCF->RCF_DIADSR	:= n_DiaDSR
   RCF->RCF_DUTEIS	:= n_DUteis
   RCF->RCF_HRSDSR	:= n_HrsDSR
   RCF->RCF_DIATRA	:= n_DiaTra
   RCF->RCF_HRSTRA	:= n_HrsTra
   RCF->RCF_DNTRAB	:= n_DNTrab
   RCF->RCF_DUTILT	:= n_DUtilt
   RCF->RCF_DREFEI	:= n_DRefei
   RCF->RCF_DALIM	:= n_DAlim 
   RCF->RCF_MODULO	:= c_Modulo
   
   RCF->( MsUnLock() )

   // Grava RCG..  
   // Não é necessário gerar RCG retroativa !

   // Grava RCH..   
   d_DtInte := d_DtFim
   d_DtPago := d_DtFim
   d_DtFech := d_DtFim + 5
   
   // Tratamento para 13o. Salario...
   If (SubStr(c_Per, 5, 2) = "11" .or. SubStr(c_Per, 5, 2) = "12")
      nVezes := 5
   Endif

   For nCnt := 1 To nVezes

      // Define o Tipo de Roteiro
      Do Case
         Case nCnt = 1
            c_Roteir := "FOL"
            d_DtInte := CTOD("//")	// Não há integração
            d_DtPago := d_DtFim + 5
         Case nCnt = 2
            c_Roteir := "FER"
         Case nCnt = 3
            c_Roteir := "RES"
         Case nCnt = 4
            c_Roteir := "AUT"
         Case nCnt = 5
            d_DtInte := CTOD("//")	// Não há integração
            If SubStr(c_Per, 5, 2) = "11"
               c_Roteir := "131"
            Else
               c_Roteir := "132"
               d_DtFech := CTOD("20/12/"+Substr(c_Per, 1, 4))
            EndIf
      EndCase
   
      If !RCH->(DbSeek(c_Filial+c_Proces+c_Per+c_NumPag+c_Roteir))
         RecLock("RCH",.T.)
					
         RCH->RCH_FILIAL := c_Filial
         RCH->RCH_PER    := c_Per
         RCH->RCH_NUMPAG := c_NumPag
         RCH->RCH_PROCES := c_Proces
         RCH->RCH_ROTEIR := c_Roteir
         RCH->RCH_MES    := c_Mes
         RCH->RCH_ANO    := c_Ano
         RCH->RCH_DTINI  := d_DtIni
         RCH->RCH_DTFIM  := d_DtFim
         RCH->RCH_DTPAGO := d_DtPago
         RCH->RCH_DTINTE := d_DtInte
         RCH->RCH_DTFECH := d_DtFech
         RCH->RCH_PERSEL := c_PerSel
         RCH->RCH_STATUS := c_RCHSta
         RCH->RCH_MODULO := c_Modulo
         RCH->RCH_COMPL  := c_Compl
      
         RCH->( MsUnLock() )
      EndIf
      
   Next
   
   // Grava RFQ..
   If !RFQ->(DbSeek(c_Filial+c_Proces+c_Per+c_NumPag+c_Roteir))
      RecLock("RFQ",.T.)
					
      RFQ->RFQ_FILIAL := c_Filial
      RFQ->RFQ_PROCES := c_Proces
      RFQ->RFQ_MES    := c_Mes
      RFQ->RFQ_ANO    := c_Ano
      RFQ->RFQ_PERIOD := c_Per
      RFQ->RFQ_NUMPAG := c_NumPag
      RFQ->RFQ_DTINI  := d_DtIni
      RFQ->RFQ_DTFIM  := d_DtFim
      RFQ->RFQ_MODULO := c_Modulo
      RFQ->RFQ_STATUS := c_RFQSta

      RFQ->( MsUnLock() )
   EndIf
   
   lGravou_RCF := .T.

   nRCF_Ok ++
Else
   lGravou_RCF := .F.
   nRCF_Rej ++
EndIf
				
RCF->( MsUnLock() )



Return

/*
Função 	RCF_GRV_LOG - Gravar log da operação
Param	cTipoLog, caracter, Tipo de Linha de Log
Return	lRet, Se tudo ok, continua...
*/
Static Function RCF_GRV_LOG(cTipoLog)


Local cTexto := ""

If cTipoLog = "0"							// Cabeçalho
	cTexto += "RCF_FILIAL"     				// Filial Processada 	(008)
	cTexto += ";"							// Separador
	cTexto += "RCF_MES"     				// Mes Competência   	(002)
	cTexto += ";"							// Separador
	cTexto += "RCF_ANO"     				// Ano Competência   	(004)
	cTexto += ";"							// Separador
	cTexto += "RCF_PER"     				// Período 			   	(006)
	cTexto += ";"							// Separador
	cTexto += "RCF_PROCES"     				// Cod. Processo	 	(005)
	cTexto += ";"							// Separador
	cTexto += "RCF_TNOTRA"     				// Turno Trab		   	(003)
	cTexto += ";"							// Separador
	cTexto += "RCF_SEMANA"     				// Num. Pagto		   	(002)
	cTexto += ";"							// Separador
	cTexto += "RCF_DTINI"     				// Data Inicial		   	(008)
	cTexto += ";"							// Separador
	cTexto += "RCF_DTFIM"     				// Data Final		 	(008)
	cTexto += ";"							// Separador
	cTexto += "RCF_DCALCM"     				// Dias Cálculo		   	(004)
	cTexto += ";"							// Separador
	cTexto += "RCF_DPERIO"     				// Dias Período		   	(004)
	cTexto += ";"							// Separador
	cTexto += "RCF_HRSDIA"     				// Qtd. Hrs. Dia	   	(005)
	cTexto += ";"							// Separador
	cTexto += "RCF_DUTEIS"     				// Dias Úteis		 	(004)
	cTexto += ";"							// Separador
	cTexto += "RCF_DIASDSR"    				// Período 			   	(004)
	cTexto += ";"							// Separador
	cTexto += "RCF_HRSDSR"     				// Horas DSR		   	(007)
	cTexto += ";"							// Separador
	cTexto += "RCF_DIATRA"     				// Qtd. Dias Traba.	   	(004)
	cTexto += ";"							// Separador
	cTexto += "RCF_HRSTRA"     				// Horas Trab.		   	(007)
	cTexto += ";"							// Separador
	cTexto += "RCF_DNTRAB"     				// Dias Não Trab.	 	(004)
	cTexto += ";"							// Separador
	cTexto += "RCF_DUTILT"     				// Dias Uteis VT	   	(004)
	cTexto += ";"							// Separador
	cTexto += "RCF_DREFEI"     				// Dias Vale Refeição  	(004)
	cTexto += ";"							// Separador
	cTexto += "RCF_DALIM"     				// Dias V.Alim		   	(004)
	cTexto += ";"							// Separador
	cTexto += "RCF_MODULO"     				// Modulo				(003)
	cTexto += ";"							// Separador
	cTexto += "STATUS"     				    // Status			   	(003)
Else
	cTexto += c_Filial     							// Filial Processada 	(008)
	cTexto += ";"									// Separador
	cTexto += c_Mes     							// Mes Competência   	(002)
	cTexto += ";"									// Separador
	cTexto += c_Ano     							// Ano Competência   	(004)
	cTexto += ";"									// Separador
	cTexto += c_Per     							// Período 			   	(006)
	cTexto += ";"									// Separador
	cTexto += c_Proces  	   						// Cod. Processo	 	(005)
	cTexto += ";"									// Separador
	cTexto += c_TnoTra     							// Turno Trab		   	(003)
	cTexto += ";"									// Separador
	cTexto += c_Semana     							// Num. Pagto		   	(002)
	cTexto += ";"									// Separador
	cTexto += Dtoc(d_DtIni)     					// Data Inicial		   	(008)
	cTexto += ";"									// Separador
	cTexto += Dtoc(d_DtFim)     					// Data Final		 	(008)
	cTexto += ";"									// Separador
	cTexto += Str(n_DCalcm, 4)     					// Dias Cálculo		   	(004)
	cTexto += ";"									// Separador
	cTexto += Str(n_DPerio, 4)     					// Dias Período		   	(004)
	cTexto += ";"									// Separador
	cTexto += Transform(n_HrsDia, "@E 9.999")		// Qtd. Hrs. Dia	   	(005)
	cTexto += ";"									// Separador
	cTexto += Str(n_DUteis, 4)     					// Dias Uteis		   	(004)
	cTexto += ";"									// Separador
	cTexto += Str(n_DiaDSR, 4)     					// Dias DSR		   		(004)
	cTexto += ";"									// Separador
	cTexto += Transform(n_HrsDSR, "@E 999.99")		// Horas DSR		   	(004)
	cTexto += ";"									// Separador
	cTexto += Str(n_DiaTra, 4)     					// Dias Trabalhados		(004)
	cTexto += ";"									// Separador
	cTexto += Transform(n_HrsTra, "@E 999.99")		// Horas Trabalhadas	(004)
	cTexto += ";"									// Separador
	cTexto += Str(n_DNTrab, 4)    					// Dias Não Trabalhados (004)
	cTexto += ";"									// Separador
	cTexto += Str(n_DUtilt, 4)     					// Dias Úteis VT		(004)
	cTexto += ";"									// Separador
	cTexto += Str(n_DRefei, 4)  	   				// Dias de Vale Refeição(004)
	cTexto += ";"									// Separador
	cTexto += Str(n_DAlim, 4)						// Qtd. Dias Traba.	   	(004)
	cTexto += ";"									// Separador
	cTexto += c_Modulo     							// Modulo				(003)
	cTexto += ";"									// Separador
	cTexto += If(cTipoLog="1","Ok","Rejeitado")	    // Status			   	(009)
EndIf

// Salto de Linha ...
cTexto += CHR(13)+CHR(10)

If fWrite(nHdl,cTexto,Len(cTexto)) != Len(cTexto)
	Alert("Atenção ! ERRO gravando dados do funcionário")
Endif

Return

  
/*
Função: RCF_TELA - Tela Parâmetros
Return	
*/
Static Function RCF_TELA

Local _sAlias := Alias()
Local aRegs   := {}

dbSelectArea("SX1")
dbSetOrder(1)
cPerg := PADR(cPerg,10)

// Grupo/Ordem/Pergunta///Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01///Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05
Aadd(aRegs,{cPerg , "01" , "Filial             ?" ,"Filial             ?","Filial             ?", "mv_ch1" , "C" , 08 ,0 ,0 , "G" , "naovazio" , "mv_par01" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "","","","","","","","","","","XM0","","033",".RHFILDE.     ",""})
Aadd(aRegs,{cPerg , "02" , "Gerar Mensa./Estag.?" ,"Gerar p/Mens/Estag.?","Gerar p/Mens/Estag.?", "mv_ch2" , "N" , 01 ,0 ,1 , "C" , "naovazio" , "mv_par02" , "1-Sim" , "" , "" , "" , "" , "2-Não" , "" , "" , "" , "" , "" , "" , "" , "" , "","","","","","","","","","","",""})
Aadd(aRegs,{cPerg , "03" , "Gerar Pro-lab/Auto.?" ,"Gerar Pro-lab/Auto.?","Gerar Pro-lab/Auto.?", "mv_ch3" , "N" , 01 ,0 ,2 , "C" , "naovazio" , "mv_par03" , "1-Sim" , "" , "" , "" , "" , "2-Não" , "" , "" , "" , "" , "" , "" , "" , "" , "","","","","","","","","","","",""})
Aadd(aRegs,{cPerg , "04" , "Gerar Horista      ?" ,"Gerar Horista      ?","Gerar Horista      ?", "mv_ch4" , "N" , 01 ,0 ,2 , "C" , "naovazio" , "mv_par04" , "1-Sim" , "" , "" , "" , "" , "2-Não" , "" , "" , "" , "" , "" , "" , "" , "" , "","","","","","","","","","","",""})
Aadd(aRegs,{cPerg , "05" , "Data Final         ?" ,"Data Final         ?","Data Final         ?", "mv_ch5" , "D" , 08 ,0 ,0 , "C" , "naovazio" , "mv_par05" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "","","","","","","","","","","",""})
Aadd(aRegs,{cPerg , "06" , "Gerar Professor    ?" ,"Gerar Professor    ?","Gerar Professor    ?", "mv_ch6" , "N" , 01 ,0 ,2 , "C" , "naovazio" , "mv_par06" , "1-Sim" , "" , "" , "" , "" , "2-Não" , "" , "" , "" , "" , "" , "" , "" , "" , "","","","","","","","","","","",""})    // 03/07/22 - Siqueira
For i:=1 to Len(aRegs)
	If !dbSeek(cPerg+aRegs[i,2])
		RecLock("SX1",.T.)
		For j:=1 to FCount()
			If j <= Len(aRegs[i])
				FieldPut(j,aRegs[i,j])
			EndIf
		Next
		MsUnlock()
	EndIf
Next

dbSelectArea(_sAlias)

Return
