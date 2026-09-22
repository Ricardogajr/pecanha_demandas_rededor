/*/

Autor	  : Jorge Paiva                                     
-----------------------------------------------------------------------------
Data      : 17/12/2007
-----------------------------------------------------------------------------
Descricao : Geração de Arquivo Generica
-----------------------------------------------------------------------------                                    	
Partida   : Menu de Usuario

Descricao : 15/05/17 - A.Shibao
Partida   : Ajuste incluindo filtros para data de admissao de-ate
Partida   : Ajuste incluindo filtros para gerar somente para filial que tem acesso
Partida   : Ajuste incluindo a abertura do excel ao termino do relatorio
Partida   : Ajuste para retonar as filiais de acesso conforme o grupo de usuarios
-----------------------------------------------------------------------------
/*/

#INCLUDE "RWMAKE.CH"
#include "PROTHEUS.CH"
#include "rwmake.ch"
#include "topconn.ch"


***********************
USER Function GERASRA()
***********************   

  Private aFieldSRA    := {}  
  Private aXFie_SRA    := {}
  Private iFirst       := .T. 
  Private cEmpresa     := ''  
  Private cShFiliais   := ""
  Private   cPerg 	   := Padr("GERASRA",10)
  Private _aDadosCom   := {}
  Private _cTabCom	   := ""     
  Private _aTitCom     := ""
  Private _aDados      := {}
  Private _aTit		   := {}
  Private  cPath	   := ""
  

 //Verifica se existe o excel
 If !ApOleClient("MSExcel")
 	   MsgAlert("Microsoft Excel não instalado!")
 	   Return
 EndIf 

  ValidPerg(cPerg)
  If !Pergunte(cPerg,.T.)
		Return
  EndIf 
                                               
  cPath := Alltrim(mv_par01) 
  //cPath := If(Right(cPath,1) == "\",cPath,cPath+"\")
  
  If ! ":" $ cPath
     MsgStop("Caminho Inválido !!!")
     Return
  Endif


  Processa({|| fBene()  , "Aguarde a geracão do Arquivo de Beneficiários...  [Proc 1/2]"})
  

Return                 

********************************
Static Function fBene()
********************************     

Local cRaca     := ""
Local _cQuery   := ""
Local lDemitidos:= .F.
Local lTransfer := .F.
Local cTime 	:= "FUNCIONARIO.CSV" // alltrim(StrTran(TIME(),":",""))   
Local cxLocArq  := UPPER(cPath+Alltrim(cTime))
Local cQryAuxN  := '0'
Local cQryAuxA  := '0'
Local cQryAuxF  := '0' 
Local cQryAuxD  := '0'
Local cQryAuxT  := '0'
Local _aCmpRA	:= {} //Thais Paiva - Compatibilização P27
 
nArqTxt := MsFCreate(cxLocArq) 
  
If nArqTxt == -1
      MsgStop("Erro na criação do arquivo "+Alltrim(mv_par01)+" : " + Alltrim(Str(fError())))
      Return
EndIF     
   
//-Ajusta o conteudo da cTiposSel pra usar na Query Filial
cQryAux := ""
cTiposSel := Alltrim(cShFiliais)

For nTp := 1 to Len(cShFiliais) Step 8
	cQryAux += "'"+SubStr(cShFiliais, nTp, 8)+"'"
	If (nTp + 8) <= Len(cShFiliais)
		cQryAux += ","
	EndIf
Next nTp 

If Empty(cQryAux)
   Alert("Filiais não selecionadas, verificar !!")
   Return
Else
	cQryAux:= cQryAux
Endif

//-Ajusta o conteudo da cTiposSel pra usar na Query Situacao
cQryAux1 := ""
cTiposSel := Alltrim(mv_par07)
For nTp := 1 to Len(mv_par07) Step 1
	cQryAux1 += "'"+SubStr(mv_par07, nTp, 1)+"'"
	If (nTp + 1) <= Len(mv_par07)
		cQryAux1 += ","
	EndIf
Next nTp

If " " $ cQryAux1
	cQryAuxN := ' '
Endif
	
If "A" $ cQryAux1
	cQryAuxA := 'A'
Endif

If "F" $ cQryAux1
	cQryAuxF := 'F'
Endif

If "D" $ cQryAux1
	lDemitidos := .t.
	cQryAuxD   := 'D'
Endif
 
If "T" $ cQryAux1
	lTransfer := .t.
	cQryAuxT  := 'D'
Endif


/* //////////////// comentado por Rogerio Carvalho	

//If "D" $ cQryAux1 .And. !(" " $ cQryAux1) .And. !("A" $ cQryAux1) .And. !("F" $ cQryAux1) .And. !("T" $ cQryAux1)
//	lDemitidos:= .T.
//Endif      

// filtra somente transferidos.
//If "T" $ cQryAux1 .And. !(" " $ cQryAux1) .And. !("A" $ cQryAux1) .And. !("F" $ cQryAux1) .And. !("D" $ cQryAux1)
//	lTransfer:= .T.
//	cQryAux1T := "'D'"
//Endif                  

*/ ////////////////
                   

//-Ajusta o conteudo da cTiposSel pra usar na Query Categoria
cQryAux2 := ""
cTiposSel := Alltrim(mv_par08)
For nTp := 1 to Len(cTiposSel) Step 1
	cQryAux2 += "'"+SubStr(mv_par08, nTp, 1)+"'"
	If (nTp + 1) <= Len(mv_par08)
		cQryAux2 += ","
	EndIf
Next nTp
	
	cShDtD := dtos(mv_par09) 
	cShDtAt:= dtos(mv_par10) 
	cShDemD:= dtos(mv_par11) 
	cShDemA:= dtos(mv_par12) 
    
    // 24/01/2018 / 416094 : Rogerio Carvalho / chamado DOR04185643 
    // ajuste para gerar relatorio funcionarios em situação de folha : normal , afastados , ferias e transferidos
    
	// Monta no inicio da query para usar Order By
    _cQuery  := " SELECT * FROM ( "

	// Filtra (se selecionados) funcionarios com situação de folha : Normal ,Ferias e Afastados
	_cQuery  += " SELECT SRA.* FROM " + RetSqlName("SRA") + " SRA "
	_cQuery  += " WHERE "
	_cQuery  += " SRA.D_E_L_E_T_ = ' ' "
	
	_cQuery  += " AND RA_FILIAL IN (" + cQryAux + ") "
	_cQuery  += " AND RA_SITFOLH IN ('" + cQryAuxN +"','"+ cQryAuxA + "','"+ cQryAuxF + "') " 
	_cQuery  += " AND RA_CATFUNC IN (" + cQryAux2 +") "                                 
	_cQuery  += " AND RA_MAT     >= '" + mv_par05 +"' AND RA_MAT     <= '" + mv_par06 + "' "
	_cQuery  += " AND RA_CC      >= '" + mv_par03 +"' AND RA_CC      <= '" + mv_par04 + "' "

	_cQuery  += " AND RA_ADMISSA <= '" + cShDtAt  +"' AND RA_ADMISSA >= '" + cShDtD   + "' "
	_cQuery  += " AND RA_DEMISSA = ' ' " 

	// filtra somente demitidos.	
	If lDemitidos 
		_cQuery  += " UNION ALL "	
		_cQuery  += " SELECT SRA.* FROM " + RetSqlName("SRA") + " SRA "
		_cQuery  += " WHERE "
		_cQuery  += " SRA.D_E_L_E_T_ = ' ' "
		_cQuery  += " AND RA_FILIAL IN (" + cQryAux + ") "
		_cQuery  += " AND RA_SITFOLH IN ('" + cQryAuxD +"') " 
		_cQuery  += " AND RA_CATFUNC IN (" + cQryAux2 +") "                                 
		_cQuery  += " AND RA_MAT     >= '" + mv_par05 +"' AND RA_MAT     <= '" + mv_par06 + "' "
		_cQuery  += " AND RA_CC      >= '" + mv_par03 +"' AND RA_CC      <= '" + mv_par04 + "' "	
		_cQuery  += " AND RA_ADMISSA >= '" + cShDtD  + "' AND RA_ADMISSA <= '" + cShDtAt   + "' "
		_cQuery  += " AND RA_DEMISSA >= '" + cShDemD + "' AND RA_DEMISSA <= '" + cShDemA   + "' "	
		_cQuery  += " AND SRA.RA_AFASFGT NOT IN ('N1','N2') "		
	Endif
	
	// filtra somente transferidos.	
	If lTransfer
		_cQuery  += " UNION ALL "	
		_cQuery  += " SELECT SRA.* FROM " + RetSqlName("SRA") + " SRA "
		_cQuery  += " WHERE "
		_cQuery  += " SRA.D_E_L_E_T_ = ' ' "
		_cQuery  += " AND RA_FILIAL IN (" + cQryAux + ") "
		_cQuery  += " AND RA_SITFOLH IN ('" + cQryAuxT +"') " 
		_cQuery  += " AND RA_CATFUNC IN (" + cQryAux2 +") "                                 
		_cQuery  += " AND RA_MAT     >= '" + mv_par05 +"' AND RA_MAT     <= '" + mv_par06 + "' "
		_cQuery  += " AND RA_CC      >= '" + mv_par03 +"' AND RA_CC      <= '" + mv_par04 + "' "	
		_cQuery  += " AND RA_ADMISSA >= '" + cShDtD  + "' AND RA_ADMISSA <= '" + cShDtAt   + "' "
		_cQuery  += " AND RA_DEMISSA >= '" + cShDemD + "' AND RA_DEMISSA <= '" + cShDemA   + "' "	
		_cQuery  += " AND SRA.RA_AFASFGT IN ('N1','N2') "
	Endif


	// Adiciona ao final da query para usar Order By		
	_cQuery  += " ) ORDER BY RA_FILIAL,RA_MAT "   

	// 24/01/2018 - Fim Rogerio Carvalho 		

		
	If Select("TSRA") > 0
		TSRA->(DbCloseArea())
	EndIf
	
	TCQUERY _cQuery NEW ALIAS "TSRA"
	
	TSRA->( dbGoTop() )

    // Busca todos os campos no SRA e adiciona no cabecalho
    If cEmpresa <> cEmpAnt
        cEmpresa  := cEmpAnt
        aFieldSRA := {}
        //Início - Thais Paiva - Compatibilização P27
		//dbSelectArea('SX3')
        //dbSetOrder(1)
        //If dbSeek( 'SRA' )
            //do while SX3->(!Eof()) .and. ;
             //        SX3->X3_ARQUIVO == 'SRA'
		_aCmpRA := FWSX3Util():GetAllFields( "SRA" , .F. )
              //if (alltrim(SX3->X3_VISUAL ) <> 'V') .and.;
                //If (alltrim(SX3->X3_CONTEXT) <> 'V') .and.;
                 //  (alltrim(SX3->X3_CAMPO  ) <> 'RA_FILIAL') .And. (AllTrim(SX3->X3_CAMPO) != 'RA_SENHA') // Ticket No. 4335935 12/11/2018 Don Junior 
		For _nRa := 1 to Len(_aCmpRA)
			If alltrim(GetSx3Cache(_aCmpRA[_nRa], 'X3_CAMPO')) <> 'RA_FILIAL' .And. AllTrim(GetSx3Cache(_aCmpRA[_nRa], 'X3_CAMPO')) != 'RA_SENHA'
                    //aadd( aFieldSRA, { "TSRA->"+alltrim(SX3->X3_CAMPO ),;
                    //                   "TSRA->"+alltrim(SX3->X3_TITULO),;
                    //                   "TSRA->"+alltrim(SX3->X3_TIPO  ) })
                    // aadd( aXFie_SRA, { alltrim(SX3->X3_CAMPO ),;
                    //                   alltrim(SX3->X3_TITULO),;
                    //                   alltrim(SX3->X3_TIPO  ) })                                       
				aadd( aFieldSRA, { "TSRA->"+alltrim(GetSx3Cache(_aCmpRA[_nRa], 'X3_CAMPO')),;
                                   "TSRA->"+alltrim(GetSx3Cache(_aCmpRA[_nRa], 'X3_TITULO')),;
                                   "TSRA->"+alltrim(GetSx3Cache(_aCmpRA[_nRa], 'X3_TIPO')) })
                aadd( aXFie_SRA, { alltrim(GetSx3Cache(_aCmpRA[_nRa], 'X3_CAMPO')),;
                                   alltrim(GetSx3Cache(_aCmpRA[_nRa], 'X3_TITULO')),;
                                   alltrim(GetSx3Cache(_aCmpRA[_nRa], 'X3_TIPO')) })   
             Endif
                //dbskip()
            //enddo
        //endif
		Next _nRa
		//Fim - Thais Paiva - Compatibilização P27
		
//        cDetArq := 'Empresa;Filial;Nome Filial;Cod Função;Desc Função;Cod C.Custo;Desc C.Custo;Desc Turno; Desc Instrução; Sexo; Desc Est Civil; Desc Vinculo Emp; Raça;Desc Sindicato;'
        cDetArq := 'Empresa;Filial;Nome Filial;Desc Função;Desc C.Custo;Desc Turno; Desc Instrução; Sexo; Desc Est Civil; Desc Vinculo Emp; Raça;Desc Sindicato;'        
        for iX := 1 to len(aXFie_SRA)
            cDetArq += aXFie_SRA[iX][2] + ';'
        next iX
        if !iFirst
            fWrite(nArqTxt,'------------------'+Chr(13)+Chr(10))
	      	_aTitCom:= strtokarr(cDetArq, ';')
        endif
        //fWrite(nArqTxt,cDetArq+Chr(13)+Chr(10))
        iFirst := .F.
    Endif
	     
	fWrite(nArqTxt,cDetArq+Chr(13)+Chr(10)) 
    _aTitCom:= strtokarr(cDetArq, ';')
	     
	ProcRegua(0)
		
 	Do while TSRA->(!Eof())	
    
      ProcRegua(TSRA->(RecCount()))
    
	  IncProc("Emp.: " + cEmpAnt + "  Fil.: " + TSRA->RA_FILIAL + "  Func.: " + LEFT(TSRA->RA_NOME,30))

	  cRaca:= ""
      If TSRA->RA_RACACOR = "1"
         cRaca := "Indigena"
      ElseIf TSRA->RA_RACACOR = "2"               
           cRaca := "Branco"
           ElseIf TSRA->RA_RACACOR = "4"     
                cRaca := "Negro"
                ElseIf TSRA->RA_RACACOR = "6"               
                     cRaca := "Amarelo"
                 ElseIf TSRA->RA_RACACOR = "8"                         
                      cRaca := "Pardo"
                      ElseIf TSRA->RA_RACACOR = "9"               
                            cRaca := "Não Informado"
      EndIf
      
      
      //Situação do Funcionario  
      cSit := ""
      //IF empty(TSRA->RA_SITFOLH) 
 	  IF TSRA->RA_SITFOLH=' '
         cSit := "Ativo"
      ElseIf TSRA->RA_SITFOLH = "F"
           cSit := "Ferias"
           ElseIf TSRA->RA_SITFOLH = "A"
                cSit := "Afastado"
                ElseIf TSRA->RA_SITFOLH = "D" 
                     cSit := "Demitido"
                 ElseIf TSRA->RA_SITFOLH = "D" .and. TSRA->RA_RESRAI = "31"
                      cSit := "Transferido"
                      
      EndIf
      
       
      //cDetArq := PadR(SM0->M0_NOME,20,'')      + ';' // ticket n° 10310061 -- linha comentada
      cDetArq := Alltrim(FwGrpName()) + ';' // ticket n° 10310061 -- retorno do nome do grupo de empresas
      cDetArq += TSRA->RA_FILIAL                + ';'
      cDetArq += FWFilialName(cEmpAnt,TSRA->RA_FILIAL) + ';                                                     
      
//      cDetArq += PadR(TSRA->RA_CODFUNC,5,"")												       			+";"      
      cDetArq += PadR(POSICIONE("SRJ",1,XFILIAL("SRJ")+TSRA->RA_CODFUNC,"RJ_DESC"),30,"")          			+";"
//      cDetArq += PadR(TSRA->RA_CC,11,"")												            		+";"
      cDetArq += PadR(POSICIONE("CTT",1,XFILIAL("CTT")+TSRA->RA_CC,"CTT_DESC01"),40,"")             		+";"
      cDetArq += PadR(POSICIONE("SR6",1,XFILIAL("SR6")+TSRA->RA_TNOTRAB,"R6_DESC"),50,"")      	   			+";"
      cDetArq += PadR(POSICIONE("SX5",1,XFILIAL("SX5")+"26"+TSRA->RA_GRINRAI,"X5_DESCRI"),55,"")   			+";" 
      cDetArq += PadR(IF(TSRA->RA_SEXO="M","Masculino","Feminino"),10,"")									+";"
      cDetArq += PadR(POSICIONE("SX5",1,XFILIAL("SX5")+"33"+TSRA->RA_ESTCIVI,"X5_DESCRI"),55,"")   			+";"     
      cDetArq += PadR(POSICIONE("SX5",1,XFILIAL("SX5")+"25"+TSRA->RA_VIEMRAI,"X5_DESCRI"),55,"")   			+";"         
      cDetArq += PadR(cRaca,15,"")           							                                    +";"    
      cDetArq += PadR(POSICIONE("RCE",1,XFILIAL("RCE")+TSRA->RA_SINDICA,"RCE_DESCRI"),50,"")      			+";"  
      
	  dBSelectArea('SRA')
	  For iY := 1 to len(aFieldSRA)
	        Do Case
	           Case alltrim(substr(aFieldSRA[iY][3],7,1)) == 'C'
	               cDetArq += &(aFieldSRA[iY][1]) + ';'  
	           Case alltrim(substr(aFieldSRA[iY][3],7,1)) == 'N'
	               cDetArq += str(&(aFieldSRA[iY][1])) + ';'
	           Case alltrim(substr(aFieldSRA[iY][3],7,1)) == 'D'
	           		cShDt:= (&(aFieldSRA[iY][1]))
 	           		cShDt:=	substr(cShDt,7,2)+"/"+substr(cShDt,5,2)+"/"+substr(cShDt,1,4)
	               cDetArq += cShDt+ ';' 
	           Case alltrim(substr(aFieldSRA[iY][3],7,1)) == 'M'
	               cDetArq += " " + ';'	               
	        Endcase
	  Next iY
                                           
  	  //transforma o text em array.
  	  _aDados:= strtokarr(cDetArq, ';')  
  	  
  	  fWrite(nArqTxt,cDetArq+Chr(13)+Chr(10))
      AAdd(_aDadosCom,  _aDados )   

                
     TSRA->(DbSkip())         
     
    End
    
    If Len(_aDadosCom) > 0
    	FClose(nArqTxt)
		ShellExecute( "Open" , cxLocArq ,"", "" , 3 )      
    Endif

    FClose(nArqTxt)
    /*
	If Len(_aDadosCom) > 0  
	    MsgRun("Favor Aguardar.....", "Exportando os Registros para o Excel",{||DlgToExcel({{"ARRAY",_cTabCom,_aTitCom,_aDadosCom}})})	   
    Endif
    */
	MsgAlert( "Arquivo Gerado em := " + cxLocArq )    
                                       
Return             




*********************************
Static Function fGravaData(dData)
*********************************

  cData := GravaData(dData,.F.,5)
  cRet  := Subs(cData,1,2)+"."+Subs(cData,3,2)+"."+Subs(cData,5,4)
Return(cRet)

**************************
Static Function ValidPerg()
************************** 

Local i,j    := 0
Local aSx1   := {}
Local aRegs  := {}

dbSelectArea("SX1")
dbSetOrder(1)       

cPerg:= Padr("GERASRA",10)

//  Aadd(aSx1,{cPerg  ,"01"   ,"Nome do Arquivo .............?","Nome do Arquivo .............?","Nome do Arquivo .............?","mv_ch0" ,"C"   ,30       ,0        ,0	   ,"G"  ,"NaoVazio"   		   ,"mv_par01",""   ,""     ,""     ,""   ,""   ,""   ,""     ,""     ,""   ,""   ,""     ,""     ,""     ,""   ,""   ,""   ,""     ,""     ,""   ,""   ,""   ,""     ,""     ,""   ,""   ,"S" ,""     ,"",""})
  Aadd(aSx1,{cPerg  ,"01"   ,"Local de Gravação............?","Local de Gravação............?","Local de Gravação............?","mv_ch0" ,"C"   ,60       ,0        ,0     ,"G"  ,"U_xfGetPath(mv_par01)" ,"mv_par01",""   ,""     ,""     ,""   ,""   ,""   ,""     ,""     ,""   ,""   ,""     ,""     ,""     ,""   ,""   ,""   ,""     ,""     ,""   ,""   ,""   ,""     ,""     ,""   ,""   ,"S" ,""     ,"",""})  
  Aadd(aSx1,{cPerg  ,"02"   ,"Filiais  ....................?","Filiais  ....................?","Filiais  ....................?","mv_ch0" ,"C"   ,99       ,0        ,0	   ,"G"  ,"u_xFilOpc(mv_par02)"	  ,"mv_par02",""   ,""     ,""     ,""   ,""   ,""   ,""     ,""     ,""   ,""   ,""     ,""     ,""     ,""   ,""   ,""   ,""     ,""     ,""   ,""   ,""   ,""     ,""     ,""   ,""   ,"S" ,""     ,"",""})
  Aadd(aSx1,{cPerg  ,"03"   ,"Centro de Custo De...........?","Centro de Custo De...........?","Centro de Custo De...........?","mv_ch0" ,"C"   ,11       ,0        ,0	   ,"G"  ,""                      ,"mv_par03",""   ,""     ,""     ,""   ,""   ,""   ,""     ,""     ,""   ,""   ,""     ,""     ,""     ,""   ,""   ,""   ,""     ,""     ,""   ,""   ,""   ,""     ,""     ,""   ,"CTT","S" ,""     ,"",""})
  Aadd(aSx1,{cPerg  ,"04"   ,"Centro de Custo Ate..........?","Centro de Custo Ate..........?","Centro de Custo Ate..........?","mv_ch0" ,"C"   ,11       ,0        ,0     ,"G"  ,"NaoVazio"           	  ,"mv_par04",""   ,""     ,""     ,""   ,""   ,""   ,""     ,""     ,""   ,""   ,""     ,""     ,""     ,""   ,""   ,""   ,""     ,""     ,""   ,""   ,""   ,""     ,""     ,""   ,"CTT","S" ,""     ,"",""})
  Aadd(aSx1,{cPerg  ,"05"   ,"Matricula De.................?","Matricula De.................?","Matricula De.................?","mv_ch0" ,"C"   ,06       ,0        ,0     ,"G"  ,""                      ,"mv_par05",""   ,""     ,""     ,""   ,""   ,""   ,""     ,""     ,""   ,""   ,""     ,""     ,""     ,""   ,""   ,""   ,""     ,""     ,""   ,""   ,""   ,""     ,""     ,""   ,"SRA","S" ,""     ,"",""})
  Aadd(aSx1,{cPerg  ,"06"   ,"Matricula Ate................?","Matricula Ate................?","Matricula Ate................?","mv_ch0" ,"C"   ,06       ,0        ,0     ,"G"  ,"NaoVazio"              ,"mv_par06",""   ,""     ,""     ,""   ,""   ,""   ,""     ,""     ,""   ,""   ,""     ,""     ,""     ,""   ,""   ,""   ,""     ,""     ,""   ,""   ,""   ,""     ,""     ,""   ,"SRA","S" ,""     ,"",""})
  Aadd(aSx1,{cPerg  ,"07"   ,"Situacaoes...................?","Situacaoes...................?","Situacaoes...................?","mv_ch0" ,"C"   ,05       ,0        ,0     ,"G"  ,"fSituacao"             ,"mv_par07",""   ,""     ,""     ,""   ,""   ,""   ,""     ,""     ,""   ,""   ,""     ,""     ,""     ,""   ,""   ,""   ,""     ,""     ,""   ,""   ,""   ,""     ,""     ,""   ,""   ,"S" ,""     ,"",""})
  Aadd(aSx1,{cPerg  ,"08"   ,"Categoria....................?","Categoria....................?","Categoria....................?","mv_ch0" ,"C"   ,15       ,0        ,0     ,"G"  ,"fCategoria"            ,"mv_par08",""   ,""     ,""     ,""   ,""   ,""   ,""     ,""     ,""   ,""   ,""     ,""     ,""     ,""   ,""   ,""   ,""     ,""     ,""   ,""   ,""   ,""     ,""     ,""   ,""   ,"S" ,""     ,"",""})
  Aadd(aSx1,{cPerg  ,"09"   ,"Data Admissao De.............?","Data Admissao De.............?","Data Admissao De.............?","mv_ch0" ,"D"   ,08       ,0        ,0     ,"G"  ,""                      ,"mv_par09",""   ,""     ,""     ,""   ,""   ,""   ,""     ,""     ,""   ,""   ,""     ,""     ,""     ,""   ,""   ,""   ,""     ,""     ,""   ,""   ,""   ,""     ,""     ,""   ,""   ,"S" ,""     ,"",""})
  Aadd(aSx1,{cPerg  ,"10"   ,"Data Admissao Ate............?","Data Admissao Ate............?","Data Admissao Ate............?","mv_ch0" ,"D"   ,08       ,0        ,0     ,"G"  ,""                      ,"mv_par10",""   ,""     ,""     ,""   ,""   ,""   ,""     ,""     ,""   ,""   ,""     ,""     ,""     ,""   ,""   ,""   ,""     ,""     ,""   ,""   ,""   ,""     ,""     ,""   ,""   ,"S" ,""     ,"",""})
  Aadd(aSx1,{cPerg  ,"11"   ,"Data Demissao De.............?","Data Demissao De.............?","Data Demissao De.............?","mv_ch0" ,"D"   ,08       ,0        ,0     ,"G"  ,""                      ,"mv_par11",""   ,""     ,""     ,""   ,""   ,""   ,""     ,""     ,""   ,""   ,""     ,""     ,""     ,""   ,""   ,""   ,""     ,""     ,""   ,""   ,""   ,""     ,""     ,""   ,""   ,"S" ,""     ,"",""})
  Aadd(aSx1,{cPerg  ,"12"   ,"Data Demissao Ate............?","Data Demissao Ate............?","Data Demissao Ate............?","mv_ch0" ,"D"   ,08       ,0        ,0     ,"G"  ,""                      ,"mv_par12",""   ,""     ,""     ,""   ,""   ,""   ,""     ,""     ,""   ,""   ,""     ,""     ,""     ,""   ,""   ,""   ,""     ,""     ,""   ,""   ,""   ,""     ,""     ,""   ,""   ,"S" ,""     ,"",""})
//  Aadd(aSx1,{cPerg  ,"13"   ,"Local de Gravação............?","Local de Gravação............?","Local de Gravação............?","mv_ch0" ,"C"   ,60       ,0        ,0     ,"G"  ,"U_xfGetPath(mv_par13)" ,"mv_par13",""   ,""     ,""     ,""   ,""   ,""   ,""     ,""     ,""   ,""   ,""     ,""     ,""     ,""   ,""   ,""   ,""     ,""     ,""   ,""   ,""   ,""     ,""     ,""   ,""   ,"S" ,""     ,"",""})


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
User Function xFilOpc()
**************************

Local MvPar
Local MvParDef := ""
Local aItens   := {}
Local aArea    := GetArea() 

Local lRet      := .F.
//Local aUsuarios := AllUsers()
Local aUsrAux   := {}
Local nLinEnc   := 0
Local nPosFil   := 0
Local nTamGrp   := 0
Local aFilGrp	  := {}
Local aFilGrpX  := {}

Private cCodUsr := RetCodUsr()
Private cCodEmp := cEmpAnt
Private cCodFil := cFilAnt 
Private _aFilUser := {}
//416094:Rogerio Carvalho - 09/05/2018 : Ajuste para funcionar com usuário com acesso restrito a algumas filiais
Private _aGrpUser := {}
 
						      

//Encontra o usuário
//nLinEnc:= aScan(aUsuarios, {|x| x[1][1] == cCodUsr }) 

//Caso encontre o usuário
/*
If nLinEnc > 0
	aUsrAux := aClone(aUsuarios[nLinEnc][2][6]) 
Else
    Alert("Usuario nao encontrado com vinculo para filiais")
    Return
Endif  
*/

If !Empty(cCodUsr)
	PswOrder( 01 )
	If PswSeek( cCodUsr, .T. )  // .f. grupo, .t. usuario
        // busco o grupo que o funcionario esta vinculado
		//_aFilUser := PswRet()[1][10]
		// caso esteja vinculado a um grupo - (PswRet()[1][10] - GRUPO DO USUARIO), FWGRPEMP(GRUPO,.T.)- EMPRESAS/FILIAIS QUE TEM ACESSO.
		//If len(_aFilUser) > 0
			//416094:Rogerio Carvalho - 09/05/2018 : Ajuste para funcionar com usuário com acesso restrito a algumas filiais
			
			_aGrpUser:= UsrRetGrp(,cCodUsr)	
			
			nTamGrp  := len(_aGrpUser)
			
			If nTamGrp < 1
			   	Alert("Usuario sem GRUPO associado")
			   	Return
			Endif
			
			For xGrp := 1 to nTamGrp
			
				//aFilGrp  := FWGRPEMP(_aGrpUser[xGrp])
				aadd(aFilGrp,FWGRPEMP(_aGrpUser[xGrp]))
				
				nFGrupo := len(aFilGrp[xGrp])
				
				For xFGrp := 1 to nFGrupo
					aadd(aFilGrpX,aFilGrp[xGrp][xFGrp])					
				Next
				
			Next
			
			 
		Else
			//416094:Rogerio Carvalho - 09/05/2018 : Ajuste para funcionar com usuário com acesso restrito a algumas filiais		
			//_aGrpUser:= PswRet()[02][06]// empresas que o usuario tem acesso
		//Endif 		
	//Else
	    Alert("Usuario nao encontrado!")	
	    Return
	EndIf  
Else
    Alert("Usuario inválido!")
    Return
EndIf	
	
MvPar := &(Alltrim(ReadVar()))       // Carrega Nome da Variavel do Get em Questao
MvRet := Alltrim(ReadVar())          // Iguala Nome da Variavel ao Nome variavel de Retorno

dbSelectArea("SM0")
//dbSetOrder(RetOrder("SM0","SM0_CODIGO+ SM0_CODFIL +SM0_FILIAL"))
dBGotop()
While !Eof() .And. SM0->M0_CODIGO == cEmpAnt
	    
      	//Agora procura pela empresa + filial nos acessos
      	//416094:Rogerio Carvalho - 09/05/2018 : Ajuste para funcionar com usuário com acesso restrito a algumas filiais
        nPosFil := aScan(aFilGrpX, cCodEmp + alltrim(SM0->M0_CODFIL))
       //nPosFil := aScan(_aGrpUser, {|x| x == cCodEmp + SM0->M0_CODFIL })
         
        //Se encontrou a filial ou tem acesso a todas, o retorno será verdadeiro
        If nPosFil > 0 .Or. "@" $ aFilGrpX[1]
            lRet := .T.   
   			 aAdd(aItens, SM0->M0_FILIAL )
			 MvParDef += alltrim(SM0->M0_CODFIL)
		 	 DbSelectArea( "SM0" ) 
			 SM0->( DbSkip() )
        Else
             DbSelectArea( "SM0" ) 
		  	 SM0->( DbSkip() )
        Endif
      
        // se usuario tiver acesso, demonstra a filial para selecao no combo.
        //If lRet 
   		//	 aAdd(aItens, SM0->M0_FILIAL )
		//	 MvParDef += alltrim(SM0->M0_CODFIL)
		//Endif
			 
      
     
	  //("SM0")->(dbSkip())
End

//		    Retorno	    ,Titulo  ,  opcoes     , Strin Ret   ,lin  ,col  , Tipo Sel  ,tam chave , n. ele ret, Botao 
IF f_Opcoes  (@MvParDef, "Opcoes", aItens     , MvParDef     ,12   , 49 , .F.        ,  8       ,   999    , .T.  )  // "Opções"
	&MvRet := MvPar                                      // Devolve Resultado
EndIF

cShFiliais:= MvParDef

RestArea(aArea)                                  // Retorna Alias
Return MvParDef



**************************
User Function xfGetPath() //Permite que o usuario decida onde sera criado o arquivo
**************************

Local cRet	:= Alltrim(ReadVar())
cPath		:= mv_par01

oWnd := GetWndDefault()

While .T.
	If Empty(cPath)
		//cPath := cGetFile( "Local de Gravação | *.csv ",OemToAnsi("Salve o Arquivo"))
		cPath := cGetFile( "Local de Gravação | *.csv ",OemToAnsi("Salve o Arquivo"),0,,.F.,GETF_LOCALFLOPPY + GETF_LOCALHARD + GETF_RETDIRECTORY)
		//cPath := cGetFile( "Local de Gravação | *.csv ",OemToAnsi("Salve o Arquivo"),0,,.F.,GETF_LOCALHARD )		
	EndIf
	
	If Empty(cPath)
		Return .F.
	EndIf
	&cRet := cPath
	Exit
EndDo

If oWnd != Nil
	GetdRefresh()
EndIf

Return .T.      
 

 