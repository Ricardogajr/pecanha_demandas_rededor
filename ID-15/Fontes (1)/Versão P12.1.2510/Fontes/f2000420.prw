#Include 'TOTVS.ch'
#Include 'FWMVCDEF.ch'

/*/{Protheus.doc} User Function F2000420
    PE FA100ROT - Adiciona botões no menu do movimento bancário
    Apresenta log de integração dos movimentos bancários vindos
    do XRT
    @type  Function
    @author Gianluca Moreira
    @since 16/06/2021
    /*/
User Function F2000420()
	Local cFiltro := ''
    Local cFilP19 := ''
	Local cTit    := ''
	Local cChave  := ''
    Local lGrpHblt  := U_F2000132() //Verifica tabela PX1 para a empresa/filial atual

    //Integração não habilitada neste grupo
    If !lGrpHblt
		Help(,, "F2000130",, 'A integração do XRT não está habilitada nesta empresa.', 1, 0,;
		,,,,, {'Verifique se os campos do processo estão criados e habilite através da rotina F2000130'})
        Return
    EndIf

    If Empty(SE5->E5_XPCXRT) .Or. Empty(SE5->E5_XCODXRT)
        MsgInfo('Registro não originado do XRT', 'Integração XRT')
        Return
    EndIf

	//cChave := SubStr("SE5|01|"+SE5->(E5_FILIAL+E5_XPCXRT+E5_XCODXRT)+Space(Len(P19->P19_INDKEY)), 1, Len(P19->P19_INDKEY))
    cChave  := SubStr(SE5->E5_XIDP19, FWSizeFilial()+1)
	cFilP19 := Left(SE5->E5_XIDP19, FWSizeFilial())
    cChave  := AvKey(cChave, 'P19_ID')

	cTit    := 'Log Integração Movimentos Bancários - XRT'
	cFiltro := "@"
	cFiltro += " P19_FILIAL = '"+cFilP19+"' AND "
	cFiltro += " P19_ID = '"+cChave+"' AND "
	cFiltro += " D_E_L_E_T_ = ' '"
	U_F2000105(cTit, cFiltro, "P19") 
Return 

/*/{Protheus.doc} User Function F2000421
    PE F050ROT - Adiciona botões no menu do título a pagar
    Apresenta log de integração das baixas vindas
    do XRT
    @type  Function
    @author Gianluca Moreira
    @since 17/06/2021
    /*/
User Function F2000421()
	Local cFiltro := ''
    Local cFilP19 := ''
	Local cTit    := ''
	Local cChave  := ''
    Local lGrpHblt  := U_F2000132() //Verifica tabela PX1 para a empresa/filial atual

    //Integração não habilitada neste grupo
    If !lGrpHblt
		Help(,, "F2000130",, 'A integração do XRT não está habilitada nesta empresa.', 1, 0,;
		,,,,, {'Verifique se os campos do processo estão criados e habilite através da rotina F2000130'})
        Return
    EndIf

    If Empty(SE2->E2_XOPFXRT)
        MsgInfo('O título não é de uma operação financeira', 'Integração XRT')
        Return
    EndIf

	//cChave := SubStr("SE2|01|"+SE2->(E2_FILIAL+DToS(E2_VENCREA)+E2_XOPFXRT+E2_NATUREZ)+Space(Len(P19->P19_INDKEY)), 1, Len(P19->P19_INDKEY))
    cChave  := SubStr(SE2->E2_XIDP19, FWSizeFilial()+1)
	cFilP19 := Left(SE2->E2_XIDP19, FWSizeFilial())
    cChave  := AvKey(cChave, 'P19_ID')

	cTit    := 'Log Integração Movimentos Bancários - XRT'
	cFiltro := "@"
	cFiltro += " P19_FILIAL = '"+cFilP19+"' AND "
	cFiltro += " P19_ID = '"+cChave+"' AND "
	cFiltro += " D_E_L_E_T_ = ' '"
	U_F2000105(cTit, cFiltro, "P19") 
Return 

/*/{Protheus.doc} User Function F2000422
    Log de visualização dos registros integrados do XRT - movimento bancario
    @type  Function
    @author Gianluca Moreira
    @since 22/06/2021
    /*/
User Function F2000422()
    Local oBrowse
    Local cFiltro := ''
    Local cChave  := AvKey('U_F2000400', 'P19_ROTINA')
    Local lGrpHblt  := U_F2000132() //Verifica tabela PX1 para a empresa/filial atual

    //Integração não habilitada neste grupo
    If !lGrpHblt
		Help(,, "F2000130",, 'A integração do XRT não está habilitada nesta empresa.', 1, 0,;
		,,,,, {'Verifique se os campos do processo estão criados e habilite através da rotina F2000130'})
        Return
    EndIf

    Private aRotina := MenuDef()

    cFiltro := "@"
	cFiltro += " P19_FILIAL = '"+FWXFilial('P19')+"' AND "
	cFiltro += " P19_ROTINA = '"+cChave+"' AND "
	cFiltro += " D_E_L_E_T_ = ' '"

	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias('P19')
	oBrowse:SetDescription('Integração Movimentos Bancários - XRT')
    oBrowse:AddLegend('P19->P19_STATUS == "1"', 'ORANGE', 'Gravando', "1")
    oBrowse:AddLegend('P19->P19_STATUS == "2"', 'GREEN',  'Sucesso', "1")
    oBrowse:AddLegend('P19->P19_STATUS == "3"', 'RED',    'Falha', "1")

	oBrowse:SetFilterDefault ( cFiltro )
    oBrowse:DisableDetails()
    oBrowse:ForceQuitButton()

	oBrowse:Activate()

Return 

Static Function MenuDef()
	Local aRot := {}
	
    //Thiago Marques - ticket nº - 13/06/2025 - Removido o ADD OPTION para compatibilização.
	//ADD OPTION aRot TITLE 'Visualizar' ACTION 'VIEWDEF.F0700002' OPERATION 2 ACCESS 0
    aAdd(aRot, {"Visualizar", "VIEWDEF.F0700002", 0, 2})

Return aRot
