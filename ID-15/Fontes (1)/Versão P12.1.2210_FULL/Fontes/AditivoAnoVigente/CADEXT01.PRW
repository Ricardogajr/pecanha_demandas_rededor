#INCLUDE "PROTHEUS.CH"
#INCLUDE "HEADERGD.CH"
#INCLUDE "TRYEXCEPTION.CH"
#include "fileio.ch"

#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH" 

/* 
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCADMETA   บAutor  ณJamer Nunes Pedroso บ Data ณ  01/09/14   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Cadastro de Extratores                                     บฑฑM
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ TDI                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

User Function CADEXT01()

	Private cCadastro	:= "Cadastro de Processos de Importa็ใo"
	
	Private aRotina 	:= MenuDef()
	Public __nLocalLdr  := 2 //executa na maquina, 1 executa no server
   	Public __RootClt    := "C:\MIGRACAO\"

	//SysErrorBlock ({|| U_SysError() })
	
	mBrowse( 6 , 1 , 22 , 75 , "ZVJ" )
Return( NIL )



************************
User Function SysError()
************************
   Local cPathTmp := u_GetTmpKit()
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
//Local Vcall := "Processa( {|lAbort| StaticCall(SUPEXT01,ProcSupTXT,SM0->M0_CODIGO,ZVJ->ZVJ_CODIGO,6) }, 'Aguarde...Preparando arquivo...', 'Carregando: '+Alltrim(ZVJ->ZVJ_DESTINO) ,.T.)"
Local Vcall := "Processa( {|lAbort| ProcSupTXT(SM0->M0_CODIGO,ZVJ->ZVJ_CODIGO,6) }, 'Aguarde...Preparando arquivo...', 'Carregando: '+Alltrim(ZVJ->ZVJ_DESTINO) ,.T.)"

Return(;
		{;
			{ "Pesquisar"		        ,	"AxPesqui"                                                         , 0 , 1 ,0  , .F. },;
			{ "Visualizar"		        ,	"U_MntExec('ZVJ',ZVJ->(Recno()),2)"               , 0 , 2 ,0  , NIL },;
			{ "Incluir"			        ,	"U_MntExec('ZVJ',ZVJ->(Recno()),3)"               , 0 , 3 ,0  , NIL },;
			{ "Alterar"			        ,	"U_MntExec('ZVJ',ZVJ->(Recno()),4)"               , 0 , 4 ,15 , NIL },;
			{ "Excluir"			        ,	"U_MntExec('ZVJ',ZVJ->(Recno()),5)"               , 0 , 5 ,16 , NIL },;
			{ "Executar Pacote"	        ,	"U_CNCTAEXE"                                                       , 0 , 1 ,16 , NIL },;
			{ "Visualizar Log"		    ,	"U_PrvLog(.T.,AllTrim(ZVJ->ZVJ_CODIGO),,,)"  , 0 , 1 ,16 , NIL },;
			{ "Cria Intermediแria"	    ,	"U_MGATMP00"                                                       , 0 , 6 ,16 , NIL },;
			{ "Configurar conexใo"	    ,	"U_SetCfgKit"                                                      , 0 , 6 ,16 , NIL },;
			{ "Sincronizar c/dicionแrio",   "U_CNCTAVLD(ZVJ->ZVJ_CODIGO,.T.,.T.)"                              , 0 , 3 ,16 , NIL } ;
		};                     
)

			//{ "Executar"		        ,	"StaticCall(CADEXT01,SelectImp)"                                   , 0 , 6 ,16 , NIL },;

***************************
Static Function SelectImp()
***************************
    Local cTpImp := AllTrim(ZVJ->ZVJ_TPIMP)
    Local cAlias := AllTrim(ZVJ->ZVJ_DESTIN)
    
    
    EnableTrig(RetSqlName(cAlias),.F.)
    
    Do Case
       Case ( cTpImp == "1" ) //SQL Loader
       
            U_IMPTAB(RetSqlName(AllTrim(ZVJ->ZVJ_DESTIN)),AllTrim(ZVJ->ZVJ_DIRIMP))
            
       Case ( cTpImp == "2" ) //Valida็ใo (ZVJ/ZVK)
       
            U_DORCHARGE()
            
       Case ( cTpImp == "3" ) //Stored Procedure/Banco.
       
            U_MGATMP01()
            
       Case ( cTpImp == "4" ) //MsExecAuto: rotina automแtica Protheus.
       
            ExecAuto(AllTrim(ZVJ->ZVJ_DESTIN))

       Case ( cTpImp == "5" ) //Stored Procedure S/Loader
            
            U_SPNLDR(AllTrim(ZVJ->ZVJ_DESTIN))            
            
       Otherwise
           
            MsgStop("Nใo foi possํvel identificar o m้todo de importa็ใo utilizado! Verifique.")
           
    EndCase 

    EnableTrig(RetSqlName(cAlias),.T.)
       
Return        	

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

User Function MntExec( cAlias , nReg , nOpc )

	Local aZVJCols		:= {}
	Local aSvZVJCols	:= {}
	Local aZVJHeader	:= {}
	Local aZVJFields	:= {}
	Local aZVJVirtEn	:= {}
	Local aZVJVisuEn	:= {}
	Local aZVJNotFields	:= {}
	Local aZVJAltera	:= {}
	Local aZVJNaoAlt	:= {}
	Local aZVJRecnos	:= {}
	Local aZVJKeys		:= {}
    Local nSaveSX8


	Local aZVKKeys
	Local aZVKVirtGd
	Local aZVKVisuGd
	Local aZVKNotFields	:= { "ZVK_CODEXT" }
	Local aZVKRecnos
	Local aSvZVKCols

	Local bGetZVJ
	Local bGetZVK  // Parei aqui

	Local cZVJFil		:= ""
	Local cZVJCodigo	:= ""
	Local cZVKKeySeek

	Local lMod3Ret		:= .F.
	Local lLocks		:= .F.
	Local lExecLock		:= ( ( nOpc <> 2 ) /*/Visualizacao/*/ .and. ( nOpc <> 3 ) /*/Inclusao/*/ )

	Local nLoop			:= 0
	Local nOpcGD		:= nOPC
	Local nZVJUsado		:= 0
	Local nZVKUsado		:= 0
	Local nZVKOrder		:= RetOrder( "ZVK" , "ZVK_FILIAL+ZVK_CODEXT+ZVK_SEQ" )
	Local aAreaZVJ      := nil

	Private aCols		:= {}
	Private aHeader		:= {}

	Private aGets
	Private aTela

	Private n			:= 1

	BEGIN SEQUENCE

		aRotSetOpc( cAlias , @nReg , nOpc )

		bGetZVJ			:= { |lLock,lExclu|	IF( lExecLock , ( lLock := .T. , lExclu	:= .T. ) , aZVJKeys := NIL ),;
											aZVJCols := ZVJ->(;
									  							GdBuildCols(	@aZVJHeader		,;	//01 -> Array com os Campos do Cabecalho da GetDados
																				@nZVJUsado		,;	//02 -> Numero de Campos em Uso
																				@aZVJVirtEn		,;	//03 -> [@]Array com os Campos Virtuais
																				@aZVJVisuEn		,;	//04 -> [@]Array com os Campos Visuais
																				"ZVJ"			,;	//05 -> Opcional, Alias do Arquivo Carga dos Itens do aCols
																				aZVJNotFields	,;	//06 -> Opcional, Campos que nao Deverao constar no aHeader
																				@aZVJRecnos		,;	//07 -> [@]Array unidimensional contendo os Recnos
																				"ZVJ"		   	,;	//08 -> Alias do Arquivo Pai
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
																				@aZVJKeys		,;	//24 -> [@]Array que contera as chaves conforme recnos
																				@lLock			,;	//25 -> [@]Se devera efetuar o Lock dos Registros
																				@lExclu			 ;	//26 -> [@]Se devera obter a Exclusividade nas chaves dos registros
																		    );
															  ),;
											IF( lExecLock , ( lLock .and. lExclu ) , .T. );
		  					} 
	    
	    aAreaZVJ := ZVJ->(FWGetArea())
	    ZVJ->(DbSetOrder( 1 )) 
	    IF !( lLocks := WhileNoLock( "ZVJ" , NIL , NIL , 1 , 1 , .T. , 1 , 5 , bGetZVJ ) )
			Break
		EndIF
	    FWRestArea(aAreaZVJ)

		MkArrEdFlds( nOpc , aZVJHeader , aZVJVisuEn , aZVJVirtEn , @aZVJNaoAlt , @aZVJAltera , @aZVJFields )

   		For nLoop := 1 To nZVJUsado
   			SetMemVar( aZVJHeader[ nLoop , __AHEADER_FIELD__ ] , aZVJCols[ 01 , nLoop ] , .T. )
   		Next nLoop

		cZVJFil		:= ZVJ->ZVJ_FILIAL
		cZVJCodigo	:= ZVJ->ZVJ_CODIGO
		cZVKKeySeek	:= cZVJFil+cZVJCodigo

		ZVK->( dbSetOrder( nZVKOrder ) )

		ZVK->( dbSeek( cZVKKeySeek , .F. ) )

		bGetZVK	:= { |lLock,lExclu|	IF( lExecLock , ( lLock := .T. , lExclu := .T. ) , aZVKKeys := NIL ),;
						 				aCols := ZVK->(;
														GdBuildCols(	@aHeader		,;	//01 -> Array com os Campos do Cabecalho da GetDados
																		@nZVKUsado		,;	//02 -> Numero de Campos em Uso
																		@aZVKVirtGd		,;	//03 -> [@]Array com os Campos Virtuais
																		@aZVKVisuGd		,;	//04 -> [@]Array com os Campos Visuais
																		"ZVK"			,;	//05 -> Opcional, Alias do Arquivo Carga dos Itens do aCols
																		aZVKNotFields	,;	//06 -> Opcional, Campos que nao Deverao constar no aHeader
																		@aZVKRecnos		,;	//07 -> [@]Array unidimensional contendo os Recnos
																		"ZVJ"		   	,;	//08 -> Alias do Arquivo Pai
																		cZVKKeySeek		,;	//09 -> Chave para o Posicionamento no Alias Filho
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
																		@aZVKKeys		,;	//24 -> [@]Array que contera as chaves conforme recnos
																		@lLock			,;	//25 -> [@]Se devera efetuar o Lock dos Registros
																		@lExclu			,;	//26 -> [@]Se devera obter a Exclusividade nas chaves dos registros
																		1				,;	//27 -> Numero maximo de Locks a ser efetuado
																		Altera			 ;	//28 -> Utiliza Numeracao na GhostCol
																    );
														  ),;
										IF( lExecLock , ( lLock .and. lExclu ) , .T. );
		  		    }

	    IF !( lLocks := WhileNoLock( "ZVK" , NIL , NIL , 1 , 1 , .T. , 1 , 5 , bGetZVK ) )
			Break
		EndIF

		IF ( nOpc == 3  ) //Inclusao
		  
			GdDefault( NIL , "ZVJ" , aZVJHeader , @aZVJCols , NIL , .F. )
			
			dbSelectArea("ZVJ")
			dbSetOrder(1)
			dbGobottom()
			                             
		    nSaveSX8 := ZVJ->ZVJ_CODIGO                           
		    
			While (M->ZVJ_CODIGO <= nSaveSX8)
			   M->ZVJ_CODIGO := ZVJ->(GetSX8Num("ZVJ","ZVJ_CODIGO"))
		    EndDo
			
			nSaveSX8 := ZVJ->(GetSX8Len())
            

		EndIF

		aSvZVJCols	:= aClone( aZVJCols )
		aSvZVKCols	:= aClone( aCols )

       lMod3Ret	:=	Modelo3(;
									cCadastro						,;	//cTitulo
									"ZVJ"	  						,;	//cAlias1
									"ZVK"							,;	//cAlias2
									@aZVJFields						,;	//aMyEncho/
									"U_M3Lok()"						,;	//cLinOk
									"U_M3Tok()"						,;	//cTudoOk
									nOpc							,;	//nOpcE
									nOpcGD							,;	//nOpcG,
									NIL								,;	//cFieldOk,
									.T.								,;	//lVirtual
									999								,;	//nLinhas
									aZVJAltera						,;	//aAltEnchoice
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
			          ZVJ->(ConfirmSX8())
		           EndDo
		           
                Endif
	 		    
				MsAguarde(;
							{ ||;
									Mod3ExecGrv(;
													@nOpc		,;	//01 -> Opcao de Acordo com aRotina
								 					@nReg		,;	//02 -> Numero do Registro do Arquivo Pai ( ZVK )
								 					@aZVJHeader	,;	//03 -> Campos do Arquivo Pai ( ZVJ )
								 					@aZVJVirtEn	,;	//04 -> Campos Virtuais do Arquivo Pai ( ZVJ )
								 					@aZVJCols	,;	//05 -> Conteudo Atual dos Campos do Arquivo Pai ( ZVJ )
								 					@aSvZVJCols	,;	//06 -> Conteudo Anterior dos Campos do Arquivo Pai ( ZVJ )
								 					@aHeader	,;	//07 -> Campos do Arquivo Filho ( ZVK )
								 					@aCols		,;	//08 -> Itens Atual do Arquivo Filho ( ZVK )
								 					@aSvZVKCols	,;	//09 -> Itens Anterior do Arquivo Filho ( ZVK )
								 					@aZVKVirtGd	,;	//10 -> Campos Virtuais do Arquivo Filho ( ZVK )
								 					@aZVKRecnos	 ;	//11 -> Recnos do Arquivo Filho ( ZVK )
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

	FreeLocks( "ZVK" , aZVKRecnos , .T. , aZVKKeys )
	FreeLocks( "ZVJ" , aZVJRecnos , .T. , aZVJKeys )
	
Return( NIL )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณMod3XLok   บAutor  ณJamer Nunes Pedroso บ Data ณ  01/09/14   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Funcao para Validacao da Linha Ok da GetDados              บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ TDI                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function M3Lok()

	Local lLinOk  		:= .T.
	
	Local aCposKey 

	Begin Sequence

		IF !( GdDeleted() )
			aCposKey := GdObrigat( aHeader )
			IF !( lLinOk := GdNoEmpty( aCposKey ) )
		    	Break
			EndIF
			//aCposKey := GetArrUniqe( "ZVK" )
			aCposKey := {"ZVK_FILIAL","ZVK_CODEXT","ZVK_SEQ"}
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
ฑฑบPrograma  ณMod3XTok   บAutor  ณJamer Nunes Pedroso บ Data ณ  01/09/14   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Funcao Para Validacao do TudoOk da GetDados                บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ TDI                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

User Function M3Tok()

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
				IF !( lTudoOk := u_M3Lok() )
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
						 	nReg		,;	//02 -> Numero do Registro do Arquivo Pai ( ZVJ )
						 	aZVJHeader	,;	//03 -> Campos do Arquivo Pai ( ZVJ )
						 	aZVJVirtEn	,;	//04 -> Campos Virtuais do Arquivo Pai ( ZVJ )
						 	aZVJCols	,;	//05 -> Conteudo Atual dos Campos do Arquivo Pai ( ZVJ )
						 	aSvZVJCols	,;	//06 -> Conteudo Anterior dos Campos do Arquivo Pai ( ZVJ )
						 	aZVKHeader	,;	//07 -> Campos do Arquivo Filho ( ZVK )
						 	aZVKCols	,;	//08 -> Itens Atual do Arquivo Filho ( ZVK )
						 	aSvZVKCols	,;	//09 -> Itens Anterior do Arquivo Filho ( ZVK )
						 	aZVKVirtGd	,;	//10 -> Campos Virtuais do Arquivo Filho ( ZVK )
						 	aZVKRecnos	 ;	//11 -> Recnos do Arquivo Filho ( ZVK )
						  )

	Local aMestre	:= GdPutIStrMestre( 01 )
	Local aItens	:= {}
	Local cOpcao	:= IF( ( nOpc == 5 ) , "DELETE" , IF( ( ( nOpc == 3 ) .or. ( nOpc == 4 ) ) , "PUT" , NIL ) )
	Local cZVJCodigo	:= GetMemVar( "ZVJ_CODIGO" )
	Local lAllModif	:= .F.
	Local lZVJModif	:= .F.
	Local lZVKModif	:= .F.
	Local lZVKDelet	:= .F.
	
	Local aZVKColDel
	Local aZVKRecDel
	
	Local nLoop
	Local nLoops
	Local nItens

	IF ( cOpcao == "DELETE" )
		GdSuperDel( aZVKHeader , @aZVKCols , NIL , .T. )
		lZVJModif := .T.
	EndIF

	IF ( lZVKModif := !ArrayCompare( aZVKCols , aSvZVKCols ) )
		IF ( cOpcao <> "DELETE" )
			GdSuperDel( aZVKHeader , @aZVKCols , NIL , .T. , GdGetBlock( "ZVK" , aZVKHeader , .F. ) ) 
		EndIF	
		lZVKDelet := GdSplitDel( aZVKHeader , @aZVKCols , @aZVKRecnos , @aZVKColDel , @aZVKRecDel )
	EndIF

	IF ( lZVKModif )

		IF ( lZVKDelet )

			aAdd( aItens , GdPutIStrItens() )
			nItens := Len( aItens )

			aItens[ nItens , 01 ] := "ZVK"
			aItens[ nItens , 02 ] := NIL
			aItens[ nItens , 03 ] := aClone( aZVKHeader )
			aItens[ nItens , 04 ] := aClone( aZVKColDel )
			aItens[ nItens , 05 ] := aClone( aZVKVirtGd )
			aItens[ nItens , 06 ] := aClone( aZVKRecDel )
			aItens[ nItens , 07 ] := {}
			aItens[ nItens , 08 ] := NIL
			aItens[ nItens , 09 ] := NIL
			aItens[ nItens , 10 ] := ""

		EndIF

		aAdd( aItens , GdPutIStrItens() )
		nItens := Len( aItens )
		aItens[ nItens , 01 ] := "ZVK"
		aItens[ nItens , 02 ] := {;
									{ "FILIAL"	, xFilial( "ZVK" , xFilial( "ZVJ" ) ) },;
									{ "CODEXT"  , cZVJCodigo };
							 	 }
		aItens[ nItens , 03 ] := aClone( aZVKHeader )
		aItens[ nItens , 04 ] := aClone( aZVKCols   )
		aItens[ nItens , 05 ] := aClone( aZVKVirtGd )
		aItens[ nItens , 06 ] := aClone( aZVKRecnos )
		aItens[ nItens , 07 ] := {}
		aItens[ nItens , 08 ] := NIL
		aItens[ nItens , 09 ] := NIL
		aItens[ nItens , 10 ] := ""

	EndIF
                           
    If Valtype(aZVJCols[ 01 , 01 ]) == "A"
       aZVJCOls := aZVJCols[01]
    Endif   

	IF !( lZVJModif )
		nLoops := Len( aZVJHeader )
		For nLoop := 1 To nLoops                                          
			aZVJCols[ 01 , nLoop ] := GetMemVar( aZVJHeader[ nLoop , 02 ] )
		Next nLoop
		lZVJModif := !( ArrayCompare( aZVJCols , aSvZVJCols ) )
	EndIF

 	lAllModif := ( ( lZVKModif ) .or. ( lZVJModif ) )

	IF ( lAllModif )

		aMestre[ 01 , 01 ]	:= "ZVJ"
		aMestre[ 01 , 02 ]	:= nReg
		aMestre[ 01 , 03 ]	:= lZVJModif
		aMestre[ 01 , 04 ]	:= aClone( aZVJHeader )
		aMestre[ 01 , 05 ]	:= aClone( aZVJVirtEn )
		aMestre[ 01 , 06 ]	:= {}
		aMestre[ 01 , 07 ]	:= aClone( aItens )
		aMestre[ 01 , 08 ]	:= ""

		GdPutInfoData( aMestre , cOpcao , .F. , .F. )

		IF ( cOpcao <> "DELETE" )
			ZVK->( FkCommit() )
			ZVJ->( FkCommit() )
		Else
			ZVJ->( FkCommit() )
			ZVK->( FkCommit() )
		EndIF

	EndIF

Return( NIL )		



/*Leitura de texto delimitado */
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณProcTxt1  บAutor  ณMicrosiga           บ Data ณ  03/30/17   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
static Function ProcTXT(cpEmp, pcCodExt)

Local aArea := FWGetArea()
Local aCampos := {}
Local cAliasOrigem, cAliasDestino
Local lRet := .T.
Local cTcSql
Local cCRLF := Chr(10)+Chr(13)
Local cLinha  := ""
Local lPrim   := .T.
Local aDados  := {}

Private aErro := {}
Private cDir :="/"
Private cArq :="cn9.txt"

if Ascan(aProcTxt,cpEmp) > 0
 
 Return(.T.)
else
 aadd( aProcTxt, cpEmp )
 
 RecLock("ZVJ",.F.)
 ZVJ->ZVJ_EMPORI := cpEmp
 ZVJ->(MsUnlock())
 
endif

dbSelectArea("ZVK")
dbSetOrder(1)
dbSeek(xFilial("ZVK")+ZVJ->ZVJ_CODIGO)

DbEval ( {|| aAdd( aCampos , { ZVK->ZVK_SEQ, ZVK->ZVK_CPOORI, ZVK->ZVK_CPODES, ZVK->ZVK_TIPCPO } ) },,{|| ZVK->ZVK_CODEXT == ZVJ->ZVJ_CODIGO },,,) // varrendo dados

cAliasDestino := OpenOEmp(alltrim(ZVJ->ZVJ_DESTINO),ZVJ->ZVJ_EMPDES)

//CRLF := Chr(10)+Chr(13)

/*cSqlExec := " BEGIN "+CRLF
cSqlExec := " TRUNCATE TABLE " +RetSqlName( Alltrim(ZVJ->ZVJ_DESTINO) )+ " IMMEDIATE ;" + CRLF
cSqlExec += " "+CRLF
cSqlExec += " COMMIT; "+CRLF
cSqlExec += " END; "+CRLF


cTcSql := TCSQLExec( cSqlExec )

ConOut( "Retorno da remo็ใo: "+ Strzero(cTcSql,10)+ " - "+"delete "+RetSqlName( Alltrim(ZVJ->ZVJ_DESTINO) ) )

ConOut( "Iniciando importa็ใo: "+pcCodExt+"|"+cpEmp+"|"+cAliasOrigem+"|"+ZVJ->ZVJ_EMPDES+"|"+cAliasDestino)
*/

FT_FUSE(cDir+cArq)
ProcRegua(FT_FLASTREC())
FT_FGOTOP()
While !FT_FEOF()
 
 IncProc("Lendo arquivo texto...")
 
 cLinha := FT_FREADLN()
 
 If lPrim
  aCampos := Separa(cLinha,";",.T.)
  lPrim := .F.
 Else
  AADD(aDados,Separa(cLinha,";",.T.))
  Copia_Registro( cAliasOrigem, ZVJ->ZVJ_INDORI, ZVJ->ZVJ_CHVPSQ, cAliasDestino, ZVJ->ZVJ_INDDES, aCampos )
  
  FT_FSKIP()
  
  
  //    aDados := STRTOKARR(fT_readln(),2)
  
  ConOut( "Iniciando importa็ใo: "+pcCodExt+"|"+cpEmp+"|"+cAliasOrigem+"|"+ZVJ->ZVJ_EMPDES+"|"+cAliasDestino)
  
  //For i:=1 to Len(aDados)
 EndIf
 
 
 //Next i
 
EndDo

ConOut( "Finalizando importa็ใo: "+pcCodExt+"|"+cpEmp+"|"+cAliasOrigem+"|"+ZVJ->ZVJ_EMPDES+"|"+cAliasDestino)

(cAliasDestino)->(dbCloseArea())

RecLock("ZVJ",.F.)
ZVJ->ZVJ_EMPORI := cEmpZVJ
ZVJ->(MsUnlock())

FWRestArea(aArea)

Return(.T.)


User Function CarrCols(cpAlias)

Local aArea := FWGetArea() 
Local nSeq  := 0
Local nLin  := 0
Local _n07
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

//If !Empty(FWSX3Util():GetFieldType(cpAlias)) .and. Len(aCols) == 1 .and. Empty(aCols[1,2] )
//if dbSeek(Alltrim(cpAlias)) .and. Len(aCols) == 1 .and. Empty(aCols[1,2] )
//   aCols := {}
   //SX3->( DbEval ( {||aadd(aCols,Array(Len(aHeader)+1)), Carrdef(++nLin, ++nSeq) },,{|| SX3->X3_ARQUIVO == Alltrim(cpAlias) },,,)  ) // varrendo dados
//   DbEval ( {||aadd(aCols,Array(Len(aHeader)+1)), u_Carrdef(++nLin, ++nSeq,cpAlias) },,{|| GetSx3Cache(cpAlias, 'X3_ARQUIVO') == Alltrim(cpAlias) },,,)
//endif

oGetDados:oBrowse:Refresh()

FWRestArea(aArea)

Return(.T.)

Static function CarrVld(cpAlias)                    

Local cVldPro := Alltrim(GetSx3Cache(cpAlias, 'X3_VALID'))
Local cVldUsr := Alltrim(GetSx3Cache(cpAlias, 'X3_VLDUSER'))
             
Local cVldAll := Iif( !Empty(Alltrim(cVldPro)), " (" + Alltrim(cVldPro) + " ) ", ""  ) 
      cVldAll += Iif( !Empty(Alltrim(cVldUsr)), IIF( !Empty(Alltrim(cVldAll))," .and. ", "") + "( " +Alltrim(cVldUsr)+ ") ", "" )


Return( cVldAll )

Static Function CarrDef(npLin,npSeq,cpAlias)
 
	aCols[npLin,1]  := StrZero(npSeq,3)
	aCols[npLin,2]  := GetSx3Cache(cpAlias, 'X3_CAMPO') 
	aCols[npLin,3]  := "6"
	aCols[npLin,4]  := GetSx3Cache(cpAlias, 'X3_CAMPO') 
	aCols[npLin,5]  := Replicate( " ", TamSx3("ZVK_RELACA")[1] )
	aCols[npLin,6]  := Replicate( " ", TamSx3("ZVK_VALIDA")[1] )
	aCols[npLin,7]  := CarrVld(cpAlias) 
	aCols[npLin,8]  := "N"
	aCols[npLin,9]  := "N"
	aCols[npLin,10]  := GetSx3Cache(cpAlias, 'X3_DESCRIC') 
	aCols[npLin,11]  := GetSx3Cache(cpAlias, 'X3_TIPO') 
	aCols[npLin,12]  := Alltrim(Str(GetSx3Cache(cpAlias, 'X3_TAMANHO') ))
	aCols[npLin,13]  := GetSx3Cache(cpAlias, 'X3_DECIMAL') 
	aCols[npLin,14]  := IIF(Empty(GetSx3Cache(cpAlias, 'X3_OBRIGAT') ),'N','S')
	aCols[npLin,15]  := ''//A DEFINIR
	aCols[npLin,16]  := GetSx3Cache(cpAlias, 'X3_F3') 
	aCols[npLin,17]  :=  IIF(GetSx3Cache(cpAlias, 'X3_CONTEXT') =='V','S','N')
	aCols[npLin,18]  := GetSx3Cache(cpAlias, 'X3_CBOX') 
	aCols[npLin,19]  := GetSx3Cache(cpAlias, 'X3_GRPSXG') 
	aCols[npLin,20] := "ZVK"
	aCols[npLin,21] := 0
	aCols[npLin,22] := .F.

Return(.T.)


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

/*Static Function Call_ProcImp(nRecno)

Local aArea := FWGetArea()
Local aPergs := {}
Local nQtdThreads := 0
Local aRet := {}

Private lAbort := .F.
Private oProcimp 

ZVJ->(dbGoto(nRecno))

 
aAdd( aPergs ,{3,"Execu็ใo em Threads   ?",2, {"Sim", "Nao"}, 50,'.T.',.T.})    
aAdd( aPergs ,{1,"Quantidade de Threads:",nQtdThreads,"999",".T.","",".T.",30,.F.})   
	  		  	
If !ParamBox(aPergs ,"Threads",aRet)   
   Return(.F.)
Endif

if mv_par02 == 0 .or. mv_par02 > 15
   mv_par02 := 15
endif    

if mv_par01 == 1
   //mv_par02 := 2
   oProcImp := MsNewProcess():New( {|lAbort| ProcTXThreah(SM0->M0_CODIGO,ZVJ->ZVJ_CODIGO,@oProcImp,@lAbort,mv_par02) }, 'Aguarde...Preparando arquivo...', 'Carregando: '+Alltrim(ZVJ->ZVJ_DESTINO) , .T. )
else
                                          
   oProcImp := MsNewProcess():New( {|lAbort| ProcSupTXT(SM0->M0_CODIGO,ZVJ->ZVJ_CODIGO,@oProcImp,@lAbort) }, 'Aguarde...Preparando arquivo...', 'Carregando: '+Alltrim(ZVJ->ZVJ_DESTINO) , .T. )
endif

//oProcImp:odlg:nleft := 690

oProcImp:Activate()

FreeObj(oProcImp)

FWRestArea(aArea)	
Return(.T.)*/


********************************
Static function ExecAuto(cAlias)
********************************
   Local lRet      := .F.
   Local cFunction := "U_ExAuto"+AllTrim(cAlias)
   
   If FindFunction(cFunction)
      lRet := &(cFunction+'()')
   Else
      MsgStop('A rotina "'+cFunction+'" nใo estแ compilada!')
   Endif
   
Return lRet


/*
======================================================
Autor: Jamer Nunes Pedroso/Pedro 
Data:	03.2017
------------------------------------------------------
Descricao:
Rotina de abertura da tabela
======================================================
*/
Static Function ProcSupTXT(cpEmp, pcCodExt,oProcesso, lAbort)

Local aArea := FWGetArea()
Local aCampos := {}
Local cAliasOrigem, cAliasDestino
Local lRet := .T.
Local cTcSql
Local cCRLF := Chr(10)+Chr(13)
Local cLinha  := ""
Local lPrim   := .T.
Local nPos := 0
Local cIndDes := ""  
Local nUniq
Local aPosKeys := {}                   
Local nCpCount := 0
Local lEstOk   := .T.
Local nCFalta
Local nCFiles := 0
Local nsInicio := seconds()
Local cTInicio := U_Now(nsInicio)
Local cTFinal  

Private nGrvAll := 0
Private oAllDados
Private aProcEmp  := {}
Private cEmpZVJ   := ZVJ->ZVJ_EMPORI
Private nSeqErr     := 0

Private nRegCount := 0 
Private nRegTotal 
Private nTotErro  := 0
Private aDados  
Private aErro := {}
Private cDirArq :=Alltrim(ZVJ->ZVJ_DIRIMP)
Private aCpodata 
Private aDados

Private aFiles := {}
Private cHoraInicio := Time()
Private cDataInicio := Date()
   

if !MSGYESNO( 'Continua ?', 'Carga para ' + ZVJ->ZVJ_DESTINO )
   FWRestArea(aArea)
   Return(.F.)
endif   


If Right(Alltrim(Upper(cDirArq)),1) == "\" .and. !(Right(Alltrim(cDirArq),1)$".TXT|.CSV" )

   Aeval( Directory(cDirArq+"*.txt"), {|x|x[1] := cDirArq+x[1] ,aadd(aFiles, x ) } )
   Aeval( Directory(cDirArq+"*.csv"), {|x|x[1] := cDirArq+x[1] ,aadd(aFiles, x ) } )

Else 
   aFiles := {{cDirArq}}
Endif 

If Len(aFiles) == 0

   MsgStop("Nใo hแ arquivos n diret๓rio especificado...")
   Return(.F.)
Endif

if Ascan(aProcEmp,cpEmp) > 0
 
 Return(.T.)
else
 aadd( aProcEmp, cpEmp )
 
 RecLock("ZVJ",.F.)
 ZVJ->ZVJ_EMPORI := cpEmp
 ZVJ->(MsUnlock())
 
endif

dbSelectArea("ZVK")
dbSetOrder(1)
dbSeek(xFilial("ZVK")+ZVJ->ZVJ_CODIGO)

nDbeval := 0

DbEval ( {|| aAdd( aCampos , 	{ ZVK->ZVK_SEQ, ZVK->ZVK_CPOORI, ZVK->ZVK_CPODES, ZVK->ZVK_TIPCPO, ZVK->ZVK_RELACA, ZVK->ZVK_VALIDA, ZVK->ZVK_PROVLD, AtuVld(ZVK->ZVK_CPODES), ZVK->ZVK_REJEIT } ) },,{|| ZVK->ZVK_CODEXT == ZVJ->ZVJ_CODIGO },,,) // varrendo dados PEDRO SAMPAIO

cAliasDestino := alltrim(ZVJ->ZVJ_DESTINO) //OpenOEmp(alltrim(ZVJ->ZVJ_DESTINO),ZVJ->ZVJ_EMPDES)
cAliasOrigem  := cAliasDestino // Compatibilidade

MakeUnikey(cAliasDestino)

ConOut( "Iniciando importa็ใo: "+pcCodExt+"|"+cpEmp+"|"+cAliasOrigem+"|"+ZVJ->ZVJ_EMPDES+"|"+cAliasDestino)

// Inํcio do For Arquivo
For nCFiles := 1 to Len(aFiles)

   cHoraInicio := Time()
   cDataInicio := Date()
   lPrim := .T.
   nRegCount := 0
   cTInicio := U_Now(nsInicio)

   oProcesso:SetRegua1(0)
   oProcesso:SetRegua2(0)
   
   oProcesso:IncRegua1("Configurando a carga...")
    

   cDirArq := aFiles[nCFiles,1]

   cRddName  := "TOPCONN" // "DBFCDXADS" 
   oFile   := fTdb():New()
   ofile:ft_fSetRddName( cRddName )
   
   IF ( ofile:ft_fUse( cDirArq, @oProcesso ) <= 0 )
   
       oFile:ft_fUse()
       MsgStop("Arquivo nao pode ser aberto: " + cDirArq)
       ConOut( "Arquivo nao pode ser aberto: " + cDirArq)
	   Return

   EndIF

   nRegTotal := (oFile:ft_fRecCount()-1)


   RegToMemory(ZVJ->ZVJ_DESTIN,.F.,.F.)

	While !( oFile:ft_fEof() ) .and. ( nRegCount <= (nRegTotal) ) // Executando while condicional
	
	   if oProcesso:lEnd
	      MsgStop("Carga cancelada") 
	      exit
	   Endif
	
                        
		cLinha := Replace( oFile:ft_fReadLn(), '"', "" )
 
		If ( oFile:ft_fRecno() == 1 )
	
			aCpoData := Separa( Replace( Replace(cLinha,Chr(10),""),Chr(13),""),iif( at(CHR(165),cLinha)>0,CHR(165),If(at(CHR(167),cLinha)>0,chr(167),";")),.T.)
			lPrim := .F.; lEstok := .T.
			cIndDes := ""
			aPosKeys := {}
			(cAliasDestino)->(dbSetOrder(ZVJ->ZVJ_INDDES))
			aUniq := Separa( Replace( Replace( (cAliasDestino)->(IndexKey()),"DTOS(","" ), ")","") ,"+",.T.)
    
			For nCpCount := 1 to Len(aCpodata) // #Consist๊ncia estrutura do arquivo enviado
 
				aCpodata[nCpCount] := replace(replace(aCpodata[nCpCount],char(13),""), chr(10),"")
    
				if ( nPos := AScan( ACampos,{|x| Alltrim(x[3]) == Alltrim(ACpoData[nCpCount])},,) ) = 0
					cConteud := "Tabela:["+Alltrim(ZVJ->ZVJ_DESTINO)+"] - Campo Inexistente na tabela:["+Alltrim(aCpoData[nCpCount])+"]- Linha do arquivo:["+Strzero(nRegCount,12)+"]"
					U_LOGMIG01(ALLTRIM(ZVJ->ZVJ_DESTINO),StrZero(nSeqErr++,5),cDirArq,cConteud,"004",cDataInicio,cHoraInicio,nRegCount,nTotErro++)
					lEstOk := .F.
				Endif
       
			Next 1
    
			For nCpCount := 1 to Len(aCampos) // #Consist๊ncia estrutura do arquivo enviado
    
				if ( nPos := AScan( ACpoData,{|x| Alltrim(x) == Alltrim(aCampos[nCpCount,3])},,) ) = 0
					cConteud := "Tabela:["+Alltrim(ZVJ->ZVJ_DESTINO)+"] - Campo Inexistente no arquivo:["+Alltrim(aCampos[nCpCount,3])+"]- Linha do arquivo:["+Strzero(nRegCount,12)+"]"
					U_LOGMIG01(ALLTRIM(ZVJ->ZVJ_DESTINO),StrZero(nSeqErr++,5),cDirArq,cConteud,"004",cDataInicio,cHoraInicio,nRegCount,nTotErro++)
					lEstOk := .F.
				Endif
       
              
              if (cAliasDestino)->(FieldPos(aCampos[nCpCount,3])) == 0 // Campos existe no config e nใo existe na tabela
                 aCampos[nCpCount,4] := "0"          
	          endif
       
			Next 1

  
			/* Montando chave de indice para pesquisa */
			For nUniq := 1 to  Len(aUniq) // #Consist๊ncia de campos indices
  
				nPos := AScan( aCpodata, {|x| Alltrim(x) == Alltrim(aUniq[nUNiq])},,)
				if nPos = 0
                   
					cConteud := "Tabela:["+Alltrim(ZVJ->ZVJ_DESTINO)+"] - Erro fatal. Estrutura de chave unica invalida:["+(Alltrim(ZVJ->ZVJ_DESTINO))->(IndexKey())+"] - Linha do arquivo:["+Strzero(nRegCount,12)+"]"
					U_LOGMIG01(ALLTRIM(ZVJ->ZVJ_DESTINO),StrZero(nSeqErr++,5),cDirArq,cConteud,"002",cDataInicio,cHoraInicio,nRegCount,nTotErro++)
					lEstOk := .F.
				else
          
					cIndDes += Iif(nUniq<>1,"+","")+"aDados["+StrZero(nPos,4)+"]"
					aAdd( aPosKeys, "aDados["+StrZero(nPos,4)+"]" )
				endif
       
			next 1
    
			if !lEstok .and. ZVJ->ZVJ_REJEITA = "1"
			   MsgStop("Estrutura inconsistente.Campos de indice")
			    oFile:ft_fUse()
				Return(.F.)
			Endif
 
	       oFile:ft_fSkip()

			Loop
		Else
		
		    if Mod(nRegCount,50) = 0
		    
		       
		       nsNow    := Seconds()
		       nsTime   := NsNow-nsInicio
		       nsInicio := nsNow
		       nsRest   := ((nRegTotal-nRegCount)/50)*nSTime
		       cTRest    := U_Now(nsRest)
	
              oprocesso:odlg:ccaption := "Carregando arquivo"
	          
	          oProcesso:IncRegua1("Carregando:"+Alltrim(ZVJ->ZVJ_DESTINO)+" - "+ StrZero(nRegCount,10)+"/"+StrZero(nRegTotal,10))
	          oProcesso:IncRegua2(" Decorrido:"+ElapTime(Left(cTInicio,8),Left(U_Now(),8) )+ " Restante:"+ cTRest )
             
           endif   
           
			aDados := Separa(Replace(Replace(cLinha,Chr(10),""),Chr(13),""),iif( at(CHR(165),cLinha)>0,CHR(165),If(at(CHR(167),cLinha)>0,chr(167),";")),.T.)
  
			if ( nFfalta := ( Len(aCpoData)-len(aDados) ) ) > 0 // Campos a menos nas linhas de dados
  
				For nCFalta := 1 to nFfalta
     
					aadd( aDados, " " )
				Next 1
     
			endif
                                
			nRegCount++
                    
          Copia_Registro( cAliasOrigem, ZVJ->ZVJ_INDORI, cIndDes, cAliasDestino, ZVJ->ZVJ_INDDES, aCampos, @oProcesso, aCpoData )
  
  
		Endif



	Enddo

    oFile:ft_fUse()
    FreeObj(oFile)
     
	U_LOGMIG01(ALLTRIM(ZVJ->ZVJ_DESTINO),StrZero(nSeqErr++,5),cDirArq,"Finaliza็ใo - Tabela - "+ZVJ->ZVJ_DESTINO,"000",cDataInicio,cHoraInicio,nRegCount,nTotErro++)
 
    if oProcesso:lEnd
	    Exit
	 Endif

// Final do For Arquivos 
Next 1


ConOut( "Finalizando importa็ใo: "+pcCodExt+"|"+cpEmp+"|"+cAliasOrigem+"|"+ZVJ->ZVJ_EMPDES+"|"+cAliasDestino)

(cAliasDestino)->(dbCloseArea())

RecLock("ZVJ",.F.)
ZVJ->ZVJ_EMPORI := cEmpZVJ
ZVJ->(MsUnlock())

FWRestArea(aArea)

if !oProcesso:lEnd 
   MsgStop(  "Processamento:"+Alltrim(ZVJ->ZVJ_DESTINO)+" - "+ StrZero(nRegCount,10)+"/"+StrZero(nRegTotal,10)+ " concluํdo !" )
endif

Return(.T.)

**********************************************************************
User Function PrvLog(lGerar,cCodProc,cDataRef,cHoraRef,cFileRpt)
**********************************************************************
   Local cLocalFile := "" 
   Local cFileName  := ""
   Local cProcesso  := ""
   Local bGeraRpt   := {|| cFileName := U_GerRel(cCodProc,cDataRef,cHoraRef) }
   Local lRet       := .T.
   Local lCopyOk    := .F.
   
   Default cFileRpt := ""
   
   If !lGerar .And. !File(cFileRpt)
      MsgStop("Nใo foi possํvel localizar o arquivo de relat๓rio! Verifique.")
      return .F.
   Endif
   
   If lGerar
      MsgRun("Gerando o log...", "Aguarde...", bGeraRpt)
   Else
      cFileName := cFileRpt
   Endif
   
   lRet := File(cFileName)
   
   If lRet
      cLocalFile := U_GetDirc(300) + Right(cFileName,LEN(cFileName)-RAT("\",cFileName))
      MsgRun( "Abrindo o arquivo de log...", "Aguarde...", { || lCopyOk := CpyS2T(cFileName,U_GetDirc(300)) } )
      lRet := lCopyOk .And. File(cLocalFile)
      If lRet 
         //ShellExecute("Open",cLocalFile,"","",3)	// 1 = Normal, 2 = Minimizado, 3 = Maximizado
		ShellExecute("open","excel.exe",'"' + cLocalFile + '"',"",3)
      Endif
   Endif
   
Return lRet

**********************************************
Static Function EnableTrig(cTableName,lEnable)
**********************************************
   Local cAlias := GetNextAlias()
   Local cQuery := ""
   Local cEnable:= If(lEnable,"enable","disable")
   
   cQuery += "select 'alter trigger '||t.table_owner||'.'||t.trigger_name||' {1}' SCRIPT     " + CRLF
   cQuery += "from USER_TRIGGERS t                                                            " + CRLF
   cQuery += "where t.base_object_type = 'TABLE'                                              " + CRLF
   cQuery += "AND t.table_name = '{2}'                                                        " + CRLF
   cQuery += "ORDER BY t.table_name                                                           "
   
   cQuery := u_FmtStr(cQuery,{cEnable,cTableName})

   TCQUERY cQuery NEW ALIAS (cAlias)
   
   While (cAlias)->(!Eof())
       cScript := AllTrim( (cAlias)->SCRIPT )
       If (TCSQLExec(cScript) < 0) 
          Aviso('Erro ao executar o script!',TCSQLError(),{"Fechar"},3)
       Endif
       (cAlias)->(DbSkip(1))
   Enddo
   
   If Select(cAlias) > 0   ; (cAlias)->(DbCloseArea()) ; Endif

return 
