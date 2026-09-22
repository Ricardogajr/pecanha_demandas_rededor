#Include 'Protheus.ch'
/*
{Protheus.doc} ORG030GRV()
Ponto de Entrada para contar os funcionários titulares e substitutos
e preencher , respectivamente, os campos RCL_OPOSTO (titulares+substitutos)e RCL_XSPOST (substitutos) 
@Author     Rogerio Carvalho - AMS Rio - DOR05218784
@Since      15/10/2018
@Version    P12.1.07
@Project    
*/

User Function ORG030GRV()

	Local cQueryT := ""
	Local cQueryS := ""
	Local nQtdTit := 0
	Local nQtdSub := 0
    Local aAreaAnt := getarea()	
	
	// Conta o numero de titulares no posto
	cQueryT := " SELECT count(*) RCXTITUL "
	cQueryT += " FROM RCX010 "
    cQueryT += " WHERE D_E_L_E_T_=' ' "
    cQueryT += " AND RCX_POSTO= '"+RCL->RCL_POSTO+"' "
    cQueryT += " AND RCX_FILIAL= '"+RCL->RCL_FILIAL+"' "
    cQueryT += " AND RCX_SUBST= '2' "

    If Select("ALIRCXT") > 0
		ALIRCXT->(DbCloseArea())
	EndIf
    
	cQueryT := ChangeQuery(cQueryT)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQueryT),"ALIRCXT")
	
	DbSelectArea("ALIRCXT")
	While !ALIRCXT->(EOF())
			nQtdTit += ALIRCXT->RCXTITUL // acumula o total de titulares
			ALIRCXT->(dbskip())
	Enddo

	// Conta o numero de substitutos no posto
	cQueryS := " SELECT count(*) RCXSUB "
	cQueryS += " FROM RCX010 "
    cQueryS += " WHERE D_E_L_E_T_=' ' "
    cQueryS += " AND RCX_POSTO= '"+RCL->RCL_POSTO+"' "
    cQueryS += " AND RCX_FILIAL= '"+RCL->RCL_FILIAL+"' "
    cQueryS += " AND RCX_SUBST= '1' "
    
    If Select("ALIRCXS") > 0
		ALIRCXS->(DbCloseArea())
	EndIf
	
	cQueryS := ChangeQuery(cQueryS)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQueryS),"ALIRCXS")
	
	DbSelectArea("ALIRCXS")
	While !ALIRCXS->(EOF())
			nQtdSub += ALIRCXS->RCXSUB //acumula o total de substitutos
		    ALIRCXS->(dbskip()) 
	Enddo

	If (RCL->RCL_OPOSTO <> nQtdTit+nQtdSub) .or. (RCL->RCL_XSPOST <> nQtdSub) 
	
		MsgInfo("Titulares : "+CVALTOCHAR(nQtdTit)+" / Substitutos : "+CVALTOCHAR(nQtdSub),"Filial : "+RCL->RCL_FILIAL+" / Posto : "+RCL->RCL_POSTO)

		RecLock('RCL',.F.)
		
			RCL->RCL_OPOSTO := nQtdTit+nQtdSub
			RCL->RCL_XSPOST	:= nQtdSub
			
		MsUnLock()						
			
	Endif
		    
	ALIRCXS->(DbCloseArea())
	
	ALIRCXT->(DbCloseArea())

    restarea(aAreaAnt)		    
Return
