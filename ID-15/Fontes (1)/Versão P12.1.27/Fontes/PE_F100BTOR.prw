/*/{Protheus.doc} User Function F100BTOR
    Permite acrescentar botões na interface
    @type  Function
    @author Gianluca Moreira
    @since 22/08/2021
    /*/
User Function F100BTOR()

    Local aButton := ParamIXB[1]
   Local cCtbOn  := SuperGetMV('FS_C200040',, '')

Conout("Entrou ponto de entrada F100BTOR " + Time())
    //A doc. oficial da ExecAuto menciona o parâmetro NCTBONLINE para controlar
    //se contabiliza online ou não. Após análise da rotina padrão, verificou-se
    //que o parâmetro não é utilizado, e é necessário alterar o MV_PAR04 
    //manualmente neste ponto de entrada
    If FWIsInCallStack('U_F2000401') .And. !Empty(cCtbOn)
	    MV_PAR04 := Val(cCtbOn)
    EndIf
Conout("Saiu ponto de entrada F100BTOR " + Time())
Return aButton
