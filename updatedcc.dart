import 'dart:math';
import 'dart:typed_data';
import 'dart:io';
import 'dart:ui';
import 'package:colorfilter_generator/colorfilter_generator.dart';
import 'package:colorfilter_generator/presets.dart';
import 'package:flutter/material.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:flutter/rendering.dart';
import 'package:memo/photo/color_correction/filter_screen.dart';
import 'package:memo/photo/color_correction/image_save_screen.dart';
import 'package:memo/widgets/app_theme.dart';
import 'package:memo/widgets/bottom_button.dart';
import 'package:path_provider/path_provider.dart';

class CCMain extends StatefulWidget {
  final File? image;
  final double? brightness;
  final double? contrast;
  final double? saturation;
  final double? temperature;
  final double? hue;
  final double? tintR;
  final double? tintG;
  final double? tintB;

  CCMain({
    this.image,
    this.brightness,
    this.contrast,
    this.saturation,
    this.temperature,
    this.hue,
    this.tintR,
    this.tintG,
    this.tintB,
  });

  @override
  _CCMainState createState() => _CCMainState();
}

class _CCMainState extends State<CCMain> {
  bool _imageLoaded = false;
  double _brightness = 0.0;
  double _contrast = 1.0;
  double _saturation = 1.0;
  double _temperature = 0.0;
  double _hue = 0.0;
  double _tintR = 0.0;
  double _tintG = 0.0;
  double _tintB = 0.0;
  ColorFilterGenerator _selectedFilter = PresetFilters.none;
  bool _isBrightness = true;
  bool _isContrast = false;
  bool _isSaturation = false;
  bool _isTemperature = false;
  bool _isHue = false;
  bool _isTint = false;
  bool _isFilter = false;
  File? displayImage;

  GlobalKey _globalKey = GlobalKey(); // For capturing the widget as image

  @override
  void initState() {
    super.initState();
    if (widget.image != null) {
      _imageLoaded = true;
      displayImage = widget.image;
      _brightness = widget.brightness ?? 0.0;
      _contrast = widget.contrast ?? 1.0;
      _saturation = widget.saturation ?? 1.0;
      _temperature = widget.temperature ?? 0.0;
      _hue = widget.hue ?? 0.0;
      _tintR = widget.tintR ?? 0.0;
      _tintG = widget.tintG ?? 0.0;
      _tintB = widget.tintB ?? 0.0;
    }
  }

  void _resetAdjustments() {
    setState(() {
      _brightness = 0.0;
      _contrast = 1.0;
      _saturation = 1.0;
      _temperature = 0.0;
      _hue = 0.0;
      _tintR = 0.0;
      _tintG = 0.0;
      _tintB = 0.0;
      _selectedFilter = PresetFilters.none;
      _isBrightness = true;
      _isContrast = false;
      _isSaturation = false;
      _isTemperature = false;
      _isHue = false;
      _isTint = false;
      _isFilter = false;
    });
  }

  Future<void> _saveImage() async {
    try {
      RenderRepaintBoundary boundary = _globalKey.currentContext!
          .findRenderObject() as RenderRepaintBoundary;
      var image = await boundary.toImage();
      ByteData? byteData = await image.toByteData(format: ImageByteFormat.png);
      Uint8List pngBytes = byteData!.buffer.asUint8List();

      final directory = await getExternalStorageDirectory();
      final imagePath =
          '${directory!.path}/Pictures/filtered_image_${DateTime.now().millisecondsSinceEpoch}.png';
      final imageFile = File(imagePath);
      await imageFile.writeAsBytes(pngBytes);

      final result = await ImageGallerySaver.saveImage(pngBytes);
      if (result['isSuccess']) {
        final projectName =
            'Project ${DateTime.now().millisecondsSinceEpoch}'; // Generate a unique project name

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ImageSaveScreen(imageFile: imageFile),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save image!')),
        );
      }
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save image!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: AppTheme.theme,
      child: Scaffold(
        appBar: AppBar(
          actions: [
            IconButton(
              icon: Icon(Icons.refresh),
              onPressed: _resetAdjustments,
            ),
            IconButton(
              onPressed: _saveImage,
              icon: Icon(Icons.check),
            ),
          ],
        ),
        body: Stack(
          children: [
            Column(
              children: [
                Expanded(
                  child: Container(
                    color: Colors.black,
                    child: Center(
                      child: _imageLoaded && displayImage != null
                          ? RepaintBoundary(
                              key: _globalKey,
                              child: ColorFiltered(
                                colorFilter: ColorFilter.matrix(
                                  _createActiveAdjustmentMatrix(),
                                ),
                                child: Image.file(displayImage!),
                              ),
                            )
                          : CircularProgressIndicator(),
                    ),
                  ),
                ),
                _buildSlider(),
                _buildBottomButtons(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSlider() {
    if (_isTint) {
      return Column(
        children: [
          _buildTintSlider('Red', _tintR, Colors.red, (value) {
            setState(() {
              _tintR = value;
            });
          }),
          _buildTintSlider('Green', _tintG, Colors.green, (value) {
            setState(() {
              _tintG = value;
            });
          }),
          _buildTintSlider('Blue', _tintB, Colors.blue, (value) {
            setState(() {
              _tintB = value;
            });
          }),
        ],
      );
    } else if (_isTemperature || _isHue) {
      return Slider(
        value: _isTemperature ? _temperature : _hue,
        min: _isTemperature ? -1.0 : -180.0,
        max: _isTemperature ? 1.0 : 180.0,
        onChanged: (value) {
          setState(() {
            if (_isTemperature) {
              _temperature = value;
            } else {
              _hue = value;
            }
          });
        },
      );
    } else if (_isFilter) {
      return Container(); // Filters don't have sliders
    } else {
      return Slider(
        value: _isBrightness
            ? _brightness
            : (_isContrast ? _contrast : (_saturation)),
        min: _isBrightness ? -0.5 : 0.5, // Reduced brightness range
        max: _isBrightness ? 0.5 : 1.5, // Reduced brightness range
        onChanged: (value) {
          setState(() {
            if (_isBrightness) {
              _brightness = value;
            } else if (_isContrast) {
              _contrast = value;
            } else if (_isSaturation) {
              _saturation = value;
            }
          });
        },
      );
    }
  }

  Widget _buildTintSlider(
      String label, double value, Color color, ValueChanged<double> onChanged) {
    return Column(
      children: [
        Text(label),
        Slider(
          value: value,
          min: 0.0,
          max: 1.0,
          activeColor: color,
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildBottomButtons() {
    return Container(
      padding: EdgeInsets.all(8.0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildBottomButton(Icons.brightness_6, 'Brightness', _isBrightness,
                () {
              setState(() {
                _setActiveAdjustment('brightness');
              });
            }),
            _buildBottomButton(Icons.contrast, 'Contrast', _isContrast, () {
              setState(() {
                _setActiveAdjustment('contrast');
              });
            }),
            _buildBottomButton(Icons.color_lens, 'Saturation', _isSaturation,
                () {
              setState(() {
                _setActiveAdjustment('saturation');
              });
            }),
            _buildBottomButton(Icons.thermostat, 'Temperature', _isTemperature,
                () {
              setState(() {
                _setActiveAdjustment('temperature');
              });
            }),
            _buildBottomButton(Icons.account_tree, 'Hue', _isHue, () {
              setState(() {
                _setActiveAdjustment('hue');
              });
            }),
            _buildBottomButton(Icons.invert_colors, 'Tint', _isTint, () {
              setState(() {
                _setActiveAdjustment('tint');
              });
            }),
            _buildBottomButton(Icons.filter, 'Filter', _isFilter, () async {
              final selectedFilter = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FilterScreen(
                      image: widget.image, initialFilter: _selectedFilter),
                ),
              );
              if (selectedFilter != null) {
                setState(() {
                  _selectedFilter = selectedFilter;
                  _isFilter = true;
                });
              }
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomButton(
      IconData icon, String text, bool isActive, VoidCallback onTap) {
    return BottomButton(
      icon: icon,
      text: text,
      onTap: onTap,
      iconColor: isActive ? Colors.purple : Colors.white,
      labelColor: isActive ? Colors.purple : Colors.white,
    );
  }

  void _setActiveAdjustment(String adjustment) {
    setState(() {
      _isBrightness = adjustment == 'brightness';
      _isContrast = adjustment == 'contrast';
      _isSaturation = adjustment == 'saturation';
      _isTemperature = adjustment == 'temperature';
      _isHue = adjustment == 'hue';
      _isTint = adjustment == 'tint';
      _isFilter = adjustment == 'filter';
    });
  }

  List<double> _createActiveAdjustmentMatrix() {
    List<double> matrix = _selectedFilter.matrix; // Start with filter matrix

    if (_brightness != 0.0) {
      matrix = _multiplyMatrices(matrix, _createBrightnessMatrix(_brightness));
    }
    if (_contrast != 1.0) {
      matrix = _multiplyMatrices(matrix, _createContrastMatrix(_contrast));
    }
    if (_saturation != 1.0) {
      matrix = _multiplyMatrices(matrix, _createSaturationMatrix(_saturation));
    }
    if (_temperature != 0.0) {
      matrix =
          _multiplyMatrices(matrix, _createTemperatureMatrix(_temperature));
    }
    if (_hue != 0.0) {
      matrix = _multiplyMatrices(matrix, _createHueMatrix(_hue));
    }
    if (_tintR != 0.0 || _tintG != 0.0 || _tintB != 0.0) {
      matrix =
          _multiplyMatrices(matrix, _createTintMatrix(_tintR, _tintG, _tintB));
    }

    return matrix;
  }

  List<double> _multiplyMatrices(List<double> a, List<double> b) {
    List<double> result = List<double>.filled(20, 0.0);
    for (int i = 0; i < 4; i++) {
      for (int j = 0; j < 5; j++) {
        result[i * 5 + j] = a[i * 5] * b[j] +
            a[i * 5 + 1] * b[5 + j] +
            a[i * 5 + 2] * b[10 + j] +
            a[i * 5 + 3] * b[15 + j];
        if (j == 4) {
          result[i * 5 + j] += a[i * 5 + 4];
        }
      }
    }
    return result;
  }
}

List<double> _createBrightnessMatrix(double brightness) {
  // Adjusted brightness matrix to be less aggressive
  return [
    1,
    0,
    0,
    0,
    brightness * 150, // Reduced impact of brightness
    0,
    1,
    0,
    0,
    brightness * 150,
    0,
    0,
    1,
    0,
    brightness * 150,
    0,
    0,
    0,
    1,
    0,
  ];
}

List<double> _createContrastMatrix(double contrast) {
  double t = (1.0 - contrast) / 2.0 * 255.0;
  return [
    contrast,
    0,
    0,
    0,
    t,
    0,
    contrast,
    0,
    0,
    t,
    0,
    0,
    contrast,
    0,
    t,
    0,
    0,
    0,
    1,
    0,
  ];
}

List<double> _createSaturationMatrix(double saturation) {
  double rw = 0.3086;
  double gw = 0.6094;
  double bw = 0.0820;
  double invS = 1 - saturation;
  double r = invS * rw;
  double g = invS * gw;
  double b = invS * bw;
  return [
    r + saturation,
    g,
    b,
    0,
    0,
    r,
    g + saturation,
    b,
    0,
    0,
    r,
    g,
    b + saturation,
    0,
    0,
    0,
    0,
    0,
    1,
    0,
  ];
}

List<double> _createTemperatureMatrix(double temperature) {
  double rOffset = temperature > 0 ? temperature * 0.2 : 0;
  double bOffset = temperature < 0 ? -temperature * 0.2 : 0;
  return [
    1 + rOffset,
    0,
    0,
    0,
    0,
    0,
    1,
    0,
    0,
    0,
    0,
    0,
    1 + bOffset,
    0,
    0,
    0,
    0,
    0,
    1,
    0,
  ];
}

List<double> _createHueMatrix(double hue) {
  double cosH = cos(hue * pi / 180);
  double sinH = sin(hue * pi / 180);
  return [
    0.213 + cosH * 0.787 - sinH * 0.213,
    0.715 - cosH * 0.715 - sinH * 0.715,
    0.072 - cosH * 0.072 + sinH * 0.928,
    0,
    0,
    0.213 - cosH * 0.213 + sinH * 0.143,
    0.715 + cosH * 0.285 + sinH * 0.140,
    0.072 - cosH * 0.072 - sinH * 0.283,
    0,
    0,
    0.213 - cosH * 0.213 - sinH * 0.787,
    0.715 - cosH * 0.715 + sinH * 0.715,
    0.072 + cosH * 0.928 + sinH * 0.072,
    0,
    0,
    0,
    0,
    0,
    1,
    0,
  ];
}

List<double> _createTintMatrix(double tintR, double tintG, double tintB) {
  return [
    1,
    0,
    0,
    0,
    tintR * 255,
    0,
    1,
    0,
    0,
    tintG * 255,
    0,
    0,
    1,
    0,
    tintB * 255,
    0,
    0,
    0,
    1,
    0,
  ];
}
