#INCLUDE "PROTHEUS.CH"
#INCLUDE "TopConn.ch"
#include "RWMAKE.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "FILEIO.CH"
#include 'DIRECTRY.CH'
#INCLUDE "APWIZARD.CH"
#include "TCBROWSE.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³FUN‡…O    ³ DORZFZ3  ³ AUTOR ³ ROBERTO COSTA         ³ DATA ³ 29.05.2019 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³DESCRI‡…O ³ CARGA TABELA RFZ USANDO TABELA SRE                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ USO      ³ GENERICO                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
***********************
USER FUNCTION DORRFZ3()
***********************
    LOCAL nQTDREG    := 0
	Local cLinha 	 := ""
	Local lRet		 := .T.
	Local lPrim 	 := .F.
	Local cText 	 := OemToAnsi("Selecione o Arquivo de Importação:")
	Private aDados 	 := {}
    Private cArquivo := Space(150)
    Private lOk      := .F.
	Private lEnd     := .F.
		
    MsAguarde({|lEnd| LerSRE()},"Aguarde...","Lendo SRE...",.T.)
    MsgStop("Fim da Rotina","DORRFZ3")
	FT_FUSE()
	
RETURN

******************************
Static Function LerSRE(aDados)
******************************
    
	MsProcTxt("Lendo SRE... ")	
    
    nRegSRE := QtdRegSRE()
    nLidSRE := 0    
    dbSelectArea("SRE")
    dbSetOrder(1)
    dbGotop()	 

	While !SRE->(EOF())

	    CCNPJD := XBUSCASM0(SRE->RE_FILIALD)
	    CCNPJP := XBUSCASM0(SRE->RE_FILIALP)
        DBSELECTAREA("RFZ")  
        DBSETORDER(1)
	    IF (SUBSTR(CCNPJD,1,8) = SUBSTR(CCNPJP,1,8)) .AND. (SUBSTR(CCNPJD,9,4) <> SUBSTR(CCNPJP,9,4))
		   nreg:=BuskaRFZ(SRE->(RE_FILIALP),SRE->(RE_MATP),"2")
		   IF nreg=0                                                                                                
	          RECLOCK("RFZ",.T.)
              RFZ_FILIAL  := SRE->RE_FILIALP
              RFZ_MAT     := SRE->RE_MATP
              RFZ_TPADM   := '2'
              RFZ_INDADM  := '1'
              RFZ_INDPEM  := 'N'
              RFZ_CNPJAN  := CCNPJD
              RFZ_MATANT  := SRE->RE_MATD
              RFZ_DTADAN  := POSICIONE("SRA",1,ALLTRIM(SRE->RE_FILIALD)+ALLTRIM(SRE->RE_MATD),"RA_ADMISSA")
              RFZ_OBSVAN  := ' '
              RFZ_CNPJCE  := ' '
              RFZ_MATCED  := ' '
              RFZ_DTADCE  := CTOD("  /  /  ")
              RFZ_INFONU  := ' '
              RFZ_CATODS  := '101'
              RFZ_DTTRA   := SRE->RE_DATA                                            
		      MSUNLOCK()
		   ELSE
              RFZ->(dbGoto(nReg))
	          RECLOCK("RFZ",.F.)
              RFZ->RFZ_FILIAL  := SRE->RE_FILIALP
              RFZ->RFZ_MAT     := SRE->RE_MATP
              RFZ->RFZ_TPADM   := '2'
              RFZ->RFZ_INDADM  := '1'
              RFZ->RFZ_INDPEM  := 'N'
              RFZ->RFZ_CNPJAN  := CCNPJD
              RFZ->RFZ_MATANT  := SRE->RE_MATD
              RFZ->RFZ_DTADAN  := POSICIONE("SRA",1,ALLTRIM(SRE->RE_FILIALD)+ALLTRIM(SRE->RE_MATD),"RA_ADMISSA")
              RFZ->RFZ_OBSVAN  := ' '
              RFZ->RFZ_CNPJCE  := ' '
              RFZ->RFZ_MATCED  := ' '
              RFZ->RFZ_DTADCE  := CTOD("  /  /  ")
              RFZ->RFZ_INFONU  := ' '
              RFZ->RFZ_CATODS  := '101'
              RFZ->RFZ_DTTRA   := SRE->RE_DATA                                            
		      MSUNLOCK()
		   ENDIF
		ELSE
	      IF SUBSTR(CCNPJD,1,8) != SUBSTR(CCNPJP,1,8)
		     nreg:=BuskaRFZ(SRE->(RE_FILIALP),SRE->(RE_MATP),"4")
		    IF nreg=0                                                                                                
	          RECLOCK("RFZ",.T.)
              RFZ_FILIAL  := SRE->RE_FILIALP
              RFZ_MAT     := SRE->RE_MATP
              RFZ_TPADM   := '4'
              RFZ_INDADM  := '1'
              RFZ_INDPEM  := 'N'
              RFZ_CNPJAN  := CCNPJD
              RFZ_MATANT  := SRE->RE_MATD
              RFZ_DTADAN  := POSICIONE("SRA",1,ALLTRIM(SRE->RE_FILIALD)+ALLTRIM(SRE->RE_MATD),"RA_ADMISSA")
              RFZ_OBSVAN  := ' '
              RFZ_CNPJCE  := ' '
              RFZ_MATCED  := ' '
              RFZ_DTADCE  := CTOD("  /  /  ")
              RFZ_INFONU  := ' '
              RFZ_CATODS  := '101'
              RFZ_DTTRA   := SRE->RE_DATA                                            
		      MSUNLOCK()
            ELSE          
              RFZ->(dbGoto(nReg))
	          RECLOCK("RFZ",.F.)
              RFZ->RFZ_FILIAL  := SRE->RE_FILIALP
              RFZ->RFZ_MAT     := SRE->RE_MATP
              RFZ->RFZ_TPADM   := '4'
              RFZ->RFZ_INDADM  := '1'
              RFZ->RFZ_INDPEM  := 'N'
              RFZ->RFZ_CNPJAN  := CCNPJD
              RFZ->RFZ_MATANT  := SRE->RE_MATD
              RFZ->RFZ_DTADAN  := POSICIONE("SRA",1,ALLTRIM(SRE->RE_FILIALD)+ALLTRIM(SRE->RE_MATD),"RA_ADMISSA")
              RFZ->RFZ_OBSVAN  := ' '
              RFZ->RFZ_CNPJCE  := ' '
              RFZ->RFZ_MATCED  := ' '
              RFZ->RFZ_DTADCE  := CTOD("  /  /  ")
              RFZ->RFZ_INFONU  := ' '
              RFZ->RFZ_CATODS  := '101'
              RFZ->RFZ_DTTRA   := SRE->RE_DATA                                            
		      MSUNLOCK()
		    ENDIF
		  ENDIF
		ENDIF

        nLidSRE++	    
	    MsProcTxt("Lendo Registro "+STRZERO(nLidSRE,8,0)+" de "+strzero(nRegSRE,8,0))	

		dbSelectArea("SRE")
        dbSkip()	

	EndDo
Return 

*****************************
STATIC FUNCTION XBUSCASM0(CFIL) 
*****************************

LOCAL CCNPJ1        := ''
LOCAL AAREA			:= SM0->( GETAREA() )
LOCAL AAUX			:= {}
LOCAL ARETSM0		:= {}
LOCAL LFWLOADSM0	:= FINDFUNCTION( "FWLOADSM0" )
LOCAL LFWCODFILSM0 	:= FINDFUNCTION( "FWCODFIL" )

IF LFWLOADSM0
   ARETSM0	:= FWLOADSM0()
ELSE
	DBSELECTAREA( "SM0" )
		SM0->( DBGOTOP() )
		WHILE SM0->( !EOF() )
			AAUX := { 	SM0->M0_CODIGO,;
						IIF( LFWCODFILSM0, FWGETCODFILIAL, SM0->M0_CODFIL ),;
						"",;
						"",;
						"",;
						SM0->M0_NOME,;
						SM0->M0_FILIAL }

			AADD( ARETSM0, ACLONE( AAUX ) )
			SM0->( DBSKIP() )
		END
ENDIF
RESTAREA( AAREA ) 

N1 := 0
FOR N1 := 1 TO LEN(ARETSM0) 
   IF ALLTRIM(ARETSM0[N1][2]) == ALLTRIM(CFIL)
      CCNPJ1 := alltrim(ARETSM0[N1][18])
   ENDIF
NEXT 

RETURN (CCNPJ1)

*--------------------------*
Static Function BuskaRFZ(cFil1,cMat1,cTp1)
*--------------------------*  
	Local _cQuery3   := '' 
	Local _cAliasQr3 := ''
	Local nreg     := 0

  _cQuery3 := " SELECT R_E_C_N_O_ AS NUMREG" + CRLF    
  _cQuery3 += "  FROM " + RetSqlName('RFZ')        + CRLF 
  _cQuery3 += " WHERE D_E_L_E_T_ <> '*' "    + CRLF 
  _cQuery3 += "   AND RFZ_FILIAL = '"+cFil1   +"' "+ CRLF 
  _cQuery3 += "   AND RFZ_MAT = '"+cMat1   +"' "+ CRLF  
  _cQuery3 += "   AND RFZ_TPADM = '"+ cTp1+"' "+CRLF
  
  _cAliasQr3 := GetNextAlias()                                              
  
  If Select(  _cAliasQr3  ) > 0
		( _cAliasQr3 )->( DbCloseArea() )
  EndIf

  TcQuery _cQuery3 New Alias _cAliasQr3
  nreg := _cAliasQr3->NUMREG
  _cAliasQr3->( dbCloseArea() ) 
		  
Return ( nreg ) 
 
*--------------------------*
Static Function QtdRegSRE()
*--------------------------*  
	Local _cQuery3   := '' 
	Local _cAliasQr3 := ''
	Local nreg     := 0

  _cQuery3 := " SELECT count(1) AS NUMREG" + CRLF    
  _cQuery3 += "  FROM " + RetSqlName('SRE')        + CRLF 
  _cQuery3 += " WHERE D_E_L_E_T_ <> '*' "    + CRLF 
  
  _cAliasQr3 := GetNextAlias()                                              
  
  If Select(  _cAliasQr3  ) > 0
		( _cAliasQr3 )->( DbCloseArea() )
  EndIf

  TcQuery _cQuery3 New Alias _cAliasQr3
  nreg := _cAliasQr3->NUMREG
  _cAliasQr3->( dbCloseArea() ) 
		  
Return ( nreg ) 
