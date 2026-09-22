#include "rwmake.ch"       
#INCLUDE "PROTHEUS.CH"    
#INCLUDE "FWADAPTEREAI.CH"
#INCLUDE "XMLXFUN.CH"
#Define CRLF CHR(13)+CHR(10)

//================================================================================================
/*/
Rotina para geracao do arquivo de compra dos Beneficios da Alelo - VA-VR
@author     A.Shibao
@since      18/08/16
@param		
@version    P12
@return      
@project   EF_002_GPE_R468
@client    RedeDor   
/*/                 
// 02/09/16 - A.Shibao - Ajuste tirando o filial de-ate pois sera gerado individualmente
// 10/03/17 - A.Shibao - Ajuste tratando todos os campos numericos e caracter.
//================================================================================================
User Function DorGerVRA()
                                  
//Local oDlg
Local oRadio
Local nRadio
Local nOpca := 1

// Declaracao de variaveis private
SetPrvt("lEnd,lContinua,lAbortPrint,lImpLis,nHdl,nLin0,cPerg,cFilDe,cFilAte,cCcDe,cCcAte,cMatDe,cMatAte,nQtdFun,cCivi")
SetPrvt("cGvt,cGva,cCodCon,cNomeCon,cNomeArq,cShowFil,cShowMat,cFil,cPerRef,cTipo,cEmp,cDtEntr,cDtEmis,cValRef,cMat,cArq")
SetPrvt("cDatN,cDatA,cNomeF,cPis,cCic,cLin,dPerRef,dDtEnt,nDtrab,nDafas,nDfal,nValBen,nValBenT,nValRef,nSeq,lImpLis,lFlag,aReg,aInfoE")
SetPrvt("aCamp,cString,aOrd,aReturn,nTamanho,Titulo,cDesc1,cDesc2,cDesc3,cCancel,wCabec1,wCabec2,NomeProg,cArqInd,cInd,nLastKey,m_pag,li")
SetPrvt("ContFl,nOrdem,nTfunc,nTccFunc,nTBen,nTccBen,nTgfunc,nTgBen,wnrel,cGvr,cNumPed,cCcAnt,cCcDesc,nPerDes,cValAnt,cCCAnt,oDlg")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de Variaveis                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cNomeArq    := '' 
cArq        := ''
lEnd        := .F.
lContinua   := .T.
lAbortPrint := .F.
lImpLis     := .F.
nHdl        := 0 
nLin0       := 0
cPerg 		:= 'ALELOVA'
cPerg1 		:= 'ALELOVR'

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica as perguntas                                                ³
//ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
//³ mv_par01    Da Filial          -  Filial Inicial                     ³
//³ mv_par02    Ate a Filial       -  Filial final                       ³
//³ mv_par03    Do Centro de Custo -  Do Centro de Custo                 ³
//³ mv_par04    Ate Centro de Custo-  Ate Centro de Custo                ³
//³ mv_par05    Da Matricula       -  Matricula inicial                  ³
//³ mv_par06    Ate a Matricula    -  Matricula final                    ³
//³ mv_par07    Periodo de Refer.  -  Data para Referencia               ³
//³ mv_par08    Data de Efetivacao -  Data para Efetivacao               ³
//³ mv_par09    Pedido Normal/Comp -  Pedido Normal/Complementar         ³
//³ mv_par10    Nome do Contato    -  Nome do Contato na Empresa         ³
//³ mv_par11    DDD                -                                     ³
//³ mv_par12    Telefone           -                                     ³
//³ mv_par13    Ramal              -                                     ³
//³ mv_par14    Endereco           -                                     ³
//³ mv_par15    Codigo Contrato    -  Codigo Contrato                    ³
//³ mv_par16    Numero do Pedido   -  Numero do Pedido                   ³
//³ mv_par17    Centraliza Entrega -  Centraliza Entrega                 ³
//³ mv_par18    Nome do Arquivo    -                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ    

VerPerg()
VerPerg1()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Montagem da tela para selecionar qual beneficio quer gerar          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ  

While nOpca == 1 

	DEFINE MSDIALOG oDlg FROM  94,1 TO 273,293 TITLE OemToAnsi("Geração de Arquivo Texto Alelo") PIXEL // "Apropriacao de Custos"
	
	@ 10,17 Say OemToAnsi("Qual benefício você deseja gerar ?") SIZE 150,7 OF oDlg PIXEL
	
	@ 27,07 TO 72, 140 OF oDlg  PIXEL
	
	@ 35,10 Radio 	oRadio VAR nRadio;
				ITEMS "Vale Alimentação",;	
					  "Vale Refeição",;
					  "Vale Transporte";
				3D SIZE 100,10 OF oDlg PIXEL
	
	DEFINE SBUTTON FROM 75,085 TYPE 1 ENABLE OF oDlg ACTION (nOpca := 1, oDlg:End())
	DEFINE SBUTTON FROM 75,115 TYPE 2 ENABLE OF oDlg ACTION (nOpca := 0, oDlg:End())
	
	ACTIVATE MSDIALOG oDlg CENTERED ON INIT (nOpca := 0, .T.)	// Zero nOpca caso 
                                                               //	para saida com ESC

	If nOpca == 1
		If nRadio == 1
			cGvt := "1"    // vA
			Continua()
		ElseIf nRadio == 2
			cGvt := "2"   // vR
			Continua()
		ElseIf nRadio == 3 // vT
			u_DorGerVT(@nHdl,@cNomeArq,@nLin0)
		EndIf
	EndIf
	
	//grava o registro 
	If nHdl > 0 .and. nOpca # 0
		If fClose(nHdl)
			If nLin0 > 0 .And. lContinua
				Aviso('AVISO','Gerado o arquivo ' + AllTrim(cNomeArq) + '...',{'OK'})
				nOpca := 2
			Else
				If fErase(cNomeArq) == 0
					If lContinua
						Aviso('AVISO','Nao existem registros a serem gravados. A geraco do arquivo ' + AllTrim(cNomeArq) + ' foi abortada ...',{'OK'})
					EndIf	
				Else
					MsgAlert('Ocorreram problemas na tentativa de deletar o arquivo '+AllTrim(cNomeArq)+'.')
				EndIf	
			EndIf	
		Else
			MsgAlert('Ocorreram problemas no fechamento do arquivo '+AllTrim(cNomeArq)+'.')
		EndIf
	EndIf  
	          
EndDo
	
Return

//==========================================================================================
/*/
Funcao para continuacao do processamento (na confirmacao)
@author     A.Shibao
@since      18/08/16
@param		
@version    P12
@return      
@project 
@client    RedeDor   
/*/
//==========================================================================================
Static Function Continua()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicializa variaveis utilizadas pelo programa                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cFilDe		:= ''
cFilAte		:= ''
cCcDe		:= ''
cCcAte		:= ''
cMatDe		:= ''
cMatAte		:= ''
cGva		:= ''
cGvr		:= ''
cCodCon		:= ''
cNomeCon	:= ''
cNomeArq	:= ''
cShowFil	:= ''
cShowMat	:= ''
cFil		:= ''
cPerRef		:= ''
cPerPes		:= ''
cTipo		:= ''
cEmp		:= ''
cDtEntr		:= ''
cDtEmis		:= ''
cValRef		:= ''
cMat		:= ''
cDatN		:= ''
cDatA		:= ''
cNomeF		:= ''
cPis		:= ''
cCic		:= ''
cLin		:= ''
cArq		:= ''
cNumPed		:= ''
cGera		:= ''
cDiasMes	:= ''
cValAnt		:= ''
cCivi		:= ''
cCCAnt		:= ''
dPerRef		:= cTod("  /  /  ")
dDtEnt		:= cTod("  /  /  ")
nDtrab		:= 0
nDafas		:= 0
nDfal		:= 0
nValBen		:= 0
nValBenT	:= 0
nValRef		:= 0
nSeq		:= 0
nQtdFun		:= 0    
nPerDes		:= 0
nEntre		:= 0
lImpLis		:= .F.
lFlag		:= .F.
aReg		:= {}
aInfoE		:= {}
aCamp		:= {}
cPerg 		:= 'ALELOVA'
cPerg1 		:= 'ALELOVR'

If cGvt == "1"
	If !Pergunte(cPerg, .T. )
		Return
	EndIf 
Else
	If !Pergunte(cPerg1, .T. )
		Return
	EndIf 
Endif	

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicializa variaveis utilizadas como Pergunte                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//cFilDe   := mv_par01 								// Da Filial
cFilAte  := mv_par01 								// Ate a Filial
cCcDe    := mv_par02 								// Do Centro de Custo
cCcAte   := mv_par03 								// Ate Centro de Custo
cMatDe   := mv_par04 						   		// Da Matricula
cMatAte  := mv_par05 								// Ate a Matricula
dPerRef  := If(Empty(mv_par06),dDataBase,mv_par06)	// Periodo de Referencia
dDtEnt   := If(Empty(mv_par07),dDataBase,mv_par07) 	// Data da Efetivacao
cGva     := If(mv_par08==1,"1","2") 				// Pedido Normal/Complementar
cNomeCon := mv_par09 								// Nome do Contato na Empresa 
cDDD     := mv_par10                                // DDD
cTel     := mv_par11                                // Telefone
cRamal   := mv_par12                                // Ramal
cEnderc  := mv_par13                                // Endereco
//cCodCon	 := mv_par14 								// Codigo Contrato
//cNumPed	 := mv_par15 								// Numero do Pedido
cGvr	 := If(mv_par14==1,"1","2")					// Centraliza Entrega
cNomeArq := mv_par15 								// Nome do Arquivo    

cCodCon	 := Iif( cGvt == "1",U_fMtaCoVa() , U_fMtaCoVr())    								// Codigo Contrato

While .T.
	If File(cNomeArq)
		If (nAviso := Aviso('AVISO','Deseja substituir o ' + AllTrim(cNomeArq) + ' existente ?', {'Sim','Nao','Cancela'})) == 1
			If fErase(cNomeArq) == 0
				Exit
			Else
				MsgAlert('Ocorreram problemas na tentativa de deletar o arquivo '+AllTrim(cNomeArq)+'.')
			EndIf		
		ElseIf nAviso == 2
				Pergunte(cPerg,.T.)							
			Loop
		Else
			Return
		EndIf		
	Else
		Exit
	EndIf	
EndDo

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria o arquivo texto                                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	     
nHdl := fCreate(cNomeArq)

If nHdl == -1
	MsgAlert('O arquivo '+AllTrim(cNomeArq)+' nao pode ser criado! Verifique os parametros.','Atencao!')
	Return
Endif
       
//Carrega Dados da Filial
fLocalInfo()

// Inicializa processamento
Processa({|lEnd| RunCont()}, 'Processando...')


Return  

//==========================================================================================
/*/
Funcao para processar os registros.
@author     A.Shibao
@since      18/08/16
@param		
@version    P12
@return      
@project 
@client    RedeDor   
/*/
//==========================================================================================
Static Function RunCont()

lNotFound	 := .F.
cQuery    	 := ''                 

//Verifica se houve alteração de cadastro na tabela S011
dbSelectArea("RCC")
dbSetOrder(RetOrder("RCC","RCC_FILIAL+RCC_CODIGO+RCC_FIL+RCC_CHAVE+RCC_SEQUEN"))
dbSeek(xFilial("RCC")+"S011")
While !Eof() .And. RCC->RCC_FILIAL + RCC->RCC_CODIGO == xFilial("RCC")+"S011"
	
	If cGvt == "1" 
		cBenef := "84" 
		If Substr(RCC->RCC_CONTEU,1,2) == cBenef
			lNotFound:= .T.
		Endif
	Else 
		cBenef := "85"	 
		If Substr(RCC->RCC_CONTEU,1,2) == cBenef
			lNotFound:= .T.
		Endif
	Endif	
	
	("RCC")->(dbSkip())
End      

If !(lNotFound)
    If cGvt == "1" 
		Alert("O cadastrdo do VA na tabela S011 foi alterado, favor ajusta para o codigo 84 ! ")
	Else
		Alert("O cadastrdo do VR na tabela S011 foi alterado, favor ajusta para o codigo 85 ! ")
	Endif	
	Return
Endif	

// Busca os registros na SR0
MsAguarde( {|| fMtaQuery()}, "Processando...", "Selecao de Registros" )

nTotReg  := 1
nContReg := 1
dbSelectArea( "RDOR001" )
dbGoTop()
Do While !Eof()
	dbSkip()
	If !Eof()
		nTotReg ++
	EndIf
EndDo

dbSelectArea( "RDOR001" )
dbGoTop()

ProcRegua( nTotReg )      

cPerRef  := AllTrim(strzero(val(substr(dtos(dDtEnt),5,2)),2)) +  AllTrim(strzero(val(substr(dtos(dDtEnt),1,4)),4))

While !RDOR001->(Eof()) .And. lContinua 

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Incrementa a regua                                                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
	IncProc( "Processando: "+StrZero(nContReg,6)+" de "+StrZero(nTotReg,6))
	
	nContReg++ 
	
	If lAbortPrint .Or. lEnd
		If Aviso('ATENCAO','Deseja abandonar a Geracao do arquivo ' + AllTrim(AllTrim(cNomeArq)) + ' ?',{'Sim','Nao'}) == 1
			lContinua := .F.
			Exit
		EndIf	
	Endif
              
    nDtrab    := 30
    nDfal	  := 0
	lFlag	  := .F.
	cFil      := RDOR001->RA_FILIAL 

	//Filtra Demitidos
	If RDOR001->RA_SITFOLH =='D'
		RDOR001->(dbSkip())
		Loop		
	EndIf   
	
  	//Gera Registro Tipo 1
//	If cFil != RDOR001->RA_FILIAL .And. SRA->(!Eof())
//			cFilAnt := RDOR001->RA_FILIAL
			
			//Carrega Dados da Filial
//			fLocalInfo()     
			
//			fGeraTipo1()
			
			//Gera Registro Tipo 2
			//If cGvr == '2' //Centraliza Entrega
			//	cCCAnt := RDOR001->RA_CC
  			//	fGeraTipo2()
	  		//Endif			
  		
//	Endif
    
	
    // Verifica Dias de Afastamento
	//fDiasAfast(@nDafas,@nDtrab,dPerRef)

	//Busca o VA ou VR pela variavel cGvt
	//If lFlag == .T.
    	
    	//incializa linha
    	If nLin0 == 0
    		nLin0 += 1
    	Endif
		
		//Gera Registro linha 1
		If nSeq == 0
			nSeq += 1
			fGeraTipo0()
		Endif	
		
		If cGvr == '2' //Centraliza Entrega
   				If cCCAnt != RDOR001->RA_CC
  					cCCAnt := RDOR001->RA_CC
  					fGeraTipo2()
  				Endif
		Endif	 
		
		nDtrab	:= RDOR001->R0_QDIACAL
		nValBen	:= RDOR001->R0_VALCAL
		
		fGeraTipo5()

		//Totaliza Funcionario e Beneficio
		nQtdFun  += 1
		nValBenT += nValBen
		
		//Zera Variaveis
		nDtrab := 0
		nDfal  := 0

	//Endif	
		
	
	RDOR001->(dbSkip())
  	
   	//Gera Registro Tipo 1
/*	If cFil != RDOR001->RA_FILIAL .And. RDOR001->(!Eof())
		cFil := RDOR001->RA_FILIAL
		fGeraTipo1()
			
		//Gera Registro Tipo 2
		If cGvr == '2' .And. RDOR001->(!Eof()) //Centraliza Entrega
			cCCAnt := RDOR001->RA_CC
  			fGeraTipo2()
  		Endif			
  		
	Endif
*/
   	
EndDo          

fGeraTipo9()

Return

//==========================================================================================
/*/
Funcao para gerar linha com Registro Tipo "0"
@author     A.Shibao
@since      18/08/16
@param		
@version    P12
@return      
@project 
@client    RedeDor   
/*/
//==========================================================================================
Static Function fGeraTipo0()

cTipo         := '0'
cEmp          := Substr(aInfoE[2] + Space(40),1,35)
cDtEntr       := AllTrim(strzero(val(substr(dtos(dDtEnt),7,2)),2)) +  AllTrim(strzero(val(substr(dtos(dDtEnt),5,2)),2)) +  AllTrim(strzero(val(substr(dtos(dDtEnt),1,4)),4))
cDtEmis       := AllTrim(strzero(val(substr(dtos(dDataBase),7,2)),2)) + AllTrim(strzero(val(substr(dtos(dDataBase),5,2)),2)) + AllTrim(strzero(val(substr(dtos(dDataBase),1,4)),4))
cNumPed		  := AllTrim(StrZero(Val(cNumPed),6))
			
cLin := cTipo + cDtEmis + "A001"  + cEmp + strzero(val(aInfoE[9]),14) + Replic("0",11) + strzero(val(cCodCon),11) + strzero(val(cNumPed),6) + cDtEntr + cGvt
cLin += cGva + cPerRef + Space(18) + "007" + Space(267) + StrZero(nSeq,6) +  CRLF 

nSeq += 1

fGravaReg()

fGeraTipo1()

//Gera Registro Tipo 2
If cGvr == '2' //Centraliza Entrega
	cCCAnt := RDOR001->RA_CC
	fGeraTipo2()
Endif			
			
Return

//==========================================================================================
/*/
Funcao para gerar linha com Registro Tipo "1"
@author     A.Shibao
@since      18/08/16
@param		
@version    P12
@return      
@project 
@client    RedeDor   
/*/
//==========================================================================================
Static Function fGeraTipo1()
        
cTipo   := '1'           

cLin    := cTipo + strzero(val(aInfoE[9]),14) + Replic("0",10) + Subst(aInfoE[2] + Space(35),1,35) + strzero(val(cDDD),4) + Subst(cNomeCon + Space(35),1,35)
cLin    += substr(cEnderc+Space(40),1,40) + strzero(val(cTel),12) + strzero(val(cRamal),6) + Space(75) + Replic("0",18) + Space(75) + Replic("0",18) + Space(20) + Space(31)
cLin 	+= StrZero(nSeq,6) + CRLF

fGravaReg()

nSeq += 1
            
Return

//==========================================================================================
/*/
Funcao para gerar linha com Registro Tipo "2"
@author     A.Shibao
@since      18/08/16
@param		
@version    P12
@return      
@project 
@client    RedeDor   
/*/
//========================================================================================== 
Static Function fGeraTipo2()

cTipo   := '2'           
cDesc	:= DescCC(cCcAnt)

cLin    := cTipo +	Space(20) + Space(20) + Subst((cCcAnt + Space(20)),1,20)
cLin    += Subst((cDesc + Space(20)),1,20) + Space(40) + strzero(val(cDDD),4) + Subst(cNomeCon + Space(35),1,35)
cLin 	+= strzero(val(cTel),12) + strzero(val(cRamal),6) + Space(35) + Replic("0",12) + Replic("0",6) + Space(163) + StrZero(nSeq,6) + CRLF

fGravaReg()
         
nSeq += 1

Return

//==========================================================================================
/*/
Funcao para gerar linha com Registro Tipo "5" 
@author     A.Shibao
@since      18/08/16
@param		
@version    P12
@return      
@project 
@client    RedeDor   
/*/
//========================================================================================== 
Static Function fGeraTipo5()

//Gera Registro tipo Zero
If nSeq == 0
	nSeq += 1
	fGeraTipo0()
Endif	 

cTipo 	:= "5"
cValRef := StrZero(nValBen * 100,11) 
cMat 	:= Subst(RDOR001->RA_MAT + Space(13),1,13)
cDatN	:= AllTrim(strzero(val(substr(RDOR001->RA_NASC,7,2)),2)) + AllTrim(strzero(val(substr(RDOR001->RA_NASC,5,2)),2)) + AllTrim(strzero(val(substr(RDOR001->RA_NASC,1,4)),4))
cDatA	:= AllTrim(strzero(val(substr(RDOR001->RA_ADMISSA,7,2)),2)) + AllTrim(strzero(val(substr(RDOR001->RA_ADMISSA,5,2)),2)) + AllTrim(strzero(val(substr(RDOR001->RA_ADMISSA,1,4)),4))
cCic	:= Iif(Empty(RDOR001->RA_CIC),Replic("0",11),strzero(val(RDOR001->RA_CIC),11))	
cPis	:= Iif(Empty(RDOR001->RA_PIS),Replic("0",15),StrZero(Val(RDOR001->RA_PIS),15))
cRG     := Substr(RDOR001->RA_RG + Space(13),1,13)
cRGorg  := Substr(RDOR001->RA_RGORG + Space(20),1,20)
cRGuf   := Substr(RDOR001->RA_RGUF + Space(6),1,6)
cREnder := Substr(RDOR001->RA_ENDEREC + Space(35),1,35) 
cRCompl := Substr(RDOR001->RA_COMPLEM + Space(10),1,10) 
cRNumEn := Strzero(val(RDOR001->RA_NUMENDE),5) 
cRCep   := Strzero(val(RDOR001->RA_CEP),8)
cRMunic := Substr(RDOR001->RA_MUNICIP + Space(28),1,28)
cRBairr := Substr(RDOR001->RA_BAIRRO + Space(30),1,30)
cREst   := Substr(RDOR001->RA_ESTADO + Space(2),1,2)   
cRMae   := Substr(RDOR001->RA_MAE + Space(35),1,35) 
cRDDFon := Strzero(val(RDOR001->RA_DDDFONE),4) 
//cRTelef := Iif(len(alltrim(RDOR001->RA_TELEFON)) >=8, Right(alltrim(RDOR001->RA_TELEFON),8),strzero(val(alltrim(RDOR001->RA_TELEFON)),8))
cNomeF  := Substr(RDOR001->RA_NOME + Space(40),1,40) 

// Ajuste o telefone devido a base do cliente
If !Empty(RDOR001->RA_TELEFON)
	cRet := ""
	For n := 1 To Len (RDOR001->RA_TELEFON)
		 If Substr(RDOR001->RA_TELEFON,n,1) $ "0123456789"
		  cRet += Substr(RDOR001->RA_TELEFON,n,1)
		 EndIf
	Next 
	cRTelef:= cRet
	cRTelef := Iif(len(alltrim(cRTelef)) >=8, Right(alltrim(cRTelef),8),strzero(val(alltrim(cRTelef)),8))
Else
	cRTelef := strzero(val(alltrim(RDOR001->RA_TELEFON)),8)
Endif	              


//Gerar cartão e senha em branco
cGera := ' '

//Codigo de Estado Civil
If SRA->RA_ESTCIVI == "S"
	cCivi	:= "1"
ElseIf SRA->RA_ESTCIVI == "C"
	cCivi	:= "2"
ElseIf SRA->RA_ESTCIVI == "V"
	cCivi	:= "3"
ElseIf SRA->RA_ESTCIVI $ "D*Q"
	cCivi	:= "4"
Else
	cCivi	:= "5"
Endif				
		
cLin 	:= cTipo + cValRef + cGera + cMat + Space(54) + cDatN + cCic + Space(1) + cRG + cRGorg + cRGuf + cPis + RDOR001->RA_SEXO
cLin	+= cCivi + cREnder + cRCompl + cRNumEn + cRCep + cRMunic + cRBairr + cREst + cRMae + Space(1) + Replic("0",16) + cRDDFon + cRTelef 
cLin	+= Space(1) + cDatA + " " + cNomeF + Space(6) + StrZero(nSeq,6) + CRLF

fGravaReg()

nSeq += 1

Return

//==========================================================================================
/*/
Funcao para gerar linha com Registro Tipo "9"
@author     A.Shibao
@since      18/08/16
@param		
@version    P12
@return      
@project 
@client    RedeDor   
/*/
//==========================================================================================
Static Function fGeraTipo9()

cTipo := "9" 

cLin := cTipo + StrZero(nQtdFun,6) + StrZero(nValBenT * 100,15) + Space(372) + StrZero(nSeq,6)

fGravaReg()

Return

//==========================================================================================
/*/
Funcao para gravar Registros no Arquivo Texto
@author     A.Shibao
@since      18/08/16
@param		
@version    P12
@return      
@project 
@client    RedeDor   
/*/
//==========================================================================================
Static Function fGravaReg()

If fWrite(nHdl,cLin,Len(cLin)) != Len(cLin)
	If !MsgYesNo('Ocorreu um erro na gravacao do arquivo '+AllTrim(cNomeArq)+'.   Continua?','Atencao!')
		lContinua := .F.
		Return
	Endif
Endif            
	
Return


//==========================================================================================
/*/
Funcao para inicializar o Array aInfo com informacoes do Local 
@author     A.Shibao
@since      18/08/16
@param		
@version    P12
@return      
@project 
@client    RedeDor   
/*/
//==========================================================================================
Static Function fLocalInfo()
                                     
aInfoE := {}

// Armazena Registro Atual
nSM0Recno := SM0->(Recno())

SM0->(dbSeek(cEmpAnt + mv_par01,.T.))

Aadd(aInfoE,SM0->M0_NOME)
Aadd(aInfoE,SM0->M0_NOMECOM)
Aadd(aInfoE,SM0->M0_ENDENT)
Aadd(aInfoE,SM0->M0_CIDENT)
Aadd(aInfoE,SM0->M0_ESTENT)
Aadd(aInfoE,SM0->M0_CEPENT)
Aadd(aInfoE,SM0->M0_BAIRENT)
Aadd(aInfoE,SM0->M0_COMPENT)
Aadd(aInfoE,SM0->M0_CGC)
Aadd(aInfoE,SM0->M0_FILIAL)

// Retorna ao Registro
SM0->(dbGoto(nSM0Recno))

Return

//==========================================================================================
/*/
Funcao para criacao das perguntas p/ VA
@author     A.Shibao
@since      18/08/16
@param		
@version    P12
@return      
@project 
@client    RedeDor   
/*/
//==========================================================================================
Static Function VerPerg()

aRegs     := {}

cPerg := Left(cPerg,7)

//X1_GRUPO,X1_ORDEM,X1_PERGUNT,X1_PERSPA,X1_PERENG,X1_VARIAVL,X1_TIPO,X1_TAMANHO,X1_DECIMAL,X1_PRESEL,X1_GSC,X1_VALID,X1_VAR01,X1_DEF01,X1_DEFSPA1,X1_DEFENG1,X1_CNT01,X1_VAR02,X1_DEF02,X1_DEFSPA2,X1_DEFENG2,X1_CNT02,X1_VAR03,X1_DEF03,X1_DEFSPA3,X1_DEFENG3,X1_CNT03,X1_VAR04,X1_DEF04,X1_DEFSPA4,X1_DEFENG4,X1_CNT04,X1_VAR05,X1_DEF05,X1_DEFSPA5,X1_DEFENG5,X1_CNT05,X1_F3,X1_PYME,X1_GRPSXG,X1_HELP  
//aAdd(aRegs,{cPerg,"01","Da Filial          ?","Da Filial          ?","Da Filial          ?","mv_ch1","C",8,0,0,"G","","mv_par01","","","","01","","","","","","","","","","","","","","","","","","","","","SM0","","",""})
aAdd(aRegs,{cPerg,"01","Filial             ?","Ate a Filial       ?","Ate a Filial       ?","mv_ch1","C",8,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","SM0","","",""})
aAdd(aRegs,{cPerg,"02","Do Centro Custo    ?","Do Centro de Custo ?","Do Centro de Custo ?","mv_ch2","C",9,0,0,"G","","mv_par02","","","","000000001","","","","","","","","","","","","","","","","","","","","","SI3","","",""})
aAdd(aRegs,{cPerg,"03","At‚ Centro de Custo?","At‚ Centro de Custo?","At‚ Centro de Custo?","mv_ch3","C",9,0,0,"G","","mv_par03","","","","999999999","","","","","","","","","","","","","","","","","","","","","SI3","","",""})
aAdd(aRegs,{cPerg,"04","Da Matricula       ?","Da Matricula       ?","Da Matricula       ?","mv_ch4","C",6,0,0,"G","","mv_par04","","","","000001","","","","","","","","","","","","","","","","","","","","","SRA","","",""})
aAdd(aRegs,{cPerg,"05","Ate Matricula      ?","Ate Matricula      ?","Ate Matricula      ?","mv_ch5","C",6,0,0,"G","","mv_par05","","","","999999","","","","","","","","","","","","","","","","","","","","","SRA","","",""})
aAdd(aRegs,{cPerg,"06","Data de Referencia ?","Data de Referencia ?","Data de Referencia ?","mv_ch6","D",8,0,0,"G","","mv_par06","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"07","Data Efetivacao    ?","Data Efetivacao    ?","Data Efetivacao    ?","mv_ch7","D",8,0,0,"G","naovazio","mv_par07","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"08","Normal/Complementar?","Normal/Complementar?","Normal/Complementar?","mv_ch8","N",1,0,0,"C","","mv_par08","Normal","Normal","Normal","","","Complementar","Complementar","Complementar","","","","","","","","","","","","","","","","","","","",""})  
aAdd(aRegs,{cPerg,"09","Nome do Contato    ?","Nome do Contato    ?","Nome do Contato    ?","mv_ch9","C",35,0,0,"G","naovazio","mv_par09","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"10","DDD                ?","DDD                ?","DDD                ?","mv_cha","C",4,0,0,"G","","mv_par10","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"11","Telefone           ?","Telefone           ?","Telefone           ?","mv_chb","C",12,0,0,"G","","mv_par11","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"12","Ramal              ?","Ramal              ?","Ramal              ?","mv_chc","C",6,0,0,"G","","mv_par12","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"13","Endereco           ?","Endereco           ?","Endereco           ?","mv_chd","C",40,0,0,"G","","mv_par13","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
//aAdd(aRegs,{cPerg,"14","Codigo Contrato    ?","Codigo Contrato    ?","Codigo Contrato    ?","mv_che","C",11,0,0,"G","","mv_par14","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
//aAdd(aRegs,{cPerg,"15","Numero Pedido      ?","Numero Pedido      ?","Numero Pedido      ?","mv_chf","C",6,0,0,"G","","mv_par15","","","","000000","","","","","","","","","","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"14","Centraliza Entrega ?","Centraliza Entrega ?","Centraliza Entrega ?","mv_che","N",1,0,2,"C","","mv_par14","Sim","Sim","Sim","","","Nao","Nao","Nao","","","","","","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"15","Nome do Arquivo    ?","Nome do Arquivo    ?","Nome do Arquivo    ?","mv_chf","C",40,0,0,"G","naovazio","mv_par15","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
ValidPerg(aRegs,cPerg ,.F.)

Return   

//==========================================================================================
/*/
Funcao para criacao das perguntas p/ VR
@author     A.Shibao
@since      18/08/16
@param		
@version    P12
@return      
@project 
@client    RedeDor   
/*/
//==========================================================================================
Static Function VerPerg1()

aRegs     := {}

cPerg := Left(cPerg1,7)

//X1_GRUPO,X1_ORDEM,X1_PERGUNT,X1_PERSPA,X1_PERENG,X1_VARIAVL,X1_TIPO,X1_TAMANHO,X1_DECIMAL,X1_PRESEL,X1_GSC,X1_VALID,X1_VAR01,X1_DEF01,X1_DEFSPA1,X1_DEFENG1,X1_CNT01,X1_VAR02,X1_DEF02,X1_DEFSPA2,X1_DEFENG2,X1_CNT02,X1_VAR03,X1_DEF03,X1_DEFSPA3,X1_DEFENG3,X1_CNT03,X1_VAR04,X1_DEF04,X1_DEFSPA4,X1_DEFENG4,X1_CNT04,X1_VAR05,X1_DEF05,X1_DEFSPA5,X1_DEFENG5,X1_CNT05,X1_F3,X1_PYME,X1_GRPSXG,X1_HELP  
//aAdd(aRegs,{cPerg,"01","Filial             ?","Da Filial          ?","Da Filial          ?","mv_ch1","C",8,0,0,"G","","mv_par01","","","","01","","","","","","","","","","","","","","","","","","","","","SM0","","",""})
aAdd(aRegs,{cPerg,"01","Filial             ?","Ate a Filial       ?","Ate a Filial       ?","mv_ch1","C",8,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","SM0","","",""})
aAdd(aRegs,{cPerg,"02","Do Centro Custo    ?","Do Centro de Custo ?","Do Centro de Custo ?","mv_ch2","C",9,0,0,"G","","mv_par02","","","","000000001","","","","","","","","","","","","","","","","","","","","","SI3","","",""})
aAdd(aRegs,{cPerg,"03","At‚ Centro de Custo?","At‚ Centro de Custo?","At‚ Centro de Custo?","mv_ch3","C",9,0,0,"G","","mv_par03","","","","999999999","","","","","","","","","","","","","","","","","","","","","SI3","","",""})
aAdd(aRegs,{cPerg,"04","Da Matricula       ?","Da Matricula       ?","Da Matricula       ?","mv_ch4","C",6,0,0,"G","","mv_par04","","","","000001","","","","","","","","","","","","","","","","","","","","","SRA","","",""})
aAdd(aRegs,{cPerg,"05","Ate Matricula      ?","Ate Matricula      ?","Ate Matricula      ?","mv_ch5","C",6,0,0,"G","","mv_par05","","","","999999","","","","","","","","","","","","","","","","","","","","","SRA","","",""})
aAdd(aRegs,{cPerg,"06","Data de Referencia ?","Data de Referencia ?","Data de Referencia ?","mv_ch6","D",8,0,0,"G","","mv_par06","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"07","Data Efetivacao    ?","Data Efetivacao    ?","Data Efetivacao    ?","mv_ch7","D",8,0,0,"G","naovazio","mv_par07","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"08","Normal/Complementar?","Normal/Complementar?","Normal/Complementar?","mv_ch8","N",1,0,0,"C","","mv_par08","Normal","Normal","Normal","","","Complementar","Complementar","Complementar","","","","","","","","","","","","","","","","","","","",""})  
aAdd(aRegs,{cPerg,"09","Nome do Contato    ?","Nome do Contato    ?","Nome do Contato    ?","mv_ch9","C",35,0,0,"G","naovazio","mv_par09","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"10","DDD                ?","DDD                ?","DDD                ?","mv_cha","C",4,0,0,"G","","mv_par10","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"11","Telefone           ?","Telefone           ?","Telefone           ?","mv_chb","C",12,0,0,"G","","mv_par11","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"12","Ramal              ?","Ramal              ?","Ramal              ?","mv_chc","C",6,0,0,"G","","mv_par12","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"13","Endereco           ?","Endereco           ?","Endereco           ?","mv_chd","C",40,0,0,"G","","mv_par13","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
//aAdd(aRegs,{cPerg,"14","Codigo Contrato    ?","Codigo Contrato    ?","Codigo Contrato    ?","mv_che","C",11,0,0,"G","","mv_par14","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
//aAdd(aRegs,{cPerg,"15","Numero Pedido      ?","Numero Pedido      ?","Numero Pedido      ?","mv_chf","C",6,0,0,"G","","mv_par15","","","","000000","","","","","","","","","","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"14","Centraliza Entrega ?","Centraliza Entrega ?","Centraliza Entrega ?","mv_che","N",1,0,2,"C","","mv_par14","Sim","Sim","Sim","","","Nao","Nao","Nao","","","","","","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"15","Nome do Arquivo    ?","Nome do Arquivo    ?","Nome do Arquivo    ?","mv_chf","C",40,0,0,"G","naovazio","mv_par15","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})

ValidPerg(aRegs,cPerg1 ,.F.)

Return       

//==========================================================================================
/*/
Funcao para buscar os registros na base
@author     A.Shibao
@since      18/08/16
@param		
@version    P12
@return      
@project 
@client    RedeDor   
/*/
//==========================================================================================
Static Function fMtaQuery()

Local cQuery    := ""
Local cArqPesq	:= ""

//Verifica Tabela Aberta
If Select("RDOR001") > 0
	DbSelectArea("RDOR001")
	DbCloseArea("RDOR001")
Endif

cQuery := "  SELECT RA_FILIAL, RA_MAT, RA_CIC, RA_NOME, RA_CC, RA_SITFOLH, RA_NASC, RA_ADMISSA, RA_PIS,  RA_ESTCIVI, RA_SEXO, "
cQuery += "  RA_RG, RA_RGORG, RA_RGUF, RA_ENDEREC, RA_COMPLEM, RA_NUMENDE, RA_CEP, RA_MUNICIP, RA_BAIRRO,  RA_ESTADO, RA_MAE, "
cQuery += "  RA_DDDFONE, RA_TELEFON, "
cQuery += "  R0_CODIGO, R0_DIASPRO, R0_QDIAINF, R0_QDIACAL, R0_VALCAL, R0_VLRVALE, R0_VLRFUNC, R0_VLREMP   "


cQuery += "  FROM "+ RetSqlName("SRA") + " SRA"
cQuery += "  INNER JOIN "+ RetSqlName("SR0") + " SR0 on R0_FILIAL = RA_FILIAL  AND R0_MAT = RA_MAT "
//cQuery += "  INNER JOIN "+ RetSqlName("SRN") + " SRN on RN_FILIAL = R0_FILIAL  AND RN_COD = R0_CODIGO "

cQuery += "  WHERE "

cQuery += "  RA_FILIAL >= '"  + cFilAte + "'  AND RA_FILIAL <= '" + cFilAte + "' And"
cQuery += "  RA_CC     >= '"  + cCcDe  + "'  AND RA_CC     <= '" + cCcAte  + "' And"
cQuery += "  RA_MAT    >= '"  + cMatDe + "'  AND RA_MAT    <= '" + cMatAte + "' And"
//cQuery += "  RN_TPBEN    = '" + cGvt + "'    And"

If cGvt == "1"
	cQuery += "  R0_TPVALE   = '2'     And"
Else
	cQuery += "  R0_TPVALE   = '1'     And"
Endif	

cQuery += "  R0_VALCAL   > 0       And"
cQuery += "  R0_DIASPRO  <> '99'   And"

cQuery += "  RA_DEMISSA  = ''      And"

cQuery += "  SRA.D_E_L_E_T_ <> '*' And"
cQuery += "  SR0.D_E_L_E_T_ <> '*' "//And"
//cQuery += "  SRN.D_E_L_E_T_ <> '*' "         

cQuery += "  ORDER BY RA_CC, RA_MAT " 

cQuery := ChangeQuery(cQuery)

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"RDOR001")

/*
TcSetField( "RDOR001", "R0_DIASPRO" , "N",  3, 0 )
TcSetField( "RDOR001", "R0_DPROPIN" , "N",  3, 0 )
TcSetField( "RDOR001", "R0_DUTILM"  , "N",  3, 0 )
TcSetField( "RDOR001", "R0_QDIACAL" , "N",  3, 0 )
TcSetField( "RDOR001", "R0_VALCAL"  , "N", 12, 2 )
TcSetField( "RDOR001", "R0_VLRVALE" , "N", 12, 2 )
TcSetField( "RDOR001", "R0_VLRFUNC" , "N", 12, 2 )
TcSetField( "RDOR001", "R0_VLREMP"  , "N", 12, 2 )
TcSetField( "RDOR001", "R0_SALBASE" , "N", 12, 2 )
*/

Return 

//==========================================================================================
/*/
Monta consulta para buscar o codigo de contrato VA da tabela especifica 
@author     A.Shibao
@since      20/09/16
@param		
@version    P12
@return      
@project 
@client    RedeDor   
/*/
//==========================================================================================
User Function fMtaCoVa()

Local cShFil    := cFilAnt
Local cShCont   := ""
Local aShContra := {}
Local aArea     := GetArea()  

fCarrTab( @aShContra,"U108", Nil )
 
If (nPoSu108	:=	Ascan(aShContra,{|x| x[1] == "U108" .And. alltrim(x[2]) == alltrim(mv_par01) })   ) > 0   
	If Empty(aShContra[nPoSu108,5]) 
     	Alert("Nao existe codigo de contrato para VA da filial - "+cFilAnt+" - na tabela especifica U108, favor verificar")
		RestArea(aArea)      	
	    Return
	Else
		cRet:= aShContra[nPoSu108,5]
	Endif
Else
   	Alert("Nao existe registros na tabela na tabela especifica U108, favor verificar")
	RestArea(aArea)      	
    Return
Endif	

RestArea(aArea)       
Return(cRet)

//==========================================================================================
/*/
Monta consulta para buscar o codigo de contrato VR da tabela especifica 
@author     A.Shibao
@since      20/09/16
@param		
@version    P12
@return      
@project 
@client    RedeDor   
/*/
//==========================================================================================
User Function fMtaCoVr()

Local cShFil    := cFilAnt
Local cShCont   := ""
Local aShContra := {}  
Local aArea     := GetArea()

fCarrTab( @aShContra,"U108", Nil )
 
If (nPoSu108	:=	Ascan(aShContra,{|x| x[1] == "U108" .And. alltrim(x[2]) == alltrim(mv_par01) })   ) > 0 
	If Empty(aShContra[nPoSu108,6]) 
     	Alert("Nao existe codigo de contrato para VR da filial - "+alltrim(mv_par01)+" - na tabela especifica U108, favor verificar")
     	RestArea(aArea) 
	    Return
	Else
		cRet:= aShContra[nPoSu108,6]
	Endif
Else
   	Alert("Nao existe registros na tabela na tabela especifica U108, favor verificar")
	RestArea(aArea)      	
    Return	
Endif	  

RestArea(aArea)                                  // Retorna Alias
Return(cRet) 