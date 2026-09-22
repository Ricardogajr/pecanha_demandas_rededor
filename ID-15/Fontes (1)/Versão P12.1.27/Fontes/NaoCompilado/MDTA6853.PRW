#Include 'Protheus.ch'

User Function MDTA6853()

Local aAfasta := {}
dbSelectArea("TNP")
dbSetOrder(1)
If dbSeek(TNY->TNY_FILIAL+TNY->TNY_EMITEN) 
      aAdd( aAfasta , { "R8_NMMED"  , TNP->TNP_NOME} )    
      aAdd( aAfasta , { "R8_CRMMED" , TNP->TNP_NUMENT } )    
      aAdd( aAfasta , { "R8_UFCRM"  , TNP->TNP_UF } )    
      aAdd( aAfasta , { "R8_TPEFD" , TNY->TNY_TPEFD } )    
      IF TNP->TNP_ENTCLA = "CRM"	
         aAdd( aAfasta , { "R8_IDEOC" , "1" } )    
      ENDIF
      IF TNP->TNP_ENTCLA = "CRO"	
         aAdd( aAfasta , { "R8_IDEOC" , "2" } )    
      ENDIF 
      IF TNP->TNP_ENTCLA = "RMS"	
         aAdd( aAfasta , { "R8_IDEOC" , "3" } )    
      ENDIF
      aAdd( aAfasta , { "R8_TIPOAT" , TNY->TNY_XTPAT } )    
      aAdd( aAfasta , { "R8_ORIGALT" , TNY->TNY_ORIALT } )    
      aAdd( aAfasta , { "R8_TPPROC" , TNY->TNY_XTPPRO } )    
      aAdd( aAfasta , { "R8_NRPRCJU" , TNY->TNY_NPRCJU } )    

ELSE
   aAdd( aAfasta , { "R8_NMMED"  , "RENATA SANCHEZ"} )    
   aAdd( aAfasta , { "R8_CRMMED" , "52651079      "} )    
   aAdd( aAfasta , { "R8_UFCRM"  , "RJ"} )    
   aAdd( aAfasta , { "R8_TPEFD" , TNY->TNY_TPEFD } )    
   aAdd( aAfasta , { "R8_IDEOC" , "1" } )    
   aAdd( aAfasta , { "R8_TIPOAT" , TNY_XTPAT } )    
   aAdd( aAfasta , { "R8_ORIGALT" , TNY->TNY_ORIALT } )    
   aAdd( aAfasta , { "R8_TPPROC" , TNY->TNY_XTPPRO } )    
   aAdd( aAfasta , { "R8_NRPRCJU" , TNY->TNY_NPRCJU } )    
Endif

Return aAfasta