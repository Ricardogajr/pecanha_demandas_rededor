/*/{Protheus.doc} User Function FA100ROT
    Permite adicionar botões ao menu do movimento bancário (FINA100)
    @type  Function
    @author Gianluca Moreira
    @since 16/06/2021
    @version version
    /*/
User Function FA100ROT()

    Local aRotOld := ParamIXB[1]
    Local aRotNew := aRotOld
    Local lGrpHblt  := .F. //Verifica tabela PX1 para a empresa/filial atual
    Conout("Entrou ponto de entrada FA100ROT " + Time())
    If !Isblind()
        lGrpHblt := U_F2000132() 
    EndIf
    //Verifica se está habilitada a integração neste grupo de empresas
    If lGrpHblt
        AAdd(aRotNew, {'Log Integ. XRT',"U_F2000420()" , 0 , 2})
    EndIf    
    Conout("Saiu ponto de entrada FA100ROT " + Time())
Return aRotNew
