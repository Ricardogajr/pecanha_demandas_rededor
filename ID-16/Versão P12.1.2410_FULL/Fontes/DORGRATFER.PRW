#INCLUDE "rwmake.ch"
User Function DORGRATFER

Local nVal_Grat    := 0
Local nVal_Sal_Dia := 0
Local nDias_Grat := 0
Local nTotAnos   := 0
Local dData_Adm  := ctod("//")
Local dData_Base := ctod("//")


If SRA->RA_FILIAL <> "04I90001"
   Return
EndIf


nVal_Sal_Dia := (SRA->RA_SALARIO / 30)
dData_Adm    := SRA->RA_ADMISSA
dData_Base   := M->RH_DATAINI


nTotAnos := DateDiffYear( dData_Adm , dData_Base )


If nTotAnos >= 15


   Do Case
      Case nTotAnos >= 15 .and.  nTotAnos < 20
         nDias_Grat := fTabela("U020", 1, 4)
         nVal_Grat  :=  nVal_Sal_Dia * nDias_Grat
      Case nTotAnos >= 20 .and.  nTotAnos < 25
         nDias_Grat := fTabela("U020", 1, 5)
         nVal_Grat  :=  nVal_Sal_Dia * nDias_Grat
   Otherwise
         nDias_Grat := fTabela("U020", 1, 6)
         nVal_Grat  :=  nVal_Sal_Dia * nDias_Grat
   EndCase


   fGeraVerba("206", nVal_Grat, nDias_Grat,,SRA->RA_CC,"V","I",0,,dData_Pgto, .T. )

EndIf

Return
