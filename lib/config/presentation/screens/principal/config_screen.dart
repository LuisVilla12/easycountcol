import 'package:easycoutcol/config/presentation/providers/login_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ConfigScreen extends ConsumerWidget {
  static const String name='config_name';
  const ConfigScreen({super.key});

  @override
  Widget build(BuildContext context,ref) {
      // Saber el usuario con riverpod
  return Scaffold(
      appBar: AppBar(
        title: const Text('Datos del usuario'),
        ),
        body: const _ConfigCountScreen(),
    );
  }
}

class _ConfigCountScreen extends ConsumerWidget {
  const _ConfigCountScreen();

  @override
  Widget build(BuildContext context,ref) {
    final colors=Theme.of(context).colorScheme;
    return SingleChildScrollView(
  child: Padding(
    padding: const EdgeInsets.all(20.0),
    child: Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 10,
                offset: Offset(0, 5),
              )
            ],
          ),
          child: Column(
            children: [
              // Avatar
              CircleAvatar(
                radius: 40,
                backgroundColor: colors.primary,
                child: Icon(
                  Icons.person,
                  size: 40,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 15),

              // Nombre completo
              Text(
                '${ref.watch(nameProvider)}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 5),

              // Username
              Text(
                '@${ref.watch(usernameProvider)}',
                style: TextStyle(
                  color: Colors.grey[600],
                ),
              ),

              const Divider(height: 30),

              // Datos
              _buildInfoTile(Icons.person, "Nombre", ref.watch(nameProvider), color: colors.primary),
              _buildInfoTile(Icons.person, "Apellido", ref.watch(lastnameProvider), color: colors.primary),
              _buildInfoTile(Icons.email, "Email", ref.watch(emailProvider), color: colors.primary),
              _buildInfoTile(Icons.badge, "ID Usuario", ref.watch(idUserProvider).toString(), color: colors.primary),
            ],
          ),
        ),
      ],
    ),
  ),
);
  }

}
Widget _buildInfoTile(IconData icon, String title, String value, {Color? color}) {
  
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Row(
      children: [
        Icon(icon, color: color ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        )
      ],
    ),
  );
}