#INCLUDE "rwmake.ch"       
#INCLUDE "PROTHEUS.CH"    
#INCLUDE "FWADAPTEREAI.CH"
#INCLUDE "XMLXFUN.CH"
#DEFINE CRLF CHR(13)+CHR(10)       
#DEFINE          cSep         "|"
#DEFINE          cEol         CHR(13)+CHR(10)
 
//================================================================================================
/*/
Rotina para geracao do arquivo de compra dos Beneficios da Alelo - VA-VR-VT
@author     A.Shibao
@since      18/08/16
@param		
@version    P12
@return      
@project 
@client    RedeDor   
/*/                                 
// 02/09/16 - A.Shibao - Ajuste tirando o filial de-ate pois sera gerado individualmente  
// 25/09/16 - A.Shibao - Ajuste para buscar o endereco da tabela da localidade ao inves do SM0
// 26/11/17 - A.Shibao - Melhoria na rotina para garantir a nao geração p/filiais que estao na U109
//================================================================================================
User Function DorGeXVT(nArqAPS,cArqAPS,nSequencia)
                                  
//Local oDlg
Local oRadio
Local nRadio
Local nOpca := 1
Local aRet  := {} //416094:Rogerio Carvalho - 18/01/2018 : Melhoria Inclusão de campo Salario
Local aPergs:= {} //416094:Rogerio Carvalho - 18/01/2018 : Melhoria Inclusão de campo Salario

SetPrvt("cArqAPS,dPerRef,cShAnomes,nArqAPS,nSequencia,lContinua,nLin0")
Private    lNotFound := .F.

cArqAPS		:= ''
dPerRef		:= ''
cShAnomes	:= ''
nArqAPS		:= 0
nSequencia	:= 0          
nOpca 		:= 1                                             
lContinua   := .T.   
nLin0       := 0   
cPerg       := "VTALELO"

// Incio 
// 416094:Rogerio Carvalho - 18/01/2018 : Melhoria Inclusão de campo Salario   
mv_par01	:= " "
mv_par02	:= " "
mv_par03	:= " "
mv_par04	:= " "
mv_par05	:= " "
mv_par06	:= " "
mv_par07	:= " "
mv_par08	:= " "
mv_par09	:= " "

aAdd( aPergs ,{1,"Filial : ",space(08),"@!",'.T.','SM0','.T.',08,.F.})
aAdd( aPergs ,{1,"Do  Centro de Custo : ",space(09),"@!",'.T.','CTT','.T.',09,.F.})
aAdd( aPergs ,{1,"Ate Centro de Custo : ",space(09),"@!",'.T.','CTT','.T.',09,.F.})
aAdd( aPergs ,{1,"Da  Matricula : ",space(06),"@!",'.T.','SRA','.T.',06,.F.})
aAdd( aPergs ,{1,"Ate Matricula : ",space(06),"@!",'.T.','SRA','.T.',06,.F.})
aAdd( aPergs ,{1,"Local de Gravacao : ",space(40),"@!",'.T.',,'.T.',40,.F.})
aAdd( aPergs ,{1,"Resp Recebimento  : ",space(45),"@!",'.T.',,'.T.',45,.F.})
aAdd( aPergs ,{1,"Data de Referencia: ",space(10),"@R 99/99/9999",'.T.',,'.T.',35,.F.})
aAdd( aPergs ,{1,"Localidade        : ",space(03),"@!",'.T.','RGC','.T.',03,.F.})

ParamBox(aPergs ,"PARAMETROS",aRet,,,,,,,,.T.,) //ticket n° 2818545 - 08/05/2018 - Paulo Dias - salvando dados
//If !ParamBox(aPergs ,"PARAMETROS",aRet)
   //Return .f.
//EndIf
     
//Valida se foi cancelado a tela de parâmetro.       
If ValType(aRet) <> "A"  .Or. (ValType(aRet) = "A"  .And. Len(aRet) < 9) 
	Return
EndIF
	
 mv_par01 := aRet[1]
 mv_par02 := aRet[2]
 mv_par03 := aRet[3]
 mv_par04 := aRet[4]
 mv_par05 := aRet[5]
 mv_par06 := aRet[6]
 mv_par07 := aRet[7]
 mv_par08 := aRet[8]
 mv_par09 := aRet[9]
 
 // Fim
 // 416094:Rogerio Carvalho - 18/01/2018 : Melhoria Inclusão de campo Salario
 
 //PergVVT() //comentado por 416094:Rogerio Carvalho - 18/01/2018
 
 //Pergunte(cPerg,.T.) //comentado por 416094:Rogerio Carvalho - 18/01/2018
 //dPerRef  := If(Empty(mv_par08),dDataBase,mv_par08) // Periodo de Referencia //comentado por 416094:Rogerio Carvalho - 18/01/2018
    
 //If !Pergunte(cPerg,.T.) //comentado por 416094:Rogerio Carvalho - 18/01/2018
 //     Return() //comentado por 416094:Rogerio Carvalho - 18/01/2018
 //Endif  //comentado por 416094:Rogerio Carvalho - 18/01/2018

dPerRef  := If(Empty(mv_par08),dDataBase,mv_par08) // Periodo de Referencia
   
If Empty(mv_par07)
   MsgStop("O nome do responsável é obrigatório!!!")
   Return
Endif
   
If Empty(mv_par06)
   MsgStop("O Diretorio é obrigatório!!!")
   Return
Endif         
   
Processa({|| fProcArq(@nArqAPS,@cArqAPS,@nLin0)} , "Aguarde a geração do Arquivo...")  

Return(nArqAPS,cArqAPS,nSequencia)            


//==========================================================================================
/*/
Rotina para geracao do arquivo de compra dos Beneficios da Alelo - VA-VR-VT
@author     A.Shibao
@since      18/08/16
@param		
@version    P12
@return      
@project 
@client    RedeDor   
/*/
//==========================================================================================
Static Function fProcArq(nArqAPS,cArqAPS,nSequencia)

Local nPosValTra := 0

Private nSeqArq  := 1
Private aSHValTra:= {} 
                    

//Pergunte(cPerg,.F.)

cFilAte    := mv_par01 								// Ate a Filial
cCcDe      := mv_par02 								// Do Centro de Custo
cCcAte     := mv_par03 								// Ate Centro de Custo
cMatDe     := mv_par04 						   		// Da Matricula
cMatAte    := mv_par05 								// Ate a Matricula
cLocali	   := mv_par09								// Localidade
cDiretorio := Alltrim(mv_par06)+If(Right(Alltrim(mv_par06),1)="\","","\")



SRA->(DbSetOrder(1)) 
SRJ->(DbSetOrder(1)) 
SRN->(DbSetOrder(1)) 
SR0->(DbSetOrder(3)) 

While .T.
     cArqAPS := cDiretorio+Dtos(Date()) + StrZero(nSeqArq,3)+".APS"    
     If File(cArqAPS)
        nSeqArq ++
     Else
        Exit
     Endif
End    

nArqAPS := MsFCreate(cArqAPS)
  
If nArqAPS <  0
    MsgStop("Erro na criação do arquivo!!!")
    Return
Endif     
/*
If mv_par01 <> mv_par02
   Alert("Parametro Filial-De e Filial-Até estão diferentes, favor igualá-los para prosseguir com a geração. ")
   Return
Endif
*/              
// bloqueia a geracao conforme filial da tabela especifica
fCarrTab( @aSHValTra,"U109", Nil,.t.)  

// Verifico se existe a filial informada no parametro existe na tabela especifica, entao bloqueia a geração.		   
If Len(aSHValTra) > 0  .And. ;
       (( nPosValTra := Ascan(aSHValTra,{ |x| alltrim(x[2]) == alltrim(mv_par01) }))  > 0)  

	    MsgStop("A filial solicitada consta na tabela U109 indicando que o pagamento de VT para essa unidade é em espécie. Não será gerado nenhum arquivo, cuja unidade conste da tabela U109")
	    Return			 

Endif                    

nTipo1 := 0
nTipo2 := 0
nTipo3 := 0
nTipo4 := 0
nTipo5 := 0   

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Gravacao do Registro 00 - CABEÇALHO                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ    
SM0->(DbSetOrder(1))
nRecEmpAtu := SM0->(Recno())
SM0->(DbSeek(cEmpAnt+mv_par01))
  
cTexto := "0"                       // Identificador de Registro
cTexto += GravaData(Date(),.F.,5)   // Data do Arquivo (DDMMAAAA)
cTexto += Padr(SM0->M0_CGC,14)      // CNPJ da Empresa Principal
cTexto += Padr(SM0->M0_NOMECOM,50)  // Razão Social
cTexto += Space(157)                // Brancos
cTexto += "04"                      // Versão "04"
cTexto += "00"                      // Release "00"
cTexto += "000001"                  // Sequencial "000001
cTexto += Chr(13)+Chr(10)                   
fWrite(nArqAPS,cTexto)  


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Armazena dados da empresa                                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aDadosEmp  := {}
nSequencia := 2
nSeqEmp    := 1
  
SM0->(DbSeek(cEmpAnt+mv_par01,.T.))
While SM0->(!Eof()).And. SM0->M0_CODIGO == cEmpAnt .And. alltrim(SM0->M0_CODFIL) == mv_par01
  
     cTexto := "1"                          // Identificador do Registro  
     cTexto += Padr(SM0->M0_CGC,14)         // CNPJ
     cTexto += StrZero(nSeqEmp,3)           // Endereço de Entrega - Sequencia
     cTexto += Padr(StrTransf(SM0->M0_ENDENT,",",""),50)      // Logradouro
     cTexto += Space(15)                    // Numero 
     cTexto += Padr(SM0->M0_COMPENT,20)     // Complemento 
     cTexto += Padr(SM0->M0_BAIRENT,35)     // Bairro
     cTexto += Padr(SM0->M0_CEPENT,08,"0")  // CEP 
     cTexto += Padr(SM0->M0_CIDENT,30)      // Cidade 
     cTexto += Padr(SM0->M0_ESTENT,02)      // Estado 
     cTexto += Padr(mv_par07,45)            // Responsavel Pelo Recebimento  
     cTexto += Space(11)                    // Brancos 
     cTexto += StrZero(nSequencia,6)        // Sequencia do Registro
     cTexto += Chr(13)+Chr(10)  
//     fWrite(nArqAPS,cTexto)               // nao imprime pois esta sendo utilizado a tabela RGC abaixo 

     Aadd(aDadosEmp,{SM0->M0_CODFIL,SM0->M0_CGC,StrZero(nSeqEmp,3)})
/*       
     nSequencia ++
     nSeqEmp ++       
     nTipo1 ++    */
     SM0->(DbSkip())       
End

SM0->(DbGoTo(nRecEmpAtu))

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Gravacao do Registro 01 - ENDEREÇOS                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dBSelectArea("RGC")
dbSetOrder(1)
dbGotop()
If RGC->(!DbSeek(mv_par01 + cLocali))                           
	Alert("Não encontrado a localidade para essa filial")
	Return()
Else
     cTexto := "1"                          // Identificador do Registro  
     cTexto += Padr(RGC->RGC_CPFCGC,14)     // CNPJ
     cTexto += right(RGC->RGC_KEYLOCK,3)    // Endereço de Entrega - Sequencia
     cTexto += Padr(StrTransf(RGC->RGC_ENDER,",",""),50)      // Logradouro
     cTexto += Padr(RGC->RGC_NUMERO,15)     // Numero 
     cTexto += Padr(RGC->RGC_COMPLE,20)     // Complemento 
     cTexto += Padr(RGC->RGC_BAIRRO,35)     // Bairro
     cTexto += Padr(RGC->RGC_CODPOS,08,"0") // CEP 
     cTexto += Padr(RGC->RGC_MUNIC,30)      // Cidade 
     cTexto += Padr(RGC->RGC_ESTADO,02)     // Estado 
     cTexto += Padr(RGC->RGC_NMRESP,45)     // Responsavel Pelo Recebimento  
     cTexto += Space(11)                    // Brancos 
     cTexto += StrZero(nSequencia,6)        // Sequencia do Registro
     cTexto += Chr(13)+Chr(10)  
     fWrite(nArqAPS,cTexto)  
     
     nSequencia ++
     nSeqEmp ++       
     nTipo1 ++
Endif
                                                                       
ProcRegua(SRA->(RecCount()))   
     
If SRA->(DbSeek(alltrim(mv_par01)))
	 While SRA->(!Eof()) .And. SRA->RA_FILIAL <= mv_par01
	   
        	IncProc( "Processando matricula - "+ SRA->RA_MAT )
        	
       	 	If SRA->RA_FILIAL < Alltrim(cFilAte) .Or. SRA->RA_FILIAL > Alltrim(cFilAte) .Or. ;
				SRA->RA_MAT < cMatDe .Or. SRA->RA_MAT > cMatAte .Or.  ;
				SRA->RA_CC < cCcDe .Or. SRA->RA_CC > cCcAte 				
				SRA->(dbSkip())	
				Loop
			EndIf	
	        
	        If SRA->RA_SITFOLH == "D"
	        	SRA->(DbSkip())
	        	Loop 
	        Endif
	        
			If SR0->(!DbSeek(SRA->RA_FILIAL + SRA->RA_MAT + "0" )) .Or. SR0->R0_DPROPIN == 99 .Or. SR0->R0_QDIACAL = 0
	        	SRA->(DbSkip())
	        	Loop 
	        Endif    
	        
	        nDiasTrab := SR0->R0_QDIACAL  / SR0->R0_QDIAINF      // caso usuario queria informar a qtde.
	        
	        nPosEmp   := Ascan(aDadosEmp,{|X| alltrim(X[1]) == mv_par01})
	        
	        If nPosEmp == 0 
	        	SRA->(DbSkip()) 
	        	Loop 
	        Endif            
	        
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Gravação do Registro 02 -  USUÁRIOS                                ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ          
	        SRJ->(DbSeek(xFilial("SRJ")+SRA->RA_CODFUNC))
	        
	        cTexto := '2'                             // Identificador de Registro
	        cTexto += Padr(aDadosEmp[nPosEmp,2],14)   // CNPJ    
	        cTexto += right(RGC->RGC_KEYLOCK,3)       //aDadosEmp[nPosEmp,3]            // Endereço de Entrega     
	        cTexto += Strzero(val(SRA->RA_MAT),15)    // Matricula                    
	        cTexto += Padr(SRA->RA_NOME,50)           // Nome Completo                     
	        cTexto += Padr(SRA->RA_CIC,11)            // CPF                    
	        cTexto += Padr(Left(SRA->RA_RG,09),09)    // Numero do RG
	        cTexto += Padr(Right(SRA->RA_RG,02),02)   // Digito do RG                             
	        cTexto += Padr(SRA->RA_RGUF,2)            // Estado Emissao RG
	        cTexto += GravaData(SRA->RA_NASC,.F.,5)   // Data Nasciment (DDMMAAAA)
	        cTexto += Padr(SR0->R0_CC,45,'')          // Departamento // ticket n° 2818545 - 08/05/2018 - Paulo Dias - inclusão de campo
	        cTexto += Padr(SRJ->RJ_DESC,45)           // Cargo
	        cTexto += StrZero(nDiasTrab,3)            // Quantidade de Dias Trabalhados
	        cTexto += padl(alltrim(cvaltochar(transform(SRA->RA_SALARIO,"@E 999999.99"))),9,"0") // SALARIO
	        cTexto += Space(17)                       // Brancos
	        cTexto += StrZero(nSequencia,6)           // Sequencia do Registro
	        cTexto += Chr(13)+Chr(10)  
	        fWrite(nArqAPS,cTexto)        
	        nSequencia ++
	        nTipo2 ++
	
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Gravação do Registro 03 - BENEFICIOS                                ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ         
	        While !SR0->(Eof()) .And. SR0->R0_FILIAL == mv_par01 .And. SR0->R0_MAT == SRA->RA_MAT  .And. SR0->R0_TPVALE =="0" 
	              
	              SRN->(DbSeek(xFilial("SRN")+SR0->R0_CODIGO))
	
	              cTexto := '3' 
	              cTexto += Padr(aDadosEmp[nPosEmp,2],14)     // CNPJ    
	              cTexto += Strzero(val(SRA->RA_MAT),15)      // Matricula 
	              //B=Bilhete Único;C=Cartão Empresa;N=Não se Aplica
	              If SRA->RA_XTIPOVT $ "B/N"                    
		              cTexto += Strzero(SRN->RN_XALELO,6)     // Codigo do Beneficio     
		              cTexto += Padr(SRN->RN_XALEDES,50)      // Descricao do Beneficio
		          Else
		              cTexto += Strzero(SRN->RN_XCODEMP,6)    // Codigo do Beneficio     
		              cTexto += Padr(SRN->RN_XDESEMP,50)      // Descricao do Beneficio		          
		          Endif    
	              cTexto += Strzero(SRN->RN_VUNIATU*100,12)   // Valor do Item
	              cTexto += StrZero(SR0->R0_QDIAINF + SR0->R0_QDNUTIL,3)        // Quantidade (Por Dia)
	              cTexto += Space(25)                         // Numero do Cartão
	              cTexto += Space(108)                        // Brancos
	              cTexto += StrZero(nSequencia,6)             // Seqeuncia do Registro
	              cTexto += Chr(13)+Chr(10)  
	              fWrite(nArqAPS,cTexto)                      
	              nSequencia ++
	              nTipo3++                    
	              SR0->(DbSkip())
	        End
	                               
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³  Gravação do Registro 04 - RESIDENCIA                               ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ         
	        cTexto := '4'                           // Identificador de Registro
	        cTexto += Padr(aDadosEmp[nPosEmp,2],14) // CNPJ    
	        cTexto += Strzero(val(SRA->RA_MAT),15)  // Matricula                    
	        cTexto += Padr(StrTransf(SRA->RA_ENDEREC,",",""),50)      // Logradouro
	        cTexto += Padr(SRA->RA_NUMENDE,15)      // Numero                
	        cTexto += Padr(SRA->RA_COMPLEM,20)      // Complemento           
	        cTexto += Padr(SRA->RA_BAIRRO,35)       // Bairro     
	        cTexto += Padr(SRA->RA_CEP,08)          // Cep
	        cTexto += Padr(SRA->RA_MUNICIP,30)      // Cidade
	        cTexto += Padr(SRA->RA_ESTADO,02)       // Estado
	        cTexto += "S"                           // Solicitar Sugestao de Rota
	        cTexto += StrZero(SR0->R0_VALCAL,12)    // Valor de Vales Transporte para calculo de Reducao
	        cTexto += Space(31)                     // Brancos 
	        cTexto += StrZero(nSequencia,6)         // Seqeuncia do Registro
	        cTexto += Chr(13)+Chr(10)  
	        fWrite(nArqAPS,cTexto)                                                                          
	        nSequencia ++
	        nTipo4 ++
	                
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³  Gravação do Registro 05 - DADOS ADICIONAIS                         ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ       
	        cTexto := '5'                           // Identificador de Registro
	        cTexto += Padr(aDadosEmp[nPosEmp,2],14) // CNPJ    
	        cTexto += Strzero(val(SRA->RA_MAT),15)  // Matricula                    
	        cTexto += Padr(SRA->RA_MAE,50)          // Nome da Mae 
	        cTexto += Space(154)                    // Brancos 
	        cTexto += StrZero(nSequencia,6)         // Seqeuncia do Registro
	        cTexto += Chr(13)+Chr(10)  
	        fWrite(nArqAPS,cTexto)                                                                                 
	        nSequencia ++                  
	        nTipo5 ++
	                                
	   SRA->(DbSkip())
	End   
Else
  lNotFound:= .T.
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³  Gravação do Registro 09 - RODAPE                                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ   
 
cTexto := '9'                       // Identificador de Registro
cTexto += StrZero(nTipo1,6)         // Quantidade Registros Tipo 1
cTexto += StrZero(nTipo2,6)         // Quantidade Registros Tipo 2
cTexto += StrZero(nTipo3,6)         // Quantidade Registros Tipo 3
cTexto += StrZero(nTipo4,6)         // Quantidade Registros Tipo 4
cTexto += StrZero(nTipo5,6)         // Quantidade Registros Tipo 5
cTexto += Space(203)                // Brancos   
cTexto += StrZero(nSequencia,6)     // Seqeuncia do Registro  
cTexto += Chr(13)+Chr(10)  
fWrite(nArqAPS,cTexto)                                                                                  
fClose(nArqAPS)

// Caso nao encontre registros de funcionarios nao gerar nada.
If lNotFound
	nSequencia:= 0
Endif
   
Return(nArqAPS,cArqAPS,nSequencia)  

//==========================================================================================
/*/
Funcao para criacao das perguntas
@author     A.Shibao
@since      18/08/16
@param		
@version    P12
@return      
@project 
@client    RedeDor   
/*/
//==========================================================================================
Static Function PergVVT()

aRegs     := {}

cPerg := Left(cPerg,7)

//X1_GRUPO,X1_ORDEM,X1_PERGUNT,X1_PERSPA,X1_PERENG,X1_VARIAVL,X1_TIPO,X1_TAMANHO,X1_DECIMAL,X1_PRESEL,X1_GSC,X1_VALID,X1_VAR01,X1_DEF01,X1_DEFSPA1,X1_DEFENG1,X1_CNT01,X1_VAR02,X1_DEF02,X1_DEFSPA2,X1_DEFENG2,X1_CNT02,X1_VAR03,X1_DEF03,X1_DEFSPA3,X1_DEFENG3,X1_CNT03,X1_VAR04,X1_DEF04,X1_DEFSPA4,X1_DEFENG4,X1_CNT04,X1_VAR05,X1_DEF05,X1_DEFSPA5,X1_DEFENG5,X1_CNT05,X1_F3,X1_PYME,X1_GRPSXG,X1_HELP  
//aAdd(aRegs,{cPerg,"01","Da Filial          ?","Da Filial          ?","Da Filial          ?","mv_ch1","C",8,0,0 ,"G","","mv_par01" ,"","","","01","","","","","","","","","","","","","","","","","","","","","SM0","","",""})
aAdd(aRegs,{cPerg,"01","Filial             ?","Ate a Filial       ?","Ate a Filial       ?","mv_ch1","C",8,0,0 ,"G","","mv_par01" ,"","","","","","","","","","","","","","","","","","","","","","","","","SM0","","",""})
aAdd(aRegs,{cPerg,"02","Do Centro Custo    ?","Do Centro de Custo ?","Do Centro de Custo ?","mv_ch2","C",9,0,0 ,"G","","mv_par02" ,"","","","000000001","","","","","","","","","","","","","","","","","","","","","CTT","","",""})
aAdd(aRegs,{cPerg,"03","At‚ Centro de Custo?","At‚ Centro de Custo?","At‚ Centro de Custo?","mv_ch3","C",9,0,0 ,"G","","mv_par03" ,"","","","999999999","","","","","","","","","","","","","","","","","","","","","CTT","","",""})
aAdd(aRegs,{cPerg,"04","Da Matricula       ?","Da Matricula       ?","Da Matricula       ?","mv_ch4","C",6,0,0 ,"G","","mv_par04" ,"","","","000001","","","","","","","","","","","","","","","","","","","","","SRA","","",""})
aAdd(aRegs,{cPerg,"05","Ate Matricula      ?","Ate Matricula      ?","Ate Matricula      ?","mv_ch5","C",6,0,0 ,"G","","mv_par05" ,"","","","999999","","","","","","","","","","","","","","","","","","","","","SRA","","",""})
aAdd(aRegs,{cPerg,"06","Local de Gravacao  ?","Local de Gravacao  ?","Local de Gravacao  ?","mv_ch6","C",40,0,0,"G","","mv_par06","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"07","Resp. Recebimento  ?","Resp. Recebimento  ?","Resp. Recebimento  ?","mv_ch7","C",45,0,0,"G","naovazio","mv_par07","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"08","Data de Referencia ?","Data de Referencia ?","Data de Referencia ?","mv_ch8","D",8,0,0,"G","","mv_par08","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"09","Localidade         ?","Localidade         ?","Localidade         ?","mv_ch9","C",3,0,0,"G","","mv_par09","","","","","","","","","","","","","","","","","","","","","","","","","RGC","","",""})

ValidPerg(aRegs,cPerg ,.F.)
        
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

cQuery := " SELECT RA_MAT, RA_CIC, RA_NOME, RA_XSPTRAN, RA_XTIPOVT,  "
cQuery += "  R0_CODIGO, R0_DIASPRO, R0_QDIAINF, R0_QDIACAL, R0_VALCAL, R0_VLRVALE, R0_VLRFUNC, R0_VLREMP   "


cQuery += "  FROM "+ RetSqlName("SRA") + " SRA"
cQuery += "  INNER JOIN "+ RetSqlName("SR0") + " SR0 on R0_FILIAL = RA_FILIAL  AND R0_MAT = RA_MAT "
//cQuery += "  INNER JOIN "+ RetSqlName("SRN") + " SRN on RN_FILIAL = R0_FILIAL  AND RN_COD = R0_CODIGO "

cQuery += "  WHERE "

cQuery += "  RA_FILIAL >= '"  + cFilDe + "'  AND RA_FILIAL <= '" + cFilAte + "' And"
cQuery += "  RA_CC     >= '"  + cCcDe  + "'  AND RA_CC     <= '" + cCcAte  + "' And"
cQuery += "  RA_MAT    >= '"  + cMatDe + "'  AND RA_MAT    <= '" + cMatAte + "' And"

//cQuery += "  RN_TPBEN    = '" + cGvt + "'    And"

cQuery += "  R0_TPVALE   = '0'     And"
cQuery += "  R0_VALCAL   > 0       And"
cQuery += "  R0_DIASPRO  <> '99'   And"

cQuery += "  RA_DEMISSA  = ''      And"

cQuery += "  SRA.D_E_L_E_T_ <> '*' And"
cQuery += "  SR0.D_E_L_E_T_ <> '*' "//And"
//cQuery += "  SRN.D_E_L_E_T_ <> '*' "         

//Verifica Tabela Aberta
If Select("RDOR001") > 0
	DbSelectArea("RDOR001")
	DbCloseArea("RDOR001")
Endif

//TCQuery cQuery New Alias "RDOR001"    
DbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery), "RDOR001", .T., .F.)

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
