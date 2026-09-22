#INCLUDE 'TOTVS.CH'
#INCLUDE "PROTHEUS.CH"

/*
{Protheus.doc}  FA473CTA()
Ponto de entrada na importação do arquivo de conciliação automática, para utilizar o banco/agencia/conta definido nos parâmetros
para busca na SA6.  
@Author  Ramon Teodoro e Silva	
@Since   12/07/2019       
@Version P12.7
*/
/*
User Function FA473CTA()

Local aRet    := {}
Local cCodBco := Paramixb[1]
Local cCodAge := Paramixb[2]
Local cCodCta := Paramixb[3]

Aadd( aRet, SEE->EE_CODIGO )
Aadd( aRet, SEE->EE_AGENCIA ) 
Aadd( aRet, SEE->EE_CONTA )

Return aRet*/



  
/*/{Protheus.doc} F474CTA
Ajustar informações bancárias para a busca dos registros a conciliar // PE FA473CT descontinuado
@type       Function
@author     Jonathan Gabriel
@since      13/06/2025
@return     Nil
/*/
User Function F474CTA()
    Local cBanco    := paramixb[1]
    Local cAgencia  := paramixb[2]
    Local cConta    := paramixb[3]
    Local aRet := {}
     
    aRet := {SEE->EE_CODIGO, SEE->EE_AGENCIA, SEE->EE_CONTA}
 
Return aRet
