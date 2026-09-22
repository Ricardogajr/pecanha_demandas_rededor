#include "totvs.ch"
#include "protheus.ch"
#include "topconn.ch"
///////////////////////////////////////////////////
// CARGA NA TABELA SRB PROTHEUS 12 VIA PLANILHA. //
///////////////////////////////////////////////////
***********************
User Function UPD0275()
***********************

	Local cLinha 	 := ""
	Local lRet		 := .T.
	Local lPrim 	 := .F.
	Local cText 	 := OemToAnsi("Selecione o Arquivo de Importação:")
	Private aCampos  := {}
	Private aDados 	 := {}
    Private cArquivo := Space(150)
    Private lOk      :=.F.
	Private nLidos  := 0
	Private nProce  := 0

    Define MsDialog oDlg Title "UPD0275 - Selecionar Arquivo para Carga" From 08,15 To 19,120 Of GetWndDefault()
      
    @ 18,16  Say 	"Diretorio:" 	Size 050,10 Of oDlg Pixel
    @ 18,40  MsGet 	cArquivo 		Size 230,08 Of oDlg Pixel
    @ 18,275 Button "..." 			Size 010,10 Action Eval({|| cArquivo:=u_SelectFile() }) Of oDlg Pixel
    @ 18,310 Button "OK"            Size 040,20 Action Eval({|| If(u_ValidaDir(cArquivo), (lOk:=.T.,oDlg:End()) ,)}) Of oDlg Pixel
    @ 18,355 Button "CANCEL"        Size 040,20 Action Eval({|| lOk:=.F.,oDlg:End() }) Of oDlg Pixel
    Activate MsDialog oDlg //Centered On Init (EnchoiceBar(oDlg,bOk,bCancel))

    If lOk
       MsAguarde({|lEnd| LerArq(aDados)},"Aguarde...","Lendo Planilha",.T.)
       MsAguarde({|lEnd| ImportDad(aDados)},"Aguarde...","Processando Planilha",.T.)
       MsgStop( "Fim da Rotina", "UPD0275" )
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
    Local nPos_FILIAL  := aScan(aCampos,{ |x| Upper(AllTrim(x)) == "RFZ_FILIAL" })
    Local nPos_MAT     := aScan(aCampos,{ |x| Upper(AllTrim(x)) == "RFZ_MAT" })
    Local nPos_TPADM   := aScan(aCampos,{ |x| Upper(AllTrim(x)) == "RFZ_TPADM" })
    Local nPos_INDADM  := aScan(aCampos,{ |x| Upper(AllTrim(x)) == "RFZ_INDADM" })
    Local nPos_INDPEM  := aScan(aCampos,{ |x| Upper(AllTrim(x)) == "RFZ_INDPEM" })
    Local nPos_CNPJAN  := aScan(aCampos,{ |x| Upper(AllTrim(x)) == "RFZ_CNPJAN" })
    Local nPos_MATANT  := aScan(aCampos,{ |x| Upper(AllTrim(x)) == "RFZ_MATANT" })
    Local nPos_DTADAN  := aScan(aCampos,{ |x| Upper(AllTrim(x)) == "RFZ_DTADAN" })
    Local nPos_OBSVAN  := aScan(aCampos,{ |x| Upper(AllTrim(x)) == "RFZ_OBSVAN" })
    Local nPos_CNPJCE  := aScan(aCampos,{ |x| Upper(AllTrim(x)) == "RFZ_CNPJCE" })
    Local nPos_MATCED  := aScan(aCampos,{ |x| Upper(AllTrim(x)) == "RFZ_MATCED" })
    Local nPos_DTADCE  := aScan(aCampos,{ |x| Upper(AllTrim(x)) == "RFZ_DTADCE" })
    Local nPos_INFONU  := aScan(aCampos,{ |x| Upper(AllTrim(x)) == "RFZ_INFONU" })
    Local nPos_CATODS  := aScan(aCampos,{ |x| Upper(AllTrim(x)) == "RFZ_CATODS" })
    Local nPos_ONUS    := aScan(aCampos,{ |x| Upper(AllTrim(x)) == "RFZ_ONUS" })
    Local nPos_CATEG   := aScan(aCampos,{ |x| Upper(AllTrim(x)) == "RFZ_CATEG" })
    Local nPos_DTTRA   := aScan(aCampos,{ |x| Upper(AllTrim(x)) == "RFZ_DTTRA" })
	Local cDirSrv  := '\SPOOL\'
    Local cArq     := 'UPD0275.CSV'
    CARQ4  := cDirSrv+cArq
    nHandle4 := Fcreate(cArq4,0)		// cria o arquivo
    If Ferror() != 0
       Conout("houve erro na criação do arquivo UPD0275.CSV")
    endif                        
    cMsg := "UPD0275 LOG DE PROCESSO"+CRLF
    FWrite(nHandle4,cMsg,Len(cMsg))    
    cMsg := "RFZ_FILIAL;RFZ_MAT;RFZ_TPADM;RFZ_INDADM;RFZ_INDPEM;RFZ_CNPJAN;RFZ_MATANT;RFZ_DTADAN;RFZ_OBSVAN;RFZ_CNPJCE;RFZ_MATCED;RFZ_DTADCE;RFZ_INFONU;RFZ_CATODS;RFZ_DTTRA;STATUS"+CRLF
    FWrite(nHandle4,cMsg,Len(cMsg))    

	
	ProcRegua(LEN(ADADOS))
    dbSelectArea("RFZ")
	dbSetOrder(1) 

	For i:=1 to Len(aDados)
        nproce++
	    FWMonitorMsg('*** Processando Linha = '+strzero(nproce,9,0)+" de "+strzero(nLidos,9,0))
  	    cMsg := '*** Processando Linha = '+strzero(nproce,9,0)+" de "+strzero(nLidos,9,0)
        MsProcTxt(cMsg)	
        ProcessMessage()
		    if len(aDados[i,nPos_FILIAL]) > 0
            cFil   := adados[i,nPos_FILIAL]
			cMat   := adados[i,nPos_MAT]
			cTpAdm := adados[i,nPos_TPADM]
			
			dbGoTop() 
 	        If dbSeek(cFil+cMat+cTpAdm) 
 	           Reclock("RFZ",.F.)
            Else
 	           Reclock("RFZ",.T.) 
	        Endif   
			
            RFZ_FILIAL  := adados[i,nPos_FILIAL ]
            RFZ_MAT     := adados[i,nPos_MAT    ]
            RFZ_TPADM   := adados[i,nPos_TPADM  ]
            RFZ_INDADM  := adados[i,nPos_INDADM ]
            RFZ_INDPEM  := adados[i,nPos_INDPEM ]
            RFZ_CNPJAN  := adados[i,nPos_CNPJAN ]
            RFZ_MATANT  := adados[i,nPos_MATANT ]
            RFZ_DTADAN  := CTOD(adados[i,nPos_DTADAN ])
		    MSMM(RFZ_OBSVAN,,,adados[i,nPos_OBSVAN ],1,,,"RFZ","RFZ_OBSVAN")   
            RFZ_CNPJCE  := adados[i,nPos_CNPJCE ]
            RFZ_MATCED  := adados[i,nPos_MATCED ]
            RFZ_DTADCE  := CTOD(adados[i,nPos_DTADCE ])
            RFZ_INFONU  := adados[i,nPos_INFONU ]
            RFZ_CATODS  := adados[i,nPos_CATODS ]
            RFZ_ONUS    := adados[i,nPos_ONUS   ]
            RFZ_CATEG   := adados[i,nPos_CATEG  ]
            RFZ_DTTRA   := CTOD(adados[i,nPos_DTTRA  ])
			
            MSUNLOCK()
			
            CmSG := adados[i,nPos_FILIAL ] +";"+;
                    adados[i,nPos_MAT    ] +";"+;
                    adados[i,nPos_TPADM  ] +";"+;
                    adados[i,nPos_INDADM ] +";"+;
                    adados[i,nPos_INDPEM ] +";"+;
                    adados[i,nPos_CNPJAN ] +";"+;
                    adados[i,nPos_MATANT ] +";"+;
                    adados[i,nPos_DTADAN ] +";"+;
		            adados[i,nPos_OBSVAN ] +";"+;
                    adados[i,nPos_CNPJCE ] +";"+;
                    adados[i,nPos_MATCED ] +";"+;
                    adados[i,nPos_DTADCE ] +";"+;
                    adados[i,nPos_INFONU ] +";"+;
                    adados[i,nPos_CATODS ] +";"+;
                    adados[i,nPos_ONUS   ] +";"+;
                    adados[i,nPos_CATEG  ] +";"+;
                    adados[i,nPos_DTTRA  ] +";"+;
					"REGISTRO ATUALIZADO "+CRLF
					
            FWrite(nHandle4,cMsg,Len(cMsg))    
					
			
		Endif
	Next i
    fclose(nHandle4)
	If !Empty(aRetorno)
		Aviso('Processamento Realizado!',"Verifique o log da importação \SPOOL\UPD0275.CSV", {'OK'}, 1)
	EndIf
	
Return

******************************
Static Function LerArq(aDados)
******************************

	Local cLinha 	:= ""
	Local lPrim 	:= .F.
	
	FT_FUSE(cArquivo)
	ProcRegua(FT_FLASTREC())
	nQtdLinhas := FT_FLASTREC()
	FT_FGOTOP()
    //////////////////////
	// pular cabecalhos //
	//////////////////////
	cLinha := FT_FREADLN()
	aCampos := Separa(cLinha,";",.T.)
	FT_FSKIP()
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
	    FWMonitorMsg('*** Lendo Linha = '+strzero(nLidos,9,0)+" de "+strzero(nQtdLinhas,9,0))
  	    cMsg := '*** Lendo Linha = '+strzero(nLidos,9,0)+" de "+strzero(nQtdLinhas,9,0)
        MsProcTxt(cMsg)	
        ProcessMessage()
        FT_FSKIP()

	EndDo

Return 

Static Function Geralog(aRetorno)
Local oExcel                                            
Local cTempPath:=GetTempPath()
Local cDirUsr  := __RELDIR
Local cDirSrv  := '\SPOOL\'
Local cArq     := 'UPD0275.CSV'
CARQ4  := cDirSrv+cArq
nHandle4 := Fcreate(cArq4,0)		// cria o arquivo
If Ferror() != 0
   Conout("houve erro na criação do arquivo UPD0275.CSV")
endif                        
cMsg := "UPD0275 LOG DE PROCESSO"+CRLF
FWrite(nHandle4,cMsg,Len(cMsg))    
cMsg := "RFZ_FILIAL;RFZ_MAT;RFZ_TPADM;RFZ_INDADM;RFZ_INDPEM;RFZ_CNPJAN;RFZ_MATANT;RFZ_DTADAN;RFZ_OBSVAN;RFZ_CNPJCE;RFZ_MATCED;RFZ_DTADCE;RFZ_INFONU;RFZ_CATODS;RFZ_DTTRA;STATUS"+CRLF



FWrite(nHandle4,cMsg,Len(cMsg))    
For nI := 1 to Len(aRetorno)       
    cMsg := ""
    cMsg :=aRetorno[nI][1]+";"+;
           aRetorno[nI][2]+";"+;
           aRetorno[nI][3]+";"+;
           aRetorno[nI][4]+";"+;
           aRetorno[nI][5]+";"+;
           aRetorno[nI][6]+";"+;
           aRetorno[nI][7]+";"+;
           aRetorno[nI][8]+";"+;
           aRetorno[nI][9]+";"+;
           aRetorno[nI][10]+";"+;
           aRetorno[nI][11]+";"+;
           aRetorno[nI][12]+";"+;
           aRetorno[nI][13]+";"+;
           aRetorno[nI][14]+";"+;
           aRetorno[nI][15]+";"+;
           aRetorno[nI][16]+";"+CRLF
    FWrite(nHandle4,cMsg,Len(cMsg))    
Next
fclose (nHandle4)    

Return
