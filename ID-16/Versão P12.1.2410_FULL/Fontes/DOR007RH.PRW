#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"

//////////////////////////////////////////////////////////////////////////////////////////
//+------------------------------------------------------------------------------------+//
//| PROJETO CONECTA REDE Dï¿½OR    |  MODULO | SIGAGPE                                 |//
//+------------------------------------------------------------------------------------+//
//| PROGRAMA  | DOR007RH | AUTOR | Edsonho ï¿½                | DATA | 21/06/2017      |//
//+------------------------------------------------------------------------------------+//
//| DESCRICAO | Funï¿½ï¿½o: Bloqueio de Acesso, conf.perï¿½odo informa na Tabela U013  |//
//|                     Rotina Padrï¿½o MDTA685 ï¿½ Atestado Mï¿½dico                  |//
//+------------------------------------------------------------------------------------+//
//| MELHORIA | DOR04842295 | AUTOR | Paulo Dias               | DATA | 07/11/2018      |//
//+------------------------------------------------------------------------------------+//
//| DESCRICAO | Permissão de lançamentos de atestados médicos durante o período        |//
//|             de blackout da folha de pagamento                                      |//
//+------------------------------------------------------------------------------------+//
//////////////////////////////////////////////////////////////////////////////////////////

User Function DOR007RH()

Local aArea    := GetArea()
Local cFilU013 := cFilAnt
Local nPosU013 := 0
Local cTabela  := "U013" // "U001" 
Local TMPSR8   := GetNextAlias()
Local TMPTNY   := GetNextAlias()
Local cQSR8    := ""
Local cQTNY    := ""

nPosU013 := U_DORBLK(cFilU013,cTabela)

DbSelectArea("TNY")
TNY->(DbSetOrder(1))

If nPosU013 > 0 // Dentro do período de Blackout
      /*
      cQTNY := " Select * from (                             " 
      cQTNY += " select R_E_C_N_O_ RECNO                     "
      cQTNY += " from TNY010 TNY                             "
      cQTNY += " where TNY.D_E_L_E_T_   = ' '            And   "
      cQTNY += " TNY.TNY_FILIAL='"+TM0->TM0_FILIAL+"'    And   "
      cQTNY += " TNY.TNY_NUMFIC   ='"+TM0->TM0_NUMFIC+"'       And   "
      cQTNY += " TNY.R_E_C_N_O_ = (select max(TNY.R_E_C_N_O_)        "
      cQTNY += " from TNY010 TNY                             "
      cQTNY += " where  TNY.D_E_L_E_T_   = ' '           And   "
      cQTNY += " TNY.TNY_FILIAL='"+TM0->TM0_FILIAL+"'    And   "
      cQTNY += " TNY.TNY_NUMFIC   ='"+TM0->TM0_NUMFIC+"' )           "
      cQTNY += " Order by TNY.R_E_C_N_O_ desc)                   "                            "

      cQTNY := ChangeQuery(cQTNY)

      If Select(TMPTNY) > 0
            DbSelectArea(TMPTNY)
            (TMPTNY)->(DbCloseArea())  
      Endif

      dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQTNY),TMPTNY, .F., .T.)
      dbSelectArea(TMPTNY)

      If (TMPTNY)->(!Eof())
         dbSelectArea("TNY")
         dbSetOrder(1)
         dbGoTo((TMPTNY)->(RECNO))
      */
      //   TNY->(DBGOTO(RECNO()))
         RecLock("TNY",.F.)
      // preenchimento dos campos customizados para o E-Social.
         TNY->TNY_XDTSAI  := TNY->TNY_DTSAID
         TNY->TNY_XDALT   := TNY->TNY_DTALTA
         TNY->TNY_XQTDIA  := TNY->TNY_QTDIAS
         TNY->TNY_XCODAF  := TNY->TNY_CODAFA
         TNY->TNY_XTPEFD  := TNY->TNY_TPEFD
         TNY->TNY_XDTBLK  := DATE() // Flag

         TNY->(MsUnlock())

      //EndIf 

      cQSR8 := " Select * from (                             " 
      cQSR8 += " select R_E_C_N_O_ RECNO                     "
      cQSR8 += " from SR8010 SR8                             "
      cQSR8 += " where SR8.D_E_L_E_T_   = ' '            And   "
      cQSR8 += " SR8.R8_FILIAL='"+SRA->RA_FILIAL+"'    And   "
      cQSR8 += " SR8.R8_MAT   ='"+SRA->RA_MAT+"'       And   "
      cQSR8 += " SR8.R8_SEQ = (select max(SR8.R8_SEQ)        "
      cQSR8 += " from SR8010 SR8                             "
      cQSR8 += " where  SR8.D_E_L_E_T_   = ' '           And   "
      cQSR8 += " SR8.R8_FILIAL='"+SRA->RA_FILIAL+"'    And   "
      cQSR8 += " SR8.R8_MAT   ='"+SRA->RA_MAT+"' )           "
      cQSR8 += " Order by SR8.R8_SEQ desc)                   "                            "

      cQSR8 := ChangeQuery(cQSR8)

      If Select(TMPSR8) > 0
            DbSelectArea(TMPSR8)
            (TMPSR8)->(DbCloseArea())  
      Endif

      dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQSR8),TMPSR8, .F., .T.)
      dbSelectArea(TMPSR8)

      If (TMPSR8)->(!Eof())
         dbSelectArea("SR8")
         dbSetOrder(1)
         dbGoTo((TMPSR8)->(RECNO))

      RecLock("SR8",.F.) 
      // preenchimento dos campos customizados para o E-Social
      SR8->R8_XDTINI := M->TNY_DTSAID
      SR8->R8_XDTFIM := M->TNY_DTALTA
      SR8->R8_XDURAC := M->TNY_QTDIAS
      SR8->R8_XTPEFD := M->TNY_TPEFD
      // Limpo os campos padrões da SR8 para não contabilizar na folha de pagamento
      SR8->R8_DATAINI := CTOD("  /  /  ")
      SR8->R8_DATAFIM := CTOD("  /  /  ")
      SR8->R8_DURACAO := 0
      SR8->R8_TPEFD   := "  "  
      SR8->R8_STATUS  := " " //atualização no chamado: DOR06517008

      SR8->(MsUnlock()) 

      Endif

Else //Fora do período de Blackout

      cQSR8 := " Select * from (                             " 
      cQSR8 += " select R_E_C_N_O_ RECNO                     "
      cQSR8 += " from SR8010 SR8                             "
      cQSR8 += " where SR8.D_E_L_E_T_   = ' '            And   "
      cQSR8 += " SR8.R8_FILIAL='"+SRA->RA_FILIAL+"'    And   "
      cQSR8 += " SR8.R8_MAT   ='"+SRA->RA_MAT+"'       And   "
      cQSR8 += " SR8.R8_SEQ = (select max(SR8.R8_SEQ)        "
      cQSR8 += " from SR8010 SR8                             "
      cQSR8 += " where  SR8.D_E_L_E_T_   = ' '           And   "
      cQSR8 += " SR8.R8_FILIAL='"+SRA->RA_FILIAL+"'    And   "
      cQSR8 += " SR8.R8_MAT   ='"+SRA->RA_MAT+"' )           "
      cQSR8 += " Order by SR8.R8_SEQ desc)                   "                            "

      cQSR8 := ChangeQuery(cQSR8)

      If Select(TMPSR8) > 0
            DbSelectArea(TMPSR8)
            (TMPSR8)->(DbCloseArea())  
      Endif

      dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQSR8),TMPSR8, .F., .T.)
      dbSelectArea(TMPSR8)

      If (TMPSR8)->(!Eof())
         dbSelectArea("SR8")
         dbSetOrder(1)
         dbGoTo((TMPSR8)->(RECNO))

         RecLock("SR8",.F.) 
      // preenchimento dos campos customizados para o E-Social
      SR8->R8_XDTINI := M->TNY_DTSAID
      SR8->R8_XDTFIM := M->TNY_DTALTA
      SR8->R8_XDURAC := M->TNY_QTDIAS
      SR8->R8_XTPEFD := M->TNY_TPEFD

      SR8->(MsUnlock()) 

      Endif
EndIf


RestArea(aArea)


Return

/*
BLOQ.ACESSO ATEST/LICEN Mï¿½DICA
DTAINIBLOC Data 8 Data Inicio do Bloqueio  
DTAFIMBLOC Data 8 Data Fim do Bloqueio     

aDataBloq[1,5]
01/06/2017
aDataBloq[1,6]
30/06/2017

dDta := Ctod("05/07/2017")
05/07/2017
Ascan(aDataBloq,{|x| x[1] == "U013" .And. dDta >= x[5] .And. dDta <= x[6]})
1

dDta := Ctod("05/06/2017")
05/06/2017
Ascan(aDataBloq,{|x| x[1] == "U013" .And. dDta >= x[5] .And. dDta <= x[6]})
0

Liberar o acesso a rotina padrï¿½o
MDTA685 ï¿½ Atestado Medico
MDTA920 ï¿½ Licenï¿½a Medica.


*/

//-----------------------------------------------//
// Função para validação do período de blackout  //
//-----------------------------------------------//
User Function DORBLK(cFil,cTab)

Local aArea    := GetArea()
Local aDataBloq:= {}
Local cFilU013 := cFil
Local nPosU013 := 0
Local cTabela  := cTab

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
EndIf

RestArea(aArea) 

Return nPosU013
