#INCLUDE "PROTHEUS.CH"

User Function DEPARATNY( CCOD1 )

   Local lRet := ''

   If ALLTRIM(CCOD1) = '003' .OR. ;
	  ALLTRIM(CCOD1) = '020'
	  lRet := '01'
   ENDIF	  

   If ALLTRIM(CCOD1) = '004' .OR. ;
      ALLTRIM(CCOD1) = '019' .OR. ;
	   ALLTRIM(CCOD1) = '022' // ticket n° 8773019  - para novo tipo de afast. 022 - COVID-19
	 
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
	   ALLTRIM(CCOD1) = '008' .OR. ;
	   ALLTRIM(CCOD1) = '023' .OR. ; // Thais Paiva - 11606765
	   ALLTRIM(CCOD1) = '024'        // Mauricio Siqueira - 06/09/24 INC0577405
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
