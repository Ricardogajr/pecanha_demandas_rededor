#include 'rwmake.ch'
#include 'Protheus.ch'
#include 'Fileio.ch'

User Function AMSAJMAT()
	
	Private aTabCmp := {}
	Private aMatDup := {}
	
	Processa({|| u_le_tabcamp()},"Processando Arquivos...")
	Processa({|| u_le_matric()} ,"Processando Arquivos...")
	Processa({|| u_atu_matric()},"Atualizando Matriculas...")

	
Return

User Function le_tabcamp()

	Local cArqTab := "c:\ajustamat\tabelas x campos.csv"  // arquivo com tabelas e campos
	Local cLinTC  := ""
	Local nLTC	  := 0
 
	If !File(cArqTab)
		MsgStop("O arquivo " +cArqTab + " não foi encontrado. A atualização dos dados de MATRÍCULA será abortada!"," ATENCAO ")
		Return
	EndIf

	// abre arquivo de tabelas e campos para uso
	FT_FUSE(cArqTab)
	ProcRegua(FT_FLASTREC())
	FT_FGOTOP()
	nLTC := 0

	// enquanto não for fim de arquivo , preenche vetor com tabelas e campos
	While !FT_FEOF()
 
		IncProc("Lendo arquivo de TABELASxCAMPOS")
 
		cLinTC := FT_FREADLN()
		nLTC += 1
		
		AADD(aTabCmp,StrTokArr( cLinTC , ";" ))

		FT_FSKIP()
		
	EndDo

Return

User Function le_matric()

	Local cArqMat := "c:\ajustamat\matriculas.csv"		 // arquivo com matriculas
	Local cLinMT  := ""
	Local nLMT    := 0

	If !File(cArqMat)
		MsgStop("O arquivo " +cArqMat + " não foi encontrado. A atualização dos dados de MATRÍCULA será abortada!"," ATENCAO ")
		Return
	EndIf
 
    // abre arquivo de matriculas para uso
	FT_FUSE(cArqMat)
	ProcRegua(FT_FLASTREC())
	FT_FGOTOP()
	nLMT := 0
	
	// enquanto não for fim de arquivo , preenche vetor com tabelas e campos
	While !FT_FEOF()
 
		IncProc("Lendo arquivo de MATRICULAS")
 
		cLinMT := FT_FREADLN()
		nLMT   += 1
		
		AADD(aMatDup,StrTokArr( cLinMT , ";" ))

		FT_FSKIP()
		
	EndDo
	
Return

User Function atu_matric()

	Local xMat     := 0
	Local xTab     := 0
	Local nMatNum  := 0
	Local cMatNova := ""
	Local cQuery   := ""
	Local strAJMAT := ""
	Local nTabSim  := 0
	Local nTabNao  := 0
	Local nStatus  := ""
    local nHandle  := FCREATE("c:\ajustamat\logajustamat.txt")
  
    if nHandle = -1
        alert("Erro ao criar arquivo de logr " + Str(Ferror()))
        return
    endif
    
	cQuery := " SELECT MAX(RA_MAT) MAXMAT "
	cQuery += " FROM SRA010 "

	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN", TcGenQry(,,cQuery),"TMPMAX")
	dbSelectArea("TMPMAX")
    nMatNum  := val(TMPMAX->MAXMAT) 
    ProcRegua(len(aMatDup))
    ProcRegua(len(aTabCmp))
    			
	For xMat := 1 to len(aMatDup)  // laco de repeticao de matriculas
	    
	    nTabSim  := 0
	    nTabNao  := 0
	    
	    nMatNum += 1 

	    cMatNova := cvaltochar(nMatNum)
		
		For xTab := 1 to len(aTabCmp) // laco de repeticao de tabelas e campos
		
		    IncProc("Fazendo "+cvaltochar(xMat)+" / "+cvaltochar(len(aMatDup))+" Matriculas  em "+cvaltochar(xTab)+" / "+cvaltochar(len(aTabCmp))+" Tabelas ")
			
			strAJMAT := " UPDATE "+aTabCmp[xTab][01]+"010 "
			strAJMAT += " SET "+aTabCmp[xTab][02]+" = '"+cMatNova+"' "
			strAJMAT += " WHERE "+aTabCmp[xTab][03]+"='"+padl(aMatDup[xMat][01],8,'0')+"' "
			strAJMAT += " AND "+aTabCmp[xTab][02]+" ='"+padl(aMatDup[xMat][02],6,'0')+"' "
			
			nStatus := Tcsqlexec(strAJMAT)
			
			if (nStatus < 0)

				FWrite(nHandle, Time() + "   SEM SUCESSO ====>>>> " + TCSQLError() + CRLF)
				nTabNao+=1

			Else
				FWrite(nHandle, Time() + "   CONCLUÍDO ====>>>> " + strAJMAT + CRLF)			
			    nTabSim+=1
			    
			endif
	    
			if xTab == len(aTabCmp)
				FWrite(nHandle,CRLF+CRLF+ Time() + "   CONCLUÍDO ====>>>> " + cvaltochar(nTabSim)+" Tabelas.")			
				FWrite(nHandle,CRLF+ Time() + "   SEM SUCESSO ====>>>> " + cvaltochar(nTabNao)+" Tabelas.")

				FWrite(nHandle,CRLF+ "---------------------------------------------------------------------"+ CRLF)
	
			endif

	    Next
	    
	Next
	FWrite(nHandle,CRLF+ cvaltochar(len(aMatDup)) + " matriculas ajustadas.")
	FClose(nHandle)
	dbCloseArea()		
Return	