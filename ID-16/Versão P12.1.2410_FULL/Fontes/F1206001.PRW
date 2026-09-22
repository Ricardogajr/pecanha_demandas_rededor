#Include 'Protheus.ch'

/*
{Protheus.doc} F1206001()
Inclusão do totalizador no cabeçalho
@Author  Fabrica de Software
@Since   08/10/2018
@Project MAN0000007423048_EF_060
@Param   oNewDialog, Dialog principal
@Param   aPosGet, posição do msget
*/
User Function F1206001(oNewDialog,aPosGet)
	
	Public CC1XTOTAL := U_F1206004()
	
//-------------------------------------
//	Public CC1XTOTAL := 0
//	If !INCLUI
////		CC1XTOTAL := U_F1206003()
//		CC1XTOTAL := U_F1206004()
//	EndIf
//-------------------------------------
	
	aadd(aPosGet[1],0)
	aadd(aPosGet[1],0)
	
	aPosGet[1,7]:=255
	aPosGet[1,8]:=280
	
//-------------------------------------
//	@aPosGet[1,1]+45,aPosGet[1,1] SAY 'Totalizador' PIXEL SIZE 28,9 Of oNewDialog
//	@aPosGet[1,1]+44,aPosGet[1,2] MSGET CC1XTOTAL F3 CpoRetF3("C1_XVLTOT") Picture PesqPict("SC1","C1_XVLTOT");
//		When VisualSX3("C1_XVLTOT") Valid CheckSX3("C1_XVLTOT",CC1XTOTAL) PIXEL SIZE 80,10 Of oNewDialog
//-------------------------------------

    @ aPosGet[ 1 , 1 ] + 42 , aPosGet[ 1 , 1 ] + 200 SAY 'Totalizador' PIXEL SIZE 28 , 09 OF oNewDialog
    @ aPosGet[ 1 , 1 ] + 42 , aPosGet[ 1 , 2 ] + 220 MSGET CC1XTOTAL F3 CpoRetF3("C1_XVLTOT") PICTURE PesqPict("SC1","C1_XVLTOT");
		When VisualSX3("C1_XVLTOT") Valid CheckSX3("C1_XVLTOT",CC1XTOTAL) PIXEL SIZE 80,10 Of oNewDialog
	
Return

/*
{Protheus.doc} F1206002()
Execução do gatilho
@Author  Fabrica de Software
@Since   08/10/2018
@Project MAN0000007423048_EF_060
@Return  nTotal, Total do Item
*/
User Function F1206002()
	
	Local nTotal := 0
	
	nTotal := GDFIELDGET("C1_QUANT") * GDFIELDGET("C1_VUNIT")
	
//	CC1XTOTAL := U_F1206003(nTotal)
	CC1XTOTAL := U_F1206004( )
	
Return nTotal

/*
{Protheus.doc} F1206003()
Cálculo de todos os itens
@Author  Fabrica de Software
@Since   08/10/2018
@Project MAN0000007423048_EF_060
@Param   nTotal, total da linha
@Return  nTotLin, total de todas as linhas
*/
User Function F1206003(nTotal)
	
	Local nX      := 0
	Local nTotLin := 0
	Local nQtdTot := aScan(aHeader,{|x| AllTrim(x[2])=="C1_XVLTOT"})
//	Local nQtdTot := aScan(aHeader,{|x| AllTrim(x[2])=="C1_XTOTAL"})
	
	Default nTotal := 0
	
	For nx := 1 to Len(aCols)
		If !aCols[nX][Len(aCols[nX])]
			nTotLin += aCols[nX][nQtdTot]
		EndIf
	Next
	
	nTotLin += nTotal
	
	u_f1206004()
	
Return nTotLin

// ----------------------------------------------

user function F1206004( )

    local nPosQtd := aScan( aHeader , { |x| alltrim( x[2] ) == 'C1_QUANT'  } )
    local nPosVal := aScan( aHeader , { |x| alltrim( x[2] ) == 'C1_VUNIT'  } )
    local nLinTot := 0
    local nSC1Tot := 0
    local nX      := 0

    for nX := 1 to len( aCols )

        if !aCols[ nX ][ len( aCols[ nX ] ) ]

            nLinTot := aCols[ nX ][ nPosQtd ] * aCols[ nX ][ nPosVal ]
            nSC1Tot += nLinTot

        endif

    next nX

return nSC1Tot

// ----------------------------------------------
// [ fim de f1206001.prw ]
// ----------------------------------------------
