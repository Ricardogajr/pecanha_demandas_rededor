#INCLUDE "PROTHEUS.CH"              
#INCLUDE "TBICODE.CH"                 
#INCLUDE "TBICONN.CH"               
#INCLUDE "TOPCONN.CH"
#INCLUDE "RWMAKE.CH"        
/////////////////////////////////////////////////////////////////////////////////////
//+-------------------------------------------------------------------------------+//
//| PROGRAMA  | DORCRECHE | AUTOR | Edsonho ® / Ari Oliveira   | DATA |10/04/2017 |//
//| CLIENTE   | Rede DOR                                                          |//
//+-------------------------------------------------------------------------------+//
//| DESCRICAO | Funcão - DORCRECHE                                                |//
//|           | Calcular o Valor do Beneficio Creche                              |//
//+-------------------------------------------------------------------------------+//    
/////////////////////////////////////////////////////////////////////////////////////
User Function DorCreche()

Public nLinha    := 0
Public nQtdeDep  := 0
Public nMesTab   := 0
Public cTipoTab  := "S015"
Public nBuscaTab := 0
Public nDiasTrab := 0
Public dDtaRefFol:= Ctod(" / / ") // 18/06/2018 - Paulo
Public dDtaCreche:= Ctod(" / / ") // 18/06/2018 - Paulo
Public dDtaNascto:= Ctod(" / / ") // 18/06/2018 - Paulo
Public dDtaDemiti:= Ctod(" / / ") // 18/06/2018 - Paulo
Public dDtIni    := Ctod(" / / ") // 18/06/2018 - Paulo
Public dDtFim    := Ctod(" / / ") // 18/06/2018 - Paulo
Public dDtDur    := Ctod(" / / ") // 18/06/2018 - Paulo
Public dSumDtNas := Ctod(" / / ") // 18/06/2018 - Paulo
Public nDayProp  := 0 // 18/06/2018 - Paulo
Public nSubDia   := 0 // 18/06/2018 - Paulo
Public nVlrCreche:= 0
Public nTotCreche:= 0
Public nVlrSind  := 0
Public cSitFolha := ""
Public nTotDia   := 0
Public nTotGDia  := 0
Public nDiaProp  := 0
Public nRecSR8   := 0
Public nRecRCC   := 0
Public aAuxCreche:= {}
Public cTIPOAFA  := ""
Public lMSGdebug := .f.
Public lSR8      := .t.
Private cCrLf    := Chr(13)+Chr(10)

DbSelectArea("SRV")
If SRV->(DbSeek(xFilial("SRV")+aCodFol[721,1]))

   DbSelectArea("SRB")
   SRB->(DbSetOrder(1))
   If SRB->(DbSeek(SRA->(RA_FILIAL+SRA->RA_MAT)))

      cSitFolha := IIf(Empty(SRA->RA_SITFOLH),"A T I V O",IIf(SRA->RA_SITFOLH=="A","A F A S T A D O",IIf(!Empty(DDATADEM),"D E M I T I D O","FORA DO PROCESSO")))
      nQtdeDep  := 0
      nTotCreche:= 0
      aAuxCreche:= {}

      RCA->(DbSetOrder(1))
      If RCA->(DbSeek(xFilial("RCA")+"M_CODAFAST      "))
         cTIPOAFA  := Alltrim(RCA->RCA_CONTEU)
         dDtaRefFol := DDATAATE
         dDtaDemiti := DDATADEM
         nDiasTrab  := DIASTRAB

         fTabCreche()
         If Len(aAuxCreche) > 0
            nMesTab := aAuxCreche[1][5]
            nVlrSind:= aAuxCreche[1][6]

            fGeraSR8()
            		  
            DbSelectArea("SRB")
            While SRB->RB_FILIAL+SRB->RB_MAT == SRA->RA_FILIAL+SRA->RA_MAT .And. SRB->(!Eof())
              If SRB->RB_AUXCRE == "1"
                 nTotGDia   := 0
                 nDiaProp   := 0
                 nVlrCreche := 0
                 dDtaCreche := SRB->RB_XDTCREC // Campo Especifico -> Data da Carência da Creche
                 dDtaNascto := SRB->RB_DTNASC
                 nBuscaTab  := DateDiffMonth(IIf(Empty(dDtaDemiti),dDtaRefFol,IIf(dDtaDemiti < dDtaRefFol, dDtaDemiti ,dDtaRefFol)),dDtaNascto )
                 nNumMeses  := DateDiffMonth(dDtaRefFol,dDtaNascto) // MesAno da competencia da folha - mês/ano nascto (retorna mês)
                 
                 
                 If cROT == "FOL"
                    //Compara MES/ANO da Carência da Creche com a data da Competencia da Folha.
                    If MesAno(dDtaCreche) <= MesAno(dDtaRefFol)
                      If MesAno(MonthSum(dDtaNascto,72)) >= MesAno(dDtaRefFol) // ticket n° 3143379 - 21/06/2018 - Paulo Dias
                       fAtivo()              
                      EndIf                   
                    EndIf
                 ElseIf cROT == "RES" .And. !Empty(dDtaDemiti)
                        cSitFolha := "D E M I T I D O"
                        If MesAno(dDtaCreche) <= MesAno(dDtaDemiti)
                           fDemitido()
                        EndIf
                 EndIf
               EndIf
               DbSelectArea("SRB")
               SRB->(dbSkip())
            EndDo

            //If nTotCreche > 0  -- ticket n° 3143379 - 415966- Paulo Dias - comentado  
            	
               // Se a Verba Não Estiver Informada, Grava o Valor.
              If !((aScan(aPD,{|x| x[1] == aCodFol[721,1] .And. x[7] == "I" .And. x[9] <> "D"}) > 0))
                     fDelPD(aCodFol[721,1])	
                     fGeraVerba(aCodFol[721,1],nTotCreche,nQtdeDep,,,,,,,,.t.)
              EndIf	
            //EndIf -- ticket n° 3143379 - 415966 - Paulo Dias - comentado 
//         Else
//            Alert("Informações NÃO Encontradas na S015, Favor Verificar")
         EndIf
      Else
         Alert(" Parâmetro Código de Afastamento Não Cadastrado, Favor Verificar")
      EndIf
   EndIf
Else
   Alert(" Não Existe a Verba de AUXÍLIO CRECHE [ID-721] Cadastrada, Favor Verificar")
Endif

If Select("TMPSR8") > 0
   DbSelectArea("TMPSR8")
  ("TMPSR8")->(DbCloseArea())  
Endif

Return("FIM")
//////////////////////////////////////////////////////////////////////////////////
//+-----------------------------------------------------------------------------+//
//| Colaborador Ativo/Afastado                                                  |//
//+-----------------------------------------------------------------------------+//
///////////////////////////////////////////////////////////////////////////////////
Static Function fAtivo()

Private lIgual := .f.

nVlrCreche     := 0
// ticket n° 3143379 - 415966 - Paulo Dias - ajuste com base no DOR05010121
dDtaRefFol     := DDATAATE 
dDtaRefFol     := IIF(Last_Day(dDtaRefFol) != 30,DaySub(dDtaRefFol,1),dDtaRefFol) //ajuste para não considerar meses diferentes de 30 dias

If MesAno(dDtaCreche) == MesAno(dDtaRefFol) // Se igual, faz proporcionalide (verificar qts dias a pagar (30-dia carencia+1) * valor da S015
		If nRecSR8 > 0
      		fDiasAfCre()
      		nDiaProp := IIf((30-Day(dDtaCreche)+1)-nTotGDia < 0,0,(30-Day(dDtaCreche)+1)-IIf(SRA->RA_SITFOLH == "A",nTotGDia,0))
      		nVlrCreche := (nVlrSind/30) * nDiaProp 
    Else
      nDayProp := DateDiffDay(dDtaRefFol,dDtaCreche) + 1  // ajuste cálculo proporcionalidade com base na data de carência
   	  nVlrCreche := (nVlrSind/30) * nDayProp 
    EndIf

Else
	If MesAno(dDtaRefFol) == MesAno(MonthSum(dDtaNascto,72))
		If nRecSR8 > 0
			nDiaProp := IIf((Day(dDtaNascto)-nTotGDia) < 0,0,Day(dDtaNascto)-IIf(SRA->RA_SITFOLH == "A",nTotGDia,0))
			nVlrCreche := (nVlrSind/30) * (nDiaProp - 1) //ticket n° 3143379 - 415966 - Paulo Dias - ajuste cálculo proporcionalidade data aniversário = data folha
		Else
			dSumDtNas  := MonthSum(dDtaNascto,72)
			nDayProp   := DateDiffDay(dSumDtNas, FirstDay(dDtaRefFol))
   		nVlrCreche := (nVlrSind/30) * nDayProp 
   		EndIf
Else
	If MesAno(dDtaCreche) < MesAno(dDtaRefFol) .and. MesAno(MonthSum(dDtaNascto,72)) != MesAno(dDtaRefFol)
    	If (SRA->RA_SITFOLH != "A") 
    			nVlrCreche:= nVlrSind 
  		Else
  			fDiasAfast()
	  		nDiaProp := IIf(30 - nTotGDia < 0,0,30 - IIf(SRA->RA_SITFOLH == "A",nTotGDia,0))
	  		nVlrCreche := (nVlrSind/30)*nDiaProp
 		EndIf			
   		EndIf
   	EndIf 
EndIf
// Fim -- Paulo

If lMSGdebug
   fMostraMSG()
EndIf

If nVlrCreche > 0
   nQtdeDep++ 
   nTotCreche := nTotCreche + nVlrCreche

// ticket n° 3143379 - 415966 - Paulo Dias - ajuste para não pagar o valor padrão
Else
	nTotCreche := 0

EndIf
// Fim - Paulo

Return
//////////////////////////////////////////////////////////////////////////////////
//+-----------------------------------------------------------------------------+//
//| Quantidade de Dias Afastado - Nascimento                                    |//
//+-----------------------------------------------------------------------------+//
///////////////////////////////////////////////////////////////////////////////////
Static Function fDiasAfast()

nTotGDia := 0
nDiaProp := 0

DbSelectArea("TMPSR8")
TMPSR8->(DbGoTop())



While TMPSR8->R8_FILIAL + TMPSR8->R8_MAT == SRA->RA_FILIAL + SRA->RA_MAT .And. TMPSR8->(!Eof())
   lSR8 := .t.
   If MesAno(TMPSR8->R8_DATAINI) < MesAno(dDtaRefFol) .And. MesAno(TMPSR8->R8_DATAFIM) < MesAno(dDtaRefFol)
     lSR8 := .f.
   EndIf
   //ticket n° 3143379 - 415966 - Paulo Dias - ajuste para afastados
   If MesAno(TMPSR8->R8_DATAINI) < MesAno(dDtaRefFol) .And. EMPTY(MesAno(TMPSR8->R8_DATAFIM)) 
     nTotGDia := 30
   EndIf

   If lSR8
      nTotDia   := 0

      If MesAno(TMPSR8->R8_DATAINI) <= MesAno(dDtaRefFol) .Or. MesAno(TMPSR8->R8_DATAFIM) >= MesAno(dDtaRefFol) .Or. Empty(TMPSR8->R8_DATAFIM) 
      
      //ticket n° 3143379 - 415966 - Paulo Dias - ajuste para afastados  
         If MesAno(TMPSR8->R8_DATAINI) < MesAno(dDtaRefFol) .And. MesAno(TMPSR8->R8_DATAFIM) > MesAno(dDtaRefFol) 
               nTotGDia := 30
         EndIf
         
         If MesAno(TMPSR8->R8_DATAINI) == MesAno(dDtaRefFol).And. MesAno(TMPSR8->R8_DATAFIM) > MesAno(dDtaRefFol)
               nTotGDia := (LastDay(dDtaRefFol) - (TMPSR8->R8_DATAINI)) 
         EndIf
      //Fim Paulo

         If MesAno(TMPSR8->R8_DATAINI) <  MesAno(dDtaRefFol) .And. ;
            MesAno(TMPSR8->R8_DATAFIM) == MesAno(dDtaRefFol)

            If lIgual        
               If Day(dDtaNascto) <= Day(TMPSR8->R8_DATAFIM) 
                  nTotDia := nTotDia + ((Day(dDtaNascto) - 1)+1) // Dia Primeiro do Mês
               Else
                  nTotDia := nTotDia + ((Day(TMPSR8->R8_DATAFIM) - 1)+1) // Dia Primeiro do Mês
               EndIf

               If Dtos(TMPSR8->R8_DATAINI) < Dtos(Ctod("01"+Substr(Dtoc(dDtaRefFol),3))) 
                  nTotGDia   := nTotGDia + nTotDia
               Else
                  If Day(TMPSR8->R8_DATAINI) <= Day(dDtaNascto)
                     nTotGDia   := nTotGDia + nTotDia
                  EndIf
               EndIf
            Elseif Day(TMPSR8->R8_DATAFIM) == 1
               nTotDia := nTotDia + (Day(TMPSR8->R8_DATAFIM) - 1) // Dia Primeiro do Mês
               nTotGDia   := nTotGDia + nTotDia
            Else 
               nTotDia := nTotDia + Day(TMPSR8->R8_DATAFIM) // Dia Primeiro do Mês
               nTotGDia   := nTotGDia + nTotDia
            EndIf
         Else
            If MesAno(TMPSR8->R8_DATAINI) == MesAno(TMPSR8->R8_DATAFIM)

               If lIgual        
                  If Day(dDtaNascto) <= Day(TMPSR8->R8_DATAFIM) 
                     nTotDia := nTotDia + ((Day(dDtaNascto) - Day(TMPSR8->R8_DATAINI))+1)
                  Else
                     nTotDia := nTotDia + ((Day(TMPSR8->R8_DATAFIM) - Day(TMPSR8->R8_DATAINI))+1)
                  EndIf

                  If Day(TMPSR8->R8_DATAINI) <= Day(dDtaNascto) 
                     nTotGDia   := nTotGDia + nTotDia
                  EndIf
               Else
                  nTotDia := nTotDia + ((Day(TMPSR8->R8_DATAFIM) - Day(TMPSR8->R8_DATAINI))+1)
                  nTotGDia   := nTotGDia + nTotDia
               EndIf
            Else
               If Empty(TMPSR8->R8_DATAFIM) .And. MesAno(TMPSR8->R8_DATAINI) == MesAno(dDtaRefFol)

                  If lIgual        
                     If Day(dDtaNascto) <= Day(TMPSR8->R8_DATAFIM) 
                        nTotDia := nTotDia + ((30 - Day(dDtaNascto))+1) // Ultimo dia do Mês
                     Else
                        nTotDia := nTotDia + ((30 - Day(TMPSR8->R8_DATAINI))+1) // Ultimo dia do Mês
                     EndIf

                     If Day(TMPSR8->R8_DATAINI) <= Day(dDtaNascto) 
                        nTotGDia   := nTotGDia + nTotDia
                     EndIf
                  Else
                     nTotDia := nTotDia + ((30 - Day(TMPSR8->R8_DATAINI))+1) // Ultimo dia do Mês
                     nTotGDia   := nTotGDia + nTotDia
                  EndIf
               EndIf
            EndIf
         EndIf
      EndIf
   EndIf
   DbSelectArea("TMPSR8")
   TMPSR8->(DbSkip())       
EndDo
Return
//////////////////////////////////////////////////////////////////////////////////
//+-----------------------------------------------------------------------------+//
//| Quantidade de Dias Afastado - Carência                                      |//
//+-----------------------------------------------------------------------------+//
///////////////////////////////////////////////////////////////////////////////////
Static Function fDiasAfCre()

nTotGDia := 0
nDiaProp := 0

DbSelectArea("TMPSR8")
dbGoTop()

While TMPSR8->R8_FILIAL + TMPSR8->R8_MAT == SRA->RA_FILIAL + SRA->RA_MAT .And. TMPSR8->(!Eof())
   lSR8 := .t.
   If MesAno(TMPSR8->R8_DATAINI) < MesAno(dDtaRefFol) .And. MesAno(TMPSR8->R8_DATAFIM) < MesAno(dDtaRefFol)
      lSR8 := .f.
   EndIf

   If lSR8
   nTotDia   := 0

   If MesAno(TMPSR8->R8_DATAINI) <= MesAno(dDtaRefFol) .Or. ;
      MesAno(TMPSR8->R8_DATAFIM) >= MesAno(dDtaRefFol) .Or. ;
      Empty(TMPSR8->R8_DATAFIM) 

      If MesAno(TMPSR8->R8_DATAINI) <  MesAno(dDtaRefFol) .And. ;
         MesAno(TMPSR8->R8_DATAFIM) == MesAno(dDtaRefFol)

         If Dtos(dDtaCreche) > Dtos(TMPSR8->R8_DATAINI) 
            nTotDia := nTotDia + ((Day(TMPSR8->R8_DATAFIM) - Day(dDtaCreche))+1)
         Else
            nTotDia := nTotDia + ((Day(TMPSR8->R8_DATAFIM) - 1)+1) // Dia Primeiro do Mês
         EndIf

         If Day(TMPSR8->R8_DATAFIM) >= Day(dDtaCreche)
            nTotGDia := nTotGDia + nTotDia
         EndIf
      Else
         If MesAno(TMPSR8->R8_DATAINI) == MesAno(dDtaRefFol) .And. ;
            MesAno(TMPSR8->R8_DATAFIM) == MesAno(dDtaRefFol)

            If Dtos(dDtaCreche) > Dtos(TMPSR8->R8_DATAINI) 
               nTotDia := nTotDia + ((Day(TMPSR8->R8_DATAFIM) - Day(dDtaCreche))+1)
            Else
               nTotDia := nTotDia + ((Day(TMPSR8->R8_DATAFIM) - Day(TMPSR8->R8_DATAINI))+1)
            EndIf

            If Day(dDtaCreche) <= Day(TMPSR8->R8_DATAFIM) 
               nTotGDia   := nTotGDia + nTotDia
            EndIf
         Else
            If Empty(TMPSR8->R8_DATAFIM) .And. MesAno(TMPSR8->R8_DATAINI) == MesAno(dDtaRefFol)
               If Dtos(dDtaCreche) > Dtos(TMPSR8->R8_DATAINI) 
                  nTotDia := nTotDia + ((30 - Day(dDtaCreche))+1) // Ultimo dia do Mês
               Else
                  nTotDia := nTotDia + ((30 - Day(TMPSR8->R8_DATAINI))+1) // Ultimo dia do Mês
               EndIf
               nTotGDia   := nTotGDia + nTotDia
            EndIf
         EndIf
      EndIf
   EndIf
   EndIf
   DbSelectArea("TMPSR8")
   TMPSR8->(DbSkip())       
EndDo
Return
//////////////////////////////////////////////////////////////////////////////////
//+-----------------------------------------------------------------------------+//
//| Colaborador Demitido                                                        |//
//+-----------------------------------------------------------------------------+//
///////////////////////////////////////////////////////////////////////////////////
Static Function fDemitido()

If MesAno(dDtaDemiti) == MesAno(dDtaCreche) 
   If Day(dDtaDemiti) >= Day(dDtaCreche) 
      If nRecSR8 > 0
         fDiaAfDem1()
      EndIf
      nDiaProp := IIf((Day(dDtaDemiti)-Day(dDtaCreche)-nTotGDia) < 0,0,(Day(dDtaDemiti)-Day(dDtaCreche)-IIf(SRA->RA_SITFOLH == "A",nTotGDia,0))+1)
      nVlrCreche := (nVlrSind/30)*nDiaProp
   EndIf
Else
   If (DateDiffMonth(dDtaNascto ,dDtaDemiti)) <= nMesTab
       If (DateDiffMonth(dDtaNascto ,dDtaDemiti)) == nMesTab
           If Day(dDtaDemiti) >= Day(dDtaNascto) 
              If nRecSR8 > 0
                 fDiaAfDem2() // Maior ou Igual  DATA NASCIMENTO
              EndIf
              nDiaProp := IIf((Day(dDtaNascto)-nTotGDia) < 0,0,(Day(dDtaNascto)-IIf(SRA->RA_SITFOLH == "A",nTotGDia,0)))
           Else // Menor
              If nRecSR8 > 0
                 fDiaAfDem3() // Menor DATA DE DEMISSÃO
              EndIf
              nDiaProp := IIf((Day(dDtaDemiti)-nTotGDia) < 0,0,(Day(dDtaDemiti)-IIf(SRA->RA_SITFOLH == "A",nTotGDia,0)))
           EndIf
       Else // Menor
          If nRecSR8 > 0
             fDiaAfDem3() // Menor DATA DE DEMISSÃO
          EndIf
          nDiaProp := IIf((Day(dDtaDemiti)-nTotGDia) < 0,0,(Day(dDtaDemiti)-IIf(SRA->RA_SITFOLH == "A",nTotGDia,0)))
       EndIf
       nVlrCreche := (nVlrSind/30)*nDiaProp
   EndIf // Maior, zera a verba
EndIf

If lMSGdebug
   fMostraMSG()
EndIf

If nVlrCreche > 0
   nQtdeDep++
   nTotCreche := nTotCreche + nVlrCreche 
EndIf

Return
//////////////////////////////////////////////////////////////////////////////////
//+-----------------------------------------------------------------------------+//
//| Quantidade de Dias Afastado - Demissão - Carência                           |//
//+-----------------------------------------------------------------------------+//
///////////////////////////////////////////////////////////////////////////////////
Static Function fDiaAfDem1()

nRecTot  := 0
nTotGDia := 0
nDiaProp := 0

DbSelectArea("TMPSR8")
dbGoTop()

While TMPSR8->R8_FILIAL + TMPSR8->R8_MAT == SRA->RA_FILIAL + SRA->RA_MAT .And. TMPSR8->(!Eof())
   lSR8 := .t.
   If MesAno(TMPSR8->R8_DATAINI) < MesAno(dDtaRefFol) .And. MesAno(TMPSR8->R8_DATAFIM) < MesAno(dDtaRefFol)
      lSR8 := .f.
   EndIf

   If lSR8
   nTotDia   := 0

   If MesAno(TMPSR8->R8_DATAINI) <= MesAno(dDtaDemiti) .Or. ;
      MesAno(TMPSR8->R8_DATAFIM) >= MesAno(dDtaDemiti) .Or. ;
      !Empty(TMPSR8->R8_DATAFIM) 

      If MesAno(TMPSR8->R8_DATAINI) <  MesAno(dDtaDemiti) .And. ;
         MesAno(TMPSR8->R8_DATAFIM) == MesAno(dDtaDemiti)

         If Dtos(dDtaCreche) > Dtos(TMPSR8->R8_DATAINI) 
            nTotDia := nTotDia + ((Day(TMPSR8->R8_DATAFIM) - Day(dDtaCreche))+1)
         Else
            nTotDia := nTotDia + ((Day(TMPSR8->R8_DATAFIM) - 1)+1) // Dia Primeiro do Mês
         EndIf

         If Day(TMPSR8->R8_DATAFIM) >= Day(dDtaCreche)
            nTotGDia := nTotGDia + nTotDia
         EndIf
      Else
         If MesAno(TMPSR8->R8_DATAINI) == MesAno(dDtaDemiti) .And. ;
            MesAno(TMPSR8->R8_DATAFIM) == MesAno(dDtaDemiti)

            If Dtos(dDtaCreche) > Dtos(TMPSR8->R8_DATAINI) 
               nTotDia := nTotDia + ((Day(TMPSR8->R8_DATAFIM) - Day(dDtaCreche))+1)
            Else
               nTotDia := nTotDia + ((Day(TMPSR8->R8_DATAFIM) - Day(TMPSR8->R8_DATAINI))+1)
            EndIf

            If Day(dDtaCreche) <= Day(TMPSR8->R8_DATAFIM) 
               nTotGDia   := nTotGDia + nTotDia
            EndIf
         Else
            If nRecTot < nRecSR8
               nTotDia := nTotDia + ((Day(TMPSR8->R8_DATAFIM) - Day(TMPSR8->R8_DATAINI))+1)
            Else
               nTotDia := nTotDia + ((Day(dDtaDemiti) - Day(TMPSR8->R8_DATAINI))+1) // Ultimo dia do Mês
            EndIf
            If Dtos(dDtaCreche) > Dtos(TMPSR8->R8_DATAINI) 
               nTotGDia   := nTotGDia + nTotDia
            EndIf
         EndIf
      EndIf
   EndIf
   nRecTot++
   EndIf
   DbSelectArea("TMPSR8")
   TMPSR8->(DbSkip())       
EndDo
Return
//////////////////////////////////////////////////////////////////////////////////
//+-----------------------------------------------------------------------------+//
//| Quantidade de Dias Afastado - Nascimento                                    |//
//+-----------------------------------------------------------------------------+//
///////////////////////////////////////////////////////////////////////////////////
Static Function fDiaAfDem2()

nRecTot  := 0
nTotGDia := 0
nDiaProp := 0

DbSelectArea("TMPSR8")
dbGoTop()

While TMPSR8->R8_FILIAL + TMPSR8->R8_MAT == SRA->RA_FILIAL + SRA->RA_MAT .And. TMPSR8->(!Eof())
   lSR8 := .t.
   If MesAno(TMPSR8->R8_DATAINI) < MesAno(dDtaRefFol) .And. MesAno(TMPSR8->R8_DATAFIM) < MesAno(dDtaRefFol)
      lSR8 := .f.
   EndIf

   If lSR8
   nTotDia   := 0

   If MesAno(TMPSR8->R8_DATAINI) <= MesAno(dDtaDemiti) .Or. ;
      MesAno(TMPSR8->R8_DATAFIM) >= MesAno(dDtaDemiti) .Or. ;
      !Empty(TMPSR8->R8_DATAFIM) 

      If MesAno(TMPSR8->R8_DATAINI) <  MesAno(dDtaDemiti) .And. ;
         MesAno(TMPSR8->R8_DATAFIM) == MesAno(dDtaDemiti)

         If Day(dDtaNascto) <= Day(TMPSR8->R8_DATAFIM) 
            nTotDia := nTotDia + ((Day(dDtaNascto) - 1)+1) // Dia Primeiro do Mês
         Else
            nTotDia := nTotDia + ((Day(TMPSR8->R8_DATAFIM) - 1)+1) // Dia Primeiro do Mês
         EndIf
 
         If Day(TMPSR8->R8_DATAINI) <= Day(dDtaNascto) 
            nTotGDia   := nTotGDia + nTotDia
         EndIf

      Else
         If MesAno(TMPSR8->R8_DATAINI) == MesAno(dDtaDemiti) .And. ;
            MesAno(TMPSR8->R8_DATAFIM) == MesAno(dDtaDemiti)
            If Day(dDtaNascto) <= Day(TMPSR8->R8_DATAFIM) 
               If Day(dDtaNascto) < Day(TMPSR8->R8_DATAFIM) 
                  nTotDia := nTotDia + ((Day(TMPSR8->R8_DATAINI) - Day(dDtaNascto))+1)
               Else
                  nTotDia := nTotDia + ((Day(dDtaNascto) - Day(TMPSR8->R8_DATAINI))+1)
               EndIf
            Else
               nTotDia := nTotDia + ((Day(TMPSR8->R8_DATAFIM) - Day(TMPSR8->R8_DATAINI))+1)
            EndIf
         Else
            nTotDia := nTotDia + ((Day(dDtaDemiti) - Day(TMPSR8->R8_DATAINI))+1) // Ultimo dia do Mês
         EndIf
 
         If Day(TMPSR8->R8_DATAINI) <= Day(dDtaNascto) 
            nTotGDia   := nTotGDia + nTotDia
         EndIf
      EndIf
   EndIf
   nRecTot++
   EndIf
   DbSelectArea("TMPSR8")
   TMPSR8->(DbSkip())       
EndDo
Return
//////////////////////////////////////////////////////////////////////////////////
//+-----------------------------------------------------------------------------+//
//| Quantidade de Dias Afastado - Demissão                                      |//
//+-----------------------------------------------------------------------------+//
///////////////////////////////////////////////////////////////////////////////////
Static Function fDiaAfDem3()

nRecTot  := 0
nTotGDia := 0
nDiaProp := 0

DbSelectArea("TMPSR8")
dbGoTop()

While TMPSR8->R8_FILIAL + TMPSR8->R8_MAT == SRA->RA_FILIAL + SRA->RA_MAT .And. TMPSR8->(!Eof())
   lSR8 := .t.
   If MesAno(TMPSR8->R8_DATAINI) < MesAno(dDtaRefFol) .And. MesAno(TMPSR8->R8_DATAFIM) < MesAno(dDtaRefFol)
      lSR8 := .f.
   EndIf

   If lSR8
   nTotDia   := 0

   If MesAno(TMPSR8->R8_DATAINI) <= MesAno(dDtaDemiti) .Or. ;
      MesAno(TMPSR8->R8_DATAFIM) >= MesAno(dDtaDemiti) .Or. ;
      !Empty(TMPSR8->R8_DATAFIM) 

      If MesAno(TMPSR8->R8_DATAINI) <  MesAno(dDtaDemiti) .And. ;
         MesAno(TMPSR8->R8_DATAFIM) == MesAno(dDtaDemiti)

         If Day(dDtaDemiti) <= Day(TMPSR8->R8_DATAFIM) 
            nTotDia := nTotDia + ((Day(dDtaDemiti) - 1)+1) // Dia Primeiro do Mês
         Else
            nTotDia := nTotDia + ((Day(TMPSR8->R8_DATAFIM) - 1)+1) // Dia Primeiro do Mês
         EndIf
 
         If Day(TMPSR8->R8_DATAINI) <= Day(dDtaDemiti) 
            nTotGDia   := nTotGDia + nTotDia
         EndIf

      Else
         If MesAno(TMPSR8->R8_DATAINI) == MesAno(dDtaDemiti) .And. ;
            MesAno(TMPSR8->R8_DATAFIM) == MesAno(dDtaDemiti)
            nTotDia := nTotDia + ((Day(TMPSR8->R8_DATAFIM) - Day(TMPSR8->R8_DATAINI))+1)
         Else
            nTotDia := nTotDia + ((Day(dDtaDemiti) - Day(TMPSR8->R8_DATAINI))+1) // Ultimo dia do Mês
         EndIf
 
         If Day(TMPSR8->R8_DATAINI) <= Day(dDtaDemiti) 
            nTotGDia   := nTotGDia + nTotDia
         EndIf
      EndIf
   EndIf
   nRecTot++
   EndIf
   DbSelectArea("TMPSR8")
   TMPSR8->(DbSkip())       
EndDo
Return
//////////////////////////////////////////////////////////////////////////////////
//+-----------------------------------------------------------------------------+//
//| Pesquisa Tabela S015                                                        |//
//+-----------------------------------------------------------------------------+//
///////////////////////////////////////////////////////////////////////////////////
Static Function fTabCreche()

Local cQuery := ""
Local lAchou := .f.
 
nRecRCC    := 0
aAuxCreche := {}

cQuery += "Select *"+cCrLf
cQuery += " From "+RetSqlName("RCC")+" RCC "+cCrLf
cQuery += " Where RCC.D_E_L_E_T_   = ' ' And "+cCrLf
cQuery += " RCC.RCC_CODIGO ='"+cTipoTab+"' "+cCrLf
cQuery += "Order By RCC.RCC_FIL DESC"

//MemoWrite("C:\TOTVS_Projects\Projetos\PROTHEUS_LOCAL\PROTHEUS12\Query\TMPRCC.SQL",cQuery)
ChangeQuery(cQuery)

If Select("TMPRCC") > 0
   DbSelectArea("TMPRCC")
  ("TMPRCC")->(DbCloseArea())  
Endif

dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"TMPRCC", .F., .T.)

DbSelectArea("TMPRCC")
dbGoTop()
Count To nRecRCC
//48  8      200.00  0                                                                                                                                                                                                                                      
//22 60       90.54  0                                                                                                                                                                                                                                      
If nRecRCC > 0
   DbSelectArea("TMPRCC")
   dbGoTop()
//     If Alltrim(Substr(TMPRCC->RCC_CONTEU,1,2)) == Alltrim(SRA->RA_SINDICA) .And. ;
//      nBuscaTab <= Int(Val(Substr(TMPRCC->RCC_CONTEU,3,3)))
//cQuery += " RCC.RCC_FILIAL ='"+SRA->RA_FILIAL+"' And "+cCrLf

   While TMPRCC->(!Eof())
     If Alltrim(Substr(TMPRCC->RCC_CONTEU,1,2)) == Alltrim(SRA->RA_SINDICA)
        If TMPRCC->RCC_FIL == SRA->RA_FILIAL .And. Alltrim(TMPRCC->RCC_CHAVE) == MesAno(dDtaRefFol) 
           lAchou := .t.
           Exit
        ElseIf TMPRCC->RCC_FIL == SRA->RA_FILIAL .And. Empty(TMPRCC->RCC_CHAVE) 
               lAchou := .t.
               Exit
        ElseIf Empty(TMPRCC->RCC_FIL) .And. Alltrim(TMPRCC->RCC_CHAVE) == MesAno(dDtaRefFol)
               lAchou := .t.
               Exit
        ElseIf Empty(TMPRCC->RCC_FIL) .And. Empty(TMPRCC->RCC_CHAVE)
               lAchou := .t.
               Exit
        EndIf
     EndIf
     DbSelectArea("TMPRCC")
     TMPRCC->(dbSkip())
   EndDo
// RCC_CONTEU
//31 60      200.00  0                                                                                                                                                                                                                                                                                                                                                                                                                                                                            

   If lAchou
      aAdd(aAuxCreche,{TMPRCC->RCC_CODIGO,;
                       TMPRCC->RCC_CHAVE,;
                       TMPRCC->RCC_SEQUEN,;
                       Alltrim(Substr(TMPRCC->RCC_CONTEU,1,2)),;
                       Val(Substr(TMPRCC->RCC_CONTEU,3,3)),;
                       Val(Substr(TMPRCC->RCC_CONTEU,6,12))})
   EndIf

   aSort(aAuxCreche,,,{|x,y| x[2] > y[2] })

EndIf

If Select("TMPRCC") > 0
   DbSelectArea("TMPRCC")
  ("TMPRCC")->(DbCloseArea())  
Endif

Return
//////////////////////////////////////////////////////////////////////////////////
//+-----------------------------------------------------------------------------+//
//| Gera Query - SR8                                                            |//
//+-----------------------------------------------------------------------------+//
///////////////////////////////////////////////////////////////////////////////////
Static Function fGeraSR8()

Local cQuery := ""

nRecSR8 := 0

/* ticket n° 3143379 - 415966 - Paulo Dias - query comentada
cQuery += "Select *"+cCrLf
cQuery += " From "+RetSqlName("SR8")+" SR8 "+cCrLf
cQuery += " Where SR8.D_E_L_E_T_   = ' ' And "+cCrLf
cQuery += " SR8.R8_FILIAL='"+SRA->RA_FILIAL+"' And "+cCrLf
cQuery += " SR8.R8_TIPOAFA In ("+cTIPOAFA+")   And "+cCrLf
cQuery += " SR8.R8_MAT   ='"+SRA->RA_MAT+"' "+cCrLf
cQuery += "Order By SR8.R8_FILIAL,SR8.R8_MAT,SR8.R8_SEQ  "
*/
// ticket n° 3143379 - 415966 - Paulo Dias - query pra retorno do último registro

cQuery += " Select * from (                             " 
cQuery += " select *                                    "
cQuery += " from SR8010 SR8                             "
cQuery += " where SR8.D_E_L_E_T_   = ' '           And   "
cQuery += " SR8.R8_FILIAL='"+SRA->RA_FILIAL+"'    And   "
cQuery += " SR8.R8_TIPOAFA In ("+cTIPOAFA+")      And   "
cQuery += " SR8.R8_MAT   ='"+SRA->RA_MAT+"'       And   "
cQuery += " SR8.R8_SEQ = (select max(SR8.R8_SEQ)        "
cQuery += " from SR8010 SR8                             "
cQuery += " where  SR8.D_E_L_E_T_   = ' '          And   "
cQuery += " SR8.R8_FILIAL='"+SRA->RA_FILIAL+"'    And   "
cQuery += " SR8.R8_TIPOAFA In ("+cTIPOAFA+")      And   "
cQuery += " SR8.R8_MAT   ='"+SRA->RA_MAT+"' )           "
cQuery += " Order by SR8.R8_SEQ desc)                   "


//MemoWrite("C:\TOTVS_Projects\Projetos\PROTHEUS_LOCAL\PROTHEUS12\Query\TMPSR8.SQL",cQuery)
ChangeQuery(cQuery)

If Select("TMPSR8") > 0
   DbSelectArea("TMPSR8")
  ("TMPSR8")->(DbCloseArea())  
Endif

dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"TMPSR8", .F., .T.)

TcSetField(("TMPSR8"),"R8_DATAINI","D",8,0)
TcSetField(("TMPSR8"),"R8_DATAFIM","D",8,0)

DbSelectArea("TMPSR8")
dbGoTop()
Count To nRecSR8

Return

Static Function fMostraMSG()

MsgInfo("Colaborador: "+Alltrim(SRA->RA_MAT)+"-"+Alltrim(SRA->RA_NOME)+cCrLf+;
        "Dependente : "+Alltrim(SRB->RB_NOME)+cCrLf+;
        "Numero de Dia(s): "+CVALTOCHAR(Alltrim(TransForm(nDiaProp,"99999")))+cCrLf+;
        "Valor do Beneficio Creche ==> R$: "+ CVALTOCHAR(Alltrim(TransForm(Round(nVlrCreche,2),"@E 999,999,999.99")))+cCrLf+cCrLf+;
        cSitFolha)
Return
