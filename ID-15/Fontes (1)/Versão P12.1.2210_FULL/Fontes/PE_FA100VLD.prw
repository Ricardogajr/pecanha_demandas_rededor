#Include 'TOTVS.ch'

/*/{Protheus.doc} User Function FA100VLD
    Validação do cancelamento/exclusão da movimentação bancária
    @type  Function
    @author Gianluca Moreira
    @since 31/05/2021
    @see https://tdn.totvs.com/pages/releaseview.action?pageId=6071360
    /*/
User Function FA100VLD()

    Local aAreaE5 := SE5->(GetArea())
	Local lExclui  :=  ParamIXB[1]
	Local lCancela := !ParamIXB[1]
	Local lRet     := .T.
	Local lGrpHblt  := .F.//Verifica tabela PX1 para a empresa/filial atual
	Local cCtbOn  := ""

	// ticket n° 12543360
	Local cUsrAlt := ""

	Conout("Entrou ponto de entrada FA100VLD " + Time())
	 lGrpHblt  := U_F2000132() //Verifica tabela PX1 para a empresa/filial atual
	 cCtbOn  := SuperGetMV('FS_C200040',, '')
	 cUsrAlt := USRFULLNAME(__cuserid)

	//Verifica se está habilitada a integração neste grupo de empresas
	If lGrpHblt
		lRet := U_F2000410() //Valida se a movimentação veio do XRT
	EndIf

	//A doc. oficial da ExecAuto menciona o parâmetro NCTBONLINE para controlar
	//se contabiliza online ou não. Após análise da rotina padrão, verificou-se
	//que o parâmetro não é utilizado, e é necessário alterar o MV_PAR04
	//manualmente neste ponto de entrada
	If FWIsInCallStack('U_F2000401') .And. !Empty(cCtbOn) .And. Type('MV_PAR04') != 'U'
		MV_PAR04 := Val(cCtbOn)
	EndIf

	// ticket n° 12543360 -- FINA100
	If lExclui //.Or. lCancela
		RecLock("SE5", .F. )
		SE5->E5_XLOGMOV  := cUsrAlt
		SE5->E5_XHORMOV  := TIME()
		SE5->E5_XDATMOV  := Date()
		SE5->(MsUnlock())
	EndIf

RestArea(aAreaE5)
Conout("Saiu ponto de entrada FA100VLD " + Time())
Return lRet
