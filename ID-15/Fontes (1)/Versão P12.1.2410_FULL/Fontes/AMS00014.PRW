#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "FILEIO.CH"             

#DEFINE cEnt Chr(13)+Chr(10)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAMS00014   Autor  ณLEANDRO RIBEIRO     บ Data ณ  28/02/2020 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Rotina de consulta dos parametros FS_ULMES e MV_ULMES	  บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

User Function AMS00014()      

Local _cArea1  := GetArea()
Local oDlg 
Local _cMvUlmes := SUPERGETMV("MV_ULMES", .T., STOD("19000101")) 
Local _cfvUlmes := SUPERGETMV("FS_ULMES", .T., STOD("19000101"))  

Define MSDialog oDlg Title "Bloqueio de Movimenta็๕es de Estoque" From 0,0 to 165,375 Pixel STYLE DS_MODALFRAME

@009,009 Say "MV_ULMES - Movimenta็๕es somente a partir de"		Pixel of oDlg
@007,130 MSGet _cMvUlmes Size 50,10 of oDlg Pixel When .F. 

@035,009 Say "FS_ULMES - Movimenta็๕es somente a partir de"		Pixel of oDlg
@033,130 MSGet _cfvUlmes    Size 50,10 of oDlg Pixel When .F. 

@065,009 BUTTON "&Ok" Size 30,12 Pixel Action(oDlg:End()) of oDlg Pixel

ACTIVATE MSDIALOG oDlg Center    
        
RestArea(_cArea1)

Return()              
