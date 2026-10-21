# PRM393 - LAB 6: BUILDING A RESPONSIVE MOVIE GENRE BROWSING SCREEN

> **Học phần**: PRM393 - Mobile Programming (Flutter & Dart)  
> **Chủ đề**: Responsive UI & Adaptive Layouts (Module 6)  
> **Mục tiêu**: Xây dựng màn hình duyệt phim theo thể loại với khả năng thích ứng linh hoạt (Responsive) trên Phone (< 800px) và Tablet / Desktop Web (≥ 800px), kết hợp tìm kiếm thời gian thực, lọc đa thể loại (multi-genre filtering) và sắp xếp đa tiêu chí.

---

## 1. TỔNG QUAN VỀ DỰ ÁN

Dự án triển khai đầy đủ 3 Sub-tasks được yêu cầu trong tài liệu Lab 6:
- **Sub-task 1**: Search bar với container bo tròn và dải Genre Chips sử dụng widget `Wrap` hỗ trợ ngắt dòng tự động khi co giãn màn hình.
- **Sub-task 2**: Bố cục tương thích đa kích thước (Responsive Layout) chuyển đổi linh hoạt:
  - **Phone (< 800px)**: Danh sách cuộn dọc 1 cột bằng `ListView.builder`.
  - **Tablet / Desktop (≥ 800px)**: Lưới 2 cột bằng `GridView.builder` (`crossAxisCount: 2`, `childAspectRatio: 2.8`).
- **Sub-task 3**: Component thẻ phim (`MovieCard`) tích hợp `LayoutBuilder` cục bộ để tự động co giãn kích thước ảnh Poster tùy thuộc vào chiều rộng khả dụng của Card (95px trên Phone, 110px trên Tablet).

Ngoài ra, dự án bổ sung các tính năng nâng cao (Bonus enhancements):
- Bộ chọn sắp xếp (Sort Dropdown): A–Z, Z–A, Năm phát hành (Mới nhất), Đánh giá (Cao nhất).
- Badge đếm số lượng thể loại đang chọn và nút "Clear filters" tiện dụng.
- Nhãn chỉ báo chế độ hiển thị động: `Phone (<800px)` hoặc `Tablet/Web (≥800px)`.
- Fallback ảnh thông minh khi poster tải thất bại hoặc đang tải.

---

## 2. CẤU TRÚC THƯ MỤC DỰ ÁN

```text
prm393_lab_6/
├── bin/
│   └── cli_runner.dart            # Chạy kiểm thử logic độc lập (Pure Dart CLI)
├── lib/
│   ├── main.dart                  # Toàn bộ mã nguồn ứng dụng hoàn chỉnh
│   └── dartpad_single_file.dart   # File đơn độc lập, copy trực tiếp vào DartPad Flutter
├── test/
│   └── widget_test.dart           # Bộ widget tests kiểm tra cả 2 breakpoint Phone & Tablet
├── pubspec.yaml                   # Cấu hình dự án Flutter (Không phụ thuộc thư viện ngoài)
└── README.md                      # Báo cáo học thuật và tài liệu hướng dẫn thuyết minh
```

---

## 3. CHI TIẾT CÁC SUB-TASK VÀ GIẢI THÍCH MÃ NGUỒN

### 🎯 Sub-task 1: Search and Filter Bar
- **Thanh tìm kiếm (Search Bar)**:
  - Nằm trong `Container` bo cong mềm mại (`BorderRadius.circular(24)`), hiệu ứng đổ bóng mờ nhạt và viền xám tinh tế.
  - Tích hợp `TextField` bắt sự kiện `onChanged` để cập nhật biến trạng thái `_searchQuery` theo thời gian thực (real-time filtering, không phân biệt hoa thường).
  - Tích hợp nút xóa nhanh (Clear search icon button) xuất hiện khi người dùng đã nhập ký tự.
- **Dải thẻ thể loại (Genre Chips)**:
  - Sử dụng widget `Wrap` với khoảng cách `spacing: 8.0` và `runSpacing: 8.0`, đảm bảo khi màn hình thu hẹp (đặc biệt trên thiết bị di động), các thẻ chip tự động xuống hàng một cách mượt mà mà không gây ra lỗi tràn màn hình (Overflow).
  - Mỗi chip là một `FilterChip` tương tác được: người dùng có thể chọn hoặc bỏ chọn nhiều thể loại cùng lúc (`Set<String> _selectedGenres`).
  - Logic lọc: Hiển thị phim nếu phim đó chứa **bất kỳ** thể loại nào trong danh sách đang được chọn.

### 🎯 Sub-task 2: Responsive Layout (Breakpoint < 800px & ≥ 800px)
- Sử dụng kết hợp `MediaQuery` và `LayoutBuilder`:
  ```dart
  LayoutBuilder(
    builder: (context, constraints) {
      if (constraints.maxWidth < 800) {
        // Phone Layout: Cuộn dọc 1 cột
        return ListView.builder(
          itemCount: visibleMovies.length,
          itemBuilder: (context, index) => MovieCard(
            movie: visibleMovies[index],
            isGridView: false,
          ),
        );
      } else {
        // Tablet / Web Layout: Lưới 2 cột
        return GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 2.8,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: visibleMovies.length,
          itemBuilder: (context, index) => MovieCard(
            movie: visibleMovies[index],
            isGridView: true,
          ),
        );
      }
    },
  )
  ```
- **Điểm mạnh của việc dùng `LayoutBuilder`**: Phản hồi theo kích thước khung chứa cha (`maxWidth`) thay vì chỉ phụ thuộc vào toàn bộ cửa sổ màn hình, giúp code tái sử dụng tốt trong mọi ngữ cảnh (Split-screen, Foldable devices, v.v.).

### 🎯 Sub-task 3: Custom Movie Card Component
- `MovieCard` được thiết kế dưới dạng widget độc lập.
- Bên trong card, một widget `LayoutBuilder` cục bộ được áp dụng để tính toán kích thước ảnh Poster:
  ```dart
  LayoutBuilder(
    builder: (context, cardConstraints) {
      final posterWidth = cardConstraints.maxWidth > 500 ? 110.0 : 95.0;
      // Trả về Row chứa Poster + Column chứa thông tin phim
    },
  )
  ```
- **Nội dung thẻ phim**:
  - Ảnh Poster có bo góc `ClipRRect(borderRadius: BorderRadius.circular(12))` cùng `errorBuilder` và `loadingBuilder` xử lý ảnh mạng an toàn.
  - Tên phim in đậm, tự động cắt chuỗi nếu dài (`maxLines: 1`, `ellipsis`).
  - Năm phát hành và huy hiệu thể loại nhỏ gọn.
  - Đánh giá sao vàng với định dạng điểm số 1 chữ số thập phân (VD: `★ 8.8`).

---

## 4. HƯỚNG DẪN CHẠY VÀ KIỂM THỬ

### Cách 1: Chạy trực tiếp trên Web / Desktop / Emulator
```bash
cd D:\1.Work\Programs\flutter\prm393_lab_6
flutter run -d chrome
# Hoặc chạy trên Windows Desktop:
flutter run -d windows
```

### Cách 2: Chạy kiểm thử tự động (Widget Tests)
Kiểm tra tự động chuyển đổi Phone Mode và Tablet Mode:
```bash
flutter test
```
*Kết quả xác thực: 100% tests passed.*

### Cách 3: Chạy Dart CLI runner (Không cần mở máy ảo)
```bash
dart run bin/cli_runner.dart
```

### Cách 4: Sử dụng trên DartPad (Online)
1. Mở trình duyệt truy cập: [https://dartpad.dev/](https://dartpad.dev/)
2. Đảm bảo góc dưới phải chọn định dạng **Flutter**.
3. Mở file `lib/dartpad_single_file.dart`, copy toàn bộ nội dung và dán đè vào DartPad.
4. Bấm **Run** để trải nghiệm ứng dụng ngay trên trình duyệt mà không cần cài đặt SDK!

---

## 5. KỊCH BẢN THUYẾT MINH 3 PHÚT TRƯỚC GIẢNG VIÊN

| Thời gian | Nội dung trình bày | Thao tác demo trực quan |
| :--- | :--- | :--- |
| **00:00 - 00:45** | Chào thầy/cô, giới thiệu mục tiêu Lab 6: Xây dựng giao diện duyệt phim theo thể loại với kiến trúc Responsive UI thích ứng đa thiết bị. | Mở ứng dụng trên trình duyệt web ở độ rộng lớn (> 800px). Chỉ vào huy hiệu màu xanh: `Tablet/Web (≥800px)`. |
| **00:45 - 01:30** | Demo breakpoint < 800px vs ≥ 800px. Giải thích cách `LayoutBuilder` đọc `constraints.maxWidth` để tự động render `GridView` (2 cột) hay `ListView` (1 cột). | Kéo thu hẹp cửa sổ trình duyệt xuống dưới 800px. Ứng dụng tự động chuyển thành danh sách 1 cột dọc và huy hiệu chuyển thành `Phone (<800px)`. |
| **01:30 - 02:15** | Trình bày Sub-task 1 & 3: Cơ chế chống tràn chữ bằng widget `Wrap` cho thẻ thể loại. Trình bày `MovieCard` có `LayoutBuilder` con bên trong giúp thu phóng ảnh Poster động. | Bấm chọn đồng thời các chip thể loại: Action, Sci-Fi. Chỉ vào badge đếm số lượng "2" và danh sách phim được lọc tức thì. Nhập từ khóa tìm kiếm "Dark" vào Search bar. |
| **02:15 - 03:00** | Trình bày bộ sắp xếp đa tiêu chí (Sort Dropdown: Rating cao nhất, Năm mới nhất). Chạy lệnh `flutter test` để chứng minh mã nguồn đạt chuẩn 100% không lỗi. | Chọn sắp xếp theo Rating và bấm "Clear filters". Mở terminal chạy `flutter test` hiển thị `All tests passed!`. |
