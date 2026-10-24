-- Observe complete ROM boot; only controller input, screenshots and RAM reads.
local out = LAB_CONFIG.out
local frame = 0
local checked_input = false
local pending_save = false
local function save(name, bytes)
 local f = assert(io.open(out..'/'..name, 'wb')); f:write(bytes); f:close()
end
local function snapshot()
 save(string.format('frame-%04d.png', frame), emu.takeScreenshot())
 local state = emu.getState(); local text = {}
 for k,v in pairs(state) do text[#text+1] = tostring(k)..'='..tostring(v) end
 table.sort(text);save(string.format('state-%04d.txt',frame),table.concat(text,'\n'))
 local bytes = {}
 for i=0,0x1fff do bytes[#bytes+1]=string.char(emu.read(i,emu.memType.snesWorkRam)) end
 save(string.format('ram-%04d.bin',frame),table.concat(bytes))
end
emu.addEventCallback(function()
 local input={a=false,b=false,x=false,y=false,l=false,r=false,up=false,down=false,left=false,right=false,select=false,start=false}
 -- Fixed boot/menu Start presses and B dialogue advances, established by inspected captures.
 if (frame>=900 and frame<902) or (frame>=1200 and frame<1202) or (frame>=1500 and frame<1502) or (frame>=1800 and frame<1802) then input.start=true end
 if not checked_input then
 local available=emu.getInput(0);assert(available.start ~= nil,'SNES controller missing');checked_input=true;save('controller.txt','SNES port 0 has start/y/directions\n')
 end
 if (frame>=4400 and frame<4402) or (frame>=4600 and frame<4602) or (frame>=4800 and frame<4802) or (frame>=5000 and frame<5002) then input.b=true end
 emu.setInput(input,0)
end, emu.eventType.inputPolled)
emu.addEventCallback(function()
 frame=frame+1
 if frame==4800 or frame==5200 or frame==5600 or frame==6000 then snapshot() end
 if frame==6000 then pending_save=true end
 if frame>6060 then save('complete.txt','scene reached but idle save hook not seen\n');emu.stop(3) end
end,emu.eventType.endFrame)

local function save_ready()
 if pending_save then
  pending_save=false
  save('ready.mss',emu.createSavestate())
  save('complete.txt','scene ready; savestate created inside CPU exec callback\n')
  emu.stop(0)
 end
end
emu.addMemoryCallback(save_ready,emu.callbackType.exec,0x008103,0x008103,emu.cpuType.snes)
emu.addMemoryCallback(save_ready,emu.callbackType.exec,0x808103,0x808103,emu.cpuType.snes)
