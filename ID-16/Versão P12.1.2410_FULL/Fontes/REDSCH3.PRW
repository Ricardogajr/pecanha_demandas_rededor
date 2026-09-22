#include "PROTHEUS.CH"
#include "rwmake.ch"

/*/{Protheus.doc} REDSCH3
    Rotina de Schedule para enviar a confirmação do pedido para o Bionexo.
    @type  Function
    @author Ricardo Junior
    @since 25/07/17
    @version 1.0
/*/
*------------------------------*
User Function REDSCH3(aEmpFil)
*------------------------------*
    
    Local cQuery    := ""
    Local cAliasSC7 := ""
    Local cTabSc7   := ""
    Local aZRecNo	:= {}
    Local aAux      := {}
    Local aXml      := {}
    Local cCodus    :=RetCodUsr()    
    Local nx
    Local cAliasSC7 := ""
    U_WsLogBio("REDSCH3", 2, "ANTES DE LOGAR")
    
    RpcSetType(3)
    RpcSetEnv(aEmpFil[1], aEmpFil[2])
    
    cAliasSC7 := GetNextAlias()
    cTabSc7   := RetSqlName("SC7")
    
    U_WsLogBio("REDSCH3", 2, "RPCSETENV ---> " + aEmpFil[1] + " " + aEmpFil[2] )
    U_WsLogBio("REDSCH3", 2, "cFilAnt -----> " + cFilAnt)
    
    cQuery := " SELECT *  FROM " + cTabSc7 + " SC7 " + CRLF
    cQuery += " WHERE D_E_L_E_T_ = ' ' " + CRLF
    cQuery += " AND C7_XNUM != ' ' " + CRLF
    cQuery += " AND C7_FILIAL = '"+cFilAnt+"' " + CRLF
    cQuery += " AND C7_XFLGWBS = ' ' " + CRLF
    cQuery += " AND C7_XIDBIO != ' ' " + CRLF
    cQuery += " AND C7_XIDART != ' ' " + CRLF
    cQuery += " ORDER BY C7_FILIAL, C7_NUM " + CRLF
    
    
    If Select(cALiasSC7) > 0
        (cALiasSC7)->(DbCloseArea())
    EndIf

    DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSC7,.T.,.T.)	
    
    DbSelectArea("SC7")
    SC7->(DbSetOrder(01))
    cIdProc := AllTrim(FWUUIDV4())	
    While !(cALiasSC7)->(Eof())
        
        cFil    := (cALiasSC7)->C7_FILIAL
        cNum    := (cALiasSC7)->C7_NUM
        cItem   := (cALiasSC7)->C7_ITEM
        cNumExt := (cALiasSC7)->C7_XNUM
        
        aAdd( aAux,{ {"PARAMETROS", "LAYOUT=WB"},;
                	{"FILIAL", 		cFil},;
                	{"LOGIN", 		"teste1"},;
                	{"PASSWORD", 	"teste1"},;
                	{"XIDPROC",		cIdProc},;
                	{"C7NUM"     , (cALiasSC7)->C7_NUM},;                    		
                	{"A2CGC",		TransForm(Posicione("SA2", 1, xFilial("SA2")+(cALiasSC7)->C7_FORNECE+(cALiasSC7)->C7_LOJA, "A2_CGC"), "@R 99.999.999/9999-99")};
                	})	 
                	
                	       
        While !(cALiasSC7)->(Eof()) .And. cFil == (cALiasSC7)->C7_FILIAL .And. cNum  == (cALiasSC7)->C7_NUM
        	aConv := U_FConvUmBio((cALiasSC7)->C7_PRODUTO, (cALiasSC7)->C7_QUANT, 00, "B")                        
            aAdd( aAux, { 	{"C7FILIAL"  , (cALiasSC7)->C7_FILIAL}	,;
                    		{"C7ITEM"    , (cALiasSC7)->C7_ITEM}   	,;
                    		{"C7QTSEGUM" , cValToChar(aConv[01])},;
                    		{"C7PRODUTO" , (cALiasSC7)->C7_PRODUTO} ,;
                    		{"C7XIDBIO"  , (cALiasSC7)->C7_XIDBIO}	,;
                    		{"C7XITBIO"  , (cALiasSC7)->C7_XIDART}	,;//(cALiasSC7)->C7_XITBIO
                    		{"C7XNUMEXT" , (cALiasSC7)->C7_XNUM}	,;
                    		{"C7OBS" 	 , EncodeUTF8(_noTags((cALiasSC7)->C7_OBS))}; 
                    		})
             aAdd(aZRecNo, (cALiasSC7)->R_E_C_N_O_)       		
            (cALiasSC7)->(DbSkip())                    
        EndDo

        aXml := U_RedWsdL2("WBS", aAux)
        
        If ( aXml[1] == "1" )
        	For nX := 01 To Len(aZRecNo)
        		SC7->(DbGoTo(aZRecNo[nX]))
    		    RecLock("SC7", .F.)
    		    	SC7->C7_XFLGWBS := "S"
                	SC7->C7_XIDPROC := cIdProc
                SC7->(MsUnlock())	            
            Next nX 
        ElseIf ( aXml[1] == "-1" )
            cMsg := aXml[2]  
            For nX := 01 To Len(aZRecNo)
	            SC7->(DbGoTo(aZRecNo[nX]))
	    		RecLock("SC7", .F.)
	    			SC7->C7_XFLGWBS := "N"
	            SC7->(MsUnlock())
	            U_REDA006(SC7->C7_FILIAL, "2",SC7->C7_NUM, SC7->C7_ITEM, cCodus,cMsg,SC7->C7_XIDBIO,)
	        Next nX                		    
        EndIf 
            
        //oWs := Nil
        aAux := {} 
        aXml := {}
    EndDo

    (cALiasSC7)->(DbCloseArea())
Return
