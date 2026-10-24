using System;
using System.Text;
using System.Runtime.InteropServices;
class EditorMenuProbe {
 [DllImport("user32.dll")] static extern IntPtr GetMenu(IntPtr w);
 [DllImport("user32.dll")] static extern IntPtr GetSubMenu(IntPtr m,int i);
 [DllImport("user32.dll")] static extern int GetMenuItemCount(IntPtr m);
 [DllImport("user32.dll")] static extern uint GetMenuItemID(IntPtr m,int i);
 [DllImport("user32.dll",CharSet=CharSet.Ansi)] static extern int GetMenuStringA(IntPtr m,uint i,StringBuilder s,int n,uint flags);
 [DllImport("user32.dll")] static extern uint GetWindowThreadProcessId(IntPtr w,out uint pid);
 [DllImport("user32.dll")] static extern bool PostMessageA(IntPtr w,uint msg,IntPtr a,IntPtr b);
 [DllImport("user32.dll")] static extern bool SetForegroundWindow(IntPtr w);
 [DllImport("user32.dll")] static extern IntPtr GetForegroundWindow();
 [DllImport("user32.dll")] static extern void keybd_event(byte key,byte scan,uint flags,UIntPtr extra);
 delegate bool EnumProc(IntPtr w,IntPtr l);
 [DllImport("user32.dll")] static extern bool EnumChildWindows(IntPtr w,EnumProc p,IntPtr l);
 [DllImport("user32.dll",CharSet=CharSet.Ansi)] static extern int GetClassNameA(IntPtr w,StringBuilder s,int n);
 [DllImport("user32.dll",CharSet=CharSet.Ansi)] static extern int GetWindowTextA(IntPtr w,StringBuilder s,int n);
 [DllImport("user32.dll")] static extern int GetDlgCtrlID(IntPtr w);
 static string Info(IntPtr w) {var c=new StringBuilder(256);var t=new StringBuilder(512);GetClassNameA(w,c,256);GetWindowTextA(w,t,512);return w.ToInt64().ToString("X")+" "+c+" id="+GetDlgCtrlID(w)+" "+t;}
 [DllImport("kernel32.dll")] static extern IntPtr OpenProcess(uint rights,bool inherit,uint pid);
 [DllImport("kernel32.dll")] static extern IntPtr VirtualAllocEx(IntPtr p,IntPtr a,UIntPtr n,uint type,uint prot);
 [DllImport("kernel32.dll")] static extern bool VirtualFreeEx(IntPtr p,IntPtr a,UIntPtr n,uint type);
 [DllImport("kernel32.dll")] static extern bool ReadProcessMemory(IntPtr p,IntPtr a,byte[] b,UIntPtr n,out UIntPtr read);
 [DllImport("kernel32.dll")] static extern bool CloseHandle(IntPtr p);
 [DllImport("user32.dll")] static extern IntPtr SendMessageA(IntPtr w,uint msg,IntPtr a,IntPtr b);
 static void Toolbar(IntPtr w,uint pid) {var p=OpenProcess(0x38,false,pid);var remote=VirtualAllocEx(p,IntPtr.Zero,new UIntPtr(4096),0x3000,4);try {
   int n=SendMessageA(w,0x418,IntPtr.Zero,IntPtr.Zero).ToInt32();Console.WriteLine("TOOLBAR "+w+" buttons="+n);
   for(int i=0;i<n && i<100;i++){SendMessageA(w,0x417,new IntPtr(i),remote);var b=new byte[20];UIntPtr read;ReadProcessMemory(p,remote,b,new UIntPtr(20),out read);int id=BitConverter.ToInt32(b,4);int count=SendMessageA(w,0x42d,new IntPtr(id),remote).ToInt32();string text="";if(count>0 && count<4095){var z=new byte[count];ReadProcessMemory(p,remote,z,new UIntPtr((uint)count),out read);text=Encoding.Default.GetString(z);}Console.WriteLine("button "+i+" bitmap="+BitConverter.ToInt32(b,0)+" command="+id+" text="+text);}
  }finally{VirtualFreeEx(p,remote,UIntPtr.Zero,0x8000);CloseHandle(p);}}
 static void List(IntPtr m,string prefix) {
  for(int i=0;i<GetMenuItemCount(m);i++) {var s=new StringBuilder(512);GetMenuStringA(m,(uint)i,s,512,0x400);uint id=GetMenuItemID(m,i);Console.WriteLine(prefix+i+" id="+id+" "+s);var child=GetSubMenu(m,i);if(child!=IntPtr.Zero)List(child,prefix+i+"/");}
 }
 static int Main(string[] a) {
  var w=new IntPtr(Convert.ToInt64(a[0],16));uint pid;GetWindowThreadProcessId(w,out pid);if(pid!=UInt32.Parse(a[1]))throw new Exception("HWND process changed");
  if(a.Length>2 && a[2]=="info") {Console.WriteLine("MAIN "+Info(w)+" menu="+GetMenu(w)+" FOREGROUND "+Info(GetForegroundWindow()));EnumChildWindows(w,delegate(IntPtr c,IntPtr l){Console.WriteLine(Info(c));return true;},IntPtr.Zero);
  } else if(a.Length>2 && a[2]=="toolbar") {EnumChildWindows(w,delegate(IntPtr c,IntPtr l){var text=new StringBuilder(256);GetClassNameA(c,text,256);if(text.ToString()=="ToolbarWindow32")Toolbar(c,pid);return true;},IntPtr.Zero);
  } else if(a.Length>2 && a[2]=="savekeys") {
   SetForegroundWindow(w);System.Threading.Thread.Sleep(200);if(GetForegroundWindow()!=w)throw new Exception("Wrong foreground window");
   keybd_event(17,0,0,UIntPtr.Zero);keybd_event(83,0,0,UIntPtr.Zero);System.Threading.Thread.Sleep(200);keybd_event(83,0,2,UIntPtr.Zero);keybd_event(17,0,2,UIntPtr.Zero);
  } else if(a.Length==2)List(GetMenu(w),"");else if(a[2]=="command")PostMessageA(w,0x111,new IntPtr(Int32.Parse(a[3])),a.Length>4?new IntPtr(Convert.ToInt64(a[4],16)):IntPtr.Zero);
  return 0;
 }
}
