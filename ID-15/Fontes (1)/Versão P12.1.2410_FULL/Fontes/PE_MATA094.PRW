#Include 'Protheus.ch'

User Function MATA094()
/*=====================================================================================================================================*
Fonte:      MATA094 
Função:     Ponto de Entrada executado na rotina de Aprovação de Documentos:
			1. Enviar email após aprovação do contrato de Medição 
			2. Enviar email após aprovaçao para o próximo nível de aprovação
            3. Enviar email para o fornecedor após finalização das liberações
Analista:   Diego Fraidemberge Mariano - EZ4
Data:       05/08/2024
Empresa:    Rede D'Or
*=====================================================================================================================================*/
#Define Enter Chr(13) + Chr(10)

Local xRetorno := .T.
Local aParam     := PARAMIXB
Local cEZ_Tpcont:= SuperGetMV("EZ_TPCONT", .F.)//*** Tipo de Contrato que enviam email
Local oObj       := ''
Local cIdPonto   := ''
Local cIdModel   := ''
Local lIsGrid    := .F.
Local cNumSCR    := ""
Local cAprov     := ""
Local cEmail     := ""
Local cRevis     := ""
Local cNumCtr    := ""
Local cNivel     := ""
Local cFornece   := ""
Local cLojaFor   := ""
Local cNivelProx := ""
Local cTipo      := ""
Local aAreaSCR   := SCR->(GetArea())
Local aAreaSA2   := SA2->(GetArea())
Local aAreaCNE   := CNE->(GetArea())
Local aAreaCNA   := CNA->(GetArea())
Local aArea		 := GetArea()
Local cTpCto     := ""
Local nMulta     := ""
Local nJuros     := ""
Local cNumPla    := ""

Default cNFornec := ""
Default cTipoRev := ""
Default cDescRev := ""
Default nValor   := ""
Default nSldAtu  := ""
Default cUniVige  := ""
Default cQtdVige  := ""
    
If ParamIxb <> Nil .And. Len(ParamIxb) >= 2
    oObj     := ParamIxb[1]
    cIdPonto := ParamIxb[2]

    If cIdPonto == 'BUTTONBAR'
        xRetorno := {}
        Aadd( xRetorno , U_F1206801(oObj:nOperation,1) )
        Aadd( xRetorno , U_F1206801(oObj:nOperation,2) )
        Aadd( xRetorno , U_F1206801(oObj:nOperation,3) )
    EndIf
EndIf

If aParam <> NIL
      
	oObj       	:= aParam[1]
	cIdPonto   	:= aParam[2]
	cIdModel   	:= aParam[3]
	lIsGrid    	:= ( Len( aParam ) > 3 )    

    If cIdPonto == 'MODELCOMMITNTTS'        
        
        If SCR->CR_TIPO == "CT" .OR. SCR->CR_TIPO == "RV"
            cNumCtr := Posicione("CN9",1,xFilial("CN9")+AllTrim(SCR->CR_NUM),"CN9_NUMERO")
            cTpCto := Posicione("CN9",1,xFilial("CN9")+AllTrim(SCR->CR_NUM),"CN9_TPCTO")
            cFilCt := Posicione("CN9",1,xFilial("CN9")+AllTrim(SCR->CR_NUM),"CN9_FILIAL")
        Else 
            cNumCtr := Posicione("CNE",4,xFilial("CNE")+AllTrim(SCR->CR_NUM),"CNE_CONTRA")
            cFilCt := Posicione("CND",1,xFilial("CND")+AllTrim(cNumCtr),"CND_FILCTR")
            cTpCto := Posicione("CN9",1,cFilCt+AllTrim(cNumCtr),"CN9_TPCTO")
            cRevis := Posicione("CNE",4,xFilial("CNE")+AllTrim(cNumCtr),"CNE_REVISA")
        EndIf
        If cTpCto $ cEZ_Tpcont
            DBSELECTAREA("SCR")
            DBSETORDER(1)
            
            If SCR->(DBSEEK(XFILIAL("SCR")+SCR->CR_TIPO+SCR->CR_NUM+SCR->CR_NIVEL))
                cCodFil  := AllTrim(SCR->CR_FILIAL)
                cNomeFil := AllTrim(FWFilialName())  
                DBSELECTAREA("CN9")
                DBSETORDER(1)
                If CN9->(DBSEEK(cFilCt+cNumCtr+cRevis))
                    nSldAtu  := StrTran(AllTrim(Transform(CN9->CN9_SALDO,"9999999999999.99")),".",",")
                    cUniVige := CN9->CN9_UNVIGE
                    If cUniVige == "1"
                        cUniVige := "Dias"
                    ElseIf cUniVige == "2"
                        cUniVige := "Meses"
                    ElseIf cUniVige == "3"
                        cUniVige := "Anos"
                    EndIf
                    cQtdVige := CN9->CN9_VIGE
                    cTipoRev := CN9->CN9_REVATU
                    cDescRev := allTrim(POSICIONE("CN0",1,XFILIAL("CN0")+CN9->CN9_REVATU,"CN0_DESCRI"))
                    cFornece := Posicione("CNA",1,xFilial("CNA")+AllTrim(cNumCtr)+cRevis,"CNA_FORNEC")
                    cLojaFor := Posicione("CNA",1,xFilial("CNA")+AllTrim(cNumCtr)+cRevis,"CNA_LJFORN")
                    cNFornec := AllTrim(Posicione("SA2",1,xFilial("SA2")+AllTrim(cFornece)+AllTrim(cLojaFor),"A2_NOME"))
                    cTipo   := SCR->CR_TIPO
                    cNumSCR := SCR->CR_NUM
                    cNumPla := Posicione("CXN",1,xFilial("CXN")+AllTrim(cNumCtr)+cRevis,"CXN_NUMPLA")
                    

                    If SCR->CR_TIPO == "MD"
                        cNumMed := AllTrim(SCR->CR_NUM)
                        nMulta := Posicione("CNE",1,xFilial("CNE")+cNumCtr+cRevis+cNumPla+cNumMed,"CNE_XMULTA")
                        nJuros := Posicione("CNE",1,xFilial("CNE")+cNumCtr+cRevis+cNumPla+cNumMed,"CNE_XJUROS")
                        nValor   :=  StrTran(AllTrim(Transform(Posicione("CND",4,xFilial("CND")+AllTrim(SCR->CR_NUM),"CND_VLTOT"),"9999999999999.99")),".",",")
                        If nMulta <> 0
                            nMulta   := StrTran(AllTrim(Transform(nMulta,"9999999999999.99")),".",",")
                        Else
                            nMulta   := "0,00"
                        EndIf
                        If nJuros <> 0
                            nJuros   := StrTran(AllTrim(Transform(nJuros,"9999999999999.99")),".",",")
                        Else
                            nJuros   := "0,00"
                        EndIf
                        cNivel  := SCR->CR_NIVEL
                        cNivelProx := StrZero(val(cNivel)+1, 2)   
                        
                        While SCR->(CR_FILIAL+CR_NUM) == xFilial("SCR")+cNumSCR
                            If SCR->CR_NIVEL == cNivelProx
                                cAprov := SCR->CR_USER
                                cEmail += AllTrim(UsrRetMail(cAprov))+";"    
                                SCR->(dbSkip()) 
                            Else
                                SCR->(dbSkip()) 
                            EndIf 
                        EndDo
                        If cEmail <> ""
                            fWkApMHTML(cEmail,cNumCtr,cNumMed,cRevis,cNFornec,nValor,nSldAtu,cUniVige,cQtdVige,cNivelProx,nMulta,nJuros,cNomeFil,cCodFil)
                        EndIf
                    EndIf
                    If SCR->CR_TIPO == "CT" .OR. SCR->CR_TIPO == "RV"
                        nValor := StrTran(AllTrim(Transform(CN9->CN9_VLATU,"9999999999999.99")),".",",")
                        cNivel  := SCR->CR_NIVEL
                        cNivelProx := StrZero(val(cNivel)+1, 2)               
                        While SCR->(CR_FILIAL+CR_NUM) == xFilial("SCR")+cNumSCR
                            If SCR->CR_NIVEL == cNivelProx
                                cAprov := SCR->CR_USER
                                cEmail += AllTrim(UsrRetMail(cAprov))+";"    
                                SCR->(dbSkip()) 
                            Else
                                SCR->(dbSkip()) 
                            EndIf 
                        EndDo
                        If cEmail <> ""
                            fWkApCHTML(cEmail,cNumCtr,cRevis,cNFornec,cTipoRev,cDescRev,nValor,nSldAtu,cUniVige,cQtdVige,cNivelProx,cNomeFil,cCodFil)
                        EndIf    
                    EndIf
                EndIf    
            EndIf    
        EndIf    
    EndIf
EndIf

RestArea(aArea)
RestArea(aAreaSCR)
RestArea(aAreaSA2)
RestArea(aAreaCNE)
RestArea(aAreaCNA)
Return xRetorno

/*/{Protheus.doc} fWkApMHTML
Função para gerar o HTML para e-mail para o aprovador - Medição
@type function
@version V 1.00
@author Diego Fraidemberge Mariano
@since 06/08/2024
@param cEmail,cNumCtr,cNumMed,cRevis,cNFornec,nValor,nSldAtu,cUniVige,cQtdVige,cNivelProx,nMulta,nJuros,cNomeFil,cCodFil
@return character, HTML gerado
/*/
Static Function fWkApMHTML(cEmail,cNumCtr,cNumMed,cRevis,cNFornec,nValor,nSldAtu,cUniVige,cQtdVige,cNivelProx,nMulta,nJuros,cNomeFil,cCodFil)

    Local cRet        := ""
    Local aArea       := {}
    Local aRetMail    := {}
    
    Default cCodFil  := ""
    Default cNomeFil := ""
    Default cNivelProx   := ""
    Default nMulta   := ""
    Default nJuros   := ""
    Default cNFornec := ""
    Default cTipoRev := ""
    Default cDescRev := ""
    Default nValor   := ""
    Default nSldAtu  := ""
    Default cUniVige := ""
    Default cQtdVige := ""
    Default cMailCC  := ""
    Default cEmail   := ""
    Default cNumCtr  := ""
    Default cNumMed  := ""
    Default cRevis   := ""
    Default cNota    := ""    
    Default cObra    := ""
    Default xTitulo  := "Notificação de Aprovação de Medição do Contrato "
    Default xTitul2  := "Fornecedor "

    //--- Monta formulario html
    cRet := '<style>'																																														
    cRet += 'blockquote {'																																													
    cRet += '    position: relative;'																																										
    cRet += '    padding-left: 1em;'																																										
    cRet += '    border-left: 0.2em solid #e50303;'																																							
    cRet += "    font-family: 'Roboto', serif;"																																								
    cRet += '    font-size: 0.8em;'																																											
    cRet += '    line-height: 1.5em;'																																										
    cRet += '    font-weight: 100;'																																											
    cRet += '}'																																																
    cRet += '</style>'																																														
    cRet += '<table border="0" cellpadding="1" cellspacing="1" style="width:1128px">'																														
    cRet += '	<tbody>'																																													
    cRet += '		<tr>'																																													
    cRet += '			<td style="text-align:cEnter; width:927px"><span style="font-size:20px"><span style="font-family:Lucida Sans Unicode,Lucida Grande,sans-serIf"><strong>Aprovação da Medição de Contrato</strong></span></span></td>'    + Enter
    cRet += '		</tr>'																																													
    cRet += '		<tr>'																																													
    cRet += '			<td colspan="2" style="width:188px">&nbsp;</td>'																																	
    cRet += '		</tr>'																																													
    cRet += '		<tr>'																																													
    cRet += '			<td colspan="2" style="width:188px">'																																				
    cRet += '			<hr/>'	                                                                                                                                                                            
    cRet += '           <p> Prezado gestor(a), </p>'																																						
    cRet += '           <p> A medição do contrato '+AllTrim(cNumCtr)+' encontra-se disponível para aprovação na rotina de liberação de documentos. </p>'													                                                                        																																										
    cRet += ''			
    cRet += '			<p> Filial: '+cCodFil+' - '+cNomeFil+'</p>'																																														
    cRet += '			<p> Número da Medição: '+cNumMed+'</p>'																											                                
    cRet += '			<p> Fornec: '+cNFornec+'</p>'																											                                
    cRet += '			<p> Valor Total: R$ '+nValor+'</p>'																											                                
    cRet += '			<p> Multa: R$ '+nMulta+'</p>'																									                                
    cRet += '			<p> Juros: R$ '+nJuros+'</p>'																											                                
    cRet += '			<p> Vigência: '+cValToChar(cQtdVige)+' - '+cUniVige+'</p>'																											                                    
    cRet += '			<p> Saldo atual do contrato: R$ '+nSldAtu+'</p>'	
    cRet += '           <p> Nível: '+cNivelProx+'</p>'   																										                                
    cRet += ''																																																
    cRet += '			<p> Favor realizar a aprovação. </p>'																																			
    cRet += ''																																																
    cRet += '		</tr>'																																													
    cRet += '		<tr>'																																													
    cRet += '			<td colspan="2" style="width:188px">&nbsp;</td>'																																	
    cRet += '		</tr>'																																													
    cRet += '	</tbody>'																																												    
    cRet += '</table>'																																														
    cRet += ''																																															

    xTitulo := xTitulo+" - "+AllTrim(cNumCtr)+" - Filial "+cNomeFil+" "+xTitul2+" "+cNFornec 

    aRetMail := u_xfSendMail(cEmail, cMailCC, xTitulo, cRet)

    RestArea(aArea)

Return(aRetMail)

/*/{Protheus.doc} fWkApCHTML
Função para gerar o HTML para e-mail para o aprovador - Contrato
@type function
@version V 1.00
@author Diego Fraidemberge Mariano
@since 06/08/2024
@param cEmail,cNumCtr,cRevis,cNFornec,cTipoRev,cDescRev,nValor,nSldAtu,cUniVige,cQtdVige,cNivelProx,cNomeFil,cCodFil
@return character, HTML gerado
/*/
Static Function fWkApCHTML(cEmail,cNumCtr,cRevis,cNFornec,cTipoRev,cDescRev,nValor,nSldAtu,cUniVige,cQtdVige,cNivelProx,cNomeFil,cCodFil)

    Local cRet        := ""
    Local aArea       := {}
    Local aRetMail    := {}
  
    Default cCodFil  := ""
    Default cNomeFil := ""
    Default cNivelProx   := ""
    Default cNFornec := ""
    Default cTipoRev := ""
    Default cDescRev := ""
    Default nValor   := ""
    Default nSldAtu  := ""
    Default cUniVige := ""
    Default cQtdVige := ""
    Default cMailCC  := ""
    Default cEmail   := ""
    Default cNumCtr  := ""
    Default cRevis   := ""
    Default cNota    := ""    
    Default cObra    := ""
    Default xTitulo  := "Notificação - Aprovação Contrato "
    Default xTitul2  := "Fornecedor "

    //--- Monta formulario html
    cRet := '<style>'																																														
    cRet += 'blockquote {'																																													
    cRet += '    position: relative;'																																										
    cRet += '    padding-left: 1em;'																																										
    cRet += '    border-left: 0.2em solid #e50303;'																																							
    cRet += "    font-family: 'Roboto', serif;"																																								
    cRet += '    font-size: 0.8em;'																																											
    cRet += '    line-height: 1.5em;'																																										
    cRet += '    font-weight: 100;'																																											
    cRet += '}'																																																
    cRet += '</style>'																																														
    cRet += '<table border="0" cellpadding="1" cellspacing="1" style="width:1128px">'																														
    cRet += '	<tbody>'																																													
    cRet += '		<tr>'																																													
    cRet += '			<td style="text-align:cEnter; width:927px"><span style="font-size:20px"><span style="font-family:Lucida Sans Unicode,Lucida Grande,sans-serIf"><strong>Aprovação de Contrato</strong></span></span></td>'    + Enter
    cRet += '		</tr>'																																													
    cRet += '		<tr>'																																													
    cRet += '			<td colspan="2" style="width:188px">&nbsp;</td>'																																	
    cRet += '		</tr>'																																													
    cRet += '		<tr>'																																													
    cRet += '			<td colspan="2" style="width:188px">'																																				
    cRet += '			<hr/>'	                                                                                                                                                                            
    cRet += '           <p> Prezado gestor(a), </p>'																																						
    cRet += '           <p> O contrato '+AllTrim(cNumCtr)+' encontra-se disponível para aprovação na rotina de liberação de documentos. </p>'													                                                                        																																										
    cRet += ''	
    cRet += '			<p> Filial: '+cCodFil+' - '+cNomeFil+'</p>'																																																	
    cRet += '			<p> Número do Contrato: '+AllTrim(cNumCtr)+'</p>'																											                                
    cRet += '			<p> Fornec:: '+cNFornec+'</p>'																											                                
    cRet += '			<p> Tipo da Revisão: '+cTipoRev+'</p>'																											                                
    cRet += '			<p> Descrição da Revisão: '+cDescRev+'</p>'																											                                
    cRet += '			<p> Valor: R$ '+nValor+'</p>'																											                                
    cRet += '			<p> Saldo atual do contrato: R$ '+nSldAtu+'</p>'																											                                
    cRet += '			<p> Vigência: '+cValToChar(cQtdVige)+' - '+cUniVige+'</p>'																											                                
    cRet += '           <p> Nível: '+cNivelProx+'</p>'		
    cRet += ''																																																
    cRet += '			<p> Favor realizar a aprovação. </p>'																																			
    cRet += ''																																																
    cRet += '		</tr>'																																													
    cRet += '		<tr>'																																													
    cRet += '			<td colspan="2" style="width:188px">&nbsp;</td>'																																	
    cRet += '		</tr>'																																													
    cRet += '	</tbody>'																																												    
    cRet += '</table>'																																														
    cRet += ''																																															
 
    xTitulo := xTitulo+" "+AllTrim(cNumCtr)+" - Filial "+cNomeFil+" "+xTitul2+" "+cNFornec

    aRetMail := u_xfSendMail(cEmail, cMailCC, xTitulo, cRet)

    RestArea(aArea)

Return(aRetMail)
