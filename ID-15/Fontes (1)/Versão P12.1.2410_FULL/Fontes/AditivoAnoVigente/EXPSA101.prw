#Include 'Protheus.ch'
#Include 'Protheus.ch'
Static lBOracle		:= Trim(TcGetDb()) = 'ORACLE'
Static cNomeArq		:= ''
Static cCpoFil		:= ''
Static cCpos		:= ''
//---------------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} EXPSA101
(long_description)
@type function
@author Cris
@since 01/06/2017
@version 1.0
@return ${return}, ${return_description}
/*///---------------------------------------------------------------------------------------------------------------------------
User Function EXPSA101() 

	Local aEmpresa	:= {}
	Local aRetCpos	:= {}
	Local aRecSA1	:= {}
	Local cTabDD	:= ''
	Local nEmp		:= 0
	Local nCli		:= 0
	Local lNMvto	:= .F.
	Local lExArq	:= .F.
	Local lTela		:= .F.//!IsBlind()
		
		//Somente gravo o primeiro cliente no arquivo se o mesmo foi localizado em alguma  movimentação financeira
		cNomeArq	:= 'SA1_exp_'+Dtos(MsDate())+StrTran(Time(),":",'')+'.txt'	

		//Seleciona os campos da tabela
		U_SelSX3('SA1',@aRetCpos)
		
		cTabDD	:= GetNextAlias()
	
		Processa( {|| SelecDd('SA1',aRetCpos,@cTabDD)},'Selecionando Registros da tabela SA1....')
		
		if !(cTabDD)->(Eof())

			//Selecionando Diretório
			if U_SelDirGrv('',cNomeArq)			
				
				U_DescReg(Strtran(cCpos,',',';'),.F.)
			
				Processa( {|| ExpDD(aRetCpos,cTabDD,'SA1',.T.,'2')},'Exportando registros. Aguarde....') 
				
			EndIf
		
		Else
		
			Help('',1,'EXPTAB001_01',,"Sem informações.",1,0,,,,,,{"Verifique os parametros informados, para os mesmos, não existem registros a exportar."})
									
		EndIf
	
Return 
//---------------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} SelecDd
(long_description)
@type function
@author Cris
@since 01/06/2017
@version 1.0
@param cTabAtu, character, (Descrição do parâmetro)
@param aCpos, array, (Descrição do parâmetro)
@param cTabDD, character, (Descrição do parâmetro)
@return ${return}, ${return_description}
/*///---------------------------------------------------------------------------------------------------------------------------
Static Function SelecDd(cTabAtu,aCpos,cTabDD)

	Local nCpos		:= 0
	Local cQry		:= ''

		For nCpos := 1 to len(aCpos)
		
			if aCpos[nCpos][10] <> 'V' //VIRTUAL
				
				if  !Empty(cCpos) 
					 
					cCpos	:= cCpos+','+Alltrim(aCpos[nCpos][3])
					
				Else
				
					cCpos	:= Alltrim(aCpos[nCpos][3])
					
				EndIf
			
			EndIf
			
			//Guarda o nome do campo _FILIAL
			if nCpos == 1
			
				cCpoFil	:= Alltrim(aCpos[nCpos][3])
				
			EndIf
				
		Next nCpos

		cQry	:= " SELECT "+cCpos +CRLF
		cQry	+= " FROM "+RetSqlName(cTabAtu)+" (NOLOCK) "+CRLF
		cQry	+= " WHERE D_E_L_E_T_ = ' ' "+CRLF
		cQry	+= "  AND EXISTS ("+CRLF
		cQry	+= "  				SELECT CLIENTE "+CRLF
		cQry	+= "  				FROM TMPCLIENTE_MVTO "+CRLF
		cQry	+= "  				WHERE CLIENTE  = A1_COD  "+CRLF
		cQry	+= "  				  AND LOJA = A1_LOJA ) "+CRLF
								
		cQry := ChangeQuery(cQry)
		DbUseArea(.T., "TOPCONN", TcGenQry(NIL, NIL, cQry), cTabDD, .T., .T.)  		
	
		if !'A1_MSBLQL' $ cCpos
			
			cCpos	:= cCpos+',A1_MSBLQL'
			
		EndIf
	
Return 
//---------------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ExpDD
(long_description)
@type function
@author Cris
@since 01/06/2017
@version 1.0
@param aCpos, array, (Descrição do parâmetro)
@param cTabDD, character, (Descrição do parâmetro)
@param cTabAtu, character, (Descrição do parâmetro)
@param lMsblql, ${param_type}, (Descrição do parâmetro)
@param cMsblql, character, (Descrição do parâmetro)
@return ${return}, ${return_description}
/*///---------------------------------------------------------------------------------------------------------------------------
Static Function ExpDD(aCpos,cTabDD,cTabAtu,lMsblql,cMsblql)

	Local nCpos		:= 0
	Local cLinha	:= ''
	Local _DdAtu	:= ''
	Local cTpCpo	:= ''
	Local nCntReg	:= 0
	Local nRegAtu	:= 0
	
	Default lMsblql	:= .F.
	
		Count To nCntReg
		
		(cTabDD)->(dbGotop())
		ProcRegua(nCntReg)

		While !(cTabDD)->(Eof())	
					
			//Somente para exibir algo no processamento, o Run não esta funcionando na P10	
			IncProc('Lendo registro '+Alltrim(Str(nRegAtu := nRegAtu+1))+'/'+Alltrim(Str(nCntReg)))
						
			For nCpos	:= 1 to len(aCpos)
				
				//Se não for campo virtual
				if aCpos[nCpos][10] <> 'V'
				
					_DdAtu	:= (cTabDD)->&(aCpos[nCpos][3])	
					
					if aCpos[nCpos][4] == 'N'
						
						_DdAtu	:= Alltrim(Str(_DdAtu))
					
					EndIf
					
					_DdAtu	:= StrTran(_DdAtu,';',',')
					
					//Exclui o caracter Line Feed LF e/ou carriage return CR
					_DdAtu	:= U_fTroca(_DdAtu)					
					
					//26.4.2017, conforme alinhamento com o Jamer, na importação é retirado as aspas duplas, devido a CT5 conter fórmulas as aspas
					//duplas serão substituidas por aspas simples.
				 	_DdAtu	:= StrTran(_DdAtu,'"',"'")
					
					//Se estiver compondo a linha a mesma estará em branco ou se o campo for filial pode ser que o conteudo esteja em branco
					if nCpos > 1
											
						//Caso o campo _MSBLQL seja .T. (tratado na exportação), carrega o conteúdo deste campo conforme o enviado no parametro da função.
						if lMsblql .AND. '_MSBLQL' $ aCpos[nCpos][3]
				
							cLinha	:= cLinha+";"+cMsblql
						
						Else
						
							cLinha	:= cLinha+";"+RTRIM(_DdAtu)
															
						EndIf
				
					Else
					
						//Caso a tabela seja exclusiva ,para efetuar o De Para,o campo Filial deverá ter ser prefixo preenchido com o codigo da Empresa
						if  '_FILIAL' $ aCpos[nCpos][3] .AND. !Empty(xFilial(cTabAtu))
						
							cLinha	:= cEmpAnt+_DdAtu
						
						Else
						
							cLinha	:= _DdAtu
						
						EndIf
						
					EndIf
				
				EndIf
				
			Next nCpos

			
			(cTabDD)->(dbSkip())

			U_DescReg(cLinha,(cTabDD)->(Eof()),cNomeArq) 
			cLinha	:= ''
			
		EndDo
		
Return 
