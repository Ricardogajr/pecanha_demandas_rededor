#Include "PROTHEUS.CH"
/*{Protheus.doc} CN130PGRV()
Ponto de entrada na gravação da Medição de Contrato.
@Author	Paulo Krüger
@Since		09/06/2017
@Version	P12.7
@Project    MAN00000462901_EF_001 
@Return		Nil*/ 
 
#INCLUDE "PROTHEUS.CH"
#include 'parmtype.ch'   

user function CNTA130()

    Local aParam   := PARAMIXB
    Local oModel   := FwModelActive()
    Local oObj     := ""
    Local cIdPonto := ""
    Local cIdModel := ""
    Local lIsGrid  := .F.
    Local xRet     := .T.
    Local c_FunName	:= Upper(Alltrim(Funname()))
    Local aArea	:= GetArea()
    Local a_AreaCN9	:= CN9->(GetArea())
    Local a_Rateio	:= {}
    Local a_Campos	:= {}
    Local aAreaCN9	:= CN9->(GetArea())
    Local aAreaCNC	:= CNC->(GetArea())
    Local aAreaCNE  := CNE->(GetArea())
    Local aAreaSA1	:= SA1->(GetArea())
    Local aAreaSA2	:= SA2->(GetArea())
    Local aAreaCN1	:= CN1->(GetArea())
    Local nX		:= 0
    Local nY		:= 0
    Local a_Rat		:= 0
    Local n_PosRat	:= 9
    Local c_FilCTT	:= xFilial("CTT")

    Private l_Servic	:= .F.
    
    // VERIFICA SE APARAM NÃO ESTÁ NULO
    If aParam <> NIL
        oObj := aParam[1] 	
        cIdPonto := aParam[2]
        cIdModel := aParam[3]
        lIsGrid := (Len(aParam) > 3)
         
        //  VERIFICA SE O PONTO EM QUESTÃO É O FORMPOS
        If cIdPonto == "FORMCOMMITTTSPOS"
            //CN130PGRV.PRW
			U_F1200715(Paramixb[01]) //Ajusta Flag da Medição de Contrato
		ElseIf cIdPonto == 'MODELPOS'
            //CN130TOK.PRW
		EndIf
    EndIf
Return xRet





Return
