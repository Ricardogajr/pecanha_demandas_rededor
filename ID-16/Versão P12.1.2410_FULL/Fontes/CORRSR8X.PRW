#Include "Protheus.ch"
#Include "TopConn.Ch" 

***********************
User Function CorrSR8X()
***********************
LOCAL nQTDREG := 0
DBSELECTAREA("SR8")  
DBSETORDER(1)
DBGOTOP()         
nQTDREG := SR8->(RECCOUNT())

   if nQTDREG > 0
      processa( {|| u_atuSR8X( nQTDREG ) }, "Efetuando Acerto SR8 (CORRSR8X)", "Aguarde...", .f.)
  	  MsgStop( "Atualização Foi Realizada.", "CORRSR8X" )

   endif

Return

************************
User Function AtuSR8X(nQtd1)
************************

procregua(nQtd1)

dbSelectArea("SR8")
dbSetOrder(1)
dbGotop()
While !SR8->( EOF() )
    Reclock("SR8",.F.)
    IF SR8->R8_TIPOAT = " " .OR.;
       SR8->R8_TIPOAT = "1" .OR.;
       SR8->R8_TIPOAT = "2" .OR.;
       SR8->R8_TIPOAT = "3" 
       CNADA := " "
    ELSE
       SR8->R8_TIPOAT := " " 
    ENDIF   
	SR8->(MsUnLock())
	SR8->( dbSkip() )
    incproc("Processando ...")	
End

Return
