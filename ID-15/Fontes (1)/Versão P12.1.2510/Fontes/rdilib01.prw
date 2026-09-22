#Include 'Protheus.ch'
#INCLUDE 'PARMTYPE.CH'
#INCLUDE 'FILEIO.CH'
Static nHdlArq	:= 0
Static lBOracle	:= Trim(TcGetDb()) = 'ORACLE'
//---------------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} RDIBFSM0
validação  de filial
@type function
@author Cris
@since 24/03/2017
@version 1.0
@param cTabAtu, character, (Nome da tabela)
@param cCnt, character, (Conteúdo do campo filial contido no arquivo a ser migrado)
@return ${return}, ${return_description}
/*///---------------------------------------------------------------------------------------------------------------------------
User Function RDIBFSM0(cTabAtu,cCnt)

	Local aArea		:= GetArea()
	Local cFilAux	:= xFilial(cTabAtu)
		
		if Empty(Alltrim(cCnt)) .AND.  !Empty(Alltrim(cFilAux)) 
		
			Return {.F., '008'}//008 - Tabela exclusiva. O arquivo não possui conteúdo.
			
		EndIf
	 	 		
		if !Empty(Alltrim(cCnt)) .AND.  Empty(Alltrim(cFilAux)) 
		
			Return {.F., '007'}//007- Tabela compartilhada. O arquivo possui conteúdo.
			
		EndIf
	
		if len(Alltrim(cCnt)) <>  len(Alltrim(cFilAux)) 
		
			Return {.F., '009'}//009 -  Tamanho do campo filial divergente.
			
		EndIf
		
		if !Empty(Alltrim(cCnt))
		
			dbSelectarea('SM0')
			if !SM0->(dbSeek(cEmpAnt+cCnt))
		
				Return {.F., '001'}// 001 - Filial Inexistente. A filial informada não existe no cadastro de empresa.
			
			EndIf
			
		EndIf
			
	RestArea(aArea)
	
Return {.T.,''} 
//---------------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} $RDIBF004
De Para de Filial
@type function
@author Cris
@since 11/04/2017
@version 1.0
@param cEmpDe, character, (Empresa de Origem)
@param cFilDe, character, (Filial de Origem)
@return ${return}, ${return_description}
/*///---------------------------------------------------------------------------------------------------------------------------
User Function RDIBF004(cEmpDe,cFilDe)
	
		Local aArea			:= GetArea()
		Local aAreaSZX		:= SZX->(GetArea())
		Local cFilPara		:= ''	
		Local cArqImp		:= ''
		Local cEmpFlAx		:= ''	

			//Caso o arquivo possua o codigo da empresa no nome do arquivo e não concatenada com a filial	
			if cEmpDe == 'A'
			
				SplitPath(U_GetDir(101) + AllTrim(QZ1->QZ1_DESTIN) + "\" ,,,@cArqImp)
				cEmpDe	:= Substring(cArqImp,5,2)
				cEmpFlAx	:= cEmpDe+cFilDe	
				
			Else
			
				cEmpFlAx	:= Alltrim(cEmpDe)+cFilDe
				
			EndIf
			
			//Caso a funçao seja configurada para um arquivo compartilhado, os parametros virão em branco.
			if !Empty(cEmpFlAx)
			
				dbSelectArea('SZX')
				SZX->(dbSetOrder(1))//SZX_EMPFIL (P10)
				if SZX->(dbSeek(cEmpFlAx))
			
					cFilPara	:= SZX->ZX_FILIALP
					
				EndIf

			EndIF
						
		RestArea(aArea)
		RestArea(aAreaSZX)
		
Return cFilPara
//---------------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} RDIBF003
De Para Centro de Custo
@type function
@author Cris
@since 11/04/2017
@version 1.0
@param cCCAtu, character, (Centro de Custo  "De")
@param cItemVl, character, (Item Contábil  "De")
@param cClasVl, character, (Classe Valor  "De")
@return ${return}, ${return_description}
/*///---------------------------------------------------------------------------------------------------------------------------
User Function RDIBF003(cCCAtu,cItemVl,cClasVl)
	
		Local aArea			:= GetArea()
		Local aAreaSZY		:= SZY->(GetArea())
		Local cCCPara		:= ''	
		Local cCCAux		:= ''
		
		Default cCCAtu		:= ''
		Default	cItemVl 	:= ''
		Default cClasVl		:= ''
		
			//CC Debito
			//CT2_CCD+CT2_ITEMD+CT2_CLVLDB
			//CC Crédito
			//CT2_CCC+CT2_ITEMC+CT2_CLVLCR	

			if !Empty(cCCAtu)
			
				cCCAux	:= Alltrim(cCCAtu)+Alltrim(cItemVl)+Alltrim(cClasVl)
				M->CT2_ITEMD	:= ''
				M->CT2_CLVLDB	:= ''
				M->CT2_ITEMC	:= ''
				M->CT2_CLVLCR	:= ''
								
				dbSelectArea('SZY')
				SZY->(dbSetOrder(1))//SZY_CCP10 (P10)
				if SZY->(dbSeek(cCCAux))
			
					cCCPara	:= SZY->ZY_CCP12
					
				EndIf
			
			EndIf
			
		RestArea(aArea)
		RestArea(aAreaSZY)
		
Return cCCPara
//---------------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} RDIBF005
Pesquisa se o código existe na tabela enviada como parametro.Tem a mesma finalidade da função EXISTCPO.
@type function
@author Cris
@since 14/06/2017
@version 1.0
@param cTabAtu, character, (Descrição do parâmetro)
@param cConteud, character, (Descrição do parâmetro)
@param nIndice, numérico, (Descrição do parâmetro)
@param cFilAtu, character, (Descrição do parâmetro)
@return ${return}, ${return_description}
/*///---------------------------------------------------------------------------------------------------------------------------
User Function RDIBF005(cChave1,cAlias,cChave,nOrdem)
Local xAlias,nSalvReg,nOldOrder,lRet

If ValType(cChave) == "U"
	cChave := cChave1
EndIf

xAlias := Alias()

DbSelectArea(cAlias)
nOldOrder := IndexOrd()

If Eof() .Or. RecC() == 0
	nSalvReg := 0
	
Else
	nSalvReg := RecNo()
EndIf

nOrdem := If(nOrdem == NIL,1,nOrdem)
DbSetOrder(nOrdem)

lRet := DbSeek(xFilial(cAlias)+cChave)

If !lRet
	//Help(2,"REGNOIS",STR0003,STR0004) //"Não existe registro relacionado a este código."###"Informe um código que exista no cadastro, ou efetue a implantação no programa de manutenção do cadastro."
EndIf

If nSalvReg > 0
	DbGoTo(nSalvReg)
EndIf

DbSetOrder(nOldOrder)

Return( lRet )
