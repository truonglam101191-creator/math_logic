class GridModel {
  GridModel({required this.rows, required this.cols});

  final int rows;
  final int cols;

  bool inBounds(int row, int col) {
    return row >= 0 && row < rows && col >= 0 && col < cols;
  }
}
