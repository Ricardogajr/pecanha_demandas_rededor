#INCLUDE 'PROTHEUS.CH'

user function mdta0051()

    local aRot := PARAMIXB[1]
//  aadd( aRot , { 'Telegrama' , 'alert( "Telegrama" )' , 0 , 3 , 0 , NIL } )
    aadd( aRot , { 'Telegrama' , 'u_teleg000()        ' , 0 , 3 , 0 , NIL } )

return aRot

// --------------------------------------------------------
// [ fim de mdta0051.prw ]
// --------------------------------------------------------
