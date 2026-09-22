#include "totvs.ch"

#define F24CONSUMO    1
#define F24COMPRA     2
#define F24P12TOFRONT 1
#define F24FRONTTOP12 2

/*/{Protheus.doc} F0703504
Função responsável pelas atualização da tabela P18 (Controle de consignado especifico)
@author Alex Sandro Valario
@since 19/05/2017
@version 1.0
@Project MAN0000007423041_EF_035
@return LOGICO
/*/

User Function F0703504(cLOCAL, cCOD, cXFORN, cXLJFOR, nCUSTO1, nQUANT, cTMCons, cxCONSIG)
	Default cxCONSIG := '1'
    
    If cxCONSIG == '2'
        Return .t.
    EndIf
	If Empty(cXFORN)
        If IsBlind()
		    AutoGrLog('Codigo do fornecedor não informado!')
        Else
            Help( , , 'F0703504', , 'Codigo do fornecedor não informado!', 1, 0) 
        EndIf
		Return .f.
	EndIf
	If Empty(cXLJFOR)
        If IsBlind()
        	AutoGrLog('Codigo da loja do fornecedor não informado!')
        Else
            Help( , , 'F0703504', , 'Codigo da loja do fornecedor não informado!', 1, 0) 
        EndIf
		Return .f.
	EndIf
	
	If Select("P18") == 0
		ChkFile("P18")
	EndIf
	
	P18->(DbSetOrder(1))
	If ! P18->(DbSeek(xfilial('P18') + cLOCAL + cCOD + cXFORN + cXLJFOR))
		P18->(RecLock('P18',.t.))
		P18->P18_FILIAL := xFilial('P18')
		P18->P18_LOCAL  := cLOCAL
		P18->P18_COD    := cCOD
		P18->P18_FORN   := cXFORN
		P18->P18_LOJA	:= cXLJFOR
	Else
		P18->(RecLock('P18',.f.))
	EndIF
	If cTMCons == "E"
		P18->P18_VALOR	+= nCUSTO1
		P18->P18_SALDO	+= nQUANT
	ElseIf cTMCons == "S"
		P18->P18_VALOR	-= nCUSTO1
		P18->P18_SALDO	-= nQUANT
	EndIF
	P18->(MsUnlock())
	
Return .T.