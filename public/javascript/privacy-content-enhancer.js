// Enhanced Privacy Policy Content Update Function
window.updatePrivacyContentEnhanced = function (currentLang) {
    console.log('🔒 Enhanced Privacy Update - Language:',currentLang);

    // Update all content paragraphs
    const allPs = document.querySelectorAll('p');

    allPs.forEach((p,index) => {
        const text = p.textContent.toLowerCase();

        // Information collect intro
        if (text.includes('collects minimal information') || text.includes('thu thập thông tin tối thiểu')) {
            p.textContent = currentLang === 'vi' ?
                'Logic Mathematics thu thập thông tin tối thiểu để cung cấp trải nghiệm học tập tốt nhất:' :
                'Logic Mathematics collects minimal information to provide you with the best learning experience:';
        }

        // How we use intro
        else if (text.includes('we use the collected information') || text.includes('chúng tôi sử dụng thông tin')) {
            p.textContent = currentLang === 'vi' ?
                'Chúng tôi sử dụng thông tin thu thập được để:' :
                'We use the collected information to:';
        }

        // Data storage and security
        else if (text.includes('securely stored using firebase') || text.includes('được lưu trữ an toàn')) {
            p.textContent = currentLang === 'vi' ?
                'Dữ liệu của bạn được lưu trữ an toàn bằng dịch vụ Firebase với mã hóa tiêu chuẩn ngành. Chúng tôi thực hiện các biện pháp bảo mật phù hợp để bảo vệ thông tin cá nhân của bạn khỏi truy cập trái phép.' :
                'Your data is securely stored using Firebase services with industry-standard encryption. We implement appropriate security measures to protect your personal information against unauthorized access.';
        }

        // Third party services intro
        else if (text.includes('our app uses the following') || text.includes('ứng dụng của chúng tôi sử dụng')) {
            p.textContent = currentLang === 'vi' ?
                'Ứng dụng của chúng tôi sử dụng các dịch vụ bên thứ ba sau:' :
                'Our app uses the following third-party services:';
        }

        // Children's privacy
        else if (text.includes('designed to be safe for users') || text.includes('được thiết kế an toàn')) {
            p.textContent = currentLang === 'vi' ?
                'Ứng dụng của chúng tôi được thiết kế an toàn cho người dùng ở mọi lứa tuổi. Chúng tôi không cố ý thu thập thông tin cá nhân từ trẻ em dưới 13 tuổi mà không có sự đồng ý của cha mẹ.' :
                'Our app is designed to be safe for users of all ages. We do not knowingly collect personal information from children under 13 without parental consent.';
        }

        // Your rights intro
        else if (text.includes('you have the right to') || text.includes('bạn có quyền')) {
            p.textContent = currentLang === 'vi' ?
                'Bạn có quyền:' :
                'You have the right to:';
        }

        // Contact us
        else if (text.includes('questions about this privacy policy') || text.includes('câu hỏi về chính sách')) {
            p.textContent = currentLang === 'vi' ?
                'Nếu bạn có bất kỳ câu hỏi nào về Chính sách Bảo mật này, vui lòng liên hệ với chúng tôi thông qua phần hỗ trợ của ứng dụng hoặc truy cập portfolio nhà phát triển của chúng tôi.' :
                'If you have any questions about this Privacy Policy, please contact us through the app\'s support section or visit our developer portfolio.';
        }

        // Policy updates footer
        else if (text.includes('may be updated from time to time') || text.includes('có thể được cập nhật')) {
            p.textContent = currentLang === 'vi' ?
                'Chính sách này có thể được cập nhật theo thời gian. Chúng tôi sẽ thông báo cho người dùng về bất kỳ thay đổi quan trọng nào.' :
                'This policy may be updated from time to time. We will notify users of any material changes.';
        }

        // Bullet points - Information we collect
        else if (p.textContent.startsWith('•')) {
            const text = p.textContent.toLowerCase();

            if (text.includes('device information')) {
                p.textContent = currentLang === 'vi' ?
                    '• Thông tin thiết bị để tối ưu hóa ứng dụng' :
                    '• Device information for app optimization';
            } else if (text.includes('progress data')) {
                p.textContent = currentLang === 'vi' ?
                    '• Dữ liệu tiến độ để theo dõi hành trình học tập của bạn' :
                    '• Progress data to track your learning journey';
            } else if (text.includes('coins and achievements')) {
                p.textContent = currentLang === 'vi' ?
                    '• Dữ liệu xu và thành tích' :
                    '• Coins and achievements data';
            } else if (text.includes('crash reports')) {
                p.textContent = currentLang === 'vi' ?
                    '• Báo cáo lỗi để cải thiện tính ổn định ứng dụng' :
                    '• Crash reports to improve app stability';
            }

            // How we use information
            else if (text.includes('provide personalized')) {
                p.textContent = currentLang === 'vi' ?
                    '• Cung cấp trải nghiệm học tập cá nhân hóa' :
                    '• Provide personalized learning experiences';
            } else if (text.includes('save your progress')) {
                p.textContent = currentLang === 'vi' ?
                    '• Lưu tiến độ của bạn trên các thiết bị' :
                    '• Save your progress across devices';
            } else if (text.includes('improve app performance')) {
                p.textContent = currentLang === 'vi' ?
                    '• Cải thiện hiệu suất và độ ổn định ứng dụng' :
                    '• Improve app performance and stability';
            } else if (text.includes('show relevant advertisements')) {
                p.textContent = currentLang === 'vi' ?
                    '• Hiển thị quảng cáo phù hợp (nếu có)' :
                    '• Show relevant advertisements (if applicable)';
            }

            // Third-party services
            else if (text.includes('firebase (google)')) {
                p.textContent = currentLang === 'vi' ?
                    '• Firebase (Google) - để lưu trữ dữ liệu và phân tích' :
                    '• Firebase (Google) - for data storage and analytics';
            } else if (text.includes('google mobile ads')) {
                p.textContent = currentLang === 'vi' ?
                    '• Google Mobile Ads - để quảng cáo' :
                    '• Google Mobile Ads - for advertising';
            } else if (text.includes('google play services')) {
                p.textContent = currentLang === 'vi' ?
                    '• Google Play Services - cho các giao dịch mua trong ứng dụng' :
                    '• Google Play Services - for in-app purchases';
            }

            // Your rights
            else if (text.includes('access your personal data')) {
                p.textContent = currentLang === 'vi' ?
                    '• Truy cập dữ liệu cá nhân của bạn' :
                    '• Access your personal data';
            } else if (text.includes('request deletion')) {
                p.textContent = currentLang === 'vi' ?
                    '• Yêu cầu xóa dữ liệu của bạn' :
                    '• Request deletion of your data';
            } else if (text.includes('opt-out of data collection')) {
                p.textContent = currentLang === 'vi' ?
                    '• Từ chối thu thập dữ liệu khi có thể' :
                    '• Opt-out of data collection where applicable';
            }
        }
    });

    console.log('✅ Enhanced privacy content updated successfully');
};

console.log('Enhanced Privacy Content Updater Loaded!');