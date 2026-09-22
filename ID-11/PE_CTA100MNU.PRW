#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"

Static __aUsrCpo 	:= Nil
Static _lA300RVUN	:= ExistBlock("A300RVUN")
Static _lA300RDVI	:= ExistBlock("A300RDVI")
Static _lA300BREAK	:= ExistBlock("A300BREAK")
Static _lVPresFIN	:= Nil
Static _lVPresCTB	:= Nil

/*/{Protheus.doc} CTA100MNU
Rotina responsável pela Manutenção de Contratos.
Para adicionar botões no menu principal da rotina.
@type function 
@author Ricardo da Silva
@since 23/10/2017
@version 1.0
@return NIL
/*/
User Function CTA100MNU()

	aAdd( aRotina , { "Tabela de Preço"    , "COMA010(3,Nil,Nil)", 0,3,0,Nil } )

	U_F0400103(aRotina)

	//Adiciona uma opção ao final do menu de revisões.
	nPosRev := aScan(aRotina, {|x|  "Revis" $ AllTrim(x[1]) })
	aAdd(aRotina[nPosRev][2], { "Alteração Email", "U_XEMAICN9", 0, OP_COPIA, 0, Nil})

Return(Nil)

/*/{Protheus.doc} xEMAICN9
Atualiza o email do contrato
@type function
@version P2410 
@author Ricardo Junior
@since 4/15/2026
@return variant, Null
/*/
User Function xEMAICN9()
	Local aArea   := GetArea()
	
	Cn300Rev(,,,"1")
	
	RestArea(aArea)
return
