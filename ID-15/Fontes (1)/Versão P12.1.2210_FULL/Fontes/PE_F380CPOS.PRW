#Include 'TOTVS.ch'

/*/{Protheus.doc} User Function F380CPOS
    Adiciona e move campos na tela de conciliação bancária
    @type  Function
    @author Gianluca Moreira
    @since 01/06/2021
    @see https://tdn.engpro.totvs.com.br/pages/releaseview.action?pageId=568923443
    /*/
User Function F380CPOS()
    Local aCampos    := ParamIXB[1]
    Local aCamposNew := aCampos
    
    aCamposNew := U_F2000413(aCampos) 
       
Return aCamposNew
