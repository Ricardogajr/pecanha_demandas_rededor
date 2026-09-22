#INCLUDE "PROTHEUS.CH"        
#INCLUDE "TOPCONN.CH" 
#include "rwmake.ch"  
#include "fileio.ch"  
#INCLUDE "FWPrintSetup.ch"
#INCLUDE "RPTDEF.CH"
#Include "DBTREE.CH"
#Include "HBUTTON.CH"
#Define XENTERX Chr(13)+Chr(10)    
//=============================================================================================================================   
//Programa............: UPDX1PAG12() =======
//Autor...............: Ramon Teodoro e Silva 
//Data................: 17/10/2020
//Descricao / Objetivo: Ajusta Dicionário de Dados SX1 para o grupo de perguntas AFI420 e TEWBTYP4
//Cliente             : Rede Dor
//=============================================================================================================================
User Function UPDX1PAG12()
//=============================================================================================================================

Private aEmpresas  := {}
Private aArea      := getArea()   
//Private dfcCamiLog := GetSrvProfString("StartPath","")

MsgRun("Carregando as informações das empresas.","Aguarde...",{||aEmpresas:=ProcEmp()}) 
If Len(aEmpresas) > 0   
   fUPDTela()
Endif
Return .T.

//=============================================================================================================================
Static Function ProcEmp()
//=============================================================================================================================

Local cMarca	  := "XX" //GetMark()
Local nOpca 	  := 1
Local lInverte	  := .F.
Local _cEmpTroca := Space(02) 
Local _nRecSM0   := SM0->( RecNo() )
Local oDlgEmp    := Nil
Local _aRet		  := {}
Local aCampos	  := { { "M0OK", "C", 02, 0 }, { "M0CODIGO", "C", 02, 0 }, { "M0NOME", "C", 15, 0 },{ "M0FILIAL", "C", 02, 0 }, { "M0FILIAIS", "C", 200, 0 } }
Local aCampos2   := { { "M0OK", , "  ", "" }, { "M0CODIGO",, "Cod. Empresa", "@X" },{ "M0NOME", , "Nome Empresa", "@X" } }

oTempTable := FWTemporaryTable():New( "EMPRESA" )
oTemptable:SetFields( aCampos )
oTempTable:AddIndex("01", {"M0CODIGO"} )
oTempTable:Create()

// Carga do Alias EMPRESA com os dados do SM0
SM0->( DbGoTop() )
Do While !SM0->( Eof() )
   If AllTrim( _cEmpTroca ) != AllTrim( SM0->M0_CODIGO ) 
      _cEmpTroca 	:= SM0->M0_CODIGO
      RecLock( "EMPRESA", .T. )
      EMPRESA->M0OK 	 := cMarca
      EMPRESA->M0CODIGO := SM0->M0_CODIGO
      EMPRESA->M0NOME	 := SM0->M0_NOME
      EMPRESA->( MsUnLock() )	
   EndIf
   DbSelectArea( "SM0" ) 
   SM0->( DbSkip() )
EndDo
SM0->( DbGoTo( _nRecSM0 ) )
EMPRESA->( DbGoTop() )

DEFINE MSDIALOG oDlgEmp TITLE "Selecione as empresas que deverão ser consideradas" From 009,000 To 030,063 OF oMainWnd
	    oMark := MsSelect():New("EMPRESA","M0OK","",aCampos2,@lInverte,@cMarca,{20,2,140,248})
	    oMark:oBrowse:bAllMark := {|| EMPRESA->(DBEVAL({||RecLock("EMPRESA",.F.),EMPRESA->M0OK := iif(empty(EMPRESA->M0OK),cMarca,""),MsUnlock()})), EMPRESA->(dbgotop())}
	   	   
ACTIVATE MSDIALOG oDlgEmp ON INIT EnchoiceBar(oDlgEmp,{ || nOpca := 1, oDlgEmp:End() },{|| nOpca := 2,oDlgEmp:End()}) CENTERED
If nOpca == 1 // Confirmou o processamento
   EMPRESA->( DbGoTop() )
   Do While !EMPRESA->( Eof() )
      Dbselectarea( "EMPRESA" )
      If IsMark( "M0OK", cMarca, lInverte ) // Se a empresa foi marcada, checa os modos de compartilhamento dos arquivos
         aAdd( _aRet, { EMPRESA->M0CODIGO} )
      EndIf
      EMPRESA->( DbSkip() )
   EndDo   	
EndIf
EMPRESA->( DbCloseArea() )
Return( _aRet )

//=============================================================================================================================
Static Function fUPDTela()                                                                                                     
//=============================================================================================================================
Local lRet := .T.
Private oTexto                                                                    
Private cTexto := ""
Private oDlgTela  

cTexto := " "

DEFINE MSDIALOG oDlgTela TITLE "Dicionário de Dados" FROM 000, 000  TO 500, 500 COLORS 0, 16777215 PIXEL
    @ 002, 000 GET oTexto VAR cTexto OF oDlgTela MULTILINE SIZE 244, 223 COLORS 0, 16777215 HSCROLL PIXEL
    @ 227, 001 GROUP oGroup1 TO 246, 246 OF oDlgTela COLOR 0, 16777215 PIXEL
    @ 232, 013 BUTTON oButton1 PROMPT "Executar" SIZE 037, 012 OF oDlgTela ACTION fUPDBase()  PIXEL
    @ 232, 203 BUTTON oButton2 PROMPT "Sair" SIZE 037, 012 OF oDlgTela ACTION oDlgTela:End() PIXEL    
ACTIVATE MSDIALOG oDlgTela CENTERED
Return lRet

//=============================================================================================================================
Static Function fUPDBase()                                                                                                     
//=============================================================================================================================
Local lRet    := .T.
Local nEmp    := 0
Local cEmpBKP := ""
Local cFilBKP := ""
Local cChave	:= ""
Local nX       := 0
Local nY       := 0
Local aSx1     := {}
Local aSXCpos  := {}

cEmpBKP := cEmpAnt
cFilBKP := cFilAnt 

aAdd(aSXCpos,{"X1_GRUPO"  ,"C",003,0})   
aAdd(aSXCpos,{"X1_ORDEM"  ,"C",002,0})  
aAdd(aSXCpos,{"X1_PERGUNT","C",030,0})   
aAdd(aSXCpos,{"X1_PERSPA" ,"C",030,0})   
aAdd(aSXCpos,{"X1_PERENG" ,"C",030,0}) 	   	
aAdd(aSXCpos,{"X1_VARIAVL","C",006,0}) 	   		   	
aAdd(aSXCpos,{"X1_TIPO"   ,"C",001,0}) 	   	
aAdd(aSXCpos,{"X1_TAMANHO","N",002,0}) 	   	
aAdd(aSXCpos,{"X1_DECIMAL","N",001,0}) 	   	
aAdd(aSXCpos,{"X1_PRESEL" ,"N",001,0}) 	 
aAdd(aSXCpos,{"X1_GSC"    ,"C",001,0}) 	 
aAdd(aSXCpos,{"X1_VALID"  ,"C",060,0}) 	 	   		   		   	
aAdd(aSXCpos,{"X1_VAR01"  ,"C",015,0})
aAdd(aSXCpos,{"X1_DEF01"  ,"C",015,0})
aAdd(aSXCpos,{"X1_DEFSPA1","C",015,0})
aAdd(aSXCpos,{"X1_DEFENG1","C",015,0})
aAdd(aSXCpos,{"X1_CNT01"  ,"C",060,0})	 	   		   		   	
aAdd(aSXCpos,{"X1_VAR02"  ,"C",015,0})
aAdd(aSXCpos,{"X1_DEF02"  ,"C",015,0})
aAdd(aSXCpos,{"X1_DEFSPA2","C",015,0})
aAdd(aSXCpos,{"X1_DEFENG2","C",015,0})
aAdd(aSXCpos,{"X1_CNT02"  ,"C",060,0}) 
aAdd(aSXCpos,{"X1_VAR03"  ,"C",015,0})
aAdd(aSXCpos,{"X1_DEF03"  ,"C",015,0})
aAdd(aSXCpos,{"X1_DEFSPA3","C",015,0})
aAdd(aSXCpos,{"X1_DEFENG3","C",015,0})
aAdd(aSXCpos,{"X1_CNT03"  ,"C",060,0})	 	   		   		   	
aAdd(aSXCpos,{"X1_VAR04"  ,"C",015,0})
aAdd(aSXCpos,{"X1_DEF04"  ,"C",015,0})
aAdd(aSXCpos,{"X1_DEFSPA4","C",015,0})
aAdd(aSXCpos,{"X1_DEFENG4","C",015,0})
aAdd(aSXCpos,{"X1_CNT04"  ,"C",060,0}) 
aAdd(aSXCpos,{"X1_VAR05"  ,"C",015,0})
aAdd(aSXCpos,{"X1_DEF05"  ,"C",015,0})
aAdd(aSXCpos,{"X1_DEFSPA5","C",015,0})
aAdd(aSXCpos,{"X1_DEFENG5","C",015,0})
aAdd(aSXCpos,{"X1_CNT05"  ,"C",060,0})
aAdd(aSXCpos,{"X1_F3"     ,"C",006,0})
aAdd(aSXCpos,{"X1_PYME"   ,"C",001,0})
aAdd(aSXCpos,{"X1_GRPSXG" ,"C",003,0})
aAdd(aSXCpos,{"X1_HELP"   ,"C",014,0})
aAdd(aSXCpos,{"X1_PICTURE","C",040,0})
aAdd(aSXCpos,{"X1_IDFIL"  ,"C",006,0})

aAdd(aSX1,{'TEWBTYP4','01','Do Bordero ?'             ,'','','MV_CH1','C', 6,0,0,'G','','MV_PAR01','','','','','','','','','','','','','','','','','','','','','','','','',''      ,'S',   '','.AFI42001.','','',''})
aAdd(aSX1,{'TEWBTYP4','02','Ate o Bordero ?'          ,'','','MV_CH2','C', 6,0,0,'G','','MV_PAR02','','','','','','','','','','','','','','','','','','','','','','','','',''      ,'S',   '','.AFI42002.','','',''})
aAdd(aSX1,{'TEWBTYP4','03','Código do Banco ?'        ,'','','MV_CH3','C', 3,0,0,'G','','MV_PAR03','','','','','','','','','','','','','','','','','','','','','','','','',''      ,'S',   '',          '','','',''})
aAdd(aSX1,{'TEWBTYP4','04','Arq. Configuracao ?'      ,'','','MV_CH4','C',12,0,0,'G','','MV_PAR04','','','','','','','','','','','','','','','','','','','','','','','','',''      ,'S',   '','.AFI42003.','','',''})
//aAdd(aSX1,{'TEWBTYP4','05','Arq. de Saida ?'          ,'','','MV_CH5','C',50,0,0,'G','','MV_PAR05','','','','','','','','','','','','','','','','','','','','','','','','',''      ,'S',   '','.AFI42004.','','',''})
aAdd(aSX1,{'TEWBTYP4','05','Configuracao Cnab ?'      ,'','','MV_CH5','N', 1,0,1,'C','','MV_PAR05','Modelo1','Modelo1','Model1','','','Modelo2','Modelo2','Model2','','','','','','','','','','','','','','','','',''      ,'S',   '','.AFI42009.','','',''})
aAdd(aSX1,{'TEWBTYP4','06','Cons.filiais abaixo ?'    ,'','','MV_CH6','N', 1,0,2,'C','','MV_PAR06','Sim','Si','Yes','','','Nao','No','No','','','','','','','','','','','','','','','','',''      ,'S',   '','.AFI42010.','','',''})
aAdd(aSX1,{'TEWBTYP4','07','da Filial ?'              ,'','','MV_CH7','C', 8,0,0,'G','','MV_PAR07','','','','','','','','','','','','','','','','','','','','','','','','','SM0_01','S','033','.AFI42011.','','',''})
aAdd(aSX1,{'TEWBTYP4','08','ate a Filial ?'           ,'','','MV_CH8','C', 8,0,0,'G','','MV_PAR08','','','','','','','','','','','','','','','','','','','','','','','','','SM0_01','S','033','.AFI42012.','','',''})
aAdd(aSX1,{'TEWBTYP4','09','Receita Bruta Acumulada ?','','','MV_CH9','N',12,2,0,'G','','MV_PAR09','','','','','','','','','','','','','','','','','','','','','','','','',''      ,'S',   '','.AFI42013.','@e 999999999.99','',''})
aAdd(aSX1,{'TEWBTYP4','10','Seleciona Filiais ?'      ,'','','MV_CHA','N', 1,0,1,'C','','MV_PAR10','Sim','Si','Yes','','','Nao','No','No','','','','','','','','','','','','','','','','',''      ,'',   '','.AFI42014.','','',''})

cTexto := "==============================================================================="+Chr(13)+Chr(10)
cTexto += TIME()+" <=== Iniciando a atualização do Dicionário de Dados"+Chr(13)+Chr(10)
cTexto += "==============================================================================="+Chr(13)+Chr(10)
oTexto:Refresh()   
oTexto:GoEnd() 
oDlgTela:Refresh() 

For nEmp := 1 to Len(aEmpresas)   
   
   RpcClearEnv() 
	RpcSetType( 03 )
	RpcSetEnv( aEmpresas[nEmp,01]) // Abre ambiente da empresa    
  
   DbSelectArea("SM0")   
   SM0->(DbSetOrder(1))    
   SM0->(DbGoTop()) 

   If SM0->(DbSeek(aEmpresas[nEmp,01]))            
      
      cTexto += TIME()+" <=== Processando empresa " +SM0->M0_CODIGO+"-"+SM0->M0_NOME+Chr(13)+Chr(10)
      oTexto:Refresh()   
      oTexto:GoEnd() 
      oDlgTela:Refresh() 
      cEmpAnt := SM0->M0_CODIGO //aEmpresas[nEmp,1]  
      
      DbSelectArea("SX1")
	   SX1->(DbSetOrder(1))
      
      nComp := 10 - Len("AFI420")
      
      If SX1->(DbSeek("AFI420"+Space(nComp)+"04"))
         Reclock("SX1", .F.)
       	SX1->&("X1_GSC")     := "S"
         SX1->&("1_CNT01")	 := "\REMESSA" 
         SX1->&("X1_F3")      := ""
         SX1->(MsUnlock())  
         cTexto += "Grupo de perguntas AFI420 alterado com sucesso para a empresa: " + cEmpAnt + Chr(13)+Chr(10)
		Else 
			cTexto += "Não foi encontrado o grupo de perguntas AFI420, ordem 04 para a empresa: " + cEmpAnt + Chr(13)+Chr(10)
      EndIf
		
      oTexto:Refresh()   
		oTexto:GoEnd() 
     	oDlgTela:Refresh() 
     
      If !SX1->(DbSeek("TEWBTYP4"))
         For nX := 1 to Len(aSx1)
            Reclock("SX1", .T.)
            For nY := 1 to Len(aSXCpos)
               &(aSXCpos[nY,1]) := aSX1[nX,nY] 
            Next nY
            SX1->(MsUnlock()) 
         Next nX
         cTexto += "Grupo de perguntas TEWBTYP4 criado com sucesso para a empresa: " + cEmpAnt + Chr(13)+Chr(10)
      Else
         cTexto += "Grupo de perguntas TEWBTYP4 já existe para a empresa: " + cEmpAnt + Chr(13)+Chr(10)
      EndIf
		
      oTexto:Refresh()   
		oTexto:GoEnd() 
     	oDlgTela:Refresh() 

   Endif

Next nEmp

cTexto += "==============================================================================="+Chr(13)+Chr(10)
cTexto += TIME()+" <=== Atualização do Dicionário de Dados completa"+Chr(13)+Chr(10) 
cTexto += "==============================================================================="+Chr(13)+Chr(10)  
oTexto:Refresh()   
oTexto:GoEnd() 
oDlgTela:Refresh() 

cChave := "LogUpdX1P12-"+dtos(dDATABASE)+"-"+REPLACE(TIME(),":","-")+".TXT"
MemoWrite(cChave,cTexto) // Grava o arquivo de log no final do processamento de cada empresa   
MSGInfo("Arquivo de Log gerado em "+GetSrvProfString("Rootpath", "")+"\"+ALLTRIM(cChave), "Atualização SX1", 1, .t.)

cTexto += "  Arquivo de Log gerado em "+GetSrvProfString("Rootpath", "")+"\"+ALLTRIM(cChave) +" " +Chr(13)+Chr(10)  
oTexto:Refresh()   
oTexto:GoEnd() 
oDlgTela:Refresh()

cEmpAnt := cEmpBKP
cFilAnt := cFilBKP   

RpcClearEnv() 
RpcSetEnv( cEmpAnt, cFilAnt) // Abre ambiente da empresa    

RestArea( aArea ) 
oDlgTela:End()

Return lRet 

