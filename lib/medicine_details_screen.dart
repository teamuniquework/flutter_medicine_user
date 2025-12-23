import 'package:flutter/material.dart';

class MedicineDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> medicine;
  final Function(int medicineId, int quantity)? onAddToCart;

  const MedicineDetailsScreen({
    Key? key,
    required this.medicine,
    this.onAddToCart,
  }) : super(key: key);

  @override
  State<MedicineDetailsScreen> createState() => _MedicineDetailsScreenState();
}

class _MedicineDetailsScreenState extends State<MedicineDetailsScreen> {
  int _quantity = 1;

  void _updateQuantity(int change) {
    setState(() {
      _quantity = (_quantity + change).clamp(1, 99);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Top section with image and details overlay
          Expanded(
            child: SingleChildScrollView(
              child: Stack(
                children: [
                  // Image section with back, favorite, and share buttons
                  Column(
                    children: [
                      Stack(
                        children: [
                          // Medicine image
                          Container(
                            width: double.infinity,
                            height: 400,
                            child: Image.asset(
                              widget.medicine['image'],
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return const Center(
                                  child: Icon(
                                    Icons.medication,
                                    size: 100,
                                    color: Color(0xFF0288D1),
                                  ),
                                );
                              },
                            ),
                          ),
                          // Top action buttons
                          SafeArea(
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  _buildIconButton(
                                    Icons.arrow_back,
                                    () => Navigator.pop(context),
                                  ),
                                  Row(
                                    children: [
                                      _buildIconButton(
                                        Icons.favorite_rounded,
                                        () {
                                          print('Favorite tapped');
                                        },
                                      ),
                                      const SizedBox(width: 12),
                                      _buildIconButton(
                                        Icons.share_outlined,
                                        () {
                                          print('Share tapped');
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      // Extra space for the overlaying card content
                      const SizedBox(height: 200),
                    ],
                  ),

                  // Medicine details card overlaying the image
                  Positioned(
                    top: 376,
                    left: 0,
                    right: 0,
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [const Color(0xFFE3F2FD), Colors.white],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          stops: const [0.0, 0.6],
                        ),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(24),
                          topRight: Radius.circular(24),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 10,
                            offset: const Offset(0, -2),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Medicine name and price
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        widget.medicine['name'],
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black87,
                                          height: 1.3,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      const Text(
                                        'Alembic Pharmaceuticals Ltd',
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Colors.grey,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      const Text(
                                        'Telmisartan (20mg)',
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      widget.medicine['discountedPrice'],
                                      style: const TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF0288D1),
                                      ),
                                    ),
                                    Text(
                                      widget.medicine['originalPrice'],
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.grey[400],
                                        decoration: TextDecoration.lineThrough,
                                        decorationThickness: 2,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            // Prescription Required button
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF0288D1),
                                    Color(0xFF90DBFE),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Prescription Required',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Icon(
                                    Icons.file_upload_outlined,
                                    color: Color(0xFF0D9CE9),
                                    size: 20,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),

                            // About Product section
                            const Text(
                              'About Product',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 8),
                            RichText(
                              text: TextSpan(
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.black87,
                                  height: 1.5,
                                ),
                                children: [
                                  const TextSpan(
                                    text:
                                        'Tellzy 20 Tablet is a prescription antihypertensive medicine that contains Telmisartan 20 mg as its active ingredient. It is used for the treatment of high blood pressure (hypertension), angiotensin II receptor blockers (ARBs).',
                                  ),
                                  TextSpan(
                                    text: ' Read more',
                                    style: const TextStyle(
                                      color: Color(0xFF0288D1),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bottom section with quantity and add to cart
          Container(
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
              top: false,
              child: Row(
                children: [
                  // Quantity controls with circular design
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: const Color(0xFF0288D1),
                        width: 1.5,
                      ),
                      borderRadius: BorderRadius.circular(50),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 4,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildQuantityButton(
                          Icons.remove,
                          () => _updateQuantity(-1),
                        ),
                        Container(
                          constraints: const BoxConstraints(minWidth: 40),
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Text(
                            _quantity.toString(),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Color(0xFF0288D1),
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        _buildQuantityButton(
                          Icons.add,
                          () => _updateQuantity(1),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Add to Cart button
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        // Add to cart callback
                        if (widget.onAddToCart != null) {
                          widget.onAddToCart!(widget.medicine['id'], _quantity);
                        }

                        // Show success message
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Row(
                              children: [
                                const Icon(
                                  Icons.check_circle,
                                  color: Colors.white,
                                ),
                                const SizedBox(width: 12),
                                Text('$_quantity item(s) added to cart'),
                              ],
                            ),
                            backgroundColor: Colors.green,
                            duration: const Duration(seconds: 2),
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        );

                        // Reset quantity to 1 after adding
                        setState(() {
                          _quantity = 1;
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0288D1),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Add To Cart',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIconButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
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
                  margin: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.3),
                        blurRadius: 3,
                        offset: const Offset(0, 0),
                      ),
                    ],
                  ),
                  // Layer 4: Inner white circle with shadow
                  child: Container(
                    margin: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.white.withOpacity(0.6),
                          blurRadius: 3,
                          offset: const Offset(2, 2),
                        ),
                      ],
                    ),
                    // Layer 5: Icon (center it properly)
                    child: Center(
                      child: Icon(
                        icon,
                        size: 22,
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

  // Circular quantity button (same design as cart)
  Widget _buildQuantityButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
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
                        size: 18,
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
}
