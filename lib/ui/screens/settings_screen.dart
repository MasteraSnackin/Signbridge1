/// Settings Screen
/// 
/// Configuration screen for the SignBridge application.
/// Includes hybrid mode toggle, privacy dashboard, and app settings.

import 'package:flutter/material.dart';
import '../../features/hybrid_routing/hybrid_router.dart';
import '../../core/utils/performance_monitor.dart';
import '../theme/app_theme.dart';

/// Settings screen widget
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);
  
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _hybridRouter = HybridRouter();
  final _performanceMonitor = PerformanceMonitor.instance;
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: ListView(
        children: [
          // Hybrid Mode Section
          _buildSectionHeader('Hybrid Mode'),
          _buildHybridModeSettings(),
          
          Divider(),
          
          // Privacy Dashboard Section
          _buildSectionHeader('Privacy Dashboard'),
          _buildPrivacyDashboard(),
          
          Divider(),
          
          // Performance Section
          _buildSectionHeader('Performance'),
          _buildPerformanceStats(),
          
          Divider(),
          
          // About Section
          _buildSectionHeader('About'),
          _buildAboutSection(),
        ],
      ),
    );
  }
  
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          color: AppColors.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
  
  Widget _buildHybridModeSettings() {
    return FutureBuilder<Map<String, dynamic>>(
      future: Future.value(_hybridRouter.getStatistics()),
      builder: (context, snapshot) {
        final stats = snapshot.data;
        final cloudEnabled = stats?['config']?['cloudEnabled'] ?? false;
        
        return Column(
          children: [
            SwitchListTile(
              title: Text('Enable Cloud Processing'),
              subtitle: Text(
                'Use cloud AI for low-confidence gestures',
              ),
              value: cloudEnabled,
              onChanged: (value) async {
                if (value) {
                  await _hybridRouter.enableCloud();
                } else {
                  await _hybridRouter.disableCloud();
                }
                setState(() {});
              },
              secondary: Icon(
                cloudEnabled ? Icons.cloud : Icons.cloud_off,
                color: cloudEnabled ? AppColors.primary : AppColors.textHint,
              ),
            ),
            
            if (cloudEnabled) ...[
              ListTile(
                title: Text('Confidence Threshold'),
                subtitle: Text(
                  'Minimum confidence for local processing: '
                  '${((stats?['config']?['localConfidenceThreshold'] ?? 0.75) * 100).toInt()}%',
                ),
                trailing: Icon(Icons.tune),
                onTap: () => _showThresholdDialog(context),
              ),
              
              ListTile(
                title: Text('Cloud Timeout'),
                subtitle: Text(
                  '${stats?['config']?['cloudTimeout'] ?? 5000}ms',
                ),
                trailing: Icon(Icons.timer),
              ),
            ],
          ],
        );
      },
    );
  }
  
  Widget _buildPrivacyDashboard() {
    return FutureBuilder<Map<String, dynamic>>(
      future: Future.value(_hybridRouter.getStatistics()),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }
        
        final stats = snapshot.data!['stats'] as Map<String, dynamic>;
        final localRequests = stats['localRequests'] ?? 0;
        final cloudRequests = stats['cloudRequests'] ?? 0;
        final totalRequests = stats['totalRequests'] ?? 0;
        final localPercentage = stats['localPercentage'] ?? 0.0;
        final cloudPercentage = stats['cloudPercentage'] ?? 0.0;
        final cloudSuccessRate = stats['cloudSuccessRate'] ?? 0.0;
        
        return Column(
          children: [
            // Total requests
            ListTile(
              leading: Icon(Icons.analytics, color: AppColors.info),
              title: Text('Total Requests'),
              trailing: Text(
                '$totalRequests',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            
            // Local processing
            ListTile(
              leading: Icon(Icons.phone_android, color: AppColors.localProcessing),
              title: Text('Local Processing'),
              subtitle: Text('${localPercentage.toStringAsFixed(1)}%'),
              trailing: Text(
                '$localRequests',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            
            // Cloud processing
            ListTile(
              leading: Icon(Icons.cloud, color: AppColors.cloudProcessing),
              title: Text('Cloud Processing'),
              subtitle: Text('${cloudPercentage.toStringAsFixed(1)}%'),
              trailing: Text(
                '$cloudRequests',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            
            // Cloud success rate
            if (cloudRequests > 0)
              ListTile(
                leading: Icon(Icons.check_circle, color: AppColors.success),
                title: Text('Cloud Success Rate'),
                trailing: Text(
                  '${(cloudSuccessRate * 100).toStringAsFixed(1)}%',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
            
            // Visual breakdown
            Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Processing Breakdown',
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                  SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: totalRequests > 0 ? localPercentage / 100 : 0,
                      minHeight: 24,
                      backgroundColor: AppColors.cloudProcessing,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.localProcessing,
                      ),
                    ),
                  ),
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            color: AppColors.localProcessing,
                          ),
                          SizedBox(width: 4),
                          Text('Local'),
                        ],
                      ),
                      Row(
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            color: AppColors.cloudProcessing,
                          ),
                          SizedBox(width: 4),
                          Text('Cloud'),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Reset button
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: ElevatedButton.icon(
                onPressed: () {
                  _hybridRouter.resetStatistics();
                  setState(() {});
                },
                icon: Icon(Icons.refresh),
                label: Text('Reset Statistics'),
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 48),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
  
  Widget _buildPerformanceStats() {
    final stats = _performanceMonitor.getStats();
    
    return Column(
      children: [
        ListTile(
          leading: Icon(Icons.speed, color: AppColors.info),
          title: Text('Average Local Latency'),
          trailing: Text(
            '${stats['avgLocalLatency']?.toStringAsFixed(0) ?? 0}ms',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        
        ListTile(
          leading: Icon(Icons.cloud_queue, color: AppColors.info),
          title: Text('Average Cloud Latency'),
          trailing: Text(
            '${stats['avgCloudLatency']?.toStringAsFixed(0) ?? 0}ms',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        
        ListTile(
          leading: Icon(Icons.analytics, color: AppColors.info),
          title: Text('Total Processed'),
          trailing: Text(
            '${stats['totalProcessed'] ?? 0}',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
      ],
    );
  }
  
  Widget _buildAboutSection() {
    return Column(
      children: [
        ListTile(
          leading: Icon(Icons.info, color: AppColors.info),
          title: Text('Version'),
          trailing: Text('1.0.0'),
        ),
        
        ListTile(
          leading: Icon(Icons.code, color: AppColors.info),
          title: Text('Built with'),
          trailing: Text('Flutter + Cactus SDK'),
        ),
        
        ListTile(
          leading: Icon(Icons.privacy_tip, color: AppColors.success),
          title: Text('Privacy'),
          subtitle: Text('All processing is local by default'),
        ),
        
        ListTile(
          leading: Icon(Icons.description, color: AppColors.info),
          title: Text('Licenses'),
          trailing: Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () {
            showLicensePage(context: context);
          },
        ),
      ],
    );
  }
  
  Future<void> _showThresholdDialog(BuildContext context) async {
    final stats = _hybridRouter.getStatistics();
    final currentThreshold = stats['config']['localConfidenceThreshold'] ?? 0.75;
    
    double newThreshold = currentThreshold;
    
    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('Confidence Threshold'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Gestures below this confidence will use cloud processing',
              ),
              SizedBox(height: 16),
              Text(
                '${(newThreshold * 100).toInt()}%',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              Slider(
                value: newThreshold,
                min: 0.5,
                max: 0.95,
                divisions: 9,
                label: '${(newThreshold * 100).toInt()}%',
                onChanged: (value) {
                  setDialogState(() {
                    newThreshold = value;
                  });
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                await _hybridRouter.updateConfig(
                  HybridRoutingConfig(
                    localConfidenceThreshold: newThreshold,
                    cloudEnabled: true,
                  ),
                );
                Navigator.pop(context);
                setState(() {});
              },
              child: Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}