import os
import re

# Đường dẫn tới thư mục chứa mã nguồn của bạn
source_directory = '/Users/dong/appnext3/lib/views/bottom_nav_controller'

# Hàm để tìm tất cả các chỗ sử dụng Localization.translate
def find_localization_translations(directory):
    translations = {}
    for root, _, files in os.walk(directory):
        for file in files:
            if file.endswith('.dart'):
                file_path = os.path.join(root, file)
                with open(file_path, 'r', encoding='utf-8') as f:
                    content = f.read()
                    matches = re.findall(r"Localization\.translate\(['\"]([^'\"]+)['\"]\)", content)
                    if matches:
                        translations[file_path] = matches
    return translations

# Tìm tất cả các chỗ sử dụng Localization.translate
translations = find_localization_translations(source_directory)
# In ra kết quả
for file_path, matches in translations.items():
    for match in matches:
        print(f'{match}')