import 'package:flutter/material.dart';

class LabTestCheckoutScreen extends StatefulWidget {
  const LabTestCheckoutScreen({Key? key}) : super(key: key);

  @override
  State<LabTestCheckoutScreen> createState() => _LabTestCheckoutScreenState();
}

class _LabTestCheckoutScreenState extends State<LabTestCheckoutScreen> {
  int _currentStep = 0;
  String selectedTimeSlot = 'Morning';
  final ScrollController _scrollController = ScrollController();

  // Dummy lab tests data
  final List<Map<String, dynamic>> labTests = [
    {
      'name': 'Complete Blood Count (CBC)',
      'price': 450,
      'description': 'Measures different components of blood',
      'icon': Icons.bloodtype,
      'color': const Color(0xFFFFEBEE),
      'iconColor': const Color(0xFFE53935),
    },
    {
      'name': 'Lipid Profile',
      'price': 850,
      'description': 'Checks cholesterol and triglycerides levels',
      'icon': Icons.favorite,
      'color': const Color(0xFFF3E5F5),
      'iconColor': const Color(0xFF8E24AA),
    },
    {
      'name': 'Thyroid Function Test',
      'price': 650,
      'description': 'Evaluates thyroid gland function',
      'icon': Icons.healing,
      'color': const Color(0xFFE1F5FE),
      'iconColor': const Color(0xFF039BE5),
    },
  ];

  double _calculateTotal() {
    return labTests.fold(0, (sum, test) => sum + test['price']);
  }

  double _calculateFinalTotal() {
    return _calculateTotal() -
        50 +
        100; // Subtotal - Discount + Home Collection
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Lab Test Checkout',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          // Header section with subtitle
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Please review your selected lab tests and proceed to payment',
                  style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                ),
                const SizedBox(height: 16),
                // Stepper
                _buildStepper(),
              ],
            ),
          ),

          // Content based on current step
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 100),
                child: _buildStepContent(),
              ),
            ),
          ),
        ],
      ),
      // Bottom button
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 10,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: SafeArea(
          child: ElevatedButton(
            onPressed: () {
              if (_currentStep < 3) {
                setState(() {
                  _currentStep++;
                });
              } else {
                // Final payment action
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Payment Successful!'),
                    backgroundColor: Colors.green,
                  ),
                );
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0288D1),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(50),
              ),
              elevation: 0,
            ),
            child: Text(
              _currentStep < 3
                  ? 'Continue'
                  : 'Pay ₹${_calculateFinalTotal().toStringAsFixed(0)}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStepper() {
    return Row(
      children: [
        _buildStepItem(1, 'Review', _currentStep >= 0),
        _buildStepConnector(_currentStep >= 1),
        _buildStepItem(2, 'Details', _currentStep >= 1),
        _buildStepConnector(_currentStep >= 2),
        _buildStepItem(3, 'Time', _currentStep >= 2),
        _buildStepConnector(_currentStep >= 3),
        _buildStepItem(4, 'Payment', _currentStep >= 3),
      ],
    );
  }

  Widget _buildStepItem(int step, String label, bool isActive) {
    return Expanded(
      child: Column(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: isActive ? const Color(0xFF0288D1) : Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFF0288D1), width: 2),
              boxShadow: isActive
                  ? [
                      BoxShadow(
                        color: const Color(0xFF0288D1).withOpacity(0.3),
                        blurRadius: 8,
                        spreadRadius: 2,
                      ),
                    ]
                  : [],
            ),
            child: Center(
              child: Text(
                step.toString(),
                style: TextStyle(
                  color: isActive ? Colors.white : const Color(0xFF0288D1),
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
              color: isActive ? const Color(0xFF0288D1) : Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepConnector(bool isActive) {
    return Expanded(
      child: Container(
        height: 2,
        margin: const EdgeInsets.only(bottom: 20),
        color: isActive ? const Color(0xFF0288D1) : Colors.grey[300],
      ),
    );
  }

  Widget _buildStepContent() {
    switch (_currentStep) {
      case 0:
        return _buildReviewTests();
      case 1:
        return _buildPatientDetails();
      case 2:
        return _buildTimeSlot();
      case 3:
        return _buildPaymentSummary();
      default:
        return Container();
    }
  }

  Widget _buildReviewTests() {
    return Column(
      children: [
        const SizedBox(height: 16),
        // Selected Tests
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Icon(
                      Icons.science,
                      color: Color(0xFF0288D1),
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Selected Lab Tests',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE3F2FD),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${labTests.length} Tests',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF0288D1),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              ...labTests.map((test) => _buildTestCard(test)).toList(),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Total Amount Card
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF0288D1), Color(0xFF03A9F4)],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0288D1).withOpacity(0.3),
                spreadRadius: 2,
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Total Amount',
                    style: TextStyle(fontSize: 14, color: Colors.white70),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Including all tests',
                    style: TextStyle(fontSize: 12, color: Colors.white60),
                  ),
                ],
              ),
              Text(
                '₹${_calculateTotal().toStringAsFixed(0)}',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTestCard(Map<String, dynamic> test) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey[200]!, width: 1)),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: test['color'],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(test['icon'], color: test['iconColor'], size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  test['name'],
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  test['description'],
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            '₹${test['price']}',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0288D1),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPatientDetails() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Icon(Icons.person, color: Color(0xFF0288D1), size: 24),
                const SizedBox(width: 8),
                const Text(
                  'Patient Details',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildDetailField(
                  Icons.account_circle,
                  'Full Name',
                  'John Doe',
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildDetailField(Icons.cake, 'Age', '32 Years'),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildDetailField(
                        Icons.person_outline,
                        'Gender',
                        'Male',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildDetailField(
                  Icons.phone,
                  'Phone Number',
                  '+91 9876543210',
                ),
                const SizedBox(height: 16),
                _buildDetailField(Icons.email, 'Email', 'john.doe@email.com'),
                const SizedBox(height: 16),
                _buildDetailField(
                  Icons.location_on,
                  'Address',
                  'ILD Trade Center, Sector 47, Gurugram - 122010',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailField(IconData icon, String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: Colors.grey[600]),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: const Color(0xFFF8F9FA),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!, width: 1),
          ),
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTimeSlot() {
    final timeSlots = [
      {
        'period': 'Morning',
        'time': '8:00 AM - 11:00 AM',
        'icon': Icons.wb_sunny,
      },
      {
        'period': 'Afternoon',
        'time': '12:00 PM - 3:00 PM',
        'icon': Icons.wb_sunny_outlined,
      },
      {
        'period': 'Evening',
        'time': '4:00 PM - 7:00 PM',
        'icon': Icons.nights_stay,
      },
    ];

    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Icon(
                  Icons.calendar_today,
                  color: Color(0xFF0288D1),
                  size: 24,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Select Time Slot',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: timeSlots
                  .map(
                    (slot) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _buildTimeSlotCard(
                        slot['period'] as String,
                        slot['time'] as String,
                        slot['icon'] as IconData,
                        selectedTimeSlot == slot['period'],
                        () {
                          setState(() {
                            selectedTimeSlot = slot['period'] as String;
                          });
                        },
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeSlotCard(
    String period,
    String time,
    IconData icon,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: isSelected
              ? const LinearGradient(
                  colors: [Color(0xFF0288D1), Color(0xFF03A9F4)],
                )
              : null,
          color: isSelected ? null : const Color(0xFFF8F9FA),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFF0288D1) : Colors.grey[300]!,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.white.withOpacity(0.2)
                    : const Color(0xFFE3F2FD),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: isSelected ? Colors.white : const Color(0xFF0288D1),
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    period,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    time,
                    style: TextStyle(
                      fontSize: 13,
                      color: isSelected ? Colors.white70 : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle, color: Colors.white, size: 28),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentSummary() {
    return Column(
      children: [
        const SizedBox(height: 16),
        // Order Summary
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Icon(
                      Icons.receipt_long,
                      color: Color(0xFF0288D1),
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Order Summary',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildSummaryRow(Icons.person, 'Patient Name', 'John Doe'),
                    const SizedBox(height: 12),
                    _buildSummaryRow(
                      Icons.access_time,
                      'Time Slot',
                      '$selectedTimeSlot (${_getTimeSlotTime()})',
                    ),
                    const SizedBox(height: 12),
                    _buildSummaryRow(
                      Icons.science,
                      'Number of Tests',
                      '${labTests.length} Tests',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Bill Summary
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [const Color(0xFFE3F2FD), Colors.white],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.circular(16),
            // border: Border.all(
            //   color: const Color(0xFF0288D1).withOpacity(0.3),
            //   width: 1,
            // ),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.calculate, color: Color(0xFF0288D1), size: 24),
                    SizedBox(width: 8),
                    Text(
                      'Bill Summary',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildBillRow(
                  'Subtotal',
                  '₹${_calculateTotal().toStringAsFixed(0)}',
                ),
                _buildBillRow('Discount', '- ₹50', isDiscount: true),
                _buildBillRow('Home Collection Fee', '₹100'),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Divider(height: 1, thickness: 1),
                ),
                _buildBillRow(
                  'Total Amount',
                  '₹${_calculateFinalTotal().toStringAsFixed(0)}',
                  isBold: true,
                  isTotal: true,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: const Color(0xFF0288D1)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBillRow(
    String label,
    String value, {
    bool isDiscount = false,
    bool isBold = false,
    bool isTotal = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isBold ? 16 : 14,
              color: isTotal ? Colors.black87 : Colors.grey[700],
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isBold ? 18 : 14,
              color: isDiscount
                  ? Colors.green
                  : isTotal
                  ? const Color(0xFF0288D1)
                  : Colors.black87,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  String _getTimeSlotTime() {
    switch (selectedTimeSlot) {
      case 'Morning':
        return '8:00 AM - 11:00 AM';
      case 'Afternoon':
        return '12:00 PM - 3:00 PM';
      case 'Evening':
        return '4:00 PM - 7:00 PM';
      default:
        return '';
    }
  }
}
