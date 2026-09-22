#Include 'Protheus.ch'
/*
{Protheus.doc}  FA473CTA()
Ponto de entrada na importação do arquivo de conciliação automática, para utilizar o banco/agencia/conta definido nos parâmetros
para busca na SA6.  
@Author  Ramon Teodoro e Silva	
@Since   12/07/2019       
@Version P12.7
*/

User Function FA473CTA()

Local aRet    := {}
Local cCodBco := Paramixb[1]
Local cCodAge := Paramixb[2]
Local cCodCta := Paramixb[3]

Aadd( aRet, SEE->EE_CODIGO )
Aadd( aRet, SEE->EE_AGENCIA ) 
Aadd( aRet, SEE->EE_CONTA )

Return aRet

