#include 'protheus.ch'
#include 'parmtype.ch'

// ###########################################################################################
// Projeto:
// Modulo :
// Função : 
// -----------+-------------------+-----------------------------------------------------------
// Data       | Autor             | Descricao
// -----------+-------------------+-----------------------------------------------------------
// 16/05/2017 | Miqueias Dernier  |  O ponto de entrada CHKEXEC é disparado ao executar uma 
//            |                   |  rotina no menu. Caso seu retorno seja F  a rotina não é executada.
//------------|-------------------|----------------------------------------------------------- 
// 16/05/2017 | Miqueias Dernier  |  O ponto de entrada é utilizado para controlar quais tabelas 
//            |                   |  estarão disponíveis para consulta nas rotinas de Consulta Genérica
//            |                   |  e Consulta Genérica Relacional
// -----------+-------------------+-----------------------------------------------------------
user function CHKEXEC()


Local aArea    := GetArea()
Local aDataBloq:= {}
Local cFilU013 := cFilAnt
Local nPosU013 := 0
Local cTabela  := "U013" // "U001"  
Local lRet := .T.                       

Local cModulo := oApp:cModName
Local cObj    := PARAMIXB
Local cTabs

//Local bWindowInit := {|| __Execute('MDTA685()',"xxxxxxxxxxxxxxxxxxxx","MDTA685","SIGAMDT","SIGAMDT",1,.T.)} 
//Local bWindowInit := {|| __Execute("MDTA685()" , "xxxxxxxxxxxxxxxxxxxx" , "MDTA685" , AllTrim(Str(nModulo)) , "" , 1 , .T. )}

//Outra forma de chamar a rotina 'MDTA685' que está em MVC agora diferente do  __Execute('MDTA685()',"xxxxxxxxxxxxxxxxxxxx","MATA010","SIGAMDT","SIGAMDT",1,.T.)}
//Private aRotina := FWMVCMenu( 'MDTA685' )//( "MDTA685" )
Private oModel  
Private oView


//StaticCall(MDTA685,ModelDef)          
//StaticCall(MDTA685,ViewDef)
          

//If Len(aDataBloq) > 0 .And. paramixb $ ('MDTA685()|MDTA410()')
// ticket n° 3642635 / 4642966 - 415966 - Paulo Dias - Remoção do bloqueio total para lançamentos de atestado.
/*
If paramixb $ ('MDTA685()|MDTA410()')

	fCarrTab(@aDataBloq,cTabela, Nil )
	                    
	If Len(aDataBloq) > 0 
		If Ascan(aDataBloq,{|x| x[1] == cTabela .And. Alltrim(x[2]) == cFilU013}) > 0
	    	nPosU013 := Ascan(aDataBloq,{|x| x[1] == cTabela .And. Alltrim(x[2]) == cFilU013 .And. dDataBase >= x[5] .And. dDataBase <= x[6]})
	   	Else
	    	cFilU013 := ""
	      	If Ascan(aDataBloq,{|x| x[1] == cTabela .And. Alltrim(x[2]) == cFilU013}) > 0
	        	nPosU013 := Ascan(aDataBloq,{|x| x[1] == cTabela .And. Alltrim(x[2]) == cFilU013 .And. dDataBase >= x[5] .And. dDataBase <= x[6]})
	      	EndIf
	 	EndIf
		
		If nPosU013 > 0
			MsgAlert("Sr. Usuário: "+Upper(Alltrim(cUserName))+Chr(13)+Chr(13)+;
		             "Acesso a Rotina será Liberado em "+Dtoc(aDataBloq[nPosU013,6]),"Atestado Médico"+Chr(13)+;
		             "Período Bloqueado para Manutenção!")
		    lRet := .F.   
		
		Else   
		  //	  eval(bWindowInit)                         
		      //MDTA685()
		EndIf      	
	Else
		MsgStop("Sr. Usuário: "+Upper(Alltrim(cUserName))+Chr(13)+;
                "Favor solicitar a área de Gestão de Pessoal, que verifiquem o Cadastro.",;
                "Definição e/ou Manutenção de Tabelas"+Chr(13)+;
                "Não Localizado"+Chr(13)+"[U013 - Atestado Médico]")      
   		lRet := .F.             
	        
	EndIF
EndIf


	
	If cObj == "EDAPP()" .Or. cObj == "MPVIEW()"
		cTabs := GetTabs(cModulo)
		If !Empty(cTabs)
			oApp:cFOpened := cTabs
		Else
			Alert("Função não permitida para este ambiente")
			lRet := .F.
		EndIf
	EndIf
EndIf

RestArea(aArea) 
	
return lRet
*/
 //Fim ticket n° 3642635
// ###########################################################################################
// Projeto:
// Modulo :
// Função : 
// -----------+-------------------+-----------------------------------------------------------
// Data       | Autor             | Descricao
// -----------+-------------------+-----------------------------------------------------------
// 16/05/2017 | Miqueias Dernier  | Retorna uma String contendo os Alias disponíveis para  
//            |                   | cModulo
// -----------+-------------------+-----------------------------------------------------------
Static Function GetTabs(cModulo)
Local cRet := ""
Local cQryAlias
Local cQuery := ""

cQuery += " SELECT * FROM "+RetFullName("SZ1")+" SZ1 "+CRLF
cQuery += " 	WHERE SZ1.D_E_L_E_T_=' ' AND Z1_FILIAL = '"+XFilial("SZ1")+"' "+CRLF
cQuery += " 		AND Z1_MODULO = '"+cModulo+"' "+CRLF

cQuery := ChangeQuery(cQuery)
dbUseArea(.T.,'TOPCONN', TCGenQry(,,cQuery),(cQryAlias:=GetNextAlias()), .F., .T.)
While (cQryAlias)->(!Eof())
	cRet += (cQryAlias)->Z1_TABELA
	(cQryAlias)->(dbSkip())
EndDo
(cQryAlias)->(dbCloseArea())

Return cRet

User Function CargIni()
Local aTabelas := {}
Local nI,nJ
RpcSetEnv('01','01010001')

AAdd(aTabelas,{"SIGAACD","SX5"})
AAdd(aTabelas,{"SIGAAGR","SX5","SA5","SC7","SE2","SF1","SED","SE4","SAD","AC8","AC9","SA1","SA3","SA4","SA6","SAO","SC5","SD1","SE1","SET","VCB",;
"SU5","SQ0","SQB","SI1","SI2","SI5","SI6","SI7","SI8","SM2","SE8","SB2","SB3","SB4","SB5","SB6","SB8","SBJ","SBE","SBF",;
"SDD","SC1","SC2","SC4","SC6","SD2","SD3","SD4","SG1","SG2","SI3","SYD","SI4","SID","SIC","SJ2","SC3","SAH","QEK","QE6",;
"QE7","SFZ","SBD","SD8","SCM","SBM","SF5","NN2","NN1","NN3","CTT","NN9","NNA","SRA","NNB","NNH","NNI","NNJ","NNK","NNL",;
"NNR","NNV","NNE","NNX","NNP","NND","NQD","NQF","SB1","SY3","SY2","SAI","SFH","SCQ","SY1","AFN","SCR","SC8","SF7","SW2",;
"SA2","SDA","SB9","SDE","SE3","SEF","SF3","SF4","SF9","SN1","SN2","SN3","SN4","SN5","SD5","QEL","QEP","QEY","QEZ","SF8",;
"SD7","QEA","SFA","DCF","SB7","NQT","NP1","NP2","NQP","NPA","NPO","NPP","NPI","NPD","NPR","NP5","NPK","NPL","NO1","NO2",;
"NO7","NO8","SEV","AFR","SEZ","SE5","SEA","SM7","SE6","AF8","AF9","NOA","CT1","CTH","CTD","SBG","SBH","SCJ","SCK","SCL",;
"SCO","SA7","SC0","SBK","SDC","SGA","SDB","DAK","DAI","SC9","SF2","AA3","AA4","AAF","AB6","AB7","AB8","DAC","SFC","DX3",;
"NKF","DX4","DXE","DXF","DXI","DXA","SH7","DX1","DX9","DXL","DXM","DXJ","DXK","DX7","DXD","ADA","ADB","DXR","DXP","DXQ",;
"DXO","DXN","DXT","DXS","NP9","NP3","NP4","NP7","NP8","NKX","NKY","NPE","NPF","NPG","NPM","NPN","NPS","NO3","NP6"})
AAdd(aTabelas,{"SIGAAPD","SX5","RDK","RD4","RDM","RD2","SYP","RDY","RD1","RDH","RD5","RBK","RBL","SQP","SQQ","SQO","RDU","RDI","RDN","RDG","SI3",;
"CTT","RE8","RBO","SRA","SR7","SR9","SR3","SA6","SRJ","SR6","SRX","RBM","RIX","RIY","RD0","RDZ","RDE","RDV","RDJ","RBP",;
"RBQ","REU","RD3","RD8","RDO","RDS","RDT","RD6","RDP","RD9","RDA","RDC","RIZ"})
AAdd(aTabelas,{"SIGAAPT","SX5","RE5","REK","RE8","RE3","REJ","RER","REC","RE1","REE","CTT","SRA","RD0","RDE","RDZ","REU","RE6","RE0","REL","RE4",;
"REA","RE9","REO","RES","REM","REH","SA1","SA2","SRV","RC1","REG","SN1","SE2","RCE","REP"})
AAdd(aTabelas,{"SIGAARM","SX5"})
AAdd(aTabelas,{"SIGAATF","SX5","SN1","SN2","SN3","SN4","SN5","SN6","SNA","SNC","SI1","SI2","SI3","SI5","SI6","SI7","SI8","SI9","SM2","SA2","SFA",;
"SF9","ST9","CT1","CT2","CTT","CT5","CTH","CTD","SNW","SNX","SNY","SN8","SI4","SRD","SN9","SRA","SA4","SA5","SAD","SB6",;
"SC1","SC7","SE2","SE4","SED","SF1","AC8","AC9","SU5","SM4","SU0","SU7","SUS","SUV","SNB","SNE","SNG","FNG","SNK","ACB",;
"ACC","RD0","SND","SNH","SN0","FNI","FNT","FNB","FNC","FND","FNE","FNQ","FNU","FNV","FNX","FNW","SIC","SID","FN1","FN2",;
"FN3","FN4","FN5","FN6","FN7","FN8","SA1","SF2","SNL","SNM","SD2","SE1","FNF","SNQ","SNR","SNS","FNA","FNH","FNK","FNL",;
"FNM","FNJ","SNV","FNP","FNN","FNO","WF3","WFA","WF6"})
AAdd(aTabelas,{"SIGABPM","SX5"})
AAdd(aTabelas,{"SIGACDA","SX5","SB2","SB3","SB4","SB5","SB6","SB8","SBJ","SBF","SDD","SC1","SAI","SC2","SC4","SC6","SC7","SD1","SD2","SD3","SD4",;
"SG1","SG2","SED","SYD","SJ2","SJ1","SJC","SBP","AH1","AH8","SE2","SF1","SE4","AC8","AC9","SA6","SM2","AH2","AH3","AH4",;
"AH5","AH6","SB1","SA2","AH7","SAH","SF4","SC5","SF3","AHG","AHH","AHI","SE5","SEF","SE8","SE1","SI2","SI5","SI6","SI7",;
"SA1","SB9","SF5","SIB","SI8"})
AAdd(aTabelas,{"SIGACFG","SX5","SUO","SU5","SU7","SUS","SUV","SK4","SKA","SKB","SKJ"})
AAdd(aTabelas,{"SIGACOM","SX5","SA5","SB2","SB3","SB4","SB5","SB6","SB8","SBJ","SBF","SDD","SC1","SC2","SC4","SC6","SC7","SD1","SD2","SD3","SD4",;
"SG1","SG2","SI1","SI3","SYD","SI4","SIC","SID","SJ2","SBG","SBS","SAH","QEK","QE6","QE7","SJ1","SJC","SDC","SDB","SBM",;
"QED","QEG","QEP","QEA","QF4","QF5","QEF","QEL","QEI","QE8","QEH","QEN","QEO","QA6","QA7","QA8","QEY","QEZ","QA2","QEM",;
"QER","QE1","QEQ","QES","SB1","SCK","AFN","NNR","CC2","SE2","SF1","SED","SE4","SAD","AC8","AC9","SA1","SA3","SA4","SA6",;
"SC5","SE1","SET","VCB","SAO","JA2","SUA","SUC","SF2","DAF","DAD","SAE","SU5","SA2","SF4","SF3","SFB","SFC","SFH","SFF",;
"SFM","SM2","SF7","SI2","SI5","SI6","SI7","SI8","SM4","SU0","SU7","SUS","SUV","SAN","ACB","ACC","DHI","AIA","AIB","SAI",;
"DBK","AIC","CPW","CPX","SY1","DHL","SAK","SAL","DBL","DHK","SAJ","SY3","SY2","SCQ","SCY","SFJ","SDF","SBL","SC8","SCE",;
"DCF","DB5","DBH","DBI","DBJ","SCR","SW2","SCS","SC3","SDU","SDA","SB9","SDE","DB1","DB2","DB3","SE3","SEF","SF9","SN1",;
"SN2","SN3","SN4","SN5","SD5","SDS","SF8","SD7","SFA","CB1","CB3","CB4","CB5","SE5","SA7","SF5","SCP","SBZ","SDT","DHJ",;
"SC0","SC9"})
AAdd(aTabelas,{"SIGACON","SX5","SI1","SI7","SID","SI4","SI5","SI9","SI8","SM2","SIB","SIA","SM4","SU0","SU5","SU7","SUS","SUV","SI2","SI3","SI6",;
"SIC","CWP","CWR","CWS","CWT","CT2","WF6"})
AAdd(aTabelas,{"SIGACRD","SX5","SA1","MA7","MA8","MAD","MA5","MA6","MAI","MA9","MAA","MAB","MAC","MAE","MAR","MA4","MAJ","MAM","MBO","MAF","SLJ",;
"MAG","MAN","MAO","MAP","MAQ","MAW","MAV","MAY","MAS","MAT","MAX","MA0","MAU","SL1","MAH","MA3","MAK","MBP","MBN","SAE",;
"SLG","SLF"})
AAdd(aTabelas,{"SIGACRM","SX5","AOF","AC8","ACH","SUS","SA1","SU5","AGA","AGB","ACY","SA3","AIM","AIN","AC3","AC4","AC9","SC7","SE2","SF1","SED",;
"SE4","AD1","AD2","AD3","AD4","AD9","ADC","ADY","AD5","AD6","SA7","SB1","SB2","SB5","SB8","SBJ","SB9","SBE","SBF","SC0",;
"SC5","SC6","SD5","SBK","SD7","SDC","SF4","SGA","SM2","SDA","SDB","SBM","DAK","DAI","SCT","AOJ","SUP","SUQ","SUR","SUW",;
"SUZ","AOC","AOG","AC6","AC7","SU4","SU6","ACD","ACE","SYP","SI1","SI3","SC1","SC2","SC4","SD3","SYD","SU1","SUG","ACU",;
"ACV","SG1","SAH","QEK","QE6","QE7","SFZ","SBD","SD8","SCM","NNR","AC1","AC2","AO3","AO4","ADK","ACA","AO5","AA1","ABC",;
"AOV","CTT","DA0","DA1","ACO","ACP","AOL","AOM","AZ0","AZ1","AZ2","AZA","AO6","AOE","AG1","AG3","AOH","AO2","AO8","AO9",;
"AOA","SUM","SUN","AC5","AOK","AO0","AO1","ACB","ACC"})
AAdd(aTabelas,{"SIGACSA","SX5","RD2","SRA","SR7","SI3","SR9","SR3","SA6","SRJ","SR6","SRX","RBM","SQB","CTT","SQV","SQ9","SQI","RBF","RBK","RBL",;
"RBG","RBJ","SQ1","SQ2","SQ3","SQ4","SQN","SQ0","RA5","RBH","RAL","SQX","SQT","SRW","SYP","SQ8","SRD","SI1","SI7","SQC",;
"RAF","RBI","RB7","RB8","RBD","RB3","RB0","RB2","RB1","RB4","RB6","RA4","RA3","RB5","RBE","SU0","SU5","SU7","SUS","SUV",;
"WF6"})
AAdd(aTabelas,{"SIGACTB","SX5","CT0","CV0","CTM","CTO","CTR","CTP","CTS","CTG","CTE","CT8","CTA","CTL","CVB","CVC","CVR","CVS","CVT","CVL","CVM",;
"CVQ","CT1","CTD","CTT","CTH","CTB","CQ0","CQ1","CQ2","CQ3","CQ4","CQ5","CQ6","CQ7","CQ8","CQ9","CV5","CT2","CTF","CVD",;
"CVN","CVA","CT5","CTJ","CT9","CTQ","CW1","CW2","CW3","CTC","CV1","CTK","CV3","CT3","CT4","CTI","CW8","CTZ","CT6","CT7",;
"CTN","CVX","CTU","CTV","CTX","CTW","CTY","CQC","CQB","WF6"})
AAdd(aTabelas,{"SIGADPR","SX5","QP1","QP2","QP7","QP8","QA2","QPR","QEE","QPF","QPX","QQB","QA6","QA7","QPH","QPI","QPN","QPY","QPA","QP6","SB1",;
"QM1","QPS","QPT","SH3","SG2","SH1","SH7","SH4","QQ1","QQ2","QQ3","QQH","QQG","SHB","SAH","QQK"})
AAdd(aTabelas,{"SIGAECO","SX5","SF1","SED","SE4","SAD","SW7","SW0","SC1","SC7","SE2","SYA","SYR","SA2","SA6","SB6","SA1","ECC","EC6","ECB","SI8",;
"SYF","SYE","SE5","EE3","ACY","EC3","EC7","ECD","ECF","ECG","ECH","ECE","EC5","EC2","EC4","EC0","EC8","EC9","ECA","EC1",;
"EF1","EF3","SY0","SU0","SU5","SU7","SUS","SUV","WF6"})
AAdd(aTabelas,{"SIGAEDC","SX5","SYS","SW0","SW1","SW2","SW3","SW4","SW5","SW6","SW7","SYD","SAH","SGA","SB1","EEI","SA5","SC1","SC7","SD1","SYC",;
"SJC","SJ1","SJ2","SG1","SYT","SY1","SA2","SA6","SYP","SY2","SA1","SY6","SJ7","SJ8","SJ5","ED7","ED0","ED1","ED2","ED3",;
"ED4","ED5","ED6","EDD","EDF","ED8","ED9","SWP","SWN","SWW","EI1","EI2","EI3","SF3","SWX","SWZ","EEC","EE9","EEM","SD2",;
"EEK","SY0","SU0","SU5","SU7","SUS","SUV"})
AAdd(aTabelas,{"SIGAEEC","SX5","EE4","SYP","SY6","EE2","SYF","SYE","EEH","EEG","SYC","SYA","EE1","SY9","SYQ","SYR","SW2","EC6","SYB","EEI","E11",;
"EJ7","EX5","EX6","SA6","SE2","SE5","EE3","SY5","SA1","EXH","SA2","EE5","EEK","SB1","SA5","SW3","EE6","EXB","EX8","E10",;
"SG1","SJ0","SJ9","SAH","SJ5","SYJ","EED","SY8","EEF","EEE","SYD","SJC","SJ2","SJ1","EXO","EE7","EE8","SWD","EEB","EEJ",;
"EEN","EEO","SC5","SC6","SF4","SE4","SB4","SB2","SC0","EET","EEC","EE9","EEM","SD2","EXI","EXL","EEU","EXM","EY5","EY8",;
"EJ5","EJ6","EEY","EEP","EER","EY6","EEX","EEZ","E09","EEL","EEQ","EXG","SC9","EJA","EES","EEA","EX0","EX1","EX2","SY0",;
"EG4","E12","SU0","SU5","SU7","SUS","SUV","WF6","EYA","EYB","EYC","EYD","EYE","SJ6","SYL","SYM","SYN","SYO","SYU","SYV",;
"SYX","SYZ"})
AAdd(aTabelas,{"SIGAEFF","SX5","SJ7","EEF","SY6","EE2","SYF","SYE","SY3","EF7","EF8","SYT","SA2","SA1","SA6","EF5","SYW","SY5","EC6","EF9","EFA",;
"EF1","EF2","EF3","SWB","EF4","SWA","SW6","SWC","SYH","SWP","SW3","SW4","SW5","SW9","SW8","EF6","EEQ","EEL","SY0","SU0",;
"SU5","SU7","SUS","SUV"})
AAdd(aTabelas,{"SIGAEIC","SX5","SW2","SYS","SW1","SW7","SW0","SYD","SAH","SYI","SJ6","SY3","SY4","SY5","SYJ","SY6","SJ7","SJ8","SY7","SY8","SY9",;
"SYG","SYK","SYW","SWX","SWZ","EE3","EC6","EJ7","SYT","SY1","SA2","SA6","SB1","SYP","SY2","SA1","SYA","SE2","SE5","SA5",;
"SC1","SC7","SD1","SYC","SJC","SJ1","SJ2","NNR","SF1","SED","SE4","SAD","SB6","EJC","SYV","SYX","SA3","SA4","SC5","SE1",;
"SF2","SYF","SYQ","SYR","SW3","SYE","SWO","EI4","EI5","SW4","SW5","SWP","SWV","EIS","SW6","EIJ","EIC","SW8","SW9","SWA",;
"SWB","SWD","EIK","EIL","EIM","EIN","EIO","EIP","EIQ","EIR","SJ9","EII","EIF","EIG","EIH","SWN","SWW","EI1","EI2","EI3",;
"SF3","EJ5","EJ6","SWC","SYH","EID","SJV","SJA","SJB","SJE","SJF","SJG","SJH","SJI","SJJ","SJK","SJL","SJM","SJN","SJO",;
"SJP","SJR","SJT","SJU","SJW","SJY","SJZ","EV0","EV1","EV2","EV3","EV4","EV5","EV6","EV7","EV8","EV9","EVA","EVB","EVC",;
"EVD","EVE","EVF","EVG","EVH","EVI","EVK","SWF","SWH","SWI","SWJ","SWK","SWQ","SWR","SWS","SWT","SYL","SYM","SYN","SYO",;
"SJ0","SJ5","SYU","SYZ","SY0","SYB","ECF","SU0","SU5","SU7","SUS","SUV","WF6"})
AAdd(aTabelas,{"SIGAESP","SX5","SM2","SM4"})
AAdd(aTabelas,{"SIGAESS","SX5","SW2","SYS","SW1","SW7","SW0","EL0","SE4","EC6","ELC","SA6","SYA","SE2","SE5","EE3","SBM","QE6","QED","QEG","QEP",;
"QEK","QEA","QF4","QF5","QEF","QEL","QEI","QE7","QE8","QEH","QEN","QEO","QA6","QA7","QA8","QEY","QEZ","QA2","QEM","QER",;
"QE1","QEQ","QES","SAH","SJ1","SJC","SDC","SDB","SA5","SC1","SC7","SD1","SYC","SJ2","SA3","SA4","SC5","SE1","SF2","SF1",;
"SED","SAD","SB6","SYF","EJW","EJX","EJY","EJZ","EL2","EL1","EEQ","EL3","EL4","EL5","EL6","EL7","EL8","EL9","EYA","EYB",;
"EYC","EYD","EYE"})
AAdd(aTabelas,{"SIGAEST","SX5","SB2","SB3","SB4","SB5","SB6","SB8","SBJ","SBF","SDD","SC1","SAI","SC2","SC4","SC6","SC7","SD1","SD2","SD3","SD4",;
"SG1","SG2","SED","SYD","SJ2","SJ1","SJC","SB1","SBM","QE6","QED","QEG","QEP","QEK","QEA","QF4","QF5","QEF","QEL","QEI",;
"QE7","QE8","QEH","QEN","QEO","QA6","QA7","QA8","QEY","QEZ","QA2","QEM","QER","QE1","QEQ","QES","NNR","SAH","SA2","FRN",;
"SF5","SF4","SC5","SF3","SFB","SFC","SFH","SFF","SFM","SA1","SBE","SDA","SDB","SDC","SM2","SE4","SEC","SI3","CTT","CTD",;
"CTH","SI1","SI2","SI5","SI6","SI7","SI8","SI4","SIC","SID","CT5","SE2","SF1","AC8","AC9","SU5","SM4","SU0","SU7","SUS",;
"SUV","SAN","ACB","ACC","SGK","SGL","SGM","SGN","SG5","SGA","SGT","SGG","SBV","SAS","SAT","SBP","SBQ","SBR","SBS","SBT",;
"SBU","SBW","SBX","SBY","SHK","DCF","SB9","SCN","SBK","SBD","SD8","SCC","DB1","DB2","DB3","SA5","SE1","SE3","SEF","SF9",;
"SN1","SN2","SN3","SN4","SN5","AFN","SDE","SF8","SD7","SCQ","SAD","SFA","STJ","STL","SB7","SCP","SD5","SHD","SHE","SC3",;
"AFM","SGJ","SH1","SCR","DBK","DBL","CB1","CB3","CB5","CBJ","CBF","CBK","CBA","CB4","SF2","SE5","VCB","SA7","SHF","SA3",;
"SA4","SBZ","SC8","SC9","DA0","DA1","SBC","SD9","AF9","SC0","WF6"})
AAdd(aTabelas,{"SIGAFAT","SX5","SB2","SB3","SB4","SB5","SB6","SB8","SBJ","SBE","SBF","SDD","SC1","SC2","SC4","SC6","SC7","SD1","SD2","SD3","SD4",;
"SG1","SG2","SED","SI3","SM2","SYD","SI4","SID","SIC","SJ2","SC3","SBM","SAH","QEK","QE6","QE7","SFZ","SBD","SD8","SCM",;
"SBV","SAS","SAT","NNR","CC2","SC5","SE1","SAO","AC8","AC9","JA2","SA1","SUA","SUC","SF2","DAF","DAD","SF1","SAE","SA7",;
"SB1","VCB","SE2","SA6","SE3","SA4","DA3","SF4","SF3","SFM","SA2","SF7","SFB","SE4","DV9","SI1","SI2","SI5","SI6","SI7",;
"SI8","SM4","SU0","SU5","SU7","SUS","SUV","SAN","CCG","CC3","SAU","MBH","MBI","SUH","DA0","DA1","ACO","ACP","ACQ","ACR",;
"ACS","ACT","ACN","ACX","AI1","AI2","ACY","ACK","ACL","ACM","ACW","SCT","AC1","AC2","SUN","AC4","AC5","AC3","SUM","ADK",;
"ACA","SA3","ACB","ACC","ADL","ADI","ADG","AGT","AGU","AGV","AGX","ACU","ACV","ACH","AD1","AIM","AIN","SL1","SL2","SEF",;
"SE5","SE8","SL4","SAF","SB0","SDB","SLQ","SLF","SC9","SYP","SDC","SA5","SLH","SLG","SFT","FRA","SLW","SLT","MBQ","MBS",;
"MBT","MD1","MD2","SLJ","SB9","MEM","SDA","AI3","AI4","AI5","AI6","AI8","AI9","AI7","AD2","AD3","AD4","AD9","ADC","AD5",;
"AD6","AD7","AD8","AA1","ABC","ADR","ADS","ADT","ADU","AE1","AE2","AE3","AE4","AE5","ADM","ADN","ADO","ADP","ADQ","SKG",;
"SKH","AG3","AG4","ADA","ADB","SBG","SBH","SCJ","SCK","SCL","SC0","SD5","SBK","SD7","SGA","DAK","DAI","SD0","SDX","AF8",;
"SES","AA3","AA4","AAF","AB6","AB7","AB8","DAC","SFC","SF9","SN1","SN2","SN3","SN4","SN5","AFN","CB3","CB4","CBK","AIP",;
"AIR","SB7","SF5","SAD","SBZ","SJ3","SD9","MBR","MBJ","SCQ","AD0"})
AAdd(aTabelas,{"SIGAFIN","SX5","SA2","SC7","SE2","SF1","SA5","SC1","SAD","SB6","AC8","AC9","FIL","SA1","SC5","SD1","SE1","SDE","VCB","SAO","SY6",;
"SA3","SE3","SF5","SJ1","SA6","SM2","CTP","SED","SE7","SU5","SQO","SQB","CT5","SE9","SE0","SEE","SEB","SI1","SI2","SI5",;
"SI6","SI7","SEJ","SE4","SAN","SM4","SU0","SU7","SUS","SUV","SEP","SEO","SEN","SEQ","SEA","FIM","CN5","FR9","FRD","FW1",;
"FW2","FJQ","SI3","SEV","AFR","SEZ","SK1","SE5","SE8","SFQ","SI4","SID","SIC","SEL","SEK","SAQ","SEX","FO0","FO1","FO2",;
"SEF","SE6","FIF","FRV","FJP","FJA","CT2","FWM","AF8","AF9","SER","SEM","FI9","SET","SEU","SEG","SEH","SEI","SI8","FI2",;
"FIG","FRO","FRP","FRQ","FRR","FRS","FL0","FL1","FL2","FL3","FL4","FL5","RD0","FLK","FLG","FLI","FLL","FLQ","FLR","FL6",;
"FL7","FL8","FL9","FLA","FLB","FLV","FV4","FVH","FVJ","FVK","FV0","FV1","FV2","FV5","FV6","FV7","FV8","FV9","FVA","FVB",;
"FVD","FVE","FVI","FVL","FVM","FVN","FX0","FX1","FX2","SF2","SC6","SC9","SB1","SF4","SAH","SD2","SA4","FW8","FW9","FWA",;
"FWB","CTK","SEW","FLF","FIQ","FIR","FIS","FIN","FIO","FIP","SRL","SR4","SLR","WF6"})
AAdd(aTabelas,{"SIGAFIS","SX5","SB2","SB3","SB4","SB5","SB6","SC1","SC2","SC4","SC6","SC7","SD1","SD2","SD3","SD4","SG1","SG2","SED","SI3","SYD",;
"SC3","SBG","SBH","SCK","SJ1","SJC","SAH","QEK","QE6","QE7","SBM","CC2","SC5","SE1","SE4","SF2","SE2","SAO","AC8","AC9",;
"SA5","SF1","SAD","SF4","SF3","CC7","SFM","SA1","SA2","SB1","SB9","SFK","SF6","SI1","SI2","SI5","SI6","SI7","SI8","SFA",;
"SF9","SFN","SFO","SF7","SFB","SM2","SM4","SU0","SU5","SU7","SUS","SUV","SFS","LA1","CDZ","CCU","CDU","CLL","CLK","F0R",;
"CGA","CGB","CC6","CC8","CC9","CCA","CCB","CCC","CCD","CC4","CC5","CCE","CCF","CCH","CDO","CC1","CDN","CE5","CE6","CE7",;
"CCY","CCW","CE0","CKN","CCZ","CG1","CGE","CGG","CF9","CDA","SFT","VCB","F0S","CFA","CFB","F0L","SC9","SE5","SF5","SYA",;
"SN1","SN3","SN4","CDM","SDS","B1","CDW","CFD","CLJ","DT6","CDH","SGH","F0V","F0U","SIC","SF8","SWN","SFI","SFU","SFX",;
"CG7","CD5","CDT","SA8"})
AAdd(aTabelas,{"SIGAFRT","SX5","SL1","SL2","SL4","SLF","SLG","SLI","SLK","SA1","SA3","SA6","SAE","SAF","SAH","SBI","SFI","MD3","MD4","MD5","SB0",;
"SB1","SE4","SED","SF4","SF7","SFC","SLH","SF2","SD2","SB2","SE1","SE3","SE5","SE8","SEF","SBF","SDB","SB8","SYD","EL0"})
AAdd(aTabelas,{"SIGAGAC","SX5","JM0","JM1","JM2","JM3","JM4","JM5","JM6","JM8","JM9","JMC","JMD","JMF","JMH","JMI","JMJ","JMR","JMS","SA1","SE1",;
"SED","JA3","JAG","SA5","SC7","SE2","SF1","AC8","AC9","JMQ","JMO","JML","JMP","JMN","JMM","SE5","SA3","SA6","SM2","SEA",;
"SE8","SE3","SH7","SH9","JMT","JMU","JDI","JA1","AI3","AI4","AI5","AI6","AI7"})
AAdd(aTabelas,{"SIGAGAV","SX5","SM2","SED","FS0","SE4","FSE","FSJ","FSV","FSF","FSA","ACY","SA1","SA2","SC7","SE2","SF1","AC8","AC9","SU5","SQO",;
"SQB","FSK","FT4","FSM","ACJ","FTA","FSY","FSZ","FT8","FSG","FTG","FSQ","FSC","FT3","FS3","FS1","FSO","FTU","FSN","FTN",;
"FS5","FT5"})
AAdd(aTabelas,{"SIGAGCP","SX5","SAH","QEK","QE6","QE7","SJ1","SJC","SDC","SDB","SBM","QED","QEG","QEP","QEA","QF4","QF5","QEF","QEL","QEI","QE8",;
"QEH","QEN","QEO","QA6","QA7","QA8","QEY","QEZ","QA2","QEM","QER","QE1","QEQ","QES","NNR","SA5","SB2","SB3","SB4","SB5",;
"SB6","SB8","SBJ","SBF","SDD","SC1","SC2","SC4","SC6","SC7","SD1","SD2","SD3","SD4","SG1","SG2","SI1","SI3","SYD","SI4",;
"SIC","SID","SJ2","SBG","SBS","CC2","SA1","SE2","SF1","SED","SE4","SAD","AC8","AC9","SA2","SF4","SC5","SF3","SFB","SFC",;
"SFH","SFF","SFM","SB1","SM2","SI2","SI5","SI6","SI7","SI8","SM4","SU0","SU5","SU7","SUS","SUV","SAN","ACB","ACC","CN1",;
"CO0","COD","COZ","CP5","CP0","CP1","COV","COX","CPB","CP8","CP9","COT","COU","CPA","CO6","COR","COS","SAI","SY1","SAK",;
"SAL","SAJ","DBL","SY3","SY2","SCQ","AFN","SCY","COM","CON","COO","COP","COQ","COY","CO2","CP4","CO1","CO3","CN9","CNB",;
"CPV","CNL","CO7","CO9","COW","CP2","CP3","CP7","CPD","CPE","CPH","CPI","CX0","CX1","CX2","CX3","SCR","SC8","SF7","SW2",;
"CNA","CNF","CNC","CNW","CNV","CNX","CND","CNE","SCS","DBK","SDA","SB9","SDE","SE1","SE3","SEF","SF9","SN1","SN2","SN3",;
"SN4","SN5","SD5","SDS","SF2","SE5","VCB","SA7","SF5","SCP"})
AAdd(aTabelas,{"SIGAGCT","SX5","QE6","SAH","QE7","QEK","SB1","SBM","SB2","SB9","SC1","SC2","SC4","SC6","SC7","SC3","SD1","SD2","SD3","SG1","SG2",;
"SBG","SBH","SCK","SB3","SB4","SA5","SB5","SF4","SFC","SDW","SE4","SED","SM2","SE2","CN9","CN7","CN3","CN6","CTT","CTD",;
"CTH","SUC","SC5","SF1","SF2","SAD","AH1","SA2","CN1","CNA","CNL","CN8","CNP","CN5","CNJ","CNK","CN2","CN0","SM4","SU0",;
"SU5","SU7","SUS","SUV","SAN","AC9","ACB","ACC","CN4","CNB","CNC","CND","CNE","CNF","CNG","CNH","CNI","SCR","DBM","SAK",;
"SAL","DBL","SY3","SY2","SAI","SFH","SCQ","SY1","AFN","SCY","SC8","SF7","SW2","SDA","SDE","SB8","SBJ","SE1","SE3","SEF",;
"SF3","SI1","SI2","SI5","SI6","SI7","SF9","SN1","SN2","SN3","SN4","SN5","SD5","SDS","SA7","SBE","SBF","SC0","SBK","SD7",;
"SDC","SGA","SDB","DAK","DAI","SC9","ACK","ACL","ACM","ACN","SA1","SE5","AF8","SES","SA4","DA3","AA3","AA4","AAF","AB6",;
"AB7","AB8","DAC"})
AAdd(aTabelas,{"SIGAGE","SX5","JAE","JAL","JAM","JAN","JDG","JDH","JAP","JA6","JA7","JAI","JA8","JA9","JAC","JAD","JAK","JAO","JA1","JAH","JAR",;
"JDL","JAF","JA3","JA4","JA5","JAQ","JAX","SE1","SA1","SE5","SA6","SED","SRA","JDI","JAV","JAA","JA2","JB4","JB7","JCA",;
"JCC","JB5","JBO","JAY","JAS","JBE","JCO","JC7","JBM","JCE","SRB","SPA","SRW","SRJ","SR6","SRF","SAN","JAG","JAW","JB1",;
"JBZ","JC8","JBX","JDE","JDF","JDK","JCF","JBT","JBV","JAJ","JBQ","JD9","JDA","JBK","JDS","JBN","JBS","JCH","JAT","JAU",;
"JBL","JBR","JBU","JC6","JC9","JCG","JDC","JBC","JBD","JCN","JD2","JBY","JDO","JDN","JB3","JAZ","JDB","JD7","JCX","JCY",;
"JCM","JCV","JCW","JD8","JCR","JCS","JCT","JBH","JD1","JCL","JBW","JCI","SRV","JCJ","JDJ","JHO","JHP","JHQ","JI7","JC2",;
"JC1","JC4","JC5","JAB","TMR","JCP","JCQ","JDD","JBB","JBJ","JBI","JCU","JBF","JBG","JC3","SB1","SAH","JD5","JD6","JB2",;
"JB6","JB8","JB9","JCD","JCB","JD3","JD4","JBA","SA3","SE2","SI1","SI2","SI3","SI5","SI6","SI7","SM2","SEV","SEA","SE8",;
"SE3","SI4","SIC","SID","SES","SE4","SF2","SF4","SF1","SD2","SD1","JF6","JF7","JCK","JIG","JIE","JEG","SCP","JJ1","JJ2",;
"JJ3","JJ4","JJ5","SC5","SC6","JHC","JHD","JHE","JHF","JHG","JHH","JHI","JHJ","JHN","JGL","JGM","FJA","HJA","SJB","EJC",;
"HJC","GJD","EJA","DJB","VJB","NJA","O"})
AAdd(aTabelas,{"SIGAGFE","SX5","GWP","N","GW3"})
AAdd(aTabelas,{"SIGAGPE","SX5","RCD","SQB","SRA","SR7","SRS","TOA","RDB","DCI","TMO","TNB","RAL","TO0","RB5","DC6","TAK","RB7","RB4","TMV","TCB",;
"TNO","TNC","RC6","TNF","TAN","AA1","SRJ","SQ3","SA6","CTT","SI3","RCE","SI5","SI1","SI4","SIC","SID","CT5","RCT","LA1",;
"SRW","RF1","RCJ","RFQ","RCH","RCF","RCG","RG5","RG6","RCM","SRV","RCB","RCC","RCA","RC2","RC3","SRY","SRM","SRB","SPA",;
"SR9","SR8","SR3","RCP","SR6","SRF","TLI","SRC","SRD","SRE","SRG","SRH","SRI","SRK","SRL","SRO","SRX","SRZ","SRQ","SR0",;
"SR1","SR2","SR4","SR5","RGE","RB8","RGB","RCK","RG1","RG7","SRR","SPJ","RF2","RF4","RF5","RF8","RF9","SP3","SPF","SJQ",;
"SJS","RHK","RHL","RHM","RHN","RHR","RFO","RFP","SRN","RG2","RFC","TM4","RC8","TMA","TMB","RC9","RC7","TMK","TML","SEF",;
"SE5","RFY","SRT","RHT","RC0","RC1","SRU","SI2","SI6","SI7","CT2","CT6","RCZ","RCU","SU0","SU5","SU7","SUS","SUV","WF6",;
"DE9","DE0","DE1","DE2","DED","DEE","DEC","DDE","E","RH3"})
AAdd(aTabelas,{"SIGAGPR","SX5","SKC","SKD","SKE","SKF","SKG","SKH","SKI","SKJ","SKK","SKL","SKM","SKN","SKO","SKP","SKQ","SKR","SKS","SKT","SKU",;
"SA1","SA2","SA3","AC4","SU5","SU2","WF6"})
AAdd(aTabelas,{"SIGAGSP","SX5","SA5","SB2","SB3","SB4","SB5","SB6","SB8","SBJ","SBF","SDD","SC1","SC2","SC4","SC6","SC7","SD1","SD2","SD3","SD4",;
"SG1","SG2","SI1","SI3","SYD","SI4","SIC","SID","SJ2","SBG","SBS","SAH","QEK","QE6","QE7","SJ1","SJC","SDC","SDB","SBM",;
"QED","QEG","QEP","QEA","QF4","QF5","QEF","QEL","QEI","QE8","QEH","QEN","QEO","QA6","QA7","QA8","QEY","QEZ","QA2","QEM",;
"QER","QE1","QEQ","QES","SA2","SF4","SC5","SF3","SAI","SY1","SAK","SAL","SAJ","N10","N11","N09","SN1","SN2","SN3","SN4",;
"SN5","SM2","SE4","AC8","AC9","SA1","SA3","SA4","SA6","SAO","SE1","SET","VCB","SE2","SF1","SED","SAD","N12","SRA","NI1",;
"NI7","NI3","NI6","NI5","N02","N01","N03","N06","N08","N07","SB1","SY3","SY2","SFH","SCQ","AFN","N51","N13","SC8","SCE",;
"SCR","SF7","SW2","N55","SI2","SE3","SEF","SI5","SI6","SI7","SF9","SD5","SE8","SEV","AFR","SEZ","N04","SE5","AF8","AF9",;
"NI2","N54","N18","N19","N1A","N1B","N1C","N1D","N1E","N1F","N1G","N53","N52","SF2","N14","N15","N16","N17","N05","N3B",;
"N36","N31","N32","N37","N33","N39","N3A","N3D","N3C","N3F","N34","N35","N38","N3E","N30","N20","N21","SRB","SPA","SR9",;
"SRJ","N22","N40","N41","N45","N43","N42","N60","N68","N69","N6K","N6D","N6B","N6C","N66","N67","N6A","N61","N62","N6F",;
"N6G","N6I","N6J","N6L","N6H","NM4","NM5","NM3","NM1","NM2","NM6"})
AAdd(aTabelas,{"SIGAHSP","SX5","GM8","SCK","GCY","GT9","GTK","GT7","GTE","GM6","GSA","GB4","GBH","GSB","GAV","GCZ","GD4","GM9","GMA","GMJ","GML",;
"GMM","GSE","GSD","GMN","QI2","GSC","GSF","GM5","GM4","GM3","GA9","GBJ","GA7","GM7","GDZ","GE4","GT6","GT5","GCS","GM1",;
"GCW","GD0","GD1","GP9","GBW","GBY","GGP","GFS","GFT","GCI","GCJ","GCG","GCH","GCO","GGJ","GND","GNE","GGO","GPA","GPB",;
"GPC","GPD","GDH","GPE","GBT","GDO","GDP","GDR","GDS","GDT","GDY","GAI","GAJ","GO0","GO1","GAT","GEY","GEZ","SA1","SC5",;
"SC6","SC9","SF2","SD2","GGK","GCM","GA3","GCA","GCB","SB1","GBI","GAS","GA8","SBM","GAZ","GAQ","GA1","GA2","GAA","GDC",;
"GDD","GHZ","GHY","GAB","GCU","GCT","GDL","SL1","SL2","SL4","GB3","SE5","SA6","SL5","SEF","SE3","SE1","SF4","SB2","SE8",;
"SB0","SBF","SDB","SB8","SLG","SLF","GDX","GE7","GD7","SRA","GEU","GN3","GN4","GDV","GN8","GNB","GAY","GN6","GE5","GE6",;
"GF0","GF5","GF6","GF7","GE0","GDM","GG9","GA4","GBD","GBE","GAC","GFF","GFG","GFH","GFI","GAF","GAG","GB8","GF2","SAH",;
"QEK","QE6","QE7","SJ1","SJC","GAN","GA0","SD1","SF3","SB6","SED","SA5","GAW","SB3","SB4","SB5","SBJ","SDD","SC1","SC2",;
"SC4","SC7","SD3","SD4","SG1","SG2","SI1","SI3","SYD","SI4","SIC","SID","SJ2","SBG","GAP","GFE","GH1","GHD","GH3","GHF",;
"GH4","GHG","GH2","GH5","GH6","GH8","GH9","GHA","GHE","GHB","GH7","GMS","GMV","GK7","GK8","G05","G07","G15","G16","G17",;
"G18","G24","GN1","GHN","GHO","GFW","GFX","GFZ","GFY","GHT","GHU","GHV","GHX","GHS","GNP","GNS","GGE","GGN","GGG","GGS",;
"GGT","GHJ","GG0","GG1","GG2","GG3","GG4","GG8","GEV","GM0","GM2","GMB","GMC","CTT","GAE","GFL","GFM","GDW","GES","GF3",;
"SE2","SF1","SE4","SAD","GAM","GDI","GER","ST9","GFJ","GGY","GHW","GSI","GE9","GEA","GEB","GET","GB1","GE8","GF8","GEH",;
"GEJ","GEO","GD5","GD6","GO5","GO6","GO7","GE2","GE3","GP0","GP1","GP2","GP3","GP4","GP5","GP6","GP7","GP8","GD9","GDA",;
"GD2","GD3","GD8","GC6","GDB","GDF","GFR","SA2","GB2","SCJ","GC7","GC8","GED","GB5"})
AAdd(aTabelas,{"SIGAICE","SX5","IC1","IC2","IC3","IC4","QAC","QAD","QAA","QAB","QID","QIB","QIC","IC6","ICC","ICD","IC5","IC7","IC8","IC9","ICA",;
"ICB","AA1","ICH","ICI","ICJ","ICK","ICL","QI0","QI1","QI2","QI3","QI4","QI5","QI7","QI8","QI9","QIA","QDH","QA4","QIF"})
AAdd(aTabelas,{"SIGAJURI","SX5","NVE","NTA","NT9","NT2","NT3","NT4","NYP","RD0","NUH"})
AAdd(aTabelas,{"SIGALOJA","SX5","MDO","MDP","MDQ","SE2","SBM","SA1","SA3","SA6","SD1","SE1","SED","VCB","SAO","AC8","AC9","SB2","SA5","SB0","SC1",;
"SC7","SLH","NNR","ACU","ACV","SE3","SB1","SLK","SB5","SA4","SE4","DCF","SE8","SAE","MDE","MBQ","MDT","MDU","MBH","MBI",;
"MBF","MBL","SUH","AC3","MFP","MFR","MFQ","MG3","MDV","MDX","ME5","ME3","MEF","MED","ME1","ME2","MEE","MEH","ME7","ME8",;
"ME4","SLF","SLG","SD2","SL6","SBQ","SA2","SE5","SEF","SL5","FRA","SLW","SLT","MB2","MB3","MB4","MB5","MB6","MB7","MB8",;
"MEI","MEJ","SFI","SF2","SF4","SF3","SFT","SL1","SL2","SL4","SF1","SL3","SM5","SEV","SEZ","SEI","SEH","DA0","DA1","ACO",;
"ACP","ACQ","ACR","MBS","MBT","MD1","MD2","SAF","SBF","SDB","SB8","SLQ","SLR","SDC","MBO","MBP","MBN","SC9","SYP","SF5",;
"SC0","SLJ","MBR","MEM","SF7","SI5","SM2","SEA","SI1","SI2","SI3","SI6","SI7","SAH","QEK","QE6","QE7","SG1","SY1","SAL",;
"SCR","SW2","SI8","SD5","SB6","SF9","SN1","SN2","SN3","SN4","SN5","SDA","SB9","SD3","SD7","SB7","SB4","SBV","SAN","SLM",;
"SLN","SC2","SD4","SBE","SBJ","SBC","MD5","MD3","MD4","MD8","MDC","MDR","MA5","MA6","MA7","MA8","MA9","MAA","MAB","MAC",;
"MAD","MAE","MAR","AIH","AII","MFE","MFF","MFG","MFH","MFO","MFI","MFK","SC5","SC6","MFN","MFM","MFJ","MGM","MGO","MGN",;
"MGR","MGQ","MGU","MGS","MGT","MGY","SFA","MBJ","SB3","SAD","SLL","SYD","EL0","SBD","SD8","AF9","WF6","MBM","MBK"})
AAdd(aTabelas,{"SIGAMDT","SX5","SH7","SH1","SRA","SRB","SPA","SR9","SRF","SRC","SRD","SRG","SR4","SRI","SRK","SRL","SRO","SRR","SR5","SR0","SR1",;
"SR2","SRH","SRS","SRE","SRJ","SRM","SRV","SRX","SRZ","SR8","SRW","SI3","SA2","SE2","SF1","SA5","SC1","SAD","SR3","SYA",;
"SC7","SB6","SYP","SB1","SB9","SC2","SC4","SC6","SC3","SB2","SG1","SG2","SB3","SB4","SAH","SD1","SD2","SBG","SBH","SB5",;
"SCK","VE1","SC5","SE1","SED","SAO","AC8","AC9","ACC","SQ3","SR7","CTT","SR6","TLG","TMR","TO0","TO1","TO2","TO3","TO4",;
"TNX","TMZ","TNW","TK0","TMG","TMH","TM9","TMS","TNP","TO7","TO8","TOE","TOK","TK9","TKA","TIL","TOB","TOC","SN1","SN2",;
"SN3","SN4","SN5","SI1","SI2","SI5","SI6","SI7","SI8","SI9","SM2","SN6","SFA","SF9","TAF","TN0","TNE","TU0","TU1","TN5",;
"TN6","TM0","TMK","TML","TMJ","TMD","TN3","TNF","TLX","TLY","TKE","TPR","TPS","TPJ","TPL","TPY","ST6","ST9","STI","STR",;
"ST0","ST7","TPE","SHB","ST1","TP9","STB","STC","STF","TPA","TPC","TPX","TP1","TP2","ST2","STG","STK","ST4","STD","STE",;
"STJ","STP","TP5","TPF","TPG","TPH","TPM","ST5","STH","STM","ST8","STN","TP7","TP8","SH9","ST3","STA","STL","SD4","STS",;
"SD3","SH4","TPD","TPQ","STY","STZ","TN7","TJB","TLK","TKD","TMA","TN2","TO9","TNJ","TNI","TNB","TOH","TIK","TMQ","TMU",;
"TM8","TM4","TM6","TN9","TMO","TN8","TMB","TON","TM5","TMY","TMW","TN4","TN1","TMN","TMV","TM1","TM3","TL6","TL9","TL7",;
"TL8","TLE","TMF","TMI","TNA","TNY","TNC","TMT","TME","TOG","TL5","TMX","TMC","TOF","TK7","TKL","TKM","TKN","TKO","TKU",;
"TKQ","TKR","TKS","TLA","TK4","TLB","TK6","TLD","TK5","TLC","TJK","TJL","TJX","TJJ","TJM","TJN","TJO","TJP","TJQ","TJR",;
"TNN","TNO","TNQ","TNU","TNS","TND","TNR","TNZ","TNV","TNT","TLH","TLI","TNG","TNH","TNL","TOJ","TOI","TO6","TO5","TJ0",;
"SA1","TOX","TOZ","TJG","TJA","TLS","TLQ","TLZ","TLL","TLM","TLP","TLR","TLN","TLO","QAA","QAD","QAC","TA0","TA1","TA2",;
"TAC","TOA","TIB","TID","TJ4","TJ2","TJ3","TJ1","TJ5","TM7","STO","TNM","TM2","TZ1","TZ2","TZ3","TZ4","TZ5","TZ6","TZ7",;
"TJC","SU0","SU5","SU7","SUS","SUV","WF6","TQC","TQD"})
AAdd(aTabelas,{"SIGAMNT","SX5","SH7","SED","TPD","SQA","SAN","SAI","QP6","TPE","TPI","TPP","TPW","TPQ","STY","ST0","STN","STP","TPS","TPY","TPZ",;
"SG7","SG8","SI3","QIA","QI2","SRA","SAH","SHB","SDC","SB1","SB9","SC1","SC2","SC4","SC6","SC7","SC3","SB2","SG1","SG2",;
"SB3","SA5","SB4","SD1","SD2","SBG","SBH","SB5","SCK","VE1","SYP","NNR","SA2","SE2","SF1","SAD","SA1","SYA","SE4","SB6",;
"TPO","SGA","SH4","SH1","SH2","SH9","SN1","SN2","SN3","SN4","SN5","SI1","SI2","SI5","SI6","SI7","SI8","SI9","SM2","SN6",;
"SFA","SF9","SRB","SPA","SR9","SRF","SRC","SRD","SRG","SR4","SRI","SRK","SRL","SRO","SRR","SR5","SR0","SR1","SR2","SRH",;
"SRS","SRW","SRJ","SRX","SR6","SR3","TSK","TSL","TAF","ST9","STQ","STC","STJ","TPC","ST4","STF","CTT","TPR","TPJ","TPL",;
"ST6","STI","STR","TQR","ST7","TQY","ST1","TP9","TPB","TPK","STB","TS3","TRW","STZ","TPN","TPA","TPX","TP1","TP2","ST5",;
"STG","STA","STH","STK","TT9","STL","STM","STT","STV","STX","TP5","TPG","TPH","TPM","ST2","TP4","TP6","STD","STE","TPF",;
"ST8","TQ5","TP3","TP7","TP8","TTB","TTC","TTD","TTE","TTG","TTF","TQB","SC5","STO","TQA","STW","ST3","SD4","STS","TQ0",;
"TQ1","SD3","TPU","TPV","TQ3","TQ4","SCP","TT1","TT2","TT3","TT4","TT5","TPT","TP0","TQW","TQ9","TT0","TU0","TU1","TTJ",;
"TTL","STU","TQ6","TZ1","TZ2","TZ3","TZ4","TZ5","TZ6","TZ7","TQN","TRX","TS2","TRH","TCJ","TQ2","TQC","TQD","TUA","TUB"})
AAdd(aTabelas,{"SIGAOFI","SX5","VEG","VOV","AFR","DC8","CT1","VVO","VOS","SF5","DAK","AF8","SCV","DA0","DA1","ACO","ACQ","SC0","ACR","AB8","VG6",;
"VH9","SAJ","VI5","VE1","SA1","VEA","VF7","VF8","VF9","VFC","VFD","VG3","VG4","VG8","VG9","VGB","VH4","VH5","VI4","VI7",;
"VOM","VS5","VOQ","VIM","SE8","SC5","SE1","SD1","SED","SAO","SAN","AC8","AC9","SYP","NNR","SA2","SE2","SF1","SA5","SC1",;
"SAD","SR3","SYA","SC7","SB6","VS0","SF4","SC6","SD2","SF3","SD3","VVK","VEI","AA1","AA2","SRJ","VAM","VER","VAP","VS2",;
"SI3","SEN","SEQ","SEO","SEP","SE4","VSA","VSB","SM2","SA6","SF2","VVC","VVQ","VVB","SI7","VVE","VV8","VV7","VV2","VVX",;
"VVR","QEY","VVP","VVM","VVL","VO5","VF0","VF1","VF2","VV1","VOG","VOH","VOD","VON","VSN","VOK","VOL","VO6","VO7","VO8",;
"VO9","SB1","SAH","VOI","VOJ","SBE","VOW","VOX","VOC","VF5","VE0","VFA","SY6","VZC","VH6","VH2","VH3","VH0","VH1","VH7",;
"VG1","VE4","VGD","VEB","VEL","VG0","VC0","VCA","VC5","VCB","VAQ","VSO","VSP","VO1","VZB","VOE","VFB","VZ9","VSL","VOF",;
"VOP","VOU","VSM","VO2","VO4","VS8","VO3","SB0","SB9","VSJ","VF6","SD7","SD5","SB8","VOZ","SES","SE3","SE5","VS9","VGC",;
"SBL","AFT","VF3","VPE","VPF","VPG","SB2","SB5","SB7","VIV","VCF"})
AAdd(aTabelas,{"SIGAOMS","SX5","SA5","SC7","SE2","SF1","SED","SE4","SAD","SC5","SD1","SE1","SB2","SB3","SB4","SB5","SB6","SB8","SBJ","SBE","SBF",;
"SDD","SC1","SC2","SC4","SC6","SD2","SD3","SD4","SG1","SG2","SI3","SM2","SYD","SI4","SID","SIC","SJ2","SC3","NNR","SBM",;
"SAH","QEK","QE6","QE7","SFZ","SBD","SD8","SCM","SBV","SA7","SA1","SB1","VCB","SA6","SE3","SA4","SF4","SF3","SFM","SA2",;
"SF7","SFB","SI1","SI2","SI5","SI6","SI7","SI8","SM4","SU0","SU5","SU7","SUS","SUV","SAN","AC9","ACB","ACC","DA0","DA1",;
"ACO","ACP","ACQ","ACR","ACS","ACT","ACN","ACX","ACK","ACL","ACY","ACM","DA5","DA6","DA7","DA8","DA3","DA9","DAA","DAB",;
"DAC","DC1","DC4","DA4","DAN","DAK","DAI","DAU","DCK","DB0","DAD","DAE","DAF","DAG","SB9","SC0","SD5","SBK","SD7","SDC",;
"SGA","SDA","SDB","ADA","SC9","SE5","DBN","DC5","SF2","AA3","AA4","AAF","AB6","AB7","AB8","DAH","DAP","DAM","SEL","SEF",;
"SF9","SN1","SN2","SN3","SN4","SN5","AFN","QEL","QEP","QEY","QEZ","SF8","SDE","QEA","SF5","STJ","STA","AF8","AF9","AFC",;
"SB7","SA3","SJ3","DTY","SCQ","WF6"})
AAdd(aTabelas,{"SIGAORG","SX5","CTT","RBG","RBM","RBJ","RBF","RB6","SRJ","L","SRA","RA2","RA4","SR7","RAF","SRF","SQ1","RA1","RD0","RE8","SQ3",;
"F","RBS","SQB","RCL","RDK","RBU","BU","RH3"})
AAdd(aTabelas,{"SIGAPCO","SX5","AK2","AKK","AKQ","ALM","ALL","AM2","ALV","ALX","ALY","AK1","AK3","AKR","ALI","AMU","AL6","AL7","AMX","AMY","AMV",;
"ALU","ALS","ALO","ALR","ALN","AM5","ALP","AM8","AM9","AM3","AMA","AM7","ALQ","ALT","AM4"})
AAdd(aTabelas,{"SIGAPCP","SX5","SB2","SB4","SB6","SB8","SBJ","SBF","SDD","SC1","SAI","SC2","SC4","SC6","SC7","SD1","SD2","SD3","SD4","SG1","SG2",;
"SB3","SB5","SA5","SI1","SI3","SYD","SI4","SID","SIC","SJ1","SJC","SB1","NNR","SBM","SBZ","SAH","QEK","QE6","QE7","SHB",;
"SH3","SG8","SG9","SGC","SGD","SGF","SH6","SH7","SHI","SH1","SH2","SH9","SH4","SOO","SOP","CZB","CZC","CZF","SBE","SDA",;
"SDB","SDC","SF5","CTT","CTD","CTH","SI2","SI5","SI6","SI7","SI8","SM2","SM4","SU0","SU5","SU7","SUS","SUV","SAN","SGK",;
"SGL","SGM","SGN","SG5","SGA","SGT","SGG","SBV","SAS","SAT","SBP","SBQ","SBR","SBS","SBT","SBU","SBW","SBX","SBY","SB9",;
"SBK","SBD","SD8","SD7","SC5","SE1","SHD","SHE","SC3","SGJ","DCF","SD5","SOU","SOQ","SOR","SF4","CB7","CB8","CBJ","CB1",;
"CB3","CB4","CB5","CBI","CBF","CBK","SOD","SOE","SOF","CZG","SA7","SAD","SA2","SHF","SOT","SC9","SBC","SB7","SA1","SC0",;
"SE2","VCB","WF6"})
AAdd(aTabelas,{"SIGAPEC","SX5","VAP","VS2","SB1","SBM","VPD","VPE","VPF","VPG","SB2","SB5","SB7","SA1","SE1","SA6","SE4","SF2","VCF"})
AAdd(aTabelas,{"SIGAPFS","SX5","NVE","NUI","NWC","NUJ","NUK","NVF","NUU","NV1","NUW","NV2","NV0","NT7","NUH","NU9","NUD","NUA","NUB","NUC","SU5",;
"NT0","NTJ","NUT","NT1","NWE","NTR","NVN","NTW","NT5","ACY","NW2","NW3","NRB","CTT","NS7","NW9","NRL","NRU","NXK","NXL",;
"NSE","NVQ","NVP","NR1","NR4","NR5","NR2","NR3","NWM","NWN","NV4","NTP","NTN","NSA","NVX","NSB","NRD","NSC","NRF","NS9",;
"NSD","NTV","NTU","NTT","NRE","NRC","NRG","NUO","NRK","NRH","NRM","NR9","NRA","NTH","NRI","NR7","NRW","NRV","NRY","NRZ",;
"NS0","NS3","NS2","NS1","NS4","NRX","NTQ","NR6","SA6","SE4","CTP","NXQ","CTO","SED","NRN","RD0","NUR","NUS","NSS","NVM",;
"NSO","NRJ","NZO","NWF","NVY","NVZ","SF2","SD2","SF3","NX5","NX6","NX7","NX3","NX9","NVV","NVW","NWD","NW4","NXA","NXB",;
"NXC","NXD","NXE","NXF","NX0","NX8","NX1","NX2","NXG","NX4","NXH","NXI","NXJ","SE1","NUE","NW0","NW1","NUF","NUG","NTO",;
"NTM","NTL","NUX","NUY","NTY","NTZ"})
AAdd(aTabelas,{"SIGAPHOTO","SX5","MD1","MD2","MD5","MD6","MD7","MD8","MD9","MD3","MD4","DA0","DA1","ACO","ACP","ACQ","ACR","SLF","SLG","SD2","SL6",;
"SA1","SE1","SE5","SEF","SAE","SA3","SA2","SA4","SL1","SL2","SE3","SF4","SB1","SB2","SE8","SB0","SBF","SD8","SB8","SA6",;
"SG1","SL4","SAF","SC9","SYP","SDB","SDC","SF2","SLQ","SLR","SD1","SED","VC8","SAO","AC8","AC9","SA7","SB5","SBJ","SB9",;
"SBE","SC0","SC5","SC6","SD5","SBK","SD7","SGA","SM2","SDA","SBM","DAK","DAI","AF8","SES","SB3","SI1","SI2","SI5","SI6",;
"SI7","SF3","AA3","AA4","AAF","AB6","AB7","AB8","SFC","SF7","SE4","SF1","SA5","SC7","SE2","SC1","SY1","SAL","SCR","SW2",;
"SB7","SI8","SB6","SF9","SN1","SN2","SN3","SN4","SN5","SD3","SLM","SLN","SEA","VCB","SI3","SF5","SLJ","SC2","SD4","SAD",;
"SFA","SEH","SL3","SM4","SU0","SU5","SU7","SUS","SUV","SLH","SAH","SLK","SL5","SBD","AF9","SF8","SFI"})
AAdd(aTabelas,{"SIGAPLS","SX5","BA0","B47","B53","B68","B70","B71","B72","B73","BD6","BYS"})
AAdd(aTabelas,{"SIGAPMS","SX5","SA5","SB2","SB3","SB4","SB5","SB6","SB8","SBJ","SBF","SDD","SC1","SC2","SC4","SC6","SC7","SD1","SD2","SD3","SD4",;
"SG1","SG2","SI1","SI3","SYD","SI4","SIC","SID","SJ2","SBG","SBS","SAH","QEK","QE6","QE7","SJ1","SJC","SBM","SB1","SCK",;
"SA2","SA4","SAD","SE2","SE4","SED","SF1","AC8","AC9","SC5","SE1","SAO","SU5","AE1","AE2","AE3","AE4","AE5","AE9","AEA",;
"SH7","AED","AFY","AN1","AE8","SRV","AE7","ACB","ACC","SF4","SF3","SF5","SM2","SAN","AJM","AJN","AN4","ANA","AF1","AF2",;
"AF3","AF4","AF5","AF7","SA1","AJ1","AJ2","AJ3","AF8","AF9","AFA","AFB","AFC","AFD","AFE","AFF","AFG","AFH","AFI","AFJ",;
"AFK","AFL","AFM","AFN","AFP","AFQ","AFR","AFS","AFT","SE5","AJ4","AJ5","AJ6","SC3","SCP","AJ7","SF2","AJ8","AJC","AFW",;
"AFU","AFX","SA6","SI2","SI5","SI6","SI7","VCB","SEV","SA3","SY3","SY2","SAI","SFH","SCQ","SY1","SA7","SB9","SBE","SC0",;
"SD5","SBK","SD7","SDC","SGA","SDA","SDB","SDE","SE3","SEF","SF9","SN1","SN2","SN3","SN4","SN5","SHD","SHE","SH6","AI3",;
"AI4","AI5","AI6","AI8","AI9","AI7","AJD","AJK","ANB","ANC","SC9","SBD","SD8","WF6"})
AAdd(aTabelas,{"SIGAPON","SX5","SRA","SA6","SR3","SR7","SR9","SRC","SRX","SP2","SPF","SPE","SR8","SPT","RF0","SI3","SI1","SI7","CTT","SR6","SRJ",;
"SPW","SPY","SPZ","SPD","SP9","SP3","SP6","SP0","SPA","SPJ","SP4","SPM","SP1","SRV","SPO","RFD","SP8","SPK","SPC","SP5",;
"SPB","SPI","RS4","SPG","SPH","SPN","SPL","SRE","SR0","SR1","SR2","SR4","SRB","SRD","SRF","SRG","SRH","SRI","SRK","SRL",;
"SRO","SRR","SRS","SRW","RFE","RFF","RA1","RA2","RA3","RA4","RFG","SPU","SPV","SPX","SU0","SU5","SU7","SUS","SUV","WF6"})
AAdd(aTabelas,{"SIGAPPAP","SX5","QK1","QK2","QP6","QP7","QQK","QL4","SG2","SB1","QKK","QKO","QKZ","QKE","QAA","QAC","QAD","SAH","SA1","QAL","QKG",;
"QKP","QK5","QK6","QK7","QK8","QKF","QKN","QKL","QKM","QM4","QM5","QM2","QK9","QKA","QKB","QKD","QKC","QK3","QK4","QKI",;
"QKJ","QMU","QKH","QL0","QL1","QL2","QL3","QKQ","QKR","QKS","QKT","QKU","QKV","QKW","QKX","QKY"})
AAdd(aTabelas,{"SIGAQAD","SX5","QAA","QAB","QUN","QAC","QAD","SA2","SED","SI3","AC8","AC9","QU5","QUI","QU2","QU3","QU4","QUB","QUE","QUD","QUA",;
"QIA","QA4","SAH","QI2","QUM","QUC","QUF","QUG","QUH","WF6"})
AAdd(aTabelas,{"SIGAQDO","SX5","QAD","QDT","QDZ","QAC","QAA","QAB","QDR","QD3","QDK","QD2","QDD","QDC","QAK","QAG","QAH","QAI","QDH","QDB","QD4",;
"QD5","QD6","QD0","QA2","QDG","QD1","QDE","QD7","QDA","QDN","QA4","QDJ","QD9","QDP","QDS","QDU","QD8","QDM","QDL","QAE",;
"QAF","QAJ","WF6"})
AAdd(aTabelas,{"SIGAQIE","SX5","SA1","SED","SAO","AC8","AC9","SA2","SC7","SA5","SC1","SAD","SYA","SE2","SF1","SB6","SU0","SU5","SU7","SUS","SUV",;
"QF4","QF5","SB5","SA7","SB1","VCB","QE3","QE6","QE4","QEA","NNR","QE1","QE2","QE7","QE8","QA2","QER","QEE","SBF","SD4",;
"SDA","SDB","SDC","SF5","QF2","QF3","SAG","QE9","QEU","QP2","QP9","QPU","QEG","SAH","QEK","QA4","QAA","QAB","SI3","QAD",;
"QAC","QE5","QEL","QEM","QES","QEQ","QET","QEB","QEC","QEV","QEW","QE0","QM1","QEH","QEY","QEN","QEI","QEO","QD0","QD1",;
"QDG","QDJ","QDH","QA1","QF6","QEZ","QEF","QEX","QQB","QA6","QA7","QEP","SRA","SF4","QED","SC2","QF7","QM2","SB2","SD1",;
"SD7","SB8","SD3","SD5","QEJ","QF1","QA8","QA3","WF6"})
AAdd(aTabelas,{"SIGAQIP","SX5","SC5","SD1","SE1","SED","SU0","SU5","SU7","SUS","SUV","SAO","AC8","AC9","SB1","SA7","SA1","QQ7","QPA","QP3","QQ4",;
"SAH","QP6","QP7","QP1","QP2","QP8","QA2","QPR","QEE","NNR","SH7","SAG","QP9","QPU","QAA","QAC","SI3","QAD","CTT","QP4",;
"QP5","SRA","QQ5","QM1","QPS","QPT","SH3","SG2","SH1","SH4","QQ1","QQ2","QQ3","QQH","QQG","SHB","QQK","QPB","QPC","QPF",;
"QPX","QQB","QA6","QA7","QPH","QPI","QPN","QPY","QPZ","SA5","SA2","SC2","SB2","SG1","SC6","SHD","SHE","SC3","QPK","QPQ",;
"QPD","QPO","QA4","QM2","QPL","QPM","QEK","QEL","SD4","QE9","QE2","QPG","QQC","VCB","WF1","WF2","WF3","WF6"})
AAdd(aTabelas,{"SIGAQMT","SX5","QMB","QMZ","QM6","QM7","QM8","QMI","QMJ","QMR","QMS","QMT","QMX","QI2","SA1","QM4","QM5","QML","QM2","QM1","QN4",;
"QN5","QME","QMU","SAH","SYP","QMD","QMF","QA2","QA3","QMG","QMK","QM9","QMW","QMH","QMA","QMQ","QA5","QM3","QMC","SAP",;
"QEK","QE6","QE7","QMO","QMV","SAG","QE2","QE9","QEU","QED","QEE","QAA","QAC","QAD","QMP","SU0","SU5","SU7","SUS","SUV",;
"WF6"})
AAdd(aTabelas,{"SIGAQNC","SX5","QI0","QI1","QI2","QI3","QI4","QI5","QI6","QI7","QI8","QI9","QIA","QAA","QA4","SH9","ST3","ST4","STA","STF","STI",;
"STK","STL","STN","STQ","QIE","QDH","QID","QIF","QIB","QIC","SAH","QEK","QE6","QE7","QAC","QAD","QAB","SU0","SU5","SU7",;
"SUS","SUV","SYA","SA5","SB2","SB3","SB4","SB5","SB6","SB8","SBF","SDD","SC1","SC4","SC6","SC7","SD1","SD2","SD3","SD4",;
"SG1","SG2","SI1","SI3","SYD","SI4","SIC","SID","SJ2","SJC","SB1","SE2","SF1","SAD","AC8","AC9","SC5","SA1","SE1","SF2",;
"SAE","VCB","SAO","SA2","SA7","QIG","WF6"})
AAdd(aTabelas,{"SIGAREP","SX5","OZ1","OZ2","OZ4","OZ3"})
AAdd(aTabelas,{"SIGARSP","SX5","SQ0","RBM","SQB","SQ3","SI3","SI1","SI7","CTT","SQV","SQ1","SQ2","SQN","SQ4","RA5","RBH","SRJ","SQX","SQT","RA0",;
"SQE","SQS","SA1","VCB","RBK","RBL","SQO","SQW","SQQ","SQG","SQI","SQL","SQP","SQR","SYP","SQD","SQM","SQU","AI7","AI8",;
"AI9","RS0","RS1","SRA","SR3","SR6","SR7","SR9","SRX","SA6","SPA","SQH","SU0","SU5","SU7","SUS","SUV","WF6","RH3"})
AAdd(aTabelas,{"SIGASFC","SX5"})
AAdd(aTabelas,{"SIGASGA","SX5","SH7","SED","SI3","CTT","NNR","SHB","QAD","QDT","QAC","QAA","SRA","TAF","ST9","TN5","SRJ","TDR","TAB","TA1","TA2",;
"TBH","TBI","TA0","TA5","TAC","TA6","TA7","TA3","TA8","TA4","TA9","TAG","TAE","TAD","TAA","TCO","TB6","SA2","SC7","SE2",;
"SF1","SA5","SC1","SAD","SA1","SYA","SE4","SB6","SYP","TB0","TAV","TB4","TB1","SB1","SA4","TCS","TAX","TAZ","TC0","SB2",;
"SB9","SD1","SD2","SD3","TB2","TDB","TH1","TH2","TDC","TDD","TDE","TDF","TDG","TDH","TB5","TBJ","DA4","TDL","DUT","DA3",;
"TDM","TDJ","TDI","TDK","TCA","TCB","TCC","TCD","TCE","TCF","TCG","TBB","TBC","TBU","TBV","TBX","TBY","TBZ","TC1","TC2",;
"TC3","TBD","TBE","TBF","TBG","TBM","TD0","TD1","TD2","TD3","TD4","TD5","TD6","TD7","TD8","TD9","TDA","TBK","TAO","TCH",;
"TCM","TCK","TZ1","TZ2","TZ3","TZ4","TZ5","TZ6","TZ7","TAP","TBA","TB7","SAH","TCJ","TBN","TBQ","TBR","TBP","TC5","TC6",;
"TC7","TCI","TAQ","TQC","TQD"})
AAdd(aTabelas,{"SIGATAF","SX5","C1E","C2J","T39","T38","T35","T36","CHD","C0Q","CAL","CMW","CM7","C1N","C1G","C1H","C1J","C1K","C1L","C03","C0A",;
"C0B","C2M","C3Z","C3V","C3X","C2Q","C2L","C0W","C0T","C6V","C55","C3R","C3Q","T32","C6D","C2R","C1O","C1P","CHC","C20",;
"C21","C22","C23","C24","C25","C26","C27","C28","C29","C2A","C2B","C2C","C2D","C2E","C2F","C2G","C2H","C2I","C30","C31",;
"C32","C33","C34","C35","C36","C37","C38","C39","C3F","C4F","C4G","C4H","C01","C0S","C08","C4N","C4O","C4P","C4Q","C1S",;
"C5I","C1Q","C5J","C5K","C5L","C1C","C4D","C17","C5Z","CA2","CA3","CA4","CA5","CA6","CA7","CA8","C3B","C3C","C82","C83",;
"C84","C49","C4A","C85","C46","C47","C48","C4C","C4B","C4E","C4L","C4M","C5F","C5G","C0Y","C11","T18","C6Y","C5A","C5D",;
"C14","C6M","C40","C44","C45","C43","C5Q","C5R","C5S","C5T","C5U","C51","C50","C1A","C4Z","C4X","C07","C09","C5E","C58",;
"C1U","C59","C53","C54","C5H","C5M","C5N","C5O","C6E","C3S","C6F","C6G","C6H","C6I","C6J","C6K","C6L","C6N","C6O","T30",;
"C7H","C7I","C7J","C7K","C7L","C7M","C7N","C7O","C7P","C7Q","C7R","C7S","C7T","C7Z","C70","C7V","C7X","C7U","C71","C72",;
"C73","C74","C75","C76","C77","C78","C79","C4R","C4S","C4T","C4U","C4V","C52","C4I","C4J","CAC","CAD","CAE","CAF","CAG",;
"CFS","CHB","T0M","CEN","CEO","CEP","CEQ","CER","CES","CET","CEU","CEV","CGO","CGP","CGQ","CGR","CGT","CHF","CGU","CGV",;
"CGW","CGY","CGZ","CH9","T27","T28","T29","C0R","C1Z","CEG","T2U"})
AAdd(aTabelas,{"SIGATCF","SX5","SRA","AI3","AI4","AI5","AI6","RD0","AI8","AI9","AI7","SRB","SRJ","SR6","RCE","SU0","SU5","SU7","SUS","SUV","WF6"})
AAdd(aTabelas,{"SIGATEC","SX5","SA2","SED","SE4","SF4","SI1","SI3","SB8","SBJ","SBF","SDC","SC7","SD3","SRA","SJ1","SJC","AC8","AC9","SA1","SC3",;
"SB3","VCB","SAO","SB1","SYP","SB5","SGA","SC1","SC2","SC4","SYD","SU5","SBM","SG1","SAH","SG2","SBG","SBH","SCK","SC5",;
"SC6","SD1","SD2","SF3","SB6","SM2","SM4","SU0","SU7","SUS","SUV","SAN","ACB","ACC","SA3","ABT","SU1","SUG","ADO","TDW",;
"TDX","TGX","TDY","TGW","AC0","RR0","TCZ","TWS","DA0","DA1","AC1","AC2","ACA","AGT","AGU","AGV","AGX","AC3","AD3","ACU",;
"ACV","ADK","AD1","AD2","AD4","AD9","ADC","AD5","AD6","AD7","AD8","AA1","ABC","ABW","AAT","AAU","ADY","ADZ","TV6","TV7",;
"ADR","ADS","ADT","ADU","AE1","AE2","AE3","AE4","AE5","ADM","ADN","ADP","ADQ","AG3","AG4","AAG","AA7","AAC","AAP","AA6",;
"AA5","AAI","AAK","AAL","AA3","AA4","TWJ","TWK","TWL","TWM","TWN","SRJ","SR6","SPJ","RHQ","SP2","SP3","ABU","TW2","AA2",;
"AAX","AAY","TDU","SN1","SB4","ABD","ABS","AGW","SQB","TGS","TEZ","TEW","AAH","SB2","SA7","SC0","SB9","SBE","SD5","SBK",;
"SD7","AAM","AAN","AAO","AAE","AAJ","AAA","AAB","AB6","AB7","AB8","ABB","ABP","SQ3","AAD","AAZ","TFI","TFL","TFJ","TEV",;
"SF2","SF1","TGQ","TGR","TWC","TWD","AA8","AA9","ABE","AB9","ABQ","CN1","CN9","CNA","CNB","TFF","TFG","TFH","CN0","CND",;
"CNE","TFS","TFT","TFV","TFW","TFX","TFY","TFZ","TGV","TDS","TDT","TW9","TWA","ST9","STJ","ABH","ABI","ABJ","AB1","AB2",;
"AB3","AB4","AB5","ABK","ABL","ABM","ABF","ABG","SCP","ABA","SAD","QEK","QE6","QE7","TIM","ABN","TCU","TIZ","ABR","SRH",;
"SRF","SR8","TCT","TIN","TW0","TW1","TGZ","SP8","SRV","RGB","TE0","CCH","TIO","TE1","TE2","TFP","TER","TFN","TIX","TEU",;
"TE4","TE5","TE6","TE7","TES","TET","TFQ","TEP","TEQ","TEY","TFK","TFM","TIQ","TIR","TIS","TIV","TIT","TIU","TIW","TIY",;
"SC9","SE1","SE2","SE5","AAF","TIP","TWE","TWF"})
AAdd(aTabelas,{"SIGATMK","SX5","SBM","SB2","SB3","SB4","SB5","SB6","SC1","SC2","SC4","SC6","SC7","SD1","SD2","SD4","SG1","SG2","SED","SAH","NNR",;
"SLG","SU0","SK0","SU7","AGE","ACJ","SUM","SRA","SR7","SI3","SR9","SR3","SA6","SRJ","SR6","SRX","RA0","SQB","SM2","SI7",;
"SM4","SAN","ADG","SUX","SUY","SU9","SUQ","SUR","SUH","SUL","SUN","SC5","SE3","SU1","SB1","SUG","SK2","SK3","SK1","DA0",;
"DA1","ACO","ACP","ACQ","ACR","ACS","ACT","AC9","ACB","ACC","SU5","SQ0","SA1","VCB","SAO","AC8","SUS","ACH","AC4","SE2",;
"SF1","SE4","SU2","AC3","SB9","SF5","SD3","SAE","SF4","SFM","SA2","ACD","ACE","SUZ","SUP","SU6","SUO","SUW","AC6","AC7",;
"SU4","SUC","SUD","SE1","SE5","SYP","SU8","SUA","SUB","SC9","SUK","SUV","AD7","SEF","ACF","ACG","SKA","SKB","SKJ","ADE",;
"ADF","SB0","SL4","SBF","AB1","SB8","SBJ","SD5","SBK","AA3","AAG","AB3","AB4","AB5","AB6","AB7","AB8","AAL","AAK","AAJ",;
"AA4","AG9","SUE","SUF","SKY","SKW","SKX","SK8","SK6","SK7","SK9","SUI","SUJ","SPJ","SP2","SKK","SKQ","SUU","SUT","QI0",;
"QI2","QI6","AG8","RBK","RBL","RDM","RD2","AGM","AGN","AGO","AGI","AGJ","AB2","ACI","SF2","SY6","SA4","SA3","AGF","SK5"})
AAdd(aTabelas,{"SIGATMS","SX5","SB2","SB3","SB4","SB5","SB6","SB8","SBJ","SBF","SDD","SC1","SAI","SC2","SC4","SC6","SC7","SD1","SD2","SD3","SD4",;
"SG1","SG2","SED","SYD","SJ2","SJ1","SJC","SYP","SDC","NNR","SAH","QEK","QE6","QE7","SBM","VE1","SB1","SBE","SDA","SDB",;
"SC5","SE1","SAO","AC8","AC9","SYA","DAF","DAC","SA7","SA1","VCB","SE2","SF1","SE4","SF4","SF3","SM2","SCJ","SC8","SA3",;
"SE3","SAN","DYI","DY3","SA4","DC5","DC6","DUY","DT0","DUN","DVK","DTN","DA5","DA6","DA7","DA8","DA3","DA9","DAL","DVM",;
"DTZ","DU0","DU1","DU2","DV8","DTD","DVA","DAR","DAO","DAQ","DAV","DIR","DIS","DIT","DIU","DIV","DIX","DU3","DU4","DU5",;
"DUX","DUW","DV6","DV7","DVI","DU8","DU9","SF2","DUB","DT2","DTQ","DUD","DT6","DT3","DW0","DW1","DW2","DTL","DTF","DTG",;
"DY9","DYA","DT1","DTK","DV9","DVC","DVD","DYE","DYF","AAM","AAN","AAO","AAE","DU6","DUO","DVN","DVO","DVE","DT5","DV2",;
"DV3","DV5","DTI","DTH","DTJ","DUR","DVZ","DW3","DT9","DE4","AI3","AI4","AI5","AI6","AI8","AI9","AI7","DTS","DUS","DTM",;
"DTT","DVG","DUJ","DVP","DTY","DTR","DTX","SDG","DUA","DTP","SA2","SE5","DEG","DUI","DUF","DUG","DV1","DY5","SFT","DVL",;
"DA4","DAU","DUT","DUP","DUQ","DVB","DVW","DTB","DTO","DTU","DUV","DT7","DUC","DYD","DVS","DVT","DF7","DYB","DYC","DUE",;
"DUM","DUL","DT4","DVF","DVQ","DF0","DF1","DF2","DF3","DF4","DF5","DF6","DTC","DTE","DUH","DUK","DE5","DVR","DVU","DT8",;
"DC9","SDE","DU7","DAI","SF8","DC8","SD7","AB6","AB8","DAK","AF8","SES","DTA","DTW","DD7","DY6","DY7","DTV","SFC","SF7",;
"AFR","DD8","DWX","DVV","DID","DV4","DVH","DW4","DUU","DWU","SA5","SEF","SI1","SI2","SI5","SI6","SI7","SF9","SN1","SN2",;
"SN3","SN4","SN5","AFN","SB9","SF5","STJ","STA","AF9","AFC","DUZ","DV0","SET","SEU","SA6","SE6","DVX","SC9","DE9","DE3",;
"DE0","DE1","DE2","DED","DEE","DE8","DEC","DE6","DE7","DEA","DET","DEB","DD0","DD1","DD3","DD5","DD2","DD4","DD6","DEH",;
"DEI","DEK","DEM","DJB","DI0","DIL","DIE","DIF","DI1","DI2","DI3","DI4","DI6","DIN","DIK","DIB","DIG","DIC","DFV","DFT",;
"DW5","DWE","DWF","DWG","DWH","DWL","DWM","DWN","DW7","DW8","DWI","DWJ","DYS","DYT","DYU","DYV","DYX","SCV","DEN","DEF",;
"SD9"})
AAdd(aTabelas,{"SIGATRM","SX5","RD2","SRA","SR7","SI3","SR9","SR3","SA6","SRJ","SR6","SRX","RA0","RBM","SQB","CTT","SQV","SQ9","RBK","RBL","RBG",;
"RBJ","SQ1","SQ2","SQ3","SQ4","RA4","RA5","SQN","SQ0","RBH","RAL","SQX","SQT","AIQ","SQI","RA6","RAG","RAH","JAE","JAG",;
"JA8","JAM","JAN","JAR","JAW","JB1","JAA","JAP","JBZ","JAY","RA1","RA3","RA9","RA7","SRW","SAN","RAT","RAV","RHG","RAX",;
"SYP","SQ8","SRD","SI1","SI7","RAF","RBI","SQO","SQP","SQW","SQQ","RA8","SC1","SC8","SAD","SA2","SB1","SB3","SE4","SCE",;
"RA2","SQC","RAA","RAJ","RAI","SU0","SU5","SU7","SUS","SUV","WF6","RH3"})
AAdd(aTabelas,{"SIGAVEI","SX5","VAM","VAP","VV1","VVW","VV2","VAQ","VD1","VAZ","SA1","VV0","VVA","VCF","VS9","VV9"})
AAdd(aTabelas,{"SIGAWMS","SX5","DC1","DCO","DC2","SAH","QEK","QE6","QE7","DC4","DC8","SRJ","DCD","DCI","SBM","DC9","SB2","SB3","SB4","SB5","SB6",;
"SB8","SBJ","SBF","SDD","SC1","SAI","SC2","SC4","SC6","SC7","SD1","SD2","SD3","SD4","SG1","SG2","SED","SYD","SJ2","SJ1",;
"SJC","DB0","EI6","SB1","NNR","SE2","SF1","SE4","SA7","SA1","VCB","SA2","SBE","SDA","SDB","DC7","DCL","D10","DCP","DC3",;
"DC6","DC5","DCG","DCH","DCC","DCM","SF5","SF4","SC5","SF3","DCA","SI1","SI2","SI5","SI6","SI7","SI8","SI4","SIC","SID",;
"SM2","SM4","SU0","SU5","SU7","SUS","SUV","SAN","DCQ","SB9","SBD","SD8","SBK","DB1","DB2","DB3","SA5","SE1","SE3","SEF",;
"SF9","SN1","SN2","SN3","SN4","SN5","AFN","QEL","QEP","QEY","QEZ","SF8","SDE","SD7","QEA","SB7","AAM","AAN","AAO","AAE",;
"DCN","DBN","DCF","DCW","DCX","DCY","DCZ","D00","D01","D02","D03","D04","SC9","DCS","DCT","DCU","DCV","SDC","D06","D07",;
"D08","D09","SCP","SCQ","SAD","SF2","SD5","SBC","SC0","WF6"})

dbSelectArea("SZ1")
For nI:=1 To Len(aTabelas)
	For nJ:=2 To Len(aTabelas[nI])
		RecLock("SZ1",.T.)
		SZ1->Z1_FILIAL := XFilial("SZ1")
		SZ1->Z1_MODULO := aTabelas[nI,1]
		SZ1->Z1_TABELA := aTabelas[nI,nJ]
		SZ1->(MSUnlock())
	Next
Next
