User Function FA560BRW()

Local aButtons := ParamIxb[1]

Aadd(aButtons, {"Banco Específico - Visualizar", "U_F0400101(1)" ,0,4,Nil,.F.} )
Aadd(aButtons, {"Banco Especí­fico - Incluir", "U_F0400101(3)" ,0,4,Nil,.F.} )
Aadd(aButtons, {"Banco Especí­fico - Excluir", "U_F0400101(5)" ,0,4,Nil,.F.} )


Return(aButtons) 
 

