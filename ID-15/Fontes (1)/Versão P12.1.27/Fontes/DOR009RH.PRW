#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"
/*
{Protheus.doc} DOR009RH()

-> Bloqueia rotina de ficha m�dica fora do p�riodo de lan�amento de folha;
-> Base da fonte de bloqueio da rotina MDTA685;
@Author     Paulo Dias
@Since	     24/01/2018
@Version    P12.7
*/
User Function DOR009RH()

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
   
      MsgAlert("Sr(a). Usu�rio(a): "+Upper(Alltrim(cUserName))+Chr(13)+Chr(13)+;
               "Acesso liberado em "+Dtoc(aDataBloq[nPosU013,6]),"Atestado M�dico"+Chr(13)+;
               "Per�odo Bloqueado para Manuten��o")
   Else
      MDTA410()
   EndIf
Else
   MsgStop("Sr(a). Usu�rio(a): "+Upper(Alltrim(cUserName))+Chr(13)+;
           "Favor solicitar a �rea de Gest�o de Pessoal, que verifiquem o Cadastro.",;
           "Defini��o e/ou Manuten��o de Tabelas"+Chr(13)+;
           "N�o Localizado"+Chr(13)+"[U013 - Atestado M�dico]")
EndIf

RestArea(aArea) 

Return
