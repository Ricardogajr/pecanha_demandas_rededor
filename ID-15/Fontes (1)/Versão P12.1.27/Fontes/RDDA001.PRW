#INCLUDE "PROTHEUS.CH"
#INCLUDE "topconn.ch"

/*
|----------------------------------------------------------------------------|
|Programa  |RDDA001  |Autor  |TECNOSUM            | Data |  31/03/2016       |
|----------------------------------------------------------------------------|
|Descri豫o |Amarra豫o tipo sc x motivo sc                                    |						  
|----------------------------------------------------------------------------|
|Uso       |REDEDOR                                                            |						  
|----------------------------------------------------------------------------|
*/

User Function RDDA001()

	Local cFiltro := " " 
	Local cStatus := " "

	//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴?
	//?Declaracao de Variaveis                                             ?
	//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴?

	Private cCadastro := "Amarra豫o Tipo SC x Motivo SC"


	//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴?
	//?Monta um aRotina proprio                                            ?
	//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴?

	Private aRotina := { {"Pesquisar","AxPesqui",0,1} ,;
	{"Visualizar","u_RDDA001A",0,2} ,;
	{"Incluir","u_RDDA001A",0,3} ,;
	{"Alterar","u_RDDA001A",0,4} ,;
	{"Excluir","u_RDDA001A",0,5}}

	Private cDelFunc := ".T." // Validacao para a exclusao. Pode-se utilizar ExecBlock

	Private cString := "PZZ" 


	dbSelectArea("PZZ")
	dbSetOrder(1) 

	mBrowse(6,1,22,75,"PZZ")

Return


/*
|----------------------------------------------------------------------------|
|Programa  |RDDA001A  |Autor  |TECNOSUM            | Data |  31/03/2016       |
|----------------------------------------------------------------------------|
|Descri豫o |Amarra豫o tipo sc x motivo sc                                    |						  
|----------------------------------------------------------------------------|
|Uso       |REDEDOR                                                            |						  
|----------------------------------------------------------------------------|
*/
User Function RDDA001A(cAlias, nReg, nOpc)


	Local aArea     := GetArea()
	Local oDlg
	Local nUsado    := 0
	Local nCntFor   := 0
	Local nOpcA     := 0
	Local lContinua := .T.
	Local cQuery    := ""
	Local aObjects  := {}
	Local aPosObj   := {}
	Local aSizeAut  := MsAdvSize()
	Local lNopc1    := .F.
	Local lNopc2    := .F.

	Local aAlter       	:= {"PZZ_MOTIVO"}
	Local aFields		:= {"PZZ_TIPO","PZZ_DESCTP"}
	Local nOpcx        	:= GD_INSERT+GD_DELETE+GD_UPDATE
	Local cLinOk       	:= "U_RDDA1LOK()"/*"U_LinOk"*/    // Funcao executada para validar o contexto da linha atual do aCols
	Local cTudoOk      	:= "U_RDDA1LOK()"    // Funcao executada para validar o contexto geral da MsNewGetDados (todo aCols)
	Local cIniCpos     	:= ""               // Nome dos campos do tipo caracter que utilizarao incremento automatico.
	Local nFreeze      	:= 000              // Campos estaticos na GetDados.
	Local nMax         	:= 999              // Numero maximo de linhas permitidas. Valor padrao 99
	Local cFieldOk     	:= "AllwaysTrue"    // Funcao executada na validacao do campo
	Local cSuperDel    	:= ""              // Funcao executada quando pressionada as teclas <Ctrl>+<Delete>
	Local cDelOk       	:= "AllwaysTrue"   // Funcao executada para validar a exclusao de uma linha do aCols
	Local _aCmpPZZ	:= {} //Thais Paiva - Compatibilizacao P27



	PRIVATE aHEADER := {}
	PRIVATE aCOLS   := {}
	PRIVATE aGETS   := {}
	PRIVATE aTELA   := {}

	Private oGetDad



	*----------------------------------------------------------------
	*|   Montagem de Variaveis de Memoria                             |
	*----------------------------------------------------------------
	Do case
		Case nOpc = 2
		lNopc1 :=.F.
		lNopc2 :=.F.
		Case nOpc = 3
		lNopc1 :=.T.
		lNopc2 :=.F.
		Case nOpc = 4
		lNopc1 :=.F.
		lNopc2 :=.T.
		Case nOpc = 5
		lNopc1 :=.F.
		lNopc2 :=.F.
	EndCase

	RegToMemory( "PZZ", lNopc1, lNopc2 )

	//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴?
	//?Monta o aHeader                                       ?
	//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴?

	aHeader := {}
	//Inicio - Thais Paiva - Compatibilizacao P27
	_aCmpPZZ := FWSX3Util():GetAllFields( "PZZ" , .T. )

	//DbSelectArea("SX3")
	//DbSetOrder(1)
	//DbSeek("PZZ",.T.)

	nUsado := 0

	//Do While ( !SX3->(Eof()) .And. SX3->X3_ARQUIVO == "PZZ" )
	For _nZZ := 1 to Len(_aCmpPZZ)
		//If ( cNivel >= SX3->X3_NIVEL )
		If ( cNivel >= GetSx3Cache(_aCmpPZZ[_nZZ], 'X3_NIVEL') )
			//If (ALLTRIM(SX3->X3_CAMPO) $ "PZZ_MOTIVO|PZZ_DESMOT")
			If (ALLTRIM(GetSx3Cache(_aCmpPZZ[_nZZ], 'X3_CAMPO')) $ "PZZ_MOTIVO|PZZ_DESMOT")
				/*AADD(aHeader,{ AllTrim(X3Titulo()),;
				SX3->X3_CAMPO,;
				SX3->X3_PICTURE,;
				SX3->X3_TAMANHO,;
				SX3->X3_DECIMAL,;
				SX3->X3_VALID,;
				SX3->X3_USADO,;
				SX3->X3_TIPO,;
				SX3->X3_F3,;
				SX3->X3_CONTEXT,;
				SX3->X3_CBOX,;
				SX3->X3_RELACAO,;
				SX3->X3_WHEN,;
				SX3->X3_VISUAL,;
				SX3->X3_VLDUSER,;
				SX3->X3_PICTVAR,;
				SX3->X3_OBRIGAT})*/
				AADD(aHeader,{	AllTrim(GetSx3Cache(_aCmpPZZ[_nZZ], 'X3_TITULO')),;
								GetSx3Cache(_aCmpPZZ[_nZZ], 'X3_CAMPO'),;
								GetSx3Cache(_aCmpPZZ[_nZZ], 'X3_PICTURE'),;
								GetSx3Cache(_aCmpPZZ[_nZZ], 'X3_TAMANHO'),;
								GetSx3Cache(_aCmpPZZ[_nZZ], 'X3_DECIMAL'),;
								GetSx3Cache(_aCmpPZZ[_nZZ], 'X3_VALID'),;
								GetSx3Cache(_aCmpPZZ[_nZZ], 'X3_USADO'),;
								GetSx3Cache(_aCmpPZZ[_nZZ], 'X3_TIPO'),;
								GetSx3Cache(_aCmpPZZ[_nZZ], 'X3_F3'),;
								GetSx3Cache(_aCmpPZZ[_nZZ], 'X3_CONTEXT'),;
								GetSx3Cache(_aCmpPZZ[_nZZ], 'X3_CBOX'),;
								GetSx3Cache(_aCmpPZZ[_nZZ], 'X3_RELACAO'),;
								GetSx3Cache(_aCmpPZZ[_nZZ], 'X3_WHEN'),;
								GetSx3Cache(_aCmpPZZ[_nZZ], 'X3_VISUAL'),;
								GetSx3Cache(_aCmpPZZ[_nZZ], 'X3_VLDUSER'),;
								GetSx3Cache(_aCmpPZZ[_nZZ], 'X3_PICTVAR'),;
								GetSx3Cache(_aCmpPZZ[_nZZ], 'X3_OBRIGAT')})
				nUsado++
			Endif
		Endif
		//dbSkip()
	//EndDo
	Next _nZZ
	//Fim - Thais Paiva - Compatibilizacao P27

	*----------------------------------------------------------------+
	*   Montagem do aCols                                            |
	*----------------------------------------------------------------+



	If nOpc # 3

		BeginSql alias "PZZTMP"

		%noparser%
		SELECT PZZ_MOTIVO
		FROM %table:PZZ% PZZ
		WHERE 	PZZ_TIPOSC = %exp:PZZ->PZZ_TIPOSC% AND	%notDel%
		ORDER BY PZZ_MOTIVO

		EndSql


		While (!PZZTMP->(Eof()))
			aadd(aCOLS,Array(nUsado+1))
			For nCntFor := 1 To nUsado
				If ( aHeader[nCntFor][10] != "V" )
					aCols[Len(aCols)][nCntFor] := FieldGet(FieldPos(aHeader[nCntFor][2]))
				Else
					aCols[Len(aCols)][nCntFor] := CriaVar(aHeader[nCntFor][2])
					If aHeader[nCntFor][2] = "PZZ_DESMOT"
						aCols[Len(aCols)][nCntFor] := POSICIONE("SX5",1,XFILIAL("SX5")+"ZZ"+PZZTMP->PZZ_MOTIVO,"X5_DESCRI")
					Endif	
				EndIf
			Next nCntFor
			aCOLS[Len(aCols)][Len(aHeader)+1] := .F.
			PZZTMP->(dbSkip())
		EndDo

		If select("PZZTMP")>0
			dbSelectArea("PZZTMP")
			dbCloseArea()
		EndIf
	Endif

	dbSelectArea("PZZ")
	dbSetOrder(1)


	//****

	aObjects := {}
	AAdd( aObjects, { 315,  30, .T., .T. } )
	AAdd( aObjects, { 100,  70, .T., .T. } )

	aInfo := { aSizeAut[ 1 ], aSizeAut[ 2 ], aSizeAut[ 3 ], aSizeAut[ 4 ], 3, 3 }
	aPosObj := MsObjSize( aInfo, aObjects, .T. )

	DBSELECTAREA(cAlias)
	DBGOTO(nReg)


	DEFINE MSDIALOG oDlg TITLE cCadastro From aSizeAut[7],00 To aSizeAut[6],aSizeAut[5] OF oMainWnd PIXEL
	EnChoice( cAlias,nReg, nOpc, , , , , aPosObj[1], , 3, , , ,oDlg)
	oGetDad:= MsNewGetDados():New(aPosObj[2,1],aPosObj[2,2],aPosObj[2,3],aPosObj[2,4],iF(INCLUI .OR. ALTERA,GD_INSERT+GD_UPDATE+GD_DELETE,0),cLinOk,cTudoOk,cIniCpos,;
	aAlter,nFreeze,nMax,cFieldOk,cSuperDel,cDelOk,oDlg,aHeader,aCols)


	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{ || IIF( OBRIGATORIO(AGETS,ATELA) .And. TudoOk() .and. U_RDDA1LOK(), (nOpca := 1, oDlg:END()), nOpca := 0) }, { || oDlg:END() },,)




	IF  nOpca = 1

		Grava(cAlias,nReg,nOpc)

	EndIf
	RestArea(aArea)




Return


/*
|----------------------------------------------------------------------------|
|Programa  |RDDA001A  |Autor  |TECNOSUM            | Data |  31/03/2016       |
|----------------------------------------------------------------------------|
|Descri豫o |Amarra豫o tipo sc x motivo sc                                    |						  
|----------------------------------------------------------------------------|
|Uso       |REDEDOR                                                            |						  
|----------------------------------------------------------------------------|
*/

Static Function Grava(cAlias,nReg,nOpcx)


	Local lFound   //Verifica se o reckloc sera .T. ou .F.
	Local i,j      //Contador
	Local lRet    	:= .T. // logico que permite a exclusao caso nao tenha restricao
	Local aHeader 	:= aClone(oGetDad:aHeader)
	Local aCols		:= aClone(oGetDad:aCols)
	Local nPosMot 		:= aScan(aHeader,{|x| AllTrim(x[2])=="PZZ_MOTIVO"})

	DbSelectArea("PZZ")
	DbSetOrder(1)

	If nopcx = 5 // Exclusao

		DbSelectArea("PZZ")
		DbSetOrder(1)
		DbSeek(xFilial("PZZ")+M->PZZ_TIPOSC)
		While !PZZ->(Eof()) .And. PZZ->PZZ_FILIAL+PZZ->PZZ_TIPOSC = xfilial("PZZ")+M->PZZ_TIPOSC

			Reclock("PZZ",.F.)
			DbDelete()
			MsUnlock()
			PZZ->(DbSkip())

		EndDo

	ElseIf nopcx = 3 .OR. nOpcx = 4

		If nOpcx = 4
			DbSelectArea("PZZ")
			DbSetOrder(1)
			DbSeek(xFilial("PZZ")+M->PZZ_TIPOSC)
			While !PZZ->(Eof()) .And. PZZ->PZZ_FILIAL+PZZ->PZZ_TIPOSC = xfilial("PZZ")+M->PZZ_TIPOSC

				Reclock("PZZ",.F.)
				DbDelete()
				MsUnlock()
				PZZ->(DbSkip())

			EndDo
		Endif 

		DbSelectArea("PZZ")
		DbSetOrder(1)
		For i:=1 to Len(aCols)
			If !aCols[i][Len(aCols[i])] .And. !Empty(aCols[i][1]) //Se n? estiver deletado
				Reclock("PZZ", .t.)
				PZZ->PZZ_FILIAL  	:= xFilial("PZZ")
				PZZ->PZZ_TIPOSC		:= M->PZZ_TIPOSC
				PZZ->PZZ_MOTIVO		:= Acols[i,nPosMot]
				MsUnlock()
			Endif
		Next

	Endif

Return
/*
|----------------------------------------------------------------------------|
|Programa  |RDDA001A  |Autor  |TECNOSUM            | Data |  31/03/2016       |
|----------------------------------------------------------------------------|
|Descri豫o |Amarra豫o tipo sc x motivo sc                                    |						  
|----------------------------------------------------------------------------|
|Uso       |REDEDOR                                                            |						  
|----------------------------------------------------------------------------|
*/

User Function RDDA1LOK()
	Local aHeader 	:= aClone(oGetDad:aHeader)
	Local aCols		:= aClone(oGetDad:aCols)
	Local i			:=0
	Local nPosMot 		:= aScan(aHeader,{|x| AllTrim(x[2])=="PZZ_MOTIVO"})
	lRet 			:= .t.

	For i := 1 to Len(aCols)

		If !aCols[i][Len(aCols[i])] .and. oGetDad:nAt <> i
			If aCols[i][nPosMot] == aCols[oGetDad:nAt][nPosMot] 
				Alert("Motivo j?informado para o tipo")
				lRet := .f.
			Endif

		Endif
	Next



Return lRet


/*
|----------------------------------------------------------------------------|
|Programa  |RDDV001  |Autor  |TECNOSUM            | Data |  31/03/2016       |
|----------------------------------------------------------------------------|
|Descri豫o |Valida豫o do tipo utilizado                                      |						  
|----------------------------------------------------------------------------|
|Uso       |REDEDOR                                                          |						  
|----------------------------------------------------------------------------|
*/

User Function RDDV001(cTipo)
	
	Local cRet 		:= "|"
	Local cRetGrp	:= ""
	Local cQuery	:= ""
	
	Local nX		:= 0
		
	Local lRet 		:= .T. 
	
	Local aRetGrp	:= {}
	
	Local aArea 	:= GetArea()
	
	If !l110Auto .and. !IsInCallStack('U_REDA003')//Thais Paiva 9474856

		cQuery := "SELECT AI_XTPSC, AI_GRUSER FROM " + RetSqlName("SAI")
		cQuery += "		WHERE AI_FILIAL = '" + xFilial("SAI") + "' AND AI_USER = '" + __cUserID + "'  AND D_E_L_E_T_= ' '"

		TcQuery cQuery New Alias "AITMP"
		
		// N? encontrou o Usu?io
		If ( AITMP->(Eof()) )
			// Busco pelo Grupo para identificar o Usu?io
			aRetGrp := fUserGrp()	 
		EndIf 

		cQuery := ""
		
		If ( Len( aRetGrp ) > 0 )
			If ( Select("AITMP") > 0 )
				DbCloseArea("AITMP")
			EndIf
			// Monto a string com os Grupos ao qual o Usu?io corrente pertence
			For nX := 1 To Len( aRetGrp )
				cRetGrp += aRetGrp[nX] + ","
			Next nX
			// Removo a virgula do final da string
			cRetGrp := SubStr( cRetGrp, 1, Len(cRetGrp)-1 )
			
			cQuery := "SELECT AI_XTPSC, AI_USER, AI_GRUSER FROM "+ RetSqlName("SAI")
			//cQuery += "		WHERE AI_FILIAL = '" + xFilial("SAI") + "' AND AI_GRUSER = '" + cRetGrp + "'  AND D_E_L_E_T_= ' '"
			cQuery += "		WHERE AI_FILIAL = '" + xFilial("SAI") + "' AND AI_GRUSER IN " + FormatIn( cRetGrp, "," ) + " AND D_E_L_E_T_= ' '"
			
			TcQuery cQuery New Alias "AITMP"
		EndIf
		
		While ( !AITMP->(Eof()) )
			
			//Se encontrar * faz o filtro da zx completa.
			cRet += AllTrim( AITMP->AI_XTPSC ) 
			//If ( Empty( cRetGrp ) )
			//lRet := fGrpUser( AITMP->AI_GRUSER )
			//Else
			//lRet = .T.
			//EndIf
					
			AITMP->( DbSkip() )
			
		End
		// Realizo a valida豫o do Tipo da SC
		If !(cTipo $ cRet)
			Alert("Solicitante nao tem permissao para incluir SC do tipo informado!!")
			lRet = .F.
		EndIf
			
		DbSelectArea("AITMP")
		DbCloseArea()
		
	EndIf //Thais Paiva 9474856
	
	RestArea(aArea)
	
Return( lRet )


/*
|----------------------------------------------------------------------------|
|Programa  |RDDV002  |Autor  |TECNOSUM            | Data |  13/04/2016       |
|----------------------------------------------------------------------------|
|Descri豫o |Valida豫o do motivo utilizado                                      |						  
|----------------------------------------------------------------------------|
|Uso       |REDEDOR                                                          |						  
|----------------------------------------------------------------------------|
*/

User Function RDDV002(cTipo,cMotivo)
	Local aArea := GetArea()
	Local lRet 	:= .t.


	DbSelectArea("PZZ")
	DbSetOrder(1)
	If !DbSeek(xFilial("PZZ")+cTipo+cMotivo)
		If l110Auto //Inicio Thais Paiva 9474856
			aadd(_aMsgErr,"Nao e permitido utilizar motivo que nao esteja amarrado ao tipo!")
		Else //Fim Thais Paiva 9474856
			Alert("Nao e permitido utilizar motivo que nao esteja amarrado ao tipo!")
		Endif //Thais Paiva 9474856
		lRet := .f.
	Endif

Return lRet

User Function RDDG001(cTipo)
	Local aArea 	:= GetArea()
	Local cMot		:= " "
	Local nCont		:= 0
	Local cQuery	:= ""


	BeginSql alias "PZZTMP"
	%noparser%
	Select PZZ_MOTIVO FROM %table:PZZ% PZZ 
	WHERE PZZ_TIPOSC = %exp:cTipo% and PZZ.%notdel%
	EndSql		

	DbSelectArea("PZZTMP")
	Count to nCont

	PZZTMP->(Dbgotop())

	If nCont = 1
		cMot := PZZTMP->PZZ_MOTIVO

	Endif
	DbSelectArea("PZZTMP")
	DbCloseArea()


	RestArea(aArea)
Return cMot

/*
|----------------------------------------------------------------------------|
|Programa  |ValidPZZ  |Autor  |TECNOSUM            | Data |  15/04/2016      |
|----------------------------------------------------------------------------|
|Descri豫o |Valida豫o do campo PZZ_TIPOSC                                    |						  
|----------------------------------------------------------------------------|
|Uso       |CAMPO PZZ_TIPOSC                                                 |						  
|----------------------------------------------------------------------------|
*/

User Function ValidPZZ(cTipo)
	Local aArea 	:= GetArea()
	Local lRet := .t.

	BeginSql alias "PZZTMP"
	%noparser%
	Select COUNT(PZZ_TIPOSC) CONT FROM %table:PZZ% PZZ 
	WHERE PZZ_TIPOSC = %exp:cTipo% and PZZ.%notdel%
	EndSql		

	DbSelectArea("PZZTMP")

	PZZTMP->(Dbgotop()) 


	If PZZTMP->CONT > 0
		Alert("Tipo J?cadastrado!")
		lRet:= .f.
	Endif
	DbSelectArea("PZZTMP")
	DbCloseArea()
	RestArea(aArea)	
Return lRet

/*
|----------------------------------------------------------------------------|
|Programa  |fTipoSC  |Autor  |TECNOSUM            | Data |  15/04/2016       |
|----------------------------------------------------------------------------|
|Descri豫o |Preenchimento do campo AI_XTPSC                                  |						  
|----------------------------------------------------------------------------|
|Uso       |CAMPO AI_XTPSC                                                 |						  
|----------------------------------------------------------------------------|
*/
User Function fTipoSC(l1Elem,lTipoRet)

Local cTitulo:=""
Local MvPar
Local MvParDef:=""
Local _aX5ZX := {}

Private aCat:={}

DEFAULT lTipoRet := .T.

l1Elem := If (l1Elem = Nil , .F. , .T.)

cAlias := Alias() 					 // Salva Alias Anterior

IF lTipoRet
	MvPar:=&(Alltrim(ReadVar()))		 // Carrega Nome da Variavel do Get em Questao
	mvRet:=Alltrim(ReadVar())			 // Iguala Nome da Variavel ao Nome variavel de Retorno
EndIF

//Inicio - Thais Paiva - Compatibilizacao P27
//dbSelectArea("SX5")
//If dbSeek(cFilial+"00ZX")
   //cTitulo := Alltrim(Left(X5Descri(),20))
//Endif
cTitulo := Alltrim(Left( U_SX5UTILI("L","00","ZX",4),20))

//If dbSeek(cFilial+"ZX")
_aX5ZX := U_SX5UTILI("","ZX")
	//CursorWait()
		//While !Eof() .And. SX5->X5_Tabela == "ZX"
		For _nZ := 1 To Len(_aX5ZX)
//			IF (Left(SX5->X5_Chave,3) $ MvTipoTit ) //"BOL|CC |CD |CH |DC |R$ |VA |")      
			
				//Aadd(aCat,Left(SX5->X5_Chave,2) + " - " + Alltrim(X5Descri()))
				//MvParDef+=Left(SX5->X5_Chave,2)
				Aadd(aCat,Left(_aX5ZX[_nZ][3],2) + " - " + Alltrim(_aX5ZX[_nZ][4]))
				MvParDef+=Left(_aX5ZX[_nZ][3],2)
//			Endif
			//dbSkip()
		//Enddo
		Next _nZ
	//CursorArrow()
//Endif
//Fim - Thais Paiva - Compatibilizacao P27
mvRetor := ""
IF lTipoRet
	IF f_Opcoes(@MvPar,cTitulo,aCat,MvParDef,12,49,l1Elem,2)  // Chama funcao f_Opcoes
	
		For nFor := 1 To Len( mVpar ) Step 2
			IF ( SubStr( mVpar , nFor , 2 ) # "**" )      
				mvRetor += "|" + SubStr( mVpar , nFor , 2 )
			Endif
		Next nFor
		If( Empty(mvRetor) )
			mvRetor := Space(300)
		EndIf  
		&MvRet := SubStr(mvRetor,2)										 // Devolve Resultado

		
	EndIF
EndIF

dbSelectArea(cAlias) 								 // Retorna Alias


Return( IF( lTipoRet , .T. , MvParDef ) )

/*
|----------------------------------------------------------------------------|
|Programa  |fGrpUser  |Autor  |TECNOSUM            | Data |  27/10/2017      |
|----------------------------------------------------------------------------|
|Descri豫o |Retorno o campo AI_GRUSER                                        |						  
|----------------------------------------------------------------------------|
|Uso       |CAMPO AI_GRUSER                                                  |						  
|----------------------------------------------------------------------------|
*/
Static Function fGrpUser( cGrpUser )

Local nAchou	:= 0
Local lAchou	:= .F.
Local aGrupos 	:= {}


// Verifica se faz parte de algum grupo 
If ( cGrpUser != "******" .And. !Empty( cGrpUser ) )         

	PswOrder(1)
	If (  PswSeek(__cUserId, .T.) )
		// Retorna os Grupos
		aGrupos := Pswret(1)
		// Pesquisa
		nAchou := Ascan( aGrupos[1][10], cGrpUser ) 
		// O usuario corrente faz parte do grupo
		If ( nAchou != 0 )
			lAchou	:= .T.
		EndIf
				
	EndIf

// Verifica se faz parte de todos os grupos	
ElseIf ( cGrpUser == "******" )
	lAchou	:= .F.
// Verifica se n? faz parte de nenhum grupo	
ElseIf ( Empty( cGrpUser ) )
	lAchou	:= .F.
EndIf

Return( lAchou )


/*
|----------------------------------------------------------------------------|
|Programa  |fGrpUser  |Autor  |TECNOSUM            | Data |  30/10/2017      |
|----------------------------------------------------------------------------|
|Descri豫o |Retorno o campo AI_GRUSER                                        |						  
|----------------------------------------------------------------------------|
|Uso       |CAMPO AI_GRUSER                                                  |						  
|----------------------------------------------------------------------------|
*/
Static Function fUserGrp()

//Local cUserGrp	:= ""
//Local lAchou	:= .F.
Local aUserGrp	:= {}
Local aGrupos 	:= {}


PswOrder(1)
If (  PswSeek( __cUserId, .T. ) )
	// Retorna os Grupos
	aGrupos := Pswret(1)
	// O usuario corrente faz parte do grupo
	aUserGrp := aGrupos[1][10]
	//cUserGrp := aGrupos[1][10][1]
						
EndIf
	
Return( aUserGrp )
