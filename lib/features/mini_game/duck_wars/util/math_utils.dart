import 'dart:math';

double randRange(Random r, double a, double b) => a + r.nextDouble() * (b - a);

double clamp(double v, double a, double b) => v < a ? a : (v > b ? b : v);
