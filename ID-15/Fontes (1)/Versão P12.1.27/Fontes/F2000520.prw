#Include 'TOTVS.ch'
#Include 'FWMVCDEF.ch'

/*/{Protheus.doc} F2000520

Exibe o log P19 de integração do lançamento contábil originado pelo XRT
Executado pelo PE CT102BUT

@type function
@version  
@author fabio.cazarini
@since 24/06/2021
@return return_type, return_description
/*/
User Function F2000520()
	Local cFiltro := ''
	Local cTit    := ''
	Local cChave  := ''
	Local lGrpHblt  := U_F2000132() //Verifica tabela PX1 para a empresa/filial atual

    //Integração não habilitada neste grupo
    If !lGrpHblt
		Help(,, "F2000130",, 'A integração do XRT não está habilitada nesta empresa.', 1, 0,;
		,,,,, {'Verifique se os campos do processo estão criados e habilite através da rotina F2000130'})
        Return
    EndIf

    If Empty(CT2->CT2_XCDXRT) .or. Empty(CT2->CT2_IDINT)
        MsgInfo('Registro não originado do XRT', 'Integração XRT')
        Return
    EndIf

    cChave := Padr(CT2->CT2_IDINT, GetSx3Cache("P19_FILIAL", "X3_TAMANHO")+GetSx3Cache("P19_ID", "X3_TAMANHO") )

	cTit    := 'Log Integração Lançamentos Contábeis - XRT'

	cFiltro := "@"
	cFiltro += " P19_FILIAL+P19_ID = '" + cChave + "' AND "
	cFiltro += " D_E_L_E_T_ = ' '"
	
    U_F2000105(cTit, cFiltro, "P19") 

Return 


/*/{Protheus.doc} F2000522

Log de visualização dos registros integrados do XRT - movimento bancario

@type function
@version  
@author Gianluca Moreira
@since 24/06/2021
@return return_type, return_description
/*/
User Function F2000522()
    Local oBrowse
    Local cFiltro := ''
    Local cChave  := Padr('U_F2000501', GetSx3Cache('P19_ROTINA','X3_TAMANHO') )
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
	oBrowse:SetDescription('Integração Lançamentos Contábeis - XRT')
    oBrowse:AddLegend('P19->P19_STATUS == "1"', 'ORANGE', 'Gravando', "1")
    oBrowse:AddLegend('P19->P19_STATUS == "2"', 'GREEN',  'Sucesso', "1")
    oBrowse:AddLegend('P19->P19_STATUS == "3"', 'RED',    'Falha', "1")

	oBrowse:SetFilterDefault ( cFiltro )
    oBrowse:DisableDetails()
    oBrowse:ForceQuitButton()

	oBrowse:Activate()

Return 


/*/{Protheus.doc} MenuDef

MenuDef

@type function
@version  
@author Gianluca Moreira
@since 24/06/2021
@return return_type, return_description
/*/
Static Function MenuDef()
	Local aRot := {}
	
	ADD OPTION aRot TITLE 'Visualizar' ACTION 'VIEWDEF.F0700002' OPERATION 2 ACCESS 0

Return aRot
