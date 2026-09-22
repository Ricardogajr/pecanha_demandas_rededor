


function U_GPE210LOG()

local NSALFUNC
local NTETO
local NTOTCOPART

local NFAIXA1
local NTETO1
local NPERC1

local NFAIXA2
local NTETO2
local NPERC2

local NFAIXA3
local NTETO3
local NPERC3

local NFAIXA4
local NTETO4
local NPERC4

local CFAIXA
local CCONTEUDO

local AAREA
local AVERBAS
local ACOPART
local CMATRICULA
local AFILPARAM
local AFILLIB
local NPOSFIL
local CFILLIB
local CFILQRY
local CQRY
local NY
local NX
local CINIANOMES
local CFIMANOMES
local CANOMES
local LVALIDADE
local ADADLOG
local CDADTXT

local CTIPRFJ

AFILPARAM := STRTOKARR(SUPERGETMV("DOR_FILLIB", .T. ,"01BU0001,01BU0003"),",")

CTIPRFJ := GETMV("FS_COPAR")

AFILLIB := {}
CFILLIB := ""
CFILQRY := ""

AAREA := GETAREA()

if .not. ((RFJ->RFJ_CODIGO) $ (CTIPRFJ))
    NPOSFIL := ASCAN(ACAMPOS,{ |X| upper( alltrim(X[1]))=="RGB_FILIAL"})
    
    for NY := 1 to ( len(AREG)) step 1
         if ASCAN(AFILPARAM,{ |X| upper( alltrim(X))== upper(AREG[NY][NPOSFIL])})>0
             if ASCAN(AFILLIB,{ |X| upper( alltrim(X))== upper(AREG[NY][NPOSFIL])})=0
                AADD(AFILLIB,AREG[NY][NPOSFIL])
            endif
        endif
    next
    
    if CALIASARQ=="RGB" .and.  len(AFILLIB)>0
        
        CFAIXA := ""
        AVERBAS := {}
        ACOPART := {}
        ADADLOG := {}
        CDADTXT := ""
        NX := 1
        NTETO := 0
        NTOTCOPART := 0
        
        CQRY := "SELECT RGB_FILIAL, RGB_MAT, RGB_PD, RGB_VALOR, RGB_PERIOD, RGB_SEMANA, RGB_SEQ FROM "+RETSQLNAME("RGB")+" "
        CQRY += " WHERE D_E_L_E_T_ = ' '"
         if  len(AFILLIB)>1
            for NY := 1 to ( len(AFILLIB)) step 1
                CFILQRY += "'"+AFILLIB[NY]+"', "
            next
            CFILQRY :=  substr(CFILQRY,1, len(CFILQRY)-2)
            CQRY += "   AND RGB_FILIAL IN ("+CFILQRY+") "
        else 
            CQRY += "   AND RGB_FILIAL = '"+AFILLIB[1]+"'"
        endif
        CQRY += " ORDER BY RGB_FILIAL, RGB_MAT, RGB_PD DESC"
        
         if SELECT("TDP")
            (TDP)->(DBCLOSEAREA())
        endif
        
        DBUSEAREA( .T. ,"TOPCONN",TCGENQRY(CQRY),"TDP", .T. , .T. )
        
        (TDP)->(DBGOTOP())
        CMATRICULA := TDP->RGB_MAT
        CFILLIB := ""
        LVALIDADE :=  .T. 
        
        ATITTESTE := STRTOKARR(CTITIMPRES," ")
        CTITIMPRES := "    "+ATITTESTE[1]+"        "+ATITTESTE[2]+"    "+ATITTESTE[3]+"  "+ATITTESTE[4]+" "+ATITTESTE[5]+"             "+ATITTESTE[6]+" "+ATITTESTE[7]+"     "+ATITTESTE[8]+"           "+ATITTESTE[9]+"           "+"Coparticipação"
        ALOG[2][1] := CTITIMPRES
        
        while (TDP)->(.not. (EOF())) 
             if TDP->RGB_FILIAL<>CFILLIB
                LVALIDADE :=  .T. 
                CFILLIB := TDP->RGB_FILIAL
                dbselectarea("RCC")
                (RCC)->(DBSETORDER(1))
                (RCC)->(DBGOTOP())
                 if (RCC)->(DBSEEK(FWXFILIAL("RCC")+"U052"+TDP->RGB_FILIAL))
                    while (RCC)->(.not. (EOF()) .and. RCC_FIL=TDP->RGB_FILIAL) 
                        CCONTEUDO :=  alltrim(RCC->RCC_CONTEU)
                        
                        CVERBA :=  substr(CCONTEUDO,136,3)
                        AADD(AVERBAS,CVERBA)
                        
                         if (CVERBA="627") .or. (CVERBA="628")
                            CINIANOMES :=  substr(CCONTEUDO,1,6)
                            CFIMANOMES :=  substr(CCONTEUDO,7,6)
                            
                            CANOMES :=  strzero(YEAR(DDATABASE),4)+ strzero(MONTH(DDATABASE),2)
                             if CANOMES>=CINIANOMES .and. CANOMES<=CFIMANOMES
                                NFAIXA1 :=  val( substr(CCONTEUDO,13,12))
                                NTETO1 :=  val( substr(CCONTEUDO,25,12))
                                NPERC1 :=  val( substr(CCONTEUDO,37,6))
                                
                                NFAIXA2 :=  val( substr(CCONTEUDO,43,12))
                                NTETO2 :=  val( substr(CCONTEUDO,55,12))
                                NPERC2 :=  val( substr(CCONTEUDO,67,6))
                                
                                NFAIXA3 :=  val( substr(CCONTEUDO,73,12))
                                NTETO3 :=  val( substr(CCONTEUDO,85,12))
                                NPERC3 :=  val( substr(CCONTEUDO,97,6))
                                
                                NFAIXA4 :=  val( substr(CCONTEUDO,103,12))
                                NTETO4 :=  val( substr(CCONTEUDO,115,12))
                                NPERC4 :=  val( substr(CCONTEUDO,127,6))
                            else 
                                LVALIDADE :=  .F. 
                            endif
                        endif
                        (RCC)->(DBSKIP())
                        end
                endif
            endif
            
            
             if TDP->RGB_MAT=CMATRICULA
                 if LVALIDADE
                     if NTOTCOPART<=NTETO
                         if ASCAN(AVERBAS, alltrim(TDP->RGB_PD))
                            NSALFUNC := GETADVFVAL("SRA","RA_SALARIO",TDP->RGB_FILIAL+TDP->RGB_MAT,1,"")
                             if NSALFUNC<=NFAIXA1
                                
                                
                                NCOPART := ((TDP->RGB_VALOR) * (NPERC1)) / (100)
                                CFAIXA := "A"
                                NTETO := NTETO1
                            
                            elseif NSALFUNC>NFAIXA1 .and. NSALFUNC<=NFAIXA2
                                
                                
                                NCOPART := ((TDP->RGB_VALOR) * (NPERC2)) / (100)
                                CFAIXA := "B"
                                NTETO := NTETO2
                            
                            elseif NSALFUNC>NFAIXA2 .and. NSALFUNC<=NFAIXA3
                                
                                
                                NCOPART := ((TDP->RGB_VALOR) * (NPERC3)) / (100)
                                CFAIXA := "C"
                                NTETO := NTETO3
                            else 
                                
                                
                                NCOPART := ((TDP->RGB_VALOR) * (NPERC4)) / (100)
                                CFAIXA := "D"
                                NTETO := NTETO4
                            endif
                            
                             if NCOPART>NTETO
                                 if NTOTCOPART>0
                                    NCOPART := NTETO-NTOTCOPART
                                    NTOTCOPART := NTOTCOPART+NCOPART
                                else 
                                    NCOPART := NTETO
                                    NTOTCOPART := NTETO
                                    NTOTCOPART := NTOTCOPART+NCOPART
                                endif
                            else 
                                 if NTOTCOPART=0
                                    NTOTCOPART := NTOTCOPART+NCOPART
                                else 
                                     if NTOTCOPART+NCOPART<NTETO
                                        NTOTCOPART := NTOTCOPART+NCOPART
                                    else 
                                        NCOPART := NTETO-NTOTCOPART
                                        NTOTCOPART := NTOTCOPART+NCOPART
                                    endif
                                endif
                            endif
                            AADD(ACOPART,{TDP->RGB_FILIAL,TDP->RGB_MAT,TDP->RGB_PD,TDP->RGB_PERIOD,TDP->RGB_SEMANA,TDP->RGB_SEQ,NOROUND(NCOPART,2),""})
                            
                            for NY := 2 to ( len(ALOG[2])) step 1
                                ADADLOG := STRTOKARR(ALOG[2][NY]," ")
                                 if  len(ADADLOG)>5
                                     if TDP->RGB_FILIAL+TDP->RGB_MAT+TDP->RGB_PD==ADADLOG[3]+ADADLOG[4]+ substr(ADADLOG[5],1,3)
                                        CDADTXT := ADADLOG[1]+" "+ADADLOG[2]+"   "+ADADLOG[3]+"    "+ADADLOG[4]+"    "+ADADLOG[5]+" "+ADADLOG[6]+" "+ADADLOG[7]+" "+ADADLOG[8]+"    "+ADADLOG[9]+"                    "+PADL(ADADLOG[10],12)+"       "+PADL( alltrim(REPLACE(STR(NOROUND(NCOPART)),".",",")),12)
                                        ALOG[2][NY] := CDADTXT
                                        exit 
                                    endif
                                endif
                            next
                        endif
                    else 
                         if ASCAN(AVERBAS, alltrim(TDP->RGB_PD))
                            AADD(ACOPART,{TDP->RGB_FILIAL,TDP->RGB_MAT,TDP->RGB_PD,TDP->RGB_PERIOD,TDP->RGB_SEMANA,TDP->RGB_SEQ,0,""})
                            for NY := 2 to ( len(ALOG[2])) step 1
                                ADADLOG := STRTOKARR(ALOG[2][NY]," ")
                                 if  len(ADADLOG)>5
                                     if TDP->RGB_FILIAL+TDP->RGB_MAT+TDP->RGB_PD==ADADLOG[3]+ADADLOG[4]+ substr(ADADLOG[5],1,3)
                                        CDADTXT := ADADLOG[1]+" "+ADADLOG[2]+"   "+ADADLOG[3]+"    "+ADADLOG[4]+"    "+ADADLOG[5]+" "+ADADLOG[6]+" "+ADADLOG[7]+" "+ADADLOG[8]+"    "+ADADLOG[9]+"                    "+PADL(ADADLOG[10],12)+"               "+"0,00"
                                        ALOG[2][NY] := CDADTXT
                                        exit 
                                    endif
                                endif
                            next
                        endif
                    endif
                    (TDP)->(DBSKIP())
                else 
                    AADD(ACOPART,{TDP->RGB_FILIAL,TDP->RGB_MAT,TDP->RGB_PD,TDP->RGB_PERIOD,TDP->RGB_SEMANA,TDP->RGB_SEQ,0,"D"})
                    for NY := 2 to ( len(ALOG[2])) step 1
                        ADADLOG := STRTOKARR(ALOG[2][NY]," ")
                         if  len(ADADLOG)>5
                             if TDP->RGB_FILIAL+TDP->RGB_MAT+TDP->RGB_PD==ADADLOG[3]+ADADLOG[4]+ substr(ADADLOG[5],1,3)
                                 if  len(ADADLOG)>10
                                    CDADTXT := ADADLOG[1]+" "+ADADLOG[2]+"   "+ADADLOG[3]+"    "+ADADLOG[4]+"    "+ADADLOG[5]+" "+ADADLOG[6]+" "+ADADLOG[7]+" "+ADADLOG[8]+"    "+ADADLOG[9]+"   "+ADADLOG[10]+"   "+PADR(ADADLOG[11],12)+"    "+"0,00 - Não calculou a coparticipação pois a Data esta fora do período de validade na tabela U052"
                                else 
                                    CDADTXT := ADADLOG[1]+" "+ADADLOG[2]+"   "+ADADLOG[3]+"    "+ADADLOG[4]+"    "+ADADLOG[5]+" "+ADADLOG[6]+" "+ADADLOG[7]+" "+ADADLOG[8]+"    "+ADADLOG[9]+"                    "+PADL(ADADLOG[10],12)+"    "+"0,00 - Não calculou a coparticipação pois a Data esta fora do período de validade na tabela U052"
                                endif
                                ALOG[2][NY] := CDADTXT
                                exit 
                            endif
                        endif
                    next
                    (TDP)->(DBSKIP())
                endif
            else 
                CMATRICULA := TDP->RGB_MAT
                NTOTCOPART := 0
                NTETO := 0
            endif
            end
        
        
        for NX := 1 to ( len(ACOPART)) step 1
            dbselectarea("RGB")
            (RGB)->(DBSETORDER(1))
            (RGB)->(DBGOTOP())
             if (RGB)->(DBSEEK(ACOPART[NX][1]+ACOPART[NX][2]+ACOPART[NX][3]+ACOPART[NX][4]+ACOPART[NX][5]+ACOPART[NX][6]))
                 if  alltrim(RGB->RGB_PD)<>"628"
                     if ACOPART[NX][7]>0
                        (RGB)->(RECLOCK("RGB", .F. ))
                        (RGB)->(RGB_VALOR) := ACOPART[NX][7]
                        (RGB)->(MSUNLOCK())
                    else 
                         if ACOPART[NX][8]=="D"
                            (RGB)->(RECLOCK("RGB", .F. ))
                            (RGB)->(RGB_VALOR) := ACOPART[NX][7]
                            (RGB)->(MSUNLOCK())
                        else 
                            (RGB)->(DBRLOCK())
                            (RGB)->(DBDELETE())
                            (RGB)->(DBCOMMIT())
                            (RGB)->(DBRUNLOCK())
                        endif
                    endif
                endif
            endif
        next
    endif
    
    RESTAREA(AAREA)
else 
    return 
endif

return ALOG
