using War3Net.IO.Mpq;

namespace Wc3.GameData;

/// <summary>Select Classic MPQ storage only for an actual MPQ installation.
/// Existing CASC installations retain their reader.</summary>
public static class InstalledGameDataSource
{
    public static bool TryOpen(string dir, out IGameDataSource? source, out string? error)
    {
        source = null; error = null;
        try
        {
            if (Directory.EnumerateFiles(dir).Any(p => Path.GetFileName(p).Equals("war3.mpq", StringComparison.OrdinalIgnoreCase)))
            {
                source = new ClassicMpqGameDataSource(dir);
                return true;
            }
            if (!CascGameDataSource.TryOpen(dir, out var casc, out error)) return false;
            source = casc;
            return true;
        }
        catch (Exception ex) { error = ex.Message; return false; }
    }

    public static IEnumerable<string> EnumerateFileNames(IGameDataSource source) => source switch
    {
        ClassicMpqGameDataSource mpq => mpq.EnumerateFileNames(),
        CascGameDataSource casc => casc.EnumerateFileNames(),
        _ => Array.Empty<string>(),
    };
}

/// <summary>Read-only Classic archives, newest patch first. MPQ names are
/// case-insensitive; installed filenames are resolved case-insensitively too.</summary>
public sealed class ClassicMpqGameDataSource : IGameDataSource
{
    private readonly List<MpqArchive> _archives = new();
    private readonly object _gate = new();

    public ClassicMpqGameDataSource(string dir)
    {
        var files = Directory.EnumerateFiles(dir).ToDictionary(p => Path.GetFileName(p)!, StringComparer.OrdinalIgnoreCase);
        if (!files.ContainsKey("war3.mpq")) throw new FileNotFoundException("Classic war3.mpq not found");
        try
        {
            foreach (var name in new[] { "War3Patch.mpq", "War3xlocal.mpq", "War3x.mpq", "war3.mpq" })
                if (files.TryGetValue(name, out var file))
                    _archives.Add(MpqArchive.Open(file, loadListFile: true));
        }
        catch { Dispose(); throw; }
    }

    public byte[]? ReadFile(string name)
    {
        // GameData's callers use CASC layer-qualified names; Classic stores the
        // same base/editor files without these layer prefixes.
        name = name[(name.LastIndexOf(':') + 1)..].Replace('/', '\\');
        if (string.IsNullOrWhiteSpace(name) || name.StartsWith('\\') || name.Split('\\').Any(p => p is ".." or "."))
            return null;
        lock (_gate)
        {
            foreach (var archive in _archives)
            {
                Stream stream;
                try { stream = archive.OpenFile(name); }
                catch (FileNotFoundException) { continue; }
                // Read failures in a newer archive must not silently fall back
                // to older data. They remain visible as diagnostics upstream.
                using (stream)
                using (var buffer = new MemoryStream())
                {
                    stream.CopyTo(buffer);
                    return buffer.ToArray();
                }
            }
        }
        return null;
    }

    public IEnumerable<string> EnumerateFileNames()
    {
        lock (_gate)
            return _archives.SelectMany(a => a).Select(e => e.FileName)
                .Where(n => !string.IsNullOrEmpty(n)).Select(n => "war3.w3mod:" + n)
                .Distinct(StringComparer.OrdinalIgnoreCase).ToArray();
    }

    public void Dispose()
    {
        foreach (var archive in _archives) archive.Dispose();
        _archives.Clear();
    }
}
