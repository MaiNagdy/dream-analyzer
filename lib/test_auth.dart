import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const TestAuthApp());
}

class TestAuthApp extends StatelessWidget {
  const TestAuthApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Auth Test',
      theme: ThemeData(
        primarySwatch: Colors.purple,
        useMaterial3: true,
      ),
      home: const TestAuthScreen(),
    );
  }
}

class TestAuthScreen extends StatefulWidget {
  const TestAuthScreen({super.key});

  @override
  State<TestAuthScreen> createState() => _TestAuthScreenState();
}

class _TestAuthScreenState extends State<TestAuthScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _dreamTextController = TextEditingController();
  
  String _token = '';
  String _result = '';
  bool _isLoading = false;
  
  static const String baseUrl = 'http://localhost:5000';
  
  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _dreamTextController.dispose();
    super.dispose();
  }
  
  Future<void> _login() async {
    setState(() {
      _isLoading = true;
      _result = 'Logging in...';
    });
    
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email_or_username': _usernameController.text,
          'password': _passwordController.text,
        }),
      );
      
      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200) {
        setState(() {
          _token = data['access_token'];
          _result = 'Login successful!\nToken: ${_token.substring(0, 10)}...\n\n${jsonEncode(data)}';
        });
      } else {
        setState(() {
          _result = 'Login failed: ${data['message']}\n\n${jsonEncode(data)}';
        });
      }
    } catch (e) {
      setState(() {
        _result = 'Error: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  Future<void> _healthCheck() async {
    setState(() {
      _isLoading = true;
      _result = 'Checking health...';
    });
    
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/health'));
      final data = jsonDecode(response.body);
      
      setState(() {
        _result = 'Health check: ${response.statusCode}\n\n${jsonEncode(data)}';
      });
    } catch (e) {
      setState(() {
        _result = 'Error: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  Future<void> _analyzeDream() async {
    if (_token.isEmpty) {
      setState(() {
        _result = 'Please login first!';
      });
      return;
    }
    
    setState(() {
      _isLoading = true;
      _result = 'Analyzing dream...';
    });
    
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/dreams/analyze'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token',
        },
        body: jsonEncode({
          'dreamText': _dreamTextController.text,
        }),
      );
      
      final data = jsonDecode(response.body);
      
      setState(() {
        _result = 'Analysis result (${response.statusCode}):\n\n${jsonEncode(data)}';
      });
    } catch (e) {
      setState(() {
        _result = 'Error: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Auth Test'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Login', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(
                labelText: 'Email or Username',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isLoading ? null : _login,
              child: const Text('Login'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isLoading ? null : _healthCheck,
              child: const Text('Health Check (No Auth)'),
            ),
            const SizedBox(height: 24),
            const Text('Dream Analysis', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: _dreamTextController,
              decoration: const InputDecoration(
                labelText: 'Dream Text',
                border: OutlineInputBorder(),
              ),
              maxLines: 5,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isLoading ? null : _analyzeDream,
              child: const Text('Analyze Dream'),
            ),
            const SizedBox(height: 24),
            const Text('Result:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(4),
              ),
              child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : SelectableText(_result, style: const TextStyle(fontFamily: 'monospace')),
            ),
          ],
        ),
      ),
    );
  }
} 