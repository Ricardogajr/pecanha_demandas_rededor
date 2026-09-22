#Include 'Protheus.ch'

/*
{Protheus.doc}  TEWBTYP3()
Rotina de Pré-Nota Específico, criada para fazer a chamada da rotina padrão porém filtrando apenas os documentos gerados
pela rotina de solicitação de pagamento (ver PE MT140FIL). 
@Author  Ramon Teodoro e Silva	
@Since   21/11/2017       
@Version P12.7
*/

User Function TEWBTYP3()

Local lRet := .t.

MATA140()

Return lRet
