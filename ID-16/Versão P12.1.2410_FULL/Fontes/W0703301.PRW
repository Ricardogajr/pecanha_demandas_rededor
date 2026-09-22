#INCLUDE "TOTVS.CH"
#INCLUDE "APWEBSRV.CH"

/*/{Protheus.doc} W0703301
Inclui, altera, deleta e devolve notas fiscais de entrada
@type function
@author anieli.rodrigues
@since 03/02/2017
@Project MAN0000007423041_EF_033
/*/
WSService W0703301 Description "Integração de Nota Fiscal de Entrada"
	WSData DocEntrada as DocumentoEntrada
	WSData DelDocEnt  as DeleteDocEnt
	WSData DevDocEnt  as DevolverDocEntrada
	WSData CancelDev  as CanDocDevolucao
	WSData cRet       as String

	WSMethod UpSertDocEntrada     Description "Inclui ou Altera uma Nota Fiscal de Entrada"
	WSMethod DeleteDocEntrada     Description "Exclui uma Nota Fiscal de Entrada"
	WSMethod DevolverDocEntrada   Description "Devolve uma Nota Fiscal de Entrada"
	WSMethod CancelarDocDevolucao Description "Cancelamento de Devolução"
EndWSService

WSMethod UpSertDocEntrada WSReceive DocEntrada WSSend cRet WSService W0703301
	Local oCabec   := ::DocEntrada:CabDocEnt
	Local oCorpo   := ::DocEntrada:ItDocEnt
	Local oParcela := ::DocEntrada:DupDocEnt
	Public cRetErr := ""

	Begin WSMethod
	::cRet := U_F0703301(oCabec, oCorpo, oParcela, 3)

	If !Empty(cRetErr)
		::cRet := cRetErr
	EndIf
End WSMethod
Return .T.

WSMethod DeleteDocEntrada WSReceive DelDocEnt WSSend cRet WSService W0703301
	Local oCabec := ::DelDocEnt
	Public cRetErr := ""

	Begin WSMethod
	::cRet := U_F0703301(oCabec, , , 5)

	If !Empty(cRetErr)
		::cRet := cRetErr
	EndIf
End WSMethod
Return .T.

WSMethod DevolverDocEntrada WSReceive DevDocEnt WSSend cRet WSService W0703301
	Local oCabec := ::DevDocEnt:CabDevDocEnt
	Local oCorpo := aSort(::DevDocEnt:ItensDevDocEnt, , , {|p1,p2| p1:cproduto + p1:cvalor  < p2:cproduto + p2:cvalor  })
	Public cRetErr := ""

	Begin WSMethod
	::cRet := U_F0703302(oCabec, oCorpo)

	If !Empty(cRetErr) 
		::cRet := cRetErr
	EndIf
End WSMethod 
Return .T.

WSMethod CancelarDocDevolucao WSReceive CancelDev WSSend cRet WSService W0703301
	Local oCabecCan   := ::CancelDev:CabCanDevDoc
	Public cRetErr := ""

	Begin WSMethod
	::cRet := U_F0703308(oCabecCan, 5, 2)

	If !Empty(cRetErr)
		::cRet := cRetErr
	EndIf
End WSMethod
Return .T.


WSStruct DocumentoEntrada
	WSData CabDocEnt as CabecDocEnt
	WSData ItDocEnt  as Array of ItensDocEnt
	WSData DupDocEnt as Array of Duplicatas
EndWSStruct

WSStruct CabecDocEnt
	WSData cBasCOFI as String
	WSData cBasCSLL as String
	WSData cBasECF3 as String
	WSData cBasECID as String
	WSData cBasECPM as String
	WSData cBasEFD  as String
	WSData cBasEFMP as String
	WSData cBasEICM as String
	WSData cBasEINS as String
	WSData cBasEIPI as String
	WSData cBasEPS3 as String
	WSData cBasIMP1 as String
	WSData cBasIMP2 as String
	WSData cBasIMP3 as String
	WSData cBasIMP4 as String
	WSData cBasIMP5 as String
	WSData cBasIMP6 as String
	WSData cBasPIS  as String
	WSData cBRICMS  as String
	WSData cCHVNFE  as String
	WSData cCIF     as String
	WSData cCODNFE  as String
	WSData cCONTSOC as String
	WSData cDESCONT as String
	WSData cDESPESA as String
	WSData cDOC     as String
	WSData cDTDIGIT as String
	WSData cEMISSAO as String
	WSData cESPECIE as String
	WSData cEST     as String
	WSData cFILREG  as String
	WSData cFOB_R   as String
	WSData cFORNECE as String
	WSData cFRETE   as String
	WSData cHORA    as String
	WSData cICMS    as String
	WSData cICMSRET as String
	WSData cINSS    as String
	WSData cIPI     as String
	WSData cIRRF    as String
	WSData cISS     as String
	WSData cLOJA    as String
	WSData cMENNOTA as String
	WSData cNFORIG  as String
	WSData cOPERAC  as String
	WSData cPREFIXO as String
	WSData cRECBMTO as String
	WSData cSEGURO  as String
	WSData cSERIE   as String
	WSData cSERORIG as String
	WSData cSTATUS  as String
	WSData cTIPO    as String
	WSData cVALBRUT as String
	WSData cVALCF3  as String
	WSData cVALCOFI as String
	WSData cVALCSLL as String
	WSData cVALEMB  as String
	WSData cVALFMP  as String
	WSData cVALICM  as String
	WSData cVALIMP1 as String
	WSData cVALIMP2 as String
	WSData cVALIMP3 as String
	WSData cVALIMP4 as String
	WSData cVALIMP5 as String
	WSData cVALIMP6 as String
	WSData cVALIPI  as String
	WSData cVALIRF  as String
	WSData cVALMERC as String
	WSData cVALPIS  as String
	WSData cVALPS3  as String
	WSData cVLCIDE  as String
	WSData cVLCPM   as String
	WSData cXCONSIG as String
	WSData CXTITFRO as String
EndWSStruct

WSStruct ItensDocEnt
	WSData cABATMAT as String
	WSData cALIQCF3 as String
	WSData cALQCIDE as String
	WSData cALIQINS as String
	WSData cALIQIRR as String
	WSData cALIQISS as String
	WSData cALIQPS3 as String
	WSData cALIQSOL as String
	WSData cALQCOF  as String
	WSData cALQCSL  as String
	WSData cALQFMP  as String
	WSData cALQIMP1 as String
	WSData cALQIMP2 as String
	WSData cALQIMP3 as String
	WSData cALQIMP4 as String
	WSData cALQIMP5 as String
	WSData cALQIMP6 as String
	WSData cALQPIS  as String
	WSData cBasECF3 as String
	WSData cBasECID as String
	WSData cBasECOF as String
	WSData cBasECSL as String
	WSData cBasEFMP as String
	WSData cBasEICM as String
	WSData cBasEINS as String
	WSData cBasEIPI as String
	WSData cBasEIRR as String
	WSData cBasEISS as String
	WSData cBasEPIS as String
	WSData cBasEPS3 as String
	WSData cBasIMP1 as String
	WSData cBasIMP2 as String
	WSData cBasIMP3 as String
	WSData cBasIMP4 as String
	WSData cBasIMP5 as String
	WSData cBasIMP6 as String
	WSData cBRICMS  as String
	WSData cCF      as String
	WSData cCFPS    as String
	WSData cCLasFIS as String
	WSData cCOD     as String
//	WSData cCONTA   as String
	WSData cCRDZFM  as String
	WSData cCUSTO   as String
	WSData cDESC    as String
	WSData cDESCICM as String
	WSData cDESPESA as String
	WSData cESTCRED as String
	WSData cICMSCOM as String
	WSData cICMSDIF as String
	WSData cICMSRET as String
	WSData cIPI     as String
	WSData cITEM    as String
	WSData cITEMORI as String
	WSData cITEMPC  as String
	WSData cLOCAL   as String
	WSData cMARGEM  as String
	WSData cNFORI   as String
	WSData cOPER    as String
	WSData cPEDIDO  as String
	WSData cPICM    as String
	WSData cQTDEDEV as String
	WSData cQTDPEDI as String
	WSData cQUANT   as String
	WSData cSEGURO  as String
	WSData cSERIORI as String
	WSData cTES     as String
	WSData cTIPO    as String
	WSData cTOTAL   as String
	WSData cUM      as String
	WSData cVALACRS as String
	WSData cVALCF3  as String
	WSData cVALCOF  as String
	WSData cVALCSL  as String
	WSData cVALDESC as String
	WSData cVALDEV  as String
	WSData cVALFMP  as String
	WSData cVALFRE  as String
	WSData cVALICM  as String
	WSData cVALIMP1 as String
	WSData cVALIMP2 as String
	WSData cVALIMP3 as String
	WSData cVALIMP4 as String
	WSData cVALIMP5 as String
	WSData cVALIMP6 as String
	WSData cVALINS  as String
	WSData cVALIPI  as String
	WSData cVALIRR  as String
	WSData cVALISS  as String
	WSData cVALPIS  as String
	WSData cVALPS3  as String
	WSData cVLCIDE  as String
	WSData cVUNIT   as String
	WSData cXDTVALI as String
	WSData cXLOTECT as String
	WSData cXSETOR  as String
	WSData cXCONSIG as String
EndWSStruct

WSStruct Duplicatas
	WSData cEMISSAO as String
	WSData cFORNECE as String
	WSData cLOJA    as String
	WSData cMOEDA   as String
	WSData cNOMFOR  as String
	WSData cNUM     as String
	WSData cPARCELA as String
	WSData cPREFIXO as String
	WSData cSALDO   as String
	WSData cTIPO    as String
	WSData cVALOR   as String
	WSData cVENCORI as String
	WSData cVENCREA as String
	WSData cVENCTO  as String
	WSData cVLCRUZ  as String
EndWSStruct

WSStruct DeleteDocEnt
	WSData cDOC     as String
	WSData cFILREG  as String
	WSData cFORNECE as String
	WSData cLOJA    as String
	WSData cSERIE   as String
EndWSStruct

WSStruct DevolverDocEntrada
	WSData CabDevDocEnt   as CabDevolveDocEnt
	WSData ItensDevDocEnt as Array of ItensDevolveDocEnt
EndWSStruct

WSStruct CabDevolveDocEnt
	WSData cDOC      as String
	WSData cFILREG   as String
	WSData cFORNECE  as String
	WSData cLOJA     as String
	WSData cSERIE    as String
	WsData cDTDEV    as String
	WsData cTAGDEV   as String
EndWSStruct

WSStruct ItensDevolveDocEnt
	WSData cPRODUTO as String
	WSData cPRCVEN  as String
	WSData cQTDVEN  as String
	WSData cVALOR   as String
	WSData cITEMORI as String
EndWSStruct

WSStruct CanDocDevolucao
	WSData CabCanDevDoc as CabCancelDevDoc
EndWSStruct

WSStruct CabCancelDevDoc
	WSData cDOC      as String
	WSData cFILREG   as String
	WSData cFORNECE  as String
	WSData cLOJA     as String
	WSData cSERIE    as String
	WsData cDTDEV    as String
	WSData cTAGDEV   as String
EndWSStruct

