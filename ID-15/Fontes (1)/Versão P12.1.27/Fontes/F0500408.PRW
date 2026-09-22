#Include 'Protheus.ch'
#INCLUDE "FWMVCDEF.CH" 
#INCLUDE "FWBROWSE.CH"
//---------------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} F0500408
Retorna a descrição do conforme codigo associado
@type function
@author Cris
@since 23/11/2016
@param ${cNTab}, ${Caracter}, ${Nome da Tabela}
@param ${cCpoInf}, ${Caracter}, ${Chave de busca}
@param ${cCpoRet}, ${Caracter}, ${Campo a retornar}
@return ${Caracter}, ${Descrição do Campo}
@version P12.1.7
@Project MAN0000007423039_EF_004
/*///---------------------------------------------------------------------------------------------------------------------------
User Function F0500408(cNTab,cCpoInf,cCpoRet)

	Local oModAtu	:=	FWModelActive()
	Local cFilProp	:=	oModAtu:GetModel("TRFDETAIL"):GEtValue("FILIPROP")
	Local cFilAtu	:=	oModAtu:GetModel("TRFDETAIL"):GEtValue("TMP_FILIAL")
	Local cFilTab	:=  iif(Empty(xFilial((cNTab))),xFilial((cNTab)),iif(len(Alltrim(xFilial((cNTab))))<=4,xFilial((cNTab)),IIf(!Empty(cFilProp),cFilProp,cFilAtu)))
	Local cBkpFil	:= cFilAnt
	Local cNomDept	:= ''
	Local aAreaAtu	:= (cNTab)->(GetArea())
		
		dbSelectArea((cNTab))
		(cNTab)->(dbSetOrder(1))
		if (cNTab)->(DbSeek(cFilTab + cCpoInf))
		
			cNomDept	:= (cNTab)->&(cCpoRet)

		EndIf
		
		(cNTab)->(DbSeek(cBkpFil))
		
		RestArea(aAreaAtu)
		
Return cNomDept