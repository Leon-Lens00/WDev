package main
import("flag";"fmt";"os";"github.com/StephenSHorton/wc3-forge/internal/terrainproc")
func main(){if e:=run();e!=nil{fmt.Fprintln(os.Stderr,e);os.Exit(1)}}
func run()error{
 f:=flag.NewFlagSet("terrain-landscape",flag.ContinueOnError)
 spec:=f.String("spec","","scene spec");out:=f.String("out","","output directory")
 if e:=f.Parse(os.Args[1:]);e!=nil{return e};s,e:=terrainproc.ReadSpec(*spec);if e!=nil{return e}
 return terrainproc.ProbeLandscape(s,*out)
}
