#Include "Protheus.ch"
#Include "TopConn.Ch" 
#include "RWMAKE.CH"
#INCLUDE "TBICONN.CH"

///////////////////////////////////////////////////////////////////////////////////////
// ROTINA ATUALIZA O CAMPO R8_TPEFD REFERENTE AO AFASTAMENTO POR LICENCA MATERNIDADE //
///////////////////////////////////////////////////////////////////////////////////////

************************
User Function PDAC3SR8()
************************
LOCAL nQTDREG := 0

lSchedule := Type("oMainWnd") == "U" //
If lSchedule
   PREPARE ENVIRONMENT EMPRESA "01" FILIAL "01010001" 
Endif

DBSELECTAREA("SR8")  
DBSETORDER(1)
DBGOTOP()         
nQTDREG := SR8->(RECCOUNT())
if nQTDREG > 0
   If lSchedule
      u_atual3SR8( nQTDREG )
   Else
      processa( {|| u_atual3SR8( nQTDREG ) }, "PDAC3SR8 - Atualizando R8_TPEFD Ref.Licenca Maternidade", "Aguarde...", .F.)
      MsgStop( "Atualizacao Foi Realizada.", "PDAC3SR8" )
   Endif
endif

If lSchedule
   RESET ENVIRONMENT 
Endif

Return

******************************
User Function Atual3SR8(nQtd1)
******************************

If lSchedule
   cnada := ""
Else
   procregua(nQtd1) 
endif

dbSelectArea("SR8")
dbSetOrder(1)
dbGotop()
While !SR8->( EOF() )
         
    IF SR8->R8_TIPOAFA $("006;007;008;009;010;011;012")
       Reclock("SR8",.F.)
   	   SR8->R8_TPEFD := U_DEPARA3(SR8->R8_TIPOAFA)		
	   SR8->(MsUnLock())
    ENDIF
    
	SR8->( dbSkip() )
    If lSchedule
       cnada := ""
	Else
	   incproc("Processando ...")	
	Endif	
End

Return

///////////////////////////////
User Function DEPARA3( CCOD1 )
///////////////////////////////

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
      ALLTRIM(CCOD1) = '007' .OR. ;
	  ALLTRIM(CCOD1) = '008' 
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

RETURN lRet
