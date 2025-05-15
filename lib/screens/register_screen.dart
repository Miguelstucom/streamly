import 'package:flutter/material.dart';
import 'package:streamly/theme/app_theme.dart';
import 'package:streamly/services/auth_service.dart';
import 'package:streamly/models/genre.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _authService = AuthService();
  bool _isLoading = false;
  int _currentStep = 0;

  // Campos del formulario
  final _usernameController = TextEditingController();
  final _firstnameController = TextEditingController();
  final _lastnameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _ageController = TextEditingController();
  String? _selectedOccupation;

  // Lista de géneros seleccionados
  final Set<int> _selectedGenres = {};

  // Lista de géneros disponibles
  final List<Genre> _genres = [
    Genre(id: 12, name: 'Adventure'),
    Genre(id: 14, name: 'Fantasy'),
    Genre(id: 16, name: 'Animation'),
    Genre(id: 18, name: 'Drama'),
    Genre(id: 27, name: 'Horror'),
    Genre(id: 28, name: 'Action'),
    Genre(id: 35, name: 'Comedy'),
    Genre(id: 36, name: 'History'),
    Genre(id: 37, name: 'Western'),
    Genre(id: 53, name: 'Thriller'),
    Genre(id: 80, name: 'Crime'),
    Genre(id: 99, name: 'Documentary'),
    Genre(id: 878, name: 'Sci-Fi'),
    Genre(id: 9648, name: 'Mistery'),
    Genre(id: 10402, name: 'Music'),
    Genre(id: 10749, name: 'Romance'),
    Genre(id: 10751, name: 'Family'),
    Genre(id: 10752, name: 'War'),
    Genre(id: 10770, name: 'Tv Movie'),
  ];

  // Lista de ocupaciones disponibles
  final List<String> _occupations = [
    'technician',
    'other',
    'writer',
    'executive',
    'administrator',
    'student',
    'lawyer',
    'educator',
    'scientist',
    'entertainment',
    'programmer',
    'librarian',
    'homemaker',
    'artist',
    'marketing',
    'none',
    'healthcare',
    'retired',
    'salesman',
    'doctor',
  ];

  @override
  void dispose() {
    _usernameController.dispose();
    _firstnameController.dispose();
    _lastnameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await _authService.register(
        username: _usernameController.text,
        firstname: _firstnameController.text,
        lastname: _lastnameController.text,
        email: _emailController.text,
        password: _passwordController.text,
        age: int.parse(_ageController.text),
        occupation: _selectedOccupation ?? 'none',
        preferredGenres: _selectedGenres.toList(),
      );

      if (mounted) {
        // Mostrar mensaje de éxito
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 8),
                const Text('¡Registro exitoso!'),
              ],
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            margin: const EdgeInsets.all(16),
          ),
        );

        // Esperar 2 segundos antes de navegar
        await Future.delayed(const Duration(seconds: 2));

        if (mounted) {
          Navigator.pushReplacementNamed(context, '/login');
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(child: Text(e.toString())),
              ],
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Widget _buildPersonalInfoStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Información Personal',
          style: TextStyle(
            color: AppTheme.primaryColor,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Completa tus datos personales para crear tu cuenta',
          style: TextStyle(color: Colors.grey[400], fontSize: 16),
        ),
        const SizedBox(height: 24),
        TextFormField(
          controller: _usernameController,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            labelText: 'Nombre de usuario',
            labelStyle: TextStyle(color: Colors.grey[400]),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey[800]!),
              borderRadius: BorderRadius.circular(12),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: AppTheme.primaryColor),
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Por favor ingresa un nombre de usuario';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _firstnameController,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            labelText: 'Nombre',
            labelStyle: TextStyle(color: Colors.grey[400]),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey[800]!),
              borderRadius: BorderRadius.circular(12),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: AppTheme.primaryColor),
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Por favor ingresa tu nombre';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _lastnameController,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            labelText: 'Apellido',
            labelStyle: TextStyle(color: Colors.grey[400]),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey[800]!),
              borderRadius: BorderRadius.circular(12),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: AppTheme.primaryColor),
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Por favor ingresa tu apellido';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildAccountInfoStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Información de la Cuenta',
          style: TextStyle(
            color: AppTheme.primaryColor,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Crea tus credenciales de acceso',
          style: TextStyle(color: Colors.grey[400], fontSize: 16),
        ),
        const SizedBox(height: 24),
        TextFormField(
          controller: _emailController,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            labelText: 'Email',
            labelStyle: TextStyle(color: Colors.grey[400]),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey[800]!),
              borderRadius: BorderRadius.circular(12),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: AppTheme.primaryColor),
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Por favor ingresa tu email';
            }
            if (!value.contains('@')) {
              return 'Por favor ingresa un email válido';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _passwordController,
          style: const TextStyle(color: Colors.white),
          obscureText: true,
          decoration: InputDecoration(
            labelText: 'Contraseña',
            labelStyle: TextStyle(color: Colors.grey[400]),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey[800]!),
              borderRadius: BorderRadius.circular(12),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: AppTheme.primaryColor),
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Por favor ingresa una contraseña';
            }
            if (value.length < 6) {
              return 'La contraseña debe tener al menos 6 caracteres';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildProfileInfoStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Información del Perfil',
          style: TextStyle(
            color: AppTheme.primaryColor,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Cuéntanos más sobre ti',
          style: TextStyle(color: Colors.grey[400], fontSize: 16),
        ),
        const SizedBox(height: 24),
        TextFormField(
          controller: _ageController,
          style: const TextStyle(color: Colors.white),
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: 'Edad',
            labelStyle: TextStyle(color: Colors.grey[400]),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey[800]!),
              borderRadius: BorderRadius.circular(12),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: AppTheme.primaryColor),
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Por favor ingresa tu edad';
            }
            if (int.tryParse(value) == null) {
              return 'Por favor ingresa un número válido';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          value: _selectedOccupation,
          decoration: InputDecoration(
            labelText: 'Ocupación',
            labelStyle: TextStyle(color: Colors.grey[400]),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey[800]!),
              borderRadius: BorderRadius.circular(12),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: AppTheme.primaryColor),
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          dropdownColor: Colors.grey[900],
          style: const TextStyle(color: Colors.white),
          icon: Icon(Icons.arrow_drop_down, color: Colors.grey[400]),
          items:
              _occupations.map((String occupation) {
                return DropdownMenuItem<String>(
                  value: occupation,
                  child: Text(
                    occupation[0].toUpperCase() + occupation.substring(1),
                    style: const TextStyle(color: Colors.white),
                  ),
                );
              }).toList(),
          onChanged: (String? newValue) {
            setState(() {
              _selectedOccupation = newValue;
            });
          },
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Por favor selecciona una ocupación';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildGenresStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Géneros Preferidos',
          style: TextStyle(
            color: AppTheme.primaryColor,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Selecciona tus géneros favoritos para personalizar tus recomendaciones',
          style: TextStyle(color: Colors.grey[400], fontSize: 16),
        ),
        const SizedBox(height: 24),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[800]!),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children:
                _genres.map((genre) {
                  final isSelected = _selectedGenres.contains(genre.id);
                  return FilterChip(
                    label: Text(
                      genre.name,
                      style: TextStyle(
                        color: isSelected ? Colors.black : Colors.white,
                      ),
                    ),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _selectedGenres.add(genre.id);
                        } else {
                          _selectedGenres.remove(genre.id);
                        }
                      });
                    },
                    backgroundColor: Colors.grey[900],
                    selectedColor: AppTheme.primaryColor,
                    checkmarkColor: Colors.black,
                  );
                }).toList(),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () {
                        if (_currentStep > 0) {
                          setState(() {
                            _currentStep--;
                          });
                        } else {
                          Navigator.pop(context);
                        }
                      },
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Crear cuenta',
                      style: TextStyle(
                        color: AppTheme.primaryColor,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      if (_currentStep == 0) _buildPersonalInfoStep(),
                      if (_currentStep == 1) _buildAccountInfoStep(),
                      if (_currentStep == 2) _buildProfileInfoStep(),
                      if (_currentStep == 3) _buildGenresStep(),
                      const SizedBox(height: 32),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          if (_currentStep > 0)
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  _currentStep--;
                                });
                              },
                              child: Text(
                                'Anterior',
                                style: TextStyle(
                                  color: Colors.grey[400],
                                  fontSize: 16,
                                ),
                              ),
                            )
                          else
                            const SizedBox.shrink(),
                          ElevatedButton(
                            onPressed:
                                _isLoading
                                    ? null
                                    : () {
                                      if (_currentStep < 3) {
                                        setState(() {
                                          _currentStep++;
                                        });
                                      } else {
                                        _register();
                                      }
                                    },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryColor,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 32,
                                vertical: 16,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child:
                                _isLoading
                                    ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              Colors.white,
                                            ),
                                      ),
                                    )
                                    : Text(
                                      _currentStep < 3
                                          ? 'Siguiente'
                                          : 'Registrarse',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
