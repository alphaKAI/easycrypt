module easycrypt.easycrypt;
import std.algorithm,
       std.random,
       std.string,
       std.array,
       std.stdio,
       std.regex,
       std.range,
       std.file,
       std.conv;

class EasyCrypt{
  private{
    string baseName;
    string keyFile;
    ubyte[] keyData;
  }

  this(string argBaseName, ubyte[] argKeyData){
    keyData = argKeyData;
    this(argBaseName);
  }

  this(string argBaseName, string keyFilePath){
    keyData = loadKeyFile(keyFilePath);

    this(argBaseName);
  }

  this(string argBaseName){
    baseName = argBaseName;

    if(keyData == null){
      string keyName;
      if(baseName.match(regex(r"\.encrypt")))
        keyName = baseName.replace(regex(r"\.encrypt"), "");
      else
        keyName = baseName;
      keyName ~= ".key";

      if(!exists(keyName)){
        writeln("Key file does not exist -> create key file");

        foreach(e; keyGen)
          writeFile(keyName, e);

        writeln("Key file :", keyName);
      } else 
        writeln("Load key file - ", keyName);

      keyData = loadKeyFile(keyName);
    }
  }

  void encrypt(){
    auto buf = rawRead(baseName);

    magic(buf, keyData);
    
    rawWrite(baseName ~ ".encrypt", buf);
  }

  void decrypt(){
    auto buf = rawRead(baseName);

    magic(buf, keyData);
    string output;
    if(baseName.match(regex(r"\.encrypt")))
      output = baseName.replace(regex(r"\.encrypt"), "");
    else
      output = baseName ~ ".decrypt";
    
    writeln(output);
    rawWrite(output, buf);
  }

  private{
    void magic(ubyte[] data, ubyte[] argKeyData){
      ubyte[] keyData = argKeyData;

      foreach(pr; keyData)
        foreach(ref e; data)
          e ^= pr;
    }

    string[] keyGen(){
      string[] key;
      Mt19937 mt;
      immutable keyLength = 1024;

      foreach(i; keyLength.iota){
        mt.seed(unpredictableSeed);
        key ~= mt.front.to!string ~ ",";
      }

      key[$ - 1] = key[$ - 1].removechars(",");

      return key;
    }

    ubyte[] loadKeyFile(string keyFilePath){
      return File(keyFilePath, "r").byLine
              .map!chomp
              .join
              .split(",")
              .map!(e => e.removechars(" "))
              .map!(e => cast(ubyte)e.to!ulong).array;
    }

    void writeFile(string fileName, string text, string mode = "d"){
      if(mode == "d")
        mode = "a";
      File(fileName, mode).writeln(text);
    }

    void rawWrite(string fileName, ubyte[] data){
      auto file = File(fileName, "wb");
      file.rawWrite(data);
    }

    ubyte[] rawRead(string fileName){
      auto file = File(fileName, "rb");
      ubyte[] buf;
      
      buf.length = cast(uint)file.size;
      file.rawRead(buf);

      return buf;
    }
  }
}

