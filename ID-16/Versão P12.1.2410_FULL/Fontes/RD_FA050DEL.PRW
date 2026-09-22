#Include 'Protheus.ch' 
#Include 'TopConn.Ch'

User function FA050DEL()

Local LRET :=  .T. 
Local AAREA := FWGETAREA()
Local CQUERY := ""
Local CSEQCXA := ""
Local CMV_FORINSS := SUPERGETMV("MV_FORINSS",,"")
Local CMV_LOJINSS :=  strzero(0,TAMSX3("E2_LOJA")[1])

If !(EMPTY(SE2->E2_XCAIXIN))

    dbselectarea("SEU")
    DBSETORDER(1)
    
    CQUERY := " SELECT R_E_C_N_O_ AS RECNO, EU_FILIAL, EU_CAIXA FROM "+RETSQLNAME("SEU")+" "
    CQUERY += " WHERE EU_FILIAL = '"+XFILIAL("SEU")+"' AND EU_CAIXA = '"+SE2->E2_XCAIXIN+"'"
    CQUERY += " AND EU_XNUMTIT = '"+SE2->E2_NUM+"' AND EU_BAIXA = ' ' AND D_E_L_E_T_ = ' '"
    
    If Select("TMPSEU") > 0
		DbSelectArea("TMPSEU")
		TMPSEU->(DbCloseArea())
	EndIf
    
    TCQUERY cQuery New Alias "TMPSEU" //DBUSEAREA( .T. ,"TOPCONN",TCGENQRY(CQUERY),"TMPSEU", .F. , .T. )
    
    dbselectarea("SET")
    DBSETORDER(1)
    If DBSEEK(XFILIAL("SET")+SE2->E2_XCAIXIN)
        CSEQCXA := SET->ET_SEQCXA
    endif
    
    
    While !TMPSEU->(Eof())
	
		SEU->(DbGoTo(TMPSEU->RECNO))
		RecLock("SEU", .F.)
		SEU->EU_SEQCXA  := cSeqCxa
		SEU->EU_XNUMTIT := " "
		SEU->(MsUnLock())
			
		TMPSEU->(DbSkip())
	
	EndDo
	
endif

CMV_FORINSS := LEFT( alltrim(CMV_FORINSS)+"          ",TAMSX3("E2_FORNECE")[1])

If !(( upper( alltrim(FUNNAME()))) $ ("ETX_BRWS|AGL_MRKB|ETX_CANC|AGL_BRWE"))
    if SE2->E2_PREFIXO="AGI" .and. SE2->E2_TIPO="INS" .and. SE2->E2_FORNECE=CMV_FORINSS
        MSGSTOP("Este Título é um Aglutinador de INSS, para a Exclusão, deve-se utilizar a Rotina de Aglutinação de INSS","Erro")
        LRET :=  .F. 
    endif
endif

FWRESTAREA(AAREA)

Return LRET
