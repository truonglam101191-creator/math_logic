console.log('Language.js loading...');

// Multi-language content
const translations = {
    en: {
        title: "Logic Mathematics",
        subtitle: "An application for learning and practicing mathematical logic",
        version: "🚀 Version 2.1.0",
        downloadTitle: "📱 Download Now",
        googlePlay: "Google Play",
        appStore: "App Store",
        getItOn: "GET IT ON",
        downloadOn: "Download on the",
        comingSoon: "Coming soon to App Store!",
        privacyPolicy: "🔒 Privacy Policy",
        termsOfService: "📋 Terms of Service",
        support: "🛠️ Support",
        appDetails: "📋 App Details:",
        features: {
            interactive: { title: "Interactive Learning",desc: "Multiple math topics including Basic Math, Fun Geometry, Advanced Arithmetic, and more specialized challenges." },
            coinSystem: { title: "Coin System & Shop",desc: "Earn coins by solving problems, use them for hints, or purchase more coins through the in-app shop." },
            progress: { title: "Progress Tracking",desc: "Track your performance across different difficulty levels with detailed statistics and achievements." },
            updates: { title: "Dynamic Updates",desc: "Get new content and features instantly with Shorebird code push technology." },
            multilang: { title: "Multi-language Support",desc: "Available in multiple languages including English and Vietnamese with localized content." },
            sync: { title: "Offline & Cloud Sync",desc: "Practice offline and sync your progress to the cloud with Firebase integration." }
        },
        developer: {
            title: "Meet the Developer",
            name: "Trương Nguyễn Trường Lâm",
            desc: "Passionate about creating educational apps that make learning fun and accessible for everyone.",
            portfolio: "🌐 Visit My Portfolio"
        },
        details: ["📱 In-App Purchases & Google Mobile Ads","🌍 Multi-language Support (EN/VI)","🔐 Secure Storage & Device Info","📊 Progress Tracking & Statistics"],
        pages: {
            privacy: {
                title: "🔒 Privacy Policy",
                lastUpdated: "Last updated: January 2025",
                backBtn: "← Back to Home",
                sections: {
                    infoCollect: "Information We Collect",
                    howUse: "How We Use Your Information",
                    dataStorage: "Data Storage and Security",
                    thirdParty: "Third-Party Services",
                    childrenPrivacy: "Children's Privacy",
                    yourRights: "Your Rights",
                    contactUs: "Contact Us"
                },
                content: {
                    infoIntro: "Logic Mathematics collects minimal information to provide you with the best learning experience:",
                    infoItems: [
                        "Device information for app optimization",
                        "Progress data to track your learning journey",
                        "Coins and achievements data",
                        "Crash reports to improve app stability"
                    ],
                    useIntro: "We use the collected information to:",
                    useItems: [
                        "Provide personalized learning experiences",
                        "Save your progress across devices",
                        "Improve app performance and stability",
                        "Show relevant advertisements (if applicable)"
                    ],
                    securityInfo: "Your data is securely stored using Firebase services with industry-standard encryption. We implement appropriate security measures to protect your personal information against unauthorized access.",
                    securityFeatures: [
                        { title: "End-to-end Encryption",desc: "All data transmission is encrypted using HTTPS protocol" },
                        { title: "Secure Storage",desc: "Data stored in Google Firebase with enterprise-grade security" },
                        { title: "Privacy First",desc: "We never share personal data with third parties" }
                    ],
                    thirdPartyIntro: "Our app uses the following third-party services:",
                    services: [
                        { name: "Firebase (Google)",desc: "For data storage, authentication, and analytics",link: "View Firebase Privacy Policy" },
                        { name: "Google Mobile Ads",desc: "For displaying relevant advertisements",link: "View Google Privacy Policy" },
                        { name: "Google Play Services",desc: "For in-app purchases and app distribution",link: "View Google Play Privacy Policy" }
                    ],
                    safeForAll: "Safe for All Ages:",
                    safeDescription: "Our app is designed to be safe for users of all ages. We do not knowingly collect personal information from children under 13 without parental consent.",
                    coppaInfo: "We comply with the Children's Online Privacy Protection Act (COPPA) and take special care to protect children's privacy and safety online.",
                    userRights: [
                        { title: "Access Your Data",desc: "You have the right to request access to your personal data" },
                        { title: "Delete Your Data",desc: "You can request deletion of your personal data at any time" },
                        { title: "Opt-Out",desc: "You can opt-out of data collection where applicable" },
                        { title: "Correct Your Data",desc: "You can request corrections to inaccurate personal data" }
                    ],
                    contactIntro: "If you have any questions about this Privacy Policy, please contact us:",
                    contactMethods: ["Developer Portfolio","Google Play Store"],
                    responseTime: "We typically respond to privacy inquiries within 48 hours.",
                    footer: "This policy may be updated from time to time. We will notify users of any material changes."
                }
            },
            terms: {
                title: "📋 Terms of Service",
                lastUpdated: "Last updated: January 2025",
                backBtn: "← Back to Home",
                sections: {
                    acceptance: "Acceptance of Terms",
                    inAppPurchases: "In-App Purchases",
                    acceptableUse: "Acceptable Use",
                    intellectualProperty: "Intellectual Property",
                    limitation: "Limitation of Liability",
                    updates: "Updates and Changes",
                    termination: "Termination",
                    contact: "Contact Information"
                },
                content: {
                    acceptanceIntro: "By downloading, installing, or using the Logic Mathematics app, you agree to be bound by these Terms of Service.",
                    purchasesIntro: "Our app offers in-app purchases for additional features and content.",
                    purchasesItems: [
                        "All purchases are processed through your device's app store",
                        "Prices are displayed in your local currency",
                        "No refunds for digital content unless required by law",
                        "Subscription renewals are automatic unless cancelled"
                    ],
                    useIntro: "You agree to use the app only for lawful purposes and in accordance with these terms:",
                    useItems: [
                        "Do not attempt to reverse engineer the app",
                        "Do not use the app to harm minors",
                        "Do not share inappropriate content",
                        "Respect other users and educational content"
                    ],
                    ipIntro: "All content, features, and functionality of the app are owned by Logic Mathematics and are protected by copyright and other laws.",
                    limitationIntro: "Logic Mathematics shall not be liable for any indirect, incidental, or consequential damages.",
                    updatesIntro: "We reserve the right to update these terms at any time. Continued use constitutes acceptance of new terms.",
                    terminationIntro: "We may terminate your access if you violate these terms.",
                    contactIntro: "For questions about these terms, contact us through the app or our website."
                }
            },
            support: {
                title: "🛠️ Support Center",
                lastUpdated: "Last updated: January 2025",
                backBtn: "← Back to Home",
                sections: {
                    getHelp: "📞 Getting Help",
                    faq: "❓ Frequently Asked Questions",
                    features: "🎯 App Features Guide",
                    troubleshooting: "🔧 Troubleshooting",
                    feedback: "💝 Feedback & Reviews",
                    contact: "📧 Contact Support"
                },
                content: {
                    helpIntro: "Need assistance with Logic Mathematics? We're here to help!",
                    helpMethods: [
                        "Browse our FAQ section below",
                        "Contact us through the app",
                        "Visit our developer portfolio",
                        "Leave feedback on the app store"
                    ],
                    faqIntro: "Common questions and answers:",
                    faqItems: [
                        { q: "How do I earn coins?",a: "Solve math problems correctly to earn coins. Harder problems give more coins!" },
                        { q: "Can I use the app offline?",a: "Yes! Most features work offline, and your progress syncs when you're back online." },
                        { q: "How do I change the language?",a: "Tap the language button (EN/VI) at the top right of the screen." },
                        { q: "Is my progress saved?",a: "Yes, your progress is automatically saved locally and synced to the cloud." }
                    ],
                    featuresIntro: "Learn about our key features:",
                    featuresItems: [
                        "🎯 Interactive Learning: Engaging math problems across multiple topics",
                        "🪙 Coin System: Earn rewards for correct answers",
                        "📊 Progress Tracking: Monitor your improvement over time",
                        "🌐 Multi-language: Switch between English and Vietnamese"
                    ],
                    troubleshootingIntro: "Common issues and solutions:",
                    troubleshootingItems: [
                        "App won't start: Try restarting your device",
                        "Progress not saving: Check your internet connection",
                        "Audio not working: Check device volume settings",
                        "Slow performance: Close other apps and restart"
                    ],
                    feedbackIntro: "Your feedback helps us improve! Please:",
                    feedbackItems: [
                        "Rate us on Google Play Store",
                        "Share suggestions through the app",
                        "Report bugs or issues",
                        "Tell us about new features you'd like"
                    ],
                    contactIntro: "Still need help? Contact our support team:",
                    responseTime: "We typically respond within 24 hours during business days."
                }
            }
        }
    },
    vi: {
        title: "Logic Mathematics",
        subtitle: "Ứng dụng học tập và luyện tập logic toán học",
        version: "🚀 Phiên bản 2.1.0",
        downloadTitle: "📱 Tải Ngay",
        googlePlay: "Google Play",
        appStore: "App Store",
        getItOn: "TẢI TẠI",
        downloadOn: "Tải về từ",
        comingSoon: "Sắp có trên App Store!",
        privacyPolicy: "🔒 Chính Sách Bảo Mật",
        termsOfService: "📋 Điều Khoản Dịch Vụ",
        support: "🛠️ Hỗ Trợ",
        appDetails: "📋 Chi Tiết Ứng Dụng:",
        features: {
            interactive: { title: "Học Tập Tương Tác",desc: "Nhiều chủ đề toán học bao gồm Toán Cơ Bản, Hình Học Vui, Số Học Nâng Cao và các thử thách chuyên biệt khác." },
            coinSystem: { title: "Hệ Thống Xu & Cửa Hàng",desc: "Kiếm xu bằng cách giải bài toán, sử dụng cho gợi ý hoặc mua thêm xu thông qua cửa hàng trong ứng dụng." },
            progress: { title: "Theo Dõi Tiến Độ",desc: "Theo dõi hiệu suất của bạn qua các cấp độ khó khác nhau với thống kê chi tiết và thành tích." },
            updates: { title: "Cập Nhật Động",desc: "Nhận nội dung và tính năng mới ngay lập tức với công nghệ code push Shorebird." },
            multilang: { title: "Hỗ Trợ Đa Ngôn Ngữ",desc: "Có sẵn bằng nhiều ngôn ngữ bao gồm tiếng Anh và tiếng Việt với nội dung được bản địa hóa." },
            sync: { title: "Đồng Bộ Offline & Cloud",desc: "Luyện tập offline và đồng bộ tiến độ lên cloud với tích hợp Firebase." }
        },
        developer: {
            title: "Gặp Gỡ Nhà Phát Triển",
            name: "Trương Nguyễn Trường Lâm",
            desc: "Đam mê tạo ra các ứng dụng giáo dục giúp việc học trở nên thú vị và dễ tiếp cận với mọi người.",
            portfolio: "🌐 Xem Portfolio"
        },
        details: ["📱 Mua Hàng Trong Ứng Dụng & Google Mobile Ads","🌍 Hỗ Trợ Đa Ngôn Ngữ (EN/VI)","🔐 Lưu Trữ An Toàn & Thông Tin Thiết Bị","📊 Theo Dõi Tiến Độ & Thống Kê"],
        pages: {
            privacy: {
                title: "🔒 Chính Sách Bảo Mật",
                lastUpdated: "Cập nhật lần cuối: Tháng 1 năm 2025",
                backBtn: "← Quay Về Trang Chủ",
                sections: {
                    infoCollect: "Thông Tin Chúng Tôi Thu Thập",
                    howUse: "Cách Chúng Tôi Sử Dụng Thông Tin",
                    dataStorage: "Lưu Trữ Dữ Liệu và Bảo Mật",
                    thirdParty: "Dịch Vụ Bên Thứ Ba",
                    childrenPrivacy: "Quyền Riêng Tư Trẻ Em",
                    yourRights: "Quyền Của Bạn",
                    contactUs: "Liên Hệ Chúng Tôi"
                },
                content: {
                    infoIntro: "Logic Mathematics thu thập thông tin tối thiểu để cung cấp trải nghiệm học tập tốt nhất:",
                    infoItems: [
                        "Thông tin thiết bị để tối ưu hóa ứng dụng",
                        "Dữ liệu tiến độ để theo dõi hành trình học tập",
                        "Dữ liệu xu và thành tích",
                        "Báo cáo lỗi để cải thiện tính ổn định"
                    ],
                    useIntro: "Chúng tôi sử dụng thông tin thu thập để:",
                    useItems: [
                        "Cung cấp trải nghiệm học tập cá nhân hóa",
                        "Lưu tiến độ của bạn trên các thiết bị",
                        "Cải thiện hiệu suất và độ ổn định ứng dụng",
                        "Hiển thị quảng cáo phù hợp (nếu có)"
                    ],
                    securityInfo: "Dữ liệu của bạn được lưu trữ an toàn bằng dịch vụ Firebase với mã hóa tiêu chuẩn ngành. Chúng tôi thực hiện các biện pháp bảo mật phù hợp để bảo vệ thông tin cá nhân của bạn khỏi truy cập trái phép.",
                    securityFeatures: [
                        { title: "Mã Hóa Đầu-Cuối",desc: "Tất cả truyền dữ liệu được mã hóa bằng giao thức HTTPS" },
                        { title: "Lưu Trữ An Toàn",desc: "Dữ liệu được lưu trữ trong Google Firebase với bảo mật cấp doanh nghiệp" },
                        { title: "Ưu Tiên Riêng Tư",desc: "Chúng tôi không bao giờ chia sẻ dữ liệu cá nhân với bên thứ ba" }
                    ],
                    thirdPartyIntro: "Ứng dụng của chúng tôi sử dụng các dịch vụ bên thứ ba sau:",
                    services: [
                        { name: "Firebase (Google)",desc: "Để lưu trữ dữ liệu, xác thực và phân tích",link: "Xem Chính Sách Bảo Mật Firebase" },
                        { name: "Google Mobile Ads",desc: "Để hiển thị quảng cáo phù hợp",link: "Xem Chính Sách Bảo Mật Google" },
                        { name: "Google Play Services",desc: "Để mua hàng trong ứng dụng và phân phối ứng dụng",link: "Xem Chính Sách Bảo Mật Google Play" }
                    ],
                    safeForAll: "An Toàn Cho Mọi Lứa Tuổi:",
                    safeDescription: "Ứng dụng của chúng tôi được thiết kế an toàn cho người dùng ở mọi lứa tuổi. Chúng tôi không cố ý thu thập thông tin cá nhân từ trẻ em dưới 13 tuổi mà không có sự đồng ý của cha mẹ.",
                    coppaInfo: "Chúng tôi tuân thủ Đạo luật Bảo vệ Quyền riêng tư Trẻ em Trực tuyến (COPPA) và đặc biệt chú ý bảo vệ quyền riêng tư và an toàn của trẻ em trên mạng.",
                    userRights: [
                        { title: "Truy Cập Dữ Liệu",desc: "Bạn có quyền yêu cầu truy cập vào dữ liệu cá nhân của mình" },
                        { title: "Xóa Dữ Liệu",desc: "Bạn có thể yêu cầu xóa dữ liệu cá nhân của mình bất cứ lúc nào" },
                        { title: "Từ Chối Tham Gia",desc: "Bạn có thể từ chối thu thập dữ liệu khi có thể" },
                        { title: "Chỉnh Sửa Dữ Liệu",desc: "Bạn có thể yêu cầu chỉnh sửa dữ liệu cá nhân không chính xác" }
                    ],
                    contactIntro: "Nếu bạn có bất kỳ câu hỏi nào về Chính sách Bảo mật này, vui lòng liên hệ với chúng tôi:",
                    contactMethods: ["Portfolio Nhà Phát Triển","Google Play Store"],
                    responseTime: "Chúng tôi thường phản hồi các yêu cầu về quyền riêng tư trong vòng 48 giờ.",
                    footer: "Chính sách này có thể được cập nhật theo thời gian. Chúng tôi sẽ thông báo cho người dùng về bất kỳ thay đổi quan trọng nào."
                }
            },
            terms: {
                title: "📋 Điều Khoản Dịch Vụ",
                lastUpdated: "Cập nhật lần cuối: Tháng 1 năm 2025",
                backBtn: "← Quay Về Trang Chủ",
                sections: {
                    acceptance: "Chấp Nhận Điều Khoản",
                    inAppPurchases: "Mua Hàng Trong Ứng Dụng",
                    acceptableUse: "Sử Dụng Được Chấp Nhận",
                    intellectualProperty: "Sở Hữu Trí Tuệ",
                    limitation: "Giới Hạn Trách Nhiệm",
                    updates: "Cập Nhật và Thay Đổi",
                    termination: "Chấm Dứt",
                    contact: "Thông Tin Liên Hệ"
                },
                content: {
                    acceptanceIntro: "Bằng cách tải xuống, cài đặt hoặc sử dụng ứng dụng Logic Mathematics, bạn đồng ý bị ràng buộc bởi các Điều khoản Dịch vụ này.",
                    purchasesIntro: "Ứng dụng của chúng tôi cung cấp các giao dịch mua trong ứng dụng cho các tính năng và nội dung bổ sung.",
                    purchasesItems: [
                        "Tất cả giao dịch mua được xử lý thông qua cửa hàng ứng dụng của thiết bị",
                        "Giá được hiển thị bằng tiền tệ địa phương của bạn",
                        "Không hoàn tiền cho nội dung kỹ thuật số trừ khi pháp luật yêu cầu",
                        "Gia hạn đăng ký tự động trừ khi bị hủy"
                    ],
                    useIntro: "Bạn đồng ý chỉ sử dụng ứng dụng cho các mục đích hợp pháp và theo các điều khoản này:",
                    useItems: [
                        "Không cố gắng thiết kế ngược ứng dụng",
                        "Không sử dụng ứng dụng để làm hại trẻ vị thành niên",
                        "Không chia sẻ nội dung không phù hợp",
                        "Tôn trọng người dùng khác và nội dung giáo dục"
                    ],
                    ipIntro: "Tất cả nội dung, tính năng và chức năng của ứng dụng thuộc sở hữu của Logic Mathematics và được bảo vệ bởi bản quyền và các luật khác.",
                    limitationIntro: "Logic Mathematics sẽ không chịu trách nhiệm cho bất kỳ thiệt hại gián tiếp, ngẫu nhiên hoặc hệ quả nào.",
                    updatesIntro: "Chúng tôi có quyền cập nhật các điều khoản này bất cứ lúc nào. Việc tiếp tục sử dụng có nghĩa là chấp nhận các điều khoản mới.",
                    terminationIntro: "Chúng tôi có thể chấm dứt quyền truy cập của bạn nếu bạn vi phạm các điều khoản này.",
                    contactIntro: "Đối với các câu hỏi về các điều khoản này, hãy liên hệ với chúng tôi thông qua ứng dụng hoặc trang web của chúng tôi."
                }
            },
            support: {
                title: "🛠️ Trung Tâm Hỗ Trợ",
                lastUpdated: "Cập nhật lần cuối: Tháng 1 năm 2025",
                backBtn: "← Quay Về Trang Chủ",
                sections: {
                    getHelp: "📞 Nhận Trợ Giúp",
                    faq: "❓ Câu Hỏi Thường Gặp",
                    features: "🎯 Hướng Dẫn Tính Năng Ứng Dụng",
                    troubleshooting: "🔧 Khắc Phục Sự Cố",
                    feedback: "💝 Phản Hồi & Đánh Giá",
                    contact: "📧 Liên Hệ Hỗ Trợ"
                },
                content: {
                    helpIntro: "Cần hỗ trợ với Logic Mathematics? Chúng tôi sẵn sàng giúp đỡ!",
                    helpMethods: [
                        "Duyệt phần FAQ bên dưới",
                        "Liên hệ với chúng tôi thông qua ứng dụng",
                        "Truy cập portfolio nhà phát triển",
                        "Để lại phản hồi trên cửa hàng ứng dụng"
                    ],
                    faqIntro: "Câu hỏi và trả lời thường gặp:",
                    faqItems: [
                        { q: "Làm thế nào để kiếm xu?",a: "Giải đúng các bài toán để kiếm xu. Bài toán khó hơn cho nhiều xu hơn!" },
                        { q: "Tôi có thể sử dụng ứng dụng offline không?",a: "Có! Hầu hết các tính năng hoạt động offline, và tiến độ của bạn sẽ đồng bộ khi bạn trở lại online." },
                        { q: "Làm thế nào để thay đổi ngôn ngữ?",a: "Nhấn nút ngôn ngữ (EN/VI) ở góc trên bên phải màn hình." },
                        { q: "Tiến độ của tôi có được lưu không?",a: "Có, tiến độ của bạn được tự động lưu cục bộ và đồng bộ lên cloud." }
                    ],
                    featuresIntro: "Tìm hiểu về các tính năng chính của chúng tôi:",
                    featuresItems: [
                        "🎯 Học Tập Tương Tác: Các bài toán hấp dẫn trên nhiều chủ đề",
                        "🪙 Hệ Thống Xu: Nhận phần thưởng cho câu trả lời đúng",
                        "📊 Theo Dõi Tiến Độ: Giám sát sự cải thiện của bạn theo thời gian",
                        "🌐 Đa Ngôn Ngữ: Chuyển đổi giữa tiếng Anh và tiếng Việt"
                    ],
                    troubleshootingIntro: "Các vấn đề thường gặp và giải pháp:",
                    troubleshootingItems: [
                        "Ứng dụng không khởi động: Thử khởi động lại thiết bị",
                        "Tiến độ không lưu: Kiểm tra kết nối internet",
                        "Âm thanh không hoạt động: Kiểm tra cài đặt âm lượng thiết bị",
                        "Hiệu suất chậm: Đóng các ứng dụng khác và khởi động lại"
                    ],
                    feedbackIntro: "Phản hồi của bạn giúp chúng tôi cải thiện! Vui lòng:",
                    feedbackItems: [
                        "Đánh giá chúng tôi trên Google Play Store",
                        "Chia sẻ đề xuất thông qua ứng dụng",
                        "Báo cáo lỗi hoặc vấn đề",
                        "Cho chúng tôi biết về các tính năng mới bạn muốn"
                    ],
                    contactIntro: "Vẫn cần trợ giúp? Liên hệ với đội ngũ hỗ trợ của chúng tôi:",
                    responseTime: "Chúng tôi thường phản hồi trong vòng 24 giờ trong các ngày làm việc."
                }
            }
        }
    }
};

// Language management
window.languageManager = {
    currentLang: 'en',

    init: function () {
        console.log('Language Manager: Initializing...');

        // Get saved language or detect browser language
        const saved = localStorage.getItem('language');
        const browserLang = navigator.language.toLowerCase().startsWith('vi') ? 'vi' : 'en';
        this.currentLang = saved || browserLang;

        console.log('Current language:',this.currentLang,saved ? '(from localStorage)' : '(auto-detected from browser)');

        // Only setup toggle button on main page (index.html)
        const btn = document.getElementById('languageToggle');
        if (btn && !document.querySelector('.sub-page-container')) {
            btn.addEventListener('click',() => {
                console.log('Language button clicked');
                this.toggle();
            });
            console.log('Language: Event listener added successfully');
        }

        // Apply saved/detected language immediately
        this.updateLanguage();
        console.log('Language: Applied language on startup');
    },

    toggle: function () {
        console.log('Toggling language from',this.currentLang);
        this.currentLang = this.currentLang === 'en' ? 'vi' : 'en';
        localStorage.setItem('language',this.currentLang);
        console.log('Language toggled to',this.currentLang,'- saved to localStorage');
        this.updateLanguage();
    },

    updateLanguage: function () {
        console.log('Updating language to',this.currentLang);

        // Only update language button on main page
        const langBtn = document.getElementById('currentLang');
        if (langBtn && !document.querySelector('.sub-page-container')) {
            langBtn.textContent = this.currentLang.toUpperCase();
            console.log('Updated language button to:',this.currentLang.toUpperCase());
        }

        const t = translations[this.currentLang];
        console.log('Translation object:',t ? 'found' : 'not found');

        if (document.querySelector('.sub-page-container')) {
            console.log('Detected sub-page, updating sub-page content');
            this.updateSubPage(t);
        } else {
            console.log('Detected main page, updating main page content');
            this.updateMainPage(t);
        }
    },

    updateMainPage: function (t) {
        this.updateElement('.app-title',t.title);
        this.updateElement('.app-subtitle',t.subtitle);
        this.updateElement('.version-badge span',t.version);
        this.updateElement('.download-title',t.downloadTitle);

        const features = document.querySelectorAll('.feature-card');
        const featureKeys = ['interactive','coinSystem','progress','updates','multilang','sync'];
        features.forEach((card,index) => {
            const key = featureKeys[index];
            if (key && t.features[key]) {
                const title = card.querySelector('.feature-title');
                const desc = card.querySelector('.feature-desc');
                if (title) title.textContent = t.features[key].title;
                if (desc) desc.textContent = t.features[key].desc;
            }
        });

        this.updateElement('.developer-title',t.developer.title);
        this.updateElement('.developer-name',t.developer.name);
        this.updateElement('.developer-desc',t.developer.desc);
        this.updateElement('.developer-link',t.developer.portfolio);

        const googlePlayBtn = document.querySelector('.download-btn div');
        if (googlePlayBtn) {
            googlePlayBtn.innerHTML = `<div style="font-size: 12px; opacity: 0.8;">${t.getItOn}</div><div>${t.googlePlay}</div>`;
        }

        const appStoreBtn = document.querySelectorAll('.download-btn div')[1];
        if (appStoreBtn) {
            appStoreBtn.innerHTML = `<div style="font-size: 12px; opacity: 0.8;">${t.downloadOn}</div><div>${t.appStore}</div>`;
        }

        const details = document.querySelector('.firebase-status');
        if (details) {
            details.innerHTML = `<strong>${t.appDetails}</strong><br>${t.details.join('<br>')}`;
        }

        const policyLinks = document.querySelectorAll('a[href^="pages/"]');
        if (policyLinks.length >= 3) {
            policyLinks[0].innerHTML = t.privacyPolicy;
            policyLinks[1].innerHTML = t.termsOfService;
            policyLinks[2].innerHTML = t.support;
        }

        const appStoreLink = document.querySelector('a[onclick]');
        if (appStoreLink) {
            appStoreLink.setAttribute('onclick',`alert('${t.comingSoon}')`);
        }
    },

    updateSubPage: function (t) {
        const title = document.querySelector('h1');
        if (!title) return;

        const titleText = title.textContent.trim();
        let pageType = '';

        if (titleText.includes('Privacy') || titleText.includes('Bảo Mật')) {
            pageType = 'privacy';
        } else if (titleText.includes('Terms') || titleText.includes('Điều Khoản')) {
            pageType = 'terms';
        } else if (titleText.includes('Support') || titleText.includes('Hỗ Trợ')) {
            pageType = 'support';
        }

        if (!pageType || !t.pages[pageType]) return;

        const page = t.pages[pageType];

        // Update basic elements
        this.updateElement('h1',page.title);
        this.updateElement('.back-btn',page.backBtn);
        this.updateElement('.last-updated',page.lastUpdated);

        // Update all h2 section headers
        const h2Elements = document.querySelectorAll('h2');
        const sectionValues = Object.values(page.sections || {});
        h2Elements.forEach((h2,index) => {
            if (sectionValues[index]) {
                h2.textContent = sectionValues[index];
                console.log('Updated section',index,'to:',sectionValues[index]);
            }
        });

        // Update page-specific content
        if (pageType === 'privacy' && page.content) {
            this.updatePrivacyContent(page.content);
        } else if (pageType === 'terms' && page.content) {
            this.updateTermsContent(page.content);
        } else if (pageType === 'support' && page.content) {
            this.updateSupportContent(page.content);
        }

        console.log(`Updated ${pageType} page content`);
    },

    updateTermsContent: function (content) {
        console.log('Updating Terms content to:',this.currentLang);

        // Update all paragraphs based on position and content
        const allPs = document.querySelectorAll('p');

        // First paragraph after title - should be acceptance intro
        if (allPs.length >= 2) {
            allPs[1].textContent = content.acceptanceIntro;
        }

        // Update specific content based on current text
        allPs.forEach((p,index) => {
            const text = p.textContent.toLowerCase();

            // App description paragraph
            if (text.includes('educational mobile application') || text.includes('ứng dụng giáo dục di động')) {
                p.textContent = this.currentLang === 'vi' ?
                    'Logic Mathematics là một ứng dụng giáo dục di động được thiết kế để giúp người dùng học và thực hành logic toán học thông qua các bài tập tương tác, câu đố và thử thách.' :
                    'Logic Mathematics is an educational mobile application designed to help users learn and practice mathematical logic through interactive exercises, quizzes, and challenges.';
            }

            // Purchase intro
            else if (text.includes('offers in-app purchases') || text.includes('cung cấp các giao dịch')) {
                p.textContent = content.purchasesIntro;
            }

            // Acceptable use intro
            else if (text.includes('lawful purposes') || text.includes('mục đích hợp pháp')) {
                p.textContent = content.useIntro;
            }

            // Intellectual property
            else if (text.includes('owned by') || text.includes('thuộc sở hữu')) {
                p.textContent = content.ipIntro;
            }

            // Limitation of liability
            else if (text.includes('shall not be liable') || text.includes('không chịu trách nhiệm')) {
                p.textContent = content.limitationIntro;
            }

            // Updates
            else if (text.includes('reserve the right') || text.includes('có quyền cập nhật')) {
                p.textContent = content.updatesIntro;
            }

            // Termination
            else if (text.includes('terminate or suspend') || text.includes('chấm dứt quyền')) {
                p.textContent = content.terminationIntro;
            }

            // Contact
            else if (text.includes('questions about these terms') || text.includes('câu hỏi về các điều khoản')) {
                p.textContent = content.contactIntro;
            }
        });

        // Update bullet points for user data
        const bulletPs = document.querySelectorAll('p');
        bulletPs.forEach(p => {
            if (p.textContent.startsWith('•')) {
                const text = p.textContent.toLowerCase();
                if (text.includes('progress') && text.includes('stored')) {
                    p.textContent = this.currentLang === 'vi' ?
                        '• Tiến độ và thành tích của bạn được lưu trữ cục bộ và trên cloud' :
                        '• Your progress and achievements are stored locally and in the cloud';
                } else if (text.includes('responsible') || text.includes('security')) {
                    p.textContent = this.currentLang === 'vi' ?
                        '• Bạn có trách nhiệm duy trì bảo mật thiết bị của mình' :
                        '• You are responsible for maintaining the security of your device';
                } else if (text.includes('terminate') || text.includes('violate')) {
                    p.textContent = this.currentLang === 'vi' ?
                        '• Chúng tôi có quyền chấm dứt tài khoản vi phạm điều khoản' :
                        '• We reserve the right to terminate accounts that violate our terms';
                }
            }
        });

        console.log('Terms of service content updated to',this.currentLang);
    },

    updateSupportContent: function (content) {
        console.log('Updating Support content to:',this.currentLang);

        // Update main help intro in support card
        const supportCard = document.querySelector('.support-card');
        if (supportCard) {
            const helpP = supportCard.querySelector('p');
            if (helpP) {
                helpP.textContent = content.helpIntro;
            }
        }

        // Update FAQ items
        const faqItems = document.querySelectorAll('.faq-item');
        content.faqItems.forEach((item,index) => {
            if (faqItems[index]) {
                const question = faqItems[index].querySelector('.faq-question');
                if (question) {
                    question.textContent = `Q: ${item.q}`;
                }

                // Find the answer paragraph (usually the next p after question)
                const answerP = faqItems[index].querySelector('p');
                if (answerP && !answerP.classList.contains('faq-question')) {
                    answerP.textContent = `A: ${item.a}`;
                }
            }
        });

        // Update contact buttons
        const contactBtns = document.querySelectorAll('.contact-btn');
        if (this.currentLang === 'vi' && contactBtns.length >= 2) {
            if (contactBtns[0] && contactBtns[0].textContent.includes('Portfolio')) {
                contactBtns[0].innerHTML = '🌐 Portfolio Nhà Phát Triển';
            }
            if (contactBtns[1] && contactBtns[1].textContent.includes('App Store')) {
                contactBtns[1].innerHTML = '📱 Đánh Giá App Store';
            }
        } else if (this.currentLang === 'en' && contactBtns.length >= 2) {
            if (contactBtns[0]) {
                contactBtns[0].innerHTML = '🌐 Developer Portfolio';
            }
            if (contactBtns[1]) {
                contactBtns[1].innerHTML = '📱 App Store Review';
            }
        }

        console.log('Support page content updated to',this.currentLang);
    },

    updatePrivacyContent: function (content) {
        // Update intro texts
        const infoIntro = document.querySelector('h2:nth-of-type(1) + p');
        if (infoIntro) infoIntro.textContent = content.infoIntro;

        const useIntro = document.querySelector('h2:nth-of-type(2) + p');
        if (useIntro) useIntro.textContent = content.useIntro;

        const securityInfo = document.querySelector('.security-info');
        if (securityInfo) securityInfo.textContent = content.securityInfo;

        const thirdPartyIntro = document.querySelector('h2:nth-of-type(4) + p');
        if (thirdPartyIntro) thirdPartyIntro.textContent = content.thirdPartyIntro;

        // Update security features
        const securityTitles = document.querySelectorAll('.security-item strong');
        const securityDescs = document.querySelectorAll('.security-item p');
        content.securityFeatures.forEach((feature,index) => {
            if (securityTitles[index]) securityTitles[index].textContent = feature.title;
            if (securityDescs[index]) securityDescs[index].textContent = feature.desc;
        });

        // Update user rights
        const rightTitles = document.querySelectorAll('.right-item strong');
        const rightDescs = document.querySelectorAll('.right-item p');
        content.userRights.forEach((right,index) => {
            if (rightTitles[index]) rightTitles[index].textContent = right.title;
            if (rightDescs[index]) rightDescs[index].textContent = right.desc;
        });

        // Update contact section
        const contactIntro = document.querySelector('.contact-section > p');
        if (contactIntro) contactIntro.textContent = content.contactIntro;

        const responseTime = document.querySelector('.response-time');
        if (responseTime) responseTime.textContent = content.responseTime;

        // Update safe for all section
        const safeTitle = document.querySelector('.privacy-highlight strong');
        if (safeTitle) safeTitle.textContent = content.safeForAll;

        const safeDesc = document.querySelector('.privacy-highlight p');
        if (safeDesc) {
            safeDesc.innerHTML = `<strong>${content.safeForAll}</strong> ${content.safeDescription}`;
        }

        console.log('Privacy policy content updated');
    },

    updateElement: function (selector,text) {
        const element = document.querySelector(selector);
        if (element) {
            element.textContent = text;
            console.log('Updated',selector,'to:',text);
        }
    }
};

console.log('Language.js loaded!');