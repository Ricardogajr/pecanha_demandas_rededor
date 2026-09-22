#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'

/*{Protheus.doc} F0700004
Monitor Integração por processo
@author Alex Sandro 
@since 27/12/2016
@Project MAN0000007423041_EF_000 - Monitor Integração
*/


User Function F0700004()
   Local aProcint := {}
   Local cAlias   := ''
   Local cTitulo  := ''
   Local aPergs   := {}
   Local aRet
   Local nTipImp  := "1-Pedido de Compra"
   Local nx
   Local aInt     := {}

   aadd(aProcInt,{"Pedido de Compra"         , "SC7" }) 
   aadd(aProcInt,{"Mov. titulo"              , "SE5" }) 
   aadd(aProcInt,{"Contas a Receber"         , "SE1" }) 
   aadd(aProcInt,{"Contas a Pagar"           , "SE2" }) 
   aadd(aProcInt,{"Documento Entrada"        , "SF1" }) 
   aadd(aProcInt,{"Documento Saida"          , "SF2" }) 
   aadd(aProcInt,{"Pedido Venda"             , "SC5" }) 
   aadd(aProcInt,{"Mov. Estoque"             , "SD3" }) 
   aadd(aProcInt,{"Produto"                  , "SB1" }) 
   aadd(aProcInt,{"Cadastro de Setores"      , "P11" }) 
   aadd(aProcInt,{"Local de Estoque"         , "NNR" }) 
   aadd(aProcInt,{"Cadastro de Fabricantes"  , "P13" }) 
   aadd(aProcInt,{"Cadastro de Brasindice"   , "P14" }) 
   aadd(aProcInt,{"Cadastro de Simpro"       , "P16" }) 
   aadd(aProcInt,{"Cadastro de Tuss"         , "P15" }) 
   aadd(aProcInt,{"Cadastro de Cliente"      , "SA1" }) 

   For nx:= 1 to len(aProcint)
      aadd(aInt,Alltrim(Str(nx)+"-"+aProcint[nx,1]))
   Next

	aRet	:= {}
	aAdd( aPergs ,{2,'Integração',nTipImp,aInt,80,'.T.',.T.})
	
	If ! ParamBox(aPergs ,"Selecione ",aRet,,,,,,,,.f.) 
      Return
   EndIf

   cAlias   := aProcInt[val(MV_PAR01),2]
   cTitulo  := aProcInt[val(MV_PAR01),1]
   MontBrw(cAlias,cTitulo)

Return

Static Function MontBrw(cAlias,cTitulo)
   Local oBrowse := FWMBrowse():New()

   oBrowse:SetAlias(cAlias)
   oBrowse:SetDescription(cTitulo)
   oBrowse:SetMenuDef("F0700004")
   oBrowse:Activate()
 
Return

Static Function MenuDef()
	Local aRotina := {}
	
     ADD OPTION aRotina Title 'Int. Server' 	Action 'U_F07004MS()' OPERATION 2 ACCESS 0
     ADD OPTION aRotina Title 'Int. Client'  Action 'U_F07004MC()' OPERATION 2 ACCESS 0 
     ADD OPTION aRotina Title 'Int. Server All'  Action 'U_F07004MC(.t.)' OPERATION 2 ACCESS 0 
     ADD OPTION aRotina Title 'Int. Client All'  Action 'U_F07004MC(.t.)' OPERATION 2 ACCESS 0    

Return aRotina

User Function F07004MS(lAll)
   Local cFiltro:= ''
   Default lAll:= .f.

   cFiltro := MontaFiltro(Alias(),"P19",lAll)
   U_F0700002(cFiltro)
Return

User Function F07004MC(lAll)

   Local cFiltro:= ''
   Default lAll:= .f.

   cFiltro := MontaFiltro(Alias(),"P20",lAll)

   U_F0700003(cFiltro)
Return

Static Function MontaFiltro(cAlias,cTab,lAll)
Local cIndKey     := ''
Local aAreaAlias  := (cAlias)->(GetArea(cAlias)) 
Local aParKey     := {}
Local nPos        := 0
Local nOrdem      := 0
Local aCampos     := {}
Local nx          := 1
Local cFiltro


   aadd(aParKey,{"Pedido de Compra"         , "SC7", 1            ,'U_F0702201-U_F0702601-U_F0702203',"C7_FILIAL+C7_NUM" }) 
   aadd(aParKey,{"Mov. titulo"              , "SE5", "EF0702801"  ,'U_F0702801',NIL})
   aadd(aParKey,{"Contas a Receber"         , "SE1", 1            ,'U_F0702803-U_F0702702',NIL})
   aadd(aParKey,{"Contas a Pagar"           , "SE2", 1            ,'U_F0702902',NIL})
   aadd(aParKey,{"Documento Entrada"        , "SF1", 1            ,'U_F0703301',NIL})
   aadd(aParKey,{"Documento Saida"           ,"SF2", 1            ,'U_F0703401',NIL})
   aadd(aParKey,{"Pedido Venda"             , "SC5", 1            ,'U_F0703302-U_F0703203',NIL})
   aadd(aParKey,{"Mov. Estoque"             , "SD3", 'FSWSD301'   ,'U_F0703501',NIL})
   aadd(aParKey,{"Produto"                  , "SB1", 1            ,'U_F0702501',NIL})                 
   aadd(aParKey,{"Cadastro de Setores"      , "P11", 1            ,'U_F0700301',NIL})
   aadd(aParKey,{"Local de Estoque"         , "NNR", 1            ,'U_F0700602',NIL}) 
   aadd(aParKey,{"Cadastro de Fabricantes"  , "P13", 1            ,'U_F0700801',NIL}) 
   aadd(aParKey,{"Cadastro de Brasindice"   , "P14", 1            ,'U_F0701101',NIL}) 
   aadd(aParKey,{"Cadastro de Simpro"       , "P16", 1            ,'U_F0701401',NIL}) 
   aadd(aParKey,{"Cadastro de Tuss"         , "P15", 1            ,'U_F0701701',NIL}) 
   aadd(aParKey,{"Cadastro de Cliente"      , "SA1", 1            ,'U_F0702001',NIL}) 


   nPos  := Ascan(aParKey,{|x| x[2] == cAlias})  // tem que achar!!
   If ValType( aParkey[nPos,3]) == "C"
      (cAlias)->(DBOrderNickName(aParkey[nPos,3]))
   Else
      (cAlias)->(DBSetOrder(aParkey[nPos,3]))
   EndIf

   If aParkey[nPos,5] <> NIL
      aCampos := StrTokArr(aParkey[nPos,5],"+")
   Else
      aCampos := StrTokArr((cAlias)->(IndexKey()),"+")
   EndIf   
   For nx:= 1 to len(aCampos)
      cIndKey+= (cAlias)->(FieldGet(FieldPos(aCampos[nx])))
      cIndKey+="|"
   Next

   If ! cAlias $ "P11+NNR+P13+P14+P16+P15+SA1+"
      cIndKey:= Left(cIndKey,len(cIndKey)-1)
   EndIf
   cIndKey := cAlias+"|"+Strzero((cAlias)->(IndexOrd()),2)+"|"+cIndKey
   cIndKey := Padr(cIndKey,250)

   cFiltro := cTab+'->'+cTab+'_FILIAL == "'+xFilial(cTab)+'"' 
   If ! lAll
      cFiltro += ' .AND. '+cTab+'->'+cTab+'_INDKEY == "'+cIndKey+'"'
   EndIf
   cFiltro += ' .AND. Alltrim('+cTab+'->'+cTab+'_ROTINA) $  "'+aParkey[nPos,4]+'"'

   (cAlias)->(RestArea(aAreaAlias))

Return cFiltro






