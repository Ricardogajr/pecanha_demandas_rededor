#Include 'Totvs.ch'
#Include 'FWMVCDEF.ch'

/*
Funcao: GPESALAR - Ponto de Entrada para alterar o salario de 'Docentes'
Autor : Mauricio Siqueira
Data..: 13/07/2022
VersÃ£o: Protheus12
*/

User Function GPESALAR()

Local nVerba_467 := GetValType('N') // Salário Docente
Local nVerba_468 := GetValType('N') // DSR Docente
Local nVerba_472 := GetValType('N') // Adicional Qualificação
Local nVerba_473 := GetValType('N') // Extra Classe 
Local nVerba_474 := GetValType('N') // Supervisão de Estágio
Local nVerba_475 := GetValType('N') // Remuneração de Coordenador
Local nVerba_246 := GetValType('N') // Insalubridade (código padrão)
Local nVerba_307 := GetValType('N') // ATS - quinquenio (código padrão)
Local cFilDocent := GetValType('C') // Filiais Sujeitas aos Cálculos de Docentes
Local nSalProf   := GetValType('N') // Remuneração do Professor

// Mnemônico específico para relacionar filiais sujeitas ao cálculo de docentes...
cFilDocent := AllTrim(GetAdvFVal("RCA", "RCA_CONTEU", xFilial("RCA")+"M_FILDOCEN", 1, 0) )

If SRA->RA_FILIAL $ cFilDocent .AND. SRA->RA_PROCES = '00006'    // '01BQ0001 - UNINEVES'
 
   // Busca em Valores Fixos, a remuneração do docente...
   RG1-> (DBGOTOP())
   RG1-> (DbSetOrder(8)) 

   nVerba_246 := If( RG1->(DBSEEK( SRA->RA_FILIAL + SRA->RA_MAT + '246', .F. ) ), RG1->rg1_valor, 0 )
   nVerba_307 := If( RG1->(DBSEEK( SRA->RA_FILIAL + SRA->RA_MAT + '307', .F. ) ), RG1->rg1_valor, 0 )
   nVerba_467 := If( RG1->(DBSEEK( SRA->RA_FILIAL + SRA->RA_MAT + '467', .F. ) ), RG1->rg1_valor, 0 )
   nVerba_468 := If( RG1->(DBSEEK( SRA->RA_FILIAL + SRA->RA_MAT + '468', .F. ) ), RG1->rg1_valor, 0 )
   nVerba_472 := If( RG1->(DBSEEK( SRA->RA_FILIAL + SRA->RA_MAT + '472', .F. ) ), RG1->rg1_valor, 0 )
   nVerba_473 := If( RG1->(DBSEEK( SRA->RA_FILIAL + SRA->RA_MAT + '473', .F. ) ), RG1->rg1_valor, 0 )
   nVerba_474 := If( RG1->(DBSEEK( SRA->RA_FILIAL + SRA->RA_MAT + '474', .F. ) ), RG1->rg1_valor, 0 )
   nVerba_475 := If( RG1->(DBSEEK( SRA->RA_FILIAL + SRA->RA_MAT + '475', .F. ) ), RG1->rg1_valor, 0 )

   nSalProf := nVerba_307 + nVerba_467 + nVerba_468
   nSalProf += nVerba_472 + nVerba_473 + nVerba_474 + nVerba_475
   
   RG1-> (DbSetOrder(1))
   RG1-> (DBGOTOP())
 
   oModelx := FWModelActive()

   If oModelx:GetOperation() == MODEL_OPERATION_INSERT
      oModelxDet := oModelx:GetModel('GPEM040_MSRG')
      oModelxDet:LoadValue('RG_SALMES',nSalProf)
      oModelxDet:LoadValue('RG_SALDIA',nSalProf/30)
      oModelxDet:LoadValue('RG_SALHORA',nSalProf/SRA->RA_HRSMES)
   EndIf

EndIf

Return
