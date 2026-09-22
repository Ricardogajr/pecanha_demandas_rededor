#Include 'Protheus.ch'

/*
{Protheus.doc}  FA290()
Ponto de Entrada na geração do título aglutinado, será utilizado para a digitação e gravação do código de barras no campo E2_CODBAR 
quando for realizada a aglutinação de ISS na rotina de fatura a pagar
@Author  Ramon Teodoro e Silva	
@Since   05/01/2018       
@Version P12.7
*/

User Function FA290()

Local lRet    := .T.
Local aArea   := GetArea()


// Rafael Yera Barchi - 16/08/2021
// Chamado 12255356
// Tratativa para verificar se não está sendo executada por job/Schedule
If !IsBlind()

	If &(GetNewPar("MV_ISS")) == Alltrim(SE2->E2_NATUREZ)

		If MsgYesNo("Deseja gravar código de barras para o título que está sendo gerado?", "Atenção")
			U_DigCodBar()
		EndIf

	EndIf

EndIf

RestArea(aArea)

Return lRet


/*
{Protheus.doc}  DigCodBar()
Função que monta tela para digitação e grava o campo de código de barras na SE2 
@Author  Ramon Teodoro e Silva	
@Since   05/01/2018       
@Version P12.7
*/
User Function DigCodBar

Local lRet    := .T.
Local aBotoes := {}
Local cCodBar := SE2->E2_CODBAR
Local cPrefix := Alltrim(SE2->E2_PREFIXO)
Local cTitulo := Alltrim(SE2->E2_NUM) 
Local cFornec := Alltrim(SE2->E2_FORNECE)
Local cNomFor := Alltrim(SE2->E2_NOMFOR) 
Local cEmiss  := DtoC(SE2->E2_EMISSAO)
Local nValor  := SE2->E2_VALOR
Local lConf   := .f.
Local oGroup 

Private aSizeAut := MsAdvSize() 
Private oDlgS

aObjects := {}

AAdd( aObjects, { 300, 030, .T., .F. } )

aInfo := { aSizeAut[ 1 ], aSizeAut[ 2 ], aSizeAut[ 3 ], aSizeAut[ 4 ], 3, 3 }
aPosObj := MsObjSize( aInfo, aObjects, .T. )

DEFINE MSDIALOG oDlgS TITLE "DIGITAÇÃO DO CÓDIGO DE BARRAS" From 0,0 TO aSizeAut[3]-400,aSizeAut[5]-750 OF oMainWnd PIXEL

@  aPosObj[1][1], aPosObj[1][2] GROUP oGroup TO aPosObj[1][1]+100,aPosObj[1][2]+250 LABEL "Dados do título" PIXEL OF oDlgS 
	
@ aPosObj[1][1]+16, aPosObj[1][2]+07   Say   "Prefixo"             Size 045,008 PIXEL OF oDlgS   //030
@ aPosObj[1][1]+15, aPosObj[1][2]+40   MSGET cPrefix          	   When .F. Size 35,010 PIXEL OF oDlgS  //038
@ aPosObj[1][1]+16, aPosObj[1][2]+85   Say    "Título"             Size 045,008 PIXEL OF oDlgS   //030
@ aPosObj[1][1]+15, aPosObj[1][2]+110  MSGET cTitulo         	   When .F. Size 50,010 PIXEL OF oDlgS  //038

@ aPosObj[1][1]+31,  aPosObj[1][2]+07  Say   "Emissão"              Size 045,008 PIXEL OF oDlgS   //030
@ aPosObj[1][1]+30,  aPosObj[1][2]+40  MSGET cEmiss                 When .F. Size 35,010 PIXEL OF oDlgS  //038
@ aPosObj[1][1]+31,  aPosObj[1][2]+85  Say   "Valor"                Size 045,008 PIXEL OF oDlgS   //030
@ aPosObj[1][1]+30,  aPosObj[1][2]+110 MSGET nValor                 When .F. Size 50,010 OF oDlgS PIXEL Picture PesqPict("SE2","E2_VALOR")   //038

@ aPosObj[1][1]+46, aPosObj[1][2]+07  Say   "Fornecedor"           Size 045,008 PIXEL OF oDlgS   //030
@ aPosObj[1][1]+45, aPosObj[1][2]+40 MSGET cFornec                 When .F. Size 35,010 PIXEL OF oDlgS  //038
@ aPosObj[1][1]+45, aPosObj[1][2]+85  MSGET cNomFor                When .F. Size 100,010 PIXEL OF oDlgS  //038

@ aPosObj[1][1]+62, aPosObj[1][2]+07 Say   "Cod. Barras"           Size 045,008 PIXEL OF oDlgS   //030
@ aPosObj[1][1]+61, aPosObj[1][2]+40 MSGET cCodBar                 Size 135,010 PIXEL OF oDlgS  //038

ACTIVATE MSDIALOG oDlgS ON INIT EnchoiceBar(oDlgS,{ || lConf:=.t.,oDlgS:END() }, { || lConf:=.f.,oDlgS:END() },,aBotoes)

If lConf
	SE2->E2_CODBAR := cCodBar
EndIf

Return lRet
