#Include 'Protheus.ch'

/*
{Protheus.doc}  F240SUM()
PE para adicionar a multa ao valor do título na geração do arquivo SISPAG 
@Author  Ramon Teodoro e Silva	
@Since   27/01/2017       
@Version P12.7
*/

User Function F240SUM()

Local nRet

//If SE2->E2_FORMPAG $ "17|16" // ticket n° 6917175 - 415966 - Paulo Dias - Validação comentada para que efetue o cálculo, conforme atualização do projeto
	nRet := SE2->E2_SALDO+SE2->E2_SDACRES+SE2->E2_MULTA+SE2->E2_JUROS-SE2->E2_SDDECRE
//Else
//	nRet := SE2->E2_SALDO+SE2->E2_SDACRES-SE2->E2_SDDECRE
//EndIf

Return nRet
