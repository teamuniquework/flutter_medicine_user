import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_medicine_user/cart_screen.dart';
import 'package:flutter_medicine_user/custom_bottom_nav_bar.dart';
import 'package:flutter_medicine_user/medicine_details_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  int _selectedIndex = 0;
  int _currentBannerIndex = 0;
  final PageController _bannerController = PageController();
  final ScrollController _scrollController = ScrollController();
  final Map<String, bool> _imageLoadStatus = {};

  // Animation controllers
  late AnimationController _headerAnimationController;
  late AnimationController _searchAnimationController;
  late AnimationController _bannerAnimationController;
  late AnimationController _browseAnimationController;
  late AnimationController _medicineCategoryAnimationController;
  late AnimationController _popularMedicineAnimationController;
  late AnimationController _labTestAnimationController;

  // Animations
  late Animation<Offset> _headerSlideAnimation;
  late Animation<double> _headerFadeAnimation;
  late Animation<Offset> _searchSlideAnimation;
  late Animation<double> _searchFadeAnimation;
  late Animation<Offset> _bannerSlideAnimation;
  late Animation<double> _bannerFadeAnimation;
  late Animation<Offset> _browseSlideAnimation;
  late Animation<double> _browseFadeAnimation;
  late Animation<Offset> _medicineCategorySlideAnimation;
  late Animation<double> _medicineCategoryFadeAnimation;
  late Animation<Offset> _popularMedicineSlideAnimation;
  late Animation<double> _popularMedicineFadeAnimation;
  late Animation<Offset> _labTestSlideAnimation;
  late Animation<double> _labTestFadeAnimation;

  // Cart quantities for medicines
  Map<int, int> medicineQuantities = {};

  Timer? _bannerTimer;

  // Scroll-based animation states
  bool _popularMedicineVisible = false;
  bool _labTestVisible = false;

  // Cart animation
  final GlobalKey _cartIconKey = GlobalKey();
  OverlayEntry? _flyingImageOverlay;
  int _cartItemCount = 0;

  // Banner Data
  final List<Map<String, dynamic>> banners = [
    {
      'title': 'Get 20% OFF',
      'subtitle': 'On your first order',
      'buttonText': 'Order Now',
      'gradient': [Color(0xFF0288D1), Color(0xFF03A9F4)],
      'icon': Icons.local_pharmacy,
    },
    {
      'title': 'Free Delivery',
      'subtitle': 'On orders above ₹500',
      'buttonText': 'Shop Now',
      'gradient': [Color(0xFF7B1FA2), Color(0xFF9C27B0)],
      'icon': Icons.local_shipping,
    },
  ];

  // Medicine Categories Data
  final List<Map<String, dynamic>> medicineCategories = [
    {
      'name': 'Pain Relief',
      'icon': Icons.medical_services,
      'color': const Color(0xFFFFEBEE),
      'iconColor': const Color(0xFFE53935),
    },
    {
      'name': 'Cold & Flu',
      'icon': Icons.ac_unit,
      'color': const Color(0xFFE3F2FD),
      'iconColor': const Color(0xFF1E88E5),
    },
    {
      'name': 'Vitamins',
      'icon': Icons.energy_savings_leaf,
      'color': const Color(0xFFF1F8E9),
      'iconColor': const Color(0xFF7CB342),
    },
    {
      'name': 'Digestive',
      'icon': Icons.restaurant,
      'color': const Color(0xFFFFF3E0),
      'iconColor': const Color(0xFFFB8C00),
    },
  ];

  // Popular Medicines Data with images and discounts
  final List<Map<String, dynamic>> popularMedicines = [
    {
      'id': 0,
      'name': 'Paracetamol tablate 500mg',
      'image': 'assets/images/medicine1.jpeg',
      'originalPrice': '₹50',
      'discountedPrice': '₹45',
      'discount': '10% OFF',
      'rating': 4.5,
    },
    {
      'id': 1,
      'name': 'Crocin Advance',
      'image': 'assets/images/medicine2.jpeg',
      'originalPrice': '₹40',
      'discountedPrice': '₹32',
      'discount': '20% OFF',
      'rating': 4.3,
    },
    {
      'id': 2,
      'name': 'Dolo 650',
      'image': 'assets/images/medicine3.jpeg',
      'originalPrice': '₹35',
      'discountedPrice': '₹28',
      'discount': '15% OFF',
      'rating': 4.7,
    },
  ];

  // Lab Test Categories Data
  final List<Map<String, dynamic>> labTestCategories = [
    {
      'name': 'Blood Test',
      'icon': Icons.bloodtype,
      'color': const Color(0xFFFFEBEE),
      'iconColor': const Color(0xFFE53935),
    },
    {
      'name': 'Diabetes',
      'icon': Icons.healing,
      'color': const Color(0xFFF3E5F5),
      'iconColor': const Color(0xFF8E24AA),
    },
    {
      'name': 'Thyroid',
      'icon': Icons.favorite,
      'color': const Color(0xFFE1F5FE),
      'iconColor': const Color(0xFF039BE5),
    },
    {
      'name': 'X-Ray',
      'icon': Icons.camera_alt,
      'color': const Color(0xFFFFF8E1),
      'iconColor': const Color(0xFFFFA000),
    },
  ];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startBannerAutoScroll();
    _scrollController.addListener(_onScroll);
  }

  void _initializeAnimations() {
    // Header animation
    _headerAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _headerSlideAnimation =
        Tween<Offset>(begin: const Offset(0, -0.3), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _headerAnimationController,
            curve: Curves.easeOut,
          ),
        );
    _headerFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _headerAnimationController, curve: Curves.easeIn),
    );

    // Search bar animation
    _searchAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _searchSlideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _searchAnimationController,
            curve: Curves.easeOut,
          ),
        );
    _searchFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _searchAnimationController, curve: Curves.easeIn),
    );

    // Banner animation
    _bannerAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _bannerSlideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _bannerAnimationController,
            curve: Curves.easeOut,
          ),
        );
    _bannerFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _bannerAnimationController, curve: Curves.easeIn),
    );

    // Browse buttons animation
    _browseAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _browseSlideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _browseAnimationController,
            curve: Curves.easeOut,
          ),
        );
    _browseFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _browseAnimationController, curve: Curves.easeIn),
    );

    // Medicine category animation (triggers immediately on load)
    _medicineCategoryAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _medicineCategorySlideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _medicineCategoryAnimationController,
            curve: Curves.easeOut,
          ),
        );
    _medicineCategoryFadeAnimation = Tween<double>(begin: 0.0, end: 1.0)
        .animate(
          CurvedAnimation(
            parent: _medicineCategoryAnimationController,
            curve: Curves.easeIn,
          ),
        );

    // Popular medicine animation (triggers on scroll)
    _popularMedicineAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _popularMedicineSlideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _popularMedicineAnimationController,
            curve: Curves.easeOut,
          ),
        );
    _popularMedicineFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _popularMedicineAnimationController,
        curve: Curves.easeIn,
      ),
    );

    // Lab test animation (triggers on scroll)
    _labTestAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _labTestSlideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _labTestAnimationController,
            curve: Curves.easeOut,
          ),
        );
    _labTestFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _labTestAnimationController,
        curve: Curves.easeIn,
      ),
    );

    // Start initial animations with staggered delays for above-the-fold content
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) _headerAnimationController.forward();
    });
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) _searchAnimationController.forward();
    });
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _bannerAnimationController.forward();
    });
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) _browseAnimationController.forward();
    });
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) _medicineCategoryAnimationController.forward();
    });
  }

  void _onScroll() {
    final scrollOffset = _scrollController.offset;

    // Trigger popular medicine animation when it's about to come into view
    if (scrollOffset > 50 && !_popularMedicineVisible) {
      setState(() => _popularMedicineVisible = true);
      _popularMedicineAnimationController.forward();
    }

    // Trigger lab test animation when it's about to come into view
    if (scrollOffset > 400 && !_labTestVisible) {
      setState(() => _labTestVisible = true);
      _labTestAnimationController.forward();
    }
  }

  void _startBannerAutoScroll() {
    _bannerTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (_currentBannerIndex < banners.length - 1) {
        _currentBannerIndex++;
      } else {
        _currentBannerIndex = 0;
      }

      _bannerController.animateToPage(
        _currentBannerIndex,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _bannerTimer?.cancel();
    _bannerController.dispose();
    _scrollController.dispose();
    _headerAnimationController.dispose();
    _searchAnimationController.dispose();
    _bannerAnimationController.dispose();
    _browseAnimationController.dispose();
    _medicineCategoryAnimationController.dispose();
    _popularMedicineAnimationController.dispose();
    _labTestAnimationController.dispose();
    _flyingImageOverlay?.remove();
    super.dispose();
  }

  void _updateQuantity(int medicineId, int change) {
    setState(() {
      int currentQty = medicineQuantities[medicineId] ?? 0;
      int newQty = currentQty + change;

      if (newQty > 0) {
        medicineQuantities[medicineId] = newQty;
        // Increment cart count when adding item
        if (change > 0) {
          _cartItemCount++;
        }
      } else {
        medicineQuantities.remove(medicineId);
        // Decrement cart count when removing item
        if (change < 0 && _cartItemCount > 0) {
          _cartItemCount--;
        }
      }

      print(
        'Medicine $medicineId quantity: ${medicineQuantities[medicineId] ?? 0}',
      );
    });
  }

  // Animate product image flying to cart
  // Animate product image flying to cart
  void _animateProductToCart(
    GlobalKey productKey,
    String imageUrl,
    int medicineId,
  ) {
    // Update quantity IMMEDIATELY before animation
    _updateQuantity(medicineId, 1);

    // Get cart icon position
    final cartBox =
        _cartIconKey.currentContext?.findRenderObject() as RenderBox?;
    if (cartBox == null) return;

    final cartPosition = cartBox.localToGlobal(Offset.zero);

    // Get product image position
    final productBox =
        productKey.currentContext?.findRenderObject() as RenderBox?;
    if (productBox == null) return;

    final productPosition = productBox.localToGlobal(Offset.zero);
    final productSize = productBox.size;

    // Create overlay for flying image
    _flyingImageOverlay = OverlayEntry(
      builder: (context) => _FlyingImage(
        imageUrl: imageUrl,
        startPosition: Offset(
          productPosition.dx + productSize.width / 2 - 40,
          productPosition.dy + productSize.height / 2 - 40,
        ),
        endPosition: Offset(
          cartPosition.dx + cartBox.size.width / 2 - 20,
          cartPosition.dy + cartBox.size.height / 2 - 20,
        ),
        onComplete: () {
          _flyingImageOverlay?.remove();
          _flyingImageOverlay = null;
          // Animation complete - no need to update quantity again
        },
      ),
    );

    Overlay.of(context).insert(_flyingImageOverlay!);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          controller: _scrollController,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Location and action buttons row with animation
                SlideTransition(
                  position: _headerSlideAnimation,
                  child: FadeTransition(
                    opacity: _headerFadeAnimation,
                    child: Row(
                      children: [
                        const Icon(
                          Icons.location_on,
                          color: Color(0xFF0288D1),
                          size: 24,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Gurugram,',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Text(
                          ' 123456',
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                        const Spacer(),
                        _buildIconButton(Icons.notifications),
                        const SizedBox(width: 12),
                        _buildCartIconWithBadge(),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 17),

                // Search Bar with animation
                SlideTransition(
                  position: _searchSlideAnimation,
                  child: FadeTransition(
                    opacity: _searchFadeAnimation,
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: const Color(0xFF0288D1),
                          width: 1.5,
                        ),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Search for medicines & lab tests...',
                          hintStyle: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 14,
                          ),
                          prefixIcon: const Icon(
                            Icons.search,
                            color: Color(0xFF0288D1),
                            size: 28,
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 14,
                          ),
                        ),
                        onTap: () {
                          print('Search tapped');
                        },
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Slideable Banner with animation
                SlideTransition(
                  position: _bannerSlideAnimation,
                  child: FadeTransition(
                    opacity: _bannerFadeAnimation,
                    child: _buildSlideableBanner(),
                  ),
                ),
                const SizedBox(height: 20),

                // Browse buttons with animation
                SlideTransition(
                  position: _browseSlideAnimation,
                  child: FadeTransition(
                    opacity: _browseFadeAnimation,
                    child: Row(
                      children: [
                        Expanded(
                          child: _buildBrowseButton(
                            'Browse Medicine',
                            Icons.medical_services,
                            () {
                              print('Browse Medicine tapped');
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildBrowseButton(
                            'Browse Lab Test',
                            Icons.science,
                            () {
                              print('Browse Lab Test tapped');
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Medicine Categories Section with animation (loads immediately)
                SlideTransition(
                  position: _medicineCategorySlideAnimation,
                  child: FadeTransition(
                    opacity: _medicineCategoryFadeAnimation,
                    child: Column(
                      children: [
                        _buildSectionHeader('Medicine Categories', () {
                          print('View all medicine categories');
                        }),
                        const SizedBox(height: 12),
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 12,
                                childAspectRatio: 1.8,
                              ),
                          itemCount: medicineCategories.length,
                          itemBuilder: (context, index) {
                            return _buildCategoryCard(
                              medicineCategories[index]['name'],
                              medicineCategories[index]['icon'],
                              medicineCategories[index]['color'],
                              medicineCategories[index]['iconColor'],
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Popular Medicines Section with animation (loads on scroll)
                SlideTransition(
                  position: _popularMedicineSlideAnimation,
                  child: FadeTransition(
                    opacity: _popularMedicineFadeAnimation,
                    child: Column(
                      children: [
                        _buildSectionHeader('Popular Medicines', () {
                          print('View all popular medicines');
                        }),
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 240,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: popularMedicines.length,
                            itemBuilder: (context, index) {
                              return _buildMedicineCard(
                                popularMedicines[index],
                                index < popularMedicines.length - 1,
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Lab Test Categories Section with animation (loads on scroll)
                SlideTransition(
                  position: _labTestSlideAnimation,
                  child: FadeTransition(
                    opacity: _labTestFadeAnimation,
                    child: Column(
                      children: [
                        _buildSectionHeader('Recommended Lab Test', () {
                          print('View all lab tests');
                        }),
                        const SizedBox(height: 12),
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 12,
                                childAspectRatio: 1.8,
                              ),
                          itemCount: labTestCategories.length,
                          itemBuilder: (context, index) {
                            return _buildCategoryCard(
                              labTestCategories[index]['name'],
                              labTestCategories[index]['icon'],
                              labTestCategories[index]['color'],
                              labTestCategories[index]['iconColor'],
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: CustomBottomNavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  // Build icon button with shadow
  Widget _buildIconButton(IconData icon) {
    return GestureDetector(
      onTap: () {
        print('$icon tapped');
      },
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
                        color: Colors.grey.withOpacity(0.2),
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
                          color: Colors.white.withOpacity(0.5),
                          blurRadius: 3,
                          offset: const Offset(2, 2),
                        ),
                      ],
                    ),
                    // Layer 5: Icon (center it properly)
                    child: Center(
                      child: Icon(
                        icon,
                        size: 24,
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

  // Build cart icon with badge
  Widget _buildCartIconWithBadge() {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CartScreen(
              medicineQuantities: medicineQuantities,
              medicines: popularMedicines,
            ),
          ),
        ).then((_) {
          // Refresh the UI when returning from cart
          setState(() {});
        });
      },
      child: Container(
        key: _cartIconKey,
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
              // Layer 2: First white circle with shadow
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
                        color: Colors.grey.withOpacity(0.2),
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
                          color: Colors.white.withOpacity(0.5),
                          blurRadius: 3,
                          offset: const Offset(2, 2),
                        ),
                      ],
                    ),
                    // Layer 5: Icon (center it properly)
                    child: const Center(
                      child: Icon(
                        Icons.shopping_cart,
                        size: 24,
                        color: Color(0xFF0288D1),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            // Badge
            if (_cartItemCount > 0)
              Positioned(
                right: -2,
                top: -2,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  constraints: const BoxConstraints(
                    minWidth: 20,
                    minHeight: 20,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE53935),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: Center(
                    child: Text(
                      _cartItemCount > 99 ? '99+' : _cartItemCount.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        height: 1,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // Build slideable banner
  Widget _buildSlideableBanner() {
    return Column(
      children: [
        SizedBox(
          height: 140,
          child: PageView.builder(
            controller: _bannerController,
            onPageChanged: (index) {
              setState(() {
                _currentBannerIndex = index;
              });
            },
            itemCount: banners.length,
            physics: const BouncingScrollPhysics(),
            pageSnapping: true,
            itemBuilder: (context, index) {
              return _buildBannerItem(banners[index]);
            },
          ),
        ),
        const SizedBox(height: 12),
        // Indicator dots
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            banners.length,
            (index) => AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: _currentBannerIndex == index ? 24 : 8,
              height: 8,
              decoration: BoxDecoration(
                color: _currentBannerIndex == index
                    ? const Color(0xFF0288D1)
                    : Colors.grey[300],
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Build individual banner item
  Widget _buildBannerItem(Map<String, dynamic> banner) {
    return GestureDetector(
      onTap: () {
        print('Banner tapped: ${banner['title']}');
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: banner['gradient'],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Stack(
          children: [
            Positioned(
              right: 15,
              bottom: 5,
              child: Icon(
                banner['icon'],
                size: 90,
                color: Colors.white.withOpacity(0.2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    banner['title'],
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    banner['subtitle'],
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      banner['buttonText'],
                      style: TextStyle(
                        color: banner['gradient'][0],
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Build browse button
  Widget _buildBrowseButton(String text, IconData icon, VoidCallback onTap) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: Color(0xFF0288D1), width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        padding: const EdgeInsets.symmetric(vertical: 14),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: const Color(0xFF0288D1), size: 20),
          const SizedBox(width: 8),
          Text(
            text,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // Build section header
  Widget _buildSectionHeader(String title, VoidCallback onViewAll) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        TextButton(
          onPressed: onViewAll,
          child: const Text(
            'View all >',
            style: TextStyle(color: Color(0xFF0288D1), fontSize: 14),
          ),
        ),
      ],
    );
  }

  // Build category card
  Widget _buildCategoryCard(
    String name,
    IconData icon,
    Color backgroundColor,
    Color iconColor,
  ) {
    return GestureDetector(
      onTap: () {
        print('$name category tapped');
      },
      child: Container(
        decoration: BoxDecoration(
          color: backgroundColor,
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 28),
            ),
            const SizedBox(height: 8),
            Text(
              name,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  // Build medicine card with image, discount, and quantity controls
  Widget _buildMedicineCard(Map<String, dynamic> medicine, bool hasMargin) {
    int medicineId = medicine['id'];
    int quantity = medicineQuantities[medicineId] ?? 0;
    bool hasQuantity = quantity > 0;

    // Create a unique key for each medicine card's image
    final GlobalKey imageKey = GlobalKey();

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MedicineDetailsScreen(
              medicine: medicine,
              onAddToCart: (medicineId, quantity) {
                // Add the quantity to cart
                setState(() {
                  int currentQty = medicineQuantities[medicineId] ?? 0;
                  medicineQuantities[medicineId] = currentQty + quantity;
                  _cartItemCount += quantity;
                });
              },
            ),
          ),
        );
      },
      child: Container(
        width: 170,
        margin: EdgeInsets.only(right: hasMargin ? 12 : 0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey[200]!, width: 1.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image container with discount badge
            Stack(
              children: [
                Container(
                  key: imageKey,
                  height: 130,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [const Color(0xFFF5F5F5), Colors.grey[100]!],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                  ),

                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                    child: Image.asset(
                      medicine['image'],
                      height: 130,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0288D1).withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.medication,
                            size: 50,
                            color: Color(0xFF0288D1),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                // Discount badge
                Positioned(
                  top: 10,
                  left: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF2B8C33), Color(0xFF2B8C33)],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF2B8C33).withOpacity(0.4),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      medicine['discount'],
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            // Content section
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Medicine name
                    Text(
                      medicine['name'],
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    // Price and button row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        // Price column
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                medicine['originalPrice'],
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey[500],
                                  decoration: TextDecoration.lineThrough,
                                  decorationThickness: 2,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                medicine['discountedPrice'],
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF0288D1),
                                  height: 1,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Add or quantity control
                        hasQuantity
                            ? Container(
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFF0288D1),
                                      Color(0xFF0277BD),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(50),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(
                                        0xFF0288D1,
                                      ).withOpacity(0.3),
                                      blurRadius: 6,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    GestureDetector(
                                      onTap: () =>
                                          _updateQuantity(medicineId, -1),
                                      child: Container(
                                        padding: const EdgeInsets.all(6),
                                        child: const Icon(
                                          Icons.remove,
                                          size: 16,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      constraints: const BoxConstraints(
                                        minWidth: 24,
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 4,
                                      ),
                                      child: Text(
                                        quantity.toString(),
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        _animateProductToCart(
                                          imageKey,
                                          medicine['image'],
                                          medicineId,
                                        );
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.all(6),
                                        child: const Icon(
                                          Icons.add,
                                          size: 16,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : GestureDetector(
                                onTap: () {
                                  _animateProductToCart(
                                    imageKey,
                                    medicine['image'],
                                    medicineId,
                                  );
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0xFF0288D1),
                                        Color(0xFF0277BD),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(50),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(
                                          0xFF0288D1,
                                        ).withOpacity(0.3),
                                        blurRadius: 6,
                                        offset: const Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.add,
                                    size: 20,
                                    color: Colors.white,
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
    );
  }
}

// Flying Image Animation Widget
class _FlyingImage extends StatefulWidget {
  final String imageUrl;
  final Offset startPosition;
  final Offset endPosition;
  final VoidCallback onComplete;

  const _FlyingImage({
    required this.imageUrl,
    required this.startPosition,
    required this.endPosition,
    required this.onComplete,
  });

  @override
  State<_FlyingImage> createState() => _FlyingImageState();
}

class _FlyingImageState extends State<_FlyingImage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _positionAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    // Curved position animation with bounce effect
    _positionAnimation = Tween<Offset>(
      begin: widget.startPosition,
      end: widget.endPosition,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    // Scale down animation
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.3,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    // Fade out near the end
    _opacityAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.7, 1.0, curve: Curves.easeOut),
      ),
    );

    _controller.forward().then((_) {
      widget.onComplete();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Positioned(
          left: _positionAnimation.value.dx,
          top: _positionAnimation.value.dy,
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: Opacity(
              opacity: _opacityAnimation.value,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF0288D1).withOpacity(0.3),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: ClipOval(
                  child: Image.asset(
                    widget.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0288D1).withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.medication,
                          size: 40,
                          color: Color(0xFF0288D1),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
