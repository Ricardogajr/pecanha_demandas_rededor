//Bibliotecas
#Include "Protheus.ch"
#Include "TopConn.Ch" 
 
/*---------------------------------------------------------------------------------------------------------------------------*
 | P.E.:  MDTA680                                                                                                            |
 | Desc:  Ponto de entrada MVC no cadastro de emissor de atestado medico                                                                        |
 | Obs.:  Ao criar um P.E. em MVC com o mesmo nome do ModelDef, deixe o nome do prw com outro nome, por exemplo,             |
 |        MATAXXX_pe.prw                                                                                                     |
 | Ref.:  http://tdn.totvs.com/display/public/mp/Pontos+de+Entrada+para+fontes+Advpl+desenvolvidos+utilizando+o+conceito+MVC |
 *---------------------------------------------------------------------------------------------------------------------------*/
 
User Function MDTA680()
    Local aParam     := PARAMIXB
    Local xRet       := .T.
    Local oObj       := Nil
    Local cIdPonto   := ''
    Local cIdModel   := ''                             
    
    Local nOper      := 0
    Local cCampo     := ''
    Local cTipo      := ''
 
    //Se tiver parâmetros
    If aParam <> NIL  
                    
        //Pega informações dos parâmetros
        oObj     := aParam[1]
        cIdPonto := aParam[2]
        cIdModel := aParam[3]
         
        //Valida a abertura da tela
        If cIdPonto == "MODELVLDACTIVE"
            nOper := oObj:nOperation
             
            //Se for Exclusão, não permite abrir a tela
            //If nOper == 5
            //    xRet := .F.
            //EndIf
         
        //Pré configurações do Modelo de Dados
        ElseIf cIdPonto == "MODELPRE"
            xRet := .T.
         
        //Pré configurações do Formulário de Dados
        ElseIf cIdPonto == "FORMPRE"
            nOper  := oObj:GetModel(cIdPonto):nOperation
            cTipo  := aParam[4]
            cCampo := aParam[5]
             
            //Se for Alteração
            //If nOper == 4
            //    //Não permite alteração dos campos chave
            //    If cTipo == "CANSETVALUE" .And. Alltrim(cCampo) $ ("A6_COD.A6_AGENCIA.A6_NUMCON")
            //        xRet := .F.
            //    EndIf
            //EndIf
         
        //Adição de opções no Ações Relacionadas dentro da tela
        ElseIf cIdPonto == 'BUTTONBAR'
            xRet := {}
            //aAdd(xRet, {"* Titulo 1", "", {|| Alert("Botão 1")}, "Tooltip 1"})
            //aAdd(xRet, {"* Titulo 2", "", {|| Alert("Botão 2")}, "Tooltip 2"})
            //aAdd(xRet, {"* Titulo 3", "", {|| Alert("Botão 3")}, "Tooltip 3"})
         
        //Pós configurações do Formulário
        ElseIf cIdPonto == 'FORMPOS'
           xRet := U_VldNome(M->TNP_NOME)   
           IF !xRet             
              Aviso('Atenção', 'Nome do emitente Invalido Conforme Regra E-Social !', {'OK'}, 03)           
           Endif 
           If xRet                                                                    
              If Empty(M->TNP_UF)
                 Aviso('Atenção', 'UF Invalida Conforme Regra E-Social !', {'OK'}, 03)
                 xRet := .F.                                     
              Else           
                 xRet := EXISTCPO('SX5','12'+M->TNP_UF)
              Endif
           Endif
           If xRet 
              If LEN(ALLTRIM(M->TNP_NUMENT)) < 3
                 Aviso('Atenção', 'Numero na Entidade Classe Invalido Conforme Regra E-Social !', {'OK'}, 03)
                 xRet := .F. 
              Endif                                    
           Endif   
           nChave1 := u_BUSCATNP(M->TNP_FILIAL,M->TNP_EMITEN)
           If xRet            
              If INCLUI .AND. nChave1 > 0
                 Aviso('Atenção', 'Cod. Emit. de Atest/Aut Já Está Cadastrado !', {'OK'}, 03)
                 xRet := .F. 
              Endif                                    
           Endif   
           If xRet
              If ALTERA .AND. nChave1 = 0
                 Aviso('Atenção', 'Cod. Emit. de Atest/Aut Não Foi Cadastrado !', {'OK'}, 03)
                 xRet := .F.
              Endif                                     
           Endif
         
        //Validação ao clicar no Botão Confirmar
        ElseIf cIdPonto == 'MODELPOS'
           xRet := .T.   

        //Pré validações do Commit
        ElseIf cIdPonto == 'FORMCOMMITTTSPRE'
         
        //Pós validações do Commit
        ElseIf cIdPonto == 'FORMCOMMITTTSPOS'
             
        //Commit das operações (antes da gravação)
        ElseIf cIdPonto == 'MODELCOMMITTTS'
             
        //Commit das operações (após a gravação)
        ElseIf cIdPonto == 'MODELCOMMITNTTS'
            nOper := oObj:nOperation
            U_MDTASR8(M->TNP_FILIAL,M->TNP_EMITEN)
            //Se for inclusão, mostra mensagem de sucesso
            //If nOper == 3
            //    Aviso('Atenção', 'Banco criado com sucesso!', {'OK'}, 03)
            //EndIf
        EndIf
    EndIf
    cNada := " "
Return xRet   

User Function Buscatnp(cFil,cMat)
Local nReg1   := 0
Local cQry := " "

cQry := "SELECT TNP.R_E_C_N_O_ REGISTRO1 "
cQry += "  FROM " + RetSqlName("TNP") + " TNP " 
cQry += " WHERE TNP.TNP_FILIAL = '"+cFil+"' "
cQry += "   AND TNP.TNP_EMITEN = '"+cMat+"' "
cQry += "   AND TNP.D_E_L_E_T_ <> '*' "

TCQUERY cQry ALIAS "TSR8" NEW
dbSelectArea("TSR8")
If !TSR8->(EOF())
    nReg1 := TSR8->(REGISTRO1) 
Endif	
TSR8->(DBCLOSEAREA())

Return nReg1