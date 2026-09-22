#INCLUDE "PROTHEUS.CH"     

/*========================================================================================================================================
/  Funcao para integração do vale transporte com os valores extras. 
/  TIPO 1 - EXTRA - Calculo do Vale Transporte que será pago via rotina de valores extras e NAO vai para o arquivo de compra alelo
/  @author     A.Shibao
/  @since      27/09/16
/  @param		
/  @version    P12
/  @return      
/  @project 
/  @client    RedeDor   
/  @ criar uma formula e chamar a funcao no roteiro VEX.  
// 26/09/17 - A.Shibao - Ajustado para buscar o periodo aberto da folha para efetuar a integracao.
//========================================================================================================================================  */
User Function DorIntVTEX()              

Local oDlg
Local oRadio		
Local nRadio        := 2   // ja traz selecionado o "nao"
Local nXOpca 	    := 1   
Local aArea         := GetArea()

Private cTipCal		:= "0"

If M_XVTEXTRA == .T.

		fIntegVtExt(SRA->RA_FILIAL,SRA->RA_MAT,CSEMANA,CPROCESSO,CPERIODO,"FOL",CNUMPAG) 

Else
	If M_XCTRLVEX == .T.
	
		While nXOpca == 1      
	    
			DEFINE MSDIALOG oDlg FROM  94,1 TO 273,293 TITLE OemToAnsi("Integração") PIXEL // "Tipo do Beneficio"
			
			@ 10,5 Say OemToAnsi("Deseja Integrar o Vale Transporte com Valores Extras :") SIZE 150,7 OF oDlg PIXEL 
			
			@ 27,07 TO 72, 140 OF oDlg  PIXEL
			
		 
				@ 35,10 Radio 	oRadio VAR nRadio;
						ITEMS 	OemToAnsi("Sim"),;
								OemToAnsi("Nao");
						3D SIZE 100,10 OF oDlg PIXEL
		
			
			DEFINE SBUTTON FROM 75,085 TYPE 1 ENABLE OF oDlg ACTION (nXOpca := 1, oDlg:End())
			DEFINE SBUTTON FROM 75,115 TYPE 2 ENABLE OF oDlg ACTION (nXOpca := 0, oDlg:End())
			
			ACTIVATE MSDIALOG oDlg CENTERED ON INIT (nXOpca := 0, .T.)	// Zero nXOpca caso 
		                                                             	// para saida com ESC
		
			If nXOpca == 1   
		
				If nRadio == 1
					cTipCal   := "0" // Vale Transporte 
					M_XVTEXTRA:= .T. // Mneumonico 
		
					fIntegVtExt(SRA->RA_FILIAL,SRA->RA_MAT,CSEMANA,CPROCESSO,CPERIODO,"FOL",CNUMPAG) 
					
				EndIf   
				// controle para nao executar a rotina qdo calculado o VEX todo e selecionado a opcao "nao"
				nXOpca    := 0                                           
				M_XCTRLVEX:= .f.
			
			Else

				M_XCTRLVEX := .f. 
				LABORTPRINT:= .T. // sai de todos os calculos

			Endif  
		                     
			nXOpca := 2 		
			
		EndDo
	Endif
Endif                             

RestArea(aArea)
	
Return("FIM")

/*========================================================================================================================================
/  Funcao de processmaneto
/  @author     A.Shibao
/  @since      27/09/16
/  @param		
/  @version    P12
/  @return      
/  @project 
/  @client    RedeDor   
//========================================================================================================================================*/
Static Function fIntegVtExt(cShFil,cShMatr,cShSemana,cShProces,cShPeriodo,cShRoteiro,cShNumPag)

Local aArea		:= GetArea()
Local cShVrbVT  := acodfol[052,1]
Local aSHVTExt  := {}
Local nPosVTExt := 0   
Local lFoundFil := .F. 

Local aPerAtual := {}
Local cSemanaFol:= ""  
Local cShPeriFol:= ""

DEFAULT cShFil		:= SRA->RA_FILIAL
DEFAULT cShMatr		:= SRA->RA_MAT
DEFAULT cShNumPag	:= Space( GetSx3Cache("RCH_NUMPAG"	, "X3_TAMANHO") )  
DEFAULT cShProces	:= SRA->RA_PROCES
//DEFAULT cShPeriodo	:= Space( GetSx3Cache("RCH_PER"		, "X3_TAMANHO") )
//DEFAULT cShRoteiro	:= GetRotExec()

//Busca periodo da folha aberto
fGetPerAtual( @aPerAtual,cShFil,cShProces,cShRoteiro )

If Len(aPerAtual) > 0
	cShPeriFol := aPerAtual[1,5]+aPerAtual[1,4] 	// perido da folha
	cSemanaFol  := aPerAtual[1,2]                   // semana da folha
Else
 	Alert("Nao existe periodo da folha aberto para efetuar a integração.") 
 	M_XCTRLVEX	:= .F.  
 	M_XVTEXTRA	:= .F.
	LABORTPRINT := .T. 	
 	Return
Endif

// Busca na tabela se a filial ira gerar valor extra
fCarrTab( @aSHVTExt,"U109", Nil)  
 
// Verifico se existe registros na tabela com as verbas que devem ser deletadas.		   
If ( nPosVTExt := Ascan(aSHVTExt,{ |x| x[1] == "U109" .And. alltrim(x[2]) == alltrim(SRA->RA_FILIAL)  .And.  alltrim(x[5]) == "1"}))  > 0  
	lFoundFil  := .T.
Else
 	Alert("Você escolheu a integração do VT, porém essa filial não está cadastrada na tabela U109 para ser pago via valores extras, favor ajustar.")
	M_XCTRLVEX  := .f.
	M_XVTEXTRA  := .F.  
	LABORTPRINT := .T.
 	Return
Endif

If  lFoundFil 
	
	dbSelectArea( "RGB" )
	//RGB_FILIAL+RGB_PROCES+RGB_PERIOD+RGB_SEMANA+RGB_ROTEIR+RGB_MAT+RGB_PD+RGB_SEQ                                                                                   
	DbSetOrder(5)                      
	DbGoTop()
	
	// buscao no roteiro FOL a verba que veio do VT para alterar para VEX.
	If RGB->(DbSeek(cShFil + cShProces + cShPeriFol + cSemanaFol + cShRoteiro + cShMatr + cShVrbVT  )) 
		RecLock( "RGB" ,.F.,.T.)
	    RGB->RGB_ROTEIR:= "VEX"
	    RGB->RGB_SEMANA:= cShSemana     // gravo a semana do roteiro VEX que for calcular.
	    RGB->RGB_PERIOD:= cShPeriodo	// gravo o periodo do roteiro VEX que for calcular.    	    
		MsUnlock()
	Endif
	
Endif
	
dbCloseArea()
RestArea(aArea)		

Return(aPd)
