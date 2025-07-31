Scriptname SkyrimNet_Arousal_Main extends Quest

String[] amount_labels = None
int[]  amount_values = None

Function Trace(String msg, Bool notification=False) global
    msg = "[SkyrimNet_Arousal] "+msg
    Debug.Trace(msg)
    if notification
        Debug.Notification(msg)
    endif 
EndFunction

Event OnInit()
    Trace("OnInit")

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
    Trace("Setup")
    RegisterActions()
    amount_values[0] = 1
    amount_values[1] = 5
    amount_values[2] = 10
    amount_values[3] = 15
    amount_values[4] = 20
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
    Trace("RegisterActions")
    ;----------------
    ; This is for dialogue driven arousal, so should happen during sex
    ;----------------
    int i = 0
    int count = amount_labels.length - 1
    String labels_str = ""
    while i < count
        if labels_str > 0
            labels_str += "|"
        endif 
        labels_str += amount_labels[i]
        i += 1
    endwhile

    SkyrimNetApi.RegisterAction("ArousalChange", \
            "sexual arousal {direction} by a {how_much} amount",\
            "SkyrimNet_Arousal_Main", "IsEligible",  \
            "SkyrimNet_Arousal_Main", "Change",  \
            "", "PAPYRUS", 1, \
            "{\"how_much\":\""+labels_str+"\",\"direction\":\"increases|decreases\"}")
EndFunction

Bool Function IsEligible(Actor akActor, string contextJson, string paramsJson) global
    ; Check if the bridge code is loaded 
    Quest plugin = Game.GetFormFromFile(0x9905F, "SexLabAroused.esm") as Quest
    if plugin == None
        return false
    endif
    Faction sla_arousal = Game.GetFormFromFile(0x3FC36, "SexLabAroused.esm") as Faction
    if sla_arousal == None
        Debug.MessageBox("IsEligible: SexLabAroused.esm not loaded, cannot check arousal")
        return false
    endif
    int amount_value = akActor.GetFactionRank(sla_arousal)
    return amount_value >= 0
EndFunction

Function Change(Actor akActor, string contextJson, string paramsJson) global
    SkyrimNet_Arousal_Main main = Game.GetFormFromFile(0x800, "SkyrimNet_Arousal.esp") as SkyrimNet_Arousal_Main
    Trace("Arousal_Change: "+paramsJson,true)
    String label = SkyrimNetApi.GetJsonString(paramsJson, "how_much","tiny")
    int value = main.GetAmountValue(label)

    String direction = SkyrimNetApi.GetJsonString(paramsJson, "direction","increases")
    if direction != "increases"
        value = -value  
    endif
    Trace("ArousalIncrease_Execute: "+paramsJson+" label:"+label+" direction:"+direction+" value:"+value)
    OSLAroused_ModInterface.ModifyArousal(target=akActor, value=value, reason="dailogue")
EndFunction
