"""Render two observed SNES frame sequences at their measured emulated cadence."""
from pathlib import Path
import json,subprocess,hashlib
LAB=Path(__file__).resolve().parents[1]

def render_video():
    fps=json.loads((LAB/'analysis/native-comparison.json').read_text())['cases'][0]['fps']
    a=LAB/'runs/final-original-gap20/video-%04d.png';b=LAB/'runs/final-mod-gap20/video-%04d.png'
    out=LAB/'analysis/comparacion-original-zero-project.mp4'
    filters="[0:v]scale=768:717:flags=neighbor,pad=768:760:0:43:black,drawtext=text='Original USA':fontcolor=white:fontsize=25:x=20:y=8[o];[1:v]scale=768:717:flags=neighbor,pad=768:760:0:43:black,drawtext=text='Zero Project - IPS V4.1':fontcolor=white:fontsize=25:x=20:y=8[m];[o][m]hstack=inputs=2[v]"
    cmd=['ffmpeg','-y','-hide_banner','-loglevel','warning','-framerate',str(fps),'-start_number','0','-i',str(a),'-framerate',str(fps),'-start_number','0','-i',str(b),'-filter_complex',filters,'-map','[v]','-c:v','libx264','-crf','18','-pix_fmt','yuv420p','-movflags','+faststart',str(out)]
    result=subprocess.run(cmd,capture_output=True,text=True)
    (LAB/'analysis/video-encode-log.txt').write_text(result.stdout+result.stderr)
    assert result.returncode==0,result.stderr
    probe=subprocess.run(['ffprobe','-v','error','-show_format','-show_streams','-of','json',str(out)],capture_output=True,text=True,check=True)
    info=json.loads(probe.stdout);(LAB/'analysis/video-probe.json').write_text(probe.stdout)
    assert int(info['streams'][0]['nb_frames'])==161 and info['streams'][0]['codec_name']=='h264'
    sources={str(f.relative_to(LAB)):hashlib.sha256(f.read_bytes()).hexdigest() for folder in [a.parent,b.parent] for f in sorted(folder.glob('video-*.png'))}
    assert len(sources)==322
    receipt={'fps_measured':fps,'frames_per_variant':161,'same_input_timeline':True,'interpolation':False,'pixel_scale':3,'audio':False,'command':cmd,'output_sha256':hashlib.sha256(out.read_bytes()).hexdigest(),'source_frame_sha256':sources}
    (LAB/'analysis/video-receipt.json').write_text(json.dumps(receipt,indent=2))
    subprocess.run(['ffmpeg','-y','-hide_banner','-loglevel','error','-ss','1.2','-i',str(out),'-frames:v','1',str(LAB/'analysis/video-muestra.png')],check=True)
    print(out)

if __name__=='__main__':render_video()
