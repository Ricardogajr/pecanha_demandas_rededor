#Include "Protheus.ch"
#Include "TopConn.Ch" 
 
/*---------------------------------------------------------------------------------------------------------------------------*
 | P.E.:  GPEA020                                                                                                            |
 | Desc:  Ponto de entrada MVC no cadastro de Dependentes PROTHEUS 12                                                                       |
 | Obs.:  Ao criar um P.E. em MVC com o mesmo nome do ModelDef, deixe o nome do prw com outro nome, por exemplo,             |
 |        MATAXXX_pe.prw                                                                                                     |
 | Ref.:  http://tdn.totvs.com/display/public/mp/Pontos+de+Entrada+para+fontes+Advpl+desenvolvidos+utilizando+o+conceito+MVC |
 *---------------------------------------------------------------------------------------------------------------------------*/
 
User Function GPEA020()
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
            xRet := .T.
         
        //Validação ao clicar no Botão Confirmar
        ElseIf cIdPonto == 'MODELPOS'             
           // oModel1 	:= oObj //FWModelActive()
            //oGrid1   := oModel1:GetModel("GPEA020_SRB")
            //oStruct1 := oGrid1:GetStruct()
            //aCampos	:= oStruct1:GetFields()
            //lCICOK  := .T.
            //If !oGrid1:IsDeleted()
            //   For px := 1 to oGrid1:Length()   
              //     oGrid1:GoLine( px )
            //       For nx := 1 To Len(aCampos) 
          //             cNome  := oGrid1:GetValue("RB_NOME")
		//	           nIdade := CALC_IDADE(dDataBase,oGrid1:GetValue("RB_DTNASC"))
			//           nCic   := oGrid1:GetValue("RB_CIC") 
          //             If Empty(nCIC) .AND. nIdade > 8
          //                lCICOK := .F.
          //             Endif 
          //         Next
          //     Next
          //  Endif
          //  if lCICOK
          //     xRet := .T.
          //  else
          //     Aviso('Atenção', 'Dependente > 8 Anos Sem CPF', {'OK'}, 03)
          //     xRet := .F.
         //   endif
        //Pré validações do Commit
        ElseIf cIdPonto == 'FORMCOMMITTTSPRE'
            xRet := .T.
         
        //Pós validações do Commit
        ElseIf cIdPonto == 'FORMCOMMITTTSPOS'
             
        //Commit das operações (antes da gravação)
        ElseIf cIdPonto == 'MODELCOMMITTTS'
             
        //Commit das operações (após a gravação)
        ElseIf cIdPonto == 'MODELCOMMITNTTS'
            nOper := oObj:nOperation
             
            //Se for inclusão, mostra mensagem de sucesso
            //If nOper == 3
            //    Aviso('Atenção', 'Banco criado com sucesso!', {'OK'}, 03)
            //EndIf
        EndIf
    EndIf
Return xRet   

