#INCLUDE "PROTHEUS.CH"


















User function RCFDORMA()

local AAREA := GETAREA()
local ASAYS := {}
local ABUTTONS := {}
local NOPCA := 0

private CPERG := "RCFDORMA "


private CARQTXT := ""
private NRCF_OK := 0
private NRCF_REJ := 0


private LCAB_TXT := 0
private CSTATUS_TXT := ""
private LGRAVOU_RCF :=  .T. 


private C_FILIAL := "        "
private C_MES := "        "
private C_ANO := "    "
private C_PER := "      "
private C_PROCES := "     "
private C_TNOTRA := "@@@"
private C_SEMANA := "01"
private D_DTINI := ctod("//")
private D_DTFIM := ctod("//")
private N_DCALCM := 0
private N_DPERIO := 0
private N_HRSDIA := 0
private N_DIADSR := 0
private N_DUTEIS := 0
private N_HRSDSR := 0
private N_DIATRA := 0
private N_HRSTRA := 0
private N_DNTRAB := 0
private N_DUTILT := 0
private N_DREFEI := 0
private N_DALIM := 0
private C_MODULO := "GPE"


private C_NUMPAG := "01"
private C_ROTEIR := "   "
private D_DTPAGO := ctod("//")
private D_DTINTE := ctod("//")
private D_DTFECH := ctod("//")
private C_PERSEL := "2"
private C_RCHSTA := "5"
private C_RFQSTA := "2"
private C_COMPL := "2"


RCF_TELA()

CCADASTRO := OemToAnsi("Gerar tabelas de Período")

aadd(ASAYS,OemToAnsi("Este programa realiza o processo de geração do periodos"))
aadd(ASAYS,OemToAnsi("para as rotinas do módulo de Gestão de Pessoal."))

aadd(ABUTTONS,{5, .T. ,{ ||PERGUNTE(CPERG, .T. )}})
aadd(ABUTTONS,{1, .T. ,{|O|NOPCA := 1,iif(RCF_VALID(MV_PAR01),FECHABATCH(),NOPCA := 0)}})
aadd(ABUTTONS,{2, .T. ,{|O|FECHABATCH()}})

FORMBATCH(CCADASTRO,ASAYS,ABUTTONS)

if NOPCA==1
    PROCESSA({|LEND|RCF_PROCES(),"Gerando tabelas de período","Gerando períodos . . ."})
endif

RESTAREA(AAREA)

return 








static function RCF_VALID(CFILIAL_DE)

local LRET :=  .F. 

if iif(FindFunction("APMsgYesNo"),APMSGYESNO("Confirma a configuração dos parâmetros?","Atenção"),(CMSGYESNO := "MsgYesNo", &CMSGYESNO.("Confirma a configuração dos parâmetros?","Atenção")))

    LRET :=  .T. 
endif



return LRET






static function RCF_PROCES()

local AAREA := GETAREA()
local CQUERY := ""
local AFUNC := {}
local NT := 0

local CCANCELA :=  .F. 
local ASTRU := NIL
local D_DT_FIM_PROC := ctod("//")

local ASTRU := SRA->(dbstruct())


CARQTXT := "C:\TEMP\RCF_"+MV_PAR01+"_"+dtos(DDATABASE)+".TXT"
NHDL := fcreate(CARQTXT)
if NHDL==- (1)
    iif(FindFunction("APMsgAlert"),APMSGALERT("O arquivo "+CARQTXT+" não pôde ser criado! Verifique se existe a pasta C:\TEMP em sua máquina.","Atenção !"),MsgAlert("O arquivo "+CARQTXT+" não pôde ser criado! Verifique se existe a pasta C:\TEMP em sua máquina.","Atenção !"))
    return 
endif


CQUERY := "SELECT RA_FILIAL, RA_ADMISSA FROM "+RETSQLNAME("SRA")+" "
CQUERY += "WHERE D_E_L_E_T_ <> '*' "
CQUERY += "AND RA_FILIAL = '"+MV_PAR01+"' "
CQUERY += "ORDER BY RA_ADMISSA "
CQUERY := CHANGEQUERY(CQUERY)

dbusearea( .T. ,"TOPCONN",TCGenQry(CQUERY),"TSRA", .F. , .T. )


NT :=  len(ASTRU)
for NI := 1 to NT step 1
    if (ASTRU[NI][2]) $ ("DNL")
        TCSetField("TSRA",ASTRU[NI][1],ASTRU[NI][2],ASTRU[NI][3],ASTRU[NI][4])
    endif
next


TSRA->(dbgotop())
D_DTINI := FIRSTDATE(TSRA->RA_ADMISSA)

if empty(D_DTINI)
    iif(FindFunction("APMsgInfo"),APMSGINFO("Filial sem funcionários ou com a data de admissão inválida.","Atenção"),MsgInfo("Filial sem funcionários ou com a data de admissão inválida.","Atenção"))
    TSRA->(dbclosearea())
    return 
endif

C_FILIAL := MV_PAR01
D_DT_FIM_PROC := LASTDATE(MV_PAR05)

while D_DTINI<=D_DT_FIM_PROC; 

    INCPROC("Data: "+dtoc(D_DTINI))



    C_MES :=  strzero(month(D_DTINI),2)
    C_ANO := str(year(D_DTINI),4)
    C_PER := C_ANO+C_MES



    D_DTFIM := LASTDATE(D_DTINI)
    N_DCALCM := D_DTFIM-D_DTINI+1
    N_DPERIO := N_DCALCM
    N_HRSDIA := 8
    N_DIATRA := DATEWORKDAY(D_DTINI,D_DTFIM)
    N_DNTRAB := D_DTFIM-D_DTINI+1-N_DIATRA
    N_DIADSR := (N_DNTRAB) / (2)
    N_DUTEIS := N_DPERIO-N_DIADSR
    N_HRSDSR := ((N_DNTRAB) / (2)) * (8)
    N_HRSTRA := (N_DIATRA) * (8)
    N_DUTILT := N_DIATRA
    N_DREFEI := N_DIATRA
    N_DALIM := N_DIATRA
    C_MODULO := "GPE"


    if MV_PAR02=1
        C_PROCES := "00001"
        RCF_GRV_TAB(C_PROCES)
    endif


    if MV_PAR03=1
        C_PROCES := "00003"
        RCF_GRV_TAB(C_PROCES)
    endif


    if MV_PAR04=1
        C_PROCES := "00005"
        RCF_GRV_TAB(C_PROCES)
    endif


    if MV_PAR06=1
        C_PROCES := "00006"
        RCF_GRV_TAB(C_PROCES)
    endif



    if LCAB_TXT=0
        CSTATUS_TXT := "0"
        RCF_GRV_LOG(CSTATUS_TXT)
        LCAB_TXT := 1
    endif
    if LGRAVOU_RCF
        CSTATUS_TXT := "1"
        RCF_GRV_LOG(CSTATUS_TXT)
    else 
        CSTATUS_TXT := "2"
        RCF_GRV_LOG(CSTATUS_TXT)
    endif

    D_DTINI := D_DTFIM+1
	
	endDo


TSRA->(dbclosearea())

fclose(NHDL)

iif(FindFunction("APMsgInfo"),APMSGINFO("Total de períodos gerados: "+ strzero(NRCF_OK,6),),MsgInfo("Total de períodos gerados: "+ strzero(NRCF_OK,6),))

iif(FindFunction("APMsgInfo"),APMSGINFO("Total de períodos rejeitados: "+ strzero(NRCF_REJ,6),),MsgInfo("Total de períodos rejeitados: "+ strzero(NRCF_REJ,6),))


return 







static function RCF_GRV_TAB()

local NCNT := 0
local NVEZES := iif(MV_PAR03=1,4,3)

dbselectarea("RCF")
dbsetorder(4)
if .not. (RCF->(dbseek(C_FILIAL+C_PER+C_SEMANA+C_ANO+C_MES+C_PROCES+"   "+C_TNOTRA)))
    RECLOCK("RCF", .T. )

    RCF->RCF_FILIAL := C_FILIAL
    RCF->RCF_MES := C_MES
    RCF->RCF_ANO := C_ANO
    RCF->RCF_PER := C_PER
    RCF->RCF_PROCES := C_PROCES
    RCF->RCF_TNOTRA := C_TNOTRA
    RCF->RCF_SEMANA := C_SEMANA
    RCF->RCF_DTINI := D_DTINI
    RCF->RCF_DTFIM := D_DTFIM
    RCF->RCF_DCALCM := N_DCALCM
    RCF->RCF_DPERIO := N_DPERIO
    RCF->RCF_HRSDIA := N_HRSDIA
    RCF->RCF_DIADSR := N_DIADSR
    RCF->RCF_DUTEIS := N_DUTEIS
    RCF->RCF_HRSDSR := N_HRSDSR
    RCF->RCF_DIATRA := N_DIATRA
    RCF->RCF_HRSTRA := N_HRSTRA
    RCF->RCF_DNTRAB := N_DNTRAB
    RCF->RCF_DUTILT := N_DUTILT
    RCF->RCF_DREFEI := N_DREFEI
    RCF->RCF_DALIM := N_DALIM
    RCF->RCF_MODULO := C_MODULO

    RCF->(MSUNLOCK())





    D_DTINTE := D_DTFIM
    D_DTPAGO := D_DTFIM
    D_DTFECH := D_DTFIM+5


    if ( substr(C_PER,5,2)="11") .or. ( substr(C_PER,5,2)="12")
        NVEZES := 5
    endif

    for NCNT := 1 to NVEZES step 1



        do case 
		
		case NCNT=1
        C_ROTEIR := "FOL"
        D_DTINTE := ctod("//")
        D_DTPAGO := D_DTFIM+5
        case NCNT=2
        C_ROTEIR := "FER"
        case NCNT=3
        C_ROTEIR := "RES"
        case NCNT=4
        C_ROTEIR := "AUT"
        case NCNT=5
        D_DTINTE := ctod("//")
        if  substr(C_PER,5,2)="11"
            C_ROTEIR := "131"
        else 
            C_ROTEIR := "132"
            D_DTFECH := ctod("20/12/"+ substr(C_PER,1,4))
        endif
        endcase

        if .not. (RCH->(dbseek(C_FILIAL+C_PROCES+C_PER+C_NUMPAG+C_ROTEIR)))
           RECLOCK("RCH", .T. )

            RCH->RCH_FILIAL := C_FILIAL
            RCH->RCH_PER := C_PER
            RCH->RCH_NUMPAG := C_NUMPAG
            RCH->RCH_PROCES := C_PROCES
            RCH->RCH_ROTEIR := C_ROTEIR
            RCH->RCH_MES := C_MES
            RCH->RCH_ANO := C_ANO
            RCH->RCH_DTINI := D_DTINI
            RCH->RCH_DTFIM := D_DTFIM
            RCH->RCH_DTPAGO := D_DTPAGO
            RCH->RCH_DTINTE := D_DTINTE
            RCH->RCH_DTFECH := D_DTFECH
            RCH->RCH_PERSEL := C_PERSEL
            RCH->RCH_STATUS := C_RCHSTA
            RCH->RCH_MODULO := C_MODULO
            RCH->RCH_COMPL := C_COMPL

            RCH->(MSUNLOCK())
        endif
    next



    if .not. (RFQ->(dbseek(C_FILIAL+C_PROCES+C_PER+C_NUMPAG+C_ROTEIR)))
        RECLOCK("RFQ", .T. )

        RFQ->RFQ_FILIAL := C_FILIAL
        RFQ->RFQ_PROCES := C_PROCES
        RFQ->RFQ_MES := C_MES
        RFQ->RFQ_ANO := C_ANO
        RFQ->RFQ_PERIOD := C_PER
        RFQ->RFQ_NUMPAG := C_NUMPAG
        RFQ->RFQ_DTINI := D_DTINI
        RFQ->RFQ_DTFIM := D_DTFIM
        RFQ->RFQ_MODULO := C_MODULO
        RFQ->RFQ_STATUS := C_RFQSTA

        RFQ->(MSUNLOCK())
    endif

    LGRAVOU_RCF :=  .T. 

    NRCF_OK++
else 
    LGRAVOU_RCF :=  .F. 
    NRCF_REJ++
endif

RCF->(MSUNLOCK())



return 






static function RCF_GRV_LOG(CTIPOLOG)


local CTEXTO := ""

if CTIPOLOG="0"
    CTEXTO += "RCF_FILIAL"
    CTEXTO += ";"
    CTEXTO += "RCF_MES"
    CTEXTO += ";"
    CTEXTO += "RCF_ANO"
    CTEXTO += ";"
    CTEXTO += "RCF_PER"
    CTEXTO += ";"
    CTEXTO += "RCF_PROCES"
    CTEXTO += ";"
    CTEXTO += "RCF_TNOTRA"
    CTEXTO += ";"
    CTEXTO += "RCF_SEMANA"
    CTEXTO += ";"
    CTEXTO += "RCF_DTINI"
    CTEXTO += ";"
    CTEXTO += "RCF_DTFIM"
    CTEXTO += ";"
    CTEXTO += "RCF_DCALCM"
    CTEXTO += ";"
    CTEXTO += "RCF_DPERIO"
    CTEXTO += ";"
    CTEXTO += "RCF_HRSDIA"
    CTEXTO += ";"
    CTEXTO += "RCF_DUTEIS"
    CTEXTO += ";"
    CTEXTO += "RCF_DIASDSR"
    CTEXTO += ";"
    CTEXTO += "RCF_HRSDSR"
    CTEXTO += ";"
    CTEXTO += "RCF_DIATRA"
    CTEXTO += ";"
    CTEXTO += "RCF_HRSTRA"
    CTEXTO += ";"
    CTEXTO += "RCF_DNTRAB"
    CTEXTO += ";"
    CTEXTO += "RCF_DUTILT"
    CTEXTO += ";"
    CTEXTO += "RCF_DREFEI"
    CTEXTO += ";"
    CTEXTO += "RCF_DALIM"
    CTEXTO += ";"
    CTEXTO += "RCF_MODULO"
    CTEXTO += ";"
    CTEXTO += "STATUS"
else 
    CTEXTO += C_FILIAL
    CTEXTO += ";"
    CTEXTO += C_MES
    CTEXTO += ";"
    CTEXTO += C_ANO
    CTEXTO += ";"
    CTEXTO += C_PER
    CTEXTO += ";"
    CTEXTO += C_PROCES
    CTEXTO += ";"
    CTEXTO += C_TNOTRA
    CTEXTO += ";"
    CTEXTO += C_SEMANA
    CTEXTO += ";"
    CTEXTO += dtoc(D_DTINI)
    CTEXTO += ";"
    CTEXTO += dtoc(D_DTFIM)
    CTEXTO += ";"
    CTEXTO += str(N_DCALCM,4)
    CTEXTO += ";"
    CTEXTO += str(N_DPERIO,4)
    CTEXTO += ";"
    CTEXTO += transform(N_HRSDIA,"@E 9.999")
    CTEXTO += ";"
    CTEXTO += str(N_DUTEIS,4)
    CTEXTO += ";"
    CTEXTO += str(N_DIADSR,4)
    CTEXTO += ";"
    CTEXTO += transform(N_HRSDSR,"@E 999.99")
    CTEXTO += ";"
    CTEXTO += str(N_DIATRA,4)
    CTEXTO += ";"
    CTEXTO += transform(N_HRSTRA,"@E 999.99")
    CTEXTO += ";"
    CTEXTO += str(N_DNTRAB,4)
    CTEXTO += ";"
    CTEXTO += str(N_DUTILT,4)
    CTEXTO += ";"
    CTEXTO += str(N_DREFEI,4)
    CTEXTO += ";"
    CTEXTO += str(N_DALIM,4)
    CTEXTO += ";"
    CTEXTO += C_MODULO
    CTEXTO += ";"
    CTEXTO += iif(CTIPOLOG="1","Ok","Rejeitado")
endif


CTEXTO += CHR(13)+CHR(10)

if fwrite(NHDL,CTEXTO, len(CTEXTO))<> len(CTEXTO)
    ALERT("Atenção ! ERRO gravando dados do funcionário")
endif

return 






static function RCF_TELA()

local _SALIAS := alias()
local AREGS := {}

dbselectarea("SX1")
dbsetorder(1)
CPERG := padr(CPERG,10)


aadd(AREGS,{CPERG,"01","Filial             ?","Filial             ?","Filial             ?","mv_ch1","C",8,0,0,"G","naovazio","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","XM0","","033",".RHFILDE.     ",""})
aadd(AREGS,{CPERG,"02","Gerar Mensa./Estag.?","Gerar p/Mens/Estag.?","Gerar p/Mens/Estag.?","mv_ch2","N",1,0,1,"C","naovazio","mv_par02","1-Sim","","","","","2-Não","","","","","","","","","","","","","","","","","","","",""})
aadd(AREGS,{CPERG,"03","Gerar Pro-lab/Auto.?","Gerar Pro-lab/Auto.?","Gerar Pro-lab/Auto.?","mv_ch3","N",1,0,2,"C","naovazio","mv_par03","1-Sim","","","","","2-Não","","","","","","","","","","","","","","","","","","","",""})
aadd(AREGS,{CPERG,"04","Gerar Horista      ?","Gerar Horista      ?","Gerar Horista      ?","mv_ch4","N",1,0,2,"C","naovazio","mv_par04","1-Sim","","","","","2-Não","","","","","","","","","","","","","","","","","","","",""})
aadd(AREGS,{CPERG,"05","Data Final         ?","Data Final         ?","Data Final         ?","mv_ch5","D",8,0,0,"C","naovazio","mv_par05","","","","","","","","","","","","","","","","","","","","","","","","","",""})
aadd(AREGS,{CPERG,"06","Gerar Professor    ?","Gerar Professor    ?","Gerar Professor    ?","mv_ch6","N",1,0,2,"C","naovazio","mv_par06","1-Sim","","","","","2-Não","","","","","","","","","","","","","","","","","","","",""})
for I := 1 to ( len(AREGS)) step 1
    if .not. (dbseek(CPERG+AREGS[I][2]))
        RECLOCK("SX1", .T. )
        for J := 1 to (fcount()) step 1
            if J<= len(AREGS[I])
                fieldput(J,AREGS[I][J])
            endif
        next
        MSUNLOCK()
    endif
next

dbselectarea(_SALIAS)

return 
