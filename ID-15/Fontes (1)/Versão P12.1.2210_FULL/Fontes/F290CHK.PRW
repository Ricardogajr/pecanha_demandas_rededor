#include 'protheus.ch'
#include 'totvs.ch'
#include 'parmtype.ch'


/*/{Protheus.doc} F290CHK
Ponto de Entrada que altera os Filtro dos Títulos que podem
ser incluídos numa fatura a pagar
@authora Thais Paiva
@data 28/05/2020
@retorno cfiltro
@chamado 8813936
/*/

User Function F290CHK()
Local cFiltro := PARAMIXB
Local _aAreaFin	:= GetArea()
Local oDlgNat 
Local lOk	:= .F.
Local _cNatDe	:= Space(TamSX3("E2_NATUREZ")[1])
Local _cNatAte	:= Space(TamSX3("E2_NATUREZ")[1])


// Rafael Yera Barchi - 16/07/2021
// Chamado 12045907
// Tratativa para verificar se não está sendo executada por job/Schedule
If !IsBlind()

    Define MSDialog oDlgNat Title "Selecione a Natureza" From 0,0 to 165,360 Pixel STYLE DS_MODALFRAME

    @009,009 Say "Natureza De:"		Pixel of oDlgNat
    @007,100 MSGet _cNatDe Size 50,10 of oDlgNat Pixel VALID FvalNat(_cNatDe,_cNatAte,1) F3 "SED"

    @035,009 Say "Natureza Ate:"	Pixel of oDlgNat
    @033,100 MSGet _cNatAte    Size 50,10 of oDlgNat Pixel VALID FvalNat(_cNatDe,_cNatAte,2) F3 "SED"

    DEFINE SBUTTON FROM 065,050 TYPE 1 ENABLE ACTION ( lOk :=  .T.,oDlgNat:End()) OF oDlgNat
    DEFINE SBUTTON FROM 065,100 TYPE 2 ENABLE ACTION ( oDlgNat:End()) OF oDlgNat

    ACTIVATE MSDIALOG oDlgNat Center    

    If lOk .AND. !Empty(Alltrim(_cNatDe)) .AND. !Empty(Alltrim(_cNatAte))

        cFiltro += " AND E2_NATUREZ BETWEEN '"+Alltrim(_cNatDe)+"' AND '"+Alltrim(_cNatAte)+"' "

    EndIf

EndIf
        
RestArea(_aAreaFin)

Return cFiltro

Static Function FvalNat(_cNatDe,_cNatAte,_nOp)
Local lRet := .T.

If _nOp == 1 

	If !Empty(Alltrim(_cNatDe))

		If !ExistCpo("SED",_cNatDe)
			lRet := .F.
		EndIf
		
	EndIf
	
ElseIf _nOp == 2

	If !Empty(Alltrim(_cNatAte)) .AND. UPPER(Alltrim(_cNatAte)) <> 'ZZZZZZZZZZ'

		If !ExistCpo("SED",_cNatAte)
			lRet := .F.
		ElseIf Alltrim(_cNatDe) > Alltrim(_cNatAte)
			MSGALERT( "O campo Natureza De nao pode ser maior que o campo Natureza Ate.", "Atencao" )
			lRet := .F.
		EndIf
	
	EndIf

EndIf

Return lRet
