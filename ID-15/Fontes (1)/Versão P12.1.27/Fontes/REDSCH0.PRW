#include 'protheus.ch'
#include 'parmtype.ch'
/*/
    {Protheus.doc} REDSCH0
    Schedule que executa rotinas REDSCH1 (Busca carrinho de compras pedido de compras) = WDG - Libera Pedidos 
    @type  Function
    @author Ricardo Junior
    @since 25/05/2018    
/*/

User Function REDSCH0(aEmpFil)

    Local nX        := 01

    Local aAux      := {}
    Local aPedidos  := {}
    Local aCotacao  := {}
    Local aXml      := {}  
    
    Local oXml      := NIL
   
    // WDG - Libera Pedidos;ID=41588054"
    cIdProc := AllTrim(FWUUIDV4())
    //U_REDSCH0({"01","01010004"})                                                                                                    
    U_WsLogBio("REDSCH0", 2, "ANTES DE LOGAR")
    RpcSetType(3)
    
    RpcSetEnv(aEmpFil[1], aEmpFil[2])
    
    U_WsLogBio("REDSCH0", 2, "RPCSETENV ---> " + aEmpFil[1] + " " + aEmpFil[2] )
    U_WsLogBio("REDSCH0", 2, "cFilAnt -----> " + cFilAnt)
    
    aAdd(aAux,{ {"PARAMETROS", 	"LAYOUT=WD"},;
			    {"FILIAL", 		aEmpFil[2]},;
			    {"LOGIN", 		"teste1"},;
			    {"XIDPROC", 	cIdProc},;
			    {"PASSWORD", 	"teste1"}})
	
	U_WsLogBio("REDSCH0", 2, "Antes REDWSDL2")
    aXml := U_RedWsdL2("WDG", aAux)
    U_WsLogBio("REDSCH0", 2, "DEPOIS REDWSDL2")
   
Return