import subprocess,time
subprocess.run(['hyprctl','dispatch','hl.dsp.focus({window="address:0x55bb0733e500"})'],check=True)
subprocess.run(['hyprctl','dispatch','hl.dsp.cursor.move({x=3395,y=355})'],check=True)
subprocess.run(['ydotool','mousemove','--','0','1'],check=True);time.sleep(.25)
subprocess.run(['ydotool','click','-D','100','0xC0'],check=True)
print('MCP reload action clicked',flush=True)
