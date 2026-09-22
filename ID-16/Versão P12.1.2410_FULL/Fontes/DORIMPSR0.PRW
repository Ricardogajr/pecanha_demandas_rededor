#INCLUDE "PROTHEUS.CH"
#INCLUDE "rwmake.ch"
#include "Fileio.ch"
#include "TOPCONN.ch"
/*/==========================================================================================
/  Rotina para importar  beneficio para tabela SR0 Vale Refeicao / Vale Alimentacao
@author     A.Shibao
@since      29/08/16
@param		
@version    P12                           
@return      
@project 
@client    RedeDor   
/*/
//==========================================================================================  
// Adicionado a opcao de importacao do seguro de vida p/ v12. 22/11/16

User Function DorImpSR0()

Local bProcesso 	:= {|oSelf| fProcessa( oSelf )}  
Local aInfoCustom 	:= {}

Private cCadastro  	:= "IMPORTAÇÃO DE BENEFICIOS "
Private cStartPath 	:= GetSrvProfString("StartPath","")
Private cPerg      	:= "IMPXSR0"
Private cPerg1     	:= "IMPXRI1" 
Private cDescricao  
Private lSai        := .F.

//fPerg()
Pergunte(cPerg,.F.)

cDescricao := "Este programa irá importar de um arquivo texto contendo as  " + Chr(13) + Chr(10)
cDescricao += "informações do beneficio VR/VA/SegVida/Outros Benef    .    " + Chr(13) + Chr(10)
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
Private cTbBenef   := ""
Private cVrbPagt   := ""
Private cVrbDesc   := ""
Private cShPropo   := ""
Private cVrbBase   := ""

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

If MV_PAR01 == 1
   cTipo:= "2"   //VA
Elseif MV_PAR01 == 2
   cTipo:= "1"   // VR	   
Elseif MV_PAR01 == 3
   cTipo:= "3"      
   u_DorShBenef(@cTbBenef,@cVrbPagt,@cVrbDesc,@cVrbBase)
Endif	
                                
If lSai
   Return
Endif
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
	    nPos3 := at(";",subs(cBuffer,nPos2+1))  + nPos2		//CODIGO    / RI1_TABELA
		If cTipo $ "1*2"
			nPos4 := at(";",subs(cBuffer,nPos3+1))  + nPos3	//DIAS UTEIS
			nPos5 := at(";",subs(cBuffer,nPOs4+1))  + nPos4	//DIAS NAO UTEIS
		Endif	
	    
		cLoteTxt  := subs(cBuffer,01,nPos1-1)
		cNumContr := subs(cBuffer,nPos1+1,nPos2-nPos1-1)
		cContrat  := subs(cBuffer,nPos2+1 ,nPos3 -nPos2 -1)
		If cTipo $ "1*2"		
			cTipoUs   := subs(cBuffer,nPos3+1 ,nPos4 -nPos3 -1)
			cNomeUsu  := subs(cBuffer,nPos4 +1,nPos5 -nPos4 -1)
		Endif	
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
	

	   If cTipo $ "1*2"
	   
		  dbSelectArea( "SR0" ) 
		  //R0_FILIAL+R0_MAT+R0_TPVALE+R0_CODIGO	   
		  SR0->(dbSetOrder( 3 )) 	   
		  
		  // verifica se ja existe e regrava
		  If dbSeek( cLoteTxt + cNumContr + cTipo + cContrat )
			          
			          RecLock("SR0",.F.)
					//  R0_FILIAL  		:= Substr(cLoteTxt,2,len(cLoteTxt))
					//  R0_MAT    		:= Substr(cNumContr,2,len(cNumContr))
					//  R0_TPVALE		:= MV_PAR01
					//  R0_CODIGO       := Substr(cContrat,2,len(cContrat))
					  R0_QDIAINF        := Substr(cTipoUs,1,len(cTipoUs))
					  R0_QDNUTIL        := Substr(cNomeUsu,1,len(cNomeUsu))				  				  
					  R0_VLRVALE        := Posicione("RFO",1,xFilial("SRA") + cTipo + cContrat, "RFO_VALOR")
				      MsUnlock()         
				      
		   // grava um novo registro	      
		   Elseif !(dbSeek( cLoteTxt + cNumContr + cTipo + cContrat ) ) 
		   
				      RecLock("SR0",.T.)
					  R0_FILIAL  		:= Substr(cLoteTxt,1,len(cLoteTxt))
					  R0_MAT    		:= Substr(cNumContr,1,len(cNumContr))
					  R0_TPVALE			:= cTipo
					  R0_CODIGO         := Substr(cContrat,1,len(cContrat))
					  R0_QDIAINF        := val(Substr(cTipoUs,1,len(cTipoUs)))
					  R0_QDNUTIL        := val(Substr(cNomeUsu,1,len(cNomeUsu)))                              
					  R0_VLRVALE        := Posicione("RFO",1,xFilial("SRA") + cTipo + cContrat, "RFO_VALOR")				  
				      MsUnlock()		   	      
	
	       EndIf
/*	       
	   Elseif cTipo $ "3"
	   	
		  dbSelectArea( "RI1" ) 
		  //RI1_FILIAL+RI1_MAT+RI1_BENEF+RI1_TABELA
	   	  RI1->(dbSetOrder( 1 ))    
	   
	   	  If dbSeek( cLoteTxt + cNumContr + "82" + cContrat )
			          
			          RecLock("RI1",.F.)
					  
						RI1_COD			:= "001" 
						RI1_BENEF       := "82"
						RI1_TABELA 		:= Substr(cContrat,1,len(cContrat)) 
						RI1_PD1 		:= "648"
						RI1_PROPOR 		:= "2"
						RI1_TPCALC 		:= "1"

 					  MsUnlock()     				             
				      
		   // grava um novo registro	      
		   Elseif !(dbSeek( cLoteTxt + cNumContr + "82" + cContrat ))
		   
				      RecLock("RI1",.T.)
				      
					  	RI1_FILIAL  	:= Substr(cLoteTxt,1,len(cLoteTxt))
					  	RI1_MAT    		:= Substr(cNumContr,1,len(cNumContr))
						RI1_COD			:= "001" 
						RI1_BENEF       := "82"
						RI1_TABELA 		:= Substr(cContrat,1,len(cContrat)) 
						RI1_PD1 		:= "648"
						RI1_PROPOR 		:= "2"
						RI1_TPCALC 		:= "1"				  
						
				      MsUnlock()		   	      
	
	       EndIf
*/	       
	   // VR valor fixo para outros beneficios..
	   Else
   	      //   u_DorShBenef(@cTbBenef,@cVrbPagt,@cVrbDesc,@cShPropo)
		  dbSelectArea( "RI1" ) 
		  //RI1_FILIAL+RI1_MAT+RI1_BENEF+RI1_TABELA
	   	  RI1->(dbSetOrder( 1 ))    
	   
	   	  If dbSeek( cLoteTxt + cNumContr + cTbBenef + cContrat )
			          
			          RecLock("RI1",.F.)
					  
						RI1_COD			:= "001" 
						RI1_BENEF       := cTbBenef
						RI1_TABELA 		:= Substr(cContrat,1,len(cContrat)) 
						//If Empty(cVrbPagt)
						RI1_PD1 		:= cVrbDesc
						//Else
						RI1_PD 		 	:= cVrbPagt
						//Endif
						RI1_PROPOR 		:= cvaltochar(cShPropo)
						RI1_TPCALC 		:= "1"
						RI1_PD2         := cVrbBase

 					  MsUnlock()     				             
				      
		   // grava um novo registro	      
		   Elseif !(dbSeek( cLoteTxt + cNumContr + cTbBenef + cContrat ))
		   
				      RecLock("RI1",.T.)
				      
					  	RI1_FILIAL  	:= Substr(cLoteTxt,1,len(cLoteTxt))
					  	RI1_MAT    		:= Substr(cNumContr,1,len(cNumContr))
						RI1_COD			:= "001" 
						RI1_BENEF       := cTbBenef
						RI1_TABELA 		:= Substr(cContrat,1,len(cContrat)) 
						//If Empty(cVrbPagt)
							RI1_PD1 	:= cVrbDesc
					   	//Else
							RI1_PD	 	:= cVrbPagt
						//Endif
						RI1_PROPOR 		:= cvaltochar(cShPropo)
						RI1_TPCALC 		:= "1"
						RI1_PD2         := cVrbBase										  
						
				      MsUnlock()	   
	       Endif
	       
	   Endif
						
             
		fGeraLog( @aLogDetail, nPosImpOk, cLoteTxt, cNumContr +  " - Registro Importado com Sucesso. " )

		
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
//Static Function fPerg()
//
//Local aRegs := {}
//
//aAdd(aRegs,{cPerg,'01','VA ou VR ou Vida       ?       ','','','mv_ch1','C',01,0,0,'C','           ','mv_par01','VA','VA','VA','','','VR','VR','VR','','','OUTROS BENEF','OUTROS BENEF','OUTROS BENEF','','','','','','','','           ','','','','   ',''})
////aAdd(aRegs,{cPerg,'02','Importar ou Excluir  ?       ','','','mv_ch2','C',01,0,0,'C',''           ,'mv_par02','Importar       ','','','','','Excluir     ','','','','','         ','','','','','            ','','','','','           ','','','','   ',''})
//
//ValidPerg(aRegs,cPerg)
//
//Return


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


 
//==========================================================================================
/*/
Criacao de perguntes para importacao para outros beneficios.
@author     A.Shibao
@since      26/05/17
@param		
@version    P12
@return      
@project 
@client    RedeDor   
/*/                                 
//==========================================================================================
User Function DorShBenef(cTbBenef,cVrbPagt,cVrbDesc,cVrbBase)

PergBenef()

Pergunte(cPerg1,.F.)
   
If !Pergunte(cPerg1,.T.) 
	 lSai:= .T.
     Return
Endif  
   
If Empty(mv_par02) .And. Empty(mv_par03)
   MsgStop("É necessário informar uma verba de pagamento ou verba de desconto!!!")
	 lSai:= .T.   
   Return
Endif
   
If Empty(mv_par01)
   MsgStop("O Tipo de Benefício é obrigatório!!!")
	 lSai:= .T.   
   Return
Endif       

If Empty(mv_par05)
   MsgStop("A verba de base é obrigatório!!!")
	 lSai:= .T.   
   Return
Endif    

cTbBenef:=  mv_par01  
cVrbPagt:=	mv_par02
cVrbDesc:=  mv_par03
cShPropo:=  mv_par04
cVrbBase:=  mv_par05
   
Return(cTbBenef,cVrbPagt,cVrbDesc,cVrbBase)            


//==========================================================================================
/*/
Criacao de perguntes para importacao para outros beneficios.
@author     A.Shibao
@since      26/05/17
@param		
@version    P12
@return      
@project 
@client    RedeDor   
/*/
//==========================================================================================
Static Function PergBenef()

Local i,j    := 0
Local aPergs := {}
Local aRegs  := {}

dbSelectArea("SX1")
dbSetOrder(1)       

cPerg1:= Padr("IMPXRI1",10) 

//X1_GRUPO,X1_ORDEM,X1_PERGUNT,X1_PERSPA,X1_PERENG,X1_VARIAVL,X1_TIPO,X1_TAMANHO,X1_DECIMAL,X1_PRESEL,X1_GSC,X1_VALID,X1_VAR01,X1_DEF01,X1_DEFSPA1,X1_DEFENG1,X1_CNT01,X1_VAR02,X1_DEF02,X1_DEFSPA2,X1_DEFENG2,X1_CNT02,X1_VAR03,X1_DEF03,X1_DEFSPA3,X1_DEFENG3,X1_CNT03,X1_VAR04,X1_DEF04,X1_DEFSPA4,X1_DEFENG4,X1_CNT04,X1_VAR05,X1_DEF05,X1_DEFSPA5,X1_DEFENG5,X1_CNT05,X1_F3,X1_PYME,X1_GRPSXG,X1_HELP  
//aAdd(aRegs,{cPerg,"01","Da Filial          ?","Da Filial          ?","Da Filial          ?","mv_ch1","C",8,0,0 ,"G","","mv_par01" ,"","","","01","","","","","","","","","","","","","","","","","","","","","SM0","","",""})
aAdd(aRegs,{cPerg1,"01","Tipo Benef         ?","Tipo Benef         ?","Tipo Benef         ?","mv_ch1","C",2,0,0 ,"G","naovazio","mv_par01" ,"","","","","","","","","","","","","","","","","","","","","","","","","S11BRA","","",""})
aAdd(aRegs,{cPerg1,"02","Verba Pagamento    ?","Verba Pagamento    ?","Verba Pagamento    ?","mv_ch2","C",3,0,0 ,"G",""        ,"mv_par02" ,"","","","","","","","","","","","","","","","","","","","","","","","","SRV","","",""})
aAdd(aRegs,{cPerg1,"03","Verba Desconto     ?","Verba Desconto     ?","Verba Desconto     ?","mv_ch3","C",3,0,0 ,"G",""        ,"mv_par03" ,"","","","","","","","","","","","","","","","","","","","","","","","","SRV","","",""})
aAdd(aRegs,{cPerg1,"04","Proporcional ?      ","Proporcional ?      ","Proporcional ?      ","mv_ch4","N",1,0,1 ,"C",""        ,"mv_par04" ,"1-Sim","1-Sim","1-Sim","","","2-Nao","2-Nao","2-Nao","","","","","","","","","","","","",""   ,""     ,""     ,""   ,"" ,"S" ,""     ,"",""})
aAdd(aRegs,{cPerg1,"05","Verba Empresa      ?","Verba Empresa      ?","Verba Empresa      ?","mv_ch5","C",3,0,0 ,"G",""        ,"mv_par05" ,"","","","","","","","","","","","","","","","","","","","","","","","","SRV","","",""})

For i := 1 to Len(aRegs)
	If !dbSeek(cPerg1+aRegs[i,2])
		RecLock("SX1",.T.)
		For j:=1 to FCount()
			If j <= Len(aRegs[i])
				FieldPut(j,aRegs[i,j])
			Endif                                                                                              
		Next j
		MsUnlock()
	Endif
Next i

Return 