/*/{Protheus.doc} User Function FA080BUT
    Adiciona botões na rotina de baixas a pagar
    @type  Function
    @author Gianluca Moreira
    @since 20/08/2021
    /*/
User Function FA080BUT()
    If FindFunction('U_F2000120')
        AAdd(aRotina, {'Integ. AP XRT' ,"U_F2000120()", 0 , 2})
    EndIf
    If FindFunction('U_F2000421')
        AAdd(aRotina, {'Integ. Op. Fin. XRT' ,"U_F2000421()", 0 , 2})
    EndIf
Return
