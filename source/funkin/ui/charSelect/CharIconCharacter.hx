package funkin.ui.charSelect;

import openfl.display.BitmapData;
import openfl.filters.DropShadowFilter;
import openfl.filters.ConvolutionFilter;
import funkin.graphics.shaders.StrokeShader;

@:nullSafety
class CharIconCharacter extends CharIcon
{
  var matrixFilter:Array<Float> = [
    1, 1, 1,
    1, 1, 1,
    1, 1, 1
  ];

  var divisor:Int = 1;
  var bias:Int = 0;

  public function new(path:String)
  {
    super(0, 0, false);

    loadGraphic(Paths.image('freeplay/icons/' + path + 'pixel'));
    setGraphicSize(128, 128);
    updateHitbox();
    antialiasing = false;
  }
}
