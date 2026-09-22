#INCLUDE "rwmake.ch"
#include "protheus.ch"
#Include 'TopConn.Ch' 

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  SISPAG001    º Autor ³ Rafael Melo      º Data ³  16/02/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ RETORNAR AGENCIA E CONTA DO FAVORECIDO - SISPAG            º±±
±±º          ³ DOC, TED E CREDITO E CONTA CORRENTE                        º±±
±±º          ³ POSICAO  - 024 - 043 - HEADER DE ARQUIVO                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SISPAG - ARQ CONFIG - ITAUFIN.PAG                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function SISPAG001()

Local aArea    := GetArea() // ticket n° 8974475 
Local cAgConta := ""
Local cCod := Alltrim(U_SISFOR("A2_DVCTA"))	//Adicionado para atender banco com dois caracteres no digito verificador da conta 02/08/12

If !EMPTY(SA2->A2_XCNPJPG)
	DBSELECTAREA("SA2")
	DBSETORDER(3)
	DBSeek(xFilial("SA2")+SA2->A2_XCNPJPG)
EndIf 
If SA2->A2_BANCO == "341" .Or. AllTrim(SEA->EA_MODELO) $ "10|02"
//If Alltrim(U_SISFOR("A2_BANCO")) == '341'  .Or. AllTrim(SEA->EA_MODELO) $ "10|02"                                // Posições

   	cAgConta := "0"                                      // 024 - 024
   	If AllTrim(SEA->EA_MODELO) $ "10|02"
   		cAgConta += STRZERO(VAL(ALLTRIM(SA6->A6_AGENCIA)),4)                     // 025 - 028
   		cAgConta += " "                                      // 029 - 029
   		cAgConta += "000000"                                // 030 - 036
	 // Os campos Conta e DAC devem ser preenchidos com zeros quando a forma de pagamento for 02 ou 10 (cheque ou Ordem de Pagamento), porque neste caso a OP ou o cheque ficarão à disposição do favorecido na agência indicada.
		cAgConta += "000000" // 037 - 041
		cAgConta += " 0" // 042 - 043 
   	Else
   	   	cAgConta += STRZERO(VAL(ALLTRIM(U_SISFOR("A2_AGENCIA"))),4) // 025 - 028
	   	cAgConta += " "                                      // 029 - 029
	   	cAgConta += "000000"                                // 030 - 036
		cAgConta += STRZERO(VAL(ALLTRIM(U_SISFOR("A2_NUMCON"))),6)  // 037 - 041
		cAgConta += If(len(cCod) = 1 ," " + substr(cCod,1,1), SubStr(cCod,1,1) + SubStr(cCod,2,1)) // 042 - 043 
	   	//Adicionado para atender a bancos com dois caracteres no digito verificador da conta 
   EndIf
  
Else
	
	cAgConta := STRZERO(VAL(ALLTRIM(U_SISFOR("A2_AGENCIA"))),5) // 024 - 028
	cAgConta += " "                                      // 029 - 029
    //cAgConta += STRZERO(VAL(U_SISFOR("A2_NUMCON")),12)          // 030 - 041
	cAgConta += STRZERO(GetdToVal(U_SISFOR("A2_NUMCON")),12)          // 030 - 041                             // ticket n° 12923588
    cAgConta += If(len(cCod) = 1 ," " + Substr(cCod,1,1), SubStr(cCod,1,1) + SubStr(cCod,2,1)) // 042 - 043 
   	//Adicionado para atender a bancos com dois caracteres no digito verificador da conta
   
EndIf
//RIGHT(TRIM(SA6->A6_NUMCON),1)   
RestArea(aArea)   // ticket n° 8974475                          
Return(cAgConta)


/*
{Protheus.doc} SISFOR
Tratamento para retornar a informação do Fornecedor Pagador quando necessário
@Author     Ramon Teodoro e Silva
@Since      26/10/2017     
@Version    P12.7
@Return
*/

User Function SisFor(cCampo)

Local cRet  := ""
Local aArea := SA2->(GetArea())

If !Empty(SA2->A2_XCNPJPG)
	cRet := Posicione( "SA2", 3, xFilial("SA2")+SA2->A2_XCNPJPG, cCampo)	
Else
	cRet := &("SA2->"+cCampo)
EndIf

RestArea(aArea)
Return cRet


/*
{Protheus.doc} BcoFav
Função para retornar o código do banco favorecido -  em casos de ordem de pagamento, não serão
considerados os dados do favorecido e sim os indicados para a retirada do dinheiro.
@Author     Ramon Teodoro e Silva
@Since      05/04/2017     
@Version    P12.7
@Return
*/

User Function BcoFav()

Local cRet  := ""

If AllTrim(SEA->EA_MODELO) $ "10|02"
	cRet := SubStr(SEA->EA_PORTADO,1,3)           	
Else
	cRet := SubStr(U_SISFOR("A2_BANCO"),1,3)            
EndIf

Return cRet


/*
{Protheus.doc} SomaAcresc
Função para retornar o valor total de acréscimo para o trailer do segmento N.
@Author     Ramon Teodoro e Silva
@Since      15/06/2018     
@Version    P12.7
@Return
*/

User Function SomaAcresc()

Return  nSomaAcres * 100


/*
{Protheus.doc} TotValLiq
Função para retornar o valor líquido para o trailer do segmento N.
@Author     Ramon Teodoro e Silva
@Since      15/06/2018     
@Version    P12.7
@Return
*/

User Function TotValLiq()

Return SOMAVALOR() - ( nSomaAcres + U_TotVlOut(mv_par01, mv_par02) ) 


/*
{Protheus.doc} TotVlOut
Função para retornar o valor total de outras entidades
@Author     Ramon Teodoro e Silva
@Since      21/12/2018     
@Version    P12.7
@Return
*/

User Function TotVlOut(cPar01, cPar02)

Local nTotRet := 0
Local aArea   := GetArea()
Local cQuery  := ''

If AllTrim(SE2->E2_FORMPAG) == "17"

	cQuery := " SELECT SUM ( E2_XTERCEI ) E2_XTERCEI FROM " + RetSqlName("SE2") 
	cQuery += " WHERE E2_FILIAL = '" + xFilial("SE2") + "' AND " 
	cQuery += " E2_NUMBOR >= '" + cPar01 + "' AND E2_NUMBOR <= '" + cPar02 + "' AND E2_XTERCEI > 0 AND "
	cQuery += " D_E_L_E_T_ = ''"
	
	cQuery := ChangeQuery(cQuery)
	cAliasTmp := GetNextAlias() 
	
	DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTmp,.F.,.T.)
	
	If !((cAliasTmp)->(Eof()))
		nTotRet := (cAliasTmp)->(E2_XTERCEI)	
	EndIf

EndIf

RestArea(aArea)
Return nTotRet*100 

