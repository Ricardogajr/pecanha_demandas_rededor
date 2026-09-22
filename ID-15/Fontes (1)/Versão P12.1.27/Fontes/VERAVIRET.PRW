#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"

User Function VERAVIRET()
Local cArq  := " "
Local cloc0 := "\SPOOL\"
Local cLoc1 := __RELDIR //allTrim(GetMV("MV_RELT"))	//allTrim(GetMV("DOR_SPOOL"))
Local cLoc2 :=  GetTempPath()
Local cLoc3 :=  Curdir()
Local cDrive, cDir, cNome, cExt 

aFiles1 := Directory(cLoc1+"RELAFAST*.*", "D")
aFiles2 := Directory(cLoc1+"FIMAFAST*.*", "D")

ni:=0
For ni := 1 to len(aFiles1)
    FERASE(cLoc1+aFiles1[ni][1])
Next 

ni:=0
For ni := 1 to len(aFiles2)
    FERASE(cLoc1+aFiles2[ni][1])
Next

cDirUsr  := __RELDIR
cDirSrv  := '\SPOOL\'
aDirAux  := Directory(cDirSrv+'RELAFAST*.##R')
aDirAux1 := Directory(cDirSrv+'FIMAFAST*.##R')
//Percorre os arquivos
For nAtual := 1 To Len(aDirAux)
    //Pegando o nome do arquivo
    cNomArq := aDirAux[nAtual][1]
     
    //Copia o arquivos do Servidor para a máquina do usuário
    CpyS2T(cDirSrv+cNomArq, cDirUsr)
Next nAtual   

For nAtual := 1 To Len(aDirAux1)
    //Pegando o nome do arquivo
    cNomArq1 := aDirAux1[nAtual][1]
     
    //Copia o arquivos do Servidor para a máquina do usuário
    CpyS2T(cDirSrv+cNomArq1, cDirUsr)
Next nAtual   

        IF ( ":\" $ cLoc1 )
            //Cliente
            cArq := cGetFile( 'Relacao Fim de Afastamento(s) |fim*.##r|Relacao de Afastamento(s) |rel*.##r' , 'Arquivos',, cLoc1, .T., nOR( GETF_LOCALHARD, GETF_LOCALFLOPPY, GETF_NOCHANGEDIR ),.T., .T.)
        Else
            //Servidor
            cArq := cGetFile( 'Relacao Fim de Afastamento(s) |fim*.##r|Relacao de Afastamento(s) |rel*.##r' , 'Arquivos',, cLoc1, .T., (GETF_NETWORKDRIVE,GETF_NOCHANGEDIR ) ,.T., .T. )   
        EndIF

//cArq := cGetFile( 'Relacao Fim de Afastamento(s) |fim*.##r|Relacao de Afastamento(s) |rel*.##r' , 'Arquivos',, cLoc1, .T., (GETF_NETWORKDRIVE,GETF_NOCHANGEDIR ) ,.T., .T. )   
SplitPath( cArq, @cDrive, @cDir, @cNome, @cExt )
IF !Empty(cNome)
   OurSpool(cNome) 
Endif
/*
If Empty(cDrive)
   cLoc2 := cGetFile( cArq , 'Salvar em', 1, 'C:\', .F., nOR( GETF_LOCALHARD, GETF_LOCALFLOPPY, GETF_RETDIRECTORY ),.F., .F. ) 
   if !Empty(cLoc2)
      CpyS2T(cArq, cLoc2)  
      cArq2 := cloc2+cnome+cext 
      IF !EMPTY(CNOME)  
         shellExecute( "Open", "notepad.exe", cArq2, cLoc2, 1 )
      endif
   ENDIF
else
   IF !EMPTY(CNOME)  
      shellExecute( "Open", "notepad.exe", cArq, cLoc1, 1 )
   ENDIF
endif
*/
RETURN .T.       
