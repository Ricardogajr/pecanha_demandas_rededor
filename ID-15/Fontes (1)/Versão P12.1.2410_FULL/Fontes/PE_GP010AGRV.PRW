#include "totvs.ch"
#include 'parmtype.ch'
#Include 'Protheus.ch'

/*
{Protheus.doc} GP010AGRV()
Apos a gravação dos registros
@Author     Bruno de Oliveira
@Since      23/11/2016
@Version    P12.1.07
@Project    MAN00000462901_EF_003
@history    07/10/2021, Luciano Camargo TOTVS, inativação dos cursos do funcionario no caso de transferencia de empresa
@see 		GRATITULA / PE_GP180TRA / ADICESTIM / ADIC1ESTIM / FUNXCUR / GPE10MENU
@obs 		Influencia nos roteiros de calculo GRATTIULA / ADICESTIM e ADIC1ESTIM
*/
User Function GP010AGRV()

	Local aParam := ParamIXB
	Local aAlias := Alias()
	Local aArea  := GetArea()

	// Inativa os cursos - 07/10/2021, Luciano Camargo TOTVS
	If aParam[2]
		If aParam[1] ==  3 .Or. aParam[1] ==  4
			// Colocar cursos como inativos, apenas se houve alteração de cargo ou função
			// Consultar na SR7
			DbSelectArea("SR7")
			SR7->(DbSkip(-1))
			If (SR7->R7_FUNCAO != SRA->RA_CODFUNC .or. SR7->R7_CARGO != SRA->RA_CARGO) .and. ( SR7->R7_MAT = SRA->RA_MAT )
				fajdCursos()
			Endif
		EndIf
	EndIf
	DbSelectArea(aAlias)
	RestArea(aArea)

	//Valida pelos parametros se essa empresa irá executar essas chamadas.
	If !U_VALIDEMP()
		Return
	EndIf

	U_AMS00013() // ticket n° 3834093 - 415966 - Paulo Dias - função gravação de registros da CNS

	// 416094 - Rogerio Carvalho - AMS Rio - 13/07/2018 - DOR04520620
	// Função abaixo desligada, pois está sendo a integração está sendo feita por JOB
	//U_F0600107()
	// Fim 416094 - Rogerio Carvalho - AMS Rio - 13/07/2018 - DOR04520620
	U_F0100326(SRA->RA_CIC)
	U_F0600303(aParam)

Return

Static Function fajdCursos()

	dbSelectArea("ZZD")
	ZZD->(DbSetOrder(1))
	If ZZD->(dbSeek( xFilial('ZZD') + SRA->RA_MAT ))
		While ZZD->(!Eof())  .and. ZZD->ZZD_MAT == SRA->RA_MAT
			RecLock("ZZD", .F.)
			ZZD->ZZD_ATIVO := "2"
			ZZD->(MsUnlock())
			ZZD->(DBSkip())
		Enddo
	EndIf

Return
