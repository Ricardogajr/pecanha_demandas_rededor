#include "totvs.ch"
#include "protheus.ch"
#include "topconn.ch"
///////////////////////////////////////////////////
// CARGA NA TABELA RHH PROTHEUS 12 VIA PLANILHA. //
///////////////////////////////////////////////////
***********************
User Function UPD0115()
***********************

	Local cLinha 	 := ""
	Local lRet		 := .T.
	Local lPrim 	 := .F.
	Local cText 	 := OemToAnsi("Selecione o Arquivo de Importação:")
	Private aDados 	 := {}
    Private cArquivo := Space(150)
    Private lOk      :=.F.
	Private nLidos  := 0
	Private nProce  := 0

    Define MsDialog oDlg Title "UPD0115 - Selecionar Arquivo para Carga" From 08,15 To 19,120 Of GetWndDefault()
      
    @ 18,16  Say 	"Diretorio:" 	Size 050,10 Of oDlg Pixel
    @ 18,40  MsGet 	cArquivo 		Size 230,08 Of oDlg Pixel
    @ 18,275 Button "..." 			Size 010,10 Action Eval({|| cArquivo:=u_SelectFile() }) Of oDlg Pixel
    @ 18,310 Button "OK"            Size 040,20 Action Eval({|| If(u_ValidaDir(cArquivo), (lOk:=.T.,oDlg:End()) ,)}) Of oDlg Pixel
    @ 18,355 Button "CANCEL"        Size 040,20 Action Eval({|| lOk:=.F.,oDlg:End() }) Of oDlg Pixel
    Activate MsDialog oDlg //Centered On Init (EnchoiceBar(oDlg,bOk,bCancel))

    If lOk
       MsgRun("Lendo Planilha ","Aguarde...",{|| LerArq(aDados) })   
       MsgRun("Processando Planilha ","Aguarde...",{|| ImportDad(aDados) })   
       MsgStop( "Fim da Rotina", "UPD0115" )
    Endif
	FT_FUSE()

Return

*********************************
Static Function ImportDad(aDados)
*********************************

	Local i 		  := 0
	Local j 		  := 0
	Local lRet		  := .T.
	Local aRetorno	  :={}
	Local lOk         := .T.
	Local aAreaSRA    := SRA->(GetArea())
	Local aAreaRHH    := RHH->(GetArea())
	Local aAreaCTT    := CTT->(GetArea())
	Local aAreaSRV    := SRV->(GetArea())
	Local aAreaRCJ    := RCJ->(GetArea())
	Local aAreaSRY    := SRY->(GetArea())
	Local aAreaRCE    := RCE->(GetArea())

	ProcRegua(LEN(ADADOS))

	//////////////////////////////////////////////////////////
	// COLUNA A = FILIAL                      RHH_FILIAL 	//1
	// COLUNA B = MATRICULA                   RHH_MAT	    //2
	// COLUNA C = CENTRO DE CUSTO             RHH_CC	    //3
	// COLUNA D = VALOR                       RHH_VL	    //4
	// COLUNA E = DATA  REFERENCIA AAAAMM     RHH_DATA	    //5
	// COLUNA F = NOVO SALARIO                RHH_CALC   	//6
	// COLUNA G = VERBA DE ORIGEM             RHH_VB        //7
	// COLUNA H = VALOR DA DIFERENCA          RHH_VALOR	    //8
	// COLUNA I = VERBA DA DIREFENCA DE PAGTO RHH_VERBA     //9
	// COLUNA J = INDICE DO REAJUSTE          RHH_INDICE	//10
	// COLUNA K = TIPO AUMENTO                RHH_TPOAUM	//11
	// COLUNA L = DATA BASE DISSIDIO          RHH_MESANO	//12
	// COLUMN M = CODIGO SINDICATO            RHH_SINDIC    //13
	// COLUMN N = DATA ASSINATURA             RHH_DEFTA     //14
	// COLUMN O = DESCRICAO MOTIVO ACORDO     RHH_DSC       //15
	// COLUMN P = DATA DO ACORDO              RHH_DTACOR    //16
	//////////////////////////////////////////////////////////

	For i:=1 to Len(aDados)
        nproce++
	    ptinternal(1,'*** Processando Linha = '+strzero(nproce,9,0)+" de "+strzero(nLidos,9,0))
	    if len(aDados[i,1]) > 0
           c_Filial := PADL(aDados[i,1],TamSX3("RA_FILIAL")[1],"0")
           If Len(alltrim(c_Filial)) < 8
              c_Filial := "0"+alltrim(c_Filial)
           Endif
           c_Mat    := PADL(aDados[i,2],TamSX3("RA_MAT")[1],"0")
           c_Mat    := Strzero(Val(c_mat),6,0)
           c_linha  := strzero(i,7,0)
        
		SRA->(DbSetOrder(1))
		If SRA->(DbSeek(c_Filial+c_Mat))
	       c_CC	    := PADL(aDados[i,3],TamSX3("RHH_CC")[1],"0")
	       n_VL	    := aDados[i,4]
	       c_DATA	:= PADL(aDados[i,5],TamSX3("RHH_DATA")[1],"0")    
	       n_CALC   := aDados[i,6]
           c_VB     := aDados[i,7]
	       n_VALOR	:= aDados[i,8]
		   c_VERBA  := PADL(aDados[i,9],TamSX3("RHH_VERBA")[1],"0")
	       n_INDICE	:= aDados[i,10]
	       c_TPOAUM	:= PADL(aDados[i,11],TamSX3("RHH_TPOAUM")[1],"0")
	       IF VALTYPE(aDados[i,12]) = "D"
	          c_MESANO := SUBSTR(DTOS(aDados[i,12]),1,6)
	       ELSE          
	          N1 := AT( "/", aDados[i,12] ) 
	          IF N1 > 0
	             cTexto1 := STRTRAN(aDados[i,12], "/", "")
                 c_MESANO := SUBSTR(CTEXTO1,5,4)+SUBSTR(CTEXTO1,3,2)
              ELSE
  	             c_MESANO := PADL(aDados[i,12],TamSX3("RHH_MESANO")[1],"0")
  	          ENDIF
  	       ENDIF
	       c_SINDIC := PADL(aDados[i,13],TamSX3("RHH_SINDIC")[1],"0")
	       d_DEFTA  := aDados[i,14]
	       c_DSC    := aDados[i,15]
	       d_DTACOR := aDados[i,16]
	       lOk      := .T.
		   //////////////////////////
		   // VALIDACAO DOS CAMPOS //
		   //////////////////////////
		   RCE->(DbSetOrder(1))
           If !RCE->(dbseek(xFilial("RCE")+c_SINDIC))
			  AADD(aRetorno,{c_Filial,c_Mat,"Não","Linha="+c_linha+" - Codigo do Sindicato Invalido"})
              lOk := .F.
           Endif 		   

		   CTT->(DbSetOrder(1))
           If !CTT->(dbseek(xFilial("CTT")+c_CC))
			  AADD(aRetorno,{c_Filial,c_Mat,"Nao","Linha="+c_linha+" - Centro de Custo Invalido"})
              lOk := .F.
           Endif 		   

		   SRV->(DbSetOrder(1))
           If !SRV->(dbseek(xFilial("SRV")+c_VB))
			  AADD(aRetorno,{c_Filial,c_Mat,"Nao","Linha="+c_linha+" - Verba de Origem Invalida"})
              lOk := .F.
           Endif 		   

		   SRV->(DbSetOrder(1))
           If !SRV->(dbseek(xFilial("SRV")+c_Verba))
			  AADD(aRetorno,{c_Filial,c_Mat,"Nao","Linha="+c_linha+" - Verba de Pagamento Invalida"})
              lOk := .F.
           Endif 		   
		   
	       If !(n_VL > 0)
			  AADD(aRetorno,{c_Filial,c_Mat,"Nao","Linha="+c_linha+" - Salário Anterior Invalido"})
              lOk := .F.
		   Endif
		   
	       If Empty(c_DATA)
			  AADD(aRetorno,{c_Filial,c_Mat,"Nao","Linha="+c_linha+" - Data de Referência de Pagto Dissídio (ano e mês) Invalido"})
              lOk := .F.
           Endif
		   
	       If !(n_CALC > 0)
			  AADD(aRetorno,{c_Filial,c_Mat,"Nao","Linha="+c_linha+" - Novo Salário Invalido"})
              lOk := .F.
		   Endif
		   
	       If !(n_VALOR > 0)
			  AADD(aRetorno,{c_Filial,c_Mat,"Nao","Linha="+c_linha+" - Valor da Diferença Invalido"})
              lOk := .F.
		   Endif
		   
	       If !(n_INDICE > 0)
			  AADD(aRetorno,{c_Filial,c_Mat,"Nao","Linha="+c_linha+" - Indice de Reajuste Invalido"})
              lOk := .F.
		   Endif

		  // cTpAco := fTpAco(c_Filial,c_TPOAUM)
		  // 
	      // If !(c_TPOAUM = cTpAco)
		  //	  AADD(aRetorno,{c_Filial,c_Mat,"Nao","Tipo Aumento Invalido"})
          //    lOk := .F.
		  // Endif
		   
	       If Empty(c_MESANO) .Or. (Right(c_MesAno,2) < '01' .Or. Right(c_MesAno,2) > '12') .Or. (Val(Left(c_MesAno,4)) > Year(Date()))
			  AADD(aRetorno,{c_Filial,c_Mat,"Nao","Linha="+c_linha+" - Data base do Dissídio (ano e mês) Invalido"})
              lOk := .F.
		   Endif

           // Buscando dados SR7 //

   			IF  Substr(DtoS(SRA->RA_ADMISSA),1,6) >= c_DATA
				dDtReaj 	:= SRA->RA_ADMISSA
			Else
				dDtReaj 	:= Ctod( "01/" + substr(c_DATA,5,2) + "/" + substr(c_DATA,1,4))
			Endif
		    
		   ///////////////////////////////////////////////////////////////////////////////
		   
           ///////////////////////////////////////////////////////////////////////////////////////////////////		   
		   If lOk
		            cQry :=      "SELECT R_E_C_N_O_ AS REGISTRO"
		            cQry += CRLF+"  FROM "+RetSqlName("RHH")
		            cQry += CRLF+" WHERE RHH_FILIAL = '"+c_Filial+"'"
		            cQry += CRLF+"   AND RHH_CC = '"+c_CC+"'"
		            cQry += CRLF+"   AND RHH_MAT    = '"+c_Mat+"'"
		            cQry += CRLF+"   AND RHH_VB  = '"+c_vb+"'"
		            //cQry += CRLF+"   AND RHH_VERBA  = '"+c_Verba+"'"  
					cQry += CRLF+"   AND RHH_DATA = '"+c_data+"'"
					cQry += CRLF+"   AND RHH_SINDIC = '"+c_SINDIC+"'"
                    cQry += CRLF+"   AND D_E_L_E_T_  <> '*'"   

		            cQry := changequery(cQry) 

					TCQUERY cQry ALIAS "cTMP" NEW

                    If cTMP->(REGISTRO)> 0  
		               lInclui := .F.
                       RHH->( dbGoTo( cTMP->(REGISTRO) ) )					   
                    else
		               lInclui := .T.
                    endif
	                cTMP->(DbCloseArea()) 
	                
                    RecLock("RHH",lInclui)
                    RHH->RHH_FILIAL   := c_Filial
                    RHH->RHH_MAT      := c_Mat
                    RHH->RHH_CC       := c_CC
                    RHH->RHH_VB       := c_Vb
                    RHH->RHH_VL       := n_VL
                    RHH->RHH_DATA     := c_DATA
                    RHH->RHH_VERBA    := c_Verba
                    RHH->RHH_CALC     := n_CALC
                    RHH->RHH_VALOR    := n_VALOR
                    RHH->RHH_INDICE   := n_INDICE
                  // RHH->RHH_VLRAUM   :=
                    RHH->RHH_TPOAUM   := c_TPOAUM
                  // RHH->RHH_COMPL_   :=
                  // RHH->RHH_SEMANA   :=
                  // RHH->RHH_INTEGR   :=
                    RHH->RHH_MESANO   := c_MESANO
                  // RHH->RHH_TIPO1    :=
                  // RHH->RHH_TIPO2    :=
                  // RHH->RHH_HORAS    :=
                  // RHH->RHH_PARC     :=
                  // RHH->RHH_SEQ      :=
                  // RHH->RHH_QTDSEM   :=
                  // RHH->RHH_DTPGT    :=
                  // RHH->RHH_ITEM     :=
                  // RHH->RHH_CLVL     :=
                  // RHH->RHH_IDCMPL   :=
                  // RHH->RHH_GRRA     :=
                  // RHH->RHH_RRA      :=
                  // RHH->RHH_PROCES   :=
                    RHH->RHH_ROTEIR   := "FOL"
                    RHH->RHH_DTACOR   := ctod(d_DTACOR)
                    RHH->RHH_SINDIC   := c_SINDIC
                    RHH->RHH_DEFTA    := ctod(d_DEFTA)     
                    _cTeste := NoAcento(AnsiToOem(AllTrim(c_DSC)))
                    _nTam   := TamSX3("RHH_DSC")
                    _nTam1 := _nTam[1]
                    MSMM(RHH->RHH_DSC,,,_cTeste,1,,,"RHH","RHH_DSC")     
                    msunlock()
			        AADD(aRetorno,{c_Filial,c_Mat,"Sim","Linha="+c_linha+" - Atualizada com Sucesso"})
			EndIf
		Else
			AADD(aRetorno,{c_Filial,c_Mat,"Nao","Linha="+c_linha+" - Filial e Matricula Nao encontrado no sistema"})
		EndIf
		
		Endif
	Next i

	If !Empty(aRetorno)
		Aviso('Processamento Realizado!',"Verifique o log da importação", {'OK'}, 1)
        Geralog(aRetorno,cArquivo)
	EndIf
	
	RestArea(aAreaSRA)
	RestArea(aAreaRHH)
	RestArea(aAreaCTT)
	RestArea(aAreaSRV)
	RestArea(aAreaRCJ)
	RestArea(aAreaSRY)
	RestArea(aAreaRCE)

Return

******************************
Static Function LerArq(aDados)
******************************

	Local cLinha 	:= ""
	Local lPrim 	:= .F.
	Local aCampos	:= {}
	
	FT_FUSE(cArquivo)
	ProcRegua(FT_FLASTREC())
	nQtdLinhas := FT_FLASTREC()
	FT_FGOTOP()
	////////////////////////////
	// COLUNAS DO ARQUIVO CSV //
	//////////////////////////////////////////////////////////
	// COLUNA A = FILIAL                      RHH_FILIAL 	//1
	// COLUNA B = MATRICULA                   RHH_MAT	    //2
	// COLUNA C = CENTRO DE CUSTO             RHH_CC	    //3
	// COLUNA D = VALOR                       RHH_VL	    //4
	// COLUNA E = DATA  REFERENCIA AAAAMM     RHH_DATA	    //5
	// COLUNA F = NOVO SALARIO                RHH_CALC   	//6
	// COLUNA G = VERBA DE ORIGEM             RHH_VB        //7
	// COLUNA H = VALOR DA DIFERENCA          RHH_VALOR	    //8
	// COLUNA I = VERBA DA DIREFENCA DE PAGTO RHH_VERBA     //9
	// COLUNA J = INDICE DO REAJUSTE          RHH_INDICE	//10
	// COLUNA K = TIPO AUMENTO                RHH_TPOAUM	//11
	// COLUNA L = DATA BASE DISSIDIO          RHH_MESANO	//12
	// COLUMN M = CODIGO SINDICATO            RHH_SINDIC    //13
	// COLUMN N = DATA ASSINATURA             RHH_DEFTA     //14
	// COLUMN O = DESCRICAO MOTIVO ACORDO     RHH_DSC       //15
	// COLUMN P = DATA DO ACORDO              RHH_DTACOR    //16
	//////////////////////////////////////////////////////////
	
    //////////////////////
	// pular cabecalhos //
	//////////////////////
	cLinha := FT_FREADLN()
	aCampos := Separa(cLinha,";",.T.)
	FT_FSKIP()
	//cLinha := FT_FREADLN()
	//FT_FSKIP()
	//////////////////////////////////////////////
    nI := 0
	While !FT_FEOF()

		cLinha := FT_FREADLN()
		If !(EMPTY(STRTRAN(cLinha, ";", "")))
		   AAdd(aDados,Separa(cLinha,";",.T.))
		Else
			EXIT
		EndIf
        nI++            
        nLidos++		
	    ptinternal(1,'*** Lendo Linha = '+strzero(nLidos,9,0)+" de "+strzero(nQtdLinhas,9,0))
		
		If Len(aDados[ni][1]) < 8
		   s1 := 8 - Len(aDados[ni][1])
		   s2 := replicate("0",s1)+aDados[ni][1]
		   aDados[ni][1] := s2
		Endif

		If Len(aDados[ni][2]) < 6
		   s1 := 6 - Len(aDados[ni][2])
		   s2 := replicate("0",s1)+aDados[ni][2]
		   aDados[ni][2] := s2
		Endif
				
        C1:=STRTRAN(adados[nI][4],"R$"," ")
		C2:=STRTRAN(C1, ".", "")
		C3:=STRTRAN(C2, ",", ".")
        adados[nI][4] := val(c3)        

        C1:=STRTRAN(adados[nI][6],"R$"," ")
		C2:=STRTRAN(C1, ".", "")
		C3:=STRTRAN(C2, ",", ".")
        adados[nI][6] := val(c3)        
		
        C1:=STRTRAN(adados[nI][8],"R$"," ")
		C2:=STRTRAN(C1, ".", "")
		C3:=STRTRAN(C2, ",", ".")
        adados[nI][8] := val(c3)        

        C1:=STRTRAN(adados[nI][10],"R$"," ")
		C2:=STRTRAN(C1, ".", "")
		C3:=STRTRAN(C2, ",", ".")
        adados[nI][10] := val(c3)        
		
		FT_FSKIP()

	EndDo

Return 

Static Function Geralog(aRetorno,cArq1)
Local oExcel                                            
Local cTempPath:=GetTempPath()
Local cDirUsr  := __RELDIR
Local cDirSrv  := '\SPOOL\'
Local cArq2    := SUBSTR(cArq1,RAT("\", cArquivo)+1,LEN(cArq1))
Local cArq     := 'LOG_'+cArq2

CARQ4  := cDirSrv+cArq

nHandle4 := Fcreate(cArq4,0)		// cria o arquivo
If Ferror() != 0
   Conout("houve erro na criação do arquivo LOGEMPRE")
endif                        
cMsg := "IMPRAWRAZ LOG DE ERROS"+CRLF
FWrite(nHandle4,cMsg,Len(cMsg))    
cMsg := "FILIAL;MATRICULA;DESCRICAO ERRO"+CRLF
FWrite(nHandle4,cMsg,Len(cMsg))    
For nI := 1 to Len(aRetorno)       
    cMsg = ""
    cMsg = aRetorno[nI][1]+";"+aRetorno[nI][2]+";"+aRetorno[nI][4]+";"+CRLF
    FWrite(nHandle4,cMsg,Len(cMsg))    
Next
fclose (nHandle4)    

//CpyS2T(cDirSrv+cArq, cTempPath)
//
//oExcel:=MSExcel():New()
//oExcel:WorkBooks:Open(cTempPath+carq)
//oExcel:SetVisible(.T.)
//oExcel:Destroy()

Return

