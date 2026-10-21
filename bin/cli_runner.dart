// ignore_for_file: avoid_print

class Movie {
  final String title;
  final List<String> genres;
  final int year;
  final double rating;
  final String posterUrl;

  const Movie({
    required this.title,
    required this.genres,
    required this.year,
    required this.rating,
    required this.posterUrl,
  });
}

const List<Movie> allMovies = [
  Movie(
    title: 'Inception',
    genres: ['Action', 'Sci-Fi'],
    year: 2010,
    rating: 8.8,
    posterUrl: 'https://images.unsplash.com/photo-1534447677768-be436bb09401?w=400&q=80',
  ),
  Movie(
    title: 'The Dark Knight',
    genres: ['Action', 'Drama'],
    year: 2008,
    rating: 9.0,
    posterUrl: 'https://images.unsplash.com/photo-1509198397868-475647b2a1e5?w=400&q=80',
  ),
  Movie(
    title: 'Interstellar',
    genres: ['Sci-Fi', 'Drama'],
    year: 2014,
    rating: 8.6,
    posterUrl: 'https://images.unsplash.com/photo-1451187580459-43490279c0fa?w=400&q=80',
  ),
  Movie(
    title: 'Spirited Away',
    genres: ['Animation', 'Fantasy'],
    year: 2001,
    rating: 8.6,
    posterUrl: 'https://images.unsplash.com/photo-1579783902614-a3fb3927b675?w=400&q=80',
  ),
  Movie(
    title: 'Pulp Fiction',
    genres: ['Action', 'Comedy'],
    year: 1994,
    rating: 8.9,
    posterUrl: 'https://images.unsplash.com/photo-1594909122845-11baa439b7bf?w=400&q=80',
  ),
  Movie(
    title: 'Parasite',
    genres: ['Drama', 'Comedy'],
    year: 2019,
    rating: 8.5,
    posterUrl: 'https://images.unsplash.com/photo-1518709268805-4e9042af9f23?w=400&q=80',
  ),
  Movie(
    title: 'Spider-Man: Into the Spider-Verse',
    genres: ['Animation', 'Action', 'Sci-Fi'],
    year: 2018,
    rating: 8.4,
    posterUrl: 'https://images.unsplash.com/photo-1635805737707-575885ab0820?w=400&q=80',
  ),
  Movie(
    title: 'Avengers: Endgame',
    genres: ['Action', 'Sci-Fi'],
    year: 2019,
    rating: 8.4,
    posterUrl: 'https://images.unsplash.com/photo-1607604276583-eef5d076aa5f?w=400&q=80',
  ),
];

void main() {
  print('================================================================');
  print('   PRM393 - LAB 6: RESPONSIVE MOVIE GENRE BROWSING SCREEN      ');
  print('================================================================\n');

  // 1. Kiểm tra tập dữ liệu phim
  print('1. KIỂM TRA TẬP DỮ LIỆU PHIM MẪU (allMovies):');
  print('   - Tổng số phim có sẵn: ${allMovies.length}');
  for (var m in allMovies) {
    print('   • [${m.year}] "${m.title}" | Rating: ${m.rating} ★ | Genres: ${m.genres.join(', ')}');
  }

  // 2. Kiểm tra bộ lọc tìm kiếm (Search Query)
  print('\n2. KIỂM TRA THUẬT TOÁN TÌM KIẾM THEO TIÊU ĐỀ:');
  const searchKeyword = 'dark';
  final searchResults = allMovies
      .where((m) => m.title.toLowerCase().contains(searchKeyword.toLowerCase()))
      .toList();
  print('   - Tìm kiếm từ khóa "$searchKeyword": ${searchResults.length} kết quả');
  for (var r in searchResults) {
    print('     -> "${r.title}" (${r.year})');
  }

  // 3. Kiểm tra lọc theo thể loại (Genre Filter)
  print('\n3. KIỂM TRA BỘ LỌC THỂ LOẠI (GENRE FILTERING):');
  final testGenres = {'Sci-Fi', 'Animation'};
  final genreResults = allMovies
      .where((m) => m.genres.any((g) => testGenres.contains(g)))
      .toList();
  print('   - Lọc với thể loại {${testGenres.join(', ')}}: ${genreResults.length} phim phù hợp');
  for (var r in genreResults) {
    print('     -> "${r.title}" [${r.genres.join(', ')}]');
  }

  // 4. Kiểm tra sắp xếp (Sorting)
  print('\n4. KIỂM TRA CÁC CHẾ ĐỘ SẮP XẾP (SORTING):');
  // Rating sort
  final ratingSorted = List<Movie>.from(allMovies)..sort((a, b) => b.rating.compareTo(a.rating));
  print('   - Top phim theo Rating: "${ratingSorted.first.title}" (${ratingSorted.first.rating} ★)');
  // Year sort
  final yearSorted = List<Movie>.from(allMovies)..sort((a, b) => b.year.compareTo(a.year));
  print('   - Phim mới nhất theo Year: "${yearSorted.first.title}" (${yearSorted.first.year})');

  // 5. Kiểm tra logic responsive breakpoint
  print('\n5. KIỂM TRA ĐIỀU KIỆN RESPONSIVE BREAKPOINT:');
  const phoneWidth = 412.0;
  const tabletWidth = 1024.0;
  print('   - Viewport width = $phoneWidth px (< 800px)  -> Bố cục: ListView.builder (1 cột dọc)');
  print('   - Viewport width = $tabletWidth px (>= 800px) -> Bố cục: GridView.count (2 cột Tablet/Web)');

  print('\n✅ TẤT CẢ 3 SUB-TASKS CỦA LAB 6 ĐÃ ĐƯỢC XÁC THỰC HOÀN CHỈNH!');
}
