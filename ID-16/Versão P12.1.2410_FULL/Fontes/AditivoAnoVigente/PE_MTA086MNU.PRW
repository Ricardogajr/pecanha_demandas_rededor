/*/{Protheus.doc} CTA100MNU
Rotina responsável pela Manutenção de Contratos.
Para adicionar botões no menu principal da rotina.
@type function 
@author Ricardo da Silva
@since 23/10/2017
@version 1.0
@return NIL
/*/
User Function MTA086MNU()
Local aRotina as array

aRotina := PARAMIXB[1]

aAdd( aRotina , { "Grupo Compras X E-mail", "u_GRPXEMAIL", 0, 3, 0, Nil, Nil , Nil  } )  
    
Return aRotina
