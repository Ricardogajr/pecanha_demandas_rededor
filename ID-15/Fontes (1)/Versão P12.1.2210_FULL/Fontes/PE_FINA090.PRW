 #include 'TOTVS.CH'
 
/*/{Protheus.doc} FINA090 
Ponto de entrada executado na saida da funcao de baixa automática, apos gravar todos os dados e apos a contabilizacao.
@type User function
@author Paulo Krüger
@since 17/03/2017
@version 12.7
@project MAN0000007423041_EF_029
@return NIL
/*/

User Function FINA090() 
Local aArea := GetArea()

//Bloqueio de Notas Fiscais de Entrada
U_F0702901(SE2->E2_XID)

RestArea(aArea)

Return