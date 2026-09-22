#Include 'Protheus.ch'

User Function RelDic()
   Local lRet      := .F.
   Local oDlgTbl   := Nil 
   Local oListTbl  := Nil
   Local cListTbl  := 0
   Local aListTbl  := {}
   Local nListH    := 0
   Local nListW    := 0
   Local oChkTodos := Nil
   Local lChkTodos := .F.
   Local oBtnConf  := Nil
   Local bBtnConf  := {|| lRet := .T., oDlgTbl:End() }
   Local oBtnCanc  := Nil
   Local bBtnCanc  := {|| lRet := .F., oDlgTbl:End() }
   Local bSelTodos := {|| AEval(oListTbl:aArray,{|l| l[1] := lChkTodos}), oListTbl:Refresh() }
   Local bFilter   := {||SetFiltro(@oListTbl,cGetFil) }
   
   Private aSx2Tables := {}
   Private oNo       := LoadBitmap( GetResources(), "LBNO" )
   Private oOk       := LoadBitmap( GetResources(), "LBOK" )
   Private cGetFil   := Space(30)
   Private oGetFil   := Nil
   
   
   MsAguarde({|| LoadTables(oListTbl,@aListTbl,{}) },"Aguarde, carregando o dicionario...")
   
   If Empty(aListTbl)
      Return .F.
   Endif
   
   oDlgTbl :=TDialog():New(000,000,400, 400,"Selecione a(s) tabela(s)",,,,,,,,,.T.)
       oDlgTbl:nClrPane:= RGB(254,255,255)
       
       oPnlTop:= TPanel():New(00,00,,oDlgTbl,,.T.,,,,000,28)
       oPnlTop:Align := CONTROL_ALIGN_TOP
       
	   oGetFil := TGet():New(005,005 , bSetGet(cGetFil), oPnlTop,150, 10, "@!" , {||.T.},,,;
              /*oFnt12AriN*/,,,.T.,,,{|| .T. },,,{|| .T. },.F. ,,, "" ,,,,,,,"Pesquisar a seguinte expressão:",1,/*oFnt12AriN*/)

	   oBtnFil := TBtnBmp2():New(oGetFil:nTop+9,320,50,30,'CHECKED.PNG',,,,bFilter,oPnlTop,"Selecionar...",,.T. )

       oPnlBottom:= TPanel():New(00,00,,oDlgTbl,,.T.,,,,000,28)
       oPnlBottom:Align := CONTROL_ALIGN_BOTTOM       
              
       nListH := (oDlgTbl:nClientHeight / 2) - 50
       nListW := (oDlgTbl:nClientWidth / 2) - 10
       
       @ 005, 005 Listbox oListTbl Var cListTbl Fields Header " ", "Tabela", "Descricao" Size nListW,nListH Of oDlgTbl Pixel
       //oListTbl := TListBox():New(005,005,{|u|if(Pcount()>0,cListTbl:=u,cListTbl)},aListTbl,nListW,nListH,,oDlgTbl,,,,.T.)       
          oListTbl:SetArray( aListTbl )
          oListTbl:bLine      := {||{IIf( aListTbl[oListTbl:nAt, 1], oOk, oNo ), aListTbl[oListTbl:nAt, 2], aListTbl[oListTbl:nAt, 3]}}
          oListTbl:BlDblClick := { || aListTbl[oListTbl:nAt, 1] := !aListTbl[oListTbl:nAt, 1], oListTbl:Refresh()}
          oListTbl:cToolTip   := oDlgTbl:cTitle
          oListTbl:Align      := CONTROL_ALIGN_ALLCLIENT

      oChkTodos := TCheckBox():New((oPnlBottom:nTop/2)+10,05,'Todos',bSetGet(lChkTodos),oPnlBottom,100,050,,bSelTodos,/* oFont */, /* bValid */, /* nClrText */, /* nClrPane */, /* uParam14 */, /* lPixel */, /* cMsg */, /* uParam17 */, /* bWhen */ )

      oBtnCanc := TButton():New(005,oPnlBottom:nRight+055,"Cancelar" ,oPnlBottom,bBtnCanc,070,15,,,,.T.)
      oBtnConf := TButton():New(005,oPnlBottom:nRight+130,"Confirmar",oPnlBottom,bBtnConf,070,15,,,,.T.)

   oDlgTbl:Activate(,,,.T.,{|| If(lRet,GeraRelat(oListTbl:aArray),) })
   
Return lRet

*************************************
Static Function SetFiltro(oList,cExp)
*************************************
   Local aList := AClone(oList:AArray)
   
   cExp := AllTrim(Upper(cExp))
   
   Aeval(aList,{|x| x[1] := (x[1] .OR. (cExp $ Upper(x[2]))) })
   
   oList:SetArray(aList)
   oList:bLine  := {||{IIf( aList[oList:nAt, 1], oOk, oNo ), aList[oList:nAt, 2], aList[oList:nAt, 3]}}   
   oList:Refresh()
   
   cGetFil := Space(30)
   oGetFil:SetFocus()   
   
return .T. 


**************************************************
Static Function LoadTables(oList,aTables,aFilter)
**************************************************
   Local cQuery := ""
   Local _cAliasX2 := GetNExtAlias()
   Default aFilter := {}

   If Empty(aTables)   
      //SX2->(DbSetOrder(1))
      //SX2->(DbGotop())
		cQuery := " SELECT X2_CHAVE AS CHAVEX2, X2_NOME AS NOMEX2"
		cQuery += " FROM "+RetSQLName("SX2") + " SX2  "
		cQuery += " WHERE D_E_L_E_T_= ' ' "

		cQuery := ChangeQuery(cQuery)
		dbUseArea(.T., 'TOPCONN', TcGenQry(,,cQuery), _cAliasX2)
      While (_cAliasX2)->(!Eof()) //SX2->(!Eof())
            Aadd(aTables,{.F.,(_cAliasX2)->CHAVEX2,AllTrim((_cAliasX2)->NOMEX2)})
            (_cAliasX2)->(DbSkip()) //SX2->(DbSkip(1))
      EndDo
   Endif
   
   If !Empty(aFilter)
      AEval(aTables,{|x| k := x[2], x[1] := ( AScan(aFilter,{|t| t == k}) > 0 )})
   Endif
   
   If (ValType(oList) == "O")
      oList:SetArray( aTables  )
      oList:Refresh()
   Endif

Return .T.

*********************************
Static Function GeraRelat(aAlias)
*********************************
   Local aRows    := {}
   Local nX       := 1
   Local aAreaSx3 := SX3->(FWGetArea())
   Local _aCmpX3
   Local _nCp := 0 //SX3->(DbSetOrder(1)) //X3_ARQUIVO+X3_ORDEM
   
   For nX := 1 To Len(aAlias)
       If ! aAlias[nX,1]
          Loop
       Endif
       
       _aCmpX3 := FWSX3Util():GetAllFields(aAlias[nX,2], .T. ) //SX3->(dbseek(aAlias[nX,2]))
       For _nCp := 1 to Len(_aCmpX3) //While (SX3->(!Eof()) .And. (GetSx3Cache(_aCmpX3[_nCp], 'X3_ARQUIVO == aAlias[nX,2]))
             Aadd(aRows,{GetSx3Cache(_aCmpX3[_nCp], 'X3_ARQUIVO') +" - "+FWX2Nome(GetSx3Cache(_aCmpX3[_nCp], 'X3_ARQUIVO')),GetSx3Cache(_aCmpX3[_nCp], 'X3_CAMPO'),GetSx3Cache(_aCmpX3[_nCp], 'X3_DESCRIC'),GetSx3Cache(_aCmpX3[_nCp], 'X3_TIPO'),GetSx3Cache(_aCmpX3[_nCp], 'X3_TAMANHO'),GetSx3Cache(_aCmpX3[_nCp], 'X3_DECIMAL'),GetSx3Cache(_aCmpX3[_nCp], 'X3_CONTEXT'),If(X3Obrigat(GetSx3Cache(_aCmpX3[_nCp], 'X3_CAMPO')),"Sim","Não")})
             //SX3->(dbskip())
       Next _nCp //Enddo
	   _aCmpX3 := {}
   Next nX
   
   SX3->(RestArea(aAreaSx3))

   MsAguarde({|| fReport(aRows)},"Aguarde, gerando o relatorio...")
   
return .T.   

******************************
Static Function fReport(aRows)
******************************
   Local cFileName := U_GetTmpKit(.T.) + "RelDic.csv"
   Local nHld      := fCreate(cFileName)
   Local aHtml     := {}
   Local cRow      := ""
   Local nX, nY, nZ:= 0
   Local cRelTit   := "DICIONARIO DE DADOS"
   Local aHeader   := {"X3_ARQUIVO","X3_CAMPO","X3_DESCRIC","X3_TIPO","X3_TAMANHO","X3_DECIMAL","X3_CONTEXT","X3_OBRIGAT"}
   
   If Empty(aRows)
      MsgInfo("Não há dados!")
      Return .F.
   Endif

   aSort( aRows,,,{ |x,y| x[1] < y[1] } )
   
   If nHld = -1
      conout("Erro ao criar arquivo - ferror " + Str(Ferror()))
      Return .F.
   Endif
   
   FWrite(nHld, cRelTit + CRLF)
   
   For nX := 1 To Len(aRows)
       
       cRow := ""
       
       If nX == 1
          AEval(aHeader,{|h| cRow += h + ";" })
          cRow += CRLF
       Endif 

       AEval(aRows[nX],{|d| cRow += cValToChar(d) + ";" })
       
       FWrite(nHld, cRow + CRLF)
       
   Next nX
   
   FClose(nHld)
   
   If File(cFileName)
      ShellExecute("Open",cFileName,"","",3)	// 1 = Normal, 2 = Minimizado, 3 = Maximizado
   Endif
   
Return .T.
  
