#Include "Protheus.ch"
/*
//=============================================================================================\\
// Programa   E-Mail   | Autor  Diego Fraidemberge Mariano                | Data    02/08/24   ||
//=============================================================================================||
//Desc.     | Classe para envio de email. Busca dados nos parâmetros os métodos sempre retornam||
//          | .t. ou .f., e a MSG de erro esta armazenada no elemento cError.                  ||
//          | Use o método ExibeErro ou usar o elemento diretamente.                           ||
||Parametros  | PARAMIXB[1] - Contém informações sobre a situação atual do contrato.           ||
            | PARAMIXB[2] - Contém informações sobre a nova situação do contrato.              ||
||Ret Nil                                                                                      ||
//=============================================================================================//
*/
User Function CN100SIT()

// Possíveis situações do contrato
#DEFINE DEF_SCANC '01' 
//Cancelado
#DEFINE DEF_SELAB '02' 
//Em Elaboração
#DEFINE DEF_SEMIT '03' 
//Emitido
#DEFINE DEF_SAPRO '04' 
//Em Aprovação
#DEFINE DEF_SVIGE '05' 
//Vigente
#DEFINE DEF_SPARA '06' 
//Paralisado
#DEFINE DEF_SSPAR '07' 
//Sol Fina.
#DEFINE DEF_SFINA '08' 
//Finalizado
#DEFINE DEF_SREVS '09' 
//Revisão  
#DEFINE DEF_SREVD '10'
//Revisado
#Define Enter Chr(13) + Chr(10)

Local aAreaCN9   := CN9->(GetArea())
Local aAreaSCR   := SCR->(GetArea())
//Local cSitAt     := PARAMIXB[1] //Situação atual
Local cSitCT     := PARAMIXB[2] //Situação selecionada
Local cEZ_Tpcont := SuperGetMV("EZ_TPCONT", .F.)//*** Tipo de Contrato que enviam email
Local cGrupApr   := ""
Local cNumCtr    := ""
Local cRevis     := ""
Local cAprov     := "" 
Local cNivel     := ""
Local cEmail     := ""
Local cNumSCR    := ""
Local cFornece   := ""
Local cLojaFor   := ""
Local cTipo      := "CT"
Local cNomeFil   := ""
Local cCodFil    := ""
Default cNFornec := ""
Default cTipoRev := ""
Default cDescRev := ""
Default nValor   := ""
Default nSldAtu  := ""
Default cUniVige  := ""
Default cQtdVige  := ""

If cSitCT == '04' //.OR. cSitCT == '05'
    dbSelectArea("CN9")
    CN9->(dbSetOrder(1))    // 1 CN9_FILIAL+CN9_NUMERO+CN9_REVISA |7 CN9_FILIAL+CN9_NUMERO+CN9_SITUAC
    If CN9->(dbSeek(xFilial("CN9")+CN9->CN9_NUMERO+CN9->CN9_REVISA))
        If CN9->CN9_TPCTO $ cEZ_Tpcont
            cCodFil  := AllTrim(CN9->CN9_FILIAL)
            cNomeFil := AllTrim(FWFilialName())
            cGrupApr := CN9->CN9_APROV
            cNumCtr  := CN9->CN9_NUMERO
            cRevis   := CN9->CN9_REVISA
            nSldAtu  := StrTran(AllTrim(Transform(CN9->CN9_SALDO,"9999999999999.99")),".",",")
            nValor   := StrTran(AllTrim(Transform(CN9->CN9_VLATU,"9999999999999.99")),".",",")
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
            dbSelectArea("SCR")
            cNivel   := "01"
            SCR->(dbSetOrder(1)) //1 CR_FILIAL+CR_TIPO+CR_NUM+CR_NIVEL
            If SCR->(dbSeek(xFilial("SCR")+cTipo+CN9->CN9_NUMERO))
                cNumSCR := SCR->CR_NUM 
                If SCR->(dbSeek(xFilial("SCR")+cTipo+cNumSCR+SCR->CR_NIVEL))
                    While SCR->(CR_FILIAL+CR_NUM) == xFilial("SCR")+cNumSCR
                        If SCR->CR_NIVEL == cNivel
                            cAprov := SCR->CR_USER
                            cEmail += AllTrim(UsrRetMail(cAprov))+";"   
                            SCR->(dbSkip())  
                        Else
                            SCR->(dbSkip())
                        EndIf              
                    EndDo              
                    fWkApCHTML(cEmail,cNumCtr,cRevis,cNFornec,cTipoRev,cDescRev,nValor,nSldAtu,cUniVige,cQtdVige,cNivel,cNomeFil,cCodFil)
                    cEmail   := ""
                EndIf    
            EndIf  
        EndIf      	
    EndIf
EndIf
RestArea(aAreaCN9)
RestArea(aAreaSCR)
Return


/*/{Protheus.doc} fWkApCHTML
Função para gerar o HTML para e-mail
@type function
@version V 1.00
@author Diego Fraidemberge Mariano
@since 06/08/2024
@param cEmail,cNumCtr,cRevis,cNFornec,cTipoRev,cDescRev,nValor,nSldAtu,cUniVige,cQtdVige
@return character, HTML gerado
/*/
Static Function fWkApCHTML(cEmail,cNumCtr,cRevis,cNFornec,cTipoRev,cDescRev,nValor,nSldAtu,cUniVige,cQtdVige,cNivel,cNomeFil,cCodFil)

    Local cRet        := ""
    Local aArea       := {}
    Local aRetMail    := {}
  
    Default cCodFil  := ""
    Default cNomeFil := ""
    Default cNivel   := ""  
    Default cNFornec := ""
    Default cTipoRev := ""
    Default cDescRev := ""
    Default cValor   := ""
    Default cSldAtu  := ""
    Default cUniVige := ""
    Default cQtdVige := ""
    Default cMailCC  := ""
    Default cEmail   := ""
    Default cNumCtr  := ""
    Default cRevis   := ""
    Default cNota    := ""    
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
    cRet += '           <p> O contrato '+cNumCtr+' encontra-se disponível para aprovação na rotina de liberação de documentos. </p>'													                                                                        																																										
    cRet += ''																																																
    cRet += '			<p> Filial: '+cCodFil+' - '+cNomeFil+'</p>'																											                                
    cRet += '			<p> Número do Contrato: '+cNumCtr+'</p>'																											                                
    cRet += '			<p> Fornec: '+cNFornec+'</p>'																											                                
    cRet += '			<p> Tipo da Revisão: '+cTipoRev+'</p>'																											                                
    cRet += '			<p> Descrição da Revisão: '+cDescRev+'</p>'																											                                
    cRet += '			<p> Valor: R$ '+nValor+'</p>'																											                                
    cRet += '			<p> Saldo atual do contrato: R$ '+nSldAtu+'</p>'																											                                
    cRet += '			<p> Vigência: '+cValToChar(cQtdVige)+' - '+cUniVige+'</p>'																											                                
    cRet += '           <p> Nível: '+cNivel+'</p>'		
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
 
    xTitulo := xTitulo+" "+cNumCtr+" - Filial "+cNomeFil+" "+xTitul2+" "+cNFornec

    aRetMail := u_xfSendMail(cEmail, cMailCC, xTitulo, cRet)

    RestArea(aArea)

Return(aRetMail)
