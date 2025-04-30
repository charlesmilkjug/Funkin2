package source; // Yeah, I know...

import sys.io.File;

/**
 * A script which executes before the game is built.
 */
class Prebuild extends CommandLine
{
  static inline final BUILD_TIME_FILE:String = '.build_time';

  static final NG_CREDS_PATH:String = './source/funkin/api/newgrounds/NewgroundsCredentials.hx';

  static final NG_CREDS_TEMPLATE:String = "package funkin.api.newgrounds;

class NewgroundsCredentials
{
  public static final APP_ID:String = #if API_NG_APP_ID haxe.macro.Compiler.getDefine(\"API_NG_APP_ID\") #else 'INSERT APP ID HERE' #end;
  public static final ENCRYPTION_KEY:String = #if API_NG_ENC_KEY haxe.macro.Compiler.getDefine(\"API_NG_ENC_KEY\") #else 'INSERT ENCRYPTION KEY HERE' #end;
}";

  static function main():Void
  {
    saveBuildTime();

    CommandLine.prettyPrint('Building Funkin\'.. (${Sys.systemName})');

    buildCredsFile();

    var theProcess:Process = new Process('haxe --version');
    theProcess.exitCode(true);
    var haxer = theProcess.stdout.readLine();
    if (haxer != "4.3.6")
    {
      var curHaxe = [for (augh in haxer.split(".")) Std.parseInt(augh)];
      var dudeWanted = [4, 3, 6];
      for (bro in 0...dudeWanted.length)
      {
        if (curHaxe[bro] < dudeWanted[bro])
        {
          CommandLine.prettyPrint("-- !! W A R N I N G !! --");
          Sys.println("Your current Haxe version is outdated!");
          Sys.println('So, you\'re using ${haxer}, while the required version is 4.3.6.');
          Sys.println('The game has no guarantee of compiling with your current version.');
          Sys.println('So, we recommend upgrading to 4.3.6.');
          break;
        }
      }
    }

    Sys.println('This might take a while, just be patient.');
  }

  static function saveBuildTime():Void
  {
    var fo:sys.io.FileOutput = File.write(BUILD_TIME_FILE);
    var now:Float = Sys.time();
    fo.writeDouble(now);
    fo.close();
  }

  static function buildCredsFile():Void
  {
    #if sys
    if (sys.FileSystem.exists(NG_CREDS_PATH))
    {
      trace('NewgroundsCredentials.hx already exists, skipping.');
    }
    else
    {
      trace('Creating NewgroundsCredentials.hx...');

      var fileContents:String = NG_CREDS_TEMPLATE;

      sys.io.File.saveContent(NG_CREDS_PATH, fileContents);
    }
    #end
  }
}
