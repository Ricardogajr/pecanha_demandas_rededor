/*/

Autor	  : Jorge Paiva                                
-----------------------------------------------------------------------------
Data      : 12/01/2011
-----------------------------------------------------------------------------
Descricao : Geração de Arquivos de Dependentes
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
USER Function GERADEP()
**********************
  LOCAL CMES := "  "
  LOCAL CANO := "  "
  Private cShFiliais   := ""   
  Private   cPerg := Padr("GERADEP",10)
       
  ValidPerg(cPerg)
  If !Pergunte(cPerg,.T.)
		Return
  EndIf   
                           
  cPath := Alltrim(mv_par01) 
  cPath := If(Right(cPath,1) == "\",cPath,cPath+"\")
  
 If ! ":" $ cPath
  MsgStop("Caminho Inválido !!!")
  Return
  Endif  
  
  
  Processa({|| fBeneficiario()  , "Aguarde a geracão do Arquivo de Dependentes...  [Proc 1/2]"})
  

Return                 

********************************
Static Function fBeneficiarios()
********************************

   Local _cQuery := ""
   Local cShDtD  := ""
   Local cShDtAt := ""
   Local cShDemD := ""	
   Local cShDemA := ""
   
   nArqTxt := MsFCreate(UPPER(cPath+"DEPENDENTE.CSV"))
  
   If nArqTxt == -1
      MsgStop("Erro na criação do arquivo "+Alltrim(mv_par01)+" : " + Alltrim(Str(fError())))
      Return
   EndIf
   
   //-Ajusta o conteudo da cTiposSel pra usar na Query Filial
   cQryAux := ""
   cTiposSel := Alltrim(cShFiliais)
   For nTp := 1 to Len(cShFiliais) Step 8
   		cQryAux += "'"+SubStr(cShFiliais, nTp, 8)+"'"
		If (nTp + 8) < Len(cShFiliais)
			cQryAux += ","
		EndIf
   Next nTp       
   
   cQryAux:= Iif(Empty(cQryAux),'',cQryAux)
   
   If Empty(cQryAux)
	   Alert("Filiais não selecionadas, verificar !!")
	   Return
   Else
		cQryAux:= cQryAux
   Endif
	
	//-Ajusta o conteudo da cTiposSel pra usar na Query Situacao
   
   /*ticket 3109787 [AMS] - Paulo Dias - 29/06/2018 - bloco comentado
   cQryAux1 := ""
   cTiposSel := Alltrim(mv_par07)
   For nTp := 1 to Len(mv_par07) Step 1
		cQryAux1 += "'"+SubStr(mv_par07, nTp, 1)+"'"
		If (nTp + 1) < Len(mv_par07)
			cQryAux1 += ","
		EndIf
   Next nTp
	
	//-Ajusta o conteudo da cTiposSel pra usar na Query Categoria
   cQryAux2 := ""
   cTiposSel := Alltrim(mv_par08)
   For nTp := 1 to Len(cTiposSel) Step 1
		cQryAux2 += "'"+SubStr(mv_par08, nTp, 1)+"'"
		If (nTp + 1) < Len(mv_par08)
			cQryAux2 += ","
		EndIf
   Next nTp
   Fim - Paulo Dias*/
   
    cQryAux1 := ""
    cQryAux2 := ""
   	cShDtD := dtos(mv_par09) 
	cShDtAt:= dtos(mv_par10) 
	cShDemD:= dtos(mv_par11) 
	cShDemA:= dtos(mv_par12) 
   
   	_cQuery  := "SELECT RA_FILIAL, RA_MAT, RA_NOME, RA_CC, RA_SITFOLH, RA_CATFUNC, RA_ADMISSA, RA_DEMISSA,
   	_cQuery  += " RB_NOME, RB_COD, RB_MAT, RB_DTNASC, RB_SEXO, RB_GRAUPAR   FROM " + RetSqlName("SRA") + " SRA "
	_cQuery  += " INNER JOIN  " + RetSqlName("SRB") + " SRB "
	_cQuery  += " ON RB_FILIAL = RA_FILIAL AND RB_MAT = RA_MAT " 
	_cQuery  += " WHERE RA_FILIAL IN (" + cQryAux + ") "
	_cQuery  += " AND RA_MAT     >= '" + mv_par05 +"' AND RA_MAT     <= '" + mv_par06 + "' "
	_cQuery  += " AND RA_CC      >= '" + mv_par03 +"' AND RA_CC      <= '" + mv_par04 + "' "
	//_cQuery  += " AND RA_SITFOLH IN (" + cQryAux1 +") " //ticket 3109787 [AMS] - Paulo Dias - 29/06/2018 - linha comentada
	//_cQuery  += " AND RA_CATFUNC IN (" + cQryAux2 +") " //ticket 3109787 [AMS] - Paulo Dias - 29/06/2018 - linha comentada
	_cQuery  += " AND RA_ADMISSA >= '" + cShDtD +"' AND RA_ADMISSA <= '" + cShDtAt + "' "
	_cQuery  += " AND RA_DEMISSA >= '" + cShDemD +"' AND RA_DEMISSA <= '" + cShDemA + "' "	
	_cQuery  += " AND SRA.D_E_L_E_T_ = ' ' 
	_cQuery  += "  AND SRB.D_E_L_E_T_ = ' ' 	
	
	_cQuery  += " ORDER BY SRA.RA_FILIAL,SRA.RA_MAT "   

	If Select("TSRB") > 0
		TSRB->(DbCloseArea())
	EndIf
	
	TCQUERY _cQuery NEW ALIAS "TSRB"
	
	TSRB->( dbGoTop() )
   

   ProcRegua(TSRB->(RecCount()))
   
   cDetArq := "Filial"				 	    +";"    
   cDetArq += "C.Custo"                     +";"    
   cDetArq += "Descricao"		            +";"    
   cDetArq += "Matricula"                   +";"
   cDetArq += "Nome Funcionario"            +";"
   cDetArq += "Sequencia"                   +";"
   cDetArq += "Nome Dependente"             +";"
   cDetArq += "Data Nasc"                   +";"                                              
   cDetArq += "Sexo"                        +";"                                              
   cDetArq += "Grau de Parentesco"          +";"
//   cDetArq += "CPF"                       +";"

   fWrite(nArqTxt,cDetArq+Chr(13)+Chr(10))                                                  
   
   Do While TSRB->(!Eof())                 
   
	  IncProc("Emp.: " + cEmpAnt + "  Fil.: " + TSRB->RB_MAT + "  Func.: " + LEFT(TSRB->RB_NOME,30))
         

                cDetArq := "'"+PadR(TSRB->RA_FILIAL   ,08,"")    										+";"
                cDetArq += "'"+PadR(TSRB->RA_CC     ,15,"")    										    +";"    
                cDetArq += PadR(POSICIONE("CTT",1,XFILIAL("CTT")+TSRB->RA_CC,"CTT_DESC01"),30,"")       +";"    
	            cDetArq += "'"+PadR(TSRB->RB_MAT,06,"")  												+";"
  	            cDetArq += PadR(TSRB->RA_NOME,24,"")												    +";"
  	            cDetArq += "'"+Padr(TSRB->RB_COD,02,"") 												+";"
  	            cDetArq += PadR(TSRB->RB_NOME,24,"")  													+";"
				cShDt   := (TSRB->RB_DTNASC)
           		cShDt   :=	substr(cShDt,7,2)+"/"+substr(cShDt,5,2)+"/"+substr(cShDt,1,4)  	            
  	            cDetArq += cShDt  			   										     	            +";"
  	            cDetArq += PadR(IF(TSRB->RB_SEXO='F','FEMININO','MASCULINO'),10,"")                     +";"
  	            
  	            cGrau := ""
  	            If TSRB->RB_GRAUPAR = "F"
  	                cGrau := "Filho"
  	            Elseif TSRB->RB_GRAUPAR = "C" 
  	                   cGrau := "Conjugue" 
  	            Elseif TSRB->RB_GRAUPAR = "E" 
  	                   cGrau := "Enteado" 
  	            Elseif TSRB->RB_GRAUPAR = "O" 
  	                   cGrau := "Outros"     
  	            Elseif TSRB->RB_GRAUPAR = "P" 
  	                   cGrau := "Pai/Mae"       
  	            Endif                    
  	               
  	            cDetArq += PadR(cGrau,20,"") 															+";"
  //            cDetArq += PadR(TSRB->RB_CIC,11,"")  													+";"
  	           
               fWrite(nArqTxt,cDetArq+Chr(13)+Chr(10))               
        
         TSRB->(DbSkip())         
   End

   FClose(nArqTxt)

Return             

*********************************
Static Function fGravaData(dData)
*********************************

  cData := GravaData(dData,.F.,5)
  cRet  := Subs(cData,1,2)+"/"+Subs(cData,3,2)+"/"+Subs(cData,5,4)
Return(cRet)

**************************
Static Function ValidPerg()
************************** 

Local i,j    := 0
Local aSx1   := {}
Local aRegs  := {}

dbSelectArea("SX1")
dbSetOrder(1)       

cPerg:= Padr("GERADEP",10)

  Aadd(aSx1,{cPerg  ,"01"   ,"Nome do Arquivo .............?","Nome do Arquivo .............?","Nome do Arquivo .............?","mv_ch0" ,"C"   ,30       ,0        ,0	   ,"G"  ,"NaoVazio"   		   ,"mv_par01",""   ,""     ,""     ,""   ,""   ,""   ,""     ,""     ,""   ,""   ,""     ,""     ,""     ,""   ,""   ,""   ,""     ,""     ,""   ,""   ,""   ,""     ,""     ,""   ,""   ,"S" ,""     ,"",""})
  Aadd(aSx1,{cPerg  ,"02"   ,"Filiais  ....................?","Filiais  ....................?","Filiais  ....................?","mv_ch0" ,"C"   ,99       ,0        ,0	   ,"G"  ,"u_xFilOpc1(mv_par02)","mv_par02",""   ,""     ,""     ,""   ,""   ,""   ,""     ,""     ,""   ,""   ,""     ,""     ,""     ,""   ,""   ,""   ,""     ,""     ,""   ,""   ,""   ,""     ,""     ,""   ,""   ,"S" ,""     ,"",""})
  Aadd(aSx1,{cPerg  ,"03"   ,"Centro de Custo De...........?","Centro de Custo De...........?","Centro de Custo De...........?","mv_ch0" ,"C"   ,11       ,0        ,0	   ,"G"  ,""                   ,"mv_par03",""   ,""     ,""     ,""   ,""   ,""   ,""     ,""     ,""   ,""   ,""     ,""     ,""     ,""   ,""   ,""   ,""     ,""     ,""   ,""   ,""   ,""     ,""     ,""   ,"CTT","S" ,""     ,"",""})
  Aadd(aSx1,{cPerg  ,"04"   ,"Centro de Custo Ate..........?","Centro de Custo Ate..........?","Centro de Custo Ate..........?","mv_ch0" ,"C"   ,11       ,0        ,0     ,"G"  ,"NaoVazio"           ,"mv_par04",""   ,""     ,""     ,""   ,""   ,""   ,""     ,""     ,""   ,""   ,""     ,""     ,""     ,""   ,""   ,""   ,""     ,""     ,""   ,""   ,""   ,""     ,""     ,""   ,"CTT","S" ,""     ,"",""})
  Aadd(aSx1,{cPerg  ,"05"   ,"Matricula De.................?","Matricula De.................?","Matricula De.................?","mv_ch0" ,"C"   ,06       ,0        ,0     ,"G"  ,""                   ,"mv_par05",""   ,""     ,""     ,""   ,""   ,""   ,""     ,""     ,""   ,""   ,""     ,""     ,""     ,""   ,""   ,""   ,""     ,""     ,""   ,""   ,""   ,""     ,""     ,""   ,"SRA","S" ,""     ,"",""})
  Aadd(aSx1,{cPerg  ,"06"   ,"Matricula Ate................?","Matricula Ate................?","Matricula Ate................?","mv_ch0" ,"C"   ,06       ,0        ,0     ,"G"  ,"NaoVazio"           ,"mv_par06",""   ,""     ,""     ,""   ,""   ,""   ,""     ,""     ,""   ,""   ,""     ,""     ,""     ,""   ,""   ,""   ,""     ,""     ,""   ,""   ,""   ,""     ,""     ,""   ,"SRA","S" ,""     ,"",""})
  Aadd(aSx1,{cPerg  ,"07"   ,"Situacaoes...................?","Situacaoes...................?","Situacaoes...................?","mv_ch0" ,"C"   ,05       ,0        ,0     ,"G"  ,"fSituacao"          ,"mv_par07",""   ,""     ,""     ,""   ,""   ,""   ,""     ,""     ,""   ,""   ,""     ,""     ,""     ,""   ,""   ,""   ,""     ,""     ,""   ,""   ,""   ,""     ,""     ,""   ,""   ,"S" ,""     ,"",""})
  Aadd(aSx1,{cPerg  ,"08"   ,"Categoria....................?","Categoria....................?","Categoria....................?","mv_ch0" ,"C"   ,15       ,0        ,0     ,"G"  ,"fCategoria"         ,"mv_par08",""   ,""     ,""     ,""   ,""   ,""   ,""     ,""     ,""   ,""   ,""     ,""     ,""     ,""   ,""   ,""   ,""     ,""     ,""   ,""   ,""   ,""     ,""     ,""   ,""   ,"S" ,""     ,"",""})
  Aadd(aSx1,{cPerg  ,"09"   ,"Data Admissao De.............?","Data Admissao De.............?","Data Admissao De.............?","mv_ch0" ,"D"   ,08       ,0        ,0     ,"G"  ,""                   ,"mv_par09",""   ,""     ,""     ,""   ,""   ,""   ,""     ,""     ,""   ,""   ,""     ,""     ,""     ,""   ,""   ,""   ,""     ,""     ,""   ,""   ,""   ,""     ,""     ,""   ,""   ,"S" ,""     ,"",""})
  Aadd(aSx1,{cPerg  ,"10"   ,"Data Admissao Ate............?","Data Admissao Ate............?","Data Admissao Ate............?","mv_ch0" ,"D"   ,08       ,0        ,0     ,"G"  ,""                   ,"mv_par10",""   ,""     ,""     ,""   ,""   ,""   ,""     ,""     ,""   ,""   ,""     ,""     ,""     ,""   ,""   ,""   ,""     ,""     ,""   ,""   ,""   ,""     ,""     ,""   ,""   ,"S" ,""     ,"",""})
  Aadd(aSx1,{cPerg  ,"11"   ,"Data Demissao De.............?","Data Demissao De.............?","Data Demissao De.............?","mv_ch0" ,"D"   ,08       ,0        ,0     ,"G"  ,""                   ,"mv_par11",""   ,""     ,""     ,""   ,""   ,""   ,""     ,""     ,""   ,""   ,""     ,""     ,""     ,""   ,""   ,""   ,""     ,""     ,""   ,""   ,""   ,""     ,""     ,""   ,""   ,"S" ,""     ,"",""})
  Aadd(aSx1,{cPerg  ,"12"   ,"Data Demissao Ate............?","Data Demissao Ate............?","Data Demissao Ate............?","mv_ch0" ,"D"   ,08       ,0        ,0     ,"G"  ,""                   ,"mv_par12",""   ,""     ,""     ,""   ,""   ,""   ,""     ,""     ,""   ,""   ,""     ,""     ,""     ,""   ,""   ,""   ,""     ,""     ,""   ,""   ,""   ,""     ,""     ,""   ,""   ,"S" ,""     ,"",""})
  
  For i := 1 to Len(aSx1)
		If !dbSeek(cPerg+aSx1[i,2])
			RecLock("SX1",.T.)
			For j:=1 to FCount()
				If j <= Len(aSx1[i])
					FieldPut(j,aSx1[i,j])
				Endif                                                                                             
			Next j
			MsUnlock()
		Endif
  Next i

Return .t.  

**************************
User Function xFilOpc1()
**************************

Local MvPar
Local MvParDef := ""
Local aItens   := {}
Local aArea    := GetArea()

MvPar := &(Alltrim(ReadVar()))       // Carrega Nome da Variavel do Get em Questao
MvRet := Alltrim(ReadVar())          // Iguala Nome da Variavel ao Nome variavel de Retorno

dbSelectArea("SM0")
//dbSetOrder(RetOrder("SM0","SM0_CODIGO+ SM0_CODFIL +SM0_FILIAL"))
dBGotop()
While !Eof() .And. SM0->M0_CODIGO == cEmpAnt
	
		aAdd(aItens, SM0->M0_FILIAL )
		MvParDef += alltrim(SM0->M0_CODFIL)
		
	("SM0")->(dbSkip())
End

//		    Retorno	    ,Titulo  ,  opcoes     , Strin Ret   ,lin  ,col  , Tipo Sel  ,tam chave , n. ele ret, Botao 
IF f_Opcoes  (@MvParDef, "Opcoes", aItens     , MvParDef     ,12   , 49 , .F.        ,  8       ,   999    , .T.  )  // "Opções"
	&MvRet := MvPar                                      // Devolve Resultado
EndIF

cShFiliais:= MvParDef

RestArea(aArea)                                  // Retorna Alias
Return MvParDef

