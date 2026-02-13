// Enhanced Support Content Update Function
window.updateSupportContentEnhanced = function (currentLang) {
    console.log('🔧 Enhanced Support Update - Language:',currentLang);

    // Update ALL FAQ items with proper mapping
    const faqItems = document.querySelectorAll('.faq-item');
    console.log('Found FAQ items:',faqItems.length);

    faqItems.forEach((item,index) => {
        const question = item.querySelector('.faq-question');
        const answer = item.querySelector('p');

        if (question && answer) {
            const currentQ = question.textContent.toLowerCase();
            console.log(`FAQ ${index}:`,currentQ);

            // Map each FAQ specifically
            if (currentQ.includes('earn coins') || currentQ.includes('kiếm xu')) {
                question.textContent = currentLang === 'vi' ? 'Q: Làm thế nào để kiếm xu?' : 'Q: How do I earn coins in the app?';
                answer.textContent = currentLang === 'vi' ?
                    'A: Bạn có thể kiếm xu bằng cách giải đúng các bài toán, hoàn thành thử thách và đạt được mốc quan trọng. Bạn cũng có thể mua thêm xu thông qua cửa hàng trong ứng dụng.' :
                    'A: You can earn coins by solving math problems correctly, completing challenges, and achieving milestones. You can also purchase additional coins through the in-app shop.';
            }
            else if (currentQ.includes('crashes') || currentQ.includes('freezes') || currentQ.includes('crash') || currentQ.includes('đóng băng')) {
                question.textContent = currentLang === 'vi' ? 'Q: Tôi nên làm gì nếu ứng dụng bị crash hoặc đóng băng?' : 'Q: What should I do if the app crashes or freezes?';
                answer.textContent = currentLang === 'vi' ?
                    'A: Đầu tiên, thử khởi động lại ứng dụng. Nếu vấn đề vẫn tiếp tục, hãy khởi động lại thiết bị. Đảm bảo bạn đã cài đặt phiên bản mới nhất từ app store.' :
                    'A: First, try restarting the app. If the problem persists, restart your device. Make sure you have the latest version of the app installed from the app store.';
            }
            else if (currentQ.includes('sync') || currentQ.includes('devices') || currentQ.includes('đồng bộ')) {
                question.textContent = currentLang === 'vi' ? 'Q: Tôi có thể đồng bộ tiến độ trên nhiều thiết bị không?' : 'Q: Can I sync my progress across multiple devices?';
                answer.textContent = currentLang === 'vi' ?
                    'A: Có! Tiến độ của bạn tự động được lưu lên cloud bằng Firebase. Chỉ cần đảm bảo bạn sử dụng cùng tài khoản Google trên tất cả thiết bị.' :
                    'A: Yes! Your progress is automatically saved to the cloud using Firebase. Just make sure you\'re using the same Google account on all devices.';
            }
            else if (currentQ.includes('hints') || currentQ.includes('gợi ý')) {
                question.textContent = currentLang === 'vi' ? 'Q: Làm thế nào để sử dụng gợi ý?' : 'Q: How do I use hints?';
                answer.textContent = currentLang === 'vi' ?
                    'A: Khi bạn gặp khó khăn với bài toán, nhấn nút gợi ý (💡). Sử dụng gợi ý sẽ tốn 1 xu, vì vậy hãy sử dụng một cách khôn ngoan!' :
                    'A: When you\'re stuck on a problem, tap the hint button (💡). Using a hint will cost 1 coin, so use them wisely!';
            }
            else if (currentQ.includes('suitable') || currentQ.includes('children') || currentQ.includes('phù hợp') || currentQ.includes('trẻ em')) {
                question.textContent = currentLang === 'vi' ? 'Q: Ứng dụng có phù hợp cho trẻ em không?' : 'Q: Is the app suitable for children?';
                answer.textContent = currentLang === 'vi' ?
                    'A: Có! Logic Mathematics được thiết kế giáo dục và an toàn cho người dùng ở mọi lứa tuổi, bao gồm trẻ em. Nội dung phù hợp và giúp phát triển kỹ năng tư duy toán học.' :
                    'A: Yes! Logic Mathematics is designed to be educational and safe for users of all ages, including children. The content is appropriate and helps develop mathematical thinking skills.';
            }
        }
    });

    // Update feature items
    const featureItems = document.querySelectorAll('.feature-item');
    if (featureItems.length >= 4) {
        if (currentLang === 'vi') {
            featureItems[0].querySelector('h3').textContent = '📚 15+ Chủ Đề Toán';
            featureItems[0].querySelector('p').textContent = 'Từ số học cơ bản đến hình học nâng cao';
            featureItems[1].querySelector('h3').textContent = '🏆 Hệ Thống Thành Tích';
            featureItems[1].querySelector('p').textContent = 'Nhận phần thưởng cho tiến độ của bạn';
            featureItems[2].querySelector('h3').textContent = '💡 Hệ Thống Gợi Ý';
            featureItems[2].querySelector('p').textContent = 'Nhận trợ giúp khi bạn gặp khó khăn';
            featureItems[3].querySelector('h3').textContent = '🌍 Đa Ngôn Ngữ';
            featureItems[3].querySelector('p').textContent = 'Có sẵn bằng tiếng Anh và tiếng Việt';
        } else {
            featureItems[0].querySelector('h3').textContent = '📚 15+ Math Topics';
            featureItems[0].querySelector('p').textContent = 'From basic arithmetic to advanced geometry';
            featureItems[1].querySelector('h3').textContent = '🏆 Achievement System';
            featureItems[1].querySelector('p').textContent = 'Earn rewards for your progress';
            featureItems[2].querySelector('h3').textContent = '💡 Hint System';
            featureItems[2].querySelector('p').textContent = 'Get help when you\'re stuck';
            featureItems[3].querySelector('h3').textContent = '🌍 Multi-language';
            featureItems[3].querySelector('p').textContent = 'Available in English and Vietnamese';
        }
    }

    // Update buttons
    const contactBtns = document.querySelectorAll('.contact-btn');
    contactBtns.forEach((btn,index) => {
        if (currentLang === 'vi') {
            if (index === 0) btn.innerHTML = '🌐 Portfolio Nhà Phát Triển';
            else if (index === 1) btn.innerHTML = '📱 Đánh Giá App Store';
            else if (index === 2) btn.innerHTML = '⭐ Đánh Giá trên Google Play';
        } else {
            if (index === 0) btn.innerHTML = '🌐 Developer Portfolio';
            else if (index === 1) btn.innerHTML = '📱 App Store Review';
            else if (index === 2) btn.innerHTML = '⭐ Rate on Google Play';
        }
    });

    // Update other content
    const allPs = document.querySelectorAll('p');
    allPs.forEach(p => {
        const text = p.textContent.toLowerCase();
        if (text.includes('enjoying') && text.includes('review')) {
            p.textContent = currentLang === 'vi' ?
                'Thích Logic Mathematics? Vui lòng để lại đánh giá tích cực trên app store. Phản hồi của bạn giúp chúng tôi cải thiện và tiếp cận nhiều học viên hơn!' :
                'Enjoying Logic Mathematics? Please consider leaving a positive review on the app store. Your feedback helps us improve and reach more learners!';
        } else if (text.includes('thank you') && text.includes('logic mathematics')) {
            p.innerHTML = currentLang === 'vi' ?
                '<strong>Cảm ơn bạn đã sử dụng Logic Mathematics!</strong>' :
                '<strong>Thank you for using Logic Mathematics!</strong>';
        } else if (text.includes('committed') && text.includes('accessible')) {
            p.textContent = currentLang === 'vi' ?
                'Chúng tôi cam kết làm cho việc học toán trở nên thú vị và dễ tiếp cận với mọi người.' :
                'We\'re committed to making math learning fun and accessible for everyone.';
        } else if (text.includes('need assistance') || text.includes('cần hỗ trợ')) {
            p.textContent = currentLang === 'vi' ?
                'Cần hỗ trợ với Logic Mathematics? Chúng tôi sẵn sàng giúp đỡ! Chọn cách tốt nhất để liên hệ với chúng tôi:' :
                'Need assistance with Logic Mathematics? We\'re here to help! Choose the best way to reach us:';
        }
    });

    console.log('✅ Enhanced support content updated successfully');
};

console.log('Enhanced Support Content Updater Loaded!');