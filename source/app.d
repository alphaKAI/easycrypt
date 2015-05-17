/*
  EasyCrypt
  The easy encrypt/decrypt tool.

  Copyright (C) 2015 alphaKAI http://alpha-kai-net.info
  THE MIT LICENSE.
 */
import std.string,
       std.stdio,
       std.regex,
       std.file;
import easycrypt.easycrypt;

void main(string[] args){
  if(args.length < 3){
    writeln("Error");
    writeln("Usage : $ easycrypt -MODE <FILENAME> [option: keyFilePath]");
    writeln("MODE : ");
    writeln(" -e : encrypt");
    writeln(" -d : decrypt");
    return;
  }

  string baseName = args[2];
  if(!exists(baseName)){
    writeln("Error");
    writeln("File not found - ", baseName);
    return;
  }

  string keyFilePath;
  if(args.length == 4){
    if(!exists(args[3]))
      throw new Error("Key file not found - " ~ args[3]);

    keyFilePath = args[3];
  }

  EasyCrypt ec = keyFilePath != null ?
    new EasyCrypt(baseName, keyFilePath) : new EasyCrypt(baseName);

  switch(args[1]){
    case "-e":
      writeln(" -> Encrypt mode");
      writeln("original file   : ", baseName);
      writeln("encrypted  file : ", baseName ~ ".encrypt");

      ec.encrypt;

      writeln("Complete!");
      break;
    case "-d":
      writeln(" -> Decrypt mode");
      writeln("original file : ", baseName);
      writeln("decrypted  file : ", 
          baseName.match(regex(r"\.encrypt")) ? 
            baseName.replace(regex(r"\.encrypt"), "") : baseName ~ ".key");

      ec.decrypt;

      writeln("Complete!");
      break;
    default:
      writeln("Error");
      writeln("Invalid Option \"", args[1], "\"");
      break;
  }
}

