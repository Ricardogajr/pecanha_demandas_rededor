#INCLUDE "PROTHEUS.CH"
#INCLUDE "TopConn.ch"
#include "RWMAKE.CH"
#INCLUDE "TBICONN.CH"

///////////////////////
User Function UPD0279()
///////////////////////
    Local aPergs  := {}
	Local cFilDe  := Space(TamSX3('RA_FILIAL')[01])
	Local cFilAte := Space(TamSX3('RA_FILIAL')[01])

    If .not.(ApOleClient("MSExcel"))
	    MsgAlert("Microsoft Excel nao esta instalado!")
	    Return
    Endif
    
	// ** Adiciona os parametros para a pergunta
	aAdd(aPergs, {1, "Filial De",   cFilDe, "", ".T.", "SM0", ".T.", 50, .T.})
	aAdd(aPergs, {1, "Filial Ate",   cFilAte, "", ".T.", "SM0", ".T.", 50, .T.})
	
	// ** Mostra uma pergunta com parambox para filtrar **
	If ParamBox(aPergs, "Informe os parametros", , , , , , , , , .F., .F.)
	   If MV_PAR01 > MV_PAR02
          MsgStop( "Erro nos Parametros, Fim da Rotina", "UPD0279" )
	   Else
          MsAguarde({|lEnd| LerArq()},"Aguarde...","Processando...",.T.)
          MsgStop( "Fim da Rotina", "UPD0279" )
	   Endif
	Endif
Return

////////////////////////
Static Function LerArq()
////////////////////////

Local cQry := ""
Local nCount := 0
LOCAL OEXCEL                                            
LOCAL CTEMPPATH:= GETTEMPPATH()
LOCAL CDIRSRV  := '\SPOOL\'
LOCAL CARQ     := "LISTASRB.CSV"
Local aTotais  := {}

Aadd(aTotais ,{"CPF EM BRANCO                     ",0})
Aadd(aTotais ,{"CPF INVALIDO                      ",0})
Aadd(aTotais ,{"CPF DEPENDENTE IGUAL AO DO TITULAR",0})
Aadd(aTotais ,{"CPF DUPLICADO                     ",0})
Aadd(aTotais ,{"CPF OK                            ",0})

CARQ4  := cDirSrv+cArq
nHandle4 := Fcreate(cArq4,0)		// cria o arquivo
If Ferror() != 0 
   Conout("houve erro na criação do arquivo UPD0264.CSV")
endif                        

cMsg := "LISTA DE DEPENDENTES COM PROBLEMA CPF"+CRLF
FWrite(nHandle4,cMsg,Len(cMsg))    
cMsg := "FILIAL;MATRICULA;NOME FUNCIONARIO;CPF FUNCIONARIO;ADMISSAO;DEMISSAO;NDEP;NOME DEPENDENTE;CPF DEPENDENTE;STATUS"+CRLF
FWrite(nHandle4,cMsg,Len(cMsg))    

cQry := "SELECT * FROM "+RETSQLNAME("SRB")+" SRB, "+RETSQLNAME("SRA")+" SRA, (SELECT DISTINCT RHL_FILIAL,RHL_MAT, RHL_CODIGO FROM "+RETSQLNAME("RHL")+" WHERE D_E_L_E_T_<>'*' ) RHL "+CRLF
cQry += "WHERE SRA.D_E_L_E_T_<>'*' "+CRLF
cQry += "  AND SRB.D_E_L_E_T_<>'*' "+CRLF
cQry += "  AND (SRA.RA_DEMISSA =' ' OR (SRA.RA_DEMISSA>'20191231' AND SRA.RA_RESCRAI NOT IN('30','31'))) "+CRLF
cQry += "  AND SRA.RA_FILIAL BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"' "+CRLF
cQry += "  AND SRB.RB_FILIAL  = SRA.RA_FILIAL "+CRLF
cQry += "  AND SRB.RB_MAT     = SRA.RA_MAT "+CRLF
cQry += "  AND RHL.RHL_FILIAL = SRB.RB_FILIAL "+CRLF
cQry += "  AND RHL.RHL_MAT    = SRB.RB_MAT "+CRLF
cQry += "  AND RHL.RHL_CODIGO = SRB.RB_COD "+CRLF
cQry += " Order by SRB.RB_FILIAL,SRB.RB_MAT,SRB.RB_COD "+CRLF
cQry := changequery(cQry) 
TCQUERY cQry ALIAS "TM01" NEW
dbSelectArea("TM01")
TM01->(DBGOTOP())
If !TM01->(EOF())
    Do While !TM01->(EOF())     
  	   cMsg := 'Processando ... '+TM01->RB_FILIAL+'-'+TM01->RB_MAT+'-'+TM01->RB_COD
       MsProcTxt(cMsg)	
       ProcessMessage()           
       D1 := STOD(TM01->RA_ADMISSA)
       D2 := DTOC(D1)
       D3 := STOD(TM01->RA_DEMISSA)
       D4 := DTOC(D3)
       IF EMPTY(TM01->RB_CIC)
          cmsg1 := TM01->RB_FILIAL+";"+TM01->RB_MAT+";"+TM01->RA_NOME+";"+TM01->RA_CIC+";"+D2+";"+D4+";"+TM01->RB_COD+";"+TM01->RB_NOME+";"+TM01->RB_CIC+";"+"CPF EM BRANCO"+CRLF
          FWrite(nHandle4,cMsg1,Len(cMsg1))    
		  aTotais[1,2]++
       ELSE
          IF !ChkCPF2(TM01->RB_CIC)
             cmsg1 := TM01->RB_FILIAL+";"+TM01->RB_MAT+";"+TM01->RA_NOME+";"+TM01->RA_CIC+";"+D2+";"+D4+";"+TM01->RB_COD+";"+TM01->RB_NOME+";"+TM01->RB_CIC+";"+"CPF INVALIDO"+CRLF
             FWrite(nHandle4,cMsg1,Len(cMsg1))    
		     aTotais[2,2]++
          ELSE
             IF ALLTRIM(TM01->RB_CIC) == ALLTRIM(TM01->RA_CIC)
                cmsg1 := TM01->RB_FILIAL+";"+TM01->RB_MAT+";"+TM01->RA_NOME+";"+TM01->RA_CIC+";"+D2+";"+D4+";"+TM01->RB_COD+";"+TM01->RB_NOME+";"+TM01->RB_CIC+";"+"CPF DEPENDENTE IGUAL AO DO TITULAR"+CRLF
                FWrite(nHandle4,cMsg1,Len(cMsg1))    
		        aTotais[3,2]++
             ELSE
                IF TemDupcpf(TM01->RB_CIC,TM01->RB_FILIAL,TM01->RB_MAT,TM01->RB_COD)
                   cmsg1 := TM01->RB_FILIAL+";"+TM01->RB_MAT+";"+TM01->RA_NOME+";"+TM01->RA_CIC+";"+D2+";"+D4+";"+TM01->RB_COD+";"+TM01->RB_NOME+";"+TM01->RB_CIC+";"+"CPF DUPLICADO"+CRLF
                   FWrite(nHandle4,cMsg1,Len(cMsg1))    
		           aTotais[4,2]++
                ELSE
                   cmsg1 := TM01->RB_FILIAL+";"+TM01->RB_MAT+";"+TM01->RA_NOME+";"+TM01->RA_CIC+";"+D2+";"+D4+";"+TM01->RB_COD+";"+TM01->RB_NOME+";"+TM01->RB_CIC+";"+"CPF OK"+CRLF
                   FWrite(nHandle4,cMsg1,Len(cMsg1))    
		           aTotais[5,2]++
                ENDIF
             ENDIF
          ENDIF
       ENDIF  
       
       dbSelectArea("TM01")
       TM01->(DBSKIP())
    EndDo                       
Endif
cmsg1 := "  "+CRLF
FWrite(nHandle4,cMsg1,Len(cMsg1))    
cmsg1 := "  "+CRLF
FWrite(nHandle4,cMsg1,Len(cMsg1))    
cmsg1 := " "+";"+" "+";"+"TOTAIS"+CRLF
FWrite(nHandle4,cMsg1,Len(cMsg1))    
cmsg1 := " "+";"+" "+";"+aTotais[1,1]+";"+Strzero(atotais[1,2],9,0)+CRLF
FWrite(nHandle4,cMsg1,Len(cMsg1))    
cmsg1 := " "+";"+" "+";"+aTotais[2,1]+";"+Strzero(atotais[2,2],9,0)+CRLF
FWrite(nHandle4,cMsg1,Len(cMsg1))    
cmsg1 := " "+";"+" "+";"+aTotais[3,1]+";"+Strzero(atotais[3,2],9,0)+CRLF
FWrite(nHandle4,cMsg1,Len(cMsg1))    
cmsg1 := " "+";"+" "+";"+aTotais[4,1]+";"+Strzero(atotais[4,2],9,0)+CRLF
FWrite(nHandle4,cMsg1,Len(cMsg1))    
cmsg1 := " "+";"+" "+";"+aTotais[5,1]+";"+Strzero(atotais[5,2],9,0)+CRLF
FWrite(nHandle4,cMsg1,Len(cMsg1))    

cMsg := 'Executando Carga EXCEL'
MsProcTxt(cMsg)	
ProcessMessage()           
TM01->(dbCloseArea())
fclose (nHandle4)    

CPYS2T(CDIRSRV+CARQ, CTEMPPATH)
OEXCEL:=MSEXCEL():NEW()
OEXCEL:WORKBOOKS:OPEN(CTEMPPATH+CARQ)
OEXCEL:SETVISIBLE(.T.)
OEXCEL:DESTROY()

Return 

///////////////////////////////
Static Function TemDupcpf(cCic,cFil,cMat,cCod)
///////////////////////////////

Local lRet := .T.
Local cQry := ""
Local nCount := 0

If !Empty(cCic)
   If Select("TSR8") > 0
      dbSelectArea("TSR8")
	  TSR8->(dbCloseArea())
   EndIf
   cQry := "SELECT SRB.RB_FILIAL FILIAL, SRB.RB_MAT MAT, SRB.RB_COD DEP, SRB.RB_NOME NOME, SRB.RB_CIC CPF"
   cQry += "  FROM "+ RETSQLNAME('SRB')+" SRB "
   cQry += " WHERE SRB.D_E_L_E_T_=''"
   cQry += "   AND SRB.RB_CIC = '"+cCic+"' "

   cQry := changequery(cQry) 
   TCQUERY cQry ALIAS "TSR8" NEW
   dbSelectArea("TSR8")
   TSR8->(DbGoTop())
   If !TSR8->(EOF())
	  Do While !TSR8->(EOF())     
         IF !(TSR8->FILIAL = cFil .And. TSR8->MAT = cMat .And. STRZERO(VAL(TSR8->DEP),2,0) = STRZERO(VAL(cCod),2,0))
             DbSelectArea("SRA")
             DbSetOrder(1)
    	     If dbSeek(TSR8->FILIAL+TSR8->MAT)
                IF Empty(("SRA")->RA_DEMISSA)
                   nCount ++
                Endif
             Endif
         Endif
         dbSelectArea("TSR8")
	     TSR8->(DBSKIP())
	  EndDo                       
   Endif
   TSR8->(dbCloseArea())
Endif

If nCount > 0
   lOk := .T. 
Endif

Return lOk

Static Function ChkCPF2(cCPF)
Local nCic01	:= nCic02	:= nCic03 := nCic04 := nCic05 := 0
Local nCic06	:= nCic07	:= nCic08 := nCic09 := nCic10 := nCic11 := 0
Local nXcic 	:= nYcic 	:= nWcic  := nKcic  := 0
Local nDig1Cic := nDig2Cic := 0

If Replicate(Left(cCPF,1),11) = cCPF
	Return (.F.)
Endif

nCic01  := Val(SubStr(cCPF,01,01))
nCic02  := Val(SubStr(cCPF,02,01))
nCic03  := Val(SubStr(cCPF,03,01))
nCic04  := Val(SubStr(cCPF,04,01))
nCic05  := Val(SubStr(cCPF,05,01))
nCic06  := Val(SubStr(cCPF,06,01))
nCic07  := Val(SubStr(cCPF,07,01))
nCic08  := Val(SubStr(cCPF,08,01))
nCic09  := Val(SubStr(cCPF,09,01))
nCic10  := Val(SubStr(cCPF,10,01))
nCic11  := Val(SubStr(cCPF,11,01))

// Consistencia do 1?Numero do Digito
nXcic := (nCic01 * 10) + (nCic02 * 9) + (nCic03 * 8) + (nCic04 * 7) + (nCic05 * 6)
nXcic += (nCic06 *  5) + (nCic07 * 4) + (nCic08 * 3) + (nCic09 * 2)
nYcic := Int( nXcic / 11 )
nWcic := nYcic * 11
nKcic := nXcic - nWcic

If nKcic = 0 .OR. nKcic = 1
	nDig1Cic := 0
Else
	nDig1Cic := 11 - nKcic
Endif

If nDig1Cic != nCic10
	Return (.F.)
Endif

// Consistencia do 2?Numero do Digito
nXcic := (nCic01 * 11) + (nCic02 * 10) + (nCic03 * 9) + (nCic04 * 8) + (nCic05 * 7)
nXcic += (nCic06 *  6) + (nCic07 *	5) + (nCic08 * 4) + (nCic09 * 3) + (nCic10 * 2)
nYcic = Int( nXcic / 11 )
nWcic = nYcic * 11
nKcic = nXcic - nWcic

If nKcic = 0 .OR. nKcic = 1
	nDig2Cic = 0
Else
	nDig2Cic = 11 - nKcic
Endif

If nDig2Cic != nCic11
	Return (.F.)
Endif

Return (.T.)
