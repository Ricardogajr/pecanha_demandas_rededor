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
    
Return(Nil)