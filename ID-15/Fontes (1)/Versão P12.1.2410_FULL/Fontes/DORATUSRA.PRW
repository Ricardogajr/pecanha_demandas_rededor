#INCLUDE "PROTHEUS.CH"
#INCLUDE "rwmake.ch"
#include "Fileio.ch"
#include "TOPCONN.ch"
/*/==========================================================================================
/  Rotina para atualizar o campo RA_ASSIST  e RA_MENSIND no cadastro de funcionarios.
@author     A.Shibao
@since      09/11/16
@param		
@version    P12
@return      
@project 
@client    RedeDor   
/*/
//==========================================================================================  
User Function DorAtuSRA()

Local bProcesso 	:= {|oSelf| fProcessa( oSelf )}  
Local aInfoCustom 	:= {}

Private cCadastro  	:= "Atualiza Cadastro SRA  "
Private cStartPath 	:= GetSrvProfString("StartPath","")
Private cPerg      	:= "IMPXSRA"
Private cDescricao

//fPerg()
Pergunte(cPerg,.F.)

cDescricao := "Este programa atualizar os campos RA_ASSIST e RA_MENSIND    " + Chr(13) + Chr(10)
cDescricao += "no cadastro do funcionario conforme arquivo.csv             " + Chr(13) + Chr(10)
cDescricao += "Preencha o Parâmetro. Após confirmar a operação, será aberta" + Chr(13) + Chr(10)
cDescricao += "um tela para escolher o local e o arquivo a ser importado."

tNewProcess():New( "SRA" , cCadastro , bProcesso , cDescricao , cPerg,,,,,.T.,.F. )  

Return

//==========================================================================================
/*/
Rotinas para processamento
@author     A.Shibao
@since      23/08/16
@param		
@version    P12
@return      
@project 
@client    RedeDor   
/*/
//==========================================================================================  
Static Function fProcessa( oSelf )

Local cPath    	:= ""
Local cArquivo 	:= ""
Local nTamFile 	:= 0
Local nTamLin  	:= 0
Local cBuffer  	:= ""
Local nBtLidos 	:= 0
Local lImport  	:= .F.
Local dDtMov   	:= Ctod( "" )
Local cTitulo1  := "Selecione o arquivo"
Local cExtens	:= "Arquivo CSV | *.csv"
Local cFileOpen := ""
Local nContad   := 0  
Local nConta2   := 0
Local cSeqTxt   := ""
Local aLogTitle := {}
Local aLogDetail:= {}      
Local aStru 	:= {}
Local nVTitGrv  := 0
Local nVDepGrv  := 0 
Local cCodCart  := cCodCarAnt := ""   
Local nValor , nValTot := 0

Private nPosImpOk  := 1
Private nPosImpNo  := 2
Private nPosImpDem := 3
Private nPosImpAfa := 4
Private nPosImpSub := 5
Private nPosImpFil := 6
Private nExc       := 0

Aadd(aLogTitle, "Log de Importação da dados faltantes - REGISTROS IMPORTADOS" )
Aadd(aLogDetail,{})
Aadd(aLogTitle, "Log de Importação da dados faltantes  - REGISTROS NAO IMPORTADOS" )
Aadd(aLogDetail,{})
Aadd(aLogTitle, "Log de Importação da dados faltantes  - FUNCIONÁRIOS DEMITIDOS" )
Aadd(aLogDetail,{})
Aadd(aLogTitle, "Log de Importação da dados faltantes  - FUNCIONÁRIOS AFASTADOS" )
Aadd(aLogDetail,{})

//Indexa
cIndCond:= "SRA->RA_FILIAL + SRA->RA_MAT"
cArqNtx  := CriaTrab(Nil,.F.) 

//"Selecionando Registros..."
IndRegua("SRA",cArqNtx,cIndCond,,,"Selecionando Registros...")  

SRA->(dbSetOrder( 1 ))  // Mat

cFileOpen := cGetFile(cExtens,cTitulo1,2,,.T.,GETF_LOCALHARD+GETF_NETWORKDRIVE,.T.)

If !File(cFileOpen)
	MsgAlert("Arquivo texto: "+cFileOpen+" não localizado",cCadastro)
	Return(.F.)
EndIf

//Conta os registros
nRegs := fContaReg(cFileOpen)

oSelf:SetRegua1(nRegs)			//( nTamFile/(nTamLin) )

FT_FUSE(cFileOpen)   			//ABRIR
FT_FGOTOP()          			//PONTO NO TOPO

While !FT_FEOF()  				
	
	nContad++
	
	oSelf:IncRegua1( "Processando Registros -> " + StrZero(nContad,8) + " de " + StrZero(nRegs,8) )
	
	// Capturar dados
	cBuffer := FT_FREADLN() //LENDO LINHA 
	
	//Verifico se fim do txt
	If len(cBuffer)== 0   
			FT_FSKIP()
	Else 
		
	    cBuffer:= cBuffer +";"
		nPos1 := at(";",cBuffer)              				//FILIAL       
		nPos2 := at(";",subs(cBuffer,nPos1+1))  + nPos1		//MATRICULA
		nPos3 := at(";",subs(cBuffer,nPos2+1))  + nPos2		//RA_ASSIST
		nPos4 := at(";",subs(cBuffer,nPos3+1))  + nPos3		//RA_MENSIND
//		nPos5 := at(";",subs(cBuffer,nPOs4+1))  + nPos4		//DIAS NAO UTEIS
//		nPos6 := at(";",subs(cBuffer,nPOs5+1))  + nPos5		//DIAS NAO UTEIS
			
		
		cLoteTxt  := subs(cBuffer,01,nPos1-1)
		cNumContr := subs(cBuffer,nPos1+1,nPos2-nPos1-1)
		cContrat  := subs(cBuffer,nPos2+1 ,nPos3 -nPos2 -1)
		cTipoUs   := subs(cBuffer,nPos3+1 ,nPos4 -nPos3 -1)
//		cNomeUsu  := subs(cBuffer,nPos4 +1,nPos5 -nPos4 -1)
//		cNomeTit  := subs(cBuffer,nPos5 +1,nPos6 -nPos5 -1)
		
   	   // Posiciona o Funcionario
   	   If !(SRA->(dbSeek( cLoteTxt + cNumContr )))
	   		fGeraLog( @aLogDetail, nPosImpNo, cNumContr, "Não Importado - Existe no txt, mas nao existe no sistema")
	   		FT_FSKIP()
	   		LOOP
   	   EndIf 
   	   
	   // Log para Funcionario Demitido
	   If SRA->RA_SITFOLH == "D"
			fGeraLog( @aLogDetail, nPosImpDem, cLoteTxt, cNumContr + " - Registro Não Importado - Funcionário está demitido." )
			FT_FSKIP()
			LOOP
	   EndIf       	   
	
	   
	   If SRA->(dbSeek( cLoteTxt + cNumContr ))
		          
		          RecLock("SRA",.F.)  
		          
				  RA_ASSIST := cContrat
				  RA_MENSIND:= cTipoUs
				  
			      MsUnlock()         
		
				 fGeraLog( @aLogDetail, nPosImpOk, cLoteTxt, cNumContr +  " - Registro Importado com Sucesso. " )			      
       EndIf

		FT_FSKIP()   //proximo registro no arquivo txt
		
	Endif
	
EndDo


FT_FUSE() //fecha o arquivo txt


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Mostra os Logs gerados                                              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
fMakeLog( aLogDetail, aLogTitle, NIL, NIL, FunName(), NIL, NIL, NIL, NIL, .F. )


Return

//==========================================================================================
/*/
Rotinas para gerar o log
@author     A.Shibao
@since      23/08/16
@param		
@version    P12
@return      
@project 
@client    RedeDor   
/*/
//==========================================================================================  
Static Function fGeraLog( aLogDetail, nPos, c_Matric, cOcorrencia )

//Aadd(aLogDetail[nPos],c_Filial + " - " + c_Matric + " - " + cOcorrencia )
Aadd(aLogDetail[nPos], c_Matric + " - " + cOcorrencia )

Return

//==========================================================================================
/*/
Rotinas perguntas do sistema
@author     A.Shibao
@since      23/08/16
@param		
@version    P12
@return      
@project 
@client    RedeDor   
/*/
//==========================================================================================  
Static Function fPerg()

Local aRegs := {}

aAdd(aRegs,{cPerg,'01','Importacao             ?       ','','','mv_ch1','C',0,0,0,'C','           ','mv_par01','             ','','','','','          ','','','','','         ','','','','','            ','','','','','           ','','','','   ',''})
//aAdd(aRegs,{cPerg,'02','Importar ou Excluir  ?       ','','','mv_ch2','C',01,0,0,'C',''           ,'mv_par02','Importar       ','','','','','Excluir     ','','','','','         ','','','','','            ','','','','','           ','','','','   ',''})

//ValidPerg(aRegs,cPerg)

Return


//==========================================================================================
/*/
Rotinas para contas os registros
@author     A.Shibao
@since      23/08/16
@param		
@version    P12
@return      
@project 
@client    RedeDor   
/*/
//==========================================================================================  
Static Function fContaReg(cFileX)

Local nNumX  := 0
Local nCount := 0

FT_FUSE(cFileX)   //ABRIR
FT_FGOTOP()       //PONTO NO TOPO


While !FT_FEOF()  //FACA ENQUANTO NAO FOR FIM DE ARQUIVO
	IncProc("Aguarde, efetuando contagem dos registros ......")
	nCount++
	
	FT_FSKIP()   //proximo registro no arquivo txt
	
EndDo

nNumX := nCount

Return(nNumX)
