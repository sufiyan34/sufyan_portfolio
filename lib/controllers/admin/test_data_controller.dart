import 'package:get/get.dart';
import 'package:sufyan_portfolio/models/package_model.dart';
import 'package:sufyan_portfolio/models/service_model.dart';
import 'package:sufyan_portfolio/models/skill_model.dart';
import 'package:sufyan_portfolio/models/experience_model.dart';
import 'package:sufyan_portfolio/models/project_model.dart';
import 'package:sufyan_portfolio/repositories/package_repository.dart';
import 'package:sufyan_portfolio/repositories/service_repository.dart';
import 'package:sufyan_portfolio/repositories/skill_repository.dart';
import 'package:sufyan_portfolio/repositories/experience_repository.dart';
import 'package:sufyan_portfolio/repositories/project_repository.dart';

class TestDataController extends GetxController {
  final _packageRepository = PackageRepository.instance;
  final _serviceRepository = ServiceRepository.instance;
  final _skillRepository = SkillRepository.instance;
  final _experienceRepository = ExperienceRepository.instance;
  final _projectRepository = ProjectRepository.instance;

  final RxBool isSeedingPackages = false.obs;
  final RxBool isSeedingServices = false.obs;
  final RxBool isSeedingAll = false.obs;
  final RxInt uploadedPackages = 0.obs;
  final RxInt uploadedServices = 0.obs;
  final RxInt uploadedSkills = 0.obs;
  final RxInt uploadedExperiences = 0.obs;
  final RxInt uploadedProjects = 0.obs;
  final RxString successMessage = ''.obs;
  final RxString errorMessage = ''.obs;
  final RxBool isSeedingSkills = false.obs;
  final RxBool isSeedingExperiences = false.obs;
  final RxBool isSeedingProjects = false.obs;

  Future<bool> seedPackages() async {
    if (isSeedingPackages.value ||
        isSeedingServices.value ||
        isSeedingSkills.value ||
        isSeedingExperiences.value ||
        isSeedingProjects.value ||
        isSeedingAll.value)
      return false;

    isSeedingPackages.value = true;
    successMessage.value = '';
    errorMessage.value = '';
    uploadedPackages.value = 0;

    try {
      final packages = _demoPackages();
      for (final package in packages) {
        await _packageRepository.seed(package);
        uploadedPackages.value++;
      }

      successMessage.value =
          '${packages.length} demo packages uploaded successfully.';
      return true;
    } catch (e) {
      errorMessage.value = 'Package demo data upload failed: $e';
      return false;
    } finally {
      isSeedingPackages.value = false;
    }
  }

  Future<bool> seedServices() async {
    if (isSeedingPackages.value ||
        isSeedingServices.value ||
        isSeedingSkills.value ||
        isSeedingExperiences.value ||
        isSeedingProjects.value ||
        isSeedingAll.value) {
      return false;
    }

    isSeedingServices.value = true;
    successMessage.value = '';
    errorMessage.value = '';
    uploadedServices.value = 0;

    try {
      final services = _demoServices();
      for (final service in services) {
        await _serviceRepository.seed(service);
        uploadedServices.value++;
      }

      successMessage.value =
          '${services.length} demo services uploaded successfully.';
      return true;
    } catch (e) {
      errorMessage.value = 'Service demo data upload failed: $e';
      return false;
    } finally {
      isSeedingServices.value = false;
    }
  }

  Future<bool> seedSkills() async {
    if (isSeedingPackages.value ||
        isSeedingServices.value ||
        isSeedingSkills.value ||
        isSeedingExperiences.value ||
        isSeedingProjects.value ||
        isSeedingAll.value) {
      return false;
    }

    isSeedingSkills.value = true;
    successMessage.value = '';
    errorMessage.value = '';
    uploadedSkills.value = 0;

    try {
      final skills = _demoSkills();
      for (final skill in skills) {
        await _skillRepository.seed(skill);
        uploadedSkills.value++;
      }

      successMessage.value =
          '${skills.length} demo skills uploaded successfully.';
      return true;
    } catch (e) {
      errorMessage.value = 'Skill demo data upload failed: $e';
      return false;
    } finally {
      isSeedingSkills.value = false;
    }
  }

  Future<bool> seedExperiences() async {
    if (isSeedingPackages.value ||
        isSeedingServices.value ||
        isSeedingSkills.value ||
        isSeedingExperiences.value ||
        isSeedingProjects.value ||
        isSeedingAll.value) {
      return false;
    }

    isSeedingExperiences.value = true;
    successMessage.value = '';
    errorMessage.value = '';
    uploadedExperiences.value = 0;

    try {
      final experiences = _demoExperiences();
      for (final experience in experiences) {
        await _experienceRepository.seed(experience);
        uploadedExperiences.value++;
      }

      successMessage.value =
          '${experiences.length} demo experience entries uploaded successfully.';
      return true;
    } catch (e) {
      errorMessage.value = 'Experience demo data upload failed: $e';
      return false;
    } finally {
      isSeedingExperiences.value = false;
    }
  }

  Future<bool> seedProjects() async {
    if (isSeedingPackages.value ||
        isSeedingServices.value ||
        isSeedingSkills.value ||
        isSeedingExperiences.value ||
        isSeedingProjects.value ||
        isSeedingAll.value) {
      return false;
    }

    isSeedingProjects.value = true;
    successMessage.value = '';
    errorMessage.value = '';
    uploadedProjects.value = 0;

    try {
      final projects = _demoProjects();
      for (final project in projects) {
        await _projectRepository.seed(project);
        uploadedProjects.value++;
      }

      successMessage.value =
          '${projects.length} demo projects uploaded successfully.';
      return true;
    } catch (e) {
      errorMessage.value = 'Project demo data upload failed: $e';
      return false;
    } finally {
      isSeedingProjects.value = false;
    }
  }

  Future<bool> seedAllDemoData() async {
    if (isSeedingPackages.value ||
        isSeedingServices.value ||
        isSeedingSkills.value ||
        isSeedingExperiences.value ||
        isSeedingProjects.value ||
        isSeedingAll.value) {
      return false;
    }

    isSeedingAll.value = true;
    successMessage.value = '';
    errorMessage.value = '';
    uploadedPackages.value = 0;
    uploadedServices.value = 0;
    uploadedSkills.value = 0;
    uploadedExperiences.value = 0;
    uploadedProjects.value = 0;

    try {
      final packages = _demoPackages();
      for (final package in packages) {
        await _packageRepository.seed(package);
        uploadedPackages.value++;
      }

      final services = _demoServices();
      for (final service in services) {
        await _serviceRepository.seed(service);
        uploadedServices.value++;
      }

      final skills = _demoSkills();
      for (final skill in skills) {
        await _skillRepository.seed(skill);
        uploadedSkills.value++;
      }

      final experiences = _demoExperiences();
      for (final experience in experiences) {
        await _experienceRepository.seed(experience);
        uploadedExperiences.value++;
      }

      final projects = _demoProjects();
      for (final project in projects) {
        await _projectRepository.seed(project);
        uploadedProjects.value++;
      }

      successMessage.value =
          'All demo data uploaded: ${packages.length} packages, ${services.length} services, ${skills.length} skills, ${experiences.length} experience entries, and ${projects.length} projects.';
      return true;
    } catch (e) {
      errorMessage.value = 'Demo data upload failed: $e';
      return false;
    } finally {
      isSeedingAll.value = false;
    }
  }

  List<SkillModel> _demoSkills() {
    final now = DateTime.now().millisecondsSinceEpoch;

    return [
      SkillModel(
        id: 'demo_skill_flutter',
        name: 'Flutter',
        category: 'Mobile',
        description: 'Cross-platform mobile and web application development with Flutter.',
        proficiency: 95,
        icon: 'phone',
        sortOrder: 1,
        published: true,
        createdAt: now,
        updatedAt: now,
      ),
      SkillModel(
        id: 'demo_skill_dart',
        name: 'Dart',
        category: 'Mobile',
        description:
            'Primary programming language for Flutter application development.',
        proficiency: 92,
        icon: 'code',
        sortOrder: 2,
        published: true,
        createdAt: now,
        updatedAt: now,
      ),
      SkillModel(
        id: 'demo_skill_getx',
        name: 'GetX',
        category: 'Mobile',
        description: 'State management, dependency injection, and navigation for Flutter applications.',
        proficiency: 90,
        icon: 'architecture',
        sortOrder: 3,
        published: true,
        createdAt: now,
        updatedAt: now,
      ),
      SkillModel(
        id: 'demo_skill_flutter_web',
        name: 'Flutter Web',
        category: 'Frontend',
        description: 'Responsive web applications, dashboards, portals, and portfolio experiences with Flutter Web.',
        proficiency: 90,
        icon: 'web',
        sortOrder: 4,
        published: true,
        createdAt: now,
        updatedAt: now,
      ),
      SkillModel(
        id: 'demo_skill_javascript',
        name: 'JavaScript',
        category: 'Frontend',
        description: 'Frontend scripting and web application fundamentals.',
        proficiency: 72,
        icon: 'web',
        sortOrder: 5,
        published: true,
        createdAt: now,
        updatedAt: now,
      ),
      SkillModel(
        id: 'demo_skill_python',
        name: 'Python',
        category: 'Backend',
        description: 'Python development for APIs, automation, data analysis, and system integration.',
        proficiency: 82,
        icon: 'backend',
        sortOrder: 6,
        published: true,
        createdAt: now,
        updatedAt: now,
      ),
      SkillModel(
        id: 'demo_skill_flask',
        name: 'Flask',
        category: 'Backend',
        description:
            'Lightweight Python web development and backend fundamentals.',
        proficiency: 68,
        icon: 'backend',
        sortOrder: 7,
        published: true,
        createdAt: now,
        updatedAt: now,
      ),
      SkillModel(
        id: 'demo_skill_rest_api',
        name: 'REST APIs',
        category: 'Backend',
        description: 'REST API integration, request handling, authentication, and application data flows.',
        proficiency: 88,
        icon: 'api',
        sortOrder: 8,
        published: true,
        createdAt: now,
        updatedAt: now,
      ),
      SkillModel(
        id: 'demo_skill_dio',
        name: 'Dio',
        category: 'Backend',
        description: 'HTTP networking, interceptors, authenticated requests, and API integration in Flutter.',
        proficiency: 86,
        icon: 'api',
        sortOrder: 9,
        published: true,
        createdAt: now,
        updatedAt: now,
      ),
      SkillModel(
        id: 'demo_skill_firebase',
        name: 'Firebase',
        category: 'Firebase',
        description: 'Firebase services for authentication, databases, storage, messaging, and backend workflows.',
        proficiency: 90,
        icon: 'firebase',
        sortOrder: 10,
        published: true,
        createdAt: now,
        updatedAt: now,
      ),
      SkillModel(
        id: 'demo_skill_realtime_database',
        name: 'Realtime Database',
        category: 'Firebase',
        description: 'Real-time application data, listeners, CRUD operations, and role-aware access patterns.',
        proficiency: 90,
        icon: 'database',
        sortOrder: 11,
        published: true,
        createdAt: now,
        updatedAt: now,
      ),
      SkillModel(
        id: 'demo_skill_firestore',
        name: 'Cloud Firestore',
        category: 'Firebase',
        description: 'Cloud Firestore data modeling and real-time application data integration.',
        proficiency: 82,
        icon: 'database',
        sortOrder: 12,
        published: true,
        createdAt: now,
        updatedAt: now,
      ),
      SkillModel(
        id: 'demo_skill_supabase',
        name: 'Supabase',
        category: 'Database',
        description: 'Supabase-backed application architectures and database integrations.',
        proficiency: 80,
        icon: 'cloud',
        sortOrder: 13,
        published: true,
        createdAt: now,
        updatedAt: now,
      ),
      SkillModel(
        id: 'demo_skill_sql',
        name: 'SQL',
        category: 'Database',
        description:
            'Relational database querying and application data fundamentals.',
        proficiency: 78,
        icon: 'database',
        sortOrder: 14,
        published: true,
        createdAt: now,
        updatedAt: now,
      ),
      SkillModel(
        id: 'demo_skill_cloudinary',
        name: 'Cloudinary',
        category: 'Backend',
        description: 'Media upload and cloud asset delivery for images, videos, and files.',
        proficiency: 82,
        icon: 'cloud',
        sortOrder: 15,
        published: true,
        createdAt: now,
        updatedAt: now,
      ),
      SkillModel(
        id: 'demo_skill_git',
        name: 'Git',
        category: 'Tools',
        description: 'Source control, branching, commits, and collaborative development workflows.',
        proficiency: 88,
        icon: 'git',
        sortOrder: 16,
        published: true,
        createdAt: now,
        updatedAt: now,
      ),
      SkillModel(
        id: 'demo_skill_github',
        name: 'GitHub',
        category: 'Tools',
        description: 'Repository management, collaboration, pull requests, and project delivery.',
        proficiency: 88,
        icon: 'git',
        sortOrder: 17,
        published: true,
        createdAt: now,
        updatedAt: now,
      ),
      SkillModel(
        id: 'demo_skill_postman',
        name: 'Postman',
        category: 'Tools',
        description: 'API testing, request debugging, and endpoint validation.',
        proficiency: 84,
        icon: 'tools',
        sortOrder: 18,
        published: true,
        createdAt: now,
        updatedAt: now,
      ),
      SkillModel(
        id: 'demo_skill_gemini_api',
        name: 'Gemini API',
        category: 'AI & Automation',
        description:
            'Gemini API integration for AI-assisted application experiences.',
        proficiency: 72,
        icon: 'api',
        sortOrder: 19,
        published: true,
        createdAt: now,
        updatedAt: now,
      ),
      SkillModel(
        id: 'demo_skill_jwt',
        name: 'JWT Authentication',
        category: 'Systems Integration',
        description: 'Token-based authentication flows and authenticated API integration.',
        proficiency: 80,
        icon: 'architecture',
        sortOrder: 20,
        published: true,
        createdAt: now,
        updatedAt: now,
      ),
      SkillModel(
        id: 'demo_skill_rbac',
        name: 'RBAC & Permissions',
        category: 'Systems Integration',
        description: 'Role-based access control, permission systems, and protected application features.',
        proficiency: 82,
        icon: 'architecture',
        sortOrder: 21,
        published: true,
        createdAt: now,
        updatedAt: now,
      ),
      SkillModel(
        id: 'demo_skill_zkteco',
        name: 'ZKTeco / K40 Integration',
        category: 'Systems Integration',
        description: 'Biometric attendance integration using a custom Python bridge and Firebase synchronization.',
        proficiency: 76,
        icon: 'backend',
        sortOrder: 22,
        published: true,
        createdAt: now,
        updatedAt: now,
      ),
      SkillModel(
        id: 'demo_skill_mvvm',
        name: 'MVVM',
        category: 'Architecture',
        description: 'Separation of presentation, state, and data responsibilities in application architecture.',
        proficiency: 78,
        icon: 'architecture',
        sortOrder: 23,
        published: true,
        createdAt: now,
        updatedAt: now,
      ),
      SkillModel(
        id: 'demo_skill_clean_architecture',
        name: 'Clean Architecture',
        category: 'Architecture',
        description: 'Layered, maintainable application structure with clear boundaries and reusable data access.',
        proficiency: 78,
        icon: 'architecture',
        sortOrder: 24,
        published: true,
        createdAt: now,
        updatedAt: now,
      ),
      SkillModel(
        id: 'demo_skill_machine_learning',
        name: 'Machine Learning Fundamentals',
        category: 'AI & Automation',
        description: 'Foundational machine learning experience with model training, evaluation, and data analysis.',
        proficiency: 65,
        icon: 'design',
        sortOrder: 25,
        published: true,
        createdAt: now,
        updatedAt: now,
      ),
    ];
  }

  List<ExperienceModel> _demoExperiences() {
    final now = DateTime.now().millisecondsSinceEpoch;

    return [
      ExperienceModel(
        id: 'demo_experience_dawood_designers',
        role: 'Web Developer',
        company: 'Dawood Designers',
        employmentType: 'Full-time',
        location: 'Lahore, Pakistan',
        startDate: 'June 2026',
        endDate: '',
        isCurrent: true,
        description: 'Building the Dawood Designers Employee Portal (DDE Portal), a full-scale employee management system covering employee records, attendance, shifts, payroll, reporting, permissions, and documents for multiple offices and cities.',
        achievements: [
          'Built the DDE Portal from the ground up as an end-to-end employee management platform.',
          'Developed responsive Flutter Web interfaces with reusable components and GetX state management.',
          'Integrated Firebase Authentication, Realtime Database, Firestore, Storage, and Cloudinary-based file uploads.',
          'Built a Python bridge service to integrate a ZKTeco K40 biometric attendance device with Firebase for fingerprint-based check-in/check-out.',
          'Unified attendance, CSV export, and HR monthly export calculations with a shared attendance metrics function and a standardized 15-minute grace period.',
          'Built payroll and admin reporting workflows including salary calculations, deductions, overtime, PDF payslip generation, and role-based permission controls.',
          'Integrated the Gemini API to provide a permission-scoped employee-facing AI assistant.',
          'Shipped multi-company support, group chat, data-management workflows, task management, and employee letter/approval modules with automated email delivery.',
        ],
        technologies: [
          'Flutter',
          'Dart',
          'Flutter Web',
          'GetX',
          'Firebase Authentication',
          'Realtime Database',
          'Cloud Firestore',
          'Firebase Storage',
          'Cloudinary',
          'Python',
          'ZKTeco K40',
          'Gemini API',
        ],
        sortOrder: 1,
        published: true,
        featured: true,
        createdAt: now,
        updatedAt: now,
      ),
      ExperienceModel(
        id: 'demo_experience_zerum_solutions',
        role: 'Software Developer',
        company: 'Zerum Solutions',
        employmentType: 'Full-time',
        location: 'Lahore, Pakistan',
        startDate: 'November 2025',
        endDate: 'July 2026',
        isCurrent: false,
        description: 'Developed cross-platform mobile applications using Flutter, Dart, GetX, Firebase, and Supabase, including production applications for ticketing, digital cards, wallets, and transactions.',
        achievements: [
          'Developed cross-platform applications using Flutter, Dart, GetX, Firebase, and Supabase.',
          'Built Mega Safari Zoo, a multi-city zoo ticket and ride booking app with QR-based real-time entry validation.',
          'Implemented PDF ticket generation, push notifications, and transaction tracking for the Mega Safari Zoo application.',
          'Developed Asaan Card, a digital card and wallet application with secure balance top-ups and real-time transaction history.',
          'Implemented PDF receipt generation and Firebase-based data handling for Asaan Card.',
          'Prepared an architecture-ready Stripe integration for card funding in Asaan Card.',
        ],
        technologies: [
          'Flutter',
          'Dart',
          'GetX',
          'Firebase',
          'Supabase',
          'QR Validation',
          'PDF Generation',
          'Push Notifications',
          'Stripe',
        ],
        sortOrder: 2,
        published: true,
        featured: true,
        createdAt: now,
        updatedAt: now,
      ),
      ExperienceModel(
        id: 'demo_experience_squarenex',
        role: 'Flutter Developer',
        company: 'Squarenex Technologies',
        employmentType: 'Full-time',
        location: 'Lahore, Pakistan',
        startDate: 'August 2024',
        endDate: 'June 2025',
        isCurrent: false,
        description: 'Developed multiple cross-platform applications using Flutter and GetX, with Firebase, Supabase, responsive UI, custom animations, chat modules, maps, and interactive 2D game experiences.',
        achievements: [
          'Developed multiple cross-platform applications using Flutter and GetX.',
          'Integrated Firebase Authentication, Firestore, and Storage for real-time user data and media.',
          'Connected Flutter front-ends to Supabase backends for scalable application architectures.',
          'Built custom animations, chat modules, maps, and interactive 2D games with custom collision handling and responsive game loops.',
          'Delivered client projects including Rehma, BarberOnline.com, Caribsell, Gasebuddy, and ConnectingLives.',
          'Contributed to the company website and ensured full responsiveness across devices.',
          'Participated in agile sprint planning and daily scrums.',
        ],
        technologies: [
          'Flutter',
          'Dart',
          'GetX',
          'Firebase Authentication',
          'Cloud Firestore',
          'Firebase Storage',
          'Supabase',
          'Maps',
          'Custom Animations',
          '2D Game Development',
          'Flame',
        ],
        sortOrder: 3,
        published: true,
        featured: false,
        createdAt: now,
        updatedAt: now,
      ),
    ];
  }

  List<ProjectModel> _demoProjects() {
    final now = DateTime.now().millisecondsSinceEpoch;

    return [
      ProjectModel(
        id: 'demo_project_dde_portal',
        title: 'DDE Portal',
        slug: 'dde-portal',
        shortDescription: 'Full-scale employee management web and mobile platform for attendance, payroll, reporting, permissions, and documents.',
        fullDescription: 'An end-to-end employee management platform built for Dawood Designers, covering employee records, attendance, shifts, payroll, reporting, permissions, and documents across multiple offices and cities.',
        categoryIds: ['Flutter', 'Web', 'Firebase', 'Business'],
        technologies: [
          'Flutter',
          'Dart',
          'GetX',
          'Firebase',
          'Cloudinary',
          'Python',
          'Gemini API',
        ],
        features: [
          'Employee records and management',
          'Attendance and shift workflows',
          'Payroll and reporting',
          'Role-based permissions',
          'Cloudinary file uploads',
          'Gemini-powered employee assistant',
        ],
        role: 'Web Developer',
        challenge: 'Bring employee, attendance, payroll, reporting, permissions, and document workflows into one responsive system used across multiple offices.',
        solution: 'Built reusable Flutter Web interfaces with GetX and Firebase-backed workflows, with supporting Python and AI integrations where required.',
        results: 'Delivered a scalable employee portal with centralized workflows and support for multiple offices and cities.',
        clientName: 'Dawood Designers',
        year: 2026,
        visibility: 'public',
        featured: true,
        published: true,
        sortOrder: 1,
        createdAt: now,
        updatedAt: now,
      ),
      ProjectModel(
        id: 'demo_project_zkteco_bridge',
        title: 'ZKTeco Attendance Bridge',
        slug: 'zkteco-attendance-bridge',
        shortDescription: 'Python bridge service syncing ZKTeco K40 biometric attendance data into Firebase for automated reporting.',
        fullDescription: 'A custom Python bridge that connects a ZKTeco K40 biometric attendance device with Firebase, automating fingerprint-based check-in and check-out data for reporting.',
        categoryIds: ['Business', 'Firebase'],
        technologies: ['Python', 'Firebase Realtime Database', 'ZKTeco K40'],
        features: [
          'Biometric attendance synchronization',
          'Fingerprint check-in/check-out data',
          'Firebase integration',
          'Automated reporting pipeline',
        ],
        role: 'Developer',
        challenge: 'Connect biometric device data with the existing employee portal without replacing the manual attendance workflow.',
        solution: 'Developed a Python bridge service that reads ZKTeco K40 attendance data and synchronizes it into Firebase.',
        results: 'Automated biometric attendance syncing and enabled real-time reporting inside the employee platform.',
        clientName: 'Dawood Designers',
        year: 2026,
        visibility: 'public',
        featured: true,
        published: true,
        sortOrder: 2,
        createdAt: now,
        updatedAt: now,
      ),
      ProjectModel(
        id: 'demo_project_mega_safari_zoo',
        title: 'Mega Safari Zoo',
        slug: 'mega-safari-zoo',
        shortDescription: 'Multi-city Flutter and Firebase zoo booking app with QR ticket validation and transaction tracking.',
        fullDescription: 'A multi-city zoo ticket and ride booking application with QR-based real-time entry validation, PDF ticket generation, push notifications, and transaction tracking.',
        categoryIds: ['Flutter', 'Firebase', 'Business'],
        technologies: ['Flutter', 'Dart', 'Firebase', 'QR', 'PDF'],
        features: [
          'Zoo ticket booking',
          'Ride booking',
          'QR-based entry validation',
          'PDF ticket generation',
          'Push notifications',
          'Transaction tracking',
        ],
        role: 'Software Developer',
        challenge: 'Support ticketing and ride booking across multiple zoo locations while validating entry in real time.',
        solution: 'Built the cross-platform application with Firebase-backed data handling and QR-based validation workflows.',
        results: 'Delivered a multi-city booking experience with digital tickets and real-time entry validation.',
        clientName: 'Zerum Solutions',
        year: 2026,
        visibility: 'public',
        featured: true,
        published: true,
        sortOrder: 3,
        createdAt: now,
        updatedAt: now,
      ),
      ProjectModel(
        id: 'demo_project_asaan_card',
        title: 'Asaan Card',
        slug: 'asaan-card',
        shortDescription: 'Flutter and Firebase digital card and wallet app with top-ups, transaction history, and PDF receipts.',
        fullDescription: 'A digital card and wallet application supporting secure balance top-ups, real-time transaction history, PDF receipts, and a Stripe-ready card funding architecture.',
        categoryIds: ['Flutter', 'Firebase', 'Business'],
        technologies: ['Flutter', 'Dart', 'Firebase', 'Stripe'],
        features: [
          'Digital card and wallet flows',
          'Secure balance top-ups',
          'Real-time transaction history',
          'PDF receipt generation',
          'Stripe-ready payment architecture',
        ],
        role: 'Software Developer',
        challenge: 'Provide a reliable digital wallet experience with transaction visibility and a payment architecture ready for card funding.',
        solution: 'Developed the Flutter application with Firebase-backed transaction handling and an architecture-ready Stripe integration.',
        results: 'Delivered wallet, top-up, and transaction workflows with generated PDF receipts.',
        clientName: 'Zerum Solutions',
        year: 2026,
        visibility: 'public',
        featured: true,
        published: true,
        sortOrder: 4,
        createdAt: now,
        updatedAt: now,
      ),
      ProjectModel(
        id: 'demo_project_rehma',
        title: 'Rehma',
        slug: 'rehma',
        shortDescription:
            'FoodPanda-style ordering platform with responsive Flutter UI.',
        fullDescription: 'A food ordering platform inspired by the core experience of large food-delivery marketplaces, with a responsive Flutter interface.',
        categoryIds: ['Flutter', 'E-Commerce'],
        technologies: ['Flutter', 'Dart', 'GetX'],
        features: [
          'Food browsing',
          'Responsive ordering interface',
          'Cart and checkout experience',
          'Cross-platform UI',
        ],
        role: 'Flutter Developer',
        challenge: 'Create a responsive food-ordering experience with a familiar marketplace interaction model.',
        solution: 'Implemented the front-end experience in Flutter with reusable responsive components and state management.',
        results: 'Delivered a responsive food-ordering platform experience for mobile and larger screens.',
        clientName: 'Squarenex Technologies',
        year: 2025,
        visibility: 'public',
        featured: false,
        published: true,
        sortOrder: 5,
        createdAt: now,
        updatedAt: now,
      ),
      ProjectModel(
        id: 'demo_project_barber_online',
        title: 'BarberOnline.com',
        slug: 'barber-online',
        shortDescription: 'Barber service booking platform designed for convenient appointment scheduling.',
        fullDescription: 'A barber service booking platform focused on connecting customers with barber services through a straightforward booking experience.',
        categoryIds: ['Flutter', 'Business'],
        technologies: ['Flutter', 'Dart', 'GetX'],
        features: [
          'Barber service discovery',
          'Appointment booking flow',
          'Responsive interface',
        ],
        role: 'Flutter Developer',
        challenge: 'Create a simple and responsive service-booking journey for customers looking to schedule barber appointments.',
        solution: 'Built the booking-focused client experience using Flutter and reusable application components.',
        results: 'Delivered a focused booking platform for barber service appointments.',
        clientName: 'Squarenex Technologies',
        year: 2025,
        visibility: 'public',
        featured: false,
        published: true,
        sortOrder: 6,
        createdAt: now,
        updatedAt: now,
      ),
      ProjectModel(
        id: 'demo_project_caribsell',
        title: 'Caribsell',
        slug: 'caribsell',
        shortDescription: 'OLX-style marketplace application for listing and discovering products.',
        fullDescription: 'A marketplace application modeled around the core listing and discovery experience of classified platforms such as OLX.',
        categoryIds: ['Flutter', 'E-Commerce'],
        technologies: ['Flutter', 'Dart', 'GetX'],
        features: [
          'Product listings',
          'Marketplace browsing',
          'Responsive UI',
          'Cross-platform application experience',
        ],
        role: 'Flutter Developer',
        challenge: 'Build a marketplace experience around product discovery and listing workflows.',
        solution: 'Implemented a Flutter-based marketplace interface with reusable components and application state management.',
        results: 'Delivered an OLX-style marketplace experience for browsing and listing products.',
        clientName: 'Squarenex Technologies',
        year: 2025,
        visibility: 'public',
        featured: false,
        published: true,
        sortOrder: 7,
        createdAt: now,
        updatedAt: now,
      ),
      ProjectModel(
        id: 'demo_project_gasebuddy',
        title: 'Gasebuddy',
        slug: 'gasebuddy',
        shortDescription:
            'On-demand gas cylinder refill and ordering application.',
        fullDescription: 'An on-demand gas cylinder refill and ordering application created as part of the client projects delivered during the Squarenex role.',
        categoryIds: ['Flutter', 'Business'],
        technologies: ['Flutter', 'Dart', 'GetX'],
        features: [
          'Gas cylinder ordering',
          'Delivery-oriented workflow',
          'Responsive application UI',
        ],
        role: 'Flutter Developer',
        challenge: 'Provide a practical ordering experience for customers requesting gas cylinder refills.',
        solution: 'Built the application workflow in Flutter with reusable UI and state management components.',
        results: 'Delivered an on-demand ordering experience for gas cylinder refills.',
        clientName: 'Squarenex Technologies',
        year: 2025,
        visibility: 'public',
        featured: false,
        published: true,
        sortOrder: 8,
        createdAt: now,
        updatedAt: now,
      ),
      ProjectModel(
        id: 'demo_project_havoc_crm',
        title: 'Havoc CRM',
        slug: 'havoc-crm',
        shortDescription: 'Independent CRM build with core role/permission models and REST API authentication.',
        fullDescription: 'An independent CRM build covering Department, Designation, Permission, and Role models, an animated login flow, and integration with a client REST API backend using JWT authentication and Dio interceptors.',
        categoryIds: ['Business', 'Web'],
        technologies: ['REST API', 'Dio', 'JWT', 'RBAC'],
        features: [
          'Department model',
          'Designation model',
          'Role and permission models',
          'Animated authentication flow',
          'JWT authentication',
          'Dio interceptors',
        ],
        role: 'Independent Developer',
        challenge: 'Establish a permission-aware CRM structure and connect the client application to a protected REST backend.',
        solution: 'Designed the core CRM models and authentication flow with JWT and Dio interceptor integration.',
        results: 'Delivered the core CRM domain structure and authenticated REST API integration.',
        clientName: 'Independent Project',
        year: 2026,
        visibility: 'public',
        featured: false,
        published: true,
        sortOrder: 9,
        createdAt: now,
        updatedAt: now,
      ),
    ];
  }

  List<PackageModel> _demoPackages() {
    final now = DateTime.now().millisecondsSinceEpoch;

    return [
      PackageModel(
        id: 'demo_silver_package',
        title: 'Silver',
        type: PackageTypes.silver,
        shortDescription: 'A focused package for small business websites, landing pages, and compact Flutter or web projects.',
        description: 'A practical starting package for clients who need a polished digital presence or a small application with a clearly defined scope.',
        price: 75000,
        currency: 'PKR',
        pricingNote: 'Starting from',
        deliveryDays: 10,
        revisions: 2,
        features: [
          'Up to 5 core screens/pages',
          'Responsive UI implementation',
          'Flutter or Flutter Web development',
          'REST API integration',
          'Firebase integration',
          'Basic testing and bug fixing',
          'Source code handover',
        ],
        technologies: ['Flutter', 'Dart', 'GetX', 'Firebase', 'REST API'],
        sortOrder: 1,
        published: true,
        featured: false,
        ctaLabel: 'Choose Silver',
        createdAt: now,
        updatedAt: now,
      ),
      PackageModel(
        id: 'demo_gold_package',
        title: 'Gold',
        type: PackageTypes.gold,
        shortDescription: 'A balanced package for production-ready mobile or web applications with integrations and polished UX.',
        description: 'Our balanced package for clients who need a more complete product experience, stronger backend integration, and production-ready delivery.',
        price: 150000,
        currency: 'PKR',
        pricingNote: 'Starting from',
        deliveryDays: 21,
        revisions: 3,
        features: [
          'Up to 10 core screens/pages',
          'Custom responsive UI',
          'Flutter Android, iOS, or Web',
          'Firebase Auth + Realtime Database',
          'REST API integration',
          'Payment or third-party API integration',
          'Form validation and error handling',
          'Testing and performance pass',
          'Deployment guidance',
        ],
        technologies: [
          'Flutter',
          'Dart',
          'GetX',
          'Firebase',
          'REST API',
          'Dio',
        ],
        sortOrder: 2,
        published: true,
        featured: true,
        ctaLabel: 'Choose Gold',
        createdAt: now,
        updatedAt: now,
      ),
      PackageModel(
        id: 'demo_premium_package',
        title: 'Premium',
        type: PackageTypes.platinum,
        shortDescription: 'A complete premium product package for advanced applications, business systems, and complex integrations.',
        description: 'A high-touch package for serious products that require deeper architecture, richer functionality, advanced integrations, and a refined production experience.',
        price: 275000,
        currency: 'PKR',
        pricingNote: 'Starting from',
        deliveryDays: 35,
        revisions: 5,
        features: [
          'Up to 20 core screens/pages',
          'Custom UI system and design implementation',
          'Flutter Android + iOS + Web where applicable',
          'Advanced Firebase architecture',
          'Multiple REST / third-party integrations',
          'Role-based admin functionality',
          'Payment gateway integration',
          'Cloudinary media integration',
          'Performance optimization',
          'Production QA and release support',
        ],
        technologies: [
          'Flutter',
          'Dart',
          'GetX',
          'Firebase',
          'Cloudinary',
          'REST API',
          'Dio',
        ],
        sortOrder: 3,
        published: true,
        featured: false,
        ctaLabel: 'Choose Premium',
        createdAt: now,
        updatedAt: now,
      ),
      PackageModel(
        id: 'demo_custom_package',
        title: 'Custom',
        type: PackageTypes.custom,
        shortDescription: 'A tailored engagement built around your exact scope, timeline, integrations, and business requirements.',
        description: 'For projects that do not fit a fixed tier. We first understand the requirements, define the scope, and then prepare a custom technical and commercial proposal.',
        price: 0,
        currency: 'PKR',
        pricingNote: 'Custom quote after consultation',
        deliveryDays: 0,
        revisions: 0,
        features: [
          'Requirements discovery',
          'Custom scope and architecture',
          'Flexible screen and feature count',
          'Advanced third-party integrations',
          'Custom Firebase or API architecture',
          'Custom timeline and milestones',
          'Tailored support agreement',
        ],
        technologies: ['Flutter', 'Dart', 'Firebase', 'REST API', 'Cloudinary'],
        sortOrder: 4,
        published: true,
        featured: false,
        ctaLabel: 'Request Custom Quote',
        createdAt: now,
        updatedAt: now,
      ),
    ];
  }

  List<ServiceModel> _demoServices() {
    final now = DateTime.now().millisecondsSinceEpoch;

    return [
      ServiceModel(
        id: 'demo_flutter_app_development',
        title: 'Flutter App Development',
        category: 'Mobile Development',
        shortDescription: 'Modern Android, iOS, and cross-platform applications built with Flutter.',
        description: 'End-to-end Flutter application development for startups, businesses, and product teams that need a polished, responsive, and maintainable mobile experience.',
        features: [
          'Responsive mobile UI',
          'GetX or scalable state management',
          'Firebase and REST API integration',
          'Authentication and user flows',
          'Form validation and error handling',
          'Performance optimization',
          'Android and iOS build support',
        ],
        technologies: ['Flutter', 'Dart', 'GetX', 'Firebase', 'REST API'],
        icon: 'phone_android',
        sortOrder: 1,
        published: true,
        featured: true,
        createdAt: now,
        updatedAt: now,
      ),
      ServiceModel(
        id: 'demo_flutter_web_development',
        title: 'Flutter Web Development',
        category: 'Web Development',
        shortDescription: 'Fast, responsive Flutter websites, portals, dashboards, and web applications.',
        description: 'Responsive Flutter Web experiences designed for recruiters, clients, and businesses that need a consistent product across desktop, tablet, and mobile browsers.',
        features: [
          'Responsive desktop, tablet, and mobile layouts',
          'Professional landing pages',
          'Admin dashboards and business portals',
          'Firebase-backed dynamic content',
          'SEO-friendly web structure',
          'Performance-focused interactions',
        ],
        technologies: [
          'Flutter Web',
          'Dart',
          'GetX',
          'Firebase',
          'Responsive UI',
        ],
        icon: 'web',
        sortOrder: 2,
        published: true,
        featured: true,
        createdAt: now,
        updatedAt: now,
      ),
      ServiceModel(
        id: 'demo_firebase_backend',
        title: 'Firebase & Backend Development',
        category: 'Firebase & Backend',
        shortDescription: 'Secure Firebase architecture for authentication, databases, cloud logic, and app data.',
        description: 'Firebase-powered backend implementation for applications that need authentication, Realtime Database, Cloud Functions, notifications, and scalable application data flows.',
        features: [
          'Firebase Authentication',
          'Realtime Database architecture',
          'Cloud Functions integration',
          'Role-based access patterns',
          'Data modeling and repository layers',
          'Secure rules planning',
        ],
        technologies: [
          'Firebase',
          'Realtime Database',
          'Cloud Functions',
          'Firebase Auth',
          'Dart',
        ],
        icon: 'firebase',
        sortOrder: 3,
        published: true,
        featured: false,
        createdAt: now,
        updatedAt: now,
      ),
      ServiceModel(
        id: 'demo_api_integration',
        title: 'REST API & Third-Party Integration',
        category: 'API Integration',
        shortDescription: 'Reliable API integrations connecting your Flutter product to external services.',
        description: 'Integration of REST APIs, authentication flows, payment services, maps, external systems, and other third-party platforms with clean error handling and maintainable data layers.',
        features: [
          'REST API consumption',
          'Authentication and token flows',
          'JSON parsing and model mapping',
          'Payment and third-party APIs',
          'Dio-based networking',
          'Error and timeout handling',
        ],
        technologies: ['Dio', 'REST API', 'JSON', 'Flutter', 'Firebase'],
        icon: 'api',
        sortOrder: 4,
        published: true,
        featured: false,
        createdAt: now,
        updatedAt: now,
      ),
      ServiceModel(
        id: 'demo_business_systems',
        title: 'Business Management Systems',
        category: 'Business Systems',
        shortDescription: 'Custom management portals for employees, attendance, operations, and internal workflows.',
        description: 'Business-focused software for teams that need centralized dashboards, role-based access, employee workflows, attendance, reports, and operational management in one place.',
        features: [
          'Admin and employee dashboards',
          'Role-based permissions',
          'Attendance and workforce workflows',
          'Realtime operational data',
          'Reports and management views',
          'Scalable CRUD architecture',
        ],
        technologies: [
          'Flutter Web',
          'GetX',
          'Firebase',
          'Realtime Database',
          'REST API',
        ],
        icon: 'business',
        sortOrder: 5,
        published: true,
        featured: true,
        createdAt: now,
        updatedAt: now,
      ),
      ServiceModel(
        id: 'demo_ui_ux_implementation',
        title: 'UI/UX Implementation',
        category: 'UI/UX Implementation',
        shortDescription: 'Pixel-conscious Flutter implementation of polished, responsive interfaces and design systems.',
        description: 'Transforming design concepts and product requirements into polished Flutter interfaces with consistent spacing, typography, responsive behavior, reusable components, and thoughtful interactions.',
        features: [
          'Responsive screen implementation',
          'Reusable component systems',
          'Design-system driven styling',
          'Micro-interactions and motion',
          'Loading and skeleton states',
          'Accessibility-conscious layouts',
        ],
        technologies: [
          'Flutter',
          'ScreenUtil',
          'Google Fonts',
          'Flutter Animate',
          'Rive',
        ],
        icon: 'design',
        sortOrder: 6,
        published: true,
        featured: false,
        createdAt: now,
        updatedAt: now,
      ),
    ];
  }
}
