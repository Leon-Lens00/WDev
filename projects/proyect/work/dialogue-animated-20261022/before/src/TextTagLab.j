// Isolated visual experiment. Five persistent texttags, never one per letter.
library TextTagLab initializer Init requires UserInterface, TextTagCases
globals
 private Camera Cam
 private UIText Title
 private UIText Info
 private UIText Body
 private UIText Footer
 private UIText Marker
 private integer Page = -1
 private integer TickIndex = 0
 private timer Clock = CreateTimer()
endglobals
private function Dump takes string suffix returns nothing
 call PreloadGenClear()
 call PreloadGenStart()
 call Preload("case="+I2S(Page)+" name="+LabName[Page]+" expectedBytes="+I2S(LabBytes[Page])+" nativeStringLength="+I2S(StringLength(LabText[Page]))+" size="+R2S(LabFont[Page]))
 call Preload("eye="+R2S(GetCameraEyePositionX())+","+R2S(GetCameraEyePositionY())+","+R2S(GetCameraEyePositionZ())+" tagCount="+I2S(UIText.CountShow))
 call PreloadGenEnd("Logs\\TextTagLab-"+I2S(Page)+suffix+".txt")
endfunction
private function Next takes nothing returns nothing
 set Page = Page+1
 set TickIndex = 0
 if Page == LAB_COUNT then
  call SetTextTagText(Title.text,"TEXTTAG LAB: COMPLETE",0.034)
  call SetTextTagText(Info.text,"All cases captured; this label does not certify visual results.",0.020)
  call SetTextTagText(Body.text,"",0.020)
  set Page = LAB_COUNT-1
  call Dump("-complete")
  call PauseTimer(Clock)
  return
 endif
 call SetTextTagText(Title.text,"TEXTTAG LAB "+I2S(Page+1)+" / "+I2S(LAB_COUNT),0.034)
 call SetTextTagText(Info.text,LabName[Page]+"  size="+R2S(LabFont[Page])+"  bytes="+I2S(LabBytes[Page]),0.020)
 call SetTextTagText(Body.text,LabText[Page],LabFont[Page])
 if LabTyping[Page] then
  call SetTextTagText(Body.text,"",LabFont[Page])
 endif
 call Dump("")
endfunction
private function Tick takes nothing returns nothing
 call Cam.applyCameraForPlayer(Player(0),true)
 call UIText.updateAll()
 set TickIndex = TickIndex+1
 if LabTyping[Page] then
  if TickIndex*2 <= LAB_TYPE_LENGTH then
   call SetTextTagText(Body.text,LabPrefix[TickIndex*2],LabFont[Page])
  else
   call SetTextTagText(Body.text,LabText[Page],LabFont[Page])
  endif
 endif
 if TickIndex >= 80 then
  call Next()
 endif
endfunction
private function Start takes nothing returns nothing
 set Cam = Camera.create()
 call Cam.setPosition(0,0,UserInterface_GetTerrainZ(0,0))
 call Cam.applyCameraForPlayer(Player(0),true)
 call ShowInterface(false,0)
 call EnableUserUI(true)
 call SetTimeOfDay(0)
 set Title = UIText.create(-1.20,0.92,1)
 set Info = UIText.create(-1.20,0.78,1)
 set Body = UIText.create(-1.20,-0.65,1)
 set Footer = UIText.create(-1.20,-0.96,1)
 set Marker = UIText.create(1.00,-0.65,1)
 call SetTextTagPermanent(Title.text,true)
 call SetTextTagPermanent(Info.text,true)
 call SetTextTagPermanent(Body.text,true)
 call SetTextTagPermanent(Footer.text,true)
 call SetTextTagPermanent(Marker.text,true)
 call SetTextTagColor(Title.text,255,255,255,255)
 call SetTextTagColor(Info.text,255,255,255,255)
 call SetTextTagColor(Body.text,255,32,192,255)
 call SetTextTagColor(Footer.text,255,255,255,255)
 call SetTextTagColor(Marker.text,32,255,255,255)
 call SetTextTagText(Footer.text,"One body tag. FIN is the end marker. Auto case: 8 seconds.",0.017)
 call SetTextTagText(Marker.text,"|",0.020)
 call Title.show(true,Cam)
 call Info.show(true,Cam)
 call Body.show(true,Cam)
 call Footer.show(true,Cam)
 call Marker.show(true,Cam)
 call Next()
 call TimerStart(Clock,0.10,true,function Tick)
 call DestroyTimer(GetExpiredTimer())
endfunction
private function Init takes nothing returns nothing
 call TimerStart(CreateTimer(),2.0,false,function Start)
endfunction
endlibrary
