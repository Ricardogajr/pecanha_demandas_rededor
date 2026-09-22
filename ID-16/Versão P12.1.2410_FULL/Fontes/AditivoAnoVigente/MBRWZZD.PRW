#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'TBICONN.CH'
#INCLUDE 'TOPCONN.CH'
#INCLUDE 'TOTVS.CH'

/*/{Protheus.doc} MBrwZZD
Exibe a lista de funcionarios e permite a manutenção dos vinculos de Funcionarios x Cursos
@author luciano.camargo
@since 17/05/2018
@version undefined
@type function
/*/
User Function MBRWZZD()

	Private cCadastro := "Cadastro (Funcionarios x Cursos)"
	Private cString := "SRA"
	Private aRotina := MENUDEF()

	dbSelectArea(cString)
	(cString)->(dbSetOrder(1))
	aRotina := MenuDef()

	mBrowse( 06,01,22,75,cString)

Return Nil

Static Function MenuDef()
	
	Local aArea		:= GetArea()
	Local aRetorno	:= { {"Pesquisar","AxPesqui",0,1} ,;
		{"Visualizar","AxVisual",0,2} ,;
		{"Cursos"	 ,"u_FUNXCUR",0,3} }

	RestArea(aArea)

Return aRetorno


