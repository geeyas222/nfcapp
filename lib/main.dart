import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart'; // Add this import for local storage
import 'package:flutter_nfc_kit/flutter_nfc_kit.dart';

void main() {
  runApp(const BankCardApp());
}

class BankCardApp extends StatelessWidget {
  const BankCardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: BankCardScreen(),
    );
  }
}

class BankCardScreen extends StatefulWidget {
  const BankCardScreen({super.key});

  @override
  _BankCardScreenState createState() => _BankCardScreenState();
}

class _BankCardScreenState extends State<BankCardScreen>
    with TickerProviderStateMixin {
  double _rotationAngle = 0.0;
  double _verticalOffset = 0.0;
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
  }

  void _startPaymentAnimation() {
    Animation<double> rotationAnimation =
        Tween<double>(begin: 0, end: -0.25).animate(_controller);
    Animation<double> verticalAnimation =
        Tween<double>(begin: 0, end: -200).animate(_controller);

    _controller.addListener(() {
      setState(() {
        _rotationAngle = rotationAnimation.value;
        _verticalOffset = verticalAnimation.value;
      });
    });

    if (_controller.isCompleted || _controller.isDismissed) {
      _controller.forward();
    } else {
      _controller.reverse();
    }

    Future.delayed(const Duration(seconds: 5), () {
      _controller.reset();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const GradientAppBar(title: 'NFC Business Card'),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: _startPaymentAnimation,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: const Center(
                  child: Icon(
                    Icons.nfc,
                    size: 60,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, _verticalOffset),
                  child: RotationTransition(
                    turns: AlwaysStoppedAnimation(_rotationAngle),
                    child: child,
                  ),
                );
              },
              child: const BankCardWidget(),
            ),
          ],
        ),
      ),
    );
  }
}

class BankCardWidget extends StatefulWidget {
  const BankCardWidget({super.key});

  @override
  _BankCardWidgetState createState() => _BankCardWidgetState();
}

class _BankCardWidgetState extends State<BankCardWidget> {
  late File _image;
  String _businessName = 'Business Name';
  String _websiteLink = 'www.YourWebsiteLinkHere.com.au';
  String _name = 'Ram Doe';
  String _phoneNumber = '042024001';
  String _email = 'john@example.com'; // Initialize with default email

  Future<void> _pickImage() async {
    final pickedImage =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      setState(() {
        _image = File(pickedImage.path);
      });

      // Save the image to local storage
      final appDir = await getApplicationDocumentsDirectory();
      final fileName = 'user_image.png'; // Choose a suitable name
      final savedImage = await _image.copy('${appDir.path}/$fileName');
    }
  }

  Future<void> _editBusinessName() async {
    final enteredName = await showDialog<String>(
      context: context,
      builder: (context) {
        String newName = _businessName;
        return AlertDialog(
          title: const Text('Edit Business Name'),
          content: TextField(
            onChanged: (value) {
              newName = value;
            },
            controller: TextEditingController(text: _businessName),
            decoration: const InputDecoration(
              hintText: 'Enter new business name',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, newName);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    if (enteredName != null) {
      setState(() {
        _businessName = enteredName;
        _saveUserData(); // Save the updated data
      });
    }
  }

  Future<void> _editWebsiteLink() async {
    final enteredLink = await showDialog<String>(
      context: context,
      builder: (context) {
        String newLink = _websiteLink;
        return AlertDialog(
          title: const Text('Edit Website Link'),
          content: TextField(
            onChanged: (value) {
              newLink = value;
            },
            controller: TextEditingController(text: _websiteLink),
            decoration: const InputDecoration(
              hintText: 'Enter new website link',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, newLink);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    if (enteredLink != null) {
      setState(() {
        _websiteLink = enteredLink;
        _saveUserData(); // Save the updated data
      });
    }
  }

  Future<void> _editName() async {
    final enteredName = await showDialog<String>(
      context: context,
      builder: (context) {
        String newName = _name;
        return AlertDialog(
          title: const Text('Edit Name'),
          content: TextField(
            onChanged: (value) {
              newName = value;
            },
            controller: TextEditingController(text: _name),
            decoration: const InputDecoration(
              hintText: 'Enter new name',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, newName);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    if (enteredName != null) {
      setState(() {
        _name = enteredName;
        _saveUserData(); // Save the updated data
      });
    }
  }

  Future<void> _editPhoneNumber() async {
    final enteredPhoneNumber = await showDialog<String>(
      context: context,
      builder: (context) {
        String newPhoneNumber = _phoneNumber;
        return AlertDialog(
          title: const Text('Edit Phone Number'),
          content: TextField(
            onChanged: (value) {
              newPhoneNumber = value;
            },
            controller: TextEditingController(text: _phoneNumber),
            decoration: const InputDecoration(
              hintText: 'Enter new phone number',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, newPhoneNumber);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    if (enteredPhoneNumber != null) {
      setState(() {
        _phoneNumber = enteredPhoneNumber;
        _saveUserData(); // Save the updated data
      });
    }
  }

  Future<void> _editEmail() async {
    final enteredEmail = await showDialog<String>(
      context: context,
      builder: (context) {
        String newEmail = _email;
        return AlertDialog(
          title: const Text('Edit Email'),
          content: TextField(
            onChanged: (value) {
              newEmail = value;
            },
            controller: TextEditingController(text: _email),
            decoration: const InputDecoration(
              hintText: 'Enter new email',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, newEmail);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    if (enteredEmail != null) {
      setState(() {
        _email = enteredEmail;
        _saveUserData(); // Save the updated data
      });
    }
  }

  Future<void> _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _businessName = prefs.getString('businessName') ?? _businessName;
      _websiteLink = prefs.getString('websiteLink') ?? _websiteLink;
      _name = prefs.getString('name') ?? _name;
      _phoneNumber = prefs.getString('phoneNumber') ?? _phoneNumber;
      _email = prefs.getString('email') ?? _email;
    });

    // Load the image from local storage
    final appDir = await getApplicationDocumentsDirectory();
    final fileName = 'user_image.png'; // Same name used when saving
    final imageFile = File('${appDir.path}/$fileName');

    if (imageFile.existsSync()) {
      setState(() {
        _image = imageFile;
      });
    }
  }

  Future<void> _saveUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('businessName', _businessName);
    prefs.setString('websiteLink', _websiteLink);
    prefs.setString('name', _name);
    prefs.setString('phoneNumber', _phoneNumber);
    prefs.setString('email', _email);
  }

  @override
  void initState() {
    super.initState();
    _loadUserData(); // Load user data when the widget initializes
    _image = File(''); // Initialize with an empty file
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        width: 455,
        height: 310, // Increased height to accommodate the new field
        margin: const EdgeInsets.all(0.2),
        padding: const EdgeInsets.all(12),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.black87,
              Color.fromARGB(255, 6, 64, 112),
              Color.fromARGB(255, 4, 56, 99),
              Color.fromARGB(255, 2, 29, 50),
              Colors.black87
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(75), // Bigger curve on top left
            bottomRight: Radius.circular(50), // Smaller curve on bottom right
            bottomLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        image: _image.path.isNotEmpty
                            ? FileImage(_image)
                            : const AssetImage('assets/placeholder.png')
                                as ImageProvider<
                                    Object>, // Provide a placeholder image
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                Transform.rotate(
                  angle: 3.14159 / 2,
                  child: const Icon(
                    Icons.wifi,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 5),
            GestureDetector(
              onTap: _editBusinessName,
              child: Text(
                _businessName,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            GestureDetector(
              onTap: _editWebsiteLink,
              child: Text(
                _websiteLink,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: _editName,
                      child: Text(
                        _name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    GestureDetector(
                      onTap: _editPhoneNumber,
                      child: Text(
                        _phoneNumber,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    GestureDetector(
                      onTap: _editEmail,
                      child: Text(
                        _email,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 100.0, // Adjust the width as needed
                      height: 100.0, // Adjust the height as needed
                      child: QrImageView(
                        data: _websiteLink, // Website link for QR code
                        version: QrVersions.auto,
                        size: 20,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class GradientAppBar extends StatelessWidget implements PreferredSizeWidget {
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  final String title;

  const GradientAppBar({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.black87,
            Color.fromARGB(255, 6, 64, 112),
            Color.fromARGB(255, 4, 56, 99),
            Color.fromARGB(255, 2, 29, 50),
            Colors.black87,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: AppBar(
        title: Text(title),
        centerTitle: true,
        backgroundColor: Colors.transparent, // Make AppBar transparent
        elevation: 0, // Remove shadow
      ),
    );
  }
}
