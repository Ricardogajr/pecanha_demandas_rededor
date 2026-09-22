#include 'protheus.ch'
#include 'parmtype.ch'

/*/{Protheus.doc} REDA007
Programa para o Menu da tela de gerar cotação.
é utilizado para re-gerar as cotações do que não foi possivel integrada com o 
Bionexo no botão RE-INTEGRAR BIONEXO ao menu de ações relacionadas.
@type function
@author Ricardo da Silva
@since 18/09/2017
@version 1.0
@return Solicitações de Compras
/*/
User Function REDA007() 

	Processa( {|| fProcessa() }, "Aguarde...", "Re-integrando Solicitações de compras...",.F.)
	
Return( .T. )


Static Function fProcessa()	
	
Local oWs			:= Nil
Local oNewStrSolic	:= Nil

Local nX			:= 0
Local nI			:= 0

Local cUser			:= ""
Local cSenha 		:= ""
Local _cZNumero		:= ""
Local _cZItem		:= ""
Local _cZNumSC		:= ""
Local cIdProc 		:= ""	
Local cQuery		:= ""

Local _cZFilial		:= xFilial("SY1")
Local _cZUser 		:= RetCodUsr()

Local aAux			:= {}
Local aArea			:= GetArea()

Local lRetSC	   	:= .F.

// Retorna um ID Único com até 254 Caracteres
cIdProc := AllTrim( FWUUIDV4() )
	
aAdd(aAux,{ {"PARAMETROS",	"LAYOUT=WA"    	},;
			{"FILIAL"    , 	SC1->C1_FILIAL 	},;
			{"LOGIN"     , 	"teste1"       	},;
			{"PASSWORD"  , 	"teste1"		},;
			{"OPERATION" ,	"WASE"			},;
			{"XIDPROC"   ,	cIdProc    		} })

_cFilial    := SC1->C1_FILIAL
_cZNumero 	:= StrZero(Val(SC1->C1_NUM), 6, 0)
_cZItem		:= SC1->C1_ITEM

SC1->(DbGoTop())
SC1->(DbSetOrder(01))
If SC1->(DbSeek(_cFilial + _cZNumero))
	While !SC1->(Eof()) .And. StrZero( Val( SC1->C1_NUM ), 6, 0 ) == _cZNumero
		
		If AllTrim(SC1->C1_XENVBIO) == "2"
			SC1->(DbSkip())
		 	Loop
		EndIf	
		
		aAdd( aAux, { 	{"C1FILIAL",	SC1->C1_FILIAL},;
						{"C1NUM"    , 	SC1->C1_NUM},;
						{"C1ITEM"   , 	AllTrim(SC1->C1_FILIAL) + AllTrim(SC1->C1_NUM) + AllTrim(SC1->C1_ITEM)},;
						{"XCONDPAG" , 	MVGetCus("MV_XCONDBI","1")},;
						{"XDTCOTA"  , 	MVGetCus("MV_XDTBIO",DToC(Date()+1))},;
						{"XHRCOTA"  , 	MVGetCus("MV_XHRBIO","00:00")},;
						{"C1PRODUTO", 	SC1->C1_PRODUTO },;
						{"C1QTSEGUM", 	cValToChar(SC1->C1_QTSEGUM) },;
						{"C1OBS"    , 	SC1->C1_OBS},;
						{"C1XTPSC"  ,  	SC1->C1_XTPSC },;
						{"TITPDC"   , 	"PDC PROTHEUS " + SC1->C1_NUM },;
						{"C1MOEDA"  ,	cValToChar(SC1->C1_MOEDA)},;
						{"XIDPROC"  ,	cIdProc };
			})
		SC1->( DbSkip() )	
	End
EndIf	
// Chama Método de Solicitação de Compras
aXml := U_REDWSDL2("WASE", aAux)

VarInfo("aXml", aXml)

If ( Type("aXml") == "A" )
	U_WsLogBio("REDA007", 2, "TYPE AXML = A")
	If ( Len(aXml) > 0 )
		U_WsLogBio("REDA007", 2, "AXML MAIOR QUE 0")
		If ( aXml[1] == "1" )			
			U_WsLogBio("REDA007", 2, "AXML[1] = 1")
			//DbSelectArea("SY1")
			//SY1->( DbSetOrder(3) )
			//If ( SY1->( DbSeek( _cZFilial + _cZUser ) ) )
			//	U_WsLogBio("REDA007", 2, "ENCONTROU O COMPRADOR")						
				DbSelectArea("SC1")
				SC1->( DbSetOrder(1) )
				If ( SC1->( MsSeek( _cZFilial + _cZNumero + _cZItem ) ) )
					U_WsLogBio("REDA007", 2, "ENCONTROU A SOLICITACAO")				
					// Identifica o registro do envio com sucesso
					While !SC1->(Eof()) .And. StrZero( Val( SC1->C1_NUM ), 6, 0 ) == _cZNumero												
						// Marca o registro selecionado como enviado	
						U_WsLogBio("REDA007", 2, "ATUALIZANDO SC " + SC1->C1_NUM + SC1->C1_ITEM )			
						SC1->( RecLock("SC1",.F.) )
							SC1->C1_XENVBIO := "1" //1=Aguardando Integr. Bionexo, 2=Integrado Bionexo, 3=Aguardando Desvinculo Bionexo, 4=Erro de Integraï¿½ï¿½o Bionexo
				//			SC1->C1_XCPBIO  := SY1->Y1_COD
							SC1->C1_XIDPROC := cIdProc
						SC1->( MsUnLock() )
						SC1->( DbSkip() )											
					EndDo
				EndIf
			//EndIf		
			// Limpa os registros de Recno
		Else
			Alert( aXml[2] )
		EndIf
	EndIf
EndIf
					
aAux := {}
		
//SC1->( DbCloseArea() )
RestArea( aArea )	

Return( .T. )
Static Function MVGetCus(cParam1, cParam2)

Return SuperGetMv(cParam1,,cParam2)
