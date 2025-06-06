package funkin.ui.freeplay.backcards;

import funkin.ui.freeplay.FreeplayState;
import flixel.math.FlxMath;
import flixel.FlxSprite;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import funkin.graphics.adobeanimate.FlxAtlasSprite;
import funkin.ui.freeplay.charselect.PlayableCharacter;
import openfl.display.BlendMode;

@:nullSafety
class NewCharacterCard extends BackingCard
{
  var darkBg:FlxSprite;
  var lightLayer:FlxSprite;
  var multiply1:FlxSprite;
  var multiply2:FlxSprite;
  var lightLayer2:FlxSprite;
  var lightLayer3:FlxSprite;
  var yellow:FlxSprite;
  var multiplyBar:FlxSprite;

  public var friendFoe:BGScrollingText;
  public var newUnlock1:BGScrollingText;
  public var waiting:BGScrollingText;
  public var newUnlock2:BGScrollingText;
  public var friendFoe2:BGScrollingText;
  public var newUnlock3:BGScrollingText;

  public override function applyExitMovers(?exitMovers:FreeplayState.ExitMoverData, ?exitMoversCharSel:FreeplayState.ExitMoverData):Void
  {
    super.applyExitMovers(exitMovers, exitMoversCharSel);
    if (exitMovers == null || exitMoversCharSel == null) return;
    exitMovers.set([friendFoe],
      {
        x: FlxG.width * 2,
        speed: 0.4,
      });
    exitMovers.set([newUnlock1],
      {
        x: -newUnlock1.width * 2,
        y: newUnlock1.y,
        speed: 0.4,
        wait: 0
      });
    exitMovers.set([waiting],
      {
        x: FlxG.width * 2,
        speed: 0.4,
      });
    exitMovers.set([newUnlock2],
      {
        x: -newUnlock2.width * 2,
        speed: 0.5,
      });
    exitMovers.set([friendFoe2],
      {
        x: FlxG.width * 2,
        speed: 0.4
      });
    exitMovers.set([newUnlock3],
      {
        x: -newUnlock3.width * 2,
        speed: 0.3
      });

    exitMoversCharSel.set([friendFoe, newUnlock1, waiting, newUnlock2, friendFoe2, newUnlock3, multiplyBar], {
      y: -60,
      speed: 0.8,
      wait: 0.1
    });
  }

  public override function introDone():Void
  {
    darkBg.visible = friendFoe.visible = newUnlock1.visible = waiting.visible = newUnlock2.visible = friendFoe2.visible = newUnlock3.visible = multiplyBar.visible = lightLayer.visible = multiply1.visible = multiply2.visible = lightLayer2.visible = yellow.visible = lightLayer3.visible = cardGlow.visible = true;

    FlxTween.tween(cardGlow, {alpha: 0, "scale.x": 1.2, "scale.y": 1.2}, 0.45, {ease: FlxEase.sineOut});
  }

  public override function enterCharSel():Void
  {
    FlxTween.tween(friendFoe, {speed: 0}, 0.8, {ease: FlxEase.sineIn});
    FlxTween.tween(newUnlock1, {speed: 0}, 0.8, {ease: FlxEase.sineIn});
    FlxTween.tween(waiting, {speed: 0}, 0.8, {ease: FlxEase.sineIn});
    FlxTween.tween(newUnlock2, {speed: 0}, 0.8, {ease: FlxEase.sineIn});
    FlxTween.tween(friendFoe2, {speed: 0}, 0.8, {ease: FlxEase.sineIn});
    FlxTween.tween(newUnlock3, {speed: 0}, 0.8, {ease: FlxEase.sineIn});
  }

  public override function new(currentCharacter:PlayableCharacter)
  {
    super(currentCharacter);

    friendFoe = new BGScrollingText(0, 163, "COULD IT BE A NEW FRIEND? OR FOE??", FlxG.width, true, 43);
    newUnlock1 = new BGScrollingText(-440, 215, 'NEW UNLOCK!', FlxG.width / 2, true, 80);
    waiting = new BGScrollingText(0, 286, "SOMEONE'S WAITING!", FlxG.width / 2, true, 43);
    newUnlock2 = new BGScrollingText(-220, 331, 'NEW UNLOCK!', FlxG.width / 2, true, 80);
    friendFoe2 = new BGScrollingText(0, 402, 'COULD IT BE A NEW FRIEND? OR FOE??', FlxG.width, true, 43);
    newUnlock3 = new BGScrollingText(0, 458, 'NEW UNLOCK!', FlxG.width / 2, true, 80);
    darkBg = new FlxSprite(0, 0).loadGraphic(Paths.image('freeplay/backingCards/newCharacter/darkback'));
    multiplyBar = new FlxSprite(-10, 440).loadGraphic(Paths.image('freeplay/backingCards/newCharacter/multiplyBar'));
    lightLayer = new FlxSprite(-360, 230).loadGraphic(Paths.image('freeplay/backingCards/newCharacter/orange gradient'));
    multiply1 = new FlxSprite(-15, -125).loadGraphic(Paths.image('freeplay/backingCards/newCharacter/red'));
    multiply2 = new FlxSprite(-15, -125).loadGraphic(Paths.image('freeplay/backingCards/newCharacter/red'));
    lightLayer2 = new FlxSprite(-360, 230).loadGraphic(Paths.image('freeplay/backingCards/newCharacter/orange gradient'));
    yellow = new FlxSprite(0, 0).loadGraphic(Paths.image('freeplay/backingCards/newCharacter/yellow bg piece'));
    lightLayer3 = new FlxSprite(-360, 290).loadGraphic(Paths.image('freeplay/backingCards/newCharacter/red gradient'));
  }

  public override function init():Void
  {
    FlxTween.tween(pinkBack, {x: 0}, 0.6, {ease: FlxEase.quartOut});
    add(pinkBack);

    confirmTextGlow.blend = BlendMode.ADD;
    confirmTextGlow.visible = false;

    confirmGlow.blend = BlendMode.ADD;

    confirmGlow.visible = confirmGlow2.visible = false;

    add(darkBg);

    friendFoe.funnyColor = 0xFF139376;
    friendFoe.speed = -4;
    add(friendFoe);

    newUnlock1.funnyColor = 0xFF99BDF2;
    newUnlock1.speed = 2;
    add(newUnlock1);

    waiting.funnyColor = 0xFF40EA84;
    waiting.speed = -2;
    add(waiting);

    newUnlock2.funnyColor = 0xFF99BDF2;
    newUnlock2.speed = 2;
    add(newUnlock2);

    friendFoe2.funnyColor = 0xFF139376;
    friendFoe2.speed = -4;
    add(friendFoe2);

    newUnlock3.funnyColor = 0xFF99BDF2;
    newUnlock3.speed = 2;
    add(newUnlock3);

    multiplyBar.blend = BlendMode.MULTIPLY;
    add(multiplyBar);

    lightLayer.blend = BlendMode.ADD;
    add(lightLayer);

    multiply1.blend = BlendMode.MULTIPLY;
    add(multiply1);

    multiply2.blend = BlendMode.MULTIPLY;
    add(multiply2);

    lightLayer2.blend = BlendMode.ADD;
    add(lightLayer2);

    yellow.blend = BlendMode.MULTIPLY;
    add(yellow);

    lightLayer3.blend = BlendMode.ADD;
    add(lightLayer3);

    cardGlow.blend = BlendMode.ADD;
    cardGlow.visible = false;

    add(cardGlow);

    darkBg.visible = friendFoe.visible = newUnlock1.visible = waiting.visible = newUnlock2.visible = friendFoe2.visible = newUnlock3.visible = multiplyBar.visible = lightLayer.visible = multiply1.visible = multiply2.visible = lightLayer2.visible = yellow.visible = lightLayer3.visible = false;
  }

  var _timer:Float = 0;

  override public function update(elapsed:Float):Void
  {
    super.update(elapsed);

    _timer += elapsed * 2;
    var sinTest:Float = (Math.sin(_timer) + 1) / 2;
    lightLayer.alpha = FlxMath.lerp(0.4, 1, sinTest);
    lightLayer2.alpha = FlxMath.lerp(0.2, 0.5, sinTest);
    lightLayer3.alpha = FlxMath.lerp(0.1, 0.7, sinTest);

    multiply1.alpha = FlxMath.lerp(1, 0.21, sinTest);
    multiply2.alpha = FlxMath.lerp(1, 0.21, sinTest);

    yellow.alpha = FlxMath.lerp(0.2, 0.72, sinTest);

    if (FreeplayState.instance != null) FreeplayState.instance.angleMaskShader.extraColor = FlxColor.interpolate(0xFF2E2E46, 0xFF60607B, sinTest);
  }

  public override function disappear():Void
  {
    FlxTween.color(pinkBack, 0.25, 0xFF05020E, 0xFFFFD0D5, {ease: FlxEase.quadOut});

    darkBg.visible = friendFoe.visible = newUnlock1.visible = waiting.visible = newUnlock2.visible = friendFoe2.visible = newUnlock3.visible = multiplyBar.visible = lightLayer.visible = multiply1.visible = multiply2.visible = lightLayer2.visible = yellow.visible = lightLayer3.visible = false;

    cardGlow.visible = true;
    cardGlow.alpha = 1;
    cardGlow.scale.set(1, 1);
    FlxTween.tween(cardGlow, {alpha: 0, "scale.x": 1.2, "scale.y": 1.2}, 0.25, {ease: FlxEase.sineOut});
  }

  override public function confirm():Void {}
}
