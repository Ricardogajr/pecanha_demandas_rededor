#INCLUDE "PROTHEUS.CH"


/*/{Protheus.doc} F050MDVC
Customização da data de vecimento do imposto
@type function
@version 12.1.27
@author paulo.dias
@since 11/10/2021
@return Data de Vencimento
/*/
User Function F050MDVC()

Local dNextDay := ParamIxb[1]

If Paramixb[6] == '9478' ; 
    .AND. SC7->C7_XDOC == SE2->E2_NUM ; 
    .AND. SC7->C7_XDTEMI == SE2->E2_EMISSAO ; 
    .AND. SC7->C7_FILIAL == SE2->E2_FILIAL
    
    dNextDay := ParamIxb[5]
EndIf

Return dNextDay
