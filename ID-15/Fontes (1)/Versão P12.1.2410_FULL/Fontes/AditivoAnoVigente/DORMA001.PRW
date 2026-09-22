#INCLUDE "Totvs.ch"

/*
Funcao: DORMA001 - Calcula Remuneração para 'Docentes'
Autor : Mauricio Siqueira
Data..: 23/06/2022
Versão: Protheus12
*/

User Function DORMA001

Local nVerba_246 := GetValType('N') // Insalubridade (código padrão)
Local nVerba_307 := GetValType('N') // ATS - quinquenio (código padrão)
Local nVerba_467 := GetValType('N') // Salário Docente
Local nRefer_467 := GetValType('N') // Referencia Salário Docente
Local nVerba_468 := GetValType('N') // DSR Docente
Local nVerba_469 := GetValType('N') // Horas Dedicação (Média)
Local nVerba_470 := GetValType('N') // Horas EAD (Media)
Local nVerba_471 := GetValType('N') // Aulas Dependencia (Média)
Local nVerba_472 := GetValType('N') // Adicional Qualificação
Local nVerba_473 := GetValType('N') // Extra Classe
Local nVerba_474 := GetValType('N') // Supervisão de Estágio
Local nVerba_475 := GetValType('N') // Remuneração de Coordenador
Local lFerPart   := GetValType('L') // Férias Partidas
Local cFilDocent := GetValType('C') // Filiais Sujeitas aos Cálculos de Docentes
Local nDias_Afas := nDiasAfas
Local cVerba_Mat := GetValType('C') // Codigo de Verba para Sal. Maternidade


// Mnemônico específico para relacionar filiais sujeitas ao cálculo de docentes...
cFilDocent := AllTrim(GetAdvFVal("RCA", "RCA_CONTEU", xFilial("RCA")+"M_FILDOCEN", 1, 0) )

If SRA->RA_FILIAL $ cFilDocent .AND. SRA->RA_PROCES = '00006'    // '01BQ0001 - UNINEVES'

   // Busca em Valores Fixos, a remuneração do docente...
   RG1-> (DBGOTOP())
   RG1-> (DbSetOrder(8))

   nVerba_246 := If( RG1->(DBSEEK( SRA->RA_FILIAL + SRA->RA_MAT + '246', .F. ) ), RG1->rg1_valor, 0 )
   nVerba_307 := If( RG1->(DBSEEK( SRA->RA_FILIAL + SRA->RA_MAT + '307', .F. ) ), RG1->rg1_valor, 0 )
   nVerba_467 := If( RG1->(DBSEEK( SRA->RA_FILIAL + SRA->RA_MAT + '467', .F. ) ), RG1->rg1_valor, 0 )
   nRefer_467 := If( RG1->(DBSEEK( SRA->RA_FILIAL + SRA->RA_MAT + '467', .F. ) ), RG1->rg1_refer, 0 )
   nVerba_468 := If( RG1->(DBSEEK( SRA->RA_FILIAL + SRA->RA_MAT + '468', .F. ) ), RG1->rg1_valor, 0 )
   nVerba_469 := If( RG1->(DBSEEK( SRA->RA_FILIAL + SRA->RA_MAT + '469', .F. ) ), RG1->rg1_valor, 0 )
   nVerba_470 := If( RG1->(DBSEEK( SRA->RA_FILIAL + SRA->RA_MAT + '470', .F. ) ), RG1->rg1_valor, 0 )
   nVerba_471 := If( RG1->(DBSEEK( SRA->RA_FILIAL + SRA->RA_MAT + '471', .F. ) ), RG1->rg1_valor, 0 )
   nVerba_472 := If( RG1->(DBSEEK( SRA->RA_FILIAL + SRA->RA_MAT + '472', .F. ) ), RG1->rg1_valor, 0 )
   nVerba_473 := If( RG1->(DBSEEK( SRA->RA_FILIAL + SRA->RA_MAT + '473', .F. ) ), RG1->rg1_valor, 0 )
   nVerba_474 := If( RG1->(DBSEEK( SRA->RA_FILIAL + SRA->RA_MAT + '474', .F. ) ), RG1->rg1_valor, 0 )
   nVerba_475 := If( RG1->(DBSEEK( SRA->RA_FILIAL + SRA->RA_MAT + '475', .F. ) ), RG1->rg1_valor, 0 )

   nSalProf := nVerba_246 + nVerba_307 + nVerba_467 + nVerba_468
   nSalProf += nVerba_472 + nVerba_473 + nVerba_474 + nVerba_475

   // Férias
   If ( cRot ) == 'FER'
      
      // Verifica se as Férias são 'partidas'...
      lFerPart := MESANO(GETMEMVAR("RH_DATAINI")) <> MESANO(GETMEMVAR("RH_DATAFIM") + GETMEMVAR("RH_DABONPE"))
 
      If ( lFerPart )
    
         NSALM1:= NSALM2:= ( nSalProf - nVerba_246 )
    
         NSALD1 := (nSalProf - nVerba_246 ) / NDIASPERF1
    
         NSALD2 := (nSalProf - nVerba_246 ) / NDIASPERF2
    
         NSALH1 := nSalProf / (SRA->RA_HRSDIA * NDIASPERF1)
    
         NSALH2 := nSalProf / ( SRA->RA_HRSDIA * NDIASPERF2)

      Else

         NSALM1 := (nSalProf - nVerba_246 )
    
         NSALD1 := (nSalProf - nVerba_246 ) / NDIASPERF1
    
         NSALH1 := (nSalProf - nVerba_246 ) / (SRA->RA_HRSDIA * NDIASPERF1)

      EndIF
   EndIf

   If (cRot) $ ('FOL*131*132')

      SALARIO := nSalProf
      SALMES  := nSalProf

   EndIf

  // Rescisões
   If( cRot ) == 'RES'

      SALARIO := nSalProf - nVerba_246
      SALMES  := nSalProf - nVerba_246

      // Deleta verbas 'geradas' pela RG1...
//      If( fLocaliaPD("246") > 0, fDelPD("246"), .f. )
      If( fLocaliaPD("307") > 0, fDelPD("307"), .f. )
      If( fLocaliaPD("467") > 0, fDelPD("467"), .f. )
      If( fLocaliaPD("468") > 0, fDelPD("468"), .f. )
      If( fLocaliaPD("469") > 0, fDelPD("469"), .f. )
      If( fLocaliaPD("470") > 0, fDelPD("470"), .f. )
      If( fLocaliaPD("471") > 0, fDelPD("471"), .f. )
      If( fLocaliaPD("472") > 0, fDelPD("472"), .f. )
      If( fLocaliaPD("473") > 0, fDelPD("473"), .f. )
      If( fLocaliaPD("474") > 0, fDelPD("474"), .f. )
      If( fLocaliaPD("475") > 0, fDelPD("475"), .f. )
    
   ENDIF

   // Exclui Insalubridade 'calculada' para não duplicar...
   If ( fLocaliaPD("246") > 0 ) .And. ( aPD[fLocaliaPD("246"), 7] == 'C' )
      aPd[fLocaliaPD("246"), 9] := "D"
   Endif

   // Salario Maternidade...
   IF ( cRot ) == 'FOL' .AND. SRA->RA_AFASFGT $ 'Q1*Q2*Q3*Q4*Q5*Q6'

      If nDias_Afas == 31
         nDias_Afas :=30
      EndIf

      If SRA->RA_AFASFGT $ 'Q1*Q3*Q4*Q5*Q6'
         cVerba_Mat := '003'
      Else
         cVerba_Mat := '303'
      EndIf
      
      // Abate a Insalubridade da Remuneração para que a mesma seja demonstrada em separado.
      fGeraVerba(cVerba_Mat, ROUND( (( (nSalProf - nVerba_246 ) / 30) * nDias_Afas), 2), nDias_Afas)

   ENDIF

   // Auxilio Doença...
   If fLocaliaPD("443") > 0
      aPD[fLocaliaPD("443"), 5] := ROUND( ( (SALMES / 30) * aPD[fLocaliaPD("443"), 4] ), 2)
   ENDIF
   If fLocaliaPD("083") > 0
      aPD[fLocaliaPD("083"), 5] := ROUND( ( (SALMES / 30) * aPD[fLocaliaPD("083"), 4] ), 2)
   ENDIF

   // Auxilio Acidente...
   If fLocaliaPD("444") > 0
      aPD[fLocaliaPD("444"), 5] := ROUND( ( (SALMES / 30) * aPD[fLocaliaPD("444"), 4] ), 2)
   ENDIF
   If fLocaliaPD("080") > 0
      aPD[fLocaliaPD("080"), 5] := ROUND( ( (SALMES / 30) * aPD[fLocaliaPD("080"), 4] ), 2)
   ENDIF

   RG1-> (DbSetOrder(1))
   RG1-> (DBGOTOP())
   
EndIf 

RETURN
