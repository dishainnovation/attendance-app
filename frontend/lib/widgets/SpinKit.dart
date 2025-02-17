import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

enum SpinType {
  RotatingPlain,
  DoubleBounce,
  Wave,
  WanderingCubes,
  FadingFour,
  FadingCube,
  Pulse,
  ChasingDots,
  ThreeBounce,
  Circle,
  CubeGrid,
  FadingCircle,
  RotatingCircle,
  FoldingCube,
  PouringHourGlassRefined,
  FadingGrid,
  Ring,
  Ripple,
  SpinningCircle,
  SpinningLines,
  SquareCircle,
  DualRing,
  PianoWave,
  DancingSquare,
  ThreeInOut,
  WaveSpinner,
  PulsingGrid
}

class SpinKit extends StatelessWidget {
  final SpinType type;
  const SpinKit({super.key, required this.type});

  @override
  Widget build(BuildContext context) {
    Color color = Colors.green[900]!;
    double size = 80.0;
    late Widget spinkit;
    switch (type) {
      case SpinType.RotatingPlain:
        spinkit = SpinKitRotatingPlain(
          color: color,
          size: size,
        );
        break;
      case SpinType.DoubleBounce:
        spinkit = SpinKitDoubleBounce(
          color: color,
          size: size,
        );
        break;
      case SpinType.Wave:
        spinkit = SpinKitWave(
          color: color,
          size: size,
        );
        break;
      case SpinType.WanderingCubes:
        spinkit = SpinKitWanderingCubes(
          color: color,
          size: size,
        );
        break;
      case SpinType.FadingFour:
        spinkit = SpinKitFadingFour(
          color: color,
          size: size,
        );
        break;
      case SpinType.FadingCube:
        spinkit = SpinKitFadingCube(
          color: color,
          size: size,
        );
        break;
      case SpinType.Pulse:
        spinkit = SpinKitPulse(
          color: color,
          size: size,
        );
        break;
      case SpinType.ChasingDots:
        spinkit = SpinKitChasingDots(
          color: color,
          size: size,
        );
        break;
      case SpinType.ThreeBounce:
        spinkit = SpinKitThreeBounce(
          color: color,
          size: size,
        );
        break;
      case SpinType.Circle:
        spinkit = SpinKitCircle(
          color: color,
          size: size,
        );
        break;
      case SpinType.CubeGrid:
        spinkit = SpinKitCubeGrid(
          color: color,
          size: size,
        );
        break;
      case SpinType.FadingCircle:
        spinkit = SpinKitFadingCircle(
          color: color,
          size: size,
        );
        break;
      case SpinType.RotatingCircle:
        spinkit = SpinKitRotatingCircle(
          color: color,
          size: size,
        );
        break;
      case SpinType.FoldingCube:
        spinkit = SpinKitFoldingCube(
          color: color,
          size: size,
        );
        break;
      case SpinType.PouringHourGlassRefined:
        spinkit = SpinKitPouringHourGlassRefined(
          color: color,
          size: size,
        );
        break;
      case SpinType.FadingGrid:
        spinkit = SpinKitFadingGrid(
          color: color,
          size: size,
        );
        break;
      case SpinType.Ring:
        spinkit = SpinKitRing(
          color: color,
          size: size,
        );
        break;
      case SpinType.Ripple:
        spinkit = SpinKitRipple(
          color: color,
          size: size,
        );
        break;
      case SpinType.SpinningCircle:
        spinkit = SpinKitSpinningCircle(
          color: color,
          size: size,
        );
        break;
      case SpinType.SpinningLines:
        spinkit = SpinKitSpinningLines(
          color: color,
          size: size,
        );
        break;
      case SpinType.SquareCircle:
        spinkit = SpinKitSquareCircle(
          color: color,
          size: size,
        );
        break;
      case SpinType.DualRing:
        spinkit = SpinKitDualRing(
          color: color,
          size: size,
        );
        break;
      case SpinType.PianoWave:
        spinkit = SpinKitPianoWave(
          color: color,
          size: size,
        );
        break;
      case SpinType.DancingSquare:
        spinkit = SpinKitDancingSquare(
          color: color,
          size: size,
        );
        break;
      case SpinType.ThreeInOut:
        spinkit = SpinKitThreeInOut(
          color: color,
          size: size,
        );
        break;
      case SpinType.WaveSpinner:
        spinkit = SpinKitWaveSpinner(
          color: Colors.white,
          trackColor: color,
          waveColor: color,
          size: size,
        );
        break;
      default:
    }

    return spinkit;
  }
}
