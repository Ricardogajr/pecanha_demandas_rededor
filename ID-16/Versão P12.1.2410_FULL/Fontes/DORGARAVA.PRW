#INCLUDE "PROTHEUS.CH"
//============================================================================================
/*/
Rotinas para calculo de garantia de vale alimentacao para funcinario afastado.
@author     A.Shibao
@since      07/11/16
@param		
@version    P12
@return      
@project 
@client    RedeDor   
@array     aVACalc    - private onde ja vem com os valores do vale calculado pronto para gravar
//06/07/17 - A.Shibao - Ajuste efetuado para NAO calcular o VA para funcionarios que estejam
						afastados e nao estejam dentro da excecao, pois o sistema como padrao			
  	                    SEMPRE paga o VA qdo o cad do beneficio estiver preenchido RFO_DIAFIX.
*/
//============================================================================================  
User Function DorGaraVa()

Local aShGrVa   := {}
Local nSalM     := SRA->RA_SALARIO
Local aShAfast  := {}  
Local nShDFixo	:= 0

Private dShDtPes1	:= dDataAte  
Private dShDtPes2	:= Ctod("//") 
Private dShDtPes3	:= Ctod("//")   
Private lExcecao    := .F.

DbSelectArea("SR0")
SR0->(DbSetOrder(3))
                       
DbSelectArea("RFO")
RFO->(DbSetOrder(1))

// Carrega tabela especifica
fCarrTab( @aShGrVa,"U10C", Nil )

// afastados 
If SRA->RA_SITFOLH == "A"
    
	// afastado que estao na regra de garantia.
	If ((nPoSu10c	:=	Ascan(aShGrVa,{|x| x[1] == "U10C" .And. Alltrim(x[2]) == Alltrim(SRA->RA_FILIAL) .And. Alltrim(x[5]) == SRA->RA_SINDICA })   ) > 0   ) 
		If Empty(aShGrVa[nPoSu10c,5])  // coluna sindicato
	     	Alert("Tabelas U10C não possui sindicato cadastrado, favor verificar")
		    Return
		ElseIf Empty(aShGrVa[nPoSu10c,6]) .Or. aShGrVa[nPoSu10c,6] > 12  // coluna meses                                                                    
	     	Alert("Tabelas U10C coluna 'Qtde de Meses', esta em branco ou maior que 12 meses, favor verificar")
		    Return	
		Else   
			 nMeses:= aShGrVa[nPoSu10c,6]
				 
				 // verifica se existe afastamento dentro do periodo devido.
			 	 //fRetAfas( dShDtPes1, dShDtPes2 , , , , @aShAfast )
			 	 
			 	 fSearchR8(dShDtPes2,dShDtPes3)
			 	 
	 			 // data limite para verificar ate qdo sera pago o beneficio 
				 dShDtPes1:= SubMeses(stod(@dShDtPes2),@nMeses)              
				 
				 /* Zera o array aDiasMes pois o sistema irá considerar o RCF_DALIM do cadastro de periodo.
				 If sTod(dShDtPes2) >= dShDtPes1 
					 aDiasMes:= {}
					 lExcecao:= .T.
				 Endif
				 */
				 // perdeu o direito pois nao esta na excecao
	 			 If ANOMES(dShDtPes1) < ANOMES(dDataAte)
	 			 	 // zero os valores no array para nao ficar sujeira no SR0	
					 For nVa:= 1 to len(aVACalc)
						 //aVACalc[nVa,1]:=0
						 aVACalc[nVa,2]:=0
						 aVACalc[nVa,3]:=0					 
						 aVACalc[nVa,4]:=0					 
						 aVACalc[nVa,5]:=0
						 aVACalc[nVa,6]:=0					 					 
						 aVACalc[nVa,7]:=0					 
					 Next nVa             
					 
					 lExcecao:= .T.			 
	
				 Endif
				 
				 /* o sistema "sempre" esta pagando o vale alimentacao para funcionarios afastados qdo tem RFO->RFO_DIAFIX preenchido,
		            entao caso nao esteja na excecao acima, eu deletarei o calculo para que nao seja gerado nenhum valor ao func.
				 
				 If SR0->(dBSeek(SRA->RA_FILIAL+SRA->RA_MAT+"2"))  .And. !(lExcecao)
				 
					 If RFO->(dBSeek(xFilial("SRA") + "2" + SR0->R0_CODIGO)) 
						 nShDFixo:= RFO->RFO_DIAFIX
						 
						 If nShDFixo > 0 
							// zero os valores no array para nao ficar sujeira no SR0	
							 For nVa:= 1 to len(aVACalc)
								 //aVACalc[nVa,1]:=0
								 aVACalc[nVa,2]:=0
								 aVACalc[nVa,3]:=0					 
								 aVACalc[nVa,4]:=0					 
								 aVACalc[nVa,5]:=0
								 aVACalc[nVa,6]:=0					 					 
								 aVACalc[nVa,7]:=0					 
							 Next nVa 
						 Endif 
						 
					 Endif			 	
				 
				 Endif	 
				 */
		Endif	
	
	// afastados que NAO estao na regra da garantia e devem ser zerados o valores pois o padrao gera valor qdo possui dias fixos 	
	Elseif len(aVACalc)> 0  
	
	 	 // zero os valores no array para nao ficar sujeira no SR0	
		 For nVa:= 1 to len(aVACalc)
			 //aVACalc[nVa,1]:=0
			 aVACalc[nVa,2]:=0
			 aVACalc[nVa,3]:=0					 
			 aVACalc[nVa,4]:=0					 
			 aVACalc[nVa,5]:=0
			 aVACalc[nVa,6]:=0					 					 
			 aVACalc[nVa,7]:=0					 
		 Next nVa   
	
	
	Endif
	
Endif	
	
Return("FIM") 
               


************************************************
Static function SubMeses(dData,nMenos)
************************************************
Local dDtMenos
Local nMes := Month(dData)
Local nAno := Year(dData)
Local n 	:= 0 

For n = 1 To nMenos
	nMes := nMes + 1
	If nMes > 12 
		nMes := 1
		nAno += 1
	Endif
Next
dDtMenos := Ctod("01/"+StrZero(nMes,2)+"/"+StrZero(nAno,4) , "DDMMYY" )
Return(dDtMenos)         


************************************************
Static function fSearchR8(dData,dData1)
************************************************

Local cQr

cQr := "SELECT R8_MAT, R8_DATAINI, R8_DATAFIM, "
cQr += " ( SELECT COUNT (*)  as LASHTREG FROM "+RETSQLNAME('SR8')+" RR8 "  
cQr += "   WHERE R8_FILIAL = '" + SRA->RA_FILIAL + "' "
cQr += "   AND R8_MAT = '" + SRA->RA_MAT + "' "
cQr += "   AND RR8.D_E_L_E_T_   = ' '  "
cQr += " ) "
cQr += "FROM "+RETSQLNAME('SR8')+" SR8 "  
cQr += "WHERE R8_FILIAL = '" + SRA->RA_FILIAL + "' "
cQr += "AND R8_MAT = '" + SRA->RA_MAT + "' "
cQr += "AND SR8.D_E_L_E_T_   = ' '  "


If Select("TRD") > 0
	TRD->(dbCloseArea())
Endif

dbUseArea(.T.,"TOPCONN", TCGENQRY(,,cQr),"TRD",.F.,.T.)

While TRD->(!Eof())
    dShDtPes2:= TRD->R8_DATAINI
	dShDtPes3:= TRD->R8_DATAFIM
   dbSkip()
EndDo

Return()