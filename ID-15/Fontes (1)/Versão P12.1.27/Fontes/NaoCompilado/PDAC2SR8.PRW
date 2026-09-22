#Include "Protheus.ch"
#Include "TopConn.Ch" 

************************
User Function PDAC2SR8()
************************
LOCAL nQTDREG := 0
DBSELECTAREA("TNY")  
DBSETORDER(1)
DBGOTOP()         
nQTDREG := TNY->(RECCOUNT())

   if nQTDREG > 0
      processa( {|| u_atual2SR8( nQTDREG ) }, "PDAC2SR8 - Efetuando Acerto SR8", "Aguarde...", .F.)
	  MsgStop( "Atualizacao Foi Realizada.", "PDAC2SR8" )
   endif

Return

******************************
User Function Atual2SR8(nQtd1)
******************************

procregua(nQtd1)

dbSelectArea("TNY")
dbSetOrder(1)
dbGotop()
While !TNY->( EOF() )
         
    IF TNY->TNY_NUMFIC = "102017001"
       NADA := "PARADA"
    ENDIF
    
    dbSelectArea("TM0")
    dbSetOrder(1)
    IF dbSeek(TNY->TNY_FILIAL+TNY->TNY_NUMFIC) 

	If !Empty(TNY->TNY_DTSAI3)
	    nReg := U_busca2sr8(TM0->TM0_FILIAL,TM0->TM0_MAT,TNY->TNY_DTSAI3,TNY->TNY_CODAFA)
		dbSelectArea("SR8")
		dbSetOrder(1)
		If nReg > 0
			U_DADOS2SR8(nReg)
		Endif
	Endif
	If !Empty(TNY->TNY_DTSAI2)
	    nReg := U_busca2sr8(TM0->TM0_FILIAL,TM0->TM0_MAT,TNY->TNY_DTSAI2,TNY->TNY_CODAFA)
		dbSelectArea("SR8")
		dbSetOrder(1)
		If nReg > 0
			U_DADOS2SR8(nReg)
		Endif
	Endi
	If !Empty(TNY->TNY_DTINIC)
	    nReg := U_busca2sr8(TM0->TM0_FILIAL,TM0->TM0_MAT,TNY->TNY_DTINIC,TNY->TNY_CODAFA)
		dbSelectArea("SR8")
		dbSetOrder(1)
		If nReg > 0
			U_DADOS2SR8(nReg)
		Endif
   	Endif

    Endif
    
    dbSelectArea("TNY")
    dbSetOrder(1)
	TNY->( dbSkip() )
    incproc("Processando ...")	
		
End

Return

**********************************************
User Function Busca2sr8(cFil,cMat,dDtini,ctip)
**********************************************
Local nReg1   := 0
Local cQry := " "

cQry := "SELECT SR8.R_E_C_N_O_ REGISTRO1 "
cQry += "  FROM " + RetSqlName("SR8") + " SR8 " 
cQry += " WHERE SR8.R8_FILIAL = '"+cFil+"' "
cQry += "   AND SR8.R8_MAT = '"+cMat+"' "
cQry += "   AND SR8.R8_DATAINI = '"+dTos(dDtini)+"' "
cQry += "   AND SR8.R8_TIPOAFA = '"+cTip+"' "

TCQUERY cQry ALIAS "TSR8" NEW
dbSelectArea("TSR8")
If !TSR8->(EOF())
    nReg1 := TSR8->(REGISTRO1) 
Endif	
TSR8->(DBCLOSEAREA())

Return nReg1

*****************************
User Function Dados2Sr8(nRg1)
*****************************

    SR8->(Dbgoto(nRg1))
    Reclock("SR8",.F.)
    If Empty(SR8->R8_TPEFD)	
       SR8->R8_TPEFD	:= U_DEPARA2(SR8->R8_TIPOAFA)		
	Endif
	dbSelectArea("TNP")
	dbSetOrder(1)
	If dbSeek(TNY->TNY_FILIAL+TNY->TNY_EMITEN)
       SR8->R8_NMMED	:= TNP->TNP_NOME		
       SR8->R8_CRMMED	:= TNP->TNP_NUMENT		
       SR8->R8_UFCRM	:= TNP->TNP_UF	
       SR8->R8_IDEOC	:= " "
       IF TNP->TNP_ENTCLA = "CRM"	
          SR8->R8_IDEOC	:= "1"
       ENDIF
       IF TNP->TNP_ENTCLA = "CRO"	
          SR8->R8_IDEOC	:= "2"
       ENDIF 
       IF TNP->TNP_ENTCLA = "RMS"	
          SR8->R8_IDEOC	:= "3"
       ENDIF 
    Endif

	SR8->(MsUnLock())
	
Return

*******************************
User Function DEPARA2( CCOD1 )
*******************************

   Local lRet := ''

   If ALLTRIM(CCOD1) = '003' .OR. ;
	  ALLTRIM(CCOD1) = '020'
	  lRet := '01'
   ENDIF	  

   If ALLTRIM(CCOD1) = '004' .OR. ;
	  ALLTRIM(CCOD1) = '019' 
	  lRet := '03'
   ENDIF	  
		
   If ALLTRIM(CCOD1) = '017'	                                                	
	  lRet := '06'
   ENDIF	
		
   If ALLTRIM(CCOD1) = '018'	                                                	
	  lRet := '10'
   ENDIF	
		
   If ALLTRIM(CCOD1) = '001' .OR. ;
      ALLTRIM(CCOD1) = '002' 	                                                	
	  lRet := '15'
   ENDIF	

   If ALLTRIM(CCOD1) = '015'  	                                                	
	  lRet := '16'
   ENDIF	

   If ALLTRIM(CCOD1) = '006' .OR. ;
      ALLTRIM(CCOD1) = '007' 
	  lRet := '17'
   ENDIF	  
   
   If ALLTRIM(CCOD1) = '009'  	                                                	
	  lRet := '19'
   ENDIF	

   If ALLTRIM(CCOD1) = '010' .OR. ;
      ALLTRIM(CCOD1) = '011' .OR. ;
	  ALLTRIM(CCOD1) = '012' 
	  lRet := '20'
   ENDIF	  

   If ALLTRIM(CCOD1) = '014'  	                                                	
	  lRet := '21'
   ENDIF	
		
   If ALLTRIM(CCOD1) = '013' .OR. ;
	  ALLTRIM(CCOD1) = '021' 
	  lRet := '24'
   ENDIF	  
		
   If ALLTRIM(CCOD1) = '005'  	                                                	
	  lRet := '29'
   ENDIF	

   If ALLTRIM(CCOD1) = '008'  	                                                	
	  lRet := '35'
   ENDIF	

RETURN lRet
