-- Complete SNES execution. One-time equipment preparation; thereafter inputs and observation only.
local cfg=LAB_CONFIG
local frame=0
local gap=cfg.gap or 12
local loaded=false
local prepared=false
local streams={}
local function file(name,mode)
 local f=assert(io.open(cfg.out..'/'..name,mode or 'w'));streams[#streams+1]=f;return f
end
local events=file('events.csv');events:write('frame,native_frame,master_clock,event,dp,alive,id,subtype,state,substate,x_px,y_px,vx,vy_up,ax_byte,ay_byte\n')
local frames=file('frames.csv');frames:write('frame,native_frame,master_clock,player_x,player_y,charge,charge2,stored_second,pc,armor,lock,camera_x,camera_y\n')
local inputs=file('inputs.csv');inputs:write('frame,y,left,right\n')
local mem=emu.memType.snesWorkRam
local function r(a)return emu.read(a,mem) end
local function w(a,b)emu.write(a,b,mem) end
local function u16(a)return r(a)+256*r(a+1) end
local function signed(v,n)if v>=2^(n-1) then return v-2^n else return v end end
local function point(a)return u16(a+1)+r(a)/256 end
local function screenshot(name)
 local f=file(name,'wb');f:write(emu.takeScreenshot());f:close()
end
local function log_event(name,dp,state)
 if dp<0x0c98 or dp>=0x1398 then return end
 local id=r(dp+10)
 if id~=0x1d and id~=0x1f and id~=0x20 and id>3 then return end
 state=state or emu.getState()
 events:write(string.format('%d,%d,%d,%s,%d,%d,%d,%d,%d,%d,%.8f,%.8f,%.8f,%.8f,%d,%d\n',frame,state.frameCount,state.masterClock,name,dp,r(dp),id,r(dp+11),r(dp+1),r(dp+2),point(dp+4),point(dp+7),signed(u16(dp+0x1a),16)/256,signed(u16(dp+0x1c),16)/256,signed(r(dp+0x1f),8),signed(r(dp+0x1e),8)))
end
local function hook(addr,name)
 for _,a in ipairs({addr,addr+0x800000}) do
  emu.addMemoryCallback(function()
   if loaded and prepared then local st=emu.getState();log_event(name,st['cpu.d'],st) end
  end,emu.callbackType.exec,a,a,emu.cpuType.snes)
 end
end
hook(0x01c0e8,'helix_entry')
hook(0x01c1f5,'helix_after')
hook(0x01c30b,'helix_child_after')
hook(0x01c193,'merge_check')
hook(0x01c198,'merge_detected')
hook(0x01c49d,'emit_combined')
hook(0x01c5a6,'combined_init')
hook(0x01c5db,'combined_init_end')
hook(0x01c610,'combined_before')
hook(0x01c62e,'combined_after')
hook(0x01905f,'pulse_before')
hook(0x019063,'pulse_after')
local function load_ready()
 if not loaded then
  local f=assert(io.open(cfg.state,'rb'));local bytes=f:read('*a');f:close()
  loaded=true;emu.loadSavestate(bytes)
  local f2=file('loaded-state.txt');f2:write(cfg.state..'\n'..#bytes..' bytes\n');f2:close()
 end
end
emu.addMemoryCallback(load_ready,emu.callbackType.exec,0x008000,0x008000,emu.cpuType.snes)
emu.addEventCallback(function()
 if not loaded then return end
 if not prepared then
  -- Equipment flag only. Physics, charge counters, object states and timing are untouched.
  local a=r(0x1fd1);w(0x1fd1,a|2)
  local f=file('equipment-preparation.txt');f:write(string.format('1FD1: %02X -> %02X\n',a,a|2))
  if cfg.variant=='mod' then local m=r(0xf418);w(0xf418,m|2);f:write(string.format('F418: %02X -> %02X\n',m,m|2)) end
  f:close();prepared=true
 end
 local input={a=false,b=false,x=false,y=false,l=false,r=false,up=false,down=false,left=false,right=false,select=false,start=false}
 input.y=(frame>=30 and frame<450) or (frame>=450+gap and frame<452+gap)
 input.left=(cfg.facing=='left' and frame>=10 and frame<12)
 assert(emu.getInput(0).y~=nil,'SNES controller missing')
 inputs:write(string.format('%d,%d,%d,0\n',frame,input.y and 1 or 0,input.left and 1 or 0))
 emu.setInput(input,0)
end,emu.eventType.inputPolled)
emu.addEventCallback(function()
 if not loaded then return end
 frame=frame+1
 local st=emu.getState()
 frames:write(table.concat({frame,st.frameCount,st.masterClock,point(0x9dc),point(0x9df),r(0xa30),r(0xa66),r(0xa67),r(0xa8e),r(0x1fd1),r(0x1f3f),u16(0x1e5d),u16(0x1e60)},',')..'\n')
 for dp=0x0d18,0x1358,0x40 do if r(dp)~=0 then log_event('frame',dp,st) end end
 if frame==1 or frame==200 or frame==440 or frame==470 or frame==500 or frame==560 then screenshot(string.format('screen-%04d.png',frame)) end
 if frame>=440 and frame<=600 then screenshot(string.format('video-%04d.png',frame-440)) end
 if frame==640 then
  local f=file('complete.txt');f:write('640 frames after independent per-ROM scene state; input-only firing after one-time equipment flags\n');f:close()
  for _,s in ipairs({events,frames,inputs})do s:flush();s:close() end
  emu.stop(0)
 end
end,emu.eventType.endFrame)
