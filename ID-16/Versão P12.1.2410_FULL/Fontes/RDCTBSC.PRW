/*
CRIAR TABELA CONTROLE SEMAFORO DE CONTABILIZAÇÃO POR EMPRESA
-- SZ4 - SEMAFORO DE CONTABILIZACAO SCHEDULE

Z4_FILIAL  - TAMANHO 8 CARACTER
Z4_EMPPROC - TAMANHO 2 CARACTER
Z4_FILPROC - TAMANHO 8 CARACTER
Z4_FLGPROC - LOGICO  // FLAG PARA GARANTIR QUE NÃO SERÃO PROCESSADAS AS FILIAIS NOVAMENTE.
Z4_MIGRADO - LOGICO  // PARA SELECIONAR AS EMPRESAS QUE VÃO SER EXECUTADAS NA SCHEDULE.    
Z4_DTULPRO - TAMANHO 8 DATA // DATA DO ULTIMO PROCESSAMENTO DA SCHEDULE NA FILIAL.
Z4_QTDCONT - TAMANHO 14 NUMERICO // QUANTIDADE DE REGISTROS CONTABILIZADOS NA DATA
Z4_QTDREG  - TAMANHO 14 NUMERICO // QUANTIDADE DE REGISTROS A SEREM PROCESSADOS.
  
CAMPOS - EMPRESA 
		 FILIAL
		 INDICADOR DE PROCESSAMENTO
INDICE(1)   FILIAL + EMPRESA PROCESSAMENTO + FILIAL PROCESSAMENTO   

// ativar parametro, existem 7 threds ativos, distribuidos 35000 registros entre os threads por execucao.
MV_CTBNMRB    - criado (descricao -Numero Maximo de registros a distribuir pelas Threads.) configurado com 35000 --http://athena.microsiga.com.br/display/public/PROT/MV_CTBNMRB     
MV_CFINTHR esteja configurado para utilização de 3 threads(7 rede dor).
MV_FINLOG precisa ser habilitado para .T. - http://tdn.totvs.com/pages/viewpage.action?pageId=6070492
MV_DIRDOC precisa ser definido para a geração do arquivo de inconsistências (verificar se está apontando para uma pasta valida do ERP ex. System)
MV_PRELAN precisa estar como “D” - http://tdn.totvs.com/pages/viewpage.action?pageId=284348618
MV_ATUSAL precisa estar como “S”
MV_CFINTHR pode colocar a quantidade que o SLAVE aguentar (limitado a 30 threads) - http://tdn.totvs.com/pages/viewpage.action?pageId=6070318
MV_CTBUPRC deve estar como .F. - http://tdn.totvs.com/pages/releaseview.action?pageId=223930616
MV_CTBUPRC mesmo que esteja configurado para contabilizacao multi-threads se o parametro estiver como .T. será feito por conexao unica (.t. rededor), 
MV_CTBFLAG deve estar como .T. - http://tdn.totvs.com/pages/viewpage.action?pageId=185757542
*/

#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"   
#include "PARMTYPE.CH"    
#INCLUDE "TOTVS.CH"

// Contabilização OFF line de Compras via SChedule // *********** DEBUGAR PAREI AQUI 18/03/2019 ************ //

User Function RDCTBSC
 
 Local   nTotReg1  	:= 0 
 Local   cEmp 		:= ""
 Local   cFil 		:= "" 
 Local   cModulo 	:= ""
 Local   aParam     := {}
 Private cFilAtu   	:= ""
 Private cEmpAtu   	:= ""
 Private cEmpProc  	:= ""
 Private cFilProc  	:= "" 
 Private aRecnoSM0 	:= {}
 Private aProgs    	:= {}
 Private lSchedule 	:= IsBlind()
 Private _aFilias  	:= {}
 Private cDtini    	:= SUBS(DTOS(date()),1,6)+"01" 
 Private cDtFim    	:= SUBS(DTOS(date()),1,8)   
// Private cDtini    := "20190301"
// Private cDtFim    := "20190331"
// Private cDtfim    := DTOS(date())
 Private cEol      := chr(13)+chr(10)   
 Private nTotReg  	:= 0       
 Private _cPathRoot := "\SIGADOC\LOG_CONTABILIDADE\"
 Private _cPath 	:= "\SIGADOC\LOG_CONTABILIDADE\"+cDtFim+"\" 
 Private aArea0     	
 Private nCount := 0
 //Private lRPC  
 //DEFAULT aParam := {"01","01010001"} // caso nao receba nenhum parametro
 //DEFAULT lRPC := MyIsBlind()

 //IF ( lRPC )

 DEFAULT cEmp := "01"
 DEFAULT cFil := "01010001"
 DEFAULT cModulo := "CTB"
	
 RPCSetType(3)
 	
 //#IFDEF TOP
 	SetTopType("A")
 //#ENDIF 
 	
 RpcSetType( 3 )	
 PREPARE ENVIRONMENT EMPRESA "01" FILIAL "01010001" MODULO "FAT" 
 
 aArea0 := GetArea()
 
 //SetsDefault()
 //SetModulo("SIGACTB","CTB") 

// EndIF

 aAdd( aProgs, { "FCTBRD" } )
 aAdd( aProgs, { "CTBANFE" } )  
 
// aArea0    	:= GETAREA()
 
//Inicia outra Thread com outra empresa e filial
// RpcSetType( 3 )
// cDtini    :=  SUBS(DTOS(date()),1,6)+"01"
// cDtFim    :=  SUBS(DTOS(date()),1,8)        
    
 dbSelectArea("SZ4")
 SZ4->(dbSetOrder(1))
 SZ4->(dbGoTop())


 dbSelectArea("SM0")
 SM0->(dbGoTop())

 While !SM0->( EOF() )
	// Só adiciona no aRecnoSM0 se a empresa for diferente 
	aAdd( aRecnoSM0, { SM0->M0_CODFIL } )

	cEmpAtu := Alltrim(SM0->M0_CODIGO)	
	cFilAtu := Alltrim(SM0->M0_CODFIL)

	If !(SZ4->(Dbseek(xFilial("SZ4")+cEmpAtu+cFilAtu)))
		RecLock("SZ4",.T.)
			Z4_EMPPROC := cEmpAtu
			Z4_FILPROC := cFilAtu
		SZ4->(MsUnlock())
	EndIf
	
	SM0->( dbSkip() )

 EndDo

 If Select("SZ4") >0 ; SZ4->(dbCloseArea()) ; EndIf

 dbSelectArea("SZ4")
 SZ4->(dbSetOrder(1))
 SZ4->(dbGoTop())
 
 While SZ4->(!EOF())
 	cEmpProc := Alltrim(SZ4->Z4_EMPPROC)
	cFilProc := Alltrim(SZ4->Z4_FILPROC)   
 
	If !(SZ4->Z4_FLGPROC) 
		If SZ4->Z4_MIGRADO
			If SZ4->(Dbseek(xFilial("SZ4")+cEmpProc+cFilProc))
				If SZ4->(RecLock("SZ4",.F.))
						Z4_FLGPROC := .T.
						Z4_DTULPRO := Date()
					SZ4->(MsUnlock())
  	  				ChangeEmp(cEmpProc,cFilProc)
				EndIf
    		EndIf
    		
		AADD( _aFilias, {cEmpProc,cFilProc} ) 
		EndIf
	EndIf
 SZ4->(dbSkip())
 EndDo
 
 For nX:=1 to Len(_aFilias)
    cEmpProc := _aFilias[nX,1]
	cFilProc := _aFilias[nX,2]
     
    RpcSetType( 3 )
    PREPARE ENVIRONMENT EMPRESA ( cEmpProc ) FILIAL ( cFilProc ) MODULO 'CTB'
 
 	nTotReg1:= fCtarCTB(cEmpProc,cFilProc)
 	nTotCtb := fContabz(cEmpProc,cFilProc) 
	
 	SZ4->(dbGoTop())
	
	If nTotReg1 > 0 .or. nTotCtb > 0 
		If SZ4->(Dbseek(xFilial("SZ4")+cEmpProc+cFilProc))
			If (RecLock("SZ4",.F.))
				  Z4_QTDREG  := nTotReg1 
				  Z4_QTDCONT := nTotCtb
			    SZ4->(MsUnlock())
			EndIf
	    EndIf
	EndIf
	RESET ENVIRONMENT   
 Next nX
 

 RpcSetType( 3 )
 PREPARE ENVIRONMENT EMPRESA  "01" FILIAL  "01010001"  MODULO 'CTB'

 If Select("SZ4") >0 ; SZ4->(dbCloseArea()) ; EndIf

 dbSelectArea("SZ4")
 SZ4->(dbSetOrder(1))
 SZ4->(dbGoTop())

// If cf_ProcInUse(aProgs) == .F.  // VERIFICA SE ESTÁ EXECUTANDO O PROGRAMA
 	Sleep(3600)  //parar por 1h para limpar a tabela
	While !SZ4->(EOF())
		nCount := 1
		While !DBRLock() .or. nCount < 10
   			sleep( 60 )
    		If DBRUnlock( SZ4->(RECNO()) )
    			nCount := 10
    			Loop
    		EndIf 
    		nCount ++
  		EndDo
		If SZ4->(RecLock("SZ4",.F.))
			Z4_FLGPROC := .F.
	      SZ4->(MsUnlock())
	 	EndIf
		SZ4->(dbSkip())
  	EndDo 

 If Select("SZ4") >0 ; SZ4->(dbCloseArea()) ; EndIf
 
 rdZip(_cPath,_cPathRoot,cDtFim) //zipar os arquivos		

 If lSchedule
 	RpcClearEnv()
 Else        
 	Aviso( 'INFO', 'O processamento da contabilizacao está terminado ', { 'Fechar' } )
 EndIf

 RestArea(aArea0)
		
Return		


/*
    Programa    : RDCTBSC.prw
    Funcao      : ContNfe
    Autor       : Thiago Góes 
    Data        : 29/03/2019
    Uso         : Contabilização OFF line de Compras via SChedule
*/
// salva relatorio - log na pasta.//
// Contabilização OFF line de Financeiro via SChedule
// Contabilização OFF line de Compras via SChedule

//*********************************//
 Static Function ContNfe(cEmpProc,cFilProc)
//********************************//

 Local aPergunte := {,,,,,,,}
 Local lSchedule := IsBlind()
 Local DiaInicio := ctod("  /  /  ")

 RpcSetType( 3 )
 PREPARE ENVIRONMENT EMPRESA cEmpProc FILIAL cFilProc MODULO "FIN" 

 dDiaInicio   := ctod("01/"+str(MONTH(Ddatabase))+"/"+SUBS(DTOS(Ddatabase),1,4))
 aPergunte[1] := 2 			// Mostra Lançamentos 1-Sim / 2- Não
 aPergunte[2] := 1 			// Aglutina Lançamentos 1- Sim / 2-Não          
 aPergunte[3] := 1 			// Gera Lançamento por 1- Documento / 2- Periodo / 3- Dia                 
 aPergunte[4] := dDiaInicio	// Data Inicial    // comentado para testes  //thiago goes 28/02/2019
 aPergunte[5] := dDatabase	// Data Final      // comentado para testes //thiago goes 28/02/2019
 aPergunte[6] := cFilProc
 aPergunte[7] := cFilProc
 aPergunte[8] := 2			// Contabiliza Notas de Crédito 1-Sim / 2-Não    
        
 ConOut("=== INICIO DO PROCESSAMENTO CTBANFE - EMPRESA: "+cEmpAnt+" - FILIAL: "+cFilProc+" ===")
    
 CTBANFE(aPergunte)
    
 ConOut("=== FIM DO PROCESSAMENTO CTBANFE - EMPRESA: "+cEmpAnt+" - FILIAL: "+cFilProc+" ===") 
 
 RESET ENVIRONMENT 

Return                    

/*
    Programa    : RDCTBSC.prw
    Funcao      : ContFin
    Autor       : Thiago Góes 
    Data        : 29/03/2019
    Uso         : Contabilização OFF line de Financeiro via SChedule.
*/
// salva relatorio - log na pasta.//
// Contabilização OFF line de Financeiro via SChedule

//*********************************//
 Static Function ContFin(cEmpProc,cFilProc)
//*********************************//

 Local cPerg     := ""
 Local lSchedule := IsBlind()
 Local dDiaInicio := ctod(" /  /  ")    

 RpcSetType( 3 )
 PREPARE ENVIRONMENT EMPRESA cEmpProc FILIAL cFilProc MODULO "FIN" 

 Pergunte("FIN370",.F.)
 cPerg     	:= "FIN370"
 
     
 ConOut("=== INICIO PROCESSAMENTO CTBAFIN - EMPRESA: "+cEmpAnt+" - FILIAL: "+xFilial("SE2")+" ===")
     
 CTBAFIN(.T.)

 ConOut("=== FIM DO PROCESAMENTO CTBAFIN -  EMPRESA: "+cEmpAnt+" - FILIAL: "+xFilial("SE2")+" ===") 

 RESET ENVIRONMENT

Return

//Verifica se o programa esta executando em outra instancia
//*--------------------------------------------*
Static Function cf_ProcInUse(aProgs)
//*--------------------------------------------*
 Local lRet     := .F.
 Local lOk      := .T.
 Local aInfo    := {}
 Local aMonitor := {}
 Local cString  := ""
 Local cLogged  := ""
 Local nMonitor := 1
 Local nElem    := 0

 aMonitor := GetUserInfoArray()

 For nMonitor := 1 To Len(aMonitor)  
 		For nProgs := 1 To Len(aProgs)
			If aProgs[nProgs] == cString
               cLogged := If( AT("Logged :", cString) > 0, SubStr( cString, AT("Logged :", cString)+Len("Logged :"), 15), "" )
               If cUserName <> cLogged
                  If (nElem := AScan( aInfo ,{ |x|x[1]==cString .And. x[2]==aMonitor[nMonitor][3] } )) == 0
                     AAdd( aInfo , { cString , aMonitor[nMonitor][3] , aMonitor[nMonitor][1] , aMonitor[nMonitor][2] , aProgs[nProgs] , cLogged } )
                  EndIf
               EndIf
            EndIf
		Next nProgs
 Next nMonitor

 If (Len(aInfo) > 0)        
	lRet := .T.
 EndIf           
 
 RESTAREA(aAreaAnt)  
   
Return(lRet)          

/*
    Programa    : RDCTBSC.prw
    Funcao      : fCtarCTB
    Autor       : Thiago Góes 
    Data        : 29/03/2019
    Uso         : Relatorio, registros a ser contabilizados na data.
*/
// salva relatorio - log na pasta.//
// Relatorio, registros a ser contabilizados na data.

//*--------------------------------------------*
Static Function fCtarCTB(cEmpProc, cFilProc)
//*--------------------------------------------*    
 
 Local _nContar     := 0
 Local _cQry 	 	:= " " 
 Local aAreaSZ4    	:= GetArea()
 Local _cArq 		:= "CTBOFFLINE_"+cFilProc+"_"+SUBSTR(TIME(), 1, 2) +"h"+SUBSTR(TIME(), 4, 2)
 Local _lArqCsv 
 Local _cLin  
 Local _cQry 		:= " " 
 Local _nContar 	:= 0 
 Local _lGerouExc 	:= .F.     
 Private cAlias   	:= GetNextAlias() 
 Private _cEscrev   := " "  
 Private _cLinha    := " "   
 Private _cScript 	:= Alltrim(_cPath+_cArq)

// If !(ExistDir(_cPathRoot,.F.))
 MONTADIR( _cPathRoot )
// EndIf
 
// If !(ExistDir(_cPath,.F.))
 MONTADIR( _cPath )
// EndIf
 
 _cQry := " SELECT TABELA, FILIAL, NUMERO, EMISSAO, DTCONTAB, VALOR, BENEF, REPLACE(REPLACE(HISTORICO,';',' '),'.',' ') HISTORICO, BANCO, AGENCIA, CONTA, FORNECEDOR, LOJA, RECNO1,LA "+cEol 
 _cQry += "     FROM(               " +cEol
 _cQry += "          SELECT 'SEU' TABELA, EU.EU_FILIAL FILIAL,EU.EU_NUM NUMERO,EU_EMISSAO EMISSAO,EU.EU_DTDIGIT DTCONTAB, EU.EU_VALOR VALOR,EU_BENEF BENEF, EU.EU_HISTOR HISTORICO, ' ' BANCO, ' ' AGENCIA, ' ' CONTA,EU_FORNECE FORNECEDOR, EU_LOJA LOJA, EU.R_E_C_N_O_ RECNO1, EU.EU_LA LA "+cEol                                                      
 _cQry += "            FROM "+RetSqlName("SEU")+" EU " +cEol
 _cQry += "            WHERE EU_DTDIGIT BETWEEN '"+cDtini+"' AND '"+cDtFim+"'"+cEol
 _cQry += "              AND EU_TIPO <> '02' "+cEol
 _cQry += "              AND EU_FILIAL = '"+cFilProc+"'"+cEol  
 _cQry += "              AND D_E_L_E_T_ =  ' '"+cEol
 
 // union tabelas de cheque
 _cQry += "    UNION "+cEol
 _cQry += "    SELECT 'SEF' TABELA,EF.EF_FILIAL FILIAL, EF.EF_NUM NUMERO, ' ' EMISSAO, EF_DATA DTCONTAB, EF_VALOR VALOR,EF_BENEF BENEF, EF_HIST HISTORICO,EF_BANCO BANCO, EF_AGENCIA AGENCIA, EF_CONTA CONTA ,' ' FORNECEDOR, ' ' LOJA,EF.R_E_C_N_O_ RECNO1, EF.EF_LA LA "+cEol
 _cQry += "            FROM "+RetSqlName('SEF') + " EF " +cEol
 _cQry += "            WHERE EF_DATA BETWEEN '"+cDtini+"' AND '"+cDtfim+"'"+cEol
 _cQry += "              AND D_E_L_E_T_ = ' ' "+cEol
 _cQry += "              AND EF_XMIGLT = ' ' "+cEol
 _cQry += "              AND EF_FILIAL = '"+cFilProc+"'"+cEol 

// union tabelas de extrato bancario
 _cQry += "    UNION  "+cEol
 _cQry += "          SELECT 'SE5' TABELA,E5.E5_FILIAL, E5_NUMERO, E5_DATA, E5_DTDIGIT, E5_VALOR, E5_BENEF, E5_HISTOR, E5_BANCO, E5_AGENCIA, E5_CONTA, ' ' E5_FORNECE, E5_LOJA, E5.R_E_C_N_O_, E5.E5_LA  "+cEol
 _cQry += "          	FROM "+RetSqlName("SE5")+" E5 " +cEol
 _cQry += "            	WHERE E5_DTDIGIT BETWEEN '"+cDtini+"' AND '"+cDtfim+"'"+cEol
 _cQry += "            		AND E5_TIPO <> 'TX' "+cEol
 _cQry += "            		AND E5_FILIAL = '"+cFilProc+"'"+cEol 
 _cQry += "            		AND E5_RECPAG = 'P' "+cEol
 _cQry += "            		AND E5_NATUREZ NOT IN ('INS','ISS','PCC') "+cEol
 _cQry += "            		AND D_E_L_E_T_ =  ' ' "+cEol
 _cQry += "            		AND E5_XMIGLT = ' ' "+cEol

// union tabelas de contas a pagar"+cEol
 _cQry += "    UNION "+cEol
 _cQry += "   		SELECT 'SE2' TABELA,E2.E2_FILIAL, E2_NUM, E2_EMISSAO, E2_EMIS1,E2_VALOR, E2_NOMFOR, E2_HIST,  E2_PORTADO,' ' E2_AGENCIA,' '  E2_CONTA,E2_FORNECE, E2_LOJA, E2.R_E_C_N_O_, E2.E2_LA "+cEol
 _cQry += "         	from "+RetSqlName("SE2")+" E2 " +cEol
 _cQry += "          	WHERE E2_EMIS1 BETWEEN '"+cDtini+"' AND '"+cDtfim+"'"+cEol
 _cQry += "           		AND E2_TIPO <> 'TX' "+cEol
 _cQry += "           		AND E2_FILIAL = '"+cFilProc+"'"+cEol 
 _cQry += "           		AND E2_NATUREZ NOT IN ('INS','ISS','PCC') "+cEol
 _cQry += "           		AND D_E_L_E_T_ =  ' ' "+cEol
 _cQry += "           		AND E2_XMIGLT = ' ' ) A "+cEol      
 
 DbUseArea(.F., "TOPCONN", TcGenQry(,, _cQry), cAlias, .f., .f.) 

 DbSelectArea(cAlias) 
 (cAlias)->(dbGotop())
                              
 _nContar := Contar( cAlias, "!EOF()" )
 nTotReg  := _nContar      
 
 
 ConOut("=== GERACAO DO RELATORIO (QUANTIDADES A CONTABILIZAR) - FILIAL: "+cFilProc+" ===")
 
 (cAlias)->( DbGoTop() )
 
// armazena relatorio na pasta  
 If nTotReg > 0 

	 If Select(cAlias) >0 
		 _lArqCsv := FCreate( Alltrim(_cScript) + ".CSV", 0 )
		 _cEscrev := 'MOVIMENTO CANDIDATOS A CONTABILIZACAO NA DATA' + cEOL  
		  fWrite( _lArqCsv, _cEscrev )
		  
		 _cEscrev := 'TABELA;FILIAL;NUMERO;EMISSAO;DTCONTAB;VALOR;BENEFICIARIO;HISTORICO;BANCO;AGENCIA;CONTA;FORNECEDOR;LOJA;RECNO;LA ' + cEOL 
		 fWrite( _lArqCsv, _cEscrev )
			   	
		While (cAlias)->( ! Eof() )
			_cLinha := (cAlias)->TABELA															+ ';'
			_cLinha += Iif( Empty( (cAlias)->FILIAL)  	 ,' ' ,"'" + (cAlias)->FILIAL) 	    	+ ';'
			_cLinha += Iif( Empty( (cAlias)->NUMERO)  	 ,' ' ,"'" + (cAlias)->NUMERO) 			+ ';'
			_cLinha += Dtoc( Stod( (cAlias)->EMISSAO  ) )	 						  			+ ';' 
			_cLinha += Dtoc( Stod( (cAlias)->DTCONTAB ) ) 										+ ';' 
			_cLinha += TransForm(  (cAlias)->VALOR, '@E 9,999,999,999,999.99' ) 				+ ';'                         
			_cLinha += (cAlias)->BENEF															+ ';'
			_cLinha += (cAlias)->HISTORICO 														+ ';'
			_cLinha += Iif( Empty( (cAlias)->BANCO )  	 ,' ' ,"'" + (cAlias)->BANCO     )		+ ';'
			_cLinha += Iif( Empty( (cAlias)->AGENCIA )	 ,' ' ,"'" + (cAlias)->AGENCIA   )		+ ';'
			_cLinha += Iif( Empty( (cAlias)->CONTA )  	 ,' ' ,"'" + (cAlias)->CONTA     )		+ ';'
			_cLinha += Iif( Empty( (cAlias)->FORNECEDOR ) ,' ' ,"'" + (cAlias)->FORNECEDOR) 	+ ';'
			_cLinha += Iif( Empty( (cAlias)->LOJA )		 ,' ' ,"'" + (cAlias)->LOJA      )		+ ';'
			_cLinha += cValtoChar((cAlias)->RECNO1) 											+ ';'
			_cLinha += (cAlias)->LA 															+ cEol						
			            
			fWrite( _lArqCsv, _cLinha ) 
	
			(cAlias)->( DbSkip() )
	
		EndDo
	 EndIf
	
	 fClose( _lArqCsv )
 EndIf
 
 If select(cAlias) >0 ;(cAlias)->(dbCloseArea());EndIf

 If Select("SZ4")> 0; SZ4->(DbCloseArea());EndIf
 
 DbselectArea("SZ4")

 RESTAREA(aAreaSZ4)
 
Return nTotReg   


/*
    Programa    : RDCTBSC.prw
    Funcao      : fContabz
    Autor       : Thiago Góes 
    Data        : 29/03/2019
    Uso         : Gera Quantidade dos lançamentos eleitos a contabilização, grava no campo de Log.
*/
// salva relatorio - log na pasta.//

//*--------------------------------------------*
Static Function fContabz(cEmpProc,cFilProc)
//*--------------------------------------------*
 
 Local _nContar     := 0
 Local _cQuery 	 	:= " " 
 Local aAreaSZ4	    := SZ4->(GetArea())
 Local cAlias2      := GetNextAlias()
 
 _cQuery := " SELECT SUM(QTD) TOTAL FROM  "+cEol
 _cQuery += " (SELECT count(*) QTD "+cEol
 _cQuery += "      	from "+RetSqlName("CT2") +" CT2 " +cEol
 _cQuery += "  INNER JOIN "+RetSqlName("SE5")+" E5 ON SUBSTR( CT2_KEY, 11, 3 ) = E5_PREFIXO  "+cEol
 _cQuery += "    AND SUBSTR( CT2_KEY, 14, 9 ) = E5_NUMERO  "+cEol
 _cQuery += "    AND E5.D_E_L_E_T_ = CT2.D_E_L_E_T_ "+cEol
 _cQuery += "    AND E5_DTDIGIT = CT2_DATA  "+cEol
 _cQuery += "    AND E5_FILIAL = CT2_FILIAL "+cEol
 _cQuery += "    AND E5_RECPAG = 'P' "+cEol
 _cQuery += "    AND E5_TIPODOC IN ( 'PA', 'RA', 'BA', 'VL', 'V2', 'AP', 'EP', 'PE', 'RF', 'IF', 'CP', 'TL', 'ES', 'TR', 'DB', 'OD', 'LJ', 'E2', 'TE', '  ' )  "+cEol
 _cQuery += "    AND ( E5_LA <> ' ' OR ( ( E5_ORDREC || E5_SERREC ) <> ' ' AND E5_TIPODOC = 'BA' ) ) "+cEol
 _cQuery += "    AND E5_MOTBX NOT IN ('DSD','CMP','DAC') "+cEol 
 _cQuery += "    AND SUBSTR( CT2_KEY, 1, 8 ) 	= E5_FILIAL  "+cEol
 _cQuery += "    AND SUBSTR( CT2_KEY, 9, 2 ) 	= E5_TIPODOC "+cEol
 _cQuery += "    AND SUBSTR( CT2_KEY, 23, 1 ) 	= E5_PARCELA "+cEol
 _cQuery += "    AND SUBSTR( CT2_KEY, 24, 3 ) 	= E5_TIPO  "+cEol
 _cQuery += "    AND SUBSTR( CT2_KEY, 27, 8 ) 	= E5_DATA "+cEol
 _cQuery += "    AND SUBSTR( CT2_KEY, 35, 6 ) 	= E5_CLIFOR "+cEol
 _cQuery += "    AND SUBSTR( CT2_KEY, 41, 2 ) 	= E5_LOJA "+cEol
 _cQuery += "    AND SUBSTR( CT2_KEY, 43, 2 ) 	= E5_SEQ "+cEol
 _cQuery += "  WHERE CT2.D_E_L_E_T_ = ' '  "+cEol
 _cQuery += "    AND CT2_VALOR > 0  "+cEol
 _cQuery += "    AND CT2_XMIGLT =  ' ' "+cEol
 _cQuery += "    AND CT2_LOTE <> '008890' "+cEol
 _cQuery += "    AND CT2_FILIAL = '"+cFilProc+"'"+cEol 
 _cQuery += "    AND CT2_VALOR > 0  "+cEol
 _cQuery += "    AND CT2_TPSALD = '1'  "+cEol
 _cQuery += "    AND CT2_ROTINA NOT IN ( 'CTBA102', 'CTBA500','GPEM110') "+cEol
// _cQuery += "    --AND CT2_DATA BETWEEN '"+cDtini+"' AND '"+cDtfim+"'"+cEol
 _cQuery += "    AND E5_LA = 'S'  "+cEol
 _cQuery += "    AND E5_TIPO <> 'TX' "+cEol
 _cQuery += "    AND CT2_DATA BETWEEN '"+cDtini+"' AND '"+cDtfim+"'"+cEol
 _cQuery += "  UNION  "+cEol
 _cQuery += "  SELECT COUNT(E2.R_E_C_N_O_) QTD "+cEol
 _cQuery += "    FROM CT2010 CT2  "+cEol
 _cQuery += "    INNER JOIN "+RetSqlName("SE2")+" E2 ON SUBSTR( CT2_KEY, 12, 9 ) = E2_NUM  "+cEol
 _cQuery += "      AND CT2_DATA = E2_EMIS1 AND E2_XID = ' '      "+cEol
 _cQuery += "      AND E2_XMIGLT = ' '                           "+cEol
 _cQuery += "      AND SUBSTR( CT2_KEY, 1, 8 ) 	= E2_FILIAL	  "+cEol
 _cQuery += "      AND E2_EMIS1 					= CT2_DATA 	  "+cEol
 _cQuery += "      AND SUBSTR( CT2_KEY, 9, 3 ) 	= E2_PREFIXO  "+cEol
 _cQuery += "      AND SUBSTR( CT2_KEY, 21, 1 ) 	= E2_PARCELA  "+cEol
 _cQuery += "      AND SUBSTR( CT2_KEY, 22, 3 ) 	= E2_TIPO      "+cEol
 _cQuery += "      AND SUBSTR( CT2_KEY, 25, 6 ) 	= E2_FORNECE  "+cEol
 _cQuery += "      AND E2.D_E_L_E_T_ = CT2.D_E_L_E_T_ 			  "+cEol
 _cQuery += "      AND E2_FILIAL = CT2_FILIAL					  "+cEol
 _cQuery += "    WHERE CT2.D_E_L_E_T_ = ' '  "+cEol
 _cQuery += "      AND CT2_VALOR > 0  "+cEol
 _cQuery += "      AND CT2_XMIGLT =  ' ' "+cEol
 _cQuery += "      AND CT2_LOTE <> '008890' "+cEol
 _cQuery += "      AND CT2_FILIAL = '"+cFilProc+"'"+cEol 
 _cQuery += "      AND CT2_VALOR > 0  "+cEol
 _cQuery += "      AND CT2_TPSALD = '1'  "+cEol
 _cQuery += "      AND CT2_ROTINA NOT IN ( 'CTBA102', 'CTBA500','GPEM110') "+cEol
 _cQuery += "      AND E2_LA = 'S'  "+cEol
 _cQuery += "      AND E2_TIPO <> 'TX' "+cEol
 _cQuery += "      AND CT2_DATA BETWEEN '"+cDtini+"' AND '"+cDtfim+"'"+cEol
 _cQuery += "    UNION  "+cEol
 _cQuery += "    SELECT COUNT(EF.R_E_C_N_O_) QTD "+cEol
 _cQuery += "      FROM CT2010 CT2 "+cEol
 _cQuery += "      INNER JOIN "+RetSqlName("SEF")+" EF ON EF_VALOR = CT2_VALOR "+cEol
 _cQuery += "        AND EF_DATA = CT2_DATA "+cEol
 _cQuery += "        AND EF_FILIAL = CT2_FILIAL "+cEol
 _cQuery += "        AND EF.D_E_L_E_T_ = CT2.D_E_L_E_T_ "+cEol 
 _cQuery += "      WHERE CT2_DATA BETWEEN '"+cDtini+"' AND '"+cDtfim+"'"+cEol
 _cQuery += "        AND CT2.D_E_L_E_T_ = ' '  "+cEol
 _cQuery += "        AND CT2_HIST LIKE '%CH%'  "+cEol
 _cQuery += "        AND CT2_XMIGLT = ' ' "+cEol
 _cQuery += "        AND CT2_TPSALD = '1' "+cEol
 _cQuery += "        AND CT2_LP NOT IN ('566') "+cEol
 _cQuery += "        AND CT2_FILIAL = '"+cFilProc+"'"+cEol 
 _cQuery += "        AND CT2_LOTE <> '008890' "+cEol
 _cQuery += "        AND CT2_ROTINA NOT IN ( 'CTBA102', 'CTBA500','GPEM110') "+cEol
 _cQuery += "        AND EF_LA = 'S'     "+cEol
 _cQuery += "        AND CT2_VALOR > 0  "+cEol
 _cQuery += "        AND CT2_TPSALD = '1'  "+cEol
 _cQuery += "        UNION "+cEol
 _cQuery += "        SELECT COUNT(*) QTD  "+cEol
 _cQuery += "          FROM "+RetSqlName("SEU")+"  "+cEol
 _cQuery += "          WHERE EU_LA = 'S' "+cEol
 _cQuery += "            AND D_E_L_E_T_ = ' '  "+cEol
 _cQuery += "            AND EU_TIPO <> '02'  "+cEol
 _cQuery += "            AND EU_DTDIGIT BETWEEN '"+cDtini+"' AND '"+cDtfim+"'"+cEol
 _cQuery += "            AND EU_FILIAL = '"+cFilProc+"'"+cEol 
 _cQuery += "    ) A "+cEol

 DbUseArea(.F., "TOPCONN", TcGenQry(,, _cQuery), cAlias2, .f., .f.) 
 DbSelectArea(cAlias2) 
                            
 _nContar := (cAlias2)->TOTAL          
 
 ConOut("=== GERACAO DO RELATORIO (QUANTIDADES CONTABILIZADAS)- FILIAL: "+cFilProc+" ===")

 If select(cAlias2) >0 ;(cAlias2)->(dbCloseArea());EndIf
 
 If Select("SZ4")> 0; SZ4->(DbCloseArea());EndIf
 
 DbselectArea("SZ4")

 RESTAREA(aAreaSZ4) 

Return _nContar    


/*
    Programa    : RDCTBSC.prw
    Funcao      : RDzip
    Autor       : Thiago Góes 
    Data        : 29/03/2019
    Uso         : Criar arquivo compactado dos relatorios gerados, posteriormente apaga pasta criada
*/

Static Function RDZip (_cPath,_cPathRoot,cDtFim)

 Local aFiles   := {} // O array receberá os nomes dos arquivos e do diretório
 Local aSizes   := {} // O array receberá os tamanhos dos arquivos e do diretorio
 Local aArqCsv  := {}
 Local nX,nY
 Local cExtens 	:= ".CSV"
 Local cArqCsv  := " "
 Local cArqZip  := _cPathRoot+"\"+SUBS(DTOS(date()),1,8)+"_"+SUBSTR(TIME(), 1, 2) +"h"+SUBSTR(TIME(), 4, 2)+".zip"    
 
 ADir(_cPath+"*.CSV", aFiles, aSizes)
 // Exibe dados dos arquivos
 nCount := Len( aFiles )

 If nCount == 0 
	Return
 EndIf 
 
 For nY:= 1 to nCount
 	cArqCsv := _cPath + aFiles[nY]
 	AADD( aArqCsv, cArqCsv) 
 Next nY
 
 nret := FZip(cArqZip,aArqCsv)
 
 if nret!=0
   conout("Não foi possível criar o arquivo zip")
 else
   conout("Arquivo zip criado com sucesso")
 endif             
 
 nCount := Len( aArqCsv )
 
 For nX := 1 to nCount
   Ferase( aArqCsv[nX] ) 
 Next nX

 DirRemove( _cPath )

Return         

/*
    Programa    : RDCTBSC.prw
    Funcao      : MyIsBlind
    Autor       : Thiago Góes 
    Data        : 29/03/2019  
    Uso         : Verificar Blind
*/
 Static Function MyIsBlind()
  Local oWnd    := GetWndDefault()  
   If  IsBlind() .or. (oWnd == NIL  .and.  Select("SM0") == 0 )
   		lRet := .T.
   EndIf
 Return(lRet)

   
/*
    Programa    : RDCTBSC.prw
    Funcao      : ChangeEmp
    Autor       : Thiago Góes 
    Data        : 29/03/2019  
    Uso         : Preparar ambiente para execução das schedules por filial corretamente.
*/

//************************************//
Static Function ChangeEmp(cEmpProc,cFilProc)
//************************************//
   Local aArea    := GetArea()
   Local aAreaSZ4 := SZ4->(GetArea())
   Local lRpcEnv  := ValType("cEmpAnt") != "C" .OR. (cEmpProc != cEmpAnt) .OR. (cFilProc != cFilAnt)

   // Inicia o Job
   If lRpcEnv 
      RpcSetType( 3 )
      PREPARE ENVIRONMENT EMPRESA cEmpProc FILIAL cFilProc MODULO "FIN"  
   Endif
   
//   StartJob("U_ContNfe",GetEnvServer(),.F.,_aParametros)
//   StartJob("U_ContFin",GetEnvServer(),.F.,_aParametros)
  
   ContNfe(cEmpProc,cFilProc)  // Processar Contabilização Compras
   ContFin(cEmpProc,cFilProc)  // Processar Contabilizacao Financeiro
   
   If Select("SZ4") == 0 
      RpcSetType( 3 )
      PREPARE ENVIRONMENT EMPRESA cEmpProc FILIAL cFilProc MODULO "FIN"
   EndIf 
   	
   RestArea(aArea)
   SZ4->(RestArea(aAreaSZ4))
   
Return    
 