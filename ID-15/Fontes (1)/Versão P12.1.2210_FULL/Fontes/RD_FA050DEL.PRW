











function U_FA050DEL()

local LRET :=  .T. 
local AAREA := GETAREA()
local CQUERY := ""
local CSEQCXA := ""
local CMV_FORINSS := SUPERGETMV("MV_FORINSS",,"")
local CMV_LOJINSS :=  strzero(0,TAMSX3("E2_LOJA")[1])

if .not. (EMPTY(SE2->E2_XCAIXIN))



    dbselectarea("SEU")
    DBSETORDER(1)
    
    CQUERY := " SELECT R_E_C_N_O_ AS RECNO, EU_FILIAL, EU_CAIXA FROM "+RETSQLNAME("SEU")+" "
    CQUERY += " WHERE EU_FILIAL = '"+XFILIAL("SEU")+"' AND EU_CAIXA = '"+SE2->E2_XCAIXIN+"'"
    CQUERY += " AND EU_XNUMTIT = '"+SE2->E2_NUM+"' AND EU_BAIXA = ' ' AND D_E_L_E_T_ = ' '"
    
    ; if SELECT("TMPSEU")>0
        dbselectarea("TMPSEU")
        (TMPSEU)->(DBCLOSEAREA())
    endif
    
    DBUSEAREA( .T. ,"TOPCONN",TCGENQRY(CQUERY),"TMPSEU", .F. , .T. )
    
    dbselectarea("SET")
    DBSETORDER(1)
    ; if DBSEEK(XFILIAL("SET")+SE2->E2_XCAIXIN)
        CSEQCXA := SET->ET_SEQCXA
    endif
    
    
    ;while .not. ((TMPSEU)->(EOF())); 
        
        (SEU)->(DBGOTO(TMPSEU->RECNO))
        RECLOCK("SEU", .F. )
        SEU->EU_SEQCXA := CSEQCXA
        SEU->EU_XNUMTIT := " "
        (SEU)->(MSUNLOCK())
        
        (TMPSEU)->(DBSKIP()); end
endif





CMV_FORINSS := LEFT( alltrim(CMV_FORINSS)+"          ",TAMSX3("E2_FORNECE")[1])
if .not. (( upper( alltrim(FUNNAME()))) $ ("ETX_BRWS|AGL_MRKB|ETX_CANC|AGL_BRWE"))
    ; if SE2->E2_PREFIXO="AGI" .and. SE2->E2_TIPO="INS" .and. SE2->E2_FORNECE=CMV_FORINSS
        iif(FINDFUNCTION("APMsgStop"),APMSGSTOP("Este Título é um Aglutinador de INSS, para a Exclusão, deve-se utilizar a Rotina de Aglutinação de INSS","Erro"),MSGSTOP("Este Título é um Aglutinador de INSS, para a Exclusão, deve-se utilizar a Rotina de Aglutinação de INSS","Erro"))
        LRET :=  .F. 
    endif
endif


RESTAREA(AAREA)
return LRET
