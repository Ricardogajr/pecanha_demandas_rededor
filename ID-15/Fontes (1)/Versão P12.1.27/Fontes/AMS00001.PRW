#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"
/*
{Protheus.doc} AMS00001()


-> Bloqueia rotina de ficha médica fora do périodo de lançamento de folha;
-> Base da fonte de bloqueio da rotina MDTA685;
@Author     Paulo Dias
@Since	     24/01/2018
@Version    P12.7
*/
User Function AMS00001()

Local aArea    := GetArea()

Local aDataBloq:= {}
Local cFilU013 := cFilAnt
Local nPosU013 := 0
Local cTabela  := "U013" 

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
      MsgAlert("Sr(a). Usuário(a): "+Upper(Alltrim(cUserName))+Chr(13)+Chr(13)+;
               "Acesso liberado em "+Dtoc(aDataBloq[nPosU013,6]),"Atestado Médico"+Chr(13)+;
               "Período Bloqueado para Manutenção")
   Else
      MDTA410()
   EndIf
Else
   MsgStop("Sr(a). Usuário(a): "+Upper(Alltrim(cUserName))+Chr(13)+;
           "Favor solicitar a área de Gestão de Pessoal, que verifiquem o Cadastro.",;
           "Definição e/ou Manutenção de Tabelas"+Chr(13)+;
           "Não Localizado"+Chr(13)+"[U013 - Atestado Médico]")
EndIf

RestArea(aArea) 

Return
