#INCLUDE 'TOTVS.CH'


/*/{Protheus.doc} User Function F390CBX
    Ponto localizado no cancelamento do cheque, depois de remover do título
    @type  Function
    @author Paulo Dias
    @since 13/01/2022
    /*/
User Function F390CBX()

Local cUsrAlt :=  UsrFullName(__cuserid)
       
// ticket n° 12912589
DbSelectArea("SE5")

RecLock("SE5",.F.)
SE5->E5_XLOGMOV  := cUsrAlt
SE5->E5_XHORMOV  := TIME() 
SE5->E5_XDATMOV  := DATE() 

MsUnLock()


Return
