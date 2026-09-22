#Include 'Protheus.ch' 
#Include 'TopConn.Ch'

//////////////////////////////////////////////////////////////////////////////////////
//+--------------------------------------------------------------------------------+//
//| PROGRAMA  | FA550REP | AUTORA| Thais Paiva              | DATA | 08/09/2021    |//
//+--------------------------------------------------------------------------------+//
//| DESCRICAO  | Ponto de Entrada que permite a gravação de dados complementares na|//
//|            | reposição do Caixinha. É chamado após a reposição do Caixinha e   |//
//|            | sua contabilização.											   |//
//+--------------------------------------------------------------------------------+//
//| CHAMADO    | 13596614 - DOR010530046  										   |//
//+--------------------------------------------------------------------------------+//
//////////////////////////////////////////////////////////////////////////////////////
USER FUNCTION FA550REP()
Local _aAreaRep := GetArea()

If lGerouRep
    MsgInfo("Foi criado o título a pagar " + Alltrim(SE2->E2_NUM) + " no valor de R$" + Alltrim(Transform(SE2->E2_VALOR,PesqPict("SE2","E2_VALOR"))) + " com vencimento para " + DtoC(SE2->E2_VENCTO) + ". É necessário realizar a baixa para que a reposição seja concluída" )
EndIf

RestArea(_aAreaRep)
RETURN
