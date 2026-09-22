#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"
///////////////////////////////////////////////////////////////////////////////////
//+-----------------------------------------------------------------------------+//
//| PROJETO CONECTA REDE D´OR    |  MODULO | SIGAGPE                            |//
//+-----------------------------------------------------------------------------+//
//| PROGRAMA  | DOR008RH | AUTOR | Edsonho ®                | DATA | 21/06/2017 |//
//+-----------------------------------------------------------------------------+//
//| DESCRICAO | Função: Bloqueio de Acesso, conf.período informa na Tabela U013 |//
//|                     Rotina Padrão MDTA920 – Licença Maternidade             |//
//+-----------------------------------------------------------------------------+//
///////////////////////////////////////////////////////////////////////////////////
User Function DOR008RH()
/* // ticket n°4642966- 415966 - Paulo Dias - Fonte comentado. Remoção do bloqueio total em período de blackout.
Local aArea    := GetArea()
Local aDataBloq:= {}
Local cFilU013 
Local nPosU013 := 0
Local cTabela  := "U013" // "U001" 

cFilU013 := cFilAnt

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
               "Acesso a Rotina será Liberado em "+Dtoc(aDataBloq[nPosU013,6]),"Licença Maternidade"+Chr(13)+;
               "Período Bloqueado para Manutenção")
   Else
      MDTA920()
   EndIf
Else
   MsgStop("Sr. Usuário: "+Upper(Alltrim(cUserName))+Chr(13)+;
           "Favor solicitar a área de Gestão de Pessoal, que verifiquem o Cadastro.",;
           "Definição e/ou Manutenção de Tabelas"+Chr(13)+;
           "Não Localizado"+Chr(13)+"[U013 - Licença Maternidade]")
EndIf

RestArea(aArea) 
*/
Return