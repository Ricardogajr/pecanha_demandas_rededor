#include "rwmake.ch"
#include "topconn.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CRIAITEM  ºAutor  ³Microsiga           º Data ³             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ PROGRAMA PARA CRIACAO DO ITEM CONTABIL                     º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function CRIAITEM()
Processa( {|| PrcCtb01()} ,OemToAnsi("Atualização do Item Contábil - Fornecedores"),"Processando...")
Processa( {|| PrcCtb02()} ,OemToAnsi("Atualização do Item Contábil - Clientes"),"Processando...")
Return

Static Function PrcCtb01()
*****************************************************************************************************
Local cItemCont := ""
dbSelectArea("SA2")
dbGoTop()      
ProcRegua(RecCount()) // Numero de registros a processar
While !Eof()
    IncProc()
	dbSelectArea("CTD")
	dbSetOrder(1)
	cItemCont := "F"+ALLTRIM(xfilial("SA2"))+SA2->A2_COD+SA2->A2_LOJA
	dbSeek(xFilial("CTD")+cItemCont)
	If Eof()
		RecLock("CTD",.T.)
		Replace CTD_FILIAL With xFilial("CTD") , ;
		CTD_ITEM   With cItemcont      , ;
		CTD_DESC01 With SA2->A2_NOME   , ;
		CTD_CLASSE With "2"            , ;
		CTD_NORMAL With "0"            , ;
		CTD_DTEXIS With ctod("01/01/2000") , ;
		CTD_BLOQ   With '2'
		MsUnlock("CTD")
	EndIf
	dbSelectArea("SA2")
	dbSkip()
End
Return

Static Function PrcCtb02()
Local cItemCont := ""
dbSelectArea("SA1")
dbGoTop()
ProcRegua(RecCount()) // Numero de registros a processar
While !Eof()
	incproc()
	dbSelectArea("CTD")
	dbSetOrder(1)
	IF Alltrim(xfilial("SA1"))<>""
		cItemCont := "C"+xfilial("SA1")+SA1->A1_COD+SA1->A1_LOJA
	else
		cItemCont := "C"+SA1->A1_COD+SA1->A1_LOJA
	endif
	dbSeek(xFilial("CTD")+cItemCont)
	If Eof()
		RecLock("CTD",.T.)
		Replace CTD_FILIAL With xFilial("CTD") , ;
				CTD_ITEM   With cItemcont      , ;
				CTD_DESC01 With SA1->A1_NOME   , ;
				CTD_CLASSE With "2"            , ;
				CTD_NORMAL With "0"            , ;
				CTD_DTEXIS With ctod("01/01/1980") , ;
				CTD_BLOQ   With '2'
		MsUnlock("CTD")
	EndIf
	dbSelectArea("SA1")
	dbSkip()
End
Return
