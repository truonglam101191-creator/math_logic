// Enhanced Terms Content Update Function
window.updateTermsContentEnhanced = function (currentLang) {
    console.log('📋 Enhanced Terms Update - Language:',currentLang);

    // Update all content paragraphs and lists
    const allPs = document.querySelectorAll('p');
    const allUls = document.querySelectorAll('ul');

    allPs.forEach((p,index) => {
        const text = p.textContent.toLowerCase();

        // First paragraph - acceptance intro
        if (text.includes('by downloading, installing') || text.includes('bằng cách tải xuống')) {
            p.textContent = currentLang === 'vi' ?
                'Bằng cách tải xuống, cài đặt hoặc sử dụng ứng dụng Logic Mathematics, bạn đồng ý bị ràng buộc bởi các Điều khoản Dịch vụ này. Nếu bạn không đồng ý với các điều khoản này, vui lòng không sử dụng ứng dụng của chúng tôi.' :
                'By downloading, installing, or using the Logic Mathematics app, you agree to be bound by these Terms of Service. If you do not agree to these terms, please do not use our app.';
        }

        // App description
        else if (text.includes('educational mobile application') || text.includes('ứng dụng giáo dục di động')) {
            p.textContent = currentLang === 'vi' ?
                'Logic Mathematics là một ứng dụng giáo dục di động được thiết kế để giúp người dùng học và thực hành logic toán học thông qua các bài tập tương tác, câu đố và thử thách.' :
                'Logic Mathematics is an educational mobile application designed to help users learn and practice mathematical logic through interactive exercises, quizzes, and challenges.';
        }

        // In-app purchases intro
        else if (text.includes('offers in-app purchases') || text.includes('cung cấp các giao dịch mua')) {
            p.textContent = currentLang === 'vi' ?
                'Ứng dụng của chúng tôi cung cấp các giao dịch mua trong ứng dụng cho xu và các tính năng premium:' :
                'Our app offers in-app purchases for coins and premium features:';
        }

        // Acceptable use intro
        else if (text.includes('lawful purposes') || text.includes('mục đích hợp pháp')) {
            p.textContent = currentLang === 'vi' ?
                'Bạn đồng ý chỉ sử dụng ứng dụng cho các mục đích hợp pháp và theo các điều khoản này. Bạn không được:' :
                'You agree to use the app only for lawful purposes and in accordance with these terms. You may not:';
        }

        // Intellectual property
        else if (text.includes('owned by the developer') || text.includes('thuộc sở hữu của nhà phát triển')) {
            p.textContent = currentLang === 'vi' ?
                'Tất cả nội dung, tính năng và chức năng của Logic Mathematics thuộc sở hữu của nhà phát triển và được bảo vệ bởi bản quyền, nhãn hiệu và các luật sở hữu trí tuệ khác.' :
                'All content, features, and functionality of Logic Mathematics are owned by the developer and are protected by copyright, trademark, and other intellectual property laws.';
        }

        // Limitation of liability
        else if (text.includes('shall the developer be liable') || text.includes('nhà phát triển chịu trách nhiệm')) {
            p.textContent = currentLang === 'vi' ?
                'Trong mọi trường hợp, nhà phát triển sẽ không chịu trách nhiệm cho bất kỳ thiệt hại gián tiếp, ngẫu nhiên, đặc biệt, hệ quả hoặc trừng phạt nào phát sinh từ việc bạn sử dụng ứng dụng.' :
                'In no event shall the developer be liable for any indirect, incidental, special, consequential, or punitive damages resulting from your use of the app.';
        }

        // Updates and changes
        else if (text.includes('reserve the right to update') || text.includes('có quyền cập nhật')) {
            p.textContent = currentLang === 'vi' ?
                'Chúng tôi có quyền cập nhật ứng dụng và các điều khoản này bất cứ lúc nào. Việc tiếp tục sử dụng ứng dụng sau các thay đổi có nghĩa là chấp nhận các điều khoản mới.' :
                'We reserve the right to update the app and these terms at any time. Continued use of the app after changes constitutes acceptance of the new terms.';
        }

        // Termination
        else if (text.includes('terminate or suspend') || text.includes('chấm dứt hoặc đình chỉ')) {
            p.textContent = currentLang === 'vi' ?
                'Chúng tôi có thể chấm dứt hoặc đình chỉ quyền truy cập của bạn vào ứng dụng bất cứ lúc nào, không cần thông báo trước, đối với hành vi vi phạm các điều khoản này hoặc có hại đến người dùng khác.' :
                'We may terminate or suspend your access to the app at any time, without prior notice, for conduct that violates these terms or is harmful to other users.';
        }

        // Contact information
        else if (text.includes('questions about these terms') || text.includes('câu hỏi về các điều khoản')) {
            p.textContent = currentLang === 'vi' ?
                'Đối với các câu hỏi về Điều khoản Dịch vụ này, vui lòng liên hệ với chúng tôi thông qua phần hỗ trợ của ứng dụng hoặc truy cập portfolio nhà phát triển của chúng tôi.' :
                'For questions about these Terms of Service, please contact us through the app\'s support section or visit our developer portfolio.';
        }

        // Bullet points for user accounts
        else if (p.textContent.startsWith('•')) {
            const text = p.textContent.toLowerCase();
            if (text.includes('progress') && text.includes('stored')) {
                p.textContent = currentLang === 'vi' ?
                    '• Tiến độ và thành tích của bạn được lưu trữ cục bộ và trên cloud' :
                    '• Your progress and achievements are stored locally and in the cloud';
            } else if (text.includes('responsible') && text.includes('security')) {
                p.textContent = currentLang === 'vi' ?
                    '• Bạn có trách nhiệm duy trì bảo mật thiết bị của mình' :
                    '• You are responsible for maintaining the security of your device';
            } else if (text.includes('terminate') && text.includes('violate')) {
                p.textContent = currentLang === 'vi' ?
                    '• Chúng tôi có quyền chấm dứt tài khoản vi phạm điều khoản' :
                    '• We reserve the right to terminate accounts that violate our terms';
            } else if (text.includes('provided "as is"')) {
                p.textContent = currentLang === 'vi' ?
                    '• Ứng dụng được cung cấp "như hiện tại" mà không có bảo hành dưới bất kỳ hình thức nào' :
                    '• The app is provided "as is" without warranties of any kind';
            } else if (text.includes('uninterrupted') && text.includes('error-free')) {
                p.textContent = currentLang === 'vi' ?
                    '• Chúng tôi không đảm bảo hoạt động liên tục hoặc không có lỗi' :
                    '• We do not guarantee uninterrupted or error-free operation';
            } else if (text.includes('educational content')) {
                p.textContent = currentLang === 'vi' ?
                    '• Nội dung giáo dục chỉ dành cho mục đích thông tin' :
                    '• Educational content is for informational purposes only';
            }
        }

        // Last paragraph - jurisdiction
        else if (text.includes('governed by applicable law') || text.includes('tuân theo luật')) {
            p.textContent = currentLang === 'vi' ?
                'Các điều khoản này được điều chỉnh bởi luật pháp hiện hành và mọi tranh chấp sẽ được giải quyết theo thẩm quyền địa phương.' :
                'These terms are governed by applicable law and any disputes will be resolved in accordance with local jurisdiction.';
        }
    });

    // Update list items in ul elements
    allUls.forEach(ul => {
        const listItems = ul.querySelectorAll('li');
        listItems.forEach(li => {
            const text = li.textContent.toLowerCase();

            // In-app purchases list
            if (text.includes('purchases are final')) {
                li.textContent = currentLang === 'vi' ?
                    'Tất cả giao dịch mua là cuối cùng và không thể hoàn tiền trừ khi pháp luật yêu cầu' :
                    'All purchases are final and non-refundable unless required by law';
            } else if (text.includes('coins can be used')) {
                li.textContent = currentLang === 'vi' ?
                    'Xu có thể được sử dụng cho gợi ý và mở khóa nội dung' :
                    'Coins can be used for hints and unlocking content';
            } else if (text.includes('prices may vary')) {
                li.textContent = currentLang === 'vi' ?
                    'Giá có thể thay đổi theo khu vực và có thể thay đổi' :
                    'Prices may vary by region and are subject to change';
            } else if (text.includes('refund requests')) {
                li.textContent = currentLang === 'vi' ?
                    'Yêu cầu hoàn tiền nên được thực hiện thông qua nền tảng cửa hàng ứng dụng' :
                    'Refund requests should be made through the app store platform';
            }

            // Acceptable use list
            else if (text.includes('reverse engineer')) {
                li.textContent = currentLang === 'vi' ?
                    'Thiết kế ngược hoặc cố gắng trích xuất mã nguồn' :
                    'Reverse engineer or attempt to extract source code';
            } else if (text.includes('illegal or unauthorized')) {
                li.textContent = currentLang === 'vi' ?
                    'Sử dụng ứng dụng cho bất kỳ mục đích bất hợp pháp hoặc không được ủy quyền' :
                    'Use the app for any illegal or unauthorized purpose';
            } else if (text.includes('interfere with or disrupt')) {
                li.textContent = currentLang === 'vi' ?
                    'Can thiệp hoặc làm gián đoạn chức năng của ứng dụng' :
                    'Interfere with or disrupt the app\'s functionality';
            } else if (text.includes('share your account')) {
                li.textContent = currentLang === 'vi' ?
                    'Chia sẻ thông tin đăng nhập tài khoản của bạn với người khác' :
                    'Share your account credentials with others';
            }
        });
    });

    console.log('✅ Enhanced terms content updated successfully');
};

console.log('Enhanced Terms Content Updater Loaded!');