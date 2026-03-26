import 'package:flutter/material.dart';
import '../widgets/bottom_nav.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  String _selectedDevice = 'camera';

  void _onNavTap(int index) {
    setState(() => _currentIndex = index);
    switch (index) {
      case 0:
        break;
      case 1:
        Navigator.of(context).pushReplacementNamed('/exercises');
        break;
      case 2:
        Navigator.of(context).pushReplacementNamed('/scan');
        break;
      case 3:
        Navigator.of(context).pushReplacementNamed('/stats');
        break;
      case 4:
        Navigator.of(context).pushReplacementNamed('/profile');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Status Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '01:08',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Welcome Message
                    const SizedBox(height: 32),
                    const Text(
                      'Welcome Back',
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.w300,
                        color: Color(0xFF111827),
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Let\'s continue your journey to better posture and pain-free movement',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w300,
                        color: Colors.grey.shade600,
                        height: 1.5,
                      ),
                    ),

                    // Daily Goal Card
                    const SizedBox(height: 32),
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: const Color(0xFF4F46E5),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF4F46E5).withOpacity(0.2),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Today\'s Goal',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.white.withOpacity(0.7),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  const Text(
                                    '15 minutes',
                                    style: TextStyle(
                                      fontSize: 30,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '4 min completed',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.white.withOpacity(0.7),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                width: 64,
                                height: 64,
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    CircularProgressIndicator(
                                      value: 0.27,
                                      strokeWidth: 4,
                                      backgroundColor: Colors.white.withOpacity(0.3),
                                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                                    ),
                                    const Text(
                                      '27%',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: LinearProgressIndicator(
                              value: 0.27,
                              minHeight: 8,
                              backgroundColor: Colors.white.withOpacity(0.2),
                              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Quick Start Section
                    const SizedBox(height: 24),
                    const Text(
                      'Quick Start',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF111827),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Device Selection
                    Row(
                      children: [
                        Expanded(
                          child: _buildDeviceCard(
                            icon: Icons.camera_alt_rounded,
                            label: 'Camera',
                            deviceId: 'camera',
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildDeviceCard(
                            icon: Icons.smartphone_rounded,
                            label: 'Phone',
                            deviceId: 'phone',
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pushNamed(context, '/live-analysis'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4F46E5),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 4,
                        ),
                        child: const Text(
                          'Start Exercise Session',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),

                    // Today's Progress
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.shade200,
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                        border: Border.all(color: Colors.grey.shade100),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Today\'s Progress',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w400,
                              color: Color(0xFF111827),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              Expanded(
                                child: _buildStatCard(
                                  icon: Icons.access_time_rounded,
                                  value: '4m',
                                  label: 'Active Time',
                                  color: const Color(0xFF3B82F6),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _buildStatCard(
                                  icon: Icons.check_circle_rounded,
                                  value: '93',
                                  label: 'Posture Score',
                                  color: const Color(0xFF10B981),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNav(
        currentIndex: _currentIndex,
        onTap: _onNavTap,
      ),
    );
  }

  Widget _buildDeviceCard({
    required IconData icon,
    required String label,
    required String deviceId,
  }) {
    final isSelected = _selectedDevice == deviceId;
    
    return GestureDetector(
      onTap: () => setState(() => _selectedDevice = deviceId),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFEEF2FF) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? const Color(0xFF4F46E5) : Colors.grey.shade100,
            width: 2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF4F46E5).withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.grey.shade200,
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? const Color(0xFF4F46E5) : Colors.grey.shade500,
              size: 28,
            ),
            const SizedBox(height: 12),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: isSelected ? const Color(0xFF4F46E5) : Colors.grey.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
