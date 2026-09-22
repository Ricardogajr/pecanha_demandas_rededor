#include "totvs.ch"
#include "protheus.ch"
#include "topconn.ch"
/////////////////////////////////////////////////////
// CORRECAO TABELA SRD RETIRANDO VALORES NEGATIVOS //
/////////////////////////////////////////////////////
***********************
User Function UPD0231()
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

    MsAguarde({|lEnd| ImportDad()},"Aguarde...","Processando....",.T.)
    MsgStop( "Fim da Rotina", "UPD0231" )

Return

***************************
Static Function ImportDad()
***************************

	Local i 		  := 0
	Local j 		  := 0
	Local lRet		  := .T.
	Local aRetorno	  :={}
	Local lOk         := .T.
    Local cQry        := " "

	cMsg := '*** Filtrando Registros ****'
    MsProcTxt(cMsg)	
    ProcessMessage()
    
    cQry := "SELECT R_E_C_N_O_ AS REGISTRO1 FROM "+RETSQLNAME("SRD")+" SRD "
    cQry += "WHERE SRD.D_E_L_E_T_ = ''"
    cQry += "  AND SRD.RD_VALOR < 0 " 
	cQry += "  AND SRD.RD_PD IN('211','050','602') "
    cQry := changequery(cQry)
    TCQUERY cQry ALIAS "TSRD" NEW
    TSRD->(DBGOTOP())  
    nTotRegSRD := Contar("TSRD","!Eof()")
    nRecLido   := 0
    TSRD->(DBGOTOP())  
    WHILE TSRD->(!Eof())
       nRecLido ++
 	   cMsg := 'Processando = '+STRZERO(nRecLido,9,0)+" De "+STRZERO(nTotRegSRD,9,0)
       MsProcTxt(cMsg)	
       ProcessMessage()
       dbSelectArea( "SRD" )   
       dbGoTo(TSRD->(REGISTRO1))

       If (RD_PD = '211' .And. RD_VALOR < 0) .OR.;
	      (RD_PD = '050' .And. RD_VALOR < 0) .OR.;
		  (RD_PD = '602' .And. RD_VALOR < 0) 
		 ////////////////////////////////
         // SALVANDO REGISTRO ORIGINAL //
         ////////////////////////////////
          XX_FILIAL       := SRD->RD_FILIAL
          XX_MAT          := SRD->RD_MAT
          XX_PD           := SRD->RD_PD
          XX_DESCPD       := SRD->RD_DESCPD
          XX_TIPO1        := SRD->RD_TIPO1
          XX_QTDSEM       := SRD->RD_QTDSEM
          XX_HORINFO      := SRD->RD_HORINFO
          XX_HORAS        := SRD->RD_HORAS
          XX_VALINFO      := SRD->RD_VALINFO
          XX_VALOR        := SRD->RD_VALOR
          XX_VNAOAPL      := SRD->RD_VNAOAPL
          XX_DATARQ       := SRD->RD_DATARQ
          XX_DATPGT       := SRD->RD_DATPGT
          XX_CC           := SRD->RD_CC
          XX_SEQ          := SRD->RD_SEQ
          XX_EMPRESA      := SRD->RD_EMPRESA
          XX_TIPO2        := SRD->RD_TIPO2
          XX_VSTATUS      := SRD->RD_VSTATUS
          XX_STATUS       := SRD->RD_STATUS
          XX_INSS         := SRD->RD_INSS
          XX_IR           := SRD->RD_IR
          XX_FGTS         := SRD->RD_FGTS
          XX_PROCES       := SRD->RD_PROCES
          XX_PERIODO      := SRD->RD_PERIODO
          XX_SEMANA       := SRD->RD_SEMANA
          XX_ROTEIR       := SRD->RD_ROTEIR
          XX_DTREF        := SRD->RD_DTREF
          XX_POSTO        := SRD->RD_POSTO
          XX_MES          := SRD->RD_MES
          XX_NUMID        := SRD->RD_NUMID
          XX_DEPTO        := SRD->RD_DEPTO
          XX_NODIA        := SRD->RD_NODIA
          XX_DIACTB       := SRD->RD_DIACTB
          XX_PLNUCO       := SRD->RD_PLNUCO
          XX_CODB1T       := SRD->RD_CODB1T
          XX_ITEM         := SRD->RD_ITEM
          XX_CLVL         := SRD->RD_CLVL
          XX_EMPCONS      := SRD->RD_EMPCONS
          XX_IDCMPL       := SRD->RD_IDCMPL
          XX_CRITER       := SRD->RD_CRITER
          XX_SEQUE        := SRD->RD_SEQUE
          XX_LOTPLS       := SRD->RD_LOTPLS
          XX_CODRDA       := SRD->RD_CODRDA
          XX_VALORBA      := SRD->RD_VALORBA
          XX_CONVOC       := SRD->RD_CONVOC
	      AADD(aRetorno,{XX_FILIAL,XX_MAT,XX_DATARQ,XX_PD,"Nao","Registro da SRD Foi Excluido"})
         ////////////////////////////////////////////////		 
		 
		 Begin Transaction
             ///////////////////////////////////
             //  DELETANDO REGISTRO ANTERIOR  //
			 ///////////////////////////////////
			 RecLock( "SRD" , .F. )
             SRD->(dbDelete())
			 SRD->(MsUnlock())                                         
             ///////////////////////////////////

			 ////////////////////////////
             // CRIANDO NOVO REGISTRO  //
			 ////////////////////////////
              RecLock( "SRD" , .T. )
              SRD->RD_FILIAL       := XX_FILIAL
              SRD->RD_MAT          := XX_MAT
			  IF XX_PD = "211"
                 SRD->RD_PD           := "682"
                 SRD->RD_DESCPD       := "DESCONTO C/I(*)     "
			  ENDIF
			  IF XX_PD = "050"
                 SRD->RD_PD           := "666"
                 SRD->RD_DESCPD       := "ADIC NOT IND(*)     "
			  ENDIF
			  IF XX_PD = "602"
                 SRD->RD_PD           := "069"
                 SRD->RD_DESCPD       := "ARREDOND PROVENTO   "
			  ENDIF
              SRD->RD_TIPO1        := XX_TIPO1
              SRD->RD_QTDSEM       := XX_QTDSEM
              SRD->RD_HORINFO      := XX_HORINFO
              If XX_HORAS < 0
                 SRD->RD_HORAS     := XX_HORAS * (-1)
              Else	
                 SRD->RD_HORAS     := XX_HORAS
              Endif
              SRD->RD_VALINFO      := XX_VALINFO
              SRD->RD_VALOR        := XX_VALOR * (-1)
              SRD->RD_VNAOAPL      := XX_VNAOAPL
              SRD->RD_DATARQ       := XX_DATARQ
              SRD->RD_DATPGT       := XX_DATPGT
              SRD->RD_CC           := XX_CC
              SRD->RD_SEQ          := XX_SEQ
              SRD->RD_EMPRESA      := XX_EMPRESA
              SRD->RD_TIPO2        := XX_TIPO2
              SRD->RD_VSTATUS      := XX_VSTATUS
              SRD->RD_STATUS       := XX_STATUS
              SRD->RD_INSS         := XX_INSS
              SRD->RD_IR           := XX_IR
              SRD->RD_FGTS         := XX_FGTS
              SRD->RD_PROCES       := XX_PROCES
              SRD->RD_PERIODO      := XX_PERIODO
              SRD->RD_SEMANA       := XX_SEMANA
              SRD->RD_ROTEIR       := XX_ROTEIR
              SRD->RD_DTREF        := XX_DTREF
              SRD->RD_POSTO        := XX_POSTO
              SRD->RD_MES          := XX_MES
              SRD->RD_NUMID        := XX_NUMID
              SRD->RD_DEPTO        := XX_DEPTO
              SRD->RD_NODIA        := XX_NODIA
              SRD->RD_DIACTB       := XX_DIACTB
              SRD->RD_PLNUCO       := XX_PLNUCO
              SRD->RD_CODB1T       := XX_CODB1T
              SRD->RD_ITEM         := XX_ITEM
              SRD->RD_CLVL         := XX_CLVL
              SRD->RD_EMPCONS      := XX_EMPCONS
              SRD->RD_IDCMPL       := XX_IDCMPL
              SRD->RD_CRITER       := XX_CRITER
              SRD->RD_SEQUE        := XX_SEQUE
              SRD->RD_LOTPLS       := XX_LOTPLS
              SRD->RD_CODRDA       := XX_CODRDA
              SRD->RD_VALORBA      := XX_VALORBA
              SRD->RD_CONVOC       := XX_CONVOC
			  SRD->(MsUnlock())                                         
	          AADD(aRetorno,{SRD->RD_FILIAL,SRD->RD_MAT,SRD->RD_DATARQ,SRD->RD_PD,"Sim","Registro da SRD Foi Incluido"})
			  ////////////////////////////////////////////////		 
		  End Transaction
	   ENDIF
   	   TSRD->(DBSKIP())
    END      
	If !Empty(aRetorno)
		Aviso('Processamento Realizado!',"Verifique o log da importação \SPOOL\UPD0231.CSV", {'OK'}, 1)
        Geralog(aRetorno)
	EndIf
	
Return

Static Function Geralog(aRetorno)
Local oExcel                                            
Local cTempPath:=GetTempPath()
Local cDirUsr  := __RELDIR
Local cDirSrv  := '\SPOOL\'
Local cArq     := 'UPD0231.CSV'

CARQ4  := cDirSrv+cArq

nHandle4 := Fcreate(cArq4,0)		// cria o arquivo
If Ferror() != 0
   Conout("houve erro na criação do arquivo UPD0230.CSV")
endif                        
cMsg := "UPD0231 LOG DE PROCESSO"+CRLF
FWrite(nHandle4,cMsg,Len(cMsg))    
cMsg := "FILIAL;MATRICULA;FOLHA;VERBA;DESCRICAO ATIVIDADE"+CRLF
FWrite(nHandle4,cMsg,Len(cMsg))    
For nI := 1 to Len(aRetorno)       
    cMsg = ""
    cMsg = aRetorno[nI][1]+";"+aRetorno[nI][2]+";"+aRetorno[nI][3]+";"+aRetorno[nI][4]+";"+aRetorno[nI][6]+CRLF
    FWrite(nHandle4,cMsg,Len(cMsg))    
Next
fclose (nHandle4)    

Return
