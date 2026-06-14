import 'package:flutter/material.dart';
import 'package:pos/layouts/desktop_layout.dart';

class LoginScreen extends StatefulWidget {
  final VoidCallback onAccess;

  const LoginScreen({super.key, required this.onAccess});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

enum _ActiveField { account, password }

class _LoginScreenState extends State<LoginScreen> {
  String _account = '';
  String _password = '';
  _ActiveField _active = _ActiveField.account;

  void _typeDigit(String digit) {
    setState(() {
      if (_active == _ActiveField.account) {
        _account += digit;
      } else {
        _password += digit;
      }
    });
  }

  void _backspace() {
    setState(() {
      if (_active == _ActiveField.account) {
        if (_account.isNotEmpty) {
          _account = _account.substring(0, _account.length - 1);
        }
      } else {
        if (_password.isNotEmpty) {
          _password = _password.substring(0, _password.length - 1);
        }
      }
    });
  }

  void _clearAccount() {
    setState(() {
      _account = '';
      _active = _ActiveField.account;
    });
  }

  void _clearPassword() {
    setState(() {
      _password = '';
      _active = _ActiveField.password;
    });
  }

  @override
  Widget build(BuildContext context) {
    return DesktopLayout(
      child: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0, -0.4),
            radius: 1.3,
            colors: [Color(0xFF1E4D8C), Color(0xFF081A40)],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(60, 60, 60, 0),
          child: Column(
            children: [
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 3,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: _LoginField(
                                    text: _account,
                                    isPassword: false,
                                    isActive: _active == _ActiveField.account,
                                    onTap: () => setState(
                                      () => _active = _ActiveField.account,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 24),
                                _ClearButton(onTap: _clearAccount),
                              ],
                            ),
                            const SizedBox(height: 32),
                            Row(
                              children: [
                                Expanded(
                                  child: _LoginField(
                                    text: _password,
                                    isPassword: true,
                                    isActive: _active == _ActiveField.password,
                                    onTap: () => setState(
                                      () => _active = _ActiveField.password,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 24),
                                _ClearButton(onTap: _clearPassword),
                              ],
                            ),
                            const SizedBox(height: 60),
                            _AccesoButton(onTap: widget.onAccess),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 60),
                    Expanded(
                      flex: 2,
                      child: Column(
                        children: [
                          Expanded(
                            child: _NumPad(
                              onDigit: _typeDigit,
                              onBackspace: _backspace,
                            ),
                          ),
                          const SizedBox(height: 28),
                          Align(
                            alignment: Alignment.centerRight,
                            child: Image.asset(
                              'assets/resources/ds_logo_login.png',
                              height: 64,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // Bottom image strip with version number
              SizedBox(
                height: 160,
                width: double.infinity,
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: Image.asset(
                        'assets/resources/games_img.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      left: 16,
                      bottom: 8,
                      child: Text(
                        '2.51.00',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.6),
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LoginField extends StatelessWidget {
  final String text;
  final bool isPassword;
  final bool isActive;
  final VoidCallback onTap;

  const _LoginField({
    required this.text,
    required this.isPassword,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final display = isPassword ? '•' * text.length : text;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 76,
        padding: const EdgeInsets.symmetric(horizontal: 28),
        alignment: Alignment.centerLeft,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isActive ? const Color(0xFFD4AF37) : Colors.transparent,
            width: 3,
          ),
        ),
        child: Text(
          display,
          style: TextStyle(
            fontSize: 30,
            fontStyle: isPassword ? FontStyle.normal : FontStyle.italic,
            letterSpacing: isPassword ? 6 : 1,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1A1A3A),
          ),
        ),
      ),
    );
  }
}

class _ClearButton extends StatefulWidget {
  final VoidCallback onTap;

  const _ClearButton({required this.onTap});

  @override
  State<_ClearButton> createState() => _ClearButtonState();
}

class _ClearButtonState extends State<_ClearButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedScale(
          scale: _isHovered ? 1.05 : 1.0,
          duration: const Duration(milliseconds: 100),
          child: Image.asset('assets/resources/imagenx.png', height: 60),
        ),
      ),
    );
  }
}

class _AccesoButton extends StatefulWidget {
  final VoidCallback onTap;

  const _AccesoButton({required this.onTap});

  @override
  State<_AccesoButton> createState() => _AccesoButtonState();
}

class _AccesoButtonState extends State<_AccesoButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final bgAsset = _isHovered
        ? 'assets/resources/butt_login_hov.png'
        : 'assets/resources/butt_login.png';

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          width: 320,
          height: 76,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(bgAsset),
              fit: BoxFit.fill,
            ),
          ),
          child: const Text(
            'ACCESO',
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
        ),
      ),
    );
  }
}

class _NumPad extends StatelessWidget {
  final ValueChanged<String> onDigit;
  final VoidCallback onBackspace;

  const _NumPad({required this.onDigit, required this.onBackspace});

  @override
  Widget build(BuildContext context) {
    const spacing = 16.0;
    return Column(
      children: [
        Expanded(
          child: Row(
            children: [
              Expanded(
                child: _NumKey(label: '1', onTap: () => onDigit('1')),
              ),
              const SizedBox(width: spacing),
              Expanded(
                child: _NumKey(label: '2', onTap: () => onDigit('2')),
              ),
              const SizedBox(width: spacing),
              Expanded(
                child: _NumKey(label: '3', onTap: () => onDigit('3')),
              ),
            ],
          ),
        ),
        const SizedBox(height: spacing),
        Expanded(
          child: Row(
            children: [
              Expanded(
                child: _NumKey(label: '4', onTap: () => onDigit('4')),
              ),
              const SizedBox(width: spacing),
              Expanded(
                child: _NumKey(label: '5', onTap: () => onDigit('5')),
              ),
              const SizedBox(width: spacing),
              Expanded(
                child: _NumKey(label: '6', onTap: () => onDigit('6')),
              ),
            ],
          ),
        ),
        const SizedBox(height: spacing),
        Expanded(
          child: Row(
            children: [
              Expanded(
                child: _NumKey(label: '7', onTap: () => onDigit('7')),
              ),
              const SizedBox(width: spacing),
              Expanded(
                child: _NumKey(label: '8', onTap: () => onDigit('8')),
              ),
              const SizedBox(width: spacing),
              Expanded(
                child: _NumKey(label: '9', onTap: () => onDigit('9')),
              ),
            ],
          ),
        ),
        const SizedBox(height: spacing),
        Expanded(
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: _NumKey(
                  icon: Icons.arrow_back,
                  color: const Color(0xFFB7281E),
                  iconColor: Colors.white,
                  onTap: onBackspace,
                ),
              ),
              const SizedBox(width: spacing),
              Expanded(
                flex: 1,
                child: _NumKey(label: '0', onTap: () => onDigit('0')),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _NumKey extends StatefulWidget {
  final String? label;
  final IconData? icon;
  final Color? color;
  final Color? iconColor;
  final VoidCallback onTap;

  const _NumKey({
    this.label,
    this.icon,
    this.color,
    this.iconColor,
    required this.onTap,
  });

  @override
  State<_NumKey> createState() => _NumKeyState();
}

class _NumKeyState extends State<_NumKey> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final baseColor = widget.color ?? const Color(0xFFE6E6E6);
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          decoration: BoxDecoration(
            color: _isHovered ? baseColor.withOpacity(0.8) : baseColor,
            borderRadius: BorderRadius.circular(6),
          ),
          alignment: Alignment.center,
          child: widget.icon != null
              ? Icon(widget.icon, color: widget.iconColor, size: 30)
              : Text(
                  widget.label!,
                  style: const TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1A3A),
                  ),
                ),
        ),
      ),
    );
  }
}
