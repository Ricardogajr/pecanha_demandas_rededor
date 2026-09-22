#Include 'Protheus.ch' 

/*
{Protheus.doc}  F560FCAD()
PE para excluir o título de reposição do caixinha (caso exista) no momento do fechamento.
@Author  Ramon Teodoro e Silva	
@Since   08/11/2017       
@Version P12.7
*/
User Function F560FCAD()

Local aArea    := GetArea()
Local lRet     := .F.
Local cCaixa   := SET->ET_CODIGO
Local cQuery   := ""
Local cAliasE2 := GetNextAlias()
Local aTit     := {}

Private lMsErroAuto := .F.

If IsInCallStack("Fa550Baixa")
	
	cQuery := "SELECT * FROM " + RetSqlName("SE2")
	cQuery += " WHERE E2_FILIAL = '" + xFilial("SE2") + "' AND E2_XCAIXIN = '" + cCaixa + "' AND "
	cQuery += " E2_SALDO > 0 AND E2_NUMBOR = '' AND D_E_L_E_T_ = ''"
	cQuery := ChangeQuery( cQuery ) 
	
	If Select(cAliasE2) > 0
		(cAliasE2)->(DbCloseArea())
	EndIf
				
	DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasE2,.F.,.T.)
	
	If (cAliasE2)->(!Eof())
	
		DbSelectArea("SE2")
		DbSetOrder(1)
		If DbSeek((cAliasE2)->(E2_FILIAL+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA))
			RecLock("SE2", .f.)
			SE2->E2_DATALIB := dDataBase
			MsUnLock()
		EndIf
	
		aTit := { { "E2_PREFIXO"  , (cAliasE2)->(E2_PREFIXO)     , NIL },;
		          { "E2_NUM"      , (cAliasE2)->(E2_NUM)         , NIL },;
		          { "E2_PARCELA"  , (cAliasE2)->(E2_PARCELA)     , NIL },;
		          { "E2_TIPO"     , (cAliasE2)->(E2_TIPO)        , NIL },;
		          { "E2_FORNECE"  , (cAliasE2)->(E2_FORNECE)  	 , NIL },;
		          { "E2_LOJA"     , (cAliasE2)->(E2_LOJA)        , NIL },;
		          { "E2_NATUREZ"  , (cAliasE2)->(E2_NATUREZ)  	 , NIL },;
		          { "E2_EMISSAO"  , (cAliasE2)->(E2_EMISSAO)     , NIL },;
		          { "E2_VENCTO"   , (cAliasE2)->(E2_VENCTO)      , NIL },;
		          { "E2_VENCREA"  , (cAliasE2)->(E2_VENCREA)     , NIL },;
		          { "E2_VALOR"    , (cAliasE2)->(E2_VALOR)       , NIL }}
		          
		MsExecAuto( { |x,y,z| FINA050(x,y,z)}, aTit,, 5)
		
		If lMsErroAuto
			RollBackSx8()
		    If !(IsBlind())
				MostraErro()
			EndIf
		Else
			MsgAlert("O título " + Alltrim((cAliasE2)->(E2_NUM)) + " foi excluído." )
		Endif
		
	EndIf
	
	(cAliasE2)->(DbCloseArea())

EndIf

RestArea(aArea)

Return lRet

