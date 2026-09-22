#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"
 
/* 
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍkÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³SUPExtratorºAutor  ³Jamer Nunes Pedroso º Data ³  20/10/14   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Gera a informação a partir do cadastro de extratores e      º±±
±±º          ³ e importadores                                              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function SupExt01(pcCodExt, cpEmp, cpFil, lJob)

Local aArea := FWGetArea()

Public  cNotKey    := "SE5|SEF"  
Private lexecauto := .T.
Private lShowHelp := .F.
Private lMsHelpAuto := .t. // se .t. direciona as mensagens     de help para o arq. de log
Private lMsErroAuto := .f.
Private nSeqErr     := 0
                       
Default cpEmp        := '99'
Default cpFil        := '01'
Default lJob         := .F.

Private aProcEmp := {}
Private cEmpZVJ 

if lJob
   RpcClearEnv()
   RpcSetType( 3 )
   If !RpcSetEnv( cpEmp, cpFil )
      ConOut( '[ SupExt01 ][ '+ Dtoc( Date() ) +' ][ '+ Time() +' ]-Nao Foi Possivel Iniciar o Ambiente na Empresa [ '+ cEmp +' ]/[ '+ cFil +' ]... Processo Cancelado Pelo Sistema!' )
      RpcClearEnv()
      Return(.F.)
   EndIf
Endif

dbSelectArea("ZVJ")
dbSetOrder(1)
If !dbSeek(xFilial("ZVJ")+pcCodExt)

   If lJob
      ConOut( "Nao existe o codigo de extracao: "+pcCodExt)
   Else
      MsgStop( "Nao existe o codigo de extracao: "+pcCodExt)
   EndIf

EndIf   

//chkfile(Alltrim(ZVJ->ZVJ_ORIGEM))
//chkfile(Alltrim(ZVJ->ZVJ_DESTINO))

cEmpZVJ := ZVJ->ZVJ_EMPORI 

if Empty(ZVJ->ZVJ_EMPORI) 

   dbSelectArea("SM0")     
   nRecSM0 := SM0->(Recno())
   dbGotop()
    
   if ZVJ->ZVJ_TPORIG == '5'
      dbEval( {|| ProcSupExt(SM0->M0_CODIGO,pcCodExt) },,{|| !SM0->(Eof()) },,,) 
   else 
      dbEval( {|| ProcEmp(SM0->M0_CODIGO,pcCodExt) },,{|| !SM0->(Eof()) },,,)                       
   Endif   
   
   dbGoto(nRecSM0)                                      

Else 

   if ZVJ->ZVJ_TPORIG == '5'    
      ProcTxt(ZVJ->ZVJ_EMPORI,pcCodExt)
   else 
      ProcEmp(ZVJ->ZVJ_EMPORI,pcCodExt)
   endif

Endif                

if lJob
   RpcClearEnv()
Endif                                                                  

FWRestArea(aArea)

Private lexecauto := .F.
Private lShowHelp := .T.
Private lMsHelpAuto := .F. // se .t. direciona as mensagens     de help para o arq. de log
Private lMsErroAuto := .T.
Private nSeqErr     := 0

Return(.T.)
          
/*
======================================================
Autor: Jamer Nunes Pedroso 
Data:	10.2014
------------------------------------------------------
Descricao:
Rotina de Processamento de empresa via tabela
======================================================
*/
Static Function ProcEmp(cpEmp, pcCodExt)

Local aArea := FWGetArea()
Local aCampos := {} 
Local cAliasOrigem, cAliasDestino
Local lRet := .T.
Local cTcSql             
Local cCRLF := Chr(10)+Chr(13)


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
DbEval ( {|| aAdd( aCampos , { ZVK->ZVK_SEQ, ZVK->ZVK_CPOORI, ZVK->ZVK_CPODES, ZVK->ZVK_TIPCPO, ZVK->ZVK_RELACA, ZVK->ZVK_VALIDA, ZVK->ZVK_PROVLD } ), Reclock("ZVK",.F.), ZVK->ZVK_VLDPRO := Posicione("SX3", 2, aCampos[nDbeval++], "X3_VALID"), ZVK->(MsUnlock()) },,{|| ZVK->ZVK_CODEXT == ZVJ->ZVJ_CODIGO },,,) // varrendo dados

cAliasOrigem  := OpenOEmp(alltrim(ZVJ->ZVJ_ORIGEM),cpEmp)

cAliasDestino := OpenOEmp(alltrim(ZVJ->ZVJ_DESTINO),ZVJ->ZVJ_EMPDES)

if Empty(cAliasOrigem)
   FWRestArea(aArea) 
   ConOut("Origem inexistente..."+cAliasOrigem)
   Return(.T.) 
Endif 

//CRLF := Chr(10)+Chr(13)
                             
//cSqlExec := " TRUNCATE TABLE " +RetSqlName( Alltrim(ZVJ->ZVJ_DESTINO) )+ CRLF

//cTcSql := TCSQLExec( cSqlExec )

//ConOut( "Retorno da remoção: "+ Strzero(cTcSql,10)+ " - "+"delete "+RetSqlName( Alltrim(ZVJ->ZVJ_DESTINO) ) )

dbSelectArea( cAliasOrigem )
dbSetOrder(ZVJ->ZVJ_INDORI)
/* Limpando todos os filtros */
RetIndex(cAliasOrigem)
dbSelectArea(cAliasOrigem)
dbClearFilter() 

If !Empty(ZVJ->ZVJ_FILORI)
   cFiltroIdx := ZVJ->ZVJ_FILORI
   bFiltraIdx := {||&(cFiltroIdx)}
   (cAliasOrigem)->(dbsetfilter(bfiltraIdx, cfiltroidx))	
   (cAliasOrigem)->(DbGoTop())
Endif
                                 
                                 
ConOut( "Iniciando extracao: "+pcCodExt+"|"+cpEmp+"|"+cAliasOrigem+"|"+ZVJ->ZVJ_EMPDES+"|"+cAliasDestino)

RegToMemory(ZVJ->ZVJ_DESTIN,.F.,.F.)

// Varrendo dados de origem 
DbEval ( {|| Copia_Registro( cAliasOrigem, ZVJ->ZVJ_INDORI, ZVJ->ZVJ_CHVPSQ, cAliasDestino, ZVJ->ZVJ_INDDES, aCampos, @oProcesso, aCpodata ) },,{|| !(cAliasOrigem)->(Eof()) },,,) 

ConOut( "Finalizando extracao: "+pcCodExt+"|"+cpEmp+"|"+cAliasOrigem+"|"+ZVJ->ZVJ_EMPDES+"|"+cAliasDestino)


(cAliasOrigem)->(dbCloseArea()) 

(cAliasDestino)->(dbCloseArea()) 

RecLock("ZVJ",.F.)     
ZVJ->ZVJ_EMPORI := cEmpZVJ
ZVJ->(MsUnlock())

FWRestArea(aArea)

Return(.T.)
/*
======================================================
Autor: Jamer Nunes Pedroso 
Data:	10.2014
------------------------------------------------------
Descricao:
Rotina de copia Copia registro
======================================================
*/
Static Function Copia_Registro( cpAliasOrigem, cpIndiceOrigem, cpChave, cpAliasDestino, cpIndiceDestino, aInfo, oProc, aCpodata )
Local oInfo := DataArray():New()
oInfo:aInfo := aClone(aInfo)

CpRegFil( cpAliasOrigem, cpIndiceOrigem, cpChave, cpAliasDestino, cpIndiceDestino, aInfo, @oProc, aCpoData )

aInfo := oInfo:aInfo

FreeObj(oInfo)

Return(.T.)

/*
======================================================
Autor: Jamer Nunes Pedroso 
Data:	10.2014
------------------------------------------------------
Descricao:
Rotina de copia Copia registro
======================================================
*/
Static Function CpRegFil(cpAlias01,cpIndice01,cpChave, cpAlias02,cpIndice02,  aInfo, oProc, aCpodata )

Local lRet:= .T. , nCampos,  aArea := FWGetArea() 
Local aValidSx3 := {}             
Local bError  := ErrorBlock({|o| ,U_VerVal(o),.T.} )

if nGrvAll == 0 
   oAllDados := DataArray():New()
Endif
nGrvAll++
                       
   // { ZVK->ZVK_SEQ, ZVK->ZVK_CPOORI, ZVK->ZVK_CPODES }
                                       
   
	For nCampos := 1 TO Len(aInfo)                    

       if ( aInfo[nCampos,4] == "6" ) 
                                      // Campo carregado por macro 
                                      // #Consistência de dados
                                      // #Validação dos campos será colocada aqui
             if ( nPos := AScan( aCpodata,{|x| Alltrim(x) == Alltrim(aInfo[nCampos,3])},,) ) = 0 // #Consistência de estrutura de arquivo 
                aInfo[nCampos,2] := iif( ( aInfo[nCampos,2] <> aInfo[nCampos,3] ), aInfo[nCampos,2], "CriaVar('"+Alltrim(aInfo[nCampos,3])+"',.T.)" )
             else           
                                          
                // Campos fixo ;rdmake ou literal 
                if ( aInfo[nCampos,2] <> aInfo[nCampos,3] )
                   M->&(Alltrim(aInfo[nCampos,3])) := aDados[nPos]          
                   aDados[nPos] := &(aInfo[nCampos,2])
                endif
                
                if Valtype((cpAlias02)->&(aInfo[nCampos,3]))     = "D"
                
                   If Len( aDados[nPos] )<8
                      aDados[nPos] := Dtos(IIf(At("/",aDados[nPos])>0,CtoD(aDados[nPos]),StoD(aDados[nPos])))
                   endif
                
                   aInfo[nCampos,2] := IIf(At("/",aDados[nPos])>0,"CtoD","StoD")+"(aDados["+StrZero(nPos,4)+"])" // #Consistência campo data 
                elseif Valtype((cpAlias02)->&(aInfo[nCampos,3])) = "N"
                 
                   aInfo[nCampos,2] := "NoRound( Val(Alltrim(aDados["+StrZero(nPos,4)+"])),2)" // #Consistência campo numérico
                   aDados[nPos] := if( empty(aDados[nPos]), 0, aDados[nPos] )
                elseif Valtype((cpAlias02)->&(aInfo[nCampos,3])) = "L"
                
                   aInfo[nCampos,2] := "aDados["+StrZero(nPos,4)+"]"
                
                   if aDados[nPos] = "F" .or. aDados[nPos] = ".F."  
                      aDados[nPos] := .F.
                   elseif aDados[nPos] = "T" .or. aDados[nPos] = ".T."
                      aDados[nPos] := .T. 
                   else
                      aDados[nPos] := .F. 
                   endif     
                else                                                         
             
                   aInfo[nCampos,2] := "aDados["+StrZero(nPos,4)+"]"
                   aDados[nPos] := if( empty(aDados[nPos]), Replicate(" ", TamSx3(Alltrim(aInfo[nCampos,3]))[1] ),;
                                                            Padr( aDados[nPos], TamSx3(Alltrim(aInfo[nCampos,3]))[1] ) )
                endif   
                
             endif
          
                                     
          if aInfo[nCampos,7] == "S"  .and. !Empty(aInfo[nCampos,8]) // Validação Protheus
                                                                
             aAdd( aValidSx3, { aInfo[nCampos,3], aInfo[nCampos,8], .T., "1", aInfo[nCampos,9] } ) 
          endif                   
          
          if !Empty(aInfo[nCampos,6]) // Validação especifica 
             aAdd( aValidSx3, { aInfo[nCampos,3], aInfo[nCampos,6], .T., "2", aInfo[nCampos,9] } )          
          endif                                    
          
          if !Empty(aInfo[nCampos,5]) // Validação de dependencia 
             aAdd( aValidSx3, { aInfo[nCampos,3], aInfo[nCampos,5], .T., "3", aInfo[nCampos,9] } )          
          endif   
         
       Endif	     
	   
    Next 1

   

    For nCampos := 1 TO Len(aInfo)                    
       
       if ( aInfo[nCampos,4] == "6" )
             
          M->&(Alltrim(aInfo[nCampos,3])) := (cpAlias01)->&(aInfo[nCampos,2])
          
       Elseif ( aInfo[nCampos,4] <> "0" ) // Outros modelos de carga 
       
         If (cpAlias02)->(FieldPos(aInfo[nCampos,3])) > 0 // Campo cadastrado encontrado no dicionário 
             M->&(Alltrim(aInfo[nCampos,3])) := (cpAlias01)->&(aInfo[nCampos,2])     
        endif   
          
	
	   Endif	     
    
    Next 1

    
    aadd( oAllDados:aAlldados, { aDados, aValidData(aValidSx3), nRegCount} )
    
    FWRestArea(aArea)
      
    oFile:ft_fSkip()
     
    if Mod(nRegCount,250) = 0  .or. ( oFile:ft_fEof() ) .and. ( nRegCount = (nRegTotal) )
       Begin Transaction 
       
       oProc:IncRegua1("Gravando:"+Alltrim(ZVJ->ZVJ_DESTINO)+" - "+ StrZero(nRegCount,10)+"/"+StrZero(nRegTotal,10))
       
       aEval( oAllDados:aAlldados, {|x| GrvAllDados(cpAlias01,cpIndice01,cpChave, cpAlias02,cpIndice02,  aInfo, x[1], x[2], x[3] ) } )
       nGrvAll := 0
       FreeObj(oAllDados)
       __MPAPPSRVINI()
             
       End Transaction  
    endif
     	
    
    
Return(.T.) 

/*====================================================================================================================*/
Static Function GrvAllDados(cpAlias01,cpIndice01,cpChave, cpAlias02,cpIndice02,  aInfo, apDados, apValid, nReg )

Local aDados    :=  aPDados
Local aDadosVld :=  aPValid  
Local cVerify := &(cpChave) 
Local lNewRec := .T.   
Local aDadosVld
Local aLVld   
Local lRet := .T.
Local aArea := FWGetArea()
Local nCampos	:= 0
Local bError  := ErrorBlock({|o| ,U_VerVal(o),.T.} )
//Local bError  := ErrorBlock({|o| ,U_LOGMIG01(aLLTRIM(cpAlias02),StrZero(nSeqErr++,5),cDirArq,"Erro interno na gravação:"+o:DESCRIPTION,"018",cDataInicio,cHoraInicio,nRegCount,nTotErro++),.T.} )

   dbSelectArea(cpAlias02)     
  	dbSetOrder(cpIndice02)
	dbGotop()               

    aLVld := aGrvValid(aDadosVld,nReg)    
	   
	cVerify := &(cpChave)
	   
//    if (cpAlias02)->(dbSeek(cVerify,.F.)) .And. !(Upper(Alltrim(ZVJ->ZVJ_DESTINO)) $ cNotKey) // Edsonho #Consistência de linhas com chave duplicada no arquivo
    if Upper(Alltrim(ZVJ->ZVJ_DESTINO)) <> "SE5"
       if (cpAlias02)->(dbSeek(cVerify,.F.))
          	//lNewRec := .F. // Substitui dados                                 
   	          cConteud := "Tabela:["+Alltrim(ZVJ->ZVJ_DESTINO)+"] - Chave:["+(cpAlias02)->(IndexKey())+"] - Chave duplicada:["+cVerify+"] - Linha do arquivo:["+Strzero(nRegCount,12)+"]"     
  	          U_LOGMIG01(ALLTRIM(ZVJ->ZVJ_DESTINO),StrZero(nSeqErr++,5),cDirArq,cConteud,"002",cDataInicio,cHoraInicio,nReg,nTotErro++)
              Return(.T.)
       Else 
	       dbGotop()
	   Endif                  
	Else 
	   dbGotop()
	Endif                  

	lValiddata := aLVLd[1]

	if !lValiddata // Controle de Validação e Rejeição 
	   if aLVLd[2] // Rejeita = S  
          Return(.T.)  
       endif
    endif                    
	
    dbSelectArea(cpAlias02)
	RecLock(cpAlias02, lNewRec)
      
	For nCampos := 1 TO Len(aInfo)                    
       
       if ( aInfo[nCampos,4] == "6" )
             
          (cpAlias02)->&(Alltrim(aInfo[nCampos,3])) := &(aInfo[nCampos,2])
          //M->&(Alltrim(aInfo[nCampos,3])) := (cpAlias01)->&(aInfo[nCampos,2])
          
       Elseif ( aInfo[nCampos,4] <> "0" ) // Outros modelos de carga 
          
          If (cpAlias02)->(FieldPos(aInfo[nCampos,3])) > 0 // Campo cadastrado encontrado no dicionário 
             (cpAlias02)->&(Alltrim(aInfo[nCampos,3])) := (cpAlias01)->&(aInfo[nCampos,2])
             //M->&(Alltrim(aInfo[nCampos,3])) := (cpAlias01)->&(aInfo[nCampos,2])     
          endif   
          
	
	   Endif	     
    
    Next 1
    
    //endif
    
    // Local da Chamado do Ponto de entrada
    
    (cpAlias02)->(MsUnlock())

FWRestArea(aArea)
Return(lRet)

/*
======================================================
Autor: Jamer Nunes Pedroso 
Data:	10.2014
------------------------------------------------------
Descricao:
Rotina de abertura da tabela
======================================================
*/
Static Function OpenOEmp(cpAlias,cpEmp)

Local aArea := FWGetArea()
Local aAreaSave := (cpAlias)->( FWGetArea() )
Local cSvFilAnt := cFilAnt //Salva a Filial Anterior
Local cSvEmpAnt := cEmpAnt //Salva a Empresa Anterior
Local cSvArqTab := cArqTab //Salva os arquivos de
//trabalho
Local cModo //Modo de acesso do arquivo aberto
//"E" ou "C"
Local cNewAls := GetNextAlias() //Obtem novo Alias
Local cRet    := cNewAls


IF !EmpOpenFile(cNewAls,cpAlias,1,.T.,cpEmp,@cModo)
//
   cRet := ""
EndIF


//Restaura os Dados de Entrada ( Ambiente )
cFilAnt := cSvFilAnt
cEmpAnt := cSvEmpAnt
cArqTab := cSvArqTab

//Restaura os ponteiros das Tabelas
FWRestArea( aAreaSave )
FWRestArea( aArea )

Return( cRet )

/*
======================================================
Autor: Jamer Nunes Pedroso/Pedro 
Data:	03.2017
------------------------------------------------------
Descricao:
Rotina de abertura da tabela
======================================================
*/
Static Function ProcTXT(cpEmp, pcCodExt)

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
Local ARMetodo2 := {"P03","P04","CT8","CTG","CT5","CTO","TMK"}
Local lRMetodo2 := .F.
Local nCFalta
Local nCFiles := 0

Private nRegCount := 0 
Private nTotErro  := 0
Private aDados  
Private aErro := {}
Private cDirArq :=Alltrim(ZVJ->ZVJ_DIRIMP)
Private aCpodata 
Private aDados

Private aFiles := {}
Private cHoraInicio := Time()
Private cDataInicio := Date()
   

If Right(Alltrim(Upper(cDirArq)),1) == "\" .and. !(Right(Alltrim(cDirArq),1)$".TXT|.CSV" )

   Aeval( Directory(cDirArq+"*.txt"), {|x|x[1] := cDirArq+x[1] ,aadd(aFiles, x ) } )
   Aeval( Directory(cDirArq+"*.csv"), {|x|x[1] := cDirArq+x[1] ,aadd(aFiles, x ) } )

Else 
   aFiles := {{cDirArq}}
Endif 

If Len(aFiles) == 0

   MsgStop("Não há arquivos n diretório especificado...")
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
//DbEval ( {|| aAdd( aCampos , { ZVK->ZVK_SEQ, ZVK->ZVK_CPOORI, ZVK->ZVK_CPODES, ZVK->ZVK_TIPCPO, ZVK_RELACA, ZVK_VALIDA } ), Reclock("ZVK",.F.), ZVK->ZVK_VLDPRO := Posicione("SX3", 2, aCampos[++nDbeval,3], "X3_VALID"), ZVK->(MsUnlock()) },,{|| ZVK->ZVK_CODEXT == ZVJ->ZVJ_CODIGO },,,) // varrendo dados
DbEval ( {|| aAdd( aCampos , 	{ ZVK->ZVK_SEQ, ZVK->ZVK_CPOORI, ZVK->ZVK_CPODES, ZVK->ZVK_TIPCPO, ZVK->ZVK_RELACA, ZVK->ZVK_VALIDA, ZVK->ZVK_PROVLD, AtuVld(ZVK->ZVK_CPODES), ZVK->ZVK_REJEIT } ) },,{|| ZVK->ZVK_CODEXT == ZVJ->ZVJ_CODIGO },,,) // varrendo dados PEDRO SAMPAIO

cAliasDestino := OpenOEmp(alltrim(ZVJ->ZVJ_DESTINO),ZVJ->ZVJ_EMPDES)
cAliasOrigem  := cAliasDestino // Compatibilidade

//CRLF := Chr(10)+Chr(13)

//cSqlExec := " TRUNCATE TABLE " +RetSqlName( Alltrim(ZVJ->ZVJ_DESTINO) )+ " ;" + CRLF

//cTcSql := TCSQLExec( cSqlExec )

//ConOut( "Retorno da remoção: "+ Strzero(cTcSql,10)+ " - "+"delete "+RetSqlName( Alltrim(ZVJ->ZVJ_DESTINO) ) )

ConOut( "Iniciando importação: "+pcCodExt+"|"+cpEmp+"|"+cAliasOrigem+"|"+ZVJ->ZVJ_EMPDES+"|"+cAliasDestino)



// Início do For Arquivo
For nCFiles := 1 to Len(aFiles)

   cHoraInicio := Time()
   cDataInicio := Date()
   lPrim := .T.

//IncProc("Lendo arquivo texto...")
   
   cDirArq := aFiles[nCFiles,1]
   
   lRMetodo2 := ( Ascan( ARMetodo2, Alltrim(ZVJ->ZVJ_DESTINO) ) > 0 )

	if lRMetodo2

		nHandle := FT_FUSE(cDirArq)

		if nHandle = -1

			return
		endif
   
		FT_FGoTop()

	else

		oFile := FWFileReader():New(cDirArq)

		If !oFile:Open()
			ConOut( "Arquivo nao pode ser aberto: " + cDirArq)

			Return
		Endif
   
		oFile:setBufferSize(4096)

	endif

	cWhile := Iif( lRMetodo2 , "!FT_FEOF()",  "(!oFile:Eof()) .and. ( ofile:getBytesRead() < ofile:getFileSize() )" )
   
   
	While &(cWhile) // Executando while condicional

		cLinha := iif ( lRMetodo2, Replace(FT_FReadLn(),'"',"") ,Replace(oFile:GetLine(.F.),'"',"") )

		If lPrim
			aCpoData := Separa(cLinha,iif( at(CHR(165),cLinha)>0,CHR(165),iif( at(CHR(167),cLinha)>0,chr(167),";")),.T.)
			lPrim := .F.; lEstok := .T.
			cIndDes := ""
			aPosKeys := {}
			(cAliasDestino)->(dbSetOrder(ZVJ->ZVJ_INDDES))
			aUniq := Separa((cAliasDestino)->(IndexKey()),"+",.T.)
    
			For nCpCount := 1 to Len(aCpodata) // #Consistência estrutura do arquivo enviado
 
				aCpodata[nCpCount] := replace(replace(aCpodata[nCpCount],char(13),""), chr(10),"")
    
				if ( nPos := AScan( ACampos,{|x| Alltrim(x[3]) == Alltrim(ACpoData[nCpCount])},,) ) = 0
					cConteud := "Tabela:["+Alltrim(ZVJ->ZVJ_DESTINO)+"] - Campo Inexistente na tabela:["+Alltrim(aCpoData[nCpCount])+"]- Linha do arquivo:["+Strzero(nRegCount,12)+"]"
					U_LOGMIG01(ALLTRIM(ZVJ->ZVJ_DESTINO),StrZero(nSeqErr++,5),cDirArq,cConteud,"004",cDataInicio,cHoraInicio,nRegCount,nTotErro++)
					lEstOk := .F.
				Endif
       
			Next 1
    
			For nCpCount := 1 to Len(aCampos) // #Consistência estrutura do arquivo enviado
    
				if ( nPos := AScan( ACpoData,{|x| Alltrim(x) == Alltrim(aCampos[nCpCount,3])},,) ) = 0
					cConteud := "Tabela:["+Alltrim(ZVJ->ZVJ_DESTINO)+"] - Campo Inexistente no arquivo:["+Alltrim(aCampos[nCpCount,3])+"]- Linha do arquivo:["+Strzero(nRegCount,12)+"]"
					U_LOGMIG01(ALLTRIM(ZVJ->ZVJ_DESTINO),StrZero(nSeqErr++,5),cDirArq,cConteud,"004",cDataInicio,cHoraInicio,nRegCount,nTotErro++)
					lEstOk := .F.
				Endif
       
			Next 1

  
			/* Montando chave de indice para pesquisa */
			For nUniq := 1 to  Len(aUniq) // #Consistência de campos indices
  
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
				Return(.F.)
			Endif
 
			if lRMetodo2
				FT_FSKIP()
			endif

			Loop
		Else
  
			aDados := Separa(cLinha,iif( at(CHR(165),cLinha)>0,CHR(165),If(at(CHR(167),cLinha)>0,chr(167),";")),.T.)
  
			if ( nFfalta := ( Len(aCpoData)-len(aDados) ) ) > 0 // Campos a menos nas linhas de dados
  
				For nCFalta := 1 to nFfalta
     
					aadd( aDados, " " )
				Next 1
     
			endif
                                
  //cprod := &("aDados["+StrZero(2,4)+"]")
  
			for nUniq := 1 to Len(aPosKeys) // Campos sem dados são inicializados no padrão protheus para evitar pesquisas incorretas

				If Empty( &( "aDados["+StrZero(nUniq,4)+"]" ) )
					&("aDados["+StrZero(nUniq,4)+"]") = Criavar(Alltrim(aUniq[nUNiq]),.F.)
				endif

			Next 1

			nRegCount++
			
           RegToMemory(ZVJ->ZVJ_DESTIN,.F.,.F.)
         

			Copia_Registro( cAliasOrigem, ZVJ->ZVJ_INDORI, cIndDes, cAliasDestino, ZVJ->ZVJ_INDDES, aCampos )
  
  
			if lRMetodo2
				FT_FSKIP()
			endif

  
		Endif

	Enddo

	If lRMetodo2

		FT_FUSE()
	else

		oFile:Close()
	endif

	U_LOGMIG01(ALLTRIM(ZVJ->ZVJ_DESTINO),StrZero(nSeqErr++,5),cDirArq,"Finalização - Tabela - "+ZVJ->ZVJ_DESTINO,"000",cDataInicio,cHoraInicio,nRegCount,nTotErro++)


// Final do For Arquivos 
Next 1

ConOut( "Finalizando importação: "+pcCodExt+"|"+cpEmp+"|"+cAliasOrigem+"|"+ZVJ->ZVJ_EMPDES+"|"+cAliasDestino)

(cAliasDestino)->(dbCloseArea())

RecLock("ZVJ",.F.)
ZVJ->ZVJ_EMPORI := cEmpZVJ
ZVJ->(MsUnlock())

FWRestArea(aArea)

Return(.T.)

/*
======================================================
Autor: Jamer Nunes Pedroso/Pedro 
Data:	04.2017
------------------------------------------------------
Descricao:
Rotina que efetua validação dos campos da importação
======================================================
*/
Static Function aValidData(aValid)             
                      
Local aArea := FWGetArea()                                                                                 
Local cValid  := ""
Local bError  := ErrorBlock({|o| ,U_LOGMIG01(aLLTRIM(ZVJ->ZVJ_DESTINO),StrZero(nSeqErr++,5),cDirArq,"Validação:"+Alltrim(cValid)+" - Erro interno na validação:"+o:DESCRIPTION,"018",cDataInicio,cHoraInicio,nRegCount,nTotErro++),.T.} )
//Local bError  := ErrorBlock({|o| ,U_VerVal(o),.T.} )
Local nVCount := 0                   

Private lHelp := .F.
                                 
Private lJOb := .T.
Private nOpc := 4, nOpcx := 4

For nVCount := 1 to Len(aValid)

   FWRestArea(aArea)

   if aValid[nVCount,4]$"12"
    
      cValid    :=  Upper(aValid[nVCount,2])

      if At("EXISTCPO",CVALID) >0 
         cValid    := Replace(cValid, "EXISTCPO(", "U_EXISTCPO('"+&("M->"+ALLTRIM(aValid[nVCount,1]) )+"'," )
      ENDIF
      cValid    := Replace(cValid, "NAOVAZIO()", "!Empty(M->"+aLLTRIM(aValid[nVCount,1])+")" )
      cValid    := Replace(cValid, "VAZIO()", "Empty(M->"+aLLTRIM(aValid[nVCount,1])+")" )
      cValid    := Replace(cValid, "IE(M->", "U_IE(M->" )
      cValid    := Replace(cValid, "EXISTCHAV(", "U_EXISTCHAV(" )
      cValid    := Replace(cValid, "PERTENCE(",  "U_PERTENCE(M->"+aLLTRIM(aValid[nVCount,1])+"," ) 
      cValid    := Replace(cValid, "FREEFORUSE(",  "FREEFORUSE("+aLLTRIM(aValid[nVCount,1])+"," )
      cValid    := Replace(cValid, "VALCTASUP(", "U_VALCTASUP(" ) 
      cValid    := Replace(cValid,'""',"'")
      
      if !Empty(cValid)
         if Valtype(&(cValid)) = "C"
            cValid := &(cValid)
         endif   
         aValid[nVCount,3] := &(cValid) 
      else 
         aValid[nVCount,3] := .T.
      endif
      
    else 
      cValid := "U_ExistCpo('',"+Alltrim(aValid[nVCount,2])+")"
      aValid[nVCount,3] := &(cValid)   
    endif

    FWRestArea(aArea)
Next 1                          
 
       
Return(aValid)         

Static Function aGrvValid(aValid,nReg)

Local cContvalid
Local nVCount
Local cConteud
Local aRet    :={.T.,.F.}            
Local aArea := FWGetArea()

aSort( aValid,,,{|x,y| x[4] < y[4] } )
      
cContValid := "Tabela:["+Alltrim(ZVJ->ZVJ_DESTINO)+"] - "+"Linha do arquivo:["+Strzero(nReg,12)+"]"


/* Gerando informações de erro */
For nVCount := 1 to Len(aValid)
   
   if !aValid[nVCount,3] 
      aRet := {.F.,iif( aValid[nVCount,5]=="S", .T., .F. ) }             
                            
       
      if aValid[nVCount,4] == "3" 

         cConteud := "Tabela:["+Alltrim(ZVJ->ZVJ_DESTINO)+"]"+" - Campo:["+ALLTRIM(aValid[nVCount,1])+"] - Dependencia não encontrada:["+aLLTRIM(aValid[nVCount,2])+"] - Linha do arquivo:["+Strzero(nReg,12)+"]"      
         U_LOGMIG01(ALLTRIM(ZVJ->ZVJ_DESTINO),StrZero(nSeqErr++,5),cDirArq,cConteud,"015",cDataInicio,cHoraInicio,nReg,nTotErro++)

      else

         cContValid += " - Campo:["+ALLTRIM(aValid[nVCount,1])+iif(aValid[nVCount,4]=="1","] - Validação Protheus:[","] - Validação Especifica:[")+aLLTRIM(aValid[nVCount,2])+"] " 

      endif
      
   //else 
   //      cConteud += "Tabela:["+Alltrim(ZVJ->ZVJ_DESTINO)+"]"+" - Campo:["+ALLTRIM(aValid[nVCount,1])+iif(aValid[nVCount,4]=="1","] - Validação Protheus atendida:[","] - Validação Especifica:[")+aLLTRIM(aValid[nVCount,2])+"] - Linha do arquivo:["+Strzero(nRegCount,12)+"]"
   //      U_LOGMIG01(ALLTRIM(ZVJ->ZVJ_DESTINO),StrZero(nSeqErr++,5),cDirArq,cConteud,iif(aValid[nVCount,4]=="1", "100","101"),cDataInicio,cHoraInicio,nRegCount,nTotErro++)
     
   endif
   
Next 1    

If Ascan( aValid, {|x| x[4] <> "3" .and. !x[3] } ) > 0 
                
   U_LOGMIG01(ALLTRIM(ZVJ->ZVJ_DESTINO),StrZero(nSeqErr++,5),cDirArq,cContValid, "017",cDataInicio,cHoraInicio,nReg,nTotErro++)                   
endif          
                               
FWRestArea(aArea)
Return(aRet)


/*
======================================================
Autor: Jamer Nunes Pedroso 
Data:	10.2014
------------------------------------------------------
Descricao:
Funcçoes compatibilizadoras 
======================================================
*/
user Function ExistCpo(cChave1,cAlias,cChave,nOrdem)
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


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³IE        ³ Autor ³Eduardo Riera          ³ Data ³10.12.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
/*/
#DEFINE TCD_UF     01
#DEFINE TCD_TAM    02
#DEFINE TCD_FATF   03
#DEFINE TCD_DVXROT 04
#DEFINE TCD_DVXMD  05
#DEFINE TCD_DVXTP  06
#DEFINE TCD_DVYROT 07
#DEFINE TCD_DVYMD  08
#DEFINE TCD_DVYTP  09
#DEFINE TCD_DIG14  10
#DEFINE TCD_DIG13  11
#DEFINE TCD_DIG12  12
#DEFINE TCD_DIG11  13
#DEFINE TCD_DIG10  14
#DEFINE TCD_DIG09  15
#DEFINE TCD_DIG08  16
#DEFINE TCD_DIG07  17
#DEFINE TCD_DIG06  18
#DEFINE TCD_DIG05  19
#DEFINE TCD_DIG04  20
#DEFINE TCD_DIG03  21
#DEFINE TCD_DIG02  22
#DEFINE TCD_DIG01  23
#DEFINE TCD_CRIT   24

User Function IE(cIE,cUF,lHelp)

Local aPesos   := {}
Local aDigitos := {}
Local aCalculo := {}
Local aMi      := {}
Local nX       := 0
Local nY       := 0
Local nDVX     := 0
Local nDVY     := 0
Local nPUF     := 0
Local nPPeso   := 0
Local nSomaS   := 0
Local cDigito  := ""
Local cDVX     := ""
Local cDVY     := ""
Local lRetorno := .T.
Local cIEOrig  := cIE

DEFAULT lHelp := .T.
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Ajusta o codigo da Inscricao Estadual                                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cIE := AllTrim(cIE)
cIE := StrTran(cIE,".","")
cIE := StrTran(cIE,"/","")
cIE := StrTran(cIE,"-","")
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Montagem da Tabela de Calculo                                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !Empty(cIEOrig) .And. Empty(cIE) .And. !Empty(cUF)
	lRetorno := .F.
EndIf
If !Empty(cIE) .And. !"ISENT"$cIE .And. lRetorno
	aadd(aCalculo,{"AC",09,00,"E ",11,"P01","  ",00,"   ","--","--","--","--","--","=0","=1","09","09","09","09","09","09","DVX",{||Len(cIE)==09}})
	aadd(aCalculo,{"AC",13,00,"E ",11,"P02","E ",11,"P01","--","=0","=1","09","09","09","09","09","09","09","09","09","DVX","DVY",{||Len(cIE)==13}})
	aadd(aCalculo,{"AL",09,00,"BD",11,"P01","  ",00,"   ","--","--","--","--","--","=2","=4","09","09","09","09","09","09","DVX",{||.T.}})
	aadd(aCalculo,{"AP",09,00,"CE",11,"P01","  ",00,"   ","--","--","--","--","--","=0","=3","09","09","09","09","09","09","DVX",{||cIE<="030170009"}})
	aadd(aCalculo,{"AP",09,01,"CE",11,"P01","  ",00,"   ","--","--","--","--","--","=0","=3","09","09","09","09","09","09","DVX",{||cIE>="030170010".And.cIE<="030190229"}})
	aadd(aCalculo,{"AP",09,00,"E ",11,"P01","  ",00,"   ","--","--","--","--","--","=0","=3","09","09","09","09","09","09","DVX",{||cIE>="030190230"}})
	aadd(aCalculo,{"AM",09,00,"E ",11,"P01","  ",00,"   ","--","--","--","--","=0","09","09","09","09","09","09","09","09","DVX",{||.T.}})
	aadd(aCalculo,{"BA",08,00,"E ",10,"P02","E ",10,"P03","--","--","--","--","--","--","09","09","09","09","09","09","DVY","DVX",{||SubStr(cIE,1,1)$"0123458" .AND. Len( cIE )==8}})
	aadd(aCalculo,{"BA",08,00,"E ",11,"P02","E ",11,"P03","--","--","--","--","--","--","09","09","09","09","09","09","DVY","DVX",{||SubStr(cIE,1,1)$"679".AND. Len( cIE )==8}})
	aadd(aCalculo,{"BA",09,00,"E ",10,"P02","E ",10,"P03","--","--","--","--","--","09","09","09","09","09","09","09","DVY","DVX",{||SubStr(cIE,2,1)$"0123458" .AND. Len( cIE )==9}})	
	aadd(aCalculo,{"BA",08,00,"E ",11,"P02","E ",11,"P03","--","--","--","--","--","09","09","09","09","09","09","09","DVY","DVX",{||SubStr(cIE,2,1)$"679".AND. Len( cIE )==9}})
	aadd(aCalculo,{"CE",09,00,"E ",11,"P01","  ",00,"   ","--","--","--","--","--","=0","09","09","09","09","09","09","09","DVX",{||.T.}})
	aadd(aCalculo,{"DF",13,00,"E ",11,"P02","E ",11,"P01","--","=0","=7","=345","09","09","09","09","09","09","09","09","DVX","DVY",{|| Len(cIE)==12 .OR. (Len(cIE)==13 .AND. SubStr(cIE,3,1)  $ "345")}})		
	aadd(aCalculo,{"DF",13,00,"E ",11,"P02","E ",11,"P01","--","=0","=7","09","09","09","09","09","09","09","09","09","DVX","DVY",{|| Len(cIE)==13 .AND. !SubStr(cIE,3,1)  $ "345"}})		
	aadd(aCalculo,{"ES",09,00,"E ",11,"P01","  ",00,"   ","--","--","--","--","--","09","09","09","09","09","09","09","09","DVX",{||.T.}})
	aadd(aCalculo,{"GO",09,01,"F ",11,"P01","  ",00,"   ","--","--","--","--","--","=1","=015","09","09","09","09","09","09","DVX",{||cIE>="101031050".And.cIE<="101199979"}})
	aadd(aCalculo,{"GO",09,00,"F ",11,"P01","  ",00,"   ","--","--","--","--","--","=1","=015","09","09","09","09","09","09","DVX",{||!(cIE>="101031050".And.cIE<="101199979")}})
	aadd(aCalculo,{"MA",09,00,"E ",11,"P01","  ",00,"   ","--","--","--","--","--","=1","=2","09","09","09","09","09","09","DVX",{||.T.}})
	aadd(aCalculo,{"MT",11,00,"E ",11,"P01","  ",00,"   ","--","--","--","09","09","09","09","09","09","09","09","09","09","DVX",{||.T.}})
	aadd(aCalculo,{"MS",09,00,"E ",11,"P01","  ",00,"   ","--","--","--","--","--","=2","=8","09","09","09","09","09","09","DVX",{||.T.}})
	aadd(aCalculo,{"MG",13,00,"AE",10,"P10","E ",11,"P11","--","09","09","09","09","09","09","09","09","09","09","09","DVX","DVY",{||SubStr(cIE,1,1)<>"P".And.Len(cIE)==13}})
	aadd(aCalculo,{"MG",09,00,"  ",00,"P09","  ",00,"   ","--","--","--","--","--","=P","=R","09","09","09","09","09","09","09",{||SubStr(cIE,1,1)=="P".And.Len(cIE)==9}})
	aadd(aCalculo,{"PA",09,00,"E ",11,"P01","  ",00,"   ","--","--","--","--","--","=1","=5","09","09","09","09","09","09","DVX",{||.T.}})
	aadd(aCalculo,{"PB",09,00,"E ",11,"P01","  ",00,"   ","--","--","--","--","--","09","09","09","09","09","09","09","09","DVX",{||.T.}})
	aadd(aCalculo,{"PR",10,00,"E ",11,"P09","E ",11,"P08","--","--","--","--","09","09","09","09","09","09","09","09","DVX","DVY",{||.T.}})
	aadd(aCalculo,{"PE",14,01,"E ",11,"P07","  ",00,"   ","=1","=8","19","09","09","09","09","09","09","09","09","09","09","DVX",{||Len(cIE)==14}})
	aadd(aCalculo,{"PE",09,00,"E ",11,"P02","E ",11,"P01","--","--","--","--","--","09","09","09","09","09","09","09","DVX","DVY",{||Len(cIE)==9}})
	aadd(aCalculo,{"PI",09,00,"E ",11,"P01","  ",00,"   ","--","--","--","--","--","=1","=9","09","09","09","09","09","09","DVX",{||.T.}})
	aadd(aCalculo,{"RJ",08,00,"E ",11,"P08","  ",00,"   ","--","--","--","--","--","--","09","09","09","09","09","09","09","DVX",{||.T.}})
	aadd(aCalculo,{"RN",09,00,"BD",11,"P01","  ",00,"   ","--","--","--","--","--","=2","=0","09","09","09","09","09","09","DVX",{||Len(cIE)==9}})
	aadd(aCalculo,{"RN",10,00,"BD",11,"P11","  ",00,"   ","--","--","--","--","=2","=0","09","09","09","09","09","09","09","DVX",{||Len(cIE)==10}})
	aadd(aCalculo,{"RS",10,00,"E ",11,"P01","  ",00,"   ","--","--","--","--","09","09","09","09","09","09","09","09","09","DVX",{||.T.}})
	aadd(aCalculo,{"RO",09,01,"E ",11,"P04","  ",00,"   ","--","--","--","--","--","19","09","09","09","09","09","09","09","DVX",{||Len(cIE)==9}})
	aadd(aCalculo,{"RO",14,01,"E ",11,"P01","  ",00,"   ","09","09","09","09","09","09","09","09","09","09","09","09","09","DVX",{||Len(cIE)==14}})
	aadd(aCalculo,{"RR",09,00,"D ",09,"P05","  ",00,"   ","--","--","--","--","--","=2","=4","09","09","09","09","09","09","DVX",{||.T.}})
	aadd(aCalculo,{"SC",09,00,"E ",11,"P01","  ",00,"   ","--","--","--","--","--","09","09","09","09","09","09","09","09","DVX",{||.T.}})
	aadd(aCalculo,{"SP",12,00,"D ",11,"P12","D ",11,"P13","--","--","09","09","09","09","09","09","09","09","DVX","09","09","DVY",{||SubStr(cIE,1,1)<>"P"}})
	aadd(aCalculo,{"SP",13,00,"D ",11,"P12","  ",00,"   ","--","=P","09","09","09","09","09","09","09","09","DVX","09","09","09",{||SubStr(cIE,1,1)=="P"}})
	aadd(aCalculo,{"SE",09,00,"E ",11,"P01","  ",00,"   ","--","--","--","--","--","09","09","09","09","09","09","09","09","DVX",{||.T.}})
	aadd(aCalculo,{"TO",11,00,"E ",11,"P06","  ",00,"   ","--","--","--","=2","=9","09","=1239","09","09","09","09","09","09","DVX",{||.T.}})
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Montagem da Tabela de Pesos                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aadd(aPesos,{06,05,04,03,02,09,08,07,06,05,04,03,02,00}) //01
	aadd(aPesos,{05,04,03,02,09,08,07,06,05,04,03,02,00,00}) //02
	aadd(aPesos,{06,05,04,03,02,09,08,07,06,05,04,03,00,02}) //03
	aadd(aPesos,{00,00,00,00,00,00,00,00,06,05,04,03,02,00}) //04
	aadd(aPesos,{00,00,00,00,00,01,02,03,04,05,06,07,08,00}) //05
	aadd(aPesos,{00,00,00,09,08,00,00,07,06,05,04,03,02,00}) //06
	aadd(aPesos,{05,04,03,02,01,09,08,07,06,05,04,03,02,00}) //07
	aadd(aPesos,{08,07,06,05,04,03,02,07,06,05,04,03,02,00}) //08
	aadd(aPesos,{07,06,05,04,03,02,07,06,05,04,03,02,00,00}) //09
	aadd(aPesos,{00,01,02,01,01,02,01,02,01,02,01,02,00,00}) //10
	aadd(aPesos,{00,03,02,11,10,09,08,07,06,05,04,03,02,00}) //11
	aadd(aPesos,{00,00,01,03,04,05,06,07,08,10,00,00,00,00}) //12
	aadd(aPesos,{00,00,03,02,10,09,08,07,06,05,04,03,02,00}) //13
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Validacao dos digitos da inscricao estadual                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nPUF := aScan(aCalculo,{|x| x[TCD_UF] == cUF .And. Eval(x[TCD_CRIT])})
	If nPUF <> 0
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Validacao do Tamanho da inscricao estadual                              ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		Do Case 
			Case aCalculo[nPUF][2] <> Len(cIE) .And. cUF == "TO"
				cIE := SubStr(cIe,1,2)+"01"+SubStr(cIe,3)
		EndCase
		nY := TCD_DIG01+1
		For nX := Len(cIE) To 1 STEP - 1
			cDigito := SubStr(cIE,nX,1)	
			nY--
			Do Case
			Case SubStr(aCalculo[nPUF][nY],1,2)=="DV"
				If IsAlpha(cDigito) .Or. IsDigit(cDigito)
					If SubStr(aCalculo[nPUF][nY],1,3)=="DVX"
						cDVX := cDigito
					Else
						cDVY := cDigito
					EndIf
				Else
					lRetorno := .F.
				EndIf
			Case SubStr(aCalculo[nPUF][nY],1,2)=="--"
				lRetorno := .F.
				Exit
			Case SubStr(aCalculo[nPUF][nY],1,1)=="="
				If !cDigito $ SubStr(aCalculo[nPUF][nY],2)
					lRetorno := .F.
					Exit
				EndIf
			OtherWise
				If !(cDigito >= SubStr(aCalculo[nPUF][nY],1,1) .And. cDigito <= SubStr(aCalculo[nPUF][nY],2,1))
					lRetorno := .F.
					Exit
				EndIf
			EndCase
			aadd(aDigitos,cDigito)
		Next nX
	Else
		lRetorno := .F.		
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Calculo do digito verificador DVX                                       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lRetorno
		nPPeso := Val(SubStr(aCalculo[nPUF][TCD_DVXTP],2))
		nSomaS := 0
		aMI    := {}
		For nX := 1 To Len(aDigitos)
			aadd(aMi,Val(aDigitos[nX])*aPesos[nPPeso][15-nX])
			nSomaS += Val(aDigitos[nX])*aPesos[nPPeso][15-nX]
		Next nX	
		If "A"$aCalculo[nPUF][TCD_DVXROT]
			For nX := 1 To Len(aMi)				
				nSomaS += Int(aMi[nX] / 10)
			Next nX
		EndIf
		If "B"$aCalculo[nPUF][TCD_DVXROT]
			nSomaS *= 10
		EndIf
		If "C"$aCalculo[nPUF][TCD_DVXROT]
			nSomaS += 5+4*aCalculo[nPUF][TCD_FATF]
		EndIf
		If "D"$aCalculo[nPUF][TCD_DVXROT]
			nDVX := Mod(nSomaS,aCalculo[nPUF][TCD_DVXMD])
		EndIf
		If "E"$aCalculo[nPUF][TCD_DVXROT]
			nDVX := aCalculo[nPUF][TCD_DVXMD]-Mod(nSomaS,aCalculo[nPUF][TCD_DVXMD])
		EndIf
		If "F"$aCalculo[nPUF][TCD_DVXROT]
			nDVX := aCalculo[nPUF][TCD_DVXMD]-Mod(nSomaS,aCalculo[nPUF][TCD_DVXMD])
			If nDVX == 11
				nDVX := 0
			EndIf
			If nDVX == 10
				nDVX := aCalculo[nPUF][TCD_FATF]
			EndIf
		EndIf
		If nDVX == 10
			nDVX := 0
		EndIf
		If nDVX == 11
			nDVX := aCalculo[nPUF][TCD_FATF]
		EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Calculo do digito verificador DVY                                       ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !Empty(aCalculo[nPUF][TCD_DVYROT])
			nPPeso := Val(SubStr(aCalculo[nPUF][TCD_DVYTP],2))
			nSomaS := 0
			aMi    := {}
			For nX := 1 To Len(aDigitos)
				aadd(aMi,Val(aDigitos[nX])*aPesos[nPPeso][15-nX])
				nSomaS += Val(aDigitos[nX])*aPesos[nPPeso][15-nX]
			Next nX	
			If "A"$aCalculo[nPUF][TCD_DVYROT]
				For nX := 1 To Len(aMi)				
					nSomaS += Int(aMi[nX] / 10)
				Next nX
			EndIf
			If "B"$aCalculo[nPUF][TCD_DVYROT]
				nSomaS *= 10
			EndIf
			If "C"$aCalculo[nPUF][TCD_DVYROT]
				nSomaS *= 5+4*aCalculo[nPUF][TCD_FATF]
			EndIf
			If "D"$aCalculo[nPUF][TCD_DVYROT]
				nDVY := Mod(nSomaS,aCalculo[nPUF][TCD_DVYMD])
			EndIf
			If "E"$aCalculo[nPUF][TCD_DVYROT]
				nDVY := aCalculo[nPUF][TCD_DVYMD]-Mod(nSomaS,aCalculo[nPUF][TCD_DVYMD])
			EndIf
			If nDVY == 10
				nDVY := 0
			EndIf
			If nDVY == 11
				nDVY := aCalculo[nPUF][TCD_FATF]
			EndIf
		EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verificacao dos digitos calculados                                      ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If Val(cDVX) <> nDVX .Or. Val(cDVY) <> nDVY
			lRetorno := .F.
		EndIf
	EndIf
EndIf
If !lRetorno .And. lHelp
	//Help(" ",1,"IE")
EndIf
Return(lRetorno)

/*============================================================================================================================*/
User Function existchav(cAlias,cChave,nOrdem,cHelp)
LOCAL xAlias,nSalvReg,nSavOrd,nRegSeek,lRetorno:=.T.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Pega o conteudo da variavel caso nao venha como parametro	 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ValType(cChave) = "U"
	cChave := &(ReadVar())
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Salva o ALIAS do arquivo ativo								 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
xAlias := Alias()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Seleciona o arquivo a ser consultado						 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea(cAlias)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Seleciona a ordem escolhida									   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nSavOrd := IndexOrd()
If nOrdem != NIL
	dbSetOrder(nOrdem)
else
	dbSetOrder(1)
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Salva o registro original do arquivo a ser consultado		 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If EOF() .Or. RecC() == 0
	nSalvReg := 0
Else
	nSalvReg := RecN()
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Quando seleciona ordem ele salva a ordem original 			   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Do Case
	Case valtype(cChave) == "D"
		dbSeek(xFilial(cAlias)+DTOS(cChave))
	Otherwise                 
		dbSeek(xFilial(cAlias)+cChave)
End Case
If inclui
	If !Found()
		If nSalvReg > 0
			Go nSalvReg
		EndIf
		dbSetOrder(nSavOrd)
		dbSelectArea(xAlias)
		Return .T.
	Else
		lRetorno := .F.
	EndIf
Else
	If Found()
		nRegSeek := RecNo()
		If nSalvReg > 0
			Go nSalvReg
		EndIf
		dbSetOrder(nSavOrd)
		dbSelectArea(xAlias)
		lRetorno :=Iif( nRegSeek == nSalvReg, .T. , .F. )
	EndIf
EndIf

If !lRetorno
	IF cHelp == NIL
		//HELP(2,"JAGRAVADO",STR0001,STR0002) //"Já existe registro com esta informação"###"Troque a chave principal deste registro."
	Else
		//HELP(2,"JAGRAVADO",cHelp,"")
	EndIF
End

dbSelectArea(cAlias)
If nSalvReg > 0
	Go nSalvReg
EndIf
dbSetOrder(nSavOrd)
dbSelectArea(xAlias)
Return lRetorno

User Function Pertence(npValor, cpFaixa)
Local lRet := npValor$cpFaixa
Return(lRet)

Static function AtuVld(cpField)                    

	Local aAreaAtu	:= FWGetArea()
	Local cVldPro := ''
	Local cVldUsr := ''	             
	Local cVldAll := ''
	     	
		//dbSelectArea('SX3')
		//SX3->(dbSetOrder(2))//X3_CAMPO
		if !Empty(FWSX3Util():GetFieldType(cpField)) //SX3->(dbSeek(cpField))
			
			cVldPro	:= Alltrim(GetSx3Cache(cpField, 'X3_VALID'))
			cVldUsr	:= Alltrim(GetSx3Cache(cpField, 'X3_VLDUSER'))
			cVldAll	:= Iif( !Empty(Alltrim(cVldPro)), " (" + cVldPro + " ) ", ""  ) 
			cVldAll += Iif( !Empty(Alltrim(cVldUsr)), IIF( !Empty(Alltrim(cVldAll))," .and. ", "") + "( " +cVldUsr+ ") ", "" )
			
			if Empty( ZVK->ZVK_VLDPRO )
			   RecLock("ZVK",.F.)                                     
			   	ZVK->ZVK_VLDPRO 	:= cVldAll 
				//ZVK->ZVK_DESCDE		:= GetSx3Cache(cpField, 'X3_DESCRIC
				///ZVK->ZVK_TIPDES		:= GetSx3Cache(cpField, 'X3_TIPO
				//ZVK->ZVK_TAMDES		:= Alltrim(Str(GetSx3Cache(cpField, 'X3_TAMANHO))
				//ZVK->ZVK_DECDES		:= GetSx3Cache(cpField, 'X3_DECIMAL
				//ZVK->ZVK_OBRDES		:= GetSx3Cache(cpField, 'X3_OBRIGAT
				//ZVK->ZVK_IMPDES		:= GetSx3Cache(cpField, 'X3_RESERV//ANALISAR
				//ZVK->ZVK_PREDES		:= GetSx3Cache(cpField, 'X3_F3
				//ZVK->ZVK_VIRTUA		:= IIF(GetSx3Cache(cpField, 'X3_CONTEXT=='V','S','N')
				//ZVK->ZVK_CBOXDE		:= GetSx3Cache(cpField, 'X3_CBOX
				//ZVK->ZVK_GRPSXG		:= GetSx3Cache(cpField, 'X3_GRPSXG
				//ZVK->ZVK_LOGALT		
			   ZVK->(MsUnlock())
			else
			   cVldAll := ZVK->ZVK_VLDPRO
			endif
		
		EndIf
	
	//SX3->(dbSetOrder(1))
	
	FWRestArea(aAreaAtu)
	
Return( cVldAll )

User Function FreeForUse(cAlias, cChave)

Return(.T.)

User Function ValCtaSup(cConta,cCtaAtu)

Local aSaveArea:= FWGetArea()
Local lRet		:= .T.

DEFAULT cCtaAtu := ""
dbSelectArea("CT1")
dbSetOrder(1)

If !Empty(cConta)
	DO CASE
		CASE cCtaAtu == cConta					//A conta atual (_CONTA) deve ser diferente da superior
			//Help(" ",1,"ENTPAIGUAL")
			lRet := .F.
		CASE !MsSeek(xFilial()+cConta)          //A conta digitada (CTASUP) deve existir no Plano de Contas.
			//Help("  ", 1, "NOCADCTASU")
			lRet := .F.
		CASE CT1->CT1_CLASSE != "1"				//A conta superior deve ser sintetica.
			//Help(" ",1,"NOCLASSESI")
			lRet := .F.
	ENDCASE
EndIf

FWRestArea(aSaveArea)

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

   MsgStop("Não há arquivos n diretório especificado...")
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
//DbEval ( {|| aAdd( aCampos , { ZVK->ZVK_SEQ, ZVK->ZVK_CPOORI, ZVK->ZVK_CPODES, ZVK->ZVK_TIPCPO, ZVK_RELACA, ZVK_VALIDA } ), Reclock("ZVK",.F.), ZVK->ZVK_VLDPRO := Posicione("SX3", 2, aCampos[++nDbeval,3], "X3_VALID"), ZVK->(MsUnlock()) },,{|| ZVK->ZVK_CODEXT == ZVJ->ZVJ_CODIGO },,,) // varrendo dados
DbEval ( {|| aAdd( aCampos , 	{ ZVK->ZVK_SEQ, ZVK->ZVK_CPOORI, ZVK->ZVK_CPODES, ZVK->ZVK_TIPCPO, ZVK->ZVK_RELACA, ZVK->ZVK_VALIDA, ZVK->ZVK_PROVLD, AtuVld(ZVK->ZVK_CPODES), ZVK->ZVK_REJEIT } ) },,{|| ZVK->ZVK_CODEXT == ZVJ->ZVJ_CODIGO },,,) // varrendo dados PEDRO SAMPAIO

cAliasDestino := alltrim(ZVJ->ZVJ_DESTINO) //OpenOEmp(alltrim(ZVJ->ZVJ_DESTINO),ZVJ->ZVJ_EMPDES)
cAliasOrigem  := cAliasDestino // Compatibilidade

MakeUnikey(cAliasDestino)


//CRLF := Chr(10)+Chr(13)

//cSqlExec := " TRUNCATE TABLE " +RetSqlName( Alltrim(ZVJ->ZVJ_DESTINO) )+ " ;" + CRLF

//cTcSql := TCSQLExec( cSqlExec )

//ConOut( "Retorno da remoção: "+ Strzero(cTcSql,10)+ " - "+"delete "+RetSqlName( Alltrim(ZVJ->ZVJ_DESTINO) ) )

ConOut( "Iniciando importação: "+pcCodExt+"|"+cpEmp+"|"+cAliasOrigem+"|"+ZVJ->ZVJ_EMPDES+"|"+cAliasDestino)


// Início do For Arquivo
For nCFiles := 1 to Len(aFiles)

   cHoraInicio := Time()
   cDataInicio := Date()
   lPrim := .T.
   nRegCount := 0
   cTInicio := U_Now(nsInicio)

//IncProc("Lendo arquivo texto...")

   oProcesso:SetRegua1(0)
   oProcesso:SetRegua2(0)
   
   oProcesso:IncRegua1("Configurando a carga...")
   //oProcesso:IncRegua2("Início:"+cTInicio+" Atual:"+U_Now()+" Decorrido:"+ElapTime(Left(cTInicio,8),Left(U_Now(),8) ) )
   

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
    
			For nCpCount := 1 to Len(aCpodata) // #Consistência estrutura do arquivo enviado
 
				aCpodata[nCpCount] := replace(replace(aCpodata[nCpCount],char(13),""), chr(10),"")
    
				if ( nPos := AScan( ACampos,{|x| Alltrim(x[3]) == Alltrim(ACpoData[nCpCount])},,) ) = 0
					cConteud := "Tabela:["+Alltrim(ZVJ->ZVJ_DESTINO)+"] - Campo Inexistente na tabela:["+Alltrim(aCpoData[nCpCount])+"]- Linha do arquivo:["+Strzero(nRegCount,12)+"]"
					U_LOGMIG01(ALLTRIM(ZVJ->ZVJ_DESTINO),StrZero(nSeqErr++,5),cDirArq,cConteud,"004",cDataInicio,cHoraInicio,nRegCount,nTotErro++)
					lEstOk := .F.
				Endif
       
			Next 1
    
			For nCpCount := 1 to Len(aCampos) // #Consistência estrutura do arquivo enviado
    
				if ( nPos := AScan( ACpoData,{|x| Alltrim(x) == Alltrim(aCampos[nCpCount,3])},,) ) = 0
					cConteud := "Tabela:["+Alltrim(ZVJ->ZVJ_DESTINO)+"] - Campo Inexistente no arquivo:["+Alltrim(aCampos[nCpCount,3])+"]- Linha do arquivo:["+Strzero(nRegCount,12)+"]"
					U_LOGMIG01(ALLTRIM(ZVJ->ZVJ_DESTINO),StrZero(nSeqErr++,5),cDirArq,cConteud,"004",cDataInicio,cHoraInicio,nRegCount,nTotErro++)
					lEstOk := .F.
				Endif
       
              
              if (cAliasDestino)->(FieldPos(aCampos[nCpCount,3])) == 0 // Campos existe no config e não existe na tabela
                 aCampos[nCpCount,4] := "0"          
	          endif
       
			Next 1

  
			/* Montando chave de indice para pesquisa */
			For nUniq := 1 to  Len(aUniq) // #Consistência de campos indices
  
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
	          //oProcesso:IncRegua2("Início:"+cTInicio+" Atual:"+U_Now()+" Decorrido:"+ElapTime(Left(cTInicio,8),Left(U_Now(),8) )+ " Restante:"+ cTRest ) 
	          oProcesso:IncRegua2(" Decorrido:"+ElapTime(Left(cTInicio,8),Left(U_Now(),8) )+ " Restante:"+ cTRest )
             
           endif   
           
			aDados := Separa(Replace(Replace(cLinha,Chr(10),""),Chr(13),""),iif( at(CHR(165),cLinha)>0,CHR(165),If(at(CHR(167),cLinha)>0,chr(167),";")),.T.)
  
			if ( nFfalta := ( Len(aCpoData)-len(aDados) ) ) > 0 // Campos a menos nas linhas de dados
  
				For nCFalta := 1 to nFfalta
     
					aadd( aDados, " " )
				Next 1
     
			endif
                                
  //cprod := &("aDados["+StrZero(2,4)+"]")

	       //IF nRegCount == 30
	       //   mSGsTOP("REGISTRO: "+sTRZERO(nRegCount))
          //ENDIF

  
			//for nUniq := 1 to Len(aPosKeys) // Campos sem dados são inicializados no padrão protheus para evitar pesquisas incorretas

           //   Ascan()

			//	If Empty( &( "aDados["+StrZero(nUniq,4)+"]" ) )
					//&("aDados["+StrZero(nUniq,4)+"]") = Criavar(Alltrim(aUniq[nUNiq]),.F.)
			//	else
			//	   if Tamsx3(AposKeys[nUniq])[3] == "D"
				   //   &("aDados["+StrZero(nUniq,4)+"]") := &( IIf(At("/",aDados[nUniq])>0,"CtoD","StoD")+"(aDados["+StrZero(nUniq,4)+"])" )
			//	   	endif
			//	endif

			//Next 1

			nRegCount++
                    
          Copia_Registro( cAliasOrigem, ZVJ->ZVJ_INDORI, cIndDes, cAliasDestino, ZVJ->ZVJ_INDDES, aCampos, @oProcesso, aCpoData )
  
          //oFile:ft_fSkip()
  
		Endif



	Enddo

    oFile:ft_fUse()
    FreeObj(oFile)
     
	U_LOGMIG01(ALLTRIM(ZVJ->ZVJ_DESTINO),StrZero(nSeqErr++,5),cDirArq,"Finalização - Tabela - "+ZVJ->ZVJ_DESTINO,"000",cDataInicio,cHoraInicio,nRegCount,nTotErro++)
 
    if oProcesso:lEnd
	    Exit
	 Endif

// Final do For Arquivos 
Next 1


ConOut( "Finalizando importação: "+pcCodExt+"|"+cpEmp+"|"+cAliasOrigem+"|"+ZVJ->ZVJ_EMPDES+"|"+cAliasDestino)

(cAliasDestino)->(dbCloseArea())

RecLock("ZVJ",.F.)
ZVJ->ZVJ_EMPORI := cEmpZVJ
ZVJ->(MsUnlock())

FWRestArea(aArea)

if !oProcesso:lEnd 
   MsgStop(  "Processamento:"+Alltrim(ZVJ->ZVJ_DESTINO)+" - "+ StrZero(nRegCount,10)+"/"+StrZero(nRegTotal,10)+ " concluído !" )
endif

Return(.T.)

/*
======================================================
Autor: Jamer Nunes Pedroso/Pedro 
Data:	03.2017
------------------------------------------------------
Descricao:
Rotina calculo de tempo
======================================================
*/

user Function NOW(nMS)
Local nHH, nMM , nSS 

Default nMS := seconds() 

nHH := int(nMS/3600) 
nMS -= (nHH*3600) 
nMM := int(nMS/60) 
nMS -= (nMM*60) 
nSS := int(nMS) 
nMS := (nMs - nSS)*1000 

Return strzero(nHH,2)+":"+strzero(nMM,2)+":"+strzero(nSS,2)+"."+strzero(nMS,3) 

User function verval(o) 
Return(.T.)

/*
======================================================
Autor: Jamer Nunes Pedroso/Pedro 
Data:	03.2017
------------------------------------------------------
Descricao:
Rotina calculo de tempo
======================================================
*/
Static Function MakeUnikey(cpAlias)

Local cArquivo
Local cChave
Local cFor
Local nIndex
Local cArquivo 
Local cMens := "Criando indice unico"
Local aArea := FWGetArea()
Local lRet := .F.

if !Empty( cChave := POSICIONE( "SX2", 1, Alltrim(ZVJ->ZVJ_DESTINO), "X2_UNICO" ) )

   DbSelectArea(cpAlias)

   cArquivo := CriaTrab(,.F.)

   IndRegua(cpAlias,cArquivo,cChave,,cFor,cMens,.T.)

   DbSelectArea(cpAlias)

   nIndex := RetIndex(cpAlias)

   DbSetOrder(nIndex+1)

   RecLock("ZVJ",.F.)
   ZVJ->ZVJ_INDDES := nIndex+1
   ZVJ->(MsUnLock()) 
   
   lRet := .T.
   //DbSelectArea(cpAlias)

   //RetIndex(cpAlias)

   //FErase(cArquivo+OrdBagExt())
Else

   DbSelectArea(cpAlias)
   DbSetOrder(1)

   RecLock("ZVJ",.F.)
   ZVJ->ZVJ_INDDES := 1
   ZVJ->(MsUnLock()) 
   lRet := .T.

Endif

FWRestArea(aArea)

Return(lRet)


Static Function GenInsert(cpAlias01,cpAlias02, aInfo)

Local nCount := 0 , cCampos := "", cDados, cValues :="", cSqlText  

aEval(aInfo, {|| nCount++, cCampos += aInfo[nCount,3]+iif( nCount < Len(aInfo),",","" ),;
	                       cValue += toStrSql(&(aInfo[nCount,2]))+iif( nCount < Len(aInfo),",","" ) } )


cSqlText := "Insert Into "+RetSqlName(cpAlias02)+" ( "+cCampos+" ) 

cSqlText += "Values ( "+cValues+"," "

cSqlText += "( Select Max("+RetSqlName(cpAlias02)+".R_E_C_N_O_)+ "+Str((CDBALIAS)->(Recno()))+" " 

cSqlText += "from "+RetSqlName(cpAlias02)+") )


Return(.T.)

Static function ToStrSql(cOrigem)

Local cValue

//&(aInfo[nCampos,2])

if ValType(cOrigem) == "N"
   
      cVaLue := Str(cOrigem)
   
elseif ValType(cOrigem) == "D"

      cValue := "'"+DTos(cOrigem)+"'"
   
elseif  ValType(cOrigem) == "L"

   cValue := Iif(cOrigem, "1", "0")
else 

   cValue := "'"+cOrigem+"'"

endif

Return(cValue)
