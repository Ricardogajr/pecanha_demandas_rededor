#Include "Protheus.ch"
#INCLUDE "MSOLE.CH"      
#INCLUDE 'FWMVCDEF.CH'

/*{Protheus.doc} MDTA9201
Função responsável por gravar a tabela auxiliar de Afastamentos lançados de forma retroativa.
@author		Nairan Alves Silva
@since		03/08/2017
@project	MAN0000007423045_EF_003 
*/
User Function MDTA9201()
Local aArea    := GetArea() // ticket n°4642966- 415966 - Paulo Dias 
Local aSR8Reg
Local aRetDias := {}
// ticket n°4642966- 415966 - Paulo Dias
Local nU013   := 0
Local dDtIni  := CTOD("  /  /  ")
Local dDtFim  := CTOD("  /  /  ")
Local dDtInix := CTOD("  /  /  ")
Local dDtFimx := CTOD("  /  /  ")
Local nDuracx := 0
Local cTip    := ""
Local cTipx   := ""

// Fim - Paulo

Private nRecSR8 := 0

	U_F1100105()  

	nU013 := U_DORLIMAT(cFilAnt,"U013")

	//Inicio da Gravação dos dados de afastamento na SR8  - Marcos Furtado - 20/01/2019
	
	If lIntGpe .and. (Altera .or. "EXCLUIR" $ ccadastro  )//Verifica se esta integrado ao GPE e alteracao ou inclusao
		aSR8Reg := { { "R8_FILIAL" , xFilial("SRA",TM0->TM0_FILFUN) } , { "R8_MAT" , SRA->RA_MAT } ,;
							{(IIF(nU013 > 0, "R8_XDTINI","R8_DATAINI")), TOF->TOF_DTSLIC } , { "R8_TIPO" , "Q" } } // ticket n°4642966- 415966 - Paulo Dias - tratamento para exclusão.
		If lTipoAfas
			aAdd( aSR8Reg , { "R8_TIPOAFA" , TOF->TOF_CODAFA } )
		EndIf
		
		nRecSR8 := MDTRecnoSR8( aSR8Reg )
	Endif
		                     
		//Exclui registro de afastamento anterior
	If (ALTERA .or. "EXCLUIR" $ ccadastro) .and. nRecSR8 > 0
		If lTipoAfas
			cCondSR8 := "If( Empty( SR8->R8_TIPO ), SubSTR( SR8->R8_TIPOAFA , 1 , 1 ) == 'Q' , SR8->R8_TIPO == 'Q' )"
		Else
			cCondSR8 := "SR8->R8_TIPO == 'Q'" 
		EndIf  
		 
		DbSelectArea("SR8")
		DbGoto(nRecSR8)	                  
		RecLock( "SR8", .F. )
		dbDelete()
		MsUnLock()    
		
	EndIf
	If INCLUI .or. ALTERA              
	
		//Verifica ultima sequencia 
		dbSelectArea("SR8")
		dbSetOrder(2)
		dbSeek(SRA->RA_FILIAL+SRA->RA_MAT+"ZZZ",.T.)
		dbSkip(-1)
		IF !Eof() .AND. SRA->RA_FILIAL+SRA->RA_MAT == SR8->R8_FILIAL+SR8->R8_MAT
			cSeq := SOMA1(SR8->R8_SEQ)
		Else
			cSeq := "001"
		Endif     
		       
		// ticket n°4642966- 415966 - Paulo Dias - tratamento para gravação dos campos e validação da tabela U013
		
				If nU013 > 0 // se blackout
					dDtIni  := CTOD("  /  /  ")
					dDtFim  := CTOD("  /  /  ")
					cTip    := ""
					dDtInix := M->TOF_DTSLIC
					dDtFimx := M->TOF_DTRLIC-1
					cTipx   := M->TOF_TPEFD	
					//Persistir gravação dos dados nos customizados na TOF
					M->TOF_XDTBLK := DATE() // Flag
					M->TOF_XDTSLI := M->TOF_DTSLIC
					M->TOF_XDTRLI := M->TOF_DTRLIC
					M->TOF_XCODAF := M->TOF_CODAFA
					M->TOF_XTPEFD := M->TOF_TPEFD
				Else
					dDtIni  := M->TOF_DTSLIC
					dDtFim  := M->TOF_DTRLIC-1
					cTip    := M->TOF_TPEFD
					dDtInix := M->TOF_DTSLIC
					dDtFimx := M->TOF_DTRLIC-1 
					cTipx   := M->TOF_TPEFD
				EndIf   
			Reclock("SR8",.T.)
			SR8->R8_FILIAL  := SRA->RA_FILIAL
			SR8->R8_SEQ 	:= cSeq
			SR8->R8_MAT 	:= SRA->RA_MAT
			SR8->R8_DATA 	:= dDataBase
			SR8->R8_DATAINI := dDtIni 
			SR8->R8_DATAFIM := dDtFim 
			SR8->R8_TIPO    := "Q"
			SR8->R8_CONTINU := "2"   
			SR8->R8_TPEFD   := cTip 		
			SR8->R8_XDTINI  := dDtInix 
			SR8->R8_XDTFIM  := dDtFimx 
			SR8->R8_XDURAC  := nDias  
			SR8->R8_XTPEFD  := cTipx 
			SR8->R8_XDTTRAN := DATE()
			SR8->R8_XHROPER := TIME()
			
			
			If lTipoAfas
				SR8->R8_TIPOAFA := M->TOF_CODAFA
				SR8->R8_PD := NGSeek( "RCM" , M->TOF_CODAFA , 1 , "RCM->RCM_PD" )			
			EndIf                       
						
			If lCpoDura//A empresa deverá pagar o salário integralmente a funcionária    
				aRetDias := a685AtuDia( M->TOF_DTSLIC, M->TOF_DTRLIC-1, "2" , Space(3),  ,  , , NGSeek( "RCM" , M->TOF_CODAFA , 1 , "RCM->RCM_DIASEM" ))				
				SR8->R8_DURACAO := IIF(nU013 > 0, 0, nDias)
				SR8->R8_DIASEMP := aRetDias[2]
				SR8->R8_DPAGAR  := aRetDias[3]
			Endif
			MsUnlock("SR8")         
			     
			If INCLUI 
				fMontaMail("018")
			Endif
			
	EndIf       
RestArea(aArea)
Return

// ticket n°4642966- 415966 - Paulo Dias 
//-----------------------------------------------//
// Função para validação do período de blackout  //
//-----------------------------------------------//
User Function DORLIMAT(cFil,cTab)

Local aArea    := GetArea()
Local aDataBloq:= {}
Local cFilU013 := cFil
Local nBlk := 0
Local cTabela  := cTab

fCarrTab(@aDataBloq,cTabela, Nil )

If Len(aDataBloq) > 0
   If Ascan(aDataBloq,{|x| x[1] == cTabela .And. Alltrim(x[2]) == cFilU013}) > 0
      nBlk := Ascan(aDataBloq,{|x| x[1] == cTabela .And. Alltrim(x[2]) == cFilU013 .And. dDataBase >= x[5] .And. dDataBase <= x[6]})
   Else
      cFilU013 := ""
      If Ascan(aDataBloq,{|x| x[1] == cTabela .And. Alltrim(x[2]) == cFilU013}) > 0
         nBlk := Ascan(aDataBloq,{|x| x[1] == cTabela .And. Alltrim(x[2]) == cFilU013 .And. dDataBase >= x[5] .And. dDataBase <= x[6]})
      EndIf
   EndIf
EndIf

RestArea(aArea) 

Return nBlk