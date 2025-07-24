# SkyrimNet_Aroused
basic SkyrimNet ASO 
~~~
; ---------------------
; Arousal
; ---------------------
Function RegisterActions
  ;----------------
    ; This is for dialogue driven arousal, so should happen during sex
    ;----------------
    int amount_value = GetArousal_AmountValues()
    String[] amounts = JMap.allKeysPArray(amount_value)
    i = amounts.length - 1
    String amounts_str = ""
    while 0 <= i 
        if amounts_str != ""
            amounts_str += "|"
        endif 
        amounts_str += amounts[i]
        i -= 1
    endwhile

    SkyrimNetApi.RegisterAction("ArousalIncrease", \
            "sexual arousal increased by a {how_much} amount",\
            "SkyrimNet_SexLab_Actions", "SexTarget_IsEligible",  \
            "SkyrimNet_SexLab_Actions", "ArousalIncrease_Execute",  \
            "", "PAPYRUS", 1, \
            "{\"how_much\":\""+amounts_str+"\"}")
EndFunction

int Function GetArousal_AmountValues() global
    int amount_value = JMap.object()
    JMap.setFlt(amount_value,"tiny",1.0)
    JMap.setFlt(amount_value,"small",5.0)
    JMap.setFlt(amount_value,"medium",10.0)
    JMap.setFlt(amount_value,"large",15.0)
    JMap.setFlt(amount_value,"enourmous",20.0)
    JMap.setFlt(amount_value,"gigantic",25.0)
    return amount_value
EndFunction

Function ArousalIncrease_Execute(Actor akActor, string contextJson, string paramsJson) global
    String amount = SkyrimNetApi.GetJsonString(paramsJson, "how_much","tiny")
    int amount_value = GetArousal_AmountValues()
    float value = JMap.getFlt(amount_value,amount)
    Trace("ArousalIncrease_Execute: "+paramsJson+" amount:"+amount+" value:"+value)
    OSLAroused_ModInterface.MOdifyArousal(target=akActor, value=value, reason="dailogue")
EndFunction
~~~

~~~
Function RegisterDecorators()
    SkyrimNetApi.RegisterDecorator("sexlab_get_arousal", "SkyrimNet_SexLab_Decorators", "Get_Arousal")
EndFunction


String Function Get_Arousal(Actor akActor) global
    Debug.Trace("[SkyrimNet_SexLab] Get_Arousal called for "+akActor.GetDisplayName())

    int arousal = -1

    ; Form api = Game.GetFormFromFile(0x00000D61, "DiaryOfMine.esm")
    ; if api != None 
    ;    DOM_Actor slave = (api as DOM_API).GetDOMActor(akActor)
    ;    if slave != None 
    ;        arousal = slave.mind.arousal_factor as Int
    ;    endif 
    ;endif 

    if arousal == -1
        slaFrameworkScr sla = Game.GetFormFromFile(0x4290F, "SexLabAroused.esm") as slaFrameworkScr
        if sla == None
            Debug.Notification("[SkyrimNet_SexLab] Get_Arousal: slaFrameworkScr is None")
        else
            arousal =  sla.GetActorArousal(akActor)
        endif
    endif 
    return "{\"arousal\":"+arousal+"}"
EndFunction
~~~

~~~
{% if not isTimePaused %}
{% set arousal = sexlab_get_arousal(npc.UUID) %} 
- {{ decnpc(npc.UUID).name }}'s arousal is {{ arousal.arousal -}}% {%
    if arousal.arousal < 20 %} (doesn't want sex) {%
    else if arousal.arousal < 40 %} (would enjoy sex) {%
    else if arousal.arousal < 60 %} (wants sex) {%
    else if arousal.arousal < 80 %} (will ask for sex) {%
                            else %} (will beg for sex) {%endif%}
{% endif %}
~~~
