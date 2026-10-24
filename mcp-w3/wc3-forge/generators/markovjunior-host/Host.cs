using System;
using System.IO;
using System.Linq;
using System.Text;
using System.Text.Json;
using System.Xml.Linq;
using System.Collections.Generic;
using SixLabors.ImageSharp;
using SixLabors.ImageSharp.PixelFormats;

// Same assembly as the pinned MIT upstream sources; no reflection or reimplementation.
static class Host
{
    const string Revision = "42aaf24bcf54ae164fba49c0a59348297904a676+sample-bounds-v1";
    public class Request
    {
        public int Width { get; set; }
        public int Height { get; set; }
        public int Seed { get; set; }
        public int SampleWidth { get; set; }
        public int SampleHeight { get; set; }
        public int[] Sample { get; set; }
        public int[] Fixed { get; set; }
        public int[] Allowed { get; set; }
        public string Example { get; set; }
        public int Steps { get; set; } = 20000;
        public int Tries { get; set; } = 8;
    }
    sealed class Log : StringWriter
    {
        public override void WriteLine(string s) { if (s != null && !s.StartsWith("[")) base.WriteLine(s); }
    }
    static int Main(string[] args)
    {
        try
        {
            if (args.Length != 2) throw new Exception("Host request.json result.json");
            var options = new JsonSerializerOptions { PropertyNameCaseInsensitive = true, WriteIndented = true };
            var req = JsonSerializer.Deserialize<Request>(File.ReadAllText(args[0]), options);
            if (req.Width < 2 || req.Height < 2 || req.Width > 256 || req.Height > 256 || req.Steps < 1 || req.Steps > 100000 || req.Tries < 1 || req.Tries > 64) throw new Exception("Invalid bounded dimensions/steps/tries");
            var outputPath = Path.GetFullPath(args[1]);
            var log = new Log(); Console.SetOut(log);
            XElement model;
            int[] ordinals = null;
            byte[] initial = null;
            if (req.Example != null)
            {
                model = XDocument.Load(req.Example).Root;
            }
            else
            {
                if (req.SampleWidth < 2 || req.SampleHeight < 2 || req.SampleWidth > 256 || req.SampleHeight > 256 || req.Sample?.Length != req.SampleWidth * req.SampleHeight) throw new Exception("Invalid sample");
                ordinals = req.Sample.Distinct().ToArray(); // Match upstream bitmap.Ords first-seen ordering.
                if (ordinals.Length < 2 || ordinals.Length > 16) throw new Exception("Sample needs 2..16 semantic labels");
                if (req.Fixed != null && req.Fixed.Length != req.Width * req.Height) throw new Exception("Invalid fixed cells");
                if (req.Allowed != null && req.Allowed.Length != req.Width * req.Height) throw new Exception("Invalid allowed domains");
                Directory.CreateDirectory("resources/samples");
                using (var img = new Image<Rgba32>(req.SampleWidth, req.SampleHeight))
                {
                    for (int y = 0; y < req.SampleHeight; y++) for (int x = 0; x < req.SampleWidth; x++)
                    { int v = Array.IndexOf(ordinals, req.Sample[x+y*req.SampleWidth]); img[x,y] = new Rgba32((byte)(v*13+16),(byte)(v*7+20),(byte)(v*3+30),255); }
                    img.SaveAsPng("resources/samples/terrain.png");
                }
                string labels = new string(Enumerable.Range(0, ordinals.Length).Select(i=>(char)('A'+i)).ToArray());
                var wfc = new XElement("wfc",new XAttribute("sample","terrain"),new XAttribute("values",labels),new XAttribute("n",2),new XAttribute("tries",req.Tries),new XAttribute("periodicInput",true));
                foreach (char label in labels) wfc.Add(new XElement("rule",new XAttribute("in",label),new XAttribute("out",label)));
                int[] domains = req.Allowed == null ? Array.Empty<int>() : req.Allowed.Where(v=>v!=0).Distinct().ToArray();
                if (domains.Length>32) throw new Exception("Too many allowed domains");
                string domainLabels = new string(Enumerable.Range(0,domains.Length).Select(i=>(char)('a'+i)).ToArray());
                int knownMask=0;
                if(domains.Length>0) foreach(int v in ordinals) { if(v<0||v>15)throw new Exception("Domain labels must be 0..15"); knownMask|=1<<v; }
                for(int i=0;i<domains.Length;i++)
                {
                    int mask=domains[i];
                    if(mask<=0 || (mask & ~knownMask)!=0)throw new Exception("Domain contains absent labels");
                    string output=string.Join("|",Enumerable.Range(0,ordinals.Length).Where(v=>(mask & (1<<ordinals[v]))!=0).Select(v=>labels[v]));
                    wfc.Add(new XElement("rule",new XAttribute("in",domainLabels[i]),new XAttribute("out",output)));
                }
                model = new XElement("sequence",new XAttribute("values","?"+labels+domainLabels),wfc);
                initial = new byte[req.Width*req.Height];
                if(req.Allowed!=null)for(int i=0;i<initial.Length;i++)if(req.Allowed[i]!=0)initial[i]=(byte)(labels.Length+1+Array.IndexOf(domains,req.Allowed[i]));
                if (req.Fixed != null) for (int i=0;i<initial.Length;i++) if (req.Fixed[i]>=0)
                { int v=Array.IndexOf(ordinals,req.Fixed[i]); if(v<0)throw new Exception("Fixed label absent from sample"); if(req.Allowed!=null&&req.Allowed[i]!=0&&(req.Allowed[i]&(1<<req.Fixed[i]))==0)throw new Exception("Fixed label conflicts with domain"); initial[i]=(byte)(v+1); }
                File.WriteAllText(Path.ChangeExtension(outputPath,"xml"),model.ToString());
            }
            var ip = Interpreter.Load(model,req.Width,req.Height,1);
            if(ip==null)throw new Exception("Invalid MJ model: "+log);
            bool first=true;
            foreach(var frame in ip.Run(req.Seed,req.Steps,true))
            {
                if(first){if(initial!=null)Array.Copy(initial,frame.Item1,initial.Length);first=false;ip.gif=false;}
            }
            if(ip.current!=null)throw new Exception("MarkovJunior step budget exhausted");
            if(req.Example==null && !log.ToString().Contains("wfc found a good seed"))throw new Exception("WFC contradiction: "+log);
            var result = ip.grid.state.Select(v=>ordinals==null?(int)v:ordinals[v]).ToArray();
            if(req.Fixed!=null)for(int i=0;i<result.Length;i++)if(req.Fixed[i]>=0 && result[i]!=req.Fixed[i])throw new Exception("WFC violated a fixed cell");
            if(req.Allowed!=null)for(int i=0;i<result.Length;i++)if(req.Allowed[i]!=0&&(req.Allowed[i]&(1<<result[i]))==0)throw new Exception("WFC violated an allowed domain");
            File.WriteAllText(outputPath,JsonSerializer.Serialize(new {format="wc3-mj-result-v1",revision=Revision,seed=req.Seed,width=ip.grid.MX,height=ip.grid.MY,steps=ip.counter,states=result,diagnostics=log.ToString()},options));
            return 0;
        }
        catch(Exception e){Console.Error.WriteLine(e.Message);return 1;}
    }
}
