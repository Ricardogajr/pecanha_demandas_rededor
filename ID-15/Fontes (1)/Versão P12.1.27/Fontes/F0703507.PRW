#include 'protheus.ch'
#include 'parmtype.ch'
/*{Protheus.doc} F0703507
Função responsável para derrubar Thread após um determinado tempo de execução.
@author Reinaldo Dias
@since 24/07/2018
@version 1.0
@Project 
@param oParam, object, descricao
@return 
*/
User Function F0703507(aParam)
 
Local cKILLTHR
Local aThreads
Local nI

//Libera o Ambiente
RPCClearEnv()

//Seta job para nao consumir licensas
RpcSetType(3)
     
// Seta job para empresa filial desejada
RPCSetEnv(aParam[1],aParam[2],,,"EST")

cKILLTHR := Alltrim(SuperGetMV('FS_KILLTHR', .F., "00:10:00"))

aThreads := GetUserInfoArray()
/*
Sintaxe: GetUserInfoArray ( ) --> aRet
Retorno : aRet(array_of_record) 
Retorna um array multidimensional com os números e dados de cada uma das threads.
aInfo[x][01] = (C) Nome de usuário
aInfo[x][02] = (C) Nome da máquina local
aInfo[x][03] = (N) ID da Thread
aInfo[x][04] = (C) Servidor (caso esteja usando Balance; caso contrário é vazio)
aInfo[x][05] = (C) Nome da função que está sendo executada
aInfo[x][06] = (C) Ambiente(Environment) que está sendo executado
aInfo[x][07] = (C) Data e hora da conexão
aInfo[x][08] = (C) Tempo em que a thread está ativa (formato hh:mm:ss)
aInfo[x][09] = (N) Número de instruções
aInfo[x][10] = (N) Número de instruções por segundo
aInfo[x][11] = (C) Observações
aInfo[x][12] = (N) (*) Memória consumida pelo processo atual, em bytes
aInfo[x][13] = (C) (**) SID - ID do processo em uso no TOPConnect/TOTVSDBAccess, caso utilizado.
*/
For nI := 1 To Len(aThreads) 
  If aThreads[nI,3] <> ThreadId() .And. "W0703501" $ aThreads[9,11] .And.  aThreads[nI,8] >=  cKILLTHR
	 fGrvLogThr(aThreads,nI)
           //(UserName      ,ComputerName  ,ThreadId      , ServerName )	 
	 KillUser(aThreads[nI,1],aThreads[nI,2],aThreads[nI,3],aThreads[nI,2])
  EndIf
Next

RpcClearEnv()

Return


/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
Static Function fGrvLogThr(aThreads,nI)
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
Local aArea      := GetArea()

CriaAbreLOG() //Cria e abre a tabela de LOG do produto
  
RecLock("LOG_THREAD",.T.)
LOG_THREAD->DATAATU    := MsDate() 
LOG_THREAD->HORAATU    := Time() 
LOG_THREAD->USUARIO    := aThreads[nI,01] //Nome de usuário
LOG_THREAD->MAQUILOCAL := aThreads[nI,02] //Nome da máquina local
LOG_THREAD->IDTHREAD   := aThreads[nI,03] //ID da Thread
LOG_THREAD->SERVIDOR   := aThreads[nI,04] //Servidor (caso esteja usando Balance; caso contrário é vazio)
LOG_THREAD->ROTINA     := aThreads[nI,05] //Nome da função que está sendo executada
LOG_THREAD->AMBIENTE   := aThreads[nI,06] //Ambiente(Environment) que está sendo executado
LOG_THREAD->DTHRCONEXA := aThreads[nI,07] //Data e hora da conexão
LOG_THREAD->TEMPOTHEAD := aThreads[nI,08] //Tempo em que a thread está ativa (formato hh:mm:ss)
LOG_THREAD->OBSERVACAO := aThreads[nI,11] //Observações
MsUnlock()

RestArea(aArea)

Return


/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
Static Function CriaAbreLOG()
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
If Select("LOG_THREAD") ==  0
   If !MSFile("LOG_THREAD",,__cRdd)
      aCampos := {{"DATAATU"    ,"D",008,0},;  
                  {"HORAATU"    ,"C",008,0},;
                  {"USUARIO"    ,"C",030,0},;
                  {"MAQUILOCAL" ,"C",030,0},;
                  {"IDTHREAD"   ,"N",010,0},;
                  {"SERVIDOR"   ,"C",030,0},;
                  {"ROTINA"     ,"C",030,0},;
                  {"AMBIENTE"   ,"C",030,0},;
                  {"DTHRCONEXA" ,"C",030,0},;
                  {"TEMPOTHEAD" ,"C",008,0},;
                  {"OBSERVACAO" ,"C",200,0}}
      DBCreate("LOG_THREAD",aCampos,__cRdd)
      USE "LOG_THREAD" ALIAS "LOG_THREAD" VIA __cRdd EXCLUSIVE NEW
      //INDEX ON ID+FILIAL TO ("LOG_THREAD1")
      //DBSetIndex("LOG_THREAD1")
   Else
      DBUseArea(.T.,__cRdd,"LOG_THREAD","LOG_THREAD",.T.,.F.)
      //DBSetIndex("LOG_THREAD1")
   Endif  
   IF Neterr()
      Return Nil
   Endif           
Endif
                                    
Return