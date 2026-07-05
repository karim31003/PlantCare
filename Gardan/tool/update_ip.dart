import 'dart:io';
import 'dart:convert';

void main() async {
  try {
    final interfaces = await NetworkInterface.list(
      includeLoopback: false,
      type: InternetAddressType.IPv4,
    );

    String? localIp;
    
    // Sort interfaces to prioritize physical/Wi-Fi/Ethernet adapters
    // Avoid virtual/WSL/vbox interfaces if possible
    final sortedInterfaces = listPrioritizedInterfaces(interfaces);

    for (var interface in sortedInterfaces) {
      for (var addr in interface.addresses) {
        final ip = addr.address;
        // Check if it's a private network address
        if (isPrivateIp(ip)) {
          localIp = ip;
          break;
        }
      }
      if (localIp != null) break;
    }

    // Fallback to any non-loopback IP if no private IP found
    if (localIp == null && interfaces.isNotEmpty) {
      localIp = interfaces.first.addresses.first.address;
    }

    if (localIp == null) {
      print('Error: Could not detect any valid local IP address.');
      exit(1);
    }

    final configFile = File('dev_config.json');
    final config = {
      'FLASK_HOST': localIp,
    };

    const encoder = JsonEncoder.withIndent('  ');
    await configFile.writeAsString(encoder.convert(config));
    print('--------------------------------------------------');
    print('SUCCESS: Dynamic local IP auto-detected!');
    print('IP Address: $localIp');
    print('Written to: dev_config.json');
    print('Run config: flutter run --dart-define-from-file=dev_config.json');
    print('--------------------------------------------------');
  } catch (e) {
    print('Error auto-detecting IP: $e');
    exit(1);
  }
}

List<NetworkInterface> listPrioritizedInterfaces(List<NetworkInterface> interfaces) {
  final List<NetworkInterface> prioritized = [];
  final List<NetworkInterface> virtual = [];

  for (var interface in interfaces) {
    final name = interface.name.toLowerCase();
    if (name.contains('wsl') ||
        name.contains('virtual') ||
        name.contains('vbox') ||
        name.contains('vmware') ||
        name.contains('docker') ||
        name.contains('host-only')) {
      virtual.add(interface);
    } else {
      prioritized.add(interface);
    }
  }

  return [...prioritized, ...virtual];
}

bool isPrivateIp(String ip) {
  // Matches:
  // 192.168.x.x
  // 10.x.x.x
  // 172.16.x.x - 172.31.x.x
  if (ip.startsWith('192.168.') || ip.startsWith('10.')) {
    return true;
  }
  if (ip.startsWith('172.')) {
    final parts = ip.split('.');
    if (parts.length >= 2) {
      final secondPart = int.tryParse(parts[1]);
      if (secondPart != null && secondPart >= 16 && secondPart <= 31) {
        return true;
      }
    }
  }
  return false;
}
