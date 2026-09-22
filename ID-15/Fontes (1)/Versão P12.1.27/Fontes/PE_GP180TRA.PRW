#include 'protheus.ch'
#include 'parmtype.ch'

/*
{Protheus.doc} GP180TRA()
Executado logo após a atualização dos dados da tabela Cadastro de Funcionários (SRA). A tabela fica posicionada no funcionário que foi transferido, 
e as informações atualizadas ficam disponíveis e podem ser utilizadas em outros módulos do sistema ou rotinas específicas.

Grava a tabela PA6 para transferências realizadas pelas rotinas de movimentação customizada.

@Author     Nairan Alves Silva
@Since      20/05/2017
@Version    P12.1.07
@history    08/10/2021, Luciano.Camargo TOTVS, na transferencia do funcionario, inativar todos os cursos da ZZD
@see PE_GP010AGRV / GRATITULA / ADICESTIM / ADIC1ESTIM / FUNXCUR / GPE10MENU
@Project    
*/
User Function GP180TRA()

	Local cFunc := "F0100323|F0500402|F050030S|U_F0100323|U_F0500402|U_F050030S"
	Local aArea := GetArea() // ticket n° 9303216

	// Verificar se existem cursos do funcionario
	// Caso existam, e esteja sendo realizada uma transferencia de filial, inativar os cursos para nova validação pela nova filial
	IF SRE->(RE_EMPD+RE_FILIALD) != SRE->(RE_EMPP+RE_FILIALP)
		dbSelectArea("ZZD")
		ZZD->(DbSetOrder(1))		
		If ZZD->(dbSeek( xFilial('ZZD') + SRE->RE_MATD ))		
			While ZZD->(!Eof()) .and. ZZD->ZZD_MAT == SRE->RE_MATD			
				RecLock("ZZD", .F.)
				ZZD->ZZD_ATIVO := "2" // 1=SIM 0=NAO				
				ZZD->(MsUnlock())
				ZZD->(DBSkip())
			Enddo
			//MsgInfo("Este funcionario teve os cursos inativados, favor proceder com revalidação.")
		EndIf
		RestArea(aArea)
	Endif

	//Valida pelos parametros se essa empresa irá executar essas chamadas.
	If !U_VALIDEMP()
		Return .T.
	EndIf

	If AllTrim(FunName()) $ cFunc
		U_F0600700("",8192)
	EndIf

	RestArea(aArea) // ticket n° 9303216

Return .T.
