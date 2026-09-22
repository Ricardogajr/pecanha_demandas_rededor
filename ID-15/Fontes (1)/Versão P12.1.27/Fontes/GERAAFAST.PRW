/*/

Autor	  : Jorge Paiva 
-----------------------------------------------------------------------------
Data      : 12/01/2011
-----------------------------------------------------------------------------
Descricao : Geração de Arquivos de Afastamentos
-----------------------------------------------------------------------------
Partida   : Menu de Usuario

Descricao : 15/05/17 - A.Shibao
Partida   : Ajuste incluindo filtros para data de admissao de-ate
-----------------------------------------------------------------------------
/*/

#INCLUDE "RWMAKE.CH"
#include "PROTHEUS.CH"
#include "rwmake.ch"
#include "topconn.ch"

**********************
USER Function GERAAFAST()
**********************
  LOCAL CMES := "  "
  LOCAL CANO := "  "
  
       
  cPerg := Padr("GERAAFAST",10,"")
  aSx1  := {}
  Aadd(aSx1,{"GRUPO","ORDEM","PERGUNT"                       ,"VARIAVL","TIPO","TAMANHO","DECIMAL","GSC","VALID" ,"VAR01"   ,"F3","DEF01" ,"DEF02" ,"DEF03","DEF04","DEF05","HELP"})
  Aadd(aSx1,{cPerg  ,"01"   ,"Local p/ Gravação............?","mv_ch1" ,"C"   ,30       ,0        ,"G"  ,""                 ,"mv_par01",""    ,""      ,""      ,""     ,""     ,""     ,""    })
  Aadd(aSx1,{cPerg  ,"02"   ,"Filiais  ....................?","mv_ch2" ,"C"   ,99       ,0        ,"G"  ,"u_xFilOpc1(mv_par02)","mv_par02",""    ,""      ,""      ,""       ,""       ,""        ,".RHFILDE." })
  Aadd(aSx1,{cPerg  ,"03"   ,"Centro de Custo De...........?","mv_ch3" ,"C"   ,09       ,0        ,"G"  ,""           		,"mv_par03","CTC" ,""      ,""      ,""       ,""       ,""        ,".RHCCD."   })
  Aadd(aSx1,{cPerg  ,"04"   ,"Centro de Custo Ate..........?","mv_ch4" ,"C"   ,09       ,0        ,"G"  ,"NaoVazio"   		,"mv_par04","CTC" ,""      ,""      ,""       ,""       ,""        ,".RHCCAT."  })
  Aadd(aSx1,{cPerg  ,"05"   ,"Matricula De.................?","mv_ch5" ,"C"   ,06       ,0        ,"G"  ,""           		,"mv_par05","SRA" ,""      ,""      ,""       ,""       ,""        ,".RHMATD."  })
  Aadd(aSx1,{cPerg  ,"06"   ,"Matricula Ate................?","mv_ch6" ,"C"   ,06       ,0        ,"G"  ,"NaoVazio"   		,"mv_par06","SRA" ,""      ,""      ,""       ,""       ,""        ,".RHMATA."  })
  Aadd(aSx1,{cPerg  ,"07"   ,"Situacaoes...................?","mv_ch7" ,"C"   ,05       ,0        ,"G"  ,"fSituacao"  		,"mv_par07",""    ,""      ,""      ,""       ,""       ,""        ,".RHSITUA." })
  Aadd(aSx1,{cPerg  ,"08"   ,"Categoria....................?","mv_ch8" ,"C"   ,15       ,0        ,"G"  ,"fCategoria" 		,"mv_par08",""    ,""      ,""      ,""       ,""       ,""        ,".RHCATEG." })    
  Aadd(aSx1,{cPerg  ,"09"   ,"Data Admissao De.............?","mv_ch9" ,"D"   ,08       ,0        ,"G"  ,""           		,"mv_par09",""    ,""      ,""      ,""       ,""       ,""        ,""          })   
  Aadd(aSx1,{cPerg  ,"10"   ,"Data Admissao Ate............?","mv_cha" ,"D"   ,08       ,0        ,"G"  ,""           		,"mv_par10",""    ,""      ,""      ,""       ,""       ,""        ,""          })   
  Aadd(aSx1,{cPerg  ,"11"   ,"Data Demissao De.............?","mv_chb" ,"D"   ,08       ,0        ,"G"  ,""           		,"mv_par11",""    ,""      ,""      ,""       ,""       ,""        ,""          })   
  Aadd(aSx1,{cPerg  ,"12"   ,"Data Demissao Ate............?","mv_chc" ,"D"   ,08       ,0        ,"G"  ,""           		,"mv_par12",""    ,""      ,""      ,""       ,""       ,""        ,""          })     

    
  //fCriaSx1() Thais Paiva - Compatibilização P27
    
  If !Pergunte(cPerg,.T.)
     Return
  Endif   
                           
  cPath := Alltrim(mv_par01) 
  cPath := If(Right(cPath,1) == "\",cPath,cPath+"\")
  
  If ! ":" $ cPath
     MsgStop("Caminho Inválido !!!")
     Return
  Endif  
  
   
  
  Processa({|| fBeneficiario()  , "Aguarde a geracão do Arquivo de Afastamentos...  [Proc 1/2]"})
  

Return                 

********************************
Static Function fBeneficiarios()
********************************
   
   nArqTxt := MsFCreate(UPPER(cPath+"AFASTAMENTO.CSV"))
  
   If nArqTxt == -1
      MsgStop("Erro na criação do arquivo "+Alltrim(mv_par01)+" : " + Alltrim(Str(fError())))
      Return
   EndIF

   ProcRegua(SRA->(RecCount()))
   
   SRA->(DbSetOrder(1)) ;  SRA->(DbGoTop())
   SR8->(DbSetOrder(1)) 
   
   cDetArq := "Filial"				 	    +";"    
   cDetArq += "C.Custo"                     +";" 
   cDetArq += "Descricao Custo"                     +";"    
   cDetArq += "Matricula"                   +";"
   cDetArq += "Nome Funcionario"                                                                    +";"
   cDetArq += "Tipo de Afastamento"                                                                 +";"
   cDetArq += "Data Inicio"                                                                     +";"   
   cDetArq += "Data Fim"                                                                    +";"                                              
   
   
   
  
   
   
  	fWrite(nArqTxt,cDetArq+Chr(13)+Chr(10))                                                  
   
   While SRA->(!Eof())
    
         IncProc(SRA->RA_NOME)                                         
	     cMat := SRA->RA_MAT
	     
	     If SRA->RA_SITFOLH = "D"
            SRA->(DbSkip()) ; Loop
         Endif
         
         If SRA->RA_CATFUNC $ "A-E"
            SRA->(DbSkip()) ; Loop
         Endif	                       
	     
         

         //Busca Dependentes 
         SR8->(DbSeek(SRA->RA_FILIAL+SRA->RA_MAT))
         While SR8->(!Eof()) .And. SR8->R8_FILIAL == SRA->RA_FILIAL .And. SR8->R8_MAT == SRA->RA_MAT

               If EMPTY(SR8->R8_TIPO)
                  SR8->(DbSkip());loop
               ENDIF
               
               cDetArq := "'"+PadR(SRA->RA_FILIAL   ,02,"")    										    +";"
               cDetArq += "'"+PadR(SRA->RA_CC     ,15,"")    										    +";"    
               cDetArq += PadR(POSICIONE("CTT",1,XFILIAL("CTT")+SRA->RA_CC,"CTT_DESC01"),30,"")         +";"    
		       cDetArq += "'"+PadR(cMat,06,"")  													    +";"                                    //0003 a 0008 - Matricula
  	           cDetArq += PadR(SRA->RA_NOME,30,"")													    +";"                          //0043 a 0066 - Nome Beneficiario   
  	           cDetArq += PadR(POSICIONE("SX5",1,XFILIAL("SX5")+"30"+SR8->R8_TIPO,"X5_DESCRI"),30,"")+";"                              //0125 a 0125 - Sexo
  	           cDetArq += fGravaData(SR8->R8_DATAINI)  													+";"                          //0080 a 0089 - Data de Nascimento
  	           if !empty(SR8->R8_DATAFIM)
  	              cDetArq += fGravaData(SR8->R8_DATAFIM)  													+";"                          //0080 a 0089 - Data de Nascimento
  	           ELSE
  	              cDetArq += ""                													+";"                          //0080 a 0089 - Data de Nascimento
               ENDIF
	           
  	           

               fWrite(nArqTxt,cDetArq+Chr(13)+Chr(10))               
               SR8->(DbSkip())
         End    
         
         SRA->(DbSkip())         
   End

  
           



   FClose(nArqTxt)

Return             

*********************************
Static Function fGravaData(dData)
*********************************

  cData := GravaData(dData,.F.,5)
  cRet  := Subs(cData,1,2)+"/"+Subs(cData,3,2)+"/"+Subs(cData,5,4)
Return(cRet)

/*Início - Thais Paiva - Compatibilização P27
**************************
Static Function fCriaSx1()
**************************
 
 SX1->(DbSetOrder(1))

 If SX1->(!DbSeek(cPerg+aSx1[Len(aSx1),2]))
	SX1->(DbSeek(cPerg))
	While SX1->(!Eof()) .And. Alltrim(SX1->X1_GRUPO) == Alltrim(cPerg)
		  SX1->(Reclock("SX1",.F.,.F.))
		  SX1->(DbDelete())
		  SX1->(MsunLock())
		  SX1->(DbSkip())
	End
	For X1:=2 To Len(aSX1)
		SX1->(RecLock("SX1",.T.))
		For Z:=1 To Len(aSX1[1])
		    cCampo := "X1_"+aSX1[1,Z]
			SX1->(FieldPut(FieldPos(cCampo),aSx1[X1,Z]))
		Next
		SX1->(MsunLock())
	Next
 Endif

Fim - Thais Paiva - Compatibilização P27*/

**************************
User Function xFilOpc2()
**************************
Local MvPar
Local MvParDef := ""
Local aItens   := {}
Local aArea    := GetArea()

MvPar := &(Alltrim(ReadVar()))       // Carrega Nome da Variavel do Get em Questao
MvRet := Alltrim(ReadVar())          // Iguala Nome da Variavel ao Nome variavel de Retorno

dbSelectArea("SM0")
dbSetOrder(RetOrder("SM0","SM0_CODIGO+ SM0_CODFIL +SM0_FILIAL"))
While !Eof() .And. SM0->M0_CODIGO == cEmpAnt
	
		aAdd(aItens, SM0->M0_FILIAL )
		MvParDef += alltrim(SM0->M0_CODFIL)
		
	("SM0")->(dbSkip())
End

//         Retorno,Titulo   ,opcoes ,Strin Ret,lin,col, Tipo Sel,tam chave , n. ele ret, Botao
IF f_Opcoes(@MvPar, "Opcoes", aItens, MvParDef, 12, 49, .F., 8)  // "Opções"
	&MvRet := MvPar                                      // Devolve Resultado
EndIF

cShFiliais:= MvPar

RestArea(aArea)                                  // Retorna Alias
Return MvParDef
