#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "RWMAKE.CH"
     
/*--------------------------------------------------------------------------------------------------------------
        Programa:RCXDORIMP.PRW
        Funcao:RCXDORIMP
        Data: 27/12/2018 (v3)
        Autor: (v1) Mauricio Siqueira (mauricio.siqueira@totvspartners.com.br;mauriciocsiqueira@gmail.com)
        Descricao:Rotina para popular a tabela RCX (Ocupantes do Posto).
--------------------------------------------------------------------------------------------------------------*/
User Function RCXDORIMP()

Local oDlg
Local cTitulo, cTime
Local lConv

Private cFilDest := cFilAnt
Private lOk      := .F.
Private bOk      := { || If(!EMPTY(ALLTRIM(cFilDest)), (lOk:=.T.,oDlg:End()), (lOk:=.F.,oDlg:End())) }
Private bCancel  := { || lOk:=.F.,oDlg:End() }
Private lEnd     := .F.
//Private oProcess

cTitulo := "Cria ( RCX - Ocupantes do Posto)  -  "+cFilDest

Define MsDialog oDlg Title cTitulo From 003,020 To 015,100

@ 50,070 Say 	"Filial a ser gerada: " Size 060,15 Of oDlg Pixel
@ 50,130 MsGet 	cFilDest 		        Size 050,12 Of oDlg Pixel

Activate MsDialog oDlg Centered On Init (EnchoiceBar(oDlg,bOk,bCancel))

If lOk
	cTime := Time()
	Processa( { |lEnd| lConv:=ProcRepl(cFilDest, @lEnd)}, cTitulo, "Processando ", .T. )
EndIf


Return


/*-------------------------------*/
Static Function ProcRepl(cDirOrig,lEnd)
/*-------------------------------*/

Private cKeyRCL := ""
Private cFilFil := ""

Public _cDirNew  := "C:\LOG\"
Public cHora     := Time()    
Public cCrLf     := Chr(13)+Chr(10)
Public nRecRCL   := 0
Public ltxtHeader:= .f.
Public ltxtFim   := .f.
Public nTotPosto := 0
Public nTotLog   := 0
Public nTotOk    := 0
Public aVetorRCX := {}
Public dDtaRefere:= Ctod('01/01/2000')  
//---------------------------------------------------------------------------------------------------------//
Public cArquiXLS := ""
Public oExcelApp
Public nHandle
//---------------------------------------------------------------------------------------------------------//

If cFilDest <> cFilAnt
   MsgAlert("Filial DIFERENTE da filial logada !","Atenção !!")
   Return()
EndIf

If IW_MsgBox("Confirma a Atualização da Tabela [ RCX - Ocupantes do Posto ] ?","Atenção","YESNO" )  	
   fCriaPasta()
   fQueryRCL()
  (Processa({|| fProcRCX()},"Processando","Aguarde, Lendo a Tabela [RCL]...",.F.))
Endif  

Return

//////////////////////////////////////////////////////////////////////////////////
//+-----------------------------------------------------------------------------+//
//| Processa RCX                                                                |//
//+-----------------------------------------------------------------------------+//
///////////////////////////////////////////////////////////////////////////////////
Static Function fProcRCX()

nTotOk := 0

ProcRegua(nRecRCL)

If nRecRCL > 0
   DbSelectArea("TMPRCL")
   DbGoTop()

   While TMPRCL->(!Eof())
     IncProc("Processo... Inserindo Registros na Tabela - [RCX - Ocupantes do Posto]"," :" + Strzero(nTotOk,5) + "/" + Strzero(nRecRCL,5))

     DbSelectArea("RCL")
     DbSelectArea("SRA")
     RCL->(DbGoTo(TMPRCL->RCLRECNO))
     SRA->(DbGoTo(TMPRCL->SRARECNO))
     If RCL->(!Eof())
        aVetorRCX := {}
        nTotPosto := 0
        nMaxPosto := TMPRCL->RCL_NPOSTO
        While TMPRCL->(!Eof()) .And. TMPRCL->RCLRECNO == RCL->(Recno()) 
          IncProc("Processo... Inserindo Registros na Tabela - [RCX - Ocupantes do Posto]"," :" + Strzero(nTotOk,5) + "/" + Strzero(nRecRCL,5))
          If (!(cKeyRCL == TMPRCL->(RCL_FILIAL+RCL_DEPTO+RCL_CARGO+RCL_CC)) .Or. nMaxPosto > nTotPosto) .And. Empty(SRA->RA_POSTO) 
          	cKeyRCL := TMPRCL->(RCL_FILIAL+RCL_DEPTO+RCL_CARGO+RCL_CC)
          	fVetorRCX()
          	nTotPosto++
          EndIf
          nTotOk++
          DbSelectArea("TMPRCL")
          TMPRCL->(DbSkip())
        EndDo

/*
Alteração Solitado pela NANE em 23/05/2017
Mesmo que haja NC, Inserir na RCX os Registros
        If nTotPosto > RCL->RCL_NPOSTO
           nTotLog := nTotLog + nTotPosto
           LogRCX()
           DbSelectArea("RCL")
           RecLock("RCL",.f.)
                    RCL->RCL_OPOSTO := 0
           RCL->(MsUnLock())	   
        Else
           fGravaRCX()
           DbSelectArea("RCL")
           RecLock("RCL",.f.)
                    RCL->RCL_OPOSTO := nTotPosto
           RCL->(MsUnLock())	   
        EndIf
*/
        If nTotPosto > RCL->RCL_NPOSTO
           nTotLog := nTotLog + nTotPosto
           LogRCX()
        EndIf

        fGravaRCX()
        DbSelectArea("RCL")
        RecLock("RCL",.f.)
                 RCL->RCL_OPOSTO := Min(nMaxPosto,nTotPosto)
                 RCL->RCL_STATUS := IIf(nTotPosto == 0,"1","2")  // 1=Livre;2=Ocupado;3=Congelado;4=Cancelado
                 RCL->RCL_DTINI  := IIf(Empty(RCL->RCL_DTINI),dDtaRefere,RCL->RCL_DTINI)
//                 RCL->RCL_DTFIM  := IIf(Empty(RCL->RCL_DTFIM),dDtaRefere,RCL->RCL_DTFIM)
        RCL->(MsUnLock())	   
 
        DbSelectArea("TMPRCL")
     Else
        DbSelectArea("TMPRCL")
        TMPRCL->(DbSkip())
     EndIf
   EndDo

   ltxtFim := .t.
   LogRCX()

   MsgInfo("Geração do(s) Registro(s) na Tabela [RCX - Ocupantes do Posto], Finalizado com Sucesso !!!"+Chr(13)+;
           "Foram Lido(s): "+Alltrim(Str(nTotOk))+" Registro(s)."+Chr(13)+;
           "Sr. Usuário: "+Upper(Alltrim(cUserName))+Chr(13)+" Favor Conferir..","*** FIM DO PROCESSAMENTO ***")
   TCSqlExec("UPDATE "+RetFullName("RCL")+" SET RCL_STATUS = '1' WHERE D_E_L_E_T_=' ' AND RCL_OPOSTO = 0 AND RCL_FILIAL IN ("+cFilFil+")")

   	cSQL := " MERGE INTO "+RetFullName("RCX")+" RCX "+CRLF
   	cSQL += "    USING "+RetFullName("RDZ")+" RDZ "+CRLF
//	cSQL += "    ON (RDZ.D_E_L_E_T_= RCX.D_E_L_E_T_ AND RDZ_CODENT = RCX_FILFUN||RCX_MATFUN) "+CRLF
	cSQL += "    ON RDZ_CODENT = RCX_FILFUN+RCX_MATFUN) "+CRLF
	cSQL += "    WHEN MATCHED THEN UPDATE SET RCX.RCX_CODOCU = RDZ.RDZ_CODRD0 "+CRLF
	cSQL += "    WHERE (RCX.D_E_L_E_T_=' ' AND RCX.RCX_FILIAL = '"+cFilFil+"'"+CRLF

	TCSqlExec(cSql)
	   
   U_XDORLOGSRA()
Else
   Alert("Não Existem Registros para Geração na [RCX - Ocupantes do Posto] !!!"+Chr(13)+;
           "Sr. Usuário: "+Upper(Alltrim(cUserName))+Chr(13)+" Favor Verificar..","*** FIM DO PROCESSAMENTO ***")
EndIf

Return

//////////////////////////////////////////////////////////////////////////////////
//+-----------------------------------------------------------------------------+//
//| Incrementa VETOR                                                            |//
//+-----------------------------------------------------------------------------+//
///////////////////////////////////////////////////////////////////////////////////
Static Function fVetorRCX()

aAdd(aVetorRCX,{;
     TMPRCL->RCL_FILIAL,;
     TMPRCL->RCL_DEPTO,;
     TMPRCL->RCL_CARGO,;
     TMPRCL->RCL_POSTO,;
     TMPRCL->RA_MAT,;
     TMPRCL->RA_NOME,;
     TMPRCL->RCLRECNO,;
     TMPRCL->SRARECNO,;
     dDataBase;
     })
Return

//////////////////////////////////////////////////////////////////////////////////
//+-----------------------------------------------------------------------------+//
//| Grava Registros na RCX                                                      |//
//+-----------------------------------------------------------------------------+//
///////////////////////////////////////////////////////////////////////////////////
Static Function fGravaRCX()

Local i := 0

For i := 1 to Len(aVetorRCX)
 DbSelectArea("RCX")
 Begin Transaction 
    DbSelectArea("RCX")
    RecLock("RCX",.t.)
             RCX->RCX_FILIAL := aVetorRCX[i,1]
             RCX->RCX_POSTO  := aVetorRCX[i,4]
             RCX->RCX_TIPOCU := "1"    // 1=Funcionario;2=Pessoa                                                                                                          
             RCX->RCX_DTINI  := aVetorRCX[i,9]  
    //       RCX->RCX_DTFIM  := 
             RCX->RCX_FILFUN := aVetorRCX[i,1]
             RCX->RCX_MATFUN := aVetorRCX[i,5]
    //       RCX->RCX_NOMFUN := TMPRCL->RA_NOME  // Campo Virtual
    //       RCX->RCX_FILOCU := 
    //       RCX->RCX_CODOCU := 
    //       RCX->RCX_NOMOCU := 
             RCX->RCX_SUBST  := "2"    // 1=Sim;2=Nao                                                                                                                     
    //       RCX->RCX_CODMOV := 
    //       RCX->RCX_AFAST  :=        // 1=Sim;2=Nao                                                                                                                     
    //       RCX->RCX_DTCADS := 
    RCX->(MsUnLock())

    DbSelectArea("SRA")
    SRA->(DbGoTo(aVetorRCX[i,8]))
    If SRA->(!Eof())
       DbSelectArea("SRA")
       RecLock("SRA",.f.)
                SRA->RA_POSTO := aVetorRCX[i,4]
       SRA->(MsUnLock())
    EndIf

    If nTotPosto > RCL->RCL_NPOSTO
       If i == RCL->RCL_NPOSTO
          nTotPosto := i
          i := Len(aVetorRCX)+1
       EndIf
    EndIf
 End Transaction        
Next i

Return

//////////////////////////////////////////////////////////////////////////////////
//+-----------------------------------------------------------------------------+//
//| Gera Query da RCL/SRA                                                       |//
//+-----------------------------------------------------------------------------+//
///////////////////////////////////////////////////////////////////////////////////
Static Function fQueryRCL()
Local cQuery := ""
Local nI

nRecRCL := 0

cFilFil += cFildest

cQuery += "Select"+cCrLf
cQuery += " RCL.RCL_FILIAL,"+cCrLf
cQuery += " RCL.RCL_DEPTO,"+cCrLf
cQuery += " RCL.RCL_CARGO,"+cCrLf
cQuery += " RCL.RCL_CC,"+cCrLf
cQuery += " RCL.RCL_POSTO,"+cCrLf
cQuery += " RCL.RCL_NPOSTO,"+cCrLf
cQuery += " RCL.RCL_OPOSTO,"+cCrLf
cQuery += " RCL.RCL_TPOSTO,"+cCrLf
cQuery += " RCL.RCL_DTINI,"+cCrLf
cQuery += " RCL.RCL_DTFIM,"+cCrLf
cQuery += " RCL.R_E_C_N_O_ AS RCLRECNO,"+cCrLf
cQuery += " SRA.RA_FILIAL,"+cCrLf
cQuery += " SRA.RA_MAT,"+cCrLf
cQuery += " SRA.RA_NOME,"+cCrLf
cQuery += " SRA.RA_SITFOLH,"+cCrLf
cQuery += " SRA.RA_DEPTO,"+cCrLf
cQuery += " SRA.RA_CARGO,"+cCrLf
cQuery += " SRA.R_E_C_N_O_ AS SRARECNO"+cCrLf
cQuery += " From "+RetSqlName("RCL")+" RCL "+cCrLf
cQuery += " Inner Join "+RetSqlName("SRA")+" SRA On "+cCrLf
cQuery += "  SRA.RA_FILIAL = RCL.RCL_FILIAL And"+cCrLf 
cQuery += "  SRA.RA_DEPTO  = RCL.RCL_DEPTO  And"+cCrLf 
cQuery += "  SRA.RA_CARGO  = RCL.RCL_CARGO  And SRA.RA_SITFOLH <> 'D' And SRA.RA_CATFUNC In ('C','D','E','G','H','I','J','M','S','T') And SRA.D_E_L_E_T_ <> '*' "+cCrLf 
cQuery += " Where RCL.D_E_L_E_T_ <> '*' "+cCrLf 
//cQuery += " 	AND SRA.RA_FILIAL IN ('"+cFilFil+"')	"+CRLF
cQuery += " 	AND SRA.RA_FILIAL = '"+cFilFil+"'"+cCrLf
cQuery += "Order By RCL.RCL_FILIAL,RCL.RCL_DEPTO,RCL.RCL_CARGO,RCL.RCL_CC,RCL.RCL_POSTO,SRA.RA_MAT"

//cQuery += " Where RCL.D_E_L_E_T_ <> '*' And SRA.RA_SITFOLH <> 'D' And"+cCrLf 
//cQuery += "  RCL.RCL_FILIAL = '01010004' And RCL.RCL_DEPTO = '000000011' And RCL.RCL_CARGO = '40107'"+cCrLf

MemoWrite("C:\TOTVS_Projects\Projetos\PROTHEUS_RedeDOR\RedeDOR\Query\TMPRCL.SQL",cQuery)
//_cQuery := ChangeQuery(cQuery)
ChangeQuery(cQuery)

If Select("TMPRCL") > 0
   DbSelectArea("TMPRCL")
  ("TMPRCL")->(DbCloseArea())  
Endif

dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"TMPRCL", .F., .T.)
//dbUseArea( .T., “DBFCDX” , “\SA1010.DBF”     ,“SA1DBF”, .T., .F.)

TcSetField(("TMPRCL"),"RCL_DTINI","D",8,0)
TcSetField(("TMPRCL"),"RCL_DTFIM","D",8,0)

DbSelectArea("TMPRCL")
dbGoTop()
Count To nRecRCL

Return


///////////////////////////////////////////////////////////////////////////////////
//+-----------------------------------------------------------------------------+//
//| Grava Arquivo de LOG                                                        |//
//+-----------------------------------------------------------------------------+//
///////////////////////////////////////////////////////////////////////////////////
Static Function LogRCX()

Local i := 0

If !ltxtFim
    If Len(aVetorRCX) > 0
       For i := 1 to Len(aVetorRCX)
	     fWrite(nHandle,Chr(160)+ aVetorRCX[i,1] + ";" )  
	     fWrite(nHandle,Chr(160)+ aVetorRCX[i,2] + ";" )  
	     fWrite(nHandle,Chr(160)+ aVetorRCX[i,3] + ";" )  
	     fWrite(nHandle,Chr(160)+ aVetorRCX[i,4] + ";" )  
	     fWrite(nHandle,Chr(160)+ aVetorRCX[i,5] + ";" )  
	     fWrite(nHandle,Chr(160)+ aVetorRCX[i,6] + ";" )  
	     fWrite(nHandle,"SRA com Alocacao [MAIOR] que Total de Postos RCL" + ";" )  
	     fWrite(nHandle,Transform(nTotPosto,"@E 999999")+ ";" )  
	     fWrite(nHandle,Transform(RCL->RCL_NPOSTO,"@E 999999")+ ";" )  
	     fWrite(nHandle,Chr(160)+ Dtoc(dDataBase) + ";" )  
	     fWrite(nHandle,Chr(160)+ Alltrim(cHora) + ";" )  
	     fWrite(nHandle,Chr(160)+ Alltrim(cUserName) + ";" )  
	     fWrite(nHandle,"DORPOSTRAB()" + ";" )  
	     fWrite(nHandle,Chr(160)+ GetEnvServer() + ";" )  
	     fWrite(nHandle,Chr(160)+ Alltrim(TcGetDB()) + ";" )  
	     fWrite(nHandle,cCrLf )
       Next i
    EndIf
EndIf

If ltxtFim
   fClose(nHandle)
EndIf
Return

///////////////////////////////////////////////////////////////////////////////////
//+-----------------------------------------------------------------------------+//
//| Cria Pasta Local para Geração do TXT                                        |//
//+-----------------------------------------------------------------------------+//
///////////////////////////////////////////////////////////////////////////////////
Static Function fCriaPasta()

If !(ExistDir(_cDirNew))
     Makedir(_cDirNew)
EndIf

cArquiXLS := _cDirNew + "RCL_" + "_" +Dtos(dDataBase)+"_"+StrTran(cHora,":","_")+".CSV"
nHandle   := MsfCreate(cArquiXLS,0)

//Cabec
fWrite(nHandle, "Filial"          + ";" )
fWrite(nHandle, "Departamento"    + ";" )
fWrite(nHandle, "Cargo"           + ";" )
fWrite(nHandle, "Posto"           + ";" )
fWrite(nHandle, "Matrícula"       + ";" )
fWrite(nHandle, "Nome"            + ";" )
fWrite(nHandle, "Não Conformidade"+ ";" )
fWrite(nHandle, "Total SRA com Alocação"+ ";" )
fWrite(nHandle, "Total RCL - RCL_NPOSTO"+ ";" )
fWrite(nHandle, "Data Inicial"    + ";" )
fWrite(nHandle, "Hora Inicial"    + ";" )
fWrite(nHandle, "Usuário"         + ";" )
fWrite(nHandle, "Rotina"          + ";" )
fWrite(nHandle, "Ambiente"        + ";" )
fWrite(nHandle, "Banco de Dados"  + ";" )
fWrite(nHandle, cCrLf )

Return



///////////////////////////////////////////////////////////////////////////////////
//+-----------------------------------------------------------------------------+//
//| PROGRAMA  | DORLOGSRA | AUTOR | Edsonho ®                | DATA |20/05/2017 |//
//+-----------------------------------------------------------------------------+//
//| DESCRICAO | Funcao - DORLOGSRA                                              |//
//|           | LOG das Tabelas RCL x SRA                                       |//
//+-----------------------------------------------------------------------------+//
///////////////////////////////////////////////////////////////////////////////////

User Function xDORLOGSRA()

Public _cDirNew  := "C:\LOG\"
Public cHora     := Time()    
Public cCrLf     := Chr(13)+Chr(10)
Public nRecSRA   := 0
Public ltxtHeader:= .f.
Public ltxtFim   := .f.
Public nTotOk    := 0
//---------------------------------------------------------------------------------------------------------//
Public cArquiXLS := ""
Public oExcelApp
Public nHandle
//---------------------------------------------------------------------------------------------------------//

If IW_MsgBox("Confirma a Geração do LOG da Tabela [ SRA - Ocupantes do Posto ] ?","Atenção","YESNO" )  	
   f2CriaPasta()
   f2QueryRCL()
  (Processa({|| fProcSRA(nRecSRA)},"Processando","Aguarde, Lendo a Tabela [SRA]...",.F.))
Endif  

Return
//////////////////////////////////////////////////////////////////////////////////
//+-----------------------------------------------------------------------------+//
//| Processa SRA                                                                |//
//+-----------------------------------------------------------------------------+//
///////////////////////////////////////////////////////////////////////////////////
Static Function fProcSRA(nRecSRA)

nTotOk := 0

ProcRegua(nRecSRA)

If nRecSRA > 0
   DbSelectArea("TMPSRA")
   DbGoTop()

   While TMPSRA->(!Eof())
     IncProc("Processando... Gerando LOG da Tabela - [SRA]"," :" + Strzero(nTotOk,5) + "/" + Strzero(nRecSRA,5))

     DbSelectArea("SRA")
     SRA->(DbGoTo(TMPSRA->SRARECNO))
     If SRA->(!Eof())
        aVetorSRA := {}
        nTotOK := 0
        While TMPSRA->RA_FILIAL==SRA->RA_FILIAL .And. TMPSRA->RA_DEPTO==SRA->RA_DEPTO .And. TMPSRA->RA_CARGO==SRA->RA_CARGO .And. TMPSRA->(!Eof())
           IncProc("Processando... Gerando LOG da Tabela - [SRA]"," :" + Strzero(nTotOk,5) + "/" + Strzero(nRecSRA,5))
           fVetorSRA()
           nTotOk++
           DbSelectArea("TMPSRA")
           TMPSRA->(DbSkip())
        EndDo
        If nTotOk > 0
           LogSRA()
        EndIf
     Else
        DbSelectArea("TMPSRA")
        TMPSRA->(DbSkip())
     EndIf
     DbSelectArea("TMPSRA")
   EndDo

   ltxtFim := .t.

   LogSRA()

   MsgInfo("Geração LOG da Tabela [SRA], Finalizado com Sucesso !!!"+Chr(13)+;
           "Foram Lido(s): "+Alltrim(Str(nRecSRA))+" Registro(s)."+Chr(13)+;
           "Sr. Usuário: "+Upper(Alltrim(cUserName))+Chr(13)+" Favor Conferir..","*** FIM DO PROCESSAMENTO ***")
Else
   Alert("Não Existem Registros para Geração do LOG [SRA] !!!"+Chr(13)+;
           "Sr. Usuário: "+Upper(Alltrim(cUserName))+Chr(13)+" Favor Verificar..","*** FIM DO PROCESSAMENTO ***")
EndIf

Return

//////////////////////////////////////////////////////////////////////////////////
//+-----------------------------------------------------------------------------+//
//| Incrementa VETOR                                                            |//
//+-----------------------------------------------------------------------------+//
///////////////////////////////////////////////////////////////////////////////////
Static Function fVetorSRA()

aAdd(aVetorSRA,{;
     TMPSRA->RA_FILIAL,;
     TMPSRA->RA_DEPTO,;
     TMPSRA->RA_CARGO,;
     TMPSRA->RA_MAT,;
     TMPSRA->RA_NOME,;
     TMPSRA->SRARECNO})
Return

///////////////////////////////////////////////////////////////////////////////////
//+-----------------------------------------------------------------------------+//
//| Grava Arquivo de LOG                                                        |//
//+-----------------------------------------------------------------------------+//
///////////////////////////////////////////////////////////////////////////////////
Static Function LogSRA()

Local i := 0

If !ltxtFim
    If Len(aVetorSRA) > 0
       For i := 1 to Len(aVetorSRA)
	     fWrite(nHandle,Chr(160)+ aVetorSRA[i,1] + ";" )  
	     fWrite(nHandle,Chr(160)+ aVetorSRA[i,2] + ";" )  
	     fWrite(nHandle,Chr(160)+ aVetorSRA[i,3] + ";" )  
	     fWrite(nHandle,"Não Definido" + ";" )  
	     fWrite(nHandle,Chr(160)+ aVetorSRA[i,4] + ";" )  
	     fWrite(nHandle,Chr(160)+ aVetorSRA[i,5] + ";" )  
	     fWrite(nHandle,"Colaboradores SEM Posto(s) Alocado(s) na RCL" + ";" )  
	     fWrite(nHandle,Chr(160)+ Dtoc(dDataBase) + ";" )  
	     fWrite(nHandle,Chr(160)+ Alltrim(cHora) + ";" )  
	     fWrite(nHandle,Chr(160)+ Alltrim(cUserName) + ";" )  
	     fWrite(nHandle,"DORLOGSRA()" + ";" )  
	     fWrite(nHandle,Chr(160)+ GetEnvServer() + ";" )  
	     fWrite(nHandle,Chr(160)+ Alltrim(TcGetDB()) + ";" )  
	     fWrite(nHandle,cCrLf )
       Next i
    EndIf
EndIf

If ltxtFim
   fClose(nHandle)
EndIf
Return

//////////////////////////////////////////////////////////////////////////////////
//+-----------------------------------------------------------------------------+//
//| Gera Query da RCL/SRA                                                       |//
//+-----------------------------------------------------------------------------+//
///////////////////////////////////////////////////////////////////////////////////
Static Function f2QueryRCL()
Local cQuery := ""

nRecSRA := 0

cQuery += "Select"+cCrLf
cQuery += " SRA.RA_FILIAL,"+cCrLf
cQuery += " SRA.RA_DEPTO,"+cCrLf
cQuery += " SRA.RA_CARGO,"+cCrLf
cQuery += " SRA.RA_MAT,"+cCrLf
cQuery += " SRA.RA_NOME,"+cCrLf
cQuery += " SRA.R_E_C_N_O_ AS SRARECNO"+cCrLf
cQuery += " From "+RetSqlName("SRA")+" SRA "+cCrLf
cQuery += " Where SRA.D_E_L_E_T_ <> '*' And SRA.RA_SITFOLH <> 'D'  "+cCrLf
//cQuery += " 	AND SRA.RA_POSTO = ' ' AND  SRA.RA_FILIAL IN ("+cFilFil+")  "+cCrLf
cQuery += " 	AND SRA.RA_POSTO = ' ' AND  SRA.RA_FILIAL = '"+cFilFil+"'"+cCrLf

//cQuery += " And Not Exists ( Select * "+cCrLf
//cQuery += " From "+RetSqlName("RCL")+" RCL "+cCrLf
//cQuery += " Where RCL.D_E_L_E_T_ <> '*' And "+cCrLf 
//cQuery += "  RCL.RCL_FILIAL = SRA.RA_FILIAL And"+cCrLf 
//cQuery += "  RCL.RCL_DEPTO  = SRA.RA_DEPTO  And"+cCrLf 
//cQuery += "  SRA.RA_FILIAL IN ("+cFilFil+")  And"+cCrLf 
//cQuery += "  RCL.RCL_CARGO  = SRA.RA_CARGO  And RCL.D_E_L_E_T_ <> '*' "+cCrLf 
//cQuery += " ) "+cCrLf 
cQuery += "Order By SRA.RA_FILIAL,SRA.RA_DEPTO,SRA.RA_CARGO,SRA.RA_MAT"

MemoWrite("C:\TOTVS_Projects\Projetos\PROTHEUS_LOCAL\PROTHEUS12\Query\TMPSRA.SQL",cQuery)
ChangeQuery(cQuery)

If Select("TMPSRA") > 0
   DbSelectArea("TMPSRA")
  ("TMPSRA")->(DbCloseArea())  
Endif

dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"TMPSRA", .F., .T.)

DbSelectArea("TMPSRA")
dbGoTop()
Count To nRecSRA

Return

///////////////////////////////////////////////////////////////////////////////////
//+-----------------------------------------------------------------------------+//
//| Cria Pasta Local para Geração do CSV                                        |//
//+-----------------------------------------------------------------------------+//
///////////////////////////////////////////////////////////////////////////////////
Static Function f2CriaPasta()

If !(ExistDir(_cDirNew))
     Makedir(_cDirNew)
EndIf

cArquiXLS := _cDirNew + "SRA_" + "_" +Dtos(dDataBase)+"_"+StrTran(cHora,":","_")+".CSV"
nHandle   := MsfCreate(cArquiXLS,0)

//Cabec
fWrite(nHandle, "Filial"          + ";" )
fWrite(nHandle, "Departamento"    + ";" )
fWrite(nHandle, "Cargo"           + ";" )
fWrite(nHandle, "Posto"           + ";" )
fWrite(nHandle, "Matrícula"       + ";" )
fWrite(nHandle, "Nome"            + ";" )
fWrite(nHandle, "Não Conformidade"+ ";" )
fWrite(nHandle, "Data Inicial"    + ";" )
fWrite(nHandle, "Hora Inicial"    + ";" )
fWrite(nHandle, "Usuário"         + ";" )
fWrite(nHandle, "Rotina"          + ";" )
fWrite(nHandle, "Ambiente"        + ";" )
fWrite(nHandle, "Banco de Dados"  + ";" )
fWrite(nHandle, cCrLf )

Return