#INCLUDE "TOTVS.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#include "tbiconn.ch"

***********************
User Function UPD0304() 
***********************   
    Private lcabec   := .F.
 	Private Afilial1  := {}	
	Private aDados 	 := {}
    Private aEmpresas := {}
	Private aVetor := {}
    Private cArquivo := Space(150)
    Private lOk      :=.F.
	Private nLidos  := 0
	Private nProce  := 0    
	Private lCorrigeLiq := .F.
    Private aUnidades :={}
	Private aUnid2    :={}
	Private agrupos   :={}
    Private cRetxx8 := ""
    Private oExcel   
	Private otext                                         
    Private cTempPath:=GetTempPath()

	Private aParmBox    := {} // Perguntas do Parambox
	Private aRetBox     := {} // Retorno do Parambox
	Private fDtDigitIni  := stod("  /  /    ")
	Private fDtDigitFim  := stod("  /  /    ")  
	Private cEmpIni   := ""
	Private cEmpFim   := ""
	Private cEmpPro   := ""
    Private cFilPro   := ""
	Private Ix1       := 0
	Private Ix2       := 0
    Private cDirSrv  := '\SPOOL\'
    Private cArq     := 'UPD0304.CSV'

    CARQ4  := cDirSrv+cArq

    nHandle4 := Fcreate(cArq4,0)		// cria o arquivo
    If Ferror() != 0
       Conout("houve erro na criacao do arquivo UPD0304.CSV")
    endif       
	 
  //  U_FSAtuSXB()	

    //旼컴컴컴컴컴컴컴컴컴컴?
    //?RUPO DE EMPRESAS    ?
    //읕컴컴컴컴컴컴컴컴컴컴?
    DbSelectArea("XX8")
    XX8->(dbSetOrder(1))
    XX8->(dbGoTop())

    While !XX8->(Eof())
   
      If XX8_TIPO == "0"
	     aAdd( AEMPRESAS, { XX8->XX8_CODIGO, XX8->XX8_DESCRI } )
      EndIf
   
      XX8->(DbSkip())
   
    Enddo

    //旼컴컴컴컴컴컴컴컴컴컴?
    //?ELACAO DE FILIAIS   ?
    //읕컴컴컴컴컴컴컴컴컴컴?
    DbSelectArea("XX8")
    XX8->(dbSetOrder(1))
    XX8->(dbGoTop())

    While !XX8->(Eof())
   
      If XX8_TIPO == "3"
	     aAdd( AFILIAl1, { XX8->XX8_GRPEMP, alltrim(XX8->XX8_EMPR)+alltrim(XX8_UNID)+alltrim(XX8_CODIGO) } )
      EndIf
   
      XX8->(DbSkip()) 
     
    Enddo

	// Parametro de Emissao

   	AAdd( aParmBox, {1, "Demitidos  De : ", fDtDigitIni, "@D","","","",50, .T. } )
	AAdd( aParmBox, {1, "Demitidos  Ate: ", fDtDigitFim, "@D","","","",50, .T. } )
	aAdd( aParmBox, {1, "Grupo de Empressa De  : ",Space(5),"","","XX8GRP","",0,.F.})
	aAdd( aParmBox, {1, "Grupo de Empressa Ate : ",Space(5),"","","XX8GRP","",0,.F.})


	If( ParamBox(aParmBox, "Incluir Demitidos Entre", @aRetBox,,,.T.,,,,,,) )
	    If( Len(aRetBox)==Len(aParmBox) )
	        dDtDigitIni := dtos(aRetBox[1])
	        dDtDigitFim := dtos(aRetBox[2])
			IF dDtDigitIni > dDtDigitFim
               MsgStop( "Parametro Invalido", "UPD0304" )
			   Return .F.
			endif 
			if aRetbox[3] > aRetbox[4]
               MsgStop( "Parametro Invalido", "UPD0304" )
			   Return .F.
			else
			   cEmpIni := SUBSTRING(aRetbox[3],1,2)
			   cEmpFim := SUBSTRING(aRetbox[4],1,2)
			endif
	    Else
	        Return .F.
	    EndIf
	Else
		Return .F.
	EndIf


    cEmpPro:="01"
	cFilpro:="00000000"
	ix2 := Len(Afilial1)
    
	While cEmpPro <= cEmpFim
	   if cemppro >= cempini .and. cemppro <= cEmpFim
         MsAguarde({|lEnd| u_fupd0304()},"Aguarde...","Processando",.T.)
		endif 
        cEmppro := strzero(val(cemppro)+1,2,0) 
    enddo   

    Fclose (nHandle4)

//	PREPARE ENVIRONMENT EMPRESA cEmpantBkp FILIAL cFilantBkp

	//If (ApOleClient("MSExcel")) //.not.(ApOleClient("MSExcel"))
       CpyS2T(cArq4, cTempPath)
//       oExcel:=MSExcel():New()
//       oExcel:WorkBooks:Open(cTempPath+carq)
//       oExcel:SetVisible(.T.)
//       oExcel:Destroy()
       
       
       ShellExecute("Open", carq, "", cTempPath, 1 )
//	Else 
//		Break
//    Endif

//	If (ApOleClient("MSExcel"))//.not.(ApOleClient("MSExcel"))
//       aviso('Processamento Realizado!',"Arquivo Gerado em \SPOOL\UPD0304.CSV", {'OK'}, 1)
//    Endif

	MsgStop( "Fim da Rotina", "UPD0304" )

Return

 
***************************
User Function fupd0304()
***************************

    local csufix := cemppro+"0"
	Local npos := 0
    Local Nx   := 0

    If !lcabec
       cMsg := "GRUPO EMPRESA;REGIONAL_FUNCIONAL;"
       cMsg += "COD_FILIAL;"     
       cMsg += "NOME_DA_UNIDADE;"
       cMsg += "UF_UNIDADE;"                   
       cMsg += "RAZAO_SOCIAL;"                  
       cMsg += "CENTRO_CUSTO;"                   
       cMsg += "DESCR_CENTRO_CUSTO;"    
       cMsg += "MATRICULA;"                       
       cMsg += "CPF;"                             
       cMsg += "NOME_FUNCIONARIO;"                
       cMsg += "COD_FUNCAO;"                      
       cMsg += "DESCRICAO_DA_FUNCAO;"             
       cMsg += "GRUPO_CARGOS;"                    
       cMsg += "DESCR_GRUPO_CARGOS;"
       cMsg += "SEXO;"   
       cMsg += "NASCIMENTO;"                      
       cMsg += "SITUACAO;"    
	   cMsg += "SITUACAO_DESCR;"  
       cMsg += "ADMISSAO;"                        
       cMsg += "DEMISSAO;"                        
       cMsg += "CAT_FUNC;"  
	   cMsg += "CATEGORIA_FUNC;"
	   cMsg += "TIPO_DE_CONTRATACAO;"  
       cMsg += "CCUSTO_DIR;" 
       cMsg += "DCCUSTODIR;"
       cMsg += "CCUSTO_SETOR1;"
       cMsg += "DCCUSTOSET1;"  
       cMsg += "CCUSTO_SETOR3;" 
       cMsg += "DCCUSTOSET3;"   
       cMsg += "EMAIL;"                             
       cMsg += CRLF
       FWrite(nHandle4,cMsg,Len(cMsg))    
       lcabec := .T.
	ENDIF

	cMsg := '*** Filtrando Registros Grupo '+cemppro+'****'
    FWMONITORMSG(cMsg)
    MsProcTxt(cMsg)	
    ProcessMessage()     
  
	/////////////////////////////// 
    // SELECIONANDO FUNCIONARIOS //
	///////////////////////////////

	cQry :="SELECT                                                                                                                                           " 
	cQry +="       C09.C09_DESCRI                   AS REGIONAL_FUNCIONAL,                                                                                   "
	cQry +="       SRA.RA_FILIAL                    AS COD_FILIAL,                                                                                           "
	cQry +="       ZM0.ZM0_FILNOM                   AS NOME_DA_UNIDADE,                                                                                      "
	cQry +="       ZM0.ZM0_ESTCOB                   AS UF_UNIDADE,                                                                                           "
	cQry +="       ZM0.ZM0_NOMECO                   AS RAZAO_SOCIAL,                                                                                         "
	cQry +="       SRA.RA_CC                        AS CENTRO_CUSTO,                                                                                         "
	cQry +="       nvl(CTT.CTT_DESC01,' ')          AS DESCR_CENTRO_CUSTO,                                                                                   "
	cQry +="       SRA.RA_MAT                       AS MATRICULA,                                                                                            "
	cQry +="       SRA.RA_CIC                       AS CPF,                                                                                                  "
	cQry +="       SRA.RA_NOME                      AS NOME_FUNCIONARIO,                                                                                     "
	cQry +="       SRA.RA_CODFUNC                   AS COD_FUNCAO,                                                                                           "
	cQry +="       nvl(SRJ.RJ_DESC,' ')             AS DESCRICAO_DA_FUNCAO,                                                                                  "
	cQry +="       nvl(SQ3.Q3_GRUPO,' ')            AS GRUPO_CARGOS,                                                                                         "
	cQry +="       nvl(SQ0.Q0_DESCRIC,' ')          AS DESCR_GRUPO_CARGOS,                                                                                   "
	cQry +="       SRA.RA_SEXO                      AS SEXO,                                                                                                 "
	cQry +="       SRA.RA_NASC                      AS NASCIMENTO,                                                                                           "
	cQry +="       SRA.RA_SITFOLH                   AS SITUACAO,                                                                                             "
	cQry +="	  (SELECT DISTINCT nvl(SX5.X5_DESCRI,' ') FROM SX5"+CSUFIX+" SX5 WHERE SX5.D_E_L_E_T_ = ' '  AND SX5.X5_TABELA='31' AND X5_CHAVE=SRA.RA_SITFOLH)      "
	cQry +="	                                    AS SITUACAO_DESCR,                                                                                       "
	cQry +="       SRA.RA_ADMISSA                   AS ADMISSAO,                                                                                             "
	cQry +="       SRA.RA_DEMISSA                   AS DEMISSAO,                                                                                             "
	cQry +="       SRA.RA_CATFUNC                   AS CAT_FUNC,                                                                                             "
	cQry +="      (SELECT DISTINCT nvl(SX5.X5_DESCRI,' ') FROM SX5"+CSUFIX+" SX5 WHERE SX5.D_E_L_E_T_ = ' '  AND SX5.X5_TABELA='28' AND X5_CHAVE=SRA.RA_CATFUNC)      "
	cQry +="	                                    AS CATEGORIA_FUNC,                                                                                       "
	cQry +="       CASE                                                                                                                                      "
	cQry +="        WHEN RA_VIEMRAI='55' THEN 'JOVEN APRENDIZ'                                                                                               "
	cQry +="        ELSE                                                                                                                                     "
	cQry +="	   (SELECT DISTINCT nvl(SX5.X5_DESCRI,' ') FROM SX5"+CSUFIX+" SX5 WHERE SX5.D_E_L_E_T_ = ' '  AND SX5.X5_TABELA='25' AND X5_CHAVE=SRA.RA_VIEMRAI) END "
	cQry +="	                                    AS TIPO_DE_CONTRATACAO,                                                                                  "
	cQry +="       SUBSTR(SRA.RA_CC,1,4)	        AS CCUSTO_DIR,                                                                                           "
	cQry +="       nvl(CTTDIR.CTT_DESC01,' ')       AS DCCUSTODIR,                                                                                           "
	cQry +="       SUBSTR(SRA.RA_CC,1,6)	        AS CCUSTO_SETOR1,                                                                                        "
	cQry +="       nvl(CTTST1.CTT_DESC01,' ')       AS DCCUSTOSET1,                                                                                          "
	cQry +="       SRA.RA_CC	                    AS CCUSTO_SETOR3,                                                                                        "
	cQry +="       nvl(CTT.CTT_DESC01,' ')          AS DCCUSTOSET3,                                                                                          "
	cQry +="       SRA.RA_EMAIL                     AS EMAIL                                                                                                 "
	cQry +="                                                                                                                                                 "
	cQry +="FROM SRA"+CSUFIX+" SRA                                                                                                                   "                                                                                                                                 
	cQry +="LEFT JOIN CTT"+CSUFIX+" CTT ON CTT.D_E_L_E_T_ = ' '   AND CTT.CTT_CUSTO  = SRA.RA_CC                                                     "
	cQry +="LEFT JOIN CTT"+CSUFIX+" CTTDIR ON CTTDIR.D_E_L_E_T_ = ' '   AND TRIM(CTTDIR.CTT_CUSTO)  = TRIM(SUBSTR(SRA.RA_CC,1,4))                    "
	cQry +="LEFT JOIN CTT"+CSUFIX+" CTTST1 ON CTTST1.D_E_L_E_T_ = ' '   AND TRIM(CTTST1.CTT_CUSTO)  = TRIM(SUBSTR(SRA.RA_CC,1,6))                    "
	cQry +="LEFT JOIN CTT"+CSUFIX+" CTTST2 ON CTTST2.D_E_L_E_T_ = ' '   AND TRIM(CTTST2.CTT_CUSTO)  = TRIM(SUBSTR(SRA.RA_CC,1,8))                    "
	cQry +="LEFT JOIN SRJ"+CSUFIX+" SRJ ON SRJ.D_E_L_E_T_ = ' '   AND TRIM(SRJ.RJ_FUNCAO)  = TRIM(SRA.RA_CODFUNC)                                    "
	cQry +="LEFT JOIN SQ3"+CSUFIX+" SQ3 ON SQ3.D_E_L_E_T_ = ' '   AND TRIM(SQ3.Q3_CARGO)   = TRIM(SRA.RA_CODFUNC)                                    "
	cQry +="LEFT JOIN SQB"+CSUFIX+" SQB ON SQB.D_E_L_E_T_ = ' '   AND TRIM(SQB.QB_FILIAL)  = TRIM(SRA.RA_FILIAL) AND TRIM(SQB.QB_DEPTO)   = TRIM(SRA.RA_DEPTO)      "
	cQry +="LEFT JOIN SQ0"+CSUFIX+" SQ0 ON SQ0.D_E_L_E_T_ = ' '   AND TRIM(SQ0.Q0_GRUPO)   = TRIM(SQ3.Q3_GRUPO)                                      "
	cQry +="LEFT JOIN ZM0010 ZM0 ON ZM0.D_E_L_E_T_ = ' '   AND TRIM(ZM0.ZM0_CODFIL) = TRIM(SRA.RA_FILIAL) and trim(zm0_codigo)='"+alltrim(cemppro)+"'       "
	cQry +="LEFT JOIN C09"+CSUFIX+" C09 ON C09.D_E_L_E_T_ = ' '   AND TRIM(C09.C09_UF) = TRIM(ZM0.ZM0_ESTCOB)                                        "
	cQry +="WHERE SRA.D_E_L_E_T_ = ' '                                                                                                                       "
	cQry +="  AND (SRA.RA_DEMISSA = ' '  OR (SRA.RA_DEMISSA BETWEEN '"+dDtDigitIni+"' AND '"+dDtDigitFim+"' ))                                               "
	cQry +="  AND (SRA.RA_RESCRAI NOT IN('30','31'))     	                                                                                                     "

    //    cQry := changequery(cQry)
    TCQUERY cQry ALIAS "TRH1" NEW    
    TRH1->(DBGOTOP())   
    nTotReg := Contar("TRH1","!Eof()")
    nRecLido   := 0
    TRH1->(DBGOTOP())   
    WHILE TRH1->(!Eof())
       nRecLido ++
 	   cMsg := "Processando = '" +STRZERO(nRecLido,9,0)+"' De '"+STRZERO(nTotReg,9,0)+"'"
        FWMonitorMsg(cMsg)
        MsProcTxt(cMsg)	
        ProcessMessage()

   	    For Nx := 1 to len(aEmpresas)
		    if ALLTRIM(aempresas[Nx][1]) == ALLTRIM(cemppro)
			   npos := Nx
			endif
		next Nx

	    cMsg := CEMPPRO+"-"+ALLTRIM(aEmpresas[npos][2])
        cMsg += ";"
		cMsg += ALLTRIM(TRH1->REGIONAL_FUNCIONAL)
		cMsg += ";"
	    cMsg += TRH1->COD_FILIAL     
		cMsg += ";" 
	    cMsg += ALLTRIM(TRH1->NOME_DA_UNIDADE)
		cMsg += ";"
	    cMsg += ALLTRIM(TRH1->UF_UNIDADE)          
		cMsg += ";"
	    cMsg += ALLTRIM(TRH1->RAZAO_SOCIAL)       
		cMsg += ";"
	    cMsg += TRH1->CENTRO_CUSTO        
		cMsg += ";"
	    cMsg += ALLTRIM(TRH1->DESCR_CENTRO_CUSTO)  
		cMsg += ";"
	    cMsg += TRH1->MATRICULA
		cMsg += ";"
	    cMsg += Alltrim(Transform(TRH1->CPF, "@R 999.999.999-99"))            
		cMsg += ";"
	    cMsg += ALLTRIM(TRH1->NOME_FUNCIONARIO)    
		cMsg += ";"
	    cMsg += TRH1->COD_FUNCAO          
		cMsg += ";"
	    cMsg += ALLTRIM(TRH1->DESCRICAO_DA_FUNCAO) 
		cMsg += ";"
	    cMsg += TRH1->GRUPO_CARGOS       
		cMsg += ";"
	    cMsg += ALLTRIM(TRH1->DESCR_GRUPO_CARGOS)
		cMsg += ";"
	    cMsg += TRH1->SEXO   
		cMsg += ";"
	    cMsg += DTOC(STOD(TRH1->NASCIMENTO))          
		cMsg += ";"
	    cMsg += ALLTRIM(TRH1->SITUACAO)    
		cMsg += ";"
        cMsg += ALLTRIM(TRH1->SITUACAO_DESCR)  
		cMsg += ";"
	    cMsg += DTOC(STOD(TRH1->ADMISSAO))            
		cMsg += ";"
	    cMsg += DTOC(STOD(TRH1->DEMISSAO))            
		cMsg += ";"
	    cMsg += TRH1->CAT_FUNC  
		cMsg += ";"
	    cMsg += TRH1->CATEGORIA_FUNC
		cMsg += ";"
	    cMsg += ALLTRIM(TRH1->TIPO_DE_CONTRATACAO) 
		cMsg += ";"
	    cMsg += TRH1->CCUSTO_DIR 
		cMsg += ";"
	    cMsg += ALLTRIM(TRH1->DCCUSTODIR)
		cMsg += ";"
	    cMsg += TRH1->CCUSTO_SETOR1
		cMsg += ";"
	    cMsg += ALLTRIM(TRH1->DCCUSTOSET1) 
		cMsg += ";"
	    cMsg += TRH1->CCUSTO_SETOR3 
		cMsg += ";"
	    cMsg += ALLTRIM(TRH1->DCCUSTOSET3)   
		cMsg += ";"
        cMsg += ALLTRIM(TRH1->EMAIL)               
		cMsg += ";"

     	cMsg += CRLF
  	    FWrite(nHandle4,cMsg,Len(cMsg))    
	
	    TRH1->(DBSKIP())
   ENDDO
   TRH1->(DBCLOSEAREA())

   //RESET ENVIRONMENT
  
Return

User Function F3XX8GRP()

Local aArea	:= fwGetArea()
Local aCpos     := {}       //Array com os dados
Local lRet      := .T. 		//Array do retorno da opcao selecionada
Local oDlgF3                  //Objeto Janela
Local oLbx                  //Objeto List box
Local cTitulo   := "Empresas"
//Local cNoCpos   := ""    
//Local cDescr    := "Empresas"
Local aRet		:= {}
	    
//旼컴컴컴컴컴컴컴컴컴컴?
//?rocurar campo no SX3?
//읕컴컴컴컴컴컴컴컴컴컴?
DbSelectArea("XX8")
XX8->(dbSetOrder(1))
XX8->(dbGoTop())

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴?
//?arrega o vetor com os campos da tabela selecionada?
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴?

While !XX8->(Eof())
   
   If XX8_TIPO == "0"
	   aAdd( aCpos, { XX8->XX8_CODIGO, XX8->XX8_DESCRI } )
   EndIf
   
   XX8->(DbSkip())
   
Enddo

If Len( aCpos ) > 0

	DEFINE MSDIALOG oDlgf3 TITLE cTitulo FROM 0,0 TO 240,500 PIXEL
	
	   @ 10,10 LISTBOX oLbx FIELDS HEADER "Empresas", "Descricao" SIZE 230,95 OF oDlgf3 PIXEL	 
	
	   oLbx:SetArray( aCpos )
	   oLbx:bLine     := {|| {aCpos[oLbx:nAt,1], aCpos[oLbx:nAt,2]}}
	   oLbx:bLDblClick := {|| {oDlgF3:End(), aRet := {oLbx:aArray[oLbx:nAt,1],oLbx:aArray[oLbx:nAt,2]}}} 	                   

	DEFINE SBUTTON FROM 107,213 TYPE 1 ACTION (oDlgF3:End(), aRet := {oLbx:aArray[oLbx:nAt,1],oLbx:aArray[oLbx:nAt,2]})  ENABLE OF oDlgF3
	ACTIVATE MSDIALOG oDlgF3 CENTER
		
EndIf	

cRetxx8 := AllTrim(iIF(Len(aRet) > 0, aRet[1],""))

If Empty(cRetxx8)
	lRet := .F.
EndIf

fwRestArea(aArea)

Return lRet
/* A atualizacao de SXB somente deve ser feita via configurador a parti da release 2210 BD
User Function FSAtuSXB()
Local aEstrut   := {}
Local aSXB      := {}
Local cAlias    := ""
Local cMsg      := ""
Local lTodosNao := .F.
Local lTodosSim := .T.
Local nI        := 0
Local nJ        := 0
Local nOpcA     := 0

aEstrut := { "XB_ALIAS",  "XB_TIPO"   , "XB_SEQ"    , "XB_COLUNA" , ;
             "XB_DESCRI", "XB_DESCSPA", "XB_DESCENG", "XB_CONTEM" }

//
// Consulta GRUPO DE EMPRESAS (XX8GRP)
//
aAdd( aSXB, { ;
	'XX8GRP'						, ; //XB_ALIAS
	'1'						, ; //XB_TIPO
	'01'						, ; //XB_SEQ
	'RE'						, ; //XB_COLUNA
	'Empresas            '				, ; //XB_DESCRI
	'Empresas            '				, ; //XB_DESCSPA
	'Companies           '				, ; //XB_DESCENG
	'XX8'						} ) //XB_CONTEM

aAdd( aSXB, { ;
	'XX8GRP'						, ; //XB_ALIAS
	'2'						, ; //XB_TIPO
	'01'						, ; //XB_SEQ
	'01'						, ; //XB_COLUNA
	' '				, ; //XB_DESCRI
	' '				, ; //XB_DESCSPA
	' '				, ; //XB_DESCENG
	'U_F3XX8GRP()'						} ) //XB_CONTEM

aAdd( aSXB, { ;
	'XX8GRP'						, ; //XB_ALIAS
	'5'						, ; //XB_TIPO
	'01'						, ; //XB_SEQ
	' '						, ; //XB_COLUNA
	' '				, ; //XB_DESCRI
	' '				, ; //XB_DESCSPA
	' '				, ; //XB_DESCENG
	'cRetxx8'				} ) //XB_CONTEM


//
// Atualizando dicion?io
//

dbSelectArea( "SXB" )
dbSetOrder( 1 )

For nI := 1 To Len( aSXB )

	If !Empty( aSXB[nI][1] )

		If !SXB->( dbSeek( PadR( aSXB[nI][1], Len( SXB->XB_ALIAS ) ) + aSXB[nI][2] + aSXB[nI][3] + aSXB[nI][4] ) )

			If !( aSXB[nI][1] $ cAlias )
				cAlias += aSXB[nI][1] + "/"
			EndIf

			RecLock( "SXB", .T. )

			For nJ := 1 To Len( aSXB[nI] )
				If !Empty( FieldName( FieldPos( aEstrut[nJ] ) ) )
					FieldPut( FieldPos( aEstrut[nJ] ), aSXB[nI][nJ] )
				EndIf
			Next nJ

			dbCommit()
			MsUnLock()

		Else

			//
			// Verifica todos os campos
			//
			For nJ := 1 To Len( aSXB[nI] )

				//
				// Se o campo estiver diferente da estrutura
				//
				If aEstrut[nJ] == SXB->( FieldName( nJ ) ) .AND. ;
					!StrTran( AllToChar( SXB->( FieldGet( nJ ) ) ), " ", "" ) == ;
					 StrTran( AllToChar( aSXB[nI][nJ]            ), " ", "" )
						RecLock( "SXB", .F. )
						FieldPut( FieldPos( aEstrut[nJ] ), aSXB[nI][nJ] )
						dbCommit()
						MsUnLock()

				EndIf

			Next

		EndIf

	EndIf

Next nI

Return */
