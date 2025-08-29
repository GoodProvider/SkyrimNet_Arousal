Scriptname SkyrimNet_Arousal_Main extends Quest

String[] amount_labels = None
int[]  amount_values = None

int debug_key = 40 
bool debug_on = false

Function Trace(String msg, Bool notification=False) global
    msg = "[SkyrimNet_Arousal] "+msg
    Debug.Trace(msg)
    if notification
        Debug.Notification(msg)
    endif 
EndFunction

Event OnInit()
    Trace("OnInit")

    ;if debug_on 
    ;    registerforkey(debug_key)
    ;else 
    ;    unregisterforkey(debug_key)
    ;endif

    amount_labels = new String[5]
    amount_values = new int[5]
    amount_labels[0] = "tiny"
    amount_labels[1] = "small"
    amount_labels[2] = "medium"
    amount_labels[3] = "large"
    amount_labels[4] = "huge"

    Setup() 
EndEvent

Function Setup()
    Trace("Setup", true)
    amount_values[0] = 1
    amount_values[1] = 5
    amount_values[2] = 10
    amount_values[3] = 15
    amount_values[4] = 25
    RegisterActions()
EndFunction

int function GetAmountValue(String label)
    int i = amount_labels.length - 1
    while 0 < i && amount_labels[i] != label
        i -= 1  
    endwhile 
    return amount_values[i]
EndFunction

; ---------------------
; Arousal
; ---------------------
Function RegisterActions()
    Trace("RegisterActions",true)
    ;----------------
    ; This is for dialogue driven arousal, so should happen during sex
    ;----------------
    int i = 0
    int count = amount_labels.length
    String labels_str = ""
    while i < count
        if labels_str > 0
            labels_str += "|"
        endif 
        labels_str += amount_labels[i]
        i += 1
    endwhile

    SkyrimNetApi.RegisterAction("ArousalChange", \
            "{{npc.name}}'s sexual arousal {direction} by a {how_much} amount.",\
            "SkyrimNet_Arousal_Main", "IsEligible",  \
            "SkyrimNet_Arousal_Main", "Change",  \
            "", "PAPYRUS", 1, \
            "{\"how_much\":\""+labels_str+"\",\"direction\":\"increases|decreases\"}")
    Trace("Registered ArousalChange action with labels: "+labels_str)
EndFunction

Bool Function IsEligible(Actor akActor, string contextJson, string paramsJson) global
    ; Check if the bridge code is loaded 
    Trace("IsEligible: "+akActor.GetDisplayName())
    Faction sla_arousal = Game.GetFormFromFile(0x3FC36, "SexLabAroused.esm") as Faction
    if sla_arousal == None
        Trace("IsEligible: SexLabAroused.esm not loaded, cannot check arousal", True)
        return false
    endif
    int amount_value = akActor.GetFactionRank(sla_arousal)
    if amount_value < 0
        Trace("IsEligible: Actor "+akActor.GetDisplayName()+" is untracked, cannot change")
        return false
    endif
    Trace("IsEligible: "+akActor.GetDisplayName()+" amount_value "+amount_value)
    return amount_value >= 0
EndFunction

Event OnKeyDown(int keyCode)
    if keyCode == debug_key
        Actor target = Game.GetCurrentCrosshairRef() as Actor 
        if target != None 
            Change(target, "", "{\"how_much\":\"huge\",\"direction\":\"increases\"}")
        endif 
    endif
EndEvent 

Function Change(Actor akActor, string contextJson, string paramsJson) global
    slaFrameworkScr framework = Game.GetFormFromFile(0x104290F, "SexLabAroused.esm") as slaFrameworkScr
    if framework == None
        Trace("Change: SexLabArounsed not loaded, cannot change arousal", True)
        return
    endif
    SkyrimNet_Arousal_Main main = Game.GetFormFromFile(0x800, "SkyrimNet_Arousal.esp") as SkyrimNet_Arousal_Main
    String label = SkyrimNetApi.GetJsonString(paramsJson, "how_much","tiny")
    int value = main.GetAmountValue(label)

    String direction = SkyrimNetApi.GetJsonString(paramsJson, "direction","increases")
    if direction != "increases"
        value *= -1 
    endif
    value += framework.GetActorExposure(akActor)

    Faction sla_arousal = Game.GetFormFromFile(0x3FC36, "SexLabAroused.esm") as Faction
    framework.SetActorExposure(akActor, value)
    Trace("ArousalIncrease_Execute: "+paramsJson+" label:"+label+" direction:"+direction+" value:"+value)
EndFunction
