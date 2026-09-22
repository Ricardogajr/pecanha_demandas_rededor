#INCLUDE "PROTHEUS.CH"
#INCLUDE "HEADERGD.CH"
#include "Directry.ch"


#DEFINE F_FULLNM 06

User Function RDI001()

	Private cCadastro	:= "KIT Migra็ใo - Cadastro de Processos de Importa็ใo"
	
	Private aRotina 	:= MenuDef()
	
    //SysErrorBlock ({| e | ErrorDialog( e ), U_RDIFError() })
	
	LoadPublics()
	
	mBrowse( 6 , 1 , 22 , 75 , "QZ1" )
Return( NIL )


*************************
User Function RDIFError()
*************************
   Local cPathTmp := U_GetTmpMigra()
   Local aFiles   := DIRECTORY(cPathTmp + "*.bat")
   
   AEval(aFiles,{|f| If(File(f[1]),fErase(f[1]),)})
   
Return nil     

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณMenuDef   บAutor  ณJamer Nunes Pedroso บ Data ณ  01/09/14   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Opc็๕es do menu Arotina                                    บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ TDI                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function MenuDef()

   Private aExecute   := { {"Processo  ", "U_RDI011()", 0, 2 },;
                           {"Pacote    ", "U_RDI008()", 0, 2 } }
                         
   Private aRotTools  := { { "Sincronizar c/dicionแrio",   "U_RDI002(QZ1->QZ1_CODIGO,.T.,.T.)"   , 0 , 4 ,16 , NIL },;
                           { "Configurar conexใo"	     ,	"U_SetCfgCnx()"     , 0 , 3 ,16 , NIL },;
                           { "Cria Intermediแria"	     ,	"U_RDI007"                           , 0 , 4 ,16 , NIL } }

Return(;
		{;
			{ "Pesquisar"      , "AxPesqui"                                                         , 0 , 1 ,0  , .F. },;
			{ "Visualizar"	   , "U_MntExe('QZ1',QZ1->(Recno()),2)"                 , 0 , 2 ,0  , NIL },;
			{ "Incluir"		   , "U_MntExe('QZ1',QZ1->(Recno()),3)"                 , 0 , 3 ,0  , NIL },;
			{ "Alterar"		   , "U_MntExe('QZ1',QZ1->(Recno()),4)"                 , 0 , 4 ,15 , NIL },;
			{ "Excluir"		   , "U_MntExe('QZ1',QZ1->(Recno()),5)"                 , 0 , 5 ,16 , NIL },;
			{ "Executar"       , aExecute                                                           , 0 , 4 ,16 , NIL },;
			{ "Visualizar Log" , "U_PreviewL(.T.,AllTrim(QZ1->QZ1_CODIGO),,,)"    , 0 , 4 ,16 , NIL },;
			{ "Utilitแrios"    , aRotTools                                                          , 0 , 3 ,16 , NIL } ;
		};                     
)


***************************
User Function SelectImp()
***************************
    Local lRet    := .F.
    Local cAlias  := AllTrim(QZ1->QZ1_DESTIN)
    Local cTpImp  := AllTrim(QZ1->QZ1_TPIMP)
	Local cDirImp := U_GetDir(101) + cAlias + "\"
	
	If ! RDICpy2S(cAlias)
	   Return .F.
	Endif
    
    Do Case
       Case ( cTpImp == "1" ) //SQL Loader
       
            lRet := U_RDI004(RetSqlName(cAlias),cDirImp)
            
       Case ( cTpImp == "2" ) //Valida็ใo (QZ1/QZ2)
       
            lRet := U_RDI003()
            
       Case ( cTpImp == "3" ) //Stored Procedure/Banco.
       
            lRet := U_RDI009()
            
       Otherwise
           
            MsgStop("Nใo foi possํvel identificar o m้todo de importa็ใo utilizado! Verifique.")
           
    EndCase 
       
Return lRet       	

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณExecMnt   บAutor  ณJamer Nunes Pedroso บ Data ณ  01/09/14   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Manuten็ใo Modelo 3                                        บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ TDI                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

User Function MntExe( cAlias , nReg , nOpc )

	Local aQZ1Cols		:= {}
	Local aSvQZ1Cols	:= {}
	Local aQZ1Header	:= {}
	Local aQZ1Fields	:= {}
	Local aQZ1VirtEn	:= {}
	Local aQZ1VisuEn	:= {}
	Local aQZ1NotFields	:= {}
	Local aQZ1Altera	:= {}
	Local aQZ1NaoAlt	:= {}
	Local aQZ1Recnos	:= {}
	Local aQZ1Keys		:= {}
    Local nSaveSX8

	Local aQZ2Keys
	Local aQZ2VirtGd
	Local aQZ2VisuGd
	Local aQZ2NotFields	:= { "QZ2_CODEXT" }
	Local aQZ2Recnos
	Local aSvQZ2Cols

	Local bGetQZ1
	Local bGetQZ2  // Parei aqui

	Local cQZ1Fil		:= ""
	Local cQZ1Codigo	:= ""
	Local cQZ2KeySeek

	Local lMod3Ret		:= .F.
	Local lLocks		:= .F.
	Local lExecLock		:= ( ( nOpc <> 2 ) /*/Visualizacao/*/ .and. ( nOpc <> 3 ) /*/Inclusao/*/ )

	Local nLoop			:= 0
	Local nOpcGD		:= nOPC
	Local nQZ1Usado		:= 0
	Local nQZ2Usado		:= 0
	Local nQZ2Order		:= RetOrder( "QZ2" , "QZ2_FILIAL+QZ2_CODEXT+QZ2_SEQ" )
	Local aAreaQZ1      := nil

	Private aCols		:= {}
	Private aHeader		:= {}

	Private aGets
	Private aTela

	Private n			:= 1

	BEGIN SEQUENCE

		aRotSetOpc( cAlias , @nReg , nOpc )

		bGetQZ1			:= { |lLock,lExclu|	IF( lExecLock , ( lLock := .T. , lExclu	:= .T. ) , aQZ1Keys := NIL ),;
											aQZ1Cols := QZ1->(;
									  							GdBuildCols(	@aQZ1Header		,;	//01 -> Array com os Campos do Cabecalho da GetDados
																				@nQZ1Usado		,;	//02 -> Numero de Campos em Uso
																				@aQZ1VirtEn		,;	//03 -> [@]Array com os Campos Virtuais
																				@aQZ1VisuEn		,;	//04 -> [@]Array com os Campos Visuais
																				"QZ1"			,;	//05 -> Opcional, Alias do Arquivo Carga dos Itens do aCols
																				aQZ1NotFields	,;	//06 -> Opcional, Campos que nao Deverao constar no aHeader
																				@aQZ1Recnos		,;	//07 -> [@]Array unidimensional contendo os Recnos
																				"QZ1"		   	,;	//08 -> Alias do Arquivo Pai
																				NIL				,;	//09 -> Chave para o Posicionamento no Alias Filho
																				NIL				,;	//10 -> Bloco para condicao de Loop While
																				NIL				,;	//11 -> Bloco para Skip no Loop While
																				NIL				,;	//12 -> Se Havera o Elemento de Delecao no aCols 
																				NIL				,;	//13 -> Se Sera considerado o Inicializador Padrao
																				NIL				,;	//14 -> Opcional, Carregar Todos os Campos
																				NIL				,;	//15 -> Opcional, Nao Carregar os Campos Virtuais
																				NIL				,;	//16 -> Opcional, Utilizacao de Query para Selecao de Dados
																				NIL				,;	//17 -> Opcional, Se deve Executar bKey  ( Apenas Quando TOP )
																				NIL				,;	//18 -> Opcional, Se deve Executar bSkip ( Apenas Quando TOP )
																				NIL				,;	//19 -> Carregar Coluna Fantasma
																				NIL				,;	//20 -> Inverte a Condicao de aNotFields carregando apenas os campos ai definidos
																				NIL				,;	//21 -> Verifica se Deve Checar se o campo eh usado
																				NIL				,;	//22 -> Verifica se Deve Checar o nivel do usuario
																				NIL				,;	//23 -> Verifica se Deve Carregar o Elemento Vazio no aCols
																				@aQZ1Keys		,;	//24 -> [@]Array que contera as chaves conforme recnos
																				@lLock			,;	//25 -> [@]Se devera efetuar o Lock dos Registros
																				@lExclu			 ;	//26 -> [@]Se devera obter a Exclusividade nas chaves dos registros
																		    );
															  ),;
											IF( lExecLock , ( lLock .and. lExclu ) , .T. );
		  					} 
	    
	    aAreaQZ1 := QZ1->(GetArea())
	    QZ1->(DbSetOrder( 1 )) 
	    IF !( lLocks := WhileNoLock( "QZ1" , NIL , NIL , 1 , 1 , .T. , 1 , 5 , bGetQZ1 ) )
			Break
		EndIF
	    RestArea(aAreaQZ1)

		MkArrEdFlds( nOpc , aQZ1Header , aQZ1VisuEn , aQZ1VirtEn , @aQZ1NaoAlt , @aQZ1Altera , @aQZ1Fields )

   		For nLoop := 1 To nQZ1Usado
   			SetMemVar( aQZ1Header[ nLoop , __AHEADER_FIELD__ ] , aQZ1Cols[ 01 , nLoop ] , .T. )
   		Next nLoop

		cQZ1Fil		:= QZ1->QZ1_FILIAL
		cQZ1Codigo	:= QZ1->QZ1_CODIGO
		cQZ2KeySeek	:= cQZ1Fil+cQZ1Codigo

		QZ2->( dbSetOrder( nQZ2Order ) )

		QZ2->( dbSeek( cQZ2KeySeek , .F. ) )

		bGetQZ2	:= { |lLock,lExclu|	IF( lExecLock , ( lLock := .T. , lExclu := .T. ) , aQZ2Keys := NIL ),;
						 				aCols := QZ2->(;
														GdBuildCols(	@aHeader		,;	//01 -> Array com os Campos do Cabecalho da GetDados
																		@nQZ2Usado		,;	//02 -> Numero de Campos em Uso
																		@aQZ2VirtGd		,;	//03 -> [@]Array com os Campos Virtuais
																		@aQZ2VisuGd		,;	//04 -> [@]Array com os Campos Visuais
																		"QZ2"			,;	//05 -> Opcional, Alias do Arquivo Carga dos Itens do aCols
																		aQZ2NotFields	,;	//06 -> Opcional, Campos que nao Deverao constar no aHeader
																		@aQZ2Recnos		,;	//07 -> [@]Array unidimensional contendo os Recnos
																		"QZ1"		   	,;	//08 -> Alias do Arquivo Pai
																		cQZ2KeySeek		,;	//09 -> Chave para o Posicionamento no Alias Filho
																		NIL				,;	//10 -> Bloco para condicao de Loop While
																		NIL				,;	//11 -> Bloco para Skip no Loop While
																		NIL				,;	//12 -> Se Havera o Elemento de Delecao no aCols 
																		NIL				,;	//13 -> Se Sera considerado o Inicializador Padrao
																		NIL				,;	//14 -> Opcional, Carregar Todos os Campos
																		NIL				,;	//15 -> Opcional, Nao Carregar os Campos Virtuais
																		NIL				,;	//16 -> Opcional, Utilizacao de Query para Selecao de Dados
																		.F.				,;	//17 -> Opcional, Se deve Executar bKey  ( Apenas Quando TOP )
																		.F.				,;	//18 -> Opcional, Se deve Executar bSkip ( Apenas Quando TOP )
																		NIL				,;	//19 -> Carregar Coluna Fantasma e/ou BitMap ( Logico ou Array )
																		NIL				,;	//20 -> Inverte a Condicao de aNotFields carregando apenas os campos ai definidos
																		NIL				,;	//21 -> Verifica se Deve Checar se o campo eh usado
																		NIL				,;	//22 -> Verifica se Deve Checar o nivel do usuario
																		NIL				,;	//23 -> Verifica se Deve Carregar o Elemento Vazio no aCols
																		@aQZ2Keys		,;	//24 -> [@]Array que contera as chaves conforme recnos
																		@lLock			,;	//25 -> [@]Se devera efetuar o Lock dos Registros
																		@lExclu			,;	//26 -> [@]Se devera obter a Exclusividade nas chaves dos registros
																		1				,;	//27 -> Numero maximo de Locks a ser efetuado
																		Altera			 ;	//28 -> Utiliza Numeracao na GhostCol
																    );
														  ),;
										IF( lExecLock , ( lLock .and. lExclu ) , .T. );
		  		    }

	    IF !( lLocks := WhileNoLock( "QZ2" , NIL , NIL , 1 , 1 , .T. , 1 , 5 , bGetQZ2 ) )
			Break
		EndIF

		IF ( nOpc == 3  ) //Inclusao
		  
			GdDefault( NIL , "QZ1" , aQZ1Header , @aQZ1Cols , NIL , .F. )
			
			dbSelectArea("QZ1")
			dbSetOrder(1)
			dbGobottom()
			                             
		    nSaveSX8 := QZ1->QZ1_CODIGO                           
		    
			While (M->QZ1_CODIGO <= nSaveSX8)
			   M->QZ1_CODIGO := QZ1->(GetSX8Num("QZ1","QZ1_CODIGO"))
		    EndDo
			
			nSaveSX8 := QZ1->(GetSX8Len())
            

		EndIF

		aSvQZ1Cols	:= aClone( aQZ1Cols )
		aSvQZ2Cols	:= aClone( aCols )

       lMod3Ret	:=	Modelo3(;
									cCadastro						,;	//cTitulo
									"QZ1"	  						,;	//cAlias1
									"QZ2"							,;	//cAlias2
									@aQZ1Fields						,;	//aMyEncho/
									"U_Mod3Lok()"	,;	//cLinOk
									"U_Mod3Tok()"	,;	//cTudoOk
									nOpc							,;	//nOpcE
									nOpcGD							,;	//nOpcG,
									NIL								,;	//cFieldOk,
									.T.								,;	//lVirtual
									999								,;	//nLinhas
									aQZ1Altera						,;	//aAltEnchoice
									NIL								,;	//nFreeze,
									NIL								,;	//aButtons
									NIL  							,;	//aCordW
									170								 ;	//nSizeHeader
								)
	
		IF ( lMod3Ret )
		
	 		IF ( nOpc != 2 )
	 		    
	 		    Begin Transaction 
	 		    
	 		    if ( nOpc == 3 )
	 		    
	 		       While (GetSX8Len() > nSaveSX8)
			          QZ1->(ConfirmSX8())
		           EndDo
		           
                Endif
	 		    
				MsAguarde(;
							{ ||;
									Mod3ExecGrv(;
													@nOpc		,;	//01 -> Opcao de Acordo com aRotina
								 					@nReg		,;	//02 -> Numero do Registro do Arquivo Pai ( QZ2 )
								 					@aQZ1Header	,;	//03 -> Campos do Arquivo Pai ( QZ1 )
								 					@aQZ1VirtEn	,;	//04 -> Campos Virtuais do Arquivo Pai ( QZ1 )
								 					@aQZ1Cols	,;	//05 -> Conteudo Atual dos Campos do Arquivo Pai ( QZ1 )
								 					@aSvQZ1Cols	,;	//06 -> Conteudo Anterior dos Campos do Arquivo Pai ( QZ1 )
								 					@aHeader	,;	//07 -> Campos do Arquivo Filho ( QZ2 )
								 					@aCols		,;	//08 -> Itens Atual do Arquivo Filho ( QZ2 )
								 					@aSvQZ2Cols	,;	//09 -> Itens Anterior do Arquivo Filho ( QZ2 )
								 					@aQZ2VirtGd	,;	//10 -> Campos Virtuais do Arquivo Filho ( QZ2 )
								 					@aQZ2Recnos	 ;	//11 -> Recnos do Arquivo Filho ( QZ2 )
								 				 );
							};
						  )    
						  
			    End Transaction
						  
			EndIF         
			
		Else                
		
		   if ( nOpc == 3 ) // SX8Rollback
		      RollbackSX8()
		   Endif
		   
		EndIF

	END SEQUENCE

	FreeLocks( "QZ2" , aQZ2Recnos , .T. , aQZ2Keys )
	FreeLocks( "QZ1" , aQZ1Recnos , .T. , aQZ1Keys )
	
Return( NIL )

*******************************
User Function RDIBF007(cpAlias)
*******************************
Local aArea := getArea() 
Local nSeq  := 0
Local nLin  := 0
Local _aCmp07 := ""
Local _n07
Local aArea := getArea() 
Local nSeq  := 0
Local nLin  := 0
Local _aCmp07 := {} //Thais Paiva - Compatibiliza็ใo P27

//Inํcio - Thais Paiva - Compatibiliza็ใo P27
//dbSelectArea("SX3")
//dbSetOrder(1)
//dbgotop()
_aCmp07 := FWSX3Util():GetAllFields( cpAlias , .T. )

if len( aCols ) == 1 .AND. empty( alltrim( aCols[1,2] ))
	aCols := {}
    for _n07 := 1 to len( _aCmp07 )
        aadd(aCols,Array(Len(aHeader)+1))
		Carrdef(++nLin, ++nSeq,_aCmp07[_n07])
		GetSx3Cache(_aCmp07[_n07], 'X3_ARQUIVO') == Alltrim(cpAlias)
    next _n07
endif
// -----------------------------------------------------

oGetDados:oBrowse:Refresh()

RestArea(aArea)

Return(.T.)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณMod3Lok   บAutor  ณJamer Nunes Pedroso บ Data ณ  01/09/14   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Funcao para Validacao da Linha Ok da GetDados              บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ TDI                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function Mod3Lok()

	Local lLinOk  		:= .T.
	
	Local aCposKey 

	Begin Sequence

		IF !( GdDeleted() )
			aCposKey := GdObrigat( aHeader )
			IF !( lLinOk := GdNoEmpty( aCposKey ) )
		    	Break
			EndIF
			//aCposKey := GetArrUniqe( "QZ2" )
			aCposKey := {"QZ2_FILIAL","QZ2_CODEXT","QZ2_SEQ"}
			IF !( lLinOk := GdCheckKey( aCposKey , 4 ) )
				Break
			EndIF
		EndIF

	End Sequence

Return( lLinOk )


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณMod3Tok   บAutor  ณJamer Nunes Pedroso บ Data ณ  01/09/14   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Funcao Para Validacao do TudoOk da GetDados                บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ TDI                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function Mod3Tok()
	Local lTudoOk		:= .T.
	Local nLoop
	Local nLoops
	Local nDeleted

	IF ( Type( "n" ) <> "N" )
		Private n := 0
	EndIF
	
	Begin Sequence
	
		nDeleted := GdFieldPos( "GDDELETED" )
		
		nLoops := Len( aCols )
		For nLoop := 1 To nLoops
			n := nLoop
			IF !( aCols[ n , nDeleted ] )
				IF !( lTudoOk := U_Mod3Lok() )
					Break
				EndIF
			EndIF
		Next nLoop
	
	End Sequence

Return( lTudoOk  )


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณMod3ExecGrv บAutor  ณJamer Nunes Pedroso บ Data ณ  01/09/14 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Funcao Para GRava็ใo do Modelo3                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ TDI                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Mod3ExecGrv(nOpc		,;	//01 -> Opcao de Acordo com aRotina
						 	nReg		,;	//02 -> Numero do Registro do Arquivo Pai ( QZ1 )
						 	aQZ1Header	,;	//03 -> Campos do Arquivo Pai ( QZ1 )
						 	aQZ1VirtEn	,;	//04 -> Campos Virtuais do Arquivo Pai ( QZ1 )
						 	aQZ1Cols	,;	//05 -> Conteudo Atual dos Campos do Arquivo Pai ( QZ1 )
						 	aSvQZ1Cols	,;	//06 -> Conteudo Anterior dos Campos do Arquivo Pai ( QZ1 )
						 	aQZ2Header	,;	//07 -> Campos do Arquivo Filho ( QZ2 )
						 	aQZ2Cols	,;	//08 -> Itens Atual do Arquivo Filho ( QZ2 )
						 	aSvQZ2Cols	,;	//09 -> Itens Anterior do Arquivo Filho ( QZ2 )
						 	aQZ2VirtGd	,;	//10 -> Campos Virtuais do Arquivo Filho ( QZ2 )
						 	aQZ2Recnos	 ;	//11 -> Recnos do Arquivo Filho ( QZ2 )
						  )

	Local aMestre	:= GdPutIStrMestre( 01 )
	Local aItens	:= {}
	Local cOpcao	:= IF( ( nOpc == 5 ) , "DELETE" , IF( ( ( nOpc == 3 ) .or. ( nOpc == 4 ) ) , "PUT" , NIL ) )
	Local cQZ1Codigo	:= GetMemVar( "QZ1_CODIGO" )
	Local lAllModif	:= .F.
	Local lQZ1Modif	:= .F.
	Local lQZ2Modif	:= .F.
	Local lQZ2Delet	:= .F.
	
	Local aQZ2ColDel
	Local aQZ2RecDel
	
	Local nLoop
	Local nLoops
	Local nItens

	IF ( cOpcao == "DELETE" )
		GdSuperDel( aQZ2Header , @aQZ2Cols , NIL , .T. )
		lQZ1Modif := .T.
	EndIF

	IF ( lQZ2Modif := !ArrayCompare( aQZ2Cols , aSvQZ2Cols ) )
		IF ( cOpcao <> "DELETE" )
			GdSuperDel( aQZ2Header , @aQZ2Cols , NIL , .T. , GdGetBlock( "QZ2" , aQZ2Header , .F. ) ) 
		EndIF	
		lQZ2Delet := GdSplitDel( aQZ2Header , @aQZ2Cols , @aQZ2Recnos , @aQZ2ColDel , @aQZ2RecDel )
	EndIF

	IF ( lQZ2Modif )

		IF ( lQZ2Delet )

			aAdd( aItens , GdPutIStrItens() )
			nItens := Len( aItens )

			aItens[ nItens , 01 ] := "QZ2"
			aItens[ nItens , 02 ] := NIL
			aItens[ nItens , 03 ] := aClone( aQZ2Header )
			aItens[ nItens , 04 ] := aClone( aQZ2ColDel )
			aItens[ nItens , 05 ] := aClone( aQZ2VirtGd )
			aItens[ nItens , 06 ] := aClone( aQZ2RecDel )
			aItens[ nItens , 07 ] := {}
			aItens[ nItens , 08 ] := NIL
			aItens[ nItens , 09 ] := NIL
			aItens[ nItens , 10 ] := ""

		EndIF

		aAdd( aItens , GdPutIStrItens() )
		nItens := Len( aItens )
		aItens[ nItens , 01 ] := "QZ2"
		aItens[ nItens , 02 ] := {;
									{ "FILIAL"	, xFilial( "QZ2" , xFilial( "QZ1" ) ) },;
									{ "CODEXT"  , cQZ1Codigo };
							 	 }
		aItens[ nItens , 03 ] := aClone( aQZ2Header )
		aItens[ nItens , 04 ] := aClone( aQZ2Cols   )
		aItens[ nItens , 05 ] := aClone( aQZ2VirtGd )
		aItens[ nItens , 06 ] := aClone( aQZ2Recnos )
		aItens[ nItens , 07 ] := {}
		aItens[ nItens , 08 ] := NIL
		aItens[ nItens , 09 ] := NIL
		aItens[ nItens , 10 ] := ""

	EndIF
                           
    If Valtype(aQZ1Cols[ 01 , 01 ]) == "A"
       aQZ1COls := aQZ1Cols[01]
    Endif   

	IF !( lQZ1Modif )
		nLoops := Len( aQZ1Header )
		For nLoop := 1 To nLoops                                          
			aQZ1Cols[ 01 , nLoop ] := GetMemVar( aQZ1Header[ nLoop , 02 ] )
		Next nLoop
		lQZ1Modif := !( ArrayCompare( aQZ1Cols , aSvQZ1Cols ) )
	EndIF

 	lAllModif := ( ( lQZ2Modif ) .or. ( lQZ1Modif ) )

	IF ( lAllModif )

		aMestre[ 01 , 01 ]	:= "QZ1"
		aMestre[ 01 , 02 ]	:= nReg
		aMestre[ 01 , 03 ]	:= lQZ1Modif
		aMestre[ 01 , 04 ]	:= aClone( aQZ1Header )
		aMestre[ 01 , 05 ]	:= aClone( aQZ1VirtEn )
		aMestre[ 01 , 06 ]	:= {}
		aMestre[ 01 , 07 ]	:= aClone( aItens )
		aMestre[ 01 , 08 ]	:= ""

		GdPutInfoData( aMestre , cOpcao , .F. , .F. )

		IF ( cOpcao <> "DELETE" )
			QZ2->( FkCommit() )
			QZ1->( FkCommit() )
		Else
			QZ1->( FkCommit() )
			QZ2->( FkCommit() )
		EndIF

	EndIF

Return( NIL )		


*************************
Static function CarrVld(cCampo)
*************************                    

Local cVldPro := Alltrim(GetSx3Cache( cCampo ,"X3_VALID"))
Local cVldUsr := Alltrim(GetSx3Cache( cCampo ,"X3_VLDUSER"))
             
Local cVldAll := Iif( !Empty(Alltrim(cVldPro)), " (" + Alltrim(cVldPro) + " ) ", ""  ) 
      cVldAll += Iif( !Empty(Alltrim(cVldUsr)), IIF( !Empty(Alltrim(cVldAll))," .and. ", "") + "( " +Alltrim(cVldUsr)+ ") ", "" )

Return( cVldAll )

Static Function Modelo3(cTitulo,cAlias1,cAlias2,aMyEncho,cLinOk,cTudoOk,nOpcE,nOpcG,cFieldOk,lVirtual,nLinhas,aAltEnchoice,nFreeze,aButtons,aCordW,nSizeHeader)
Local lRet, nOpca := 0,cSaveMenuh,nReg:=(cAlias1)->(Recno()),oDlg
Local oEnchoice
Local nDlgHeight   
Local nDlgWidth
Local nDiffWidth := 0          
Local nDiffHeight := 0 
Local lMDI := .F.      
Local lPlugin := .F.
Local nTop := 32
Local aSize := {}

Private Altera:=.t.,Inclui:=.t.,lRefresh:=.t.,aTELA:=Array(0,0),aGets:=Array(0),;
bCampo:={|nCPO|Field(nCPO)},nPosAnt:=9999,nColAnt:=9999
Private cSavScrVT,cSavScrVP,cSavScrHT,cSavScrHP,CurLen,nPosAtu:=0

If IsPlugin() 
	lPlugin := .T.
EndIf

nOpcE := If(nOpcE==Nil,3,nOpcE)
nOpcG := If(nOpcG==Nil,3,nOpcG)
lVirtual := Iif(lVirtual==Nil,.F.,lVirtual)
nLinhas:=Iif(nLinhas==Nil,99,nLinhas)

If SetMDIChild()
	oMainWnd:ReadClientCoors()
	nDlgHeight := oMainWnd:nHeight
	nDlgWidth := oMainWnd:nWidth
	lMdi := .T.
	nDiffWidth := 2
	If lPlugin
		nDiffHeight := 25
	EndIf
Else           
	If lPlugin
		nDlgHeight := oMainWnd:nHeight-55
		nDlgWidth	:= oMainWnd:nWidth-12
		nDiffHeight := 80
		nTop := 10
	Else		
		nDlgHeight := oMainWnd:nHeight-50
		nDlgWidth	:= oMainWnd:nWidth-27
	Endif
	nDiffWidth := 7
EndIf

Default aCordW := {nTop,000,nDlgHeight,nDlgWidth}
Default nSizeHeader := 110
                                       
Aadd(aSize,nSizeHeader)

DEFINE MSDIALOG oDlg TITLE cTitulo From aCordW[1],aCordW[2] to aCordW[3],aCordW[4] Pixel of oMainWnd
If lMdi
	oDlg:lMaximized := .T.
EndIf

oEnchoice := Msmget():New(cAlias1,nReg,nOpcE,,,,aMyEncho,{13,1,(nSizeHeader/2)+13,If(lMdi, (oMainWnd:nWidth/2)-2,__DlgWidth(oDlg)-nDiffWidth)},aAltEnchoice,3,,,,oDlg,,lVirtual,,,,,,,,.F.)       

oGetDados := MsGetDados():New((nSizeHeader/2)+13+2,1,(oMainWnd:nHeight/2)-nDiffHeight,oMainWnd:nWidth/2-nDiffWidth,nOpcG,cLinOk,cTudoOk,"",.T.,,nFreeze,,nLinhas,cFieldOk,,,,oDlg)

ACTIVATE MSDIALOG oDlg ON INIT (EnchoiceBar(oDlg,{||nOpca:=1,If(oGetDados:TudoOk(),If(!obrigatorio(aGets,aTela),nOpca := 0,oDlg:End()),nOpca := 0)},{||oDlg:End()},,aButtons),AlignObject(oDlg,{oEnchoice:oBox,oGetDados:oBrowse},1,,aSize))

lRet:=(nOpca==1)
Return lRet

*****************************
Static Function LoadPublics()
*****************************
   Local cDrive    := ""
   Local cUnidades := "A:B:C:D:E:F:G:H:I:J:K:L:M:N:O:P:Q:R:S:T:U:V:W:X:Y:Z:"
   Local cCaption  := "LoadPublics"
   Local cPathLog  := "LOGS\"
   Local cPathTmp  := "TEMP\"

   Public __nLocalLdr  := GetNewPar("FS_RDI005",1)
   Public __RootClt    := GetNewPar("FS_RDI006","C:\KITMIGRACAO\")

   If ! Empty(__RootClt) .And. ( Right(__RootClt,1) != "\" )
      __RootClt += "\"
   Endif
   
   cDrive := Left(__RootClt,AT(":",__RootClt))
   If ! ( cDrive $ cUnidades )
      U_RDIFMsg('O parโmetro "FS_RDI006" nใo possui uma unidade l๓gica vแlida!'+CRLF+'"{1}"',{__RootClt},3,cCaption)
	  Return .F.
   Endif
   
   If ! U_fMkWrkDir(__RootClt)
      U_RDIFMsg('A pasta definida no parโmetro "FS_RDI006" nใo ้ vแlida!'+CRLF+'"{1}"',{__RootClt},3,cCaption)
	  Return .F.
   Endif
   
   cPathTmp := __RootClt + cPathTmp

   If ! U_fMkWrkDir(cPathTmp)
      U_RDIFMsg('Nใo foi possํvel criar a pasta:'+CRLF+'"{1}"',{cPathTmp},3,cCaption)
	  Return .F.
   Endif
     
   cPathLog := __RootClt + cPathLog  

   If ! U_fMkWrkDir(cPathLog)
      U_RDIFMsg('Nใo foi possํvel criar a pasta:'+CRLF+'"{1}"',{cPathLog},3,cCaption)
      Return .F.
   Endif
   
   //Tenta ajustar a numera็ใo de lote (FS_RDI002)
   U_AjustLote()
   
return .T.
    
***************************************
Static Function RDICpy2S(cAlias,lErase)
***************************************
   Local lRet      := .F.
   Local aFiles    := {}
   Local cMask     := cAlias + "*.TXT"
   Local cCltPath  := ""
   Local cSrvRelat := U_GetDir(101) 
   Local cFileName := "" 
   Local nX        := 0
   Local cError    := ""
   Local bMsg      := {|| U_FormatStr('Copiando "{1}" para o servidor...',{aFiles[nX,F_NAME]}) }
   Local bExec     := {|| lRet := CpyT2S(cFileName,cSrvRelat,.T.) } 
   Local nLocalLdr := __nLocalLdr //SuperGetMv("FS_RDI005",.F.,1)
   Local cCaption  := "RDICpy2S"
   
   Default lErase  := .T.
   
   If ( nLocalLdr != 1) //SqlLoader no cliente...
      Return .T.
   Endif
   
   cCltPath := __RootClt
   
   cSrvRelat += cAlias + "\"
   If ! U_fExistDir(cSrvRelat ) .And. !U_fMkWrkDir(cSrvRelat)
      U_RDIFMsg('Nใo foi possํvel criar o diret๓rio no servidor!'+CRLF+'"{1}"',{cSrvRelat},3,cCaption)
	  Return .F.
   Endif
   
   If lErase .And. ! U_EraseAll(cSrvRelat,cAlias+"*.TXT")
      U_RDIFMsg('Nใo foi possํvel excluir os arquivos existentes no servidor! Verifique.'+CRLF+'"{1}"',{cSrvRelat+cAlias+"*.TXT"},3,cCaption)
	  Return .F.
   Endif

   cCltPath  += cAlias + "\"

   aFiles := Directory(cCltPath + cMask)
   
   For nX := 1 To Len(aFiles)
       cFileName := cCltPath + aFiles[nX,1]
       MsgRun ( Eval(bMsg), "Aguarde...", bExec )
       If ! lRet
          cError := FError()
          U_RDIFMsg('Nใo foi possํvel copiar o arquivo "{1}" para o servidor.{2}',{cFileName,CRLF+CRLF+cError},3,cCaption)
          Exit
       Endif
   Next nX
   
Return lRet

Static Function CarrDef(npLin,npSeq,_cCampo)

	aCols[npLin,1]  := StrZero(npSeq,3)
	aCols[npLin,2]  := GetSx3Cache(_cCampo, 'X3_CAMPO')//SX3->X3_CAMPO
	aCols[npLin,3]  := "6"
	aCols[npLin,4]  := GetSx3Cache(_cCampo, 'X3_CAMPO')//SX3->X3_CAMPO
	aCols[npLin,5]  := Replicate( " ", TamSx3("QZ2_RELACA")[1] )
	aCols[npLin,6]  := Replicate( " ", TamSx3("QZ2_VALIDA")[1] )
	aCols[npLin,7]  := CarrVld(_cCampo) //CarrVld() 
	aCols[npLin,8]  := "N"
	aCols[npLin,9]  := "N"
	aCols[npLin,10]  := GetSx3Cache(_cCampo, 'X3_DESCRIC') //SX3->X3_DESCRIC
	aCols[npLin,11]  := GetSx3Cache(_cCampo, 'X3_TIPO') //SX3->X3_TIPO
	aCols[npLin,12]  := Alltrim(Str(GetSx3Cache(_cCampo, 'X3_TAMANHO'))) //Alltrim(Str(SX3->X3_TAMANHO))
	aCols[npLin,13]  := GetSx3Cache(_cCampo, 'X3_DECIMAL') //SX3->X3_DECIMAL
	aCols[npLin,14]  := If(X3Obrigat(GetSx3Cache(_cCampo, 'X3_CAMPO')),"S","N") //If(X3Obrigat(SX3->X3_CAMPO),"S","N") //IIF(Empty(SX3->X3_OBRIGAT),'N','S')
	aCols[npLin,15]  := ''//A DEFINIR
	aCols[npLin,16]  := GetSx3Cache(_cCampo, 'X3_F3') //SX3->X3_F3
	aCols[npLin,17]  := If(GetSx3Cache(_cCampo, 'X3_CONTEXT') == "V","S","N") //IIF(SX3->X3_CONTEXT=='V','S','N')
	aCols[npLin,18]  := GetSx3Cache(_cCampo, 'X3_CBOX') //SX3->X3_CBOX
	aCols[npLin,19]  := GetSx3Cache(_cCampo, 'X3_GRPSXG') //SX3->X3_GRPSXG
	aCols[npLin,20] := "QZ2"
	aCols[npLin,21] := 0
	aCols[npLin,22] := .F.

Return(.T.)
