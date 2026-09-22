#Include 'Protheus.ch'
#Include 'TopConn.ch'
#Include 'FWMVCDef.ch'

/*
{Protheus.doc} F0200701()
Relatório de Lista Crítica em Excel
@Author     Paulo Krüger
@Since      01/09/2016
@Version    P12.7
@Project    MAN00000463301_EF_007      
@Return     
*/

User Function F0200701() 

	Local oReport
	Private aMaiorCons	:= {}
	Private aMaxO6Q6	:= {}
	Private aMaxO6V6	:= {}
	Private cAnlCrit	:= ''
	Private cAnLsCr    	:= ''

	Private cAplMnlc := ""

	Private cAnPrvVenc	:= ''
	Private cCalculo   	:= ''
	Private nCobALM    	:= 0
	Private nCobFAR    	:= 0
	Private nCobUni    	:= 0
	Private cFreq      	:= ''
	Private cGrupam    	:= ''
	Private cMatSubs	:= ''
	Private cNivCritLC 	:= ''
	Private cNivCritPV 	:= ''
	Private dDTBASE		:= CTOD('  /  /  ')
	Private dDtA 		:= CTOD('  /  /  ')
	Private dDt7 		:= CTOD('  /  /  ')
	Private dDt15 		:= CTOD('  /  /  ')
	Private dDt30 		:= CTOD('  /  /  ')
	Private dDt60 		:= CTOD('  /  /  ')
	Private dDt90 		:= CTOD('  /  /  ')
	Private dDt120 		:= CTOD('  /  /  ')
	Private dDt150 		:= CTOD('  /  /  ')
	Private dDt180 		:= CTOD('  /  /  ')
	Private nCD30xCD7  	:= 0
	Private nCD90xCD30 	:= 0
	Private nCusmed		:= 0
	Private nDiasAtraz	:= 0
	Private nEstSeg    	:= 0
	Private nLeadTime  	:= ''
	Private nLenFil		:= 0
	Private nMaiorCons	:= 0
	Private nMaxO6Q6	:= 0
	Private nMaxO6V6	:= 0
	Private nQtdCD07	:= 0
	Private nQtdCD120	:= 0
	Private nQtdCD15	:= 0
	Private nQtdCD150	:= 0
	Private nQtdCD180	:= 0
	Private nQtdCD30	:= 0
	Private nQtdCD60	:= 0
	Private nQtdCD90	:= 0
	Private nQtdCDA		:= 0
	Private nSalALM    	:= 0
	Private nSalAlmTot	:= 0
	Private nSalARS    	:= 0
	Private nSalFAR    	:= 0
	Private nSArmExt   	:= 0
	Private nTamFil		:= 0
	Private nCobARS		:= 0
	Private nCobTot		:= 0
	Private cAnPreVenc 	:= ''
	Private nVlFatMin	:= 0
	Private cIndNvServ	:= ''
	Private cAnalista  	:= ''
	Private cComprad	:= ''
	Private cNumPcSC    := ''
	Private cConsumo	:= 'S'
	Private lDebug	:= .F.

	If TRepInUse()
		/*===========================================================================|
		|Parâmetros:                                                                 |
		|============================================================================|
		|mv_par01| Tipo de Relatório         | 1 - Lista Crítica.                    |
		|        |                           | 2 - Manutenção Lista Crítica.         |
		|        |                           | 3 - Previsão Vencida.                 |
		|--------|-------------------------------------------------------------------|
		|mv_par02| Data de Referência        | Inicializador padrão: dDataBase.      |                      
		|--------|-------------------------------------------------------------------|
        |mv_par03| Produto                   | Consulta padrão SB1.                  |
		|--------|-------------------------------------------------------------------|
        |mv_par04| Categoria                 | Consulta padrão 	ACU.                 |
		|--------|-------------------------------------------------------------------|
        |mv_par05| Categoria controlada pela |                                       |
        |        | equipe de planejamento    | 1 = Sim, 2 = Não                      |
		|--------|-------------------------------------------------------------------|*/

		Pergunte('FSW0200701',.F.)
		
		MV_PAR02 := dDataBase       

		Pergunte('FSW0200701',.T.)
		
		If Empty(MV_PAR02)
			MsgAlert('Não foi possível gerar o relatório. Informe a Data de Referência.')
			Return
		ElseIf Empty(MV_PAR05)
			MsgAlert('Não foi possivel gerar o relatório. Defina Sim ou Não em Categoria controlada pela equipe de planejamento.')
		Else
			dDTBASE	:= MV_PAR02
			dDtA 	:= dDTBASE - 1
			dDt7 	:= dDTBASE - 7
			dDt15 	:= dDTBASE - 15
			dDt30 	:= dDTBASE - 30
			dDt60 	:= dDTBASE - 60
			dDt90 	:= dDTBASE - 90
			dDt120 	:= dDTBASE - 120
			dDt150 	:= dDTBASE - 150
			dDt180 	:= dDTBASE - 180
		
			oReport := ReportDef()
			oReport :PrintDialog()
		EndIf
	EndIf
Return

Static Function ReportDef()
	Local oReport
	Local oSection
	Local oBreak

	oReport 	:= TReport():New('FSW01007XX','Relatorio de Lista Critica','FSW0200701',;
									{|oReport| PrintReport(oReport)},"Relatorio de Lista Critica")
	oSection	:= TRSection():New(oReport,'Compras',{	'cAlias01','cAlias02','cAlias03','cAlias04',;
														'cAlias05','cAlias06','cAlias07','cAlias08',;
		                                             	'cAlias09','cAlias10','cAlias11','cAlias12',;
		                                             	'cAlias13','cAlias14','cAlias15','cAlias16','cAlias17'})
	TRCell():New(oSection,'FILIAL'		,'cAlias01','Estabelecimento'			,,,,{||(FWFilialName(,cAlias01->FILIAL))	},,,,,,,,,.t.)
	TRCell():New(oSection,'PRODUTO'		,'cAlias01','Material'					,,,,{||(cAlias01->PRODUTO)      			},,,,,,,,,.t.)
	TRCell():New(oSection,'DESCRICAO'	,'cAlias01','Descricao'					,,,,{||(cAlias01->DESCRICAO)    			},,,,,,,,,.t.)
	TRCell():New(oSection,'CATEGORIA'	,'cAlias01','Segmento'					,,,,{||(cAlias01->SEGMENTO)	    			},,,,,,,,,.t.)
	TRCell():New(oSection,'EMISSAO'		,'cAlias01','Dt. Emissao'				,,,,{||(STOD(cAlias01->EMISSAO))			},,,,,,,,,.t.)
//	TRCell():New(oSection,'NUMPCSC'		,'cAlias01','Ordem Compra'				,,,,{||(cAlias01->NUMPCSC)      			},,,,,,,,,.t.)

	TRCell():New(oSection,'NUMPCSC'		,'cAlias01','Ordem Compra'				,,,,{||(cNUMPCSC)      			},,,,,,,,,.t.)

	TRCell():New(oSection,'FORNECE'		,'cAlias01','Fornecedor OC'				,,,,{||(cAlias01->FORNECE)      			},,,,,,,,,.t.)
	TRCell():New(oSection,'STATUS'		,'cAlias01','OC Aprovada'				,,,,{||(cAlias01->STATUS)       			},,,,,,,,,.t.)
	TRCell():New(oSection,'QUANTIDADE'	,'cAlias01','QT Pedido'					,,,,{||(Transform(cAlias01->QUANTIDADE,'@E 9,999,999.99'))			},,,,,,,,,.t.)
	TRCell():New(oSection,'ENTREGA'		,'cAlias01','Dt. Entrega'				,,,,{||(STOD(cAlias01->ENTREGA))			},,,,,,,,,.t.)
	TRCell():New(oSection,'cComprad'	,'cAlias01','Comprador OC'				,,,,{||cComprad				      			},,,,,,,,,.t.)
	TRCell():New(oSection,"nQtdPedAb"	,"cAlias11","Ordens total"				,,,,{||(Transform(nQtdPedab					,'@E 9,999,999.99'))	},,,,,,,,,.t.)
	TRCell():New(oSection,'QTDCDA'		,'cAlias02'	,'CDA'						,,,,{||(Transform(cAlias02->QTDCDA			,'@E 9,999,999.9999'))	},,,,,,,,,.t.)
	TRCell():New(oSection,'QTDCD07'     ,'cAlias03'	,'CD07'						,,,,{||(Transform(cAlias03->QTDCD07			,'@E 9,999,999.9999'))	},,,,,,,,,.t.)
	TRCell():New(oSection,'QTDCD15'		,'cAlias04'	,'CD15'						,,,,{||(Transform(cAlias04->QTDCD15			,'@E 9,999,999.9999'))	},,,,,,,,,.t.)
	TRCell():New(oSection,'QTDCD30'		,'cAlias05'	,'CD30'						,,,,{||(Transform(cAlias05->QTDCD30			,'@E 9,999,999.9999'))	},,,,,,,,,.t.)
	TRCell():New(oSection,'QTDCD60'		,'cAlias06'	,'CD60'						,,,,{||(Transform(cAlias06->QTDCD60			,'@E 9,999,999.9999'))	},,,,,,,,,.t.)
	TRCell():New(oSection,'QTDCD90'		,'cAlias07'	,'CD90'						,,,,{||(Transform(cAlias07->QTDCD90			,'@E 9,999,999.9999'))	},,,,,,,,,.t.)
	TRCell():New(oSection,'QTDCD120'	,'cAlias08'	,'CD120'					,,,,{||(Transform(cAlias08->QTDCD120		,'@E 9,999,999.9999'))	},,,,,,,,,.t.)
	TRCell():New(oSection,'QTDCD150'	,'cAlias09'	,'CD150'					,,,,{||(Transform(cAlias09->QTDCD150		,'@E 9,999,999.9999'))	},,,,,,,,,.t.)
	TRCell():New(oSection,'QTDCD180'	,'cAlias10'	,'CD180'					,,,,{||(Transform(cAlias10->QTDCD180		,'@E 9,999,999.9999'))	},,,,,,,,,.t.)

//	TRCell():New(oSection,'nSalAlmTot'	,''			,'Saldo Almox.'				,,,,{||(Transform(nSalAlmTot				,'@E 9,999,999.99'))	},,,,,,,,,.t.)
	TRCell():New(oSection,'nSalALM'		,''			,'Saldo. Almox'				,,,,{||(Transform(nSalALM					,'@E 9,999,999.99'))	},,,,,,,,,.t.)

	TRCell():New(oSection,'nSalFAR'		,''			,'Saldo Farmacias'			,,,,{||(Transform(nSalFAR					,'@E 9,999,999.99'))	},,,,,,,,,.t.)

	TRCell():New(oSection,'nSalARS'		,''			,'Estoque Arsenal'			,,,,{||(Transform(nSalARS					,'@E 9,999,999.99'))	},,,,,,,,,.t.)

	// 06/06/2018

//	TRCell():New(oSection,'nCobTot'		,''			,'Cobertura Total'			,,,,{|| (If(nCobTot == 0, 0,Transform(nCobTot,'@E 9,999,999.99')))	},,,,,,,,,.t.)

	TRCell():New(oSection,'nCobTot'		,''			,'Cobertura Total'			,,,,{|| If(nMaiorCons <= 0 , "Sem Consumo" ,Transform(nCobTot,'@E 9,999,999.9999'))	},,,,,,,,,.t.)

	TRCell():New(oSection,'nMaiorCons'	,''			,'Maximo'					,,,,{||(Transform(nMaiorCons,'@E 9,999,999.9999')) },,,,,,,,,.t.)
	TRCell():New(oSection,'cCalculo'	,''			,'Calculo'           		,,,,{||(cCalculo)							},,,,,,,,,.t.)
	TRCell():New(oSection,'nCobARS'		,''			,'Cobertura Arsenais'		,,,,{||(If(nCobARS == 0, 0,Transform(nCobARS,'@E 9,999,999.9999')))	},,,,,,,,,.t.)
	TRCell():New(oSection,'cGrupam'		,''			,'Grupamento'				,,,,{||cGrupam								},,,,,,,,,.t.)
	TRCell():New(oSection,'nEstSeg'		,''			,'Est. Segurança'			,,,,{||(Transform(nEstSeg					,'@E 9,999,999.99'))	},,,,,,,,,.t.)
	TRCell():New(oSection,'cAnLsCr'     ,''			,'Anl. Lista Critica'		,,,,{||(cAnLsCr)							},,,,,,,,,.t.)

	TRCell():New(oSection,'cAplMnlc'     ,''			,'Aplicar Manut.LC'		,,,,{||(cAplMnlc)							},,,,,,,,,.t.)


	TRCell():New(oSection,'cNivCritLC'  ,''			,'Nivel Critic. Manut. LC'	,,,,{||(cNivCritLC)							},,,,,,,,,.t.)
	TRCell():New(oSection,'nCD30xCD7'	,''			,'CD30xCD7'					,,,,{||(Transform(nCD30xCD7					,'@E 9,999,999.99'))	},,,,,,,,,.t.)
	TRCell():New(oSection,'nCD90xCD30'	,''			,'CD90xCD30'				,,,,{||(Transform(nCD90xCD30				,'@E 9,999,999.99'))	},,,,,,,,,.t.)


	TRCell():New(oSection,'nDiasAtraz'	,''			,'Dias Atraso'				,,,,{||(Transform(nDiasAtraz				,'@E 9,999,999'))		},,,,,,,,,.t.)
	TRCell():New(oSection,'nLeadTime'	,''			,'Lead Time'				,,,,{||(Transform(nLeadTime					,'@E 9,999,999.99'))	},,,,,,,,,.t.)
	TRCell():New(oSection,'cAnPreVenc'	,''			,'Analisar Previsao Vencida',,,,{||(cAnPrvVenc)							},,,,,,,,,.t.)
	TRCell():New(oSection,'cNivCritPV'	,''			,'Nivel de criticidade PV'	,,,,{||(cNivCritPV)							},,,,,,,,,.t.)

	TRCell():New(oSection,'cMatSubs'	,''			,'Materiais substitutos'	,,,,{||(cMatSubs)          					},,,,,,,,,.t.)
	TRCell():New(oSection,'cAnalista'	,'cAlias01'	,'Analista'			   		,,,,{||cAnalista		 					},,,,,,,,,.t.)
	TRCell():New(oSection,'nCusMed'		,''			,'Custo medio'				,,,,{||nCusMed								},,,,,,,,,.t.)
	TRCell():New(oSection,'cUM'			,'cAlias01'	,'Unidade compra'			,,,,{||cAlias01->UNIDMED   					},,,,,,,,,.t.)
	TRCell():New(oSection,'nVlFatMin'	,''			,'Faturamento Minimo'		,,,,{||(Transform(nVlFatMin					,'@E 9,999,999.99'))	},,,,,,,,,.t.)
	TRCell():New(oSection,'cIndNvServ'	,''			,'Indicador Nível Serv'		,,,,{||(cIndNvServ)							},,,,,,,,,.t.)

Return oReport

Static Function PrintReport(oReport)
	Local oSection 	:= oReport:Section(1)
	Local aArea		:= GetArea()
	Local aAreaSA2	:= SA2->(GetArea())
	Local cFSALM	:= SuperGetMv('FS_ALM') 
	Local cFSFAR	:= SuperGetMv('FS_FAR')
	Local cFSARS	:= SuperGetMv('FS_ARS')
	Local cFSARMEX	:= SuperGetMv('FS_ARMEXT')
	Local cQuery01	:= ''
  	Local cAlias01	:= ''
	Local cAlias02	:= GetNextAlias()
	Local cAlias03	:= GetNextAlias()
	Local cAlias04	:= GetNextAlias()
	Local cAlias05	:= GetNextAlias()
	Local cAlias06	:= GetNextAlias()
	Local cAlias07	:= GetNextAlias()
	Local cAlias08	:= GetNextAlias()
	Local cAlias09	:= GetNextAlias()
	Local cAlias10	:= GetNextAlias()
	Local cAlias11	:= GetNextAlias()
	Local cAlias12	:= GetNextAlias()
	Local cAlias13	:= GetNextAlias()
	Local cAlias14	:= GetNextAlias()
	Local cAlias15	:= GetNextAlias()
	Local cAlias16	:= GetNextAlias()
	Local cAlias17  := GetNextAlias()
	Local cNumPC	:= ''
	Local cResiduo	:= ''
	Local cEncerr	:= 'E'
	//Local 			:= '1' Thais Paiva - Compatibilização P27
	Local cBloqueado:= '2'
	Local aCompFil	:= {}
	Local aCalcEst	:= {}
	Local cRefer	:= ''
	Local nCount	:= 01
	oSection:Init()
	oReport:IncMeter()
	
	/*===========================================================================|
	|Define regras de comparação de filiais.                                     |
	|===========================================================================*/
	
	aCompFil := U_F0200702({{'ACV','SD3'},;
                            {'ACU','SD3'},; 		
                            {'SB1','SD3'},; 		
                            {'SBZ','SD3'},; 		
                            {'SB2','SD3'},; 		
                            {'SC7','SD3'},; 		
                            {'SC1','SD3'},;
                            {'ACV','ACU'},;
                            {'SA2','SD3'}},cEmpAnt, cFilAnt)
                            
	If !Empty(mv_par03)
		cQuery00 :=	"SELECT * FROM ( " + CRLF
	EndIf

	cQuery01 +=	"SELECT DISTINCT	SC7.C7_FILIAL	AS FILIAL		, " + CRLF // 01
	cQuery01 +=	"					SC7.C7_LOCAL	AS LOCAL		, " + CRLF // 02				
	cQuery01 +=	"					SC7.C7_NUM      AS NUMPCSC		, " + CRLF // 03
	cQuery01 +=	"					SC7.C7_ITEM		AS ITPCSC		, " + CRLF // 04
	cQuery01 +=	"					SC7.C7_EMISSAO	AS EMISSAO		, " + CRLF // 05 *
	cQuery01 +=	"					CASE WHEN SC7.C7_ACCPROC <> '1' AND SC7.C7_CONAPRO = 'B' AND SC7.C7_QUJE < SC7.C7_QUANT THEN 'BLOQUEADO' ELSE 'LIBERADO' END AS STATUS , " + CRLF
	cQuery01 +=	"					SC7.C7_QUANT	AS QUANTIDADE	, " + CRLF      // 07
	cQuery01 +=	"					SC7.C7_QUANT - SC7.C7_QUJE AS SALDO , " + CRLF  // 08
	cQuery01 +=	"					SC7.C7_DATPRF	AS ENTREGA		, " + CRLF      // 09
	cQuery01 +=	"					SC7.C7_USER		AS COMPRADOR	, " + CRLF      // 10
	cQuery01 +=	"					SA2.A2_NREDUZ  	AS FORNECE		, " + CRLF      // 11
	cQuery01 +=	"					SC7.C7_PRODUTO	AS PRODUTO		, " + CRLF      // 12 *
	cQuery01 +=	"					SB1.B1_DESC		AS DESCRICAO	, " + CRLF      // 13
	cQuery01 +=	"					SBZ.BZ_QE		AS UNIDMED		, " + CRLF      // 14
	cQuery01 +=	"					SBZ.BZ_XSUBIST ||'-'|| SBZ.BZ_XDESCSB	AS ALTERNAT		, " + CRLF //15
	cQuery01 +=	"					SBZ.BZ_EMAX		AS ESTQMAX		, " + CRLF // 16 
	cQuery01 +=	"					SBZ.BZ_XFREQAN	AS FREQ			, " + CRLF // 17
	cQuery01 +=	"					SBZ.BZ_XANALIS	AS ANALISTA		, " + CRLF // 18
	cQuery01 +=	"					SB1.B1_GRUPCOM	AS GRPCOMPR		, " + CRLF // 19
	cQuery01 +=	"					SB1.B1_GRUPO	AS GRUPO		, " + CRLF // 20
	cQuery01 +=	"					ACU.ACU_CODPAI	AS CODPAI		, " + CRLF // 21
	cQuery01 +=	"					ACV.ACV_CATEGO	AS CATEGORIA	, " + CRLF // 22   *
	cQuery01 +=	"					ACU.ACU_DESC	AS SEGMENTO		, " + CRLF // 23
	cQuery01 +=	"					SBZ.BZ_XDIASEG	AS ESTSEG		, " + CRLF // 24 
	cQuery01 +=	"					SBZ.BZ_PE     	AS PE 			, " + CRLF // 25
	cQuery01 += "					SBZ.BZ_XTEMPRO  AS TEMPROC      , "	+ CRLF // 26
	cQuery01 +=	"					SC7.R_E_C_N_O_	AS NUMPCSCORD     " + CRLF
	cQuery01 +=	"FROM " + RETSQLNAME('SC7') + " SC7	" + CRLF
	cQuery01 +=	"INNER JOIN " + RETSQLNAME('SB1') + " SB1 ON SB1.B1_FILIAL = '" + Space(Len(cFilAnt)) + "'" + CRLF
	cQuery01 +=	"								AND	  SB1.B1_COD     =  SC7.C7_PRODUTO " + CRLF
	cQuery01 +=	"INNER JOIN " + RETSQLNAME('ACV') + " ACV ON ACV.ACV_FILIAL = SC7.C7_FILIAL " + CRLF
	cQuery01 +=	"								AND	  ACV.ACV_CODPRO =  SC7.C7_PRODUTO " + CRLF
	cQuery01 +=	"INNER JOIN " + RETSQLNAME('ACU') + " ACU ON ACU.ACU_FILIAL = ACV.ACV_FILIAL " + CRLF
	cQuery01 +=	"								AND	  ACU.ACU_COD    =  ACV.ACV_CATEGO " + CRLF
	cQuery01 +=	"LEFT  JOIN " + RETSQLNAME('SBZ') + " SBZ ON SBZ.BZ_FILIAL  = SC7.C7_FILIAL " + CRLF
	cQuery01 +=	"								AND   SBZ.D_E_L_E_T_ = '' " + CRLF
	cQuery01 +=	"								AND	  SBZ.BZ_COD     =  SC7.C7_PRODUTO " + CRLF 
	cQuery01 +=	"LEFT  JOIN " + RETSQLNAME('SA2') + " SA2 ON SA2.A2_FILIAL  = '        ' " + CRLF
	cQuery01 +=	"								AND	  SA2.A2_COD		 =	SC7.C7_FORNECE " + CRLF
	cQuery01 +=	"								AND	  SA2.A2_LOJA	 =	SC7.C7_LOJA " + CRLF			  							 
	cQuery01 +=	"								AND	  SA2.D_E_L_E_T_ =  '' " + CRLF
	cQuery01 +=	"LEFT  JOIN " + RETSQLNAME('SY1') + " SY1 ON SY1.Y1_FILIAL	= SC7.C7_FILIAL " + CRLF
	cQuery01 +=	"								AND	  SY1.Y1_COD		= SC7.C7_COMPRA " + CRLF
	cQuery01 +=	"								AND	  SY1.D_E_L_E_T_ =  '' " + CRLF
	cQuery01 +=	"WHERE " + CRLF
	cQuery01 +=	"		SC7.D_E_L_E_T_	= 	'' " + CRLF

	If !Empty(mv_par03)
		cQuery01 +=	"    AND  SC7.C7_PRODUTO   =  '" + mv_par03  + "' " + CRLF
	EndIf

	If !Empty(mv_par04)
		cQuery01 +=	"      AND (ACV.ACV_CATEGO  =  '" + mv_par04  + "' OR  ACU.ACU_CODPAI = '" + mv_par04  + "') " + CRLF
	EndIf

	cQuery01 +=	"		AND	ACV.D_E_L_E_T_	=	'' " + CRLF                                                   	
	cQuery01 +=	"		AND	ACU.D_E_L_E_T_	=	'' " + CRLF
	cQuery01 +=	"		AND	ACU.ACU_CTRLP	=	'" + ALLTRIM(STR(mv_par05))  + "' " + CRLF
	cQuery01 +=	"		AND ACU.ACU_MSBLQL	=	'" + cBloqueado + "' " + CRLF
	cQuery01 +=	"		AND	SC7.C7_FILIAL   =	'" + cFilAnt  + "' " + CRLF
	cQuery01 +=	"		AND	SC7.C7_NUM		<>	'" + cNumPC   + "' " + CRLF
	cQuery01 +=	"		AND	SC7.C7_RESIDUO	=	'" + cResiduo + "' " + CRLF   
	cQuery01 +=	"		AND	SC7.C7_ENCER	<>	'" + cEncerr  + "' " + CRLF    
	cQuery01 +=	"		AND SC7.C7_QUJE    <  SC7.C7_QUANT " + CRLF     
	cQuery01 +=	"		AND SC7.D_E_L_E_T_	= 	'' " + CRLF
	cQuery01 +=	"		AND	SB1.D_E_L_E_T_  =	'' " + CRLF
	
	//cQuery01 +=	"UNION " + CRLF

	cQuery02 :=	"SELECT DISTINCT SC1.C1_FILIAL              AS FILIAL	, " + CRLF 
	cQuery02 +=	"                SC1.C1_LOCAL               AS LOCAL	, " + CRLF 
	cQuery02 +=	"                SC1.C1_NUM                 AS NUMPCSC	, " + CRLF 
	cQuery02 +=	"                SC1.C1_ITEM                AS ITPCSC	, " + CRLF 
	cQuery02 +=	"                SC1.C1_EMISSAO             AS EMISSAO	, " + CRLF 
	cQuery02 +=	"				 CASE WHEN SC1.C1_APROV = 'B' THEN 'BLOQUEADO' ELSE 'LIBERADO' END AS STATUS , " + CRLF
	cQuery02 +=	"                SC1.C1_QUANT               AS QUANTIDADE, " + CRLF 
	cQuery02 +=	"                SC1.C1_QUANT - SC1.C1_QUJE AS SALDO	, " + CRLF 
	cQuery02 +=	"                SC1.C1_DATPRF              AS ENTREGA	, " + CRLF 
	cQuery02 +=	"                SC1.C1_USER	            AS COMPRADOR, " + CRLF 
	cQuery02 +=	"                SA2.A2_NREDUZ              AS FORNECE	, " + CRLF 
	cQuery02 +=	"                SC1.C1_PRODUTO		        AS PRODUTO	, " + CRLF 
	cQuery02 +=	"                SB1.B1_DESC                AS DESCRICAO, " + CRLF 
	cQuery02 +=	"                SBZ.BZ_QE                  AS UNIDMED	, " + CRLF 
	cQuery02 +=	"                SBZ.BZ_XSUBIST ||'-'|| SBZ.BZ_XDESCSB  AS ALTERNAT	, " + CRLF
	cQuery02 +=	"                SBZ.BZ_EMAX                AS ESTQMAX	, " + CRLF 
	cQuery02 +=	"                SBZ.BZ_XFREQAN             AS FREQ		, " + CRLF 
	cQuery02 +=	"                SBZ.BZ_XANALIS	            AS ANALISTA	, " + CRLF 
	cQuery02 +=	"                SB1.B1_GRUPCOM             AS GRPCOMPR	, " + CRLF 
	cQuery02 +=	"                SB1.B1_GRUPO               AS GRUPO	, " + CRLF 
	cQuery02 +=	"                ACU.ACU_CODPAI             AS CODPAI	, " + CRLF 
	cQuery02 +=	"                ACV.ACV_CATEGO             AS CATEGORIA, " + CRLF 
	cQuery02 +=	"				 ACU.ACU_DESC				AS SEGMENTO	, " + CRLF
	cQuery02 +=	"                SBZ.BZ_XDIASEG             AS ESTSEG	, " + CRLF 
	cQuery02 +=	"                SBZ.BZ_PE                  AS PE		, " + CRLF 
	cQuery02 += "				 SBZ.BZ_XTEMPRO             AS TEMPROC  , "	+ CRLF
	cQuery02 +=	"				 SC1.R_E_C_N_O_				AS NUMPCSCORD     " + CRLF
	cQuery02 +=	"FROM " + RETSQLNAME('SC1') + " SC1	" + CRLF
	cQuery02 +=	"INNER JOIN " + RETSQLNAME('SB1') + " SB1 ON SB1.B1_FILIAL = '" + Space(Len(cFilAnt)) + "'" + CRLF
	cQuery02 +=	"								AND		SB1.B1_COD     = SC1.C1_PRODUTO " + CRLF
	cQuery02 +=	"INNER JOIN " + RETSQLNAME('ACV') + " ACV ON ACV.ACV_FILIAL = SC1.C1_FILIAL " + CRLF
	cQuery02 +=	"								AND		ACV.ACV_CODPRO = SC1.C1_PRODUTO " + CRLF
	cQuery02 +=	"INNER JOIN " + RETSQLNAME('ACU') + " ACU ON ACU.ACU_FILIAL = ACV.ACV_FILIAL " + CRLF
	cQuery02 +=	"								AND		ACU.ACU_COD    =  ACV.ACV_CATEGO " + CRLF
	cQuery02 +=	"								AND 	ACU.ACU_CTRLP  =  '" + ALLTRIM(STR(mv_par05)) + "' " + CRLF
	cQuery02 +=	"								AND 	ACU.ACU_MSBLQL =  '" + cBloqueado + "' " + CRLF
	cQuery02 +=	"LEFT  JOIN " + RETSQLNAME('SBZ') + " SBZ ON SBZ.BZ_FILIAL  = SC1.C1_FILIAL " + CRLF
	cQuery02 +=	"								AND 	SBZ.D_E_L_E_T_ = '' " + CRLF
	cQuery02 +=	"								AND		SBZ.BZ_COD     = SC1.C1_PRODUTO " + CRLF 
	cQuery02 +=	"LEFT  JOIN " + RETSQLNAME('SC1') + " SC1 ON SC1.C1_FILIAL  = SC1.C1_FILIAL " + CRLF
	cQuery02 +=	"								AND		SC1.C1_LOCAL = SC1.C1_LOCAL " + CRLF       
	cQuery02 +=	"								AND		SC1.C1_LOCAL   =  SC1.C1_LOCAL " + CRLF    
	cQuery02 +=	"								AND		SC1.D_E_L_E_T_ =  '' " + CRLF
	cQuery02 +=	"LEFT  JOIN " + RETSQLNAME('SA2') + " SA2 ON SA2.A2_FILIAL  = '        ' " + CRLF
	cQuery02 +=	"								AND		SA2.A2_COD		 =	SC1.C1_FORNECE " + CRLF
	cQuery02 +=	"								AND		SA2.A2_LOJA	 =	SC1.C1_LOJA " + CRLF			  							 
	cQuery02 +=	"								AND		SA2.D_E_L_E_T_ =  '' " + CRLF
	cQuery02 +=	"LEFT  JOIN " + RETSQLNAME('SY1') + " SY1 ON SY1.Y1_FILIAL	= SC1.C1_FILIAL " + CRLF
	cQuery02 +=	"								AND		SY1.Y1_COD		= SC1.C1_CODCOMP " + CRLF
	cQuery02 +=	"								AND		SY1.D_E_L_E_T_ =  '' " + CRLF
	cQuery02 +=	"WHERE " + CRLF
	cQuery02 +=	"		ACV.D_E_L_E_T_ = '' " + CRLF

	If !Empty(mv_par03)
		cQuery02 +=	"   AND SC1.C1_PRODUTO      =  '" + mv_par03  + "' " + CRLF
	EndIf
	
	If !Empty(mv_par04)
		cQuery02 +=	"      AND (ACV.ACV_CATEGO  =  '" + mv_par04  + "' OR  ACU.ACU_CODPAI = '" + mv_par04  + "') " + CRLF
	EndIf
	cQuery02 +=	"		AND	ACV.D_E_L_E_T_ = '' " + CRLF                                                   	
	cQuery02 +=	"		AND	ACU.D_E_L_E_T_ = '' " + CRLF
	cQuery02 +=	"		AND	ACU.ACU_CTRLP  = '" + ALLTRIM(STR(mv_par05))  + "' " + CRLF
	cQuery02 +=	"		AND	SC1.C1_FILIAL  = '" + cFilAnt  + "' " + CRLF
	cQuery02 +=	"		AND	SC1.D_E_L_E_T_ = '' " + CRLF
//	cQuery02 +=	"		AND SC1.C1_PEDIDO  = ' ' " + CRLF
	cQuery02 +=	"		AND SC1.C1_QUJE    <  SC1.C1_QUANT " + CRLF
	cQuery02 +=	"		AND	SC1.C1_RESIDUO	=	'" + cResiduo + "' " + CRLF
	
	cQuery02 +=	"		AND SC1.C1_XITMED NOT LIKE ('%GCT%') " + CRLF	
	cQuery02 +=	"		AND	SB1.D_E_L_E_T_ = '' " + CRLF

********************************************************************************

	cQuery03 :=	"SELECT DISTINCT	ACV2.ACV_FILIAL	AS FILIAL , " + CRLF // 01
	cQuery03 +=	"					' '	AS LOCAL		, " + CRLF // 02				
	cQuery03 +=	"					' '	AS NUMPCSC		, " + CRLF // 03
	cQuery03 +=	"					' '	AS ITPCSC		, " + CRLF // 04
	cQuery03 +=	"					' '	AS EMISSAO		, " + CRLF // 05 *
	cQuery03 +=	"					' ' AS STATUS , " + CRLF // 06
	cQuery03 +=	"					  0	AS QUANTIDADE	, " + CRLF      // 07
	cQuery03 +=	"					  0 AS SALDO , " + CRLF  // 08
	cQuery03 +=	"					' '	AS ENTREGA		, " + CRLF      // 09
	cQuery03 +=	"					' '	AS COMPRADOR	, " + CRLF      // 10
	cQuery03 +=	"					' ' AS FORNECE		, " + CRLF      // 11
	cQuery03 +=	"					ACV2.ACV_CODPRO	AS PRODUTO		, " + CRLF      // 12 *
	cQuery03 +=	"					SB1.B1_DESC		AS DESCRICAO	, " + CRLF      // 13
	cQuery03 +=	"					SBZ.BZ_QE		AS UNIDMED		, " + CRLF      // 14
	cQuery03 +=	"					SBZ.BZ_XSUBIST ||'-'|| SBZ.BZ_XDESCSB	AS ALTERNAT		, " + CRLF //15
	cQuery03 +=	"					SBZ.BZ_EMAX		AS ESTQMAX		, " + CRLF // 16 
	cQuery03 +=	"					SBZ.BZ_XFREQAN	AS FREQ			, " + CRLF // 17
	cQuery03 +=	"					SBZ.BZ_XANALIS	AS ANALISTA		, " + CRLF // 18
	cQuery03 +=	"					SB1.B1_GRUPCOM	AS GRPCOMPR		, " + CRLF // 19
	cQuery03 +=	"					SB1.B1_GRUPO	AS GRUPO		, " + CRLF // 20
	cQuery03 +=	"					ACU.ACU_CODPAI	AS CODPAI		, " + CRLF // 21
	cQuery03 +=	"					ACV2.ACV_CATEGO	AS CATEGORIA	, " + CRLF // 22   *
	cQuery03 +=	"					ACU.ACU_DESC	AS SEGMENTO		, " + CRLF // 23
	cQuery03 +=	"					SBZ.BZ_XDIASEG	AS ESTSEG		, " + CRLF // 24 
	cQuery03 +=	"					SBZ.BZ_PE     	AS PE 			, " + CRLF // 25
	cQuery03 += "					SBZ.BZ_XTEMPRO  AS TEMPROC      , "	+ CRLF // 26
	cQuery03 +=	"					0	AS NUMPCSCORD     " + CRLF	
	cQuery03 +=	"FROM " + RETSQLNAME('ACV') + " ACV2	" + CRLF
	cQuery03 +=	"INNER JOIN " + RETSQLNAME('SB1') + " SB1 ON SB1.B1_FILIAL = '" + Space(Len(cFilAnt)) + "'" + CRLF
	cQuery03 +=	"								AND	  SB1.B1_COD     =  ACV2.ACV_CODPRO " + CRLF
	cQuery03 +=	"INNER JOIN " + RETSQLNAME('ACU') + " ACU ON ACU.ACU_FILIAL = ACV2.ACV_FILIAL " + CRLF
	cQuery03 +=	"								AND	  ACU.ACU_COD    =  ACV2.ACV_CATEGO " + CRLF
	cQuery03 +=	"LEFT  JOIN " + RETSQLNAME('SBZ') + " SBZ ON SBZ.BZ_FILIAL  = ACV2.ACV_FILIAL " + CRLF
	cQuery03 +=	"								AND   SBZ.D_E_L_E_T_ = '' " + CRLF
	cQuery03 +=	"								AND	  SBZ.BZ_COD     =  ACV2.ACV_CODPRO " + CRLF 
	cQuery03 +=	"WHERE " + CRLF
	cQuery03 +=	"		ACV2.D_E_L_E_T_	= 	'' " + CRLF

	If !Empty(mv_par03)
		cQuery03 +=	"    AND  ACV2.ACV_CODPRO   =  '" + mv_par03  + "' " + CRLF
	EndIf

	If !Empty(mv_par04)
		cQuery03 +=	"      AND (ACV2.ACV_CATEGO  =  '" + mv_par04  + "' OR  ACU.ACU_CODPAI = '" + mv_par04  + "') " + CRLF
	EndIf

	cQuery03 +=	"		AND	ACV2.D_E_L_E_T_	=	'' " + CRLF                                                   	
	cQuery03 +=	"		AND	ACU.D_E_L_E_T_	=	'' " + CRLF
	cQuery03 +=	"		AND	ACU.ACU_CTRLP	=	'" + ALLTRIM(STR(mv_par05))  + "' " + CRLF
	cQuery03 +=	"		AND ACU.ACU_MSBLQL	=	'" + cBloqueado + "' " + CRLF
	cQuery03 +=	"		AND	ACV2.ACV_FILIAL   =	'" + cFilAnt  + "' " + CRLF
	cQuery03 +=	"		AND	SB1.D_E_L_E_T_  =	'' " + CRLF

	cQuery03 += "       AND NOT EXISTS ( "+cQuery01+" AND ACV.ACV_CODPRO = ACV2.ACV_CODPRO ) " + CRLF
	cQuery03 += "       AND NOT EXISTS ( "+cQuery02+" AND ACV.ACV_CODPRO = ACV2.ACV_CODPRO ) " + CRLF


********************************************************************************

	If !Empty(mv_par03)
		cQuery := cQuery00 + cQuery01 + ' UNION ' + cQuery02 +  ' UNION ' + cQuery03 
	Else
	    cQuery := cQuery01 + ' UNION ' + cQuery02  +  ' UNION ' + cQuery03
	Endif

	If !Empty(mv_par03)
		cQuery +=	" ORDER BY 1 ) "+ CRLF
		IF MV_PAR01 <> 3
			cQuery +=	"WHERE    ROWNUM = 1 "+ CRLF
		ENDIF
	Else
		cQuery +=	" ORDER BY 22, 12, 05, 26 "
	EndIf 

	cQuery := ChangeQuery(cQuery)

	If lDebug
       EEcView(cQuery)
	Endif	

	If Select('cAlias01') > 0
		cAlias01->(dBCloseArea())
	EndIf
	
	dbUseArea( .T., 'TOPCONN', TcGenQry(,,cQuery), 'cAlias01', .F., .T. )
	dBSelectArea('cAlias01')
	
	cAlias01->(dbGoTop())
	
	If Empty(mv_par03)
		cRefer := cAlias01->CATEGORIA + cAlias01->PRODUTO 
	EndIf

	oReport:SetMeter(cAlias01->(LastRec()))
	
	While !cAlias01->(Eof())

//		IF cAlias01->PRODUTO = '931'
//			Alert( cAlias01->PRODUTO)
//		ENDIF

//		If oReport:Cancel()
//			Exit
//		EndIf

		oReport:IncMeter()
		IncProc("Imprimindo Produto "+Alltrim(cAlias01->PRODUTO))

		IF MV_PAR01 <> 3
			If Empty(mv_par03)
				If cRefer <> cAlias01->CATEGORIA + cAlias01->PRODUTO
					cRefer	:=	cAlias01->CATEGORIA + cAlias01->PRODUTO
					nCount	:=	01
				Else
					If nCount > 01
						cAlias01->(dBSkip())
						Loop
					EndIf
				EndIf
			EndIf	
 		ENDIF
		
		nCount := nCount + 01

		nLenFil		:=	Len(AllTrim(cAlias01->FILIAL))
		cComprad	:=  FullNamec(cAlias01->COMPRADOR)
		cAnalista	:=	AllTrim(cAlias01->ANALISTA)
		
		/*==============================================================|
		| MATERIAL SUBSTITUTO.                                          |
		|==============================================================*/
		If !Empty(cAlias01->ALTERNAT)
//			cMatSubs := cAlias01->ALTERNAT + ' - ' + Posicione('SB1',01,xFilial('SB1') + cAlias01->ALTERNAT,'B1_DESC')
			cMatSubs := cAlias01->ALTERNAT 
		EndIf
		/*==============================================================|
		| SALDO DO ARMAZEM DO TIPO ALMOXARIFADO.                        |
		|==============================================================*/
		If Select('cAlias13') > 0
			cAlias13->(dBCloseArea())
		EndIf
		BeginSql Alias 'cAlias13'
		SELECT 	SB2.B2_FILIAL 	FILSB2	,
				SB2.B2_COD		CODSB2	,
				SB2.B2_LOCAL	LOCSB2
		FROM	%table:SB2% SB2 INNER JOIN %table:NNR% NNR ON 		NNR.NNR_FILIAL	=	SB2.B2_FILIAL
																AND	NNR.NNR_CODIGO	=	SB2.B2_LOCAL
		WHERE			SB2.%notDel%
				AND		NNR.%notDel%
				AND		SB2.B2_FILIAL	=	%exp:cFilAnt%
				AND		SB2.B2_COD		=	%exp:cAlias01->PRODUTO%
				AND		NNR.NNR_XTPLOC	=	%exp:'1'%
		EndSql
		If !cAlias13->(Eof())
			While !cAlias13->(Eof())
				SB2->(DbSetOrder(01))
				If SB2->(DbSeek(cAlias13->FILSB2 + cAlias13->CODSB2 + cAlias13->LOCSB2))
					aCalcEst := CalcEst(cAlias13->CODSB2,cAlias13->LOCSB2,mv_par02+1)
//					aCalcEst := CalcEst(cAlias13->CODSB2,cAlias13->LOCSB2,mv_par02)

					If !Empty(aCalcEst)
						nSalALM	+= aCalcEst[01]
						//nCusMed	+= aCalcEst[02]
						ASIZE(aCalcEst,0)
					EndIf
				EndIf
				cAlias13->(dBSkip())
			EndDo
		EndIf
		
		If Select('cAlias17') > 0
			cAlias17->(dBCloseArea())
		EndIf

		/*==============================================================|
		| CUSTO MEDIO DIARIO.                                           |
		|==============================================================*/
		BeginSql Alias 'cAlias17'
		SELECT SUM (D1_TOTAL) / SUM(D1_QUANT) AS CustMed
		FROM %table:SD1%
		WHERE %notDel%
			AND D1_FILIAL = %exp:cAlias01->FILIAL%
			AND D1_COD = %exp:cAlias01->PRODUTO%
		EndSQL
				
		nCusMed := cAlias17->CustMed
		
		/*==============================================================|
		| SALDO DO ARMAZEM DO TIPO FARMACIA.                            |
		|==============================================================*/
		BeginSql Alias 'cAlias14'
		SELECT 	SB2.B2_FILIAL 	FILSB2	,
				SB2.B2_COD		CODSB2	,
				SB2.B2_LOCAL	LOCSB2
		FROM	%table:SB2% SB2 INNER JOIN %table:NNR% NNR ON 		NNR.NNR_FILIAL	=	SB2.B2_FILIAL
																AND	NNR.NNR_CODIGO	=	SB2.B2_LOCAL
		WHERE			SB2.%notDel%
				AND		NNR.%notDel%
				AND		SB2.B2_FILIAL	=	%exp:cFilAnt%
				AND		SB2.B2_COD		=	%exp:cAlias01->PRODUTO%
				AND		NNR.NNR_XTPLOC	=	%exp:'3'%
		EndSql
		If !cAlias14->(Eof())
			While !cAlias14->(Eof())
				SB2->(DbSetOrder(01))
				If SB2->(DbSeek(cAlias14->FILSB2 + cAlias14->CODSB2 + cAlias14->LOCSB2))
					aCalcEst := CalcEst(cAlias14->CODSB2,cAlias14->LOCSB2,mv_par02+1)
					If !Empty(aCalcEst)
						nSalFAR	+= aCalcEst[01]
						ASIZE(aCalcEst,0)
					EndIf
				EndIf
				cAlias14->(dBSkip())
			EndDo
		EndIf
//		If SB2->( DbSeek(cAlias01->FILIAL + cAlias01->PRODUTO + cFSFAR) )
//			nSalFAR	:= CalcEst(cAlias01->PRODUTO,cFSFAR,mv_par02)[01]
//		EndIf
		/*==============================================================|
		| SALDO DO ARMAZEM DO TIPO ARSENAL.                             |
		|==============================================================*/
		BeginSql Alias 'cAlias15'
		SELECT 	SB2.B2_FILIAL 	FILSB2	,
				SB2.B2_COD		CODSB2	,
				SB2.B2_LOCAL	LOCSB2
		FROM	%table:SB2% SB2 INNER JOIN %table:NNR% NNR ON 		NNR.NNR_FILIAL	=	SB2.B2_FILIAL
																AND	NNR.NNR_CODIGO	=	SB2.B2_LOCAL
		WHERE			SB2.%notDel%
				AND		NNR.%notDel%
				AND		SB2.B2_FILIAL	=	%exp:cFilAnt%
				AND		SB2.B2_COD		=	%exp:cAlias01->PRODUTO%
				AND		NNR.NNR_XTPLOC	=	%exp:'2'%
		EndSql
		If !cAlias15->(Eof())
			While !cAlias15->(Eof())
				SB2->(DbSetOrder(01))
				If SB2->(DbSeek(cAlias15->FILSB2 + cAlias15->CODSB2 + cAlias15->LOCSB2))
					aCalcEst := CalcEst(cAlias15->CODSB2,cAlias15->LOCSB2,mv_par02+1)
					If !Empty(aCalcEst)
						nSalARS	+= aCalcEst[01]
						ASIZE(aCalcEst,0)
					EndIf
				EndIf
				cAlias15->(dBSkip())
			EndDo
		EndIf
//		If SB2->( DbSeek(cAlias01->FILIAL + cAlias01->PRODUTO + cFSARS) )
//			nSalARS	:= CalcEst(cAlias01->PRODUTO,cFSARS,mv_par02)[01]
//		EndIf
		/*==============================================================|
		| SALDO DO ARMAZEM EXTERNO.                                     |
		|==============================================================*/
		BeginSql Alias 'cAlias16'
		SELECT 	SB2.B2_FILIAL 	FILSB2	,
				SB2.B2_COD		CODSB2	,
				SB2.B2_LOCAL	LOCSB2
		FROM	%table:SB2% SB2 INNER JOIN %table:NNR% NNR ON 		NNR.NNR_FILIAL	=	SB2.B2_FILIAL
																AND	NNR.NNR_CODIGO	=	SB2.B2_LOCAL
		WHERE			SB2.%notDel%
				AND		NNR.%notDel%
				AND		SB2.B2_FILIAL	=	%exp:cFilAnt%
				AND		SB2.B2_COD		=	%exp:cAlias01->PRODUTO%
				AND		NNR.NNR_XTPLOC	=	%exp:'4'%
		EndSql
		If !cAlias16->(Eof())
			SB2->(DbSetOrder(01))
			While !cAlias16->(Eof())
				If SB2->(DbSeek(cAlias16->FILSB2 + cAlias16->CODSB2 + cAlias16->LOCSB2))
					aCalcEst := CalcEst(cAlias16->CODSB2,cAlias16->LOCSB2,mv_par02+1)
					If !Empty(aCalcEst)
						nSArmExt += aCalcEst[01]
						ASIZE(aCalcEst,0)
					EndIf
				EndIf
				cAlias16->(dBSkip())
			EndDo
		EndIf
//		If SB2->( DbSeek(cAlias01->FILIAL + cAlias01->PRODUTO + cFSARMEX) )
//			nSArmExt := CalcEst(cAlias01->PRODUTO,cFSARMEX,mv_par02)[01]
//		EndIf
		/*==============================================================|
		| SALDO TOTAL DE ARMAZEM.                                       |
		|==============================================================*/
		nSalAlmTot := nSalALM + nSalFAR + nSalARS + nSArmExt 

		/*==============================================================|
		| CDA  - CONSUMO DO DIA ANTERIOR.                               |
		|==============================================================*/
		If Select('cAlias02') > 0
			cAlias02->(dBCloseArea())
		EndIf
		BeginSql Alias 'cAlias02'
		SELECT SUM(CASE WHEN SUBSTR(D3_CF,01,01) = 'D' THEN (SD3.D3_QUANT * (-1)) ELSE SD3.D3_QUANT END)  AS QTDCDA
		FROM	%table:SD3% SD3 INNER JOIN %table:SF5% SF5 ON SF5.F5_CODIGO = SD3.D3_TM    
		WHERE			SD3.%notDel%
				AND		SF5.%notDel%
				AND		SD3.D3_FILIAL	=	%exp:cFilAnt%
				AND		SD3.D3_COD		=	%exp:cAlias01->PRODUTO%
				AND		SD3.D3_EMISSAO	=	%exp:DTOS(dDtA)%
				AND		SF5.F5_XCONSUM	=	%exp:cConsumo%
				AND		SD3.D3_ESTORNO  = ' ' 
		EndSql
		
		If !cAlias02->(Eof())
			nQtdCDA	:=	cAlias02->QTDCDA
			AAdd(aMaiorCons, cAlias02->QTDCDA)
		EndIf	

		/*==============================================================|
		| PCSC - Mais antigo.                                           |
		|==============================================================*/

		cNumPcSC := MenorPCSC()

		/*==============================================================|
		| CD07 - MÉDIA DE CONSUMO DIÁRIO DOS ÚLTIMOS 7 DIAS.            |
		|==============================================================*/

		If Select('cAlias03') > 0
			cAlias03->(dBCloseArea())
		EndIf
		BeginSql Alias 'cAlias03'
		SELECT SUM(CASE WHEN SUBSTR(D3_CF,01,01) = 'D' THEN (SD3.D3_QUANT * (-1)) ELSE SD3.D3_QUANT END) / 7  AS QTDCD07
		FROM	%table:SD3% SD3 INNER JOIN %table:SF5% SF5 ON	SF5.F5_CODIGO = SD3.D3_TM    
		WHERE			SD3.%notDel%
				AND		SF5.%notDel%
				AND		SD3.D3_FILIAL	=	%exp:cFilAnt%
				AND		SD3.D3_COD		=	%exp:cAlias01->PRODUTO%
				AND		SD3.D3_EMISSAO >=	%exp:DTOS(dDt7)% 
				AND		SD3.D3_EMISSAO <=	%exp:DTOS(dDTBASE)% 
				AND		SF5.F5_XCONSUM	=	%exp:cConsumo%
				AND		SD3.D3_ESTORNO  = ' '
		EndSql
		If !cAlias03->(Eof())
			nQtdCD07	:=	cAlias03->QTDCD07
			AAdd(aMaiorCons , cAlias03->QTDCD07)
			AAdd(aMaxO6Q6,cAlias03->QTDCD07)
			AAdd(aMaxO6V6,cAlias03->QTDCD07)
		EndIf	


		/*==============================================================|
		| CD15 - MÉDIA DE CONSUMO DIÁRIO DOS ÚLTIMOS 15 DIAS.           |
		|==============================================================*/
		If Select('cAlias04') > 0
			cAlias04->(dBCloseArea())
		EndIf
		BeginSql Alias 'cAlias04'
		SELECT SUM(CASE WHEN SUBSTR(D3_CF,01,01) = 'D' THEN (SD3.D3_QUANT * (-1)) ELSE SD3.D3_QUANT END) / 15 AS QTDCD15
		FROM	%table:SD3% SD3 INNER JOIN %table:SF5% SF5 ON 	SF5.F5_CODIGO = SD3.D3_TM    
		WHERE			SD3.%notDel%
				AND		SF5.%notDel%
				AND		SD3.D3_FILIAL	=	%exp:cFilAnt%
				AND		SD3.D3_COD		=	%exp:cAlias01->PRODUTO%
				AND		SD3.D3_EMISSAO >=	%exp:DTOS(dDt15)% 
				AND		SD3.D3_EMISSAO <=	%exp:DTOS(dDTBASE)% 
				AND		SF5.F5_XCONSUM	=	%exp:cConsumo%
				AND		SD3.D3_ESTORNO  = ' '
		EndSql
		If !cAlias04->(Eof())
			nQtdCD15	:=	cAlias04->QTDCD15
			AAdd(aMaiorCons, cAlias04->QTDCD15)
			AAdd(aMaxO6Q6,cAlias04->QTDCD15)
			AAdd(aMaxO6V6,cAlias04->QTDCD15)
		EndIf	
		/*==============================================================|
		| CD30 - MÉDIA DE CONSUMO DIÁRIO DOS ÚLTIMOS 30 DIAS.           |
		|==============================================================*/
		If Select('cAlias05') > 0
			cAlias05->(dBCloseArea())
		EndIf
		BeginSql Alias 'cAlias05'
		SELECT SUM(CASE WHEN SUBSTR(D3_CF,01,01) = 'D' THEN (SD3.D3_QUANT * (-1)) ELSE SD3.D3_QUANT END) / 30 AS QTDCD30
		FROM	%table:SD3% SD3 INNER JOIN %table:SF5% SF5 ON 	SF5.F5_CODIGO = SD3.D3_TM    
		WHERE			SD3.%notDel%
				AND		SF5.%notDel%
				AND		SD3.D3_FILIAL	=	%exp:cFilAnt%
				AND		SD3.D3_COD		=	%exp:cAlias01->PRODUTO%
				AND		SD3.D3_EMISSAO >=	%exp:DTOS(dDt30)% 
				AND		SD3.D3_EMISSAO <=	%exp:DTOS(dDTBASE)% 
				AND		SF5.F5_XCONSUM	=	%exp:cConsumo%
				AND		SD3.D3_ESTORNO  = ' '
		EndSql
		If !cAlias05->(Eof())
			nQtdCD30	:=	cAlias05->QTDCD30
			AAdd(aMaiorCons, cAlias05->QTDCD30)
			AAdd(aMaxO6Q6,cAlias05->QTDCD30)
			AAdd(aMaxO6V6,cAlias05->QTDCD30)
		EndIf
		/*==============================================================|
		| MAIOR VALOR APRESENTADO NO INTERVALO CD7 / CD30               |
		|==============================================================*/
		If !Empty(aMaxO6Q6)
			ASORT(aMaxO6Q6,,, { |x, y| x > y })
			nMaxO6Q6	:= aMaxO6Q6[01]
			ASIZE(aMaxO6Q6,0)
			aMaxO6Q6 := {}
		EndIf
		/*==============================================================|
		| CD60 - MÉDIA DE CONSUMO DIÁRIO DOS ÚLTIMOS 60 DIAS.           |
		|==============================================================*/
		If Select('cAlias06') > 0
			cAlias06->(dBCloseArea())
		EndIf
		BeginSql Alias 'cAlias06'
		SELECT SUM(CASE WHEN SUBSTR(D3_CF,01,01) = 'D' THEN (SD3.D3_QUANT * (-1)) ELSE SD3.D3_QUANT END) / 60 AS QTDCD60
		FROM	%table:SD3% SD3 INNER JOIN %table:SF5% SF5 ON 	SF5.F5_CODIGO = SD3.D3_TM    
		WHERE			SD3.%notDel%
				AND		SF5.%notDel%
				AND		SD3.D3_FILIAL	 =	%exp:cFilAnt%
				AND		SD3.D3_COD		 =	%exp:cAlias01->PRODUTO%
				AND		SD3.D3_EMISSAO >=	%exp:DTOS(dDt60)% 
				AND		SD3.D3_EMISSAO <=	%exp:DTOS(dDTBASE)% 
				AND		SF5.F5_XCONSUM	=	%exp:cConsumo%
				AND		SD3.D3_ESTORNO  = ' '
		EndSql
		If !cAlias06->(Eof())
			nQtdCD60	:=	cAlias06->QTDCD60
			AAdd(aMaiorCons,cAlias06->QTDCD60)
			AAdd(aMaxO6V6  ,cAlias06->QTDCD60)
		EndIf
		/*==============================================================|
		| CD90 - MÉDIA DE CONSUMO DIÁRIO DOS ÚLTIMOS 90 DIAS.           |
		|==============================================================*/
		If Select('cAlias07') > 0
			cAlias07->(dBCloseArea())
		EndIf
		BeginSql Alias 'cAlias07'
		SELECT SUM(CASE WHEN SUBSTR(D3_CF,01,01) = 'D' THEN (SD3.D3_QUANT * (-1)) ELSE SD3.D3_QUANT END) / 90 AS QTDCD90
		FROM	%table:SD3% SD3 INNER JOIN %table:SF5% SF5 ON 	SF5.F5_CODIGO = SD3.D3_TM    
		WHERE			SD3.%notDel%
				AND		SF5.%notDel%
				AND		SD3.D3_FILIAL	 =	%exp:cFilAnt%
				AND		SD3.D3_COD		 =	%exp:cAlias01->PRODUTO%
				AND		SD3.D3_EMISSAO >=	%exp:DTOS(dDt90)% 
				AND		SD3.D3_EMISSAO <=	%exp:DTOS(dDTBASE)% 
				AND		SF5.F5_XCONSUM	=	%exp:cConsumo%
				AND		SD3.D3_ESTORNO  = ' '				
		EndSql
		If !cAlias07->(Eof())
			nQtdCD90	:=	cAlias07->QTDCD90
			AAdd(aMaiorCons,cAlias07->QTDCD90)
			AAdd(aMaxO6V6  ,cAlias07->QTDCD90)
		EndIf
		/*==============================================================|
		| CD120 - MÉDIA DE CONSUMO DIÁRIO DOS ÚLTIMOS 120 DIAS.         |
		|==============================================================*/
		If Select('cAlias08') > 0
			cAlias08->(dBCloseArea())
		EndIf
		BeginSql Alias 'cAlias08'
		SELECT SUM(CASE WHEN SUBSTR(D3_CF,01,01) = 'D' THEN (SD3.D3_QUANT * (-1)) ELSE SD3.D3_QUANT END) / 120 AS QTDCD120
		FROM	%table:SD3% SD3 INNER JOIN %table:SF5% SF5 ON 	SF5.F5_CODIGO = SD3.D3_TM    
		WHERE			SD3.%notDel%
				AND		SF5.%notDel%
				AND		SD3.D3_FILIAL	 =	%exp:cFilAnt%
				AND		SD3.D3_COD		 =	%exp:cAlias01->PRODUTO%
				AND		SD3.D3_EMISSAO >=	%exp:DTOS(dDt120)% 
				AND		SD3.D3_EMISSAO <=	%exp:DTOS(dDTBASE)%
				AND		SF5.F5_XCONSUM	=	%exp:cConsumo%
				AND		SD3.D3_ESTORNO  = ' '				
		EndSql 
		If !cAlias08->(Eof())
			nQtdCD120	:=	cAlias08->QTDCD120
			AAdd(aMaiorCons,cAlias08->QTDCD120)
			AAdd(aMaxO6V6  ,cAlias08->QTDCD120)
		EndIf
		/*==============================================================|
		| CD150 - MÉDIA DE CONSUMO DIÁRIO DOS ÚLTIMOS 150 DIAS.         |
		|==============================================================*/
		If Select('cAlias09') > 0
			cAlias09->(dBCloseArea())
		EndIf
		BeginSql Alias 'cAlias09'
		SELECT SUM(CASE WHEN SUBSTR(D3_CF,01,01) = 'D' THEN (SD3.D3_QUANT * (-1)) ELSE SD3.D3_QUANT END) / 150 AS QTDCD150
		FROM	%table:SD3% SD3 INNER JOIN %table:SF5% SF5 ON 	SF5.F5_CODIGO = SD3.D3_TM    
		WHERE			SD3.%notDel%
				AND		SF5.%notDel%
				AND		SD3.D3_FILIAL	 =	%exp:cFilAnt%
				AND		SD3.D3_COD		 =	%exp:cAlias01->PRODUTO%
				AND		SD3.D3_EMISSAO >=	%exp:DTOS(dDt150)% 
				AND		SD3.D3_EMISSAO <=	%exp:DTOS(dDTBASE)% 
				AND		SF5.F5_XCONSUM	=	%exp:cConsumo%
				AND		SD3.D3_ESTORNO  = ' '				
		EndSql
		If !cAlias09->(Eof())
			nQtdCD150	:=	cAlias09->QTDCD150
			AAdd(aMaiorCons,cAlias09->QTDCD150)
			AAdd(aMaxO6V6  ,cAlias09->QTDCD150)
		EndIf
		/*==============================================================|
		| CD180 - MÉDIA DE CONSUMO DIÁRIO DOS ÚLTIMOS 180 DIAS.         |
		|==============================================================*/
		If Select('cAlias10') > 0
			cAlias10->(dBCloseArea()) 
		EndIf
		BeginSql Alias 'cAlias10'
		SELECT SUM(CASE WHEN SUBSTR(D3_CF,01,01) = 'D' THEN (SD3.D3_QUANT * (-1)) ELSE SD3.D3_QUANT END) / 180 AS  QTDCD180
		FROM	%table:SD3% SD3 INNER JOIN %table:SF5% SF5 ON 	SF5.F5_CODIGO = SD3.D3_TM    
		WHERE			SD3.%notDel%
				AND		SF5.%notDel%
				AND		SD3.D3_FILIAL	 =	%exp:cFilAnt%
				AND		SD3.D3_COD		 =	%exp:cAlias01->PRODUTO%
				AND		SD3.D3_EMISSAO >=	%exp:DTOS(dDt180)% 
				AND		SD3.D3_EMISSAO <=	%exp:DTOS(dDTBASE)% 
				AND		SF5.F5_XCONSUM	=	%exp:cConsumo%
				AND		SD3.D3_ESTORNO  = ' '				
		EndSql
		If !cAlias10->(Eof())
			nQtdCD180	:=	cAlias10->QTDCD180
			AAdd(aMaiorCons,cAlias10->QTDCD180)
			AAdd(aMaxO6V6  ,cAlias10->QTDCD180)
		EndIf
		/*==============================================================|
		| MAIOR VALOR APRESENTADO NO INTERVALO CD7 / CD180              |
		|==============================================================*/
		If !Empty(aMaxO6V6)
			ASORT(aMaxO6V6,,, { |x, y| x > y })
			nMaxO6V6	:= aMaxO6V6[01]
			ASIZE(aMaxO6V6,0)
			aMaxO6V6 := {}
		EndIf
		/*==============================================================|
		| Maior consumo 3M - MAIOR VALOR APRESENTADO NOS CD'S  APURADOS.|
		|==============================================================*/
		If !Empty(aMaiorCons)
			ASORT(aMaiorCons,,, { |x, y| x > y })
			nMaiorCons	:= aMaiorCons[01]
			ASIZE(aMaiorCons,0)
			aMaiorCons := {}
		EndIf
		/*==============================================================|
		| COBERTURA TOTAL.                                              |
		|==============================================================*/

		nMax0730 := 0
		aMax07_30:= {}

		AAdd(aMax07_30  ,nQtdCD07)
		AAdd(aMax07_30  ,nQtdCD15)
		AAdd(aMax07_30  ,nQtdCD30)				

		If !Empty(aMax07_30)
			ASORT(aMax07_30,,, { |x, y| x > y })
			nMax07_30	:= aMax07_30[01]
			ASIZE(aMax07_30,0)
			aMax07_30 := {}
		EndIf

		If nMaiorCons <= 0

			nCobTot := 0
			
		Else
			If nSalALM <= 0
				nCobTot := 0
			Else
/*
				If nMaxO6V6 > 0
					nCobTot := nSalALM / nMaxO6V6
				Else
					nCobTot := nSalALM / nMaiorCons
				EndIf
*/
				If nMax07_30 > 0
					nCobTot := nSalALM / nMax07_30
				Else
					nCobTot := nSalALM / nMaiorCons
				EndIf

			EndIf
		EndIf
		
		/*==============================================================|
		| TOTAL PED. COMPRA / SOLIC. DE COMPRA                          |
		|==============================================================*/
		If Select('cAlias11') > 0
			cAlias11->(dBCloseArea())
		EndIf
		BeginSql Alias 'cAlias11'
		SELECT SUM(C7_QUANT - C7_QUJE) QTDPEDAB
		FROM	%table:SC7% SC7
		WHERE			SC7.%notDel%
				AND		SUBSTR(SC7.C7_FILIAL,01,%exp:nLenFil%) = %exp:cAlias01->FILIAL%	
				AND		SC7.C7_RESIDUO	=	' '
				AND		SC7.C7_ENCER	<>	'E'
				AND		SC7.C7_PRODUTO	=	%exp:cAlias01->PRODUTO%
		EndSql
		If !cAlias11->(Eof())
			nQtdPedab	:= cAlias11->QTDPEDAB
		EndIf

		If Select('cAlias12') > 0
			cAlias12->(dBCloseArea())
		EndIf
		BeginSql Alias 'cAlias12'
		SELECT SUM(C1_QUANT - C1_QUJE) QTDPEDAB
		FROM	%table:SC1% SC1
		WHERE			SC1.%notDel%
				AND		SUBSTR(SC1.C1_FILIAL,01,%exp:nLenFil%) = %exp:cAlias01->FILIAL%	
				AND		SC1.C1_RESIDUO	=	' '
				AND		SC1.C1_PRODUTO	=	%exp:cAlias01->PRODUTO%
				AND     SC1.C1_XNUMMED  =   ' '
		EndSql
		If !cAlias12->(Eof())
			nQtdPedab	:= nQtdPedab + cAlias12->QTDPEDAB
		EndIf
		
		/*==============================================================|
		| GRUPAMENTO.                                                   |
		|==============================================================*/
		
		cGrupam := Posicione('ACU',01,cAlias01->FILIAL + cAlias01->CODPAI,'ACU_DESC')  
		
		/*==============================================================|
		| LEAD TIME, FREQUENCIA E ESTOQUE DE SEGURANÇA.                 |
		|==============================================================*/
		nEstSeg		:=	cAlias01->ESTSEG
		nLeadTime	:=	cAlias01->PE + cAlias01->TEMPROC
		cFreq		:=	cAlias01->FREQ

		/*==============================================================|
		| ANALISAR LISTA CRÍTICA.                                       |
		|==============================================================*/
		If	nCobTot	<=	7
			cAnlCrit := 'Sim'
		Else
			If	nCobTot	<	nEstSeg
				cAnlCrit := 'Sim'
			Else
				cAnlCrit := 'Não'
			EndIf
		EndIf

		/*==============================================================|
		| Aplicar Manutencao Lista Critica.                             |
		|==============================================================*/

		If	nCobTot	< nEstSeg .OR. nCobTot <= 7  
			cAplMnLC := 'Sim'
		Else
			cAplMnLC := 'Não'
		EndIf

		/*==============================================================|
		| ANALISAR PREVISÃO VENCIDA.                                    |
		|==============================================================*/
		If	Empty(STOD(cAlias01->ENTREGA))
			cAnPrvVenc := 'Não'
		Else
			If STOD(cAlias01->ENTREGA) < mv_par02
				cAnPrvVenc	:= 'Sim'
			Else
				cAnPrvVenc := 'Não'
			EndIf
		EndIf
		
		/*==============================================================|
		| ANALISE DE PARÂMETROS                                         |
		|==============================================================*/

		If mv_par01 == 1  

			If nCobTot >= 7 .OR. nMaiorCons <= 0 .OR. nMaiorCons <= 0
				fLImpaVar()
				cAlias01->(dBSkip())
				Loop
			EndIf

		ElseIf mv_par01 == 2 
		
//			If nCobTot >= nEstSeg .OR. nMaiorCons <= 0
			IF cAplMnLC = 'Não' .OR. nMaiorCons <= 0 // nCobTot	<	nEstSeg .OR. nCobTot <= 7 // cAplMnLC := 'Sim'
				fLImpaVar()
				cAlias01->(dBSkip())
				Loop
			EndIf

		ElseIf mv_par01 == 3
//			cAnPrvVenc	:= 'Sim'
//			If !(STOD(cAlias01->ENTREGA) > mv_par02 .and. cAlias01->SALDO == 0)
			If cAnPrvVenc = 'Não' //STOD(cAlias01->ENTREGA) < mv_par02 .AND. nQtdPedAb > 0 //.and. cAlias01->SALDO > 0 			
				fLImpaVar()
				cAlias01->(dBSkip())
				Loop
			EndIf

		EndIf


		/*==============================================================|
		| COBERTURAS - ALMOX, FARMACIA.                                 |
		|==============================================================*/
		If nQtdCD07 + nQtdCD30 == 0
			nCobAlm	:= 0
			nCobFAR	:= 0
//			nCobARS	:= 0
			nCobUni	:= 0
		Else
			IF nQtdCD07 == 0
				nCobAlm := nSalALM / nQtdCD30
				nCobFAR := nSalFAR / nQtdCD30
//				nCobARS := nSalARS / nQtdCD30
				nCobUni := (nSalALM + nSalARS) / nQtdCD30
			Else
				nCobAlm := nSalALM / nQtdCD07
				nCobFAR := nSalFAR / nQtdCD07
//				nCobARS := nSalARS / nQtdCD07
				nCobUni := (nSalALM + nSalARS) / nQtdCD07
			EndIf
		EndIf

		/*==============================================================|
		| COBERTURAS ARSENAL			                                 |
		|==============================================================*/

//		nMax0730 := 0
//		aMax07_30:= {}

		/*
		If nMaiorCons <= 0
			nCobARS := 0
		Else
			If nSalALM <= 0
				nCobARS := 0
			Else
				If nMaxO6V6 > 0
					nCobARS := nSalARS / nMaxO6V6
				Else
					nCobARS := nSalARS / nMaiorCons
				EndIf
			EndIf
		EndIf		
		*/

		If nMaiorCons <= 0 
			nCobARS := 0
		Else
			If nSalARS <= 0
				nCobARS := 0
			Else
				If nMax07_30 > 0
					nCobARS := nSalARS / nMax07_30
				Else
					nCobARS := nSalARS / nMaiorCons
				EndIf
			EndIf
		EndIf		

		
		/*==============================================================|
		| NIVEL DE CRITICIDADE MANUT. LC.                               |
		|==============================================================*/
		If	cAnLsCr == 'Não'
			cNivCritLC := 'Sem criticidade'
		Else
			If	 nCobTot	<=	nLeadTime
				cNivCritLC := 'Alta Criticidade'
			ElseIf nCobTot	<=	nLeadTime + 7
				cNivCritLC := 'Média Criticidade'
			Else
				cNivCritLC := 'Baixa Criticidade'
			EndIf
		EndIf
		/*==============================================================|
		| NIVEL DE CRITICIDADE MANUT. PV.                               |
		|==============================================================*/
		If nCobTot <= 7
			cNivCritPV := 'Alta'
		ElseIf nCobTot < nLeadTime .and. nCobTot < nEstSeg
			cNivCritPV := 'Alta'
		ElseIf nCobTot > nLeadTime .and. nCobTot >= nEstSeg
			cNivCritPV := 'Baixa'
		Else			
			cNivCritPV := 'Média'
		EndIf
		/*==============================================================|
		| ANALISAR LISTA CRITICA.                                       |
		|==============================================================*/
		If nCobTot <= 7 .or. nCobTot < nEstSeg
			cAnLsCr := 'Sim'
		Else
			cAnLsCr := 'Não'
		EndIf
		/*==============================================================|
		| CD30xCD7 e CD90xCD30.                                         |
		|==============================================================*/
		nCD30xCD7	:=	(nQtdCD07 - nQtdCD30) / nQtdCD30
		nCD90xCD30	:=	(nQtdCD30 - nQtdCD90) / nQtdCD90
		/*==============================================================|
		| DIAS DE ATRASO.                                               |
		|==============================================================*/
		If	cAlias01->SALDO > 0
			If mv_par02 - STOD(cAlias01->ENTREGA) > 0
				nDiasAtraz :=	mv_par02 - STOD(cAlias01->ENTREGA)
			Else
				nDiasAtraz := 0
			EndIf
		Else
			nDiasAtraz := 0
		EndIf
		/*==============================================================|
		| ANALISAR PREVISÃO VENCIDA.                                    |
		|==============================================================*/
		If	Empty(STOD(cAlias01->ENTREGA))
			cAnPrvVenc := 'Não'
		Else
			If STOD(cAlias01->ENTREGA) < mv_par02
				cAnPrvVenc	:= 'Sim'
			Else
				cAnPrvVenc := 'Não'
			EndIf
		EndIf

		/*==============================================================|
		| CÁLCULO.                                                      |
		|==============================================================*/
		If nMaiorCons == nQtdCDA
			cCalculo := 'CDA'
		ElseIf nMaiorCons == nQtdCD07
			cCalculo := 'CD07'
		ElseIf nMaiorCons == nQtdCD15
			cCalculo := 'CD15'
		ElseIf nMaiorCons == nQtdCD30
			cCalculo := 'CD30'
		ElseIf nMaiorCons == nQtdCD60
			cCalculo := 'CD60'
		ElseIf nMaiorCons == nQtdCD90
			cCalculo := 'CD90'
		ElseIf nMaiorCons == nQtdCD120
			cCalculo := 'CD120'
		ElseIf nMaiorCons == nQtdCD150
			cCalculo := 'CD150'
		ElseIf nMaiorCons == nQtdCD180
			cCalculo := 'CD180'
		Else
			cCalculo := 'Sem movimento'
		EndIf
	
		/*==============================================================|
		| Faturamento Minimo.                                           |
		|==============================================================*/
		nVlFatMin := VerProdCtr(cAlias01->PRODUTO)
		
		/*==============================================================|
		| Indicador Nível Serviço                                       |
		|==============================================================*/
		If cGrupam == "ALTERNATIVO / SUBSTITUTOS     "
			cIndNvServ := "ALTERNATIVO / SUBSTITUTOS"
		ElseIf nCobTot = 0
			cIndNvServ := "LOS=0"
		ElseIf nCobTot < 1
			cIndNvServ := "LOS<1D"
		ElseIf nCobTot < 3
			cIndNvServ := "LOS<3D"
		ElseIf nCobTot < 7
			cIndNvServ := "LOS<7D"
		Else
			cIndNvServ := "LOS>7D"
		EndIf
		
		oSection:PrintLine()
		cAlias01->(dBSkip())
		fLImpaVar()
	
	EndDo
	

	oSection:Finish()
	
	RestArea(aArea)
	RestArea(aAreaSA2)
		
Return

Static Function fLImpaVar()

ASIZE(aMaiorCons,0)
ASIZE(aMax07_30,0)
ASIZE(aMaxO6Q6,0)
ASIZE(aMaxO6V6,0)
cAnalista 	:= ''
cAnlCrit 	:= ''
cAnLsCr 	:= ''
cAnPrvVenc	:= ''
cCalculo 	:= ''
cFreq 		:= ''
cGrupam 	:= ''
cMatSubs 	:= ''
cNivCritLC	:= ''
nCD30xCD7	:= 0
nCD90xCD30	:= 0
nCobAlm	:= 0
nCobARS	:= 0
nCobFAR	:= 0
nMax07_30 := 0
nCobTot 	:= 0
nCobUni	:= 0
nCusMed 	:= 0
nDiasAtraz	:= 0
nEstSeg 	:= 0
nLeadTime 	:= 0
nLenFil 	:= 0
nMaiorCons	:= 0
nMaxO6Q6 	:= 0
nMaxO6V6 	:= 0
nQtdCD07 	:= 0
nQtdCD120 	:= 0
nQtdCD15 	:= 0
nQtdCD150 	:= 0
nQtdCD180 	:= 0
nQtdCD30 	:= 0
nQtdCD60 	:= 0
nQtdCD90 	:= 0
nQtdCDA 	:= 0
nQtdPedab 	:= 0
nSalALM 	:= 0
nSalAlmTot	:= 0
nSalARS 	:= 0
nSalFAR 	:= 0
nSArmExt 	:= 0
nTamFil 	:= 0

If Select('cAlias02') > 0
	cAlias02->(dBCloseArea())
EndIf
If Select('cAlias03') > 0
	cAlias03->(dBCloseArea())
EndIf
If Select('cAlias04') > 0
	cAlias04->(dBCloseArea())
EndIf
If Select('cAlias05') > 0
	cAlias05->(dBCloseArea())
EndIf
If Select('cAlias06') > 0
	cAlias06->(dBCloseArea())
EndIf
If Select('cAlias07') > 0
	cAlias07->(dBCloseArea())
EndIf
If Select('cAlias08') > 0
	cAlias08->(dBCloseArea())
EndIf
If Select('cAlias09') > 0
	cAlias09->(dBCloseArea())
EndIf
If Select('cAlias10') > 0
	cAlias10->(dBCloseArea())
EndIf
If Select('cAlias11') > 0
	cAlias11->(dBCloseArea())
EndIf
If Select('cAlias12') > 0
	cAlias12->(dBCloseArea())
EndIf
If Select('cAlias13') > 0
	cAlias13->(dBCloseArea())
EndIf
If Select('cAlias14') > 0
	cAlias14->(dBCloseArea())
EndIf
If Select('cAlias15') > 0
	cAlias15->(dBCloseArea())
EndIf
If Select('cAlias16') > 0
	cAlias16->(dBCloseArea())
EndIf
If Select('cAlias17') > 0
	cAlias17->(dBCloseArea())
EndIf

If Select('cAliasXX') > 0
	cAliasXX->(dBCloseArea())
EndIf



Return 

Static Function VerProdCtr(cProduto)
	Local nRet 		:= 0
	Local cQuery	:= ""

	cQuery +=" SELECT MAX(CN9_XFATMI) FATMIN FROM "+RetSqlName("AIB")+" AIB " 

	cQuery +=" INNER JOIN " + RetSqlName('CNA') + " CNA	ON	CNA.CNA_FILIAL = AIB.AIB_FILIAL "
	cQuery +=" AND CNA.CNA_XTABPC = AIB.AIB_CODTAB" 
	
	cQuery +=" INNER JOIN " + RetSqlName('CN9') + " CN9	ON	CN9.CN9_FILIAL = AIB.AIB_FILIAL "
	cQuery += " AND CNA.CNA_CONTRA = CN9.CN9_NUMERO "
	
	cQuery +=" WHERE AIB_FILIAL = '" + xFilial("AIB") + "' "	
	cQuery +=" AND AIB_CODPRO = '" + cProduto + "' "	
	cQuery +=" AND CN9.CN9_SITUAC = '05' " //-- 01=Cancelado;02=Elaboracao;03=Emitido;04=Aprovacao;05=Vigente;06=Paralisa.;07=Sol. Finalizacao;08=Finali.;09=Revisao;10=Revisado

	cQuery +=" AND CN9.D_E_L_E_T_ = '' "	
	cQuery +=" AND AIB.D_E_L_E_T_ = '' "	
	cQuery +=" AND CNA.D_E_L_E_T_ = '' "	

	If Select('QRYTAB') > 0
		DbSelectArea('QRYTAB')
		DbCloseArea()
	Endif
	
	cQuery := ChangeQuery(cQuery)
	
	TCQUERY cQuery NEW ALIAS 'QRYTAB'	
	
	If QRYTAB->(!EOF()) .And. QRYTAB->FATMIN > 0
		nRet := QRYTAB->FATMIN
	EndIf
	
Return nRet

Static Function MenorPCSC()

Local cQuery01   := ""
Local cNumPC	:= ''
Local cResiduo	:= ''
Local cEncerr	:= 'E'
//Local 			:= '1'
Local cBloqueado:= '2'
Local cRefer	:= ''

                            
	cQuery01 :=	"SELECT * FROM ( " + CRLF
	cQuery01 +=	"SELECT DISTINCT	SC7.C7_FILIAL	AS FILIAL		, " + CRLF // 01
	cQuery01 +=	"					SC7.C7_LOCAL	AS LOCAL		, " + CRLF // 02				
	cQuery01 +=	"					SC7.C7_NUM      AS NUMPCSC		, " + CRLF // 03
	cQuery01 +=	"					SC7.C7_ITEM		AS ITPCSC		, " + CRLF // 04
	cQuery01 +=	"					SC7.C7_EMISSAO	AS EMISSAO		, " + CRLF // 05 *
	cQuery01 +=	"					CASE WHEN SC7.C7_ACCPROC <> '1' AND SC7.C7_CONAPRO = 'B' AND SC7.C7_QUJE < SC7.C7_QUANT THEN 'BLOQUEADO' ELSE 'LIBERADO' END AS STATUS , " + CRLF
	cQuery01 +=	"					SC7.C7_QUANT	AS QUANTIDADE	, " + CRLF      // 07
	cQuery01 +=	"					SC7.C7_QUANT - SC7.C7_QUJE AS SALDO , " + CRLF  // 08
	cQuery01 +=	"					SC7.C7_DATPRF	AS ENTREGA		, " + CRLF      // 09
	cQuery01 +=	"					SC7.C7_USER		AS COMPRADOR	, " + CRLF      // 10
	cQuery01 +=	"					SA2.A2_NREDUZ  	AS FORNECE		, " + CRLF      // 11
	cQuery01 +=	"					SC7.C7_PRODUTO	AS PRODUTO		, " + CRLF      // 12 *
	cQuery01 +=	"					SB1.B1_DESC		AS DESCRICAO	, " + CRLF      // 13
	cQuery01 +=	"					SBZ.BZ_QE		AS UNIDMED		, " + CRLF      // 14
//	cQuery01 +=	"					SB1.B1_ALTER	AS ALTERNAT		, " + CRLF

	cQuery01 +=	"					SBZ.BZ_XSUBIST ||'-'|| SBZ.BZ_XDESCSB	AS ALTERNAT		, " + CRLF //15

	cQuery01 +=	"					SBZ.BZ_EMAX		AS ESTQMAX		, " + CRLF // 16 
	cQuery01 +=	"					SBZ.BZ_XFREQAN	AS FREQ			, " + CRLF // 17
	cQuery01 +=	"					SBZ.BZ_XANALIS	AS ANALISTA		, " + CRLF // 18
	cQuery01 +=	"					SB1.B1_GRUPCOM	AS GRPCOMPR		, " + CRLF // 19
	cQuery01 +=	"					SB1.B1_GRUPO	AS GRUPO		, " + CRLF // 20
	cQuery01 +=	"					ACU.ACU_CODPAI	AS CODPAI		, " + CRLF // 21
	cQuery01 +=	"					ACV.ACV_CATEGO	AS CATEGORIA	, " + CRLF // 22   *
	cQuery01 +=	"					ACU.ACU_DESC	AS SEGMENTO		, " + CRLF // 23
	cQuery01 +=	"					SBZ.BZ_XDIASEG	AS ESTSEG		, " + CRLF // 24 
	cQuery01 +=	"					SBZ.BZ_PE     	AS PE 			, " + CRLF // 25
	cQuery01 += "					SBZ.BZ_XTEMPRO  AS TEMPROC      , "	+ CRLF // 26
	cQuery01 +=	"					SC7.R_E_C_N_O_	AS NUMPCSCORD     " + CRLF
	cQuery01 +=	"FROM " + RETSQLNAME('SC7') + " SC7	" + CRLF
	cQuery01 +=	"INNER JOIN " + RETSQLNAME('SB1') + " SB1 ON SB1.B1_FILIAL = '" + Space(Len(cFilAnt)) + "'" + CRLF
	cQuery01 +=	"								AND	  SB1.B1_COD     =  SC7.C7_PRODUTO " + CRLF
	cQuery01 +=	"INNER JOIN " + RETSQLNAME('ACV') + " ACV ON ACV.ACV_FILIAL = SC7.C7_FILIAL " + CRLF
	cQuery01 +=	"								AND	  ACV.ACV_CODPRO =  SC7.C7_PRODUTO " + CRLF
	cQuery01 +=	"INNER JOIN " + RETSQLNAME('ACU') + " ACU ON ACU.ACU_FILIAL = ACV.ACV_FILIAL " + CRLF
	cQuery01 +=	"								AND	  ACU.ACU_COD    =  ACV.ACV_CATEGO " + CRLF
	cQuery01 +=	"LEFT  JOIN " + RETSQLNAME('SBZ') + " SBZ ON SBZ.BZ_FILIAL  = SC7.C7_FILIAL " + CRLF
	cQuery01 +=	"								AND   SBZ.D_E_L_E_T_ = '' " + CRLF
	cQuery01 +=	"								AND	  SBZ.BZ_COD     =  SC7.C7_PRODUTO " + CRLF 
	cQuery01 +=	"LEFT  JOIN " + RETSQLNAME('SA2') + " SA2 ON SA2.A2_FILIAL  = '        ' " + CRLF
	cQuery01 +=	"								AND	  SA2.A2_COD		 =	SC7.C7_FORNECE " + CRLF
	cQuery01 +=	"								AND	  SA2.A2_LOJA	 =	SC7.C7_LOJA " + CRLF			  							 
	cQuery01 +=	"								AND	  SA2.D_E_L_E_T_ =  '' " + CRLF
	cQuery01 +=	"LEFT  JOIN " + RETSQLNAME('SY1') + " SY1 ON SY1.Y1_FILIAL	= SC7.C7_FILIAL " + CRLF
	cQuery01 +=	"								AND	  SY1.Y1_COD		= SC7.C7_COMPRA " + CRLF
	cQuery01 +=	"								AND	  SY1.D_E_L_E_T_ =  '' " + CRLF
	cQuery01 +=	"WHERE " + CRLF
	cQuery01 +=	"		SC7.D_E_L_E_T_	= 	'' " + CRLF

	cQuery01 +=	"    AND  SC7.C7_PRODUTO   =  '" + cAlias01->PRODUTO  + "' " + CRLF

	If !Empty(mv_par04)
		cQuery01 +=	"      AND (ACV.ACV_CATEGO  =  '" + mv_par04  + "' OR  ACU.ACU_CODPAI = '" + mv_par04  + "') " + CRLF
	EndIf

	cQuery01 +=	"		AND	ACV.D_E_L_E_T_	=	'' " + CRLF                                                   	
	cQuery01 +=	"		AND	ACU.D_E_L_E_T_	=	'' " + CRLF
	cQuery01 +=	"		AND	ACU.ACU_CTRLP	=	'" + ALLTRIM(STR(mv_par05))  + "' " + CRLF
	cQuery01 +=	"		AND ACU.ACU_MSBLQL	=	'" + cBloqueado + "' " + CRLF
	cQuery01 +=	"		AND	SC7.C7_FILIAL   =	'" + cFilAnt  + "' " + CRLF
	cQuery01 +=	"		AND	SC7.C7_NUM		<>	'" + cNumPC   + "' " + CRLF
	cQuery01 +=	"		AND	SC7.C7_RESIDUO	=	'" + cResiduo + "' " + CRLF   
	cQuery01 +=	"		AND	SC7.C7_ENCER	<>	'" + cEncerr  + "' " + CRLF    
	cQuery01 +=	"		AND SC7.C7_QUJE    <  SC7.C7_QUANT " + CRLF     
	cQuery01 +=	"		AND SC7.D_E_L_E_T_	= 	'' " + CRLF
	cQuery01 +=	"		AND	SB1.D_E_L_E_T_  =	'' " + CRLF
	
	cQuery01 +=	"UNION " + CRLF

	cQuery01 +=	"SELECT DISTINCT SC1.C1_FILIAL              AS FILIAL	, " + CRLF 
	cQuery01 +=	"                SC1.C1_LOCAL               AS LOCAL	, " + CRLF 
	cQuery01 +=	"                SC1.C1_NUM                 AS NUMPCSC	, " + CRLF 
	cQuery01 +=	"                SC1.C1_ITEM                AS ITPCSC	, " + CRLF 
	cQuery01 +=	"                SC1.C1_EMISSAO             AS EMISSAO	, " + CRLF 
	cQuery01 +=	"				 CASE WHEN SC1.C1_APROV = 'B' THEN 'BLOQUEADO' ELSE 'LIBERADO' END AS STATUS , " + CRLF
	cQuery01 +=	"                SC1.C1_QUANT               AS QUANTIDADE, " + CRLF 
	cQuery01 +=	"                SC1.C1_QUANT - SC1.C1_QUJE AS SALDO	, " + CRLF 
	cQuery01 +=	"                SC1.C1_DATPRF              AS ENTREGA	, " + CRLF 
	cQuery01 +=	"                SC1.C1_USER	            AS COMPRADOR, " + CRLF 
	cQuery01 +=	"                SA2.A2_NREDUZ              AS FORNECE	, " + CRLF 
	cQuery01 +=	"                SC1.C1_PRODUTO		        AS PRODUTO	, " + CRLF 
	cQuery01 +=	"                SB1.B1_DESC                AS DESCRICAO, " + CRLF 
	cQuery01 +=	"                SBZ.BZ_QE                  AS UNIDMED	, " + CRLF 

//	cQuery01 +=	"                SB1.B1_ALTER               AS ALTERNAT	, " + CRLF
	cQuery01 +=	"                SBZ.BZ_XSUBIST ||'-'|| SBZ.BZ_XDESCSB  AS ALTERNAT	, " + CRLF
	 
	cQuery01 +=	"                SBZ.BZ_EMAX                AS ESTQMAX	, " + CRLF 
	cQuery01 +=	"                SBZ.BZ_XFREQAN             AS FREQ		, " + CRLF 
	cQuery01 +=	"                SBZ.BZ_XANALIS	            AS ANALISTA	, " + CRLF 
	cQuery01 +=	"                SB1.B1_GRUPCOM             AS GRPCOMPR	, " + CRLF 
	cQuery01 +=	"                SB1.B1_GRUPO               AS GRUPO	, " + CRLF 
	cQuery01 +=	"                ACU.ACU_CODPAI             AS CODPAI	, " + CRLF 
	cQuery01 +=	"                ACV.ACV_CATEGO             AS CATEGORIA, " + CRLF 
	cQuery01 +=	"				 ACU.ACU_DESC				AS SEGMENTO	, " + CRLF
	cQuery01 +=	"                SBZ.BZ_XDIASEG             AS ESTSEG	, " + CRLF 
	cQuery01 +=	"                SBZ.BZ_PE                  AS PE		, " + CRLF 
	cQuery01 += "				 SBZ.BZ_XTEMPRO             AS TEMPROC  , "	+ CRLF
	cQuery01 +=	"				 SC1.R_E_C_N_O_				AS NUMPCSCORD     " + CRLF
	cQuery01 +=	"FROM " + RETSQLNAME('SC1') + " SC1	" + CRLF
	cQuery01 +=	"INNER JOIN " + RETSQLNAME('SB1') + " SB1 ON SB1.B1_FILIAL = '" + Space(Len(cFilAnt)) + "'" + CRLF
	cQuery01 +=	"								AND		SB1.B1_COD     = SC1.C1_PRODUTO " + CRLF
	cQuery01 +=	"INNER JOIN " + RETSQLNAME('ACV') + " ACV ON ACV.ACV_FILIAL = SC1.C1_FILIAL " + CRLF
	cQuery01 +=	"								AND		ACV.ACV_CODPRO = SC1.C1_PRODUTO " + CRLF
	cQuery01 +=	"INNER JOIN " + RETSQLNAME('ACU') + " ACU ON ACU.ACU_FILIAL = ACV.ACV_FILIAL " + CRLF
	cQuery01 +=	"								AND		ACU.ACU_COD    =  ACV.ACV_CATEGO " + CRLF
	cQuery01 +=	"								AND 	ACU.ACU_CTRLP  =  '" + ALLTRIM(STR(mv_par05)) + "' " + CRLF
	cQuery01 +=	"								AND 	ACU.ACU_MSBLQL =  '" + cBloqueado + "' " + CRLF
	cQuery01 +=	"LEFT  JOIN " + RETSQLNAME('SBZ') + " SBZ ON SBZ.BZ_FILIAL  = SC1.C1_FILIAL " + CRLF
	cQuery01 +=	"								AND 	SBZ.D_E_L_E_T_ = '' " + CRLF
	cQuery01 +=	"								AND		SBZ.BZ_COD     = SC1.C1_LOCAL " + CRLF 
	cQuery01 +=	"LEFT  JOIN " + RETSQLNAME('SC1') + " SC1 ON SC1.C1_FILIAL  = SC1.C1_FILIAL " + CRLF
	cQuery01 +=	"								AND		SC1.C1_LOCAL = SC1.C1_LOCAL " + CRLF       
	cQuery01 +=	"								AND		SC1.C1_LOCAL   =  SC1.C1_LOCAL " + CRLF    
	cQuery01 +=	"								AND		SC1.D_E_L_E_T_ =  '' " + CRLF
	cQuery01 +=	"LEFT  JOIN " + RETSQLNAME('SA2') + " SA2 ON SA2.A2_FILIAL  = '        ' " + CRLF
	cQuery01 +=	"								AND		SA2.A2_COD		 =	SC1.C1_FORNECE " + CRLF
	cQuery01 +=	"								AND		SA2.A2_LOJA	 =	SC1.C1_LOJA " + CRLF			  							 
	cQuery01 +=	"								AND		SA2.D_E_L_E_T_ =  '' " + CRLF
	cQuery01 +=	"LEFT  JOIN " + RETSQLNAME('SY1') + " SY1 ON SY1.Y1_FILIAL	= SC1.C1_FILIAL " + CRLF
	cQuery01 +=	"								AND		SY1.Y1_COD		= SC1.C1_CODCOMP " + CRLF
	cQuery01 +=	"								AND		SY1.D_E_L_E_T_ =  '' " + CRLF
	cQuery01 +=	"WHERE " + CRLF
	// MMT
	cQuery01 +=	"		ACV.D_E_L_E_T_ = '' " + CRLF

	cQuery01 +=	"   AND SC1.C1_PRODUTO      =  '" + cAlias01->PRODUTO  + "' " + CRLF
	
	If !Empty(mv_par04)
		cQuery01 +=	"      AND (ACV.ACV_CATEGO  =  '" + mv_par04  + "' OR  ACU.ACU_CODPAI = '" + mv_par04  + "') " + CRLF
	EndIf
	cQuery01 +=	"		AND	ACV.D_E_L_E_T_ = '' " + CRLF                                                   	
	cQuery01 +=	"		AND	ACU.D_E_L_E_T_ = '' " + CRLF
	cQuery01 +=	"		AND	ACU.ACU_CTRLP  = '" + ALLTRIM(STR(mv_par05))  + "' " + CRLF
	cQuery01 +=	"		AND	SC1.C1_FILIAL  = '" + cFilAnt  + "' " + CRLF
	cQuery01 +=	"		AND	SC1.D_E_L_E_T_ = '' " + CRLF
//	cQuery01 +=	"		AND SC1.C1_PEDIDO  = ' ' " + CRLF
	cQuery01 +=	"		AND SC1.C1_XITMED NOT LIKE ('%GCT%') " + CRLF	
	cQuery01 +=	"		AND	SB1.D_E_L_E_T_ = '' " + CRLF

		cQuery01 +=	" ORDER BY 1 ) "+ CRLF

		IF MV_PAR01 <> 3
			cQuery01 +=	"WHERE    ROWNUM = 1 "+ CRLF
		ENDIF

	cQuery01 := ChangeQuery(cQuery01)
	
	If Select('cAliasXX') > 0
		cAliasXX->(dBCloseArea())
	EndIf
	
	dbUseArea( .T., 'TOPCONN', TcGenQry(,,cQuery01), 'cAliasXX', .F., .T. )
	dBSelectArea('cAliasXX')
	
	cAliasXX->(dbGoTop())
	
	cPcsc := cAliasXX->NUMPCSC

	cAliasXX->(dBCloseArea())

RETURN (cPcsc)

Static Functio FullNamec(cUserc)
Return UsrFullName(cUserc)

