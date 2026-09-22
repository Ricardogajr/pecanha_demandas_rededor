#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'

#DEFINE CAMPOSSUP 'KT0_FILIAL|KT0_EQPE|KT0_EQDESC|'
#DEFINE MODEL_OPERATION_COPY 9

//-------------------------------------------------------------------
/*/{Protheus.doc} xKPTPerfil                                                    
@Description Cadastro de Equipe/Perfil x Usuarios para filtro no Portal do Onergy - TaxFy | KTGroup
@author	Joalisson Laurentino - 11 98975-3610
@since 	26/08/2024
/*/
//-------------------------------------------------------------------
User Function xKPTPerfil()
	Local oBrowse	:= FwMBrowse():New()
	Private aRotina := FwLoadMenuDef("xKPTPerfil")

	oBrowse:SetDescription("Perfil x Acesso - Onergy | KTGroup")
	oBrowse:SetAlias("KT0")
	oBrowse:Activate()
Return()
 
//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef                                                    
@Description Menu do cadastro.
@author	Joalisson Laurentino - 11 98975-3610
@since 	26/08/2024
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
	Local aRot := {}

	//Adicionando opções
	ADD OPTION aRot TITLE 'Visualizar' 	ACTION 'VIEWDEF.xKPTPerfil' OPERATION MODEL_OPERATION_VIEW	ACCESS 0 //OPERATION 2
	ADD OPTION aRot TITLE 'Incluir' 	ACTION 'VIEWDEF.xKPTPerfil' OPERATION MODEL_OPERATION_INSERT 	ACCESS 0 //OPERATION 3
	ADD OPTION aRot TITLE 'Alterar' 	ACTION 'VIEWDEF.xKPTPerfil' OPERATION MODEL_OPERATION_UPDATE 	ACCESS 0 //OPERATION 4
	ADD OPTION aRot TITLE 'Excluir'	 	ACTION 'VIEWDEF.xKPTPerfil' OPERATION MODEL_OPERATION_DELETE 	ACCESS 0 //OPERATION 5
	ADD OPTION aRot TITLE 'Copiar'		ACTION 'VIEWDEF.xKPTPerfil' OPERATION MODEL_OPERATION_COPY  	ACCESS 0 //OPERATION 9

Return aRot
//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef                                                    
@Description Define o modelo de dados do cadastro;
@author	Joalisson Laurentino - 11 98975-3610
@since 	26/08/2024
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
	Local oModel 	:= Nil
	Local oStruSup	:= FwFormStruct(1,"KT0", { | cCampo |	AllTrim( cCampo ) + '|' $ CAMPOSSUP } )  
	Local oStruInf	:= FwFormStruct(1,"KT0", { | cCampo |  !AllTrim( cCampo ) + '|' $ CAMPOSSUP } )
	Local aRelacao	:= {}
	Local aGatilhos := {}
	Local nAtual	:= 0

	//Adicionando um gatilho, do codigo para data
    aAdd(aGatilhos, FWStruTriggger( ;
        "KT0_CODUSR",;                                //Campo Origem
        "KT0_USRNOM",;                                  //Campo Destino
        "u_xVldName()",;                            //Regra de Preenchimento
        .F.,;                                       //Irá Posicionar?
        "",;                                        //Alias de Posicionamento
        0,;                                         //Índice de Posicionamento
        '',;                                        //Chave de Posicionamento
        NIL,;                                       //Condição para execução do gatilho
        "01");                                      //Sequência do gatilho
    )

	//Percorrendo os gatilhos e adicionando na Struct
    For nAtual := 1 To Len(aGatilhos)
        oStruInf:AddTrigger( ;
            aGatilhos[nAtual][01],; //Campo Origem
            aGatilhos[nAtual][02],; //Campo Destino
            aGatilhos[nAtual][03],; //Bloco de código na validação da execução do gatilho
            aGatilhos[nAtual][04];  //Bloco de código de execução do gatilho
        )
    Next

	oModel := MPFormModel():New("MxKPTPerfil",/*bPre*/,/*bTudOk*/,/*bCommit*/,/*bCancel*/)
	oModel:AddFields("KT0MASTER",/*cOwner*/,oStruSup)
	oModel:AddGrid("KT0DETAIL","KT0MASTER",oStruInf, /*bLinePre*/, /*bLinePost*/, /*bPre*/, /*bPost*/ )

	// Faz relaciomaneto entre os compomentes do model
	aAdd(aRelacao,{'KT0_FILIAL'	, 'FWxFilial("KT0")'})
	aAdd(aRelacao,{'KT0_EQPE' , 'KT0_EQPE'})
	oModel:SetRelation( 'KT0DETAIL', aRelacao , KT0->(IndexKey(1)) )

	oModel:SetPrimarykey({"KT0_FILIAL","KT0_EQPE"})
	oModel:GetModel( 'KT0DETAIL' ):SetUniqueLine( { 'KT0_ITEM' } )

	oModel:SetDescription("Usuarios")
Return(oModel)

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef                                                    
@Description Define o modelo de visualização do cadastro;
@author	Joalisson Laurentino - 11 98975-3610
@since 	26/08/2024
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
	Local oView 	:= FwFormView():New()
	Local oStruSup	:= FwFormStruct(2,"KT0", { | cCampo |	AllTrim( cCampo ) + '|' $ CAMPOSSUP } )
	Local oStruInf	:= FwFormStruct(2,"KT0", { | cCampo |  !AllTrim( cCampo ) + '|' $ CAMPOSSUP } )
	Local oModel	:= FwLoadModel("xKPTPerfil")

	oView:SetModel( oModel )

	oView:AddField("VWKT0MASTER"	, oStruSup ,"KT0MASTER")
	oView:AddGrid("VWKT0DETAIL"		, oStruInf ,"KT0DETAIL") 

	oView:CreateHorizontalBox("SUP",20)
	oView:CreateHorizontalBox("INF",80)

	oView:SetOwnerView("VWKT0MASTER","SUP")
	oView:SetOwnerView("VWKT0DETAIL","INF")

	oView:EnableTitleView("VWKT0MASTER","Equipe/Perfil de Acesso")
	oView:EnableTitleView("VWKT0DETAIL","Usuários")

	oView:AddIncrementField( 'VWKT0DETAIL', 'KT0_ITEM' )

Return(oView)
//-------------------------------------------------------------------
/*/{Protheus.doc} SHPTudOk                                                    
@Description Rotina responsavel por validar o formulario do Modelo de
dados, equivalente ao TudoOK.
@Param oModel = Modelo de dados 
@Return lRet  = .T. Validação sucesso | Caso constrário .F.
@author	Joalisson Laurentino - 11 98975-3610
@since 	26/08/2024
/*/
//-------------------------------------------------------------------
User Function SHPTudOk()
	Local cCodUsr := M->KT0_CODUSR
	Local cEquipe := M->KT0_EQPE
	Local lRet 	  := .T.

	DbSelectArea("KT0")	
	KT0->( DbSetOrder(1) ) //KT0_CODUSR + KT0_ROTINA
	If  KT0->( DbSeek(FWxFilial("KT0") + cEquipe + cCodUsr ) )
		 Help("",1,"","xKPTPerfil001","Usuário x Equipe já cadastrado.",1,,,,,,,{"Verifique os dados informados."}) 
		 lRet := .F.
	EndIf
Return(lRet)

/*/{Protheus.doc} User Function zV38Gat
Função que será acionada pelo gatilho do campo código para o campo data
@type  Function
@author Joalisson Laurentino - 11 98975-3610
@since 26/08/2024
/*/
User Function xVldName()
    Local aArea    := FWGetArea()
    Local cRetorno := Upper(UsrFullName(M->KT0_CODUSR))

	FwFldPut("KT0_USRNOM",Upper(UsrFullName(M->KT0_CODUSR)),,,, .T.)
	FwFldPut("KT0_EMAIL" ,Lower(UsrRetMail(M->KT0_CODUSR)),,,, .T.)
	FwFldPut("KT0_ZINTOG","1",,,, .T.)

    FWRestArea(aArea)
Return cRetorno

