import 'package:flutter/material.dart';
import 'dart:math';
import 'package:myatk/core/theme/app_theme.dart';
import 'package:myatk/data/providers/theme_provider.dart';
import 'package:provider/provider.dart';

class CalculatorPage extends StatefulWidget {
  const CalculatorPage({Key? key}) : super(key: key);

  @override
  State<CalculatorPage> createState() => _CalculatorPageState();
}

class _CalculatorPageState extends State<CalculatorPage> {
  String _input = '';
  String _output = '0';
  String _operator = '';
  double _num1 = 0;
  double _num2 = 0;
  bool _operatorPressed = false;
  bool _equalPressed = false;

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text('Kalkulator', style: TextStyle(fontWeight: FontWeight.w600)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDark 
                ? [Color(0xFF3F2B63), Color(0xFF2B2440)]
                : [Color(0xFF9C27B0), Color(0xFF6E4A6C)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/background.png'),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              isDark ? Colors.black.withOpacity(0.7) : Colors.black.withOpacity(0.3),
              BlendMode.darken,
            ),
          ),
        ),
        child: Column(
          children: [
            SizedBox(height: kToolbarHeight), // Ruang untuk AppBar
            
            // Display output
            Expanded(
              flex: 2,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDark 
                      ? [Colors.black.withOpacity(0.8), Color(0xFF1A1A2E).withOpacity(0.8)]
                      : [Colors.black.withOpacity(0.7), Color(0xFF2A2A40).withOpacity(0.7)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      _input,
                      style: TextStyle(
                        fontSize: 24,
                        color: Colors.grey[400],
                      ),
                    ),
                    SizedBox(height: 10),
                    ShaderMask(
                      shaderCallback: (bounds) => LinearGradient(
                        colors: AppTheme.primaryGradientColors,
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ).createShader(bounds),
                      child: Text(
                        _output,
                        style: TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Calculator buttons
            Expanded(
              flex: 6,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDark 
                      ? [Color(0xFF1A1A2E).withOpacity(0.9), Colors.black.withOpacity(0.9)]
                      : [Color(0xFF2A2A40).withOpacity(0.8), Colors.black.withOpacity(0.8)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Column(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          _buildButton('C', isFunction: true, isDark: isDark),
                          _buildButton('⌫', isFunction: true, isDark: isDark),
                          _buildButton('%', isFunction: true, isDark: isDark),
                          _buildButton('÷', isOperator: true, isDark: isDark),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Row(
                        children: [
                          _buildButton('7', isDark: isDark),
                          _buildButton('8', isDark: isDark),
                          _buildButton('9', isDark: isDark),
                          _buildButton('×', isOperator: true, isDark: isDark),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Row(
                        children: [
                          _buildButton('4', isDark: isDark),
                          _buildButton('5', isDark: isDark),
                          _buildButton('6', isDark: isDark),
                          _buildButton('-', isOperator: true, isDark: isDark),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Row(
                        children: [
                          _buildButton('1', isDark: isDark),
                          _buildButton('2', isDark: isDark),
                          _buildButton('3', isDark: isDark),
                          _buildButton('+', isOperator: true, isDark: isDark),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Row(
                        children: [
                          _buildButton('±', isFunction: true, isDark: isDark),
                          _buildButton('0', isDark: isDark),
                          _buildButton('.', isDark: isDark),
                          _buildButton('=', isOperator: true, isEqual: true, isDark: isDark),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildButton(String text, {
    bool isOperator = false, 
    bool isFunction = false, 
    bool isEqual = false,
    required bool isDark,
  }) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black.withOpacity(0.2), width: 0.5),
        ),
        child: TextButton(
          style: TextButton.styleFrom(
            backgroundColor: isEqual 
                ? AppTheme.primaryGradientColors[0]
                : isOperator 
                    ? AppTheme.primaryGradientColors[1].withOpacity(0.8)
                    : isFunction 
                        ? isDark ? Colors.grey[850] : Colors.grey[800]
                        : isDark ? Colors.black.withOpacity(0.7) : Colors.black.withOpacity(0.5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.zero,
            ),
            padding: EdgeInsets.all(20),
          ),
          onPressed: () => _onButtonPressed(text),
          child: Text(
            text,
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
            ),
          ),
        ),
      ),
    );
  }

  void _onButtonPressed(String buttonText) {
    switch (buttonText) {
      case 'C':
        setState(() {
          _input = '';
          _output = '0';
          _num1 = 0;
          _num2 = 0;
          _operator = '';
          _operatorPressed = false;
          _equalPressed = false;
        });
        break;
      case '⌫': // Backspace
        if (_output.length > 1) {
          setState(() {
            _output = _output.substring(0, _output.length - 1);
            if (_equalPressed || _operatorPressed) {
              _input = '';
              _operatorPressed = false;
              _equalPressed = false;
            }
          });
        } else {
          setState(() {
            _output = '0';
            if (_equalPressed || _operatorPressed) {
              _input = '';
              _operatorPressed = false;
              _equalPressed = false;
            }
          });
        }
        break;
      case '%':
        if (_output != '0') {
          setState(() {
            double value = double.parse(_output) / 100;
            _output = value.toString();
            _formatOutput();
          });
        }
        break;
      case '±': // Plus/minus toggle
        if (_output != '0') {
          setState(() {
            if (_output.startsWith('-')) {
              _output = _output.substring(1);
            } else {
              _output = '-' + _output;
            }
          });
        }
        break;
      case '+':
      case '-':
      case '×':
      case '÷':
        _handleOperator(buttonText);
        break;
      case '=':
        _calculateResult();
        break;
      case '.':
        if (!_output.contains('.')) {
          setState(() {
            if (_equalPressed || _operatorPressed) {
              _output = '0.';
              _input = '';
              _operatorPressed = false;
              _equalPressed = false;
            } else {
              _output += '.';
            }
          });
        }
        break;
      default: // Numbers
        setState(() {
          if (_output == '0' || _operatorPressed || _equalPressed) {
            _output = buttonText;
            _operatorPressed = false;
            _equalPressed = false;
          } else {
            _output += buttonText;
          }
        });
        break;
    }
  }

  void _handleOperator(String op) {
    setState(() {
      // If there was a previous calculation, use the result as first number
      if (_equalPressed) {
        _num1 = double.parse(_output);
        _input = _output + ' ' + op;
        _equalPressed = false;
      } 
      // If another operator was pressed before entering a second number
      else if (_operatorPressed) {
        _input = _input.substring(0, _input.length - 1) + op;
      } 
      // Normal case: first number followed by operator
      else {
        _num1 = double.parse(_output);
        _input = _output + ' ' + op;
      }
      
      _operator = op;
      _operatorPressed = true;
    });
  }

  void _calculateResult() {
    if (_operator.isEmpty) return;
    
    // Don't recalculate if equals was already pressed
    if (_equalPressed) return;
    
    setState(() {
      _num2 = double.parse(_output);
      _input += ' ' + _output;
      
      double result = 0;
      
      switch (_operator) {
        case '+':
          result = _num1 + _num2;
          break;
        case '-':
          result = _num1 - _num2;
          break;
        case '×':
          result = _num1 * _num2;
          break;
        case '÷':
          if (_num2 != 0) {
            result = _num1 / _num2;
          } else {
            _output = 'Error';
            _equalPressed = true;
            return;
          }
          break;
      }
      
      // Update the result and format it
      _output = result.toString();
      _formatOutput();
      _equalPressed = true;
      _input += ' = ' + _output;
    });
  }

  void _formatOutput() {
    // Handle decimals
    if (_output.contains('.')) {
      // Remove trailing zeros
      List<String> parts = _output.split('.');
      if (parts[1] == '0') {
        _output = parts[0];
      } else {
        // Limit to 8 decimal places
        if (parts[1].length > 8) {
          parts[1] = parts[1].substring(0, 8);
          _output = parts[0] + '.' + parts[1];
        }
      }
    }
    
    // Handle large numbers
    double numValue = double.parse(_output);
    if (numValue.abs() > 999999999) {
      _output = numValue.toStringAsExponential(4);
    }
  }
} 