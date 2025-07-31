Scriptname SkyrimNet_Arousal_PlayerRef extends ReferenceAlias  

int Property actorLock = 0 Auto

SkyrimNet_Arousal_Main Property main Auto  

Event OnPlayerLoadGame()
    Debug.Trace("[SkyrimNet_Arousal] OnPlayerLoadGame called")
    main.Setup()
EndEvent