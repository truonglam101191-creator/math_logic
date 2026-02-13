class Duck {
  String id;
  String assetUrl;
  double x; // logical coordinate (0..width)
  double y; // logical coordinate (0..height)
  double vx;
  double vy;
  double size; // logical size (width)
  double rotation; // radians
  double phase; // animation phase for bobbing
  int points;
  bool alive;

  Duck({
    required this.id,
    required this.assetUrl,
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.size,
    this.points = 10,
    this.rotation = 0.0,
    this.phase = 0.0,
  }) : alive = true;
}
