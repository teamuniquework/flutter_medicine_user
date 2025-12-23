import 'package:flutter/material.dart';
import 'package:flutter_medicine_user/checkout_screen.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class CartScreen extends StatefulWidget {
  final Map<int, int> medicineQuantities;
  final List<Map<String, dynamic>> medicines;

  const CartScreen({
    Key? key,
    required this.medicineQuantities,
    required this.medicines,
  }) : super(key: key);

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  Map<int, int> quantities = {};
  List<File> uploadedPrescriptions = [];
  bool showPrescriptionDialog = false;
  final ScrollController _scrollController = ScrollController();
  bool _isScrolled = false;

  @override
  void initState() {
    super.initState();
    quantities = Map.from(widget.medicineQuantities);
    _checkPrescriptionRequired();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.offset > 10 && !_isScrolled) {
      setState(() {
        _isScrolled = true;
      });
    } else if (_scrollController.offset <= 10 && _isScrolled) {
      setState(() {
        _isScrolled = false;
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _checkPrescriptionRequired() {
    // Check if any medicine requires prescription
    int prescriptionCount = 0;
    for (var entry in quantities.entries) {
      var medicine = widget.medicines.firstWhere((m) => m['id'] == entry.key);
      if (medicine['prescriptionRequired'] == true) {
        prescriptionCount++;
      }
    }

    if (prescriptionCount > 0) {
      setState(() {
        showPrescriptionDialog = true;
      });
    }
  }

  void _updateQuantity(int medicineId, int change) {
    setState(() {
      int currentQty = quantities[medicineId] ?? 0;
      int newQty = currentQty + change;

      if (newQty > 0) {
        quantities[medicineId] = newQty;
      } else {
        quantities.remove(medicineId);
      }
    });
  }

  double _calculateTotal() {
    double total = 0;
    for (var entry in quantities.entries) {
      var medicine = widget.medicines.firstWhere((m) => m['id'] == entry.key);
      String priceStr = medicine['discountedPrice'].replaceAll('₹', '');
      double price = double.tryParse(priceStr) ?? 0;
      total += price * entry.value;
    }
    return total;
  }

  double _calculateSavings() {
    double savings = 0;
    for (var entry in quantities.entries) {
      var medicine = widget.medicines.firstWhere((m) => m['id'] == entry.key);
      String originalPriceStr = medicine['originalPrice'].replaceAll('₹', '');
      String discountedPriceStr = medicine['discountedPrice'].replaceAll(
        '₹',
        '',
      );
      double originalPrice = double.tryParse(originalPriceStr) ?? 0;
      double discountedPrice = double.tryParse(discountedPriceStr) ?? 0;
      savings += (originalPrice - discountedPrice) * entry.value;
    }
    return savings;
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);

    if (pickedFile != null) {
      setState(() {
        uploadedPrescriptions.add(File(pickedFile.path));
      });
    }
  }

  void _showPrescriptionBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (BuildContext context, StateSetter setModalState) {
          return Stack(
            clipBehavior: Clip.none,
            children: [
              // Bottom sheet content
              _buildPrescriptionBottomSheet(setModalState),

              // Close button positioned above the bottom sheet
              Positioned(
                top: -60,
                left: 0,
                right: 0,
                child: Center(
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.3),
                            spreadRadius: 2,
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.close,
                        color: Color(0xFF0288D1),
                        size: 28,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildPrescriptionBottomSheet(StateSetter setModalState) {
    int prescriptionCount = 0;
    for (var entry in quantities.entries) {
      var medicine = widget.medicines.firstWhere((m) => m['id'] == entry.key);
      if (medicine['prescriptionRequired'] == true) {
        prescriptionCount++;
      }
    }

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),

            // Title
            const Text(
              'Upload Prescription',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 20),

            // Info container
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFE3F2FD),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  // Stacked medicine images like cards
                  SizedBox(
                    width: 80,
                    height: 65,
                    child: Stack(
                      children: [
                        // Third image (back)
                        if (quantities.length >= 3)
                          Positioned(
                            top: 0,
                            left: 20,
                            child: Container(
                              width: 55,
                              height: 55,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: const Color(0xFF0288D1),
                                  width: 2,
                                ),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(6),
                                child: Image.asset(
                                  widget.medicines.firstWhere(
                                    (m) =>
                                        m['id'] == quantities.keys.elementAt(2),
                                  )['image'],
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return const Icon(
                                      Icons.medication,
                                      color: Color(0xFF0288D1),
                                      size: 28,
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
                        // Second image (middle)
                        if (quantities.length >= 2)
                          Positioned(
                            top: 5,
                            left: 10,
                            child: Container(
                              width: 55,
                              height: 55,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: const Color(0xFF0288D1),
                                  width: 2,
                                ),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(6),
                                child: Image.asset(
                                  widget.medicines.firstWhere(
                                    (m) =>
                                        m['id'] == quantities.keys.elementAt(1),
                                  )['image'],
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return const Icon(
                                      Icons.medication,
                                      color: Color(0xFF0288D1),
                                      size: 28,
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
                        // First image (front)
                        Positioned(
                          top: 10,
                          left: 0,
                          child: Container(
                            width: 55,
                            height: 55,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: const Color(0xFF0288D1),
                                width: 1.5,
                              ),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: Image.asset(
                                widget.medicines.firstWhere(
                                  (m) => m['id'] == quantities.keys.first,
                                )['image'],
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return const Icon(
                                    Icons.medication,
                                    color: Color(0xFF0288D1),
                                    size: 28,
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Text
                  Expanded(
                    child: Text(
                      '${quantities.length} medicine${quantities.length > 1 ? 's' : ''} need a prescription',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Uploaded prescriptions
            if (uploadedPrescriptions.isNotEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: uploadedPrescriptions.map((file) {
                    return Stack(
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            image: DecorationImage(
                              image: FileImage(file),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Positioned(
                          top: 4,
                          right: 4,
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                uploadedPrescriptions.remove(file);
                              });
                              setModalState(() {});
                            },
                            child: Container(
                              width: 24,
                              height: 24,
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.close,
                                size: 16,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),

            // Question text
            const Text(
              'How do you want to proceed?',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () async {
                      final picker = ImagePicker();
                      final pickedFile = await picker.pickImage(
                        source: ImageSource.camera,
                      );

                      if (pickedFile != null) {
                        setState(() {
                          uploadedPrescriptions.add(File(pickedFile.path));
                        });
                        setModalState(() {});
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: const Color(0xFF0288D1),
                          width: 1.5,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: const Color(0xFFE3F2FD),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.camera_alt,
                              color: Color(0xFF0288D1),
                              size: 26,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Take photo of\nprescription',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: () async {
                      final picker = ImagePicker();
                      final pickedFile = await picker.pickImage(
                        source: ImageSource.gallery,
                      );

                      if (pickedFile != null) {
                        setState(() {
                          uploadedPrescriptions.add(File(pickedFile.path));
                        });
                        setModalState(() {});
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: const Color(0xFF0288D1),
                          width: 1.5,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: const Color(0xFFE3F2FD),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.photo_library,
                              color: Color(0xFF0288D1),
                              size: 26,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Choose from\nyour gallery',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Upload button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: uploadedPrescriptions.isEmpty
                    ? null
                    : () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LabTestCheckoutScreen(),
                          ),
                        );
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0288D1),
                  disabledBackgroundColor: Colors.grey[300],
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  'Upload and Pay ₹${_calculateTotal().toStringAsFixed(0)}',
                  style: TextStyle(
                    color: uploadedPrescriptions.isEmpty
                        ? Colors.grey[600]
                        : Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent, // Add this to prevent tint color
        elevation: _isScrolled ? 4 : 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF0288D1)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'My Cart',
          style: TextStyle(
            color: Color(0xFF0288D1),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: quantities.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shopping_cart_outlined,
                    size: 100,
                    color: Colors.grey[300],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Your cart is empty',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                // Delivery address
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border(
                      top: BorderSide(color: Color(0xFF0288D1)!, width: 1),
                      bottom: BorderSide(
                        color: const Color(0xFF0288D1),
                        width: 1,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        color: Color(0xFF0288D1),
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Delivery to Home',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                            Text(
                              'ILD Trade Center 122010...',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      TextButton(
                        onPressed: () {},
                        child: const Text(
                          'Change',
                          style: TextStyle(
                            color: Color(0xFF0288D1),
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    child: Column(
                      children: [
                        // Savings banner
                        Container(
                          margin: const EdgeInsets.all(16),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF0288D1), Color(0xFFB3E7FF)],
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.discount,
                                color: Colors.white,
                                size: 24,
                              ),
                              const SizedBox(width: 12),
                              const Text(
                                'Your Total Saving',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const Spacer(),
                              Text(
                                '₹${_calculateSavings().toStringAsFixed(0)}',
                                style: const TextStyle(
                                  color: Color(0xFF11A8F9),
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Cart items
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: quantities.length,
                          itemBuilder: (context, index) {
                            var entry = quantities.entries.elementAt(index);
                            var medicine = widget.medicines.firstWhere(
                              (m) => m['id'] == entry.key,
                            );
                            return _buildCartItem(medicine, entry.value);
                          },
                        ),

                        // Add items button
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: ElevatedButton.icon(
                              onPressed: () => Navigator.pop(context),
                              icon: const Icon(
                                Icons.add,
                                color: Colors.white,
                                size: 20,
                              ),
                              label: const Text(
                                'Add Items',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF0288D1),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(50),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 12,
                                ),
                                elevation: 0,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Use coupons
                        GestureDetector(
                          onTap: () {},
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 16),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF0288D1), Color(0xFFB3E7FF)],
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.local_offer,
                                  color: Colors.white,
                                  size: 22,
                                ),
                                const SizedBox(width: 12),
                                const Text(
                                  'Use Coupons',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const Spacer(),
                                const Icon(
                                  Icons.arrow_forward_ios,
                                  color: Colors.white,
                                  size: 18,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Bill summary with gradient
                        Container(
                          margin: const EdgeInsets.all(16),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [const Color(0xFFE3F2FD), Colors.white],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                            borderRadius: BorderRadius.circular(12),
                            // border: Border.all(
                            //   color: const Color(0xFF0288D1).withOpacity(0.3),
                            //   width: 1,
                            // ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Bill Summary :',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 12),
                              _buildBillRow(
                                'Item Total',
                                '₹${(_calculateTotal() + _calculateSavings()).toStringAsFixed(0)}',
                              ),
                              _buildBillRow(
                                'Discount',
                                '- ₹${_calculateSavings().toStringAsFixed(0)}',
                                isDiscount: true,
                              ),
                              const Divider(height: 24),
                              _buildBillRow(
                                'To Pay',
                                '₹${_calculateTotal().toStringAsFixed(0)}',
                                isBold: true,
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
      bottomNavigationBar: quantities.isEmpty
          ? null
          : Container(
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
                    _showPrescriptionBottomSheet();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0288D1),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Confirm and Pay',
                    style: TextStyle(
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

  Widget _buildCartItem(Map<String, dynamic> medicine, int quantity) {
    return Container(
      margin: const EdgeInsets.only(left: 16, right: 16, bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Image
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFF0288D1), width: 1.5),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                medicine['image'],
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(
                    Icons.medication,
                    size: 40,
                    color: Color(0xFF0288D1),
                  );
                },
              ),
            ),
          ),

          const SizedBox(width: 12),

          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  medicine['name'],
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                // Price section with both original and discounted prices
                Row(
                  children: [
                    Text(
                      medicine['discountedPrice'],
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0288D1),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      medicine['originalPrice'],
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[500],
                        decoration: TextDecoration.lineThrough,
                        decorationThickness: 2,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Quantity controls with circular design and border
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFF0288D1), width: 1.5),
              borderRadius: BorderRadius.circular(50),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Minus button
                _buildQuantityButton(
                  Icons.remove,
                  () => _updateQuantity(medicine['id'], -1),
                ),
                Container(
                  constraints: const BoxConstraints(minWidth: 30),
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    quantity.toString(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color(0xFF0288D1),
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
                // Plus button
                _buildQuantityButton(
                  Icons.add,
                  () => _updateQuantity(medicine['id'], 1),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper method for circular quantity buttons
  Widget _buildQuantityButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // Layer 1: Outer shadow
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    spreadRadius: 1,
                    blurRadius: 5,
                    offset: const Offset(2, 3),
                  ),
                ],
              ),
              // Layer 2: First white circle
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                // Layer 3: Middle shadow
                child: Container(
                  margin: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        blurRadius: 3,
                        offset: const Offset(0, 0),
                      ),
                    ],
                  ),
                  // Layer 4: Inner white circle with shadow
                  child: Container(
                    margin: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.white.withOpacity(0.5),
                          blurRadius: 3,
                          offset: const Offset(1, 1),
                        ),
                      ],
                    ),
                    // Layer 5: Icon (center it properly)
                    child: Center(
                      child: Icon(
                        icon,
                        size: 16,
                        color: const Color(0xFF0288D1),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBillRow(
    String label,
    String value, {
    bool isDiscount = false,
    bool isBold = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              color: isDiscount ? Colors.green : Colors.black87,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
