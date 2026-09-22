/*
	Descrição:
	O ponto de entrada ATFA012 inclui validação na rotina de Classificação de Compras.
*/
#include "Protheus.ch"
#Include 'FWMVCDef.ch'
#include 'parmtype.ch'
#INCLUDE "TBICONN.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "FILEIO.CH"
#INCLUDE "TRYEXCEPTION.CH"

User Function ATFA012()
Local aParam     := PARAMIXB
Local xRet       := .T.
Local oObj       := ''
Local cIdPonto   := ''
Local cIdModel   := ''
Local lIsGrid    := .F.

Local nLinha     := 0
//Local nQtdLinhas := 0
//Local cMsg       := ''
Local nPosHistor := 0 
Local cStatus    := SuperGetMV("FS_STATATF",.F., "1")
Local dDataclas  := SuperGetMV("FS_DATAATF",.F., dDataBase)
Local nPosStat   := 0   
Local nPosdClass := 0     
Local cUpd := ""
Local nRecno := 0 

if Empty(dDataclas)
    dDataclas := dDataBase
EndIf     

If Type("dDataclas") == "C"
    dDataclas := STOD(dDataclas)
EndIf 

If aParam <> NIL
      
       oObj       := aParam[1]
       cIdPonto   := aParam[2]
       cIdModel   := aParam[3]
       lIsGrid    := ( Len( aParam ) > 3 )
        
        If cIdPonto == 'MODELCOMMITNTTS' .and. FwIsInCallStack("MATA103")
                    //oSN1		:= oModel:GetModel('SN1MASTER')
                    //nPosStat      := aScan(aCab, {|x| AllTrim(x[1]) = "N1_STATUS"})
                    //nPosdClass    := aScan(aCab, {|x| AllTrim(x[1]) = "N1_DTCLASS"})
                    //oSN1:LoadValue('N1_DTCLASS', dDataBase)
                    //oSN1:LoadValue('N1_STATUS', "0")
                    
                    //If lIsGrid
                    //       nLinha     := oObj:nLine
                    //EndIf

                    nOpc := oObj:GetOperation() // PEGA A OPERAÇÃO

                    If nOpc == 3 
                    //    ATFA240(,.T.)
                        nRecno := SN1->(RECNO())
                       
                        cUpd:= " UPDATE "+RetSqlName("SN1")+" 
                        cUpd+= "    SET N1_STATUS = '"+cStatus+"' , N1_DTCLASS = '"+dtos(dDataclas)+"'"
                        cUpd+= "    WHERE R_E_C_N_O_ = "+cValtoChar(nRecno)

                        If TcSqlExec(cUpd) < 0
                            DisarmTransaction()
                            FWAlertError(TcSqlError(), "Erro na integração" )
                        EndIf	

                    EndIf 
                    /*
                            nPosHistor    := aScan(aHeader, {|x| x[2] = "N3_HISTOR"  }) 
                            If nPosHistor > 0 
                                    If !Empty(SN1->N1_DESCRIC)
                                        If Valtype(aCols[nLinha][nPosHistor]) <> "U"
                                                aCols[nLinha][nPosHistor] := SN1->N1_DESCRIC
                                        EndIf 
                                    EndIf 
                            EndIf 
                         
                        If nPosdClass > 0 
                            aCab[nPosdClass][2]  := dDataclas
                        EndIf 

                        If nPosStat > 0 
                            aCab[nPosStat][2]  := cStatus
                        EndIf 
                    EndIf 
                    */
                    //EndIf 
            EndIf 
	
EndIf 

Return xRet 
