#Include "Protheus.Ch"

User Function LCTOIMP
                                                                                                                                                                                           
Local nValor := 0

If EMPTY(SE2->E2_BAIXA) .AND. SE2->E2_SALDO<>SE2->E2_VALOR
	nValor := 0
	Return(nValor)
Endif

If !Alltrim(SE5->E5_MOTBX) $ "DAC/CMP/FAT/PCC" .AND. ALLTRIM(SE2->E2_FORNECE) == "UNIAO"

	//COFINS / CSLL / PIS
	If Alltrim(SE2->E2_NATUREZ)$"COFINS/CSLL/PIS" 
		nValor := SE5->E5_VALOR-SE5->E5_VLJUROS-SE5->E5_VLMULTA   
		
	EndIf

ElseIF ALLTRIM(SE2->E2_NATUREZA) $ "ISS/INSS" .AND. ALLTRIM(SE2->E2_TIPO) $ "ISS/TX/INS"
	nValor := SE2->E2_VALLIQ

Endif	




Return(nValor)