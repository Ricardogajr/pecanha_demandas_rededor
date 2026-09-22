#include "totvs.ch"

#define F24CONSUMO    1
#define F24COMPRA     2
#define F24P12TOFRONT 1
#define F24FRONTTOP12 2

/*/{Protheus.doc} F0702205
GATILHOS PARA MAN0000007423041_EF_022
Funções responsáveis por validar:
    - Preenchimento automático de TES na digitação do produto para pedido de compra ERP
    - Preenchimento automático de Centro de Custo na digitação do produto e/ou local para pedido de compra ERP
    - Preenchimento automático dos campos de coversão
@type User function
@author robson.william
@since 13/03/2017
@version 12.7
@param
@history    ticket n° 9153073 -- Paulo Dias -- Alteração na sintaxe das funções GDFieldGet e GDFieldPut para release 27
            ticket n° 9081027 -- Paulo Dias -- Validação para rotina de SP com gatilho
@project	MAN0000007423041_EF_022
@return lRet
/*/

User Function F0702205()

Local cRet 		 := &(ReadVar())
Local cCampo     := StrTran(ReadVar(),"M->","")
Local aSBZArea   := SBZ->(GetArea("SBZ"))
Local cCusto     := ""
Local cProduto   := cRet
Local aConv      := {}
Local lBlind	:=  IsBlind() //9363900 - Thais Paiva
Local lFilSimp := U_VALSIMP()
Private nCont 
Private nRun  // ticket n° 9081027 -- validação para solicitação de pagamento

If !lBlind //9363900 - Thais Paiva
	If IsInCallStack("MATA121") // ticket n° 9081027 -- validação para solicitação de pagamento
		If (cCampo $ "C7_PRODUTO")
			//Preenchimento do TES
			SBZ->(DbSetOrder(1))
			If SBZ->(DbSeek(xFilial("SBZ") + cProduto))
				While SBZ->(!Eof() .and. SBZ->BZ_FILIAL + SBZ->BZ_COD == xFilial("SBZ") + cProduto)
					If SBZ->BZ_LOCPAD == GDFieldGet("C7_LOCAL",nCont, , , ) 
						GDFieldPut("C7_TES",SBZ->BZ_TE,nCont, , , ) 
						Exit
					Endif
					SBZ->(DbSkip())
				End
			Else
				Help(,,'F07022051',,"Cadastro de Indicadores de Produto não localizado! Impossível Preenchimento do TES",1,0)
				cRet := Space(TamSX3("C7_PRODUTO")[01])
				GDFieldPut( "C7_TES",SC7->(Space(TamSX3("C7_PRODUTO")[01])),nCont, , , ) 
			Endif

			//Preenchimento do Centro de Custo
			cCusto := Posicione("P11",1,xFilial("P11") + cProduto,"P11_CCUSTO")
			If !Empty(cCusto)
				GDFieldPut("C7_CC",cCusto,nCont, , , ) 
			Endif
		ElseIf (cCampo $ "C7_QUANT/C7_QTSEGUM/C7_PRECO")
			//Realizando a conversão para compras
            if !lFilSimp
                If !(IsInCallStack("fCalcConv"))
                    aConv := U_F07024X(GDFieldGet("C7_PRODUTO",nCont, , , ), cFilAnt , GDFieldGet("C7_QUANT",nCont, , , ), F24COMPRA , F24P12TOFRONT, Nil) 
                    If !Empty(aConv[3])
                        Help(,,'F07022052',,"ERRO| PRODUTO " + SC7->C7_PRODUTO + " - " + aConv[3],1,0)
                        cRet := 0
                    Else
                        GDFieldPut("C7_XUMCONV" ,aConv[2],nCont, , , ) 
                        GDFieldPut("C7_XTPFATO" ,aConv[5],nCont, , , ) 
                        GDFieldPut("C7_XFATOR"  ,aConv[6],nCont, , , ) 
                        GDFieldPut("C7_XQTDPC"  ,aConv[1],nCont, , , ) 
                    EndIf
                Endif
                
                IF  GDFieldGet("C7_XFATOR",nCont, , , ) == 1  
                    GDFieldPut( "C7_XPRECO"  , GDFieldGet("C7_PRECO",nCont, , , ),nCont, , , ) 
                ELSE
                    GDFieldPut("C7_XPRECO"  ,GDFieldGet("C7_TOTAL",nCont, , , )/GDFieldGet("C7_XQTDPC",nCont, , , ),nCont, , , )   // 01 
                ENDIF

                GDFieldPut("C7_XTOTAL"  ,GDFieldGet("C7_XPRECO",nCont, , , )*GDFieldGet("C7_XQTDPC",nCont, , , ),nCont, , , )         
            endif
		ElseIf (cCampo $ "C7_XFATOR/C7_XTPFATO/C7_XQTDPC/C7_XPRECO")
            if !lFilSimp
			    fCalcConv(cCampo)
            endif
		Endif
	// ticket n° 9081027 -- gatilho
	ElseIf (!Empty(FWFldGet("C7_QUANT",nCont)) .AND. cCampo == "C7_PRECO") .OR. (!Empty(FWFldGet("C7_PRECO",nCont)) .AND. cCampo == "C7_QUANT")
		FWFldPut("C7_TOTAL",FWFldGet("C7_QUANT",nCont) * FWFldGet("C7_PRECO",nCont)) 
	EndIf
	// ticket n° 9081027 -- fim

// ----------------------------------------------
else
    if ( cCampo $ 'C7_QUANT/C7_QTSEGUM/C7_PRECO' )
// -----[ Realizando a conversão para compras ]--
        if !lFilSimp
            if !( isincallstack( 'fCalcConv' ))
                aConv := u_f07024x( GDFieldGet( 'C7_PRODUTO' ) , cFilAnt , GDFieldGet( 'C7_QUANT' ) , F24COMPRA , F24P12TOFRONT , Nil )
                if !empty( aConv[3] )
                    help( , , 'F07022052' , , "ERRO| PRODUTO " + SC7->C7_PRODUTO + " - " + aConv[3] , 1 , 0 )
                    cRet := 0
                else
                    GDFieldPut( 'C7_XUMCONV' , aConv[2] )
                    GDFieldPut( 'C7_XTPFATO' , aConv[5] )
                    GDFieldPut( 'C7_XFATOR'  , aConv[6] )
                    GDFieldPut( 'C7_XQTDPC'  , aConv[1] )
                endif
            endif
            if GDFieldGet( 'C7_XFATOR' ) == 1
                GDFieldPut( 'C7_XPRECO' , GDFieldGet( 'C7_PRECO' ))
            else
                GDFieldPut( 'C7_XPRECO' , GDFieldGet( 'C7_TOTAL' ) / GDFieldGet( 'C7_XQTDPC' ))
            endif
            GDFieldPut( 'C7_XTOTAL' , GDFieldGet( 'C7_XPRECO' ) * GDFieldGet( 'C7_XQTDPC' ))
        endif
    endif
// ----------------------------------------------

EndIf //9363900 - Thais Paiva
RestArea(aSBZArea)
Return cRet


/*/{Protheus.doc} nomeStaticFunction
    (long_description)
    @type  Static Function
    @author user
    @since date
    @version version
    @param param, param_type, param_descr
    @return returno,return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    /*/
 Static Function fCalcConv(cCampo)

    If cCampo $ "C7_XPRECO"
        GDFieldPut("C7_XTOTAL"  ,GDFieldGet("C7_XQTDPC",nCont, , , ) * GDFieldGet("C7_XPRECO",nCont, , , ),nCont, , , ) 
        GDFieldPut("C7_TOTAL"   ,GDFieldGet("C7_XQTDPC",nCont, , , ) * GDFieldGet("C7_XPRECO",nCont, , , ),nCont, , , ) 
        GDFieldPut("C7_PRECO"   ,GDFieldGet("C7_TOTAL",nCont, , , )/GDFieldGet("C7_QUANT",nCont, , , ),nCont, , , ) 

        If !fCalSX3("C7_PRECO")
            Return .F.
        Endif
    Endif

    If cCampo $ "C7_XQTDPC"
        If GDFieldGet("C7_XTPFATO",nCont, , , ) == "M"
            GDFieldPut("C7_QUANT",GDFieldGet("C7_XQTDPC",nCont, , , ) / GDFieldGet("C7_XFATOR",nCont, , , ),nCont, , , ) 
        Else
            GDFieldPut("C7_QUANT",GDFieldGet("C7_XQTDPC",nCont, , , ) * GDFieldGet("C7_XFATOR",nCont, , , ),nCont, , , ) 
        Endif
 
        IF  GDFieldGet("C7_XFATOR",nCont, , , ) == 1  
        	GDFieldPut( "C7_XPRECO"  , GDFieldGet("C7_PRECO",nCont, , , ),nCont, , , ) 
        ELSE
         	GDFieldPut("C7_XPRECO"  ,GDFieldGet("C7_TOTAL",nCont, , , )/GDFieldGet("C7_XQTDPC",nCont, , , ),nCont, , , ) // 02 
        ENDIF
 
        GDFieldPut("C7_PRECO"  ,GDFieldGet("C7_TOTAL",nCont, , , )/GDFieldGet("C7_QUANT",nCont, , , ),nCont, , , ) 

        If !fCalSX3("C7_QUANT")
            Return .F.                
        Endif
        
        If !fCalSX3("C7_PRECO")
            Return .F.
        Endif
    Endif

    If cCampo $ "C7_XTPFATO/C7_XFATOR"
        If GDFieldGet("C7_XTPFATO",nCont, , , ) == "M"
            GDFieldPut("C7_XQTDPC",GDFieldGet("C7_QUANT",nCont, , , ) * GDFieldGet("C7_XFATOR",nCont, , , ),nCont, , , )  
        Else
            GDFieldPut("C7_XQTDPC",GDFieldGet("C7_QUANT",nCont, , , ) / GDFieldGet("C7_XFATOR",nCont, , , ),nCont, , , ) 
        Endif
        
        // ID 1451
        IF  GDFieldGet("C7_XFATOR",nCont, , , ) == 1  
        	GDFieldPut( "C7_XPRECO"  , GDFieldGet("C7_PRECO",nCont, , , ),nCont, , , )
        ELSE
        	GDFieldPut("C7_XPRECO"  ,GDFieldGet("C7_TOTAL",nCont, , , ) / GDFieldGet("C7_XQTDPC",nCont, , , ),nCont, , , ) // 03
        ENDIF
        // FIM ID 1451
        
        GDFieldPut("C7_XTOTAL"  ,GDFieldGet("C7_XPRECO",nCont, , , ) * GDFieldGet("C7_XQTDPC",nCont, , , ),nCont, , , )
    Endif

Return

 /*/{Protheus.doc} nomeFunction
    (long_description)
    @type  Function
    @author user
    @since date
    @version version
    @param param, param_type, param_descr
    @return returno,return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    /*/

Static Function fCalSX3(cCampo)
Local cOldReadV := __ReadVar
Local aSX3Area  := SX3->(GetArea("SX3"))
Local b1Block   := {|| .T.}
Local b2Block   := {|| .T.}
Local lRet      := .T.

__ReadVar := 'M->' + cCampo
&('M->' + cCampo) := GDFieldGet(cCampo,nCont, , , )

   //Início -  Thais Paiva - Compatibilização P27
   //SX3->(DbSetOrder(2))
   //SX3->(DbSeek(Upper(cCampo)))
	
    //If !Empty(SX3->X3_VALID)
	If !Empty(Alltrim(GetSx3Cache(cCampo, 'X3_VALID')))
        //b1Block := &( '{ || ' + AllTrim(SX3->X3_VALID) + ' }' )
		b1Block := &( '{ || ' + AllTrim(GetSx3Cache(cCampo, 'X3_VALID')) + ' }' )
    Endif

    //If !Empty(SX3->X3_VLDUSER)
	If !Empty(Alltrim(GetSx3Cache(cCampo, 'X3_VLDUSER')))
        //b2Block := &( "{ || " + AllTrim(SX3->X3_VLDUSER) + " }" )
		b2Block := &( "{ || " + AllTrim(GetSx3Cache(cCampo, 'X3_VLDUSER')) + " }" )
    Endif

    lRet := Eval(b1Block) 
    If lRet
        lRet:=Eval(b2Block)
        If lRet
            //If SX3->X3_TRIGGER == "S"
			If Alltrim(GetSx3Cache(cCampo, 'X3_TRIGGER')) == "S"
                RunTrigger(2,nRun,NIL,,Padr(cCampo,10))
            EndIf        
        Endif
    Endif
	//Fim  -  Thais Paiva - Compatibilização P27

__ReadVar := cOldReadV

RestArea(aSX3Area)
Return lRet
