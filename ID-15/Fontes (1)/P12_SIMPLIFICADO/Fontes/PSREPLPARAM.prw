#Include "Protheus.Ch"
#INCLUDE "rwmake.ch"
#INCLUDE "TopConn.Ch"
#Include "TbiConn.Ch"
#include "Totvs.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณMParX   บAutor  ณRenato Morcerf       บ Data ณ  04/01/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
*************************
User Function REPLPARAM()
*************************
//SUPERGETMV( <nome do parโmetro>, <lHelp>, <cPadrใo>, <Filial do sistema> )
Private _cParam01 := ""
Private _cParam02 := ""
Private _cParam03 := ""
Private _cParam04 := ""
Private _cParam05 := ""
Private _cParam06 := ""
Private _cParam07 := ""
Private _cParam08 := ""
Private _cParam09 := ""
Private _cParam10 := ""
Private aParam  := {}
Private oSx6 
Private cEmp    := cEmpAnt
Private xFils   := cFilAnt
Private aSaveArea := GetArea()

//DEFAULT ldebug := .T.
//If lDebug 
// PREPARE ENVIRONMENT EMPRESA "01" FILIAL "01310001" MODULO "FIN" 
//EndIf


//@ 000,000 To 700,700 DIALOG oDlg1 TITLE "Replica de Parametros - Filias"
//@ 005,005 To 600,600


@ 000,000 To 175,460 DIALOG oDlg1 TITLE "Ajusta MV_DATAFIN"
@ 005,005 To 065,225

_cParam01 := SuperGetMv("MV_ULMES"  ,,,cFilAnt)
cDescri := alltrim(X6Descric()) + " " + alltrim(X6Desc1())+" "+alltrim(X6Desc2())
//cDescEx := alltrim(X6Desc1())+" "+alltrim(X6Desc2())

@ 010,008 Say "MV_ULMES - "+cDescri 
//@ 018,008 Say cDescEx

@ 020,008 Get _cParam01 Picture "@E"  Size 40,10

_cParam02 := SuperGetMv("MV_DATAFIN"  ,,,cFilAnt)
cDescri := alltrim(X6Descric()) + " " + alltrim(X6Desc1())+" "+alltrim(X6Desc2())
//cDescEx := alltrim(X6Desc1())+" "+alltrim(X6Desc2())

@ 035,008 Say "MV_DATAFIN - "+cDescri 
//@ 018,008 Say cDescEx

@ 045,008 Get _cParam02 Picture "@E"  Size 40,10

/*

_cParam02 := SuperGetMv("MV_DOCSEQ" ,,,cFilAnt)
cDescri := alltrim(X6Descric()) + " " + alltrim(X6Desc1())+" "+alltrim(X6Desc2())

@ 040,008 Say "MV_DOCSEQ - "+cDescri
//@ 048,008 Say cDescEx

@ 050,008 Get _cParam02 Picture "@E"  Size 40,40


_cParam03 := SuperGetMv("FS_XDIRSIS",,,cFilAnt)
cDescri := alltrim(X6Descric()) + " " + alltrim(X6Desc1())+" "+alltrim(X6Desc2())
@ 070,008 Say "FS_XDIRSIS - "+cDescri
//@ 090,008 Say cDescEx

@ 080,008 Get _cParam03 Picture "@E"  Size 200,200

_cParam04 := SuperGetMv("MV_XCNPJMA",,,cFilAnt)
cDescri := alltrim(X6Descric()) + " " + alltrim(X6Desc1())+" "+alltrim(X6Desc2())
@ 100,008 Say "MV_XCNPJMA - "+cDescri
//@ 120,008 Say cDescEx

@ 110,008 Get _cParam04 Picture "@E"  Size 200,200

_cParam05 := SuperGetMv("FS_MAILREC",,,cFilAnt)
cDescri := alltrim(X6Descric()) + " " + alltrim(X6Desc1())+" "+alltrim(X6Desc2())
@ 130,008 Say "FS_MAILREC - "+cDescri
//@ 150,008 Say cDescEx

@ 140,008 Get _cParam05 Picture "@E"  Size 200,200


_cParam06 := SuperGetMv("FS_FILNDEL",,,cFilAnt)
cDescri := alltrim(X6Descric()) + " " + alltrim(X6Desc1())+" "+alltrim(X6Desc2())
@ 160,008 Say "FS_FILNDEL - "+cDescri
//@ 180,008 Say cDescEx

@ 170,008 Get _cParam06 Picture "@E"  Size 40,40

_cParam07 := SuperGetMv("FS_XDIRARQ",,,cFilAnt)
cDescri := alltrim(X6Descric()) + " " + alltrim(X6Desc1())+" "+alltrim(X6Desc2())
@ 190,008 Say "FS_XDIRARQ - "+cDescri
//@ 210,008 Say cDescEx

@ 200,008 Get _cParam07 Picture "@E"  Size 200,200

_cParam08 := SuperGetMv("MV_ULTDEPR",,,cFilAnt)
cDescri := alltrim(X6Descric()) + " " + alltrim(X6Desc1())+" "+alltrim(X6Desc2())
@ 220,008 Say "MV_ULTDEPR - "+cDescri
//@ 240,008 Say cDescEx

@ 230,008 Get _cParam08 Picture "@E"  Size 40,10

_cParam09 := SuperGetMv("MV_DIAISS" ,,,cFilAnt)
cDescri := alltrim(X6Descric()) + " " + alltrim(X6Desc1())+" "+alltrim(X6Desc2())
@ 250,008 Say "MV_DIAISS - "+cDescri
//@ 270,008 Say cDescEx

@ 260,008 Get _cParam09 Picture "@E"  Size 40,10

_cParam10 := SuperGetMv("MV_MRETISS" ,,,cFilAnt)
cDescri := alltrim(X6Descric()) + " " + alltrim(X6Desc1())+" "+alltrim(X6Desc2())
@ 280,008 Say "MV_MRETISS - "+cDescri
//@ 300,008 Say cDescEx

@ 290,008 Get _cParam10 Picture "@E"  Size 40,10
 
aAdd(aParam, {"MV_ULMES"    ,_cParam01})   
aAdd(aParam, {"MV_DOCSEQ"   ,_cParam02})
aAdd(aParam, {"FS_XDIRSIS"  ,_cParam03})    
aAdd(aParam, {"MV_XCNPJMA"  ,_cParam04})
aAdd(aParam, {"FS_MAILREC"  ,_cParam05})    
aAdd(aParam, {"FS_FILNDEL"  ,_cParam06})
aAdd(aParam, {"FS_XDIRARQ"  ,_cParam07})    
aAdd(aParam, {"MV_ULTDEPR"  ,_cParam08})
aAdd(aParam, {"MV_DIAISS"   ,_cParam09})    
aAdd(aParam, {"MV_MRETISS"   ,_cParam10})


DEFINE SBUTTON  FROM 320,006 TYPE 1 ACTION (oDlg1:End(),_GRAVAMV())    ENABLE OF oDlg1 PIXEL
DEFINE SBUTTON  FROM 320,036 TYPE 2 ACTION (oDlg1:End())               ENABLE OF oDlg1 PIXEL

ACTIVATE DIALOG oDlg1 CENTER
Return



//MV_DATAFIN
*/


DEFINE SBUTTON  FROM 070,006 TYPE 1 ACTION (oDlg1:End(),SelectFil())    ENABLE OF oDlg1 PIXEL
DEFINE SBUTTON  FROM 070,036 TYPE 2 ACTION (oDlg1:End())               ENABLE OF oDlg1 PIXEL

ACTIVATE DIALOG oDlg1 CENTER



Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ_gravx   บAutor  ณRenato Morcerf       บ Data ณ  04/01/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

******************************
Static Function SelectFil()
******************************
Local lShareFil := .F.
Local lShareUN  := .F.
//Local aAreaSx6  := SX6->(GetArea())

Close(oDlg1)

aAdd(aParam, {"MV_ULMES"     ,_cParam01, "E"})   
aAdd(aParam, {"MV_DATAFIN"   ,_cParam02, "C"})

aSelFil := AdmGetFil(.F.,.T.,"SE2")
If Len( aSelFil ) <= 0
	Return
EndIf 

MsAguarde({|| ReplicaParam()}, "Aguarde...", "Replicando os Parametros para as Filiais..")

//MsgRun("Replicando os Parametros para as Filiais","Aguarde...",{|| ReplicaParam()})

//ReplicaParam()

//RestArea(aAreaSx6)

Return

/*
Parโmetros:

cParam 	Caracter	Indica o parโmetro que serแ replicado	X
xFils 	Array	Indica as filiais que o parโmetro serแ replicado (para todas as filiais, enviar *, para selecionar a(s) filial(s), utilizar um array simples ( {,} ))	X
lShareUN 	L๓gico	Indica se deve ser compartilhado por unidade de neg๓cio	
lShareFil 	L๓gico	Indica se deve ser compartilhado por filial	
*/


******************************
Static Function ReplicaParam()
******************************
Local aArea := GetArea()

For Nx := 1 To Len(aSelFil)
    nTotal := Len(aSelFil)
	xFils := aSelFil[Nx]
    MsProcTxt("Analisando registro " + cValToChar(Nx) + " de " + cValToChar(nTotal) + "...")
//    RpcSetEnv( cEmp, xFils )
	For Ny :=1 to Len(aParam)
        cParam := Alltrim(aParam[Ny][1])
        cValor := (aParam[Ny][2])
        If !FWSX6Util():ExistsParam(cParam) .AND. (aParam[Ny][3]) == "E"
            FWSX6Util():ReplicateParam(cParam , xFils , lShareUN , lShareFil )
            PUTMV(cParam, cValor)
        Else 
            PUTMV(cParam, cValor)
        EndIf
	Next Ny
//    RpcClearEnv()
Next Nx

RestArea(aArea)

Return
