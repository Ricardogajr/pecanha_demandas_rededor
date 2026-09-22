#Include "TOTVS.CH"

Static _aPedido := {}

/*{Protheus.doc} F0703403
Rotina de exclusão de pedido de venda ao termino da exclusão da nota fiscal
@author Alex Valario
@since  24/05/2017
@return Nil  
@project MAN0000007423041_EF_034
@version P12.1.7
*/

User Function F0703403(lMSD2520)

    If lMSD2520
        AddPedido()
    Else
        ExcPedido()
    EndIf
    
Return



Static Function AddPedido()

    If Empty( SD2->D2_PEDIDO )
        Return
    EndIf

    If Ascan(_aPedido, SD2->D2_PEDIDO ) == 0
        AAdd(_aPedido, SD2->D2_PEDIDO )
    EndIf

Return

Static Function ExcPedido()
    Local aCab    := {}
    Local aItens  := {}
    Local nX      := 1 

    Private lMsHelpAuto := .t.
    Private lMsErroAuto := .f.
 
    For nX := 1 to Len( _aPedido )

        aCab    := {}
        aItens  := {}
        CarregaPed(_aPedido[nx], aCab, aItens )
                           
        If !Empty(aCab) .and. !Empty(aItens)
	        lMsErroAuto := .f.
	        MSExecAuto({|x,y,z|Mata410(x,y,z)}, aCab, aItens, 5 )
	        If lMsErroAuto
	            conout('Erro na exclusão do pedido')
	        EndIf
        EndIf
    Next
    _aPedido := {}
Return
 

Static Function CarregaPed( cNumPed, aCab, aItens )
    Local aAreaSC5 := SC5->( GetArea( 'SC5' ) )
    Local aAreaSC6 := SC6->( GetArea( 'SC6' ) )
    Local aItem    := {}

    SC5->(DbSetOrder( 1 ))
    SC5->(DbSeek( xFilial('SC5') + cNumPed ) )

	If !Empty(SC5->C5_XID)
	    aCab:=  {   {"C5_NUM"      , cNumPed          , Nil },; 
	                {"C5_CLIENTE"  , SC5->C5_CLIENTE  , Nil },; 
	                {"C5_LOJAENT"  , SC5->C5_LOJAENT  , Nil },; 
	                {"C5_LOJACLI"  , SC5->C5_LOJACLI  , Nil },; 
	                {"C5_EMISSAO"  , SC5->C5_EMISSAO  , Nil },; 
	                {"C5_TIPO"     , SC5->C5_TIPO     , Nil } }
	                
	    aItens := {} 
	    SC6->(DbSetOrder( 1 ))
	    SC6->(DbSeek( xFilial( 'SC6' ) + cNumPed))
	    While SC6->( ! Eof() .and. C6_FILIAL + C6_NUM == xFilial( 'SC6' ) + cNumPed )
	        aItem := {  {"C6_NUM"    , cNumped           ,Nil },; 
	                    {"C6_ITEM"   , SC6->C6_ITEM      ,Nil },; 
	                    {"C6_PRODUTO", SC6->C6_PRODUTO   ,Nil },; 
	                    {"C6_QTDVEN" , SC6->C6_QTDVEN    ,Nil },; 
	                    {"C6_PRUNIT" , SC6->C6_PRUNIT    ,Nil },; 
	                    {"C6_PRCVEN" , SC6->C6_PRCVEN    ,Nil },; 
	                    {"C6_VALOR"  , SC6->C6_VALOR     ,Nil },; 
	                    {"C6_ENTREG" , SC6->C6_ENTREG    ,Nil },; 
	                    {"C6_UM"     , SC6->C6_UM        ,Nil },; 
	                    {"C6_TES"    , SC6->C6_TES       ,Nil },; 
	                    {"C6_LOCAL"  , SC6->C6_LOCAL     ,Nil } }
	
	        AAdd(aItens, aclone( aItem ) ) 
	        SC6->(DbSkip())
	    EndDo
	EndIf
    RestArea(aAreaSC6)
    RestArea(aAreaSC5)
Return