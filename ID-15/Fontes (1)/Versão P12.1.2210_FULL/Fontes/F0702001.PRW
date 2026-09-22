#Include 'Protheus.ch'
#include 'fwmvcdef.ch'
/*
{Protheus.doc} F0702001()
Inclusão/Alteração no Cadastro de Clientes
@Author     Bruno de Oliveira
@Since		20/01/2017
@Project    MAN0000007423041_EF_020
@Param		oClients, objeto, dados do webservice
 */
User Function F0702001(oClients)

	Local aCampos    := {}
	Local cRetorno   := ""
	Local nOperation := MODEL_OPERATION_INSERT
	Local cCodMun    := ""
	Local cEstado    := ""
	
	AAdd(aCampos,{"A1_FILIAL" , oClients:cFILREG})
	
	If !Empty(oClients:cCOD+oClients:cLOJA)
		AAdd(aCampos,{"A1_COD"    , PadR(oClients:cCOD,  TamSX3("A1_COD" )[1]) })
		AAdd(aCampos,{"A1_LOJA"   , PadR(oClients:cLOJA, TamSX3("A1_LOJA")[1]) })
		nOperation := MODEL_OPERATION_UPDATE
	ElseIf !Empty(oClients:cCGC)
		SA1->(DbSetOrder(3)) //A1_FILIAL+A1_CGC
		If SA1->(DbSeek(xFilial("SA1")+oClients:cCGC))
			AAdd(aCampos,{"A1_COD"    , SA1->A1_COD  })
			AAdd(aCampos,{"A1_LOJA"   , SA1->A1_LOJA })		
			nOperation := MODEL_OPERATION_UPDATE
		Endif
	Endif

	If nOperation == MODEL_OPERATION_UPDATE
		SA1->(DbSetOrder(1))
		If SA1->(DbSeek(XFilial("SA1")+aCampos[2][2]+aCampos[3][2])) .And. ( SA1->A1_PESSOA != "F" .Or. SA1->A1_XOPCM == "1" )
			cRetorno := "WARNING|"+SA1->A1_COD+"|"+SA1->A1_LOJA+"|Cliente convenio/pessoa juridica nao pode ser alterado."
			Return cRetorno
		EndIf
	EndIf

	cCodMun := oClients:cCOD_MUN
	cEstado := Upper(AllTrim(oClients:cEST))
	CC2->(DbSetOrder(1))
	If CC2->(DbSeek(XFilial("CC2") + cEstado + Subs(cCodMun,01,04)))
		cCodMun := CC2->CC2_CODMUN
	EndIf

	AAdd(aCampos,{"A1_PFISICA", oClients:cPFISICA })
	AAdd(aCampos,{"A1_CGC"    , oClients:cCGC     })
	AAdd(aCampos,{"A1_NOME"   , oClients:cNOME    })
	AAdd(aCampos,{"A1_PESSOA" , oClients:cPESSOA  })
	AAdd(aCampos,{"A1_END"    , oClients:cEND     })
	AAdd(aCampos,{"A1_NREDUZ" , oClients:cNREDUZ  })
	AAdd(aCampos,{"A1_COMPLEM", oClients:cCOMPLEM })
	AAdd(aCampos,{"A1_BAIRRO" , oClients:cBAIRRO  })
	AAdd(aCampos,{"A1_TIPO"   , oClients:cTIPO    })
	AAdd(aCampos,{"A1_CEP"    , oClients:cCEP     })
	AAdd(aCampos,{"A1_EST"    , cEstado           })
	AAdd(aCampos,{"A1_COD_MUN", cCodMun           })
	AAdd(aCampos,{"A1_PAIS"   , oClients:cPAIS    })
	AAdd(aCampos,{"A1_CODPAIS", oClients:cCODPAIS })
	AAdd(aCampos,{"A1_EMAIL"  , oClients:cEMAIL   })
	AAdd(aCampos,{"A1_INSCRM" , oClients:cINSCRM  }) 
	AAdd(aCampos,{"A1_XOPCM"  , oClients:cXOPCM   }) 
	AAdd(aCampos,{"A1_XID"    , U_GetIntegID()    })

    cRetorno := U_F0700001("SA1", {2, 3}, "MATA030", "MATA030_SA1", aCampos, ,nOperation)        

	If ! Upper(Left(cRetorno,4)) == 'ERRO'
		cRetorno := "OK|"+SA1->A1_COD+"|"+SA1->A1_LOJA
	EndIf

Return cRetorno