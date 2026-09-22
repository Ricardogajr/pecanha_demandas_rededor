#include 'protheus.ch'
#include 'parmtype.ch'
/*/
    {Protheus.doc} REDSCH4
    Schedule que executa rotinas REDSCH2 (Busca carrinho de compras contrato) = WFG - Gerar Contratos para todas as empresas
    @type  Function
    @author Ricardo Junior
    @since 25/05/2018    
/*/
User Function REDSCH4(aEmpFil)

	 Local nX        := 01

    Local aAux      := {}
    Local aPedidos  := {}
    Local aCotacao  := {}
    Local aXml      := {}  
    
    Local oXml      := NIL
    
    cIdProc := AllTrim(FWUUIDV4())
    
    U_WsLogBio("REDSCH4", 2, "ANTES DE LOGAR")
    RpcSetType(3)
    
    RpcSetEnv(aEmpFil[1], aEmpFil[2])
    
    U_WsLogBio("REDSCH4", 2, "RPCSETENV ---> " + aEmpFil[1] + " " + aEmpFil[2] )
    U_WsLogBio("REDSCH4", 2, "cFilAnt -----> " + cFilAnt)
    
	aAdd(aAux,{ {"PARAMETROS", 	"LAYOUT=WF"},;
			    {"FILIAL", 		"BIONEXO"},;
			    {"LOGIN", 		"teste1"},;
			    {"XIDPROC", 	cIdProc},;
			    {"PASSWORD", 	"teste1"}})
			    
	U_WsLogBio("REDSCH4", 2, "Antes REDWSDL2")
    aXml := U_RedWsdL2("WFG", aAux)
    U_WsLogBio("REDSCH4", 2, "DEPOIS REDWSDL2")
Return