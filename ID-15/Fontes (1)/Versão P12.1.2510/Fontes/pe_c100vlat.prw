#Include 'TOTVS.ch'
/*
Ponto de entrada criado para permitir alterações apenas em contratos em Elaboração ou Revisão.
@Author Thiago Pereira
@Since  01.07.2019
*/

User Function C100VLAT()

	Local cSituac := paramixb[1] //Situacao do Contrato


//Permite alteracao se o status for Em Elaboracao ou Em Revisao
Return (cSituac $ '02,09,11')
